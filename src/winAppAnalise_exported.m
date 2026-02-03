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
        Tab1_File                      matlab.ui.container.Tab
        file_Grid                      matlab.ui.container.GridLayout
        SubTabGroup                    matlab.ui.container.TabGroup
        SubTab1                        matlab.ui.container.Tab
        SubGrid1                       matlab.ui.container.GridLayout
        NOMEDAEMPRESAMetadadosOutrascoisasLabel  matlab.ui.control.Label
        SubTab2                        matlab.ui.container.Tab
        SubGrid2                       matlab.ui.container.GridLayout
        file_FilteringTree             matlab.ui.container.Tree
        file_FilteringAdd              matlab.ui.control.Image
        file_FilteringValue_Frequency  matlab.ui.control.DropDown
        file_FilteringValue_ID         matlab.ui.control.DropDown
        file_FilteringValue_Description  matlab.ui.control.EditField
        file_FilteringType             matlab.ui.control.DropDown
        file_toolGrid                  matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        file_SpecReadButton            matlab.ui.control.Image
        file_OpenFileButton            matlab.ui.control.Image
        file_Metadata                  matlab.ui.control.Label
        file_Tree                      matlab.ui.container.Tree
        Tab2_Playback                  matlab.ui.container.Tab
        Tab3_DriveTest                 matlab.ui.container.Tab
        Tab4_SignalAnalysis            matlab.ui.container.Tab
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

        metaData = model.MetaData.empty
        specData = model.SpecData.empty
        projectData

        rfDataHub
        rfDataHubLOG
        rfDataHubSummary

        bandObj
        channelObj

        restoreView = struct('ID', {}, 'xLim', {}, 'yLim', {}, 'cLim', {})
        plotFlag = 0
        plotLayout = 1
        idxTime = 1

        UIAxes1
        UIAxes2
        UIAxes3

        hClearWrite                                                         % ClearWrite (main trace)
        hMinHold
        hAverage
        hMaxHold
        hPersistanceObj                                                     % Persistance Object    
        hSelectedEmission                                                   % Selected marker roi
        hEmissionMarkers                                                    % Markers labels        
        hTHR                                                                % OCC roi/line
        hTHRLabel                                                           % OCC roi/line label ("THR")            
        hWaterfall
        hWaterfallTime                                                      % Waterfall timestamp
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
                            selectedNodes = app.file_Tree.SelectedNodes;
                            if ~isempty(app.file_Tree.SelectedNodes)
                                app.file_Tree.SelectedNodes = [];
                                file_TreeSelectionChanged(app)
                            end

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            if ~isempty(selectedNodes)
                                app.file_Tree.SelectedNodes = selectedNodes;
                                file_TreeSelectionChanged(app)
                            end
                        end
                        
                        app.renderCount = app.renderCount+1;

                    case 'unload'
                        closeFcn(app)
                    
                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'eFiscalizaSignInPage'
                                report_uploadInfoController(app, event.HTMLEventData, 'uploadDocument')

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    % MAINAPP
                    case 'mainApp.file_Tree'
                        file_ContextMenu_delTree1NodeSelected(app)

                    case 'mainApp.file_FilteringTree'
                        file_ContextMenu_delTree2NodeSelected(app)

                    case 'mainApp.play_Channel_Tree'
                        play_Channel_ContextMenu_delChannelSelected(app)

                    case 'mainApp.play_BandLimits_Tree'
                        play_BandLimits_ContextMenu_delSelected(app)

                    case 'mainApp.play_FindPeaks_Tree'
                        play_FindPeaks_delEmission(app)

                    case 'mainApp.report_Tree'
                        report_ContextMenu_delSelected(app)

                    % DRIVETEST / RFDATAHUB
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
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, operationType, varargin)
            varargout = {};

            try
                switch operationType
                    case 'closeFcn'
                        auxAppTag    = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        auxAppTag    = varargin{1};
                        varargout{1} = auxAppInputArguments(app, auxAppTag);

                    otherwise
                        switch class(callingApp)
                            % CONFIG
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch operationType
                                    case 'checkDataHubLampStatus'
                                        DataHubWarningLamp(app)

                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))

                                    case 'simulationModeChanged'
                                        if app.General.operationMode.Simulation
                                            file_ButtonPushed_OpenFile(app)
        
                                            % Muda programaticamente o modo p/ ARQUIVOS.
                                            set(app.Tab1Button, 'Enable', 1, 'Value', 1)                    
                                            tabNavigatorButtonPushed(app, struct('Source', app.Tab1Button, 'PreviousValue', false))
                                        end

                                    case 'onYAxesScaleChange'
                                        if ~isempty(app.UIAxes2) && isvalid(app.UIAxes2)
                                            set(app.UIAxes2, 'YScale', app.General.Plot.Axes.yOccupancyScale)
                                        end

                                    case 'onRFDataHubUpdate'
                                        initializeRFDataHub(app)
                                        ipcMainMatlabCallAuxiliarApp(app, 'RFDATAHUB', 'MATLAB', operationType)

                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            % DRIVETEST
                            case {'auxApp.winDriveTest', 'auxApp.winDriveTest_exported'}
                                switch operationType
                                    case {'ChannelParameterChanged', 'ChannelDefault'}
                                        play_UpdateAuxiliarApps(app, 'SIGNALANALYSIS')

                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            % SIGNALANALYSIS
                            case {'auxApp.winSignalAnalysis', 'auxApp.winSignalAnalysis_exported'}
                                switch operationType
                                    case 'DeleteButtonPushed'
                                        idxThread = varargin{1};
                                        idxEmission = varargin{2};
                    
                                        if isequal(idxThread, app.play_PlotPanel.UserData.NodeData)
                                            plot.draw2D.ClearWrite_old(app, idxThread, operationType, idxEmission)
                                        end
                                        play_UpdateAuxiliarApps(app)

                                    case 'IsTruncatedValueChanged'
                                        idxThread   = varargin{1};
                                        idxEmission = varargin{2};
                                        isTruncated = app.specData(idxThread).UserData.Emissions.isTruncated(idxEmission);
        
                                        update(app.specData(idxThread), 'UserData:Emissions', 'Edit', 'IsTruncated', idxEmission, isTruncated, app.channelObj)
        
                                        if isequal(idxThread, app.play_PlotPanel.UserData.NodeData)
                                            selectedEmission = [app.play_FindPeaks_Tree.SelectedNodes.NodeData];
                                            play_EmissionList(app, idxThread, selectedEmission)
                                        end
                                        play_UpdateAuxiliarApps(app)

                                    case 'PeakDescriptionChanged'
                                        play_FindPeaks_TreeSelectionChanged(app)

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
        
                                switch operationType
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
                                            switch operationType
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
                auxiliarApp char {mustBeMember(auxiliarApp, {'Detection', 'Classification', 'AddFiles', 'TimeFiltering', 'EditLocation', 'AddKFactor', 'AddChannel', 'LevelFiltering'})}
            end

            arguments (Repeating)
                varargin 
            end

            switch auxiliarApp
                case 'Detection';      screenWidth = 412; screenHeight = 282;
                case 'Classification'; screenWidth = 534; screenHeight = 248;
                case 'AddFiles';       screenWidth = 880; screenHeight = 480;
                case 'TimeFiltering';  screenWidth = 640; screenHeight = 480;
                case 'LevelFiltering'; screenWidth = 540; screenHeight = 300;
                case 'EditLocation';   screenWidth = 394; screenHeight = 194;
                case 'AddKFactor';     screenWidth = 480; screenHeight = 360;
                case 'AddChannel';     screenWidth = 560; screenHeight = 480;                
            end

            ui.PopUpContainer(app, class.Constants.appName, screenWidth, screenHeight)

            % Executa o app auxiliar.
            inputArguments = [{app}, varargin];
            
            if app.General.operationMode.Debug
                eval(sprintf('auxApp.dock%s(inputArguments{:})', auxiliarApp))
            else
                eval(sprintf('auxApp.dock%s_exported(app.popupContainer, inputArguments{:})', auxiliarApp))
                app.popupContainer.Parent.Visible = 1;
            end            
        end
    end
    
    
    methods (Access = public)
        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            tabNavigatorButtonPushed(app, struct('Source', clickedButton, 'PreviousValue', false))
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
                    elToModify = {              ...
                        app.file_Metadata,      ... % ui.TextView
                        app.file_Tree,          ...
                        app.NOMEDAEMPRESAMetadadosOutrascoisasLabel ...
                    };

                    elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                    if ~isempty(elDataTag)
                        ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);

                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elDataTag{3}, 'selector', '[class="mwTextNode"]', 'style', struct('textAlign', 'justify')), ...
                            struct('appName', appName, 'dataTag', elDataTag{2}, 'listener', struct('componentName', 'mainApp.file_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    end

                case 2
                    app.file_FilteringValue_ID.UserData.render        = true;
                    app.file_FilteringValue_Frequency.UserData.render = true;
                    app.file_FilteringTree.UserData.render            = true;

                    file_FilterOptions(app)
                    file_FilterCheck(app)

                    elToModify = {app.file_FilteringTree};
                    elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                    if ~isempty(elDataTag)
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elDataTag{1}, 'listener', struct('componentName', 'mainApp.file_FilteringTree',   'keyEvents', {{'Delete', 'Backspace'}}))  ...
                        });
                    end

                    % PLAYBACK-REPORT-MISC (Migrar isso p/ módulo auxApp.winPlayback)
                    
                    % elToModify = {                       ...
                    %     app.play_Metadata,               ... % ui.TextView
                    %     app.play_axesToolbar,            ...
                    %     app.play_Channel_Tree,           ...
                    %     app.play_BandLimits_Tree,        ...
                    %     app.play_FindPeaks_Tree,         ...
                    %     app.report_Tree,                 ...
                    %     app.report_ThreadAlgorithms,     ... % ui.TextView
                    %     app.report_ThreadAlgorithmsImage ... % ui.TextView (Background image)
                    % };
                    % 
                    % elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                    % if ~isempty(elDataTag)
                    %     ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
                    % 
                    %     sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    %         struct('appName', appName, 'dataTag', elDataTag{2}, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                    %         struct('appName', appName, 'dataTag', elDataTag{3}, 'listener', struct('componentName', 'mainApp.play_Channel_Tree',    'keyEvents', {{'Delete', 'Backspace'}})), ...
                    %         struct('appName', appName, 'dataTag', elDataTag{4}, 'listener', struct('componentName', 'mainApp.play_BandLimits_Tree', 'keyEvents', {{'Delete', 'Backspace'}})), ...
                    %         struct('appName', appName, 'dataTag', elDataTag{5}, 'listener', struct('componentName', 'mainApp.play_FindPeaks_Tree',  'keyEvents', {{'Delete', 'Backspace'}})), ...
                    %         struct('appName', appName, 'dataTag', elDataTag{6}, 'listener', struct('componentName', 'mainApp.report_Tree',          'keyEvents', {{'Delete', 'Backspace'}})), ...
                    %     });
                    % 
                    %     ui.TextView.startup(app.jsBackDoor, elToModify{7}, appName);
                    %     ui.TextView.startup(app.jsBackDoor, elToModify{8}, appName, 'SELECIONE UM DOS FLUXOS ESPECTRAIS<br>INSERIDOS NA LISTA DE FLUXOS A PROCESSAR');
                    % end
                    % 
                    % % Inicialização de componentes que não são renderizados 
                    % % inicialmente por estarem em aba invisível.
                    % 
                    % % Painel "PLAYBACK > ASPECTOS GERAIS"
                    % if ismember(num2str(app.General.Integration.Trace), app.play_TraceIntegration.Items)
                    %     app.play_TraceIntegration.Value       = num2str(app.General.Integration.Trace);
                    % else
                    %     app.General_I.Integration.Trace       = Inf;
                    %     app.General.Integration.Trace         = Inf;
                    % end
                    % 
                    % app.tool_LayoutLeft.UserData              = true;
                    % app.tool_LayoutRight.UserData             = true;
                    % 
                    % % Painel "PLAYBACK > ASPECTOS GERAIS > PERSISTÊNCIA"
                    % app.play_Persistance_Interpolation.Value  = app.General.Plot.Persistance.Interpolation;
                    % app.play_Persistance_WindowSize.Value     = app.General.Plot.Persistance.WindowSize;
                    % app.play_Persistance_WindowSizeValue.Text = app.General.Plot.Persistance.WindowSize;
                    % app.play_Persistance_Colormap.Value       = app.General.Plot.Persistance.Colormap;
                    % app.play_Persistance_cLim1.Value          = app.General.Plot.Persistance.LevelLimits(1);
                    % app.play_Persistance_cLim2.Value          = app.General.Plot.Persistance.LevelLimits(2);
                    % play_ControlsPanelSelectionChanged(app)
                    % 
                    % % Painel "PLAYBACK > ASPECTOS GERAIS > WATERFALL"
                    % app.play_Waterfall_Fcn.Value              = app.General.Plot.Waterfall.Fcn;
                    % app.play_Waterfall_Colorbar.Value         = app.General.Plot.Waterfall.Colorbar;
                    % app.play_Waterfall_Decimation.Value       = app.General.Plot.Waterfall.Decimation;
                    % app.play_Waterfall_MeshStyle.Value        = app.General.Plot.Waterfall.MeshStyle;
                    % app.play_Waterfall_Timeline.Value         = app.General.Plot.WaterfallTime.Visible;
                    % app.play_Waterfall_Colormap.Value         = app.General.Plot.Waterfall.Colormap;
                    % app.play_Waterfall_cLim1.Value            = app.General.Plot.Waterfall.LevelLimits(1);
                    % app.play_Waterfall_cLim2.Value            = app.General.Plot.Waterfall.LevelLimits(2);
                    % 
                    % % Painel "PLAYBACK > CANAIS"
                    % channelList = {};
                    % for ii = 1:numel(app.channelObj.Channel)
                    %     channelList{end+1} = sprintf('%d: %.3f - %.3f MHz (%s)', ii, app.channelObj.Channel(ii).Band(1), ...
                    %                                                                  app.channelObj.Channel(ii).Band(2),     ...
                    %                                                                  app.channelObj.Channel(ii).Name);
                    % end
                    % app.play_Channel_List.Items = channelList;
                    % play_Channel_RadioGroupSelectionChanged(app)
                    % 
                    % % Painel "PLAYBACK > EMISSÕES"
                    % app.play_FindPeaks_Class.Items = app.channelObj.FindPeaks.Name;
                    % play_FindPeaks_ClassValueChanged(app)
                    % 
                    % play_FindPeaks_RadioGroupSelectionChanged(app)
                    % 
                    % app.play_FindPeaks_Algorithm.Value = 'FindPeaks+OCC';
                    % play_FindPeaks_AlgorithmValueChanged(app)
                    % 
                    % % Painel "RELATÓRIO"
                    % app.report_Unit.Items      = app.General.eFiscaliza.defaultValues.unit;
                    % app.report_ModelName.Items = [{''}; app.General.Models.Name];
                    % 
                    % if app.General.operationMode.Simulation
                    %     app.report_system.Value = app.report_system.Items{end};
                    % end


                    % function menu_LayoutControl(app, tabIndex)
                    %     if tabIndex ~= 2
                    %         return
                    %     end
                    % 
                    %     if app.Tab2Button.Value
                    %         set(app.play_Tree, 'SelectedNodes', app.play_PlotPanel.UserData, 'Multiselect', 'off')
                    %         play_submenuButtonPushed(app, struct('Source', app.submenu_Button1Icon))
                    % 
                    %     elseif app.Tab3Button.Value
                    %         app.play_Tree.Multiselect = "on";
                    %         play_submenuButtonPushed(app, struct('Source', app.submenu_Button4Icon))
                    % 
                    %         if isempty(app.report_ThreadAlgorithms.UserData.idxThread) || ~isequal(app.report_ThreadAlgorithms.UserData.idxThread, app.play_PlotPanel.UserData)
                    %             app.report_Tree.SelectedNodes = [];
                    %             report_Algorithms(app, app.play_PlotPanel.UserData.NodeData)
                    %         end
                    % 
                    %     elseif app.Tab4Button.Value
                    %         app.play_Tree.Multiselect = "on";
                    %         play_submenuButtonPushed(app, struct('Source', app.submenu_Button6Icon))
                    %     end
                    % end
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
            addComponent(app.tabGroupController, "Built-in", "",                         app.Tab1Button, "AlwaysOn", struct('On', 'OpenFile_32Yellow.png',         'Off', 'OpenFile_32White.png'),         matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winPlayback",       app.Tab2Button, "AlwaysOn", struct('On', 'Playback_32Yellow.png',         'Off', 'Playback_32White.png'),         app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winDriveTest",      app.Tab3Button, "AlwaysOn", struct('On', 'DriveTestDensity_32Yellow.png', 'Off', 'DriveTestDensity_32White.png'), app.Tab2Button,                      3)
            addComponent(app.tabGroupController, "External", "auxApp.winSignalAnalysis", app.Tab4Button, "AlwaysOn", struct('On', 'exceptionList_32Yellow.png',    'Off', 'exceptionList_32White.png'),    app.Tab2Button,                      4)
            addComponent(app.tabGroupController, "External", "auxApp.winRFDataHub",      app.Tab5Button, "AlwaysOn", struct('On', 'mosaic_32Yellow.png',           'Off', 'mosaic_32White.png'),           app.Tab2Button,                      5)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",         app.Tab6Button, "AlwaysOn", struct('On', 'Settings_36Yellow.png',         'Off', 'Settings_36White.png'),         app.Tab2Button,                      6)

            % Salva na propriedade "UserData" as opções de ícone e o índice 
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.file_Tree.UserData                    = struct('previousSelectedFileIndex', [], 'previousSelectedFileThread', []);
            app.file_FilteringValue_ID.UserData       = struct('id', '', 'render', false);
            app.file_FilteringValue_Frequency.UserData= struct('id', '', 'render', false);
            app.file_FilteringTree.UserData           = struct('id', '', 'render', false);

            addStyle(app.file_Tree, uistyle('Interpreter', 'html'))
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            DataHubWarningLamp(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function DataHubWarningLamp(app)
            if isfolder(app.General.fileFolder.DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
        end

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
        function startup_Axes(app)
            % Axes creation:
            hParent     = tiledlayout(app.play_PlotPanel, 4, 1, "Padding", "compact", "TileSpacing", "compact");
            app.UIAxes1 = plot.axes.Creation(hParent, 'Cartesian', {'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2 1];
            
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'YScale', app.General.Plot.Axes.yOccupancyScale});
            app.UIAxes2.Layout.Tile = 3;
            
            app.UIAxes3 = plot.axes.Creation(hParent, 'Cartesian', {'Layer', 'top', 'Box', 'on', 'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes3.Layout.Tile = 4;            

            % Axes colormap:
            plot.axes.Colormap(app.UIAxes1, app.play_Persistance_Colormap.Value)
            plot.axes.Colormap(app.UIAxes3, app.play_Waterfall_Colormap.Value)

            % Axes colorbar:
            play_Waterfall_ColorbarValueChanged(app)

            % Axes fixed labels:
            ylabel(app.UIAxes1, 'Nível (dB)')
            ysecondarylabel(app.UIAxes1, Visible='on')

            ylabel(app.UIAxes2, 'Ocupação (%)')
            xlabel(app.UIAxes3, 'Frequência (MHz)')
            ylabel(app.UIAxes3, 'Instante')
            plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value)
            plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value, app.play_LayoutRatio)

            % Axes listeners:
            linkaxes([app.UIAxes1, app.UIAxes2, app.UIAxes3], 'x')
            addlistener(app.UIAxes1, 'XLim', 'PostSet', @app.plot_AxesLimitsChanged);
            addlistener(app.UIAxes1, 'YLim', 'PostSet', @app.plot_AxesLimitsChanged);

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation([app.UIAxes1, app.UIAxes2, app.UIAxes3], [dataTipInteraction, regionZoomInteraction])
        end

        %-----------------------------------------------------------------%
        function inputArguments = auxAppInputArguments(app, auxAppName)
            arguments
                app
                auxAppName char {mustBeMember(auxAppName, {'FILE', 'PLAYBACK', 'REPORT', 'MISC', 'DRIVETEST', 'SIGNALANALYSIS', 'RFDATAHUB', 'CONFIG'})}
            end
            
            [auxAppIsOpen, ...
             auxAppHandle] = checkStatusModule(app.tabGroupController, auxAppName);

            inputArguments = {app};

            switch auxAppName
                case 'DRIVETEST'
                    if auxAppIsOpen
                        [idxThread, idxEmission] = specDataIndex(auxAppHandle, 'EmissionShowed');
                    else
                        idxThread   = app.play_PlotPanel.UserData.NodeData;
                        idxEmission = [];
                        if ~isempty(app.play_FindPeaks_Tree.SelectedNodes)
                            idxEmission = app.play_FindPeaks_Tree.SelectedNodes.NodeData;
                        end
                    end

                    inputArguments = {app, idxThread, idxEmission};

                case 'SIGNALANALYSIS'                    
                    if auxAppIsOpen
                        selectedRow = auxAppHandle.UITable.Selection;                        
                    else
                        selectedRow = [];
                    end

                    inputArguments = {app, selectedRow};

                case 'RFDATAHUB'
                    if auxAppIsOpen
                        filterTable         = auxAppHandle.filterTable;
                        rfDataHubAnnotation = auxAppHandle.rfDataHubAnnotation;
                        inputArguments      = {app, filterTable, rfDataHubAnnotation};
                    end
            end
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
        % SISTEMA DE GESTÃO DA FISCALIZAÇÃO (eFiscaliza/SEI)
        %-----------------------------------------------------------------%                
        function status = report_checkEFiscalizaIssueId(app)
            status = (app.report_Issue.Value > 0) && (app.report_Issue.Value < inf);
        end

        %-----------------------------------------------------------------%
        function report_uploadInfoController(app, credentials, operation)
            communicationStatus = report_sendHTMLDocToSEIviaEFiscaliza(app, credentials, operation);
            if communicationStatus && strcmp(app.report_system.Value, 'eFiscaliza')
                report_sendJSONFileToSharepoint(app)
            end
        end

        %-------------------------------------------------------------------------%
        function communicationStatus = report_sendHTMLDocToSEIviaEFiscaliza(app, credentials, operation)
            app.progressDialog.Visible = 'visible';
            communicationStatus = false;

            try
                if ~isempty(credentials)
                    app.eFiscalizaObj = ws.eFiscaliza(credentials.login, credentials.password);
                end

                switch operation
                    case 'uploadDocument'
                        env = strsplit(app.report_system.Value);
                        if numel(env) < 2
                            env = 'PD';
                        else
                            env = env{2};
                        end

                        issue    = struct('type', 'ATIVIDADE DE INSPEÇÃO', 'id', app.report_Issue.Value);
                        unit     = app.report_Unit.Value;
                        fileName = app.projectData.generatedFiles.lastHTMLDocFullPath;
                        docSpec  = app.General.eFiscaliza;
                        docSpec.originId = docSpec.internal.originId;
                        docSpec.typeId   = docSpec.internal.typeId;

                        msg = run(app.eFiscalizaObj, env, operation, issue, unit, docSpec, fileName);
        
                    otherwise
                        error('Unexpected call')
                end
                
                if ~contains(msg, 'Documento cadastrado no SEI', 'IgnoreCase', true)
                    error(msg)
                end

                modalWindowIcon     = 'success';
                modalWindowMessage  = msg;
                communicationStatus = true;

            catch ME
                app.eFiscalizaObj   = [];
                
                modalWindowIcon     = 'error';
                modalWindowMessage  = ME.message;
            end

            ui.Dialog(app.UIFigure, modalWindowIcon, modalWindowMessage);
            app.progressDialog.Visible = 'hidden';
        end

        %------------------------------------------------------------------------%
        function report_sendJSONFileToSharepoint(app)
            JSONFile = app.projectData.generatedFiles.lastTableFullPath;            
            [status, msg] = copyfile(JSONFile, app.General.fileFolder.DataHub_POST, 'f');

            if ~status
                ui.Dialog(app.UIFigure, 'error', msg);
            end
        end
    end


    methods
        %-----------------------------------------------------------------%
        % APAGA COISAS...
        %-----------------------------------------------------------------%
        function DeleteAll(app)
            DeleteProject(app, 'appAnalise:MISC:RestartAnalysis')
            closeModule(app.tabGroupController, ["DRIVETEST", "SIGNALANALYSIS", "RFDATAHUB"], app.General)
            file_DataReaderError(app)
            file_specReadButtonVisibility(app)
        end

        %-----------------------------------------------------------------%
        function DeleteProject(app, operationType)
            Restart(app.projectData)

            app.report_ProjectName.Value       = app.projectData.file;
            app.report_Issue.Value             = app.projectData.issue;
            app.report_Unit.Value              = app.projectData.unit;
            app.report_ModelName.Value         = app.projectData.documentModel;
            app.report_ProjectWarnIcon.Visible = 0;

            switch operationType
                case 'appAnalise:MISC:RestartAnalysis'
                    % ...

                case 'appAnalise:REPORT:NewProject'
                    % Ajusta specData, além de reiniciar variáveis.
                    idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
                    update(app.specData, 'UserData:ReportFields', 'Delete', idxThreads)
        
                    % Apaga a árvore de fluxos a processar, além de retirar o ícone
                    % do relatório na árvore principal de fluxos.
                    report_TreeBuilding(app)

                    % Fecha o app auxiliar SIGNALANALYSIS porque ele demanda 
                    % ao menos um fluxo espectral a processar, o que não existe
                    % neste momento.
                    closeModule(app.tabGroupController, "SIGNALANALYSIS",  app.General)
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

            file_TreeBuilding(app)
        end

        %-----------------------------------------------------------------%
        function file_TreeBuilding(app)
            if ~isempty(app.file_Tree.Children)
                delete(app.file_Tree.Children)
                
                oldStyleIndex = find(app.file_Tree.StyleConfigurations.Target == "node");
                if ~isempty(oldStyleIndex)
                    removeStyle(app.file_Tree, oldStyleIndex)
                end

                app.file_Tree.UserData = struct('previousSelectedFileIndex', [], 'previousSelectedFileThread', []);
            end

            if ~isempty(app.metaData)
                file_FilterOptions(app)
                file_FilterCheck(app)

                filteredNodes = [];

                for ii = 1:numel(app.metaData)
                    [~, fileName, fileExt] = fileparts(app.metaData(ii).File);
                    
                    fileNode = uitreenode(app.file_Tree, 'Text',        [fileName fileExt],                                                     ...
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
                    addStyle(app.file_Tree, uistyle('FontColor', [.65,.65,.65]), 'node', filteredNodes)
                end

                app.file_Tree.SelectedNodes = app.file_Tree.Children(1);
                file_TreeSelectionChanged(app)

            else
                ui.TextView.update(app.file_Metadata, '');
                app.file_FilteringValue_Frequency.Items   = {};
                app.file_FilteringValue_ID.Items          = {};
                app.file_FilteringValue_Description.Value = '';           
            end

            file_specReadButtonVisibility(app)
        end

        %-----------------------------------------------------------------%
        function file_FilterOptions(app)
            % Se app.file_FilteringValue_ID e file_FilteringValue_Frequency 
            % ainda não foram renderizados, então não faz sentido passar por 
            % aqui...
            if ~app.file_FilteringValue_ID.UserData.render && ~app.file_FilteringValue_Frequency.UserData.render
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

            app.file_FilteringValue_ID.Items = unique(string(sort(IDList)), "rows", "stable");
            app.file_FilteringValue_Frequency.Items = unique(bandList.Band, "rows", "stable");
        end

        %-----------------------------------------------------------------%
        function file_FilterCheck(app)
            % Se app.file_FilteringTree ainda não foi renderizado, então
            % não faz sentido passar por aqui...
            if ~app.file_FilteringTree.UserData.render
                return
            end

            hFilter = allchild(app.file_FilteringTree);
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
            app.Tab5Button.Enable = 1;
            app.Tab6Button.Enable = 1;

            tabNavigatorButtonPushed(app, struct('Source', app.Tab1Button, 'PreviousValue', false)) 
        end

        %-----------------------------------------------------------------%
        function file_specReadButtonVisibility(app)
            if ~isempty(app.metaData)
                app.file_SpecReadButton.Enable = 1;
            else
                app.file_SpecReadButton.Enable = 0;
            end
        end


        %-----------------------------------------------------------------%
        % PLAYBACK >> ÁRVORE PRINCIPAL
        %-----------------------------------------------------------------%
        function play_TreeBuilding(app)
            if ~isempty(app.play_Tree.Children)
                delete(app.play_Tree.Children)
            end
            ui.TextView.update(app.play_Metadata, '');

            receiverRawList = {app.specData.Receiver};
            [receiverList, ~, receiverIndex] = unique(receiverRawList);

            for ii = 1:numel(receiverList)
                idx1 = find(receiverIndex == ii)';

                receiverNode = uitreenode(app.play_Tree, 'Text',     util.layoutTreeNodeText(receiverList{ii}, 'play_TreeBuilding'), ...
                                                         'NodeData', idx1,                                                           ...
                                                         'Icon',     util.layoutTreeNodeIcon(receiverList{ii}));
                                
                for jj = idx1
                    specNodeText = misc_nodeTreeText(app, jj);
                    if ismember(app.specData(jj).MetaData.DataType, class.Constants.occDataTypes)
                        specNodeText = [specNodeText ' (Ocupação)'];
                    end

                    specNode = uitreenode(receiverNode, 'Text', specNodeText, ...
                                                        'NodeData', jj,       ...
                                                        'Tag', 'BAND');

                    % TEMPO DE OBSERVAÇÃO
                    uitreenode(specNode, 'Text', sprintf('%s - %s', datestr(app.specData(jj).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), ...
                                                                    datestr(app.specData(jj).Data{1}(end), 'dd/mm/yyyy HH:MM:SS')), ...
                                         'NodeData', jj);
                        
                    % GPS
                    if ~app.specData(jj).GPS.Status
                        uitreenode(specNode, 'Text', '🔴 GPS', 'NodeData', jj);
                    else
                        gpsNode = uitreenode(specNode, 'Text', sprintf('%.6f, %.6f (%s)', app.specData(jj).GPS.Latitude,  ...
                                                                                          app.specData(jj).GPS.Longitude, ...
                                                                                          app.specData(jj).GPS.Location), ...
                                                       'NodeData', jj);
                        if app.specData(jj).GPS.Status == -1
                            gpsNode.Icon = 'modeManual_32.png';
                        end
                    end

                    % OCC
                    if ismember(app.specData(jj).MetaData.DataType, class.Constants.specDataTypes)
                        if ~isempty(app.specData(jj).UserData.occMethod.RelatedIndex)
                            occNode = uitreenode(specNode, 'Text', 'Fluxo(s) de ocupação', ...
                                                           'NodeData', jj);
                            
                            idx2 = app.specData(jj).UserData.occMethod.RelatedIndex;
                            for kk = idx2
                                occChildThreadNode = uitreenode(occNode, 'Text', sprintf('Threshold: %d %s (ID %d)', app.specData(kk).MetaData.Threshold,  ...
                                                                                                                     app.specData(kk).MetaData.LevelUnit,  ...
                                                                                                                     app.specData(kk).RelatedFiles.ID(1)), ...
                                                                         'NodeData', jj);

                                if app.specData(jj).UserData.occMethod.SelectedIndex == kk
                                    occChildThreadNode.Icon = 'modeSelected_32.png';
                                end                     
                            end

                            occChildPlaybackNode = uitreenode(occNode, 'Text', 'Ocupação a ser aferida', 'NodeData', jj);
                            if isempty(app.specData(jj).UserData.occMethod.SelectedIndex)
                                occChildPlaybackNode.Icon = 'modeSelected_32.png';
                            end
                        end
                    end
                end
            end

            arrayfun(@(x) expand(x), app.play_Tree.Children)
        end

        %-----------------------------------------------------------------%
        function play_changingTreeNodeStyleFromPlayback(app, idx)
            % specIndex..: índices dos fluxos de dados de espectro.
            % occIndex...: índices dos fluxos de dados de ocupação.
            % reportIndex: subconjunto de specIndex, representando os índices dos 
            %              fluxos de dados que serão analisados no modo "RELATÓRIO".

            removeStyle(app.play_Tree)

            nodeTreeList      = findobj(app.play_Tree, 'Tag', 'BAND');
            nodeDataTreeList  = [nodeTreeList.NodeData];
            [~, idxSelection] = ismember(idx, nodeDataTreeList);

            if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData)
                [~, idxPreviousSelection] = ismember(app.play_PlotPanel.UserData.NodeData, nodeDataTreeList);
                collapse(nodeTreeList(idxPreviousSelection))
            end

            if idxSelection
                addStyle(app.play_Tree, uistyle('FontColor', [0,0,0]), 'node', [findobj(nodeTreeList(idxSelection)); nodeTreeList(idxSelection).Parent])

                expand(nodeTreeList(idxSelection))
                scroll(app.play_Tree, nodeTreeList(idxSelection).Children(end))
            end
        end

        %-----------------------------------------------------------------%
        function play_changingTreeNodeStyleFromReport(app)
            nodeTreeList     = findobj(app.play_Tree, 'Tag', 'BAND');
            nodeDataTreeList = [nodeTreeList.NodeData];
            
            idxReportThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            [~, idxReport]   = ismember(idxReportThreads, nodeDataTreeList);

            set(nodeTreeList(idxReport),                        'Icon', 'Report_32.png')
            set(setdiff(nodeTreeList, nodeTreeList(idxReport)), 'Icon', '')
        end

        %-----------------------------------------------------------------%
        function play_TreeRebuilding(app, SelectedNodesTextList, hComp)
            arguments
                app
                SelectedNodesTextList
                hComp = []
            end

            % Evidencia células que tiveram os seus valores editados...
            if ~isempty(hComp)
                set(hComp, BackgroundColor='#bfbfbf')
                drawnow
            end
        
            % Desenha novamente a árvore, deixando selecionados os mesmos fluxos espectrais
            % que estavam selecionados quando da edição das suas informações de GPS.
            play_TreeBuilding(app)
            drawnow

            hTreeNodes     = findobj(app.play_Tree, '-not', 'Type', 'uitree');
            hTreeNodeText  = arrayfun(@(x) x.Text, hTreeNodes, "UniformOutput", false);
            hTreeNodeIndex = [];
            for ii = 1:numel(SelectedNodesTextList)
                hTreeNodeIndex = [hTreeNodeIndex, find(strcmp(hTreeNodeText, SelectedNodesTextList{ii}), 1)];
            end
            
            if isempty(hTreeNodeIndex)
                app.play_Tree.SelectedNodes = app.play_Tree.Children(1).Children(1);
            else
                app.play_Tree.SelectedNodes = hTreeNodes(hTreeNodeIndex);
            end
            report_TreeBuilding(app)
        
            % Retira evidência às supracitadas células.
            if ~isempty(hComp)
                set(hComp, BackgroundColor='white')
            end
        end


        %-----------------------------------------------------------------%
        % PLAYBACK >> ASPECTOS GERAIS >> OCUPAÇÃO
        %-----------------------------------------------------------------%
        function occParameters = play_OCCParameters(app)
            Method = app.play_OCC_Method.Value;

            switch Method
                case 'Linear fixo (COLETA)'
                    occParameters = RF.Occupancy.Parameters(Method, app.play_OCC_IntegrationTimeCaptured.Value, str2double(app.play_OCC_THRCaptured.Value));
                case 'Linear fixo'
                    occParameters = RF.Occupancy.Parameters(Method, str2double(app.play_OCC_IntegrationTime.Value), app.play_OCC_THR.Value);
                case {'Linear adaptativo', 'Envoltória do ruído'}
                    occParameters = RF.Occupancy.Parameters(Method, str2double(app.play_OCC_IntegrationTime.Value), app.play_OCC_Offset.Value, app.play_OCC_noiseFcn.Value, app.play_OCC_noiseTrashSamples.Value/100, app.play_OCC_noiseUsefulSamples.Value/100, app.play_OCC_ceilFactor.Value);            
            end
        end

        %-----------------------------------------------------------------%
        function occIndex = play_OCCIndex(app, idx, srcFcn)
            arguments
                app
                idx
                srcFcn char {mustBeMember(srcFcn, {'PLAYBACK/REPORT', 'PLAYBACK', 'REPORT'})}
            end

            switch srcFcn
                case 'PLAYBACK/REPORT'
                    if isempty(app.specData(idx).UserData.occCache)
                        occParameters = play_OCCParameters(app);
                    else
                        occParameters = app.specData(idx).UserData.reportAlgorithms.Occupancy;
                    end
                    play_OCCLayoutStartup(app, idx)

                case 'PLAYBACK'
                    occParameters = play_OCCParameters(app);

                case 'REPORT'
                    occParameters = app.specData(idx).UserData.reportAlgorithms.Occupancy;
            end
            
            occIndex = find(cellfun(@(x) isequal(x, occParameters), {app.specData(idx).UserData.occCache.Info}));
            
            if isempty(occIndex)
                occIndex = numel(app.specData(idx).UserData.occCache)+1;
                occTHR   = RF.Occupancy.Threshold(occParameters.Method, occParameters, app.specData(idx), app.play_OCC_Orientation.Value);

                switch occParameters.Method
                    case 'Linear fixo (COLETA)'
                        occData = app.specData(app.specData(idx).UserData.occMethod.SelectedIndex).Data;

                    otherwise
                        update(app.specData(idx), 'UserData:OccupancyFields', 'SelectedIndex:Refresh')
                        occData = RF.Occupancy.run(app.specData(idx).Data{1}, app.specData(idx).Data{2}, occParameters.Method, occTHR, occParameters.IntegrationTime);
                end

                update(app.specData(idx), 'UserData:OccupancyFields', 'Cache:Add', occIndex, occParameters, occTHR, occData)
            end

            update(app.specData(idx), 'UserData:OccupancyFields', 'CacheIndex:Edit', occIndex)
        end

        %-----------------------------------------------------------------%
        function selectedTreeNode = play_OCCSelectedTreeNode(app, idx)
            selectedTreeNode = [];
            for ii = 1:numel(app.play_Tree.Children)
                for jj = 1:numel(app.play_Tree.Children(ii).Children)
                    if app.play_Tree.Children(ii).Children(jj).NodeData == idx
                        selectedTreeNode = app.play_Tree.Children(ii).Children(jj);
                        break
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function play_OCCSelectedTreeNodeIconUpdate(app, idx1)

            selectedTreeNode = play_OCCSelectedTreeNode(app, idx1);

            switch app.play_OCC_Method.Value
                case 'Linear fixo (COLETA)'
                    idx2 = find(strcmp(app.play_OCC_THRCaptured.Items, app.play_OCC_THRCaptured.Value), 1);
                    if isempty(app.specData(idx1).UserData.occMethod.SelectedIndex) || (app.specData(idx1).UserData.occMethod.SelectedIndex ~= app.specData(idx1).UserData.occMethod.RelatedIndex(idx2))
                        update(app.specData(idx1), 'UserData:OccupancyFields', 'SelectedIndex:Edit', app.specData(idx1).UserData.occMethod.RelatedIndex(idx2))
                    end                    

                otherwise
                    if ~isempty(app.specData(idx1).UserData.occMethod.RelatedIndex)
                        update(app.specData(idx1), 'UserData:OccupancyFields', 'SelectedIndex:Refresh')
                        idx2 = numel(selectedTreeNode.Children(end).Children);
                    end
            end
   
            if exist('idx2', 'var')
                set(selectedTreeNode.Children(end).Children, Icon='')
                selectedTreeNode.Children(end).Children(idx2).Icon = 'modeSelected_32.png';
            end
        end

        %-----------------------------------------------------------------%
        function play_OCCNewPlot(app)
            if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData)
                idx = app.play_PlotPanel.UserData.NodeData;
    
                % Layout
                play_OCCSelectedTreeNodeIconUpdate(app, idx)
                if strcmp(app.play_OCC_Method.Value, 'Linear fixo (COLETA)')
                    idxOCC = app.specData(idx).UserData.occMethod.SelectedIndex;
    
                    app.play_OCC_THRCaptured.Value = num2str(app.specData(idxOCC).MetaData.Threshold);
                    app.play_OCC_IntegrationTimeCaptured.Value = mean(app.specData(idxOCC).RelatedFiles.RevisitTime)/60;
                end
                play_OCCLayoutVisibility(app, app.bandObj.LevelUnit)
                
                % Ao trocar qualquer um dos parâmetros relacionados aos métodos
                % de ocupação embarcados no appAnalise, afere-se, novamente, a
                % ocupação por bin. Isso, contudo, somente ocorre se estiver
                % habilitado o botão de ocupação, deixando visível o resultado
                % no app.axes2.
    
                % Ao inserir um fluxo de espectro para compor o relatório, será
                % definido um método de aferição de ocupação, caso ainda não
                % feita nenhuma simulação. Neste caso, a alteração dos parâmetros 
                % também irão refletir no algoritmo que será aplicado para fins
                % de geração do relatório.
    
                if app.axesTool_Occupancy.UserData.Value
                    % Aferição da ocupação (armazenada no campo "occCache" da 
                    % propriedade "UserData" de app.specData).
                    occIndex = play_OCCIndex(app, idx, 'PLAYBACK');
    
                    % Avalia se o fluxo que está sendo alterado foi incluído no
                    % modo relatório e este é exatamente o fluxo selecionado.
                    if app.specData(idx).UserData.reportFlag
                        update(app.specData(idx), 'UserData:ReportFields', 'ReportOCC:Edit', app.specData(idx).UserData.occCache(occIndex).Info)
    
                        idxOCC = [];
                        if ~isempty(app.play_Tree.SelectedNodes)
                            idxOCC = unique([app.play_Tree.SelectedNodes.NodeData]);
                        end
        
                        report_Algorithms(app, idxOCC)
                    end
        
                    % Plot                    
                    plot.old_OCC(app, idx, 'Creation', occIndex)
                end
            end
        end

        %-----------------------------------------------------------------%
        function play_OCCLayoutStartup(app, idx)        
            % Ajuste dos itens de app.play_OCC_Method, o qual depende da existência
            % de fluxos de ocupação relacionados aos fluxos de espectro. Lembrando
            % que atualmente os fluxos de ocupação são aqueles gerados pelo Logger.
            if isempty(app.specData(idx).UserData.occMethod.RelatedIndex)
                app.play_OCC_Method.Items      = {'Linear fixo', 'Linear adaptativo', 'Envoltória do ruído'};
                app.play_OCC_THRCaptured.Items = {};        
            else
                app.play_OCC_Method.Items      = {'Linear fixo (COLETA)', 'Linear fixo', 'Linear adaptativo', 'Envoltória do ruído'};
                app.play_OCC_THRCaptured.Items = arrayfun(@(x) num2str(x.MetaData.Threshold), app.specData(app.specData(idx).UserData.occMethod.RelatedIndex), 'UniformOutput', false);
            end        
            
            % Caso não esteja habilitado o botão de ocupação, então o painel de
            % ocupação é desabilitado. Se o fluxo de espectro possui habilitado a 
            % customização do playback, então os campos de todos os principais painéis 
            % (Persistência, Ocupação e Waterfall) serão atualizados em 
            % "layoutFcn.customPlayback".
            % Caso essa funcionalidade não tenha sido habilitada, é necessária
            % atualizadar os valores do painel de Ocupação.
            if app.axesTool_Occupancy.Enable
                play_OCCLayoutUpdate(app, idx)
                play_OCCLayoutVisibility(app, app.specData(idx).MetaData.LevelUnit)        
            else
                hComponents = findobj(app.play_OCCGrid, '-not', {'Type', 'uilabel', '-or', 'Type', 'uigrid', '-or', 'Type', 'uipanel'});
                set(hComponents, Enable=0)
            end
        end
        
        %-----------------------------------------------------------------%
        function play_OCCLayoutUpdate(app, idx)        
            if isempty(app.specData(idx).UserData.occMethod.CacheIndex)
                SelectedIndex = app.specData(idx).UserData.occMethod.SelectedIndex;
                
                if ~isempty(SelectedIndex)
                    app.play_OCC_Method.Value                  = 'Linear fixo (COLETA)';
                    app.play_OCC_IntegrationTimeCaptured.Value = mean(app.specData(SelectedIndex).RelatedFiles.RevisitTime)/60;
                    app.play_OCC_THRCaptured.Value             = num2str(app.specData(SelectedIndex).MetaData.Threshold);
                end        
            else
                occIndex = app.specData(idx).UserData.occMethod.CacheIndex;
                occInfo  = app.specData(idx).UserData.occCache(occIndex).Info;
            
                app.play_OCC_Method.Value = occInfo.Method;
            
                switch occInfo.Method
                    case 'Linear fixo (COLETA)'
                        app.play_OCC_IntegrationTimeCaptured.Value = occInfo.IntegrationTimeCaptured;
                        app.play_OCC_THRCaptured.Value             = num2str(occInfo.THRCaptured);
            
                    case 'Linear fixo'
                        app.play_OCC_IntegrationTime.Value         = num2str(occInfo.IntegrationTime);
                        app.play_OCC_THR.Value                     = occInfo.THR;
            
                    otherwise % 'Linear adaptativo' | 'Envoltória do ruído'            
                        app.play_OCC_IntegrationTime.Value         = num2str(occInfo.IntegrationTime);
                        app.play_OCC_Offset.Value                  = occInfo.Offset;
                        app.play_OCC_noiseFcn.Value                = occInfo.noiseFcn;
                        app.play_OCC_noiseTrashSamples.Value       = 100 * occInfo.noiseTrashSamples;
                        app.play_OCC_noiseUsefulSamples.Value      = 100 * occInfo.noiseUsefulSamples;
            
                        if strcmp(occInfo.Method, 'Envoltória do ruído')
                            app.play_OCC_ceilFactor.Value          = occInfo.ceilFactor;
                        end
                end
            end
        end

        %-----------------------------------------------------------------%
        function play_OCCLayoutVisibility(app, LevelUnit)
            hComponents = findobj(app.play_OCCGrid, '-not', {'Type', 'uilabel', '-or', 'Type', 'uigrid', '-or', 'Type', 'uipanel'});
            set(hComponents, Enable=1)
        
            switch app.play_OCC_Method.Value
                case 'Linear fixo (COLETA)'
                    set(app.play_OCC_IntegrationTime,         Visible=0, Enable=0)
                    set(app.play_OCC_IntegrationTimeCaptured, Visible=1)
        
                    set(app.play_OCC_THRLabel,        Visible=1)
                    set(app.play_OCC_THR,             Visible=0)
                    set(app.play_OCC_THRCaptured,     Visible=1)
        
                    set(app.play_OCC_OffsetLabel,     Visible=0)
                    set(app.play_OCC_Offset,          Visible=0, Enable=0)
                    
                    set(app.play_OCC_ceilFactorLabel, Visible=0)
                    set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)
        
                    set(app.play_OCC_noiseLabel,      Visible=0)
                    set(app.play_OCC_noisePanel,      Visible=0)
                    set(findobj(app.play_OCC_noiseGrid.Children, '-not', 'Type', 'uilabel'), Enable=0)
        
                    play_OCCLayoutVisibilityUpdate(app, LevelUnit)
        
                case 'Linear fixo'
                    set(app.play_OCC_IntegrationTime,         Visible=1)
                    set(app.play_OCC_IntegrationTimeCaptured, Visible=0, Enable=0)
        
                    set(app.play_OCC_THRLabel,        Visible=1)
                    set(app.play_OCC_THR,             Visible=1)
                    set(app.play_OCC_THRCaptured,     Visible=0)
        
                    set(app.play_OCC_OffsetLabel,     Visible=0)
                    set(app.play_OCC_Offset,          Visible=0, Enable=0)
                    
                    set(app.play_OCC_ceilFactorLabel, Visible=0)
                    set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)
        
                    set(app.play_OCC_noiseLabel,      Visible=0)
                    set(app.play_OCC_noisePanel,      Visible=0)
                    set(findobj(app.play_OCC_noiseGrid.Children, '-not', 'Type', 'uilabel'), Enable=0)
        
                    play_OCCLayoutVisibilityUpdate(app, LevelUnit)
        
                otherwise % {'Linear adaptativo', 'Envoltória do ruído adaptativo'}
                    set(app.play_OCC_IntegrationTime,         Visible=1)
                    set(app.play_OCC_IntegrationTimeCaptured, Visible=0, Enable=0)
        
                    set(app.play_OCC_THRLabel,    Visible=0)
                    set(app.play_OCC_THR,         Visible=0, Enable=0)
                    set(app.play_OCC_THRCaptured, Visible=0, Enable=0)
                    
                    set(app.play_OCC_OffsetLabel, Visible=1)
                    set(app.play_OCC_Offset,      Visible=1)
        
                    set(app.play_OCC_noiseLabel,  Visible=1)
                    set(app.play_OCC_noisePanel,  Visible=1)
        
                    switch app.play_OCC_Method.Value
                        case'Linear adaptativo'
                            set(app.play_OCC_ceilFactorLabel, Visible=0)
                            set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)
        
                        case 'Envoltória do ruído'
                            set(app.play_OCC_ceilFactorLabel, Visible=1)
                            set(app.play_OCC_ceilFactor,      Visible=1)
                    end
            end
        end        
        
        %-------------------------------------------------------------------------%
        function play_OCCLayoutVisibilityUpdate(app, LevelUnit)        
            app.play_OCC_THRLabel.Text = sprintf('Valor (%s):', LevelUnit);
        
            switch LevelUnit
                case 'dBm'
                    if app.play_OCC_THR.Value > 0                            
                        app.play_OCC_THR.Value = -80;
                    end        
                case 'dBµV'
                    if app.play_OCC_THR.Value < 0
                        app.play_OCC_THR.Value = 27;
                    end
                case 'dBµV/m'
                    if app.play_OCC_THR.Value < 0
                        app.play_OCC_THR.Value = 40;
                    end
            end
        end


        %-----------------------------------------------------------------%
        % % PLAYBACK >> CANAIS
        %-----------------------------------------------------------------%
        function play_Channel_AddChannel(app, channel2Add, typeOfChannel, idxThreads)
            idx = app.play_PlotPanel.UserData.NodeData;

            % Valida o novo registro, incluindo-o depois, caso não retorne 
            % erro na validação.
            for ii = 1:numel(channel2Add)
                channelCell2Add = struct2cell(channel2Add(ii));
                checkIfNewChannelIsValid(app.channelObj, channelCell2Add{:})                    
            end
            addChannel(app.channelObj, typeOfChannel, app.specData, idxThreads, channel2Add)

            % Por fim, reescreve a árvore...
            play_Channel_TreeBuilding(app, idx, 'play_Channel_addChannel')
        end

        %-----------------------------------------------------------------%
        function play_Channel_TreeBuilding(app, idx, srcFcn)
            if ~isempty(app.play_Channel_Tree.Children)
                delete(app.play_Channel_Tree.Children)                
            end

            % Canais incluídos automaticamente, os quais constam em "ChannelLib.json".
            channelLibIndex = app.specData(idx).UserData.channelLibIndex;
            if ~isempty(channelLibIndex)
                for ii = channelLibIndex'
                    uitreenode(app.play_Channel_Tree, 'Text', sprintf('%.3f - %.3f MHz (%s)',             ...
                                                                      app.channelObj.Channel(ii).Band(1), ...
                                                                      app.channelObj.Channel(ii).Band(2), ...
                                                                      app.channelObj.Channel(ii).Name),   ...
                                                      'NodeData', struct('src', 'channelLib', 'idx', ii), ...
                                                      'ContextMenu', app.play_Channel_ContextMenu);
                end
            end

            % Canais incluídos manualmente pelo usuário.
            channelManual = app.specData(idx).UserData.channelManual;
            if ~isempty(channelManual)
                manualNodes   = [];
                for kk = 1:numel(channelManual)
                    if channelManual(kk).FirstChannel == channelManual(kk).LastChannel
                        treeText = sprintf('%.3f MHz (%s)', channelManual(kk).FirstChannel, channelManual(kk).Name);
                    else
                        treeText = sprintf('%.3f - %.3f MHz (%s)', channelManual(kk).FirstChannel, channelManual(kk).LastChannel, channelManual(kk).Name);
                    end
    
                    manualNodes = [manualNodes, uitreenode(app.play_Channel_Tree, 'Text', treeText,                               ...
                                                                                  'NodeData', struct('src', 'manual', 'idx', kk), ...
                                                                                  'ContextMenu', app.play_Channel_ContextMenu)];
                end            
                addStyle(app.play_Channel_Tree, uistyle('FontColor', '#c94756'), 'node', manualNodes)
            end

            % Seleciona o primeiro fluxo e chama TreeSelectionChanged, caso
            % aplicável.
            if ~isempty(app.play_Channel_Tree.Children)
                app.play_Channel_Tree.SelectedNodes = app.play_Channel_Tree.Children(1);
            end
            play_Channel_TreeSelectionChanged(app, struct('Source', srcFcn))
        end

        %-----------------------------------------------------------------%
        function play_ChannelListSample(app, FreqList)
            nFreqList = numel(FreqList);

            if nFreqList == 0
                app.play_Channel_Sample.Text = '';
            elseif nFreqList <= 4
                app.play_Channel_Sample.Text = strjoin(string(FreqList) + " MHz", ', ');
            else
                app.play_Channel_Sample.Text = strjoin(string(FreqList(1:2)) + " MHz", ', ') + " ... " + strjoin(string(FreqList(end-1:end)) + " MHz", ', ');
            end
        end

        %-----------------------------------------------------------------%
        function plot_updateSelectedEmission(app, idxThread, idxEmission, updatePlotFlag)
            % Analisa se as emissões incluídas/editadas pertencem às subfaixas 
            % sob análise. 
            %
            % Trigger:
            % (a) Inclusão automática de emissões. 
            %     Callback "play_FindPeaks_addEmission(app, event)"
            % (b) Edição manual da frequência central da emissão selecionada.
            %     Callback "play_FindPeaks_editEmission(app, event)"
            % (c) Ajuste do ROI, diretamente no eixo.
            %     Função auxiliar à "plot.draw2D.ClearWrite_old" ("mkrLineROI")
            % (d) Inclusão automática de emissões na geração do relatório.
            %     Função externa report.ReportGenerator_Peaks(...)
            arguments
                app
                idxThread
                idxEmission
                updatePlotFlag = true
            end

            if updatePlotFlag
                idxEmission = find(app.specData(idxThread).UserData.Emissions.idxFrequency == idxEmission(1), 1);
                if isempty(idxEmission)
                    if ~isempty(app.specData(idxThread).UserData.Emissions)
                        idxEmission = 1;
                    else
                        delete(app.hSelectedEmission)
                        app.hSelectedEmission = [];
                    end
                end
                plot.draw2D.ClearWrite_old(app, idxThread, 'PeakValueChanged', idxEmission)
            end
        end

        %-----------------------------------------------------------------%
        function play_BandLimits_Layout(app, idx)

            if app.play_BandLimits_Status.Value
                update(app.specData(idx), 'UserData:BandLimits', 'Status:Edit', true)
                
                set(app.play_BandLimits_Grid.Children, Enable=1)
                app.play_BandLimits_add.Enable  = 1;
                app.play_BandLimits_Tree.Enable = 1;

            else
                update(app.specData(idx), 'UserData:BandLimits', 'Status:Edit', false)

                set(findobj(app.play_BandLimits_Grid, 'Type', 'uinumericeditfield'), Enable=0)
                app.play_BandLimits_add.Enable  = 0;
                app.play_BandLimits_Tree.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function play_BandLimits_TreeBuilding(app, idx)
            
            if ~isempty(app.play_BandLimits_Tree.Children)
                delete(app.play_BandLimits_Tree.Children)
            end

            bandLimitsTable = app.specData(idx).UserData.bandLimitsTable;
            for ii = 1:height(bandLimitsTable)
                uitreenode(app.play_BandLimits_Tree, 'Text', sprintf('%.3f - %.3f MHz', bandLimitsTable.FreqStart(ii), bandLimitsTable.FreqStop(ii)), ...
                                                     'NodeData', ii, 'ContextMenu', app.play_BandLimits_ContextMenu);
            end
        end


        %-----------------------------------------------------------------%
        % PLAYBACK >> EMISSÕES
        %-----------------------------------------------------------------%
        function play_EmissionList(app, idx, selectedEmission)
            if ~isempty(app.play_FindPeaks_Tree.Children)
                delete(app.play_FindPeaks_Tree.Children)
            end

            if ~isempty(app.specData(idx).UserData.Emissions)
                emissionsTable = app.specData(idx).UserData.Emissions;

                for ii = 1:height(emissionsTable)
                    if emissionsTable.isTruncated(ii)
                        Icon = 'signalTruncated_32.png';
                    else
                        Icon = 'signalUntruncated_32.png';
                    end

                    if isempty(emissionsTable.auxAppData(ii).DriveTest)
                        DriveTestFlag = '';
                    else
                        DriveTestFlag = ' (DT)';
                    end

                    uitreenode(app.play_FindPeaks_Tree, 'Text', sprintf('%d: %.3f MHz ⌂ %.1f kHz%s', ii, emissionsTable.Frequency(ii), emissionsTable.BW_kHz(ii), DriveTestFlag), ...
                                                        'NodeData', ii, 'Icon', Icon, 'ContextMenu', app.play_FindPeaks_ContextMenu);
                end

                app.play_FindPeaks_Tree.SelectedNodes = app.play_FindPeaks_Tree.Children(selectedEmission);
            end
            play_FindPeaks_TreeSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function play_AddEmission2List(app, idxThread, idxFreqCenter, FreqCenter, BW_kHz, Algorithm, Description)
            arguments
                app
                idxThread
                idxFreqCenter
                FreqCenter
                BW_kHz
                Algorithm
                Description = [];
            end
            update(app.specData(idxThread), 'UserData:Emissions', 'Add', idxFreqCenter, FreqCenter, BW_kHz, Algorithm, Description, app.channelObj)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            plot_updateSelectedEmission(app, idxThread, idxFreqCenter, idx == idxThread)            
            play_UpdateAuxiliarApps(app)
        end

        %-----------------------------------------------------------------%
        function play_UpdateAuxiliarApps(app, auxAppToUpdate)
            arguments
                app
                auxAppToUpdate {mustBeMember(auxAppToUpdate, {'All', 'SIGNALANALYSIS', 'DRIVETEST'})} = 'All'
            end
            
            if ismember(auxAppToUpdate, {'All', 'SIGNALANALYSIS'})
                hSignalAnalysis = getAppHandle(app.tabGroupController, 'SIGNALANALYSIS');
                if ~isempty(hSignalAnalysis) && isvalid(hSignalAnalysis)
                    ipcSecundaryMatlabCallsHandler(hSignalAnalysis, app)
                end
            end

            if ismember(auxAppToUpdate, {'All', 'DRIVETEST'})
                hDriveTest = getAppHandle(app.tabGroupController, 'DRIVETEST');
                if ~isempty(hDriveTest) && isvalid(hDriveTest)
                    ipcSecundaryMatlabCallsHandler(hDriveTest, app)
                end
            end
        end

        
        %-----------------------------------------------------------------%
        % ## LAYOUT ##
        %-----------------------------------------------------------------%
        function play_Layout_PersistancePanel(app)
            % Lista de componentes passíveis de mudança no seus status, a
            % depender do plot Persistance.
            hComponents = [app.play_Persistance_cLim1, ...
                           app.play_Persistance_cLim2, ...
                           app.play_Persistance_cLim_Mode];

            if ~isempty(app.hPersistanceObj)
                set(hComponents, 'Enable', 1)

                if ~strcmp(app.play_Persistance_WindowSize.Value, 'full')
                    app.play_Persistance_cLim_Mode.Enable = 0;
                    set(app.play_Persistance_cLim_Grid2.Children, 'Enable', 0)
                end

                app.restoreView(1).cLim = app.UIAxes1.CLim;
                app.play_Persistance_cLim1.Value = app.UIAxes1.CLim(1);
                app.play_Persistance_cLim2.Value = app.UIAxes1.CLim(2);

            else
                set(hComponents, 'Enable', 0)
            end
        end

        %-----------------------------------------------------------------%
        function play_Layout_WaterfallPanel(app)
            % Lista de componentes passíveis de mudança no seus status, a
            % depender do plot Waterfall.
            hComponents = [app.play_Waterfall_MeshStyle,  ...
                           app.play_Waterfall_Decimation, ...
                           app.play_Waterfall_Colorbar,   ...
                           app.play_Waterfall_cLim1,      ...                           
                           app.play_Waterfall_cLim2,      ...
                           app.play_Waterfall_cLim_Mode];

            if app.axesTool_Waterfall.UserData.Value
                switch app.play_Waterfall_Fcn.Value
                    case 'image'
                        hComponents(1).Enable = 0;
                        set(hComponents(2:end), 'Enable', 1)
                    case 'mesh'
                        set(hComponents, 'Enable', 1)
                end    

                app.restoreView(3).yLim = app.UIAxes3.YLim;
                app.restoreView(3).cLim = app.UIAxes3.CLim;

                app.play_Waterfall_cLim1.Value = double(app.UIAxes3.CLim(1));
                app.play_Waterfall_cLim2.Value = double(app.UIAxes3.CLim(2));

            else
                set(hComponents, 'Enable', 0)
            end
        end


        %-----------------------------------------------------------------%
        % ## PLOT ##
        %-----------------------------------------------------------------%
        function prePlot_restartProperties(app, axesLimits)
            cla([app.UIAxes1, app.UIAxes2, app.UIAxes3])

            app.UIAxes1.UserData.CLimMode = 'auto';
            app.UIAxes3.UserData.CLimMode = 'auto';

            app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yLevelLim, 'cLim', 'auto');
            app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', axesLimits.xLim, 'yLim', [0, 100],             'cLim', 'auto');
            app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yTimeLim,  'cLim', axesLimits.cLim);
        
            app.hClearWrite       = [];
            app.hMinHold          = [];
            app.hAverage          = [];
            app.hMaxHold          = [];
            app.hPersistanceObj   = [];
            app.hSelectedEmission = [];
            app.hEmissionMarkers  = [];
            app.hTHR              = [];
            app.hTHRLabel         = [];
            app.hWaterfall        = [];
            app.hWaterfallTime    = [];

            app.idxTime = 1;
            app.tool_TimestampSlider.Value = 0;
        end

        %-----------------------------------------------------------------%
        function prePlot_checkNSweepsAndDataType(app, idx)
            if app.bandObj.nSweeps > 2                
                app.axesTool_Persistance.Enable = 1;
                app.axesTool_Waterfall.Enable   = 1;

                if ~ismember(app.specData(idx).MetaData.DataType, class.Constants.occDataTypes)
                    app.axesTool_Occupancy.Enable = 1;
                else
                    app.axesTool_Occupancy.Enable = 0;
                    app.axesTool_Occupancy.UserData.Value = false;
                    
                    plot.old_OCC(app, idx, 'Delete', [])                    % !! PONTO DE REVISÃO !!
                end
            else                
                app.axesTool_Persistance.Enable = 0;
                app.axesTool_Persistance.UserData.Value = false;

                app.axesTool_Waterfall.Enable   = 0;
                app.axesTool_Waterfall.UserData.Value = false;

                app.axesTool_Occupancy.Enable   = 0;
                app.axesTool_Occupancy.UserData.Value = false;

                plot.old_OCC(app, idx, 'Delete', [])                        % !! PONTO DE REVISÃO !!           
            end
        end

        %-----------------------------------------------------------------%
        function treeNode = prePlot_findSelectedNodeRoot(app, idx)
            hTreeNodes     = findobj(app.play_Tree, '-not', 'Type', 'uitree');
            hTreeNodeData  = arrayfun(@(x) x.NodeData, hTreeNodes, "UniformOutput", false);
            hTreeNodeIndex = find(cellfun(@(x) isequal(idx, x), hTreeNodeData))';
        
            for ii = hTreeNodeIndex
                generation = misc_findGenerationOfTreeNode(app, hTreeNodes(ii));
                if generation == 1
                    treeNode = hTreeNodes(ii);
                    break
                end
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_HTMLPanels(app, idxThread)
            ui.TextView.update(app.play_Metadata, util.HtmlTextGenerator.Thread(app.specData, idxThread));
            app.tool_TimestampLabel.Text = sprintf('1 de %d\n%s', app.bandObj.nSweeps, app.specData(idxThread).Data{1}(1));
            ysecondarylabel(app.UIAxes1, sprintf('%s\n%.3f - %.3f MHz\n', app.specData(idxThread).Receiver, app.bandObj.FreqStart, app.bandObj.FreqStop))
        end

        %-----------------------------------------------------------------%
        function prePlot_customPlayback(app, idx)
            % Em relação à customização do PLAYBACK,
            % (a) Até a v. 1.67, o appAnalise possibilitava a customização de onze parâmetros
            %     do PLAYBACK. Desde a v. 1.80, o app aumentou esse número para vinte
            %     (praticamente todos!). Além disso, os nomes dos parâmetros foram compactados, 
            %     o que demandou ajuste no leitor .MAT, mantendo a compatibilidade com os .MAT
            %     gerado em versões anteriores do app.
            
            % (b) A atualização do componente app.play_LayoutRatio deve ser posterior
            %     à atualização dos componentes app.play_Occupancy e app.play_Waterfall.
            
            % (c) A atualização dos limites dos eixos x e y é realizada automaticamente,
            %     seguindo os limites do eixos app.axes1.
            %     addlistener(app.axes1, 'XLim', 'PostSet', @app.plot_xLimitsUpdate);
            %     addlistener(app.axes1, 'YLim', 'PostSet', @app.plot_yLimitsUpdate);

            switch app.specData(idx).UserData.customPlayback.Type
                case 'auto'
                    app.play_Customization.Value = 0;

                case 'manual'
                    app.play_Customization.Value = 1;

                    iconDictionary = dictionary([true, false], [1, 2]);
                    if ~isequal(app.axesTool_MinHold.UserData, app.specData(idx).UserData.customPlayback.Parameters.Controls.MinHold)
                        app.axesTool_MinHold.UserData.Value   = app.specData(idx).UserData.customPlayback.Parameters.Controls.MinHold;
                        app.axesTool_MinHold.ImageSource      = app.axesTool_MinHold.UserData.ImageSource{iconDictionary(app.axesTool_MinHold.UserData.Value)};
                    end

                    if ~isequal(app.axesTool_Average.UserData, app.specData(idx).UserData.customPlayback.Parameters.Controls.Average)
                        app.axesTool_Average.UserData.Value   = app.specData(idx).UserData.customPlayback.Parameters.Controls.Average;
                        app.axesTool_Average.ImageSource      = app.axesTool_Average.UserData.ImageSource{iconDictionary(app.axesTool_Average.UserData.Value)};
                    end

                    if ~isequal(app.axesTool_MaxHold.UserData, app.specData(idx).UserData.customPlayback.Parameters.Controls.MaxHold)
                        app.axesTool_MaxHold.UserData.Value   = app.specData(idx).UserData.customPlayback.Parameters.Controls.MaxHold;
                        app.axesTool_MaxHold.ImageSource      = app.axesTool_MaxHold.UserData.ImageSource{iconDictionary(app.axesTool_MaxHold.UserData.Value)};
                    end

                    app.axesTool_Persistance.UserData.Value   = app.specData(idx).UserData.customPlayback.Parameters.Controls.Persistance;
                    app.axesTool_Occupancy.UserData.Value     = app.specData(idx).UserData.customPlayback.Parameters.Controls.Occupancy;
                    app.axesTool_Waterfall.UserData.Value     = app.specData(idx).UserData.customPlayback.Parameters.Controls.Waterfall;
        
                    app.play_LayoutRatio.Items                = {app.specData(idx).UserData.customPlayback.Parameters.Controls.LayoutRatio};
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value, app.play_LayoutRatio)
                    
                    app.play_Persistance_Interpolation.Value  = app.specData(idx).UserData.customPlayback.Parameters.Persistance.Interpolation;
                    app.play_Persistance_WindowSize.Value     = app.specData(idx).UserData.customPlayback.Parameters.Persistance.WindowSize;
                    app.play_Persistance_WindowSizeValue.Text = app.specData(idx).UserData.customPlayback.Parameters.Persistance.WindowSize;
                    app.play_Persistance_Transparency.Value   = app.specData(idx).UserData.customPlayback.Parameters.Persistance.Transparency;
                    app.play_Persistance_Colormap.Value       = app.specData(idx).UserData.customPlayback.Parameters.Persistance.Colormap;
        
                    if app.play_Persistance_WindowSize.Value == "full"
                        app.play_Persistance_cLim1.Value      = app.specData(idx).UserData.customPlayback.Parameters.Persistance.LevelLimits(1);
                        app.play_Persistance_cLim2.Value      = app.specData(idx).UserData.customPlayback.Parameters.Persistance.LevelLimits(2);
                    end

                    % A visibilidade e posição da Colobar não é tratada como 
                    % customização do playback... e por isso o componente
                    % específico não é atualizado com a informação presente
                    % em app.specData.
                    app.play_Waterfall_Fcn.Value              = app.specData(idx).UserData.customPlayback.Parameters.Waterfall.Fcn;
                    app.play_Waterfall_Decimation.Value       = app.specData(idx).UserData.customPlayback.Parameters.Waterfall.Decimation;
                    app.play_Waterfall_MeshStyle.Value        = app.specData(idx).UserData.customPlayback.Parameters.Waterfall.MeshStyle;            
                    app.play_Waterfall_Colormap.Value         = app.specData(idx).UserData.customPlayback.Parameters.Waterfall.Colormap;
                    app.play_Waterfall_cLim1.Value            = app.specData(idx).UserData.customPlayback.Parameters.Waterfall.LevelLimits(1);
                    app.play_Waterfall_cLim2.Value            = app.specData(idx).UserData.customPlayback.Parameters.Waterfall.LevelLimits(2);        
                    app.play_Waterfall_Timeline.Value         = app.specData(idx).UserData.customPlayback.Parameters.WaterfallTime.Visible;
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_updatingGeneralSettings(app)
            % app.General_I
            % (a) Persistance
            app.General_I.Plot.Persistance = struct('Interpolation', app.play_Persistance_Interpolation.Value, ...
                                                    'WindowSize',    app.play_Persistance_WindowSize.Value,    ...
                                                    'Transparency',  app.play_Persistance_Transparency.Value,  ...
                                                    'Colormap',      app.play_Persistance_Colormap.Value,      ...
                                                    'LevelLimits',  [app.play_Persistance_cLim1.Value, app.play_Persistance_cLim2.Value]);

            if app.axesTool_Persistance.UserData.Value && strcmp(app.UIAxes1.UserData.CLimMode, 'auto')
                app.General_I.Plot.Persistance.LevelLimits = [0, 1];
            end

            % (b) Waterfall
            app.General_I.Plot.Waterfall   = struct('Fcn',           app.play_Waterfall_Fcn.Value,        ...
                                                    'Decimation',    app.play_Waterfall_Decimation.Value, ...
                                                    'MeshStyle',     app.play_Waterfall_MeshStyle.Value,  ...
                                                    'Colormap',      app.play_Waterfall_Colormap.Value,   ...
                                                    'Colorbar',      app.play_Waterfall_Colorbar.Value,   ...
                                                    'LevelLimits',  [app.play_Waterfall_cLim1.Value, app.play_Waterfall_cLim2.Value]);

            if app.axesTool_Waterfall.UserData.Value && strcmp(app.UIAxes3.UserData.CLimMode, 'auto')
                app.General_I.Plot.Waterfall.LevelLimits = [0, 1];
            end

            % (c) WaterfallTime
            app.General_I.Plot.WaterfallTime.Visible = app.play_Waterfall_Timeline.Value;
            
            % app.General
            app.General.Plot.Persistance   = app.General_I.Plot.Persistance;
            app.General.Plot.Waterfall     = app.General_I.Plot.Waterfall;
            app.General.Plot.WaterfallTime = app.General_I.Plot.WaterfallTime;
        end

        %-----------------------------------------------------------------%
        function prePlot_updatingCustomProperties(app, idx)
            if app.play_Customization.Value
                % Aqui são atualizados todos os controles do customPlayback, 
                % exceto os DataTips, os quais são atualizados apenas quando
                % é selecionado outro fluxo espectral.

                if ~app.axesTool_Persistance.UserData.Value
                    app.play_Persistance_cLim1.Value = 0;
                    app.play_Persistance_cLim2.Value = 1;
                end

                if ~app.axesTool_Waterfall.UserData.Value
                    app.play_Waterfall_cLim1.Value   = 0;
                    app.play_Waterfall_cLim2.Value   = 1;
                end

                customPlayback = struct('Controls',      struct('MinHold',          app.axesTool_MinHold.UserData.Value,                                  ...
                                                                'Average',          app.axesTool_Average.UserData.Value,                                  ...
                                                                'MaxHold',          app.axesTool_MaxHold.UserData.Value,                                  ...
                                                                'Persistance',      app.axesTool_Persistance.UserData.Value,                              ...
                                                                'Occupancy',        app.axesTool_Occupancy.UserData.Value,                                ...
                                                                'Waterfall',        app.axesTool_Waterfall.UserData.Value,                                ...
                                                                'LayoutRatio',      app.play_LayoutRatio.Value,                                           ...
                                                                'FrequencyLimits', [app.play_Limits_xLim1.Value, app.play_Limits_xLim2.Value],            ...
                                                                'LevelLimits',     [app.play_Limits_yLim1.Value, app.play_Limits_yLim2.Value]),           ...
                                        'Persistance',   struct('Interpolation',    app.play_Persistance_Interpolation.Value,                             ...
                                                                'WindowSize',       app.play_Persistance_WindowSize.Value,                                ...
                                                                'Transparency',     app.play_Persistance_Transparency.Value,                              ...
                                                                'Colormap',         app.play_Persistance_Colormap.Value,                                  ...
                                                                'LevelLimits',     [app.play_Persistance_cLim1.Value, app.play_Persistance_cLim2.Value]), ...
                                        'Waterfall',     struct('Fcn',              app.play_Waterfall_Fcn.Value,                                         ...
                                                                'Decimation',       app.play_Waterfall_Decimation.Value,                                  ...
                                                                'MeshStyle',        app.play_Waterfall_MeshStyle.Value,                                   ...
                                                                'Colormap',         app.play_Waterfall_Colormap.Value,                                    ...
                                                                'LevelLimits',     [app.play_Waterfall_cLim1.Value, app.play_Waterfall_cLim2.Value]),     ...
                                        'WaterfallTime', struct('Visible',          app.play_Waterfall_Timeline.Value,                                    ...
                                                                'ZData',           [1000, 1000]));

                update(app.specData(idx), 'UserData:CustomPlayback', 'Edit', customPlayback)
            else
                update(app.specData(idx), 'UserData:CustomPlayback', 'Refresh')
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_updatingRestoreView(app, idx)
            axesLimits = Limits(app.bandObj, idx);

            app.restoreView(1).xLim = axesLimits.xLim;
            app.restoreView(2).xLim = axesLimits.xLim;
            app.restoreView(3).xLim = axesLimits.xLim;

            app.restoreView(1).yLim = axesLimits.yLevelLim;
            app.restoreView(2).yLim = axesLimits.yLevelLim;
            app.restoreView(3).yLim = axesLimits.yLevelLim;

            app.restoreView(3).cLim = axesLimits.cLim;
        end

        %-----------------------------------------------------------------%
        function plot_startupFcn(app, idx)        
            % !! ESSENCIAL !!
            % O handle do elemento selecionado na árvore de fluxos, para o 
            % qual será plotado os gráficos, fica armazenado na propriedade 
            % "UserData", do componente app.play_PlotPanel.
            app.play_PlotPanel.UserData = prePlot_findSelectedNodeRoot(app, idx);

            % O objeto app.bandObj armazena propriedades de app.specData(idx) 
            % que simplifica o processo do plot, em especial na passagem de 
            % argumentos para as funções plot.draw2D, plot.Waterfall e plot.Persistance.
            axesLimits = update(app.bandObj, idx);

            prePlot_restartProperties(app, axesLimits)
            prePlot_checkNSweepsAndDataType(app, idx)

            % Painel "PLAYBACK > HTMLPANEL"
            prePlot_HTMLPanels(app, idx)

            % Painel "PLAYBACK > PLAYBACK"
            % Ajuste dos paineis de controle "Persistance", "Occupancy" e
            % "Waterfall" (inserindo valores do customPlayback, caso existentes).
            prePlot_customPlayback(app, idx)
            prePlot_updatingGeneralSettings(app)
            play_OCCLayoutStartup(app, idx)                                 % !! PONTO DE REVISÃO !!

            % Painel "PLAYBACK > CANAIS >> INCLUSÃO DE CANAIS"
            play_Channel_TreeBuilding(app, idx, 'plot_startupFcn')

            % Painel "PLAYBACK > CANAIS >> SUBFAIXAS"
            FreqStart = app.bandObj.FreqStart;
            FreqStop  = app.bandObj.FreqStop;

            app.play_BandLimits_Status.Value = app.specData(idx).UserData.bandLimitsStatus;
        
            app.play_BandLimits_xLim1.Limits = [-Inf, Inf];
            app.play_BandLimits_xLim2.Limits = [-Inf, Inf];
            set(app.play_BandLimits_xLim1, 'Value', FreqStart, 'Limits', [FreqStart, FreqStop])
            set(app.play_BandLimits_xLim2, 'Value', FreqStop,  'Limits', [FreqStart, FreqStop])
        
            play_BandLimits_Layout(app, idx)
            play_BandLimits_TreeBuilding(app, idx)

            % Painel "PLAYBACK >> EMISSÕES"
            play_EmissionList(app, idx, 1)
        end

        %-----------------------------------------------------------------%
        function plot_Draw(app, idx)
            % No processo de inicialização do PLOT, que ocorre toda vez que é
            % alterado o fluxo espectral selecionado, na árvore principal do
            % appAnalise, os eixos são limpos e os handles dos principais
            % componentes do plot são apagados. app.hClearWrite vazio significa 
            % que deverá ser desenhado um novo PLOT. Por outro lado, caso não 
            % seja vazio, então o PLOT deverá ser atualizado.
        
            if isempty(app.hClearWrite)
                % Essa configuração aqui dispara o trigger de alteração de
                % 'XLim' e 'YLim', executando o callback
                % @(src,evt)plot_AxesLimitsChanged(app,src,evt)
                set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
                ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))
        
                % (a) ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["ClearWrite", "MinHold", "Average", "MaxHold"]
                    if ismember(plotTag, {'MinHold', 'Average', 'MaxHold'}) && ~eval(sprintf('app.axesTool_%s.UserData.Value', plotTag))
                        continue
                    end
        
                    eval(sprintf('app.h%s = plot.draw2D.OrdinaryLine(app.UIAxes1, app.bandObj, idx, "%s");', plotTag, plotTag))
                    plot.datatip.Template(eval(sprintf('app.h%s', plotTag)), "Frequency+Level", app.bandObj.LevelUnit)
                end
                
                % (b) Persistance
                if app.axesTool_Persistance.UserData.Value
                    plot_Draw_Persistance(app, 'Creation', idx)
                end

                % Emissões
                plot.draw2D.ClearWrite_old(app, idx, 'InitialPlot', 1)

                % BandLimits & Channels
                plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')
                plot_Draw_Channels(app, idx)
        
                % Occupancy
                if app.axesTool_Occupancy.UserData.Value
                    occIndex = play_OCCIndex(app, idx, 'PLAYBACK');
                    plot.old_OCC(app, idx, 'Creation', occIndex)
                end
        
                % Waterfall
                if app.axesTool_Waterfall.UserData.Value
                    plot_Draw_Waterfall(app, idx)
                end
        
                % customPlayback >> DataTips
                if ~isempty(app.specData(idx).UserData.customPlayback.Parameters)
                    dtConfig = app.specData(idx).UserData.customPlayback.Parameters.Datatip;
                    dtParent = [app.UIAxes1, app.UIAxes2, app.UIAxes3];
                    plot.datatip.Create('customPlayback', dtConfig, dtParent)
                end
        
            else
                % ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["ClearWrite", "MinHold", "Average", "MaxHold"]
                    if ismember(plotTag, {'MinHold', 'Average', 'MaxHold'})
                        if ~eval(sprintf('app.axesTool_%s.UserData.Value', plotTag)) || isinf(app.General.Integration.Trace)
                            continue
                        end
                    end
        
                    eval(sprintf('plot.draw2D.OrdinaryLineUpdate(app.h%s, app.bandObj, idx, plotTag);', plotTag))
                end
        
                for ii = 1:numel(app.hEmissionMarkers)
                    app.hEmissionMarkers(ii).Position(2) = app.hClearWrite.YData(app.hClearWrite.MarkerIndices(ii));
                end
        
                % Persistance
                plot_Draw_Persistance(app, 'Update', idx)

                % WaterfallTime
                if app.axesTool_Waterfall.UserData.Value && ~isempty(app.hWaterfallTime) && strcmp(app.play_Waterfall_Timeline.Value, 'on')
                    plot.draw2D.OrdinaryLineUpdate(app.hWaterfallTime, app.bandObj, idx, 'WaterfallTime');
                end
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function plot_Draw_Persistance(app, operationType, idx)
            switch operationType
                case 'Creation'
                    [app.hPersistanceObj, app.play_Persistance_WindowSizeValue.Text] = plot.Persistance('Creation', app.hPersistanceObj, app.UIAxes1, app.bandObj, idx);
                    play_Layout_PersistancePanel(app)

                case 'Update'
                    if app.axesTool_Persistance.UserData.Value && ~strcmp(app.play_Persistance_WindowSizeValue.Text, 'full')
                        app.hPersistanceObj = plot.Persistance('Update', app.hPersistanceObj, app.UIAxes1, app.bandObj, idx);
                        play_Layout_PersistancePanel(app)
                    end

                case 'Delete'
                    app.hPersistanceObj = plot.Persistance('Delete', app.hPersistanceObj);
            end
        end

        %-----------------------------------------------------------------%
        function plot_Draw_Waterfall(app, idx)
            prePlot_updatingGeneralSettings(app)
            prePlot_updatingCustomProperties(app, idx)

            [app.hWaterfall, app.play_Waterfall_DecimationValue.Text] = plot.Waterfall('Creation', app.UIAxes3, app.bandObj, idx);
            plot.axes.Layout.YLabel(app.hWaterfall, app.axesTool_Waterfall.UserData.Value)
            play_Layout_WaterfallPanel(app)

            % DataCursorMode
            % O DataCursorMode é, de forma geral, uma interação ruim p/ eixos
            % cartesianos por bloquear as outras (Pan, regionZoom etc). Por
            % essa razão, restringir o DataCursorMode apenas ao eixo específico
            % em que está sendo plotado a imagem (que não suporta a interação 
            % padrão de DataTip).
            switch app.play_Waterfall_Fcn.Value
                case 'image'
                    app.axesTool_DataTip.Enable = 1;
                case 'mesh'
                    app.axesTool_DataTip.Enable = 0;
                    if app.axesTool_DataTip.UserData
                        play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_DataTip))
                    end
            end

            % Timeline
            if strcmp(app.play_Waterfall_Timeline.Value, 'on')
                app.hWaterfallTime = plot.draw2D.OrdinaryLine(app.UIAxes3, app.bandObj, idx, 'WaterfallTime');
            end
        end

        %-----------------------------------------------------------------%
        function plot_Draw_Channels(app, idx)
            delete(findobj(app.UIAxes1, 'Tag', 'Channel'))

            if ~isempty(app.play_Channel_Tree.SelectedNodes) && app.play_Channel_ShowPlot.UserData
                chTable = table('Size',          [0, 6],                                                                      ...
                                'VariableNames', {'Name', 'FirstChannel', 'ChannelBW', 'Reference', 'FreqStart', 'FreqStop'}, ...
                                'VariableTypes', {'cell', 'double', 'double', 'cell', 'double', 'double'});

                for ii = 1:numel(app.play_Channel_Tree.SelectedNodes)
                    srcChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.src;
                    idxChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.idx;
    
                    switch srcChannel
                        case 'channelLib'
                            srcRawTable = app.channelObj.Channel(idxChannel);
                        case 'manual'
                            srcRawTable = app.specData(idx).UserData.channelManual(idxChannel);
                    end

                    chTable = PreparingData2Plot(app.channelObj, chTable, srcRawTable);
                end

                if ~isempty(chTable)
                    plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'Channel', chTable) 
                end
            end
        end
        
        %-----------------------------------------------------------------%
        function plot_AxesLimitsChanged(app, src, evt)
            switch src.Name
                case 'XLim'
                    app.play_Limits_xLim1.Value = round(evt.AffectedObject.XLim(1), 3);
                    app.play_Limits_xLim2.Value = round(evt.AffectedObject.XLim(2), 3);

                case 'YLim'
                    app.play_Limits_yLim1.Value = round(double(evt.AffectedObject.YLim(1)), 1);
                    app.play_Limits_yLim2.Value = round(double(evt.AffectedObject.YLim(2)), 1);
            end
        end

        %-----------------------------------------------------------------%
        function [idx, nSweeps] = plot_updateIndex(app)
            % Os valores do índice e do número de varredura se referem ao
            % novo fluxo espectral selecionado, e não àquele que estava
            % sendo apresentado.
            idx = app.play_Tree.SelectedNodes.NodeData;
            idx = idx(1);
            nSweeps = numel(app.specData(idx).Data{1});
            
            plot_startupFcn(app, idx)
            plot_Draw(app, idx)

            app.plotFlag = 1;
        end     
        
        %-----------------------------------------------------------------%
        function plot_deleteLines(app, Tag)
            eval(sprintf('delete(app.h%s)', Tag));
            eval(sprintf('app.h%s = [];', Tag));
        end

        %-----------------------------------------------------------------%
        function plot_mainLoop(app, idx, nSweeps)
            app.tool_Play.ImageSource = 'stop_32.png';                

            while app.idxTime <= nSweeps
                % A variável app.plotFlag pode assumir os valores -1 | 0 | 1.
                % - -1: alteração de fluxo espectral
                % -  0: finalização do plot
                % -  1: atualização do plot
                switch app.plotFlag
                    case -1; [idx, nSweeps] = plot_updateIndex(app);
                    case  0; break
                end
                sweepTic = tic;
                
                plot_Draw(app, idx)
                app.tool_TimestampLabel.Text   = sprintf('%d de %d\n%s', app.idxTime, nSweeps, app.specData(idx).Data{1}(app.idxTime));
                app.tool_TimestampSlider.Value = round(100 * app.idxTime/nSweeps, 1);
                
                pause(max(app.play_MinPlotTime.Value/1000-toc(sweepTic), .001))
                
                % Reload Flag
                if app.idxTime == nSweeps
                    if app.tool_LoopControl.Tag == "loop"
                        app.idxTime = 1;
                    else
                        break
                    end
                else
                    app.idxTime = app.idxTime+1;
                end                
            end

            app.tool_Play.ImageSource = 'play_32.png';
        end


        %-----------------------------------------------------------------%
        % ## Modo "RELATÓRIO" ##
        %-----------------------------------------------------------------%
        function report_TreeBuilding(app)
            if ~isempty(app.report_Tree.Children)
                delete(app.report_Tree.Children);
            end

            % E, posteriormente, ajusta os elementos do painel do modo
            % RELATÓRIO.
            idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            if isempty(idxThreads)
                app.tool_ReportGenerator.Enable = 0;

            else
                report_ModelOrVersionValueChanged(app, struct('Source', app.report_ModelName))
                
                [receiverList, ~, ic] = unique({app.specData(idxThreads).Receiver});                
                for ii = 1:numel(receiverList)
                    idx2 = find(ic == ii)';
                    Category = uitreenode(app.report_Tree, 'Text', receiverList{ii},                          ...
                                                           'NodeData', idxThreads(idx2),                      ...
                                                           'Icon', util.layoutTreeNodeIcon(receiverList{ii}), ...
                                                           'ContextMenu', app.report_ContextMenu);
                    
                    for jj = idx2
                        idx3 = idxThreads(jj);
                        Node = uitreenode(Category, 'Text', misc_nodeTreeText(app, idx3), ...
                                                    'NodeData', idx3,                     ...
                                                    'ContextMenu', app.report_ContextMenu);

                        if ~isempty(app.specData(idx3).UserData.reportExternalFiles)
                            Node.Icon = 'attach_32.png';
                        end
                    end
                end
                expand(app.report_Tree, 'all')
            end

            % Atualizando a árvore principal de fluxos de dados, destacando
            % os fluxos incluídos para análise (no modo RELATÓRIO).
            play_changingTreeNodeStyleFromReport(app)

            % Atualizando módulo auxiliar auxApp.winSignalAnalysis, caso
            % habilitada a visualização apenas das emissões relacionadas
            % aos fluxos espectrais a processar.
            play_UpdateAuxiliarApps(app, 'SIGNALANALYSIS')

            play_TreeSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function report_updateAlgorithms(app, status, varargin)
            switch status
                case 'on'
                    idx = varargin{1};                    
                    ui.TextView.update(app.report_ThreadAlgorithms, util.HtmlTextGenerator.ReportAlgorithms(app.specData(idx)));
                    app.report_ThreadAlgorithms.UserData.idxThread = app.play_PlotPanel.UserData;
                    app.report_ThreadAlgorithmsImage.Visible = 'off';
                    
                case 'off'
                    ui.TextView.update(app.report_ThreadAlgorithms, '');
                    app.report_ThreadAlgorithms.UserData.idxThread = [];
                    app.report_ThreadAlgorithmsImage.Visible = 'on';
            end
        end

        %-----------------------------------------------------------------%
        function report_Algorithms(app, idx)
            if isscalar(idx) && app.specData(idx).UserData.reportFlag
                if isempty(app.report_ThreadAlgorithms.UserData.idxThread) || ~isequal(app.report_ThreadAlgorithms.UserData.idxThread, app.play_PlotPanel.UserData)
                    report_updateAlgorithms(app, 'on', idx)
                    app.report_EditDetection.Enable      = ~app.specData(idx).UserData.reportAlgorithms.Detection.ManualMode;
                    app.report_EditClassification.Enable = 1;
                    set(app.report_DetectionManualMode, 'Enable', 1, 'Value', app.specData(idx).UserData.reportAlgorithms.Detection.ManualMode)
                end

            else
                report_updateAlgorithms(app, 'off')
                app.report_EditDetection.Enable      = 0;
                app.report_EditClassification.Enable = 0;
                set(app.report_DetectionManualMode, 'Enable', 0, 'Value', 0)
            end            
        end


        %-----------------------------------------------------------------%
        % MISCELÂNEAS
        %-----------------------------------------------------------------%
        function nodeText = misc_nodeTreeText(app, idx)
            FreqStart = app.specData(idx).MetaData.FreqStart / 1e+6;
            FreqStop  = app.specData(idx).MetaData.FreqStop  / 1e+6;

            nodeText = sprintf('%.3f - %.3f MHz', FreqStart, FreqStop);
        end

        %-----------------------------------------------------------------%
        function misc_updateLastVisitedFolder(app, filePath)
            app.General_I.fileFolder.lastVisited = filePath;
            app.General.fileFolder.lastVisited   = filePath;

            appEngine.util.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General_I, app.executionMode)
        end

        %-----------------------------------------------------------------%
        function generation = misc_findGenerationOfTreeNode(app, treeNode)
            referenceNode = treeNode;
            generation    = 0;
            while true
                if referenceNode.Parent ~= app.play_Tree
                    referenceNode = referenceNode.Parent;
                    generation = generation+1;
                else
                    break
                end
            end
        end

        %-----------------------------------------------------------------%
        function SelectedNodesTextList = misc_SelectedNodesText(app)
            SelectedNodesTextList = {};
            for ii = 1:numel(app.play_Tree.SelectedNodes)
                generation = misc_findGenerationOfTreeNode(app, app.play_Tree.SelectedNodes(ii));

                switch generation
                    case 0
                        NN = numel(app.play_Tree.SelectedNodes(ii).Children);
                        SelectedNodesTextList(end+1:end+NN) = {app.play_Tree.SelectedNodes(ii).Text};
                    case 1
                        SelectedNodesTextList{end+1} = app.play_Tree.SelectedNodes(ii).Text;
                    case 2
                        SelectedNodesTextList{end+1} = app.play_Tree.SelectedNodes(ii).Parent.Text;
                    case 3
                        SelectedNodesTextList{end+1} = app.play_Tree.SelectedNodes(ii).Parent.Parent.Text;
                end

            end
            SelectedNodesTextList = unique(SelectedNodesTextList);
        end

        %-----------------------------------------------------------------%
        function fileFullPath = misc_SaveSpectralData(app, idx)
            nameFormatMap = {'*.mat',    'appAnalise (*.mat)'; ...
                             '*.bin',    'Logger (*.bin)';     ...
                             '*.sm1809', 'SM1809 (*.sm1809)'};
            
            defaultName   = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'SpectralData', -1); 
            [fileFullPath, ~, fileExt] = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end

            % As mensagens de erro apresentadas a seguir já explicitam as
            % limitações dos formatos "CRFS Bin" e "SM1809". O formato  "MAT",
            % por outro lado, não possui limitação.
            switch fileExt
                case '.bin'
                    receiverList = unique({app.specData(idx).Receiver});
                    if (numel(receiverList) > 1) || ~contains(receiverList, 'RFeye', 'IgnoreCase', true)
                        msgWarning = 'O formato de arquivo CRFS Bin não possibilita o armazenamento de dados gerados por mais de um sensor, ou por um sensor que não seja um RFeye.';
                    end
                case '.sm1809'
                    receiverList = unique({app.specData(idx).Receiver});
                    if (numel(receiverList) > 1)
                        msgWarning = 'O formato de arquivo SM1809 não possibilita o armazenamento de dados gerados por mais de um sensor.';
                    elseif any(ismember(arrayfun(@(x) x.MetaData.DataType, app.specData(idx)), class.Constants.occDataTypes))
                        msgWarning = 'O formato de arquivo SM1809 não possibilita o armazenamento de fluxos de ocupação.';
                    end
            end

            if exist('msgWarning', 'var')
                fileFullPath = '';
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                return
            end

            args = {app.specData(idx)};
            if strcmp(fileExt, '.mat')
                args = [args, {[], {'UserData', 'callingApp', 'sortType'}}];
            end
            misc_ExportDataToFile(app, fileFullPath, fileExt, 'SpectralData', args{:})
        end

        %-----------------------------------------------------------------%
        function misc_ExportDataToFile(app, fileName, fileExt, fileType, varargin)
            arguments
                app
                fileName
                fileExt  char {mustBeMember(fileExt,  {'.mat', '.bin', '.sm1809'})}
                fileType char {mustBeMember(fileType, {'ProjectData', 'SpectralData', 'UserData'})}
            end

            arguments (Repeating)
                varargin
            end

            % Avalia se o disco sob análise tem ao menos FreeStorageThreshold 
            % de espaço livre.
            [statusFreeStorage, msgFreeStorage] = util.checkFreeStorage(fileName, app.General.fileFolder.tempPath, app.General.operationMode.FreeStorageThreshold);
            if ~statusFreeStorage
                msgQuestion   = sprintf('%s\n\nDeseja continuar mesmo assim?', msgFreeStorage);
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
                if strcmp(userSelection, 'Não')
                    return
                end
            end

            app.progressDialog.Visible = 'visible';
            
            switch fileType
                case {'ProjectData', 'UserData'}
                    model.fileWriter.MAT(fileName, fileType, varargin{:});

                case 'SpectralData'
                    switch fileExt
                        case '.mat'
                            model.fileWriter.MAT(fileName, fileType, varargin{:});
                        case '.bin'
                            model.fileWriter.CRFSBin(fileName, varargin{:});
                        case '.sm1809'
                            model.fileWriter.SM1809( fileName, varargin{:});
                    end
            end

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function misc_ExportUserData(app, idx)
            if numel(idx) < numel(app.specData)
                msgQuestion   = 'Você deseja exportar a lista de emissões apenas dos fluxos espectrais selecionados ou de todos os fluxos espectrais?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Apenas seleção', 'Todos', 'Cancelar'}, 1, 3);
                switch userSelection
                    case 'Todos'
                        idx = 1:numel(app.specData);
                    case 'Cancelar'
                        return
                end
            end

            nameFormatMap = {'*.mat', 'appAnalise (*.mat)'};
            defaultName   = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'UserData', -1); 
            fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end
            
            misc_ExportDataToFile(app, fileFullPath, '.mat', 'UserData', app.specData(idx), struct.empty, {'Data', 'callingApp', 'sortType'})
        end

        %-----------------------------------------------------------------%
        function fileFullPath = misc_ImportUserData(app, idx)
            if numel(idx) < numel(app.specData)
                msgQuestion   = 'Você deseja importar a lista de emissões apenas para os fluxos espectrais selecionados ou para todos os fluxos espectrais?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Apenas seleção', 'Todos', 'Cancelar'}, 1, 3);
                switch userSelection
                    case 'Todos'
                        idx = 1:numel(app.specData);
                    case 'Cancelar'
                        return
                end
            end

            [fileFullPath, fileFolder] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.mat', 'appAnalise (*.mat)'}, app.General.fileFolder.lastVisited);
            if isempty(fileFullPath)
                return
            end
            misc_updateLastVisitedFolder(app, fileFolder)
            
            util.importAnalysis(app, app.specData(idx), fileFullPath);
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

            if ~strcmp(app.executionMode, 'webApp')
                projectName = char(app.report_ProjectName.Value);
                if ~isempty(projectName) && app.report_ProjectWarnIcon.Visible
                    msgQuestion = sprintf(['O projeto aberto - registrado no arquivo <b>"%s"</b> - foi alterado.\n\n' ...
                                           'Deseja descartar essas alterações? Caso não, favor salvá-las no modo RELATÓRIO.'], projectName);
                else
                    msgQuestion = 'Deseja fechar o aplicativo?';
                end

                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            % Aspectos gerais (comum em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)
            
        end

        % Value changed function: Tab1Button, Tab2Button, Tab3Button, 
        % ...and 3 other components
        function tabNavigatorButtonPushed(app, event)

            clickedButton  = event.Source;
            auxAppName     = clickedButton.Tag;
            inputArguments = auxAppInputArguments(app, auxAppName);
            openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, inputArguments{:})
            
        end

        % Image clicked function: AppInfo, FigurePosition
        function menuImageClicked(app, event)

            switch event.Source
                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appEngine.util.setWindowPosition(app.UIFigure)

                case app.AppInfo
                    appInfo = util.HtmlTextGenerator.AppInfo(app.General, app.rootFolder, app.executionMode, app.renderCount, "popup");
                    ui.Dialog(app.UIFigure, 'info', appInfo);
            end

        end

        % Image clicked function: file_OpenFileButton
        function file_ButtonPushed_OpenFile(app, event)

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
                misc_updateLastVisitedFolder(app, filePath)
            end

            file_OpenSelectedFiles(app, filePath, fileName)

        end

        % Image clicked function: file_SpecReadButton
        function file_ButtonPushed_SpecRead(app, event)
                        
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

                if isempty(app.UIAxes1)
                    startup_Axes(app)
                end
    
                % Habilita botões do menu principal - PLAYBACK, REPORT e MISC -
                % abrindo programaticamente o modo PLAYBACK.
                set(app.Tab2Button, 'Enable', 1, 'Value', 1)
                app.Tab3Button.Enable = 1;
                app.Tab4Button.Enable = 1;

                tabNavigatorButtonPushed(app, struct('Source', app.Tab2Button, 'PreviousValue', false))

                % Constroi a árvore de fluxos espectrais, deixando selecionado
                % o primeiro dos fluxos. E constroi a árvore de fluxos espectrais
                % que eventualmente foram incluídos em um projeto.
                play_TreeBuilding(app)
                app.play_Tree.SelectedNodes = app.play_Tree.Children(1).Children(1);
                report_TreeBuilding(app)
    
                % Desabilita botão, inviabilizando leitura do mesmo conjunto de
                % dados.
                app.file_SpecReadButton.Enable = 0;

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
                file_DataReaderError(app)
            end

            delete(d)

        end

        % Selection changed function: file_Tree
        function file_TreeSelectionChanged(app, event)
            
            currentSelectedFileIndex = [];

            if ~isempty(app.file_Tree.SelectedNodes)
                % Caso sejam selecionados nós de apenas um único arquivo,
                % apresentam-se os metadados relacionados à informação 
                % espectral, além de habilitar os botões do toolbar.

                idxFileList   = arrayfun(@(x) x.NodeData.idx1, app.file_Tree.SelectedNodes, "UniformOutput", false);
                idxFile       = unique(horzcat(idxFileList{:}));

                if isscalar(idxFile)
                    idxThreadList = arrayfun(@(x) x.NodeData.idx2, app.file_Tree.SelectedNodes, "UniformOutput", false);
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

            if isequal(app.file_Tree.UserData, currentSelectedFileIndex)
                % Não faz nada...

            elseif ~isempty(currentSelectedFileIndex)
                app.file_Tree.UserData = currentSelectedFileIndex;

                collapse(app.file_Tree)                        
                expand(app.file_Tree.Children(idxFile), 'all')
                scroll(app.file_Tree, app.file_Tree.SelectedNodes(end))

                ui.TextView.update(app.file_Metadata, util.HtmlTextGenerator.Thread(app.metaData, idxFile, idxThread));

            else
                app.file_Tree.UserData = struct('previousSelectedFileIndex', [], 'previousSelectedFileThread', []);
                ui.TextView.update(app.file_Metadata, '');
            end
            
        end

        % Value changed function: file_FilteringType
        function file_FilteringTypeChanged(app, event)

            cellfun(@(x) set(x, 'Visible', 'off'), {app.file_FilteringValue_Frequency, app.file_FilteringValue_ID, app.file_FilteringValue_Description});

            switch app.file_FilteringType.Value
                case 'Faixa de Frequência'; app.file_FilteringValue_Frequency.Visible   = 'on';
                case 'ID';                  app.file_FilteringValue_ID.Visible          = 'on';
                case 'Descrição';           app.file_FilteringValue_Description.Visible = 'on';
            end

        end

        % Image clicked function: file_FilteringAdd
        function file_FilteringAddClicked(app, event)
            
            switch app.file_FilteringType.Value
                case 'Faixa de Frequência'
                    if isempty(app.file_FilteringValue_Frequency.Value)
                        return
                    end
                    newFilterText = sprintf('FREQUÊNCIA: %s', app.file_FilteringValue_Frequency.Value);
                    
                case 'ID'
                    if isempty(app.file_FilteringValue_ID.Value)
                        return
                    end
                    newFilterText = sprintf('ID: %s', app.file_FilteringValue_ID.Value);
                    
                case 'Descrição'
                    app.file_FilteringValue_Description.Value = upper(strtrim(app.file_FilteringValue_Description.Value));
                    
                    if isempty(app.file_FilteringValue_Description.Value)
                        return
                    else
                        newFilterText = sprintf('DESCRIÇÃO: "%s"', app.file_FilteringValue_Description.Value);
                    end
            end

            hComponents = allchild(app.file_FilteringTree);
            if ~isempty(hComponents) && ismember(newFilterText, {hComponents.Text})
                return
            end

            uitreenode(app.file_FilteringTree, 'Text',        newFilterText, ...
                                               'ContextMenu', app.file_ContextMenu_Tree2);
            file_TreeBuilding(app)

        end

        % Menu selected function: file_ContextMenu_delTree1Node
        function file_ContextMenu_delTree1NodeSelected(app, event)
            % <ReviewNote>EMD - 14/08/2024</ReviewNote>
            idxTable = table('Size', [0, 3],                                ...
                             'VariableTypes', {'double', 'double', 'cell'}, ...
                             'VariableNames', {'level', 'idx1', 'idx2'});

            for ii = 1:numel(app.file_Tree.SelectedNodes)
                idx = find(idxTable.idx1 == app.file_Tree.SelectedNodes(ii).NodeData.idx1, 1);
                if isempty(idx)
                    idxTable(end+1,:)   = {app.file_Tree.SelectedNodes(ii).NodeData.level, app.file_Tree.SelectedNodes(ii).NodeData.idx1, {app.file_Tree.SelectedNodes(ii).NodeData.idx2}};
                else
                    idxTable(idx,[1,3]) = {min([idxTable{idx,1}, app.file_Tree.SelectedNodes(ii).NodeData.level]), {unique([cell2mat(idxTable{idx,3}), app.file_Tree.SelectedNodes(ii).NodeData.idx2])}};
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
            
            file_TreeBuilding(app)

        end

        % Menu selected function: file_ContextMenu_delTree2Node
        function file_ContextMenu_delTree2NodeSelected(app, event)
            
            if ~isempty(app.file_FilteringTree.SelectedNodes)
                delete(app.file_FilteringTree.SelectedNodes)
                file_TreeBuilding(app)
            end

        end

        % Selection change function: SubTabGroup
        function SubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

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

            % Create Tab1_File
            app.Tab1_File = uitab(app.TabGroup);
            app.Tab1_File.AutoResizeChildren = 'off';
            app.Tab1_File.Title = 'FILE';

            % Create file_Grid
            app.file_Grid = uigridlayout(app.Tab1_File);
            app.file_Grid.ColumnWidth = {10, '1x', '1x', 10, '0.25x', 360, 10};
            app.file_Grid.RowHeight = {94, 10, '1x', 10, 34};
            app.file_Grid.ColumnSpacing = 0;
            app.file_Grid.RowSpacing = 0;
            app.file_Grid.Padding = [0 0 0 40];
            app.file_Grid.BackgroundColor = [1 1 1];

            % Create file_Tree
            app.file_Tree = uitree(app.file_Grid);
            app.file_Tree.Multiselect = 'on';
            app.file_Tree.SelectionChangedFcn = createCallbackFcn(app, @file_TreeSelectionChanged, true);
            app.file_Tree.FontSize = 10;
            app.file_Tree.Layout.Row = 3;
            app.file_Tree.Layout.Column = [2 3];

            % Create file_Metadata
            app.file_Metadata = uilabel(app.file_Grid);
            app.file_Metadata.VerticalAlignment = 'top';
            app.file_Metadata.WordWrap = 'on';
            app.file_Metadata.FontSize = 11;
            app.file_Metadata.Layout.Row = 3;
            app.file_Metadata.Layout.Column = [5 6];
            app.file_Metadata.Interpreter = 'html';
            app.file_Metadata.Text = '';

            % Create file_toolGrid
            app.file_toolGrid = uigridlayout(app.file_Grid);
            app.file_toolGrid.ColumnWidth = {22, 5, 22, '1x'};
            app.file_toolGrid.RowHeight = {3, 17, 2};
            app.file_toolGrid.ColumnSpacing = 5;
            app.file_toolGrid.RowSpacing = 0;
            app.file_toolGrid.Padding = [10 6 10 6];
            app.file_toolGrid.Layout.Row = 5;
            app.file_toolGrid.Layout.Column = [1 7];

            % Create file_OpenFileButton
            app.file_OpenFileButton = uiimage(app.file_toolGrid);
            app.file_OpenFileButton.ScaleMethod = 'none';
            app.file_OpenFileButton.ImageClickedFcn = createCallbackFcn(app, @file_ButtonPushed_OpenFile, true);
            app.file_OpenFileButton.Tooltip = {'Seleciona arquivos'};
            app.file_OpenFileButton.Layout.Row = 2;
            app.file_OpenFileButton.Layout.Column = 1;
            app.file_OpenFileButton.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Import_16.png');

            % Create file_SpecReadButton
            app.file_SpecReadButton = uiimage(app.file_toolGrid);
            app.file_SpecReadButton.ScaleMethod = 'none';
            app.file_SpecReadButton.ImageClickedFcn = createCallbackFcn(app, @file_ButtonPushed_SpecRead, true);
            app.file_SpecReadButton.Enable = 'off';
            app.file_SpecReadButton.Tooltip = {'Inicia análise'};
            app.file_SpecReadButton.Layout.Row = 2;
            app.file_SpecReadButton.Layout.Column = 3;
            app.file_SpecReadButton.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Run_16.png');

            % Create Image
            app.Image = uiimage(app.file_toolGrid);
            app.Image.ScaleMethod = 'none';
            app.Image.Enable = 'off';
            app.Image.Layout.Row = [1 3];
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.file_Grid);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @SubTabGroupSelectionChanged, true);
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

            % Create NOMEDAEMPRESAMetadadosOutrascoisasLabel
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel = uilabel(app.SubGrid1);
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.VerticalAlignment = 'top';
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.WordWrap = 'on';
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.FontSize = 11;
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.FontColor = [0.149 0.149 0.149];
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.Layout.Row = 1;
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.Layout.Column = 1;
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.Text = 'Este aplicativo permite a leitura de arquivos gerados em monitorações do espectro de radiofrequências usando o appColeta, Logger, Argus e CelPlan, organizando as informações por faixa de frequência. Também realiza detecção e classificação de emissões, comparando com informações constantes no RFDataHub. E, por fim, possibilita anotação dos dados e geração de relatório.';

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'FILTRO';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {320, 22, 320};
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create file_FilteringType
            app.file_FilteringType = uidropdown(app.SubGrid2);
            app.file_FilteringType.Items = {'Faixa de Frequência', 'ID', 'Descrição'};
            app.file_FilteringType.ValueChangedFcn = createCallbackFcn(app, @file_FilteringTypeChanged, true);
            app.file_FilteringType.FontSize = 11;
            app.file_FilteringType.BackgroundColor = [1 1 1];
            app.file_FilteringType.Layout.Row = 1;
            app.file_FilteringType.Layout.Column = 1;
            app.file_FilteringType.Value = 'Faixa de Frequência';

            % Create file_FilteringValue_Description
            app.file_FilteringValue_Description = uieditfield(app.SubGrid2, 'text');
            app.file_FilteringValue_Description.FontSize = 11;
            app.file_FilteringValue_Description.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringValue_Description.Visible = 'off';
            app.file_FilteringValue_Description.Layout.Row = 2;
            app.file_FilteringValue_Description.Layout.Column = 1;

            % Create file_FilteringValue_ID
            app.file_FilteringValue_ID = uidropdown(app.SubGrid2);
            app.file_FilteringValue_ID.Items = {};
            app.file_FilteringValue_ID.Visible = 'off';
            app.file_FilteringValue_ID.FontSize = 11;
            app.file_FilteringValue_ID.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringValue_ID.BackgroundColor = [1 1 1];
            app.file_FilteringValue_ID.Layout.Row = 2;
            app.file_FilteringValue_ID.Layout.Column = 1;
            app.file_FilteringValue_ID.Value = {};

            % Create file_FilteringValue_Frequency
            app.file_FilteringValue_Frequency = uidropdown(app.SubGrid2);
            app.file_FilteringValue_Frequency.Items = {};
            app.file_FilteringValue_Frequency.FontSize = 11;
            app.file_FilteringValue_Frequency.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringValue_Frequency.BackgroundColor = [1 1 1];
            app.file_FilteringValue_Frequency.Layout.Row = 2;
            app.file_FilteringValue_Frequency.Layout.Column = 1;
            app.file_FilteringValue_Frequency.Value = {};

            % Create file_FilteringAdd
            app.file_FilteringAdd = uiimage(app.SubGrid2);
            app.file_FilteringAdd.ScaleMethod = 'none';
            app.file_FilteringAdd.ImageClickedFcn = createCallbackFcn(app, @file_FilteringAddClicked, true);
            app.file_FilteringAdd.Tooltip = {'Aplica filtro ao conjunto de dados'};
            app.file_FilteringAdd.Layout.Row = [1 2];
            app.file_FilteringAdd.Layout.Column = 2;
            app.file_FilteringAdd.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Continue_16.png');

            % Create file_FilteringTree
            app.file_FilteringTree = uitree(app.SubGrid2);
            app.file_FilteringTree.Multiselect = 'on';
            app.file_FilteringTree.FontSize = 10;
            app.file_FilteringTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringTree.Layout.Row = [1 2];
            app.file_FilteringTree.Layout.Column = 3;

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
            app.NavBar.ColumnWidth = {22, 74, '1x', 34, 5, 34, 34, 34, 34, 34, '1x', 20, 20, 1, 20, 20};
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
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab1Button.Tag = 'FILE';
            app.Tab1Button.Tooltip = {'Leitura de arquivos'};
            app.Tab1Button.Icon = 'OpenFile_32Yellow.png';
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
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'PLAYBACK';
            app.Tab2Button.Enable = 'off';
            app.Tab2Button.Tooltip = {'Playback'};
            app.Tab2Button.Icon = 'Playback_32White.png';
            app.Tab2Button.IconAlignment = 'top';
            app.Tab2Button.Text = '';
            app.Tab2Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab2Button.FontSize = 11;
            app.Tab2Button.Layout.Row = [2 4];
            app.Tab2Button.Layout.Column = 6;

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'DRIVETEST';
            app.Tab3Button.Enable = 'off';
            app.Tab3Button.Tooltip = {'Drive-test'};
            app.Tab3Button.Icon = 'DriveTestDensity_32White.png';
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 7;

            % Create Tab4Button
            app.Tab4Button = uibutton(app.NavBar, 'state');
            app.Tab4Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab4Button.Tag = 'SIGNALANALYSIS';
            app.Tab4Button.Enable = 'off';
            app.Tab4Button.Tooltip = {'Análise de sinais'};
            app.Tab4Button.Icon = 'exceptionList_32White.png';
            app.Tab4Button.IconAlignment = 'top';
            app.Tab4Button.Text = '';
            app.Tab4Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab4Button.FontSize = 11;
            app.Tab4Button.Layout.Row = [2 4];
            app.Tab4Button.Layout.Column = 8;

            % Create Tab5Button
            app.Tab5Button = uibutton(app.NavBar, 'state');
            app.Tab5Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab5Button.Tag = 'RFDATAHUB';
            app.Tab5Button.Tooltip = {'RFDataHub'};
            app.Tab5Button.Icon = 'mosaic_32White.png';
            app.Tab5Button.IconAlignment = 'top';
            app.Tab5Button.Text = '';
            app.Tab5Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab5Button.FontSize = 11;
            app.Tab5Button.Layout.Row = [2 4];
            app.Tab5Button.Layout.Column = 9;

            % Create Tab6Button
            app.Tab6Button = uibutton(app.NavBar, 'state');
            app.Tab6Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab6Button.Tag = 'CONFIG';
            app.Tab6Button.Tooltip = {'Configurações gerais'};
            app.Tab6Button.Icon = 'Settings_36White.png';
            app.Tab6Button.IconAlignment = 'top';
            app.Tab6Button.Text = '';
            app.Tab6Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab6Button.FontSize = 11;
            app.Tab6Button.Layout.Row = [2 4];
            app.Tab6Button.Layout.Column = 10;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.NavBar);
            app.jsBackDoor.Layout.Row = [2 5];
            app.jsBackDoor.Layout.Column = 12;

            % Create DataHubLamp
            app.DataHubLamp = uiimage(app.NavBar);
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear o Sharepoint'};
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 13;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menuImageClicked, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Tooltip = {'Reposiciona janela'};
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 15;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout1_32White.png');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menuImageClicked, true);
            app.AppInfo.Tooltip = {'Informações gerais'};
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 16;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Dots_32White.png');

            % Create file_ContextMenu_Tree1
            app.file_ContextMenu_Tree1 = uicontextmenu(app.UIFigure);
            app.file_ContextMenu_Tree1.Tag = 'winAppAnalise';

            % Create file_ContextMenu_delTree1Node
            app.file_ContextMenu_delTree1Node = uimenu(app.file_ContextMenu_Tree1);
            app.file_ContextMenu_delTree1Node.MenuSelectedFcn = createCallbackFcn(app, @file_ContextMenu_delTree1NodeSelected, true);
            app.file_ContextMenu_delTree1Node.ForegroundColor = [1 0 0];
            app.file_ContextMenu_delTree1Node.Text = 'Excluir';

            % Create file_ContextMenu_Tree2
            app.file_ContextMenu_Tree2 = uicontextmenu(app.UIFigure);
            app.file_ContextMenu_Tree2.Tag = 'winAppAnalise';

            % Create file_ContextMenu_delTree2Node
            app.file_ContextMenu_delTree2Node = uimenu(app.file_ContextMenu_Tree2);
            app.file_ContextMenu_delTree2Node.MenuSelectedFcn = createCallbackFcn(app, @file_ContextMenu_delTree2NodeSelected, true);
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
