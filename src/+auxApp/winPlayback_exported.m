classdef winPlayback_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        dockModule_Undock               matlab.ui.control.Image
        dockModule_Close                matlab.ui.control.Image
        SubTabGroup                     matlab.ui.container.TabGroup
        SubTab1                         matlab.ui.container.Tab
        SubGrid1                        matlab.ui.container.GridLayout
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
        SubTab2                         matlab.ui.container.Tab
        SubGrid2                        matlab.ui.container.GridLayout
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
        SubTab3                         matlab.ui.container.Tab
        SubGrid3                        matlab.ui.container.GridLayout
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
        SubTab4                         matlab.ui.container.Tab
        SubGrid4                        matlab.ui.container.GridLayout
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
        SubTab5                         matlab.ui.container.Tab
        SubGrid5                        matlab.ui.container.GridLayout
        misc_Panel1                     matlab.ui.container.Panel
        misc_Grid1                      matlab.ui.container.GridLayout
        misc_DeleteAllLabel             matlab.ui.control.Label
        misc_DeleteAll                  matlab.ui.control.Button
        misc_AddCorrectionLabel         matlab.ui.control.Label
        misc_AddCorrection              matlab.ui.control.Button
        misc_EditLocationLabel          matlab.ui.control.Label
        misc_EditLocation               matlab.ui.control.Button
        misc_LevelFilteringLabel        matlab.ui.control.Label
        misc_LevelFiltering             matlab.ui.control.Button
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
        play_axesToolbar                matlab.ui.container.GridLayout
        axesTool_RestoreView_2          matlab.ui.control.Image
        axesTool_Pan                    matlab.ui.control.Image
        axesTool_DataTip                matlab.ui.control.Image
        axesTool_Waterfall              matlab.ui.control.Image
        axesTool_Occupancy              matlab.ui.control.Image
        axesTool_Persistance            matlab.ui.control.Image
        axesTool_MaxHold                matlab.ui.control.Image
        axesTool_Average                matlab.ui.control.Image
        axesTool_MinHold                matlab.ui.control.Image
        play_PlotPanel                  matlab.ui.container.Panel
        play_Metadata                   matlab.ui.control.Label
        play_MetadataLabel              matlab.ui.control.Label
        play_Tree                       matlab.ui.container.Tree
        play_TreeLabel                  matlab.ui.control.Label
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
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog

        referenceData

        rfDataHub
        rfDataHubLOG
        rfDataHubSummary
        rfDataHubAnnotation = table( ...
            string.empty, ...
            int32([]), ...
            struct('Latitude', {}, 'Longitude', {}, 'AntennaHeight', {}), ...
            'VariableNames', {'ID', 'Station', 'TXSite'} ...
        )
        
        UIAxes1
        UIAxes2
        UIAxes3
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
        )

        elevationObj = RF.Elevation
        ChannelReportObj

        filterTable = table( ...
            'Size', [0, 9], ...
            'VariableTypes', {'cell', 'int8', 'int8', 'cell', 'cell', 'int8', 'cell', 'logical', 'cell'}, ...
            'VariableNames', {'Order', 'ID', 'RelatedID', 'Type', 'Operation', 'Column', 'Value', 'Enable', 'uuid'} ...
        )
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'auxApp.winRFDataHub.filter_Tree'
                        filter_delFilter(app, struct('Source', app.contextmenu_del))

                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, varargin)
            try
                switch class(callingApp)
                    case {'winAppAnalise', 'winAppAnalise_exported', ...
                          'winMonitorRNI', 'winMonitorRNI_exported'}
                        operationType = varargin{1};

                        switch operationType
                            case 'onRFDataHubUpdate'
                                initializeRFDataHub(app)
                                applyInitialLayout(app)

                            otherwise
                                error('UnexpectedCall')
                        end

                    otherwise
                        error('UnexpectedCaller')
                end
            
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            persistent customizationStatus
            if tabIndex == -1
                customizationStatus = zeros(1, numel(app.SubTabGroup.Children), 'logical');
                return
            end

            if customizationStatus(tabIndex)
                return
            end

            appName = class(app);

            customizationStatus(tabIndex) = true;
            switch tabIndex
                case 1 % RFDATAHUB
                    elToModify = {app.SubTabGroup, app.AxesToolbar, app.stationInfo, app.stationInfoImage};
                    elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                    if ~isempty(elDataTag)
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('border', 'none', 'backgroundColor', 'transparent')), ...
                            struct('appName', appName, 'dataTag', elDataTag{2}, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                        });

                        ui.TextView.startup(app.jsBackDoor, elToModify{3}, appName);
                        ui.TextView.startup(app.jsBackDoor, elToModify{4}, appName, 'NÃO HÁ REGISTRO QUE ATENDA<br>AOS CRITÉRIOS DE FILTRAGEM');
                    end

                case 2 % FILTRAGEM
                    elToModify = {app.filter_Tree};
                    elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                    if ~isempty(elDataTag)
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {                                                                          ...
                            struct('appName', appName, 'dataTag', elDataTag{1}, 'listener', struct('componentName', 'auxApp.winRFDataHub.filter_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    end

                    filter_TreeBuilding(app)
                    
                case 3 % CONFIGURAÇÕES GERAIS
                    elToModify = {app.config_ElevationForceSearch};
                    elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                    if ~isempty(elDataTag)
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elDataTag{1}, 'generation', 1, 'style', struct('textAlign', 'justify')) ...
                        });
                    end

                    % Elevação:
                    app.config_ElevationAPISource.Value    = app.mainApp.General.Elevation.Server;
                    app.config_ElevationNPoints.Value      = num2str(app.mainApp.General.Elevation.Points);
                    app.config_ElevationForceSearch.Value  = app.mainApp.General.Elevation.ForceSearch;
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRFDataHub(app)

            % refRX: armazena o valor inicial da estação receptora de referência
            %        para fins de análise da edição.
            rxSite = referenceRX_InitialValue(app);
            app.referenceRX_Refresh.UserData.InitialValue = rxSite;
            referenceRX_UpdatePanel(app, rxSite)

            referenceRX_CalculateDistance(app, rxSite)

            % lastPrimarySearch
            filter_getReferenceSearch(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            % Controles de funcionalidades:
            app.referenceTX_EditionMode.UserData = false;
            app.referenceRX_EditionMode.UserData = false;
            app.tool_TableVisibility.UserData    = 1;
            app.tool_RFLinkButton.UserData       = false;
            app.tool_PDFButton.UserData          = false;

            startup_AxesCreation(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            filter_TableFiltering(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeRFDataHub(app)
            app.rfDataHub        = app.mainApp.rfDataHub;
            app.rfDataHubLOG     = app.mainApp.rfDataHubLOG;
            app.rfDataHubSummary = app.mainApp.rfDataHubSummary;
        end
        
        %-----------------------------------------------------------------%
        function startup_AxesCreation(app)
            hParent     = tiledlayout(app.plotPanel, 2, 2, "Padding", "none", "TileSpacing", "none");

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.config_Basemap.Value,                 ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '')});

            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2, 2];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            geolimits(app.UIAxes1, 'auto')
            plot.axes.Colormap(app.UIAxes1, app.config_Colormap.Value)

            if ismember(app.config_Basemap.Value, {'darkwater', 'none'})
                app.UIAxes1.Grid = 'on';
            end

            % Eixo cartesiano: PERFIL DE RELEVO
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'XGrid', 'off', 'XMinorGrid', 'off', 'XTick', [], 'XColor', [.8,.8,.8], 'XLimitMethod', 'padded', ...
                                                                    'YGrid', 'off', 'YMinorGrid', 'off', 'YTick', [], 'YColor', 'none',                               ...
                                                                    'Color', 'none', 'Clipping', 'off', 'LineWidth', 2, 'Layer', 'top', 'Visible', 'off'});
            app.UIAxes2.Layout.Tile = 3;
            app.UIAxes2.Layout.TileSpan = [1 2];
            app.UIAxes2.XAxis.TickLabelFormat = '%.1f';

            % Eixo cartesiano: DIAGRAMA DE RADIAÇÃO DA ANTENA
            app.UIAxes3 = polaraxes(app.stationInfoAntennaPattern, 'Units',             'normalized',      ...
                                                                   'Position',          [.08, 0, .9, .85], ...
                                                                   'ThetaZeroLocation', 'top',             ...
                                                                   'Toolbar',           [],                ...
                                                                   'FontSize',          8,                 ...
                                                                   'Color',             'yellow',          ...
                                                                   'ThetaTick',         0,                 ...
                                                                   'ThetaDir',          'clockwise',       ...
                                                                   'RTickLabel',        {});
            hold(app.UIAxes3, 'on')

            % Legenda
            % legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 4, 'LineWidth', .5, 'FontSize', 7.5)

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation(app.UIAxes1, [dataTipInteraction, zoomInteraction, panInteraction])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes2, dataTipInteraction)
        end

        %-----------------------------------------------------------------%
        function [idxRFDataHub, idxSelectedRow] = getRFDataHubIndex(app)
            if isempty(app.UITable.Selection)
                idxRFDataHub   = [];
                idxSelectedRow = 0;
                
            else
                idxSelectedRow = app.UITable.Selection(1);
                idxVirtual     = app.UITable.Data.ID(idxSelectedRow);    
                idxRFDataHub   = str2double(extractAfter(idxVirtual, '#'));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = RFLinkObjects(app, siteType, varargin)
            arguments
                app 
                siteType char {mustBeMember(siteType, {'TX', 'RX', 'TX-RX'})} = 'TX-RX'
            end

            arguments (Repeating)
                varargin
            end
            % txSite e rxSite estão como struct, mas basta mudar para "txsite" e 
            % "rxsite" que eles poderão ser usados em predições, uma vez que os 
            % campos da estrutura são idênticos às propriedades dos objetos.

            varargout = {};

            if contains(siteType, 'TX')
                idxRFDataHub = varargin{1};

                % TX
                txSite = struct('Name',                 'TX',                                                 ...
                                'TransmitterFrequency', double(app.rfDataHub.Frequency(idxRFDataHub)) * 1e+6, ...
                                'Latitude',             app.referenceTX_Latitude.Value,                       ...
                                'Longitude',            app.referenceTX_Longitude.Value,                      ...
                                'AntennaHeight',        app.referenceTX_Height.Value,                         ...
                                'ID',                   app.rfDataHub.ID(idxRFDataHub),                       ...
                                'Station',              app.rfDataHub.Station(idxRFDataHub));
                varargout{end+1} = txSite;
            end

            if contains(siteType, 'RX')
                % RX
                rxSite = struct('Name',                 'RX',                            ...
                                'Latitude',             app.referenceRX_Latitude.Value,  ...
                                'Longitude',            app.referenceRX_Longitude.Value, ...
                                'AntennaHeight',        app.referenceRX_Height.Value);
                varargout{end+1} = rxSite;
            end
        end


        %-----------------------------------------------------------------%
        % TAB: 1
        % PAINEL: ESTAÇÃO TRANSMISSORA - TX
        %-----------------------------------------------------------------%
        function referenceTX_UpdatePanel(app, idxRFDataHub)
            idxAnnotation = referenceTX_AddOrDelTXSiteTempList(app, 'Search', app.rfDataHub.ID(idxRFDataHub));

            % A ideia aqui é destacar as informações que foram editadas...
            txLatitudeFontColor   = [0,0,0];
            txLongitudeFontColor  = [0,0,0];
            txHeightFontColor     = [0,0,0];

            txLatitudeBackground  = [1,1,1];
            txLongitudeBackground = [1,1,1];
            txHeightBackground    = [1,1,1];

            if idxAnnotation
                app.referenceTX_Refresh.Visible = 1;
                % Latitude
                if app.rfDataHubAnnotation.TXSite(idxAnnotation).Latitude.Status
                    txLatitude  = app.rfDataHubAnnotation.TXSite(idxAnnotation).Latitude.EditedValue;
                    txLatitudeFontColor   = [1,1,1];
                    txLatitudeBackground  = [1,0,0];
                else
                    txLatitude  = app.rfDataHubAnnotation.TXSite(idxAnnotation).Latitude.RawValue;
                end

                % Longitude
                if app.rfDataHubAnnotation.TXSite(idxAnnotation).Longitude.Status
                    txLongitude = app.rfDataHubAnnotation.TXSite(idxAnnotation).Longitude.EditedValue;
                    txLongitudeFontColor  = [1,1,1];
                    txLongitudeBackground = [1,0,0];
                else
                    txLongitude = app.rfDataHubAnnotation.TXSite(idxAnnotation).Longitude.RawValue;
                end

                % Height
                if app.rfDataHubAnnotation.TXSite(idxAnnotation).AntennaHeight.Status
                    txHeight    = app.rfDataHubAnnotation.TXSite(idxAnnotation).AntennaHeight.EditedValue;
                    txHeightFontColor     = [1,1,1];
                    txHeightBackground    = [1,0,0];
                else
                    txHeight    = app.rfDataHubAnnotation.TXSite(idxAnnotation).AntennaHeight.RawValue;
                end

            else
                app.referenceTX_Refresh.Visible = 0;

                [txLatitude,  ...
                 txLongitude, ...
                 txHeight]  = referenceTX_getRawData(app);
            end

            set(app.referenceTX_Latitude,  'Value', txLatitude,  'FontColor', txLatitudeFontColor,  'BackgroundColor', txLatitudeBackground)
            set(app.referenceTX_Longitude, 'Value', txLongitude, 'FontColor', txLongitudeFontColor, 'BackgroundColor', txLongitudeBackground)
            set(app.referenceTX_Height,    'Value', txHeight,    'FontColor', txHeightFontColor,    'BackgroundColor', txHeightBackground)
        end

        %-----------------------------------------------------------------%
        function referenceTX_EditionPanelLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            idxRFDataHub = getRFDataHubIndex(app);
            hEditFields = findobj(app.referenceTX_Grid.Children, '-not', 'Type', 'uilabel');            

            switch editionStatus
                case 'on'
                    set(app.referenceTX_EditionMode, 'ImageSource', 'Edit_32Filled.png', 'UserData', true)
                    set(hEditFields, 'Editable', true)
                    
                    app.referenceTX_TitleGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.referenceTX_EditionConfirm.Enable = 1;
                    app.referenceTX_EditionCancel.Enable  = 1;

                case 'off'
                    referenceTX_UpdatePanel(app, idxRFDataHub)

                    set(app.referenceTX_EditionMode, 'ImageSource', 'Edit_32.png', 'UserData', false)
                    set(hEditFields, 'Editable', false)

                    app.referenceTX_TitleGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.referenceTX_EditionConfirm.Enable = 0;
                    app.referenceTX_EditionCancel.Enable  = 0;
            end
        end

        %-----------------------------------------------------------------%
        function varargout = referenceTX_AddOrDelTXSiteTempList(app, operationType, varargin)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'Search', 'Add', 'Del'})}
            end

            arguments (Repeating)
                varargin
            end

            switch operationType
                case 'Search'
                    ID = varargin{1};
                    [~, idxAnnotation] = ismember(ID, app.rfDataHubAnnotation.ID);
                    varargout = {idxAnnotation};

                case 'Add'
                    [txObj, ID, Station, idxAnnotation] = referenceTX_checkTXSiteTempList(app);

                    [txLatitude,  ...
                     txLongitude, ...
                     txHeight]  = referenceTX_getRawData(app);

                    % Confirma que ocorreu alteração em algum dos parâmetros 
                    % do registro.
                    txSiteDiff = struct('Latitude',      struct('Status', false, 'RawValue', txLatitude,  'EditedValue', []), ...
                                        'Longitude',     struct('Status', false, 'RawValue', txLongitude, 'EditedValue', []), ...
                                        'AntennaHeight', struct('Status', false, 'RawValue', txHeight,    'EditedValue', []));
                    txSiteDiffFlag = false;

                    % Cria estrutura que possibilita identificar quais dos
                    % parâmetros foram editados manualmente...
                    % Latitude
                    if ~isequal(txObj.Latitude, txLatitude)
                        txSiteDiffFlag = true;

                        txSiteDiff.Latitude.Status = true;
                        txSiteDiff.Latitude.EditedValue = txObj.Latitude;
                    end

                    % Longitude
                    if ~isequal(txObj.Longitude, txLongitude)
                        txSiteDiffFlag = true;

                        txSiteDiff.Longitude.Status = true;
                        txSiteDiff.Longitude.EditedValue = txObj.Longitude;
                    end

                    % Height
                    if ~isequal(txObj.AntennaHeight, txHeight)
                        txSiteDiffFlag = true;

                        txSiteDiff.AntennaHeight.Status = true;
                        txSiteDiff.AntennaHeight.EditedValue = txObj.AntennaHeight;
                    end

                    if txSiteDiffFlag
                        % Evidenciada alteração no registro. Cria-se nova linha
                        % ou edita-se a existente.
                        if idxAnnotation
                            if isequal(app.rfDataHubAnnotation.TXSite(idxAnnotation), txSiteDiff)
                                return
                            end
                        else
                            idxAnnotation = height(app.rfDataHubAnnotation) + 1;
                        end

                        app.rfDataHubAnnotation(idxAnnotation, :) = {ID, Station, txSiteDiff};
                        layout_AddNewTableStyle(app, 'EditedRows')
                        
                        % Força a atualização do painel HTML e dos plots...
                        app.stationInfo.UserData.idxRFDataHub = [];
                        UITableSelectionChanged(app)
                    else
                        % Não evidenciada alteração no registro. Apaga-se linha,
                        % caso existente. O usuário, aqui, desfez alteração
                        % manualmente (sem pressionar no Refresh).
                        if idxAnnotation
                            app.rfDataHubAnnotation(idxAnnotation, :) = [];
                            layout_AddNewTableStyle(app, 'EditedRows')

                            app.stationInfo.UserData.idxRFDataHub = [];
                            UITableSelectionChanged(app)
                        end
                    end

                case 'Del'
                    [~, ~, ~, idxAnnotation] = referenceTX_checkTXSiteTempList(app);
                    if idxAnnotation
                        app.rfDataHubAnnotation(idxAnnotation, :) = [];
                        layout_AddNewTableStyle(app, 'EditedRows')

                        app.stationInfo.UserData.idxRFDataHub = [];
                        UITableSelectionChanged(app)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function [txObj, ID, Station, idxAnnotation] = referenceTX_checkTXSiteTempList(app)
            idxRFDataHub = getRFDataHubIndex(app);

            % Objeto.
            txObj   = RFLinkObjects(app, 'TX', idxRFDataHub);
            ID      = txObj.ID;
            Station = txObj.Station;

            % Consulta se esse objeto está na lista temporária de estações
            % editadas do RFDataHub.
            [~, idxAnnotation] = ismember(ID, app.rfDataHubAnnotation.ID);
        end

        %-----------------------------------------------------------------%
        function [txLatitude, txLongitude, txHeight] = referenceTX_getRawData(app)
            idxRFDataHub = getRFDataHubIndex(app);

            txLatitude   = round(double(app.rfDataHub.Latitude(idxRFDataHub)),  6);
            txLongitude  = round(double(app.rfDataHub.Longitude(idxRFDataHub)), 6);
            txHeight     = round(str2double(char(app.rfDataHub.AntennaHeight(idxRFDataHub))), 1);
            if txHeight < 0
                txHeight = app.mainApp.General.RFDataHub.DefaultTX.Height;
            end
        end


        %-----------------------------------------------------------------%
        % TAB: 2
        % PAINEL: ESTAÇÃO RECEPTORA - RX
        %-----------------------------------------------------------------%
        function  rxSite = referenceRX_InitialValue(app)
            refRXFlag = false;

            switch class(app.mainApp)
                case 'winAppAnalise'
                    for ii = 1:numel(app.referenceData)
                        if app.referenceData(ii).GPS.Status
                            rxLatitude  = app.referenceData(ii).GPS.Latitude;
                            rxLongitude = app.referenceData(ii).GPS.Longitude;
        
                            % Salvo engano, o campo de altura só existe nos arquivos 
                            % gerados pelo appColeta, no formato "10m", por exemplo.
                            rxHeight = [];
                            if isfield(app.referenceData(ii).MetaData.Antenna, 'Height')
                                rxHeight = str2double(extractBefore(app.referenceData(ii).MetaData.Antenna.Height, 'm'));
                            end
        
                            if isempty(rxHeight) || isnan(rxHeight) || (rxHeight <= 0) || isinf(rxHeight)
                                rxHeight = app.mainApp.General.RFDataHub.DefaultRX.Height;
                            end
                            
                            refRXFlag   = true;
                            break
                        end
                    end
        
                    case 'winMonitorRNI'
                        if ~isempty(app.referenceData)
                            rxLatitude  = app.referenceData(1).Latitude;
                            rxLongitude = app.referenceData(1).Longitude;
                            rxHeight    = app.mainApp.General.RFDataHub.DefaultRX.Height;
                            refRXFlag   = true;
                        end
            end

            if ~refRXFlag
                rxLatitude  = app.mainApp.General.RFDataHub.DefaultRX.Latitude;
                rxLongitude = app.mainApp.General.RFDataHub.DefaultRX.Longitude;
                rxHeight    = app.mainApp.General.RFDataHub.DefaultRX.Height;
            end

            rxSite = struct('Name',          'RX',        ...
                            'Latitude',      rxLatitude,  ...
                            'Longitude',     rxLongitude, ...
                            'AntennaHeight', rxHeight);
        end

        %-----------------------------------------------------------------%
        function referenceRX_UpdatePanel(app, rxSite)
            app.referenceRX_Latitude.Value  = rxSite.Latitude;
            app.referenceRX_Longitude.Value = rxSite.Longitude;
            app.referenceRX_Height.Value    = rxSite.AntennaHeight;
        end

        %-----------------------------------------------------------------%
        function referenceRX_CalculateDistance(app, rxSite)
            app.rfDataHub.Distance = round(single(deg2km(distance(app.rfDataHub.Latitude,  ...
                                                                  app.rfDataHub.Longitude, ...
                                                                  rxSite.Latitude,         ...
                                                                  rxSite.Longitude))), 1);
            app.referenceRX_Refresh.UserData.DistanceColumnSource = rxSite;
        end

        %-----------------------------------------------------------------%
        function referenceRX_EditOrRefreshReferenceRX(app, operationType)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'Refresh', 'Edit'})}
            end

            refInitialValue         = app.referenceRX_Refresh.UserData.InitialValue;
            refDistanceColumnSource = app.referenceRX_Refresh.UserData.DistanceColumnSource;

            switch operationType
                case 'Refresh'
                    rxSite = refInitialValue;
                    referenceRX_UpdatePanel(app, rxSite)
                case 'Edit'
                    rxSite = RFLinkObjects(app, 'RX');
            end
            
            set([app.referenceRX_Latitude, app.referenceRX_Longitude, app.referenceRX_Height], 'BackGroundColor', [1,1,1], 'FontColor', [0,0,0])

            if ~isequal(rxSite, refInitialValue)
                app.referenceRX_Refresh.Visible = 1;
                
                if ~isequal(rxSite.Latitude, refInitialValue.Latitude)
                    set(app.referenceRX_Latitude, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end

                if ~isequal(rxSite.Longitude, refInitialValue.Longitude)
                    set(app.referenceRX_Longitude, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end

                if ~isequal(rxSite.AntennaHeight, refInitialValue.AntennaHeight)
                    set(app.referenceRX_Height, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end
            else
                app.referenceRX_Refresh.Visible = 0;
            end

            % Recalcula a coluna "Distance" caso a alteração tenha 
            % ocorrido em "Latitude" ou "Longitude".            
            if ~isequal(rmfield(refDistanceColumnSource, 'AntennaHeight'), rmfield(rxSite, 'AntennaHeight'))
                referenceRX_RefreshTableAndPlots(app, rxSite)
            elseif ~isequal(refDistanceColumnSource.AntennaHeight, rxSite.AntennaHeight)
                app.referenceRX_Refresh.UserData.DistanceColumnSource.AntennaHeight = rxSite.AntennaHeight;
                app.stationInfo.UserData.idxRFDataHub = [];
                UITableSelectionChanged(app)
            end
        end

        %-----------------------------------------------------------------%
        function referenceRX_EditionPanelLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            hEditFields = findobj(app.referenceRX_Grid.Children, '-not', 'Type', 'uilabel');

            switch editionStatus
                case 'on' 
                    set(app.referenceRX_EditionMode, 'ImageSource', 'Edit_32Filled.png', 'UserData', true)
                    set(hEditFields, 'Editable', true)
                    
                    app.referenceRX_TitleGrid.ColumnWidth(5:6) = {18, 18};
                    app.referenceRX_EditionConfirm.Enable = 1;
                    app.referenceRX_EditionCancel.Enable  = 1;

                case 'off'
                    set(app.referenceRX_EditionMode, 'ImageSource', 'Edit_32.png', 'UserData', false)
                    set(hEditFields, 'Editable', false)

                    app.referenceRX_TitleGrid.ColumnWidth(5:6) = {0, 0};
                    app.referenceRX_EditionConfirm.Enable = 0;
                    app.referenceRX_EditionCancel.Enable  = 0;
            end
        end

        %-----------------------------------------------------------------%
        function referenceRX_RefreshTableAndPlots(app, rxSite)
            referenceRX_CalculateDistance(app, rxSite)
            filter_TableFiltering(app)
        end


        %-----------------------------------------------------------------%
        % FILTRAGEM
        %-----------------------------------------------------------------%
        function filter_getReferenceSearch(app)
            % Inicialização do filtro, evitando carregar todas as estações
            % da base no plot.
            if isempty(app.filterTable)
                filterType          = app.mainApp.General.RFDataHub.DefaultFilter.ColumnLabel;
                filterValue         = app.mainApp.General.RFDataHub.DefaultFilter.Value;
                filterOperation     = app.mainApp.General.RFDataHub.DefaultFilter.Operation;
    
                hFilterNames        = findobj(app.filter_SecondaryTypePanel.Children,  'Type', 'uiradiobutton');
                hFilterOperations   = findobj(app.filter_SecondaryValuePanel.Children, 'Type', 'uitogglebutton');
                hFilterValues       = [app.filter_SecondaryNumValue1, ...
                                       app.filter_SecondaryNumValue2, ...
                                       app.filter_SecondaryTextFree,  ...
                                       app.filter_SecondaryTextList];
    
                listOfFilterNames   = {hFilterNames.Text};
                listOfOperations    = {hFilterOperations.Text};
    
                [~, idxFilter]      = ismember(filterType,      listOfFilterNames);
                [~, idxOperation]   = ismember(filterOperation, listOfOperations);
    
                if ~isempty(idxFilter) && ~isempty(idxOperation)
                    hFilterNames(idxFilter).Value   = true;
                    filter_typePanelSelectionChanged(app)
    
                    hFilterOperations(idxOperation).Value = true;
                    filter_SecondaryValuePanelSelectionChanged(app)
    
                    hFilterValues   = hFilterValues(arrayfun(@(x) x.Visible, hFilterValues));
                    for ii = 1:numel(hFilterValues)
                        hFilterValues(ii).Value = filterValue(ii);
                    end
                end
    
                columnName       = filter_FilterType2ColumnNames(app, filterType);
                [~, columnIndex] = ismember(columnName, app.rfDataHub.Properties.VariableNames);
    
                newFilter = {'Node', 1, -3, filterType, filterOperation, columnIndex, filterValue, true, char(matlab.lang.internal.uuid())};
    
                filter_addNewFilter(app, newFilter)
            end
        end

        %-----------------------------------------------------------------%
        function filter_addNewFilter(app, newFilter)
            app.filterTable(end+1, [1:6,8:9]) = newFilter([1:6,8:9]);
            app.filterTable.Value{end} = newFilter{7};
        end

        %-----------------------------------------------------------------%
        function filter_delOldFilter(app, idxFilter)
            % Apaga os ROI's, caso existentes.
            idxROI = find(strcmp(app.filterTable.Type, 'ROI'))';
            for ii = idxROI
                if ismember(ii, idxFilter)
                    UUID = app.filterTable.uuid{ii};
                    delete(findobj(app.UIAxes1.Children, 'UserData', UUID))
                end
            end

            % Apaga os filtros e atualiza os índices dos remanecestes. Por
            % fim, atualiza a árvore e o plot, criando os novos ROI's.
            app.filterTable(idxFilter, :) = [];

            idCurrentList = app.filterTable.ID';
            idNewValue    = 0;

            for ii = idCurrentList
                idNewValue = idNewValue+1;

                app.filterTable.ID(app.filterTable.ID == ii) = idNewValue;
                app.filterTable.RelatedID(app.filterTable.RelatedID == ii) = idNewValue;
            end

            filter_TreeBuilding(app)
            filter_TableFiltering(app)
        end        

        %-----------------------------------------------------------------%
        function columnName = filter_FilterType2ColumnNames(app, filterType)
            filterTypes = ["Fonte", "Frequência", "Largura banda", "Classe emissão", "Entidade", "Fistel", "Serviço", "Estação", "UF",    "Município", "Distância"];
            columnNames = ["Source", "Frequency", "BW",            "EmissionClass",  "_Name",    "Fistel", "Service", "Station", "State", "_Location", "Distance"];
            d = dictionary(filterTypes, columnNames);

            columnName = d(filterType);            
        end

        %-----------------------------------------------------------------%
        function filter_TreeBuilding(app)
            if ~isempty(app.filter_Tree.Children)
                delete(app.filter_Tree.Children)
            end

            idx1 = find(strcmp(app.filterTable.Order, 'Node'))';
            if ~isempty(idx1)
                checkedNodes = [];
                for ii = idx1
                    idx2 = find(app.filterTable.RelatedID == app.filterTable.ID(ii))';
                    if isempty(idx2)
                        parentNode = uitreenode(app.filter_Tree, 'Text', sprintf('#%d: RFDataHub.("%s") %s %s', app.filterTable.ID(ii),                        ...
                                                                                                                app.filterTable.Type{ii},                      ...
                                                                                                                app.filterTable.Operation{ii},                 ...
                                                                                                                filter_Value(app, app.filterTable.Value{ii})), ...
                                                                 'NodeData', ii, 'ContextMenu', app.ContextMenu);
                        if app.filterTable.Enable(ii)
                            checkedNodes = [checkedNodes, parentNode];
                        end

                    else
                        parentNode = uitreenode(app.filter_Tree, 'Text', '*.*', ...
                                                                 'NodeData', [ii, idx2], 'ContextMenu', app.ContextMenu);
                        for jj = [ii, idx2]
                            childNode = uitreenode(parentNode, 'Text', sprintf('#%d: RFDataHub.("%s") %s %s', app.filterTable.ID(jj),                        ...
                                                                                                              app.filterTable.Type{jj},                      ...
                                                                                                              app.filterTable.Operation{jj},                 ...
                                                                                                              filter_Value(app, app.filterTable.Value{jj})), ...
                                                               'NodeData', jj, 'ContextMenu', app.ContextMenu);
        
                            if app.filterTable.Enable(jj)
                                checkedNodes = [checkedNodes, childNode];
                            end
                        end
                    end
                end
                app.filter_Tree.CheckedNodes = checkedNodes;
                expand(app.filter_Tree, 'all')
            end

            app.filter_SecondaryReferenceFilter.Items = [{''}, cellstr("#" + string((idx1)))];
        end

        %-----------------------------------------------------------------%
        function filter_TableFiltering(app)
            app.progressDialog.Visible = 'visible';

            % Identifica registro inicialmente selecionado da tabela.
            initialSelectedRowID = '';
            if ~isempty(app.UITable.Selection)
                initialSelectedRowID = app.UITable.Data.ID{app.UITable.Selection(1)};
            end

            % Verifica se todos os filtros geográficos que envolvem ROIs
            % estão válidos, eventualmente recriando os ROIs.
            idxROIFilter = find(app.filterTable.Type == "ROI");
            if ~isempty(idxROIFilter) && any(cellfun(@(x) ~isvalid(x.handle), app.filterTable.Value(idxROIFilter)))
                delete(findobj(app.UIAxes1, 'Tag', 'FilterROI'))

                for ii = idxROIFilter'
                    roiFcn  = class(app.filterTable.Value{ii}.handle);
                    roiSpec = [structUtil.struct2cellWithFields(app.filterTable.Value{ii}.specification), ...
                               {'Color', [0.40,0.73,0.88], 'Tag', 'FilterROI', 'UserData', app.filterTable.uuid{ii}}];
                    if isa(app.filterTable.Value{ii}.handle, 'images.roi.Rectangle')
                        roiSpec = [roiSpec, {'Rotatable', true}];
                    end

                    hROI = plot.ROI.draw(roiFcn, app.UIAxes1, roiSpec);

                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)                    
                    addlistener(hROI, 'MovingROI', @app.filter_ROICallbacks);
                    addlistener(hROI, 'ROIMoved',  @app.filter_ROICallbacks);
                    addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));

                    app.filterTable.Value{ii}.handle = hROI;                    
                end
            end

            % Filtragem, preenchendo a tabela e o seu label (nº de linhas).
            idxRFDataHubArray = find(util.TableFiltering(app.rfDataHub, app.filterTable));
            columnGUINames    = {'ID', 'Frequency', 'Description', 'Service', 'Station', 'BW', 'Distance'};

            set(app.UITable, 'Selection', [], 'Data', app.rfDataHub(idxRFDataHubArray, columnGUINames))
            [app.UITable.Data, idxSort] = sortrows(app.UITable.Data, 'Distance');
            app.UITable.UserData = idxRFDataHubArray(idxSort);

            NN = numel(idxRFDataHubArray);
            MM = height(app.rfDataHub);
            app.tool_tableNRows.Text = sprintf('%d de %d registros\n%.1f %%', NN, MM, (NN/MM)*100);

            % Aplicando a seleção inicial da tabela, caso aplicável.
            idxSelectedRow = 0;
            if ~isempty(app.UITable.Data)
                if ~isempty(initialSelectedRowID)
                    [~, idxSelectedRow] = ismember(initialSelectedRowID, app.UITable.Data.ID);
                end

                if ~idxSelectedRow
                    idxSelectedRow = 1;
                end

                app.UITable.Selection = [idxSelectedRow, 1];
                scroll(app.UITable, 'Row', idxSelectedRow)
            end

            layout_AddNewTableStyle(app, 'EditedRows')
            
            % Plots.
            if isempty(app.UIAxes1.Legend)
                legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 4, 'LineWidth', .5, 'FontSize', 7.5)
            end

            plot_Stations(app)
            plot_RX(app)
            UITableSelectionChanged(app, struct('Source', app.UITable))
            
            plot.axes.StackingOrder.execute(app.UIAxes1, 'RFDataHub')
            app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', app.UIAxes1.LatitudeLimits, 'yLim', app.UIAxes1.LongitudeLimits, 'cLim', 'auto');

            app.progressDialog.Visible = 'hidden';
        end


        %-----------------------------------------------------------------%
        % PLOT
        %-----------------------------------------------------------------%
        function plot_Stations(app)
            delete(findobj(app.UIAxes1.Children, '-not', {'Tag', 'FilterROI', '-or', 'Tag', 'TX'}))
            app.stationInfo.UserData.idxRFDataHub = [];

            if ~isempty(app.UITable.Data)
                geolimits(app.UIAxes1, 'auto')

                idxRFDataHubArray = app.UITable.UserData;
                latitudeArray     = app.rfDataHub.Latitude(idxRFDataHubArray);
                longitudeArray    = app.rfDataHub.Longitude(idxRFDataHubArray);

                hStations = geoscatter(app.UIAxes1, latitudeArray, longitudeArray, ...
                    'MarkerEdgeColor', app.config_Station_Color.Value,             ...
                    'SizeData',        app.config_Station_Size.Value,              ...
                    'DisplayName',     'RFDataHub',                                ...
                    'Tag',             'Stations');
                plot.datatip.Template(hStations, 'winRFDataHub.Geographic', app.UITable.Data)
            end
        end

        %-----------------------------------------------------------------%
        function plot_RX(app)
            RX = struct('Latitude',  app.referenceRX_Latitude.Value, ...
                        'Longitude', app.referenceRX_Longitude.Value);

            hRX = geoscatter(app.UIAxes1, RX.Latitude, RX.Longitude, ...
                'Marker',          '^',                              ...
                'MarkerEdgeColor', app.config_RX_Color.Value,        ...
                'MarkerFaceColor', app.config_RX_Color.Value,        ...
                'SizeData',        44*app.config_RX_Size.Value,      ...
                'DisplayName',     'RX',                             ...
                'Tag',             'RX');
            plot.datatip.Template(hRX, 'Coordinates')
        end

        %-----------------------------------------------------------------%
        function plot_TX(app, idxRFDataHub, idxSelectedRow)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))

            if ~isempty(idxRFDataHub)
                txObj = RFLinkObjects(app, 'TX', idxRFDataHub);

                % Scatter
                hTXScatter = findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX');
                if isempty(hTXScatter)
                    hTX = geoscatter(app.UIAxes1, txObj.Latitude, txObj.Longitude, ...
                        'LineWidth',       2,                                      ...
                        'Marker',          'o',                                    ...
                        'MarkerEdgeColor', app.config_TX_Color.Value,              ...
                        'MarkerFaceColor', app.config_TX_Color.Value,              ...
                        'SizeData',        20*app.config_TX_Size.Value ,           ...
                        'PickableParts',   'none',                                 ...
                        'DisplayName',     'TX',                                   ...
                        'Tag',             'TX');
                    plot.datatip.Template(hTX, 'Coordinates')
                else
                    set(hTXScatter, 'LatitudeData',  txObj.Latitude, ...
                                    'LongitudeData', txObj.Longitude)
                end

                % DataTip
                if strcmp(app.config_TX_DataTipVisibility.Value, 'on')
                    hTXDataTip = findobj(app.UIAxes1.Children, 'Type', 'datatip', 'Tag', 'TX');
                    if isempty(hTXDataTip)
                        hStations = findobj(app.UIAxes1.Children, 'Tag', 'Stations');
                        datatip(hStations,                   ...
                            'DataIndex',     idxSelectedRow, ...
                            'PickableParts', 'none',         ...
                            'Tag',           'TX');
                    else
                        hTXDataTip.DataIndex = idxSelectedRow;
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function plot_createRFLinkPlot(app)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'RFLink'))
            cla(app.UIAxes2)
            delete(findobj(app.UIAxes3.Children, 'Tag', 'Azimuth'))

            if app.tool_RFLinkButton.UserData && ~isempty(app.UITable.Selection)
                idxRFDataHub = getRFDataHubIndex(app);

                app.progressDialog.Visible = 'visible';

                try
                    % OBJETOS TX e RX
                    [txObj, rxObj] = RFLinkObjects(app, 'TX-RX', idxRFDataHub);
        
                    % ELEVAÇÃO DO LINK TX-RX
                    [wayPoints3D, msgWarning] = Get(app.elevationObj, txObj, rxObj, str2double(app.config_ElevationNPoints.Value), app.config_ElevationForceSearch.Value, app.config_ElevationAPISource.Value);
                    if ~isempty(msgWarning)
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                    end
        
                    % PLOT: RFLink Map
                    geoplot(app.UIAxes1, wayPoints3D(:,1), wayPoints3D(:,2), Color='#c94756', LineStyle='-.', PickableParts='none', DisplayName='Enlace', Tag='RFLink');
                    
                    % PLOT: RFLink
                    plot.RFLink(app.UIAxes2, txObj, rxObj, wayPoints3D, 'light', true, true)
    
                    % PLOT: RFLink Azimuth
                    Azimuth = deg2rad(app.UIAxes2.UserData.Azimuth);
                    polarplot(app.UIAxes3, Azimuth,            app.UIAxes3.RLim(1), 'MarkerEdgeColor', '#c94756', 'MarkerFaceColor', '#c94756', 'Marker', 'o', 'PickableParts', 'none', 'Tag', 'Azimuth');
                    polarplot(app.UIAxes3, Azimuth,            app.UIAxes3.RLim(2), 'MarkerEdgeColor', '#c94756', 'MarkerFaceColor', '#c94756', 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Azimuth');
                    polarplot(app.UIAxes3, [Azimuth, Azimuth], app.UIAxes3.RLim,              'Color', '#c94756', 'LineStyle', '-.',                           'PickableParts', 'none', 'Tag', 'Azimuth');
                    
                catch
                end

                app.progressDialog.Visible = 'hidden';
            end

            plot_PolarAxesVisibility(app)
        end

        %-----------------------------------------------------------------%
        function plot_PolarAxesVisibility(app)
            % Visibilidade do eixo polar, com diagrama de radiação da
            % antena e azimute do enlace, caso aplicáveis.
            app.stationInfoAntennaPattern.Visible = ~isempty(app.UIAxes3.Children);
        end

        %-----------------------------------------------------------------%
        function misc_getChannelReport(app, operationType)
            arguments
                app
                operationType char {mustBeMember(operationType, {'OnlyCache', 'Cache+RealTime', 'RealTime'})}
            end

            if app.tool_PDFButton.UserData && ~isempty(app.UITable.Selection)
                idxRFDataHub = getRFDataHubIndex(app);

                URL = char(app.rfDataHub.URL(idxRFDataHub));
                if strcmp(URL, '-1')
                    layout_restartChannelReport(app)
                    return
                end

                % Caso a URL seja válida, cria-se objeto ChannelReport, caso
                % não existente.            
                if isempty(app.ChannelReportObj)
                    app.ChannelReportObj = RF.ChannelReport;
                end
    
                % A operação poderá ser demorada caso seja do tipo "Cache+RealTime" 
                % ou "RealTime". 
                if ismember(operationType, {'Cache+RealTime', 'RealTime'})
                    app.progressDialog.Visible = 'visible';
                end
    
                [idxCache, msgError] = Get(app.ChannelReportObj, URL, operationType);
                if ~isempty(idxCache)    
                    app.chReportHTML.HTMLSource     = app.ChannelReportObj.cacheMapping.File{idxCache};
                    app.chReportDownloadTime.Text   = sprintf('DOWNLOAD EM %s', app.ChannelReportObj.cacheMapping.Timestamp{idxCache});
                    app.chReportHotDownload.Visible = 1;
                    app.chReportUndock.Visible      = 1;
    
                else
                    layout_restartChannelReport(app)
    
                    if ismember(operationType, {'Cache+RealTime', 'RealTime'}) && ~isempty(msgError)
                        ui.Dialog(app.UIFigure, 'error', msgError);
                    end
                end
    
                if strcmp(app.progressDialog.Visible, 'visible')
                    app.progressDialog.Visible = 'hidden';
                end

            else
                layout_restartChannelReport(app)
            end
        end

        %-----------------------------------------------------------------%
        function layout_restartChannelReport(app)
            app.chReportHTML.HTMLSource     = 'Warning2.html';
            app.chReportDownloadTime.Text   = '';
            app.chReportHotDownload.Visible = 0;
            app.chReportUndock.Visible      = 0;
        end

        %-----------------------------------------------------------------%
        function layout_AddNewTableStyle(app, operationType, varargin)
            arguments
                app
                operationType char {mustBeMember(operationType, {'EditedRows', 'RowSelectionChanged'})}
            end

            arguments (Repeating)
                varargin
            end

            switch operationType
                case 'EditedRows'
                    styleType = "cell";
                    layout_RemoveOldTableStyle(app, styleType)

                    idxRows = find(contains(app.UITable.Data.ID, app.rfDataHubAnnotation.ID));
                    if ~isempty(idxRows)
                        listOfCells = [idxRows, 2*ones(numel(idxRows), 1)];
                        addStyle(app.UITable, uistyle('Icon', 'Edit_32.png',  'IconAlignment', 'leftmargin'), styleType, listOfCells)
                    end

                case 'RowSelectionChanged'
                    styleType = "row";
                    layout_RemoveOldTableStyle(app, styleType)

                    idxSelectedRow = varargin{1};
                    if idxSelectedRow
                        addStyle(app.UITable, uistyle('BackgroundColor', '#d8ebfa'), styleType, idxSelectedRow)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function layout_RemoveOldTableStyle(app, styleType)
            idxStyle = find(app.UITable.StyleConfigurations.Target == styleType);
            if ~isempty(idxStyle)
                removeStyle(app.UITable, idxStyle)
            end
        end

        %-----------------------------------------------------------------%
        function layout_FilterOperationPanel(app, filterType, filterDefault)            
            layout_FilterDefaultValues(app)
            filter_SecondaryReferenceFilterValueChanged(app)

            hComp = findobj(app.filter_SecondaryValuePanel, 'Type', 'uitogglebutton');
            hCompTagFlag = contains(arrayfun(@(x) x.Tag, hComp, 'UniformOutput', false), filterType);

            set(hComp(hCompTagFlag),  Enable=1)
            set(hComp(~hCompTagFlag), Enable=0)

            selectedButton = app.filter_SecondaryValuePanel.SelectedObject;
            if ~selectedButton.Enable
                switch filterType
                    case {'textList1', 'ROI'}
                        app.filter_SecondaryOperation3.Value = 1; % CONTÉM

                    case 'textList3'
                        app.filter_SecondaryOperation2.Value = 1; % DIFERENTE

                    otherwise
                        app.filter_SecondaryOperation1.Value = 1; % IGUAL
                end
            end

            switch filterType
                case 'numeric'
                    app.filter_SecondaryNumValue1.Visible    = 1;
                    app.filter_SecondaryNumSeparator.Visible = 1;
                    app.filter_SecondaryNumValue2.Visible    = 1;
                    app.filter_SecondaryTextFree.Visible     = 0;
                    app.filter_SecondaryTextList.Visible     = 0;

                case 'textFree'
                    app.filter_SecondaryNumValue1.Visible    = 0;
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
                    app.filter_SecondaryTextFree.Visible     = 1;
                    app.filter_SecondaryTextList.Visible     = 0;

                case {'textList1', 'textList2', 'ROI'}
                    app.filter_SecondaryNumValue1.Visible    = 0;
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
                    app.filter_SecondaryTextFree.Visible     = 0;
                    app.filter_SecondaryTextList.Visible     = 1;
                    app.filter_SecondaryTextList.Items       = filterDefault;

                case 'textList3'
                    app.filter_SecondaryNumValue1.Visible    = 0;
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
                    app.filter_SecondaryTextFree.Visible     = 0;
                    app.filter_SecondaryTextList.Visible     = 1;
                    app.filter_SecondaryTextList.Items       = filterDefault;
            end
        end

        %-----------------------------------------------------------------%
        function layout_FilterDefaultValues(app)
            app.filter_SecondaryNumValue1.Value       = -1;
            app.filter_SecondaryNumValue2.Value       = -1;
            app.filter_SecondaryTextFree.Value        = '';
            app.filter_SecondaryTextList.Items        = {};
            app.filter_SecondaryLogicalOperator.Items = {'E (&&)'};
        end

        %-----------------------------------------------------------------%
        function filterValue = filter_Value(app, filterValue)
            if isnumeric(filterValue)
                if isscalar(filterValue)
                    filterValue = string(filterValue);
                else
                    filterValue = "[" + strjoin(string(filterValue), ', ') + "]";
                end
            elseif ischar(filterValue)
                filterValue = sprintf('"%s"', upper(filterValue));
            else
                filterValue = '⌂';
            end
        end

        %-----------------------------------------------------------------%
        function filter_ROICallbacks(app, src, event)
            switch(event.EventName)
                case 'MovingROI'
                    plot.axes.Interactivity.DefaultDisable(app.UIAxes1)
                    
                case 'ROIMoved'
                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)
                    
                    filter_TableFiltering(app)
                    if isvalid(event.Source)
                        uistack(event.Source, 'top')
                    end
            end            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, filterTable, rfDataHubAnnotation)
            
            % Módulo auxiliar RFDataHub, consumido, em 18/09/2025, tanto pelo 
            % appAnalise quanto pelo monitorRNI. Toda modificação deste módulo
            % demanda a posterior atualização MANUAL do ".mlapp" em todos os
            % projetos.
            try
                switch class(mainApp)
                    case 'winAppAnalise'
                        app.referenceData = mainApp.specData;
                    case 'winMonitorRNI'
                        app.referenceData = mainApp.measData;
                    otherwise
                        error('UnexpectedCaller')
                end
                app.UIFigure.Name = class.Constants.appName;
        
                if nargin == 4
                    app.filterTable = filterTable;
                    app.rfDataHubAnnotation = rfDataHubAnnotation;
                end

                appEngine.boot(app, app.Role, mainApp)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'RFDATAHUB')
            delete(app)
            
        end

        % Callback function
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

        % Callback function
        function Toolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.tool_ControlPanelVisibility
                    if app.SubTabGroup.Visible
                        app.tool_ControlPanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.SubTabGroup.Visible = 0;
                        app.Document.Layout.Column = [2 5];
                    else
                        app.tool_ControlPanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.SubTabGroup.Visible = 1;
                        app.Document.Layout.Column = [4 5];
                    end

                case app.tool_TableVisibility
                    app.tool_TableVisibility.UserData = mod(app.tool_TableVisibility.UserData + 1, 3);
                    switch app.tool_TableVisibility.UserData
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
                    app.tool_PDFButton.UserData = ~app.tool_PDFButton.UserData;
                    if app.tool_PDFButton.UserData
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout.
                        if app.tool_TableVisibility.UserData == 2
                            app.tool_TableVisibility.UserData = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                        end

                        app.Document.ColumnWidth(4:7) = {10,22,22,'1x'};
                    else
                        app.Document.ColumnWidth(4:7) = {0,0,0,0};
                    end
                    misc_getChannelReport(app, 'Cache+RealTime')

                case app.tool_RFLinkButton
                    app.tool_RFLinkButton.UserData = ~app.tool_RFLinkButton.UserData;
                    if app.tool_RFLinkButton.UserData
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout. O pause é uma espécie de "drawnow"
                        % e garante que o plot será realizado corretamente.
                        if app.tool_TableVisibility.UserData == 2
                            app.tool_TableVisibility.UserData = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                            pause(.100)
                        end
                        
                        app.UIAxes1.Layout.TileSpan = [1,2];
                        set(findobj(app.UIAxes2), 'Visible', 1)
                    else
                        app.UIAxes1.Layout.TileSpan = [2,2];
                        set(findobj(app.UIAxes2), 'Visible', 0)
                    end
                    plot_createRFLinkPlot(app)
            end

        end

        % Callback function
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

        % Callback function
        function AxesToolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    geolimits(app.UIAxes1, app.restoreView(1).xLim, app.restoreView(1).yLim)

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes1, app.axesTool_RegionZoom)
            end

        end

        % Callback function
        function PDFToolbar_ReportImageClicked(app, event)
            
            if strcmp(app.chReportHTML.HTMLSource, 'Warning2.html')
                return
            end

            switch event.Source
                case app.chReportHotDownload
                    misc_getChannelReport(app, 'RealTime')

                case app.chReportUndock
                    switch app.mainApp.executionMode
                        case 'webApp'
                            idxRFDataHub = getRFDataHubIndex(app);
                            URL = char(app.rfDataHub.URL(idxRFDataHub));
                            web(URL, '-new')
                        otherwise
                            appEngine.util.OperationSystem('openFile', app.chReportHTML.HTMLSource)
                    end                    
                    Toolbar_InteractionImageClicked(app, struct('Source', app.tool_PDFButton))
            end

        end

        % Callback function
        function UITableSelectionChanged(app, event)
            
            [idxRFDataHub, idxSelectedRow] = getRFDataHubIndex(app);

            % Caso nenhum registro atenda aos critérios de filtragem,
            % reinicializa a área de visualização do app.
            if isempty(idxRFDataHub)
                % Painel:
                app.referenceTX_Refresh.Visible     = 0;
                app.referenceTX_EditionMode.Visible = 0;
                app.referenceTX_Latitude.Value      = -1;
                app.referenceTX_Longitude.Value     = -1;
                app.referenceTX_Height.Value        = 0;

                ui.TextView.update(app.stationInfo, '');
                app.stationInfoImage.Visible = 'on';

                % Área de plot/PDF:
                delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))
                cla(app.UIAxes2)
                cla(app.UIAxes3)

                plot_PolarAxesVisibility(app)
                layout_restartChannelReport(app)
                return

            % Caso a alteração na seleção da tabela seja restrita à coluna,
            % por exemplo, mantendo-se selecionada a mesma linha, não será 
            % realizado um novo plot.
            elseif isequal(app.stationInfo.UserData.idxRFDataHub, idxRFDataHub)
                return
            end

            app.stationInfo.UserData.idxRFDataHub = idxRFDataHub;
            layout_AddNewTableStyle(app, 'RowSelectionChanged', idxSelectedRow)
            
            % Estação transmissora - TX
            if ~app.referenceTX_EditionMode.Visible
                app.referenceTX_EditionMode.Visible = 1;
            end

            referenceTX_UpdatePanel(app, idxRFDataHub)
            if app.referenceTX_EditionMode.UserData
                referenceTX_EditionModeImageClicked(app, struct('Source', app.referenceTX_EditionMode))
            end

            % Painel HTML
            ui.TextView.update(app.stationInfo, util.HtmlTextGenerator.Station(app.rfDataHub, idxRFDataHub, app.rfDataHubLOG, app.mainApp.General));
            app.stationInfoImage.Visible = 'off';

            % Painel PDF
            if app.rfDataHub.Source(idxRFDataHub) == "MOSAICO-SRD"
                misc_getChannelReport(app, 'Cache+RealTime')
            else
                layout_restartChannelReport(app)
            end
                
            % Plot "AntennaPattern"
            % O bloco try/catch protege possível erro no parser da informação
            % do Mosaico. Como exposto em model.RFDataHub.parsingAntennaPattern
            % foram identificados quatro formas de armazenar a informação.
            cla(app.UIAxes3)
            if app.rfDataHub.AntennaPattern(idxRFDataHub) ~= "-1"
                try
                    [angle, gain] = model.RFDataHub.parsingAntennaPattern(app.rfDataHub.AntennaPattern(idxRFDataHub), 360);
                    hAntennaPattern = polarplot(app.UIAxes3, angle, gain, 'Tag', 'AntennaPattern');
                    plot.datatip.Template(hAntennaPattern, "AntennaPattern")
                catch
                end
            end

            % Plot "TX"
            plot_TX(app, idxRFDataHub, idxSelectedRow)

            % Plot "RFLink"
            plot_createRFLinkPlot(app)
            
        end

        % Callback function
        function referenceTX_EditionModeImageClicked(app, event)
            
            switch event.Source
                case app.referenceTX_Refresh
                    referenceTX_AddOrDelTXSiteTempList(app, 'Del')
                    referenceTX_EditionPanelLayout(app, 'off')

                case app.referenceTX_EditionMode
                    app.referenceTX_EditionMode.UserData = ~app.referenceTX_EditionMode.UserData;
                    
                    if app.referenceTX_EditionMode.UserData
                        referenceTX_EditionPanelLayout(app, 'on')
                        focus(app.referenceTX_Latitude)
                    else
                        referenceTX_EditionModeImageClicked(app, struct('Source', app.referenceTX_EditionCancel))
                    end

                case app.referenceTX_EditionConfirm
                    referenceTX_AddOrDelTXSiteTempList(app, 'Add')
                    referenceTX_EditionPanelLayout(app, 'off')

                case app.referenceTX_EditionCancel
                    idxRFDataHub = getRFDataHubIndex(app);
                    referenceTX_UpdatePanel(app, idxRFDataHub)
                    referenceTX_EditionPanelLayout(app, 'off')
            end

        end

        % Callback function
        function referenceRX_EditionModeImageClicked(app, event)
            
            switch event.Source
                case app.referenceRX_Refresh
                    referenceRX_EditOrRefreshReferenceRX(app, 'Refresh')
                    referenceRX_EditionPanelLayout(app, 'off')

                case app.referenceRX_EditionMode
                    app.referenceRX_EditionMode.UserData = ~app.referenceRX_EditionMode.UserData;

                    if app.referenceRX_EditionMode.UserData
                        referenceRX_EditionPanelLayout(app, 'on')
                        focus(app.referenceRX_Latitude)
                    else
                        referenceRX_EditionModeImageClicked(app, struct('Source', app.referenceRX_EditionCancel))
                    end

                case app.referenceRX_EditionConfirm
                    referenceRX_EditOrRefreshReferenceRX(app, 'Edit')
                    referenceRX_EditionPanelLayout(app, 'off')

                case app.referenceRX_EditionCancel
                    rxSite = app.referenceRX_Refresh.UserData.DistanceColumnSource;
                    referenceRX_UpdatePanel(app, rxSite)
                    referenceRX_EditionPanelLayout(app, 'off')
            end        

        end

        % Callback function
        function filter_typePanelSelectionChanged(app, event)
                        
            selectedButton = app.filter_SecondaryTypePanel.SelectedObject;
            switch selectedButton
                case app.filter_SecondaryType1                              % BASE DE DADOS
                    filterType    = 'textList1';
                    filterDefault = app.rfDataHubSummary.Source.RawCategories;

                case {app.filter_SecondaryType2, ...                      % FREQUÊNCIA
                      app.filter_SecondaryType3, ...                      % LARGURA BANDA
                      app.filter_SecondaryType6, ...                      % FISTEL
                      app.filter_SecondaryType7, ...                      % SERVIÇO
                      app.filter_SecondaryType8, ...                      % ESTAÇÃO
                      app.filter_SecondaryType11}                         % DISTÂNCIA
                    filterType    = 'numeric';
                    filterDefault = {};

                case {app.filter_SecondaryType4, ...                      % CLASSE EMISSÃO (DESIGNAÇÃO)
                      app.filter_SecondaryType5, ...                      % ENTIDADE
                      app.filter_SecondaryType10}                         % MUNICÍPIO
                    filterType    = 'textFree';
                    filterDefault = {};

                case app.filter_SecondaryType9                            % UF
                    filterType    = 'textList2';
                    filterDefault = app.rfDataHubSummary.State.Categories;

                case app.filter_SecondaryType12                           % ROI
                    filterType    = 'ROI';
                    filterDefault = {'ROI:Círculo', 'ROI:Retângulo', 'ROI:Polígono'};

                case app.filter_SecondaryType13                           % Padrão de antena
                    filterType    = 'textList3';
                    filterDefault = {'-1'};
            end

            layout_FilterOperationPanel(app, filterType, filterDefault)
            filter_SecondaryValuePanelSelectionChanged(app)
            
        end

        % Callback function
        function filter_SecondaryValuePanelSelectionChanged(app, event)
            
            selectedButton = app.filter_SecondaryValuePanel.SelectedObject;
            switch selectedButton
                case {app.filter_SecondaryOperation9, app.filter_SecondaryOperation10}
                    app.filter_SecondaryNumSeparator.Visible = 1;
                    app.filter_SecondaryNumValue2.Visible    = 1;
                    
                otherwise
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
            end
            
        end

        % Callback function
        function filter_SecondaryReferenceFilterValueChanged(app, event)
            
            value = app.filter_SecondaryReferenceFilter.Value;
            if isempty(value)
                app.filter_SecondaryLogicalOperator.Items = {'E (&&)'};
            else
                app.filter_SecondaryLogicalOperator.Items = {'OU (||)'};
            end
            
        end

        % Callback function
        function filter_addFilter(app, event)
            
            selectedFilterType      = app.filter_SecondaryTypePanel.SelectedObject;
            selectedFilterOperation = app.filter_SecondaryValuePanel.SelectedObject;

            if isempty(app.filter_SecondaryReferenceFilter.Value)
                Order     = 'Node';
                RelatedID = -1;
            else
                Order     = 'Child';
                RelatedID = str2double(app.filter_SecondaryReferenceFilter.Value(2:end));
            end
            UUID = char(matlab.lang.internal.uuid());

            switch selectedFilterType
                case {app.filter_SecondaryType1, ...                      % BASE DE DADOS
                      app.filter_SecondaryType9, ...                      % UF
                      app.filter_SecondaryType13}                         % PADRÃO DA ANTENA
                    Value = app.filter_SecondaryTextList.Value;

                case {app.filter_SecondaryType2, ...                      % FREQUÊNCIA
                      app.filter_SecondaryType3, ...                      % LARGURA BANDA
                      app.filter_SecondaryType6, ...                      % FISTEL
                      app.filter_SecondaryType7, ...                      % SERVIÇO
                      app.filter_SecondaryType8, ...                      % ESTAÇÃO
                      app.filter_SecondaryType11}                         % DISTÂNCIA

                    if ismember(selectedFilterOperation.Text, {'<>', '><'})
                        Value = [app.filter_SecondaryNumValue1.Value, ...
                                 app.filter_SecondaryNumValue2.Value];
                    else
                        Value = app.filter_SecondaryNumValue1.Value;
                    end

                case {app.filter_SecondaryType4, ...                      % CLASSE EMISSÃO (DESIGNAÇÃO)
                      app.filter_SecondaryType5, ...                      % ENTIDADE
                      app.filter_SecondaryType10}                         % MUNICÍPIO
                    Value = app.filter_SecondaryTextFree.Value;

                case app.filter_SecondaryType12                           % ROI
                    hROI = [];

                    plot.axes.Interactivity.DefaultDisable(app.UIAxes1)
                    pause(.1)

                    switch app.filter_SecondaryTextList.Value
                        case 'ROI:Círculo';   roiFcn = 'drawcircle';    roiNameArgument = '';
                        case 'ROI:Retângulo'; roiFcn = 'drawrectangle'; roiNameArgument = 'Rotatable=true, ';
                        case 'ROI:Polígono';  roiFcn = 'drawpolygon';   roiNameArgument = '';
                    end
                    eval(sprintf('hROI = %s(app.UIAxes1, Color=[0.40,0.73,0.88], LineWidth=1, Deletable=0, FaceSelectable=0, %sTag="FilterROI", UserData="%s");', roiFcn, roiNameArgument, UUID))
                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)

                    if isempty(hROI.Position)
                        delete(hROI)
                        return
                    end
                    addlistener(hROI, 'MovingROI', @app.filter_ROICallbacks);
                    addlistener(hROI, 'ROIMoved',  @app.filter_ROICallbacks);
                    addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));
                    Value = struct('handle', hROI, 'specification', plot.ROI.specification(hROI));
            end

            columnName = selectedFilterType.Tag;
            [~, columnIndex] = ismember(columnName, app.rfDataHub.Properties.VariableNames);
            if ~columnIndex
                columnIndex = -1;                                         % ROI
            end

            newFilter     = {Order, height(app.filterTable)+1, RelatedID,           ...
                             selectedFilterType.Text, selectedFilterOperation.Text, ...
                             columnIndex, Value, true, UUID};
            newFilterFlag = true;

            for ii = 1:height(app.filterTable)
                if isequal(app.filterTable{ii,[4,5,7]}, newFilter([4,5,7]))
                    newFilterFlag = false;
                    break
                end
            end

            if ~newFilterFlag
                msg = 'Filtro já incluído!';
                ui.Dialog(app.UIFigure, 'warning', msg);
                if exist('hROI', 'var')
                    delete(hROI)
                end
                
                return
            end

            filter_addNewFilter(app, newFilter)
            filter_TreeBuilding(app)
            filter_TableFiltering(app)

        end

        % Menu selected function: contextmenu_del, contextmenu_delAll
        function filter_delFilter(app, event)
            
            if isempty(app.filterTable)
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
                    idx1 = [idx1, find(ismember(app.filterTable.RelatedID, idx1))'];

                case app.contextmenu_delAll
                    idx1 = 1:height(app.filterTable);
            end 
    
            if ~isempty(idx1)
                filter_delOldFilter(app, idx1);
            end

        end

        % Callback function
        function filter_TreeCheckedNodesChanged(app, event)
            
            hTree             = findobj(app.filter_Tree, '-not', 'Type', 'uicheckboxtree');
            
            hTreeNode         = arrayfun(@(x) x.NodeData, hTree, 'UniformOutput', false);
            hTreeNodeDataList = unique(horzcat(hTreeNode{:}));

            hCheckedNode      = arrayfun(@(x) x.NodeData, app.filter_Tree.CheckedNodes, 'UniformOutput', false);
            hCheckedNodeData  = unique(horzcat(hCheckedNode{:}));

            disableIndexList  = setdiff(hTreeNodeDataList, hCheckedNodeData);
            enableIndexList   = setdiff((1:height(app.filterTable))', disableIndexList);

            app.filterTable.Enable(disableIndexList) = false;
            app.filterTable.Enable(enableIndexList)  = true;

            filter_TableFiltering(app)
            
        end

        % Callback function
        function config_geoAxesColorParameterChanged(app, event)
            
            selectedColor = event.Source.Value;

            switch event.Source
                case app.config_Station_Color
                    set(findobj(app.UIAxes1.Children, 'Tag', 'Stations'), 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.config_TX_Color
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX'), 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.config_RX_Color
                    set(findobj(app.UIAxes1.Children, 'Tag', 'RX'),  'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)
            end

        end

        % Callback function
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

                case app.config_TX_DataTipVisibility
                    switch app.config_TX_DataTipVisibility.Value
                        case 'on'
                            [idxRFDataHub, idxSelectedRow] = getRFDataHubIndex(app);
                            plot_TX(app, idxRFDataHub, idxSelectedRow)
                            plot.axes.StackingOrder.execute(app.UIAxes1, 'RFDataHub')
                            
                        case 'off'
                            hDataTip = findobj(app.UIAxes1.Children, 'Type', 'datatip', 'Tag', 'TX');
                            delete(hDataTip)
                    end

                case app.config_Station_Size
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'Stations'), 'SizeData', event.Value)

                case app.config_TX_Size
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX'),       'SizeData', 20*event.Value)

                case app.config_RX_Size
                    set(findobj(app.UIAxes1.Children,                    'Tag', 'RX'),       'SizeData', 44*event.Value)
            end

        end

        % Callback function
        function config_RefreshImageClicked(app, event)
            
            % ToDo: Pendente finalizar a implementação dessa funcionalidade.
            % Não gostei de plotar novamente a coisa... preciso identificar
            % os parâmetros que foram alterados, chamando individualmente
            % os callbacks de cada parâmetro. O botão ficará invisível até 
            % ajuste desses pontos.

            app.config_ElevationAPISource.Value = app.mainApp.General.Elevation.Server;
            app.config_ElevationNPoints.Value      = num2str(app.mainApp.General.Elevation.Points);

            % % Eixo geográfico - app.UIAxes1
            app.config_Colormap.Value             = 'turbo';            
            app.config_Station_Color.Value        = [0 1 1];
            app.config_Station_Size.Value         = 1;
            app.config_TX_Color.Value             = [0.7882 0.2784 0.3412];
            app.config_TX_Size.Value              = 1;
            app.config_TX_DataTipVisibility.Value = 'off';
            app.config_RX_Color.Value             = [0.7882 0.2784 0.3373];
            app.config_RX_Size.Value              = 1;
            
            % % Atualiza o plot...
            app.stationInfo.UserData.idxRFDataHub = [];
            filter_TableFiltering(app)            

            app.config_Refresh.Visible = 0;

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
            app.GridLayout.ColumnWidth = {10, 320, 10, '1x', 198, 5, 10, 320, 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, 5, 176, '1x', 5, 22, 5, '1x', 10, 34};
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
            app.Toolbar.Layout.Row = 12;
            app.Toolbar.Layout.Column = [1 11];

            % Create tool_LayoutLeft
            app.tool_LayoutLeft = uiimage(app.Toolbar);
            app.tool_LayoutLeft.Layout.Row = 2;
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = 'ArrowLeft_32.png';

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
            app.tool_LayoutRight.Layout.Row = 2;
            app.tool_LayoutRight.Layout.Column = 18;
            app.tool_LayoutRight.ImageSource = 'ArrowRight_32.png';

            % Create play_TreeLabel
            app.play_TreeLabel = uilabel(app.GridLayout);
            app.play_TreeLabel.VerticalAlignment = 'bottom';
            app.play_TreeLabel.FontSize = 10;
            app.play_TreeLabel.Layout.Row = [2 3];
            app.play_TreeLabel.Layout.Column = 2;
            app.play_TreeLabel.Text = 'FLUXOS ESPECTRAIS';

            % Create play_Tree
            app.play_Tree = uitree(app.GridLayout);
            app.play_Tree.Multiselect = 'on';
            app.play_Tree.FontSize = 10;
            app.play_Tree.FontColor = [0.651 0.651 0.651];
            app.play_Tree.Layout.Row = [5 6];
            app.play_Tree.Layout.Column = 2;

            % Create play_MetadataLabel
            app.play_MetadataLabel = uilabel(app.GridLayout);
            app.play_MetadataLabel.VerticalAlignment = 'bottom';
            app.play_MetadataLabel.FontSize = 10;
            app.play_MetadataLabel.Layout.Row = 8;
            app.play_MetadataLabel.Layout.Column = 2;
            app.play_MetadataLabel.Text = 'METADADOS';

            % Create play_Metadata
            app.play_Metadata = uilabel(app.GridLayout);
            app.play_Metadata.VerticalAlignment = 'top';
            app.play_Metadata.WordWrap = 'on';
            app.play_Metadata.FontSize = 11;
            app.play_Metadata.Layout.Row = 10;
            app.play_Metadata.Layout.Column = 2;
            app.play_Metadata.Interpreter = 'html';
            app.play_Metadata.Text = '';

            % Create play_PlotPanel
            app.play_PlotPanel = uipanel(app.GridLayout);
            app.play_PlotPanel.AutoResizeChildren = 'off';
            app.play_PlotPanel.BorderType = 'none';
            app.play_PlotPanel.BackgroundColor = [0 0 0];
            app.play_PlotPanel.Layout.Row = [3 10];
            app.play_PlotPanel.Layout.Column = [4 6];

            % Create play_axesToolbar
            app.play_axesToolbar = uigridlayout(app.GridLayout);
            app.play_axesToolbar.ColumnWidth = {'1x', 22, 22, 22, 22, 22, 22, 22, 22, 22, '1x'};
            app.play_axesToolbar.RowHeight = {'1x'};
            app.play_axesToolbar.ColumnSpacing = 0;
            app.play_axesToolbar.RowSpacing = 0;
            app.play_axesToolbar.Padding = [0 2 0 2];
            app.play_axesToolbar.Layout.Row = 3;
            app.play_axesToolbar.Layout.Column = 5;
            app.play_axesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_MinHold
            app.axesTool_MinHold = uiimage(app.play_axesToolbar);
            app.axesTool_MinHold.Tag = 'MinHold';
            app.axesTool_MinHold.Tooltip = {'MinHold'};
            app.axesTool_MinHold.Layout.Row = 1;
            app.axesTool_MinHold.Layout.Column = 5;
            app.axesTool_MinHold.ImageSource = 'MinHold_32.png';

            % Create axesTool_Average
            app.axesTool_Average = uiimage(app.play_axesToolbar);
            app.axesTool_Average.Tag = 'Average';
            app.axesTool_Average.Tooltip = {'Média'};
            app.axesTool_Average.Layout.Row = 1;
            app.axesTool_Average.Layout.Column = 6;
            app.axesTool_Average.ImageSource = 'Average_32.png';

            % Create axesTool_MaxHold
            app.axesTool_MaxHold = uiimage(app.play_axesToolbar);
            app.axesTool_MaxHold.Tag = 'MaxHold';
            app.axesTool_MaxHold.Tooltip = {'MaxHold'};
            app.axesTool_MaxHold.Layout.Row = 1;
            app.axesTool_MaxHold.Layout.Column = 7;
            app.axesTool_MaxHold.ImageSource = 'MaxHold_32.png';

            % Create axesTool_Persistance
            app.axesTool_Persistance = uiimage(app.play_axesToolbar);
            app.axesTool_Persistance.Tag = 'Persistance';
            app.axesTool_Persistance.Tooltip = {'Persistência'};
            app.axesTool_Persistance.Layout.Row = 1;
            app.axesTool_Persistance.Layout.Column = 8;
            app.axesTool_Persistance.ImageSource = 'Persistance_36.png';

            % Create axesTool_Occupancy
            app.axesTool_Occupancy = uiimage(app.play_axesToolbar);
            app.axesTool_Occupancy.Tag = 'Ocuppancy';
            app.axesTool_Occupancy.Tooltip = {'Ocupação'};
            app.axesTool_Occupancy.Layout.Row = 1;
            app.axesTool_Occupancy.Layout.Column = 9;
            app.axesTool_Occupancy.ImageSource = 'Occupancy_32Gray.png';

            % Create axesTool_Waterfall
            app.axesTool_Waterfall = uiimage(app.play_axesToolbar);
            app.axesTool_Waterfall.ScaleMethod = 'none';
            app.axesTool_Waterfall.Tag = 'Waterfall';
            app.axesTool_Waterfall.Tooltip = {'Waterfall'};
            app.axesTool_Waterfall.Layout.Row = 1;
            app.axesTool_Waterfall.Layout.Column = 10;
            app.axesTool_Waterfall.HorizontalAlignment = 'left';
            app.axesTool_Waterfall.VerticalAlignment = 'bottom';
            app.axesTool_Waterfall.ImageSource = 'Waterfall_24.png';

            % Create axesTool_DataTip
            app.axesTool_DataTip = uiimage(app.play_axesToolbar);
            app.axesTool_DataTip.Enable = 'off';
            app.axesTool_DataTip.Tooltip = {'DataCursorMode'; '(restrito à Waterfall:Image)'};
            app.axesTool_DataTip.Layout.Row = 1;
            app.axesTool_DataTip.Layout.Column = 4;
            app.axesTool_DataTip.ImageSource = 'DataTip_22.png';

            % Create axesTool_Pan
            app.axesTool_Pan = uiimage(app.play_axesToolbar);
            app.axesTool_Pan.Tooltip = {'Pan'};
            app.axesTool_Pan.Layout.Row = 1;
            app.axesTool_Pan.Layout.Column = 3;
            app.axesTool_Pan.ImageSource = 'Pan_32.png';

            % Create axesTool_RestoreView_2
            app.axesTool_RestoreView_2 = uiimage(app.play_axesToolbar);
            app.axesTool_RestoreView_2.ScaleMethod = 'none';
            app.axesTool_RestoreView_2.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView_2.Layout.Row = 1;
            app.axesTool_RestoreView_2.Layout.Column = 2;
            app.axesTool_RestoreView_2.ImageSource = 'Home_18.png';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.Layout.Row = [3 10];
            app.SubTabGroup.Layout.Column = [8 9];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'PLAYBACK';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {'1x'};
            app.SubGrid1.RowHeight = {22, 174, 22, 32, 112, '1x', 200, 1, 14};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create play_GeneralPanelLabel
            app.play_GeneralPanelLabel = uilabel(app.SubGrid1);
            app.play_GeneralPanelLabel.VerticalAlignment = 'bottom';
            app.play_GeneralPanelLabel.FontSize = 10;
            app.play_GeneralPanelLabel.Layout.Row = 1;
            app.play_GeneralPanelLabel.Layout.Column = 1;
            app.play_GeneralPanelLabel.Text = 'ASPECTOS GERAIS';

            % Create play_GeneralPanel
            app.play_GeneralPanel = uipanel(app.SubGrid1);
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
            app.play_TraceIntegration.FontSize = 11;
            app.play_TraceIntegration.BackgroundColor = [1 1 1];
            app.play_TraceIntegration.Layout.Row = 2;
            app.play_TraceIntegration.Layout.Column = [4 5];
            app.play_TraceIntegration.Value = '3';

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
            app.play_LimitsRefresh.Tooltip = {'Retorna à configuração padrão'};
            app.play_LimitsRefresh.Layout.Row = 3;
            app.play_LimitsRefresh.Layout.Column = 5;
            app.play_LimitsRefresh.HorizontalAlignment = 'right';
            app.play_LimitsRefresh.VerticalAlignment = 'bottom';
            app.play_LimitsRefresh.ImageSource = 'Refresh_18.png';

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
            app.play_Limits_xLim2.Tag = 'FreqStop';
            app.play_Limits_xLim2.FontSize = 11;
            app.play_Limits_xLim2.Tooltip = {''};
            app.play_Limits_xLim2.Layout.Row = 1;
            app.play_Limits_xLim2.Layout.Column = 3;

            % Create play_Limits_yLim1
            app.play_Limits_yLim1 = uispinner(app.play_LimitsGrid);
            app.play_Limits_yLim1.Step = 5;
            app.play_Limits_yLim1.ValueDisplayFormat = '%.1f';
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
            app.play_Limits_yLim2.Tag = 'MaxLevel';
            app.play_Limits_yLim2.FontSize = 11;
            app.play_Limits_yLim2.Tooltip = {''};
            app.play_Limits_yLim2.Layout.Row = 2;
            app.play_Limits_yLim2.Layout.Column = 3;

            % Create play_ControlPanelLabel
            app.play_ControlPanelLabel = uilabel(app.SubGrid1);
            app.play_ControlPanelLabel.VerticalAlignment = 'bottom';
            app.play_ControlPanelLabel.FontSize = 10;
            app.play_ControlPanelLabel.Layout.Row = 3;
            app.play_ControlPanelLabel.Layout.Column = 1;
            app.play_ControlPanelLabel.Text = 'CONTROLES';

            % Create play_ControlsPanel
            app.play_ControlsPanel = uibuttongroup(app.SubGrid1);
            app.play_ControlsPanel.AutoResizeChildren = 'off';
            app.play_ControlsPanel.BackgroundColor = [1 1 1];
            app.play_ControlsPanel.Layout.Row = 4;
            app.play_ControlsPanel.Layout.Column = 1;
            app.play_ControlsPanel.FontWeight = 'bold';
            app.play_ControlsPanel.FontSize = 10;

            % Create play_RadioButton_Persistance
            app.play_RadioButton_Persistance = uiradiobutton(app.play_ControlsPanel);
            app.play_RadioButton_Persistance.Text = 'Persistência';
            app.play_RadioButton_Persistance.FontSize = 10.5;
            app.play_RadioButton_Persistance.Position = [11 6 79 22];
            app.play_RadioButton_Persistance.Value = true;

            % Create play_RadioButton_Occupancy
            app.play_RadioButton_Occupancy = uiradiobutton(app.play_ControlsPanel);
            app.play_RadioButton_Occupancy.Text = 'Ocupação';
            app.play_RadioButton_Occupancy.FontSize = 10.5;
            app.play_RadioButton_Occupancy.Position = [114 6 70 22];

            % Create play_RadioButton_Waterfall
            app.play_RadioButton_Waterfall = uiradiobutton(app.play_ControlsPanel);
            app.play_RadioButton_Waterfall.Text = 'Waterfall';
            app.play_RadioButton_Waterfall.FontSize = 10.5;
            app.play_RadioButton_Waterfall.Position = [216 6 83 22];

            % Create play_Persistance_Panel
            app.play_Persistance_Panel = uipanel(app.SubGrid1);
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
            app.play_Persistance_WindowSize.FontSize = 11;
            app.play_Persistance_WindowSize.BackgroundColor = [1 1 1];
            app.play_Persistance_WindowSize.Layout.Row = 2;
            app.play_Persistance_WindowSize.Layout.Column = 2;
            app.play_Persistance_WindowSize.Value = '128';

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
            app.play_Persistance_cLim_Mode.Enable = 'off';
            app.play_Persistance_cLim_Mode.Tooltip = {'Retorna à configuração padrão'};
            app.play_Persistance_cLim_Mode.Layout.Row = 3;
            app.play_Persistance_cLim_Mode.Layout.Column = 4;
            app.play_Persistance_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Persistance_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Mode.ImageSource = 'Refresh_18.png';

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
            app.play_Persistance_cLim1.FontSize = 11;
            app.play_Persistance_cLim1.Enable = 'off';
            app.play_Persistance_cLim1.Tooltip = {''};
            app.play_Persistance_cLim1.Layout.Row = 1;
            app.play_Persistance_cLim1.Layout.Column = 1;

            % Create play_Persistance_cLim2
            app.play_Persistance_cLim2 = uispinner(app.play_Persistance_cLim_Grid2);
            app.play_Persistance_cLim2.Limits = [0 Inf];
            app.play_Persistance_cLim2.ValueDisplayFormat = '%.3f';
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
            app.play_OCC_Panel = uipanel(app.SubGrid1);
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
            app.play_OCC_IntegrationTime.Tag = 'Factor';
            app.play_OCC_IntegrationTime.FontSize = 11;
            app.play_OCC_IntegrationTime.BackgroundColor = [1 1 1];
            app.play_OCC_IntegrationTime.Layout.Row = 2;
            app.play_OCC_IntegrationTime.Layout.Column = 3;
            app.play_OCC_IntegrationTime.Value = '1';

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
            app.play_OCC_THR.Tag = 'THR';
            app.play_OCC_THR.FontSize = 11;
            app.play_OCC_THR.Layout.Row = 4;
            app.play_OCC_THR.Layout.Column = 2;
            app.play_OCC_THR.Value = -80;

            % Create play_OCC_THRCaptured
            app.play_OCC_THRCaptured = uidropdown(app.play_OCCGrid);
            app.play_OCC_THRCaptured.Items = {};
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
            app.play_OCC_ceilFactor.Tag = 'Factor';
            app.play_OCC_ceilFactor.Visible = 'off';
            app.play_OCC_ceilFactor.FontSize = 11;
            app.play_OCC_ceilFactor.BackgroundColor = [1 1 1];
            app.play_OCC_ceilFactor.Layout.Row = 4;
            app.play_OCC_ceilFactor.Layout.Column = 3;
            app.play_OCC_ceilFactor.Value = '1𝜎';

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
            app.play_OCC_noiseUsefulSamples.FontSize = 11;
            app.play_OCC_noiseUsefulSamples.Layout.Row = 2;
            app.play_OCC_noiseUsefulSamples.Layout.Column = 3;
            app.play_OCC_noiseUsefulSamples.Value = 20;

            % Create play_Waterfall_Panel
            app.play_Waterfall_Panel = uipanel(app.SubGrid1);
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
            app.play_Waterfall_MeshStyle.Enable = 'off';
            app.play_Waterfall_MeshStyle.FontSize = 11;
            app.play_Waterfall_MeshStyle.BackgroundColor = [1 1 1];
            app.play_Waterfall_MeshStyle.Layout.Row = 6;
            app.play_Waterfall_MeshStyle.Layout.Column = 1;
            app.play_Waterfall_MeshStyle.Value = 'row';

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
            app.play_Waterfall_cLim_Mode.Enable = 'off';
            app.play_Waterfall_cLim_Mode.Layout.Row = 5;
            app.play_Waterfall_cLim_Mode.Layout.Column = 4;
            app.play_Waterfall_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Waterfall_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Mode.ImageSource = 'Refresh_18.png';

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
            app.play_Waterfall_cLim2.FontSize = 11;
            app.play_Waterfall_cLim2.Enable = 'off';
            app.play_Waterfall_cLim2.Tooltip = {''};
            app.play_Waterfall_cLim2.Layout.Row = 1;
            app.play_Waterfall_cLim2.Layout.Column = 3;
            app.play_Waterfall_cLim2.Value = 1;

            % Create play_Customization
            app.play_Customization = uicheckbox(app.SubGrid1);
            app.play_Customization.Text = 'Customizar controles do plot.';
            app.play_Customization.WordWrap = 'on';
            app.play_Customization.FontSize = 11;
            app.play_Customization.Layout.Row = 9;
            app.play_Customization.Layout.Column = 1;

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'CANAIS';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {'1x', 16, 16};
            app.SubGrid2.RowHeight = {22, 36, 210, 80, 8, '1x', 22, 42, 8, '0.5x'};
            app.SubGrid2.ColumnSpacing = 5;
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create play_Channel_Label
            app.play_Channel_Label = uilabel(app.SubGrid2);
            app.play_Channel_Label.VerticalAlignment = 'bottom';
            app.play_Channel_Label.FontSize = 10;
            app.play_Channel_Label.FontColor = [0.149 0.149 0.149];
            app.play_Channel_Label.Layout.Row = 1;
            app.play_Channel_Label.Layout.Column = 1;
            app.play_Channel_Label.Text = 'INCLUSÃO DE CANAIS';

            % Create play_Channel_RadioGroup
            app.play_Channel_RadioGroup = uibuttongroup(app.SubGrid2);
            app.play_Channel_RadioGroup.AutoResizeChildren = 'off';
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
            app.play_Channel_Panel = uipanel(app.SubGrid2);
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
            app.play_Channel_ListUpdate.Tooltip = {'Retorna à configuração padrão'};
            app.play_Channel_ListUpdate.Layout.Row = 1;
            app.play_Channel_ListUpdate.Layout.Column = 4;
            app.play_Channel_ListUpdate.VerticalAlignment = 'bottom';
            app.play_Channel_ListUpdate.ImageSource = 'Refresh_18.png';

            % Create play_Channel_List
            app.play_Channel_List = uidropdown(app.play_Channel_Grid);
            app.play_Channel_List.Items = {};
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
            app.play_Channel_ExternalFilePanel = uipanel(app.SubGrid2);
            app.play_Channel_ExternalFilePanel.AutoResizeChildren = 'off';
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
            app.play_Channel_FileTemplate.VerticalAlignment = 'top';
            app.play_Channel_FileTemplate.FontSize = 10;
            app.play_Channel_FileTemplate.Layout.Row = 3;
            app.play_Channel_FileTemplate.Layout.Column = 1;
            app.play_Channel_FileTemplate.Text = 'Download modelo do arquivo';

            % Create play_Channel_add
            app.play_Channel_add = uiimage(app.SubGrid2);
            app.play_Channel_add.ScaleMethod = 'scaledown';
            app.play_Channel_add.Layout.Row = 5;
            app.play_Channel_add.Layout.Column = 3;
            app.play_Channel_add.HorizontalAlignment = 'right';
            app.play_Channel_add.VerticalAlignment = 'bottom';
            app.play_Channel_add.ImageSource = 'addSymbol_32.png';

            % Create play_Channel_Tree
            app.play_Channel_Tree = uitree(app.SubGrid2);
            app.play_Channel_Tree.Multiselect = 'on';
            app.play_Channel_Tree.FontSize = 10;
            app.play_Channel_Tree.Layout.Row = 6;
            app.play_Channel_Tree.Layout.Column = [1 3];

            % Create play_BandLimits_Status
            app.play_BandLimits_Status = uicheckbox(app.SubGrid2);
            app.play_BandLimits_Status.Text = 'Limitar detecção de emissões a subfaixa(s)';
            app.play_BandLimits_Status.FontSize = 11;
            app.play_BandLimits_Status.Layout.Row = 7;
            app.play_BandLimits_Status.Layout.Column = [1 3];

            % Create play_BandLimits_Panel
            app.play_BandLimits_Panel = uipanel(app.SubGrid2);
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
            app.play_BandLimits_add = uiimage(app.SubGrid2);
            app.play_BandLimits_add.ScaleMethod = 'scaledown';
            app.play_BandLimits_add.Enable = 'off';
            app.play_BandLimits_add.Layout.Row = 9;
            app.play_BandLimits_add.Layout.Column = 3;
            app.play_BandLimits_add.HorizontalAlignment = 'right';
            app.play_BandLimits_add.VerticalAlignment = 'bottom';
            app.play_BandLimits_add.ImageSource = 'addSymbol_32.png';

            % Create play_BandLimits_Tree
            app.play_BandLimits_Tree = uitree(app.SubGrid2);
            app.play_BandLimits_Tree.Multiselect = 'on';
            app.play_BandLimits_Tree.Enable = 'off';
            app.play_BandLimits_Tree.FontSize = 10;
            app.play_BandLimits_Tree.Layout.Row = 10;
            app.play_BandLimits_Tree.Layout.Column = [1 3];

            % Create play_Channel_ShowPlot
            app.play_Channel_ShowPlot = uiimage(app.SubGrid2);
            app.play_Channel_ShowPlot.Tooltip = {'Mostra canais no plot'};
            app.play_Channel_ShowPlot.Layout.Row = 1;
            app.play_Channel_ShowPlot.Layout.Column = 3;
            app.play_Channel_ShowPlot.VerticalAlignment = 'bottom';
            app.play_Channel_ShowPlot.ImageSource = 'EyeNegative_32.png';

            % Create SubTab3
            app.SubTab3 = uitab(app.SubTabGroup);
            app.SubTab3.Title = 'EMISSÕES';

            % Create SubGrid3
            app.SubGrid3 = uigridlayout(app.SubTab3);
            app.SubGrid3.ColumnWidth = {'1x', 100, 89, 16};
            app.SubGrid3.RowHeight = {22, 36, 270, 80, 8, '1x', 22, 22, 44};
            app.SubGrid3.ColumnSpacing = 5;
            app.SubGrid3.RowSpacing = 5;
            app.SubGrid3.BackgroundColor = [1 1 1];

            % Create play_FindPeaks_Label
            app.play_FindPeaks_Label = uilabel(app.SubGrid3);
            app.play_FindPeaks_Label.VerticalAlignment = 'bottom';
            app.play_FindPeaks_Label.FontSize = 10;
            app.play_FindPeaks_Label.FontColor = [0.149 0.149 0.149];
            app.play_FindPeaks_Label.Layout.Row = 1;
            app.play_FindPeaks_Label.Layout.Column = [1 3];
            app.play_FindPeaks_Label.Text = 'DETECÇÃO DE EMISSÕES';

            % Create play_FindPeaks_RadioGroup
            app.play_FindPeaks_RadioGroup = uibuttongroup(app.SubGrid3);
            app.play_FindPeaks_RadioGroup.AutoResizeChildren = 'off';
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
            app.play_FindPeaks_ParametersPanel = uipanel(app.SubGrid3);
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
            app.play_FindPeaks_Algorithm.FontSize = 11;
            app.play_FindPeaks_Algorithm.BackgroundColor = [1 1 1];
            app.play_FindPeaks_Algorithm.Layout.Row = 2;
            app.play_FindPeaks_Algorithm.Layout.Column = [1 3];
            app.play_FindPeaks_Algorithm.Value = 'FindPeaks';

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
            app.play_FindPeaks_Trace.Value = 'MinHold';

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
            app.play_FindPeaks_maxOCC.FontSize = 11;
            app.play_FindPeaks_maxOCC.Layout.Row = 2;
            app.play_FindPeaks_maxOCC.Layout.Column = 5;
            app.play_FindPeaks_maxOCC.Value = 10;

            % Create play_FindPeaks_add
            app.play_FindPeaks_add = uiimage(app.SubGrid3);
            app.play_FindPeaks_add.ScaleMethod = 'scaledown';
            app.play_FindPeaks_add.Layout.Row = 5;
            app.play_FindPeaks_add.Layout.Column = 4;
            app.play_FindPeaks_add.HorizontalAlignment = 'right';
            app.play_FindPeaks_add.VerticalAlignment = 'bottom';
            app.play_FindPeaks_add.ImageSource = 'addSymbol_32.png';

            % Create play_FindPeaks_Tree
            app.play_FindPeaks_Tree = uitree(app.SubGrid3);
            app.play_FindPeaks_Tree.Multiselect = 'on';
            app.play_FindPeaks_Tree.FontSize = 10;
            app.play_FindPeaks_Tree.Layout.Row = 6;
            app.play_FindPeaks_Tree.Layout.Column = [1 4];

            % Create play_FindPeaks_PeakCFLabel
            app.play_FindPeaks_PeakCFLabel = uilabel(app.SubGrid3);
            app.play_FindPeaks_PeakCFLabel.FontSize = 11;
            app.play_FindPeaks_PeakCFLabel.Layout.Row = 7;
            app.play_FindPeaks_PeakCFLabel.Layout.Column = [1 2];
            app.play_FindPeaks_PeakCFLabel.Text = 'Frequência central (MHz):';

            % Create play_FindPeaks_PeakCF
            app.play_FindPeaks_PeakCF = uieditfield(app.SubGrid3, 'numeric');
            app.play_FindPeaks_PeakCF.ValueDisplayFormat = '%.3f';
            app.play_FindPeaks_PeakCF.FontSize = 11;
            app.play_FindPeaks_PeakCF.Enable = 'off';
            app.play_FindPeaks_PeakCF.Layout.Row = 7;
            app.play_FindPeaks_PeakCF.Layout.Column = [3 4];

            % Create play_FindPeaks_PeakBWLabel
            app.play_FindPeaks_PeakBWLabel = uilabel(app.SubGrid3);
            app.play_FindPeaks_PeakBWLabel.FontSize = 11;
            app.play_FindPeaks_PeakBWLabel.Layout.Row = 8;
            app.play_FindPeaks_PeakBWLabel.Layout.Column = [1 2];
            app.play_FindPeaks_PeakBWLabel.Text = 'Largura ocupada (kHz):';

            % Create play_FindPeaks_PeakBW
            app.play_FindPeaks_PeakBW = uieditfield(app.SubGrid3, 'numeric');
            app.play_FindPeaks_PeakBW.ValueDisplayFormat = '%.3f';
            app.play_FindPeaks_PeakBW.FontSize = 11;
            app.play_FindPeaks_PeakBW.Enable = 'off';
            app.play_FindPeaks_PeakBW.Layout.Row = 8;
            app.play_FindPeaks_PeakBW.Layout.Column = [3 4];

            % Create play_FindPeaks_DescriptionLabel
            app.play_FindPeaks_DescriptionLabel = uilabel(app.SubGrid3);
            app.play_FindPeaks_DescriptionLabel.VerticalAlignment = 'top';
            app.play_FindPeaks_DescriptionLabel.WordWrap = 'on';
            app.play_FindPeaks_DescriptionLabel.FontSize = 11;
            app.play_FindPeaks_DescriptionLabel.Layout.Row = 9;
            app.play_FindPeaks_DescriptionLabel.Layout.Column = 1;
            app.play_FindPeaks_DescriptionLabel.Text = {'Informações'; 'complementares:'};

            % Create play_FindPeaks_Description
            app.play_FindPeaks_Description = uitextarea(app.SubGrid3);
            app.play_FindPeaks_Description.FontSize = 11;
            app.play_FindPeaks_Description.Enable = 'off';
            app.play_FindPeaks_Description.Layout.Row = 9;
            app.play_FindPeaks_Description.Layout.Column = [2 4];

            % Create play_FindPeaks_ExternalFilePanel
            app.play_FindPeaks_ExternalFilePanel = uipanel(app.SubGrid3);
            app.play_FindPeaks_ExternalFilePanel.AutoResizeChildren = 'off';
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
            app.play_FindPeaks_FileTemplate.VerticalAlignment = 'top';
            app.play_FindPeaks_FileTemplate.FontSize = 10;
            app.play_FindPeaks_FileTemplate.Layout.Row = 3;
            app.play_FindPeaks_FileTemplate.Layout.Column = 1;
            app.play_FindPeaks_FileTemplate.Text = 'Download modelo do arquivo';

            % Create SubTab4
            app.SubTab4 = uitab(app.SubTabGroup);
            app.SubTab4.Title = 'PROJETO';

            % Create SubGrid4
            app.SubGrid4 = uigridlayout(app.SubTab4);
            app.SubGrid4.ColumnWidth = {95, '1x', 32, 16, 16, 16};
            app.SubGrid4.RowHeight = {22, 32, 22, 112, 9, 8, '1x', 22, '1x', 15, 15};
            app.SubGrid4.ColumnSpacing = 5;
            app.SubGrid4.RowSpacing = 5;
            app.SubGrid4.BackgroundColor = [1 1 1];

            % Create report_ProjectNameLabel
            app.report_ProjectNameLabel = uilabel(app.SubGrid4);
            app.report_ProjectNameLabel.VerticalAlignment = 'bottom';
            app.report_ProjectNameLabel.FontSize = 10;
            app.report_ProjectNameLabel.Layout.Row = 1;
            app.report_ProjectNameLabel.Layout.Column = 1;
            app.report_ProjectNameLabel.Text = 'ARQUIVO';

            % Create report_ProjectWarnIcon
            app.report_ProjectWarnIcon = uiimage(app.SubGrid4);
            app.report_ProjectWarnIcon.ScaleMethod = 'scaledown';
            app.report_ProjectWarnIcon.Visible = 'off';
            app.report_ProjectWarnIcon.Tooltip = {'Pendente salvar projeto'};
            app.report_ProjectWarnIcon.Layout.Row = 1;
            app.report_ProjectWarnIcon.Layout.Column = 4;
            app.report_ProjectWarnIcon.VerticalAlignment = 'bottom';
            app.report_ProjectWarnIcon.ImageSource = 'Warn_18.png';

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.SubGrid4);
            app.report_ProjectSave.Tooltip = {'Salva projeto'};
            app.report_ProjectSave.Layout.Row = 1;
            app.report_ProjectSave.Layout.Column = 5;
            app.report_ProjectSave.VerticalAlignment = 'bottom';
            app.report_ProjectSave.ImageSource = 'saveFile_32.png';

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.SubGrid4);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 1;
            app.report_ProjectNew.Layout.Column = 6;
            app.report_ProjectNew.VerticalAlignment = 'bottom';
            app.report_ProjectNew.ImageSource = 'addFiles_32.png';

            % Create report_ProjectName
            app.report_ProjectName = uitextarea(app.SubGrid4);
            app.report_ProjectName.Tag = 'file';
            app.report_ProjectName.Editable = 'off';
            app.report_ProjectName.FontSize = 11;
            app.report_ProjectName.Layout.Row = 2;
            app.report_ProjectName.Layout.Column = [1 6];

            % Create report_DocumentPanelLabel
            app.report_DocumentPanelLabel = uilabel(app.SubGrid4);
            app.report_DocumentPanelLabel.VerticalAlignment = 'bottom';
            app.report_DocumentPanelLabel.FontSize = 10;
            app.report_DocumentPanelLabel.Layout.Row = 3;
            app.report_DocumentPanelLabel.Layout.Column = [1 6];
            app.report_DocumentPanelLabel.Text = 'ATIVIDADE DE INSPEÇÃO';

            % Create report_DocumentPanel
            app.report_DocumentPanel = uipanel(app.SubGrid4);
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
            app.report_AddProjectAttachment.Tooltip = {'Edita lista de arquivos externos '; 'relacionados ao projeto'};
            app.report_AddProjectAttachment.Layout.Row = 3;
            app.report_AddProjectAttachment.Layout.Column = 3;
            app.report_AddProjectAttachment.VerticalAlignment = 'bottom';
            app.report_AddProjectAttachment.ImageSource = 'attach_32.png';

            % Create report_ModelName
            app.report_ModelName = uidropdown(app.report_DocumentGrid);
            app.report_ModelName.Items = {};
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
            app.report_Version.FontSize = 11;
            app.report_Version.BackgroundColor = [1 1 1];
            app.report_Version.Layout.Row = 4;
            app.report_Version.Layout.Column = 4;
            app.report_Version.Value = 'Preliminar';

            % Create report_TreeLabel
            app.report_TreeLabel = uilabel(app.SubGrid4);
            app.report_TreeLabel.VerticalAlignment = 'bottom';
            app.report_TreeLabel.FontSize = 10;
            app.report_TreeLabel.Layout.Row = [5 6];
            app.report_TreeLabel.Layout.Column = [1 2];
            app.report_TreeLabel.Text = 'FLUXOS A PROCESSAR';

            % Create report_TreeAddImage
            app.report_TreeAddImage = uiimage(app.SubGrid4);
            app.report_TreeAddImage.Tooltip = {''};
            app.report_TreeAddImage.Layout.Row = 6;
            app.report_TreeAddImage.Layout.Column = 6;
            app.report_TreeAddImage.VerticalAlignment = 'bottom';
            app.report_TreeAddImage.ImageSource = 'addSymbol_32.png';

            % Create report_Tree
            app.report_Tree = uitree(app.SubGrid4);
            app.report_Tree.Multiselect = 'on';
            app.report_Tree.FontSize = 10;
            app.report_Tree.Layout.Row = 7;
            app.report_Tree.Layout.Column = [1 6];

            % Create report_ThreadAlgorithmsLabel
            app.report_ThreadAlgorithmsLabel = uilabel(app.SubGrid4);
            app.report_ThreadAlgorithmsLabel.VerticalAlignment = 'bottom';
            app.report_ThreadAlgorithmsLabel.FontSize = 10;
            app.report_ThreadAlgorithmsLabel.Layout.Row = 8;
            app.report_ThreadAlgorithmsLabel.Layout.Column = [1 2];
            app.report_ThreadAlgorithmsLabel.Text = 'ALGORITMOS';

            % Create report_ThreadAlgorithmsImage
            app.report_ThreadAlgorithmsImage = uiimage(app.SubGrid4);
            app.report_ThreadAlgorithmsImage.ScaleMethod = 'none';
            app.report_ThreadAlgorithmsImage.Layout.Row = 9;
            app.report_ThreadAlgorithmsImage.Layout.Column = [1 6];
            app.report_ThreadAlgorithmsImage.ImageSource = 'warning.svg';

            % Create report_ThreadAlgorithms
            app.report_ThreadAlgorithms = uilabel(app.SubGrid4);
            app.report_ThreadAlgorithms.VerticalAlignment = 'top';
            app.report_ThreadAlgorithms.WordWrap = 'on';
            app.report_ThreadAlgorithms.FontSize = 11;
            app.report_ThreadAlgorithms.Layout.Row = 9;
            app.report_ThreadAlgorithms.Layout.Column = [1 6];
            app.report_ThreadAlgorithms.Interpreter = 'html';
            app.report_ThreadAlgorithms.Text = '';

            % Create report_EditDetection
            app.report_EditDetection = uihyperlink(app.SubGrid4);
            app.report_EditDetection.VisitedColor = [0 0.4 0.8];
            app.report_EditDetection.VerticalAlignment = 'top';
            app.report_EditDetection.FontSize = 10;
            app.report_EditDetection.FontColor = [0 0.4 0.8];
            app.report_EditDetection.Enable = 'off';
            app.report_EditDetection.Layout.Row = 10;
            app.report_EditDetection.Layout.Column = 1;
            app.report_EditDetection.Text = 'DETECÇÃO';

            % Create report_EditClassification
            app.report_EditClassification = uihyperlink(app.SubGrid4);
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
            app.report_DetectionManualMode = uicheckbox(app.SubGrid4);
            app.report_DetectionManualMode.Enable = 'off';
            app.report_DetectionManualMode.Text = 'Restringir detecção de emissões ao PLAYBACK.';
            app.report_DetectionManualMode.WordWrap = 'on';
            app.report_DetectionManualMode.FontSize = 11;
            app.report_DetectionManualMode.Layout.Row = 11;
            app.report_DetectionManualMode.Layout.Column = [1 6];

            % Create SubTab5
            app.SubTab5 = uitab(app.SubTabGroup);
            app.SubTab5.Title = 'MISCELÂNEAS';

            % Create SubGrid5
            app.SubGrid5 = uigridlayout(app.SubTab5);
            app.SubGrid5.ColumnWidth = {'1x'};
            app.SubGrid5.RowHeight = {22, '1x'};
            app.SubGrid5.ColumnSpacing = 5;
            app.SubGrid5.RowSpacing = 5;
            app.SubGrid5.BackgroundColor = [1 1 1];

            % Create misc_Label1
            app.misc_Label1 = uilabel(app.SubGrid5);
            app.misc_Label1.VerticalAlignment = 'bottom';
            app.misc_Label1.FontSize = 10;
            app.misc_Label1.Layout.Row = 1;
            app.misc_Label1.Layout.Column = 1;
            app.misc_Label1.Text = 'OPERAÇÃO';

            % Create misc_Panel1
            app.misc_Panel1 = uipanel(app.SubGrid5);
            app.misc_Panel1.AutoResizeChildren = 'off';
            app.misc_Panel1.Layout.Row = 2;
            app.misc_Panel1.Layout.Column = 1;

            % Create misc_Grid1
            app.misc_Grid1 = uigridlayout(app.misc_Panel1);
            app.misc_Grid1.ColumnWidth = {3, 28, 3, 3, 28, 3, 3, 28, 3, 3, 28, 3, 3, 3, 28, 3, 3, 28, 3};
            app.misc_Grid1.RowHeight = {1, 34, 26, 1, 34, 26, 1, 34, 26, '1x', 34, 26};
            app.misc_Grid1.ColumnSpacing = 5;
            app.misc_Grid1.RowSpacing = 5;
            app.misc_Grid1.Padding = [10 10 10 5];
            app.misc_Grid1.BackgroundColor = [1 1 1];

            % Create misc_Save
            app.misc_Save = uibutton(app.misc_Grid1, 'push');
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
            app.misc_Serarator.ImageSource = 'LineV.png';

            % Create misc_Export
            app.misc_Export = uibutton(app.misc_Grid1, 'push');
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
            app.misc_TimeFilteringLabel.Text = 'Filtro temporal';

            % Create misc_LevelFiltering
            app.misc_LevelFiltering = uibutton(app.misc_Grid1, 'push');
            app.misc_LevelFiltering.Icon = 'clear_breakpoints_16.png';
            app.misc_LevelFiltering.BackgroundColor = [1 1 1];
            app.misc_LevelFiltering.Tooltip = {''};
            app.misc_LevelFiltering.Layout.Row = 5;
            app.misc_LevelFiltering.Layout.Column = 5;
            app.misc_LevelFiltering.Text = '';

            % Create misc_LevelFilteringLabel
            app.misc_LevelFilteringLabel = uilabel(app.misc_Grid1);
            app.misc_LevelFilteringLabel.HorizontalAlignment = 'center';
            app.misc_LevelFilteringLabel.WordWrap = 'on';
            app.misc_LevelFilteringLabel.FontSize = 10;
            app.misc_LevelFilteringLabel.Layout.Row = 6;
            app.misc_LevelFilteringLabel.Layout.Column = [4 6];
            app.misc_LevelFilteringLabel.Text = {'Filtro'; 'nível'};

            % Create misc_EditLocation
            app.misc_EditLocation = uibutton(app.misc_Grid1, 'push');
            app.misc_EditLocation.Icon = 'Pin_32.png';
            app.misc_EditLocation.BackgroundColor = [1 1 1];
            app.misc_EditLocation.Tooltip = {''};
            app.misc_EditLocation.Layout.Row = 5;
            app.misc_EditLocation.Layout.Column = 8;
            app.misc_EditLocation.Text = '';

            % Create misc_EditLocationLabel
            app.misc_EditLocationLabel = uilabel(app.misc_Grid1);
            app.misc_EditLocationLabel.HorizontalAlignment = 'center';
            app.misc_EditLocationLabel.WordWrap = 'on';
            app.misc_EditLocationLabel.FontSize = 10;
            app.misc_EditLocationLabel.Layout.Row = 6;
            app.misc_EditLocationLabel.Layout.Column = [7 9];
            app.misc_EditLocationLabel.Text = {'Editar'; 'Local'};

            % Create misc_AddCorrection
            app.misc_AddCorrection = uibutton(app.misc_Grid1, 'push');
            app.misc_AddCorrection.Icon = 'RFFilter_32.png';
            app.misc_AddCorrection.BackgroundColor = [1 1 1];
            app.misc_AddCorrection.Tooltip = {''};
            app.misc_AddCorrection.Layout.Row = 5;
            app.misc_AddCorrection.Layout.Column = 11;
            app.misc_AddCorrection.Text = '';

            % Create misc_AddCorrectionLabel
            app.misc_AddCorrectionLabel = uilabel(app.misc_Grid1);
            app.misc_AddCorrectionLabel.HorizontalAlignment = 'center';
            app.misc_AddCorrectionLabel.WordWrap = 'on';
            app.misc_AddCorrectionLabel.FontSize = 10;
            app.misc_AddCorrectionLabel.Layout.Row = 6;
            app.misc_AddCorrectionLabel.Layout.Column = [10 12];
            app.misc_AddCorrectionLabel.Text = {'Aplicar'; 'correção'};

            % Create misc_DeleteAll
            app.misc_DeleteAll = uibutton(app.misc_Grid1, 'push');
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

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [9 10];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

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
