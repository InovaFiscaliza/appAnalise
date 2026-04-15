classdef winSignalAnalysis_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        DockModule                    matlab.ui.container.GridLayout
        dockModule_Undock             matlab.ui.control.Image
        dockModule_Close              matlab.ui.control.Image
        Toolbar                       matlab.ui.container.GridLayout
        tool_ControlPanelVisibility   matlab.ui.control.Image
        tool_Separator                matlab.ui.control.Image
        tool_ShowGlobalExceptionList  matlab.ui.control.Image
        tool_ExportJSONFile           matlab.ui.control.Image
        tool_EmissionReportListLimit  matlab.ui.control.CheckBox
        SelectedEmissionGrid          matlab.ui.container.GridLayout
        SelectedEmissionPanel         matlab.ui.container.Panel
        SelectedEmissionPanelGrid     matlab.ui.container.GridLayout
        ClassificationRefresh         matlab.ui.control.Image
        LOG                           matlab.ui.control.Label
        LOGLabel                      matlab.ui.control.Label
        AdditionalDescription         matlab.ui.control.EditField
        AdditionalDescriptionLabel    matlab.ui.control.Label
        TXLocationPanel               matlab.ui.container.Panel
        TXLocationGrid                matlab.ui.container.GridLayout
        TXAntennaHeight               matlab.ui.control.NumericEditField
        TXAntennaHeightLabel          matlab.ui.control.Label
        TXLongitude                   matlab.ui.control.NumericEditField
        TXLongitudeLabel              matlab.ui.control.Label
        TXLatitude                    matlab.ui.control.NumericEditField
        TXLatitudeLabel               matlab.ui.control.Label
        TXLocationEditionGrid         matlab.ui.container.GridLayout
        TXLocationEditCancel          matlab.ui.control.Image
        TXLocationEditConfirm         matlab.ui.control.Image
        TXLocationEditMode            matlab.ui.control.Image
        TXLocationPanelLabel          matlab.ui.control.Label
        RiskLevel                     matlab.ui.control.DropDown
        RiskLevelLabel                matlab.ui.control.Label
        Compliance                    matlab.ui.control.DropDown
        ComplianceLabel               matlab.ui.control.Label
        EmissionType                  matlab.ui.control.DropDown
        EmissionTypeLabel             matlab.ui.control.Label
        StationID                     matlab.ui.control.EditField
        StationIDLabel                matlab.ui.control.Label
        Regulatory                    matlab.ui.control.DropDown
        RegulatoryLabel               matlab.ui.control.Label
        EmissionTitle                 matlab.ui.control.Label
        SelectedEmissionLabel         matlab.ui.control.Label
        SelectedEmissionIcon          matlab.ui.control.Image
        Document                      matlab.ui.container.GridLayout
        AxesToolbar                   matlab.ui.container.GridLayout
        AxesPanButton                 matlab.ui.control.Image
        AxesRestoreViewButton         matlab.ui.control.Image
        RFLinkWarning                 matlab.ui.control.Image
        AxesContainer                 matlab.ui.container.Panel
        UITable                       matlab.ui.control.Table
        UITableLabel                  matlab.ui.control.Label
        ContextMenu                   matlab.ui.container.ContextMenu
        contextmenu_TruncateItem      matlab.ui.container.Menu
        contextmenu_NonTruncateEmission  matlab.ui.container.Menu
        contextmenu_TruncateEmission  matlab.ui.container.Menu
        contextmenu_DeleteEmission    matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'SIGNALANALYSIS'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
        popupContainer

        SubTabGroup = struct('Children', -1, 'UserData', [])

        % Handles dos eixos cartesianos utilizados por este módulo. No futuro,
        % simplificar para uma lista de handles, permitindo a criação dinâmica
        % de quantos eixos forem necessários, como ocorre na geração do relatório.
        UIAxes1
        UIAxes2

        % Informações relacionadas ao specData selecionado, com atalhos para 
        % os principais metadados e a definição dos limites dos eixos x, y e 
        % z dos eixos cartesianos. No futuro, remover essa propriedade.
        bandObj

        % Armazena limites padrão dos eixos cartesianos computados em método 
        % de model.Band (app.bandObj).
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
        )
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        tempBandObj
        elevationObj = RF.Elevation
        emissionsTable
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    otherwise
                        error('auxApp:winSignalAnalysis:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
                end

            catch ME
                struct2table(ME.stack)
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, varargin)
            try
                switch class(callingApp)
                    case {'winAppAnalise', 'winAppAnalise_exported'}
                        onToolbarCheckBoxValueChanged(app)

                    otherwise
                        error('auxApp:winRFDataHub:UnexpectedCall', 'Unexpected call "%s"', operationType)
                end
            
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;

            appName = class(app);
            switch tabIndex
                case 1
                    elToModify = { 
                        app.AxesToolbar;
                        app.ClassificationRefresh;
                        app.TXLocationEditMode;
                        app.TXLocationEditConfirm;
                        app.TXLocationEditCancel;
                        app.tool_ExportJSONFile;
                        app.tool_ShowGlobalExceptionList;
                        app.tool_ControlPanelVisibility;
                        app.RFLinkWarning;
                        app.dockModule_Undock;
                        app.dockModule_Close;
                        app.EmissionTitle
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id,                  'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.ClassificationRefresh.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna à classificação automática')), ...
                            struct('appName', appName, 'dataTag', app.TXLocationEditMode.UserData.id,           'tooltip', struct('defaultPosition', 'top',    'textContent', 'Edita parâmetros do provável emissor')), ...
                            struct('appName', appName, 'dataTag', app.TXLocationEditConfirm.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Confirma edição, recriando perfil de terreno')), ...
                            struct('appName', appName, 'dataTag', app.TXLocationEditCancel.UserData.id,         'tooltip', struct('defaultPosition', 'top',    'textContent', 'Cancela edição')), ...
                            struct('appName', appName, 'dataTag', app.tool_ExportJSONFile.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Exporta arquivo JSON com informações das emissões')), ...
                            struct('appName', appName, 'dataTag', app.tool_ShowGlobalExceptionList.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Mostra lista global de exceções')), ...
                            struct('appName', appName, 'dataTag', app.tool_ControlPanelVisibility.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à direita')), ...
                            struct('appName', appName, 'dataTag', app.RFLinkWarning.UserData.id,                'tooltip', struct('defaultPosition', 'top',    'textContent', 'Evidenciada obstrução total da 1ª Zona de Fresnel')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,            'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,             'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.EmissionTitle, appName, struct('class', {{'textview--borderless', 'textview--no-scroll'}}));
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.LOG, appName, struct('class', {{'textview--wordbreak'}}));
                    catch
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.bandObj = model.Band('appAnalise:SIGNALANALYSIS', app.mainApp);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.AxesPanButton.UserData.status = false;
            app.TXLocationEditMode.UserData.status = false;
            app.UITable.RowName = 'numbered';

            initializeAxes(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            pause(.100)

            if app.tool_EmissionReportListLimit.Value
                flowIdxs = find(arrayfun(@(x) x.UserData.ReportInclude, app.mainApp.specData));
            else
                flowIdxs = 1:numel(app.mainApp.specData);
            end

            selectedRow = app.UITable.Selection;
            updateTable(app, flowIdxs, selectedRow)

            focus(app.UITable)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 1, 3, "Padding", "compact", "TileSpacing", "compact");
            
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'YAxisLocation', "right", 'Clipping', 'off'});
            app.UIAxes2.Layout.Tile = 2;
            app.UIAxes2.Layout.TileSpan = [1 2];
            app.UIAxes2.XAxis.TickLabelFormat = '%.1f';

            app.UIAxes1 = plot.axes.Creation(hParent, 'Cartesian', {'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'Box', 'on', 'TickDir', 'none'});
            
            xlabel(app.UIAxes1, 'Frequência (MHz)')
            ylabel(app.UIAxes1, 'Nível (dB)')
            xlabel(app.UIAxes2, 'Distância (km)')
            ylabel(app.UIAxes2, 'Elevação (m)')

            plot.axes.Interactivity.DefaultCreation(app.UIAxes1, [dataTipInteraction, regionZoomInteraction])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes2, [dataTipInteraction, regionZoomInteraction])
        end

        %-----------------------------------------------------------------%
        function updateTable(app, flowIdxs, selectedRow)
            app.emissionsTable = util.createEmissionsTable(app.mainApp.specData, flowIdxs, 'SIGNALANALYSIS: GUI');
    
            if isempty(app.emissionsTable)
                selectedRow = [];
            else
                if isempty(selectedRow)
                    selectedRow = 1;
                elseif selectedRow > height(app.emissionsTable)
                    selectedRow = height(app.emissionsTable);
                end
            end
    
            if app.progressDialog.Visible == "visible"
                progressDialogAlreadyVisible = true;
            else
                progressDialogAlreadyVisible = false;
                app.progressDialog.Visible = 'visible';
            end
    
            columnNames = { ...
                'Frequency', ...
                'Truncated', ...
                'BandWidthkHz', ...
                'Level_FreqCenter_Min', ...
                'Level_FreqCenter_Mean', ...
                'Level_FreqCenter_Max', ...
                'FCO_FreqCenter_Infinite', ...
                'FCO_FreqCenter_Finite_Min', ...
                'FCO_FreqCenter_Finite_Mean', ...
                'FCO_FreqCenter_Finite_Max',  ...
                'RFDataHubDescription' ...
            };

            app.UITable.Data = app.emissionsTable(:, columnNames);
            updateTableStyle(app)

            pause(.100)
            app.UITable.Selection = selectedRow;
            updateSelectedEmissionFormAndPlot(app)
    
            if ~progressDialogAlreadyVisible
                app.progressDialog.Visible = 'hidden';
            end
        end
        
        %-----------------------------------------------------------------%
        function updateCoordinatesPanelStyle(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    app.TXLocationEditMode.ImageSource = 'Edit_32Filled.png';
                    app.TXLocationEditMode.UserData.status = true;

                    app.TXLocationEditionGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.TXLocationEditConfirm.Enable = 1;
                    app.TXLocationEditCancel.Enable  = 1;
                    set(findobj(app.TXLocationGrid.Children, 'Type', 'uinumericeditfield'), 'Editable', 1)

                case 'off'
                    app.TXLocationEditMode.ImageSource = 'Edit_32.png';
                    app.TXLocationEditMode.UserData.status = false;

                    app.TXLocationEditionGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.TXLocationEditConfirm.Enable = 0;
                    app.TXLocationEditCancel.Enable  = 0;
                    set(findobj(app.TXLocationGrid.Children, 'Type', 'uinumericeditfield'), 'Editable', 0)

                    updateCoordinatesPanel(app)
            end
        end

        %-----------------------------------------------------------------%
        function updateRegulatoryStyle(app)
            switch app.Regulatory.Value
                case {'Licenciada', 'Licenciada UTE'}
                    set(app.EmissionType, 'Value', 'Fundamental', 'Enable', 0)
                    app.EmissionTypeLabel.Enable   = 0;    
                    set(app.Compliance, 'Items', {'Não', 'Sim'}, 'Value', 'Não')

                otherwise % {'Não licenciada', 'Não passível de licenciamento'}
                    app.EmissionType.Enable = 1;
                    app.EmissionTypeLabel.Enable = 1;
                    app.StationID.Value = '-1';
    
                    switch app.Regulatory.Value
                        case 'Não licenciada'
                            app.Compliance.Items = {'Sim'};

                        case 'Não passível de licenciamento'
                            set(app.Compliance, 'Items', {'Não', 'Sim'}, 'Value', 'Não')
                    end
            end
        end

        %-----------------------------------------------------------------%
        function updateStationIdStyle(app)
            if app.StationID.Value == "-1"
                set(app.StationID, 'BackgroundColor', [1,0,0], 'FontColor', [1,1,1])
            else
                set(app.StationID, 'BackgroundColor', [1,1,1], 'FontColor', [0,0,0])
            end
        end

        %-----------------------------------------------------------------%
        function updateEmissionTypeStyle(app)
            % Migrado do ordinário "set" p/ "addStyle" porque o "set" não
            % renderiza a cor da fonte até que o mouse passe sobre o
            % componente, mesmo inserindo drawnow ou pause(.100).
            % set(app.EmissionType, 'BackgroundColor', [1,1,1], 'FontColor', [0,0,0])

            removeStyle(app.EmissionType)
            if contains(app.EmissionType.Value, 'Pendente', 'IgnoreCase', true)
                backgroundColor = [1,0,0];
                fontColor       = [1,1,1];
            else
                backgroundColor = [1,1,1];
                fontColor       = [0,0,0];
            end
            addStyle(app.EmissionType, uistyle('BackgroundColor', backgroundColor, 'FontColor', fontColor))
        end

        %-----------------------------------------------------------------%
        function updateComplianceStyle(app)
            if strcmp(app.Compliance.Value, 'Não')
                set(app.RiskLevel,      'Enable', 0, 'Items', {'-'})
                set(app.RiskLevelLabel, 'Enable', 0)
            else
                set(app.RiskLevel,      'Enable', 1, 'Items', {'Baixo', 'Médio', 'Alto'})
                set(app.RiskLevelLabel, 'Enable', 1)
            end
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            removeStyle(app.UITable)
                
            % Destaca registros que tiveram a sua classificação editada...
            idxEditedPeaks = [];            
            for ii = 1:height(app.emissionsTable)
                if ~isequal(app.emissionsTable.Classification(ii).AutoSuggested, ...
                            app.emissionsTable.Classification(ii).UserModified)
                    idxEditedPeaks = [idxEditedPeaks; ii];
                end
            end
            
            if ~isempty(idxEditedPeaks)
                listOfCells1 = [idxEditedPeaks, ones(numel(idxEditedPeaks), 1)];
                addStyle(app.UITable, uistyle('Icon', 'edit.svg',  'IconAlignment', 'leftmargin'), 'cell', listOfCells1) 
            end

            % Destaca registros que apresentam valores inválidos de estações...
            % (usei o método dois por robustez na obtenção dos índices)
            % idxInvalidStationNumber = find(arrayfun(@(x) x.UserModified.Station, app.emissionsTable.Classification) == -1);
            idxInvalidStationNumber = find(cellfun(@(x) isequal(x, -1), arrayfun(@(x) x.UserModified.Station, app.emissionsTable.Classification, 'UniformOutput', false)));
            if ~isempty(idxInvalidStationNumber)
                listOfCells2 = [idxInvalidStationNumber, repmat(2, numel(idxInvalidStationNumber), 1)];
                addStyle(app.UITable, uistyle('Icon', 'Circle_18Red.png',  'IconAlignment', 'leftmargin'), 'cell', listOfCells2) 
            end
        end
        
        %-----------------------------------------------------------------%
        function updateSelectedEmissionFormAndPlot(app)
            if ~isempty(app.emissionsTable)
                [flowIdx, emissionIdx] = getEmissionIndexes(app);
                specData = app.mainApp.specData(flowIdx);
                selectedRow = app.UITable.Selection;
    
                [htmlContent1, ...
                 htmlContent2, ...
                 emissionTag, ...
                 userDescription, ...
                 stationInfo] = util.HtmlTextGenerator.Emission(specData, emissionIdx);
    
                ui.TextView.update(app.EmissionTitle, htmlContent1);
                ui.TextView.update(app.LOG, htmlContent2);
                set(app.AdditionalDescription, 'Value', userDescription, 'UserData', userDescription) 
    
                % TABLE CONTEXT MENU
                if specData.UserData.Emissions.IsTruncated(emissionIdx)
                    app.contextmenu_NonTruncateEmission.Enable  = 1;
                    app.contextmenu_TruncateEmission.Enable = 0;
                else
                    app.contextmenu_NonTruncateEmission.Enable  = 0;
                    app.contextmenu_TruncateEmission.Enable = 1;
                end
    
                % CONTROL PANEL
                app.ClassificationRefresh.Visible = ~isequal(specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested, ...
                                                     specData.UserData.Emissions.Classification(emissionIdx).UserModified);
                
                app.Regulatory.Value = specData.UserData.Emissions.Classification(emissionIdx).UserModified.Regulatory;
                updateRegulatoryStyle(app)

                app.StationID.Value = num2str(specData.UserData.Emissions.Classification(emissionIdx).UserModified.Station);
                updateStationIdStyle(app)

                app.EmissionType.Value = specData.UserData.Emissions.Classification(emissionIdx).UserModified.EmissionType;
                updateEmissionTypeStyle(app)

                app.Compliance.Value = specData.UserData.Emissions.Classification(emissionIdx).UserModified.Irregular;
                updateComplianceStyle(app)

                app.RiskLevel.Value = specData.UserData.Emissions.Classification(emissionIdx).UserModified.RiskLevel;
    
                % PLOT CONFIG PANEL
                app.TXLocationEditConfirm.UserData = stationInfo;
                updateCoordinatesPanel(app)
    
                % PLOT
                createSpectrumPlot(app, specData, emissionIdx, emissionTag)
                createRFLinkPlot(app, selectedRow, flowIdx)
                
                app.SelectedEmissionPanelGrid.Visible = 1;
                app.tool_ExportJSONFile.Enable = 1;

            else
                ui.TextView.update(app.EmissionTitle, '');
                
                cla(app.UIAxes1)
                cla(app.UIAxes2)
                ylabel(app.UIAxes1, 'Nível')
                set(app.UIAxes1, 'XLim', [0, 1], 'YLim', [0, 1])
                ysecondarylabel(app.UIAxes1, [newline, newline])
                
                app.ClassificationRefresh.Visible = 0;
                app.SelectedEmissionPanelGrid.Visible = 0;
                app.tool_ExportJSONFile.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function updateCoordinatesPanel(app)
            stationInfo = app.TXLocationEditConfirm.UserData;

            app.TXLatitude.Value  = round(double(stationInfo.Latitude),  6);
            app.TXLongitude.Value = round(double(stationInfo.Longitude), 6);

            if stationInfo.AntennaHeight > 0
                app.TXAntennaHeight.Value = stationInfo.AntennaHeight;
            else
                app.TXAntennaHeight.Value = app.mainApp.General.context.RFDATAHUB.tx.defaultHeight;
            end
        end

        %-----------------------------------------------------------------%
        function createSpectrumPlot(app, specData, emissionIdx, emissionTag)
            % Atualiza bandObj...
            updateSpectrumInfo(app.bandObj, specData, emissionIdx);
            app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', app.bandObj.XLimits, 'yLim', app.bandObj.YLimitsLevel, 'cLim', 'auto');
            
            % Limpa eixo, atualizando labels e limites...
            cla(app.UIAxes1)
            ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))
            set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
            ysecondarylabel(app.UIAxes1, sprintf('%s\n%.3f - %.3f MHz @ %s\n', specData.Receiver, specData.MetaData.FreqStart/1e6, specData.MetaData.FreqStop/1e6, emissionTag))

            % Plot "minHold", "average" e "maxHold"
            for plotTag = ["minHold", "average", "maxHold"]
                eval(sprintf('hLine = plot.draw2D.OrdinaryLine(app.UIAxes1, "%s", app.bandObj, []);', plotTag))
                plot.datatip.Template(hLine, "Frequency+Level", app.bandObj.LevelUnit)
            end

            % Plot "ROI"
            plot.draw2D.rectangularROI(app.UIAxes1, app.bandObj, specData.UserData.Emissions, emissionIdx, 'emissionROI', {'EdgeAlpha', 0, 'InteractionsAllowed', 'none'})
        end

        %-----------------------------------------------------------------%
        function createRFLinkPlot(app, selectedRow, idxThread)
            try
                specData = app.mainApp.specData(idxThread);

                % OBJETOS TX e RX
                [txObj, rxObj] = getRFLinkObjects(app, specData, selectedRow);
    
                % ELEVAÇÃO DO LINK TX-RX
                [wayPoints3D, msgWarning] = Get(app.elevationObj, txObj, rxObj, app.mainApp.General.elevation.pointCount, app.mainApp.General.elevation.forceRefresh, app.mainApp.General.elevation.provider);
                if ~isempty(msgWarning)
                    ui.Dialog(app.UIFigure, 'warning', msgWarning);
                end
    
                % PLOT: RFLink
                plot.RFLink(app.UIAxes2, txObj, rxObj, wayPoints3D, 'dark')
                app.UIAxes2.PickableParts = "visible";
                app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', app.UIAxes2.XLim, 'yLim', app.UIAxes2.YLim, 'cLim', 'auto');

                if isempty(findobj(app.UIAxes2.Children, 'Tag', 'FirstObstruction'))
                    app.RFLinkWarning.Visible = 0;
                else
                    app.RFLinkWarning.Visible = 1;
                end
                
            catch ME
                cla(app.UIAxes2)
                app.UIAxes2.PickableParts = "none";
                msgWarning = text(app.UIAxes2, mean(app.UIAxes2.XLim), mean(app.UIAxes2.YLim), { ...
                    'PERFIL DE TERRENO ENTRE RECEPTOR';  ...
                    'E PROVÁVEL EMISSOR É LIMITADO ÀS';  ...
                    'ESTAÇÕES INCLUÍDAS NO RFDATAHUB';   ...
                    '(EXCETO VISUALIZAÇÃO TEMPORÁRIA)' ...
                }, 'BackgroundColor', [.8,.8,.8], 'HorizontalAlignment', 'center', 'FontSize', 10);
                msgWarning.Units = 'normalized';
                app.RFLinkWarning.Visible = 0;
            end
            app.TXLocationEditConfirm.Enable = 0;
        end

        %-----------------------------------------------------------------%
        function [txSite, rxSite] = getRFLinkObjects(app, specData, selectedRow)
            % txSite e rxSite estão como struct, mas basta mudar para "txsite" e 
            % "rxsite" que eles poderão ser usados em predições, uma vez que os 
            % campos da estrutura são idênticos às propriedades dos objetos.
            if (app.TXLatitude.Value == -1) && (app.TXLongitude.Value == -1)
                error('winSignalAnalysis:RFLinkObjects:UnexpectedEmptyIndex', 'Unexpected empty index')
            end

            % TX
            txSite = struct( ...
                'Name', 'TX', ...
                'TransmitterFrequency', double(app.UITable.Data.Truncated(selectedRow) * 1e+6), ...
                'Latitude', app.TXLatitude.Value, ...
                'Longitude', app.TXLongitude.Value, ...
                'AntennaHeight', app.TXAntennaHeight.Value ...
            );

            % RX
            rxSite = struct( ...
                'Name', 'RX', ...
                'Latitude', specData.GPS.Latitude,  ...
                'Longitude', specData.GPS.Longitude, ...
                'AntennaHeight', calculateAntennaHeight(specData, 1, 10) ...
            );
        end

        %-----------------------------------------------------------------%
        function fetchEmissionUpdate(app, triggeredComponent, varargin)
            [flowIdx, emissionIdx] = getEmissionIndexes(app);
            specData = app.mainApp.specData(flowIdx);

            switch triggeredComponent
                case app.ClassificationRefresh
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified = specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested;

                case app.StationID
                    stationInfo = varargin{1};

                    switch stationInfo.Service 
                        case -1
                            newRegulatory = 'Não licenciada';
                            newCompliance = 'Sim';
                            newRiskLevel  = 'Baixo';
                        otherwise
                            newRegulatory = 'Licenciada';
                            newCompliance = 'Não';
                            newRiskLevel  = '-';
                    end

                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Service       = stationInfo.Service;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Station       = stationInfo.Station;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Latitude      = stationInfo.Latitude;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Longitude     = stationInfo.Longitude;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.AntennaHeight = stationInfo.AntennaHeight;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Description   = stationInfo.Description;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Details       = stationInfo.Details;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Distance      = stationInfo.Distance;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Regulatory    = newRegulatory;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.EmissionType  = 'Fundamental';                        
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Irregular     = newCompliance;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.RiskLevel     = newRiskLevel;

                case app.AdditionalDescription
                    userDescription = app.AdditionalDescription.Value;
                    if strcmp(userDescription, specData.UserData.Emissions.Description(emissionIdx))
                        return
                    end

                    specData.UserData.Emissions.Description(emissionIdx) = userDescription;
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'PeakDescriptionChanged')
                    
                case app.TXLocationEditConfirm % Latitude | Longitude | AntennaHeight
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Latitude      = app.TXLatitude.Value;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Longitude     = app.TXLongitude.Value;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.AntennaHeight = app.TXAntennaHeight.Value;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Distance      = deg2km(distance(specData.GPS.Latitude, specData.GPS.Longitude, ...
                                                                                                                                        app.TXLatitude.Value, app.TXLongitude.Value));

                otherwise
                    oldRegulatory = specData.UserData.Emissions.Classification(emissionIdx).UserModified.Regulatory;
                    newRegulatory = app.Regulatory.Value;

                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Regulatory    = app.Regulatory.Value;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.EmissionType  = app.EmissionType.Value;                        
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.Irregular     = app.Compliance.Value;
                    specData.UserData.Emissions.Classification(emissionIdx).UserModified.RiskLevel     = app.RiskLevel.Value;

                    if newRegulatory ~= "Licenciada"
                        specData.UserData.Emissions.Classification(emissionIdx).UserModified.Service     = int16(-1);
                        specData.UserData.Emissions.Classification(emissionIdx).UserModified.Station     = int32(-1);
                        specData.UserData.Emissions.Classification(emissionIdx).UserModified.Description = '[EXC]';
                        specData.UserData.Emissions.Classification(emissionIdx).UserModified.Details     = '';

                        if oldRegulatory == "Licenciada"
                            specData.UserData.Emissions.Classification(emissionIdx).UserModified.Latitude      = -1;
                            specData.UserData.Emissions.Classification(emissionIdx).UserModified.Longitude     = -1;
                            specData.UserData.Emissions.Classification(emissionIdx).UserModified.AntennaHeight = 0;
                            specData.UserData.Emissions.Classification(emissionIdx).UserModified.Distance      = -1;
                        end
                    end
            end

            onToolbarCheckBoxValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function [flowIdx, emissionIdx] = getEmissionIndexes(app)
            selectedRow = app.UITable.Selection;
            flowIdx = app.emissionsTable.idxThread(selectedRow);
            emissionIdx = app.emissionsTable.idxEmission(selectedRow);
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            try
                appEngine.boot(app, app.Role, mainApp)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', app.Context)
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function onDockModuleGroupButtonClicked(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;
                    
                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];
                    
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Selection changed function: UITable
        function onUITableSelectionChanged(app, event)

            if isempty(event.Selection)
                app.UITable.Selection = event.PreviousSelection;
            else
                updateSelectedEmissionFormAndPlot(app)
            end
            
        end

        % Menu selected function: contextmenu_DeleteEmission, 
        % ...and 2 other components
        function onUITableContextMenuClicked(app, event)
            
            if isempty(app.UITable.Selection)
                return
            end

            [flowIdx, emissionIdx] = getEmissionIndexes(app);
            specData = app.mainApp.specData(flowIdx);

            switch event.Source
                case app.contextmenu_DeleteEmission
                    update(specData, 'UserData:Emissions', 'Delete', emissionIdx)
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onEmissionDeleted')

                otherwise % app.contextmenu_TruncateEmission | app.contextmenu_NonTruncateEmission
                    isTruncated = ~specData.UserData.Emissions.IsTruncated(emissionIdx);
                    update(specData, 'UserData:Emissions', 'Edit', 'IsTruncated', emissionIdx, isTruncated)
            end

            applyInitialLayout(app)

        end

        % Value changed function: Regulatory
        function onRegulatoryValueChanged(app, event)
            
            switch event.Value
                case 'Licenciada'
                    app.Regulatory.Value = event.PreviousValue;
    
                    msgWarning = [ ...
                        'A alteração da situação de uma emissão para "Licenciada" deve ser feita diretamente no ' ...
                        'campo "Estação / ID", inserindo o número da estação ou a ID do registro no RFDataHub. ' ...
                        'O seu formato é numérico, com a ressalva de que quando inserido a ID do registro ' ...
                        'deve ser colocado o caractere "#" à frente do número. Por exemplo: 123456 ou #123456.' ...
                    ];
                    ui.Dialog(app.UIFigure, 'warning', msgWarning);
                    return

                otherwise % case {'Licenciada UTE', 'Não licenciada', 'Não passível de licenciamento'}
                    userDescription = strtrim(app.AdditionalDescription.Value);
                    if isempty(userDescription)
                        app.Regulatory.Value = event.PreviousValue;
    
                        msgWarning = [ ...
                            'O campo "Informações adicionais" não pode ficar vazio para registros ' ...
                            'relacionados a uma estação "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento".<br><br>' ...
                            'Edite o campo "Informações adicionais" antes de alterar a "Situação".' ...
                        ];
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                        return
                    end
            end

            updateRegulatoryStyle(app)
            onOthersParametersValueChanged(app, struct('Source', app.Compliance))
            
        end

        % Value changed function: StationID
        function onStationIdValueChanged(app, event)
            
            global RFDataHub

            try
                app.StationID.Value = strtrim(app.StationID.Value);
                if isempty(regexp(app.StationID.Value, '^\#?\d+$', 'once'))
                    error([ ...
                        'Esse campo deve ser preenchido com o número da estação ou a ID do registro no RFDataHub. ' ...
                        'O seu formato é numérico, com a ressalva de que quando inserido a ID do registro ' ...
                        'deve ser colocado o caractere "#" à frente do número. Por exemplo: 123456 ou #123456.' ...
                    ])
                end
                
                [flowIdx, emissionIdx] = getEmissionIndexes(app);
                specData = app.mainApp.specData(flowIdx);

                receiverLatitude  = specData.GPS.Latitude;
                receiverLongitude = specData.GPS.Longitude;
                stationInfo       = model.RFDataHub.query(RFDataHub, app.StationID.Value, receiverLatitude, receiverLongitude);

                % Caso a estação não conste em RFDataHub, o método query
                % chamado anteriormente retornará um erro. Mas caso
                % encontre, confirma-se com o usuário a edição.
                dataStruct(1) = struct( ...
                    'group', 'INDICAÇÃO AUTOMÁTICA', ...
                    'value', struct( ...
                        'Regulatory', specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Regulatory, ...
                        'Frequency', sprintf('%.3f MHz', specData.UserData.Emissions.Frequency(emissionIdx)) ...
                    ) ...
                );
                
                if specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Regulatory == "Licenciada"
                    dataStruct(1).value.Description = specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Description;
                    dataStruct(1).value.Distance    = sprintf('%s km', specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Distance);
                end

                switch stationInfo.Service
                    case -1
                        emissionRegulatory = '<font style="color: #c94756;">Não Licenciada</font>';
                    otherwise
                        emissionRegulatory = 'Licenciada';
                end
                dataStruct(2) = struct( ...
                    'group', 'MANUAL', ...
                    'value', struct( ...
                        'Regulatory',  emissionRegulatory, ...
                        'Frequency', sprintf('%s MHz', stationInfo.Frequency), ...
                        'Description', stationInfo.Description,                  ...
                        'Distance', sprintf('%.1f km', stationInfo.Distance) ...
                    ) ...
                );

                msgQuestion   = sprintf('%s<br><font style="font-size: 12px;">Confirma edição?<font>', textFormatGUI.struct2PrettyPrintList(dataStruct, "print -1", '', 'popup'));
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                switch userSelection
                    case 'Sim'
                        fetchEmissionUpdate(app, app.StationID, stationInfo)

                    case 'Não'
                        app.StationID.Value = num2str(specData.UserData.Emissions.Classification(emissionIdx).UserModified.Station);
                end

            catch ME
                app.StationID.Value = num2str(specData.UserData.Emissions.Classification(emissionIdx).UserModified.Station);
                ui.Dialog(app.UIFigure, 'warning', getReport(ME));
            end
            
        end

        % Value changed function: EmissionType
        function onEmissionTypeValueChanged(app, event)
            
            regulatoryValue = app.Regulatory.Value;
            userDescription = strtrim(app.AdditionalDescription.Value);

            if ~strcmp(regulatoryValue, 'Licenciada') && isempty(userDescription)
                app.EmissionType.Value = event.PreviousValue;

                msgWarning = [ ...
                    'O campo "Informações adicionais" não pode ficar vazio para registros ' ...
                    'relacionados a uma estação "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento".<br><br>' ...
                    'Edite o campo "Informações adicionais" antes de alterar o "Tipo de emissão".' ...
                ];
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                return
            end

            onOthersParametersValueChanged(app, struct('Source', app.EmissionType))
            
        end

        % Callback function: AdditionalDescription, ClassificationRefresh, 
        % ...and 2 other components
        function onOthersParametersValueChanged(app, event)
            
            switch event.Source
                case app.Compliance
                    updateComplianceStyle(app)

                case app.EmissionType
                    updateEmissionTypeStyle(app)

                case app.AdditionalDescription
                    userDescription = strtrim(app.AdditionalDescription.Value);
                    if isempty(userDescription) && ~strcmp(app.Regulatory.Value, 'Licenciada')
                        app.AdditionalDescription.Value = event.PreviousValue;
    
                        msgWarning = [ ...
                            'O campo "Informações adicionais" não pode ficar vazio para registros ' ...
                            'relacionados a uma estação "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento".' ...
                        ];
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                        return
                    end

                    app.AdditionalDescription.Value = userDescription;
            end

            fetchEmissionUpdate(app, event.Source)

        end

        % Callback function: TXLatitude, TXLocationEditCancel, 
        % ...and 3 other components
        function onCoordinatesPanelButtonClicked(app, event)
            
            switch event.Source
                case app.TXLocationEditMode
                    app.TXLocationEditMode.UserData.status = ~app.TXLocationEditMode.UserData.status;
        
                    if app.TXLocationEditMode.UserData.status
                        updateCoordinatesPanelStyle(app, 'on')
                        focus(app.TXLatitude)        
                    else
                        updateCoordinatesPanelStyle(app, 'off')
                    end

                case app.TXLocationEditConfirm
                    fetchEmissionUpdate(app, event.Source)
                    updateCoordinatesPanelStyle(app, 'off')

                case app.TXLocationEditCancel
                    updateCoordinatesPanelStyle(app, 'off')

                case app.TXLatitude
                    focus(app.TXLongitude)

                case app.TXLongitude
                    focus(app.TXAntennaHeight)
            end

        end

        % Image clicked function: AxesPanButton, AxesRestoreViewButton
        function onAxesToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.AxesRestoreViewButton
                    plot.axes.Interactivity.CustomRestoreViewFcn(app.UIAxes1, app.UIAxes2, app)
                
                case app.AxesPanButton
                    app.AxesPanButton.UserData.status = ~app.AxesPanButton.UserData.status;
                    if app.AxesPanButton.UserData.status
                        app.AxesPanButton.ImageSource = 'pan-filled-32px.png';
                    else
                        app.AxesPanButton.ImageSource = 'pan-32px.png';
                    end

                    plot.axes.Interactivity.CustomPanFcn(struct('Value', app.AxesPanButton.UserData.status), app.UIAxes1, app.UIAxes2);

                case app.TXLocationEditMode
                    app.TXLocationEditMode.UserData.status = ~app.TXLocationEditMode.UserData.status;
        
                    if app.TXLocationEditMode.UserData.status
                        updateCoordinatesPanelStyle(app, 'on')
                        focus(app.TXLatitude)        
                    else
                        updateCoordinatesPanelStyle(app, 'off')
                    end
            end

        end

        % Value changed function: tool_EmissionReportListLimit
        function onToolbarCheckBoxValueChanged(app, event)
            
            applyInitialLayout(app)
            
        end

        % Image clicked function: tool_ControlPanelVisibility, 
        % ...and 2 other components
        function onToolbarButtonClicked(app, event)

            switch event.Source
                %---------------------------------------------------------%
                case app.tool_ShowGlobalExceptionList
                    exceptionGlobalList = app.mainApp.channelObj.Exception;

                    if isempty(exceptionGlobalList)
                        msgWarning  = 'Lista global de exceções, registrada no arquivo "ChannelLib.json", está vazia.';
                        iconWarning = 'warning';
                    else
                        globalEmissiontList = {};
                        for ii = 1:height(exceptionGlobalList)
                            globalEmissiontList{end+1} = sprintf('&emsp;•&thinsp;%s', sprintf('<b>%.3f MHz</b>: "%s"', exceptionGlobalList.FreqCenter(ii), exceptionGlobalList.Description{ii}));
                        end

                        msgWarning  = sprintf('%s\n%s', 'Lista global de exceções:', strjoin(globalEmissiontList, '\n'));
                        iconWarning = 'none';
                    end

                    ui.Dialog(app.UIFigure, iconWarning, msgWarning);

                %---------------------------------------------------------%
                case app.tool_ExportJSONFile
                    if app.tool_EmissionReportListLimit.Value
                        idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.mainApp.specData));
                    else
                        idxThreads = 1:numel(app.mainApp.specData);
                    end

                    emissionSummaryTable   = util.createEmissionsTable(app.mainApp.specData, idxThreads, 'SIGNALANALYSIS: JSONFile');
                    emissionFiscalizaTable = reportLibConnection.table.fiscalizaJsonFile(app.mainApp.specData, idxThreads, emissionSummaryTable);
    
                    nameFormatMap   = {'*.json', 'appAnalise (*.json)'};
                    defaultFilename = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'preReport');
                    JSONFullPath    = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultFilename);

                    if isempty(JSONFullPath)
                        return
                    end

                    app.progressDialog.Visible = 'visible';
                    
                    try
                        writematrix(emissionFiscalizaTable, JSONFullPath, "FileType", "text", "QuoteStrings", "none", "Encoding", "UTF-8")
                    catch ME
                        ui.Dialog(app.UIFigure, 'error', ME.message);
                    end

                    app.progressDialog.Visible = 'hidden';

                %---------------------------------------------------------%
                case app.tool_ControlPanelVisibility
                    if app.SelectedEmissionGrid.Visible
                        app.SelectedEmissionGrid.Visible = 0;
                        app.Document.Layout.Column = [2, numel(app.GridLayout.ColumnWidth)-2];
                        app.tool_ControlPanelVisibility.ImageSource = 'layout-sidebar-right-off.svg';
                    else
                        app.SelectedEmissionGrid.Visible = 1;
                        app.Document.Layout.Column = 2;
                        app.tool_ControlPanelVisibility.ImageSource = 'layout-sidebar-right.svg';
                    end
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
            app.GridLayout.ColumnWidth = {10, '1x', 10, 272, 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {5, 50, '1x', '1x', 18, 3};
            app.Document.RowHeight = {53, '1x', 14, 24, 216};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = 2;
            app.Document.BackgroundColor = [1 1 1];

            % Create UITableLabel
            app.UITableLabel = uilabel(app.Document);
            app.UITableLabel.VerticalAlignment = 'top';
            app.UITableLabel.WordWrap = 'on';
            app.UITableLabel.FontSize = 14;
            app.UITableLabel.Layout.Row = 1;
            app.UITableLabel.Layout.Column = [1 6];
            app.UITableLabel.Interpreter = 'html';
            app.UITableLabel.Text = {'Exibindo emissões relacionadas aos fluxos espectrais'; '<p style="color: #808080; font-size:10px; text-align: justify; margin-right: 2px;"><b>FREQUÊNCIA (MHz)</b> exibe ícone de edição sempre que a classificação da emissão é alterada; e'; '<b>FREQUÊNCIA CANAL (MHz)</b> exibe ícone vermelho quando estação for igual a -1.</p>'};

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.BackgroundColor = [1 1 1;0.96078431372549 0.96078431372549 0.96078431372549];
            app.UITable.ColumnName = {'FREQUÊNCIA|(MHz)'; 'FREQUÊNCIA|CANAL (MHz)'; 'LARGURA|(kHz)'; 'NÍVEL|MÍNIMO (dB)'; 'NÍVEL|MÉDIO (dB)'; 'NÍVEL|MÁXIMO (dB)'; 'OCUPAÇÃO|TOTAL (%)'; 'OCUPAÇÃO|MÍNIMA (%)'; 'OCUPAÇÃO|MÉDIA (%)'; 'OCUPAÇÃO|MÁXIMA (%)'; 'PROVÁVEL EMISSOR|(Entidade+Fistel+Serviço+Estação+Localidade)'};
            app.UITable.ColumnWidth = {95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 'auto'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onUITableSelectionChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.Layout.Row = 2;
            app.UITable.Layout.Column = [1 6];
            app.UITable.FontSize = 10.5;

            % Create AxesContainer
            app.AxesContainer = uipanel(app.Document);
            app.AxesContainer.AutoResizeChildren = 'off';
            app.AxesContainer.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.AxesContainer.BorderType = 'none';
            app.AxesContainer.BackgroundColor = [0 0 0];
            app.AxesContainer.Layout.Row = [4 5];
            app.AxesContainer.Layout.Column = [1 6];

            % Create RFLinkWarning
            app.RFLinkWarning = uiimage(app.Document);
            app.RFLinkWarning.Visible = 'off';
            app.RFLinkWarning.Tooltip = {''};
            app.RFLinkWarning.Layout.Row = 4;
            app.RFLinkWarning.Layout.Column = 5;
            app.RFLinkWarning.ImageSource = 'warning.svg';

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {'1x', 22, 22, '1x'};
            app.AxesToolbar.RowHeight = {'1x'};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [0 2 0 1];
            app.AxesToolbar.Layout.Row = 4;
            app.AxesToolbar.Layout.Column = 2;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create AxesRestoreViewButton
            app.AxesRestoreViewButton = uiimage(app.AxesToolbar);
            app.AxesRestoreViewButton.ScaleMethod = 'none';
            app.AxesRestoreViewButton.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.AxesRestoreViewButton.Tooltip = {''};
            app.AxesRestoreViewButton.Layout.Row = 1;
            app.AxesRestoreViewButton.Layout.Column = 2;
            app.AxesRestoreViewButton.ImageSource = 'Home_18.png';

            % Create AxesPanButton
            app.AxesPanButton = uiimage(app.AxesToolbar);
            app.AxesPanButton.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.AxesPanButton.Tooltip = {''};
            app.AxesPanButton.Layout.Row = 1;
            app.AxesPanButton.Layout.Column = 3;
            app.AxesPanButton.ImageSource = 'pan-32px.png';

            % Create SelectedEmissionGrid
            app.SelectedEmissionGrid = uigridlayout(app.GridLayout);
            app.SelectedEmissionGrid.ColumnWidth = {18, '1x'};
            app.SelectedEmissionGrid.RowHeight = {48, '1x', 22, 253};
            app.SelectedEmissionGrid.ColumnSpacing = 5;
            app.SelectedEmissionGrid.RowSpacing = 5;
            app.SelectedEmissionGrid.Padding = [0 0 0 0];
            app.SelectedEmissionGrid.Layout.Row = [3 4];
            app.SelectedEmissionGrid.Layout.Column = [4 5];
            app.SelectedEmissionGrid.BackgroundColor = [1 1 1];

            % Create SelectedEmissionIcon
            app.SelectedEmissionIcon = uiimage(app.SelectedEmissionGrid);
            app.SelectedEmissionIcon.ScaleMethod = 'none';
            app.SelectedEmissionIcon.Layout.Row = 1;
            app.SelectedEmissionIcon.Layout.Column = 1;
            app.SelectedEmissionIcon.VerticalAlignment = 'bottom';
            app.SelectedEmissionIcon.ImageSource = 'selected-row-16px.png';

            % Create SelectedEmissionLabel
            app.SelectedEmissionLabel = uilabel(app.SelectedEmissionGrid);
            app.SelectedEmissionLabel.VerticalAlignment = 'bottom';
            app.SelectedEmissionLabel.FontSize = 10;
            app.SelectedEmissionLabel.Layout.Row = 1;
            app.SelectedEmissionLabel.Layout.Column = 2;
            app.SelectedEmissionLabel.Text = 'EMISSÃO SELECIONADA';

            % Create SelectedEmissionPanel
            app.SelectedEmissionPanel = uipanel(app.SelectedEmissionGrid);
            app.SelectedEmissionPanel.AutoResizeChildren = 'off';
            app.SelectedEmissionPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SelectedEmissionPanel.BackgroundColor = [1 1 1];
            app.SelectedEmissionPanel.Layout.Row = [2 4];
            app.SelectedEmissionPanel.Layout.Column = [1 2];

            % Create SelectedEmissionPanelGrid
            app.SelectedEmissionPanelGrid = uigridlayout(app.SelectedEmissionPanel);
            app.SelectedEmissionPanelGrid.ColumnWidth = {'1x', '1x', 62, 18};
            app.SelectedEmissionPanelGrid.RowHeight = {108, 15, 22, 17, 22, 17, 22, 19, 61, 17, 22, 22, '1x'};
            app.SelectedEmissionPanelGrid.RowSpacing = 5;
            app.SelectedEmissionPanelGrid.BackgroundColor = [1 1 1];

            % Create EmissionTitle
            app.EmissionTitle = uilabel(app.SelectedEmissionPanelGrid);
            app.EmissionTitle.VerticalAlignment = 'top';
            app.EmissionTitle.FontSize = 11;
            app.EmissionTitle.Layout.Row = 1;
            app.EmissionTitle.Layout.Column = [1 4];
            app.EmissionTitle.Interpreter = 'html';
            app.EmissionTitle.Text = '';

            % Create RegulatoryLabel
            app.RegulatoryLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.RegulatoryLabel.VerticalAlignment = 'bottom';
            app.RegulatoryLabel.FontSize = 11;
            app.RegulatoryLabel.Layout.Row = 2;
            app.RegulatoryLabel.Layout.Column = 1;
            app.RegulatoryLabel.Text = 'Situação:';

            % Create Regulatory
            app.Regulatory = uidropdown(app.SelectedEmissionPanelGrid);
            app.Regulatory.Items = {'Licenciada', 'Licenciada UTE', 'Não licenciada', 'Não passível de licenciamento'};
            app.Regulatory.ValueChangedFcn = createCallbackFcn(app, @onRegulatoryValueChanged, true);
            app.Regulatory.FontSize = 11;
            app.Regulatory.BackgroundColor = [1 1 1];
            app.Regulatory.Layout.Row = 3;
            app.Regulatory.Layout.Column = [1 2];
            app.Regulatory.Value = 'Licenciada';

            % Create StationIDLabel
            app.StationIDLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.StationIDLabel.VerticalAlignment = 'bottom';
            app.StationIDLabel.FontSize = 11;
            app.StationIDLabel.Layout.Row = 2;
            app.StationIDLabel.Layout.Column = [3 4];
            app.StationIDLabel.Text = 'Estação / Id:';

            % Create StationID
            app.StationID = uieditfield(app.SelectedEmissionPanelGrid, 'text');
            app.StationID.ValueChangedFcn = createCallbackFcn(app, @onStationIdValueChanged, true);
            app.StationID.HorizontalAlignment = 'right';
            app.StationID.FontSize = 11;
            app.StationID.Layout.Row = 3;
            app.StationID.Layout.Column = [3 4];

            % Create EmissionTypeLabel
            app.EmissionTypeLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.EmissionTypeLabel.VerticalAlignment = 'bottom';
            app.EmissionTypeLabel.FontSize = 11;
            app.EmissionTypeLabel.Layout.Row = 4;
            app.EmissionTypeLabel.Layout.Column = [1 2];
            app.EmissionTypeLabel.Text = 'Tipo de emissão:';

            % Create EmissionType
            app.EmissionType = uidropdown(app.SelectedEmissionPanelGrid);
            app.EmissionType.Items = {'Fundamental', 'Harmônico de fundamental', 'Produto de intermodulação', 'Espúrio', 'Não identificado', 'Não se manifestou', 'Pendente identificação'};
            app.EmissionType.ValueChangedFcn = createCallbackFcn(app, @onEmissionTypeValueChanged, true);
            app.EmissionType.FontSize = 11;
            app.EmissionType.BackgroundColor = [1 1 1];
            app.EmissionType.Layout.Row = 5;
            app.EmissionType.Layout.Column = [1 4];
            app.EmissionType.Value = 'Pendente identificação';

            % Create ComplianceLabel
            app.ComplianceLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.ComplianceLabel.VerticalAlignment = 'bottom';
            app.ComplianceLabel.FontSize = 11;
            app.ComplianceLabel.Layout.Row = 6;
            app.ComplianceLabel.Layout.Column = [1 2];
            app.ComplianceLabel.Text = 'Indício de irregularidade?';

            % Create Compliance
            app.Compliance = uidropdown(app.SelectedEmissionPanelGrid);
            app.Compliance.Items = {'Não', 'Sim'};
            app.Compliance.ValueChangedFcn = createCallbackFcn(app, @onOthersParametersValueChanged, true);
            app.Compliance.FontSize = 11;
            app.Compliance.BackgroundColor = [1 1 1];
            app.Compliance.Layout.Row = 7;
            app.Compliance.Layout.Column = [1 2];
            app.Compliance.Value = 'Não';

            % Create RiskLevelLabel
            app.RiskLevelLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.RiskLevelLabel.VerticalAlignment = 'bottom';
            app.RiskLevelLabel.FontSize = 11;
            app.RiskLevelLabel.Layout.Row = 6;
            app.RiskLevelLabel.Layout.Column = [3 4];
            app.RiskLevelLabel.Text = 'Potencial lesivo:';

            % Create RiskLevel
            app.RiskLevel = uidropdown(app.SelectedEmissionPanelGrid);
            app.RiskLevel.Items = {'-', 'Baixo', 'Médio', 'Alto'};
            app.RiskLevel.ValueChangedFcn = createCallbackFcn(app, @onOthersParametersValueChanged, true);
            app.RiskLevel.FontSize = 11;
            app.RiskLevel.BackgroundColor = [1 1 1];
            app.RiskLevel.Layout.Row = 7;
            app.RiskLevel.Layout.Column = [3 4];
            app.RiskLevel.Value = '-';

            % Create TXLocationPanelLabel
            app.TXLocationPanelLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.TXLocationPanelLabel.VerticalAlignment = 'bottom';
            app.TXLocationPanelLabel.FontSize = 11;
            app.TXLocationPanelLabel.Layout.Row = 8;
            app.TXLocationPanelLabel.Layout.Column = [1 3];
            app.TXLocationPanelLabel.Text = 'Características de instalação:';

            % Create TXLocationEditionGrid
            app.TXLocationEditionGrid = uigridlayout(app.SelectedEmissionPanelGrid);
            app.TXLocationEditionGrid.ColumnWidth = {'1x', 18, 0, 0};
            app.TXLocationEditionGrid.RowHeight = {'1x'};
            app.TXLocationEditionGrid.ColumnSpacing = 5;
            app.TXLocationEditionGrid.Padding = [0 0 0 0];
            app.TXLocationEditionGrid.Layout.Row = 8;
            app.TXLocationEditionGrid.Layout.Column = [3 4];
            app.TXLocationEditionGrid.BackgroundColor = [1 1 1];

            % Create TXLocationEditMode
            app.TXLocationEditMode = uiimage(app.TXLocationEditionGrid);
            app.TXLocationEditMode.ImageClickedFcn = createCallbackFcn(app, @onCoordinatesPanelButtonClicked, true);
            app.TXLocationEditMode.Tooltip = {''};
            app.TXLocationEditMode.Layout.Row = 1;
            app.TXLocationEditMode.Layout.Column = 2;
            app.TXLocationEditMode.VerticalAlignment = 'bottom';
            app.TXLocationEditMode.ImageSource = 'Edit_32.png';

            % Create TXLocationEditConfirm
            app.TXLocationEditConfirm = uiimage(app.TXLocationEditionGrid);
            app.TXLocationEditConfirm.ImageClickedFcn = createCallbackFcn(app, @onCoordinatesPanelButtonClicked, true);
            app.TXLocationEditConfirm.Enable = 'off';
            app.TXLocationEditConfirm.Tooltip = {''};
            app.TXLocationEditConfirm.Layout.Row = 1;
            app.TXLocationEditConfirm.Layout.Column = 3;
            app.TXLocationEditConfirm.VerticalAlignment = 'bottom';
            app.TXLocationEditConfirm.ImageSource = 'Ok_32Green.png';

            % Create TXLocationEditCancel
            app.TXLocationEditCancel = uiimage(app.TXLocationEditionGrid);
            app.TXLocationEditCancel.ImageClickedFcn = createCallbackFcn(app, @onCoordinatesPanelButtonClicked, true);
            app.TXLocationEditCancel.Enable = 'off';
            app.TXLocationEditCancel.Tooltip = {''};
            app.TXLocationEditCancel.Layout.Row = 1;
            app.TXLocationEditCancel.Layout.Column = 4;
            app.TXLocationEditCancel.VerticalAlignment = 'bottom';
            app.TXLocationEditCancel.ImageSource = 'Delete_32Red.png';

            % Create TXLocationPanel
            app.TXLocationPanel = uipanel(app.SelectedEmissionPanelGrid);
            app.TXLocationPanel.AutoResizeChildren = 'off';
            app.TXLocationPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.TXLocationPanel.BackgroundColor = [1 1 1];
            app.TXLocationPanel.Layout.Row = 9;
            app.TXLocationPanel.Layout.Column = [1 4];
            app.TXLocationPanel.FontSize = 10;

            % Create TXLocationGrid
            app.TXLocationGrid = uigridlayout(app.TXLocationPanel);
            app.TXLocationGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.TXLocationGrid.RowHeight = {17, 22};
            app.TXLocationGrid.RowSpacing = 5;
            app.TXLocationGrid.Padding = [10 10 10 5];
            app.TXLocationGrid.BackgroundColor = [1 1 1];

            % Create TXLatitudeLabel
            app.TXLatitudeLabel = uilabel(app.TXLocationGrid);
            app.TXLatitudeLabel.VerticalAlignment = 'bottom';
            app.TXLatitudeLabel.FontSize = 11;
            app.TXLatitudeLabel.Layout.Row = 1;
            app.TXLatitudeLabel.Layout.Column = 1;
            app.TXLatitudeLabel.Text = 'Latitude:';

            % Create TXLatitude
            app.TXLatitude = uieditfield(app.TXLocationGrid, 'numeric');
            app.TXLatitude.Limits = [-90 90];
            app.TXLatitude.ValueDisplayFormat = '%.6f';
            app.TXLatitude.ValueChangedFcn = createCallbackFcn(app, @onCoordinatesPanelButtonClicked, true);
            app.TXLatitude.Editable = 'off';
            app.TXLatitude.FontSize = 11;
            app.TXLatitude.Layout.Row = 2;
            app.TXLatitude.Layout.Column = 1;
            app.TXLatitude.Value = -1;

            % Create TXLongitudeLabel
            app.TXLongitudeLabel = uilabel(app.TXLocationGrid);
            app.TXLongitudeLabel.VerticalAlignment = 'bottom';
            app.TXLongitudeLabel.FontSize = 11;
            app.TXLongitudeLabel.Layout.Row = 1;
            app.TXLongitudeLabel.Layout.Column = 2;
            app.TXLongitudeLabel.Text = 'Longitude:';

            % Create TXLongitude
            app.TXLongitude = uieditfield(app.TXLocationGrid, 'numeric');
            app.TXLongitude.Limits = [-180 180];
            app.TXLongitude.ValueDisplayFormat = '%.6f';
            app.TXLongitude.ValueChangedFcn = createCallbackFcn(app, @onCoordinatesPanelButtonClicked, true);
            app.TXLongitude.Editable = 'off';
            app.TXLongitude.FontSize = 11;
            app.TXLongitude.Layout.Row = 2;
            app.TXLongitude.Layout.Column = 2;
            app.TXLongitude.Value = -1;

            % Create TXAntennaHeightLabel
            app.TXAntennaHeightLabel = uilabel(app.TXLocationGrid);
            app.TXAntennaHeightLabel.VerticalAlignment = 'bottom';
            app.TXAntennaHeightLabel.FontSize = 11;
            app.TXAntennaHeightLabel.Layout.Row = 1;
            app.TXAntennaHeightLabel.Layout.Column = 3;
            app.TXAntennaHeightLabel.Text = 'Altura (m):';

            % Create TXAntennaHeight
            app.TXAntennaHeight = uieditfield(app.TXLocationGrid, 'numeric');
            app.TXAntennaHeight.Limits = [0 Inf];
            app.TXAntennaHeight.ValueDisplayFormat = '%.1f';
            app.TXAntennaHeight.Editable = 'off';
            app.TXAntennaHeight.FontSize = 11;
            app.TXAntennaHeight.Layout.Row = 2;
            app.TXAntennaHeight.Layout.Column = 3;
            app.TXAntennaHeight.Value = 10;

            % Create AdditionalDescriptionLabel
            app.AdditionalDescriptionLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.AdditionalDescriptionLabel.VerticalAlignment = 'bottom';
            app.AdditionalDescriptionLabel.FontSize = 11;
            app.AdditionalDescriptionLabel.Layout.Row = 10;
            app.AdditionalDescriptionLabel.Layout.Column = [1 3];
            app.AdditionalDescriptionLabel.Text = 'Informações adicionais:';

            % Create AdditionalDescription
            app.AdditionalDescription = uieditfield(app.SelectedEmissionPanelGrid, 'text');
            app.AdditionalDescription.ValueChangedFcn = createCallbackFcn(app, @onOthersParametersValueChanged, true);
            app.AdditionalDescription.FontSize = 11;
            app.AdditionalDescription.Layout.Row = 11;
            app.AdditionalDescription.Layout.Column = [1 4];

            % Create LOGLabel
            app.LOGLabel = uilabel(app.SelectedEmissionPanelGrid);
            app.LOGLabel.VerticalAlignment = 'bottom';
            app.LOGLabel.FontSize = 10;
            app.LOGLabel.Layout.Row = 12;
            app.LOGLabel.Layout.Column = [1 3];
            app.LOGLabel.Text = 'LOG';

            % Create LOG
            app.LOG = uilabel(app.SelectedEmissionPanelGrid);
            app.LOG.VerticalAlignment = 'top';
            app.LOG.WordWrap = 'on';
            app.LOG.FontSize = 11;
            app.LOG.Layout.Row = 13;
            app.LOG.Layout.Column = [1 4];
            app.LOG.Interpreter = 'html';
            app.LOG.Text = '';

            % Create ClassificationRefresh
            app.ClassificationRefresh = uiimage(app.SelectedEmissionPanelGrid);
            app.ClassificationRefresh.ScaleMethod = 'none';
            app.ClassificationRefresh.ImageClickedFcn = createCallbackFcn(app, @onOthersParametersValueChanged, true);
            app.ClassificationRefresh.Visible = 'off';
            app.ClassificationRefresh.Tooltip = {''};
            app.ClassificationRefresh.Layout.Row = 12;
            app.ClassificationRefresh.Layout.Column = 4;
            app.ClassificationRefresh.VerticalAlignment = 'bottom';
            app.ClassificationRefresh.ImageSource = 'Refresh_18.png';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {'1x', 22, 22, 5, 22};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_EmissionReportListLimit
            app.tool_EmissionReportListLimit = uicheckbox(app.Toolbar);
            app.tool_EmissionReportListLimit.ValueChangedFcn = createCallbackFcn(app, @onToolbarCheckBoxValueChanged, true);
            app.tool_EmissionReportListLimit.Text = 'Exibir apenas emissões dos fluxos espectrais selecionados para o relatório.';
            app.tool_EmissionReportListLimit.FontSize = 11;
            app.tool_EmissionReportListLimit.Layout.Row = 2;
            app.tool_EmissionReportListLimit.Layout.Column = 1;

            % Create tool_ExportJSONFile
            app.tool_ExportJSONFile = uiimage(app.Toolbar);
            app.tool_ExportJSONFile.ScaleMethod = 'none';
            app.tool_ExportJSONFile.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.tool_ExportJSONFile.Tooltip = {''};
            app.tool_ExportJSONFile.Layout.Row = [1 3];
            app.tool_ExportJSONFile.Layout.Column = 2;
            app.tool_ExportJSONFile.ImageSource = 'Export_16.png';

            % Create tool_ShowGlobalExceptionList
            app.tool_ShowGlobalExceptionList = uiimage(app.Toolbar);
            app.tool_ShowGlobalExceptionList.ScaleMethod = 'none';
            app.tool_ShowGlobalExceptionList.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.tool_ShowGlobalExceptionList.Tooltip = {''};
            app.tool_ShowGlobalExceptionList.Layout.Row = [1 3];
            app.tool_ShowGlobalExceptionList.Layout.Column = 3;
            app.tool_ShowGlobalExceptionList.ImageSource = 'exceptionList_18.png';

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 4;
            app.tool_Separator.VerticalAlignment = 'bottom';
            app.tool_Separator.ImageSource = 'LineV.svg';

            % Create tool_ControlPanelVisibility
            app.tool_ControlPanelVisibility = uiimage(app.Toolbar);
            app.tool_ControlPanelVisibility.ScaleMethod = 'none';
            app.tool_ControlPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.tool_ControlPanelVisibility.Layout.Row = [1 3];
            app.tool_ControlPanelVisibility.Layout.Column = 5;
            app.tool_ControlPanelVisibility.ImageSource = 'layout-sidebar-right.svg';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [5 6];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {''};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {''};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winSignalAnalysis';

            % Create contextmenu_TruncateItem
            app.contextmenu_TruncateItem = uimenu(app.ContextMenu);
            app.contextmenu_TruncateItem.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_TruncateItem.Text = '✏️ Editar';

            % Create contextmenu_NonTruncateEmission
            app.contextmenu_NonTruncateEmission = uimenu(app.contextmenu_TruncateItem);
            app.contextmenu_NonTruncateEmission.MenuSelectedFcn = createCallbackFcn(app, @onUITableContextMenuClicked, true);
            app.contextmenu_NonTruncateEmission.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_NonTruncateEmission.Text = 'Não truncar';

            % Create contextmenu_TruncateEmission
            app.contextmenu_TruncateEmission = uimenu(app.contextmenu_TruncateItem);
            app.contextmenu_TruncateEmission.MenuSelectedFcn = createCallbackFcn(app, @onUITableContextMenuClicked, true);
            app.contextmenu_TruncateEmission.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_TruncateEmission.Enable = 'off';
            app.contextmenu_TruncateEmission.Text = 'Truncar frequência';

            % Create contextmenu_DeleteEmission
            app.contextmenu_DeleteEmission = uimenu(app.ContextMenu);
            app.contextmenu_DeleteEmission.MenuSelectedFcn = createCallbackFcn(app, @onUITableContextMenuClicked, true);
            app.contextmenu_DeleteEmission.Separator = 'on';
            app.contextmenu_DeleteEmission.Text = '❌ Excluir';
            
            % Assign app.ContextMenu
            app.UITable.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winSignalAnalysis_exported(Container, varargin)

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
