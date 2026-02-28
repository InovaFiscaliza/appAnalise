classdef winPlayback_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        DockModule                     matlab.ui.container.GridLayout
        dockModule_Close               matlab.ui.control.Image
        dockModule_Undock              matlab.ui.control.Image
        Document                       matlab.ui.container.GridLayout
        RightPanel                     matlab.ui.container.GridLayout
        WaterfallPanel                 matlab.ui.container.Panel
        WaterfallPanelGrid             matlab.ui.container.GridLayout
        WaterfallCLim2                 matlab.ui.control.Spinner
        WaterfallCLim1                 matlab.ui.control.Spinner
        WaterfallCLimRefresh           matlab.ui.control.Image
        WaterfallCLimLabel             matlab.ui.control.Label
        WaterfallMeshStyle             matlab.ui.control.DropDown
        WaterfallMeshStyleLabel        matlab.ui.control.Label
        WaterfallColormap              matlab.ui.control.DropDown
        WaterfallColormapLabel         matlab.ui.control.Label
        WaterfallDecimation            matlab.ui.control.DropDown
        WaterfallDecimationValue       matlab.ui.control.Label
        WaterfallDecimationLabel       matlab.ui.control.Label
        WaterfallFcn                   matlab.ui.control.DropDown
        WaterfallFcnLabel              matlab.ui.control.Label
        WaterfallPanelLabel            matlab.ui.control.Label
        WaterfallPanelIcon             matlab.ui.control.Image
        PersistencePanel               matlab.ui.container.Panel
        PersistencePanelGrid           matlab.ui.container.GridLayout
        PersistenceCLim2               matlab.ui.control.Spinner
        PersistenceCLim1               matlab.ui.control.Spinner
        PersistenceCLimRefresh         matlab.ui.control.Image
        PersistenceCLim_Label          matlab.ui.control.Label
        PersistenceTransparency        matlab.ui.control.Spinner
        PersistenceTransparencyLabel   matlab.ui.control.Label
        PersistenceColormap            matlab.ui.control.DropDown
        PersistenceColormapLabel       matlab.ui.control.Label
        PersistenceWindowSize          matlab.ui.control.DropDown
        PersistenceWindowSizeValue     matlab.ui.control.Label
        PersistenceWindowSizeLabel     matlab.ui.control.Label
        PersistenceInterpolation       matlab.ui.control.DropDown
        PersistenceInterpolationLabel  matlab.ui.control.Label
        PersistencePanelLabel          matlab.ui.control.Label
        PersistencePanelIcon           matlab.ui.control.Image
        GeneralPanel                   matlab.ui.container.Panel
        GeneralPanelGrid               matlab.ui.container.GridLayout
        LimitsYLim2                    matlab.ui.control.Spinner
        LimitsYLim1                    matlab.ui.control.Spinner
        LimitsYLimLabel                matlab.ui.control.Label
        LimitsXLim2                    matlab.ui.control.Spinner
        LimitsXLim1                    matlab.ui.control.Spinner
        LimitsXLimLabel                matlab.ui.control.Label
        LimitsRefresh                  matlab.ui.control.Image
        LimitsPanelLabel               matlab.ui.control.Label
        LayoutRatio                    matlab.ui.control.DropDown
        LayoutRatioLabel               matlab.ui.control.Label
        GeneralPanelLabel              matlab.ui.control.Label
        GeneralPanelIcon               matlab.ui.control.Image
        LeftPanel                      matlab.ui.container.GridLayout
        FlowPanel                      matlab.ui.container.Panel
        FlowPanelGrid                  matlab.ui.container.GridLayout
        FlowAnalysis                   matlab.ui.control.Label
        FlowEmissions                  matlab.ui.container.Tree
        FlowEmissionsBtn2              matlab.ui.control.Image
        FlowEmissionsBtn1              matlab.ui.control.Image
        FlowEmissionsLabel             matlab.ui.control.Label
        FlowChannel                    matlab.ui.control.ListBox
        FlowChannelBtn                 matlab.ui.control.Image
        FlowChannelLabel               matlab.ui.control.Label
        FlowDetection                  matlab.ui.control.Label
        FlowDetectionBtn               matlab.ui.control.Image
        FlowDetectionLabel             matlab.ui.control.Label
        FlowOccupancy                  matlab.ui.control.Label
        FlowOccupancyBtn               matlab.ui.control.Image
        FlowOccupancyLabel             matlab.ui.control.Label
        FlowMetadata                   matlab.ui.control.Label
        FlowAttributesPanelRightBtn    matlab.ui.control.Image
        FlowAttributesPanelLeftBtn     matlab.ui.control.Image
        FlowAttributesPanelVisibleIdx  matlab.ui.control.Label
        FlowPanelLabel                 matlab.ui.control.Label
        SpectrumFlowList               matlab.ui.control.DropDown
        AxesAnnotation                 matlab.ui.control.Label
        AxesToolbar                    matlab.ui.container.GridLayout
        axesTool_waterfall             matlab.ui.control.Image
        axesTool_occupancy             matlab.ui.control.Image
        axesTool_persistence           matlab.ui.control.Image
        axesTool_maxHold               matlab.ui.control.Image
        axesTool_average               matlab.ui.control.Image
        axesTool_minHold               matlab.ui.control.Image
        axesTool_DataTip               matlab.ui.control.Image
        axesTool_Pan                   matlab.ui.control.Image
        axesTool_RestoreView           matlab.ui.control.Image
        AxesContainer                  matlab.ui.container.Panel
        Toolbar                        matlab.ui.container.GridLayout
        tool_OpenPopupProject          matlab.ui.control.Image
        tool_LayoutRight               matlab.ui.control.Image
        tool_UploadFinalFile           matlab.ui.control.Image
        tool_GenerateReport            matlab.ui.control.Image
        tool_TimestampLabel            matlab.ui.control.Label
        tool_TimestampSlider           matlab.ui.control.Slider
        tool_LoopControl               matlab.ui.control.Image
        tool_Play                      matlab.ui.control.Image
        tool_LayoutLeft                matlab.ui.control.Image
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

        plotHandles
        sweepTimeIndex

        bandObj
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
                        app.SpectrumFlowList;
                        app.FlowPanelLabel;
                        app.FlowMetadata;
                        app.FlowOccupancy;
                        app.FlowDetection;
                        app.FlowAnalysis;
                        app.tool_LayoutLeft;
                        app.tool_Play;
                        app.tool_LoopControl;
                        app.tool_OpenPopupProject;
                        app.tool_GenerateReport;
                        app.tool_UploadFinalFile;
                        app.tool_LayoutRight;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SpectrumFlowList.UserData.id, 'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', 'rgba(183, 49, 44, 0.75)'), ...
                            struct('appName', appName, 'dataTag', app.FlowPanelLabel.UserData.id, 'styleImportant', struct('borderLeft', '3px solid #b7312c', 'paddingLeft', '8px')), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutLeft.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel')), ...
                            struct('appName', appName, 'dataTag', app.tool_Play.UserData.id,             'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla execução do playback da monitoração')), ...
                            struct('appName', appName, 'dataTag', app.tool_LoopControl.UserData.id,      'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla loop da execução do playback')), ...
                            struct('appName', appName, 'dataTag', app.tool_OpenPopupProject.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Edita informações do projeto<br>(fiscalizada, arquivo de backup etc)')), ...
                            struct('appName', appName, 'dataTag', app.tool_GenerateReport.UserData.id,   'tooltip', struct('defaultPosition', 'top',    'textContent', 'Gera relatório')), ...
                            struct('appName', appName, 'dataTag', app.tool_UploadFinalFile.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Upload relatório')), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutRight.UserData.id,      'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à direita')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,     'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,      'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.FlowMetadata,   appName, struct('class', 'textview--borderless'));
                        ui.TextView.startup(app.jsBackDoor, app.FlowOccupancy, appName);
                        ui.TextView.startup(app.jsBackDoor, app.FlowDetection, appName);
                        ui.TextView.startup(app.jsBackDoor, app.FlowAnalysis,       appName, struct('class', 'textview--borderless'));
                    catch
                    end
                    
                    addStyle(app.SpectrumFlowList, uistyle('Interpreter', 'html'))

                    app.FlowAttributesPanelVisibleIdx.UserData.index = 1;
                    app.axesTool_Pan.UserData.status = false;
                    app.axesTool_DataTip.UserData.status = false;
                    app.axesTool_minHold.UserData = struct('status', false, 'imageSource', {{'MinHold_32Filled.png', 'MinHold_32.png'}});
                    app.axesTool_average.UserData = struct('status', false, 'imageSource', {{'Average_32Filled.png', 'Average_32.png'}});
                    app.axesTool_maxHold.UserData = struct('status', false, 'imageSource', {{'MaxHold_32Filled.png', 'MaxHold_32.png'}});
                    app.axesTool_persistence.UserData.status = false;
                    app.axesTool_occupancy.UserData.status = false;
                    app.axesTool_waterfall.UserData.status = false;

                otherwise
                     % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.bandObj = class.Band('appAnalise:PLAYBACK', app);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            startup_Axes(app)

            % ...
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            if ~isempty(app.mainApp.specData)
                util.layoutDropDownTreeStyle(app.SpectrumFlowList, app.mainApp.specData)
                updateAttributesPanel(app)
            end
        end
    end


    methods (Access = public) % Mudar para private - não feito ainda porque draw2D.ClearWrite_old chama play_EmissionList
        %-----------------------------------------------------------------%
        function idx = findSpecDataIndex(app)
            idx = app.SpectrumFlowList.Value;
            if ~isempty(idx) && ~isnumeric(idx)
                [~, idx] = ismember(app.SpectrumFlowList.Value, app.SpectrumFlowList.Items);
            end
        end
        
        %-----------------------------------------------------------------%
        % ## PAINÉIS ##
        %-----------------------------------------------------------------%
        function updateAttributesPanel(app)
            idx = findSpecDataIndex(app);
            
            app.FlowMetadata.Text = util.HtmlTextGenerator.ThreadMetaData(app.mainApp.specData(idx));
            app.FlowAnalysis.Text = util.HtmlTextGenerator.ThreadAnalysis(app.mainApp.specData(idx));

            plot_startupFcn(app, idx)
            plot_Draw(app, idx)
        end

        %-----------------------------------------------------------------%
        % ## PLOT ##
        %-----------------------------------------------------------------%
        function startup_Axes(app)
            hParent = tiledlayout(app.AxesContainer, 4, 1, "Padding", "compact", "TileSpacing", "compact");

            app.UIAxes1 = plot.axes.Creation(hParent, 'Cartesian', {'TitleHorizontalAlignment', 'right', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2 1];
            
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'YScale', app.mainApp.General.plot.cartesianAxes.yOccupancyScale});
            app.UIAxes2.Layout.Tile = 3;
            
            app.UIAxes3 = plot.axes.Creation(hParent, 'Cartesian', {'Layer', 'top', 'Box', 'on', 'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes3.Layout.Tile = 4;            

            % Axes colormap:
            plot.axes.Colormap(app.UIAxes1, app.PersistenceColormap.Value)
            plot.axes.Colormap(app.UIAxes3, app.WaterfallColormap.Value)

            % Axes colorbar:
            plot.axes.Colorbar(app.UIAxes3, app.mainApp.General.plot.waterfall.Colorbar)

            % Axes fixed labels:
            ylabel(app.UIAxes1, 'Nível (dB)')
            set(app.UIAxes1.Title, Visible='on', FontSize=10, FontWeight='normal', HorizontalAlignment='right', Color=[.8,.8,.8])

            ylabel(app.UIAxes2, 'Ocupação (%)')
            xlabel(app.UIAxes3, 'Frequência (MHz)')
            ylabel(app.UIAxes3, 'Instante')
            plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
            plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)

            % Axes listeners:
            linkaxes([app.UIAxes1, app.UIAxes2, app.UIAxes3], 'x')
            addlistener(app.UIAxes1, 'XLim', 'PostSet', @app.plot_AxesLimitsChanged);
            addlistener(app.UIAxes1, 'YLim', 'PostSet', @app.plot_AxesLimitsChanged);

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation([app.UIAxes1, app.UIAxes2], [dataTipInteraction, regionZoomInteraction, rulerPanInteraction])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes3,                [dataTipInteraction, regionZoomInteraction])
            
        end

        %-----------------------------------------------------------------%
        function plot_startupFcn(app, idx)
            % O objeto app.bandObj armazena propriedades de app.mainApp.specData(idx) 
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

            % Painel "PLAYBACK > CANAIS >> INCLUSÃO DE CANAIS"
            play_Channel_TreeBuilding(app, idx)

            % Painel "PLAYBACK >> EMISSÕES"
            play_EmissionList(app, idx, 1)
        end

        %-----------------------------------------------------------------%
        function prePlot_restartProperties(app, axesLimits)
            cla([app.UIAxes1, app.UIAxes2, app.UIAxes3])

            app.UIAxes1.UserData.CLimMode = 'auto';
            app.UIAxes3.UserData.CLimMode = 'auto';

            app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yLevelLim, 'cLim', 'auto');
            app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', axesLimits.xLim, 'yLim', [0, 100],             'cLim', 'auto');
            app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yTimeLim,  'cLim', axesLimits.cLim);

            app.plotHandles = struct( ...
                'clearWrite', [], ...
                'minHold', [], ...
                'average', [], ...
                'maxHold', [], ...
                'persistence', [], ...
                'selectedEmission', [], ...
                'emissionMarkers', [], ...
                'thresholdLine', [], ...
                'thresholdLabel', [], ...
                'waterfall', [], ...
                'waterfallTime', [] ...
            );
    
            app.sweepTimeIndex = 1;
            app.tool_TimestampSlider.Value = 0;
        end

        %-----------------------------------------------------------------%
        function prePlot_checkNSweepsAndDataType(app, idx)
            if app.bandObj.nSweeps > 2                
                app.axesTool_persistence.Enable = 1;
                app.axesTool_waterfall.Enable   = 1;

                if ~ismember(app.mainApp.specData(idx).MetaData.DataType, class.Constants.occDataTypes)
                    app.axesTool_occupancy.Enable = 1;
                else
                    app.axesTool_occupancy.Enable = 0;
                    app.axesTool_occupancy.UserData.status = false;
                    
                    plot.old_OCC(app, idx, 'Delete', [])                    % !! PONTO DE REVISÃO !!
                end
            else                
                app.axesTool_persistence.Enable = 0;
                app.axesTool_persistence.UserData.status = false;

                app.axesTool_waterfall.Enable   = 0;
                app.axesTool_waterfall.UserData.status = false;

                app.axesTool_occupancy.Enable   = 0;
                app.axesTool_occupancy.UserData.status = false;

                plot.old_OCC(app, idx, 'Delete', [])                        % !! PONTO DE REVISÃO !!           
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_HTMLPanels(app, idx)
            app.tool_TimestampLabel.Text = sprintf('1 de %d\n%s', app.bandObj.nSweeps, app.mainApp.specData(idx).Data{1}(1));
            app.AxesAnnotation.Text = sprintf('%s \n%.3f - %.3f MHz ', app.mainApp.specData(idx).Receiver, app.bandObj.FreqStart, app.bandObj.FreqStop);
        end

        %-----------------------------------------------------------------%
        function prePlot_customPlayback(app, idx)
            % Em relação à customização do PLAYBACK,
            % (a) Até a v. 1.67, o appAnalise possibilitava a customização de onze parâmetros
            %     do PLAYBACK. Desde a v. 1.80, o app aumentou esse número para vinte
            %     (praticamente todos!). Além disso, os nomes dos parâmetros foram compactados, 
            %     o que demandou ajuste no leitor .MAT, mantendo a compatibilidade com os .MAT
            %     gerado em versões anteriores do app.
            
            % (b) A atualização do componente app.LayoutRatio deve ser posterior
            %     à atualização dos componentes app.play_Occupancy e app.play_Waterfall.
            
            % (c) A atualização dos limites dos eixos x e y é realizada automaticamente,
            %     seguindo os limites do eixos app.axes1.
            %     addlistener(app.axes1, 'XLim', 'PostSet', @app.plot_xLimitsUpdate);
            %     addlistener(app.axes1, 'YLim', 'PostSet', @app.plot_yLimitsUpdate);

            switch app.mainApp.specData(idx).UserData.customPlayback.Type
                case 'auto'
                    % ...

                case 'manual'
                    iconDictionary = dictionary([true, false], [1, 2]);
                    if ~isequal(app.axesTool_minHold.UserData, app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.MinHold)
                        app.axesTool_minHold.UserData.status  = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.MinHold;
                        app.axesTool_minHold.ImageSource      = app.axesTool_minHold.UserData.imageSource{iconDictionary(app.axesTool_minHold.UserData.status)};
                    end

                    if ~isequal(app.axesTool_average.UserData, app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.Average)
                        app.axesTool_average.UserData.status  = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.Average;
                        app.axesTool_average.ImageSource      = app.axesTool_average.UserData.imageSource{iconDictionary(app.axesTool_average.UserData.status)};
                    end

                    if ~isequal(app.axesTool_maxHold.UserData, app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.MaxHold)
                        app.axesTool_maxHold.UserData.status  = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.MaxHold;
                        app.axesTool_maxHold.ImageSource      = app.axesTool_maxHold.UserData.imageSource{iconDictionary(app.axesTool_maxHold.UserData.status)};
                    end

                    app.axesTool_persistence.UserData.status  = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.Persistance;
                    app.axesTool_occupancy.UserData.status    = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.Occupancy;
                    app.axesTool_waterfall.UserData.status    = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.Waterfall;
        
                    app.LayoutRatio.Items                = {app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.LayoutRatio};
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)
                    
                    app.PersistenceInterpolation.Value  = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.Interpolation;
                    app.PersistenceWindowSize.Value     = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.WindowSize;
                    app.PersistenceWindowSizeValue.Text = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.WindowSize;
                    app.PersistenceTransparency.Value   = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.Transparency;
                    app.PersistenceColormap.Value       = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.Colormap;
        
                    if app.PersistenceWindowSize.Value == "full"
                        app.PersistenceCLim1.Value      = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.LevelLimits(1);
                        app.PersistenceCLim2.Value      = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.LevelLimits(2);
                    end

                    % A visibilidade e posição da Colobar não é tratada como 
                    % customização do playback... e por isso o componente
                    % específico não é atualizado com a informação presente
                    % em app.mainApp.specData.
                    app.WaterfallFcn.Value              = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.Fcn;
                    app.WaterfallDecimation.Value       = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.Decimation;
                    app.WaterfallMeshStyle.Value        = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.MeshStyle;            
                    app.WaterfallColormap.Value         = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.Colormap;
                    app.WaterfallCLim1.Value            = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.LevelLimits(1);
                    app.WaterfallCLim2.Value            = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.LevelLimits(2);
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_updatingGeneralSettings(app)
            % app.General_I
            % (a) Persistance
            app.mainApp.General_I.plot.persistence = struct( ...
                'Interpolation', app.PersistenceInterpolation.Value, ...
                'WindowSize', app.PersistenceWindowSize.Value, ...
                'Transparency', app.PersistenceTransparency.Value, ...
                'Colormap', app.PersistenceColormap.Value, ...
                'LevelLimits', [app.PersistenceCLim1.Value, app.PersistenceCLim2.Value] ...
            );

            if app.axesTool_persistence.UserData.status && strcmp(app.UIAxes1.UserData.CLimMode, 'auto')
                app.mainApp.General_I.plot.persistence.LevelLimits = [0, 1];
            end

            % (b) Waterfall
            app.mainApp.General_I.plot.waterfall.Fcn = app.WaterfallFcn.Value;
            app.mainApp.General_I.plot.waterfall.Decimation = app.WaterfallDecimation.Value;
            app.mainApp.General_I.plot.waterfall.MeshStyle = app.WaterfallMeshStyle.Value;
            app.mainApp.General_I.plot.waterfall.Colormap = app.WaterfallColormap.Value;
            app.mainApp.General_I.plot.waterfall.LevelLimits = [app.WaterfallCLim1.Value, app.WaterfallCLim2.Value];

            if app.axesTool_waterfall.UserData.status && strcmp(app.UIAxes3.UserData.CLimMode, 'auto')
                app.mainApp.General_I.plot.waterfall.LevelLimits = [0, 1];
            end
            
            % app.mainApp.General
            app.mainApp.General.plot.persistence = app.mainApp.General_I.plot.persistence;
            app.mainApp.General.plot.waterfall   = app.mainApp.General_I.plot.waterfall;
        end

        %-----------------------------------------------------------------%
        function play_Channel_TreeBuilding(app, idx)
            channelLibIndex = app.mainApp.specData(idx).UserData.channelLibIndex;
            if isempty(channelLibIndex)
                app.FlowChannel.Items = {};
            else
                app.FlowChannel.Items = arrayfun(@(x) sprintf('%.3f - %.3f MHz', x.Band(1), x.Band(2), x.Name), app.mainApp.channelObj.Channel, 'UniformOutput', false);
            end
        end

        %-----------------------------------------------------------------%
        function play_EmissionList(app, idx, selectedEmission)
            if ~isempty(app.FlowEmissions.Children)
                delete(app.FlowEmissions.Children)
            end

            if ~isempty(app.mainApp.specData(idx).UserData.Emissions)
                emissionTable = app.mainApp.specData(idx).UserData.Emissions;

                for ii = 1:height(emissionTable)
                    if emissionTable.isTruncated(ii)
                        iconFileName = 'signalTruncated_32.png';
                    else
                        iconFileName = 'signalUntruncated_32.png';
                    end

                    if isempty(emissionTable.auxAppData(ii).DriveTest)
                        driveTestReportFlag = '';
                    else
                        driveTestReportFlag = ' (DT)';
                    end

                    uitreenode(app.FlowEmissions, 'Text', sprintf('%d: %.3f MHz ⌂ %.1f kHz%s', ii, emissionTable.Frequency(ii), emissionTable.BW_kHz(ii), driveTestReportFlag), ...
                                                  'NodeData', ii, 'Icon', iconFileName);
                end

                app.FlowEmissions.SelectedNodes = app.FlowEmissions.Children(selectedEmission);
            end

            FlowEmissionsSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function plot_Draw(app, idx)
            % No processo de inicialização do PLOT, que ocorre toda vez que é
            % alterado o fluxo espectral selecionado, na árvore principal do
            % appAnalise, os eixos são limpos e os handles dos principais
            % componentes do plot são apagados. app.hClearWrite vazio significa 
            % que deverá ser desenhado um novo PLOT. Por outro lado, caso não 
            % seja vazio, então o PLOT deverá ser atualizado.
        
            if isempty(app.plotHandles.clearWrite)
                % Essa configuração aqui dispara o trigger de alteração de
                % 'XLim' e 'YLim', executando o callback
                % @(src,evt)plot_AxesLimitsChanged(app,src,evt)
                set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
                ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))
        
                % (a) ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["clearWrite", "minHold", "average", "maxHold"]
                    if ismember(plotTag, {'minHold', 'average', 'maxHold'}) && ~eval(sprintf('app.axesTool_%s.UserData.status', plotTag))
                        continue
                    end
        
                    eval(sprintf('app.plotHandles.("%s") = plot.draw2D.OrdinaryLine(app.UIAxes1, app.bandObj, idx, "%s");', plotTag, plotTag))
                    plot.datatip.Template(eval(sprintf('app.plotHandles.("%s")', plotTag)), "Frequency+Level", app.bandObj.LevelUnit)
                end
                
                % (b) Persistance
                if app.axesTool_persistence.UserData.status
                    plot_Draw_Persistance(app, 'Creation', idx)
                end

                % Emissões
                plot.draw2D.ClearWrite_old(app, idx, 'InitialPlot', 1)

                % BandLimits & Channels
                plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'bandLimits')
                plot_Draw_Channels(app, idx)
        
                % Occupancy
                if app.axesTool_occupancy.UserData.status
                    occIndex = play_OCCIndex(app, idx, 'PLAYBACK');
                    plot.old_OCC(app, idx, 'Creation', occIndex)
                end
        
                % Waterfall
                if app.axesTool_waterfall.UserData.status
                    plot_Draw_Waterfall(app, idx)
                end
        
                % customPlayback >> DataTips
                if ~isempty(app.mainApp.specData(idx).UserData.customPlayback.Parameters)
                    dtConfig = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Datatip;
                    dtParent = [app.UIAxes1, app.UIAxes2, app.UIAxes3];
                    plot.datatip.Create('customPlayback', dtConfig, dtParent)
                end
        
            else
                % ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["clearWrite", "minHold", "average", "maxHold"]
                    if ismember(plotTag, {'MinHold', 'Average', 'MaxHold'})
                        if ~eval(sprintf('app.axesTool_%s.UserData.status', plotTag)) || isinf(app.mainApp.General.context.PLAYBACK.integration.traceMode)
                            continue
                        end
                    end
        
                    eval(sprintf('plot.draw2D.OrdinaryLineUpdate(app.plotHandles.("%s"), app.bandObj, idx, plotTag);', plotTag))
                end
        
                for ii = 1:numel(app.plotHandles.emissionMarkers)
                    app.plotHandles.emissionMarkers(ii).Position(2) = app.plotHandles.clearWrite.YData(app.plotHandles.clearWrite.MarkerIndices(ii));
                end
        
                % Persistance
                plot_Draw_Persistance(app, 'Update', idx)

                % WaterfallTime
                if app.axesTool_waterfall.UserData.status && ~isempty(app.plotHandles.waterfallTime) && strcmp(app.play_Waterfall_Timeline.Value, 'on')
                    plot.draw2D.OrdinaryLineUpdate(app.plotHandles.waterfallTime, app.bandObj, idx, 'WaterfallTime');
                end
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function plot_Draw_Persistance(app, operationType, idx)
            switch operationType
                case 'Creation'
                    [app.plotHandles.persistence, app.PersistenceWindowSizeValue.Text] = plot.Persistance('Creation', app.plotHandles.persistence, app.UIAxes1, app.bandObj, idx);
                    play_Layout_PersistancePanel(app)

                case 'Update'
                    if app.axesTool_persistence.UserData.status && ~strcmp(app.PersistenceWindowSizeValue.Text, 'full')
                        app.plotHandles.persistence = plot.Persistance('Update', app.plotHandles.persistence, app.UIAxes1, app.bandObj, idx);
                        play_Layout_PersistancePanel(app)
                    end

                case 'Delete'
                    app.plotHandles.persistence = plot.Persistance('Delete', app.plotHandles.persistence);
            end
        end

        %-----------------------------------------------------------------%
        function plot_Draw_Waterfall(app, idx)
            prePlot_updatingGeneralSettings(app)
            prePlot_updatingCustomProperties(app, idx)

            [app.plotHandles.waterfall, app.WaterfallDecimationValue.Text] = plot.Waterfall('Creation', app.UIAxes3, app.bandObj, idx);
            plot.axes.Layout.YLabel(app.plotHandles.waterfall, app.axesTool_waterfall.UserData.status)
            play_Layout_WaterfallPanel(app)

            % DataCursorMode
            % O DataCursorMode é, de forma geral, uma interação ruim p/ eixos
            % cartesianos por bloquear as outras (Pan, regionZoom etc). Por
            % essa razão, restringir o DataCursorMode apenas ao eixo específico
            % em que está sendo plotado a imagem (que não suporta a interação 
            % padrão de DataTip).
            switch app.WaterfallFcn.Value
                case 'image'
                    app.axesTool_DataTip.Enable = 1;
                case 'mesh'
                    app.axesTool_DataTip.Enable = 0;
                    if app.axesTool_DataTip.UserData.status
                        play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_DataTip))
                    end
            end

            % Timeline
            if strcmp(app.play_Waterfall_Timeline.Value, 'on')
                app.plotHandles.waterfallTime = plot.draw2D.OrdinaryLine(app.UIAxes3, app.bandObj, idx, 'WaterfallTime');
            end
        end

        %-----------------------------------------------------------------%
        function plot_Draw_Channels(app, idx)
            delete(findobj(app.UIAxes1, 'Tag', 'Channel'))

            % if ~isempty(app.play_Channel_Tree.SelectedNodes) && app.play_Channel_ShowPlot.UserData
            %     chTable = table('Size',          [0, 6],                                                                      ...
            %                     'VariableNames', {'Name', 'FirstChannel', 'ChannelBW', 'Reference', 'FreqStart', 'FreqStop'}, ...
            %                     'VariableTypes', {'cell', 'double', 'double', 'cell', 'double', 'double'});
            % 
            %     for ii = 1:numel(app.play_Channel_Tree.SelectedNodes)
            %         srcChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.src;
            %         idxChannel = app.play_Channel_Tree.SelectedNodes(ii).NodeData.idx;
            % 
            %         switch srcChannel
            %             case 'channelLib'
            %                 srcRawTable = app.channelObj.Channel(idxChannel);
            %             case 'manual'
            %                 srcRawTable = app.mainApp.specData(idx).UserData.channelManual(idxChannel);
            %         end
            % 
            %         chTable = PreparingData2Plot(app.channelObj, chTable, srcRawTable);
            %     end
            % 
            %     if ~isempty(chTable)
            %         plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'Channel', chTable) 
            %     end
            % end
        end
        
        %-----------------------------------------------------------------%
        function plot_AxesLimitsChanged(app, src, evt)
            switch src.Name
                case 'XLim'
                    app.LimitsXLim1.Value = round(evt.AffectedObject.XLim(1), 3);
                    app.LimitsXLim2.Value = round(evt.AffectedObject.XLim(2), 3);

                case 'YLim'
                    app.LimitsYLim1.Value = round(double(evt.AffectedObject.YLim(1)), 1);
                    app.LimitsYLim2.Value = round(double(evt.AffectedObject.YLim(2)), 1);
            end
        end

        %-----------------------------------------------------------------%
        function [idx, nSweeps] = plot_updateIndex(app)
            % Os valores do índice e do número de varredura se referem ao
            % novo fluxo espectral selecionado, e não àquele que estava
            % sendo apresentado.
            idx = app.play_Tree.SelectedNodes.NodeData;
            idx = idx(1);
            nSweeps = numel(app.mainApp.specData(idx).Data{1});
            
            plot_startupFcn(app, idx)
            plot_Draw(app, idx)

            app.plotFlag = 1;
        end     
        
        %-----------------------------------------------------------------%
        function plot_deleteLines(app, Tag)
            eval(sprintf('delete(app.plotHandles.("%s"))', Tag));
            eval(sprintf('app.plotHandles.("%s") = [];', Tag));
        end

        %-----------------------------------------------------------------%
        function plot_mainLoop(app, idx, nSweeps)
            app.tool_Play.ImageSource = 'stop_32.png';                

            while app.sweepTimeIndex <= nSweeps
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
                app.tool_TimestampLabel.Text   = sprintf('%d de %d\n%s', app.sweepTimeIndex, nSweeps, app.mainApp.specData(idx).Data{1}(app.sweepTimeIndex));
                app.tool_TimestampSlider.Value = round(100 * app.sweepTimeIndex/nSweeps, 1);
                
                pause(max(app.play_MinPlotTime.Value/1000-toc(sweepTic), .001))
                
                % Reload Flag
                if app.sweepTimeIndex == nSweeps
                    if app.tool_LoopControl.Tag == "loop"
                        app.sweepTimeIndex = 1;
                    else
                        break
                    end
                else
                    app.sweepTimeIndex = app.sweepTimeIndex+1;
                end                
            end

            app.tool_Play.ImageSource = 'play_32.png';
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
                        app.tool_LayoutLeft.ImageSource     = 'layout-sidebar-left-off.svg';
                        app.Document.ColumnWidth(1:2)       = {0,0};
                    else
                        app.tool_LayoutLeft.ImageSource     = 'layout-sidebar-left.svg';
                        app.Document.ColumnWidth(1:2)       = {320,10};
                    end

                case app.tool_LayoutRight
                    if app.Document.ColumnWidth{end}
                        app.tool_LayoutRight.ImageSource    = 'layout-sidebar-right-off.svg';
                        app.Document.ColumnWidth(end-1:end) = {0,0};
                    else
                        app.tool_LayoutRight.ImageSource    = 'layout-sidebar-right.svg';
                        app.Document.ColumnWidth(end-1:end) = {10,232};
                    end
            end

        end

        % Value changed function: SpectrumFlowList
        function onSpectrumFlowListValueChanged(app, event)

            updateAttributesPanel(app)
            
        end

        % Image clicked function: FlowAttributesPanelLeftBtn, 
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

            currentIndex = app.FlowAttributesPanelVisibleIdx.UserData.index;
            
            switch event.Source
                case app.FlowAttributesPanelLeftBtn
                    step = -1;
                case app.FlowAttributesPanelRightBtn
                    step = 1;
            end

            currentIndex = mod(currentIndex - 1 + step, numPanels) + 1;
            
            app.FlowAttributesPanelLeftBtn.Enable  = panelBtnStatus(currentIndex, 1);
            app.FlowAttributesPanelRightBtn.Enable = panelBtnStatus(currentIndex, 2);
            app.FlowAttributesPanelVisibleIdx.Text   = sprintf('%d/%d', currentIndex, numPanels);
            app.FlowPanelGrid.ColumnWidth    = columnWidths{currentIndex};
            app.FlowPanelLabel.Text     = replace(app.FlowPanelLabel.Text, extractBetween(app.FlowPanelLabel.Text, '<i>', '</i>'), panelSubtitles{currentIndex});
            app.FlowAttributesPanelVisibleIdx.UserData.index = currentIndex;

        end

        % Selection changed function: FlowEmissions
        function FlowEmissionsSelectionChanged(app, event)
            selectedNodes = app.FlowEmissions.SelectedNodes;
            
        end

        % Image clicked function: axesTool_DataTip, axesTool_Pan, 
        % ...and 7 other components
        function onAxesToolbarButtonClicked(app, event)
            
            idx = findSpecDataIndex(app);

            switch event.Source
                case app.axesTool_RestoreView
                    plot.axes.Interactivity.CustomRestoreViewFcn(app.UIAxes1, [app.UIAxes2, app.UIAxes3], app)

                case app.axesTool_Pan
                    app.axesTool_Pan.UserData.status = ~app.axesTool_Pan.UserData.status;
                    if app.axesTool_Pan.UserData.status
                        app.axesTool_Pan.ImageSource = 'Pan_32Filled.png';
                        if app.axesTool_DataTip.UserData
                            play_AxesToolbarCallbacks(app, struct('Source', app.axesTool_DataTip))
                        end
                    else
                        app.axesTool_Pan.ImageSource = 'Pan_32.png';
                    end

                    plot.axes.Interactivity.CustomPanFcn(struct('Value', app.axesTool_Pan.UserData.status), app.UIAxes1, [app.UIAxes2, app.UIAxes3]);

                case app.axesTool_DataTip
                    app.axesTool_DataTip.UserData.status = ~app.axesTool_DataTip.UserData.status;
                    if app.axesTool_DataTip.UserData.status
                        app.axesTool_DataTip.ImageSource = 'DataTip_22Filled.png';
                    else
                        app.axesTool_DataTip.ImageSource = 'DataTip_22.png';
                    end

                    plot.axes.Interactivity.DataCursorMode(app.UIAxes3, app.axesTool_DataTip.UserData.status)

                case {app.axesTool_minHold, app.axesTool_average, app.axesTool_maxHold}
                    event.Source.UserData.status = ~event.Source.UserData.status;
                    if event.Source.UserData.status
                        event.Source.ImageSource = event.Source.UserData.ImageSource{1};

                        hObject = plot.draw2D.OrdinaryLine(app.UIAxes1, app.bandObj, idx, event.Source.Tag);
                        plot.datatip.Template(hObject, 'Frequency+Level', app.bandObj.LevelUnit)
                        plot.axes.StackingOrder.execute(app.UIAxes1, app.bandObj.Context)
            
                        eval(sprintf('app.h%s = hObject;', event.Source.Tag));

                    else
                        event.Source.ImageSource = event.Source.UserData.ImageSource{2};
                        plot_deleteLines(app, event.Source.Tag)
                    end

                case app.axesTool_persistence
                    app.axesTool_persistence.UserData.status = ~app.axesTool_persistence.UserData.status;
                    if app.axesTool_persistence.UserData.status
                        prePlot_updatingGeneralSettings(app)
                        prePlot_updatingCustomProperties(app, idx)
                        plot_Draw_Persistance(app, 'Creation', idx)
                    else
                        plot_Draw_Persistance(app, 'Delete', -1)
                    end

                case app.axesTool_occupancy
                    app.axesTool_occupancy.UserData.status = ~app.axesTool_occupancy.UserData.status;
                    if app.axesTool_occupancy.UserData.status
                        occIndex = play_OCCIndex(app, idx, 'PLAYBACK/REPORT');
                        plot.old_OCC(app, idx, 'Creation', occIndex)
                    else
                        plot.old_OCC(app, idx, 'Delete', -1)
                    end
                    play_OCCLayoutVisibility(app, app.bandObj.LevelUnit)

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.play_LayoutRatio)

                case app.axesTool_waterfall
                    app.axesTool_waterfall.UserData.status = ~app.axesTool_waterfall.UserData.status;
                    if app.axesTool_waterfall.UserData.status
                        if isempty(app.plotHandles.waterfall)
                            plot_Draw_Waterfall(app, idx)
                        else
                            play_Layout_WaterfallPanel(app)
                        end
                    else
                        play_Layout_WaterfallPanel(app)
                    end                    

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.play_LayoutRatio)
            end
            drawnow

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
            app.tool_LayoutLeft.Layout.Row = [1 3];
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Play
            app.tool_Play = uiimage(app.Toolbar);
            app.tool_Play.Layout.Row = [1 3];
            app.tool_Play.Layout.Column = 2;
            app.tool_Play.ImageSource = 'play_32.png';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.Layout.Row = [1 3];
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

            % Create tool_GenerateReport
            app.tool_GenerateReport = uiimage(app.Toolbar);
            app.tool_GenerateReport.ScaleMethod = 'none';
            app.tool_GenerateReport.Layout.Row = [1 3];
            app.tool_GenerateReport.Layout.Column = 16;
            app.tool_GenerateReport.ImageSource = 'Publish_HTML_16.png';

            % Create tool_UploadFinalFile
            app.tool_UploadFinalFile = uiimage(app.Toolbar);
            app.tool_UploadFinalFile.ScaleMethod = 'none';
            app.tool_UploadFinalFile.Layout.Row = [1 3];
            app.tool_UploadFinalFile.Layout.Column = 17;
            app.tool_UploadFinalFile.ImageSource = 'up-20px.png';

            % Create tool_LayoutRight
            app.tool_LayoutRight = uiimage(app.Toolbar);
            app.tool_LayoutRight.ScaleMethod = 'none';
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @tool_LayoutLeftImageClicked, true);
            app.tool_LayoutRight.Layout.Row = [1 3];
            app.tool_LayoutRight.Layout.Column = 18;
            app.tool_LayoutRight.ImageSource = 'layout-sidebar-right.svg';

            % Create tool_OpenPopupProject
            app.tool_OpenPopupProject = uiimage(app.Toolbar);
            app.tool_OpenPopupProject.ScaleMethod = 'none';
            app.tool_OpenPopupProject.Layout.Row = [1 3];
            app.tool_OpenPopupProject.Layout.Column = 15;
            app.tool_OpenPopupProject.ImageSource = 'organization-20px-black.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {320, 10, 5, 198, '1x', 5, 10, 232};
            app.Document.RowHeight = {24, 12, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [2 3];
            app.Document.BackgroundColor = [1 1 1];

            % Create AxesContainer
            app.AxesContainer = uipanel(app.Document);
            app.AxesContainer.AutoResizeChildren = 'off';
            app.AxesContainer.BorderType = 'none';
            app.AxesContainer.BackgroundColor = [0 0 0];
            app.AxesContainer.Layout.Row = [1 3];
            app.AxesContainer.Layout.Column = [3 6];

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

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_Pan
            app.axesTool_Pan = uiimage(app.AxesToolbar);
            app.axesTool_Pan.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_Pan.Layout.Row = 1;
            app.axesTool_Pan.Layout.Column = 3;
            app.axesTool_Pan.ImageSource = 'Pan_32.png';

            % Create axesTool_DataTip
            app.axesTool_DataTip = uiimage(app.AxesToolbar);
            app.axesTool_DataTip.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_DataTip.Enable = 'off';
            app.axesTool_DataTip.Layout.Row = 1;
            app.axesTool_DataTip.Layout.Column = 4;
            app.axesTool_DataTip.ImageSource = 'DataTip_22.png';

            % Create axesTool_minHold
            app.axesTool_minHold = uiimage(app.AxesToolbar);
            app.axesTool_minHold.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_minHold.Tag = 'minHold';
            app.axesTool_minHold.Layout.Row = 1;
            app.axesTool_minHold.Layout.Column = 5;
            app.axesTool_minHold.ImageSource = 'MinHold_32.png';

            % Create axesTool_average
            app.axesTool_average = uiimage(app.AxesToolbar);
            app.axesTool_average.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_average.Tag = 'average';
            app.axesTool_average.Layout.Row = 1;
            app.axesTool_average.Layout.Column = 6;
            app.axesTool_average.ImageSource = 'Average_32.png';

            % Create axesTool_maxHold
            app.axesTool_maxHold = uiimage(app.AxesToolbar);
            app.axesTool_maxHold.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_maxHold.Tag = 'maxHold';
            app.axesTool_maxHold.Layout.Row = 1;
            app.axesTool_maxHold.Layout.Column = 7;
            app.axesTool_maxHold.ImageSource = 'MaxHold_32.png';

            % Create axesTool_persistence
            app.axesTool_persistence = uiimage(app.AxesToolbar);
            app.axesTool_persistence.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_persistence.Layout.Row = 1;
            app.axesTool_persistence.Layout.Column = 8;
            app.axesTool_persistence.ImageSource = 'Persistance_36.png';

            % Create axesTool_occupancy
            app.axesTool_occupancy = uiimage(app.AxesToolbar);
            app.axesTool_occupancy.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_occupancy.Layout.Row = 1;
            app.axesTool_occupancy.Layout.Column = 9;
            app.axesTool_occupancy.ImageSource = 'Occupancy_32Gray.png';

            % Create axesTool_waterfall
            app.axesTool_waterfall = uiimage(app.AxesToolbar);
            app.axesTool_waterfall.ScaleMethod = 'none';
            app.axesTool_waterfall.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_waterfall.Layout.Row = 1;
            app.axesTool_waterfall.Layout.Column = 10;
            app.axesTool_waterfall.ImageSource = 'Waterfall_24.png';

            % Create AxesAnnotation
            app.AxesAnnotation = uilabel(app.Document);
            app.AxesAnnotation.HorizontalAlignment = 'right';
            app.AxesAnnotation.FontSize = 10;
            app.AxesAnnotation.FontColor = [0.8 0.8 0.8];
            app.AxesAnnotation.Layout.Row = [1 2];
            app.AxesAnnotation.Layout.Column = 5;
            app.AxesAnnotation.Text = '';

            % Create LeftPanel
            app.LeftPanel = uigridlayout(app.Document);
            app.LeftPanel.ColumnWidth = {'1x', 18, 10, 18};
            app.LeftPanel.RowHeight = {44, 30, '1x'};
            app.LeftPanel.ColumnSpacing = 5;
            app.LeftPanel.RowSpacing = 5;
            app.LeftPanel.Padding = [0 0 0 0];
            app.LeftPanel.Layout.Row = [1 3];
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.BackgroundColor = [1 1 1];

            % Create SpectrumFlowList
            app.SpectrumFlowList = uidropdown(app.LeftPanel);
            app.SpectrumFlowList.Items = {};
            app.SpectrumFlowList.ValueChangedFcn = createCallbackFcn(app, @onSpectrumFlowListValueChanged, true);
            app.SpectrumFlowList.FontSize = 11;
            app.SpectrumFlowList.FontColor = [1 1 1];
            app.SpectrumFlowList.BackgroundColor = [0.7176 0.1922 0.1725];
            app.SpectrumFlowList.Layout.Row = 1;
            app.SpectrumFlowList.Layout.Column = [1 4];
            app.SpectrumFlowList.Value = {};

            % Create FlowPanelLabel
            app.FlowPanelLabel = uilabel(app.LeftPanel);
            app.FlowPanelLabel.FontSize = 10;
            app.FlowPanelLabel.Layout.Row = 2;
            app.FlowPanelLabel.Layout.Column = 1;
            app.FlowPanelLabel.Interpreter = 'html';
            app.FlowPanelLabel.Text = 'ATRIBUTOS DO FLUXO ESPECTRAL<br><font style="font-size: 11px;"><i>Metadados</i></font>';

            % Create FlowAttributesPanelVisibleIdx
            app.FlowAttributesPanelVisibleIdx = uilabel(app.LeftPanel);
            app.FlowAttributesPanelVisibleIdx.HorizontalAlignment = 'center';
            app.FlowAttributesPanelVisibleIdx.FontSize = 10;
            app.FlowAttributesPanelVisibleIdx.FontColor = [0.502 0.502 0.502];
            app.FlowAttributesPanelVisibleIdx.Layout.Row = 2;
            app.FlowAttributesPanelVisibleIdx.Layout.Column = [2 4];
            app.FlowAttributesPanelVisibleIdx.Text = '1/4';

            % Create FlowAttributesPanelLeftBtn
            app.FlowAttributesPanelLeftBtn = uiimage(app.LeftPanel);
            app.FlowAttributesPanelLeftBtn.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.FlowAttributesPanelLeftBtn.Enable = 'off';
            app.FlowAttributesPanelLeftBtn.Layout.Row = 2;
            app.FlowAttributesPanelLeftBtn.Layout.Column = 2;
            app.FlowAttributesPanelLeftBtn.ImageSource = 'triangle-left.svg';

            % Create FlowAttributesPanelRightBtn
            app.FlowAttributesPanelRightBtn = uiimage(app.LeftPanel);
            app.FlowAttributesPanelRightBtn.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.FlowAttributesPanelRightBtn.Layout.Row = 2;
            app.FlowAttributesPanelRightBtn.Layout.Column = 4;
            app.FlowAttributesPanelRightBtn.ImageSource = 'triangle-right.svg';

            % Create FlowPanel
            app.FlowPanel = uipanel(app.LeftPanel);
            app.FlowPanel.AutoResizeChildren = 'off';
            app.FlowPanel.Layout.Row = 3;
            app.FlowPanel.Layout.Column = [1 4];

            % Create FlowPanelGrid
            app.FlowPanelGrid = uigridlayout(app.FlowPanel);
            app.FlowPanelGrid.ColumnWidth = {'1x', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            app.FlowPanelGrid.RowHeight = {5, 22, 5, '1x', 22, 5, '1x', '1x', 10};
            app.FlowPanelGrid.ColumnSpacing = 0;
            app.FlowPanelGrid.RowSpacing = 0;
            app.FlowPanelGrid.Padding = [0 0 0 0];
            app.FlowPanelGrid.BackgroundColor = [1 1 1];

            % Create FlowMetadata
            app.FlowMetadata = uilabel(app.FlowPanelGrid);
            app.FlowMetadata.VerticalAlignment = 'top';
            app.FlowMetadata.WordWrap = 'on';
            app.FlowMetadata.FontSize = 11;
            app.FlowMetadata.Layout.Row = [2 8];
            app.FlowMetadata.Layout.Column = 1;
            app.FlowMetadata.Interpreter = 'html';
            app.FlowMetadata.Text = '';

            % Create FlowOccupancyLabel
            app.FlowOccupancyLabel = uilabel(app.FlowPanelGrid);
            app.FlowOccupancyLabel.VerticalAlignment = 'bottom';
            app.FlowOccupancyLabel.FontSize = 10;
            app.FlowOccupancyLabel.Layout.Row = 2;
            app.FlowOccupancyLabel.Layout.Column = 3;
            app.FlowOccupancyLabel.Text = 'OCUPAÇÃO:';

            % Create FlowOccupancyBtn
            app.FlowOccupancyBtn = uiimage(app.FlowPanelGrid);
            app.FlowOccupancyBtn.Layout.Row = 2;
            app.FlowOccupancyBtn.Layout.Column = 4;
            app.FlowOccupancyBtn.VerticalAlignment = 'bottom';
            app.FlowOccupancyBtn.ImageSource = 'Edit_32.png';

            % Create FlowOccupancy
            app.FlowOccupancy = uilabel(app.FlowPanelGrid);
            app.FlowOccupancy.VerticalAlignment = 'top';
            app.FlowOccupancy.WordWrap = 'on';
            app.FlowOccupancy.FontSize = 11;
            app.FlowOccupancy.Layout.Row = 4;
            app.FlowOccupancy.Layout.Column = [3 4];
            app.FlowOccupancy.Interpreter = 'html';
            app.FlowOccupancy.Text = {'<p style="margin: 5px; word-break: normal;">Ocupação: deijdeijddie jdeijdiejjdji'; 'Detecção assistida: deokdekodkoe dedeokkodeo'; 'Detecção automática: dejidejiejide jidejidejieji'; 'Classificação: deojidejedji dedeijdejiijde</p>'};

            % Create FlowDetectionLabel
            app.FlowDetectionLabel = uilabel(app.FlowPanelGrid);
            app.FlowDetectionLabel.VerticalAlignment = 'bottom';
            app.FlowDetectionLabel.FontSize = 10;
            app.FlowDetectionLabel.Layout.Row = 5;
            app.FlowDetectionLabel.Layout.Column = 3;
            app.FlowDetectionLabel.Text = 'DETECÇÃO E CLASSIFICAÇÃO DE EMISSÕES:';

            % Create FlowDetectionBtn
            app.FlowDetectionBtn = uiimage(app.FlowPanelGrid);
            app.FlowDetectionBtn.Layout.Row = 5;
            app.FlowDetectionBtn.Layout.Column = 4;
            app.FlowDetectionBtn.VerticalAlignment = 'bottom';
            app.FlowDetectionBtn.ImageSource = 'Edit_32.png';

            % Create FlowDetection
            app.FlowDetection = uilabel(app.FlowPanelGrid);
            app.FlowDetection.VerticalAlignment = 'top';
            app.FlowDetection.WordWrap = 'on';
            app.FlowDetection.FontSize = 11;
            app.FlowDetection.Layout.Row = [7 8];
            app.FlowDetection.Layout.Column = [3 4];
            app.FlowDetection.Interpreter = 'html';
            app.FlowDetection.Text = 'METADADOS';

            % Create FlowChannelLabel
            app.FlowChannelLabel = uilabel(app.FlowPanelGrid);
            app.FlowChannelLabel.VerticalAlignment = 'bottom';
            app.FlowChannelLabel.FontSize = 10;
            app.FlowChannelLabel.Layout.Row = 2;
            app.FlowChannelLabel.Layout.Column = 6;
            app.FlowChannelLabel.Text = 'CANALIZAÇÃO:';

            % Create FlowChannelBtn
            app.FlowChannelBtn = uiimage(app.FlowPanelGrid);
            app.FlowChannelBtn.Layout.Row = 2;
            app.FlowChannelBtn.Layout.Column = 9;
            app.FlowChannelBtn.VerticalAlignment = 'bottom';
            app.FlowChannelBtn.ImageSource = 'Edit_32.png';

            % Create FlowChannel
            app.FlowChannel = uilistbox(app.FlowPanelGrid);
            app.FlowChannel.Items = {};
            app.FlowChannel.FontSize = 11;
            app.FlowChannel.Layout.Row = 4;
            app.FlowChannel.Layout.Column = [6 10];
            app.FlowChannel.Value = {};

            % Create FlowEmissionsLabel
            app.FlowEmissionsLabel = uilabel(app.FlowPanelGrid);
            app.FlowEmissionsLabel.VerticalAlignment = 'bottom';
            app.FlowEmissionsLabel.FontSize = 10;
            app.FlowEmissionsLabel.Layout.Row = 5;
            app.FlowEmissionsLabel.Layout.Column = 6;
            app.FlowEmissionsLabel.Text = 'LISTA DE EMISSÕES:';

            % Create FlowEmissionsBtn1
            app.FlowEmissionsBtn1 = uiimage(app.FlowPanelGrid);
            app.FlowEmissionsBtn1.ScaleMethod = 'none';
            app.FlowEmissionsBtn1.Layout.Row = 5;
            app.FlowEmissionsBtn1.Layout.Column = 7;
            app.FlowEmissionsBtn1.VerticalAlignment = 'bottom';
            app.FlowEmissionsBtn1.ImageSource = 'search-sparkle.svg';

            % Create FlowEmissionsBtn2
            app.FlowEmissionsBtn2 = uiimage(app.FlowPanelGrid);
            app.FlowEmissionsBtn2.Layout.Row = 5;
            app.FlowEmissionsBtn2.Layout.Column = 9;
            app.FlowEmissionsBtn2.VerticalAlignment = 'bottom';
            app.FlowEmissionsBtn2.ImageSource = 'Edit_32.png';

            % Create FlowEmissions
            app.FlowEmissions = uitree(app.FlowPanelGrid);
            app.FlowEmissions.SelectionChangedFcn = createCallbackFcn(app, @FlowEmissionsSelectionChanged, true);
            app.FlowEmissions.FontSize = 11;
            app.FlowEmissions.Layout.Row = [7 8];
            app.FlowEmissions.Layout.Column = [6 9];

            % Create FlowAnalysis
            app.FlowAnalysis = uilabel(app.FlowPanelGrid);
            app.FlowAnalysis.VerticalAlignment = 'top';
            app.FlowAnalysis.WordWrap = 'on';
            app.FlowAnalysis.FontSize = 11;
            app.FlowAnalysis.Layout.Row = [2 8];
            app.FlowAnalysis.Layout.Column = 11;
            app.FlowAnalysis.Interpreter = 'html';
            app.FlowAnalysis.Text = '';

            % Create RightPanel
            app.RightPanel = uigridlayout(app.Document);
            app.RightPanel.ColumnWidth = {18, '1x'};
            app.RightPanel.RowHeight = {5, 17, 5, 124, 5, 5, 17, 5, 168, 5, 5, 17, 5, '1x'};
            app.RightPanel.ColumnSpacing = 5;
            app.RightPanel.RowSpacing = 0;
            app.RightPanel.Padding = [0 0 0 0];
            app.RightPanel.Layout.Row = [1 3];
            app.RightPanel.Layout.Column = 8;
            app.RightPanel.BackgroundColor = [1 1 1];

            % Create GeneralPanelIcon
            app.GeneralPanelIcon = uiimage(app.RightPanel);
            app.GeneralPanelIcon.Layout.Row = [1 2];
            app.GeneralPanelIcon.Layout.Column = 1;
            app.GeneralPanelIcon.ImageSource = 'DriveTestDensity_32.png';

            % Create GeneralPanelLabel
            app.GeneralPanelLabel = uilabel(app.RightPanel);
            app.GeneralPanelLabel.FontSize = 10;
            app.GeneralPanelLabel.Layout.Row = 2;
            app.GeneralPanelLabel.Layout.Column = 2;
            app.GeneralPanelLabel.Text = 'EIXOS GRÁFICOS';

            % Create GeneralPanel
            app.GeneralPanel = uipanel(app.RightPanel);
            app.GeneralPanel.AutoResizeChildren = 'off';
            app.GeneralPanel.BackgroundColor = [1 1 1];
            app.GeneralPanel.Layout.Row = 4;
            app.GeneralPanel.Layout.Column = [1 2];

            % Create GeneralPanelGrid
            app.GeneralPanelGrid = uigridlayout(app.GeneralPanel);
            app.GeneralPanelGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.GeneralPanelGrid.RowHeight = {22, 20, 22, 22};
            app.GeneralPanelGrid.RowSpacing = 5;
            app.GeneralPanelGrid.BackgroundColor = [1 1 1];

            % Create LayoutRatioLabel
            app.LayoutRatioLabel = uilabel(app.GeneralPanelGrid);
            app.LayoutRatioLabel.FontSize = 11;
            app.LayoutRatioLabel.Layout.Row = 1;
            app.LayoutRatioLabel.Layout.Column = [1 3];
            app.LayoutRatioLabel.Text = 'Razão de aspecto:';

            % Create LayoutRatio
            app.LayoutRatio = uidropdown(app.GeneralPanelGrid);
            app.LayoutRatio.Items = {'1:0:0'};
            app.LayoutRatio.FontSize = 11;
            app.LayoutRatio.BackgroundColor = [1 1 1];
            app.LayoutRatio.Layout.Row = 1;
            app.LayoutRatio.Layout.Column = [4 5];
            app.LayoutRatio.Value = '1:0:0';

            % Create LimitsPanelLabel
            app.LimitsPanelLabel = uilabel(app.GeneralPanelGrid);
            app.LimitsPanelLabel.VerticalAlignment = 'bottom';
            app.LimitsPanelLabel.FontSize = 11;
            app.LimitsPanelLabel.Layout.Row = 2;
            app.LimitsPanelLabel.Layout.Column = [1 4];
            app.LimitsPanelLabel.Text = 'Limites de frequência e nível:';

            % Create LimitsRefresh
            app.LimitsRefresh = uiimage(app.GeneralPanelGrid);
            app.LimitsRefresh.ScaleMethod = 'none';
            app.LimitsRefresh.Enable = 'off';
            app.LimitsRefresh.Layout.Row = 2;
            app.LimitsRefresh.Layout.Column = 5;
            app.LimitsRefresh.ImageSource = 'Refresh_18.png';

            % Create LimitsXLimLabel
            app.LimitsXLimLabel = uilabel(app.GeneralPanelGrid);
            app.LimitsXLimLabel.HorizontalAlignment = 'center';
            app.LimitsXLimLabel.FontSize = 10;
            app.LimitsXLimLabel.Layout.Row = 3;
            app.LimitsXLimLabel.Layout.Column = [1 5];
            app.LimitsXLimLabel.Text = 'MHz  ';

            % Create LimitsXLim1
            app.LimitsXLim1 = uispinner(app.GeneralPanelGrid);
            app.LimitsXLim1.ValueDisplayFormat = '%.3f';
            app.LimitsXLim1.FontSize = 11;
            app.LimitsXLim1.Layout.Row = 3;
            app.LimitsXLim1.Layout.Column = 1;

            % Create LimitsXLim2
            app.LimitsXLim2 = uispinner(app.GeneralPanelGrid);
            app.LimitsXLim2.ValueDisplayFormat = '%.3f';
            app.LimitsXLim2.FontSize = 11;
            app.LimitsXLim2.Layout.Row = 3;
            app.LimitsXLim2.Layout.Column = [4 5];

            % Create LimitsYLimLabel
            app.LimitsYLimLabel = uilabel(app.GeneralPanelGrid);
            app.LimitsYLimLabel.HorizontalAlignment = 'center';
            app.LimitsYLimLabel.FontSize = 10;
            app.LimitsYLimLabel.Layout.Row = 4;
            app.LimitsYLimLabel.Layout.Column = [1 5];
            app.LimitsYLimLabel.Text = 'dB  ';

            % Create LimitsYLim1
            app.LimitsYLim1 = uispinner(app.GeneralPanelGrid);
            app.LimitsYLim1.Step = 5;
            app.LimitsYLim1.ValueDisplayFormat = '%.1f';
            app.LimitsYLim1.FontSize = 11;
            app.LimitsYLim1.Layout.Row = 4;
            app.LimitsYLim1.Layout.Column = 1;

            % Create LimitsYLim2
            app.LimitsYLim2 = uispinner(app.GeneralPanelGrid);
            app.LimitsYLim2.Step = 5;
            app.LimitsYLim2.ValueDisplayFormat = '%.1f';
            app.LimitsYLim2.FontSize = 11;
            app.LimitsYLim2.Layout.Row = 4;
            app.LimitsYLim2.Layout.Column = [4 5];

            % Create PersistencePanelIcon
            app.PersistencePanelIcon = uiimage(app.RightPanel);
            app.PersistencePanelIcon.Layout.Row = [6 7];
            app.PersistencePanelIcon.Layout.Column = 1;
            app.PersistencePanelIcon.VerticalAlignment = 'bottom';
            app.PersistencePanelIcon.ImageSource = 'Persistance_36.png';

            % Create PersistencePanelLabel
            app.PersistencePanelLabel = uilabel(app.RightPanel);
            app.PersistencePanelLabel.FontSize = 10;
            app.PersistencePanelLabel.Layout.Row = 7;
            app.PersistencePanelLabel.Layout.Column = 2;
            app.PersistencePanelLabel.Text = 'PERSISTÊNCIA';

            % Create PersistencePanel
            app.PersistencePanel = uipanel(app.RightPanel);
            app.PersistencePanel.AutoResizeChildren = 'off';
            app.PersistencePanel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.PersistencePanel.Layout.Row = 9;
            app.PersistencePanel.Layout.Column = [1 2];

            % Create PersistencePanelGrid
            app.PersistencePanelGrid = uigridlayout(app.PersistencePanel);
            app.PersistencePanelGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.PersistencePanelGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.PersistencePanelGrid.RowSpacing = 5;
            app.PersistencePanelGrid.Padding = [10 10 10 5];
            app.PersistencePanelGrid.BackgroundColor = [1 1 1];

            % Create PersistenceInterpolationLabel
            app.PersistenceInterpolationLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceInterpolationLabel.VerticalAlignment = 'bottom';
            app.PersistenceInterpolationLabel.FontSize = 11;
            app.PersistenceInterpolationLabel.Layout.Row = 1;
            app.PersistenceInterpolationLabel.Layout.Column = [1 3];
            app.PersistenceInterpolationLabel.Text = 'Interpolação:';

            % Create PersistenceInterpolation
            app.PersistenceInterpolation = uidropdown(app.PersistencePanelGrid);
            app.PersistenceInterpolation.Items = {'nearest', 'bilinear'};
            app.PersistenceInterpolation.FontSize = 11;
            app.PersistenceInterpolation.BackgroundColor = [1 1 1];
            app.PersistenceInterpolation.Layout.Row = 2;
            app.PersistenceInterpolation.Layout.Column = [1 2];
            app.PersistenceInterpolation.Value = 'nearest';

            % Create PersistenceWindowSizeLabel
            app.PersistenceWindowSizeLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceWindowSizeLabel.VerticalAlignment = 'bottom';
            app.PersistenceWindowSizeLabel.FontSize = 11;
            app.PersistenceWindowSizeLabel.Layout.Row = 1;
            app.PersistenceWindowSizeLabel.Layout.Column = [3 5];
            app.PersistenceWindowSizeLabel.Text = 'Tamanho janela:';

            % Create PersistenceWindowSizeValue
            app.PersistenceWindowSizeValue = uilabel(app.PersistencePanelGrid);
            app.PersistenceWindowSizeValue.HorizontalAlignment = 'right';
            app.PersistenceWindowSizeValue.VerticalAlignment = 'bottom';
            app.PersistenceWindowSizeValue.FontSize = 11;
            app.PersistenceWindowSizeValue.FontColor = [0.8 0.8 0.8];
            app.PersistenceWindowSizeValue.Layout.Row = 1;
            app.PersistenceWindowSizeValue.Layout.Column = [3 5];
            app.PersistenceWindowSizeValue.Text = 'full';

            % Create PersistenceWindowSize
            app.PersistenceWindowSize = uidropdown(app.PersistencePanelGrid);
            app.PersistenceWindowSize.Items = {'128', '256', '512', 'full'};
            app.PersistenceWindowSize.FontSize = 11;
            app.PersistenceWindowSize.BackgroundColor = [1 1 1];
            app.PersistenceWindowSize.Layout.Row = 2;
            app.PersistenceWindowSize.Layout.Column = [3 5];
            app.PersistenceWindowSize.Value = '128';

            % Create PersistenceColormapLabel
            app.PersistenceColormapLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceColormapLabel.VerticalAlignment = 'bottom';
            app.PersistenceColormapLabel.FontSize = 11;
            app.PersistenceColormapLabel.Layout.Row = 3;
            app.PersistenceColormapLabel.Layout.Column = [1 2];
            app.PersistenceColormapLabel.Text = 'Mapa de cores:';

            % Create PersistenceColormap
            app.PersistenceColormap = uidropdown(app.PersistencePanelGrid);
            app.PersistenceColormap.Items = {'winter', 'parula', 'turbo'};
            app.PersistenceColormap.FontSize = 11;
            app.PersistenceColormap.BackgroundColor = [1 1 1];
            app.PersistenceColormap.Layout.Row = 4;
            app.PersistenceColormap.Layout.Column = [1 2];
            app.PersistenceColormap.Value = 'winter';

            % Create PersistenceTransparencyLabel
            app.PersistenceTransparencyLabel = uilabel(app.PersistencePanelGrid);
            app.PersistenceTransparencyLabel.VerticalAlignment = 'bottom';
            app.PersistenceTransparencyLabel.WordWrap = 'on';
            app.PersistenceTransparencyLabel.FontSize = 11;
            app.PersistenceTransparencyLabel.Layout.Row = 3;
            app.PersistenceTransparencyLabel.Layout.Column = [3 5];
            app.PersistenceTransparencyLabel.Text = 'Transparência:';

            % Create PersistenceTransparency
            app.PersistenceTransparency = uispinner(app.PersistencePanelGrid);
            app.PersistenceTransparency.Step = 0.05;
            app.PersistenceTransparency.Limits = [0.2 1];
            app.PersistenceTransparency.ValueDisplayFormat = '%.2f';
            app.PersistenceTransparency.FontSize = 11;
            app.PersistenceTransparency.Layout.Row = 4;
            app.PersistenceTransparency.Layout.Column = [3 5];
            app.PersistenceTransparency.Value = 1;

            % Create PersistenceCLim_Label
            app.PersistenceCLim_Label = uilabel(app.PersistencePanelGrid);
            app.PersistenceCLim_Label.VerticalAlignment = 'bottom';
            app.PersistenceCLim_Label.FontSize = 11;
            app.PersistenceCLim_Label.Layout.Row = 5;
            app.PersistenceCLim_Label.Layout.Column = [1 4];
            app.PersistenceCLim_Label.Text = 'Limites de intensidade (%):';

            % Create PersistenceCLimRefresh
            app.PersistenceCLimRefresh = uiimage(app.PersistencePanelGrid);
            app.PersistenceCLimRefresh.ScaleMethod = 'none';
            app.PersistenceCLimRefresh.Enable = 'off';
            app.PersistenceCLimRefresh.Layout.Row = 5;
            app.PersistenceCLimRefresh.Layout.Column = 5;
            app.PersistenceCLimRefresh.ImageSource = 'Refresh_18.png';

            % Create PersistenceCLim1
            app.PersistenceCLim1 = uispinner(app.PersistencePanelGrid);
            app.PersistenceCLim1.Step = 0.1;
            app.PersistenceCLim1.Limits = [0 Inf];
            app.PersistenceCLim1.ValueDisplayFormat = '%.3f';
            app.PersistenceCLim1.FontSize = 11;
            app.PersistenceCLim1.Enable = 'off';
            app.PersistenceCLim1.Layout.Row = 6;
            app.PersistenceCLim1.Layout.Column = [1 2];

            % Create PersistenceCLim2
            app.PersistenceCLim2 = uispinner(app.PersistencePanelGrid);
            app.PersistenceCLim2.Limits = [0 Inf];
            app.PersistenceCLim2.ValueDisplayFormat = '%.3f';
            app.PersistenceCLim2.FontSize = 11;
            app.PersistenceCLim2.Enable = 'off';
            app.PersistenceCLim2.Layout.Row = 6;
            app.PersistenceCLim2.Layout.Column = [3 5];
            app.PersistenceCLim2.Value = 1;

            % Create WaterfallPanelIcon
            app.WaterfallPanelIcon = uiimage(app.RightPanel);
            app.WaterfallPanelIcon.ScaleMethod = 'none';
            app.WaterfallPanelIcon.Layout.Row = [11 12];
            app.WaterfallPanelIcon.Layout.Column = 1;
            app.WaterfallPanelIcon.ImageSource = 'Waterfall_24.png';

            % Create WaterfallPanelLabel
            app.WaterfallPanelLabel = uilabel(app.RightPanel);
            app.WaterfallPanelLabel.FontSize = 10;
            app.WaterfallPanelLabel.Layout.Row = 12;
            app.WaterfallPanelLabel.Layout.Column = 2;
            app.WaterfallPanelLabel.Text = 'WATERFALL';

            % Create WaterfallPanel
            app.WaterfallPanel = uipanel(app.RightPanel);
            app.WaterfallPanel.AutoResizeChildren = 'off';
            app.WaterfallPanel.Layout.Row = 14;
            app.WaterfallPanel.Layout.Column = [1 2];

            % Create WaterfallPanelGrid
            app.WaterfallPanelGrid = uigridlayout(app.WaterfallPanel);
            app.WaterfallPanelGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.WaterfallPanelGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.WaterfallPanelGrid.RowSpacing = 5;
            app.WaterfallPanelGrid.Padding = [10 10 10 5];
            app.WaterfallPanelGrid.BackgroundColor = [1 1 1];

            % Create WaterfallFcnLabel
            app.WaterfallFcnLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallFcnLabel.VerticalAlignment = 'bottom';
            app.WaterfallFcnLabel.WordWrap = 'on';
            app.WaterfallFcnLabel.FontSize = 11;
            app.WaterfallFcnLabel.Layout.Row = 1;
            app.WaterfallFcnLabel.Layout.Column = [1 3];
            app.WaterfallFcnLabel.Text = 'Renderização:';

            % Create WaterfallFcn
            app.WaterfallFcn = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallFcn.Items = {'image', 'mesh'};
            app.WaterfallFcn.FontSize = 11;
            app.WaterfallFcn.BackgroundColor = [1 1 1];
            app.WaterfallFcn.Layout.Row = 2;
            app.WaterfallFcn.Layout.Column = [1 2];
            app.WaterfallFcn.Value = 'image';

            % Create WaterfallDecimationLabel
            app.WaterfallDecimationLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallDecimationLabel.VerticalAlignment = 'bottom';
            app.WaterfallDecimationLabel.FontSize = 11;
            app.WaterfallDecimationLabel.Layout.Row = 1;
            app.WaterfallDecimationLabel.Layout.Column = [3 4];
            app.WaterfallDecimationLabel.Text = 'Decimação:';

            % Create WaterfallDecimationValue
            app.WaterfallDecimationValue = uilabel(app.WaterfallPanelGrid);
            app.WaterfallDecimationValue.HorizontalAlignment = 'right';
            app.WaterfallDecimationValue.VerticalAlignment = 'bottom';
            app.WaterfallDecimationValue.FontSize = 11;
            app.WaterfallDecimationValue.FontColor = [0.8 0.8 0.8];
            app.WaterfallDecimationValue.Layout.Row = 1;
            app.WaterfallDecimationValue.Layout.Column = [3 5];
            app.WaterfallDecimationValue.Text = 'auto';

            % Create WaterfallDecimation
            app.WaterfallDecimation = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallDecimation.Items = {'auto', '1', '2', '4', '8', '16', '32', '64', '128', '256'};
            app.WaterfallDecimation.Enable = 'off';
            app.WaterfallDecimation.FontSize = 11;
            app.WaterfallDecimation.BackgroundColor = [1 1 1];
            app.WaterfallDecimation.Layout.Row = 2;
            app.WaterfallDecimation.Layout.Column = [3 5];
            app.WaterfallDecimation.Value = 'auto';

            % Create WaterfallColormapLabel
            app.WaterfallColormapLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallColormapLabel.VerticalAlignment = 'bottom';
            app.WaterfallColormapLabel.FontSize = 11;
            app.WaterfallColormapLabel.Layout.Row = 3;
            app.WaterfallColormapLabel.Layout.Column = [1 3];
            app.WaterfallColormapLabel.Text = 'Mapa de cores:';

            % Create WaterfallColormap
            app.WaterfallColormap = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallColormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.WaterfallColormap.FontSize = 11;
            app.WaterfallColormap.BackgroundColor = [1 1 1];
            app.WaterfallColormap.Layout.Row = 4;
            app.WaterfallColormap.Layout.Column = [1 2];
            app.WaterfallColormap.Value = 'winter';

            % Create WaterfallMeshStyleLabel
            app.WaterfallMeshStyleLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallMeshStyleLabel.VerticalAlignment = 'bottom';
            app.WaterfallMeshStyleLabel.FontSize = 11;
            app.WaterfallMeshStyleLabel.Layout.Row = 3;
            app.WaterfallMeshStyleLabel.Layout.Column = [3 5];
            app.WaterfallMeshStyleLabel.Text = 'Linhas da superfície:';

            % Create WaterfallMeshStyle
            app.WaterfallMeshStyle = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallMeshStyle.Items = {'row', 'both'};
            app.WaterfallMeshStyle.Enable = 'off';
            app.WaterfallMeshStyle.FontSize = 11;
            app.WaterfallMeshStyle.BackgroundColor = [1 1 1];
            app.WaterfallMeshStyle.Layout.Row = 4;
            app.WaterfallMeshStyle.Layout.Column = [3 5];
            app.WaterfallMeshStyle.Value = 'row';

            % Create WaterfallCLimLabel
            app.WaterfallCLimLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallCLimLabel.VerticalAlignment = 'bottom';
            app.WaterfallCLimLabel.FontSize = 11;
            app.WaterfallCLimLabel.Layout.Row = 5;
            app.WaterfallCLimLabel.Layout.Column = [1 4];
            app.WaterfallCLimLabel.Text = 'Limites de nível (dB):';

            % Create WaterfallCLimRefresh
            app.WaterfallCLimRefresh = uiimage(app.WaterfallPanelGrid);
            app.WaterfallCLimRefresh.ScaleMethod = 'none';
            app.WaterfallCLimRefresh.Enable = 'off';
            app.WaterfallCLimRefresh.Layout.Row = 5;
            app.WaterfallCLimRefresh.Layout.Column = 5;
            app.WaterfallCLimRefresh.ImageSource = 'Refresh_18.png';

            % Create WaterfallCLim1
            app.WaterfallCLim1 = uispinner(app.WaterfallPanelGrid);
            app.WaterfallCLim1.RoundFractionalValues = 'on';
            app.WaterfallCLim1.ValueDisplayFormat = '%.0f';
            app.WaterfallCLim1.FontSize = 11;
            app.WaterfallCLim1.Enable = 'off';
            app.WaterfallCLim1.Layout.Row = 6;
            app.WaterfallCLim1.Layout.Column = [1 2];

            % Create WaterfallCLim2
            app.WaterfallCLim2 = uispinner(app.WaterfallPanelGrid);
            app.WaterfallCLim2.RoundFractionalValues = 'on';
            app.WaterfallCLim2.ValueDisplayFormat = '%.0f';
            app.WaterfallCLim2.FontSize = 11;
            app.WaterfallCLim2.Enable = 'off';
            app.WaterfallCLim2.Layout.Row = 6;
            app.WaterfallCLim2.Layout.Column = [3 5];
            app.WaterfallCLim2.Value = 1;

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [3 4];
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
