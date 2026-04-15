classdef winSignalAnalysis_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        DockModule                    matlab.ui.container.GridLayout
        dockModule_Undock             matlab.ui.control.Image
        dockModule_Close              matlab.ui.control.Image
        Document                      matlab.ui.container.GridLayout
        axesTool_Warning              matlab.ui.control.Image
        plotPanel                     matlab.ui.container.Panel
        axesTool_Pan                  matlab.ui.control.Image
        axesTool_RestoreView          matlab.ui.control.Image
        UITable                       matlab.ui.control.Table
        tableInfoMetadata             matlab.ui.control.Label
        Control                       matlab.ui.container.GridLayout
        EditableParametersPanel       matlab.ui.container.Panel
        EditableParametersGrid        matlab.ui.container.GridLayout
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
        TXLocation_EditCancel         matlab.ui.control.Image
        TXLocation_EditConfirm        matlab.ui.control.Image
        TXLocation_EditMode           matlab.ui.control.Image
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
        DelAnnotation                 matlab.ui.control.Image
        EditableParametersLabel       matlab.ui.control.Label
        selectedEmissionInfo          matlab.ui.control.Label
        selectedEmissionLabel         matlab.ui.control.Label
        Toolbar                       matlab.ui.container.GridLayout
        tool_Separator2               matlab.ui.control.Image
        tool_ControlPanelVisibility   matlab.ui.control.Image
        tool_ShowGlobalExceptionList  matlab.ui.control.Image
        tool_ExportJSONFile           matlab.ui.control.Image
        tool_EmissionReportListLimit  matlab.ui.control.CheckBox
        ContextMenu                   matlab.ui.container.ContextMenu
        ContextMenu_editEmission      matlab.ui.container.Menu
        ContextMenu_analogEmission    matlab.ui.container.Menu
        ContextMenu_digitalEmission   matlab.ui.container.Menu
        ContextMenu_deleteEmission    matlab.ui.container.Menu
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
                        Toolbar_CheckBoxValueChanged(app)

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
                        app.DelAnnotation;
                        app.TXLocation_EditMode;
                        app.TXLocation_EditConfirm;
                        app.TXLocation_EditCancel;
                        app.tool_ExportJSONFile;
                        app.tool_ShowGlobalExceptionList;
                        app.tool_ControlPanelVisibility;
                        app.axesTool_Warning;
                        app.dockModule_Undock;
                        app.dockModule_Close;
                        app.selectedEmissionInfo
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.DelAnnotation.UserData.id,                'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna à classificação automática')), ...
                            struct('appName', appName, 'dataTag', app.TXLocation_EditMode.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Edita parâmetros do provável emissor')), ...
                            struct('appName', appName, 'dataTag', app.TXLocation_EditConfirm.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Confirma edição, recriando perfil de terreno')), ...
                            struct('appName', appName, 'dataTag', app.TXLocation_EditCancel.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Cancela edição')), ...
                            struct('appName', appName, 'dataTag', app.tool_ExportJSONFile.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Exporta arquivo JSON com informações das emissões sob análise')), ...
                            struct('appName', appName, 'dataTag', app.tool_ShowGlobalExceptionList.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Mostra lista global de exceções<br>(emissão não é considerada "Não licenciada")')), ...
                            struct('appName', appName, 'dataTag', app.tool_ControlPanelVisibility.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à direita')), ...
                            struct('appName', appName, 'dataTag', app.axesTool_Warning.UserData.id,             'tooltip', struct('defaultPosition', 'top',    'textContent', 'Evidenciada obstrução total da 1ª Zona de Fresnel')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,            'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,             'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.selectedEmissionInfo, appName);
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

            app.axesTool_Pan.UserData.status = false;
            app.TXLocation_EditMode.UserData.status = false;
            app.UITable.RowName = 'numbered';

            initializeAxes(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            pause(.100)
            Toolbar_CheckBoxValueChanged(app)
            focus(app.UITable)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.plotPanel, 1, 3, "Padding", "compact", "TileSpacing", "compact");
            
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
        function startup_createEmissionsTable(app, flowIdxs, selectedRow)
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

            set(app.UITable, 'Data', app.emissionsTable(:, columnNames), 'Selection', selectedRow)
            layout_TableStyle(app)
            FillComponents(app)
    
            if ~progressDialogAlreadyVisible
                app.progressDialog.Visible = 'hidden';
            end
        end
        
        %-----------------------------------------------------------------%
        function layout_editRFDataHubStation(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    set(app.TXLocation_EditMode, 'ImageSource', 'Edit_32Filled.png', 'UserData', true)
                    app.TXLocationEditionGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.TXLocation_EditConfirm.Enable = 1;
                    app.TXLocation_EditCancel.Enable  = 1;
                    set(findobj(app.TXLocationGrid.Children, 'Type', 'uinumericeditfield'), 'Editable', 1)

                case 'off'
                    set(app.TXLocation_EditMode, 'ImageSource', 'Edit_32.png', 'UserData', false)
                    app.TXLocationEditionGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.TXLocation_EditConfirm.Enable = 0;
                    app.TXLocation_EditCancel.Enable  = 0;
                    set(findobj(app.TXLocationGrid.Children, 'Type', 'uinumericeditfield'), 'Editable', 0)

                    layout_updateCoordinatesPanel(app)
            end
        end

        %-----------------------------------------------------------------%
        function layout_Regulatory(app)
            switch app.Regulatory.Value
                case {'Licenciada', 'Licenciada UTE'}
                    set(app.EmissionType, 'Value', 'Fundamental', 'Enable', 0)
                    app.EmissionTypeLabel.Enable   = 0;    
                    set(app.Compliance, 'Items', {'Não', 'Sim'}, 'Value', 'Não')

                otherwise % {'Não licenciada', 'Não passível de licenciamento'}
                    app.EmissionType.Enable      = 1;
                    app.EmissionTypeLabel.Enable = 1;
                    app.StationID.Value          = '-1';
    
                    switch app.Regulatory.Value
                        case 'Não licenciada'
                            app.Compliance.Items = {'Sim'};                            
                        case 'Não passível de licenciamento'
                            set(app.Compliance, 'Items', {'Não', 'Sim'}, 'Value', 'Não')
                    end
            end
        end

        %-----------------------------------------------------------------%
        function layout_StationID(app)
            if app.StationID.Value == "-1"
                set(app.StationID, 'BackgroundColor', [1,0,0], 'FontColor', [1,1,1])
            else
                set(app.StationID, 'BackgroundColor', [1,1,1], 'FontColor', [0,0,0])
            end
        end

        %-----------------------------------------------------------------%
        function layout_EmissionType(app)
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
        function layout_Compliance(app)
            if strcmp(app.Compliance.Value, 'Não')
                set(app.RiskLevel,      'Enable', 0, 'Items', {'-'})
                set(app.RiskLevelLabel, 'Enable', 0)
            else
                set(app.RiskLevel,      'Enable', 1, 'Items', {'Baixo', 'Médio', 'Alto'})
                set(app.RiskLevelLabel, 'Enable', 1)
            end
        end

        %-----------------------------------------------------------------%
        function layout_TableStyle(app)
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
                addStyle(app.UITable, uistyle('Icon', 'Edit_32.png',  'IconAlignment', 'leftmargin'), 'cell', listOfCells1) 
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
        function FillComponents(app)
            if ~isempty(app.emissionsTable)
                selectedRow = app.UITable.Selection;
                [idxThread, idxEmission] = emissionIndex(app);
    
                [htmlContent,     ...
                 emissionTag,     ...
                 userDescription, ...
                 stationInfo]   = util.HtmlTextGenerator.Emission(app.mainApp.specData, idxThread, idxEmission);
    
                ui.TextView.update(app.selectedEmissionInfo, htmlContent);
                set(app.AdditionalDescription, 'Value', userDescription, 'UserData', userDescription) 
    
                % TABLE CONTEXT MENU
                if app.mainApp.specData(idxThread).UserData.Emissions.IsTruncated(idxEmission)
                    app.ContextMenu_analogEmission.Enable  = 1;
                    app.ContextMenu_digitalEmission.Enable = 0;
                else
                    app.ContextMenu_analogEmission.Enable  = 0;
                    app.ContextMenu_digitalEmission.Enable = 1;
                end
    
                % CONTROL PANEL
                app.DelAnnotation.Visible = ~isequal(app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).AutoSuggested, ...
                                                     app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified);
                
                app.Regulatory.Value = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Regulatory;
                layout_Regulatory(app)

                app.StationID.Value = num2str(app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Station);
                layout_StationID(app)

                app.EmissionType.Value = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.EmissionType;
                layout_EmissionType(app)

                app.Compliance.Value = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Irregular;
                layout_Compliance(app)

                app.RiskLevel.Value = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.RiskLevel;
    
                % PLOT CONFIG PANEL
                app.TXLocation_EditConfirm.UserData = stationInfo;
                layout_updateCoordinatesPanel(app)
    
                % PLOT
                plot_createSpectrumPlot(app, idxThread, idxEmission, emissionTag)
                plot_createRFLinkPlot(app, selectedRow, idxThread)
                
                app.EditableParametersGrid.Visible = 1;
                app.tool_ExportJSONFile.Enable = 1;

            else
                ui.TextView.update(app.selectedEmissionInfo, '');
                cla(app.UIAxes1)
                ysecondarylabel(app.UIAxes1, newline)
                cla(app.UIAxes2)
                app.DelAnnotation.Visible = 0;
                app.EditableParametersGrid.Visible = 0;
                app.tool_ExportJSONFile.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function layout_updateCoordinatesPanel(app)
            stationInfo = app.TXLocation_EditConfirm.UserData;

            app.TXLatitude.Value  = round(double(stationInfo.Latitude),  6);
            app.TXLongitude.Value = round(double(stationInfo.Longitude), 6);

            if stationInfo.AntennaHeight > 0
                app.TXAntennaHeight.Value = stationInfo.AntennaHeight;
            else
                app.TXAntennaHeight.Value = app.mainApp.General.context.RFDATAHUB.tx.defaultHeight;
            end
        end

        %-----------------------------------------------------------------%
        function plot_createSpectrumPlot(app, flowIdx, emissionIdx, emissionTag)
            cla(app.UIAxes1)

            if ~isempty(flowIdx) && ~isempty(emissionIdx)
                % pre-Plot (XLim, YLim, YLabel)
                updateSpectrumInfo(app.bandObj, app.mainApp.specData(flowIdx), emissionIdx);

                app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', app.bandObj.XLimits, 'yLim', app.bandObj.YLimitsLevel, 'cLim', 'auto');
                set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)

                ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))
                ysecondarylabel(app.UIAxes1, sprintf('%s\n%.3f - %.3f MHz @ %s\n', app.mainApp.specData(flowIdx).Receiver,               ...
                                                                                   app.mainApp.specData(flowIdx).MetaData.FreqStart/1e6, ...
                                                                                   app.mainApp.specData(flowIdx).MetaData.FreqStop/1e6,  ...
                                                                                   emissionTag))

                % Plot "minHold", "average" e "maxHold"
                for plotTag = ["minHold", "average", "maxHold"]
                    eval(sprintf('hLine = plot.draw2D.OrdinaryLine(app.UIAxes1, "%s", app.bandObj, []);', plotTag))
                    plot.datatip.Template(hLine, "Frequency+Level", app.bandObj.LevelUnit)
                end

                % Plot "ROI"
                plot.draw2D.rectangularROI(app.UIAxes1, app.bandObj, app.mainApp.specData(flowIdx).UserData.Emissions, emissionIdx, 'emissionROI', {'EdgeAlpha', 0, 'InteractionsAllowed', 'none'})

            else
                msgWarning = 'Não identificado o fluxo de dados relacionado à emissão...';
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
            end
        end

        %-----------------------------------------------------------------%
        function plot_createRFLinkPlot(app, selectedRow, idxThread)
            try
                % OBJETOS TX e RX
                [txObj, rxObj] = RFLinkObjects(app, selectedRow, idxThread);
    
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
                    app.axesTool_Warning.Visible = 0;
                else
                    app.axesTool_Warning.Visible = 1;
                end
                
            catch ME
                cla(app.UIAxes2)
                app.UIAxes2.PickableParts = "none";
                msgWarning = text(app.UIAxes2, mean(app.UIAxes2.XLim), mean(app.UIAxes2.YLim), {'PERFIL DE TERRENO ENTRE RECEPTOR';  ...
                                                                                                'E PROVÁVEL EMISSOR É LIMITADO ÀS';  ...
                                                                                                'ESTAÇÕES INCLUÍDAS NO RFDATAHUB';   ...
                                                                                                '(EXCETO VISUALIZAÇÃO TEMPORÁRIA)'}, ...
                                               BackgroundColor=[.8,.8,.8], HorizontalAlignment="center", FontSize=10);
                msgWarning.Units = 'normalized';
                app.axesTool_Warning.Visible = 0;
            end
            app.TXLocation_EditConfirm.Enable = 0;
        end

        %-----------------------------------------------------------------%
        function [txSite, rxSite] = RFLinkObjects(app, selectedRow, flowIdx)
            if (app.TXLatitude.Value == -1) && (app.TXLongitude.Value == -1)
                error('winSignalAnalysis:RFLinkObjects:UnexpectedEmptyIndex', 'Unexpected empty index')
            end

            % txSite e rxSite estão como struct, mas basta mudar para "txsite" e 
            % "rxsite" que eles poderão ser usados em predições, uma vez que os 
            % campos da estrutura são idênticos às propriedades dos objetos.

            % TX
            txSite = struct('Name',                 'TX',                                                   ...
                            'TransmitterFrequency', double(app.UITable.Data.Truncated(selectedRow) * 1e+6), ...
                            'Latitude',             app.TXLatitude.Value,                                   ...
                            'Longitude',            app.TXLongitude.Value,                                  ...
                            'AntennaHeight',        app.TXAntennaHeight.Value);

            % RX
            rxSite = struct('Name',                 'RX',                                  ...
                            'Latitude',             app.mainApp.specData(flowIdx).GPS.Latitude,  ...
                            'Longitude',            app.mainApp.specData(flowIdx).GPS.Longitude, ...
                            'AntennaHeight',        calculateAntennaHeight(app.mainApp.specData, flowIdx, 10));
        end

        %-----------------------------------------------------------------%
        function AddException(app, triggeredComponent, varargin)
            [idxThread, idxEmission] = emissionIndex(app);

            switch triggeredComponent
                case app.DelAnnotation
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).AutoSuggested;

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

                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Service       = stationInfo.Service;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Station       = stationInfo.Station;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Latitude      = stationInfo.Latitude;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Longitude     = stationInfo.Longitude;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.AntennaHeight = stationInfo.AntennaHeight;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Description   = stationInfo.Description;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Details       = stationInfo.Details;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Distance      = stationInfo.Distance;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Regulatory    = newRegulatory;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.EmissionType  = 'Fundamental';                        
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Irregular     = newCompliance;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.RiskLevel     = newRiskLevel;

                case app.AdditionalDescription
                    userDescription = app.AdditionalDescription.Value;

                    if strcmp(userDescription, app.mainApp.specData(idxThread).UserData.Emissions.Description(idxEmission))
                        return
                    end

                    app.mainApp.specData(idxThread).UserData.Emissions.Description(idxEmission) = userDescription;
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'PeakDescriptionChanged')
                    
                case app.TXLocation_EditConfirm % Latitude | Longitude | AntennaHeight
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Latitude      = app.TXLatitude.Value;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Longitude     = app.TXLongitude.Value;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.AntennaHeight = app.TXAntennaHeight.Value;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Distance      = deg2km(distance(app.mainApp.specData(idxThread).GPS.Latitude, app.mainApp.specData(idxThread).GPS.Longitude, ...
                                                                                                                                        app.TXLatitude.Value, app.TXLongitude.Value));

                otherwise
                    oldRegulatory = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Regulatory;
                    newRegulatory = app.Regulatory.Value;

                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Regulatory    = app.Regulatory.Value;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.EmissionType  = app.EmissionType.Value;                        
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Irregular     = app.Compliance.Value;
                    app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.RiskLevel     = app.RiskLevel.Value;

                    if newRegulatory ~= "Licenciada"
                        app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Service     = int16(-1);
                        app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Station     = int32(-1);
                        app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Description = '[EXC]';
                        app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Details     = '';

                        if oldRegulatory == "Licenciada"
                            app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Latitude      = -1;
                            app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Longitude     = -1;
                            app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.AntennaHeight = 0;
                            app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Distance      = -1;
                        end
                    end
            end

            Toolbar_CheckBoxValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function [flowIdx, emissionIdx] = emissionIndex(app)
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
        function DockModuleGroup_ButtonPushed(app, event)
            
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

        % Image clicked function: tool_ControlPanelVisibility, 
        % ...and 2 other components
        function Toolbar_ImageClicked(app, event)

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
                        iconWarning = 'none';
                    end
                    msgWarning = sprintf('%s\n%s', 'Lista global de exceções:', strjoin(globalEmissiontList, '\n'));
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
                    
                    writematrix(emissionFiscalizaTable, JSONFullPath, "FileType", "text", "QuoteStrings", "none")

                %---------------------------------------------------------%
                case app.tool_ControlPanelVisibility
                    if app.Control.Visible
                        app.Control.Visible = 0;
                        app.Document.Layout.Column = [2, numel(app.GridLayout.ColumnWidth)-2];
                        app.tool_ControlPanelVisibility.ImageSource = 'layout-sidebar-right-off.svg';
                    else
                        app.Control.Visible = 1;
                        app.Document.Layout.Column = 2;
                        app.tool_ControlPanelVisibility.ImageSource = 'layout-sidebar-right.svg';
                    end
            end

        end

        % Value changed function: tool_EmissionReportListLimit
        function Toolbar_CheckBoxValueChanged(app, event)
            
            if app.tool_EmissionReportListLimit.Value
                flowIdxs = find(arrayfun(@(x) x.UserData.ReportInclude, app.mainApp.specData));
            else
                flowIdxs = 1:numel(app.mainApp.specData);
            end

            selectedRow = app.UITable.Selection;
            startup_createEmissionsTable(app, flowIdxs, selectedRow)
            
        end

        % Callback function: TXLatitude, TXLocation_EditCancel, 
        % ...and 5 other components
        function AxesToolbar_ImageClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    plot.axes.Interactivity.CustomRestoreViewFcn(app.UIAxes1, app.UIAxes2, app)
                
                case app.axesTool_Pan
                    app.axesTool_Pan.UserData.status = ~app.axesTool_Pan.UserData.status;
                    if app.axesTool_Pan.UserData.status
                        app.axesTool_Pan.ImageSource = 'Pan_32Filled.png';
                    else
                        app.axesTool_Pan.ImageSource = 'Pan_32.png';
                    end

                    plot.axes.Interactivity.CustomPanFcn(struct('Value', app.axesTool_Pan.UserData.status), app.UIAxes1, app.UIAxes2);

                case app.TXLocation_EditMode
                    app.TXLocation_EditMode.UserData.status = ~app.TXLocation_EditMode.UserData.status;
        
                    if app.TXLocation_EditMode.UserData.status
                        layout_editRFDataHubStation(app, 'on')
                        focus(app.TXLatitude)        
                    else
                        layout_editRFDataHubStation(app, 'off')
                    end

                case app.TXLocation_EditConfirm
                    AddException(app, event.Source)
                    layout_editRFDataHubStation(app, 'off')

                case app.TXLocation_EditCancel
                    layout_editRFDataHubStation(app, 'off')

                case app.TXLatitude
                    focus(app.TXLongitude)

                case app.TXLongitude
                    focus(app.TXAntennaHeight)
            end

        end

        % Selection changed function: UITable
        function UITableSelectionValueChanged(app, event)

            if isempty(event.Selection)
                app.UITable.Selection = event.PreviousSelection;
            else
                FillComponents(app)
            end
            
        end

        % Menu selected function: ContextMenu_analogEmission, 
        % ...and 2 other components
        function UITableContextMenuClicked(app, event)
            
            if ~isempty(app.UITable.Selection)
                app.progressDialog.Visible = 'visible';

                [idxThread, idxEmission] = emissionIndex(app);

                switch event.Source
                    case app.ContextMenu_deleteEmission
                        operationType = 'DeleteButtonPushed';
                        app.mainApp.specData(idxThread).UserData.Emissions(idxEmission,:) = [];
                        idxEmission = 1;

                    case app.ContextMenu_digitalEmission
                        operationType = 'IsTruncatedValueChanged';
                        app.mainApp.specData(idxThread).UserData.Emissions.IsTruncated(idxEmission) = 1;

                    case app.ContextMenu_analogEmission
                        operationType = 'IsTruncatedValueChanged';
                        app.mainApp.specData(idxThread).UserData.Emissions.IsTruncated(idxEmission) = 0;
                end
                
                ipcMainMatlabCallsHandler(app.mainApp, app, operationType, idxThread, idxEmission)

                % Ao excluir emissões diretamente deste módulo, chegando ao
                % limite de não ter emissões, o módulo será fechado. A validação 
                % a seguir evita erro.
                if isvalid(app)
                    if ~strcmp(app.mainApp.executionMode, 'webApp')
                        figure(app.UIFigure)
                    end
                    
                    app.progressDialog.Visible = 'hidden';
                end
            end

        end

        % Value changed function: StationID
        function StationIDValueChanged(app, event)
            
            global RFDataHub

            try
                app.StationID.Value = strtrim(app.StationID.Value);
                if isempty(regexp(app.StationID.Value, '^\#?\d+$', 'once'))
                    error(['Esse campo deve ser preenchido com o número da estação ou a ID do registro no RFDataHub. ' ...
                           'O seu formato é numérico, com a ressalva de que quando inserido a ID do registro '         ...
                           'deve ser colocado o caractere "#" à frente do número. Por exemplo: 123456 ou #123456.'])
                end
                
                [idxThread, idxEmission] = emissionIndex(app);
                receiverLatitude  = app.mainApp.specData(idxThread).GPS.Latitude;
                receiverLongitude = app.mainApp.specData(idxThread).GPS.Longitude;
                stationInfo       = model.RFDataHub.query(RFDataHub, app.StationID.Value, receiverLatitude, receiverLongitude);

                % Caso a estação não conste em RFDataHub, o método query
                % chamado anteriormente retornará um erro. Mas caso
                % encontre, confirma-se com o usuário a edição.
                dataStruct(1)     = struct('group', 'INDICAÇÃO AUTOMÁTICA',                                                                                               ...
                                           'value', struct('Regulatory', app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).AutoSuggested.Regulatory, ...
                                                           'Frequency',  sprintf('%.3f MHz', app.mainApp.specData(idxThread).UserData.Emissions.Frequency(idxEmission))));
                
                if app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).AutoSuggested.Regulatory == "Licenciada"
                    dataStruct(1).value.Description = app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).AutoSuggested.Description;
                    dataStruct(1).value.Distance    = sprintf('%s km', app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).AutoSuggested.Distance);
                end

                switch stationInfo.Service
                    case -1
                        emissionRegulatory = '<font style="color: #c94756;">Não Licenciada</font>';
                    otherwise
                        emissionRegulatory = 'Licenciada';
                end
                dataStruct(2)  = struct('group', 'MANUAL',                                                       ...
                                        'value', struct('Regulatory',  emissionRegulatory,                       ...
                                                        'Frequency',   sprintf('%s MHz', stationInfo.Frequency), ...
                                                        'Description', stationInfo.Description,                  ...
                                                        'Distance',    sprintf('%.1f km', stationInfo.Distance)));

                msgQuestion    = sprintf('%s<br><font style="font-size: 12px;">Confirma edição?<font>', textFormatGUI.struct2PrettyPrintList(dataStruct, "print -1", '', 'popup'));
                userSelection  = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                switch userSelection
                    case 'Sim'
                        AddException(app, app.StationID, stationInfo)
                    case 'Não'
                        app.StationID.Value = num2str(app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Station);
                end

            catch ME
                app.StationID.Value = num2str(app.mainApp.specData(idxThread).UserData.Emissions.Classification(idxEmission).UserModified.Station);
                ui.Dialog(app.UIFigure, 'warning', getReport(ME));
            end
            
        end

        % Value changed function: Regulatory
        function RegulatoryValueChanged(app, event)
            
            switch event.Value
                case 'Licenciada'
                    app.Regulatory.Value = event.PreviousValue;
    
                    msgWarning = ['A alteração da situação de uma emissão para "Licenciada" deve ser feita diretamente no ' ...
                                  'campo "Estação / ID", inserindo o número da estação ou a ID do registro no RFDataHub. ' ...
                                  'O seu formato é numérico, com a ressalva de que quando inserido a ID do registro '      ...
                                  'deve ser colocado o caractere "#" à frente do número. Por exemplo: 123456 ou #123456.'];
                    ui.Dialog(app.UIFigure, 'warning', msgWarning);
                    return

                otherwise % case {'Licenciada UTE', 'Não licenciada', 'Não passível de licenciamento'}
                    userDescription = strtrim(app.AdditionalDescription.Value);
                    if isempty(userDescription)
                        app.Regulatory.Value = event.PreviousValue;
    
                        msgWarning = ['O campo "Informações complementares" não pode ficar vazio para registros ' ...
                                      'relacionados a uma estação "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento".<br><br>' ...
                                      'Edite o campo "Informações complementares" antes de alterar a "Situação".'];
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                        return
                    end
            end

            layout_Regulatory(app)
            OthersParametersValueChanged(app, struct('Source', app.Compliance))
            
        end

        % Value changed function: EmissionType
        function EmissionTypeValueChanged(app, event)
            
            regulatoryValue = app.Regulatory.Value;
            userDescription = strtrim(app.AdditionalDescription.Value);

            if ~strcmp(regulatoryValue, 'Licenciada') && isempty(userDescription)
                app.EmissionType.Value = event.PreviousValue;

                msgWarning = ['O campo "Informações complementares" não pode ficar vazio para registros ' ...
                              'relacionados a uma estação "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento".<br><br>' ...
                              'Edite o campo "Informações complementares" antes de alterar o "Tipo de emissão".'];
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                return
            end

            OthersParametersValueChanged(app, struct('Source', app.EmissionType))
            
        end

        % Callback function: AdditionalDescription, Compliance, 
        % ...and 2 other components
        function OthersParametersValueChanged(app, event)
            
            switch event.Source
                case app.Compliance
                    layout_Compliance(app)

                case app.EmissionType
                    layout_EmissionType(app)

                case app.AdditionalDescription
                    userDescription = strtrim(app.AdditionalDescription.Value);
                    if isempty(userDescription) && ~strcmp(app.Regulatory.Value, 'Licenciada')
                        app.AdditionalDescription.Value = event.PreviousValue;
    
                        msgWarning = ['O campo "Informações complementares" não pode ficar vazio para registros ' ...
                                      'relacionados a uma estação "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento".'];
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                        return
                    end

                    app.AdditionalDescription.Value = userDescription;
            end

            AddException(app, event.Source)

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
            app.tool_EmissionReportListLimit.ValueChangedFcn = createCallbackFcn(app, @Toolbar_CheckBoxValueChanged, true);
            app.tool_EmissionReportListLimit.Text = 'Exibir apenas emissões dos fluxos espectrais selecionados para o relatório.';
            app.tool_EmissionReportListLimit.FontSize = 11;
            app.tool_EmissionReportListLimit.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.tool_EmissionReportListLimit.Layout.Row = 2;
            app.tool_EmissionReportListLimit.Layout.Column = 1;

            % Create tool_ExportJSONFile
            app.tool_ExportJSONFile = uiimage(app.Toolbar);
            app.tool_ExportJSONFile.ScaleMethod = 'none';
            app.tool_ExportJSONFile.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ImageClicked, true);
            app.tool_ExportJSONFile.Tooltip = {''};
            app.tool_ExportJSONFile.Layout.Row = [1 3];
            app.tool_ExportJSONFile.Layout.Column = 2;
            app.tool_ExportJSONFile.ImageSource = 'Export_16.png';

            % Create tool_ShowGlobalExceptionList
            app.tool_ShowGlobalExceptionList = uiimage(app.Toolbar);
            app.tool_ShowGlobalExceptionList.ScaleMethod = 'none';
            app.tool_ShowGlobalExceptionList.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ImageClicked, true);
            app.tool_ShowGlobalExceptionList.Tooltip = {''};
            app.tool_ShowGlobalExceptionList.Layout.Row = [1 3];
            app.tool_ShowGlobalExceptionList.Layout.Column = 3;
            app.tool_ShowGlobalExceptionList.ImageSource = 'exceptionList_18.png';

            % Create tool_ControlPanelVisibility
            app.tool_ControlPanelVisibility = uiimage(app.Toolbar);
            app.tool_ControlPanelVisibility.ScaleMethod = 'none';
            app.tool_ControlPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ImageClicked, true);
            app.tool_ControlPanelVisibility.Layout.Row = [1 3];
            app.tool_ControlPanelVisibility.Layout.Column = 5;
            app.tool_ControlPanelVisibility.ImageSource = 'layout-sidebar-right.svg';

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.Toolbar);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 3];
            app.tool_Separator2.Layout.Column = 4;
            app.tool_Separator2.VerticalAlignment = 'bottom';
            app.tool_Separator2.ImageSource = 'LineV.svg';

            % Create Control
            app.Control = uigridlayout(app.GridLayout);
            app.Control.ColumnWidth = {'1x', 16};
            app.Control.RowHeight = {58, '1x', 22, 253};
            app.Control.RowSpacing = 5;
            app.Control.Padding = [0 0 0 0];
            app.Control.Layout.Row = [3 4];
            app.Control.Layout.Column = [4 5];
            app.Control.BackgroundColor = [1 1 1];

            % Create selectedEmissionLabel
            app.selectedEmissionLabel = uilabel(app.Control);
            app.selectedEmissionLabel.VerticalAlignment = 'bottom';
            app.selectedEmissionLabel.FontSize = 10;
            app.selectedEmissionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.selectedEmissionLabel.Layout.Row = 1;
            app.selectedEmissionLabel.Layout.Column = 1;
            app.selectedEmissionLabel.Text = 'EMISSÃO SELECIONADA';

            % Create selectedEmissionInfo
            app.selectedEmissionInfo = uilabel(app.Control);
            app.selectedEmissionInfo.VerticalAlignment = 'top';
            app.selectedEmissionInfo.WordWrap = 'on';
            app.selectedEmissionInfo.FontSize = 11;
            app.selectedEmissionInfo.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.selectedEmissionInfo.Layout.Row = 2;
            app.selectedEmissionInfo.Layout.Column = [1 2];
            app.selectedEmissionInfo.Interpreter = 'html';
            app.selectedEmissionInfo.Text = '';

            % Create EditableParametersLabel
            app.EditableParametersLabel = uilabel(app.Control);
            app.EditableParametersLabel.VerticalAlignment = 'bottom';
            app.EditableParametersLabel.FontSize = 10;
            app.EditableParametersLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EditableParametersLabel.Layout.Row = 3;
            app.EditableParametersLabel.Layout.Column = 1;
            app.EditableParametersLabel.Text = 'PROVÁVEL EMISSOR';

            % Create DelAnnotation
            app.DelAnnotation = uiimage(app.Control);
            app.DelAnnotation.ScaleMethod = 'none';
            app.DelAnnotation.ImageClickedFcn = createCallbackFcn(app, @OthersParametersValueChanged, true);
            app.DelAnnotation.Tooltip = {''};
            app.DelAnnotation.Layout.Row = 3;
            app.DelAnnotation.Layout.Column = 2;
            app.DelAnnotation.VerticalAlignment = 'bottom';
            app.DelAnnotation.ImageSource = 'Refresh_18.png';

            % Create EditableParametersPanel
            app.EditableParametersPanel = uipanel(app.Control);
            app.EditableParametersPanel.AutoResizeChildren = 'off';
            app.EditableParametersPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EditableParametersPanel.BackgroundColor = [1 1 1];
            app.EditableParametersPanel.Layout.Row = 4;
            app.EditableParametersPanel.Layout.Column = [1 2];

            % Create EditableParametersGrid
            app.EditableParametersGrid = uigridlayout(app.EditableParametersPanel);
            app.EditableParametersGrid.ColumnWidth = {'1x', '1x', 70, '1x'};
            app.EditableParametersGrid.RowHeight = {17, 22, 25, 22, 17, 59, 17, '1x'};
            app.EditableParametersGrid.ColumnSpacing = 5;
            app.EditableParametersGrid.RowSpacing = 5;
            app.EditableParametersGrid.Padding = [10 10 10 5];
            app.EditableParametersGrid.BackgroundColor = [1 1 1];

            % Create RegulatoryLabel
            app.RegulatoryLabel = uilabel(app.EditableParametersGrid);
            app.RegulatoryLabel.VerticalAlignment = 'bottom';
            app.RegulatoryLabel.WordWrap = 'on';
            app.RegulatoryLabel.FontSize = 10;
            app.RegulatoryLabel.FontColor = [0.149 0.149 0.149];
            app.RegulatoryLabel.Layout.Row = 1;
            app.RegulatoryLabel.Layout.Column = 1;
            app.RegulatoryLabel.Text = 'Situação:';

            % Create Regulatory
            app.Regulatory = uidropdown(app.EditableParametersGrid);
            app.Regulatory.Items = {'Licenciada', 'Licenciada UTE', 'Não licenciada', 'Não passível de licenciamento'};
            app.Regulatory.ValueChangedFcn = createCallbackFcn(app, @RegulatoryValueChanged, true);
            app.Regulatory.FontSize = 11;
            app.Regulatory.FontColor = [0.149 0.149 0.149];
            app.Regulatory.BackgroundColor = [1 1 1];
            app.Regulatory.Layout.Row = 2;
            app.Regulatory.Layout.Column = [1 3];
            app.Regulatory.Value = 'Licenciada';

            % Create StationIDLabel
            app.StationIDLabel = uilabel(app.EditableParametersGrid);
            app.StationIDLabel.VerticalAlignment = 'bottom';
            app.StationIDLabel.FontSize = 10;
            app.StationIDLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.StationIDLabel.Layout.Row = 1;
            app.StationIDLabel.Layout.Column = 4;
            app.StationIDLabel.Text = 'Estação / ID:';

            % Create StationID
            app.StationID = uieditfield(app.EditableParametersGrid, 'text');
            app.StationID.ValueChangedFcn = createCallbackFcn(app, @StationIDValueChanged, true);
            app.StationID.HorizontalAlignment = 'right';
            app.StationID.FontSize = 11;
            app.StationID.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.StationID.Layout.Row = 2;
            app.StationID.Layout.Column = 4;

            % Create EmissionTypeLabel
            app.EmissionTypeLabel = uilabel(app.EditableParametersGrid);
            app.EmissionTypeLabel.VerticalAlignment = 'bottom';
            app.EmissionTypeLabel.WordWrap = 'on';
            app.EmissionTypeLabel.FontSize = 10;
            app.EmissionTypeLabel.FontColor = [0.149 0.149 0.149];
            app.EmissionTypeLabel.Layout.Row = 3;
            app.EmissionTypeLabel.Layout.Column = [1 2];
            app.EmissionTypeLabel.Text = {'Tipo de '; 'emissão:'};

            % Create EmissionType
            app.EmissionType = uidropdown(app.EditableParametersGrid);
            app.EmissionType.Items = {'Fundamental', 'Harmônico de fundamental', 'Produto de intermodulação', 'Espúrio', 'Não identificado', 'Não se manifestou', 'Pendente identificação'};
            app.EmissionType.ValueChangedFcn = createCallbackFcn(app, @EmissionTypeValueChanged, true);
            app.EmissionType.FontSize = 11;
            app.EmissionType.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EmissionType.BackgroundColor = [1 1 1];
            app.EmissionType.Layout.Row = 4;
            app.EmissionType.Layout.Column = [1 2];
            app.EmissionType.Value = 'Pendente identificação';

            % Create ComplianceLabel
            app.ComplianceLabel = uilabel(app.EditableParametersGrid);
            app.ComplianceLabel.VerticalAlignment = 'bottom';
            app.ComplianceLabel.WordWrap = 'on';
            app.ComplianceLabel.FontSize = 10;
            app.ComplianceLabel.FontColor = [0.149 0.149 0.149];
            app.ComplianceLabel.Layout.Row = 3;
            app.ComplianceLabel.Layout.Column = [3 4];
            app.ComplianceLabel.Text = {'Indício de'; 'irregularidade?'};

            % Create Compliance
            app.Compliance = uidropdown(app.EditableParametersGrid);
            app.Compliance.Items = {'Não', 'Sim'};
            app.Compliance.ValueChangedFcn = createCallbackFcn(app, @OthersParametersValueChanged, true);
            app.Compliance.FontSize = 11;
            app.Compliance.FontColor = [0.149 0.149 0.149];
            app.Compliance.BackgroundColor = [1 1 1];
            app.Compliance.Layout.Row = 4;
            app.Compliance.Layout.Column = 3;
            app.Compliance.Value = 'Não';

            % Create RiskLevelLabel
            app.RiskLevelLabel = uilabel(app.EditableParametersGrid);
            app.RiskLevelLabel.VerticalAlignment = 'bottom';
            app.RiskLevelLabel.WordWrap = 'on';
            app.RiskLevelLabel.FontSize = 10;
            app.RiskLevelLabel.FontColor = [0.149 0.149 0.149];
            app.RiskLevelLabel.Layout.Row = 3;
            app.RiskLevelLabel.Layout.Column = 4;
            app.RiskLevelLabel.Text = 'Potencial lesivo:';

            % Create RiskLevel
            app.RiskLevel = uidropdown(app.EditableParametersGrid);
            app.RiskLevel.Items = {'-', 'Baixo', 'Médio', 'Alto'};
            app.RiskLevel.ValueChangedFcn = createCallbackFcn(app, @OthersParametersValueChanged, true);
            app.RiskLevel.FontSize = 11;
            app.RiskLevel.FontColor = [0.149 0.149 0.149];
            app.RiskLevel.BackgroundColor = [1 1 1];
            app.RiskLevel.Layout.Row = 4;
            app.RiskLevel.Layout.Column = 4;
            app.RiskLevel.Value = '-';

            % Create TXLocationPanelLabel
            app.TXLocationPanelLabel = uilabel(app.EditableParametersGrid);
            app.TXLocationPanelLabel.VerticalAlignment = 'bottom';
            app.TXLocationPanelLabel.FontSize = 10;
            app.TXLocationPanelLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLocationPanelLabel.Layout.Row = 5;
            app.TXLocationPanelLabel.Layout.Column = [1 2];
            app.TXLocationPanelLabel.Text = 'Características de instalação:';

            % Create TXLocationEditionGrid
            app.TXLocationEditionGrid = uigridlayout(app.EditableParametersGrid);
            app.TXLocationEditionGrid.ColumnWidth = {'1x', 18, 0, 0};
            app.TXLocationEditionGrid.RowHeight = {'1x'};
            app.TXLocationEditionGrid.ColumnSpacing = 5;
            app.TXLocationEditionGrid.Padding = [0 0 0 0];
            app.TXLocationEditionGrid.Layout.Row = 5;
            app.TXLocationEditionGrid.Layout.Column = [3 4];
            app.TXLocationEditionGrid.BackgroundColor = [1 1 1];

            % Create TXLocation_EditMode
            app.TXLocation_EditMode = uiimage(app.TXLocationEditionGrid);
            app.TXLocation_EditMode.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.TXLocation_EditMode.Tooltip = {''};
            app.TXLocation_EditMode.Layout.Row = 1;
            app.TXLocation_EditMode.Layout.Column = 2;
            app.TXLocation_EditMode.VerticalAlignment = 'bottom';
            app.TXLocation_EditMode.ImageSource = 'Edit_32.png';

            % Create TXLocation_EditConfirm
            app.TXLocation_EditConfirm = uiimage(app.TXLocationEditionGrid);
            app.TXLocation_EditConfirm.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.TXLocation_EditConfirm.Enable = 'off';
            app.TXLocation_EditConfirm.Tooltip = {''};
            app.TXLocation_EditConfirm.Layout.Row = 1;
            app.TXLocation_EditConfirm.Layout.Column = 3;
            app.TXLocation_EditConfirm.VerticalAlignment = 'bottom';
            app.TXLocation_EditConfirm.ImageSource = 'Ok_32Green.png';

            % Create TXLocation_EditCancel
            app.TXLocation_EditCancel = uiimage(app.TXLocationEditionGrid);
            app.TXLocation_EditCancel.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.TXLocation_EditCancel.Enable = 'off';
            app.TXLocation_EditCancel.Tooltip = {''};
            app.TXLocation_EditCancel.Layout.Row = 1;
            app.TXLocation_EditCancel.Layout.Column = 4;
            app.TXLocation_EditCancel.VerticalAlignment = 'bottom';
            app.TXLocation_EditCancel.ImageSource = 'Delete_32Red.png';

            % Create TXLocationPanel
            app.TXLocationPanel = uipanel(app.EditableParametersGrid);
            app.TXLocationPanel.AutoResizeChildren = 'off';
            app.TXLocationPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.TXLocationPanel.BackgroundColor = [1 1 1];
            app.TXLocationPanel.Layout.Row = 6;
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
            app.TXLatitudeLabel.FontSize = 10;
            app.TXLatitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLatitudeLabel.Layout.Row = 1;
            app.TXLatitudeLabel.Layout.Column = 1;
            app.TXLatitudeLabel.Text = 'Latitude:';

            % Create TXLatitude
            app.TXLatitude = uieditfield(app.TXLocationGrid, 'numeric');
            app.TXLatitude.Limits = [-90 90];
            app.TXLatitude.ValueDisplayFormat = '%.6f';
            app.TXLatitude.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.TXLatitude.Editable = 'off';
            app.TXLatitude.FontSize = 11;
            app.TXLatitude.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLatitude.Layout.Row = 2;
            app.TXLatitude.Layout.Column = 1;
            app.TXLatitude.Value = -1;

            % Create TXLongitudeLabel
            app.TXLongitudeLabel = uilabel(app.TXLocationGrid);
            app.TXLongitudeLabel.VerticalAlignment = 'bottom';
            app.TXLongitudeLabel.FontSize = 10;
            app.TXLongitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLongitudeLabel.Layout.Row = 1;
            app.TXLongitudeLabel.Layout.Column = 2;
            app.TXLongitudeLabel.Text = 'Longitude:';

            % Create TXLongitude
            app.TXLongitude = uieditfield(app.TXLocationGrid, 'numeric');
            app.TXLongitude.Limits = [-180 180];
            app.TXLongitude.ValueDisplayFormat = '%.6f';
            app.TXLongitude.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.TXLongitude.Editable = 'off';
            app.TXLongitude.FontSize = 11;
            app.TXLongitude.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLongitude.Layout.Row = 2;
            app.TXLongitude.Layout.Column = 2;
            app.TXLongitude.Value = -1;

            % Create TXAntennaHeightLabel
            app.TXAntennaHeightLabel = uilabel(app.TXLocationGrid);
            app.TXAntennaHeightLabel.VerticalAlignment = 'bottom';
            app.TXAntennaHeightLabel.FontSize = 10;
            app.TXAntennaHeightLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXAntennaHeightLabel.Layout.Row = 1;
            app.TXAntennaHeightLabel.Layout.Column = 3;
            app.TXAntennaHeightLabel.Text = 'Altura (m):';

            % Create TXAntennaHeight
            app.TXAntennaHeight = uieditfield(app.TXLocationGrid, 'numeric');
            app.TXAntennaHeight.Limits = [0 Inf];
            app.TXAntennaHeight.ValueDisplayFormat = '%.1f';
            app.TXAntennaHeight.Editable = 'off';
            app.TXAntennaHeight.FontSize = 11;
            app.TXAntennaHeight.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXAntennaHeight.Layout.Row = 2;
            app.TXAntennaHeight.Layout.Column = 3;
            app.TXAntennaHeight.Value = 10;

            % Create AdditionalDescriptionLabel
            app.AdditionalDescriptionLabel = uilabel(app.EditableParametersGrid);
            app.AdditionalDescriptionLabel.VerticalAlignment = 'bottom';
            app.AdditionalDescriptionLabel.WordWrap = 'on';
            app.AdditionalDescriptionLabel.FontSize = 10;
            app.AdditionalDescriptionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.AdditionalDescriptionLabel.Layout.Row = 7;
            app.AdditionalDescriptionLabel.Layout.Column = [1 4];
            app.AdditionalDescriptionLabel.Text = 'Informações complementares:';

            % Create AdditionalDescription
            app.AdditionalDescription = uieditfield(app.EditableParametersGrid, 'text');
            app.AdditionalDescription.ValueChangedFcn = createCallbackFcn(app, @OthersParametersValueChanged, true);
            app.AdditionalDescription.FontSize = 11;
            app.AdditionalDescription.FontColor = [0 0 1];
            app.AdditionalDescription.Layout.Row = 8;
            app.AdditionalDescription.Layout.Column = [1 4];

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {22, 22, '1x', '1x', 22};
            app.Document.RowHeight = {63, '1x', 14, 18, 253};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = 2;
            app.Document.BackgroundColor = [1 1 1];

            % Create tableInfoMetadata
            app.tableInfoMetadata = uilabel(app.Document);
            app.tableInfoMetadata.VerticalAlignment = 'top';
            app.tableInfoMetadata.WordWrap = 'on';
            app.tableInfoMetadata.FontSize = 14;
            app.tableInfoMetadata.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.tableInfoMetadata.Layout.Row = 1;
            app.tableInfoMetadata.Layout.Column = [1 5];
            app.tableInfoMetadata.Interpreter = 'html';
            app.tableInfoMetadata.Text = {'Exibindo emissões relacionadas aos fluxos espectrais'; '<p style="color: #808080; font-size:10px; text-align: justify; margin-right: 2px;">A célula "Frequência (MHz)" apresentará <font style="color: red;">ÍCONE DE EDIÇÃO</font> toda vez que alterada a classificação da emissão. Além disso, a célula "Frequência canal (MHz)" apresentará <font style="color: red;">ÍCONE VERMELHO</font> toda vez que o nº da estação for igual a -1, o que ocorre quando a situação da emissão é "Licenciada UTE", "Não licenciada" ou "Não passível de licenciamento", ou quando essa informação não consta na base de dados.</p>'};

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.BackgroundColor = [1 1 1;0.96078431372549 0.96078431372549 0.96078431372549];
            app.UITable.ColumnName = {'FREQUÊNCIA|(MHz)'; 'FREQUÊNCIA|CANAL (MHz)'; 'LARGURA|(kHz)'; 'NÍVEL|MÍNIMO (dB)'; 'NÍVEL|MÉDIO (dB)'; 'NÍVEL|MÁXIMO (dB)'; 'OCUPAÇÃO|TOTAL (%)'; 'OCUPAÇÃO|MÍNIMA (%)'; 'OCUPAÇÃO|MÉDIA (%)'; 'OCUPAÇÃO|MÁXIMA (%)'; 'PROVÁVEL EMISSOR|(Entidade+Fistel+Serviço+Estação+Localidade)'};
            app.UITable.ColumnWidth = {95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 'auto'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @UITableSelectionValueChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.UITable.Layout.Row = 2;
            app.UITable.Layout.Column = [1 5];
            app.UITable.FontSize = 10.5;

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.Document);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 4;
            app.axesTool_RestoreView.Layout.Column = 1;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_Pan
            app.axesTool_Pan = uiimage(app.Document);
            app.axesTool_Pan.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_ImageClicked, true);
            app.axesTool_Pan.Tooltip = {'Pan'};
            app.axesTool_Pan.Layout.Row = 4;
            app.axesTool_Pan.Layout.Column = 2;
            app.axesTool_Pan.ImageSource = 'pan-32px.png';

            % Create plotPanel
            app.plotPanel = uipanel(app.Document);
            app.plotPanel.AutoResizeChildren = 'off';
            app.plotPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.plotPanel.BorderType = 'none';
            app.plotPanel.BackgroundColor = [0 0 0];
            app.plotPanel.Layout.Row = 5;
            app.plotPanel.Layout.Column = [1 5];

            % Create axesTool_Warning
            app.axesTool_Warning = uiimage(app.Document);
            app.axesTool_Warning.Visible = 'off';
            app.axesTool_Warning.Tooltip = {''};
            app.axesTool_Warning.Layout.Row = 4;
            app.axesTool_Warning.Layout.Column = 5;
            app.axesTool_Warning.ImageSource = 'warning.svg';

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
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {''};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {''};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winSignalAnalysis';

            % Create ContextMenu_editEmission
            app.ContextMenu_editEmission = uimenu(app.ContextMenu);
            app.ContextMenu_editEmission.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContextMenu_editEmission.Text = '✏️ Editar';

            % Create ContextMenu_analogEmission
            app.ContextMenu_analogEmission = uimenu(app.ContextMenu_editEmission);
            app.ContextMenu_analogEmission.MenuSelectedFcn = createCallbackFcn(app, @UITableContextMenuClicked, true);
            app.ContextMenu_analogEmission.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContextMenu_analogEmission.Text = 'Não truncar';

            % Create ContextMenu_digitalEmission
            app.ContextMenu_digitalEmission = uimenu(app.ContextMenu_editEmission);
            app.ContextMenu_digitalEmission.MenuSelectedFcn = createCallbackFcn(app, @UITableContextMenuClicked, true);
            app.ContextMenu_digitalEmission.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContextMenu_digitalEmission.Enable = 'off';
            app.ContextMenu_digitalEmission.Text = 'Truncar frequência';

            % Create ContextMenu_deleteEmission
            app.ContextMenu_deleteEmission = uimenu(app.ContextMenu);
            app.ContextMenu_deleteEmission.MenuSelectedFcn = createCallbackFcn(app, @UITableContextMenuClicked, true);
            app.ContextMenu_deleteEmission.Separator = 'on';
            app.ContextMenu_deleteEmission.Text = '❌ Excluir';
            
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
