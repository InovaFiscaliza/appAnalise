classdef winRepoSFI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        DockModule              matlab.ui.container.GridLayout
        dockModule_Close        matlab.ui.control.Image
        dockModule_Undock       matlab.ui.control.Image
        AxesToolbar             matlab.ui.container.GridLayout
        axesTool_Basemap        matlab.ui.control.DropDown
        axesTool_RegionZoom     matlab.ui.control.Image
        axesTool_RestoreView    matlab.ui.control.Image
        AxesPopup               matlab.ui.control.Label
        AxesContainer           matlab.ui.container.Panel
        LeftPanel               matlab.ui.container.Panel
        LeftPanelGrid           matlab.ui.container.GridLayout
        CacheUpdatedAt          matlab.ui.control.Label
        CacheUpdatedAtIcon      matlab.ui.control.Image
        ReceiverPanel           matlab.ui.container.Panel
        ReceiverGrid            matlab.ui.container.GridLayout
        ReceiverPosition        matlab.ui.control.DropDown
        ReceiverPositionLabel   matlab.ui.control.Label
        ReceiverStatus          matlab.ui.control.DropDown
        ReceiverStatusLabel     matlab.ui.control.Label
        Receiver                matlab.ui.control.DropDown
        ReceiverLabel           matlab.ui.control.Label
        Location                matlab.ui.control.DropDown
        LocationLabel           matlab.ui.control.Label
        State                   matlab.ui.control.DropDown
        StateLabel              matlab.ui.control.Label
        ModuleIntro             matlab.ui.control.Label
        ModuleIcon              matlab.ui.control.Image
        Toolbar                 matlab.ui.container.GridLayout
        tool_FilterSummaryIcon  matlab.ui.control.Image
        tool_FilterSummary      matlab.ui.control.Label
        tool_LayoutLeft         matlab.ui.control.Image
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
        UIAxesLimits = struct('LatitudeLimits', [-90, 90], 'LongitudeLimits', [-180, 180])
        
        dbHandlerObj
        dbCacheData        
        dbReference
        dbReferenceSummary
        dbMatchMask
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        SITE_COLOR = struct( ...
            'CURRENT_ONLINE',   [0.3098 0.4980 0.4039], ...4
            'CURRENT_OFFLINE',  [0.7216 0.5137 0.3216], ...3
            'PREVIOUS_ONLINE',  [0.6549 0.7451 0.6706], ...2
            'PREVIOUS_OFFLINE', [0.8627 0.7647 0.6784], ...1
            'UNKNOWN_HOST',     [0.4824 0.5412 0.6275], ...5
            'OVERLAY',          [0.2200 0.2200 0.2200] ...
        )
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'onRepoFileSearchRequested'
                        idxs = jsondecode(event.HTMLEventData);
                        point = app.AxesPopup.UserData.siteDetails(idxs(1)).point;
                        filterContext = struct( ...
                            'state',    point.state_code, ...
                            'location', point.state_name + "/" + point.state_code, ...
                            'receiver', point.stations(idxs(2)).host_name ...
                        );
                        ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RepoSFI', app.Context, filterContext)

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
                            case 'onRepoSFIFilterChanged'
                                applyInitialLayout(app)

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
                app.State;
                app.AxesToolbar;
                app.AxesPopup;
                app.tool_LayoutLeft;
                app.dockModule_Undock;
                app.dockModule_Close
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.State.UserData.id, 'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')), ...
                    struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                    struct('appName', appName, 'dataTag', app.AxesPopup.UserData.id, 'style', struct('pointerEvents', 'none')), ...
                    struct('appName', appName, 'dataTag', app.AxesPopup.UserData.id, 'selector', '.mwAlignmentNode', 'style', struct('height', '100%')), ...
                    struct('appName', appName, 'dataTag', app.tool_LayoutLeft.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Alterna visibilidade do painel')), ... 
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
            app.dbCacheData = app.dbHandlerObj.CacheData;

            % Cria tabela de referência, que pode vir a ser entregue diretamente
            % pelo banco, ordenando-a por "Location". Posteriormente, ordena-se
            % o conteúdo dos campos "points" e "siteDetails" de app.dbCacheData.
            dbFilteredData = app.dbCacheData.points;
            app.dbReference = table( ...
                [dbFilteredData.site_id]', ...
                [dbFilteredData.district_id]', ...
                [dbFilteredData.state_code]', ...
                [dbFilteredData.county_name]' + "/" + [dbFilteredData.state_code]', ...
                [dbFilteredData.district_name]', ...
                {dbFilteredData.station_names}', ...
                {dbFilteredData.stations}', ...
                'VariableNames', {'SiteId', 'DistrictId', 'StateCode', 'Location', 'District', 'StationNames', 'StationDetails'} ...
            );
            [app.dbReference, sortIdxs] = sortrows(app.dbReference, 'Location');

            app.dbReferenceSummary = struct( ...
                'NumGlobalLocation', numel(unique(app.dbReference.Location)), ...
                'NumGlobalDistrict', numel(unique(app.dbReference.District)), ...
                'NumGlobalReceiver', numel(unique(vertcat(app.dbReference.StationNames{:}))) ...
            );

            app.dbCacheData.points = app.dbCacheData.points(sortIdxs);
            app.dbCacheData.siteDetails = app.dbCacheData.siteDetails(sortIdxs);
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

            app.State.Items = [{''}, unique([app.dbCacheData.points.state_code])];
            cacheUpdatedAt = strsplit(app.dbHandlerObj.CacheUpdatedAt, ' ');
            app.CacheUpdatedAt.Text = sprintf('%s às %s', cacheUpdatedAt{2}, cacheUpdatedAt{1});
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            matchMask = applyFilter(app);
            dbFilteredReference = app.dbReference(matchMask, :);

            refreshLocationDropDown(app, dbFilteredReference)
            refreshReceiverDropDown(app, dbFilteredReference)
            refreshPlots(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 1, 1, "Padding", "none", "TileSpacing", "none", "Position", [0, 0, 1, 1]);

            app.UIAxes = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.axesTool_Basemap.Value, ...
                                                                    'Color', [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                    'UserData', struct('CLimMode', 'auto', 'Colormap', '', 'Render', false)});
        
            set(app.UIAxes.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            
            geolimits(app.UIAxes, 'auto')
            plot.axes.Colormap(app.UIAxes, 'turbo')

            if ismember(app.axesTool_Basemap.Value, {'darkwater', 'none'})
                app.UIAxes.Grid = 'on';
            end
        end

        %-----------------------------------------------------------------%
        function matchMask = applyFilter(app)
            % app.dbReference é uma tabela com as colunas "DistrictId", "StateCode", 
            % "Location", "StationNames" e "StationDetails".
            matchMask = true(height(app.dbReference), 1);

            % Filtragem "UF"
            stateCode = app.State.Value;
            if ~isempty(stateCode)
                matchMask = matchMask & app.dbReference.StateCode == string(stateCode);
            end

            % Filtragem "Localidade"
            location = app.Location.Value;
            if ~isempty(location)
                matchMask = matchMask & app.dbReference.Location == string(location);
            end

            % Filtragem "Sensor"
            receiver = app.Receiver.Value;
            if ~isempty(receiver)
                matchMask = matchMask & cellfun(@(x) any(contains(x, string(receiver))), app.dbReference.StationNames);
            end

            app.dbMatchMask = matchMask;
        end

        %-----------------------------------------------------------------%
        function refreshLocationDropDown(app, dbFilteredReference)
            previousValue = app.Location.Value;
            app.Location.Items = [{''}, cellstr(unique(dbFilteredReference.Location))'];

            if ~isempty(previousValue) && ismember(previousValue, app.Location.Items) && ~isequal(previousValue, app.Location.Value)
                app.Location.Value = previousValue;
            end
        end

        %-----------------------------------------------------------------%
        function refreshReceiverDropDown(app, dbFilteredReference)
            previousValue = app.Receiver.Value;
            app.Receiver.Items = [{''}, cellstr(unique(vertcat(dbFilteredReference.StationNames{:})))'];

            if ~isempty(previousValue) && ismember(previousValue, app.Receiver.Items) && ~isequal(previousValue, app.Receiver.Value)
                app.Receiver.Value = previousValue;
            end
        end

        %-----------------------------------------------------------------%
        function refreshPlots(app)
            if ~app.UIAxes.UserData.Render
                timerObj = timer( ...
                    "ExecutionMode", "singleShot", ...
                    "StartDelay", 0.500, ...
                    "TimerFcn", @(src, ~)app.waitForDOMReady(src) ...
                );

                start(timerObj)
                return
            end

            % MATLAB tem um BUG que impede a interação do mouse com o eixo, 
            % caso habilitado ButtonDownFcn em algum dos seus filhos. O arranjo 
            % abaixo, desativando temporariamente a interação do eixo, resolve.
            if ~isempty(app.UIAxes.Children)
                cla(app.UIAxes)
                app.UIAxes.Interactions = [];
                disableDefaultInteractivity(app.UIAxes)
            end

            if app.AxesPopup.Visible
                app.AxesPopup.Visible = "off";
            end

            matchMask = app.dbMatchMask;
            dbFilteredPoints = app.dbCacheData.points(matchMask);
            dbFilteredReference = app.dbReference(matchMask, :);
            
            refreshPlotSites(app, dbFilteredPoints, dbFilteredReference)
            refreshPlotFootnote(app)
            drawnow

            % Por fim, reativa interação do mouse.
            if isempty(app.UIAxes.Interactions)
                app.UIAxes.Interactions = [zoomInteraction, panInteraction, dataTipInteraction];
                enableDefaultInteractivity(app.UIAxes)
            end
            set(findStationHandles(app), 'ButtonDownFcn', @app.clickPlotElement)
        end

        %-----------------------------------------------------------------%
        function waitForDOMReady(app, timerObj)
            app.UIAxes.UserData.Render = true;
            refreshPlots(app)

            stop(timerObj)
            delete(timerObj)
        end

        %-----------------------------------------------------------------%
        function refreshPlotFootnote(app)
            matchMask = app.dbMatchMask;
            dbFilteredPoints    = app.dbCacheData.points(matchMask);
            dbFilteredReference = app.dbReference(matchMask, :);

            visibleMask = true(1, numel(dbFilteredPoints));
            if ~isempty(dbFilteredPoints)
                [showOnlineSite, showOfflineSite, showActiveSite, showHistoric] = getVisibilityFlags(app);

                markerStates = [dbFilteredPoints.marker_state];
                visibleMask  = false(size(markerStates));
                visibleMask(markerStates == "offline_previous") = showOfflineSite && showHistoric;
                visibleMask(markerStates == "online_previous")  = showOnlineSite  && showHistoric;
                visibleMask(markerStates == "offline_current")  = showOfflineSite && showActiveSite;
                visibleMask(markerStates == "online_current")   = showOnlineSite  && showActiveSite;
                visibleMask(markerStates == "no_host")          = true;

                dbFilteredReference = dbFilteredReference(visibleMask, :);
            end

            numLocation = numel(unique(dbFilteredReference.Location));
            numDistrict = numel(unique(dbFilteredReference.District));

            if numLocation == app.dbReferenceSummary.NumGlobalLocation
                location = sprintf('%d localidades', numLocation);
            else
                location = sprintf('%d de %d localidades', numLocation, app.dbReferenceSummary.NumGlobalLocation);
            end

            if numDistrict == app.dbReferenceSummary.NumGlobalDistrict
                district = sprintf('%d regiões      ', numDistrict);  
            else
                district = sprintf('%d de %d regiões      ', numDistrict, app.dbReferenceSummary.NumGlobalDistrict);
            end

            app.tool_FilterSummary.Text = [location newline district];

            if all(matchMask) && all(visibleMask)
                app.tool_FilterSummaryIcon.ImageSource = 'filter.svg';
            else
                app.tool_FilterSummaryIcon.ImageSource = 'filter-filled.svg';
            end
        end

        %-----------------------------------------------------------------%
        function refreshPlotSites(app, dbFilteredPoints, dbFilteredReference)
            if isempty(dbFilteredPoints)
                return
            end

            siteIds        = [dbFilteredPoints.site_id];
            siteStates     = [dbFilteredPoints.marker_state];
            siteLatitudes  = [dbFilteredPoints.latitude];
            siteLongitudes = [dbFilteredPoints.longitude];

            [showOnlineSite, showOfflineSite, showActiveSite, showHistoric] = getVisibilityFlags(app);

            plotGroup("offline_previous", 100, app.SITE_COLOR.PREVIOUS_ONLINE, showOfflineSite && showHistoric,   true, true);
            plotGroup("online_previous",   80, app.SITE_COLOR.PREVIOUS_ONLINE, showOnlineSite  && showHistoric,   true, true);
            plotGroup("offline_current",  100, app.SITE_COLOR.CURRENT_OFFLINE, showOfflineSite && showActiveSite, true, false);
            plotGroup("online_current",    80, app.SITE_COLOR.CURRENT_ONLINE,  showOnlineSite  && showActiveSite, true, false);
            plotGroup("no_host",          100, app.SITE_COLOR.UNKNOWN_HOST,    true,                              true, false);

            delta = max(0.01, max(range(siteLatitudes), range(siteLongitudes)) * 0.1);
            geolimits(app.UIAxes, [min(siteLatitudes)-delta, max(siteLatitudes)+delta], [min(siteLongitudes)-delta, max(siteLongitudes)+delta]);
            app.UIAxesLimits.LatitudeLimits  = app.UIAxes.LatitudeLimits;
            app.UIAxesLimits.LongitudeLimits = app.UIAxes.LongitudeLimits;

            function plotGroup(tag, markerSize, markerColor, isVisible, hasDataTipInteraction, isHistoric)
                groupMatchMask = siteStates == tag;
                if ~any(groupMatchMask)
                    return
                end

                groupSiteIds = siteIds(groupMatchMask);
                groupSiteLat = siteLatitudes(groupMatchMask);
                groupSiteLng = siteLongitudes(groupMatchMask);

                plotHandle = geoscatter(app.UIAxes, groupSiteLat, groupSiteLng, markerSize, markerColor, 'filled', 'Marker', 'o', 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1, 'Tag', tag, 'Visible', isVisible);
                plotHandle.UserData = struct('ids', groupSiteIds, 'latitudes', groupSiteLat, 'longitudes', groupSiteLng);

                if hasDataTipInteraction
                    try
                        plot.datatip.Template(plotHandle, 'RepoSFI.Location', dbFilteredReference(groupMatchMask, {'Location', 'District'}))
                    catch
                        plot.datatip.Template(plotHandle, 'Coordinates')
                    end
                end

                if isHistoric
                    geoscatter(app.UIAxes, groupSiteLat, groupSiteLng, markerSize, app.SITE_COLOR.OVERLAY, 'Marker', '.', 'LineWidth', 1, 'PickableParts', 'none', 'Tag', tag + "_overlay", 'Visible', isVisible);
                end
            end
        end

        %-----------------------------------------------------------------%
        function refreshPlotHighlight(app, siteGroupDetails)
            delete(findobj(app.UIAxes.Children, 'Tag', 'siteGroup'))

            if isempty(siteGroupDetails)
                return
            end

            siteStates     = arrayfun(@(x) x.point.marker_state, siteGroupDetails);
            siteLatitudes  = arrayfun(@(x) x.point.latitude,     siteGroupDetails);
            siteLongitudes = arrayfun(@(x) x.point.longitude,    siteGroupDetails);

            plotHighlightGroup("offline_previous", 165, app.SITE_COLOR.PREVIOUS_ONLINE);
            plotHighlightGroup("online_previous",  165, app.SITE_COLOR.PREVIOUS_ONLINE);
            plotHighlightGroup("offline_current",  165, app.SITE_COLOR.CURRENT_OFFLINE);
            plotHighlightGroup("online_current",   165, app.SITE_COLOR.CURRENT_ONLINE);
            plotHighlightGroup("no_host",          165, app.SITE_COLOR.UNKNOWN_HOST);

            function plotHighlightGroup(tag, markerSize, markerColor)
                groupMatchMask = siteStates == tag;
                if ~any(groupMatchMask)
                    return
                end

                groupSiteLat = siteLatitudes(groupMatchMask);
                groupSiteLng = siteLongitudes(groupMatchMask);
                geoscatter(app.UIAxes, groupSiteLat, groupSiteLng, markerSize, markerColor, 'filled', 'Marker', 'o', 'MarkerEdgeColor', [0, 0, 0], 'LineWidth', 2, 'PickableParts', 'none', 'Tag', 'siteGroup');
            end
        end

        %-----------------------------------------------------------------%
        function refreshPlotVisibility(app)
            [showOnlineSite, showOfflineSite, showActiveSite, showHistoric] = getVisibilityFlags(app);

            toggleGroupVisibility('offline_previous', showOfflineSite && showHistoric);
            toggleGroupVisibility('online_previous',  showOnlineSite  && showHistoric);
            toggleGroupVisibility('offline_current',  showOfflineSite && showActiveSite);
            toggleGroupVisibility('online_current',   showOnlineSite  && showActiveSite);

            function toggleGroupVisibility(tag, isVisible)
                h = findobj(app.UIAxes.Children, '-regexp', 'Tag', ['^' tag]);
                set(h, 'Visible', isVisible);
            end

            refreshPlotFootnote(app)
        end

        %-----------------------------------------------------------------%
        function h = findStationHandles(app)
            h = findobj(app.UIAxes.Children, '-regexp', 'Tag', '^(offline_previous|online_previous|offline_current|online_current|no_host)$');
        end

        %-----------------------------------------------------------------%
        function [showOnline, showOffline, showActive, showHistoric] = getVisibilityFlags(app)
            showOnline   = ismember(app.ReceiverStatus.Value,   {'', 'Online'});
            showOffline  = ismember(app.ReceiverStatus.Value,   {'', 'Offline'});
            showActive   = ismember(app.ReceiverPosition.Value, {'', 'Atual'});
            showHistoric = ismember(app.ReceiverPosition.Value, {'', 'Histórica'});
        end

        %-----------------------------------------------------------------%
        function clickPlotElement(app, src, event)
            matchMask = app.dbMatchMask;
            dbFilteredPoints = app.dbCacheData.points(matchMask);
            dbFilteredSiteDetails = app.dbCacheData.siteDetails(matchMask);

            if isprop(event, 'DataIndex') && ~isempty(event.DataIndex) && event.DataIndex >= 1 && event.DataIndex <= numel(src.UserData.ids)
                siteId  = src.UserData.ids(event.DataIndex);
                siteLat = src.UserData.latitudes(event.DataIndex);
                siteLng = src.UserData.longitudes(event.DataIndex);

            elseif isscalar(src.UserData.ids)
                siteId  = src.UserData.ids;
                siteLat = src.UserData.latitudes;
                siteLng = src.UserData.longitudes;

            else
                intersectionPoint = event.IntersectionPoint;
                siteLat = double(intersectionPoint(1));
                siteLng = double(intersectionPoint(2));

                [~, siteIdx] = min(distance(siteLat, siteLng, [dbFilteredPoints.latitude], [dbFilteredPoints.longitude]));
                siteId  = dbFilteredPoints(siteIdx).site_id;
            end

            if isempty(siteId)
                return
            end

            site = struct('id', siteId, 'lat', siteLat, 'lng', siteLng);
            siteGroup = resolveSiteSelection(app, dbFilteredPoints, site);
            siteGroupDetails = collectPopupSites(app, dbFilteredPoints, dbFilteredSiteDetails, siteGroup.siteIds);
            
            refreshPlotHighlight(app, siteGroupDetails);
            showPointPopup(app, siteGroupDetails);
        end

        %-----------------------------------------------------------------%
        function siteGroup = resolveSiteSelection(app, dbFilteredPoints, site)
            siteGroup = struct( ...
                'siteId', site.id, ...
                'siteIds', site.id, ...
                'isAmbiguous', false, ...
                'nearbyCount', 1, ...
                'zoomSpan', NaN ...
            );

            siteLatitudes  = [dbFilteredPoints.latitude];
            siteLongitudes = [dbFilteredPoints.longitude];

            % Calcula a distância aproximada de cada ponto ao local do clique.
            % A mesma correção angular é aplicada no eixo longitudinal.
            siteDistances  = distance(siteLatitudes, siteLongitudes, site.lat, site.lng);

            % Estima zoom
            latLimitsSpan  = abs(diff(app.UIAxes.LatitudeLimits));
            lngLimitsSpan  = abs(diff(app.UIAxes.LongitudeLimits)) * max(cosd(site.lat), 0.25);
            estimatedZoom  = max(latLimitsSpan, lngLimitsSpan);            

            % Define o raio de agrupamento conforme o nível de zoom atual.
            % Quanto mais aberto o mapa, maior a tolerância para agrupar sites próximos.
            selectionRadius = getAdaptiveSelectionRadius(app, estimatedZoom);
            nearbyIdx = find(siteDistances <= selectionRadius);

            % Se nenhum ponto caiu dentro do raio, ao menos mantém o mais próximo.
            if isempty(nearbyIdx)
                [~, nearbyIdx] = min(siteDistances);
            end

            % Ordena os candidatos do mais próximo para o mais distante.
            % O primeiro passa a ser o site principal da seleção.
            [~, sortIdx] = sort(siteDistances(nearbyIdx), 'ascend');
            nearbyIdx = nearbyIdx(sortIdx);

            % Materializa a seleção final em ordem de proximidade ao clique.
            siteGroup.siteIds = double([dbFilteredPoints(nearbyIdx).site_id]);
            siteGroup.siteId = siteGroup.siteIds(1);
            siteGroup.nearbyCount = numel(siteGroup.siteIds);
            siteGroup.zoomSpan = estimatedZoom;

            % Considera a seleção ambígua apenas quando há múltiplos sites e o
            % mapa está suficientemente aberto para justificar o agrupamento.
            siteGroup.isAmbiguous = siteGroup.nearbyCount > 1 && estimatedZoom >= 1.0;
        end


        %-----------------------------------------------------------
        % Helpers de Seleção do Mapa
        %-----------------------------------------------------------------%
        function selectionRadius = getAdaptiveSelectionRadius(~, zoomSpan)
            % Ajusta o raio de agrupamento conforme a zoom atual do mapa.
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

        %-----------------------------------------------------------------%
        % POPUP
        %-----------------------------------------------------------------%
        function hidePointPopup(app)
            delete(findobj(app.UIAxes.Children, 'Tag', 'siteGroup'))
            set(app.AxesPopup, 'Visible', 'off', 'Text', '')
            app.AxesPopup.UserData.siteDetails = [];
        end

        %-----------------------------------------------------------------%
        function showPointPopup(app, siteGroupDetails)
            if isempty(siteGroupDetails)
                hidePointPopup(app)
                return
            end

            % Verifica se o handle para o app continua ativo no workspace
            % base do MATLAB, possibilitando que clicks no ui.TextView sejam 
            % capturados corretamente.
            appHandleNameInBase = app.AppHandleNameInBase;
            if isempty(appHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', appHandleNameInBase, appHandleNameInBase, class(app), appHandleNameInBase))
                app.AppHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
            end

            [~, siteDetailsSortedIdxs] = sort(arrayfun(@(x) x.point.site_label, siteGroupDetails));
            siteGroupDetails = siteGroupDetails(siteDetailsSortedIdxs);

            if isequal(siteGroupDetails, app.AxesPopup.UserData.siteDetails)
                app.AxesPopup.Visible = 'on';
            else
                htmlContent = util.HtmlTextGenerator.receiverStationDetails(siteGroupDetails, app.AppHandleNameInBase, app.mainApp.General);
                set(app.AxesPopup, 'Visible', 'on', 'Text', htmlContent)
                app.AxesPopup.UserData.siteDetails = siteGroupDetails;

                pause(1)
                delete(findobj(app.UIAxes.Children, 'Type', 'datatip'))
            end
        end

        %-----------------------------------------------------------------%
        function siteGroupDetails = collectPopupSites(app, dbFilteredPoints, dbFilteredSiteDetails, siteIds)
            siteIds = unique(siteIds, 'stable');
            siteGroupDetails = struct('siteId', {}, 'point', {}, 'detail', {});

            [showOnlineSite, showOfflineSite, showActiveSite, showHistoric] = getVisibilityFlags(app);

            for siteId = siteIds
                pointIdx = find([dbFilteredPoints.site_id] == siteId, 1);
                detailIdx = find([dbFilteredSiteDetails.site_id] == siteId, 1);

                if isempty(pointIdx) || isempty(detailIdx)
                    continue
                end

                siteState = dbFilteredPoints(pointIdx).marker_state;
                switch siteState
                    case 'offline_previous'
                        isVisible = showOfflineSite && showHistoric;
                    case 'online_previous'
                        isVisible = showOnlineSite  && showHistoric;
                    case 'offline_current'
                        isVisible = showOfflineSite && showActiveSite;
                    case 'online_current'
                        isVisible = showOnlineSite  && showActiveSite;
                    otherwise % 'no_host'
                        isVisible = true;
                end

                if ~isVisible
                    continue
                end

                siteGroupDetails(end+1) = struct( ...
                    'siteId', siteId, ...
                    'point', dbFilteredPoints(pointIdx), ...
                    'detail', dbFilteredSiteDetails(detailIdx) ...
                );
            end
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

        % Value changed function: Location, Receiver, ReceiverPosition, 
        % ...and 2 other components
        function onFilterValueChanged(app, event)
            
            if isequal(event.Value, event.PreviousValue) || isempty(event.ValueIndex)
                event.Source.Value = event.PreviousValue;
                return
            end

            switch event.Source
                case app.State
                    app.Location.Value = '';
                    app.Receiver.Value = '';

                    matchMask = applyFilter(app);
                    dbFilteredReference = app.dbReference(matchMask, :);

                    refreshLocationDropDown(app, dbFilteredReference)
                    refreshReceiverDropDown(app, dbFilteredReference)

                case app.Location
                    app.Receiver.Value = '';
                    applyFilter(app);

                case app.Receiver
                    app.Location.Value = '';
                    applyFilter(app);

                case {app.ReceiverStatus, app.ReceiverPosition}
                    hidePointPopup(app)
                    refreshPlotVisibility(app)
                    return
            end

            refreshPlots(app)          
            
        end

        % Callback function: axesTool_Basemap, axesTool_RegionZoom, 
        % ...and 1 other component
        function onAxesToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    geolimits(app.UIAxes, app.UIAxesLimits.LatitudeLimits, app.UIAxesLimits.LongitudeLimits)

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes, app.axesTool_RegionZoom, findStationHandles(app))

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

        % Image clicked function: tool_LayoutLeft
        function onToolbarButtonClicked(app, event)

            if app.LeftPanel.Visible
                app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left-off.svg';
                app.LeftPanel.Visible = 'off';
                app.GridLayout.ColumnWidth(2:3) = {0, 0};
            else
                app.tool_LayoutLeft.ImageSource = 'layout-sidebar-left.svg';
                app.LeftPanel.Visible = 'on';
                app.GridLayout.ColumnWidth(2:3) = {232, 10};
            end

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
            app.Toolbar.ColumnWidth = {22, '1x', 320, 22};
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

            % Create tool_FilterSummary
            app.tool_FilterSummary = uilabel(app.Toolbar);
            app.tool_FilterSummary.HorizontalAlignment = 'right';
            app.tool_FilterSummary.FontSize = 10;
            app.tool_FilterSummary.Layout.Row = [1 3];
            app.tool_FilterSummary.Layout.Column = 3;
            app.tool_FilterSummary.Text = '';

            % Create tool_FilterSummaryIcon
            app.tool_FilterSummaryIcon = uiimage(app.Toolbar);
            app.tool_FilterSummaryIcon.ScaleMethod = 'none';
            app.tool_FilterSummaryIcon.Layout.Row = [1 3];
            app.tool_FilterSummaryIcon.Layout.Column = 4;
            app.tool_FilterSummaryIcon.ImageSource = 'filter.svg';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.AutoResizeChildren = 'off';
            app.LeftPanel.Layout.Row = [3 4];
            app.LeftPanel.Layout.Column = 2;

            % Create LeftPanelGrid
            app.LeftPanelGrid = uigridlayout(app.LeftPanel);
            app.LeftPanelGrid.ColumnWidth = {22, 5, 73, 10, 100};
            app.LeftPanelGrid.RowHeight = {92, 17, 22, 22, 22, 22, 22, 69, '1x', 17};
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
            app.State.FontColor = [1 1 1];
            app.State.BackgroundColor = [0.7216 0.1882 0.1686];
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
            app.Location.Items = {};
            app.Location.Editable = 'on';
            app.Location.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Location.FontSize = 11;
            app.Location.BackgroundColor = [1 1 1];
            app.Location.Layout.Row = 5;
            app.Location.Layout.Column = [1 5];
            app.Location.Value = {};

            % Create ReceiverLabel
            app.ReceiverLabel = uilabel(app.LeftPanelGrid);
            app.ReceiverLabel.VerticalAlignment = 'bottom';
            app.ReceiverLabel.FontSize = 11;
            app.ReceiverLabel.Layout.Row = 6;
            app.ReceiverLabel.Layout.Column = [1 3];
            app.ReceiverLabel.Text = 'Sensor';

            % Create Receiver
            app.Receiver = uidropdown(app.LeftPanelGrid);
            app.Receiver.Items = {''};
            app.Receiver.Editable = 'on';
            app.Receiver.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.Receiver.FontSize = 11;
            app.Receiver.BackgroundColor = [1 1 1];
            app.Receiver.Layout.Row = 7;
            app.Receiver.Layout.Column = [1 5];
            app.Receiver.Value = '';

            % Create ReceiverPanel
            app.ReceiverPanel = uipanel(app.LeftPanelGrid);
            app.ReceiverPanel.Layout.Row = 8;
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
            app.ReceiverStatus.Items = {'', 'Online', 'Offline'};
            app.ReceiverStatus.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.ReceiverStatus.FontSize = 11;
            app.ReceiverStatus.BackgroundColor = [1 1 1];
            app.ReceiverStatus.Layout.Row = 2;
            app.ReceiverStatus.Layout.Column = 1;
            app.ReceiverStatus.Value = '';

            % Create ReceiverPositionLabel
            app.ReceiverPositionLabel = uilabel(app.ReceiverGrid);
            app.ReceiverPositionLabel.VerticalAlignment = 'bottom';
            app.ReceiverPositionLabel.FontSize = 11;
            app.ReceiverPositionLabel.Layout.Row = 1;
            app.ReceiverPositionLabel.Layout.Column = 2;
            app.ReceiverPositionLabel.Text = 'Registro posição:';

            % Create ReceiverPosition
            app.ReceiverPosition = uidropdown(app.ReceiverGrid);
            app.ReceiverPosition.Items = {'', 'Atual', 'Histórica'};
            app.ReceiverPosition.ValueChangedFcn = createCallbackFcn(app, @onFilterValueChanged, true);
            app.ReceiverPosition.FontSize = 11;
            app.ReceiverPosition.BackgroundColor = [1 1 1];
            app.ReceiverPosition.Layout.Row = 2;
            app.ReceiverPosition.Layout.Column = 2;
            app.ReceiverPosition.Value = '';

            % Create CacheUpdatedAtIcon
            app.CacheUpdatedAtIcon = uiimage(app.LeftPanelGrid);
            app.CacheUpdatedAtIcon.ScaleMethod = 'none';
            app.CacheUpdatedAtIcon.Enable = 'off';
            app.CacheUpdatedAtIcon.Layout.Row = 10;
            app.CacheUpdatedAtIcon.Layout.Column = 1;
            app.CacheUpdatedAtIcon.VerticalAlignment = 'top';
            app.CacheUpdatedAtIcon.ImageSource = 'calendar.svg';

            % Create CacheUpdatedAt
            app.CacheUpdatedAt = uilabel(app.LeftPanelGrid);
            app.CacheUpdatedAt.FontSize = 11;
            app.CacheUpdatedAt.FontColor = [0.502 0.502 0.502];
            app.CacheUpdatedAt.Layout.Row = 10;
            app.CacheUpdatedAt.Layout.Column = [3 5];
            app.CacheUpdatedAt.Text = '';

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

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 3;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

            % Create axesTool_Basemap
            app.axesTool_Basemap = uidropdown(app.AxesToolbar);
            app.axesTool_Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.axesTool_Basemap.ValueChangedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
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
