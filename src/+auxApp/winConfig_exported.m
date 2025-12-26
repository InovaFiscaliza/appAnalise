classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        DockModule                   matlab.ui.container.GridLayout
        dockModule_Undock            matlab.ui.control.Image
        dockModule_Close             matlab.ui.control.Image
        SubTabGroup                  matlab.ui.container.TabGroup
        SubTab1                      matlab.ui.container.Tab
        SubGrid1                     matlab.ui.container.GridLayout
        tool_RFDataHubButton         matlab.ui.control.Image
        tool_versionInfoRefresh      matlab.ui.control.Image
        openAuxiliarApp2Debug        matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked      matlab.ui.control.CheckBox
        versionInfo                  matlab.ui.control.Label
        versionInfoLabel             matlab.ui.control.Label
        SubTab2                      matlab.ui.container.Tab
        SubGrid2                     matlab.ui.container.GridLayout
        analysis_ElevationPanel      matlab.ui.container.Panel
        analysis_ElevationGrid       matlab.ui.container.GridLayout
        elevationForceSearch         matlab.ui.control.CheckBox
        elevationNPoints             matlab.ui.control.DropDown
        elevationNPointsLabel        matlab.ui.control.Label
        elevationAPIServer           matlab.ui.control.DropDown
        elevationAPIServerLabel      matlab.ui.control.Label
        configAnalysisLabel3         matlab.ui.control.Label
        analysis_GraphicsPanel       matlab.ui.container.Panel
        analysis_GraphicsGrid        matlab.ui.container.GridLayout
        InitialBW_kHz                matlab.ui.control.Spinner
        InitialBW_kHzLabel           matlab.ui.control.Label
        yOccupancyScale              matlab.ui.control.DropDown
        yOccupancyScaleLabel         matlab.ui.control.Label
        configAnalysisLabel2         matlab.ui.control.Label
        analysis_FilePanel           matlab.ui.container.Panel
        analysis_FileGrid            matlab.ui.container.GridLayout
        detectionManualMode          matlab.ui.control.CheckBox
        channelManualMode            matlab.ui.control.CheckBox
        mergeDistance                matlab.ui.control.Spinner
        mergeLabel2                  matlab.ui.control.Label
        mergeAntenna                 matlab.ui.control.CheckBox
        mergeDataType                matlab.ui.control.CheckBox
        mergeLabel1                  matlab.ui.control.Label
        configAnalysisRefresh        matlab.ui.control.Image
        configAnalysisLabel1         matlab.ui.control.Label
        SubTab3                      matlab.ui.container.Tab
        SubGrid3                     matlab.ui.container.GridLayout
        reportPanel                  matlab.ui.container.Panel
        reportGrid_2                 matlab.ui.container.GridLayout
        prjFileCompressionMode       matlab.ui.control.DropDown
        prjFileCompressionModeLabel  matlab.ui.control.Label
        reportBinningPanel           matlab.ui.container.Panel
        reportBinningGrid            matlab.ui.container.GridLayout
        reportBinningFcn             matlab.ui.control.DropDown
        reportBinningFcnLabel        matlab.ui.control.Label
        reportBinningLength          matlab.ui.control.Spinner
        reportBinningLengthLabel     matlab.ui.control.Label
        reportBinningLabel           matlab.ui.control.Label
        reportImgDpi                 matlab.ui.control.DropDown
        reportImgFormat              matlab.ui.control.DropDown
        reportImageLabel             matlab.ui.control.Label
        reportBasemap                matlab.ui.control.DropDown
        reportBasemapLabel           matlab.ui.control.Label
        reportDocType                matlab.ui.control.DropDown
        reportDocTypeLabel           matlab.ui.control.Label
        reportLabel                  matlab.ui.control.Label
        eFiscalizaPanel              matlab.ui.container.Panel
        eFiscalizaGrid               matlab.ui.container.GridLayout
        reportUnit                   matlab.ui.control.DropDown
        reportUnitLabel              matlab.ui.control.Label
        reportSystem                 matlab.ui.control.DropDown
        reportSystemLabel            matlab.ui.control.Label
        eFiscalizaRefresh            matlab.ui.control.Image
        eFiscalizaLabel              matlab.ui.control.Label
        SubTab4                      matlab.ui.container.Tab
        SubGrid4                     matlab.ui.container.GridLayout
        userPathButton               matlab.ui.control.Image
        userPath                     matlab.ui.control.EditField
        userPathLabel                matlab.ui.control.Label
        DataHubPOSTButton            matlab.ui.control.Image
        DataHubPOST                  matlab.ui.control.EditField
        DATAHUBPOSTLabel             matlab.ui.control.Label
        Toolbar                      matlab.ui.container.GridLayout
        tool_simulationMode          matlab.ui.control.Image
        tool_openDevTools            matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        defaultValues
        stableVersion
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
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
                        app.progressDialog = ui.ProgressDialog(app.jsBackDoor);
                    end
                    customizationStatus = [false, false, false, false];

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
                                elToModify = {app.DockModule};
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
                            updatePanel_Analysis(app)

                        case 3
                            updatePanel_Report(app)

                        case 4
                            if ~strcmp(app.mainApp.executionMode, 'webApp')
                                set([app.DataHubPOSTButton, app.userPathButton], 'Enable', 1)
                            end
                            updatePanel_Folder(app)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            projectFolder     = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            projectFilePath   = fullfile(projectFolder, 'GeneralSettings.json');
            projectGeneral    = jsondecode(fileread(projectFilePath));

            app.defaultValues = struct('Elevation', projectGeneral.Elevation, ...
                                       'Merge',     projectGeneral.Merge, ...
                                       'Channel',   projectGeneral.Channel, ...
                                       'Detection', projectGeneral.Detection, ...
                                       'Plot',      projectGeneral.Plot, ...
                                       'Report',    projectGeneral.Report);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable       = 1;
                app.tool_openDevTools.Enable       = 1;                
                app.tool_versionInfoRefresh.Enable = 1;
                app.openAuxiliarAppAsDocked.Enable = 1;
            end

            if ~isdeployed
                app.openAuxiliarApp2Debug.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            % Versão:
            appInfo = util.HtmlTextGenerator.AppInfo( ...
                app.mainApp.General, ...
                app.mainApp.rootFolder, ...
                app.mainApp.executionMode, ...
                app.mainApp.renderCount, ...
                "textview" ...
            );
            ui.TextView.update(app.versionInfo, appInfo);

            % Modo de operação:
            app.openAuxiliarAppAsDocked.Value = app.mainApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value   = app.mainApp.General.operationMode.Debug;
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel_Analysis(app)
            % Mesclagem de fluxos espectrais
            switch app.mainApp.General.Merge.DataType
                case 'keep';   app.mergeDataType.Value = 0;
                case 'remove'; app.mergeDataType.Value = 1;
            end

            switch app.mainApp.General.Merge.Antenna
                case 'keep';   app.mergeAntenna.Value = 0;
                case 'remove'; app.mergeAntenna.Value = 1;
            end

            app.mergeDistance.Value        = app.mainApp.General.Merge.Distance;

            % PLAYBACK AXES
            app.yOccupancyScale.Value      = app.mainApp.General.Plot.Axes.yOccupancyScale;
            
            % DETECTION
            app.channelManualMode.Value    = app.mainApp.General.Channel.ManualMode;
            app.detectionManualMode.Value  = app.mainApp.General.Detection.ManualMode;
            app.InitialBW_kHz.Value        = app.mainApp.General.Detection.InitialBW_kHz;

            % ELEVATION
            app.elevationNPoints.Value     = num2str(app.mainApp.General.Elevation.Points);
            app.elevationForceSearch.Value = app.mainApp.General.Elevation.ForceSearch;
            app.elevationAPIServer.Value   = app.mainApp.General.Elevation.Server;

            app.configAnalysisRefresh.Visible = checkEdition(app, 'ANALYSIS');
        end

        %-----------------------------------------------------------------%
        function updatePanel_Report(app)
            app.reportSystem.Value        = app.mainApp.General.Report.system;
            set(app.reportUnit, 'Items', app.mainApp.General.eFiscaliza.defaultValues.unit, 'Value', app.mainApp.General.Report.unit)
            
            app.reportDocType.Value       = app.mainApp.General.Report.Document;
            app.reportBasemap.Value       = app.mainApp.General.Report.Basemap;
            app.reportImgFormat.Value     = app.mainApp.General.Report.Image.Format;
            app.reportImgDpi.Value        = num2str(app.mainApp.General.Report.Image.Resolution);
            app.reportBinningLength.Value = app.mainApp.General.Report.DataBinning.length_m;
            app.reportBinningFcn.Value    = app.mainApp.General.Report.DataBinning.function;

            if ismember(app.mainApp.General.Report.outputCompressionMode, app.prjFileCompressionMode.Items)
                app.prjFileCompressionMode.Value = app.mainApp.General.Report.outputCompressionMode;
            end

            app.eFiscalizaRefresh.Visible = checkEdition(app, 'REPORT');
        end

        %-----------------------------------------------------------------%
        function updatePanel_Folder(app)
            DataHub_POST = app.mainApp.General.fileFolder.DataHub_POST;    
            if isfolder(DataHub_POST)
                app.DataHubPOST.Value = DataHub_POST;
            end

            app.userPath.Value = app.mainApp.General.fileFolder.userPath;                
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app, tabName)
            editionFlag   = false;
            currentValues = struct('Elevation', app.mainApp.General.Elevation, ...
                                   'Merge',     app.mainApp.General.Merge, ...
                                   'Channel',   app.mainApp.General.Channel, ...
                                   'Detection', app.mainApp.General.Detection, ...
                                   'Plot',      app.mainApp.General.Plot, ...
                                   'Report',    app.mainApp.General.Report);

            switch tabName
                case 'ANALYSIS'
                    if ~isequal(rmfield(currentValues, 'Report'), rmfield(app.defaultValues, 'Report'))
                        editionFlag = true;
                    end
                case 'REPORT'
                    if ~isequal(currentValues.Report, app.defaultValues.Report)
                        editionFlag = true;
                    end
            end
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
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
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'CONFIG')
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

        % Selection change function: SubTabGroup
        function SubTabGroup_TabSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Image clicked function: tool_versionInfoRefresh
        function Toolbar_AppEnvRefreshButtonPushed(app, event)
            
            app.progressDialog.Visible = 'visible';

            [htmlContent, app.stableVersion, updatedModule] = util.HtmlTextGenerator.checkAvailableUpdate(app.mainApp.General, app.mainApp.rootFolder);
            ui.Dialog(app.UIFigure, "info", htmlContent);
            app.tool_RFDataHubButton.Enable = ~ismember('RFDataHub', updatedModule);

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_simulationMode
        function Toolbar_SimulationModeButtonPushed(app, event)
            
            msgQuestion   = 'Deseja abrir arquivos de <b>simulação</b>?';
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            
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

        % Image clicked function: tool_RFDataHubButton
        function Toolbar_RFDataHubButtonPushed(app, event)
            
            if isequal(rmfield(app.mainApp.General.AppVersion.database, 'name'),  app.stableVersion.rfDataHub)
                app.tool_RFDataHubButton.Enable = 0;
                ui.Dialog(app.UIFigure, 'warning', 'Módulo RFDataHub já atualizado!');
                return
            end

            d = ui.Dialog(app.UIFigure, "progressdlg", 'Em andamento... esse processo pode demorar alguns minutos!');

            try
                appName = class.Constants.appName;
                rfDataHubLink = util.publicLink(appName, app.mainApp.rootFolder, 'RFDataHub');
                model.RFDataHub.update(appName, app.mainApp.rootFolder, app.mainApp.General.fileFolder.tempPath, rfDataHubLink)

                % Atualiza versão.
                global RFDataHub_info

                app.mainApp.General.AppVersion.database      = RFDataHub_info;
                app.mainApp.General.AppVersion.database.name = 'RFDataHub';
                app.stableVersion.rfDataHub = RFDataHub_info;
                app.tool_RFDataHubButton.Enable = 0;

                ipcMainMatlabCallsHandler(app.mainApp, app, 'onRFDataHubUpdate')
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            applyInitialLayout(app)
            delete(d)

        end

        % Value changed function: openAuxiliarApp2Debug, 
        % ...and 1 other component
        function Config_GeneralParameterValueChanged(app, event)
            
            switch event.Source
                case app.openAuxiliarAppAsDocked
                    app.mainApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.mainApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;
            end

            app.mainApp.General_I.operationMode = app.mainApp.General.operationMode;
            saveGeneralSettings(app)

        end

        % Image clicked function: configAnalysisRefresh
        function Config_AnalysisRefreshImageClicked(app, event)
            
            if ~checkEdition(app, 'ANALYSIS')
                app.configAnalysisRefresh.Visible = 0;
                return

            else
                app.mainApp.General.Merge     = app.defaultValues.Merge;                    
                app.mainApp.General.Channel   = app.defaultValues.Channel;
                app.mainApp.General.Detection = app.defaultValues.Detection;
                app.mainApp.General.Elevation = app.defaultValues.Elevation;
                app.mainApp.General.Plot      = app.defaultValues.Plot;

                updatePanel_Analysis(app)
                saveGeneralSettings(app)
            end

        end

        % Value changed function: InitialBW_kHz, channelManualMode, 
        % ...and 8 other components
        function Config_AnalysisParameterValueChanged(app, event)
            
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

                case app.yOccupancyScale
                    app.mainApp.General.Plot.Axes.yOccupancyScale = app.yOccupancyScale.Value;
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onYAxesScaleChange')

                case app.InitialBW_kHz
                    app.mainApp.General.Detection.InitialBW_kHz  = app.InitialBW_kHz.Value;

                case app.elevationNPoints
                    app.mainApp.General.Elevation.Points = str2double(app.elevationNPoints.Value);

                case app.elevationForceSearch
                    app.mainApp.General.Elevation.ForceSearch = app.elevationForceSearch.Value;

                case app.elevationAPIServer
                    app.mainApp.General.Elevation.Server = app.elevationAPIServer.Value;
            end

            app.mainApp.General_I.Merge     = app.mainApp.General.Merge;
            app.mainApp.General_I.Channel   = app.mainApp.General.Channel;
            app.mainApp.General_I.Detection = app.mainApp.General.Detection;
            app.mainApp.General_I.Elevation = app.mainApp.General.Elevation;
            app.mainApp.General_I.Plot      = app.mainApp.General.Plot;

            saveGeneralSettings(app)
            updatePanel_Analysis(app)  

        end

        % Image clicked function: eFiscalizaRefresh
        function Config_ProjectRefreshImageClicked(app, event)
            
            if ~checkEdition(app, 'REPORT')
                app.eFiscalizaRefresh.Visible = 0;
                return
            
            else
                app.mainApp.General.Report   = app.defaultValues.Report;
                app.mainApp.General_I.Report = app.mainApp.General.Report;
                
                updatePanel_Report(app)
                saveGeneralSettings(app)
            end

        end

        % Value changed function: prjFileCompressionMode, reportBasemap, 
        % ...and 7 other components
        function Config_ProjectParameterValueChanged(app, event)
            
            switch event.Source
                case app.reportSystem
                    app.mainApp.General.Report.system = event.Value;

                case app.reportUnit
                    app.mainApp.General.Report.unit = event.Value;

                case app.reportDocType
                    app.mainApp.General.Report.Document = event.Value;

                case app.reportBasemap
                    app.mainApp.General.Report.Basemap = event.Value;

                case app.reportImgFormat
                    app.mainApp.General.Report.Image.Format = event.Value;

                case app.reportImgDpi
                    app.mainApp.General.Report.Image.Resolution = str2double(event.Value);

                case app.reportBinningLength
                    app.mainApp.General.Report.DataBinning.length_m = event.Value;

                case app.reportBinningFcn
                    app.mainApp.General.Report.DataBinning.function = event.Value;

                case app.prjFileCompressionMode
                    app.mainApp.General.Report.outputCompressionMode = event.Value;
            end

            app.mainApp.General_I.Report = app.mainApp.General.Report;

            updatePanel_Report(app)
            saveGeneralSettings(app)

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
                                ui.Dialog(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - POST", do appAnalise.');
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
                updatePanel_Folder(app)
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

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @SubTabGroup_TabSelectionChanged, true);
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = [2 3];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'ASPECTOS GERAIS';
            app.SubTab1.BackgroundColor = 'none';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {'1x', 22, 22};
            app.SubGrid1.RowHeight = {17, '1x', 1, 22, 15};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create versionInfoLabel
            app.versionInfoLabel = uilabel(app.SubGrid1);
            app.versionInfoLabel.VerticalAlignment = 'bottom';
            app.versionInfoLabel.FontSize = 10;
            app.versionInfoLabel.Layout.Row = 1;
            app.versionInfoLabel.Layout.Column = 1;
            app.versionInfoLabel.Text = 'AMBIENTE:';

            % Create versionInfo
            app.versionInfo = uilabel(app.SubGrid1);
            app.versionInfo.BackgroundColor = [1 1 1];
            app.versionInfo.VerticalAlignment = 'top';
            app.versionInfo.WordWrap = 'on';
            app.versionInfo.FontSize = 11;
            app.versionInfo.Layout.Row = 2;
            app.versionInfo.Layout.Column = [1 3];
            app.versionInfo.Interpreter = 'html';
            app.versionInfo.Text = '';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.SubGrid1);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @Config_GeneralParameterValueChanged, true);
            app.openAuxiliarAppAsDocked.Enable = 'off';
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na janela principal do app';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.openAuxiliarAppAsDocked.Layout.Row = 4;
            app.openAuxiliarAppAsDocked.Layout.Column = 1;

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.SubGrid1);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @Config_GeneralParameterValueChanged, true);
            app.openAuxiliarApp2Debug.Enable = 'off';
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.openAuxiliarApp2Debug.Layout.Row = 5;
            app.openAuxiliarApp2Debug.Layout.Column = 1;

            % Create tool_versionInfoRefresh
            app.tool_versionInfoRefresh = uiimage(app.SubGrid1);
            app.tool_versionInfoRefresh.ScaleMethod = 'none';
            app.tool_versionInfoRefresh.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AppEnvRefreshButtonPushed, true);
            app.tool_versionInfoRefresh.Enable = 'off';
            app.tool_versionInfoRefresh.Tooltip = {'Verifica atualizações'};
            app.tool_versionInfoRefresh.Layout.Row = 1;
            app.tool_versionInfoRefresh.Layout.Column = 2;
            app.tool_versionInfoRefresh.VerticalAlignment = 'bottom';
            app.tool_versionInfoRefresh.ImageSource = 'Refresh_18.png';

            % Create tool_RFDataHubButton
            app.tool_RFDataHubButton = uiimage(app.SubGrid1);
            app.tool_RFDataHubButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_RFDataHubButtonPushed, true);
            app.tool_RFDataHubButton.Enable = 'off';
            app.tool_RFDataHubButton.Tooltip = {'Atualiza RFDataHub'};
            app.tool_RFDataHubButton.Layout.Row = 1;
            app.tool_RFDataHubButton.Layout.Column = 3;
            app.tool_RFDataHubButton.ImageSource = 'mosaic_32.png';

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'ANÁLISE';
            app.SubTab2.BackgroundColor = 'none';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {'1x', 22};
            app.SubGrid2.RowHeight = {17, 200, 22, 116, 22, '1x'};
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create configAnalysisLabel1
            app.configAnalysisLabel1 = uilabel(app.SubGrid2);
            app.configAnalysisLabel1.VerticalAlignment = 'bottom';
            app.configAnalysisLabel1.FontSize = 10;
            app.configAnalysisLabel1.Layout.Row = 1;
            app.configAnalysisLabel1.Layout.Column = 1;
            app.configAnalysisLabel1.Text = 'LEITURA DOS ARQUIVOS + IDENTIFICAÇÃO AUTOMÁTICA DE CANAIS E EMISSÕES';

            % Create configAnalysisRefresh
            app.configAnalysisRefresh = uiimage(app.SubGrid2);
            app.configAnalysisRefresh.ScaleMethod = 'none';
            app.configAnalysisRefresh.ImageClickedFcn = createCallbackFcn(app, @Config_AnalysisRefreshImageClicked, true);
            app.configAnalysisRefresh.Visible = 'off';
            app.configAnalysisRefresh.Tooltip = {'Volta à configuração inicial'};
            app.configAnalysisRefresh.Layout.Row = 1;
            app.configAnalysisRefresh.Layout.Column = 2;
            app.configAnalysisRefresh.VerticalAlignment = 'bottom';
            app.configAnalysisRefresh.ImageSource = 'Refresh_18.png';

            % Create analysis_FilePanel
            app.analysis_FilePanel = uipanel(app.SubGrid2);
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
            app.mergeDataType.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.mergeDataType.Text = 'DataType';
            app.mergeDataType.FontSize = 11;
            app.mergeDataType.FontColor = [0.149 0.149 0.149];
            app.mergeDataType.Layout.Row = 2;
            app.mergeDataType.Layout.Column = 2;
            app.mergeDataType.Value = true;

            % Create mergeAntenna
            app.mergeAntenna = uicheckbox(app.analysis_FileGrid);
            app.mergeAntenna.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
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
            app.mergeDistance.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.mergeDistance.FontSize = 11;
            app.mergeDistance.FontColor = [0.149 0.149 0.149];
            app.mergeDistance.Layout.Row = 5;
            app.mergeDistance.Layout.Column = [1 2];
            app.mergeDistance.Value = 100;

            % Create channelManualMode
            app.channelManualMode = uicheckbox(app.analysis_FileGrid);
            app.channelManualMode.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.channelManualMode.Text = 'Não identificar automaticamente canais relacionados aos fluxos espectrais na leitura de arquivos.';
            app.channelManualMode.FontSize = 11;
            app.channelManualMode.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelManualMode.Layout.Row = 6;
            app.channelManualMode.Layout.Column = [1 3];

            % Create detectionManualMode
            app.detectionManualMode = uicheckbox(app.analysis_FileGrid);
            app.detectionManualMode.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.detectionManualMode.Text = 'Não detectar automaticamente emissões na geração preliminar do relatório (editável no modo RELATÓRIO).';
            app.detectionManualMode.FontSize = 11;
            app.detectionManualMode.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.detectionManualMode.Layout.Row = 7;
            app.detectionManualMode.Layout.Column = [1 3];

            % Create configAnalysisLabel2
            app.configAnalysisLabel2 = uilabel(app.SubGrid2);
            app.configAnalysisLabel2.VerticalAlignment = 'bottom';
            app.configAnalysisLabel2.FontSize = 10;
            app.configAnalysisLabel2.Layout.Row = 3;
            app.configAnalysisLabel2.Layout.Column = 1;
            app.configAnalysisLabel2.Text = 'ESCALA PLOT + LARGURA PADRÃO DE EMISSÃO';

            % Create analysis_GraphicsPanel
            app.analysis_GraphicsPanel = uipanel(app.SubGrid2);
            app.analysis_GraphicsPanel.AutoResizeChildren = 'off';
            app.analysis_GraphicsPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.analysis_GraphicsPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.analysis_GraphicsPanel.Layout.Row = 4;
            app.analysis_GraphicsPanel.Layout.Column = [1 2];

            % Create analysis_GraphicsGrid
            app.analysis_GraphicsGrid = uigridlayout(app.analysis_GraphicsPanel);
            app.analysis_GraphicsGrid.ColumnWidth = {110, '1x'};
            app.analysis_GraphicsGrid.RowHeight = {17, 22, 22, 22};
            app.analysis_GraphicsGrid.RowSpacing = 5;
            app.analysis_GraphicsGrid.Padding = [10 10 10 5];
            app.analysis_GraphicsGrid.BackgroundColor = [1 1 1];

            % Create yOccupancyScaleLabel
            app.yOccupancyScaleLabel = uilabel(app.analysis_GraphicsGrid);
            app.yOccupancyScaleLabel.VerticalAlignment = 'bottom';
            app.yOccupancyScaleLabel.FontSize = 11;
            app.yOccupancyScaleLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.yOccupancyScaleLabel.Layout.Row = 1;
            app.yOccupancyScaleLabel.Layout.Column = [1 2];
            app.yOccupancyScaleLabel.Text = 'Escala de ocupação do plot (PLAYBACK):';

            % Create yOccupancyScale
            app.yOccupancyScale = uidropdown(app.analysis_GraphicsGrid);
            app.yOccupancyScale.Items = {'linear', 'log'};
            app.yOccupancyScale.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.yOccupancyScale.FontSize = 11;
            app.yOccupancyScale.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.yOccupancyScale.BackgroundColor = [1 1 1];
            app.yOccupancyScale.Layout.Row = 2;
            app.yOccupancyScale.Layout.Column = 1;
            app.yOccupancyScale.Value = 'log';

            % Create InitialBW_kHzLabel
            app.InitialBW_kHzLabel = uilabel(app.analysis_GraphicsGrid);
            app.InitialBW_kHzLabel.VerticalAlignment = 'bottom';
            app.InitialBW_kHzLabel.WordWrap = 'on';
            app.InitialBW_kHzLabel.FontSize = 11;
            app.InitialBW_kHzLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.InitialBW_kHzLabel.Layout.Row = 3;
            app.InitialBW_kHzLabel.Layout.Column = [1 2];
            app.InitialBW_kHzLabel.Text = 'Largura de emissão em kHz para emissão criada pelo método "DataTip" (PLAYBACK):';

            % Create InitialBW_kHz
            app.InitialBW_kHz = uispinner(app.analysis_GraphicsGrid);
            app.InitialBW_kHz.Step = 50;
            app.InitialBW_kHz.Limits = [0 1000];
            app.InitialBW_kHz.RoundFractionalValues = 'on';
            app.InitialBW_kHz.ValueDisplayFormat = '%.0f';
            app.InitialBW_kHz.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.InitialBW_kHz.FontSize = 11;
            app.InitialBW_kHz.FontColor = [0.149 0.149 0.149];
            app.InitialBW_kHz.Layout.Row = 4;
            app.InitialBW_kHz.Layout.Column = 1;

            % Create configAnalysisLabel3
            app.configAnalysisLabel3 = uilabel(app.SubGrid2);
            app.configAnalysisLabel3.VerticalAlignment = 'bottom';
            app.configAnalysisLabel3.FontSize = 10;
            app.configAnalysisLabel3.Layout.Row = 5;
            app.configAnalysisLabel3.Layout.Column = 1;
            app.configAnalysisLabel3.Text = 'ELEVAÇÃO';

            % Create analysis_ElevationPanel
            app.analysis_ElevationPanel = uipanel(app.SubGrid2);
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
            app.elevationAPIServer.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
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
            app.elevationNPoints.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.elevationNPoints.FontSize = 11;
            app.elevationNPoints.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationNPoints.BackgroundColor = [1 1 1];
            app.elevationNPoints.Layout.Row = 2;
            app.elevationNPoints.Layout.Column = 2;
            app.elevationNPoints.Value = '256';

            % Create elevationForceSearch
            app.elevationForceSearch = uicheckbox(app.analysis_ElevationGrid);
            app.elevationForceSearch.ValueChangedFcn = createCallbackFcn(app, @Config_AnalysisParameterValueChanged, true);
            app.elevationForceSearch.Text = 'Força consulta ao servidor (ignorando eventual informação em cache).';
            app.elevationForceSearch.WordWrap = 'on';
            app.elevationForceSearch.FontSize = 11;
            app.elevationForceSearch.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.elevationForceSearch.Layout.Row = 3;
            app.elevationForceSearch.Layout.Column = [1 3];

            % Create SubTab3
            app.SubTab3 = uitab(app.SubTabGroup);
            app.SubTab3.Title = 'PROJETO';

            % Create SubGrid3
            app.SubGrid3 = uigridlayout(app.SubTab3);
            app.SubGrid3.ColumnWidth = {'1x', 22};
            app.SubGrid3.RowHeight = {17, 70, 22, '1x'};
            app.SubGrid3.RowSpacing = 5;
            app.SubGrid3.BackgroundColor = [1 1 1];

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.SubGrid3);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontSize = 10;
            app.eFiscalizaLabel.Layout.Row = 1;
            app.eFiscalizaLabel.Layout.Column = 1;
            app.eFiscalizaLabel.Text = 'INICIALIZAÇÃO eFISCALIZA';

            % Create eFiscalizaRefresh
            app.eFiscalizaRefresh = uiimage(app.SubGrid3);
            app.eFiscalizaRefresh.ScaleMethod = 'none';
            app.eFiscalizaRefresh.ImageClickedFcn = createCallbackFcn(app, @Config_ProjectRefreshImageClicked, true);
            app.eFiscalizaRefresh.Visible = 'off';
            app.eFiscalizaRefresh.Tooltip = {'Retorna às configurações iniciais'};
            app.eFiscalizaRefresh.Layout.Row = 1;
            app.eFiscalizaRefresh.Layout.Column = 2;
            app.eFiscalizaRefresh.VerticalAlignment = 'bottom';
            app.eFiscalizaRefresh.ImageSource = 'Refresh_18.png';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.SubGrid3);
            app.eFiscalizaPanel.AutoResizeChildren = 'off';
            app.eFiscalizaPanel.Layout.Row = 2;
            app.eFiscalizaPanel.Layout.Column = [1 2];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {350, 110, 110};
            app.eFiscalizaGrid.RowHeight = {22, 22};
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [1 1 1];

            % Create reportSystemLabel
            app.reportSystemLabel = uilabel(app.eFiscalizaGrid);
            app.reportSystemLabel.WordWrap = 'on';
            app.reportSystemLabel.FontSize = 11;
            app.reportSystemLabel.Layout.Row = 1;
            app.reportSystemLabel.Layout.Column = 1;
            app.reportSystemLabel.Text = 'Ambiente do sistema de gestão à fiscalização:';

            % Create reportSystem
            app.reportSystem = uidropdown(app.eFiscalizaGrid);
            app.reportSystem.Items = {'eFiscaliza', 'eFiscaliza TS', 'eFiscaliza HM', 'eFiscaliza DS'};
            app.reportSystem.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportSystem.FontSize = 11;
            app.reportSystem.BackgroundColor = [1 1 1];
            app.reportSystem.Layout.Row = 1;
            app.reportSystem.Layout.Column = [2 3];
            app.reportSystem.Value = 'eFiscaliza';

            % Create reportUnitLabel
            app.reportUnitLabel = uilabel(app.eFiscalizaGrid);
            app.reportUnitLabel.WordWrap = 'on';
            app.reportUnitLabel.FontSize = 11;
            app.reportUnitLabel.Layout.Row = 2;
            app.reportUnitLabel.Layout.Column = 1;
            app.reportUnitLabel.Text = 'Unidade responsável pela fiscalização:';

            % Create reportUnit
            app.reportUnit = uidropdown(app.eFiscalizaGrid);
            app.reportUnit.Items = {};
            app.reportUnit.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportUnit.FontSize = 11;
            app.reportUnit.BackgroundColor = [1 1 1];
            app.reportUnit.Layout.Row = 2;
            app.reportUnit.Layout.Column = 2;
            app.reportUnit.Value = {};

            % Create reportLabel
            app.reportLabel = uilabel(app.SubGrid3);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontSize = 10;
            app.reportLabel.Layout.Row = 3;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'RELATÓRIO + BASEMAP + IMAGEM + DATABINNING';

            % Create reportPanel
            app.reportPanel = uipanel(app.SubGrid3);
            app.reportPanel.AutoResizeChildren = 'off';
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 4;
            app.reportPanel.Layout.Column = [1 2];

            % Create reportGrid_2
            app.reportGrid_2 = uigridlayout(app.reportPanel);
            app.reportGrid_2.ColumnWidth = {350, 110, 110};
            app.reportGrid_2.RowHeight = {22, 22, 22, 22, 48, 22, '1x'};
            app.reportGrid_2.RowSpacing = 5;
            app.reportGrid_2.BackgroundColor = [1 1 1];

            % Create reportDocTypeLabel
            app.reportDocTypeLabel = uilabel(app.reportGrid_2);
            app.reportDocTypeLabel.WordWrap = 'on';
            app.reportDocTypeLabel.FontSize = 11;
            app.reportDocTypeLabel.Layout.Row = 1;
            app.reportDocTypeLabel.Layout.Column = 1;
            app.reportDocTypeLabel.Text = 'Tipo de documento a gerar:';

            % Create reportDocType
            app.reportDocType = uidropdown(app.reportGrid_2);
            app.reportDocType.Items = {'Relatório de Atividades'};
            app.reportDocType.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportDocType.FontSize = 11;
            app.reportDocType.BackgroundColor = [1 1 1];
            app.reportDocType.Layout.Row = 1;
            app.reportDocType.Layout.Column = [2 3];
            app.reportDocType.Value = 'Relatório de Atividades';

            % Create reportBasemapLabel
            app.reportBasemapLabel = uilabel(app.reportGrid_2);
            app.reportBasemapLabel.FontSize = 11;
            app.reportBasemapLabel.Layout.Row = 2;
            app.reportBasemapLabel.Layout.Column = 1;
            app.reportBasemapLabel.Text = 'Basemap do eixo geográfico dos plots:';

            % Create reportBasemap
            app.reportBasemap = uidropdown(app.reportGrid_2);
            app.reportBasemap.Items = {'darkwater', 'none', 'satellite', 'streets-dark', 'streets-light', 'topographic'};
            app.reportBasemap.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportBasemap.FontSize = 11;
            app.reportBasemap.BackgroundColor = [1 1 1];
            app.reportBasemap.Layout.Row = 2;
            app.reportBasemap.Layout.Column = [2 3];
            app.reportBasemap.Value = 'darkwater';

            % Create reportImageLabel
            app.reportImageLabel = uilabel(app.reportGrid_2);
            app.reportImageLabel.FontSize = 11;
            app.reportImageLabel.Layout.Row = 3;
            app.reportImageLabel.Layout.Column = 1;
            app.reportImageLabel.Text = 'Formato e resolução (dpi) das imagens:';

            % Create reportImgFormat
            app.reportImgFormat = uidropdown(app.reportGrid_2);
            app.reportImgFormat.Items = {'jpeg', 'png'};
            app.reportImgFormat.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportImgFormat.FontSize = 11;
            app.reportImgFormat.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportImgFormat.BackgroundColor = [1 1 1];
            app.reportImgFormat.Layout.Row = 3;
            app.reportImgFormat.Layout.Column = 2;
            app.reportImgFormat.Value = 'jpeg';

            % Create reportImgDpi
            app.reportImgDpi = uidropdown(app.reportGrid_2);
            app.reportImgDpi.Items = {'100', '120', '150', '200'};
            app.reportImgDpi.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportImgDpi.FontSize = 11;
            app.reportImgDpi.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportImgDpi.BackgroundColor = [1 1 1];
            app.reportImgDpi.Layout.Row = 3;
            app.reportImgDpi.Layout.Column = 3;
            app.reportImgDpi.Value = '100';

            % Create reportBinningLabel
            app.reportBinningLabel = uilabel(app.reportGrid_2);
            app.reportBinningLabel.VerticalAlignment = 'top';
            app.reportBinningLabel.FontSize = 11;
            app.reportBinningLabel.Layout.Row = [4 5];
            app.reportBinningLabel.Layout.Column = 1;
            app.reportBinningLabel.Text = {'Sumarização de pontos com níveis superiores ao limiar:'; '(Data-Binning)'};

            % Create reportBinningPanel
            app.reportBinningPanel = uipanel(app.reportGrid_2);
            app.reportBinningPanel.AutoResizeChildren = 'off';
            app.reportBinningPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportBinningPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.reportBinningPanel.Layout.Row = [4 5];
            app.reportBinningPanel.Layout.Column = [2 3];

            % Create reportBinningGrid
            app.reportBinningGrid = uigridlayout(app.reportBinningPanel);
            app.reportBinningGrid.ColumnWidth = {100, 100};
            app.reportBinningGrid.RowHeight = {'1x', 22};
            app.reportBinningGrid.RowSpacing = 5;
            app.reportBinningGrid.Padding = [10 10 10 5];
            app.reportBinningGrid.BackgroundColor = [1 1 1];

            % Create reportBinningLengthLabel
            app.reportBinningLengthLabel = uilabel(app.reportBinningGrid);
            app.reportBinningLengthLabel.VerticalAlignment = 'bottom';
            app.reportBinningLengthLabel.WordWrap = 'on';
            app.reportBinningLengthLabel.FontSize = 11;
            app.reportBinningLengthLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportBinningLengthLabel.Layout.Row = 1;
            app.reportBinningLengthLabel.Layout.Column = 1;
            app.reportBinningLengthLabel.Text = 'Comprimento quadrícula (metros):';

            % Create reportBinningLength
            app.reportBinningLength = uispinner(app.reportBinningGrid);
            app.reportBinningLength.Step = 50;
            app.reportBinningLength.Limits = [50 1500];
            app.reportBinningLength.RoundFractionalValues = 'on';
            app.reportBinningLength.ValueDisplayFormat = '%.0f';
            app.reportBinningLength.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportBinningLength.FontSize = 11;
            app.reportBinningLength.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportBinningLength.Layout.Row = 2;
            app.reportBinningLength.Layout.Column = 1;
            app.reportBinningLength.Value = 100;

            % Create reportBinningFcnLabel
            app.reportBinningFcnLabel = uilabel(app.reportBinningGrid);
            app.reportBinningFcnLabel.VerticalAlignment = 'bottom';
            app.reportBinningFcnLabel.WordWrap = 'on';
            app.reportBinningFcnLabel.FontSize = 11;
            app.reportBinningFcnLabel.Layout.Row = 1;
            app.reportBinningFcnLabel.Layout.Column = 2;
            app.reportBinningFcnLabel.Text = {'Função'; 'estatística:'};

            % Create reportBinningFcn
            app.reportBinningFcn = uidropdown(app.reportBinningGrid);
            app.reportBinningFcn.Items = {'min', 'mean-linear', 'median-linear', 'rms-linear', 'max'};
            app.reportBinningFcn.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportBinningFcn.FontSize = 11;
            app.reportBinningFcn.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.reportBinningFcn.BackgroundColor = [1 1 1];
            app.reportBinningFcn.Layout.Row = 2;
            app.reportBinningFcn.Layout.Column = 2;
            app.reportBinningFcn.Value = 'min';

            % Create prjFileCompressionModeLabel
            app.prjFileCompressionModeLabel = uilabel(app.reportGrid_2);
            app.prjFileCompressionModeLabel.WordWrap = 'on';
            app.prjFileCompressionModeLabel.FontSize = 11;
            app.prjFileCompressionModeLabel.Layout.Row = 6;
            app.prjFileCompressionModeLabel.Layout.Column = 1;
            app.prjFileCompressionModeLabel.Text = 'Compressão aplicada ao arquivo de saída do projeto?';

            % Create prjFileCompressionMode
            app.prjFileCompressionMode = uidropdown(app.reportGrid_2);
            app.prjFileCompressionMode.Items = {'Não', 'Sim'};
            app.prjFileCompressionMode.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.prjFileCompressionMode.FontSize = 11;
            app.prjFileCompressionMode.BackgroundColor = [1 1 1];
            app.prjFileCompressionMode.Layout.Row = 6;
            app.prjFileCompressionMode.Layout.Column = 2;
            app.prjFileCompressionMode.Value = 'Não';

            % Create SubTab4
            app.SubTab4 = uitab(app.SubTabGroup);
            app.SubTab4.AutoResizeChildren = 'off';
            app.SubTab4.Title = 'MAPEAMENTO DE PASTAS';
            app.SubTab4.BackgroundColor = 'none';

            % Create SubGrid4
            app.SubGrid4 = uigridlayout(app.SubTab4);
            app.SubGrid4.ColumnWidth = {'1x', 20};
            app.SubGrid4.RowHeight = {17, 22, 22, 22, '1x'};
            app.SubGrid4.ColumnSpacing = 5;
            app.SubGrid4.RowSpacing = 5;
            app.SubGrid4.BackgroundColor = [1 1 1];

            % Create DATAHUBPOSTLabel
            app.DATAHUBPOSTLabel = uilabel(app.SubGrid4);
            app.DATAHUBPOSTLabel.VerticalAlignment = 'bottom';
            app.DATAHUBPOSTLabel.FontSize = 10;
            app.DATAHUBPOSTLabel.Layout.Row = 1;
            app.DATAHUBPOSTLabel.Layout.Column = 1;
            app.DATAHUBPOSTLabel.Text = 'DATAHUB - POST:';

            % Create DataHubPOST
            app.DataHubPOST = uieditfield(app.SubGrid4, 'text');
            app.DataHubPOST.Editable = 'off';
            app.DataHubPOST.FontSize = 11;
            app.DataHubPOST.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataHubPOST.Layout.Row = 2;
            app.DataHubPOST.Layout.Column = 1;

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.SubGrid4);
            app.DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Enable = 'off';
            app.DataHubPOSTButton.Layout.Row = 2;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'OpenFile_36x36.png';

            % Create userPathLabel
            app.userPathLabel = uilabel(app.SubGrid4);
            app.userPathLabel.VerticalAlignment = 'bottom';
            app.userPathLabel.FontSize = 10;
            app.userPathLabel.Layout.Row = 3;
            app.userPathLabel.Layout.Column = 1;
            app.userPathLabel.Text = 'PASTA DO USUÁRIO:';

            % Create userPath
            app.userPath = uieditfield(app.SubGrid4, 'text');
            app.userPath.Editable = 'off';
            app.userPath.FontSize = 11;
            app.userPath.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.userPath.Layout.Row = 4;
            app.userPath.Layout.Column = 1;

            % Create userPathButton
            app.userPathButton = uiimage(app.SubGrid4);
            app.userPathButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.userPathButton.Tag = 'userPath';
            app.userPathButton.Enable = 'off';
            app.userPathButton.Layout.Row = 4;
            app.userPathButton.Layout.Column = 2;
            app.userPathButton.ImageSource = 'OpenFile_36x36.png';

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
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
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
