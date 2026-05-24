classdef dockRepoFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        FilterDescriptionIcon  matlab.ui.control.Image
        FilterDescription      matlab.ui.control.Label
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
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        dbHandlerObj
        dbCacheData
        dbReference
        dbMatchMask
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        TABLE_RESULTS = table( ...
            'Size', [0, 8], ...
            'VariableTypes', {'string', 'string', 'string', 'cell', 'datetime', 'datetime', 'double', 'string'}, ...
            'VariableNames', {'REGIÃO', 'SENSOR', 'QTD. FLUXOS', 'LIMITES (MHz)', 'INÍCIO', 'FIM', 'TAMANHO', 'ARQUIVO'} ...
        )

        TABLE_FILE_DETAILS = table( ...
            'Size', [0, 4], ...
            'VariableTypes', {'string', 'string', 'string', 'string'}, ...
            'VariableNames', {'FAIXA (MHz)', 'INÍCIO', 'FIM', 'DESCRIÇÃO'} ...
        );
    end

    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyJSCustomization(app)
            appName = class(app);
            elToModify = {
                app.State
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.State.UserData.id, 'selector', 'input', 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')) ...
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
                    resultData.("ARQUIVO") = fullfile(extractAfter(resultData.("NA_PATH"), app.mainApp.General.context.REPOSFI.containerPathPrefixToRemove), resultData.("NA_FILE"));

                    resultData = renamevars(resultData(:, {'LOCALITY_LABELS', 'EQUIPMENT_LABELS', 'LIMITES (MHz)', 'NU_SPECTRA', 'DT_TIME_START', 'DT_TIME_END', 'VL_FILE_SIZE_KB', 'ARQUIVO'}), ...
                        {'LOCALITY_LABELS', 'EQUIPMENT_LABELS', 'NU_SPECTRA', 'DT_TIME_START', 'DT_TIME_END', 'VL_FILE_SIZE_KB'}, ...
                        {'REGIÃO', 'SENSOR', 'QTD. FLUXOS', 'INÍCIO', 'FIM', 'TAMANHO'} ...
                    );

                    app.UITable1.Data = resultData;

                case 'fileDetails'





            end
        end

        %-----------------------------------------------------------------%
        function [currentFilter, warningMsg] = getCurrentFilter(app)
            currentFilter = [];
            warningMsg = '';
            
            issues = {};
            if (isnat(app.PeriodBegin.Value)  && ~isnat(app.PeriodEnd.Value)) || ...
               (~isnat(app.PeriodBegin.Value) &&  isnat(app.PeriodEnd.Value)) || ...
               (~isnat(app.PeriodBegin.Value) && ~isnat(app.PeriodEnd.Value) && app.PeriodEnd.Value < app.PeriodBegin.Value)
                issues{end+1} = 'período de observação';
            end

            if isnan(app.FreqStop.Value - app.FreqStart.Value) || (~isnan(app.FreqStart.Value) && ~isnan(app.FreqStop.Value) && app.FreqStop.Value <= app.FreqStart.Value)
                issues{end+1} = 'faixa de frequência';
            end

            if ~isempty(issues)
                warningMsg = sprintf('Filtragem inválida. Corrija os valores de %s.', textFormatGUI.cellstr2FriendlyListWithQuotes(issues));
                return
            end

            currentFilter = struct( ...
                'stateCode', app.State.Value, ...
                'districtId', getParameterId(app, 'location'), ...
                'siteId', NaN, ...
                'equipmentId', getParameterId(app, 'receiver'), ...
                'startDate', app.PeriodBegin.Value, ...
                'endDate', app.PeriodEnd.Value, ...
                'freqStart', NaN, ...
                'freqEnd', NaN, ...
                'description', strtrim(app.Description.Value) ...
                );

            if ~isempty(app.FreqStart.Value)
                currentFilter.freqStart = round(app.FreqStart.Value, 3);
            end

            if ~isempty(app.FreqStop.Value)
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


        %-----------------------------------------------------------------%
        % Formatação da tabela para exibição em tela
        %-----------------------------------------------------------------%
        function refreshTableFootnote(app)
            app.FilterDescription.Text = sprintf('%d resultado(s)', height(app.UITable1.Data));
        end

        %-----------------------------------------------------------------%
        function toggleSelectedFileDetail(app)
            % Abre ou recolhe o detalhe do arquivo atualmente apontado pela seleção.
            %
            % Esse helper concentra a ação do botão de detalhe: valida a linha ativa,
            % resolve o identificador do arquivo e decide entre fechar o painel já
            % aberto ou consultar novamente os espectros do item selecionado.
            rowIndex = getSelectedDetailRow(app);
            rawRows = app.UITable1.UserData;
        
            % Interrompe o fluxo quando não existir uma linha válida na tabela
            % principal para servir de origem à abertura do detalhe.
            if isnan(rowIndex) || ~istable(rawRows) || isempty(rawRows) || (rowIndex < 1) || (rowIndex > height(rawRows))
                ui.Dialog(app.UIFigure, 'warning', 'Selecione ao menos um arquivo para visualizar os detalhes.');
                return
            end
        
            % Traduz o identificador bruto do arquivo para o formato numérico usado
            % pela consulta de espectros no repositório.
            fileId = str2double(formatIdValue(app, rawRows.ID_FILE(rowIndex)));
            if isnan(fileId)
                ui.Dialog(app.UIFigure, 'warning', 'Não foi possível identificar o arquivo selecionado.');
                return
            end
        
            % Se o painel já estiver mostrando exatamente esse mesmo arquivo, a ação
            % passa a ser de recolhimento para funcionar como toggle visual.
            if app.expandedFileId == fileId
                resetDetailState(app, false)
                return
            end
        
            % Fora desse caso, segue para a carga do detalhe do arquivo escolhido.
            openFileDetail(app, rowIndex, fileId)
        end
        
        %-----------------------------------------------------------------%
        function openFileDetail(app, rowIndex, fileId)
            % Consulta os espectros do arquivo selecionado e publica o detalhe no dock.
            %
            % Esse helper materializa a expansão do painel inferior: reaproveita os
            % filtros correntes, busca os espectros associados ao arquivo em foco e
            % sincroniza tabela, resumo e estado visual do detalhe aberto.
            [currentFilter, warningMsg] = getCurrentFilter(app);
            if ~isempty(warningMsg)
                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                return
            end

            rawRows = app.UITable1.UserData;

            app.UITable2.Data(:, :) = [];
            app.expandedFileId = NaN;
        
            try
                % Executa a consulta detalhada já respeitando o mesmo recorte atual
                % aplicado à busca principal do dock.
                detailRows = app.dbHandlerObj.getSpectraByFileId(fileId, currentFilter);
                
                if ~istable(detailRows) || isempty(detailRows)
                    error('auxApp:dockRepoFiles:UnexpectedValue', 'Unexpected value')
                end

                detailRows = sortrows(detailRows, 'NU_FREQ_START');
                
                detailRows.ID_SPECTRUM = string(detailRows.ID_SPECTRUM);
                detailRows.NA_DESCRIPTION(detailRows.NA_DESCRIPTION == "" | ismissing(detailRows.NA_DESCRIPTION)) = "-";
                detailRows.LOCALIDADE = detailRows.LOCALITY_LABEL + " (" + detailRows.COUNTY_NAME + "/" + detailRows.STATE_CODE + ")";
                detailRows.FAIXA = string(detailRows.NU_FREQ_START) + " - " + string(detailRows.NU_FREQ_END);                
                detailRows.INICIO = string(detailRows.DT_TIME_START);
                detailRows.INICIO(ismissing(detailRows.INICIO)) = "-";
                detailRows.FIM = string(detailRows.DT_TIME_END);
                detailRows.FIM(ismissing(detailRows.FIM)) = "-";

                app.UITable2.Data(1:height(detailRows), :) = detailRows(:, {'ID_SPECTRUM', 'NA_DESCRIPTION', 'LOCALIDADE', 'FAIXA', 'INICIO', 'FIM'});
                app.expandedFileId = fileId;
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end
        
        %-----------------------------------------------------------------%
        function restoreSearchPageState(app)
            % Esse helper recoloca a interface no ponto neutro entre uma busca e outra:
            % limpa o resultado anterior, zera os acumuladores visuais e recolhe o
            % detalhe para evitar que a UI mantenha seleções ou dados obsoletos.
            app.UITable1.Data(:,:) = [];
        
            % Zera o total agregado para manter o rodapé coerente com a ausência
            % momentânea de resultados após a mudança de filtro.
            app.totalResults = 0;
            refreshTableFootnote(app)
        
            % Limpa também o estado do painel inferior e a seleção associada ao
            % resultado anterior, que deixa de ser válido após o recálculo.
            resetDetailState(app)
        end

        %-----------------------------------------------------------------%
        function output = buildRepositoryFilePath(app, row)
            % Monta o caminho completo do arquivo no repositório a partir da pasta e do nome.
            %
            % Esse helper é usado no fluxo de download e visualização para compor o
            % srcPath que alimenta copyfile, combinando o prefixo fixo do servidor
            % com o diretório relativo armazenado no banco e o nome do arquivo.

            % Extrai a subpasta relativa registrada no banco antes de tentar
            % compor o caminho completo no servidor de repositório.
            folder = char(displayText(app, row.NA_PATH, ''));

            % Sem um caminho de pasta válido não é possível localizar o arquivo no
            % sistema de arquivos, então devolve vazio como sinal de metadado ausente.
            if isempty(folder)
                output = '';
                return
            end

            % O RF.Fusion armazena o caminho com o prefixo do ponto de montagem
            % do container Linux (/mnt/reposfi). Esse segmento deve ser removido
            % antes de compor o caminho UNC real no servidor de repositório.
            folder = regexprep(folder, '^[/\\]mnt[/\\]reposfi', '', 'ignorecase');

            % Com a pasta disponível, monta o caminho completo combinando o prefixo
            % fixo do servidor com a subpasta e o nome de arquivo normalizado.
            fileName = buildRepositoryFileName(app, row);
            output = fullfile(class.Constants.repoSFIRoot, folder, char(fileName));
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

                case app.Receiver
                    app.Location.Value = '';

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

            try
                pageSizeTotal = getSpectrumFileDataCount(app.dbHandlerObj, currentFilter);
                currentFilter.page = 1;
                currentFilter.pageSize = max(pageSizeTotal, 1);
        
                resultData = getSpectrumFileData(app.dbHandlerObj, currentFilter);
                refreshTable(app, 'files', resultData)

            catch ME
                app.UITable1.Data(:,:) = [];
                ui.Dialog(app.UIFigure, 'error', sprintf('Erro ao consultar arquivos do repositório:\n%s', ME.message));
            end

            refreshTableFootnote(app)

        end

        % Cell selection callback: UITable1
        function onTableSelectionValueChanged(app, event)
            
            rowIndices = [];
            selectedFileRows = table();
            rawRows = app.UITable1.UserData;

            if ~isempty(event.Indices)
                rowIndices = unique(event.Indices(:, 1), 'stable')';
                app.selectedDetailRow = event.Indices(end, 1);

                if istable(rawRows) && ~isempty(rawRows)
                    validMask = (rowIndices >= 1) & (rowIndices <= height(rawRows));
                    rowIndices = rowIndices(validMask);

                    if ~isempty(rowIndices)
                        selectedFileRows = rawRows(rowIndices, :);
                    end
                end
            else
                app.selectedDetailRow = NaN;
            end
        
            app.selectedRows = rowIndices;
            app.selectedRowData = selectedFileRows;

            if isscalar(app.selectedRows)
                toggleSelectedFileDetail(app)
            else
                app.UITable2.Data(:, :) = [];
                app.expandedFileId = NaN;
            end
            app.SelectedRowsLabel.Text = sprintf('%d arquivo(s) selecionado(s)', numel(app.selectedRows));
            
        end

        % Image clicked function: DownloadButton
        function onToolbarButtonClicked(app, event)
            
            selectedFileRows = app.selectedRowData;
            selectedCount = height(selectedFileRows);

            if selectedCount == 0
                ui.Dialog(app.UIFigure, 'warning', 'Selecione ao menos um arquivo para continuar.');
                return
            end

            questionMsg = sprintf('O que você quer fazer com os %d arquivo(s) selecionado(s)?', selectedCount);
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Download', 'Visualizar', 'Cancelar'}, 1, 3);
            if userSelection == "Cancelar"
                return
            end

            if userSelection == "Download"
                destFolder = app.mainApp.General.fileFolder.userPath;

                d = ui.Dialog(app.UIFigure, 'progressdlg', sprintf('Copiando %d arquivo(s) para:\n%s', selectedCount, destFolder));
                
                successCount = 0;
                errorList    = {};

                for ii = 1:selectedCount
                    fileRow  = selectedFileRows(ii, :);
                    srcPath  = buildRepositoryFilePath(app, fileRow);
                    fileName = buildRepositoryFileName(app, fileRow);

                    if isempty(srcPath)
                        errorList{end+1} = sprintf('Arquivo %d: metadados de caminho ausentes no banco de dados.', ii);
                        continue
                    end

                    destPath = fullfile(destFolder, char(fileName));
                    [status, msg] = copyfile(char(srcPath), destPath);

                    if status
                        successCount = successCount + 1;
                    else
                        errorList{end+1} = sprintf('%s: %s', fileName, msg);
                    end
                end

                if isempty(errorList)
                    ui.Dialog(app.UIFigure, 'success', sprintf('%d arquivo(s) copiado(s) com sucesso para:\n%s', successCount, destFolder));
                elseif successCount > 0
                    ui.Dialog(app.UIFigure, 'warning', sprintf('%d de %d arquivo(s) copiado(s). Erros:\n%s', successCount, selectedCount, strjoin(errorList, newline)));
                else
                    ui.Dialog(app.UIFigure, 'error', sprintf('Nenhum arquivo copiado. Erros:\n%s', strjoin(errorList, newline)));
                end

            else  % "Visualizar"
                tempFolder = app.mainApp.General.fileFolder.tempPath;

                d = ui.Dialog(app.UIFigure, 'progressdlg', sprintf('Preparando %d arquivo(s) para visualização...', selectedCount));

                copiedPaths = {};
                errorList   = {};

                for ii = 1:selectedCount
                    fileRow  = selectedFileRows(ii, :);
                    srcPath  = buildRepositoryFilePath(app, fileRow);
                    fileName = buildRepositoryFileName(app, fileRow);

                    if isempty(srcPath)
                        errorList{end+1} = sprintf('Arquivo %d: metadados de caminho ausentes no banco de dados.', ii);
                        continue
                    end

                    destPath = fullfile(tempFolder, char(fileName));
                    [status, msg] = copyfile(char(srcPath), destPath);

                    if status
                        copiedPaths{end+1} = destPath;
                    else
                        errorList{end+1} = sprintf('%s: %s', fileName, msg);
                    end
                end

                if ~isempty(errorList)
                    ui.Dialog(app.UIFigure, 'warning', sprintf('Alguns arquivos não puderam ser preparados:\n%s', strjoin(errorList, newline)));
                end

                if ~isempty(copiedPaths)
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onImportFilesFromPaths', copiedPaths)
                end
            end

            if exist('d', 'var')
                delete(d)
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
            app.GridLayout.ColumnWidth = {22, '1x', 22};
            app.GridLayout.RowHeight = {66, 10, '1x', 10, 17, 5, '0.5x', 10, 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create FilterPanel
            app.FilterPanel = uipanel(app.GridLayout);
            app.FilterPanel.Layout.Row = 1;
            app.FilterPanel.Layout.Column = [1 3];

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
            app.UITable1.ColumnName = {'REGIÃO'; 'SENSOR'; 'LIMITES (MHz)'; 'QTD. FLUXOS'; 'INÍCIO'; 'FIM'; 'TAMANHO'; 'ARQUIVO'};
            app.UITable1.ColumnWidth = {130, 130, 130, 90, 90, 90, 90, 'auto'};
            app.UITable1.RowName = {};
            app.UITable1.ColumnSortable = [true true false false true true false false];
            app.UITable1.SelectionType = 'row';
            app.UITable1.CellSelectionCallback = createCallbackFcn(app, @onTableSelectionValueChanged, true);
            app.UITable1.Layout.Row = 3;
            app.UITable1.Layout.Column = [1 3];
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
            app.UITable2Label.Layout.Column = 2;
            app.UITable2Label.Text = 'INFORMAÇÕES ACERCA DO REGISTRO SELECIONADO';

            % Create UITable2
            app.UITable2 = uitable(app.GridLayout);
            app.UITable2.ColumnName = {'FAIXA (MHz)'; 'INÍCIO'; 'FIM'; 'DESCRIÇÃO'};
            app.UITable2.ColumnWidth = {130, 130, 130, 'auto'};
            app.UITable2.RowName = {};
            app.UITable2.SelectionType = 'row';
            app.UITable2.Multiselect = 'off';
            app.UITable2.Enable = 'off';
            app.UITable2.Layout.Row = 7;
            app.UITable2.Layout.Column = [1 3];
            app.UITable2.FontSize = 11;

            % Create UITable2Warning
            app.UITable2Warning = uilabel(app.GridLayout);
            app.UITable2Warning.HorizontalAlignment = 'center';
            app.UITable2Warning.FontSize = 22;
            app.UITable2Warning.FontWeight = 'bold';
            app.UITable2Warning.FontColor = [0.502 0.502 0.502];
            app.UITable2Warning.Layout.Row = 7;
            app.UITable2Warning.Layout.Column = [1 3];
            app.UITable2Warning.Interpreter = 'html';
            app.UITable2Warning.Text = {'❗'; '<p style="font-size: 12px;">SELECIONE UM REGISTRO'; 'NA TABELA ACIMA</p>'};

            % Create DownloadButton
            app.DownloadButton = uiimage(app.GridLayout);
            app.DownloadButton.ScaleMethod = 'none';
            app.DownloadButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.DownloadButton.Enable = 'off';
            app.DownloadButton.Layout.Row = 9;
            app.DownloadButton.Layout.Column = 1;
            app.DownloadButton.ImageSource = 'Import_16.png';

            % Create FilterDescription
            app.FilterDescription = uilabel(app.GridLayout);
            app.FilterDescription.HorizontalAlignment = 'right';
            app.FilterDescription.WordWrap = 'on';
            app.FilterDescription.FontSize = 11;
            app.FilterDescription.Layout.Row = 9;
            app.FilterDescription.Layout.Column = 2;
            app.FilterDescription.Text = '';

            % Create FilterDescriptionIcon
            app.FilterDescriptionIcon = uiimage(app.GridLayout);
            app.FilterDescriptionIcon.ScaleMethod = 'none';
            app.FilterDescriptionIcon.Layout.Row = 9;
            app.FilterDescriptionIcon.Layout.Column = 3;
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
