classdef winDriveTest_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModuleGroup                 matlab.ui.container.GridLayout
        dockModule_Undock               matlab.ui.control.Image
        dockModule_Close                matlab.ui.control.Image
        AxesToolbar                     matlab.ui.container.GridLayout
        axesTool_PlotSize               matlab.ui.control.Slider
        axesTool_DensityPlot            matlab.ui.control.Image
        axesTool_DistortionPlot         matlab.ui.control.Image
        axesTool_DropDown               matlab.ui.control.DropDown
        axesTool_RegionZoom             matlab.ui.control.Image
        axesTool_RestoreView            matlab.ui.control.Image
        Document                        matlab.ui.container.Panel
        TabGroup                        matlab.ui.container.TabGroup
        Tab1                            matlab.ui.container.Tab
        Tab1Grid                        matlab.ui.container.GridLayout
        reportFlag                      matlab.ui.control.CheckBox
        channelPanel                    matlab.ui.container.Panel
        channelGrid                     matlab.ui.container.GridLayout
        channelBandWidth                matlab.ui.control.NumericEditField
        channelBandWidthLabel           matlab.ui.control.Label
        channelFrequency                matlab.ui.control.NumericEditField
        channelFrequencyLabel           matlab.ui.control.Label
        channelEditGrid                 matlab.ui.container.GridLayout
        channelEditCancel               matlab.ui.control.Image
        channelEditConfirm              matlab.ui.control.Image
        channelEditMode                 matlab.ui.control.Image
        channelRefresh                  matlab.ui.control.Image
        channelLabel                    matlab.ui.control.Label
        emissionInfo                    matlab.ui.control.Label
        emissionList                    matlab.ui.control.DropDown
        emissionListLabel               matlab.ui.control.Label
        spectralThreadTree              matlab.ui.container.Tree
        spectralThreadPanel             matlab.ui.container.Panel
        spectralThreadGrid              matlab.ui.container.GridLayout
        spectralThread                  matlab.ui.control.Label
        spectralThreadEditGrid          matlab.ui.container.GridLayout
        spectralThreadEditCancel        matlab.ui.control.Image
        spectralThreadEditConfirm       matlab.ui.control.Image
        spectralThreadEdit              matlab.ui.control.Image
        spectralThreadLabel             matlab.ui.control.Label
        Tab2                            matlab.ui.container.Tab
        Tab2Grid                        matlab.ui.container.GridLayout
        filter_DataBinningPanel         matlab.ui.container.Panel
        filter_DataBinningGrid          matlab.ui.container.GridLayout
        filter_DataBinningFcn           matlab.ui.control.DropDown
        filter_DataBinningFcnLabel      matlab.ui.control.Label
        filter_DataBinningLength        matlab.ui.control.Spinner
        filter_DataBinningLengthLabel   matlab.ui.control.Label
        filter_DataBinningLabel         matlab.ui.control.Label
        filter_Tree                     matlab.ui.container.Tree
        filter_AddImage                 matlab.ui.control.Image
        filter_RadioGroup               matlab.ui.container.ButtonGroup
        filter_KMLFileLayer             matlab.ui.control.DropDown
        filter_KMLOpenFile              matlab.ui.control.Image
        filter_KMLFilename              matlab.ui.control.EditField
        filter_KMLFilenameLabel         matlab.ui.control.Label
        filter_GeographicType           matlab.ui.control.DropDown
        filter_GeographicTypeLabel      matlab.ui.control.Label
        filter_Geographic               matlab.ui.control.RadioButton
        filter_THR                      matlab.ui.control.RadioButton
        filter_TreeLabel                matlab.ui.control.Label
        Tab3                            matlab.ui.container.Tab
        Tab3Grid                        matlab.ui.container.GridLayout
        points_Tree                     matlab.ui.container.CheckBoxTree
        points_AddImage                 matlab.ui.control.Image
        points_AddValuePanel            matlab.ui.container.Panel
        points_AddValueGrid             matlab.ui.container.GridLayout
        points_Subtype2Distance         matlab.ui.control.Spinner
        points_Subtype2DistanceLabel    matlab.ui.control.Label
        points_Subtype2NPeaks           matlab.ui.control.Spinner
        points_Subtype2NPeaksLabel      matlab.ui.control.Label
        points_Subtype2DropDown         matlab.ui.control.DropDown
        points_Subtype2Label            matlab.ui.control.Label
        points_Subtype1Distance         matlab.ui.control.NumericEditField
        points_Subtype1DistanceLabel    matlab.ui.control.Label
        points_Subtype1Value            matlab.ui.control.EditField
        points_Subtype1DropDown         matlab.ui.control.DropDown
        points_Subtype1Label            matlab.ui.control.Label
        points_RadioGroup               matlab.ui.container.ButtonGroup
        points_AddFindPeaks             matlab.ui.control.RadioButton
        points_AddRFDataHub             matlab.ui.control.RadioButton
        points_TreeLabel                matlab.ui.control.Label
        Tab4                            matlab.ui.container.Tab
        Tab4Grid                        matlab.ui.container.GridLayout
        config_xyAxesPanel              matlab.ui.container.Panel
        config_xyAxesGrid               matlab.ui.container.GridLayout
        config_BandGuardPanel           matlab.ui.container.Panel
        config_BandGuardGrid            matlab.ui.container.GridLayout
        config_BandGuardBWRelatedValue  matlab.ui.control.Spinner
        config_BandGuardFixedValue      matlab.ui.control.NumericEditField
        config_BandGuardValueLabel      matlab.ui.control.Label
        config_BandGuardType            matlab.ui.control.DropDown
        config_BandGuardTypeLabel       matlab.ui.control.Label
        config_BandGuardLabel           matlab.ui.control.Label
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
        config_xyAxesLabel              matlab.ui.control.Label
        config_geoAxesPanel             matlab.ui.container.Panel
        config_geoAxesGrid              matlab.ui.container.GridLayout
        config_points_Size              matlab.ui.control.Slider
        config_points_Color             matlab.ui.control.ColorPicker
        config_points_LineStyle         matlab.ui.control.DropDown
        config_points_Label             matlab.ui.control.Label
        config_Car_Size                 matlab.ui.control.Slider
        config_Car_Color                matlab.ui.control.ColorPicker
        config_Car_LineStyle            matlab.ui.control.DropDown
        config_Car_Label                matlab.ui.control.Label
        config_route_Size               matlab.ui.control.Slider
        config_route_InColor            matlab.ui.control.ColorPicker
        config_route_OutColor           matlab.ui.control.ColorPicker
        config_route_LineStyle          matlab.ui.control.DropDown
        config_route_Label              matlab.ui.control.Label
        config_geoAxesSubPanel          matlab.ui.container.Panel
        config_geoAxesSubGrid           matlab.ui.container.GridLayout
        config_Colormap                 matlab.ui.control.DropDown
        config_ColormapLabel            matlab.ui.control.Label
        config_Basemap                  matlab.ui.control.DropDown
        config_BasemapLabel             matlab.ui.control.Label
        config_geoAxesSublabel          matlab.ui.control.Label
        config_Refresh                  matlab.ui.control.Image
        config_geoAxesLabel             matlab.ui.control.Label
        Toolbar                         matlab.ui.container.GridLayout
        tool_FilterSummary              matlab.ui.control.Image
        tool_DataBinningExport          matlab.ui.control.Image
        tool_TimestampLabel             matlab.ui.control.Label
        tool_TimestampSlider            matlab.ui.control.Slider
        tool_LoopControl                matlab.ui.control.Image
        tool_Play                       matlab.ui.control.Image
        tool_ControlPanelVisibility     matlab.ui.control.Image
        ContextMenu2                    matlab.ui.container.ContextMenu
        filter_delButton                matlab.ui.container.Menu
        filter_delAllButton             matlab.ui.container.Menu
        ContextMenu1                    matlab.ui.container.ContextMenu
        points_delButton                matlab.ui.container.Menu
    end

    
    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false

        mainApp
        General
        General_I
        specData

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj
        jsBackDoor

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog        

        %-----------------------------------------------------------------%
        % ESPECIFICIDADES AUXAPP.WINDRIVETEST
        %-----------------------------------------------------------------%
        tempBandObj
        KMLObj

        % POTÊNCIA DE CANAL, FILTRAGEM, DATA-BINNING
        selectedEmission

        specRawTable
        specFilteredTable
        specBinTable

        filterTable = table({}, {}, struct('handle', {}, 'specification', {}),               'VariableNames', {'type', 'subtype', 'roi'})
        pointsTable = table({}, struct('Source', {}, 'idxData', {}, 'Data', {}), true(0, 1), 'VariableNames', {'type', 'value', 'visible'})

        % PLOT+PLAYBACK
        UIAxes1
        UIAxes2
        UIAxes3
        UIAxes4
        restoreView = struct('ID', {}, 'xLim', {}, 'yLim', {}, 'cLim', {})
        
        plotFlag = 0
        idxTime  = 1
        
        hClearWrite
        hTimeline
        hCar
    end


    methods
        %-----------------------------------------------------------------%
        % IPC: COMUNICAÇÃO ENTRE PROCESSOS
        %-----------------------------------------------------------------%
        function ipcSecundaryJSEventsHandler(app, event, varargin)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        startup_Controller(app, varargin{:})
                    case 'auxApp.winDriveTest.filter_Tree'
                        filter_delFilter(app, struct('Source', app.filter_delButton))
                    case 'auxApp.winDriveTest.points_Tree'
                        points_delButtonMenuSelected(app)
                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecundaryMatlabCallsHandler(app, callingApp, varargin)
            try
                switch class(callingApp)
                    case {'winAppAnalise', 'winAppAnalise_exported'}
                        [idxThread, idxEmission] = specDataIndex(app, 'EmissionShowed');
            
                        if isempty(idxThread) || isempty(app.specData(idxThread).UserData.Emissions)
                            closeFcn(app)
                            return
                        end
            
                        preSelection = app.emissionList.Value;
                        layout_EmissionListCreation(app, idxThread, idxEmission)
            
                        if ismember(preSelection, app.emissionList.Items)
                            app.emissionList.Value = preSelection;
                        else
                            general_EmissionChanged(app, struct('Source', app.emissionList))
                        end
                    otherwise
                        error('UnexpectedCall')
                end
            
            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR: CUSTOMIZAÇÃO GUI (ESTÉTICA/COMPORTAMENTAL)
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app, varargin)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appUtil.jsBackDoorHTMLSource(),                              ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt, varargin{:}), ...
                                                  "Visible",              "off");
        end

        %-------------------------------------------------------------------------%
        function jsBackDoor_Customizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false, false];
            end

            switch tabIndex
                case 0 % STARTUP
                    if app.isDocked
                        app.progressDialog = app.mainApp.progressDialog;
                    else
                        sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                        app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);                        
                    end
                    customizationStatus = [false, false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    appName = class(app);

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1
                            % Grid botões "dock":
                            if app.isDocked
                                elToModify = {app.DockModuleGroup};
                                elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                                if ~isempty(elDataTag)
                                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                        struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('transition', 'opacity 2s ease', 'opacity', '0.5')), ...
                                    });
                                end
                            end

                            % Outros elementos:
                            elToModify = {app.TabGroup, app.AxesToolbar, app.reportFlag, app.emissionInfo};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('border', 'none', 'backgroundColor', 'transparent')), ...
                                    struct('appName', appName, 'dataTag', elDataTag{2}, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                                    struct('appName', appName, 'dataTag', elDataTag{3}, 'generation', 1, 'style', struct('textAlign', 'justify')) ...
                                });

                                ui.TextView.startup(app.jsBackDoor, elToModify{4}, appName);
                            end

                        case 2
                            elToModify = {app.filter_Tree};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {                                                                                     ...
                                    struct('appName', appName, 'dataTag', elDataTag{1}, 'listener', struct('componentName', 'auxApp.winDriveTest.filter_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                                });
                            end
                        
                        case 3
                            elToModify = {app.points_Tree};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {                                                                                     ...
                                    struct('appName', appName, 'dataTag', elDataTag{1}, 'listener', struct('componentName', 'auxApp.winDriveTest.points_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                                });
                            end

                        case 4
                            app.config_chROIColor.Value     = app.General.Plot.ChannelROI.Color;
                            app.config_chROIEdgeAlpha.Value = app.General.Plot.ChannelROI.EdgeAlpha;
                            app.config_chROIFaceAlpha.Value = app.General.Plot.ChannelROI.FaceAlpha;
                            app.config_chPowerColor.Value   = app.UIAxes3.Colormap(end,:);
                    end
            end
        end
    end

    
    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO
        %-----------------------------------------------------------------%
        function startup_timerCreation(app, idxThread, idxEmission)
            app.timerObj = timer("ExecutionMode", "fixedSpacing", ...
                                 "StartDelay",    1.5,            ...
                                 "Period",        .1,             ...
                                 "TimerFcn",      @(~,~)startup_timerFcn(app, idxThread, idxEmission));
            start(app.timerObj)
        end

        %-----------------------------------------------------------------%
        function startup_timerFcn(app, idxThread, idxEmission)
            if ccTools.fcn.UIFigureRenderStatus(app.UIFigure)
                stop(app.timerObj)
                delete(app.timerObj)

                drawnow
                jsBackDoor_Initialization(app, idxThread, idxEmission)
            end
        end

        %-----------------------------------------------------------------%
        function startup_Controller(app, idxThread, idxEmission)
            drawnow
            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)

            app.progressDialog.Visible = 'visible';

            startup_AppProperties(app)
            startup_AxesCreation(app)
            startup_GUIComponents(app, idxThread, idxEmission)
            general_EmissionChanged(app, struct('updateType', 'AppStartup'))            

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.tempBandObj = class.Band('appAnalise:DRIVETEST', app);

            app.General_I.Plot.Waterfall.Fcn = 'image';
            app.General.Plot.Waterfall.Fcn   = 'image';

            if strcmp(app.mainApp.executionMode, 'webApp')
                app.config_Basemap.Value = 'none';
            end
        end

        %-----------------------------------------------------------------%
        function startup_AxesCreation(app)
            hParent     = tiledlayout(app.Document, 24, 16, "Padding", "none", "TileSpacing", "none");

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.config_Basemap.Value,                 ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '', 'PlotMode', 'distortion')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [24, 12];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            
            geolimits(app.UIAxes1, 'auto')
            plot.axes.Colormap(app.UIAxes1, app.config_Colormap.Value)

            if ismember(app.config_Basemap.Value, {'darkwater', 'none'})
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
                                                                    'GridLineStyle', '-.', 'TickDir', 'both', 'Color', 'none', 'UserData', struct('YLimUnit', 'dBm')});
            app.UIAxes4.Layout.Tile = 112;
            app.UIAxes4.Layout.TileSpan = [18, 1];
            app.UIAxes4.View = [270, 90];
            app.UIAxes4.YAxis.Direction = "reverse";

            % Legenda
            % lgd = legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 1, 'LineWidth', .5, 'FontSize', 7.5, 'PickableParts', 'none');
            % lgd.Title.FontSize = 8.5;

            % Colorbar
            colorBar = colorbar(app.UIAxes1, "Location", "layout", "TickDirection", "none", "PickableParts", "none", "FontSize", 7, "Color", "white", 'AxisLocation', 'in', 'Box', 'off');
            colorBar.Layout.Tile = 284;
            colorBar.Layout.TileSpan = [6,1];

            % Interações:
            linkaxes([app.UIAxes2, app.UIAxes3], 'x')
            plot.axes.Interactivity.DefaultCreation(app.UIAxes1, [dataTipInteraction, zoomInteraction, panInteraction])
            plot.axes.Interactivity.DefaultCreation([app.UIAxes2, app.UIAxes4], dataTipInteraction)
            plot.axes.Interactivity.DataCursorMode(app.UIAxes3, true)
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app, idxThread, idxEmission)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            % Controle do modo de edição:
            app.spectralThreadEdit.UserData = false;
            app.channelEditMode.UserData    = false;

            % Lista as emissões:
            layout_ThreadTreeBuilding(app, idxThread, idxEmission)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % LAYOUT
        %-----------------------------------------------------------------%
        function layout_ThreadTreeBuilding(app, idxThread, idxEmission)
            if ~isempty(app.spectralThreadTree.Children)
                delete(app.spectralThreadTree.Children)
            end

            app.spectralThread.Text = sprintf('%s\n%.3f - %.3f MHz', app.specData(idxThread).Receiver,                 ...
                                                                     app.specData(idxThread).MetaData.FreqStart / 1e6, ...
                                                                     app.specData(idxThread).MetaData.FreqStop  / 1e6);

            % Cria árvore:
            receiverRawList = {app.specData.Receiver};
            [receiverList, ~, receiverIndex] = unique(receiverRawList);

            for ii = 1:numel(receiverList)
                idx1 = find(receiverIndex == ii)';

                receiverNode = uitreenode(app.spectralThreadTree, 'Text',  util.layoutTreeNodeText(receiverList{ii}, 'play_TreeBuilding'), ...
                                                                  'NodeData', idx1, 'Icon', util.layoutTreeNodeIcon(receiverList{ii}), 'Tag', 'RECEIVER');
                                
                for jj = idx1
                    uitreenode(receiverNode, 'Text', sprintf('%.3f - %.3f MHz', app.specData(jj).MetaData.FreqStart / 1e6, ...
                                                                                app.specData(jj).MetaData.FreqStop  / 1e6), ...
                                             'NodeData', jj, 'Tag', 'BAND');
                end
            end

            % Expande árvore:
            expand(app.spectralThreadTree, 'all')

            % Ajusta seleção programaticamente e aplica estilo:
            layout_changingSpectralThreadTreeStyle(app, idxThread)

            % Cria lista de emissões:
            layout_EmissionListCreation(app, idxThread, idxEmission)
        end

        %-----------------------------------------------------------------%
        function layout_changingSpectralThreadTreeStyle(app, idxThread)
            removeStyle(app.spectralThreadTree)

            nodeTreeList      = findobj(app.spectralThreadTree, 'Tag', 'BAND');
            [~, idxSelection] = ismember(idxThread, [nodeTreeList.NodeData]);

            if idxSelection
                app.spectralThreadTree.SelectedNodes = nodeTreeList(idxSelection);
                addStyle(app.spectralThreadTree, uistyle('FontColor', [0,0,0]), 'node', [nodeTreeList(idxSelection); nodeTreeList(idxSelection).Parent])

                expand(nodeTreeList(idxSelection))
                scroll(app.spectralThreadTree, nodeTreeList(idxSelection))
            end
        end

        %-----------------------------------------------------------------%
        function layout_EmissionListCreation(app, idxThread, idxEmission)
            emissionsTable = app.specData(idxThread).UserData.Emissions;

            % Cria lista de emissões:
            app.emissionList.Items = {};
            for kk = 0:height(emissionsTable)
                additionalNote = '';
    
                if kk == 0
                    FreqCenter     = (app.specData(idxThread).MetaData.FreqStart + app.specData(idxThread).MetaData.FreqStop) / 2e6; % MHz
                    BW_kHz         = (app.specData(idxThread).MetaData.FreqStop - app.specData(idxThread).MetaData.FreqStart) / 1e3; % kHz
                    additionalNote = ' (Emissão virtual)';
                else
                    FreqCenter     = emissionsTable.Frequency(kk); % MHz
                    BW_kHz         = emissionsTable.BW_kHz(kk);    % kHz
                    if ~isempty(emissionsTable.auxAppData(kk).DriveTest)
                        additionalNote = ' (DT)';
                    end
                end

                app.emissionList.Items{end+1} = sprintf('%d: %.3f MHz ⌂ %.1f kHz%s', kk, FreqCenter, BW_kHz, additionalNote);
            end

            % Ajusta seleção programaticamente:
            if ~isempty(idxEmission)
                app.emissionList.Value = app.emissionList.Items{idxEmission+1};
            elseif numel(app.emissionList.Items) > 1
                app.emissionList.Value = app.emissionList.Items{2};
            end
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
                    app.Tab1Grid.RowHeight{3} = '1x';
                    app.spectralThreadEditGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.spectralThreadEditConfirm.Enable = 1;
                    app.spectralThreadEditCancel.Enable  = 1;

                case 'off'
                    set(app.spectralThreadEdit, 'ImageSource', 'Edit_32.png',       'Tooltip', 'Habilita edição do fluxo espectral',   'UserData', false)
                    app.Tab1Grid.RowHeight{3} = 0;
                    app.spectralThreadEditGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.spectralThreadEditConfirm.Enable = 0;
                    app.spectralThreadEditCancel.Enable  = 0;

                    idxThread         = specDataIndex(app, 'ThreadSelectionChanged');
                    nodeTreeList      = findobj(app.spectralThreadTree, 'Tag', 'BAND');
                    [~, idxSelection] = ismember(idxThread, [nodeTreeList.NodeData]);
        
                    if idxSelection
                        app.spectralThreadTree.SelectedNodes = nodeTreeList(idxSelection);
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
                    set(app.channelEditMode, 'ImageSource', 'Edit_32Filled.png', 'Tooltip', 'Desabilita edição do canal', 'UserData', true)
                    app.channelEditGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.channelEditConfirm.Enable = 1;
                    app.channelEditCancel.Enable  = 1;
                    app.channelFrequency.Editable = 1;
                    app.channelBandWidth.Editable = 1;

                case 'off'
                    set(app.channelEditMode, 'ImageSource', 'Edit_32.png',       'Tooltip', 'Habilita edição do canal',   'UserData', false)
                    app.channelEditGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.channelEditConfirm.Enable = 0;
                    app.channelEditCancel.Enable  = 0;
                    app.channelFrequency.Editable = 0;
                    app.channelBandWidth.Editable = 0;

                    [idxThread, idxEmission]      = specDataIndex(app, 'ChannelDefault');
                    app.channelFrequency.Value    = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified.Frequency;
                    app.channelBandWidth.Value    = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified.ChannelBW;
            end
        end

        %-----------------------------------------------------------------%
        function checkChannelAssigned(app, idxThread, idxEmission)            
            if isempty(idxEmission)
                chAssigned = util.emissionChannel(app.specData, idxThread, idxEmission, app.mainApp.channelObj);
                app.channelRefresh.Visible = 0;

            else
                chAssigned = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified;
                
                if isequal(app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, ...
                           app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                    app.channelRefresh.Visible = 0;
                else
                    app.channelRefresh.Visible = 1;
                end
            end

            app.channelGrid.UserData   = chAssigned;
            app.channelFrequency.Value = chAssigned.Frequency;
            app.channelBandWidth.Value = chAssigned.ChannelBW;

            checkFixedScreenSpanLimits(app)
        end

        %-----------------------------------------------------------------%
        function dataSource = checkDataSource(app)
            switch app.axesTool_DropDown.Value
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
                    chBW        = app.channelBandWidth.Value; % kHz
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

            chFrequency = app.channelFrequency.Value; % MHz
            chBW        = app.channelBandWidth.Value / 1000; % kHz >> MHz
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
                    if app.reportFlag.Value
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest = createPlotParameters(app);
                    else
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest = [];
                    end

                case 'DriveTest:JustTables'
                    if ~isempty(app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest)
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specRawTable      = app.specRawTable;
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specFilteredTable = app.specFilteredTable;
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specBinTable      = app.specBinTable;
                    end

                case 'DriveTest:JustPoints'
                    if ~isempty(app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest)
                        app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.pointsTable = app.pointsTable;
                    end
                
                case 'ChannelParameterChanged'
                    chAssigned = struct('Frequency', app.channelFrequency.Value, ...
                                        'ChannelBW', app.channelBandWidth.Value);
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
                        chAssigned = struct('Frequency', app.channelFrequency.Value, ...
                                            'ChannelBW', app.channelBandWidth.Value);
                        [app.specRawTable, ...
                         app.UIAxes4.UserData.YLimUnit] = RF.DataBinning.RawTableCreation(app.specData, idxThread, chAssigned);

                    case 'specRawTable+specFilteredTable+specBinTable'
                        % E, posteriormente, criam-se as outras tabelas - specFilteredTable e
                        % specBinTable. A coluna "Filtered" é acrescida à tabela specRawTable.
                        [app.specRawTable,      ...
                         app.specFilteredTable, ...
                         app.specBinTable,      ...
                         app.filterTable,       ...
                         app.tool_FilterSummary.UserData] = RF.DataBinning.execute(app.specRawTable,                   ...
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
                                'specRawTable',          app.specRawTable,                   ...
                                'specFilteredTable',     app.specFilteredTable,              ...
                                'specBinTable',          app.specBinTable,                   ...
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

            try
                if isempty(app.UIAxes1.Legend)
                    lgd = legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 1, 'LineWidth', .5, 'FontSize', 7.5, 'PickableParts', 'none');
                    lgd.Title.FontSize = 8.5;
                end
                app.UIAxes1.Legend.Title.String = sprintf('%.3f MHz ⌂ %.1f kHz', app.channelFrequency.Value, app.channelBandWidth.Value);

                % Afere as tabelas que suportarão os plots e aplica os valores 
                % dos parâmetros, customizando o plot, caso aplicável. 
                prePlot_updateTables(app, idxThread, idxEmission, operationType)

                % Leitura de propriedades customizadas, caso habilitado o
                % flag do relatório.
                prePlot_customProperties(app, idxThread, idxEmission, operationType)
    
                % O objeto app.tempBandObj armazena propriedades de app.specData(idxThreads) 
                % que simplifica o processo do plot, em especial na passagem de 
                % argumentos para as funções plot.draw2D, plot.Waterfall e plot.Persitance.
                GuardBand  = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', getFrequencyScreenSpanInMHz(app, 'Screen')));
                axesLimits = update(app.tempBandObj, idxThread, GuardBand, idxEmission);

                prePlot_restartProperties(app, axesLimits, operationType)
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
                    appUtil.modalWindow(app.UIFigure, 'error', ME.message);
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
            
            % Neste ponto, não deve ser validado o app.reportFlag.Value 
            % porque, no caso de mudança de emissão, o app.reportFlag.Value 
            % se referirá ao flag do relatório da emissão anteriormente selecionada.
            if updateFlag
                updateCustomProperty(app, idxThread, idxEmission, 'DriveTest:JustTables')
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_customProperties(app, idxThread, idxEmission, operationType)
            % Customiza-se o plot, caso o flag do relatório estiver desativado...
            if ~isempty(idxEmission) && ~isempty(app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest)
                app.reportFlag.Value = 1;

                % Essa "gambi" evita que os ROIs dos filtros sejam redesenhados...
                if ismember(operationType, {'AddEditOrDeleteFilter'})
                    return
                end

                % Source
                switch app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.Source
                    case {'Raw', 'Filtered'}
                        app.axesTool_DropDown.Value     = 'Dados brutos';
                        app.axesTool_DensityPlot.Enable = 0;
                    case 'Data-Binning'
                        app.axesTool_DropDown.Value     = 'Dados processados';
                        app.axesTool_DensityPlot.Enable = 1;
                end

                % specRawTable, specFilteredTable e specBinTable
                app.specRawTable                   = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specRawTable;
                app.specFilteredTable              = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specFilteredTable;
                app.specBinTable                   = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.specBinTable;

                % filterTable
                app.filterTable                    = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.filterTable;
                filter_TreeBuilding(app)
                plot_FiltersController(app)

                % pointsTable
                app.pointsTable                    = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.pointsTable;
                points_TreeBuilding(app)
                plot_PointsController(app)

                % potType e plotSize
                app.UIAxes1.UserData.PlotMode      = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.plotType;
                app.axesTool_PlotSize.Value        = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.plotSize;

                % binningValue e binningFcn
                app.filter_DataBinningLength.Value = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.binning_Value;
                app.filter_DataBinningFcn.Value    = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.binning_Fcn;

                % route...                
                app.config_route_LineStyle.Value   = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.route_LineStyle;
                app.config_route_OutColor.Value    = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.route_OutColor;
                app.config_route_InColor.Value     = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.route_InColor;
                app.config_route_Size.Value        = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.route_MarkerSize;

                % Colormap
                if ~strcmp(app.UIAxes1.UserData.Colormap, app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.Colormap)
                    app.config_Colormap.Value      = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.Colormap;
                    plot.axes.Colormap(app.UIAxes1, app.config_Colormap.Value)
                end

                % points...                
                app.config_points_LineStyle.Value  = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.points_Marker;
                app.config_points_Color.Value      = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.points_Color;
                app.config_points_Size.Value       = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.points_Size;

                % Basemap
                if ~strcmp(app.UIAxes1.Basemap, app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.Basemap)
                    app.config_Basemap.Value       = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.Basemap;
                    app.UIAxes1.Basemap            = app.specData(idxThread).UserData.Emissions.auxAppData(idxEmission).DriveTest.Basemap;
                end

            else
                app.reportFlag.Value = 0;
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_restartProperties(app, axesLimits, operationType)
            switch operationType
                case {'AppStartup', 'RefreshPlotParameters', 'ThreadSelectionChanged'}
                    % TRIGGER: Inicialização do app, e retorno às configurações 
                    %          iniciais dos parâmetros, no modo CONFIG.
                    % EFEITO : Desenha todas as curvas - "Route", "Car", "Distortion", 
                    %          "Density", "ClearWrite", "Persistance", "ChannelROI"
                    %          "Waterfall", "ChannelPower" etc.
                    delete(findobj([app.UIAxes1.Children; app.UIAxes4.Children], '-not', {'Tag', 'FilterROI', '-or', 'Tag', 'Points'}))
                    cla([app.UIAxes2, app.UIAxes3])

                    app.hCar = [];
                    app.hClearWrite = [];
                    app.hTimeline = [];

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
            app.General.Plot.Waterfall.LevelLimits = [0, 0];

            app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yLevelLim, 'cLim', 'auto');          % Eixo cartesiano (Espectro)
            app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', axesLimits.xLim, 'yLim', [],                   'cLim', axesLimits.cLim); % Eixo cartesiano (Waterfall)
            app.restoreView(4) = struct('ID', 'app.UIAxes4', 'xLim', [],              'yLim', [],                   'cLim', 'auto');          % Eixo cartesiano (Potência do canal)
        end

        %-----------------------------------------------------------------%
        function plot_CreatePlot(app, idxThread, operationType)
            % prePLOT
            chFrequency = app.channelFrequency.Value;
            
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
                    app.hClearWrite = plot.draw2D.OrdinaryLine(app.UIAxes2, app.tempBandObj, idxThread, 'ClearWrite');
                    plot.datatip.Template(app.hClearWrite, "Frequency+Level", app.tempBandObj.LevelUnit)
                    plot.Persistance('Creation', [], app.UIAxes2, app.tempBandObj, idxThread);
    
                    % (c) Waterfall+Timeline
                    plot.Waterfall('Creation', app.UIAxes3, app.tempBandObj, idxThread);
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

            plot.axes.StackingOrder.execute(app.UIAxes1, app.tempBandObj.Context)
            plot.axes.StackingOrder.execute(app.UIAxes2, app.tempBandObj.Context)
            plot.axes.StackingOrder.execute(app.UIAxes3, app.tempBandObj.Context)
            plot.axes.StackingOrder.execute(app.UIAxes4, app.tempBandObj.Context)

            drawnow
        end

        %-----------------------------------------------------------------%
        function plot_PlaybackLoop(app, idxThread, nSweeps)
            app.tool_Play.ImageSource = 'stop_32.png';

            while app.idxTime <= nSweeps
                switch app.plotFlag
                    case -1 % alteração de fluxo espectral
                        [idxThread, nSweeps] = plot_RecreatePlot(app);
                    case  0 % finalização do plot
                        break
                end

                sweepTic = tic;                
                plot_UpdatePlot(app, idxThread, nSweeps)
                app.tool_TimestampSlider.Value = 100 * app.idxTime/nSweeps;

                % O pause a seguir assegura que exista responsividade no
                % app...
                pause(max(app.mainApp.play_MinPlotTime.Value/1000-toc(sweepTic), .001))

                if app.idxTime == nSweeps
                    if strcmp(app.tool_LoopControl.Tag, 'direct')
                        break
                    end
                    app.idxTime = 1;
                else
                    app.idxTime = app.idxTime+1;
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
            app.plotFlag = 1;
        end

        %-----------------------------------------------------------------%
        function plot_UpdatePlot(app, idxThread, nSweeps)
            plot.draw2D.OrdinaryLineUpdate(app.hClearWrite, app.tempBandObj, idxThread, 'ClearWrite')
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
            OutTable  = app.specRawTable(~app.specRawTable.Filtered,:);
            InTable   = app.specFilteredTable;

            LineStyle = app.config_route_LineStyle.Value;
            OutColor  = app.config_route_OutColor.Value;
            InColor   = app.config_route_InColor.Value;
            MarkerSize= app.config_route_Size.Value;

            plot.DriveTest.Route(hAxes, app.tempBandObj, OutTable, InTable, LineStyle, OutColor, InColor, MarkerSize)
        end

        %-----------------------------------------------------------------%
        function plot_DistortionAndDensityPlot(app)
            hAxes    = app.UIAxes1;
            Source   = checkDataSource(app);
            plotMode = app.UIAxes1.UserData.PlotMode;
            plotSize = app.axesTool_PlotSize.Value;

            switch Source
                case {'Raw', 'Filtered'}
                    srcTable = app.specFilteredTable;
                case 'Data-Binning'
                    srcTable = app.specBinTable;
            end

            plot.DriveTest.DistortionAndDensityPlot(hAxes, app.tempBandObj, srcTable, plotMode, plotSize)
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
                    app.hCar = geoscatter(app.UIAxes1, app.specRawTable.Latitude(app.idxTime), app.specRawTable.Longitude(app.idxTime), 'filled',              ...
                                          'Marker', app.config_Car_LineStyle.Value, 'MarkerFaceColor', app.config_Car_Color.Value, 'MarkerEdgeColor', 'black', ...
                                          'SizeData', 10*app.config_Car_Size.Value, 'PickableParts', 'none', 'DisplayName', 'Veículo', 'Tag', 'Car');

                case 'Update'
                    set(app.hCar, 'LatitudeData', app.specRawTable.Latitude(app.idxTime), ...
                                  'LongitudeData', app.specRawTable.Longitude(app.idxTime))
            end
        end

        %-----------------------------------------------------------------%
        function plot_Timeline(app, operationType, varargin)
            switch operationType
                case 'Creation'
                    app.hTimeline = line(app.UIAxes3, getFrequencyScreenSpanInMHz(app, 'ScreenMaxLimits'), [app.idxTime, app.idxTime], ...
                                         'Color', 'red', 'Tag', 'Timeline');                
                case 'Relocate'
                    app.hTimeline.XData = getFrequencyScreenSpanInMHz(app, 'ScreenMaxLimits');
                    return
                case 'Update'
                    app.hTimeline.YData = [app.idxTime, app.idxTime];
            end

            idxThread = varargin{1};
            nSweeps   = varargin{2};
            app.tool_TimestampLabel.Text = sprintf('%d de %d\n%s', app.idxTime, ...
                                                                   nSweeps,     ...
                                                                   app.specData(idxThread).Data{1}(app.idxTime));
        end

        %-----------------------------------------------------------------%
        function plot_ChannelPower(app)
            hAxes     = app.UIAxes4;
            Color     = app.UIAxes3.Colormap(end,:);
            EdgeAlpha = app.config_chPowerEdgeAlpha.Value;
            FaceAlpha = app.config_chPowerFaceAlpha.Value;
            app.config_chPowerColor.Value = Color;

            plot.DriveTest.ChannelPower(hAxes, app.tempBandObj, app.specRawTable, Color, EdgeAlpha, FaceAlpha)
        end

        %-----------------------------------------------------------------%
        function plot_ChannelROI(app, operationType)
            chFrequency = app.channelFrequency.Value;
            chBW        = app.channelBandWidth.Value;

            switch operationType
                case 'Creation'
                    srcROITable = table(chFrequency, chBW, 'VariableNames', {'Frequency', 'BW_kHz'});
                    plot.draw2D.rectangularROI(app.UIAxes2, app.tempBandObj, srcROITable, 1, 'ChannelROI', {'InteractionsAllowed', 'none'}, [-1000, 1000])
                    plot.draw2D.rectangularROI(app.UIAxes3, app.tempBandObj, srcROITable, 1, 'ChannelROI', {'InteractionsAllowed', 'none'})

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
            if ~isempty(app.filter_Tree.Children)
                delete(app.filter_Tree.Children)
            end

            if ~isempty(app.filterTable)
                for ii = 1:height(app.filterTable)
                    nodeText = sprintf('%s:%s', app.filterTable.type{ii}, app.filterTable.subtype{ii});
                    uitreenode(app.filter_Tree, 'Text', nodeText, 'NodeData', ii, 'ContextMenu', app.ContextMenu2);
                end

                set(app.filter_Tree, 'SelectedNodes', app.filter_Tree.Children(end), 'Enable', 1)
                filter_TreeSelectionChanged(app)

                set(app.ContextMenu2.Children, Enable=1)
            else
                app.filter_Tree.Enable = 1;
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
            if ~isempty(app.points_Tree.Children)
                delete(app.points_Tree.Children)
            end

            checkedTreeNodes = [];
            for ii = 1:height(app.pointsTable)
                nodeText = sprintf('%s: %s', app.pointsTable.type{ii}, strjoin("#" + string(app.pointsTable.value(ii).idxData), ', '));
                treeNode = uitreenode(app.points_Tree, 'Text',        nodeText, ...
                                                       'NodeData',    ii,       ...
                                                       'ContextMenu', app.ContextMenu1);
                if app.pointsTable.visible(ii)
                    checkedTreeNodes = [checkedTreeNodes, treeNode];
                end
            end
            app.points_Tree.CheckedNodes = checkedTreeNodes;

            if app.reportFlag.Value
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
                    sourceData = app.specRawTable.ChannelPower;
                case 'Dados processados (Data Binning)'
                    sourceData = app.specBinTable.ChannelPower;
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
                            refCoordinates = app.specRawTable{idxPeak,            {'Latitude', 'Longitude'}};
                            Coordinates    = app.specRawTable{idxListOfPeaks(ii), {'Latitude', 'Longitude'}};    
                        
                        case 'Dados processados (Data Binning)'
                            refCoordinates = app.specBinTable{idxPeak,                 {'Latitude', 'Longitude'}};
                            Coordinates    = app.specBinTable{idxListOfPeaks(ii),      {'Latitude', 'Longitude'}};
                    end
    
                    tempDistance = deg2km(distance(refCoordinates, Coordinates(end,:))); % em km
                    if all(tempDistance >= MinDistance)
                        idxPeak(end+1) = idxListOfPeaks(ii);
                    end
                end

                switch Source
                    case 'Dados brutos'
                        Coordinates = app.specRawTable{idxPeak, {'Latitude', 'Longitude'}};
                    case 'Dados processados (Data Binning)'
                        Coordinates = app.specBinTable{idxPeak,      {'Latitude', 'Longitude'}};
                end
            end
        end
    end


    methods
        %-----------------------------------------------------------------%
        % ÍNDICES DO FLUXO ESPECTRAL E DA EMISSÃO
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
            threadUUID  = app.selectedEmission.Thread.UUID;
            listOfAllThreadsUUID = arrayfun(@(x) x.RelatedFiles.uuid, app.specData, 'UniformOutput', false);
            
            idxThread   = find(cellfun(@(x) isequal(x, threadUUID), listOfAllThreadsUUID), 1);
            idxEmission = [];

            % Caso seja identificado o fluxo espectral, busca a emissão 
            % sob análise na lista de emissões.
            if ~isempty(idxThread)
                switch operationType
                    case 'EmissionSelectionChanged'
                        newEmissionTag = app.emissionList.Value;
                        emissionTable  = app.specData(idxThread).UserData.Emissions;

                        for ii = 1:height(emissionTable)
                            if strcmp(newEmissionTag, sprintf('%.3f MHz ⌂ %.1f kHz', emissionTable.Frequency(ii), emissionTable.BW_kHz(ii)))
                                idxEmission = ii;
                                break
                            end
                        end

                    otherwise
                        emissionFrequency = app.selectedEmission.Emission.Frequency;
                        emissionBW        = app.selectedEmission.Emission.BW_kHz;
        
                        idxEmission = find(abs(app.specData(idxThread).UserData.Emissions.Frequency - emissionFrequency) <= class.Constants.floatDiffTolerance & ...
                                           abs(app.specData(idxThread).UserData.Emissions.BW_kHz    - emissionBW)        <= class.Constants.floatDiffTolerance, 1);
                end
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, idxThread, idxEmission)

            app.mainApp    = mainApp;
            app.General    = mainApp.General;
            app.General_I  = mainApp.General_I;
            app.specData   = mainApp.specData;

            if app.isDocked
                app.GridLayout.Padding(4) = 30;
                app.DockModuleGroup.Visible = 1;
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app, idxThread, idxEmission)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app, idxThread, idxEmission)
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn')
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function DockModuleGroup_ButtonPushed(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;
                    
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.TabGroup.SelectedTab, app.TabGroup.Children);
            jsBackDoor_Customizations(app, tabIndex)

        end

        % Image clicked function: tool_ControlPanelVisibility
        function Toolbar_LeftPanelVisibilityImageClicked(app, event)

            switch event.Source
                case app.tool_ControlPanelVisibility
                    if app.GridLayout.ColumnWidth{2}
                        app.tool_ControlPanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.GridLayout.ColumnWidth(2:3) = {0,0};
                    else
                        app.tool_ControlPanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.GridLayout.ColumnWidth(2:3) = {320,10};
                    end
            end

        end

        % Image clicked function: tool_LoopControl, tool_Play
        function Toolbar_PlaybackControlImageClicked(app, event)
            
            switch event.Source
                case app.tool_Play
                    idxThread   = app.selectedEmission.Thread.Index;
        
                    if idxThread && ~app.plotFlag
                        if app.mainApp.plotFlag
                            app.mainApp.plotFlag = 0;
                            app.mainApp.tool_Play.ImageSource = 'play_32.png';
                            drawnow
                        end

                        app.plotFlag = 1;

                        % O bloco try/catch evita erros decorrentes da finalização 
                        % do playback porque a lista de emissão do fluxo espectral 
                        % sob análise está vazia, decorrente de edição no appAnalise.
                        try
                            plot_PlaybackLoop(app, idxThread, numel(app.specData(idxThread).Data{1}))
                        catch
                        end

                    else
                        app.plotFlag = 0;
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
            
            idxThread = app.selectedEmission.Thread.Index;
            nSweeps   = app.tempBandObj.nSweeps;
            
            app.idxTime = round(event.Value/100 * nSweeps);
            if app.idxTime < 1
                app.idxTime = 1;
            elseif app.idxTime > nSweeps
                app.idxTime = nSweeps;
            end

            if ~app.plotFlag
                plot_UpdatePlot(app, idxThread, nSweeps)
            end

        end

        % Image clicked function: tool_DataBinningExport
        function Toolbar_ExportFileButtonPushed(app, event)
            
            nameFormatMap = {'*.zip', 'appAnalise (*.zip)'};
            Basename      = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'DriveTest', app.mainApp.report_Issue.Value);
            fileFullPath  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, Basename);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            dataSource = checkDataSource(app);
            hPlot      = findobj(app.UIAxes1.Children, 'Tag', 'Distortion');
            channelTag = sprintf('%.3f MHz ⌂ %.1f kHz', app.channelFrequency.Value, app.channelBandWidth.Value);

            try
                msgWarning = util.exportDriveTestAnalysis(app.specRawTable, app.specFilteredTable, app.specBinTable, Basename, fileFullPath, dataSource, hPlot, channelTag);
                appUtil.modalWindow(app.UIFigure, 'info', msgWarning);
            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_FilterSummary
        function Toolbar_SummaryImageClicked(app, event)
            
            appUtil.modalWindow(app.UIFigure, 'info', app.tool_FilterSummary.UserData);

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

        % Value changed function: axesTool_DropDown, 
        % ...and 2 other components
        function AxesToolbar_DataSourceChanged(app, event)

            [idxThread, idxEmission] = specDataIndex(app);

            switch event.Source
                case app.axesTool_DropDown
                    operationType = 'PlotDataSourceChanged';
            
                    switch app.axesTool_DropDown.Value
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
                    if app.axesTool_DropDown.Value == "Dados brutos"
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

        % Image clicked function: spectralThreadEdit, 
        % ...and 2 other components
        function general_ThreadChanged(app, event)
            
            switch event.Source
                case app.spectralThreadEdit
                    app.spectralThreadEdit.UserData = ~app.spectralThreadEdit.UserData;
                    
                    if app.spectralThreadEdit.UserData
                        layout_editSpectralThread(app, 'on')
                    else
                        general_ThreadChanged(app, struct('Source', app.spectralThreadEditCancel))
                    end

                case app.spectralThreadEditConfirm
                    idxSelectedThread = app.spectralThreadTree.SelectedNodes.NodeData;
        
                    if (~isempty(app.selectedEmission) && isequal(idxSelectedThread, app.selectedEmission.Thread.Index)) || ~isscalar(idxSelectedThread)
                        layout_editSpectralThread(app, 'off')
                        return
                    end

                    % Se o fluxo espectral relacionado está relacionado a
                    % outra coleta, em outro local, os filtros de nível e
                    % geográficos são apagados...
                    if ~isequal(app.specData(idxSelectedThread).GPS, app.specData(app.selectedEmission.Thread.Index).GPS)
                        app.filterTable(:,:) = [];
                        filter_TreeBuilding(app)
                        delete(findobj([app.UIAxes1.Children; app.UIAxes4.Children], 'Tag', 'FilterROI'))
                    end

                    layout_ThreadTreeBuilding(app, idxSelectedThread, [])
                    general_EmissionChanged(app, struct('updateType', 'ThreadSelectionChanged'))

                    layout_editSpectralThread(app, 'off')

                case app.spectralThreadEditCancel
                    layout_editSpectralThread(app, 'off')
            end

        end

        % Value changed function: emissionList
        function general_EmissionChanged(app, event)
            
            idxThread   = app.spectralThreadTree.SelectedNodes.NodeData;
            idxEmission = find(strcmp(app.emissionList.Items, app.emissionList.Value), 1) - 1;
            if ~idxEmission
                idxEmission = [];
            end

            if ~isempty(app.selectedEmission) && isequal(idxThread, app.selectedEmission.Thread.Index) && isequal(idxEmission, app.selectedEmission.Emission.Index)
                return
            end

            % Inicialmente, a informação acerca do fluxo espectral e da emissão 
            % sob análise são salvas na propriedade "selectedEmission" do app.
            [htmlContent, app.selectedEmission] = util.HtmlTextGenerator.Emission_v2(app.specData, idxThread, idxEmission);
            ui.TextView.update(app.emissionInfo, htmlContent);

            % Atualiza canal, bloqueando edição de informação do canal.
            checkChannelAssigned(app, idxThread, idxEmission)
            if app.channelEditMode.UserData
                general_chEditImageClicked(app)
            end

            if ~isempty(idxEmission) && ~isequal(app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, ...
                                                 app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                app.channelRefresh.Visible = 1;
            else
                app.channelRefresh.Visible = 0;
            end

            % Verifica se os limites do plot estão adequados ao tipo de emissão (a
            % emissão virtual, que corresponde à toda faixa espectral tem particularidades).
            if ~isempty(idxEmission)
                if ~app.config_BandGuardType.Enable
                    % Essa situação só ocorre quando estava selecionado uma
                    % emissão virtual e agora foi selecionada uma emissão real.
                    % Por isso, os valores estavam configurados em "BWRelated" e 1.
                    app.reportFlag.Enable = 1;
                    app.channelEditMode.Enable = 1;

                    app.config_BandGuardType.Enable = 1;
                    set(app.config_BandGuardBWRelatedValue, 'Enable', 1, 'Value', 6)
                    config_BandGuardValueChanged(app, struct('Source', app.config_BandGuardBWRelatedValue))
                end
            else
                if app.config_BandGuardType.Enable
                    % Essa situação só ocorre quando estava selecionado uma
                    % emissão real e agora foi selecionada uma emissão virtual.
                    set(app.reportFlag, 'Enable', 0, 'Value', 0)                    
                    app.channelEditMode.Enable = 0;

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

        % Image clicked function: channelEditCancel, channelEditConfirm, 
        % ...and 2 other components
        function general_ChannelChanged(app, event)
            
            switch event.Source
                case {app.channelRefresh, app.channelEditConfirm}
                    switch event.Source
                        case app.channelRefresh
                            operationType = 'ChannelDefault';
                            [idxThread, idxEmission] = specDataIndex(app, operationType);
                            updateCustomProperty(app, idxThread, idxEmission, operationType)        
                            checkChannelAssigned(app, idxThread, idxEmission)
                        otherwise
                            operationType = 'ChannelParameterChanged';
                            [idxThread, idxEmission] = specDataIndex(app, operationType);
                            updateCustomProperty(app, idxThread, idxEmission, operationType)
                            app.channelRefresh.Visible = 1;
                    end

                    layout_editChannelAssigned(app, 'off')

                    if app.plotFlag
                        app.plotFlag = 0;
                        pause(.100)
                    end
        
                    prePlot_Startup(app, idxThread, idxEmission, operationType)

                case app.channelEditMode
                    app.channelEditMode.UserData = ~app.channelEditMode.UserData;
        
                    if app.channelEditMode.UserData
                        layout_editChannelAssigned(app, 'on')
                        focus(app.channelFrequency)        
                    else
                        layout_editChannelAssigned(app, 'off')
                    end

                case app.channelEditCancel
                    layout_editChannelAssigned(app, 'off')
            end

        end

        % Value changed function: reportFlag
        function general_ReportFlagCheckBoxClicked(app, event)

            [idxThread, idxEmission] = specDataIndex(app);
            updateCustomProperty(app, idxThread, idxEmission)
            layout_EmissionListCreation(app, idxThread, idxEmission)

        end

        % Callback function: config_Car_Color, config_points_Color, 
        % ...and 2 other components
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
            app.config_Refresh.Visible = 1;
            
        end

        % Callback function: config_Basemap, config_Car_LineStyle, 
        % ...and 6 other components
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
            app.config_Refresh.Visible = 1;

        end

        % Value changed function: config_PersistanceVisibility, 
        % ...and 8 other components
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

                    app.General.Plot.ChannelROI.Color     = app.config_chROIColor.Value;
                    app.General.Plot.ChannelROI.EdgeAlpha = app.config_chROIEdgeAlpha.Value;
                    app.General.Plot.ChannelROI.FaceAlpha = app.config_chROIFaceAlpha.Value;

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
            app.config_Refresh.Visible = 1;
            
        end

        % Value changed function: config_BandGuardBWRelatedValue, 
        % ...and 2 other components
        function config_BandGuardValueChanged(app, event)

            chBW = app.channelBandWidth.Value;

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

            app.config_Refresh.Visible = 1;

        end

        % Image clicked function: config_Refresh
        function config_RefreshImageClicked(app, event)
            
            % Trava função do Waterfall em "image" para que seja possível
            % sincronizar os eixos app.UIAxes3.YAxes e app.UIAxes4.XAxis.
            app.General = app.mainApp.General;
            app.General.Plot.Waterfall.Fcn           = 'image';

            % % Eixo geográfico - app.UIAxes1
            app.config_Colormap.Value                = 'turbo';            
            app.config_route_LineStyle.Value         = ':';
            app.config_route_Size.Value              = 1;            
            app.config_route_OutColor.Value          = [.5,.5,.5];
            app.config_route_InColor.Value           = [.87,.54,.54];
            app.config_Car_LineStyle.Value           = 'square';
            app.config_Car_Color.Value               = [1,0,0];
            app.config_Car_Size.Value                = 10;            
            app.config_points_LineStyle.Value        = 'none';            
            app.config_points_Color.Value            = [0,0,0];
            app.config_points_Size.Value             = 9;

            % % Eixos cartesianos - app.UIAxes2, app.UIAxes3 e app.UIAxes4
            app.config_PersistanceVisibility.Value   = 'on';
            app.config_chROIVisibility.Value         = 'on';
            app.config_chROIColor.Value              = app.General.Plot.ChannelROI.Color;
            app.config_chROIEdgeAlpha.Value          = 0;
            app.config_chROIFaceAlpha.Value          = .4;
            app.config_chPowerVisibility.Value       = 'on';
            app.config_chPowerColor.Value            = app.UIAxes3.Colormap(end,:);
            app.config_chPowerEdgeAlpha.Value        = 1;
            app.config_chPowerFaceAlpha.Value        = .4;
            
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

            app.config_Refresh.Visible = 0;

        end

        % Selection changed function: filter_RadioGroup
        function filter_RadioGroupSelectionChanged(app, event)
            
            switch app.filter_RadioGroup.SelectedObject
                case app.filter_THR
                    app.Tab2Grid.RowHeight{2} = 96;
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

        % Value changed function: filter_GeographicType
        function filter_GeographicTypeValueChanged(app, event)
            
            switch app.filter_GeographicType.Value
                case 'Arquivo externo KML/KMZ'
                    app.Tab2Grid.RowHeight{2} = 208;

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
                    app.Tab2Grid.RowHeight{2} = 140;

                    app.filter_THR.Position(2)                 = 90;
                    app.filter_Geographic.Position(2)          = 52;
                    app.filter_GeographicTypeLabel.Position(2) = 36;
                    app.filter_GeographicType.Position(2)      = 12;
                    
                    set(findobj(app.filter_RadioGroup.Children, 'Tag', 'KML'), 'Visible', 0)
            end
            
        end

        % Image clicked function: filter_KMLOpenFile
        function filter_KMLOpenFileClicked(app, event)
            
            [~, filePath, ~, fileName] = appUtil.modalWindow(app.UIFigure, 'uigetfile', '', {'*.kml;*.kmz', '(*.kml, *.kmz)'}, app.General.fileFolder.lastVisited);

            if ~isempty(fileName)
                app.progressDialog.Visible = 'visible';

                misc_updateLastVisitedFolder(app.mainApp, filePath)
                app.General.fileFolder.lastVisited = filePath;

                try
                    if ~isempty(app.KMLObj)
                        delete(app.KMLObj)
                    end

                    app.KMLObj = RF.KML(fullfile(filePath, fileName));

                    [~, fileName, fileExt] = fileparts(app.KMLObj.File);
                    app.filter_KMLFilename.Value  = [fileName fileExt];
                    app.filter_KMLFileLayer.Items = app.KMLObj.LayerNames;

                catch ME
                    app.KMLObj = [];
                    app.filter_KMLFilename.Value  = '';
                    app.filter_KMLFileLayer.Items = {};

                    appUtil.modalWindow(app.UIFigure, 'error', ME.message);
                end

                app.progressDialog.Visible = 'hidden';
            end            

        end

        % Image clicked function: filter_AddImage
        function filter_AddFilterImageClicked(app, event)
            
            focus(app.filter_Tree)

            switch app.filter_RadioGroup.SelectedObject
                case app.filter_THR
                    if ismember('Level', app.filterTable.type)
                        msgWarning = ['Já foi incluído o filtro de nível, cujo <i>threshold</i> pode ser ajustado ' ...
                                      'diretamente no eixo que apresenta a potência do canal sob análise.'];
                        appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                        return
                    end

                    FilterType = 'Level';
                    FilterSubtype = 'Threshold';
                    Threshold = min(app.specRawTable.ChannelPower);

                    hROI = plot_FilterROIObject(app, 'DrawInRealTime', FilterSubtype, app.UIAxes4);
                    hROI.Position = [height(app.specFilteredTable) Threshold; 1 Threshold];

                    app.filterTable(end+1,:) = {FilterType, FilterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};

                case app.filter_Geographic
                    FilterType = 'Geographic ROI';

                    switch app.filter_GeographicType.Value
                        case 'Arquivo externo KML/KMZ'
                            if isempty(app.filter_KMLFilename.Value)
                                msgWarning = 'É preciso escolher um arquivo KML/KMZ antes de adicioná-lo como filtro geográfico.';
                                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                                return
                            end
                            
                            FilterSubtype = 'PolygonKML';

                            try
                                readgeotable(app.KMLObj, app.filter_KMLFileLayer.Value)
                                for ii = 1:height(app.KMLObj.GeoTable)
                                    shapeObj = app.KMLObj.GeoTable.Shape(ii);

                                    if isa(shapeObj, 'geopolyshape')
                                        hROI = plot_FilterROIObject(app, 'DrawInRealTime', FilterSubtype, app.UIAxes1, shapeObj);
                                        app.filterTable(end+1,:) = {FilterType, FilterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};
                                    end
                                end

                                if ~exist('hROI', 'var')
                                    error(['A pasta "%s", do arquivo "%s", possui apenas objetos do tipo "%s". Um filtro '  ...
                                           'geográfico, contudo, precisa ser um polígono.'], app.filter_KMLFileLayer.Value, ...
                                                                                             app.KMLObj.File,               ...
                                                                                             textFormatGUI.cellstr2ListWithQuotes(unique(arrayfun(@(x) class(x), app.KMLObj.GeoTable.Shape, "UniformOutput", false))))
                                end

                            catch ME
                                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
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
                    if isempty(app.filter_Tree.SelectedNodes)
                        return
                    end
                    idx = arrayfun(@(x) x.NodeData, app.filter_Tree.SelectedNodes);

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

        % Selection changed function: filter_Tree
        function filter_TreeSelectionChanged(app, event)
            
            if ~isempty(app.filter_Tree.SelectedNodes) && all(isvalid([app.filterTable.roi.handle]))
                idxFilter = app.filter_Tree.SelectedNodes.NodeData;        
    
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

        % Selection changed function: points_RadioGroup
        function points_RadioGroupSelectionChanged(app, event)
            
            switch app.points_RadioGroup.SelectedObject
                case app.points_AddRFDataHub
                    app.points_AddValueGrid.RowHeight = {17,22,22,22,0,0,0,0};
                case app.points_AddFindPeaks
                    app.points_AddValueGrid.RowHeight = {0,0,0,0,17,22,22,22};
            end
            
        end

        % Image clicked function: points_AddImage
        function points_AddPointImageClicked(app, event)
            
            focus(app.points_Tree)

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
                                    appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                                    return
                                end
                                idxRawPoints = str2double([idxRawPoints{:}]);
            
                            case 'Lista de frequências (MHz)'
                                freqList = regexp(entryText, '(\d+.\d+)', 'tokens');
                                if isempty(freqList)
                                    msgWarning = 'Valor inválido! Deve ser inserida lista de frequências em MHz. Por exemplos: 101.1, 101.3, 101.5';
                                    appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
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
                        appUtil.modalWindow(app.UIFigure, 'warning', msgLOG);
    
                    %---------------------------------------------------------%
                    case app.points_AddFindPeaks
                        [idxRawPoints, Coordinates] = points_FindPeaks(app, app.points_Subtype2DropDown.Value, app.points_Subtype2NPeaks.Value, app.points_Subtype2Distance.Value/1000);
                        newRow = {'FindPeaks',                                                                                       ...
                                  struct('Source', app.points_Subtype2DropDown.Value, 'idxData', idxRawPoints, 'Data', Coordinates), ...
                                  true};
                        points_AddNewPoint2Table(app, newRow)

                        msgLOG = sprintf('Identificado(s) %d ponto(s) que atende(m) ao critério.', numel(idxRawPoints));
                        appUtil.modalWindow(app.UIFigure, 'warning', msgLOG);
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
                return
            end

            points_TreeBuilding(app)
            plot_PointsController(app)

        end

        % Value changed function: points_Subtype1Value
        function points_Subtype1ValueValueChanged2(app, event)

            app.points_Subtype1Value.Value = strtrim(app.points_Subtype1Value.Value);
            
        end

        % Callback function: points_Tree
        function points_TreeCheckedNodesChanged(app, event)
            
            visibleNodeData   = arrayfun(@(x) x.NodeData, app.points_Tree.CheckedNodes);
            invisibleNodeData = setdiff(1:height(app.pointsTable), visibleNodeData);

            app.pointsTable.visible(visibleNodeData)   = true;
            app.pointsTable.visible(invisibleNodeData) = false;

            plot_PointsController(app)
            
        end

        % Menu selected function: points_delButton
        function points_delButtonMenuSelected(app, event)
            
            if isempty(app.pointsTable) || isempty(app.points_Tree.SelectedNodes)
                return
            end

            idx = arrayfun(@(x) x.NodeData, app.points_Tree.SelectedNodes);
    
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
            app.GridLayout.ColumnWidth = {10, 320, 10, 5, 366, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, 22, 248, 196, '1x', 22, 22};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [5 5 0 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 9];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_ControlPanelVisibility
            app.tool_ControlPanelVisibility = uiimage(app.Toolbar);
            app.tool_ControlPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_LeftPanelVisibilityImageClicked, true);
            app.tool_ControlPanelVisibility.Layout.Row = 2;
            app.tool_ControlPanelVisibility.Layout.Column = 1;
            app.tool_ControlPanelVisibility.VerticalAlignment = 'bottom';
            app.tool_ControlPanelVisibility.ImageSource = 'ArrowLeft_32.png';

            % Create tool_Play
            app.tool_Play = uiimage(app.Toolbar);
            app.tool_Play.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PlaybackControlImageClicked, true);
            app.tool_Play.Tooltip = {'Playback'};
            app.tool_Play.Layout.Row = 2;
            app.tool_Play.Layout.Column = 2;
            app.tool_Play.ImageSource = 'play_32.png';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PlaybackControlImageClicked, true);
            app.tool_LoopControl.Tag = 'loop';
            app.tool_LoopControl.Tooltip = {'Loop do playback'};
            app.tool_LoopControl.Layout.Row = 2;
            app.tool_LoopControl.Layout.Column = 3;
            app.tool_LoopControl.ImageSource = 'playbackLoop_32Blue.png';

            % Create tool_TimestampSlider
            app.tool_TimestampSlider = uislider(app.Toolbar);
            app.tool_TimestampSlider.MajorTicks = [0 50 100];
            app.tool_TimestampSlider.MajorTickLabels = {''};
            app.tool_TimestampSlider.ValueChangingFcn = createCallbackFcn(app, @Toolbar_TimelineSliderValueChanging, true);
            app.tool_TimestampSlider.MinorTicks = [0 2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30 32.5 35 37.5 40 42.5 45 47.5 50 52.5 55 57.5 60 62.5 65 67.5 70 72.5 75 77.5 80 82.5 85 87.5 90 92.5 95 97.5 100];
            app.tool_TimestampSlider.FontSize = 8;
            app.tool_TimestampSlider.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.tool_TimestampSlider.Layout.Row = 2;
            app.tool_TimestampSlider.Layout.Column = 4;

            % Create tool_TimestampLabel
            app.tool_TimestampLabel = uilabel(app.Toolbar);
            app.tool_TimestampLabel.WordWrap = 'on';
            app.tool_TimestampLabel.FontSize = 10;
            app.tool_TimestampLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.tool_TimestampLabel.Layout.Row = [1 3];
            app.tool_TimestampLabel.Layout.Column = 5;
            app.tool_TimestampLabel.Text = {'0 de 0'; '00/00/0000 00:00:00'};

            % Create tool_DataBinningExport
            app.tool_DataBinningExport = uiimage(app.Toolbar);
            app.tool_DataBinningExport.ScaleMethod = 'none';
            app.tool_DataBinningExport.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ExportFileButtonPushed, true);
            app.tool_DataBinningExport.Tooltip = {'Exporta análise em arquivos XLSX e KML'};
            app.tool_DataBinningExport.Layout.Row = 2;
            app.tool_DataBinningExport.Layout.Column = 7;
            app.tool_DataBinningExport.ImageSource = 'Export_16.png';

            % Create tool_FilterSummary
            app.tool_FilterSummary = uiimage(app.Toolbar);
            app.tool_FilterSummary.ImageClickedFcn = createCallbackFcn(app, @Toolbar_SummaryImageClicked, true);
            app.tool_FilterSummary.Tooltip = {'Informações acerca do processo de análise dos dados'};
            app.tool_FilterSummary.Layout.Row = 2;
            app.tool_FilterSummary.Layout.Column = 8;
            app.tool_FilterSummary.ImageSource = 'Info_32.png';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Layout.Row = [3 4];
            app.TabGroup.Layout.Column = 2;

            % Create Tab1
            app.Tab1 = uitab(app.TabGroup);
            app.Tab1.AutoResizeChildren = 'off';
            app.Tab1.Title = 'DT';
            app.Tab1.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.Tab1.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1);
            app.Tab1Grid.ColumnWidth = {'1x', 88};
            app.Tab1Grid.RowHeight = {22, 44, 0, 22, 22, '1x', 22, 69, 5, 26};
            app.Tab1Grid.ColumnSpacing = 5;
            app.Tab1Grid.RowSpacing = 5;
            app.Tab1Grid.Padding = [10 10 10 5];
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create spectralThreadLabel
            app.spectralThreadLabel = uilabel(app.Tab1Grid);
            app.spectralThreadLabel.VerticalAlignment = 'bottom';
            app.spectralThreadLabel.FontSize = 10;
            app.spectralThreadLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.spectralThreadLabel.Layout.Row = 1;
            app.spectralThreadLabel.Layout.Column = 1;
            app.spectralThreadLabel.Text = 'FLUXO ESPECTRAL';

            % Create spectralThreadEditGrid
            app.spectralThreadEditGrid = uigridlayout(app.Tab1Grid);
            app.spectralThreadEditGrid.ColumnWidth = {'1x', 18, 0, 0};
            app.spectralThreadEditGrid.RowHeight = {'1x'};
            app.spectralThreadEditGrid.ColumnSpacing = 5;
            app.spectralThreadEditGrid.Padding = [0 0 0 0];
            app.spectralThreadEditGrid.Layout.Row = 1;
            app.spectralThreadEditGrid.Layout.Column = 2;
            app.spectralThreadEditGrid.BackgroundColor = [1 1 1];

            % Create spectralThreadEdit
            app.spectralThreadEdit = uiimage(app.spectralThreadEditGrid);
            app.spectralThreadEdit.ImageClickedFcn = createCallbackFcn(app, @general_ThreadChanged, true);
            app.spectralThreadEdit.Tooltip = {'Possibilita edição dos parâmetros do canal'};
            app.spectralThreadEdit.Layout.Row = 1;
            app.spectralThreadEdit.Layout.Column = 2;
            app.spectralThreadEdit.VerticalAlignment = 'bottom';
            app.spectralThreadEdit.ImageSource = 'Edit_32.png';

            % Create spectralThreadEditConfirm
            app.spectralThreadEditConfirm = uiimage(app.spectralThreadEditGrid);
            app.spectralThreadEditConfirm.ImageClickedFcn = createCallbackFcn(app, @general_ThreadChanged, true);
            app.spectralThreadEditConfirm.Enable = 'off';
            app.spectralThreadEditConfirm.Tooltip = {'Confirma edição'};
            app.spectralThreadEditConfirm.Layout.Row = 1;
            app.spectralThreadEditConfirm.Layout.Column = 3;
            app.spectralThreadEditConfirm.VerticalAlignment = 'bottom';
            app.spectralThreadEditConfirm.ImageSource = 'Ok_32Green.png';

            % Create spectralThreadEditCancel
            app.spectralThreadEditCancel = uiimage(app.spectralThreadEditGrid);
            app.spectralThreadEditCancel.ImageClickedFcn = createCallbackFcn(app, @general_ThreadChanged, true);
            app.spectralThreadEditCancel.Enable = 'off';
            app.spectralThreadEditCancel.Tooltip = {'Cancela edição'};
            app.spectralThreadEditCancel.Layout.Row = 1;
            app.spectralThreadEditCancel.Layout.Column = 4;
            app.spectralThreadEditCancel.VerticalAlignment = 'bottom';
            app.spectralThreadEditCancel.ImageSource = 'Delete_32Red.png';

            % Create spectralThreadPanel
            app.spectralThreadPanel = uipanel(app.Tab1Grid);
            app.spectralThreadPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.spectralThreadPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.spectralThreadPanel.Layout.Row = 2;
            app.spectralThreadPanel.Layout.Column = [1 2];

            % Create spectralThreadGrid
            app.spectralThreadGrid = uigridlayout(app.spectralThreadPanel);
            app.spectralThreadGrid.ColumnWidth = {'1x'};
            app.spectralThreadGrid.RowHeight = {'1x'};
            app.spectralThreadGrid.Padding = [5 2 2 2];
            app.spectralThreadGrid.BackgroundColor = [1 1 1];

            % Create spectralThread
            app.spectralThread = uilabel(app.spectralThreadGrid);
            app.spectralThread.FontSize = 11;
            app.spectralThread.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.spectralThread.Layout.Row = 1;
            app.spectralThread.Layout.Column = 1;
            app.spectralThread.Text = '';

            % Create spectralThreadTree
            app.spectralThreadTree = uitree(app.Tab1Grid);
            app.spectralThreadTree.FontSize = 10;
            app.spectralThreadTree.FontColor = [0.651 0.651 0.651];
            app.spectralThreadTree.Layout.Row = 3;
            app.spectralThreadTree.Layout.Column = [1 2];

            % Create emissionListLabel
            app.emissionListLabel = uilabel(app.Tab1Grid);
            app.emissionListLabel.VerticalAlignment = 'bottom';
            app.emissionListLabel.FontSize = 10;
            app.emissionListLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.emissionListLabel.Layout.Row = 4;
            app.emissionListLabel.Layout.Column = 1;
            app.emissionListLabel.Text = 'EMISSÃO';

            % Create emissionList
            app.emissionList = uidropdown(app.Tab1Grid);
            app.emissionList.Items = {};
            app.emissionList.ValueChangedFcn = createCallbackFcn(app, @general_EmissionChanged, true);
            app.emissionList.FontSize = 11;
            app.emissionList.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.emissionList.BackgroundColor = [1 1 1];
            app.emissionList.Layout.Row = 5;
            app.emissionList.Layout.Column = [1 2];
            app.emissionList.Value = {};

            % Create emissionInfo
            app.emissionInfo = uilabel(app.Tab1Grid);
            app.emissionInfo.VerticalAlignment = 'top';
            app.emissionInfo.WordWrap = 'on';
            app.emissionInfo.FontSize = 11;
            app.emissionInfo.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.emissionInfo.Layout.Row = 6;
            app.emissionInfo.Layout.Column = [1 2];
            app.emissionInfo.Interpreter = 'html';
            app.emissionInfo.Text = '';

            % Create channelLabel
            app.channelLabel = uilabel(app.Tab1Grid);
            app.channelLabel.VerticalAlignment = 'bottom';
            app.channelLabel.FontSize = 10;
            app.channelLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelLabel.Layout.Row = 7;
            app.channelLabel.Layout.Column = 1;
            app.channelLabel.Text = 'CANAL SOB ANÁLISE';

            % Create channelEditGrid
            app.channelEditGrid = uigridlayout(app.Tab1Grid);
            app.channelEditGrid.ColumnWidth = {'1x', 18, 18, 0, 0};
            app.channelEditGrid.RowHeight = {'1x'};
            app.channelEditGrid.ColumnSpacing = 5;
            app.channelEditGrid.Padding = [0 0 0 0];
            app.channelEditGrid.Layout.Row = 7;
            app.channelEditGrid.Layout.Column = 2;
            app.channelEditGrid.BackgroundColor = [1 1 1];

            % Create channelRefresh
            app.channelRefresh = uiimage(app.channelEditGrid);
            app.channelRefresh.ImageClickedFcn = createCallbackFcn(app, @general_ChannelChanged, true);
            app.channelRefresh.Visible = 'off';
            app.channelRefresh.Tooltip = {'Volta à configuração inicial'};
            app.channelRefresh.Layout.Row = 1;
            app.channelRefresh.Layout.Column = 2;
            app.channelRefresh.VerticalAlignment = 'bottom';
            app.channelRefresh.ImageSource = 'Refresh_18.png';

            % Create channelEditMode
            app.channelEditMode = uiimage(app.channelEditGrid);
            app.channelEditMode.ImageClickedFcn = createCallbackFcn(app, @general_ChannelChanged, true);
            app.channelEditMode.Tooltip = {'Possibilita edição dos parâmetros do canal'};
            app.channelEditMode.Layout.Row = 1;
            app.channelEditMode.Layout.Column = 3;
            app.channelEditMode.VerticalAlignment = 'bottom';
            app.channelEditMode.ImageSource = 'Edit_32.png';

            % Create channelEditConfirm
            app.channelEditConfirm = uiimage(app.channelEditGrid);
            app.channelEditConfirm.ImageClickedFcn = createCallbackFcn(app, @general_ChannelChanged, true);
            app.channelEditConfirm.Enable = 'off';
            app.channelEditConfirm.Tooltip = {'Confirma edição'};
            app.channelEditConfirm.Layout.Row = 1;
            app.channelEditConfirm.Layout.Column = 4;
            app.channelEditConfirm.VerticalAlignment = 'bottom';
            app.channelEditConfirm.ImageSource = 'Ok_32Green.png';

            % Create channelEditCancel
            app.channelEditCancel = uiimage(app.channelEditGrid);
            app.channelEditCancel.ImageClickedFcn = createCallbackFcn(app, @general_ChannelChanged, true);
            app.channelEditCancel.Enable = 'off';
            app.channelEditCancel.Tooltip = {'Cancela edição'};
            app.channelEditCancel.Layout.Row = 1;
            app.channelEditCancel.Layout.Column = 5;
            app.channelEditCancel.VerticalAlignment = 'bottom';
            app.channelEditCancel.ImageSource = 'Delete_32Red.png';

            % Create channelPanel
            app.channelPanel = uipanel(app.Tab1Grid);
            app.channelPanel.AutoResizeChildren = 'off';
            app.channelPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.channelPanel.Layout.Row = 8;
            app.channelPanel.Layout.Column = [1 2];

            % Create channelGrid
            app.channelGrid = uigridlayout(app.channelPanel);
            app.channelGrid.ColumnWidth = {'1x', 110};
            app.channelGrid.RowHeight = {22, 22};
            app.channelGrid.RowSpacing = 5;
            app.channelGrid.BackgroundColor = [1 1 1];

            % Create channelFrequencyLabel
            app.channelFrequencyLabel = uilabel(app.channelGrid);
            app.channelFrequencyLabel.FontSize = 11;
            app.channelFrequencyLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelFrequencyLabel.Layout.Row = 1;
            app.channelFrequencyLabel.Layout.Column = 1;
            app.channelFrequencyLabel.Text = 'Frequência central (MHz):';

            % Create channelFrequency
            app.channelFrequency = uieditfield(app.channelGrid, 'numeric');
            app.channelFrequency.ValueDisplayFormat = '%.3f';
            app.channelFrequency.Editable = 'off';
            app.channelFrequency.FontSize = 11;
            app.channelFrequency.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelFrequency.Layout.Row = 1;
            app.channelFrequency.Layout.Column = 2;

            % Create channelBandWidthLabel
            app.channelBandWidthLabel = uilabel(app.channelGrid);
            app.channelBandWidthLabel.FontSize = 11;
            app.channelBandWidthLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelBandWidthLabel.Layout.Row = 2;
            app.channelBandWidthLabel.Layout.Column = 1;
            app.channelBandWidthLabel.Text = 'Largura (kHz):';

            % Create channelBandWidth
            app.channelBandWidth = uieditfield(app.channelGrid, 'numeric');
            app.channelBandWidth.ValueDisplayFormat = '%.1f';
            app.channelBandWidth.Editable = 'off';
            app.channelBandWidth.FontSize = 11;
            app.channelBandWidth.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelBandWidth.Layout.Row = 2;
            app.channelBandWidth.Layout.Column = 2;

            % Create reportFlag
            app.reportFlag = uicheckbox(app.Tab1Grid);
            app.reportFlag.ValueChangedFcn = createCallbackFcn(app, @general_ReportFlagCheckBoxClicked, true);
            app.reportFlag.Text = 'Customizar plot relacionado à emissão, habilitando-o para inclusão em relatório.';
            app.reportFlag.WordWrap = 'on';
            app.reportFlag.FontSize = 11;
            app.reportFlag.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportFlag.Layout.Row = 10;
            app.reportFlag.Layout.Column = [1 2];

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.AutoResizeChildren = 'off';
            app.Tab2.Title = 'FILTRO';
            app.Tab2.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.Tab2.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create Tab2Grid
            app.Tab2Grid = uigridlayout(app.Tab2);
            app.Tab2Grid.ColumnWidth = {'1x', 22};
            app.Tab2Grid.RowHeight = {22, 96, 8, '1x', 54, 74};
            app.Tab2Grid.ColumnSpacing = 5;
            app.Tab2Grid.RowSpacing = 5;
            app.Tab2Grid.Padding = [10 10 10 5];
            app.Tab2Grid.BackgroundColor = [1 1 1];

            % Create filter_TreeLabel
            app.filter_TreeLabel = uilabel(app.Tab2Grid);
            app.filter_TreeLabel.VerticalAlignment = 'bottom';
            app.filter_TreeLabel.FontSize = 10;
            app.filter_TreeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_TreeLabel.Layout.Row = 1;
            app.filter_TreeLabel.Layout.Column = 1;
            app.filter_TreeLabel.Text = 'ORDINÁRIA';

            % Create filter_RadioGroup
            app.filter_RadioGroup = uibuttongroup(app.Tab2Grid);
            app.filter_RadioGroup.AutoResizeChildren = 'off';
            app.filter_RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @filter_RadioGroupSelectionChanged, true);
            app.filter_RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_RadioGroup.BackgroundColor = [1 1 1];
            app.filter_RadioGroup.Layout.Row = 2;
            app.filter_RadioGroup.Layout.Column = [1 2];
            app.filter_RadioGroup.FontWeight = 'bold';
            app.filter_RadioGroup.FontSize = 10;

            % Create filter_THR
            app.filter_THR = uiradiobutton(app.filter_RadioGroup);
            app.filter_THR.Text = {'<b>NÍVEL</b>'; '<p style="color: gray; text-align: justify;">Elimina medições cuja potência do canal sob análise é inferior ao <i>threshold</i>.</font>'};
            app.filter_THR.WordWrap = 'on';
            app.filter_THR.FontSize = 10;
            app.filter_THR.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_THR.Interpreter = 'html';
            app.filter_THR.Position = [11 45 275 44];
            app.filter_THR.Value = true;

            % Create filter_Geographic
            app.filter_Geographic = uiradiobutton(app.filter_RadioGroup);
            app.filter_Geographic.Text = {'<b>GEOGRÁFICA</b>'; '<p style="color: gray; text-align: justify;">Elimina medições fora da região de interesse (ROI).</p>'};
            app.filter_Geographic.FontSize = 10;
            app.filter_Geographic.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_Geographic.Interpreter = 'html';
            app.filter_Geographic.Position = [11 7 275 29];

            % Create filter_GeographicTypeLabel
            app.filter_GeographicTypeLabel = uilabel(app.filter_RadioGroup);
            app.filter_GeographicTypeLabel.VerticalAlignment = 'bottom';
            app.filter_GeographicTypeLabel.FontSize = 10;
            app.filter_GeographicTypeLabel.FontColor = [0.502 0.502 0.502];
            app.filter_GeographicTypeLabel.Visible = 'off';
            app.filter_GeographicTypeLabel.Position = [30 -8 61 14];
            app.filter_GeographicTypeLabel.Text = 'Fonte:';

            % Create filter_GeographicType
            app.filter_GeographicType = uidropdown(app.filter_RadioGroup);
            app.filter_GeographicType.Items = {'ROI:Círculo', 'ROI:Retângulo', 'ROI:Polígono', 'Arquivo externo KML/KMZ'};
            app.filter_GeographicType.ValueChangedFcn = createCallbackFcn(app, @filter_GeographicTypeValueChanged, true);
            app.filter_GeographicType.Visible = 'off';
            app.filter_GeographicType.FontSize = 11;
            app.filter_GeographicType.FontColor = [0.502 0.502 0.502];
            app.filter_GeographicType.BackgroundColor = [1 1 1];
            app.filter_GeographicType.Position = [29 -32 232 22];
            app.filter_GeographicType.Value = 'Arquivo externo KML/KMZ';

            % Create filter_KMLFilenameLabel
            app.filter_KMLFilenameLabel = uilabel(app.filter_RadioGroup);
            app.filter_KMLFilenameLabel.Tag = 'KML';
            app.filter_KMLFilenameLabel.VerticalAlignment = 'bottom';
            app.filter_KMLFilenameLabel.FontSize = 10;
            app.filter_KMLFilenameLabel.FontColor = [0.502 0.502 0.502];
            app.filter_KMLFilenameLabel.Visible = 'off';
            app.filter_KMLFilenameLabel.Position = [30 -51 61 15];
            app.filter_KMLFilenameLabel.Text = 'Arquivo:';

            % Create filter_KMLFilename
            app.filter_KMLFilename = uieditfield(app.filter_RadioGroup, 'text');
            app.filter_KMLFilename.Tag = 'KML';
            app.filter_KMLFilename.Editable = 'off';
            app.filter_KMLFilename.FontSize = 11;
            app.filter_KMLFilename.FontColor = [0.502 0.502 0.502];
            app.filter_KMLFilename.Visible = 'off';
            app.filter_KMLFilename.Position = [29 -74 232 22];

            % Create filter_KMLOpenFile
            app.filter_KMLOpenFile = uiimage(app.filter_RadioGroup);
            app.filter_KMLOpenFile.ImageClickedFcn = createCallbackFcn(app, @filter_KMLOpenFileClicked, true);
            app.filter_KMLOpenFile.Tag = 'KML';
            app.filter_KMLOpenFile.Visible = 'off';
            app.filter_KMLOpenFile.Position = [268 -72 18 18];
            app.filter_KMLOpenFile.ImageSource = 'OpenFile_36x36.png';

            % Create filter_KMLFileLayer
            app.filter_KMLFileLayer = uidropdown(app.filter_RadioGroup);
            app.filter_KMLFileLayer.Items = {};
            app.filter_KMLFileLayer.Tag = 'KML';
            app.filter_KMLFileLayer.Visible = 'off';
            app.filter_KMLFileLayer.FontSize = 11;
            app.filter_KMLFileLayer.FontColor = [0.502 0.502 0.502];
            app.filter_KMLFileLayer.BackgroundColor = [1 1 1];
            app.filter_KMLFileLayer.Position = [29 -101 232 22];
            app.filter_KMLFileLayer.Value = {};

            % Create filter_AddImage
            app.filter_AddImage = uiimage(app.Tab2Grid);
            app.filter_AddImage.ImageClickedFcn = createCallbackFcn(app, @filter_AddFilterImageClicked, true);
            app.filter_AddImage.Layout.Row = 3;
            app.filter_AddImage.Layout.Column = 2;
            app.filter_AddImage.HorizontalAlignment = 'right';
            app.filter_AddImage.ImageSource = 'addSymbol_32.png';

            % Create filter_Tree
            app.filter_Tree = uitree(app.Tab2Grid);
            app.filter_Tree.SelectionChangedFcn = createCallbackFcn(app, @filter_TreeSelectionChanged, true);
            app.filter_Tree.FontSize = 10.5;
            app.filter_Tree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_Tree.Layout.Row = 4;
            app.filter_Tree.Layout.Column = [1 2];

            % Create filter_DataBinningLabel
            app.filter_DataBinningLabel = uilabel(app.Tab2Grid);
            app.filter_DataBinningLabel.VerticalAlignment = 'bottom';
            app.filter_DataBinningLabel.WordWrap = 'on';
            app.filter_DataBinningLabel.FontSize = 10;
            app.filter_DataBinningLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningLabel.Layout.Row = 5;
            app.filter_DataBinningLabel.Layout.Column = [1 2];
            app.filter_DataBinningLabel.Interpreter = 'html';
            app.filter_DataBinningLabel.Text = {'DATA-BINNING'; '<p style="font-size: 10px; color: gray; text-align: justify; padding-right: 2px;">Agrupa medições em quadrículas, sumarizando-as por meio de função estatística.</p>'};

            % Create filter_DataBinningPanel
            app.filter_DataBinningPanel = uipanel(app.Tab2Grid);
            app.filter_DataBinningPanel.AutoResizeChildren = 'off';
            app.filter_DataBinningPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.filter_DataBinningPanel.Layout.Row = 6;
            app.filter_DataBinningPanel.Layout.Column = [1 2];

            % Create filter_DataBinningGrid
            app.filter_DataBinningGrid = uigridlayout(app.filter_DataBinningPanel);
            app.filter_DataBinningGrid.ColumnWidth = {110, '1x'};
            app.filter_DataBinningGrid.RowHeight = {'1x', 22};
            app.filter_DataBinningGrid.RowSpacing = 5;
            app.filter_DataBinningGrid.Padding = [10 10 10 5];
            app.filter_DataBinningGrid.BackgroundColor = [1 1 1];

            % Create filter_DataBinningLengthLabel
            app.filter_DataBinningLengthLabel = uilabel(app.filter_DataBinningGrid);
            app.filter_DataBinningLengthLabel.VerticalAlignment = 'bottom';
            app.filter_DataBinningLengthLabel.WordWrap = 'on';
            app.filter_DataBinningLengthLabel.FontSize = 10;
            app.filter_DataBinningLengthLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_DataBinningLengthLabel.Layout.Row = 1;
            app.filter_DataBinningLengthLabel.Layout.Column = 1;
            app.filter_DataBinningLengthLabel.Interpreter = 'html';
            app.filter_DataBinningLengthLabel.Text = {'Comprimento da lateral'; 'da quadrícula (metros):'};

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
            app.filter_DataBinningFcnLabel.FontSize = 10;
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

            % Create Tab3
            app.Tab3 = uitab(app.TabGroup);
            app.Tab3.AutoResizeChildren = 'off';
            app.Tab3.Title = 'PT. INTERESSE';
            app.Tab3.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.Tab3.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create Tab3Grid
            app.Tab3Grid = uigridlayout(app.Tab3);
            app.Tab3Grid.ColumnWidth = {'1x', 22};
            app.Tab3Grid.RowHeight = {22, 92, 118, 8, '1x'};
            app.Tab3Grid.ColumnSpacing = 5;
            app.Tab3Grid.RowSpacing = 5;
            app.Tab3Grid.Padding = [10 10 10 5];
            app.Tab3Grid.BackgroundColor = [1 1 1];

            % Create points_TreeLabel
            app.points_TreeLabel = uilabel(app.Tab3Grid);
            app.points_TreeLabel.VerticalAlignment = 'bottom';
            app.points_TreeLabel.FontSize = 10;
            app.points_TreeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_TreeLabel.Layout.Row = 1;
            app.points_TreeLabel.Layout.Column = 1;
            app.points_TreeLabel.Text = 'TIPO';

            % Create points_RadioGroup
            app.points_RadioGroup = uibuttongroup(app.Tab3Grid);
            app.points_RadioGroup.AutoResizeChildren = 'off';
            app.points_RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @points_RadioGroupSelectionChanged, true);
            app.points_RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_RadioGroup.BackgroundColor = [1 1 1];
            app.points_RadioGroup.Layout.Row = 2;
            app.points_RadioGroup.Layout.Column = [1 2];
            app.points_RadioGroup.FontWeight = 'bold';
            app.points_RadioGroup.FontSize = 10;

            % Create points_AddRFDataHub
            app.points_AddRFDataHub = uiradiobutton(app.points_RadioGroup);
            app.points_AddRFDataHub.Text = {'<b>ESTAÇÕES DE TELECOMUNICAÇÕES</b>'; '<p style="color: gray; text-align: justify;">Adiciona estações incluídas no RFDataHub.</font>'};
            app.points_AddRFDataHub.FontSize = 10;
            app.points_AddRFDataHub.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_AddRFDataHub.Interpreter = 'html';
            app.points_AddRFDataHub.Position = [11 58 278 25];
            app.points_AddRFDataHub.Value = true;

            % Create points_AddFindPeaks
            app.points_AddFindPeaks = uiradiobutton(app.points_RadioGroup);
            app.points_AddFindPeaks.Text = {'<b>POTÊNCIA DO CANAL</b>'; '<p style="color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.points_AddFindPeaks.WordWrap = 'on';
            app.points_AddFindPeaks.FontSize = 10;
            app.points_AddFindPeaks.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_AddFindPeaks.Interpreter = 'html';
            app.points_AddFindPeaks.Position = [12 7 277 44];

            % Create points_AddValuePanel
            app.points_AddValuePanel = uipanel(app.Tab3Grid);
            app.points_AddValuePanel.AutoResizeChildren = 'off';
            app.points_AddValuePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_AddValuePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.points_AddValuePanel.Layout.Row = 3;
            app.points_AddValuePanel.Layout.Column = [1 2];

            % Create points_AddValueGrid
            app.points_AddValueGrid = uigridlayout(app.points_AddValuePanel);
            app.points_AddValueGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.points_AddValueGrid.RowHeight = {17, 22, 22, 22, 0, 0, 0, 0};
            app.points_AddValueGrid.RowSpacing = 5;
            app.points_AddValueGrid.Padding = [10 10 10 5];
            app.points_AddValueGrid.BackgroundColor = [1 1 1];

            % Create points_Subtype1Label
            app.points_Subtype1Label = uilabel(app.points_AddValueGrid);
            app.points_Subtype1Label.VerticalAlignment = 'bottom';
            app.points_Subtype1Label.FontSize = 10;
            app.points_Subtype1Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1Label.Layout.Row = 1;
            app.points_Subtype1Label.Layout.Column = [1 2];
            app.points_Subtype1Label.Text = 'Tipo de registro:';

            % Create points_Subtype1DropDown
            app.points_Subtype1DropDown = uidropdown(app.points_AddValueGrid);
            app.points_Subtype1DropDown.Items = {'Lista de frequências (MHz)', 'Índices de registros do RFDataHub'};
            app.points_Subtype1DropDown.FontSize = 11;
            app.points_Subtype1DropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1DropDown.BackgroundColor = [1 1 1];
            app.points_Subtype1DropDown.Layout.Row = 2;
            app.points_Subtype1DropDown.Layout.Column = [1 3];
            app.points_Subtype1DropDown.Value = 'Lista de frequências (MHz)';

            % Create points_Subtype1Value
            app.points_Subtype1Value = uieditfield(app.points_AddValueGrid, 'text');
            app.points_Subtype1Value.ValueChangedFcn = createCallbackFcn(app, @points_Subtype1ValueValueChanged2, true);
            app.points_Subtype1Value.FontSize = 11;
            app.points_Subtype1Value.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1Value.Tooltip = {'Exemplos:'; '• 101.1, 101.3, 101.5 (Lista de frequências)'; '• #1000 #1500 #2000 (RFDataHub)'};
            app.points_Subtype1Value.Layout.Row = 3;
            app.points_Subtype1Value.Layout.Column = [1 3];

            % Create points_Subtype1DistanceLabel
            app.points_Subtype1DistanceLabel = uilabel(app.points_AddValueGrid);
            app.points_Subtype1DistanceLabel.WordWrap = 'on';
            app.points_Subtype1DistanceLabel.FontSize = 10;
            app.points_Subtype1DistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1DistanceLabel.Layout.Row = 4;
            app.points_Subtype1DistanceLabel.Layout.Column = [1 2];
            app.points_Subtype1DistanceLabel.Text = 'Distância máxima entre estação e local da monitoração (km):';

            % Create points_Subtype1Distance
            app.points_Subtype1Distance = uieditfield(app.points_AddValueGrid, 'numeric');
            app.points_Subtype1Distance.Limits = [1 Inf];
            app.points_Subtype1Distance.RoundFractionalValues = 'on';
            app.points_Subtype1Distance.ValueDisplayFormat = '%d';
            app.points_Subtype1Distance.FontSize = 11;
            app.points_Subtype1Distance.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1Distance.Layout.Row = 4;
            app.points_Subtype1Distance.Layout.Column = 3;
            app.points_Subtype1Distance.Value = 30;

            % Create points_Subtype2Label
            app.points_Subtype2Label = uilabel(app.points_AddValueGrid);
            app.points_Subtype2Label.VerticalAlignment = 'bottom';
            app.points_Subtype2Label.FontSize = 10;
            app.points_Subtype2Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2Label.Layout.Row = 5;
            app.points_Subtype2Label.Layout.Column = [1 2];
            app.points_Subtype2Label.Text = 'Fonte da informação:';

            % Create points_Subtype2DropDown
            app.points_Subtype2DropDown = uidropdown(app.points_AddValueGrid);
            app.points_Subtype2DropDown.Items = {'Dados brutos', 'Dados processados (Data Binning)'};
            app.points_Subtype2DropDown.FontSize = 11;
            app.points_Subtype2DropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2DropDown.BackgroundColor = [1 1 1];
            app.points_Subtype2DropDown.Layout.Row = 6;
            app.points_Subtype2DropDown.Layout.Column = [1 3];
            app.points_Subtype2DropDown.Value = 'Dados brutos';

            % Create points_Subtype2NPeaksLabel
            app.points_Subtype2NPeaksLabel = uilabel(app.points_AddValueGrid);
            app.points_Subtype2NPeaksLabel.FontSize = 10;
            app.points_Subtype2NPeaksLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2NPeaksLabel.Layout.Row = 7;
            app.points_Subtype2NPeaksLabel.Layout.Column = [1 2];
            app.points_Subtype2NPeaksLabel.Text = 'Número de picos:';

            % Create points_Subtype2NPeaks
            app.points_Subtype2NPeaks = uispinner(app.points_AddValueGrid);
            app.points_Subtype2NPeaks.Limits = [1 100];
            app.points_Subtype2NPeaks.RoundFractionalValues = 'on';
            app.points_Subtype2NPeaks.ValueDisplayFormat = '%.0f';
            app.points_Subtype2NPeaks.FontSize = 11;
            app.points_Subtype2NPeaks.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2NPeaks.Layout.Row = 7;
            app.points_Subtype2NPeaks.Layout.Column = 3;
            app.points_Subtype2NPeaks.Value = 1;

            % Create points_Subtype2DistanceLabel
            app.points_Subtype2DistanceLabel = uilabel(app.points_AddValueGrid);
            app.points_Subtype2DistanceLabel.WordWrap = 'on';
            app.points_Subtype2DistanceLabel.FontSize = 10;
            app.points_Subtype2DistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2DistanceLabel.Layout.Row = 8;
            app.points_Subtype2DistanceLabel.Layout.Column = [1 2];
            app.points_Subtype2DistanceLabel.Text = 'Distância mínima entre picos (metros):';

            % Create points_Subtype2Distance
            app.points_Subtype2Distance = uispinner(app.points_AddValueGrid);
            app.points_Subtype2Distance.Step = 100;
            app.points_Subtype2Distance.Limits = [0 10000];
            app.points_Subtype2Distance.RoundFractionalValues = 'on';
            app.points_Subtype2Distance.ValueDisplayFormat = '%.0f';
            app.points_Subtype2Distance.FontSize = 11;
            app.points_Subtype2Distance.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2Distance.Layout.Row = 8;
            app.points_Subtype2Distance.Layout.Column = 3;
            app.points_Subtype2Distance.Value = 1000;

            % Create points_AddImage
            app.points_AddImage = uiimage(app.Tab3Grid);
            app.points_AddImage.ScaleMethod = 'scaledown';
            app.points_AddImage.ImageClickedFcn = createCallbackFcn(app, @points_AddPointImageClicked, true);
            app.points_AddImage.Layout.Row = 4;
            app.points_AddImage.Layout.Column = 2;
            app.points_AddImage.HorizontalAlignment = 'right';
            app.points_AddImage.VerticalAlignment = 'bottom';
            app.points_AddImage.ImageSource = 'addSymbol_32.png';

            % Create points_Tree
            app.points_Tree = uitree(app.Tab3Grid, 'checkbox');
            app.points_Tree.FontSize = 10.5;
            app.points_Tree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Tree.Layout.Row = 5;
            app.points_Tree.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.points_Tree.CheckedNodesChangedFcn = createCallbackFcn(app, @points_TreeCheckedNodesChanged, true);

            % Create Tab4
            app.Tab4 = uitab(app.TabGroup);
            app.Tab4.AutoResizeChildren = 'off';
            app.Tab4.Title = 'CONFIG';
            app.Tab4.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.Tab4.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create Tab4Grid
            app.Tab4Grid = uigridlayout(app.Tab4);
            app.Tab4Grid.ColumnWidth = {'1x', 22};
            app.Tab4Grid.RowHeight = {22, 184, 22, '1x'};
            app.Tab4Grid.ColumnSpacing = 5;
            app.Tab4Grid.RowSpacing = 5;
            app.Tab4Grid.Padding = [10 10 10 5];
            app.Tab4Grid.BackgroundColor = [1 1 1];

            % Create config_geoAxesLabel
            app.config_geoAxesLabel = uilabel(app.Tab4Grid);
            app.config_geoAxesLabel.VerticalAlignment = 'bottom';
            app.config_geoAxesLabel.WordWrap = 'on';
            app.config_geoAxesLabel.FontSize = 10;
            app.config_geoAxesLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_geoAxesLabel.Layout.Row = 1;
            app.config_geoAxesLabel.Layout.Column = [1 2];
            app.config_geoAxesLabel.Text = 'EIXO GEOGRÁFICO';

            % Create config_Refresh
            app.config_Refresh = uiimage(app.Tab4Grid);
            app.config_Refresh.ScaleMethod = 'none';
            app.config_Refresh.ImageClickedFcn = createCallbackFcn(app, @config_RefreshImageClicked, true);
            app.config_Refresh.Visible = 'off';
            app.config_Refresh.Tooltip = {'Volta à configuração inicial'};
            app.config_Refresh.Layout.Row = 1;
            app.config_Refresh.Layout.Column = 2;
            app.config_Refresh.VerticalAlignment = 'bottom';
            app.config_Refresh.ImageSource = 'Refresh_18.png';

            % Create config_geoAxesPanel
            app.config_geoAxesPanel = uipanel(app.Tab4Grid);
            app.config_geoAxesPanel.AutoResizeChildren = 'off';
            app.config_geoAxesPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_geoAxesPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.config_geoAxesPanel.Layout.Row = 2;
            app.config_geoAxesPanel.Layout.Column = [1 2];

            % Create config_geoAxesGrid
            app.config_geoAxesGrid = uigridlayout(app.config_geoAxesPanel);
            app.config_geoAxesGrid.ColumnWidth = {56, '1x', 36, 36, 36};
            app.config_geoAxesGrid.RowHeight = {17, 64, 22, 22, 22};
            app.config_geoAxesGrid.RowSpacing = 5;
            app.config_geoAxesGrid.Padding = [10 10 10 5];
            app.config_geoAxesGrid.BackgroundColor = [1 1 1];

            % Create config_geoAxesSublabel
            app.config_geoAxesSublabel = uilabel(app.config_geoAxesGrid);
            app.config_geoAxesSublabel.VerticalAlignment = 'bottom';
            app.config_geoAxesSublabel.FontSize = 10;
            app.config_geoAxesSublabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_geoAxesSublabel.Layout.Row = 1;
            app.config_geoAxesSublabel.Layout.Column = 1;
            app.config_geoAxesSublabel.Text = 'Mapa:';

            % Create config_geoAxesSubPanel
            app.config_geoAxesSubPanel = uipanel(app.config_geoAxesGrid);
            app.config_geoAxesSubPanel.AutoResizeChildren = 'off';
            app.config_geoAxesSubPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_geoAxesSubPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.config_geoAxesSubPanel.Layout.Row = 2;
            app.config_geoAxesSubPanel.Layout.Column = [1 5];

            % Create config_geoAxesSubGrid
            app.config_geoAxesSubGrid = uigridlayout(app.config_geoAxesSubPanel);
            app.config_geoAxesSubGrid.ColumnWidth = {127, '1x'};
            app.config_geoAxesSubGrid.RowHeight = {17, 22};
            app.config_geoAxesSubGrid.RowSpacing = 5;
            app.config_geoAxesSubGrid.Padding = [10 10 10 5];
            app.config_geoAxesSubGrid.BackgroundColor = [1 1 1];

            % Create config_BasemapLabel
            app.config_BasemapLabel = uilabel(app.config_geoAxesSubGrid);
            app.config_BasemapLabel.VerticalAlignment = 'bottom';
            app.config_BasemapLabel.FontSize = 10;
            app.config_BasemapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BasemapLabel.Layout.Row = 1;
            app.config_BasemapLabel.Layout.Column = 1;
            app.config_BasemapLabel.Text = 'Basemap:';

            % Create config_Basemap
            app.config_Basemap = uidropdown(app.config_geoAxesSubGrid);
            app.config_Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.config_Basemap.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Basemap.FontSize = 11;
            app.config_Basemap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Basemap.BackgroundColor = [1 1 1];
            app.config_Basemap.Layout.Row = 2;
            app.config_Basemap.Layout.Column = 1;
            app.config_Basemap.Value = 'satellite';

            % Create config_ColormapLabel
            app.config_ColormapLabel = uilabel(app.config_geoAxesSubGrid);
            app.config_ColormapLabel.VerticalAlignment = 'bottom';
            app.config_ColormapLabel.FontSize = 10;
            app.config_ColormapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ColormapLabel.Layout.Row = 1;
            app.config_ColormapLabel.Layout.Column = 2;
            app.config_ColormapLabel.Text = 'Mapa de cor:';

            % Create config_Colormap
            app.config_Colormap = uidropdown(app.config_geoAxesSubGrid);
            app.config_Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.config_Colormap.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Colormap.FontSize = 11;
            app.config_Colormap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Colormap.BackgroundColor = [1 1 1];
            app.config_Colormap.Layout.Row = 2;
            app.config_Colormap.Layout.Column = 2;
            app.config_Colormap.Value = 'turbo';

            % Create config_route_Label
            app.config_route_Label = uilabel(app.config_geoAxesGrid);
            app.config_route_Label.FontSize = 10;
            app.config_route_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_route_Label.Layout.Row = 3;
            app.config_route_Label.Layout.Column = 1;
            app.config_route_Label.Text = 'Rota:';

            % Create config_route_LineStyle
            app.config_route_LineStyle = uidropdown(app.config_geoAxesGrid);
            app.config_route_LineStyle.Items = {'none', ':', '-'};
            app.config_route_LineStyle.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_route_LineStyle.FontSize = 11;
            app.config_route_LineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_route_LineStyle.BackgroundColor = [1 1 1];
            app.config_route_LineStyle.Layout.Row = 3;
            app.config_route_LineStyle.Layout.Column = 2;
            app.config_route_LineStyle.Value = ':';

            % Create config_route_OutColor
            app.config_route_OutColor = uicolorpicker(app.config_geoAxesGrid);
            app.config_route_OutColor.Value = [0.502 0.502 0.502];
            app.config_route_OutColor.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_route_OutColor.Layout.Row = 3;
            app.config_route_OutColor.Layout.Column = 3;
            app.config_route_OutColor.BackgroundColor = [1 1 1];

            % Create config_route_InColor
            app.config_route_InColor = uicolorpicker(app.config_geoAxesGrid);
            app.config_route_InColor.Value = [0.8706 0.5412 0.5412];
            app.config_route_InColor.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_route_InColor.Layout.Row = 3;
            app.config_route_InColor.Layout.Column = 4;
            app.config_route_InColor.BackgroundColor = [1 1 1];

            % Create config_route_Size
            app.config_route_Size = uislider(app.config_geoAxesGrid);
            app.config_route_Size.Limits = [1 9];
            app.config_route_Size.MajorTicks = [];
            app.config_route_Size.ValueChangingFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_route_Size.MinorTicks = [1 2 3 4 5 6 7 8 9];
            app.config_route_Size.FontSize = 10;
            app.config_route_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_route_Size.Tooltip = {'Tamanho do marcador'};
            app.config_route_Size.Layout.Row = 3;
            app.config_route_Size.Layout.Column = 5;
            app.config_route_Size.Value = 1;

            % Create config_Car_Label
            app.config_Car_Label = uilabel(app.config_geoAxesGrid);
            app.config_Car_Label.FontSize = 10;
            app.config_Car_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Car_Label.Layout.Row = 4;
            app.config_Car_Label.Layout.Column = 1;
            app.config_Car_Label.Text = 'Veículo:';

            % Create config_Car_LineStyle
            app.config_Car_LineStyle = uidropdown(app.config_geoAxesGrid);
            app.config_Car_LineStyle.Items = {'none', 'o', 'square', '^'};
            app.config_Car_LineStyle.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Car_LineStyle.FontSize = 11;
            app.config_Car_LineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Car_LineStyle.BackgroundColor = [1 1 1];
            app.config_Car_LineStyle.Layout.Row = 4;
            app.config_Car_LineStyle.Layout.Column = 2;
            app.config_Car_LineStyle.Value = 'square';

            % Create config_Car_Color
            app.config_Car_Color = uicolorpicker(app.config_geoAxesGrid);
            app.config_Car_Color.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_Car_Color.Layout.Row = 4;
            app.config_Car_Color.Layout.Column = 3;
            app.config_Car_Color.BackgroundColor = [1 1 1];

            % Create config_Car_Size
            app.config_Car_Size = uislider(app.config_geoAxesGrid);
            app.config_Car_Size.Limits = [1 19];
            app.config_Car_Size.MajorTicks = [];
            app.config_Car_Size.ValueChangingFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Car_Size.MinorTicks = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19];
            app.config_Car_Size.FontSize = 10;
            app.config_Car_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Car_Size.Tooltip = {'Tamanho do marcador'};
            app.config_Car_Size.Layout.Row = 4;
            app.config_Car_Size.Layout.Column = [4 5];
            app.config_Car_Size.Value = 10;

            % Create config_points_Label
            app.config_points_Label = uilabel(app.config_geoAxesGrid);
            app.config_points_Label.WordWrap = 'on';
            app.config_points_Label.FontSize = 10;
            app.config_points_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_points_Label.Layout.Row = 5;
            app.config_points_Label.Layout.Column = [1 2];
            app.config_points_Label.Text = {'Pontos de'; 'interesse:'};

            % Create config_points_LineStyle
            app.config_points_LineStyle = uidropdown(app.config_geoAxesGrid);
            app.config_points_LineStyle.Items = {'none', 'o', 'square', '^'};
            app.config_points_LineStyle.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_points_LineStyle.FontSize = 11;
            app.config_points_LineStyle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_points_LineStyle.BackgroundColor = [1 1 1];
            app.config_points_LineStyle.Layout.Row = 5;
            app.config_points_LineStyle.Layout.Column = 2;
            app.config_points_LineStyle.Value = 'none';

            % Create config_points_Color
            app.config_points_Color = uicolorpicker(app.config_geoAxesGrid);
            app.config_points_Color.Value = [0 0 0];
            app.config_points_Color.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_points_Color.Layout.Row = 5;
            app.config_points_Color.Layout.Column = 3;
            app.config_points_Color.BackgroundColor = [1 1 1];

            % Create config_points_Size
            app.config_points_Size = uislider(app.config_geoAxesGrid);
            app.config_points_Size.Limits = [6 12];
            app.config_points_Size.MajorTicks = [];
            app.config_points_Size.ValueChangingFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_points_Size.MinorTicks = [6 6.3 6.6 6.9 7.2 7.5 7.8 8.1 8.4 8.7 9 9.3 9.6 9.9 10.2 10.5 10.8 11.1 11.4 11.7 12];
            app.config_points_Size.FontSize = 10;
            app.config_points_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_points_Size.Tooltip = {'Tamanho do marcador'};
            app.config_points_Size.Layout.Row = 5;
            app.config_points_Size.Layout.Column = [4 5];
            app.config_points_Size.Value = 9;

            % Create config_xyAxesLabel
            app.config_xyAxesLabel = uilabel(app.Tab4Grid);
            app.config_xyAxesLabel.VerticalAlignment = 'bottom';
            app.config_xyAxesLabel.WordWrap = 'on';
            app.config_xyAxesLabel.FontSize = 10;
            app.config_xyAxesLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_xyAxesLabel.Layout.Row = 3;
            app.config_xyAxesLabel.Layout.Column = [1 2];
            app.config_xyAxesLabel.Text = 'EIXOS CARTESIANOS';

            % Create config_xyAxesPanel
            app.config_xyAxesPanel = uipanel(app.Tab4Grid);
            app.config_xyAxesPanel.AutoResizeChildren = 'off';
            app.config_xyAxesPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_xyAxesPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.config_xyAxesPanel.Layout.Row = 4;
            app.config_xyAxesPanel.Layout.Column = [1 2];

            % Create config_xyAxesGrid
            app.config_xyAxesGrid = uigridlayout(app.config_xyAxesPanel);
            app.config_xyAxesGrid.ColumnWidth = {56, 50, 36, '1x', '1x'};
            app.config_xyAxesGrid.RowHeight = {22, 22, 22, 22, '1x'};
            app.config_xyAxesGrid.RowSpacing = 5;
            app.config_xyAxesGrid.BackgroundColor = [1 1 1];

            % Create config_PersistanceLabel
            app.config_PersistanceLabel = uilabel(app.config_xyAxesGrid);
            app.config_PersistanceLabel.FontSize = 10;
            app.config_PersistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_PersistanceLabel.Layout.Row = 1;
            app.config_PersistanceLabel.Layout.Column = [1 2];
            app.config_PersistanceLabel.Text = 'Persistência:';

            % Create config_PersistanceVisibility
            app.config_PersistanceVisibility = uidropdown(app.config_xyAxesGrid);
            app.config_PersistanceVisibility.Items = {'on', 'off'};
            app.config_PersistanceVisibility.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_PersistanceVisibility.Tooltip = {''};
            app.config_PersistanceVisibility.FontSize = 11;
            app.config_PersistanceVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_PersistanceVisibility.BackgroundColor = [1 1 1];
            app.config_PersistanceVisibility.Layout.Row = 1;
            app.config_PersistanceVisibility.Layout.Column = 2;
            app.config_PersistanceVisibility.Value = 'on';

            % Create config_chROILabel
            app.config_chROILabel = uilabel(app.config_xyAxesGrid);
            app.config_chROILabel.WordWrap = 'on';
            app.config_chROILabel.FontSize = 10;
            app.config_chROILabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROILabel.Layout.Row = 2;
            app.config_chROILabel.Layout.Column = 1;
            app.config_chROILabel.Text = 'Canal:';

            % Create config_chROIVisibility
            app.config_chROIVisibility = uidropdown(app.config_xyAxesGrid);
            app.config_chROIVisibility.Items = {'on', 'off'};
            app.config_chROIVisibility.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chROIVisibility.Tooltip = {''};
            app.config_chROIVisibility.FontSize = 11;
            app.config_chROIVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROIVisibility.BackgroundColor = [1 1 1];
            app.config_chROIVisibility.Layout.Row = 2;
            app.config_chROIVisibility.Layout.Column = 2;
            app.config_chROIVisibility.Value = 'on';

            % Create config_chROIColor
            app.config_chROIColor = uicolorpicker(app.config_xyAxesGrid);
            app.config_chROIColor.Value = [0.7216 0.2706 1];
            app.config_chROIColor.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chROIColor.Tooltip = {''};
            app.config_chROIColor.Layout.Row = 2;
            app.config_chROIColor.Layout.Column = 3;
            app.config_chROIColor.BackgroundColor = [1 1 1];

            % Create config_chROIEdgeAlpha
            app.config_chROIEdgeAlpha = uispinner(app.config_xyAxesGrid);
            app.config_chROIEdgeAlpha.Step = 0.1;
            app.config_chROIEdgeAlpha.Limits = [0 1];
            app.config_chROIEdgeAlpha.ValueDisplayFormat = '%.1f';
            app.config_chROIEdgeAlpha.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chROIEdgeAlpha.FontSize = 11;
            app.config_chROIEdgeAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROIEdgeAlpha.Tooltip = {'Transparência da margem'};
            app.config_chROIEdgeAlpha.Layout.Row = 2;
            app.config_chROIEdgeAlpha.Layout.Column = 4;

            % Create config_chROIFaceAlpha
            app.config_chROIFaceAlpha = uispinner(app.config_xyAxesGrid);
            app.config_chROIFaceAlpha.Step = 0.1;
            app.config_chROIFaceAlpha.Limits = [0 1];
            app.config_chROIFaceAlpha.ValueDisplayFormat = '%.1f';
            app.config_chROIFaceAlpha.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chROIFaceAlpha.FontSize = 11;
            app.config_chROIFaceAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chROIFaceAlpha.Tooltip = {'Transparência da face'};
            app.config_chROIFaceAlpha.Layout.Row = 2;
            app.config_chROIFaceAlpha.Layout.Column = 5;
            app.config_chROIFaceAlpha.Value = 0.4;

            % Create config_chPowerLabel
            app.config_chPowerLabel = uilabel(app.config_xyAxesGrid);
            app.config_chPowerLabel.WordWrap = 'on';
            app.config_chPowerLabel.FontSize = 10;
            app.config_chPowerLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerLabel.Layout.Row = 3;
            app.config_chPowerLabel.Layout.Column = [1 2];
            app.config_chPowerLabel.Text = {'Potência do'; 'canal:'};

            % Create config_chPowerVisibility
            app.config_chPowerVisibility = uidropdown(app.config_xyAxesGrid);
            app.config_chPowerVisibility.Items = {'on', 'off'};
            app.config_chPowerVisibility.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chPowerVisibility.Tooltip = {''};
            app.config_chPowerVisibility.FontSize = 11;
            app.config_chPowerVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerVisibility.BackgroundColor = [1 1 1];
            app.config_chPowerVisibility.Layout.Row = 3;
            app.config_chPowerVisibility.Layout.Column = 2;
            app.config_chPowerVisibility.Value = 'on';

            % Create config_chPowerColor
            app.config_chPowerColor = uicolorpicker(app.config_xyAxesGrid);
            app.config_chPowerColor.Value = [0.5686 1 0];
            app.config_chPowerColor.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chPowerColor.Tooltip = {''};
            app.config_chPowerColor.Layout.Row = 3;
            app.config_chPowerColor.Layout.Column = 3;
            app.config_chPowerColor.BackgroundColor = [1 1 1];

            % Create config_chPowerEdgeAlpha
            app.config_chPowerEdgeAlpha = uispinner(app.config_xyAxesGrid);
            app.config_chPowerEdgeAlpha.Step = 0.1;
            app.config_chPowerEdgeAlpha.Limits = [0 1];
            app.config_chPowerEdgeAlpha.ValueDisplayFormat = '%.1f';
            app.config_chPowerEdgeAlpha.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chPowerEdgeAlpha.FontSize = 11;
            app.config_chPowerEdgeAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerEdgeAlpha.Tooltip = {'Transparência da margem'};
            app.config_chPowerEdgeAlpha.Layout.Row = 3;
            app.config_chPowerEdgeAlpha.Layout.Column = 4;
            app.config_chPowerEdgeAlpha.Value = 1;

            % Create config_chPowerFaceAlpha
            app.config_chPowerFaceAlpha = uispinner(app.config_xyAxesGrid);
            app.config_chPowerFaceAlpha.Step = 0.1;
            app.config_chPowerFaceAlpha.Limits = [0 1];
            app.config_chPowerFaceAlpha.ValueDisplayFormat = '%.1f';
            app.config_chPowerFaceAlpha.ValueChangedFcn = createCallbackFcn(app, @config_xyAxesParameterChanged, true);
            app.config_chPowerFaceAlpha.FontSize = 11;
            app.config_chPowerFaceAlpha.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_chPowerFaceAlpha.Tooltip = {'Transparência da face'};
            app.config_chPowerFaceAlpha.Layout.Row = 3;
            app.config_chPowerFaceAlpha.Layout.Column = 5;
            app.config_chPowerFaceAlpha.Value = 0.4;

            % Create config_BandGuardLabel
            app.config_BandGuardLabel = uilabel(app.config_xyAxesGrid);
            app.config_BandGuardLabel.VerticalAlignment = 'bottom';
            app.config_BandGuardLabel.WordWrap = 'on';
            app.config_BandGuardLabel.FontSize = 10;
            app.config_BandGuardLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardLabel.Layout.Row = 4;
            app.config_BandGuardLabel.Layout.Column = [1 2];
            app.config_BandGuardLabel.Text = 'Limites do eixo x:';

            % Create config_BandGuardPanel
            app.config_BandGuardPanel = uipanel(app.config_xyAxesGrid);
            app.config_BandGuardPanel.AutoResizeChildren = 'off';
            app.config_BandGuardPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.config_BandGuardPanel.Layout.Row = 5;
            app.config_BandGuardPanel.Layout.Column = [1 5];

            % Create config_BandGuardGrid
            app.config_BandGuardGrid = uigridlayout(app.config_BandGuardPanel);
            app.config_BandGuardGrid.ColumnWidth = {151, '1x'};
            app.config_BandGuardGrid.RowHeight = {17, 22, '1x'};
            app.config_BandGuardGrid.RowSpacing = 5;
            app.config_BandGuardGrid.Padding = [10 10 10 5];
            app.config_BandGuardGrid.BackgroundColor = [1 1 1];

            % Create config_BandGuardTypeLabel
            app.config_BandGuardTypeLabel = uilabel(app.config_BandGuardGrid);
            app.config_BandGuardTypeLabel.VerticalAlignment = 'bottom';
            app.config_BandGuardTypeLabel.FontSize = 10;
            app.config_BandGuardTypeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardTypeLabel.Layout.Row = 1;
            app.config_BandGuardTypeLabel.Layout.Column = 1;
            app.config_BandGuardTypeLabel.Text = 'Tipo:';

            % Create config_BandGuardType
            app.config_BandGuardType = uidropdown(app.config_BandGuardGrid);
            app.config_BandGuardType.Items = {'Fixed', 'BWRelated'};
            app.config_BandGuardType.ValueChangedFcn = createCallbackFcn(app, @config_BandGuardValueChanged, true);
            app.config_BandGuardType.FontSize = 11;
            app.config_BandGuardType.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardType.BackgroundColor = [1 1 1];
            app.config_BandGuardType.Layout.Row = 2;
            app.config_BandGuardType.Layout.Column = 1;
            app.config_BandGuardType.Value = 'BWRelated';

            % Create config_BandGuardValueLabel
            app.config_BandGuardValueLabel = uilabel(app.config_BandGuardGrid);
            app.config_BandGuardValueLabel.VerticalAlignment = 'bottom';
            app.config_BandGuardValueLabel.FontSize = 10;
            app.config_BandGuardValueLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardValueLabel.Layout.Row = 1;
            app.config_BandGuardValueLabel.Layout.Column = 2;
            app.config_BandGuardValueLabel.Text = 'Multiplicador:';

            % Create config_BandGuardFixedValue
            app.config_BandGuardFixedValue = uieditfield(app.config_BandGuardGrid, 'numeric');
            app.config_BandGuardFixedValue.Limits = [0 Inf];
            app.config_BandGuardFixedValue.ValueDisplayFormat = '%.1f';
            app.config_BandGuardFixedValue.ValueChangedFcn = createCallbackFcn(app, @config_BandGuardValueChanged, true);
            app.config_BandGuardFixedValue.FontSize = 11;
            app.config_BandGuardFixedValue.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardFixedValue.Visible = 'off';
            app.config_BandGuardFixedValue.Layout.Row = 2;
            app.config_BandGuardFixedValue.Layout.Column = 2;
            app.config_BandGuardFixedValue.Value = 1000;

            % Create config_BandGuardBWRelatedValue
            app.config_BandGuardBWRelatedValue = uispinner(app.config_BandGuardGrid);
            app.config_BandGuardBWRelatedValue.Limits = [1 10];
            app.config_BandGuardBWRelatedValue.RoundFractionalValues = 'on';
            app.config_BandGuardBWRelatedValue.ValueDisplayFormat = '%.0f';
            app.config_BandGuardBWRelatedValue.ValueChangedFcn = createCallbackFcn(app, @config_BandGuardValueChanged, true);
            app.config_BandGuardBWRelatedValue.FontSize = 11;
            app.config_BandGuardBWRelatedValue.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BandGuardBWRelatedValue.Layout.Row = 2;
            app.config_BandGuardBWRelatedValue.Layout.Column = 2;
            app.config_BandGuardBWRelatedValue.Value = 6;

            % Create Document
            app.Document = uipanel(app.GridLayout);
            app.Document.AutoResizeChildren = 'off';
            app.Document.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Document.BorderType = 'none';
            app.Document.BackgroundColor = [1 1 1];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 7];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.GridLayout);
            app.AxesToolbar.ColumnWidth = {22, 22, 5, '1x', 5, 22, 22, 5, '1x'};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = 3;
            app.AxesToolbar.Layout.Column = 5;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_InteractionImageClicked, true);
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 1;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_InteractionImageClicked, true);
            app.axesTool_RegionZoom.Tooltip = {'RegionZoom'};
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 2;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create axesTool_DropDown
            app.axesTool_DropDown = uidropdown(app.AxesToolbar);
            app.axesTool_DropDown.Items = {'Dados brutos', 'Dados processados'};
            app.axesTool_DropDown.ValueChangedFcn = createCallbackFcn(app, @AxesToolbar_DataSourceChanged, true);
            app.axesTool_DropDown.FontSize = 11;
            app.axesTool_DropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_DropDown.BackgroundColor = [1 1 1];
            app.axesTool_DropDown.Layout.Row = 1;
            app.axesTool_DropDown.Layout.Column = 4;
            app.axesTool_DropDown.Value = 'Dados brutos';

            % Create axesTool_DistortionPlot
            app.axesTool_DistortionPlot = uiimage(app.AxesToolbar);
            app.axesTool_DistortionPlot.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_PlotTypeValueChanged, true);
            app.axesTool_DistortionPlot.Tooltip = {'Distortion'};
            app.axesTool_DistortionPlot.Layout.Row = 1;
            app.axesTool_DistortionPlot.Layout.Column = 6;
            app.axesTool_DistortionPlot.ImageSource = 'DriveTestDistortion_32.png';

            % Create axesTool_DensityPlot
            app.axesTool_DensityPlot = uiimage(app.AxesToolbar);
            app.axesTool_DensityPlot.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_PlotTypeValueChanged, true);
            app.axesTool_DensityPlot.Enable = 'off';
            app.axesTool_DensityPlot.Tooltip = {'Heatmap'; '(aplicável apenas quando visualizados os dados processados)'};
            app.axesTool_DensityPlot.Layout.Row = 1;
            app.axesTool_DensityPlot.Layout.Column = 7;
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
            app.axesTool_PlotSize.Layout.Column = 9;
            app.axesTool_PlotSize.Value = 1;

            % Create DockModuleGroup
            app.DockModuleGroup = uigridlayout(app.GridLayout);
            app.DockModuleGroup.RowHeight = {'1x'};
            app.DockModuleGroup.ColumnSpacing = 2;
            app.DockModuleGroup.Padding = [5 2 5 2];
            app.DockModuleGroup.Visible = 'off';
            app.DockModuleGroup.Layout.Row = [2 3];
            app.DockModuleGroup.Layout.Column = [7 8];
            app.DockModuleGroup.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModuleGroup);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModuleGroup);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create ContextMenu2
            app.ContextMenu2 = uicontextmenu(app.UIFigure);

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
