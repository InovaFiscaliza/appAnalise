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
        axesTool_Target                 matlab.ui.control.Image
        axesTool_PlotSize               matlab.ui.control.Slider
        axesTool_DensityPlot            matlab.ui.control.Image
        axesTool_DistortionPlot         matlab.ui.control.Image
        axesTool_DataSourceDropDown     matlab.ui.control.DropDown
        axesTool_RegionZoom             matlab.ui.control.Image
        axesTool_RestoreView            matlab.ui.control.Image
        AxesContainer                   matlab.ui.container.Panel
        RightPanel                      matlab.ui.container.GridLayout
        CartesianAxesPanel              matlab.ui.container.Panel
        CartesianAxesGrid               matlab.ui.container.GridLayout
        BandGuardBWRelatedValue         matlab.ui.control.Spinner
        BandGuardFixedValue             matlab.ui.control.NumericEditField
        BandGuardType                   matlab.ui.control.DropDown
        BandGuardValueLabel             matlab.ui.control.Label
        BandGuardTypeLabel              matlab.ui.control.Label
        ChannelPowerFaceAlpha           matlab.ui.control.Spinner
        ChannelPowerEdgeAlpha           matlab.ui.control.Spinner
        ChannelPowerColor               matlab.ui.control.ColorPicker
        ChannelPowerVisibility          matlab.ui.control.DropDown
        ChannelPowerLabel               matlab.ui.control.Label
        ChannelRoiFaceAlpha             matlab.ui.control.Spinner
        ChannelRoiEdgeAlpha             matlab.ui.control.Spinner
        ChannelRoiColor                 matlab.ui.control.ColorPicker
        ChannelRoiVisibility            matlab.ui.control.DropDown
        ChannelRoiLabel                 matlab.ui.control.Label
        PersistanceVisibility           matlab.ui.control.DropDown
        PersistanceLabel                matlab.ui.control.Label
        CartesianAxesPanelLabel         matlab.ui.control.Label
        CartesianAxesPanelIcon          matlab.ui.control.Image
        GeographicAxesPanel             matlab.ui.container.Panel
        GeographicAxesPanelGrid         matlab.ui.container.GridLayout
        PointsSize                      matlab.ui.control.Slider
        PointsColor                     matlab.ui.control.ColorPicker
        PointsMarker                    matlab.ui.control.DropDown
        PointsLabel                     matlab.ui.control.Label
        CarSize                         matlab.ui.control.Slider
        CarColor                        matlab.ui.control.ColorPicker
        CarMarker                       matlab.ui.control.DropDown
        CarLabel                        matlab.ui.control.Label
        RouteLineWidth                  matlab.ui.control.Slider
        RouteColorIn                    matlab.ui.control.ColorPicker
        RouteColorOut                   matlab.ui.control.ColorPicker
        RouteLineStyle                  matlab.ui.control.DropDown
        RouteStyleLabel                 matlab.ui.control.Label
        Basemap                         matlab.ui.control.DropDown
        BasemapLabel                    matlab.ui.control.Label
        Colormap                        matlab.ui.control.DropDown
        ColormapLabel                   matlab.ui.control.Label
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
        tool_TimestampLabel             matlab.ui.control.Label
        tool_TimestampSlider            matlab.ui.control.Slider
        tool_LoopControl                matlab.ui.control.Image
        tool_Play                       matlab.ui.control.Image
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
        %  -2: mudança de fluxo espectral
        %  -1: mudança de emissão
        %   0: finaliza a apresentação da última varredura
        %   1: atualiza alguma característica do plot em andamento
        plotUpdateEvent = 0

        % Handles dos objetos gráficos do plot.
        plotHandles = struct( ...
            'car', [], ...
            'azimuth', [], ...
            'clearWrite', [], ...
            'persistence', [], ...
            'waterfallTime', [] ...
        )

        % Índice da varredura atual.
        sweepTimeIdx

        emissionPoints = struct('raw', [], 'filtered', [], 'binned', [])
        filterTable = table({}, {}, struct('handle', {}, 'specification', {}), 'VariableNames', {'type', 'subtype', 'roi'})
        pointsTable = table({}, struct('source', {}, 'data', {}, 'dataIdx', {}), true(0, 1), {}, 'VariableNames', {'type', 'value', 'visible', 'hash'})
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        projectData
        defaultValues
        emissionSelectedIdxs = struct('flowIdx', {}, 'emissionIdx', {}, 'attributes', {})
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'onChannelEditRequested'
                        [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
                        ipcMainMatlabOpenPopupApp(app.mainApp, app, 'EmissionChannel', app.Context, flowIdx, emissionIdx)

                    case 'onClassificationEditRequested'
                        [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onClassificationEditRequested', app.Context, flowIdx, emissionIdx)

                    case 'onMeasurementsDetailsRequested'
                        if isempty(app.emissionSelectedIdxs)
                            return
                        end

                        dataBinningDetails = app.emissionSelectedIdxs.attributes.dataBinningDetails;
                        ui.Dialog(app.UIFigure, 'info', dataBinningDetails);

                    case 'onMeasurementsExportRequested'
                        if isempty(app.emissionSelectedIdxs)
                            return
                        end

                        questionMsg = 'Deseja exportar drive-test em arquivos .XLSX e .KML?';
                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                        if userSelection == "Não"
                            return
                        end

                        nameFormatMap = {'*.zip', 'appAnalise (*.zip)'};
                        basename = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'DriveTest');
                        fileFullPath = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, basename);
                        if isempty(fileFullPath)
                            return
                        end
            
                        app.progressDialog.Visible = 'visible';
            
                        dataSource = getActiveDataSource(app);
                        distortionHandle = findobj(app.UIAxes1.Children, 'Tag', 'distortion');
                        channelTag = sprintf('%.3f MHz ⌂ %.1f kHz', ...
                            app.emissionSelectedIdxs.attributes.channel.Frequency, ...
                            app.emissionSelectedIdxs.attributes.channel.ChannelBW ...
                        );
            
                        try
                            msgWarning = util.exportDriveTestAnalysis(app.emissionPoints, basename, fileFullPath, dataSource, distortionHandle, channelTag);
                            ui.Dialog(app.UIFigure, 'info', msgWarning);
                        catch ME
                            ui.Dialog(app.UIFigure, 'error', ME.message);
                        end
            
                        app.progressDialog.Visible = 'hidden';

                    case 'onReportIncludeRequested'
                        specData = app.bandObj.SpecData;
                        emissionIdx = app.emissionSelectedIdxs.emissionIdx;
                        update(specData, 'UserData:Emissions', 'AuxAppData:DriveTest:ReportInclude', emissionIdx)

                        refreshEmissionDropDown(app)
                        refreshEmissionMetadataPanel(app, specData)

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
                            case {'onFileListAdded', ...
                                  'onFileListRemoved', ...
                                  'onFileFilterChanged', ...
                                  'onProjectLoad', ...
                                  'onFlowMergeRequested', ...
                                  'onReportFlowListChanged', ...
                                  'onFlowUnlockRequested', ...
                                  'onFilterByLevelRequested', ...
                                  'onFilterByTimeRequested', ...
                                  'onEmissionAdded', ...
                                  'onEmissionParameterValueChanged', ...
                                  'onEmissionTruncatedValueChanged', ...
                                  'onEmissionDeleted', ...
                                  'onDetectionSubBandsChanged', ...
                                  'onCalibrationCurveApplied', ...
                                  'onSpectralDataReadError'}
                                app.emissionSelectedIdxs(:) = [];
                                refreshFlowDropDown(app)

                                if app.plotUpdateEvent > 0
                                    app.plotUpdateEvent = -2;
                                else
                                    onFlowDropDownValueChanged(app)
                                end

                            case 'onEmissionChannelChanged'
                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = 0;
                                end

                                specData = app.bandObj.SpecData;
                                emissionIdx = app.emissionSelectedIdxs.emissionIdx;

                                recomputeEmissionMeasures(app, specData, emissionIdx)
                                persistEmissionDisplaySettings(app, specData, emissionIdx)
            
                                % Isso força a reinicialização das tabelas e plot...
                                app.emissionSelectedIdxs(:) = [];
                                onEmissionDropDownValueChanged(app)

                            case 'onLocationChanged'
                                specData = app.bandObj.SpecData;
                                refreshMetadataPanels(app, specData)
            
                            case {'onTabNavigatorButtonPushed', ...
                                  'onPlaybackStarted'}
                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = 0;
                                end

                            case 'onDriveTestFilterChanged'
                                filterType = varargin{2};
                                filterSubtype = varargin{3};

                                switch filterSubtype
                                    case 'Threshold'
                                        initialThreshold = min(app.emissionPoints.raw.ChannelPower);

                                        roiHandle = plot.DriveTest.FilterRoiGraphic(filterSubtype, app.UIAxes4, @app.replotAfterFilterChange);
                                        roiHandle.Position = [height(app.emissionPoints.raw) initialThreshold; 1 initialThreshold];
                    
                                        app.filterTable(end+1, :) = {filterType, filterSubtype, struct('handle', roiHandle, 'specification', plot.ROI.specification(roiHandle))};

                                    case 'PolygonKML'
                                        kmlObj = app.mainApp.kmlObj;
                                        kmlFileLayer = varargin{4};

                                        try
                                            readgeotable(kmlObj, kmlFileLayer)
                                            for ii = 1:height(kmlObj.GeoTable)
                                                shapeObj = kmlObj.GeoTable.Shape(ii);
            
                                                if isa(shapeObj, 'geopolyshape')
                                                    roiHandle = plot.DriveTest.FilterRoiGraphic(filterSubtype, app.UIAxes1, @app.replotAfterFilterChange, shapeObj);
                                                    app.filterTable(end+1, :) = {filterType, filterSubtype, struct('handle', roiHandle, 'specification', plot.ROI.specification(roiHandle))};
                                                end
                                            end
            
                                            if ~exist('roiHandle', 'var')
                                                error([ ...
                                                    'A pasta "%s", do arquivo "%s", possui apenas objetos do tipo "%s". Um filtro '  ...
                                                    'geográfico, contudo, precisa ser um polígono.' ...
                                                ], kmlFileLayer, kmlObj.File, textFormatGUI.cellstr2ListWithQuotes(unique(arrayfun(@(x) class(x), kmlObj.GeoTable.Shape, "UniformOutput", false))))
                                            end
            
                                        catch ME
                                            ui.Dialog(app.UIFigure, 'error', ME.message);
                                            return
                                        end

                                    otherwise % 'Circle' | 'Rectangle' | 'Polygon'
                                        roiHandle = plot.DriveTest.FilterRoiGraphic(filterSubtype, app.UIAxes1, @app.replotAfterFilterChange, 'DrawInRealTime');
                                        if isempty(roiHandle.Position)
                                            delete(roiHandle)                
                                            return
                                        end
            
                                        app.filterTable(end+1, :) = {filterType, filterSubtype, struct('handle', roiHandle, 'specification', plot.ROI.specification(roiHandle))};
                                end

                                replotAfterFilterChange(app)

                            case 'onDriveTestPointsAdded'
                                newRowType = varargin{2};
                                newRowData = varargin{3};
                                newRowHash = Hash.sha1(sprintf('%s - %s', newRowType, jsonencode(newRowData)));

                                if ismember(newRowHash, app.pointsTable.hash)
                                    return
                                end

                                app.pointsTable(end+1, :) = {newRowType, newRowData, true, newRowHash};
                                replotAfterPointsChange(app)

                            case 'auxApp.winDriveTest.FilterTree'
                                onContextMenuItemClicked(app, struct('ContextObject', app.FilterTree.Children(1), 'Source', app.DeleteSelectedItem))

                            case 'auxApp.winDriveTest.PointsTree'
                                onContextMenuItemClicked(app, struct('ContextObject', app.PointsTree.Children(1), 'Source', app.DeleteSelectedItem))

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
                'drivetest', prjGeneralSettings.plot.drivetest, ...
                'dataBinning', prjGeneralSettings.context.DRIVETEST.dataBinning ...
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
            app.tool_LoopControl.UserData.loopMode = true;

            
            app.Basemap.Value = app.defaultValues.basemap;
            app.Colormap.Value = app.defaultValues.colormap;
            
            initializeAxes(app)

            % Preenche valores que atualmente não são customizados:
            % (a lista de customização está restrita aos elementos do painel 
            %  "Eixo Geográfico", com exceção dos parâmetros do carro)
            app.CarMarker.Value           = app.defaultValues.drivetest.car.Marker;
            app.CarColor.Value            = app.defaultValues.drivetest.car.MarkerFaceColor;
            app.CarSize.Value             = app.defaultValues.drivetest.car.MarkerSize;
            app.ChannelRoiColor.Value     = app.defaultValues.channelROI.Color;
            app.ChannelRoiEdgeAlpha.Value = app.defaultValues.channelROI.EdgeAlpha;
            app.ChannelRoiFaceAlpha.Value = app.defaultValues.channelROI.FaceAlpha;
            app.ChannelPowerColor.Value   = app.defaultValues.channelPower.FaceColor;
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            refreshFlowDropDown(app)
            onFlowDropDownValueChanged(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 24, 16, "Padding", "none", "TileSpacing", "none", "Position", [0, 0, 1, 1]);

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.Basemap.Value,                        ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '', 'PlotMode', 'distortion')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [24, 12];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            
            geolimits(app.UIAxes1, 'auto')
            plot.axes.Colormap(app.UIAxes1, app.Colormap.Value)

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
                                                                    'HitTest', 'off',                                            ...
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
        function [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app)
            flowIdx = app.SpectrumFlowList.Value;
            emissionIdx = find(strcmp(app.EmissionList.Items, app.EmissionList.Value), 1) - 1;
            if ~emissionIdx
                emissionIdx = [];
            end
        end

        %-----------------------------------------------------------------%
        function refreshFlowDropDown(app)
            specData = app.mainApp.specData;

            % Aberto, em 10/03/2026, reporte de BUG relacionado ao uidropdown, 
            % quando aplicado estilo "html". Ao apagar lista, o MATLAB não
            % apaga o valor atual do elemento na GUI. Assim que resolver
            % isso, basta inserir o addStyle uma única vez, não precisando
            % removê-lo.

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

                        lockStatus = '';
                        if specData(jj).IsUserModified
                            lockStatus = '&emsp;&#x1F512;&#xFE0E;';
                        end
            
                        items{end+1} = sprintf('%s<br>└── %.3f&ensp;a&ensp;%.3f MHz%s%s', receiverName, freqStart, freqStop, reportStatus, lockStatus);
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
        function loadSelectedFlow(app, flowIdx)
            % Caso não esteja em cache os dados do fluxo espectral selecionado, 
            % procede-se a sua leitura, preenchendo a propriedade "Data" com
            % timestamps, níveis das varreduras, azimutes e notas de qualidade.
            % Caso ocorra erro na leitura, o registro é excluído e o layout é
            % reinicializado.
            specData = [];
            if ~isempty(flowIdx)
                specData = app.mainApp.specData(flowIdx);
            end

            if ~isempty(specData) 
                if isempty(specData.Data) || (numel(specData.Data{1}) ~= sum(specData.RelatedFiles.NumSweeps))
                    requestVisibilityChange(app.progressDialog, 'visible', 'unlocked')
    
                    try
                        populateSpectrum(specData, app.mainApp.metaData, app.mainApp.projectData, app.mainApp.channelObj, app.mainApp.General)
                        
                        relatedHases = specData.UserData.OccupancyComputationMode.RelatedHashes;
                        if ~isempty(relatedHases)
                            relatedHashIdxs = find(ismember({app.mainApp.specData.Hash}, relatedHases));
                            populateSpectrum(app.mainApp.specData(relatedHashIdxs), app.mainApp.metaData, app.mainApp.projectData, app.mainApp.channelObj, app.mainApp.General)
                        end
    
                    catch ME
                        ui.Dialog(app.UIFigure, 'error', ME.message);
    
                        delete(app.mainApp.specData(flowIdx))
                        app.mainApp.specData(flowIdx) = [];
                        refreshFlowDropDown(app)
    
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onSpectralDataReadError', app.Context)
                        requestVisibilityChange(app.progressDialog, 'hidden', 'unlocked')
                        return
                    end
    
                    requestVisibilityChange(app.progressDialog, 'hidden', 'unlocked')
                end

                initializeUnsetProperties(specData, app.mainApp.channelObj, app.mainApp.General)
            end

            % Reinicializa handles dos plots WATERFALL e PERSISTÊNCIA. Os
            % outros são reinicializados quando alterada a emissão.
            resetPlotState(app, specData, 'onFlowDropDownValueChanged')

            refreshEmissionDropDown(app)
            onEmissionDropDownValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function refreshEmissionDropDown(app)
            if isempty(app.mainApp.specData)
                app.EmissionList.Items = {};
                return
            end

            flowIdx   = getSelectedFlowAndEmissionIndices(app);
            specData  = app.mainApp.specData(flowIdx);
            emissions = specData.UserData.Emissions;

            % Cria lista de emissões:
            emissionList = {};

            for ii = 0:height(emissions)
                additionalNote = '';
                reportStatus = '';
    
                if ii == 0
                    freqCenter   = (specData.MetaData.FreqStart + specData.MetaData.FreqStop) / 2e6; % MHz
                    bandWidthkHz = (specData.MetaData.FreqStop - specData.MetaData.FreqStart) / 1e3; % kHz
                    additionalNote = ' (Emissão virtual)';
                else
                    freqCenter   = emissions.Frequency(ii); % MHz
                    bandWidthkHz = emissions.BandWidthkHz(ii); % kHz

                    if ~isempty(emissions.AuxAppData(ii).DriveTest) && emissions.AuxAppData(ii).DriveTest.ReportInclude
                        reportStatus = ' 🟢';
                    end
                end

                emissionList{end+1} = sprintf('%d: %.3f MHz ⌂ %.1f kHz%s%s', ii, freqCenter, bandWidthkHz, additionalNote, reportStatus);
            end

            previousValue = app.EmissionList.Value;
            [~, previousValueIdx] = ismember(replace(previousValue, {' (Emissão virtual)', ' 🟢'}, ''), replace(emissionList, {' (Emissão virtual)', ' 🟢'}, ''));

            currentValue = {};
            if ~isempty(previousValue) && previousValueIdx
                currentValue = {'Value', emissionList{previousValueIdx}};
            end

            set(app.EmissionList, 'Items', emissionList, currentValue{:})

            if isempty(currentValue) && ~isscalar(emissionList)
                app.EmissionList.Value = emissionList{2};
            end
        end

        %-----------------------------------------------------------------%
        function loadSelectedEmission(app)
            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);

            if ~isempty(app.emissionSelectedIdxs) && isequal(app.emissionSelectedIdxs.flowIdx, flowIdx) && isequal(app.emissionSelectedIdxs.emissionIdx, emissionIdx)
                return
            end

            specData = [];
            if ~isempty(flowIdx)
                specData = app.mainApp.specData(flowIdx);
            end

            app.filterTable(:, :) = [];
            app.pointsTable(:, :) = [];

            % Atualiza app.bandObj, instância de model.Band, que guarda
            % informações derivadas da instância de model.SpecData sob análise.
            % A partir desse momento, a referência ao specData selecionado
            % se dará por app.bandObj.SpecData.
            storeSelectedEmissionContext(app, specData, flowIdx, emissionIdx)

            guardBand = resolveScreenSpan(app, specData, emissionIdx);
            updateSpectrumInfo(app.bandObj, specData, emissionIdx, guardBand);

            % Atualiza PAINEL À DIREITA.
            applyEmissionDisplaySettings(app, specData, emissionIdx, guardBand)

            % Atualiza PAINEL À ESQUERDA com metadados do fluxo e da emissão.
            refreshControlStates(app, specData, emissionIdx)
            refreshMetadataPanels(app, specData)

            % Reseta o PLOT e atualiza informações que suportam o plot, como 
            % as dispostas no painel à direita.
            resetPlotState(app, specData, 'onEmissionDropDownValueChanged')
        end

        %-----------------------------------------------------------------%
        function storeSelectedEmissionContext(app, specData, flowIdx, emissionIdx)
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
                    'Frequency', chFrequency, ...
                    'ChannelBW', chBandWidth ...
                );
    
                app.emissionSelectedIdxs(1) = struct( ...
                    'flowIdx', flowIdx, ...
                    'emissionIdx', emissionIdx, ...
                    'attributes', struct( ...
                        'tag', sprintf('%.3f MHz ⌂ %.1f kHz', freqCenter, bandWidthkHz), ...
                        'freqCenter', freqCenter, ...
                        'bandWidthkHz', bandWidthkHz, ...
                        'channel', emissionChannel, ...
                        'dataBinningDetails', '' ...
                    ) ...
                );
            else
                app.emissionSelectedIdxs(:) = [];
            end
        end

        %-----------------------------------------------------------------%
        function guardBand = resolveScreenSpan(app, specData, emissionIdx)
            if isempty(emissionIdx)
                guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'BWRelated', 'Value', 1));

            else
                driveTestAttributes = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest;
                chBandWidthkHz = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW;                

                if isempty(driveTestAttributes)
                    guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'BWRelated', 'Value', 6));

                else
                    guardBandType = driveTestAttributes.PlotDisplayConfig.ScreenSpan.Type;
                    switch guardBandType
                        case 'Fixed'
                            initialGuardBandValue = driveTestAttributes.PlotDisplayConfig.ScreenSpan.Value;
                            guardBandValue = limitGuardBandValue(app, initialGuardBandValue, chBandWidthkHz) / 1000; % MHz
                        otherwise % 'BWRelated'
                            guardBandValue = driveTestAttributes.PlotDisplayConfig.ScreenSpan.Value;
                    end

                    guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', guardBandType, 'Value', guardBandValue));
                end

                if chBandWidthkHz <= 0
                    guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', 1));
                end
            end
        end

        %-----------------------------------------------------------------%
        function guardBandValue = limitGuardBandValue(app, guardBandValue, chBandWidthkHz)
            chBandWidthLimits = chBandWidthkHz * app.BandGuardBWRelatedValue.Limits;
    
            if guardBandValue < chBandWidthLimits(1)
                guardBandValue = chBandWidthLimits(1);
            elseif guardBandValue > chBandWidthLimits(2)
                guardBandValue = chBandWidthLimits(2);
            end
        end

        %-----------------------------------------------------------------%
        function applyEmissionDisplaySettings(app, specData, emissionIdx, guardBand)
            syncScreenSpanControls(app, guardBand.Parameters.Type, guardBand.Parameters.Value)

            if isempty(specData) || isempty(emissionIdx)
                resetDataBinningControls(app)
                recomputeEmissionMeasures(app, specData, emissionIdx)

                return
            end

            driveTestAttributes = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest;

            if isempty(driveTestAttributes)
                resetDataBinningControls(app)

                app.Colormap.Value = app.defaultValues.colormap;
                app.Basemap.Value = app.defaultValues.basemap;
                app.RouteLineStyle.Value = app.defaultValues.drivetest.route.LineStyle;
                app.RouteLineWidth.Value = app.defaultValues.drivetest.route.LineWidth;
                app.RouteColorOut.Value = app.defaultValues.drivetest.route.Colors.OutROI;
                app.RouteColorIn.Value = app.defaultValues.drivetest.route.Colors.InROI;
                app.PointsMarker.Value = app.defaultValues.drivetest.points.Marker;
                app.PointsColor.Value = app.defaultValues.drivetest.points.MarkerFaceColor;
                app.PointsSize.Value = app.defaultValues.drivetest.points.MarkerSize;
                
                recomputeEmissionMeasures(app, specData, emissionIdx)
                persistEmissionDisplaySettings(app, specData, emissionIdx)

                guardBand = resolveScreenSpan(app, specData, emissionIdx);
                applyEmissionDisplaySettings(app, specData, emissionIdx, guardBand)

                return
            end

            app.emissionPoints = driveTestAttributes.Measures;
            app.filterTable = driveTestAttributes.Filters;
            app.pointsTable = driveTestAttributes.Points;

            app.DataBinningFcn.Value = driveTestAttributes.Binning.AggregationFunction;
            app.DataBinningLength.Value = driveTestAttributes.Binning.LengthMeters;
            app.emissionSelectedIdxs.attributes.dataBinningDetails = driveTestAttributes.Binning.Summary;

            app.UIAxes1.UserData.PlotMode = driveTestAttributes.PlotDisplayConfig.Data.PlotMode;
            app.axesTool_PlotSize.Value = driveTestAttributes.PlotDisplayConfig.Data.PlotSize;
            
            app.axesTool_DataSourceDropDown.Value = driveTestAttributes.PlotDisplayConfig.Data.Source;
            syncDataSourceToolbarState(app)
            
            app.Colormap.Value = driveTestAttributes.PlotDisplayConfig.Colormap;
            if ~strcmp(app.UIAxes1.UserData.Colormap, app.Colormap.Value)
                plot.axes.Colormap(app.UIAxes1, app.Colormap.Value)
            end
            
            app.Basemap.Value = driveTestAttributes.PlotDisplayConfig.Basemap;
            if ~strcmp(app.UIAxes1.Basemap, app.Basemap.Value)
                app.UIAxes1.Basemap = app.Basemap.Value;

                switch app.Basemap.Value
                    case {'darkwater', 'none'}
                        app.UIAxes1.Grid = 'on';

                    otherwise
                        app.UIAxes1.Grid = 'off';
                end
            end

            app.RouteLineStyle.Value = driveTestAttributes.PlotDisplayConfig.Route.LineStyle;
            app.RouteLineWidth.Value = driveTestAttributes.PlotDisplayConfig.Route.LineWidth;
            app.RouteColorOut.Value = driveTestAttributes.PlotDisplayConfig.Route.ColorOut;
            app.RouteColorIn.Value = driveTestAttributes.PlotDisplayConfig.Route.ColorIn;                
            app.PointsMarker.Value = driveTestAttributes.PlotDisplayConfig.Points.Marker;
            app.PointsColor.Value = driveTestAttributes.PlotDisplayConfig.Points.Color;
            app.PointsSize.Value = driveTestAttributes.PlotDisplayConfig.Points.Size;                    
        end

        %-----------------------------------------------------------------%
        function syncScreenSpanControls(app, guardBandType, guardBandValue)
            app.BandGuardType.Value = guardBandType;

            switch guardBandType
                case 'Fixed'
                    app.BandGuardValueLabel.Text = 'Largura (kHz):';
                    set(app.BandGuardFixedValue,     'Enable', 'on',  'Visible', 'on', 'Value', guardBandValue * 1000) % MHz >> kHz
                    set(app.BandGuardBWRelatedValue, 'Enable', 'off', 'Visible', 'off')

                otherwise % 'BWRelated'
                    app.BandGuardValueLabel.Text = 'Fator:';
                    set(app.BandGuardFixedValue,     'Enable', 'off', 'Visible', 'off')
                    set(app.BandGuardBWRelatedValue, 'Enable', 'on',  'Visible', 'on', 'Value', guardBandValue)
            end
        end

        %-----------------------------------------------------------------%
        function resetDataBinningControls(app)
            app.axesTool_DataSourceDropDown.Value = 'Dados brutos';
            syncDataSourceToolbarState(app)
            app.axesTool_PlotSize.Value = 1;
            
            app.DataBinningFcn.Value = app.defaultValues.dataBinning.aggregationFunction;
            app.DataBinningLength.Value = app.defaultValues.dataBinning.binLengthMeters;
        end

        %-----------------------------------------------------------------%
        function syncDataSourceToolbarState(app)
            switch app.axesTool_DataSourceDropDown.Value
                case 'Dados brutos'
                    app.axesTool_DensityPlot.Enable = 0;
                    if ~strcmp(app.UIAxes1.UserData.PlotMode, 'distortion')
                        app.UIAxes1.UserData.PlotMode = 'distortion';
                    end

                otherwise % 'Processados'
                    app.axesTool_DensityPlot.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function recomputeEmissionMeasures(app, specData, emissionIdx)
            if ~isempty(specData)
                if ~isempty(emissionIdx)
                    chFrequency  = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.Frequency;
                    chBandWidth  = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW;
                    
                else 
                    freqCenter   = (specData.MetaData.FreqStart + specData.MetaData.FreqStop)  / 2e6; % MHz
                    bandWidthkHz = (specData.MetaData.FreqStop  - specData.MetaData.FreqStart) / 1e3; % kHz
                    chFrequency  = freqCenter;
                    chBandWidth  = bandWidthkHz;
                end

                emissionChannel = struct( ...
                    'Frequency', chFrequency, ...
                    'ChannelBW', chBandWidth ...
                );

                app.emissionPoints(1).raw = RF.DataBinning.RawTableCreation(specData, 1, emissionChannel);

                [app.emissionPoints.raw, ...
                 app.emissionPoints.filtered, ...
                 app.emissionPoints.binned, ...
                 app.filterTable, ...
                 dataBinningDetails] = RF.DataBinning.execute(app.emissionPoints.raw,      ...
                                                              app.DataBinningLength.Value, ...
                                                              app.DataBinningFcn.Value,    ...
                                                              app.filterTable);

                if ~isempty(app.emissionSelectedIdxs)
                    app.emissionSelectedIdxs.attributes.dataBinningDetails = dataBinningDetails;
                end

            else
                app.emissionPoints(:) = [];
            end
        end

        %-----------------------------------------------------------------%
        function refreshControlStates(app, specData, emissionIdx)
            isSpectralFlow = ~isempty(specData) && ismember(specData.MetaData.DataType, class.Constants.specDataTypes);
            hasEmission    = ~isempty(specData) && ~isempty(emissionIdx);
            hasChannelBW   = ~isempty(specData) && ~isempty(emissionIdx) && specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW > 0;
            isDataBinned   = strcmp(app.axesTool_DataSourceDropDown.Value, 'Processados');

            set([
                app.Colormap;
                app.Basemap;
                app.RouteLineStyle;
                app.RouteLineWidth;
                app.RouteColorOut;
                app.RouteColorIn;
                app.CarMarker;
                app.CarColor;
                app.CarSize;
                app.PointsMarker;
                app.PointsColor;
                app.PointsSize;
                app.PersistanceVisibility;
                app.ChannelRoiVisibility;
                app.ChannelRoiColor;
                app.ChannelRoiEdgeAlpha;
                app.ChannelRoiFaceAlpha;
                app.ChannelPowerVisibility;
                app.ChannelPowerColor;
                app.ChannelPowerEdgeAlpha;
                app.ChannelPowerFaceAlpha;
                app.tool_Play;
                app.tool_LoopControl;
                app.tool_TimestampSlider
            ], 'Enable', isSpectralFlow)

            set([
                app.axesTool_DataSourceDropDown;
                app.axesTool_DistortionPlot;
                app.axesTool_PlotSize;
                app.axesTool_Target; 
                app.DataBinningLength;
                app.DataBinningFcn;
                app.FilterTreeButton;
                app.PointsTreeButton
            ], 'Enable', hasEmission)

            app.axesTool_DensityPlot.Enable = hasEmission && isDataBinned;

            app.BandGuardType.Enable = hasChannelBW;
            app.BandGuardFixedValue.Enable = hasChannelBW && strcmp(app.BandGuardType.Value, 'Fixed');
            app.BandGuardBWRelatedValue.Enable = hasChannelBW && strcmp(app.BandGuardType.Value, 'BWRelated');
        end

        %-----------------------------------------------------------------%
        function refreshMetadataPanels(app, specData)
            if ~isempty(specData)
                % Verifica se o handle para o app continua ativo no workspace
                % base do MATLAB, possibilitando que clicks no ui.TextView sejam 
                % capturados corretamente.
                appHandleNameInBase = app.AppHandleNameInBase;
                if isempty(appHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', appHandleNameInBase, appHandleNameInBase, class(app), appHandleNameInBase))
                    app.AppHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
                end

                refreshEmissionMetadataPanel(app, specData)
                rebuildFilterTree(app)
                rebuildPointsTree(app)

            else
                ui.TextView.update(app.EmissionMetadata, '');
            end
        end

        %-----------------------------------------------------------------%
        function refreshEmissionMetadataPanel(app, specData)
            emissionIdx = app.emissionSelectedIdxs.emissionIdx;
            htmlContent = util.HtmlTextGenerator.getSelectedEmissionMetaData(specData, emissionIdx, app.Context, app.AppHandleNameInBase, app.mainApp.General);
            ui.TextView.update(app.EmissionMetadata, htmlContent);
        end

        %-----------------------------------------------------------------%
        function rebuildFilterTree(app)
            if ~isempty(app.FilterTree.Children)
                delete(app.FilterTree.Children)
            end

            if ~isempty(app.filterTable)
                for ii = 1:height(app.filterTable)
                    nodeText = sprintf('%s:%s', app.filterTable.type{ii}, app.filterTable.subtype{ii});
                    uitreenode(app.FilterTree, 'Text', nodeText, 'NodeData', ii, 'ContextMenu', app.ContextMenu);
                end
            end
        end

        %-----------------------------------------------------------------%
        function rebuildPointsTree(app)
            if ~isempty(app.PointsTree.Children)
                delete(app.PointsTree.Children)
            end

            checkedTreeNodes = [];

            for ii = 1:height(app.pointsTable)
                nodeText = sprintf('%s: %s', app.pointsTable.type{ii}, strjoin("#" + string(app.pointsTable.value(ii).dataIdx), ', '));
                treeNode = uitreenode(app.PointsTree, 'Text', nodeText, 'NodeData', ii, 'ContextMenu', app.ContextMenu);

                if app.pointsTable.visible(ii)
                    checkedTreeNodes = [checkedTreeNodes, treeNode];
                end
            end

            app.PointsTree.CheckedNodes = checkedTreeNodes;
        end

        %-----------------------------------------------------------------%
        function persistEmissionDisplaySettings(app, specData, emissionIdx)
            if isempty(specData) || isempty(emissionIdx)
                return
            end

            reportInclude = false;
            if ~isempty(specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest)
                reportInclude = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest.ReportInclude;
            end

            screenSpanType = app.BandGuardType.Value;
            switch screenSpanType
                case 'Fixed'
                    screenSpanValue = app.BandGuardFixedValue.Value;
                otherwise % 'BWRelated'
                    screenSpanValue = app.BandGuardBWRelatedValue.Value;
            end

            driveTestAttributes = struct( ...
                'ReportInclude', reportInclude, ...
                'Measures', app.emissionPoints, ...
                'Binning', struct( ...
                    'AggregationFunction', app.DataBinningFcn.Value, ...
                    'LengthMeters', app.DataBinningLength.Value, ...
                    'Summary', app.emissionSelectedIdxs.attributes.dataBinningDetails ...
                ), ...
                'Filters', app.filterTable, ...
                'Points', app.pointsTable, ...
                'PlotDisplayConfig', struct( ...
                    'Colormap', app.Colormap.Value, ...
                    'Basemap', app.Basemap.Value, ....
                    'ScreenSpan', struct( ...
                        'Type', screenSpanType, ...
                        'Value', screenSpanValue ...
                    ), ...
                    'Data', struct( ...
                        'Source', app.axesTool_DataSourceDropDown.Value, ...
                        'PlotMode', app.UIAxes1.UserData.PlotMode, ...
                        'PlotSize', app.axesTool_PlotSize.Value ...
                    ), ...
                    'Route', struct( ...
                        'LineStyle', app.RouteLineStyle.Value, ...
                        'LineWidth', app.RouteLineWidth.Value, ...
                        'ColorOut', app.RouteColorOut.Value, ...
                        'ColorIn', app.RouteColorIn.Value ...
                    ), ...
                    'Points', struct( ...
                        'Marker', app.PointsMarker.Value, ...
                        'Color', app.PointsColor.Value, ...
                        'Size', app.PointsSize.Value ...
                    ) ...
                ) ...
            );

            update(specData, 'UserData:Emissions', 'AuxAppData:DriveTest', emissionIdx, driveTestAttributes)
        end

        %-----------------------------------------------------------------%
        % ## PLOT ##
        %-----------------------------------------------------------------%
        function resetPlotState(app, specData, eventName)
            switch eventName
                case 'onFlowDropDownValueChanged'
                    delete(findobj(app.UIAxes2.Children, 'Tag', 'persistence'))
                    app.plotHandles.persistence = [];

                case 'onEmissionDropDownValueChanged'
                    cla([app.UIAxes1, app.UIAxes3, app.UIAxes4])
                    delete(findobj(app.UIAxes2.Children, '-not', 'Tag', 'persistence'))
                    
                    % A inicialização de plots mais pesados como WATERFALL e PERSISTÊNCIA 
                    % ocorre apenas quando alterado o fluxo espectral.
                    app.plotHandles.car = [];
                    app.plotHandles.azimuth = [];
                    app.plotHandles.clearWrite = [];
                    app.plotHandles.waterfallTime = [];
            
                    app.sweepTimeIdx = 1;
                    app.tool_TimestampSlider.Value = 0;
                    persistAxesViewLimits(app, 'resetPlotState')
        
                    if ~isempty(specData)
                        if isempty(app.UIAxes1.Legend)
                            pause(1)
                            lgd = legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'BackgroundAlpha', 0.9, 'EdgeColor', [.9,.9,.9], 'NumColumns', 1, 'LineWidth', .5, 'FontSize', 7.5, 'PickableParts', 'none');
                            lgd.Title.FontSize = 8.5;
                        end
                        set(app.UIAxes1.Legend.Title, 'Visible', 'on', 'String', app.emissionSelectedIdxs.attributes.tag)
                        
                        refreshTimestampLabel(app)
        
                    else
                        if ~isempty(app.UIAxes1.Legend)
                            app.UIAxes1.Legend.Title.Visible = 'off';
                        end

                        app.tool_TimestampLabel.Text = '';
                        onAxesToolbarZoomControlButtonClicked(app, struct('Source', app.axesTool_RestoreView))
                    end
            end
        end

        %-----------------------------------------------------------------%
        function persistAxesViewLimits(app, requestType)
            arguments
                app 
                requestType {mustBeMember(requestType, {'resetPlotState', 'refreshGeoAxesPlotLimits'})}
            end

            switch requestType
                case 'resetPlotState'
                    app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', [], 'yLim', [], 'cLim', 'auto');
                    app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', app.bandObj.XLimits, 'yLim', app.bandObj.YLimitsLevel, 'cLim', 'auto');
                    app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', app.bandObj.XLimits, 'yLim', [], 'cLim', app.bandObj.CLimits);
                    app.restoreView(4) = struct('ID', 'app.UIAxes4', 'xLim', [], 'yLim', [], 'cLim', 'auto');

                case 'refreshGeoAxesPlotLimits'
                    geolimits(app.UIAxes1, 'auto')                    
                    app.restoreView(1).xLim = app.UIAxes1.LatitudeLimits;
                    app.restoreView(1).yLim = app.UIAxes1.LongitudeLimits;                    
                    geolimits(app.UIAxes1, 'manual')
            end
        end

        %-----------------------------------------------------------------%
        function dataSource = getActiveDataSource(app)
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
        function refreshPlots(app)
            specData = app.bandObj.SpecData;
            if isempty(specData)
                return
            end

            if isempty(app.plotHandles.clearWrite)
                % (a) Route+Distortion+Density+Car
                plotMeasurementRoute(app)
                plotDistortionAndDensity(app)

                plotOrUpdateVehicleMarker(app, 'Creation')
                plotOrUpdateAzimuthMeasure(app, 'Creation')
                
                % (b) ClearWrite+Persistance
                app.plotHandles.clearWrite = plot.draw2D.OrdinaryLine(app.UIAxes2, 'clearWrite', app.bandObj, app.sweepTimeIdx);
                plot.datatip.Template(app.plotHandles.clearWrite, "Frequency+Level", app.bandObj.LevelUnit)
                ensurePersistencePlot(app)                
                set(app.UIAxes2, 'XLim', app.restoreView(2).xLim, 'YLim', app.restoreView(2).yLim)

                % (c) Waterfall+Timeline
                plot.Waterfall('Creation', [], app.UIAxes3, app.bandObj, app.restoreView(2).xLim);
                app.plotHandles.waterfallTime = plot.draw2D.OrdinaryLine(app.UIAxes3, 'waterfallTime', app.bandObj, app.sweepTimeIdx);

                % (d) ChannelPower
                plotChannelPower(app)

                % (e) ChannelROI
                plotOrUpdateChannelRoi(app, 'Creation')

                % (f) Filters
                plotFilterRegions(app)

                % (g) Points
                plotHighlightedPoints(app)
                persistAxesViewLimits(app, 'refreshGeoAxesPlotLimits')
                
            else
                plot.draw2D.OrdinaryLineUpdate('clearWrite',    app.plotHandles.clearWrite,    app.bandObj, app.sweepTimeIdx);
                plot.draw2D.OrdinaryLineUpdate('waterfallTime', app.plotHandles.waterfallTime, app.bandObj, app.sweepTimeIdx);
                
                plotOrUpdateVehicleMarker(app, 'Update')
                plotOrUpdateAzimuthMeasure(app, 'Update')
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function ensurePersistencePlot(app)
            if isempty(app.plotHandles.persistence) && strcmp(app.PersistanceVisibility.Value, 'on')
                app.plotHandles.persistence = plot.Persistence('Creation', [], app.UIAxes2, app.bandObj, app.sweepTimeIdx);
            end
        end

        %-----------------------------------------------------------------%
        function refreshTimestampLabel(app)
            app.tool_TimestampLabel.Text = sprintf('%d de %d\n%s', app.sweepTimeIdx, app.bandObj.NumSweeps, app.bandObj.SpecData.Data{1}(app.sweepTimeIdx));
        end

        %-----------------------------------------------------------------%
        function plotMeasurementRoute(app)
            outTable  = app.emissionPoints.raw(~app.emissionPoints.raw.Filtered, :);
            inTable   = app.emissionPoints.raw;
            lineStyle = app.RouteLineStyle.Value;
            outColor  = app.RouteColorOut.Value;
            inColor   = app.RouteColorIn.Value;
            markerSize= app.RouteLineWidth.Value;

            plot.DriveTest.Route(app.UIAxes1, app.bandObj, outTable, inTable, lineStyle, outColor, inColor, markerSize)
        end

        %-----------------------------------------------------------------%
        function plotDistortionAndDensity(app)
            dataSource = getActiveDataSource(app);
            plotMode = app.UIAxes1.UserData.PlotMode;
            plotSize = app.axesTool_PlotSize.Value;

            switch dataSource
                case {'Raw', 'Filtered'}
                    srcTable = app.emissionPoints.filtered;

                case 'Data-Binning'
                    srcTable = app.emissionPoints.binned;
            end

            plot.DriveTest.DistortionAndDensityPlot(app.UIAxes1, app.bandObj, srcTable, plotMode, plotSize)
        end

        %-----------------------------------------------------------------%
        function plotFilterRegions(app)
            delete(findobj([app.UIAxes1.Children; app.UIAxes4.Children], 'Tag', 'filterROI'))
            app.filterTable = plot.DriveTest.FilterRegions(app.filterTable, app.UIAxes1, app.UIAxes4, @app.replotAfterFilterChange);
        end

        %-----------------------------------------------------------------%
        function plotHighlightedPoints(app)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'points', '-or', 'Tag', 'estimatedEmissorLocation'))

            if ~isempty(app.pointsTable)
                markerStyle = app.PointsMarker.Value;
                markerColor = app.PointsColor.Value;
                markerSize  = app.PointsSize.Value;

                plot.DriveTest.Points(app.UIAxes1, app.pointsTable, markerStyle, markerColor, markerSize)
                plot.axes.StackingOrder.execute(app.UIAxes1, 'appAnalise:DRIVETEST')
            end
        end

        %-----------------------------------------------------------------%
        function plotOrUpdateAzimuthMeasure(app, operationType)
            if ~ismember('Azimuth', app.emissionPoints.raw.Properties.VariableNames)
                return
            end

            lat1 = app.emissionPoints.raw.Latitude(app.sweepTimeIdx);
            lng1 = app.emissionPoints.raw.Longitude(app.sweepTimeIdx);
            azimuth = app.emissionPoints.raw.Azimuth(app.sweepTimeIdx);

            [lat2, lng2] = reckon(lat1, lng1, km2deg(1), azimuth);

            switch operationType
                case 'Creation'
                    app.plotHandles.azimuth = geoplot(app.UIAxes1, [lat1, lat2], [lng1, lng2], 'Color', app.CarColor.Value, 'DisplayName', 'Azimute', 'Tag', 'azimuth', 'PickableParts', 'none');

                case 'Update'
                    set(app.plotHandles.azimuth, 'LatitudeData', [lat1, lat2], 'LongitudeData', [lng1, lng2])
            end
        end

        %-----------------------------------------------------------------%
        function plotOrUpdateVehicleMarker(app, operationType)
            switch operationType
                case 'Creation'
                    app.plotHandles.car = geoscatter(app.UIAxes1, app.emissionPoints.raw.Latitude(app.sweepTimeIdx), app.emissionPoints.raw.Longitude(app.sweepTimeIdx), 'filled', ...
                        'Marker', app.CarMarker.Value, 'MarkerFaceColor', app.CarColor.Value, 'MarkerEdgeColor', 'black', ...
                        'SizeData', 10*app.CarSize.Value, 'PickableParts', 'none', 'DisplayName', 'Veículo', 'Tag', 'car');

                case 'Update'
                    set(app.plotHandles.car, 'LatitudeData', app.emissionPoints.raw.Latitude(app.sweepTimeIdx), ...
                                             'LongitudeData', app.emissionPoints.raw.Longitude(app.sweepTimeIdx))
            end
        end

        %-----------------------------------------------------------------%
        function plotChannelPower(app)
            color = app.ChannelPowerColor.Value;
            edgeAlpha = app.ChannelPowerEdgeAlpha.Value;
            faceAlpha = app.ChannelPowerFaceAlpha.Value;

            plot.DriveTest.ChannelPower(app.UIAxes4, app.bandObj, app.emissionPoints.raw, color, edgeAlpha, faceAlpha)
            set(findobj(app.UIAxes4), 'Visible', app.ChannelPowerVisibility.Value)
        end

        %-----------------------------------------------------------------%
        function plotOrUpdateChannelRoi(app, operationType)
            emissionIdx = app.emissionSelectedIdxs.emissionIdx;
            if isempty(emissionIdx)
                return
            end

            chFreqCenter = app.emissionSelectedIdxs.attributes.channel.Frequency;
            chBandWidth  = max(10, app.emissionSelectedIdxs.attributes.channel.ChannelBW);

            switch operationType
                case 'Creation'
                    srcROITable = table(chFreqCenter, chBandWidth, 'VariableNames', {'Frequency', 'BandWidthkHz'});
                    postPlotConfig = { ...
                        'InteractionsAllowed', 'none', ...
                        'Color', app.ChannelRoiColor.Value, ...
                        'EdgeAlpha', app.ChannelRoiEdgeAlpha.Value, ...
                        'FaceAlpha', app.ChannelRoiFaceAlpha.Value, ...
                        'Visible', app.ChannelRoiVisibility.Value ...
                    };
                    
                    plot.draw2D.rectangularROI(app.UIAxes2, app.bandObj, srcROITable, 1, 'channelROI', postPlotConfig, [-1000, 1000])
                    plot.draw2D.rectangularROI(app.UIAxes3, app.bandObj, srcROITable, 1, 'channelROI', postPlotConfig)

                case 'Relocate'
                    hChannelROI1 = findobj(app.UIAxes2.Children, 'Tag', 'channelROI');
                    hChannelROI2 = findobj(app.UIAxes3.Children, 'Tag', 'channelROI');

                    hChannelROI1.Position([1,3]) = [chFreqCenter - chBandWidth/2000, chBandWidth/1000];
                    hChannelROI2.Position([1,3]) = [chFreqCenter - chBandWidth/2000, chBandWidth/1000];
            end
        end

        %-----------------------------------------------------------------%
        function replotAfterFilterChange(app, roiHandle)
            arguments
                app
                roiHandle = []
            end

            if app.plotUpdateEvent
                app.plotUpdateEvent = 0;
            end
    
            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            specData = app.mainApp.specData(flowIdx);

            if ~isempty(roiHandle)
                [~, filterIdx] = ismember(roiHandle, [app.filterTable.roi.handle]);
                app.filterTable.roi(filterIdx).specification = plot.ROI.specification(roiHandle);
            end
    
            recomputeEmissionMeasures(app, specData, emissionIdx)
            persistEmissionDisplaySettings(app, specData, emissionIdx)
    
            % Isso força a reinicialização das tabelas e plot...
            app.emissionSelectedIdxs(:) = [];
            onEmissionDropDownValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function replotAfterPointsChange(app)
            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            specData = app.mainApp.specData(flowIdx);
            persistEmissionDisplaySettings(app, specData, emissionIdx)

            % Reinicializa uitree e plot...
            rebuildPointsTree(app)
            plotHighlightedPoints(app)
            persistAxesViewLimits(app, 'refreshGeoAxesPlotLimits')
        end

        %-----------------------------------------------------------------%
        % ## PLAYBACK ##
        %-----------------------------------------------------------------%
        function runPlaybackLoop(app, nSweeps)
            app.tool_Play.ImageSource = 'playback-stop-16px-gray.png';

            if ~app.plotHandles.clearWrite.Visible
                app.plotHandles.clearWrite.Visible = true;
            end

            while app.sweepTimeIdx <= nSweeps
                switch app.plotUpdateEvent
                    case -2
                        app.plotUpdateEvent = 1;

                        flowIdx = getSelectedFlowAndEmissionIndices(app);
                        loadSelectedFlow(app, flowIdx)

                        if isempty(flowIdx)
                            break
                        end
                        
                        nSweeps = numel(app.mainApp.specData(flowIdx).Data{1});

                    case -1
                        app.plotUpdateEvent = 1;
                        loadSelectedEmission(app)

                    case  0
                        break
                end

                sweepTic = tic;

                refreshPlots(app)
                refreshTimestampLabel(app)
                app.tool_TimestampSlider.Value = round(100 * app.sweepTimeIdx/nSweeps, 1);
                
                pause(max(app.mainApp.General.context.PLAYBACK.minSweepTimeSeconds - toc(sweepTic), .025)) % Valor mínimo: 25ms

                % Reload Flag
                if app.sweepTimeIdx == nSweeps
                    if ~app.tool_LoopControl.UserData.loopMode
                        break
                    end
                    app.sweepTimeIdx = 1;
                else
                    app.sweepTimeIdx = app.sweepTimeIdx+1;
                end       
            end

            app.plotUpdateEvent = 0;
            app.tool_Play.ImageSource = 'playback-play-16px-gray.png';
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

        % Image clicked function: FilterTreeButton, PointsTreeButton
        function onOpenPopupApp(app, event)
            
            if app.plotUpdateEvent
                app.plotUpdateEvent = 0;
            end

            switch event.Source
                case app.FilterTreeButton
                    dockAppTag = 'DriveTestFilter';
                case app.PointsTreeButton
                    dockAppTag = 'DriveTestPoints';
            end

            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            ipcMainMatlabOpenPopupApp(app.mainApp, app, dockAppTag, app.Context, flowIdx, emissionIdx)

        end

        % Value changed function: SpectrumFlowList
        function onFlowDropDownValueChanged(app, event)
            
            if app.plotUpdateEvent > 0
                app.plotUpdateEvent = -2;
            else
                flowIdx = getSelectedFlowAndEmissionIndices(app);
                loadSelectedFlow(app, flowIdx)
            end
            
        end

        % Value changed function: EmissionList
        function onEmissionDropDownValueChanged(app, event)
            
            if app.plotUpdateEvent > 0
                app.plotUpdateEvent = -1;
            else
                loadSelectedEmission(app)
                refreshPlots(app)
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

        % Image clicked function: axesTool_RegionZoom, axesTool_RestoreView
        function onAxesToolbarZoomControlButtonClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    try
                        geolimits(app.UIAxes1, app.restoreView(1).xLim, app.restoreView(1).yLim)
                    catch
                        persistAxesViewLimits(app, 'refreshGeoAxesPlotLimits')
                    end

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes1, app.axesTool_RegionZoom)
            end

        end

        % Value changed function: DataBinningFcn, DataBinningLength, 
        % ...and 1 other component
        function onAxesToolbarDataSourceChanged(app, event)

            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            specData = app.mainApp.specData(flowIdx);

            switch event.Source
                case app.axesTool_DataSourceDropDown
                    syncDataSourceToolbarState(app)
                    persistEmissionDisplaySettings(app, specData, emissionIdx)

                case {app.DataBinningLength, app.DataBinningFcn}
                    recomputeEmissionMeasures(app, specData, emissionIdx)
                    persistEmissionDisplaySettings(app, specData, emissionIdx)

                    % Se o plot em evidência é o gerado pelas informações
                    % brutas (e não pela processada via Data-Binning), então 
                    % não é necessário redesenhá-lo.
                    if app.axesTool_DataSourceDropDown.Value == "Dados brutos"
                        return
                    end
            end

            % Isso força a reinicialização das tabelas e plot...
            app.emissionSelectedIdxs(:) = [];
            onEmissionDropDownValueChanged(app)

        end

        % Image clicked function: axesTool_DensityPlot, 
        % ...and 1 other component
        function onAxesToolbarPlotTypeChanged(app, event)

            hDistortion = findobj(app.UIAxes1.Children, 'Tag', 'distortion');
            hDensity    = findobj(app.UIAxes1.Children, 'Tag', 'density');

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

            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            specData = app.mainApp.specData(flowIdx);
            persistEmissionDisplaySettings(app, specData, emissionIdx)

        end

        % Value changed function: axesTool_PlotSize
        function onAxesToolbarPlotSizeChanged(app, event)

            % Como exposto em onAxesToolbarPlotSizeChanging(app, event),
            % o plot de distorção será atualizado em "tempo real", no 
            % "ValueChangingFcn", mas o plot de densidade apenas no callback 
            % "ValueChangedFcn".

            hDensity = findobj(app.UIAxes1.Children, 'Tag', 'density');

            if hDensity.Visible
                set(findobj(app.UIAxes1.Children, 'Tag', 'density'), 'Radius',  100*event.Value)
                drawnow
            end

            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            specData = app.mainApp.specData(flowIdx);
            persistEmissionDisplaySettings(app, specData, emissionIdx)
            
        end

        % Value changing function: axesTool_PlotSize
        function onAxesToolbarPlotSizeChanging(app, event)
            
            % Ao interagir com o slider, não soltando o mouse, o MATLAB dispara 
            % apenas o evento "ValueChangingFcn". Ao soltar o botão do mouse, o 
            % MATLAB dispara, nesta ordem, os eventos "ValueChangingFcn" e 
            % "ValueChangedFcn".

            % Nesse contexto, considerando que o plot de densidade demora
            % para atualizar, o plot de distorção será atualizado em "tempo
            % real", no "ValueChangingFcn", mas o plot de densidade apenas 
            % no callback "ValueChangedFcn".

            hDistortion = findobj(app.UIAxes1.Children, 'Tag', 'distortion');

            if hDistortion.Visible
                set(findobj(app.UIAxes1.Children, 'Tag', 'distortion'), 'SizeData', 20*event.Value)
            end
            
        end

        % Image clicked function: axesTool_Target
        function onAxesToolbarTargetButtonClicked(app, event)
            
            specData = app.bandObj.SpecData;
            [~, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            if isempty(emissionIdx)
                return
            end

            if numel(specData.Data) > 3
                questionMsg = 'Os dados possuem informação de azimute, de forma que pode ser aplicada não apenas o PoA, mas também o AoA, na estimativa do local de geração da emissão sob análise?<br><br> Qual técnica deseja simular?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'PoA', 'AoA', 'Cancelar'}, 1, 3);
                if userSelection == "Cancelar"
                    return
                end

                algorithm = userSelection;

            else
                algorithm = 'PoA';
            end

            try
                estimatedLatitude  = NaN;
                estimatedLongitude = NaN;

                geoLocationIdxs = find(strcmp(app.pointsTable.type, 'GeoLocation'))';
                if ~isempty(geoLocationIdxs)
                    for ii = geoLocationIdxs
                        if strcmp(app.pointsTable.value(ii).source, algorithm)
                            estimatedLatitude  = app.pointsTable.value(ii).data.estimatedLatitude;
                            estimatedLongitude = app.pointsTable.value(ii).data.estimatedLongitude;
                            
                            break
                        end
                    end
                end

                if isnan(estimatedLatitude) || isnan(estimatedLongitude)
                    app.progressDialog.Visible = 'visible';

                    frequencyCenterMHz = specData.UserData.Emissions.Frequency(emissionIdx);
                    bandWidthkHz = specData.UserData.Emissions.BandWidthkHz(emissionIdx);
                    algorithmFcn = str2func(sprintf('RF.Geolocation.%s%s', lower(algorithm(1)), algorithm(2:end)));
                    [estimatedLatitude, estimatedLongitude, uncertaintyRadius] = algorithmFcn(specData, frequencyCenterMHz, bandWidthkHz);

                    app.progressDialog.Visible = 'hidden';

                    if isnan(estimatedLatitude) || isnan(estimatedLongitude)
                        error('Dados insuficientes para estimar o local de geração da emissão.')
                    end

                    if isnan(uncertaintyRadius) || uncertaintyRadius < 0
                        uncertaintyRadius = 500;
                    end

                    newRowType = 'GeoLocation';
                    newRowData = struct('source', algorithm, 'data', struct('estimatedLatitude', estimatedLatitude, 'estimatedLongitude', estimatedLongitude, 'uncertaintyRadius', uncertaintyRadius), 'dataIdx', algorithm);
                    newRowHash = Hash.sha1(sprintf('%s - %s', newRowType, jsonencode(newRowData)));

                    app.pointsTable(end+1, :) = {newRowType, newRowData, true, newRowHash};
                    replotAfterPointsChange(app)

                else
                    plotHighlightedPoints(app)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

        end

        % Image clicked function: tool_LayoutLeft, tool_LayoutRight
        function onToolbarPanelVisibilityChanged(app, event)

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
        function onToolbarPlaybackControlChanged(app, event)
            
            switch event.Source
                case app.tool_Play
                    flowIdx = getSelectedFlowAndEmissionIndices(app);

                    if ~isempty(flowIdx) && ~app.plotUpdateEvent
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onPlaybackStarted')

                        app.plotUpdateEvent = 1;
                        try
                            runPlaybackLoop(app, numel(app.mainApp.specData(flowIdx).Data{1}))
                        catch
                        end
                    else
                        app.plotUpdateEvent = 0;
                    end

                %---------------------------------------------------------%
                case app.tool_LoopControl
                     app.tool_LoopControl.UserData.loopMode = ~ app.tool_LoopControl.UserData.loopMode;

                     if app.tool_LoopControl.UserData.loopMode
                         app.tool_LoopControl.ImageSource = 'playback-loop-36px-gray.png';
                     else
                         app.tool_LoopControl.ImageSource = 'playback-straight-36px-gray.png';
                    end
            end

        end

        % Callback function: tool_TimestampSlider, tool_TimestampSlider
        function onToolbarTimelineSliderChanging(app, event)
            
            nSweeps = app.bandObj.NumSweeps;            
            app.sweepTimeIdx = round(event.Value/100 * nSweeps);
            
            if app.sweepTimeIdx < 1
                app.sweepTimeIdx = 1;
            elseif app.sweepTimeIdx > nSweeps
                app.sweepTimeIdx = nSweeps;
            end

            if ~app.plotUpdateEvent
                plot.draw2D.OrdinaryLineUpdate('clearWrite',    app.plotHandles.clearWrite,    app.bandObj, app.sweepTimeIdx);
                plot.draw2D.OrdinaryLineUpdate('waterfallTime', app.plotHandles.waterfallTime, app.bandObj, app.sweepTimeIdx);
                
                plotOrUpdateVehicleMarker(app, 'Update')
                plotOrUpdateAzimuthMeasure(app, 'Update')

                refreshTimestampLabel(app)
            end

        end

        % Menu selected function: DeleteAllEntries, DeleteSelectedItem
        function onContextMenuItemClicked(app, event)
            
            contextObject = event.ContextObject.Parent;
            idx = [];

            switch event.Source
                case app.DeleteSelectedItem
                    if isempty(contextObject.SelectedNodes)
                        return
                    end
                    idx = arrayfun(@(x) x.NodeData, contextObject.SelectedNodes);

                case app.DeleteAllEntries
                    switch contextObject
                        case app.FilterTree
                            idx = 1:height(app.filterTable);
                        case app.PointsTree
                            idx = 1:height(app.pointsTable);
                    end
            end 
    
            if ~isempty(idx)
                switch contextObject
                    case app.FilterTree
                        app.filterTable(idx,:) = [];
                        rebuildFilterTree(app)
                        replotAfterFilterChange(app)

                    case app.PointsTree
                        app.pointsTable(idx, :) = [];
                        replotAfterPointsChange(app)
                end
            end

        end

        % Selection changed function: FilterTree
        function onFilterTreeSelectionChanged(app, event)
            
            if ~isempty(app.FilterTree.SelectedNodes)
                filterSelectionIdx = app.FilterTree.SelectedNodes.NodeData;        
    
                for ii = 1:height(app.filterTable)
                    roiHandle = app.filterTable.roi(ii).handle;
                    roiClass  = class(roiHandle);

                    switch roiClass
                        case 'map.graphics.chart.primitive.Polygon'
                            if ii ~= filterSelectionIdx
                                roiHandle.LineWidth = .5;
                            else
                                roiHandle.LineWidth = 2.5;
                            end

                        otherwise
                            if ii ~= filterSelectionIdx
                                set(roiHandle, LineWidth=.5, InteractionsAllowed='none')
                            else
                                switch roiClass
                                    case 'images.roi.Line'
                                        set(roiHandle, LineWidth=2.5, InteractionsAllowed='translate')
                                    otherwise
                                        set(roiHandle, LineWidth=2.5, InteractionsAllowed='all')
                                end
                            end
                    end
                end

                uistack(app.filterTable.roi(filterSelectionIdx).handle, "top")

            else
                roiHandles = [app.filterTable.roi.handle];
                for roiHandle = roiHandles
                    roiHandle.LineWidth = .5;
                    if isprop(roiHandle, 'InteractionsAllowed')
                        roiHandle.InteractionsAllowed = 'none';
                    end
                end    
            end
            
        end

        % Callback function: PointsTree
        function onPointsTreeCheckedNodesChanged(app, event)
            
            visibleNodeData   = arrayfun(@(x) x.NodeData, app.PointsTree.CheckedNodes);
            invisibleNodeData = setdiff(1:height(app.pointsTable), visibleNodeData);

            app.pointsTable.visible(visibleNodeData)   = true;
            app.pointsTable.visible(invisibleNodeData) = false;

            plotHighlightedPoints(app)
            persistAxesViewLimits(app, 'refreshGeoAxesPlotLimits')
            
        end

        % Value changed function: BandGuardBWRelatedValue, 
        % ...and 11 other components
        function onCustomizableParameterValueChanged(app, event)
            
            [flowIdx, emissionIdx] = getSelectedFlowAndEmissionIndices(app);
            if isempty(flowIdx)
                return
            end

            specData = app.mainApp.specData(flowIdx);

            switch event.Source
                case app.Colormap
                    if strcmp(app.UIAxes1.UserData.Colormap, event.Value)
                        return
                    end

                    plot.axes.Colormap(app.UIAxes1, event.Value)

                case app.Basemap
                    app.UIAxes1.Basemap = event.Value;
                    switch event.Value
                        case {'darkwater', 'none'}
                            app.UIAxes1.Grid = 'on';
                        otherwise
                            app.UIAxes1.Grid = 'off';
                    end

                case app.RouteLineStyle
                    switch event.Value
                        case 'none'
                            markerSize = 1;
                        otherwise
                            markerSize = 8*app.RouteLineWidth.Value;
                    end
                    set(findobj(app.UIAxes1.Children, 'Tag', 'routeFailFilter'),                           'MarkerSize', markerSize)
                    set(findobj(app.UIAxes1.Children, 'Tag', 'routePassFilter'), 'LineStyle', event.Value, 'MarkerSize', markerSize)

                case app.RouteColorOut
                    selectedColor = event.Value;
                    set(findobj(app.UIAxes1.Children, 'Tag', 'routeFailFilter'), 'Color', selectedColor, 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.RouteColorIn
                    selectedColor = event.Value;
                    set(findobj(app.UIAxes1.Children, 'Tag', 'routePassFilter'), 'Color', selectedColor, 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.RouteLineWidth
                    if ~strcmp(app.RouteLineWidth.Value, 'none')
                        set(findobj(app.UIAxes1.Children, 'Tag', 'routeFailFilter'), 'MarkerSize', 8*event.Value)
                        set(findobj(app.UIAxes1.Children, 'Tag', 'routePassFilter'), 'MarkerSize', 8*event.Value)
                    end

                case app.PointsMarker
                    set(findobj(app.UIAxes1.Children, 'Tag', 'points'), 'Marker', event.Value)

                case app.PointsColor
                    selectedColor = event.Value;
                    hPoints = findobj(app.UIAxes1.Children, 'Tag', 'points');
                    for ii = 1:numel(hPoints)
                        if strcmp(hPoints(ii).MarkerFaceColor, 'none')
                            set(hPoints(ii), 'MarkerEdgeColor', selectedColor)
                        else
                            set(hPoints(ii), 'MarkerFaceColor', imageUtil.deriveFaceColor(selectedColor), 'MarkerEdgeColor', selectedColor)
                        end
                    end
                
                case app.PointsSize
                    set(findobj(app.UIAxes1.Children, 'Tag', 'points'), 'MarkerSize', event.Value)

                case app.BandGuardType
                    guardBandType = event.Value;
                    chBandWidthkHz = app.emissionSelectedIdxs.attributes.channel.ChannelBW;

                    switch guardBandType
                        case 'Fixed'
                            guardBandValue = limitGuardBandValue(app, app.BandGuardBWRelatedValue.Value * chBandWidthkHz, chBandWidthkHz);
                            syncScreenSpanControls(app, 'Fixed', guardBandValue / 1000) % kHz >> MHz

                        otherwise % 'BWRelated'
                            guardBandValue = app.BandGuardFixedValue.Value / chBandWidthkHz;
                            syncScreenSpanControls(app, 'BWRelated', guardBandValue)
                    end

                    onCustomizableParameterValueChanged(app, struct('Source', app.BandGuardFixedValue, 'Value', guardBandValue))

                case {app.BandGuardFixedValue, app.BandGuardBWRelatedValue}
                    bandGuardType = app.BandGuardType.Value;
                    switch bandGuardType
                        case 'Fixed'
                            chBandWidthkHz = app.emissionSelectedIdxs.attributes.channel.ChannelBW;
                            bandGuardValue = limitGuardBandValue(app, app.BandGuardFixedValue.Value, chBandWidthkHz);
                            app.BandGuardFixedValue.Value = bandGuardValue;
                            bandGuardValue = bandGuardValue / 1000; % kHz >> MHz

                        otherwise % 'BWRelated'
                            bandGuardValue = app.BandGuardBWRelatedValue.Value;
                    end

                    guardBand = resolveScreenSpan(app, specData, emissionIdx);
                    guardBand.Parameters.Type  = bandGuardType;
                    guardBand.Parameters.Value = bandGuardValue;

                    updateSpectrumInfo(app.bandObj, specData, emissionIdx, guardBand);
                    xLimits = app.bandObj.XLimits;

                    app.UIAxes2.XLim = xLimits;
                    app.restoreView(2).xLim = xLimits;
                    app.restoreView(3).xLim = xLimits;

                    % Como estou usando o renderizador "image" (ao invés de
                    % mesh), preciso plotar novamente o waterfall toda vez
                    % que é alterado o parâmetro, de forma que não seja
                    % perdida a interação datatips.
                    delete(findobj(app.UIAxes3, 'Tag', 'waterfall'))
                    plot.Waterfall('Creation', [], app.UIAxes3, app.bandObj, xLimits);
                    plot.axes.StackingOrder.execute(app.UIAxes3, 'appAnalise:DRIVETEST')
            end

            persistEmissionDisplaySettings(app, specData, emissionIdx)

        end

        % Value changed function: CarColor, CarMarker, CarSize, 
        % ...and 9 other components
        function onNonCustomizableParameterValueChanged(app, event)
            
            switch event.Source
                case app.CarMarker
                    set(app.plotHandles.car, 'Marker', event.Value)

                case app.CarColor
                    selectedColor = event.Value;
                    set(app.plotHandles.car, 'MarkerFaceColor', selectedColor)

                case app.CarSize
                    set(app.plotHandles.car, 'SizeData', 10 * event.Value)

                case app.PersistanceVisibility
                    elHandles = findobj(app.UIAxes2.Children, 'Tag', 'persistence');
                    set(elHandles, 'Visible', event.Value)

                case app.ChannelRoiVisibility
                    elHandles = findobj([app.UIAxes2.Children; app.UIAxes3.Children], 'Tag', 'channelROI');
                    set(elHandles, 'Visible', event.Value)

                case {app.ChannelRoiColor, app.ChannelRoiEdgeAlpha, app.ChannelRoiFaceAlpha}                    
                    elHandles = findobj([app.UIAxes2.Children; app.UIAxes3.Children], 'Tag', 'channelROI');
                    set(elHandles, 'Color',     app.ChannelRoiColor.Value,     ...
                                   'EdgeAlpha', app.ChannelRoiEdgeAlpha.Value, ...
                                   'FaceAlpha', app.ChannelRoiFaceAlpha.Value)

                case app.ChannelPowerVisibility
                    set(findobj(app.UIAxes4), 'Visible', event.Value)

                case {app.ChannelPowerColor, app.ChannelPowerEdgeAlpha, app.ChannelPowerFaceAlpha}
                    elHandles = findobj(app.UIAxes4.Children, 'Tag', 'channelPower');
                    set(elHandles, 'EdgeColor', app.ChannelPowerColor.Value,     ...
                                   'FaceColor', app.ChannelPowerColor.Value,     ...
                                   'EdgeAlpha', app.ChannelPowerEdgeAlpha.Value, ...
                                   'FaceAlpha', app.ChannelPowerFaceAlpha.Value)
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
            app.GridLayout.ColumnWidth = {10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 233, 196, '1x', 22};
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
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @onToolbarPanelVisibilityChanged, true);
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

            % Create tool_Play
            app.tool_Play = uiimage(app.Toolbar);
            app.tool_Play.ScaleMethod = 'none';
            app.tool_Play.ImageClickedFcn = createCallbackFcn(app, @onToolbarPlaybackControlChanged, true);
            app.tool_Play.Enable = 'off';
            app.tool_Play.Layout.Row = [1 3];
            app.tool_Play.Layout.Column = 3;
            app.tool_Play.ImageSource = 'playback-play-16px-gray.png';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.ImageClickedFcn = createCallbackFcn(app, @onToolbarPlaybackControlChanged, true);
            app.tool_LoopControl.Enable = 'off';
            app.tool_LoopControl.Layout.Row = [1 3];
            app.tool_LoopControl.Layout.Column = 4;
            app.tool_LoopControl.ImageSource = 'playback-loop-36px-gray.png';

            % Create tool_TimestampSlider
            app.tool_TimestampSlider = uislider(app.Toolbar);
            app.tool_TimestampSlider.MajorTicks = [0 50 100];
            app.tool_TimestampSlider.MajorTickLabels = {'0', '50', '100'};
            app.tool_TimestampSlider.ValueChangedFcn = createCallbackFcn(app, @onToolbarTimelineSliderChanging, true);
            app.tool_TimestampSlider.ValueChangingFcn = createCallbackFcn(app, @onToolbarTimelineSliderChanging, true);
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

            % Create tool_LayoutRight
            app.tool_LayoutRight = uiimage(app.Toolbar);
            app.tool_LayoutRight.ScaleMethod = 'none';
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @onToolbarPanelVisibilityChanged, true);
            app.tool_LayoutRight.Layout.Row = [1 3];
            app.tool_LayoutRight.Layout.Column = 8;
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
            app.EmissionPanelGrid.RowHeight = {10, 25, 22, 5, 78, 10, 25, 22, 5, '1x', 10};
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
            app.DataBinningLength.ValueChangedFcn = createCallbackFcn(app, @onAxesToolbarDataSourceChanged, true);
            app.DataBinningLength.FontSize = 11;
            app.DataBinningLength.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataBinningLength.Enable = 'off';
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
            app.DataBinningFcn.ValueChangedFcn = createCallbackFcn(app, @onAxesToolbarDataSourceChanged, true);
            app.DataBinningFcn.Enable = 'off';
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
            app.FilterTreeButton.ScaleMethod = 'none';
            app.FilterTreeButton.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.FilterTreeButton.Enable = 'off';
            app.FilterTreeButton.Layout.Row = 8;
            app.FilterTreeButton.Layout.Column = 4;
            app.FilterTreeButton.VerticalAlignment = 'bottom';
            app.FilterTreeButton.ImageSource = 'filter.svg';

            % Create FilterTree
            app.FilterTree = uitree(app.EmissionPanelGrid);
            app.FilterTree.SelectionChangedFcn = createCallbackFcn(app, @onFilterTreeSelectionChanged, true);
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
            app.PointsTreeButton.ScaleMethod = 'none';
            app.PointsTreeButton.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.PointsTreeButton.Enable = 'off';
            app.PointsTreeButton.Layout.Row = 3;
            app.PointsTreeButton.Layout.Column = 7;
            app.PointsTreeButton.VerticalAlignment = 'bottom';
            app.PointsTreeButton.ImageSource = 'Pin_18.png';

            % Create PointsTree
            app.PointsTree = uitree(app.EmissionPanelGrid, 'checkbox');
            app.PointsTree.FontSize = 10.5;
            app.PointsTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PointsTree.Layout.Row = [5 10];
            app.PointsTree.Layout.Column = [6 7];

            % Assign Checked Nodes
            app.PointsTree.CheckedNodesChangedFcn = createCallbackFcn(app, @onPointsTreeCheckedNodesChanged, true);

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
            app.RightPanel.ColumnWidth = {18, 209};
            app.RightPanel.RowHeight = {5, 17, 5, 208, 5, 5, 17, 5, '1x'};
            app.RightPanel.ColumnSpacing = 5;
            app.RightPanel.RowSpacing = 0;
            app.RightPanel.Padding = [0 0 0 0];
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
            app.GeographicAxesPanel.Layout.Column = [1 2];

            % Create GeographicAxesPanelGrid
            app.GeographicAxesPanelGrid = uigridlayout(app.GeographicAxesPanel);
            app.GeographicAxesPanelGrid.ColumnWidth = {57, 36, 36, 51};
            app.GeographicAxesPanelGrid.RowHeight = {17, 22, 17, 22, 17, 22, 17, 22};
            app.GeographicAxesPanelGrid.RowSpacing = 5;
            app.GeographicAxesPanelGrid.Padding = [10 10 10 5];
            app.GeographicAxesPanelGrid.BackgroundColor = [1 1 1];

            % Create ColormapLabel
            app.ColormapLabel = uilabel(app.GeographicAxesPanelGrid);
            app.ColormapLabel.VerticalAlignment = 'bottom';
            app.ColormapLabel.FontSize = 11;
            app.ColormapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ColormapLabel.Layout.Row = 1;
            app.ColormapLabel.Layout.Column = [1 2];
            app.ColormapLabel.Text = 'Mapa de cor:';

            % Create Colormap
            app.Colormap = uidropdown(app.GeographicAxesPanelGrid);
            app.Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.Colormap.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.Colormap.Enable = 'off';
            app.Colormap.FontSize = 11;
            app.Colormap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Colormap.BackgroundColor = [1 1 1];
            app.Colormap.Layout.Row = 2;
            app.Colormap.Layout.Column = [1 2];
            app.Colormap.Value = 'winter';

            % Create BasemapLabel
            app.BasemapLabel = uilabel(app.GeographicAxesPanelGrid);
            app.BasemapLabel.VerticalAlignment = 'bottom';
            app.BasemapLabel.FontSize = 11;
            app.BasemapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BasemapLabel.Layout.Row = 1;
            app.BasemapLabel.Layout.Column = [3 4];
            app.BasemapLabel.Text = 'Mapa base:';

            % Create Basemap
            app.Basemap = uidropdown(app.GeographicAxesPanelGrid);
            app.Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.Basemap.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.Basemap.Enable = 'off';
            app.Basemap.FontSize = 11;
            app.Basemap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Basemap.BackgroundColor = [1 1 1];
            app.Basemap.Layout.Row = 2;
            app.Basemap.Layout.Column = [3 4];
            app.Basemap.Value = 'none';

            % Create RouteStyleLabel
            app.RouteStyleLabel = uilabel(app.GeographicAxesPanelGrid);
            app.RouteStyleLabel.VerticalAlignment = 'bottom';
            app.RouteStyleLabel.FontSize = 11;
            app.RouteStyleLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RouteStyleLabel.Layout.Row = 3;
            app.RouteStyleLabel.Layout.Column = [1 2];
            app.RouteStyleLabel.Text = 'Rota:';

            % Create RouteLineStyle
            app.RouteLineStyle = uidropdown(app.GeographicAxesPanelGrid);
            app.RouteLineStyle.Items = {'none', ':', '-'};
            app.RouteLineStyle.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.RouteLineStyle.Enable = 'off';
            app.RouteLineStyle.FontSize = 11;
            app.RouteLineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RouteLineStyle.BackgroundColor = [1 1 1];
            app.RouteLineStyle.Layout.Row = 4;
            app.RouteLineStyle.Layout.Column = 1;
            app.RouteLineStyle.Value = ':';

            % Create RouteColorOut
            app.RouteColorOut = uicolorpicker(app.GeographicAxesPanelGrid);
            app.RouteColorOut.Value = [0.502 0.502 0.502];
            app.RouteColorOut.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.RouteColorOut.Enable = 'off';
            app.RouteColorOut.Layout.Row = 4;
            app.RouteColorOut.Layout.Column = 2;
            app.RouteColorOut.BackgroundColor = [1 1 1];

            % Create RouteColorIn
            app.RouteColorIn = uicolorpicker(app.GeographicAxesPanelGrid);
            app.RouteColorIn.Value = [0.8706 0.5412 0.5412];
            app.RouteColorIn.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.RouteColorIn.Enable = 'off';
            app.RouteColorIn.Layout.Row = 4;
            app.RouteColorIn.Layout.Column = 3;
            app.RouteColorIn.BackgroundColor = [1 1 1];

            % Create RouteLineWidth
            app.RouteLineWidth = uislider(app.GeographicAxesPanelGrid);
            app.RouteLineWidth.Limits = [1 9];
            app.RouteLineWidth.MajorTicks = [];
            app.RouteLineWidth.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.RouteLineWidth.MinorTicks = [1 2.6 4.2 5.8 7.4 9];
            app.RouteLineWidth.Enable = 'off';
            app.RouteLineWidth.Layout.Row = 4;
            app.RouteLineWidth.Layout.Column = 4;
            app.RouteLineWidth.Value = 1;

            % Create CarLabel
            app.CarLabel = uilabel(app.GeographicAxesPanelGrid);
            app.CarLabel.VerticalAlignment = 'bottom';
            app.CarLabel.FontSize = 11;
            app.CarLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.CarLabel.Layout.Row = 5;
            app.CarLabel.Layout.Column = [1 2];
            app.CarLabel.Text = 'Veículo:';

            % Create CarMarker
            app.CarMarker = uidropdown(app.GeographicAxesPanelGrid);
            app.CarMarker.Items = {'none', 'o', 'square', '^'};
            app.CarMarker.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.CarMarker.Enable = 'off';
            app.CarMarker.FontSize = 11;
            app.CarMarker.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.CarMarker.BackgroundColor = [1 1 1];
            app.CarMarker.Layout.Row = 6;
            app.CarMarker.Layout.Column = [1 2];
            app.CarMarker.Value = 'square';

            % Create CarColor
            app.CarColor = uicolorpicker(app.GeographicAxesPanelGrid);
            app.CarColor.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.CarColor.Enable = 'off';
            app.CarColor.Layout.Row = 6;
            app.CarColor.Layout.Column = 3;
            app.CarColor.BackgroundColor = [1 1 1];

            % Create CarSize
            app.CarSize = uislider(app.GeographicAxesPanelGrid);
            app.CarSize.Limits = [1 19];
            app.CarSize.MajorTicks = [];
            app.CarSize.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.CarSize.MinorTicks = [1 4.6 8.2 11.8 15.4 19];
            app.CarSize.Enable = 'off';
            app.CarSize.Layout.Row = 6;
            app.CarSize.Layout.Column = 4;
            app.CarSize.Value = 10;

            % Create PointsLabel
            app.PointsLabel = uilabel(app.GeographicAxesPanelGrid);
            app.PointsLabel.VerticalAlignment = 'bottom';
            app.PointsLabel.FontSize = 11;
            app.PointsLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PointsLabel.Layout.Row = 7;
            app.PointsLabel.Layout.Column = [1 3];
            app.PointsLabel.Text = 'Pontos de interesse:';

            % Create PointsMarker
            app.PointsMarker = uidropdown(app.GeographicAxesPanelGrid);
            app.PointsMarker.Items = {'none', 'o', 'square', '^'};
            app.PointsMarker.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.PointsMarker.Enable = 'off';
            app.PointsMarker.FontSize = 11;
            app.PointsMarker.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PointsMarker.BackgroundColor = [1 1 1];
            app.PointsMarker.Layout.Row = 8;
            app.PointsMarker.Layout.Column = [1 2];
            app.PointsMarker.Value = '^';

            % Create PointsColor
            app.PointsColor = uicolorpicker(app.GeographicAxesPanelGrid);
            app.PointsColor.Value = [1 1 0.0706];
            app.PointsColor.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.PointsColor.Enable = 'off';
            app.PointsColor.Layout.Row = 8;
            app.PointsColor.Layout.Column = 3;
            app.PointsColor.BackgroundColor = [1 1 1];

            % Create PointsSize
            app.PointsSize = uislider(app.GeographicAxesPanelGrid);
            app.PointsSize.Limits = [9 15];
            app.PointsSize.MajorTicks = [];
            app.PointsSize.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.PointsSize.MinorTicks = [9 10 11 12 13 14 15];
            app.PointsSize.Enable = 'off';
            app.PointsSize.Layout.Row = 8;
            app.PointsSize.Layout.Column = 4;
            app.PointsSize.Value = 12;

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
            app.CartesianAxesPanel.Layout.Column = [1 2];

            % Create CartesianAxesGrid
            app.CartesianAxesGrid = uigridlayout(app.CartesianAxesPanel);
            app.CartesianAxesGrid.ColumnWidth = {48, 36, 48, 48};
            app.CartesianAxesGrid.RowHeight = {18, 22, 36, 22, 36, 22, 22, 22};
            app.CartesianAxesGrid.RowSpacing = 5;
            app.CartesianAxesGrid.Padding = [10 10 10 5];
            app.CartesianAxesGrid.BackgroundColor = [1 1 1];

            % Create PersistanceLabel
            app.PersistanceLabel = uilabel(app.CartesianAxesGrid);
            app.PersistanceLabel.VerticalAlignment = 'bottom';
            app.PersistanceLabel.FontSize = 11;
            app.PersistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PersistanceLabel.Layout.Row = 1;
            app.PersistanceLabel.Layout.Column = [1 3];
            app.PersistanceLabel.Text = 'Persistência:';

            % Create PersistanceVisibility
            app.PersistanceVisibility = uidropdown(app.CartesianAxesGrid);
            app.PersistanceVisibility.Items = {'on', 'off'};
            app.PersistanceVisibility.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.PersistanceVisibility.Enable = 'off';
            app.PersistanceVisibility.FontSize = 11;
            app.PersistanceVisibility.BackgroundColor = [1 1 1];
            app.PersistanceVisibility.Layout.Row = 2;
            app.PersistanceVisibility.Layout.Column = 1;
            app.PersistanceVisibility.Value = 'on';

            % Create ChannelRoiLabel
            app.ChannelRoiLabel = uilabel(app.CartesianAxesGrid);
            app.ChannelRoiLabel.VerticalAlignment = 'bottom';
            app.ChannelRoiLabel.FontSize = 11;
            app.ChannelRoiLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ChannelRoiLabel.Layout.Row = 3;
            app.ChannelRoiLabel.Layout.Column = [1 4];
            app.ChannelRoiLabel.Interpreter = 'html';
            app.ChannelRoiLabel.Text = 'Canal:<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Visibilidade e estilo de exibição.</p>';

            % Create ChannelRoiVisibility
            app.ChannelRoiVisibility = uidropdown(app.CartesianAxesGrid);
            app.ChannelRoiVisibility.Items = {'on', 'off'};
            app.ChannelRoiVisibility.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelRoiVisibility.Enable = 'off';
            app.ChannelRoiVisibility.FontSize = 11;
            app.ChannelRoiVisibility.BackgroundColor = [1 1 1];
            app.ChannelRoiVisibility.Layout.Row = 4;
            app.ChannelRoiVisibility.Layout.Column = 1;
            app.ChannelRoiVisibility.Value = 'on';

            % Create ChannelRoiColor
            app.ChannelRoiColor = uicolorpicker(app.CartesianAxesGrid);
            app.ChannelRoiColor.Value = [0.7216 0.2706 1];
            app.ChannelRoiColor.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelRoiColor.Enable = 'off';
            app.ChannelRoiColor.Layout.Row = 4;
            app.ChannelRoiColor.Layout.Column = 2;
            app.ChannelRoiColor.BackgroundColor = [1 1 1];

            % Create ChannelRoiEdgeAlpha
            app.ChannelRoiEdgeAlpha = uispinner(app.CartesianAxesGrid);
            app.ChannelRoiEdgeAlpha.Step = 0.1;
            app.ChannelRoiEdgeAlpha.Limits = [0 1];
            app.ChannelRoiEdgeAlpha.ValueDisplayFormat = '%.1f';
            app.ChannelRoiEdgeAlpha.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelRoiEdgeAlpha.FontSize = 11;
            app.ChannelRoiEdgeAlpha.Enable = 'off';
            app.ChannelRoiEdgeAlpha.Layout.Row = 4;
            app.ChannelRoiEdgeAlpha.Layout.Column = 3;

            % Create ChannelRoiFaceAlpha
            app.ChannelRoiFaceAlpha = uispinner(app.CartesianAxesGrid);
            app.ChannelRoiFaceAlpha.Step = 0.1;
            app.ChannelRoiFaceAlpha.Limits = [0 1];
            app.ChannelRoiFaceAlpha.ValueDisplayFormat = '%.1f';
            app.ChannelRoiFaceAlpha.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelRoiFaceAlpha.FontSize = 11;
            app.ChannelRoiFaceAlpha.Enable = 'off';
            app.ChannelRoiFaceAlpha.Layout.Row = 4;
            app.ChannelRoiFaceAlpha.Layout.Column = 4;
            app.ChannelRoiFaceAlpha.Value = 0.4;

            % Create ChannelPowerLabel
            app.ChannelPowerLabel = uilabel(app.CartesianAxesGrid);
            app.ChannelPowerLabel.VerticalAlignment = 'bottom';
            app.ChannelPowerLabel.FontSize = 11;
            app.ChannelPowerLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ChannelPowerLabel.Layout.Row = 5;
            app.ChannelPowerLabel.Layout.Column = [1 4];
            app.ChannelPowerLabel.Interpreter = 'html';
            app.ChannelPowerLabel.Text = 'Potência do canal:<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Visibilidade e estilo de exibição.</p>';

            % Create ChannelPowerVisibility
            app.ChannelPowerVisibility = uidropdown(app.CartesianAxesGrid);
            app.ChannelPowerVisibility.Items = {'on', 'off'};
            app.ChannelPowerVisibility.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelPowerVisibility.Enable = 'off';
            app.ChannelPowerVisibility.FontSize = 11;
            app.ChannelPowerVisibility.BackgroundColor = [1 1 1];
            app.ChannelPowerVisibility.Layout.Row = 6;
            app.ChannelPowerVisibility.Layout.Column = 1;
            app.ChannelPowerVisibility.Value = 'on';

            % Create ChannelPowerColor
            app.ChannelPowerColor = uicolorpicker(app.CartesianAxesGrid);
            app.ChannelPowerColor.Value = [1 1 0.0706];
            app.ChannelPowerColor.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelPowerColor.Enable = 'off';
            app.ChannelPowerColor.Layout.Row = 6;
            app.ChannelPowerColor.Layout.Column = 2;
            app.ChannelPowerColor.BackgroundColor = [1 1 1];

            % Create ChannelPowerEdgeAlpha
            app.ChannelPowerEdgeAlpha = uispinner(app.CartesianAxesGrid);
            app.ChannelPowerEdgeAlpha.Step = 0.1;
            app.ChannelPowerEdgeAlpha.Limits = [0 1];
            app.ChannelPowerEdgeAlpha.ValueDisplayFormat = '%.1f';
            app.ChannelPowerEdgeAlpha.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelPowerEdgeAlpha.FontSize = 11;
            app.ChannelPowerEdgeAlpha.Enable = 'off';
            app.ChannelPowerEdgeAlpha.Layout.Row = 6;
            app.ChannelPowerEdgeAlpha.Layout.Column = 3;
            app.ChannelPowerEdgeAlpha.Value = 1;

            % Create ChannelPowerFaceAlpha
            app.ChannelPowerFaceAlpha = uispinner(app.CartesianAxesGrid);
            app.ChannelPowerFaceAlpha.Step = 0.1;
            app.ChannelPowerFaceAlpha.Limits = [0 1];
            app.ChannelPowerFaceAlpha.ValueDisplayFormat = '%.1f';
            app.ChannelPowerFaceAlpha.ValueChangedFcn = createCallbackFcn(app, @onNonCustomizableParameterValueChanged, true);
            app.ChannelPowerFaceAlpha.FontSize = 11;
            app.ChannelPowerFaceAlpha.Enable = 'off';
            app.ChannelPowerFaceAlpha.Layout.Row = 6;
            app.ChannelPowerFaceAlpha.Layout.Column = 4;
            app.ChannelPowerFaceAlpha.Value = 0.4;

            % Create BandGuardTypeLabel
            app.BandGuardTypeLabel = uilabel(app.CartesianAxesGrid);
            app.BandGuardTypeLabel.VerticalAlignment = 'bottom';
            app.BandGuardTypeLabel.FontSize = 11;
            app.BandGuardTypeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandGuardTypeLabel.Layout.Row = 7;
            app.BandGuardTypeLabel.Layout.Column = [1 4];
            app.BandGuardTypeLabel.Text = 'Escala frequência:';

            % Create BandGuardValueLabel
            app.BandGuardValueLabel = uilabel(app.CartesianAxesGrid);
            app.BandGuardValueLabel.VerticalAlignment = 'bottom';
            app.BandGuardValueLabel.FontSize = 11;
            app.BandGuardValueLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandGuardValueLabel.Layout.Row = 7;
            app.BandGuardValueLabel.Layout.Column = [3 4];
            app.BandGuardValueLabel.Text = 'Fator:';

            % Create BandGuardType
            app.BandGuardType = uidropdown(app.CartesianAxesGrid);
            app.BandGuardType.Items = {'Fixed', 'BWRelated'};
            app.BandGuardType.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.BandGuardType.Enable = 'off';
            app.BandGuardType.FontSize = 11;
            app.BandGuardType.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandGuardType.BackgroundColor = [1 1 1];
            app.BandGuardType.Layout.Row = 8;
            app.BandGuardType.Layout.Column = [1 2];
            app.BandGuardType.Value = 'BWRelated';

            % Create BandGuardFixedValue
            app.BandGuardFixedValue = uieditfield(app.CartesianAxesGrid, 'numeric');
            app.BandGuardFixedValue.Limits = [0 Inf];
            app.BandGuardFixedValue.ValueDisplayFormat = '%.1f';
            app.BandGuardFixedValue.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.BandGuardFixedValue.FontSize = 11;
            app.BandGuardFixedValue.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandGuardFixedValue.Enable = 'off';
            app.BandGuardFixedValue.Visible = 'off';
            app.BandGuardFixedValue.Layout.Row = 8;
            app.BandGuardFixedValue.Layout.Column = [3 4];
            app.BandGuardFixedValue.Value = 1000;

            % Create BandGuardBWRelatedValue
            app.BandGuardBWRelatedValue = uispinner(app.CartesianAxesGrid);
            app.BandGuardBWRelatedValue.Limits = [1 10];
            app.BandGuardBWRelatedValue.RoundFractionalValues = 'on';
            app.BandGuardBWRelatedValue.ValueDisplayFormat = '%.0f';
            app.BandGuardBWRelatedValue.ValueChangedFcn = createCallbackFcn(app, @onCustomizableParameterValueChanged, true);
            app.BandGuardBWRelatedValue.FontSize = 11;
            app.BandGuardBWRelatedValue.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandGuardBWRelatedValue.Enable = 'off';
            app.BandGuardBWRelatedValue.Layout.Row = 8;
            app.BandGuardBWRelatedValue.Layout.Column = [3 4];
            app.BandGuardBWRelatedValue.Value = 6;

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
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarZoomControlButtonClicked, true);
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarZoomControlButtonClicked, true);
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 3;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create axesTool_DataSourceDropDown
            app.axesTool_DataSourceDropDown = uidropdown(app.AxesToolbar);
            app.axesTool_DataSourceDropDown.Items = {'Dados brutos', 'Processados'};
            app.axesTool_DataSourceDropDown.ValueChangedFcn = createCallbackFcn(app, @onAxesToolbarDataSourceChanged, true);
            app.axesTool_DataSourceDropDown.FontSize = 11;
            app.axesTool_DataSourceDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_DataSourceDropDown.BackgroundColor = [1 1 1];
            app.axesTool_DataSourceDropDown.Layout.Row = 1;
            app.axesTool_DataSourceDropDown.Layout.Column = 5;
            app.axesTool_DataSourceDropDown.Value = 'Dados brutos';

            % Create axesTool_DistortionPlot
            app.axesTool_DistortionPlot = uiimage(app.AxesToolbar);
            app.axesTool_DistortionPlot.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarPlotTypeChanged, true);
            app.axesTool_DistortionPlot.Layout.Row = 1;
            app.axesTool_DistortionPlot.Layout.Column = 7;
            app.axesTool_DistortionPlot.ImageSource = 'DriveTestDistortion_32.png';

            % Create axesTool_DensityPlot
            app.axesTool_DensityPlot = uiimage(app.AxesToolbar);
            app.axesTool_DensityPlot.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarPlotTypeChanged, true);
            app.axesTool_DensityPlot.Enable = 'off';
            app.axesTool_DensityPlot.Layout.Row = 1;
            app.axesTool_DensityPlot.Layout.Column = 8;
            app.axesTool_DensityPlot.ImageSource = 'DriveTestDensity_32.png';

            % Create axesTool_PlotSize
            app.axesTool_PlotSize = uislider(app.AxesToolbar);
            app.axesTool_PlotSize.Limits = [1 19];
            app.axesTool_PlotSize.MajorTicks = [1 10 19];
            app.axesTool_PlotSize.MajorTickLabels = {''};
            app.axesTool_PlotSize.ValueChangedFcn = createCallbackFcn(app, @onAxesToolbarPlotSizeChanged, true);
            app.axesTool_PlotSize.ValueChangingFcn = createCallbackFcn(app, @onAxesToolbarPlotSizeChanging, true);
            app.axesTool_PlotSize.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_PlotSize.Layout.Row = 1;
            app.axesTool_PlotSize.Layout.Column = 10;
            app.axesTool_PlotSize.Value = 1;

            % Create axesTool_Target
            app.axesTool_Target = uiimage(app.AxesToolbar);
            app.axesTool_Target.ScaleMethod = 'none';
            app.axesTool_Target.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarTargetButtonClicked, true);
            app.axesTool_Target.Enable = 'off';
            app.axesTool_Target.Layout.Row = 1;
            app.axesTool_Target.Layout.Column = 11;
            app.axesTool_Target.ImageSource = 'target.svg';

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
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
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
