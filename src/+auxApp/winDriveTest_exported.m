classdef winDriveTest_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        DockModule                     matlab.ui.container.GridLayout
        dockModule_Close               matlab.ui.control.Image
        dockModule_Undock              matlab.ui.control.Image
        GridLayout2                    matlab.ui.container.GridLayout
        RightPanel                     matlab.ui.container.GridLayout
        WaterfallPanel                 matlab.ui.container.Panel
        WaterfallPanelGrid             matlab.ui.container.GridLayout
        WaterfallCLim2                 matlab.ui.control.Spinner
        WaterfallCLim1                 matlab.ui.control.Spinner
        WaterfallCLimRefresh           matlab.ui.control.Image
        WaterfallCLimLabel             matlab.ui.control.Label
        WaterfallMeshStyle             matlab.ui.control.DropDown
        WaterfallMeshStyleLabel        matlab.ui.control.Label
        WaterfallColormap              matlab.ui.control.DropDown
        WaterfallColormapLabel         matlab.ui.control.Label
        WaterfallDecimation            matlab.ui.control.DropDown
        WaterfallDecimationValue       matlab.ui.control.Label
        WaterfallDecimationLabel       matlab.ui.control.Label
        WaterfallFunction              matlab.ui.control.DropDown
        WaterfallFunctionLabel         matlab.ui.control.Label
        WaterfallPanelLabel            matlab.ui.control.Label
        WaterfallPanelIcon             matlab.ui.control.Image
        PersistencePanel               matlab.ui.container.Panel
        PersistencePanelGrid           matlab.ui.container.GridLayout
        PersistenceCLim2               matlab.ui.control.Spinner
        PersistenceCLim1               matlab.ui.control.Spinner
        PersistenceCLimRefresh         matlab.ui.control.Image
        PersistenceCLim_Label          matlab.ui.control.Label
        PersistenceTransparency        matlab.ui.control.Spinner
        PersistenceTransparencyLabel   matlab.ui.control.Label
        PersistenceColormap            matlab.ui.control.DropDown
        PersistenceColormapLabel       matlab.ui.control.Label
        PersistenceWindowSize          matlab.ui.control.DropDown
        PersistenceWindowSizeValue     matlab.ui.control.Label
        PersistenceWindowSizeLabel     matlab.ui.control.Label
        PersistenceInterpolation       matlab.ui.control.DropDown
        PersistenceInterpolationLabel  matlab.ui.control.Label
        PersistencePanelLabel          matlab.ui.control.Label
        PersistencePanelIcon           matlab.ui.control.Image
        GeneralPanel                   matlab.ui.container.Panel
        GeneralPanelGrid               matlab.ui.container.GridLayout
        LimitsYLim2                    matlab.ui.control.Spinner
        LimitsYLim1                    matlab.ui.control.Spinner
        LimitsYLimLabel                matlab.ui.control.Label
        LimitsXLim2                    matlab.ui.control.Spinner
        LimitsXLim1                    matlab.ui.control.Spinner
        LimitsXLimLabel                matlab.ui.control.Label
        LimitsRefresh                  matlab.ui.control.Image
        LimitsPanelLabel               matlab.ui.control.Label
        LayoutRatio                    matlab.ui.control.DropDown
        LayoutRatioLabel               matlab.ui.control.Label
        GeneralPanelLabel              matlab.ui.control.Label
        GeneralPanelIcon               matlab.ui.control.Image
        AxesToolbar                    matlab.ui.container.GridLayout
        axesTool_PlotSize              matlab.ui.control.Slider
        axesTool_DensityPlot           matlab.ui.control.Image
        axesTool_DistortionPlot        matlab.ui.control.Image
        axesTool_DataSourceDropDown    matlab.ui.control.DropDown
        axesTool_RegionZoom            matlab.ui.control.Image
        axesTool_RestoreView           matlab.ui.control.Image
        Document                       matlab.ui.container.Panel
        LeftPanel                      matlab.ui.container.GridLayout
        EmissionList                   matlab.ui.control.DropDown
        FlowPanel                      matlab.ui.container.Panel
        FlowPanelGrid                  matlab.ui.container.GridLayout
        FlowChannelEdit_2              matlab.ui.control.Image
        filter_DataBinningLabel_3      matlab.ui.control.Label
        PointsTree                     matlab.ui.container.CheckBoxTree
        FlowChannelEdit                matlab.ui.control.Image
        filter_DataBinningLabel_2      matlab.ui.control.Label
        filter_DataBinningLabel        matlab.ui.control.Label
        FilterTree                     matlab.ui.container.Tree
        filter_DataBinningPanel        matlab.ui.container.Panel
        filter_DataBinningGrid         matlab.ui.container.GridLayout
        filter_DataBinningFcn          matlab.ui.control.DropDown
        filter_DataBinningFcnLabel     matlab.ui.control.Label
        filter_DataBinningLength       matlab.ui.control.Spinner
        filter_DataBinningLengthLabel  matlab.ui.control.Label
        FlowMetadata                   matlab.ui.control.Label
        FlowAttributesPanelRightBtn    matlab.ui.control.Image
        FlowAttributesPanelLeftBtn     matlab.ui.control.Image
        FlowAttributesPanelVisibleIdx  matlab.ui.control.Label
        FlowPanelLabel                 matlab.ui.control.Label
        SpectrumFlowList               matlab.ui.control.DropDown
        Toolbar                        matlab.ui.container.GridLayout
        tool_LayoutRight               matlab.ui.control.Image
        tool_Separator3                matlab.ui.control.Image
        tool_FilterSummary             matlab.ui.control.Image
        tool_DataBinningExport         matlab.ui.control.Image
        tool_Play                      matlab.ui.control.Image
        tool_TimestampLabel            matlab.ui.control.Label
        tool_TimestampSlider           matlab.ui.control.Slider
        tool_LoopControl               matlab.ui.control.Image
        tool_Separator                 matlab.ui.control.Image
        tool_LayoutLeft                matlab.ui.control.Image
        ContextMenu2                   matlab.ui.container.ContextMenu
        filter_delButton               matlab.ui.container.Menu
        filter_delAllButton            matlab.ui.container.Menu
        ContextMenu1                   matlab.ui.container.ContextMenu
        points_delButton               matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'DRIVETEST'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
        popupContainer

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
        emissionSelectedIdxs = struct('flowIdx', {}, 'emissionIdx', {})
        emissionPoints = struct('raw', [], 'filtered', [], 'binned', [])
        emissionPointsTable
        emissionFilteredPointsTable
        emissionBinnedPointsTable

        filterTable = table({}, {}, struct('handle', {}, 'specification', {}),               'VariableNames', {'type', 'subtype', 'roi'})
        pointsTable = table({}, struct('Source', {}, 'idxData', {}, 'Data', {}), true(0, 1), 'VariableNames', {'type', 'value', 'visible'})

        kmlObj

        defaultConfigValues = struct(...
            'Colormap',          'turbo', ...
            'route_LineStyle',   ':', ...
            'route_Size',        1, ...
            'route_OutColor',    [0.502 0.502 0.502], ...
            'route_InColor',     [0.8706 0.5412 0.5412], ...
            'Car_LineStyle',     'square', ...
            'Car_Color',         [1,0,0], ...
            'Car_Size',          10, ...
            'points_LineStyle',  '^', ...
            'points_Color',      [0,0,0], ...
            'points_Size',       9, ...
            'persistancePlot',   'on', ...
            'chROIVisibility',   'on', ...
            'chROIEdgeAlpha',    0, ...
            'chROIFaceAlpha',    .4, ...
            'chPowerVisibility', 'on', ...
            'chPowerEdgeAlpha',  1, ...
            'chPowerFaceAlpha',  .4 ...
        )
        defaultValues
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

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
                                  'onEmissionAdded', ...
                                  'onEmissionParameterValueChanged', ...
                                  'onEmissionDeleted'}
                                % [flowIdx, emissionIdx] = getEmissionIndexes(app);
                            %     [idxThread, idxEmission] = specDataIndex(app, 'EmissionShowed');
                            % 
                            %     if isempty(idxThread) || isempty(app.specData(idxThread).UserData.Emissions)
                            %         closeFcn(app)
                            %         return
                            %     end
                            % 
                            %     preSelection = app.EmissionList.Value;
                            %     layout_EmissionListCreation(app, idxThread, idxEmission)
                            % 
                            %     if ismember(preSelection, app.EmissionList.Items)
                            %         app.EmissionList.Value = preSelection;
                            %     else
                            %         general_EmissionChanged(app, struct('Source', app.EmissionList))
                            %     end
            
                            case 'onTabNavigatorButtonPushed'
                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = 0;
                                end

                            case 'auxApp.winDriveTest.FilterTree'
                                filter_delFilter(app, struct('Source', app.filter_delButton))

                            case 'auxApp.winDriveTest.PointsTree'
                                points_delButtonMenuSelected(app)

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
                        app.SelectedFlowTag;
                        app.EmissionInfo;
                        app.ToggleEmissionPlotCustomization;
                        app.tool_LayoutLeft;
                        app.tool_Play;
                        app.tool_LoopControl;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.SelectedFlowTag, appName);
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.EmissionInfo, appName);
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id,       'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.ToggleEmissionPlotCustomization.UserData.id, 'generation', 1, 'style', struct('textAlign', 'justify')), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutLeft.UserData.id,   'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à esquerda')), ...
                            struct('appName', appName, 'dataTag', app.tool_Play.UserData.id,         'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla execução do playback da monitoração')), ...
                            struct('appName', appName, 'dataTag', app.tool_LoopControl.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla loop da execução do playback')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,  'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                case 2
                    elToModify = {app.FilterTree};
                    ui.CustomizationBase.getElementsDataTag(elToModify);
                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.FilterTree.UserData.id, 'listener', struct('componentName', 'auxApp.winDriveTest.FilterTree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end
                
                case 3
                    elToModify = {app.PointsTree};
                    ui.CustomizationBase.getElementsDataTag(elToModify);
                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.PointsTree.UserData.id, 'listener', struct('componentName', 'auxApp.winDriveTest.PointsTree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end

                case 4
                    app.config_chROIColor.Value     = app.defaultValues.channelROI.Color;
                    app.config_chROIEdgeAlpha.Value = app.defaultValues.channelROI.EdgeAlpha;
                    app.config_chROIFaceAlpha.Value = app.defaultValues.channelROI.FaceAlpha;
                    app.config_chPowerColor.Value   = app.UIAxes3.Colormap(end,:);
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
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

            % Cria eixos...
            app.bandObj = model.Band('appAnalise:DRIVETEST', app.mainApp);
            initializeAxes(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            % Controle do modo de edição:
            app.spectralThreadEdit.UserData.status = false;
            app.ChannelToggleEditMode.UserData.status = false;

            % Lista as emissões:
            buildSpecFlowTree(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            % general_EmissionChanged(app, struct('updateType', 'AppStartup'))
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.Document, 24, 16, "Padding", "none", "TileSpacing", "none");

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
        function buildSpecFlowTree(app, flowIdx, emissionIdx)
            arguments
                app
                flowIdx = []
                emissionIdx = []
            end

            if ~isempty(app.SpecFlowTree.Children)
                removeStyle(app.SpecFlowTree)
                delete(app.SpecFlowTree.Children)
            end

            if ~isempty(app.mainApp.specData)
                if isempty(flowIdx)
                    flowIdx = 1;
                end
    
                app.SelectedFlowTag.Text = sprintf('%s\n%.3f - %.3f MHz', app.mainApp.specData(flowIdx).Receiver, ...
                                                                         app.mainApp.specData(flowIdx).MetaData.FreqStart / 1e6, ...
                                                                         app.mainApp.specData(flowIdx).MetaData.FreqStop  / 1e6);
    
                % Cria árvore:
                [receiverList, ~, receiverIdxs] = unique({app.mainApp.specData.Receiver});
    
                for ii = 1:numel(receiverList)
                    idxs = find(receiverIdxs == ii)';
                    receiverNode = uitreenode(app.SpecFlowTree, 'Text',  util.layoutTreeNodeText(receiverList{ii}, 'play_TreeBuilding'), ...
                                                                      'NodeData', idxs, 'Icon', util.layoutTreeNodeIcon(receiverList{ii}), 'Tag', 'RECEIVER');
                                    
                    for jj = idxs
                        uitreenode(receiverNode, 'Text', sprintf('%.3f - %.3f MHz', app.mainApp.specData(jj).MetaData.FreqStart / 1e6, ...
                                                                                    app.mainApp.specData(jj).MetaData.FreqStop  / 1e6), ...
                                                 'NodeData', jj, 'Tag', 'BAND');
                    end
                end
                expand(app.SpecFlowTree, 'all')

                % Ajusta seleção programaticamente e aplica estilo:
                applySpecFlowTreeStyle(app, flowIdx)
    
                % Cria lista de emissões:
                createSpecFlowEmissionDropDownList(app, flowIdx, emissionIdx)

            else
                app.SelectedFlowTag.Text = '';
            end
        end

        %-----------------------------------------------------------------%
        function applySpecFlowTreeStyle(app, flowIdx)
            nodeTreeList = findobj(app.SpecFlowTree, 'Tag', 'BAND');
            [~, selectionIdx] = ismember(flowIdx, [nodeTreeList.NodeData]);

            if selectionIdx
                app.SpecFlowTree.SelectedNodes = nodeTreeList(selectionIdx);
                addStyle(app.SpecFlowTree, uistyle('FontColor', [0,0,0]), 'node', [nodeTreeList(selectionIdx); nodeTreeList(selectionIdx).Parent])

                expand(nodeTreeList(selectionIdx))
                scroll(app.SpecFlowTree, nodeTreeList(selectionIdx))
            end
        end

        %-----------------------------------------------------------------%
        function createSpecFlowEmissionDropDownList(app, flowIdx, emissionIdx)
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
                    if ~isempty(emissions.auxAppData(ii).DriveTest)
                        additionalNote = ' (DT)';
                    end
                end

                emissionList{end+1} = sprintf('%d: %.3f MHz ⌂ %.1f kHz%s', ii, freqCenter, bandWidthkHz, additionalNote);
            end

            app.EmissionList.Items = emissionList;

            % Ajusta seleção programaticamente:
            if ~isempty(emissionIdx)
                app.EmissionList.Value = app.EmissionList.Items{emissionIdx+1};
            elseif numel(app.EmissionList.Items) > 1
                app.EmissionList.Value = app.EmissionList.Items{2};
            end
        end

        %-----------------------------------------------------------------%
        function updateEmissionView(app)
            updateUIControlsState(app)
            % ...
        end

        %-----------------------------------------------------------------%
        function updateUIControlsState(app)
            hasSpectralFlow = ~isempty(app.mainApp.specData) && any(ismember([specData.MetaData.DataType], class.Constants.specDataTypes));

            set([
                app.tool_Play;
                app.tool_LoopControl;
                app.tool_TimestampSlider;
                app.tool_DataBinningExport;
                app.tool_FilterSummary
            ], 'Enable', hasSpectralFlow)
        end

        %-----------------------------------------------------------------%
        function layout_editSpectralThread(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    set(app.spectralThreadEdit, 'ImageSource', 'Edit_32Filled.png', 'Tooltip', 'Desabilita edição do fluxo espectral', 'UserData', true)
                    app.SubGrid1.RowHeight{3} = '1x';
                    app.spectralThreadEditGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.spectralThreadEditConfirm.Enable = 1;
                    app.spectralThreadEditCancel.Enable  = 1;

                case 'off'
                    set(app.spectralThreadEdit, 'ImageSource', 'Edit_32.png',       'Tooltip', 'Habilita edição do fluxo espectral',   'UserData', false)
                    app.SubGrid1.RowHeight{3} = 0;
                    app.spectralThreadEditGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.spectralThreadEditConfirm.Enable = 0;
                    app.spectralThreadEditCancel.Enable  = 0;

                    idxThread         = specDataIndex(app, 'ThreadSelectionChanged');
                    nodeTreeList      = findobj(app.SpecFlowTree, 'Tag', 'BAND');
                    [~, idxSelection] = ismember(idxThread, [nodeTreeList.NodeData]);
        
                    if idxSelection
                        app.SpecFlowTree.SelectedNodes = nodeTreeList(idxSelection);
                    end
            end
        end

        %-----------------------------------------------------------------%
        function layout_editChannelAssigned(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    set(app.ChannelToggleEditMode, 'ImageSource', 'Edit_32Filled.png', 'Tooltip', 'Desabilita edição do canal', 'UserData', true)
                    app.ChannelPanelEditionGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.ChannelEditConfirm.Enable = 1;
                    app.ChannelEditCancel.Enable  = 1;
                    app.ChannelFrequency.Editable = 1;
                    app.ChannelBandWidthkHz.Editable = 1;

                case 'off'
                    set(app.ChannelToggleEditMode, 'ImageSource', 'Edit_32.png',       'Tooltip', 'Habilita edição do canal',   'UserData', false)
                    app.ChannelPanelEditionGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.ChannelEditConfirm.Enable = 0;
                    app.ChannelEditCancel.Enable  = 0;
                    app.ChannelFrequency.Editable = 0;
                    app.ChannelBandWidthkHz.Editable = 0;

                    [idxThread, idxEmission]      = specDataIndex(app, 'ChannelDefault');
                    app.ChannelFrequency.Value    = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified.Frequency;
                    app.ChannelBandWidthkHz.Value    = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified.ChannelBW;
            end
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
        function checkChannelAssigned(app, idxThread, idxEmission)            
            if isempty(idxEmission)
                chAssigned = util.emissionChannel(app.specData, idxThread, idxEmission, app.mainApp.channelObj);
                app.ChannelRefresh.Visible = 0;

            else
                chAssigned = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified;
                
                if isequal(app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, ...
                           app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                    app.ChannelRefresh.Visible = 0;
                else
                    app.ChannelRefresh.Visible = 1;
                end
            end

            app.ChannelGrid.UserData   = chAssigned;
            app.ChannelFrequency.Value = chAssigned.Frequency;
            app.ChannelBandWidthkHz.Value = chAssigned.ChannelBW;

            checkFixedScreenSpanLimits(app)
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
                    chBW        = app.ChannelBandWidthkHz.Value; % kHz
                    chBWLimits = chBW * app.config_BandGuardBWRelatedValue.Limits;
        
                    if app.config_BandGuardFixedValue.Value < chBWLimits(1)
                        app.config_BandGuardFixedValue.Value = chBWLimits(1);
                    elseif app.config_BandGuardFixedValue.Value > chBWLimits(2)
                        app.config_BandGuardFixedValue.Value = chBWLimits(2);
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

            chFrequency = app.ChannelFrequency.Value; % MHz
            chBW        = app.ChannelBandWidthkHz.Value / 1000; % kHz >> MHz
            maxFactor   = app.config_BandGuardBWRelatedValue.Limits(2);

            switch app.config_BandGuardType.Value
                case 'Fixed'
                    screenSpan = app.config_BandGuardFixedValue.Value / 1000;     % kHz >> MHz
                case 'BWRelated'
                    screenSpan = app.config_BandGuardBWRelatedValue.Value * chBW; % MHz
            end

            screenSpanLimits    = [chFrequency - screenSpan/2,     chFrequency + screenSpan/2];
            screenSpanMaxLimits = [chFrequency - maxFactor*chBW/2, chFrequency + maxFactor*chBW/2];

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
        function updateCustomProperty(app, idxThread, idxEmission, updateType)
            arguments
                app
                idxThread
                idxEmission
                updateType char {mustBeMember(updateType, {'DriveTest',               ...
                                                           'DriveTest:JustTables',    ...
                                                           'DriveTest:JustPoints',    ...
                                                           'ChannelParameterChanged', ...
                                                           'ChannelDefault'})} = 'DriveTest'
            end

            if isempty(idxEmission)
                return
            end

            switch updateType
                case 'DriveTest'
                    if app.ToggleEmissionPlotCustomization.Value
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest = createPlotParameters(app);
                    else
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest = [];
                    end

                case 'DriveTest:JustTables'
                    if ~isempty(app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest)
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specRawTable      = app.emissionPointsTable;
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specFilteredTable = app.emissionFilteredPointsTable;
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specBinTable      = app.emissionBinnedPointsTable;
                    end

                case 'DriveTest:JustPoints'
                    if ~isempty(app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest)
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.pointsTable = app.pointsTable;
                    end
                
                case 'ChannelParameterChanged'
                    chAssigned = struct('Frequency', app.ChannelFrequency.Value, ...
                                        'ChannelBW', app.ChannelBandWidthkHz.Value);
                    app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified = chAssigned;
                    ipcMainMatlabCallsHandler(app.mainApp, app, updateType, idxThread, idxEmission)
                
                case 'ChannelDefault'
                    app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested;
                    ipcMainMatlabCallsHandler(app.mainApp, app, updateType, idxThread, idxEmission)
            end
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
                         app.tool_FilterSummary.UserData] = RF.DataBinning.execute(app.emissionPoints.raw,             ...
                                                                                   app.filter_DataBinningLength.Value, ...
                                                                                   app.filter_DataBinningFcn.Value,    ...
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
                                'binning_Value',         app.filter_DataBinningLength.Value, ...
                                'binning_Fcn',           app.filter_DataBinningFcn.Value,    ...
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
    
                    filter_TreeBuilding(app)
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
                    if isempty(idxEmission) || isempty(app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest)
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
                    points_TreeBuilding(app)
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
            if ~isempty(emissionIdx) && ~isempty(app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest)
                app.ToggleEmissionPlotCustomization.Value = 1;

                % Essa "gambi" evita que os ROIs dos filtros sejam redesenhados...
                if ismember(operationType, {'AddEditOrDeleteFilter'})
                    return
                end

                % Source
                switch app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.Source
                    case {'Raw', 'Filtered'}
                        app.axesTool_DataSourceDropDown.Value = 'Dados brutos';
                        app.axesTool_DensityPlot.Enable = 0;

                    case 'Data-Binning'
                        app.axesTool_DataSourceDropDown.Value = 'Dados processados';
                        app.axesTool_DensityPlot.Enable = 1;
                end

                % specRawTable, specFilteredTable e specBinTable
                app.emissionPoints = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.emissionPoints;

                % filterTable
                app.filterTable                    = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.filterTable;
                filter_TreeBuilding(app)
                plot_FiltersController(app)

                % pointsTable
                app.pointsTable                    = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.pointsTable;
                points_TreeBuilding(app)
                plot_PointsController(app)

                % potType e plotSize
                app.UIAxes1.UserData.PlotMode      = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.plotType;
                app.axesTool_PlotSize.Value        = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.plotSize;

                % binningValue e binningFcn
                app.filter_DataBinningLength.Value = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.binning_Value;
                app.filter_DataBinningFcn.Value    = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.binning_Fcn;

                % route...                
                app.config_route_LineStyle.Value   = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.route_LineStyle;
                app.config_route_OutColor.Value    = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.route_OutColor;
                app.config_route_InColor.Value     = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.route_InColor;
                app.config_route_Size.Value        = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.route_MarkerSize;

                % Colormap
                if ~strcmp(app.UIAxes1.UserData.Colormap, app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.Colormap)
                    app.config_Colormap.Value      = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.Colormap;
                    plot.axes.Colormap(app.UIAxes1, app.config_Colormap.Value)
                end

                % points...                
                app.config_points_LineStyle.Value  = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.points_Marker;
                app.config_points_Color.Value      = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.points_Color;
                app.config_points_Size.Value       = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.points_Size;

                % Basemap
                if ~strcmp(app.UIAxes1.Basemap, app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.Basemap)
                    app.config_Basemap.Value       = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.Basemap;
                    app.UIAxes1.Basemap            = app.specData(flowIdx).UserData.Emissions.auxAppData(emissionIdx).DriveTest.Basemap;
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
        % FILTROS
        %-----------------------------------------------------------------%
        function filter_TreeBuilding(app)
            if ~isempty(app.FilterTree.Children)
                delete(app.FilterTree.Children)
            end

            if ~isempty(app.filterTable)
                for ii = 1:height(app.filterTable)
                    nodeText = sprintf('%s:%s', app.filterTable.type{ii}, app.filterTable.subtype{ii});
                    uitreenode(app.FilterTree, 'Text', nodeText, 'NodeData', ii, 'ContextMenu', app.ContextMenu2);
                end

                set(app.FilterTree, 'SelectedNodes', app.FilterTree.Children(end), 'Enable', 1)
                FilterTreeSelectionChanged(app)

                set(app.ContextMenu2.Children, Enable=1)
            else
                app.FilterTree.Enable = 1;
                set(app.ContextMenu2.Children, Enable=0)
            end
        end

        %-----------------------------------------------------------------%
        function filter_UpdatePlot(app)
            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)

            prePlot_Startup(app, idxThread, idxEmission, 'AddEditOrDeleteFilter')

            geolimits(app.UIAxes1, 'auto')
            app.restoreView(1).xLim = app.UIAxes1.LatitudeLimits;
            app.restoreView(1).yLim = app.UIAxes1.LongitudeLimits;
        end

        %-----------------------------------------------------------------%
        % PONTOS
        %-----------------------------------------------------------------%
        function points_TreeBuilding(app)
            if ~isempty(app.PointsTree.Children)
                delete(app.PointsTree.Children)
            end

            checkedTreeNodes = [];
            for ii = 1:height(app.pointsTable)
                nodeText = sprintf('%s: %s', app.pointsTable.type{ii}, strjoin("#" + string(app.pointsTable.value(ii).idxData), ', '));
                treeNode = uitreenode(app.PointsTree, 'Text',        nodeText, ...
                                                       'NodeData',    ii,       ...
                                                       'ContextMenu', app.ContextMenu1);
                if app.pointsTable.visible(ii)
                    checkedTreeNodes = [checkedTreeNodes, treeNode];
                end
            end
            app.PointsTree.CheckedNodes = checkedTreeNodes;

            if app.ToggleEmissionPlotCustomization.Value
                [idxThread, idxEmission] = specDataIndex(app);
                updateCustomProperty(app, idxThread, idxEmission, 'DriveTest:JustPoints')
            end
        end

        %-----------------------------------------------------------------%
        function points_AddNewPoint2Table(app, newRow)
            status = true;
            for ii = 1:height(app.pointsTable)
                if isequal(newRow(1), app.pointsTable{ii,1}) && ...
                   isequal(newRow{2}, app.pointsTable{ii,2})
                    status = false;
                    break
                end
            end

            if status
                app.pointsTable(end+1,:) = newRow;
            else
                error('Registro já incluído!')
            end
        end

        %-----------------------------------------------------------------%
        function [idxPeak, Coordinates] = points_FindPeaks(app, Source, NPeaks, MinDistance)
            idxPeak = [];
            Coordinates = [];

            switch Source
                case 'Dados brutos'
                    sourceData = app.emissionPointsTable.ChannelPower;
                case 'Dados processados (Data Binning)'
                    sourceData = app.emissionBinnedPointsTable.ChannelPower;
            end

            [~, idxListOfPeaks] = findpeaks(sourceData, 'SortStr', 'descend');

            if ~isempty(idxListOfPeaks)
                idxPeak = idxListOfPeaks(1);
                for ii = 2:numel(idxListOfPeaks)
                    if numel(idxPeak) >= NPeaks
                        break
                    end

                    switch Source
                        case 'Dados brutos'
                            refCoordinates = app.emissionPointsTable{idxPeak,            {'Latitude', 'Longitude'}};
                            Coordinates    = app.emissionPointsTable{idxListOfPeaks(ii), {'Latitude', 'Longitude'}};    
                        
                        case 'Dados processados (Data Binning)'
                            refCoordinates = app.emissionBinnedPointsTable{idxPeak,                 {'Latitude', 'Longitude'}};
                            Coordinates    = app.emissionBinnedPointsTable{idxListOfPeaks(ii),      {'Latitude', 'Longitude'}};
                    end
    
                    tempDistance = deg2km(distance(refCoordinates, Coordinates(end,:))); % em km
                    if all(tempDistance >= MinDistance)
                        idxPeak(end+1) = idxListOfPeaks(ii);
                    end
                end

                switch Source
                    case 'Dados brutos'
                        Coordinates = app.emissionPointsTable{idxPeak, {'Latitude', 'Longitude'}};
                    case 'Dados processados (Data Binning)'
                        Coordinates = app.emissionBinnedPointsTable{idxPeak,      {'Latitude', 'Longitude'}};
                end
            end
        end

        %-----------------------------------------------------------------%
        function [idxThread, idxEmission] = specDataIndex(app, operationType)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'EmissionShowed',              ...
                                                                 'RefreshPlotParameters',       ...
                                                                 'ChannelParameterChanged',     ...
                                                                 'ChannelDefault',              ...
                                                                 'PlotDataSourceChanged',       ...
                                                                 'DataBinningParameterChanged', ...
                                                                 'ThreadSelectionChanged',      ...
                                                                 'EmissionSelectionChanged'})} = 'EmissionShowed'
            end

            % Inicialmente, busca-se o fluxo espectral (referenciado 
            % unicamente pela lista UUID dos arquivos brutos).
            threadUUID  = app.emissionSelectedIdxs.Thread.UUID;
            listOfAllThreadsUUID = arrayfun(@(x) x.RelatedFiles.uuid, app.specData, 'UniformOutput', false);
            
            idxThread   = find(cellfun(@(x) isequal(x, threadUUID), listOfAllThreadsUUID), 1);
            idxEmission = [];

            % Caso seja identificado o fluxo espectral, busca a emissão 
            % sob análise na lista de emissões.
            if ~isempty(idxThread)
                switch operationType
                    case 'EmissionSelectionChanged'
                        newEmissionTag = app.EmissionList.Value;
                        emissions = app.specData(idxThread).UserData.Emissions;

                        for ii = 1:height(emissions)
                            if strcmp(newEmissionTag, sprintf('%.3f MHz ⌂ %.1f kHz', emissions.Frequency(ii), emissions.BandWidthkHz(ii)))
                                idxEmission = ii;
                                break
                            end
                        end

                    otherwise
                        emissionFrequency = app.emissionSelectedIdxs.Emission.Frequency;
                        emissionBandWidth = app.emissionSelectedIdxs.Emission.BandWidthkHz;
        
                        idxEmission = find(abs(app.specData(idxThread).UserData.Emissions.Frequency - emissionFrequency) <= class.Constants.floatDiffTol & ...
                                           abs(app.specData(idxThread).UserData.Emissions.BandWidthkHz - emissionBandWidth) <= class.Constants.floatDiffTol, 1);
                end
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

        % Callback function: not associated with a component
        function SubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Image clicked function: tool_LayoutLeft
        function Toolbar_LeftPanelVisibilityImageClicked(app, event)

            switch event.Source
                case app.tool_LayoutLeft
                    if app.GridLayout.ColumnWidth{2}
                        app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left-off.svg';
                        app.GridLayout.ColumnWidth(2:3) = {0,0};
                    else
                        app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';
                        app.GridLayout.ColumnWidth(2:3) = {320,10};
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

        % Value changed function: axesTool_DataSourceDropDown, 
        % ...and 2 other components
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

                case {app.filter_DataBinningLength, app.filter_DataBinningFcn}
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

        % Callback function: not associated with a component
        function general_ThreadChanged(app, event)
            
            switch event.Source
                case app.spectralThreadEdit
                    app.spectralThreadEdit.UserData.status = ~app.spectralThreadEdit.UserData.status;
                    
                    if app.spectralThreadEdit.UserData.status
                        layout_editSpectralThread(app, 'on')
                    else
                        general_ThreadChanged(app, struct('Source', app.spectralThreadEditCancel))
                    end

                case app.spectralThreadEditConfirm
                    idxSelectedThread = app.SpecFlowTree.SelectedNodes.NodeData;
        
                    if (~isempty(app.emissionSelectedIdxs) && isequal(idxSelectedThread, app.emissionSelectedIdxs.Thread.Index)) || ~isscalar(idxSelectedThread)
                        layout_editSpectralThread(app, 'off')
                        return
                    end

                    % Se o fluxo espectral relacionado está relacionado a
                    % outra coleta, em outro local, os filtros de nível e
                    % geográficos são apagados...
                    if ~isequal(app.specData(idxSelectedThread).GPS, app.specData(app.emissionSelectedIdxs.Thread.Index).GPS)
                        app.filterTable(:,:) = [];
                        filter_TreeBuilding(app)
                        delete(findobj([app.UIAxes1.Children; app.UIAxes4.Children], 'Tag', 'FilterROI'))
                    end

                    buildSpecFlowTree(app, idxSelectedThread, [])
                    general_EmissionChanged(app, struct('updateType', 'ThreadSelectionChanged'))

                    layout_editSpectralThread(app, 'off')

                case app.spectralThreadEditCancel
                    layout_editSpectralThread(app, 'off')
            end

        end

        % Value changed function: EmissionList
        function general_EmissionChanged(app, event)
            
            idxThread   = app.SpecFlowTree.SelectedNodes.NodeData;
            idxEmission = find(strcmp(app.EmissionList.Items, app.EmissionList.Value), 1) - 1;
            if ~idxEmission
                idxEmission = [];
            end

            if ~isempty(app.emissionSelectedIdxs) && isequal(idxThread, app.emissionSelectedIdxs.Thread.Index) && isequal(idxEmission, app.emissionSelectedIdxs.Emission.Index)
                return
            end

            % Inicialmente, a informação acerca do fluxo espectral e da emissão 
            % sob análise são salvas na propriedade "selectedEmission" do app.
            [htmlContent, app.emissionSelectedIdxs] = util.HtmlTextGenerator.Emission_v2(app.specData, idxThread, idxEmission);
            ui.TextView.update(app.EmissionInfo, htmlContent);

            % Atualiza canal, bloqueando edição de informação do canal.
            checkChannelAssigned(app, idxThread, idxEmission)
            if app.ChannelToggleEditMode.UserData.status
                general_chEditImageClicked(app)
            end

            if ~isempty(idxEmission) && ~isequal(app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, ...
                                                 app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                app.ChannelRefresh.Visible = 1;
            else
                app.ChannelRefresh.Visible = 0;
            end

            % Verifica se os limites do plot estão adequados ao tipo de emissão (a
            % emissão virtual, que corresponde à toda faixa espectral tem particularidades).
            if ~isempty(idxEmission)
                if ~app.config_BandGuardType.Enable
                    % Essa situação só ocorre quando estava selecionado uma
                    % emissão virtual e agora foi selecionada uma emissão real.
                    % Por isso, os valores estavam configurados em "BWRelated" e 1.
                    app.ToggleEmissionPlotCustomization.Enable = 1;
                    app.ChannelToggleEditMode.Enable = 1;

                    app.config_BandGuardType.Enable = 1;
                    set(app.config_BandGuardBWRelatedValue, 'Enable', 1, 'Value', 6)
                    config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))
                end
            else
                if app.config_BandGuardType.Enable
                    % Essa situação só ocorre quando estava selecionado uma
                    % emissão real e agora foi selecionada uma emissão virtual.
                    set(app.ToggleEmissionPlotCustomization, 'Enable', 0, 'Value', 0)                    
                    app.ChannelToggleEditMode.Enable = 0;

                    app.config_BandGuardType.Enable = 0;
                    app.config_BandGuardBWRelatedValue.Enable = 0;

                    if app.config_BandGuardType.Value ~= "BWRelated"
                        app.config_BandGuardType.Value = 'BWRelated';
                        config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardType))
                    end
        
                    if app.config_BandGuardBWRelatedValue.Value ~= 1
                        app.config_BandGuardBWRelatedValue.Value = 1;
                        config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))
                    end
                end
            end

            if isfield(event, 'updateType')
                prePlot_Startup(app, idxThread, idxEmission, event.updateType)
            else
                prePlot_Startup(app, idxThread, idxEmission, 'EmissionSelectionChanged')
            end

        end

        % Callback function: not associated with a component
        function general_ChannelChanged(app, event)
            
            switch event.Source
                case {app.ChannelRefresh, app.ChannelEditConfirm}
                    switch event.Source
                        case app.ChannelRefresh
                            operationType = 'ChannelDefault';
                            [idxThread, idxEmission] = specDataIndex(app, operationType);
                            updateCustomProperty(app, idxThread, idxEmission, operationType)        
                            checkChannelAssigned(app, idxThread, idxEmission)
                        otherwise
                            operationType = 'ChannelParameterChanged';
                            [idxThread, idxEmission] = specDataIndex(app, operationType);
                            updateCustomProperty(app, idxThread, idxEmission, operationType)
                            app.ChannelRefresh.Visible = 1;
                    end

                    layout_editChannelAssigned(app, 'off')

                    if app.plotUpdateEvent
                        app.plotUpdateEvent = 0;
                        pause(.100)
                    end
        
                    prePlot_Startup(app, idxThread, idxEmission, operationType)

                case app.ChannelToggleEditMode
                    app.ChannelToggleEditMode.UserData.status = ~app.ChannelToggleEditMode.UserData.status;
        
                    if app.ChannelToggleEditMode.UserData.status
                        layout_editChannelAssigned(app, 'on')
                        focus(app.ChannelFrequency)        
                    else
                        layout_editChannelAssigned(app, 'off')
                    end

                case app.ChannelEditCancel
                    layout_editChannelAssigned(app, 'off')
            end

        end

        % Callback function: not associated with a component
        function general_ReportFlagCheckBoxClicked(app, event)

            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)
            createSpecFlowEmissionDropDownList(app, idxThread, idxEmission)

        end

        % Callback function: not associated with a component
        function config_geoAxesColorParameterChanged(app, event)
            
            selectedColor = event.Source.Value;

            switch event.Source
                case app.config_route_OutColor
                    set(findobj(app.UIAxes1.Children, 'Tag', 'OutRoute'), 'Color', selectedColor, 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.config_route_InColor
                    set(findobj(app.UIAxes1.Children, 'Tag', 'InRoute'),  'Color', selectedColor, 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.config_Car_Color
                    set(app.hCar, 'MarkerFaceColor', selectedColor)

                case app.config_points_Color
                    hPoints = findobj(app.UIAxes1.Children, 'Tag', 'Points');
                    for ii = 1:numel(hPoints)
                        if strcmp(hPoints(ii).MarkerFaceColor, 'none')
                            set(hPoints(ii), 'Color', selectedColor, 'MarkerEdgeColor', selectedColor)
                        else
                            set(hPoints(ii), 'Color', selectedColor, 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)
                        end
                    end
            end

            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)
            checkIfCustomConfigParameter(app)
            
        end

        % Callback function: not associated with a component
        function config_geoAxesOthersParametersChanged(app, event)
            
            switch event.Source
                case app.config_Basemap
                    app.UIAxes1.Basemap = app.config_Basemap.Value;
                    switch app.config_Basemap.Value
                        case {'darkwater', 'none'}
                            app.UIAxes1.Grid = 'on';
                        otherwise
                            app.UIAxes1.Grid = 'off';
                    end
                    return

                case app.config_Colormap
                    if strcmp(app.UIAxes1.UserData.Colormap, event.Value)
                        return
                    end

                    plot.axes.Colormap(app.UIAxes1, event.Value)

                case app.config_route_LineStyle
                    switch event.Value
                        case 'none'; markerSize = 1;
                        otherwise;   markerSize = 8*app.config_route_Size.Value;
                    end
                    set(findobj(app.UIAxes1.Children, 'Tag', 'OutRoute'),                          'MarkerSize', markerSize)
                    set(findobj(app.UIAxes1.Children, 'Tag', 'InRoute'), 'LineStyle', event.Value, 'MarkerSize', markerSize)

                case app.config_route_Size
                    if ~strcmp(app.config_route_LineStyle.Value, 'none')
                        set(findobj(app.UIAxes1.Children, 'Tag', 'OutRoute'), 'MarkerSize', 8*event.Value)
                        set(findobj(app.UIAxes1.Children, 'Tag', 'InRoute'),  'MarkerSize', 8*event.Value)
                    end

                case app.config_Car_LineStyle
                    set(app.hCar, 'Marker', event.Value)
                
                case app.config_Car_Size
                    set(app.hCar, 'SizeData', 10*event.Value)

                case app.config_points_LineStyle
                    set(findobj(app.UIAxes1.Children, 'Tag', 'Points'), 'Marker', event.Value)
                
                case app.config_points_Size
                    set(findobj(app.UIAxes1.Children, 'Tag', 'Points'), 'MarkerSize', event.Value)
            end

            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)
            checkIfCustomConfigParameter(app)

        end

        % Callback function: not associated with a component
        function config_xyAxesParameterChanged(app, event)

            switch event.Source
                case app.config_PersistanceVisibility
                    hPersistance = findobj(app.UIAxes2.Children, 'Tag', 'Persistance');
                    hPersistance.Visible = app.config_PersistanceVisibility.Value;

                case app.config_chROIVisibility
                    hChannelROI = findobj([app.UIAxes2.Children; app.UIAxes3.Children], 'Tag', 'ChannelROI');
                    set(hChannelROI, 'Visible', app.config_chROIVisibility.Value)

                case {app.config_chROIColor, app.config_chROIEdgeAlpha, app.config_chROIFaceAlpha}                    
                    hChannelROI = findobj([app.UIAxes2.Children; app.UIAxes3.Children], 'Tag', 'ChannelROI');
                    set(hChannelROI, 'Color',     app.config_chROIColor.Value,     ...
                                     'EdgeAlpha', app.config_chROIEdgeAlpha.Value, ...
                                     'FaceAlpha', app.config_chROIFaceAlpha.Value)

                    app.mainApp.General.Plot.ChannelROI.Color     = app.config_chROIColor.Value;
                    app.mainApp.General.Plot.ChannelROI.EdgeAlpha = app.config_chROIEdgeAlpha.Value;
                    app.mainApp.General.Plot.ChannelROI.FaceAlpha = app.config_chROIFaceAlpha.Value;

                case app.config_chPowerVisibility
                    set(findobj(app.UIAxes4), 'Visible', app.config_chPowerVisibility.Value)

                case {app.config_chPowerColor, app.config_chPowerEdgeAlpha, app.config_chPowerFaceAlpha}
                    hChannelROI = findobj(app.UIAxes4.Children, 'Tag', 'ChannelPower');
                    set(hChannelROI, 'EdgeColor', app.config_chPowerColor.Value,     ...
                                     'FaceColor', app.config_chPowerColor.Value,     ...
                                     'EdgeAlpha', app.config_chPowerEdgeAlpha.Value, ...
                                     'FaceAlpha', app.config_chPowerFaceAlpha.Value)
            end

            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)
            checkIfCustomConfigParameter(app)
            
        end

        % Callback function: not associated with a component
        function config_BandGuardValueChanged(app, event)

            chBW = app.ChannelBandWidthkHz.Value;

            switch event.Source
                case app.config_BandGuardType
                    switch app.config_BandGuardType.Value
                        case 'Fixed'
                            app.config_BandGuardValueLabel.Text = 'Span (kHz):';                            
                            set(app.config_BandGuardFixedValue, 'Visible', 1, 'Value', app.config_BandGuardBWRelatedValue.Value * chBW)
                            app.config_BandGuardBWRelatedValue.Visible = 0;                            

                        case 'BWRelated'
                            app.config_BandGuardValueLabel.Text    = 'Multiplicador';
                            app.config_BandGuardFixedValue.Visible = 0;
                            set(app.config_BandGuardBWRelatedValue, 'Visible', 1, 'Value', app.config_BandGuardFixedValue.Value / chBW)
                    end
                    config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))

                case {app.config_BandGuardFixedValue, app.config_BandGuardBWRelatedValue}
                    checkFixedScreenSpanLimits(app)

                    xLim = getFrequencyScreenSpanInMHz(app, 'ScreenLimits');
                    app.UIAxes2.XLim = xLim;
                    app.restoreView(2).xLim = xLim;
                    app.restoreView(3).xLim = xLim;
            end

            checkIfCustomConfigParameter(app)

        end

        % Callback function: not associated with a component
        function config_RefreshImageClicked(app, event)
            
            % Trava função do Waterfall em "image" para que seja possível
            % sincronizar os eixos app.UIAxes3.YAxes e app.UIAxes4.XAxis.
            app.mainApp.General = app.mainApp.General;
            app.mainApp.General.Plot.Waterfall.Fcn         = 'image';

            % % Eixo geográfico - app.UIAxes1
            app.config_Colormap.Value              = app.defaultConfigValues.Colormap;            
            app.config_route_LineStyle.Value       = app.defaultConfigValues.route_LineStyle;
            app.config_route_Size.Value            = app.defaultConfigValues.route_Size;
            app.config_route_OutColor.Value        = app.defaultConfigValues.route_OutColor;
            app.config_route_InColor.Value         = app.defaultConfigValues.route_InColor;
            app.config_Car_LineStyle.Value         = app.defaultConfigValues.Car_LineStyle;
            app.config_Car_Color.Value             = app.defaultConfigValues.Car_Color;
            app.config_Car_Size.Value              = app.defaultConfigValues.Car_Size;
            app.config_points_LineStyle.Value      = app.defaultConfigValues.points_LineStyle;
            app.config_points_Color.Value          = app.defaultConfigValues.points_Color;
            app.config_points_Size.Value           = app.defaultConfigValues.points_Size;

            % % Eixos cartesianos - app.UIAxes2, app.UIAxes3 e app.UIAxes4
            app.config_PersistanceVisibility.Value = app.defaultConfigValues.persistancePlot;
            app.config_chROIVisibility.Value       = app.defaultConfigValues.chROIVisibility;
            app.config_chROIColor.Value            = app.mainApp.General.Plot.ChannelROI.Color;
            app.config_chROIEdgeAlpha.Value        = app.defaultConfigValues.chROIEdgeAlpha;
            app.config_chROIFaceAlpha.Value        = app.defaultConfigValues.chROIFaceAlpha;
            app.config_chPowerVisibility.Value     = app.defaultConfigValues.chPowerVisibility;
            app.config_chPowerColor.Value          = app.UIAxes3.Colormap(end,:);
            app.config_chPowerEdgeAlpha.Value      = app.defaultConfigValues.chPowerEdgeAlpha;
            app.config_chPowerFaceAlpha.Value      = app.defaultConfigValues.chPowerFaceAlpha;
            
            % % Atualiza o plot...
            operationType = 'RefreshPlotParameters';
            [idxThread, idxEmission] = specDataIndex(app, operationType);

            prePlot_Startup(app, idxThread, idxEmission, operationType)
            
            % Chama callbacks relacionados a parâmetros que não serão afetados 
            % pelo novo plot e, por isso, demandam uma atualização direta.
            config_geoAxesOthersParametersChanged(app, struct('Source', app.config_Colormap, 'Value', app.config_Colormap.Value))

            config_xyAxesParameterChanged(app, struct('Source', app.config_PersistanceVisibility))
            config_xyAxesParameterChanged(app, struct('Source', app.config_chROIVisibility))
            config_xyAxesParameterChanged(app, struct('Source', app.config_chROIColor))
            config_xyAxesParameterChanged(app, struct('Source', app.config_chPowerVisibility))

            if app.config_BandGuardType.Value ~= "BWRelated"
                app.config_BandGuardType.Value = 'BWRelated';
                config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardType))
            end

            if app.config_BandGuardBWRelatedValue.Value ~= 6
                app.config_BandGuardBWRelatedValue.Value = 6;
                config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))
            end

            checkIfCustomConfigParameter(app)

        end

        % Callback function: not associated with a component
        function filter_RadioGroupSelectionChanged(app, event)
            
            switch app.filter_RadioGroup.SelectedObject
                case app.filter_THR
                    app.SubGrid2.RowHeight{2} = 96;
                    app.filter_THR.Position(2) = 46;
                    app.filter_Geographic.Position(2) = 8;

                    app.filter_GeographicTypeLabel.Visible = 0;
                    app.filter_GeographicType.Visible      = 0;
                    set(findobj(app.filter_RadioGroup.Children, 'Tag', 'KML'), 'Visible', 0)

                case app.filter_Geographic
                    app.filter_GeographicTypeLabel.Visible = 1;
                    app.filter_GeographicType.Visible      = 1;
                    
                    filter_GeographicTypeValueChanged(app)
            end
            
        end

        % Callback function: not associated with a component
        function filter_GeographicTypeValueChanged(app, event)
            
            switch app.filter_GeographicType.Value
                case 'Arquivo externo KML/KMZ'
                    app.SubGrid2.RowHeight{2} = 208;

                    app.filter_THR.Position(2)                 = 158;
                    app.filter_Geographic.Position(2)          = 120;
                    app.filter_GeographicTypeLabel.Position(2) = 104;
                    app.filter_GeographicType.Position(2)      = 80;
                    app.filter_KMLFilenameLabel.Position(2)    = 61;
                    app.filter_KMLFilename.Position(2)         = 38;
                    app.filter_KMLOpenFile.Position(2)         = 40;
                    app.filter_KMLFileLayer.Position(2)        = 11;

                    set(findobj(app.filter_RadioGroup.Children, 'Tag', 'KML'), 'Visible', 1)

                otherwise
                    app.SubGrid2.RowHeight{2} = 140;

                    app.filter_THR.Position(2)                 = 90;
                    app.filter_Geographic.Position(2)          = 52;
                    app.filter_GeographicTypeLabel.Position(2) = 36;
                    app.filter_GeographicType.Position(2)      = 12;
                    
                    set(findobj(app.filter_RadioGroup.Children, 'Tag', 'KML'), 'Visible', 0)
            end
            
        end

        % Callback function: not associated with a component
        function filter_KMLOpenFileClicked(app, event)
            
            [~, filePath, ~, fileName] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.kml;*.kmz', '(*.kml, *.kmz)'}, app.mainApp.General.fileFolder.lastVisited);

            if ~isempty(fileName)
                app.progressDialog.Visible = 'visible';

                misc_updateLastVisitedFolder(app.mainApp, filePath)
                app.mainApp.General.fileFolder.lastVisited = filePath;

                try
                    if ~isempty(app.kmlObj)
                        delete(app.kmlObj)
                    end

                    app.kmlObj = RF.KML(fullfile(filePath, fileName));

                    [~, fileName, fileExt] = fileparts(app.kmlObj.File);
                    app.filter_KMLFilename.Value  = [fileName fileExt];
                    app.filter_KMLFileLayer.Items = app.kmlObj.LayerNames;

                catch ME
                    app.kmlObj = [];
                    app.filter_KMLFilename.Value  = '';
                    app.filter_KMLFileLayer.Items = {};

                    ui.Dialog(app.UIFigure, 'error', ME.message);
                end

                app.progressDialog.Visible = 'hidden';
            end            

        end

        % Callback function: not associated with a component
        function filter_AddFilterImageClicked(app, event)
            
            focus(app.FilterTree)

            switch app.filter_RadioGroup.SelectedObject
                case app.filter_THR
                    if ismember('Level', app.filterTable.type)
                        msgWarning = ['Já foi incluído o filtro de nível, cujo <i>threshold</i> pode ser ajustado ' ...
                                      'diretamente no eixo que apresenta a potência do canal sob análise.'];
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                        return
                    end

                    FilterType = 'Level';
                    FilterSubtype = 'Threshold';
                    Threshold = min(app.emissionPointsTable.ChannelPower);

                    hROI = plot_FilterROIObject(app, 'DrawInRealTime', FilterSubtype, app.UIAxes4);
                    hROI.Position = [height(app.emissionFilteredPointsTable) Threshold; 1 Threshold];

                    app.filterTable(end+1,:) = {FilterType, FilterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};

                case app.filter_Geographic
                    FilterType = 'Geographic ROI';

                    switch app.filter_GeographicType.Value
                        case 'Arquivo externo KML/KMZ'
                            if isempty(app.filter_KMLFilename.Value)
                                msgWarning = 'É preciso escolher um arquivo KML/KMZ antes de adicioná-lo como filtro geográfico.';
                                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                                return
                            end
                            
                            FilterSubtype = 'PolygonKML';

                            try
                                readgeotable(app.kmlObj, app.filter_KMLFileLayer.Value)
                                for ii = 1:height(app.kmlObj.GeoTable)
                                    shapeObj = app.kmlObj.GeoTable.Shape(ii);

                                    if isa(shapeObj, 'geopolyshape')
                                        hROI = plot_FilterROIObject(app, 'DrawInRealTime', FilterSubtype, app.UIAxes1, shapeObj);
                                        app.filterTable(end+1,:) = {FilterType, FilterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};
                                    end
                                end

                                if ~exist('hROI', 'var')
                                    error(['A pasta "%s", do arquivo "%s", possui apenas objetos do tipo "%s". Um filtro '  ...
                                           'geográfico, contudo, precisa ser um polígono.'], app.filter_KMLFileLayer.Value, ...
                                                                                             app.kmlObj.File,               ...
                                                                                             textFormatGUI.cellstr2ListWithQuotes(unique(arrayfun(@(x) class(x), app.kmlObj.GeoTable.Shape, "UniformOutput", false))))
                                end

                            catch ME
                                ui.Dialog(app.UIFigure, 'error', ME.message);
                                return
                            end

                        otherwise
                            switch app.filter_GeographicType.Value
                                case 'ROI:Círculo'
                                    FilterSubtype = 'Circle';
                                case 'ROI:Retângulo'
                                    FilterSubtype = 'Rectangle';
                                case 'ROI:Polígono'
                                    FilterSubtype = 'Polygon';
                            end

                            hROI = plot_FilterROIObject(app, 'DrawInRealTime', FilterSubtype, app.UIAxes1);

                            if isempty(hROI.Position)
                                delete(hROI)                
                                return
                            end

                            app.filterTable(end+1,:) = {FilterType, FilterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};
                    end
                    
                    if isprop(hROI, 'DisplayName')
                        hROI.DisplayName = 'Contorno';
                    end
            end
            
            % Insere filtro à tabela app.filterTable, redesenhando a árvore
            % de fitros.
            filter_TreeBuilding(app)

            % Atualiza o plot...
            filter_UpdatePlot(app)

        end

        % Menu selected function: filter_delAllButton, filter_delButton
        function filter_delFilter(app, event)
            
            if isempty(app.filterTable)
                return
            end

            switch event.Source
                case app.filter_delButton
                    if isempty(app.FilterTree.SelectedNodes)
                        return
                    end
                    idx = arrayfun(@(x) x.NodeData, app.FilterTree.SelectedNodes);

                case app.filter_delAllButton
                    idx = 1:height(app.filterTable);
            end 
    
            if ~isempty(idx)
                arrayfun(@(x) delete(x), [app.filterTable.roi(idx).handle]); 
                app.filterTable(idx,:) = [];

                filter_TreeBuilding(app)
                filter_UpdatePlot(app)
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

        % Callback function: not associated with a component
        function points_RadioGroupSelectionChanged(app, event)
            
            switch app.points_RadioGroup.SelectedObject
                case app.points_AddRFDataHub
                    app.points_AddValueGrid.RowHeight = {17,22,22,22,0,0,0,0};
                case app.points_AddFindPeaks
                    app.points_AddValueGrid.RowHeight = {0,0,0,0,17,22,22,22};
            end
            
        end

        % Callback function: not associated with a component
        function points_AddPointImageClicked(app, event)
            
            focus(app.PointsTree)

            try
                switch app.points_RadioGroup.SelectedObject
                    %-----------------------------------------------------%
                    case app.points_AddRFDataHub            
                        if isempty(app.points_Subtype1Value.Value)
                            return
                        end
                        global RFDataHub

                        entryText = app.points_Subtype1Value.Value;

                        % Inicialmente, identificam-se os valores da lista
                        % de entrada.            
                        switch app.points_Subtype1DropDown.Value
                            case 'Índices de registros do RFDataHub'
                                idxRawPoints = regexp(entryText, '#(\d+)', 'tokens');
                                if isempty(idxRawPoints)
                                    msgWarning = 'Valor inválido! Deve ser inserida lista de IDs dos registros do RFDataHub. Por exemplos: #1000 #1500 #2000';
                                    ui.Dialog(app.UIFigure, 'warning', msgWarning);
                                    return
                                end
                                idxRawPoints = str2double([idxRawPoints{:}]);
            
                            case 'Lista de frequências (MHz)'
                                freqList = regexp(entryText, '(\d+.\d+)', 'tokens');
                                if isempty(freqList)
                                    msgWarning = 'Valor inválido! Deve ser inserida lista de frequências em MHz. Por exemplos: 101.1, 101.3, 101.5';
                                    ui.Dialog(app.UIFigure, 'warning', msgWarning);
                                    return
                                end
                                freqList = cellfun(@(x) str2double(x), [freqList{:}]);
            
                                filterTempTable = table('Size',          [0, 9],                                                                      ...
                                                        'VariableTypes', {'cell', 'int8', 'int8', 'cell', 'cell', 'int8', 'cell', 'logical', 'cell'}, ...
                                                        'VariableNames', {'Order', 'ID', 'RelatedID', 'Type', 'Operation', 'Column', 'Value', 'Enable', 'uuid'});
            
                                for ii = 1:numel(freqList)
                                    if ii == 1; Order = 'Node';  RelatedID = -1;
                                    else;       Order = 'Child'; RelatedID = 1;
                                    end
                                    filterTempTable(ii,:) = {Order, ii, RelatedID, 'Frequência', '=', 1, {freqList(ii)}, true, ''};
                                end            
                                idxRawPoints = find(util.TableFiltering(RFDataHub, filterTempTable));
                        end

                        % Posteriormente, avalia-se quais desses registros 
                        % estão no entorno do local da monitoração.        
                        if ~isempty(idxRawPoints)
                            nRawPoints = numel(idxRawPoints);

                            idxThread = specDataIndex(app, 'EmissionShowed');
                            distanceArray = deg2km(distance(RFDataHub.Latitude(idxRawPoints),   RFDataHub.Longitude(idxRawPoints),  ...
                                                            app.specData(idxThread).GPS.Latitude, app.specData(idxThread).GPS.Longitude));

                            idxNewPoints = idxRawPoints(distanceArray <= app.points_Subtype1Distance.Value);
                            
                            
                            nNewPoints = numel(idxNewPoints);
                            if ~nNewPoints
                                error('Não identificada estação de telecomunicações que atenda ao critério.')
                            end
                            
                            newRow = {'RFDataHub',                                                                                                            ...
                                      struct('Source', app.points_Subtype1DropDown.Value, 'idxData', idxNewPoints, 'Data', RFDataHub(idxNewPoints,:)), ...
                                      true};
                            points_AddNewPoint2Table(app, newRow)
        
                            msgLOG = sprintf('Identificada(s) %d estação(ões) de telecomunicações que atende(m) ao critério.', nRawPoints);
                            if nNewPoints ~= nRawPoints
                                msgLOG = sprintf('%s Contudo, apenas %d atende(m) à distância máxima especificada.', msgLOG, nNewPoints);
                            end

                        else
                            error('Não identificada estação de telecomunicações que atenda ao critério.')
                        end
                        ui.Dialog(app.UIFigure, 'warning', msgLOG);
    
                    %---------------------------------------------------------%
                    case app.points_AddFindPeaks
                        [idxRawPoints, Coordinates] = points_FindPeaks(app, app.points_Subtype2DropDown.Value, app.points_Subtype2NPeaks.Value, app.points_Subtype2Distance.Value/1000);
                        newRow = {'FindPeaks',                                                                                       ...
                                  struct('Source', app.points_Subtype2DropDown.Value, 'idxData', idxRawPoints, 'Data', Coordinates), ...
                                  true};
                        points_AddNewPoint2Table(app, newRow)

                        msgLOG = sprintf('Identificado(s) %d ponto(s) que atende(m) ao critério.', numel(idxRawPoints));
                        ui.Dialog(app.UIFigure, 'warning', msgLOG);
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
                return
            end

            points_TreeBuilding(app)
            plot_PointsController(app)

        end

        % Callback function: not associated with a component
        function points_Subtype1ValueValueChanged2(app, event)

            app.points_Subtype1Value.Value = strtrim(app.points_Subtype1Value.Value);
            
        end

        % Callback function: PointsTree
        function PointsTreeCheckedNodesChanged(app, event)
            
            visibleNodeData   = arrayfun(@(x) x.NodeData, app.PointsTree.CheckedNodes);
            invisibleNodeData = setdiff(1:height(app.pointsTable), visibleNodeData);

            app.pointsTable.visible(visibleNodeData)   = true;
            app.pointsTable.visible(invisibleNodeData) = false;

            plot_PointsController(app)
            
        end

        % Menu selected function: points_delButton
        function points_delButtonMenuSelected(app, event)
            
            if isempty(app.pointsTable) || isempty(app.PointsTree.SelectedNodes)
                return
            end

            idx = arrayfun(@(x) x.NodeData, app.PointsTree.SelectedNodes);
    
            if ~isempty(idx)
                app.pointsTable(idx,:) = [];

                points_TreeBuilding(app)
                plot_PointsController(app)
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
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @Toolbar_LeftPanelVisibilityImageClicked, true);
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
            app.tool_LayoutRight.Layout.Row = [1 3];
            app.tool_LayoutRight.Layout.Column = 11;
            app.tool_LayoutRight.ImageSource = 'layout-sidebar-right.svg';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {320, 10, 5, 271, '1x', 10, 232};
            app.GridLayout2.RowHeight = {24, '1x'};
            app.GridLayout2.ColumnSpacing = 0;
            app.GridLayout2.RowSpacing = 0;
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = [3 4];
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create LeftPanel
            app.LeftPanel = uigridlayout(app.GridLayout2);
            app.LeftPanel.ColumnWidth = {'1x', 18, 10, 18};
            app.LeftPanel.RowHeight = {44, 22, 30, '1x'};
            app.LeftPanel.ColumnSpacing = 5;
            app.LeftPanel.RowSpacing = 5;
            app.LeftPanel.Padding = [0 0 0 0];
            app.LeftPanel.Layout.Row = [1 2];
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.BackgroundColor = [1 1 1];

            % Create SpectrumFlowList
            app.SpectrumFlowList = uidropdown(app.LeftPanel);
            app.SpectrumFlowList.Items = {};
            app.SpectrumFlowList.FontSize = 11;
            app.SpectrumFlowList.FontColor = [1 1 1];
            app.SpectrumFlowList.BackgroundColor = [0.7176 0.1922 0.1725];
            app.SpectrumFlowList.Layout.Row = 1;
            app.SpectrumFlowList.Layout.Column = [1 4];
            app.SpectrumFlowList.Value = {};

            % Create FlowPanelLabel
            app.FlowPanelLabel = uilabel(app.LeftPanel);
            app.FlowPanelLabel.FontSize = 10;
            app.FlowPanelLabel.Layout.Row = 3;
            app.FlowPanelLabel.Layout.Column = 1;
            app.FlowPanelLabel.Interpreter = 'html';
            app.FlowPanelLabel.Text = 'ATRIBUTOS DA EMISSÃO<br><font style="font-size: 11px;"><i>Metadados</i></font>';

            % Create FlowAttributesPanelVisibleIdx
            app.FlowAttributesPanelVisibleIdx = uilabel(app.LeftPanel);
            app.FlowAttributesPanelVisibleIdx.HorizontalAlignment = 'center';
            app.FlowAttributesPanelVisibleIdx.FontSize = 10;
            app.FlowAttributesPanelVisibleIdx.FontColor = [0.502 0.502 0.502];
            app.FlowAttributesPanelVisibleIdx.Layout.Row = 3;
            app.FlowAttributesPanelVisibleIdx.Layout.Column = [2 4];
            app.FlowAttributesPanelVisibleIdx.Text = '1/4';

            % Create FlowAttributesPanelLeftBtn
            app.FlowAttributesPanelLeftBtn = uiimage(app.LeftPanel);
            app.FlowAttributesPanelLeftBtn.Enable = 'off';
            app.FlowAttributesPanelLeftBtn.Layout.Row = 3;
            app.FlowAttributesPanelLeftBtn.Layout.Column = 2;
            app.FlowAttributesPanelLeftBtn.ImageSource = 'triangle-left.svg';

            % Create FlowAttributesPanelRightBtn
            app.FlowAttributesPanelRightBtn = uiimage(app.LeftPanel);
            app.FlowAttributesPanelRightBtn.Layout.Row = 3;
            app.FlowAttributesPanelRightBtn.Layout.Column = 4;
            app.FlowAttributesPanelRightBtn.ImageSource = 'triangle-right.svg';

            % Create FlowPanel
            app.FlowPanel = uipanel(app.LeftPanel);
            app.FlowPanel.AutoResizeChildren = 'off';
            app.FlowPanel.Layout.Row = 4;
            app.FlowPanel.Layout.Column = [1 4];

            % Create FlowPanelGrid
            app.FlowPanelGrid = uigridlayout(app.FlowPanel);
            app.FlowPanelGrid.ColumnWidth = {'1x', 10, '1x', 18, 10, '1x', 18, 10};
            app.FlowPanelGrid.RowHeight = {10, 22, 22, 5, 78, 10, 22, 22, 5, '1x', 10};
            app.FlowPanelGrid.ColumnSpacing = 0;
            app.FlowPanelGrid.RowSpacing = 0;
            app.FlowPanelGrid.Padding = [0 0 0 0];
            app.FlowPanelGrid.BackgroundColor = [1 1 1];

            % Create FlowMetadata
            app.FlowMetadata = uilabel(app.FlowPanelGrid);
            app.FlowMetadata.VerticalAlignment = 'top';
            app.FlowMetadata.WordWrap = 'on';
            app.FlowMetadata.FontSize = 11;
            app.FlowMetadata.Layout.Row = [1 11];
            app.FlowMetadata.Layout.Column = 1;
            app.FlowMetadata.Interpreter = 'html';
            app.FlowMetadata.Text = '';

            % Create filter_DataBinningPanel
            app.filter_DataBinningPanel = uipanel(app.FlowPanelGrid);
            app.filter_DataBinningPanel.AutoResizeChildren = 'off';
            app.filter_DataBinningPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.filter_DataBinningPanel.Layout.Row = 5;
            app.filter_DataBinningPanel.Layout.Column = [3 4];

            % Create filter_DataBinningGrid
            app.filter_DataBinningGrid = uigridlayout(app.filter_DataBinningPanel);
            app.filter_DataBinningGrid.ColumnWidth = {110, '1x'};
            app.filter_DataBinningGrid.RowHeight = {'1x', 22};
            app.filter_DataBinningGrid.RowSpacing = 5;
            app.filter_DataBinningGrid.BackgroundColor = [1 1 1];

            % Create filter_DataBinningLengthLabel
            app.filter_DataBinningLengthLabel = uilabel(app.filter_DataBinningGrid);
            app.filter_DataBinningLengthLabel.VerticalAlignment = 'bottom';
            app.filter_DataBinningLengthLabel.WordWrap = 'on';
            app.filter_DataBinningLengthLabel.FontSize = 11;
            app.filter_DataBinningLengthLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningLengthLabel.Layout.Row = 1;
            app.filter_DataBinningLengthLabel.Layout.Column = 1;
            app.filter_DataBinningLengthLabel.Interpreter = 'html';
            app.filter_DataBinningLengthLabel.Text = {'Comprimento '; 'quadrícula (metros):'};

            % Create filter_DataBinningLength
            app.filter_DataBinningLength = uispinner(app.filter_DataBinningGrid);
            app.filter_DataBinningLength.Step = 50;
            app.filter_DataBinningLength.Limits = [50 1500];
            app.filter_DataBinningLength.RoundFractionalValues = 'on';
            app.filter_DataBinningLength.ValueDisplayFormat = '%.0f';
            app.filter_DataBinningLength.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_DataSourceChanged, true);
            app.filter_DataBinningLength.FontSize = 11;
            app.filter_DataBinningLength.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningLength.Layout.Row = 2;
            app.filter_DataBinningLength.Layout.Column = 1;
            app.filter_DataBinningLength.Value = 100;

            % Create filter_DataBinningFcnLabel
            app.filter_DataBinningFcnLabel = uilabel(app.filter_DataBinningGrid);
            app.filter_DataBinningFcnLabel.VerticalAlignment = 'bottom';
            app.filter_DataBinningFcnLabel.WordWrap = 'on';
            app.filter_DataBinningFcnLabel.FontSize = 11;
            app.filter_DataBinningFcnLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningFcnLabel.Layout.Row = 1;
            app.filter_DataBinningFcnLabel.Layout.Column = 2;
            app.filter_DataBinningFcnLabel.Text = {'Função'; 'estatística:'};

            % Create filter_DataBinningFcn
            app.filter_DataBinningFcn = uidropdown(app.filter_DataBinningGrid);
            app.filter_DataBinningFcn.Items = {'min', 'mean', 'median', 'rms', 'max'};
            app.filter_DataBinningFcn.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_DataSourceChanged, true);
            app.filter_DataBinningFcn.FontSize = 11;
            app.filter_DataBinningFcn.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningFcn.BackgroundColor = [1 1 1];
            app.filter_DataBinningFcn.Layout.Row = 2;
            app.filter_DataBinningFcn.Layout.Column = 2;
            app.filter_DataBinningFcn.Value = 'rms';

            % Create FilterTree
            app.FilterTree = uitree(app.FlowPanelGrid);
            app.FilterTree.SelectionChangedFcn = createCallbackFcn(app, @FilterTreeSelectionChanged, true);
            app.FilterTree.FontSize = 10.5;
            app.FilterTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTree.Layout.Row = 10;
            app.FilterTree.Layout.Column = [3 4];

            % Create filter_DataBinningLabel
            app.filter_DataBinningLabel = uilabel(app.FlowPanelGrid);
            app.filter_DataBinningLabel.VerticalAlignment = 'top';
            app.filter_DataBinningLabel.WordWrap = 'on';
            app.filter_DataBinningLabel.FontSize = 10;
            app.filter_DataBinningLabel.Layout.Row = [2 3];
            app.filter_DataBinningLabel.Layout.Column = [3 4];
            app.filter_DataBinningLabel.Interpreter = 'html';
            app.filter_DataBinningLabel.Text = {'DATA-BINNING'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Agrupa medições em quadrículas, sumarizando-as por meio de função estatística.</p>'};

            % Create filter_DataBinningLabel_2
            app.filter_DataBinningLabel_2 = uilabel(app.FlowPanelGrid);
            app.filter_DataBinningLabel_2.VerticalAlignment = 'top';
            app.filter_DataBinningLabel_2.WordWrap = 'on';
            app.filter_DataBinningLabel_2.FontSize = 10;
            app.filter_DataBinningLabel_2.Layout.Row = [7 9];
            app.filter_DataBinningLabel_2.Layout.Column = [3 4];
            app.filter_DataBinningLabel_2.Interpreter = 'html';
            app.filter_DataBinningLabel_2.Text = {'FILTRAGEM DE DADOS'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Remove medições com base em critérios de nível de sinal e localização geográfica.</p>'};

            % Create FlowChannelEdit
            app.FlowChannelEdit = uiimage(app.FlowPanelGrid);
            app.FlowChannelEdit.Enable = 'off';
            app.FlowChannelEdit.Layout.Row = 8;
            app.FlowChannelEdit.Layout.Column = 4;
            app.FlowChannelEdit.VerticalAlignment = 'bottom';
            app.FlowChannelEdit.ImageSource = 'Edit_32.png';

            % Create PointsTree
            app.PointsTree = uitree(app.FlowPanelGrid, 'checkbox');
            app.PointsTree.FontSize = 10.5;
            app.PointsTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PointsTree.Layout.Row = [5 10];
            app.PointsTree.Layout.Column = [6 7];

            % Assign Checked Nodes
            app.PointsTree.CheckedNodesChangedFcn = createCallbackFcn(app, @PointsTreeCheckedNodesChanged, true);

            % Create filter_DataBinningLabel_3
            app.filter_DataBinningLabel_3 = uilabel(app.FlowPanelGrid);
            app.filter_DataBinningLabel_3.VerticalAlignment = 'top';
            app.filter_DataBinningLabel_3.WordWrap = 'on';
            app.filter_DataBinningLabel_3.FontSize = 10;
            app.filter_DataBinningLabel_3.Layout.Row = [2 3];
            app.filter_DataBinningLabel_3.Layout.Column = [6 7];
            app.filter_DataBinningLabel_3.Interpreter = 'html';
            app.filter_DataBinningLabel_3.Text = {'PONTOS DE INTERESSE'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Destaca locais relevantes, como máximos de potência e estações de telecomunicações.</p>'};

            % Create FlowChannelEdit_2
            app.FlowChannelEdit_2 = uiimage(app.FlowPanelGrid);
            app.FlowChannelEdit_2.Enable = 'off';
            app.FlowChannelEdit_2.Layout.Row = 3;
            app.FlowChannelEdit_2.Layout.Column = 7;
            app.FlowChannelEdit_2.VerticalAlignment = 'bottom';
            app.FlowChannelEdit_2.ImageSource = 'Edit_32.png';

            % Create EmissionList
            app.EmissionList = uidropdown(app.LeftPanel);
            app.EmissionList.Items = {};
            app.EmissionList.ValueChangedFcn = createCallbackFcn(app, @general_EmissionChanged, true);
            app.EmissionList.FontSize = 11;
            app.EmissionList.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EmissionList.BackgroundColor = [1 1 1];
            app.EmissionList.Layout.Row = 2;
            app.EmissionList.Layout.Column = [1 4];
            app.EmissionList.Value = {};

            % Create Document
            app.Document = uipanel(app.GridLayout2);
            app.Document.AutoResizeChildren = 'off';
            app.Document.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Document.BorderType = 'none';
            app.Document.BackgroundColor = [0 0 0];
            app.Document.Layout.Row = [1 2];
            app.Document.Layout.Column = [3 5];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.GridLayout2);
            app.AxesToolbar.ColumnWidth = {5, 22, 22, 5, '1x', 5, 22, 22, 5, '1x'};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [0 2 0 1];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 4;
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
            app.axesTool_DataSourceDropDown.Items = {'Dados brutos', 'Dados processados'};
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

            % Create RightPanel
            app.RightPanel = uigridlayout(app.GridLayout2);
            app.RightPanel.ColumnWidth = {18, '1x'};
            app.RightPanel.RowHeight = {5, 17, 5, 124, 5, 5, 17, 5, 168, 5, 5, 17, 5, '1x'};
            app.RightPanel.ColumnSpacing = 5;
            app.RightPanel.RowSpacing = 0;
            app.RightPanel.Padding = [0 0 0 0];
            app.RightPanel.Layout.Row = [1 2];
            app.RightPanel.Layout.Column = 7;
            app.RightPanel.BackgroundColor = [1 1 1];

            % Create GeneralPanelIcon
            app.GeneralPanelIcon = uiimage(app.RightPanel);
            app.GeneralPanelIcon.Layout.Row = [1 3];
            app.GeneralPanelIcon.Layout.Column = 1;
            app.GeneralPanelIcon.ImageSource = 'DriveTestDensity_32.png';

            % Create GeneralPanelLabel
            app.GeneralPanelLabel = uilabel(app.RightPanel);
            app.GeneralPanelLabel.VerticalAlignment = 'bottom';
            app.GeneralPanelLabel.FontSize = 10;
            app.GeneralPanelLabel.Layout.Row = 2;
            app.GeneralPanelLabel.Layout.Column = 2;
            app.GeneralPanelLabel.Text = 'EIXOS GRÁFICOS';

            % Create GeneralPanel
            app.GeneralPanel = uipanel(app.RightPanel);
            app.GeneralPanel.AutoResizeChildren = 'off';
            app.GeneralPanel.BackgroundColor = [1 1 1];
            app.GeneralPanel.Layout.Row = 4;
            app.GeneralPanel.Layout.Column = [1 2];

            % Create GeneralPanelGrid
            app.GeneralPanelGrid = uigridlayout(app.GeneralPanel);
            app.GeneralPanelGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.GeneralPanelGrid.RowHeight = {22, 20, 22, 22};
            app.GeneralPanelGrid.RowSpacing = 5;
            app.GeneralPanelGrid.BackgroundColor = [1 1 1];

            % Create LayoutRatioLabel
            app.LayoutRatioLabel = uilabel(app.GeneralPanelGrid);
            app.LayoutRatioLabel.FontSize = 11;
            app.LayoutRatioLabel.Layout.Row = 1;
            app.LayoutRatioLabel.Layout.Column = [1 3];
            app.LayoutRatioLabel.Text = 'Razão de aspecto:';

            % Create LayoutRatio
            app.LayoutRatio = uidropdown(app.GeneralPanelGrid);
            app.LayoutRatio.Items = {'1:0:0'};
            app.LayoutRatio.Tag = 'layoutRatio';
            app.LayoutRatio.FontSize = 11;
            app.LayoutRatio.BackgroundColor = [1 1 1];
            app.LayoutRatio.Layout.Row = 1;
            app.LayoutRatio.Layout.Column = [4 5];
            app.LayoutRatio.Value = '1:0:0';

            % Create LimitsPanelLabel
            app.LimitsPanelLabel = uilabel(app.GeneralPanelGrid);
            app.LimitsPanelLabel.VerticalAlignment = 'bottom';
            app.LimitsPanelLabel.FontSize = 11;
            app.LimitsPanelLabel.Layout.Row = 2;
            app.LimitsPanelLabel.Layout.Column = [1 4];
            app.LimitsPanelLabel.Text = 'Limites de frequência e nível:';

            % Create LimitsRefresh
            app.LimitsRefresh = uiimage(app.GeneralPanelGrid);
            app.LimitsRefresh.ScaleMethod = 'none';
            app.LimitsRefresh.Tag = 'limitsXYRefresh';
            app.LimitsRefresh.Visible = 'off';
            app.LimitsRefresh.Layout.Row = 2;
            app.LimitsRefresh.Layout.Column = 5;
            app.LimitsRefresh.ImageSource = 'Refresh_18.png';

            % Create LimitsXLimLabel
            app.LimitsXLimLabel = uilabel(app.GeneralPanelGrid);
            app.LimitsXLimLabel.HorizontalAlignment = 'center';
            app.LimitsXLimLabel.FontSize = 10;
            app.LimitsXLimLabel.Layout.Row = 3;
            app.LimitsXLimLabel.Layout.Column = [1 5];
            app.LimitsXLimLabel.Text = 'MHz  ';

            % Create LimitsXLim1
            app.LimitsXLim1 = uispinner(app.GeneralPanelGrid);
            app.LimitsXLim1.ValueDisplayFormat = '%.3f';
            app.LimitsXLim1.Tag = 'limitsX';
            app.LimitsXLim1.FontSize = 11;
            app.LimitsXLim1.Layout.Row = 3;
            app.LimitsXLim1.Layout.Column = 1;

            % Create LimitsXLim2
            app.LimitsXLim2 = uispinner(app.GeneralPanelGrid);
            app.LimitsXLim2.ValueDisplayFormat = '%.3f';
            app.LimitsXLim2.Tag = 'limitsX';
            app.LimitsXLim2.FontSize = 11;
            app.LimitsXLim2.Layout.Row = 3;
            app.LimitsXLim2.Layout.Column = [4 5];
            app.LimitsXLim2.Value = 1;

            % Create LimitsYLimLabel
            app.LimitsYLimLabel = uilabel(app.GeneralPanelGrid);
            app.LimitsYLimLabel.HorizontalAlignment = 'center';
            app.LimitsYLimLabel.FontSize = 10;
            app.LimitsYLimLabel.Layout.Row = 4;
            app.LimitsYLimLabel.Layout.Column = [1 5];
            app.LimitsYLimLabel.Text = 'dB  ';

            % Create LimitsYLim1
            app.LimitsYLim1 = uispinner(app.GeneralPanelGrid);
            app.LimitsYLim1.Step = 5;
            app.LimitsYLim1.ValueDisplayFormat = '%.1f';
            app.LimitsYLim1.Tag = 'limitsY';
            app.LimitsYLim1.FontSize = 11;
            app.LimitsYLim1.Layout.Row = 4;
            app.LimitsYLim1.Layout.Column = 1;

            % Create LimitsYLim2
            app.LimitsYLim2 = uispinner(app.GeneralPanelGrid);
            app.LimitsYLim2.Step = 5;
            app.LimitsYLim2.ValueDisplayFormat = '%.1f';
            app.LimitsYLim2.Tag = 'limitsY';
            app.LimitsYLim2.FontSize = 11;
            app.LimitsYLim2.Layout.Row = 4;
            app.LimitsYLim2.Layout.Column = [4 5];
            app.LimitsYLim2.Value = 1;

            % Create PersistencePanelIcon
            app.PersistencePanelIcon = uiimage(app.RightPanel);
            app.PersistencePanelIcon.Layout.Row = [6 8];
            app.PersistencePanelIcon.Layout.Column = 1;
            app.PersistencePanelIcon.ImageSource = 'persistence-36px.png';

            % Create PersistencePanelLabel
            app.PersistencePanelLabel = uilabel(app.RightPanel);
            app.PersistencePanelLabel.VerticalAlignment = 'bottom';
            app.PersistencePanelLabel.FontSize = 10;
            app.PersistencePanelLabel.Layout.Row = 7;
            app.PersistencePanelLabel.Layout.Column = 2;
            app.PersistencePanelLabel.Text = 'PERSISTÊNCIA';

            % Create PersistencePanel
            app.PersistencePanel = uipanel(app.RightPanel);
            app.PersistencePanel.AutoResizeChildren = 'off';
            app.PersistencePanel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.PersistencePanel.Layout.Row = 9;
            app.PersistencePanel.Layout.Column = [1 2];

            % Create PersistencePanelGrid
            app.PersistencePanelGrid = uigridlayout(app.PersistencePanel);
            app.PersistencePanelGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.PersistencePanelGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.PersistencePanelGrid.RowSpacing = 5;
            app.PersistencePanelGrid.Padding = [10 10 10 5];
            app.PersistencePanelGrid.BackgroundColor = [1 1 1];

            % Create PersistenceInterpolationLabel
            app.PersistenceInterpolationLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceInterpolationLabel.VerticalAlignment = 'bottom';
            app.PersistenceInterpolationLabel.FontSize = 11;
            app.PersistenceInterpolationLabel.Layout.Row = 1;
            app.PersistenceInterpolationLabel.Layout.Column = [1 3];
            app.PersistenceInterpolationLabel.Text = 'Interpolação:';

            % Create PersistenceInterpolation
            app.PersistenceInterpolation = uidropdown(app.PersistencePanelGrid);
            app.PersistenceInterpolation.Items = {'nearest', 'bilinear'};
            app.PersistenceInterpolation.Tag = 'persistenceInterpolation';
            app.PersistenceInterpolation.Enable = 'off';
            app.PersistenceInterpolation.FontSize = 11;
            app.PersistenceInterpolation.BackgroundColor = [1 1 1];
            app.PersistenceInterpolation.Layout.Row = 2;
            app.PersistenceInterpolation.Layout.Column = [1 2];
            app.PersistenceInterpolation.Value = 'nearest';

            % Create PersistenceWindowSizeLabel
            app.PersistenceWindowSizeLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceWindowSizeLabel.VerticalAlignment = 'bottom';
            app.PersistenceWindowSizeLabel.FontSize = 11;
            app.PersistenceWindowSizeLabel.Layout.Row = 1;
            app.PersistenceWindowSizeLabel.Layout.Column = [3 5];
            app.PersistenceWindowSizeLabel.Text = 'Tamanho janela:';

            % Create PersistenceWindowSizeValue
            app.PersistenceWindowSizeValue = uilabel(app.PersistencePanelGrid);
            app.PersistenceWindowSizeValue.HorizontalAlignment = 'right';
            app.PersistenceWindowSizeValue.VerticalAlignment = 'bottom';
            app.PersistenceWindowSizeValue.FontSize = 11;
            app.PersistenceWindowSizeValue.FontColor = [0.8 0.8 0.8];
            app.PersistenceWindowSizeValue.Layout.Row = 1;
            app.PersistenceWindowSizeValue.Layout.Column = [3 5];
            app.PersistenceWindowSizeValue.Text = 'full';

            % Create PersistenceWindowSize
            app.PersistenceWindowSize = uidropdown(app.PersistencePanelGrid);
            app.PersistenceWindowSize.Items = {'128', '256', '512', 'full'};
            app.PersistenceWindowSize.Tag = 'persistenceWindowSize';
            app.PersistenceWindowSize.Enable = 'off';
            app.PersistenceWindowSize.FontSize = 11;
            app.PersistenceWindowSize.BackgroundColor = [1 1 1];
            app.PersistenceWindowSize.Layout.Row = 2;
            app.PersistenceWindowSize.Layout.Column = [3 5];
            app.PersistenceWindowSize.Value = '128';

            % Create PersistenceColormapLabel
            app.PersistenceColormapLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceColormapLabel.VerticalAlignment = 'bottom';
            app.PersistenceColormapLabel.FontSize = 11;
            app.PersistenceColormapLabel.Layout.Row = 3;
            app.PersistenceColormapLabel.Layout.Column = [1 2];
            app.PersistenceColormapLabel.Text = 'Mapa de cores:';

            % Create PersistenceColormap
            app.PersistenceColormap = uidropdown(app.PersistencePanelGrid);
            app.PersistenceColormap.Items = {'winter', 'parula', 'turbo'};
            app.PersistenceColormap.Tag = 'persistenceColormap';
            app.PersistenceColormap.Enable = 'off';
            app.PersistenceColormap.FontSize = 11;
            app.PersistenceColormap.BackgroundColor = [1 1 1];
            app.PersistenceColormap.Layout.Row = 4;
            app.PersistenceColormap.Layout.Column = [1 2];
            app.PersistenceColormap.Value = 'winter';

            % Create PersistenceTransparencyLabel
            app.PersistenceTransparencyLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceTransparencyLabel.VerticalAlignment = 'bottom';
            app.PersistenceTransparencyLabel.WordWrap = 'on';
            app.PersistenceTransparencyLabel.FontSize = 11;
            app.PersistenceTransparencyLabel.Layout.Row = 3;
            app.PersistenceTransparencyLabel.Layout.Column = [3 5];
            app.PersistenceTransparencyLabel.Text = 'Transparência:';

            % Create PersistenceTransparency
            app.PersistenceTransparency = uispinner(app.PersistencePanelGrid);
            app.PersistenceTransparency.Step = 0.05;
            app.PersistenceTransparency.Limits = [0.2 1];
            app.PersistenceTransparency.ValueDisplayFormat = '%.2f';
            app.PersistenceTransparency.Tag = 'persistenceTransparency';
            app.PersistenceTransparency.FontSize = 11;
            app.PersistenceTransparency.Enable = 'off';
            app.PersistenceTransparency.Layout.Row = 4;
            app.PersistenceTransparency.Layout.Column = [3 5];
            app.PersistenceTransparency.Value = 1;

            % Create PersistenceCLim_Label
            app.PersistenceCLim_Label = uilabel(app.PersistencePanelGrid);
            app.PersistenceCLim_Label.VerticalAlignment = 'bottom';
            app.PersistenceCLim_Label.FontSize = 11;
            app.PersistenceCLim_Label.Layout.Row = 5;
            app.PersistenceCLim_Label.Layout.Column = [1 4];
            app.PersistenceCLim_Label.Text = 'Limites de intensidade (%):';

            % Create PersistenceCLimRefresh
            app.PersistenceCLimRefresh = uiimage(app.PersistencePanelGrid);
            app.PersistenceCLimRefresh.ScaleMethod = 'none';
            app.PersistenceCLimRefresh.Tag = 'limitsPersistenceRefresh';
            app.PersistenceCLimRefresh.Visible = 'off';
            app.PersistenceCLimRefresh.Layout.Row = 5;
            app.PersistenceCLimRefresh.Layout.Column = 5;
            app.PersistenceCLimRefresh.ImageSource = 'Refresh_18.png';

            % Create PersistenceCLim1
            app.PersistenceCLim1 = uispinner(app.PersistencePanelGrid);
            app.PersistenceCLim1.Step = 0.1;
            app.PersistenceCLim1.Limits = [0 Inf];
            app.PersistenceCLim1.ValueDisplayFormat = '%.3f';
            app.PersistenceCLim1.Tag = 'limitsPersistence';
            app.PersistenceCLim1.FontSize = 11;
            app.PersistenceCLim1.Enable = 'off';
            app.PersistenceCLim1.Layout.Row = 6;
            app.PersistenceCLim1.Layout.Column = [1 2];
            app.PersistenceCLim1.Value = 0.1;

            % Create PersistenceCLim2
            app.PersistenceCLim2 = uispinner(app.PersistencePanelGrid);
            app.PersistenceCLim2.Limits = [0 Inf];
            app.PersistenceCLim2.ValueDisplayFormat = '%.3f';
            app.PersistenceCLim2.Tag = 'limitsPersistence';
            app.PersistenceCLim2.FontSize = 11;
            app.PersistenceCLim2.Enable = 'off';
            app.PersistenceCLim2.Layout.Row = 6;
            app.PersistenceCLim2.Layout.Column = [3 5];
            app.PersistenceCLim2.Value = 1;

            % Create WaterfallPanelIcon
            app.WaterfallPanelIcon = uiimage(app.RightPanel);
            app.WaterfallPanelIcon.ScaleMethod = 'none';
            app.WaterfallPanelIcon.Layout.Row = [11 13];
            app.WaterfallPanelIcon.Layout.Column = 1;
            app.WaterfallPanelIcon.ImageSource = 'waterfall-22px.png';

            % Create WaterfallPanelLabel
            app.WaterfallPanelLabel = uilabel(app.RightPanel);
            app.WaterfallPanelLabel.VerticalAlignment = 'bottom';
            app.WaterfallPanelLabel.FontSize = 10;
            app.WaterfallPanelLabel.Layout.Row = 12;
            app.WaterfallPanelLabel.Layout.Column = 2;
            app.WaterfallPanelLabel.Text = 'WATERFALL';

            % Create WaterfallPanel
            app.WaterfallPanel = uipanel(app.RightPanel);
            app.WaterfallPanel.AutoResizeChildren = 'off';
            app.WaterfallPanel.Layout.Row = 14;
            app.WaterfallPanel.Layout.Column = [1 2];

            % Create WaterfallPanelGrid
            app.WaterfallPanelGrid = uigridlayout(app.WaterfallPanel);
            app.WaterfallPanelGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.WaterfallPanelGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.WaterfallPanelGrid.RowSpacing = 5;
            app.WaterfallPanelGrid.Padding = [10 10 10 5];
            app.WaterfallPanelGrid.BackgroundColor = [1 1 1];

            % Create WaterfallFunctionLabel
            app.WaterfallFunctionLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallFunctionLabel.VerticalAlignment = 'bottom';
            app.WaterfallFunctionLabel.WordWrap = 'on';
            app.WaterfallFunctionLabel.FontSize = 11;
            app.WaterfallFunctionLabel.Layout.Row = 1;
            app.WaterfallFunctionLabel.Layout.Column = [1 3];
            app.WaterfallFunctionLabel.Text = 'Renderização:';

            % Create WaterfallFunction
            app.WaterfallFunction = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallFunction.Items = {'image', 'mesh'};
            app.WaterfallFunction.Tag = 'waterfallFunction';
            app.WaterfallFunction.Enable = 'off';
            app.WaterfallFunction.FontSize = 11;
            app.WaterfallFunction.BackgroundColor = [1 1 1];
            app.WaterfallFunction.Layout.Row = 2;
            app.WaterfallFunction.Layout.Column = [1 2];
            app.WaterfallFunction.Value = 'image';

            % Create WaterfallDecimationLabel
            app.WaterfallDecimationLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallDecimationLabel.VerticalAlignment = 'bottom';
            app.WaterfallDecimationLabel.FontSize = 11;
            app.WaterfallDecimationLabel.Layout.Row = 1;
            app.WaterfallDecimationLabel.Layout.Column = [3 4];
            app.WaterfallDecimationLabel.Text = 'Decimação:';

            % Create WaterfallDecimationValue
            app.WaterfallDecimationValue = uilabel(app.WaterfallPanelGrid);
            app.WaterfallDecimationValue.HorizontalAlignment = 'right';
            app.WaterfallDecimationValue.VerticalAlignment = 'bottom';
            app.WaterfallDecimationValue.FontSize = 11;
            app.WaterfallDecimationValue.FontColor = [0.8 0.8 0.8];
            app.WaterfallDecimationValue.Layout.Row = 1;
            app.WaterfallDecimationValue.Layout.Column = [3 5];
            app.WaterfallDecimationValue.Text = 'auto';

            % Create WaterfallDecimation
            app.WaterfallDecimation = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallDecimation.Items = {'auto', '1', '2', '4', '8', '16', '32', '64', '128', '256'};
            app.WaterfallDecimation.Tag = 'waterfallDecimation';
            app.WaterfallDecimation.Enable = 'off';
            app.WaterfallDecimation.FontSize = 11;
            app.WaterfallDecimation.BackgroundColor = [1 1 1];
            app.WaterfallDecimation.Layout.Row = 2;
            app.WaterfallDecimation.Layout.Column = [3 5];
            app.WaterfallDecimation.Value = 'auto';

            % Create WaterfallColormapLabel
            app.WaterfallColormapLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallColormapLabel.VerticalAlignment = 'bottom';
            app.WaterfallColormapLabel.FontSize = 11;
            app.WaterfallColormapLabel.Layout.Row = 3;
            app.WaterfallColormapLabel.Layout.Column = [1 3];
            app.WaterfallColormapLabel.Text = 'Mapa de cores:';

            % Create WaterfallColormap
            app.WaterfallColormap = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallColormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.WaterfallColormap.Tag = 'waterfallColormap';
            app.WaterfallColormap.Enable = 'off';
            app.WaterfallColormap.FontSize = 11;
            app.WaterfallColormap.BackgroundColor = [1 1 1];
            app.WaterfallColormap.Layout.Row = 4;
            app.WaterfallColormap.Layout.Column = [1 2];
            app.WaterfallColormap.Value = 'winter';

            % Create WaterfallMeshStyleLabel
            app.WaterfallMeshStyleLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallMeshStyleLabel.VerticalAlignment = 'bottom';
            app.WaterfallMeshStyleLabel.FontSize = 11;
            app.WaterfallMeshStyleLabel.Layout.Row = 3;
            app.WaterfallMeshStyleLabel.Layout.Column = [3 5];
            app.WaterfallMeshStyleLabel.Text = 'Linhas da superfície:';

            % Create WaterfallMeshStyle
            app.WaterfallMeshStyle = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallMeshStyle.Items = {'row', 'both'};
            app.WaterfallMeshStyle.Tag = 'waterfallMeshStyle';
            app.WaterfallMeshStyle.Enable = 'off';
            app.WaterfallMeshStyle.FontSize = 11;
            app.WaterfallMeshStyle.BackgroundColor = [1 1 1];
            app.WaterfallMeshStyle.Layout.Row = 4;
            app.WaterfallMeshStyle.Layout.Column = [3 5];
            app.WaterfallMeshStyle.Value = 'row';

            % Create WaterfallCLimLabel
            app.WaterfallCLimLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallCLimLabel.VerticalAlignment = 'bottom';
            app.WaterfallCLimLabel.FontSize = 11;
            app.WaterfallCLimLabel.Layout.Row = 5;
            app.WaterfallCLimLabel.Layout.Column = [1 4];
            app.WaterfallCLimLabel.Text = 'Limites de nível (dB):';

            % Create WaterfallCLimRefresh
            app.WaterfallCLimRefresh = uiimage(app.WaterfallPanelGrid);
            app.WaterfallCLimRefresh.ScaleMethod = 'none';
            app.WaterfallCLimRefresh.Tag = 'limitsWaterfallRefresh';
            app.WaterfallCLimRefresh.Visible = 'off';
            app.WaterfallCLimRefresh.Layout.Row = 5;
            app.WaterfallCLimRefresh.Layout.Column = 5;
            app.WaterfallCLimRefresh.ImageSource = 'Refresh_18.png';

            % Create WaterfallCLim1
            app.WaterfallCLim1 = uispinner(app.WaterfallPanelGrid);
            app.WaterfallCLim1.Step = 5;
            app.WaterfallCLim1.RoundFractionalValues = 'on';
            app.WaterfallCLim1.ValueDisplayFormat = '%.0f';
            app.WaterfallCLim1.Tag = 'limitsWaterfall';
            app.WaterfallCLim1.FontSize = 11;
            app.WaterfallCLim1.Enable = 'off';
            app.WaterfallCLim1.Layout.Row = 6;
            app.WaterfallCLim1.Layout.Column = [1 2];

            % Create WaterfallCLim2
            app.WaterfallCLim2 = uispinner(app.WaterfallPanelGrid);
            app.WaterfallCLim2.Step = 5;
            app.WaterfallCLim2.RoundFractionalValues = 'on';
            app.WaterfallCLim2.ValueDisplayFormat = '%.0f';
            app.WaterfallCLim2.Tag = 'limitsWaterfall';
            app.WaterfallCLim2.FontSize = 11;
            app.WaterfallCLim2.Enable = 'off';
            app.WaterfallCLim2.Layout.Row = 6;
            app.WaterfallCLim2.Layout.Column = [3 5];
            app.WaterfallCLim2.Value = 1;

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

            % Create ContextMenu2
            app.ContextMenu2 = uicontextmenu(app.UIFigure);
            app.ContextMenu2.Tag = 'auxApp.winDriveTest';

            % Create filter_delButton
            app.filter_delButton = uimenu(app.ContextMenu2);
            app.filter_delButton.MenuSelectedFcn = createCallbackFcn(app, @filter_delFilter, true);
            app.filter_delButton.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_delButton.Text = 'Excluir';

            % Create filter_delAllButton
            app.filter_delAllButton = uimenu(app.ContextMenu2);
            app.filter_delAllButton.MenuSelectedFcn = createCallbackFcn(app, @filter_delFilter, true);
            app.filter_delAllButton.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_delAllButton.Text = 'Excluir todos';

            % Create ContextMenu1
            app.ContextMenu1 = uicontextmenu(app.UIFigure);
            app.ContextMenu1.Tag = 'auxApp.winDriveTest';

            % Create points_delButton
            app.points_delButton = uimenu(app.ContextMenu1);
            app.points_delButton.MenuSelectedFcn = createCallbackFcn(app, @points_delButtonMenuSelected, true);
            app.points_delButton.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_delButton.Text = 'Excluir';

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
