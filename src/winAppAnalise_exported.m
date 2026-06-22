classdef winAppAnalise_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        NavBar                   matlab.ui.container.GridLayout
        AppInfo                  matlab.ui.control.Image
        FigurePosition           matlab.ui.control.Image
        DataHubLamp              matlab.ui.control.Image
        jsBackDoor               matlab.ui.control.HTML
        Tab7Button               matlab.ui.control.StateButton
        Tab6Button               matlab.ui.control.StateButton
        Tab5Button               matlab.ui.control.StateButton
        ButtonsSeparator2        matlab.ui.control.Image
        Tab4Button               matlab.ui.control.StateButton
        Tab3Button               matlab.ui.control.StateButton
        Tab2Button               matlab.ui.control.StateButton
        ButtonsSeparator1        matlab.ui.control.Image
        Tab1Button               matlab.ui.control.StateButton
        AppName                  matlab.ui.control.Label
        TabGroup                 matlab.ui.container.TabGroup
        Tab1_File                matlab.ui.container.Tab
        Tab1Grid                 matlab.ui.container.GridLayout
        SubTabGroup              matlab.ui.container.TabGroup
        SubTab1                  matlab.ui.container.Tab
        SubGrid1                 matlab.ui.container.GridLayout
        FileTreeCollapse         matlab.ui.control.Image
        FileTreeExpand           matlab.ui.control.Image
        FileSortMethod           matlab.ui.control.DropDown
        FileSortMethodIcon       matlab.ui.control.Image
        FileModuleInfo           matlab.ui.control.Label
        SubTab2                  matlab.ui.container.Tab
        SubGrid2                 matlab.ui.container.GridLayout
        FileFilterTree           matlab.ui.container.Tree
        FileFilterAdd            matlab.ui.control.Image
        FileFilterValueList      matlab.ui.control.DropDown
        FileFilterValueText      matlab.ui.control.EditField
        FileFilterType           matlab.ui.control.DropDown
        Toolbar                  matlab.ui.container.GridLayout
        tool_ReadFiles           matlab.ui.control.Image
        FileMetadata             matlab.ui.control.Label
        FileTree                 matlab.ui.container.Tree
        Tab2_Playback            matlab.ui.container.Tab
        Tab3_DriveTest           matlab.ui.container.Tab
        Tab4_SignalAnalysis      matlab.ui.container.Tab
        Tab5_RFDataHub           matlab.ui.container.Tab
        Tab6_RepoSFI             matlab.ui.container.Tab
        Tab7_Config              matlab.ui.container.Tab
        ContextMenu              matlab.ui.container.ContextMenu
        ContextMenuDeleteButton  matlab.ui.container.Menu
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
        popupCurrentApp

        eFiscalizaObj

        projectData
        metaData = model.MetaData.empty
        specData = model.SpecData.empty        
        
        channelObj
        elevationObj = RF.Elevation
        kmlObj
        dbHandlerObj

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
                                onFileTreeSelectionChanged(app)
                            end

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            if ~isempty(selectedNodes)
                                app.FileTree.SelectedNodes = selectedNodes;
                                onFileTreeSelectionChanged(app)
                            end
                        end
                        
                        app.renderCount = app.renderCount+1;

                    case 'unload'
                        closeFcn(app)

                    case 'closeFcnCallFromPopupApp'
                        context = event.HTMLEventData.context;
                        popupCurrentAppTag = event.HTMLEventData.dockAppName;

                        switch context
                            case {'mainApp', app.Context}
                                hApp = app;
                            otherwise
                                hApp = getAppHandle(app.tabGroupController, context);
                        end
                        
                        if ~isempty(hApp) && isvalid(hApp)
                            deleteContextMenu(app.tabGroupController, hApp.UIFigure, popupCurrentAppTag)
                        end

                        if contains(class(app.popupCurrentApp), popupCurrentAppTag)
                            delete(app.popupCurrentApp)
                            app.popupCurrentApp = [];
                        end
                    
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

                    case 'findResourceStaticURL'
                        resourceStaticURL = event.HTMLEventData;
                        if ~isempty(resourceStaticURL)
                            app.General.AppVersion.application.resourceStaticURL = resourceStaticURL;
                        end

                    % winAppAnalise
                    case 'mainApp.FileTree'
                        onContextMenuDeleteOptionClicked(app, struct('ContextObjectTag', 'fileTreeContext'))

                    case 'mainApp.FileFilterTree'
                        onContextMenuDeleteOptionClicked(app, struct('ContextObjectTag', 'fileFilterTreeContext'))

                    % % auxApp.winPlayback
                    % case 'auxApp.winPlayback.ChannelTree'
                    %     play_Channel_ContextMenu_delChannelSelected(app)
                    % 
                    % case 'auxApp.winPlayback.FindPeaksTree'
                    %     play_FindPeaks_delEmission(app)
                    
                    % auxApp.winDriveTest
                    % auxApp.winRFDataHub
                    case {'auxApp.winDriveTest.FilterTree', 'auxApp.winDriveTest.PointsTree', 'auxApp.winRFDataHub.FilterTree'}
                        if contains(event.HTMLEventName, 'winDriveTest')
                            auxAppName = 'DRIVETEST';
                            
                        elseif contains(event.HTMLEventName, 'winRFDataHub')
                            auxAppName = 'RFDATAHUB';
                        end

                        ipcMainMatlabCallAuxiliarApp(app, auxAppName, 'MATLAB', event.HTMLEventName)

                    % % DOCKADDKFACTOR / DOCKTIMEFILTERING
                    % case {'auxApp.dockAddKFactor.kFactorTree', 'auxApp.dockTimeFiltering.filterTree'}
                    %     hDockApp  = app.popupContainer.RunningAppInstance;
                    %     ipcSecundaryJSEventsHandler(hDockApp, event)

                    otherwise
                        error('winAppAnalise:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
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
                        auxAppTag = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        varargout{1} = {app};

                    case 'onUpdateLastVisitedFolder'
                        filePath = varargin{1};
                        updateLastVisitedFolder(app, filePath)

                    otherwise
                        switch class(callingApp)
                            % auxApp.winConfig (CONFIG)
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch eventName
                                    case 'checkDataHubLampStatus'
                                        updateWarningLampVisibility(app)

                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))

                                    case 'onSimulationMode'
                                        navigateToTab(app, app.Tab1Button)
                                        onFilteTreeAddRequested(app, struct('EventName', eventName))

                                    case 'onYAxesScaleChange'
                                        ipcMainMatlabCallAuxiliarApp(app, 'PLAYBACK', 'MATLAB', eventName)

                                    case 'onRFDataHubUpdate'
                                        initializeRFDataHub(app)
                                        ipcMainMatlabCallAuxiliarApp(app, 'RFDATAHUB', 'MATLAB', eventName)

                                    case 'onFileSortMethodChanged'
                                        if ~strcmp(app.FileSortMethod.Value, app.General.context.FILE.sortMethod)
                                            app.FileSortMethod.Value = app.General.context.FILE.sortMethod;
                                            onFileSortMethodValueChanged(app)
                                        end

                                    otherwise
                                        error('winAppAnalise:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end

                            % auxApp.winPlayback (PLAYBACK)
                            case {'auxApp.winPlayback', 'auxApp.winPlayback_exported'}
                                switch eventName
                                    case 'onPlaybackStarted'
                                        ipcMainMatlabCallAuxiliarApp(app, 'DRIVETEST', 'MATLAB', eventName)

                                    case 'onReportGenerate'
                                        context = varargin{1};
                                        indexes = varargin{2};
                                        reportGenerate(app, context, [], indexes)

                                    case 'onUploadArtifacts'
                                        context = varargin{1};
                                        reportUploadArtifacts(app, context, [], 'uploadDocument')

                                    case {'onSpectralDataReadError', 'onEmissionDeleted', 'onEmissionParameterValueChanged'}
                                        notifySecondaryApps(app, eventName)

                                    case 'onFlowUnlockRequested'
                                        requestVisibilityChange(callingApp.progressDialog, 'visible', 'locked')

                                        flowIdx = varargin{1};
                                        update(app.specData(flowIdx), 'IsUserModified', 'Unlock', app.metaData)
                                        refreshProjectFiles(app, [], 'onFlowUnlockRequested')

                                        requestVisibilityChange(callingApp.progressDialog, 'hidden', 'locked')

                                    case 'onEmissionAdded'
                                        notifySecondaryApps(app, eventName)

                                    otherwise
                                        error('winAppAnalise:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end
        
                            % auxApp.winDriveTest (DRIVETEST)
                            case {'auxApp.winDriveTest', 'auxApp.winDriveTest_exported'}
                                switch eventName
                                    case 'onPlaybackStarted'
                                        ipcMainMatlabCallAuxiliarApp(app, 'PLAYBACK', 'MATLAB', eventName)

                                    case 'onSpectralDataReadError'
                                        context = varargin{1};
                                        notifySecondaryApps(app, eventName, {context})

                                    case 'onClassificationEditRequested'
                                        if ~app.Tab4Button.Value
                                            isAppOpen = ~isempty(getAppHandle(app.tabGroupController, 'SIGNALANALYSIS'));
                                            navigateToTab(app, app.Tab4Button)
                                            
                                            if ~isAppOpen
                                                pause(1)

                                                hAuxApp = getAppHandle(app.tabGroupController, 'SIGNALANALYSIS');
                                                if ui.FigureRenderStatus(hAuxApp.UIFigure)
                                                    pause(1)
                                                end
                                            end
                                        end

                                        flowIdx = varargin{2};
                                        emissionIdx = varargin{3};
                                        ipcMainMatlabCallAuxiliarApp(app, 'SIGNALANALYSIS', 'MATLAB', 'onEmissionSelectionChanged', flowIdx, emissionIdx)

                                    otherwise
                                        error('winAppAnalise:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end

                            % auxApp.winSignalAnalysis (SIGNALANALYSIS)
                            case {'auxApp.winSignalAnalysis', 'auxApp.winSignalAnalysis_exported'}
                                switch eventName
                                    case {'onEmissionDeleted', 'onEmissionParameterValueChanged'}
                                        context = varargin{1};
                                        notifySecondaryApps(app, eventName, {context})

                                    case 'onEmissionTruncatedValueChanged'
                                        ipcMainMatlabCallAuxiliarApp(app, 'DRIVETEST', 'MATLAB', eventName)

                                    otherwise
                                        error('winAppAnalise:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end

                            % auxApp.winRFDataHub (RFDATAHUB)
                            % ...

                            % auxApp.winRepoSFI (REPOSFI)
                            % ...

                            % DOCKS:OTHERS
                            case {'auxApp.dockCalibration',     'auxApp.dockCalibration_exported',     ... % ?
                                  'auxApp.dockChannels',        'auxApp.dockChannels_exported',        ... % ?
                                  'auxApp.dockClassification',  'auxApp.dockClassification_exported',  ... % ?
                                  'auxApp.dockDetection',       'auxApp.dockDetection_exported',       ... % PLAYBACK
                                  'auxApp.dockDetectionLimits', 'auxApp.dockDetectionLimits_exported', ... % PLAYBACK
                                  'auxApp.dockDriveTestFilter', 'auxApp.dockDriveTestFilter_exported', ... % DRIVETEST
                                  'auxApp.dockDriveTestPoints', 'auxApp.dockDriveTestPoints_exported', ... % DRIVETEST
                                  'auxApp.dockEmissionChannel', 'auxApp.dockEmissionChannel_exported', ... % DRIVETEST | SIGNALANALYSIS
                                  'auxApp.dockExternalFiles',   'auxApp.dockExternalFiles_exported',   ... % ?
                                  'auxApp.dockFilterByLevel',   'auxApp.dockFilterByLevel_exported',   ... % PLAYBACK
                                  'auxApp.dockFilterByTime',    'auxApp.dockFilterByTime_exported',    ... % PLAYBACK
                                  'auxApp.dockLocation',        'auxApp.dockLocation_exported',        ... % PLAYBACK
                                  'auxApp.dockFlowMerge',       'auxApp.dockFlowMerge_exported',       ... % PLAYBACK (toolbar)
                                  'auxApp.dockOccupancy',       'auxApp.dockOccupancy_exported',       ... % ?
                                  'auxApp.dockReportLib',       'auxApp.dockReportLib_exported',       ... % PLAYBACK (toolbar)
                                  'auxApp.dockRepoFiles',       'auxApp.dockRepoFiles_exported'}           % REPOSFI

                                switch eventName
                                    % auxApp.dockReportLib
                                    case {'onProjectRestart', 'onFinalReportFileChanged'}
                                        refreshProjectFiles(app, [], 'onProjectLoad')

                                    case 'onProjectLoad'
                                        filePath = varargin{1};
                                        onFilteTreeAddRequested(app, struct('EventName', 'onImportFilesFromPaths', 'FilePaths', {filePath}))
                                        refreshProjectFiles(app, [], 'onProjectLoad')
                                        
                                    case 'onUpdateLastVisitedFolder'
                                        filePath = varargin{1};
                                        updateLastVisitedFolder(app, filePath)

                                    case 'onFetchIssueDetails'
                                        context  = varargin{1};
                                        reportFetchIssueDetails(app, context, [])

                                    case 'onExternalFileModuleOpenRequest'
                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                            pause(.100)
                                        else
                                            delete(callingApp)
                                        end

                                        ipcMainMatlabCallAuxiliarApp(app, 'PLAYBACK', 'MATLAB', eventName, varargin{:})

                                    % Outros...
                                    case {'onEmissionAdded', 'onLocationChanged'}
                                        notifySecondaryApps(app, eventName)

                                    case 'onDetectionSubBandsChanged'
                                        emissionsDeleted = varargin{1};
                                        if emissionsDeleted
                                            notifySecondaryApps(app, eventName)
                                        else
                                            ipcMainMatlabCallAuxiliarApp(app, 'PLAYBACK', 'MATLAB', eventName)
                                        end

                                    case 'onCalibrationCurveApplied'
                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                        else
                                            delete(callingApp)
                                        end

                                        notifySecondaryApps(app, eventName)

                                    case 'onEmissionChannelChanged'
                                        notifySecondaryApps(app, eventName, {'PLAYBACK'})

                                    case {'onFilterByLevelRequested', 'onFilterByTimeRequested'}
                                        requestVisibilityChange(callingApp.progressDialog, 'visible', 'locked')

                                        flowIdx = varargin{1};
                                        filterSpecification = varargin{2};
                                        matchMask = varargin{3};
                                        maskMode = varargin{4};

                                        app.specData(flowIdx) = applyFilter(app.specData(flowIdx), filterSpecification, matchMask, maskMode);
                                        notifySecondaryApps(app, eventName, {'SIGNALANALYSIS'})

                                        requestVisibilityChange(callingApp.progressDialog, 'hidden', 'locked')

                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                        else
                                            delete(callingApp)
                                        end

                                    case 'onReportFlowListChanged'
                                        notifySecondaryApps(app, eventName)

                                    case 'onFlowMergeRequested'
                                        requestVisibilityChange(callingApp.progressDialog, 'visible', 'locked')

                                        flowIdxs = varargin{1};
                                        app.specData = mergeWith(app.specData, flowIdxs);
                                        notifySecondaryApps(app, eventName)

                                        requestVisibilityChange(callingApp.progressDialog, 'hidden', 'locked')

                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                        else
                                            delete(callingApp)
                                        end

                                    case 'onDriveTestFilterChanged'
                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                        else
                                            delete(callingApp)
                                        end

                                        ipcMainMatlabCallAuxiliarApp(app, 'DRIVETEST', 'MATLAB', eventName, varargin{:})

                                    case 'onDriveTestPointsAdded'
                                        ipcMainMatlabCallAuxiliarApp(app, 'DRIVETEST', 'MATLAB', eventName, varargin{:})

                                    case 'onImportFilesFromPaths'
                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                        else
                                            delete(callingApp)
                                        end

                                        filePaths = varargin{1};

                                        navigateToTab(app, app.Tab1Button)
                                        onFilteTreeAddRequested(app, struct('EventName', 'onImportFilesFromPaths', 'FilePaths', {filePaths}))

                                    otherwise
                                        error('winAppAnalise:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end
            
                            otherwise
                                error('winAppAnalise:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
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
        function ipcMainMatlabOpenPopupApp(app, callingApp, auxAppName, context, varargin)
            arguments
                app
                callingApp
                auxAppName char {mustBeMember(auxAppName, {'Calibration', 'Channels', 'ChannelsFileImport', 'ChannelsSatellite', 'Detection', 'DetectionLimits', 'DriveTestFilter', 'DriveTestPoints', 'EmissionChannel', 'ExternalFiles', 'FilterByLevel', 'FilterByTime', 'FlowMerge', 'Location', 'ReportLib', 'RepoFiles'})}
                context    char {mustBeMember(context, {'mainApp', 'FILE', 'PLAYBACK', 'DRIVETEST', 'SIGNALANALYSIS', 'MISC', 'RFDATAHUB', 'REPOSFI', 'CONFIG'})}
            end

            arguments (Repeating)
                varargin 
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')
            inputArguments = [{app, callingApp, context}, varargin];

            if app.General.operationMode.Debug
                app.popupCurrentApp = eval(sprintf('auxApp.dock%s(inputArguments{:})', auxAppName));
                app.popupCurrentApp.isDocked = false;

            else
                popupSpecifications = table( ...
                    'Size', [15, 4], ...
                    'VariableTypes', {'string', 'double', 'double', 'logical'}, ...
                    'VariableNames', {'AuxAppName', 'Width', 'Height', 'IsFluid'} ...
                );
                popupSpecifications( 1, :) = {"Calibration",        452, 170, false};
                popupSpecifications( 2, :) = {"Channels",           412, 516, false}; % Em andamento
                popupSpecifications( 3, :) = {"ChannelsFileImport", 620, 480, false}; % Em andamento
                popupSpecifications( 4, :) = {"ChannelsSatellite",  620, 480, false}; % Em andamento
                popupSpecifications( 5, :) = {"Detection",          412, 484, false};
                popupSpecifications( 6, :) = {"DetectionLimits",    292, 360, false};
                popupSpecifications( 7, :) = {"DriveTestFilter",    412, 338, false};
                popupSpecifications( 8, :) = {"DriveTestPoints",    412, 408, false};
                popupSpecifications( 9, :) = {"EmissionChannel",    412, 138, false};
                popupSpecifications(10, :) = {"ExternalFiles",      880, 480, true};
                popupSpecifications(11, :) = {"FilterByLevel",      550, 308, false};
                popupSpecifications(12, :) = {"FilterByTime",       452, 208, false};
                popupSpecifications(13, :) = {"FlowMerge",          880, 480, true};
                popupSpecifications(14, :) = {"Location",           412, 190, false};                
                popupSpecifications(15, :) = {"Occupancy",          412, 516, false}; % Não iniciada revisão
                popupSpecifications(16, :) = {"ReportLib",          784, 594, false};
                popupSpecifications(17, :) = {"RepoFiles",         1244, 660, false};

                auxAppNameIdx = find(popupSpecifications.AuxAppName == string(auxAppName), 1);
                screenWidth = popupSpecifications.Width(auxAppNameIdx);
                screenHeight = popupSpecifications.Height(auxAppNameIdx);
                isFluid = popupSpecifications.IsFluid(auxAppNameIdx);

                ui.PopUpContainer(callingApp, screenWidth, screenHeight)
                auxDockAppName = sprintf('auxApp.dock%s', auxAppName);
                app.popupCurrentApp = feval([auxDockAppName '_exported'], callingApp.popupContainer, inputArguments{:});
                
                ui.CustomizationBase.getElementsDataTag({
                    callingApp.popupContainer;
                    app.popupCurrentApp.GridLayout
                });

                if isFluid
                    sizing = struct('type', 'fluid', 'width', 90, 'height', 80);
                else
                    sizing = struct('type', 'fixed', 'width', screenWidth, 'height', screenHeight+31);
                end

                sendEventToHTMLSource(callingApp.jsBackDoor, 'dockContainer', struct( ...
                    'dockAppName', auxDockAppName, ...
                    'dockAppDataTag', app.popupCurrentApp.GridLayout.UserData.id, ...
                    'dockAppContainerDataTag', callingApp.popupContainer.UserData.id, ...
                    'sizing', sizing, ...
                    'context', context, ...
                    'numCanvasElements', numel(findobj(app.popupCurrentApp.Container, 'Type', 'axes')) ...
                ))

                app.popupCurrentApp.GridLayout.UserData.auxDockAppName = auxDockAppName;
                callingApp.popupContainer.UserData.auxDockAppName = auxDockAppName;
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end
    end
    
    
    methods (Access = public)
        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            clickedButton.Value = true;
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
                        app.FileTreeExpand;
                        app.FileTreeCollapse;
                        app.FileTree;
                        app.FileMetadata;
                        app.tool_ReadFiles
                    };                            
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.FileMetadata, appName);
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.FileModuleInfo.UserData.id, 'selector', '[class="mwTextNode"]', 'style', struct('textAlign', 'justify')), ...
                            struct('appName', appName, 'dataTag', app.tool_ReadFiles.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Seleciona arquivos')), ...
                            struct('appName', appName, 'dataTag', app.FileTreeExpand.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Expandir tudo')), ...
                            struct('appName', appName, 'dataTag', app.FileTreeCollapse.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Recolher tudo')), ...
                            struct('appName', appName, 'dataTag', app.Tab1Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab2Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab3Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab4Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab5Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab5Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab6Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab7Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.FileTree.UserData.id, 'listener', struct('componentName', 'mainApp.FileTree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end

                    app.FileFilterTree.UserData.render = false;
                    initializeFileTreeSelectionIdx(app)

                case 2
                    elToModify = {
                        app.FileFilterTree
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);
                    
                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.FileFilterTree.UserData.id, 'listener', struct('componentName', 'mainApp.FileFilterTree', 'keyEvents', {{'Delete', 'Backspace'}}))  ...
                        });
                    catch
                    end

                    app.FileFilterTree.UserData.render = true;
                    onFileFilterTypeSelectionChanged(app)
                    updateFileFilterTree(app)
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
            
            if isempty(app.General_I.context.FILE.spectrumConsolidationPolicy.maxCoLocationDistanceMeters)
                app.General_I.context.FILE.spectrumConsolidationPolicy.maxCoLocationDistanceMeters = Inf;
            end
        
            if isempty(app.General_I.context.PLAYBACK.integration.traceMode)
                app.General_I.context.PLAYBACK.integration.traceMode = Inf;
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
                    app.General_I.plot.geographicAxes.Basemap = 'none';
                    app.General_I.reportLib.basemap = 'none';

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

            app.General = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')

            % Ideia é identificar URL de pasta estática servida pelo backend, de 
            % forma que possam ser inseridas imagens em uilabel (como ui.TextView).
            try
                [~, resourceName, resourceExt] = fileparts(app.tool_ReadFiles.ImageSource);
                sendEventToHTMLSource(app.jsBackDoor, 'findResourceStaticURL', struct('resourceName', [resourceName resourceExt], 'resourceTag', 'img', 'resourceId', app.tool_ReadFiles.UserData.id))
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRFDataHub(app)

            app.projectData = model.Project(app, app.rootFolder, app.General);
            app.channelObj  = class.ChannelLib(class.Constants.appName, app.rootFolder);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog);
            addComponent(app.tabGroupController, "Built-in", "",                         app.Tab1Button, "AlwaysOn", struct('On', '', 'Off', ''), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winPlayback",       app.Tab2Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winDriveTest",      app.Tab3Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      3)
            addComponent(app.tabGroupController, "External", "auxApp.winSignalAnalysis", app.Tab4Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      4)
            addComponent(app.tabGroupController, "External", "auxApp.winRFDataHub",      app.Tab5Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      5)
            addComponent(app.tabGroupController, "External", "auxApp.winRepoSFI",        app.Tab6Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      6)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",         app.Tab7Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      7)
            app.tabGroupController.inlineSVG = true;

            % addStyle(app.FileTree, uistyle('Interpreter', 'html'))
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateWarningLampVisibility(app)
            app.FileSortMethod.Value = app.General.context.FILE.sortMethod;
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
        function initializeFileTreeSelectionIdx(app)
            app.FileTree.UserData.previousSelection = struct('fileIdx', [], 'flowIdxs', []);
        end

        %-----------------------------------------------------------------%
        function refreshProjectFiles(app, previousSelectionIdxs, updateType)
            arguments
                app
                previousSelectionIdxs
                updateType char {mustBeMember(updateType, {'onFileListAdded', ...
                                                           'onFileListRemoved', ...
                                                           'onFileFilterChanged', ...
                                                           'onProjectLoad', ...
                                                           'onFlowUnlockRequested'})}
            end

            buildFileTree(app, previousSelectionIdxs)
            app.specData = syncCollection(app.specData, app.metaData, app.projectData, app.channelObj, app.General);
            notifySecondaryApps(app, updateType)
        end

        %-----------------------------------------------------------------%
        function notifySecondaryApps(app, updateType, excludeTags)
            arguments
                app
                updateType char {mustBeMember(updateType, {'onFileListAdded', ...
                                                           'onFileListRemoved', ...
                                                           'onFileFilterChanged', ...
                                                           'onProjectLoad', ...
                                                           'onFlowUnlockRequested', ...
                                                           'onReportFlowListChanged', ...
                                                           'onFilterByLevelRequested', ...
                                                           'onFilterByTimeRequested', ...
                                                           'onFlowMergeRequested', ...
                                                           'onLocationChanged', ...
                                                           'onEmissionAdded', ...
                                                           'onEmissionParameterValueChanged', ...
                                                           'onEmissionChannelChanged', ...
                                                           'onEmissionDeleted', ...
                                                           'onDetectionSubBandsChanged', ...
                                                           'onCalibrationCurveApplied', ...
                                                           'onSpectralDataReadError'})}
                excludeTags cell = {}
            end
            
            secondaryAppTags = setdiff({'PLAYBACK', 'DRIVETEST', 'SIGNALANALYSIS'}, excludeTags);
            cellfun(@(x) ipcMainMatlabCallAuxiliarApp(app, x, 'MATLAB', updateType), secondaryAppTags)
        end

        %-----------------------------------------------------------------%
        function buildFileTree(app, previousSelectionIdxs)
            arguments
                app 
                previousSelectionIdxs = []
            end

            if ~isempty(app.FileTree.Children)
                delete(app.FileTree.Children)
                
                oldStyleIndex = find(app.FileTree.StyleConfigurations.Target == "node");
                if ~isempty(oldStyleIndex)
                    removeStyle(app.FileTree, oldStyleIndex)
                end

                initializeFileTreeSelectionIdx(app)
            end

            if ~isempty(app.metaData)
                onFileFilterTypeSelectionChanged(app)
                updateFileFilterTree(app)

                selectedNodes = [];
                filteredNodes = [];

                referenceTable = buildSpectrumReferenceTable(app.metaData, app.General, true);

                switch app.FileSortMethod.Value
                    case 'ARQUIVO' % Ordenação "ARQUIVO >> SENSOR >> FLUXO ESPECTRAL"
                        referenceTable = sortrows(referenceTable, {'File', 'Receiver', 'FreqStart', 'FreqStop', 'IsOccupancyFlow', 'BeginTime'});
                        [uniqueFiles, ~, fileGroupIdxs] = unique(referenceTable.File, 'stable');

                        for ii = 1:numel(uniqueFiles)
                            [~, fileName, fileExt] = fileparts(uniqueFiles{ii});

                            level1Idxs = find(fileGroupIdxs == ii)';
                            fileIdx = referenceTable.FileIdx(level1Idxs(1));

                            fileNode = uitreenode(app.FileTree, ...
                                'Text', [fileName fileExt], ...
                                'NodeData', struct('sortType', 'ARQUIVO', 'level', 1, 'fileIdx', fileIdx, 'flowIdx', referenceTable.FlowIdx(level1Idxs)'), ...
                                'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                            );

                            if ~any(referenceTable.IsEnable(level1Idxs))
                                filteredNodes = [filteredNodes, fileNode];
                            end

                            [uniqueReceivers, ~, receiverGroupIdxs] = unique(referenceTable.Receiver(level1Idxs), 'stable');

                            for jj = 1:numel(uniqueReceivers)
                                receiver  = uniqueReceivers{jj};
                                level2Idx = level1Idxs(receiverGroupIdxs == jj);

                                receiverNode = uitreenode(fileNode, ...
                                    'Text', util.layoutTreeNodeText(receiver, 'file_TreeBuilding'), ...
                                    'NodeData', struct('sortType', 'ARQUIVO', 'level', 2, 'fileIdx', fileIdx, 'flowIdx', referenceTable.FlowIdx(level2Idx)'), ...
                                    'Icon', util.layoutTreeNodeIcon(receiver), ...
                                    'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                                );

                                if ~any(referenceTable.IsEnable(level2Idx))
                                    filteredNodes = [filteredNodes, receiverNode];
                                end

                                for kk = level2Idx
                                    % durationFlag = sprintf(' (⌛%s)', referenceTable.Duration(kk));
                                    % if referenceTable.Duration(kk) < minutes(10)
                                    %     durationFlag = [durationFlag(1:end-1), '⚠️)'];
                                    % end

                                    occupancyFlag = '';
                                    if referenceTable.IsOccupancyFlow(kk)
                                        occupancyFlag = ' (Ocupação)';
                                    end

                                    warningMsg = computeWarningMessage(referenceTable.GpsStatus(kk), referenceTable.Duration(kk));

                                    dataNode = uitreenode(receiverNode, ...
                                        'Text', sprintf('%s%s%s', referenceTable.Band{kk}, occupancyFlag, warningMsg), ...
                                        'NodeData', struct('sortType', 'ARQUIVO', 'level', 3, 'fileIdx', fileIdx, 'flowIdx', referenceTable.FlowIdx(kk)), ...
                                        'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                                    );

                                    if ~referenceTable.IsEnable(kk)
                                        filteredNodes = [filteredNodes, dataNode];
                                    end

                                    if ~isempty(previousSelectionIdxs) && ismember(fileIdx, previousSelectionIdxs.fileIdx) && ismember(referenceTable.FlowIdx(kk), previousSelectionIdxs.flowIdxs)
                                        selectedNodes = [selectedNodes, dataNode];
                                    end
                                end
                            end
                        end

                    case 'SENSOR' % Ordenação "SENSOR >> ARQUIVO >> FLUXO ESPECTRAL"
                        referenceTable = sortrows(referenceTable, {'Receiver', 'File', 'FreqStart', 'FreqStop', 'IsOccupancyFlow', 'BeginTime'});
                        [uniqueReceivers, ~, receiverGroupIdxs] = unique(referenceTable.Receiver, 'stable');

                        for ii = 1:numel(uniqueReceivers)
                            receiver = uniqueReceivers{ii};
                            level1Idxs = find(receiverGroupIdxs == ii)';

                            [uniqueReceiverFiles, ~, receiverFileGroupIdxs] = unique(referenceTable.File(level1Idxs), 'stable');

                            receiverFileIdxs = {};
                            receiverFileFlowIdxs = {};
                            for mm = 1:numel(uniqueReceiverFiles)
                                level2Idxs = level1Idxs(receiverFileGroupIdxs == mm);
                                receiverFileIdxs{end+1} = referenceTable.FileIdx(level2Idxs(1));
                                receiverFileFlowIdxs{end+1} = referenceTable.FlowIdx(level2Idxs)';
                            end

                            receiverNode = uitreenode(app.FileTree, ...
                                'Text', util.layoutTreeNodeText(receiver, 'file_TreeBuilding'), ...
                                'NodeData', struct('sortType', 'SENSOR', 'level', 1, 'fileIdx', receiverFileIdxs, 'flowIdx', receiverFileFlowIdxs), ...
                                'Icon', util.layoutTreeNodeIcon(receiver), ...
                                'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                            );

                            if ~any(referenceTable.IsEnable(level1Idxs))
                                filteredNodes = [filteredNodes, receiverNode];
                            end

                            for mm = 1:numel(uniqueReceiverFiles)
                                [~, fileName, fileExt] = fileparts(uniqueReceiverFiles{mm});
                                
                                fileIdx = receiverFileIdxs{mm};
                                flowIdxs = receiverFileFlowIdxs{mm};

                                fileNode = uitreenode(receiverNode, ...
                                    'Text', [fileName fileExt], ...
                                    'NodeData', struct('sortType', 'SENSOR', 'level', 2, 'fileIdx', fileIdx, 'flowIdx', flowIdxs), ...
                                    'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                                );

                                level2Idxs = level1Idxs(receiverFileGroupIdxs == mm);

                                if ~any(referenceTable.IsEnable(level2Idxs))
                                    filteredNodes = [filteredNodes, fileNode];
                                end

                                for kk = level2Idxs
                                    occupancyFlag = '';
                                    if referenceTable.IsOccupancyFlow(kk)
                                        occupancyFlag = ' (Ocupação)';
                                    end

                                    warningMsg = computeWarningMessage(referenceTable.GpsStatus(kk), referenceTable.Duration(kk));

                                    dataNode = uitreenode(fileNode, ...
                                        'Text', sprintf('%s%s%s', referenceTable.Band{kk}, occupancyFlag, warningMsg), ...
                                        'NodeData', struct('sortType', 'SENSOR', 'level', 3, 'fileIdx', fileIdx, 'flowIdx', referenceTable.FlowIdx(kk)), ...
                                        'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                                    );

                                    if ~referenceTable.IsEnable(kk)
                                        filteredNodes = [filteredNodes, dataNode];
                                    end

                                    if ~isempty(previousSelectionIdxs) && ismember(fileIdx, previousSelectionIdxs.fileIdx) && ismember(referenceTable.FlowIdx(kk), previousSelectionIdxs.flowIdxs)
                                        selectedNodes = [selectedNodes, dataNode];
                                    end
                                end
                            end
                        end

                    otherwise % Ordenação "FLUXO ESPECTRAL >> SENSOR >> ARQUIVO"
                        referenceTable = sortrows(referenceTable, {'FreqStart', 'FreqStop', 'Receiver', 'IsOccupancyFlow', 'BeginTime'});
                        [uniqueBands, ~, uniqueBandIdxs] = unique(referenceTable.Band, 'stable');

                        for ii = 1:numel(uniqueBands)
                            level1Idxs = find(uniqueBandIdxs == ii)';

                            bandFiles = referenceTable.File(level1Idxs);
                            [uniqueBandFiles, ~, bandFileGroupIdxs] = unique(bandFiles, 'stable');

                            bandFileIdxs = {};
                            bandFlowIdxs = {};
                            for ff = 1:numel(uniqueBandFiles)
                                level2Idxs = level1Idxs(bandFileGroupIdxs == ff);
                                bandFileIdxs{end+1} = referenceTable.FileIdx(level2Idxs(1));
                                bandFlowIdxs{end+1} = referenceTable.FlowIdx(level2Idxs)';
                            end

                            bandNode = uitreenode(app.FileTree, ...
                                'Text', referenceTable.Band{level1Idxs(1)}, ...
                                'NodeData', struct('sortType', 'FLUXO ESPECTRAL', 'level', 1, 'fileIdx', bandFileIdxs, 'flowIdx', bandFlowIdxs), ...
                                'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                            );

                            if ~any(referenceTable.IsEnable(level1Idxs))
                                filteredNodes = [filteredNodes, bandNode];
                            end

                            bandReceivers = referenceTable.Receiver(level1Idxs);
                            [uniqueBandReceivers, ~, receiverGroupIdxs] = unique(bandReceivers, 'stable');

                            for rr = 1:numel(uniqueBandReceivers)
                                receiver = uniqueBandReceivers{rr};
                                level2Idxs = level1Idxs(receiverGroupIdxs == rr);

                                receiverFiles = referenceTable.File(level2Idxs);
                                [uniqueFiles, ~, receiverFileGroupIdxs] = unique(receiverFiles, 'stable');

                                receiverFileIdxs = {};
                                receiverFlowdxs = {};
                                for ff = 1:numel(uniqueFiles)
                                    level3Idxs = level2Idxs(receiverFileGroupIdxs == ff);
                                    receiverFileIdxs{end+1} = referenceTable.FileIdx(level3Idxs(1));
                                    receiverFlowdxs{end+1} = referenceTable.FlowIdx(level3Idxs)';
                                end

                                receiverNode = uitreenode(bandNode, ...
                                    'Text', util.layoutTreeNodeText(receiver, 'file_TreeBuilding'), ...
                                    'NodeData', struct('sortType', 'FLUXO ESPECTRAL', 'level', 2, 'fileIdx', receiverFileIdxs, 'flowIdx', receiverFlowdxs), ...
                                    'Icon', util.layoutTreeNodeIcon(receiver), ...
                                    'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                                );

                                if ~any(referenceTable.IsEnable(level2Idxs))
                                    filteredNodes = [filteredNodes, receiverNode];
                                end

                                for jj = level2Idxs
                                    fileIdx = referenceTable.FileIdx(jj);
                                    [~, fileName, fileExt] = fileparts(referenceTable.File{jj});

                                    occupancyFlag = '';
                                    if referenceTable.IsOccupancyFlow(jj)
                                        occupancyFlag = ' (Ocupação)';
                                    end

                                    warningMsg = computeWarningMessage(referenceTable.GpsStatus(jj), referenceTable.Duration(jj));

                                    dataNode = uitreenode(receiverNode, ...
                                        'Text', sprintf('%s%s%s', [fileName fileExt], occupancyFlag, warningMsg), ...
                                        'NodeData', struct('sortType', 'FLUXO ESPECTRAL', 'level', 3, 'fileIdx', fileIdx, 'flowIdx', referenceTable.FlowIdx(jj)), ...
                                        'ContextMenu', app.ContextMenu, 'Tag', 'fileTreeContext' ...
                                    );

                                    if ~referenceTable.IsEnable(jj)
                                        filteredNodes = [filteredNodes, dataNode];
                                    end

                                    if ~isempty(previousSelectionIdxs) && ismember(fileIdx, previousSelectionIdxs.fileIdx) && ismember(referenceTable.FlowIdx(jj), previousSelectionIdxs.flowIdxs)
                                        selectedNodes = [selectedNodes, dataNode];
                                    end
                                end
                            end
                        end
                end

                expand(app.FileTree, 'all')

                if ~isempty(filteredNodes)
                    addStyle(app.FileTree, uistyle('FontColor', [.65,.65,.65]), 'node', filteredNodes)
                end

                if isempty(selectedNodes)
                    selectedNodes = app.FileTree.Children(1);
                end

                app.FileTree.SelectedNodes = selectedNodes;
                onFileTreeSelectionChanged(app)

            else
                ui.TextView.update(app.FileMetadata, '');
                app.FileFilterValueList.Items = {};
                app.FileFilterValueText.Value = '';           
            end

            set([app.FileTreeExpand, app.FileTreeCollapse], 'Enable', ~isempty(app.metaData))

            function warningMsg = computeWarningMessage(gpsStatus, taskDuration)
                warningMsg = '';
                if gpsStatus <= 0
                    warningMsg = ' ❗📍';
                end

                if taskDuration < minutes(app.General.context.FILE.durationWarningThresholdMinutes)
                    if isempty(warningMsg)
                        warningMsg = ' ❗⌛';
                    else
                        warningMsg = [warningMsg '⌛'];
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function updateFileFilterTree(app)
            if ~app.FileFilterTree.UserData.render
                return
            end

            hFilter = allchild(app.FileFilterTree);
            if isempty(hFilter)
                updateEnabledState(app.metaData, 'all-flows', true)

            else
                filterTextList = strjoin({hFilter.Text}, '\n');                
                filterParser   = struct2table(regexp(filterTextList, '(?<Type>(FREQUÊNCIA|ID|DESCRIÇÃO|RECEPTOR))[:] (?<Sentence>.*)', 'names', 'dotexceptnewline'));
                if ~iscell(filterParser.Sentence)
                    filterParser.Sentence = {filterParser.Sentence};
                end

                filterSentence_Description = filterParser.Sentence(filterParser.Type == "DESCRIÇÃO");
                filterSentence_Frequency   = filterParser.Sentence(filterParser.Type == "FREQUÊNCIA");
                filterSentence_ID          = str2double(filterParser.Sentence(filterParser.Type == "ID"));
                filterSentence_Receiver    = filterParser.Sentence(filterParser.Type == "RECEPTOR");

                for ii = 1:numel(app.metaData)
                    for jj = 1:numel(app.metaData(ii).Data)
                        if isInvalidData(app.metaData, ii, jj)
                            continue
                        end

                        updateEnabledState(app.metaData, 'specific-flow', ii, jj, false)

                        % DESCRIÇÃO
                        if ~isempty(filterSentence_Description)
                            description = app.metaData(ii).Data(jj).RelatedFiles.Description{1};
                            if any(cellfun(@(x) contains(description, x, "IgnoreCase", true), replace(filterSentence_Description, '"', '')))
                                updateEnabledState(app.metaData, 'specific-flow', ii, jj, true)
                                continue
                            end
                        end

                        % FREQUÊNCIA
                        if ~isempty(filterSentence_Frequency)
                            flowTag = sprintf('%.3f – %.3f MHz', app.metaData(ii).Data(jj).MetaData.FreqStart / 1e+6, app.metaData(ii).Data(jj).MetaData.FreqStop  / 1e+6);
                            if ismember(flowTag, filterSentence_Frequency)
                                updateEnabledState(app.metaData, 'specific-flow', ii, jj, true)
                                continue
                            end
                        end

                        % ID
                        if ~isempty(filterSentence_ID)
                            id = app.metaData(ii).Data(jj).RelatedFiles.Id(1);
                            if ismember(id, filterSentence_ID)
                                updateEnabledState(app.metaData, 'specific-flow', ii, jj, true)
                                continue
                            end
                        end

                        % RECEPTOR
                        if ~isempty(filterSentence_Receiver)
                            receiver = util.layoutTreeNodeText(app.metaData(ii).Data(jj).Receiver, 'play_TreeBuilding');
                            if ismember(receiver, filterSentence_Receiver)
                                updateEnabledState(app.metaData, 'specific-flow', ii, jj, true)
                                continue
                            end
                        end
                    end
                end
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
                context {mustBeMember(context, {'PLAYBACK'})}
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
                reportLibConnection.Controller.Run(app, callingApp, context, app.specData(indexes))
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
                getGeneratedDocumentFileName(app.projectData, '.teams', context), ...
                getGeneratedDocumentFileName(app.projectData, '.json',  context) ...
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

            questionMsg = '';
            flowIdxs = getReportIncludeIdxs(app.specData);
            if ~isempty(flowIdxs) && checkIfUpdateNeeded(app.projectData, app.specData(flowIdxs))
                questionMsg = sprintf([ ...
                    'O projeto "%s" foi modificado (nome, arquivo de saída, ' ...
                    'lista de arquivos de entrada ou anotações das estações). ' ...
                    'Caso o aplicativo seja encerrado agora, todas as alterações ' ...
                    'serão descartadas.\n\nDeseja realmente fechar o aplicativo?' ...
                ], app.projectData.name);

            elseif ~strcmp(app.executionMode, 'webApp')
                questionMsg = 'Deseja fechar o aplicativo?';
            end

            if ~isempty(questionMsg)                
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            if ~isempty(app.dbHandlerObj)
                delete(app.dbHandlerObj)
            end

            % Aspectos gerais (comum em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)
            
        end

        % Callback function: AppInfo, DataHubLamp, FigurePosition, 
        % ...and 7 other components
        function onTabNavigatorButtonPushed(app, event)

            switch event.Source
                case {app.Tab1Button, app.Tab2Button, app.Tab3Button, app.Tab4Button, app.Tab5Button, app.Tab6Button, app.Tab7Button}
                    openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, app)

                    % Ideia aqui é basicamente parar o PLAYBACK dos módulos
                    % auxApp.winPlayback e auxApp.winDriveTest, caso abertos.
                    if event.Source ~= app.Tab2Button
                        ipcMainMatlabCallAuxiliarApp(app, 'PLAYBACK', 'MATLAB', 'onTabNavigatorButtonPushed')
                    end

                    if event.Source ~= app.Tab3Button
                        ipcMainMatlabCallAuxiliarApp(app, 'DRIVETEST', 'MATLAB', 'onTabNavigatorButtonPushed')
                    end

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
                    appInfo = util.HtmlTextGenerator.getAppInfo( ...
                        app.General, ...
                        app.rootFolder, ...
                        app.executionMode, ...
                        app.renderCount, ...
                        "popup" ...
                    );
                    ui.Dialog(app.UIFigure, 'info', appInfo);
            end
            
        end

        % Selection change function: SubTabGroup
        function onSubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Menu selected function: ContextMenuDeleteButton
        function onContextMenuDeleteOptionClicked(app, event)
            
            if isprop(event, 'ContextObject')
                contextObjectTag = event.ContextObject.Tag;
            else
                contextObjectTag = event.ContextObjectTag;
            end

            switch contextObjectTag
                case 'fileTreeContext'
                    if isempty(app.FileTree.SelectedNodes)
                        return
                    end
        
                    referenceTable = table( ...
                        'Size', [0, 3], ...
                        'VariableTypes', {'double', 'double', 'cell'}, ...
                        'VariableNames', {'level', 'fileIdx', 'flowIdxs'} ...
                    );
        
                    nodeDataList = {};
                    for ii = 1:numel(app.FileTree.SelectedNodes)
                        nd = app.FileTree.SelectedNodes(ii).NodeData;
                        if ~isscalar(nd)
                            for child = app.FileTree.SelectedNodes(ii).Children'
                                childNd = child.NodeData;
                                if ~isscalar(childNd)
                                    for grandchild = child.Children'
                                        nodeDataList{end+1} = grandchild.NodeData;
                                    end
                                else
                                    nodeDataList{end+1} = childNd;
                                end
                            end
                        else
                            nodeDataList{end+1} = nd;
                        end
                    end

                    for ii = 1:numel(nodeDataList)
                        nd = nodeDataList{ii};
                        idx = find(referenceTable.fileIdx == nd.fileIdx, 1);
        
                        if isempty(idx)
                            referenceTable(end+1, :)   = {nd.level, nd.fileIdx, {nd.flowIdx}};
                        else
                            referenceTable(idx, [1,3]) = {min([referenceTable{idx, 1}, nd.level]), {unique([cell2mat(referenceTable{idx, 3}), nd.flowIdx])}};
                        end
                    end
        
                    referenceTable = sortrows(referenceTable, 'fileIdx');
        
                    for kk = height(referenceTable):-1:1
                        fileIdx  = referenceTable.fileIdx(kk);
                        flowIdxs = referenceTable.flowIdxs{kk};
        
                        if (strcmp(app.FileSortMethod.Value, 'ARQUIVO') && referenceTable.level(kk) == 1) || isequal(referenceTable.flowIdxs{kk}, 1:numel(app.metaData(fileIdx).Data))
                            delete(app.metaData(fileIdx))
                            app.metaData(fileIdx) = [];
        
                        else
                            delete(app.metaData(fileIdx).Data(flowIdxs))
                            app.metaData(fileIdx).Samples(flowIdxs, :) = 0;
                            app.metaData(fileIdx).Memory = computeEstimatedMemory(app.metaData, fileIdx);

                            if all(arrayfun(@(x) ~isvalid(x), app.metaData(fileIdx).Data))
                                delete(app.metaData(fileIdx))
                                app.metaData(fileIdx) = [];
                            end
                        end
                    end
                    
                    refreshProjectFiles(app, [], 'onFileListRemoved')

                case 'fileFilterTreeContext'
                    if isempty(app.FileFilterTree.SelectedNodes)
                        return
                    end
        
                    delete(app.FileFilterTree.SelectedNodes)
        
                    previousSelectionIdxs = app.FileTree.UserData.previousSelection;
                    refreshProjectFiles(app, previousSelectionIdxs, 'onFileFilterChanged')
            end

        end

        % Value changed function: FileSortMethod
        function onFileSortMethodValueChanged(app, event)
            
            buildFileTree(app)

        end

        % Image clicked function: FileTreeCollapse, FileTreeExpand
        function onFileTreeExpansionToggleRequest(app, event)
            
            switch event.Source
                case app.FileTreeCollapse
                    collapse(app.FileTree, 'all')
                otherwise % app.FileTreeExpand
                    expand(app.FileTree, 'all')
            end

        end

        % Image clicked function: tool_ReadFiles
        function onFilteTreeAddRequested(app, event)

            hasReadNewFiles = false;

            switch event.EventName
                case 'onSimulationMode'
                    [projectFolder, cacheFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
                    simulationFolders = {cacheFolder, projectFolder};
    
                    for ii = 1:numel(simulationFolders)
                        filePath = fullfile(simulationFolders{ii}, 'Simulation');
                        fileList = dir(filePath);
                        
                        fileName = {fileList.name};
                        fileName = fileName(endsWith(lower(fileName), '.bin'));
    
                        if ~isempty(fileName)
                            break
                        end
                    end

                case 'onImportFilesFromPaths'
                    fileFullPaths = event.FilePaths;

                    if ~iscellstr(fileFullPaths)
                        fileFullPaths = cellstr(fileFullPaths);
                    end

                    [filePath, fileName, fileExt] = fileparts(fileFullPaths);
                    filePath = filePath{1};
                    fileName = strcat(fileName, fileExt);

                case 'ImageClicked'
                    [~, filePath, ~, fileName] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.bin;*.dbm;*.mat', 'Binários (*.bin,*.dbm,*.mat)'; '*.csv;*.sm1809', 'Textuais (*.csv,*.sm1809)'}, app.General.fileFolder.lastVisited, {'MultiSelect', 'on'});
    
                    if isempty(fileName)
                        return
                    elseif ~iscell(fileName)
                        fileName = {fileName};
                    end
    
                    updateLastVisitedFolder(app, filePath)
            end

            d = ui.Dialog(app.UIFigure, 'progressdlg', 'Em andamento a leitura de metadados do(s) arquivo(s) selecionado(s).', 'Cancelable', 'on');
            
            repeteadFiles = {};
            errorMsg = {};

            for ii = 1:numel(fileName)
                if d.CancelRequested
                    break
                end

                d.Message = sprintf('Em andamento a leitura de metadados do arquivo:\n•&thinsp;%s\n\n%d de %d', fileName{ii}, ii, numel(fileName));

                if any(contains({app.metaData.File}, fileName{ii}))
                    repeteadFiles{end+1} = fileName{ii};                      
                    continue
                end

                fileFullPath = fullfile(filePath, fileName{ii});
                [app.metaData, msg] = importFile(app.metaData, fileFullPath, app.projectData, app.General, app.specData);
                
                if isempty(msg)
                    hasReadNewFiles = true;
                else
                    errorMsg{end+1} = msg;
                end
            end

            if hasReadNewFiles
                previousSelectionIdxs = app.FileTree.UserData.previousSelection;
                refreshProjectFiles(app, previousSelectionIdxs, 'onFileListAdded')
            end

            dialogBoxMsg = {};            
            if ~isempty(repeteadFiles)
                dialogBoxMsg{end+1} = sprintf('Os metadados do(s) arquivo(s) indicado(s) a seguir já tinham sido lidos.\n%s', textFormatGUI.cellstr2Bullets(repeteadFiles));
            end

            if ~isempty(errorMsg)
                dialogBoxMsg{end+1} = sprintf('Evidenciado <font style="color: red;"><b>ERRO</b></font> na leitura do(s) arquivo(s) indicado(s) a seguir.\n%s', textFormatGUI.cellstr2Bullets(errorMsg));
            end

            if ~isempty(dialogBoxMsg)
                ui.Dialog(app.UIFigure, 'error', strjoin(dialogBoxMsg, '<br><br>'));
            end

        end

        % Selection changed function: FileTree
        function onFileTreeSelectionChanged(app, event)
            
            currentSelectedIdxs = [];
            if ~isempty(app.FileTree.SelectedNodes)
                fileIdxList = arrayfun(@(x) {x.NodeData.fileIdx}, app.FileTree.SelectedNodes, "UniformOutput", false);
                fileIdxs = unique(cell2mat(horzcat(fileIdxList{:})));

                if isscalar(fileIdxs)
                    flowIdxList = arrayfun(@(x) {x.NodeData.flowIdx}, app.FileTree.SelectedNodes, "UniformOutput", false);
                    flowIdxs = unique(cell2mat(horzcat(flowIdxList{:})));
                    currentSelectedIdxs = struct('fileIdx', fileIdxs, 'flowIdxs', flowIdxs);
                end
            end

            if isequal(app.FileTree.UserData.previousSelection, currentSelectedIdxs)
                return
            end

            if ~isempty(currentSelectedIdxs)
                app.FileTree.UserData.previousSelection = currentSelectedIdxs;
                ui.TextView.update(app.FileMetadata, util.HtmlTextGenerator.getSelectedFileInfo(app.metaData, fileIdxs, app.General, flowIdxs));
            else
                initializeFileTreeSelectionIdx(app)

                if ~isempty(app.FileTree.SelectedNodes)
                    nodeData = [app.FileTree.SelectedNodes.NodeData];
                    ui.TextView.update(app.FileMetadata, util.HtmlTextGenerator.getSelectedFileInfo(app.metaData, fileIdxs, app.General, nodeData))
                else
                    ui.TextView.update(app.FileMetadata, '');
                end
            end
            
        end

        % Image clicked function: FileFilterAdd
        function onFileFilterAddRequested(app, event)
            
            switch app.FileFilterType.Value
                case 'Descrição'
                    app.FileFilterValueText.Value = upper(strtrim(app.FileFilterValueText.Value));
                    
                    if isempty(app.FileFilterValueText.Value)
                        return
                    else
                        newFilterText = sprintf('DESCRIÇÃO: "%s"', app.FileFilterValueText.Value);
                    end

                case 'Faixa de frequência'
                    if isempty(app.FileFilterValueList.Value)
                        return
                    end
                    newFilterText = sprintf('FREQUÊNCIA: %s', app.FileFilterValueList.Value);
                    
                case 'Id'
                    if isempty(app.FileFilterValueList.Value)
                        return
                    end
                    newFilterText = sprintf('ID: %s', app.FileFilterValueList.Value);

                case 'Receptor'
                    if isempty(app.FileFilterValueList.Value)
                        return
                    end
                    newFilterText = sprintf('RECEPTOR: %s', app.FileFilterValueList.Value);
            end

            hComponents = allchild(app.FileFilterTree);
            if ~isempty(hComponents) && ismember(newFilterText, {hComponents.Text})
                return
            end

            uitreenode(app.FileFilterTree, 'Text', newFilterText, 'ContextMenu', app.ContextMenu, 'Tag', 'fileFilterTreeContext');

            previousSelectionIdxs = app.FileTree.UserData.previousSelection;
            refreshProjectFiles(app, previousSelectionIdxs, 'onFileFilterChanged')

        end

        % Value changed function: FileFilterType
        function onFileFilterTypeSelectionChanged(app, event)

            if ~app.FileFilterTree.UserData.render
                return
            end

            switch app.FileFilterType.Value
                case 'Descrição'
                    app.FileFilterValueText.Visible = 'on';
                    app.FileFilterValueList.Visible = 'off';
                    
                case {'Faixa de frequência', 'Id', 'Receptor'}
                    app.FileFilterValueText.Visible = 'off';
                    app.FileFilterValueList.Visible = 'on';

                    if ~isempty(app.metaData)
                        referenceTable = buildSpectrumReferenceTable(app.metaData, app.General, true);

                        switch app.FileFilterType.Value
                            case 'Faixa de frequência'
                                referenceTable = sortrows(referenceTable, {'FreqStart', 'FreqStop'});
                                valueList = referenceTable.Band;
                            case 'Id'
                                referenceTable = sortrows(referenceTable, {'Id', 'FreqStart', 'FreqStop'});
                                valueList = arrayfun(@(x) num2str(x), referenceTable.Id, 'UniformOutput', false);
                            otherwise
                                valueList = cellfun(@(x) util.layoutTreeNodeText(x, 'play_TreeBuilding'), referenceTable.Receiver, 'UniformOutput', false);
                        end

                        app.FileFilterValueList.Items = unique(valueList, 'stable');
                        
                    else
                        app.FileFilterValueList.Items = {};
                    end
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

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1_File
            app.Tab1_File = uitab(app.TabGroup);
            app.Tab1_File.AutoResizeChildren = 'off';
            app.Tab1_File.Title = 'FILE';

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1_File);
            app.Tab1Grid.ColumnWidth = {10, '1x', '1x', 10, '0.25x', 360, 10};
            app.Tab1Grid.RowHeight = {94, 10, '1x', 10, 34};
            app.Tab1Grid.ColumnSpacing = 0;
            app.Tab1Grid.RowSpacing = 0;
            app.Tab1Grid.Padding = [0 0 0 40];
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create FileTree
            app.FileTree = uitree(app.Tab1Grid);
            app.FileTree.Multiselect = 'on';
            app.FileTree.SelectionChangedFcn = createCallbackFcn(app, @onFileTreeSelectionChanged, true);
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
            app.Toolbar.ColumnWidth = {22, '1x'};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 5;
            app.Toolbar.Layout.Column = [1 7];

            % Create tool_ReadFiles
            app.tool_ReadFiles = uiimage(app.Toolbar);
            app.tool_ReadFiles.ScaleMethod = 'none';
            app.tool_ReadFiles.ImageClickedFcn = createCallbackFcn(app, @onFilteTreeAddRequested, true);
            app.tool_ReadFiles.Layout.Row = [1 3];
            app.tool_ReadFiles.Layout.Column = 1;
            app.tool_ReadFiles.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Import_16.png');

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
            app.SubGrid1.ColumnWidth = {22, 150, 22, 22, '1x'};
            app.SubGrid1.RowHeight = {22, 22};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create FileModuleInfo
            app.FileModuleInfo = uilabel(app.SubGrid1);
            app.FileModuleInfo.VerticalAlignment = 'top';
            app.FileModuleInfo.WordWrap = 'on';
            app.FileModuleInfo.FontSize = 11;
            app.FileModuleInfo.FontColor = [0.149 0.149 0.149];
            app.FileModuleInfo.Layout.Row = 1;
            app.FileModuleInfo.Layout.Column = [1 5];
            app.FileModuleInfo.Text = 'Este aplicativo permite a leitura de arquivos gerados em monitorações do espectro de radiofrequências e a sua análise.';

            % Create FileSortMethodIcon
            app.FileSortMethodIcon = uiimage(app.SubGrid1);
            app.FileSortMethodIcon.ScaleMethod = 'none';
            app.FileSortMethodIcon.Layout.Row = 2;
            app.FileSortMethodIcon.Layout.Column = 1;
            app.FileSortMethodIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'sort_az_ascending.png');

            % Create FileSortMethod
            app.FileSortMethod = uidropdown(app.SubGrid1);
            app.FileSortMethod.Items = {'ARQUIVO', 'SENSOR', 'FLUXO ESPECTRAL'};
            app.FileSortMethod.ValueChangedFcn = createCallbackFcn(app, @onFileSortMethodValueChanged, true);
            app.FileSortMethod.FontSize = 10;
            app.FileSortMethod.BackgroundColor = [0.9804 0.9804 0.9804];
            app.FileSortMethod.Layout.Row = 2;
            app.FileSortMethod.Layout.Column = 2;
            app.FileSortMethod.Value = 'FLUXO ESPECTRAL';

            % Create FileTreeExpand
            app.FileTreeExpand = uiimage(app.SubGrid1);
            app.FileTreeExpand.ScaleMethod = 'none';
            app.FileTreeExpand.ImageClickedFcn = createCallbackFcn(app, @onFileTreeExpansionToggleRequest, true);
            app.FileTreeExpand.Enable = 'off';
            app.FileTreeExpand.Layout.Row = 2;
            app.FileTreeExpand.Layout.Column = 3;
            app.FileTreeExpand.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'expand-all.svg');

            % Create FileTreeCollapse
            app.FileTreeCollapse = uiimage(app.SubGrid1);
            app.FileTreeCollapse.ScaleMethod = 'none';
            app.FileTreeCollapse.ImageClickedFcn = createCallbackFcn(app, @onFileTreeExpansionToggleRequest, true);
            app.FileTreeCollapse.Enable = 'off';
            app.FileTreeCollapse.Layout.Row = 2;
            app.FileTreeCollapse.Layout.Column = 4;
            app.FileTreeCollapse.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'collapse-all.svg');

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'FILTRO';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {320, 22, 320};
            app.SubGrid2.RowHeight = {22, 22};
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create FileFilterType
            app.FileFilterType = uidropdown(app.SubGrid2);
            app.FileFilterType.Items = {'Descrição', 'Faixa de frequência', 'Id', 'Receptor'};
            app.FileFilterType.ValueChangedFcn = createCallbackFcn(app, @onFileFilterTypeSelectionChanged, true);
            app.FileFilterType.FontSize = 11;
            app.FileFilterType.BackgroundColor = [1 1 1];
            app.FileFilterType.Layout.Row = 1;
            app.FileFilterType.Layout.Column = 1;
            app.FileFilterType.Value = 'Descrição';

            % Create FileFilterValueText
            app.FileFilterValueText = uieditfield(app.SubGrid2, 'text');
            app.FileFilterValueText.FontSize = 11;
            app.FileFilterValueText.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterValueText.Layout.Row = 2;
            app.FileFilterValueText.Layout.Column = 1;

            % Create FileFilterValueList
            app.FileFilterValueList = uidropdown(app.SubGrid2);
            app.FileFilterValueList.Items = {};
            app.FileFilterValueList.Visible = 'off';
            app.FileFilterValueList.FontSize = 11;
            app.FileFilterValueList.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterValueList.BackgroundColor = [1 1 1];
            app.FileFilterValueList.Layout.Row = 2;
            app.FileFilterValueList.Layout.Column = 1;
            app.FileFilterValueList.Value = {};

            % Create FileFilterAdd
            app.FileFilterAdd = uiimage(app.SubGrid2);
            app.FileFilterAdd.ScaleMethod = 'none';
            app.FileFilterAdd.ImageClickedFcn = createCallbackFcn(app, @onFileFilterAddRequested, true);
            app.FileFilterAdd.Layout.Row = [1 2];
            app.FileFilterAdd.Layout.Column = 2;
            app.FileFilterAdd.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Continue_16.png');

            % Create FileFilterTree
            app.FileFilterTree = uitree(app.SubGrid2);
            app.FileFilterTree.Multiselect = 'on';
            app.FileFilterTree.FontSize = 11;
            app.FileFilterTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FileFilterTree.Layout.Row = [1 2];
            app.FileFilterTree.Layout.Column = 3;

            % Create Tab2_Playback
            app.Tab2_Playback = uitab(app.TabGroup);
            app.Tab2_Playback.AutoResizeChildren = 'off';
            app.Tab2_Playback.Title = 'PLAYBACK';

            % Create Tab3_DriveTest
            app.Tab3_DriveTest = uitab(app.TabGroup);
            app.Tab3_DriveTest.AutoResizeChildren = 'off';
            app.Tab3_DriveTest.Title = 'DRIVETEST';

            % Create Tab4_SignalAnalysis
            app.Tab4_SignalAnalysis = uitab(app.TabGroup);
            app.Tab4_SignalAnalysis.AutoResizeChildren = 'off';
            app.Tab4_SignalAnalysis.Title = 'SIGNALANALYSIS';

            % Create Tab5_RFDataHub
            app.Tab5_RFDataHub = uitab(app.TabGroup);
            app.Tab5_RFDataHub.AutoResizeChildren = 'off';
            app.Tab5_RFDataHub.Title = 'RFDATAHUB';

            % Create Tab6_RepoSFI
            app.Tab6_RepoSFI = uitab(app.TabGroup);
            app.Tab6_RepoSFI.AutoResizeChildren = 'off';
            app.Tab6_RepoSFI.Title = 'REPOSFI';

            % Create Tab7_Config
            app.Tab7_Config = uitab(app.TabGroup);
            app.Tab7_Config.AutoResizeChildren = 'off';
            app.Tab7_Config.Title = 'CONFIG';

            % Create NavBar
            app.NavBar = uigridlayout(app.GridLayout);
            app.NavBar.ColumnWidth = {106, '1x', 34, 5, 34, 34, 34, 5, 34, 34, 34, '1x', 20, 20, 1, 20, 20};
            app.NavBar.RowHeight = {5, 7, 20, 7, 5};
            app.NavBar.ColumnSpacing = 5;
            app.NavBar.RowSpacing = 0;
            app.NavBar.Padding = [10 5 5 5];
            app.NavBar.Tag = 'COLORLOCKED';
            app.NavBar.Layout.Row = 1;
            app.NavBar.Layout.Column = 1;
            app.NavBar.BackgroundColor = [0.2 0.2 0.2];

            % Create AppName
            app.AppName = uilabel(app.NavBar);
            app.AppName.FontSize = 11;
            app.AppName.FontColor = [1 1 1];
            app.AppName.Layout.Row = [1 5];
            app.AppName.Layout.Column = [1 2];
            app.AppName.Interpreter = 'html';
            app.AppName.Text = {'appAnalise v. 2.00.0'; '<font style="font-size: 9px;">R2024a</font>'};

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
            app.Tab1Button.Layout.Column = 3;
            app.Tab1Button.Value = true;

            % Create ButtonsSeparator1
            app.ButtonsSeparator1 = uiimage(app.NavBar);
            app.ButtonsSeparator1.ScaleMethod = 'none';
            app.ButtonsSeparator1.Enable = 'off';
            app.ButtonsSeparator1.Layout.Row = [2 4];
            app.ButtonsSeparator1.Layout.Column = 4;
            app.ButtonsSeparator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab2Button
            app.Tab2Button = uibutton(app.NavBar, 'state');
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'PLAYBACK';
            app.Tab2Button.Tooltip = {'Playback'};
            app.Tab2Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'pulse-24px-white.svg');
            app.Tab2Button.IconAlignment = 'top';
            app.Tab2Button.Text = '';
            app.Tab2Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab2Button.FontSize = 11;
            app.Tab2Button.Layout.Row = [2 4];
            app.Tab2Button.Layout.Column = 5;

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'DRIVETEST';
            app.Tab3Button.Tooltip = {'Drive-test'};
            app.Tab3Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'map-filled-24px-white.svg');
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 6;

            % Create Tab4Button
            app.Tab4Button = uibutton(app.NavBar, 'state');
            app.Tab4Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab4Button.Tag = 'SIGNALANALYSIS';
            app.Tab4Button.Tooltip = {'Análise de sinais'};
            app.Tab4Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'tasklist-24px-white.svg');
            app.Tab4Button.IconAlignment = 'top';
            app.Tab4Button.Text = '';
            app.Tab4Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab4Button.FontSize = 11;
            app.Tab4Button.Layout.Row = [2 4];
            app.Tab4Button.Layout.Column = 7;

            % Create ButtonsSeparator2
            app.ButtonsSeparator2 = uiimage(app.NavBar);
            app.ButtonsSeparator2.ScaleMethod = 'none';
            app.ButtonsSeparator2.Enable = 'off';
            app.ButtonsSeparator2.Layout.Row = [2 4];
            app.ButtonsSeparator2.Layout.Column = 8;
            app.ButtonsSeparator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab5Button
            app.Tab5Button = uibutton(app.NavBar, 'state');
            app.Tab5Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab5Button.Tag = 'RFDATAHUB';
            app.Tab5Button.Tooltip = {'RF.DataHub'};
            app.Tab5Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'database-24px-white.svg');
            app.Tab5Button.IconAlignment = 'top';
            app.Tab5Button.Text = '';
            app.Tab5Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab5Button.FontSize = 11;
            app.Tab5Button.Layout.Row = [2 4];
            app.Tab5Button.Layout.Column = 9;

            % Create Tab6Button
            app.Tab6Button = uibutton(app.NavBar, 'state');
            app.Tab6Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab6Button.Tag = 'REPOSFI';
            app.Tab6Button.Tooltip = {'RF.Fusion'};
            app.Tab6Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'library-24px-white.svg');
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
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 14;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ScaleMethod = 'none';
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 16;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-normal-24px-white.svg');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 17;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'kebab-vertical-24px-white.svg');

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'winAppAnalise';

            % Create ContextMenuDeleteButton
            app.ContextMenuDeleteButton = uimenu(app.ContextMenu);
            app.ContextMenuDeleteButton.MenuSelectedFcn = createCallbackFcn(app, @onContextMenuDeleteOptionClicked, true);
            app.ContextMenuDeleteButton.Text = '❌ Excluir';

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
