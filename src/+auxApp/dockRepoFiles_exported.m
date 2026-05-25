classdef dockRepoFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        FilterDescriptionIcon  matlab.ui.control.Image
        FilterDescription      matlab.ui.control.Label
        FileDetailsButton      matlab.ui.control.Image
        DownloadButton         matlab.ui.control.Image
        UITable2Warning        matlab.ui.control.Label
        UITable2               matlab.ui.control.Table
        UITable2Label          matlab.ui.control.Label
        UITable2Icon           matlab.ui.control.Image
        UITable1               matlab.ui.control.Table
        FilterPanel            matlab.ui.container.Panel
        FilterGrid             matlab.ui.container.GridLayout
        SearchButton           matlab.ui.control.Image
        Description            matlab.ui.control.EditField
        DescriptionLabel       matlab.ui.control.Label
        FreqStop               matlab.ui.control.NumericEditField
        FreqStopLabel          matlab.ui.control.Label
        FreqStart              matlab.ui.control.NumericEditField
        FreqStartLabel         matlab.ui.control.Label
        PeriodEnd              matlab.ui.control.DatePicker
        PeriodEndLabel         matlab.ui.control.Label
        PeriodBegin            matlab.ui.control.DatePicker
        PeriodBeginLabel       matlab.ui.control.Label
        Receiver               matlab.ui.control.DropDown
        ReceiverLabel          matlab.ui.control.Label
        Location               matlab.ui.control.DropDown
        LocationLabel          matlab.ui.control.Label
        State                  matlab.ui.control.DropDown
        StateLabel             matlab.ui.control.Label
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true
        mainApp
        callingApp
        jsBackDoor
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        dbHandlerObj
        dbCacheData
        dbReference
        dbMatchMask
    end


    % properties (Access = private, Constant)
    %     %-----------------------------------------------------------------%
    %     TABLE_RESULTS = table( ...
    %         'Size', [0, 9], ...
    %         'VariableTypes', {'string', 'string', 'string', 'cell', 'datetime', 'datetime', 'uint32', 'string', 'cell'}, ...
    %         'VariableNames', {'REGIÃO', 'SENSOR', 'QTD. FLUXOS', 'LIMITES (MHz)', 'INÍCIO', 'FIM', 'ID', 'ARQUIVO', 'TAMANHO'} ...
    %     )
    % 
    %     TABLE_FILE_DETAILS = table( ...
    %         'Size', [0, 4], ...
    %         'VariableTypes', {'cell', 'datetime', 'datetime', 'string'}, ...
    %         'VariableNames', {'FAIXA (MHz)', 'INÍCIO', 'FIM', 'DESCRIÇÃO'} ...
    %     );
    % end

    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyJSCustomization(app)
            appName = class(app);
            elToModify = {
                app.State;
                app.DownloadButton;
                app.FileDetailsButton
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.State.UserData.id, 'selector', 'input', 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')), ...
                    struct('appName', appName, 'dataTag', app.DownloadButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Download de arquivos', 'zIndex', 901)), ... 
                    struct('appName', appName, 'dataTag', app.FileDetailsButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Detalhes do arquivo selecionado', 'zIndex', 901)) ... 
                });
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app, dbCacheData, dbReference)
            app.dbHandlerObj = app.mainApp.dbHandlerObj;
            app.dbCacheData = dbCacheData;
            app.dbReference = dbReference;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.UITable1.RowName = 'numbered';
            app.UITable2.RowName = 'numbered';
            app.FileDetailsButton.UserData.status = false;
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app, filterContext)
            set(app.State, 'Items', [{''}, cellstr(unique([app.dbCacheData.points.state_code]))], 'Value', char(filterContext.state))

            matchMask = applyFilter(app);
            dbFilteredReference = app.dbReference(matchMask, :);

            refreshLocationDropDown(app, dbFilteredReference, '')
            refreshReceiverDropDown(app, dbFilteredReference, filterContext.receiver)

            applyFilter(app);
        end

        %-----------------------------------------------------------------%
        function matchMask = applyFilter(app)
            % app.dbReference é uma tabela com as colunas "DistrictId", "StateCode", 
            % "Location", "StationNames" e "StationDetails".
            matchMask = true(height(app.dbReference), 1);

            % Filtragem "UF"
            stateCode = app.State.Value;
            if ~isempty(stateCode)
                matchMask = matchMask & app.dbReference.StateCode == string(stateCode);
            end

            % Filtragem "Localidade"
            location = app.Location.Value;
            if ~isempty(location)
                matchMask = matchMask & app.dbReference.Location == string(location);
            end

            % Filtragem "Sensor"
            receiver = app.Receiver.Value;
            if ~isempty(receiver)
                matchMask = matchMask & cellfun(@(x) any(contains(x, string(receiver))), app.dbReference.StationNames);
            end

            app.dbMatchMask = matchMask;
        end

        %-----------------------------------------------------------------%
        function refreshLocationDropDown(app, dbFilteredReference, previousValue)
            app.Location.Items = [{''}, cellstr(unique(dbFilteredReference.Location))'];

            if ~isempty(previousValue) && ismember(previousValue, app.Location.Items) && ~isequal(previousValue, app.Location.Value)
                app.Location.Value = previousValue;
            end
        end

        %-----------------------------------------------------------------%
        function refreshReceiverDropDown(app, dbFilteredReference, previousValue)
            app.Receiver.Items = [{''}, cellstr(unique(vertcat(dbFilteredReference.StationNames{:})))'];

            if ~isempty(previousValue) && ismember(previousValue, app.Receiver.Items) && ~isequal(previousValue, app.Receiver.Value)
                app.Receiver.Value = previousValue;
            end
        end

        %-----------------------------------------------------------------%
        function refreshTable(app, type, resultData)
            arguments
                app 
                type {mustBeMember(type, {'files', 'fileDetails'})}
                resultData
            end

            switch type
                case 'files'
                    resultData.("LIMITES (MHz)") = arrayfun(@(x, y) sprintf('%.3f – %.3f', x, y), resultData.("NU_FREQ_START"), resultData.("NU_FREQ_END"), 'UniformOutput', false);
                    resultData.("DT_TIME_START").Format = 'dd/MM/yyyy';
                    resultData.("DT_TIME_END").Format = 'dd/MM/yyyy';
                    resultData.("VL_FILE_SIZE_KB") = arrayfun(@(x) textFormatGUI.bytes2human(x), 1024*resultData.("VL_FILE_SIZE_KB"), "UniformOutput", false);
                    resultData.("ARQUIVO") = extractAfter(resultData.("NA_PATH"), app.mainApp.General.context.REPOSFI.containerPathPrefixToRemove) + "/" + resultData.("NA_FILE");
                    resultData = convertvars(resultData, 'ID_FILE', 'uint32');
                    resultData = renamevars(resultData(:, {'LOCALITY_LABELS', 'EQUIPMENT_LABELS', 'LIMITES (MHz)', 'NU_SPECTRA', 'DT_TIME_START', 'DT_TIME_END', 'ID_FILE', 'ARQUIVO', 'VL_FILE_SIZE_KB'}), ...
                        {'LOCALITY_LABELS', 'EQUIPMENT_LABELS', 'NU_SPECTRA', 'DT_TIME_START', 'DT_TIME_END', 'ID_FILE', 'VL_FILE_SIZE_KB'}, ...
                        {'REGIÃO', 'SENSOR', 'QTD. FLUXOS', 'INÍCIO', 'FIM', 'ID', 'TAMANHO'} ...
                    );

                    set(app.UITable1, 'Data', resultData, 'Selection', [])
                    set(app.UITable2, 'Data', [], 'Enable', 'off')
                    app.UITable2Warning.Visible = 'on';

                case 'fileDetails'
                    resultData = sortrows(resultData, {'NU_FREQ_START', 'NU_FREQ_END'});
                    resultData.("FAIXA (MHz)") = arrayfun(@(x, y) sprintf('%.3f – %.3f', x, y), resultData.("NU_FREQ_START"), resultData.("NU_FREQ_END"), 'UniformOutput', false);
                    resultData.("DT_TIME_START").Format = 'dd/MM/yyyy HH:mm:ss';
                    resultData.("DT_TIME_END").Format = 'dd/MM/yyyy HH:mm:ss';
                    resultData.("NA_DESCRIPTION")(resultData.("NA_DESCRIPTION") == "" | ismissing(resultData.("NA_DESCRIPTION"))) = "-";
                    resultData = renamevars(resultData(:, {'FAIXA (MHz)', 'DT_TIME_START', 'DT_TIME_END', 'NA_DESCRIPTION'}), ...
                        {'DT_TIME_START', 'DT_TIME_END', 'NA_DESCRIPTION'}, ...
                        {'INÍCIO', 'FIM', 'DESCRIÇÃO'} ...
                    );
    
                    set(app.UITable2, 'Data', resultData, 'Selection', [], 'Enable', 'on')
                    app.UITable2Warning.Visible = 'off';
            end
        end

        %-----------------------------------------------------------------%
        function refreshTableFootnote(app, currentFilter)
            description = {};
            if ~isempty(currentFilter.stateCode)
                description{end+1} = sprintf('UF: <b>%s</b>', currentFilter.stateCode);
            end

            if ~isempty(currentFilter.location)
                description{end+1} = sprintf('Localidade: <b>%s</b>', currentFilter.location);
            end

            if ~isempty(currentFilter.receiver)
                description{end+1} = sprintf('Sensor:<b>%s</b>', currentFilter.receiver);
            end

            if ~isnat(currentFilter.startDate) && ~isnat(currentFilter.endDate)
                description{end+1} = sprintf('Observação: <b>%s a %s</b>', string(currentFilter.startDate), string(currentFilter.endDate));
            end

            if ~isnan(currentFilter.freqStart) && ~isnan(currentFilter.freqEnd)
                description{end+1} = sprintf('Faixa: <b>%.3f – %.3f MHz</b>', currentFilter.freqStart, currentFilter.freqEnd);
            end

            app.FilterDescription.Text = sprintf('%s \n%d arquivos ', strjoin(description, ', '), height(app.UITable1.Data));
            app.FilterDescriptionIcon.Visible = 'on';
        end

        %-----------------------------------------------------------------%
        function [currentFilter, warningMsg] = getCurrentFilter(app)
            currentFilter = [];
            warningMsg = '';

            if isempty(app.State.Value) && isempty(app.Location.Value) && isempty(app.Receiver.Value)
                warningMsg = 'Selecione ao menos um dos filtros primários (UF, localidade ou sensor).';
                return
            end

            issues = {};

            isPeriodBeginNaT = isnat(app.PeriodBegin.Value);
            isPeriodEndNaT   = isnat(app.PeriodEnd.Value);
            if xor(isPeriodBeginNaT, isPeriodEndNaT) || (~isPeriodBeginNaT && ~isPeriodEndNaT && app.PeriodEnd.Value < app.PeriodBegin.Value)
                issues{end+1} = 'período de observação';
            end

            isFreqStartEmpty = isempty(app.FreqStart.Value);
            isFreqStopEmpty  = isempty(app.FreqStop.Value);
            if xor(isFreqStartEmpty, isFreqStopEmpty) || (~isFreqStartEmpty && ~isFreqStopEmpty && app.FreqStop.Value <= app.FreqStart.Value)
                issues{end+1} = 'faixa de frequência';
            end

            if ~isempty(issues)
                warningMsg = sprintf('Filtragem inválida. Corrija os valores de %s.', textFormatGUI.cellstr2FriendlyListWithQuotes(issues));
                return
            end

            currentFilter = struct( ...
                'stateCode', app.State.Value, ...
                'location', app.Location.Value, ...
                'receiver', app.Receiver.Value, ...
                'districtId', getParameterId(app, 'location'), ...
                'siteId', NaN, ...
                'equipmentId', getParameterId(app, 'receiver'), ...
                'startDate', app.PeriodBegin.Value, ...
                'endDate', app.PeriodEnd.Value, ...
                'freqStart', NaN, ...
                'freqEnd', NaN, ...
                'description', strtrim(app.Description.Value) ...
            );

            if ~isFreqStartEmpty
                currentFilter.freqStart = round(app.FreqStart.Value, 3);
            end

            if ~isFreqStopEmpty
                currentFilter.freqEnd = round(app.FreqStop.Value, 3);
            end
        end

        %-----------------------------------------------------------------%
        function id = getParameterId(app, name)
            arguments
                app
                name {mustBeMember(name, {'state', 'location', 'receiver'})}
            end

            id = NaN;

            matchMask = app.dbMatchMask;
            dbFilteredReference = app.dbReference(matchMask, :);

            switch name
                case 'state'
                    value = string(app.State.Value);
                    [~, valueIdx] = ismember(value, dbFilteredReference.StateCode);
                    if valueIdx
                        id = dbFilteredReference.StateId(valueIdx);
                    end

                case 'location'
                    value = string(app.Location.Value);
                    valueIdx = find(dbFilteredReference.Location == value);
                    if ~isempty(valueIdx)
                        id = unique(dbFilteredReference.DistrictId(valueIdx));
                    end

                otherwise % 'receiver'
                    value = string(app.Receiver.Value);
                    valueIdx = find(cellfun(@(x) any(contains(x, value)), dbFilteredReference.StationNames), 1);
                    if ~isempty(valueIdx)
                        stationDetails = dbFilteredReference.StationDetails{valueIdx};
                        stationDetailsMask = strcmpi([stationDetails.host_name], value) | strcmpi([stationDetails.equipment_name], value);
                        if any(stationDetailsMask)
                            stationDetailsIdx = find(stationDetailsMask, 1);
                            id = stationDetails(stationDetailsIdx).equipment_id;
                        end
                    end
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, dbCacheData, dbReference, filterContext)

            % ## ToDo ##
            % Esse app deve migrado para operar um secondaryApp, mas depende 
            % de evolução em auxApp.winRepoSFI para que ambos compartilhem a 
            % mesma aba de app.mainApp.TabGroup. Controle interno, da própria 
            % aba, para chavear entre duas telas. Outra opção é migrar esse 
            % app para auxApp.winRepoSFI.

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                applyJSCustomization(app)
                initializeAppProperties(app, dbCacheData, dbReference)
                initializeUIComponents(app)
                applyInitialLayout(app, filterContext)

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)

        end

        % Value changed function: Description, FreqStart, FreqStop, 
        % ...and 5 other components
        function onFilterValueChanged(app, event)
           
            if isequal(event.Value, event.PreviousValue) || (isprop(event, 'ValueIndex') && isempty(event.ValueIndex))
                event.Source.Value = event.PreviousValue;
                return
            end

            switch event.Source
                case app.State
                    previousLocationValue = app.Location.Value;
                    previousReceiverValue = app.Receiver.Value;
                    
                    app.Location.Value = '';
                    app.Receiver.Value = '';

                    matchMask = applyFilter(app);
                    dbFilteredReference = app.dbReference(matchMask, :);

                    refreshLocationDropDown(app, dbFilteredReference, previousLocationValue)
                    refreshReceiverDropDown(app, dbFilteredReference, previousReceiverValue)

                    if ~isempty(app.Location.Value) || ~isempty(app.Receiver.Value)
                        applyFilter(app);
                    end

                case app.Location
                    app.Receiver.Value = '';
                    applyFilter(app);

                case app.Receiver
                    app.Location.Value = '';
                    applyFilter(app);

                case {app.FreqStart, app.FreqStop}
                    event.Source.Value = round(event.Source.Value, 3);

                case app.Description
                    app.Description.Value = strtrim(app.Description.Value);
            end

            app.SearchButton.Enable = ~isempty(app.State.Value) || ~isempty(app.Location.Value) || ~isempty(app.Receiver.Value);
            
        end

        % Image clicked function: SearchButton
        function onSearchButtonClicked(app, event)
            
            [currentFilter, warningMsg] = getCurrentFilter(app);
            if ~isempty(warningMsg)
                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                pageSizeTotal = getSpectrumFileDataCount(app.dbHandlerObj, currentFilter);
                currentFilter.page = 1;
                currentFilter.pageSize = max(pageSizeTotal, 1);
        
                resultData = getSpectrumFileData(app.dbHandlerObj, currentFilter);

                if ~istable(resultData) || isempty(resultData)
                    error('auxApp:dockRepoFiles:UnexpectedValue', 'Unexpected value')
                end

                refreshTable(app, 'files', resultData)
                refreshTableFootnote(app, currentFilter)

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Selection changed function: UITable1
        function onTableSelectionValueChanged(app, event)
            
            if ~app.FileDetailsButton.UserData.status
                return
            end

            selectedRows = app.UITable1.Selection;
            
            if ~isempty(selectedRows) && isscalar(selectedRows)
                fileId = app.UITable1.Data.ID(selectedRows);

                app.progressDialog.Visible = 'visible';

                try
                    resultData = getSpectraByFileId(app.dbHandlerObj, fileId);
                    
                    if ~istable(resultData) || isempty(resultData)
                        error('auxApp:dockRepoFiles:UnexpectedValue', 'Unexpected value')
                    end

                    refreshTable(app, 'fileDetails', resultData)
                    
                catch ME
                    ui.Dialog(app.UIFigure, 'error', ME.message);
                    
                    app.UITable1.Selection = [];
                    onTableSelectionValueChanged(app)
                end

                app.progressDialog.Visible = 'hidden';

            else
                set(app.UITable2, 'Data', [], 'Enable', 'off')
                app.UITable2Warning.Visible = 'on';
            end
            
        end

        % Image clicked function: DownloadButton
        function onToolbarDownloadButtonClicked(app, event)
            
            selectedRows = app.UITable1.Selection;
            numSelectedRows = numel(selectedRows);
            
            if isempty(selectedRows)
                ui.Dialog(app.UIFigure, 'warning', 'Selecione ao menos um arquivo para continuar.');
                return
            end

            questionMsg = sprintf('O que deseja fazer com o(s) %d arquivo(s) selecionado(s)?', numSelectedRows);
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Apenas download', 'Visualizar', 'Cancelar'}, 1, 3);
            if userSelection == "Cancelar"
                return
            end

            if userSelection == "Apenas download"
                appName = class.Constants.appName;
                [~, zipFileBase] = appEngine.util.DefaultFileName('', [appName '_RepoSFI'], -1);
                zipFile = ui.Dialog(app.UIFigure, 'uiputfile', '', {'*.zip', [appName ' (*.zip)']}, fullfile(app.mainApp.General.fileFolder.userPath, [zipFileBase '.zip']));
                if isempty(zipFile)
                    return
                end                 
            end

            d = ui.Dialog(app.UIFigure, 'progressdlg', 'Em andamento...', 'Cancelable', 'on');

            zipFileList = {};
            errorMsg = {};

            httpBaseUrl = sprintf('%s://%s:%d%s', app.mainApp.General.context.REPOSFI.protocol, app.mainApp.General.context.REPOSFI.host, app.mainApp.General.context.REPOSFI.httpPort, app.mainApp.General.context.REPOSFI.httpBasePath);

            for ii = 1:numSelectedRows
                if d.CancelRequested
                    break
                end

                d.Message = sprintf('Em andamento o download do arquivo %d de %d.', ii, numSelectedRows);

                originFilePath = char(app.UITable1.Data.("ARQUIVO")(selectedRows(ii)));
                [~, fileName, fileExt] = fileparts(originFilePath);
                fileName = [fileName, fileExt];

                httpFileUrl = sprintf('%s%s', httpBaseUrl, originFilePath);
                destFilePath = fullfile(app.mainApp.General.fileFolder.tempPath, fileName);

                if isfile(destFilePath)
                    zipFileList{end+1} = destFilePath;
                    continue
                end

                try
                    zipFileList{end+1} = websave(destFilePath, httpFileUrl);
                catch ME
                    errorMsg{end+1} = sprintf('%s: %s', fileName, ME.message);
                end
            end

            if ~isempty(errorMsg)
                ui.Dialog(app.UIFigure, 'error', sprintf('Evidenciado <font style="color: red;"><b>ERRO</b></font> na leitura do(s) arquivo(s) indicado(s) a seguir.\n%s', textFormatGUI.cellstr2Bullets(errorMsg)))
            end

            if ~isempty(zipFileList)
                switch userSelection 
                    case 'Apenas download'
                        zip(zipFile, zipFileList)
                        delete(d)

                    otherwise % 'Visualizar'
                        delete(d)
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onImportFilesFromPaths', zipFileList);
                end
            end

        end

        % Image clicked function: FileDetailsButton
        function onToolbarFileDetailsButtonClicked(app, event)
            
            app.FileDetailsButton.UserData.status = ~app.FileDetailsButton.UserData.status;
            
            if app.FileDetailsButton.UserData.status
                app.UITable2.Visible = 'on';
                app.GridLayout.RowHeight(5:8) = {17, 5, '.5x', 10};
                onTableSelectionValueChanged(app)
            else
                app.UITable2.Visible = 'off';
                app.GridLayout.RowHeight(5:8) = {0, 0, 0, 0};
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, Container)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            if isempty(Container)
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.AutoResizeChildren = 'off';
                app.UIFigure.Position = [100 100 1244 660];
                app.UIFigure.Name = 'appAnalise';
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                if ~isempty(Container.Children)
                    delete(Container.Children)
                end

                app.UIFigure  = ancestor(Container, 'figure');
                app.Container = Container;
                if ~isprop(Container, 'RunningAppInstance')
                    addprop(app.Container, 'RunningAppInstance');
                end
                app.Container.RunningAppInstance = app;
                app.isDocked  = true;
            end

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Container);
            app.GridLayout.ColumnWidth = {22, 22, '1x', 22};
            app.GridLayout.RowHeight = {66, 10, '1x', 10, 0, 0, 0, 0, 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create FilterPanel
            app.FilterPanel = uipanel(app.GridLayout);
            app.FilterPanel.Layout.Row = 1;
            app.FilterPanel.Layout.Column = [1 4];

            % Create FilterGrid
            app.FilterGrid = uigridlayout(app.FilterPanel);
            app.FilterGrid.ColumnWidth = {100, 200, 200, 100, 100, 100, 100, '1x', 22};
            app.FilterGrid.RowHeight = {17, 22, 22, 22, 22, 22, 22, 22, '1x', 49};
            app.FilterGrid.RowSpacing = 5;
            app.FilterGrid.BackgroundColor = [1 1 1];

            % Create StateLabel
            app.StateLabel = uilabel(app.FilterGrid);
            app.StateLabel.VerticalAlignment = 'bottom';
            app.StateLabel.FontSize = 11;
            app.StateLabel.Layout.Row = 1;
            app.StateLabel.Layout.Column = 1;
            app.StateLabel.Text = 'UF:';

            % Create State
            app.State = uidropdown(app.FilterGrid);
            app.State.Items = {};
            app.State.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.State.FontSize = 11;
            app.State.FontColor = [1 1 1];
            app.State.BackgroundColor = [0.7216 0.1882 0.1686];
            app.State.Layout.Row = 2;
            app.State.Layout.Column = 1;
            app.State.Value = {};

            % Create LocationLabel
            app.LocationLabel = uilabel(app.FilterGrid);
            app.LocationLabel.VerticalAlignment = 'bottom';
            app.LocationLabel.FontSize = 11;
            app.LocationLabel.Layout.Row = 1;
            app.LocationLabel.Layout.Column = 2;
            app.LocationLabel.Text = 'Localidade:';

            % Create Location
            app.Location = uidropdown(app.FilterGrid);
            app.Location.Items = {};
            app.Location.Editable = 'on';
            app.Location.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Location.FontSize = 11;
            app.Location.BackgroundColor = [1 1 1];
            app.Location.Layout.Row = 2;
            app.Location.Layout.Column = 2;
            app.Location.Value = {};

            % Create ReceiverLabel
            app.ReceiverLabel = uilabel(app.FilterGrid);
            app.ReceiverLabel.VerticalAlignment = 'bottom';
            app.ReceiverLabel.FontSize = 11;
            app.ReceiverLabel.Layout.Row = 1;
            app.ReceiverLabel.Layout.Column = 3;
            app.ReceiverLabel.Text = 'Sensor:';

            % Create Receiver
            app.Receiver = uidropdown(app.FilterGrid);
            app.Receiver.Items = {};
            app.Receiver.Editable = 'on';
            app.Receiver.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Receiver.FontSize = 11;
            app.Receiver.BackgroundColor = [1 1 1];
            app.Receiver.Layout.Row = 2;
            app.Receiver.Layout.Column = 3;
            app.Receiver.Value = {};

            % Create PeriodBeginLabel
            app.PeriodBeginLabel = uilabel(app.FilterGrid);
            app.PeriodBeginLabel.VerticalAlignment = 'bottom';
            app.PeriodBeginLabel.FontSize = 11;
            app.PeriodBeginLabel.Layout.Row = 1;
            app.PeriodBeginLabel.Layout.Column = 4;
            app.PeriodBeginLabel.Text = 'Período inicial:';

            % Create PeriodBegin
            app.PeriodBegin = uidatepicker(app.FilterGrid);
            app.PeriodBegin.DisplayFormat = 'dd/MM/uuuu';
            app.PeriodBegin.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.PeriodBegin.FontSize = 11;
            app.PeriodBegin.Layout.Row = 2;
            app.PeriodBegin.Layout.Column = 4;

            % Create PeriodEndLabel
            app.PeriodEndLabel = uilabel(app.FilterGrid);
            app.PeriodEndLabel.VerticalAlignment = 'bottom';
            app.PeriodEndLabel.FontSize = 11;
            app.PeriodEndLabel.Layout.Row = 1;
            app.PeriodEndLabel.Layout.Column = 5;
            app.PeriodEndLabel.Text = 'Período final:';

            % Create PeriodEnd
            app.PeriodEnd = uidatepicker(app.FilterGrid);
            app.PeriodEnd.DisplayFormat = 'dd/MM/uuuu';
            app.PeriodEnd.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.PeriodEnd.FontSize = 11;
            app.PeriodEnd.Layout.Row = 2;
            app.PeriodEnd.Layout.Column = 5;

            % Create FreqStartLabel
            app.FreqStartLabel = uilabel(app.FilterGrid);
            app.FreqStartLabel.VerticalAlignment = 'bottom';
            app.FreqStartLabel.FontSize = 11;
            app.FreqStartLabel.Layout.Row = 1;
            app.FreqStartLabel.Layout.Column = 6;
            app.FreqStartLabel.Text = 'Freq. inicial (MHz):';

            % Create FreqStart
            app.FreqStart = uieditfield(app.FilterGrid, 'numeric');
            app.FreqStart.Limits = [20 18000];
            app.FreqStart.ValueDisplayFormat = '%.3f';
            app.FreqStart.AllowEmpty = 'on';
            app.FreqStart.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.FreqStart.FontSize = 11;
            app.FreqStart.Layout.Row = 2;
            app.FreqStart.Layout.Column = 6;
            app.FreqStart.Value = [];

            % Create FreqStopLabel
            app.FreqStopLabel = uilabel(app.FilterGrid);
            app.FreqStopLabel.VerticalAlignment = 'bottom';
            app.FreqStopLabel.FontSize = 11;
            app.FreqStopLabel.Layout.Row = 1;
            app.FreqStopLabel.Layout.Column = 7;
            app.FreqStopLabel.Text = 'Freq. final (MHz):';

            % Create FreqStop
            app.FreqStop = uieditfield(app.FilterGrid, 'numeric');
            app.FreqStop.Limits = [20 18000];
            app.FreqStop.ValueDisplayFormat = '%.3f';
            app.FreqStop.AllowEmpty = 'on';
            app.FreqStop.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.FreqStop.FontSize = 11;
            app.FreqStop.Layout.Row = 2;
            app.FreqStop.Layout.Column = 7;
            app.FreqStop.Value = [];

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.FilterGrid);
            app.DescriptionLabel.VerticalAlignment = 'bottom';
            app.DescriptionLabel.FontSize = 11;
            app.DescriptionLabel.Layout.Row = 1;
            app.DescriptionLabel.Layout.Column = 8;
            app.DescriptionLabel.Text = 'Descrição:';

            % Create Description
            app.Description = uieditfield(app.FilterGrid, 'text');
            app.Description.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Description.FontSize = 11;
            app.Description.Layout.Row = 2;
            app.Description.Layout.Column = 8;

            % Create SearchButton
            app.SearchButton = uiimage(app.FilterGrid);
            app.SearchButton.ScaleMethod = 'none';
            app.SearchButton.ImageClickedFcn = createCallbackFcn(app, @onSearchButtonClicked, true);
            app.SearchButton.Layout.Row = 2;
            app.SearchButton.Layout.Column = 9;
            app.SearchButton.ImageSource = 'search-sparkle.svg';

            % Create UITable1
            app.UITable1 = uitable(app.GridLayout);
            app.UITable1.ColumnName = {'REGIÃO'; 'SENSOR'; 'LIMITES (MHz)'; 'QTD. FLUXOS'; 'INÍCIO'; 'FIM'; 'ID'; 'ARQUIVO'; 'TAMANHO'};
            app.UITable1.ColumnWidth = {130, 130, 130, 90, 90, 90, 90, 'auto', 90};
            app.UITable1.RowName = {};
            app.UITable1.ColumnSortable = [true true false false true true false false];
            app.UITable1.SelectionType = 'row';
            app.UITable1.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionValueChanged, true);
            app.UITable1.Layout.Row = 3;
            app.UITable1.Layout.Column = [1 4];
            app.UITable1.FontSize = 11;

            % Create UITable2Icon
            app.UITable2Icon = uiimage(app.GridLayout);
            app.UITable2Icon.ScaleMethod = 'none';
            app.UITable2Icon.Layout.Row = 5;
            app.UITable2Icon.Layout.Column = 1;
            app.UITable2Icon.VerticalAlignment = 'bottom';
            app.UITable2Icon.ImageSource = 'selected-row-16px.png';

            % Create UITable2Label
            app.UITable2Label = uilabel(app.GridLayout);
            app.UITable2Label.VerticalAlignment = 'bottom';
            app.UITable2Label.FontSize = 10;
            app.UITable2Label.Layout.Row = 5;
            app.UITable2Label.Layout.Column = 3;
            app.UITable2Label.Text = 'INFORMAÇÕES ACERCA DO REGISTRO SELECIONADO';

            % Create UITable2
            app.UITable2 = uitable(app.GridLayout);
            app.UITable2.ColumnName = {'FAIXA (MHz)'; 'INÍCIO'; 'FIM'; 'DESCRIÇÃO'};
            app.UITable2.ColumnWidth = {130, 130, 130, 'auto'};
            app.UITable2.RowName = {};
            app.UITable2.ColumnSortable = true;
            app.UITable2.SelectionType = 'row';
            app.UITable2.Enable = 'off';
            app.UITable2.Visible = 'off';
            app.UITable2.Layout.Row = 7;
            app.UITable2.Layout.Column = [1 4];
            app.UITable2.FontSize = 11;

            % Create UITable2Warning
            app.UITable2Warning = uilabel(app.GridLayout);
            app.UITable2Warning.HorizontalAlignment = 'center';
            app.UITable2Warning.FontSize = 22;
            app.UITable2Warning.FontWeight = 'bold';
            app.UITable2Warning.FontColor = [0.502 0.502 0.502];
            app.UITable2Warning.Layout.Row = 7;
            app.UITable2Warning.Layout.Column = [1 4];
            app.UITable2Warning.Interpreter = 'html';
            app.UITable2Warning.Text = {'❗'; '<p style="font-size: 12px;">SELECIONE UM REGISTRO'; 'NA TABELA ACIMA</p>'};

            % Create DownloadButton
            app.DownloadButton = uiimage(app.GridLayout);
            app.DownloadButton.ScaleMethod = 'none';
            app.DownloadButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarDownloadButtonClicked, true);
            app.DownloadButton.Layout.Row = 9;
            app.DownloadButton.Layout.Column = 1;
            app.DownloadButton.ImageSource = 'Import_16.png';

            % Create FileDetailsButton
            app.FileDetailsButton = uiimage(app.GridLayout);
            app.FileDetailsButton.ScaleMethod = 'none';
            app.FileDetailsButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarFileDetailsButtonClicked, true);
            app.FileDetailsButton.Layout.Row = 9;
            app.FileDetailsButton.Layout.Column = 2;
            app.FileDetailsButton.ImageSource = 'split_top_bottom_24.png';

            % Create FilterDescription
            app.FilterDescription = uilabel(app.GridLayout);
            app.FilterDescription.HorizontalAlignment = 'right';
            app.FilterDescription.WordWrap = 'on';
            app.FilterDescription.FontSize = 10;
            app.FilterDescription.Layout.Row = 9;
            app.FilterDescription.Layout.Column = 3;
            app.FilterDescription.Interpreter = 'html';
            app.FilterDescription.Text = '';

            % Create FilterDescriptionIcon
            app.FilterDescriptionIcon = uiimage(app.GridLayout);
            app.FilterDescriptionIcon.ScaleMethod = 'none';
            app.FilterDescriptionIcon.Visible = 'off';
            app.FilterDescriptionIcon.Layout.Row = 9;
            app.FilterDescriptionIcon.Layout.Column = 4;
            app.FilterDescriptionIcon.ImageSource = 'filter.svg';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockRepoFiles_exported(Container, varargin)

            % Create UIFigure and components
            createComponents(app, Container)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            if app.isDocked
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
