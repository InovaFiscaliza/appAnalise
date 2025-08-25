classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        Folders_Grid              matlab.ui.container.GridLayout
        FolderMapPanel            matlab.ui.container.Panel
        FolderMapGrid             matlab.ui.container.GridLayout
        userPathButton            matlab.ui.control.Image
        userPath                  matlab.ui.control.EditField
        userPathLabel             matlab.ui.control.Label
        DataHubPOSTButton         matlab.ui.control.Image
        DataHubPOST               matlab.ui.control.EditField
        DataHubPOSTLabel          matlab.ui.control.Label
        config_FolderMapLabel     matlab.ui.control.Label
        CustomPlotGrid            matlab.ui.container.GridLayout
        general_ElevationPanel    matlab.ui.container.Panel
        general_ElevationGrid     matlab.ui.container.GridLayout
        ElevationForceSearch      matlab.ui.control.CheckBox
        ElevationNPoints          matlab.ui.control.DropDown
        ElevationNPointsLabel     matlab.ui.control.Label
        ElevationAPIServer        matlab.ui.control.DropDown
        ElevationAPIServerLabel   matlab.ui.control.Label
        general_ElevationRefresh  matlab.ui.control.Image
        general_ElevationLabel    matlab.ui.control.Label
        general_GraphicsPanel     matlab.ui.container.Panel
        general_GraphicsGrid      matlab.ui.container.GridLayout
        InitialBW_kHz             matlab.ui.control.Spinner
        InitialBW_kHzLabel        matlab.ui.control.Label
        yOccupancyScale           matlab.ui.control.DropDown
        yOccupancyScaleLabel      matlab.ui.control.Label
        imgResolution             matlab.ui.control.DropDown
        imgResolutionLabel        matlab.ui.control.Label
        imgFormat                 matlab.ui.control.DropDown
        imgFormatLabel            matlab.ui.control.Label
        graphics_Refresh          matlab.ui.control.Image
        general_GraphicsLabel     matlab.ui.control.Label
        general_FilePanel         matlab.ui.container.Panel
        general_FileGrid          matlab.ui.container.GridLayout
        detectionManualMode       matlab.ui.control.CheckBox
        channelManualMode         matlab.ui.control.CheckBox
        mergeDistance             matlab.ui.control.Spinner
        mergeLabel2               matlab.ui.control.Label
        mergeAntenna              matlab.ui.control.CheckBox
        mergeDataType             matlab.ui.control.CheckBox
        mergeLabel1               matlab.ui.control.Label
        general_FileLabel         matlab.ui.control.Label
        general_mergeRefresh      matlab.ui.control.Image
        General_Grid              matlab.ui.container.GridLayout
        openAuxiliarApp2Debug     matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked   matlab.ui.control.CheckBox
        versionInfo               matlab.ui.control.Label
        versionInfoRefresh        matlab.ui.control.Image
        versionInfoLabel          matlab.ui.control.Label
        LeftPanelRadioGroup       matlab.ui.container.ButtonGroup
        btnFolder                 matlab.ui.control.RadioButton
        btnAnalysis               matlab.ui.control.RadioButton
        btnGeneral                matlab.ui.control.RadioButton
        LeftPanel                 matlab.ui.container.Panel
        LeftPanelGrid             matlab.ui.container.GridLayout
        menuUnderline             matlab.ui.control.Image
        menu_ButtonGrid           matlab.ui.container.GridLayout
        menu_ButtonIcon           matlab.ui.control.Image
        menu_ButtonLabel          matlab.ui.control.Label
        toolGrid                  matlab.ui.container.GridLayout
        openDevTools              matlab.ui.control.Image
        tool_RFDataHubButton      matlab.ui.control.Image
    end

    
    properties
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        
        mainApp
        rootFolder

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

        stableVersion
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        DefaultValues = struct('File',      struct('DataType', true, 'DataTypeLabel', 'remove', 'Antenna', true, 'AntennaLabel', 'remove', 'AntennaAttributes', {{'Name', 'Azimuth', 'Elevation', 'Polarization', 'Height', 'SwitchPort', 'LNBChannel'}}, 'Distance', 100, 'ChannelManualMode', false, 'DetectionManualMode', false), ...
                               'Graphics',  struct('openGL', 'hardware', 'Format', 'jpeg', 'Resolution', '120', 'Dock', true),                                                                                                                                                                                                        ...
                               'Elevation', struct('Points', '256', 'ForceSearch', false, 'Server', 'Open-Elevation'))
    end


    methods
        %-----------------------------------------------------------------%
        % IPC: COMUNICAÇÃO ENTRE PROCESSOS
        %-----------------------------------------------------------------%
        function ipcSecundaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        startup_Controller(app)
                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appUtil.jsBackDoorHTMLSource(),                 ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt), ...
                                                  "Visible",              "off");
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app)
            if app.isDocked
                app.progressDialog = app.mainApp.progressDialog;
            else
                sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);
            end

            elToModify = {app.versionInfo};
            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
            if ~isempty(elDataTag)
                appName = class(app);
                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function startup_timerCreation(app)
            app.timerObj = timer("ExecutionMode", "fixedSpacing", ...
                                 "StartDelay",    1.5,            ...
                                 "Period",        .1,             ...
                                 "TimerFcn",      @(~,~)app.startup_timerFcn);
            start(app.timerObj)
        end

        %-----------------------------------------------------------------%
        function startup_timerFcn(app)
            if ccTools.fcn.UIFigureRenderStatus(app.UIFigure)
                stop(app.timerObj)
                delete(app.timerObj)
                
                jsBackDoor_Initialization(app)
            end
        end

        %-----------------------------------------------------------------%
        function startup_Controller(app)
            drawnow
            jsBackDoor_Customizations(app)

            startup_GUIComponents(app)
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            switch app.mainApp.executionMode
                case 'webApp'
                    delete(app.openDevTools)
                otherwise
                    app.btnFolder.Enable               = 1;
                    app.versionInfoRefresh.Enable      = 1;
                    app.openAuxiliarAppAsDocked.Enable = 1;
            end

            if ~isdeployed
                app.openAuxiliarApp2Debug.Enable = 1;
            end

            General_updatePanel(app)
            File_updatePanel(app)
            Graphics_updatePanel(app)
            Elevation_updatePanel(app)
            Folder_updatePanel(app)
        end

        %-----------------------------------------------------------------%
        function General_updatePanel(app)
            % Versão:
            ui.TextView.update(app.versionInfo, util.HtmlTextGenerator.AppInfo(app.mainApp.General, app.mainApp.rootFolder, app.mainApp.executionMode));

            % Modo de operação:
            app.openAuxiliarAppAsDocked.Value   = app.mainApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value     = app.mainApp.General.operationMode.Debug;
        end

        %-----------------------------------------------------------------%
        function File_updatePanel(app)
            % Mesclagem de fluxos espectrais
            switch app.mainApp.General.Merge.DataType
                case 'keep';   app.mergeDataType.Value = 0;
                case 'remove'; app.mergeDataType.Value = 1;
            end

            switch app.mainApp.General.Merge.Antenna
                case 'keep';   app.mergeAntenna.Value = 0;
                case 'remove'; app.mergeAntenna.Value = 1;
            end

            app.mergeDistance.Value = app.mainApp.General.Merge.Distance;

            app.channelManualMode.Value   = app.mainApp.General.Channel.ManualMode;
            app.detectionManualMode.Value = app.mainApp.General.Detection.ManualMode;
            
            if File_checkEdition(app)
                app.general_mergeRefresh.Visible = 1;
            else
                app.general_mergeRefresh.Visible = 0;
            end
        end

        %-----------------------------------------------------------------%
        function editionFlag = File_checkEdition(app)
            editionFlag = false;

            if (app.mergeDataType.Value       ~= app.DefaultValues.File.DataType)          || ...
               (app.mergeAntenna.Value        ~= app.DefaultValues.File.Antenna)           || ...
               (abs(app.mergeDistance.Value - app.DefaultValues.File.Distance) > 1e-5)     || ...
               (app.channelManualMode.Value   ~= app.DefaultValues.File.ChannelManualMode) || ...
               (app.detectionManualMode.Value ~= app.DefaultValues.File.DetectionManualMode)

                editionFlag = true;
            end
        end

        %-----------------------------------------------------------------%
        function Graphics_updatePanel(app)
            % Imagem relatório
            app.imgFormat.Value     = app.mainApp.General.Image.Format;
            app.imgResolution.Value = string(app.mainApp.General.Image.Resolution);

            if Graphics_checkEdition(app)
                app.graphics_Refresh.Visible = 1;
            else
                app.graphics_Refresh.Visible = 0;
            end

            app.yOccupancyScale.Value = app.mainApp.General.Plot.Axes.yOccupancyScale;
            app.InitialBW_kHz.Value   = app.mainApp.General.Detection.InitialBW_kHz;
        end

        %-----------------------------------------------------------------%
        function editionFlag = Graphics_checkEdition(app)
            editionFlag = false;

            if ~strcmp(app.imgFormat.Value,     app.DefaultValues.Graphics.Format) || ...
               ~strcmp(app.imgResolution.Value, app.DefaultValues.Graphics.Resolution)

                editionFlag = true;
            end
        end

        %-----------------------------------------------------------------%
        function Elevation_updatePanel(app)
            app.ElevationNPoints.Value     = num2str(app.mainApp.General.Elevation.Points);
            app.ElevationForceSearch.Value = app.mainApp.General.Elevation.ForceSearch;
            app.ElevationAPIServer.Value   = app.mainApp.General.Elevation.Server;

            if Elevation_checkEdition(app)
                app.general_ElevationRefresh.Visible = 1;
            else
                app.general_ElevationRefresh.Visible = 0;
            end
        end

        %-----------------------------------------------------------------%
        function editionFlag = Elevation_checkEdition(app)
            editionFlag = false;

            if ~strcmp(app.ElevationNPoints.Value, app.DefaultValues.Elevation.Points)     || ...
               (app.ElevationForceSearch.Value ~= app.DefaultValues.Elevation.ForceSearch) || ...
               ~strcmp(app.ElevationAPIServer.Value, app.DefaultValues.Elevation.Server)
                
                editionFlag = true;
            end
        end

        %-----------------------------------------------------------------%
        function Folder_updatePanel(app)
            % Na versão webapp, a configuração das pastas não é habilitada.

            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.btnFolder.Enable      = 1;

                DataHub_POST = app.mainApp.General.fileFolder.DataHub_POST;    
                if isfolder(DataHub_POST)
                    app.DataHubPOST.Value = DataHub_POST;
                end

                app.userPath.Value        = app.mainApp.General.fileFolder.userPath;
            end
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            % A razão de ser deste app é possibilitar visualização/edição 
            % de algumas das informações do arquivo "GeneralSettings.json".
            app.mainApp    = mainApp;
            app.rootFolder = mainApp.rootFolder;

            if app.isDocked
                app.GridLayout.Padding(4) = 19;
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn')
            delete(app)
            
        end

        % Image clicked function: tool_RFDataHubButton
        function tool_RFDataHubButtonPushed(app, event)
            
            if isequal(app.mainApp.General.AppVersion.rfDataHub,  app.stableVersion.rfDataHub)
                app.tool_RFDataHubButton.Enable = 0;
                appUtil.modalWindow(app.UIFigure, 'warning', 'Módulo RFDataHub já atualizado!');
                return
            end

            d = appUtil.modalWindow(app.UIFigure, "progressdlg", 'Em andamento... esse processo pode demorar alguns minutos!');

            try
                appName = class.Constants.appName;
                rfDataHubLink = util.publicLink(appName, app.rootFolder, 'RFDataHub');
                model.RFDataHub.update(appName, app.rootFolder, app.mainApp.General.fileFolder.tempPath, rfDataHubLink)

                % Atualiza versão.
                global RFDataHub_info

                app.mainApp.General.AppVersion.rfDataHub = RFDataHub_info;
                app.stableVersion.rfDataHub = RFDataHub_info;
                app.tool_RFDataHubButton.Enable = 0;
                
            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end

            General_updatePanel(app)
            delete(d)

        end

        % Selection changed function: LeftPanelRadioGroup
        function RadioButtonGroupSelectionChanged(app, event)
            
            selectedButton = app.LeftPanelRadioGroup.SelectedObject;
            switch selectedButton
                case app.btnGeneral;  app.GridLayout.ColumnWidth(4:6) = {'1x',0,0};
                case app.btnAnalysis; app.GridLayout.ColumnWidth(4:6) = {0,'1x',0};
                case app.btnFolder;   app.GridLayout.ColumnWidth(4:6) = {0,0,'1x'};
            end
            
        end

        % Image clicked function: versionInfoRefresh
        function AppVersion_refreshButtonPushed(app, event)
            
            app.progressDialog.Visible = 'visible';

            [htmlContent, app.stableVersion, updatedModule] = util.HtmlTextGenerator.checkAvailableUpdate(app.mainApp.General, app.rootFolder);
            appUtil.modalWindow(app.UIFigure, "info", htmlContent);
            
            if ~ismember('RFDataHub', updatedModule)
                app.tool_RFDataHubButton.Enable = 1;
            end          

            app.progressDialog.Visible = 'hidden';

        end

        % Callback function: channelManualMode, detectionManualMode, 
        % ...and 4 other components
        function File_ParameterValueChanged(app, event)
            
            switch event.Source
                case {app.mergeDataType, app.mergeAntenna, app.mergeDistance}                    
                    switch app.mergeDataType.Value
                        case 0; DataTypeStatus = 'keep';
                        case 1; DataTypeStatus = 'remove';
                    end
                    
                    switch app.mergeAntenna.Value
                        case 0; AntennaStatus  = 'keep';
                        case 1; AntennaStatus  = 'remove';
                    end
                                
                    app.mainApp.General.Merge.DataType = DataTypeStatus;
                    app.mainApp.General.Merge.Antenna  = AntennaStatus;
                    app.mainApp.General.Merge.Distance = app.mergeDistance.Value;

                case {app.channelManualMode, app.detectionManualMode}
                    app.mainApp.General.Channel.ManualMode   = app.channelManualMode.Value;
                    app.mainApp.General.Detection.ManualMode = app.detectionManualMode.Value;

                case app.general_mergeRefresh
                    app.mainApp.General.Merge = struct('DataType',           app.DefaultValues.File.DataTypeLabel,      ...
                                                       'Antenna',            app.DefaultValues.File.AntennaLabel,       ...
                                                       'AntennaAttributes', {app.DefaultValues.File.AntennaAttributes}, ...
                                                       'Distance',           app.DefaultValues.File.Distance);
                    
                    app.mainApp.General.Channel.ManualMode   = app.DefaultValues.File.ChannelManualMode;
                    app.mainApp.General.Detection.ManualMode = app.DefaultValues.File.DetectionManualMode;
            end

            app.mainApp.General_I.Merge     = app.mainApp.General.Merge;
            app.mainApp.General_I.Channel   = app.mainApp.General.Channel;
            app.mainApp.General_I.Detection = app.mainApp.General.Detection;

            saveGeneralSettings(app)
            File_updatePanel(app)  

        end

        % Callback function: InitialBW_kHz, graphics_Refresh, imgFormat, 
        % ...and 4 other components
        function Graphics_ParameterValueChanged(app, event)
            
            switch event.Source
                case {app.imgFormat, app.imgResolution}
                    app.mainApp.General.Image = struct('Format', app.imgFormat.Value, 'Resolution', str2double(app.imgResolution.Value));

                case app.yOccupancyScale
                    app.mainApp.General.Plot.Axes.yOccupancyScale = app.yOccupancyScale.Value;
                    set(app.mainApp.UIAxes2, 'YScale', app.yOccupancyScale.Value)

                case app.InitialBW_kHz
                    app.mainApp.General.Detection.InitialBW_kHz = app.InitialBW_kHz.Value;

                case app.openAuxiliarAppAsDocked
                    app.mainApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.mainApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;

                case app.graphics_Refresh
                    app.mainApp.General.Image = struct('Format', app.DefaultValues.Graphics.Format, 'Resolution', app.DefaultValues.Graphics.Resolution);
            end

            app.mainApp.General_I.openGL                    = app.mainApp.General.openGL;
            app.mainApp.General_I.Image                     = app.mainApp.General.Image;
            app.mainApp.General_I.operationMode             = app.mainApp.General.operationMode;
            app.mainApp.General_I.Detection.InitialBW_kHz   = app.mainApp.General.Detection.InitialBW_kHz;
            app.mainApp.General_I.Plot.Axes.yOccupancyScale = app.mainApp.General.Plot.Axes.yOccupancyScale;

            saveGeneralSettings(app)
            Graphics_updatePanel(app)

        end

        % Callback function: ElevationAPIServer, ElevationForceSearch, 
        % ...and 2 other components
        function Elevation_ParameterValueChanged(app, event)

            switch event.Source
                case app.ElevationNPoints
                    app.mainApp.General.Elevation.Points      = str2double(app.ElevationNPoints.Value);

                case app.ElevationForceSearch
                    app.mainApp.General.Elevation.ForceSearch = app.ElevationForceSearch.Value;

                case app.ElevationAPIServer
                    app.mainApp.General.Elevation.Server      = app.ElevationAPIServer.Value;

                case app.general_ElevationRefresh
                    app.mainApp.General.Elevation = struct('Points',      str2double(app.DefaultValues.Elevation.Points), ...
                                                           'ForceSearch', app.DefaultValues.Elevation.ForceSearch,        ...
                                                           'Server',      app.DefaultValues.Elevation.Server);
            end

            app.mainApp.General_I.Elevation = app.mainApp.General.Elevation;
            saveGeneralSettings(app)
            Elevation_updatePanel(app)
            
        end

        % Image clicked function: DataHubPOSTButton, userPathButton
        function Folder_ButtonPushed(app, event)
            
            try
                relatedFolder = eval(sprintf('app.config_Folder_%s.Value', event.Source.Tag));                    
            catch
                relatedFolder = app.mainApp.General.fileFolder.(event.Source.Tag);
            end
            
            if isfolder(relatedFolder)
                initialFolder = relatedFolder;
            elseif isfile(relatedFolder)
                initialFolder = fileparts(relatedFolder);
            else
                initialFolder = app.userPath.Value;
            end
            
            selectedFolder = uigetdir(initialFolder);
            figure(app.UIFigure)

            if selectedFolder
                switch event.Source
                    case app.DataHubPOSTButton
                        if strcmp(app.mainApp.General.fileFolder.DataHub_POST, selectedFolder) 
                            return
                        else
                            selectedFolderFiles = dir(selectedFolder);
                            if ~ismember('.appanalise_post', {selectedFolderFiles.name})
                                appUtil.modalWindow(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - POST", do appAnalise.');
                                return
                            end

                            app.DataHubPOST.Value = selectedFolder;
                            app.mainApp.General.fileFolder.DataHub_POST = selectedFolder;
    
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'checkDataHubLampStatus')
                        end

                    case app.userPathButton
                        app.userPath.Value = selectedFolder;
                        app.mainApp.General.fileFolder.userPath = selectedFolder;
                end

                app.mainApp.General_I.fileFolder = app.mainApp.General.fileFolder;
                saveGeneralSettings(app)
                Folder_updatePanel(app)
            end

        end

        % Image clicked function: openDevTools
        function openDevToolsClicked(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'openDevTools')

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
            app.GridLayout.ColumnWidth = {5, 320, 10, '1x', 0, 0, 5};
            app.GridLayout.RowHeight = {5, 23, 3, 5, 100, '1x', 5, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create toolGrid
            app.toolGrid = uigridlayout(app.GridLayout);
            app.toolGrid.ColumnWidth = {22, '1x', 22, 1};
            app.toolGrid.RowHeight = {4, 17, 2};
            app.toolGrid.ColumnSpacing = 5;
            app.toolGrid.RowSpacing = 0;
            app.toolGrid.Padding = [5 5 0 5];
            app.toolGrid.Layout.Row = 8;
            app.toolGrid.Layout.Column = [1 7];
            app.toolGrid.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_RFDataHubButton
            app.tool_RFDataHubButton = uiimage(app.toolGrid);
            app.tool_RFDataHubButton.ImageClickedFcn = createCallbackFcn(app, @tool_RFDataHubButtonPushed, true);
            app.tool_RFDataHubButton.Enable = 'off';
            app.tool_RFDataHubButton.Tooltip = {'Atualiza RFDataHub'};
            app.tool_RFDataHubButton.Layout.Row = 2;
            app.tool_RFDataHubButton.Layout.Column = 1;
            app.tool_RFDataHubButton.ImageSource = 'mosaic_32.png';

            % Create openDevTools
            app.openDevTools = uiimage(app.toolGrid);
            app.openDevTools.ScaleMethod = 'none';
            app.openDevTools.ImageClickedFcn = createCallbackFcn(app, @openDevToolsClicked, true);
            app.openDevTools.Tooltip = {'DevTools'};
            app.openDevTools.Layout.Row = 2;
            app.openDevTools.Layout.Column = 3;
            app.openDevTools.ImageSource = 'Debug_18.png';

            % Create menu_ButtonGrid
            app.menu_ButtonGrid = uigridlayout(app.GridLayout);
            app.menu_ButtonGrid.ColumnWidth = {18, '1x', '1x'};
            app.menu_ButtonGrid.RowHeight = {'1x'};
            app.menu_ButtonGrid.ColumnSpacing = 3;
            app.menu_ButtonGrid.Padding = [2 0 0 0];
            app.menu_ButtonGrid.Layout.Row = 2;
            app.menu_ButtonGrid.Layout.Column = 2;
            app.menu_ButtonGrid.BackgroundColor = [0.749 0.749 0.749];

            % Create menu_ButtonLabel
            app.menu_ButtonLabel = uilabel(app.menu_ButtonGrid);
            app.menu_ButtonLabel.FontSize = 11;
            app.menu_ButtonLabel.Layout.Row = 1;
            app.menu_ButtonLabel.Layout.Column = 2;
            app.menu_ButtonLabel.Text = 'CONFIGURAÇÕES';

            % Create menu_ButtonIcon
            app.menu_ButtonIcon = uiimage(app.menu_ButtonGrid);
            app.menu_ButtonIcon.ScaleMethod = 'none';
            app.menu_ButtonIcon.Tag = '1';
            app.menu_ButtonIcon.Layout.Row = 1;
            app.menu_ButtonIcon.Layout.Column = 1;
            app.menu_ButtonIcon.HorizontalAlignment = 'left';
            app.menu_ButtonIcon.ImageSource = 'Settings_18.png';

            % Create menuUnderline
            app.menuUnderline = uiimage(app.GridLayout);
            app.menuUnderline.ScaleMethod = 'none';
            app.menuUnderline.Layout.Row = 3;
            app.menuUnderline.Layout.Column = 2;
            app.menuUnderline.ImageSource = 'LineH.svg';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = [5 6];
            app.LeftPanel.Layout.Column = 2;

            % Create LeftPanelGrid
            app.LeftPanelGrid = uigridlayout(app.LeftPanel);
            app.LeftPanelGrid.ColumnWidth = {'1x'};
            app.LeftPanelGrid.RowHeight = {100, '1x'};
            app.LeftPanelGrid.Padding = [0 0 0 0];
            app.LeftPanelGrid.BackgroundColor = [1 1 1];

            % Create LeftPanelRadioGroup
            app.LeftPanelRadioGroup = uibuttongroup(app.GridLayout);
            app.LeftPanelRadioGroup.AutoResizeChildren = 'off';
            app.LeftPanelRadioGroup.SelectionChangedFcn = createCallbackFcn(app, @RadioButtonGroupSelectionChanged, true);
            app.LeftPanelRadioGroup.BorderType = 'none';
            app.LeftPanelRadioGroup.BackgroundColor = [1 1 1];
            app.LeftPanelRadioGroup.Layout.Row = 5;
            app.LeftPanelRadioGroup.Layout.Column = 2;
            app.LeftPanelRadioGroup.FontSize = 11;

            % Create btnGeneral
            app.btnGeneral = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnGeneral.Text = 'Aspectos gerais';
            app.btnGeneral.FontSize = 11;
            app.btnGeneral.Position = [14 69 100 22];
            app.btnGeneral.Value = true;

            % Create btnAnalysis
            app.btnAnalysis = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnAnalysis.Text = 'Análise';
            app.btnAnalysis.FontSize = 11;
            app.btnAnalysis.Position = [14 47 58 22];

            % Create btnFolder
            app.btnFolder = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnFolder.Enable = 'off';
            app.btnFolder.Text = 'Mapeamento de pastas';
            app.btnFolder.FontSize = 11;
            app.btnFolder.Position = [14 25 195 22];

            % Create General_Grid
            app.General_Grid = uigridlayout(app.GridLayout);
            app.General_Grid.ColumnWidth = {'1x', 16};
            app.General_Grid.RowHeight = {26, '1x', 1, 22, 15};
            app.General_Grid.RowSpacing = 5;
            app.General_Grid.Padding = [0 0 0 0];
            app.General_Grid.Layout.Row = [2 6];
            app.General_Grid.Layout.Column = 4;
            app.General_Grid.BackgroundColor = [1 1 1];

            % Create versionInfoLabel
            app.versionInfoLabel = uilabel(app.General_Grid);
            app.versionInfoLabel.VerticalAlignment = 'bottom';
            app.versionInfoLabel.FontSize = 10;
            app.versionInfoLabel.Layout.Row = 1;
            app.versionInfoLabel.Layout.Column = 1;
            app.versionInfoLabel.Text = 'ASPECTOS GERAIS';

            % Create versionInfoRefresh
            app.versionInfoRefresh = uiimage(app.General_Grid);
            app.versionInfoRefresh.ScaleMethod = 'none';
            app.versionInfoRefresh.ImageClickedFcn = createCallbackFcn(app, @AppVersion_refreshButtonPushed, true);
            app.versionInfoRefresh.Enable = 'off';
            app.versionInfoRefresh.Tooltip = {'Verifica atualizações'};
            app.versionInfoRefresh.Layout.Row = 1;
            app.versionInfoRefresh.Layout.Column = 2;
            app.versionInfoRefresh.VerticalAlignment = 'bottom';
            app.versionInfoRefresh.ImageSource = 'Refresh_18.png';

            % Create versionInfo
            app.versionInfo = uilabel(app.General_Grid);
            app.versionInfo.BackgroundColor = [1 1 1];
            app.versionInfo.VerticalAlignment = 'top';
            app.versionInfo.WordWrap = 'on';
            app.versionInfo.FontSize = 11;
            app.versionInfo.Layout.Row = 2;
            app.versionInfo.Layout.Column = [1 2];
            app.versionInfo.Interpreter = 'html';
            app.versionInfo.Text = '';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.General_Grid);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.openAuxiliarAppAsDocked.Enable = 'off';
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na janela principal do app';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.Layout.Row = 4;
            app.openAuxiliarAppAsDocked.Layout.Column = [1 2];

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.General_Grid);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.openAuxiliarApp2Debug.Enable = 'off';
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.Layout.Row = 5;
            app.openAuxiliarApp2Debug.Layout.Column = [1 2];

            % Create CustomPlotGrid
            app.CustomPlotGrid = uigridlayout(app.GridLayout);
            app.CustomPlotGrid.ColumnWidth = {'1x', 16};
            app.CustomPlotGrid.RowHeight = {26, 192, 22, 116, 22, '1x'};
            app.CustomPlotGrid.RowSpacing = 5;
            app.CustomPlotGrid.Padding = [0 0 0 0];
            app.CustomPlotGrid.Layout.Row = [2 6];
            app.CustomPlotGrid.Layout.Column = 5;
            app.CustomPlotGrid.BackgroundColor = [1 1 1];

            % Create general_mergeRefresh
            app.general_mergeRefresh = uiimage(app.CustomPlotGrid);
            app.general_mergeRefresh.ScaleMethod = 'none';
            app.general_mergeRefresh.ImageClickedFcn = createCallbackFcn(app, @File_ParameterValueChanged, true);
            app.general_mergeRefresh.Visible = 'off';
            app.general_mergeRefresh.Tooltip = {'Volta à configuração inicial'};
            app.general_mergeRefresh.Layout.Row = 1;
            app.general_mergeRefresh.Layout.Column = 2;
            app.general_mergeRefresh.VerticalAlignment = 'bottom';
            app.general_mergeRefresh.ImageSource = 'Refresh_18.png';

            % Create general_FileLabel
            app.general_FileLabel = uilabel(app.CustomPlotGrid);
            app.general_FileLabel.VerticalAlignment = 'bottom';
            app.general_FileLabel.FontSize = 10;
            app.general_FileLabel.Layout.Row = 1;
            app.general_FileLabel.Layout.Column = 1;
            app.general_FileLabel.Text = 'LEITURA DE ARQUIVOS';

            % Create general_FilePanel
            app.general_FilePanel = uipanel(app.CustomPlotGrid);
            app.general_FilePanel.Layout.Row = 2;
            app.general_FilePanel.Layout.Column = [1 2];

            % Create general_FileGrid
            app.general_FileGrid = uigridlayout(app.general_FilePanel);
            app.general_FileGrid.ColumnWidth = {10, 90, '1x'};
            app.general_FileGrid.RowHeight = {17, 17, 17, 22, 22, 1, 22, 22};
            app.general_FileGrid.ColumnSpacing = 0;
            app.general_FileGrid.RowSpacing = 5;
            app.general_FileGrid.BackgroundColor = [1 1 1];

            % Create mergeLabel1
            app.mergeLabel1 = uilabel(app.general_FileGrid);
            app.mergeLabel1.VerticalAlignment = 'bottom';
            app.mergeLabel1.WordWrap = 'on';
            app.mergeLabel1.FontSize = 11;
            app.mergeLabel1.Layout.Row = 1;
            app.mergeLabel1.Layout.Column = [1 3];
            app.mergeLabel1.Text = 'Metadados a serem ignorados na mesclagem de fluxos espectrais:';

            % Create mergeDataType
            app.mergeDataType = uicheckbox(app.general_FileGrid);
            app.mergeDataType.ValueChangedFcn = createCallbackFcn(app, @File_ParameterValueChanged, true);
            app.mergeDataType.Text = 'DataType';
            app.mergeDataType.FontSize = 11;
            app.mergeDataType.FontColor = [0.149 0.149 0.149];
            app.mergeDataType.Layout.Row = 2;
            app.mergeDataType.Layout.Column = 2;
            app.mergeDataType.Value = true;

            % Create mergeAntenna
            app.mergeAntenna = uicheckbox(app.general_FileGrid);
            app.mergeAntenna.ValueChangedFcn = createCallbackFcn(app, @File_ParameterValueChanged, true);
            app.mergeAntenna.Text = 'Antenna';
            app.mergeAntenna.FontSize = 11;
            app.mergeAntenna.FontColor = [0.149 0.149 0.149];
            app.mergeAntenna.Layout.Row = 3;
            app.mergeAntenna.Layout.Column = 2;
            app.mergeAntenna.Value = true;

            % Create mergeLabel2
            app.mergeLabel2 = uilabel(app.general_FileGrid);
            app.mergeLabel2.VerticalAlignment = 'bottom';
            app.mergeLabel2.WordWrap = 'on';
            app.mergeLabel2.FontSize = 11;
            app.mergeLabel2.Layout.Row = 4;
            app.mergeLabel2.Layout.Column = [1 3];
            app.mergeLabel2.Text = 'Distância máxima permitida entre pontos de monitoração em arquivos diferentes para mesclar fluxos espectrais (em metros):';

            % Create mergeDistance
            app.mergeDistance = uispinner(app.general_FileGrid);
            app.mergeDistance.Step = 50;
            app.mergeDistance.Limits = [50 Inf];
            app.mergeDistance.RoundFractionalValues = 'on';
            app.mergeDistance.ValueDisplayFormat = '%.0f';
            app.mergeDistance.ValueChangedFcn = createCallbackFcn(app, @File_ParameterValueChanged, true);
            app.mergeDistance.FontSize = 11;
            app.mergeDistance.FontColor = [0.149 0.149 0.149];
            app.mergeDistance.Layout.Row = 5;
            app.mergeDistance.Layout.Column = [1 2];
            app.mergeDistance.Value = 100;

            % Create channelManualMode
            app.channelManualMode = uicheckbox(app.general_FileGrid);
            app.channelManualMode.ValueChangedFcn = createCallbackFcn(app, @File_ParameterValueChanged, true);
            app.channelManualMode.Text = 'Não identificar automaticamente canais relacionados aos fluxos espectrais na leitura de arquivos.';
            app.channelManualMode.FontSize = 11;
            app.channelManualMode.Layout.Row = 7;
            app.channelManualMode.Layout.Column = [1 3];

            % Create detectionManualMode
            app.detectionManualMode = uicheckbox(app.general_FileGrid);
            app.detectionManualMode.ValueChangedFcn = createCallbackFcn(app, @File_ParameterValueChanged, true);
            app.detectionManualMode.Text = 'Não detectar automaticamente emissões na geração preliminar do relatório (editável no modo RELATÓRIO).';
            app.detectionManualMode.FontSize = 11;
            app.detectionManualMode.Layout.Row = 8;
            app.detectionManualMode.Layout.Column = [1 3];

            % Create general_GraphicsLabel
            app.general_GraphicsLabel = uilabel(app.CustomPlotGrid);
            app.general_GraphicsLabel.VerticalAlignment = 'bottom';
            app.general_GraphicsLabel.FontSize = 10;
            app.general_GraphicsLabel.Layout.Row = 3;
            app.general_GraphicsLabel.Layout.Column = 1;
            app.general_GraphicsLabel.Text = 'GRÁFICO';

            % Create graphics_Refresh
            app.graphics_Refresh = uiimage(app.CustomPlotGrid);
            app.graphics_Refresh.ScaleMethod = 'none';
            app.graphics_Refresh.ImageClickedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.graphics_Refresh.Visible = 'off';
            app.graphics_Refresh.Tooltip = {'Volta à configuração inicial'};
            app.graphics_Refresh.Layout.Row = 3;
            app.graphics_Refresh.Layout.Column = 2;
            app.graphics_Refresh.VerticalAlignment = 'bottom';
            app.graphics_Refresh.ImageSource = 'Refresh_18.png';

            % Create general_GraphicsPanel
            app.general_GraphicsPanel = uipanel(app.CustomPlotGrid);
            app.general_GraphicsPanel.Layout.Row = 4;
            app.general_GraphicsPanel.Layout.Column = [1 2];

            % Create general_GraphicsGrid
            app.general_GraphicsGrid = uigridlayout(app.general_GraphicsPanel);
            app.general_GraphicsGrid.ColumnWidth = {220, 100, 110, '1x'};
            app.general_GraphicsGrid.RowHeight = {17, 22, 22, 22};
            app.general_GraphicsGrid.RowSpacing = 5;
            app.general_GraphicsGrid.Padding = [10 10 10 5];
            app.general_GraphicsGrid.BackgroundColor = [1 1 1];

            % Create imgFormatLabel
            app.imgFormatLabel = uilabel(app.general_GraphicsGrid);
            app.imgFormatLabel.VerticalAlignment = 'bottom';
            app.imgFormatLabel.FontSize = 11;
            app.imgFormatLabel.Layout.Row = 1;
            app.imgFormatLabel.Layout.Column = 1;
            app.imgFormatLabel.Text = 'Formato da imagem (RELATÓRIO):';

            % Create imgFormat
            app.imgFormat = uidropdown(app.general_GraphicsGrid);
            app.imgFormat.Items = {'jpeg', 'png'};
            app.imgFormat.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.imgFormat.FontSize = 11;
            app.imgFormat.BackgroundColor = [1 1 1];
            app.imgFormat.Layout.Row = 2;
            app.imgFormat.Layout.Column = 1;
            app.imgFormat.Value = 'jpeg';

            % Create imgResolutionLabel
            app.imgResolutionLabel = uilabel(app.general_GraphicsGrid);
            app.imgResolutionLabel.VerticalAlignment = 'bottom';
            app.imgResolutionLabel.FontSize = 11;
            app.imgResolutionLabel.Layout.Row = 1;
            app.imgResolutionLabel.Layout.Column = 2;
            app.imgResolutionLabel.Text = 'Resolução (dpi):';

            % Create imgResolution
            app.imgResolution = uidropdown(app.general_GraphicsGrid);
            app.imgResolution.Items = {'100', '120', '150', '200'};
            app.imgResolution.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.imgResolution.FontSize = 11;
            app.imgResolution.BackgroundColor = [1 1 1];
            app.imgResolution.Layout.Row = 2;
            app.imgResolution.Layout.Column = 2;
            app.imgResolution.Value = '120';

            % Create yOccupancyScaleLabel
            app.yOccupancyScaleLabel = uilabel(app.general_GraphicsGrid);
            app.yOccupancyScaleLabel.VerticalAlignment = 'bottom';
            app.yOccupancyScaleLabel.FontSize = 11;
            app.yOccupancyScaleLabel.Layout.Row = 3;
            app.yOccupancyScaleLabel.Layout.Column = 1;
            app.yOccupancyScaleLabel.Text = 'Escala de ocupação do plot (PLAYBACK):';

            % Create yOccupancyScale
            app.yOccupancyScale = uidropdown(app.general_GraphicsGrid);
            app.yOccupancyScale.Items = {'linear', 'log'};
            app.yOccupancyScale.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.yOccupancyScale.FontSize = 11;
            app.yOccupancyScale.BackgroundColor = [1 1 1];
            app.yOccupancyScale.Layout.Row = 4;
            app.yOccupancyScale.Layout.Column = 1;
            app.yOccupancyScale.Value = 'linear';

            % Create InitialBW_kHzLabel
            app.InitialBW_kHzLabel = uilabel(app.general_GraphicsGrid);
            app.InitialBW_kHzLabel.VerticalAlignment = 'bottom';
            app.InitialBW_kHzLabel.WordWrap = 'on';
            app.InitialBW_kHzLabel.FontSize = 11;
            app.InitialBW_kHzLabel.Layout.Row = 3;
            app.InitialBW_kHzLabel.Layout.Column = [2 4];
            app.InitialBW_kHzLabel.Text = 'Largura de emissão em kHz para emissão criada pelo método "DataTip" (PLAYBACK):';

            % Create InitialBW_kHz
            app.InitialBW_kHz = uispinner(app.general_GraphicsGrid);
            app.InitialBW_kHz.Step = 50;
            app.InitialBW_kHz.Limits = [0 1000];
            app.InitialBW_kHz.RoundFractionalValues = 'on';
            app.InitialBW_kHz.ValueDisplayFormat = '%.0f';
            app.InitialBW_kHz.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.InitialBW_kHz.FontSize = 11;
            app.InitialBW_kHz.FontColor = [0.149 0.149 0.149];
            app.InitialBW_kHz.Layout.Row = 4;
            app.InitialBW_kHz.Layout.Column = 2;

            % Create general_ElevationLabel
            app.general_ElevationLabel = uilabel(app.CustomPlotGrid);
            app.general_ElevationLabel.VerticalAlignment = 'bottom';
            app.general_ElevationLabel.FontSize = 10;
            app.general_ElevationLabel.Layout.Row = 5;
            app.general_ElevationLabel.Layout.Column = 1;
            app.general_ElevationLabel.Text = 'ELEVAÇÃO';

            % Create general_ElevationRefresh
            app.general_ElevationRefresh = uiimage(app.CustomPlotGrid);
            app.general_ElevationRefresh.ScaleMethod = 'none';
            app.general_ElevationRefresh.ImageClickedFcn = createCallbackFcn(app, @Elevation_ParameterValueChanged, true);
            app.general_ElevationRefresh.Visible = 'off';
            app.general_ElevationRefresh.Layout.Row = 5;
            app.general_ElevationRefresh.Layout.Column = 2;
            app.general_ElevationRefresh.VerticalAlignment = 'bottom';
            app.general_ElevationRefresh.ImageSource = 'Refresh_18.png';

            % Create general_ElevationPanel
            app.general_ElevationPanel = uipanel(app.CustomPlotGrid);
            app.general_ElevationPanel.AutoResizeChildren = 'off';
            app.general_ElevationPanel.Layout.Row = 6;
            app.general_ElevationPanel.Layout.Column = [1 2];

            % Create general_ElevationGrid
            app.general_ElevationGrid = uigridlayout(app.general_ElevationPanel);
            app.general_ElevationGrid.ColumnWidth = {220, 110, '1x'};
            app.general_ElevationGrid.RowHeight = {17, 22, 36};
            app.general_ElevationGrid.RowSpacing = 5;
            app.general_ElevationGrid.Padding = [10 10 10 5];
            app.general_ElevationGrid.BackgroundColor = [1 1 1];

            % Create ElevationAPIServerLabel
            app.ElevationAPIServerLabel = uilabel(app.general_ElevationGrid);
            app.ElevationAPIServerLabel.VerticalAlignment = 'bottom';
            app.ElevationAPIServerLabel.FontSize = 11;
            app.ElevationAPIServerLabel.Layout.Row = 1;
            app.ElevationAPIServerLabel.Layout.Column = 1;
            app.ElevationAPIServerLabel.Text = 'Fonte:';

            % Create ElevationAPIServer
            app.ElevationAPIServer = uidropdown(app.general_ElevationGrid);
            app.ElevationAPIServer.Items = {'Open-Elevation', 'MathWorks WMS Server'};
            app.ElevationAPIServer.ValueChangedFcn = createCallbackFcn(app, @Elevation_ParameterValueChanged, true);
            app.ElevationAPIServer.FontSize = 11;
            app.ElevationAPIServer.BackgroundColor = [1 1 1];
            app.ElevationAPIServer.Layout.Row = 2;
            app.ElevationAPIServer.Layout.Column = 1;
            app.ElevationAPIServer.Value = 'MathWorks WMS Server';

            % Create ElevationNPointsLabel
            app.ElevationNPointsLabel = uilabel(app.general_ElevationGrid);
            app.ElevationNPointsLabel.VerticalAlignment = 'bottom';
            app.ElevationNPointsLabel.FontSize = 11;
            app.ElevationNPointsLabel.Layout.Row = 1;
            app.ElevationNPointsLabel.Layout.Column = 2;
            app.ElevationNPointsLabel.Text = 'Pontos enlace:';

            % Create ElevationNPoints
            app.ElevationNPoints = uidropdown(app.general_ElevationGrid);
            app.ElevationNPoints.Items = {'64', '128', '256', '512', '1024'};
            app.ElevationNPoints.ValueChangedFcn = createCallbackFcn(app, @Elevation_ParameterValueChanged, true);
            app.ElevationNPoints.FontSize = 11;
            app.ElevationNPoints.BackgroundColor = [1 1 1];
            app.ElevationNPoints.Layout.Row = 2;
            app.ElevationNPoints.Layout.Column = 2;
            app.ElevationNPoints.Value = '256';

            % Create ElevationForceSearch
            app.ElevationForceSearch = uicheckbox(app.general_ElevationGrid);
            app.ElevationForceSearch.ValueChangedFcn = createCallbackFcn(app, @Elevation_ParameterValueChanged, true);
            app.ElevationForceSearch.Text = 'Força consulta ao servidor (ignorando eventual informação em cache).';
            app.ElevationForceSearch.WordWrap = 'on';
            app.ElevationForceSearch.FontSize = 11;
            app.ElevationForceSearch.Layout.Row = 3;
            app.ElevationForceSearch.Layout.Column = [1 3];

            % Create Folders_Grid
            app.Folders_Grid = uigridlayout(app.GridLayout);
            app.Folders_Grid.ColumnWidth = {'1x'};
            app.Folders_Grid.RowHeight = {26, '1x'};
            app.Folders_Grid.RowSpacing = 5;
            app.Folders_Grid.Padding = [0 0 0 0];
            app.Folders_Grid.Layout.Row = [2 6];
            app.Folders_Grid.Layout.Column = 6;
            app.Folders_Grid.BackgroundColor = [1 1 1];

            % Create config_FolderMapLabel
            app.config_FolderMapLabel = uilabel(app.Folders_Grid);
            app.config_FolderMapLabel.VerticalAlignment = 'bottom';
            app.config_FolderMapLabel.FontSize = 10;
            app.config_FolderMapLabel.Layout.Row = 1;
            app.config_FolderMapLabel.Layout.Column = 1;
            app.config_FolderMapLabel.Text = 'MAPEAMENTO DE PASTAS';

            % Create FolderMapPanel
            app.FolderMapPanel = uipanel(app.Folders_Grid);
            app.FolderMapPanel.AutoResizeChildren = 'off';
            app.FolderMapPanel.Layout.Row = 2;
            app.FolderMapPanel.Layout.Column = 1;

            % Create FolderMapGrid
            app.FolderMapGrid = uigridlayout(app.FolderMapPanel);
            app.FolderMapGrid.ColumnWidth = {'1x', 20};
            app.FolderMapGrid.RowHeight = {17, 22, 17, 22, '1x'};
            app.FolderMapGrid.ColumnSpacing = 5;
            app.FolderMapGrid.RowSpacing = 5;
            app.FolderMapGrid.BackgroundColor = [1 1 1];

            % Create DataHubPOSTLabel
            app.DataHubPOSTLabel = uilabel(app.FolderMapGrid);
            app.DataHubPOSTLabel.VerticalAlignment = 'bottom';
            app.DataHubPOSTLabel.FontSize = 10;
            app.DataHubPOSTLabel.Layout.Row = 1;
            app.DataHubPOSTLabel.Layout.Column = 1;
            app.DataHubPOSTLabel.Text = 'DataHub - POST:';

            % Create DataHubPOST
            app.DataHubPOST = uieditfield(app.FolderMapGrid, 'text');
            app.DataHubPOST.Editable = 'off';
            app.DataHubPOST.FontSize = 11;
            app.DataHubPOST.Layout.Row = 2;
            app.DataHubPOST.Layout.Column = 1;

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.FolderMapGrid);
            app.DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @Folder_ButtonPushed, true);
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Layout.Row = 2;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'OpenFile_36x36.png';

            % Create userPathLabel
            app.userPathLabel = uilabel(app.FolderMapGrid);
            app.userPathLabel.VerticalAlignment = 'bottom';
            app.userPathLabel.FontSize = 10;
            app.userPathLabel.Layout.Row = 3;
            app.userPathLabel.Layout.Column = 1;
            app.userPathLabel.Text = 'Pasta do usuário:';

            % Create userPath
            app.userPath = uieditfield(app.FolderMapGrid, 'text');
            app.userPath.Editable = 'off';
            app.userPath.FontSize = 11;
            app.userPath.Layout.Row = 4;
            app.userPath.Layout.Column = 1;

            % Create userPathButton
            app.userPathButton = uiimage(app.FolderMapGrid);
            app.userPathButton.ImageClickedFcn = createCallbackFcn(app, @Folder_ButtonPushed, true);
            app.userPathButton.Tag = 'userPath';
            app.userPathButton.Layout.Row = 4;
            app.userPathButton.Layout.Column = 2;
            app.userPathButton.ImageSource = 'OpenFile_36x36.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winConfig_exported(Container, varargin)

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
