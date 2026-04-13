classdef winRepoSFI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        TabGroup                   matlab.ui.container.TabGroup
        Tab                        matlab.ui.container.Tab
        GridLayout2                matlab.ui.container.GridLayout
        ColorPicker                matlab.ui.control.ColorPicker
        ColorPickerLabel           matlab.ui.control.Label
        Label                      matlab.ui.control.Label
        bdededededebDropDown       matlab.ui.control.DropDown
        bdededededebDropDownLabel  matlab.ui.control.Label
        Tab2                       matlab.ui.container.Tab
        DockModule                 matlab.ui.container.GridLayout
        dockModule_Close           matlab.ui.control.Image
        dockModule_Undock          matlab.ui.control.Image
        Document                   matlab.ui.container.GridLayout
        AxesToolbar                matlab.ui.container.GridLayout
        axesTool_RegionZoom        matlab.ui.control.Image
        axesTool_RestoreView       matlab.ui.control.Image
        plotPanel                  matlab.ui.container.Panel
        Toolbar                    matlab.ui.container.GridLayout
        tool_tableNRowsIcon        matlab.ui.control.Image
        tool_ExportButton          matlab.ui.control.Image
        tool_Separator2            matlab.ui.control.Image
        tool_PDFButton             matlab.ui.control.Image
        tool_RFLinkButton          matlab.ui.control.Image
        tool_TableVisibility       matlab.ui.control.Image
        tool_Separator1            matlab.ui.control.Image
        tool_PanelVisibility       matlab.ui.control.Image
        ContextMenu                matlab.ui.container.ContextMenu
        contextmenu_del            matlab.ui.container.Menu
        contextmenu_delAll         matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'RFDATAHUB'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog

        repoSFI        
        UIAxes
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    otherwise
                        error('auxApp:winRFDataHub:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
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
                        operationType = varargin{1};

                        switch operationType
                            case 'onRepoSFIUpdate'
                                closeFcn(app)

                            otherwise
                                error('auxApp:winRFDataHub:UnexpectedCall', 'Unexpected call "%s"', operationType)
                        end

                    otherwise
                        error('auxApp:winRFDataHub:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
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

            switch tabIndex
                case 1
                    appName = class(app);
                    elToModify = {
                        app.AxesToolbar;
                        app.tool_PanelVisibility;
                        app.tool_TableVisibility;
                        app.tool_RFLinkButton;
                        app.tool_PDFButton;
                        app.tool_ExportButton;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.tool_PanelVisibility.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel')), ...
                            struct('appName', appName, 'dataTag', app.tool_TableVisibility.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna entre três layouts do conjunto plot+tabela<br>(apenas plot, apenas tabela ou plot+tabela)')), ...
                            struct('appName', appName, 'dataTag', app.tool_RFLinkButton.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Apresenta perfil de terreno entre registro selecionado (TX)<br>e estação de referência (RX)')), ...
                            struct('appName', appName, 'dataTag', app.tool_PDFButton.UserData.id,             'tooltip', struct('defaultPosition', 'top',    'textContent', 'Apresenta documento gerado pelo Mosaico (limitado à radiodifusão)')), ...
                            struct('appName', appName, 'dataTag', app.tool_ExportButton.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Exporta planilha filtrada (.xlsx)')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,          'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,           'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRepoSFI(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            startup_AxesCreation(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            plot_Stations(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeRepoSFI(app)
            global factSpec
            if isempty(factSpec)
                load("C:\InovaFiscaliza\appAnalise\src\config\DataBase\repoSFI.mat", "factSpec")
                factSpec.Hash = arrayfun(@(x,y) Hash.sha1(sprintf('%.6f - %.6f', x, y)), factSpec.LATITUDE, factSpec.LONGITUDE, 'UniformOutput', false);
            end

            app.repoSFI = factSpec;
        end
        
        %-----------------------------------------------------------------%
        function startup_AxesCreation(app)
            hParent = tiledlayout(app.plotPanel, 1, 1, "Padding", "none", "TileSpacing", "none");

            % Eixo geográfico: MAPA
            app.UIAxes = plot.axes.Creation(hParent, 'Geographic', {'Basemap', 'streets-dark',                 ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '')});

            set(app.UIAxes.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            geolimits(app.UIAxes, 'auto')
            plot.axes.Colormap(app.UIAxes, 'turbo')

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation(app.UIAxes, [dataTipInteraction, zoomInteraction, panInteraction])
        end


        %-----------------------------------------------------------------%
        % PLOT
        %-----------------------------------------------------------------%
        function plot_Stations(app)
            [~, uniqueStationsIdxs] = unique(app.repoSFI.Hash);

            latitudeArray = app.repoSFI.LATITUDE(uniqueStationsIdxs);
            longitudeArray = app.repoSFI.LONGITUDE(uniqueStationsIdxs);

            geoscatter(app.UIAxes, latitudeArray, longitudeArray, ...
                'MarkerEdgeColor', 'yellow', ...
                'MarkerFaceColor', 'yellow', ...
                'SizeData',        36,              ...
                'Tag',             'Stations' ...
            );
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
                    
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Image clicked function: tool_PDFButton, tool_PanelVisibility, 
        % ...and 2 other components
        function Toolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.tool_PanelVisibility
                    if app.SubTabGroup.Visible
                        app.tool_PanelVisibility.ImageSource = 'layout-sidebar-left-off.svg';
                        app.SubTabGroup.Visible = 0;
                        app.Document.Layout.Column = [2 5];
                    else
                        app.tool_PanelVisibility.ImageSource = 'layout-sidebar-left.svg';
                        app.SubTabGroup.Visible = 1;
                        app.Document.Layout.Column = [4 5];
                    end

                case app.tool_TableVisibility
                    app.tool_TableVisibility.UserData.layout = mod(app.tool_TableVisibility.UserData.layout + 1, 3);
                    switch app.tool_TableVisibility.UserData.layout
                        case 0
                            app.UITable.Visible    = 0;
                            app.Document.RowHeight = {24,'1x',0,0};
                        case 1
                            app.UITable.Visible    = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                        case 2
                            app.UITable.Visible    = 1;
                            app.Document.RowHeight = {0,0,0,'1x'};
                    end

                case app.tool_PDFButton
                    app.tool_PDFButton.UserData.status = ~app.tool_PDFButton.UserData.status;
                    if app.tool_PDFButton.UserData.status
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout.
                        if app.tool_TableVisibility.UserData.layout == 2
                            app.tool_TableVisibility.UserData.layout = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                        end

                        app.Document.ColumnWidth(4:7) = {10,22,22,'1x'};
                    else
                        app.Document.ColumnWidth(4:7) = {0,0,0,0};
                    end
                    misc_getChannelReport(app, 'Cache+RealTime')

                case app.tool_RFLinkButton
                    app.tool_RFLinkButton.UserData.status = ~app.tool_RFLinkButton.UserData.status;
                    if app.tool_RFLinkButton.UserData.status
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout. O pause é uma espécie de "drawnow"
                        % e garante que o plot será realizado corretamente.
                        if app.tool_TableVisibility.UserData.layout == 2
                            app.tool_TableVisibility.UserData.layout = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                            pause(.100)
                        end
                        
                        app.UIAxes.Layout.TileSpan = [1,2];
                        set(findobj(app.UIAxes2), 'Visible', 1)
                    else
                        app.UIAxes.Layout.TileSpan = [2,2];
                        set(findobj(app.UIAxes2), 'Visible', 0)
                    end
                    plot_createRFLinkPlot(app)
            end

        end

        % Image clicked function: tool_ExportButton
        function Toolbar_exportButtonPushed(app, event)

                nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
                defaultName   = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'RFDataHub', -1); 
                fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
                if isempty(fileFullPath)
                    return
                end
                
                app.progressDialog.Visible = 'visible';

                try
                    idxRFDataHubArray = app.UITable.UserData;
                    tempRFDataHub = model.RFDataHub.ColumnNames(app.rfDataHub(idxRFDataHubArray,1:29), 'eng2port');
                    writetable(tempRFDataHub, fileFullPath, 'WriteMode', 'overwritesheet')
                catch ME
                    ui.Dialog(app.UIFigure, 'warning', getReport(ME));
                end

                app.progressDialog.Visible = 'hidden';

        end

        % Menu selected function: contextmenu_del, contextmenu_delAll
        function filter_delFilter(app, event)
            
            if isempty(app.FilterRules)
                return
            end

            switch event.Source
                case app.contextmenu_del
                    if isempty(app.filter_Tree.SelectedNodes)
                        return
                    end
                    idx1 = app.filter_Tree.SelectedNodes.NodeData;
                    
                    % Identifica se algum dos fluxos selecionado é um nó de
                    % filtros, inserindo na lista os seus filhos.
                    idx1 = [idx1, find(ismember(app.FilterRules.RelatedID, idx1))'];

                case app.contextmenu_delAll
                    idx1 = 1:height(app.FilterRules);
            end 
    
            if ~isempty(idx1)
                removeFilterRule(app, idx1);
            end

        end

        % Value changed function: bdededededebDropDown
        function bdededededebDropDownValueChanged(app, event)
            
            value = app.bdededededebDropDown.Value;
            event


            
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
            app.GridLayout.ColumnWidth = {10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 22, 5, 22, '1x', 18};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_PanelVisibility
            app.tool_PanelVisibility = uiimage(app.Toolbar);
            app.tool_PanelVisibility.ScaleMethod = 'none';
            app.tool_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_PanelVisibility.Layout.Row = [1 3];
            app.tool_PanelVisibility.Layout.Column = 1;
            app.tool_PanelVisibility.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Separator1
            app.tool_Separator1 = uiimage(app.Toolbar);
            app.tool_Separator1.ScaleMethod = 'none';
            app.tool_Separator1.Enable = 'off';
            app.tool_Separator1.Layout.Row = [1 3];
            app.tool_Separator1.Layout.Column = 2;
            app.tool_Separator1.VerticalAlignment = 'bottom';
            app.tool_Separator1.ImageSource = 'LineV.svg';

            % Create tool_TableVisibility
            app.tool_TableVisibility = uiimage(app.Toolbar);
            app.tool_TableVisibility.ScaleMethod = 'none';
            app.tool_TableVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_TableVisibility.Layout.Row = [1 3];
            app.tool_TableVisibility.Layout.Column = 3;
            app.tool_TableVisibility.ImageSource = 'View_16.png';

            % Create tool_RFLinkButton
            app.tool_RFLinkButton = uiimage(app.Toolbar);
            app.tool_RFLinkButton.ScaleMethod = 'none';
            app.tool_RFLinkButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_RFLinkButton.Layout.Row = [1 3];
            app.tool_RFLinkButton.Layout.Column = 4;
            app.tool_RFLinkButton.ImageSource = 'Publish_HTML_16.png';

            % Create tool_PDFButton
            app.tool_PDFButton = uiimage(app.Toolbar);
            app.tool_PDFButton.ScaleMethod = 'none';
            app.tool_PDFButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_PDFButton.Layout.Row = [1 3];
            app.tool_PDFButton.Layout.Column = 5;
            app.tool_PDFButton.ImageSource = 'Publish_PDF_16.png';

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.Toolbar);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 3];
            app.tool_Separator2.Layout.Column = 6;
            app.tool_Separator2.VerticalAlignment = 'bottom';
            app.tool_Separator2.ImageSource = 'LineV.svg';

            % Create tool_ExportButton
            app.tool_ExportButton = uiimage(app.Toolbar);
            app.tool_ExportButton.ScaleMethod = 'none';
            app.tool_ExportButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_exportButtonPushed, true);
            app.tool_ExportButton.Layout.Row = [1 3];
            app.tool_ExportButton.Layout.Column = 7;
            app.tool_ExportButton.ImageSource = 'Export_16.png';

            % Create tool_tableNRowsIcon
            app.tool_tableNRowsIcon = uiimage(app.Toolbar);
            app.tool_tableNRowsIcon.ScaleMethod = 'none';
            app.tool_tableNRowsIcon.Enable = 'off';
            app.tool_tableNRowsIcon.Layout.Row = [1 3];
            app.tool_tableNRowsIcon.Layout.Column = 9;
            app.tool_tableNRowsIcon.ImageSource = 'Filter_18.png';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {5, 50, '1x'};
            app.Document.RowHeight = {24, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 5];
            app.Document.BackgroundColor = [1 1 1];

            % Create plotPanel
            app.plotPanel = uipanel(app.Document);
            app.plotPanel.AutoResizeChildren = 'off';
            app.plotPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.plotPanel.BorderType = 'none';
            app.plotPanel.BackgroundColor = [1 1 1];
            app.plotPanel.Layout.Row = [1 2];
            app.plotPanel.Layout.Column = [1 3];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {22, 22};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 2;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 1;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 2;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [5 6];
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

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [3 4];
            app.TabGroup.Layout.Column = 2;

            % Create Tab
            app.Tab = uitab(app.TabGroup);
            app.Tab.Title = 'Tab';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Tab);
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create bdededededebDropDownLabel
            app.bdededededebDropDownLabel = uilabel(app.GridLayout2);
            app.bdededededebDropDownLabel.VerticalAlignment = 'bottom';
            app.bdededededebDropDownLabel.Layout.Row = 1;
            app.bdededededebDropDownLabel.Layout.Column = 1;
            app.bdededededebDropDownLabel.Interpreter = 'html';
            app.bdededededebDropDownLabel.Text = '<b>dedededede</b>';

            % Create bdededededebDropDown
            app.bdededededebDropDown = uidropdown(app.GridLayout2);
            app.bdededededebDropDown.ValueChangedFcn = createCallbackFcn(app, @bdededededebDropDownValueChanged, true);
            app.bdededededebDropDown.FontColor = [1 1 1];
            app.bdededededebDropDown.BackgroundColor = [0.851 0.3255 0.098];
            app.bdededededebDropDown.Layout.Row = 2;
            app.bdededededebDropDown.Layout.Column = [1 2];

            % Create Label
            app.Label = uilabel(app.GridLayout2);
            app.Label.Layout.Row = 3;
            app.Label.Layout.Column = 1;

            % Create ColorPickerLabel
            app.ColorPickerLabel = uilabel(app.GridLayout2);
            app.ColorPickerLabel.HorizontalAlignment = 'right';
            app.ColorPickerLabel.Layout.Row = 4;
            app.ColorPickerLabel.Layout.Column = 1;
            app.ColorPickerLabel.Text = 'Color Picker';

            % Create ColorPicker
            app.ColorPicker = uicolorpicker(app.GridLayout2);
            app.ColorPicker.Layout.Row = 4;
            app.ColorPicker.Layout.Column = 2;

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.Title = 'Tab2';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winRFDataHub';

            % Create contextmenu_del
            app.contextmenu_del = uimenu(app.ContextMenu);
            app.contextmenu_del.MenuSelectedFcn = createCallbackFcn(app, @filter_delFilter, true);
            app.contextmenu_del.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_del.Text = '❌ Excluir';

            % Create contextmenu_delAll
            app.contextmenu_delAll = uimenu(app.ContextMenu);
            app.contextmenu_delAll.MenuSelectedFcn = createCallbackFcn(app, @filter_delFilter, true);
            app.contextmenu_delAll.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_delAll.Text = '⛔ Excluir todos';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winRepoSFI_exported(Container, varargin)

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
