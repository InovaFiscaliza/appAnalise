classdef winAppAnalise_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        popupContainerGrid              matlab.ui.container.GridLayout
        SplashScreen                    matlab.ui.control.Image
        menu_Grid                       matlab.ui.container.GridLayout
        DataHubLamp                     matlab.ui.control.Image
        menu_AppName                    matlab.ui.control.Label
        menu_AppIcon                    matlab.ui.control.Image
        AppInfo                         matlab.ui.control.Image
        FigurePosition                  matlab.ui.control.Image
        jsBackDoor                      matlab.ui.control.HTML
        menu_Button8                    matlab.ui.control.StateButton
        menu_Button7                    matlab.ui.control.StateButton
        menu_Button6                    matlab.ui.control.StateButton
        menu_Button5                    matlab.ui.control.StateButton
        menu_Separator2                 matlab.ui.control.Image
        menu_Button4                    matlab.ui.control.StateButton
        menu_Button3                    matlab.ui.control.StateButton
        menu_Button2                    matlab.ui.control.StateButton
        menu_Separator1                 matlab.ui.control.Image
        menu_Button1                    matlab.ui.control.StateButton
        TabGroup                        matlab.ui.container.TabGroup
        Tab1_File                       matlab.ui.container.Tab
        file_Grid                       matlab.ui.container.GridLayout
        TabGroup2                       matlab.ui.container.TabGroup
        ARQUIVOSTab                     matlab.ui.container.Tab
        GridLayout2                     matlab.ui.container.GridLayout
        NOMEDAEMPRESAMetadadosOutrascoisasLabel  matlab.ui.control.Label
        FILTROTab                       matlab.ui.container.Tab
        file_FilteringGrid              matlab.ui.container.GridLayout
        file_FilteringTree              matlab.ui.container.Tree
        file_FilteringAdd               matlab.ui.control.Image
        file_FilteringValue_Frequency   matlab.ui.control.DropDown
        file_FilteringValue_ID          matlab.ui.control.DropDown
        file_FilteringValue_Description  matlab.ui.control.EditField
        file_FilteringType              matlab.ui.control.DropDown
        file_toolGrid                   matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        file_SpecReadButton             matlab.ui.control.Image
        file_OpenFileButton             matlab.ui.control.Image
        file_Metadata                   matlab.ui.control.Label
        file_Tree                       matlab.ui.container.Tree
        Tab2_Playback                   matlab.ui.container.Tab
        play_Grid                       matlab.ui.container.GridLayout
        play_TreeTitleGrid              matlab.ui.container.GridLayout
        play_TreeTitle                  matlab.ui.control.Label
        play_TreeTitleImage             matlab.ui.control.Image
        play_TreeTitleUnderline         matlab.ui.control.Image
        play_TreeLabel                  matlab.ui.control.Label
        play_Tree                       matlab.ui.container.Tree
        play_MetadataLabel              matlab.ui.control.Label
        play_Metadata                   matlab.ui.control.Label
        play_toolGrid                   matlab.ui.container.GridLayout
        tool_LayoutRight                matlab.ui.control.Image
        tool_FiscalizaUpdate            matlab.ui.control.Image
        tool_ReportGenerator            matlab.ui.control.Image
        tool_TimestampLabel             matlab.ui.control.Label
        tool_TimestampSlider            matlab.ui.control.Slider
        tool_LoopControl                matlab.ui.control.Image
        tool_Play                       matlab.ui.control.Image
        tool_LayoutLeft                 matlab.ui.control.Image
        play_ControlsGrid               matlab.ui.container.GridLayout
        submenu_Grid                    matlab.ui.container.GridLayout
        submenu_Button6Grid             matlab.ui.container.GridLayout
        submenu_Button6Icon             matlab.ui.control.Image
        submenu_Button6Label            matlab.ui.control.Label
        submenu_Button4Grid             matlab.ui.container.GridLayout
        submenu_Button4Icon             matlab.ui.control.Image
        submenu_Button4Label            matlab.ui.control.Label
        submenu_Button3Grid             matlab.ui.container.GridLayout
        submenu_Button3Icon             matlab.ui.control.Image
        submenu_Button3Label            matlab.ui.control.Label
        submenu_Button2Grid             matlab.ui.container.GridLayout
        submenu_Button2Icon             matlab.ui.control.Image
        submenu_Button2Label            matlab.ui.control.Label
        submenu_Button1Grid             matlab.ui.container.GridLayout
        submenu_Button1Icon             matlab.ui.control.Image
        submenu_Button1Label            matlab.ui.control.Label
        submenuUnderline                matlab.ui.control.Image
        misc_ControlsTab1Info           matlab.ui.container.GridLayout
        misc_Panel1                     matlab.ui.container.Panel
        misc_Grid1                      matlab.ui.container.GridLayout
        misc_DeleteInvalidSweepsLabel   matlab.ui.control.Label
        misc_DeleteInvalidSweeps        matlab.ui.control.Button
        misc_DeleteAllLabel             matlab.ui.control.Label
        misc_DeleteAll                  matlab.ui.control.Button
        misc_AddCorrectionLabel         matlab.ui.control.Label
        misc_AddCorrection              matlab.ui.control.Button
        misc_EditLocationLabel          matlab.ui.control.Label
        misc_EditLocation               matlab.ui.control.Button
        misc_TimeFilteringLabel         matlab.ui.control.Label
        misc_TimeFiltering              matlab.ui.control.Button
        misc_ImportLabel                matlab.ui.control.Label
        misc_Import                     matlab.ui.control.Button
        misc_ExportLabel                matlab.ui.control.Label
        misc_Export                     matlab.ui.control.Button
        misc_Serarator                  matlab.ui.control.Image
        misc_DelLabel                   matlab.ui.control.Label
        misc_Del                        matlab.ui.control.Button
        misc_MergeLabel                 matlab.ui.control.Label
        misc_Merge                      matlab.ui.control.Button
        misc_DuplicateLabel             matlab.ui.control.Label
        misc_Duplicate                  matlab.ui.control.Button
        misc_SaveLabel                  matlab.ui.control.Label
        misc_Save                       matlab.ui.control.Button
        misc_Label1                     matlab.ui.control.Label
        report_ControlsTab1Info         matlab.ui.container.GridLayout
        report_DetectionManualMode      matlab.ui.control.CheckBox
        report_EditClassification       matlab.ui.control.Hyperlink
        report_EditDetection            matlab.ui.control.Hyperlink
        report_ThreadAlgorithms         matlab.ui.control.Label
        report_ThreadAlgorithmsImage    matlab.ui.control.Image
        report_ThreadAlgorithmsLabel    matlab.ui.control.Label
        report_Tree                     matlab.ui.container.Tree
        report_TreeAddImage             matlab.ui.control.Image
        report_TreeLabel                matlab.ui.control.Label
        report_DocumentPanel            matlab.ui.container.Panel
        report_DocumentGrid             matlab.ui.container.GridLayout
        report_Version                  matlab.ui.control.DropDown
        report_VersionLabel             matlab.ui.control.Label
        report_ModelName                matlab.ui.control.DropDown
        report_AddProjectAttachment     matlab.ui.control.Image
        report_ModelNameLabel           matlab.ui.control.Label
        report_UnitLabel                matlab.ui.control.Label
        report_Unit                     matlab.ui.control.DropDown
        report_Issue                    matlab.ui.control.NumericEditField
        report_IssueLabel               matlab.ui.control.Label
        report_system                   matlab.ui.control.DropDown
        report_systemLabel              matlab.ui.control.Label
        report_DocumentPanelLabel       matlab.ui.control.Label
        report_ProjectName              matlab.ui.control.TextArea
        report_ProjectNew               matlab.ui.control.Image
        report_ProjectSave              matlab.ui.control.Image
        report_ProjectWarnIcon          matlab.ui.control.Image
        report_ProjectNameLabel         matlab.ui.control.Label
        play_ControlsTab3Info           matlab.ui.container.GridLayout
        play_FindPeaks_ExternalFilePanel  matlab.ui.container.Panel
        play_FindPeaks_ExternalFileGrid  matlab.ui.container.GridLayout
        play_FindPeaks_FileTemplate     matlab.ui.control.Hyperlink
        play_FindPeaks_ExternalFile     matlab.ui.control.DropDown
        play_FindPeaks_ExternalFileLabel  matlab.ui.control.Label
        play_FindPeaks_Description      matlab.ui.control.TextArea
        play_FindPeaks_DescriptionLabel  matlab.ui.control.Label
        play_FindPeaks_PeakBW           matlab.ui.control.NumericEditField
        play_FindPeaks_PeakBWLabel      matlab.ui.control.Label
        play_FindPeaks_PeakCF           matlab.ui.control.NumericEditField
        play_FindPeaks_PeakCFLabel      matlab.ui.control.Label
        play_FindPeaks_Tree             matlab.ui.container.Tree
        play_FindPeaks_add              matlab.ui.control.Image
        play_FindPeaks_ParametersPanel  matlab.ui.container.Panel
        play_FindPeaks_ParametersGrid   matlab.ui.container.GridLayout
        play_FindPeaks_MaxHoldPanel     matlab.ui.container.Panel
        play_FindPeaks_MaxHoldGrid      matlab.ui.container.GridLayout
        play_FindPeaks_maxOCC           matlab.ui.control.Spinner
        play_FindPeaks_meanOCC          matlab.ui.control.Spinner
        play_FindPeaks_OCCLabel         matlab.ui.control.Label
        play_FindPeaks_Prominence2      matlab.ui.control.Spinner
        play_FindPeaks_Prominence2Label  matlab.ui.control.Label
        play_FindPeaks_MeanPanel        matlab.ui.container.Panel
        play_FindPeaks_MeanGrid         matlab.ui.container.GridLayout
        play_FindPeaks_Prominence1      matlab.ui.control.Spinner
        play_FindPeaks_Prominence1Label  matlab.ui.control.Label
        play_FindPeaks_BW               matlab.ui.control.Spinner
        play_FindPeaks_BWLabel          matlab.ui.control.Label
        play_FindPeaks_distance         matlab.ui.control.Spinner
        play_FindPeaks_distanceLabel    matlab.ui.control.Label
        play_FindPeaks_Class            matlab.ui.control.DropDown
        play_FindPeaks_ClassLabel       matlab.ui.control.Label
        play_FindPeaks_prominence       matlab.ui.control.Spinner
        play_FindPeaks_prominenceLabel  matlab.ui.control.Label
        play_FindPeaks_THR              matlab.ui.control.Spinner
        play_FindPeaks_THRLabel         matlab.ui.control.Label
        play_FindPeaks_Numbers          matlab.ui.control.Spinner
        play_FindPeaks_NumbersLabel     matlab.ui.control.Label
        play_FindPeaks_Trace            matlab.ui.control.DropDown
        play_FindPeaks_TraceLabel       matlab.ui.control.Label
        play_FindPeaks_Algorithm        matlab.ui.control.DropDown
        play_FindPeaks_AlgorithmLabel   matlab.ui.control.Label
        play_FindPeaks_RadioGroup       matlab.ui.container.ButtonGroup
        play_FindPeaks_File             matlab.ui.control.RadioButton
        play_FindPeaks_DataTips         matlab.ui.control.RadioButton
        play_FindPeaks_ROI              matlab.ui.control.RadioButton
        play_FindPeaks_auto             matlab.ui.control.RadioButton
        play_FindPeaks_Label            matlab.ui.control.Label
        play_ControlsTab2Info           matlab.ui.container.GridLayout
        play_Channel_ShowPlot           matlab.ui.control.Image
        play_BandLimits_Tree            matlab.ui.container.Tree
        play_BandLimits_add             matlab.ui.control.Image
        play_BandLimits_Panel           matlab.ui.container.Panel
        play_BandLimits_Grid            matlab.ui.container.GridLayout
        play_BandLimits_xLim2           matlab.ui.control.NumericEditField
        play_BandLimits_xLabel          matlab.ui.control.Label
        play_BandLimits_xLim1           matlab.ui.control.NumericEditField
        play_BandLimits_Status          matlab.ui.control.CheckBox
        play_Channel_Tree               matlab.ui.container.Tree
        play_Channel_add                matlab.ui.control.Image
        play_Channel_ExternalFilePanel  matlab.ui.container.Panel
        play_Channel_ExternalFileGrid   matlab.ui.container.GridLayout
        play_Channel_FileTemplate       matlab.ui.control.Hyperlink
        play_Channel_ExternalFile       matlab.ui.control.DropDown
        play_Channel_ExternalFileLabel  matlab.ui.control.Label
        play_Channel_Panel              matlab.ui.container.Panel
        play_Channel_Grid               matlab.ui.container.GridLayout
        play_Channel_Sample             matlab.ui.control.Label
        play_Channel_BW                 matlab.ui.control.NumericEditField
        play_Channel_BWLabel            matlab.ui.control.Label
        play_Channel_StepWidth          matlab.ui.control.NumericEditField
        play_Channel_StepWidthLabel     matlab.ui.control.Label
        play_Channel_Class              matlab.ui.control.DropDown
        play_Channel_ClassLabel         matlab.ui.control.Label
        play_Channel_LastChannel        matlab.ui.control.NumericEditField
        play_Channel_LastChannelLabel   matlab.ui.control.Label
        play_Channel_FirstChannel       matlab.ui.control.NumericEditField
        play_Channel_FirstChannelLabel  matlab.ui.control.Label
        play_Channel_nChannels          matlab.ui.control.NumericEditField
        play_Channel_nChannelsLabel     matlab.ui.control.Label
        play_Channel_Name               matlab.ui.control.EditField
        play_Channel_List               matlab.ui.control.DropDown
        play_Channel_ListUpdate         matlab.ui.control.Image
        play_Channel_ListLabel          matlab.ui.control.Label
        play_Channel_RadioGroup         matlab.ui.container.ButtonGroup
        play_Channel_File               matlab.ui.control.RadioButton
        play_Channel_Single             matlab.ui.control.RadioButton
        play_Channel_Multiples          matlab.ui.control.RadioButton
        play_Channel_ReferenceList      matlab.ui.control.RadioButton
        play_Channel_Label              matlab.ui.control.Label
        play_ControlsTab1Info           matlab.ui.container.GridLayout
        play_Customization              matlab.ui.control.CheckBox
        play_Waterfall_Panel            matlab.ui.container.Panel
        play_WaterFallGrid              matlab.ui.container.GridLayout
        play_Waterfall_cLim_Grid2       matlab.ui.container.GridLayout
        play_Waterfall_cLim2            matlab.ui.control.Spinner
        play_Waterfall_cLim_Separation  matlab.ui.control.Label
        play_Waterfall_cLim1            matlab.ui.control.Spinner
        play_Waterfall_cLim_Mode        matlab.ui.control.Image
        play_Waterfall_cLim_Label       matlab.ui.control.Label
        play_Waterfall_MeshStyle        matlab.ui.control.DropDown
        play_Waterfall_MeshStyleLabel   matlab.ui.control.Label
        play_Waterfall_Colormap         matlab.ui.control.DropDown
        play_Waterfall_ColormapLabel    matlab.ui.control.Label
        play_Waterfall_Colorbar         matlab.ui.control.DropDown
        play_Waterfall_ColorbarLabel    matlab.ui.control.Label
        play_Waterfall_Timeline         matlab.ui.control.DropDown
        play_Waterfall_TimelineLabel    matlab.ui.control.Label
        play_Waterfall_Decimation       matlab.ui.control.DropDown
        play_Waterfall_DecimationValue  matlab.ui.control.Label
        play_Waterfall_DecimationLabel  matlab.ui.control.Label
        play_Waterfall_Fcn              matlab.ui.control.DropDown
        play_Waterfall_FcnLabel         matlab.ui.control.Label
        play_OCC_Panel                  matlab.ui.container.Panel
        play_OCCGrid                    matlab.ui.container.GridLayout
        play_OCC_noisePanel             matlab.ui.container.Panel
        play_OCC_noiseGrid              matlab.ui.container.GridLayout
        play_OCC_noiseUsefulSamples     matlab.ui.control.Spinner
        play_OCC_noiseUsefulSamplesLabel  matlab.ui.control.Label
        play_OCC_noiseTrashSamples      matlab.ui.control.Spinner
        play_OCC_noiseTrashSamplesLabel  matlab.ui.control.Label
        play_OCC_noiseFcn               matlab.ui.control.DropDown
        play_OCC_noiseFcnLabel          matlab.ui.control.Label
        play_OCC_noiseLabel             matlab.ui.control.Label
        play_OCC_ceilFactor             matlab.ui.control.DropDown
        play_OCC_ceilFactorLabel        matlab.ui.control.Label
        play_OCC_Offset                 matlab.ui.control.Spinner
        play_OCC_OffsetLabel            matlab.ui.control.Label
        play_OCC_THRCaptured            matlab.ui.control.DropDown
        play_OCC_THR                    matlab.ui.control.Spinner
        play_OCC_THRLabel               matlab.ui.control.Label
        play_OCC_Orientation            matlab.ui.control.DropDown
        play_OCC_OrientationLabel       matlab.ui.control.Label
        play_OCC_IntegrationTimeCaptured  matlab.ui.control.NumericEditField
        play_OCC_IntegrationTime        matlab.ui.control.DropDown
        play_OCC_IntegrationTimeLabel   matlab.ui.control.Label
        play_OCC_Method                 matlab.ui.control.DropDown
        play_OCC_MethodLabel            matlab.ui.control.Label
        play_Persistance_Panel          matlab.ui.container.Panel
        play_PersistanceGrid            matlab.ui.container.GridLayout
        play_Persistance_cLim_Grid2     matlab.ui.container.GridLayout
        play_Persistance_cLim_Separation  matlab.ui.control.Label
        play_Persistance_cLim2          matlab.ui.control.Spinner
        play_Persistance_cLim1          matlab.ui.control.Spinner
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
        play_ControlsPanel              matlab.ui.container.ButtonGroup
        play_RadioButton_Waterfall      matlab.ui.control.RadioButton
        play_RadioButton_Occupancy      matlab.ui.control.RadioButton
        play_RadioButton_Persistance    matlab.ui.control.RadioButton
        play_ControlPanelLabel          matlab.ui.control.Label
        play_GeneralPanel               matlab.ui.container.Panel
        play_OthersGrid                 matlab.ui.container.GridLayout
        play_LimitsPanel                matlab.ui.container.Panel
        play_LimitsGrid                 matlab.ui.container.GridLayout
        play_Limits_yLim2               matlab.ui.control.Spinner
        play_Limits_yLimLabel           matlab.ui.control.Label
        play_Limits_yLim1               matlab.ui.control.Spinner
        play_Limits_xLim2               matlab.ui.control.Spinner
        play_Limits_xLimLabel           matlab.ui.control.Label
        play_Limits_xLim1               matlab.ui.control.Spinner
        play_LimitsRefresh              matlab.ui.control.Image
        play_LimitsPanelLabel           matlab.ui.control.Label
        play_TraceIntegration           matlab.ui.control.DropDown
        play_TraceIntegrationLabel      matlab.ui.control.Label
        play_MinPlotTime                matlab.ui.control.Spinner
        play_MinPlotTimeLabel           matlab.ui.control.Label
        play_LineVisibility             matlab.ui.control.DropDown
        play_LineVisibilityLabel        matlab.ui.control.Label
        play_LayoutRatio                matlab.ui.control.DropDown
        play_LayoutRatioLabel           matlab.ui.control.Label
        play_GeneralPanelLabel          matlab.ui.control.Label
        play_axesToolbar                matlab.ui.container.GridLayout
        axesTool_RestoreView            matlab.ui.control.Image
        axesTool_Pan                    matlab.ui.control.Image
        axesTool_DataTip                matlab.ui.control.Image
        axesTool_Waterfall              matlab.ui.control.Image
        axesTool_Occupancy              matlab.ui.control.Image
        axesTool_Persistance            matlab.ui.control.Image
        axesTool_MaxHold                matlab.ui.control.Image
        axesTool_Average                matlab.ui.control.Image
        axesTool_MinHold                matlab.ui.control.Image
        play_PlotPanel                  matlab.ui.container.Panel
        Tab3_DriveTest                  matlab.ui.container.Tab
        Tab4_SignalAnalysis             matlab.ui.container.Tab
        Tab5_RFDataHub                  matlab.ui.container.Tab
        Tab6_Config                     matlab.ui.container.Tab
        file_ContextMenu_Tree1          matlab.ui.container.ContextMenu
        file_ContextMenu_delTree1Node   matlab.ui.container.Menu
        file_ContextMenu_Tree2          matlab.ui.container.ContextMenu
        file_ContextMenu_delTree2Node   matlab.ui.container.Menu
        play_FindPeaks_ContextMenu      matlab.ui.container.ContextMenu
        play_FindPeaks_ContextMenu_search  matlab.ui.container.Menu
        play_FindPeaks_ContextMenu_edit  matlab.ui.container.Menu
        play_FindPeaks_ContextMenu_analog  matlab.ui.container.Menu
        play_FindPeaks_ContextMenu_digital  matlab.ui.container.Menu
        play_FindPeaks_ContextMenu_del  matlab.ui.container.Menu
        play_Channel_ContextMenu        matlab.ui.container.ContextMenu
        play_Channel_ContextMenu_addBandLimit  matlab.ui.container.Menu
        play_Channel_ContextMenu_addEmission  matlab.ui.container.Menu
        play_Channel_ContextMenu_del    matlab.ui.container.Menu
        report_ContextMenu              matlab.ui.container.ContextMenu
        report_ContextMenu_del          matlab.ui.container.Menu
        play_BandLimits_ContextMenu     matlab.ui.container.ContextMenu
        play_BandLimits_ContextMenu_del  matlab.ui.container.Menu
    end

    
    properties (Access = public)
        %-----------------------------------------------------------------%
        % PROPRIEDADES COMUNS A TODOS OS APPS
        %-----------------------------------------------------------------%
        General
        General_I

        rootFolder
        entryPointFolder        

        % Essa propriedade registra o tipo de execução da aplicação, podendo
        % ser: 'built-in', 'desktopApp' ou 'webApp'.
        executionMode        

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj

        % Controla a seleção da TabGroup a partir do menu.
        tabGroupController

        % Garante que startup_controller será executada uma única vez.
        rendererFlag = false

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog
        popupContainer

        % Objeto que possibilita integração com o eFiscaliza.
        eFiscalizaObj

        %-----------------------------------------------------------------%
        % PROPRIEDADES ESPECÍFICAS
        %-----------------------------------------------------------------%
        metaData    = model.MetaData.empty
        specData    = model.SpecData.empty
        projectData

        bandObj
        channelObj

        restoreView = struct('ID', {}, 'xLim', {}, 'yLim', {}, 'cLim', {})
        plotFlag    = 0
        plotLayout  = 1
        idxTime     = 1

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


    methods
        %-----------------------------------------------------------------%
        % COMUNICAÇÃO ENTRE PROCESSOS:
        % • ipcMainJSEventsHandler
        %   Eventos recebidos do objeto app.jsBackDoor por meio de chamada 
        %   ao método "sendEventToMATLAB" do objeto "htmlComponent" (no JS).
        %
        % • ipcMainMatlabCallsHandler
        %   Eventos recebidos dos apps secundários.
        %-----------------------------------------------------------------%
        function ipcMainJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    % JSBACKDOOR (compCustomization.js)
                    case 'renderer'
                        if ~app.rendererFlag
                            app.rendererFlag = true;
                            startup_Controller(app)
                        end

                    case 'unload'
                        closeFcn(app)

                    case 'BackgroundColorTurnedInvisible'
                        switch event.HTMLEventData
                            case 'SplashScreen'
                                if isvalid(app.popupContainerGrid)
                                    delete(app.popupContainerGrid)
                                end
                            otherwise
                                error('UnexpectedEvent')
                        end
                    
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

                        idxAuxApp = app.tabGroupController.Components.Tag == auxAppName;
                        hAuxApp   = app.tabGroupController.Components.appHandle{idxAuxApp};
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
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, operationType, varargin)
            varargout = {};

            try
                switch class(callingApp)
                    % CONFIG
                    case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                        switch operationType
                            case 'closeFcn'
                                closeModule(app.tabGroupController, "CONFIG", app.General)
                            case 'dockButtonPushed'
                                auxAppTag = varargin{1};
                                varargout{1} = auxAppInputArguments(app, auxAppTag);
                            case 'checkDataHubLampStatus'
                                DataHubWarningLamp(app)
                            case 'openDevTools'
                                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))
                            otherwise
                                error('UnexpectedCall')
                        end

                    % DRIVETEST
                    case {'auxApp.winDriveTest', 'auxApp.winDriveTest_exported'}
                        switch operationType
                            case 'closeFcn'
                                closeModule(app.tabGroupController, "DRIVETEST", app.General)
                            case 'dockButtonPushed'
                                auxAppTag = varargin{1};
                                varargout{1} = auxAppInputArguments(app, auxAppTag);
                            case {'ChannelParameterChanged', 'ChannelDefault'}
                                play_UpdateAuxiliarApps(app, 'SIGNALANALYSIS')
                            otherwise
                                error('UnexpectedCall')
                        end

                    % RFDATAHUB
                    case {'auxApp.winRFDataHub', 'auxApp.winRFDataHub_exported'}
                        switch operationType
                            case 'closeFcn'
                                closeModule(app.tabGroupController, "RFDATAHUB", app.General)
                            case 'dockButtonPushed'
                                auxAppTag = varargin{1};
                                varargout{1} = auxAppInputArguments(app, auxAppTag);
                            otherwise
                                error('UnexpectedCall')
                        end

                    % SIGNALANALYSIS
                    case {'auxApp.winSignalAnalysis', 'auxApp.winSignalAnalysis_exported'}
                        switch operationType
                            case 'closeFcn'
                                closeModule(app.tabGroupController, "SIGNALANALYSIS", app.General)
                            case 'dockButtonPushed'
                                auxAppTag = varargin{1};
                                varargout{1} = auxAppInputArguments(app, auxAppTag);
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

                                play_FindPeaks_TreeSelectionChanged(app)            
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
                          'auxApp.dockAddKFactor',     'auxApp.dockAddKFactor_exported'}         % MISCELLANEOUS:ADDKFACTOR
                        
                        % Esse ramo do switch trata chamados de módulos auxiliares dos 
                        % modos "REPORT" e "MISCELLANEOUS". Algumas das funcionalidades 
                        % desses módulos requerem atualização do appAnalise:
                        % (a) REPORT: atualização do painel de algoritmos.
                        % (b) MISCELLANEOUS: atualização da visualização da árvore (e 
                        %     aspectos decorrentes desta atualização, como painel de 
                        %     metadados e plots).

                        % O flag "updateFlag" provê essa atualização, e o flag "returnFlag" 
                        % evita que o módulo seja "fechado" (por meio da invisibilidade do 
                        % app.popupContainer.Parent).

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
                            end
                        end

                        if returnFlag
                            return
                        end
                        
                        if ~isempty(app.popupContainer) || isvalid(app.popupContainer)
                            app.popupContainer.Parent.Visible = 0;
                        end
    
                    otherwise
                        error('UnexpectedCall')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));            
            end

            % Caso um app auxiliar esteja em modo DOCK, o progressDialog do
            % app auxiliar coincide com o do appAnalise. Força-se, portanto, 
            % a condição abaixo para evitar possível bloqueio da tela.
            app.progressDialog.Visible = 'hidden';
        end
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor.HTMLSource           = appUtil.jsBackDoorHTMLSource();
            app.jsBackDoor.HTMLEventReceivedFcn = @(~, evt)ipcMainJSEventsHandler(app, evt);
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false, false, false, false];
            end

            switch tabIndex
                case 0
                    sendEventToHTMLSource(app.jsBackDoor, 'startup', app.executionMode);
                    app.progressDialog  = ccTools.ProgressDialog(app.jsBackDoor);
                    customizationStatus = [false, false, false, false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    appName = class(app);

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1 % FILE
                            elToModify = {              ...
                                app.file_Metadata,      ... % ui.TextView
                                app.popupContainerGrid, ...
                                app.file_Tree,          ...
                                app.file_FilteringTree, ...
                                app.NOMEDAEMPRESAMetadadosOutrascoisasLabel ...
                            };

                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);

                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elDataTag{2}, 'style',    struct('backgroundColor', 'rgba(255,255,255,0.65)')), ...
                                    struct('appName', appName, 'dataTag', elDataTag{5}, 'selector', '[class="mwTextNode"]', 'style', struct('textAlign', 'justify')), ...
                                    struct('appName', appName, 'dataTag', elDataTag{3}, 'listener', struct('componentName', 'mainApp.file_Tree', 'keyEvents', {{'Delete', 'Backspace'}})), ...
                                    struct('appName', appName, 'dataTag', elDataTag{4}, 'listener', struct('componentName', 'mainApp.file_FilteringTree',   'keyEvents', {{'Delete', 'Backspace'}}))  ...
                                });
                            end
        
                        case 2 % PLAYBACK-REPORT-MISC
                            elToModify = {                       ...
                                app.play_Metadata,               ... % ui.TextView
                                app.play_axesToolbar,            ...
                                app.play_Channel_Tree,           ...
                                app.play_BandLimits_Tree,        ...
                                app.play_FindPeaks_Tree,         ...
                                app.report_Tree,                 ...
                                app.report_ThreadAlgorithms,     ... % ui.TextView
                                app.report_ThreadAlgorithmsImage ... % ui.TextView (Background image)
                            };

                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);

                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elDataTag{2}, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                                    struct('appName', appName, 'dataTag', elDataTag{3}, 'listener', struct('componentName', 'mainApp.play_Channel_Tree',    'keyEvents', {{'Delete', 'Backspace'}})), ...
                                    struct('appName', appName, 'dataTag', elDataTag{4}, 'listener', struct('componentName', 'mainApp.play_BandLimits_Tree', 'keyEvents', {{'Delete', 'Backspace'}})), ...
                                    struct('appName', appName, 'dataTag', elDataTag{5}, 'listener', struct('componentName', 'mainApp.play_FindPeaks_Tree',  'keyEvents', {{'Delete', 'Backspace'}})), ...
                                    struct('appName', appName, 'dataTag', elDataTag{6}, 'listener', struct('componentName', 'mainApp.report_Tree',          'keyEvents', {{'Delete', 'Backspace'}})), ...
                                });

                                ui.TextView.startup(app.jsBackDoor, elToModify{7}, appName);
                                ui.TextView.startup(app.jsBackDoor, elToModify{8}, appName, 'SELECIONE UM DOS FLUXOS ESPECTRAIS<br>INSERIDOS NA LISTA DE FLUXOS A PROCESSAR');
                            end

                            % Inicialização de componentes que não são renderizados 
                            % inicialmente por estarem em aba invisível.
                            channelList = {};
                            for ii = 1:numel(app.channelObj.Channel)
                                channelList{end+1} = sprintf('%d: %.3f - %.3f MHz (%s)', ii, app.channelObj.Channel(ii).Band(1), ...
                                                                                             app.channelObj.Channel(ii).Band(2),     ...
                                                                                             app.channelObj.Channel(ii).Name);
                            end
                            app.play_Channel_List.Items = channelList;
                            play_Channel_RadioGroupSelectionChanged(app)
                            
                            app.play_FindPeaks_Class.Items = app.channelObj.FindPeaks.Name;
                            play_FindPeaks_ClassValueChanged(app)
                
                            play_FindPeaks_RadioGroupSelectionChanged(app)
                
                            app.play_FindPeaks_Algorithm.Value = 'FindPeaks+OCC';
                            play_FindPeaks_AlgorithmValueChanged(app)
                
                            app.report_Unit.Items      = app.General.ui.unit.options;
                            app.report_ModelName.Items = [{''}; app.General.Models.Name];
                            
                            if app.General.operationMode.Simulation
                                app.report_system.Value = app.report_system.Items{end};
                            end

                        otherwise
                            % Customização dos módulos que são renderizados
                            % nesta figura são controladas pelos próprios
                            % módulos.
                    end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO DO APP
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
            
            % Essa propriedade registra o tipo de execução da aplicação, podendo
            % ser: 'built-in', 'desktopApp' ou 'webApp'.
            app.executionMode = appUtil.ExecutionMode(app.UIFigure);
            if ~strcmp(app.executionMode, 'webApp')
                app.FigurePosition.Visible = 1;
                appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
            end

            % Identifica o local deste arquivo .MLAPP, caso se trate das versões 
            % "built-in" ou "webapp", ou do .EXE relacionado, caso se trate da
            % versão executável (neste caso, o ctfroot indicará o local do .MLAPP).
            appName = class.Constants.appName;
            MFilePath = fileparts(mfilename('fullpath'));
            app.rootFolder = appUtil.RootFolder(appName, MFilePath);

            % Customizações...
            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)
            pause(.100)

            % Inicia operações de gerar tela inicial, customizar componentes e
            % de ler informações constantes em arquivos externos, aplicando-as.
            startup_ConfigFileRead(app, appName, MFilePath)
            startup_AppProperties(app)
            startup_GUIComponents(app)

            sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'SplashScreen', 'componentDataTag', struct(app.SplashScreen).Controller.ViewModel.Id));
            drawnow

            % Por fim, exclui-se o splashscreen.
            if isvalid(app.popupContainerGrid)
                pause(1)
                delete(app.popupContainerGrid)
            end
        end

        %-----------------------------------------------------------------%
        function startup_ConfigFileRead(app, appName, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appUtil.generalSettingsLoad(appName, app.rootFolder);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'error', msgWarning);
            end

            % Para criação de arquivos temporários, cria-se uma pasta da 
            % sessão.
            tempDir = tempname;
            mkdir(tempDir)
            app.General_I.fileFolder.tempPath  = tempDir;
            app.General_I.fileFolder.MFilePath = MFilePath;

            switch app.executionMode
                case 'webApp'
                    % Força a exclusão do SplashScreen do MATLAB Web Server.
                    sendEventToHTMLSource(app.jsBackDoor, "delProgressDialog");

                    % Webapp também não suporta outras janelas, de forma que os 
                    % módulos auxiliares devem ser abertos na própria janela
                    % do appAnalise.
                    app.dockModule_Undock.Visible     = 0;

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

                otherwise    
                    % Resgata a pasta de trabalho do usuário (configurável).
                    userPaths = appUtil.UserPaths(app.General_I.fileFolder.userPath);
                    app.General_I.fileFolder.userPath = userPaths{end};

                    switch app.executionMode
                        case 'desktopStandaloneApp'
                            app.General_I.operationMode.Debug = false;
                        case 'MATLABEnvironment'
                            app.General_I.operationMode.Debug = true;
                    end
            end

            % Especificidades do parser do JSON. 
            if ~strcmp(app.General_I.Plot.Waterfall.Decimation, 'auto')
                app.General_I.Plot.Waterfall.Decimation = 'auto';
            end
        
            if isempty(app.General_I.Merge.Distance)
                app.General_I.Merge.Distance = Inf;
            end
        
            if isempty(app.General_I.Integration.Trace)
                app.General_I.Integration.Trace = Inf;
            end

            % "RFDataHub.mat"
            global RFDataHub
            global RFDataHub_info
        
            if isempty(RFDataHub) || isempty(RFDataHub_info)
                model.RFDataHub.read(appName, app.rootFolder, tempDir)
            end

            % Um dos arquivos que compõem a subpasta "config", copiada para
            % "ProgramData/ANATEL/appAnalise" na primeira execução, é o arquivo 
            % "ReportTemplates.json".
            [projectFolder, programDataFolder] = appUtil.Path(appName, app.rootFolder);
            if isfile(fullfile(programDataFolder, 'ReportTemplates.json'))
                reportTemplateFile = fullfile(programDataFolder, 'ReportTemplates.json');
            else
                reportTemplateFile = fullfile(projectFolder,     'ReportTemplates.json');
            end

            % Leitura de arquivo "IBGE.mat", salvando-o em memória como 
            % variável global.
            [~, msgError] = gpsLib.checkIfIBGEIsGlobal();
            if ~isempty(msgError)
                switch app.executionMode
                    case 'MATLABEnvironment'
                        msgQuestion = sprintf(['Erro na leitura da base de dados "IBGE"\n%s\n\nEsse problema pode ' ...
                                               'ser resolvido mapeando "SupportPackages" no path do MATLAB'], msgError);
                    otherwise
                        msgQuestion = sprintf(['Erro na leitura da base de dados "IBGE"\n%s\n\nEsse problema pode ' ...
                                               'ser resolvido apagando manualmente a pasta %s'], msgError, ctfroot);
                end

                appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'OK'}, 1, 1);
                closeFcn(app)
            end

            app.General            = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            app.General.Models     = struct2table(jsondecode(fileread(reportTemplateFile)));
            app.General.Report     = '';
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.projectData = projectLib(app);
            app.bandObj     = class.Band('appAnalise:PLAYBACK', app);
            app.channelObj  = class.ChannelLib(class.Constants.appName, app.rootFolder);
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            % Cria o objeto que conecta o TabGroup com o GraphicMenu.
            app.tabGroupController = tabGroupGraphicMenu(app.menu_Grid, app.TabGroup, app.progressDialog, @app.jsBackDoor_Customizations, @app.menu_LayoutControl);

            addComponent(app.tabGroupController, "Built-in", "",                         app.menu_Button1, "AlwaysOn", struct('On', 'OpenFile_32Yellow.png',         'Off', 'OpenFile_32White.png'),         matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "Built-in", "",                         app.menu_Button2, "AlwaysOn", struct('On', 'Playback_32Yellow.png',         'Off', 'Playback_32White.png'),         matlab.graphics.GraphicsPlaceholder, 2)
            addComponent(app.tabGroupController, "Built-in", "",                         app.menu_Button3, "AlwaysOn", struct('On', 'Report_32Yellow.png',           'Off', 'Report_32White.png'),           matlab.graphics.GraphicsPlaceholder, 2)
            addComponent(app.tabGroupController, "Built-in", "",                         app.menu_Button4, "AlwaysOn", struct('On', 'Misc_32Yellow.png',             'Off', 'Misc_32White.png'),             matlab.graphics.GraphicsPlaceholder, 2)
            addComponent(app.tabGroupController, "External", "auxApp.winDriveTest",      app.menu_Button5, "AlwaysOn", struct('On', 'DriveTestDensity_32Yellow.png', 'Off', 'DriveTestDensity_32White.png'), app.menu_Button2,                    3)
            addComponent(app.tabGroupController, "External", "auxApp.winSignalAnalysis", app.menu_Button6, "AlwaysOn", struct('On', 'exceptionList_32Yellow.png',    'Off', 'exceptionList_32White.png'),    app.menu_Button2,                    4)
            addComponent(app.tabGroupController, "External", "auxApp.winRFDataHub",      app.menu_Button7, "AlwaysOn", struct('On', 'mosaic_32Yellow.png',           'Off', 'mosaic_32White.png'),           app.menu_Button2,                    5)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",         app.menu_Button8, "AlwaysOn", struct('On', 'Settings_36Yellow.png',         'Off', 'Settings_36White.png'),         app.menu_Button2,                    6)

            % Salva na propriedade "UserData" as opções de ícone e o índice 
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.file_Tree.UserData                    = struct('previousSelectedFileIndex', [], 'previousSelectedFileThread', []);
            app.play_Channel_ShowPlot.UserData        = false;
            
            app.axesTool_Pan.UserData                 = false;
            app.axesTool_DataTip.UserData             = false;
            app.axesTool_MinHold.UserData             = struct('Value', false, 'ImageSource', {{'MinHold_32Filled.png', 'MinHold_32.png'}});
            app.axesTool_Average.UserData             = struct('Value', false, 'ImageSource', {{'Average_32Filled.png', 'Average_32.png'}});
            app.axesTool_MaxHold.UserData             = struct('Value', false, 'ImageSource', {{'MaxHold_32Filled.png', 'MaxHold_32.png'}});
            app.axesTool_Persistance.UserData         = struct('Value', false);
            app.axesTool_Occupancy.UserData           = struct('Value', false);
            app.axesTool_Waterfall.UserData           = struct('Value', false);

            app.play_PlotPanel.UserData               = [];

            % Painel "PLAYBACK > ASPECTOS GERAIS"
            if ismember(num2str(app.General.Integration.Trace), app.play_TraceIntegration.Items)
                app.play_TraceIntegration.Value       = num2str(app.General.Integration.Trace);
            else
                app.General_I.Integration.Trace       = Inf;
                app.General.Integration.Trace         = Inf;
            end

            app.tool_LayoutLeft.UserData              = true;
            app.tool_LayoutRight.UserData             = true;

            % Painel "PLAYBACK > ASPECTOS GERAIS > PERSISTÊNCIA"
            app.play_Persistance_Interpolation.Value  = app.General.Plot.Persistance.Interpolation;
            app.play_Persistance_WindowSize.Value     = app.General.Plot.Persistance.WindowSize;
            app.play_Persistance_WindowSizeValue.Text = app.General.Plot.Persistance.WindowSize;
            app.play_Persistance_Colormap.Value       = app.General.Plot.Persistance.Colormap;
            app.play_Persistance_cLim1.Value          = app.General.Plot.Persistance.LevelLimits(1);
            app.play_Persistance_cLim2.Value          = app.General.Plot.Persistance.LevelLimits(2);
            play_ControlsPanelSelectionChanged(app)

            % Painel "PLAYBACK > ASPECTOS GERAIS > WATERFALL"
            app.play_Waterfall_Fcn.Value              = app.General.Plot.Waterfall.Fcn;
            app.play_Waterfall_Colorbar.Value         = app.General.Plot.Waterfall.Colorbar;
            app.play_Waterfall_Decimation.Value       = app.General.Plot.Waterfall.Decimation;
            app.play_Waterfall_MeshStyle.Value        = app.General.Plot.Waterfall.MeshStyle;
            app.play_Waterfall_Timeline.Value         = app.General.Plot.WaterfallTime.Visible;
            app.play_Waterfall_Colormap.Value         = app.General.Plot.Waterfall.Colormap;
            app.play_Waterfall_cLim1.Value            = app.General.Plot.Waterfall.LevelLimits(1);
            app.play_Waterfall_cLim2.Value            = app.General.Plot.Waterfall.LevelLimits(2);

            % Painel "PLAYBACK > CANAIS"
            app.report_ThreadAlgorithms.UserData = struct('idxThread', [], 'id', '');

            DataHubWarningLamp(app)
        end

        %-----------------------------------------------------------------%
        function DataHubWarningLamp(app)
            if isfolder(app.General.fileFolder.DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
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
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % TABGROUPCONTROLLER
        %-----------------------------------------------------------------%
        function hAuxApp = auxAppHandle(app, auxAppName)
            arguments
                app
                auxAppName string {mustBeMember(auxAppName, ["DRIVETEST", "SIGNALANALYSIS", "RFDATAHUB", "CONFIG"])}
            end

            hAuxApp = app.tabGroupController.Components.appHandle{app.tabGroupController.Components.Tag == auxAppName};
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
                                                                 'FILTRAR FLUXO(S)',           ...
                                                                 'EDITAR LOCAL',               ...
                                                                 'APLICAR CORREÇÃO',           ...
                                                                 'EXCLUIR VARREDURAS INVÁLIDAS'})}
            end

            userSelection = 'Sim';

            if checkStatusModule(app.tabGroupController, 'DRIVETEST') || checkStatusModule(app.tabGroupController, 'SIGNALANALYSIS')
                msgQuestion   = sprintf(['A operação "%s" demanda que os módulos auxiliares "DRIVETEST" e "SIGNALANALYSIS" sejam fechados, '        ...
                                         'caso abertos, pois as informações espectrais consumidas por esses módulos poderão ficar desatualizadas. ' ...
                                         'Deseja continuar?'], operationType);
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

                if userSelection == "Sim"
                    closeModule(app.tabGroupController, 'DRIVETEST',      app.General)
                    closeModule(app.tabGroupController, 'SIGNALANALYSIS', app.General)
                end
            end
        end
    end


    methods (Access = private)
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

            appUtil.modalWindow(app.UIFigure, modalWindowIcon, modalWindowMessage);
            app.progressDialog.Visible = 'hidden';
        end

        %------------------------------------------------------------------------%
        function report_sendJSONFileToSharepoint(app)
            JSONFile = app.projectData.generatedFiles.lastTableFullPath;            
            [status, msg] = copyfile(JSONFile, app.General.fileFolder.DataHub_POST, 'f');

            if ~status
                appUtil.modalWindow(app.UIFigure, 'error', msg);
            end
        end
    end


    methods
        %-----------------------------------------------------------------%
        % CUSTOMIZAÇÃO DECORRENTE DA TROCA DO MODO DE OPERAÇÃO
        %-----------------------------------------------------------------%
        function menu_LayoutControl(app, tabIndex)
            if tabIndex ~= 2
                return
            end

            if app.menu_Button2.Value
                set(app.play_Tree, 'SelectedNodes', app.play_PlotPanel.UserData, 'Multiselect', 'off')
                play_submenuButtonPushed(app, struct('Source', app.submenu_Button1Icon))

            elseif app.menu_Button3.Value
                app.play_Tree.Multiselect = "on";
                play_submenuButtonPushed(app, struct('Source', app.submenu_Button4Icon))

                if isempty(app.report_ThreadAlgorithms.UserData.idxThread) || ~isequal(app.report_ThreadAlgorithms.UserData.idxThread, app.play_PlotPanel.UserData)
                    app.report_Tree.SelectedNodes = [];
                    report_Algorithms(app, app.play_PlotPanel.UserData.NodeData)
                end

            elseif app.menu_Button4.Value
                app.play_Tree.Multiselect = "on";
                play_submenuButtonPushed(app, struct('Source', app.submenu_Button6Icon))
            end
        end

        %-----------------------------------------------------------------%
        function menu_LayoutPopupApp(app, auxiliarApp, varargin)
            arguments
                app
                auxiliarApp char {mustBeMember(auxiliarApp, {'Detection', 'Classification', 'AddFiles', 'TimeFiltering', 'EditLocation', 'AddKFactor', 'AddChannel'})}
            end

            arguments (Repeating)
                varargin 
            end

            % Inicialmente ajusta as dimensões do container.
            switch auxiliarApp
                case 'Detection';      screenWidth  = 412; screenHeight = 282;
                case 'Classification'; screenWidth  = 534; screenHeight = 248;
                case 'AddFiles';       screenWidth  = 880; screenHeight = 480;
                case 'TimeFiltering';  screenWidth  = 640; screenHeight = 480;
                case 'EditLocation';   screenWidth  = 394; screenHeight = 194;
                case 'AddKFactor';     screenWidth  = 480; screenHeight = 360;
                case 'AddChannel';     screenWidth  = 560; screenHeight = 480;
            end

            ui.PopUpContainer(app, class.Constants.appName, screenWidth, screenHeight)

            % Executa o app auxiliar.
            inputArguments = [{app}, varargin];
            
            if ~isempty(app.General) && app.General.operationMode.Debug
                eval(sprintf('auxApp.dock%s(inputArguments{:})', auxiliarApp))
            else
                eval(sprintf('auxApp.dock%s_exported(app.popupContainer, inputArguments{:})', auxiliarApp))
                app.popupContainer.Parent.Visible = 1;
            end            
        end


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
            d = appUtil.modalWindow(app.UIFigure, 'progressdlg', 'Em andamento a leitura de metadados do(s) arquivo(s) selecionado(s).');            
            
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
                            appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                            continue
                            
                        elseif any(strcmpi(fileFullPath, {app.metaData.File}))
                            msgWarning = sprintf('O arquivo indicado a seguir já tinha sido lido.\n•&thinsp;%s', fileName{ii});
                            appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);                            
                            continue
                            
                        elseif any(contains(relatedFiles, prj_RelatedFiles, 'IgnoreCase', true))
                            msgWarning = sprintf(['O arquivo indicado a seguir não será lido por já ter sido lido ao menos um arquivo relacionado ao ' ...
                                           'projeto appAnalise.\n•&thinsp;%s\n\nArquivo(s) relacionado(s) ao projeto appAnalise já lido(s):\n%s'],   ...
                                           fileName{ii}, strjoin(cellfun(@(x) sprintf('•&thinsp;%s', x), relatedFiles(contains(relatedFiles, prj_RelatedFiles, 'IgnoreCase', true)), 'UniformOutput', false), '\n'));
                            appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);                            
                            continue

                        elseif ~isempty(app.metaData) && strcmp(prj_Type, 'Project data') && ismember('Project data', {app.metaData.Type})
                            msgWarning = sprintf('O arquivo indicado a seguir não será lido porque já foram lidos os metadados de outro projeto appAnalise.\n•&thinsp;%s', fileName{ii});
                            appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);                            
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
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
            end

            if ~isempty(emptyFiles)
                msgWarning = sprintf('Os arquivos indicados a seguir não possuem informação espectral.\n%s',   strjoin(strcat('•&thinsp;', emptyFiles),    '\n'));
                appUtil.modalWindow(app.UIFigure, 'error', msgWarning);
            end

            file_TreeBuilding(app)
        end

        %-----------------------------------------------------------------%
        function file_TreeBuilding(app)
            if ~isempty(app.file_Tree.Children)
                delete(app.file_Tree.Children)
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

            app.file_FilteringValue_Frequency.Items = unique(bandList.Band, "rows", "stable");
            app.file_FilteringValue_ID.Items        = unique(string(sort(IDList)), "rows", "stable");
        end

        %-----------------------------------------------------------------%
        function file_FilterCheck(app)
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

            set(findobj(app.menu_Grid, 'Type', 'uistatebutton'), 'Enable', 0)
            set(app.menu_Button1, 'Enable', 1, 'Value', 1)
            app.menu_Button7.Enable = 1;
            app.menu_Button8.Enable = 1;

            menu_mainButtonPushed(app, struct('Source', app.menu_Button1, 'PreviousValue', false)) 
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
                        uitreenode(specNode, 'Text',     'GPS', ...
                                             'NodeData', jj,    ...
                                             'Icon',     'Warn_18.png');
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
                hSignalAnalysis = auxAppHandle(app, 'SIGNALANALYSIS');
                if ~isempty(hSignalAnalysis) && isvalid(hSignalAnalysis)
                    ipcSecundaryMatlabCallsHandler(hSignalAnalysis, app)
                end
            end

            if ismember(auxAppToUpdate, {'All', 'DRIVETEST'})
                hDriveTest = auxAppHandle(app, 'DRIVETEST');
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

            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General_I, app.executionMode)
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
            [fileFullPath, ~, fileExt] = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
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
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
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
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
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
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Apenas seleção', 'Todos', 'Cancelar'}, 1, 3);
                switch userSelection
                    case 'Todos'
                        idx = 1:numel(app.specData);
                    case 'Cancelar'
                        return
                end
            end

            nameFormatMap = {'*.mat', 'appAnalise (*.mat)'};
            defaultName   = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'UserData', -1); 
            fileFullPath  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end
            
            misc_ExportDataToFile(app, fileFullPath, '.mat', 'UserData', app.specData(idx), struct.empty, {'Data', 'callingApp', 'sortType'})
        end

        %-----------------------------------------------------------------%
        function fileFullPath = misc_ImportUserData(app, idx)
            if numel(idx) < numel(app.specData)
                msgQuestion   = 'Você deseja importar a lista de emissões apenas para os fluxos espectrais selecionados ou para todos os fluxos espectrais?';
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Apenas seleção', 'Todos', 'Cancelar'}, 1, 3);
                switch userSelection
                    case 'Todos'
                        idx = 1:numel(app.specData);
                    case 'Cancelar'
                        return
                end
            end

            [fileFullPath, fileFolder] = appUtil.modalWindow(app.UIFigure, 'uigetfile', '', {'*.mat', 'appAnalise (*.mat)'}, app.General.fileFolder.lastVisited);
            if isempty(fileFullPath)
                return
            end
            misc_updateLastVisitedFolder(app, fileFolder)
            
            util.importAnalysis(app, app.specData(idx), fileFullPath);
        end

        %-----------------------------------------------------------------%
        function misc_DeleteInvalidSweepsController(app, idx)

        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            try
                % WARNING MESSAGES
                appUtil.disablingWarningMessages()

                % <GUI>
                app.UIFigure.Position(4) = 660;

                app.popupContainerGrid.Layout.Row = [1,2];
                app.GridLayout.RowHeight(end) = [];

                app.menu_AppName.Text = sprintf('%s v. %s\n<font style="font-size: 9px;">%s</font>', ...
                    class.Constants.appName, class.Constants.appVersion, class.Constants.appRelease);
                % </GUI>

                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            if strcmp(app.progressDialog.Visible, 'visible')
                app.progressDialog.Visible = 'hidden';
            end

            if ~strcmp(app.executionMode, 'webApp')
                projectName = char(app.report_ProjectName.Value);
                if ~isempty(projectName) && app.report_ProjectWarnIcon.Visible
                    msgQuestion = sprintf(['O projeto aberto - registrado no arquivo <b>"%s"</b> - foi alterado.\n\n' ...
                                           'Deseja descartar essas alterações? Caso não, favor salvá-las no modo RELATÓRIO.'], projectName);
                else
                    msgQuestion = 'Deseja fechar o aplicativo?';
                end
    
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            % Aspectos gerais (comum em todos os apps):
            appUtil.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)
            
        end

        % Value changed function: menu_Button1, menu_Button2, 
        % ...and 6 other components
        function menu_mainButtonPushed(app, event)

            clickedButton  = event.Source;
            auxAppName     = clickedButton.Tag;
            inputArguments = auxAppInputArguments(app, auxAppName);
            openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, inputArguments{:})
            
        end

        % Image clicked function: AppInfo, FigurePosition
        function menu_ToolbarImageCliced(app, event)

            switch event.Source
                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appUtil.winPosition(app.UIFigure)

                case app.AppInfo
                    if isempty(app.AppInfo.Tag)
                        app.progressDialog.Visible = 'visible';
                        app.AppInfo.Tag = util.HtmlTextGenerator.AppInfo(app.General, app.rootFolder, app.executionMode, "popup");
                        app.progressDialog.Visible = 'hidden';
                    end

                    msgInfo = app.AppInfo.Tag;
                    appUtil.modalWindow(app.UIFigure, 'info', msgInfo);
            end

        end

        % Image clicked function: file_OpenFileButton
        function file_ButtonPushed_OpenFile(app, event)

            if app.General.operationMode.Simulation
                app.General.operationMode.Simulation = false;
                
                [projectFolder, ...
                 programDataFolder] = appUtil.Path(class.Constants.appName, app.rootFolder);
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
                [~, filePath, ~, fileName] = appUtil.modalWindow(app.UIFigure, 'uigetfile', '', ...
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
                appUtil.modalWindow(app.UIFigure, 'warning', 'Não há fluxo de informação a ser lido...');
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
                d = appUtil.modalWindow(app.UIFigure, 'progressdlg', 'Em andamento...');
                app.specData = spectrumRead(app.specData, app.metaData, app, d);

                if isempty(app.UIAxes1)
                    startup_Axes(app)
                end
    
                % Habilita botões do menu principal - PLAYBACK, REPORT e MISC -
                % abrindo programaticamente o modo PLAYBACK.
                set(app.menu_Button2, 'Enable', 1, 'Value', 1)
                app.menu_Button3.Enable = 1;
                app.menu_Button4.Enable = 1;
                app.menu_Button5.Enable = 1;
                app.menu_Button6.Enable = 1;

                menu_mainButtonPushed(app, struct('Source', app.menu_Button2, 'PreviousValue', false))

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
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
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

        % Image clicked function: submenu_Button1Icon, 
        % ...and 2 other components
        function play_submenuButtonPushed(app, event)
            
            switch event.Source.Tag
                case 'PLAYBACK:GENERAL'
                    submenuColumnWidth     = {'1x',22,22,0,0};
                    submenuUnderlineColumn = 1;
                    app.play_ControlsGrid.RowHeight(2:6) = {'1x',0,0,0,0};
                    
                    app.submenu_Button1Grid.ColumnWidth = {18,'1x'};
                    app.submenu_Button2Grid.ColumnWidth = {18,0};
                    app.submenu_Button3Grid.ColumnWidth = {18,0};
                
                case 'PLAYBACK:CHANNEL'
                    submenuColumnWidth     = {22,'1x',22,0,0};
                    submenuUnderlineColumn = 2;
                    app.play_ControlsGrid.RowHeight(2:6) = {0,'1x',0,0,0};

                    app.submenu_Button1Grid.ColumnWidth = {18,0};
                    app.submenu_Button2Grid.ColumnWidth = {18,'1x'};
                    app.submenu_Button3Grid.ColumnWidth = {18,0};
                
                case 'PLAYBACK:EMISSION'
                    submenuColumnWidth     = {22,22,'1x',0,0};
                    submenuUnderlineColumn = 3;
                    app.play_ControlsGrid.RowHeight(2:6) = {0,0,'1x',0,0};

                    app.submenu_Button1Grid.ColumnWidth = {18,0};
                    app.submenu_Button2Grid.ColumnWidth = {18,0};
                    app.submenu_Button3Grid.ColumnWidth = {18,'1x'};
                
                case 'REPORT:GENERAL'
                    submenuColumnWidth     = {0,0,0,'1x',0};
                    submenuUnderlineColumn = 4;
                    app.play_ControlsGrid.RowHeight(2:6) = {0,0,0,'1x',0};

                    app.submenu_Button4Grid.ColumnWidth = {18,'1x'};

                case 'MISC:GENERAL'
                    submenuColumnWidth     = {0,0,0,0,'1x'};
                    submenuUnderlineColumn = 5;
                    app.play_ControlsGrid.RowHeight(2:6) = {0,0,0,0,'1x'};
            end

            app.submenu_Grid.ColumnWidth       = submenuColumnWidth;
            app.submenuUnderline.Layout.Column = submenuUnderlineColumn;

        end

        % Image clicked function: tool_LayoutLeft, tool_LayoutRight
        function play_PanelsVisibility(app, event)
            
            event.Source.UserData = ~event.Source.UserData;

            switch event.Source
                case app.tool_LayoutLeft
                    if app.tool_LayoutLeft.UserData
                        app.play_Grid.ColumnWidth(2:3) = {320, 10};
                        app.tool_LayoutLeft.ImageSource = 'ArrowLeft_32.png';
                    else
                        app.play_Grid.ColumnWidth(2:3) = {0, 0};
                        app.tool_LayoutLeft.ImageSource = 'ArrowRight_32.png';
                    end

                case app.tool_LayoutRight
                    if app.tool_LayoutRight.UserData
                        app.play_Grid.ColumnWidth(end-2:end-1) = {10, 320};
                        app.tool_LayoutRight.ImageSource = 'ArrowRight_32.png';
                    else
                        app.play_Grid.ColumnWidth(end-2:end-1) = {0, 0};
                        app.tool_LayoutRight.ImageSource = 'ArrowLeft_32.png';
                    end
            end

        end

        % Selection changed function: play_Tree
        function play_TreeSelectionChanged(app, event)
            
            % De forma geral, espera-se que exista ao menos um nó da árvore
            % selecionado. Caso ocorra um BUG, a condição abaixo assegura 
            % que o app volte a operar como é esperado.
            if isempty(app.play_Tree.SelectedNodes)
                app.play_Tree.SelectedNodes = app.play_Tree.Children(1).Children(1);
            end

            idx = unique([app.play_Tree.SelectedNodes.NodeData]);

            % Será desenhado o plot nas seguintes hipóteses:
            % (a) Inicialização;
            % (b) Altera seleção de fluxo espectral;
            % (c) Busca emissões.
            renderFlag = true;
            if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData) && ismember(app.play_PlotPanel.UserData.NodeData, idx)
                renderFlag = false;
            end

            if renderFlag
                idx = idx(1);

                % Edita-se a estética dos nós da árvore, de forma a destacar
                % o nó selecionado.
                play_changingTreeNodeStyleFromPlayback(app, idx)

                % Em relação ao FLUXO ANTERIORMENTE SELECIONADO, atualiza-se
                % o controle de customização do playback, caso habilitado.
                if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData) && ~isequal(app.play_PlotPanel.UserData.NodeData, idx)
                    play_CustomizationValueChanged(app)
                end

                % Ao plotar dados relacionados a um fluxo de espectro, salva-se
                % o handle do nó selecionado da árvore na propriedade "UserData"
                % do painel app.play_PlotPanel. A propriedade "NodeData" deste 
                % nó armazena o índice do app.specData.
                if app.plotFlag
                    if ~isequal(app.play_PlotPanel.UserData.NodeData, idx)
                        % Ao fazer app.plotFlag = -1, o plot será atualizado, 
                        % mas não a partir daqui, mas do método plot_mainLoop(app)
                        app.plotFlag = -1;
                    end

                else
                    plot_startupFcn(app, idx)
                    plot_Draw(app, idx)
                end
            end

            % Aspectos relacionados a modos auxiliares - inicialmente, necessário 
            % apenas p/ modo REPORT (app.menu_Button3).
            if app.menu_Button3.Value
                app.report_Tree.SelectedNodes = [];
                report_Algorithms(app, app.play_PlotPanel.UserData.NodeData)
            end
            drawnow
            
        end

        % Image clicked function: axesTool_Average, axesTool_DataTip, 
        % ...and 7 other components
        function play_AxesToolbarCallbacks(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;

            switch event.Source
                case app.axesTool_RestoreView
                    plot.axes.Interactivity.CustomRestoreViewFcn(app.UIAxes1, [app.UIAxes2, app.UIAxes3], app)

                case app.axesTool_Pan
                    app.axesTool_Pan.UserData = ~app.axesTool_Pan.UserData;
                    if app.axesTool_Pan.UserData
                        app.axesTool_Pan.ImageSource = 'Pan_32Filled.png';
                        if app.axesTool_DataTip.UserData
                            play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_DataTip))
                        end
                    else
                        app.axesTool_Pan.ImageSource = 'Pan_32.png';
                    end

                    plot.axes.Interactivity.CustomPanFcn(struct('Value', app.axesTool_Pan.UserData), app.UIAxes1, [app.UIAxes2, app.UIAxes3]);

                case app.axesTool_DataTip
                    app.axesTool_DataTip.UserData = ~app.axesTool_DataTip.UserData;
                    if app.axesTool_DataTip.UserData
                        app.axesTool_DataTip.ImageSource = 'DataTip_22Filled.png';
                    else
                        app.axesTool_DataTip.ImageSource = 'DataTip_22.png';
                    end

                    plot.axes.Interactivity.DataCursorMode(app.UIAxes3, app.axesTool_DataTip.UserData)

                case {app.axesTool_MinHold, app.axesTool_Average, app.axesTool_MaxHold}
                    event.Source.UserData.Value = ~event.Source.UserData.Value;
                    if event.Source.UserData.Value
                        event.Source.ImageSource = event.Source.UserData.ImageSource{1};

                        hObject = plot.draw2D.OrdinaryLine(app.UIAxes1, app.bandObj, idx, event.Source.Tag);
                        plot.datatip.Template(hObject, 'Frequency+Level', app.bandObj.LevelUnit)
                        plot.axes.StackingOrder.execute(app.UIAxes1, app.bandObj.Context)
            
                        eval(sprintf('app.h%s = hObject;', event.Source.Tag));

                    else
                        event.Source.ImageSource = event.Source.UserData.ImageSource{2};
                        plot_deleteLines(app, event.Source.Tag)
                    end

                case app.axesTool_Persistance
                    app.axesTool_Persistance.UserData.Value = ~app.axesTool_Persistance.UserData.Value;
                    if app.axesTool_Persistance.UserData.Value
                        app.play_RadioButton_Persistance.Value = 1;
                        play_ControlsPanelSelectionChanged(app)

                        prePlot_updatingGeneralSettings(app)
                        prePlot_updatingCustomProperties(app, idx)
                        plot_Draw_Persistance(app, 'Creation', idx)
                    else
                        plot_Draw_Persistance(app, 'Delete', -1)
                    end

                case app.axesTool_Occupancy
                    app.axesTool_Occupancy.UserData.Value = ~app.axesTool_Occupancy.UserData.Value;
                    if app.axesTool_Occupancy.UserData.Value
                        app.play_RadioButton_Occupancy.Value = 1;
                        play_ControlsPanelSelectionChanged(app)

                        occIndex = play_OCCIndex(app, idx, 'PLAYBACK/REPORT');
                        plot.old_OCC(app, idx, 'Creation', occIndex)
                    else
                        plot.old_OCC(app, idx, 'Delete', -1)
                    end
                    play_OCCLayoutVisibility(app, app.bandObj.LevelUnit)

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value, app.play_LayoutRatio)

                case app.axesTool_Waterfall
                    app.axesTool_Waterfall.UserData.Value = ~app.axesTool_Waterfall.UserData.Value;
                    if app.axesTool_Waterfall.UserData.Value
                        if isempty(app.hWaterfall)
                            plot_Draw_Waterfall(app, idx)
                        else
                            play_Layout_WaterfallPanel(app)
                        end

                        app.play_RadioButton_Waterfall.Value = 1;
                        play_ControlsPanelSelectionChanged(app)
                    else
                        play_Layout_WaterfallPanel(app)
                    end                    

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_Occupancy.UserData.Value, app.axesTool_Waterfall.UserData.Value, app.play_LayoutRatio)
            end
            drawnow

        end

        % Image clicked function: tool_LoopControl, tool_Play
        function play_PlaybackToolbarButtonCallback(app, event)
            
            switch event.Source
                case app.tool_Play
                    idx = [];
                    if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData)
                        idx = app.play_PlotPanel.UserData.NodeData;
                    end
        
                    if ~isempty(idx) && ~app.plotFlag
                        hDriveTest = auxAppHandle(app, 'DRIVETEST');

                        if ~isempty(hDriveTest) && isvalid(hDriveTest) && hDriveTest.plotFlag
                            hDriveTest.plotFlag = 0;
                            hDriveTest.tool_Play.ImageSource = 'play_32.png';
                            drawnow
                        end

                        app.plotFlag = 1;
                        plot_mainLoop(app, idx, numel(app.specData(idx).Data{1}))        
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
        function tool_TimestampSliderValueChanging(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            nSweeps = app.bandObj.nSweeps;
            
            app.idxTime = round(event.Value/100 * nSweeps);
            if app.idxTime < 1
                app.idxTime = 1;
            elseif app.idxTime > nSweeps
                app.idxTime = nSweeps;
            end

            if ~app.plotFlag
                app.hClearWrite.YData = app.specData(idx).Data{2}(:, app.idxTime)';
    
                for ii = 1:numel(app.hEmissionMarkers)
                    app.hEmissionMarkers(ii).Position(2) = app.hClearWrite.YData(app.hClearWrite.MarkerIndices(ii));
                end
                
                plot_Draw_Persistance(app, 'Update', idx)

                if app.axesTool_Waterfall.UserData.Value && ~isempty(app.hWaterfallTime) && strcmp(app.play_Waterfall_Timeline.Value, 'on')
                    plot.draw2D.OrdinaryLineUpdate(app.hWaterfallTime, app.bandObj, idx, 'WaterfallTime');
                end

                app.tool_TimestampLabel.Text = sprintf('%d de %d\n%s', app.idxTime, nSweeps, app.specData(idx).Data{1}(app.idxTime));
            end
            
        end

        % Value changed function: play_LayoutRatio
        function play_ControlButtonPushed(app, event)

            plot.axes.Layout.Visibility([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.play_LayoutRatio.Value, app.bandObj.Context)

        end

        % Value changed function: play_LineVisibility
        function play_LineVisibilityValueChanged(app, event)
            
            app.General_I.Plot.ClearWrite.Visible = app.play_LineVisibility.Value;
            app.General.Plot.ClearWrite.Visible   = app.play_LineVisibility.Value;

            try
                set(app.hClearWrite,      'Visible', app.play_LineVisibility.Value)
                set(app.hEmissionMarkers, 'Visible', app.play_LineVisibility.Value)
            catch
            end

        end

        % Value changed function: play_TraceIntegration
        function play_TraceIntegrationValueChanged(app, event)

            app.General_I.Integration.Trace = str2double(event.Value);
            app.General.Integration.Trace   = str2double(event.Value);

            if isinf(app.General.Integration.Trace) || strcmp(event.PreviousValue, 'Inf')
                if ~isempty(app.hMinHold)
                    plot_deleteLines(app, 'MinHold')
                    play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_MinHold))
                end
    
                if ~isempty(app.hAverage)
                    plot_deleteLines(app, 'Average')
                    play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_Average))
                end
    
                if ~isempty(app.hMaxHold)
                    plot_deleteLines(app, 'MaxHold')
                    play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_MaxHold))
                end
            end

        end

        % Value changed function: play_Limits_xLim1, play_Limits_xLim2
        function play_xLimitsValueChanged(app, event)
            
            FreqRange = app.play_Limits_xLim2.Value - app.play_Limits_xLim1.Value;
            if FreqRange > 0
                app.UIAxes1.XLim = [app.play_Limits_xLim1.Value, app.play_Limits_xLim2.Value];
            else
                switch event.Source.Tag
                    case 'FreqStart'; app.play_Limits_xLim1.Value = event.PreviousValue;
                    case 'FreqStop';  app.play_Limits_xLim2.Value = event.PreviousValue;
                end
            end

        end

        % Value changed function: play_Limits_yLim1, play_Limits_yLim2
        function play_yLimitsValueChanged(app, event)

            LevelRange = app.play_Limits_yLim2.Value - app.play_Limits_yLim1.Value;
            if LevelRange > 0
                app.UIAxes1.YLim = [app.play_Limits_yLim1.Value, app.play_Limits_yLim2.Value];
            else
                switch event.Source.Tag
                    case 'MinLevel'; app.play_Limits_yLim1.Value = event.PreviousValue;
                    case 'MaxLevel'; app.play_Limits_yLim2.Value = event.PreviousValue;
                end
            end

        end

        % Selection changed function: play_ControlsPanel
        function play_ControlsPanelSelectionChanged(app, event)
            
            switch app.play_ControlsPanel.SelectedObject
                case app.play_RadioButton_Persistance; app.play_ControlsTab1Info.RowHeight(5:7) = {'1x',0,0};
                case app.play_RadioButton_Occupancy;   app.play_ControlsTab1Info.RowHeight(5:7) = {0,'1x',0};
                case app.play_RadioButton_Waterfall;   app.play_ControlsTab1Info.RowHeight(5:7) = {0,0,'1x'};
            end
            
        end

        % Value changed function: play_Customization
        function play_CustomizationValueChanged(app, event)
            
            if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData)
                idx = app.play_PlotPanel.UserData.NodeData;
                prePlot_updatingCustomProperties(app, idx)

                if app.play_Customization.Value
                    [ParentTag, DataIndex] = plot.datatip.Search(app.UIFigure);
                    update(app.specData(idx), 'UserData:CustomPlayback', 'DataTip', ParentTag, DataIndex)
                end            
            end            
            
        end

        % Callback function: play_Persistance_Colormap, 
        % ...and 4 other components
        function play_Persistance_Callbacks(app, event)
            
            % Os callbacks aqui descritos são aplicáveis apenas se estiver
            % habilitado o plot Persistance.
            if ~app.axesTool_Persistance.UserData.Value
                return
            end

            switch event.Source
                case app.play_Persistance_cLim_Mode
                    app.UIAxes1.CLimMode = 'auto';
                    app.play_Persistance_cLim1.Value = app.UIAxes1.CLim(1);
                    app.play_Persistance_cLim2.Value = app.UIAxes1.CLim(2);

                    app.UIAxes1.UserData.CLimMode = 'auto';

                otherwise
                    idx = app.play_PlotPanel.UserData.NodeData;
                    
                    prePlot_updatingGeneralSettings(app)
                    prePlot_updatingCustomProperties(app, idx)

                    switch event.Source
                        case app.play_Persistance_Interpolation
                            app.hPersistanceObj.handle.Interpolation = app.play_Persistance_Interpolation.Value;
        
                        case app.play_Persistance_WindowSize
                            plot_Draw_Persistance(app, 'Delete', -1)
                            plot_Draw_Persistance(app, 'Creation', idx)
        
                        case app.play_Persistance_Transparency
                            app.hPersistanceObj.handle.CData(isnan(app.hPersistanceObj.handle.CData)) = 0; 
                            app.hPersistanceObj.handle.AlphaData = double(logical(app.hPersistanceObj.handle.CData)) * app.play_Persistance_Transparency.Value;
        
                        case app.play_Persistance_Colormap
                            plot.axes.Colormap(app.UIAxes1, app.play_Persistance_Colormap.Value)
                    end
            end
            drawnow
            
        end

        % Value changed function: play_Persistance_cLim1, 
        % ...and 1 other component
        function play_Persistance_cLimValueChanged(app, event)

            cLim = [app.play_Persistance_cLim1.Value, app.play_Persistance_cLim2.Value];
            if issorted(cLim, 'strictascend')
                app.UIAxes1.CLim = cLim;
                app.UIAxes1.UserData.CLimMode = 'manual';
            else
                switch event.Source
                    case app.play_Persistance_cLim1; app.play_Persistance_cLim1.Value = event.PreviousValue;
                    case app.play_Persistance_cLim2; app.play_Persistance_cLim2.Value = event.PreviousValue;
                end
            end

        end

        % Callback function: play_Waterfall_Colormap, 
        % ...and 5 other components
        function play_Waterfall_Callbacks(app, event)
            
            % Os callbacks aqui descritos são aplicáveis apenas se estiver
            % habilitado o plot Waterfall.
            if ~app.axesTool_Waterfall.UserData.Value
                return
            end

            app.progressDialog.Visible = 'visible';

            idx = app.play_PlotPanel.UserData.NodeData;
            switch event.Source
                %---------------------------------------------------------%
                case {app.play_Waterfall_Fcn, app.play_Waterfall_Decimation}
                    prePlot_updatingGeneralSettings(app)
                    prePlot_updatingCustomProperties(app, idx)

                    [~, ~, XData, YData] = plot.datatip.Search(app.UIAxes3);
                    app.hWaterfall = plot.Waterfall('Delete', app.hWaterfall);
                    plot_Draw_Waterfall(app, idx)

                    if ~isempty(XData)
                        if event.Source == app.play_Waterfall_Fcn
                            for ii = 1:numel(YData)
                                switch event.Value
                                    case 'image'
                                        YData{ii} = Timestamp2idxTime(app.bandObj, idx, YData{ii});
                                    case 'mesh'
                                        YData{ii} = idxTime2Timestamp(app.bandObj, idx, YData{ii});
                                end
                            end
                        end

                        dtConfig = struct('XData', XData, 'YData', YData);
                        dtParent = app.hWaterfall;
                        plot.datatip.Create('redrawWaterfall', dtConfig, dtParent)                        
                    end

                %---------------------------------------------------------%
                case app.play_Waterfall_MeshStyle
                    app.hWaterfall.MeshStyle = app.play_Waterfall_MeshStyle.Value;

                %---------------------------------------------------------%
                case app.play_Waterfall_Timeline
                    switch app.play_Waterfall_Timeline.Value
                        case 'on'
                            prePlot_updatingGeneralSettings(app)
                            prePlot_updatingCustomProperties(app, idx)

                            app.hWaterfallTime = plot.draw2D.OrdinaryLine(app.UIAxes3, app.bandObj, idx, 'WaterfallTime');
                            plot.axes.StackingOrder.execute(app.UIAxes3, app.bandObj.Context)

                        case 'off'
                            if ~isempty(app.hWaterfallTime)
                                delete(app.hWaterfallTime) 
                                app.hWaterfallTime = [];
                            end
                    end

                %---------------------------------------------------------%
                case app.play_Waterfall_Colormap
                    plot.axes.Colormap(app.UIAxes3, app.play_Waterfall_Colormap.Value)

                %---------------------------------------------------------%
                case app.play_Waterfall_cLim_Mode
                    % Para que o eixo volte às configurações automáticas de
                    % CLim, e considerando como foi construída a classe Band, 
                    % em especial o seu método Limits, apaga-se temporariamente 
                    % a informação de customização... 
                    update(app.specData(idx), 'UserData:CustomPlayback', 'Refresh')
                    
                    prePlot_updatingRestoreView(app, idx)
                    app.UIAxes3.CLim = app.restoreView(3).cLim;
                    app.UIAxes3.UserData.CLimMode = 'auto';

                    play_Layout_WaterfallPanel(app)

                    % E após os ajustes do eixo e do painel de Waterfall, 
                    % recria-se a informação de customização, caso aplicável.
                    prePlot_updatingGeneralSettings(app)
                    prePlot_updatingCustomProperties(app, idx)
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Value changed function: play_Waterfall_Colorbar
        function play_Waterfall_ColorbarValueChanged(app, event)
            
            plot.axes.Colorbar(app.UIAxes3, app.play_Waterfall_Colorbar.Value)
            
        end

        % Value changed function: play_Waterfall_cLim1, 
        % ...and 1 other component
        function play_Waterfall_cLimValueChanged(app, event)

            cLim = [app.play_Waterfall_cLim1.Value, app.play_Waterfall_cLim2.Value];
            if issorted(cLim, 'strictascend')
                app.UIAxes3.CLim = cLim;
                app.UIAxes3.UserData.CLimMode = 'manual';
                
            else
                switch event.Source
                    case app.play_Waterfall_cLim1; app.play_Waterfall_cLim1.Value = event.PreviousValue;
                    case app.play_Waterfall_cLim2; app.play_Waterfall_cLim2.Value = event.PreviousValue;
                end
            end
            
        end

        % Value changed function: play_OCC_IntegrationTime, 
        % ...and 8 other components
        function play_Occupancy_Callbacks(app, event)
            
            play_OCCNewPlot(app)
            
        end

        % Selection changed function: play_Channel_RadioGroup
        function play_Channel_RadioGroupSelectionChanged(app, event)
            
            switch app.play_Channel_RadioGroup.SelectedObject
                case app.play_Channel_File
                    app.play_ControlsTab2Info.RowHeight(3:4) = {0, 80};

                otherwise
                    app.play_ControlsTab2Info.RowHeight(3:4) = {210, 0};

                    switch app.play_Channel_RadioGroup.SelectedObject
                        case app.play_Channel_ReferenceList
                            app.play_Channel_ListUpdate.Visible  = 1;
                            app.play_Channel_Grid.RowHeight(2:3) = {22,0};
                            
                            set(findobj(app.play_Channel_Grid, 'Type', 'uinumericeditfield'), 'Enable', 1, 'Editable', 0)
                            play_Channel_AutomaticChannelListValueChanged(app)
        
                        case app.play_Channel_Multiples
                            app.play_Channel_ListUpdate.Visible  = 0;
                            app.play_Channel_Grid.RowHeight(2:3) = {0,22};
                            
                            set(findobj(app.play_Channel_Grid, 'Type', 'uinumericeditfield'), 'Enable', 1, 'Editable', 1)
                            app.play_Channel_nChannels.Editable  = 0;
                            app.play_Channel_Class.Items         = app.channelObj.FindPeaks.Name;
        
                        case app.play_Channel_Single
                            app.play_Channel_ListUpdate.Visible  = 0;
                            app.play_Channel_Grid.RowHeight(2:3) = {0,22};                            
                            
                            set(app.play_Channel_nChannels,                 'Editable', 0, 'Value',  1)
                            set(app.play_Channel_FirstChannel, 'Enable', 1, 'Editable', 1)
                            set(app.play_Channel_BW,           'Enable', 1, 'Editable', 1)
                            set(app.play_Channel_LastChannel,  'Enable', 0, 'Editable', 0)
                            set(app.play_Channel_StepWidth,    'Enable', 0, 'Editable', 0, 'Value', -1)                            
                            app.play_Channel_Class.Items         = app.channelObj.FindPeaks.Name;
                            play_Channel_FirstChannelValueChanged(app)
                    end
            end
            
        end

        % Image clicked function: play_Channel_ListUpdate
        function play_Channel_AutomaticChannelListUpdate(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            update(app.specData(idx), 'UserData:Channel', 'ChannelLibIndex:Add', app.channelObj)
            play_Channel_TreeBuilding(app, idx, 'play_Channel_ListUpdateImageClicked')

        end

        % Value changed function: play_Channel_List
        function play_Channel_AutomaticChannelListValueChanged(app, event)

            idxChannel   = str2double(extractBefore(app.play_Channel_List.Value, ': '));

            FirstChannel = app.channelObj.Channel(idxChannel).FirstChannel;
            LastChannel  = app.channelObj.Channel(idxChannel).LastChannel;
            StepWidth    = app.channelObj.Channel(idxChannel).StepWidth;

            app.play_Channel_FirstChannel.Value = FirstChannel;
            app.play_Channel_LastChannel.Value  = LastChannel;
            app.play_Channel_StepWidth.Value    = max(-1, StepWidth * 1000);
            app.play_Channel_BW.Value           = max(-1, app.channelObj.Channel(idxChannel).ChannelBW * 1000);
            app.play_Channel_Class.Items        = {app.channelObj.Channel(idxChannel).FindPeaksName};

            if ~isempty(app.channelObj.Channel(idxChannel).FreqList)
                FreqList = app.channelObj.Channel(idxChannel).FreqList;
            else
                FreqList = FirstChannel:StepWidth:LastChannel;
            end
            app.play_Channel_nChannels.Value    = numel(FreqList);
            play_ChannelListSample(app, FreqList)
            
        end

        % Value changed function: play_Channel_FirstChannel, 
        % ...and 2 other components
        function play_Channel_FirstChannelValueChanged(app, event)
            
            FreqList = [];

            switch app.play_Channel_RadioGroup.SelectedObject
                case app.play_Channel_Multiples
                    if (app.play_Channel_LastChannel.Value >= app.play_Channel_FirstChannel.Value) && (app.play_Channel_StepWidth.Value > 0)
                        FreqList = app.play_Channel_FirstChannel.Value:app.play_Channel_StepWidth.Value/1000:app.play_Channel_LastChannel.Value;                        
                        app.play_Channel_nChannels.Value = numel(FreqList);
                    else
                        app.play_Channel_nChannels.Value = -1;
                    end

                case app.play_Channel_Single
                    app.play_Channel_LastChannel.Value = app.play_Channel_FirstChannel.Value;
                    FreqList = app.play_Channel_FirstChannel.Value;
            end

            play_ChannelListSample(app, FreqList)
            
        end

        % Selection changed function: play_Channel_Tree
        function play_Channel_TreeSelectionChanged(app, event)

            idxThread = app.play_PlotPanel.UserData.NodeData;

            if ~isempty(app.play_Channel_Tree.SelectedNodes)
                if isscalar(app.play_Channel_Tree.SelectedNodes)
                    srcChannel = app.play_Channel_Tree.SelectedNodes.NodeData.src;
                    idxChannel = app.play_Channel_Tree.SelectedNodes.NodeData.idx;
    
                    switch srcChannel
                        case 'channelLib'
                            app.play_Channel_ReferenceList.Value = 1;
                            play_Channel_RadioGroupSelectionChanged(app)
        
                            app.play_Channel_List.Value = app.play_Channel_List.Items{idxChannel};
                            play_Channel_AutomaticChannelListValueChanged(app)
    
                        case 'manual'
                            FirstChannel = app.specData(idxThread).UserData.channelManual(idxChannel).FirstChannel;
                            LastChannel  = app.specData(idxThread).UserData.channelManual(idxChannel).LastChannel;
                            StepWidth    = app.specData(idxThread).UserData.channelManual(idxChannel).StepWidth;
                            FreqList     = app.specData(idxThread).UserData.channelManual(idxChannel).FreqList;
    
                            if (StepWidth > 0) || ~isempty(FreqList)
                                app.play_Channel_Multiples.Value = 1;
                                if isempty(FreqList)
                                    FreqList = FirstChannel:StepWidth:LastChannel;
                                end
                            else
                                app.play_Channel_Single.Value    = 1;
                                FreqList = FirstChannel;
                            end
                            play_Channel_RadioGroupSelectionChanged(app)
        
                            app.play_Channel_Name.Value          = app.specData(idxThread).UserData.channelManual(idxChannel).Name;
                            app.play_Channel_FirstChannel.Value  = FirstChannel;
                            app.play_Channel_LastChannel.Value   = LastChannel;
                            app.play_Channel_StepWidth.Value     = max(-1, StepWidth * 1000);
                            app.play_Channel_BW.Value            = max(-1, app.specData(idxThread).UserData.channelManual(idxChannel).ChannelBW * 1000);
                            set(app.play_Channel_Class, 'Items', app.channelObj.FindPeaks.Name, 'Value', app.specData(idxThread).UserData.channelManual(idxChannel).FindPeaksName)
                
                            app.play_Channel_nChannels.Value     = numel(FreqList);
                            play_ChannelListSample(app, FreqList)
                    end

                    set(findobj(app.play_Channel_Grid.Children, '-not', {'Type', 'uilabel', '-or', 'Type', 'uiimage'}), 'Enable', 1)
                else
                    set(findobj(app.play_Channel_Grid.Children, '-not', {'Type', 'uilabel', '-or', 'Type', 'uiimage'}), 'Enable', 0)
                end
            end

            plot_Draw_Channels(app, idxThread)
            
        end

        % Image clicked function: play_Channel_add
        function play_Channel_addChannel(app, event)
            
            try
                idx = app.play_PlotPanel.UserData.NodeData;
                idxThreads = idx;

                switch app.play_Channel_RadioGroup.SelectedObject
                    %-----------------------------------------------------%
                    case app.play_Channel_ReferenceList
                        chIndex = str2double(extractBefore(app.play_Channel_List.Value, ': '));

                        channel2Add   = app.channelObj.Channel(chIndex);
                        typeOfChannel = 'channelLib';

                    %-----------------------------------------------------%
                    case {app.play_Channel_Multiples, app.play_Channel_Single}
                        channelName = strtrim(app.play_Channel_Name.Value);
                        refNames    = {app.specData(idx).UserData.channelManual.Name};

                        if isempty(channelName)
                            error('winAppAnalise:play_Channel_addChannel', 'O nome de um registro de canalização não pode ser vazio.')
                        elseif ismember(channelName, refNames)
                            msgQuestion   = sprintf(['Já existe uma canalização inserida manualmente com o nome "%s". ' ...
                                                     'Deseja editar as informações desse registro?'], channelName);
                            userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
                            
                            if strcmp(userSelection, 'Não')
                                return
                            end
                        end

                        FirstChannel  = app.play_Channel_FirstChannel.Value;
                        LastChannel   = app.play_Channel_LastChannel.Value;
                        channelBW     = max(0, app.play_Channel_BW.Value/1000); 
                        StepWidth     = app.play_Channel_StepWidth.Value/1000;
                        if StepWidth < 0
                            StepWidth = -1;
                        end

                        channel2Add   = struct('Name',          channelName,                                         ...
                                               'Band',          [FirstChannel-channelBW/2; LastChannel+channelBW/2], ...
                                               'FirstChannel',  FirstChannel,                                        ...
                                               'LastChannel',   LastChannel,                                         ...
                                               'StepWidth',     StepWidth,                                           ...
                                               'ChannelBW',     channelBW,                                           ...
                                               'FreqList',      [],                                                  ...
                                               'Reference',     'Inclusão manual',                                   ...
                                               'FindPeaksName', app.play_Channel_Class.Value);
                        typeOfChannel = 'manual';
    
                    %-----------------------------------------------------%
                    case app.play_Channel_File
                        switch app.play_Channel_ExternalFile.Value
                            case 'Generic (json)'
                                fileFormats = {'*.json', '(*.json)'};
                            case 'Satellite (csv)'
                                fileFormats = {'*.csv', '(*.csv)'};
                        end
                        
                        [fileFullPath, fileFolder, fileExt] = appUtil.modalWindow(app.UIFigure, 'uigetfile', '', fileFormats, app.General.fileFolder.lastVisited);
                        if isempty(fileFullPath)
                            return
                        end

                        misc_updateLastVisitedFolder(app, fileFolder)

                        switch fileExt
                            case '.json'
                                channel2Add = readFileWithChannel2Add(app.channelObj, fileFullPath);

                                msgQuestion   = sprintf(['Foram extraídos os registros %s, os quais serão incluídos na lista de canais manuais do ' ...
                                                         'fluxo espectral selecionado, caso se sobreponham à faixa de frequência, substituindo '    ...
                                                         'eventuais canalizações inseridas manualmente que tenham um dos supracitados nomes.\n\n'   ...
                                                         'Deseja analisar a inclusão desses registros para os outros fluxos?'], textFormatGUI.cellstr2ListWithQuotes({channel2Add.Name}));
                                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
                                
                                if strcmp(userSelection, 'Sim')
                                    idxThreads = 1:numel(app.specData);
                                end
                                typeOfChannel = 'manual';

                            % Em sendo um plano básico de um satélite, o relacionamento 
                            % dos canais com os fluxos espectrais ocorrerá em modo auxiliar
                            % (popup).
                            case '.csv'                            
                                channelTable = class.EMSatDataHubLib.importRawCSVFile(fileFullPath);
                                menu_LayoutPopupApp(app, 'AddChannel', idx, channelTable)
                                return
                        end
                end

                play_Channel_AddChannel(app, channel2Add, typeOfChannel, idxThreads)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end

        end

        % Menu selected function: play_Channel_ContextMenu_del
        function play_Channel_ContextMenu_delChannelSelected(app, event)
            
            % Operação realizada a partir do menu de contexto, apagando a
            % canalização selecionada.

            if ~isempty(app.play_Channel_Tree.SelectedNodes)
                idx = app.play_PlotPanel.UserData.NodeData;

                for ii = numel(app.play_Channel_Tree.SelectedNodes):-1:1
                    srcChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.src;
                    idxChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.idx;
    
                    switch srcChannel
                        case 'channelLib'
                            update(app.specData(idx), 'UserData:Channel', 'ChannelLibIndex:Edit', idxChannel)
                        case 'manual'
                            update(app.specData(idx), 'UserData:Channel', 'ChannelManual:Refresh')
                    end
                end
            end

            play_Channel_TreeBuilding(app, idx, 'play_Channel_ContextMenu_delChannel')

        end

        % Menu selected function: play_Channel_ContextMenu_addBandLimit
        function play_Channel_ContextMenu_addBandLimitSelected(app, event)
            
            % Operação realizada a partir do menu de contexto, inserindo os
            % limites da canalização selecionada como limite de detecção de 
            % emissões.

            if ~isempty(app.play_Channel_Tree.SelectedNodes)
                idxThread = app.play_PlotPanel.UserData.NodeData;

                xLim1 = [];
                xLim2 = [];

                for ii = 1:numel(app.play_Channel_Tree.SelectedNodes)
                    srcChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.src;
                    idxChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.idx;
    
                    switch srcChannel
                        case 'channelLib'
                            xLim1(end+1) = app.channelObj.Channel(idxChannel).Band(1);
                            xLim2(end+1) = app.channelObj.Channel(idxChannel).Band(2);
                        case 'manual'
                            xLim1(end+1) = app.specData(idxThread).UserData.channelManual(idxChannel).Band(1);
                            xLim2(end+1) = app.specData(idxThread).UserData.channelManual(idxChannel).Band(2);
                    end
                end

                app.play_BandLimits_xLim1.Value = max([min(xLim1), app.play_BandLimits_xLim1.Limits(1)]);
                app.play_BandLimits_xLim2.Value = min([max(xLim2), app.play_BandLimits_xLim1.Limits(2)]);

                if ~app.play_BandLimits_Status.Value
                    app.play_BandLimits_Status.Value = 1;
                    play_BandLimits_StatusValueChanged(app)
                end
                play_BandLimits_addImageClicked(app)
            end

        end

        % Menu selected function: play_Channel_ContextMenu_addEmission
        function play_Channel_ContextMenu_addEmissionSelected(app, event)
            
            % Operação realizada a partir do menu de contexto, inserindo os
            % canais da canalização selecionada como emissões.

            if ~isempty(app.play_Channel_Tree.SelectedNodes)
                idxThread  = app.play_PlotPanel.UserData.NodeData;

                for ii = 1:numel(app.play_Channel_Tree.SelectedNodes)
                    srcChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.src;
                    idxChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.idx;
    
                    switch srcChannel
                        case 'channelLib'
                            specChannel = app.channelObj.Channel(idxChannel);
                        case 'manual'
                            specChannel = app.specData(idxThread).UserData.channelManual(idxChannel);
                    end
    
                    newFreq  = specChannel.FreqList;
                    if isempty(newFreq)
                        newFreq = (specChannel.FirstChannel:specChannel.StepWidth:specChannel.LastChannel)';
                    end
                    [newIndex, invalidIndex] = freq2idx(app.bandObj, newFreq .* 1e+6, 'OnlyCheck');
    
                    newFreq(invalidIndex)  = [];
                    newIndex(invalidIndex) = [];
                    
                    if ~isempty(newIndex)
                        newBW = specChannel.ChannelBW;
                        if newBW < 0
                            newBW = 0;
                        end
                        newBW = newBW * 1000; % Em kHz
            
                        NN = numel(newIndex);
                        play_AddEmission2List(app, idxThread, newIndex, newFreq, repmat(newBW, NN, 1), repmat({jsonencode(struct('Algorithm', 'Manual'))}, NN, 1))
                    end
                end
            end

        end

        % Selection changed function: play_FindPeaks_RadioGroup
        function play_FindPeaks_RadioGroupSelectionChanged(app, event)
            
            switch app.play_FindPeaks_RadioGroup.SelectedObject
                case app.play_FindPeaks_auto
                    play_FindPeaks_AlgorithmValueChanged(app)

                case app.play_FindPeaks_File
                    app.play_ControlsTab3Info.RowHeight(3:4) = {0,80};

                otherwise % ROI | DataTips
                    app.play_ControlsTab3Info.RowHeight(3:4) = {0,0};
            end
            
        end

        % Value changed function: play_FindPeaks_Algorithm
        function play_FindPeaks_AlgorithmValueChanged(app, event)
            
            switch app.play_FindPeaks_Algorithm.Value
                case 'FindPeaks'
                    app.play_ControlsTab3Info.RowHeight(3:4) = {174,0};
                    app.play_FindPeaks_ParametersGrid.RowHeight([3 4 7]) = {25,22,0};
                    
                    app.play_FindPeaks_prominenceLabel.Visible = 1;
                    app.play_FindPeaks_prominence.Visible      = 1;

                    app.play_FindPeaks_ClassLabel.Visible = 0;
                    app.play_FindPeaks_Class.Visible      = 0;

                case 'FindPeaks+OCC'
                    app.play_ControlsTab3Info.RowHeight(3:4) = {210,0};
                    app.play_FindPeaks_ParametersGrid.RowHeight([3 4 7]) = {0,0,88};

                    app.play_FindPeaks_prominenceLabel.Visible = 0;
                    app.play_FindPeaks_prominence.Visible      = 0;

                    app.play_FindPeaks_ClassLabel.Visible = 1;
                    app.play_FindPeaks_Class.Visible      = 1;
            end

        end

        % Selection changed function: play_FindPeaks_Tree
        function play_FindPeaks_TreeSelectionChanged(app, event)
            
            if isscalar(app.play_FindPeaks_Tree.SelectedNodes)
                idxThread   = app.play_PlotPanel.UserData.NodeData;
                idxEmission = app.play_FindPeaks_Tree.SelectedNodes.NodeData;

                set(app.play_FindPeaks_PeakCF,      'Value', round(app.specData(idxThread).UserData.Emissions.Frequency(idxEmission), 3), 'Enable', 1)
                set(app.play_FindPeaks_PeakBW,      'Value', round(app.specData(idxThread).UserData.Emissions.BW_kHz(idxEmission), 1),    'Enable', 1)
                set(app.play_FindPeaks_Description, 'Value',       app.specData(idxThread).UserData.Emissions.Description(idxEmission),   'Enable', 1)

                app.play_FindPeaks_ContextMenu_search.Enable = 1;
                if strcmp(app.play_FindPeaks_Tree.SelectedNodes.Icon, 'signalTruncated_32.png')
                    app.play_FindPeaks_ContextMenu_digital.Enable = 0;
                    app.play_FindPeaks_ContextMenu_analog.Enable  = 1;
                else
                    app.play_FindPeaks_ContextMenu_digital.Enable = 1;
                    app.play_FindPeaks_ContextMenu_analog.Enable  = 0;
                end

                if exist('event', 'var')
                    plot.draw2D.ClearWrite_old(app, idxThread, 'TreeSelectionChanged', [])
                end

            else
                set(app.play_FindPeaks_PeakCF,      'Value', -1, 'Enable', 0)
                set(app.play_FindPeaks_PeakBW,      'Value', -1, 'Enable', 0)
                set(app.play_FindPeaks_Description, 'Value', '', 'Enable', 0)

                set(app.play_FindPeaks_ContextMenu_search,        'Enable', 0)
                set(app.play_FindPeaks_ContextMenu_edit.Children, 'Enable', 1)
            end
            
        end

        % Image clicked function: play_FindPeaks_add
        function play_FindPeaks_addEmission(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            newIndex = [];

            switch app.play_FindPeaks_RadioGroup.SelectedObject
                %---------------------------------------------------------%
                case app.play_FindPeaks_File
                    switch app.play_FindPeaks_ExternalFile.Value
                        case 'Generic (csv, txt, json, xls, xlsx)'
                            fileFormats = {'*.csv;*.txt;*.json;*.xls;*.xlsx', '(*.csv,*.txt,*.json,*.xls,*.xlsx)'};
                        case 'Romes (csv)'
                            fileFormats = {'*.csv', '(*.csv)'};
                    end

                    [fileFullPath, fileFolder, fileExt] = appUtil.modalWindow(app.UIFigure, 'uigetfile', '', fileFormats, app.General.fileFolder.lastVisited);
                    if isempty(fileFullPath)
                        return
                    end
                    misc_updateLastVisitedFolder(app, fileFolder)

                    try
                        switch fileExt
                            case '.json'
                                rawTable = struct2table(jsondecode(fileread(fileFullPath)), 'AsArray', true);
                            otherwise
                                switch app.play_FindPeaks_ExternalFile.Value
                                    case 'Generic (csv, txt, json, xls, xlsx)'
                                        rawTable = readtable(fileFullPath, "VariableNamingRule", "preserve");
                                    case 'Romes (csv)'
                                        rawTable = util.readFileGeneratedByRomes(fileFullPath);
                                end
                        end
                        rawTable.Properties.VariableNames = {'Frequency', 'BW', 'Description'};

                        if ~isempty(rawTable)
                            msgQuestion   = sprintf(['Foram identificadas emissões centralizadas em %s.\n\nEssas emissões serão adicionadas ' ...
                                                     'ao fluxo espectral selecionado, caso estejam dentro da faixa de frequência.\n\nDeseja ' ...
                                                     'incluir essas emissões nos demais fluxos também?'],                                     ...
                                                     strjoin(string(sort(rawTable.Frequency))+" MHz", ', '));
                            userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

                            switch userSelection
                                case 'Sim'
                                    idxThreads  = 1:numel(app.specData);
                                    tempBandObj = class.Band('appAnalise:PLAYBACK', app);
                                otherwise
                                    idxThreads  = idx;
                                    tempBandObj = app.bandObj;
                            end
                            
                            for ii = idxThreads
                                update(tempBandObj, ii);
                                tempBandTable = rawTable;

                                [newIndex, invalidIndex] = freq2idx(tempBandObj, tempBandTable.Frequency .* 1e+6, 'OnlyCheck');
                                if all(invalidIndex)
                                    continue
                                end

                                tempBandTable(invalidIndex,:) = [];
                                newIndex(invalidIndex)        = [];

                                numEmissions   = numel(newIndex);
                                newFreq        = tempBandTable.Frequency;         % Em MHz
                                newBW          = tempBandTable.BW;                % Em kHz
                                Method         = repmat({jsonencode(struct('Algorithm', 'ExternalFile'))}, numEmissions, 1);
                                newDescription = tempBandTable.Description;
                                
                                if numEmissions
                                    play_AddEmission2List(app, ii, newIndex, newFreq, newBW, Method, newDescription)
                                end
                            end
                        end

                    catch ME
                        appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
                        return
                    end

                otherwise
                    switch app.play_FindPeaks_RadioGroup.SelectedObject
                        %-------------------------------------------------%
                        case app.play_FindPeaks_auto
                            app.progressDialog.Visible = 'visible';

                            switch app.play_FindPeaks_Algorithm.Value
                                case 'FindPeaks'
                                    Attributes = struct('Algorithm',    app.play_FindPeaks_Algorithm.Value,  ...
                                                        'Fcn',          app.play_FindPeaks_Trace.Value,      ...
                                                        'NPeaks',       app.play_FindPeaks_Numbers.Value,    ...
                                                        'THR',          app.play_FindPeaks_THR.Value,        ...
                                                        'Prominence',   app.play_FindPeaks_prominence.Value, ...
                                                        'Distance_kHz', app.play_FindPeaks_distance.Value,   ...
                                                        'BW_kHz',       app.play_FindPeaks_BW.Value);        
                                case 'FindPeaks+OCC'
                                    Attributes = struct('Algorithm',    app.play_FindPeaks_Algorithm.Value,   ...
                                                        'Distance_kHz', app.play_FindPeaks_distance.Value,    ...
                                                        'BW_kHz',       app.play_FindPeaks_BW.Value,          ...
                                                        'Prominence1',  app.play_FindPeaks_Prominence1.Value, ...
                                                        'Prominence2',  app.play_FindPeaks_Prominence2.Value, ...
                                                        'meanOCC',      app.play_FindPeaks_meanOCC.Value,     ...
                                                        'maxOCC',       app.play_FindPeaks_maxOCC.Value);
                            end
                            [newIndex, newFreq, newBW, Method] = util.Detection.Controller(app.specData, idx, Attributes);

                        %-------------------------------------------------%
                        case app.play_FindPeaks_ROI
                            % Incluir uma emissõe por ROI demanda eliminar
                            % interações do plot.
                            app.play_FindPeaks_add.Enable = 0;
                            if app.axesTool_DataTip.UserData
                                play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_DataTip))
                            end
                            plot.axes.Interactivity.DefaultDisable([app.UIAxes1, app.UIAxes2, app.UIAxes3])
                            drawnow
                            
                            mkrTemp  = drawrectangle(app.UIAxes1, Color=[0.40,0.73,0.88], LineWidth=1, Tag='mkrTemp');
                            app.play_FindPeaks_add.Enable = 1;
        
                            plot.axes.Interactivity.DefaultEnable([app.UIAxes1, app.UIAxes2, app.UIAxes3])
            
                            newFreq  = mkrTemp.Position(1) + mkrTemp.Position(3)/2; % Em MHz
                            newBW    = mkrTemp.Position(3) * 1000;                  % Em kHz
                            newIndex = freq2idx(app.bandObj, newFreq .* 1e+6);
                            Method   = jsonencode(struct('Algorithm', 'Manual'));
        
                            % Se for desenhada uma ROI fora dos limites do eixo,
                            % a função freq2idx retornará ela nas extremidades do 
                            % eixo. Nesse caso, exclui-se a ROI.                            
                            if ismember(newIndex, [1, app.specData(idx).MetaData.DataPoints])
                                delete(mkrTemp)
                                return
                            end
        
                        %-------------------------------------------------%
                        case app.play_FindPeaks_DataTips
                            hDataTips = findobj('Type', 'DataTip');
                            if isempty(hDataTips)
                                return
                            end
            
                            newFreq = [];
                            ii = 0;
                            while ii < numel(hDataTips)
                                ii = ii+1;
                                if isequal(hDataTips(ii).Parent.Parent.Parent.Parent, app.play_PlotPanel)
                                    newFreq(end+1,1) = double(round(hDataTips(ii).X, 3));   % Em MHz
                                end
                            end
                            newBW    = ones(numel(newFreq), 1) .* app.General.Detection.InitialBW_kHz;
                            newIndex = freq2idx(app.bandObj, newFreq .* 1e+6);
                            Method   = repmat({jsonencode(struct('Algorithm', 'Manual'))}, numel(newFreq), 1);
                    end

                    app.progressDialog.Visible = 'visible';
                
                    if ischar(Method)
                        Method = {Method};
                    end
    
                    NN = numel(newIndex);
                    if NN
                        play_AddEmission2List(app, idx, newIndex, newFreq, newBW, Method)
                    else
                        if exist('mkrTemp', 'var')
                            delete(mkrTemp)
                        end
                    end

                    app.progressDialog.Visible = 'hidden';
            end
            
            if isempty(newIndex)
                appUtil.modalWindow(app.UIFigure, 'warning', 'Não identificado pico que atenda as condições estabelecidas.');
            end
            
        end

        % Menu selected function: play_FindPeaks_ContextMenu_del
        function play_FindPeaks_delEmission(app, event)
            
            if ~isempty(app.play_FindPeaks_Tree.SelectedNodes)
                idxThread    = app.play_PlotPanel.UserData.NodeData;
                idxEmissions = [app.play_FindPeaks_Tree.SelectedNodes.NodeData];

                update(app.specData(idxThread), 'UserData:Emissions', 'Delete', idxEmissions)
                
                plot.draw2D.ClearWrite_old(app, idxThread, 'DeleteButtonPushed', 1)
                play_UpdateAuxiliarApps(app)
            end
            
        end

        % Value changed function: play_FindPeaks_Description, 
        % ...and 2 other components
        function play_FindPeaks_editEmission(app, event)
            
            idxThread   = app.play_PlotPanel.UserData.NodeData;
            idxEmission = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;

            switch event.Source
                case app.play_FindPeaks_PeakCF
                    if (app.play_FindPeaks_PeakCF.Value*1e+6 < app.specData(idxThread).MetaData.FreqStart) || ...
                       (app.play_FindPeaks_PeakCF.Value*1e+6 > app.specData(idxThread).MetaData.FreqStop)
                    
                       app.play_FindPeaks_PeakCF.Value = round(app.specData(idxThread).UserData.Emissions.Frequency(idxEmission), 3);
                       return
                    end
                    
                    idxFrequency = freq2idx(app.bandObj, app.play_FindPeaks_PeakCF.Value*1e+6);
                    FreqCenter   = app.bandObj.xArray(idxFrequency);
                    BW_kHz       = app.play_FindPeaks_PeakBW.Value;

                    update(app.specData(idxThread), 'UserData:Emissions', 'Edit', 'Frequency', idxEmission, idxFrequency, FreqCenter, BW_kHz, app.channelObj)
                    app.play_FindPeaks_PeakCF.Value = FreqCenter;
                    plot_updateSelectedEmission(app, idxThread, idxFrequency)

                case app.play_FindPeaks_PeakBW
                    idxFrequency = freq2idx(app.bandObj, app.play_FindPeaks_PeakCF.Value*1e+6);
                    FreqCenter   = app.play_FindPeaks_PeakCF.Value;
                    BW_kHz       = app.play_FindPeaks_PeakBW.Value;

                    update(app.specData(idxThread), 'UserData:Emissions', 'Edit', 'BandWidth', idxEmission, idxFrequency, FreqCenter, BW_kHz, app.channelObj)
                    plot_updateSelectedEmission(app, idxThread, idxFrequency)

                case app.play_FindPeaks_Description
                    newDescription = textFormatGUI.cellstr2TextField(app.play_FindPeaks_Description.Value);

                    update(app.specData(idxThread), 'UserData:Emissions', 'Edit', 'Description', idxEmission, newDescription)
                    app.play_FindPeaks_Description.Value = newDescription;
            end

            play_UpdateAuxiliarApps(app)
            
        end

        % Menu selected function: play_FindPeaks_ContextMenu_analog, 
        % ...and 1 other component
        function play_FindPeaks_TruncatedEmission(app, event)

            idx = app.play_PlotPanel.UserData.NodeData;

            for ii = 1:numel(app.play_FindPeaks_Tree.SelectedNodes)
                idxEmission = app.play_FindPeaks_Tree.SelectedNodes(ii).NodeData;
    
                switch event.Source.Text
                    case 'Truncar frequência'
                        update(app.specData(idx), 'UserData:Emissions', 'Edit', 'IsTruncated', idxEmission, 1, app.channelObj)
                        app.play_FindPeaks_Tree.SelectedNodes(ii).Icon = 'signalTruncated_32.png';
    
                    case 'Não truncar'
                        update(app.specData(idx), 'UserData:Emissions', 'Edit', 'IsTruncated', idxEmission, 0, app.channelObj)
                        app.play_FindPeaks_Tree.SelectedNodes(ii).Icon = 'signalUntruncated_32.png';
                end
            end            
            play_FindPeaks_TreeSelectionChanged(app)            
            play_UpdateAuxiliarApps(app)
            
        end

        % Value changed function: play_FindPeaks_maxOCC, 
        % ...and 1 other component
        function play_FindPeaks_OCCValueChanged(app, event)

            switch event.Source
                case app.play_FindPeaks_meanOCC
                    if app.play_FindPeaks_meanOCC.Value > app.play_FindPeaks_maxOCC.Value
                        app.play_FindPeaks_maxOCC.Value = app.play_FindPeaks_meanOCC.Value;
                    end

                case app.play_FindPeaks_maxOCC
                    if app.play_FindPeaks_maxOCC.Value < app.play_FindPeaks_meanOCC.Value
                        app.play_FindPeaks_meanOCC.Value = app.play_FindPeaks_maxOCC.Value;
                    end
            end

        end

        % Value changed function: play_FindPeaks_Class
        function play_FindPeaks_ClassValueChanged(app, event)
            
            idxFindPeaks = find(strcmp(app.channelObj.FindPeaks.Name, app.play_FindPeaks_Class.Value), 1);

            app.play_FindPeaks_distance.Value    = 1000 * app.channelObj.FindPeaks.Distance(idxFindPeaks);
            app.play_FindPeaks_BW.Value          = 1000 * app.channelObj.FindPeaks.BW(idxFindPeaks);
            app.play_FindPeaks_Prominence1.Value = app.channelObj.FindPeaks.Prominence1(idxFindPeaks);
            app.play_FindPeaks_Prominence2.Value = app.channelObj.FindPeaks.Prominence2(idxFindPeaks);
            app.play_FindPeaks_meanOCC.Value     = app.channelObj.FindPeaks.meanOCC(idxFindPeaks);
            app.play_FindPeaks_maxOCC.Value      = app.channelObj.FindPeaks.maxOCC(idxFindPeaks);
                        
        end

        % Value changed function: play_BandLimits_Status
        function play_BandLimits_StatusValueChanged(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            play_BandLimits_Layout(app, idx)

            if app.play_BandLimits_Status.Value                      && ...
                ~isempty(app.specData(idx).UserData.bandLimitsTable) && ...
                ~isempty(app.specData(idx).UserData.Emissions)

                msgQuestion   = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    app.play_BandLimits_Status.Value = 0;
                    play_BandLimits_Layout(app, idx)
                    return
                end

                % Identificar o índice da emissão selecionada, para o qual
                % foi desenhado um ROI no app.axes1.
                idxEmission = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;
                newIndex = app.specData(idx).UserData.Emissions.idxFrequency(idxEmission);

                plot_updateSelectedEmission(app, idx, newIndex)
                play_UpdateAuxiliarApps(app)
            end

            plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')
            
        end

        % Image clicked function: play_BandLimits_add
        function play_BandLimits_addImageClicked(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            bandLimitsTable = app.specData(idx).UserData.bandLimitsTable;

            % Validações:
            if app.play_BandLimits_xLim2.Value <= app.play_BandLimits_xLim1.Value                    
                appUtil.modalWindow(app.UIFigure, 'warning', 'Subfaixa inválida.');
                return

            elseif any((bandLimitsTable.FreqStart <= app.play_BandLimits_xLim1.Value) & (bandLimitsTable.FreqStop >= app.play_BandLimits_xLim2.Value))
                appUtil.modalWindow(app.UIFigure, 'warning', 'Subfaixa já contemplada.');
                return
            end

            % Compara subfaixa a analisar inserida com os registros já existentes.
            xLim1 = app.play_BandLimits_xLim1.Value;
            xLim2 = app.play_BandLimits_xLim2.Value;

            % Passo 1 de 2
            Flag = true;
            for ii = 1:height(bandLimitsTable)
                if (xLim1 <= bandLimitsTable.FreqStart(ii)) && (xLim2 >= bandLimitsTable.FreqStop(ii))
                    bandLimitsTable(ii,:) = {xLim1, xLim2};
                    Flag = false;
                    continue
                
                elseif (xLim1 <= bandLimitsTable.FreqStart(ii)) && (xLim2 > bandLimitsTable.FreqStart(ii)) && (xLim2 < bandLimitsTable.FreqStop(ii))
                    bandLimitsTable(ii,1) = {xLim1};
                    Flag = false;
                    continue

                elseif (xLim1 > bandLimitsTable.FreqStart(ii)) && (xLim1 < bandLimitsTable.FreqStop(ii)) && (xLim2 >= bandLimitsTable.FreqStop(ii))
                    bandLimitsTable(ii,2) = {xLim2};
                    Flag = false;
                    continue
                end
            end

            if Flag
                bandLimitsTable(end+1,:) = {xLim1, xLim2};
            end
            bandLimitsTable = sortrows(bandLimitsTable, 'FreqStart');

            % Passo 2 de 2
            for ii = height(bandLimitsTable):-1:2
                if bandLimitsTable.FreqStart(ii) <= bandLimitsTable.FreqStop(ii-1)
                    bandLimitsTable(ii-1,2) = {bandLimitsTable.FreqStop(ii)};
                    bandLimitsTable(ii,:)   = [];
                end
            end

            if isempty(app.specData(idx).UserData.bandLimitsTable) && ~isempty(app.specData(idx).UserData.Emissions)
                msgQuestion   = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end

                % Identificar o índice da emissão selecionada, para o qual
                % foi desenhado um ROI no app.axes1.
                idxEmission  = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;
                idxFrequency = app.specData(idx).UserData.Emissions.idxFrequency(idxEmission);

                update(app.specData(idx), 'UserData:BandLimits', 'Table:Edit', bandLimitsTable)
                plot_updateSelectedEmission(app, idx, idxFrequency)
                play_UpdateAuxiliarApps(app)

            else
                update(app.specData(idx), 'UserData:BandLimits', 'Table:Edit', bandLimitsTable)
            end

            play_BandLimits_TreeBuilding(app, idx)
            plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')

        end

        % Menu selected function: play_BandLimits_ContextMenu_del
        function play_BandLimits_ContextMenu_delSelected(app, event)
            
            if ~isempty(app.play_BandLimits_Tree.SelectedNodes)
                idx = app.play_PlotPanel.UserData.NodeData;
                idxBandLimits = [app.play_BandLimits_Tree.SelectedNodes.NodeData];
                
                if ~isempty(app.specData(idx).UserData.Emissions) && height(app.specData(idx).UserData.bandLimitsTable) > 1
                    msgQuestion   = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                    userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        return
                    end
                end

                update(app.specData(idx), 'UserData:BandLimits', 'Table:DeleteRows', idxBandLimits)
                if exist('userSelection', 'var')
                    plot_updateSelectedEmission(app, idx, app.specData(idx).UserData.Emissions.idxFrequency)
                    play_UpdateAuxiliarApps(app)
                end
    
                play_BandLimits_TreeBuilding(app, idx)
                plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')
            end

        end

        % Menu selected function: play_FindPeaks_ContextMenu_search
        function play_RFDataHubButtonPushed(app, event)
            
            global RFDataHub

            idxThread = app.play_PlotPanel.UserData.NodeData;
            idxEmission = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;

            % Inicialmente, trunca-se a frequência da emissão selecionada, 
            % caso aplicável.            
            if app.specData(idxThread).UserData.Emissions.isTruncated(idxEmission)
                Truncated = TruncatedFrequency(app.channelObj, app.specData(idxThread), idxEmission);
            else
                Truncated = app.specData(idxThread).UserData.Emissions.Frequency(idxEmission);
            end            

            % Identifica na base de dados offline (anateldb) aqueles registros 
            % que possuem a mesma frequência (tolerância: 1e-5).
            idxRFDataHub = find(abs(RFDataHub.Frequency - Truncated) <= class.Constants.floatDiffTolerance);
            if ~isempty(idxRFDataHub)
                auxDistance      = deg2km(distance(app.specData(idxThread).GPS.Latitude, app.specData(idxThread).GPS.Longitude, RFDataHub.Latitude(idxRFDataHub), RFDataHub.Longitude(idxRFDataHub)));
                [Distance, idx4] = min(auxDistance);
                Description      = model.RFDataHub.Description(RFDataHub, idxRFDataHub(idx4));

                if app.specData(idxThread).UserData.Emissions.isTruncated(idxEmission)
                    msg = sprintf(['A frequência central da emissão (%.3f MHz) foi truncada em <b>%.5f MHz</b>.\n\n'                            ...
                                   'Foram identificados <b>%d registros</b> de estações cujas frequências centrais coincidem com %.3f MHz.\n\n' ...
                                   'A estação mais próxima do local de monitoração está a <b>%.1f km</b>, tendo como descrição "<b>%s</b>"'],   ...
                                   app.specData(idxThread).UserData.Emissions.Frequency(idxEmission), Truncated, numel(idxRFDataHub), Truncated, Distance, Description);
                else
                    msg = sprintf(['A frequência central da emissão (%.3f MHz) não foi truncada.\n\n'                                           ...
                                   'Foram identificados <b>%d registros</b> de estações cujas frequências centrais coincidem com %.3f MHz.\n\n' ...
                                   'A estação mais próxima do local de monitoração está a <b>%.1f km</b>, tendo como descrição "<b>%s</b>"'],   ...
                                   app.specData(idxThread).UserData.Emissions.Frequency(idxEmission), numel(idxRFDataHub), Truncated, Distance, Description);
                end

            else
                if app.specData(idxThread).UserData.Emissions.isTruncated(idxEmission)
                    msg = sprintf(['A frequência central da emissão (%.3f MHz) foi truncada em <b>%.5f MHz</b>.\n\n'           ...
                                   'Não foi identificado registro de estação cuja frequência central coincide com %.5f MHz.'], ...
                                   app.specData(idxThread).UserData.Emissions.Frequency(idxEmission), Truncated, Truncated);
                else
                    msg = sprintf(['A frequência central da emissão (%.3f MHz) não foi truncada.\n\n'                          ...
                                   'Não foi identificado registro de estação cuja frequência central coincide com %.5f MHz.'], ...
                                   app.specData(idxThread).UserData.Emissions.Frequency(idxEmission), Truncated);
                end
            end

            appUtil.modalWindow(app.UIFigure, 'warning', msg);

        end

        % Image clicked function: play_LimitsRefresh
        function play_LimitsRefreshImageClicked(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;

            % Para que o eixo volte às configurações automáticas de
            % XLim e YLim, e considerando como foi construída a classe Band, 
            % em especial o seu método Limits, apaga-se temporariamente 
            % a informação de customização... 
            update(app.specData(idx), 'UserData:CustomPlayback', 'Refresh')

            prePlot_updatingRestoreView(app, idx)
            set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)

            % E após os ajustes do eixo e do painel de spinners (que é atualizado
            % automaticamente), recria-se a informação de customização, caso aplicável.
            prePlot_updatingGeneralSettings(app)
            prePlot_updatingCustomProperties(app, idx)

        end

        % Callback function: play_Channel_FileTemplate, 
        % ...and 1 other component
        function play_DownloadFileTemplate(app, event)
            
            switch event.Source
                case app.play_Channel_FileTemplate
                    msgQuestion   = ['O arquivo genérico que possibilita a inclusão de canais é composto por uma estrutura com nove campos:<br>'            ...
                                     '<font style="font-size: 11px;">•&thinsp;Campo 1: Identificador;<br>'                                                  ...
                                     '•&thinsp;Campo 2: Faixa de frequência, em kHZ;<br>'                                                                   ...
                                     '•&thinsp;Campos 3-4: Frequências centrais de canais - o primeiro e o último, respectivamente -, em MHz;<br>'          ...
                                     '•&thinsp;Campo 5: Distância entre frequências centrais de canais adjacentes, em MHz;<br>'                             ...
                                     '•&thinsp;Campo 6: Largura dos canais, em MHz;<br>'                                                                    ...
                                     '•&thinsp;Campo 7: Lista de frequências centrais dos canais, caso não sejam regularmente espaçados;<br>'               ...
                                     '•&thinsp;Campo 8: Referência textual sobre a canalização;<br>'                                                        ...
                                     '•&thinsp;Campo 9: Natureza das emissões, podendo ser "Aircraft", "Cellular", "FM", "TV" ou "Unknown".</font><br><br>' ...
                                     'Deseja fazer download do arquivo modelo?'];
                    templateName  = 'addChannelList.json';
                    templateExt   = '.json';

                case app.play_FindPeaks_FileTemplate
                    msgQuestion   = ['O arquivo genérico que possibilita a inclusão de emissões é composto por uma tabela com três colunas:<br>' ...
                                     '<font style="font-size: 11px;">•&thinsp;Coluna 1: Frequência, em MHZ;<br>'                                 ...
                                     '•&thinsp;Coluna 2: Largura ocupada, em kHZ; e<br>'                                                         ...
                                     '•&thinsp;Coluna 3: Descrição textual da emissão.</font><br><br>'                                           ...
                                     'Deseja fazer download dos arquivos modelos?'];
                    templateName  = 'addEmission.zip';
                    templateExt   = '.zip';
            end

            userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
            if userSelection == "Sim"
                nameFormatMap = {['*' templateExt], sprintf('appAnalise (*%s)', templateExt)};
                defaultName   = fullfile(app.General.fileFolder.userPath, templateName); 
                fileFullPath  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);

                if isempty(fileFullPath)
                    return
                end

                try
                    templateFullFile = fullfile(app.General.fileFolder.MFilePath, 'resources', 'FileTemplates', templateName);
                    copyfile(templateFullFile, fileFullPath, 'f')
                catch ME
                    appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
                end
            end

        end

        % Image clicked function: play_Channel_ShowPlot
        function play_Channel_ShowPlotImageClicked(app, event)
            
            app.play_Channel_ShowPlot.UserData = ~app.play_Channel_ShowPlot.UserData;
            
            if app.play_Channel_ShowPlot.UserData
                app.play_Channel_ShowPlot.ImageSource = 'Eye_32.png';
            else
                app.play_Channel_ShowPlot.ImageSource = 'EyeNegative_32.png';
            end

            idx = app.play_PlotPanel.UserData.NodeData;
            plot_Draw_Channels(app, idx)

        end

        % Value changed function: report_Issue
        function report_SaveWarn(app, event)

            app.report_ProjectWarnIcon.Visible = 1;
            
        end

        % Image clicked function: report_TreeAddImage
        function report_TreeAddImagePushed(app, event)
            
            if ~isempty(app.play_Tree.SelectedNodes)
                idxThreads = unique([app.play_Tree.SelectedNodes.NodeData]);
    
                msg = '';
                if any(ismember(arrayfun(@(x) x.MetaData.DataType, app.specData(idxThreads)), class.Constants.occDataTypes))
                    msg = 'É possível a inclusão apenas de fluxos de espectro. Os fluxos de ocupação automaticamente serão inclusos na edição do relatório, desde que selecionado nos equivalentes fluxos de espectro.';
                elseif any(~arrayfun(@(x) x.GPS.Status, app.specData(idxThreads)))
                    msg = 'Necessária a edição de informações de coordenadas geográficas de fluxo(s) de dados.';                    
                elseif any(arrayfun(@(x) numel(x.Data{1}), app.specData(idxThreads)) == 1)
                    msg = 'É possível a inclusão de fluxo(s) de dados que possua(m) ao menos duas amostras.';
                end

                if ~isempty(msg)
                    appUtil.modalWindow(app.UIFigure, 'warning', msg);
                    return
                end

                if any(~ismember(idxThreads, find(arrayfun(@(x) x.UserData.reportFlag, app.specData))))
                    app.progressDialog.Visible = 'visible';

                    update(app.specData, 'UserData:ReportFields', 'Creation', idxThreads, app.channelObj)
                    report_TreeBuilding(app)
                    report_SaveWarn(app)

                    app.progressDialog.Visible = 'hidden';
                end
            end

        end

        % Menu selected function: report_ContextMenu_del
        function report_ContextMenu_delSelected(app, event)
            
            if ~isempty(app.report_Tree.SelectedNodes)
                idx = unique([app.report_Tree.SelectedNodes.NodeData]);
                update(app.specData, 'UserData:ReportFields', 'Delete', idx)

                report_TreeBuilding(app)
                report_SaveWarn(app)
            end

        end

        % Value changed function: report_DetectionManualMode
        function report_DetectionManualModeValueChanged(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;            
            update(app.specData(idx), 'UserData:ReportFields', 'ReportDetection:ManualMode:Edit', double(app.report_DetectionManualMode.Value))

            % Esse estado força a atualização do painel
            app.report_ThreadAlgorithms.UserData.idxThread = [];
            report_Algorithms(app, idx)

        end

        % Image clicked function: tool_ReportGenerator
        function report_playButtonPushed(app, event)
            
            % <VALIDATION>
            idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));

            if isempty(idxThreads)
                msgWarning = 'Necessário incluir ao menos um fluxo espectral na lista de fluxos a processar.';
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return

            elseif app.plotFlag
                msgWarning = 'Necessário interromper o playback antes de inicializar análise para geração do relatório.';
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return

            else
                switch app.report_Version.Value
                    case 'Definitiva'
                        % EMISSÃO AINDA PENDENTE DE IDENTIFICAÇÃO
                        classification = {};
                        for ii = idxThreads
                            classification{end+1} = arrayfun(@(x) x.userModified.EmissionType, app.specData(ii).UserData.Emissions.Classification, 'UniformOutput', false);
                        end
                        classification = vertcat(classification{:});

                        if any(contains(classification, 'Pendente', 'IgnoreCase', true))
                            msgWarning = sprintf(['Há ao menos uma emissão ainda pendente de identificação, o que inviabiliza a geração ' ...
                                                  'da versão definitiva do relatório.\n\nA identificação das emissões é realizada no módulo "Análise de sinais".']);
                            appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                            return
                        end

                        % INSPEÇÃO
                        if ~report_checkEFiscalizaIssueId(app)
                            msgWarning = sprintf('O número da inspeção "%.0f" é inválido.', app.report_Issue.Value);
                            appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                            return
                        end
        
                        msgQuestion   = sprintf('Confirma que se trata de monitoração relacionada à Atividade de Inspeção nº %.0f?', app.report_Issue.Value);
                        userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                        if userSelection == "Não"
                            return
                        end

                    case 'Preliminar'
                        % ...
                end
            end
            % </VALIDATION>

            reportLibConnection.Controller(app, 'Report')

            % Atualiza apps auxiliares...
            play_UpdateAuxiliarApps(app)

            % LAYOUT:
            % Esse modo "REPORT" pode detectar, automaticamente, novas
            % emissões. Essa informação é salva na própria app.specData.
            % Necesário, portanto, atualizar screen.
            if app.report_Version.Value ~= "Definitiva"
                app.play_Tree.SelectedNodes = app.play_PlotPanel.UserData;
                app.play_PlotPanel.UserData = [];
                play_TreeSelectionChanged(app)
            end

        end

        % Image clicked function: tool_FiscalizaUpdate
        function report_FiscalizaStaticButtonPushed(app, event)
    
            % <VALIDATION>
            msg = '';
            if all(~arrayfun(@(x) x.UserData.reportFlag, app.specData))
                msg = 'É necessário incluir pelo menos um fluxo espectral na lista de fluxos a processar.';
            elseif ~report_checkEFiscalizaIssueId(app)
                msg = sprintf('O número da inspeção "%.0f" é inválido.', app.report_Issue.Value);
            elseif isempty(app.report_Unit.Value)
                msg = 'Unidade geradora do documento precisa ser selecionada.';
            elseif isempty(app.projectData.generatedFiles) || isempty(app.projectData.generatedFiles.lastHTMLDocFullPath)
                msg = 'A versão definitiva do relatório ainda não foi gerada.';
            elseif ~isfile(app.projectData.generatedFiles.lastHTMLDocFullPath)
                msg = sprintf('O arquivo "%s" não foi encontrado.', app.projectData.generatedFiles.lastHTMLDocFullPath);
            elseif ~isfolder(app.General.fileFolder.DataHub_POST)
                msg = 'Pendente mapear pasta do Sharepoint';
            end

            if ~isempty(msg)
                appUtil.modalWindow(app.UIFigure, 'warning', msg);
                return
            end
            % </VALIDATION>

            % <PROCESS>
            if isempty(app.eFiscalizaObj)
                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'eFiscalizaSignInPage', 'Fields', dialogBox))
            else
                report_uploadInfoController(app, [], 'uploadDocument')
            end
            % </PROCESS>

        end

        % Image clicked function: report_ProjectNew, report_ProjectSave
        function report_ProjectToolbarImageClicked(app, event)
            
            switch event.Source
                case app.report_ProjectNew
                    if isempty(app.report_Tree.Children)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Operação aplicável apenas quando a lista de fluxos espectrais a processar não está vazia.');
                        return
                    end

                    msgQuestion   = 'Deseja excluir a lista de fluxos espectrais a processar, iniciando um novo projeto?';
                    userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        return
                    end
                    
                    DeleteProject(app, 'appAnalise:REPORT:NewProject')

                %---------------------------------------------------------%
                case app.report_ProjectSave
                    if isempty(app.report_Tree.Children)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Operação aplicável apenas quando a lista de fluxos espectrais a processar não está vazia.');
                        return
                    end

                    if ~isempty(app.report_ProjectName.Value{1})
                        defaultName = app.report_ProjectName.Value{1};
                    else
                        defaultName = appUtil.DefaultFileName(app.General.fileFolder.userPath, 'ProjectData', app.report_Issue.Value);
                    end

                    nameFormatMap = {'*.mat', 'appAnalise (*.mat)'};
                    [fileFullPath, ~, ~, fileName]  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
                    if isempty(fileFullPath)
                        return
                    end

                    reportTemplateIndex = find(strcmp(app.report_ModelName.Items, app.report_ModelName.Value), 1) - 1;
                    [idx, reportInfo]   = report.GeneralInfo(app, 'Report', reportTemplateIndex);
                    
                    generatedZIPFile = '';
                    if ~isempty(app.projectData.generatedFiles) && isfield(app.projectData.generatedFiles, 'lastZIPFullPath') && isfile(app.projectData.generatedFiles.lastZIPFullPath)
                        generatedZIPFile = app.projectData.generatedFiles.lastZIPFullPath;
                    end

                    prjInfo = struct('Name',           fileName,                        ...
                                     'reportInfo',     rmfield(reportInfo, 'Filename'), ...
                                     'generatedFiles', generatedZIPFile);
                    
                    misc_ExportDataToFile(app, fileFullPath, '.mat', 'ProjectData', app.specData(idx), prjInfo, {'callingApp', 'sortType'})
                    

                    app.report_ProjectName.Value = fileFullPath;
                    app.report_ProjectWarnIcon.Visible = 0;
            end

        end

        % Callback function: report_AddProjectAttachment, 
        % ...and 2 other components
        function report_ThreadAlgorithmsRefreshImageClicked(app, event)
            
            switch event.Source
                case app.report_EditDetection
                    menu_LayoutPopupApp(app, 'Detection')

                case app.report_EditClassification
                    menu_LayoutPopupApp(app, 'Classification')

                case app.report_AddProjectAttachment
                    idxTemplate = find(strcmp(app.General.Models.Name, app.report_ModelName.Value), 1);
                    if isempty(idxTemplate)
                        msgWarning = ['O modelo do relatório deve ser escolhido previamente à '  ...
                                      'inclusão de arquivos externos relacionados ao projeto e ' ...
                                      'aos fluxos espectrais a processar'];
                        appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                        return
                    end

                    idxTemplate = find(strcmp(app.General.Models.Name, app.report_ModelName.Value), 1);
                    if isempty(app.General.Models.ExternalFilesTags{idxTemplate})
                        TAGs = '';
                    else
                        TAGs = jsonencode(app.General.Models.ExternalFilesTags{idxTemplate});
                    end

                    menu_LayoutPopupApp(app, 'AddFiles', TAGs)
            end

        end

        % Value changed function: report_ModelName, report_Version
        function report_ModelOrVersionValueChanged(app, event)
            
            switch event.Source
                case app.report_ModelName
                    if isempty(app.report_ModelName.Value)
                        app.tool_ReportGenerator.Enable = 0;
                    else
                        app.tool_ReportGenerator.Enable = 1;
                    end

                case app.report_Version
                    switch app.report_Version.Value
                        case 'Definitiva'
                            app.report_ControlsTab1Info.RowHeight(end-1:end) = {0,0};
                            app.report_EditDetection.Visible       = 0;
                            app.report_EditClassification.Visible  = 0;
                            app.report_DetectionManualMode.Visible = 0;

                        otherwise
                            app.report_ControlsTab1Info.RowHeight(end-1:end) = {15,15};                            
                            app.report_EditDetection.Visible       = 1;
                            app.report_EditClassification.Visible  = 1;
                            app.report_DetectionManualMode.Visible = 1;
                    end
            end

        end

        % Button pushed function: misc_DeleteAll
        function misc_DeleteAllButtonPushed(app, event)

            msgQuestion   = ['Confirma a exclusão dos fluxos espectrais e das informações auxiliares ' ...
                             'a cada um dos fluxos, dentre elas a lista de exceções?'];
            userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            if userSelection == "Não"
                return
            end

            DeleteAll(app)

        end

        % Button pushed function: misc_AddCorrection, misc_Del, 
        % ...and 8 other components
        function misc_OperationsCallbacks(app, event)
            
            if app.plotFlag
                play_PlaybackToolbarButtonCallback(app, struct('Source', app.tool_Play))
            end

            idxThreads = unique([app.play_Tree.SelectedNodes.NodeData]);
            try
                switch event.Source
                    %-----------------------------------------------------%
                    case app.misc_Save
                        if isempty(misc_SaveSpectralData(app, idxThreads))
                            return
                        end

                    %-----------------------------------------------------%
                    case app.misc_Duplicate
                        for ii = 1:numel(idxThreads)
                            app.specData(end+1) = copy(app.specData(idxThreads(ii)), {});
                        end

                        app.specData = sort(app.specData);
                    
                    %-----------------------------------------------------%
                    case app.misc_Merge
                        if strcmp(auxAppStatus(app, 'MESCLAR FLUXOS'), 'Não')
                            return
                        end
                        
                        app.specData = merge(app.specData, idxThreads, app.UIFigure);

                        % Reinicia os valores de ocupação...
                        idxThread = idxThreads(1);
                        if ~isempty(app.specData(idxThread).UserData.occCache)
                            update(app.specData, 'UserData:OccupancyFields+ReportFields', 'Refresh', idxThread, app.channelObj)
                        end
    
                    %-----------------------------------------------------%
                    case app.misc_Del
                        if strcmp(auxAppStatus(app, 'EXCLUIR FLUXO(S)'), 'Não')
                            return
                        end

                        delete(app.specData(idxThreads))
                        app.specData(idxThreads) = [];

                        if isempty(app.specData)
                            DeleteAll(app)
                            return
                        end
    
                    %-----------------------------------------------------%
                    case app.misc_Export
                        misc_ExportUserData(app, idxThreads)
                        return
    
                    %-----------------------------------------------------%
                    case app.misc_Import
                        if strcmp(auxAppStatus(app, 'IMPORTAR ANÁLISE'), 'Não')
                            return
                        end

                        if isempty(misc_ImportUserData(app, idxThreads))
                            return
                        end

                    %-----------------------------------------------------%
                    case app.misc_TimeFiltering
                        if strcmp(auxAppStatus(app, 'FILTRAR FLUXO(S)'), 'Não')
                            return
                        end

                        menu_LayoutPopupApp(app, 'TimeFiltering', idxThreads)
                        return

                    %-----------------------------------------------------%
                    case app.misc_EditLocation
                        gpsArray = arrayfun(@(x) x.GPS, app.specData(idxThreads));
                        for ii = numel(gpsArray):-1:2
                            if isequal(gpsArray(ii), gpsArray(1))
                                gpsArray(ii) = [];
                            end
                        end
        
                        if numel(gpsArray) > 1
                            error(['A edição de informações relacionadas ao local de monitoração é '      ...
                                   'aplicável apenas quando selecionados fluxos espectrais relacionados ' ...
                                   'ao mesmo local.'])
                        end

                        if strcmp(auxAppStatus(app, 'EDITAR LOCAL'), 'Não')
                            return
                        end

                        menu_LayoutPopupApp(app, 'EditLocation', idxThreads)
                        return

                    %-----------------------------------------------------%
                    case app.misc_AddCorrection
                        if ~isscalar(idxThreads)
                            error(['A aplicação de uma curva de correção é possível apenas quando ' ...
                                   'selecionado um único fluxo espectral.'])
                        end

                        if strcmp(auxAppStatus(app, 'APLICAR CORREÇÃO'), 'Não')
                            return
                        end
                        
                        menu_LayoutPopupApp(app, 'AddKFactor', idxThreads)
                        return

                    %-----------------------------------------------------%
                    case app.misc_DeleteInvalidSweeps
                        if strcmp(auxAppStatus(app, 'EXCLUIR VARREDURAS INVÁLIDAS'), 'Não')
                            return
                        end

                        misc_DeleteInvalidSweepsController(app, idxThreads)
                end

                SelectedNodesTextList = misc_SelectedNodesText(app);
                play_TreeRebuilding(app, SelectedNodesTextList)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
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
            app.GridLayout.RowHeight = {54, '1x', 44};
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
            app.Tab1_File.Title = 'FILE';

            % Create file_Grid
            app.file_Grid = uigridlayout(app.Tab1_File);
            app.file_Grid.ColumnWidth = {10, 320, '1x', 10, 320, 16, 10};
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
            app.file_toolGrid.Padding = [5 6 5 6];
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

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.file_Grid);
            app.TabGroup2.AutoResizeChildren = 'off';
            app.TabGroup2.Layout.Row = 1;
            app.TabGroup2.Layout.Column = [2 6];

            % Create ARQUIVOSTab
            app.ARQUIVOSTab = uitab(app.TabGroup2);
            app.ARQUIVOSTab.AutoResizeChildren = 'off';
            app.ARQUIVOSTab.Title = 'ARQUIVOS';
            app.ARQUIVOSTab.BackgroundColor = 'none';
            app.ARQUIVOSTab.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ARQUIVOSTab);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create NOMEDAEMPRESAMetadadosOutrascoisasLabel
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel = uilabel(app.GridLayout2);
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.VerticalAlignment = 'top';
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.WordWrap = 'on';
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.FontSize = 11;
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.FontColor = [0.149 0.149 0.149];
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.Layout.Row = 1;
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.Layout.Column = 1;
            app.NOMEDAEMPRESAMetadadosOutrascoisasLabel.Text = 'Este aplicativo permite a leitura de arquivos gerados em monitorações do espectro de radiofrequências usando o appColeta, Logger, Argus e CelPlan, organizando as informações por faixa de frequência. Também realiza detecção e classificação de emissões, comparando com informações constantes no RFDataHub. E, por fim, possibilita anotação dos dados e geração de relatório.';

            % Create FILTROTab
            app.FILTROTab = uitab(app.TabGroup2);
            app.FILTROTab.Title = 'FILTRO';

            % Create file_FilteringGrid
            app.file_FilteringGrid = uigridlayout(app.FILTROTab);
            app.file_FilteringGrid.ColumnWidth = {320, 22, 320};
            app.file_FilteringGrid.RowSpacing = 5;
            app.file_FilteringGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create file_FilteringType
            app.file_FilteringType = uidropdown(app.file_FilteringGrid);
            app.file_FilteringType.Items = {'Faixa de Frequência', 'ID', 'Descrição'};
            app.file_FilteringType.ValueChangedFcn = createCallbackFcn(app, @file_FilteringTypeChanged, true);
            app.file_FilteringType.FontSize = 11;
            app.file_FilteringType.BackgroundColor = [1 1 1];
            app.file_FilteringType.Layout.Row = 1;
            app.file_FilteringType.Layout.Column = 1;
            app.file_FilteringType.Value = 'Faixa de Frequência';

            % Create file_FilteringValue_Description
            app.file_FilteringValue_Description = uieditfield(app.file_FilteringGrid, 'text');
            app.file_FilteringValue_Description.FontSize = 11;
            app.file_FilteringValue_Description.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringValue_Description.Visible = 'off';
            app.file_FilteringValue_Description.Layout.Row = 2;
            app.file_FilteringValue_Description.Layout.Column = 1;

            % Create file_FilteringValue_ID
            app.file_FilteringValue_ID = uidropdown(app.file_FilteringGrid);
            app.file_FilteringValue_ID.Items = {};
            app.file_FilteringValue_ID.Visible = 'off';
            app.file_FilteringValue_ID.FontSize = 11;
            app.file_FilteringValue_ID.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringValue_ID.BackgroundColor = [1 1 1];
            app.file_FilteringValue_ID.Layout.Row = 2;
            app.file_FilteringValue_ID.Layout.Column = 1;
            app.file_FilteringValue_ID.Value = {};

            % Create file_FilteringValue_Frequency
            app.file_FilteringValue_Frequency = uidropdown(app.file_FilteringGrid);
            app.file_FilteringValue_Frequency.Items = {};
            app.file_FilteringValue_Frequency.FontSize = 11;
            app.file_FilteringValue_Frequency.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringValue_Frequency.BackgroundColor = [1 1 1];
            app.file_FilteringValue_Frequency.Layout.Row = 2;
            app.file_FilteringValue_Frequency.Layout.Column = 1;
            app.file_FilteringValue_Frequency.Value = {};

            % Create file_FilteringAdd
            app.file_FilteringAdd = uiimage(app.file_FilteringGrid);
            app.file_FilteringAdd.ScaleMethod = 'none';
            app.file_FilteringAdd.ImageClickedFcn = createCallbackFcn(app, @file_FilteringAddClicked, true);
            app.file_FilteringAdd.Tooltip = {'Aplica filtro ao conjunto de dados'};
            app.file_FilteringAdd.Layout.Row = [1 2];
            app.file_FilteringAdd.Layout.Column = 2;
            app.file_FilteringAdd.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Continue_16.png');

            % Create file_FilteringTree
            app.file_FilteringTree = uitree(app.file_FilteringGrid);
            app.file_FilteringTree.Multiselect = 'on';
            app.file_FilteringTree.FontSize = 10;
            app.file_FilteringTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.file_FilteringTree.Layout.Row = [1 2];
            app.file_FilteringTree.Layout.Column = 3;

            % Create Tab2_Playback
            app.Tab2_Playback = uitab(app.TabGroup);
            app.Tab2_Playback.AutoResizeChildren = 'off';
            app.Tab2_Playback.Title = 'PLAYBACK+REPORT+MISC';

            % Create play_Grid
            app.play_Grid = uigridlayout(app.Tab2_Playback);
            app.play_Grid.ColumnWidth = {10, 320, 10, '1x', 198, 5, 10, 320, 10};
            app.play_Grid.RowHeight = {23, 3, 5, 22, 5, 176, '1x', 5, 22, 5, '1x', 10, 34};
            app.play_Grid.ColumnSpacing = 0;
            app.play_Grid.RowSpacing = 0;
            app.play_Grid.Padding = [0 0 0 40];
            app.play_Grid.BackgroundColor = [1 1 1];

            % Create play_PlotPanel
            app.play_PlotPanel = uipanel(app.play_Grid);
            app.play_PlotPanel.AutoResizeChildren = 'off';
            app.play_PlotPanel.BorderType = 'none';
            app.play_PlotPanel.BackgroundColor = [0 0 0];
            app.play_PlotPanel.Layout.Row = [1 11];
            app.play_PlotPanel.Layout.Column = [4 6];

            % Create play_axesToolbar
            app.play_axesToolbar = uigridlayout(app.play_Grid);
            app.play_axesToolbar.ColumnWidth = {'1x', 22, 22, 22, 22, 22, 22, 22, 22, 22, '1x'};
            app.play_axesToolbar.RowHeight = {'1x'};
            app.play_axesToolbar.ColumnSpacing = 0;
            app.play_axesToolbar.RowSpacing = 0;
            app.play_axesToolbar.Padding = [0 2 0 2];
            app.play_axesToolbar.Layout.Row = 1;
            app.play_axesToolbar.Layout.Column = 5;
            app.play_axesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_MinHold
            app.axesTool_MinHold = uiimage(app.play_axesToolbar);
            app.axesTool_MinHold.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_MinHold.Tag = 'MinHold';
            app.axesTool_MinHold.Tooltip = {'MinHold'};
            app.axesTool_MinHold.Layout.Row = 1;
            app.axesTool_MinHold.Layout.Column = 5;
            app.axesTool_MinHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MinHold_32.png');

            % Create axesTool_Average
            app.axesTool_Average = uiimage(app.play_axesToolbar);
            app.axesTool_Average.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_Average.Tag = 'Average';
            app.axesTool_Average.Tooltip = {'Média'};
            app.axesTool_Average.Layout.Row = 1;
            app.axesTool_Average.Layout.Column = 6;
            app.axesTool_Average.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Average_32.png');

            % Create axesTool_MaxHold
            app.axesTool_MaxHold = uiimage(app.play_axesToolbar);
            app.axesTool_MaxHold.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_MaxHold.Tag = 'MaxHold';
            app.axesTool_MaxHold.Tooltip = {'MaxHold'};
            app.axesTool_MaxHold.Layout.Row = 1;
            app.axesTool_MaxHold.Layout.Column = 7;
            app.axesTool_MaxHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MaxHold_32.png');

            % Create axesTool_Persistance
            app.axesTool_Persistance = uiimage(app.play_axesToolbar);
            app.axesTool_Persistance.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_Persistance.Tag = 'Persistance';
            app.axesTool_Persistance.Tooltip = {'Persistência'};
            app.axesTool_Persistance.Layout.Row = 1;
            app.axesTool_Persistance.Layout.Column = 8;
            app.axesTool_Persistance.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Persistance_36.png');

            % Create axesTool_Occupancy
            app.axesTool_Occupancy = uiimage(app.play_axesToolbar);
            app.axesTool_Occupancy.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_Occupancy.Tag = 'Ocuppancy';
            app.axesTool_Occupancy.Tooltip = {'Ocupação'};
            app.axesTool_Occupancy.Layout.Row = 1;
            app.axesTool_Occupancy.Layout.Column = 9;
            app.axesTool_Occupancy.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Occupancy_32Gray.png');

            % Create axesTool_Waterfall
            app.axesTool_Waterfall = uiimage(app.play_axesToolbar);
            app.axesTool_Waterfall.ScaleMethod = 'none';
            app.axesTool_Waterfall.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_Waterfall.Tag = 'Waterfall';
            app.axesTool_Waterfall.Tooltip = {'Waterfall'};
            app.axesTool_Waterfall.Layout.Row = 1;
            app.axesTool_Waterfall.Layout.Column = 10;
            app.axesTool_Waterfall.HorizontalAlignment = 'left';
            app.axesTool_Waterfall.VerticalAlignment = 'bottom';
            app.axesTool_Waterfall.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Waterfall_24.png');

            % Create axesTool_DataTip
            app.axesTool_DataTip = uiimage(app.play_axesToolbar);
            app.axesTool_DataTip.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_DataTip.Enable = 'off';
            app.axesTool_DataTip.Tooltip = {'DataCursorMode'; '(restrito à Waterfall:Image)'};
            app.axesTool_DataTip.Layout.Row = 1;
            app.axesTool_DataTip.Layout.Column = 4;
            app.axesTool_DataTip.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'DataTip_22.png');

            % Create axesTool_Pan
            app.axesTool_Pan = uiimage(app.play_axesToolbar);
            app.axesTool_Pan.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_Pan.Tooltip = {'Pan'};
            app.axesTool_Pan.Layout.Row = 1;
            app.axesTool_Pan.Layout.Column = 3;
            app.axesTool_Pan.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Pan_32.png');

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.play_axesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @play_AxesToolbarCallbacks, true);
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Home_18.png');

            % Create play_ControlsGrid
            app.play_ControlsGrid = uigridlayout(app.play_Grid);
            app.play_ControlsGrid.ColumnWidth = {'1x'};
            app.play_ControlsGrid.RowHeight = {26, '1x', '1x', '1x', 0, 0};
            app.play_ControlsGrid.ColumnSpacing = 5;
            app.play_ControlsGrid.RowSpacing = 5;
            app.play_ControlsGrid.Padding = [0 0 0 0];
            app.play_ControlsGrid.Layout.Row = [1 11];
            app.play_ControlsGrid.Layout.Column = 8;
            app.play_ControlsGrid.BackgroundColor = [1 1 1];

            % Create play_ControlsTab1Info
            app.play_ControlsTab1Info = uigridlayout(app.play_ControlsGrid);
            app.play_ControlsTab1Info.ColumnWidth = {'1x'};
            app.play_ControlsTab1Info.RowHeight = {22, 174, 22, 32, 112, '1x', 200, 1, 14};
            app.play_ControlsTab1Info.ColumnSpacing = 5;
            app.play_ControlsTab1Info.RowSpacing = 5;
            app.play_ControlsTab1Info.Padding = [0 0 0 0];
            app.play_ControlsTab1Info.Layout.Row = 2;
            app.play_ControlsTab1Info.Layout.Column = 1;
            app.play_ControlsTab1Info.BackgroundColor = [1 1 1];

            % Create play_GeneralPanelLabel
            app.play_GeneralPanelLabel = uilabel(app.play_ControlsTab1Info);
            app.play_GeneralPanelLabel.VerticalAlignment = 'bottom';
            app.play_GeneralPanelLabel.FontSize = 10;
            app.play_GeneralPanelLabel.Layout.Row = 1;
            app.play_GeneralPanelLabel.Layout.Column = 1;
            app.play_GeneralPanelLabel.Text = 'ASPECTOS GERAIS';

            % Create play_GeneralPanel
            app.play_GeneralPanel = uipanel(app.play_ControlsTab1Info);
            app.play_GeneralPanel.AutoResizeChildren = 'off';
            app.play_GeneralPanel.BackgroundColor = [1 1 1];
            app.play_GeneralPanel.Layout.Row = 2;
            app.play_GeneralPanel.Layout.Column = 1;

            % Create play_OthersGrid
            app.play_OthersGrid = uigridlayout(app.play_GeneralPanel);
            app.play_OthersGrid.ColumnWidth = {'1x', '1x', '1x', 46, 16};
            app.play_OthersGrid.RowHeight = {26, 22, 17, '1x'};
            app.play_OthersGrid.RowSpacing = 5;
            app.play_OthersGrid.BackgroundColor = [1 1 1];

            % Create play_LayoutRatioLabel
            app.play_LayoutRatioLabel = uilabel(app.play_OthersGrid);
            app.play_LayoutRatioLabel.VerticalAlignment = 'bottom';
            app.play_LayoutRatioLabel.WordWrap = 'on';
            app.play_LayoutRatioLabel.FontSize = 10;
            app.play_LayoutRatioLabel.Layout.Row = 1;
            app.play_LayoutRatioLabel.Layout.Column = [1 2];
            app.play_LayoutRatioLabel.Text = {'Razão aspecto'; 'dos eixos:'};

            % Create play_LayoutRatio
            app.play_LayoutRatio = uidropdown(app.play_OthersGrid);
            app.play_LayoutRatio.Items = {'1:0:0'};
            app.play_LayoutRatio.ValueChangedFcn = createCallbackFcn(app, @play_ControlButtonPushed, true);
            app.play_LayoutRatio.FontSize = 11;
            app.play_LayoutRatio.BackgroundColor = [1 1 1];
            app.play_LayoutRatio.Layout.Row = 2;
            app.play_LayoutRatio.Layout.Column = 1;
            app.play_LayoutRatio.Value = '1:0:0';

            % Create play_LineVisibilityLabel
            app.play_LineVisibilityLabel = uilabel(app.play_OthersGrid);
            app.play_LineVisibilityLabel.VerticalAlignment = 'bottom';
            app.play_LineVisibilityLabel.WordWrap = 'on';
            app.play_LineVisibilityLabel.FontSize = 10;
            app.play_LineVisibilityLabel.Layout.Row = 1;
            app.play_LineVisibilityLabel.Layout.Column = 2;
            app.play_LineVisibilityLabel.Text = 'Visibilidade ClearWrite:';

            % Create play_LineVisibility
            app.play_LineVisibility = uidropdown(app.play_OthersGrid);
            app.play_LineVisibility.Items = {'on', 'off'};
            app.play_LineVisibility.ValueChangedFcn = createCallbackFcn(app, @play_LineVisibilityValueChanged, true);
            app.play_LineVisibility.FontSize = 11;
            app.play_LineVisibility.BackgroundColor = [1 1 1];
            app.play_LineVisibility.Layout.Row = 2;
            app.play_LineVisibility.Layout.Column = 2;
            app.play_LineVisibility.Value = 'on';

            % Create play_MinPlotTimeLabel
            app.play_MinPlotTimeLabel = uilabel(app.play_OthersGrid);
            app.play_MinPlotTimeLabel.VerticalAlignment = 'bottom';
            app.play_MinPlotTimeLabel.WordWrap = 'on';
            app.play_MinPlotTimeLabel.FontSize = 10;
            app.play_MinPlotTimeLabel.Layout.Row = 1;
            app.play_MinPlotTimeLabel.Layout.Column = [3 4];
            app.play_MinPlotTimeLabel.Text = {'Tempo mínimo'; 'escrita (ms):'};

            % Create play_MinPlotTime
            app.play_MinPlotTime = uispinner(app.play_OthersGrid);
            app.play_MinPlotTime.Step = 25;
            app.play_MinPlotTime.Limits = [50 1000];
            app.play_MinPlotTime.RoundFractionalValues = 'on';
            app.play_MinPlotTime.ValueDisplayFormat = '%.0f';
            app.play_MinPlotTime.FontSize = 11;
            app.play_MinPlotTime.Layout.Row = 2;
            app.play_MinPlotTime.Layout.Column = 3;
            app.play_MinPlotTime.Value = 50;

            % Create play_TraceIntegrationLabel
            app.play_TraceIntegrationLabel = uilabel(app.play_OthersGrid);
            app.play_TraceIntegrationLabel.VerticalAlignment = 'bottom';
            app.play_TraceIntegrationLabel.WordWrap = 'on';
            app.play_TraceIntegrationLabel.FontSize = 10;
            app.play_TraceIntegrationLabel.Layout.Row = 1;
            app.play_TraceIntegrationLabel.Layout.Column = [4 5];
            app.play_TraceIntegrationLabel.Text = 'Fator integração:';

            % Create play_TraceIntegration
            app.play_TraceIntegration = uidropdown(app.play_OthersGrid);
            app.play_TraceIntegration.Items = {'3', '10', '100', 'Inf'};
            app.play_TraceIntegration.ValueChangedFcn = createCallbackFcn(app, @play_TraceIntegrationValueChanged, true);
            app.play_TraceIntegration.FontSize = 11;
            app.play_TraceIntegration.BackgroundColor = [1 1 1];
            app.play_TraceIntegration.Layout.Row = 2;
            app.play_TraceIntegration.Layout.Column = [4 5];
            app.play_TraceIntegration.Value = 'Inf';

            % Create play_LimitsPanelLabel
            app.play_LimitsPanelLabel = uilabel(app.play_OthersGrid);
            app.play_LimitsPanelLabel.VerticalAlignment = 'bottom';
            app.play_LimitsPanelLabel.FontSize = 10;
            app.play_LimitsPanelLabel.Layout.Row = 3;
            app.play_LimitsPanelLabel.Layout.Column = 1;
            app.play_LimitsPanelLabel.Text = 'Limites';

            % Create play_LimitsRefresh
            app.play_LimitsRefresh = uiimage(app.play_OthersGrid);
            app.play_LimitsRefresh.ScaleMethod = 'none';
            app.play_LimitsRefresh.ImageClickedFcn = createCallbackFcn(app, @play_LimitsRefreshImageClicked, true);
            app.play_LimitsRefresh.Tooltip = {'Retorna à configuração padrão'};
            app.play_LimitsRefresh.Layout.Row = 3;
            app.play_LimitsRefresh.Layout.Column = 5;
            app.play_LimitsRefresh.HorizontalAlignment = 'right';
            app.play_LimitsRefresh.VerticalAlignment = 'bottom';
            app.play_LimitsRefresh.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Refresh_18.png');

            % Create play_LimitsPanel
            app.play_LimitsPanel = uipanel(app.play_OthersGrid);
            app.play_LimitsPanel.AutoResizeChildren = 'off';
            app.play_LimitsPanel.Layout.Row = 4;
            app.play_LimitsPanel.Layout.Column = [1 5];

            % Create play_LimitsGrid
            app.play_LimitsGrid = uigridlayout(app.play_LimitsPanel);
            app.play_LimitsGrid.ColumnWidth = {'1x', 70, '1x'};
            app.play_LimitsGrid.RowHeight = {22, 22};
            app.play_LimitsGrid.RowSpacing = 5;
            app.play_LimitsGrid.BackgroundColor = [1 1 1];

            % Create play_Limits_xLim1
            app.play_Limits_xLim1 = uispinner(app.play_LimitsGrid);
            app.play_Limits_xLim1.ValueDisplayFormat = '%.3f';
            app.play_Limits_xLim1.ValueChangedFcn = createCallbackFcn(app, @play_xLimitsValueChanged, true);
            app.play_Limits_xLim1.Tag = 'FreqStart';
            app.play_Limits_xLim1.FontSize = 11;
            app.play_Limits_xLim1.Tooltip = {''};
            app.play_Limits_xLim1.Layout.Row = 1;
            app.play_Limits_xLim1.Layout.Column = 1;

            % Create play_Limits_xLimLabel
            app.play_Limits_xLimLabel = uilabel(app.play_LimitsGrid);
            app.play_Limits_xLimLabel.HorizontalAlignment = 'center';
            app.play_Limits_xLimLabel.FontSize = 10;
            app.play_Limits_xLimLabel.Layout.Row = 1;
            app.play_Limits_xLimLabel.Layout.Column = 2;
            app.play_Limits_xLimLabel.Text = 'Frequência';

            % Create play_Limits_xLim2
            app.play_Limits_xLim2 = uispinner(app.play_LimitsGrid);
            app.play_Limits_xLim2.ValueDisplayFormat = '%.3f';
            app.play_Limits_xLim2.ValueChangedFcn = createCallbackFcn(app, @play_xLimitsValueChanged, true);
            app.play_Limits_xLim2.Tag = 'FreqStop';
            app.play_Limits_xLim2.FontSize = 11;
            app.play_Limits_xLim2.Tooltip = {''};
            app.play_Limits_xLim2.Layout.Row = 1;
            app.play_Limits_xLim2.Layout.Column = 3;

            % Create play_Limits_yLim1
            app.play_Limits_yLim1 = uispinner(app.play_LimitsGrid);
            app.play_Limits_yLim1.Step = 5;
            app.play_Limits_yLim1.ValueDisplayFormat = '%.1f';
            app.play_Limits_yLim1.ValueChangedFcn = createCallbackFcn(app, @play_yLimitsValueChanged, true);
            app.play_Limits_yLim1.Tag = 'MinLevel';
            app.play_Limits_yLim1.FontSize = 11;
            app.play_Limits_yLim1.Tooltip = {''};
            app.play_Limits_yLim1.Layout.Row = 2;
            app.play_Limits_yLim1.Layout.Column = 1;

            % Create play_Limits_yLimLabel
            app.play_Limits_yLimLabel = uilabel(app.play_LimitsGrid);
            app.play_Limits_yLimLabel.HorizontalAlignment = 'center';
            app.play_Limits_yLimLabel.FontSize = 10;
            app.play_Limits_yLimLabel.Layout.Row = 2;
            app.play_Limits_yLimLabel.Layout.Column = 2;
            app.play_Limits_yLimLabel.Text = 'Nível';

            % Create play_Limits_yLim2
            app.play_Limits_yLim2 = uispinner(app.play_LimitsGrid);
            app.play_Limits_yLim2.Step = 5;
            app.play_Limits_yLim2.ValueDisplayFormat = '%.1f';
            app.play_Limits_yLim2.ValueChangedFcn = createCallbackFcn(app, @play_yLimitsValueChanged, true);
            app.play_Limits_yLim2.Tag = 'MaxLevel';
            app.play_Limits_yLim2.FontSize = 11;
            app.play_Limits_yLim2.Tooltip = {''};
            app.play_Limits_yLim2.Layout.Row = 2;
            app.play_Limits_yLim2.Layout.Column = 3;

            % Create play_ControlPanelLabel
            app.play_ControlPanelLabel = uilabel(app.play_ControlsTab1Info);
            app.play_ControlPanelLabel.VerticalAlignment = 'bottom';
            app.play_ControlPanelLabel.FontSize = 10;
            app.play_ControlPanelLabel.Layout.Row = 3;
            app.play_ControlPanelLabel.Layout.Column = 1;
            app.play_ControlPanelLabel.Text = 'CONTROLES';

            % Create play_ControlsPanel
            app.play_ControlsPanel = uibuttongroup(app.play_ControlsTab1Info);
            app.play_ControlsPanel.AutoResizeChildren = 'off';
            app.play_ControlsPanel.SelectionChangedFcn = createCallbackFcn(app, @play_ControlsPanelSelectionChanged, true);
            app.play_ControlsPanel.BackgroundColor = [1 1 1];
            app.play_ControlsPanel.Layout.Row = 4;
            app.play_ControlsPanel.Layout.Column = 1;
            app.play_ControlsPanel.FontWeight = 'bold';
            app.play_ControlsPanel.FontSize = 10;

            % Create play_RadioButton_Persistance
            app.play_RadioButton_Persistance = uiradiobutton(app.play_ControlsPanel);
            app.play_RadioButton_Persistance.Text = 'Persistência';
            app.play_RadioButton_Persistance.FontSize = 10.5;
            app.play_RadioButton_Persistance.Position = [11 5 79 22];
            app.play_RadioButton_Persistance.Value = true;

            % Create play_RadioButton_Occupancy
            app.play_RadioButton_Occupancy = uiradiobutton(app.play_ControlsPanel);
            app.play_RadioButton_Occupancy.Text = 'Ocupação';
            app.play_RadioButton_Occupancy.FontSize = 10.5;
            app.play_RadioButton_Occupancy.Position = [114 5 70 22];

            % Create play_RadioButton_Waterfall
            app.play_RadioButton_Waterfall = uiradiobutton(app.play_ControlsPanel);
            app.play_RadioButton_Waterfall.Text = 'Waterfall';
            app.play_RadioButton_Waterfall.FontSize = 10.5;
            app.play_RadioButton_Waterfall.Position = [216 5 83 22];

            % Create play_Persistance_Panel
            app.play_Persistance_Panel = uipanel(app.play_ControlsTab1Info);
            app.play_Persistance_Panel.AutoResizeChildren = 'off';
            app.play_Persistance_Panel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.play_Persistance_Panel.Layout.Row = 5;
            app.play_Persistance_Panel.Layout.Column = 1;

            % Create play_PersistanceGrid
            app.play_PersistanceGrid = uigridlayout(app.play_Persistance_Panel);
            app.play_PersistanceGrid.ColumnWidth = {'1x', '1x', 67, 16};
            app.play_PersistanceGrid.RowHeight = {17, 22, 17, 22};
            app.play_PersistanceGrid.RowSpacing = 5;
            app.play_PersistanceGrid.Padding = [10 10 10 5];
            app.play_PersistanceGrid.BackgroundColor = [1 1 1];

            % Create play_Persistance_InterpolationLabel
            app.play_Persistance_InterpolationLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_InterpolationLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_InterpolationLabel.FontSize = 10;
            app.play_Persistance_InterpolationLabel.Layout.Row = 1;
            app.play_Persistance_InterpolationLabel.Layout.Column = 1;
            app.play_Persistance_InterpolationLabel.Text = 'Interpolação:';

            % Create play_Persistance_Interpolation
            app.play_Persistance_Interpolation = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_Interpolation.Items = {'nearest', 'bilinear'};
            app.play_Persistance_Interpolation.ValueChangedFcn = createCallbackFcn(app, @play_Persistance_Callbacks, true);
            app.play_Persistance_Interpolation.FontSize = 11;
            app.play_Persistance_Interpolation.BackgroundColor = [1 1 1];
            app.play_Persistance_Interpolation.Layout.Row = 2;
            app.play_Persistance_Interpolation.Layout.Column = 1;
            app.play_Persistance_Interpolation.Value = 'nearest';

            % Create play_Persistance_WindowSizeLabel
            app.play_Persistance_WindowSizeLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_WindowSizeLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_WindowSizeLabel.FontSize = 10;
            app.play_Persistance_WindowSizeLabel.Layout.Row = 1;
            app.play_Persistance_WindowSizeLabel.Layout.Column = 2;
            app.play_Persistance_WindowSizeLabel.Text = 'Janela:';

            % Create play_Persistance_WindowSizeValue
            app.play_Persistance_WindowSizeValue = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_WindowSizeValue.HorizontalAlignment = 'right';
            app.play_Persistance_WindowSizeValue.VerticalAlignment = 'bottom';
            app.play_Persistance_WindowSizeValue.FontSize = 10;
            app.play_Persistance_WindowSizeValue.FontColor = [0.8 0.8 0.8];
            app.play_Persistance_WindowSizeValue.Layout.Row = 1;
            app.play_Persistance_WindowSizeValue.Layout.Column = 2;
            app.play_Persistance_WindowSizeValue.Text = 'full';

            % Create play_Persistance_WindowSize
            app.play_Persistance_WindowSize = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_WindowSize.Items = {'128', '256', '512', 'full'};
            app.play_Persistance_WindowSize.ValueChangedFcn = createCallbackFcn(app, @play_Persistance_Callbacks, true);
            app.play_Persistance_WindowSize.FontSize = 11;
            app.play_Persistance_WindowSize.BackgroundColor = [1 1 1];
            app.play_Persistance_WindowSize.Layout.Row = 2;
            app.play_Persistance_WindowSize.Layout.Column = 2;
            app.play_Persistance_WindowSize.Value = 'full';

            % Create play_Persistance_ColormapLabel
            app.play_Persistance_ColormapLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_ColormapLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_ColormapLabel.FontSize = 10;
            app.play_Persistance_ColormapLabel.Layout.Row = 1;
            app.play_Persistance_ColormapLabel.Layout.Column = [3 4];
            app.play_Persistance_ColormapLabel.Text = 'Mapa de cor:';

            % Create play_Persistance_Colormap
            app.play_Persistance_Colormap = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_Colormap.Items = {'winter', 'parula', 'turbo'};
            app.play_Persistance_Colormap.ValueChangedFcn = createCallbackFcn(app, @play_Persistance_Callbacks, true);
            app.play_Persistance_Colormap.FontSize = 11;
            app.play_Persistance_Colormap.BackgroundColor = [1 1 1];
            app.play_Persistance_Colormap.Layout.Row = 2;
            app.play_Persistance_Colormap.Layout.Column = [3 4];
            app.play_Persistance_Colormap.Value = 'winter';

            % Create play_Persistance_TransparencyLabel
            app.play_Persistance_TransparencyLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_TransparencyLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_TransparencyLabel.WordWrap = 'on';
            app.play_Persistance_TransparencyLabel.FontSize = 10;
            app.play_Persistance_TransparencyLabel.Layout.Row = 3;
            app.play_Persistance_TransparencyLabel.Layout.Column = 1;
            app.play_Persistance_TransparencyLabel.Text = 'Transparência:';

            % Create play_Persistance_Transparency
            app.play_Persistance_Transparency = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_Transparency.Step = 0.05;
            app.play_Persistance_Transparency.Limits = [0.2 1];
            app.play_Persistance_Transparency.ValueDisplayFormat = '%.2f';
            app.play_Persistance_Transparency.ValueChangedFcn = createCallbackFcn(app, @play_Persistance_Callbacks, true);
            app.play_Persistance_Transparency.FontSize = 11;
            app.play_Persistance_Transparency.Layout.Row = 4;
            app.play_Persistance_Transparency.Layout.Column = 1;
            app.play_Persistance_Transparency.Value = 1;

            % Create play_Persistance_cLim_Label
            app.play_Persistance_cLim_Label = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Label.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Label.FontSize = 10;
            app.play_Persistance_cLim_Label.Layout.Row = 3;
            app.play_Persistance_cLim_Label.Layout.Column = 2;
            app.play_Persistance_cLim_Label.Text = 'Limites (%):';

            % Create play_Persistance_cLim_Mode
            app.play_Persistance_cLim_Mode = uiimage(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Mode.ScaleMethod = 'none';
            app.play_Persistance_cLim_Mode.ImageClickedFcn = createCallbackFcn(app, @play_Persistance_Callbacks, true);
            app.play_Persistance_cLim_Mode.Enable = 'off';
            app.play_Persistance_cLim_Mode.Tooltip = {'Retorna à configuração padrão'};
            app.play_Persistance_cLim_Mode.Layout.Row = 3;
            app.play_Persistance_cLim_Mode.Layout.Column = 4;
            app.play_Persistance_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Persistance_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Mode.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Refresh_18.png');

            % Create play_Persistance_cLim_Grid2
            app.play_Persistance_cLim_Grid2 = uigridlayout(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Grid2.ColumnWidth = {'1x', 10, '1x'};
            app.play_Persistance_cLim_Grid2.RowHeight = {'1x'};
            app.play_Persistance_cLim_Grid2.ColumnSpacing = 0;
            app.play_Persistance_cLim_Grid2.RowSpacing = 5;
            app.play_Persistance_cLim_Grid2.Padding = [0 0 0 0];
            app.play_Persistance_cLim_Grid2.Layout.Row = 4;
            app.play_Persistance_cLim_Grid2.Layout.Column = [2 4];
            app.play_Persistance_cLim_Grid2.BackgroundColor = [1 1 1];

            % Create play_Persistance_cLim1
            app.play_Persistance_cLim1 = uispinner(app.play_Persistance_cLim_Grid2);
            app.play_Persistance_cLim1.Step = 0.1;
            app.play_Persistance_cLim1.Limits = [0 Inf];
            app.play_Persistance_cLim1.ValueDisplayFormat = '%.3f';
            app.play_Persistance_cLim1.ValueChangedFcn = createCallbackFcn(app, @play_Persistance_cLimValueChanged, true);
            app.play_Persistance_cLim1.FontSize = 11;
            app.play_Persistance_cLim1.Enable = 'off';
            app.play_Persistance_cLim1.Tooltip = {''};
            app.play_Persistance_cLim1.Layout.Row = 1;
            app.play_Persistance_cLim1.Layout.Column = 1;

            % Create play_Persistance_cLim2
            app.play_Persistance_cLim2 = uispinner(app.play_Persistance_cLim_Grid2);
            app.play_Persistance_cLim2.Limits = [0 Inf];
            app.play_Persistance_cLim2.ValueDisplayFormat = '%.3f';
            app.play_Persistance_cLim2.ValueChangedFcn = createCallbackFcn(app, @play_Persistance_cLimValueChanged, true);
            app.play_Persistance_cLim2.FontSize = 11;
            app.play_Persistance_cLim2.Enable = 'off';
            app.play_Persistance_cLim2.Tooltip = {''};
            app.play_Persistance_cLim2.Layout.Row = 1;
            app.play_Persistance_cLim2.Layout.Column = 3;
            app.play_Persistance_cLim2.Value = 1;

            % Create play_Persistance_cLim_Separation
            app.play_Persistance_cLim_Separation = uilabel(app.play_Persistance_cLim_Grid2);
            app.play_Persistance_cLim_Separation.HorizontalAlignment = 'center';
            app.play_Persistance_cLim_Separation.FontSize = 10;
            app.play_Persistance_cLim_Separation.Enable = 'off';
            app.play_Persistance_cLim_Separation.Layout.Row = 1;
            app.play_Persistance_cLim_Separation.Layout.Column = 2;
            app.play_Persistance_cLim_Separation.Text = '-';

            % Create play_OCC_Panel
            app.play_OCC_Panel = uipanel(app.play_ControlsTab1Info);
            app.play_OCC_Panel.AutoResizeChildren = 'off';
            app.play_OCC_Panel.BackgroundColor = [1 1 1];
            app.play_OCC_Panel.Layout.Row = 6;
            app.play_OCC_Panel.Layout.Column = 1;

            % Create play_OCCGrid
            app.play_OCCGrid = uigridlayout(app.play_OCC_Panel);
            app.play_OCCGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.play_OCCGrid.RowHeight = {17, 22, 17, 22, 17, '1x'};
            app.play_OCCGrid.RowSpacing = 5;
            app.play_OCCGrid.Padding = [10 10 10 5];
            app.play_OCCGrid.BackgroundColor = [1 1 1];

            % Create play_OCC_MethodLabel
            app.play_OCC_MethodLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_MethodLabel.VerticalAlignment = 'bottom';
            app.play_OCC_MethodLabel.FontSize = 10;
            app.play_OCC_MethodLabel.Layout.Row = 1;
            app.play_OCC_MethodLabel.Layout.Column = [1 2];
            app.play_OCC_MethodLabel.Text = 'Tipo de threshold:';

            % Create play_OCC_Method
            app.play_OCC_Method = uidropdown(app.play_OCCGrid);
            app.play_OCC_Method.Items = {'Linear fixo (COLETA)', 'Linear fixo', 'Linear adaptativo', 'Envoltória do ruído'};
            app.play_OCC_Method.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_Method.FontSize = 11;
            app.play_OCC_Method.BackgroundColor = [1 1 1];
            app.play_OCC_Method.Layout.Row = 2;
            app.play_OCC_Method.Layout.Column = [1 2];
            app.play_OCC_Method.Value = 'Linear fixo (COLETA)';

            % Create play_OCC_IntegrationTimeLabel
            app.play_OCC_IntegrationTimeLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_IntegrationTimeLabel.VerticalAlignment = 'bottom';
            app.play_OCC_IntegrationTimeLabel.WordWrap = 'on';
            app.play_OCC_IntegrationTimeLabel.FontSize = 10;
            app.play_OCC_IntegrationTimeLabel.Layout.Row = 1;
            app.play_OCC_IntegrationTimeLabel.Layout.Column = 3;
            app.play_OCC_IntegrationTimeLabel.Text = 'Integração (min):';

            % Create play_OCC_IntegrationTime
            app.play_OCC_IntegrationTime = uidropdown(app.play_OCCGrid);
            app.play_OCC_IntegrationTime.Items = {'1', '5', '15', '30', '60', 'Inf'};
            app.play_OCC_IntegrationTime.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_IntegrationTime.Tag = 'Factor';
            app.play_OCC_IntegrationTime.FontSize = 11;
            app.play_OCC_IntegrationTime.BackgroundColor = [1 1 1];
            app.play_OCC_IntegrationTime.Layout.Row = 2;
            app.play_OCC_IntegrationTime.Layout.Column = 3;
            app.play_OCC_IntegrationTime.Value = '15';

            % Create play_OCC_IntegrationTimeCaptured
            app.play_OCC_IntegrationTimeCaptured = uieditfield(app.play_OCCGrid, 'numeric');
            app.play_OCC_IntegrationTimeCaptured.Limits = [0 Inf];
            app.play_OCC_IntegrationTimeCaptured.ValueDisplayFormat = '%.0f';
            app.play_OCC_IntegrationTimeCaptured.Editable = 'off';
            app.play_OCC_IntegrationTimeCaptured.HorizontalAlignment = 'left';
            app.play_OCC_IntegrationTimeCaptured.FontSize = 11;
            app.play_OCC_IntegrationTimeCaptured.Visible = 'off';
            app.play_OCC_IntegrationTimeCaptured.Layout.Row = 2;
            app.play_OCC_IntegrationTimeCaptured.Layout.Column = 3;

            % Create play_OCC_OrientationLabel
            app.play_OCC_OrientationLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_OrientationLabel.VerticalAlignment = 'bottom';
            app.play_OCC_OrientationLabel.FontSize = 10;
            app.play_OCC_OrientationLabel.Layout.Row = 3;
            app.play_OCC_OrientationLabel.Layout.Column = 1;
            app.play_OCC_OrientationLabel.Text = 'Orientação:';

            % Create play_OCC_Orientation
            app.play_OCC_Orientation = uidropdown(app.play_OCCGrid);
            app.play_OCC_Orientation.Items = {'bin'};
            app.play_OCC_Orientation.FontSize = 11;
            app.play_OCC_Orientation.BackgroundColor = [1 1 1];
            app.play_OCC_Orientation.Layout.Row = 4;
            app.play_OCC_Orientation.Layout.Column = 1;
            app.play_OCC_Orientation.Value = 'bin';

            % Create play_OCC_THRLabel
            app.play_OCC_THRLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_THRLabel.Tag = 'THR';
            app.play_OCC_THRLabel.VerticalAlignment = 'bottom';
            app.play_OCC_THRLabel.WordWrap = 'on';
            app.play_OCC_THRLabel.FontSize = 10;
            app.play_OCC_THRLabel.Layout.Row = 3;
            app.play_OCC_THRLabel.Layout.Column = 2;
            app.play_OCC_THRLabel.Text = 'Valor (dBm):';

            % Create play_OCC_THR
            app.play_OCC_THR = uispinner(app.play_OCCGrid);
            app.play_OCC_THR.RoundFractionalValues = 'on';
            app.play_OCC_THR.ValueDisplayFormat = '%d';
            app.play_OCC_THR.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_THR.Tag = 'THR';
            app.play_OCC_THR.FontSize = 11;
            app.play_OCC_THR.Layout.Row = 4;
            app.play_OCC_THR.Layout.Column = 2;
            app.play_OCC_THR.Value = -80;

            % Create play_OCC_THRCaptured
            app.play_OCC_THRCaptured = uidropdown(app.play_OCCGrid);
            app.play_OCC_THRCaptured.Items = {};
            app.play_OCC_THRCaptured.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_THRCaptured.Tag = 'Factor';
            app.play_OCC_THRCaptured.Visible = 'off';
            app.play_OCC_THRCaptured.FontSize = 11;
            app.play_OCC_THRCaptured.BackgroundColor = [1 1 1];
            app.play_OCC_THRCaptured.Layout.Row = 4;
            app.play_OCC_THRCaptured.Layout.Column = 2;
            app.play_OCC_THRCaptured.Value = {};

            % Create play_OCC_OffsetLabel
            app.play_OCC_OffsetLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_OffsetLabel.Tag = 'Offset';
            app.play_OCC_OffsetLabel.VerticalAlignment = 'bottom';
            app.play_OCC_OffsetLabel.WordWrap = 'on';
            app.play_OCC_OffsetLabel.FontSize = 10;
            app.play_OCC_OffsetLabel.Visible = 'off';
            app.play_OCC_OffsetLabel.Layout.Row = 3;
            app.play_OCC_OffsetLabel.Layout.Column = 2;
            app.play_OCC_OffsetLabel.Text = 'OffSet (dB):';

            % Create play_OCC_Offset
            app.play_OCC_Offset = uispinner(app.play_OCCGrid);
            app.play_OCC_Offset.Limits = [3 30];
            app.play_OCC_Offset.RoundFractionalValues = 'on';
            app.play_OCC_Offset.ValueDisplayFormat = '%d';
            app.play_OCC_Offset.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_Offset.Tag = 'Offset';
            app.play_OCC_Offset.FontSize = 11;
            app.play_OCC_Offset.Visible = 'off';
            app.play_OCC_Offset.Layout.Row = 4;
            app.play_OCC_Offset.Layout.Column = 2;
            app.play_OCC_Offset.Value = 12;

            % Create play_OCC_ceilFactorLabel
            app.play_OCC_ceilFactorLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_ceilFactorLabel.Tag = 'Factor';
            app.play_OCC_ceilFactorLabel.VerticalAlignment = 'bottom';
            app.play_OCC_ceilFactorLabel.FontSize = 10;
            app.play_OCC_ceilFactorLabel.Visible = 'off';
            app.play_OCC_ceilFactorLabel.Layout.Row = 3;
            app.play_OCC_ceilFactorLabel.Layout.Column = 3;
            app.play_OCC_ceilFactorLabel.Text = 'Ceifamento:';

            % Create play_OCC_ceilFactor
            app.play_OCC_ceilFactor = uidropdown(app.play_OCCGrid);
            app.play_OCC_ceilFactor.Items = {'1𝜎', '2𝜎', '3𝜎'};
            app.play_OCC_ceilFactor.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_ceilFactor.Tag = 'Factor';
            app.play_OCC_ceilFactor.Visible = 'off';
            app.play_OCC_ceilFactor.FontSize = 11;
            app.play_OCC_ceilFactor.BackgroundColor = [1 1 1];
            app.play_OCC_ceilFactor.Layout.Row = 4;
            app.play_OCC_ceilFactor.Layout.Column = 3;
            app.play_OCC_ceilFactor.Value = '2𝜎';

            % Create play_OCC_noiseLabel
            app.play_OCC_noiseLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_noiseLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseLabel.FontSize = 10;
            app.play_OCC_noiseLabel.Visible = 'off';
            app.play_OCC_noiseLabel.Layout.Row = 5;
            app.play_OCC_noiseLabel.Layout.Column = [1 3];
            app.play_OCC_noiseLabel.Text = 'Parâmetros relacionados à estimativa do piso de ruído:';

            % Create play_OCC_noisePanel
            app.play_OCC_noisePanel = uipanel(app.play_OCCGrid);
            app.play_OCC_noisePanel.AutoResizeChildren = 'off';
            app.play_OCC_noisePanel.Visible = 'off';
            app.play_OCC_noisePanel.Layout.Row = 6;
            app.play_OCC_noisePanel.Layout.Column = [1 3];

            % Create play_OCC_noiseGrid
            app.play_OCC_noiseGrid = uigridlayout(app.play_OCC_noisePanel);
            app.play_OCC_noiseGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.play_OCC_noiseGrid.RowHeight = {17, 22};
            app.play_OCC_noiseGrid.RowSpacing = 4;
            app.play_OCC_noiseGrid.Padding = [10 10 10 5];
            app.play_OCC_noiseGrid.BackgroundColor = [1 1 1];

            % Create play_OCC_noiseFcnLabel
            app.play_OCC_noiseFcnLabel = uilabel(app.play_OCC_noiseGrid);
            app.play_OCC_noiseFcnLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseFcnLabel.FontSize = 10;
            app.play_OCC_noiseFcnLabel.Layout.Row = 1;
            app.play_OCC_noiseFcnLabel.Layout.Column = [1 2];
            app.play_OCC_noiseFcnLabel.Text = 'Função estatística:';

            % Create play_OCC_noiseFcn
            app.play_OCC_noiseFcn = uidropdown(app.play_OCC_noiseGrid);
            app.play_OCC_noiseFcn.Items = {'mean', 'median'};
            app.play_OCC_noiseFcn.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_noiseFcn.FontSize = 11;
            app.play_OCC_noiseFcn.BackgroundColor = [1 1 1];
            app.play_OCC_noiseFcn.Layout.Row = 2;
            app.play_OCC_noiseFcn.Layout.Column = 1;
            app.play_OCC_noiseFcn.Value = 'mean';

            % Create play_OCC_noiseTrashSamplesLabel
            app.play_OCC_noiseTrashSamplesLabel = uilabel(app.play_OCC_noiseGrid);
            app.play_OCC_noiseTrashSamplesLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseTrashSamplesLabel.WordWrap = 'on';
            app.play_OCC_noiseTrashSamplesLabel.FontSize = 10;
            app.play_OCC_noiseTrashSamplesLabel.Layout.Row = 1;
            app.play_OCC_noiseTrashSamplesLabel.Layout.Column = [2 3];
            app.play_OCC_noiseTrashSamplesLabel.Text = 'Descartadas (%):';

            % Create play_OCC_noiseTrashSamples
            app.play_OCC_noiseTrashSamples = uispinner(app.play_OCC_noiseGrid);
            app.play_OCC_noiseTrashSamples.Limits = [0 10];
            app.play_OCC_noiseTrashSamples.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_noiseTrashSamples.FontSize = 11;
            app.play_OCC_noiseTrashSamples.Layout.Row = 2;
            app.play_OCC_noiseTrashSamples.Layout.Column = 2;

            % Create play_OCC_noiseUsefulSamplesLabel
            app.play_OCC_noiseUsefulSamplesLabel = uilabel(app.play_OCC_noiseGrid);
            app.play_OCC_noiseUsefulSamplesLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseUsefulSamplesLabel.WordWrap = 'on';
            app.play_OCC_noiseUsefulSamplesLabel.FontSize = 10;
            app.play_OCC_noiseUsefulSamplesLabel.Layout.Row = 1;
            app.play_OCC_noiseUsefulSamplesLabel.Layout.Column = 3;
            app.play_OCC_noiseUsefulSamplesLabel.Text = 'Úteis (%):';

            % Create play_OCC_noiseUsefulSamples
            app.play_OCC_noiseUsefulSamples = uispinner(app.play_OCC_noiseGrid);
            app.play_OCC_noiseUsefulSamples.Limits = [10 90];
            app.play_OCC_noiseUsefulSamples.ValueChangedFcn = createCallbackFcn(app, @play_Occupancy_Callbacks, true);
            app.play_OCC_noiseUsefulSamples.FontSize = 11;
            app.play_OCC_noiseUsefulSamples.Layout.Row = 2;
            app.play_OCC_noiseUsefulSamples.Layout.Column = 3;
            app.play_OCC_noiseUsefulSamples.Value = 20;

            % Create play_Waterfall_Panel
            app.play_Waterfall_Panel = uipanel(app.play_ControlsTab1Info);
            app.play_Waterfall_Panel.AutoResizeChildren = 'off';
            app.play_Waterfall_Panel.Layout.Row = 7;
            app.play_Waterfall_Panel.Layout.Column = 1;

            % Create play_WaterFallGrid
            app.play_WaterFallGrid = uigridlayout(app.play_Waterfall_Panel);
            app.play_WaterFallGrid.ColumnWidth = {'1x', '1x', 67, 16};
            app.play_WaterFallGrid.RowHeight = {17, 22, 17, 22, 17, 22};
            app.play_WaterFallGrid.RowSpacing = 5;
            app.play_WaterFallGrid.Padding = [10 10 10 5];
            app.play_WaterFallGrid.BackgroundColor = [1 1 1];

            % Create play_Waterfall_FcnLabel
            app.play_Waterfall_FcnLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_FcnLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_FcnLabel.WordWrap = 'on';
            app.play_Waterfall_FcnLabel.FontSize = 10;
            app.play_Waterfall_FcnLabel.Layout.Row = 1;
            app.play_Waterfall_FcnLabel.Layout.Column = 1;
            app.play_Waterfall_FcnLabel.Text = 'Função:';

            % Create play_Waterfall_Fcn
            app.play_Waterfall_Fcn = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Fcn.Items = {'image', 'mesh'};
            app.play_Waterfall_Fcn.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_Callbacks, true);
            app.play_Waterfall_Fcn.FontSize = 11;
            app.play_Waterfall_Fcn.BackgroundColor = [1 1 1];
            app.play_Waterfall_Fcn.Layout.Row = 2;
            app.play_Waterfall_Fcn.Layout.Column = 1;
            app.play_Waterfall_Fcn.Value = 'image';

            % Create play_Waterfall_DecimationLabel
            app.play_Waterfall_DecimationLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_DecimationLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_DecimationLabel.FontSize = 10;
            app.play_Waterfall_DecimationLabel.Layout.Row = 1;
            app.play_Waterfall_DecimationLabel.Layout.Column = 2;
            app.play_Waterfall_DecimationLabel.Text = 'Decimação:';

            % Create play_Waterfall_DecimationValue
            app.play_Waterfall_DecimationValue = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_DecimationValue.HorizontalAlignment = 'right';
            app.play_Waterfall_DecimationValue.VerticalAlignment = 'bottom';
            app.play_Waterfall_DecimationValue.FontSize = 10;
            app.play_Waterfall_DecimationValue.FontColor = [0.8 0.8 0.8];
            app.play_Waterfall_DecimationValue.Layout.Row = 1;
            app.play_Waterfall_DecimationValue.Layout.Column = 2;
            app.play_Waterfall_DecimationValue.Text = 'auto';

            % Create play_Waterfall_Decimation
            app.play_Waterfall_Decimation = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Decimation.Items = {'auto', '1', '2', '4', '8', '16', '32', '64', '128', '256'};
            app.play_Waterfall_Decimation.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_Callbacks, true);
            app.play_Waterfall_Decimation.Enable = 'off';
            app.play_Waterfall_Decimation.FontSize = 11;
            app.play_Waterfall_Decimation.BackgroundColor = [1 1 1];
            app.play_Waterfall_Decimation.Layout.Row = 2;
            app.play_Waterfall_Decimation.Layout.Column = 2;
            app.play_Waterfall_Decimation.Value = 'auto';

            % Create play_Waterfall_TimelineLabel
            app.play_Waterfall_TimelineLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_TimelineLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_TimelineLabel.WordWrap = 'on';
            app.play_Waterfall_TimelineLabel.FontSize = 10;
            app.play_Waterfall_TimelineLabel.Layout.Row = 1;
            app.play_Waterfall_TimelineLabel.Layout.Column = [3 4];
            app.play_Waterfall_TimelineLabel.Text = 'Timeline:';

            % Create play_Waterfall_Timeline
            app.play_Waterfall_Timeline = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Timeline.Items = {'on', 'off'};
            app.play_Waterfall_Timeline.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_Callbacks, true);
            app.play_Waterfall_Timeline.FontSize = 11;
            app.play_Waterfall_Timeline.BackgroundColor = [1 1 1];
            app.play_Waterfall_Timeline.Layout.Row = 2;
            app.play_Waterfall_Timeline.Layout.Column = [3 4];
            app.play_Waterfall_Timeline.Value = 'on';

            % Create play_Waterfall_ColorbarLabel
            app.play_Waterfall_ColorbarLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_ColorbarLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_ColorbarLabel.FontSize = 10;
            app.play_Waterfall_ColorbarLabel.Layout.Row = 3;
            app.play_Waterfall_ColorbarLabel.Layout.Column = 1;
            app.play_Waterfall_ColorbarLabel.Text = 'Legenda de cor:';

            % Create play_Waterfall_Colorbar
            app.play_Waterfall_Colorbar = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Colorbar.Items = {'off', 'west', 'east', 'eastoutside'};
            app.play_Waterfall_Colorbar.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_ColorbarValueChanged, true);
            app.play_Waterfall_Colorbar.Enable = 'off';
            app.play_Waterfall_Colorbar.FontSize = 11;
            app.play_Waterfall_Colorbar.BackgroundColor = [1 1 1];
            app.play_Waterfall_Colorbar.Layout.Row = 4;
            app.play_Waterfall_Colorbar.Layout.Column = [1 2];
            app.play_Waterfall_Colorbar.Value = 'off';

            % Create play_Waterfall_ColormapLabel
            app.play_Waterfall_ColormapLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_ColormapLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_ColormapLabel.FontSize = 10;
            app.play_Waterfall_ColormapLabel.Layout.Row = 3;
            app.play_Waterfall_ColormapLabel.Layout.Column = [3 4];
            app.play_Waterfall_ColormapLabel.Text = 'Mapa de cor:';

            % Create play_Waterfall_Colormap
            app.play_Waterfall_Colormap = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.play_Waterfall_Colormap.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_Callbacks, true);
            app.play_Waterfall_Colormap.FontSize = 11;
            app.play_Waterfall_Colormap.BackgroundColor = [1 1 1];
            app.play_Waterfall_Colormap.Layout.Row = 4;
            app.play_Waterfall_Colormap.Layout.Column = [3 4];
            app.play_Waterfall_Colormap.Value = 'winter';

            % Create play_Waterfall_MeshStyleLabel
            app.play_Waterfall_MeshStyleLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_MeshStyleLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_MeshStyleLabel.WordWrap = 'on';
            app.play_Waterfall_MeshStyleLabel.FontSize = 10;
            app.play_Waterfall_MeshStyleLabel.Layout.Row = 5;
            app.play_Waterfall_MeshStyleLabel.Layout.Column = 1;
            app.play_Waterfall_MeshStyleLabel.Text = 'MeshStyle:';

            % Create play_Waterfall_MeshStyle
            app.play_Waterfall_MeshStyle = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_MeshStyle.Items = {'row', 'both'};
            app.play_Waterfall_MeshStyle.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_Callbacks, true);
            app.play_Waterfall_MeshStyle.Enable = 'off';
            app.play_Waterfall_MeshStyle.FontSize = 11;
            app.play_Waterfall_MeshStyle.BackgroundColor = [1 1 1];
            app.play_Waterfall_MeshStyle.Layout.Row = 6;
            app.play_Waterfall_MeshStyle.Layout.Column = 1;
            app.play_Waterfall_MeshStyle.Value = 'both';

            % Create play_Waterfall_cLim_Label
            app.play_Waterfall_cLim_Label = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Label.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Label.FontSize = 10;
            app.play_Waterfall_cLim_Label.Layout.Row = 5;
            app.play_Waterfall_cLim_Label.Layout.Column = 2;
            app.play_Waterfall_cLim_Label.Text = 'Limites (dB):';

            % Create play_Waterfall_cLim_Mode
            app.play_Waterfall_cLim_Mode = uiimage(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Mode.ScaleMethod = 'none';
            app.play_Waterfall_cLim_Mode.ImageClickedFcn = createCallbackFcn(app, @play_Waterfall_Callbacks, true);
            app.play_Waterfall_cLim_Mode.Enable = 'off';
            app.play_Waterfall_cLim_Mode.Layout.Row = 5;
            app.play_Waterfall_cLim_Mode.Layout.Column = 4;
            app.play_Waterfall_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Waterfall_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Mode.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Refresh_18.png');

            % Create play_Waterfall_cLim_Grid2
            app.play_Waterfall_cLim_Grid2 = uigridlayout(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Grid2.ColumnWidth = {'1x', 10, '1x'};
            app.play_Waterfall_cLim_Grid2.RowHeight = {'1x'};
            app.play_Waterfall_cLim_Grid2.ColumnSpacing = 0;
            app.play_Waterfall_cLim_Grid2.RowSpacing = 5;
            app.play_Waterfall_cLim_Grid2.Padding = [0 0 0 0];
            app.play_Waterfall_cLim_Grid2.Layout.Row = 6;
            app.play_Waterfall_cLim_Grid2.Layout.Column = [2 4];
            app.play_Waterfall_cLim_Grid2.BackgroundColor = [1 1 1];

            % Create play_Waterfall_cLim1
            app.play_Waterfall_cLim1 = uispinner(app.play_Waterfall_cLim_Grid2);
            app.play_Waterfall_cLim1.Step = 5;
            app.play_Waterfall_cLim1.RoundFractionalValues = 'on';
            app.play_Waterfall_cLim1.ValueDisplayFormat = '%.0f';
            app.play_Waterfall_cLim1.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_cLimValueChanged, true);
            app.play_Waterfall_cLim1.FontSize = 11;
            app.play_Waterfall_cLim1.Enable = 'off';
            app.play_Waterfall_cLim1.Tooltip = {''};
            app.play_Waterfall_cLim1.Layout.Row = 1;
            app.play_Waterfall_cLim1.Layout.Column = 1;

            % Create play_Waterfall_cLim_Separation
            app.play_Waterfall_cLim_Separation = uilabel(app.play_Waterfall_cLim_Grid2);
            app.play_Waterfall_cLim_Separation.HorizontalAlignment = 'center';
            app.play_Waterfall_cLim_Separation.FontSize = 10;
            app.play_Waterfall_cLim_Separation.Enable = 'off';
            app.play_Waterfall_cLim_Separation.Layout.Row = 1;
            app.play_Waterfall_cLim_Separation.Layout.Column = 2;
            app.play_Waterfall_cLim_Separation.Text = '-';

            % Create play_Waterfall_cLim2
            app.play_Waterfall_cLim2 = uispinner(app.play_Waterfall_cLim_Grid2);
            app.play_Waterfall_cLim2.Step = 5;
            app.play_Waterfall_cLim2.RoundFractionalValues = 'on';
            app.play_Waterfall_cLim2.ValueDisplayFormat = '%.0f';
            app.play_Waterfall_cLim2.ValueChangedFcn = createCallbackFcn(app, @play_Waterfall_cLimValueChanged, true);
            app.play_Waterfall_cLim2.FontSize = 11;
            app.play_Waterfall_cLim2.Enable = 'off';
            app.play_Waterfall_cLim2.Tooltip = {''};
            app.play_Waterfall_cLim2.Layout.Row = 1;
            app.play_Waterfall_cLim2.Layout.Column = 3;
            app.play_Waterfall_cLim2.Value = 1;

            % Create play_Customization
            app.play_Customization = uicheckbox(app.play_ControlsTab1Info);
            app.play_Customization.ValueChangedFcn = createCallbackFcn(app, @play_CustomizationValueChanged, true);
            app.play_Customization.Text = 'Customizar controles do plot.';
            app.play_Customization.WordWrap = 'on';
            app.play_Customization.FontSize = 11;
            app.play_Customization.Layout.Row = 9;
            app.play_Customization.Layout.Column = 1;

            % Create play_ControlsTab2Info
            app.play_ControlsTab2Info = uigridlayout(app.play_ControlsGrid);
            app.play_ControlsTab2Info.ColumnWidth = {'1x', 16, 16};
            app.play_ControlsTab2Info.RowHeight = {22, 36, 210, 80, 8, '1x', 22, 42, 8, '0.5x'};
            app.play_ControlsTab2Info.ColumnSpacing = 5;
            app.play_ControlsTab2Info.RowSpacing = 5;
            app.play_ControlsTab2Info.Padding = [0 0 0 0];
            app.play_ControlsTab2Info.Layout.Row = 3;
            app.play_ControlsTab2Info.Layout.Column = 1;
            app.play_ControlsTab2Info.BackgroundColor = [1 1 1];

            % Create play_Channel_Label
            app.play_Channel_Label = uilabel(app.play_ControlsTab2Info);
            app.play_Channel_Label.VerticalAlignment = 'bottom';
            app.play_Channel_Label.FontSize = 10;
            app.play_Channel_Label.FontColor = [0.149 0.149 0.149];
            app.play_Channel_Label.Layout.Row = 1;
            app.play_Channel_Label.Layout.Column = 1;
            app.play_Channel_Label.Text = 'INCLUSÃO DE CANAIS';

            % Create play_Channel_RadioGroup
            app.play_Channel_RadioGroup = uibuttongroup(app.play_ControlsTab2Info);
            app.play_Channel_RadioGroup.AutoResizeChildren = 'off';
            app.play_Channel_RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @play_Channel_RadioGroupSelectionChanged, true);
            app.play_Channel_RadioGroup.BackgroundColor = [1 1 1];
            app.play_Channel_RadioGroup.Layout.Row = 2;
            app.play_Channel_RadioGroup.Layout.Column = [1 3];
            app.play_Channel_RadioGroup.FontWeight = 'bold';
            app.play_Channel_RadioGroup.FontSize = 10;

            % Create play_Channel_ReferenceList
            app.play_Channel_ReferenceList = uiradiobutton(app.play_Channel_RadioGroup);
            app.play_Channel_ReferenceList.Text = {'Canalização'; 'de referência'};
            app.play_Channel_ReferenceList.FontSize = 10.5;
            app.play_Channel_ReferenceList.Position = [11 4 83 26];
            app.play_Channel_ReferenceList.Value = true;

            % Create play_Channel_Multiples
            app.play_Channel_Multiples = uiradiobutton(app.play_Channel_RadioGroup);
            app.play_Channel_Multiples.Text = {'Faixa de'; 'frequência'};
            app.play_Channel_Multiples.FontSize = 10.5;
            app.play_Channel_Multiples.Position = [105 4 71 26];

            % Create play_Channel_Single
            app.play_Channel_Single = uiradiobutton(app.play_Channel_RadioGroup);
            app.play_Channel_Single.Text = 'Canal';
            app.play_Channel_Single.FontSize = 10.5;
            app.play_Channel_Single.Position = [188 6 49 22];

            % Create play_Channel_File
            app.play_Channel_File = uiradiobutton(app.play_Channel_RadioGroup);
            app.play_Channel_File.Text = 'Arquivo';
            app.play_Channel_File.FontSize = 10.5;
            app.play_Channel_File.Position = [255 6 58 22];

            % Create play_Channel_Panel
            app.play_Channel_Panel = uipanel(app.play_ControlsTab2Info);
            app.play_Channel_Panel.AutoResizeChildren = 'off';
            app.play_Channel_Panel.Layout.Row = 3;
            app.play_Channel_Panel.Layout.Column = [1 3];

            % Create play_Channel_Grid
            app.play_Channel_Grid = uigridlayout(app.play_Channel_Panel);
            app.play_Channel_Grid.ColumnWidth = {'1x', '1x', 66, 16};
            app.play_Channel_Grid.RowHeight = {17, 22, 0, 27, 22, 27, 22, '1x'};
            app.play_Channel_Grid.RowSpacing = 5;
            app.play_Channel_Grid.Padding = [10 10 10 5];
            app.play_Channel_Grid.BackgroundColor = [1 1 1];

            % Create play_Channel_ListLabel
            app.play_Channel_ListLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_ListLabel.VerticalAlignment = 'bottom';
            app.play_Channel_ListLabel.FontSize = 10;
            app.play_Channel_ListLabel.Layout.Row = 1;
            app.play_Channel_ListLabel.Layout.Column = [1 2];
            app.play_Channel_ListLabel.Text = 'Referência:';

            % Create play_Channel_ListUpdate
            app.play_Channel_ListUpdate = uiimage(app.play_Channel_Grid);
            app.play_Channel_ListUpdate.ScaleMethod = 'none';
            app.play_Channel_ListUpdate.ImageClickedFcn = createCallbackFcn(app, @play_Channel_AutomaticChannelListUpdate, true);
            app.play_Channel_ListUpdate.Tooltip = {'Retorna à configuração padrão'};
            app.play_Channel_ListUpdate.Layout.Row = 1;
            app.play_Channel_ListUpdate.Layout.Column = 4;
            app.play_Channel_ListUpdate.VerticalAlignment = 'bottom';
            app.play_Channel_ListUpdate.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Refresh_18.png');

            % Create play_Channel_List
            app.play_Channel_List = uidropdown(app.play_Channel_Grid);
            app.play_Channel_List.Items = {};
            app.play_Channel_List.ValueChangedFcn = createCallbackFcn(app, @play_Channel_AutomaticChannelListValueChanged, true);
            app.play_Channel_List.FontSize = 11;
            app.play_Channel_List.BackgroundColor = [1 1 1];
            app.play_Channel_List.Layout.Row = 2;
            app.play_Channel_List.Layout.Column = [1 4];
            app.play_Channel_List.Value = {};

            % Create play_Channel_Name
            app.play_Channel_Name = uieditfield(app.play_Channel_Grid, 'text');
            app.play_Channel_Name.CharacterLimits = [0 128];
            app.play_Channel_Name.Layout.Row = 3;
            app.play_Channel_Name.Layout.Column = [1 4];

            % Create play_Channel_nChannelsLabel
            app.play_Channel_nChannelsLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_nChannelsLabel.VerticalAlignment = 'bottom';
            app.play_Channel_nChannelsLabel.WordWrap = 'on';
            app.play_Channel_nChannelsLabel.FontSize = 10;
            app.play_Channel_nChannelsLabel.Layout.Row = 4;
            app.play_Channel_nChannelsLabel.Layout.Column = 1;
            app.play_Channel_nChannelsLabel.Text = {'Qtd.'; 'canais:'};

            % Create play_Channel_nChannels
            app.play_Channel_nChannels = uieditfield(app.play_Channel_Grid, 'numeric');
            app.play_Channel_nChannels.Limits = [-1 Inf];
            app.play_Channel_nChannels.RoundFractionalValues = 'on';
            app.play_Channel_nChannels.ValueDisplayFormat = '%d';
            app.play_Channel_nChannels.Editable = 'off';
            app.play_Channel_nChannels.FontSize = 11;
            app.play_Channel_nChannels.Layout.Row = 5;
            app.play_Channel_nChannels.Layout.Column = 1;
            app.play_Channel_nChannels.Value = 1;

            % Create play_Channel_FirstChannelLabel
            app.play_Channel_FirstChannelLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_FirstChannelLabel.VerticalAlignment = 'bottom';
            app.play_Channel_FirstChannelLabel.WordWrap = 'on';
            app.play_Channel_FirstChannelLabel.FontSize = 10;
            app.play_Channel_FirstChannelLabel.Layout.Row = 4;
            app.play_Channel_FirstChannelLabel.Layout.Column = [2 4];
            app.play_Channel_FirstChannelLabel.Text = {'Frequência central'; '1º canal (MHz):'};

            % Create play_Channel_FirstChannel
            app.play_Channel_FirstChannel = uieditfield(app.play_Channel_Grid, 'numeric');
            app.play_Channel_FirstChannel.Limits = [0 Inf];
            app.play_Channel_FirstChannel.ValueDisplayFormat = '%.3f';
            app.play_Channel_FirstChannel.ValueChangedFcn = createCallbackFcn(app, @play_Channel_FirstChannelValueChanged, true);
            app.play_Channel_FirstChannel.FontSize = 11;
            app.play_Channel_FirstChannel.Layout.Row = 5;
            app.play_Channel_FirstChannel.Layout.Column = 2;

            % Create play_Channel_LastChannelLabel
            app.play_Channel_LastChannelLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_LastChannelLabel.VerticalAlignment = 'bottom';
            app.play_Channel_LastChannelLabel.WordWrap = 'on';
            app.play_Channel_LastChannelLabel.FontSize = 10;
            app.play_Channel_LastChannelLabel.Layout.Row = 4;
            app.play_Channel_LastChannelLabel.Layout.Column = [3 4];
            app.play_Channel_LastChannelLabel.Text = {'Frequência central'; 'n-ésimo canal:'};

            % Create play_Channel_LastChannel
            app.play_Channel_LastChannel = uieditfield(app.play_Channel_Grid, 'numeric');
            app.play_Channel_LastChannel.Limits = [0 Inf];
            app.play_Channel_LastChannel.ValueDisplayFormat = '%.3f';
            app.play_Channel_LastChannel.ValueChangedFcn = createCallbackFcn(app, @play_Channel_FirstChannelValueChanged, true);
            app.play_Channel_LastChannel.FontSize = 11;
            app.play_Channel_LastChannel.Layout.Row = 5;
            app.play_Channel_LastChannel.Layout.Column = [3 4];

            % Create play_Channel_ClassLabel
            app.play_Channel_ClassLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_ClassLabel.VerticalAlignment = 'bottom';
            app.play_Channel_ClassLabel.WordWrap = 'on';
            app.play_Channel_ClassLabel.FontSize = 10;
            app.play_Channel_ClassLabel.Layout.Row = 6;
            app.play_Channel_ClassLabel.Layout.Column = 1;
            app.play_Channel_ClassLabel.Text = {'Classe de '; 'emissão:'};

            % Create play_Channel_Class
            app.play_Channel_Class = uidropdown(app.play_Channel_Grid);
            app.play_Channel_Class.Items = {};
            app.play_Channel_Class.FontSize = 11;
            app.play_Channel_Class.BackgroundColor = [1 1 1];
            app.play_Channel_Class.Layout.Row = 7;
            app.play_Channel_Class.Layout.Column = 1;
            app.play_Channel_Class.Value = {};

            % Create play_Channel_StepWidthLabel
            app.play_Channel_StepWidthLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_StepWidthLabel.VerticalAlignment = 'bottom';
            app.play_Channel_StepWidthLabel.WordWrap = 'on';
            app.play_Channel_StepWidthLabel.FontSize = 10;
            app.play_Channel_StepWidthLabel.Layout.Row = 6;
            app.play_Channel_StepWidthLabel.Layout.Column = 2;
            app.play_Channel_StepWidthLabel.Text = {'Espaçamento '; 'canais (kHz):'};

            % Create play_Channel_StepWidth
            app.play_Channel_StepWidth = uieditfield(app.play_Channel_Grid, 'numeric');
            app.play_Channel_StepWidth.Limits = [-1 Inf];
            app.play_Channel_StepWidth.ValueDisplayFormat = '%.1f';
            app.play_Channel_StepWidth.ValueChangedFcn = createCallbackFcn(app, @play_Channel_FirstChannelValueChanged, true);
            app.play_Channel_StepWidth.FontSize = 11;
            app.play_Channel_StepWidth.Layout.Row = 7;
            app.play_Channel_StepWidth.Layout.Column = 2;

            % Create play_Channel_BWLabel
            app.play_Channel_BWLabel = uilabel(app.play_Channel_Grid);
            app.play_Channel_BWLabel.VerticalAlignment = 'bottom';
            app.play_Channel_BWLabel.WordWrap = 'on';
            app.play_Channel_BWLabel.FontSize = 10;
            app.play_Channel_BWLabel.Layout.Row = 6;
            app.play_Channel_BWLabel.Layout.Column = [3 4];
            app.play_Channel_BWLabel.Text = {'Largura canal'; '(kHz):'};

            % Create play_Channel_BW
            app.play_Channel_BW = uieditfield(app.play_Channel_Grid, 'numeric');
            app.play_Channel_BW.Limits = [-1 Inf];
            app.play_Channel_BW.ValueDisplayFormat = '%.1f';
            app.play_Channel_BW.FontSize = 11;
            app.play_Channel_BW.Layout.Row = 7;
            app.play_Channel_BW.Layout.Column = [3 4];

            % Create play_Channel_Sample
            app.play_Channel_Sample = uilabel(app.play_Channel_Grid);
            app.play_Channel_Sample.WordWrap = 'on';
            app.play_Channel_Sample.FontSize = 11;
            app.play_Channel_Sample.FontColor = [0.651 0.651 0.651];
            app.play_Channel_Sample.Layout.Row = 8;
            app.play_Channel_Sample.Layout.Column = [1 4];
            app.play_Channel_Sample.Interpreter = 'html';
            app.play_Channel_Sample.Text = '<p style="text-align: justify;">101.700 MHz, 101.900 MHz, 102.100 MHz, 102.300 MHz, 102.500 MHz, 102.700 MHz...</font>';

            % Create play_Channel_ExternalFilePanel
            app.play_Channel_ExternalFilePanel = uipanel(app.play_ControlsTab2Info);
            app.play_Channel_ExternalFilePanel.Layout.Row = 4;
            app.play_Channel_ExternalFilePanel.Layout.Column = [1 3];

            % Create play_Channel_ExternalFileGrid
            app.play_Channel_ExternalFileGrid = uigridlayout(app.play_Channel_ExternalFilePanel);
            app.play_Channel_ExternalFileGrid.ColumnWidth = {'1x'};
            app.play_Channel_ExternalFileGrid.RowHeight = {17, 22, '1x'};
            app.play_Channel_ExternalFileGrid.RowSpacing = 5;
            app.play_Channel_ExternalFileGrid.Padding = [10 10 10 5];
            app.play_Channel_ExternalFileGrid.BackgroundColor = [1 1 1];

            % Create play_Channel_ExternalFileLabel
            app.play_Channel_ExternalFileLabel = uilabel(app.play_Channel_ExternalFileGrid);
            app.play_Channel_ExternalFileLabel.VerticalAlignment = 'bottom';
            app.play_Channel_ExternalFileLabel.FontSize = 10;
            app.play_Channel_ExternalFileLabel.Layout.Row = 1;
            app.play_Channel_ExternalFileLabel.Layout.Column = 1;
            app.play_Channel_ExternalFileLabel.Text = 'Formato:';

            % Create play_Channel_ExternalFile
            app.play_Channel_ExternalFile = uidropdown(app.play_Channel_ExternalFileGrid);
            app.play_Channel_ExternalFile.Items = {'Generic (json)', 'Satellite (csv)'};
            app.play_Channel_ExternalFile.FontSize = 11;
            app.play_Channel_ExternalFile.BackgroundColor = [1 1 1];
            app.play_Channel_ExternalFile.Layout.Row = 2;
            app.play_Channel_ExternalFile.Layout.Column = 1;
            app.play_Channel_ExternalFile.Value = 'Generic (json)';

            % Create play_Channel_FileTemplate
            app.play_Channel_FileTemplate = uihyperlink(app.play_Channel_ExternalFileGrid);
            app.play_Channel_FileTemplate.HyperlinkClickedFcn = createCallbackFcn(app, @play_DownloadFileTemplate, true);
            app.play_Channel_FileTemplate.VerticalAlignment = 'top';
            app.play_Channel_FileTemplate.FontSize = 10;
            app.play_Channel_FileTemplate.Layout.Row = 3;
            app.play_Channel_FileTemplate.Layout.Column = 1;
            app.play_Channel_FileTemplate.Text = 'Download modelo do arquivo';

            % Create play_Channel_add
            app.play_Channel_add = uiimage(app.play_ControlsTab2Info);
            app.play_Channel_add.ScaleMethod = 'scaledown';
            app.play_Channel_add.ImageClickedFcn = createCallbackFcn(app, @play_Channel_addChannel, true);
            app.play_Channel_add.Layout.Row = 5;
            app.play_Channel_add.Layout.Column = 3;
            app.play_Channel_add.HorizontalAlignment = 'right';
            app.play_Channel_add.VerticalAlignment = 'bottom';
            app.play_Channel_add.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'addSymbol_32.png');

            % Create play_Channel_Tree
            app.play_Channel_Tree = uitree(app.play_ControlsTab2Info);
            app.play_Channel_Tree.Multiselect = 'on';
            app.play_Channel_Tree.SelectionChangedFcn = createCallbackFcn(app, @play_Channel_TreeSelectionChanged, true);
            app.play_Channel_Tree.FontSize = 10;
            app.play_Channel_Tree.Layout.Row = 6;
            app.play_Channel_Tree.Layout.Column = [1 3];

            % Create play_BandLimits_Status
            app.play_BandLimits_Status = uicheckbox(app.play_ControlsTab2Info);
            app.play_BandLimits_Status.ValueChangedFcn = createCallbackFcn(app, @play_BandLimits_StatusValueChanged, true);
            app.play_BandLimits_Status.Text = 'Limitar detecção de emissões a subfaixa(s)';
            app.play_BandLimits_Status.FontSize = 11;
            app.play_BandLimits_Status.Layout.Row = 7;
            app.play_BandLimits_Status.Layout.Column = [1 3];

            % Create play_BandLimits_Panel
            app.play_BandLimits_Panel = uipanel(app.play_ControlsTab2Info);
            app.play_BandLimits_Panel.AutoResizeChildren = 'off';
            app.play_BandLimits_Panel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.play_BandLimits_Panel.Layout.Row = 8;
            app.play_BandLimits_Panel.Layout.Column = [1 3];
            app.play_BandLimits_Panel.FontSize = 10;

            % Create play_BandLimits_Grid
            app.play_BandLimits_Grid = uigridlayout(app.play_BandLimits_Panel);
            app.play_BandLimits_Grid.ColumnWidth = {'1x', 70, '1x'};
            app.play_BandLimits_Grid.RowHeight = {22};
            app.play_BandLimits_Grid.RowSpacing = 5;
            app.play_BandLimits_Grid.BackgroundColor = [1 1 1];

            % Create play_BandLimits_xLim1
            app.play_BandLimits_xLim1 = uieditfield(app.play_BandLimits_Grid, 'numeric');
            app.play_BandLimits_xLim1.ValueDisplayFormat = '%.3f';
            app.play_BandLimits_xLim1.FontSize = 11;
            app.play_BandLimits_xLim1.Enable = 'off';
            app.play_BandLimits_xLim1.Layout.Row = 1;
            app.play_BandLimits_xLim1.Layout.Column = 1;

            % Create play_BandLimits_xLabel
            app.play_BandLimits_xLabel = uilabel(app.play_BandLimits_Grid);
            app.play_BandLimits_xLabel.HorizontalAlignment = 'center';
            app.play_BandLimits_xLabel.FontSize = 10;
            app.play_BandLimits_xLabel.Layout.Row = 1;
            app.play_BandLimits_xLabel.Layout.Column = 2;
            app.play_BandLimits_xLabel.Text = 'Frequência';

            % Create play_BandLimits_xLim2
            app.play_BandLimits_xLim2 = uieditfield(app.play_BandLimits_Grid, 'numeric');
            app.play_BandLimits_xLim2.ValueDisplayFormat = '%.3f';
            app.play_BandLimits_xLim2.FontSize = 11;
            app.play_BandLimits_xLim2.Enable = 'off';
            app.play_BandLimits_xLim2.Layout.Row = 1;
            app.play_BandLimits_xLim2.Layout.Column = 3;

            % Create play_BandLimits_add
            app.play_BandLimits_add = uiimage(app.play_ControlsTab2Info);
            app.play_BandLimits_add.ScaleMethod = 'scaledown';
            app.play_BandLimits_add.ImageClickedFcn = createCallbackFcn(app, @play_BandLimits_addImageClicked, true);
            app.play_BandLimits_add.Enable = 'off';
            app.play_BandLimits_add.Layout.Row = 9;
            app.play_BandLimits_add.Layout.Column = 3;
            app.play_BandLimits_add.HorizontalAlignment = 'right';
            app.play_BandLimits_add.VerticalAlignment = 'bottom';
            app.play_BandLimits_add.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'addSymbol_32.png');

            % Create play_BandLimits_Tree
            app.play_BandLimits_Tree = uitree(app.play_ControlsTab2Info);
            app.play_BandLimits_Tree.Multiselect = 'on';
            app.play_BandLimits_Tree.Enable = 'off';
            app.play_BandLimits_Tree.FontSize = 10;
            app.play_BandLimits_Tree.Layout.Row = 10;
            app.play_BandLimits_Tree.Layout.Column = [1 3];

            % Create play_Channel_ShowPlot
            app.play_Channel_ShowPlot = uiimage(app.play_ControlsTab2Info);
            app.play_Channel_ShowPlot.ImageClickedFcn = createCallbackFcn(app, @play_Channel_ShowPlotImageClicked, true);
            app.play_Channel_ShowPlot.Tooltip = {'Mostra canais no plot'};
            app.play_Channel_ShowPlot.Layout.Row = 1;
            app.play_Channel_ShowPlot.Layout.Column = 3;
            app.play_Channel_ShowPlot.VerticalAlignment = 'bottom';
            app.play_Channel_ShowPlot.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'EyeNegative_32.png');

            % Create play_ControlsTab3Info
            app.play_ControlsTab3Info = uigridlayout(app.play_ControlsGrid);
            app.play_ControlsTab3Info.ColumnWidth = {'1x', 100, 89, 16};
            app.play_ControlsTab3Info.RowHeight = {22, 36, 270, 80, 8, '1x', 22, 22, 44};
            app.play_ControlsTab3Info.ColumnSpacing = 5;
            app.play_ControlsTab3Info.RowSpacing = 5;
            app.play_ControlsTab3Info.Padding = [0 0 0 0];
            app.play_ControlsTab3Info.Layout.Row = 4;
            app.play_ControlsTab3Info.Layout.Column = 1;
            app.play_ControlsTab3Info.BackgroundColor = [1 1 1];

            % Create play_FindPeaks_Label
            app.play_FindPeaks_Label = uilabel(app.play_ControlsTab3Info);
            app.play_FindPeaks_Label.VerticalAlignment = 'bottom';
            app.play_FindPeaks_Label.FontSize = 10;
            app.play_FindPeaks_Label.FontColor = [0.149 0.149 0.149];
            app.play_FindPeaks_Label.Layout.Row = 1;
            app.play_FindPeaks_Label.Layout.Column = [1 3];
            app.play_FindPeaks_Label.Text = 'DETECÇÃO DE EMISSÕES';

            % Create play_FindPeaks_RadioGroup
            app.play_FindPeaks_RadioGroup = uibuttongroup(app.play_ControlsTab3Info);
            app.play_FindPeaks_RadioGroup.AutoResizeChildren = 'off';
            app.play_FindPeaks_RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @play_FindPeaks_RadioGroupSelectionChanged, true);
            app.play_FindPeaks_RadioGroup.BackgroundColor = [1 1 1];
            app.play_FindPeaks_RadioGroup.Layout.Row = 2;
            app.play_FindPeaks_RadioGroup.Layout.Column = [1 4];
            app.play_FindPeaks_RadioGroup.FontWeight = 'bold';
            app.play_FindPeaks_RadioGroup.FontSize = 10;

            % Create play_FindPeaks_auto
            app.play_FindPeaks_auto = uiradiobutton(app.play_FindPeaks_RadioGroup);
            app.play_FindPeaks_auto.Text = 'Automática';
            app.play_FindPeaks_auto.FontSize = 10.5;
            app.play_FindPeaks_auto.Position = [11 6 83 22];
            app.play_FindPeaks_auto.Value = true;

            % Create play_FindPeaks_ROI
            app.play_FindPeaks_ROI = uiradiobutton(app.play_FindPeaks_RadioGroup);
            app.play_FindPeaks_ROI.Text = 'ROI';
            app.play_FindPeaks_ROI.FontSize = 10.5;
            app.play_FindPeaks_ROI.Position = [105 6 41 22];

            % Create play_FindPeaks_DataTips
            app.play_FindPeaks_DataTips = uiradiobutton(app.play_FindPeaks_RadioGroup);
            app.play_FindPeaks_DataTips.Text = 'DataTips';
            app.play_FindPeaks_DataTips.FontSize = 10.5;
            app.play_FindPeaks_DataTips.Position = [168 6 64 22];

            % Create play_FindPeaks_File
            app.play_FindPeaks_File = uiradiobutton(app.play_FindPeaks_RadioGroup);
            app.play_FindPeaks_File.Text = 'Arquivo';
            app.play_FindPeaks_File.FontSize = 10.5;
            app.play_FindPeaks_File.Position = [255 6 58 22];

            % Create play_FindPeaks_ParametersPanel
            app.play_FindPeaks_ParametersPanel = uipanel(app.play_ControlsTab3Info);
            app.play_FindPeaks_ParametersPanel.AutoResizeChildren = 'off';
            app.play_FindPeaks_ParametersPanel.Layout.Row = 3;
            app.play_FindPeaks_ParametersPanel.Layout.Column = [1 4];

            % Create play_FindPeaks_ParametersGrid
            app.play_FindPeaks_ParametersGrid = uigridlayout(app.play_FindPeaks_ParametersPanel);
            app.play_FindPeaks_ParametersGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.play_FindPeaks_ParametersGrid.RowHeight = {17, 22, 25, 22, 25, 22, 88};
            app.play_FindPeaks_ParametersGrid.RowSpacing = 5;
            app.play_FindPeaks_ParametersGrid.Padding = [10 10 10 5];
            app.play_FindPeaks_ParametersGrid.BackgroundColor = [1 1 1];

            % Create play_FindPeaks_AlgorithmLabel
            app.play_FindPeaks_AlgorithmLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_AlgorithmLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_AlgorithmLabel.FontSize = 10;
            app.play_FindPeaks_AlgorithmLabel.Layout.Row = 1;
            app.play_FindPeaks_AlgorithmLabel.Layout.Column = [1 3];
            app.play_FindPeaks_AlgorithmLabel.Text = 'Algoritmo:';

            % Create play_FindPeaks_Algorithm
            app.play_FindPeaks_Algorithm = uidropdown(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_Algorithm.Items = {'FindPeaks', 'FindPeaks+OCC'};
            app.play_FindPeaks_Algorithm.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_AlgorithmValueChanged, true);
            app.play_FindPeaks_Algorithm.FontSize = 11;
            app.play_FindPeaks_Algorithm.BackgroundColor = [1 1 1];
            app.play_FindPeaks_Algorithm.Layout.Row = 2;
            app.play_FindPeaks_Algorithm.Layout.Column = [1 3];
            app.play_FindPeaks_Algorithm.Value = 'FindPeaks+OCC';

            % Create play_FindPeaks_TraceLabel
            app.play_FindPeaks_TraceLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_TraceLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_TraceLabel.FontSize = 10;
            app.play_FindPeaks_TraceLabel.Layout.Row = 3;
            app.play_FindPeaks_TraceLabel.Layout.Column = 1;
            app.play_FindPeaks_TraceLabel.Text = {'Tipo de '; 'traço:'};

            % Create play_FindPeaks_Trace
            app.play_FindPeaks_Trace = uidropdown(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_Trace.Items = {'MinHold', 'Média', 'MaxHold'};
            app.play_FindPeaks_Trace.FontSize = 11;
            app.play_FindPeaks_Trace.BackgroundColor = [1 1 1];
            app.play_FindPeaks_Trace.Layout.Row = 4;
            app.play_FindPeaks_Trace.Layout.Column = 1;
            app.play_FindPeaks_Trace.Value = 'Média';

            % Create play_FindPeaks_NumbersLabel
            app.play_FindPeaks_NumbersLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_NumbersLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_NumbersLabel.FontSize = 10;
            app.play_FindPeaks_NumbersLabel.Layout.Row = 3;
            app.play_FindPeaks_NumbersLabel.Layout.Column = 2;
            app.play_FindPeaks_NumbersLabel.Text = {'Número de '; 'picos:'};

            % Create play_FindPeaks_Numbers
            app.play_FindPeaks_Numbers = uispinner(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_Numbers.Limits = [1 100];
            app.play_FindPeaks_Numbers.RoundFractionalValues = 'on';
            app.play_FindPeaks_Numbers.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_Numbers.FontSize = 11;
            app.play_FindPeaks_Numbers.Layout.Row = 4;
            app.play_FindPeaks_Numbers.Layout.Column = 2;
            app.play_FindPeaks_Numbers.Value = 10;

            % Create play_FindPeaks_THRLabel
            app.play_FindPeaks_THRLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_THRLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_THRLabel.FontSize = 10;
            app.play_FindPeaks_THRLabel.Layout.Row = 3;
            app.play_FindPeaks_THRLabel.Layout.Column = 3;
            app.play_FindPeaks_THRLabel.Text = {'Threshold'; '(dB):'};

            % Create play_FindPeaks_THR
            app.play_FindPeaks_THR = uispinner(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_THR.Step = 10;
            app.play_FindPeaks_THR.RoundFractionalValues = 'on';
            app.play_FindPeaks_THR.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_THR.FontSize = 11;
            app.play_FindPeaks_THR.Layout.Row = 4;
            app.play_FindPeaks_THR.Layout.Column = 3;
            app.play_FindPeaks_THR.Value = -Inf;

            % Create play_FindPeaks_prominenceLabel
            app.play_FindPeaks_prominenceLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_prominenceLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_prominenceLabel.WordWrap = 'on';
            app.play_FindPeaks_prominenceLabel.FontSize = 10;
            app.play_FindPeaks_prominenceLabel.Layout.Row = 5;
            app.play_FindPeaks_prominenceLabel.Layout.Column = 1;
            app.play_FindPeaks_prominenceLabel.Text = {'Proeminência '; '(dB):'};

            % Create play_FindPeaks_prominence
            app.play_FindPeaks_prominence = uispinner(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_prominence.Step = 10;
            app.play_FindPeaks_prominence.Limits = [1 Inf];
            app.play_FindPeaks_prominence.RoundFractionalValues = 'on';
            app.play_FindPeaks_prominence.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_prominence.FontSize = 11;
            app.play_FindPeaks_prominence.Layout.Row = 6;
            app.play_FindPeaks_prominence.Layout.Column = 1;
            app.play_FindPeaks_prominence.Value = 30;

            % Create play_FindPeaks_ClassLabel
            app.play_FindPeaks_ClassLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_ClassLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_ClassLabel.FontSize = 10;
            app.play_FindPeaks_ClassLabel.Visible = 'off';
            app.play_FindPeaks_ClassLabel.Layout.Row = 5;
            app.play_FindPeaks_ClassLabel.Layout.Column = 1;
            app.play_FindPeaks_ClassLabel.Text = {'Classe de '; 'emissão:'};

            % Create play_FindPeaks_Class
            app.play_FindPeaks_Class = uidropdown(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_Class.Items = {};
            app.play_FindPeaks_Class.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_ClassValueChanged, true);
            app.play_FindPeaks_Class.Visible = 'off';
            app.play_FindPeaks_Class.FontSize = 11;
            app.play_FindPeaks_Class.BackgroundColor = [1 1 1];
            app.play_FindPeaks_Class.Layout.Row = 6;
            app.play_FindPeaks_Class.Layout.Column = 1;
            app.play_FindPeaks_Class.Value = {};

            % Create play_FindPeaks_distanceLabel
            app.play_FindPeaks_distanceLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_distanceLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_distanceLabel.WordWrap = 'on';
            app.play_FindPeaks_distanceLabel.FontSize = 10;
            app.play_FindPeaks_distanceLabel.Layout.Row = 5;
            app.play_FindPeaks_distanceLabel.Layout.Column = 2;
            app.play_FindPeaks_distanceLabel.Text = {'Distância entre'; 'picos (kHz):'};

            % Create play_FindPeaks_distance
            app.play_FindPeaks_distance = uispinner(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_distance.Step = 25;
            app.play_FindPeaks_distance.Limits = [0 Inf];
            app.play_FindPeaks_distance.RoundFractionalValues = 'on';
            app.play_FindPeaks_distance.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_distance.FontSize = 11;
            app.play_FindPeaks_distance.Layout.Row = 6;
            app.play_FindPeaks_distance.Layout.Column = 2;
            app.play_FindPeaks_distance.Value = 25;

            % Create play_FindPeaks_BWLabel
            app.play_FindPeaks_BWLabel = uilabel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_BWLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_BWLabel.WordWrap = 'on';
            app.play_FindPeaks_BWLabel.FontSize = 10;
            app.play_FindPeaks_BWLabel.Layout.Row = 5;
            app.play_FindPeaks_BWLabel.Layout.Column = 3;
            app.play_FindPeaks_BWLabel.Text = 'Largura ocupada (kHz):';

            % Create play_FindPeaks_BW
            app.play_FindPeaks_BW = uispinner(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_BW.Step = 10;
            app.play_FindPeaks_BW.Limits = [0 Inf];
            app.play_FindPeaks_BW.RoundFractionalValues = 'on';
            app.play_FindPeaks_BW.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_BW.FontSize = 11;
            app.play_FindPeaks_BW.Layout.Row = 6;
            app.play_FindPeaks_BW.Layout.Column = 3;
            app.play_FindPeaks_BW.Value = 10;

            % Create play_FindPeaks_MeanPanel
            app.play_FindPeaks_MeanPanel = uipanel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_MeanPanel.AutoResizeChildren = 'off';
            app.play_FindPeaks_MeanPanel.Title = 'MÉDIA';
            app.play_FindPeaks_MeanPanel.Layout.Row = 7;
            app.play_FindPeaks_MeanPanel.Layout.Column = 1;
            app.play_FindPeaks_MeanPanel.FontSize = 10;

            % Create play_FindPeaks_MeanGrid
            app.play_FindPeaks_MeanGrid = uigridlayout(app.play_FindPeaks_MeanPanel);
            app.play_FindPeaks_MeanGrid.ColumnWidth = {'1x'};
            app.play_FindPeaks_MeanGrid.RowHeight = {27, 22};
            app.play_FindPeaks_MeanGrid.RowSpacing = 5;
            app.play_FindPeaks_MeanGrid.Padding = [10 10 10 5];
            app.play_FindPeaks_MeanGrid.BackgroundColor = [1 1 1];

            % Create play_FindPeaks_Prominence1Label
            app.play_FindPeaks_Prominence1Label = uilabel(app.play_FindPeaks_MeanGrid);
            app.play_FindPeaks_Prominence1Label.VerticalAlignment = 'bottom';
            app.play_FindPeaks_Prominence1Label.WordWrap = 'on';
            app.play_FindPeaks_Prominence1Label.FontSize = 10;
            app.play_FindPeaks_Prominence1Label.Layout.Row = 1;
            app.play_FindPeaks_Prominence1Label.Layout.Column = 1;
            app.play_FindPeaks_Prominence1Label.Text = {'Proeminência'; '(dB):'};

            % Create play_FindPeaks_Prominence1
            app.play_FindPeaks_Prominence1 = uispinner(app.play_FindPeaks_MeanGrid);
            app.play_FindPeaks_Prominence1.Step = 10;
            app.play_FindPeaks_Prominence1.Limits = [1 Inf];
            app.play_FindPeaks_Prominence1.RoundFractionalValues = 'on';
            app.play_FindPeaks_Prominence1.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_Prominence1.FontSize = 11;
            app.play_FindPeaks_Prominence1.Layout.Row = 2;
            app.play_FindPeaks_Prominence1.Layout.Column = 1;
            app.play_FindPeaks_Prominence1.Value = 10;

            % Create play_FindPeaks_MaxHoldPanel
            app.play_FindPeaks_MaxHoldPanel = uipanel(app.play_FindPeaks_ParametersGrid);
            app.play_FindPeaks_MaxHoldPanel.AutoResizeChildren = 'off';
            app.play_FindPeaks_MaxHoldPanel.Title = 'MAXHOLD';
            app.play_FindPeaks_MaxHoldPanel.Layout.Row = 7;
            app.play_FindPeaks_MaxHoldPanel.Layout.Column = [2 3];
            app.play_FindPeaks_MaxHoldPanel.FontSize = 10;

            % Create play_FindPeaks_MaxHoldGrid
            app.play_FindPeaks_MaxHoldGrid = uigridlayout(app.play_FindPeaks_MaxHoldPanel);
            app.play_FindPeaks_MaxHoldGrid.ColumnWidth = {60, 10, '1x', 5, '1x'};
            app.play_FindPeaks_MaxHoldGrid.RowHeight = {27, 22};
            app.play_FindPeaks_MaxHoldGrid.ColumnSpacing = 0;
            app.play_FindPeaks_MaxHoldGrid.RowSpacing = 5;
            app.play_FindPeaks_MaxHoldGrid.Padding = [10 10 8 5];
            app.play_FindPeaks_MaxHoldGrid.BackgroundColor = [1 1 1];

            % Create play_FindPeaks_Prominence2Label
            app.play_FindPeaks_Prominence2Label = uilabel(app.play_FindPeaks_MaxHoldGrid);
            app.play_FindPeaks_Prominence2Label.VerticalAlignment = 'bottom';
            app.play_FindPeaks_Prominence2Label.WordWrap = 'on';
            app.play_FindPeaks_Prominence2Label.FontSize = 10;
            app.play_FindPeaks_Prominence2Label.Layout.Row = 1;
            app.play_FindPeaks_Prominence2Label.Layout.Column = [1 5];
            app.play_FindPeaks_Prominence2Label.Text = {'Proeminência'; '(dB):'};

            % Create play_FindPeaks_Prominence2
            app.play_FindPeaks_Prominence2 = uispinner(app.play_FindPeaks_MaxHoldGrid);
            app.play_FindPeaks_Prominence2.Step = 10;
            app.play_FindPeaks_Prominence2.Limits = [1 Inf];
            app.play_FindPeaks_Prominence2.RoundFractionalValues = 'on';
            app.play_FindPeaks_Prominence2.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_Prominence2.FontSize = 11;
            app.play_FindPeaks_Prominence2.Layout.Row = 2;
            app.play_FindPeaks_Prominence2.Layout.Column = 1;
            app.play_FindPeaks_Prominence2.Value = 30;

            % Create play_FindPeaks_OCCLabel
            app.play_FindPeaks_OCCLabel = uilabel(app.play_FindPeaks_MaxHoldGrid);
            app.play_FindPeaks_OCCLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_OCCLabel.FontSize = 10;
            app.play_FindPeaks_OCCLabel.Layout.Row = 1;
            app.play_FindPeaks_OCCLabel.Layout.Column = [3 5];
            app.play_FindPeaks_OCCLabel.Interpreter = 'html';
            app.play_FindPeaks_OCCLabel.Text = {'Ocupação (%):'; '<p style="line-height:10px; font-size:9px; color:gray;">(Mínima | Máxima)</p>'};

            % Create play_FindPeaks_meanOCC
            app.play_FindPeaks_meanOCC = uispinner(app.play_FindPeaks_MaxHoldGrid);
            app.play_FindPeaks_meanOCC.Step = 10;
            app.play_FindPeaks_meanOCC.Limits = [0 100];
            app.play_FindPeaks_meanOCC.RoundFractionalValues = 'on';
            app.play_FindPeaks_meanOCC.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_meanOCC.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_OCCValueChanged, true);
            app.play_FindPeaks_meanOCC.FontSize = 11;
            app.play_FindPeaks_meanOCC.Layout.Row = 2;
            app.play_FindPeaks_meanOCC.Layout.Column = 3;
            app.play_FindPeaks_meanOCC.Value = 1;

            % Create play_FindPeaks_maxOCC
            app.play_FindPeaks_maxOCC = uispinner(app.play_FindPeaks_MaxHoldGrid);
            app.play_FindPeaks_maxOCC.Step = 10;
            app.play_FindPeaks_maxOCC.Limits = [0 100];
            app.play_FindPeaks_maxOCC.RoundFractionalValues = 'on';
            app.play_FindPeaks_maxOCC.ValueDisplayFormat = '%.0f';
            app.play_FindPeaks_maxOCC.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_OCCValueChanged, true);
            app.play_FindPeaks_maxOCC.FontSize = 11;
            app.play_FindPeaks_maxOCC.Layout.Row = 2;
            app.play_FindPeaks_maxOCC.Layout.Column = 5;
            app.play_FindPeaks_maxOCC.Value = 10;

            % Create play_FindPeaks_add
            app.play_FindPeaks_add = uiimage(app.play_ControlsTab3Info);
            app.play_FindPeaks_add.ScaleMethod = 'scaledown';
            app.play_FindPeaks_add.ImageClickedFcn = createCallbackFcn(app, @play_FindPeaks_addEmission, true);
            app.play_FindPeaks_add.Layout.Row = 5;
            app.play_FindPeaks_add.Layout.Column = 4;
            app.play_FindPeaks_add.HorizontalAlignment = 'right';
            app.play_FindPeaks_add.VerticalAlignment = 'bottom';
            app.play_FindPeaks_add.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'addSymbol_32.png');

            % Create play_FindPeaks_Tree
            app.play_FindPeaks_Tree = uitree(app.play_ControlsTab3Info);
            app.play_FindPeaks_Tree.Multiselect = 'on';
            app.play_FindPeaks_Tree.SelectionChangedFcn = createCallbackFcn(app, @play_FindPeaks_TreeSelectionChanged, true);
            app.play_FindPeaks_Tree.FontSize = 10;
            app.play_FindPeaks_Tree.Layout.Row = 6;
            app.play_FindPeaks_Tree.Layout.Column = [1 4];

            % Create play_FindPeaks_PeakCFLabel
            app.play_FindPeaks_PeakCFLabel = uilabel(app.play_ControlsTab3Info);
            app.play_FindPeaks_PeakCFLabel.FontSize = 11;
            app.play_FindPeaks_PeakCFLabel.Layout.Row = 7;
            app.play_FindPeaks_PeakCFLabel.Layout.Column = [1 2];
            app.play_FindPeaks_PeakCFLabel.Text = 'Frequência central (MHz):';

            % Create play_FindPeaks_PeakCF
            app.play_FindPeaks_PeakCF = uieditfield(app.play_ControlsTab3Info, 'numeric');
            app.play_FindPeaks_PeakCF.ValueDisplayFormat = '%.3f';
            app.play_FindPeaks_PeakCF.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_editEmission, true);
            app.play_FindPeaks_PeakCF.FontSize = 11;
            app.play_FindPeaks_PeakCF.Enable = 'off';
            app.play_FindPeaks_PeakCF.Layout.Row = 7;
            app.play_FindPeaks_PeakCF.Layout.Column = [3 4];

            % Create play_FindPeaks_PeakBWLabel
            app.play_FindPeaks_PeakBWLabel = uilabel(app.play_ControlsTab3Info);
            app.play_FindPeaks_PeakBWLabel.FontSize = 11;
            app.play_FindPeaks_PeakBWLabel.Layout.Row = 8;
            app.play_FindPeaks_PeakBWLabel.Layout.Column = [1 2];
            app.play_FindPeaks_PeakBWLabel.Text = 'Largura ocupada (kHz):';

            % Create play_FindPeaks_PeakBW
            app.play_FindPeaks_PeakBW = uieditfield(app.play_ControlsTab3Info, 'numeric');
            app.play_FindPeaks_PeakBW.ValueDisplayFormat = '%.3f';
            app.play_FindPeaks_PeakBW.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_editEmission, true);
            app.play_FindPeaks_PeakBW.FontSize = 11;
            app.play_FindPeaks_PeakBW.Enable = 'off';
            app.play_FindPeaks_PeakBW.Layout.Row = 8;
            app.play_FindPeaks_PeakBW.Layout.Column = [3 4];

            % Create play_FindPeaks_DescriptionLabel
            app.play_FindPeaks_DescriptionLabel = uilabel(app.play_ControlsTab3Info);
            app.play_FindPeaks_DescriptionLabel.VerticalAlignment = 'top';
            app.play_FindPeaks_DescriptionLabel.WordWrap = 'on';
            app.play_FindPeaks_DescriptionLabel.FontSize = 11;
            app.play_FindPeaks_DescriptionLabel.Layout.Row = 9;
            app.play_FindPeaks_DescriptionLabel.Layout.Column = 1;
            app.play_FindPeaks_DescriptionLabel.Text = {'Informações'; 'complementares:'};

            % Create play_FindPeaks_Description
            app.play_FindPeaks_Description = uitextarea(app.play_ControlsTab3Info);
            app.play_FindPeaks_Description.ValueChangedFcn = createCallbackFcn(app, @play_FindPeaks_editEmission, true);
            app.play_FindPeaks_Description.FontSize = 11;
            app.play_FindPeaks_Description.Enable = 'off';
            app.play_FindPeaks_Description.Layout.Row = 9;
            app.play_FindPeaks_Description.Layout.Column = [2 4];

            % Create play_FindPeaks_ExternalFilePanel
            app.play_FindPeaks_ExternalFilePanel = uipanel(app.play_ControlsTab3Info);
            app.play_FindPeaks_ExternalFilePanel.Layout.Row = 4;
            app.play_FindPeaks_ExternalFilePanel.Layout.Column = [1 4];

            % Create play_FindPeaks_ExternalFileGrid
            app.play_FindPeaks_ExternalFileGrid = uigridlayout(app.play_FindPeaks_ExternalFilePanel);
            app.play_FindPeaks_ExternalFileGrid.ColumnWidth = {'1x'};
            app.play_FindPeaks_ExternalFileGrid.RowHeight = {17, 22, '1x'};
            app.play_FindPeaks_ExternalFileGrid.RowSpacing = 5;
            app.play_FindPeaks_ExternalFileGrid.Padding = [10 10 10 5];
            app.play_FindPeaks_ExternalFileGrid.BackgroundColor = [1 1 1];

            % Create play_FindPeaks_ExternalFileLabel
            app.play_FindPeaks_ExternalFileLabel = uilabel(app.play_FindPeaks_ExternalFileGrid);
            app.play_FindPeaks_ExternalFileLabel.VerticalAlignment = 'bottom';
            app.play_FindPeaks_ExternalFileLabel.FontSize = 10;
            app.play_FindPeaks_ExternalFileLabel.Layout.Row = 1;
            app.play_FindPeaks_ExternalFileLabel.Layout.Column = 1;
            app.play_FindPeaks_ExternalFileLabel.Text = 'Formato:';

            % Create play_FindPeaks_ExternalFile
            app.play_FindPeaks_ExternalFile = uidropdown(app.play_FindPeaks_ExternalFileGrid);
            app.play_FindPeaks_ExternalFile.Items = {'Generic (csv, txt, json, xls, xlsx)', 'Romes (csv)'};
            app.play_FindPeaks_ExternalFile.FontSize = 11;
            app.play_FindPeaks_ExternalFile.BackgroundColor = [1 1 1];
            app.play_FindPeaks_ExternalFile.Layout.Row = 2;
            app.play_FindPeaks_ExternalFile.Layout.Column = 1;
            app.play_FindPeaks_ExternalFile.Value = 'Generic (csv, txt, json, xls, xlsx)';

            % Create play_FindPeaks_FileTemplate
            app.play_FindPeaks_FileTemplate = uihyperlink(app.play_FindPeaks_ExternalFileGrid);
            app.play_FindPeaks_FileTemplate.HyperlinkClickedFcn = createCallbackFcn(app, @play_DownloadFileTemplate, true);
            app.play_FindPeaks_FileTemplate.VerticalAlignment = 'top';
            app.play_FindPeaks_FileTemplate.FontSize = 10;
            app.play_FindPeaks_FileTemplate.Layout.Row = 3;
            app.play_FindPeaks_FileTemplate.Layout.Column = 1;
            app.play_FindPeaks_FileTemplate.Text = 'Download modelo do arquivo';

            % Create report_ControlsTab1Info
            app.report_ControlsTab1Info = uigridlayout(app.play_ControlsGrid);
            app.report_ControlsTab1Info.ColumnWidth = {95, '1x', 32, 16, 16, 16};
            app.report_ControlsTab1Info.RowHeight = {22, 32, 22, 112, 9, 8, '1x', 22, '1x', 15, 15};
            app.report_ControlsTab1Info.ColumnSpacing = 5;
            app.report_ControlsTab1Info.RowSpacing = 5;
            app.report_ControlsTab1Info.Padding = [0 0 0 0];
            app.report_ControlsTab1Info.Layout.Row = 5;
            app.report_ControlsTab1Info.Layout.Column = 1;
            app.report_ControlsTab1Info.BackgroundColor = [1 1 1];

            % Create report_ProjectNameLabel
            app.report_ProjectNameLabel = uilabel(app.report_ControlsTab1Info);
            app.report_ProjectNameLabel.VerticalAlignment = 'bottom';
            app.report_ProjectNameLabel.FontSize = 10;
            app.report_ProjectNameLabel.Layout.Row = 1;
            app.report_ProjectNameLabel.Layout.Column = 1;
            app.report_ProjectNameLabel.Text = 'ARQUIVO';

            % Create report_ProjectWarnIcon
            app.report_ProjectWarnIcon = uiimage(app.report_ControlsTab1Info);
            app.report_ProjectWarnIcon.ScaleMethod = 'scaledown';
            app.report_ProjectWarnIcon.Visible = 'off';
            app.report_ProjectWarnIcon.Tooltip = {'Pendente salvar projeto'};
            app.report_ProjectWarnIcon.Layout.Row = 1;
            app.report_ProjectWarnIcon.Layout.Column = 4;
            app.report_ProjectWarnIcon.VerticalAlignment = 'bottom';
            app.report_ProjectWarnIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.report_ControlsTab1Info);
            app.report_ProjectSave.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectSave.Tooltip = {'Salva projeto'};
            app.report_ProjectSave.Layout.Row = 1;
            app.report_ProjectSave.Layout.Column = 5;
            app.report_ProjectSave.VerticalAlignment = 'bottom';
            app.report_ProjectSave.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'saveFile_32.png');

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.report_ControlsTab1Info);
            app.report_ProjectNew.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 1;
            app.report_ProjectNew.Layout.Column = 6;
            app.report_ProjectNew.VerticalAlignment = 'bottom';
            app.report_ProjectNew.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'addFiles_32.png');

            % Create report_ProjectName
            app.report_ProjectName = uitextarea(app.report_ControlsTab1Info);
            app.report_ProjectName.Tag = 'file';
            app.report_ProjectName.Editable = 'off';
            app.report_ProjectName.FontSize = 11;
            app.report_ProjectName.Layout.Row = 2;
            app.report_ProjectName.Layout.Column = [1 6];

            % Create report_DocumentPanelLabel
            app.report_DocumentPanelLabel = uilabel(app.report_ControlsTab1Info);
            app.report_DocumentPanelLabel.VerticalAlignment = 'bottom';
            app.report_DocumentPanelLabel.FontSize = 10;
            app.report_DocumentPanelLabel.Layout.Row = 3;
            app.report_DocumentPanelLabel.Layout.Column = [1 6];
            app.report_DocumentPanelLabel.Text = 'ATIVIDADE DE INSPEÇÃO';

            % Create report_DocumentPanel
            app.report_DocumentPanel = uipanel(app.report_ControlsTab1Info);
            app.report_DocumentPanel.AutoResizeChildren = 'off';
            app.report_DocumentPanel.Layout.Row = 4;
            app.report_DocumentPanel.Layout.Column = [1 6];

            % Create report_DocumentGrid
            app.report_DocumentGrid = uigridlayout(app.report_DocumentPanel);
            app.report_DocumentGrid.ColumnWidth = {'1x', 58, 16, 84};
            app.report_DocumentGrid.RowHeight = {17, 22, 17, 22};
            app.report_DocumentGrid.RowSpacing = 5;
            app.report_DocumentGrid.Padding = [10 10 10 5];
            app.report_DocumentGrid.BackgroundColor = [1 1 1];

            % Create report_systemLabel
            app.report_systemLabel = uilabel(app.report_DocumentGrid);
            app.report_systemLabel.VerticalAlignment = 'bottom';
            app.report_systemLabel.WordWrap = 'on';
            app.report_systemLabel.FontSize = 10;
            app.report_systemLabel.FontColor = [0.149 0.149 0.149];
            app.report_systemLabel.Layout.Row = 1;
            app.report_systemLabel.Layout.Column = 1;
            app.report_systemLabel.Text = 'Sistema:';

            % Create report_system
            app.report_system = uidropdown(app.report_DocumentGrid);
            app.report_system.Items = {'eFiscaliza', 'eFiscaliza DS', 'eFiscaliza HM'};
            app.report_system.FontSize = 11;
            app.report_system.BackgroundColor = [1 1 1];
            app.report_system.Layout.Row = 2;
            app.report_system.Layout.Column = 1;
            app.report_system.Value = 'eFiscaliza';

            % Create report_IssueLabel
            app.report_IssueLabel = uilabel(app.report_DocumentGrid);
            app.report_IssueLabel.VerticalAlignment = 'bottom';
            app.report_IssueLabel.WordWrap = 'on';
            app.report_IssueLabel.FontSize = 10;
            app.report_IssueLabel.FontColor = [0.149 0.149 0.149];
            app.report_IssueLabel.Layout.Row = 1;
            app.report_IssueLabel.Layout.Column = 2;
            app.report_IssueLabel.Text = '# Id:';

            % Create report_Issue
            app.report_Issue = uieditfield(app.report_DocumentGrid, 'numeric');
            app.report_Issue.Limits = [-1 Inf];
            app.report_Issue.RoundFractionalValues = 'on';
            app.report_Issue.ValueDisplayFormat = '%d';
            app.report_Issue.ValueChangedFcn = createCallbackFcn(app, @report_SaveWarn, true);
            app.report_Issue.Tag = 'issue';
            app.report_Issue.FontSize = 11;
            app.report_Issue.FontColor = [0.149 0.149 0.149];
            app.report_Issue.Layout.Row = 2;
            app.report_Issue.Layout.Column = [2 3];
            app.report_Issue.Value = -1;

            % Create report_Unit
            app.report_Unit = uidropdown(app.report_DocumentGrid);
            app.report_Unit.Items = {};
            app.report_Unit.FontSize = 11;
            app.report_Unit.BackgroundColor = [1 1 1];
            app.report_Unit.Layout.Row = 2;
            app.report_Unit.Layout.Column = 4;
            app.report_Unit.Value = {};

            % Create report_UnitLabel
            app.report_UnitLabel = uilabel(app.report_DocumentGrid);
            app.report_UnitLabel.VerticalAlignment = 'bottom';
            app.report_UnitLabel.WordWrap = 'on';
            app.report_UnitLabel.FontSize = 10;
            app.report_UnitLabel.Layout.Row = 1;
            app.report_UnitLabel.Layout.Column = 4;
            app.report_UnitLabel.Text = 'Unidade:';

            % Create report_ModelNameLabel
            app.report_ModelNameLabel = uilabel(app.report_DocumentGrid);
            app.report_ModelNameLabel.VerticalAlignment = 'bottom';
            app.report_ModelNameLabel.FontSize = 10;
            app.report_ModelNameLabel.Layout.Row = 3;
            app.report_ModelNameLabel.Layout.Column = 1;
            app.report_ModelNameLabel.Text = 'Modelo do relatório:';

            % Create report_AddProjectAttachment
            app.report_AddProjectAttachment = uiimage(app.report_DocumentGrid);
            app.report_AddProjectAttachment.ImageClickedFcn = createCallbackFcn(app, @report_ThreadAlgorithmsRefreshImageClicked, true);
            app.report_AddProjectAttachment.Tooltip = {'Edita lista de arquivos externos '; 'relacionados ao projeto'};
            app.report_AddProjectAttachment.Layout.Row = 3;
            app.report_AddProjectAttachment.Layout.Column = 3;
            app.report_AddProjectAttachment.VerticalAlignment = 'bottom';
            app.report_AddProjectAttachment.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'attach_32.png');

            % Create report_ModelName
            app.report_ModelName = uidropdown(app.report_DocumentGrid);
            app.report_ModelName.Items = {};
            app.report_ModelName.ValueChangedFcn = createCallbackFcn(app, @report_ModelOrVersionValueChanged, true);
            app.report_ModelName.Tag = 'documentModel';
            app.report_ModelName.FontSize = 11;
            app.report_ModelName.BackgroundColor = [1 1 1];
            app.report_ModelName.Layout.Row = 4;
            app.report_ModelName.Layout.Column = [1 3];
            app.report_ModelName.Value = {};

            % Create report_VersionLabel
            app.report_VersionLabel = uilabel(app.report_DocumentGrid);
            app.report_VersionLabel.VerticalAlignment = 'bottom';
            app.report_VersionLabel.FontSize = 10;
            app.report_VersionLabel.Layout.Row = 3;
            app.report_VersionLabel.Layout.Column = 4;
            app.report_VersionLabel.Text = 'Versão:';

            % Create report_Version
            app.report_Version = uidropdown(app.report_DocumentGrid);
            app.report_Version.Items = {'Preliminar', 'Definitiva'};
            app.report_Version.ValueChangedFcn = createCallbackFcn(app, @report_ModelOrVersionValueChanged, true);
            app.report_Version.FontSize = 11;
            app.report_Version.BackgroundColor = [1 1 1];
            app.report_Version.Layout.Row = 4;
            app.report_Version.Layout.Column = 4;
            app.report_Version.Value = 'Preliminar';

            % Create report_TreeLabel
            app.report_TreeLabel = uilabel(app.report_ControlsTab1Info);
            app.report_TreeLabel.VerticalAlignment = 'bottom';
            app.report_TreeLabel.FontSize = 10;
            app.report_TreeLabel.Layout.Row = [5 6];
            app.report_TreeLabel.Layout.Column = [1 2];
            app.report_TreeLabel.Text = 'FLUXOS A PROCESSAR';

            % Create report_TreeAddImage
            app.report_TreeAddImage = uiimage(app.report_ControlsTab1Info);
            app.report_TreeAddImage.ImageClickedFcn = createCallbackFcn(app, @report_TreeAddImagePushed, true);
            app.report_TreeAddImage.Tooltip = {''};
            app.report_TreeAddImage.Layout.Row = 6;
            app.report_TreeAddImage.Layout.Column = 6;
            app.report_TreeAddImage.VerticalAlignment = 'bottom';
            app.report_TreeAddImage.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'addSymbol_32.png');

            % Create report_Tree
            app.report_Tree = uitree(app.report_ControlsTab1Info);
            app.report_Tree.Multiselect = 'on';
            app.report_Tree.FontSize = 10;
            app.report_Tree.Layout.Row = 7;
            app.report_Tree.Layout.Column = [1 6];

            % Create report_ThreadAlgorithmsLabel
            app.report_ThreadAlgorithmsLabel = uilabel(app.report_ControlsTab1Info);
            app.report_ThreadAlgorithmsLabel.VerticalAlignment = 'bottom';
            app.report_ThreadAlgorithmsLabel.FontSize = 10;
            app.report_ThreadAlgorithmsLabel.Layout.Row = 8;
            app.report_ThreadAlgorithmsLabel.Layout.Column = [1 2];
            app.report_ThreadAlgorithmsLabel.Text = 'ALGORITMOS';

            % Create report_ThreadAlgorithmsImage
            app.report_ThreadAlgorithmsImage = uiimage(app.report_ControlsTab1Info);
            app.report_ThreadAlgorithmsImage.ScaleMethod = 'none';
            app.report_ThreadAlgorithmsImage.Layout.Row = 9;
            app.report_ThreadAlgorithmsImage.Layout.Column = [1 6];
            app.report_ThreadAlgorithmsImage.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'warning.svg');

            % Create report_ThreadAlgorithms
            app.report_ThreadAlgorithms = uilabel(app.report_ControlsTab1Info);
            app.report_ThreadAlgorithms.VerticalAlignment = 'top';
            app.report_ThreadAlgorithms.WordWrap = 'on';
            app.report_ThreadAlgorithms.FontSize = 11;
            app.report_ThreadAlgorithms.Layout.Row = 9;
            app.report_ThreadAlgorithms.Layout.Column = [1 6];
            app.report_ThreadAlgorithms.Interpreter = 'html';
            app.report_ThreadAlgorithms.Text = '';

            % Create report_EditDetection
            app.report_EditDetection = uihyperlink(app.report_ControlsTab1Info);
            app.report_EditDetection.HyperlinkClickedFcn = createCallbackFcn(app, @report_ThreadAlgorithmsRefreshImageClicked, true);
            app.report_EditDetection.VisitedColor = [0 0.4 0.8];
            app.report_EditDetection.VerticalAlignment = 'top';
            app.report_EditDetection.FontSize = 10;
            app.report_EditDetection.FontColor = [0 0.4 0.8];
            app.report_EditDetection.Enable = 'off';
            app.report_EditDetection.Layout.Row = 10;
            app.report_EditDetection.Layout.Column = 1;
            app.report_EditDetection.Text = 'DETECÇÃO';

            % Create report_EditClassification
            app.report_EditClassification = uihyperlink(app.report_ControlsTab1Info);
            app.report_EditClassification.HyperlinkClickedFcn = createCallbackFcn(app, @report_ThreadAlgorithmsRefreshImageClicked, true);
            app.report_EditClassification.VisitedColor = [0 0.4 0.8];
            app.report_EditClassification.HorizontalAlignment = 'right';
            app.report_EditClassification.VerticalAlignment = 'top';
            app.report_EditClassification.FontSize = 10;
            app.report_EditClassification.FontColor = [0 0.4 0.8];
            app.report_EditClassification.Enable = 'off';
            app.report_EditClassification.Layout.Row = 10;
            app.report_EditClassification.Layout.Column = [3 6];
            app.report_EditClassification.Text = 'CLASSIFICAÇÃO';

            % Create report_DetectionManualMode
            app.report_DetectionManualMode = uicheckbox(app.report_ControlsTab1Info);
            app.report_DetectionManualMode.ValueChangedFcn = createCallbackFcn(app, @report_DetectionManualModeValueChanged, true);
            app.report_DetectionManualMode.Enable = 'off';
            app.report_DetectionManualMode.Text = 'Restringir detecção de emissões ao PLAYBACK.';
            app.report_DetectionManualMode.WordWrap = 'on';
            app.report_DetectionManualMode.FontSize = 11;
            app.report_DetectionManualMode.Layout.Row = 11;
            app.report_DetectionManualMode.Layout.Column = [1 6];

            % Create misc_ControlsTab1Info
            app.misc_ControlsTab1Info = uigridlayout(app.play_ControlsGrid);
            app.misc_ControlsTab1Info.ColumnWidth = {'1x'};
            app.misc_ControlsTab1Info.RowHeight = {22, '1x'};
            app.misc_ControlsTab1Info.ColumnSpacing = 5;
            app.misc_ControlsTab1Info.RowSpacing = 5;
            app.misc_ControlsTab1Info.Padding = [0 0 0 0];
            app.misc_ControlsTab1Info.Layout.Row = 6;
            app.misc_ControlsTab1Info.Layout.Column = 1;
            app.misc_ControlsTab1Info.BackgroundColor = [1 1 1];

            % Create misc_Label1
            app.misc_Label1 = uilabel(app.misc_ControlsTab1Info);
            app.misc_Label1.VerticalAlignment = 'bottom';
            app.misc_Label1.FontSize = 10;
            app.misc_Label1.Layout.Row = 1;
            app.misc_Label1.Layout.Column = 1;
            app.misc_Label1.Text = 'OPERAÇÃO';

            % Create misc_Panel1
            app.misc_Panel1 = uipanel(app.misc_ControlsTab1Info);
            app.misc_Panel1.AutoResizeChildren = 'off';
            app.misc_Panel1.Layout.Row = 2;
            app.misc_Panel1.Layout.Column = 1;

            % Create misc_Grid1
            app.misc_Grid1 = uigridlayout(app.misc_Panel1);
            app.misc_Grid1.ColumnWidth = {3, 28, 3, 3, 28, 3, 3, 28, 3, 3, 28, 3, '1x', 3, 28, 3, 3, 28, 3};
            app.misc_Grid1.RowHeight = {1, 34, 26, 1, 34, 26, 1, 34, 26, '1x', 34, 26};
            app.misc_Grid1.ColumnSpacing = 5;
            app.misc_Grid1.RowSpacing = 5;
            app.misc_Grid1.Padding = [10 10 10 5];
            app.misc_Grid1.BackgroundColor = [1 1 1];

            % Create misc_Save
            app.misc_Save = uibutton(app.misc_Grid1, 'push');
            app.misc_Save.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_Save.Icon = 'saveFile_32.png';
            app.misc_Save.IconAlignment = 'top';
            app.misc_Save.BackgroundColor = [1 1 1];
            app.misc_Save.FontSize = 10;
            app.misc_Save.Tooltip = {''};
            app.misc_Save.Layout.Row = 2;
            app.misc_Save.Layout.Column = 2;
            app.misc_Save.Text = '';

            % Create misc_SaveLabel
            app.misc_SaveLabel = uilabel(app.misc_Grid1);
            app.misc_SaveLabel.HorizontalAlignment = 'center';
            app.misc_SaveLabel.WordWrap = 'on';
            app.misc_SaveLabel.FontSize = 10;
            app.misc_SaveLabel.Layout.Row = 3;
            app.misc_SaveLabel.Layout.Column = [1 3];
            app.misc_SaveLabel.Text = {'Salvar'; 'fluxo(s)'};

            % Create misc_Duplicate
            app.misc_Duplicate = uibutton(app.misc_Grid1, 'push');
            app.misc_Duplicate.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_Duplicate.Icon = 'duplicateFile_32.png';
            app.misc_Duplicate.IconAlignment = 'top';
            app.misc_Duplicate.BackgroundColor = [1 1 1];
            app.misc_Duplicate.FontSize = 10;
            app.misc_Duplicate.Tooltip = {''};
            app.misc_Duplicate.Layout.Row = 2;
            app.misc_Duplicate.Layout.Column = 5;
            app.misc_Duplicate.Text = '';

            % Create misc_DuplicateLabel
            app.misc_DuplicateLabel = uilabel(app.misc_Grid1);
            app.misc_DuplicateLabel.HorizontalAlignment = 'center';
            app.misc_DuplicateLabel.WordWrap = 'on';
            app.misc_DuplicateLabel.FontSize = 10;
            app.misc_DuplicateLabel.Layout.Row = 3;
            app.misc_DuplicateLabel.Layout.Column = [4 6];
            app.misc_DuplicateLabel.Text = {'Duplicar'; 'fluxo(s)'};

            % Create misc_Merge
            app.misc_Merge = uibutton(app.misc_Grid1, 'push');
            app.misc_Merge.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_Merge.Icon = 'Merge_32.png';
            app.misc_Merge.IconAlignment = 'top';
            app.misc_Merge.BackgroundColor = [1 1 1];
            app.misc_Merge.FontSize = 10;
            app.misc_Merge.Tooltip = {''};
            app.misc_Merge.Layout.Row = 2;
            app.misc_Merge.Layout.Column = 8;
            app.misc_Merge.Text = '';

            % Create misc_MergeLabel
            app.misc_MergeLabel = uilabel(app.misc_Grid1);
            app.misc_MergeLabel.HorizontalAlignment = 'center';
            app.misc_MergeLabel.WordWrap = 'on';
            app.misc_MergeLabel.FontSize = 10;
            app.misc_MergeLabel.Layout.Row = 3;
            app.misc_MergeLabel.Layout.Column = [7 9];
            app.misc_MergeLabel.Text = {'Mesclar'; 'fluxos'};

            % Create misc_Del
            app.misc_Del = uibutton(app.misc_Grid1, 'push');
            app.misc_Del.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_Del.Icon = 'Delete_32Red.png';
            app.misc_Del.IconAlignment = 'top';
            app.misc_Del.BackgroundColor = [1 1 1];
            app.misc_Del.FontSize = 10;
            app.misc_Del.Tooltip = {''};
            app.misc_Del.Layout.Row = 2;
            app.misc_Del.Layout.Column = 11;
            app.misc_Del.Text = '';

            % Create misc_DelLabel
            app.misc_DelLabel = uilabel(app.misc_Grid1);
            app.misc_DelLabel.HorizontalAlignment = 'center';
            app.misc_DelLabel.WordWrap = 'on';
            app.misc_DelLabel.FontSize = 10;
            app.misc_DelLabel.Layout.Row = 3;
            app.misc_DelLabel.Layout.Column = [10 12];
            app.misc_DelLabel.Text = {'Excluir'; 'fluxo(s)'};

            % Create misc_Serarator
            app.misc_Serarator = uiimage(app.misc_Grid1);
            app.misc_Serarator.ScaleMethod = 'stretch';
            app.misc_Serarator.Enable = 'off';
            app.misc_Serarator.Layout.Row = [1 3];
            app.misc_Serarator.Layout.Column = 13;
            app.misc_Serarator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.png');

            % Create misc_Export
            app.misc_Export = uibutton(app.misc_Grid1, 'push');
            app.misc_Export.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_Export.Icon = 'Export_16.png';
            app.misc_Export.IconAlignment = 'top';
            app.misc_Export.BackgroundColor = [1 1 1];
            app.misc_Export.FontSize = 10;
            app.misc_Export.Tooltip = {''};
            app.misc_Export.Layout.Row = 2;
            app.misc_Export.Layout.Column = 15;
            app.misc_Export.Text = '';

            % Create misc_ExportLabel
            app.misc_ExportLabel = uilabel(app.misc_Grid1);
            app.misc_ExportLabel.HorizontalAlignment = 'center';
            app.misc_ExportLabel.WordWrap = 'on';
            app.misc_ExportLabel.FontSize = 10;
            app.misc_ExportLabel.Layout.Row = 3;
            app.misc_ExportLabel.Layout.Column = [14 16];
            app.misc_ExportLabel.Text = {'Exportar'; 'análise'};

            % Create misc_Import
            app.misc_Import = uibutton(app.misc_Grid1, 'push');
            app.misc_Import.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_Import.Icon = 'Import_16.png';
            app.misc_Import.IconAlignment = 'top';
            app.misc_Import.BackgroundColor = [1 1 1];
            app.misc_Import.FontSize = 10;
            app.misc_Import.Tooltip = {''};
            app.misc_Import.Layout.Row = 2;
            app.misc_Import.Layout.Column = 18;
            app.misc_Import.Text = '';

            % Create misc_ImportLabel
            app.misc_ImportLabel = uilabel(app.misc_Grid1);
            app.misc_ImportLabel.HorizontalAlignment = 'center';
            app.misc_ImportLabel.WordWrap = 'on';
            app.misc_ImportLabel.FontSize = 10;
            app.misc_ImportLabel.Layout.Row = 3;
            app.misc_ImportLabel.Layout.Column = [17 19];
            app.misc_ImportLabel.Text = {'Importar'; 'análise'};

            % Create misc_TimeFiltering
            app.misc_TimeFiltering = uibutton(app.misc_Grid1, 'push');
            app.misc_TimeFiltering.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_TimeFiltering.Icon = 'Filter_18.png';
            app.misc_TimeFiltering.BackgroundColor = [1 1 1];
            app.misc_TimeFiltering.Tooltip = {''};
            app.misc_TimeFiltering.Layout.Row = 5;
            app.misc_TimeFiltering.Layout.Column = 2;
            app.misc_TimeFiltering.Text = '';

            % Create misc_TimeFilteringLabel
            app.misc_TimeFilteringLabel = uilabel(app.misc_Grid1);
            app.misc_TimeFilteringLabel.HorizontalAlignment = 'center';
            app.misc_TimeFilteringLabel.WordWrap = 'on';
            app.misc_TimeFilteringLabel.FontSize = 10;
            app.misc_TimeFilteringLabel.Layout.Row = 6;
            app.misc_TimeFilteringLabel.Layout.Column = [1 3];
            app.misc_TimeFilteringLabel.Text = 'Filtrar fluxo(s)';

            % Create misc_EditLocation
            app.misc_EditLocation = uibutton(app.misc_Grid1, 'push');
            app.misc_EditLocation.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_EditLocation.Icon = 'Pin_32.png';
            app.misc_EditLocation.BackgroundColor = [1 1 1];
            app.misc_EditLocation.Tooltip = {''};
            app.misc_EditLocation.Layout.Row = 5;
            app.misc_EditLocation.Layout.Column = 5;
            app.misc_EditLocation.Text = '';

            % Create misc_EditLocationLabel
            app.misc_EditLocationLabel = uilabel(app.misc_Grid1);
            app.misc_EditLocationLabel.HorizontalAlignment = 'center';
            app.misc_EditLocationLabel.WordWrap = 'on';
            app.misc_EditLocationLabel.FontSize = 10;
            app.misc_EditLocationLabel.Layout.Row = 6;
            app.misc_EditLocationLabel.Layout.Column = [4 6];
            app.misc_EditLocationLabel.Text = {'Editar'; 'Local'};

            % Create misc_AddCorrection
            app.misc_AddCorrection = uibutton(app.misc_Grid1, 'push');
            app.misc_AddCorrection.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_AddCorrection.Icon = 'RFFilter_32.png';
            app.misc_AddCorrection.BackgroundColor = [1 1 1];
            app.misc_AddCorrection.Tooltip = {''};
            app.misc_AddCorrection.Layout.Row = 5;
            app.misc_AddCorrection.Layout.Column = 8;
            app.misc_AddCorrection.Text = '';

            % Create misc_AddCorrectionLabel
            app.misc_AddCorrectionLabel = uilabel(app.misc_Grid1);
            app.misc_AddCorrectionLabel.HorizontalAlignment = 'center';
            app.misc_AddCorrectionLabel.WordWrap = 'on';
            app.misc_AddCorrectionLabel.FontSize = 10;
            app.misc_AddCorrectionLabel.Layout.Row = 6;
            app.misc_AddCorrectionLabel.Layout.Column = [7 9];
            app.misc_AddCorrectionLabel.Text = {'Aplicar'; 'correção'};

            % Create misc_DeleteAll
            app.misc_DeleteAll = uibutton(app.misc_Grid1, 'push');
            app.misc_DeleteAll.ButtonPushedFcn = createCallbackFcn(app, @misc_DeleteAllButtonPushed, true);
            app.misc_DeleteAll.Icon = 'Trash_32.png';
            app.misc_DeleteAll.BackgroundColor = [1 1 1];
            app.misc_DeleteAll.Tooltip = {''};
            app.misc_DeleteAll.Layout.Row = 11;
            app.misc_DeleteAll.Layout.Column = 2;
            app.misc_DeleteAll.Text = '';

            % Create misc_DeleteAllLabel
            app.misc_DeleteAllLabel = uilabel(app.misc_Grid1);
            app.misc_DeleteAllLabel.HorizontalAlignment = 'center';
            app.misc_DeleteAllLabel.WordWrap = 'on';
            app.misc_DeleteAllLabel.FontSize = 10;
            app.misc_DeleteAllLabel.Layout.Row = 12;
            app.misc_DeleteAllLabel.Layout.Column = [1 3];
            app.misc_DeleteAllLabel.Text = 'Reiniciar análise';

            % Create misc_DeleteInvalidSweeps
            app.misc_DeleteInvalidSweeps = uibutton(app.misc_Grid1, 'push');
            app.misc_DeleteInvalidSweeps.ButtonPushedFcn = createCallbackFcn(app, @misc_OperationsCallbacks, true);
            app.misc_DeleteInvalidSweeps.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'clear_breakpoints_16.png');
            app.misc_DeleteInvalidSweeps.BackgroundColor = [1 1 1];
            app.misc_DeleteInvalidSweeps.Tooltip = {''};
            app.misc_DeleteInvalidSweeps.Layout.Row = 8;
            app.misc_DeleteInvalidSweeps.Layout.Column = 2;
            app.misc_DeleteInvalidSweeps.Text = '';

            % Create misc_DeleteInvalidSweepsLabel
            app.misc_DeleteInvalidSweepsLabel = uilabel(app.misc_Grid1);
            app.misc_DeleteInvalidSweepsLabel.HorizontalAlignment = 'center';
            app.misc_DeleteInvalidSweepsLabel.WordWrap = 'on';
            app.misc_DeleteInvalidSweepsLabel.FontSize = 10;
            app.misc_DeleteInvalidSweepsLabel.Layout.Row = 9;
            app.misc_DeleteInvalidSweepsLabel.Layout.Column = [1 3];
            app.misc_DeleteInvalidSweepsLabel.Text = {'Eliminar'; 'inválidas'};

            % Create submenu_Grid
            app.submenu_Grid = uigridlayout(app.play_ControlsGrid);
            app.submenu_Grid.ColumnWidth = {'1x', 22, 22, 0, 0};
            app.submenu_Grid.RowHeight = {'1x', 3};
            app.submenu_Grid.ColumnSpacing = 2;
            app.submenu_Grid.RowSpacing = 0;
            app.submenu_Grid.Padding = [0 0 0 0];
            app.submenu_Grid.Layout.Row = 1;
            app.submenu_Grid.Layout.Column = 1;
            app.submenu_Grid.BackgroundColor = [1 1 1];

            % Create submenuUnderline
            app.submenuUnderline = uiimage(app.submenu_Grid);
            app.submenuUnderline.ScaleMethod = 'scaleup';
            app.submenuUnderline.Layout.Row = 2;
            app.submenuUnderline.Layout.Column = 1;
            app.submenuUnderline.ImageSource = 'LineH.png';

            % Create submenu_Button1Grid
            app.submenu_Button1Grid = uigridlayout(app.submenu_Grid);
            app.submenu_Button1Grid.ColumnWidth = {18, '1x'};
            app.submenu_Button1Grid.RowHeight = {'1x'};
            app.submenu_Button1Grid.ColumnSpacing = 3;
            app.submenu_Button1Grid.Padding = [2 0 0 0];
            app.submenu_Button1Grid.Layout.Row = 1;
            app.submenu_Button1Grid.Layout.Column = 1;
            app.submenu_Button1Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create submenu_Button1Label
            app.submenu_Button1Label = uilabel(app.submenu_Button1Grid);
            app.submenu_Button1Label.FontSize = 10;
            app.submenu_Button1Label.Layout.Row = 1;
            app.submenu_Button1Label.Layout.Column = 2;
            app.submenu_Button1Label.Text = 'PLAYBACK';

            % Create submenu_Button1Icon
            app.submenu_Button1Icon = uiimage(app.submenu_Button1Grid);
            app.submenu_Button1Icon.ScaleMethod = 'none';
            app.submenu_Button1Icon.ImageClickedFcn = createCallbackFcn(app, @play_submenuButtonPushed, true);
            app.submenu_Button1Icon.Tag = 'PLAYBACK:GENERAL';
            app.submenu_Button1Icon.Layout.Row = 1;
            app.submenu_Button1Icon.Layout.Column = [1 2];
            app.submenu_Button1Icon.HorizontalAlignment = 'left';
            app.submenu_Button1Icon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Playback_18.png');

            % Create submenu_Button2Grid
            app.submenu_Button2Grid = uigridlayout(app.submenu_Grid);
            app.submenu_Button2Grid.ColumnWidth = {18, 0};
            app.submenu_Button2Grid.RowHeight = {'1x'};
            app.submenu_Button2Grid.ColumnSpacing = 3;
            app.submenu_Button2Grid.Padding = [2 0 0 0];
            app.submenu_Button2Grid.Layout.Row = 1;
            app.submenu_Button2Grid.Layout.Column = 2;
            app.submenu_Button2Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create submenu_Button2Label
            app.submenu_Button2Label = uilabel(app.submenu_Button2Grid);
            app.submenu_Button2Label.FontSize = 10;
            app.submenu_Button2Label.Layout.Row = 1;
            app.submenu_Button2Label.Layout.Column = 2;
            app.submenu_Button2Label.Text = 'CANAIS';

            % Create submenu_Button2Icon
            app.submenu_Button2Icon = uiimage(app.submenu_Button2Grid);
            app.submenu_Button2Icon.ScaleMethod = 'none';
            app.submenu_Button2Icon.ImageClickedFcn = createCallbackFcn(app, @play_submenuButtonPushed, true);
            app.submenu_Button2Icon.Tag = 'PLAYBACK:CHANNEL';
            app.submenu_Button2Icon.Layout.Row = 1;
            app.submenu_Button2Icon.Layout.Column = [1 2];
            app.submenu_Button2Icon.HorizontalAlignment = 'left';
            app.submenu_Button2Icon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Channel_18.png');

            % Create submenu_Button3Grid
            app.submenu_Button3Grid = uigridlayout(app.submenu_Grid);
            app.submenu_Button3Grid.ColumnWidth = {18, 0};
            app.submenu_Button3Grid.RowHeight = {'1x'};
            app.submenu_Button3Grid.ColumnSpacing = 3;
            app.submenu_Button3Grid.Padding = [2 0 0 0];
            app.submenu_Button3Grid.Layout.Row = 1;
            app.submenu_Button3Grid.Layout.Column = 3;
            app.submenu_Button3Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create submenu_Button3Label
            app.submenu_Button3Label = uilabel(app.submenu_Button3Grid);
            app.submenu_Button3Label.FontSize = 10;
            app.submenu_Button3Label.Layout.Row = 1;
            app.submenu_Button3Label.Layout.Column = 2;
            app.submenu_Button3Label.Text = 'EMISSÕES';

            % Create submenu_Button3Icon
            app.submenu_Button3Icon = uiimage(app.submenu_Button3Grid);
            app.submenu_Button3Icon.ScaleMethod = 'none';
            app.submenu_Button3Icon.ImageClickedFcn = createCallbackFcn(app, @play_submenuButtonPushed, true);
            app.submenu_Button3Icon.Tag = 'PLAYBACK:EMISSION';
            app.submenu_Button3Icon.Layout.Row = 1;
            app.submenu_Button3Icon.Layout.Column = [1 2];
            app.submenu_Button3Icon.HorizontalAlignment = 'left';
            app.submenu_Button3Icon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Detection_18.png');

            % Create submenu_Button4Grid
            app.submenu_Button4Grid = uigridlayout(app.submenu_Grid);
            app.submenu_Button4Grid.ColumnWidth = {18, 0};
            app.submenu_Button4Grid.RowHeight = {'1x'};
            app.submenu_Button4Grid.ColumnSpacing = 3;
            app.submenu_Button4Grid.Padding = [2 0 0 0];
            app.submenu_Button4Grid.Layout.Row = 1;
            app.submenu_Button4Grid.Layout.Column = 4;
            app.submenu_Button4Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create submenu_Button4Label
            app.submenu_Button4Label = uilabel(app.submenu_Button4Grid);
            app.submenu_Button4Label.FontSize = 10;
            app.submenu_Button4Label.Layout.Row = 1;
            app.submenu_Button4Label.Layout.Column = 2;
            app.submenu_Button4Label.Text = 'PROJETO';

            % Create submenu_Button4Icon
            app.submenu_Button4Icon = uiimage(app.submenu_Button4Grid);
            app.submenu_Button4Icon.ScaleMethod = 'none';
            app.submenu_Button4Icon.Tag = 'REPORT:GENERAL';
            app.submenu_Button4Icon.Layout.Row = 1;
            app.submenu_Button4Icon.Layout.Column = [1 2];
            app.submenu_Button4Icon.HorizontalAlignment = 'left';
            app.submenu_Button4Icon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Report_18.png');

            % Create submenu_Button6Grid
            app.submenu_Button6Grid = uigridlayout(app.submenu_Grid);
            app.submenu_Button6Grid.ColumnWidth = {18, '1x'};
            app.submenu_Button6Grid.RowHeight = {'1x'};
            app.submenu_Button6Grid.ColumnSpacing = 3;
            app.submenu_Button6Grid.Padding = [2 0 0 0];
            app.submenu_Button6Grid.Layout.Row = 1;
            app.submenu_Button6Grid.Layout.Column = 5;
            app.submenu_Button6Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create submenu_Button6Label
            app.submenu_Button6Label = uilabel(app.submenu_Button6Grid);
            app.submenu_Button6Label.FontSize = 10;
            app.submenu_Button6Label.Layout.Row = 1;
            app.submenu_Button6Label.Layout.Column = 2;
            app.submenu_Button6Label.Text = 'MISCELÂNEAS';

            % Create submenu_Button6Icon
            app.submenu_Button6Icon = uiimage(app.submenu_Button6Grid);
            app.submenu_Button6Icon.ScaleMethod = 'none';
            app.submenu_Button6Icon.Tag = 'MISC:GENERAL';
            app.submenu_Button6Icon.Layout.Row = 1;
            app.submenu_Button6Icon.Layout.Column = [1 2];
            app.submenu_Button6Icon.HorizontalAlignment = 'left';
            app.submenu_Button6Icon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Misc_18.png');

            % Create play_toolGrid
            app.play_toolGrid = uigridlayout(app.play_Grid);
            app.play_toolGrid.ColumnWidth = {22, 22, 22, 248, '1x', 24, 24, 24, 24, 24, 24, '1x', 167, 22, 22, 22, 22, 22};
            app.play_toolGrid.RowHeight = {4, 17, 3};
            app.play_toolGrid.ColumnSpacing = 5;
            app.play_toolGrid.RowSpacing = 0;
            app.play_toolGrid.Padding = [5 5 5 5];
            app.play_toolGrid.Layout.Row = 13;
            app.play_toolGrid.Layout.Column = [1 9];

            % Create tool_LayoutLeft
            app.tool_LayoutLeft = uiimage(app.play_toolGrid);
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @play_PanelsVisibility, true);
            app.tool_LayoutLeft.Layout.Row = 2;
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'ArrowLeft_32.png');

            % Create tool_Play
            app.tool_Play = uiimage(app.play_toolGrid);
            app.tool_Play.ImageClickedFcn = createCallbackFcn(app, @play_PlaybackToolbarButtonCallback, true);
            app.tool_Play.Tooltip = {'Playback'};
            app.tool_Play.Layout.Row = 2;
            app.tool_Play.Layout.Column = 2;
            app.tool_Play.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'play_32.png');

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.play_toolGrid);
            app.tool_LoopControl.ImageClickedFcn = createCallbackFcn(app, @play_PlaybackToolbarButtonCallback, true);
            app.tool_LoopControl.Tag = 'loop';
            app.tool_LoopControl.Tooltip = {'Loop do playback'};
            app.tool_LoopControl.Layout.Row = 2;
            app.tool_LoopControl.Layout.Column = 3;
            app.tool_LoopControl.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'playbackLoop_32Blue.png');

            % Create tool_TimestampSlider
            app.tool_TimestampSlider = uislider(app.play_toolGrid);
            app.tool_TimestampSlider.MajorTicks = [0 50 100];
            app.tool_TimestampSlider.MajorTickLabels = {''};
            app.tool_TimestampSlider.ValueChangingFcn = createCallbackFcn(app, @tool_TimestampSliderValueChanging, true);
            app.tool_TimestampSlider.MinorTicks = [0 2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30 32.5 35 37.5 40 42.5 45 47.5 50 52.5 55 57.5 60 62.5 65 67.5 70 72.5 75 77.5 80 82.5 85 87.5 90 92.5 95 97.5 100];
            app.tool_TimestampSlider.FontSize = 8;
            app.tool_TimestampSlider.Layout.Row = 2;
            app.tool_TimestampSlider.Layout.Column = 4;

            % Create tool_TimestampLabel
            app.tool_TimestampLabel = uilabel(app.play_toolGrid);
            app.tool_TimestampLabel.WordWrap = 'on';
            app.tool_TimestampLabel.FontSize = 10;
            app.tool_TimestampLabel.Layout.Row = [1 3];
            app.tool_TimestampLabel.Layout.Column = 5;
            app.tool_TimestampLabel.Text = {'22 de 328 '; '22/02/2022 08:00:00 '};

            % Create tool_ReportGenerator
            app.tool_ReportGenerator = uiimage(app.play_toolGrid);
            app.tool_ReportGenerator.ImageClickedFcn = createCallbackFcn(app, @report_playButtonPushed, true);
            app.tool_ReportGenerator.Enable = 'off';
            app.tool_ReportGenerator.Tooltip = {'Gera relatório'};
            app.tool_ReportGenerator.Layout.Row = 2;
            app.tool_ReportGenerator.Layout.Column = 16;
            app.tool_ReportGenerator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Publish_HTML_16.png');

            % Create tool_FiscalizaUpdate
            app.tool_FiscalizaUpdate = uiimage(app.play_toolGrid);
            app.tool_FiscalizaUpdate.ImageClickedFcn = createCallbackFcn(app, @report_FiscalizaStaticButtonPushed, true);
            app.tool_FiscalizaUpdate.Tooltip = {'Upload relatório'};
            app.tool_FiscalizaUpdate.Layout.Row = 2;
            app.tool_FiscalizaUpdate.Layout.Column = 17;
            app.tool_FiscalizaUpdate.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Up_24.png');

            % Create tool_LayoutRight
            app.tool_LayoutRight = uiimage(app.play_toolGrid);
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @play_PanelsVisibility, true);
            app.tool_LayoutRight.Layout.Row = 2;
            app.tool_LayoutRight.Layout.Column = 18;
            app.tool_LayoutRight.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'ArrowRight_32.png');

            % Create play_Metadata
            app.play_Metadata = uilabel(app.play_Grid);
            app.play_Metadata.VerticalAlignment = 'top';
            app.play_Metadata.WordWrap = 'on';
            app.play_Metadata.FontSize = 11;
            app.play_Metadata.Layout.Row = 11;
            app.play_Metadata.Layout.Column = 2;
            app.play_Metadata.Interpreter = 'html';
            app.play_Metadata.Text = '';

            % Create play_MetadataLabel
            app.play_MetadataLabel = uilabel(app.play_Grid);
            app.play_MetadataLabel.VerticalAlignment = 'bottom';
            app.play_MetadataLabel.FontSize = 10;
            app.play_MetadataLabel.Layout.Row = 9;
            app.play_MetadataLabel.Layout.Column = 2;
            app.play_MetadataLabel.Text = 'METADADOS';

            % Create play_Tree
            app.play_Tree = uitree(app.play_Grid);
            app.play_Tree.Multiselect = 'on';
            app.play_Tree.SelectionChangedFcn = createCallbackFcn(app, @play_TreeSelectionChanged, true);
            app.play_Tree.FontSize = 10;
            app.play_Tree.FontColor = [0.651 0.651 0.651];
            app.play_Tree.Layout.Row = [6 7];
            app.play_Tree.Layout.Column = 2;

            % Create play_TreeLabel
            app.play_TreeLabel = uilabel(app.play_Grid);
            app.play_TreeLabel.VerticalAlignment = 'bottom';
            app.play_TreeLabel.FontSize = 10;
            app.play_TreeLabel.Layout.Row = 4;
            app.play_TreeLabel.Layout.Column = 2;
            app.play_TreeLabel.Text = 'FLUXOS ESPECTRAIS';

            % Create play_TreeTitleUnderline
            app.play_TreeTitleUnderline = uiimage(app.play_Grid);
            app.play_TreeTitleUnderline.ScaleMethod = 'none';
            app.play_TreeTitleUnderline.Layout.Row = 2;
            app.play_TreeTitleUnderline.Layout.Column = 2;
            app.play_TreeTitleUnderline.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineH.svg');

            % Create play_TreeTitleGrid
            app.play_TreeTitleGrid = uigridlayout(app.play_Grid);
            app.play_TreeTitleGrid.ColumnWidth = {18, '1x'};
            app.play_TreeTitleGrid.RowHeight = {22};
            app.play_TreeTitleGrid.ColumnSpacing = 3;
            app.play_TreeTitleGrid.RowSpacing = 0;
            app.play_TreeTitleGrid.Padding = [2 0 0 0];
            app.play_TreeTitleGrid.Tag = 'COLORLOCKED';
            app.play_TreeTitleGrid.Layout.Row = 1;
            app.play_TreeTitleGrid.Layout.Column = 2;
            app.play_TreeTitleGrid.BackgroundColor = [0.749 0.749 0.749];

            % Create play_TreeTitleImage
            app.play_TreeTitleImage = uiimage(app.play_TreeTitleGrid);
            app.play_TreeTitleImage.ScaleMethod = 'none';
            app.play_TreeTitleImage.Layout.Row = 1;
            app.play_TreeTitleImage.Layout.Column = 1;
            app.play_TreeTitleImage.HorizontalAlignment = 'left';
            app.play_TreeTitleImage.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Classification_18.png');

            % Create play_TreeTitle
            app.play_TreeTitle = uilabel(app.play_TreeTitleGrid);
            app.play_TreeTitle.FontSize = 10;
            app.play_TreeTitle.Layout.Row = 1;
            app.play_TreeTitle.Layout.Column = 2;
            app.play_TreeTitle.Text = 'DADOS';

            % Create Tab3_DriveTest
            app.Tab3_DriveTest = uitab(app.TabGroup);
            app.Tab3_DriveTest.Title = 'DRIVE-TEST';

            % Create Tab4_SignalAnalysis
            app.Tab4_SignalAnalysis = uitab(app.TabGroup);
            app.Tab4_SignalAnalysis.Title = 'SIGNALANALYSIS';

            % Create Tab5_RFDataHub
            app.Tab5_RFDataHub = uitab(app.TabGroup);
            app.Tab5_RFDataHub.Title = 'RFDATAHUB';

            % Create Tab6_Config
            app.Tab6_Config = uitab(app.TabGroup);
            app.Tab6_Config.Title = 'CONFIG';

            % Create menu_Grid
            app.menu_Grid = uigridlayout(app.GridLayout);
            app.menu_Grid.ColumnWidth = {22, 74, '1x', 34, 5, 34, 34, 34, 5, 34, 34, 34, 34, '1x', 20, 20, 1, 20, 20};
            app.menu_Grid.RowHeight = {5, 7, 20, 7, 5};
            app.menu_Grid.ColumnSpacing = 5;
            app.menu_Grid.RowSpacing = 0;
            app.menu_Grid.Padding = [10 5 5 5];
            app.menu_Grid.Tag = 'COLORLOCKED';
            app.menu_Grid.Layout.Row = 1;
            app.menu_Grid.Layout.Column = 1;
            app.menu_Grid.BackgroundColor = [0.2 0.2 0.2];

            % Create menu_Button1
            app.menu_Button1 = uibutton(app.menu_Grid, 'state');
            app.menu_Button1.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button1.Tag = 'FILE';
            app.menu_Button1.Tooltip = {'Leitura de arquivos'};
            app.menu_Button1.Icon = 'OpenFile_32Yellow.png';
            app.menu_Button1.IconAlignment = 'top';
            app.menu_Button1.Text = '';
            app.menu_Button1.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button1.FontSize = 11;
            app.menu_Button1.Layout.Row = [2 4];
            app.menu_Button1.Layout.Column = 4;
            app.menu_Button1.Value = true;

            % Create menu_Separator1
            app.menu_Separator1 = uiimage(app.menu_Grid);
            app.menu_Separator1.ScaleMethod = 'none';
            app.menu_Separator1.Enable = 'off';
            app.menu_Separator1.Layout.Row = [2 4];
            app.menu_Separator1.Layout.Column = 5;
            app.menu_Separator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create menu_Button2
            app.menu_Button2 = uibutton(app.menu_Grid, 'state');
            app.menu_Button2.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button2.Tag = 'PLAYBACK';
            app.menu_Button2.Enable = 'off';
            app.menu_Button2.Tooltip = {'Playback'};
            app.menu_Button2.Icon = 'Playback_32White.png';
            app.menu_Button2.IconAlignment = 'top';
            app.menu_Button2.Text = '';
            app.menu_Button2.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button2.FontSize = 11;
            app.menu_Button2.Layout.Row = [2 4];
            app.menu_Button2.Layout.Column = 6;

            % Create menu_Button3
            app.menu_Button3 = uibutton(app.menu_Grid, 'state');
            app.menu_Button3.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button3.Tag = 'REPORT';
            app.menu_Button3.Enable = 'off';
            app.menu_Button3.Tooltip = {'Relatório'};
            app.menu_Button3.Icon = 'Report_32White.png';
            app.menu_Button3.IconAlignment = 'top';
            app.menu_Button3.Text = '';
            app.menu_Button3.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button3.FontSize = 11;
            app.menu_Button3.Layout.Row = [2 4];
            app.menu_Button3.Layout.Column = 7;

            % Create menu_Button4
            app.menu_Button4 = uibutton(app.menu_Grid, 'state');
            app.menu_Button4.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button4.Tag = 'MISC';
            app.menu_Button4.Enable = 'off';
            app.menu_Button4.Tooltip = {'Miscelâneas'};
            app.menu_Button4.Icon = 'Misc_32White.png';
            app.menu_Button4.IconAlignment = 'top';
            app.menu_Button4.Text = '';
            app.menu_Button4.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button4.FontSize = 11;
            app.menu_Button4.Layout.Row = [2 4];
            app.menu_Button4.Layout.Column = 8;

            % Create menu_Separator2
            app.menu_Separator2 = uiimage(app.menu_Grid);
            app.menu_Separator2.ScaleMethod = 'none';
            app.menu_Separator2.Enable = 'off';
            app.menu_Separator2.Layout.Row = [2 4];
            app.menu_Separator2.Layout.Column = 9;
            app.menu_Separator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create menu_Button5
            app.menu_Button5 = uibutton(app.menu_Grid, 'state');
            app.menu_Button5.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button5.Tag = 'DRIVETEST';
            app.menu_Button5.Enable = 'off';
            app.menu_Button5.Tooltip = {'Drive-test'};
            app.menu_Button5.Icon = 'DriveTestDensity_32White.png';
            app.menu_Button5.IconAlignment = 'top';
            app.menu_Button5.Text = '';
            app.menu_Button5.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button5.FontSize = 11;
            app.menu_Button5.Layout.Row = [2 4];
            app.menu_Button5.Layout.Column = 10;

            % Create menu_Button6
            app.menu_Button6 = uibutton(app.menu_Grid, 'state');
            app.menu_Button6.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button6.Tag = 'SIGNALANALYSIS';
            app.menu_Button6.Enable = 'off';
            app.menu_Button6.Tooltip = {'Análise de sinais'};
            app.menu_Button6.Icon = 'exceptionList_32White.png';
            app.menu_Button6.IconAlignment = 'top';
            app.menu_Button6.Text = '';
            app.menu_Button6.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button6.FontSize = 11;
            app.menu_Button6.Layout.Row = [2 4];
            app.menu_Button6.Layout.Column = 11;

            % Create menu_Button7
            app.menu_Button7 = uibutton(app.menu_Grid, 'state');
            app.menu_Button7.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button7.Tag = 'RFDATAHUB';
            app.menu_Button7.Tooltip = {'RFDataHub'};
            app.menu_Button7.Icon = 'mosaic_32White.png';
            app.menu_Button7.IconAlignment = 'top';
            app.menu_Button7.Text = '';
            app.menu_Button7.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button7.FontSize = 11;
            app.menu_Button7.Layout.Row = [2 4];
            app.menu_Button7.Layout.Column = 12;

            % Create menu_Button8
            app.menu_Button8 = uibutton(app.menu_Grid, 'state');
            app.menu_Button8.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button8.Tag = 'CONFIG';
            app.menu_Button8.Tooltip = {'Configurações gerais'};
            app.menu_Button8.Icon = 'Settings_36White.png';
            app.menu_Button8.IconAlignment = 'top';
            app.menu_Button8.Text = '';
            app.menu_Button8.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button8.FontSize = 11;
            app.menu_Button8.Layout.Row = [2 4];
            app.menu_Button8.Layout.Column = 13;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.menu_Grid);
            app.jsBackDoor.Layout.Row = [2 5];
            app.jsBackDoor.Layout.Column = 15;

            % Create FigurePosition
            app.FigurePosition = uiimage(app.menu_Grid);
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menu_ToolbarImageCliced, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Tooltip = {'Reposiciona janela'};
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 18;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout1_32White.png');

            % Create AppInfo
            app.AppInfo = uiimage(app.menu_Grid);
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menu_ToolbarImageCliced, true);
            app.AppInfo.Tooltip = {'Informações gerais'};
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 19;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Dots_32White.png');

            % Create menu_AppIcon
            app.menu_AppIcon = uiimage(app.menu_Grid);
            app.menu_AppIcon.Layout.Row = [1 5];
            app.menu_AppIcon.Layout.Column = 1;
            app.menu_AppIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Connect_36White.png');

            % Create menu_AppName
            app.menu_AppName = uilabel(app.menu_Grid);
            app.menu_AppName.WordWrap = 'on';
            app.menu_AppName.FontSize = 11;
            app.menu_AppName.FontColor = [1 1 1];
            app.menu_AppName.Layout.Row = [1 5];
            app.menu_AppName.Layout.Column = [2 3];
            app.menu_AppName.Interpreter = 'html';
            app.menu_AppName.Text = {'appAnalise v. 1.88.0'; '<font style="font-size: 9px;">R2024a</font>'};

            % Create DataHubLamp
            app.DataHubLamp = uiimage(app.menu_Grid);
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear o Sharepoint'};
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 16;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create popupContainerGrid
            app.popupContainerGrid = uigridlayout(app.GridLayout);
            app.popupContainerGrid.ColumnWidth = {'1x', 880, '1x'};
            app.popupContainerGrid.RowHeight = {'1x', 300, '1x'};
            app.popupContainerGrid.ColumnSpacing = 0;
            app.popupContainerGrid.RowSpacing = 0;
            app.popupContainerGrid.Layout.Row = 3;
            app.popupContainerGrid.Layout.Column = 1;
            app.popupContainerGrid.BackgroundColor = [1 1 1];

            % Create SplashScreen
            app.SplashScreen = uiimage(app.popupContainerGrid);
            app.SplashScreen.Layout.Row = 2;
            app.SplashScreen.Layout.Column = 2;
            app.SplashScreen.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'SplashScreen.gif');

            % Create file_ContextMenu_Tree1
            app.file_ContextMenu_Tree1 = uicontextmenu(app.UIFigure);

            % Create file_ContextMenu_delTree1Node
            app.file_ContextMenu_delTree1Node = uimenu(app.file_ContextMenu_Tree1);
            app.file_ContextMenu_delTree1Node.MenuSelectedFcn = createCallbackFcn(app, @file_ContextMenu_delTree1NodeSelected, true);
            app.file_ContextMenu_delTree1Node.ForegroundColor = [1 0 0];
            app.file_ContextMenu_delTree1Node.Text = 'Excluir';

            % Create file_ContextMenu_Tree2
            app.file_ContextMenu_Tree2 = uicontextmenu(app.UIFigure);

            % Create file_ContextMenu_delTree2Node
            app.file_ContextMenu_delTree2Node = uimenu(app.file_ContextMenu_Tree2);
            app.file_ContextMenu_delTree2Node.MenuSelectedFcn = createCallbackFcn(app, @file_ContextMenu_delTree2NodeSelected, true);
            app.file_ContextMenu_delTree2Node.ForegroundColor = [1 0 0];
            app.file_ContextMenu_delTree2Node.Text = 'Excluir';

            % Create play_FindPeaks_ContextMenu
            app.play_FindPeaks_ContextMenu = uicontextmenu(app.UIFigure);

            % Create play_FindPeaks_ContextMenu_search
            app.play_FindPeaks_ContextMenu_search = uimenu(app.play_FindPeaks_ContextMenu);
            app.play_FindPeaks_ContextMenu_search.MenuSelectedFcn = createCallbackFcn(app, @play_RFDataHubButtonPushed, true);
            app.play_FindPeaks_ContextMenu_search.Text = 'Consultar';

            % Create play_FindPeaks_ContextMenu_edit
            app.play_FindPeaks_ContextMenu_edit = uimenu(app.play_FindPeaks_ContextMenu);
            app.play_FindPeaks_ContextMenu_edit.Text = 'Editar';

            % Create play_FindPeaks_ContextMenu_analog
            app.play_FindPeaks_ContextMenu_analog = uimenu(app.play_FindPeaks_ContextMenu_edit);
            app.play_FindPeaks_ContextMenu_analog.MenuSelectedFcn = createCallbackFcn(app, @play_FindPeaks_TruncatedEmission, true);
            app.play_FindPeaks_ContextMenu_analog.Text = 'Não truncar';

            % Create play_FindPeaks_ContextMenu_digital
            app.play_FindPeaks_ContextMenu_digital = uimenu(app.play_FindPeaks_ContextMenu_edit);
            app.play_FindPeaks_ContextMenu_digital.MenuSelectedFcn = createCallbackFcn(app, @play_FindPeaks_TruncatedEmission, true);
            app.play_FindPeaks_ContextMenu_digital.Text = 'Truncar frequência';

            % Create play_FindPeaks_ContextMenu_del
            app.play_FindPeaks_ContextMenu_del = uimenu(app.play_FindPeaks_ContextMenu);
            app.play_FindPeaks_ContextMenu_del.MenuSelectedFcn = createCallbackFcn(app, @play_FindPeaks_delEmission, true);
            app.play_FindPeaks_ContextMenu_del.ForegroundColor = [1 0 0];
            app.play_FindPeaks_ContextMenu_del.Separator = 'on';
            app.play_FindPeaks_ContextMenu_del.Text = 'Excluir';

            % Create play_Channel_ContextMenu
            app.play_Channel_ContextMenu = uicontextmenu(app.UIFigure);

            % Create play_Channel_ContextMenu_addBandLimit
            app.play_Channel_ContextMenu_addBandLimit = uimenu(app.play_Channel_ContextMenu);
            app.play_Channel_ContextMenu_addBandLimit.MenuSelectedFcn = createCallbackFcn(app, @play_Channel_ContextMenu_addBandLimitSelected, true);
            app.play_Channel_ContextMenu_addBandLimit.Text = 'Adicionar limites à detecção';

            % Create play_Channel_ContextMenu_addEmission
            app.play_Channel_ContextMenu_addEmission = uimenu(app.play_Channel_ContextMenu);
            app.play_Channel_ContextMenu_addEmission.MenuSelectedFcn = createCallbackFcn(app, @play_Channel_ContextMenu_addEmissionSelected, true);
            app.play_Channel_ContextMenu_addEmission.Text = 'Adicionar canais como emissões';

            % Create play_Channel_ContextMenu_del
            app.play_Channel_ContextMenu_del = uimenu(app.play_Channel_ContextMenu);
            app.play_Channel_ContextMenu_del.MenuSelectedFcn = createCallbackFcn(app, @play_Channel_ContextMenu_delChannelSelected, true);
            app.play_Channel_ContextMenu_del.ForegroundColor = [1 0 0];
            app.play_Channel_ContextMenu_del.Separator = 'on';
            app.play_Channel_ContextMenu_del.Text = 'Excluir';

            % Create report_ContextMenu
            app.report_ContextMenu = uicontextmenu(app.UIFigure);

            % Create report_ContextMenu_del
            app.report_ContextMenu_del = uimenu(app.report_ContextMenu);
            app.report_ContextMenu_del.MenuSelectedFcn = createCallbackFcn(app, @report_ContextMenu_delSelected, true);
            app.report_ContextMenu_del.ForegroundColor = [1 0 0];
            app.report_ContextMenu_del.Separator = 'on';
            app.report_ContextMenu_del.Text = 'Excluir';

            % Create play_BandLimits_ContextMenu
            app.play_BandLimits_ContextMenu = uicontextmenu(app.UIFigure);

            % Create play_BandLimits_ContextMenu_del
            app.play_BandLimits_ContextMenu_del = uimenu(app.play_BandLimits_ContextMenu);
            app.play_BandLimits_ContextMenu_del.MenuSelectedFcn = createCallbackFcn(app, @play_BandLimits_ContextMenu_delSelected, true);
            app.play_BandLimits_ContextMenu_del.ForegroundColor = [1 0 0];
            app.play_BandLimits_ContextMenu_del.Text = 'Excluir';

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
