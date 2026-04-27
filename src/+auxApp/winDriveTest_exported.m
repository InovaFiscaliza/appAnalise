classdef winDriveTest_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        dockModule_Close                matlab.ui.control.Image
        dockModule_Undock               matlab.ui.control.Image
        Document                        matlab.ui.container.GridLayout
        AxesToolbar                     matlab.ui.container.GridLayout
        axesTool_DensityPlot_2          matlab.ui.control.Image
        axesTool_PlotSize               matlab.ui.control.Slider
        axesTool_DensityPlot            matlab.ui.control.Image
        axesTool_DistortionPlot         matlab.ui.control.Image
        axesTool_DataSourceDropDown     matlab.ui.control.DropDown
        axesTool_RegionZoom             matlab.ui.control.Image
        axesTool_RestoreView            matlab.ui.control.Image
        AxesContainer                   matlab.ui.container.Panel
        RightPanel                      matlab.ui.container.GridLayout
        config_Refresh                  matlab.ui.control.Image
        CartesianAxesPanel              matlab.ui.container.Panel
        CartesianAxesGrid               matlab.ui.container.GridLayout
        config_BandGuardBWRelatedValue  matlab.ui.control.Spinner
        config_BandGuardFixedValue      matlab.ui.control.NumericEditField
        config_BandGuardType            matlab.ui.control.DropDown
        config_BandGuardValueLabel      matlab.ui.control.Label
        config_BandGuardTypeLabel       matlab.ui.control.Label
        config_chPowerFaceAlpha         matlab.ui.control.Spinner
        config_chPowerEdgeAlpha         matlab.ui.control.Spinner
        config_chPowerColor             matlab.ui.control.ColorPicker
        config_chPowerVisibility        matlab.ui.control.DropDown
        config_chPowerLabel             matlab.ui.control.Label
        config_chROIFaceAlpha           matlab.ui.control.Spinner
        config_chROIEdgeAlpha           matlab.ui.control.Spinner
        config_chROIColor               matlab.ui.control.ColorPicker
        config_chROIVisibility          matlab.ui.control.DropDown
        config_chROILabel               matlab.ui.control.Label
        config_PersistanceVisibility    matlab.ui.control.DropDown
        config_PersistanceLabel         matlab.ui.control.Label
        CartesianAxesPanelLabel         matlab.ui.control.Label
        CartesianAxesPanelIcon          matlab.ui.control.Image
        GeographicAxesPanel             matlab.ui.container.Panel
        GeographicAxesPanelGrid         matlab.ui.container.GridLayout
        config_Colormap                 matlab.ui.control.DropDown
        config_ColormapLabel            matlab.ui.control.Label
        config_Basemap                  matlab.ui.control.DropDown
        config_BasemapLabel             matlab.ui.control.Label
        config_points_Size              matlab.ui.control.Slider
        config_points_Color             matlab.ui.control.ColorPicker
        config_points_LineStyle         matlab.ui.control.DropDown
        config_points_Label             matlab.ui.control.Label
        config_Car_Size                 matlab.ui.control.Slider
        config_Car_Color                matlab.ui.control.ColorPicker
        config_Car_LineStyle            matlab.ui.control.DropDown
        config_Car_Label                matlab.ui.control.Label
        config_route_Label              matlab.ui.control.Label
        config_route_LineStyle          matlab.ui.control.DropDown
        config_route_OutColor           matlab.ui.control.ColorPicker
        config_route_InColor            matlab.ui.control.ColorPicker
        config_route_Size               matlab.ui.control.Slider
        GeographicAxesPanelLabel        matlab.ui.control.Label
        GeographicAxesPanelIcon         matlab.ui.control.Image
        LeftPanel                       matlab.ui.container.GridLayout
        EmissionList                    matlab.ui.control.DropDown
        EmissionPanel                   matlab.ui.container.Panel
        EmissionPanelGrid               matlab.ui.container.GridLayout
        PointsTree                      matlab.ui.container.CheckBoxTree
        PointsTreeButton                matlab.ui.control.Image
        PointsTreeLabel                 matlab.ui.control.Label
        FilterTree                      matlab.ui.container.Tree
        FilterTreeButton                matlab.ui.control.Image
        FilterTreeLabel                 matlab.ui.control.Label
        DataBinningPanel                matlab.ui.container.Panel
        DataBinningGrid                 matlab.ui.container.GridLayout
        DataBinningFcn                  matlab.ui.control.DropDown
        DataBinningFcnLabel             matlab.ui.control.Label
        DataBinningLength               matlab.ui.control.Spinner
        DataBinningLengthLabel          matlab.ui.control.Label
        DataBinningLabel                matlab.ui.control.Label
        EmissionMetadata                matlab.ui.control.Label
        EmissionAttributesPanelRightBtn  matlab.ui.control.Image
        EmissionAttributesPanelLeftBtn  matlab.ui.control.Image
        EmissionAttributesPanelVisibleIdx  matlab.ui.control.Label
        EmissionPanelLabel              matlab.ui.control.Label
        SpectrumFlowList                matlab.ui.control.DropDown
        Toolbar                         matlab.ui.container.GridLayout
        tool_LayoutRight                matlab.ui.control.Image
        tool_Separator3                 matlab.ui.control.Image
        tool_FilterSummary              matlab.ui.control.Image
        tool_DataBinningExport          matlab.ui.control.Image
        tool_Play                       matlab.ui.control.Image
        tool_TimestampLabel             matlab.ui.control.Label
        tool_TimestampSlider            matlab.ui.control.Slider
        tool_LoopControl                matlab.ui.control.Image
        tool_Separator                  matlab.ui.control.Image
        tool_LayoutLeft                 matlab.ui.control.Image
        ContextMenu                     matlab.ui.container.ContextMenu
        DeleteSelectedItem              matlab.ui.container.Menu
        DeleteAllEntries                matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'DRIVETEST'
        AppHandleNameInBase
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

        % Handles dos eixos utilizados por este módulo.
        UIAxes1
        UIAxes2
        UIAxes3
        UIAxes4

        % Informações relacionadas ao specData selecionado, com atalhos para 
        % os principais metadados e a definição dos limites dos eixos x, y e 
        % z dos eixos cartesianos.
        bandObj

        % Armazena limites padrão dos eixos cartesianos computados em método 
        % de model.Band (app.bandObj).
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
        )

        % Controla o estado de atualização do plot:
        %  -1: mudança de fluxo espectral
        %   0: finaliza a apresentação da última varredura
        %   1: atualiza alguma característica do plot em andamento
        plotUpdateEvent = 0

        % Handles dos objetos gráficos do plot.
        plotHandles

        % Índice da varredura atual.
        sweepTimeIdx
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        projectData

        emissionSelectedIdxs = struct('flowIdx', {}, 'emissionIdx', {}, 'attributes', {})
        emissionPoints = struct('raw', [], 'filtered', [], 'binned', [])

        filterTable = table({}, {}, struct('handle', {}, 'specification', {}), 'VariableNames', {'type', 'subtype', 'roi'})
        pointsTable = table({}, struct('source', {}, 'data', {}, 'dataIdx', {}), true(0, 1), 'VariableNames', {'type', 'value', 'visible'})

        defaultValues
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'onChannelEditRequested'
                        [flowIdx, emissionIdx] = findSpecDataIndex(app);
                        ipcMainMatlabOpenPopupApp(app.mainApp, app, 'EmissionChannel', app.Context, flowIdx, emissionIdx)

                    case 'onClassificationEditRequested'
                        [flowIdx, emissionIdx] = findSpecDataIndex(app);
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onClassificationEditRequested', app.Context, flowIdx, emissionIdx)

                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, varargin)
            try
                switch class(callingApp)
                    case {'winAppAnalise', 'winAppAnalise_exported'}
                        eventName = varargin{1};

                        switch eventName
                            case 'NomeEventoEspecifico'
                                uialert(app.UIFigure, 'Oi', '')

                            case {'onFileListAdded', ...
                                  'onFileListRemoved', ...
                                  'onFileFilterChanged', ...
                                  'onLocationChanged', ...
                                  'onEmissionAdded', ...
                                  'onEmissionParameterValueChanged', ...
                                  'onEmissionTruncatedValueChanged', ...
                                  'onEmissionChannelChanged', ...
                                  'onEmissionDeleted', ...
                                  'onSpectralDataReadError'}
                                app.emissionSelectedIdxs(:) = [];
                                updateFlowDropDown(app)

                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = -1;
                                else
                                    onFlowDropDownValueChanged(app)
                                end
            
                            case {'onTabNavigatorButtonPushed', 'onPlaybackStarted'}
                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = 0;
                                end

                            case 'auxApp.winDriveTest.FilterTree'
                                onContextMenuItemClicked(app, struct('ContextObject', app.FilterTree, 'Source', app.DeleteSelectedItem))

                            case 'auxApp.winDriveTest.PointsTree'
                                onContextMenuItemClicked(app, struct('ContextObject', app.PointsTree, 'Source', app.DeleteSelectedItem))

                            otherwise
                                error('auxApp:winDriveTest:UnexpectedCall', 'Unexpected call "%s"', eventName)
                        end

                    otherwise
                        error('auxApp:winDriveTest:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                end
            
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-------------------------------------------------------------------------%
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
                        app.SpectrumFlowList;
                        app.EmissionList;
                        app.EmissionPanelLabel;
                        app.EmissionMetadata;
                        app.FilterTree;
                        app.PointsTree;
                        app.tool_LayoutLeft;
                        app.tool_LayoutRight;
                        app.tool_Play;
                        app.tool_LoopControl;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id,        'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SpectrumFlowList.UserData.id,   'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')), ...
                            struct('appName', appName, 'dataTag', app.EmissionList.UserData.id,       'dropDownBackgroundColor', struct('items', 'rgba(51, 51, 51, 0.75)', 'selectedItem', 'rgb(20, 20, 20)')), ...
                            struct('appName', appName, 'dataTag', app.EmissionPanelLabel.UserData.id, 'styleImportant', struct('borderLeft', '3px solid #333333', 'paddingLeft', '8px')), ...
                            struct('appName', appName, 'dataTag', app.FilterTree.UserData.id,         'listener', struct('componentName', 'auxApp.winDriveTest.FilterTree', 'keyEvents', {{'Delete', 'Backspace'}})), ...
                            struct('appName', appName, 'dataTag', app.PointsTree.UserData.id,         'listener', struct('componentName', 'auxApp.winDriveTest.PointsTree', 'keyEvents', {{'Delete', 'Backspace'}})), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutLeft.UserData.id,    'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à esquerda')), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutRight.UserData.id,   'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à direita')), ...
                            struct('appName', appName, 'dataTag', app.tool_Play.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla execução do playback da monitoração')), ...
                            struct('appName', appName, 'dataTag', app.tool_LoopControl.UserData.id,   'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla loop da execução do playback')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,  'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,   'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.EmissionMetadata,  appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
                    catch
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = app.mainApp.projectData;
            app.bandObj = model.Band('appAnalise:DRIVETEST', app.mainApp);

            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            prjFolder = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            prjConfigFile = fullfile(prjFolder, 'GeneralSettings.json');
            prjGeneralSettings = jsondecode(fileread(prjConfigFile));
            
            app.defaultValues = struct( ...
                'basemap', prjGeneralSettings.plot.geographicAxes.Basemap, ...
                'colormap', prjGeneralSettings.plot.geographicAxes.Colormap, ...
                'waterfall', prjGeneralSettings.context.PLAYBACK.defaultPlotDisplayConfig.waterfall, ...
                'channelROI', prjGeneralSettings.plot.channelROI, ...
                'channelPower', prjGeneralSettings.plot.channelPower, ...
                'drivetest', prjGeneralSettings.plot.drivetest ...
            );

            app.defaultValues.waterfall.function = 'image';

            if strcmp(app.mainApp.executionMode, 'webApp')
                app.defaultValues.basemap = 'none';
            end
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.EmissionAttributesPanelVisibleIdx.UserData.index = 1;
            app.tool_LayoutLeft.UserData.status = true;
            app.tool_LayoutRight.UserData.status = false;

            initializeAxes(app)

            app.config_chROIColor.Value     = app.defaultValues.channelROI.Color;
            app.config_chROIEdgeAlpha.Value = app.defaultValues.channelROI.EdgeAlpha;
            app.config_chROIFaceAlpha.Value = app.defaultValues.channelROI.FaceAlpha;
            app.config_chPowerColor.Value   = app.UIAxes3.Colormap(end,:);
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateFlowDropDown(app)
            onFlowDropDownValueChanged(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 24, 16, "Padding", "none", "TileSpacing", "none", "Position", [0, 0, 1, 1]);

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.defaultValues.basemap,                ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '', 'PlotMode', 'distortion')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [24, 12];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            
            geolimits(app.UIAxes1, 'auto')
            plot.axes.Colormap(app.UIAxes1, app.defaultValues.colormap)

            if ismember(app.defaultValues.basemap, {'darkwater', 'none'})
                app.UIAxes1.Grid = 'on';
            end

            % Eixo cartesiano: ESPECTRO
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'XColor', 'white', 'XGrid', 1, 'XMinorGrid', 0, 'XTick', {}, 'XTickLabel', {}, ...
                                                                    'YColor', 'white', 'YGrid', 0, 'YMinorGrid', 0, 'YTick', {},                   ...
                                                                    'Layer', 'top', 'GridLineStyle', '-.', 'TickDir', 'none',                      ...
                                                                    'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes2.Layout.Tile = 13;
            app.UIAxes2.Layout.TileSpan = [6, 4];

            % Eixo cartesiano: WATERFALL
            app.UIAxes3 = plot.axes.Creation(hParent, 'Cartesian', {'XColor', 'white', 'XGrid', 1, 'XMinorGrid', 0, 'XTick', {}, 'XTickLabel', {}, ...
                                                                    'YColor', 'white', 'YGrid', 1, 'YMinorGrid', 0, 'YTick', {}, 'YTickLabel', {}, ...
                                                                    'Layer', 'top', 'GridLineStyle', '-.', 'TickDir', 'in',                        ...
                                                                    'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes3.Layout.Tile = 109;
            app.UIAxes3.Layout.TileSpan = [18, 4];

            % Eixo cartesiano: POTÊNCIA DO CANAL
            app.UIAxes4 = plot.axes.Creation(hParent, 'Cartesian', {'XColor', 'white', 'XGrid', 1, 'XMinorGrid', 0,              ...
                                                                    'YColor', 'white', 'YGrid', 0, 'YMinorGrid', 0, 'YTick', {}, ...
                                                                    'GridLineStyle', '-.', 'TickDir', 'both', 'Color', 'none',   ...
                                                                    'UserData', struct('YLimUnit', 'dBm')});
            app.UIAxes4.Layout.Tile = 112;
            app.UIAxes4.Layout.TileSpan = [18, 1];
            app.UIAxes4.View = [270, 90];
            app.UIAxes4.YAxis.Direction = "reverse";

            % Colorbar
            colorBar = colorbar(app.UIAxes1, "Location", "layout", "TickDirection", "none", "PickableParts", "none", "FontSize", 7, "Color", "white", 'AxisLocation', 'in', 'Box', 'off');
            colorBar.Layout.Tile = 284;
            colorBar.Layout.TileSpan = [6,1];

            % Interações
            linkaxes([app.UIAxes2, app.UIAxes3], 'x')
            plot.axes.Interactivity.DefaultCreation(app.UIAxes1, [dataTipInteraction, zoomInteraction, panInteraction])
            plot.axes.Interactivity.DefaultCreation([app.UIAxes2, app.UIAxes4], dataTipInteraction)
            plot.axes.Interactivity.DataCursorMode(app.UIAxes3, true)
        end

        %-----------------------------------------------------------------%
        function updateFlowDropDown(app)
            specData = app.mainApp.specData;

            if ~isempty(specData)
                if isempty(app.SpectrumFlowList.StyleConfigurations)
                    addStyle(app.SpectrumFlowList, uistyle('Interpreter', 'html'))
                end

                previousValue = app.SpectrumFlowList.Value;
            
                [receivers, ~, indexes] = unique({specData.Receiver});
                items = {};
                itemsData = [];
                
                for ii = 1:numel(receivers)
                    receiverIdxs = find(indexes == ii)';
                    receiverName = util.layoutTreeNodeText(receivers{ii}, 'play_TreeBuilding');
                    
                    for jj = receiverIdxs
                        if ismember(specData(jj).MetaData.DataType, class.Constants.occDataTypes)
                            continue
                        end

                        freqStart = specData(jj).MetaData.FreqStart / 1e+6;
                        freqStop  = specData(jj).MetaData.FreqStop  / 1e+6;
                        
                        reportStatus = '';
                        if ~isempty(specData(jj).UserData) && specData(jj).UserData.ReportInclude
                            reportStatus = '&emsp;&#x1F7E2;';
                        end
            
                        items{end+1} = sprintf('%s<br>└── %.3f&ensp;a&ensp;%.3f MHz%s', receiverName, freqStart, freqStop, reportStatus);
                        itemsData(end+1) = jj;
                    end
                end

                currentValue = {};
                if ~isempty(previousValue)
                    if isnumeric(previousValue) && ismember(previousValue, itemsData)
                        currentValue = {'Value', previousValue};
                    end
                end

                set(app.SpectrumFlowList, 'Items', items, 'ItemsData', itemsData, currentValue{:})

            else
                removeStyle(app.SpectrumFlowList)
                app.SpectrumFlowList.Items = {};
            end
        end

        %-----------------------------------------------------------------%
        function updateFlowView(app, flowIdx)
            % Caso não esteja em cache os dados do fluxo espectral selecionado, 
            % procede-se a sua leitura, preenchendo a propriedade "Data" com
            % timestamps, níveis das varreduras, azimutes e notas de qualidade.
            % Caso ocorra erro na leitura, o registro é excluído e o layout é
            % reinicializado.
            specData = [];
            if ~isempty(flowIdx)
                specData = app.mainApp.specData(flowIdx);
            end

            if ~isempty(specData) && (isempty(specData.Data) || (numel(specData.Data{1}) ~= sum(specData.RelatedFiles.NumSweeps)))
                requestVisibilityChange(app.progressDialog, 'visible', 'unlocked')

                try
                    populateSpectrum(specData, app.mainApp.metaData, app.mainApp.channelObj, app.mainApp.General)
                    
                    relatedHases = specData.UserData.OccupancyComputationMode.RelatedHashes;
                    if ~isempty(relatedHases)
                        relatedHashIdxs = find(ismember({app.mainApp.specData.Hash}, relatedHases));
                        populateSpectrum(app.mainApp.specData(relatedHashIdxs), app.mainApp.metaData, app.mainApp.channelObj, app.mainApp.General)
                    end

                catch ME
                    ui.Dialog(app.UIFigure, 'error', ME.message);

                    delete(app.mainApp.specData(flowIdx))
                    app.mainApp.specData(flowIdx) = [];
                    updateFlowDropDown(app)

                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onSpectralDataReadError', app.Context)
                    return
                end

                requestVisibilityChange(app.progressDialog, 'hidden', 'unlocked')
            end

            updateEmissionDropDown(app)
            onEmissionDropDownValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function updateEmissionDropDown(app)
            if isempty(app.mainApp.specData)
                app.EmissionList.Items = {};
                return
            end

            flowIdx   = findSpecDataIndex(app);
            specData  = app.mainApp.specData(flowIdx);
            emissions = specData.UserData.Emissions;

            % Cria lista de emissões:
            emissionList = {};

            for ii = 0:height(emissions)
                additionalNote = '';
    
                if ii == 0
                    freqCenter   = (specData.MetaData.FreqStart + specData.MetaData.FreqStop) / 2e6; % MHz
                    bandWidthkHz = (specData.MetaData.FreqStop - specData.MetaData.FreqStart) / 1e3; % kHz
                    additionalNote = ' (Emissão virtual)';
                else
                    freqCenter   = emissions.Frequency(ii); % MHz
                    bandWidthkHz = emissions.BandWidthkHz(ii);    % kHz
                    if ~isempty(emissions.AuxAppData(ii).DriveTest)
                        additionalNote = ' (DT)';
                    end
                end

                emissionList{end+1} = sprintf('%d: %.3f MHz ⌂ %.1f kHz%s', ii, freqCenter, bandWidthkHz, additionalNote);
            end

            previousValue = app.EmissionList.Value;
            currentValue = {};
            if ~isempty(previousValue) && ismember(previousValue, emissionList)
                currentValue = {'Value', previousValue};
            end

            set(app.EmissionList, 'Items', emissionList, currentValue{:})

            if isempty(currentValue) && ~isscalar(emissionList)
                app.EmissionList.Value = emissionList{2};
            end
        end

        %-----------------------------------------------------------------%
        function updateEmissionView(app)
            [flowIdx, emissionIdx] = findSpecDataIndex(app);

            if ~isempty(app.emissionSelectedIdxs) && isequal(app.emissionSelectedIdxs.flowIdx, flowIdx) && isequal(app.emissionSelectedIdxs.emissionIdx, emissionIdx)
                return
            end

            specData = [];
            if ~isempty(flowIdx)
                specData = app.mainApp.specData(flowIdx);
            end

            % Atualiza app.bandObj, instância de model.Band, que guarda
            % informações derivadas da instância de model.SpecData sob análise.
            % A partir desse momento, a referência ao specData selecionado
            % se dará por app.bandObj.SpecData.
            updateEmissionSelected(app, specData, flowIdx, emissionIdx)
            updateSpectrumInfo(app.bandObj, specData, emissionIdx);

            % Atualiza PAINEL À ESQUERDA com metadados do fluxo e da emissão.
            updateUIControlsState(app, specData, emissionIdx)
            updateUIPanelContent(app, specData, emissionIdx)

            % Reseta o PLOT e atualiza informações que suportam o plot, como 
            % as dispostas no painel à direita.
            % resetPlotState(app, specData, emissionIdx)
            % 
            % % Atualiza PAINEL À DIREITA.
            % applyCustomPlaybackSettings(app, specData, emissionIdx)
        end

        %-----------------------------------------------------------------%
        function updateEmissionSelected(app, specData, flowIdx, emissionIdx)
            if ~isempty(specData)
                if ~isempty(emissionIdx)
                    freqCenter   = specData.UserData.Emissions.Frequency(emissionIdx);
                    bandWidthkHz = specData.UserData.Emissions.BandWidthkHz(emissionIdx);
                    chFrequency  = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.Frequency;
                    chBandWidth  = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW;
                    
                else 
                    freqCenter   = (specData.MetaData.FreqStart + specData.MetaData.FreqStop)  / 2e6; % MHz
                    bandWidthkHz = (specData.MetaData.FreqStop  - specData.MetaData.FreqStart) / 1e3; % kHz
                    chFrequency  = freqCenter;
                    chBandWidth  = bandWidthkHz;
                end

                emissionChannel = struct( ...
                    'freqCenter', chFrequency, ...
                    'bandWidthkHz', chBandWidth ...
                );
    
                app.emissionSelectedIdxs(1) = struct( ...
                    'flowIdx', flowIdx, ...
                    'emissionIdx', emissionIdx, ...
                    'attributes', struct( ...
                        'tag', sprintf('%.3f MHz ⌂ %.1f kHz', freqCenter, bandWidthkHz), ...
                        'freqCenter', freqCenter, ...
                        'bandWidthkHz', bandWidthkHz, ...
                        'channel', emissionChannel ...
                    ) ...
                );

            else
                app.emissionSelectedIdxs(:) = [];
            end
        end

        %-----------------------------------------------------------------%
        function updateUIControlsState(app, specData, emissionIdx)
            hasSpectralFlow = ~isempty(specData) && any(ismember([specData.MetaData.DataType], class.Constants.specDataTypes));

            set([
                app.tool_Play;
                app.tool_LoopControl;
                app.tool_TimestampSlider;
                app.tool_DataBinningExport;
                app.tool_FilterSummary
            ], 'Enable', hasSpectralFlow)
        end

        %-----------------------------------------------------------------%
        function updateUIPanelContent(app, specData, emissionIdx)
            if ~isempty(specData)
                % Verifica se o handle para o app continua ativo no workspace
                % base do MATLAB, possibilitando que clicks no ui.TextView sejam 
                % capturados corretamente.
                appHandleNameInBase = app.AppHandleNameInBase;
                if isempty(appHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', appHandleNameInBase, appHandleNameInBase, class(app), appHandleNameInBase))
                    app.AppHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
                end
    
                htmlContent = util.HtmlTextGenerator.EmissionMetaData(specData, app.emissionSelectedIdxs, app.AppHandleNameInBase);
                ui.TextView.update(app.EmissionMetadata, htmlContent);
    
                % Verifica se os limites do plot estão adequados ao tipo de emissão (a
                % emissão virtual, que corresponde à toda faixa espectral tem particularidades).
                % if ~isempty(emissionIdx)
                %     if ~app.config_BandGuardType.Enable
                %         % Essa situação só ocorre quando estava selecionado uma
                %         % emissão virtual e agora foi selecionada uma emissão real.
                %         % Por isso, os valores estavam configurados em "BWRelated" e 1.
                %         app.config_BandGuardType.Enable = 1;
                %         set(app.config_BandGuardBWRelatedValue, 'Enable', 1, 'Value', 6)
                %         config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))
                %     end
                % 
                % else
                %     if app.config_BandGuardType.Enable
                %         % Essa situação só ocorre quando estava selecionado uma
                %         % emissão real e agora foi selecionada uma emissão virtual.
                %         app.config_BandGuardType.Enable = 0;
                %         app.config_BandGuardBWRelatedValue.Enable = 0;
                % 
                %         if app.config_BandGuardType.Value ~= "BWRelated"
                %             app.config_BandGuardType.Value = 'BWRelated';
                %             config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardType))
                %         end
                % 
                %         if app.config_BandGuardBWRelatedValue.Value ~= 1
                %             app.config_BandGuardBWRelatedValue.Value = 1;
                %             config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))
                %         end
                %     end
                % end
    
                buildFilterTree(app)
                buildPointsTree(app)

            else
                ui.TextView.update(app.EmissionMetadata, '');
            end
        end

        %-----------------------------------------------------------------%
        function buildFilterTree(app)
            if ~isempty(app.FilterTree.Children)
                delete(app.FilterTree.Children)
            end

            if ~isempty(app.filterTable)
                for ii = 1:height(app.filterTable)
                    nodeText = sprintf('%s:%s', app.filterTable.type{ii}, app.filterTable.subtype{ii});
                    uitreenode(app.FilterTree, 'Text', nodeText, 'NodeData', ii);
                end

                set(app.FilterTree, 'SelectedNodes', app.FilterTree.Children(end), 'Enable', 1)
                FilterTreeSelectionChanged(app)
            else
                app.FilterTree.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function buildPointsTree(app)
            if ~isempty(app.PointsTree.Children)
                delete(app.PointsTree.Children)
            end

            checkedTreeNodes = [];
            for ii = 1:height(app.pointsTable)
                nodeText = sprintf('%s: %s', app.pointsTable.type{ii}, strjoin("#" + string(app.pointsTable.value(ii).idxData), ', '));
                treeNode = uitreenode(app.PointsTree, 'Text', nodeText, 'NodeData', ii);
                if app.pointsTable.visible(ii)
                    checkedTreeNodes = [checkedTreeNodes, treeNode];
                end
            end
            app.PointsTree.CheckedNodes = checkedTreeNodes;
        end

        %-----------------------------------------------------------------%
        % ## PLOT CONTROLLER ##
        %-----------------------------------------------------------------%
        function resetPlotState(app, specData)
            cla([app.UIAxes1, app.UIAxes2, app.UIAxes3])
            
            app.UIAxes1.UserData.CLimMode = 'auto';
            app.UIAxes3.UserData.CLimMode = 'auto';

            app.plotHandles = struct( ...
                'clearWrite', [], ...
                'minHold', [], ...
                'average', [], ...
                'maxHold', [], ...
                'persistence', [], ...
                'thresholdLine', [], ...
                'thresholdLabel', [], ...
                'waterfall', [], ...
                'waterfallTime', [] ...
            );
    
            app.sweepTimeIdx = 1;
            app.tool_TimestampSlider.Value = 0;
            resetRestoreView(app)

            if ~isempty(specData)
                app.tool_TimestampLabel.Text = sprintf('1 de %d\n%s', app.bandObj.NumSweeps, app.bandObj.YLimitsTime(1));
                app.AxesAnnotation.Text = sprintf('%s \n%.3f – %.3f MHz ', app.bandObj.Receiver, app.bandObj.FreqStart, app.bandObj.FreqStop);

            else
                app.tool_TimestampLabel.Text = '';
                app.AxesAnnotation.Text = '';

                if app.axesTool_occupancy.UserData.status || app.axesTool_waterfall.UserData.status
                    app.axesTool_occupancy.UserData.status = false;
                    app.axesTool_waterfall.UserData.status = false;

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)
                end

                onAxesToolbarButtonClicked(app, struct('Source', app.axesTool_RestoreView))
            end
        end

        %-----------------------------------------------------------------%
        function resetRestoreView(app)
            app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', [], 'yLim', [], 'cLim', 'auto');
            app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', [], 'yLim', [], 'cLim', 'auto');
            app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', [], 'yLim', [], 'cLim', 'auto');
            app.restoreView(4) = struct('ID', 'app.UIAxes4', 'xLim', [], 'yLim', [], 'cLim', 'auto');
        end

        %-----------------------------------------------------------------%
        function updatePlot(app)
            specData = app.bandObj.SpecData;
            if isempty(specData)
                return
            end
        
            if isempty(app.plotHandles.clearWrite)
                set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
                ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))
        
                % ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["clearWrite", "minHold", "average", "maxHold"]
                    if ismember(plotTag, {'minHold', 'average', 'maxHold'}) && ~eval(sprintf('app.axesTool_%s.UserData.status', plotTag))
                        continue
                    end
        
                    app.plotHandles.(plotTag) = plot.draw2D.OrdinaryLine(app.UIAxes1, plotTag, app.bandObj, app.sweepTimeIdx);
                    plot.datatip.Template(app.plotHandles.(plotTag), "Frequency+Level", app.bandObj.LevelUnit)
                end
                
                % Persistence
                if app.axesTool_persistence.UserData.status
                    updatePersistencePlot(app, 'Creation')
                end

                % Emissions
                updateEmissionsPlot(app)

                % BandLimits & Channels
                plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, 'bandLimits')
                % plot_Draw_Channels(app, idx)
        
                % Occupancy
                if app.axesTool_occupancy.UserData.status
                    updateOccupancyPlot(app, 'Creation', specData)
                end
        
                % Waterfall
                if app.axesTool_waterfall.UserData.status
                    updateWaterfallPlot(app)
                end
        
                % customPlayback >> DataTips
                if ~isempty(specData.UserData.PlotDisplayConfig.dataTips)
                    dtConfig = specData.UserData.PlotDisplayConfig.dataTips;
                    dtParent = [app.UIAxes1, app.UIAxes2, app.UIAxes3];
                    plot.datatip.Create('customPlayback', dtConfig, dtParent)
                end
        
            else
                % ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["clearWrite", "minHold", "average", "maxHold"]
                    if ismember(plotTag, {'minHold', 'average', 'maxHold'})
                        if ~eval(sprintf('app.axesTool_%s.UserData.status', plotTag)) || isinf(app.mainApp.General.context.PLAYBACK.integration.traceMode)
                            continue
                        end
                    end
        
                    plot.draw2D.OrdinaryLineUpdate(plotTag, app.plotHandles.(plotTag), app.bandObj, app.sweepTimeIdx);
                end
        
                % Persistence
                updatePersistencePlot(app, 'Update')

                % WaterfallTime
                if app.axesTool_waterfall.UserData.status && ~isempty(app.plotHandles.waterfallTime)
                    plot.draw2D.OrdinaryLineUpdate('waterfallTime', app.plotHandles.waterfallTime, app.bandObj, app.sweepTimeIdx);
                end
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function checkIfCustomConfigParameter(app)
            currentConfigValues = struct(...
                'controls', struct( ...
                    'persistence', app.config_PersistanceVisibility.Value, ...
                    'waterfall', true ...
                ), ...
                'persistence', struct( ...
                    'interpolation', 'nearest', ...
                    'windowSize', 'full', ...
                    'colormap', 'winter', ...
                    'transparency', 1 ...
                ), ...
                'waterfall', struct( ...
                    'function', 'image', ...
                    'decimation', 'auto', ...
                    'colormap', app.config_Colormap.Value, ...
                    'meshStyle', 'row' ...
                ), ...
                'overlays', struct( ...
                    'route', struct( ...
                        'lineStyle', app.config_route_LineStyle.Value, ...
                        'lineWidth', app.config_route_Size.Value, ...
                        'colors', struct( ...
                            'discardedPoints', app.config_route_OutColor.Value, ...
                            'retainedPoints', app.config_route_InColor.Value ...
                        ) ...
                    ), ...
                    'car', struct( ...
                        'marker', app.config_Car_LineStyle.Value, ...
                        'color', app.config_Car_Color.Value, ...
                        'size', app.config_Car_Size.Value ...
                    ), ...
                    'points', struct( ...
                        'marker',  app.config_points_LineStyle.Value, ...
                        'color', app.config_points_Color.Value, ...
                        'size', app.config_points_Size.Value ...
                    ) ...
                ), ...
                'channel', struct( ...
                    'roi', struct( ...
                        'visibility', app.config_chROIVisibility.Value, ...
                        'edgeAlpha', app.config_chROIEdgeAlpha.Value, ...
                        'faceAlpha', app.config_chROIFaceAlpha.Value ...
                    ), ...
                    'power', struct( ...
                        'visibility', app.config_chPowerVisibility.Value, ...
                        'edgeAlpha', app.config_chPowerEdgeAlpha.Value, ...
                        'faceAlpha', app.config_chPowerFaceAlpha.Value ...
                    ) ...
                ) ...
            );

            app.config_Refresh.Visible = ~isequal(app.defaultValues, currentConfigValues);
        end

        %-----------------------------------------------------------------%
        function dataSource = checkDataSource(app)
            switch app.axesTool_DataSourceDropDown.Value
                case 'Dados brutos'
                    if isempty(app.filterTable)
                        dataSource = 'Raw';
                    else
                        dataSource = 'Filtered';
                    end
                
                otherwise
                    dataSource = 'Data-Binning';
            end
        end

        %-----------------------------------------------------------------%
        function checkFixedScreenSpanLimits(app)
            switch app.config_BandGuardType.Value
                case 'Fixed'
                    chBandWidth = app.emissionSelectedIdxs.attributes.channel.bandWidthkHz;
                    chBandWidthsLimits = chBandWidth * app.config_BandGuardBWRelatedValue.Limits;
        
                    if app.config_BandGuardFixedValue.Value < chBandWidthsLimits(1)
                        app.config_BandGuardFixedValue.Value = chBandWidthsLimits(1);
                    elseif app.config_BandGuardFixedValue.Value > chBandWidthsLimits(2)
                        app.config_BandGuardFixedValue.Value = chBandWidthsLimits(2);
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function screenSpanValue = getFrequencyScreenSpanInMHz(app, requiredData)
            arguments
                app
                requiredData char {mustBeMember(requiredData, {'Screen', 'ScreenLimits', 'ScreenMaxLimits'})}
            end

            chFreqCenter = app.emissionSelectedIdxs.attributes.channel.bandWidthkHz;
            chBandWidth  = app.emissionSelectedIdxs.attributes.channel.bandWidthkHz;
            maxFactor    = app.config_BandGuardBWRelatedValue.Limits(2);

            switch app.config_BandGuardType.Value
                case 'Fixed'
                    screenSpan = app.config_BandGuardFixedValue.Value / 1000;     % kHz >> MHz
                case 'BWRelated'
                    screenSpan = app.config_BandGuardBWRelatedValue.Value * chBandWidth; % MHz
            end

            screenSpanLimits    = [chFreqCenter - screenSpan/2,            chFreqCenter + screenSpan/2];
            screenSpanMaxLimits = [chFreqCenter - maxFactor*chBandWidth/2, chFreqCenter + maxFactor*chBandWidth/2];

            switch requiredData
                case 'Screen'
                    screenSpanValue = screenSpan;
                case 'ScreenLimits'
                    screenSpanValue = screenSpanLimits;
                case 'ScreenMaxLimits'
                    screenSpanValue = screenSpanMaxLimits;
            end
        end

        %-----------------------------------------------------------------%
        function updateCustomProperty(app, specData, emissionIdx)
            arguments
                app
                specData
                emissionIdx
            end

            if isempty(emissionIdx)
                return
            end

            driveTestAttributes = struct( ...
                'measures', struct( ...
                    'raw', app.emissionPointsTable, ...
                    'filtered', app.emissionFilteredPointsTable, ...
                    'binned', app.emissionBinnedPointsTable ...
                ), ...
                'filters', [], ...
                'points', [], ...
                'customPlot', [] ...
            );

            update(specData, 'UserData:Emissions', 'AuxApp:DriveTest', emissionIdx, driveTestAttributes)
        end

        %-----------------------------------------------------------------%
        function processingSpecRawTable(app, idxThread, operationType)
            for ii = 1:numel(operationType)
                switch operationType{ii}
                    case 'specRawTable'            
                        % Afere-se, então, a potência do canal para cada uma das varreduras, 
                        % criando a tabela app.specTable com as colunas "Timestamp", "Latitude", 
                        % "Longitude" e "emissionPower".
                        chAssigned = struct('Frequency', app.ChannelFrequency.Value, ...
                                            'ChannelBW', app.ChannelBandWidthkHz.Value);
                        [app.emissionPoints.binned, ...
                         app.UIAxes4.UserData.YLimUnit] = RF.DataBinning.RawTableCreation(app.specData, idxThread, chAssigned);

                    case 'specRawTable+specFilteredTable+specBinTable'
                        % E, posteriormente, criam-se as outras tabelas - specFilteredTable e
                        % specBinTable. A coluna "Filtered" é acrescida à tabela specRawTable.
                        [app.emissionPoints.raw, ...
                         app.emissionPoints.filtered, ...
                         app.emissionPoints.binned, ...
                         app.filterTable, ...
                         app.tool_FilterSummary.UserData] = RF.DataBinning.execute(app.emissionPoints.raw,      ...
                                                                                   app.DataBinningLength.Value, ...
                                                                                   app.DataBinningFcn.Value,    ...
                                                                                   app.filterTable);
                end
            end
        end

        %-----------------------------------------------------------------%
        function Parameters = createPlotParameters(app)
            for ii = 1:height(app.filterTable)
                if isvalid(app.filterTable.roi(ii).handle)
                    app.filterTable.roi(ii).specification = plot.ROI.specification(app.filterTable.roi(ii).handle);
                end
            end

            Parameters = struct('Source',                checkDataSource(app),               ...
                                'specRawTable',          app.emissionPointsTable,                   ...
                                'specFilteredTable',     app.emissionFilteredPointsTable,              ...
                                'specBinTable',          app.emissionBinnedPointsTable,                   ...
                                'filterTable',           app.filterTable,                    ...
                                'pointsTable',           app.pointsTable,                    ...
                                'plotType',              app.UIAxes1.UserData.PlotMode,      ...
                                'plotSize',              app.axesTool_PlotSize.Value,        ...
                                'binning_Value',         app.DataBinningLength.Value, ...
                                'binning_Fcn',           app.DataBinningFcn.Value,    ...
                                'route_LineStyle',       app.config_route_LineStyle.Value,   ...
                                'route_OutColor',        app.config_route_OutColor.Value,    ...
                                'route_InColor',         app.config_route_InColor.Value,     ...
                                'route_MarkerSize',      app.config_route_Size.Value,        ...
                                'Colormap',              app.config_Colormap.Value,          ...
                                'points_Marker',         app.config_points_LineStyle.Value,  ...
                                'points_Color',          app.config_points_Color.Value,      ...
                                'points_Size',           app.config_points_Size.Value,       ...                                
                                'Basemap',               app.UIAxes1.Basemap);

        end

        %-----------------------------------------------------------------%
        % PLOT
        %-----------------------------------------------------------------%
        function prePlot_Startup(app, idxThread, idxEmission, operationType)
            app.progressDialog.Visible = 'visible';

            % Cria legenda programaticamente, caso não exista.
            if isempty(app.UIAxes1.Legend)
                lgd = legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 1, 'LineWidth', .5, 'FontSize', 7.5, 'PickableParts', 'none');
                lgd.Title.FontSize = 8.5;
            end
            app.UIAxes1.Legend.Title.String = sprintf('%.3f MHz ⌂ %.1f kHz', app.ChannelFrequency.Value, app.ChannelBandWidthkHz.Value);

            % O objeto app.tempBandObj armazena propriedades de app.specData(idxThreads) 
            % que simplifica o processo do plot, em especial na passagem de 
            % argumentos para as funções plot.draw2D, plot.Waterfall e plot.Persitance.
            GuardBand  = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', getFrequencyScreenSpanInMHz(app, 'Screen')));
            axesLimits = update(app.bandObj, idxThread, GuardBand, idxEmission);
            prePlot_restartProperties(app, axesLimits, operationType)

            try
                % Afere as tabelas que suportarão os plots e aplica os valores 
                % dos parâmetros, customizando o plot, caso aplicável. 
                prePlot_updateTables(app, idxThread, idxEmission, operationType)

                % Leitura de propriedades customizadas, caso habilitado o
                % flag do relatório.
                prePlot_customProperties(app, idxThread, idxEmission, operationType)                
                plot_CreatePlot(app, idxThread, operationType)

            catch ME
                % O erro aqui é controlado, e esperado apenas se após a aplicação
                % do filtro aos dados, restar no máximo uma amostra. Neste caso,
                % exclui-se o filtro, redesenhando-se a árvore.
                if ~isempty(app.filterTable)
                    arrayfun(@(x) delete(x), [app.filterTable.roi(end).handle]); 
                    app.filterTable(end,:) = [];
    
                    buildFilterTree(app)
                    filter_UpdatePlot(app)
                else
                    ui.Dialog(app.UIFigure, 'error', ME.message);
                end
            end

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function prePlot_updateTables(app, idxThread, idxEmission, operationType)
            % A coisa não é tão simples, infelizmente! :(
            
            % A depender do tipo de operação realizada, precisa-se atualizar,
            % ou não, as tabelas que suportam os plots. Por exemplo, caso
            % ocorra uma troca de emissão, somente será necessário recalcular 
            % as tabelas se o flag do relatório estiver desativado. Por outro 
            % lado, caso ocorra uma alteração de parâmetros do Data-Binning 
            % deverá ser recalculado apenas a tabela app.specBinTable.

            updateFlag = false;
            switch operationType
                case {'AppStartup', 'ThreadSelectionChanged', 'EmissionSelectionChanged'}
                    if isempty(idxEmission) || isempty(app.specData(idxThread).UserData.Emissions.AuxAppData(idxEmission).DriveTest)
                        processingSpecRawTable(app, idxThread, {'specRawTable', 'specRawTable+specFilteredTable+specBinTable'})
                        updateFlag = true;
                    end

                case {'ChannelParameterChanged', 'ChannelDefault'}
                    processingSpecRawTable(app, idxThread, {'specRawTable', 'specRawTable+specFilteredTable+specBinTable'})
                    updateFlag = true;

                case {'PlotDataSourceChanged', 'DataBinningParameterChanged', 'AddEditOrDeleteFilter'}
                    processingSpecRawTable(app, idxThread, {'specRawTable+specFilteredTable+specBinTable'})
                    updateFlag = true;

                case 'RefreshPlotParameters'
                    % Não é necessário recalcular as tabelas...

                otherwise
                    error('winDriveTest:prePlot_customProperties:UnexpectedOperationType', 'Unexpected operation type')
            end

            % Os pontos do tipo "FindPeaks" são relacionados à busca realizadas
            % em app.specFilteredTable. Por essa razão, ao realizar uma das 
            % operações "EmissionSelectionChanged", "ChannelParameterChanged" ou 
            % "ChannelDefault", os pontos deverão ser excluídos.
            if ismember(operationType, {'EmissionSelectionChanged', 'ChannelParameterChanged', 'ChannelDefault', 'ThreadSelectionChanged'})
                idxFindPeaks = find(strcmp(app.pointsTable.type, 'FindPeaks'));
                if ~isempty(idxFindPeaks)
                    app.pointsTable(idxFindPeaks,:) = [];
                    buildPointsTree(app)
                    plot_PointsController(app)
                end
            end

            % Atualiza as tabelas no conjunto de propriedades customizadas,
            % caso habilitado o flag do relatório. 
            
            % Neste ponto, não deve ser validado o app.ToggleEmissionPlotCustomization.Value 
            % porque, no caso de mudança de emissão, o app.ToggleEmissionPlotCustomization.Value 
            % se referirá ao flag do relatório da emissão anteriormente selecionada.
            if updateFlag
                updateCustomProperty(app, idxThread, idxEmission, 'DriveTest:JustTables')
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_customProperties(app, flowIdx, emissionIdx, operationType)
            % Customiza-se o plot, caso o flag do relatório estiver desativado...
            if ~isempty(emissionIdx) && ~isempty(app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest)
                app.ToggleEmissionPlotCustomization.Value = 1;

                % Essa "gambi" evita que os ROIs dos filtros sejam redesenhados...
                if ismember(operationType, {'AddEditOrDeleteFilter'})
                    return
                end

                % Source
                switch app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Source
                    case {'Raw', 'Filtered'}
                        app.axesTool_DataSourceDropDown.Value = 'Dados brutos';
                        app.axesTool_DensityPlot.Enable = 0;

                    case 'Data-Binning'
                        app.axesTool_DataSourceDropDown.Value = 'Dados processados';
                        app.axesTool_DensityPlot.Enable = 1;
                end

                % specRawTable, specFilteredTable e specBinTable
                app.emissionPoints = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.emissionPoints;

                % filterTable
                app.filterTable                    = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.filterTable;
                buildFilterTree(app)
                plot_FiltersController(app)

                % pointsTable
                app.pointsTable                    = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.pointsTable;
                buildPointsTree(app)
                plot_PointsController(app)

                % potType e plotSize
                app.UIAxes1.UserData.PlotMode      = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.plotType;
                app.axesTool_PlotSize.Value        = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.plotSize;

                % binningValue e binningFcn
                app.DataBinningLength.Value = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.binning_Value;
                app.DataBinningFcn.Value    = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.binning_Fcn;

                % route...                
                app.config_route_LineStyle.Value   = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.route_LineStyle;
                app.config_route_OutColor.Value    = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.route_OutColor;
                app.config_route_InColor.Value     = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.route_InColor;
                app.config_route_Size.Value        = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.route_MarkerSize;

                % Colormap
                if ~strcmp(app.UIAxes1.UserData.Colormap, app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Colormap)
                    app.config_Colormap.Value      = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Colormap;
                    plot.axes.Colormap(app.UIAxes1, app.config_Colormap.Value)
                end

                % points...                
                app.config_points_LineStyle.Value  = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.points_Marker;
                app.config_points_Color.Value      = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.points_Color;
                app.config_points_Size.Value       = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.points_Size;

                % Basemap
                if ~strcmp(app.UIAxes1.Basemap, app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Basemap)
                    app.config_Basemap.Value       = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Basemap;
                    app.UIAxes1.Basemap            = app.specData(flowIdx).UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Basemap;
                end

            else
                app.ToggleEmissionPlotCustomization.Value = 0;
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_restartProperties(app, axesLimits, operationType)
            switch operationType
                case {'AppStartup', 'RefreshPlotParameters', 'ThreadSelectionChanged'}
                    % TRIGGER: Inicialização do app, e retorno às configurações 
                    %          iniciais dos parâmetros, no modo CONFIG.
                    % EFEITO : Desenha todas as curvas - "Route", "Car", "Distortion", 
                    %          "Density", "ClearWrite", "Persistence", "ChannelROI"
                    %          "Waterfall", "ChannelPower" etc.
                    delete(findobj([app.UIAxes1.Children; app.UIAxes4.Children], '-not', {'Tag', 'FilterROI', '-or', 'Tag', 'Points'}))
                    cla([app.UIAxes2, app.UIAxes3])

                    app.plotHandles = struct('car', [], 'clearWrite', [], 'timestamp', []);
                    app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', [], 'yLim', [], 'cLim', 'auto'); % Eixo geográfico

                case 'EmissionSelectionChanged'
                    % TRIGGER: Seleção de emissão.
                    % EFEITO : Redesenha curvas do eixo geográfico, além de 
                    %          reposicionar "ChannelROI" e "Timeline".
                    delete(findobj(app.UIAxes1.Children, '-not', {'Tag', 'FilterROI', '-or', 'Tag', 'Points'}))
                    delete(findobj(app.UIAxes4.Children, 'Tag', 'ChannelPower'))

                case {'ChannelParameterChanged', 'ChannelDefault'}
                    % TRIGGER: Alteração de características do canal.
                    % EFEITO : Redesenha "Distortion", "Density" e "ChannelPower",
                    %          reposicionando "ChannelROI" e "Timeline".
                    delete(findobj(app.UIAxes1.Children, {'Tag', 'Distortion', '-or', 'Tag', 'Density'}))
                    delete(findobj(app.UIAxes4.Children, 'Tag', 'ChannelPower'))

                case {'PlotDataSourceChanged', 'DataBinningParameterChanged'}
                    % TRIGGER: Alteração fonte dos dados plotados ("Raw" para
                    %          "Data-Binning" e vice-versa) ou de características 
                    %          do Data-Binning.
                    % EFEITO : Redesenha "Distortion" e "Density".
                    delete(findobj(app.UIAxes1.Children, {'Tag', 'Distortion', '-or', 'Tag', 'Density'}))

                case 'AddEditOrDeleteFilter'
                    % TRIGGER: Mudança na lista de filtros.
                    % EFEITO : Redesenha "Route", "Distortion" e "Density".
                    delete(findobj(app.UIAxes1.Children, {'Tag', 'Distortion', '-or', 'Tag', 'Density', '-or', 'Tag', 'InRoute', '-or', 'Tag', 'OutRoute'}))

                    geolimits(app.UIAxes1, 'auto')
                    app.restoreView(1).xLim = app.UIAxes1.LatitudeLimits;
                    app.restoreView(1).yLim = app.UIAxes1.LongitudeLimits;
            end

            app.UIAxes1.UserData.CLimMode = 'auto';
            app.UIAxes3.UserData.CLimMode = 'auto';
            app.mainApp.General.Plot.Waterfall.LevelLimits = [0, 0];

            app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yLevelLim, 'cLim', 'auto');          % Eixo cartesiano (Espectro)
            app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', axesLimits.xLim, 'yLim', [],                   'cLim', axesLimits.cLim); % Eixo cartesiano (Waterfall)
            app.restoreView(4) = struct('ID', 'app.UIAxes4', 'xLim', [],              'yLim', [],                   'cLim', 'auto');          % Eixo cartesiano (Potência do canal)
        end

        %-----------------------------------------------------------------%
        function plot_CreatePlot(app, idxThread, operationType)
            % prePLOT
            chFrequency = app.ChannelFrequency.Value;
            
            set(app.UIAxes2, 'XLim', app.restoreView(2).xLim, 'YLim', app.restoreView(2).yLim, 'XTick', chFrequency)
            set(app.UIAxes3, 'XTick', chFrequency, 'CLim', app.restoreView(3).cLim)

            % PLOT
            switch operationType
                case {'AppStartup', 'RefreshPlotParameters', 'ThreadSelectionChanged'}
                    % TRIGGER: Inicialização do app, e retorno às configurações 
                    %          iniciais dos parâmetros, no modo CONFIG.
                    % EFEITO : Desenha todas as curvas - "Route", "Distortion", 
                    %          "Density", "Filters", "Points", "Car", "ClearWrite", 
                    %          "Persistance", "Waterfall" etc.
    
                    % (a) Route+Distortion+Density+Car
                    plot_Route(app)
                    plot_DistortionAndDensityPlot(app)
                    plot_Car(app, 'Creation')

                    % (b) ClearWrite+Persistance
                    app.hClearWrite = plot.draw2D.OrdinaryLine(app.UIAxes2, app.bandObj, idxThread, 'ClearWrite');
                    plot.datatip.Template(app.hClearWrite, "Frequency+Level", app.bandObj.LevelUnit)
                    plot.Persistance('Creation', [], app.UIAxes2, app.bandObj, idxThread);
    
                    % (c) Waterfall+Timeline
                    plot.Waterfall('Creation', app.UIAxes3, app.bandObj, idxThread);
                    plot_Timeline(app, 'Creation', idxThread, numel(app.specData(idxThread).Data{1}))
    
                    % (d) ChannelPower
                    plot_ChannelPower(app)
    
                    % (e) ChannelROI
                    plot_ChannelROI(app, 'Creation')

                    app.restoreView(1).xLim = app.UIAxes1.LatitudeLimits;
                    app.restoreView(1).yLim = app.UIAxes1.LongitudeLimits;

                case 'EmissionSelectionChanged'
                    % TRIGGER: Seleção de emissão.
                    % EFEITO : Redesenha curvas do eixo geográfico, além de 
                    %          reposicionar "ChannelROI" e "Timeline".
    
                    % (a) Route+Distortion+Density+Car
                    plot_Route(app)
                    plot_DistortionAndDensityPlot(app)
                    plot_Car(app, 'Creation')

                    % (b) ChannelPower+ChannelROI+Timeline
                    plot_ChannelPower(app)
                    plot_ChannelROI(app, 'Relocate')
                    plot_Timeline(app, 'Relocate')
                    
                case {'ChannelParameterChanged', 'ChannelDefault'}
                    % TRIGGER: Alteração de características do canal.
                    % EFEITO : Redesenha "Distortion", "Density" e "ChannelPower",
                    %          reposicionando "ChannelROI" e "Timeline".
                    plot_DistortionAndDensityPlot(app)
                    plot_ChannelPower(app)
                    plot_ChannelROI(app, 'Relocate')
                    plot_Timeline(app, 'Relocate')

                case {'PlotDataSourceChanged', 'DataBinningParameterChanged'}
                    % TRIGGER: Alteração fonte dos dados plotados ("Raw" para
                    %          "Data-Binning" e vice-versa), além de alteração
                    %          de características do Data-Binning.
                    % EFEITO : Redesenha "Distortion" e "Density".
                    plot_DistortionAndDensityPlot(app)

                case 'AddEditOrDeleteFilter'
                    % TRIGGER: Mudança na lista de filtros.
                    % EFEITO : Redesenha "Route", "Distortion" e "Density".
                    plot_Route(app)
                    plot_DistortionAndDensityPlot(app)                    
            end

            % postPLOT
            app.UIAxes3.YTick = app.UIAxes4.XTick;

            app.restoreView(3).yLim = app.UIAxes4.YLim;
            app.restoreView(4).xLim = app.UIAxes4.XLim;
            app.restoreView(4).yLim = app.UIAxes4.YLim;

            plot.axes.StackingOrder.execute(app.UIAxes1, app.bandObj.Context)
            plot.axes.StackingOrder.execute(app.UIAxes2, app.bandObj.Context)
            plot.axes.StackingOrder.execute(app.UIAxes3, app.bandObj.Context)
            plot.axes.StackingOrder.execute(app.UIAxes4, app.bandObj.Context)

            drawnow
        end

        %-----------------------------------------------------------------%
        function plot_PlaybackLoop(app, idxThread, nSweeps)
            app.tool_Play.ImageSource = 'stop_32.png';

            while app.sweepTimeIdx <= nSweeps
                switch app.plotUpdateEvent
                    case -1 % alteração de fluxo espectral
                        [idxThread, nSweeps] = plot_RecreatePlot(app);
                    case  0 % finalização do plot
                        break
                end

                sweepTic = tic;                
                plot_UpdatePlot(app, idxThread, nSweeps)
                app.tool_TimestampSlider.Value = 100 * app.sweepTimeIdx/nSweeps;

                % O pause a seguir assegura que exista responsividade no
                % app...
                pause(max(app.mainApp.play_MinPlotTime.Value/1000-toc(sweepTic), .001))

                if app.sweepTimeIdx == nSweeps
                    if strcmp(app.tool_LoopControl.Tag, 'direct')
                        break
                    end
                    app.sweepTimeIdx = 1;
                else
                    app.sweepTimeIdx = app.sweepTimeIdx+1;
                end       
            end
            
            app.tool_Play.ImageSource = 'play_32.png';
        end

        %-----------------------------------------------------------------%
        function [idxThread, nSweeps] = plot_RecreatePlot(app)
            operationType = 'EmissionSelectionChanged';
            [idxThread, idxEmission] = specDataIndex(app, operationType);
            prePlot_Startup(app, idxThread, idxEmission, operationType)

            nSweeps = numel(app.specData(idxThread).Data{1});
            app.plotUpdateEvent = 1;
        end

        %-----------------------------------------------------------------%
        function plot_UpdatePlot(app, idxThread, nSweeps)
            plot.draw2D.OrdinaryLineUpdate(app.hClearWrite, app.bandObj, idxThread, 'ClearWrite')
            plot_Car(app, 'Update')
            plot_Timeline(app, 'Update', idxThread, nSweeps)
            drawnow
        end

        %-----------------------------------------------------------------%
        % PLOTS INDIVIDUAIS
        % ToDo: MIGRAR PARA SUBPASTA PLOT
        %-----------------------------------------------------------------%
        function plot_Route(app)
            hAxes     = app.UIAxes1;
            OutTable  = app.emissionPointsTable(~app.emissionPointsTable.Filtered, :);
            InTable   = app.emissionFilteredPointsTable;

            LineStyle = app.config_route_LineStyle.Value;
            OutColor  = app.config_route_OutColor.Value;
            InColor   = app.config_route_InColor.Value;
            MarkerSize= app.config_route_Size.Value;

            plot.DriveTest.Route(hAxes, app.bandObj, OutTable, InTable, LineStyle, OutColor, InColor, MarkerSize)
        end

        %-----------------------------------------------------------------%
        function plot_DistortionAndDensityPlot(app)
            hAxes    = app.UIAxes1;
            Source   = checkDataSource(app);
            plotMode = app.UIAxes1.UserData.PlotMode;
            plotSize = app.axesTool_PlotSize.Value;

            switch Source
                case {'Raw', 'Filtered'}
                    srcTable = app.emissionFilteredPointsTable;
                case 'Data-Binning'
                    srcTable = app.emissionBinnedPointsTable;
            end

            plot.DriveTest.DistortionAndDensityPlot(hAxes, app.bandObj, srcTable, plotMode, plotSize)
        end

        %-----------------------------------------------------------------%
        function plot_FiltersController(app)
            delete(findobj([app.UIAxes1.Children; app.UIAxes4.Children], 'Tag', 'FilterROI'))

            if ~isempty(app.filterTable)
                for ii = 1:height(app.filterTable)
                    FilterSubtype = app.filterTable.subtype{ii};

                    switch FilterSubtype
                        case 'PolygonKML'
                            Latitude  = app.filterTable.roi(ii).specification.Latitude;
                            Longitude = app.filterTable.roi(ii).specification.Longitude;
                            shapeObj  = geopolyshape(Latitude, Longitude);

                            hROI = plot_FilterROIObject(app, 'DrawProgrammatically', FilterSubtype, app.UIAxes1, shapeObj);

                        otherwise
                            switch FilterSubtype                        
                                case 'Threshold'
                                    hAxes = app.UIAxes4;        
                                otherwise
                                    hAxes = app.UIAxes1;
                            end

                            hROI = plot_FilterROIObject(app, 'DrawProgrammatically', FilterSubtype, hAxes);
            
                            fieldsList = fields(app.filterTable.roi(ii).specification);
                            for jj = 1:numel(fieldsList)
                                hROI.(fieldsList{jj}) = app.filterTable.roi(ii).specification.(fieldsList{jj});
                            end
                    end
    
                    app.filterTable.roi(ii).handle = hROI;
                end
            end
        end

        %-----------------------------------------------------------------%
        function hROI = plot_FilterROIObject(app, callingFcn, FilterSubtype, hAxes, varargin)
            switch FilterSubtype
                case 'Threshold'
                    hROI = plot.ROI.draw('images.roi.Line', hAxes, {'Tag', 'FilterROI'});

                case 'PolygonKML'
                    shapeObj = varargin{1};
                    hROI = geoplot(hAxes, shapeObj, FaceColor=[0 0.4470 0.7410], ...
                                                    EdgeColor=[0 0.4470 0.7410], ...
                                                    FaceAlpha=0.05,              ...
                                                    EdgeAlpha=1,                 ...
                                                    LineWidth=2.5,               ...
                                                    PickableParts='none',        ...
                                                    Tag='FilterROI');

                otherwise
                    roiNameArgument = '';

                    switch callingFcn
                        case 'DrawInRealTime'
                            switch FilterSubtype
                                case 'Circle';     roiFcn = 'drawcircle';
                                case 'Rectangle';  roiFcn = 'drawrectangle';
                                case 'Polygon';    roiFcn = 'drawpolygon';
                            end

                        case 'DrawProgrammatically'
                            switch FilterSubtype
                                case 'Circle';     roiFcn = 'images.roi.Circle';
                                case 'Rectangle';  roiFcn = 'images.roi.Rectangle';
                                case 'Polygon';    roiFcn = 'images.roi.Polygon';
                            end
                    end

                    if strcmp(FilterSubtype, 'Rectangle')
                        roiNameArgument = 'Rotatable=true, ';
                    end

                    eval(sprintf('hROI = %s(hAxes, LineWidth=2.5, FaceAlpha=0.05, Deletable=0, FaceSelectable=0, %sTag="FilterROI");', roiFcn, roiNameArgument))
            end

            if ~strcmp(FilterSubtype, 'PolygonKML')
                addlistener(hROI, 'MovingROI',            @(~, evt)plot.axes.Interactivity.CustomROIInteractionFcn(evt, hAxes, []));
                addlistener(hROI, 'ROIMoved',             @(~, evt)plot.axes.Interactivity.CustomROIInteractionFcn(evt, hAxes, @app.filter_UpdatePlot));
                addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));
            end
        end

        %-----------------------------------------------------------------%
        function plot_PointsController(app)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'Points'))

            hAxes       = app.UIAxes1;
            MarkerStyle = app.config_points_LineStyle.Value;
            MarkerColor = app.config_points_Color.Value;
            MarkerSize  = app.config_points_Size.Value;
            plot.DriveTest.Points(hAxes, app.pointsTable, MarkerStyle, MarkerColor, MarkerSize)
            
            plot.axes.StackingOrder.execute(app.UIAxes1, 'appAnalise:DRIVETEST')
        end

        %-----------------------------------------------------------------%
        function plot_Car(app, operationType)
            switch operationType
                case 'Creation'
                    app.hCar = geoscatter(app.UIAxes1, app.emissionPointsTable.Latitude(app.sweepTimeIdx), app.emissionPointsTable.Longitude(app.sweepTimeIdx), 'filled',              ...
                                          'Marker', app.config_Car_LineStyle.Value, 'MarkerFaceColor', app.config_Car_Color.Value, 'MarkerEdgeColor', 'black', ...
                                          'SizeData', 10*app.config_Car_Size.Value, 'PickableParts', 'none', 'DisplayName', 'Veículo', 'Tag', 'Car');

                case 'Update'
                    set(app.hCar, 'LatitudeData', app.emissionPointsTable.Latitude(app.sweepTimeIdx), ...
                                  'LongitudeData', app.emissionPointsTable.Longitude(app.sweepTimeIdx))
            end
        end

        %-----------------------------------------------------------------%
        function plot_Timeline(app, operationType, varargin)
            switch operationType
                case 'Creation'
                    app.hTimeline = line(app.UIAxes3, getFrequencyScreenSpanInMHz(app, 'ScreenMaxLimits'), [app.sweepTimeIdx, app.sweepTimeIdx], ...
                                         'Color', 'red', 'Tag', 'Timeline');                
                case 'Relocate'
                    app.hTimeline.XData = getFrequencyScreenSpanInMHz(app, 'ScreenMaxLimits');
                    return
                case 'Update'
                    app.hTimeline.YData = [app.sweepTimeIdx, app.sweepTimeIdx];
            end

            idxThread = varargin{1};
            nSweeps   = varargin{2};
            app.tool_TimestampLabel.Text = sprintf('%d de %d\n%s', app.sweepTimeIdx, ...
                                                                   nSweeps,     ...
                                                                   app.specData(idxThread).Data{1}(app.sweepTimeIdx));
        end

        %-----------------------------------------------------------------%
        function plot_ChannelPower(app)
            hAxes     = app.UIAxes4;
            Color     = app.UIAxes3.Colormap(end,:);
            EdgeAlpha = app.config_chPowerEdgeAlpha.Value;
            FaceAlpha = app.config_chPowerFaceAlpha.Value;
            app.config_chPowerColor.Value = Color;

            plot.DriveTest.ChannelPower(hAxes, app.bandObj, app.emissionPointsTable, Color, EdgeAlpha, FaceAlpha)
        end

        %-----------------------------------------------------------------%
        function plot_ChannelROI(app, operationType)
            chFrequency = app.ChannelFrequency.Value;
            chBW        = app.ChannelBandWidthkHz.Value;

            switch operationType
                case 'Creation'
                    srcROITable = table(chFrequency, chBW, 'VariableNames', {'Frequency', 'BW_kHz'});
                    plot.draw2D.rectangularROI(app.UIAxes2, app.bandObj, srcROITable, 1, 'ChannelROI', {'InteractionsAllowed', 'none'}, [-1000, 1000])
                    plot.draw2D.rectangularROI(app.UIAxes3, app.bandObj, srcROITable, 1, 'ChannelROI', {'InteractionsAllowed', 'none'})

                case 'Relocate'
                    hChannelROI1 = findobj(app.UIAxes2.Children, 'Tag', 'ChannelROI');
                    hChannelROI2 = findobj(app.UIAxes3.Children, 'Tag', 'ChannelROI');

                    hChannelROI1.Position([1,3]) = [chFrequency-chBW/2000, chBW/1000];
                    hChannelROI2.Position([1,3]) = [chFrequency-chBW/2000, chBW/1000];
            end
        end

        %-----------------------------------------------------------------%
        function filter_UpdatePlot(app)
            [flowIdx, emissionIdx] = findSpecDataIndex(app);
            updateCustomProperty(app, flowIdx, emissionIdx)
            prePlot_Startup(app, flowIdx, emissionIdx, 'AddEditOrDeleteFilter')
        end

        %-----------------------------------------------------------------%
        function [flowIdx, emissionIdx] = findSpecDataIndex(app)
            flowIdx = app.SpectrumFlowList.Value;
            emissionIdx = find(strcmp(app.EmissionList.Items, app.EmissionList.Value), 1) - 1;
            if ~emissionIdx
                emissionIdx = [];
            end
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

        % Value changed function: SpectrumFlowList
        function onFlowDropDownValueChanged(app, event)
            
            flowIdx = findSpecDataIndex(app);
            updateFlowView(app, flowIdx)

        end

        % Value changed function: EmissionList
        function onEmissionDropDownValueChanged(app, event)
            
            if app.plotUpdateEvent
                app.plotUpdateEvent = -1;
            else
                updateEmissionView(app)
                % updatePlot(app)
            end

        end

        % Image clicked function: EmissionAttributesPanelLeftBtn, 
        % ...and 1 other component
        function onEmissionPanelViewChanged(app, event)
            
            numPanels = 3;

            panelSubtitles = {'Metadados', 'Filtros', 'Pontos de interesse'};
            panelBtnStatus = [false true; true true; true false];
            columnWidths = {
                {'1x',0,0,0,0,0,0,0};
                {0,10,'1x',18,10,0,0,0};
                {0,0,0,0,10,'1x',18,10};
            };

            currentIndex = app.EmissionAttributesPanelVisibleIdx.UserData.index;

            switch event.Source
                case app.EmissionAttributesPanelLeftBtn
                    step = -1;
                case app.EmissionAttributesPanelRightBtn
                    step = 1;
            end

            currentIndex = mod(currentIndex - 1 + step, numPanels) + 1;

            app.EmissionAttributesPanelLeftBtn.Enable  = panelBtnStatus(currentIndex, 1);
            app.EmissionAttributesPanelRightBtn.Enable = panelBtnStatus(currentIndex, 2);
            app.EmissionAttributesPanelVisibleIdx.Text = sprintf('%d/%d', currentIndex, numPanels);

            app.EmissionPanelGrid.ColumnWidth = columnWidths{currentIndex};

            app.EmissionPanelLabel.Text = replace(app.EmissionPanelLabel.Text, extractBetween(app.EmissionPanelLabel.Text, '<i>', '</i>'), panelSubtitles{currentIndex});
            app.EmissionAttributesPanelVisibleIdx.UserData.index = currentIndex;

        end

        % Image clicked function: tool_LayoutLeft, tool_LayoutRight
        function tool_PanelVisibilityButtonPushed(app, event)

            event.Source.UserData.status = ~event.Source.UserData.status;

            switch event.Source
                case app.tool_LayoutLeft
                    if event.Source.UserData.status
                        app.tool_LayoutLeft.ImageSource    = 'layout-sidebar-left.svg';
                        app.AxesContainer.Layout.Column(1) = 4;
                        app.AxesToolbar.Layout.Column      = 5;
                        app.LeftPanel.Visible              = 'on';
                    else
                        app.tool_LayoutLeft.ImageSource    = 'layout-sidebar-left-off.svg';
                        app.AxesContainer.Layout.Column(1) = 1;
                        app.AxesToolbar.Layout.Column      = 2;
                        app.LeftPanel.Visible              = 'off';
                    end

                case app.tool_LayoutRight
                    if event.Source.UserData.status
                        app.tool_LayoutRight.ImageSource   = 'layout-sidebar-right.svg';
                        app.AxesContainer.Layout.Column(2) = 6;
                        app.RightPanel.Visible             = 'on';
                    else
                        app.tool_LayoutRight.ImageSource   = 'layout-sidebar-right-off.svg';
                        app.AxesContainer.Layout.Column(2) = 8;
                        app.RightPanel.Visible             = 'off';
                    end
            end

        end

        % Image clicked function: tool_LoopControl, tool_Play
        function Toolbar_PlaybackControlImageClicked(app, event)
            
            switch event.Source
                case app.tool_Play
                    idxThread   = app.emissionSelectedIdxs.Thread.Index;
        
                    if idxThread && ~app.plotUpdateEvent
                        if app.mainApp.plotFlag
                            app.mainApp.plotFlag = 0;
                            app.mainApp.tool_Play.ImageSource = 'play_32.png';
                            drawnow
                        end

                        app.plotUpdateEvent = 1;

                        % O bloco try/catch evita erros decorrentes da finalização 
                        % do playback porque a lista de emissão do fluxo espectral 
                        % sob análise está vazia, decorrente de edição no appAnalise.
                        try
                            plot_PlaybackLoop(app, idxThread, numel(app.specData(idxThread).Data{1}))
                        catch
                        end

                    else
                        app.plotUpdateEvent = 0;
                    end

                %---------------------------------------------------------%
                case app.tool_LoopControl
                    switch app.tool_LoopControl.Tag
                        case 'loop';   set(app.tool_LoopControl, Tag='direct', ImageSource='playbackStraight_32Blue.png')
                        case 'direct'; set(app.tool_LoopControl, Tag='loop',   ImageSource='playbackLoop_32Blue.png')
                    end
            end

        end

        % Value changing function: tool_TimestampSlider
        function Toolbar_TimelineSliderValueChanging(app, event)
            
            idxThread = app.emissionSelectedIdxs.Thread.Index;
            nSweeps   = app.bandObj.nSweeps;
            
            app.sweepTimeIdx = round(event.Value/100 * nSweeps);
            if app.sweepTimeIdx < 1
                app.sweepTimeIdx = 1;
            elseif app.sweepTimeIdx > nSweeps
                app.sweepTimeIdx = nSweeps;
            end

            if ~app.plotUpdateEvent
                plot_UpdatePlot(app, idxThread, nSweeps)
            end

        end

        % Image clicked function: tool_DataBinningExport
        function Toolbar_ExportFileButtonPushed(app, event)
            
            nameFormatMap = {'*.zip', 'appAnalise (*.zip)'};
            Basename      = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'DriveTest', app.mainApp.report_Issue.Value);
            fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, Basename);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            dataSource = checkDataSource(app);
            hPlot      = findobj(app.UIAxes1.Children, 'Tag', 'Distortion');
            channelTag = sprintf('%.3f MHz ⌂ %.1f kHz', app.ChannelFrequency.Value, app.ChannelBandWidthkHz.Value);

            try
                msgWarning = util.exportDriveTestAnalysis(app.emissionPointsTable, app.emissionFilteredPointsTable, app.emissionBinnedPointsTable, Basename, fileFullPath, dataSource, hPlot, channelTag);
                ui.Dialog(app.UIFigure, 'info', msgWarning);
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_FilterSummary
        function Toolbar_SummaryImageClicked(app, event)
            
            ui.Dialog(app.UIFigure, 'info', app.tool_FilterSummary.UserData);

        end

        % Image clicked function: axesTool_RegionZoom, axesTool_RestoreView
        function AxesToolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    geolimits(app.UIAxes1, app.restoreView(1).xLim, app.restoreView(1).yLim)

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes1, app.axesTool_RegionZoom)
            end

        end

        % Value changed function: DataBinningFcn, DataBinningLength, 
        % ...and 1 other component
        function AxesToolbar_DataSourceChanged(app, event)

            [idxThread, idxEmission] = specDataIndex(app);

            switch event.Source
                case app.axesTool_DataSourceDropDown
                    operationType = 'PlotDataSourceChanged';
            
                    switch app.axesTool_DataSourceDropDown.Value
                        case 'Dados brutos'
                            app.axesTool_DensityPlot.Enable = 0;
                            if strcmp(app.UIAxes1.UserData.PlotMode, 'density')
                                app.UIAxes1.UserData.PlotMode = 'distortion';
                            end

                        otherwise
                            app.axesTool_DensityPlot.Enable = 1;
                    end
                    updateCustomProperty(app, idxThread, idxEmission)

                case {app.DataBinningLength, app.DataBinningFcn}
                    operationType = 'DataBinningParameterChanged';
                    updateCustomProperty(app, idxThread, idxEmission)

                    % Se o plot em evidência é o gerado pelas informações
                    % brutas (e não pela processada via Data-Binning), então 
                    % não é necessário redesenhá-lo.
                    if app.axesTool_DataSourceDropDown.Value == "Dados brutos"
                        return
                    end
            end

            prePlot_Startup(app, idxThread, idxEmission, operationType)

        end

        % Image clicked function: axesTool_DensityPlot, 
        % ...and 1 other component
        function AxesToolbar_PlotTypeValueChanged(app, event)

            hDistortion = findobj(app.UIAxes1.Children, 'Tag', 'Distortion');
            hDensity    = findobj(app.UIAxes1.Children, 'Tag', 'Density');

            switch event.Source
                %---------------------------------------------------------%
                case app.axesTool_DistortionPlot
                    if hDistortion.Visible
                        app.UIAxes1.UserData.PlotMode = 'none';
                        hDistortion.Visible = 0;
                    else
                        app.UIAxes1.UserData.PlotMode = 'distortion';
                        hDensity.Visible = 0;
                        set(hDistortion, 'Visible', 1, 'SizeData', 20*app.axesTool_PlotSize.Value)                        
                    end

                %---------------------------------------------------------%
                case app.axesTool_DensityPlot
                    if hDensity.Visible
                        app.UIAxes1.UserData.PlotMode = 'none';
                        hDensity.Visible = 0;
                    else
                        app.UIAxes1.UserData.PlotMode = 'density';
                        hDistortion.Visible = 0;
                        set(hDensity, 'Visible', 1, 'Radius', 100*app.axesTool_PlotSize.Value)
                    end
            end

            % A atualização do colorbar só é renderizada em tela quando o
            % usuário faz alguma interação com o eixo... duas possibilidades 
            % para forçar a atualização:

            % (a) Trocar "LimitsMode" para "manual" e depois para "auto". A
            %     operação é concluída em cerca de 0.461 ms.
            % (b) Chamar o método "reset", reconfigurando o eixo. A operação
            %     é concluída em cerca de 16.601 ms.

            colorBar = findobj(app.UIAxes1.Parent.Children, 'Type', 'colorbar');
            colorBar.LimitsMode = 'manual';
            colorBar.LimitsMode = 'auto';
            
            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)

        end

        % Value changed function: axesTool_PlotSize
        function AxesToolbar_PlotSizeValueChanged(app, event)

            % Como exposto em AxesToolbar_PlotSizeValueChanging(app, event),
            % o plot de distorção será atualizado em "tempo real", no 
            % "ValueChangingFcn", mas o plot de densidade apenas no callback 
            % "ValueChangedFcn".

            hDensity = findobj(app.UIAxes1.Children, 'Tag', 'Density');

            if hDensity.Visible
                set(findobj(app.UIAxes1.Children, 'Tag', 'Density'), 'Radius',  100*event.Value)
                drawnow
            end

            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)
            
        end

        % Value changing function: axesTool_PlotSize
        function AxesToolbar_PlotSizeValueChanging(app, event)
            
            % Ao interagir com o slider, não soltando o mouse, o MATLAB dispara 
            % apenas o evento "ValueChangingFcn". Ao soltar o botão do mouse, o 
            % MATLAB dispara, nesta ordem, os eventos "ValueChangingFcn" e 
            % "ValueChangedFcn".

            % Nesse contexto, considerando que o plot de densidade demora
            % para atualizar, o plot de distorção será atualizado em "tempo
            % real", no "ValueChangingFcn", mas o plot de densidade apenas 
            % no callback "ValueChangedFcn".

            hDistortion = findobj(app.UIAxes1.Children, 'Tag', 'Distortion');

            if hDistortion.Visible
                set(findobj(app.UIAxes1.Children, 'Tag', 'Distortion'), 'SizeData', 20*event.Value)
            end
            
        end

        % Menu selected function: DeleteAllEntries, DeleteSelectedItem
        function onContextMenuItemClicked(app, event)
            
            switch event.ContextObject
                case app.FilterTree
                    referenceTable = app.filterTable;
                    buildTreeFcn   = @buildFilterTree;
                case app.PointsTree
                    referenceTable = app.pointsTable;
                    buildTreeFcn   = @buildPointsTree;
            end

            if isempty(referenceTable)
                return
            end

            switch event.Source
                case app.DeleteSelectedItem
                    if isempty(event.ContextObject.SelectedNodes)
                        return
                    end
                    idx = arrayfun(@(x) x.NodeData, event.ContextObject.SelectedNodes);

                case app.DeleteAllEntries
                    idx = 1:height(referenceTable);
            end 
    
            if ~isempty(idx)
                arrayfun(@(x) delete(x), [app.filterTable.roi(idx).handle]); 
                app.referenceTable(idx,:) = [];

                buildTreeFcn(app)
            end

        end

        % Selection changed function: FilterTree
        function FilterTreeSelectionChanged(app, event)
            
            if ~isempty(app.FilterTree.SelectedNodes) && all(isvalid([app.filterTable.roi.handle]))
                idxFilter = app.FilterTree.SelectedNodes.NodeData;        
    
                for ii = 1:height(app.filterTable)
                    hROI = app.filterTable.roi(ii).handle;
                    hROIClass = class(hROI);

                    switch hROIClass
                        case 'map.graphics.chart.primitive.Polygon'
                            if ii ~= idxFilter
                                hROI.LineWidth = .5;
                            else
                                hROI.LineWidth = 2.5;
                            end

                        otherwise
                            if ii ~= idxFilter
                                set(hROI, LineWidth=.5, InteractionsAllowed='none')
                            else
                                switch hROIClass
                                    case 'images.roi.Line'
                                        set(hROI, LineWidth=2.5, InteractionsAllowed='translate')
                                    otherwise
                                        set(hROI, LineWidth=2.5, InteractionsAllowed='all')
                                end
                            end
                    end
                end
                uistack(app.filterTable.roi(idxFilter).handle, "top")
            end
            
        end

        % Callback function: PointsTree
        function PointsTreeCheckedNodesChanged(app, event)
            
            visibleNodeData   = arrayfun(@(x) x.NodeData, app.PointsTree.CheckedNodes);
            invisibleNodeData = setdiff(1:height(app.pointsTable), visibleNodeData);

            app.pointsTable.visible(visibleNodeData)   = true;
            app.pointsTable.visible(invisibleNodeData) = false;

            plot_PointsController(app)
            
        end

        % Image clicked function: FilterTreeButton
        function FilterTreeButtonImageClicked(app, event)
            
        end

        % Image clicked function: PointsTreeButton
        function PointsTreeButtonImageClicked(app, event)
            
        end

        % Image clicked function: axesTool_DensityPlot_2
        function axesTool_DensityPlot_2ImageClicked(app, event)
            
            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RepoFiles', app.Context)

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
            app.GridLayout.ColumnWidth = {10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 233, 196, '1x', 22, 22, 5, 22};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_LayoutLeft
            app.tool_LayoutLeft = uiimage(app.Toolbar);
            app.tool_LayoutLeft.ScaleMethod = 'none';
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @tool_PanelVisibilityButtonPushed, true);
            app.tool_LayoutLeft.Layout.Row = [1 3];
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 2;
            app.tool_Separator.VerticalAlignment = 'bottom';
            app.tool_Separator.ImageSource = 'LineV.svg';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PlaybackControlImageClicked, true);
            app.tool_LoopControl.Enable = 'off';
            app.tool_LoopControl.Layout.Row = [1 3];
            app.tool_LoopControl.Layout.Column = 4;
            app.tool_LoopControl.ImageSource = 'playback-loop-36px-gray.png';

            % Create tool_TimestampSlider
            app.tool_TimestampSlider = uislider(app.Toolbar);
            app.tool_TimestampSlider.MajorTicks = [0 50 100];
            app.tool_TimestampSlider.MajorTickLabels = {'0', '50', '100'};
            app.tool_TimestampSlider.ValueChangingFcn = createCallbackFcn(app, @Toolbar_TimelineSliderValueChanging, true);
            app.tool_TimestampSlider.MinorTicks = [0 2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30 32.5 35 37.5 40 42.5 45 47.5 50 52.5 55 57.5 60 62.5 65 67.5 70 72.5 75 77.5 80 82.5 85 87.5 90 92.5 95 97.5 100];
            app.tool_TimestampSlider.FontSize = 8;
            app.tool_TimestampSlider.Enable = 'off';
            app.tool_TimestampSlider.Layout.Row = 2;
            app.tool_TimestampSlider.Layout.Column = 5;

            % Create tool_TimestampLabel
            app.tool_TimestampLabel = uilabel(app.Toolbar);
            app.tool_TimestampLabel.WordWrap = 'on';
            app.tool_TimestampLabel.FontSize = 10;
            app.tool_TimestampLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.tool_TimestampLabel.Layout.Row = [1 3];
            app.tool_TimestampLabel.Layout.Column = 6;
            app.tool_TimestampLabel.Text = {'0 de 0'; '00/00/0000 00:00:00'};

            % Create tool_Play
            app.tool_Play = uiimage(app.Toolbar);
            app.tool_Play.ScaleMethod = 'none';
            app.tool_Play.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PlaybackControlImageClicked, true);
            app.tool_Play.Enable = 'off';
            app.tool_Play.Layout.Row = [1 3];
            app.tool_Play.Layout.Column = 3;
            app.tool_Play.ImageSource = 'playback-play-16px-gray.png';

            % Create tool_DataBinningExport
            app.tool_DataBinningExport = uiimage(app.Toolbar);
            app.tool_DataBinningExport.ScaleMethod = 'none';
            app.tool_DataBinningExport.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ExportFileButtonPushed, true);
            app.tool_DataBinningExport.Enable = 'off';
            app.tool_DataBinningExport.Layout.Row = [1 3];
            app.tool_DataBinningExport.Layout.Column = 8;
            app.tool_DataBinningExport.ImageSource = 'Export_16.png';

            % Create tool_FilterSummary
            app.tool_FilterSummary = uiimage(app.Toolbar);
            app.tool_FilterSummary.ImageClickedFcn = createCallbackFcn(app, @Toolbar_SummaryImageClicked, true);
            app.tool_FilterSummary.Enable = 'off';
            app.tool_FilterSummary.Layout.Row = [1 3];
            app.tool_FilterSummary.Layout.Column = 9;
            app.tool_FilterSummary.ImageSource = 'Info_32.png';

            % Create tool_Separator3
            app.tool_Separator3 = uiimage(app.Toolbar);
            app.tool_Separator3.ScaleMethod = 'none';
            app.tool_Separator3.Enable = 'off';
            app.tool_Separator3.Layout.Row = [1 3];
            app.tool_Separator3.Layout.Column = 10;
            app.tool_Separator3.VerticalAlignment = 'bottom';
            app.tool_Separator3.ImageSource = 'LineV.svg';

            % Create tool_LayoutRight
            app.tool_LayoutRight = uiimage(app.Toolbar);
            app.tool_LayoutRight.ScaleMethod = 'none';
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @tool_PanelVisibilityButtonPushed, true);
            app.tool_LayoutRight.Layout.Row = [1 3];
            app.tool_LayoutRight.Layout.Column = 11;
            app.tool_LayoutRight.ImageSource = 'layout-sidebar-right-off.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {5, 315, 10, 5, 315, '1x', 10, 232};
            app.Document.RowHeight = {24, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [2 3];
            app.Document.BackgroundColor = [1 1 1];

            % Create LeftPanel
            app.LeftPanel = uigridlayout(app.Document);
            app.LeftPanel.ColumnWidth = {'1x', 18, 10, 18};
            app.LeftPanel.RowHeight = {44, 30, 30, '1x'};
            app.LeftPanel.ColumnSpacing = 5;
            app.LeftPanel.RowSpacing = 5;
            app.LeftPanel.Padding = [0 0 0 0];
            app.LeftPanel.Layout.Row = [1 2];
            app.LeftPanel.Layout.Column = [1 2];
            app.LeftPanel.BackgroundColor = [1 1 1];

            % Create SpectrumFlowList
            app.SpectrumFlowList = uidropdown(app.LeftPanel);
            app.SpectrumFlowList.Items = {};
            app.SpectrumFlowList.ValueChangedFcn = createCallbackFcn(app, @onFlowDropDownValueChanged, true);
            app.SpectrumFlowList.FontSize = 11;
            app.SpectrumFlowList.FontColor = [1 1 1];
            app.SpectrumFlowList.BackgroundColor = [0.7176 0.1922 0.1725];
            app.SpectrumFlowList.Layout.Row = 1;
            app.SpectrumFlowList.Layout.Column = [1 4];
            app.SpectrumFlowList.Value = {};

            % Create EmissionPanelLabel
            app.EmissionPanelLabel = uilabel(app.LeftPanel);
            app.EmissionPanelLabel.FontSize = 10;
            app.EmissionPanelLabel.Layout.Row = 3;
            app.EmissionPanelLabel.Layout.Column = 1;
            app.EmissionPanelLabel.Interpreter = 'html';
            app.EmissionPanelLabel.Text = 'ATRIBUTOS DA EMISSÃO<br><font style="font-size: 11px;"><i>Metadados</i></font>';

            % Create EmissionAttributesPanelVisibleIdx
            app.EmissionAttributesPanelVisibleIdx = uilabel(app.LeftPanel);
            app.EmissionAttributesPanelVisibleIdx.HorizontalAlignment = 'center';
            app.EmissionAttributesPanelVisibleIdx.FontSize = 10;
            app.EmissionAttributesPanelVisibleIdx.FontColor = [0.502 0.502 0.502];
            app.EmissionAttributesPanelVisibleIdx.Layout.Row = 3;
            app.EmissionAttributesPanelVisibleIdx.Layout.Column = [2 4];
            app.EmissionAttributesPanelVisibleIdx.Text = '1/3';

            % Create EmissionAttributesPanelLeftBtn
            app.EmissionAttributesPanelLeftBtn = uiimage(app.LeftPanel);
            app.EmissionAttributesPanelLeftBtn.ImageClickedFcn = createCallbackFcn(app, @onEmissionPanelViewChanged, true);
            app.EmissionAttributesPanelLeftBtn.Enable = 'off';
            app.EmissionAttributesPanelLeftBtn.Layout.Row = 3;
            app.EmissionAttributesPanelLeftBtn.Layout.Column = 2;
            app.EmissionAttributesPanelLeftBtn.ImageSource = 'triangle-left.svg';

            % Create EmissionAttributesPanelRightBtn
            app.EmissionAttributesPanelRightBtn = uiimage(app.LeftPanel);
            app.EmissionAttributesPanelRightBtn.ImageClickedFcn = createCallbackFcn(app, @onEmissionPanelViewChanged, true);
            app.EmissionAttributesPanelRightBtn.Layout.Row = 3;
            app.EmissionAttributesPanelRightBtn.Layout.Column = 4;
            app.EmissionAttributesPanelRightBtn.ImageSource = 'triangle-right.svg';

            % Create EmissionPanel
            app.EmissionPanel = uipanel(app.LeftPanel);
            app.EmissionPanel.AutoResizeChildren = 'off';
            app.EmissionPanel.Layout.Row = 4;
            app.EmissionPanel.Layout.Column = [1 4];

            % Create EmissionPanelGrid
            app.EmissionPanelGrid = uigridlayout(app.EmissionPanel);
            app.EmissionPanelGrid.ColumnWidth = {'1x', 0, 0, 0, 0, 0, 0, 0};
            app.EmissionPanelGrid.RowHeight = {10, 22, 22, 5, 78, 10, 22, 22, 5, '1x', 10};
            app.EmissionPanelGrid.ColumnSpacing = 0;
            app.EmissionPanelGrid.RowSpacing = 0;
            app.EmissionPanelGrid.Padding = [0 0 0 0];
            app.EmissionPanelGrid.BackgroundColor = [1 1 1];

            % Create EmissionMetadata
            app.EmissionMetadata = uilabel(app.EmissionPanelGrid);
            app.EmissionMetadata.VerticalAlignment = 'top';
            app.EmissionMetadata.WordWrap = 'on';
            app.EmissionMetadata.FontSize = 11;
            app.EmissionMetadata.Layout.Row = [1 11];
            app.EmissionMetadata.Layout.Column = 1;
            app.EmissionMetadata.Interpreter = 'html';
            app.EmissionMetadata.Text = '';

            % Create DataBinningLabel
            app.DataBinningLabel = uilabel(app.EmissionPanelGrid);
            app.DataBinningLabel.VerticalAlignment = 'top';
            app.DataBinningLabel.WordWrap = 'on';
            app.DataBinningLabel.FontSize = 10;
            app.DataBinningLabel.Layout.Row = [2 3];
            app.DataBinningLabel.Layout.Column = [3 4];
            app.DataBinningLabel.Interpreter = 'html';
            app.DataBinningLabel.Text = {'DATA-BINNING'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Agrupa medições em quadrículas, sumarizando-as por meio de função estatística.</p>'};

            % Create DataBinningPanel
            app.DataBinningPanel = uipanel(app.EmissionPanelGrid);
            app.DataBinningPanel.AutoResizeChildren = 'off';
            app.DataBinningPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataBinningPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.DataBinningPanel.Layout.Row = 5;
            app.DataBinningPanel.Layout.Column = [3 4];

            % Create DataBinningGrid
            app.DataBinningGrid = uigridlayout(app.DataBinningPanel);
            app.DataBinningGrid.ColumnWidth = {110, '1x'};
            app.DataBinningGrid.RowHeight = {'1x', 22};
            app.DataBinningGrid.RowSpacing = 5;
            app.DataBinningGrid.BackgroundColor = [1 1 1];

            % Create DataBinningLengthLabel
            app.DataBinningLengthLabel = uilabel(app.DataBinningGrid);
            app.DataBinningLengthLabel.VerticalAlignment = 'bottom';
            app.DataBinningLengthLabel.WordWrap = 'on';
            app.DataBinningLengthLabel.FontSize = 11;
            app.DataBinningLengthLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataBinningLengthLabel.Layout.Row = 1;
            app.DataBinningLengthLabel.Layout.Column = 1;
            app.DataBinningLengthLabel.Interpreter = 'html';
            app.DataBinningLengthLabel.Text = {'Comprimento '; 'quadrícula (metros):'};

            % Create DataBinningLength
            app.DataBinningLength = uispinner(app.DataBinningGrid);
            app.DataBinningLength.Step = 50;
            app.DataBinningLength.Limits = [50 1500];
            app.DataBinningLength.RoundFractionalValues = 'on';
            app.DataBinningLength.ValueDisplayFormat = '%.0f';
            app.DataBinningLength.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_DataSourceChanged, true);
            app.DataBinningLength.FontSize = 11;
            app.DataBinningLength.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataBinningLength.Layout.Row = 2;
            app.DataBinningLength.Layout.Column = 1;
            app.DataBinningLength.Value = 100;

            % Create DataBinningFcnLabel
            app.DataBinningFcnLabel = uilabel(app.DataBinningGrid);
            app.DataBinningFcnLabel.VerticalAlignment = 'bottom';
            app.DataBinningFcnLabel.WordWrap = 'on';
            app.DataBinningFcnLabel.FontSize = 11;
            app.DataBinningFcnLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataBinningFcnLabel.Layout.Row = 1;
            app.DataBinningFcnLabel.Layout.Column = 2;
            app.DataBinningFcnLabel.Text = {'Função'; 'estatística:'};

            % Create DataBinningFcn
            app.DataBinningFcn = uidropdown(app.DataBinningGrid);
            app.DataBinningFcn.Items = {'min', 'mean', 'median', 'rms', 'max'};
            app.DataBinningFcn.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_DataSourceChanged, true);
            app.DataBinningFcn.FontSize = 11;
            app.DataBinningFcn.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataBinningFcn.BackgroundColor = [1 1 1];
            app.DataBinningFcn.Layout.Row = 2;
            app.DataBinningFcn.Layout.Column = 2;
            app.DataBinningFcn.Value = 'rms';

            % Create FilterTreeLabel
            app.FilterTreeLabel = uilabel(app.EmissionPanelGrid);
            app.FilterTreeLabel.VerticalAlignment = 'top';
            app.FilterTreeLabel.WordWrap = 'on';
            app.FilterTreeLabel.FontSize = 10;
            app.FilterTreeLabel.Layout.Row = [7 9];
            app.FilterTreeLabel.Layout.Column = [3 4];
            app.FilterTreeLabel.Interpreter = 'html';
            app.FilterTreeLabel.Text = {'FILTRAGEM DE DADOS'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Remove medições com base em critérios de nível de sinal e localização geográfica.</p>'};

            % Create FilterTreeButton
            app.FilterTreeButton = uiimage(app.EmissionPanelGrid);
            app.FilterTreeButton.ImageClickedFcn = createCallbackFcn(app, @FilterTreeButtonImageClicked, true);
            app.FilterTreeButton.Enable = 'off';
            app.FilterTreeButton.Layout.Row = 8;
            app.FilterTreeButton.Layout.Column = 4;
            app.FilterTreeButton.VerticalAlignment = 'bottom';
            app.FilterTreeButton.ImageSource = 'Edit_32.png';

            % Create FilterTree
            app.FilterTree = uitree(app.EmissionPanelGrid);
            app.FilterTree.SelectionChangedFcn = createCallbackFcn(app, @FilterTreeSelectionChanged, true);
            app.FilterTree.FontSize = 10.5;
            app.FilterTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTree.Layout.Row = 10;
            app.FilterTree.Layout.Column = [3 4];

            % Create PointsTreeLabel
            app.PointsTreeLabel = uilabel(app.EmissionPanelGrid);
            app.PointsTreeLabel.VerticalAlignment = 'top';
            app.PointsTreeLabel.WordWrap = 'on';
            app.PointsTreeLabel.FontSize = 10;
            app.PointsTreeLabel.Layout.Row = [2 3];
            app.PointsTreeLabel.Layout.Column = [6 7];
            app.PointsTreeLabel.Interpreter = 'html';
            app.PointsTreeLabel.Text = {'PONTOS DE INTERESSE'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Destaca locais relevantes, como máximos de potência e estações de telecomunicações.</p>'};

            % Create PointsTreeButton
            app.PointsTreeButton = uiimage(app.EmissionPanelGrid);
            app.PointsTreeButton.ImageClickedFcn = createCallbackFcn(app, @PointsTreeButtonImageClicked, true);
            app.PointsTreeButton.Enable = 'off';
            app.PointsTreeButton.Layout.Row = 3;
            app.PointsTreeButton.Layout.Column = 7;
            app.PointsTreeButton.VerticalAlignment = 'bottom';
            app.PointsTreeButton.ImageSource = 'Edit_32.png';

            % Create PointsTree
            app.PointsTree = uitree(app.EmissionPanelGrid, 'checkbox');
            app.PointsTree.FontSize = 10.5;
            app.PointsTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PointsTree.Layout.Row = [5 10];
            app.PointsTree.Layout.Column = [6 7];

            % Assign Checked Nodes
            app.PointsTree.CheckedNodesChangedFcn = createCallbackFcn(app, @PointsTreeCheckedNodesChanged, true);

            % Create EmissionList
            app.EmissionList = uidropdown(app.LeftPanel);
            app.EmissionList.Items = {};
            app.EmissionList.ValueChangedFcn = createCallbackFcn(app, @onEmissionDropDownValueChanged, true);
            app.EmissionList.FontSize = 11;
            app.EmissionList.FontColor = [1 1 1];
            app.EmissionList.BackgroundColor = [0.2 0.2 0.2];
            app.EmissionList.Layout.Row = 2;
            app.EmissionList.Layout.Column = [1 4];
            app.EmissionList.Value = {};

            % Create RightPanel
            app.RightPanel = uigridlayout(app.Document);
            app.RightPanel.ColumnWidth = {18, '1x', 18};
            app.RightPanel.RowHeight = {5, 17, 5, 208, 5, 5, 17, 5, '1x'};
            app.RightPanel.ColumnSpacing = 5;
            app.RightPanel.RowSpacing = 0;
            app.RightPanel.Padding = [0 0 0 0];
            app.RightPanel.Visible = 'off';
            app.RightPanel.Layout.Row = [1 2];
            app.RightPanel.Layout.Column = 8;
            app.RightPanel.BackgroundColor = [1 1 1];

            % Create GeographicAxesPanelIcon
            app.GeographicAxesPanelIcon = uiimage(app.RightPanel);
            app.GeographicAxesPanelIcon.Layout.Row = [1 3];
            app.GeographicAxesPanelIcon.Layout.Column = 1;
            app.GeographicAxesPanelIcon.ImageSource = 'DriveTestDensity_32.png';

            % Create GeographicAxesPanelLabel
            app.GeographicAxesPanelLabel = uilabel(app.RightPanel);
            app.GeographicAxesPanelLabel.VerticalAlignment = 'bottom';
            app.GeographicAxesPanelLabel.FontSize = 10;
            app.GeographicAxesPanelLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.GeographicAxesPanelLabel.Layout.Row = 2;
            app.GeographicAxesPanelLabel.Layout.Column = 2;
            app.GeographicAxesPanelLabel.Text = 'EIXO GEOGRÁFICO';

            % Create GeographicAxesPanel
            app.GeographicAxesPanel = uipanel(app.RightPanel);
            app.GeographicAxesPanel.AutoResizeChildren = 'off';
            app.GeographicAxesPanel.BackgroundColor = [1 1 1];
            app.GeographicAxesPanel.Layout.Row = 4;
            app.GeographicAxesPanel.Layout.Column = [1 3];

            % Create GeographicAxesPanelGrid
            app.GeographicAxesPanelGrid = uigridlayout(app.GeographicAxesPanel);
            app.GeographicAxesPanelGrid.ColumnWidth = {'1x', 36, 36, 54};
            app.GeographicAxesPanelGrid.RowHeight = {17, 22, 17, 22, 17, 22, 17, 22};
            app.GeographicAxesPanelGrid.RowSpacing = 5;
            app.GeographicAxesPanelGrid.Padding = [10 10 10 5];
            app.GeographicAxesPanelGrid.BackgroundColor = [1 1 1];

            % Create config_route_Size
            app.config_route_Size = uislider(app.GeographicAxesPanelGrid);
            app.config_route_Size.Limits = [1 9];
            app.config_route_Size.MajorTicks = [];
            app.config_route_Size.MinorTicks = [1 2.6 4.2 5.8 7.4 9];
            app.config_route_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_route_Size.Tooltip = {'Tamanho do marcador'};
            app.config_route_Size.Layout.Row = 4;
            app.config_route_Size.Layout.Column = 4;
            app.config_route_Size.Value = 1;

            % Create config_route_InColor
            app.config_route_InColor = uicolorpicker(app.GeographicAxesPanelGrid);
            app.config_route_InColor.Value = [0.8706 0.5412 0.5412];
            app.config_route_InColor.Layout.Row = 4;
            app.config_route_InColor.Layout.Column = 3;
            app.config_route_InColor.BackgroundColor = [1 1 1];

            % Create config_route_OutColor
            app.config_route_OutColor = uicolorpicker(app.GeographicAxesPanelGrid);
            app.config_route_OutColor.Value = [0.502 0.502 0.502];
            app.config_route_OutColor.Layout.Row = 4;
            app.config_route_OutColor.Layout.Column = 2;
            app.config_route_OutColor.BackgroundColor = [1 1 1];

            % Create config_route_LineStyle
            app.config_route_LineStyle = uidropdown(app.GeographicAxesPanelGrid);
            app.config_route_LineStyle.Items = {'none', ':', '-'};
            app.config_route_LineStyle.FontSize = 11;
            app.config_route_LineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_route_LineStyle.BackgroundColor = [1 1 1];
            app.config_route_LineStyle.Layout.Row = 4;
            app.config_route_LineStyle.Layout.Column = 1;
            app.config_route_LineStyle.Value = 'none';

            % Create config_route_Label
            app.config_route_Label = uilabel(app.GeographicAxesPanelGrid);
            app.config_route_Label.VerticalAlignment = 'bottom';
            app.config_route_Label.FontSize = 11;
            app.config_route_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_route_Label.Layout.Row = 3;
            app.config_route_Label.Layout.Column = [1 2];
            app.config_route_Label.Text = 'Rota:';

            % Create config_Car_Label
            app.config_Car_Label = uilabel(app.GeographicAxesPanelGrid);
            app.config_Car_Label.VerticalAlignment = 'bottom';
            app.config_Car_Label.FontSize = 11;
            app.config_Car_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Car_Label.Layout.Row = 5;
            app.config_Car_Label.Layout.Column = [1 2];
            app.config_Car_Label.Text = 'Veículo:';

            % Create config_Car_LineStyle
            app.config_Car_LineStyle = uidropdown(app.GeographicAxesPanelGrid);
            app.config_Car_LineStyle.Items = {'none', 'o', 'square', '^'};
            app.config_Car_LineStyle.FontSize = 11;
            app.config_Car_LineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Car_LineStyle.BackgroundColor = [1 1 1];
            app.config_Car_LineStyle.Layout.Row = 6;
            app.config_Car_LineStyle.Layout.Column = [1 2];
            app.config_Car_LineStyle.Value = 'none';

            % Create config_Car_Color
            app.config_Car_Color = uicolorpicker(app.GeographicAxesPanelGrid);
            app.config_Car_Color.Layout.Row = 6;
            app.config_Car_Color.Layout.Column = 3;
            app.config_Car_Color.BackgroundColor = [1 1 1];

            % Create config_Car_Size
            app.config_Car_Size = uislider(app.GeographicAxesPanelGrid);
            app.config_Car_Size.Limits = [1 19];
            app.config_Car_Size.MajorTicks = [];
            app.config_Car_Size.MinorTicks = [1 4.6 8.2 11.8 15.4 19];
            app.config_Car_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Car_Size.Tooltip = {'Tamanho do marcador'};
            app.config_Car_Size.Layout.Row = 6;
            app.config_Car_Size.Layout.Column = 4;
            app.config_Car_Size.Value = 10;

            % Create config_points_Label
            app.config_points_Label = uilabel(app.GeographicAxesPanelGrid);
            app.config_points_Label.VerticalAlignment = 'bottom';
            app.config_points_Label.FontSize = 11;
            app.config_points_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_points_Label.Layout.Row = 7;
            app.config_points_Label.Layout.Column = [1 3];
            app.config_points_Label.Text = 'Pontos de interesse:';

            % Create config_points_LineStyle
            app.config_points_LineStyle = uidropdown(app.GeographicAxesPanelGrid);
            app.config_points_LineStyle.Items = {'none', 'o', 'square', '^'};
            app.config_points_LineStyle.FontSize = 11;
            app.config_points_LineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_points_LineStyle.BackgroundColor = [1 1 1];
            app.config_points_LineStyle.Layout.Row = 8;
            app.config_points_LineStyle.Layout.Column = [1 2];
            app.config_points_LineStyle.Value = 'none';

            % Create config_points_Color
            app.config_points_Color = uicolorpicker(app.GeographicAxesPanelGrid);
            app.config_points_Color.Value = [0 0 0];
            app.config_points_Color.Layout.Row = 8;
            app.config_points_Color.Layout.Column = 3;
            app.config_points_Color.BackgroundColor = [1 1 1];

            % Create config_points_Size
            app.config_points_Size = uislider(app.GeographicAxesPanelGrid);
            app.config_points_Size.Limits = [6 12];
            app.config_points_Size.MajorTicks = [];
            app.config_points_Size.MinorTicks = [6 7 8 9 10 11 12];
            app.config_points_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_points_Size.Tooltip = {'Tamanho do marcador'};
            app.config_points_Size.Layout.Row = 8;
            app.config_points_Size.Layout.Column = 4;
            app.config_points_Size.Value = 9;

            % Create config_BasemapLabel
            app.config_BasemapLabel = uilabel(app.GeographicAxesPanelGrid);
            app.config_BasemapLabel.VerticalAlignment = 'bottom';
            app.config_BasemapLabel.FontSize = 11;
            app.config_BasemapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BasemapLabel.Layout.Row = 1;
            app.config_BasemapLabel.Layout.Column = [3 4];
            app.config_BasemapLabel.Text = 'Mapa base:';

            % Create config_Basemap
            app.config_Basemap = uidropdown(app.GeographicAxesPanelGrid);
            app.config_Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.config_Basemap.FontSize = 11;
            app.config_Basemap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Basemap.BackgroundColor = [1 1 1];
            app.config_Basemap.Layout.Row = 2;
            app.config_Basemap.Layout.Column = [3 4];
            app.config_Basemap.Value = 'none';

            % Create config_ColormapLabel
            app.config_ColormapLabel = uilabel(app.GeographicAxesPanelGrid);
            app.config_ColormapLabel.VerticalAlignment = 'bottom';
            app.config_ColormapLabel.FontSize = 11;
            app.config_ColormapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ColormapLabel.Layout.Row = 1;
            app.config_ColormapLabel.Layout.Column = [1 2];
            app.config_ColormapLabel.Text = 'Mapa de cor:';

            % Create config_Colormap
            app.config_Colormap = uidropdown(app.GeographicAxesPanelGrid);
            app.config_Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.config_Colormap.FontSize = 11;
            app.config_Colormap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Colormap.BackgroundColor = [1 1 1];
            app.config_Colormap.Layout.Row = 2;
            app.config_Colormap.Layout.Column = [1 2];
            app.config_Colormap.Value = 'winter';

            % Create CartesianAxesPanelIcon
            app.CartesianAxesPanelIcon = uiimage(app.RightPanel);
            app.CartesianAxesPanelIcon.Layout.Row = [6 8];
            app.CartesianAxesPanelIcon.Layout.Column = 1;
            app.CartesianAxesPanelIcon.ImageSource = 'DriveTestRouteOFF_32.png';

            % Create CartesianAxesPanelLabel
            app.CartesianAxesPanelLabel = uilabel(app.RightPanel);
            app.CartesianAxesPanelLabel.VerticalAlignment = 'bottom';
            app.CartesianAxesPanelLabel.FontSize = 10;
            app.CartesianAxesPanelLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.CartesianAxesPanelLabel.Layout.Row = 7;
            app.CartesianAxesPanelLabel.Layout.Column = 2;
            app.CartesianAxesPanelLabel.Text = 'EIXOS CARTESIANOS';

            % Create CartesianAxesPanel
            app.CartesianAxesPanel = uipanel(app.RightPanel);
            app.CartesianAxesPanel.AutoResizeChildren = 'off';
            app.CartesianAxesPanel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.CartesianAxesPanel.Layout.Row = 9;
            app.CartesianAxesPanel.Layout.Column = [1 3];

            % Create CartesianAxesGrid
            app.CartesianAxesGrid = uigridlayout(app.CartesianAxesPanel);
            app.CartesianAxesGrid.ColumnWidth = {'1x', 36, 48, 48};
            app.CartesianAxesGrid.RowHeight = {18, 22, 36, 22, 36, 22, 22, 22};
            app.CartesianAxesGrid.RowSpacing = 5;
            app.CartesianAxesGrid.Padding = [10 10 10 5];
            app.CartesianAxesGrid.BackgroundColor = [1 1 1];

            % Create config_PersistanceLabel
            app.config_PersistanceLabel = uilabel(app.CartesianAxesGrid);
            app.config_PersistanceLabel.VerticalAlignment = 'bottom';
            app.config_PersistanceLabel.FontSize = 11;
            app.config_PersistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_PersistanceLabel.Layout.Row = 1;
            app.config_PersistanceLabel.Layout.Column = [1 3];
            app.config_PersistanceLabel.Text = 'Persistência:';

            % Create config_PersistanceVisibility
            app.config_PersistanceVisibility = uidropdown(app.CartesianAxesGrid);
            app.config_PersistanceVisibility.Items = {'on', 'off'};
            app.config_PersistanceVisibility.Tooltip = {''};
            app.config_PersistanceVisibility.FontSize = 11;
            app.config_PersistanceVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_PersistanceVisibility.BackgroundColor = [1 1 1];
            app.config_PersistanceVisibility.Layout.Row = 2;
            app.config_PersistanceVisibility.Layout.Column = 1;
            app.config_PersistanceVisibility.Value = 'on';

            % Create config_chROILabel
            app.config_chROILabel = uilabel(app.CartesianAxesGrid);
            app.config_chROILabel.VerticalAlignment = 'bottom';
            app.config_chROILabel.FontSize = 11;
            app.config_chROILabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROILabel.Layout.Row = 3;
            app.config_chROILabel.Layout.Column = [1 4];
            app.config_chROILabel.Interpreter = 'html';
            app.config_chROILabel.Text = 'Canal:<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Visibilidade e estilo de exibição.</p>';

            % Create config_chROIVisibility
            app.config_chROIVisibility = uidropdown(app.CartesianAxesGrid);
            app.config_chROIVisibility.Items = {'on', 'off'};
            app.config_chROIVisibility.Tooltip = {''};
            app.config_chROIVisibility.FontSize = 11;
            app.config_chROIVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROIVisibility.BackgroundColor = [1 1 1];
            app.config_chROIVisibility.Layout.Row = 4;
            app.config_chROIVisibility.Layout.Column = 1;
            app.config_chROIVisibility.Value = 'on';

            % Create config_chROIColor
            app.config_chROIColor = uicolorpicker(app.CartesianAxesGrid);
            app.config_chROIColor.Value = [0.7216 0.2706 1];
            app.config_chROIColor.Tooltip = {''};
            app.config_chROIColor.Layout.Row = 4;
            app.config_chROIColor.Layout.Column = 2;
            app.config_chROIColor.BackgroundColor = [1 1 1];

            % Create config_chROIEdgeAlpha
            app.config_chROIEdgeAlpha = uispinner(app.CartesianAxesGrid);
            app.config_chROIEdgeAlpha.Step = 0.1;
            app.config_chROIEdgeAlpha.Limits = [0 1];
            app.config_chROIEdgeAlpha.ValueDisplayFormat = '%.1f';
            app.config_chROIEdgeAlpha.FontSize = 11;
            app.config_chROIEdgeAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROIEdgeAlpha.Tooltip = {'Transparência da margem'};
            app.config_chROIEdgeAlpha.Layout.Row = 4;
            app.config_chROIEdgeAlpha.Layout.Column = 3;

            % Create config_chROIFaceAlpha
            app.config_chROIFaceAlpha = uispinner(app.CartesianAxesGrid);
            app.config_chROIFaceAlpha.Step = 0.1;
            app.config_chROIFaceAlpha.Limits = [0 1];
            app.config_chROIFaceAlpha.ValueDisplayFormat = '%.1f';
            app.config_chROIFaceAlpha.FontSize = 11;
            app.config_chROIFaceAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROIFaceAlpha.Tooltip = {'Transparência da face'};
            app.config_chROIFaceAlpha.Layout.Row = 4;
            app.config_chROIFaceAlpha.Layout.Column = 4;
            app.config_chROIFaceAlpha.Value = 0.4;

            % Create config_chPowerLabel
            app.config_chPowerLabel = uilabel(app.CartesianAxesGrid);
            app.config_chPowerLabel.VerticalAlignment = 'bottom';
            app.config_chPowerLabel.FontSize = 11;
            app.config_chPowerLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerLabel.Layout.Row = 5;
            app.config_chPowerLabel.Layout.Column = [1 4];
            app.config_chPowerLabel.Interpreter = 'html';
            app.config_chPowerLabel.Text = 'Potência do canal:<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Visibilidade e estilo de exibição.</p>';

            % Create config_chPowerVisibility
            app.config_chPowerVisibility = uidropdown(app.CartesianAxesGrid);
            app.config_chPowerVisibility.Items = {'on', 'off'};
            app.config_chPowerVisibility.Tooltip = {''};
            app.config_chPowerVisibility.FontSize = 11;
            app.config_chPowerVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerVisibility.BackgroundColor = [1 1 1];
            app.config_chPowerVisibility.Layout.Row = 6;
            app.config_chPowerVisibility.Layout.Column = 1;
            app.config_chPowerVisibility.Value = 'on';

            % Create config_chPowerColor
            app.config_chPowerColor = uicolorpicker(app.CartesianAxesGrid);
            app.config_chPowerColor.Value = [0.5686 1 0];
            app.config_chPowerColor.Tooltip = {''};
            app.config_chPowerColor.Layout.Row = 6;
            app.config_chPowerColor.Layout.Column = 2;
            app.config_chPowerColor.BackgroundColor = [1 1 1];

            % Create config_chPowerEdgeAlpha
            app.config_chPowerEdgeAlpha = uispinner(app.CartesianAxesGrid);
            app.config_chPowerEdgeAlpha.Step = 0.1;
            app.config_chPowerEdgeAlpha.Limits = [0 1];
            app.config_chPowerEdgeAlpha.ValueDisplayFormat = '%.1f';
            app.config_chPowerEdgeAlpha.FontSize = 11;
            app.config_chPowerEdgeAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerEdgeAlpha.Tooltip = {'Transparência da margem'};
            app.config_chPowerEdgeAlpha.Layout.Row = 6;
            app.config_chPowerEdgeAlpha.Layout.Column = 3;
            app.config_chPowerEdgeAlpha.Value = 1;

            % Create config_chPowerFaceAlpha
            app.config_chPowerFaceAlpha = uispinner(app.CartesianAxesGrid);
            app.config_chPowerFaceAlpha.Step = 0.1;
            app.config_chPowerFaceAlpha.Limits = [0 1];
            app.config_chPowerFaceAlpha.ValueDisplayFormat = '%.1f';
            app.config_chPowerFaceAlpha.FontSize = 11;
            app.config_chPowerFaceAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerFaceAlpha.Tooltip = {'Transparência da face'};
            app.config_chPowerFaceAlpha.Layout.Row = 6;
            app.config_chPowerFaceAlpha.Layout.Column = 4;
            app.config_chPowerFaceAlpha.Value = 0.4;

            % Create config_BandGuardTypeLabel
            app.config_BandGuardTypeLabel = uilabel(app.CartesianAxesGrid);
            app.config_BandGuardTypeLabel.VerticalAlignment = 'bottom';
            app.config_BandGuardTypeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardTypeLabel.Layout.Row = 7;
            app.config_BandGuardTypeLabel.Layout.Column = [1 4];
            app.config_BandGuardTypeLabel.Text = 'Escala frequência:';

            % Create config_BandGuardValueLabel
            app.config_BandGuardValueLabel = uilabel(app.CartesianAxesGrid);
            app.config_BandGuardValueLabel.VerticalAlignment = 'bottom';
            app.config_BandGuardValueLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardValueLabel.Layout.Row = 7;
            app.config_BandGuardValueLabel.Layout.Column = [3 4];
            app.config_BandGuardValueLabel.Text = 'Fator:';

            % Create config_BandGuardType
            app.config_BandGuardType = uidropdown(app.CartesianAxesGrid);
            app.config_BandGuardType.Items = {'Fixed', 'BWRelated'};
            app.config_BandGuardType.FontSize = 11;
            app.config_BandGuardType.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardType.BackgroundColor = [1 1 1];
            app.config_BandGuardType.Layout.Row = 8;
            app.config_BandGuardType.Layout.Column = [1 2];
            app.config_BandGuardType.Value = 'Fixed';

            % Create config_BandGuardFixedValue
            app.config_BandGuardFixedValue = uieditfield(app.CartesianAxesGrid, 'numeric');
            app.config_BandGuardFixedValue.Limits = [0 Inf];
            app.config_BandGuardFixedValue.ValueDisplayFormat = '%.1f';
            app.config_BandGuardFixedValue.FontSize = 11;
            app.config_BandGuardFixedValue.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardFixedValue.Visible = 'off';
            app.config_BandGuardFixedValue.Layout.Row = 8;
            app.config_BandGuardFixedValue.Layout.Column = [3 4];
            app.config_BandGuardFixedValue.Value = 1000;

            % Create config_BandGuardBWRelatedValue
            app.config_BandGuardBWRelatedValue = uispinner(app.CartesianAxesGrid);
            app.config_BandGuardBWRelatedValue.Limits = [1 10];
            app.config_BandGuardBWRelatedValue.RoundFractionalValues = 'on';
            app.config_BandGuardBWRelatedValue.ValueDisplayFormat = '%.0f';
            app.config_BandGuardBWRelatedValue.FontSize = 11;
            app.config_BandGuardBWRelatedValue.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardBWRelatedValue.Layout.Row = 8;
            app.config_BandGuardBWRelatedValue.Layout.Column = [3 4];
            app.config_BandGuardBWRelatedValue.Value = 6;

            % Create config_Refresh
            app.config_Refresh = uiimage(app.RightPanel);
            app.config_Refresh.ScaleMethod = 'none';
            app.config_Refresh.Visible = 'off';
            app.config_Refresh.Tooltip = {'Volta à configuração inicial'};
            app.config_Refresh.Layout.Row = [6 7];
            app.config_Refresh.Layout.Column = 3;
            app.config_Refresh.VerticalAlignment = 'bottom';
            app.config_Refresh.ImageSource = 'Refresh_18.png';

            % Create AxesContainer
            app.AxesContainer = uipanel(app.Document);
            app.AxesContainer.AutoResizeChildren = 'off';
            app.AxesContainer.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.AxesContainer.BorderType = 'none';
            app.AxesContainer.BackgroundColor = [0 0 0];
            app.AxesContainer.Layout.Row = [1 2];
            app.AxesContainer.Layout.Column = [4 8];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {10, 25, 25, 5, '1x', 5, 25, 25, 5, 54, 25, 10};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [0 2 0 1];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 5;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_InteractionImageClicked, true);
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_InteractionImageClicked, true);
            app.axesTool_RegionZoom.Tooltip = {'RegionZoom'};
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 3;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create axesTool_DataSourceDropDown
            app.axesTool_DataSourceDropDown = uidropdown(app.AxesToolbar);
            app.axesTool_DataSourceDropDown.Items = {'Dados brutos', 'Processados'};
            app.axesTool_DataSourceDropDown.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_DataSourceChanged, true);
            app.axesTool_DataSourceDropDown.FontSize = 11;
            app.axesTool_DataSourceDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_DataSourceDropDown.BackgroundColor = [1 1 1];
            app.axesTool_DataSourceDropDown.Layout.Row = 1;
            app.axesTool_DataSourceDropDown.Layout.Column = 5;
            app.axesTool_DataSourceDropDown.Value = 'Dados brutos';

            % Create axesTool_DistortionPlot
            app.axesTool_DistortionPlot = uiimage(app.AxesToolbar);
            app.axesTool_DistortionPlot.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_PlotTypeValueChanged, true);
            app.axesTool_DistortionPlot.Tooltip = {'Distortion'};
            app.axesTool_DistortionPlot.Layout.Row = 1;
            app.axesTool_DistortionPlot.Layout.Column = 7;
            app.axesTool_DistortionPlot.ImageSource = 'DriveTestDistortion_32.png';

            % Create axesTool_DensityPlot
            app.axesTool_DensityPlot = uiimage(app.AxesToolbar);
            app.axesTool_DensityPlot.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_PlotTypeValueChanged, true);
            app.axesTool_DensityPlot.Enable = 'off';
            app.axesTool_DensityPlot.Tooltip = {'Heatmap'; '(aplicável apenas quando visualizados os dados processados)'};
            app.axesTool_DensityPlot.Layout.Row = 1;
            app.axesTool_DensityPlot.Layout.Column = 8;
            app.axesTool_DensityPlot.ImageSource = 'DriveTestDensity_32.png';

            % Create axesTool_PlotSize
            app.axesTool_PlotSize = uislider(app.AxesToolbar);
            app.axesTool_PlotSize.Limits = [1 19];
            app.axesTool_PlotSize.MajorTicks = [1 10 19];
            app.axesTool_PlotSize.MajorTickLabels = {''};
            app.axesTool_PlotSize.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_PlotSizeValueChanged, true);
            app.axesTool_PlotSize.ValueChangingFcn = createCallbackFcn(app, @AxesToolbar_PlotSizeValueChanging, true);
            app.axesTool_PlotSize.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_PlotSize.Layout.Row = 1;
            app.axesTool_PlotSize.Layout.Column = 10;
            app.axesTool_PlotSize.Value = 1;

            % Create axesTool_DensityPlot_2
            app.axesTool_DensityPlot_2 = uiimage(app.AxesToolbar);
            app.axesTool_DensityPlot_2.ScaleMethod = 'none';
            app.axesTool_DensityPlot_2.ImageClickedFcn = createCallbackFcn(app, @axesTool_DensityPlot_2ImageClicked, true);
            app.axesTool_DensityPlot_2.Tooltip = {'Heatmap'; '(aplicável apenas quando visualizados os dados processados)'};
            app.axesTool_DensityPlot_2.Layout.Row = 1;
            app.axesTool_DensityPlot_2.Layout.Column = 11;
            app.axesTool_DensityPlot_2.ImageSource = 'target.svg';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [3 4];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winDriveTest';

            % Create DeleteSelectedItem
            app.DeleteSelectedItem = uimenu(app.ContextMenu);
            app.DeleteSelectedItem.MenuSelectedFcn = createCallbackFcn(app, @onContextMenuItemClicked, true);
            app.DeleteSelectedItem.Text = '❌ Excluir';

            % Create DeleteAllEntries
            app.DeleteAllEntries = uimenu(app.ContextMenu);
            app.DeleteAllEntries.MenuSelectedFcn = createCallbackFcn(app, @onContextMenuItemClicked, true);
            app.DeleteAllEntries.Text = '🚫 Excluir todos';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winDriveTest_exported(Container, varargin)

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
