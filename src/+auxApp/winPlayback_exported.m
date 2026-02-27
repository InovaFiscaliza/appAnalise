classdef winPlayback_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        dockModule_Undock               matlab.ui.control.Image
        dockModule_Close                matlab.ui.control.Image
        Document                        matlab.ui.container.GridLayout
        SubGrid1                        matlab.ui.container.GridLayout
        Image3                          matlab.ui.control.Image
        Image2                          matlab.ui.control.Image
        Image                           matlab.ui.control.Image
        play_ControlPanelLabel_2        matlab.ui.control.Label
        play_Persistance_Panel          matlab.ui.container.Panel
        play_PersistanceGrid            matlab.ui.container.GridLayout
        play_Persistance_cLim1          matlab.ui.control.Spinner
        play_Persistance_cLim2          matlab.ui.control.Spinner
        play_Persistance_cLim_Mode      matlab.ui.control.Image
        play_Persistance_cLim_Label     matlab.ui.control.Label
        play_Persistance_Transparency   matlab.ui.control.Spinner
        play_Persistance_TransparencyLabel  matlab.ui.control.Label
        play_Persistance_Colormap       matlab.ui.control.DropDown
        play_Persistance_ColormapLabel  matlab.ui.control.Label
        play_Persistance_WindowSize     matlab.ui.control.DropDown
        play_Persistance_WindowSizeValue  matlab.ui.control.Label
        play_Persistance_WindowSizeLabel  matlab.ui.control.Label
        play_Persistance_Interpolation  matlab.ui.control.DropDown
        play_Persistance_InterpolationLabel  matlab.ui.control.Label
        play_Waterfall_Panel            matlab.ui.container.Panel
        play_WaterFallGrid              matlab.ui.container.GridLayout
        play_Waterfall_cLim2            matlab.ui.control.Spinner
        play_Waterfall_cLim1            matlab.ui.control.Spinner
        play_Waterfall_cLim_Mode        matlab.ui.control.Image
        play_Waterfall_cLim_Label       matlab.ui.control.Label
        play_Waterfall_MeshStyle        matlab.ui.control.DropDown
        play_Waterfall_MeshStyleLabel   matlab.ui.control.Label
        play_Waterfall_Colormap         matlab.ui.control.DropDown
        play_Waterfall_ColormapLabel    matlab.ui.control.Label
        play_Waterfall_Decimation       matlab.ui.control.DropDown
        play_Waterfall_DecimationValue  matlab.ui.control.Label
        play_Waterfall_DecimationLabel  matlab.ui.control.Label
        play_Waterfall_Fcn              matlab.ui.control.DropDown
        play_Waterfall_FcnLabel         matlab.ui.control.Label
        play_ControlPanelLabel          matlab.ui.control.Label
        play_GeneralPanel               matlab.ui.container.Panel
        play_OthersGrid                 matlab.ui.container.GridLayout
        play_LimitsRefresh              matlab.ui.control.Image
        play_Limits_yLim2               matlab.ui.control.Spinner
        play_Limits_yLimLabel           matlab.ui.control.Label
        play_Limits_yLim1               matlab.ui.control.Spinner
        play_Limits_xLim2               matlab.ui.control.Spinner
        play_Limits_xLimLabel           matlab.ui.control.Label
        play_Limits_xLim1               matlab.ui.control.Spinner
        play_LimitsPanelLabel           matlab.ui.control.Label
        play_LayoutRatio                matlab.ui.control.DropDown
        play_LayoutRatioLabel           matlab.ui.control.Label
        play_GeneralPanelLabel          matlab.ui.control.Label
        LeftPanel                       matlab.ui.container.GridLayout
        FlowAttributesPanelRight        matlab.ui.control.Image
        FlowAttributesPanelLeft         matlab.ui.control.Image
        FlowAttributesPanelIndex        matlab.ui.control.Label
        SpectrumFlow                    matlab.ui.control.DropDown
        SelectedFlowPanel               matlab.ui.container.Panel
        SelectedFlowGrid                matlab.ui.container.GridLayout
        SelectedFlowMetadata_2          matlab.ui.control.Label
        SelectedFlowPlotBtn_3           matlab.ui.control.Image
        SelectedFlowPlotBtn_2           matlab.ui.control.Image
        DETECOECLASSIFICAODEEMISSESLabel  matlab.ui.control.Label
        OCUPAOLabel                     matlab.ui.control.Label
        SelectedFlowAlgorithms          matlab.ui.control.Label
        SelectedFlowMetadata            matlab.ui.control.Label
        SelectedFlowPlot                matlab.ui.control.Label
        SelectedFlowEmissionsBtn_2      matlab.ui.control.Image
        SelectedFlowPlotBtn             matlab.ui.control.Image
        SelectedFlowEmissions           matlab.ui.control.ListBox
        SelectedFlowEmissionsBtn        matlab.ui.control.Image
        SelectedFlowEmissionsLabel      matlab.ui.control.Label
        SelectedFlowChannel             matlab.ui.control.ListBox
        SelectedFlowChannelLabel        matlab.ui.control.Label
        SelectedFlowPanelLabel          matlab.ui.control.Label
        AxesToolbar                     matlab.ui.container.GridLayout
        axesTool_RestoreView_2          matlab.ui.control.Image
        axesTool_Pan                    matlab.ui.control.Image
        axesTool_DataTip                matlab.ui.control.Image
        axesTool_Waterfall              matlab.ui.control.Image
        axesTool_Occupancy              matlab.ui.control.Image
        axesTool_Persistance            matlab.ui.control.Image
        axesTool_MaxHold                matlab.ui.control.Image
        axesTool_Average                matlab.ui.control.Image
        axesTool_MinHold                matlab.ui.control.Image
        PlotPanel                       matlab.ui.container.Panel
        Toolbar                         matlab.ui.container.GridLayout
        tool_LayoutRight                matlab.ui.control.Image
        tool_FiscalizaUpdate            matlab.ui.control.Image
        tool_ReportGenerator            matlab.ui.control.Image
        tool_TimestampLabel             matlab.ui.control.Label
        tool_TimestampSlider            matlab.ui.control.Slider
        tool_LoopControl                matlab.ui.control.Image
        tool_Play                       matlab.ui.control.Image
        tool_LayoutLeft                 matlab.ui.control.Image
        ContextMenu                     matlab.ui.container.ContextMenu
        contextmenu_del                 matlab.ui.container.Menu
        contextmenu_delAll              matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'PLAYBACK'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog

        SubTabGroup = struct('Children', -1, 'UserData', [])

        UIAxes1
        UIAxes2
        UIAxes3
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
        )
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
                            case 'onSpecDataRead'
                                applyInitialLayout(app)                                

                            otherwise
                                error('auxApp:winPlayback:UnexpectedCall', 'Unexpected call "%s"', eventName)
                        end

                    otherwise
                        error('auxApp:winPlayback:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
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

            appName = class.Constants.appName;
            switch tabIndex
                case 1 % PLAYBACK
                    elToModify = {
                        app.AxesToolbar;
                        ... % app.PlotPanel;
                        app.SpectrumFlow;
                        app.SelectedFlowPanelLabel;
                        app.SelectedFlowMetadata;
                        app.SelectedFlowAlgorithms;
                        app.SelectedFlowMetadata_2;
                        app.SelectedFlowPlot
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SpectrumFlow.UserData.id, 'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', 'rgba(183, 49, 44, 0.75)'), ...
                            struct('appName', appName, 'dataTag', app.SelectedFlowPanelLabel.UserData.id, 'styleImportant', struct('borderLeft', '3px solid #b7312c', 'paddingLeft', '8px')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.SelectedFlowMetadata,   appName, struct('class', 'textview--borderless'));
                        ui.TextView.startup(app.jsBackDoor, app.SelectedFlowAlgorithms, appName);
                        ui.TextView.startup(app.jsBackDoor, app.SelectedFlowMetadata_2, appName);
                        ui.TextView.startup(app.jsBackDoor, app.SelectedFlowPlot,       appName, struct('class', 'textview--borderless'));
                    catch
                    end
                    
                    addStyle(app.SpectrumFlow, uistyle('Interpreter', 'html'))

                    app.FlowAttributesPanelIndex.UserData.index = 1;

                otherwise
                     % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % ...
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            % ...
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            if ~isempty(app.mainApp.specData)
                util.layoutDropDownTreeStyle(app.SpectrumFlow, app.mainApp.specData)
                updateAttributesPanel(app)
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updateAttributesPanel(app)
            specDataIdx = findSpecDataIndex(app);
            app.SelectedFlowMetadata.Text = util.HtmlTextGenerator.Thread(app.mainApp.specData, specDataIdx);
        end

        %-----------------------------------------------------------------%
        function idx = findSpecDataIndex(app)
            idx = app.SpectrumFlow.Value;
            if ~isempty(idx) && ~isnumeric(idx)
                [~, idx] = ismember(app.SpectrumFlow.Value, app.SpectrumFlow.Items);
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, filterTable, rfDataHubAnnotation)
            
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

        % Callback function
        function SubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Image clicked function: tool_LayoutLeft, tool_LayoutRight
        function tool_LayoutLeftImageClicked(app, event)
            
            switch event.Source
                case app.tool_LayoutLeft
                    if app.Document.ColumnWidth{1}
                        app.Document.ColumnWidth(1:2) = {0,0};
                    else
                        app.Document.ColumnWidth(1:2) = {320,10};
                    end

                case app.tool_LayoutRight
                    if app.Document.ColumnWidth{end}
                        app.Document.ColumnWidth(end-1:end) = {0,0};
                    else
                        app.Document.ColumnWidth(end-1:end) = {10,232};
                    end
            end

        end

        % Value changed function: SpectrumFlow
        function onSpectrumFlowValueChanged(app, event)

            updateAttributesPanel(app)
            
        end

        % Image clicked function: FlowAttributesPanelLeft, 
        % ...and 1 other component
        function ImageClicked(app, event)
            
            numPanels = 4;

            panelSubtitles = {'Metadados', 'Algoritmos', 'Canais e emissões', 'Sumário de análise'};
            panelBtnStatus = [false true; true true; true true; true false];
            columnWidths = {
                {'1x',0,0,0,0,0,0,0,0,0,0};
                {0,10,'1x',18,10,0,0,0,0,0,0};
                {0,0,0,0,10,'1x',18,5,18,10,0};
                {0,0,0,0,0,0,0,0,0,0,'1x'}
            };

            currentIndex = app.FlowAttributesPanelIndex.UserData.index;
            
            switch event.Source
                case app.FlowAttributesPanelLeft
                    step = -1;
                case app.FlowAttributesPanelRight
                    step = 1;
            end

            currentIndex = mod(currentIndex - 1 + step, numPanels) + 1;
            
            app.FlowAttributesPanelLeft.Enable  = panelBtnStatus(currentIndex, 1);
            app.FlowAttributesPanelRight.Enable = panelBtnStatus(currentIndex, 2);
            app.FlowAttributesPanelIndex.Text   = sprintf('%d/%d', currentIndex, numPanels);
            app.SelectedFlowGrid.ColumnWidth    = columnWidths{currentIndex};
            app.SelectedFlowPanelLabel.Text     = replace(app.SelectedFlowPanelLabel.Text, extractBetween(app.SelectedFlowPanelLabel.Text, '<i>', '</i>'), panelSubtitles{currentIndex});
            app.FlowAttributesPanelIndex.UserData.index = currentIndex;

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
                app.UIFigure.Position = [100 100 1244 724];
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
            app.Toolbar.ColumnWidth = {22, 22, 22, 248, '1x', 24, 24, 24, 24, 24, 24, '1x', 167, 22, 22, 22, 22, 22};
            app.Toolbar.RowHeight = {4, 17, 3};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [5 5 5 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];

            % Create tool_LayoutLeft
            app.tool_LayoutLeft = uiimage(app.Toolbar);
            app.tool_LayoutLeft.ScaleMethod = 'none';
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @tool_LayoutLeftImageClicked, true);
            app.tool_LayoutLeft.Layout.Row = 2;
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Play
            app.tool_Play = uiimage(app.Toolbar);
            app.tool_Play.Tooltip = {'Playback'};
            app.tool_Play.Layout.Row = 2;
            app.tool_Play.Layout.Column = 2;
            app.tool_Play.ImageSource = 'play_32.png';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.Tag = 'loop';
            app.tool_LoopControl.Tooltip = {'Loop do playback'};
            app.tool_LoopControl.Layout.Row = 2;
            app.tool_LoopControl.Layout.Column = 3;
            app.tool_LoopControl.ImageSource = 'playbackLoop_32Blue.png';

            % Create tool_TimestampSlider
            app.tool_TimestampSlider = uislider(app.Toolbar);
            app.tool_TimestampSlider.MajorTicks = [0 50 100];
            app.tool_TimestampSlider.MinorTicks = [0 2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30 32.5 35 37.5 40 42.5 45 47.5 50 52.5 55 57.5 60 62.5 65 67.5 70 72.5 75 77.5 80 82.5 85 87.5 90 92.5 95 97.5 100];
            app.tool_TimestampSlider.FontSize = 8;
            app.tool_TimestampSlider.Layout.Row = 2;
            app.tool_TimestampSlider.Layout.Column = 4;

            % Create tool_TimestampLabel
            app.tool_TimestampLabel = uilabel(app.Toolbar);
            app.tool_TimestampLabel.WordWrap = 'on';
            app.tool_TimestampLabel.FontSize = 10;
            app.tool_TimestampLabel.Layout.Row = [1 3];
            app.tool_TimestampLabel.Layout.Column = 5;
            app.tool_TimestampLabel.Text = {'22 de 328 '; '22/02/2022 08:00:00 '};

            % Create tool_ReportGenerator
            app.tool_ReportGenerator = uiimage(app.Toolbar);
            app.tool_ReportGenerator.Enable = 'off';
            app.tool_ReportGenerator.Tooltip = {'Gera relatório'};
            app.tool_ReportGenerator.Layout.Row = 2;
            app.tool_ReportGenerator.Layout.Column = 16;
            app.tool_ReportGenerator.ImageSource = 'Publish_HTML_16.png';

            % Create tool_FiscalizaUpdate
            app.tool_FiscalizaUpdate = uiimage(app.Toolbar);
            app.tool_FiscalizaUpdate.Tooltip = {'Upload relatório'};
            app.tool_FiscalizaUpdate.Layout.Row = 2;
            app.tool_FiscalizaUpdate.Layout.Column = 17;
            app.tool_FiscalizaUpdate.ImageSource = 'Up_24.png';

            % Create tool_LayoutRight
            app.tool_LayoutRight = uiimage(app.Toolbar);
            app.tool_LayoutRight.ScaleMethod = 'none';
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @tool_LayoutLeftImageClicked, true);
            app.tool_LayoutRight.Layout.Row = 2;
            app.tool_LayoutRight.Layout.Column = 18;
            app.tool_LayoutRight.ImageSource = 'layout-sidebar-right.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {320, 10, 5, 198, '1x', 10, 232};
            app.Document.RowHeight = {24, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [2 3];
            app.Document.BackgroundColor = [1 1 1];

            % Create PlotPanel
            app.PlotPanel = uipanel(app.Document);
            app.PlotPanel.AutoResizeChildren = 'off';
            app.PlotPanel.BorderType = 'none';
            app.PlotPanel.BackgroundColor = [0 0 0];
            app.PlotPanel.Layout.Row = [1 2];
            app.PlotPanel.Layout.Column = [3 5];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {'1x', 22, 22, 22, 22, 22, 22, 22, 22, 22, '1x'};
            app.AxesToolbar.RowHeight = {'1x'};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [0 2 0 2];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 4;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_MinHold
            app.axesTool_MinHold = uiimage(app.AxesToolbar);
            app.axesTool_MinHold.Tag = 'MinHold';
            app.axesTool_MinHold.Tooltip = {'MinHold'};
            app.axesTool_MinHold.Layout.Row = 1;
            app.axesTool_MinHold.Layout.Column = 5;
            app.axesTool_MinHold.ImageSource = 'MinHold_32.png';

            % Create axesTool_Average
            app.axesTool_Average = uiimage(app.AxesToolbar);
            app.axesTool_Average.Tag = 'Average';
            app.axesTool_Average.Tooltip = {'Média'};
            app.axesTool_Average.Layout.Row = 1;
            app.axesTool_Average.Layout.Column = 6;
            app.axesTool_Average.ImageSource = 'Average_32.png';

            % Create axesTool_MaxHold
            app.axesTool_MaxHold = uiimage(app.AxesToolbar);
            app.axesTool_MaxHold.Tag = 'MaxHold';
            app.axesTool_MaxHold.Tooltip = {'MaxHold'};
            app.axesTool_MaxHold.Layout.Row = 1;
            app.axesTool_MaxHold.Layout.Column = 7;
            app.axesTool_MaxHold.ImageSource = 'MaxHold_32.png';

            % Create axesTool_Persistance
            app.axesTool_Persistance = uiimage(app.AxesToolbar);
            app.axesTool_Persistance.Tag = 'Persistance';
            app.axesTool_Persistance.Tooltip = {'Persistência'};
            app.axesTool_Persistance.Layout.Row = 1;
            app.axesTool_Persistance.Layout.Column = 8;
            app.axesTool_Persistance.ImageSource = 'Persistance_36.png';

            % Create axesTool_Occupancy
            app.axesTool_Occupancy = uiimage(app.AxesToolbar);
            app.axesTool_Occupancy.Tag = 'Ocuppancy';
            app.axesTool_Occupancy.Tooltip = {'Ocupação'};
            app.axesTool_Occupancy.Layout.Row = 1;
            app.axesTool_Occupancy.Layout.Column = 9;
            app.axesTool_Occupancy.ImageSource = 'Occupancy_32Gray.png';

            % Create axesTool_Waterfall
            app.axesTool_Waterfall = uiimage(app.AxesToolbar);
            app.axesTool_Waterfall.ScaleMethod = 'none';
            app.axesTool_Waterfall.Tag = 'Waterfall';
            app.axesTool_Waterfall.Tooltip = {'Waterfall'};
            app.axesTool_Waterfall.Layout.Row = 1;
            app.axesTool_Waterfall.Layout.Column = 10;
            app.axesTool_Waterfall.HorizontalAlignment = 'left';
            app.axesTool_Waterfall.VerticalAlignment = 'bottom';
            app.axesTool_Waterfall.ImageSource = 'Waterfall_24.png';

            % Create axesTool_DataTip
            app.axesTool_DataTip = uiimage(app.AxesToolbar);
            app.axesTool_DataTip.Enable = 'off';
            app.axesTool_DataTip.Tooltip = {'DataCursorMode'; '(restrito à Waterfall:Image)'};
            app.axesTool_DataTip.Layout.Row = 1;
            app.axesTool_DataTip.Layout.Column = 4;
            app.axesTool_DataTip.ImageSource = 'DataTip_22.png';

            % Create axesTool_Pan
            app.axesTool_Pan = uiimage(app.AxesToolbar);
            app.axesTool_Pan.Tooltip = {'Pan'};
            app.axesTool_Pan.Layout.Row = 1;
            app.axesTool_Pan.Layout.Column = 3;
            app.axesTool_Pan.ImageSource = 'Pan_32.png';

            % Create axesTool_RestoreView_2
            app.axesTool_RestoreView_2 = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView_2.ScaleMethod = 'none';
            app.axesTool_RestoreView_2.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView_2.Layout.Row = 1;
            app.axesTool_RestoreView_2.Layout.Column = 2;
            app.axesTool_RestoreView_2.ImageSource = 'Home_18.png';

            % Create LeftPanel
            app.LeftPanel = uigridlayout(app.Document);
            app.LeftPanel.ColumnWidth = {'1x', 18, 10, 18};
            app.LeftPanel.RowHeight = {44, 30, '1x'};
            app.LeftPanel.ColumnSpacing = 5;
            app.LeftPanel.RowSpacing = 5;
            app.LeftPanel.Padding = [0 0 0 0];
            app.LeftPanel.Layout.Row = [1 2];
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.BackgroundColor = [1 1 1];

            % Create SelectedFlowPanelLabel
            app.SelectedFlowPanelLabel = uilabel(app.LeftPanel);
            app.SelectedFlowPanelLabel.FontSize = 10;
            app.SelectedFlowPanelLabel.Layout.Row = 2;
            app.SelectedFlowPanelLabel.Layout.Column = 1;
            app.SelectedFlowPanelLabel.Interpreter = 'html';
            app.SelectedFlowPanelLabel.Text = 'ATRIBUTOS DO FLUXO ESPECTRAL<br><font style="font-size: 11px;"><i>Metadados</i></font>';

            % Create SelectedFlowPanel
            app.SelectedFlowPanel = uipanel(app.LeftPanel);
            app.SelectedFlowPanel.AutoResizeChildren = 'off';
            app.SelectedFlowPanel.Layout.Row = 3;
            app.SelectedFlowPanel.Layout.Column = [1 4];

            % Create SelectedFlowGrid
            app.SelectedFlowGrid = uigridlayout(app.SelectedFlowPanel);
            app.SelectedFlowGrid.ColumnWidth = {'1x', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            app.SelectedFlowGrid.RowHeight = {5, 22, 5, '1x', 22, 5, '1x', '1x', 10};
            app.SelectedFlowGrid.ColumnSpacing = 0;
            app.SelectedFlowGrid.RowSpacing = 0;
            app.SelectedFlowGrid.Padding = [0 0 0 0];
            app.SelectedFlowGrid.BackgroundColor = [1 1 1];

            % Create SelectedFlowChannelLabel
            app.SelectedFlowChannelLabel = uilabel(app.SelectedFlowGrid);
            app.SelectedFlowChannelLabel.VerticalAlignment = 'bottom';
            app.SelectedFlowChannelLabel.FontSize = 10;
            app.SelectedFlowChannelLabel.Layout.Row = 2;
            app.SelectedFlowChannelLabel.Layout.Column = 6;
            app.SelectedFlowChannelLabel.Text = 'CANALIZAÇÃO:';

            % Create SelectedFlowChannel
            app.SelectedFlowChannel = uilistbox(app.SelectedFlowGrid);
            app.SelectedFlowChannel.Items = {};
            app.SelectedFlowChannel.FontSize = 11;
            app.SelectedFlowChannel.Layout.Row = 4;
            app.SelectedFlowChannel.Layout.Column = [6 9];
            app.SelectedFlowChannel.Value = {};

            % Create SelectedFlowEmissionsLabel
            app.SelectedFlowEmissionsLabel = uilabel(app.SelectedFlowGrid);
            app.SelectedFlowEmissionsLabel.VerticalAlignment = 'bottom';
            app.SelectedFlowEmissionsLabel.FontSize = 10;
            app.SelectedFlowEmissionsLabel.Layout.Row = 5;
            app.SelectedFlowEmissionsLabel.Layout.Column = 6;
            app.SelectedFlowEmissionsLabel.Text = 'LISTA DE EMISSÕES:';

            % Create SelectedFlowEmissionsBtn
            app.SelectedFlowEmissionsBtn = uiimage(app.SelectedFlowGrid);
            app.SelectedFlowEmissionsBtn.Layout.Row = 2;
            app.SelectedFlowEmissionsBtn.Layout.Column = 9;
            app.SelectedFlowEmissionsBtn.VerticalAlignment = 'bottom';
            app.SelectedFlowEmissionsBtn.ImageSource = 'Edit_32.png';

            % Create SelectedFlowEmissions
            app.SelectedFlowEmissions = uilistbox(app.SelectedFlowGrid);
            app.SelectedFlowEmissions.Items = {};
            app.SelectedFlowEmissions.FontSize = 11;
            app.SelectedFlowEmissions.Layout.Row = [7 8];
            app.SelectedFlowEmissions.Layout.Column = [6 9];
            app.SelectedFlowEmissions.Value = {};

            % Create SelectedFlowPlotBtn
            app.SelectedFlowPlotBtn = uiimage(app.SelectedFlowGrid);
            app.SelectedFlowPlotBtn.Layout.Row = 5;
            app.SelectedFlowPlotBtn.Layout.Column = 9;
            app.SelectedFlowPlotBtn.VerticalAlignment = 'bottom';
            app.SelectedFlowPlotBtn.ImageSource = 'Edit_32.png';

            % Create SelectedFlowEmissionsBtn_2
            app.SelectedFlowEmissionsBtn_2 = uiimage(app.SelectedFlowGrid);
            app.SelectedFlowEmissionsBtn_2.ScaleMethod = 'none';
            app.SelectedFlowEmissionsBtn_2.Layout.Row = 5;
            app.SelectedFlowEmissionsBtn_2.Layout.Column = 7;
            app.SelectedFlowEmissionsBtn_2.VerticalAlignment = 'bottom';
            app.SelectedFlowEmissionsBtn_2.ImageSource = 'search-sparkle.svg';

            % Create SelectedFlowPlot
            app.SelectedFlowPlot = uilabel(app.SelectedFlowGrid);
            app.SelectedFlowPlot.VerticalAlignment = 'top';
            app.SelectedFlowPlot.WordWrap = 'on';
            app.SelectedFlowPlot.FontSize = 11;
            app.SelectedFlowPlot.Layout.Row = [2 8];
            app.SelectedFlowPlot.Layout.Column = 11;
            app.SelectedFlowPlot.Interpreter = 'html';
            app.SelectedFlowPlot.Text = {'<p style="margin: 10px; word-break: normal;">Monitoração TERRESTRE que durou 00:22:22, coletando 200 varreduras, com revisita média igual a 23 amostra/seg.'; ''; 'Características da coleta: ClearWrite...'; ''; 'Piso de ruído alto...'; ''; 'Identificadas 17 emissões. 12 das 17 com ocupação superior a 85%.'; ''; 'Das 17 emissões, 14 delas parecem terem sido geradas por estações licenciadas. As outras 3 são desconhecidas, e ainda dependem de análise pelo fiscal.</p>'};

            % Create SelectedFlowMetadata
            app.SelectedFlowMetadata = uilabel(app.SelectedFlowGrid);
            app.SelectedFlowMetadata.VerticalAlignment = 'top';
            app.SelectedFlowMetadata.WordWrap = 'on';
            app.SelectedFlowMetadata.FontSize = 11;
            app.SelectedFlowMetadata.Layout.Row = [2 8];
            app.SelectedFlowMetadata.Layout.Column = 1;
            app.SelectedFlowMetadata.Interpreter = 'html';
            app.SelectedFlowMetadata.Text = '';

            % Create SelectedFlowAlgorithms
            app.SelectedFlowAlgorithms = uilabel(app.SelectedFlowGrid);
            app.SelectedFlowAlgorithms.BackgroundColor = [0.0588 1 1];
            app.SelectedFlowAlgorithms.VerticalAlignment = 'top';
            app.SelectedFlowAlgorithms.WordWrap = 'on';
            app.SelectedFlowAlgorithms.FontSize = 11;
            app.SelectedFlowAlgorithms.Layout.Row = 4;
            app.SelectedFlowAlgorithms.Layout.Column = [3 4];
            app.SelectedFlowAlgorithms.Interpreter = 'html';
            app.SelectedFlowAlgorithms.Text = {'<p style="margin: 5px; word-break: normal;">Ocupação: deijdeijddie jdeijdiejjdji'; 'Detecção assistida: deokdekodkoe dedeokkodeo'; 'Detecção automática: dejidejiejide jidejidejieji'; 'Classificação: deojidejedji dedeijdejiijde</p>'};

            % Create OCUPAOLabel
            app.OCUPAOLabel = uilabel(app.SelectedFlowGrid);
            app.OCUPAOLabel.VerticalAlignment = 'bottom';
            app.OCUPAOLabel.FontSize = 10;
            app.OCUPAOLabel.Layout.Row = 2;
            app.OCUPAOLabel.Layout.Column = 3;
            app.OCUPAOLabel.Text = 'OCUPAÇÃO:';

            % Create DETECOECLASSIFICAODEEMISSESLabel
            app.DETECOECLASSIFICAODEEMISSESLabel = uilabel(app.SelectedFlowGrid);
            app.DETECOECLASSIFICAODEEMISSESLabel.VerticalAlignment = 'bottom';
            app.DETECOECLASSIFICAODEEMISSESLabel.FontSize = 10;
            app.DETECOECLASSIFICAODEEMISSESLabel.Layout.Row = 5;
            app.DETECOECLASSIFICAODEEMISSESLabel.Layout.Column = 3;
            app.DETECOECLASSIFICAODEEMISSESLabel.Text = 'DETECÇÃO E CLASSIFICAÇÃO DE EMISSÕES:';

            % Create SelectedFlowPlotBtn_2
            app.SelectedFlowPlotBtn_2 = uiimage(app.SelectedFlowGrid);
            app.SelectedFlowPlotBtn_2.Layout.Row = 5;
            app.SelectedFlowPlotBtn_2.Layout.Column = 4;
            app.SelectedFlowPlotBtn_2.VerticalAlignment = 'bottom';
            app.SelectedFlowPlotBtn_2.ImageSource = 'Edit_32.png';

            % Create SelectedFlowPlotBtn_3
            app.SelectedFlowPlotBtn_3 = uiimage(app.SelectedFlowGrid);
            app.SelectedFlowPlotBtn_3.Layout.Row = 2;
            app.SelectedFlowPlotBtn_3.Layout.Column = 4;
            app.SelectedFlowPlotBtn_3.VerticalAlignment = 'bottom';
            app.SelectedFlowPlotBtn_3.ImageSource = 'Edit_32.png';

            % Create SelectedFlowMetadata_2
            app.SelectedFlowMetadata_2 = uilabel(app.SelectedFlowGrid);
            app.SelectedFlowMetadata_2.BackgroundColor = [0.0588 1 1];
            app.SelectedFlowMetadata_2.VerticalAlignment = 'top';
            app.SelectedFlowMetadata_2.WordWrap = 'on';
            app.SelectedFlowMetadata_2.FontSize = 11;
            app.SelectedFlowMetadata_2.Layout.Row = [7 8];
            app.SelectedFlowMetadata_2.Layout.Column = [3 4];
            app.SelectedFlowMetadata_2.Interpreter = 'html';
            app.SelectedFlowMetadata_2.Text = 'METADADOS';

            % Create SpectrumFlow
            app.SpectrumFlow = uidropdown(app.LeftPanel);
            app.SpectrumFlow.Items = {''};
            app.SpectrumFlow.ValueChangedFcn = createCallbackFcn(app, @onSpectrumFlowValueChanged, true);
            app.SpectrumFlow.FontSize = 11;
            app.SpectrumFlow.FontColor = [1 1 1];
            app.SpectrumFlow.BackgroundColor = [0.7176 0.1922 0.1725];
            app.SpectrumFlow.Layout.Row = 1;
            app.SpectrumFlow.Layout.Column = [1 4];
            app.SpectrumFlow.Value = '';

            % Create FlowAttributesPanelIndex
            app.FlowAttributesPanelIndex = uilabel(app.LeftPanel);
            app.FlowAttributesPanelIndex.HorizontalAlignment = 'center';
            app.FlowAttributesPanelIndex.FontSize = 10;
            app.FlowAttributesPanelIndex.FontColor = [0.502 0.502 0.502];
            app.FlowAttributesPanelIndex.Layout.Row = 2;
            app.FlowAttributesPanelIndex.Layout.Column = [2 4];
            app.FlowAttributesPanelIndex.Text = '1/4';

            % Create FlowAttributesPanelLeft
            app.FlowAttributesPanelLeft = uiimage(app.LeftPanel);
            app.FlowAttributesPanelLeft.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.FlowAttributesPanelLeft.Enable = 'off';
            app.FlowAttributesPanelLeft.Layout.Row = 2;
            app.FlowAttributesPanelLeft.Layout.Column = 2;
            app.FlowAttributesPanelLeft.ImageSource = 'triangle-left.svg';

            % Create FlowAttributesPanelRight
            app.FlowAttributesPanelRight = uiimage(app.LeftPanel);
            app.FlowAttributesPanelRight.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.FlowAttributesPanelRight.Layout.Row = 2;
            app.FlowAttributesPanelRight.Layout.Column = 4;
            app.FlowAttributesPanelRight.ImageSource = 'triangle-right.svg';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.Document);
            app.SubGrid1.ColumnWidth = {18, '1x'};
            app.SubGrid1.RowHeight = {22, 124, 22, 168, 22, '1x'};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.Padding = [0 0 0 0];
            app.SubGrid1.Layout.Row = [1 2];
            app.SubGrid1.Layout.Column = 7;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create play_GeneralPanelLabel
            app.play_GeneralPanelLabel = uilabel(app.SubGrid1);
            app.play_GeneralPanelLabel.VerticalAlignment = 'bottom';
            app.play_GeneralPanelLabel.FontSize = 10;
            app.play_GeneralPanelLabel.Layout.Row = 1;
            app.play_GeneralPanelLabel.Layout.Column = 2;
            app.play_GeneralPanelLabel.Text = 'EIXOS GRÁFICOS';

            % Create play_GeneralPanel
            app.play_GeneralPanel = uipanel(app.SubGrid1);
            app.play_GeneralPanel.AutoResizeChildren = 'off';
            app.play_GeneralPanel.BackgroundColor = [1 1 1];
            app.play_GeneralPanel.Layout.Row = 2;
            app.play_GeneralPanel.Layout.Column = [1 2];

            % Create play_OthersGrid
            app.play_OthersGrid = uigridlayout(app.play_GeneralPanel);
            app.play_OthersGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.play_OthersGrid.RowHeight = {22, 20, 22, 22};
            app.play_OthersGrid.RowSpacing = 5;
            app.play_OthersGrid.BackgroundColor = [1 1 1];

            % Create play_LayoutRatioLabel
            app.play_LayoutRatioLabel = uilabel(app.play_OthersGrid);
            app.play_LayoutRatioLabel.FontSize = 11;
            app.play_LayoutRatioLabel.Layout.Row = 1;
            app.play_LayoutRatioLabel.Layout.Column = [1 3];
            app.play_LayoutRatioLabel.Text = 'Razão de aspecto:';

            % Create play_LayoutRatio
            app.play_LayoutRatio = uidropdown(app.play_OthersGrid);
            app.play_LayoutRatio.Items = {'1:0:0'};
            app.play_LayoutRatio.FontSize = 11;
            app.play_LayoutRatio.BackgroundColor = [1 1 1];
            app.play_LayoutRatio.Layout.Row = 1;
            app.play_LayoutRatio.Layout.Column = [4 5];
            app.play_LayoutRatio.Value = '1:0:0';

            % Create play_LimitsPanelLabel
            app.play_LimitsPanelLabel = uilabel(app.play_OthersGrid);
            app.play_LimitsPanelLabel.VerticalAlignment = 'bottom';
            app.play_LimitsPanelLabel.FontSize = 11;
            app.play_LimitsPanelLabel.Layout.Row = 2;
            app.play_LimitsPanelLabel.Layout.Column = [1 4];
            app.play_LimitsPanelLabel.Text = 'Limites de frequência e nível:';

            % Create play_Limits_xLim1
            app.play_Limits_xLim1 = uispinner(app.play_OthersGrid);
            app.play_Limits_xLim1.ValueDisplayFormat = '%.3f';
            app.play_Limits_xLim1.Tag = 'FreqStart';
            app.play_Limits_xLim1.FontSize = 11;
            app.play_Limits_xLim1.Tooltip = {''};
            app.play_Limits_xLim1.Layout.Row = 3;
            app.play_Limits_xLim1.Layout.Column = 1;

            % Create play_Limits_xLimLabel
            app.play_Limits_xLimLabel = uilabel(app.play_OthersGrid);
            app.play_Limits_xLimLabel.HorizontalAlignment = 'center';
            app.play_Limits_xLimLabel.FontSize = 10;
            app.play_Limits_xLimLabel.Layout.Row = 3;
            app.play_Limits_xLimLabel.Layout.Column = [1 5];
            app.play_Limits_xLimLabel.Text = 'MHz  ';

            % Create play_Limits_xLim2
            app.play_Limits_xLim2 = uispinner(app.play_OthersGrid);
            app.play_Limits_xLim2.ValueDisplayFormat = '%.3f';
            app.play_Limits_xLim2.Tag = 'FreqStop';
            app.play_Limits_xLim2.FontSize = 11;
            app.play_Limits_xLim2.Tooltip = {''};
            app.play_Limits_xLim2.Layout.Row = 3;
            app.play_Limits_xLim2.Layout.Column = [4 5];

            % Create play_Limits_yLim1
            app.play_Limits_yLim1 = uispinner(app.play_OthersGrid);
            app.play_Limits_yLim1.Step = 5;
            app.play_Limits_yLim1.ValueDisplayFormat = '%.1f';
            app.play_Limits_yLim1.Tag = 'MinLevel';
            app.play_Limits_yLim1.FontSize = 11;
            app.play_Limits_yLim1.Tooltip = {''};
            app.play_Limits_yLim1.Layout.Row = 4;
            app.play_Limits_yLim1.Layout.Column = 1;

            % Create play_Limits_yLimLabel
            app.play_Limits_yLimLabel = uilabel(app.play_OthersGrid);
            app.play_Limits_yLimLabel.HorizontalAlignment = 'center';
            app.play_Limits_yLimLabel.FontSize = 10;
            app.play_Limits_yLimLabel.Layout.Row = 4;
            app.play_Limits_yLimLabel.Layout.Column = [1 5];
            app.play_Limits_yLimLabel.Text = 'dB  ';

            % Create play_Limits_yLim2
            app.play_Limits_yLim2 = uispinner(app.play_OthersGrid);
            app.play_Limits_yLim2.Step = 5;
            app.play_Limits_yLim2.ValueDisplayFormat = '%.1f';
            app.play_Limits_yLim2.Tag = 'MaxLevel';
            app.play_Limits_yLim2.FontSize = 11;
            app.play_Limits_yLim2.Tooltip = {''};
            app.play_Limits_yLim2.Layout.Row = 4;
            app.play_Limits_yLim2.Layout.Column = [4 5];

            % Create play_LimitsRefresh
            app.play_LimitsRefresh = uiimage(app.play_OthersGrid);
            app.play_LimitsRefresh.ScaleMethod = 'none';
            app.play_LimitsRefresh.Tooltip = {'Retorna à configuração padrão'};
            app.play_LimitsRefresh.Layout.Row = 2;
            app.play_LimitsRefresh.Layout.Column = 5;
            app.play_LimitsRefresh.HorizontalAlignment = 'right';
            app.play_LimitsRefresh.VerticalAlignment = 'bottom';
            app.play_LimitsRefresh.ImageSource = 'Refresh_18.png';

            % Create play_ControlPanelLabel
            app.play_ControlPanelLabel = uilabel(app.SubGrid1);
            app.play_ControlPanelLabel.VerticalAlignment = 'bottom';
            app.play_ControlPanelLabel.FontSize = 10;
            app.play_ControlPanelLabel.Layout.Row = 3;
            app.play_ControlPanelLabel.Layout.Column = 2;
            app.play_ControlPanelLabel.Text = 'PERSISTÊNCIA';

            % Create play_Waterfall_Panel
            app.play_Waterfall_Panel = uipanel(app.SubGrid1);
            app.play_Waterfall_Panel.AutoResizeChildren = 'off';
            app.play_Waterfall_Panel.Layout.Row = 6;
            app.play_Waterfall_Panel.Layout.Column = [1 2];

            % Create play_WaterFallGrid
            app.play_WaterFallGrid = uigridlayout(app.play_Waterfall_Panel);
            app.play_WaterFallGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.play_WaterFallGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.play_WaterFallGrid.RowSpacing = 5;
            app.play_WaterFallGrid.Padding = [10 10 10 5];
            app.play_WaterFallGrid.BackgroundColor = [1 1 1];

            % Create play_Waterfall_FcnLabel
            app.play_Waterfall_FcnLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_FcnLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_FcnLabel.WordWrap = 'on';
            app.play_Waterfall_FcnLabel.FontSize = 11;
            app.play_Waterfall_FcnLabel.Layout.Row = 1;
            app.play_Waterfall_FcnLabel.Layout.Column = [1 3];
            app.play_Waterfall_FcnLabel.Text = 'Renderização:';

            % Create play_Waterfall_Fcn
            app.play_Waterfall_Fcn = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Fcn.Items = {'image', 'mesh'};
            app.play_Waterfall_Fcn.FontSize = 11;
            app.play_Waterfall_Fcn.BackgroundColor = [1 1 1];
            app.play_Waterfall_Fcn.Layout.Row = 2;
            app.play_Waterfall_Fcn.Layout.Column = [1 2];
            app.play_Waterfall_Fcn.Value = 'image';

            % Create play_Waterfall_DecimationLabel
            app.play_Waterfall_DecimationLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_DecimationLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_DecimationLabel.FontSize = 11;
            app.play_Waterfall_DecimationLabel.Layout.Row = 1;
            app.play_Waterfall_DecimationLabel.Layout.Column = [3 4];
            app.play_Waterfall_DecimationLabel.Text = 'Decimação:';

            % Create play_Waterfall_DecimationValue
            app.play_Waterfall_DecimationValue = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_DecimationValue.HorizontalAlignment = 'right';
            app.play_Waterfall_DecimationValue.VerticalAlignment = 'bottom';
            app.play_Waterfall_DecimationValue.FontSize = 11;
            app.play_Waterfall_DecimationValue.FontColor = [0.8 0.8 0.8];
            app.play_Waterfall_DecimationValue.Layout.Row = 1;
            app.play_Waterfall_DecimationValue.Layout.Column = [3 5];
            app.play_Waterfall_DecimationValue.Text = 'auto';

            % Create play_Waterfall_Decimation
            app.play_Waterfall_Decimation = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Decimation.Items = {'auto', '1', '2', '4', '8', '16', '32', '64', '128', '256'};
            app.play_Waterfall_Decimation.Enable = 'off';
            app.play_Waterfall_Decimation.FontSize = 11;
            app.play_Waterfall_Decimation.BackgroundColor = [1 1 1];
            app.play_Waterfall_Decimation.Layout.Row = 2;
            app.play_Waterfall_Decimation.Layout.Column = [3 5];
            app.play_Waterfall_Decimation.Value = 'auto';

            % Create play_Waterfall_ColormapLabel
            app.play_Waterfall_ColormapLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_ColormapLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_ColormapLabel.FontSize = 11;
            app.play_Waterfall_ColormapLabel.Layout.Row = 3;
            app.play_Waterfall_ColormapLabel.Layout.Column = [1 3];
            app.play_Waterfall_ColormapLabel.Text = 'Mapa de cores:';

            % Create play_Waterfall_Colormap
            app.play_Waterfall_Colormap = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.play_Waterfall_Colormap.FontSize = 11;
            app.play_Waterfall_Colormap.BackgroundColor = [1 1 1];
            app.play_Waterfall_Colormap.Layout.Row = 4;
            app.play_Waterfall_Colormap.Layout.Column = [1 2];
            app.play_Waterfall_Colormap.Value = 'winter';

            % Create play_Waterfall_MeshStyleLabel
            app.play_Waterfall_MeshStyleLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_MeshStyleLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_MeshStyleLabel.FontSize = 11;
            app.play_Waterfall_MeshStyleLabel.Layout.Row = 3;
            app.play_Waterfall_MeshStyleLabel.Layout.Column = [3 5];
            app.play_Waterfall_MeshStyleLabel.Text = 'Linhas da superfície:';

            % Create play_Waterfall_MeshStyle
            app.play_Waterfall_MeshStyle = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_MeshStyle.Items = {'row', 'both'};
            app.play_Waterfall_MeshStyle.Enable = 'off';
            app.play_Waterfall_MeshStyle.FontSize = 11;
            app.play_Waterfall_MeshStyle.BackgroundColor = [1 1 1];
            app.play_Waterfall_MeshStyle.Layout.Row = 4;
            app.play_Waterfall_MeshStyle.Layout.Column = [3 5];
            app.play_Waterfall_MeshStyle.Value = 'row';

            % Create play_Waterfall_cLim_Label
            app.play_Waterfall_cLim_Label = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Label.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Label.FontSize = 11;
            app.play_Waterfall_cLim_Label.Layout.Row = 5;
            app.play_Waterfall_cLim_Label.Layout.Column = [1 4];
            app.play_Waterfall_cLim_Label.Text = 'Limites de nível (dB):';

            % Create play_Waterfall_cLim_Mode
            app.play_Waterfall_cLim_Mode = uiimage(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Mode.ScaleMethod = 'none';
            app.play_Waterfall_cLim_Mode.Enable = 'off';
            app.play_Waterfall_cLim_Mode.Layout.Row = 5;
            app.play_Waterfall_cLim_Mode.Layout.Column = 5;
            app.play_Waterfall_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Waterfall_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Mode.ImageSource = 'Refresh_18.png';

            % Create play_Waterfall_cLim1
            app.play_Waterfall_cLim1 = uispinner(app.play_WaterFallGrid);
            app.play_Waterfall_cLim1.Step = 5;
            app.play_Waterfall_cLim1.RoundFractionalValues = 'on';
            app.play_Waterfall_cLim1.ValueDisplayFormat = '%.0f';
            app.play_Waterfall_cLim1.FontSize = 11;
            app.play_Waterfall_cLim1.Enable = 'off';
            app.play_Waterfall_cLim1.Tooltip = {''};
            app.play_Waterfall_cLim1.Layout.Row = 6;
            app.play_Waterfall_cLim1.Layout.Column = [1 2];

            % Create play_Waterfall_cLim2
            app.play_Waterfall_cLim2 = uispinner(app.play_WaterFallGrid);
            app.play_Waterfall_cLim2.Step = 5;
            app.play_Waterfall_cLim2.RoundFractionalValues = 'on';
            app.play_Waterfall_cLim2.ValueDisplayFormat = '%.0f';
            app.play_Waterfall_cLim2.FontSize = 11;
            app.play_Waterfall_cLim2.Enable = 'off';
            app.play_Waterfall_cLim2.Tooltip = {''};
            app.play_Waterfall_cLim2.Layout.Row = 6;
            app.play_Waterfall_cLim2.Layout.Column = [3 5];
            app.play_Waterfall_cLim2.Value = 1;

            % Create play_Persistance_Panel
            app.play_Persistance_Panel = uipanel(app.SubGrid1);
            app.play_Persistance_Panel.AutoResizeChildren = 'off';
            app.play_Persistance_Panel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.play_Persistance_Panel.Layout.Row = 4;
            app.play_Persistance_Panel.Layout.Column = [1 2];

            % Create play_PersistanceGrid
            app.play_PersistanceGrid = uigridlayout(app.play_Persistance_Panel);
            app.play_PersistanceGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.play_PersistanceGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.play_PersistanceGrid.RowSpacing = 5;
            app.play_PersistanceGrid.Padding = [10 10 10 5];
            app.play_PersistanceGrid.BackgroundColor = [1 1 1];

            % Create play_Persistance_InterpolationLabel
            app.play_Persistance_InterpolationLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_InterpolationLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_InterpolationLabel.FontSize = 11;
            app.play_Persistance_InterpolationLabel.Layout.Row = 1;
            app.play_Persistance_InterpolationLabel.Layout.Column = [1 3];
            app.play_Persistance_InterpolationLabel.Text = 'Interpolação:';

            % Create play_Persistance_Interpolation
            app.play_Persistance_Interpolation = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_Interpolation.Items = {'nearest', 'bilinear'};
            app.play_Persistance_Interpolation.FontSize = 11;
            app.play_Persistance_Interpolation.BackgroundColor = [1 1 1];
            app.play_Persistance_Interpolation.Layout.Row = 2;
            app.play_Persistance_Interpolation.Layout.Column = [1 2];
            app.play_Persistance_Interpolation.Value = 'nearest';

            % Create play_Persistance_WindowSizeLabel
            app.play_Persistance_WindowSizeLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_WindowSizeLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_WindowSizeLabel.FontSize = 11;
            app.play_Persistance_WindowSizeLabel.Layout.Row = 1;
            app.play_Persistance_WindowSizeLabel.Layout.Column = [3 5];
            app.play_Persistance_WindowSizeLabel.Text = 'Tamanho janela:';

            % Create play_Persistance_WindowSizeValue
            app.play_Persistance_WindowSizeValue = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_WindowSizeValue.HorizontalAlignment = 'right';
            app.play_Persistance_WindowSizeValue.VerticalAlignment = 'bottom';
            app.play_Persistance_WindowSizeValue.FontSize = 11;
            app.play_Persistance_WindowSizeValue.FontColor = [0.8 0.8 0.8];
            app.play_Persistance_WindowSizeValue.Layout.Row = 1;
            app.play_Persistance_WindowSizeValue.Layout.Column = [3 5];
            app.play_Persistance_WindowSizeValue.Text = 'full';

            % Create play_Persistance_WindowSize
            app.play_Persistance_WindowSize = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_WindowSize.Items = {'128', '256', '512', 'full'};
            app.play_Persistance_WindowSize.FontSize = 11;
            app.play_Persistance_WindowSize.BackgroundColor = [1 1 1];
            app.play_Persistance_WindowSize.Layout.Row = 2;
            app.play_Persistance_WindowSize.Layout.Column = [3 5];
            app.play_Persistance_WindowSize.Value = '128';

            % Create play_Persistance_ColormapLabel
            app.play_Persistance_ColormapLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_ColormapLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_ColormapLabel.FontSize = 11;
            app.play_Persistance_ColormapLabel.Layout.Row = 3;
            app.play_Persistance_ColormapLabel.Layout.Column = [1 2];
            app.play_Persistance_ColormapLabel.Text = 'Mapa de cores:';

            % Create play_Persistance_Colormap
            app.play_Persistance_Colormap = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_Colormap.Items = {'winter', 'parula', 'turbo'};
            app.play_Persistance_Colormap.FontSize = 11;
            app.play_Persistance_Colormap.BackgroundColor = [1 1 1];
            app.play_Persistance_Colormap.Layout.Row = 4;
            app.play_Persistance_Colormap.Layout.Column = [1 2];
            app.play_Persistance_Colormap.Value = 'winter';

            % Create play_Persistance_TransparencyLabel
            app.play_Persistance_TransparencyLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_TransparencyLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_TransparencyLabel.WordWrap = 'on';
            app.play_Persistance_TransparencyLabel.FontSize = 11;
            app.play_Persistance_TransparencyLabel.Layout.Row = 3;
            app.play_Persistance_TransparencyLabel.Layout.Column = [3 5];
            app.play_Persistance_TransparencyLabel.Text = 'Transparência:';

            % Create play_Persistance_Transparency
            app.play_Persistance_Transparency = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_Transparency.Step = 0.05;
            app.play_Persistance_Transparency.Limits = [0.2 1];
            app.play_Persistance_Transparency.ValueDisplayFormat = '%.2f';
            app.play_Persistance_Transparency.FontSize = 11;
            app.play_Persistance_Transparency.Layout.Row = 4;
            app.play_Persistance_Transparency.Layout.Column = [3 5];
            app.play_Persistance_Transparency.Value = 1;

            % Create play_Persistance_cLim_Label
            app.play_Persistance_cLim_Label = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Label.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Label.FontSize = 11;
            app.play_Persistance_cLim_Label.Layout.Row = 5;
            app.play_Persistance_cLim_Label.Layout.Column = [1 4];
            app.play_Persistance_cLim_Label.Text = 'Limites de intensidade (%):';

            % Create play_Persistance_cLim_Mode
            app.play_Persistance_cLim_Mode = uiimage(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Mode.ScaleMethod = 'none';
            app.play_Persistance_cLim_Mode.Enable = 'off';
            app.play_Persistance_cLim_Mode.Tooltip = {'Retorna à configuração padrão'};
            app.play_Persistance_cLim_Mode.Layout.Row = 5;
            app.play_Persistance_cLim_Mode.Layout.Column = 5;
            app.play_Persistance_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Persistance_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Mode.ImageSource = 'Refresh_18.png';

            % Create play_Persistance_cLim2
            app.play_Persistance_cLim2 = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_cLim2.Limits = [0 Inf];
            app.play_Persistance_cLim2.ValueDisplayFormat = '%.3f';
            app.play_Persistance_cLim2.FontSize = 11;
            app.play_Persistance_cLim2.Enable = 'off';
            app.play_Persistance_cLim2.Tooltip = {''};
            app.play_Persistance_cLim2.Layout.Row = 6;
            app.play_Persistance_cLim2.Layout.Column = [3 5];
            app.play_Persistance_cLim2.Value = 1;

            % Create play_Persistance_cLim1
            app.play_Persistance_cLim1 = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_cLim1.Step = 0.1;
            app.play_Persistance_cLim1.Limits = [0 Inf];
            app.play_Persistance_cLim1.ValueDisplayFormat = '%.3f';
            app.play_Persistance_cLim1.FontSize = 11;
            app.play_Persistance_cLim1.Enable = 'off';
            app.play_Persistance_cLim1.Tooltip = {''};
            app.play_Persistance_cLim1.Layout.Row = 6;
            app.play_Persistance_cLim1.Layout.Column = [1 2];

            % Create play_ControlPanelLabel_2
            app.play_ControlPanelLabel_2 = uilabel(app.SubGrid1);
            app.play_ControlPanelLabel_2.VerticalAlignment = 'bottom';
            app.play_ControlPanelLabel_2.FontSize = 10;
            app.play_ControlPanelLabel_2.Layout.Row = 5;
            app.play_ControlPanelLabel_2.Layout.Column = 2;
            app.play_ControlPanelLabel_2.Text = 'WATERFALL';

            % Create Image
            app.Image = uiimage(app.SubGrid1);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = 'DriveTestDensity_32.png';

            % Create Image2
            app.Image2 = uiimage(app.SubGrid1);
            app.Image2.Layout.Row = 3;
            app.Image2.Layout.Column = 1;
            app.Image2.VerticalAlignment = 'bottom';
            app.Image2.ImageSource = 'Persistance_36.png';

            % Create Image3
            app.Image3 = uiimage(app.SubGrid1);
            app.Image3.ScaleMethod = 'none';
            app.Image3.Layout.Row = 5;
            app.Image3.Layout.Column = 1;
            app.Image3.ImageSource = 'Waterfall_24.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [3 4];
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
            app.ContextMenu.Tag = 'auxApp.winRFDataHub';

            % Create contextmenu_del
            app.contextmenu_del = uimenu(app.ContextMenu);
            app.contextmenu_del.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_del.Text = '❌ Excluir';

            % Create contextmenu_delAll
            app.contextmenu_delAll = uimenu(app.ContextMenu);
            app.contextmenu_delAll.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_delAll.Text = '⛔ Excluir todos';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winPlayback_exported(Container, varargin)

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
