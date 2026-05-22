classdef winRepoSFI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        DockModule                matlab.ui.container.GridLayout
        dockModule_Close          matlab.ui.control.Image
        dockModule_Undock         matlab.ui.control.Image
        AxesToolbar               matlab.ui.container.GridLayout
        axesTool_Basemap          matlab.ui.control.DropDown
        axesTool_RestoreView      matlab.ui.control.Image
        axesTool_RegionZoom       matlab.ui.control.Image
        AxesPopup                 matlab.ui.control.Label
        AxesContainer             matlab.ui.container.Panel
        LeftPanel                 matlab.ui.container.Panel
        LeftPanelGrid             matlab.ui.container.GridLayout
        Label                     matlab.ui.control.Label
        Image                     matlab.ui.control.Image
        ReceiverPanel             matlab.ui.container.Panel
        ReceiverGrid              matlab.ui.container.GridLayout
        ReceiverPosition          matlab.ui.control.DropDown
        ReceiverPositionLabel     matlab.ui.control.Label
        ReceiverStatus            matlab.ui.control.DropDown
        ReceiverStatusLabel       matlab.ui.control.Label
        Receiver                  matlab.ui.control.DropDown
        ReceiverLabel             matlab.ui.control.Label
        EndDatePicker             matlab.ui.control.DatePicker
        EndDateLabel              matlab.ui.control.Label
        StartDate                 matlab.ui.control.DatePicker
        StartDateLabel            matlab.ui.control.Label
        Location                  matlab.ui.control.DropDown
        LocationLabel             matlab.ui.control.Label
        State                     matlab.ui.control.DropDown
        StateLabel                matlab.ui.control.Label
        ModuleIntro               matlab.ui.control.Label
        ModuleIcon                matlab.ui.control.Image
        Toolbar                   matlab.ui.container.GridLayout
        tool_FileCount            matlab.ui.control.Label
        tool_RefreshFilterValues  matlab.ui.control.Image
        tool_OpenPopupApp         matlab.ui.control.Image
        tool_Separator            matlab.ui.control.Image
        tool_LayoutLeft           matlab.ui.control.Image
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'REPOSFI'
        AppHandleNameInBase
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

        UIAxes
        defaultValues
        
        dbHandlerObj
        repoSFI % dbHandlerObj.CacheData
        
        filteredRepoSFI = struct('points', struct([]), 'siteDetails', struct([]))        
        filesLocalityRows = table()
        currentSiteContext
        popupReferenceData
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'onFileSearchRequested'
                        idxs = jsondecode(event.HTMLEventData);
                        selectedStationDetails = app.AxesPopup.UserData.siteDetails(idxs(1)).point.stations(idxs(2))

                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
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

                            case 'onRepoSFIFilterChanged'
                                syncFiltersFromDock(app, varargin{2})

                            case 'onOpenDockModuleFromPopup'
                                payload = varargin{2};
        
                                siteId = str2double(string(payload.siteId));
                                equipmentId = str2double(string(payload.equipmentId));
                                hostId = str2double(string(payload.hostId));
        
                                hidePointPopup(app);
                                openRepoFilesDockForStation(app, siteId, equipmentId, hostId)

                            case 'onClosePopupRequest'
                                hidePointPopup(app)

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
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;

            appName = class(app);
            elToModify = {
                app.AxesToolbar;
                app.tool_LayoutLeft;
                app.tool_OpenPopupApp;
                app.tool_RefreshFilterValues;
                app.dockModule_Undock;
                app.dockModule_Close;
                app.AxesPopup
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                    struct('appName', appName, 'dataTag', app.AxesPopup.UserData.id, 'style', struct('pointerEvents', 'none')), ...
                    struct('appName', appName, 'dataTag', app.AxesPopup.UserData.id, 'selector', '.mwAlignmentNode', 'style', struct('height', '100%')), ...
                    struct('appName', appName, 'dataTag', app.tool_LayoutLeft.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Alterna visibilidade do painel')), ... 
                    struct('appName', appName, 'dataTag', app.tool_OpenPopupApp.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Apresenta lista de arquivos')), ... 
                    struct('appName', appName, 'dataTag', app.tool_RefreshFilterValues.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Volta às configuraçoes inicias de filtragem')), ... 
                    struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                    struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                    });
            catch
            end

            try
                ui.TextView.startup(app.jsBackDoor, app.AxesPopup, appName, struct('class', {{'textview--borderless', 'textview--wordbreak', 'textview--no-scroll'}}));
            catch ME
                disp(ME.identifier);
            end

            app.AxesPopup.UserData.siteDetails = [];
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            warningMsg = '';
            if isempty(app.mainApp.dbHandlerObj) || ~isvalid(app.mainApp.dbHandlerObj) || ~app.mainApp.dbHandlerObj.Status
                [app.mainApp.dbHandlerObj, warningMsg] = util.DBHandler(app.mainApp.General);
            end

            if ~isempty(warningMsg)
                ui.Dialog(app.UIFigure, 'warning', warningMsg);
            end

            app.dbHandlerObj = app.mainApp.dbHandlerObj;
            app.repoSFI = app.dbHandlerObj.CacheData;

            cacheUpdatedAt = strsplit(app.dbHandlerObj.CacheUpdatedAt, ' ');
            app.Label.Text = sprintf('%s às %s', cacheUpdatedAt{2}, cacheUpdatedAt{1});

            app.defaultValues = getFilterCurrentSpecification(app);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            defaultBasemap = app.mainApp.General.plot.geographicAxes.Basemap;
            if ismember(defaultBasemap, app.axesTool_Basemap.Items)
                app.axesTool_Basemap.Value = defaultBasemap;
            end

            initializeAxes(app)
            app.State.Items = [{''}, unique([app.repoSFI.points.state_code])];
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            initializeFilesSearchPanel(app)
            refreshFilteredMap(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 1, 1, "Padding", "none", "TileSpacing", "none", "Position", [0, 0, 1, 1]);

            app.UIAxes = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.axesTool_Basemap.Value, ...
                                                                    'Color', [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                    'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
        
            set(app.UIAxes.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            
            geolimits(app.UIAxes, 'auto')
            plot.axes.Colormap(app.UIAxes, 'turbo')

            if ismember(app.axesTool_Basemap.Value, {'darkwater', 'none'})
                app.UIAxes.Grid = 'on';
            end
        
            plot.axes.Interactivity.DefaultCreation(app.UIAxes, [zoomInteraction, panInteraction, dataTipInteraction])
        end

        %-----------------------------------------------------------------%
        function spec = getFilterCurrentSpecification(app)
            spec = struct( ...
                'state', app.State.Value, ...
                'location', app.Location.Value, ...
                'periodBegin', app.StartDate.Value, ...
                'periodEnd', app.EndDatePicker.Value, ...
                'receiver', app.Receiver.Value, ...
                'receiverStatus', app.ReceiverStatus.Value, ...
                'receiverPosition', app.ReceiverPosition.Value ...
            );
        end

        %-------------------------------------------------------------%
        function refreshFilteredMap(app)
            set(findobj(app.UIAxes.Children, 'Tag', 'receiverStation'), 'ButtonDownFcn', [])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes, matlab.graphics.interaction.interface.BaseInteraction.empty)

            updateFilteredRepoSFI(app)
            plot_Stations(app)
            drawnow

            set(findobj(app.UIAxes.Children, 'Tag', 'receiverStation'), 'ButtonDownFcn', @app.onPlottedSiteClick)
            plot.axes.Interactivity.DefaultCreation(app.UIAxes, [zoomInteraction, panInteraction, dataTipInteraction])
        end

        %-----------------------------------------------------------------%
        function clearPopupSelectionHighlight(app)
            % Limpa o highlight visual deixado pela seleção atual do popup.
            % Garante um contrato estável para o UserData do eixo, evitando
            % remover campos e reduzindo dependência de verificações ad hoc.
            axesState = getPopupHighlightState(app);

            % Remove apenas os handles gráficos ainda válidos antes de zerar o
            % estado persistido no eixo.
            highlightHandle = axesState.popupHighlightHandle;
            if ~isempty(highlightHandle)
                highlightHandle = highlightHandle(isgraphics(highlightHandle));
                if ~isempty(highlightHandle)
                    delete(highlightHandle)
                end
            end

            axesState.popupHighlightHandle = gobjects(0);
            axesState.popupHighlightSiteIds = zeros(1, 0);
            app.UIAxes.UserData = axesState;
        end

        %-----------------------------------------------------------------%
        function updatePopupSelectionHighlight(app, siteDetails)
            clearPopupSelectionHighlight(app);

            axesState = getPopupHighlightState(app);

            points = [siteDetails.point];
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

            % Persiste os handles e os IDs destacados no estado do eixo sem
            % alterar a estrutura base de UserData.
            axesState.popupHighlightHandle = highlightHandle;
            axesState.popupHighlightSiteIds = [siteDetails.siteId];
            app.UIAxes.UserData = axesState;

            function plotHighlightGroup(idx, markerColor, isHistorical)
                if ~any(idx)
                    return
                end

                latGroup = lat(idx);
                lonGroup = lon(idx);

                highlightHandle(end+1) = geoscatter(app.UIAxes, latGroup, lonGroup, 165, markerColor, 'filled', 'Marker', 'o', 'MarkerEdgeColor', [0, 0, 0], 'LineWidth', 2, 'PickableParts', 'none', 'Tag', 'selectedReceiverStation');
            end
        end

        %-----------------------------------------------------------------%
        function plot_Stations(app)
            % Limpa completamente o eixo para evitar sobreposição entre plots
            % antigos e o novo estado filtrado.
            set(findobj(app.UIAxes.Children, 'Tag', 'receiverStation'), 'ButtonDownFcn', [])
            cla(app.UIAxes);
            app.AxesPopup.Visible = "off";
            clearPopupSelectionHighlight(app)

            filteredData = app.filteredRepoSFI;
            if ~isstruct(filteredData) || ~isfield(filteredData, 'points') || ~isfield(filteredData, 'siteDetails')
                app.tool_FileCount.Text = '';
                return
            end

            % Atualiza a indicação textual de quantas localidades permanecem visíveis.
            numPoints = numel(filteredData.points);
            switch numPoints
                case 0
                    numPointsLabel = '';
                case 1
                    numPointsLabel = 'Uma única localidade visível';
                otherwise
                    numPointsLabel = sprintf('%d localidades visíveis', numPoints);
            end
            app.tool_FileCount.Text = numPointsLabel;

            % Se nenhum ponto sobreviveu ao filtro, não há mais nada para desenhar.
            if isempty(filteredData.points)
                return
            end

            lat = [filteredData.points.latitude];
            lon = [filteredData.points.longitude];
            markerStates = string({filteredData.points.marker_state});

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
            plotGroup("offline_previous", colorOfflinePrevious, true,  100);
            plotGroup("online_previous",  colorOnlinePrevious,  true,   80);
            plotGroup("offline_current",  colorOfflineCurrent,  false, 100);
            plotGroup("online_current",   colorOnlineCurrent,   false,  80);
            plotGroup("no_host",          colorNoHost,          false, 100);
            geolimits(app.UIAxes, 'auto')

            function plotGroup(tag, color, isHistorical, markerSize)
                maskMatch = markerStates == tag;
                if ~any(maskMatch)
                    return
                end

                latGroup = lat(maskMatch);
                lngGroup = lon(maskMatch);
                
                siteIdGroup = double([filteredData.points(maskMatch).site_id]);

                h = geoscatter(app.UIAxes, latGroup, lngGroup, markerSize, color, 'filled', 'Marker', 'o', 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1, 'Tag', 'receiverStation');
                h.UserData = struct('site_ids', siteIdGroup, 'latitudes', latGroup, 'longitudes', lngGroup);

                try
                    datatipSource = struct2table(rmfield(filteredData.points(maskMatch), setdiff(fieldnames(filteredData.points), {'site_label', 'county_name', 'state_code'})));
                    plot.datatip.Template(h, 'Coordinates+Location', datatipSource)
                catch
                    plot.datatip.Template(h, 'Coordinates')
                end


                if isHistorical
                    geoscatter(app.UIAxes, latGroup, lngGroup, 14, overlayColor, 'Marker', '.', 'LineWidth', 0.8, 'PickableParts', 'none');
                end
            end
        end

        %-----------------------------------------------------------------%
        function output = getPopupHighlightState(app)
            % Normaliza o estado de highlight persistido no UserData do geoaxes.
            %
            % Esse helper centraliza o contrato usado por clearPopupSelectionHighlight
            % e updatePopupSelectionHighlight, para que o restante do fluxo nunca
            % precise lidar com ausência dos campos de highlight.

            output = struct();

            % Reaproveita o UserData atual do eixo quando ele já estiver no formato
            % de struct esperado pelas rotinas de highlight.
            if isstruct(app.UIAxes.UserData)
                output = app.UIAxes.UserData;
            end

            % Garante os campos usados no fluxo de popup mesmo antes da primeira
            % seleção ou após um reset visual completo do mapa.
            if ~isfield(output, 'popupHighlightHandle')
                output.popupHighlightHandle = gobjects(0);
            end

            if ~isfield(output, 'popupHighlightSiteIds')
                output.popupHighlightSiteIds = zeros(1, 0);
            end
        end


        function onPlottedSiteClick(app, src, event)
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
            showPointPopup(app, filteredMapData, selectionInfo);

            % Persiste o contexto do último clique para fluxos posteriores, como
            % abertura sob demanda do dock de arquivos.
            app.currentSiteContext = struct('siteId', siteId, 'mapDataSet', filteredMapData);
        end

        %-----------------------------------------------------------
        % Helpers de Seleção do Mapa
        %-----------------------------------------------------------------%
        function selectionRadius = getAdaptiveSelectionRadius(~,zoomSpan)
            % Ajusta o raio de agrupamento conforme a zoom atual do mapa.
            %
            % Esse valor é usado em resolveSiteSelection para decidir quando um
            % clique deve abrir apenas o site resolvido ou incorporar localidades
            % vizinhas no mesmo popup.

            % Em zoom mais aberto, aumenta a tolerância para capturar pontos
            % próximos; em zoom fechado, reduz o raio para preservar precisão.
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
            % Tenta materializar a coordenada geográfica associada ao clique.
            %
            % Esse helper atende o fluxo de seleção no mapa, principalmente em
            % onPlottedSiteClick e resolveSiteSelection, onde a posição exata do
            % clique ajuda a desempatar qual site ou agrupamento deve alimentar o popup.

            clickLat = NaN;
            clickLon = NaN;

            try
                % Caminho preferencial: usa a coordenada informada pelo próprio
                % evento de clique quando ela vier disponível no geoaxes.
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
                % Fallback: quando o evento não expõe a interseção, reaproveita a
                % primeira coordenada do objeto gráfico clicado.
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
        % POPUP
        %-----------------------------------------------------------------%
        function hidePointPopup(app)
            set(app.AxesPopup, 'Visible', 'off', 'Text', '')
            app.AxesPopup.UserData.siteDetails = [];

            app.currentSiteContext = [];
            clearPopupSelectionHighlight(app);
        end

        %-----------------------------------------------------------------%
        function showPointPopup(app, mapDataSet, selectionInfo)
            if ~isstruct(mapDataSet) || ~isfield(mapDataSet, 'points') || ~isfield(mapDataSet, 'siteDetails')
                hidePointPopup(app)
                return
            end

            siteDetails = collectPopupSites(app, mapDataSet, selectionInfo.siteIds);
            if isempty(siteDetails)
                hidePointPopup(app)
                return
            end

            updatePopupSelectionHighlight(app, siteDetails);

            % Verifica se o handle para o app continua ativo no workspace
            % base do MATLAB, possibilitando que clicks no ui.TextView sejam 
            % capturados corretamente.
            appHandleNameInBase = app.AppHandleNameInBase;
            if isempty(appHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', appHandleNameInBase, appHandleNameInBase, class(app), appHandleNameInBase))
                app.AppHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
            end

            [~, siteDetailsSortedIdxs] = sort(arrayfun(@(x) x.point.site_label, siteDetails));
            siteDetails = siteDetails(siteDetailsSortedIdxs);

            if isequal(siteDetails, app.AxesPopup.UserData.siteDetails)
                app.AxesPopup.Visible = 'on';
            else
                htmlContent = util.HtmlTextGenerator.receiverStationDetails(siteDetails, app.AppHandleNameInBase, app.mainApp.General);
                set(app.AxesPopup, 'Visible', 'on', 'Text', htmlContent)
                app.AxesPopup.UserData.siteDetails = siteDetails;
                deleteUnrelatedDataTips(app, siteDetails)
            end
        end

        %-----------------------------------------------------------------%
        function deleteUnrelatedDataTips(app, siteDetails)
            datatipsHandles = findobj(app.UIAxes.Children, 'Type', 'datatip');
            datatipsHandles(~isvalid(datatipsHandles)) = [];

            if isempty(datatipsHandles)
                return
            end

            selectedLocations = cellstr(arrayfun(@(x) x.point.site_label, siteDetails));
            datatipsLocations = arrayfun(@(x) x.Content{1}, datatipsHandles, 'UniformOutput', false);
            
            for ii = numel(datatipsLocations):-1:1
                if ~contains(datatipsLocations{ii}, selectedLocations)
                    delete(datatipsHandles(ii))
                end
            end
        end

        %-----------------------------------------------------------------%
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
                detailIdx = find([mapDataSet.siteDetails.site_id] == siteId, 1);

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
                    'detail', mapDataSet.siteDetails(detailIdx) ...
                    ); %#ok<AGROW>
            end
        end

        
        function name = chooseName(app, st)
            % Resolve o nome exibido da estação nos blocos e métricas do popup.
            % A mesma regra é reutilizada em renderPopupStationHTML,
            % estimatePopupStationHeight e buildPointFromDetail para manter o
            % texto visível consistente em todo o fluxo.
            hostName = normalizeTextFromValue(app, st.host_name);
            equipmentName = normalizeTextFromValue(app, st.equipment_name);

            % Prioriza o host quando ele existir, porque esse é o rótulo mais
            % específico para a estação no contexto do popup.
            if strlength(hostName) > 0
                name = hostName;
            elseif strlength(equipmentName) > 0
                % Quando não houver host, reaproveita o nome do equipamento para
                % não deixar o bloco sem identificação textual.
                name = equipmentName;
            else
                % Fallback final para casos em que o backend não trouxe nenhum dos
                % dois campos de nome.
                name = "Estacao";
            end
        end        

        %-----------------------------------------------------------------%
        % Tab de Pesquisa de Arquivos
        %-----------------------------------------------------------------%
        function initializeFilesSearchPanel(app)
            % Reinicializa a aba Arquivos antes de recarregar estação e localidade.
            %
            % Essa preparação roda no layout inicial e também nos fluxos de reset,
            % para que loadFilesStationOptions e updateFilesLocationOptions partam
            % sempre de um estado transitório limpo e previsível.

            % Limpa o cache de localidades e zera os filtros que dependem da
            % seleção corrente antes de reconstruir as opções da interface.
            app.filesLocalityRows        = table();
            app.StartDate.Value = NaT;
            app.EndDatePicker.Value   = NaT;
            %app.filesDescriptionEditField.Value    = '';

            % Recarrega primeiro as estações e, em seguida, as localidades
            % compatíveis com a seleção inicial vazia.
            loadFilesStationOptions(app)
            updateFilesLocationOptions(app, NaN)
        end


        function loadFilesStationOptions(app)
            % Recarrega as opções de estação/equipamento da aba Arquivos.
            %
            % Essa função recompõe o dropdown principal de busca a partir do
            % catálogo retornado pelo banco e tenta preservar a seleção atual
            % quando o valor ainda continua válido após a recarga.

            % Constrói filtros a partir das seleções ativas de estado e localidade
            % para restringir os equipamentos ao contexto atual do painel.
            eqFilters = struct();

            if ~isempty(app.State.Value)
                eqFilters.stateCode = app.State.Value;
            end

            eqDistrictId = str2double(string(app.Location.Value));
            if ~isnan(eqDistrictId)
                eqFilters.districtId = eqDistrictId;
            end

            rows = app.dbHandlerObj.getSpectrumEquipments(eqFilters);

            % Mantém uma opção neutra no topo para representar ausência de
            % seleção explícita no dropdown.
            items     = {'Selecione uma estação/equipamento'};
            itemsData = {''};

            % Guarda o valor atual para tentar restaurá-lo depois da reconstrução
            % da lista.
            selectedValue = string(app.Receiver.Value);

            if istable(rows) && ~isempty(rows)
                for ii = 1:height(rows)
                        % Normaliza o identificador e o rótulo visível antes de
                        % publicar cada opção no componente.
                    equipmentId   = formatNumericId(app, rows.ID_EQUIPMENT(ii));
                    equipmentName = displayRawText(app, rows.NA_EQUIPMENT(ii), '(sem nome)');
                    items{end + 1}     = char(equipmentName); %#ok<AGROW>
                    itemsData{end + 1} = char(equipmentId);   %#ok<AGROW>
                end
            end

                % Publica a nova lista no dropdown já com Items e ItemsData em sincronia.
            app.Receiver.Items     = items;
            app.Receiver.ItemsData = itemsData;

                % Se a seleção anterior ainda existir, restaura; caso contrário,
                % volta para o estado neutro da busca.
            if any(strcmp(itemsData, char(selectedValue)))
                app.Receiver.Value = char(selectedValue);
            else
                app.Receiver.Value = '';
            end
        end

        
        function updateFilesLocationOptions(app, preferredDistrictId)
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
            equipmentId = str2double(string(app.Receiver.Value));
            items = {'Todas as localidades'};
            itemsData = {''};

            % Mantém em memória as linhas retornadas pela consulta para uso posterior
            % em outras rotinas, como atualização de período.
            app.filesLocalityRows = table();

            % Constrói filtros a partir das seleções ativas de estado e equipamento.
            locFilters = struct();
            
            if ~isempty(app.State.Value)
                locFilters.stateCode = app.State.Value;
            end

            % Sempre consulta o banco: sem filtros ativos retorna todas as
            % localidades disponíveis, permitindo que o usuário desfaça filtros
            % sem colapsar a lista para apenas a opção neutra.
            app.filesLocalityRows = app.dbHandlerObj.getSpectrumLocalities(equipmentId, locFilters);

            % Converte as linhas retornadas em Items/ItemsData do dropdown.
            if istable(app.filesLocalityRows) && ~isempty(app.filesLocalityRows)
                for ii = 1:height(app.filesLocalityRows)
                    districtId = formatNumericId(app, app.filesLocalityRows.ID_DISTRICT(ii));
                    localityLabel = formatFilesLocalityOption(app, app.filesLocalityRows(ii, :));

                    items{end + 1} = char(localityLabel); %#ok<AGROW>
                    itemsData{end + 1} = char(districtId); %#ok<AGROW>
                end
            end

            % Publica as opções calculadas no componente visual.
            % Ordena alfabeticamente mantendo 'Todas as localidades' sempre na 1ª posição.
            if numel(items) > 1
                [sortedLabels, sortIdx] = sort(items(2:end));
                items    = [items(1),     sortedLabels];
                itemsData = [itemsData(1), itemsData(sortIdx + 1)];
            end
            app.Location.Items = items;
            app.Location.ItemsData = itemsData;

            % Tenta selecionar a localidade preferencial, quando ela ainda existir
            % na lista recém-carregada; caso contrário, volta para a opção geral.
            preferredDistrictId = formatNumericId(app, preferredDistrictId);
            if strlength(preferredDistrictId) > 0 && any(strcmp(itemsData, char(preferredDistrictId)))
                app.Location.Value = char(preferredDistrictId);
            else
                app.Location.Value = '';
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
            app.StartDate.Value = NaT;
            app.EndDatePicker.Value = NaT;

            % Sem linhas disponíveis não há período a inferir.
            if ~istable(app.filesLocalityRows) || isempty(app.filesLocalityRows)
                return
            end

            selectedDistrictId = str2double(string(app.Location.Value));
            rows = app.filesLocalityRows;

            % Se uma localidade específica foi escolhida, restringe o cálculo do
            % período apenas às linhas associadas a esse distrito.
            if ~isnan(selectedDistrictId) && ismember('ID_DISTRICT', rows.Properties.VariableNames)
                districtValues = str2double(string(rows.ID_DISTRICT));
                rows = rows(districtValues == selectedDistrictId, :);
            end

            % Extrai a menor data inicial e a maior data final do subconjunto ativo.
            startDate = extractMinDateFromRows(app, rows, 'DATE_START');
            endDate = extractMaxDateFromRows(app, rows, 'DATE_END');

            % Só publica valores válidos nos componentes.
            if ~isnat(startDate)
                app.StartDate.Value = startDate;
            end

            if ~isnat(endDate)
                app.EndDatePicker.Value = endDate;
            end
        end

        
        %-----------------------------------------------------------------%
        function openRepoFilesDock(app, dockContext)
            % Encaminha a abertura do dock de arquivos no padrão do appAnalise.

            % Esse helper centraliza a chamada usada tanto pela pesquisa da aba
            % Arquivos quanto pelos botões do popup, para que winRepoSFI sempre
            % entregue ao dock RepoFiles o mesmo contexto de origem.

            % dockContext carrega os filtros e identificadores já resolvidos no
            % fluxo atual, como site, equipamento, host e demais recortes de busca.
            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RepoFiles', app.Context, dockContext)
        end

        %------------------------------------------------------------------%
        function openRepoFilesDockForStation(app, siteId, equipmentId, hostId)
            % Abre o dock de arquivos usando os identificadores da estacao clicada.
            %
            % O stateCode é resolvido a partir do dataset filtrado atual para que
            % o dock inicialize os filtros de equipamento e localidade corretamente.

            stateCode  = '';
            districtId = NaN;
            points = app.filteredRepoSFI.points;
            if ~isempty(points)
                pointIdx = find([points.site_id] == siteId, 1);
                if ~isempty(pointIdx)
                    stateCode  = char(normalizeTextFromValue(app, points(pointIdx).state_code));
                    districtId = points(pointIdx).district_id;
                end
            end

            dockContext = struct( ...
                'siteId',      siteId, ...
                'equipmentId', equipmentId, ...
                'hostId',      hostId, ...
                'stateCode',   stateCode, ...
                'districtId',  districtId ...
                );

            openRepoFilesDock(app, dockContext)
        end

        
        %-----------------------------------------------------------------%
        % Aplica os filtros no conjunto de dados lidos do banco e restringe
        % o conjunto a ser manipulado pela GUI
        %-----------------------------------------------------------------%
        function updateFilteredRepoSFI(app)
            % Recompõe o dataset filtrado a partir do estado atual da interface.

            % A função centraliza a atualização de app.filteredRepoSFI, que depois
            % é consumido tanto pelo plot do mapa quanto pelos fluxos de clique e
            % popup que dependem do snapshot atualmente visível.
            app.filteredRepoSFI = getAppliedFilter(app);

            % Também atualiza o contador textual para manter a interface coerente
            % com o recorte recém-calculado, mesmo antes do replot terminar.
            if ~isempty(app.tool_FileCount)
                app.tool_FileCount.Text = sprintf('%d localidade(s) visíveis', numel(app.filteredRepoSFI.points));
            end
        end

        
        function filteredData = getAppliedFilter(app)
            % Aplica os filtros ativos da interface e devolve o dataset filtrado.
            %
            % A saída é a fonte única de verdade consumida pelo plot do mapa,
            % popup e seleção de localidades.

            % Começa com a estrutura vazia padrão para garantir um contrato
            % estável mesmo quando o dataset base ainda não estiver disponível.
            filteredData = struct('points', struct([]), 'siteDetails', struct([]));

            basePoints = app.repoSFI.points;
            baseSiteDetails = app.repoSFI.siteDetails;

            % Se não houver pontos carregados, também não há recorte a compor.
            if isempty(basePoints)
                return
            end

            % Prepara coleções vazias tipadas a partir do dataset original para
            % reconstruir apenas os sites que sobreviverem aos filtros ativos.
            filteredPoints = basePoints([]);
            filteredSiteDetails = baseSiteDetails([]);

            % Inicializa os filtros com os estados neutros da interface.
            stateCode = app.State.Value;
            statusFilter   = app.ReceiverStatus.Value;
            localityFilter = app.ReceiverPosition.Value;
            equipmentFilter = str2double(string(app.Receiver.Value));
            districtFilter = str2double(string(app.Location.Value));

            [startDt, endDate] = getNormalizedFilterDateRange(app);
            if isnat(endDate)
                endBefore = NaT;
            else
                % Usa limite exclusivo no fim da janela para simplificar a
                % comparação com períodos de vigência das estações.
                endBefore = endDate + days(1);
            end
            hasDateFilter = ~isnat(startDt) || ~isnat(endBefore);

            for ii = 1:numel(basePoints)
                basePoint = basePoints(ii);

                % Tenta reaproveitar o detalhe na mesma posição do ponto e, se o
                % alinhamento não existir, faz a busca explícita pelo site_id.
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

                % Só entra no filtro detalhado de estações quando algum recorte de
                % data, status, localidade ou equipamento estiver realmente ativo.
                if hasDateFilter || statusFilter ~= "Todos" || localityFilter ~= "Todas" || ~isnan(equipmentFilter)
                    filteredDetail = filterSiteDetailStations(app, detail, statusFilter, localityFilter, equipmentFilter, startDt, endBefore);
                    if isempty(filteredDetail.stations)
                        continue
                    end
                end

                % Reconstroi o ponto público do mapa a partir do detalhe já podado,
                % preservando coerência entre marcador, popup e seleção.
                filteredPoint = buildPointFromDetail(app, basePoint, filteredDetail);

                % O filtro por UF atua no nível do ponto agregado já reconstruído.
                if ~isempty(stateCode)
                    pointStateCode = normalizeTextFromValue(app, filteredPoint.state_code);
                    if strlength(pointStateCode) == 0 || ~strcmp(pointStateCode, stateCode)
                        continue
                    end
                end

                % Filtro por distrito: descarta pontos cujo district_id não
                % coincide com o valor selecionado no filesLocationDropDown.
                if ~isnan(districtFilter)
                    pointDistrictId = filteredPoint.district_id;
                    if isempty(pointDistrictId) || pointDistrictId ~= districtFilter
                        continue
                    end
                end

                % Os filtros finais validam o estado visual agregado e o tipo de
                % localidade restante antes de publicar o site no recorte final.
                if ~statusFilterMatchesMapState(app, filteredPoint.marker_state, statusFilter)
                    continue
                end

                if ~detailMatchesLocality(app, filteredDetail, localityFilter)
                    continue
                end

                filteredPoints(end + 1, 1) = filteredPoint; %#ok<AGROW>
                filteredSiteDetails(end + 1, 1) = filteredDetail; %#ok<AGROW>
            end

            % Publica as coleções resultantes no formato esperado pelo restante do fluxo.
            filteredData.points = filteredPoints;
            filteredData.siteDetails = filteredSiteDetails;
        end

        

        
        function [startDate, endDate] = getNormalizedFilterDateRange(app)
            % Normaliza o intervalo selecionado para evitar janelas invertidas.

            % Esse helper é usado por getAppliedFilter e pelos callbacks de data
            % para manter um contrato consistente entre os date pickers e as
            % rotinas que avaliam vigência das estações.
            startDate = normalizeToDatetime(app, app.StartDate.Value);
            endDate = normalizeToDatetime(app, app.EndDatePicker.Value);

            % Se qualquer uma das pontas estiver ausente, preserva o retorno como
            % NaT para indicar filtro temporal parcial ou inexistente.
            if isnat(startDate) || isnat(endDate)
                return
            end

            % Remove o componente horário antes de comparar e publicar a janela.
            startDate = dateshift(startDate, 'start', 'day');
            endDate = dateshift(endDate, 'start', 'day');

            % Quando o usuário inverter as datas, corrige o limite final para não
            % deixar a interface em um estado inconsistente.
            if startDate > endDate
                endDate = startDate;
                app.EndDatePicker.Value = endDate;
            end
        end

             
        function output = filterSiteDetailStations(app, detail, statusFilter, localityFilter, equipmentFilter, startDt, endBefore)
            % Mantém no detalhe apenas as estações compatíveis com os filtros ativos.

            % Esse helper é chamado por getAppliedFilter quando existe algum
            % recorte efetivo de data, status, localidade ou equipamento, para
            % reduzir o site_detail ao subconjunto de estações ainda elegível.
            output = detail;

            % Se o detalhe já vier sem estações, apenas recompõe o estado agregado
            % vazio no mesmo contrato esperado pelo restante do fluxo.
            if isempty(detail.stations)
                output = rebuildFilteredSiteDetail(app, output, detail.stations([]));
                return
            end

            % Parte de uma máscara totalmente permissiva e elimina estação por
            % estação conforme cada regra de filtro for falhando.
            stations = detail.stations;
            keepMask = true(numel(stations), 1);

            for ii = 1:numel(stations)
                station = stations(ii);

                % A janela temporal é avaliada primeiro, porque costuma ser o
                % recorte mais restritivo quando há período selecionado.
                if ~stationMatchesDateFilter(app, station, startDt, endBefore)
                    keepMask(ii) = false;
                    continue
                end

                % Em seguida aplica o status agregado da estação.
                if ~stationMatchesStatusFilter(app, station, statusFilter)
                    keepMask(ii) = false;
                    continue
                end

                % Depois valida se a posição da estação é atual ou histórica,
                % conforme o filtro de localidade escolhido.
                if ~stationMatchesLocalityFilter(app, station, localityFilter)
                    keepMask(ii) = false;
                    continue
                end

                % O filtro por equipamento fecha a triagem no nível individual da estação.
                if ~stationMatchesEquipmentFilter(app, station, equipmentFilter)
                    keepMask(ii) = false;
                end
            end

            % Recalcula o estado agregado do site a partir apenas das estações
            % sobreviventes, mantendo consistência com marcador e popup.
            output = rebuildFilteredSiteDetail(app, output, stations(keepMask));
        end

        
        function output = rebuildFilteredSiteDetail(app, detail, stations)
            % Reconstroi o estado agregado do site a partir das estacoes restantes.

            % Esse helper fecha o ciclo iniciado em filterSiteDetailStations:
            % depois de podar as estacoes individuais, ele recompõe no
            % site_detail todos os campos agregados que o restante da interface
            % usa para marcador, popup e filtros subsequentes.
            output = detail;
            output.stations = stations;

            % Quando nenhuma estacao sobrevive ao recorte, publica o estado
            % neutro esperado pelo mapa para representar ausencia de host.
            if isempty(output.stations)
                output.marker_state = "no_host";
                output.has_online_station = false;
                output.has_online_host = false;
                output.has_known_host = false;
                return
            end

            % Recalcula o marker_state dominante e os indicadores agregados a
            % partir apenas das estacoes remanescentes.
            output.marker_state = summarizeSiteMarkerState(app, output.stations);
            stationStates = string({output.stations.map_state});
            output.has_online_station = any(stationStates == "online_current" | stationStates == "online_previous");
            output.has_online_host = output.has_online_station;

            % has_known_host continua refletindo se ainda existe ao menos uma
            % estacao com host resolvido dentro do subconjunto filtrado.
            output.has_known_host = any(~arrayfun(@(station) isempty(station.host_id), output.stations));
        end

        
        function output = stationMatchesDateFilter(app, station, startDt, endBefore)
            % Avalia se a estacao intercepta a janela temporal ativa.

            % Esse wrapper evita espalhar por filterSiteDetailStations a regra
            % de curto-circuito para cenarios sem filtro temporal efetivo.
            if isnat(startDt) && isnat(endBefore)
                output = true;
            else
                % Quando existe alguma ponta temporal valida, delega o teste de
                % sobreposicao ao helper especializado de vigencia.
                output = stationOverlapsDateRange(app, station, startDt, endBefore);
            end
        end

        
        function output = stationMatchesStatusFilter(app, station, statusFilter)
            % Avalia o filtro de status no nivel da estacao.

            % A comparacao acontece sobre map_state, que ja carrega a leitura
            % visual consolidada usada tambem na plotagem dos marcadores.
            output = statusFilterMatchesMapState(app, station.map_state, statusFilter);
        end

        
        function output = stationMatchesLocalityFilter(~, station, localityFilter)
            % Avalia o filtro de posicao atual ou historica no nivel da estacao.

            % Esse predicado traduz diretamente o valor do dropdown de
            % localidade para a flag is_current_location da estacao.
            switch string(localityFilter)
                case "Apenas atuais"
                    output = logical(station.is_current_location);
                case "Apenas históricas"
                    output = ~logical(station.is_current_location);
                otherwise
                    % Sem recorte explicito de localidade, a estacao permanece.
                    output = true;
            end
        end

        
        function output = stationMatchesEquipmentFilter(~, station, equipmentFilter)
            % Avalia o filtro de equipamento no nivel da estacao.

            % O filtro so fica restritivo quando filesStationDropDown conseguiu
            % resolver um equipment_id numerico valido; fora disso, ele e neutro.
            if isnan(equipmentFilter)
                output = true;
                return
            end

            % Compara o identificador da estacao no mesmo formato numerico usado
            % pelo restante do pipeline de filtros.
            output = str2double(string(station.equipment_id)) == equipmentFilter;
        end


        function output = stationOverlapsDateRange(app, station, startDt, endBefore)
            % Testa se a estacao teve vigencia dentro da janela selecionada.

            % A funcao normaliza first_seen_at e last_seen_at e trata ambos como
            % um intervalo de vigencia da estacao para confrontar com a janela
            % escolhida pelo usuario na aba Arquivos.
            firstSeen = normalizeToDatetime(app, station.first_seen_at);
            lastSeen = normalizeToDatetime(app, station.last_seen_at);

            % Sem nenhuma referencia temporal nao ha como afirmar intersecao.
            if isnat(firstSeen) && isnat(lastSeen)
                output = false;
                return
            end

            % Quando uma das pontas vier ausente, reaproveita a outra para manter
            % um intervalo degenerado, mas ainda comparavel.
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

            % Descarta estacoes cujo periodo termine antes do inicio filtrado.
            if ~isnat(startDt) && intervalEnd < startDt
                output = false;
                return
            end

            % O limite superior segue a convencao exclusiva adotada por
            % getAppliedFilter/getDateFilterValue.
            if ~isnat(endBefore) && intervalStart >= endBefore
                output = false;
                return
            end

            % Se nao violou nenhuma das bordas, existe sobreposicao util entre
            % a vigencia da estacao e a janela pedida.
            output = true;
        end


        function output = buildPointFromDetail(app, basePoint, detail)
            % Reconstroi o ponto publico a partir do detalhe filtrado por data.

            % Depois que getAppliedFilter/refilterSiteDetailStations podam o
            % detalhe interno do site, este helper recompõe a versão pública do
            % ponto consumida pelo mapa, preservando apenas os campos realmente
            % usados fora de site_detail.
            pointStations = emptyPublicStationArray(app);
            stationNames = strings(0, 1);

            for ii = 1:numel(detail.stations)
                % Cada estação remanescente vira uma versão enxuta para compor a
                % coleção publicada em point.stations.
                publicStation = buildPublicStation(app, detail.stations(ii));
                pointStations(end + 1, 1) = publicStation; %#ok<AGROW>

                % Em paralelo, acumula os nomes exibíveis usados por partes da UI
                % que dependem da lista textual de estações do ponto.
                stationName = chooseName(app, detail.stations(ii));
                if strlength(stationName) > 0
                    stationNames(end + 1, 1) = stationName; %#ok<AGROW>
                end
            end

            % Copia o ponto base e substitui somente os campos derivados do
            % detalhe filtrado para manter o restante dos metadados intacto.
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

            % Esse helper cria a coleção tipada vazia usada como ponto de partida
            % em buildPointFromDetail, evitando que o campo stations oscile entre
            % formatos incompatíveis quando o site ficar sem estações visíveis.
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

            % O objetivo aqui e reduzir a estacao ao subconjunto realmente
            % consumido por plotagem, popup e demais fluxos que trabalham com o
            % ponto publico, sem carregar o payload integral de site_detail.
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

            % Essa redução consolida vários map_state individuais em um único
            % marker_state para o ponto agregado do mapa.
            if isempty(stations)
                output = "no_host";
                return
            end

            output = "no_host";
            bestPriority = mapStatePriority(app, output);

            for ii = 1:numel(stations)
                stationState = string(stations(ii).map_state);
                statePriority = mapStatePriority(app, stationState);

                % Quanto menor a prioridade numérica, maior o destaque visual que
                % esse estado deve assumir no marcador agregado.
                if statePriority < bestPriority
                    output = stationState;
                    bestPriority = statePriority;
                end
            end
        end

        
        function output = mapStatePriority(~, stateKey)
            % Prioridade menor significa maior destaque visual no mapa.

            % Esse ranking sustenta summarizeSiteMarkerState e define qual estado
            % deve prevalecer quando um site reúne estacoes com condições mistas.
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

        
        function output = statusFilterMatchesMapState(~, mapState, statusFilter)
            % Centraliza a leitura do filtro de status sobre qualquer map_state.
            mapState = string(mapState);

            switch string(statusFilter)
                case "Apenas online"
                    output = any(mapState == ["online_current", "online_previous"]);
                case "Apenas offline"
                    output = any(mapState == ["offline_current", "offline_previous"]);
                otherwise
                    output = true;
            end
        end

        
        function output = detailMatchesLocality(~, detail, localityFilter)
            % Filtra por localizacao atual ou historica entre as estacoes do site.

            % Esse helper roda depois da poda individual e responde se o site ainda
            % mantém ao menos uma estação compatível com o recorte de localidade.
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
                    % Sem filtro de localidade, qualquer composição remanescente
                    % do site continua válida nesta etapa.
                    output = true;
            end
        end

        
        %-----------------------------------------------------------------
        % Helpers de Uso Geral
        %-----------------------------------------------------------------
        function output = formatFilesLocalityOption(app, row)
            % Monta o rótulo exibido para cada localidade na aba Arquivos.

            % Essa formatação é usada por updateFilesLocationOptions ao converter
            % as linhas retornadas do banco em Items do filesLocationDropDown,
            % preservando um texto legível mesmo quando parte dos campos vier vazia.

            % O nome principal da localidade é a base do rótulo; quando ele não
            % existir, a função usa '-' como fallback visual neutro.
            output = displayRawText(app, row.LOCALITY_LABEL, '-');
            county = displayRawText(app, row.COUNTY_NAME, '');
            stateCode = displayRawText(app, row.STATE_CODE, '');

            % Município e UF formam um sufixo complementar entre parênteses,
            % ajudando a distinguir localidades com nomes parecidos.
            suffix = "";
            if strlength(county) > 0 && strlength(stateCode) > 0
                suffix = county + "/" + stateCode;
            elseif strlength(county) > 0
                suffix = county;
            elseif strlength(stateCode) > 0
                suffix = stateCode;
            end

            % Evita repetir a mesma informação quando o rótulo principal já
            % coincide com o texto calculado para o sufixo.
            if strlength(suffix) > 0 && ~strcmpi(char(output), char(suffix))
                output = output + " (" + suffix + ")";
                output = sort(output);
            end

            
        end

        
        function output = displayRawText(app, rawValue, defaultValue)
            % Normaliza valores textuais heterogêneos para um texto exibível.

            % Esse helper é usado nas rotinas que montam rótulos da aba
            % Arquivos, como loadFilesStationOptions e formatFilesLocalityOption,
            % para absorver variações comuns do backend sem espalhar tratamento
            % de célula, vazio ou missing pelo restante do fluxo.

            output = normalizeTextFromValue(app, rawValue);
            if strlength(output) == 0
                output = string(defaultValue);
            end
        end

        
        function output = formatNumericId(~, rawValue)
            % Converte um identificador bruto para a forma textual usada nos dropdowns.

            % Esse helper é aplicado quando IDs vindos do banco precisam virar
            % ItemsData em loadFilesStationOptions e updateFilesLocationOptions,
            % além de servir na normalização de seleções preferenciais antes de
            % comparar valores publicados na interface.

            % Valores inválidos ou não numéricos voltam como string vazia, que no
            % restante do fluxo representa ausência de identificador selecionável.
            numericValue = str2double(string(rawValue));
            if isnan(numericValue)
                output = "";
            else
                % Mantém o ID em formato inteiro textual para alinhar com o tipo
                % esperado por ItemsData e pelas comparações com Value do dropdown.
                output = string(round(numericValue));
            end
        end

        
        function output = extractMinDateFromRows(app, rows, fieldName)
            % Extrai a menor data válida presente em uma coluna da tabela.

            % Esse helper é usado na atualização do período disponível da aba
            % Arquivos para consolidar o limite inicial a partir das linhas já
            % carregadas em app.filesLocalityRows.
            output = NaT;

            % Sem tabela válida, sem linhas ou sem a coluna pedida não existe
            % base confiável para calcular o mínimo.
            if ~istable(rows) || isempty(rows) || ~ismember(fieldName, rows.Properties.VariableNames)
                return
            end

            % Converte cada valor bruto da coluna para datetime antes de aplicar
            % a redução, reaproveitando a normalização centralizada em rawToDatetime.
            values = NaT(height(rows), 1);
            for ii = 1:height(rows)
                values(ii) = rawToDatetime(app, rows.(fieldName)(ii));
            end

            % Ignora entradas inválidas e só publica resultado quando sobrar ao
            % menos uma data útil para o cálculo.
            values = values(~isnat(values));
            if ~isempty(values)
                output = min(values);
            end
        end

        function output = extractMaxDateFromRows(app, rows, fieldName)
            % Extrai a maior data válida presente em uma coluna da tabela.

            % A função complementa extractMinDateFromRows no cálculo da janela
            % temporal exibida na aba Arquivos, definindo o limite final que pode
            % ser publicado nos date pickers.
            output = NaT;

            % Se a tabela não trouxer a coluna esperada ou vier vazia, mantém o
            % fallback NaT para sinalizar ausência de período inferível.
            if ~istable(rows) || isempty(rows) || ~ismember(fieldName, rows.Properties.VariableNames)
                return
            end

            % Normaliza os valores heterogêneos da coluna para datetime antes de
            % procurar o maior instante realmente utilizável.
            values = NaT(height(rows), 1);
            for ii = 1:height(rows)
                values(ii) = rawToDatetime(app, rows.(fieldName)(ii));
            end

            % Remove NaT do conjunto e só aplica max quando houver pelo menos uma
            % data válida remanescente.
            values = values(~isnat(values));
            if ~isempty(values)
                output = max(values);
            end
        end

        function output = rawToDatetime(~, rawValue)
            % Converte valores brutos heterogêneos para datetime escalar.

            % Esse helper sustenta extractMinDateFromRows e extractMaxDateFromRows,
            % concentrando em um único ponto o tratamento dos formatos vindos do
            % backend antes de calcular a janela temporal disponível.
            output = NaT;
            value = rawValue;

            % Alguns campos chegam encapsulados em célula; a função desempacota
            % recursivamente até encontrar a carga útil efetiva.
            while iscell(value)
                if isempty(value)
                    return
                end
                value = value{1};
            end

            % Valor vazio continua representando ausência de data útil.
            if isempty(value)
                return
            end

            try
                % Se já for datetime, reaproveita o primeiro elemento; caso
                % contrário, delega a interpretação ao construtor padrão.
                if isdatetime(value)
                    output = value(1);
                else
                    output = datetime(value);
                end
            catch
                % Falhas de conversão permanecem como NaT para que os chamadores
                % possam simplesmente descartar entradas inválidas.
                output = NaT;
            end
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

        %-----------------------------------------------------------------%
        function refreshDependentDropdowns(app)
            % Reconstrói filesStationDropDown, filesLocationDropDown e período a
            % partir dos dados do mapa em memória (app.repoSFI), aplicando os
            % filtros de estado, status e tipo de localidade atualmente ativos.
            %
            % Essa função é invocada quando um filtro que não possui equivalente
            % direto no banco (status online/offline, posição atual/histórica)
            % muda de valor, permitindo que os demais seletores se ajustem em
            % cascata sem nova consulta ao banco de dados.

            % Guarda seleções anteriores para tentar restaurá-las após o rebuild.
            prevEquipId = string(app.Receiver.Value);
            prevSiteId  = string(app.Location.Value);

            equipItems = {'Selecione uma estação/equipamento'};
            equipData  = {''};
            siteItems  = {'Todas as localidades'};
            siteData   = {''};
            seenEquipIds = {};
            seenSiteIds  = {};
            allDates     = NaT(0, 1);

            hasData = ~isempty(app.repoSFI) && isstruct(app.repoSFI) && ...
                      isfield(app.repoSFI, 'points') && ~isempty(app.repoSFI.points);

            if hasData
                stateCode = app.State.Value;
                statusFilter   = string(app.ReceiverStatus.Value);
                localityFilter = string(app.ReceiverPosition.Value);

                basePoints      = app.repoSFI.points;
                baseSiteDetails = app.repoSFI.siteDetails;

                for ii = 1:numel(basePoints)
                    point = basePoints(ii);

                    % Filtro de estado: descarta pontos fora da UF selecionada.
                    if ~isempty(stateCode) && ~strcmp(normalizeTextFromValue(app, point.state_code), stateCode)
                        continue
                    end

                    % Busca o detalhe do site pelo alinhamento posicional ou por ID.
                    if numel(baseSiteDetails) >= ii && baseSiteDetails(ii).site_id == point.site_id
                        detail = baseSiteDetails(ii);
                    else
                        didx = find([baseSiteDetails.site_id] == point.site_id, 1);
                        if isempty(didx), continue; end
                        detail = baseSiteDetails(didx);
                    end

                    siteContributed = false;
                    for jj = 1:numel(detail.stations)
                        st = detail.stations(jj);

                        % Filtro de status: verifica map_state da estação.
                        if ~statusFilterMatchesMapState(app, st.map_state, statusFilter)
                            continue
                        end

                        % Filtro de tipo de localidade: verifica is_current_location.
                        switch localityFilter
                            case "Apenas atuais"
                                if ~logical(st.is_current_location), continue, end
                            case "Apenas históricas"
                                if logical(st.is_current_location), continue, end
                        end

                        siteContributed = true;

                        % Coleta o equipamento, evitando duplicatas.
                        if ~isempty(st.equipment_id)
                            eqIdStr = char(string(round(double(st.equipment_id))));
                            if ~any(strcmp(seenEquipIds, eqIdStr))
                                seenEquipIds{end+1} = eqIdStr; %#ok<AGROW>
                                eqName = char(normalizeTextFromValue(app, st.equipment_name));
                                if isempty(eqName), eqName = '(sem nome)'; end
                                equipItems{end+1} = eqName;  %#ok<AGROW>
                                equipData{end+1}  = eqIdStr; %#ok<AGROW>
                            end
                        end

                        % Acumula datas de vigência para calcular o período disponível.
                        fs = normalizeToDatetime(app, st.first_seen_at);
                        ls = normalizeToDatetime(app, st.last_seen_at);
                        if ~isnat(fs), allDates(end+1, 1) = fs; end %#ok<AGROW>
                        if ~isnat(ls), allDates(end+1, 1) = ls; end %#ok<AGROW>
                    end

                    % Registra o site quando ao menos uma estação passou nos filtros.
                    if siteContributed
                        siteIdStr = char(string(round(double(point.site_id))));
                        if ~any(strcmp(seenSiteIds, siteIdStr))
                            seenSiteIds{end+1} = siteIdStr; %#ok<AGROW>
                            siteLabel = formatSiteLabelFromPoint(app, point);
                            siteItems{end+1} = char(siteLabel); %#ok<AGROW>
                            siteData{end+1}  = siteIdStr;       %#ok<AGROW>
                        end
                    end
                end
            end

            % Ordena alfabeticamente mantendo a opção neutra sempre na 1ª posição.
            if numel(equipItems) > 1
                [sortedEq, sortIdxEq] = sort(equipItems(2:end));
                equipItems = [equipItems(1), sortedEq];
                equipData  = [equipData(1),  equipData(sortIdxEq + 1)];
            end
            if numel(siteItems) > 1
                [sortedSite, sortIdxSite] = sort(siteItems(2:end));
                siteItems = [siteItems(1), sortedSite];
                siteData  = [siteData(1),  siteData(sortIdxSite + 1)];
            end

            % Publica os equipamentos, restaurando a seleção anterior quando válida.
            app.Receiver.Items     = equipItems;
            app.Receiver.ItemsData = equipData;
            if any(strcmp(equipData, char(prevEquipId)))
                app.Receiver.Value = char(prevEquipId);
            else
                app.Receiver.Value = '';
            end

            % Publica as localidades, restaurando a seleção anterior quando válida.
            app.Location.Items     = siteItems;
            app.Location.ItemsData = siteData;
            if strlength(prevSiteId) > 0 && any(strcmp(siteData, char(prevSiteId)))
                app.Location.Value = char(prevSiteId);
            else
                app.Location.Value = '';
            end

            % Limpa o cache de localidades do BD para evitar inconsistências
            % com os dados derivados em memória.
            app.filesLocalityRows = table();

            % Atualiza o período a partir das datas coletadas das estações filtradas.
            app.StartDate.Value = NaT;
            app.EndDatePicker.Value   = NaT;
            validDates = allDates(~isnat(allDates));
            if ~isempty(validDates)
                app.StartDate.Value = min(validDates);
                app.EndDatePicker.Value   = max(validDates);
            end
    end

    function label = formatSiteLabelFromPoint(app, point)
            % Monta o rótulo de uma localidade a partir de um ponto do mapa.
            %
            % Espelha formatFilesLocalityOption mas opera sobre a estrutura
            % de ponto do app.repoSFI em vez de sobre uma linha de tabela do BD.
            mainLabel = displayRawText(app, point.site_label, '-');
            county    = displayRawText(app, point.county_name, '');
            stCode    = displayRawText(app, point.state_code,  '');

            suffix = "";
            if strlength(county) > 0 && strlength(stCode) > 0
                suffix = county + "/" + stCode;
            elseif strlength(county) > 0
                suffix = county;
            elseif strlength(stCode) > 0
                suffix = stCode;
            end

            if strlength(suffix) > 0 && ~strcmpi(char(mainLabel), char(suffix))
                label = mainLabel + " (" + suffix + ")";
            else
                label = mainLabel;
            end
    end

    function syncFiltersFromDock(app, filters)
            % Sincroniza os seletores do painel de filtros com os valores vindos
            % do dockRepoFiles.
            %
            % A atualização programática de .Value em MATLAB UI não dispara
            % ValueChangedFcn, portanto não há risco de cascata de callbacks.
            % Quando o estado (UF) muda, as listas de equipamentos e localidades
            % precisam ser recarregadas do banco antes de restaurar os valores.

            stateChanged = false;

            % Estado (UF) ------------------------------------------------
            if isfield(filters, 'stateCode')
                targetState = char(filters.stateCode);

                if ismember(targetState, app.State.Items) && ~strcmp(app.State.Value, targetState)
                    app.State.Value = targetState;
                    stateChanged = true;
                end
            end

            % Quando o estado mudou, recarrega as listas dependentes do banco
            % para que ItemsData de equipamento e localidade fiquem coerentes
            % com a nova UF antes de tentar restaurar as seleções do dock.
            if stateChanged
                loadFilesStationOptions(app)
            end

            % Equipamento / estação --------------------------------------
            if isfield(filters, 'equipmentId')
                if isnan(filters.equipmentId)
                    if any(strcmp(app.Receiver.ItemsData, ''))
                        app.Receiver.Value = '';
                    end
                else
                    equipId = char(string(round(filters.equipmentId)));
                    if any(strcmp(app.Receiver.ItemsData, equipId))
                        app.Receiver.Value = equipId;
                    end
                end
            end

            % Localidade -------------------------------------------------
            % Quando o estado mudou, usa updateFilesLocationOptions para
            % recarregar os distritos do banco já com o filtro de UF correto,
            % passando o districtId preferido para restauração automática.
            % Caso contrário, restaura o valor diretamente na lista existente.
            preferredDistrictId = NaN;
            if isfield(filters, 'districtId') && ~isnan(filters.districtId)
                preferredDistrictId = filters.districtId;
            end

            if stateChanged
                updateFilesLocationOptions(app, preferredDistrictId)
                % updateFilesLocationOptions já chama updateFilesAvailablePeriod
            else
                if isfield(filters, 'districtId')
                    if isnan(filters.districtId)
                        if any(strcmp(app.Location.ItemsData, ''))
                            app.Location.Value = '';
                        end
                    else
                        distId = char(string(round(filters.districtId)));
                        if any(strcmp(app.Location.ItemsData, distId))
                            app.Location.Value = distId;
                        end
                    end
                end
            end

            % Datas ------------------------------------------------------
            % Definidas após updateFilesLocationOptions para sobrescrever
            % qualquer reset de período feito por updateFilesAvailablePeriod.
            if isfield(filters, 'startDate') && isdatetime(filters.startDate) && ~isnat(filters.startDate)
                app.StartDate.Value = filters.startDate;
            end
            if isfield(filters, 'endDate') && isdatetime(filters.endDate) && ~isnat(filters.endDate)
                app.EndDatePicker.Value = filters.endDate;
            end

            % Atualiza o mapa com os filtros recém-sincronizados.
            refreshFilteredMap(app)
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

        % Image clicked function: dockModule_Close, dockModule_Undock
        function onDockModuleGroupButtonClicked(app, event)

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

        % Image clicked function: axesTool_RegionZoom, axesTool_RestoreView
        function onAxesToolbarZoomControlButtonClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    geolimits(app.UIAxes, 'auto')

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes, app.axesTool_RegionZoom, findobj(app.UIAxes.Children, 'Tag', 'receiverStation'))

                case app.axesTool_Basemap
                    app.UIAxes.Basemap = event.Value;

                    switch event.Value
                        case {'darkwater', 'none'}
                            app.UIAxes.Grid = 'on';
                        otherwise
                            app.UIAxes.Grid = 'off';
                    end
            end

        end

        % Image clicked function: tool_LayoutLeft, tool_OpenPopupApp, 
        % ...and 1 other component
        function onToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.tool_LayoutLeft
                    if app.LeftPanel.Visible
                        app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left-off.svg';
                        app.LeftPanel.Visible = 'off';
                        app.GridLayout.ColumnWidth(2:3) = {0, 0};
                    else
                        app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';
                        app.LeftPanel.Visible = 'on';
                        app.GridLayout.ColumnWidth(2:3) = {232, 10};
                    end

                case app.tool_OpenPopupApp
                    [startDate, endDate] = getNormalizedFilterDateRange(app);        
                    dockContext = struct( ...
                        'equipmentId', str2double(string(app.Receiver.Value)), ...
                        'districtId',  str2double(string(app.Location.Value)), ...
                        'stateCode',   app.State.Value, ...
                        'hostId',      [], ...                
                        'startDate',   startDate, ...
                        'endDate',     endDate, ...
                        'freqStart',   NaN, ...
                        'freqEnd',     NaN, ...
                        'description', '' ...
                    );

                    openRepoFilesDock(app, dockContext);

                case app.tool_RefreshFilterValues
                    % Restaura os filtros da aba Arquivos ao estado inicial da tela.
                    app.State.Value = '';
                    app.ReceiverStatus.Value = 'Todos';
                    app.ReceiverPosition.Value = 'Todas';
        
                    %app.filesDescriptionEditField.Value = '';
                    app.StartDate.Value = NaT;
                    app.EndDatePicker.Value = NaT;
        
                    loadFilesStationOptions(app)
                    app.Receiver.Value = '';
                    updateFilesLocationOptions(app, NaN)
        
                    hidePointPopup(app)
                    refreshFilteredMap(app)
            end

        end

        % Value changed function: axesTool_Basemap
        function onMapStyleChanged(app, event)
            


        end

        % Value changed function: EndDatePicker, Location, Receiver, 
        % ...and 4 other components
        function onFilterValueChanged(app, event)
            
            switch event.Source
                case {app.State, app.ReceiverStatus, app.ReceiverPosition}
                    if isequal(event.Source, app.State)
                        loadFilesStationOptions(app)
                        updateFilesLocationOptions(app, NaN)
                    else
                        refreshDependentDropdowns(app)
                    end

                case app.Location
                    loadFilesStationOptions(app)
                    updateFilesAvailablePeriod(app);

                case {app.StartDate, app.EndDatePicker}
                    getNormalizedFilterDateRange(app);

                case app.Receiver
                    currentDistrict = app.Location.Value;
                    updateFilesLocationOptions(app, currentDistrict)
            end

            refreshFilteredMap(app)

            hasValidFilter = ~isequal(app.defaultValues, getFilterCurrentSpecification(app));
            set([app.tool_OpenPopupApp, app.tool_RefreshFilterValues], 'Enable', hasValidFilter)            
            
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
            app.GridLayout.ColumnWidth = {10, 232, 10, 5, 190, '1x', 200, 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, '1x', 320};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 10];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_LayoutLeft
            app.tool_LayoutLeft = uiimage(app.Toolbar);
            app.tool_LayoutLeft.ScaleMethod = 'none';
            app.tool_LayoutLeft.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.tool_LayoutLeft.Layout.Row = [1 3];
            app.tool_LayoutLeft.Layout.Column = 1;
            app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 2;
            app.tool_Separator.VerticalAlignment = 'bottom';
            app.tool_Separator.ImageSource = 'LineV.svg';

            % Create tool_OpenPopupApp
            app.tool_OpenPopupApp = uiimage(app.Toolbar);
            app.tool_OpenPopupApp.ScaleMethod = 'none';
            app.tool_OpenPopupApp.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.tool_OpenPopupApp.Enable = 'off';
            app.tool_OpenPopupApp.Layout.Row = [1 3];
            app.tool_OpenPopupApp.Layout.Column = 3;
            app.tool_OpenPopupApp.ImageSource = 'search-sparkle.svg';

            % Create tool_RefreshFilterValues
            app.tool_RefreshFilterValues = uiimage(app.Toolbar);
            app.tool_RefreshFilterValues.ScaleMethod = 'none';
            app.tool_RefreshFilterValues.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.tool_RefreshFilterValues.Enable = 'off';
            app.tool_RefreshFilterValues.Layout.Row = [1 3];
            app.tool_RefreshFilterValues.Layout.Column = 4;
            app.tool_RefreshFilterValues.ImageSource = 'Refresh_18.png';

            % Create tool_FileCount
            app.tool_FileCount = uilabel(app.Toolbar);
            app.tool_FileCount.HorizontalAlignment = 'right';
            app.tool_FileCount.FontSize = 11;
            app.tool_FileCount.Layout.Row = [1 3];
            app.tool_FileCount.Layout.Column = 6;
            app.tool_FileCount.Text = '';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.AutoResizeChildren = 'off';
            app.LeftPanel.Layout.Row = [3 4];
            app.LeftPanel.Layout.Column = 2;

            % Create LeftPanelGrid
            app.LeftPanelGrid = uigridlayout(app.LeftPanel);
            app.LeftPanelGrid.ColumnWidth = {22, 5, 73, 10, 100};
            app.LeftPanelGrid.RowHeight = {92, 17, 22, 22, 22, 22, 22, 22, 22, 69, '1x', 17};
            app.LeftPanelGrid.ColumnSpacing = 0;
            app.LeftPanelGrid.RowSpacing = 5;
            app.LeftPanelGrid.BackgroundColor = [1 1 1];

            % Create ModuleIcon
            app.ModuleIcon = uiimage(app.LeftPanelGrid);
            app.ModuleIcon.Layout.Row = 1;
            app.ModuleIcon.Layout.Column = 1;
            app.ModuleIcon.VerticalAlignment = 'top';
            app.ModuleIcon.ImageSource = 'library-24px.svg';

            % Create ModuleIntro
            app.ModuleIntro = uilabel(app.LeftPanelGrid);
            app.ModuleIntro.VerticalAlignment = 'top';
            app.ModuleIntro.WordWrap = 'on';
            app.ModuleIntro.FontSize = 11;
            app.ModuleIntro.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ModuleIntro.Layout.Row = 1;
            app.ModuleIntro.Layout.Column = [3 5];
            app.ModuleIntro.Interpreter = 'html';
            app.ModuleIntro.Text = {'<b>REPOSFI</b>'; '<p style="padding: 2px; text-align: justify; font-size: 10px; color: gray; line-height: 13px">Centraliza a coleta, organiza e disponibiliza dados de monitoramento de espectro, integrando arquivos de estações remotas, fluxos de espectro e artefatos analíticos.</p>'};

            % Create StateLabel
            app.StateLabel = uilabel(app.LeftPanelGrid);
            app.StateLabel.VerticalAlignment = 'bottom';
            app.StateLabel.FontSize = 11;
            app.StateLabel.Layout.Row = 2;
            app.StateLabel.Layout.Column = [1 3];
            app.StateLabel.Text = 'UF:';

            % Create State
            app.State = uidropdown(app.LeftPanelGrid);
            app.State.Items = {};
            app.State.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.State.FontSize = 11;
            app.State.BackgroundColor = [1 1 1];
            app.State.Layout.Row = 3;
            app.State.Layout.Column = [1 3];
            app.State.Value = {};

            % Create LocationLabel
            app.LocationLabel = uilabel(app.LeftPanelGrid);
            app.LocationLabel.VerticalAlignment = 'bottom';
            app.LocationLabel.FontSize = 11;
            app.LocationLabel.Layout.Row = 4;
            app.LocationLabel.Layout.Column = [1 5];
            app.LocationLabel.Text = 'Localidade:';

            % Create Location
            app.Location = uidropdown(app.LeftPanelGrid);
            app.Location.Items = {'Todas as localidades'};
            app.Location.Editable = 'on';
            app.Location.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Location.FontSize = 11;
            app.Location.BackgroundColor = [1 1 1];
            app.Location.Layout.Row = 5;
            app.Location.Layout.Column = [1 5];
            app.Location.Value = 'Todas as localidades';

            % Create StartDateLabel
            app.StartDateLabel = uilabel(app.LeftPanelGrid);
            app.StartDateLabel.VerticalAlignment = 'bottom';
            app.StartDateLabel.FontSize = 11;
            app.StartDateLabel.Layout.Row = 6;
            app.StartDateLabel.Layout.Column = [1 5];
            app.StartDateLabel.Text = 'Período inicial:';

            % Create StartDate
            app.StartDate = uidatepicker(app.LeftPanelGrid);
            app.StartDate.DisplayFormat = 'dd/MM/yyyy';
            app.StartDate.Editable = 'off';
            app.StartDate.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.StartDate.FontSize = 11;
            app.StartDate.Layout.Row = 7;
            app.StartDate.Layout.Column = [1 3];

            % Create EndDateLabel
            app.EndDateLabel = uilabel(app.LeftPanelGrid);
            app.EndDateLabel.VerticalAlignment = 'bottom';
            app.EndDateLabel.FontSize = 11;
            app.EndDateLabel.Layout.Row = 6;
            app.EndDateLabel.Layout.Column = 5;
            app.EndDateLabel.Text = 'Período final:';

            % Create EndDatePicker
            app.EndDatePicker = uidatepicker(app.LeftPanelGrid);
            app.EndDatePicker.DisplayFormat = 'dd/MM/yyyy';
            app.EndDatePicker.Editable = 'off';
            app.EndDatePicker.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.EndDatePicker.FontSize = 11;
            app.EndDatePicker.Layout.Row = 7;
            app.EndDatePicker.Layout.Column = 5;

            % Create ReceiverLabel
            app.ReceiverLabel = uilabel(app.LeftPanelGrid);
            app.ReceiverLabel.VerticalAlignment = 'bottom';
            app.ReceiverLabel.FontSize = 11;
            app.ReceiverLabel.Layout.Row = 8;
            app.ReceiverLabel.Layout.Column = [1 3];
            app.ReceiverLabel.Text = 'Sensor';

            % Create Receiver
            app.Receiver = uidropdown(app.LeftPanelGrid);
            app.Receiver.Items = {''};
            app.Receiver.Editable = 'on';
            app.Receiver.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Receiver.FontSize = 11;
            app.Receiver.BackgroundColor = [1 1 1];
            app.Receiver.Layout.Row = 9;
            app.Receiver.Layout.Column = [1 5];
            app.Receiver.Value = '';

            % Create ReceiverPanel
            app.ReceiverPanel = uipanel(app.LeftPanelGrid);
            app.ReceiverPanel.Layout.Row = 10;
            app.ReceiverPanel.Layout.Column = [1 5];

            % Create ReceiverGrid
            app.ReceiverGrid = uigridlayout(app.ReceiverPanel);
            app.ReceiverGrid.RowHeight = {17, 22};
            app.ReceiverGrid.RowSpacing = 5;
            app.ReceiverGrid.BackgroundColor = [1 1 1];

            % Create ReceiverStatusLabel
            app.ReceiverStatusLabel = uilabel(app.ReceiverGrid);
            app.ReceiverStatusLabel.VerticalAlignment = 'bottom';
            app.ReceiverStatusLabel.FontSize = 11;
            app.ReceiverStatusLabel.Layout.Row = 1;
            app.ReceiverStatusLabel.Layout.Column = 1;
            app.ReceiverStatusLabel.Text = 'Status:';

            % Create ReceiverStatus
            app.ReceiverStatus = uidropdown(app.ReceiverGrid);
            app.ReceiverStatus.Items = {'Todos', 'Apenas online', 'Apenas offline'};
            app.ReceiverStatus.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.ReceiverStatus.FontSize = 11;
            app.ReceiverStatus.BackgroundColor = [1 1 1];
            app.ReceiverStatus.Layout.Row = 2;
            app.ReceiverStatus.Layout.Column = 1;
            app.ReceiverStatus.Value = 'Todos';

            % Create ReceiverPositionLabel
            app.ReceiverPositionLabel = uilabel(app.ReceiverGrid);
            app.ReceiverPositionLabel.VerticalAlignment = 'bottom';
            app.ReceiverPositionLabel.FontSize = 11;
            app.ReceiverPositionLabel.Layout.Row = 1;
            app.ReceiverPositionLabel.Layout.Column = 2;
            app.ReceiverPositionLabel.Text = 'Registro posição:';

            % Create ReceiverPosition
            app.ReceiverPosition = uidropdown(app.ReceiverGrid);
            app.ReceiverPosition.Items = {'Todas', 'Apenas atuais', 'Apenas históricas'};
            app.ReceiverPosition.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.ReceiverPosition.FontSize = 11;
            app.ReceiverPosition.BackgroundColor = [1 1 1];
            app.ReceiverPosition.Layout.Row = 2;
            app.ReceiverPosition.Layout.Column = 2;
            app.ReceiverPosition.Value = 'Todas';

            % Create Image
            app.Image = uiimage(app.LeftPanelGrid);
            app.Image.ScaleMethod = 'none';
            app.Image.Enable = 'off';
            app.Image.Layout.Row = 12;
            app.Image.Layout.Column = 1;
            app.Image.VerticalAlignment = 'top';
            app.Image.ImageSource = 'calendar.svg';

            % Create Label
            app.Label = uilabel(app.LeftPanelGrid);
            app.Label.FontSize = 11;
            app.Label.FontColor = [0.502 0.502 0.502];
            app.Label.Layout.Row = 12;
            app.Label.Layout.Column = [3 5];
            app.Label.Text = '';

            % Create AxesContainer
            app.AxesContainer = uipanel(app.GridLayout);
            app.AxesContainer.AutoResizeChildren = 'off';
            app.AxesContainer.ForegroundColor = [1 1 1];
            app.AxesContainer.BorderType = 'none';
            app.AxesContainer.BackgroundColor = [0 0 0];
            app.AxesContainer.Layout.Row = [3 4];
            app.AxesContainer.Layout.Column = [4 8];
            app.AxesContainer.FontSize = 11;

            % Create AxesPopup
            app.AxesPopup = uilabel(app.GridLayout);
            app.AxesPopup.VerticalAlignment = 'top';
            app.AxesPopup.WordWrap = 'on';
            app.AxesPopup.FontSize = 11;
            app.AxesPopup.Visible = 'off';
            app.AxesPopup.Layout.Row = [3 4];
            app.AxesPopup.Layout.Column = [7 8];
            app.AxesPopup.Interpreter = 'html';
            app.AxesPopup.Text = '';

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.GridLayout);
            app.AxesToolbar.ColumnWidth = {10, 25, 25, 5, 110, 10};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [0 2 0 1];
            app.AxesToolbar.Layout.Row = 3;
            app.AxesToolbar.Layout.Column = 5;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarZoomControlButtonClicked, true);
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 3;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarZoomControlButtonClicked, true);
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_Basemap
            app.axesTool_Basemap = uidropdown(app.AxesToolbar);
            app.axesTool_Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.axesTool_Basemap.ValueChangedFcn = createCallbackFcn(app, @onMapStyleChanged, true);
            app.axesTool_Basemap.FontSize = 11;
            app.axesTool_Basemap.BackgroundColor = [1 1 1];
            app.axesTool_Basemap.Layout.Row = 1;
            app.axesTool_Basemap.Layout.Column = 5;
            app.axesTool_Basemap.Value = 'satellite';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [8 9];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
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
