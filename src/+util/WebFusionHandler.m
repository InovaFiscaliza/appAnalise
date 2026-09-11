classdef WebFusionHandler < handle
    % Consome a API REST do WebFusion mantendo a interface pública do DBHandler.
    %
    % Propriedades principais:
    %   Settings        - Configurações REPOSFI recebidas do aplicativo.
    %   BaseUrl         - Raiz HTTP(S), incluindo o sufixo /rffusion.
    %   Timeout         - Tempo máximo de espera de cada requisição, em segundos.
    %   CacheFolder     - Pasta do cache local do mapa.
    %   CacheData       - Estrutura com os vetores de pontos e detalhes de sites.
    %   CacheUpdatedAt  - Data/hora do cache no formato HH:MM:SS dd/mm/yyyy.
    %   CacheSession    - Cache em memória das consultas por tipo e filtros.

    properties (Access = public)
        %-----------------------------------------------------------------%
        Settings

        CacheFolder = struct('points', [], 'siteDetails', []);
        CacheData
        CacheUpdatedAt
        CacheSession = struct('requestType', {}, 'filterHash', {}, 'resultData', {}, 'updatedAt', {})
        BaseUrl
        Timeout

    end

    properties (Constant)
        %-----------------------------------------------------------------%
        CACHE_FILE_NAME = 'RepoSFI.mat'
        CACHE_TTL_HOURS = 12
        CONNECTION_TIMEOUT_SECONDS = 25


        PUBLIC_BASE_URL = 'https://fiscalizacao.anatel.gov.br/rffusion'
        INTERNAL_HOST_BASE_URL = 'http://rhfisnspdex02.anatel.gov.br:9082/rffusion'
        API_PREFIX = '/api/appanalise'
        MAP_PATH = '/api/map/stations'
        HTTP_TIMEOUT = 25;
        MAX_API_PAGE_SIZE = 1000
    end


    properties (Access = private)
        HostChecked = false
    end


    methods
        function [obj, warningMsg] = WebFusionHandler(generalSettings)
            % Inicializa o cliente REST e atualiza, quando possível, o cache do mapa.
            % Entrada:
            %   generalSettings - Estrutura geral do aplicativo; usa context.REPOSFI.
            % Saídas:
            %   obj        - Instância configurada do cliente.
            %   warningMsg - Mensagem de falha na atualização do mapa; quando houver
            %                cache local, ele é usado como contingência.

            % Carrega constantes do projeto
            obj.Settings = generalSettings.context.REPOSFI;
            warningMsg = '';

            % Tentativa de obter TABELA DE SENSORES, que suporta a visualização
            % principal em mapa do módulo em auxApp.winRepoSFI e o seu popup.
            % As outras tabelas serão requeridas diretamente da BASE DE DADOS,
            % filtradas com valores inseridos na GUI.
            obj.CacheFolder = fullfile(appEngine.util.OperationSystem('programData'), 'ANATEL', class.Constants.appName, 'DataBase');
            obj.BaseUrl = char(obj.INTERNAL_HOST_BASE_URL);
            obj.Timeout = obj.HTTP_TIMEOUT;

            if isCacheValid(obj)
                getCache(obj)

            else
                try
                    [points, siteDetails] = getMapDataSet(obj);
                    if isempty(points) || isempty(siteDetails)
                        error('util:WebFusionHandler:UnexpectedEmptyData', 'Unexpected empty data')
                    end

                    obj.CacheData.points = points;
                    obj.CacheData.siteDetails = siteDetails;
                    obj.CacheUpdatedAt = datestr(now, 'HH:MM:SS dd/mm/yyyy');
                    saveCache(obj)

                catch ME
                    warningMsg = ME.message;
                    getCache(obj)
                end
            end
        end

        function isValid = isCacheValid(obj)
            % Verifica se o cache do mapa existe e ainda está dentro do TTL.
            %
            % Entrada:
            %   obj - Cliente que define CacheFolder, CACHE_FILE_NAME e TTL.
            % Saída:
            %   isValid - true quando RepoSFI.mat existe e não expirou.
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

        function saveCache(obj)
            % Persiste o mapa atualmente carregado no cache local.
            %
            % Entrada:
            %   obj - Cliente com CacheData.points, CacheData.siteDetails e
            %         CacheUpdatedAt preenchidos.
            % Saída:
            %   Nenhuma. Salva RepoSFI.mat na pasta de cache.
            cacheFile = fullfile(obj.CacheFolder, obj.CACHE_FILE_NAME);

            points = obj.CacheData.points;
            siteDetails = obj.CacheData.siteDetails;
            cacheUpdatedAt = obj.CacheUpdatedAt;

            save(cacheFile, 'points', 'siteDetails', 'cacheUpdatedAt', '-mat', '-v7')
        end

        function getCache(obj)
            % Carrega o mapa do cache local quando o arquivo estiver disponível.
            %
            % Entrada:
            %   obj - Cliente que define a localização do arquivo de cache.
            % Saída:
            %   Nenhuma. Atualiza CacheData e CacheUpdatedAt quando a leitura é válida.
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
        function saveSessionCache(obj, requestType, filters, resultData)
            % Inclui o resultado de uma consulta no cache de sessão.
            %
            % Entrada:
            %   requestType - Tipo da consulta, como 'files' ou 'count'.
            %   filters     - Filtros normalizados que identificam a consulta.
            %   resultData  - Tabela ou resultado a ser reutilizado.
            % Saída:
            %   Nenhuma. Acrescenta uma entrada em CacheSession.
            arguments
                obj
                requestType {mustBeMember(requestType, {'count', 'files', 'fileDetails', 'stationSummary', 'hostStats', 'equipments', 'states', 'localities'})}
                filters
                resultData
            end

            filterHash = computeFilterHash(obj, filters);
            obj.CacheSession(end+1) = struct( ...
                'requestType', requestType, ...
                'filterHash', filterHash, ...
                'resultData', resultData, ...
                'updatedAt', datestr(now, 'HH:MM:SS dd/mm/yyyy') ...
                );
        end

        %-----------------------------------------------------------------%
        function filterHashIdx = getSessionCache(obj, requestType, filters)
            % Localiza uma entrada não expirada no cache de sessão.
            %
            % Entrada:
            %   requestType - Tipo da consulta procurada.
            %   filters     - Filtros usados para gerar a chave da consulta.
            % Saída:
            %   filterHashIdx - Índice da entrada válida ou [] se ela não existir/expirou.
            arguments
                obj
                requestType {mustBeMember(requestType, {'count', 'files', 'fileDetails', 'stationSummary', 'hostStats', 'equipments', 'states', 'localities'})}
                filters
            end

            if isempty(obj.CacheSession)
                filterHashIdx = [];
                return;
            end

            filterHash = computeFilterHash(obj, filters);
            hashMatches = strcmp(filterHash, {obj.CacheSession.filterHash});
            typeMatches = strcmp(requestType, {obj.CacheSession.requestType});
            filterHashIdx = find(hashMatches & typeMatches, 1);

            if ~isempty(filterHashIdx)
                cacheEntry = obj.CacheSession(filterHashIdx);
                cacheUpdatedAt = datetime(cacheEntry.updatedAt, 'InputFormat', 'HH:mm:ss dd/MM/yyyy');

                if hours(datetime('now') - cacheUpdatedAt) > obj.CACHE_TTL_HOURS
                    filterHashIdx = [];
                    return;
                end
            end
        end

        %-----------------------------------------------------------------%
        function filterHash = computeFilterHash(~, filters)
            % Gera uma chave estável para os filtros de uma consulta.
            %
            % Entrada:
            %   filters - Estrutura de filtros; NaN e NaT são desconsiderados.
            % Saída:
            %   filterHash - Hash SHA-1 do JSON que representa os filtros úteis.
            filterFields = fieldnames(filters);
            hashFilters = struct();
            for ii = 1:numel(filterFields)
                field = filterFields{ii};
                value = filters.(field);

                if (isnumeric(value) && all(isnan(value))) || (isdatetime(value) && isnat(value))
                    continue;
                end
                if ischar(value) || isstring(value)
                    hashFilters.(field) = string(value);
                else
                    hashFilters.(field) = value;
                end
            end

            filterHash = Hash.sha1(jsonencode(hashFilters));
        end

        function output = getStationSummary(obj)
            % Obtém o resumo de estações/localidades, diferente do conjunto do mapa.
            %
            % GET /api/appanalise/stations/summary
            % Entrada:
            %   obj - Cliente REST configurado.
            % Saída:
            %   output - Tabela tipada com as colunas retornadas pela API.
            output = obj.cachedTable('stationSummary', struct(), '/stations/summary', 'GET');
        end

        function output = getHostStats(obj, hostId)
            % Obtém identidade e estatísticas de um host, com os nomes legados.
            %
            % GET /api/appanalise/hosts/{hostId}/stats
            % Entrada:
            %   hostId - Identificador positivo do host.
            % Saída:
            %   output - Tabela com zero ou uma linha de estatísticas.
            path = ['/hosts/' obj.identifier(hostId) '/stats'];
            output = obj.cachedTable('hostStats', struct('hostId', hostId), path, 'GET');
        end

        function output = getSpectrumEquipments(obj, filters)
            % Obtém as opções de equipamentos no recorte geográfico informado.
            %
            % POST /api/appanalise/equipments
            % Corpo JSON: filtros opcionais stateCode, siteId e districtId.
            % Exemplo: struct('stateCode', 'AM', 'districtId', 7).
            % Campos vazios, NaN, NaT, texto em branco, location e receiver não
            % são enviados; location/receiver são valores exclusivos da interface.
            %
            % Entrada:
            %   filters - Estrutura opcional com os filtros do recorte geográfico.
            % Saída:
            %   output - Tabela com ID_EQUIPMENT e NA_EQUIPMENT.
            if nargin < 2, filters = struct(); end
            output = obj.cachedTable('equipments', filters, '/equipments', 'POST');
        end

        function output = getSpectrumStates(obj, filters)
            % Obtém as UF disponíveis para o equipamento e/ou site informado.
            %
            % POST /api/appanalise/states
            % Corpo JSON: filtros opcionais equipmentId e siteId.
            % Exemplo: struct('equipmentId', 56, 'siteId', 12).
            %
            % Entrada:
            %   filters - Estrutura opcional com equipmentId e/ou siteId.
            % Saída:
            %   output - Tabela com a coluna LC_STATE, mesmo quando vazia.
            if nargin < 2, filters = struct(); end
            output = obj.cachedTable('states', filters, '/states', 'POST');
        end

        function output = getSpectrumLocalities(obj, equipmentId, filters)
            % Obtém localidades; o equipmentId explícito tem precedência.
            %
            % POST /api/appanalise/localities
            % Corpo JSON: equipmentId e/ou stateCode. O método não requisita a API
            % se ambos estiverem ausentes após a normalização dos filtros.
            %
            % Entrada:
            %   equipmentId - Identificador positivo, NaN ou [] quando ausente.
            %   filters     - Estrutura opcional; stateCode pode definir o recorte.
            % Saída:
            %   output - Tabela de localidades ou tabela vazia sem recorte aplicável.
            if nargin < 3, filters = struct(); end
            filters.equipmentId = equipmentId;
            filters = obj.prepareFilters(filters);
            if ~isfield(filters, 'equipmentId') && ~isfield(filters, 'stateCode')
                output = table();
                return;
            end
            output = obj.cachedTable('localities', filters, '/localities', 'POST');
        end

        function output = getSpectrumFileData(obj, filters)
            % Obtém uma página de arquivos, incluindo uma linha extra de antecipação.
            %
            % POST /api/appanalise/files
            % Corpo JSON: equipmentId, siteId, districtId, stateCode, startDate,
            % endDate, freqStart, freqEnd, description, page e pageSize.
            % startDate/endDate são convertidos para AAAA-MM-DD. Campos ausentes
            % não são serializados. location e receiver são descartados; os filtros
            % equivalentes enviados à API são districtId e equipmentId.
            %
            % Entrada:
            %   filters - Estrutura opcional com os campos listados para o corpo JSON.
            % Saída:
            %   output - Tabela de arquivos com até pageSize + 1 linhas.
            if nargin < 2, filters = struct(); end
            filters = obj.prepareFilters(filters);
            if ~isfield(filters, 'pageSize') || filters.pageSize <= obj.MAX_API_PAGE_SIZE
                output = obj.cachedTable('files', filters, '/files', 'POST');
                return;
            end

            % A API limita pageSize a MAX_API_PAGE_SIZE. Quando a interface pede
            % todos os arquivos encontrados, divide a leitura em páginas REST sem
            % alterar o deslocamento lógico solicitado pela tela.
            output = obj.getLargeSpectrumFilePage(filters);
        end

        function output = getSpectraByFileId(obj, fileId)
            % Obtém todos os espectros associados a um arquivo do repositório.
            %
            % GET /api/appanalise/files/{fileId}/spectra
            % Entrada:
            %   fileId - Identificador positivo do arquivo.
            % Saída:
            %   output - Tabela de espectros associados ao arquivo.
            path = ['/files/' obj.identifier(fileId) '/spectra'];
            output = obj.cachedTable('fileDetails', struct('fileId', fileId), path, 'GET');
        end

        function output = getSpectrumFileDataCount(obj, filters)
            % Conta os arquivos do filtro sem transferir suas linhas.
            %
            % Entrada:
            %   filters - Estrutura opcional com os filtros de arquivos.
            % Saída:
            %   output - Quantidade inteira não negativa de arquivos encontrados.
            if nargin < 2, filters = struct(); end
            filters = obj.prepareFilters(filters);
            index = obj.getSessionCache('count', filters);
            if ~isempty(index)
                output = obj.CacheSession(index).resultData.TOTAL_COUNT(1);
                return;
            end
            
            % POST /api/appanalise/files/count
            % Corpo JSON: equipmentId, siteId, districtId, stateCode, startDate,
            % endDate, freqStart, freqEnd e description, quando definidos.
            % page/pageSize, se recebidos, não afetam a contagem. location e receiver
            % são removidos por prepareFilters; para o filtro da tela atual, por
            % exemplo, {stateCode:'AM', receiver:'RFEye002295', equipmentId:56}
            % torna-se {stateCode:'AM', equipmentId:56}.
            payload = obj.requestJSON('POST', [obj.API_PREFIX '/files/count'], filters);
            if ~isstruct(payload) || ~isscalar(payload) || ~isfield(payload, 'count')
                error('WebFusionHandler:InvalidResponse', 'Expected a count object.');
            end
            
            output = payload.count;
            
            validateattributes(output, {'numeric'}, {'scalar', 'finite', 'integer', 'nonnegative'});
            
            output = double(output);
            obj.saveSessionCache('count', filters, table(output, 'VariableNames', {'TOTAL_COUNT'}));
        end

        function [points, siteDetails] = getMapDataSet(obj)
            % Obtém o conjunto compartilhado do mapa e normaliza arrays, nulos e datas.
            % GET /api/map/stations?include_details=true
            % Retorna os struct-arrays coluna points e siteDetails no formato do DBHandler.
            %
            % Entrada:
            %   obj - Cliente REST configurado.
            % Saídas:
            %   points      - Pontos geográficos dos sites.
            %   siteDetails - Detalhes e estações de cada site.
            payload = obj.requestJSON('GET', [obj.MAP_PATH '?include_details=true'], struct());
            
            if ~isstruct(payload) || ~isscalar(payload) || ...
                    ~all(isfield(payload, {'points', 'site_details'}))
                error('WebFusionHandler:InvalidResponse', 'Expected points and site_details.');
            end
            
            points = obj.mapRecords(payload.points, 'point');
            siteDetails = obj.mapRecords(payload.site_details, 'siteDetail');
            
            if ~isequal([points.site_id], [siteDetails.site_id])
                error('WebFusionHandler:InvalidResponse', 'Map points and details do not match.');
            end
        end

        function output = getSummarySiteRows(obj)
            % Adapta os pontos compartilhados do mapa à tabela legada de sites.
            % São valores consolidados do mapa, não uma nova consulta de resumo bruto.
            %
            % Entrada:
            %   obj - Cliente REST configurado.
            % Saída:
            %   output - Tabela com os aliases legados de sites do DBHandler.
            [points, ~] = obj.getMapDataSet();
            mapping = {'ID_SITE','site_id'; 'SITE_LABEL','site_label'; ...
                'COUNTY_NAME','county_name'; 'ID_DISTRICT','district_id'; ...
                'DISTRICT_NAME','district_name'; 'ID_STATE','state_id'; ...
                'NA_STATE','state_name'; 'LC_STATE','state_code'; ...
                'VL_LATITUDE','latitude'; 'VL_LONGITUDE','longitude'; ...
                'VL_ALTITUDE','altitude'; 'NU_GNSS_MEASUREMENTS','gnss_measurements'; ...
                'NA_MARKER_STATE','marker_state'; 'HAS_ONLINE_STATION','has_online_station'; ...
                'HAS_ONLINE_HOST','has_online_host'; 'HAS_KNOWN_HOST','has_known_host'};
            output = obj.mappedTable(points, mapping);
        end

        function output = getSummaryStationRows(obj)
            % Adapta os detalhes das estações à tabela legada de estações.
            % A saída contém IDs, nomes, flags, estado do mapa, datas e contagem.
            %
            % Entrada:
            %   obj - Cliente REST configurado.
            % Saída:
            %   output - Tabela com os aliases legados de estações do DBHandler.
            [~, details] = obj.getMapDataSet();
            rows = struct([]);
            
            for ii = 1:numel(details)
                for jj = 1:numel(details(ii).stations)
                    row = details(ii).stations(jj);
                    row.site_id = details(ii).site_id;
                    rows(end+1, 1) = row; %#ok<AGROW>
                end
            end

            mapping = {'ID_SITE','site_id'; 'ID_EQUIPMENT','equipment_id'; ...
                'ID_HOST','host_id'; 'NA_EQUIPMENT','equipment_name'; ...
                'NA_HOST_NAME','host_name'; 'IS_OFFLINE','is_offline'; ...
                'IS_CURRENT_LOCATION','is_current_location'; 'NA_MAP_STATE','map_state'; ...
                'FIRST_SEEN_AT','first_seen_at'; 'LAST_SEEN_AT','last_seen_at'; ...
                'NU_SPECTRUM_COUNT','spectrum_count'};
            
            output = obj.mappedTable(rows, mapping);
        end
    end

    methods (Access = protected)
        function payload = requestJSON(obj, method, path, filters)
            % Executa uma requisição REST e decodifica a resposta JSON.
            %
            % Para POST, filters é exatamente o corpo JSON já normalizado por
            % prepareFilters. Portanto, nunca deve conter NaN, NaT, texto vazio,
            % location ou receiver. A URL final é [obj.BaseUrl path].
            %
            % Entrada:
            %   method  - 'GET' ou 'POST'.
            %   path    - Caminho relativo da rota REST.
            %   filters - Estrutura escalar serializada somente no POST.
            % Saída:
            %   payload - Objeto JSON convertido pelo jsondecode.
            options = weboptions('ContentType', 'text', 'Timeout', obj.Timeout, ...
                'MediaType', 'application/json', 'CharacterEncoding', 'UTF-8');
            url = [obj.BaseUrl char(path)];
            switch method
                case 'GET'
                    raw = webread(url, options);
                case 'POST'
                    % Envia Content-Type application/json e o conteúdo de filters
                    % como corpo da requisição; não há parâmetros na URL.
                    raw = webwrite(url, filters, options);
                otherwise
                    error('WebFusionHandler:InvalidMethod', 'Only GET and POST are supported.');
            end
            try
                payload = jsondecode(raw);
            catch
                error('WebFusionHandler:InvalidResponse', ...
                    'Expected a JSON response from the configured WebFusion URL.');
            end
            if isstruct(payload) && isscalar(payload) && isfield(payload, 'error')
                error('WebFusionHandler:APIError', 'WebFusion returned an API error.');
            end
        end
    end

    methods (Access = private)
        function output = getLargeSpectrumFilePage(obj, filters)
            % Reúne páginas REST quando a quantidade solicitada excede o limite da API.
            %
            % A API retorna pageSize + 1 linhas: a última é a antecipação da próxima
            % página. Cada lote intermediário é limitado a pageSize antes da união,
            % pois essa linha reaparece como a primeira linha do lote seguinte.
            %
            % Entrada:
            %   filters - Filtros normalizados com pageSize maior que MAX_API_PAGE_SIZE.
            % Saída:
            %   output - Tabela iniciada na página lógica solicitada, sem duplicatas.
            validateattributes(filters.pageSize, {'numeric'}, ...
                {'scalar', 'integer', 'positive'});
            requestedPageSize = filters.pageSize;
            requestedPage = 1;
            if isfield(filters, 'page')
                requestedPage = filters.page;
            end
            validateattributes(requestedPage, {'numeric'}, ...
                {'scalar', 'integer', 'positive'});

            % page/pageSize da tela formam o deslocamento lógico desejado. As novas
            % requisições usam páginas fixas de 1.000 registros para respeitar a API.
            startOffset = (requestedPage - 1) * requestedPageSize;
            apiPage = floor(startOffset / obj.MAX_API_PAGE_SIZE) + 1;
            firstRow = mod(startOffset, obj.MAX_API_PAGE_SIZE) + 1;
            rowsNeeded = firstRow - 1 + requestedPageSize + 1;
            pageRows = table();

            while height(pageRows) < rowsNeeded
                pageFilters = filters;
                pageFilters.page = apiPage;
                pageFilters.pageSize = obj.MAX_API_PAGE_SIZE;
                currentPage = obj.cachedTable('files', pageFilters, '/files', 'POST');

                % Descarta somente a linha de antecipação; ela será obtida na página
                % seguinte com o mesmo ordenamento e sem sobreposição.
                if height(currentPage) > obj.MAX_API_PAGE_SIZE
                    currentPage = currentPage(1:obj.MAX_API_PAGE_SIZE, :);
                end
                if isempty(pageRows)
                    pageRows = currentPage;
                else
                    pageRows = [pageRows; currentPage]; %#ok<AGROW>
                end

                if height(currentPage) < obj.MAX_API_PAGE_SIZE
                    break;
                end
                apiPage = apiPage + 1;
            end

            lastRow = min(height(pageRows), firstRow - 1 + requestedPageSize + 1);
            output = pageRows(firstRow:lastRow, :);
        end

        function output = cachedTable(obj, requestType, filters, path, method)
            % Reutiliza uma tabela em cache ou a obtém em uma rota da API.
            % Os filtros são normalizados antes de calcular a chave do cache e antes
            % do POST, garantindo que o cache represente o corpo realmente enviado.
            %
            % Entrada:
            %   requestType - Tipo usado como chave do cache de sessão.
            %   filters     - Estrutura de filtros recebida pelo método público.
            %   path        - Caminho após /api/appanalise.
            %   method      - Método HTTP da rota, 'GET' ou 'POST'.
            % Saída:
            %   output - Tabela MATLAB tipada, vinda do cache ou da API.
            filters = obj.prepareFilters(filters);
            index = obj.getSessionCache(requestType, filters);
            if ~isempty(index)
                output = obj.CacheSession(index).resultData;
                return;
            end
            % Nos POSTs, o corpo é a estrutura filters normalizada acima. A rota
            % específica e seus campos esperados são documentados no método público
            % que chamou esta rotina.
            payload = obj.requestJSON(method, [obj.API_PREFIX path], filters);
            output = obj.decodeTable(payload);
            if ~isempty(output)
                obj.saveSessionCache(requestType, filters, output);
            end
        end

        function data = readDiskCache(obj)
            % Lê apenas as variáveis do mapa e valida a identidade do cache local.
            %
            % Entrada:
            %   obj - Cliente que define o caminho e a URL associados ao cache.
            % Saída:
            %   data - Estrutura com points, siteDetails, cacheUpdatedAt e baseUrl.
            data = load(fullfile(obj.CacheFolder, obj.CACHE_FILE_NAME), ...
                'points', 'siteDetails', 'cacheUpdatedAt', 'baseUrl');
            if ~all(isfield(data, {'points','siteDetails','cacheUpdatedAt','baseUrl'})) || ...
                    ~strcmp(data.baseUrl, obj.BaseUrl) || ...
                    ~isstruct(data.points) || ~isstruct(data.siteDetails) || ...
                    ~all(isfield(data.points, fieldnames(obj.mapModel('point')))) || ...
                    ~all(isfield(data.siteDetails, fieldnames(obj.mapModel('siteDetail'))))
                error('WebFusionHandler:CacheMismatch', 'Invalid cache or different WebFusion endpoint.');
            end
        end
    end

    methods (Static, Access = private)
        function filters = prepareFilters(filters)
            % Prepara a estrutura de filtros para o corpo JSON da API.
            %
            % Remove []/NaN/NaT/missing/texto em branco e converte datetime para
            % AAAA-MM-DD, sem aplicar conversão de fuso horário. location e receiver
            % descrevem controles da interface e são removidos: seus identificadores
            % districtId e equipmentId, quando existentes, são os filtros REST.
            % A estrutura resultante usa os nomes camelCase definidos pela API.
            %
            % Entrada:
            %   filters - Estrutura escalar de filtros recebida da interface.
            % Saída:
            %   filters - Estrutura compatível com JSON, pronta para o corpo do POST.
            validateattributes(filters, {'struct'}, {'scalar'});
            % Não remove campos da entrada: constrói um novo corpo JSON abaixo.
            fields = fieldnames(filters);
            normalizedFilters = struct();
            for ii = 1:numel(fields)
                name = fields{ii};
                value = filters.(name);

                % Campos textuais usados apenas pela tela não pertencem ao contrato REST.
                if ismember(name, {'location', 'receiver'})
                    continue;
                end
                if isempty(value) || all(ismissing(value), 'all')
                    continue;
                end
                if any(ismissing(value), 'all')
                    error('WebFusionHandler:InvalidFilter', 'Partially missing filter: %s.', name);
                end
                if isdatetime(value)
                    if ~isscalar(value)
                        error('WebFusionHandler:InvalidFilter', 'Date filter must be scalar: %s.', name);
                    end
                    normalizedFilters.(name) = char(string(value, 'yyyy-MM-dd'));
                    continue;
                end

                if ischar(value) || isstring(value)
                    value = strip(string(value));
                    if ~isscalar(value)
                        error('WebFusionHandler:InvalidFilter', 'Text filter must be scalar: %s.', name);
                    end
                    if strlength(value) == 0
                        continue;
                    else
                        normalizedFilters.(name) = char(value);
                    end
                    continue;
                end

                if islogical(value)
                    normalizedFilters.(name) = value;
                    continue;
                end

                % Para os tipos restantes, a API aceita somente números reais e finitos.
                % validateattributes também identifica tipos não numéricos neste ponto.
                validateattributes(value, {'numeric'}, {'real', 'finite'});
                normalizedFilters.(name) = value;
            end
            filters = normalizedFilters;
        end

        function output = identifier(value)
            % Converte um identificador positivo em texto decimal para uso na URL.
            %
            % Entrada:
            %   value - Número inteiro, positivo e representável com precisão.
            % Saída:
            %   output - Vetor char decimal, sem notação científica.
            validateattributes(value, {'numeric'}, {'scalar','real','finite','integer','positive','<=',flintmax});
            output = sprintf('%.0f', value);
        end

        function rows = recordArray(rows)
            % Normaliza um array JSON de objetos em um struct-array coluna.
            %
            % Entrada:
            %   rows - Struct-array, célula de structs escalares ou array vazio.
            % Saída:
            %   rows - Struct-array coluna; objetos com campos distintos são rejeitados.
            if isempty(rows)
                rows = struct([]);
                return;
            end

            if iscell(rows)
                % jsondecode pode retornar célula quando os objetos JSON têm
                % formatos diferentes. MATLAB não concatena structs com campos
                % distintos, por isso o contrato é validado antes do vertcat.
                if ~isvector(rows) || ~all(cellfun(@(x) isstruct(x) && isscalar(x), rows(:)))
                    error('WebFusionHandler:InvalidResponse', ...
                        'Expected an array of JSON objects.');
                end
                fields = cellfun(@(x) sort(fieldnames(x)), rows(:), 'UniformOutput', false);
                if ~all(cellfun(@(x) isequal(x, fields{1}), fields))
                    error('WebFusionHandler:InvalidResponse', ...
                        'JSON objects in an array must contain the same fields.');
                end
                rows = vertcat(rows{:});
            end

            if ~isstruct(rows) || ~isvector(rows)
                error('WebFusionHandler:InvalidResponse', 'Expected an array of JSON objects.');
            end
            rows = rows(:);
        end

        function output = decodeTable(payload)
            % Constrói uma tabela MATLAB tipada a partir do envelope JSON da API.
            % Cada coluna é processada separadamente para preservar linhas únicas,
            % vazias e nulos: número->NaN, texto->missing e data->NaT.
            %
            % Entrada:
            %   payload - Estrutura com os campos columns e rows retornados pela API.
            % Saída:
            %   output - Tabela MATLAB com uma coluna tipada para cada alias recebido.
            if ~isstruct(payload) || ~isscalar(payload) || ~all(isfield(payload, {'columns','rows'}))
                error('WebFusionHandler:InvalidResponse', 'Expected columns and rows.');
            end
            names = cellstr(string(payload.columns(:)));
            if numel(unique(names)) ~= numel(names) || ~all(cellfun(@isvarname, names))
                error('WebFusionHandler:InvalidResponse', 'Invalid or duplicate table columns.');
            end
            rows = util.WebFusionHandler.recordArray(payload.rows);
            output = table();
            for ii = 1:numel(names)
                name = names{ii};
                if ~isempty(rows) && ~all(isfield(rows, name))
                    error('WebFusionHandler:InvalidResponse', 'Missing table column: %s.', name);
                end
                values = cell(numel(rows), 1);
                for jj = 1:numel(rows), values{jj} = rows(jj).(name); end
                output.(name) = util.WebFusionHandler.tableColumn(name, values);
            end
        end

        function output = tableColumn(name, values)
            % Aplica as convenções de tipos do banco às células decodificadas.
            %
            % Entrada:
            %   name   - Alias da coluna retornado pela API.
            %   values - Células escalares de uma coluna da resposta.
            % Saída:
            %   output - Vetor datetime, double ou string conforme o alias.
            columnKind = 'text';
            if startsWith(name, {'DT_', 'DATE_'}) || ...
                    any(strcmp(name, {'FIRST_SEEN_AT', 'LAST_SEEN_AT'}))
                columnKind = 'date';
            end
            if startsWith(name, {'ID_', 'FK_', 'NU_', 'VL_', 'IS_', 'HAS_'}) || ...
                    endsWith(name, '_COUNT') || strcmp(name, 'NA_HOST_PORT')
                columnKind = 'numeric';
            end

            switch columnKind
                case 'date'
                    output = NaT(numel(values), 1);
                case 'numeric'
                    output = NaN(numel(values), 1);
                otherwise
                    output = strings(numel(values), 1);
                    output(:) = missing;
            end
            for ii = 1:numel(values)
                value = values{ii};
                if util.WebFusionHandler.isNull(value), continue; end
                switch columnKind
                    case 'date'
                        output(ii) = util.WebFusionHandler.parseDate(value);
                    case 'numeric'
                        % Esta validação protege a fronteira de entrada da API.
                        % prepareFilters valida somente o corpo enviado pelo cliente.
                        validateattributes(value, {'numeric','logical'}, {'scalar','real','finite'});
                        output(ii) = double(value);
                    otherwise
                        if ~(ischar(value) || (isstring(value) && isscalar(value)))
                            error('WebFusionHandler:InvalidResponse', 'Expected text in %s.', name);
                        end
                        output(ii) = string(value);
                end
            end
        end

        function value = parseDate(value)
            % Converte datas ISO (ou HTTP date) sem acrescentar fuso horário.
            %
            % Entrada:
            %   value - datetime ou texto de data/hora não nulo.
            % Saída:
            %   value - datetime escalar que preserva a hora informada pela API.
            if isdatetime(value), return; end
            value = string(value);
            if ~isscalar(value)
                error('WebFusionHandler:InvalidResponse', 'Expected a scalar date.');
            end
            if contains(value, ',')
                value = datetime(value, 'InputFormat', "eee, dd MMM yyyy HH:mm:ss 'GMT'", 'Locale', 'en_US');
                return;
            end
            if strlength(value) == 10
                value = datetime(value, 'InputFormat', 'yyyy-MM-dd');
                return;
            end
            if contains(value, '.')
                value = datetime(value, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
                return;
            end
            value = datetime(value, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss");
        end

        function output = isNull(value)
            % Identifica as representações de null do jsondecode sem considerar
            % texto vazio como nulo.
            %
            % Entrada:
            %   value - Valor escalar ou vazio decodificado do JSON.
            % Saída:
            %   output - true quando value representa null.
            output = (isempty(value) && ~ischar(value)) || ...
                ((isnumeric(value) || isstring(value) || isdatetime(value)) && ...
                isscalar(value) && ismissing(value));
        end

        function output = mappedTable(records, mapping)
            % Renomeia campos do mapa e usa o mesmo decodificador de tabelas.
            %
            % Entrada:
            %   records - Struct-array retornado pela rota do mapa.
            %   mapping - Células N-by-2: alias de saída e campo de origem.
            % Saída:
            %   output - Tabela tipada, inclusive quando records estiver vazio.
            rows = cell(numel(records), 1);
            for ii = 1:numel(records)
                row = struct();
                for jj = 1:size(mapping, 1)
                    row.(mapping{jj,1}) = records(ii).(mapping{jj,2});
                end
                rows{ii} = row;
            end
            payload = struct();
            payload.columns = mapping(:,1);
            payload.rows = rows;
            output = util.WebFusionHandler.decodeTable(payload);
        end

        function output = mapRecords(records, kind)
            % Mantém o formato público do DBHandler usando as decisões do servidor.
            %
            % Entrada:
            %   records - Array JSON decodificado.
            %   kind    - 'point', 'siteDetail', 'publicStation' ou 'detailStation'.
            % Saída:
            %   output - Struct-array coluna com campos, tipos e nulos legados.
            records = util.WebFusionHandler.recordArray(records);
            model = util.WebFusionHandler.mapModel(kind);
            output = repmat(model, numel(records), 1);
            fields = fieldnames(model);
            for ii = 1:numel(records)
                for jj = 1:numel(fields)
                    field = fields{jj};
                    if ~isfield(records(ii), field)
                        error('WebFusionHandler:InvalidResponse', 'Missing map field: %s.', field);
                    end
                    value = records(ii).(field);
                    switch field
                        case 'stations'
                            stationKind = 'publicStation';
                            if strcmp(kind, 'siteDetail'), stationKind = 'detailStation'; end
                            value = util.WebFusionHandler.mapRecords(value, stationKind);

                        case 'station_names'
                            value = string(value(:));

                        otherwise
                            value = util.WebFusionHandler.normalizeMapValue( ...
                                value, field, model.(field));
                    end
                    output(ii).(field) = value;
                end
            end
        end

        function value = normalizeMapValue(value, field, defaultValue)
            % Normaliza um campo escalar do mapa que não é uma lista de estações.
            %
            % Entrada:
            %   value        - Valor retornado pela API.
            %   field        - Nome do campo que define a conversão necessária.
            %   defaultValue - Valor legado usado quando a API retorna null.
            % Saída:
            %   value - Valor convertido para o tipo esperado pelo aplicativo.
            if util.WebFusionHandler.isNull(value)
                value = defaultValue;
                return;
            end
            if any(strcmp(field, {'first_seen_at','last_seen_at'}))
                value = util.WebFusionHandler.parseDate(value);
                return;
            end
            if startsWith(field, {'is_', 'has_'})
                validateattributes(value, {'numeric','logical'}, {'scalar','finite'});
                value = logical(value);
                return;
            end
            if ischar(value) || isstring(value)
                value = string(value);
            end
        end

        function model = mapModel(kind)
            % Define os campos legados e valores-padrão de cada tipo do mapa.
            %
            % Entrada:
            %   kind - Tipo de registro do mapa.
            % Saída:
            %   model - Struct escalar usado como modelo de dados e de nulos.
            switch kind
                case 'point'
                    model = struct('site_id', NaN, 'site_label', "", 'county_name', [], ...
                        'district_id', [], 'district_name', [], 'state_id', [], ...
                        'state_name', [], 'state_code', [], 'latitude', NaN, ...
                        'longitude', NaN, 'altitude', [], 'gnss_measurements', [], ...
                        'stations', [], 'station_names', strings(0,1), 'marker_state', "no_host", ...
                        'has_online_station', false, 'has_online_host', false, 'has_known_host', false);
                case 'siteDetail'
                    model = struct('site_id', NaN, 'stations', [], 'marker_state', "no_host", ...
                        'has_online_station', false, 'has_online_host', false, 'has_known_host', false);
                case {'publicStation','detailStation'}
                    model = struct('equipment_id', [], 'equipment_name', [], 'host_id', [], ...
                        'host_name', [], 'is_offline', [], 'is_current_location', false, 'map_state', "no_host");
                    if strcmp(kind, 'detailStation')
                        model.first_seen_at = [];
                        model.last_seen_at = [];
                        model.spectrum_count = NaN;
                    end
                otherwise
                    error('WebFusionHandler:InvalidMapModel', 'Unknown map model.');
            end
        end
    end
end
