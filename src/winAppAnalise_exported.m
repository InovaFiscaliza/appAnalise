classdef winAppAnalise_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        NavBar                         matlab.ui.container.GridLayout
        AppInfo                        matlab.ui.control.Image
        FigurePosition                 matlab.ui.control.Image
        DataHubLamp                    matlab.ui.control.Image
        jsBackDoor                     matlab.ui.control.HTML
        Tab7Button                     matlab.ui.control.StateButton
        Tab6Button                     matlab.ui.control.StateButton
        Tab5Button                     matlab.ui.control.StateButton
        Tab4Button                     matlab.ui.control.StateButton
        Tab3Button                     matlab.ui.control.StateButton
        Tab2Button                     matlab.ui.control.StateButton
        ButtonsSeparator1              matlab.ui.control.Image
        Tab1Button                     matlab.ui.control.StateButton
        AppName                        matlab.ui.control.Label
        AppIcon                        matlab.ui.control.Image
        TabGroup                       matlab.ui.container.TabGroup
        Tab1                           matlab.ui.container.Tab
        Tab1Grid                       matlab.ui.container.GridLayout
        SubTabGroup                    matlab.ui.container.TabGroup
        SubTab1                        matlab.ui.container.Tab
        SubGrid1                       matlab.ui.container.GridLayout
        FileModuleInfo                 matlab.ui.control.Label
        SubTab2                        matlab.ui.container.Tab
        SubGrid2                       matlab.ui.container.GridLayout
        FileFilterTree                 matlab.ui.container.Tree
        FileFilterAdd                  matlab.ui.control.Image
        FileFilterValue_Frequency      matlab.ui.control.DropDown
        FileFilterValue_ID             matlab.ui.control.DropDown
        FileFilterValue_Description    matlab.ui.control.EditField
        FileFilterType                 matlab.ui.control.DropDown
        Toolbar                        matlab.ui.container.GridLayout
        tool_ReadSpectrumData          matlab.ui.control.Image
        tool_Separator                 matlab.ui.control.Image
        tool_ReadFiles                 matlab.ui.control.Image
        FileMetadata                   matlab.ui.control.Label
        FileTree                       matlab.ui.container.Tree
        Tab2_Playback                  matlab.ui.container.Tab
        Tab3_DriveTest                 matlab.ui.container.Tab
        Tab4_SignalAnalysis            matlab.ui.container.Tab
        Tab5_Misc                      matlab.ui.container.Tab
        Tab5_RFDataHub                 matlab.ui.container.Tab
        Tab6_Config                    matlab.ui.container.Tab
        file_ContextMenu_Tree1         matlab.ui.container.ContextMenu
        file_ContextMenu_delTree1Node  matlab.ui.container.Menu
        file_ContextMenu_Tree2         matlab.ui.container.ContextMenu
        file_ContextMenu_delTree2Node  matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainApp'
        Context = 'FILE'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        General
        General_I

        rootFolder
        tabGroupController
        renderCount = 0

        executionMode
        progressDialog
        popupContainer

        eFiscalizaObj

        projectData
        metaData = model.MetaData.empty
        specData = model.SpecData.empty
        
        bandObj
        channelObj

        elevationObj = RF.Elevation
        ChannelReportObj

        rfDataHub
        rfDataHubLOG
        rfDataHubSummary
        rfDataHubAnnotation = table( ...
            string.empty, ...
            int32([]), ...
            struct('Latitude', {}, 'Longitude', {}, 'AntennaHeight', {}), ...
            'VariableNames', {'ID', 'Station', 'TXSite'} ...
        )
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        % COMUNICAÇÃO ENTRE PROCESSOS:
        % • ipcMainJSEventsHandler
        %   Eventos recebidos do objeto app.jsBackDoor por meio de chamada 
        %   ao método "sendEventToMATLAB" do objeto "htmlComponent" (no JS).
        %
        % • ipcMainMatlabCallsHandler
        %   Eventos recebidos dos apps secundários.
        %
        % • ipcMainMatlabCallAuxiliarApp
        %   Reencaminha eventos recebidos aos apps secundários, viabilizando
        %   comunicação entre apps secundários e, também, redirecionando os 
        %   eventos JS quando o app secundário é executado em modo DOCK (e, 
        %   por essa razão, usa o "jsBackDoor" do app principal).
        %
        % • ipcMainMatlabOpenPopupApp
        %   Abre um app secundário como popup, no mainApp.
        %-----------------------------------------------------------------%
        function ipcMainJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    % MATLAB-JS BRIDGE (matlabJSBridge.js)
                    case 'renderer'
                        MFilePath   = fileparts(mfilename('fullpath'));
                        parpoolFlag = false;

                        if ~app.renderCount
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        else
                            selectedNodes = app.FileTree.SelectedNodes;
                            if ~isempty(app.FileTree.SelectedNodes)
                                app.FileTree.SelectedNodes = [];
                                onTreeSelectionChanged(app)
                            end

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            if ~isempty(selectedNodes)
                                app.FileTree.SelectedNodes = selectedNodes;
                                onTreeSelectionChanged(app)
                            end
                        end
                        
                        app.renderCount = app.renderCount+1;

                    case 'unload'
                        closeFcn(app)
                    
                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case {'onFetchIssueDetails', 'onReportGenerate', 'onUploadArtifacts'}
                                eventName = event.HTMLEventData.uuid;
                                context = event.HTMLEventData.context;

                                varargin = {};
                                if isfield(event.HTMLEventData, 'varargin')
                                    varargin = event.HTMLEventData.varargin;
                                    if ~iscell(varargin)
                                        varargin = {varargin};
                                    end
                                end

                                reportHandleOperation(app, eventName, context, event.HTMLEventData, varargin{:})

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    % auxApp.winPlayback
                    case 'mainApp.file_Tree'
                        ContextMenu_delTree1NodeSelected(app)

                    case 'mainApp.file_FilteringTree'
                        ContextMenu_delTree2NodeSelected(app)

                    case 'auxApp.winPlayback.ChannelTree'
                        play_Channel_ContextMenu_delChannelSelected(app)

                    case 'auxApp.winPlayback.BandLimitsTree'
                        play_BandLimits_ContextMenu_delSelected(app)

                    case 'auxApp.winPlayback.FindPeaksTree'
                        play_FindPeaks_delEmission(app)

                    case 'auxApp.winPlayback.ReportTree'
                        report_ContextMenu_delSelected(app)

                    % auxApp.winDriveTest
                    % auxApp.winRFDataHub
                    case {'auxApp.winDriveTest.filter_Tree', 'auxApp.winDriveTest.points_Tree', 'auxApp.winRFDataHub.filter_Tree'}
                        if contains(event.HTMLEventName, 'winDriveTest')
                            auxAppName = 'DRIVETEST';
                        elseif contains(event.HTMLEventName, 'winRFDataHub')
                            auxAppName = 'RFDATAHUB';
                        end

                        hAuxApp = getAppHandle(app.tabGroupController, auxAppName);
                        ipcSecundaryJSEventsHandler(hAuxApp, event)

                    % DOCKADDKFACTOR / DOCKTIMEFILTERING
                    case {'auxApp.dockAddKFactor.kFactorTree', 'auxApp.dockTimeFiltering.filterTree'}
                        hDockApp  = app.popupContainer.RunningAppInstance;
                        ipcSecundaryJSEventsHandler(hDockApp, event)

                    otherwise
                        error('UnexpectedEvent')
                end
                drawnow

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, eventName, varargin)
            varargout = {};

            try
                switch eventName
                    case 'closeFcn'
                        auxAppTag    = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        auxAppTag    = varargin{1};
                        varargout{1} = {app};

                    otherwise
                        switch class(callingApp)
                            % CONFIG
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch eventName
                                    case 'checkDataHubLampStatus'
                                        updateWarningLampVisibility(app)

                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))

                                    case 'onSimulationMode'
                                        if app.General.operationMode.Simulation
                                            Toolbar_SelectFileToReadButtonClicked(app)
        
                                            % Muda programaticamente o modo p/ ARQUIVOS.
                                            set(app.Tab1Button, 'Enable', 1, 'Value', 1)                    
                                            onTabNavigatorButtonPushed(app, struct('Source', app.Tab1Button, 'PreviousValue', false))
                                        end

                                    case 'onYAxesScaleChange'
                                        if ~isempty(app.UIAxes2) && isvalid(app.UIAxes2)
                                            set(app.UIAxes2, 'YScale', app.General.Plot.Axes.yOccupancyScale)
                                        end

                                    case 'onRFDataHubUpdate'
                                        initializeRFDataHub(app)
                                        ipcMainMatlabCallAuxiliarApp(app, 'RFDATAHUB', 'MATLAB', eventName)

                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            % DRIVETEST
                            case {'auxApp.winDriveTest', 'auxApp.winDriveTest_exported'}
                                switch eventName
                                    case {'ChannelParameterChanged', 'ChannelDefault'}
                                        play_UpdateAuxiliarApps(app, 'SIGNALANALYSIS')

                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            % SIGNALANALYSIS
                            case {'auxApp.winSignalAnalysis', 'auxApp.winSignalAnalysis_exported'}
                                switch eventName
                                    case 'DeleteButtonPushed'
                                        % ...

                                    case 'IsTruncatedValueChanged'
                                        % ...

                                    case 'PeakDescriptionChanged'
                                        % ...

                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            % DOCKS:OTHERS
                            case {'auxApp.dockAddChannel',     'auxApp.dockAddChannel_exported',     ... % PLAYBACK:CHANNEL
                                  'auxApp.dockDetection',      'auxApp.dockDetection_exported',      ... % REPORT:DETECTION
                                  'auxApp.dockClassification', 'auxApp.dockClassification_exported', ... % REPORT:CLASSIFICATION
                                  'auxApp.dockAddFiles',       'auxApp.dockAddFiles_exported',       ... % REPORT:EXTERNALFILES
                                  'auxApp.dockTimeFiltering',  'auxApp.dockTimeFiltering_exported',  ... % MISCELLANEOUS:TIMEFILTERING
                                  'auxApp.dockEditLocation',   'auxApp.dockEditLocation_exported',   ... % MISCELLANEOUS:EDITLOCATION
                                  'auxApp.dockAddKFactor',     'auxApp.dockAddKFactor_exported',     ... % MISCELLANEOUS:ADDKFACTOR
                                  'auxApp.dockLevelFiltering', 'auxApp.dockLevelFiltering_exported'}     % MISCELLANEOUS:LEVELFILTERING
        
                                switch eventName
                                    case 'closeFcnCallFromPopupApp'
                                        context   = varargin{1};
                                        moduleTag = varargin{2};
        
                                        switch context
                                            case 'mainApp'
                                                hApp = app;
                                            otherwise
                                                hApp = getAppHandle(app.tabGroupController, context);
                                        end
        
                                        if ~isempty(hApp)
                                            deleteContextMenu(app.tabGroupController, hApp.UIFigure, moduleTag)
                                        end
        
                                    otherwise
                                        updateFlag = varargin{1};
                                        returnFlag = varargin{2};
                
                                        if updateFlag
                                            switch eventName
                                                case 'PLAYBACK:CHANNEL'
                                                    channel2Add   = varargin{3};
                                                    typeOfChannel = varargin{4};
                                                    idxThreads    = varargin{5};
                                                    play_Channel_AddChannel(app, channel2Add, typeOfChannel, idxThreads)
                
                                                case {'REPORT:DETECTION', 'REPORT:CLASSIFICATION'}
                                                    idxThread     = varargin{3};
                
                                                    % Esse estado força a atualização do painel
                                                    app.report_ThreadAlgorithms.UserData.idxThread = [];
                                                    report_Algorithms(app, idxThread)
                                                    report_SaveWarn(app)
                
                                                case 'REPORT:EXTERNALFILES'
                                                    report_TreeBuilding(app)
                
                                                case 'MISCELLANEOUS'
                                                    SelectedNodesTextList = misc_SelectedNodesText(app);
                                                    play_TreeRebuilding(app, SelectedNodesTextList)
                                                
                                                case 'MISCELLANEOUS:LEVELFILTERING'
                                                    editedData = varargin{3};
                                                    copyMode   = varargin{4};
                
                                                    if strcmp(copyMode, 'copy')              
                                                        app.specData(end+1:end+numel(editedData)) = editedData;
                                                    end
                                                    
                                                    SelectedNodesTextList = misc_SelectedNodesText(app);
                                                    play_TreeRebuilding(app, SelectedNodesTextList)
                                            end
                                        end
                
                                        if returnFlag
                                            return
                                        end
                                end
                                
                                if ~isempty(app.popupContainer) || isvalid(app.popupContainer)
                                    app.popupContainer.Parent.Visible = 0;
                                end
            
                            otherwise
                                error('UnexpectedCall')
                        end
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));            
            end

            % Caso um app auxiliar esteja em modo DOCK, o progressDialog do
            % app auxiliar coincide com o do appAnalise. Força-se, portanto, 
            % a condição abaixo para evitar possível bloqueio da tela.
            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = getAppHandle(app.tabGroupController, auxAppName);

            if ~isempty(hAuxApp)
                switch communicationType
                    case 'MATLAB'
                        operationType = varargin{1};
                        ipcSecondaryMatlabCallsHandler(hAuxApp, app, operationType, varargin{2:end});
                    case 'JS'
                        event = varargin{1};
                        ipcSecondaryJSEventsHandler(hAuxApp, event)
                end
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabOpenPopupApp(app, auxiliarApp, varargin)
            arguments
                app
                auxiliarApp char {mustBeMember(auxiliarApp, {'ReportLib', 'Detection', 'Classification', 'AddFiles', 'TimeFiltering', 'EditLocation', 'AddKFactor', 'AddChannel', 'LevelFiltering'})}
            end

            arguments (Repeating)
                varargin 
            end

            switch auxiliarApp
                case 'ReportLib'
                    screenWidth  = 460;
                    screenHeight = 602;
                case 'Detection'
                    screenWidth = 412;
                    screenHeight = 282;
                case 'Classification'
                    screenWidth = 534;
                    screenHeight = 248;
                case 'AddFiles'
                    screenWidth = 880; 
                    screenHeight = 480;
                case 'TimeFiltering'
                    screenWidth = 640; 
                    screenHeight = 480;
                case 'LevelFiltering'
                    screenWidth = 540; 
                    screenHeight = 300;
                case 'EditLocation'
                    screenWidth = 394; 
                    screenHeight = 194;
                case 'AddKFactor'
                    screenWidth = 480; 
                    screenHeight = 360;
                case 'AddChannel'
                    screenWidth = 560; 
                    screenHeight = 480;
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')
            ui.PopUpContainer(callingApp, class.Constants.appName, screenWidth, screenHeight)

            % Executa o app auxiliar.
            inputArguments = [{app, callingApp}, varargin];
            auxDockAppName = sprintf('auxApp.dock%s', auxAppName);
            
            if app.General.operationMode.Debug
                eval(sprintf('auxApp.dock%s(inputArguments{:})', auxAppName))
            else
                eval([auxDockAppName '_exported(callingApp.popupContainer, inputArguments{:})'])
                
                callingApp.popupContainer.UserData.auxDockAppName = auxDockAppName;
                callingApp.popupContainer.Parent.Visible = 1;
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end
    end
    
    
    methods (Access = public)
        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            onTabNavigatorButtonPushed(app, struct('Source', clickedButton, 'PreviousValue', false))
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
                        app.Tab1Button;
                        app.Tab2Button;
                        app.Tab3Button;
                        app.Tab4Button;
                        app.Tab5Button;
                        app.Tab6Button;
                        app.Tab7Button;
                        app.FileModuleInfo;
                        app.FileTree;
                        app.FileMetadata;
                        app.tool_ReadFiles;
                        app.tool_ReadSpectrumData
                    };                            
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.FileMetadata, appName);
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.FileModuleInfo.UserData.id, 'selector', '[class="mwTextNode"]', 'style', struct('textAlign', 'justify')), ...
                            struct('appName', appName, 'dataTag', app.tool_ReadFiles.UserData.id,  'tooltip', struct('defaultPosition', 'top', 'textContent', 'Seleciona arquivos')), ...
                            struct('appName', appName, 'dataTag', app.tool_ReadSpectrumData.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Inicia análise, lendo dados de varreduras')), ...                            
                            struct('appName', appName, 'dataTag', app.Tab1Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab2Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab3Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab4Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab5Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab6Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab7Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.FileTree.UserData.id, 'listener', struct('componentName', 'mainApp.file_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end

                    % Salva na propriedade "UserData" as opções de ícone e o índice 
                    % da aba, simplificando os ajustes decorrentes de uma alteração...
                    app.FileTree.UserData.previousSelectedFileIndex  = [];
                    app.FileTree.UserData.previousSelectedFileThread = [];

                    app.FileFilterValue_ID.UserData.render        = false;
                    app.FileFilterValue_Frequency.UserData.render = false;
                    app.FileFilterTree.UserData.render            = false;

                case 2
                    elToModify = {
                        app.FileFilterAdd;
                        app.FileFilterTree
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);
                    
                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.FileFilterAdd.UserData.id,  'tooltip', struct('defaultPosition', 'top', 'textContent', 'Aplica filtro ao conjunto de dados')), ...
                            struct('appName', appName, 'dataTag', app.FileFilterTree.UserData.id, 'listener', struct('componentName', 'mainApp.file_FilteringTree',   'keyEvents', {{'Delete', 'Backspace'}}))  ...
                        });
                    catch
                    end

                    app.FileFilterValue_ID.UserData.render        = true;
                    app.FileFilterValue_Frequency.UserData.render = true;
                    app.FileFilterTree.UserData.render            = true;

                    file_FilterOptions(app)
                    file_FilterCheck(app)
            end
        end

        %-----------------------------------------------------------------%
        function loadConfigurationFile(app, appName, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appEngine.util.generalSettingsLoad(appName, app.rootFolder);
            if ~isempty(msgWarning)
                ui.Dialog(app.UIFigure, 'error', msgWarning);
            end

            % Para criação de arquivos temporários, cria-se uma pasta da 
            % sessão.
            tempDir = tempname;
            mkdir(tempDir)
            app.General_I.fileFolder.tempPath  = tempDir;
            app.General_I.fileFolder.MFilePath = MFilePath;
            
            if ~strcmp(app.General_I.Plot.Waterfall.Decimation, 'auto')
                app.General_I.Plot.Waterfall.Decimation = 'auto';
            end
        
            if isempty(app.General_I.Merge.Distance)
                app.General_I.Merge.Distance = Inf;
            end
        
            if isempty(app.General_I.Integration.Trace)
                app.General_I.Integration.Trace = Inf;
            end

            switch app.executionMode
                case 'webApp'
                    % Força a exclusão do SplashScreen do MATLAB Web Server.
                    sendEventToHTMLSource(app.jsBackDoor, "delProgressDialog");
                    
                    app.General_I.operationMode.Debug = false;
                    app.General_I.operationMode.Dock  = true;
                    
                    % A pasta do usuário não é configurável, mas obtida por 
                    % meio de chamada a uiputfile. 
                    app.General_I.fileFolder.userPath = tempDir;

                    % A renderização do plot no MATLAB WebServer, enviando-o à uma 
                    % sessão do webapp como imagem Base64, é crítica por depender 
                    % das comunicações WebServer-webapp e WebServer-BaseMapServer. 
                    % Ao configurar o Basemap como "none", entretanto, elimina-se a 
                    % necessidade de comunicação com BaseMapServer, além de tornar 
                    % mais eficiente a comunicação com webapp porque as imagens
                    % Base64 são menores (uma imagem com Basemap "sattelite" pode 
                    % ter 500 kB, enquanto uma imagem sem Basemap pode ter 25 kB).
                    app.General_I.Plot.GeographicAxes.Basemap = 'none';
                    app.General_I.Report.Basemap              = 'none';

                otherwise    
                    % Resgata a pasta de trabalho do usuário (configurável).
                    userPaths = appEngine.util.UserPaths(app.General_I.fileFolder.userPath);
                    app.General_I.fileFolder.userPath = userPaths{end};

                    switch app.executionMode
                        case 'desktopStandaloneApp'
                            app.General_I.operationMode.Debug = false;
                        case 'MATLABEnvironment'
                            app.General_I.operationMode.Debug = true;
                    end
            end

            % "RFDataHub.mat"
            global RFDataHub
            global RFDataHub_info
        
            if isempty(RFDataHub) || isempty(RFDataHub_info)
                model.RFDataHub.read(appName, app.rootFolder, tempDir)
            end

            app.General            = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRFDataHub(app)

            app.projectData = model.projectLib(app, app.rootFolder);
            app.bandObj     = class.Band('appAnalise:PLAYBACK', app);
            app.channelObj  = class.ChannelLib(class.Constants.appName, app.rootFolder);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog);
            addComponent(app.tabGroupController, "Built-in", "",                         app.Tab1Button, "AlwaysOn", struct('On', '', 'Off', ''), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winPlayback",       app.Tab2Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winDriveTest",      app.Tab3Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      3)
            addComponent(app.tabGroupController, "External", "auxApp.winSignalAnalysis", app.Tab4Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      4)
            addComponent(app.tabGroupController, "External", "auxApp.winMisc",           app.Tab5Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      5)
            addComponent(app.tabGroupController, "External", "auxApp.winRFDataHub",      app.Tab6Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      6)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",         app.Tab7Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      7)
            app.tabGroupController.inlineSVG = true;

            addStyle(app.FileTree, uistyle('Interpreter', 'html'))
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateWarningLampVisibility(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeRFDataHub(app)
            global RFDataHub
            global RFDataHubLog

            app.rfDataHub        = RFDataHub;
            app.rfDataHubLOG     = RFDataHubLog;
            app.rfDataHubSummary = summary(RFDataHub(:, {'Source', 'State'}));

            % A coluna "Source" possui agrupamentos da fonte dos dados,
            % decorrente da mesclagem de estações.
            tempSourceList = cellfun(@(x) strsplit(x, ' | '), app.rfDataHubSummary.Source.Categories, 'UniformOutput', false);
            app.rfDataHubSummary.Source.RawCategories = unique(horzcat(tempSourceList{:}))';
        end

        %-----------------------------------------------------------------%
        function userSelection = auxAppStatus(app, operationType)
            arguments
                app
                operationType char {mustBeMember(operationType, {'RELER INFORMAÇÃO ESPECTRAL', ...
                                                                 'MESCLAR FLUXOS',             ...
                                                                 'EXCLUIR FLUXO(S)',           ...
                                                                 'IMPORTAR ANÁLISE',           ...
                                                                 'APLICAR FILTRO TEMPORAL',    ...
                                                                 'APLICAR FILTRO NÍVEL',       ...
                                                                 'EDITAR LOCAL',               ...
                                                                 'APLICAR CORREÇÃO'})}
            end

            userSelection = 'Sim';

            if checkStatusModule(app.tabGroupController, 'DRIVETEST') || checkStatusModule(app.tabGroupController, 'SIGNALANALYSIS')
                msgQuestion   = sprintf(['A operação "%s" demanda que os módulos auxiliares "DRIVETEST" e "SIGNALANALYSIS" sejam fechados, '        ...
                                         'caso abertos, pois as informações espectrais consumidas por esses módulos poderão ficar desatualizadas. ' ...
                                         'Deseja continuar?'], operationType);
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

                if userSelection == "Sim"
                    closeModule(app.tabGroupController, 'DRIVETEST',      app.General)
                    closeModule(app.tabGroupController, 'SIGNALANALYSIS', app.General)
                end
            end
        end     

        %-----------------------------------------------------------------%
        % ## Modo "ARQUIVO(S)" ##
        %-----------------------------------------------------------------%
        function file_OpenSelectedFiles(app, filePath, fileName)
            d = ui.Dialog(app.UIFigure, 'progressdlg', 'Em andamento a leitura de metadados do(s) arquivo(s) selecionado(s).');            
            
            repeteadFiles = {};
            emptyFiles    = {};

            for ii = 1:numel(fileName)
                d.Message = sprintf('Em andamento a leitura de metadados do arquivo:\n•&thinsp;%s\n\n%d de %d', fileName{ii}, ii, numel(fileName));

                fileFullPath = fullfile(filePath, fileName{ii});
                [~,~,fileExt]= fileparts(fileName{ii});
                relatedFiles = RelatedFiles(app.metaData);
                
                switch lower(fileExt)
                    case {'.bin', '.dbm', '.sm1809', '.csv'}
                        if ~any(contains(relatedFiles, fileName(ii), 'IgnoreCase', true))
                            idx = numel(app.metaData)+1;
                            
                            app.metaData(idx).File = fileFullPath;
                            app.metaData(idx).Type = 'Spectral data';
                        else
                            repeteadFiles{end+1} = fileName{ii};
                            continue
                        end
                        
                    case '.mat'
                        lastwarn('')
                        load(fileFullPath, '-mat', 'prj_Type', 'prj_RelatedFiles')
                        [~, warnID] = lastwarn;
                        
                        % Um projeto .MAT pode conter informações geradas por mais
                        % de um arquivo .BIN, por exemplo. Por essa razão, certifica-se
                        % que nenhum dos arquivos relacionados ao projeto já foram 
                        % lidos anteriormente.
                        if strcmp(warnID, 'MATLAB:load:variableNotFound')
                            msgWarning = sprintf('O arquivo indicado a seguir não foi gerado pelo appAnalise ou appColeta.\n•&thinsp;%s', fileName{ii});
                            ui.Dialog(app.UIFigure, 'warning', msgWarning);
                            continue
                            
                        elseif any(strcmpi(fileFullPath, {app.metaData.File}))
                            msgWarning = sprintf('O arquivo indicado a seguir já tinha sido lido.\n•&thinsp;%s', fileName{ii});
                            ui.Dialog(app.UIFigure, 'warning', msgWarning);                            
                            continue
                            
                        elseif any(contains(relatedFiles, prj_RelatedFiles, 'IgnoreCase', true))
                            msgWarning = sprintf(['O arquivo indicado a seguir não será lido por já ter sido lido ao menos um arquivo relacionado ao ' ...
                                           'projeto appAnalise.\n•&thinsp;%s\n\nArquivo(s) relacionado(s) ao projeto appAnalise já lido(s):\n%s'],   ...
                                           fileName{ii}, strjoin(cellfun(@(x) sprintf('•&thinsp;%s', x), relatedFiles(contains(relatedFiles, prj_RelatedFiles, 'IgnoreCase', true)), 'UniformOutput', false), '\n'));
                            ui.Dialog(app.UIFigure, 'warning', msgWarning);                            
                            continue

                        elseif ~isempty(app.metaData) && strcmp(prj_Type, 'Project data') && ismember('Project data', {app.metaData.Type})
                            msgWarning = sprintf('O arquivo indicado a seguir não será lido porque já foram lidos os metadados de outro projeto appAnalise.\n•&thinsp;%s', fileName{ii});
                            ui.Dialog(app.UIFigure, 'warning', msgWarning);                            
                            continue
                            
                        else
                            idx = numel(app.metaData)+1;
                            
                            app.metaData(idx).File = fileFullPath;
                            app.metaData(idx).Type = prj_Type;
                        end
                end
                
                try
                    app.metaData(idx).Data    = read(app.metaData(idx).Data, fileFullPath, 'MetaData');
                    app.metaData(idx).Samples = sweepsPerThread(app.metaData(idx).Data);
                    if isempty(app.metaData(idx).Samples)
                        emptyFiles{end+1} = fileName{ii};
                        error('Empty file')
                    end
                    app.metaData(idx).Memory  = estimateMemory(app.metaData(idx).Data);

                catch ME
                    delete(app.metaData(idx))
                    app.metaData(idx) = [];
                    fclose('all');

                    if ~isvalid(app.metaData)
                        app.metaData = model.MetaData.empty;
                    end
                end
            end
            
            if ~isempty(repeteadFiles)
                msgWarning = sprintf('Os metadados dos arquivos indicados a seguir já tinham sido lidos.\n%s', strjoin(strcat('•&thinsp;', repeteadFiles), '\n'));
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
            end

            if ~isempty(emptyFiles)
                msgWarning = sprintf('Os arquivos indicados a seguir não possuem informação espectral.\n%s',   strjoin(strcat('•&thinsp;', emptyFiles),    '\n'));
                ui.Dialog(app.UIFigure, 'error', msgWarning);
            end

            buildFileTree(app)
        end

        %-----------------------------------------------------------------%
        function buildFileTree(app)
            if ~isempty(app.FileTree.Children)
                delete(app.FileTree.Children)
                
                oldStyleIndex = find(app.FileTree.StyleConfigurations.Target == "node");
                if ~isempty(oldStyleIndex)
                    removeStyle(app.FileTree, oldStyleIndex)
                end

                app.FileTree.UserData = struct('previousSelectedFileIndex', [], 'previousSelectedFileThread', []);
            end

            if ~isempty(app.metaData)
                file_FilterOptions(app)
                file_FilterCheck(app)

                filteredNodes = [];

                for ii = 1:numel(app.metaData)
                    [~, fileName, fileExt] = fileparts(app.metaData(ii).File);
                    
                    fileNode = uitreenode(app.FileTree, 'Text',        [fileName fileExt],                                                     ...
                                                         'NodeData',    struct('level', 1, 'idx1', ii, 'idx2', 1:numel(app.metaData(ii).Data)), ...
                                                         'ContextMenu', app.file_ContextMenu_Tree1);

                    receiverRawList = {app.metaData(ii).Data.Receiver};
                    [receiverList, ~, receiverIndex] = unique(receiverRawList);

                    if isscalar(receiverList) && isscalar(app.metaData(ii).Data)
                        fileNode.NodeData.idx2 = 1;
                    end
                    
                    for jj = 1:numel(receiverList)
                        idx = find(receiverIndex == jj)';

                        receiverNode = uitreenode(fileNode, 'Text',        util.layoutTreeNodeText(receiverList{jj}, 'file_TreeBuilding'), ...
                                                            'NodeData',    struct('level', 2, 'idx1', ii, 'idx2', idx),                    ...
                                                            'Icon',        util.layoutTreeNodeIcon(receiverList{jj}),                      ...
                                                            'ContextMenu', app.file_ContextMenu_Tree1);                        
                        for kk = idx
                            nodeTextNote = '';
                            if ismember(app.metaData(ii).Data(kk).MetaData.DataType, class.Constants.occDataTypes)
                                nodeTextNote = ' (Ocupação)';
                            end

                            dataNode = uitreenode(receiverNode, 'Text',        sprintf('ID %d: %.3f - %.3f MHz%s', app.metaData(ii).Data(kk).RelatedFiles.ID(1),                       ...
                                                                                                                   app.metaData(ii).Data(kk).MetaData.FreqStart .* 1e-6,               ...
                                                                                                                   app.metaData(ii).Data(kk).MetaData.FreqStop .* 1e-6, nodeTextNote), ...
                                                                'NodeData',    struct('level', 3, 'idx1', ii, 'idx2', kk),                                                             ...
                                                                'ContextMenu', app.file_ContextMenu_Tree1);
                            if ~app.metaData(ii).Data(kk).Enable
                                filteredNodes = [filteredNodes, dataNode];
                            end
                        end
                    end
                end

                if ~isempty(filteredNodes)
                    addStyle(app.FileTree, uistyle('FontColor', [.65,.65,.65]), 'node', filteredNodes)
                end

                app.FileTree.SelectedNodes = app.FileTree.Children(1);
                onTreeSelectionChanged(app)

            else
                ui.TextView.update(app.FileMetadata, '');
                app.FileFilterValue_Frequency.Items   = {};
                app.FileFilterValue_ID.Items          = {};
                app.FileFilterValue_Description.Value = '';           
            end

            file_specReadButtonVisibility(app)
        end

        %-----------------------------------------------------------------%
        function file_FilterOptions(app)
            % Se app.FileFilterValue_ID e file_FilteringValue_Frequency 
            % ainda não foram renderizados, então não faz sentido passar por 
            % aqui...
            if ~app.FileFilterValue_ID.UserData.render && ~app.FileFilterValue_Frequency.UserData.render
                return
            end

            bandList = table('Size', [0,3], ...
                             'VariableTypes', {'double', 'double', 'string'}, ...
                             'VariableNames', {'FreqStart', 'FreqStop', 'Band'});
            IDList   = [];
            for ii = 1:numel(app.metaData)
                for jj = 1:numel(app.metaData(ii).Data)

                    FreqStart = app.metaData(ii).Data(jj).MetaData.FreqStart;
                    FreqStop  = app.metaData(ii).Data(jj).MetaData.FreqStop;

                    bandList(end+1,:) = {FreqStart, FreqStop, sprintf('%.3f - %.3f MHz', FreqStart/1e+6, FreqStop/1e+6)};
                    IDList(end+1,1)   = app.metaData(ii).Data(jj).RelatedFiles.ID(1);
                end
            end
            bandList = sortrows(bandList, {'FreqStart', 'FreqStop'});

            app.FileFilterValue_ID.Items = unique(string(sort(IDList)), "rows", "stable");
            app.FileFilterValue_Frequency.Items = unique(bandList.Band, "rows", "stable");
        end

        %-----------------------------------------------------------------%
        function file_FilterCheck(app)
            % Se app.FileFilterTree ainda não foi renderizado, então
            % não faz sentido passar por aqui...
            if ~app.FileFilterTree.UserData.render
                return
            end

            hFilter = allchild(app.FileFilterTree);
            if isempty(hFilter)
                for ii = 1:numel(app.metaData)
                    for jj = 1:numel(app.metaData(ii).Data)
                        app.metaData(ii).Data(jj).Enable = true;
                    end
                end

            else
                filterTextList = strjoin({hFilter.Text}, '\n');                
                filterParser   = struct2table(regexp(filterTextList, '(?<Type>(FREQUÊNCIA|ID|DESCRIÇÃO))[:] (?<Sentence>.*)', 'names', 'dotexceptnewline'));
                if ~iscell(filterParser.Sentence)
                    filterParser.Sentence = {filterParser.Sentence};
                end

                filterSentence_Frequency   = filterParser.Sentence(filterParser.Type == "FREQUÊNCIA");
                filterSentence_ID          = str2double(filterParser.Sentence(filterParser.Type == "ID"));
                filterSentence_Description = filterParser.Sentence(filterParser.Type == "DESCRIÇÃO");

                for ii = 1:numel(app.metaData)
                    for jj = 1:numel(app.metaData(ii).Data)
                        app.metaData(ii).Data(jj).Enable = false;

                        % FREQUÊNCIA
                        if ~isempty(filterSentence_Frequency)
                            dataSentence = sprintf('%.3f - %.3f MHz', app.metaData(ii).Data(jj).MetaData.FreqStart .* 1e-6, ...
                                                                      app.metaData(ii).Data(jj).MetaData.FreqStop  .* 1e-6);
                            if ismember(dataSentence, filterSentence_Frequency)
                                app.metaData(ii).Data(jj).Enable = true;
                                continue
                            end
                        end

                        % ID
                        if ~isempty(filterSentence_ID)
                            dataSentence = app.metaData(ii).Data(jj).RelatedFiles.ID(1);

                            if ismember(dataSentence, filterSentence_ID)
                                app.metaData(ii).Data(jj).Enable = true;
                                continue
                            end
                        end

                        % DESCRIÇÃO
                        if ~isempty(filterSentence_Description)
                            dataSentence = app.metaData(ii).Data(jj).RelatedFiles.Description{1};

                            if any(cellfun(@(x) contains(dataSentence, x, "IgnoreCase", true), replace(filterSentence_Description, '"', '')))
                                app.metaData(ii).Data(jj).Enable = true;
                                continue
                            end
                        end
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function file_DataReaderError(app)
            if ~isempty(app.specData)
                delete(app.specData)
                app.specData = model.SpecData.empty;
            end

            set(findobj(app.NavBar, 'Type', 'uistatebutton'), 'Enable', 0)
            set(app.Tab1Button, 'Enable', 1, 'Value', 1)
            app.Tab6Button.Enable = 1;
            app.Tab7Button.Enable = 1;

            onTabNavigatorButtonPushed(app, struct('Source', app.Tab1Button, 'PreviousValue', false)) 
        end

        %-----------------------------------------------------------------%
        function file_specReadButtonVisibility(app)
            if ~isempty(app.metaData)
                app.tool_ReadSpectrumData.Enable = 1;
            else
                app.tool_ReadSpectrumData.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        % MISCELÂNEAS
        %-----------------------------------------------------------------%
        function updateWarningLampVisibility(app)
            if isfolder(app.General.fileFolder.DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            % ...
        end

        %-----------------------------------------------------------------%
        function updateLastVisitedFolder(app, filePath)
            app.General_I.fileFolder.lastVisited = filePath;
            app.General.fileFolder.lastVisited   = filePath;

            appEngine.util.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General_I, app.executionMode)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % SISTEMA DE GESTÃO DA FISCALIZAÇÃO (eFiscaliza/SEI)
        %-----------------------------------------------------------------%
        function createEFiscalizaObject(app, credentials)
            if ~isempty(credentials)
                app.eFiscalizaObj = ws.eFiscaliza(credentials.login, credentials.password);
            end
        end

        %-----------------------------------------------------------------%
        function reportDispatchOperation(app, eventName, varargin)
            arguments
                app
                eventName {mustBeMember(eventName, {'onReportGenerate', 'onUploadArtifacts'})}
            end

            arguments (Repeating)
                varargin
            end

            if isempty(app.eFiscalizaObj) || ~isvalid(app.eFiscalizaObj)
                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');

                customFormData = struct('UUID', eventName, 'Fields', dialogBox, 'Context', app.Context);
                if ~isempty(varargin)
                    customFormData.Varargin = varargin;
                end

                sendEventToHTMLSource(app.jsBackDoor, 'customForm', customFormData)

            else
                reportHandleOperation(app, eventName, app.Context, [], varargin{:})
            end
        end

        %-----------------------------------------------------------------%
        function reportHandleOperation(app, eventName, context, credentials, varargin)
            arguments
                app
                eventName {mustBeMember(eventName, {'onFetchIssueDetails', 'onReportGenerate', 'onUploadArtifacts'})}
                context {mustBeMember(context, {'MONITORINGPLAN', 'EXTERNALREQUEST'})}
                credentials
            end

            arguments (Repeating)
                varargin
            end

            switch eventName
                case 'onFetchIssueDetails'
                    reportFetchIssueDetails(app, context, credentials)

                case 'onReportGenerate'
                    indexes = varargin{1};
                    reportGenerate(app, context, credentials, indexes);
        
                case 'onUploadArtifacts'
                    reportUploadArtifacts(app, context, credentials, 'uploadDocument');
            end
        end

        %-----------------------------------------------------------------%
        function reportFetchIssueDetails(app, context, credentials)
            callingApp = getAppHandle(app.tabGroupController, context);
            if isempty(callingApp)
                callingApp = app;
            end

            callingApp.progressDialog.Visible = 'visible';

            createEFiscalizaObject(app, credentials)
            system = app.projectData.modules.(context).ui.system;
            issue  = app.projectData.modules.(context).ui.issue;
            [details, msgError] = getOrFetchIssueDetails(app.projectData, system, issue, app.eFiscalizaObj);

            if app ~= callingApp
                ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', 'onFetchIssueDetails', system, issue, details, msgError)

            else
                if isempty(msgError)
                    msg = util.HtmlTextGenerator.issueDetails(system, issue, details);
                    icon = 'info';
                else
                    app.eFiscalizaObj = [];
                    msg = msgError;
                    icon = 'error';
                end
                ui.Dialog(app.UIFigure, icon, msg);
            end

            callingApp.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function reportGenerate(app, context, credentials, indexes)
            callingApp = getAppHandle(app.tabGroupController, context);
            if isempty(callingApp)
                callingApp = app;
            end

            callingApp.progressDialog.Visible = 'visible';

            createEFiscalizaObject(app, credentials)
            try
                reportLibConnection.Controller.Run(app, callingApp, context, app.measData(indexes))
                if app == callingApp
                    updateToolbar(app)
                else
                    ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', 'onReportGenerate')
                end

            catch ME
                app.eFiscalizaObj = [];
                ui.Dialog(callingApp.UIFigure, 'error', getReport(ME));
            end

            callingApp.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function reportUploadArtifacts(app, context, credentials, operation)
            callingApp = getAppHandle(app.tabGroupController, context);
            if isempty(callingApp)
                callingApp = app;
            end

            callingApp.progressDialog.Visible = 'visible';

            createEFiscalizaObject(app, credentials)
            [status1, icon1, msg1] = reportUploadToSEI(app, context, operation);
            ui.Dialog(callingApp.UIFigure, icon1, msg1);

            callingApp.progressDialog.Visible = 'hidden';
            
            if status1 && strcmp(app.projectData.modules.(context).ui.system, 'eFiscaliza')
                [status2, msg2] = reportUploadFilesToSharepoint(app, context);

                if ~status2
                    ui.Dialog(callingApp.UIFigure, 'error', msg2);
                end
            end
        end

        %-------------------------------------------------------------------------%
        function [status, icon, msg] = reportUploadToSEI(app, context, operation)
            try
                env = strsplit(app.projectData.modules.(context).ui.system);
                if isscalar(env)
                    env = 'PD';
                else
                    env = env{2};
                end

                system = app.projectData.modules.(context).ui.system;
                unit = app.projectData.modules.(context).ui.unit;
                issue = app.projectData.modules.(context).ui.issue;
                issueInfo = struct( ...
                    'type', 'ATIVIDADE DE INSPEÇÃO', ...
                    'id', issue ...
                );

                switch operation
                    case 'uploadDocument'
                        HTMLFile = getGeneratedDocumentFileName(app.projectData, '.html', context);

                        [~, modelIdx]   = ismember(app.projectData.modules.(context).ui.reportModel, {app.projectData.report.templates.Name});
                        docType         = app.projectData.report.templates(modelIdx).DocumentType;
                        [~, docTypeIdx] = ismember(docType, {app.General.eFiscaliza.internal.typeIdMapping.type});

                        docSpec = app.General.eFiscaliza;
                        docSpec.originId = docSpec.internal.originId;
                        docSpec.typeId = app.General.eFiscaliza.internal.typeIdMapping(docTypeIdx).id;
                        docSpec.nomeArvore = ['[' class.Constants.appName ']'];

                        if app.projectData.modules.(context).ui.entity.status
                            docSpec.interessados = {struct( ...
                                'sigla', app.projectData.modules.(context).ui.entity.id, ...
                                'nome', app.projectData.modules.(context).ui.entity.name ...
                            )};
                        end

                        response = run(app.eFiscalizaObj, env, operation, issueInfo, unit, docSpec, HTMLFile);

                    otherwise
                        error('Unexpected call')
                end

                if ~contains(response, 'Documento cadastrado no SEI', 'IgnoreCase', true)
                    error(response)
                end

                updateUploadedFiles(app.projectData, context, system, issue, response)

                status = true;
                icon   = 'success';
                msg    = response;

            catch ME
                app.eFiscalizaObj = [];
                
                status = false;
                icon   = 'error';
                msg    = ME.message;
            end
        end

        %------------------------------------------------------------------------%
        function [status, msg] = reportUploadFilesToSharepoint(app, context)
            sharepointFileList = { ...
                getGeneratedDocumentFileName(app.projectData, '.teams',   context), ...
                getGeneratedDocumentFileName(app.projectData, '.json',    context), ...
                getGeneratedDocumentFileName(app.projectData, 'rawFiles', context)  ...
            };

            statusList = false(1, numel(sharepointFileList));
            msgList = {};
        
            for ii = 1:numel(sharepointFileList)
                [statusList(ii), msgWarning] = copyfile(sharepointFileList{ii}, app.General.fileFolder.DataHub_POST, 'f');
        
                if ~statusList(ii)
                    msgList{end+1} = msgWarning;
                end
            end
        
            status = all(statusList);
            msg = strjoin(msgList, '\n\n');
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            try
                appEngine.boot(app, app.Role)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            if strcmp(app.progressDialog.Visible, 'visible')
                app.progressDialog.Visible = 'hidden';
                return
            end

            % if ~strcmp(app.executionMode, 'webApp')
            %     projectName = char(app.report_ProjectName.Value);
            %     if ~isempty(projectName) && app.report_ProjectWarnIcon.Visible
            %         msgQuestion = sprintf(['O projeto aberto - registrado no arquivo <b>"%s"</b> - foi alterado.\n\n' ...
            %                                'Deseja descartar essas alterações? Caso não, favor salvá-las no modo RELATÓRIO.'], projectName);
            %     else
            %         msgQuestion = 'Deseja fechar o aplicativo?';
            %     end
            % 
            %     userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
            %     if userSelection == "Não"
            %         return
            %     end
            % end

            % Aspectos gerais (comum em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)
            
        end

        % Callback function: AppInfo, DataHubLamp, FigurePosition, 
        % ...and 6 other components
        function onTabNavigatorButtonPushed(app, event)

            switch event.Source
                case {app.Tab1Button, app.Tab2Button, app.Tab3Button, app.Tab4Button, app.Tab6Button, app.Tab7Button}
                    openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, app)

                case app.DataHubLamp
                    msg = [ ...
                        'Pendente mapear a pasta POST do SharePoint, de modo a viabilizar:<br>' ...
                        '•&thinsp;Upload do relatório final para o SEI.' ...
                    ];
                    ui.Dialog(app.UIFigure, 'error', msg);

                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appEngine.util.setWindowPosition(app.UIFigure)
                    focus(findobj(app.NavBar.Children, 'Type', 'uistatebutton', 'Value', true))

                case app.AppInfo
                    appInfo = util.HtmlTextGenerator.AppInfo( ...
                        app.General, ...
                        app.rootFolder, ...
                        app.executionMode, ...
                        app.renderCount, ...
                        "popup" ...
                    );
                    ui.Dialog(app.UIFigure, 'info', appInfo);
            end
            
        end

        % Selection changed function: FileTree
        function onTreeSelectionChanged(app, event)
            
            currentSelectedFileIndex = [];

            if ~isempty(app.FileTree.SelectedNodes)
                % Caso sejam selecionados nós de apenas um único arquivo,
                % apresentam-se os metadados relacionados à informação 
                % espectral, além de habilitar os botões do toolbar.

                idxFileList   = arrayfun(@(x) x.NodeData.idx1, app.FileTree.SelectedNodes, "UniformOutput", false);
                idxFile       = unique(horzcat(idxFileList{:}));

                if isscalar(idxFile)
                    idxThreadList = arrayfun(@(x) x.NodeData.idx2, app.FileTree.SelectedNodes, "UniformOutput", false);
                    idxThread     = idxThreadList{1};

                    for ii = 2:numel(idxThreadList)
                        idxThread = intersect(idxThread, idxThreadList{ii});
                    end

                    if ~isempty(idxThread)
                        currentSelectedFileIndex = struct('previousSelectedFileIndex',  idxFile, ...
                                                          'previousSelectedFileThread', idxThread);
                    end
                else
                    
                end
            end

            if isequal(app.FileTree.UserData, currentSelectedFileIndex)
                % Não faz nada...

            elseif ~isempty(currentSelectedFileIndex)
                app.FileTree.UserData = currentSelectedFileIndex;

                collapse(app.FileTree)                        
                expand(app.FileTree.Children(idxFile), 'all')
                scroll(app.FileTree, app.FileTree.SelectedNodes(end))

                ui.TextView.update(app.FileMetadata, util.HtmlTextGenerator.Thread(app.metaData, idxFile, idxThread));

            else
                app.FileTree.UserData = struct('previousSelectedFileIndex', [], 'previousSelectedFileThread', []);
                ui.TextView.update(app.FileMetadata, '');
            end
            
        end

        % Selection change function: SubTabGroup
        function onSubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Image clicked function: tool_ReadFiles
        function Toolbar_SelectFileToReadButtonClicked(app, event)

            if app.General.operationMode.Simulation
                app.General.operationMode.Simulation = false;
                
                [projectFolder, ...
                 programDataFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
                simulationFolders   = {programDataFolder, projectFolder};

                for ii = 1:numel(simulationFolders)
                    filePath    = fullfile(simulationFolders{ii}, 'Simulation');    
                    listOfFiles = dir(filePath);
                    fileName    = {listOfFiles.name};
                    fileName    = fileName(endsWith(lower(fileName), '.mat'));

                    if ~isempty(fileName)
                        break
                    end
                end

            else
                [~, filePath, ~, fileName] = ui.Dialog(app.UIFigure, 'uigetfile', '', ...
                    {'*.bin;*.dbm;*.mat', 'Binários (*.bin,*.dbm,*.mat)'; ...
                     '*.csv;*.sm1809',    'Textuais (*.csv,*.sm1809)'}, app.General.fileFolder.lastVisited, {'MultiSelect', 'on'});
    
                if isempty(fileName)
                    return
                elseif ~iscell(fileName)
                    fileName = {fileName};
                end
                updateLastVisitedFolder(app, filePath)
            end

            file_OpenSelectedFiles(app, filePath, fileName)

        end

        % Image clicked function: tool_ReadSpectrumData
        function Toolbar_ReadSpecDataButtonClicked(app, event)
                        
            % <ReviewNote> EMD - 22/08/2024</ReviewNote>
            % Verificar se há ao menos um fluxo a ser lido...
            flag = false;
            for ii = 1:numel(app.metaData)
                if any([app.metaData(ii).Data.Enable])
                    flag = true;
                    break
                end
            end

            if ~flag
                ui.Dialog(app.UIFigure, 'warning', 'Não há fluxo de informação a ser lido...');
                return
            end

            % Verifica se os módulos auxiliares abaixo descritos estão abertos.
            % - auxiliarWin1: winSignalAnalysis
            % - auxiliarWin2: winDriveTest
            if strcmp(auxAppStatus(app, 'RELER INFORMAÇÃO ESPECTRAL'), 'Não')
                return
            end

            % Reinicia a variável, caso não vazia...
            if ~isempty(app.specData)
                delete(app.specData)
                app.specData = model.SpecData.empty;
            end
           
            d = [];
            try
                d = ui.Dialog(app.UIFigure, 'progressdlg', 'Em andamento...');
                app.specData = spectrumRead(app.specData, app.metaData, app, d);
    
                % Desabilita botão, inviabilizando leitura do mesmo conjunto de
                % dados.
                app.tool_ReadSpectrumData.Enable = 0;
                ipcMainMatlabCallAuxiliarApp(app, 'PLAYBACK', 'MATLAB', 'onSpecDataRead')

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
                file_DataReaderError(app)
            end

            delete(d)

        end

        % Value changed function: FileFilterType
        function FileFilterTypeChanged(app, event)

            cellfun(@(x) set(x, 'Visible', 'off'), {app.FileFilterValue_Frequency, app.FileFilterValue_ID, app.FileFilterValue_Description});

            switch app.FileFilterType.Value
                case 'Faixa de Frequência'; app.FileFilterValue_Frequency.Visible   = 'on';
                case 'ID';                  app.FileFilterValue_ID.Visible          = 'on';
                case 'Descrição';           app.FileFilterValue_Description.Visible = 'on';
            end

        end

        % Image clicked function: FileFilterAdd
        function FileFilterAddClicked(app, event)
            
            switch app.FileFilterType.Value
                case 'Faixa de Frequência'
                    if isempty(app.FileFilterValue_Frequency.Value)
                        return
                    end
                    newFilterText = sprintf('FREQUÊNCIA: %s', app.FileFilterValue_Frequency.Value);
                    
                case 'ID'
                    if isempty(app.FileFilterValue_ID.Value)
                        return
                    end
                    newFilterText = sprintf('ID: %s', app.FileFilterValue_ID.Value);
                    
                case 'Descrição'
                    app.FileFilterValue_Description.Value = upper(strtrim(app.FileFilterValue_Description.Value));
                    
                    if isempty(app.FileFilterValue_Description.Value)
                        return
                    else
                        newFilterText = sprintf('DESCRIÇÃO: "%s"', app.FileFilterValue_Description.Value);
                    end
            end

            hComponents = allchild(app.FileFilterTree);
            if ~isempty(hComponents) && ismember(newFilterText, {hComponents.Text})
                return
            end

            uitreenode(app.FileFilterTree, 'Text',        newFilterText, ...
                                               'ContextMenu', app.file_ContextMenu_Tree2);
            buildFileTree(app)

        end

        % Menu selected function: file_ContextMenu_delTree1Node
        function ContextMenu_delTree1NodeSelected(app, event)
            % <ReviewNote>EMD - 14/08/2024</ReviewNote>
            idxTable = table('Size', [0, 3],                                ...
                             'VariableTypes', {'double', 'double', 'cell'}, ...
                             'VariableNames', {'level', 'idx1', 'idx2'});

            for ii = 1:numel(app.FileTree.SelectedNodes)
                idx = find(idxTable.idx1 == app.FileTree.SelectedNodes(ii).NodeData.idx1, 1);
                if isempty(idx)
                    idxTable(end+1,:)   = {app.FileTree.SelectedNodes(ii).NodeData.level, app.FileTree.SelectedNodes(ii).NodeData.idx1, {app.FileTree.SelectedNodes(ii).NodeData.idx2}};
                else
                    idxTable(idx,[1,3]) = {min([idxTable{idx,1}, app.FileTree.SelectedNodes(ii).NodeData.level]), {unique([cell2mat(idxTable{idx,3}), app.FileTree.SelectedNodes(ii).NodeData.idx2])}};
                end
            end

            idxTable = sortrows(idxTable, 'idx1');

            for kk = height(idxTable):-1:1
                idx1 = idxTable.idx1(kk);
                idx2 = idxTable.idx2{kk};

                switch idxTable.level(kk)
                    case 1
                        delete(app.metaData(idx1))
                        app.metaData(idx1) = [];

                    otherwise
                        if isequal(idxTable.idx2{kk}, 1:numel(app.metaData(idx1).Data))
                            delete(app.metaData(idx1))
                            app.metaData(idx1) = [];
                        else
                            delete(app.metaData(idx1).Data(idx2))
                            app.metaData(idx1).Data(idx2)    = [];
                            app.metaData(idx1).Samples(idx2) = [];
                            app.metaData(idx1).Memory        = EstimatedMemory(app.metaData, idx1);
                        end
                end
            end
            
            buildFileTree(app)

        end

        % Menu selected function: file_ContextMenu_delTree2Node
        function ContextMenu_delTree2NodeSelected(app, event)
            
            if ~isempty(app.FileFilterTree.SelectedNodes)
                delete(app.FileFilterTree.SelectedNodes)
                buildFileTree(app)
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 1244 660];
            app.UIFigure.Name = 'appAnalise';
            app.UIFigure.Icon = 'icon_48.png';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);
            app.UIFigure.HandleVisibility = 'on';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {54, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Tooltip = {''};
            app.GridLayout.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1
            app.Tab1 = uitab(app.TabGroup);
            app.Tab1.AutoResizeChildren = 'off';
            app.Tab1.Title = 'FILE';

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1);
            app.Tab1Grid.ColumnWidth = {10, '1x', '1x', 10, '0.25x', 360, 10};
            app.Tab1Grid.RowHeight = {94, 10, '1x', 10, 34};
            app.Tab1Grid.ColumnSpacing = 0;
            app.Tab1Grid.RowSpacing = 0;
            app.Tab1Grid.Padding = [0 0 0 40];
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create FileTree
            app.FileTree = uitree(app.Tab1Grid);
            app.FileTree.Multiselect = 'on';
            app.FileTree.SelectionChangedFcn = createCallbackFcn(app, @onTreeSelectionChanged, true);
            app.FileTree.FontSize = 11;
            app.FileTree.Layout.Row = 3;
            app.FileTree.Layout.Column = [2 3];

            % Create FileMetadata
            app.FileMetadata = uilabel(app.Tab1Grid);
            app.FileMetadata.VerticalAlignment = 'top';
            app.FileMetadata.WordWrap = 'on';
            app.FileMetadata.FontSize = 11;
            app.FileMetadata.Layout.Row = 3;
            app.FileMetadata.Layout.Column = [5 6];
            app.FileMetadata.Interpreter = 'html';
            app.FileMetadata.Text = '';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.Tab1Grid);
            app.Toolbar.ColumnWidth = {22, 5, 22, '1x'};
            app.Toolbar.RowHeight = {3, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 5;
            app.Toolbar.Layout.Column = [1 7];

            % Create tool_ReadFiles
            app.tool_ReadFiles = uiimage(app.Toolbar);
            app.tool_ReadFiles.ScaleMethod = 'none';
            app.tool_ReadFiles.ImageClickedFcn = createCallbackFcn(app, @Toolbar_SelectFileToReadButtonClicked, true);
            app.tool_ReadFiles.Tooltip = {'Seleciona arquivos'};
            app.tool_ReadFiles.Layout.Row = 2;
            app.tool_ReadFiles.Layout.Column = 1;
            app.tool_ReadFiles.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Import_16.png');

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 2;
            app.tool_Separator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_ReadSpectrumData
            app.tool_ReadSpectrumData = uiimage(app.Toolbar);
            app.tool_ReadSpectrumData.ScaleMethod = 'none';
            app.tool_ReadSpectrumData.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ReadSpecDataButtonClicked, true);
            app.tool_ReadSpectrumData.Enable = 'off';
            app.tool_ReadSpectrumData.Tooltip = {'Inicia análise'};
            app.tool_ReadSpectrumData.Layout.Row = 2;
            app.tool_ReadSpectrumData.Layout.Column = 3;
            app.tool_ReadSpectrumData.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Run_16.png');

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.Tab1Grid);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @onSubTabGroupSelectionChanged, true);
            app.SubTabGroup.Layout.Row = 1;
            app.SubTabGroup.Layout.Column = [2 6];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'ARQUIVOS';
            app.SubTab1.BackgroundColor = 'none';
            app.SubTab1.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {'1x'};
            app.SubGrid1.RowHeight = {'1x'};
            app.SubGrid1.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create FileModuleInfo
            app.FileModuleInfo = uilabel(app.SubGrid1);
            app.FileModuleInfo.VerticalAlignment = 'top';
            app.FileModuleInfo.WordWrap = 'on';
            app.FileModuleInfo.FontSize = 11;
            app.FileModuleInfo.FontColor = [0.149 0.149 0.149];
            app.FileModuleInfo.Layout.Row = 1;
            app.FileModuleInfo.Layout.Column = 1;
            app.FileModuleInfo.Text = 'Este aplicativo permite a leitura de arquivos gerados em monitorações do espectro de radiofrequências usando o appColeta, Logger, Argus e CelPlan, organizando as informações por faixa de frequência. Também realiza detecção e classificação de emissões, comparando com informações constantes no RFDataHub. E, por fim, possibilita anotação dos dados e geração de relatório.';

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'FILTRO';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {320, 22, 320};
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create FileFilterType
            app.FileFilterType = uidropdown(app.SubGrid2);
            app.FileFilterType.Items = {'Faixa de Frequência', 'ID', 'Descrição'};
            app.FileFilterType.ValueChangedFcn = createCallbackFcn(app, @FileFilterTypeChanged, true);
            app.FileFilterType.FontSize = 11;
            app.FileFilterType.BackgroundColor = [1 1 1];
            app.FileFilterType.Layout.Row = 1;
            app.FileFilterType.Layout.Column = 1;
            app.FileFilterType.Value = 'Faixa de Frequência';

            % Create FileFilterValue_Description
            app.FileFilterValue_Description = uieditfield(app.SubGrid2, 'text');
            app.FileFilterValue_Description.FontSize = 11;
            app.FileFilterValue_Description.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterValue_Description.Visible = 'off';
            app.FileFilterValue_Description.Layout.Row = 2;
            app.FileFilterValue_Description.Layout.Column = 1;

            % Create FileFilterValue_ID
            app.FileFilterValue_ID = uidropdown(app.SubGrid2);
            app.FileFilterValue_ID.Items = {};
            app.FileFilterValue_ID.Visible = 'off';
            app.FileFilterValue_ID.FontSize = 11;
            app.FileFilterValue_ID.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterValue_ID.BackgroundColor = [1 1 1];
            app.FileFilterValue_ID.Layout.Row = 2;
            app.FileFilterValue_ID.Layout.Column = 1;
            app.FileFilterValue_ID.Value = {};

            % Create FileFilterValue_Frequency
            app.FileFilterValue_Frequency = uidropdown(app.SubGrid2);
            app.FileFilterValue_Frequency.Items = {};
            app.FileFilterValue_Frequency.FontSize = 11;
            app.FileFilterValue_Frequency.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterValue_Frequency.BackgroundColor = [1 1 1];
            app.FileFilterValue_Frequency.Layout.Row = 2;
            app.FileFilterValue_Frequency.Layout.Column = 1;
            app.FileFilterValue_Frequency.Value = {};

            % Create FileFilterAdd
            app.FileFilterAdd = uiimage(app.SubGrid2);
            app.FileFilterAdd.ScaleMethod = 'none';
            app.FileFilterAdd.ImageClickedFcn = createCallbackFcn(app, @FileFilterAddClicked, true);
            app.FileFilterAdd.Tooltip = {''};
            app.FileFilterAdd.Layout.Row = [1 2];
            app.FileFilterAdd.Layout.Column = 2;
            app.FileFilterAdd.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Continue_16.png');

            % Create FileFilterTree
            app.FileFilterTree = uitree(app.SubGrid2);
            app.FileFilterTree.Multiselect = 'on';
            app.FileFilterTree.FontSize = 10;
            app.FileFilterTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterTree.Layout.Row = [1 2];
            app.FileFilterTree.Layout.Column = 3;

            % Create Tab2_Playback
            app.Tab2_Playback = uitab(app.TabGroup);
            app.Tab2_Playback.AutoResizeChildren = 'off';
            app.Tab2_Playback.Title = 'PLAYBACK+REPORT+MISC';

            % Create Tab3_DriveTest
            app.Tab3_DriveTest = uitab(app.TabGroup);
            app.Tab3_DriveTest.AutoResizeChildren = 'off';
            app.Tab3_DriveTest.Title = 'DRIVE-TEST';

            % Create Tab4_SignalAnalysis
            app.Tab4_SignalAnalysis = uitab(app.TabGroup);
            app.Tab4_SignalAnalysis.AutoResizeChildren = 'off';
            app.Tab4_SignalAnalysis.Title = 'SIGNALANALYSIS';

            % Create Tab5_Misc
            app.Tab5_Misc = uitab(app.TabGroup);
            app.Tab5_Misc.Title = 'MISC';

            % Create Tab5_RFDataHub
            app.Tab5_RFDataHub = uitab(app.TabGroup);
            app.Tab5_RFDataHub.AutoResizeChildren = 'off';
            app.Tab5_RFDataHub.Title = 'RFDATAHUB';

            % Create Tab6_Config
            app.Tab6_Config = uitab(app.TabGroup);
            app.Tab6_Config.AutoResizeChildren = 'off';
            app.Tab6_Config.Title = 'CONFIG';

            % Create NavBar
            app.NavBar = uigridlayout(app.GridLayout);
            app.NavBar.ColumnWidth = {22, 74, '1x', 34, 5, 34, 34, 34, 34, 34, 34, '1x', 20, 20, 1, 20, 20};
            app.NavBar.RowHeight = {5, 7, 20, 7, 5};
            app.NavBar.ColumnSpacing = 5;
            app.NavBar.RowSpacing = 0;
            app.NavBar.Padding = [10 5 5 5];
            app.NavBar.Tag = 'COLORLOCKED';
            app.NavBar.Layout.Row = 1;
            app.NavBar.Layout.Column = 1;
            app.NavBar.BackgroundColor = [0.2 0.2 0.2];

            % Create AppIcon
            app.AppIcon = uiimage(app.NavBar);
            app.AppIcon.Layout.Row = [1 5];
            app.AppIcon.Layout.Column = 1;
            app.AppIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Connect_36White.png');

            % Create AppName
            app.AppName = uilabel(app.NavBar);
            app.AppName.WordWrap = 'on';
            app.AppName.FontSize = 11;
            app.AppName.FontColor = [1 1 1];
            app.AppName.Layout.Row = [1 5];
            app.AppName.Layout.Column = [2 3];
            app.AppName.Interpreter = 'html';
            app.AppName.Text = {'appAnalise v. 1.88.0'; '<font style="font-size: 9px;">R2024a</font>'};

            % Create Tab1Button
            app.Tab1Button = uibutton(app.NavBar, 'state');
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab1Button.Tag = 'FILE';
            app.Tab1Button.Tooltip = {'Leitura de arquivos'};
            app.Tab1Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'folder-active-24px-yellow.svg');
            app.Tab1Button.IconAlignment = 'top';
            app.Tab1Button.Text = '';
            app.Tab1Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab1Button.FontSize = 11;
            app.Tab1Button.Layout.Row = [2 4];
            app.Tab1Button.Layout.Column = 4;
            app.Tab1Button.Value = true;

            % Create ButtonsSeparator1
            app.ButtonsSeparator1 = uiimage(app.NavBar);
            app.ButtonsSeparator1.ScaleMethod = 'none';
            app.ButtonsSeparator1.Enable = 'off';
            app.ButtonsSeparator1.Layout.Row = [2 4];
            app.ButtonsSeparator1.Layout.Column = 5;
            app.ButtonsSeparator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab2Button
            app.Tab2Button = uibutton(app.NavBar, 'state');
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'PLAYBACK';
            app.Tab2Button.Tooltip = {'Playback'};
            app.Tab2Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'graph-line-24px-white.svg');
            app.Tab2Button.IconAlignment = 'top';
            app.Tab2Button.Text = '';
            app.Tab2Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab2Button.FontSize = 11;
            app.Tab2Button.Layout.Row = [2 4];
            app.Tab2Button.Layout.Column = 6;

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'DRIVETEST';
            app.Tab3Button.Tooltip = {'Drive-test'};
            app.Tab3Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'graph-line-24px-white.svg');
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 7;

            % Create Tab4Button
            app.Tab4Button = uibutton(app.NavBar, 'state');
            app.Tab4Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab4Button.Tag = 'SIGNALANALYSIS';
            app.Tab4Button.Tooltip = {'Análise de sinais'};
            app.Tab4Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'graph-line-24px-white.svg');
            app.Tab4Button.IconAlignment = 'top';
            app.Tab4Button.Text = '';
            app.Tab4Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab4Button.FontSize = 11;
            app.Tab4Button.Layout.Row = [2 4];
            app.Tab4Button.Layout.Column = 8;

            % Create Tab5Button
            app.Tab5Button = uibutton(app.NavBar, 'state');
            app.Tab5Button.Tag = 'MISC';
            app.Tab5Button.Tooltip = {'Miscelâneas'};
            app.Tab5Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'edit.svg');
            app.Tab5Button.IconAlignment = 'top';
            app.Tab5Button.Text = '';
            app.Tab5Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab5Button.FontSize = 11;
            app.Tab5Button.Layout.Row = [2 4];
            app.Tab5Button.Layout.Column = 9;

            % Create Tab6Button
            app.Tab6Button = uibutton(app.NavBar, 'state');
            app.Tab6Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab6Button.Tag = 'RFDATAHUB';
            app.Tab6Button.Tooltip = {'RFDataHub'};
            app.Tab6Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'database-24px-white.svg');
            app.Tab6Button.IconAlignment = 'top';
            app.Tab6Button.Text = '';
            app.Tab6Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab6Button.FontSize = 11;
            app.Tab6Button.Layout.Row = [2 4];
            app.Tab6Button.Layout.Column = 10;

            % Create Tab7Button
            app.Tab7Button = uibutton(app.NavBar, 'state');
            app.Tab7Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab7Button.Tag = 'CONFIG';
            app.Tab7Button.Tooltip = {'Configurações gerais'};
            app.Tab7Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'gear-24px-white.svg');
            app.Tab7Button.IconAlignment = 'top';
            app.Tab7Button.Text = '';
            app.Tab7Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab7Button.FontSize = 11;
            app.Tab7Button.Layout.Row = [2 4];
            app.Tab7Button.Layout.Column = 11;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.NavBar);
            app.jsBackDoor.Layout.Row = [2 5];
            app.jsBackDoor.Layout.Column = 13;

            % Create DataHubLamp
            app.DataHubLamp = uiimage(app.NavBar);
            app.DataHubLamp.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear o Sharepoint'};
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 14;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ScaleMethod = 'none';
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Tooltip = {'Reposiciona janela'};
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 16;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-normal-24px-white.svg');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.AppInfo.Tooltip = {'Informações gerais'};
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 17;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'kebab-vertical-24px-white.svg');

            % Create file_ContextMenu_Tree1
            app.file_ContextMenu_Tree1 = uicontextmenu(app.UIFigure);
            app.file_ContextMenu_Tree1.Tag = 'winAppAnalise';

            % Create file_ContextMenu_delTree1Node
            app.file_ContextMenu_delTree1Node = uimenu(app.file_ContextMenu_Tree1);
            app.file_ContextMenu_delTree1Node.MenuSelectedFcn = createCallbackFcn(app, @ContextMenu_delTree1NodeSelected, true);
            app.file_ContextMenu_delTree1Node.ForegroundColor = [1 0 0];
            app.file_ContextMenu_delTree1Node.Text = 'Excluir';

            % Create file_ContextMenu_Tree2
            app.file_ContextMenu_Tree2 = uicontextmenu(app.UIFigure);
            app.file_ContextMenu_Tree2.Tag = 'winAppAnalise';

            % Create file_ContextMenu_delTree2Node
            app.file_ContextMenu_delTree2Node = uimenu(app.file_ContextMenu_Tree2);
            app.file_ContextMenu_delTree2Node.MenuSelectedFcn = createCallbackFcn(app, @ContextMenu_delTree2NodeSelected, true);
            app.file_ContextMenu_delTree2Node.ForegroundColor = [1 0 0];
            app.file_ContextMenu_delTree2Node.Text = 'Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winAppAnalise_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
