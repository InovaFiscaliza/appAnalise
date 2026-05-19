classdef winRepoSFI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        DockModule                matlab.ui.container.GridLayout
        dockModule_Close          matlab.ui.control.Image
        dockModule_Undock         matlab.ui.control.Image
        SubTabGroup               matlab.ui.container.Panel
        FilesMainGrid             matlab.ui.container.GridLayout
        filesCleanButton          matlab.ui.control.Button
        filesSearchButton         matlab.ui.control.Button
        referenceRX_Label_3       matlab.ui.control.Label
        referenceRX_Icon_3        matlab.ui.control.Image
        filesStationLabel         matlab.ui.control.Label
        filesSensorLocationLabel  matlab.ui.container.Panel
        filesSensorLocationGrid   matlab.ui.container.GridLayout
        filesStationDropDown      matlab.ui.control.DropDown
        filesSensorLabel          matlab.ui.control.Label
        filesPeriodPanel          matlab.ui.container.Panel
        filesPeriodGrid           matlab.ui.container.GridLayout
        filesEndDatePicker        matlab.ui.control.DatePicker
        filesStartDatePicker      matlab.ui.control.DatePicker
        filesEndDateLabel         matlab.ui.control.Label
        filesStartDateLabel       matlab.ui.control.Label
        filesLocationSelectLabel  matlab.ui.control.Label
        filesStationFilterPanel   matlab.ui.container.Panel
        filesStationsGrid         matlab.ui.container.GridLayout
        filesLocationDropDown     matlab.ui.control.DropDown
        filesLocationLabel        matlab.ui.control.Label
        filesLocalityDropDown     matlab.ui.control.DropDown
        filesStatusDropDown       matlab.ui.control.DropDown
        filesStateDropDown        matlab.ui.control.DropDown
        filesLocalityLabel        matlab.ui.control.Label
        filesStatusLabel          matlab.ui.control.Label
        filesStateLabel           matlab.ui.control.Label
        filesPeriodLabel          matlab.ui.control.Label
        Document                  matlab.ui.container.GridLayout
        popupHTML                 matlab.ui.control.Label
        AxesToolbar               matlab.ui.container.GridLayout
        configMapStyleDropDown    matlab.ui.control.DropDown
        axesTool_RestoreView      matlab.ui.control.Image
        axesTool_RegionZoom       matlab.ui.control.Image
        plotPanel                 matlab.ui.container.Panel
        Toolbar                   matlab.ui.container.GridLayout
        filesCountLabel           matlab.ui.control.Label
        tool_PanelVisibility      matlab.ui.control.Image
        ContextMenu               matlab.ui.container.ContextMenu
        contextmenu_del           matlab.ui.container.Menu
        contextmenu_delAll        matlab.ui.container.Menu
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
        repoFilesDock = []
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

                        closePopup(app);
                        openRepoFilesDockForStation(app, siteId, equipmentId, hostId)

                    case 'repoSFI.mapBackgroundClick'
                        closePopup(app);

                    case 'repoSFI.closePopup'
                        closePopup(app);


                    otherwise
                        error('auxApp:winRFDataHub:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
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

                            otherwise
                                error('auxApp:winRFDataHub:UnexpectedCall', 'Unexpected call "%s"', operationType)
                        end

                    case {'auxApp.dockRepoFiles', 'dockRepoFiles_exported'}
                        operationType = varargin{1};
                        app.repoFilesDock = callingApp;

                        switch operationType
                            case 'onDockFilterChanged'
                                syncFiltersFromDock(app, varargin{2})

                            otherwise
                                % Operações desconhecidas do dock são ignoradas silenciosamente.
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
                app.tool_PanelVisibility;
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

            % Incializa geoaxes - mapa grafico
            startup_AxesCreation(app)
        end

        
        function applyInitialLayout(app)
            populateStationFilters(app)
            initializeFilesSearchPanel(app)
            refreshFilteredMap(app)
            applyMapViewport(app, struct(), "fit")
        end
    end



    methods (Access = private)
        %-----------------------------------------------------------------%
        % Funções de Inicialização
        %-----------------------------------------------------------------%
        function initializeRepoSFI(app)
            % Inicializa o dataset principal do RepoSFI a partir do banco resumo.
            %
            % A função garante que o handler de acesso a dados esteja disponível,
            % consulta o payload consolidado do mapa e armazena o resultado em
            % app.repoSFI no contrato esperado pela interface.
            %
            % Quando a consulta não devolve a estrutura esperada, a função aplica um
            % fallback seguro com coleções vazias para evitar que etapas posteriores
            % do fluxo precisem tratar ausência de campos.
        
            % Garante a existência do handler compartilhado antes de qualquer leitura
            % do banco de dados.
            if isempty(app.dbHandler)
                app.dbHandler = util.DBHandler();
            end
        
            % Lê o dataset consolidado usado pela interface do RepoSFI.
            data = app.dbHandler.getMapDataSet();
        
            % Só aceita o resultado se ele respeitar o contrato mínimo esperado pelo
            % restante da aplicação.
            if isstruct(data) && isfield(data, 'points')
                app.repoSFI = data;
            else
                % Mantém a estrutura base mesmo em falha ou retorno incompleto, para
                % preservar a estabilidade dos fluxos que consomem app.repoSFI.
                app.repoSFI = struct('points', struct([]), 'site_details', struct([]));
            end
        end

       
        function populateStationFilters(app)
            % Preenche o filtro de estados com base nos pontos carregados no RepoSFI.
        
            % Sem o dropdown de destino ou sem os dados base do RepoSFI não existe
            % contexto suficiente para montar a lista de estados.
            if isempty(app.filesStateDropDown) || isempty(app.repoSFI)
                return
            end
        
            % Extrai os códigos de estado disponíveis e remove duplicidades antes de
            % atualizar a lista exibida ao usuário.
            points = app.repoSFI.points;
            states = [points.state_code];
            statesUnique = unique(states);
        
            % Mantém uma opção neutra no topo para permitir consulta sem filtro.
            app.filesStateDropDown.Items = [{'Todos os estados'}, statesUnique];
        end

        %-----------------------------------------------------------------%
        % Funções de manipulação do mapa
        %-----------------------------------------------------------------%
        function startup_AxesCreation(app)
            % Recria o geoaxes no painel e reinstala as interações padrão.
        
            % Sem um painel válido não há onde reconstruir o eixo geográfico.
            if isempty(app.plotPanel) || ~isvalid(app.plotPanel)
                return
            end
        
            % Limpa qualquer eixo anterior antes de recriar a área de plotagem.
            delete(app.plotPanel.Children)
            app.plotPanel.Visible = 'on';
        
            hParent = tiledlayout(app.plotPanel, 1, 1, "Padding", "none", "TileSpacing", "none");
        
            % Usa o estilo selecionado na aba de configuração quando disponível.
            initialBasemap = 'streets-light';
            if ~isempty(app.configMapStyleDropDown) && isvalid(app.configMapStyleDropDown)
                initialBasemap = char(string(app.configMapStyleDropDown.Value));
            end
        
            % Cria o geoaxes já com o estilo inicial e com os metadados visuais
            % esperados pelas rotinas de plotagem.
            app.UIAxes = plot.axes.Creation(hParent, 'Geographic', {'Basemap', initialBasemap, ...
                'Color', [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
        
            % Oculta elementos cartográficos auxiliares para priorizar a leitura dos
            % dados plotados.
            set(app.UIAxes.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            geolimits(app.UIAxes, 'auto')
            plot.axes.Colormap(app.UIAxes, 'turbo')
        
            % Reinstala as interações padrão após recriar o eixo.
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

        function restoreMapInteractions(app)
            % Reinstala as interações padrão que o geoaxes perde após cla().
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            plot.axes.Interactivity.DefaultCreation(app.UIAxes, ...
                [zoomInteraction, panInteraction])
        end


        function refreshFilteredMap(app, viewportMode)
            % Recalcula o recorte ativo e aciona um novo ciclo completo de mapa.

            % Esse helper é a ponte usada pelos callbacks dos filtros da aba
            % Arquivos para manter sincronizados o dataset filtrado em memória e
            % a visualização do geoaxes após cada mudança de estado.
            if nargin < 2
                % Na maior parte dos filtros o comportamento padrão preserva a
                % viewport quando isso ainda fizer sentido para a leitura atual.
                viewportMode = "preserve_if_all_states";
            end

            % Primeiro atualiza a fonte de verdade consumida pelo mapa; em
            % seguida, replota usando a estratégia de viewport pedida.
            updateFilteredRepoSFI(app)
            plot_Stations(app, viewportMode)
        end


        function viewportMode = normalizeViewportMode(~, viewportMode)
            % Normaliza o modo de atualização da viewport do mapa.
            % Fica estranho dar um zoom quando trocamos apenas o "Apenas
            % Online" ou "Apenas histórico" esta função evita zooms curtos
            if nargin < 2 || isempty(viewportMode)
                viewportMode = "preserve_if_all_states";
                return
            end

            viewportMode = string(viewportMode);
        end


        function output = selectedStateFilter(app)
            % Retorna o estado atualmente selecionado no filtro do mapa.
        
            % Usa a opção neutra como fallback quando o dropdown ainda não estiver
            % disponível ou não for mais válido.
            output = "Todos os estados";
        
            if isempty(app.filesStateDropDown) || ~isvalid(app.filesStateDropDown)
                return
            end
        
            % Normaliza a saída para string para simplificar as comparações nas
            % rotinas de filtragem e viewport.
            output = string(app.filesStateDropDown.Value);
        end

        
        function limits = getCurrentMapLimits(app)
            % Captura a viewport atual do mapa para uso no fluxo de replotagem.
            %
            % Esses limites são lidos antes de `cla(app.UIAxes)` em `plot_Stations`
            % e depois podem ser reaplicados por `applyMapViewport`, quando fizer
            % sentido preservar o enquadramento atual.
            limits = struct('latitude', [], 'longitude', []);
        
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end
        
            % Lê os limites atuais do geoaxes no formato esperado pelas rotinas de
            % preservação de viewport.
            latitudeLimits = double(app.UIAxes.LatitudeLimits);
            longitudeLimits = double(app.UIAxes.LongitudeLimits);
        
            % Só mantém a captura quando o par de limites puder ser reaplicado com
            % segurança no próximo ciclo de plot.
            candidateLimits = struct('latitude', latitudeLimits, 'longitude', longitudeLimits);
            if hasValidMapLimits(app, candidateLimits)
                limits = candidateLimits;
            end
        end


        function output = hasValidMapLimits(~, limits)
            % Valida se uma estrutura de limites pode voltar ao fluxo de viewport.
            %
            % Essa checagem protege os dois pontos que reaplicam ou preservam
            % enquadramento no mapa: a captura feita por getCurrentMapLimits e a
            % decisão tomada depois em applyMapViewport/shouldPreserveMapViewport.

            % O contrato esperado é o mesmo usado no restante do fluxo:
            % vetores latitude/longitude com dois extremos finitos e span positivo.
            output = isstruct(limits) && isfield(limits, 'latitude') && isfield(limits, 'longitude') && ...
                numel(limits.latitude) == 2 && numel(limits.longitude) == 2 && ...
                all(isfinite(limits.latitude)) && all(isfinite(limits.longitude)) && ...
                diff(limits.latitude) > 0 && diff(limits.longitude) > 0;
        end


        function applyMapViewport(app, previousLimits, viewportMode)
            % Aplica a regra final de enquadramento após a replotagem do mapa.
            %
            % Depois que plot_Stations limpa o eixo com cla(app.UIAxes) e redesenha
            % os pontos filtrados, esta função decide se a viewport anterior deve
            % ser restaurada ou se o mapa precisa ser reenquadrado com base no
            % dataset atual.

            % Normaliza o modo recebido e extrai os pontos já filtrados que
            % servirão de base para a decisão de preservação ou novo ajuste.
            viewportMode = normalizeViewportMode(app, viewportMode);
            points = struct([]);

            if isstruct(app.filteredRepoSFI) && isfield(app.filteredRepoSFI, 'points')
                points = app.filteredRepoSFI.points;
            end

            % Se o contexto atual ainda comporta a viewport anterior, reaplica os
            % limites capturados antes do cla; caso contrário, recalcula o ajuste.
            if shouldPreserveMapViewport(app, previousLimits, points, viewportMode)
                geolimits(app.UIAxes, previousLimits.latitude, previousLimits.longitude)
            else
                fitMapToPoints(app, points)
            end
        end

        
        function output = shouldPreserveMapViewport(app, previousLimits, points, viewportMode)
            % Decide se ainda faz sentido manter a viewport capturada antes do replot.
            %
            % Essa função é chamada por applyMapViewport depois que plot_Stations
            % limpa e redesenha o mapa. A ideia aqui é preservar o enquadramento
            % anterior só quando isso evita microajustes visuais sem esconder por
            % completo o conteúdo filtrado atual.

            output = false;

            % Se os limites vindos de getCurrentMapLimits já não formam uma
            % viewport reaplicável, o fluxo cai direto no reenquadramento.
            if ~hasValidMapLimits(app, previousLimits)
                return
            end

            switch normalizeViewportMode(app, viewportMode)
                case "preserve"
                    % Modo explícito de preservação: reaplica sempre os limites
                    % anteriores, desde que eles já tenham passado na validação.
                    output = true;

                case "preserve_if_all_states"
                    % Quando há filtro de UF ativo, a troca de contexto costuma
                    % exigir novo enquadramento; por isso esse modo só preserva a
                    % viewport na visão agregada de todos os estados.
                    if selectedStateFilter(app) ~= "Todos os estados"
                        return
                    end

                    % Sem pontos visíveis após o filtro, manter a viewport anterior
                    % evita um auto-fit sem referência útil.
                    if isempty(points)
                        output = true;
                        return
                    end

                    % Preserva apenas se ao menos parte do dataset filtrado ainda
                    % permanecer dentro da janela anterior; caso contrário, o novo
                    % recorte precisa recentralizar o mapa.
                    lat = double([points.latitude]);
                    lon = double([points.longitude]);
                    isInside = lat >= previousLimits.latitude(1) & lat <= previousLimits.latitude(2) & ...
                        lon >= previousLimits.longitude(1) & lon <= previousLimits.longitude(2);
                    output = any(isInside);
            end
        end

        
        function fitMapToPoints(app, points)
            % Recalcula a viewport do mapa a partir dos pontos atualmente filtrados.
            %
            % Esta é a rota usada por applyMapViewport quando a viewport anterior
            % não deve ser preservada. Em vez de depender do auto-fit do geoaxes,
            % a função monta manualmente um enquadramento mais estável para o fluxo
            % de replotagem de plot_Stations.

            % Tem um ajuste empirico aqui pois o geolimit com parametro
            % "auto" esticava muito a tela quando as estações estavam longe
            % ao ponto de ficar desconfortável a visualização

            % Sem um geoaxes válido não existe destino para aplicar os novos limites.
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

            % Sem pontos válidos, o melhor fallback é devolver o controle ao ajuste
            % automático nativo do mapa.
            if isempty(points)
                geolimits(app.UIAxes, 'auto')
                return
            end

            % Extrai e saneia as coordenadas que realmente podem participar do
            % cálculo do enquadramento.
            lat = double([points.latitude]);
            lon = double([points.longitude]);
            validIdx = isfinite(lat) & isfinite(lon);
            lat = lat(validIdx);
            lon = lon(validIdx);

            % Se depois da limpeza não sobrou nenhuma coordenada útil, cai no
            % mesmo fallback automático.
            if isempty(lat) || isempty(lon)
                geolimits(app.UIAxes, 'auto')
                return
            end

            % Parte do retângulo mínimo que contém o conjunto filtrado.
            minLat = min(lat);
            maxLat = max(lat);
            minLon = min(lon);
            maxLon = max(lon);
            centerLat = (minLat + maxLat) / 2;
            centerLon = (minLon + maxLon) / 2;

            % Garante spans mínimos e corrige longitude pela latitude central
            % para reduzir distorções horizontais do mapa.
            latSpan = max(maxLat - minLat, 0.30);
            cosScale = max(cosd(centerLat), 0.25);
            lonSpan = max(maxLon - minLon, 0.30 / cosScale);

            % Ajusta a janela ao aspect ratio útil do painel, para evitar um fit
            % apertado demais num eixo mais largo ou mais alto.
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

            % Aplica um padding fixo para que o replot não deixe os pontos colados
            % nas bordas após mudanças pequenas de filtro.
            latSpan = max(latSpan * 1.18, 0.45);
            lonSpan = max(lonSpan * 1.18, 0.45 / cosScale);

            latitudeLimits = centerLat + 0.5 * [-latSpan, latSpan];
            longitudeLimits = centerLon + 0.5 * [-lonSpan, lonSpan];

            % Limita os extremos ao intervalo aceito pelo geoaxes.
            latitudeLimits = max(min(latitudeLimits, 89.5), -89.5);
            longitudeLimits = max(min(longitudeLimits, 180), -180);

            % Se o cálculo degenerar mesmo após os ajustes, evita reaplicar uma
            % janela inválida e delega o enquadramento ao modo automático.
            if diff(latitudeLimits) <= 0 || diff(longitudeLimits) <= 0
                geolimits(app.UIAxes, 'auto')
                return
            end

            geolimits(app.UIAxes, latitudeLimits, longitudeLimits)
        end

        
        function clearPopupSelectionHighlight(app)
            % Limpa o highlight visual deixado pela seleção atual do popup.

            % Esse helper é usado sempre que o fluxo precisa descartar a
            % seleção destacada no mapa, como antes de redesenhar o geoaxes em
            % plot_Stations ou ao fechar explicitamente o popup.

            % Sem um geoaxes válido não existe estado gráfico a limpar.
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

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

            % Remove qualquer highlight anterior antes de desenhar o novo.
            clearPopupSelectionHighlight(app);

            % Normaliza o estado persistido do geoaxes para receber os novos
            % handles e os IDs destacados.
            axesState = getPopupHighlightState(app);

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

            % Persiste os handles e os IDs destacados no estado do eixo sem
            % alterar a estrutura base de UserData.
            axesState.popupHighlightHandle = highlightHandle;
            axesState.popupHighlightSiteIds = [popupSites.siteId];
            app.UIAxes.UserData = axesState;

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
            clearPopupSelectionHighlight(app)

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

        
        function output = getPopupHighlightState(app)
            % Normaliza o estado de highlight persistido no UserData do geoaxes.
            %
            % Esse helper centraliza o contrato usado por clearPopupSelectionHighlight
            % e updatePopupSelectionHighlight, para que o restante do fluxo nunca
            % precise lidar com ausência dos campos de highlight.

            output = struct();

            % Sem um geoaxes válido não existe estado gráfico persistente a ler.
            if isempty(app.UIAxes) || ~isvalid(app.UIAxes)
                return
            end

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
        % Popup helpers
        %-----------------------------------------------------------------%
        function value = popupNumericValue(~, rawValue)
            % Normaliza identificadores numéricos opcionais para o HTML do popup.

            % Esse helper atende principalmente renderPopupStationHTML, onde os
            % data-attributes do botão precisam receber sempre um valor escalar,
            % mesmo quando equipment_id ou host_id vierem vazios do backend.
            if isempty(rawValue)
                value = -1;
                return
            end

            % Alguns campos chegam encapsulados em célula; aqui a função reduz o
            % valor para a primeira carga útil antes da conversão final.
            if iscell(rawValue)
                rawValue = rawValue{1};
            end

            % Mantém -1 como sentinela quando o campo continuar vazio após o
            % desempacotamento, evitando atributos HTML vazios ou inválidos.
            if isempty(rawValue)
                value = -1;
                return
            end

            % A saída final é sempre numérica para ser embutida diretamente no
            % markup gerado pelo popup.
            value = double(rawValue);
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

        
        function [txt, color] = stationStatus(app, st)
            % Traduz o estado interno da estação para rótulo e cor do popup.

            % Esse mapeamento alimenta diretamente renderPopupStationHTML e
            % estimatePopupStationHeight, então texto e cor precisam seguir a
            % mesma convenção usada no restante do fluxo visual.
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
                    % Estados sem host conhecido ou fora do mapeamento caem neste
                    % tratamento neutro para não quebrar a renderização.
                    txt = "Sem host";
                    color = "#7b8aa0";
            end
        end

        function out = esc(app, value)
            % Escapa o subconjunto mínimo de caracteres sensíveis no HTML do popup.

            % Esse helper é chamado durante a montagem textual do popup para
            % impedir que nomes, municípios e demais campos livres quebrem o
            % markup final injetado em popupHTML.
            out = string(value);
            out = replace(out, "&", "&amp;");
            out = replace(out, "<", "&lt;");
            out = replace(out, ">", "&gt;");
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

            if isempty(app.dbHandler)
                app.dbHandler = util.DBHandler();
            end

            % Limpa o cache de localidades e zera os filtros que dependem da
            % seleção corrente antes de reconstruir as opções da interface.
            app.filesLocalityRows        = table();
            app.filesStartDatePicker.Value = NaT;
            app.filesEndDatePicker.Value   = NaT;
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
            stateCode = selectedStateFilter(app);
            if stateCode ~= "Todos os estados"
                eqFilters.stateCode = char(stateCode);
            end
            eqDistrictId = str2double(string(app.filesLocationDropDown.Value));
            if ~isnan(eqDistrictId)
                eqFilters.districtId = eqDistrictId;
            end

            rows = app.dbHandler.getSpectrumEquipments(eqFilters);

            % Mantém uma opção neutra no topo para representar ausência de
            % seleção explícita no dropdown.
            items     = {'Selecione uma estação/equipamento'};
            itemsData = {''};

            % Guarda o valor atual para tentar restaurá-lo depois da reconstrução
            % da lista.
            selectedValue = string(app.filesStationDropDown.Value);

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
            app.filesStationDropDown.Items     = items;
            app.filesStationDropDown.ItemsData = itemsData;

                % Se a seleção anterior ainda existir, restaura; caso contrário,
                % volta para o estado neutro da busca.
            if any(strcmp(itemsData, char(selectedValue)))
                app.filesStationDropDown.Value = char(selectedValue);
            else
                app.filesStationDropDown.Value = '';
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
            equipmentId = str2double(string(app.filesStationDropDown.Value));
            items = {'Todas as localidades'};
            itemsData = {''};

            % Mantém em memória as linhas retornadas pela consulta para uso posterior
            % em outras rotinas, como atualização de período.
            app.filesLocalityRows = table();

            % Constrói filtros a partir das seleções ativas de estado e equipamento.
            locFilters = struct();
            locStateCode = selectedStateFilter(app);
            if locStateCode ~= "Todos os estados"
                locFilters.stateCode = char(locStateCode);
            end

            % Sempre consulta o banco: sem filtros ativos retorna todas as
            % localidades disponíveis, permitindo que o usuário desfaça filtros
            % sem colapsar a lista para apenas a opção neutra.
            app.filesLocalityRows = app.dbHandler.getSpectrumLocalities(equipmentId, locFilters);

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
            app.filesLocationDropDown.Items = items;
            app.filesLocationDropDown.ItemsData = itemsData;

            % Tenta selecionar a localidade preferencial, quando ela ainda existir
            % na lista recém-carregada; caso contrário, volta para a opção geral.
            preferredDistrictId = formatNumericId(app, preferredDistrictId);
            if strlength(preferredDistrictId) > 0 && any(strcmp(itemsData, char(preferredDistrictId)))
                app.filesLocationDropDown.Value = char(preferredDistrictId);
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

            selectedDistrictId = str2double(string(app.filesLocationDropDown.Value));
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
                app.filesStartDatePicker.Value = startDate;
            end

            if ~isnat(endDate)
                app.filesEndDatePicker.Value = endDate;
            end
        end

        
        %-----------------------------------------------------------------%
        % Manipulação do DockRepoFiles
        %-----------------------------------------------------------------%
        function dockContext = buildFilesDockContext(app)
            % Builds the context payload passed to the files dock on open.
            %
            % Reads current search controls and normalizes invalid or negative
            % frequency values to NaN (meaning "no filter"). The dock always
            % runs a spectrum-aware query returning one row per repository file;
            % there is no longer a mode switch in this payload.

            freqStart   = NaN;
            freqEnd     = NaN;
            description = '';

            [startDate, endDate] = getNormalizedFilterDateRange(app);

            % Passa o estado (UF) selecionado para que o dock possa pesquisar
            % por estado mesmo quando nenhum equipamento estiver escolhido.
            stateCodeCtx = char(selectedStateFilter(app));
            if strcmp(stateCodeCtx, 'Todos os estados')
                stateCodeCtx = '';
            end

            dockContext = struct( ...
                'equipmentId', str2double(string(app.filesStationDropDown.Value)), ...
                'districtId',  str2double(string(app.filesLocationDropDown.Value)), ...
                'stateCode',   stateCodeCtx, ...
                'hostId',      [], ...                'startDate',   startDate, ...
                'endDate',     endDate, ...
                'freqStart',   freqStart, ...
                'freqEnd',     freqEnd, ...
                'description', description ...
                );
        end

        
        function openRepoFilesDock(app, dockContext)
            % Encaminha a abertura do dock de arquivos no padrão do appAnalise.

            % Esse helper centraliza a chamada usada tanto pela pesquisa da aba
            % Arquivos quanto pelos botões do popup, para que winRepoSFI sempre
            % entregue ao dock RepoFiles o mesmo contexto de origem.

            % dockContext carrega os filtros e identificadores já resolvidos no
            % fluxo atual, como site, equipamento, host e demais recortes de busca.
            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RepoFiles', app.Context, dockContext)
        end

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
            if ~isempty(app.filesCountLabel)
                app.filesCountLabel.Text = sprintf('%d localidade(s) visíveis', numel(app.filteredRepoSFI.points));
            end
        end

        
        function filteredData = getAppliedFilter(app)
            % Aplica os filtros ativos da interface e devolve o dataset filtrado.
            %
            % A saída é a fonte única de verdade consumida pelo plot do mapa,
            % popup e seleção de localidades.

            % Começa com a estrutura vazia padrão para garantir um contrato
            % estável mesmo quando o dataset base ainda não estiver disponível.
            filteredData = struct('points', struct([]), 'site_details', struct([]));

            % Sem o payload principal do RepoSFI não existe base para qualquer
            % filtragem, então o fallback vazio é mantido.
            if isempty(app.repoSFI) || ~isstruct(app.repoSFI) || ~isfield(app.repoSFI, 'points') || ~isfield(app.repoSFI, 'site_details')
                return
            end

            basePoints = app.repoSFI.points;
            baseSiteDetails = app.repoSFI.site_details;

            % Se não houver pontos carregados, também não há recorte a compor.
            if isempty(basePoints)
                return
            end

            % Prepara coleções vazias tipadas a partir do dataset original para
            % reconstruir apenas os sites que sobreviverem aos filtros ativos.
            filteredPoints = basePoints([]);
            filteredSiteDetails = baseSiteDetails([]);

            % Inicializa os filtros com os estados neutros da interface.
            stateFilter    = "Todos os estados";
            statusFilter   = "Todos";
            localityFilter = "Todas";
            equipmentFilter = NaN;

            % Lê o estado atual dos controles quando eles já estiverem disponíveis.
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
                equipmentFilter = str2double(string(app.filesStationDropDown.Value));
            end

            % Distrito selecionado: quando preenchido, restringe o mapa apenas
            % aos sites cujo district_id bata com o valor escolhido.
            districtFilter = NaN;
            if ~isempty(app.filesLocationDropDown)
                districtFilter = str2double(string(app.filesLocationDropDown.Value));
            end

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
                if stateFilter ~= "Todos os estados"
                    pointStateCode = normalizeTextFromValue(app, filteredPoint.state_code);
                    if strlength(pointStateCode) == 0 || pointStateCode ~= stateFilter
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
            filteredData.site_details = filteredSiteDetails;
        end

        

        
        function [startDate, endDate] = getNormalizedFilterDateRange(app)
            % Normaliza o intervalo selecionado para evitar janelas invertidas.

            % Esse helper é usado por getAppliedFilter e pelos callbacks de data
            % para manter um contrato consistente entre os date pickers e as
            % rotinas que avaliam vigência das estações.
            startDate = normalizeToDatetime(app, app.filesStartDatePicker.Value);
            endDate = normalizeToDatetime(app, app.filesEndDatePicker.Value);

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
                app.filesEndDatePicker.Value = endDate;
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

        function releaseDbHandler(app)
            % Fecha as conexoes abertas pelo DBHandler antes de destruir o dock.
            if isempty(app.dbHandler)
                return
            end

            try
                app.dbHandler = app.dbHandler.closeConnections();
            catch
            end

            app.dbHandler = [];
        end

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
            prevEquipId = string(app.filesStationDropDown.Value);
            prevSiteId  = string(app.filesLocationDropDown.Value);

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
                stateFilter    = selectedStateFilter(app);
                statusFilter   = string(app.filesStatusDropDown.Value);
                localityFilter = string(app.filesLocalityDropDown.Value);

                basePoints      = app.repoSFI.points;
                baseSiteDetails = app.repoSFI.site_details;

                for ii = 1:numel(basePoints)
                    point = basePoints(ii);

                    % Filtro de estado: descarta pontos fora da UF selecionada.
                    if stateFilter ~= "Todos os estados"
                        if normalizeTextFromValue(app, point.state_code) ~= stateFilter
                            continue
                        end
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
            app.filesStationDropDown.Items     = equipItems;
            app.filesStationDropDown.ItemsData = equipData;
            if any(strcmp(equipData, char(prevEquipId)))
                app.filesStationDropDown.Value = char(prevEquipId);
            else
                app.filesStationDropDown.Value = '';
            end

            % Publica as localidades, restaurando a seleção anterior quando válida.
            app.filesLocationDropDown.Items     = siteItems;
            app.filesLocationDropDown.ItemsData = siteData;
            if strlength(prevSiteId) > 0 && any(strcmp(siteData, char(prevSiteId)))
                app.filesLocationDropDown.Value = char(prevSiteId);
            else
                app.filesLocationDropDown.Value = '';
            end

            % Limpa o cache de localidades do BD para evitar inconsistências
            % com os dados derivados em memória.
            app.filesLocalityRows = table();

            % Atualiza o período a partir das datas coletadas das estações filtradas.
            app.filesStartDatePicker.Value = NaT;
            app.filesEndDatePicker.Value   = NaT;
            validDates = allDates(~isnat(allDates));
            if ~isempty(validDates)
                app.filesStartDatePicker.Value = min(validDates);
                app.filesEndDatePicker.Value   = max(validDates);
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
                stateVal   = char(filters.stateCode);
                targetState = stateVal;
                if isempty(stateVal)
                    targetState = 'Todos os estados';
                end
                if ~strcmp(char(string(app.filesStateDropDown.Value)), targetState)
                    if isempty(stateVal) || any(strcmp(app.filesStateDropDown.Items, stateVal))
                        app.filesStateDropDown.Value = targetState;
                        stateChanged = true;
                    end
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
                    if any(strcmp(app.filesStationDropDown.ItemsData, ''))
                        app.filesStationDropDown.Value = '';
                    end
                else
                    equipId = char(string(round(filters.equipmentId)));
                    if any(strcmp(app.filesStationDropDown.ItemsData, equipId))
                        app.filesStationDropDown.Value = equipId;
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
                        if any(strcmp(app.filesLocationDropDown.ItemsData, ''))
                            app.filesLocationDropDown.Value = '';
                        end
                    else
                        distId = char(string(round(filters.districtId)));
                        if any(strcmp(app.filesLocationDropDown.ItemsData, distId))
                            app.filesLocationDropDown.Value = distId;
                        end
                    end
                end
            end

            % Datas ------------------------------------------------------
            % Definidas após updateFilesLocationOptions para sobrescrever
            % qualquer reset de período feito por updateFilesAvailablePeriod.
            if isfield(filters, 'startDate') && isdatetime(filters.startDate) && ~isnat(filters.startDate)
                app.filesStartDatePicker.Value = filters.startDate;
            end
            if isfield(filters, 'endDate') && isdatetime(filters.endDate) && ~isnat(filters.endDate)
                app.filesEndDatePicker.Value = filters.endDate;
            end

            % Atualiza o mapa com os filtros recém-sincronizados.
            refreshFilteredMap(app, "preserve_if_all_states")
        
    
    end

    function notifyDockFiltersChanged(app)
            % Propaga os filtros atuais do winRepoSFI para o dockRepoFiles aberto.
            %
            % Chamado pelos callbacks de mudança de filtro para manter os seletores
            % do dock sincronizados com o estado corrente do mapa. Análogo ao
            % sentido inverso já implementado em notifyCallingAppFiltersChanged.
            if isempty(app.repoFilesDock) || ~isvalid(app.repoFilesDock)
                return
            end
            if ~ismethod(app.repoFilesDock, 'ipcSecondaryMatlabCallsHandler')
                return
            end

            stateVal = char(app.filesStateDropDown.Value);
            if strcmp(stateVal, 'Todos os estados')
                stateVal = '';
            end

            filters = struct( ...
                'stateCode',   stateVal, ...
                'equipmentId', str2double(string(app.filesStationDropDown.Value)), ...
                'districtId',  str2double(string(app.filesLocationDropDown.Value)), ...
                'startDate',   app.filesStartDatePicker.Value, ...
                'endDate',     app.filesEndDatePicker.Value ...
            );

            try
                app.repoFilesDock.ipcSecondaryMatlabCallsHandler(app, 'onRepoSFIFilterChanged', filters);
            catch
            end
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
            
            releaseDbHandler(app)
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

        % Image clicked function: tool_PanelVisibility
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
            end

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
                % Estado mudou: usa consulta ao BD para listas precisas de espectro.
                viewportMode = "fit";
                loadFilesStationOptions(app)
                updateFilesLocationOptions(app, NaN)
                notifyDockFiltersChanged(app)
            else
                % Status ou tipo de localidade mudou: filtra em memória pois essas
                % propriedades (map_state, is_current_location) não estão no BD.
                refreshDependentDropdowns(app)
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
                    applyMapViewport(app, struct(), "fit")

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
             % Tenta preservar a localidade atualmente selecionada: ela pode
            % continuar válida para a nova estação. updateFilesLocationOptions
            % descartará silenciosamente se não fizer parte da nova lista.
            currentDistrict = app.filesLocationDropDown.Value;
            updateFilesLocationOptions(app, currentDistrict)

            % O mapa também usa filesStationDropDown como filtro, então a troca
            % do equipamento precisa refletir imediatamente nos pontos visíveis.
            refreshFilteredMap(app, "fit");
            notifyDockFiltersChanged(app)


        end

        % Value changed function: configMapStyleDropDown
        function onMapStyleChanged(app, event)
            applySelectedMapStyle(app);

        end

        % Value changed function: filesLocationDropDown
        function onLocationChanged(app, event)
           % Localidade mudou: recarrega estações que passaram por esse local.
            loadFilesStationOptions(app)
            updateFilesAvailablePeriod(app);
            refreshFilteredMap(app, "preserve_if_all_states");
            notifyDockFiltersChanged(app)
        end

        % Value changed function: filesEndDatePicker, filesStartDatePicker
        function onDateChanged(app, event)
           % Reaplica o filtro após consolidar um intervalo temporal válido.
            getNormalizedFilterDateRange(app);
            refreshFilteredMap(app, "preserve_if_all_states")
            notifyDockFiltersChanged(app)
            
        end

        % Button pushed function: filesCleanButton
        function onCleanClick(app, event)
             % Restaura os filtros da aba Arquivos ao estado inicial da tela.
            app.filesStateDropDown.Value = 'Todos os estados';
            app.filesStatusDropDown.Value = 'Todos';
            app.filesLocalityDropDown.Value = 'Todas';

            %app.filesDescriptionEditField.Value = '';
            app.filesStartDatePicker.Value = NaT;
            app.filesEndDatePicker.Value = NaT;

            loadFilesStationOptions(app)
            app.filesStationDropDown.Value = '';
            updateFilesLocationOptions(app, NaN)

            closePopup(app)
            refreshFilteredMap(app, "fit")
            notifyDockFiltersChanged(app)
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
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 5, 22, '1x', 18};
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

            % Create filesCountLabel
            app.filesCountLabel = uilabel(app.Toolbar);
            app.filesCountLabel.HorizontalAlignment = 'right';
            app.filesCountLabel.FontSize = 11;
            app.filesCountLabel.Layout.Row = [1 3];
            app.filesCountLabel.Layout.Column = [7 8];
            app.filesCountLabel.Text = '0 localidade(s) visíveis';

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
            app.SubTabGroup = uipanel(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = 2;

            % Create FilesMainGrid
            app.FilesMainGrid = uigridlayout(app.SubTabGroup);
            app.FilesMainGrid.ColumnWidth = {49, 49, '1x'};
            app.FilesMainGrid.RowHeight = {48, 22, 125, 22, 35, 22, 71, 6, 49};
            app.FilesMainGrid.RowSpacing = 5;
            app.FilesMainGrid.BackgroundColor = [1 1 1];

            % Create filesPeriodLabel
            app.filesPeriodLabel = uilabel(app.FilesMainGrid);
            app.filesPeriodLabel.FontSize = 10;
            app.filesPeriodLabel.Layout.Row = 6;
            app.filesPeriodLabel.Layout.Column = [1 3];
            app.filesPeriodLabel.Text = 'PERÍODO ';

            % Create filesStationFilterPanel
            app.filesStationFilterPanel = uipanel(app.FilesMainGrid);
            app.filesStationFilterPanel.BackgroundColor = [1 1 1];
            app.filesStationFilterPanel.Layout.Row = 3;
            app.filesStationFilterPanel.Layout.Column = [1 3];
            app.filesStationFilterPanel.FontSize = 11;

            % Create filesStationsGrid
            app.filesStationsGrid = uigridlayout(app.filesStationFilterPanel);
            app.filesStationsGrid.ColumnWidth = {110, '1x'};
            app.filesStationsGrid.RowHeight = {22, 22, 22, 22};
            app.filesStationsGrid.RowSpacing = 5;
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
            app.filesStatusLabel.Layout.Row = 3;
            app.filesStatusLabel.Layout.Column = 1;
            app.filesStatusLabel.Text = 'Status';

            % Create filesLocalityLabel
            app.filesLocalityLabel = uilabel(app.filesStationsGrid);
            app.filesLocalityLabel.FontSize = 11;
            app.filesLocalityLabel.Layout.Row = 4;
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
            app.filesStatusDropDown.Layout.Row = 3;
            app.filesStatusDropDown.Layout.Column = 2;
            app.filesStatusDropDown.Value = 'Todos';

            % Create filesLocalityDropDown
            app.filesLocalityDropDown = uidropdown(app.filesStationsGrid);
            app.filesLocalityDropDown.Items = {'Todas', 'Apenas atuais', 'Apenas históricas'};
            app.filesLocalityDropDown.ValueChangedFcn = createCallbackFcn(app, @onStationFilterChanged, true);
            app.filesLocalityDropDown.FontSize = 10.5;
            app.filesLocalityDropDown.BackgroundColor = [1 1 1];
            app.filesLocalityDropDown.Layout.Row = 4;
            app.filesLocalityDropDown.Layout.Column = 2;
            app.filesLocalityDropDown.Value = 'Todas';

            % Create filesLocationLabel
            app.filesLocationLabel = uilabel(app.filesStationsGrid);
            app.filesLocationLabel.FontSize = 11;
            app.filesLocationLabel.Layout.Row = 2;
            app.filesLocationLabel.Layout.Column = 1;
            app.filesLocationLabel.Text = 'Distrito';

            % Create filesLocationDropDown
            app.filesLocationDropDown = uidropdown(app.filesStationsGrid);
            app.filesLocationDropDown.Items = {'Todas as localidades'};
            app.filesLocationDropDown.ValueChangedFcn = createCallbackFcn(app, @onLocationChanged, true);
            app.filesLocationDropDown.FontSize = 10.5;
            app.filesLocationDropDown.BackgroundColor = [1 1 1];
            app.filesLocationDropDown.Layout.Row = 2;
            app.filesLocationDropDown.Layout.Column = 2;
            app.filesLocationDropDown.Value = 'Todas as localidades';

            % Create filesLocationSelectLabel
            app.filesLocationSelectLabel = uilabel(app.FilesMainGrid);
            app.filesLocationSelectLabel.FontSize = 10;
            app.filesLocationSelectLabel.Layout.Row = 2;
            app.filesLocationSelectLabel.Layout.Column = [1 3];
            app.filesLocationSelectLabel.Text = 'LOCALIDADE/HISTÓRICO';

            % Create filesPeriodPanel
            app.filesPeriodPanel = uipanel(app.FilesMainGrid);
            app.filesPeriodPanel.BackgroundColor = [1 1 1];
            app.filesPeriodPanel.Layout.Row = 7;
            app.filesPeriodPanel.Layout.Column = [1 3];

            % Create filesPeriodGrid
            app.filesPeriodGrid = uigridlayout(app.filesPeriodPanel);
            app.filesPeriodGrid.ColumnWidth = {110, '1x'};
            app.filesPeriodGrid.RowHeight = {22, 22};
            app.filesPeriodGrid.RowSpacing = 5;
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

            % Create filesSensorLocationLabel
            app.filesSensorLocationLabel = uipanel(app.FilesMainGrid);
            app.filesSensorLocationLabel.BackgroundColor = [1 1 1];
            app.filesSensorLocationLabel.Layout.Row = 5;
            app.filesSensorLocationLabel.Layout.Column = [1 3];
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
            app.filesStationLabel.FontSize = 10;
            app.filesStationLabel.Layout.Row = 4;
            app.filesStationLabel.Layout.Column = [1 3];
            app.filesStationLabel.Text = 'ESTAÇÃO';

            % Create referenceRX_Icon_3
            app.referenceRX_Icon_3 = uiimage(app.FilesMainGrid);
            app.referenceRX_Icon_3.ScaleMethod = 'none';
            app.referenceRX_Icon_3.Layout.Row = 1;
            app.referenceRX_Icon_3.Layout.Column = 1;
            app.referenceRX_Icon_3.ImageSource = 'addFiles_32.png';

            % Create referenceRX_Label_3
            app.referenceRX_Label_3 = uilabel(app.FilesMainGrid);
            app.referenceRX_Label_3.FontSize = 11;
            app.referenceRX_Label_3.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_Label_3.Layout.Row = 1;
            app.referenceRX_Label_3.Layout.Column = [2 3];
            app.referenceRX_Label_3.Interpreter = 'html';
            app.referenceRX_Label_3.Text = {'<b>Pesquisa de Arquivos</b>'; '<font style="font-size: 9px; color: gray;">(Dentro do repoSFI)</font>'};

            % Create filesSearchButton
            app.filesSearchButton = uibutton(app.FilesMainGrid, 'push');
            app.filesSearchButton.ButtonPushedFcn = createCallbackFcn(app, @onSearchClick, true);
            app.filesSearchButton.Icon = 'icon_search.svg';
            app.filesSearchButton.IconAlignment = 'top';
            app.filesSearchButton.VerticalAlignment = 'bottom';
            app.filesSearchButton.FontSize = 11;
            app.filesSearchButton.Layout.Row = 9;
            app.filesSearchButton.Layout.Column = 1;
            app.filesSearchButton.Text = 'Buscar';

            % Create filesCleanButton
            app.filesCleanButton = uibutton(app.FilesMainGrid, 'push');
            app.filesCleanButton.ButtonPushedFcn = createCallbackFcn(app, @onCleanClick, true);
            app.filesCleanButton.Icon = 'icon_clean.svg';
            app.filesCleanButton.IconAlignment = 'top';
            app.filesCleanButton.VerticalAlignment = 'bottom';
            app.filesCleanButton.FontSize = 11;
            app.filesCleanButton.Layout.Row = 9;
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
