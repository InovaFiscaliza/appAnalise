classdef DBHandler < handle
    properties (Access = public)
        %-----------------------------------------------------------------%
        Status = false
        Settings

        CacheFolder = struct('points', [], 'siteDetails', []);
        CacheData
        CacheUpdatedAt
        CacheSession = struct('hash', {}, 'data', {})

        ConnRFData % Conexão com banco RFDATA
        ConnBPData % Conexão com banco BPDATA
        ConnSMData % Conexão com banco RFFUSION_SUMMARY
    end


    properties (Constant)
        %-----------------------------------------------------------------%
        CACHE_FILE_NAME = 'RepoSFI.mat'
        CACHE_TTL_HOURS = 12
        CONNECTION_TIMEOUT_SECONDS = 25
    end


    methods
        %-----------------------------------------------------------------%
        function [obj, warningMsg] = DBHandler(generalSettings)
            obj.Settings = generalSettings.context.REPOSFI;

            % Tentativa de conexão à BASE DE DADOS, criando um objeto mysql
            % para cada um dos bancos.
            dbHost   = obj.Settings.host;
            dbPort   = obj.Settings.dbPort;
            dbUser   = obj.Settings.dbUser;
            dbPass   = obj.Settings.dbPassword;
            dbRFName = obj.Settings.dbSchemas.rfData;
            dbBPName = obj.Settings.dbSchemas.bpData;
            dbSMName = obj.Settings.dbSchemas.smData;

            try
                t = tcpclient(dbHost, dbPort, 'Timeout', obj.CONNECTION_TIMEOUT_SECONDS);
                delete(t)

                obj.ConnRFData = mysql(dbUser, dbPass, 'Server', dbHost, 'PortNumber', dbPort, 'DatabaseName', dbRFName);
                obj.ConnBPData = mysql(dbUser, dbPass, 'Server', dbHost, 'PortNumber', dbPort, 'DatabaseName', dbBPName);
                obj.ConnSMData = mysql(dbUser, dbPass, 'Server', dbHost, 'PortNumber', dbPort, 'DatabaseName', dbSMName);
                obj.Status = true;

                warningMsg = '';
            
            catch ME
                warningMsg = ME.message;
            end

            % Tentativa de obter TABELA DE SENSORES, que suporta a visualização 
            % principal em mapa do módulo em auxApp.winRepoSFI e o seu popup. 
            % As outras tabelas serão requeridas diretamente da BASE DE DADOS, 
            % filtradas com valores inseridos na GUI.
            obj.CacheFolder = fullfile(appEngine.util.OperationSystem('programData'), 'ANATEL', class.Constants.appName, 'DataBase');

            try
                if isCacheValid(obj)
                    error('util:DBHandler:CacheBypassQuery', 'Cache is valid. Bypassing database query.')
                end

                [points, siteDetails] = getMapDataSet(obj);
                if isempty(points) || isempty(siteDetails)
                    error('util:DBHandler:UnexpectedEmptyData', 'Unexpected empty data')
                end

                obj.CacheData.points = points;
                obj.CacheData.siteDetails = siteDetails;
                obj.CacheUpdatedAt = datestr(now, 'HH:MM:SS dd/mm/yyyy');
                saveCache(obj)
            
            catch
                getCache(obj)
            end
        end

        %-----------------------------------------------------------------%
        function isValid = isCacheValid(obj)
            isValid = false;
            cacheFile = fullfile(obj.CacheFolder, obj.CACHE_FILE_NAME);

            if isfile(cacheFile)
                try
                    load(cacheFile, 'cacheUpdatedAt')
                    cacheUpdatedAt = datetime(cacheUpdatedAt, 'InputFormat', 'HH:mm:ss dd/MM/yyyy');

                    if hours(datetime('now') - cacheUpdatedAt) < obj.CACHE_TTL_HOURS
                        isValid = true;
                    end
                catch
                end
            end
        end

        %-----------------------------------------------------------------%
        function saveCache(obj)
            cacheFile = fullfile(obj.CacheFolder, obj.CACHE_FILE_NAME);

            points = obj.CacheData.points;
            siteDetails = obj.CacheData.siteDetails;
            cacheUpdatedAt = obj.CacheUpdatedAt;

            save(cacheFile, 'points', 'siteDetails', 'cacheUpdatedAt', '-mat', '-v7')
        end

        %-----------------------------------------------------------------%
        function getCache(obj)
            cacheFile = fullfile(obj.CacheFolder, obj.CACHE_FILE_NAME);
    
            if isfile(cacheFile)
                try
                    load(cacheFile, 'points', 'siteDetails', 'cacheUpdatedAt')

                    obj.CacheData.points = points;
                    obj.CacheData.siteDetails = siteDetails;
                    obj.CacheUpdatedAt = cacheUpdatedAt;
                catch
                end
            end
        end

        %-----------------------------------------------------------------%
        function delete(obj)
            obj.ConnRFData = closeSingleConnection(obj, obj.ConnRFData);
            obj.ConnBPData = closeSingleConnection(obj, obj.ConnBPData);
            obj.ConnSMData = closeSingleConnection(obj, obj.ConnSMData);
        end

        %-----------------------------------------------------------------%
        function output = getStationSummary(obj)
            % Essa função usa a conexão com o banco de dados criada
            % Retorna um array com informação de posição das estações
            % Seus nomes, uuid, data da primeira visão e data da ultima
            % visao

            if ~isempty(obj.ConnSMData)
                sqlStationQuery = ...
                    "SELECT * " + ...
                    "FROM HOST_LOCATION_SUMMARY " + ...
                    "WHERE VL_LATITUDE IS NOT NULL " + ...
                    "  AND VL_LONGITUDE IS NOT NULL " + ...
                    "ORDER BY " + ...
                    "    IS_CURRENT_LOCATION DESC, " + ...
                    "    IS_OFFLINE_SNAPSHOT ASC, " + ...
                    "    DT_LAST_SEEN_AT DESC, " + ...
                    "    NA_STATE_CODE ASC, " + ...
                    "    NA_LOCALITY_LABEL ASC, " + ...
                    "    NA_HOST_NAME ASC;";
                
                % Executa a Query
                output = fetch(obj.ConnSMData, sqlStationQuery);
            end
        end

        %-----------------------------------------------------------------%
        function output = getSummarySiteRows(obj)
            % Retorna uma linha consolidada por site mapeado
            % a partir da tabela MAP_SITE_SUMMARY.

            output = table();

            if isempty(obj.ConnSMData)
                return;
            end

            sqlQuery = ...
                "SELECT " + ...
                "    FK_SITE AS ID_SITE, " + ...
                "    NA_SITE_LABEL AS SITE_LABEL, " + ...
                "    NA_COUNTY_NAME AS COUNTY_NAME, " + ...
                "    FK_DISTRICT AS ID_DISTRICT, " + ...
                "    NA_DISTRICT_NAME AS DISTRICT_NAME, " + ...
                "    ID_STATE, " + ...
                "    NA_STATE_NAME AS NA_STATE, " + ...
                "    NA_STATE_CODE AS LC_STATE, " + ...
                "    VL_LATITUDE, " + ...
                "    VL_LONGITUDE, " + ...
                "    VL_ALTITUDE, " + ...
                "    NU_GNSS_MEASUREMENTS, " + ...
                "    NA_MARKER_STATE, " + ...
                "    HAS_ONLINE_STATION, " + ...
                "    HAS_ONLINE_HOST, " + ...
                "    HAS_KNOWN_HOST " + ...
                "FROM MAP_SITE_SUMMARY " + ...
                "ORDER BY FK_SITE;";

            output = fetch(obj.ConnSMData, sqlQuery);
        end

        %-----------------------------------------------------------------%
        function output = getSummaryStationRows(obj)
            % Retorna as linhas por estação/equipamento usadas
            % para enriquecer cada site do mapa.

            output = table();

            if isempty(obj.ConnSMData)
                return;
            end

            sqlQuery = ...
                "SELECT " + ...
                "    FK_SITE AS ID_SITE, " + ...
                "    FK_EQUIPMENT AS ID_EQUIPMENT, " + ...
                "    FK_HOST AS ID_HOST, " + ...
                "    NA_EQUIPMENT, " + ...
                "    NA_HOST_NAME, " + ...
                "    IS_OFFLINE, " + ...
                "    IS_CURRENT_LOCATION, " + ...
                "    NA_MAP_STATE, " + ...
                "    DT_FIRST_SEEN_AT AS FIRST_SEEN_AT, " + ...
                "    DT_LAST_SEEN_AT AS LAST_SEEN_AT, " + ...
                "    NU_SPECTRUM_COUNT " + ...
                "FROM MAP_SITE_STATION_SUMMARY " + ...
                "ORDER BY FK_SITE, NU_STATE_PRIORITY, NA_HOST_NAME, NA_EQUIPMENT;";

            output = fetch(obj.ConnSMData, sqlQuery);
        end

        %-----------------------------------------------------------------%
        function [points, siteDetails] = getMapDataSet(obj)
            % As saídas contém a estrutura mínima de dados para replicar
            % a aplicação web do RF.Fusion, quais sejam: "points" para 
            % mapa e "siteDetails" para popup.

            points = createDataBaseModel(obj, 'point');
            siteDetails = createDataBaseModel(obj, 'siteDetail');

            siteRows = obj.getSummarySiteRows();
            stationRows = obj.getSummaryStationRows();

            if ~istable(siteRows) || isempty(siteRows)
                return;
            end

            if ~istable(stationRows)
                stationRows = table();
            end

            for ii = 1:height(siteRows)
                siteId = obj.toDouble(siteRows.ID_SITE(ii));
                latitude = obj.toDouble(siteRows.VL_LATITUDE(ii));
                longitude = obj.toDouble(siteRows.VL_LONGITUDE(ii));

                if isnan(siteId) || isnan(latitude) || isnan(longitude)
                    continue;
                end

                markerState = obj.normalizeMapState(siteRows.NA_MARKER_STATE(ii));
                hasOnlineStation = obj.toLogical(siteRows.HAS_ONLINE_STATION(ii));
                hasOnlineHost = obj.toLogical(siteRows.HAS_ONLINE_HOST(ii));
                hasKnownHost = obj.toLogical(siteRows.HAS_KNOWN_HOST(ii));
                detailStations = createDataBaseModel(obj, 'detailStation');

                if ~isempty(stationRows)
                    % Comeca com o estado consolidado vindo de MAP_SITE_SUMMARY,
                    % mas permite recalcular pelo detalhe das estacoes para
                    % manter o comportamento consistente com o WebFusion.
                    bestPriority = obj.mapStatePriority(markerState);

                    for jj = 1:height(stationRows)
                        stationSiteId = obj.toDouble(stationRows.ID_SITE(jj));

                        if isnan(stationSiteId) || stationSiteId ~= siteId
                            continue;
                        end

                        % Cada linha de MAP_SITE_STATION_SUMMARY representa uma
                        % estacao/equipamento associada a este site.
                        station = obj.buildDetailStation(stationRows, jj);
                        detailStations(end + 1, 1) = station; %#ok<AGROW>

                        stationPriority = obj.mapStatePriority(station.map_state);

                        % O marcador do site sempre mostra o estado mais
                        % relevante entre todas as estacoes do mesmo site.
                        if stationPriority < bestPriority
                            markerState = station.map_state;
                            bestPriority = stationPriority;
                        end

                        % Esses flags sao derivados do conjunto de estacoes
                        % para o popup e para filtros do mapa.
                        if obj.isOnlineState(station.map_state)
                            hasOnlineStation = true;
                            hasOnlineHost = true;
                        end

                        if ~isnan(station.host_id)
                            hasKnownHost = true;
                        end
                    end
                end

                detail = struct( ...
                    'site_id', round(siteId), ...
                    'stations', detailStations, ...
                    'marker_state', markerState, ...
                    'has_online_station', hasOnlineStation, ...
                    'has_online_host', hasOnlineHost, ...
                    'has_known_host', hasKnownHost ...
                );

                pointStations = createDataBaseModel(obj, 'publicStation');
                stationNames = strings(0, 1);

                for kk = 1:numel(detailStations)
                    % O ponto do mapa carrega uma versao enxuta das estacoes,
                    % enquanto o popup usa o detalhe completo em site_details.
                    pointStations(end + 1, 1) = obj.buildPublicStation(detailStations(kk)); %#ok<AGROW>

                    stationName = obj.chooseStationName( ...
                        detailStations(kk).host_name, ...
                        detailStations(kk).equipment_name ...
                        );

                    if strlength(stationName) > 0
                        stationNames(end + 1, 1) = stationName; %#ok<AGROW>
                    end
                end

                % Este struct replica o payload consumido pelo mapa para
                % desenhar marcadores e preencher tooltips/listas.
                point = struct( ...
                    'site_id', round(siteId), ...
                    'site_label', obj.toText(siteRows.SITE_LABEL(ii), sprintf('Site %d', round(siteId))), ...
                    'county_name', obj.toNullableText(siteRows.COUNTY_NAME(ii)), ...
                    'district_id', obj.toNullableDouble(siteRows.ID_DISTRICT(ii)), ...
                    'district_name', obj.toNullableText(siteRows.DISTRICT_NAME(ii)), ...
                    'state_id', obj.toNullableDouble(siteRows.ID_STATE(ii)), ...
                    'state_name', obj.toNullableText(siteRows.NA_STATE(ii)), ...
                    'state_code', obj.toNullableText(siteRows.LC_STATE(ii)), ...
                    'latitude', latitude, ...
                    'longitude', longitude, ...
                    'altitude', obj.toNullableDouble(siteRows.VL_ALTITUDE(ii)), ...
                    'gnss_measurements', obj.toNullableDouble(siteRows.NU_GNSS_MEASUREMENTS(ii)), ...
                    'stations', pointStations, ...
                    'station_names', stationNames, ...
                    'marker_state', markerState, ...
                    'has_online_station', hasOnlineStation, ...
                    'has_online_host', hasOnlineHost, ...
                    'has_known_host', hasKnownHost ...
                );

                points(end+1, 1) = point;
                siteDetails(end+1, 1) = detail;
            end
        end

        %-----------------------------------------------------------------%
        function output = getHostStats(obj, hostId)
            % Retorna estatísticas de um host específico do BPDATA.
            % Equivale à função get_host_statistics() do webfusion.
            
            output = table();

            if isempty(obj.ConnBPData)
                return;
            end

            sqlQuery = ...
                "SELECT " + ...
                "    ID_HOST, " + ...
                "    NA_HOST_NAME, " + ...
                "    NA_HOST_ADDRESS, " + ...
                "    NA_HOST_PORT, " + ...
                "    IS_OFFLINE, " + ...
                "    IS_BUSY, " + ...
                "    DT_LAST_CHECK, " + ...
                "    DT_LAST_DISCOVERY, " + ...
                "    DT_LAST_BACKUP, " + ...
                "    DT_LAST_PROCESSING, " + ...
                "    NU_HOST_FILES, " + ...
                "    NU_PENDING_FILE_BACKUP_TASKS, " + ...
                "    NU_DONE_FILE_BACKUP_TASKS, " + ...
                "    VL_PENDING_BACKUP_KB " + ...
                "FROM BPDATA.HOST " + ...
                "WHERE ID_HOST = " + string(hostId);

            try
                output = fetch(obj.ConnBPData, sqlQuery);
            catch ME
                % Se a query falhar, retorna table vazio
                output = table();
            end
        end

        %-----------------------------------------------------------------%
        function output = getSpectrumEquipments(obj, filters)
            % Retorna o catálogo de equipamentos com dados observados.
            %
            % filters (opcional): struct com campos opcionais:
            %   stateCode — restringe aos equipamentos com dados no UF indicado
            %   siteId    — restringe aos equipamentos que visitaram o site indicado

            output = table();

            if nargin < 2 || ~isstruct(filters)
                filters = struct();
            end

            stateCode  = obj.toText(obj.getStructField(filters, 'stateCode'), '');
            siteId     = obj.toDouble(obj.getStructField(filters, 'siteId'));
            districtId = obj.toDouble(obj.getStructField(filters, 'districtId'));

            % Escapa aspas simples para evitar injeção SQL com valores do banco.
            stateCode = replace(stateCode, "'", "''");

            stateCondSM    = "";
            siteCondSM     = "";
            districtCondSM = "";
            if strlength(stateCode) > 0
                stateCondSM = " AND NA_STATE_CODE = '" + stateCode + "'";
            end
            if ~isnan(siteId)
                siteCondSM = " AND FK_SITE = " + string(round(siteId));
            end
            if ~isnan(districtId)
                districtCondSM = " AND FK_DISTRICT = " + string(round(districtId));
            end

            if ~isempty(obj.ConnSMData)
                sqlQuery = ...
                    "SELECT DISTINCT " + ...
                    "    FK_EQUIPMENT AS ID_EQUIPMENT, " + ...
                    "    NA_EQUIPMENT " + ...
                    "FROM SITE_EQUIPMENT_OBS_SUMMARY " + ...
                    "WHERE NA_EQUIPMENT IS NOT NULL " + ...
                    "  AND NA_EQUIPMENT <> ''" + ...
                    stateCondSM + siteCondSM + districtCondSM + " " + ...
                    "ORDER BY NA_EQUIPMENT;";

                try
                    output = fetch(obj.ConnSMData, sqlQuery);
                catch ME
                    output = table();
                end
            end

            if istable(output) && ~isempty(output)
                return;
            end

            if isempty(obj.ConnRFData)
                output = table();
                return;
            end

            stateJoin   = "";
            stateCondRF = "";
            if strlength(stateCode) > 0
                stateJoin   = "JOIN RFDATA.DIM_SPECTRUM_SITE seq ON seq.ID_SITE = f.FK_SITE " + ...
                              "LEFT JOIN RFDATA.DIM_SITE_STATE steq ON steq.ID_STATE = seq.FK_STATE ";
                stateCondRF = " AND steq.LC_STATE = '" + stateCode + "'";
            end
            siteCondRF = "";
            if ~isnan(siteId)
                siteCondRF = " AND f.FK_SITE = " + string(round(siteId));
            end

            sqlQuery = ...
                "SELECT DISTINCT " + ...
                "    e.ID_EQUIPMENT, " + ...
                "    e.NA_EQUIPMENT " + ...
                "FROM RFDATA.DIM_SPECTRUM_EQUIPMENT e " + ...
                "JOIN RFDATA.FACT_SPECTRUM f ON f.FK_EQUIPMENT = e.ID_EQUIPMENT " + ...
                stateJoin + ...
                "WHERE 1=1" + stateCondRF + siteCondRF + " " + ...
                "ORDER BY e.NA_EQUIPMENT;";

            try
                output = fetch(obj.ConnRFData, sqlQuery);
            catch ME
                output = table();
            end
        end

        %-----------------------------------------------------------------%
        function output = getSpectrumStates(obj, filters)
            % Retorna os códigos de estado (UF) com dados de espectro no repositório.
            %
            % filters (opcional): struct com campos opcionais:
            %   equipmentId — restringe aos estados onde o equipamento tem dados
            %   siteId      — restringe ao estado do site indicado

            output = table();

            if nargin < 2 || ~isstruct(filters)
                filters = struct();
            end

            equipmentId = obj.toDouble(obj.getStructField(filters, 'equipmentId'));
            siteId      = obj.toDouble(obj.getStructField(filters, 'siteId'));

            equipCondSM = "";
            siteCondSM  = "";
            if ~isnan(equipmentId)
                equipCondSM = " AND FK_EQUIPMENT = " + string(round(equipmentId));
            end
            if ~isnan(siteId)
                siteCondSM = " AND FK_SITE = " + string(round(siteId));
            end

            if ~isempty(obj.ConnSMData)
                sqlQuery = ...
                    "SELECT DISTINCT NA_STATE_CODE AS LC_STATE " + ...
                    "FROM SITE_EQUIPMENT_OBS_SUMMARY " + ...
                    "WHERE NA_STATE_CODE IS NOT NULL " + ...
                    "  AND NA_STATE_CODE <> ''" + ...
                    equipCondSM + siteCondSM + " " + ...
                    "ORDER BY NA_STATE_CODE;";
                try
                    output = fetch(obj.ConnSMData, sqlQuery);
                catch ME
                    output = table();
                end
            end

            if istable(output) && ~isempty(output)
                return;
            end

            if isempty(obj.ConnRFData)
                output = table();
                return;
            end

            equipCondRF = "";
            siteCondRF  = "";
            if ~isnan(equipmentId)
                equipCondRF = " AND f.FK_EQUIPMENT = " + string(round(equipmentId));
            end
            if ~isnan(siteId)
                siteCondRF = " AND f.FK_SITE = " + string(round(siteId));
            end

            sqlQuery = ...
                "SELECT DISTINCT st.LC_STATE " + ...
                "FROM RFDATA.FACT_SPECTRUM f " + ...
                "JOIN RFDATA.DIM_SPECTRUM_SITE s ON s.ID_SITE = f.FK_SITE " + ...
                "LEFT JOIN RFDATA.DIM_SITE_STATE st ON st.ID_STATE = s.FK_STATE " + ...
                "WHERE st.LC_STATE IS NOT NULL" + equipCondRF + siteCondRF + " " + ...
                "ORDER BY st.LC_STATE;";
            try
                output = fetch(obj.ConnRFData, sqlQuery);
            catch ME
                output = table();
            end
        end

        %-----------------------------------------------------------------%
        function output = getSpectrumLocalities(obj, equipmentId, filters)
            % Retorna as localidades disponíveis, com ou sem equipamento selecionado.
            %
            % Quando equipmentId é NaN, a consulta usa o filtro de estado (stateCode)
            % presente em filters para limitar o universo de localidades retornadas.
            % Sem nenhum filtro restritivo a função retorna vazio para evitar
            % carregar o catálogo inteiro do banco.

            output = table();
            equipmentId = obj.toDouble(equipmentId);

            if nargin < 3
                filters = struct();
            end

            stateCode = obj.toText(obj.getStructField(filters, 'stateCode'), '');
            % Escapa aspas simples para evitar injeção SQL com valores do banco.
            stateCode = replace(stateCode, "'", "''");

            % Sem equipamento e sem estado não há recorte: retorna vazio.
            if isnan(equipmentId) && strlength(stateCode) == 0
                return;
            end

            hasSpectrumFilters = false;

            if isstruct(filters)
                hasSpectrumFilters = ...
                    strlength(obj.toSQLDate(obj.getStructField(filters, 'startDate'), 'start')) > 0 || ...
                    strlength(obj.toSQLDate(obj.getStructField(filters, 'endDate'), 'end')) > 0 || ...
                    ~isnan(obj.toDouble(obj.getStructField(filters, 'freqStart'))) || ...
                    ~isnan(obj.toDouble(obj.getStructField(filters, 'freqEnd'))) || ...
                    strlength(obj.buildSQLLikePattern(obj.getStructField(filters, 'description'))) > 0;
            end

            % SMData path: mais rápido; usado quando há equipamento ou UF selecionados.
            % Agrega por distrito em vez de site para eliminar entradas duplicadas.
            if ~hasSpectrumFilters && (~isnan(equipmentId) || strlength(stateCode) > 0) && ~isempty(obj.ConnSMData)
                equipCond = "";
                stateCond = "";
                if ~isnan(equipmentId)
                    equipCond = " AND FK_EQUIPMENT = " + string(round(equipmentId));
                end
                if strlength(stateCode) > 0
                    stateCond = " AND NA_STATE_CODE = '" + stateCode + "'";
                end
                sqlQuery = ...
                    "SELECT " + ...
                    "    sm.FK_DISTRICT AS ID_DISTRICT, " + ...
                    "    sm.NA_DISTRICT_NAME AS LOCALITY_LABEL, " + ...
                    "    sm.NA_COUNTY_NAME AS COUNTY_NAME, " + ...
                    "    sm.NA_STATE_CODE AS STATE_CODE, " + ...
                    "    COUNT(DISTINCT sm.FK_SITE) AS SITE_COUNT, " + ...
                    "    SUM(sm.NU_SPECTRUM_COUNT) AS SPECTRUM_COUNT, " + ...
                    "    MIN(sm.DT_FIRST_SEEN_AT) AS DATE_START, " + ...
                    "    MAX(sm.DT_LAST_SEEN_AT) AS DATE_END " + ...
                    "FROM SITE_EQUIPMENT_OBS_SUMMARY sm " + ...
                    "WHERE sm.FK_DISTRICT IS NOT NULL" + equipCond + stateCond + " " + ...
                    "GROUP BY sm.FK_DISTRICT, sm.NA_DISTRICT_NAME, sm.NA_COUNTY_NAME, sm.NA_STATE_CODE " + ...
                    "ORDER BY sm.NA_DISTRICT_NAME ASC, sm.NA_COUNTY_NAME ASC, sm.NA_STATE_CODE ASC;";

                try
                    output = fetch(obj.ConnSMData, sqlQuery);
                catch ME
                    output = table();
                end
            end

            if istable(output) && ~isempty(output)
                return;
            end

            if isempty(obj.ConnRFData)
                output = table();
                return;
            end

            localityFilters = filters;

            if ~isstruct(localityFilters)
                localityFilters = struct();
            end

            localityFilters.equipmentId = equipmentId;
            localityFilters.siteId = NaN;
            whereConditions = obj.buildSpectrumWhereConditions(localityFilters, true);

            stateCond = "";
            if strlength(stateCode) > 0
                stateCond = " AND st.LC_STATE = '" + stateCode + "'";
            end

            sqlQuery = ...
                "SELECT " + ...
                "    d.ID_DISTRICT, " + ...
                "    d.NA_DISTRICT AS LOCALITY_LABEL, " + ...
                "    c.NA_COUNTY AS COUNTY_NAME, " + ...
                "    st.LC_STATE AS STATE_CODE, " + ...
                "    COUNT(DISTINCT s.ID_SITE) AS SITE_COUNT, " + ...
                "    COUNT(*) AS SPECTRUM_COUNT, " + ...
                "    MIN(f.DT_TIME_START) AS DATE_START, " + ...
                "    MAX(f.DT_TIME_END) AS DATE_END " + ...
                "FROM RFDATA.FACT_SPECTRUM f " + ...
                "JOIN RFDATA.DIM_SPECTRUM_SITE s ON s.ID_SITE = f.FK_SITE " + ...
                "JOIN RFDATA.DIM_SITE_DISTRICT d ON d.ID_DISTRICT = s.FK_DISTRICT " + ...
                "LEFT JOIN RFDATA.DIM_SITE_COUNTY c ON c.ID_COUNTY = s.FK_COUNTY " + ...
                "LEFT JOIN RFDATA.DIM_SITE_STATE st ON st.ID_STATE = s.FK_STATE " + ...
                "WHERE s.FK_DISTRICT IS NOT NULL " + whereConditions + stateCond + " " + ...
                "GROUP BY d.ID_DISTRICT, d.NA_DISTRICT, c.NA_COUNTY, st.LC_STATE " + ...
                "ORDER BY d.NA_DISTRICT ASC, c.NA_COUNTY ASC, st.LC_STATE ASC;";

            try
                output = fetch(obj.ConnRFData, sqlQuery);
            catch ME
                output = table();
            end
        end

        %-----------------------------------------------------------------%
        function output = getSpectrumFileData(obj, filters)
            % Retorna uma linha por arquivo do repositório.

            output = table();

            if isempty(obj.ConnRFData)
                return;
            end

            whereConditions = obj.buildSpectrumWhereConditions(filters, true);
            localitySql = obj.buildSpectrumLocalitySql();
            [pageSize, offset] = obj.getPaginationInfo(filters);

            sqlQuery = ...
                "SELECT " + ...
                "    repos.ID_FILE, " + ...
                "    repos.NA_PATH, " + ...
                "    repos.NA_FILE, " + ...
                "    repos.NA_EXTENSION, " + ...
                "    repos.VL_FILE_SIZE_KB, " + ...
                "    MIN(f.DT_TIME_START) AS DT_TIME_START, " + ...
                "    MAX(f.DT_TIME_END) AS DT_TIME_END, " + ...
                "    MIN(f.NU_FREQ_START) AS NU_FREQ_START, " + ...
                "    MAX(f.NU_FREQ_END) AS NU_FREQ_END, " + ...
                "    COUNT(DISTINCT f.ID_SPECTRUM) AS NU_SPECTRA, " + ...
                "    COUNT(DISTINCT s.ID_SITE) AS LOCALITY_COUNT, " + ...
                "    GROUP_CONCAT(DISTINCT " + localitySql + " ORDER BY " + localitySql + " SEPARATOR ' | ') AS LOCALITY_LABELS, " + ...
                "    GROUP_CONCAT(DISTINCT e.NA_EQUIPMENT ORDER BY e.NA_EQUIPMENT SEPARATOR ' | ') AS EQUIPMENT_LABELS " + ...
                "FROM RFDATA.FACT_SPECTRUM f " + ...
                "JOIN RFDATA.BRIDGE_SPECTRUM_FILE b ON b.FK_SPECTRUM = f.ID_SPECTRUM " + ...
                "JOIN RFDATA.DIM_SPECTRUM_FILE repos ON repos.ID_FILE = b.FK_FILE " + ...
                "JOIN RFDATA.DIM_SPECTRUM_EQUIPMENT e ON e.ID_EQUIPMENT = f.FK_EQUIPMENT " + ...
                "JOIN RFDATA.DIM_SPECTRUM_SITE s ON s.ID_SITE = f.FK_SITE " + ...
                "LEFT JOIN RFDATA.DIM_SITE_DISTRICT d ON d.ID_DISTRICT = s.FK_DISTRICT " + ...
                "LEFT JOIN RFDATA.DIM_SITE_COUNTY c ON c.ID_COUNTY = s.FK_COUNTY " + ...
                "LEFT JOIN RFDATA.DIM_SITE_STATE st ON st.ID_STATE = s.FK_STATE " + ...
                "WHERE repos.NA_VOLUME = 'reposfi' " + whereConditions + " " + ...
                "GROUP BY repos.ID_FILE, repos.NA_PATH, repos.NA_FILE, repos.NA_EXTENSION, repos.VL_FILE_SIZE_KB " + ...
                "ORDER BY MIN(f.DT_TIME_START) DESC, repos.ID_FILE DESC " + ...
                "LIMIT " + string(pageSize + 1) + " OFFSET " + string(offset) + ";";

            try
                output = fetch(obj.ConnRFData, sqlQuery);
            catch ME
                output = table();
            end
        end

        %-----------------------------------------------------------------%
        function output = getSpectraByFileId(obj, fileId, filters)
            % Retorna os espectros vinculados a um arquivo específico do repositório.

            output = table();

            if isempty(obj.ConnRFData)
                return;
            end

            fileId = obj.toDouble(fileId);
            if isnan(fileId)
                return;
            end

            if nargin < 3 || ~isstruct(filters)
                filters = struct();
            end

            whereConditions = obj.buildSpectrumWhereConditions(filters, true);
            localitySql = obj.buildSpectrumLocalitySql();

            sqlQuery = ...
                "SELECT " + ...
                "    f.ID_SPECTRUM, " + ...
                "    f.NA_DESCRIPTION, " + ...
                "    f.NU_FREQ_START, " + ...
                "    f.NU_FREQ_END, " + ...
                "    f.DT_TIME_START, " + ...
                "    f.DT_TIME_END, " + ...
                "    f.FK_SITE AS ID_SITE, " + ...
                     localitySql + " AS LOCALITY_LABEL, " + ...
                "    c.NA_COUNTY AS COUNTY_NAME, " + ...
                "    st.LC_STATE AS STATE_CODE, " + ...
                "    e.NA_EQUIPMENT " + ...
                "FROM RFDATA.FACT_SPECTRUM f " + ...
                "JOIN RFDATA.BRIDGE_SPECTRUM_FILE b ON b.FK_SPECTRUM = f.ID_SPECTRUM " + ...
                "JOIN RFDATA.DIM_SPECTRUM_FILE repos ON repos.ID_FILE = b.FK_FILE " + ...
                "JOIN RFDATA.DIM_SPECTRUM_EQUIPMENT e ON e.ID_EQUIPMENT = f.FK_EQUIPMENT " + ...
                "JOIN RFDATA.DIM_SPECTRUM_SITE s ON s.ID_SITE = f.FK_SITE " + ...
                "LEFT JOIN RFDATA.DIM_SITE_DISTRICT d ON d.ID_DISTRICT = s.FK_DISTRICT " + ...
                "LEFT JOIN RFDATA.DIM_SITE_COUNTY c ON c.ID_COUNTY = s.FK_COUNTY " + ...
                "LEFT JOIN RFDATA.DIM_SITE_STATE st ON st.ID_STATE = s.FK_STATE " + ...
                "WHERE repos.NA_VOLUME = 'reposfi' " + ...
                "  AND repos.ID_FILE = " + string(round(fileId)) + " " + ...
                     whereConditions + " " + ...
                "ORDER BY f.DT_TIME_START DESC, f.ID_SPECTRUM DESC;";

            try
                output = fetch(obj.ConnRFData, sqlQuery);
            catch ME
                output = table();
            end
        end

        %-----------------------------------------------------------------%
        function output = getSpectrumFileDataCount(obj, filters)
            % Retorna a quantidade total de linhas da consulta por arquivo.

            output = 0;

            if isempty(obj.ConnRFData)
                return;
            end

            whereConditions = obj.buildSpectrumWhereConditions(filters, true);

            % Quando há filtro de estado, adiciona os JOINs necessários para o
            % alias 'st' que buildSpectrumWhereConditions injeta na cláusula WHERE.
            stateCode = obj.toText(obj.getStructField(filters, 'stateCode'), '');
            if strlength(stateCode) > 0
                stateJoin = ...
                    "    JOIN RFDATA.DIM_SPECTRUM_SITE s_cnt ON s_cnt.ID_SITE = f.FK_SITE " + ...
                    "    LEFT JOIN RFDATA.DIM_SITE_STATE st ON st.ID_STATE = s_cnt.FK_STATE ";
            else
                stateJoin = "";
            end

            sqlQuery = ...
                "SELECT COUNT(*) AS TOTAL_COUNT FROM ( " + ...
                "    SELECT repos.ID_FILE " + ...
                "    FROM RFDATA.FACT_SPECTRUM f " + ...
                "    JOIN RFDATA.BRIDGE_SPECTRUM_FILE b ON b.FK_SPECTRUM = f.ID_SPECTRUM " + ...
                "    JOIN RFDATA.DIM_SPECTRUM_FILE repos ON repos.ID_FILE = b.FK_FILE " + ...
                stateJoin + ...
                "    WHERE repos.NA_VOLUME = 'reposfi' " + whereConditions + " " + ...
                "    GROUP BY repos.ID_FILE " + ...
                ") counted;";

            try
                rows = fetch(obj.ConnRFData, sqlQuery);
                output = obj.readCountValue(rows);
            catch ME
                output = 0;
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function connectionObj = closeSingleConnection(~, connectionObj)
            if isempty(connectionObj)
                return;
            end

            try
                close(connectionObj);
            catch
                try
                    delete(connectionObj);
                catch
                end
            end

            connectionObj = [];
        end
        
        %---------------------------------------------------------------%
        function model = createDataBaseModel(~, dataType)
            switch dataType        
                case "point"
                    model = struct( ...
                        'site_id', {}, ... NaN
                        'site_label', {}, ... ""
                        'county_name', {}, ... []
                        'district_id', {}, ... []
                        'district_name', {}, ... []
                        'state_id', {}, ... []
                        'state_name', {}, ... []
                        'state_code', {}, ... []
                        'latitude', {}, ... NaN
                        'longitude', {}, ... NaN
                        'altitude', {}, ... []
                        'gnss_measurements', {}, ... []
                        'stations', {}, ... createDataBaseModel(obj, 'publicStation')
                        'station_names', {}, ... strings(0, 1)
                        'marker_state', {}, ... "no_host"
                        'has_online_station', {}, ... false
                        'has_online_host', {}, ... false
                        'has_known_host', {} ... false
                    );

                case "siteDetail"
                    model = struct( ...
                        'site_id', {}, ...NaN
                        'stations', {}, ... createDataBaseModel(obj, 'detailStation')
                        'marker_state', {}, ... "no_host"
                        'has_online_station', {}, ... false
                        'has_online_host', {}, ... false
                        'has_known_host', {} ... false
                    );
        
                case "detailStation"
                    model = struct( ...
                        'equipment_id', {}, ... []
                        'equipment_name', {}, ... []
                        'host_id', {}, ... []
                        'host_name', {}, ... []
                        'is_offline', {}, ... []
                        'is_current_location', {}, ... false
                        'map_state', {}, ... "no_host"
                        'first_seen_at', {}, ... []
                        'last_seen_at', {}, ... []
                        'spectrum_count', {} ... NaN
                    );
        
                case "publicStation"
                    model = struct( ...
                        'equipment_id', {}, ... []
                        'equipment_name', {}, ... []
                        'host_id', {}, ... []
                        'host_name', {}, ... []
                        'is_offline', {}, ... []
                        'is_current_location', {}, ... false
                        'map_state', {} ... "no_host"
                    );

                otherwise
                    error('util:DBHandler:InvalidType', 'Invalid type "%s"', dataType);
            end
        end

        %-----------------------------------------------------------------%
        function output = buildDetailStation(obj, rows, rowIndex)
            % Payload completo da estacao para uso em popup e filtros por data.
            output = struct( ...
                'equipment_id', obj.toNullableDouble(rows.ID_EQUIPMENT(rowIndex)), ...
                'equipment_name', obj.toNullableText(rows.NA_EQUIPMENT(rowIndex)), ...
                'host_id', obj.toNullableDouble(rows.ID_HOST(rowIndex)), ...
                'host_name', obj.toNullableText(rows.NA_HOST_NAME(rowIndex)), ...
                'is_offline', obj.toNullableLogical(rows.IS_OFFLINE(rowIndex)), ...
                'is_current_location', obj.toLogical(rows.IS_CURRENT_LOCATION(rowIndex)), ...
                'map_state', obj.normalizeMapState(rows.NA_MAP_STATE(rowIndex)), ...
                'first_seen_at', obj.toNullableValue(rows.FIRST_SEEN_AT(rowIndex)), ...
                'last_seen_at', obj.toNullableValue(rows.LAST_SEEN_AT(rowIndex)), ...
                'spectrum_count', obj.toDouble(rows.NU_SPECTRUM_COUNT(rowIndex)) ...
                );
        end

        %-----------------------------------------------------------------%
        function output = buildPublicStation(~, station)
            % Versao enxuta da estacao anexada ao ponto do mapa.
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

        %-----------------------------------------------------------------%
        function output = isOnlineState(~, stateKey)
            normalizedState = string(stateKey);
            output = any(normalizedState == ["online_current", "online_previous"]);
        end

        %-----------------------------------------------------------------%
        function output = mapStatePriority(~, stateKey)
            normalizedState = string(stateKey);

            % Quanto menor a prioridade, mais relevante o estado no mapa.
            switch normalizedState
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

        %-----------------------------------------------------------------%
        function output = normalizeMapState(obj, rawValue)
            % Mantem um fallback explicito para estados vazios/nulos.
            output = obj.toText(rawValue, "no_host");

            if strlength(strtrim(output)) == 0
                output = "no_host";
            end
        end

        %-----------------------------------------------------------------%
        function output = toDouble(~, rawValue)
            % O fetch do MATLAB pode devolver scalars, strings ou celulas;
            % este helper centraliza a normalizacao numerica.
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    output = NaN;
                    return;
                end

                value = value{1};
            end

            if isempty(value)
                output = NaN;
                return;
            end

            if isnumeric(value) || islogical(value)
                output = double(value(1));
                return;
            end

            if isstring(value)
                if all(ismissing(value))
                    output = NaN;
                    return;
                end

                output = str2double(value(1));
                return;
            end

            if ischar(value)
                if isempty(strtrim(value))
                    output = NaN;
                    return;
                end

                output = str2double(value);
                return;
            end

            output = NaN;
        end

        %-----------------------------------------------------------------%
        function output = toLogical(obj, rawValue)
            % Campos nulos no banco viram false no contrato publico.
            numericValue = obj.toDouble(rawValue);

            if isnan(numericValue)
                output = false;
            else
                output = numericValue ~= 0;
            end
        end

        %-----------------------------------------------------------------%
        function output = toNullableLogical(obj, rawValue)
            % Diferente de toLogical, preserva nulos como [].
            numericValue = obj.toDouble(rawValue);

            if isnan(numericValue)
                output = [];
            else
                output = numericValue ~= 0;
            end
        end

        %-----------------------------------------------------------------%
        function output = toNullableDouble(obj, rawValue)
            % Campos numericos opcionais do payload usam [] quando ausentes.
            numericValue = obj.toDouble(rawValue);

            if isnan(numericValue)
                output = [];
            else
                output = numericValue;
            end
        end

        %-----------------------------------------------------------------%
        function output = toText(~, rawValue, defaultValue)
            % Normaliza texto para string scalar e aplica fallback padrao.
            if nargin < 3
                defaultValue = "";
            end

            value = rawValue;

            while iscell(value)
                if isempty(value)
                    value = [];
                    break;
                end

                value = value{1};
            end

            if isempty(value)
                output = string(defaultValue);
                return;
            end

            if isstring(value)
                if all(ismissing(value))
                    output = string(defaultValue);
                    return;
                end

                output = strtrim(value(1));
            elseif ischar(value)
                output = string(strtrim(value));
            else
                output = string(value);
            end

            if strlength(output) == 0
                output = string(defaultValue);
            end
        end

        %-----------------------------------------------------------------%
        function output = toNullableText(obj, rawValue)
            % Campos textuais opcionais do payload usam [] quando vazios.
            value = obj.toText(rawValue, "");

            if strlength(value) == 0
                output = [];
            else
                output = value;
            end
        end

        %-----------------------------------------------------------------%
        function output = toNullableValue(~, rawValue)
            % Preserva o valor original quando existir e usa [] para ausentes.
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    output = [];
                    return;
                end

                value = value{1};
            end

            if isempty(value)
                output = [];
                return;
            end

            if isstring(value) && all(ismissing(value))
                output = [];
                return;
            end

            output = value;
        end

        %-----------------------------------------------------------------%
        function output = chooseStationName(obj, hostName, equipmentName)
            % O mapa prefere host_name; se nao existir, cai para equipment_name.
            output = obj.toText(hostName, "");

            if strlength(output) == 0
                output = obj.toText(equipmentName, "");
            end
        end

        %-----------------------------------------------------------------%
        function output = buildSpectrumWhereConditions(obj, filters, includeSpectrumOnlyFilters)
            output = "";

            equipmentId = obj.getStructField(filters, 'equipmentId');
            siteId      = obj.getStructField(filters, 'siteId');
            districtId  = obj.getStructField(filters, 'districtId');
            startDate   = obj.getStructField(filters, 'startDate');
            endDate     = obj.getStructField(filters, 'endDate');
            stateCode   = obj.toText(obj.getStructField(filters, 'stateCode'), '');
            % Escapa aspas simples para evitar injeção SQL.
            stateCode   = replace(stateCode, "'", "''");

            equipmentId = obj.toDouble(equipmentId);
            siteId      = obj.toDouble(siteId);
            districtId  = obj.toDouble(districtId);

            if ~isnan(equipmentId)
                output = output + " AND f.FK_EQUIPMENT = " + string(round(equipmentId));
            end

            if ~isnan(siteId)
                output = output + " AND f.FK_SITE = " + string(round(siteId));
            end

            if ~isnan(districtId)
                output = output + " AND f.FK_SITE IN (SELECT ID_SITE FROM RFDATA.DIM_SPECTRUM_SITE WHERE FK_DISTRICT = " + string(round(districtId)) + ")";
            end

            % O alias 'st' já existe nas queries que chamam este método via JOIN
            % com DIM_SITE_STATE. Para o COUNT que não tem esse JOIN, o filtro de
            % estado é injetado como subquery — ver getSpectrumFileDataCount.
            if strlength(stateCode) > 0
                output = output + " AND st.LC_STATE = '" + stateCode + "'";
            end

            startDateSql = obj.toSQLDate(startDate, 'start');
            if strlength(startDateSql) > 0
                output = output + " AND f.DT_TIME_END >= '" + startDateSql + "'";
            end

            endDateSql = obj.toSQLDate(endDate, 'end');
            if strlength(endDateSql) > 0
                output = output + " AND f.DT_TIME_START <= '" + endDateSql + "'";
            end

            if includeSpectrumOnlyFilters
                freqStart = obj.toDouble(obj.getStructField(filters, 'freqStart'));
                freqEnd = obj.toDouble(obj.getStructField(filters, 'freqEnd'));
                description = obj.buildSQLLikePattern(obj.getStructField(filters, 'description'));

                if ~isnan(freqStart) && (freqStart < 0)
                    freqStart = NaN;
                end

                if ~isnan(freqEnd) && (freqEnd < 0)
                    freqEnd = NaN;
                end

                if ~isnan(freqStart)
                    output = output + " AND f.NU_FREQ_START >= " + string(freqStart);
                end

                if ~isnan(freqEnd)
                    output = output + " AND f.NU_FREQ_END <= " + string(freqEnd);
                end

                if strlength(description) > 0
                    output = output + " AND UPPER(COALESCE(f.NA_DESCRIPTION, '')) LIKE UPPER('" + description + "')";
                end
            end
        end

        %-----------------------------------------------------------------%
        function output = buildSpectrumLocalitySql(~)
            output = ...
                "COALESCE(" + ...
                "NULLIF(s.NA_SITE, ''), " + ...
                "NULLIF(d.NA_DISTRICT, ''), " + ...
                "c.NA_COUNTY, " + ...
                "CONCAT('Site ', s.ID_SITE)" + ...
                ")";
        end

        %-----------------------------------------------------------------%
        function output = buildSQLLikePattern(~, rawValue)
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    output = "";
                    return;
                end
                value = value{1};
            end

            output = strip(string(value));

            if isempty(output) || all(ismissing(output))
                output = "";
                return;
            end

            output = output(1);
            if strlength(output) == 0
                output = "";
                return;
            end

            output = replace(output, "'", "''");

            if ~any(contains(output, "%")) && ~any(contains(output, "_"))
                output = "%" + output + "%";
            end
        end

        %-----------------------------------------------------------------%
        function output = toSQLDate(~, rawValue, boundary)
            output = "";

            if nargin < 3
                boundary = 'start';
            end

            value = rawValue;

            while iscell(value)
                if isempty(value)
                    return;
                end
                value = value{1};
            end

            if isempty(value)
                return;
            end

            try
                if ~isdatetime(value)
                    value = datetime(value);
                end
            catch
                return;
            end

            if isnat(value)
                return;
            end

            value = dateshift(value(1), 'start', 'day');
            if isequal(boundary, 'end')
                value = value + days(1) - seconds(1);
            end

            output = string(value, 'yyyy-MM-dd HH:mm:ss');
        end

        %-----------------------------------------------------------------%
        function output = getStructField(~, inputStruct, fieldName)
            output = [];

            if ~isstruct(inputStruct) || ~isfield(inputStruct, fieldName)
                return;
            end

            output = inputStruct.(fieldName);
        end

        %-----------------------------------------------------------------%
        function [pageSize, offset] = getPaginationInfo(obj, filters)
            page = obj.toDouble(obj.getStructField(filters, 'page'));
            pageSize = obj.toDouble(obj.getStructField(filters, 'pageSize'));

            if isnan(page) || (page < 1)
                page = 1;
            end

            if isnan(pageSize) || (pageSize < 1)
                pageSize = 50;
            end

            page = round(page);
            pageSize = round(pageSize);
            offset = (page - 1) * pageSize;
        end

        %-----------------------------------------------------------------%
        function output = readCountValue(obj, rows)
            output = 0;

            if ~istable(rows) || isempty(rows)
                return;
            end

            if ismember('TOTAL_COUNT', rows.Properties.VariableNames)
                output = obj.toDouble(rows.TOTAL_COUNT(1));
            elseif width(rows) >= 1
                output = obj.toDouble(rows{1, 1});
            end

            if isnan(output)
                output = 0;
            end

            output = max(0, round(output));
        end
    end
end

