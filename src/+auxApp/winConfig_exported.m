classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        DockModuleGroup            matlab.ui.container.GridLayout
        dockModule_Undock          matlab.ui.control.Image
        dockModule_Close           matlab.ui.control.Image
        TabGroup                   matlab.ui.container.TabGroup
        Tab1                       matlab.ui.container.Tab
        Tab1Grid                   matlab.ui.container.GridLayout
        tool_RFDataHubButton       matlab.ui.control.Image
        tool_versionInfoRefresh    matlab.ui.control.Image
        openAuxiliarApp2Debug      matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked    matlab.ui.control.CheckBox
        versionInfo                matlab.ui.control.Label
        versionInfoLabel           matlab.ui.control.Label
        Tab2                       matlab.ui.container.Tab
        Tab2Grid                   matlab.ui.container.GridLayout
        analysis_ElevationPanel    matlab.ui.container.Panel
        analysis_ElevationGrid     matlab.ui.container.GridLayout
        elevationForceSearch       matlab.ui.control.CheckBox
        elevationNPoints           matlab.ui.control.DropDown
        elevationNPointsLabel      matlab.ui.control.Label
        elevationAPIServer         matlab.ui.control.DropDown
        elevationAPIServerLabel    matlab.ui.control.Label
        analysis_ElevationRefresh  matlab.ui.control.Image
        analysis_ElevationLabel    matlab.ui.control.Label
        analysis_GraphicsPanel     matlab.ui.container.Panel
        analysis_GraphicsGrid      matlab.ui.container.GridLayout
        InitialBW_kHz              matlab.ui.control.Spinner
        InitialBW_kHzLabel         matlab.ui.control.Label
        yOccupancyScale            matlab.ui.control.DropDown
        yOccupancyScaleLabel       matlab.ui.control.Label
        imgResolution              matlab.ui.control.DropDown
        imgResolutionLabel         matlab.ui.control.Label
        imgFormat                  matlab.ui.control.DropDown
        imgFormatLabel             matlab.ui.control.Label
        analysis_GraphicsRefresh   matlab.ui.control.Image
        analysis_GraphicsLabel     matlab.ui.control.Label
        analysis_FilePanel         matlab.ui.container.Panel
        analysis_FileGrid          matlab.ui.container.GridLayout
        detectionManualMode        matlab.ui.control.CheckBox
        channelManualMode          matlab.ui.control.CheckBox
        mergeDistance              matlab.ui.control.Spinner
        mergeLabel2                matlab.ui.control.Label
        mergeAntenna               matlab.ui.control.CheckBox
        mergeDataType              matlab.ui.control.CheckBox
        mergeLabel1                matlab.ui.control.Label
        analysis_FileRefresh       matlab.ui.control.Image
        analysis_FileLabel         matlab.ui.control.Label
        Tab3                       matlab.ui.container.Tab
        Tab3Grid                   matlab.ui.container.GridLayout
        userPathButton             matlab.ui.control.Image
        userPath                   matlab.ui.control.EditField
        userPathLabel              matlab.ui.control.Label
        DataHubPOSTButton          matlab.ui.control.Image
        DataHubPOST                matlab.ui.control.EditField
        DATAHUBPOSTLabel           matlab.ui.control.Label
        Toolbar                    matlab.ui.container.GridLayout
        tool_simulationMode        matlab.ui.control.Image
        tool_openDevTools          matlab.ui.control.Image
    end

    
    properties
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        
        mainApp

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
                               'Graphics',  struct('Format', 'jpeg', 'Resolution', '120', 'Dock', true), ...
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
        function jsBackDoor_Customizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false];
            end

            switch tabIndex
                case 0 % STARTUP
                    if app.isDocked
                        app.progressDialog = app.mainApp.progressDialog;
                    else
                        sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                        app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);
                    end
                    customizationStatus = [false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1
                            appName = class(app);

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
                            elToModify = {app.versionInfo};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, app.versionInfo, appName);
                            end

                        case 2
                            File_updatePanel(app)
                            Graphics_updatePanel(app)
                            Elevation_updatePanel(app)

                        case 3
                            Folder_updatePanel(app)
                    end
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
            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)

            startup_GUIComponents(app)
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
                app.tool_openDevTools.Enable = 1;

                set([app.DataHubPOSTButton, app.userPathButton], 'Enable', 1)
                app.tool_versionInfoRefresh.Enable      = 1;
                app.openAuxiliarAppAsDocked.Enable = 1;
            end

            if ~isdeployed
                app.openAuxiliarApp2Debug.Enable = 1;
            end

            General_updatePanel(app)
        end

        %-----------------------------------------------------------------%
        function General_updatePanel(app)
            % Versão:
            ui.TextView.update(app.versionInfo, util.HtmlTextGenerator.AppInfo(app.mainApp.General, app.mainApp.rootFolder, app.mainApp.executionMode, app.mainApp.renderCount, "textview"));

            % Modo de operação:
            app.openAuxiliarAppAsDocked.Value = app.mainApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value   = app.mainApp.General.operationMode.Debug;
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
                app.analysis_FileRefresh.Visible = 1;
            else
                app.analysis_FileRefresh.Visible = 0;
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
                app.analysis_GraphicsRefresh.Visible = 1;
            else
                app.analysis_GraphicsRefresh.Visible = 0;
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
            app.elevationNPoints.Value     = num2str(app.mainApp.General.Elevation.Points);
            app.elevationForceSearch.Value = app.mainApp.General.Elevation.ForceSearch;
            app.elevationAPIServer.Value   = app.mainApp.General.Elevation.Server;

            if Elevation_checkEdition(app)
                app.analysis_ElevationRefresh.Visible = 1;
            else
                app.analysis_ElevationRefresh.Visible = 0;
            end
        end

        %-----------------------------------------------------------------%
        function editionFlag = Elevation_checkEdition(app)
            editionFlag = false;

            if ~strcmp(app.elevationNPoints.Value, app.DefaultValues.Elevation.Points)     || ...
               (app.elevationForceSearch.Value ~= app.DefaultValues.Elevation.ForceSearch) || ...
               ~strcmp(app.elevationAPIServer.Value, app.DefaultValues.Elevation.Server)
                
                editionFlag = true;
            end
        end

        %-----------------------------------------------------------------%
        function Folder_updatePanel(app)
            DataHub_POST = app.mainApp.General.fileFolder.DataHub_POST;    
            if isfolder(DataHub_POST)
                app.DataHubPOST.Value = DataHub_POST;
            end

            app.userPath.Value = app.mainApp.General.fileFolder.userPath;                
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appUtil.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            app.mainApp = mainApp;

            if app.isDocked
                app.GridLayout.Padding(4) = 30;
                app.DockModuleGroup.Visible = 1;
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

        % Selection change function: TabGroup
        function TabGroup_TabSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.TabGroup.SelectedTab, app.TabGroup.Children);
            jsBackDoor_Customizations(app, tabIndex)

        end

        % Image clicked function: tool_versionInfoRefresh
        function Toolbar_AppEnvRefreshButtonPushed(app, event)
            
            app.progressDialog.Visible = 'visible';

            [htmlContent, app.stableVersion, updatedModule] = util.HtmlTextGenerator.checkAvailableUpdate(app.mainApp.General, app.mainApp.rootFolder);
            appUtil.modalWindow(app.UIFigure, "info", htmlContent);
            app.tool_RFDataHubButton.Enable = ~ismember('RFDataHub', updatedModule);

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_RFDataHubButton
        function Toolbar_RFDataHubButtonPushed(app, event)
            
            if isequal(rmfield(app.mainApp.General.AppVersion.database, 'name'),  app.stableVersion.rfDataHub)
                app.tool_RFDataHubButton.Enable = 0;
                appUtil.modalWindow(app.UIFigure, 'warning', 'Módulo RFDataHub já atualizado!');
                return
            end

            d = appUtil.modalWindow(app.UIFigure, "progressdlg", 'Em andamento... esse processo demorará alguns minutos!');

            try
                appName = class.Constants.appName;
                rfDataHubLink = util.publicLink(appName, app.mainApp.rootFolder, 'RFDataHub');
                model.RFDataHub.update(appName, app.mainApp.rootFolder, app.mainApp.General.fileFolder.tempPath, rfDataHubLink)

                % Atualiza versão.
                global RFDataHub_info
                fieldList = fieldnames(RFDataHub_info);
                for ii = 1:numel(fieldList)
                    app.mainApp.General.AppVersion.database.(fieldList{ii}) = RFDataHub_info.(fieldList{ii});
                end

                app.stableVersion.rfDataHub = RFDataHub_info;
                app.tool_RFDataHubButton.Enable = 0;
                
            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end

            General_updatePanel(app)
            delete(d)

        end

        % Image clicked function: tool_simulationMode
        function Toolbar_SimulationModeButtonPushed(app, event)
            
            msgQuestion   = 'Deseja abrir arquivos de <b>simulação</b>?';
            userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            
            if strcmp(userSelection, 'Não')
                return
            end

            app.mainApp.General.operationMode.Simulation = true;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'simulationModeChanged')
            
        end

        % Image clicked function: tool_openDevTools
        function Toolbar_OpenDevToolsClicked(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'openDevTools')

        end

        % Callback function: analysis_FileRefresh, channelManualMode, 
        % ...and 4 other components
        function Config_FileParameterValueChanged(app, event)
            
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

                case app.analysis_FileRefresh
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

        % Callback function: InitialBW_kHz, analysis_GraphicsRefresh, 
        % ...and 5 other components
        function Config_GraphicsParameterValueChanged(app, event)
            
            switch event.Source
                case {app.imgFormat, app.imgResolution}
                    app.mainApp.General.Image = struct('Format', app.imgFormat.Value, 'Resolution', str2double(app.imgResolution.Value));

                case app.yOccupancyScale
                    app.mainApp.General.Plot.Axes.yOccupancyScale = app.yOccupancyScale.Value;
                    set(app.mainApp.UIAxes2, 'YScale', app.yOccupancyScale.Value)

                case app.InitialBW_kHz
                    app.mainApp.General.Detection.InitialBW_kHz  = app.InitialBW_kHz.Value;

                case app.openAuxiliarAppAsDocked
                    app.mainApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.mainApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;

                case app.analysis_GraphicsRefresh
                    app.mainApp.General.Image = struct('Format', app.DefaultValues.Graphics.Format, 'Resolution', app.DefaultValues.Graphics.Resolution);
            end

            app.mainApp.General_I.Image                     = app.mainApp.General.Image;
            app.mainApp.General_I.operationMode             = app.mainApp.General.operationMode;
            app.mainApp.General_I.Detection.InitialBW_kHz   = app.mainApp.General.Detection.InitialBW_kHz;
            app.mainApp.General_I.Plot.Axes.yOccupancyScale = app.mainApp.General.Plot.Axes.yOccupancyScale;

            saveGeneralSettings(app)
            Graphics_updatePanel(app)

        end

        % Callback function: analysis_ElevationRefresh, elevationAPIServer,
        % 
        % ...and 2 other components
        function Config_ElevationParameterValueChanged(app, event)

            switch event.Source
                case app.elevationNPoints
                    app.mainApp.General.Elevation.Points      = str2double(app.elevationNPoints.Value);

                case app.elevationForceSearch
                    app.mainApp.General.Elevation.ForceSearch = app.elevationForceSearch.Value;

                case app.elevationAPIServer
                    app.mainApp.General.Elevation.Server      = app.elevationAPIServer.Value;

                case app.analysis_ElevationRefresh
                    app.mainApp.General.Elevation = struct('Points',      str2double(app.DefaultValues.Elevation.Points), ...
                                                           'ForceSearch', app.DefaultValues.Elevation.ForceSearch,        ...
                                                           'Server',      app.DefaultValues.Elevation.Server);
            end

            app.mainApp.General_I.Elevation = app.mainApp.General.Elevation;
            saveGeneralSettings(app)
            Elevation_updatePanel(app)
            
        end

        % Image clicked function: DataHubPOSTButton, userPathButton
        function Config_FolderButtonPushed(app, event)
            
            try
                relatedFolder = eval(sprintf('app.%s.Value', event.Source.Tag));                    
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
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                figure(app.UIFigure)
            end

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
            app.Toolbar.ColumnWidth = {22, '1x', 22};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_openDevTools
            app.tool_openDevTools = uiimage(app.Toolbar);
            app.tool_openDevTools.ScaleMethod = 'none';
            app.tool_openDevTools.ImageClickedFcn = createCallbackFcn(app, @Toolbar_OpenDevToolsClicked, true);
            app.tool_openDevTools.Enable = 'off';
            app.tool_openDevTools.Tooltip = {'Abre DevTools'};
            app.tool_openDevTools.Layout.Row = 2;
            app.tool_openDevTools.Layout.Column = 3;
            app.tool_openDevTools.ImageSource = 'Debug_18.png';

            % Create tool_simulationMode
            app.tool_simulationMode = uiimage(app.Toolbar);
            app.tool_simulationMode.ScaleMethod = 'none';
            app.tool_simulationMode.ImageClickedFcn = createCallbackFcn(app, @Toolbar_SimulationModeButtonPushed, true);
            app.tool_simulationMode.Tooltip = {'Leitura arquivos de simulação'};
            app.tool_simulationMode.Layout.Row = 2;
            app.tool_simulationMode.Layout.Column = 1;
            app.tool_simulationMode.ImageSource = 'Import_16.png';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroup_TabSelectionChanged, true);
            app.TabGroup.Layout.Row = [3 4];
            app.TabGroup.Layout.Column = [2 3];

            % Create Tab1
            app.Tab1 = uitab(app.TabGroup);
            app.Tab1.AutoResizeChildren = 'off';
            app.Tab1.Title = 'ASPECTOS GERAIS';
            app.Tab1.BackgroundColor = 'none';

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1);
            app.Tab1Grid.ColumnWidth = {'1x', 22, 22};
            app.Tab1Grid.RowHeight = {17, '1x', 1, 22, 15};
            app.Tab1Grid.ColumnSpacing = 5;
            app.Tab1Grid.RowSpacing = 5;
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create versionInfoLabel
            app.versionInfoLabel = uilabel(app.Tab1Grid);
            app.versionInfoLabel.VerticalAlignment = 'bottom';
            app.versionInfoLabel.FontSize = 10;
            app.versionInfoLabel.Layout.Row = 1;
            app.versionInfoLabel.Layout.Column = 1;
            app.versionInfoLabel.Text = 'AMBIENTE:';

            % Create versionInfo
            app.versionInfo = uilabel(app.Tab1Grid);
            app.versionInfo.BackgroundColor = [1 1 1];
            app.versionInfo.VerticalAlignment = 'top';
            app.versionInfo.WordWrap = 'on';
            app.versionInfo.FontSize = 11;
            app.versionInfo.Layout.Row = 2;
            app.versionInfo.Layout.Column = [1 3];
            app.versionInfo.Interpreter = 'html';
            app.versionInfo.Text = '';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.Tab1Grid);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.openAuxiliarAppAsDocked.Enable = 'off';
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na janela principal do app';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.openAuxiliarAppAsDocked.Layout.Row = 4;
            app.openAuxiliarAppAsDocked.Layout.Column = 1;

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.Tab1Grid);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.openAuxiliarApp2Debug.Enable = 'off';
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.openAuxiliarApp2Debug.Layout.Row = 5;
            app.openAuxiliarApp2Debug.Layout.Column = 1;

            % Create tool_versionInfoRefresh
            app.tool_versionInfoRefresh = uiimage(app.Tab1Grid);
            app.tool_versionInfoRefresh.ScaleMethod = 'none';
            app.tool_versionInfoRefresh.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AppEnvRefreshButtonPushed, true);
            app.tool_versionInfoRefresh.Enable = 'off';
            app.tool_versionInfoRefresh.Tooltip = {'Verifica atualizações'};
            app.tool_versionInfoRefresh.Layout.Row = 1;
            app.tool_versionInfoRefresh.Layout.Column = 2;
            app.tool_versionInfoRefresh.VerticalAlignment = 'bottom';
            app.tool_versionInfoRefresh.ImageSource = 'Refresh_18.png';

            % Create tool_RFDataHubButton
            app.tool_RFDataHubButton = uiimage(app.Tab1Grid);
            app.tool_RFDataHubButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_RFDataHubButtonPushed, true);
            app.tool_RFDataHubButton.Enable = 'off';
            app.tool_RFDataHubButton.Tooltip = {'Atualiza RFDataHub'};
            app.tool_RFDataHubButton.Layout.Row = 1;
            app.tool_RFDataHubButton.Layout.Column = 3;
            app.tool_RFDataHubButton.ImageSource = 'mosaic_32.png';

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.AutoResizeChildren = 'off';
            app.Tab2.Title = 'ANÁLISE';
            app.Tab2.BackgroundColor = 'none';

            % Create Tab2Grid
            app.Tab2Grid = uigridlayout(app.Tab2);
            app.Tab2Grid.ColumnWidth = {'1x', 22};
            app.Tab2Grid.RowHeight = {17, 200, 22, 116, 22, '1x'};
            app.Tab2Grid.RowSpacing = 5;
            app.Tab2Grid.BackgroundColor = [1 1 1];

            % Create analysis_FileLabel
            app.analysis_FileLabel = uilabel(app.Tab2Grid);
            app.analysis_FileLabel.VerticalAlignment = 'bottom';
            app.analysis_FileLabel.FontSize = 10;
            app.analysis_FileLabel.Layout.Row = 1;
            app.analysis_FileLabel.Layout.Column = 1;
            app.analysis_FileLabel.Text = 'LEITURA DOS ARQUIVOS + IDENTIFICAÇÃO AUTOMÁTICA DE CANAIS E EMISSÕES';

            % Create analysis_FileRefresh
            app.analysis_FileRefresh = uiimage(app.Tab2Grid);
            app.analysis_FileRefresh.ScaleMethod = 'none';
            app.analysis_FileRefresh.ImageClickedFcn = createCallbackFcn(app, @Config_FileParameterValueChanged, true);
            app.analysis_FileRefresh.Visible = 'off';
            app.analysis_FileRefresh.Tooltip = {'Volta à configuração inicial'};
            app.analysis_FileRefresh.Layout.Row = 1;
            app.analysis_FileRefresh.Layout.Column = 2;
            app.analysis_FileRefresh.VerticalAlignment = 'bottom';
            app.analysis_FileRefresh.ImageSource = 'Refresh_18.png';

            % Create analysis_FilePanel
            app.analysis_FilePanel = uipanel(app.Tab2Grid);
            app.analysis_FilePanel.AutoResizeChildren = 'off';
            app.analysis_FilePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.analysis_FilePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.analysis_FilePanel.Layout.Row = 2;
            app.analysis_FilePanel.Layout.Column = [1 2];

            % Create analysis_FileGrid
            app.analysis_FileGrid = uigridlayout(app.analysis_FilePanel);
            app.analysis_FileGrid.ColumnWidth = {10, 90, '1x'};
            app.analysis_FileGrid.RowHeight = {17, 22, 22, 22, 22, 22, 22};
            app.analysis_FileGrid.ColumnSpacing = 0;
            app.analysis_FileGrid.RowSpacing = 5;
            app.analysis_FileGrid.BackgroundColor = [1 1 1];

            % Create mergeLabel1
            app.mergeLabel1 = uilabel(app.analysis_FileGrid);
            app.mergeLabel1.VerticalAlignment = 'bottom';
            app.mergeLabel1.WordWrap = 'on';
            app.mergeLabel1.FontSize = 11;
            app.mergeLabel1.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.mergeLabel1.Layout.Row = 1;
            app.mergeLabel1.Layout.Column = [1 3];
            app.mergeLabel1.Text = 'Metadados a serem ignorados na mesclagem de fluxos espectrais:';

            % Create mergeDataType
            app.mergeDataType = uicheckbox(app.analysis_FileGrid);
            app.mergeDataType.ValueChangedFcn = createCallbackFcn(app, @Config_FileParameterValueChanged, true);
            app.mergeDataType.Text = 'DataType';
            app.mergeDataType.FontSize = 11;
            app.mergeDataType.FontColor = [0.149 0.149 0.149];
            app.mergeDataType.Layout.Row = 2;
            app.mergeDataType.Layout.Column = 2;
            app.mergeDataType.Value = true;

            % Create mergeAntenna
            app.mergeAntenna = uicheckbox(app.analysis_FileGrid);
            app.mergeAntenna.ValueChangedFcn = createCallbackFcn(app, @Config_FileParameterValueChanged, true);
            app.mergeAntenna.Text = 'Antenna';
            app.mergeAntenna.FontSize = 11;
            app.mergeAntenna.FontColor = [0.149 0.149 0.149];
            app.mergeAntenna.Layout.Row = 3;
            app.mergeAntenna.Layout.Column = 2;

            % Create mergeLabel2
            app.mergeLabel2 = uilabel(app.analysis_FileGrid);
            app.mergeLabel2.VerticalAlignment = 'bottom';
            app.mergeLabel2.WordWrap = 'on';
            app.mergeLabel2.FontSize = 11;
            app.mergeLabel2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.mergeLabel2.Layout.Row = 4;
            app.mergeLabel2.Layout.Column = [1 3];
            app.mergeLabel2.Text = 'Distância máxima permitida entre pontos de monitoração em arquivos diferentes para mesclar fluxos espectrais (em metros):';

            % Create mergeDistance
            app.mergeDistance = uispinner(app.analysis_FileGrid);
            app.mergeDistance.Step = 50;
            app.mergeDistance.Limits = [50 Inf];
            app.mergeDistance.RoundFractionalValues = 'on';
            app.mergeDistance.ValueDisplayFormat = '%.0f';
            app.mergeDistance.ValueChangedFcn = createCallbackFcn(app, @Config_FileParameterValueChanged, true);
            app.mergeDistance.FontSize = 11;
            app.mergeDistance.FontColor = [0.149 0.149 0.149];
            app.mergeDistance.Layout.Row = 5;
            app.mergeDistance.Layout.Column = [1 2];
            app.mergeDistance.Value = 100;

            % Create channelManualMode
            app.channelManualMode = uicheckbox(app.analysis_FileGrid);
            app.channelManualMode.ValueChangedFcn = createCallbackFcn(app, @Config_FileParameterValueChanged, true);
            app.channelManualMode.Text = 'Não identificar automaticamente canais relacionados aos fluxos espectrais na leitura de arquivos.';
            app.channelManualMode.FontSize = 11;
            app.channelManualMode.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelManualMode.Layout.Row = 6;
            app.channelManualMode.Layout.Column = [1 3];

            % Create detectionManualMode
            app.detectionManualMode = uicheckbox(app.analysis_FileGrid);
            app.detectionManualMode.ValueChangedFcn = createCallbackFcn(app, @Config_FileParameterValueChanged, true);
            app.detectionManualMode.Text = 'Não detectar automaticamente emissões na geração preliminar do relatório (editável no modo RELATÓRIO).';
            app.detectionManualMode.FontSize = 11;
            app.detectionManualMode.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.detectionManualMode.Layout.Row = 7;
            app.detectionManualMode.Layout.Column = [1 3];

            % Create analysis_GraphicsLabel
            app.analysis_GraphicsLabel = uilabel(app.Tab2Grid);
            app.analysis_GraphicsLabel.VerticalAlignment = 'bottom';
            app.analysis_GraphicsLabel.FontSize = 10;
            app.analysis_GraphicsLabel.Layout.Row = 3;
            app.analysis_GraphicsLabel.Layout.Column = 1;
            app.analysis_GraphicsLabel.Text = 'IMAGENS + ESCALA PLOT + LARGURA PADRÃO DE EMISSÃO';

            % Create analysis_GraphicsRefresh
            app.analysis_GraphicsRefresh = uiimage(app.Tab2Grid);
            app.analysis_GraphicsRefresh.ScaleMethod = 'none';
            app.analysis_GraphicsRefresh.ImageClickedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.analysis_GraphicsRefresh.Visible = 'off';
            app.analysis_GraphicsRefresh.Tooltip = {'Volta à configuração inicial'};
            app.analysis_GraphicsRefresh.Layout.Row = 3;
            app.analysis_GraphicsRefresh.Layout.Column = 2;
            app.analysis_GraphicsRefresh.VerticalAlignment = 'bottom';
            app.analysis_GraphicsRefresh.ImageSource = 'Refresh_18.png';

            % Create analysis_GraphicsPanel
            app.analysis_GraphicsPanel = uipanel(app.Tab2Grid);
            app.analysis_GraphicsPanel.AutoResizeChildren = 'off';
            app.analysis_GraphicsPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.analysis_GraphicsPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.analysis_GraphicsPanel.Layout.Row = 4;
            app.analysis_GraphicsPanel.Layout.Column = [1 2];

            % Create analysis_GraphicsGrid
            app.analysis_GraphicsGrid = uigridlayout(app.analysis_GraphicsPanel);
            app.analysis_GraphicsGrid.ColumnWidth = {220, 100, 110, '1x'};
            app.analysis_GraphicsGrid.RowHeight = {17, 22, 22, 22};
            app.analysis_GraphicsGrid.RowSpacing = 5;
            app.analysis_GraphicsGrid.Padding = [10 10 10 5];
            app.analysis_GraphicsGrid.BackgroundColor = [1 1 1];

            % Create imgFormatLabel
            app.imgFormatLabel = uilabel(app.analysis_GraphicsGrid);
            app.imgFormatLabel.VerticalAlignment = 'bottom';
            app.imgFormatLabel.FontSize = 11;
            app.imgFormatLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.imgFormatLabel.Layout.Row = 1;
            app.imgFormatLabel.Layout.Column = 1;
            app.imgFormatLabel.Text = 'Formato da imagem (RELATÓRIO):';

            % Create imgFormat
            app.imgFormat = uidropdown(app.analysis_GraphicsGrid);
            app.imgFormat.Items = {'jpeg', 'png'};
            app.imgFormat.ValueChangedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.imgFormat.FontSize = 11;
            app.imgFormat.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.imgFormat.BackgroundColor = [1 1 1];
            app.imgFormat.Layout.Row = 2;
            app.imgFormat.Layout.Column = 1;
            app.imgFormat.Value = 'jpeg';

            % Create imgResolutionLabel
            app.imgResolutionLabel = uilabel(app.analysis_GraphicsGrid);
            app.imgResolutionLabel.VerticalAlignment = 'bottom';
            app.imgResolutionLabel.FontSize = 11;
            app.imgResolutionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.imgResolutionLabel.Layout.Row = 1;
            app.imgResolutionLabel.Layout.Column = 2;
            app.imgResolutionLabel.Text = 'Resolução (dpi):';

            % Create imgResolution
            app.imgResolution = uidropdown(app.analysis_GraphicsGrid);
            app.imgResolution.Items = {'100', '120', '150', '200'};
            app.imgResolution.ValueChangedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.imgResolution.FontSize = 11;
            app.imgResolution.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.imgResolution.BackgroundColor = [1 1 1];
            app.imgResolution.Layout.Row = 2;
            app.imgResolution.Layout.Column = 2;
            app.imgResolution.Value = '120';

            % Create yOccupancyScaleLabel
            app.yOccupancyScaleLabel = uilabel(app.analysis_GraphicsGrid);
            app.yOccupancyScaleLabel.VerticalAlignment = 'bottom';
            app.yOccupancyScaleLabel.FontSize = 11;
            app.yOccupancyScaleLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.yOccupancyScaleLabel.Layout.Row = 3;
            app.yOccupancyScaleLabel.Layout.Column = 1;
            app.yOccupancyScaleLabel.Text = 'Escala de ocupação do plot (PLAYBACK):';

            % Create yOccupancyScale
            app.yOccupancyScale = uidropdown(app.analysis_GraphicsGrid);
            app.yOccupancyScale.Items = {'linear', 'log'};
            app.yOccupancyScale.ValueChangedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.yOccupancyScale.FontSize = 11;
            app.yOccupancyScale.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.yOccupancyScale.BackgroundColor = [1 1 1];
            app.yOccupancyScale.Layout.Row = 4;
            app.yOccupancyScale.Layout.Column = 1;
            app.yOccupancyScale.Value = 'log';

            % Create InitialBW_kHzLabel
            app.InitialBW_kHzLabel = uilabel(app.analysis_GraphicsGrid);
            app.InitialBW_kHzLabel.VerticalAlignment = 'bottom';
            app.InitialBW_kHzLabel.WordWrap = 'on';
            app.InitialBW_kHzLabel.FontSize = 11;
            app.InitialBW_kHzLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.InitialBW_kHzLabel.Layout.Row = 3;
            app.InitialBW_kHzLabel.Layout.Column = [2 4];
            app.InitialBW_kHzLabel.Text = 'Largura de emissão em kHz para emissão criada pelo método "DataTip" (PLAYBACK):';

            % Create InitialBW_kHz
            app.InitialBW_kHz = uispinner(app.analysis_GraphicsGrid);
            app.InitialBW_kHz.Step = 50;
            app.InitialBW_kHz.Limits = [0 1000];
            app.InitialBW_kHz.RoundFractionalValues = 'on';
            app.InitialBW_kHz.ValueDisplayFormat = '%.0f';
            app.InitialBW_kHz.ValueChangedFcn = createCallbackFcn(app, @Config_GraphicsParameterValueChanged, true);
            app.InitialBW_kHz.FontSize = 11;
            app.InitialBW_kHz.FontColor = [0.149 0.149 0.149];
            app.InitialBW_kHz.Layout.Row = 4;
            app.InitialBW_kHz.Layout.Column = 2;

            % Create analysis_ElevationLabel
            app.analysis_ElevationLabel = uilabel(app.Tab2Grid);
            app.analysis_ElevationLabel.VerticalAlignment = 'bottom';
            app.analysis_ElevationLabel.FontSize = 10;
            app.analysis_ElevationLabel.Layout.Row = 5;
            app.analysis_ElevationLabel.Layout.Column = 1;
            app.analysis_ElevationLabel.Text = 'ELEVAÇÃO';

            % Create analysis_ElevationRefresh
            app.analysis_ElevationRefresh = uiimage(app.Tab2Grid);
            app.analysis_ElevationRefresh.ScaleMethod = 'none';
            app.analysis_ElevationRefresh.ImageClickedFcn = createCallbackFcn(app, @Config_ElevationParameterValueChanged, true);
            app.analysis_ElevationRefresh.Visible = 'off';
            app.analysis_ElevationRefresh.Layout.Row = 5;
            app.analysis_ElevationRefresh.Layout.Column = 2;
            app.analysis_ElevationRefresh.VerticalAlignment = 'bottom';
            app.analysis_ElevationRefresh.ImageSource = 'Refresh_18.png';

            % Create analysis_ElevationPanel
            app.analysis_ElevationPanel = uipanel(app.Tab2Grid);
            app.analysis_ElevationPanel.AutoResizeChildren = 'off';
            app.analysis_ElevationPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.analysis_ElevationPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.analysis_ElevationPanel.Layout.Row = 6;
            app.analysis_ElevationPanel.Layout.Column = [1 2];

            % Create analysis_ElevationGrid
            app.analysis_ElevationGrid = uigridlayout(app.analysis_ElevationPanel);
            app.analysis_ElevationGrid.ColumnWidth = {220, 110, '1x'};
            app.analysis_ElevationGrid.RowHeight = {17, 22, 36};
            app.analysis_ElevationGrid.RowSpacing = 5;
            app.analysis_ElevationGrid.Padding = [10 10 10 5];
            app.analysis_ElevationGrid.BackgroundColor = [1 1 1];

            % Create elevationAPIServerLabel
            app.elevationAPIServerLabel = uilabel(app.analysis_ElevationGrid);
            app.elevationAPIServerLabel.VerticalAlignment = 'bottom';
            app.elevationAPIServerLabel.FontSize = 11;
            app.elevationAPIServerLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationAPIServerLabel.Layout.Row = 1;
            app.elevationAPIServerLabel.Layout.Column = 1;
            app.elevationAPIServerLabel.Text = 'Fonte:';

            % Create elevationAPIServer
            app.elevationAPIServer = uidropdown(app.analysis_ElevationGrid);
            app.elevationAPIServer.Items = {'Open-Elevation', 'MathWorks WMS Server'};
            app.elevationAPIServer.ValueChangedFcn = createCallbackFcn(app, @Config_ElevationParameterValueChanged, true);
            app.elevationAPIServer.FontSize = 11;
            app.elevationAPIServer.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationAPIServer.BackgroundColor = [1 1 1];
            app.elevationAPIServer.Layout.Row = 2;
            app.elevationAPIServer.Layout.Column = 1;
            app.elevationAPIServer.Value = 'Open-Elevation';

            % Create elevationNPointsLabel
            app.elevationNPointsLabel = uilabel(app.analysis_ElevationGrid);
            app.elevationNPointsLabel.VerticalAlignment = 'bottom';
            app.elevationNPointsLabel.FontSize = 11;
            app.elevationNPointsLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationNPointsLabel.Layout.Row = 1;
            app.elevationNPointsLabel.Layout.Column = 2;
            app.elevationNPointsLabel.Text = 'Pontos enlace:';

            % Create elevationNPoints
            app.elevationNPoints = uidropdown(app.analysis_ElevationGrid);
            app.elevationNPoints.Items = {'64', '128', '256', '512', '1024'};
            app.elevationNPoints.ValueChangedFcn = createCallbackFcn(app, @Config_ElevationParameterValueChanged, true);
            app.elevationNPoints.FontSize = 11;
            app.elevationNPoints.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationNPoints.BackgroundColor = [1 1 1];
            app.elevationNPoints.Layout.Row = 2;
            app.elevationNPoints.Layout.Column = 2;
            app.elevationNPoints.Value = '256';

            % Create elevationForceSearch
            app.elevationForceSearch = uicheckbox(app.analysis_ElevationGrid);
            app.elevationForceSearch.ValueChangedFcn = createCallbackFcn(app, @Config_ElevationParameterValueChanged, true);
            app.elevationForceSearch.Text = 'Força consulta ao servidor (ignorando eventual informação em cache).';
            app.elevationForceSearch.WordWrap = 'on';
            app.elevationForceSearch.FontSize = 11;
            app.elevationForceSearch.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationForceSearch.Layout.Row = 3;
            app.elevationForceSearch.Layout.Column = [1 3];

            % Create Tab3
            app.Tab3 = uitab(app.TabGroup);
            app.Tab3.AutoResizeChildren = 'off';
            app.Tab3.Title = 'MAPEAMENTO DE PASTAS';
            app.Tab3.BackgroundColor = 'none';

            % Create Tab3Grid
            app.Tab3Grid = uigridlayout(app.Tab3);
            app.Tab3Grid.ColumnWidth = {'1x', 20};
            app.Tab3Grid.RowHeight = {17, 22, 22, 22, '1x'};
            app.Tab3Grid.ColumnSpacing = 5;
            app.Tab3Grid.RowSpacing = 5;
            app.Tab3Grid.BackgroundColor = [1 1 1];

            % Create DATAHUBPOSTLabel
            app.DATAHUBPOSTLabel = uilabel(app.Tab3Grid);
            app.DATAHUBPOSTLabel.VerticalAlignment = 'bottom';
            app.DATAHUBPOSTLabel.FontSize = 10;
            app.DATAHUBPOSTLabel.Layout.Row = 1;
            app.DATAHUBPOSTLabel.Layout.Column = 1;
            app.DATAHUBPOSTLabel.Text = 'DATAHUB - POST:';

            % Create DataHubPOST
            app.DataHubPOST = uieditfield(app.Tab3Grid, 'text');
            app.DataHubPOST.Editable = 'off';
            app.DataHubPOST.FontSize = 11;
            app.DataHubPOST.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataHubPOST.Layout.Row = 2;
            app.DataHubPOST.Layout.Column = 1;

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.Tab3Grid);
            app.DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Enable = 'off';
            app.DataHubPOSTButton.Layout.Row = 2;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'OpenFile_36x36.png';

            % Create userPathLabel
            app.userPathLabel = uilabel(app.Tab3Grid);
            app.userPathLabel.VerticalAlignment = 'bottom';
            app.userPathLabel.FontSize = 10;
            app.userPathLabel.Layout.Row = 3;
            app.userPathLabel.Layout.Column = 1;
            app.userPathLabel.Text = 'PASTA DO USUÁRIO:';

            % Create userPath
            app.userPath = uieditfield(app.Tab3Grid, 'text');
            app.userPath.Editable = 'off';
            app.userPath.FontSize = 11;
            app.userPath.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.userPath.Layout.Row = 4;
            app.userPath.Layout.Column = 1;

            % Create userPathButton
            app.userPathButton = uiimage(app.Tab3Grid);
            app.userPathButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.userPathButton.Tag = 'userPath';
            app.userPathButton.Enable = 'off';
            app.userPathButton.Layout.Row = 4;
            app.userPathButton.Layout.Column = 2;
            app.userPathButton.ImageSource = 'OpenFile_36x36.png';

            % Create DockModuleGroup
            app.DockModuleGroup = uigridlayout(app.GridLayout);
            app.DockModuleGroup.RowHeight = {'1x'};
            app.DockModuleGroup.ColumnSpacing = 2;
            app.DockModuleGroup.Padding = [5 2 5 2];
            app.DockModuleGroup.Visible = 'off';
            app.DockModuleGroup.Layout.Row = [2 3];
            app.DockModuleGroup.Layout.Column = [3 4];
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
