classdef winPlayback_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        dockModule_Undock               matlab.ui.control.Image
        dockModule_Close                matlab.ui.control.Image
        Document                        matlab.ui.container.GridLayout
        SubGrid1                        matlab.ui.container.GridLayout
        Image3                          matlab.ui.control.Image
        Image2                          matlab.ui.control.Image
        Image                           matlab.ui.control.Image
        play_ControlPanelLabel_2        matlab.ui.control.Label
        play_Persistance_Panel          matlab.ui.container.Panel
        play_PersistanceGrid            matlab.ui.container.GridLayout
        play_Persistance_cLim1          matlab.ui.control.Spinner
        play_Persistance_cLim2          matlab.ui.control.Spinner
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
        play_Waterfall_Panel            matlab.ui.container.Panel
        play_WaterFallGrid              matlab.ui.container.GridLayout
        play_Waterfall_cLim2            matlab.ui.control.Spinner
        play_Waterfall_cLim1            matlab.ui.control.Spinner
        play_Waterfall_cLim_Mode        matlab.ui.control.Image
        play_Waterfall_cLim_Label       matlab.ui.control.Label
        play_Waterfall_MeshStyle        matlab.ui.control.DropDown
        play_Waterfall_MeshStyleLabel   matlab.ui.control.Label
        play_Waterfall_Colormap         matlab.ui.control.DropDown
        play_Waterfall_ColormapLabel    matlab.ui.control.Label
        play_Waterfall_Decimation       matlab.ui.control.DropDown
        play_Waterfall_DecimationValue  matlab.ui.control.Label
        play_Waterfall_DecimationLabel  matlab.ui.control.Label
        play_Waterfall_Fcn              matlab.ui.control.DropDown
        play_Waterfall_FcnLabel         matlab.ui.control.Label
        play_ControlPanelLabel          matlab.ui.control.Label
        play_GeneralPanel               matlab.ui.container.Panel
        play_OthersGrid                 matlab.ui.container.GridLayout
        play_LimitsRefresh              matlab.ui.control.Image
        play_Limits_yLim2               matlab.ui.control.Spinner
        play_Limits_yLim1               matlab.ui.control.Spinner
        play_Limits_yLimLabel           matlab.ui.control.Label
        play_Limits_xLim2               matlab.ui.control.Spinner
        play_Limits_xLim1               matlab.ui.control.Spinner
        play_Limits_xLimLabel           matlab.ui.control.Label
        play_LimitsPanelLabel           matlab.ui.control.Label
        play_LayoutRatio                matlab.ui.control.DropDown
        play_LayoutRatioLabel           matlab.ui.control.Label
        play_GeneralPanelLabel          matlab.ui.control.Label
        LeftPanel                       matlab.ui.container.GridLayout
        FlowPanel                       matlab.ui.container.Panel
        FlowPanelGrid                   matlab.ui.container.GridLayout
        FlowAnalysis                    matlab.ui.control.Label
        FlowEmissions                   matlab.ui.container.Tree
        FlowEmissionsBtn2               matlab.ui.control.Image
        FlowEmissionsBtn1               matlab.ui.control.Image
        FlowEmissionsLabel              matlab.ui.control.Label
        FlowChannel                     matlab.ui.control.ListBox
        FlowChannelBtn                  matlab.ui.control.Image
        FlowChannelLabel                matlab.ui.control.Label
        FlowDetection                   matlab.ui.control.Label
        FlowDetectionBtn                matlab.ui.control.Image
        FlowDetectionLabel              matlab.ui.control.Label
        FlowOccupancy                   matlab.ui.control.Label
        FlowOccupancyBtn                matlab.ui.control.Image
        FlowOccupancyLabel              matlab.ui.control.Label
        FlowMetadata                    matlab.ui.control.Label
        FlowAttributesPanelRightBtn     matlab.ui.control.Image
        FlowAttributesPanelLeftBtn      matlab.ui.control.Image
        FlowAttributesPanelVisibleIdx   matlab.ui.control.Label
        FlowPanelLabel                  matlab.ui.control.Label
        SpectrumFlowList                matlab.ui.control.DropDown
        AxesToolbar                     matlab.ui.container.GridLayout
        axesTool_waterfall              matlab.ui.control.Image
        axesTool_occupancy              matlab.ui.control.Image
        axesTool_persistence            matlab.ui.control.Image
        axesTool_maxHold                matlab.ui.control.Image
        axesTool_average                matlab.ui.control.Image
        axesTool_minHold                matlab.ui.control.Image
        axesTool_DataTip                matlab.ui.control.Image
        axesTool_Pan                    matlab.ui.control.Image
        axesTool_RestoreView            matlab.ui.control.Image
        PlotPanel                       matlab.ui.container.Panel
        Toolbar                         matlab.ui.container.GridLayout
        tool_ReportGenerator_2          matlab.ui.control.Image
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
                        app.FlowAnalysis
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SpectrumFlowList.UserData.id, 'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', 'rgba(183, 49, 44, 0.75)'), ...
                            struct('appName', appName, 'dataTag', app.FlowPanelLabel.UserData.id, 'styleImportant', struct('borderLeft', '3px solid #b7312c', 'paddingLeft', '8px')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
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
            hParent = tiledlayout(app.PlotPanel, 4, 1, "Padding", "compact", "TileSpacing", "compact");

            app.UIAxes1 = plot.axes.Creation(hParent, 'Cartesian', {'TitleHorizontalAlignment', 'right', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2 1];
            
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'YScale', app.mainApp.General.plot.cartesianAxes.yOccupancyScale});
            app.UIAxes2.Layout.Tile = 3;
            
            app.UIAxes3 = plot.axes.Creation(hParent, 'Cartesian', {'Layer', 'top', 'Box', 'on', 'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes3.Layout.Tile = 4;            

            % Axes colormap:
            plot.axes.Colormap(app.UIAxes1, app.play_Persistance_Colormap.Value)
            plot.axes.Colormap(app.UIAxes3, app.play_Waterfall_Colormap.Value)

            % Axes colorbar:
            plot.axes.Colorbar(app.UIAxes3, app.mainApp.General.plot.waterfall.Colorbar)

            % Axes fixed labels:
            ylabel(app.UIAxes1, 'Nível (dB)')
            set(app.UIAxes1.Title, Visible='on', FontSize=10, FontWeight='normal', HorizontalAlignment='right', Color=[.8,.8,.8])
            title(app.UIAxes1, {'';'';''})

            ylabel(app.UIAxes2, 'Ocupação (%)')
            xlabel(app.UIAxes3, 'Frequência (MHz)')
            ylabel(app.UIAxes3, 'Instante')
            plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
            plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.play_LayoutRatio)

            % Axes listeners:
            linkaxes([app.UIAxes1, app.UIAxes2, app.UIAxes3], 'x')
            addlistener(app.UIAxes1, 'XLim', 'PostSet', @app.plot_AxesLimitsChanged);
            addlistener(app.UIAxes1, 'YLim', 'PostSet', @app.plot_AxesLimitsChanged);

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation([app.UIAxes1, app.UIAxes2, app.UIAxes3], [dataTipInteraction, regionZoomInteraction])
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
            title(app.UIAxes1, sprintf('%s\n%.3f - %.3f MHz\n', app.mainApp.specData(idx).Receiver, app.bandObj.FreqStart, app.bandObj.FreqStop))
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
        
                    app.play_LayoutRatio.Items                = {app.mainApp.specData(idx).UserData.customPlayback.Parameters.Controls.LayoutRatio};
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.play_LayoutRatio)
                    
                    app.play_Persistance_Interpolation.Value  = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.Interpolation;
                    app.play_Persistance_WindowSize.Value     = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.WindowSize;
                    app.play_Persistance_WindowSizeValue.Text = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.WindowSize;
                    app.play_Persistance_Transparency.Value   = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.Transparency;
                    app.play_Persistance_Colormap.Value       = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.Colormap;
        
                    if app.play_Persistance_WindowSize.Value == "full"
                        app.play_Persistance_cLim1.Value      = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.LevelLimits(1);
                        app.play_Persistance_cLim2.Value      = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Persistance.LevelLimits(2);
                    end

                    % A visibilidade e posição da Colobar não é tratada como 
                    % customização do playback... e por isso o componente
                    % específico não é atualizado com a informação presente
                    % em app.mainApp.specData.
                    app.play_Waterfall_Fcn.Value              = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.Fcn;
                    app.play_Waterfall_Decimation.Value       = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.Decimation;
                    app.play_Waterfall_MeshStyle.Value        = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.MeshStyle;            
                    app.play_Waterfall_Colormap.Value         = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.Colormap;
                    app.play_Waterfall_cLim1.Value            = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.LevelLimits(1);
                    app.play_Waterfall_cLim2.Value            = app.mainApp.specData(idx).UserData.customPlayback.Parameters.Waterfall.LevelLimits(2);
            end
        end

        %-----------------------------------------------------------------%
        function prePlot_updatingGeneralSettings(app)
            % app.General_I
            % (a) Persistance
            app.mainApp.General_I.plot.persistence = struct( ...
                'Interpolation', app.play_Persistance_Interpolation.Value, ...
                'WindowSize', app.play_Persistance_WindowSize.Value, ...
                'Transparency', app.play_Persistance_Transparency.Value, ...
                'Colormap', app.play_Persistance_Colormap.Value, ...
                'LevelLimits', [app.play_Persistance_cLim1.Value, app.play_Persistance_cLim2.Value] ...
            );

            if app.axesTool_persistence.UserData.status && strcmp(app.UIAxes1.UserData.CLimMode, 'auto')
                app.mainApp.General_I.plot.persistence.LevelLimits = [0, 1];
            end

            % (b) Waterfall
            app.mainApp.General_I.plot.waterfall.Fcn = app.play_Waterfall_Fcn.Value;
            app.mainApp.General_I.plot.waterfall.Decimation = app.play_Waterfall_Decimation.Value;
            app.mainApp.General_I.plot.waterfall.MeshStyle = app.play_Waterfall_MeshStyle.Value;
            app.mainApp.General_I.plot.waterfall.Colormap = app.play_Waterfall_Colormap.Value;
            app.mainApp.General_I.plot.waterfall.LevelLimits = [app.play_Waterfall_cLim1.Value, app.play_Waterfall_cLim2.Value];

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
                    [app.plotHandles.persistence, app.play_Persistance_WindowSizeValue.Text] = plot.Persistance('Creation', app.plotHandles.persistence, app.UIAxes1, app.bandObj, idx);
                    play_Layout_PersistancePanel(app)

                case 'Update'
                    if app.axesTool_persistence.UserData.status && ~strcmp(app.play_Persistance_WindowSizeValue.Text, 'full')
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

            [app.plotHandles.waterfall, app.play_Waterfall_DecimationValue.Text] = plot.Waterfall('Creation', app.UIAxes3, app.bandObj, idx);
            plot.axes.Layout.YLabel(app.plotHandles.waterfall, app.axesTool_waterfall.UserData.status)
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
                        app.Document.ColumnWidth(1:2) = {0,0};
                    else
                        app.Document.ColumnWidth(1:2) = {320,10};
                    end

                case app.tool_LayoutRight
                    if app.Document.ColumnWidth{end}
                        app.Document.ColumnWidth(end-1:end) = {0,0};
                    else
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
            app.tool_Play.Tooltip = {'Playback'};
            app.tool_Play.Layout.Row = [1 3];
            app.tool_Play.Layout.Column = 2;
            app.tool_Play.ImageSource = 'play_32.png';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.Tag = 'loop';
            app.tool_LoopControl.Tooltip = {'Loop do playback'};
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

            % Create tool_ReportGenerator
            app.tool_ReportGenerator = uiimage(app.Toolbar);
            app.tool_ReportGenerator.ScaleMethod = 'none';
            app.tool_ReportGenerator.Enable = 'off';
            app.tool_ReportGenerator.Tooltip = {'Gera relatório'};
            app.tool_ReportGenerator.Layout.Row = [1 3];
            app.tool_ReportGenerator.Layout.Column = 16;
            app.tool_ReportGenerator.ImageSource = 'Publish_HTML_16.png';

            % Create tool_FiscalizaUpdate
            app.tool_FiscalizaUpdate = uiimage(app.Toolbar);
            app.tool_FiscalizaUpdate.ScaleMethod = 'none';
            app.tool_FiscalizaUpdate.Tooltip = {'Upload relatório'};
            app.tool_FiscalizaUpdate.Layout.Row = [1 3];
            app.tool_FiscalizaUpdate.Layout.Column = 17;
            app.tool_FiscalizaUpdate.ImageSource = 'up-20px.png';

            % Create tool_LayoutRight
            app.tool_LayoutRight = uiimage(app.Toolbar);
            app.tool_LayoutRight.ScaleMethod = 'none';
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @tool_LayoutLeftImageClicked, true);
            app.tool_LayoutRight.Layout.Row = [1 3];
            app.tool_LayoutRight.Layout.Column = 18;
            app.tool_LayoutRight.ImageSource = 'layout-sidebar-right.svg';

            % Create tool_ReportGenerator_2
            app.tool_ReportGenerator_2 = uiimage(app.Toolbar);
            app.tool_ReportGenerator_2.ScaleMethod = 'none';
            app.tool_ReportGenerator_2.Enable = 'off';
            app.tool_ReportGenerator_2.Tooltip = {'Gera relatório'};
            app.tool_ReportGenerator_2.Layout.Row = [1 3];
            app.tool_ReportGenerator_2.Layout.Column = 15;
            app.tool_ReportGenerator_2.ImageSource = 'organization-20px-black.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {320, 10, 5, 198, '1x', 10, 232};
            app.Document.RowHeight = {24, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [2 3];
            app.Document.BackgroundColor = [1 1 1];

            % Create PlotPanel
            app.PlotPanel = uipanel(app.Document);
            app.PlotPanel.AutoResizeChildren = 'off';
            app.PlotPanel.BorderType = 'none';
            app.PlotPanel.BackgroundColor = [0 0 0];
            app.PlotPanel.Layout.Row = [1 2];
            app.PlotPanel.Layout.Column = [3 5];

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
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_Pan
            app.axesTool_Pan = uiimage(app.AxesToolbar);
            app.axesTool_Pan.Tooltip = {'Pan'};
            app.axesTool_Pan.Layout.Row = 1;
            app.axesTool_Pan.Layout.Column = 3;
            app.axesTool_Pan.ImageSource = 'Pan_32.png';

            % Create axesTool_DataTip
            app.axesTool_DataTip = uiimage(app.AxesToolbar);
            app.axesTool_DataTip.Enable = 'off';
            app.axesTool_DataTip.Tooltip = {'DataCursorMode'; '(restrito à Waterfall:Image)'};
            app.axesTool_DataTip.Layout.Row = 1;
            app.axesTool_DataTip.Layout.Column = 4;
            app.axesTool_DataTip.ImageSource = 'DataTip_22.png';

            % Create axesTool_minHold
            app.axesTool_minHold = uiimage(app.AxesToolbar);
            app.axesTool_minHold.Tag = 'MinHold';
            app.axesTool_minHold.Tooltip = {'MinHold'};
            app.axesTool_minHold.Layout.Row = 1;
            app.axesTool_minHold.Layout.Column = 5;
            app.axesTool_minHold.ImageSource = 'MinHold_32.png';

            % Create axesTool_average
            app.axesTool_average = uiimage(app.AxesToolbar);
            app.axesTool_average.Tag = 'Average';
            app.axesTool_average.Tooltip = {'Média'};
            app.axesTool_average.Layout.Row = 1;
            app.axesTool_average.Layout.Column = 6;
            app.axesTool_average.ImageSource = 'Average_32.png';

            % Create axesTool_maxHold
            app.axesTool_maxHold = uiimage(app.AxesToolbar);
            app.axesTool_maxHold.Tag = 'MaxHold';
            app.axesTool_maxHold.Tooltip = {'MaxHold'};
            app.axesTool_maxHold.Layout.Row = 1;
            app.axesTool_maxHold.Layout.Column = 7;
            app.axesTool_maxHold.ImageSource = 'MaxHold_32.png';

            % Create axesTool_persistence
            app.axesTool_persistence = uiimage(app.AxesToolbar);
            app.axesTool_persistence.Tag = 'Persistance';
            app.axesTool_persistence.Tooltip = {'Persistência'};
            app.axesTool_persistence.Layout.Row = 1;
            app.axesTool_persistence.Layout.Column = 8;
            app.axesTool_persistence.ImageSource = 'Persistance_36.png';

            % Create axesTool_occupancy
            app.axesTool_occupancy = uiimage(app.AxesToolbar);
            app.axesTool_occupancy.Tag = 'Ocuppancy';
            app.axesTool_occupancy.Tooltip = {'Ocupação'};
            app.axesTool_occupancy.Layout.Row = 1;
            app.axesTool_occupancy.Layout.Column = 9;
            app.axesTool_occupancy.ImageSource = 'Occupancy_32Gray.png';

            % Create axesTool_waterfall
            app.axesTool_waterfall = uiimage(app.AxesToolbar);
            app.axesTool_waterfall.ScaleMethod = 'none';
            app.axesTool_waterfall.Tag = 'Waterfall';
            app.axesTool_waterfall.Tooltip = {'Waterfall'};
            app.axesTool_waterfall.Layout.Row = 1;
            app.axesTool_waterfall.Layout.Column = 10;
            app.axesTool_waterfall.HorizontalAlignment = 'left';
            app.axesTool_waterfall.VerticalAlignment = 'bottom';
            app.axesTool_waterfall.ImageSource = 'Waterfall_24.png';

            % Create LeftPanel
            app.LeftPanel = uigridlayout(app.Document);
            app.LeftPanel.ColumnWidth = {'1x', 18, 10, 18};
            app.LeftPanel.RowHeight = {44, 30, '1x'};
            app.LeftPanel.ColumnSpacing = 5;
            app.LeftPanel.RowSpacing = 5;
            app.LeftPanel.Padding = [0 0 0 0];
            app.LeftPanel.Layout.Row = [1 2];
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.BackgroundColor = [1 1 1];

            % Create SpectrumFlowList
            app.SpectrumFlowList = uidropdown(app.LeftPanel);
            app.SpectrumFlowList.Items = {''};
            app.SpectrumFlowList.ValueChangedFcn = createCallbackFcn(app, @onSpectrumFlowListValueChanged, true);
            app.SpectrumFlowList.FontSize = 11;
            app.SpectrumFlowList.FontColor = [1 1 1];
            app.SpectrumFlowList.BackgroundColor = [0.7176 0.1922 0.1725];
            app.SpectrumFlowList.Layout.Row = 1;
            app.SpectrumFlowList.Layout.Column = [1 4];
            app.SpectrumFlowList.Value = '';

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

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.Document);
            app.SubGrid1.ColumnWidth = {18, '1x'};
            app.SubGrid1.RowHeight = {5, 17, 5, 124, 5, 5, 17, 5, 168, 5, 5, 17, 5, '1x'};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 0;
            app.SubGrid1.Padding = [0 0 0 0];
            app.SubGrid1.Layout.Row = [1 2];
            app.SubGrid1.Layout.Column = 7;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create play_GeneralPanelLabel
            app.play_GeneralPanelLabel = uilabel(app.SubGrid1);
            app.play_GeneralPanelLabel.FontSize = 10;
            app.play_GeneralPanelLabel.Layout.Row = 2;
            app.play_GeneralPanelLabel.Layout.Column = 2;
            app.play_GeneralPanelLabel.Text = 'EIXOS GRÁFICOS';

            % Create play_GeneralPanel
            app.play_GeneralPanel = uipanel(app.SubGrid1);
            app.play_GeneralPanel.AutoResizeChildren = 'off';
            app.play_GeneralPanel.BackgroundColor = [1 1 1];
            app.play_GeneralPanel.Layout.Row = 4;
            app.play_GeneralPanel.Layout.Column = [1 2];

            % Create play_OthersGrid
            app.play_OthersGrid = uigridlayout(app.play_GeneralPanel);
            app.play_OthersGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.play_OthersGrid.RowHeight = {22, 20, 22, 22};
            app.play_OthersGrid.RowSpacing = 5;
            app.play_OthersGrid.BackgroundColor = [1 1 1];

            % Create play_LayoutRatioLabel
            app.play_LayoutRatioLabel = uilabel(app.play_OthersGrid);
            app.play_LayoutRatioLabel.FontSize = 11;
            app.play_LayoutRatioLabel.Layout.Row = 1;
            app.play_LayoutRatioLabel.Layout.Column = [1 3];
            app.play_LayoutRatioLabel.Text = 'Razão de aspecto:';

            % Create play_LayoutRatio
            app.play_LayoutRatio = uidropdown(app.play_OthersGrid);
            app.play_LayoutRatio.Items = {'1:0:0'};
            app.play_LayoutRatio.FontSize = 11;
            app.play_LayoutRatio.BackgroundColor = [1 1 1];
            app.play_LayoutRatio.Layout.Row = 1;
            app.play_LayoutRatio.Layout.Column = [4 5];
            app.play_LayoutRatio.Value = '1:0:0';

            % Create play_LimitsPanelLabel
            app.play_LimitsPanelLabel = uilabel(app.play_OthersGrid);
            app.play_LimitsPanelLabel.VerticalAlignment = 'bottom';
            app.play_LimitsPanelLabel.FontSize = 11;
            app.play_LimitsPanelLabel.Layout.Row = 2;
            app.play_LimitsPanelLabel.Layout.Column = [1 4];
            app.play_LimitsPanelLabel.Text = 'Limites de frequência e nível:';

            % Create play_Limits_xLimLabel
            app.play_Limits_xLimLabel = uilabel(app.play_OthersGrid);
            app.play_Limits_xLimLabel.HorizontalAlignment = 'center';
            app.play_Limits_xLimLabel.FontSize = 10;
            app.play_Limits_xLimLabel.Layout.Row = 3;
            app.play_Limits_xLimLabel.Layout.Column = [1 5];
            app.play_Limits_xLimLabel.Text = 'MHz  ';

            % Create play_Limits_xLim1
            app.play_Limits_xLim1 = uispinner(app.play_OthersGrid);
            app.play_Limits_xLim1.ValueDisplayFormat = '%.3f';
            app.play_Limits_xLim1.Tag = 'FreqStart';
            app.play_Limits_xLim1.FontSize = 11;
            app.play_Limits_xLim1.Tooltip = {''};
            app.play_Limits_xLim1.Layout.Row = 3;
            app.play_Limits_xLim1.Layout.Column = 1;

            % Create play_Limits_xLim2
            app.play_Limits_xLim2 = uispinner(app.play_OthersGrid);
            app.play_Limits_xLim2.ValueDisplayFormat = '%.3f';
            app.play_Limits_xLim2.Tag = 'FreqStop';
            app.play_Limits_xLim2.FontSize = 11;
            app.play_Limits_xLim2.Tooltip = {''};
            app.play_Limits_xLim2.Layout.Row = 3;
            app.play_Limits_xLim2.Layout.Column = [4 5];

            % Create play_Limits_yLimLabel
            app.play_Limits_yLimLabel = uilabel(app.play_OthersGrid);
            app.play_Limits_yLimLabel.HorizontalAlignment = 'center';
            app.play_Limits_yLimLabel.FontSize = 10;
            app.play_Limits_yLimLabel.Layout.Row = 4;
            app.play_Limits_yLimLabel.Layout.Column = [1 5];
            app.play_Limits_yLimLabel.Text = 'dB  ';

            % Create play_Limits_yLim1
            app.play_Limits_yLim1 = uispinner(app.play_OthersGrid);
            app.play_Limits_yLim1.Step = 5;
            app.play_Limits_yLim1.ValueDisplayFormat = '%.1f';
            app.play_Limits_yLim1.Tag = 'MinLevel';
            app.play_Limits_yLim1.FontSize = 11;
            app.play_Limits_yLim1.Tooltip = {''};
            app.play_Limits_yLim1.Layout.Row = 4;
            app.play_Limits_yLim1.Layout.Column = 1;

            % Create play_Limits_yLim2
            app.play_Limits_yLim2 = uispinner(app.play_OthersGrid);
            app.play_Limits_yLim2.Step = 5;
            app.play_Limits_yLim2.ValueDisplayFormat = '%.1f';
            app.play_Limits_yLim2.Tag = 'MaxLevel';
            app.play_Limits_yLim2.FontSize = 11;
            app.play_Limits_yLim2.Tooltip = {''};
            app.play_Limits_yLim2.Layout.Row = 4;
            app.play_Limits_yLim2.Layout.Column = [4 5];

            % Create play_LimitsRefresh
            app.play_LimitsRefresh = uiimage(app.play_OthersGrid);
            app.play_LimitsRefresh.ScaleMethod = 'none';
            app.play_LimitsRefresh.Tooltip = {'Retorna à configuração padrão'};
            app.play_LimitsRefresh.Layout.Row = 2;
            app.play_LimitsRefresh.Layout.Column = 5;
            app.play_LimitsRefresh.HorizontalAlignment = 'right';
            app.play_LimitsRefresh.VerticalAlignment = 'bottom';
            app.play_LimitsRefresh.ImageSource = 'Refresh_18.png';

            % Create play_ControlPanelLabel
            app.play_ControlPanelLabel = uilabel(app.SubGrid1);
            app.play_ControlPanelLabel.FontSize = 10;
            app.play_ControlPanelLabel.Layout.Row = 7;
            app.play_ControlPanelLabel.Layout.Column = 2;
            app.play_ControlPanelLabel.Text = 'PERSISTÊNCIA';

            % Create play_Waterfall_Panel
            app.play_Waterfall_Panel = uipanel(app.SubGrid1);
            app.play_Waterfall_Panel.AutoResizeChildren = 'off';
            app.play_Waterfall_Panel.Layout.Row = 14;
            app.play_Waterfall_Panel.Layout.Column = [1 2];

            % Create play_WaterFallGrid
            app.play_WaterFallGrid = uigridlayout(app.play_Waterfall_Panel);
            app.play_WaterFallGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.play_WaterFallGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.play_WaterFallGrid.RowSpacing = 5;
            app.play_WaterFallGrid.Padding = [10 10 10 5];
            app.play_WaterFallGrid.BackgroundColor = [1 1 1];

            % Create play_Waterfall_FcnLabel
            app.play_Waterfall_FcnLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_FcnLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_FcnLabel.WordWrap = 'on';
            app.play_Waterfall_FcnLabel.FontSize = 11;
            app.play_Waterfall_FcnLabel.Layout.Row = 1;
            app.play_Waterfall_FcnLabel.Layout.Column = [1 3];
            app.play_Waterfall_FcnLabel.Text = 'Renderização:';

            % Create play_Waterfall_Fcn
            app.play_Waterfall_Fcn = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Fcn.Items = {'image', 'mesh'};
            app.play_Waterfall_Fcn.FontSize = 11;
            app.play_Waterfall_Fcn.BackgroundColor = [1 1 1];
            app.play_Waterfall_Fcn.Layout.Row = 2;
            app.play_Waterfall_Fcn.Layout.Column = [1 2];
            app.play_Waterfall_Fcn.Value = 'image';

            % Create play_Waterfall_DecimationLabel
            app.play_Waterfall_DecimationLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_DecimationLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_DecimationLabel.FontSize = 11;
            app.play_Waterfall_DecimationLabel.Layout.Row = 1;
            app.play_Waterfall_DecimationLabel.Layout.Column = [3 4];
            app.play_Waterfall_DecimationLabel.Text = 'Decimação:';

            % Create play_Waterfall_DecimationValue
            app.play_Waterfall_DecimationValue = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_DecimationValue.HorizontalAlignment = 'right';
            app.play_Waterfall_DecimationValue.VerticalAlignment = 'bottom';
            app.play_Waterfall_DecimationValue.FontSize = 11;
            app.play_Waterfall_DecimationValue.FontColor = [0.8 0.8 0.8];
            app.play_Waterfall_DecimationValue.Layout.Row = 1;
            app.play_Waterfall_DecimationValue.Layout.Column = [3 5];
            app.play_Waterfall_DecimationValue.Text = 'auto';

            % Create play_Waterfall_Decimation
            app.play_Waterfall_Decimation = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Decimation.Items = {'auto', '1', '2', '4', '8', '16', '32', '64', '128', '256'};
            app.play_Waterfall_Decimation.Enable = 'off';
            app.play_Waterfall_Decimation.FontSize = 11;
            app.play_Waterfall_Decimation.BackgroundColor = [1 1 1];
            app.play_Waterfall_Decimation.Layout.Row = 2;
            app.play_Waterfall_Decimation.Layout.Column = [3 5];
            app.play_Waterfall_Decimation.Value = 'auto';

            % Create play_Waterfall_ColormapLabel
            app.play_Waterfall_ColormapLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_ColormapLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_ColormapLabel.FontSize = 11;
            app.play_Waterfall_ColormapLabel.Layout.Row = 3;
            app.play_Waterfall_ColormapLabel.Layout.Column = [1 3];
            app.play_Waterfall_ColormapLabel.Text = 'Mapa de cores:';

            % Create play_Waterfall_Colormap
            app.play_Waterfall_Colormap = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.play_Waterfall_Colormap.FontSize = 11;
            app.play_Waterfall_Colormap.BackgroundColor = [1 1 1];
            app.play_Waterfall_Colormap.Layout.Row = 4;
            app.play_Waterfall_Colormap.Layout.Column = [1 2];
            app.play_Waterfall_Colormap.Value = 'winter';

            % Create play_Waterfall_MeshStyleLabel
            app.play_Waterfall_MeshStyleLabel = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_MeshStyleLabel.VerticalAlignment = 'bottom';
            app.play_Waterfall_MeshStyleLabel.FontSize = 11;
            app.play_Waterfall_MeshStyleLabel.Layout.Row = 3;
            app.play_Waterfall_MeshStyleLabel.Layout.Column = [3 5];
            app.play_Waterfall_MeshStyleLabel.Text = 'Linhas da superfície:';

            % Create play_Waterfall_MeshStyle
            app.play_Waterfall_MeshStyle = uidropdown(app.play_WaterFallGrid);
            app.play_Waterfall_MeshStyle.Items = {'row', 'both'};
            app.play_Waterfall_MeshStyle.Enable = 'off';
            app.play_Waterfall_MeshStyle.FontSize = 11;
            app.play_Waterfall_MeshStyle.BackgroundColor = [1 1 1];
            app.play_Waterfall_MeshStyle.Layout.Row = 4;
            app.play_Waterfall_MeshStyle.Layout.Column = [3 5];
            app.play_Waterfall_MeshStyle.Value = 'row';

            % Create play_Waterfall_cLim_Label
            app.play_Waterfall_cLim_Label = uilabel(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Label.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Label.FontSize = 11;
            app.play_Waterfall_cLim_Label.Layout.Row = 5;
            app.play_Waterfall_cLim_Label.Layout.Column = [1 4];
            app.play_Waterfall_cLim_Label.Text = 'Limites de nível (dB):';

            % Create play_Waterfall_cLim_Mode
            app.play_Waterfall_cLim_Mode = uiimage(app.play_WaterFallGrid);
            app.play_Waterfall_cLim_Mode.ScaleMethod = 'none';
            app.play_Waterfall_cLim_Mode.Enable = 'off';
            app.play_Waterfall_cLim_Mode.Layout.Row = 5;
            app.play_Waterfall_cLim_Mode.Layout.Column = 5;
            app.play_Waterfall_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Waterfall_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Waterfall_cLim_Mode.ImageSource = 'Refresh_18.png';

            % Create play_Waterfall_cLim1
            app.play_Waterfall_cLim1 = uispinner(app.play_WaterFallGrid);
            app.play_Waterfall_cLim1.Step = 5;
            app.play_Waterfall_cLim1.RoundFractionalValues = 'on';
            app.play_Waterfall_cLim1.ValueDisplayFormat = '%.0f';
            app.play_Waterfall_cLim1.FontSize = 11;
            app.play_Waterfall_cLim1.Enable = 'off';
            app.play_Waterfall_cLim1.Tooltip = {''};
            app.play_Waterfall_cLim1.Layout.Row = 6;
            app.play_Waterfall_cLim1.Layout.Column = [1 2];

            % Create play_Waterfall_cLim2
            app.play_Waterfall_cLim2 = uispinner(app.play_WaterFallGrid);
            app.play_Waterfall_cLim2.Step = 5;
            app.play_Waterfall_cLim2.RoundFractionalValues = 'on';
            app.play_Waterfall_cLim2.ValueDisplayFormat = '%.0f';
            app.play_Waterfall_cLim2.FontSize = 11;
            app.play_Waterfall_cLim2.Enable = 'off';
            app.play_Waterfall_cLim2.Tooltip = {''};
            app.play_Waterfall_cLim2.Layout.Row = 6;
            app.play_Waterfall_cLim2.Layout.Column = [3 5];
            app.play_Waterfall_cLim2.Value = 1;

            % Create play_Persistance_Panel
            app.play_Persistance_Panel = uipanel(app.SubGrid1);
            app.play_Persistance_Panel.AutoResizeChildren = 'off';
            app.play_Persistance_Panel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.play_Persistance_Panel.Layout.Row = 9;
            app.play_Persistance_Panel.Layout.Column = [1 2];

            % Create play_PersistanceGrid
            app.play_PersistanceGrid = uigridlayout(app.play_Persistance_Panel);
            app.play_PersistanceGrid.ColumnWidth = {87, '1x', '1x', 64, 18};
            app.play_PersistanceGrid.RowHeight = {18, 22, 20, 22, 20, 22};
            app.play_PersistanceGrid.RowSpacing = 5;
            app.play_PersistanceGrid.Padding = [10 10 10 5];
            app.play_PersistanceGrid.BackgroundColor = [1 1 1];

            % Create play_Persistance_InterpolationLabel
            app.play_Persistance_InterpolationLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_InterpolationLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_InterpolationLabel.FontSize = 11;
            app.play_Persistance_InterpolationLabel.Layout.Row = 1;
            app.play_Persistance_InterpolationLabel.Layout.Column = [1 3];
            app.play_Persistance_InterpolationLabel.Text = 'Interpolação:';

            % Create play_Persistance_Interpolation
            app.play_Persistance_Interpolation = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_Interpolation.Items = {'nearest', 'bilinear'};
            app.play_Persistance_Interpolation.FontSize = 11;
            app.play_Persistance_Interpolation.BackgroundColor = [1 1 1];
            app.play_Persistance_Interpolation.Layout.Row = 2;
            app.play_Persistance_Interpolation.Layout.Column = [1 2];
            app.play_Persistance_Interpolation.Value = 'nearest';

            % Create play_Persistance_WindowSizeLabel
            app.play_Persistance_WindowSizeLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_WindowSizeLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_WindowSizeLabel.FontSize = 11;
            app.play_Persistance_WindowSizeLabel.Layout.Row = 1;
            app.play_Persistance_WindowSizeLabel.Layout.Column = [3 5];
            app.play_Persistance_WindowSizeLabel.Text = 'Tamanho janela:';

            % Create play_Persistance_WindowSizeValue
            app.play_Persistance_WindowSizeValue = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_WindowSizeValue.HorizontalAlignment = 'right';
            app.play_Persistance_WindowSizeValue.VerticalAlignment = 'bottom';
            app.play_Persistance_WindowSizeValue.FontSize = 11;
            app.play_Persistance_WindowSizeValue.FontColor = [0.8 0.8 0.8];
            app.play_Persistance_WindowSizeValue.Layout.Row = 1;
            app.play_Persistance_WindowSizeValue.Layout.Column = [3 5];
            app.play_Persistance_WindowSizeValue.Text = 'full';

            % Create play_Persistance_WindowSize
            app.play_Persistance_WindowSize = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_WindowSize.Items = {'128', '256', '512', 'full'};
            app.play_Persistance_WindowSize.FontSize = 11;
            app.play_Persistance_WindowSize.BackgroundColor = [1 1 1];
            app.play_Persistance_WindowSize.Layout.Row = 2;
            app.play_Persistance_WindowSize.Layout.Column = [3 5];
            app.play_Persistance_WindowSize.Value = '128';

            % Create play_Persistance_ColormapLabel
            app.play_Persistance_ColormapLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_ColormapLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_ColormapLabel.FontSize = 11;
            app.play_Persistance_ColormapLabel.Layout.Row = 3;
            app.play_Persistance_ColormapLabel.Layout.Column = [1 2];
            app.play_Persistance_ColormapLabel.Text = 'Mapa de cores:';

            % Create play_Persistance_Colormap
            app.play_Persistance_Colormap = uidropdown(app.play_PersistanceGrid);
            app.play_Persistance_Colormap.Items = {'winter', 'parula', 'turbo'};
            app.play_Persistance_Colormap.FontSize = 11;
            app.play_Persistance_Colormap.BackgroundColor = [1 1 1];
            app.play_Persistance_Colormap.Layout.Row = 4;
            app.play_Persistance_Colormap.Layout.Column = [1 2];
            app.play_Persistance_Colormap.Value = 'winter';

            % Create play_Persistance_TransparencyLabel
            app.play_Persistance_TransparencyLabel = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_TransparencyLabel.VerticalAlignment = 'bottom';
            app.play_Persistance_TransparencyLabel.WordWrap = 'on';
            app.play_Persistance_TransparencyLabel.FontSize = 11;
            app.play_Persistance_TransparencyLabel.Layout.Row = 3;
            app.play_Persistance_TransparencyLabel.Layout.Column = [3 5];
            app.play_Persistance_TransparencyLabel.Text = 'Transparência:';

            % Create play_Persistance_Transparency
            app.play_Persistance_Transparency = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_Transparency.Step = 0.05;
            app.play_Persistance_Transparency.Limits = [0.2 1];
            app.play_Persistance_Transparency.ValueDisplayFormat = '%.2f';
            app.play_Persistance_Transparency.FontSize = 11;
            app.play_Persistance_Transparency.Layout.Row = 4;
            app.play_Persistance_Transparency.Layout.Column = [3 5];
            app.play_Persistance_Transparency.Value = 1;

            % Create play_Persistance_cLim_Label
            app.play_Persistance_cLim_Label = uilabel(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Label.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Label.FontSize = 11;
            app.play_Persistance_cLim_Label.Layout.Row = 5;
            app.play_Persistance_cLim_Label.Layout.Column = [1 4];
            app.play_Persistance_cLim_Label.Text = 'Limites de intensidade (%):';

            % Create play_Persistance_cLim_Mode
            app.play_Persistance_cLim_Mode = uiimage(app.play_PersistanceGrid);
            app.play_Persistance_cLim_Mode.ScaleMethod = 'none';
            app.play_Persistance_cLim_Mode.Enable = 'off';
            app.play_Persistance_cLim_Mode.Tooltip = {'Retorna à configuração padrão'};
            app.play_Persistance_cLim_Mode.Layout.Row = 5;
            app.play_Persistance_cLim_Mode.Layout.Column = 5;
            app.play_Persistance_cLim_Mode.HorizontalAlignment = 'right';
            app.play_Persistance_cLim_Mode.VerticalAlignment = 'bottom';
            app.play_Persistance_cLim_Mode.ImageSource = 'Refresh_18.png';

            % Create play_Persistance_cLim2
            app.play_Persistance_cLim2 = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_cLim2.Limits = [0 Inf];
            app.play_Persistance_cLim2.ValueDisplayFormat = '%.3f';
            app.play_Persistance_cLim2.FontSize = 11;
            app.play_Persistance_cLim2.Enable = 'off';
            app.play_Persistance_cLim2.Tooltip = {''};
            app.play_Persistance_cLim2.Layout.Row = 6;
            app.play_Persistance_cLim2.Layout.Column = [3 5];
            app.play_Persistance_cLim2.Value = 1;

            % Create play_Persistance_cLim1
            app.play_Persistance_cLim1 = uispinner(app.play_PersistanceGrid);
            app.play_Persistance_cLim1.Step = 0.1;
            app.play_Persistance_cLim1.Limits = [0 Inf];
            app.play_Persistance_cLim1.ValueDisplayFormat = '%.3f';
            app.play_Persistance_cLim1.FontSize = 11;
            app.play_Persistance_cLim1.Enable = 'off';
            app.play_Persistance_cLim1.Tooltip = {''};
            app.play_Persistance_cLim1.Layout.Row = 6;
            app.play_Persistance_cLim1.Layout.Column = [1 2];

            % Create play_ControlPanelLabel_2
            app.play_ControlPanelLabel_2 = uilabel(app.SubGrid1);
            app.play_ControlPanelLabel_2.FontSize = 10;
            app.play_ControlPanelLabel_2.Layout.Row = 12;
            app.play_ControlPanelLabel_2.Layout.Column = 2;
            app.play_ControlPanelLabel_2.Text = 'WATERFALL';

            % Create Image
            app.Image = uiimage(app.SubGrid1);
            app.Image.Layout.Row = [1 2];
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = 'DriveTestDensity_32.png';

            % Create Image2
            app.Image2 = uiimage(app.SubGrid1);
            app.Image2.Layout.Row = [6 7];
            app.Image2.Layout.Column = 1;
            app.Image2.VerticalAlignment = 'bottom';
            app.Image2.ImageSource = 'Persistance_36.png';

            % Create Image3
            app.Image3 = uiimage(app.SubGrid1);
            app.Image3.ScaleMethod = 'none';
            app.Image3.Layout.Row = [11 12];
            app.Image3.Layout.Column = 1;
            app.Image3.ImageSource = 'Waterfall_24.png';

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
            app.dockModule_Close.Tooltip = {''};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {''};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winRFDataHub';

            % Create contextmenu_del
            app.contextmenu_del = uimenu(app.ContextMenu);
            app.contextmenu_del.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.contextmenu_del.Text = '❌ Excluir';

            % Create contextmenu_delAll
            app.contextmenu_delAll = uimenu(app.ContextMenu);
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
