classdef winMiscellaneous_exported < matlab.apps.AppBase

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
        WaterfallFunction              matlab.ui.control.DropDown
        WaterfallFunctionLabel         matlab.ui.control.Label
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
        FlowOccupancy                  matlab.ui.control.ListBox
        FlowOccupancyEdit              matlab.ui.control.Image
        FlowOccupancyLabel             matlab.ui.control.Label
        FlowEmissions                  matlab.ui.control.Table
        FlowEmissionsAdd               matlab.ui.control.Image
        FlowEmissionsLabel             matlab.ui.control.Label
        FlowDetectionLimits            matlab.ui.control.ListBox
        FlowDetectionLimitsEdit        matlab.ui.control.Image
        FlowDetectionLabel             matlab.ui.control.Label
        FlowChannel                    matlab.ui.control.ListBox
        FlowChannelEdit                matlab.ui.control.Image
        FlowChannelLabel               matlab.ui.control.Label
        FlowMetadata                   matlab.ui.control.Label
        FlowAttributesPanelRightBtn    matlab.ui.control.Image
        FlowAttributesPanelLeftBtn     matlab.ui.control.Image
        FlowAttributesPanelVisibleIdx  matlab.ui.control.Label
        FlowPanelLabel                 matlab.ui.control.Label
        SpectrumFlowList               matlab.ui.control.DropDown
        AxesAnnotation                 matlab.ui.control.Label
        AxesToolbar                    matlab.ui.container.GridLayout
        axesTool_FlowInfo              matlab.ui.control.Image
        axesTool_Separator3_2          matlab.ui.control.Image
        axesTool_DataTip               matlab.ui.control.Image
        axesTool_waterfall             matlab.ui.control.Image
        axesTool_Separator3            matlab.ui.control.Image
        axesTool_occupancy             matlab.ui.control.Image
        axesTool_Separator2            matlab.ui.control.Image
        axesTool_persistence           matlab.ui.control.Image
        axesTool_maxHold               matlab.ui.control.Image
        axesTool_average               matlab.ui.control.Image
        axesTool_minHold               matlab.ui.control.Image
        axesTool_crearWrite            matlab.ui.control.Image
        axesTool_Separator1            matlab.ui.control.Image
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
        popupContainer

        SubTabGroup = struct('Children', -1, 'UserData', [])

        % Handles dos eixos cartesianos utilizados por este módulo. No futuro,
        % simplificar para uma lista de handles, permitindo a criação dinâmica
        % de quantos eixos forem necessários, como ocorre na geração do relatório.
        UIAxes1
        UIAxes2
        UIAxes3

        % Informações relacionadas ao specData selecionado, com atalhos para 
        % os principais metadados e a definição dos limites dos eixos x, y e 
        % z dos eixos cartesianos. No futuro, remover essa propriedade.
        bandObj

        % Armazena limites padrão dos eixos cartesianos computados em método 
        % de class.Band (app.bandObj).
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
        )

        % Controla o estado de atualização do plot:
        %  -1: mudança de fluxo espectral
        %   0: finaliza a apresentação da última varredura
        %   1: atualiza alguma característica do plot em andamento
        plotUpdateEvent = 0

        % Handles dos objetos gráficos do plot.
        plotHandles

        % Índice da varredura atual.
        sweepTimeIdx
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        projectData
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
                            case {'onFileListAdded', 'onFileListRemoved', 'onFileFilterChanged'}
                                updateFlowDropDown(app)

                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = -1;
                                else
                                    onFlowDropDownValueChanged(app)
                                end

                            case 'onTabNavigatorButtonPushed'
                                if app.plotUpdateEvent
                                    app.plotUpdateEvent = 0;
                                end

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
                        app.FlowDetectionLimitsEdit;
                        app.FlowEmissionsAdd;
                        app.FlowChannelEdit;
                        app.FlowOccupancyEdit;
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
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id,             'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SpectrumFlowList.UserData.id,        'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', 'rgba(183, 49, 44, 0.75)'), ...
                            struct('appName', appName, 'dataTag', app.FlowPanelLabel.UserData.id,          'styleImportant', struct('borderLeft', '3px solid #b7312c', 'paddingLeft', '8px')), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutLeft.UserData.id,         'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à esquerda')), ...
                            struct('appName', appName, 'dataTag', app.tool_Play.UserData.id,               'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla execução do playback da monitoração')), ...
                            struct('appName', appName, 'dataTag', app.tool_LoopControl.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Controla loop da execução do playback')), ...
                            struct('appName', appName, 'dataTag', app.tool_OpenPopupProject.UserData.id,   'tooltip', struct('defaultPosition', 'top',    'textContent', 'Edita informações do projeto<br>(fiscalizada, arquivo de backup etc)')), ...
                            struct('appName', appName, 'dataTag', app.tool_GenerateReport.UserData.id,     'tooltip', struct('defaultPosition', 'top',    'textContent', 'Gera relatório')), ...
                            struct('appName', appName, 'dataTag', app.tool_UploadFinalFile.UserData.id,    'tooltip', struct('defaultPosition', 'top',    'textContent', 'Upload relatório')), ...
                            struct('appName', appName, 'dataTag', app.tool_LayoutRight.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel à direita')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,       'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,        'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')), ...
                            struct('appName', appName, 'dataTag', app.FlowDetectionLimitsEdit.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Edita os limites de detecção')), ...
                            struct('appName', appName, 'dataTag', app.FlowEmissionsAdd.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Busca novas emissões')), ...
                            struct('appName', appName, 'dataTag', app.FlowChannelEdit.UserData.id,         'tooltip', struct('defaultPosition', 'top',    'textContent', 'Edita os canais')), ...
                            struct('appName', appName, 'dataTag', app.FlowOccupancyEdit.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Afere ocupação por outro método')) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.FlowMetadata,  appName, struct('class', {{'textview--borderless'}}));
                    catch
                    end

                otherwise
                     % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = app.mainApp.projectData;
            app.bandObj = model.Band('appAnalise:PLAYBACK', app.mainApp);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.FlowAttributesPanelVisibleIdx.UserData.index = 1;
            app.axesTool_Pan.UserData.status = false;
            app.axesTool_DataTip.UserData.status = false;
            app.axesTool_minHold.UserData = struct('status', false, 'imageSource', {{'MinHold_32Filled.png', 'MinHold_32.png'}});
            app.axesTool_average.UserData = struct('status', false, 'imageSource', {{'Average_32Filled.png', 'Average_32.png'}});
            app.axesTool_maxHold.UserData = struct('status', false, 'imageSource', {{'MaxHold_32Filled.png', 'MaxHold_32.png'}});
            app.axesTool_persistence.UserData.status = false;
            app.axesTool_occupancy.UserData.status = false;
            app.axesTool_waterfall.UserData.status = false;
            app.tool_LoopControl.UserData.loopMode = true;

            initializeAxes(app)

            addStyle(app.FlowEmissions, uistyle('HorizontalAlignment', 'center'), "column", 1)
            addStyle(app.FlowEmissions, uistyle('HorizontalAlignment', 'right'), "column", 2:3)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateFlowDropDown(app)
            onFlowDropDownValueChanged(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 4, 1, "Padding", "compact", "TileSpacing", "compact");

            app.UIAxes1 = plot.axes.Creation(hParent, 'Cartesian', {'TitleHorizontalAlignment', 'right', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2 1];
            
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'YScale', app.mainApp.General.plot.cartesianAxes.yOccupancyScale});
            app.UIAxes2.Layout.Tile = 3;
            
            app.UIAxes3 = plot.axes.Creation(hParent, 'Cartesian', {'Layer', 'top', 'Box', 'on', 'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes3.Layout.Tile = 4;            

            plot.axes.Colormap(app.UIAxes1, app.PersistenceColormap.Value)
            plot.axes.Colormap(app.UIAxes3, app.WaterfallColormap.Value)
            plot.axes.Colorbar(app.UIAxes3, app.mainApp.General.plot.waterfall.Colorbar)

            ylabel(app.UIAxes1, 'Nível (dB)')
            ylabel(app.UIAxes2, 'Ocupação (%)')
            xlabel(app.UIAxes3, 'Frequência (MHz)')
            ylabel(app.UIAxes3, 'Instante')

            plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
            plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)

            linkaxes([app.UIAxes1, app.UIAxes2, app.UIAxes3], 'x')
            addlistener(app.UIAxes1, 'XLim', 'PostSet', @syncUIAxesLimitsWithSpinners);
            addlistener(app.UIAxes1, 'YLim', 'PostSet', @syncUIAxesLimitsWithSpinners);
            addlistener(app.UIAxes1, 'CLim', 'PostSet', @syncUIAxesLimitsWithSpinners);
            addlistener(app.UIAxes3, 'CLim', 'PostSet', @syncUIAxesLimitsWithSpinners);

            plot.axes.Interactivity.DefaultCreation([app.UIAxes1, app.UIAxes2], [dataTipInteraction, regionZoomInteraction, rulerPanInteraction])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes3,                [dataTipInteraction, regionZoomInteraction])

            function syncUIAxesLimitsWithSpinners(src, evt)
                switch evt.AffectedObject
                    case app.UIAxes1
                        switch src.Name
                            case 'XLim'
                                evtName  = app.LimitsXLim1.Tag;
                                evtValue = round(evt.AffectedObject.XLim, 3);

                                if app.LimitsXLim1.Value == evtValue(1) && app.LimitsXLim2.Value == evtValue(2)
                                    return
                                end

                                app.LimitsXLim1.Value = evtValue(1);
                                app.LimitsXLim2.Value = evtValue(2);

                            case 'YLim'
                                evtName  = app.LimitsYLim1.Tag;
                                evtValue = round(evt.AffectedObject.YLim, 1);

                                if app.LimitsYLim1.Value == evtValue(1) && app.LimitsYLim2.Value == evtValue(2)
                                    return
                                end

                                app.LimitsYLim1.Value = evtValue(1);
                                app.LimitsYLim2.Value = evtValue(2);

                            case 'CLim'
                                evtName  = app.PersistenceCLim1.Tag;
                                evtValue = round(evt.AffectedObject.CLim, 3);

                                if app.PersistenceCLim1.Value == evtValue(1) && app.PersistenceCLim2.Value == evtValue(2)
                                    return
                                end

                                app.PersistenceCLim1.Value = evtValue(1);
                                app.PersistenceCLim2.Value = evtValue(2);

                            otherwise
                                return
                        end

                    case app.UIAxes3
                        switch src.Name
                            case 'CLim'
                                evtName  = app.WaterfallCLim1.Tag;
                                evtValue = round(evt.AffectedObject.CLim);

                                if app.WaterfallCLim1.Value == evtValue(1) && app.WaterfallCLim2.Value == evtValue(2)
                                    return
                                end

                                app.WaterfallCLim1.Value = evtValue(1);
                                app.WaterfallCLim2.Value = evtValue(2);

                            otherwise
                                return
                        end

                    otherwise
                        return
                end

                specData = app.bandObj.SpecData;
                if ~isempty(specData)
                    update(specData, 'UserData:PlotDisplayConfig', evtName, evtValue)
                end

                checkAxesLimitsCustomizations(app)
            end
        end

        %-----------------------------------------------------------------%
        % ## LAYOUT ##
        %-----------------------------------------------------------------%
        function updateFlowDropDown(app)
            specData = app.mainApp.specData;

            % Aberto, em 10/03/2026, reporte de BUG relacionado ao uidropdown, 
            % quando aplicado estilo "html". Ao apagar lista, o MATLAB não
            % apaga o valor atual do elemento na GUI. Assim que resolver
            % isso, basta inserir o addStyle uma única vez, não precisando
            % removê-lo.

            if ~isempty(specData)
                if isempty(app.SpectrumFlowList.StyleConfigurations)
                    addStyle(app.SpectrumFlowList, uistyle('Interpreter', 'html'))
                end

                previousValue = app.SpectrumFlowList.Value;
            
                [receivers, ~, indexes] = unique({specData.Receiver});
                items = {};
                itemsData = [];
                
                for ii = 1:numel(receivers)
                    receiverIdxs = find(indexes == ii)';
                    receiverName = util.layoutTreeNodeText(receivers{ii}, 'play_TreeBuilding');
                    
                    for jj = receiverIdxs
                        freqStart = specData(jj).MetaData.FreqStart / 1e+6;
                        freqStop  = specData(jj).MetaData.FreqStop  / 1e+6;

                        occupancyStatus = '';
                        if ismember(specData(jj).MetaData.DataType, class.Constants.occDataTypes)
                            occupancyStatus = ' (Ocupação)';
                        end
                        
                        reportStatus = '';
                        if ~isempty(specData(jj).UserData) && specData(jj).UserData.ReportInclude
                            reportStatus = '&emsp;&#x1F7E2;';
                        end
            
                        items{end+1} = sprintf('%s<br>└── %.3f&ensp;a&ensp;%.3f MHz%s%s', receiverName, freqStart, freqStop, occupancyStatus, reportStatus);
                        itemsData(end+1) = jj;
                    end
                end
            
                currentValue = {};    
                if ~isempty(previousValue)
                    if isnumeric(previousValue) && ismember(previousValue, itemsData)
                        currentValue = {'Value', previousValue};
                    end
                end
            
                set(app.SpectrumFlowList, 'Items', items, 'ItemsData', itemsData, currentValue{:})

            else             
                removeStyle(app.SpectrumFlowList)
                app.SpectrumFlowList.Items = {};
            end
        end

        %-----------------------------------------------------------------%
        function updateFlowView(app, idx)
            % Caso não esteja em cache os dados do fluxo espectral selecionado, 
            % procede-se a sua leitura, preenchendo a propriedade "Data" com
            % timestamps, níveis das varreduras, azimutes e notas de qualidade.
            % Caso ocorra erro na leitura, o registro é excluído e o layout é
            % reinicializado.
            specData = [];
            if ~isempty(idx)
                specData = app.mainApp.specData(idx);
            end

            if ~isempty(specData) && (isempty(specData.Data) || (numel(specData.Data{1}) ~= sum(specData.RelatedFiles.NumSweeps)))
                requestVisibilityChange(app.progressDialog, 'visible', 'unlocked')

                try
                    populateSpectrum(specData, app.mainApp.metaData, app.mainApp.channelObj, app.mainApp.General)
                    
                    relatedHases = specData.UserData.OccupancyComputationMode.RelatedHashes;
                    if ~isempty(relatedHases)
                        relatedHashIdxs = find(ismember({app.mainApp.specData.Hash}, relatedHases));
                        populateSpectrum(app.mainApp.specData(relatedHashIdxs), app.mainApp.metaData, app.mainApp.channelObj, app.mainApp.General)
                    end

                catch ME
                    ui.Dialog(app.UIFigure, 'error', ME.message);

                    delete(app.mainApp.specData(idx))
                    app.mainApp.specData(idx) = [];
                    updateFlowDropDown(app)
                    return
                end

                requestVisibilityChange(app.progressDialog, 'hidden', 'unlocked')
            end

            % Atualiza app.bandObj, instância de model.Band, que guarda
            % informações derivadas da instância de model.SpecData sob análise.
            % A partir desse momento, a referência ao specData selecionado
            % se dará por app.bandObj.SpecData.
            updateSpectrumInfo(app.bandObj, specData);

            % Atualiza PAINEL À ESQUERDA com metadados do fluxo, algoritmos de
            % ocupação, detecção e classificação, além da lista de emissões.
            updateUIControlsState(app, specData)
            updateUIPanelContent(app, specData)

            % Reseta o PLOT e atualiza informações que suportam o plot, como 
            % as dispostas no painel à direita.            
            resetPlotState(app, specData)

            % Atualiza PAINEL À DIREITA.
            applyCustomPlaybackSettings(app, specData)
        end

        %-----------------------------------------------------------------%
        function idx = findSpecDataIndex(app)
            idx = app.SpectrumFlowList.Value;
        end

        %-----------------------------------------------------------------%
        function updateUIControlsState(app, specData)
            % Atualiza atributos "Enable" e "Visible" dos componentes
            % afetados pelo estado atual de specData.
            nonEmptySpecData = ~isempty(specData);            
            hasMoreThanTwoSamples = nonEmptySpecData && sum(specData.RelatedFiles.NumSweeps) > 2;
            isWaterfallRenderedAsImage = hasMoreThanTwoSamples && strcmp(specData.UserData.PlotDisplayConfig.waterfall.function, 'image');
            isOccupancyFlow = nonEmptySpecData && ismember(specData.MetaData.DataType, class.Constants.occDataTypes);

            set([
                app.axesTool_crearWrite;
                app.axesTool_minHold;
                app.axesTool_average;
                app.axesTool_maxHold;
                app.axesTool_FlowInfo;
                app.tool_Play;
                app.tool_LoopControl;
                app.tool_TimestampSlider;
                app.tool_GenerateReport
            ], 'Enable', nonEmptySpecData)

            set([
                app.FlowDetectionLimitsEdit;
                app.FlowEmissionsAdd;
                app.FlowChannelEdit
            ], 'Enable', ~isOccupancyFlow)

            set([
                app.FlowOccupancyEdit;
                app.axesTool_occupancy
            ], 'Enable', hasMoreThanTwoSamples && ~isOccupancyFlow)

            app.axesTool_persistence.Enable = hasMoreThanTwoSamples;
            app.axesTool_waterfall.Enable   = hasMoreThanTwoSamples;
            app.tool_UploadFinalFile.Enable = ~isempty(app.projectData.modules.(app.Context).generatedFiles.lastHTMLDocFullPath);

            % DataCursorMode
            % O DataCursorMode é, de forma geral, uma interação ruim p/ eixos
            % cartesianos por bloquear as outras (Pan, RegionZoom etc). Por
            % essa razão, restringir o DataCursorMode apenas ao eixo específico
            % em que está sendo plotado a imagem (que não suporta a interação 
            % padrão de DataTip).
            app.axesTool_DataTip.Enable = isWaterfallRenderedAsImage;

            if ~isWaterfallRenderedAsImage && app.axesTool_DataTip.UserData.status
                onAxesToolbarButtonClicked(app, struct('Source', app.axesTool_DataTip))
            end

            if isOccupancyFlow
                app.LimitsYLimLabel.Text = '%  ';
            else
                app.LimitsYLimLabel.Text = 'dB  ';
            end
        end

        %-----------------------------------------------------------------%
        function updateUIPanelContent(app, specData)
            if ~isempty(specData)
                app.FlowMetadata.Text = util.HtmlTextGenerator.ThreadMetaData(specData);
            else
                app.FlowMetadata.Text = '';
            end

            if ~isempty(specData) && ~ismember(specData.MetaData.DataType, class.Constants.occDataTypes)
                channelLibIndex = specData.UserData.ChannelLibraryRelatedIndexes;
                if isempty(channelLibIndex)
                    app.FlowChannel.Items = {};
                else
                    app.FlowChannel.Items = arrayfun(@(x) sprintf('%.3f – %.3f MHz (%s)', x.Band(1), x.Band(2), x.Name), app.mainApp.channelObj.Channel(channelLibIndex), 'UniformOutput', false);
                end

                if specData.UserData.DetectionSubBandsEnabled && ~isempty(specData.UserData.DetectionSubBands)
                    app.FlowDetectionLimits.Items = cellstr(string(specData.UserData.DetectionSubBands.FreqStart) + " – " + string(specData.UserData.DetectionSubBands.FreqStop) + " MHz");
                else
                    app.FlowDetectionLimits.Items = {sprintf('%.3f – %.3f MHz (padrão)', specData.MetaData.FreqStart/1e+6, specData.MetaData.FreqStop/1e+6)};
                end

                emissionTable = specData.UserData.Emissions(:, {'Frequency', 'BandWidthkHz', 'Description'});
                if ~isempty(emissionTable)
                    emissionTable.('#') = string(1:height(emissionTable))';
                    emissionTable.Frequency = arrayfun(@(x) sprintf('%.3f', x), emissionTable.Frequency, "UniformOutput", false);
                    emissionTable.BandWidthkHz = arrayfun(@(x) sprintf('%.3f', x), emissionTable.BandWidthkHz, "UniformOutput", false);

                    app.FlowEmissions.Data  = emissionTable(:, {'#', 'Frequency', 'BandWidthkHz', 'Description'});
                else
                    app.FlowEmissions.Data = [];
                end

                occupancyList = {};
                cacheIndex = specData.UserData.OccupancyComputationMode.CacheIndex;
                selectedHash = specData.UserData.OccupancyComputationMode.SelectedHash;                
                selectedStatus = false;
                
                for ii = 1:numel(specData.UserData.OccupancyComputationMode.RelatedHashes)
                    relatedHash = specData.UserData.OccupancyComputationMode.RelatedHashes{ii};
                    
                    threshold = -1;
                    [~, occupancyFlowIdx] = ismember(relatedHash, {app.mainApp.specData.Hash});
                    if occupancyFlowIdx
                        threshold = app.mainApp.specData(occupancyFlowIdx).MetaData.Threshold;
                    end

                    levelUnit = app.mainApp.specData(occupancyFlowIdx).MetaData.LevelUnit;
                    occupancyRegister = sprintf('Limiar: %d %s (coleta) (%s...)', threshold, levelUnit, relatedHash(1:18));

                    if strcmp(relatedHash, selectedHash)
                        selectedStatus = true;
                        occupancyRegister = [occupancyRegister ' 🟢'];
                    end

                    occupancyList{end+1} = occupancyRegister;
                end

                for jj = 1:numel(specData.UserData.OccupancyFiniteIntegrationCache)
                    [minTHR, maxTHR] = bounds(specData.UserData.OccupancyFiniteIntegrationCache(jj).Threshold);
                    if minTHR == maxTHR
                        threshold = num2str(minTHR);
                    else
                        threshold = sprintf('%d a %d', minTHR, maxTHR);
                    end

                    levelUnit = specData.MetaData.LevelUnit;
                    occupancyRegister = sprintf('Limiar: %s %s', threshold, levelUnit);

                    if ~selectedStatus && isequal(jj, cacheIndex)
                        occupancyRegister = [occupancyRegister ' 🟢'];
                    end

                    occupancyList{end+1} = occupancyRegister;
                end
                app.FlowOccupancy.Items = occupancyList;

            else
                app.FlowChannel.Items = {};
                app.FlowDetectionLimits.Items = {};
                app.FlowEmissions.Data = [];
                app.FlowOccupancy.Items = {};
            end
        end

        %-----------------------------------------------------------------%
        function applyCustomPlaybackSettings(app, specData)
            if ~isempty(specData)
                iconDictionary = dictionary([true, false], [1, 2]);
    
                % CONTROLES AXESTOOLBAR
                if ~isequal(app.axesTool_minHold.UserData, specData.UserData.PlotDisplayConfig.controls.minHold)
                    app.axesTool_minHold.UserData.status  = specData.UserData.PlotDisplayConfig.controls.minHold;
                    app.axesTool_minHold.ImageSource      = app.axesTool_minHold.UserData.imageSource{iconDictionary(app.axesTool_minHold.UserData.status)};
                end
    
                if ~isequal(app.axesTool_average.UserData, specData.UserData.PlotDisplayConfig.controls.average)
                    app.axesTool_average.UserData.status  = specData.UserData.PlotDisplayConfig.controls.average;
                    app.axesTool_average.ImageSource      = app.axesTool_average.UserData.imageSource{iconDictionary(app.axesTool_average.UserData.status)};
                end
    
                if ~isequal(app.axesTool_maxHold.UserData, specData.UserData.PlotDisplayConfig.controls.maxHold)
                    app.axesTool_maxHold.UserData.status  = specData.UserData.PlotDisplayConfig.controls.maxHold;
                    app.axesTool_maxHold.ImageSource      = app.axesTool_maxHold.UserData.imageSource{iconDictionary(app.axesTool_maxHold.UserData.status)};
                end
    
                app.axesTool_persistence.UserData.status  = specData.UserData.PlotDisplayConfig.controls.persistence;
                app.axesTool_occupancy.UserData.status    = specData.UserData.PlotDisplayConfig.controls.occupancy;
                app.axesTool_waterfall.UserData.status    = specData.UserData.PlotDisplayConfig.controls.waterfall;
    
                % CONTROLES PAINEL À DIREITA
                app.LayoutRatio.Items                     = { specData.UserData.PlotDisplayConfig.layoutRatio };
                
                plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                plot.axes.Layout.RatioAspect([ app.UIAxes1, app.UIAxes2, app.UIAxes3 ], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)
                
                app.PersistenceInterpolation.Value        = specData.UserData.PlotDisplayConfig.persistence.interpolation;
                app.PersistenceWindowSize.Value           = specData.UserData.PlotDisplayConfig.persistence.windowSize;
                app.PersistenceWindowSizeValue.Text       = specData.UserData.PlotDisplayConfig.persistence.windowSize;
                app.PersistenceTransparency.Value         = specData.UserData.PlotDisplayConfig.persistence.transparency;
                app.PersistenceColormap.Value             = specData.UserData.PlotDisplayConfig.persistence.colormap;
    
                app.WaterfallFunction.Value               = specData.UserData.PlotDisplayConfig.waterfall.function;
                app.WaterfallDecimation.Value             = specData.UserData.PlotDisplayConfig.waterfall.decimation;
                app.WaterfallDecimationValue.Text         = specData.UserData.PlotDisplayConfig.waterfall.decimation;
                app.WaterfallMeshStyle.Value              = specData.UserData.PlotDisplayConfig.waterfall.meshStyle;            
                app.WaterfallColormap.Value               = specData.UserData.PlotDisplayConfig.waterfall.colormap;
    
                app.WaterfallCLim1.Value                  = specData.UserData.PlotDisplayConfig.limits.waterfall.current(1);
                app.WaterfallCLim2.Value                  = specData.UserData.PlotDisplayConfig.limits.waterfall.current(2);
            end

            updatePersistencePanel(app, 'initialization')
            updateWaterfallPanel(app)
            checkAxesLimitsCustomizations(app)
        end

        %-----------------------------------------------------------------%
        function checkAxesLimitsCustomizations(app)
            specData = app.bandObj.SpecData;
            
            if ~isempty(specData)
                limits = specData.UserData.PlotDisplayConfig.limits;                
                app.LimitsRefresh.Visible = ~isequal(limits.frequency.initial, limits.frequency.current) || ~isequal(limits.level.initial, limits.level.current);
                app.PersistenceCLimRefresh.Visible = ~strcmp(app.UIAxes1.UserData.CLimMode, 'auto') && strcmp(app.PersistenceWindowSize.Value, 'full');
                app.WaterfallCLimRefresh.Visible = ~strcmp(app.UIAxes3.UserData.CLimMode, 'auto');
                
            else
                set([
                    app.LimitsRefresh;
                    app.PersistenceCLimRefresh;
                    app.WaterfallCLimRefresh
                ], 'Visible', false)
            end
        end

        %-----------------------------------------------------------------%
        % ## PLOT CONTROLLER ##
        %-----------------------------------------------------------------%
        function resetPlotState(app, specData)
            cla([app.UIAxes1, app.UIAxes2, app.UIAxes3])
            
            ysecondarylabel(app.UIAxes2, '')
            ysecondarylabel(app.UIAxes3, '')

            app.UIAxes1.UserData.CLimMode = 'auto';
            app.UIAxes3.UserData.CLimMode = 'auto';

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
    
            app.sweepTimeIdx = 1;
            app.tool_TimestampSlider.Value = 0;
            resetRestoreView(app)

            if ~isempty(specData)
                app.tool_TimestampLabel.Text = sprintf('1 de %d\n%s', app.bandObj.NumSweeps, app.bandObj.YLimitsTime(1));
                app.AxesAnnotation.Text = sprintf('%s \n%.3f – %.3f MHz ', app.bandObj.Receiver, app.bandObj.FreqStart, app.bandObj.FreqStop);

            else
                app.tool_TimestampLabel.Text = '';
                app.AxesAnnotation.Text = '';

                if app.axesTool_occupancy.UserData.status || app.axesTool_waterfall.UserData.status
                    app.axesTool_occupancy.UserData.status = false;
                    app.axesTool_waterfall.UserData.status = false;

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)
                end

                onAxesToolbarButtonClicked(app, struct('Source', app.axesTool_RestoreView))
            end
        end

        %-----------------------------------------------------------------%
        function resetRestoreView(app)
            app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', app.bandObj.XLimits, 'yLim', app.bandObj.YLimitsLevel, 'cLim', 'auto');
            app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', app.bandObj.XLimits, 'yLim', [0, 100],                 'cLim', 'auto');
            app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', app.bandObj.XLimits, 'yLim', app.bandObj.YLimitsTime,  'cLim', app.bandObj.CLimits);
        end

        %-----------------------------------------------------------------%
        function updatePlot(app)
            specData = app.bandObj.SpecData;
            if isempty(specData)
                return
            end
        
            if isempty(app.plotHandles.clearWrite)
                set(app.UIAxes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
                ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))
        
                % (a) ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["clearWrite", "minHold", "average", "maxHold"]
                    if ismember(plotTag, {'minHold', 'average', 'maxHold'}) && ~eval(sprintf('app.axesTool_%s.UserData.status', plotTag))
                        continue
                    end
        
                    app.plotHandles.(plotTag) = plot.draw2D.OrdinaryLine(app.UIAxes1, plotTag, app.bandObj, app.sweepTimeIdx);
                    plot.datatip.Template(app.plotHandles.(plotTag), "Frequency+Level", app.bandObj.LevelUnit)
                end
                
                % (b) Persistence
                if app.axesTool_persistence.UserData.status
                    updatePersistencePlot(app, 'Creation')
                end

                % Emissões
                % plot.draw2D.ClearWrite_old(app, idx, 'InitialPlot', 1)

                % BandLimits & Channels
                % plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'bandLimits')
                % plot_Draw_Channels(app, idx)
        
                % Occupancy
                if app.axesTool_occupancy.UserData.status
                    updateOccupancyPlot(app, 'Creation', specData)
                end
        
                % Waterfall
                if app.axesTool_waterfall.UserData.status
                    updateWaterfallPlot(app)
                end
        
                % customPlayback >> DataTips
                if ~isempty(specData.UserData.PlotDisplayConfig.dataTips)
                    dtConfig = specData.UserData.PlotDisplayConfig.dataTips;
                    dtParent = [app.UIAxes1, app.UIAxes2, app.UIAxes3];
                    plot.datatip.Create('customPlayback', dtConfig, dtParent)
                end
        
            else
                % ClearWrite, MinHold, Average, e MaxHold
                for plotTag = ["clearWrite", "minHold", "average", "maxHold"]
                    if ismember(plotTag, {'minHold', 'average', 'maxHold'})
                        if ~eval(sprintf('app.axesTool_%s.UserData.status', plotTag)) || isinf(app.mainApp.General.context.PLAYBACK.integration.traceMode)
                            continue
                        end
                    end
        
                    plot.draw2D.OrdinaryLineUpdate(plotTag, app.plotHandles.(plotTag), app.bandObj, app.sweepTimeIdx);
                end
        
                for ii = 1:numel(app.plotHandles.emissionMarkers)
                    app.plotHandles.emissionMarkers(ii).Position(2) = app.plotHandles.clearWrite.YData(app.plotHandles.clearWrite.MarkerIndices(ii));
                end
        
                % Persistence
                updatePersistencePlot(app, 'Update')

                % WaterfallTime
                if app.axesTool_waterfall.UserData.status && ~isempty(app.plotHandles.waterfallTime)
                    plot.draw2D.OrdinaryLineUpdate('waterfallTime', app.plotHandles.waterfallTime, app.bandObj, app.sweepTimeIdx);
                end
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        % ## PERSISTENCE ##
        %-----------------------------------------------------------------%
        function updatePersistencePanel(app, operationType)
            elementHandles = findobj(app.PersistencePanelGrid.Children, '-not', 'Type', 'uilabel', '-or', 'Type', 'uiimage');
            set(elementHandles, 'Enable', app.axesTool_persistence.UserData.status)

            switch operationType
                case 'initialization'
                    % ...

                case 'updateLimits'
                    spinnersHandles = [ app.PersistenceCLim1, app.PersistenceCLim2 ];
        
                    if ~isempty(app.plotHandles.persistence)
                        switch app.PersistenceWindowSize.Value
                            case 'full'
                                set(spinnersHandles, 'Enable', 1)
                            otherwise
                                set(spinnersHandles, 'Enable', 0)
                        end
        
                        app.restoreView(1).cLim = app.UIAxes1.CLim;
                        app.PersistenceCLim1.Value = round(app.UIAxes1.CLim(1), 3);
                        app.PersistenceCLim2.Value = round(app.UIAxes1.CLim(2), 3);
        
                    else
                        set(spinnersHandles, 'Enable', 0)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function updatePersistencePlot(app, operationType)
            switch operationType
                case 'Creation'
                    [app.plotHandles.persistence, app.PersistenceWindowSizeValue.Text] = plot.Persistence('Creation', app.plotHandles.persistence, app.UIAxes1, app.bandObj, app.sweepTimeIdx);
                    updatePersistencePanel(app, 'updateLimits')

                case 'Update'
                    if app.axesTool_persistence.UserData.status && ~strcmp(app.PersistenceWindowSizeValue.Text, 'full')
                        app.plotHandles.persistence = plot.Persistence('Update', app.plotHandles.persistence, app.UIAxes1, app.bandObj, app.sweepTimeIdx);
                        updatePersistencePanel(app, 'updateLimits')
                    end

                case 'Delete'
                    app.plotHandles.persistence = plot.Persistence('Delete', app.plotHandles.persistence);
                    updatePersistencePanel(app, 'initialization')
            end
        end

        %-----------------------------------------------------------------%
        % ## WATERFALL ##
        %-----------------------------------------------------------------%
        function updateWaterfallPanel(app)
            specData = app.bandObj.SpecData;
            elementHandles = findobj(app.WaterfallPanelGrid.Children, '-not', 'Type', 'uilabel', '-or', 'Type', 'uiimage');
            
            if app.axesTool_waterfall.UserData.status
                elementDisabled = [];
                if strcmp(app.WaterfallFunction.Value, 'image')
                    elementDisabled = app.WaterfallMeshStyle;
                end

                set(setdiff(elementHandles, elementDisabled), 'Enable', true)
                if ~isempty(elementDisabled)
                    set(elementDisabled, 'Enable', false)
                end

                app.restoreView(3).yLim = app.UIAxes3.YLim;
                app.restoreView(3).cLim = app.UIAxes3.CLim;

                app.WaterfallCLim1.Value = round(double(app.UIAxes3.CLim(1)));
                app.WaterfallCLim2.Value = round(double(app.UIAxes3.CLim(2)));

            else
                set(elementHandles, 'Enable', false)
            end

            updateUIControlsState(app, specData)
        end

        %-----------------------------------------------------------------%
        function updateWaterfallPlot(app)
            [app.plotHandles.waterfall, app.WaterfallDecimationValue.Text] = plot.Waterfall('Creation', app.plotHandles.waterfall, app.UIAxes3, app.bandObj);
            plot.axes.Layout.YLabel(app.plotHandles.waterfall, app.axesTool_waterfall.UserData.status)
            updateWaterfallPanel(app)

            % Timeline
            if app.mainApp.General.context.PLAYBACK.waterfallTimeVisibility
                app.plotHandles.waterfallTime = plot.draw2D.OrdinaryLine(app.UIAxes3, 'waterfallTime', app.bandObj, app.sweepTimeIdx);
            end
        end

        %-----------------------------------------------------------------%
        function updateOccupancyPlot(app, operationType, specData)
            switch operationType
                case 'Creation'
                    selectedHash = specData.UserData.OccupancyComputationMode.SelectedHash;
                    [~, selectedHashIdx] = ismember(selectedHash, {app.mainApp.specData.Hash});
        
                    if selectedHashIdx
                        occParameters  = struct( ...
                            'Method', 'Linear fixo (coleta)', ...
                            'Threshold', app.mainApp.specData(selectedHashIdx).MetaData.Threshold, ...
                            'IntegrationTime', app.mainApp.specData(selectedHashIdx).RelatedFiles.RevisitTime / 60 ... % sec >> min
                        );
                        occThreshold   = app.mainApp.specData(selectedHashIdx).MetaData.Threshold;
                        occAverageData = app.mainApp.specData(selectedHashIdx).Data{3}(:, 2);

                    else
                        cacheIdx = specData.UserData.OccupancyComputationMode.CacheIndex;
                        if ~isempty(cacheIdx)
                            occParameters  = specData.UserData.OccupancyFiniteIntegrationCache(cacheIdx).Parameters;
                            occThreshold   = specData.UserData.OccupancyFiniteIntegrationCache(cacheIdx).Threshold;
                            occAverageData = specData.UserData.OccupancyFiniteIntegrationCache(cacheIdx).Data{3}(:, 2);
                        else
                            occParameters  = specData.UserData.OccupancyCumulativeIntegration.Parameters;
                            occThreshold   = specData.UserData.OccupancyCumulativeIntegration.Threshold;
                            occMatrix      = specData.UserData.OccupancyCumulativeIntegration.Matrix;
                            occAverageData = 100 * sum(occMatrix, 2) / width(occMatrix);
                        end
                    end
        
                    plot.Occupancy('Creation', app.UIAxes1, app.UIAxes2, occParameters, occThreshold, occAverageData, app.bandObj, app.mainApp.General)

                case 'Delete'
                    plot.Occupancy('Delete', app.UIAxes1, app.UIAxes2)
            end
        end

        %-----------------------------------------------------------------%
        % ## CHANNELS & EMISSIONS ##
        %-----------------------------------------------------------------%
        function updateChannelPlot(app, idx)
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
            %                 srcRawTable = app.mainApp.specData(idx).UserData.ChannelUserDefined(idxChannel);
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
        function updateEmissionPlot(app)
            % ...
        end

        %-----------------------------------------------------------------%
        % ## PLAYBACK ##
        %-----------------------------------------------------------------%
        function runPlaybackLoop(app, idx, nSweeps)
            app.tool_Play.ImageSource = 'playback-stop-16px-gray.png';

            if ~app.plotHandles.clearWrite.Visible
                app.plotHandles.clearWrite.Visible = true;
            end

            while app.sweepTimeIdx <= nSweeps
                switch app.plotUpdateEvent
                    case -1
                        app.plotUpdateEvent = 1;

                        idx = findSpecDataIndex(app);
                        updateFlowView(app, idx)

                        if isempty(idx)
                            break
                        end
                        
                        nSweeps = numel(app.mainApp.specData(idx).Data{1});

                    case  0
                        break
                end

                sweepTic = tic;
                
                updatePlot(app)
                app.tool_TimestampLabel.Text   = sprintf('%d de %d\n%s', app.sweepTimeIdx, nSweeps, app.mainApp.specData(idx).Data{1}(app.sweepTimeIdx));
                app.tool_TimestampSlider.Value = round(100 * app.sweepTimeIdx/nSweeps, 1);
                
                pause(max(app.mainApp.General.context.PLAYBACK.minSweepTimeSeconds - toc(sweepTic), .025)) % Valor mínimo: 25ms
                
                % Reload Flag
                if app.sweepTimeIdx == nSweeps
                    if ~app.tool_LoopControl.UserData.loopMode
                        break
                    end
                    app.sweepTimeIdx = 1;
                else
                    app.sweepTimeIdx = app.sweepTimeIdx+1;
                end                
            end

            app.plotUpdateEvent = 0;
            app.tool_Play.ImageSource = 'playback-play-16px-gray.png';
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

            if app.plotUpdateEvent
                app.plotUpdateEvent = 0;
                return
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', app.Context)
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function DockModuleGroup_ButtonPushed(app, event)
            
            if app.plotUpdateEvent
                app.plotUpdateEvent = 0;
                return
            end

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

        % Value changed function: SpectrumFlowList
        function onFlowDropDownValueChanged(app, event)

            if app.plotUpdateEvent
                app.plotUpdateEvent = -1;
            else
                idx = findSpecDataIndex(app);
                updateFlowView(app, idx)
                updatePlot(app)
            end
            
        end

        % Image clicked function: FlowAttributesPanelLeftBtn, 
        % ...and 1 other component
        function onFlowPanelViewChanged(app, event)
            
            numPanels = 4;

            panelSubtitles = {'Metadados', 'Canais', 'Emissões', 'Ocupação'};
            panelBtnStatus = [false true; true true; true true; true false];
            columnWidths = {
                {'1x',0,0,0,0,0,0,0,0,0,0};
                {0,10,'1x',18,10,0,0,0,0,0,0};
                {0,0,0,0,10,'1x',18,10,0,0,0};
                {0,0,0,0,0,0,0,10,'1x',18,10}
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
            app.FlowAttributesPanelVisibleIdx.Text = sprintf('%d/%d', currentIndex, numPanels);

            app.FlowPanelGrid.ColumnWidth = columnWidths{currentIndex};
            app.FlowEmissions.Visible = strcmp(panelSubtitles{currentIndex}, 'Emissões');

            app.FlowPanelLabel.Text = replace(app.FlowPanelLabel.Text, extractBetween(app.FlowPanelLabel.Text, '<i>', '</i>'), panelSubtitles{currentIndex});
            app.FlowAttributesPanelVisibleIdx.UserData.index = currentIndex;

        end

        % Image clicked function: axesTool_DataTip, axesTool_Pan, 
        % ...and 8 other components
        function onAxesToolbarButtonClicked(app, event)
            
            specData = app.bandObj.SpecData;

            switch event.Source
                case app.axesTool_RestoreView
                    plot.axes.Interactivity.CustomRestoreViewFcn(app.UIAxes1, [app.UIAxes2, app.UIAxes3], app)

                case app.axesTool_Pan
                    app.axesTool_Pan.UserData.status = ~app.axesTool_Pan.UserData.status;
                    if app.axesTool_Pan.UserData.status
                        app.axesTool_Pan.ImageSource = 'pan-filled-32px.png';
                        
                        if app.axesTool_DataTip.UserData.status
                            onAxesToolbarButtonClicked(app, struct('Source', app.axesTool_DataTip))
                        end
                    else
                        app.axesTool_Pan.ImageSource = 'pan-32px.png';
                    end

                    plot.axes.Interactivity.CustomPanFcn(struct('Value', app.axesTool_Pan.UserData.status), [app.UIAxes1, app.UIAxes2, app.UIAxes3]);

                case app.axesTool_crearWrite
                    if ~isempty(app.plotHandles.clearWrite) && isvalid(app.plotHandles.clearWrite)
                        app.plotHandles.clearWrite.Visible = ~app.plotHandles.clearWrite.Visible;
                    end

                    if app.plotUpdateEvent
                        app.plotUpdateEvent = 0;
                    end

                case {app.axesTool_minHold, app.axesTool_average, app.axesTool_maxHold}
                    event.Source.UserData.status = ~event.Source.UserData.status;

                    plotTag = event.Source.Tag;
                    update(specData, 'UserData:PlotDisplayConfig', plotTag, event.Source.UserData.status)

                    if event.Source.UserData.status
                        event.Source.ImageSource = event.Source.UserData.imageSource{1};

                        hObject = plot.draw2D.OrdinaryLine(app.UIAxes1, plotTag, app.bandObj, app.sweepTimeIdx);
                        plot.datatip.Template(hObject, 'Frequency+Level', app.bandObj.LevelUnit)
                        plot.axes.StackingOrder.execute(app.UIAxes1, app.bandObj.Context)
            
                        app.plotHandles.(plotTag) = hObject;

                    else
                        event.Source.ImageSource = event.Source.UserData.imageSource{2};
                        delete(app.plotHandles.(plotTag))
                        app.plotHandles.(plotTag) = [];
                    end

                case app.axesTool_persistence
                    app.axesTool_persistence.UserData.status = ~app.axesTool_persistence.UserData.status;

                    update(specData, 'UserData:PlotDisplayConfig', 'persistence', event.Source.UserData.status)

                    if app.axesTool_persistence.UserData.status
                        updatePersistencePlot(app, 'Creation')
                    else
                        updatePersistencePlot(app, 'Delete')
                    end

                case app.axesTool_occupancy
                    app.axesTool_occupancy.UserData.status = ~app.axesTool_occupancy.UserData.status;

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)

                    update(specData, 'UserData:PlotDisplayConfig', 'occupancy', event.Source.UserData.status)

                    if app.axesTool_occupancy.UserData.status
                        updateOccupancyPlot(app, 'Creation', specData)
                    else
                        updateOccupancyPlot(app, 'Delete', specData)
                    end

                case app.axesTool_waterfall
                    app.axesTool_waterfall.UserData.status = ~app.axesTool_waterfall.UserData.status;

                    plot.axes.Layout.XLabel([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status)
                    plot.axes.Layout.RatioAspect([app.UIAxes1, app.UIAxes2, app.UIAxes3], app.axesTool_occupancy.UserData.status, app.axesTool_waterfall.UserData.status, app.LayoutRatio)

                    update(specData, 'UserData:PlotDisplayConfig', 'waterfall', event.Source.UserData.status)

                    if app.axesTool_waterfall.UserData.status
                        if isempty(app.plotHandles.waterfall)
                            updateWaterfallPlot(app)
                        else
                            updateWaterfallPanel(app)
                        end
                    else
                        updateWaterfallPanel(app)
                    end

                case app.axesTool_DataTip
                    app.axesTool_DataTip.UserData.status = ~app.axesTool_DataTip.UserData.status;
                    if app.axesTool_DataTip.UserData.status
                        app.axesTool_DataTip.ImageSource = 'datatip-filled-20px.png';
                    else
                        app.axesTool_DataTip.ImageSource = 'datatip-20px.png';
                    end

                    plot.axes.Interactivity.DataCursorMode(app.UIAxes3, app.axesTool_DataTip.UserData.status)
            end
            drawnow

        end

        % Value changed function: LayoutRatio, PersistenceColormap, 
        % ...and 7 other components
        function onDisplayPlotConfigChanged(app, event)
            
            specData = app.bandObj.SpecData;
            update(specData, 'UserData:PlotDisplayConfig', event.Source.Tag, event.Value)

            switch event.Source
                case app.LayoutRatio  
                    plot.axes.Layout.Visibility([app.UIAxes1, app.UIAxes2, app.UIAxes3], event.Value, app.bandObj.Context)

                case app.PersistenceInterpolation
                    app.plotHandles.persistence.handle.Interpolation = event.Value;

                case app.PersistenceWindowSize
                    updatePersistencePlot(app, 'Delete')
                    updatePersistencePlot(app, 'Creation')

                case app.PersistenceColormap
                    plot.axes.Colormap(app.UIAxes1, event.Value)

                case app.PersistenceTransparency
                    app.plotHandles.persistence.handle.CData(isnan(app.plotHandles.persistence.handle.CData)) = 0; 
                    app.plotHandles.persistence.handle.AlphaData = double(logical(app.plotHandles.persistence.handle.CData)) * event.Value;

                case { app.WaterfallFunction, app.WaterfallDecimation }
                    [~, ~, XData, YData] = plot.datatip.Search(app.UIAxes3);
                    app.plotHandles.waterfall = plot.Waterfall('Delete', app.plotHandles.waterfall);
                    updateWaterfallPlot(app)

                    if ~isempty(XData)
                        if event.Source == app.WaterfallFunction
                            for ii = 1:numel(YData)
                                switch event.Value
                                    case 'image'
                                        YData{ii} = timestamp2idx(app.bandObj, YData{ii});
                                    case 'mesh'
                                        YData{ii} = idx2timestamp(app.bandObj, YData{ii});
                                end
                            end
                        end

                        dtConfig = struct('XData', XData, 'YData', YData);
                        dtParent = app.plotHandles.waterfall;
                        plot.datatip.Create('redrawWaterfall', dtConfig, dtParent)                        
                    end                    

                case app.WaterfallColormap
                    plot.axes.Colormap(app.UIAxes3, event.Value)

                case app.WaterfallMeshStyle
                    app.plotHandles.waterfall.MeshStyle = event.Value;
            end
            
        end

        % Callback function: LimitsRefresh, LimitsXLim1, LimitsXLim2, 
        % ...and 8 other components
        function onAxesLimitsConfigChanged(app, event)
            
            specData = app.bandObj.SpecData;
            evtValue = [];

            switch event.Source
                case app.LimitsRefresh
                    if ~isempty(specData)
                        xLimits = specData.UserData.PlotDisplayConfig.limits.frequency.initial;
                        yLimits = specData.UserData.PlotDisplayConfig.limits.level.initial;
                    else
                        xLimits = [0, 1];
                        yLimits = [0, 1];
                    end
                    set(app.UIAxes1, 'XLim', xLimits, 'YLim', yLimits)

                case { app.LimitsXLim1, app.LimitsXLim2 }
                    evtValue = [app.LimitsXLim1.Value, app.LimitsXLim2.Value];                    
                    if issorted(evtValue, 'strictascend')
                        app.UIAxes1.XLim = evtValue;
                    else
                        event.Source.Value = event.PreviousValue;
                        return
                    end

                case { app.LimitsYLim1, app.LimitsYLim2 }
                    evtValue = [app.LimitsYLim1.Value, app.LimitsYLim2.Value];
                    if issorted(evtValue, 'strictascend')
                        app.UIAxes1.YLim = evtValue;
                    else
                        event.Source.Value = event.PreviousValue;
                        return
                    end

                case { app.PersistenceCLim1, app.PersistenceCLim2 }
                    evtValue = [app.PersistenceCLim1.Value, app.PersistenceCLim2.Value];
                    if issorted(evtValue, 'strictascend')
                        app.UIAxes1.CLim = evtValue;
                        app.UIAxes1.UserData.CLimMode = 'manual';
                    else
                        event.Source.Value = event.PreviousValue;
                        return
                    end

                case app.PersistenceCLimRefresh
                    app.UIAxes1.CLimMode = 'auto';
                    app.UIAxes1.UserData.CLimMode = 'auto';

                    app.PersistenceCLim1.Value = round(app.UIAxes1.CLim(1), 3);
                    app.PersistenceCLim2.Value = round(app.UIAxes1.CLim(2), 3);

                case { app.WaterfallCLim1, app.WaterfallCLim2 }
                    evtValue = [app.WaterfallCLim1.Value, app.WaterfallCLim2.Value];
                    if issorted(evtValue, 'strictascend')
                        app.UIAxes3.CLim = evtValue;
                        app.UIAxes3.UserData.CLimMode = 'manual';
                    else
                        event.Source.Value = event.PreviousValue;
                        return
                    end

                case app.WaterfallCLimRefresh
                    app.UIAxes3.CLim = specData.UserData.PlotDisplayConfig.limits.waterfall.initial;
                    app.UIAxes3.UserData.CLimMode = 'auto';

                    app.WaterfallCLim1.Value = round(app.UIAxes3.CLim(1));
                    app.WaterfallCLim2.Value = round(app.UIAxes3.CLim(2));
            end

            if ~isempty(specData)
                update(specData, 'UserData:PlotDisplayConfig', event.Source.Tag, evtValue)
                updateSpectrumInfo(app.bandObj, specData);
                resetRestoreView(app)
            end
            checkAxesLimitsCustomizations(app)
            
        end

        % Image clicked function: tool_LayoutLeft, tool_LayoutRight
        function tool_PanelVisibilityButtonPushed(app, event)
            
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

        % Callback function: tool_TimestampSlider, tool_TimestampSlider
        function tool_TimestampSliderValueChanged(app, event)
            
            nSweeps = app.bandObj.NumSweeps;            
            app.sweepTimeIdx = round(event.Value/100 * nSweeps);
            
            if app.sweepTimeIdx < 1
                app.sweepTimeIdx = 1;
            elseif app.sweepTimeIdx > nSweeps
                app.sweepTimeIdx = nSweeps;
            end

            if ~app.plotUpdateEvent
                if ~app.plotHandles.clearWrite.Visible
                    app.plotHandles.clearWrite.Visible = true;
                end
                app.plotHandles.clearWrite.YData = app.bandObj.SpecData.Data{2}(:, app.sweepTimeIdx)';
    
                % for ii = 1:numel(app.hEmissionMarkers)
                %     app.hEmissionMarkers(ii).Position(2) = app.hClearWrite.YData(app.hClearWrite.MarkerIndices(ii));
                % end
                
                updatePersistencePlot(app, 'Update')

                if app.axesTool_waterfall.UserData.status && ~isempty(app.plotHandles.waterfallTime)
                    plot.draw2D.OrdinaryLineUpdate('waterfallTime', app.plotHandles.waterfallTime, app.bandObj, app.sweepTimeIdx);
                end

                app.tool_TimestampLabel.Text = sprintf('%d de %d\n%s', app.sweepTimeIdx, nSweeps, app.bandObj.SpecData.Data{1}(app.sweepTimeIdx));
            end
            
        end

        % Image clicked function: tool_LoopControl, tool_Play
        function tool_PlaybackControlButtonPushed(app, event)
            
            switch event.Source
                case app.tool_Play
                    idx = findSpecDataIndex(app);

                    if ~isempty(idx) && ~app.plotUpdateEvent
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onPlaybackStarted')

                        app.plotUpdateEvent = 1;
                        runPlaybackLoop(app, idx, numel(app.mainApp.specData(idx).Data{1}))        
                    else
                        app.plotUpdateEvent = 0;
                    end

                %---------------------------------------------------------%
                case app.tool_LoopControl
                     app.tool_LoopControl.UserData.loopMode = ~ app.tool_LoopControl.UserData.loopMode;

                     if app.tool_LoopControl.UserData.loopMode
                         app.tool_LoopControl.ImageSource = 'playback-loop-36px-gray.png';
                     else
                         app.tool_LoopControl.ImageSource = 'playback-straight-36px-gray.png';
                    end
            end

        end

        % Image clicked function: FlowChannelEdit, 
        % ...and 2 other components
        function openPopupApp(app, event)
            
            switch event.Source
                case app.FlowDetectionLimitsEdit
                    ipcMainMatlabOpenPopupApp(app.mainApp, app, 'DetectionLimits', app.Context)
                case app.FlowEmissionsAdd
                    ipcMainMatlabOpenPopupApp(app.mainApp, app, 'Detection', app.Context)
                case app.FlowChannelEdit
                    ipcMainMatlabOpenPopupApp(app.mainApp, app, 'Channels', app.Context)
            end

        end

        % Image clicked function: axesTool_FlowInfo
        function axesTool_FlowInfoImageClicked(app, event)
            
            specData = app.bandObj.SpecData;
            
            if ~isempty(specData)
                flowAnalysis = util.HtmlTextGenerator.ThreadAnalysis(specData);
                ui.Dialog(app.UIFigure, 'info', flowAnalysis);
            end

        end

        % Double-clicked callback: FlowOccupancy
        function FlowOccupancyDoubleClicked(app, event)
            
            specData = app.bandObj.SpecData;
            item = event.InteractionInformation.Item
            
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
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];

            % Create tool_LayoutLeft
            app.tool_LayoutLeft = uiimage(app.Toolbar);
            app.tool_LayoutLeft.ScaleMethod = 'none';
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @tool_PanelVisibilityButtonPushed, true);
            app.tool_LayoutLeft.Layout.Row = [1 3];
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Play
            app.tool_Play = uiimage(app.Toolbar);
            app.tool_Play.ScaleMethod = 'none';
            app.tool_Play.ImageClickedFcn = createCallbackFcn(app, @tool_PlaybackControlButtonPushed, true);
            app.tool_Play.Enable = 'off';
            app.tool_Play.Layout.Row = [1 3];
            app.tool_Play.Layout.Column = 2;
            app.tool_Play.ImageSource = 'playback-play-16px-gray.png';

            % Create tool_LoopControl
            app.tool_LoopControl = uiimage(app.Toolbar);
            app.tool_LoopControl.ImageClickedFcn = createCallbackFcn(app, @tool_PlaybackControlButtonPushed, true);
            app.tool_LoopControl.Enable = 'off';
            app.tool_LoopControl.Layout.Row = [1 3];
            app.tool_LoopControl.Layout.Column = 3;
            app.tool_LoopControl.ImageSource = 'playback-loop-36px-gray.png';

            % Create tool_TimestampSlider
            app.tool_TimestampSlider = uislider(app.Toolbar);
            app.tool_TimestampSlider.MajorTicks = [0 50 100];
            app.tool_TimestampSlider.ValueChangedFcn = createCallbackFcn(app, @tool_TimestampSliderValueChanged, true);
            app.tool_TimestampSlider.ValueChangingFcn = createCallbackFcn(app, @tool_TimestampSliderValueChanged, true);
            app.tool_TimestampSlider.MinorTicks = [0 2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30 32.5 35 37.5 40 42.5 45 47.5 50 52.5 55 57.5 60 62.5 65 67.5 70 72.5 75 77.5 80 82.5 85 87.5 90 92.5 95 97.5 100];
            app.tool_TimestampSlider.FontSize = 8;
            app.tool_TimestampSlider.Enable = 'off';
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
            app.tool_LayoutRight.ImageClickedFcn = createCallbackFcn(app, @tool_PanelVisibilityButtonPushed, true);
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
            app.Document.ColumnWidth = {320, 10, 5, 271, '1x', 5, 10, 232};
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
            app.AxesToolbar.ColumnWidth = {'1x', 22, 22, 5, 22, 22, 22, 22, 22, 5, 22, 5, 22, 22, 5, 22, '1x'};
            app.AxesToolbar.RowHeight = {'1x'};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [0 2 0 1];
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
            app.axesTool_Pan.ImageSource = 'pan-32px.png';

            % Create axesTool_Separator1
            app.axesTool_Separator1 = uiimage(app.AxesToolbar);
            app.axesTool_Separator1.ScaleMethod = 'none';
            app.axesTool_Separator1.Enable = 'off';
            app.axesTool_Separator1.Layout.Row = 1;
            app.axesTool_Separator1.Layout.Column = 4;
            app.axesTool_Separator1.ImageSource = 'LineV.svg';

            % Create axesTool_crearWrite
            app.axesTool_crearWrite = uiimage(app.AxesToolbar);
            app.axesTool_crearWrite.ScaleMethod = 'none';
            app.axesTool_crearWrite.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_crearWrite.Tag = 'minHold';
            app.axesTool_crearWrite.Enable = 'off';
            app.axesTool_crearWrite.Layout.Row = 1;
            app.axesTool_crearWrite.Layout.Column = 5;
            app.axesTool_crearWrite.ImageSource = 'eye-closed-16px.svg';

            % Create axesTool_minHold
            app.axesTool_minHold = uiimage(app.AxesToolbar);
            app.axesTool_minHold.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_minHold.Tag = 'minHold';
            app.axesTool_minHold.Enable = 'off';
            app.axesTool_minHold.Layout.Row = 1;
            app.axesTool_minHold.Layout.Column = 6;
            app.axesTool_minHold.ImageSource = 'MinHold_32.png';

            % Create axesTool_average
            app.axesTool_average = uiimage(app.AxesToolbar);
            app.axesTool_average.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_average.Tag = 'average';
            app.axesTool_average.Enable = 'off';
            app.axesTool_average.Layout.Row = 1;
            app.axesTool_average.Layout.Column = 7;
            app.axesTool_average.ImageSource = 'Average_32.png';

            % Create axesTool_maxHold
            app.axesTool_maxHold = uiimage(app.AxesToolbar);
            app.axesTool_maxHold.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_maxHold.Tag = 'maxHold';
            app.axesTool_maxHold.Enable = 'off';
            app.axesTool_maxHold.Layout.Row = 1;
            app.axesTool_maxHold.Layout.Column = 8;
            app.axesTool_maxHold.ImageSource = 'MaxHold_32.png';

            % Create axesTool_persistence
            app.axesTool_persistence = uiimage(app.AxesToolbar);
            app.axesTool_persistence.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_persistence.Tag = 'persistence';
            app.axesTool_persistence.Enable = 'off';
            app.axesTool_persistence.Layout.Row = 1;
            app.axesTool_persistence.Layout.Column = 9;
            app.axesTool_persistence.ImageSource = 'persistence-36px.png';

            % Create axesTool_Separator2
            app.axesTool_Separator2 = uiimage(app.AxesToolbar);
            app.axesTool_Separator2.ScaleMethod = 'none';
            app.axesTool_Separator2.Enable = 'off';
            app.axesTool_Separator2.Layout.Row = 1;
            app.axesTool_Separator2.Layout.Column = 10;
            app.axesTool_Separator2.ImageSource = 'LineV.svg';

            % Create axesTool_occupancy
            app.axesTool_occupancy = uiimage(app.AxesToolbar);
            app.axesTool_occupancy.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_occupancy.Tag = 'occupancy';
            app.axesTool_occupancy.Enable = 'off';
            app.axesTool_occupancy.Layout.Row = 1;
            app.axesTool_occupancy.Layout.Column = 11;
            app.axesTool_occupancy.ImageSource = 'Occupancy_32.png';

            % Create axesTool_Separator3
            app.axesTool_Separator3 = uiimage(app.AxesToolbar);
            app.axesTool_Separator3.ScaleMethod = 'none';
            app.axesTool_Separator3.Enable = 'off';
            app.axesTool_Separator3.Layout.Row = 1;
            app.axesTool_Separator3.Layout.Column = 12;
            app.axesTool_Separator3.ImageSource = 'LineV.svg';

            % Create axesTool_waterfall
            app.axesTool_waterfall = uiimage(app.AxesToolbar);
            app.axesTool_waterfall.ScaleMethod = 'none';
            app.axesTool_waterfall.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_waterfall.Tag = 'waterfall';
            app.axesTool_waterfall.Enable = 'off';
            app.axesTool_waterfall.Layout.Row = 1;
            app.axesTool_waterfall.Layout.Column = 13;
            app.axesTool_waterfall.ImageSource = 'waterfall-22px.png';

            % Create axesTool_DataTip
            app.axesTool_DataTip = uiimage(app.AxesToolbar);
            app.axesTool_DataTip.ScaleMethod = 'none';
            app.axesTool_DataTip.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_DataTip.Enable = 'off';
            app.axesTool_DataTip.Layout.Row = 1;
            app.axesTool_DataTip.Layout.Column = 14;
            app.axesTool_DataTip.ImageSource = 'datatip-20px.png';

            % Create axesTool_Separator3_2
            app.axesTool_Separator3_2 = uiimage(app.AxesToolbar);
            app.axesTool_Separator3_2.ScaleMethod = 'none';
            app.axesTool_Separator3_2.Enable = 'off';
            app.axesTool_Separator3_2.Layout.Row = 1;
            app.axesTool_Separator3_2.Layout.Column = 15;
            app.axesTool_Separator3_2.ImageSource = 'LineV.svg';

            % Create axesTool_FlowInfo
            app.axesTool_FlowInfo = uiimage(app.AxesToolbar);
            app.axesTool_FlowInfo.ImageClickedFcn = createCallbackFcn(app, @axesTool_FlowInfoImageClicked, true);
            app.axesTool_FlowInfo.Enable = 'off';
            app.axesTool_FlowInfo.Layout.Row = 1;
            app.axesTool_FlowInfo.Layout.Column = 16;
            app.axesTool_FlowInfo.ImageSource = 'Info_32.png';

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
            app.SpectrumFlowList.ValueChangedFcn = createCallbackFcn(app, @onFlowDropDownValueChanged, true);
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
            app.FlowAttributesPanelLeftBtn.ImageClickedFcn = createCallbackFcn(app, @onFlowPanelViewChanged, true);
            app.FlowAttributesPanelLeftBtn.Enable = 'off';
            app.FlowAttributesPanelLeftBtn.Layout.Row = 2;
            app.FlowAttributesPanelLeftBtn.Layout.Column = 2;
            app.FlowAttributesPanelLeftBtn.ImageSource = 'triangle-left.svg';

            % Create FlowAttributesPanelRightBtn
            app.FlowAttributesPanelRightBtn = uiimage(app.LeftPanel);
            app.FlowAttributesPanelRightBtn.ImageClickedFcn = createCallbackFcn(app, @onFlowPanelViewChanged, true);
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
            app.FlowPanelGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.FlowPanelGrid.RowHeight = {5, 22, 5, '1x', 5, 22, 5, '1x', 10};
            app.FlowPanelGrid.ColumnSpacing = 0;
            app.FlowPanelGrid.RowSpacing = 0;
            app.FlowPanelGrid.Padding = [0 0 0 0];
            app.FlowPanelGrid.BackgroundColor = [1 1 1];

            % Create FlowMetadata
            app.FlowMetadata = uilabel(app.FlowPanelGrid);
            app.FlowMetadata.VerticalAlignment = 'top';
            app.FlowMetadata.WordWrap = 'on';
            app.FlowMetadata.FontSize = 11;
            app.FlowMetadata.Layout.Row = [1 9];
            app.FlowMetadata.Layout.Column = 1;
            app.FlowMetadata.Interpreter = 'html';
            app.FlowMetadata.Text = '';

            % Create FlowChannelLabel
            app.FlowChannelLabel = uilabel(app.FlowPanelGrid);
            app.FlowChannelLabel.VerticalAlignment = 'bottom';
            app.FlowChannelLabel.FontSize = 10;
            app.FlowChannelLabel.Layout.Row = 2;
            app.FlowChannelLabel.Layout.Column = 3;
            app.FlowChannelLabel.Text = 'CANAIS';

            % Create FlowChannelEdit
            app.FlowChannelEdit = uiimage(app.FlowPanelGrid);
            app.FlowChannelEdit.ImageClickedFcn = createCallbackFcn(app, @openPopupApp, true);
            app.FlowChannelEdit.Enable = 'off';
            app.FlowChannelEdit.Layout.Row = 2;
            app.FlowChannelEdit.Layout.Column = 4;
            app.FlowChannelEdit.VerticalAlignment = 'bottom';
            app.FlowChannelEdit.ImageSource = 'Edit_32.png';

            % Create FlowChannel
            app.FlowChannel = uilistbox(app.FlowPanelGrid);
            app.FlowChannel.Items = {};
            app.FlowChannel.FontSize = 11;
            app.FlowChannel.Layout.Row = 4;
            app.FlowChannel.Layout.Column = [3 4];
            app.FlowChannel.Value = {};

            % Create FlowDetectionLabel
            app.FlowDetectionLabel = uilabel(app.FlowPanelGrid);
            app.FlowDetectionLabel.VerticalAlignment = 'bottom';
            app.FlowDetectionLabel.FontSize = 10;
            app.FlowDetectionLabel.Layout.Row = 6;
            app.FlowDetectionLabel.Layout.Column = 3;
            app.FlowDetectionLabel.Text = 'LIMITES DE DETECÇÃO';

            % Create FlowDetectionLimitsEdit
            app.FlowDetectionLimitsEdit = uiimage(app.FlowPanelGrid);
            app.FlowDetectionLimitsEdit.ImageClickedFcn = createCallbackFcn(app, @openPopupApp, true);
            app.FlowDetectionLimitsEdit.Enable = 'off';
            app.FlowDetectionLimitsEdit.Layout.Row = 6;
            app.FlowDetectionLimitsEdit.Layout.Column = 4;
            app.FlowDetectionLimitsEdit.VerticalAlignment = 'bottom';
            app.FlowDetectionLimitsEdit.ImageSource = 'Edit_32.png';

            % Create FlowDetectionLimits
            app.FlowDetectionLimits = uilistbox(app.FlowPanelGrid);
            app.FlowDetectionLimits.Items = {};
            app.FlowDetectionLimits.FontSize = 11;
            app.FlowDetectionLimits.Layout.Row = 8;
            app.FlowDetectionLimits.Layout.Column = [3 4];
            app.FlowDetectionLimits.Value = {};

            % Create FlowEmissionsLabel
            app.FlowEmissionsLabel = uilabel(app.FlowPanelGrid);
            app.FlowEmissionsLabel.VerticalAlignment = 'bottom';
            app.FlowEmissionsLabel.FontSize = 10;
            app.FlowEmissionsLabel.Layout.Row = 2;
            app.FlowEmissionsLabel.Layout.Column = 6;
            app.FlowEmissionsLabel.Text = 'EMISSÕES';

            % Create FlowEmissionsAdd
            app.FlowEmissionsAdd = uiimage(app.FlowPanelGrid);
            app.FlowEmissionsAdd.ScaleMethod = 'none';
            app.FlowEmissionsAdd.ImageClickedFcn = createCallbackFcn(app, @openPopupApp, true);
            app.FlowEmissionsAdd.Enable = 'off';
            app.FlowEmissionsAdd.Layout.Row = 2;
            app.FlowEmissionsAdd.Layout.Column = 7;
            app.FlowEmissionsAdd.VerticalAlignment = 'bottom';
            app.FlowEmissionsAdd.ImageSource = 'search-sparkle.svg';

            % Create FlowEmissions
            app.FlowEmissions = uitable(app.FlowPanelGrid);
            app.FlowEmissions.ColumnName = {'#'; 'FREQUÊNCIA|(MHz)'; 'LARGURA|(kHz)'; 'INFORMAÇÕES|ADICIONAIS'};
            app.FlowEmissions.ColumnWidth = {20, 70, 70, 'auto'};
            app.FlowEmissions.RowName = {};
            app.FlowEmissions.SelectionType = 'row';
            app.FlowEmissions.ColumnEditable = [false true true true];
            app.FlowEmissions.Visible = 'off';
            app.FlowEmissions.Layout.Row = [4 8];
            app.FlowEmissions.Layout.Column = [6 7];
            app.FlowEmissions.FontSize = 11;

            % Create FlowOccupancyLabel
            app.FlowOccupancyLabel = uilabel(app.FlowPanelGrid);
            app.FlowOccupancyLabel.VerticalAlignment = 'bottom';
            app.FlowOccupancyLabel.FontSize = 10;
            app.FlowOccupancyLabel.Layout.Row = 2;
            app.FlowOccupancyLabel.Layout.Column = 9;
            app.FlowOccupancyLabel.Text = 'OCUPAÇÃO';

            % Create FlowOccupancyEdit
            app.FlowOccupancyEdit = uiimage(app.FlowPanelGrid);
            app.FlowOccupancyEdit.Enable = 'off';
            app.FlowOccupancyEdit.Layout.Row = 2;
            app.FlowOccupancyEdit.Layout.Column = 10;
            app.FlowOccupancyEdit.VerticalAlignment = 'bottom';
            app.FlowOccupancyEdit.ImageSource = 'Edit_32.png';

            % Create FlowOccupancy
            app.FlowOccupancy = uilistbox(app.FlowPanelGrid);
            app.FlowOccupancy.Items = {};
            app.FlowOccupancy.FontSize = 11;
            app.FlowOccupancy.Layout.Row = [4 8];
            app.FlowOccupancy.Layout.Column = [9 10];
            app.FlowOccupancy.DoubleClickedFcn = createCallbackFcn(app, @FlowOccupancyDoubleClicked, true);
            app.FlowOccupancy.Value = {};

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
            app.LayoutRatio.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.LayoutRatio.Tag = 'layoutRatio';
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
            app.LimitsRefresh.ImageClickedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.LimitsRefresh.Tag = 'limitsXYRefresh';
            app.LimitsRefresh.Visible = 'off';
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
            app.LimitsXLim1.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.LimitsXLim1.Tag = 'limitsX';
            app.LimitsXLim1.FontSize = 11;
            app.LimitsXLim1.Layout.Row = 3;
            app.LimitsXLim1.Layout.Column = 1;

            % Create LimitsXLim2
            app.LimitsXLim2 = uispinner(app.GeneralPanelGrid);
            app.LimitsXLim2.ValueDisplayFormat = '%.3f';
            app.LimitsXLim2.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.LimitsXLim2.Tag = 'limitsX';
            app.LimitsXLim2.FontSize = 11;
            app.LimitsXLim2.Layout.Row = 3;
            app.LimitsXLim2.Layout.Column = [4 5];
            app.LimitsXLim2.Value = 1;

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
            app.LimitsYLim1.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.LimitsYLim1.Tag = 'limitsY';
            app.LimitsYLim1.FontSize = 11;
            app.LimitsYLim1.Layout.Row = 4;
            app.LimitsYLim1.Layout.Column = 1;

            % Create LimitsYLim2
            app.LimitsYLim2 = uispinner(app.GeneralPanelGrid);
            app.LimitsYLim2.Step = 5;
            app.LimitsYLim2.ValueDisplayFormat = '%.1f';
            app.LimitsYLim2.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.LimitsYLim2.Tag = 'limitsY';
            app.LimitsYLim2.FontSize = 11;
            app.LimitsYLim2.Layout.Row = 4;
            app.LimitsYLim2.Layout.Column = [4 5];
            app.LimitsYLim2.Value = 1;

            % Create PersistencePanelIcon
            app.PersistencePanelIcon = uiimage(app.RightPanel);
            app.PersistencePanelIcon.Layout.Row = [6 7];
            app.PersistencePanelIcon.Layout.Column = 1;
            app.PersistencePanelIcon.VerticalAlignment = 'bottom';
            app.PersistencePanelIcon.ImageSource = 'persistence-36px.png';

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
            app.PersistenceInterpolation.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.PersistenceInterpolation.Tag = 'persistenceInterpolation';
            app.PersistenceInterpolation.Enable = 'off';
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
            app.PersistenceWindowSize.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.PersistenceWindowSize.Tag = 'persistenceWindowSize';
            app.PersistenceWindowSize.Enable = 'off';
            app.PersistenceWindowSize.FontSize = 11;
            app.PersistenceWindowSize.BackgroundColor = [1 1 1];
            app.PersistenceWindowSize.Layout.Row = 2;
            app.PersistenceWindowSize.Layout.Column = [3 5];
            app.PersistenceWindowSize.Value = 'full';

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
            app.PersistenceColormap.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.PersistenceColormap.Tag = 'persistenceColormap';
            app.PersistenceColormap.Enable = 'off';
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
            app.PersistenceTransparency.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.PersistenceTransparency.Tag = 'persistenceTransparency';
            app.PersistenceTransparency.FontSize = 11;
            app.PersistenceTransparency.Enable = 'off';
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
            app.PersistenceCLimRefresh.ImageClickedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.PersistenceCLimRefresh.Tag = 'limitsPersistenceRefresh';
            app.PersistenceCLimRefresh.Visible = 'off';
            app.PersistenceCLimRefresh.Layout.Row = 5;
            app.PersistenceCLimRefresh.Layout.Column = 5;
            app.PersistenceCLimRefresh.ImageSource = 'Refresh_18.png';

            % Create PersistenceCLim1
            app.PersistenceCLim1 = uispinner(app.PersistencePanelGrid);
            app.PersistenceCLim1.Step = 0.1;
            app.PersistenceCLim1.Limits = [0 Inf];
            app.PersistenceCLim1.ValueDisplayFormat = '%.3f';
            app.PersistenceCLim1.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.PersistenceCLim1.Tag = 'limitsPersistence';
            app.PersistenceCLim1.FontSize = 11;
            app.PersistenceCLim1.Enable = 'off';
            app.PersistenceCLim1.Layout.Row = 6;
            app.PersistenceCLim1.Layout.Column = [1 2];
            app.PersistenceCLim1.Value = 0.1;

            % Create PersistenceCLim2
            app.PersistenceCLim2 = uispinner(app.PersistencePanelGrid);
            app.PersistenceCLim2.Limits = [0 Inf];
            app.PersistenceCLim2.ValueDisplayFormat = '%.3f';
            app.PersistenceCLim2.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.PersistenceCLim2.Tag = 'limitsPersistence';
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
            app.WaterfallPanelIcon.ImageSource = 'waterfall-22px.png';

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

            % Create WaterfallFunctionLabel
            app.WaterfallFunctionLabel = uilabel(app.WaterfallPanelGrid);
            app.WaterfallFunctionLabel.VerticalAlignment = 'bottom';
            app.WaterfallFunctionLabel.WordWrap = 'on';
            app.WaterfallFunctionLabel.FontSize = 11;
            app.WaterfallFunctionLabel.Layout.Row = 1;
            app.WaterfallFunctionLabel.Layout.Column = [1 3];
            app.WaterfallFunctionLabel.Text = 'Renderização:';

            % Create WaterfallFunction
            app.WaterfallFunction = uidropdown(app.WaterfallPanelGrid);
            app.WaterfallFunction.Items = {'image', 'mesh'};
            app.WaterfallFunction.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.WaterfallFunction.Tag = 'waterfallFunction';
            app.WaterfallFunction.Enable = 'off';
            app.WaterfallFunction.FontSize = 11;
            app.WaterfallFunction.BackgroundColor = [1 1 1];
            app.WaterfallFunction.Layout.Row = 2;
            app.WaterfallFunction.Layout.Column = [1 2];
            app.WaterfallFunction.Value = 'image';

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
            app.WaterfallDecimation.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.WaterfallDecimation.Tag = 'waterfallDecimation';
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
            app.WaterfallColormap.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.WaterfallColormap.Tag = 'waterfallColormap';
            app.WaterfallColormap.Enable = 'off';
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
            app.WaterfallMeshStyle.ValueChangedFcn = createCallbackFcn(app, @onDisplayPlotConfigChanged, true);
            app.WaterfallMeshStyle.Tag = 'waterfallMeshStyle';
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
            app.WaterfallCLimRefresh.ImageClickedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.WaterfallCLimRefresh.Tag = 'limitsWaterfallRefresh';
            app.WaterfallCLimRefresh.Visible = 'off';
            app.WaterfallCLimRefresh.Layout.Row = 5;
            app.WaterfallCLimRefresh.Layout.Column = 5;
            app.WaterfallCLimRefresh.ImageSource = 'Refresh_18.png';

            % Create WaterfallCLim1
            app.WaterfallCLim1 = uispinner(app.WaterfallPanelGrid);
            app.WaterfallCLim1.Step = 5;
            app.WaterfallCLim1.RoundFractionalValues = 'on';
            app.WaterfallCLim1.ValueDisplayFormat = '%.0f';
            app.WaterfallCLim1.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.WaterfallCLim1.Tag = 'limitsWaterfall';
            app.WaterfallCLim1.FontSize = 11;
            app.WaterfallCLim1.Enable = 'off';
            app.WaterfallCLim1.Layout.Row = 6;
            app.WaterfallCLim1.Layout.Column = [1 2];

            % Create WaterfallCLim2
            app.WaterfallCLim2 = uispinner(app.WaterfallPanelGrid);
            app.WaterfallCLim2.Step = 5;
            app.WaterfallCLim2.RoundFractionalValues = 'on';
            app.WaterfallCLim2.ValueDisplayFormat = '%.0f';
            app.WaterfallCLim2.ValueChangedFcn = createCallbackFcn(app, @onAxesLimitsConfigChanged, true);
            app.WaterfallCLim2.Tag = 'limitsWaterfall';
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
        function app = winMiscellaneous_exported(Container, varargin)

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
