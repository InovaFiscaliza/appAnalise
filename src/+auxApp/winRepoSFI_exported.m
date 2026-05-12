classdef winRepoSFI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        DockModule                    matlab.ui.container.GridLayout
        dockModule_Close              matlab.ui.control.Image
        dockModule_Undock             matlab.ui.control.Image
        SubTabGroup                   matlab.ui.container.TabGroup
        FilesTab                      matlab.ui.container.Tab
        FilesMainGrid                 matlab.ui.container.GridLayout
        GridLayout2                   matlab.ui.container.GridLayout
        filesCleanButton              matlab.ui.control.Button
        filesSearchButton             matlab.ui.control.Button
        filesStationLabel             matlab.ui.control.Label
        filesSensorLocationLabel      matlab.ui.container.Panel
        filesSensorLocationGrid       matlab.ui.container.GridLayout
        filesStationDropDown          matlab.ui.control.DropDown
        filesLocationDropDown         matlab.ui.control.DropDown
        filesLocationLabel            matlab.ui.control.Label
        filesSensorLabel              matlab.ui.control.Label
        filesFrequencyPanel           matlab.ui.container.Panel
        filesFrequencyGrid            matlab.ui.container.GridLayout
        filesFrequencyStartLabel      matlab.ui.control.Label
        filesFrequencyEndEditField    matlab.ui.control.NumericEditField
        filesFrequencyStartEditField  matlab.ui.control.NumericEditField
        filesFrequencyEndLabel        matlab.ui.control.Label
        filesPeriodPanel              matlab.ui.container.Panel
        filesPeriodGrid               matlab.ui.container.GridLayout
        filesEndDatePicker            matlab.ui.control.DatePicker
        filesStartDatePicker          matlab.ui.control.DatePicker
        filesEndDateLabel             matlab.ui.control.Label
        filesStartDateLabel           matlab.ui.control.Label
        filesLocationSelectLabel      matlab.ui.control.Label
        filesCountLabel               matlab.ui.control.Label
        filesStationFilterPanel       matlab.ui.container.Panel
        filesStationsGrid             matlab.ui.container.GridLayout
        filesLocalityDropDown         matlab.ui.control.DropDown
        filesStatusDropDown           matlab.ui.control.DropDown
        filesStateDropDown            matlab.ui.control.DropDown
        filesLocalityLabel            matlab.ui.control.Label
        filesStatusLabel              matlab.ui.control.Label
        filesStateLabel               matlab.ui.control.Label
        filesDescriptionEditField     matlab.ui.control.EditField
        filesDescriptionLabel         matlab.ui.control.Label
        filesFrequencyLabel           matlab.ui.control.Label
        filesPeriodLabel              matlab.ui.control.Label
        filesTitleGrid                matlab.ui.container.GridLayout
        referenceRX_Label_3           matlab.ui.control.Label
        referenceRX_Icon_3            matlab.ui.control.Image
        Document                      matlab.ui.container.GridLayout
        popupHTML                     matlab.ui.control.Label
        AxesToolbar                   matlab.ui.container.GridLayout
        configMapStyleDropDown        matlab.ui.control.DropDown
        axesTool_RestoreView          matlab.ui.control.Image
        axesTool_RegionZoom           matlab.ui.control.Image
        plotPanel                     matlab.ui.container.Panel
        Toolbar                       matlab.ui.container.GridLayout
        tool_tableNRowsIcon           matlab.ui.control.Image
        tool_ExportButton             matlab.ui.control.Image
        tool_Separator2               matlab.ui.control.Image
        tool_PDFButton                matlab.ui.control.Image
        tool_RFLinkButton             matlab.ui.control.Image
        tool_TableVisibility          matlab.ui.control.Image
        tool_Separator1               matlab.ui.control.Image
        tool_PanelVisibility          matlab.ui.control.Image
        ContextMenu                   matlab.ui.container.ContextMenu
        contextmenu_del               matlab.ui.container.Menu
        contextmenu_delAll            matlab.ui.container.Menu
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'REPOSFI'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
        popupContainer

        repoSFI
        filteredRepoSFI = struct('points', struct([]), 'site_details', struct([]))
        UIAxes
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
            )

        % Contexto do último clique no mapa (usado para abrir dock com filtro)
        currentSiteContext

        dbHandler
        filesLocalityRows = table()
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'repoSFI.openDock'
                        payload = event.HTMLEventData;

                        siteId = str2double(string(payload.siteId));
                        equipmentId = str2double(string(payload.equipmentId));
                        hostId = str2double(string(payload.hostId));

                        openRepoFilesDockForStation(app, siteId, equipmentId, hostId)

                    case 'repoSFI.mapBackgroundClick'
                        closePopup(app);

                    case 'repoSFI.closePopup'
                        closePopup(app);


                    otherwise
                        error('auxApp:winRFDataHub:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
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
                        operationType = varargin{1};

                        switch operationType
                            case 'onRepoSFIUpdate'
                                closeFcn(app)

                            otherwise
                                error('auxApp:winRFDataHub:UnexpectedCall', 'Unexpected call "%s"', operationType)
                        end

                    otherwise
                        error('auxApp:winRFDataHub:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            % Applies JavaScript customizations to the unified search panel.
            % Previously tracked per-tab initialization; now applies setup for the
            % single FilterTab only.

            appName = class(app);
            elToModify = {
                app.AxesToolbar;
                app.tool_PanelVisibility;
                app.tool_TableVisibility;
                app.tool_RFLinkButton;
                app.tool_PDFButton;
                app.tool_ExportButton;
                app.dockModule_Undock;
                app.dockModule_Close;
                app.popupHTML
                };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                ui.TextView.startup(app.jsBackDoor, app.popupHTML, appName, struct('class', {{'textview--borderless', 'textview--wordbreak', 'textview--no-scroll'}}));
            catch ME
                disp(ME.identifier);
            end
            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                    struct('appName', appName, 'dataTag', app.tool_PanelVisibility.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel')), ...
                    struct('appName', appName, 'dataTag', app.tool_TableVisibility.UserData.id,       'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna entre três layouts do conjunto plot+tabela<br>(apenas plot, apenas tabela ou plot+tabela)')), ...
                    struct('appName', appName, 'dataTag', app.tool_RFLinkButton.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Apresenta perfil de terreno entre registro selecionado (TX)<br>e estação de referência (RX)')), ...
                    struct('appName', appName, 'dataTag', app.tool_PDFButton.UserData.id,             'tooltip', struct('defaultPosition', 'top',    'textContent', 'Apresenta documento gerado pelo Mosaico (limitado à radiodifusão)')), ...
                    struct('appName', appName, 'dataTag', app.tool_ExportButton.UserData.id,          'tooltip', struct('defaultPosition', 'top',    'textContent', 'Exporta planilha filtrada (.xlsx)')), ...
                    struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id,          'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                    struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id,           'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                    });
            catch
            end
        end

        %-----------------------------------------------------------------%
        % Funções obrigatórias pro funcionamento do app Secundário
        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRepoSFI(app)
        end

        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            % Controles de toolbar inferior
            app.tool_TableVisibility.UserData.layout    = 1;
            app.tool_RFLinkButton.UserData.status       = false;
            app.tool_PDFButton.UserData.status          = false;

            % Incializa geoaxes - mapa grafico
            startup_AxesCreation(app)
        end

        function applyInitialLayout(app)
            populateStationFilters(app)
            initializeFilesSearchPanel(app)
            refreshFilteredMap(app)
            restoreMapView(app)
        end
    end



    methods (Access = private)
        %-----------------------------------------------------------------%
        % Funções de Inicialização
        %-----------------------------------------------------------------%


        function initializeRepoSFI(app)
            % Carrega o objeto dbHandler responsável pela leitura dos dados
            % do banco resumo
            if isempty(app.dbHandler)
                app.dbHandler = util.DBHandler();
            end

            data = app.dbHandler.getMapDataSet();

            if isstruct(data) && isfield(data, 'points')
                app.repoSFI = data;
            else
                app.repoSFI = struct('points', struct([]), 'site_details', struct([]));
            end
        end

        function populateStationFilters(app)
            % Preenche o filtro de estados com base nos pontos disponíveis.

            if isempty(app.filesStateDropDown) || isempty(app.repoSFI)
                return
            end

            points = app.repoSFI.points;
            states = [points.state_code];
            statesUnique = unique(states);

            app.filesStateDropDown.Items = [{'Todos os estados'}, statesUnique];

        end

        %-----------------------------------------------------------------%
        % Funções de manipulação do mapa
        %-----------------------------------------------------------------%
        function startup_AxesCreation(app)
            % Recria o geoaxes no painel e reinstala as interações padrão.
            if isempty(app.plotPanel) || ~isvalid(app.plotPanel)
                return
            end

            delete(app.plotPanel.Children)
            app.plotPanel.Visible = 'on';

            hParent = tiledlayout(app.plotPanel, 1, 1, "Padding", "none", "TileSpacing", "none");

            initialBasemap = 'streets-light';
            if ~isempty(app.configMapStyleDropDown) && isvalid(app.configMapStyleDropDown)
                initialBasemap = char(string(app.configMapStyleDropDown.Value));
            end

            % Esta etapa recebe o estilo do mapa obtido no DropDown da Aba
            % CONFIG
            app.UIAxes = plot.axes.Creation(hParent, 'Geographic', {'Basemap', initialBasemap, ...
                'Color', [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                'UserData', struct('CLimMode', 'auto', 'Colormap', '')});

            set(app.UIAxes.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            geolimits(app.UIAxes, 'auto')
            plot.axes.Colormap(app.UIAxes, 'turbo')

            plot.axes.Interactivity.DefaultCreation(app.UIAxes, ...
                [zoomInteraction, panInteraction])
        end

        function applySelectedMapStyle(app)
            % Aplica ao geoaxes o estilo de mapa atualmente selecionado na aba
            % de configuração.
            %
            % A função tenta primeiro o caminho preferencial via geobasemap e,
            % se isso falhar, usa a propriedade Basemap como fallback.

            % Sem um eixo geográfico válido não há onde aplicar o estilo.
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            % Lê o identificador textual do estilo selecionado pelo usuário.
            mapStyle = app.configMapStyleDropDown.Value;

            try
                % Caminho preferencial para atualização do basemap.
                geobasemap(app.UIAxes, mapStyle)
            catch
                try
                    % Fallback para cenários em que a função geobasemap não esteja
                    % disponível ou não aceite o contexto atual do eixo.
                    app.UIAxes.Basemap = mapStyle;
                catch ME
                    % Se ambas as estratégias falharem, informa o usuário sem
                    % interromper o restante do fluxo da interface.
                    ui.Dialog(app.UIFigure, 'warning', ...
                        sprintf('Não foi possível aplicar o estilo de mapa "%s".\n%s', ...
                        mapStyle, ME.message));
                end
            end
        end

        function restoreMapView(app)
            % Reenquadra intencionalmente o mapa para o conjunto filtrado atual.
            applyMapViewport(app, struct(), "fit")
        end

        function restoreMapInteractions(app)
            % Reinstala as interações padrão que o geoaxes perde após cla().
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            plot.axes.Interactivity.DefaultCreation(app.UIAxes, ...
                [zoomInteraction, panInteraction])
        end

        function viewportMode = normalizeViewportMode(~, viewportMode)
            % Normaliza o modo de atualização da viewport do mapa.
            if nargin < 2 || isempty(viewportMode)
                viewportMode = "preserve_if_all_states";
                return
            end

            viewportMode = string(viewportMode);
        end

        function output = selectedStateFilter(app)
            % Retorna o estado atualmente selecionado no filtro do mapa.
            output = "Todos os estados";

            if isempty(app.filesStateDropDown) || ~isvalid(app.filesStateDropDown)
                return
            end

            output = string(app.filesStateDropDown.Value);
        end

        function limits = getCurrentMapLimits(app)
            % Captura os limites atuais do geoaxes para eventual restauração.
            limits = struct('latitude', [], 'longitude', []);

            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            latitudeLimits = double(app.UIAxes.LatitudeLimits);
            longitudeLimits = double(app.UIAxes.LongitudeLimits);

            if numel(latitudeLimits) == 2 && numel(longitudeLimits) == 2 && ...
                    all(isfinite(latitudeLimits)) && all(isfinite(longitudeLimits))
                limits.latitude = latitudeLimits;
                limits.longitude = longitudeLimits;
            end
        end

        function output = hasValidMapLimits(~, limits)
            % Valida uma estrutura de limites antes de reaplicá-la ao mapa.
            output = isstruct(limits) && isfield(limits, 'latitude') && isfield(limits, 'longitude') && ...
                numel(limits.latitude) == 2 && numel(limits.longitude) == 2 && ...
                all(isfinite(limits.latitude)) && all(isfinite(limits.longitude)) && ...
                diff(limits.latitude) > 0 && diff(limits.longitude) > 0;
        end

        function setMapLimits(app, limits)
            % Aplica ao geoaxes um par explícito de limites já validados.
            if ~hasValidMapLimits(app, limits)
                return
            end

            geolimits(app.UIAxes, limits.latitude, limits.longitude)
        end

        function applyMapViewport(app, previousLimits, viewportMode)
            % Decide entre preservar ou recalcular o enquadramento do mapa.
            viewportMode = normalizeViewportMode(app, viewportMode);
            points = struct([]);

            if isstruct(app.filteredRepoSFI) && isfield(app.filteredRepoSFI, 'points')
                points = app.filteredRepoSFI.points;
            end

            if shouldPreserveMapViewport(app, previousLimits, points, viewportMode)
                setMapLimits(app, previousLimits)
            else
                fitMapToPoints(app, points)
            end
        end

        function output = shouldPreserveMapViewport(app, previousLimits, points, viewportMode)
            % Preserva a viewport apenas quando isso evita microajustes sem ocultar tudo.
            output = false;

            if ~hasValidMapLimits(app, previousLimits)
                return
            end

            switch normalizeViewportMode(app, viewportMode)
                case "preserve"
                    output = true;

                case "preserve_if_all_states"
                    if selectedStateFilter(app) ~= "Todos os estados"
                        return
                    end

                    if isempty(points)
                        output = true;
                        return
                    end

                    lat = double([points.latitude]);
                    lon = double([points.longitude]);
                    isInside = lat >= previousLimits.latitude(1) & lat <= previousLimits.latitude(2) & ...
                        lon >= previousLimits.longitude(1) & lon <= previousLimits.longitude(2);
                    output = any(isInside);
            end
        end

        function fitMapToPoints(app, points)
            % Enquadra os pontos com padding estável, sem depender do auto-fit do geoaxes.
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            if isempty(points)
                geolimits(app.UIAxes, 'auto')
                return
            end

            lat = double([points.latitude]);
            lon = double([points.longitude]);
            validIdx = isfinite(lat) & isfinite(lon);
            lat = lat(validIdx);
            lon = lon(validIdx);

            if isempty(lat) || isempty(lon)
                geolimits(app.UIAxes, 'auto')
                return
            end

            minLat = min(lat);
            maxLat = max(lat);
            minLon = min(lon);
            maxLon = max(lon);
            centerLat = (minLat + maxLat) / 2;
            centerLon = (minLon + maxLon) / 2;

            latSpan = max(maxLat - minLat, 0.30);
            cosScale = max(cosd(centerLat), 0.25);
            lonSpan = max(maxLon - minLon, 0.30 / cosScale);

            targetAspect = 1.6;
            if ~isempty(app.plotPanel) && isvalid(app.plotPanel)
                panelPosition = getpixelposition(app.plotPanel, true);
                if numel(panelPosition) >= 4 && panelPosition(4) > 0
                    targetAspect = max(1.0, panelPosition(3) / panelPosition(4));
                end
            end

            normalizedLonSpan = lonSpan * cosScale;
            currentAspect = normalizedLonSpan / max(latSpan, eps);

            if currentAspect > targetAspect
                latSpan = normalizedLonSpan / targetAspect;
            else
                normalizedLonSpan = latSpan * targetAspect;
                lonSpan = normalizedLonSpan / cosScale;
            end

            latSpan = max(latSpan * 1.18, 0.45);
            lonSpan = max(lonSpan * 1.18, 0.45 / cosScale);

            latitudeLimits = centerLat + 0.5 * [-latSpan, latSpan];
            longitudeLimits = centerLon + 0.5 * [-lonSpan, lonSpan];

            latitudeLimits = max(min(latitudeLimits, 89.5), -89.5);
            longitudeLimits = max(min(longitudeLimits, 180), -180);

            if diff(latitudeLimits) <= 0 || diff(longitudeLimits) <= 0
                geolimits(app.UIAxes, 'auto')
                return
            end

            geolimits(app.UIAxes, latitudeLimits, longitudeLimits)
        end

        %-----------------------------------------------------------------%
        % Funções de manipulação dos scatters do mapa
        %-----------------------------------------------------------------%
        function clearPopupSelectionHighlight(app)
            % Remove o destaque visual associado ao popup atual.

            % Verificação do geoAxes
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes) || ~isstruct(app.UIAxes.UserData)
                return
            end

            % Verifica handle grafico persistido de algum highlight
            % anterior
            if isfield(app.UIAxes.UserData, 'popupHighlightHandle')
                highlightHandle = app.UIAxes.UserData.popupHighlightHandle;
                if ~isempty(highlightHandle)
                    highlightHandle = highlightHandle(isgraphics(highlightHandle));
                    if ~isempty(highlightHandle)
                        delete(highlightHandle)
                    end
                end
                app.UIAxes.UserData = rmfield(app.UIAxes.UserData, 'popupHighlightHandle');
            end

            % Remove campo
            if isfield(app.UIAxes.UserData, 'popupHighlightSiteIds')
                app.UIAxes.UserData = rmfield(app.UIAxes.UserData, 'popupHighlightSiteIds');
            end
        end

        function updatePopupSelectionHighlight(app, popupSites)
            % Atualiza o destaque visual no mapa para refletir os sites exibidos
            % no popup naquele instante.
            %
            % A função remove qualquer highlight anterior e desenha uma nova camada
            % de marcadores sobre as localidades presentes em popupSites,
            % preservando a cor base de cada ponto no mapa.

            % Verifica existencia do geoAxes
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            % Limpeza de Highlights antigos
            clearPopupSelectionHighlight(app);

            points = [popupSites.point];
            lat = double([points.latitude]);
            lon = double([points.longitude]);
            if isempty(lat) || isempty(lon)
                return
            end

            markerStates = string({points.marker_state});
            overlayColor = [0.22, 0.22, 0.22];

            highlightHandle = gobjects(0);

            plotHighlightGroup(markerStates == "offline_previous", [220, 195, 173] / 255, true);
            plotHighlightGroup(markerStates == "online_previous",  [167, 190, 171] / 255, true);
            plotHighlightGroup(markerStates == "offline_current",  [184, 131, 82] / 255, false);
            plotHighlightGroup(markerStates == "online_current",   [79, 127, 103] / 255, false);
            plotHighlightGroup(markerStates == "no_host",          [123, 138, 160] / 255, false);

            % Persiste o handle gráfico e os IDs destacados para futura limpeza
            % ou eventual inspeção de estado.
            app.UIAxes.UserData.popupHighlightHandle = highlightHandle;
            app.UIAxes.UserData.popupHighlightSiteIds = [popupSites.siteId];

            function plotHighlightGroup(idx, markerColor, isHistorical)
                if ~any(idx)
                    return
                end

                latGroup = lat(idx);
                lonGroup = lon(idx);

                highlightHandle(end+1) = geoscatter(app.UIAxes, latGroup, lonGroup, ...
                    165, markerColor, 'filled', ...
                    'Marker', 'o', ...
                    'MarkerEdgeColor', [0, 0, 0], ...
                    'LineWidth', 1.4, ...
                    'PickableParts', 'none', ...
                    'HitTest', 'off'); %#ok<AGROW>

                if isHistorical
                    highlightHandle(end+1) = geoscatter(app.UIAxes, latGroup, lonGroup, ...
                        18, overlayColor, ...
                        'Marker', '.', ...
                        'LineWidth', 0.8, ...
                        'PickableParts', 'none', ...
                        'HitTest', 'off'); %#ok<AGROW>
                end
            end
        end

        function plot_Stations(app, viewportMode)
            % Replota o mapa com base no dataset filtrado já preparado.
            %
            % Responsabilidades principais:
            % - limpar o eixo geográfico antes de um novo desenho
            % - atualizar a contagem de localidades visíveis
            % - plotar cada grupo de marcadores com sua cor/estilo
            % - reinstalar as interações padrão do mapa

            if nargin < 2
                viewportMode = "preserve_if_all_states";
            end

            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            previousLimits = getCurrentMapLimits(app);

            % Limpa completamente o eixo para evitar sobreposição entre plots
            % antigos e o novo estado filtrado.
            cla(app.UIAxes);
            app.popupHTML.Visible = "off";

            filteredData = app.filteredRepoSFI;
            if ~isstruct(filteredData) || ~isfield(filteredData, 'points') || ~isfield(filteredData, 'site_details')
                return
            end

            % Atualiza a indicação textual de quantas localidades permanecem visíveis.
            if ~isempty(app.filesCountLabel)
                app.filesCountLabel.Text = sprintf('%d localidade(s) visíveis', numel(filteredData.points));
            end

            % Se nenhum ponto sobreviveu ao filtro, não há mais nada para desenhar.
            if isempty(filteredData.points)
                restoreMapInteractions(app)
                applyMapViewport(app, previousLimits, viewportMode)
                return
            end

            lat = [filteredData.points.latitude].';
            lon = [filteredData.points.longitude].';
            markerStates = string({filteredData.points.marker_state}).';

            colorOnlineCurrent  = [79, 127, 103] / 255;
            colorOnlinePrevious = [167, 190, 171] / 255;
            colorOfflineCurrent = [184, 131, 82] / 255;
            colorOfflinePrevious = [220, 195, 173] / 255;
            colorNoHost = [123, 138, 160] / 255;

            % Cor usada na sobreposição de marcadores históricos.
            overlayColor = [0.22, 0.22, 0.22];

            % A ordem de plot é importante:
            % primeiro os históricos, depois os estados correntes e, por fim,
            % os demais marcadores. Isso ajuda a preservar legibilidade visual.
            plotGroup(markerStates == "offline_previous", colorOfflinePrevious, true, 100);
            plotGroup(markerStates == "online_previous",  colorOnlinePrevious,  true, 80);
            plotGroup(markerStates == "offline_current",  colorOfflineCurrent,  false, 100);
            plotGroup(markerStates == "online_current",   colorOnlineCurrent,   false, 80);
            plotGroup(markerStates == "no_host",          colorNoHost,          false, 100);

            %plot.axes.StackingOrder.execute(app.UIAxes1, 'RFDataHub')
            % app.restoreView = struct('ID', 'app.UIAxes1', ...
            %     'xLim', app.UIAxes.LatitudeLimits, ...
            %     'yLim', app.UIAxes.LongitudeLimits, ...
            %     'cLim', 'auto');


            restoreMapInteractions(app)
            applyMapViewport(app, previousLimits, viewportMode)

            function plotGroup(idx, color, isHistorical, markerSize)
                % Plota um subconjunto homogêneo de marcadores com o mesmo estilo.
                %
                % idx:
                %   máscara lógica dos pontos pertencentes ao grupo atual
                % color:
                %   cor principal do marcador
                % isHistorical:
                %   indica se o grupo representa localização histórica
                % markerSize:
                %   tamanho base do marcador no mapa

                % Se o grupo estiver vazio, não há nada a desenhar.
                if ~any(idx)
                    return
                end

                idxList = find(idx);

                latGroup = lat(idxList);
                lonGroup = lon(idxList);
                siteIdGroup = double([filteredData.points(idxList).site_id]);

                % Desenha o grupo principal de marcadores.
                % Esses marcadores continuam interativos para clique e abertura
                % de popup.
                h = geoscatter(app.UIAxes, latGroup, lonGroup, ...
                    markerSize, color, 'filled', ...
                    'Marker', 'o', ...
                    'MarkerEdgeColor', [1 1 1], ...
                    'LineWidth', 1.0, ...
                    'PickableParts', 'all', ...
                    'HitTest', 'on', ...
                    'ButtonDownFcn', @(src, event) onPlottedSiteClick(app, src, event));

                % Armazena no handle os dados necessários para resolver depois
                % qual localidade foi clicada.
                h.UserData = struct( ...
                    'site_ids', siteIdGroup, ...
                    'latitudes', latGroup, ...
                    'longitudes', lonGroup ...
                    );

                % Marcadores históricos recebem uma sobreposição adicional discreta
                % para diferenciá-los visualmente dos pontos correntes.
                if isHistorical
                    geoscatter(app.UIAxes, latGroup, lonGroup, ...
                        14, overlayColor, ...
                        'Marker', '.', ...
                        'LineWidth', 0.8, ...
                        'HitTest', 'off', ...
                        'PickableParts', 'none');
                end
            end
        end

        function onPlottedSiteClick(app, src, event)
            % Resolve qual localidade foi clicada no mapa e abre o popup
            % correspondente à seleção resultante.
            %
            % O clique pode representar:
            % - um único site
            % - vários sites agregados no mesmo objeto gráfico
            %
            % Nesse segundo caso, a função tenta identificar o site mais próximo
            % da coordenada real do clique.

            siteId = [];

            % Os dados necessários para resolver o clique ficam anexados ao
            % marcador via src.UserData no momento do plot.
            if isstruct(src.UserData) && isfield(src.UserData, 'site_ids')

                % Quando o evento informa diretamente o índice do ponto clicado,
                % usa esse índice para recuperar o site correspondente.
                if isprop(event, 'DataIndex') && ~isempty(event.DataIndex) && ...
                        event.DataIndex >= 1 && event.DataIndex <= numel(src.UserData.site_ids)
                    siteId = src.UserData.site_ids(event.DataIndex);

                    % Se o objeto gráfico representa apenas um site, não há ambiguidade.
                elseif isscalar(src.UserData.site_ids)
                    siteId = src.UserData.site_ids(1);

                    % Quando vários sites estão agrupados no mesmo handle gráfico,
                    % usa a coordenada do clique para escolher o mais próximo.
                else
                    [clickLat, clickLon] = extractMapClickCoordinates(app, src, event);
                    if isfinite(clickLat) && isfinite(clickLon)
                        srcLat = double(src.UserData.latitudes(:));
                        srcLon = double(src.UserData.longitudes(:));

                        % Usa distância aproximada corrigida por latitude para
                        % reduzir distorção horizontal.
                        distance = hypot(srcLat - clickLat, (srcLon - clickLon) .* max(cosd(clickLat), 0.25));

                        [~, nearestIdx] = min(distance);
                        siteId = src.UserData.site_ids(nearestIdx);
                    end
                end
            end

            % Se não foi possível resolver um site válido, encerra sem abrir popup.
            if isempty(siteId)
                return
            end

            % Recupera o snapshot filtrado atualmente exibido no mapa.
            filteredMapData = app.filteredRepoSFI;

            % A partir do site base clicado, resolve a seleção efetiva do popup.
            % Dependendo do zoom e da proximidade entre pontos, essa seleção pode
            % conter mais de um site.
            selectionInfo = resolveSiteSelection(app, siteId, filteredMapData, src, event);
            siteId = selectionInfo.siteId;

            % Exibe o popup correspondente à seleção resolvida.
            showSitePopup(app, filteredMapData, selectionInfo);

            % Persiste o contexto do último clique para fluxos posteriores, como
            % abertura sob demanda do dock de arquivos.
            app.currentSiteContext = struct('siteId', siteId, 'mapDataSet', filteredMapData);
        end

        %-----------------------------------------------------------------%
        % Funções de manipulação do Popup
        %-----------------------------------------------------------------%
        function closePopup(app)
            % Limpa o HTML e oculta o popup sem preservar estado visual.
            ui.TextView.setLabelInnerHTMLBypassingText(app.jsBackDoor, app.popupHTML, '');
            app.popupHTML.Visible = "off";
            app.currentSiteContext = [];
            clearPopupSelectionHighlight(app);
        end

        function showSitePopup(app, mapDataSet, selectionInfo)
            % Resolve os sites realmente exibíveis, atualiza o destaque no mapa,
            % calcula a geometria do popup e injeta o HTML final.
            %
            % Fluxo:
            % 1. valida o dataset recebido
            % 2. materializa apenas os sites válidos para exibição
            % 3. atualiza o highlight da seleção no mapa
            % 4. calcula métricas e posição do popup
            % 5. renderiza o HTML e conecta os botões do conteúdo

            % Sem a estrutura mínima esperada não há como montar o popup.
            if ~isstruct(mapDataSet) || ~isfield(mapDataSet, 'points') || ~isfield(mapDataSet, 'site_details')
                closePopup(app)
                return
            end

            % Converte a seleção recebida em uma coleção consistente de sites
            % válidos, já contendo point e detail para renderização.
            popupSites = collectPopupSites(app, mapDataSet, selectionInfo.siteIds);
            if isempty(popupSites)
                closePopup(app)
                return
            end

            % Cria highlight no mapa dos pontos que foram transportados pro
            % popup
            updatePopupSelectionHighlight(app, popupSites);

            % Usa o conteúdo resolvido para dimensionar e posicionar o popup.
            popupMetrics = getPopupMetrics(app, popupSites);
            popupHeight = updatePopupGeometry(app, popupMetrics);

            % Gera o HTML definitivo já adaptado à altura calculada.
            htmlContent = buildPopupHTML(app, popupSites, popupHeight);

            % Inicializa JS customizations na primeira vez se necessário
            % if isempty(app.popupHTML.UserData) || ~isfield(app.popupHTML.UserData, 'id')
            %     applyJSCustomizations(app);
            % end

            % Exibe o popup e injeta o conteúdo HTML no componente visual.
            app.popupHTML.Visible = "on";
            ui.TextView.setLabelInnerHTMLBypassingText(app.jsBackDoor, app.popupHTML, htmlContent);

            % Registra o botão de abertura do dock no bridge HTML -> MATLAB.
            sendEventToHTMLSource(app.jsBackDoor, 'bindTextViewButtons', ...
                struct('dataTag', app.popupHTML.UserData.id,...
                'selector', 'button.repo-sfi-open-dock',...
                'htmlEventName', 'repoSFI.openDock'));

            % Registra o botão de fechamento do popup no bridge HTML -> MATLAB.
            sendEventToHTMLSource(app.jsBackDoor, 'bindTextViewButtons',...
                struct('dataTag', app.popupHTML.UserData.id,...
                'selector', 'button.repo-sfi-close-popup',...
                'htmlEventName', 'repoSFI.closePopup'));
        end


        %-----------------------------------------------------------------%
        % Funções de Geometria do Popup
        %-----------------------------------------------------------------%
        function popupMetrics = getPopupMetrics(app, popupSites)
            % Calcula as métricas usadas para dimensionar o popup.
            %
            % A função estima:
            % - largura do popup
            % - quantidade total de estações
            % - quantidade de estações visíveis sem scroll
            % - altura total do conteúdo
            % - altura visível inicial do conteúdo
            %
            % A entrada popupSites já deve conter apenas os sites válidos para
            % exibição no popup.

            % Inicialização da estrutura de tamanho do popup
            popupMetrics = struct( ...
                'popupWidth', 280, ...
                'totalStations', 0, ...
                'visibleStations', 0, ...
                'visibleSites', 0, ...
                'totalContentHeight', 0, ...
                'visibleContentHeight', 0 ...
                );

            % Estado mínimo usado quando não há sites para renderizar.
            % Isso evita popup com altura zerada e mantém um fallback consistente.
            if isempty(popupSites)
                popupMetrics.visibleStations = 1;
                popupMetrics.visibleSites = 1;
                popupMetrics.totalContentHeight = 120;
                popupMetrics.visibleContentHeight = 120;
                return
            end

            % O popup exibe, sem scroll, no máximo três estações.
            % Se houver mais do que isso, a altura visível é limitada e o restante
            % do conteúdo fica acessível por rolagem vertical.
            visibleStationLimit = 3;
            accumulatedVisibleStations = 0;
            totalRenderedSites = 0;

            for ii = 1:numel(popupSites)
                popupSite = popupSites(ii);
                stationCount = numel(popupSite.detail.stations);

                % Sites sem estações associadas não contribuem para o popup.
                if stationCount == 0
                    continue
                end

                totalRenderedSites = totalRenderedSites + 1;

                % Soma a altura do cabeçalho do site ao conteúdo total.
                siteHeaderHeight = estimatePopupSiteHeight(app, popupSite.point, popupMetrics.popupWidth);
                popupMetrics.totalContentHeight = popupMetrics.totalContentHeight + siteHeaderHeight;
                popupMetrics.totalStations = popupMetrics.totalStations + stationCount;

                % A partir do segundo site há um separador visual entre blocos.
                if totalRenderedSites > 1
                    popupMetrics.totalContentHeight = popupMetrics.totalContentHeight + 1;
                end

                % Enquanto ainda houver espaço dentro do limite visível de estações,
                % o cabeçalho deste site também compõe a altura visível inicial.
                if accumulatedVisibleStations < visibleStationLimit
                    popupMetrics.visibleSites = popupMetrics.visibleSites + 1;
                    popupMetrics.visibleContentHeight = popupMetrics.visibleContentHeight + siteHeaderHeight;

                    % Também considera o separador visual entre sites visíveis.
                    if popupMetrics.visibleSites > 1
                        popupMetrics.visibleContentHeight = popupMetrics.visibleContentHeight + 1;
                    end
                end

                for kk = 1:stationCount
                    % Soma a altura de cada estação ao conteúdo total do popup.
                    stationHeight = estimatePopupStationHeight(app, popupSite.detail.stations(kk), popupMetrics.popupWidth);
                    popupMetrics.totalContentHeight = popupMetrics.totalContentHeight + stationHeight;

                    % Apenas as três primeiras estações contribuem para a área
                    % visível inicial do popup.
                    if accumulatedVisibleStations < visibleStationLimit
                        popupMetrics.visibleStations = popupMetrics.visibleStations + 1;
                        popupMetrics.visibleContentHeight = popupMetrics.visibleContentHeight + stationHeight;
                        accumulatedVisibleStations = accumulatedVisibleStations + 1;
                    end
                end
            end

            % Garante valores mínimos para evitar métricas vazias ou muito pequenas,
            % o que poderia quebrar o cálculo final da geometria do popup
            popupMetrics.visibleStations = max(1, popupMetrics.visibleStations);
            popupMetrics.visibleSites = max(1, popupMetrics.visibleSites);
            popupMetrics.totalContentHeight = max(120, popupMetrics.totalContentHeight);
            popupMetrics.visibleContentHeight = max(120, popupMetrics.visibleContentHeight);
        end

        
        function popupHeight = updatePopupGeometry(app, popupMetrics)
            % Calcula a altura final do popup e posiciona o componente dentro da área útil.
            %
            % A função usa as métricas já estimadas do conteúdo para:
            % - definir a altura visível inicial do popup
            % - limitar o tamanho ao espaço disponível no painel
            % - posicionar o popup no canto superior direito útil do mapa

            % Sem painel ou figura válidos não há como posicionar o popup.
            if isempty(app.plotPanel) || ~isvalid(app.plotPanel) || isempty(app.UIFigure)
                popupHeight = 0;
                return
            end

            % Dimensões da figura principal, usadas para impedir que o popup
            % ultrapasse os limites visuais da janela.
            figurePosition = app.UIFigure.Position;
            figureWidth = figurePosition(3);
            figureHeight = figurePosition(4);

            % Dimensões absolutas do painel do mapa, que servem como referência
            % para o cálculo da largura, altura e posição do popup.
            panelPosition = getpixelposition(app.plotPanel, true);
            panelWidth = panelPosition(3);
            panelHeight = panelPosition(4);
            panelAbsoluteX = panelPosition(1);
            panelAbsoluteY = panelPosition(2);

            % Usa a largura já calculada nas métricas; se estiver inválida,
            % recompõe a largura a partir da regra padrão do painel.
            popupWidth = popupMetrics.popupWidth;
            if isempty(popupWidth) || ~isfinite(popupWidth)
                popupWidth = getPopupWidth(app);
            end

            % O cabeçalho e a moldura têm altura fixa.
            headerHeight = 54;
            frameHeight = 4;

            % Se o total de estações couber no popup, usa toda a altura do conteúdo.
            % Caso contrário, usa apenas a altura visível inicial e deixa o restante
            % para rolagem vertical.
            if popupMetrics.totalStations <= 3
                contentHeight = popupMetrics.totalContentHeight;
            else
                contentHeight = popupMetrics.visibleContentHeight;
            end

            % Altura desejada com base no conteúdo medido.
            preferredHeight = headerHeight + frameHeight + contentHeight;

            % Impõe limites mínimos e máximos para evitar popup pequeno demais
            % ou grande demais para o painel disponível.
            minHeight = headerHeight + frameHeight + 120;
            maxHeight = max(minHeight, min(panelHeight - 16, 640));
            popupHeight = max(minHeight, min(preferredHeight, maxHeight));

            % Posiciona o popup no canto superior direito útil do painel, com margem.
            left = max(12, panelAbsoluteX + panelWidth - popupWidth - 16);
            bottom = max(12, panelAbsoluteY + panelHeight - popupHeight - 16);

            % Garante que o popup não ultrapasse os limites da figura principal.
            left = min(left, figureWidth - popupWidth - 5);
            bottom = min(bottom, figureHeight - popupHeight - 5);

            % Aplica a geometria calculada ao componente visual.
            %app.popupHTML.Position = [left, bottom, popupWidth, popupHeight];
        end

        function contentHeight = estimatePopupSiteHeight(app, point, popupWidth)
            % Estima a altura do cabeçalho de uma localidade no popup.
            %
            % O cálculo considera:
            % - o nome do site
            % - a linha de metadados do site
            % - os espaçamentos verticais usados no HTML renderizado

            % Reaproveita a mesma composição de metadados usada na renderização
            % para manter coerência entre o HTML final e a estimativa de altura.
            metaParts = buildPopupSiteMetaParts(app, point, true);

            % Estima quantas linhas o título e os metadados ocuparão dentro da
            % largura útil disponível no cabeçalho.
            titleLines = estimateWrappedLineCount(app, point.site_label, popupWidth - 40, 12, true);
            metaLines = estimateWrappedLineCount(app, strjoin(metaParts, "   "), popupWidth - 34, 10, false);

            % Soma alturas de texto e espaçamentos verticais conforme o layout HTML.
            contentHeight = 12 + titleLines * 16 + 2 + metaLines * 12 + 10;
        end

        function contentHeight = estimatePopupStationHeight(app, station, popupWidth)
            % Estima a altura do bloco de uma estação dentro do popup.
            %
            % O cálculo considera:
            % - nome da estação
            % - status
            % - indicação de posição atual ou histórica
            % - linha de última observação, quando existir
            % - botão "Abrir arquivos"

            % Resolve os textos dinâmicos que aparecem no bloco da estação.
            [statusText, ~] = stationStatus(app, station);
            locationText = "Posicao atual";
            if ~station.is_current_location
                locationText = "Posicao historica";
            end

            % A largura útil do texto é menor que a largura total do popup por
            % causa das margens e recuos do layout HTML.
            textWidth = popupWidth - 52;

            % Estima o número de linhas de cada trecho textual principal.
            nameLines = estimateWrappedLineCount(app, chooseName(app, station), textWidth, 12, true);
            statusLines = estimateWrappedLineCount(app, statusText, textWidth, 11, true);
            locationLines = estimateWrappedLineCount(app, locationText, textWidth, 11, false);

            % A linha de "última visão" só entra quando houver esse dado.
            lastSeenHeight = 0;
            if ~isempty(station.last_seen_at)
                lastSeenText = "Ultima visao: " + string(station.last_seen_at);
                lastSeenLines = estimateWrappedLineCount(app, lastSeenText, textWidth, 9, false);
                lastSeenHeight = 4 + lastSeenLines * 11;
            end

            % O botão tem altura fixa no layout.
            buttonHeight = 39;

            % Soma texto, espaçamentos e botão para estimar a altura total do bloco.
            contentHeight = 10 + nameLines * 16 + 3 + statusLines * 14 + 3 + locationLines * 15 + lastSeenHeight + 8 + buttonHeight;
        end

        function lineCount = estimateWrappedLineCount(~, rawText, availableWidth, fontSize, isBold)
            % Estima quantas linhas um texto ocupará dentro de uma largura limitada.
            %
            % Esta função não mede texto real no navegador; ela usa uma aproximação
            % baseada em:
            % - largura disponível
            % - tamanho da fonte
            % - fator de peso visual para texto normal ou negrito
            %
            % O objetivo é apenas dimensionar o popup de forma consistente.

            % Normaliza a entrada para um texto escalar limpo.
            textValue = strip(string(rawText));
            if isempty(textValue) || all(ismissing(textValue)) || strlength(textValue(1)) == 0
                lineCount = 0;
                return
            end

            % Assume uma largura média por caractere.
            % Texto em negrito tende a ocupar mais espaço horizontal.
            widthFactor = 0.56;
            if isBold
                widthFactor = 0.61;
            end

            % Converte a largura útil em uma capacidade aproximada de caracteres
            % por linha, respeitando um limite mínimo para evitar distorções.
            avgCharWidth = max(5, fontSize * widthFactor);
            maxCharsPerLine = max(10, floor(max(availableWidth, 80) / avgCharWidth));

            % Divide o texto em parágrafos para tratar quebras explícitas de linha.
            paragraphs = splitlines(textValue(1));
            lineCount = 0;

            for ii = 1:numel(paragraphs)
                % Remove espaços duplicados e trata cada parágrafo de forma isolada.
                paragraph = regexprep(char(strtrim(paragraphs(ii))), '\s+', ' ');
                if isempty(paragraph)
                    lineCount = lineCount + 1;
                    continue
                end

                % Aproxima o número de linhas pela razão entre comprimento do texto
                % e a capacidade estimada de caracteres por linha.
                normalizedLength = strlength(string(paragraph));
                lineCount = lineCount + max(1, ceil(double(normalizedLength) / maxCharsPerLine));
            end
        end


        %-----------------------------------------------------------------%
        % Funções de Conteúdo do Popup
        %-----------------------------------------------------------------%
        function output = popupSummaryText(~, siteCount, totalStations)
            % Forma string com resumo das estações associadas a uma
            % determinada localização selecionada
            if siteCount == 1
                output = sprintf('%d estacao(oes) vinculada(s) a esta localidade', totalStations);
            else
                output = sprintf('%d localidade(s) e %d estacao(oes) nesta area', siteCount, totalStations);
            end
        end

        function popupSites = collectPopupSites(~, mapDataSet, siteIds)
            % Materializa os sites válidos que serão usados pelo pipeline do popup.
            %
            % A entrada siteIds contém apenas os identificadores selecionados.
            % Esta função transforma esses IDs em uma coleção pronta para consumo
            % pelas próximas etapas, anexando:
            % - o ponto público do mapa (`point`)
            % - o detalhe completo do site (`detail`)
            %
            % Sites sem correspondência completa em mapDataSet são descartados.

            % Estrutura de saída normalizada para os métodos seguintes.
            popupSites = struct('siteId', {}, 'point', {}, 'detail', {});

            % Sem IDs não há nada para materializar.
            if isempty(siteIds)
                return
            end

            % Remove duplicidades preservando a ordem original da seleção.
            selectedSiteIds = unique(double(siteIds(:).'), 'stable');

            for ii = 1:numel(selectedSiteIds)
                siteId = selectedSiteIds(ii);

                % Localiza o ponto do mapa e o detalhe correspondente ao mesmo site.
                pointIdx = find([mapDataSet.points.site_id] == siteId, 1);
                detailIdx = find([mapDataSet.site_details.site_id] == siteId, 1);

                % O popup só trabalha com sites completos; se faltar qualquer uma
                % das partes, esse site é ignorado.
                if isempty(pointIdx) || isempty(detailIdx)
                    continue
                end

                % Empacota o site em uma estrutura única para evitar novos lookups
                % nas etapas de medição, highlight e renderização do popup.
                popupSites(end + 1) = struct( ...
                    'siteId', siteId, ...
                    'point', mapDataSet.points(pointIdx), ...
                    'detail', mapDataSet.site_details(detailIdx) ...
                    ); %#ok<AGROW>
            end
        end

        function output = buildPopupSiteMetaParts(app, point, includeSiteId)
            % Monta a lista de fragmentos textuais que compõem os metadados do site.
            %
            % Esses fragmentos são reutilizados em mais de um ponto do pipeline:
            % - no HTML do popup
            % - no cálculo da altura estimada do cabeçalho do site
            %
            % Exemplos de partes geradas:
            % - ID do site
            % - município/UF
            % - altitude

            % Normaliza os campos textuais usados na composição.
            countyName = normalizeTextFromValue(app, point.county_name);
            stateCode = normalizeTextFromValue(app, point.state_code);

            % A saída é uma lista de strings que depois será unida por separadores.
            output = strings(0, 1);

            % Inclui o identificador do site quando solicitado pelo chamador.
            if includeSiteId
                output(end + 1, 1) = "ID " + string(point.site_id);
            end

            % Município e UF só entram quando ambos estiverem disponíveis.
            if strlength(countyName) > 0 && strlength(stateCode) > 0
                output(end + 1, 1) = esc(app, countyName + "/" + stateCode);
            end

            % Altitude é opcional e só aparece quando existir no ponto.
            if ~isempty(point.altitude)
                output(end + 1, 1) = string(point.altitude) + " m";
            end
        end

        %-----------------------------------------------------------------%
        % Funções de Montagem HTML do Popup
        %-----------------------------------------------------------------%
        function html = buildPopupHTML(app, popupSites, popupHeight)
            % Monta o HTML completo do popup a partir dos sites já resolvidos.
            % A função:
            % 1. renderiza cada bloco de site
            % 2. calcula o resumo do cabeçalho
            % 3. monta a estrutura final com cabeçalho fixo e corpo rolável

            % Quantifica os sites e o total de estações para compor o resumo.
            siteCount = numel(popupSites);
            totalStations = sum(arrayfun(@(popupSite)numel(popupSite.detail.stations), popupSites));

            % Cada site vira uma seção HTML independente dentro do corpo do popup.
            siteSections = strings(siteCount, 1);

            for ii = 1:siteCount
                siteSections(ii) = renderPopupSiteHTML(app, popupSites(ii), ii > 1);
            end

            % O cabeçalho tem altura fixa; o restante da área vira corpo rolável.
            headerHeight = 54;
            bodyHeight = max(56, popupHeight - headerHeight - 4);

            % Espaço entre o botão de undock e o popup
            popupTopInset = 25;

            % Gera o texto-resumo do cabeçalho conforme a quantidade de sites
            % e estações presentes na seleção atual.
            summaryText = popupSummaryText(app, siteCount, totalStations);

            % Monta o cabeçalho fixo com título, resumo e botão de fechar.
            headerHTML = sprintf([ ...
                '<section style="font-family: Helvetica, Arial, sans-serif; color: #202020; background-color: #f2f2f2; padding: 10px 12px 8px 12px; line-height: 1.35; border-bottom: 1px solid #d9d9d9; height: %dpx; box-sizing: border-box; position: relative;">' ...
                '<p style="margin: 0 28px 2px 0;"><strong style="font-size: 13px; color: #202020;">Estações selecionadas</strong></p>' ...
                '<p style="margin: 0 28px 0 0; color: #707070; font-size: 10px;">%s</p>' ...
                '<button type="button" class="repo-sfi-close-popup" style="position: absolute; top: 8px; right: 8px; width: 22px; height: 22px; background-color: #fafafa; border: 1px solid #d0d0d0; border-radius: 11px; color: #787878; font-size: 14px; font-weight: bold; cursor: pointer; line-height: 18px; text-align: center; padding: 0;">×</button>' ...
                '</section>'], headerHeight, summaryText);

            % Empacota cabeçalho e conteúdo em um contêiner único, com altura
            % total já calculada e rolagem vertical apenas no corpo do popup.
            html = sprintf([ ...
                '<div style="padding: %dpx 0 0 0; box-sizing: border-box;">' ...
                '<section style="background-color: #ffffff; border: 1px solid #d8d8d8; border-radius: 4px; overflow: hidden; height: %dpx; box-sizing: border-box;">' ...
                '%s' ...
                '<section style="height: %dpx; overflow-y: auto; overflow-x: hidden; padding: 0; box-sizing: border-box;">' ...
                '<div style="padding: 0 0 2px 0;">%s</div>' ...
                '</section>' ...
                '</section>' ...
                '</div>'], ...
                popupTopInset, ...
                popupHeight, ...
                headerHTML, ...
                bodyHeight, ...
                char(strjoin(siteSections, '')));
        end

        function html = renderPopupSiteHTML(app, popupSite, addTopBorder)
            % Renderiza o bloco HTML de uma localidade dentro do popup.
            %
            % Cada bloco de site contém:
            % - cabeçalho com nome e metadados da localidade
            % - lista de estações associadas àquele site
            % - separador visual opcional entre sites consecutivos

            % Monta os metadados textuais do site, como município/UF e altitude.
            metaParts = buildPopupSiteMetaParts(app, popupSite.point, false);

            % Cada estação do site é renderizada como uma subseção independente.
            stationSections = strings(numel(popupSite.detail.stations), 1);
            for kk = 1:numel(popupSite.detail.stations)
                stationSections(kk) = renderPopupStationHTML(app, popupSite.siteId, popupSite.detail.stations(kk));
            end

            % O separador superior só é aplicado a partir do segundo site,
            % melhorando a leitura visual entre blocos consecutivos.
            sectionBorder = '';
            if addTopBorder
                sectionBorder = 'border-top: 1px solid #e5e5e5;';
            end

            % Monta a seção completa do site, combinando cabeçalho, metadados
            % e todas as estações associadas.
            html = sprintf([ ...
                '<section style="%s padding: 12px 12px 12px 12px; background-color: #ffffff;">' ...
                '<p style="margin: 0 0 2px 0;">' ...
                '<strong style="font-size: 12px; color: #202020;">%s</strong>' ...
                '</p>' ...
                '<p style="margin: 0; color: #707070; font-size: 10px;">ID %d   %s</p>' ...
                '%s' ...
                '</section>'], ...
                sectionBorder, ...
                char(esc(app, popupSite.point.site_label)), ...
                popupSite.siteId, ...
                char(strjoin(metaParts, ' • ')), ...
                char(strjoin(stationSections, '')) ...
                );
        end

        function html = renderPopupStationHTML(app, siteId, station)
            % Renderiza o bloco HTML de uma estação dentro de um site do popup.
            %
            % A saída inclui:
            % - nome exibido da estação
            % - status visual
            % - indicação de posição atual ou histórica
            % - data da última observação, quando existir
            % - botão para abrir os arquivos no dock

            % Resolve o nome exibido e a aparência do status da estação.
            stationName = char(esc(app, chooseName(app, station)));
            [statusText, statusColor] = stationStatus(app, station);

            % Identifica se a posição exibida é atual ou histórica.
            locationText = 'Posicao atual';
            if ~station.is_current_location
                locationText = 'Posicao historica';
            end

            % Exibe a última observação apenas quando essa informação existir.
            lastSeenHTML = '';
            if ~isempty(station.last_seen_at)
                lastSeenHTML = sprintf( ...
                    '<br><font size="1" color="#707070">Ultima visao: %s</font>', ...
                    char(esc(app, string(station.last_seen_at))));
            end

            % O botão carrega no HTML os identificadores usados pelo bridge
            % para abrir o dock de arquivos contextualizado para esta estação.
            buttonHTML = sprintf([ ...
                '<p style="margin: 8px 0 0 0; text-align: right;">' ...
                '<button type="button" class="repo-sfi-open-dock" ' ...
                'data-site-id="%d" data-equipment-id="%d" data-host-id="%d" ' ...
                'style="background-color: #f6f6f6; color: #303030; border: 1px solid #d1d1d1; border-radius: 3px; padding: 6px 12px; font-family: Helvetica, Arial, sans-serif; font-size: 11px; font-weight: bold; cursor: pointer; min-height: 31px;">' ...
                'Abrir arquivos' ...
                '</button>' ...
                '</p>'], ...
                siteId, popupNumericValue(app, station.equipment_id), popupNumericValue(app, station.host_id));

            % Estrutura final da estação dentro do popup.
            html = sprintf([ ...
                '<section style="margin: 0; padding: 10px 0 0 0; background-color: transparent; font-family: Helvetica, Arial, sans-serif;">' ...
                '<p style="margin: 0 0 2px 0; border-left: 3px solid %s; padding-left: 8px; line-height: 1.25;">' ...
                '<strong style="color: #202020;">%s</strong>' ...
                '</p>' ...
                '<p style="margin: 0 0 3px 0; padding-left: 11px; line-height: 1.2;">' ...
                '<font color="%s" size="2"><strong>%s</strong></font>' ...
                '</p>' ...
                '<p style="margin: 0; padding-left: 11px; line-height: 1.25;">' ...
                '<font size="2" color="#606060">%s</font>%s' ...
                '</p>' ...
                '%s' ...
                '</section>'], ...
                statusColor, stationName, statusColor, statusText, locationText, lastSeenHTML, buttonHTML);
        end


        %-----------------------------------------------------------------%
        % Seleção de Estações pelo click do mouse no mapa
        %-----------------------------------------------------------------%
        function selectionRadius = getAdaptiveSelectionRadius(~,zoomSpan)
            % Ajusta o raio de selecao ao nivel de zoom do mapa.
            if zoomSpan >= 45
                selectionRadius = max(0.30, zoomSpan * 0.015);
            elseif zoomSpan >= 20
                selectionRadius = max(0.20, zoomSpan * 0.012);
            elseif zoomSpan >= 5
                selectionRadius = max(0.10, zoomSpan * 0.010);
            else
                selectionRadius = max(0.05, zoomSpan * 0.008);
            end
        end


        function selectionInfo = resolveSiteSelection(app, requestedSiteId, mapDataSet, src, event)
            % Resolve a seleção efetiva de sites a partir de um clique no mapa.
            %
            % Em níveis de zoom mais abertos, um clique pode representar não apenas
            % o site originalmente identificado, mas também localidades próximas.
            % A função agrupa esses sites vizinhos para montar um popup coerente
            % com o contexto visual atual.

            % Estado default: assume seleção simples contendo apenas o site pedido.
            % Esse fallback é preservado caso qualquer etapa de refinamento falhe.
            selectionInfo = struct( ...
                'siteId', requestedSiteId, ...
                'siteIds', requestedSiteId, ...
                'isAmbiguous', false, ...
                'nearbyCount', 1, ...
                'zoomSpan', NaN);

            % Sem dataset válido ou sem pontos no mapa não há como expandir a seleção.
            if ~isstruct(mapDataSet) || ~isfield(mapDataSet, 'points') || isempty(mapDataSet.points)
                return
            end

            % Confirma que o site solicitado realmente existe entre os pontos visíveis.
            pointIdx = find([mapDataSet.points.site_id] == requestedSiteId, 1);
            if isempty(pointIdx)
                return
            end

            % Tenta usar a coordenada real do clique.
            % Se ela não estiver disponível, cai para a posição do site original.
            [clickLat, clickLon] = extractMapClickCoordinates(app, src, event);
            if ~isfinite(clickLat) || ~isfinite(clickLon)
                clickLat = double(mapDataSet.points(pointIdx).latitude);
                clickLon = double(mapDataSet.points(pointIdx).longitude);
            end

            % Extrai as coordenadas de todos os pontos candidatos.
            allLat = double([mapDataSet.points.latitude].');
            allLon = double([mapDataSet.points.longitude].');

            % O cálculo da ambiguidade depende do estado atual de zoom do mapa.
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            % Mede a abertura atual do mapa em latitude e longitude.
            % A longitude é corrigida pelo cosseno da latitude para reduzir
            % distorções horizontais.
            latLimits = app.UIAxes.LatitudeLimits;
            lonLimits = app.UIAxes.LongitudeLimits;
            latSpan = abs(diff(latLimits));
            lonSpan = abs(diff(lonLimits)) * max(cosd(clickLat), 0.25);
            zoomSpan = max(latSpan, lonSpan);

            % Calcula a distância aproximada de cada ponto ao local do clique.
            % A mesma correção angular é aplicada no eixo longitudinal.
            distance = hypot(allLat - clickLat, (allLon - clickLon) .* max(cosd(clickLat), 0.25));

            % Define o raio de agrupamento conforme o nível de zoom atual.
            % Quanto mais aberto o mapa, maior a tolerância para agrupar sites próximos.
            selectionRadius = getAdaptiveSelectionRadius(app, zoomSpan);
            nearbyIdx = find(distance <= selectionRadius);

            % Se nenhum ponto caiu dentro do raio, ao menos mantém o mais próximo.
            if isempty(nearbyIdx)
                [~, nearbyIdx] = min(distance);
            end

            % Ordena os candidatos do mais próximo para o mais distante.
            % O primeiro passa a ser o site principal da seleção.
            [~, sortIdx] = sort(distance(nearbyIdx), 'ascend');
            nearbyIdx = nearbyIdx(sortIdx);

            % Materializa a seleção final em ordem de proximidade ao clique.
            selectionInfo.siteIds = double([mapDataSet.points(nearbyIdx).site_id]);
            selectionInfo.siteId = selectionInfo.siteIds(1);
            selectionInfo.nearbyCount = numel(selectionInfo.siteIds);
            selectionInfo.zoomSpan = zoomSpan;

            % Considera a seleção ambígua apenas quando há múltiplos sites e o
            % mapa está suficientemente aberto para justificar o agrupamento.
            selectionInfo.isAmbiguous = selectionInfo.nearbyCount > 1 && zoomSpan >= 1.0;
        end


        function [clickLat, clickLon] = extractMapClickCoordinates(~, src, event)
            % Tenta recuperar a coordenada do clique a partir do evento ou do source.
            clickLat = NaN;
            clickLon = NaN;

            try
                if isprop(event, 'IntersectionPoint')
                    intersectionPoint = event.IntersectionPoint;
                    if isnumeric(intersectionPoint) && numel(intersectionPoint) >= 2
                        clickLat = double(intersectionPoint(1));
                        clickLon = double(intersectionPoint(2));
                        return
                    end
                end
            catch
            end

            try
                if isprop(src, 'LatitudeData') && isprop(src, 'LongitudeData')
                    if ~isempty(src.LatitudeData) && ~isempty(src.LongitudeData)
                        clickLat = double(src.LatitudeData(1));
                        clickLon = double(src.LongitudeData(1));
                    end
                end
            catch
            end
        end


        %-----------------------------------------------------------------%
        % Tab de Pesquisa de Arquivos
        %-----------------------------------------------------------------%
        function initializeFilesSearchPanel(app)
            % Initializes the file search panel and loads base station options.
            %
            % Called during applyInitialLayout and on full reset. Safe to call
            % repeatedly because it clears all transient state before repopulating.
            %
            % Side effects: resets all files* controls and clears filesLocalityRows.

            if isempty(app.dbHandler)
                app.dbHandler = util.DBHandler();
            end

            app.filesLocalityRows        = table();
            app.filesStartDatePicker.Value = NaT;
            app.filesEndDatePicker.Value   = NaT;
            %app.filesFrequencyStartEditField.Value = NaN;
            %app.filesFrequencyEndEditField.Value   = NaN;
            app.filesDescriptionEditField.Value    = '';

            loadFilesStationOptions(app)
            updateFilesLocationOptions(app, NaN)
        end




        function loadFilesStationOptions(app)
            % Loads station/equipment options for the repository search dropdown.
            %
            % Queries the full equipment catalog and rebuilds Items/ItemsData.
            % Preserves the current selection when the refreshed list still
            % contains it, so a reload triggered by a filter change does not
            % silently reset the user's choice.
            %
            % Note: the former online-only filter (filesOnlineCheckBox) was
            % removed. filesStatusDropDown is now the single control for
            % scoping the map and station list by online/offline status.

            rows = app.dbHandler.getSpectrumEquipments();

            items     = {'Selecione uma estação/equipamento'};
            itemsData = {''};

            selectedValue = string(app.filesStationDropDown.Value);

            if istable(rows) && ~isempty(rows)
                for ii = 1:height(rows)
                    equipmentId   = formatNumericId(app, rows.ID_EQUIPMENT(ii));
                    equipmentName = displayRawText(app, rows.NA_EQUIPMENT(ii), '(sem nome)');
                    items{end + 1}     = char(equipmentName); %#ok<AGROW>
                    itemsData{end + 1} = char(equipmentId);   %#ok<AGROW>
                end
            end

            app.filesStationDropDown.Items     = items;
            app.filesStationDropDown.ItemsData = itemsData;

            if any(strcmp(itemsData, char(selectedValue)))
                app.filesStationDropDown.Value = char(selectedValue);
            else
                app.filesStationDropDown.Value = '';
            end
        end

        function updateFilesLocationOptions(app, preferredSiteId)
            % Recarrega as localidades disponíveis para o equipamento atualmente
            % selecionado na aba Arquivos.
            %
            % A função:
            % - lê o equipamento selecionado
            % - consulta as localidades correspondentes
            % - reconstrói o dropdown de localidades
            % - tenta aplicar uma localidade preferencial
            % - atualiza a janela de período disponível

            % O dropdown sempre começa com a opção de abrangência total.
            equipmentId = selectedDropDownNumericValue(app, app.filesStationDropDown);
            items = {'Todas as localidades'};
            itemsData = {''};

            % Mantém em memória as linhas retornadas pela consulta para uso posterior
            % em outras rotinas, como atualização de período.
            app.filesLocalityRows = table();

            % Só há localidades para carregar quando existe um equipamento válido.
            if ~isnan(equipmentId)
                app.filesLocalityRows = app.dbHandler.getSpectrumLocalities(equipmentId);

                % Converte as linhas retornadas em Items/ItemsData do dropdown.
                if istable(app.filesLocalityRows) && ~isempty(app.filesLocalityRows)
                    for ii = 1:height(app.filesLocalityRows)
                        siteId = formatNumericId(app, app.filesLocalityRows.ID_SITE(ii));
                        localityLabel = formatFilesLocalityOption(app, app.filesLocalityRows(ii, :));

                        items{end + 1} = char(localityLabel); %#ok<AGROW>
                        itemsData{end + 1} = char(siteId); %#ok<AGROW>
                    end
                end
            end

            % Publica as opções calculadas no componente visual.
            app.filesLocationDropDown.Items = items;
            app.filesLocationDropDown.ItemsData = itemsData;

            % Tenta selecionar a localidade preferencial, quando ela ainda existir
            % na lista recém-carregada; caso contrário, volta para a opção geral.
            preferredSiteId = formatNumericId(app, preferredSiteId);
            if strlength(preferredSiteId) > 0 && any(strcmp(itemsData, char(preferredSiteId)))
                app.filesLocationDropDown.Value = char(preferredSiteId);
            else
                app.filesLocationDropDown.Value = '';
            end

            % A mudança de localidades altera também a janela temporal disponível.
            updateFilesAvailablePeriod(app)
        end

        function updateFilesAvailablePeriod(app)
            % Atualiza o período inicial e final disponível para a seleção atual
            % de equipamento/localidade na aba Arquivos.
            %
            % A função usa o cache de localidades carregado anteriormente em
            % app.filesLocalityRows e extrai dele a menor e a maior data válidas.

            % Reinicia os date pickers antes de recalcular os limites.
            app.filesStartDatePicker.Value = NaT;
            app.filesEndDatePicker.Value = NaT;

            % Sem linhas disponíveis não há período a inferir.
            if ~istable(app.filesLocalityRows) || isempty(app.filesLocalityRows)
                return
            end

            selectedSiteId = selectedDropDownNumericValue(app, app.filesLocationDropDown);
            rows = app.filesLocalityRows;

            % Se uma localidade específica foi escolhida, restringe o cálculo do
            % período apenas às linhas associadas a esse site.
            if ~isnan(selectedSiteId) && ismember('ID_SITE', rows.Properties.VariableNames)
                siteValues = str2double(string(rows.ID_SITE));
                rows = rows(siteValues == selectedSiteId, :);
            end

            % Extrai a menor data inicial e a maior data final do subconjunto ativo.
            startDate = extractMinDateFromRows(app, rows, 'DATE_START');
            endDate = extractMaxDateFromRows(app, rows, 'DATE_END');

            % Só publica valores válidos nos componentes.
            if ~isnat(startDate)
                app.filesStartDatePicker.Value = startDate;
            end

            if ~isnat(endDate)
                app.filesEndDatePicker.Value = endDate;
            end
        end


        function dockContext = buildFilesDockContext(app)
            % Builds the context payload passed to the files dock on open.
            %
            % Reads current search controls and normalizes invalid or negative
            % frequency values to NaN (meaning "no filter"). The dock always
            % runs a spectrum-aware query returning one row per repository file;
            % there is no longer a mode switch in this payload.

            freqStart   = app.filesFrequencyStartEditField.Value;
            freqEnd     = app.filesFrequencyEndEditField.Value;
            description = strtrim(string(app.filesDescriptionEditField.Value));

            if isempty(freqStart) || ~isfinite(freqStart) || freqStart < 0
                freqStart = NaN;
            end

            if isempty(freqEnd) || ~isfinite(freqEnd) || freqEnd < 0
                freqEnd = NaN;
            end

            [startDate, endDate] = getNormalizedFilterDateRange(app);

            dockContext = struct( ...
                'equipmentId', selectedDropDownNumericValue(app, app.filesStationDropDown), ...
                'siteId',      selectedDropDownNumericValue(app, app.filesLocationDropDown), ...
                'hostId',      [], ...
                'startDate',   startDate, ...
                'endDate',     endDate, ...
                'freqStart',   freqStart, ...
                'freqEnd',     freqEnd, ...
                'description', description ...
                );
        end

        function openRepoFilesDock(app, dockContext)
            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RepoFiles', app.Context, dockContext)
        end

        function output = selectedDropDownNumericValue(~, dropDownHandle)
            output = str2double(string(dropDownHandle.Value));
            if isnan(output)
                output = NaN;
            end
        end

        function output = formatFilesLocalityOption(app, row)
            output = displayRawText(app, row.LOCALITY_LABEL, '-');
            county = displayRawText(app, row.COUNTY_NAME, '');
            stateCode = displayRawText(app, row.STATE_CODE, '');

            suffix = "";
            if strlength(county) > 0 && strlength(stateCode) > 0
                suffix = county + "/" + stateCode;
            elseif strlength(county) > 0
                suffix = county;
            elseif strlength(stateCode) > 0
                suffix = stateCode;
            end

            if strlength(suffix) > 0 && ~strcmpi(char(output), char(suffix))
                output = output + " (" + suffix + ")";
            end
        end

        function output = displayRawText(~, rawValue, defaultValue)
            value = rawValue;
            while iscell(value)
                if isempty(value)
                    value = [];
                    break
                end
                value = value{1};
            end

            if isempty(value)
                output = string(defaultValue);
                return
            end

            if isstring(value)
                if all(ismissing(value))
                    output = string(defaultValue);
                    return
                end
                output = strtrim(value(1));
            elseif ischar(value)
                output = string(strtrim(value));
            else
                output = strtrim(string(value));
            end

            if strlength(output) == 0
                output = string(defaultValue);
            end
        end

        function output = formatNumericId(~, rawValue)
            numericValue = str2double(string(rawValue));
            if isnan(numericValue)
                output = "";
            else
                output = string(round(numericValue));
            end
        end

        function output = extractMinDateFromRows(app, rows, fieldName)
            output = NaT;

            if ~istable(rows) || isempty(rows) || ~ismember(fieldName, rows.Properties.VariableNames)
                return
            end

            values = NaT(height(rows), 1);
            for ii = 1:height(rows)
                values(ii) = rawToDatetime(app, rows.(fieldName)(ii));
            end

            values = values(~isnat(values));
            if ~isempty(values)
                output = min(values);
            end
        end

        function output = extractMaxDateFromRows(app, rows, fieldName)
            output = NaT;

            if ~istable(rows) || isempty(rows) || ~ismember(fieldName, rows.Properties.VariableNames)
                return
            end

            values = NaT(height(rows), 1);
            for ii = 1:height(rows)
                values(ii) = rawToDatetime(app, rows.(fieldName)(ii));
            end

            values = values(~isnat(values));
            if ~isempty(values)
                output = max(values);
            end
        end

        function output = rawToDatetime(~, rawValue)
            output = NaT;
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    return
                end
                value = value{1};
            end

            if isempty(value)
                return
            end

            try
                if isdatetime(value)
                    output = value(1);
                else
                    output = datetime(value);
                end
            catch
                output = NaT;
            end
        end

        function openRepoFilesDockForStation(app, siteId, equipmentId, hostId)
            % Abre o dock de arquivos usando os identificadores da estacao clicada.
            dockContext = struct( ...
                'siteId', siteId, ...
                'equipmentId', equipmentId, ...
                'hostId', hostId ...
                );

            openRepoFilesDock(app, dockContext)
        end

        %-----------------------------------------------------------------%
        % Popup helpers
        %-----------------------------------------------------------------%
        function value = popupNumericValue(~, rawValue)
            % Normaliza campos numericos opcionais para consumo no HTML.
            if isempty(rawValue)
                value = -1;
                return
            end

            if iscell(rawValue)
                rawValue = rawValue{1};
            end

            if isempty(rawValue)
                value = -1;
                return
            end

            value = double(rawValue);
        end

        function name = chooseName(app, st)
            % Prioriza host_name; usa equipment_name como fallback.
            hostName = normalizeTextFromValue(app, st.host_name);
            equipmentName = normalizeTextFromValue(app, st.equipment_name);

            if strlength(hostName) > 0
                name = hostName;
            elseif strlength(equipmentName) > 0
                name = equipmentName;
            else
                name = "Estacao";
            end
        end

        function [txt, color] = stationStatus(app, st)
            % Mapeia o estado da estacao para rotulo e cor do popup.
            switch string(st.map_state)
                case "online_current"
                    txt = "Online";
                    color = "#4f7f67";
                case "online_previous"
                    txt = "Online historico";
                    color = "#4f7f67";
                case "offline_current"
                    txt = "Offline";
                    color = "#b88352";
                case "offline_previous"
                    txt = "Offline historico";
                    color = "#b88352";
                otherwise
                    txt = "Sem host";
                    color = "#7b8aa0";
            end
        end

        function out = esc(app, value)
            % Escapa caracteres HTML minimos para evitar markup quebrado.
            out = string(value);
            out = replace(out, "&", "&amp;");
            out = replace(out, "<", "&lt;");
            out = replace(out, ">", "&gt;");
        end

        function refreshFilteredMap(app, viewportMode)
            % Atualiza o dataset filtrado e replota o mapa com a regra de viewport informada.
            if nargin < 2
                viewportMode = "preserve_if_all_states";
            end

            updateFilteredRepoSFI(app)
            plot_Stations(app, viewportMode)
        end

        function updateFilteredRepoSFI(app)
            % Recalcula o dataset filtrado a partir do estado atual da interface.
            app.filteredRepoSFI = getAppliedFilter(app);

            if ~isempty(app.filesCountLabel)
                app.filesCountLabel.Text = sprintf('%d localidade(s) visíveis', numel(app.filteredRepoSFI.points));
            end
        end

        %-----------------------------------------------------------------%




        %-----------------------------------------------------------------%
        % Filtros e normalizacao
        function filteredData = getAppliedFilter(app)
            % Aplica os filtros ativos da interface e devolve o dataset filtrado.
            %
            % A saída é a fonte única de verdade consumida pelo plot do mapa,
            % popup e seleção de localidades.

            filteredData = struct('points', struct([]), 'site_details', struct([]));

            if isempty(app.repoSFI) || ~isstruct(app.repoSFI) || ~isfield(app.repoSFI, 'points') || ~isfield(app.repoSFI, 'site_details')
                return
            end

            basePoints = app.repoSFI.points;
            baseSiteDetails = app.repoSFI.site_details;

            if isempty(basePoints)
                return
            end

            filteredPoints = basePoints([]);
            filteredSiteDetails = baseSiteDetails([]);

            stateFilter    = "Todos os estados";
            statusFilter   = "Todos";
            localityFilter = "Todas";
            equipmentFilter = NaN;

            if ~isempty(app.filesStateDropDown)
                stateFilter = string(app.filesStateDropDown.Value);
            end

            if ~isempty(app.filesStatusDropDown)
                statusFilter = string(app.filesStatusDropDown.Value);
            end

            if ~isempty(app.filesLocalityDropDown)
                localityFilter = string(app.filesLocalityDropDown.Value);
            end

            % When the user selects an equipment in the files search panel, the map
            % acts as a locator: only sites linked to that equipment remain visible.
            if ~isempty(app.filesStationDropDown)
                equipmentFilter = selectedDropDownNumericValue(app, app.filesStationDropDown);
            end

            [startDt, endDate] = getNormalizedFilterDateRange(app);
            if isnat(endDate)
                endBefore = NaT;
            else
                endBefore = endDate + days(1);
            end
            hasDateFilter = ~isnat(startDt) || ~isnat(endBefore);

            for ii = 1:numel(basePoints)
                basePoint = basePoints(ii);

                if numel(baseSiteDetails) >= ii && baseSiteDetails(ii).site_id == basePoint.site_id
                    detail = baseSiteDetails(ii);
                else
                    detailIdx = find([baseSiteDetails.site_id] == basePoint.site_id, 1);
                    if isempty(detailIdx)
                        continue
                    end
                    detail = baseSiteDetails(detailIdx);
                end

                filteredDetail = detail;

                if hasDateFilter || statusFilter ~= "Todos" || localityFilter ~= "Todas" || ~isnan(equipmentFilter)
                    filteredDetail = filterSiteDetailStations(app, detail, statusFilter, localityFilter, equipmentFilter, startDt, endBefore);
                    if isempty(filteredDetail.stations)
                        continue
                    end
                end

                filteredPoint = buildPointFromDetail(app, basePoint, filteredDetail);

                if stateFilter ~= "Todos os estados"
                    pointStateCode = normalizeText(app, filteredPoint.state_code);
                    if strlength(pointStateCode) == 0 || pointStateCode ~= stateFilter
                        continue
                    end
                end

                if ~pointMatchesStatus(app, filteredPoint, statusFilter)
                    continue
                end

                if ~detailMatchesLocality(app, filteredDetail, localityFilter)
                    continue
                end

                filteredPoints(end + 1, 1) = filteredPoint; %#ok<AGROW>
                filteredSiteDetails(end + 1, 1) = filteredDetail; %#ok<AGROW>
            end

            filteredData.points = filteredPoints;
            filteredData.site_details = filteredSiteDetails;
        end

        function output = getDateFilterValue(app, pickerHandle, mode)
            % Converte o valor do date picker para o intervalo usado na filtragem.
            output = NaT;

            if isempty(pickerHandle)
                return
            end

            rawValue = pickerHandle.Value;
            value = normalizeToDatetime(app, rawValue);

            if isnat(value)
                return
            end

            value = dateshift(value, 'start', 'day');

            if mode == "end_before"
                output = value + days(1);
            else
                output = value;
            end
        end

        function [startDate, endDate] = getNormalizedFilterDateRange(app)
            % Normaliza o intervalo selecionado para evitar janelas invertidas.
            startDate = normalizeToDatetime(app, app.filesStartDatePicker.Value);
            endDate = normalizeToDatetime(app, app.filesEndDatePicker.Value);

            if isnat(startDate) || isnat(endDate)
                return
            end

            startDate = dateshift(startDate, 'start', 'day');
            endDate = dateshift(endDate, 'start', 'day');

            if startDate > endDate
                endDate = startDate;
                app.filesEndDatePicker.Value = endDate;
            end
        end

             

        function output = filterSiteDetailStations(app, detail, statusFilter, localityFilter, equipmentFilter, startDt, endBefore)
            % Mantem no detalhe apenas as estacoes compativeis com os filtros ativos.
            output = detail;

            if isempty(detail.stations)
                output = rebuildFilteredSiteDetail(app, output, detail.stations([]));
                return
            end

            stations = detail.stations;
            keepMask = true(numel(stations), 1);

            for ii = 1:numel(stations)
                station = stations(ii);

                if ~stationMatchesDateFilter(app, station, startDt, endBefore)
                    keepMask(ii) = false;
                    continue
                end

                if ~stationMatchesStatusFilter(app, station, statusFilter)
                    keepMask(ii) = false;
                    continue
                end

                if ~stationMatchesLocalityFilter(app, station, localityFilter)
                    keepMask(ii) = false;
                    continue
                end

                if ~stationMatchesEquipmentFilter(app, station, equipmentFilter)
                    keepMask(ii) = false;
                end
            end

            output = rebuildFilteredSiteDetail(app, output, stations(keepMask));
        end

        function output = rebuildFilteredSiteDetail(app, detail, stations)
            % Reconstroi o estado agregado do site a partir das estacoes restantes.
            output = detail;
            output.stations = stations;

            if isempty(output.stations)
                output.marker_state = "no_host";
                output.has_online_station = false;
                output.has_online_host = false;
                output.has_known_host = false;
                return
            end

            output.marker_state = summarizeSiteMarkerState(app, output.stations);
            stationStates = string({output.stations.map_state});
            output.has_online_station = any(stationStates == "online_current" | stationStates == "online_previous");
            output.has_online_host = output.has_online_station;
            output.has_known_host = any(~arrayfun(@(station) isempty(station.host_id), output.stations));
        end

        function output = stationMatchesDateFilter(app, station, startDt, endBefore)
            % Avalia se a estacao intercepta a janela temporal ativa.
            if isnat(startDt) && isnat(endBefore)
                output = true;
            else
                output = stationOverlapsDateRange(app, station, startDt, endBefore);
            end
        end

        function output = stationMatchesStatusFilter(~, station, statusFilter)
            % Avalia o filtro de status no nivel da estacao.
            switch string(statusFilter)
                case "Apenas online"
                    output = any(string(station.map_state) == ["online_current", "online_previous"]);
                case "Apenas offline"
                    output = any(string(station.map_state) == ["offline_current", "offline_previous"]);
                otherwise
                    output = true;
            end
        end

        function output = stationMatchesLocalityFilter(~, station, localityFilter)
            % Avalia o filtro de posicao atual ou historica no nivel da estacao.
            switch string(localityFilter)
                case "Apenas atuais"
                    output = logical(station.is_current_location);
                case "Apenas históricas"
                    output = ~logical(station.is_current_location);
                otherwise
                    output = true;
            end
        end

        function output = stationMatchesEquipmentFilter(~, station, equipmentFilter)
            % Avalia o filtro de equipamento no nivel da estacao.
            if isnan(equipmentFilter)
                output = true;
                return
            end

            output = str2double(string(station.equipment_id)) == equipmentFilter;
        end


        function output = stationOverlapsDateRange(app, station, startDt, endBefore)
            % Testa se a estacao teve vigencia dentro da janela selecionada.
            firstSeen = normalizeToDatetime(app, station.first_seen_at);
            lastSeen = normalizeToDatetime(app, station.last_seen_at);

            if isnat(firstSeen) && isnat(lastSeen)
                output = false;
                return
            end

            if isnat(firstSeen)
                intervalStart = lastSeen;
            else
                intervalStart = firstSeen;
            end

            if isnat(lastSeen)
                intervalEnd = firstSeen;
            else
                intervalEnd = lastSeen;
            end

            if ~isnat(startDt) && intervalEnd < startDt
                output = false;
                return
            end

            if ~isnat(endBefore) && intervalStart >= endBefore
                output = false;
                return
            end

            output = true;
        end

        function output = normalizeToDatetime(~, rawValue)
            % Aceita tipos heterogeneos do backend e converte para datetime.
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    output = NaT;
                    return
                end

                value = value{1};
            end

            if isempty(value)
                output = NaT;
                return
            end

            if isdatetime(value)
                output = value(1);
                return
            end

            if isstring(value)
                if all(ismissing(value)) || strlength(strtrim(value(1))) == 0
                    output = NaT;
                    return
                end

                value = value(1);
                try
                    output = datetime(value);
                catch
                    try
                        output = datetime(value, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
                    catch
                        output = NaT;
                    end
                end
                return
            end

            if ischar(value)
                if isempty(strtrim(value))
                    output = NaT;
                    return
                end

                try
                    output = datetime(string(value));
                catch
                    try
                        output = datetime(string(value), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
                    catch
                        output = NaT;
                    end
                end
                return
            end

            if isnumeric(value)
                try
                    output = datetime(value(1), 'ConvertFrom', 'datenum');
                catch
                    output = NaT;
                end
                return
            end

            output = NaT;
        end

        function output = buildPointFromDetail(app, basePoint, detail)
            % Reconstroi o ponto publico a partir do detalhe filtrado por data.
            pointStations = emptyPublicStationArray(app);
            stationNames = strings(0, 1);

            for ii = 1:numel(detail.stations)
                publicStation = buildPublicStation(app, detail.stations(ii));
                pointStations(end + 1, 1) = publicStation; %#ok<AGROW>

                stationName = chooseName(app, detail.stations(ii));
                if strlength(stationName) > 0
                    stationNames(end + 1, 1) = stationName; %#ok<AGROW>
                end
            end

            output = basePoint;
            output.stations = pointStations;
            output.station_names = stationNames;
            output.marker_state = detail.marker_state;
            output.has_online_station = detail.has_online_station;
            output.has_online_host = detail.has_online_host;
            output.has_known_host = detail.has_known_host;
        end

        function output = emptyPublicStationArray(~)
            % Mantem a estrutura esperada pelos pontos publicos do mapa.
            output = struct( ...
                'equipment_id', cell(0, 1), ...
                'equipment_name', cell(0, 1), ...
                'host_id', cell(0, 1), ...
                'host_name', cell(0, 1), ...
                'is_offline', cell(0, 1), ...
                'is_current_location', cell(0, 1), ...
                'map_state', cell(0, 1) ...
                );
        end

        function output = buildPublicStation(~, station)
            % Extrai apenas os campos usados fora do detalhe completo do site.
            output = struct( ...
                'equipment_id', station.equipment_id, ...
                'equipment_name', station.equipment_name, ...
                'host_id', station.host_id, ...
                'host_name', station.host_name, ...
                'is_offline', station.is_offline, ...
                'is_current_location', station.is_current_location, ...
                'map_state', station.map_state ...
                );
        end

        function output = summarizeSiteMarkerState(app, stations)
            % Escolhe o estado visual dominante entre as estacoes do site.
            if isempty(stations)
                output = "no_host";
                return
            end

            output = "no_host";
            bestPriority = mapStatePriority(app, output);

            for ii = 1:numel(stations)
                stationState = string(stations(ii).map_state);
                statePriority = mapStatePriority(app, stationState);

                if statePriority < bestPriority
                    output = stationState;
                    bestPriority = statePriority;
                end
            end
        end

        function output = mapStatePriority(~, stateKey)
            % Prioridade menor significa maior destaque visual no mapa.
            switch string(stateKey)
                case "online_current"
                    output = 0;
                case "online_previous"
                    output = 1;
                case "offline_current"
                    output = 2;
                case "offline_previous"
                    output = 3;
                otherwise
                    output = 4;
            end
        end

        function output = pointMatchesStatus(~, point, statusFilter)
            % Filtra pelo estado agregado exibido no marcador.
            markerState = string(point.marker_state);

            switch string(statusFilter)
                case "Apenas online"
                    output = any(markerState == ["online_current", "online_previous"]);
                case "Apenas offline"
                    output = any(markerState == ["offline_current", "offline_previous"]);
                otherwise
                    output = true;
            end
        end

        function output = detailMatchesLocality(~, detail, localityFilter)
            % Filtra por localizacao atual ou historica entre as estacoes do site.
            if isempty(detail.stations)
                output = false;
                return
            end

            currentMask = logical([detail.stations.is_current_location]);

            switch string(localityFilter)
                case "Apenas atuais"
                    output = any(currentMask);
                case "Apenas históricas"
                    output = any(~currentMask);
                otherwise
                    output = true;
            end
        end

        

        function output = normalizeTextFromValue(app, rawValue)
            % Normaliza valores textuais heterogeneos para string escalar limpa.
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    output = "";
                    return
                end

                value = value{1};
            end

            if isempty(value)
                output = "";
                return
            end

            if isstring(value)
                if all(ismissing(value))
                    output = "";
                    return
                end

                output = strtrim(value(1));
            elseif ischar(value)
                output = string(strtrim(value));
            else
                output = strtrim(string(value));
            end

            if strlength(output) == 0
                output = "";
            end
        end

        function output = normalizeText(app, rawValue)
            % Alias semantico para manter legibilidade nos pontos de uso.
            output = normalizeTextFromValue(app, rawValue);
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

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', app.Context)
            delete(app)

        end

        % Callback function
        function DockModuleGroup_ButtonPushed(app, event)

            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;

                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')

                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Image clicked function: tool_PDFButton, tool_PanelVisibility, 
        % ...and 2 other components
        function Toolbar_InteractionImageClicked(app, event)

            switch event.Source
                case app.tool_PanelVisibility
                    if app.SubTabGroup.Visible
                        app.tool_PanelVisibility.ImageSource = 'layout-sidebar-left-off.svg';
                        app.SubTabGroup.Visible = 0;
                        app.Document.Layout.Column = [2 5];
                    else
                        app.tool_PanelVisibility.ImageSource = 'layout-sidebar-left.svg';
                        app.SubTabGroup.Visible = 1;
                        app.Document.Layout.Column = [4 5];
                    end

                case app.tool_TableVisibility
                    app.tool_TableVisibility.UserData.layout = mod(app.tool_TableVisibility.UserData.layout + 1, 3);
                    switch app.tool_TableVisibility.UserData.layout
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
                    app.tool_PDFButton.UserData.status = ~app.tool_PDFButton.UserData.status;
                    if app.tool_PDFButton.UserData.status
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout.
                        if app.tool_TableVisibility.UserData.layout == 2
                            app.tool_TableVisibility.UserData.layout = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                        end

                        app.Document.ColumnWidth(4:7) = {10,22,22,'1x'};
                    else
                        app.Document.ColumnWidth(4:7) = {0,0,0,0};
                    end
                    misc_getChannelReport(app, 'Cache+RealTime')

                case app.tool_RFLinkButton
                    app.tool_RFLinkButton.UserData.status = ~app.tool_RFLinkButton.UserData.status;
                    if app.tool_RFLinkButton.UserData.status
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout. O pause é uma espécie de "drawnow"
                        % e garante que o plot será realizado corretamente.
                        if app.tool_TableVisibility.UserData.layout == 2
                            app.tool_TableVisibility.UserData.layout = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                            pause(.100)
                        end

                        app.UIAxes.Layout.TileSpan = [1,2];
                        set(findobj(app.UIAxes2), 'Visible', 1)
                    else
                        app.UIAxes.Layout.TileSpan = [2,2];
                        set(findobj(app.UIAxes2), 'Visible', 0)
                    end
                    plot_createRFLinkPlot(app)
            end

        end

        % Image clicked function: tool_ExportButton
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

        % Menu selected function: contextmenu_del, contextmenu_delAll
        function filter_delFilter(app, event)

            if isempty(app.FilterRules)
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
                    idx1 = [idx1, find(ismember(app.FilterRules.RelatedID, idx1))'];

                case app.contextmenu_delAll
                    idx1 = 1:height(app.FilterRules);
            end

            if ~isempty(idx1)
                removeFilterRule(app, idx1);
            end

        end

        % Value changed function: filesLocalityDropDown, 
        % ...and 2 other components
        function onStationFilterChanged(app, event)

            viewportMode = "preserve_if_all_states";

            if isequal(event.Source, app.filesStateDropDown)
                viewportMode = "fit";
            end

            refreshFilteredMap(app, viewportMode)

        end

        % Image clicked function: axesTool_RegionZoom, axesTool_RestoreView
        function onAxesToolbarZoomControlButtonClicked(app, event)
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            switch event.Source
                case app.axesTool_RestoreView
                    restoreMapView(app)

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes, app.axesTool_RegionZoom)
            end
        end

        % Button pushed function: filesSearchButton
        function onSearchClick(app, event)
            openRepoFilesDock(app, buildFilesDockContext(app));
        end

        % Value changed function: filesStationDropDown
        function onStationChanged(app, event)
            % Selecting a station in the search panel re-filters the map so the
            % user immediately sees where that equipment's sites are located.
            % getAppliedFilter reads filesStationDropDown as a map filter (Batch 3).
            refreshFilteredMap(app, "fit");

        end

        % Value changed function: configMapStyleDropDown
        function onMapStyleChanged(app, event)
            applySelectedMapStyle(app);

        end

        % Selection change function: SubTabGroup
        function onSubTabChanged(app, event)
            %applyJSCustomizations(app);

        end

        % Value changed function: filesLocationDropDown
        function onLocationChanged(app, event)
            updateFilesAvailablePeriod(app);
            refreshFilteredMap(app, "preserve_if_all_states");
        end

        % Value changed function: filesEndDatePicker, filesStartDatePicker
        function onDateChanged(app, event)
           % Reaplica o filtro após consolidar um intervalo temporal válido.
            getNormalizedFilterDateRange(app);
            refreshFilteredMap(app, "preserve_if_all_states")
            
        end

        % Button pushed function: filesCleanButton
        function onCleanClick(app, event)
             % Restaura os filtros da aba Arquivos ao estado inicial da tela.
            app.filesStateDropDown.Value = 'Todos os estados';
            app.filesStatusDropDown.Value = 'Todos';
            app.filesLocalityDropDown.Value = 'Todas';

            app.filesDescriptionEditField.Value = '';
            app.filesFrequencyStartEditField.Value = -1;
            app.filesFrequencyEndEditField.Value = -1;
            app.filesStartDatePicker.Value = NaT;
            app.filesEndDatePicker.Value = NaT;

            loadFilesStationOptions(app)
            app.filesStationDropDown.Value = '';
            updateFilesLocationOptions(app, NaN)

            closePopup(app)
            refreshFilteredMap(app, "fit")
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
            app.GridLayout.ColumnWidth = {10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 22, 5, 22, '1x', 18};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_PanelVisibility
            app.tool_PanelVisibility = uiimage(app.Toolbar);
            app.tool_PanelVisibility.ScaleMethod = 'none';
            app.tool_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_PanelVisibility.Layout.Row = [1 3];
            app.tool_PanelVisibility.Layout.Column = 1;
            app.tool_PanelVisibility.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Separator1
            app.tool_Separator1 = uiimage(app.Toolbar);
            app.tool_Separator1.ScaleMethod = 'none';
            app.tool_Separator1.Enable = 'off';
            app.tool_Separator1.Layout.Row = [1 3];
            app.tool_Separator1.Layout.Column = 2;
            app.tool_Separator1.VerticalAlignment = 'bottom';
            app.tool_Separator1.ImageSource = 'LineV.svg';

            % Create tool_TableVisibility
            app.tool_TableVisibility = uiimage(app.Toolbar);
            app.tool_TableVisibility.ScaleMethod = 'none';
            app.tool_TableVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_TableVisibility.Layout.Row = [1 3];
            app.tool_TableVisibility.Layout.Column = 3;
            app.tool_TableVisibility.ImageSource = 'View_16.png';

            % Create tool_RFLinkButton
            app.tool_RFLinkButton = uiimage(app.Toolbar);
            app.tool_RFLinkButton.ScaleMethod = 'none';
            app.tool_RFLinkButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_RFLinkButton.Layout.Row = [1 3];
            app.tool_RFLinkButton.Layout.Column = 4;
            app.tool_RFLinkButton.ImageSource = 'Publish_HTML_16.png';

            % Create tool_PDFButton
            app.tool_PDFButton = uiimage(app.Toolbar);
            app.tool_PDFButton.ScaleMethod = 'none';
            app.tool_PDFButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_PDFButton.Layout.Row = [1 3];
            app.tool_PDFButton.Layout.Column = 5;
            app.tool_PDFButton.ImageSource = 'Publish_PDF_16.png';

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.Toolbar);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 3];
            app.tool_Separator2.Layout.Column = 6;
            app.tool_Separator2.VerticalAlignment = 'bottom';
            app.tool_Separator2.ImageSource = 'LineV.svg';

            % Create tool_ExportButton
            app.tool_ExportButton = uiimage(app.Toolbar);
            app.tool_ExportButton.ScaleMethod = 'none';
            app.tool_ExportButton.ImageClickedFcn = createCallbackFcn(app, @Toolbar_exportButtonPushed, true);
            app.tool_ExportButton.Layout.Row = [1 3];
            app.tool_ExportButton.Layout.Column = 7;
            app.tool_ExportButton.ImageSource = 'Export_16.png';

            % Create tool_tableNRowsIcon
            app.tool_tableNRowsIcon = uiimage(app.Toolbar);
            app.tool_tableNRowsIcon.ScaleMethod = 'none';
            app.tool_tableNRowsIcon.Enable = 'off';
            app.tool_tableNRowsIcon.Layout.Row = [1 3];
            app.tool_tableNRowsIcon.Layout.Column = 9;
            app.tool_tableNRowsIcon.ImageSource = 'Filter_18.png';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {5, 50, 100, '1x', 280};
            app.Document.RowHeight = {24, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 5];
            app.Document.BackgroundColor = [1 1 1];

            % Create plotPanel
            app.plotPanel = uipanel(app.Document);
            app.plotPanel.AutoResizeChildren = 'off';
            app.plotPanel.ForegroundColor = [1 1 1];
            app.plotPanel.BorderType = 'none';
            app.plotPanel.BackgroundColor = [1 1 1];
            app.plotPanel.Layout.Row = [1 2];
            app.plotPanel.Layout.Column = [1 5];
            app.plotPanel.FontSize = 11;

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {22, 22, '1x'};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = [2 3];
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarZoomControlButtonClicked, true);
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 2;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarZoomControlButtonClicked, true);
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 1;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create configMapStyleDropDown
            app.configMapStyleDropDown = uidropdown(app.AxesToolbar);
            app.configMapStyleDropDown.Items = {'streets-light', 'streets-dark', 'streets', 'satellite', 'topographic', 'landcover', 'colorterrain', 'grayterrain', 'bluegreen', 'grayland', 'darkwater', 'none'};
            app.configMapStyleDropDown.ValueChangedFcn = createCallbackFcn(app, @onMapStyleChanged, true);
            app.configMapStyleDropDown.FontSize = 11;
            app.configMapStyleDropDown.BackgroundColor = [1 1 1];
            app.configMapStyleDropDown.Layout.Row = 1;
            app.configMapStyleDropDown.Layout.Column = 3;
            app.configMapStyleDropDown.Value = 'streets-light';

            % Create popupHTML
            app.popupHTML = uilabel(app.Document);
            app.popupHTML.VerticalAlignment = 'top';
            app.popupHTML.WordWrap = 'on';
            app.popupHTML.FontSize = 11;
            app.popupHTML.Visible = 'off';
            app.popupHTML.Layout.Row = [1 2];
            app.popupHTML.Layout.Column = 5;
            app.popupHTML.Interpreter = 'html';
            app.popupHTML.Text = '';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @onSubTabChanged, true);
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = 2;

            % Create FilesTab
            app.FilesTab = uitab(app.SubTabGroup);
            app.FilesTab.Title = 'ARQUIVOS';

            % Create FilesMainGrid
            app.FilesMainGrid = uigridlayout(app.FilesTab);
            app.FilesMainGrid.ColumnWidth = {'1x'};
            app.FilesMainGrid.RowHeight = {48, 22, 22, 88, 22, 61, 22, 61, 22, 61, 22, 22, 22, '1x'};
            app.FilesMainGrid.RowSpacing = 5;
            app.FilesMainGrid.Padding = [10 10 10 5];
            app.FilesMainGrid.BackgroundColor = [1 1 1];

            % Create filesTitleGrid
            app.filesTitleGrid = uigridlayout(app.FilesMainGrid);
            app.filesTitleGrid.ColumnWidth = {22, '1x', 18, 18, 0, 0};
            app.filesTitleGrid.RowHeight = {18, 18, '1x'};
            app.filesTitleGrid.ColumnSpacing = 5;
            app.filesTitleGrid.RowSpacing = 5;
            app.filesTitleGrid.Padding = [10 10 10 5];
            app.filesTitleGrid.Layout.Row = 1;
            app.filesTitleGrid.Layout.Column = 1;
            app.filesTitleGrid.BackgroundColor = [1 1 1];

            % Create referenceRX_Icon_3
            app.referenceRX_Icon_3 = uiimage(app.filesTitleGrid);
            app.referenceRX_Icon_3.Layout.Row = [1 2];
            app.referenceRX_Icon_3.Layout.Column = 1;
            app.referenceRX_Icon_3.ImageSource = 'addFiles_32.png';

            % Create referenceRX_Label_3
            app.referenceRX_Label_3 = uilabel(app.filesTitleGrid);
            app.referenceRX_Label_3.VerticalAlignment = 'bottom';
            app.referenceRX_Label_3.FontSize = 11;
            app.referenceRX_Label_3.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_Label_3.Layout.Row = [1 2];
            app.referenceRX_Label_3.Layout.Column = 2;
            app.referenceRX_Label_3.Interpreter = 'html';
            app.referenceRX_Label_3.Text = {'<b>Pesquisa de Arquivos</b>'; '<font style="font-size: 9px; color: gray;">(Dentro do repoSFI)</font>'};

            % Create filesPeriodLabel
            app.filesPeriodLabel = uilabel(app.FilesMainGrid);
            app.filesPeriodLabel.FontSize = 10;
            app.filesPeriodLabel.Layout.Row = 7;
            app.filesPeriodLabel.Layout.Column = 1;
            app.filesPeriodLabel.Text = 'PERÍODO ';

            % Create filesFrequencyLabel
            app.filesFrequencyLabel = uilabel(app.FilesMainGrid);
            app.filesFrequencyLabel.FontSize = 10;
            app.filesFrequencyLabel.Layout.Row = 9;
            app.filesFrequencyLabel.Layout.Column = 1;
            app.filesFrequencyLabel.Text = 'FREQUÊNCIA (MHz)';

            % Create filesDescriptionLabel
            app.filesDescriptionLabel = uilabel(app.FilesMainGrid);
            app.filesDescriptionLabel.FontSize = 10;
            app.filesDescriptionLabel.Layout.Row = 11;
            app.filesDescriptionLabel.Layout.Column = 1;
            app.filesDescriptionLabel.Text = 'PLANO/DESCRIÇÃO';

            % Create filesDescriptionEditField
            app.filesDescriptionEditField = uieditfield(app.FilesMainGrid, 'text');
            app.filesDescriptionEditField.FontSize = 11;
            app.filesDescriptionEditField.Placeholder = 'Digite uma descrição. Exemplo ''%PMEC%''';
            app.filesDescriptionEditField.Layout.Row = 12;
            app.filesDescriptionEditField.Layout.Column = 1;

            % Create filesStationFilterPanel
            app.filesStationFilterPanel = uipanel(app.FilesMainGrid);
            app.filesStationFilterPanel.BackgroundColor = [1 1 1];
            app.filesStationFilterPanel.Layout.Row = 4;
            app.filesStationFilterPanel.Layout.Column = 1;
            app.filesStationFilterPanel.FontSize = 11;

            % Create filesStationsGrid
            app.filesStationsGrid = uigridlayout(app.filesStationFilterPanel);
            app.filesStationsGrid.ColumnWidth = {110, '1x'};
            app.filesStationsGrid.RowHeight = {22, 22, 22};
            app.filesStationsGrid.RowSpacing = 5;
            app.filesStationsGrid.Padding = [10 10 10 5];
            app.filesStationsGrid.BackgroundColor = [1 1 1];

            % Create filesStateLabel
            app.filesStateLabel = uilabel(app.filesStationsGrid);
            app.filesStateLabel.FontSize = 11;
            app.filesStateLabel.Layout.Row = 1;
            app.filesStateLabel.Layout.Column = 1;
            app.filesStateLabel.Text = 'Estado';

            % Create filesStatusLabel
            app.filesStatusLabel = uilabel(app.filesStationsGrid);
            app.filesStatusLabel.FontSize = 11;
            app.filesStatusLabel.Layout.Row = 2;
            app.filesStatusLabel.Layout.Column = 1;
            app.filesStatusLabel.Text = 'Status';

            % Create filesLocalityLabel
            app.filesLocalityLabel = uilabel(app.filesStationsGrid);
            app.filesLocalityLabel.FontSize = 11;
            app.filesLocalityLabel.Layout.Row = 3;
            app.filesLocalityLabel.Layout.Column = 1;
            app.filesLocalityLabel.Text = 'Registro de Posição';

            % Create filesStateDropDown
            app.filesStateDropDown = uidropdown(app.filesStationsGrid);
            app.filesStateDropDown.Items = {'Todos os estados'};
            app.filesStateDropDown.ValueChangedFcn = createCallbackFcn(app, @onStationFilterChanged, true);
            app.filesStateDropDown.FontSize = 10.5;
            app.filesStateDropDown.BackgroundColor = [1 1 1];
            app.filesStateDropDown.Layout.Row = 1;
            app.filesStateDropDown.Layout.Column = 2;
            app.filesStateDropDown.Value = 'Todos os estados';

            % Create filesStatusDropDown
            app.filesStatusDropDown = uidropdown(app.filesStationsGrid);
            app.filesStatusDropDown.Items = {'Todos', 'Apenas online', 'Apenas offline'};
            app.filesStatusDropDown.ValueChangedFcn = createCallbackFcn(app, @onStationFilterChanged, true);
            app.filesStatusDropDown.FontSize = 10.5;
            app.filesStatusDropDown.BackgroundColor = [1 1 1];
            app.filesStatusDropDown.Layout.Row = 2;
            app.filesStatusDropDown.Layout.Column = 2;
            app.filesStatusDropDown.Value = 'Todos';

            % Create filesLocalityDropDown
            app.filesLocalityDropDown = uidropdown(app.filesStationsGrid);
            app.filesLocalityDropDown.Items = {'Todas', 'Apenas atuais', 'Apenas históricas'};
            app.filesLocalityDropDown.ValueChangedFcn = createCallbackFcn(app, @onStationFilterChanged, true);
            app.filesLocalityDropDown.FontSize = 10.5;
            app.filesLocalityDropDown.BackgroundColor = [1 1 1];
            app.filesLocalityDropDown.Layout.Row = 3;
            app.filesLocalityDropDown.Layout.Column = 2;
            app.filesLocalityDropDown.Value = 'Todas';

            % Create filesCountLabel
            app.filesCountLabel = uilabel(app.FilesMainGrid);
            app.filesCountLabel.FontSize = 11;
            app.filesCountLabel.Layout.Row = 2;
            app.filesCountLabel.Layout.Column = 1;
            app.filesCountLabel.Text = '0 localidade(s) visíveis';

            % Create filesLocationSelectLabel
            app.filesLocationSelectLabel = uilabel(app.FilesMainGrid);
            app.filesLocationSelectLabel.FontSize = 10;
            app.filesLocationSelectLabel.Layout.Row = 3;
            app.filesLocationSelectLabel.Layout.Column = 1;
            app.filesLocationSelectLabel.Text = 'LOCALIDADE/HISTÓRICO';

            % Create filesPeriodPanel
            app.filesPeriodPanel = uipanel(app.FilesMainGrid);
            app.filesPeriodPanel.BackgroundColor = [1 1 1];
            app.filesPeriodPanel.Layout.Row = 8;
            app.filesPeriodPanel.Layout.Column = 1;

            % Create filesPeriodGrid
            app.filesPeriodGrid = uigridlayout(app.filesPeriodPanel);
            app.filesPeriodGrid.ColumnWidth = {110, '1x'};
            app.filesPeriodGrid.RowHeight = {22, 22};
            app.filesPeriodGrid.RowSpacing = 5;
            app.filesPeriodGrid.Padding = [10 10 10 5];
            app.filesPeriodGrid.BackgroundColor = [1 1 1];

            % Create filesStartDateLabel
            app.filesStartDateLabel = uilabel(app.filesPeriodGrid);
            app.filesStartDateLabel.FontSize = 11;
            app.filesStartDateLabel.Layout.Row = 1;
            app.filesStartDateLabel.Layout.Column = 1;
            app.filesStartDateLabel.Text = 'Início';

            % Create filesEndDateLabel
            app.filesEndDateLabel = uilabel(app.filesPeriodGrid);
            app.filesEndDateLabel.FontSize = 11;
            app.filesEndDateLabel.Layout.Row = 2;
            app.filesEndDateLabel.Layout.Column = 1;
            app.filesEndDateLabel.Text = 'Fim';

            % Create filesStartDatePicker
            app.filesStartDatePicker = uidatepicker(app.filesPeriodGrid);
            app.filesStartDatePicker.ValueChangedFcn = createCallbackFcn(app, @onDateChanged, true);
            app.filesStartDatePicker.FontSize = 10.5;
            app.filesStartDatePicker.Placeholder = 'dd-MMM-uuuu';
            app.filesStartDatePicker.Layout.Row = 1;
            app.filesStartDatePicker.Layout.Column = 2;

            % Create filesEndDatePicker
            app.filesEndDatePicker = uidatepicker(app.filesPeriodGrid);
            app.filesEndDatePicker.ValueChangedFcn = createCallbackFcn(app, @onDateChanged, true);
            app.filesEndDatePicker.FontSize = 10.5;
            app.filesEndDatePicker.Placeholder = 'dd-MMM-uuuu';
            app.filesEndDatePicker.Layout.Row = 2;
            app.filesEndDatePicker.Layout.Column = 2;

            % Create filesFrequencyPanel
            app.filesFrequencyPanel = uipanel(app.FilesMainGrid);
            app.filesFrequencyPanel.BackgroundColor = [1 1 1];
            app.filesFrequencyPanel.Layout.Row = 10;
            app.filesFrequencyPanel.Layout.Column = 1;

            % Create filesFrequencyGrid
            app.filesFrequencyGrid = uigridlayout(app.filesFrequencyPanel);
            app.filesFrequencyGrid.ColumnWidth = {110, '1x'};
            app.filesFrequencyGrid.RowHeight = {22, 22};
            app.filesFrequencyGrid.RowSpacing = 5;
            app.filesFrequencyGrid.Padding = [10 10 10 5];
            app.filesFrequencyGrid.BackgroundColor = [1 1 1];

            % Create filesFrequencyEndLabel
            app.filesFrequencyEndLabel = uilabel(app.filesFrequencyGrid);
            app.filesFrequencyEndLabel.FontSize = 11;
            app.filesFrequencyEndLabel.Layout.Row = 2;
            app.filesFrequencyEndLabel.Layout.Column = 1;
            app.filesFrequencyEndLabel.Text = 'Fim';

            % Create filesFrequencyStartEditField
            app.filesFrequencyStartEditField = uieditfield(app.filesFrequencyGrid, 'numeric');
            app.filesFrequencyStartEditField.AllowEmpty = 'on';
            app.filesFrequencyStartEditField.FontSize = 11;
            app.filesFrequencyStartEditField.Layout.Row = 1;
            app.filesFrequencyStartEditField.Layout.Column = 2;
            app.filesFrequencyStartEditField.Value = [];

            % Create filesFrequencyEndEditField
            app.filesFrequencyEndEditField = uieditfield(app.filesFrequencyGrid, 'numeric');
            app.filesFrequencyEndEditField.AllowEmpty = 'on';
            app.filesFrequencyEndEditField.FontSize = 11;
            app.filesFrequencyEndEditField.Layout.Row = 2;
            app.filesFrequencyEndEditField.Layout.Column = 2;
            app.filesFrequencyEndEditField.Value = [];

            % Create filesFrequencyStartLabel
            app.filesFrequencyStartLabel = uilabel(app.filesFrequencyGrid);
            app.filesFrequencyStartLabel.FontSize = 11;
            app.filesFrequencyStartLabel.Layout.Row = 1;
            app.filesFrequencyStartLabel.Layout.Column = 1;
            app.filesFrequencyStartLabel.Text = 'Início';

            % Create filesSensorLocationLabel
            app.filesSensorLocationLabel = uipanel(app.FilesMainGrid);
            app.filesSensorLocationLabel.BackgroundColor = [1 1 1];
            app.filesSensorLocationLabel.Layout.Row = 6;
            app.filesSensorLocationLabel.Layout.Column = 1;
            app.filesSensorLocationLabel.FontSize = 11;

            % Create filesSensorLocationGrid
            app.filesSensorLocationGrid = uigridlayout(app.filesSensorLocationLabel);
            app.filesSensorLocationGrid.ColumnWidth = {110, '1x'};
            app.filesSensorLocationGrid.RowHeight = {22, 22};
            app.filesSensorLocationGrid.RowSpacing = 5;
            app.filesSensorLocationGrid.Padding = [10 10 10 5];
            app.filesSensorLocationGrid.BackgroundColor = [1 1 1];

            % Create filesSensorLabel
            app.filesSensorLabel = uilabel(app.filesSensorLocationGrid);
            app.filesSensorLabel.FontSize = 11;
            app.filesSensorLabel.Layout.Row = 1;
            app.filesSensorLabel.Layout.Column = 1;
            app.filesSensorLabel.Text = 'Sensor';

            % Create filesLocationLabel
            app.filesLocationLabel = uilabel(app.filesSensorLocationGrid);
            app.filesLocationLabel.FontSize = 11;
            app.filesLocationLabel.Layout.Row = 2;
            app.filesLocationLabel.Layout.Column = 1;
            app.filesLocationLabel.Text = 'Localidade';

            % Create filesLocationDropDown
            app.filesLocationDropDown = uidropdown(app.filesSensorLocationGrid);
            app.filesLocationDropDown.Items = {'Todas as localidades'};
            app.filesLocationDropDown.ValueChangedFcn = createCallbackFcn(app, @onLocationChanged, true);
            app.filesLocationDropDown.FontSize = 10.5;
            app.filesLocationDropDown.BackgroundColor = [1 1 1];
            app.filesLocationDropDown.Layout.Row = 2;
            app.filesLocationDropDown.Layout.Column = 2;
            app.filesLocationDropDown.Value = 'Todas as localidades';

            % Create filesStationDropDown
            app.filesStationDropDown = uidropdown(app.filesSensorLocationGrid);
            app.filesStationDropDown.Items = {''};
            app.filesStationDropDown.Editable = 'on';
            app.filesStationDropDown.ValueChangedFcn = createCallbackFcn(app, @onStationChanged, true);
            app.filesStationDropDown.FontSize = 10.5;
            app.filesStationDropDown.BackgroundColor = [1 1 1];
            app.filesStationDropDown.Layout.Row = 1;
            app.filesStationDropDown.Layout.Column = 2;
            app.filesStationDropDown.Value = '';

            % Create filesStationLabel
            app.filesStationLabel = uilabel(app.FilesMainGrid);
            app.filesStationLabel.FontSize = 11;
            app.filesStationLabel.Layout.Row = 5;
            app.filesStationLabel.Layout.Column = 1;
            app.filesStationLabel.Text = 'ESTAÇÃO';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.FilesMainGrid);
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.RowSpacing = 0;
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 13;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create filesSearchButton
            app.filesSearchButton = uibutton(app.GridLayout2, 'push');
            app.filesSearchButton.ButtonPushedFcn = createCallbackFcn(app, @onSearchClick, true);
            app.filesSearchButton.FontSize = 11;
            app.filesSearchButton.Layout.Row = 1;
            app.filesSearchButton.Layout.Column = 1;
            app.filesSearchButton.Text = 'Pesquisar';

            % Create filesCleanButton
            app.filesCleanButton = uibutton(app.GridLayout2, 'push');
            app.filesCleanButton.ButtonPushedFcn = createCallbackFcn(app, @onCleanClick, true);
            app.filesCleanButton.FontSize = 11;
            app.filesCleanButton.Layout.Row = 1;
            app.filesCleanButton.Layout.Column = 2;
            app.filesCleanButton.Text = 'Limpar';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [5 6];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winRepoSFI';

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
        function app = winRepoSFI_exported(Container, varargin)

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
