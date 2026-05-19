classdef dockRepoFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        DetailPanel                 matlab.ui.container.Panel
        DetailGridLayout            matlab.ui.container.GridLayout
        DetailUITable               matlab.ui.control.Table
        DetailSummaryLabel          matlab.ui.control.Label
        SelectedRowsLabel           matlab.ui.control.Label
        Download                    matlab.ui.control.Image
        LabelTotalPaginas           matlab.ui.control.Label
        Panel                       matlab.ui.container.Panel
        GridLayout2                 matlab.ui.container.GridLayout
        DropDownEstado              matlab.ui.control.DropDown
        EstadoLabel                 matlab.ui.control.Label
        DetailButton                matlab.ui.control.Button
        LimparButton                matlab.ui.control.Button
        BuscarButton                matlab.ui.control.Button
        EditFieldPlanoDescricao     matlab.ui.control.EditField
        LabelPlanoDescricao         matlab.ui.control.Label
        EditFieldFrequenciaFinal    matlab.ui.control.NumericEditField
        LabelFrequenciaFinal        matlab.ui.control.Label
        EditFieldFrequenciaInicial  matlab.ui.control.NumericEditField
        LabelFrequenciaInicial      matlab.ui.control.Label
        DatePickerPeriodoFinal      matlab.ui.control.DatePicker
        LabelPeriodoFinal           matlab.ui.control.Label
        DropDownLocalidade          matlab.ui.control.DropDown
        LabelLocalidade             matlab.ui.control.Label
        DropDownEquipamento         matlab.ui.control.DropDown
        LabelEquipamento            matlab.ui.control.Label
        DatePickerPeriodoInicial    matlab.ui.control.DatePicker
        LabelPeriodoInicial         matlab.ui.control.Label
        UITable                     matlab.ui.control.Table
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true
        mainApp
        callingApp
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
        dbHandler
        totalResults = 0

        selectedRows = zeros(1, 0)
        selectedRowData = table()
        selectedDetailRow = NaN
        expandedFileId = NaN
        localityRows = table()
    end

    methods (Access = public)

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, varargin)
            % Recebe chamadas IPC de outros aplicativos (ex.: winRepoSFI).
            try
                switch class(callingApp)
                    case {'winAppAnalise', 'winAppAnalise_exported'}
                        operationType = varargin{1};

                        switch operationType
                            case 'onRepoSFIFilterChanged'
                                syncFiltersFromRepoSFI(app, varargin{2})

                            otherwise
                                error('auxApp:dockRepoFiles:UnexpectedCall', 'Unexpected call "%s"', eventName)
                        end

                    otherwise
                        error('auxApp:dockRepoFiles:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                end
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

    end

    
    methods (Access = private)
        %-----------------------------------------------------------------%
        % Funções de incialização e configurações iniciais do layout da
        % pagina
        %-----------------------------------------------------------------%
        function updatePanel(app)
            % Inicializa o dock a partir do contexto recebido na abertura.
            %
            % Esse helper concentra a sequência base de startup do módulo:
            % prepara as duas tabelas, aplica os filtros vindos do chamador,
            % carrega os dropdowns dependentes e dispara a primeira busca.
        
            % Garante a existência do handler de banco antes de qualquer etapa
            % que dependa de leitura contextual ou consulta ao repositório.
            if isempty(app.dbHandler)
                app.dbHandler = util.DBHandler();
            end
        
            % Primeiro configura a estrutura visual fixa da tabela principal e
            % da área de detalhe, para depois preencher filtros e resultados.
            configureTable(app)
            configureDetailTable(app)
            initializeFilters(app)
        
            % Recarrega as opções dependentes do banco e tenta restaurar a
            % localidade vinda do contexto original do dock.
            populateStateOptions(app)

            % Aplica o estado vindo do contexto antes de carregar equipamentos,
            % para que loadEquipmentOptions já receba o filtro de UF correto.
            contextState = strtrim(char(string(getContextValue(app, 'stateCode'))));
            if ~isempty(contextState) && any(strcmp(app.DropDownEstado.ItemsData, contextState))
                app.DropDownEstado.Value = contextState;
            end

            loadEquipmentOptions(app)
            updateLocalityOptions(app, getContextValue(app, 'districtId'))
        
            % Fecha a inicialização executando a primeira consulta já no estado
            % coerente entre contexto, filtros visíveis e tabelas.
            refreshSearchResults(app)
        end
        
        
        function configureTable(app)
            % Configura a grade principal que exibe os arquivos encontrados no dock.
            %
            % Essa função fixa o contrato visual da busca orientada a arquivo:
            % nomes das colunas, ordem dos campos e larguras base esperadas
            % pelas rotinas que formatam e publicam os resultados na UITable.
        
            % Define a estrutura textual da tabela principal no mesmo formato
            % usado por formatFileResults ao montar a saída exibida ao usuário.
            app.UITable.ColumnName = {'ID Arquivo'; 'Arquivo'; 'Sensor'; 'Localidades'; 'Qtd. Espectros'; 'Faixa (MHz)'; 'Início'; 'Fim'; 'Caminho'};
        
            % Mantém larguras previsíveis para privilegiar leitura de nome,
            % localidade e período sem depender de autoajuste do componente.
            app.UITable.ColumnWidth = {75, 200, 160, 190, 105, 120, 135, 135, 'auto'};
        end
        
        
        function configureDetailTable(app)
            % Configura a tabela inferior usada para detalhar o arquivo em foco.
            %
            % Esse helper prepara o painel de detalhe no estado neutro esperado
            % pelo restante do fluxo: colunas fixas, tabela vazia, cabeçalho
            % padrão e painel inicialmente recolhido até haver seleção válida.
        
            % Define a estrutura da grade de detalhe no formato consumido por
            % formatSpectrumDetailResults quando um arquivo for expandido.
            app.DetailUITable.ColumnName = {'ID Espectro'; 'Descrição'; 'Localidade'; 'Faixa (MHz)'; 'Início'; 'Fim'};
            %app.DetailUITable.ColumnWidth = {90, 240, 210, 120, 140, 140};
        
            % Publica o estado vazio inicial para evitar resíduos visuais de uma
            % consulta anterior e manter o resumo coerente com o painel fechado.
            app.DetailUITable.Data = emptyDetailResultTable(app);
            app.DetailSummaryLabel.Text = 'Detalhes do arquivo';
        
            % O dock sempre inicia com o detalhe recolhido; ele só é aberto depois
            % que a seleção da tabela principal resolve um arquivo elegível.
            setDetailPanelVisible(app, false)
        end


        function initializeFilters(app)
            % Inicializa os filtros visíveis do dock a partir do contexto de abertura.
            %
            % Esse helper traduz inputArgs para o estado inicial da interface,
            % normalizando datas, frequências e descrição antes da primeira busca
            % ou de um reset que precise restaurar o recorte contextual original.
        
            % Reinicia o acumulador de resultados para que o rodapé e a próxima
            % consulta partam de um estado neutro e coerente com a UI.
            app.totalResults = 0;
        
            % Converte o intervalo temporal bruto do contexto para datetime,
            % preservando NaT quando a abertura não trouxer datas válidas.
            app.DatePickerPeriodoInicial.Value = rawToDatetime(app, getContextValue(app, 'startDate'));
            app.DatePickerPeriodoFinal.Value = rawToDatetime(app, getContextValue(app, 'endDate'));
        
            % Normaliza as frequências para o intervalo aceito pelos campos
            % numéricos, deixando o componente vazio quando o contexto vier
            % ausente, inválido ou fora da faixa suportada.
            app.EditFieldFrequenciaInicial.Value = rawToFiniteNumber(app, getContextValue(app, 'freqStart'), 20, 18000);
            app.EditFieldFrequenciaFinal.Value = rawToFiniteNumber(app, getContextValue(app, 'freqEnd'), 20, 18000);
        
            % Carrega a descrição textual associada ao contexto já em formato
            % escalar limpo, para alinhar a UI ao contrato esperado pela busca.
            app.EditFieldPlanoDescricao.Value = char(displayText(app, getContextValue(app, 'description'), ""));

            % Aplica o estado (UF) vindo do contexto de abertura ao DropDownEstado,
            % quando ele existir entre as opções já carregadas.
            % (populateStateOptions é chamado logo após em updatePanel)
            app.localityRows = table();
        end

        function clearFilters(app)
            % Limpa os filtros visíveis do dock para um estado neutro de busca.
            %
            % Esse helper é usado pelo botão Limpar quando a intenção não é
            % restaurar o contexto de abertura, mas sim zerar campos, remover
            % seleções e preparar a interface para uma nova pesquisa manual.

            % Reinicia o total agregado para alinhar os campos ao estado vazio
            % que será publicado em seguida na tabela principal.
            app.totalResults = 0;

            % Remove qualquer recorte temporal previamente aplicado na busca.
            app.DatePickerPeriodoInicial.Value = NaT;
            app.DatePickerPeriodoFinal.Value = NaT;

            % Esvazia os limites frequenciais para representar ausência de filtro.
            app.EditFieldFrequenciaInicial.Value = [];
            app.EditFieldFrequenciaFinal.Value = [];

            % Limpa o texto livre para que a próxima consulta parta sem restrição
            % por plano ou descrição.
            app.EditFieldPlanoDescricao.Value = '';
        end
        
        %-----------------------------------------------------------------%
        % Popula informações inicias dos filrtos de buscas
        %-----------------------------------------------------------------%

        function loadEquipmentOptions(app)
            % Carrega no filtro o catálogo de equipamentos disponível no repositório.
            %
            % Esse helper reconstrói o dropdown principal da busca no dock a partir
            % do banco e tenta restaurar o equipamento vindo no contexto de abertura,
            % para que a consulta inicial já reflita o recorte esperado pelo chamador.
        
            % Constrói filtros de estado e localidade ativos para restringir o
            % catálogo de equipamentos ao contexto selecionado na interface.
            eqFilters = struct();
            stateCode = getSelectedState(app);
            if strlength(stateCode) > 0
                eqFilters.stateCode = char(stateCode);
            end
            eqDistrictId = str2double(string(app.DropDownLocalidade.Value));
            if ~isnan(eqDistrictId)
                eqFilters.districtId = eqDistrictId;
            end

            rows = app.dbHandler.getSpectrumEquipments(eqFilters);
        
            % Mantém uma opção neutra no topo para representar ausência de filtro
            % explícito por equipamento na pesquisa de arquivos.
            items = {'Selecione uma estação/equipamento'};
            itemsData = {''};
        
            % Só materializa opções reais quando o banco devolver uma tabela válida.
            if istable(rows) && ~isempty(rows)
                for ii = 1:height(rows)
                    % Normaliza o identificador e o nome exibido antes de publicar
                    % cada entrada no dropdown.
                    equipmentId = formatIdValue(app, rows.ID_EQUIPMENT(ii));
                    equipmentName = displayText(app, rows.NA_EQUIPMENT(ii), '(sem nome)');
        
                    items{end + 1} = char(equipmentName); %#ok<AGROW>
                    itemsData{end + 1} = char(equipmentId); %#ok<AGROW>
                end
            end

            % Publica a lista final mantendo texto visível e valor interno em sincronia.
            app.DropDownEquipamento.Items = items;
            app.DropDownEquipamento.ItemsData = itemsData;
        
            % Preserva a seleção atual quando ainda existe na nova lista.
            % Se não existir, tenta restaurar o equipamento do contexto de abertura.
            % Só volta para o estado neutro quando nenhuma das duas estiver disponível.
            currentEquipmentId = char(string(app.DropDownEquipamento.Value));
            contextEquipmentId = char(formatIdValue(app, getContextValue(app, 'equipmentId')));

            if ~isempty(currentEquipmentId) && any(strcmp(itemsData, currentEquipmentId))
                app.DropDownEquipamento.Value = currentEquipmentId;
            elseif ~isempty(contextEquipmentId) && any(strcmp(itemsData, contextEquipmentId))
                app.DropDownEquipamento.Value = contextEquipmentId;
            else
                app.DropDownEquipamento.Value = '';
            end
        end


        function populateStateOptions(app)
            % Preenche o DropDownEstado com os estados (UF) disponíveis no repositório.
            %
            % Mantém 'Todos os estados' na primeira posição como opção neutra e
            % tenta restaurar a seleção anterior quando ela ainda existir na lista.
            prevValue = string(app.DropDownEstado.Value);
            items     = {'Todos os estados'};
            itemsData = {''};

            rows = app.dbHandler.getSpectrumStates(struct());
            if istable(rows) && ~isempty(rows) && ismember('LC_STATE', rows.Properties.VariableNames)
                for ii = 1:height(rows)
                    code = strtrim(char(string(rows.LC_STATE(ii))));
                    if ~isempty(code)
                        items{end + 1}     = code; %#ok<AGROW>
                        itemsData{end + 1} = code; %#ok<AGROW>
                    end
                end
            end

            app.DropDownEstado.Items     = items;
            app.DropDownEstado.ItemsData = itemsData;

            if any(strcmp(itemsData, char(prevValue)))
                app.DropDownEstado.Value = char(prevValue);
            else
                app.DropDownEstado.Value = '';
            end
        end


        function output = getSelectedState(app)
            % Retorna o código de estado selecionado, ou "" quando neutro.
            output = "";
            val = string(app.DropDownEstado.Value);
            if ~ismissing(val) && strlength(val) > 0 && val ~= "Todos os estados"
                output = val;
            end
        end


        function updateLocalityOptions(app, preferredDistrictId, equipmentIdOverride)
            % Recarrega as localidades disponíveis para o equipamento ativo no dock.
            %
            % Esse helper depende do equipamento selecionado e do snapshot atual dos
            % filtros para reconstruir o dropdown de localidades, tentando ao final
            % reaplicar uma localidade preferencial vinda do contexto ou do chamador.
            %
            % equipmentIdOverride — quando fornecido, substitui o equipamento lido
            % da UI; passe NaN para obter todas as localidades do estado corrente
            % sem restringir ao equipamento selecionado (caso "Todas as localidades").

            % Resolve o equipamento atual no formato numérico esperado pelas
            % consultas ao banco.
            if nargin >= 3
                equipmentId = equipmentIdOverride;
            else
                equipmentId = str2double(string(app.DropDownEquipamento.Value));
            end
        
            % A lista sempre começa com uma opção neutra para representar busca
            % sem recorte explícito por localidade.
            items = {'Todas as localidades'};
            itemsData = {''};
        
            % Constrói filtros de estado e data/freq para a consulta de localidades.
            app.localityRows = table();
            locFilters = getCurrentFilters(app);
            % A consulta de localidades nunca deve ser filtrada pelo próprio
            % distrito selecionado — isso criaria um filtro circular que colapsaria
            % a lista ao único item correntemente escolhido.
            locFilters.districtId = NaN;
            stateCode = getSelectedState(app);
            if strlength(stateCode) > 0
                locFilters.stateCode = char(stateCode);
            end

            % Sempre consulta o banco: sem filtros ativos retorna todas as
            % localidades disponíveis, permitindo que o usuário desfaça filtros
            % sem colapsar a lista para apenas a opção neutra.
            app.localityRows = app.dbHandler.getSpectrumLocalities(equipmentId, locFilters);

            if istable(app.localityRows) && ~isempty(app.localityRows)
                for ii = 1:height(app.localityRows)
                    districtId = formatIdValue(app, app.localityRows.ID_DISTRICT(ii));
                    localityLabel = formatLocalityDisplay(app, app.localityRows(ii, :));

                    items{end + 1} = char(localityLabel); %#ok<AGROW>
                    itemsData{end + 1} = char(districtId); %#ok<AGROW>
                end
            end

            % Ordena alfabeticamente mantendo 'Todas as localidades' na 1ª posição.
            if numel(items) > 1
                [sortedLabels, sortIdx] = sort(items(2:end));
                items     = [items(1),     sortedLabels];
                itemsData = [itemsData(1), itemsData(sortIdx + 1)];
            end

            % Publica no componente o conjunto recém-montado de localidades.
            app.DropDownLocalidade.Items = items;
            app.DropDownLocalidade.ItemsData = itemsData;
        
            % Normaliza a localidade preferencial para um texto escalar comparável
            % contra os ItemsData publicados no dropdown.
            preferredDistrictId = string(formatIdValue(app, preferredDistrictId));
            preferredDistrictId = preferredDistrictId(~ismissing(preferredDistrictId));
        
            if isempty(preferredDistrictId)
                preferredDistrictId = "";
            else
                preferredDistrictId = preferredDistrictId(1);
            end
        
            % Se a localidade preferencial ainda existir entre as opções atuais,
            % restaura essa seleção; caso contrário, volta para a opção neutra.
            if (strlength(preferredDistrictId) > 0) && any(strcmp(itemsData, char(preferredDistrictId)))
                app.DropDownLocalidade.Value = char(preferredDistrictId);
            else
                app.DropDownLocalidade.Value = '';
            end
        end


        function updateAvailablePeriod(app)
            % Atualiza os DatePickers com o período disponível para a combinação
            % atual de equipamento e localidade selecionados no dock.
            %
            % Usa app.localityRows como cache das linhas retornadas pela última
            % chamada a updateLocalityOptions para não repetir consulta ao banco.
            app.DatePickerPeriodoInicial.Value = NaT;
            app.DatePickerPeriodoFinal.Value   = NaT;

            if ~istable(app.localityRows) || isempty(app.localityRows)
                return
            end

            rows = app.localityRows;
            selectedDistrictId = str2double(string(app.DropDownLocalidade.Value));

            % Se uma localidade específica foi selecionada, restringe o cálculo
            % ao período observado apenas naquele distrito.
            if ~isnan(selectedDistrictId) && ismember('ID_DISTRICT', rows.Properties.VariableNames)
                districtValues = str2double(string(rows.ID_DISTRICT));
                rows = rows(districtValues == selectedDistrictId, :);
            end

            if isempty(rows)
                return
            end

            startDates = NaT(height(rows), 1);
            endDates   = NaT(height(rows), 1);

            if ismember('DATE_START', rows.Properties.VariableNames)
                for ii = 1:height(rows)
                    startDates(ii) = rawToDatetime(app, rows.DATE_START(ii));
                end
            end
            if ismember('DATE_END', rows.Properties.VariableNames)
                for ii = 1:height(rows)
                    endDates(ii) = rawToDatetime(app, rows.DATE_END(ii));
                end
            end

            validStart = startDates(~isnat(startDates));
            validEnd   = endDates(~isnat(endDates));

            if ~isempty(validStart)
                app.DatePickerPeriodoInicial.Value = min(validStart);
            end
            if ~isempty(validEnd)
                app.DatePickerPeriodoFinal.Value = max(validEnd);
            end
        end


        %-----------------------------------------------------------------%
        % Execução da pesquisa em banco
        %-----------------------------------------------------------------%
        function refreshSearchResults(app)
            % Executa a busca atual e recompõe a tabela principal do dock.
            %
            % Esse helper é o ponto central da pesquisa por arquivos: ele captura
            % o estado visível dos filtros, consulta o banco no formato esperado
            % e publica na UITable o novo snapshot bruto e formatado do resultado.
        
            % Antes de uma nova consulta, limpa o estado de detalhe para evitar que
            % seleção, painel inferior e resumo continuem apontando para dados antigos.
            resetDetailState(app)
        
            % Congela o estado atual da interface no contrato consumido pelo DBHandler.
            filters = getCurrentFilters(app);
        
            % Exige ao menos um dos três recortes principais (equipamento, localidade
            % ou estado) para evitar carregar o repositório inteiro sem contexto.
            hasMinFilter = ~isnan(filters.equipmentId) || ...
                           ~isnan(filters.districtId)  || ...
                           strlength(strtrim(filters.stateCode)) > 0;
            if ~hasMinFilter
                app.UITable.Data = emptyResultTable(app);
                app.UITable.UserData = table();
                app.totalResults = 0;
                updatePaginationState(app)
                return
            end
        
            try
                % Primeiro mede o universo filtrado para ajustar a carga da consulta
                % principal e manter coerente o resumo textual de resultados.
                app.totalResults = app.dbHandler.getSpectrumFileDataCount(filters);
        
                % O dock carrega tudo de uma vez na visão atual, sem paginação visual,
                % então a consulta é forçada para uma única página contendo todo o recorte.
                filters.page = 1;
                filters.pageSize = max(app.totalResults, 1);
        
                % A busca interna pode filtrar por espectro, mas a tabela principal do
                % dock sempre publica uma linha por arquivo do repositório.
                rawRows = app.dbHandler.getSpectrumFileData(filters);
        
                % Publica na grade a versão formatada e amigável do resultado bruto.
                app.UITable.Data = formatFileResults(app, rawRows);
        
                % Mantém o payload original associado à tabela para sustentar fluxos
                % posteriores, como abertura do detalhe do arquivo selecionado.
                app.UITable.UserData = rawRows;
        
                % Atualiza o rodapé e os demais elementos visuais dependentes da
                % quantidade total retornada pela consulta.
                updatePaginationState(app)
            catch ME
                % Em falha de consulta, limpa a tabela e o estado agregado para não
                % deixar a interface exibindo dados parciais ou inconsistentes.
                app.UITable.Data = emptyResultTable(app);
                app.UITable.UserData = table();
                app.totalResults = 0;
                updatePaginationState(app)
        
                % Informa o erro ao usuário sem interromper o restante do dock.
                ui.Dialog(app.UIFigure, 'error', sprintf('Erro ao consultar arquivos do repositório:\n%s', ME.message));
            end
        end

        
        function filters = getCurrentFilters(app)
            % Consolida o estado visível da UI no payload consumido pelo DBHandler.
            %
            % Esse helper é a fronteira entre a interface do dock e a camada de
            % consulta: ele lê os controles atuais, materializa um struct estável
            % e normaliza valores inválidos antes de qualquer busca ao banco.
        
            % Captura em um único snapshot todos os filtros expostos na tela,
            % preservando o contrato esperado pelas consultas do repositório.
            filters = struct( ...
                'equipmentId', str2double(string(app.DropDownEquipamento.Value)), ...
                'districtId',  str2double(string(app.DropDownLocalidade.Value)), ...
                'stateCode',   char(getSelectedState(app)), ...
                'startDate',   app.DatePickerPeriodoInicial.Value, ...
                'endDate',     app.DatePickerPeriodoFinal.Value, ...
                'freqStart',   app.EditFieldFrequenciaInicial.Value, ...
                'freqEnd',     app.EditFieldFrequenciaFinal.Value, ...
                'description', strtrim(string(app.EditFieldPlanoDescricao.Value)) ...
                );
        
            % Frequência inicial vazia, não finita ou negativa é tratada como
            % ausência de filtro para manter a semântica usada nas consultas.
            if isempty(filters.freqStart) || ~isfinite(filters.freqStart) || (filters.freqStart < 0)
                filters.freqStart = NaN;
            end
        
            % Aplica a mesma convenção à ponta final da faixa para que o intervalo
            % frequencial seja sempre interpretado de forma consistente no backend.
            if isempty(filters.freqEnd) || ~isfinite(filters.freqEnd) || (filters.freqEnd < 0)
                filters.freqEnd = NaN;
            end
        end


        %-----------------------------------------------------------------%
        % Formatação da tabela para exibição em tela
        %-----------------------------------------------------------------%
        function updatePaginationState(app)
            % Atualiza o resumo textual de resultados. A paginação visual foi
            % removida, mas o rodapé continua informando a quantidade encontrada.
            if isempty(app.LabelTotalPaginas)
                return
            end

            app.LabelTotalPaginas.Text = sprintf('%d resultado(s)', app.totalResults);
        end

        
        function output = formatFileResults(app, rawRows)
            % Converte a consulta bruta por arquivo no formato exibido pela UITable.
            %
            % Esse helper é a etapa de adaptação entre o retorno do DBHandler e a
            % grade principal do dock: ele normaliza cada campo relevante e monta
            % uma tabela estável, legível e coerente com o layout visual da busca.
        
            % Quando a consulta não devolver uma tabela válida, publica diretamente
            % a estrutura vazia padrão esperada pela tabela principal.
            if ~istable(rawRows) || isempty(rawRows)
                output = emptyResultTable(app);
                return
            end
        
            % Pré-aloca todas as colunas exibidas para materializar a saída final
            % de forma explícita e previsível, sem depender do formato bruto.
            nRows = height(rawRows);
            id = strings(nRows, 1);
            fileName = strings(nRows, 1);
            equipment = strings(nRows, 1);
            localities = strings(nRows, 1);
            spectrumCount = strings(nRows, 1);
            band = strings(nRows, 1);
            startAt = strings(nRows, 1);
            endAt = strings(nRows, 1);
            pathValue = strings(nRows, 1);
        
            % Normaliza linha a linha os campos retornados pelo banco para a forma
            % textual usada na apresentação da tabela principal.
            for ii = 1:nRows
                id(ii) = formatIdValue(app, rawRows.ID_FILE(ii));
                fileName(ii) = buildRepositoryFileName(app, rawRows(ii, :));
                equipment(ii) = displayText(app, rawRows.EQUIPMENT_LABELS(ii), '-');
                localities(ii) = displayText(app, rawRows.LOCALITY_LABELS(ii), '-');
                spectrumCount(ii) = formatIdValue(app, rawRows.NU_SPECTRA(ii));
                band(ii) = formatFrequencyRange(app, rawRows.NU_FREQ_START(ii), rawRows.NU_FREQ_END(ii));
                startAt(ii) = formatDateValue(app, rawRows.DT_TIME_START(ii));
                endAt(ii) = formatDateValue(app, rawRows.DT_TIME_END(ii));
                pathValue(ii) = displayText(app, rawRows.NA_PATH(ii), '-');
            end
        
            % Empacota as colunas já tratadas no contrato final consumido pela
            % UITable e alinhado à configuração feita em configureTable.
            output = table(id, fileName, equipment, localities, spectrumCount, band, startAt, endAt, pathValue, ...
                'VariableNames', {'IDArquivo', 'Arquivo', 'Sensor', 'Localidades', 'QtdEspectros', 'FaixaMHz', 'Inicio', 'Fim', 'Caminho'});
        end

        
        function output = emptyResultTable(~)
            % Cria a estrutura vazia padrão da tabela principal de resultados.
            %
            % Esse helper garante que o dock publique sempre o mesmo contrato de
            % colunas na busca orientada a arquivo, mesmo quando a consulta vier
            % vazia ou quando a interface precisar ser resetada para estado neutro.
        
            % Materializa uma tabela sem linhas, mas com o mesmo layout esperado
            % por configureTable e formatFileResults na grade principal.
            output = table(strings(0, 1), strings(0, 1), strings(0, 1), strings(0, 1), ...
                strings(0, 1), strings(0, 1), strings(0, 1), strings(0, 1), strings(0, 1), ...
                'VariableNames', {'IDArquivo', 'Arquivo', 'Sensor', 'Localidades', 'QtdEspectros', 'FaixaMHz', 'Inicio', 'Fim', 'Caminho'});
        end

        
        function output = formatSpectrumDetailResults(app, rawRows)
            % Converte o detalhe bruto por espectro para a grade inferior do dock.
            %
            % Esse helper adapta o retorno de getSpectraByFileId ao contrato visual
            % da tabela de detalhe, normalizando cada campo antes de publicar o
            % conteúdo associado ao arquivo atualmente expandido.
        
            % Quando não houver detalhe válido, devolve diretamente a estrutura
            % vazia padrão da área inferior.
            if ~istable(rawRows) || isempty(rawRows)
                output = emptyDetailResultTable(app);
                return
            end
        
            % Pré-aloca as colunas exibidas no painel de detalhe para montar uma
            % saída estável e independente do formato bruto do banco.
            nRows = height(rawRows);
            spectrumId = strings(nRows, 1);
            description = strings(nRows, 1);
            locality = strings(nRows, 1);
            band = strings(nRows, 1);
            startAt = strings(nRows, 1);
            endAt = strings(nRows, 1);
        
            % Normaliza linha a linha os campos do espectro para a apresentação
            % final usada na tabela inferior.
            for ii = 1:nRows
                spectrumId(ii) = formatIdValue(app, rawRows.ID_SPECTRUM(ii));
                description(ii) = displayText(app, rawRows.NA_DESCRIPTION(ii), '-');
                locality(ii) = formatLocalityDisplay(app, rawRows(ii, :));
                band(ii) = formatFrequencyRange(app, rawRows.NU_FREQ_START(ii), rawRows.NU_FREQ_END(ii));
                startAt(ii) = formatDateValue(app, rawRows.DT_TIME_START(ii));
                endAt(ii) = formatDateValue(app, rawRows.DT_TIME_END(ii));
            end
        
            % Empacota o resultado já tratado no layout esperado por
            % configureDetailTable e DetailUITable.
            output = table(spectrumId, description, locality, band, startAt, endAt, ...
                'VariableNames', {'IDEspectro', 'Descricao', 'Localidade', 'FaixaMHz', 'Inicio', 'Fim'});
        end

        
        function output = emptyDetailResultTable(~)
            % Cria a estrutura vazia padrão da tabela inferior de detalhes.
            %
            % Esse helper preserva o contrato fixo do painel de detalhe mesmo quando
            % nenhum arquivo estiver expandido ou quando a consulta por espectros
            % não devolver linhas válidas para a área inferior do dock.
        
            % Materializa a tabela sem registros, mas com as mesmas colunas
            % esperadas por configureDetailTable e formatSpectrumDetailResults.
            output = table(strings(0, 1), strings(0, 1), strings(0, 1), ...
                strings(0, 1), strings(0, 1), strings(0, 1), ...
                'VariableNames', {'IDEspectro', 'Descricao', 'Localidade', 'FaixaMHz', 'Inicio', 'Fim'});
        end

        
        %------------------------------------------------------------------
        % Funções auxiliares de consistência e conversão de formatos de
        % dados
        %------------------------------------------------------------------
        function output = getContextValue(app, fieldName)
            % Recupera um campo do contexto de entrada recebido na abertura do dock.
            % Se a estrutura esperada não existir ou o campo não estiver presente,
            % retorna vazio para o chamador tratar o fallback.
            output = [];

            if ~isfield(app.inputArgs, fieldName)
                return
            end

            output = app.inputArgs.(fieldName);
        end

        
        function output = rawToDatetime(~, rawValue)
            % Converte um valor bruto do contexto para datetime.
            % Aceita valores já tipados, strings e células; se a conversão falhar,
            % retorna NaT para representar ausência de data válida.
            output = NaT;
            value = rawValue;

            % Desempacota células até encontrar o valor concreto.
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

        
        function output = rawToFiniteNumber(~, rawValue, minValue, maxValue)
            % Converte um valor bruto do contexto para número finito escalar.
            % Aceita números, lógicos, textos e células; qualquer entrada inválida
            % resulta em [] para permitir campos numéricos vazios na UI.
            value = rawValue;

            % Desempacota células até chegar ao valor utilizável.
            while iscell(value)
                if isempty(value)
                    output = [];
                    return
                end
                value = value{1};
            end

            if isempty(value)
                output = [];
                return
            end

            % Faz a conversão preservando o primeiro elemento quando vier coleção.
            if isnumeric(value) || islogical(value)
                output = double(value(1));
            else
                textValue = string(value);
                textValue = textValue(~ismissing(textValue));
                if isempty(textValue)
                    output = [];
                    return
                end

                output = str2double(textValue(1));
            end

            % Garante que a saída final seja sempre um número finito e escalar.
            if isempty(output) || ~isscalar(output) || ~isfinite(output)
                output = [];
                return
            end

            if isfinite(minValue) && output < minValue
                output = [];
                return
            end

            if isfinite(maxValue) && output > maxValue
                output = [];
            end
        end

        
        function output = formatNumericValue(~, rawValue, precision)
            % Converte um valor numérico bruto para texto compacto com precisão controlada.
            %
            % Esse helper sustenta a apresentação de frequências no dock, centralizando
            % a conversão para string e a remoção de zeros residuais para que as
            % tabelas exibam números legíveis sem ruído visual desnecessário.
        
            % Primeiro tenta interpretar o valor no formato numérico padrão usado
            % pelo restante das rotinas de exibição.
            numericValue = str2double(string(rawValue));
            if isnan(numericValue)
                output = "";
                return
            end
        
            % Formata o número com a precisão pedida antes de enxugar zeros e
            % separadores decimais sobrando no final do texto.
            output = string(sprintf(['%0.', num2str(precision), 'f'], numericValue));
            output = regexprep(output, '([\.,]0+)$', '');
            output = regexprep(output, '[\.,]$', '');
        end


        %------------------------------------------------------------------
        % Funções auxiliares de formatação de conteúdo das tabelas
        %------------------------------------------------------------------
        function output = formatLocalityDisplay(app, row)
            % Formata a localidade para dropdowns e tabelas a partir de uma linha.
            % O helper aceita subconjuntos diferentes de colunas vindos do banco e
            % monta um rótulo único, estável e legível para toda a interface.

            % Cada campo é lido de forma defensiva para suportar consultas que nem
            % sempre devolvem o mesmo conjunto de colunas de localidade.
            label = "-";
            if ismember('LOCALITY_LABEL', row.Properties.VariableNames)
                label = displayText(app, row.LOCALITY_LABEL(1), '-');
            end

            county = "";
            if ismember('COUNTY_NAME', row.Properties.VariableNames)
                county = displayText(app, row.COUNTY_NAME(1), '');
            end

            stateCode = "";
            if ismember('STATE_CODE', row.Properties.VariableNames)
                stateCode = displayText(app, row.STATE_CODE(1), '');
            end

            suffix = "";
            if strlength(county) > 0 && strlength(stateCode) > 0
                suffix = county + "/" + stateCode;
            elseif strlength(county) > 0
                suffix = county;
            elseif strlength(stateCode) > 0
                suffix = stateCode;
            end

            if strlength(suffix) == 0 || strcmpi(char(label), char(suffix))
                output = label;
            else
                output = label + " (" + suffix + ")";
            end
        end

        
        function output = formatFrequencyRange(app, startFreq, endFreq)
            % Formata uma faixa de frequência para exibição textual nas tabelas do dock.
            %
            % Esse helper é usado na montagem dos resultados principal e de detalhe
            % para transformar os limites bruto inicial/final em um rótulo curto,
            % legível e coerente com o padrão visual da busca por arquivos.
        
            % Normaliza cada ponta do intervalo com a mesma precisão usada na UI,
            % evitando espalhar a regra de formatação numérica pelo restante do fluxo.
            startText = formatNumericValue(app, startFreq, 3);
            endText = formatNumericValue(app, endFreq, 3);
        
            % Quando nenhuma das pontas vier válida, publica o fallback neutro usado
            % nas tabelas; se só houver a ponta inicial, exibe apenas esse valor.
            if strlength(startText) == 0 && strlength(endText) == 0
                output = "-";
            elseif strlength(endText) == 0
                output = startText;
            else
                % Com as duas pontas válidas, monta a faixa no padrão "inicio - fim".
                output = startText + " - " + endText;
            end
        end


        function output = buildRepositoryFileName(app, row)
            % Monta o nome final do arquivo a partir do nome base e da extensão.
            %
            % Esse helper é usado na tabela principal e no resumo do detalhe para
            % transformar os campos brutos do banco em um nome de arquivo coerente,
            % evitando duplicação de extensão e preservando um fallback visual estável.
        
            % Normaliza separadamente nome e extensão antes de compor o rótulo final
            % exibido nas áreas de resultado do dock.
            fileName = displayText(app, row.NA_FILE, '');
            extension = displayText(app, row.NA_EXTENSION, '');
        
            % Quando a extensão vier sem ponto, normaliza para o formato usual de
            % arquivo antes da concatenação.
            if strlength(extension) > 0 && startsWith(extension, '.') == 0
                extension = "." + extension;
            end
        
            % Sem nome base não há arquivo útil para exibir, então publica o
            % fallback neutro; se a extensão já estiver embutida, evita duplicá-la.
            if strlength(fileName) == 0
                output = '-';
            elseif endsWith(fileName, extension)
                output = fileName;
            else
                output = fileName + extension;
            end
        end

        
        function output = formatDateValue(app, rawValue)
            % Formata valores temporais brutos para a apresentação textual do dock.
            %
            % Esse helper é usado nas tabelas principal e de detalhe para converter
            % datas heterogêneas vindas do banco em um texto único de exibição,
            % reaproveitando o parsing centralizado em rawToDatetime.
        
            % Primeiro tenta materializar o valor como datetime no mesmo contrato
            % usado pelo restante do módulo.
            value = rawToDatetime(app, rawValue);
        
            % Quando não houver uma data válida, cai no fallback textual neutro
            % usado pela interface para campos ausentes ou inválidos.
            if isnat(value)
                output = displayText(app, rawValue, "-");
                return
            end
        
            % Com uma data válida, publica a formatação completa de data e hora
            % usada nas grades do dock.
            output = string(value(1), 'dd-MMM-yyyy HH:mm:ss');
        end
        
        
        function output = displayText(~, rawValue, defaultValue)
            % Normaliza valores textuais heterogêneos para uma string escalar limpa.
            %
            % Esse helper concentra o tratamento de células, coleções, missing e
            % espaços sobrando para que labels, nomes e campos livres do dock
            % tenham sempre um texto estável e com fallback previsível.
        
            % Mantém um valor padrão neutro quando o chamador não informar fallback
            % explícito para o campo textual.
            if nargin < 3
                defaultValue = "";
            end
        
            % Desempacota células sucessivas até chegar ao valor efetivo, ou zera
            % a entrada quando a célula vier vazia.
            value = rawValue;
            while iscell(value)
                if isempty(value)
                    value = [];
                    break
                end
                value = value{1};
            end
        
            % Sem conteúdo útil, devolve diretamente o fallback pedido pelo chamador.
            if isempty(value)
                output = string(defaultValue);
                return
            end
        
            % Normaliza para string, remove missing, tira espaços extras e descarta
            % entradas vazias antes de selecionar apenas o primeiro valor útil.
            textValue = string(value);
            textValue = textValue(~ismissing(textValue));
            textValue = strtrim(textValue);
            textValue = textValue(strlength(textValue) > 0);
        
            if isempty(textValue)
                output = string(defaultValue);
            else
                output = textValue(1);
            end
        end
        
        
        function output = formatIdValue(~, rawValue)
            % Converte identificadores brutos para o formato textual usado na UI.
            %
            % Esse helper é reaproveitado na montagem de tabelas, dropdowns e
            % resumos para publicar IDs em forma inteira textual, mantendo string
            % vazia quando o valor de origem não puder ser interpretado.
        
            % Tenta interpretar o valor no formato numérico padrão do restante do
            % fluxo antes de publicá-lo na interface.
            numericValue = str2double(string(rawValue));
            if isnan(numericValue)
                output = "";
            else
                % Força o resultado para inteiro textual, alinhando a saída ao
                % contrato visual usado por IDs e contagens no dock.
                output = string(round(numericValue));
            end
        end

        
        %------------------------------------------------------------------
        % Funções de interação com a GUI
        %------------------------------------------------------------------
        function resetDetailState(app, clearSelection)
            % Restaura a área de detalhe para o estado neutro padrão do dock.
            %
            % Esse helper concentra a limpeza do painel inferior após nova busca,
            % troca de filtro ou recolhimento manual do detalhe, mantendo resumo,
            % tabela e seleção coerentes com o contexto atual da interface.
            if nargin < 2
                % Na chamada padrão, também limpa a seleção da tabela principal.
                clearSelection = true;
            end
        
            if clearSelection
                % Remove a seleção acumulada e invalida a referência da última linha
                % usada como origem para abrir o detalhe do arquivo.
                app.selectedRows = zeros(1, 0);
                app.selectedRowData = table();
                app.selectedDetailRow = NaN;
            end
        
            % Esquece o arquivo expandido e repõe a grade inferior no layout vazio
            % esperado quando nenhum detalhe estiver aberto.
            app.expandedFileId = NaN;
            app.DetailUITable.Data = emptyDetailResultTable(app);
            app.DetailSummaryLabel.Text = 'Detalhes do arquivo';
        
            % Recolhe o painel e deixa o botão sincronizado com o novo estado visual.
            setDetailPanelVisible(app, false)
        
            % Atualiza o resumo textual da seleção principal após a limpeza aplicada.
            app.SelectedRowsLabel.Text = sprintf('%d arquivo(s) selecionado(s)', numel(app.selectedRows));
        end


        function updateDetailButtonState(app)
            % Sincroniza o botão de detalhe com o estado atual da seleção e do painel.
            %
            % Esse helper mantém o CTA coerente com o fluxo do dock: quando o detalhe
            % está aberto, o botão vira ação de ocultar; quando está fechado, só pode
            % ser usado se houver exatamente um arquivo elegível selecionado.
            if strcmp(app.DetailPanel.Visible, 'on')
                % Com o painel aberto, o botão passa a representar a ação inversa.
                app.DetailButton.Text = 'Ocultar';
                app.DetailButton.Enable = 'on';
            else
                % Com o painel fechado, o botão volta ao papel de abrir o detalhe.
                app.DetailButton.Text = 'Detalhe';
        
                % O detalhe só faz sentido quando há uma única linha selecionada.
                if numel(app.selectedRows) == 1
                    app.DetailButton.Enable = 'on';
                else
                    app.DetailButton.Enable = 'off';
                end
            end
        end
        
        
        function setDetailPanelVisible(app, shouldShow)
            % Mostra ou recolhe o painel inferior de detalhe ajustando o layout do dock.
            %
            % Esse helper centraliza a alteração visual da interface ao expandir ou
            % esconder os espectros do arquivo selecionado, evitando que cada fluxo
            % precise manipular diretamente altura de grid, visibilidade e botão.
            if shouldShow
                % Reserva espaço para a área inferior e publica o painel como visível.
               % app.GridLayout.RowHeight = {17, 148, '0.8x', '1x', 22};
                app.DetailPanel.Visible = 'on';
            else
                % Remove a altura útil da linha de detalhe para recolher o painel
                % sem deixar espaço morto no layout principal.
                %app.GridLayout.RowHeight = {17, 148, '1x', 0, 22};
                app.DetailPanel.Visible = 'off';
            end
        
            % Sempre recalcula o estado do botão após qualquer mudança visual.
            updateDetailButtonState(app)
        end


        function rowIndex = getSelectedDetailRow(app)
            % Resolve a linha que deve servir de base para abrir o detalhe do arquivo.
            %
            % Esse helper centraliza a prioridade entre a última célula realmente
            % tocada pelo usuário e o conjunto de linhas selecionadas, para que o
            % fluxo de detalhe opere sempre sobre uma referência única e consistente.
            rowIndex = NaN;
        
            % Quando houver uma linha de detalhe já destacada explicitamente pela
            % interação mais recente, ela tem prioridade como origem da consulta.
            if ~isnan(app.selectedDetailRow)
                rowIndex = app.selectedDetailRow;
                return
            end
        
            % Na ausência desse marcador, reutiliza a última linha da seleção atual
            % como fallback para permitir a abertura do detalhe pelo botão.
            if ~isempty(app.selectedRows)
                rowIndex = app.selectedRows(end);
            end
        end


        function toggleSelectedFileDetail(app)
            % Abre ou recolhe o detalhe do arquivo atualmente apontado pela seleção.
            %
            % Esse helper concentra a ação do botão de detalhe: valida a linha ativa,
            % resolve o identificador do arquivo e decide entre fechar o painel já
            % aberto ou consultar novamente os espectros do item selecionado.
            rowIndex = getSelectedDetailRow(app);
            rawRows = app.UITable.UserData;
        
            % Interrompe o fluxo quando não existir uma linha válida na tabela
            % principal para servir de origem à abertura do detalhe.
            if isnan(rowIndex) || ~istable(rawRows) || isempty(rawRows) || (rowIndex < 1) || (rowIndex > height(rawRows))
                ui.Dialog(app.UIFigure, 'warning', 'Selecione ao menos um arquivo para visualizar os detalhes.');
                return
            end
        
            % Traduz o identificador bruto do arquivo para o formato numérico usado
            % pela consulta de espectros no repositório.
            fileId = str2double(formatIdValue(app, rawRows.ID_FILE(rowIndex)));
            if isnan(fileId)
                ui.Dialog(app.UIFigure, 'warning', 'Não foi possível identificar o arquivo selecionado.');
                return
            end
        
            % Se o painel já estiver mostrando exatamente esse mesmo arquivo, a ação
            % passa a ser de recolhimento para funcionar como toggle visual.
            if strcmp(app.DetailPanel.Visible, 'on') && (app.expandedFileId == fileId)
                resetDetailState(app, false)
                return
            end
        
            % Fora desse caso, segue para a carga do detalhe do arquivo escolhido.
            openFileDetail(app, rowIndex, fileId)
        end
        
        
        function openFileDetail(app, rowIndex, fileId)
            % Consulta os espectros do arquivo selecionado e publica o detalhe no dock.
            %
            % Esse helper materializa a expansão do painel inferior: reaproveita os
            % filtros correntes, busca os espectros associados ao arquivo em foco e
            % sincroniza tabela, resumo e estado visual do detalhe aberto.
            filters = getCurrentFilters(app);
            rawRows = app.UITable.UserData;
        
            try
                % Executa a consulta detalhada já respeitando o mesmo recorte atual
                % aplicado à busca principal do dock.
                detailRows = app.dbHandler.getSpectraByFileId(fileId, filters);
        
                % Publica a tabela inferior e o cabeçalho contextual do arquivo
                % expandido antes de marcar o painel como aberto.
                app.DetailUITable.Data = formatSpectrumDetailResults(app, detailRows);
                app.DetailSummaryLabel.Text = buildDetailSummary(app, rawRows(rowIndex, :), detailRows);
                app.expandedFileId = fileId;
                setDetailPanelVisible(app, true)
            catch ME
                % Em falha de consulta, limpa a área inferior para não manter resíduos
                % de um detalhe anterior e recolhe o painel para estado seguro.
                app.DetailUITable.Data = emptyDetailResultTable(app);
                app.expandedFileId = NaN;
                setDetailPanelVisible(app, false)
        
                % Reporta o erro ao usuário preservando o restante da interface ativa.
                ui.Dialog(app.UIFigure, 'error', sprintf('Erro ao consultar os espectros do arquivo selecionado:\n%s', ME.message));
            end
        end


        function output = buildDetailSummary(app, fileRow, detailRows)
            % Monta o título exibido no painel inferior para o arquivo expandido.
            %
            % Esse helper resume o contexto do detalhe aberto combinando o nome do
            % arquivo selecionado com a quantidade de espectros retornada, para que
            % o cabeçalho da área inferior reflita exatamente o conteúdo publicado.
            fileName = buildRepositoryFileName(app, fileRow);
            spectrumCount = 0;
        
            % Só contabiliza os espectros quando a consulta realmente devolve uma
            % tabela válida, preservando zero como fallback seguro.
            if istable(detailRows)
                spectrumCount = height(detailRows);
            end
        
            % Gera a mensagem final do cabeçalho no mesmo formato usado pelo dock
            % ao abrir ou atualizar o detalhe do arquivo selecionado.
            output = sprintf('Detalhes do arquivo %s (%d espectro(s))', char(fileName), spectrumCount);
        end
        
        function restoreSearchPageState(app)
            % Restaura o estado visual base do dock após mudanças nos filtros principais.
            %
            % Esse helper recoloca a interface no ponto neutro entre uma busca e outra:
            % limpa o resultado anterior, zera os acumuladores visuais e recolhe o
            % detalhe para evitar que a UI mantenha seleções ou dados obsoletos.
            configureTable(app)
        
            % Reinstala na grade principal a estrutura vazia esperada quando ainda
            % não existe um novo resultado válido publicado.
            app.UITable.Data = emptyResultTable(app);
            app.UITable.UserData = table();
        
            % Zera o total agregado para manter o rodapé coerente com a ausência
            % momentânea de resultados após a mudança de filtro.
            app.totalResults = 0;
            updatePaginationState(app)
        
            % Limpa também o estado do painel inferior e a seleção associada ao
            % resultado anterior, que deixa de ser válido após o recálculo.
            resetDetailState(app)
        end
        
        
        function releaseDbHandler(app)
            % Fecha com segurança as conexões mantidas pelo DBHandler do dock.
            %
            % Esse helper é usado no encerramento da aplicação para liberar recursos
            % externos antes da destruição da UI, evitando que conexões com o banco
            % permaneçam abertas depois que o dock for fechado.
            if isempty(app.dbHandler)
                return
            end
        
            try
                % Delega ao próprio handler o fechamento das conexões que ele abriu
                % ao longo da vida útil do dock.
                app.dbHandler = app.dbHandler.closeConnections();
            catch
            end
        
            % Remove a referência local mesmo em caso de falha, para que o ciclo
            % final do app não continue apontando para um handler inválido.
            app.dbHandler = [];
        end

        function setSearchBusyState(app, isBusy)
            if isBusy
                app.BuscarButton.Enable = 'off';
                app.LimparButton.Enable = 'off';
                app.DetailButton.Enable = 'off';
            else
                app.BuscarButton.Enable = 'on';
                app.LimparButton.Enable = 'on';
                updateDetailButtonState(app)
            end
        end

        
        function deleteProgressDialog(~, dlg)
            if ~isempty(dlg) && isvalid(dlg)
                delete(dlg)
            end
        end

        function output = buildRepositoryFilePath(app, row)
            % Monta o caminho completo do arquivo no repositório a partir da pasta e do nome.
            %
            % Esse helper é usado no fluxo de download e visualização para compor o
            % srcPath que alimenta copyfile, combinando o prefixo fixo do servidor
            % com o diretório relativo armazenado no banco e o nome do arquivo.

            % Extrai a subpasta relativa registrada no banco antes de tentar
            % compor o caminho completo no servidor de repositório.
            folder = char(displayText(app, row.NA_PATH, ''));

            % Sem um caminho de pasta válido não é possível localizar o arquivo no
            % sistema de arquivos, então devolve vazio como sinal de metadado ausente.
            if isempty(folder)
                output = '';
                return
            end

            % O RF.Fusion armazena o caminho com o prefixo do ponto de montagem
            % do container Linux (/mnt/reposfi). Esse segmento deve ser removido
            % antes de compor o caminho UNC real no servidor de repositório.
            folder = regexprep(folder, '^[/\\]mnt[/\\]reposfi', '', 'ignorecase');

            % Com a pasta disponível, monta o caminho completo combinando o prefixo
            % fixo do servidor com a subpasta e o nome de arquivo normalizado.
            fileName = buildRepositoryFileName(app, row);
            output = fullfile(class.Constants.repoSFIRoot, folder, char(fileName));
        end

        function notifyCallingAppFiltersChanged(app)
            % Propaga os filtros atuais do dock para o callingApp (winRepoSFI).
            %
            % Chamado pelos callbacks de mudança de filtro para manter os seletores
            % do winRepoSFI sincronizados com o estado corrente do dock, sem
            % precisar roteamento pelo mainApp.

            stateCode = char(getSelectedState(app));

            filters = struct( ...
                'stateCode',   stateCode, ...
                'equipmentId', str2double(string(app.DropDownEquipamento.Value)), ...
                'districtId',  str2double(string(app.DropDownLocalidade.Value)), ...
                'startDate',   app.DatePickerPeriodoInicial.Value, ...
                'endDate',     app.DatePickerPeriodoFinal.Value ...
            );

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onRepoSFIFilterChanged', filters)
        end

        function syncFiltersFromRepoSFI(app, filters)
            % Sincroniza os seletores do dock com os valores vindos do winRepoSFI.
            %
            % Análogo a syncFiltersFromDock no winRepoSFI: atualiza os controles
            % programaticamente (sem disparar callbacks) para refletir os filtros
            % do mapa quando o usuário interage pelo painel do winRepoSFI.
            stateChanged = false;

            % Estado (UF) ------------------------------------------------
            if isfield(filters, 'stateCode')
                newState     = char(filters.stateCode);
                currentState = char(string(app.DropDownEstado.Value));
                if ~strcmp(currentState, newState)
                    if isempty(newState) || any(strcmp(app.DropDownEstado.ItemsData, newState))
                        app.DropDownEstado.Value = newState;
                        stateChanged = true;
                    end
                end
            end

            % Quando o estado mudou, recarrega a lista de equipamentos para
            % que ItemsData fique coerente com a nova UF antes de restaurar
            % a seleção vinda do winRepoSFI.
            if stateChanged
                loadEquipmentOptions(app)
            end

            % Equipamento / sensor ---------------------------------------
            if isfield(filters, 'equipmentId')
                if isnan(filters.equipmentId)
                    if any(strcmp(app.DropDownEquipamento.ItemsData, ''))
                        app.DropDownEquipamento.Value = '';
                    end
                else
                    equipId = char(formatIdValue(app, filters.equipmentId));
                    if any(strcmp(app.DropDownEquipamento.ItemsData, equipId))
                        app.DropDownEquipamento.Value = equipId;
                    end
                end
            end

            % Localidade / Distrito --------------------------------------
            preferredDistrictId = [];
            if isfield(filters, 'districtId') && ~isnan(filters.districtId)
                preferredDistrictId = filters.districtId;
            end

            if stateChanged
                updateLocalityOptions(app, preferredDistrictId)
            else
                if isfield(filters, 'districtId')
                    if isnan(filters.districtId)
                        if any(strcmp(app.DropDownLocalidade.ItemsData, ''))
                            app.DropDownLocalidade.Value = '';
                        end
                    else
                        distId = char(formatIdValue(app, filters.districtId));
                        if any(strcmp(app.DropDownLocalidade.ItemsData, distId))
                            app.DropDownLocalidade.Value = distId;
                        end
                    end
                end
            end

            % Datas — definidas após updateLocalityOptions para não serem
            % sobrescritas por updateAvailablePeriod interno.
            if isfield(filters, 'startDate') && isdatetime(filters.startDate) && ~isnat(filters.startDate)
                app.DatePickerPeriodoInicial.Value = filters.startDate;
            end
            if isfield(filters, 'endDate') && isdatetime(filters.endDate) && ~isnat(filters.endDate)
                app.DatePickerPeriodoFinal.Value = filters.endDate;
            end

            % Limpa os resultados anteriores para refletir os novos filtros.
            restoreSearchPageState(app)
        end


    end



    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, inputArgs)

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                
                % Recupera elementos do winRepoSFI
                app.inputArgs = inputArgs;
                app.mainApp     = mainApp;
                updatePanel(app)

                % Notifica o callingApp (winRepoSFI) com os filtros iniciais do dock.
                % Além de sincronizar o mapa, isso registra app.repoFilesDock no
                % winRepoSFI, estabelecendo o vínculo bidirecional desde a abertura.
                notifyCallingAppFiltersChanged(app)

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            releaseDbHandler(app)
            delete(app)

        end

        % Value changed function: DropDownEquipamento
        function onEquipmentChanged(app, event)
            % Tenta preservar o distrito atualmente selecionado: a localidade
            % pode continuar válida para o novo sensor. updateLocalityOptions
            % descartará silenciosamente se ela não fizer parte da nova lista.
            currentDistrict = app.DropDownLocalidade.Value;
            updateLocalityOptions(app, currentDistrict)
            restoreSearchPageState(app);
            notifyCallingAppFiltersChanged(app)
        end

        % Button pushed function: BuscarButton
        function onSearchClick(app, event)
            d = ui.Dialog(app.UIFigure, 'progressdlg', 'Consultando arquivos do repositório...');
            cleanupProgressDlg = onCleanup(@() deleteProgressDialog(app, d));
            cleanupButtons = onCleanup(@() setSearchBusyState(app, false));
        
            setSearchBusyState(app, true)
            drawnow
        
            resetDetailState(app, false)
            refreshSearchResults(app)
        end

        % Button pushed function: LimparButton
        function onCleanClick(app, event)
            clearFilters(app)
            app.DropDownEstado.Value = '';
            populateStateOptions(app)
            loadEquipmentOptions(app)
            app.DropDownEquipamento.Value = '';
            updateLocalityOptions(app, [])
            restoreSearchPageState(app)
        end

        % Image clicked function: Download
        function DownloadClicked(app, event)
            
            selectedFileRows = app.selectedRowData;
            selectedCount = height(selectedFileRows);

            if selectedCount == 0
                ui.Dialog(app.UIFigure, 'warning', 'Selecione ao menos um arquivo para continuar.');
                return
            end

            questionMsg = sprintf('O que você quer fazer com os %d arquivo(s) selecionado(s)?', selectedCount);
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Download', 'Visualizar', 'Cancelar'}, 1, 3);
            if userSelection == "Cancelar"
                return
            end

            if userSelection == "Download"
                destFolder = app.mainApp.General.fileFolder.userPath;

                d = ui.Dialog(app.UIFigure, 'progressdlg', sprintf('Copiando %d arquivo(s) para:\n%s', selectedCount, destFolder));
                cleanupProgressDlg = onCleanup(@() deleteProgressDialog(app, d));

                successCount = 0;
                errorList    = {};

                for ii = 1:selectedCount
                    fileRow  = selectedFileRows(ii, :);
                    srcPath  = buildRepositoryFilePath(app, fileRow);
                    fileName = buildRepositoryFileName(app, fileRow);

                    if isempty(srcPath)
                        errorList{end+1} = sprintf('Arquivo %d: metadados de caminho ausentes no banco de dados.', ii);
                        continue
                    end

                    destPath = fullfile(destFolder, char(fileName));
                    [status, msg] = copyfile(char(srcPath), destPath);

                    if status
                        successCount = successCount + 1;
                    else
                        errorList{end+1} = sprintf('%s: %s', fileName, msg);
                    end
                end

                deleteProgressDialog(app, d)

                if isempty(errorList)
                    ui.Dialog(app.UIFigure, 'success', sprintf('%d arquivo(s) copiado(s) com sucesso para:\n%s', successCount, destFolder));
                elseif successCount > 0
                    ui.Dialog(app.UIFigure, 'warning', sprintf('%d de %d arquivo(s) copiado(s). Erros:\n%s', successCount, selectedCount, strjoin(errorList, newline)));
                else
                    ui.Dialog(app.UIFigure, 'error', sprintf('Nenhum arquivo copiado. Erros:\n%s', strjoin(errorList, newline)));
                end

            else  % "Visualizar"
                tempFolder = app.mainApp.General.fileFolder.tempPath;

                d = ui.Dialog(app.UIFigure, 'progressdlg', sprintf('Preparando %d arquivo(s) para visualização...', selectedCount));
                cleanupProgressDlg = onCleanup(@() deleteProgressDialog(app, d));

                copiedPaths = {};
                errorList   = {};

                for ii = 1:selectedCount
                    fileRow  = selectedFileRows(ii, :);
                    srcPath  = buildRepositoryFilePath(app, fileRow);
                    fileName = buildRepositoryFileName(app, fileRow);

                    if isempty(srcPath)
                        errorList{end+1} = sprintf('Arquivo %d: metadados de caminho ausentes no banco de dados.', ii);
                        continue
                    end

                    destPath = fullfile(tempFolder, char(fileName));
                    [status, msg] = copyfile(char(srcPath), destPath);

                    if status
                        copiedPaths{end+1} = destPath;
                    else
                        errorList{end+1} = sprintf('%s: %s', fileName, msg);
                    end
                end

                deleteProgressDialog(app, d)

                if ~isempty(errorList)
                    ui.Dialog(app.UIFigure, 'warning', sprintf('Alguns arquivos não puderam ser preparados:\n%s', strjoin(errorList, newline)));
                end

                if ~isempty(copiedPaths)
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onImportFilesFromPaths', copiedPaths)
                end
            end

        end

        % Cell selection callback: UITable
        function onTableSelection(app, event)
            rowIndices = zeros(1, 0);
            selectedFileRows = table();
            rawRows = app.UITable.UserData;

            if ~isempty(event.Indices)
                rowIndices = unique(event.Indices(:, 1), 'stable')';
                app.selectedDetailRow = event.Indices(end, 1);

                if istable(rawRows) && ~isempty(rawRows)
                    validMask = (rowIndices >= 1) & (rowIndices <= height(rawRows));
                    rowIndices = rowIndices(validMask);

                    if ~isempty(rowIndices)
                        selectedFileRows = rawRows(rowIndices, :);
                    end
                end
            else
                app.selectedDetailRow = NaN;
            end
        
            app.selectedRows = rowIndices;
            app.selectedRowData = selectedFileRows;

            if numel(app.selectedRows) == 1 && strcmp(app.DetailPanel.Visible, 'on')
                toggleSelectedFileDetail(app)
            end

            if numel(app.selectedRows) ~= 1 && strcmp(app.DetailPanel.Visible, 'on')
                app.expandedFileId = NaN;
                app.DetailUITable.Data = emptyDetailResultTable(app);
                app.DetailSummaryLabel.Text = 'Detalhes do arquivo';
                setDetailPanelVisible(app, false)
            end
            app.SelectedRowsLabel.Text = sprintf('%d arquivo(s) selecionado(s)', numel(app.selectedRows));
            updateDetailButtonState(app)
            
        end

        % Button pushed function: DetailButton
        function onDetailClick(app, event)
            toggleSelectedFileDetail(app)
        end

        % Value changed function: DatePickerPeriodoFinal, 
        % ...and 4 other components
        function onSearchFilterChanged(app, event)
            resetDetailState(app, false);
            if ismember(event.Source, [app.DatePickerPeriodoInicial, app.DatePickerPeriodoFinal])
                notifyCallingAppFiltersChanged(app)
            end
            
        end

        % Value changed function: DropDownEstado
        function onStateChanged(app, event)
           % Estado mudou: recarrega equipamentos e localidades restritos à UF.
            loadEquipmentOptions(app)
            updateLocalityOptions(app, [])
            updateAvailablePeriod(app)
            restoreSearchPageState(app)
            notifyCallingAppFiltersChanged(app)
            
        end

        % Value changed function: DropDownLocalidade
        function onLocalityChanged(app, event)
           % Localidade mudou: recarrega equipamentos que visitaram este site
            % e atualiza o período disponível para a seleção atual.
            loadEquipmentOptions(app)

            if isnan(str2double(string(app.DropDownLocalidade.Value)))
                % "Todas as localidades" selecionado: recarrega todas as localidades
                % disponíveis para o estado corrente, sem restringir ao equipamento.
                updateLocalityOptions(app, [], NaN)
            else
                updateLocalityOptions(app, app.DropDownLocalidade.Value)
            end

            updateAvailablePeriod(app)
            restoreSearchPageState(app)
            notifyCallingAppFiltersChanged(app)
            
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
                app.UIFigure.Position = [100 100 940 580];
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
            app.GridLayout.ColumnWidth = {18, '1x', '1x', 18, 18, 90};
            app.GridLayout.RowHeight = {17, 148, '1x', 0, 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'ID'; 'Plano'; 'Equipamento'; 'Localidade'; 'Faixa(MHz)'; 'Início'; 'Fim'; 'Arquivo Oficial'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.CellSelectionCallback = createCallbackFcn(app, @onTableSelection, true);
            app.UITable.Layout.Row = 3;
            app.UITable.Layout.Column = [1 6];
            app.UITable.FontSize = 11;

            % Create Panel
            app.Panel = uipanel(app.GridLayout);
            app.Panel.AutoResizeChildren = 'off';
            app.Panel.Layout.Row = [1 2];
            app.Panel.Layout.Column = [1 6];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel);
            app.GridLayout2.ColumnWidth = {150, 150, '1x', 49, 49, 49};
            app.GridLayout2.RowHeight = {17, 22, 22, 22, 22, 22};
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create LabelPeriodoInicial
            app.LabelPeriodoInicial = uilabel(app.GridLayout2);
            app.LabelPeriodoInicial.VerticalAlignment = 'bottom';
            app.LabelPeriodoInicial.FontSize = 11;
            app.LabelPeriodoInicial.Layout.Row = 3;
            app.LabelPeriodoInicial.Layout.Column = 1;
            app.LabelPeriodoInicial.Text = 'Período inicial:';

            % Create DatePickerPeriodoInicial
            app.DatePickerPeriodoInicial = uidatepicker(app.GridLayout2);
            app.DatePickerPeriodoInicial.ValueChangedFcn = createCallbackFcn(app, @onSearchFilterChanged, true);
            app.DatePickerPeriodoInicial.FontSize = 11;
            app.DatePickerPeriodoInicial.Layout.Row = 4;
            app.DatePickerPeriodoInicial.Layout.Column = 1;

            % Create LabelEquipamento
            app.LabelEquipamento = uilabel(app.GridLayout2);
            app.LabelEquipamento.VerticalAlignment = 'bottom';
            app.LabelEquipamento.FontSize = 11;
            app.LabelEquipamento.Layout.Row = 1;
            app.LabelEquipamento.Layout.Column = [3 6];
            app.LabelEquipamento.Text = 'Sensor:';

            % Create DropDownEquipamento
            app.DropDownEquipamento = uidropdown(app.GridLayout2);
            app.DropDownEquipamento.Items = {};
            app.DropDownEquipamento.ValueChangedFcn = createCallbackFcn(app, @onEquipmentChanged, true);
            app.DropDownEquipamento.FontSize = 11;
            app.DropDownEquipamento.BackgroundColor = [1 1 1];
            app.DropDownEquipamento.Layout.Row = 2;
            app.DropDownEquipamento.Layout.Column = [3 6];
            app.DropDownEquipamento.Value = {};

            % Create LabelLocalidade
            app.LabelLocalidade = uilabel(app.GridLayout2);
            app.LabelLocalidade.VerticalAlignment = 'bottom';
            app.LabelLocalidade.FontSize = 11;
            app.LabelLocalidade.Layout.Row = 1;
            app.LabelLocalidade.Layout.Column = 2;
            app.LabelLocalidade.Text = 'Distrito';

            % Create DropDownLocalidade
            app.DropDownLocalidade = uidropdown(app.GridLayout2);
            app.DropDownLocalidade.Items = {};
            app.DropDownLocalidade.ValueChangedFcn = createCallbackFcn(app, @onLocalityChanged, true);
            app.DropDownLocalidade.FontSize = 11;
            app.DropDownLocalidade.BackgroundColor = [1 1 1];
            app.DropDownLocalidade.Layout.Row = 2;
            app.DropDownLocalidade.Layout.Column = 2;
            app.DropDownLocalidade.Value = {};

            % Create LabelPeriodoFinal
            app.LabelPeriodoFinal = uilabel(app.GridLayout2);
            app.LabelPeriodoFinal.VerticalAlignment = 'bottom';
            app.LabelPeriodoFinal.FontSize = 11;
            app.LabelPeriodoFinal.Layout.Row = 3;
            app.LabelPeriodoFinal.Layout.Column = 2;
            app.LabelPeriodoFinal.Text = 'Período final:';

            % Create DatePickerPeriodoFinal
            app.DatePickerPeriodoFinal = uidatepicker(app.GridLayout2);
            app.DatePickerPeriodoFinal.ValueChangedFcn = createCallbackFcn(app, @onSearchFilterChanged, true);
            app.DatePickerPeriodoFinal.FontSize = 11;
            app.DatePickerPeriodoFinal.Layout.Row = 4;
            app.DatePickerPeriodoFinal.Layout.Column = 2;

            % Create LabelFrequenciaInicial
            app.LabelFrequenciaInicial = uilabel(app.GridLayout2);
            app.LabelFrequenciaInicial.VerticalAlignment = 'bottom';
            app.LabelFrequenciaInicial.FontSize = 11;
            app.LabelFrequenciaInicial.Layout.Row = 5;
            app.LabelFrequenciaInicial.Layout.Column = 1;
            app.LabelFrequenciaInicial.Text = 'Frequência inicial (MHz):';

            % Create EditFieldFrequenciaInicial
            app.EditFieldFrequenciaInicial = uieditfield(app.GridLayout2, 'numeric');
            app.EditFieldFrequenciaInicial.Limits = [20 18000];
            app.EditFieldFrequenciaInicial.ValueDisplayFormat = '%.3f';
            app.EditFieldFrequenciaInicial.AllowEmpty = 'on';
            app.EditFieldFrequenciaInicial.ValueChangedFcn = createCallbackFcn(app, @onSearchFilterChanged, true);
            app.EditFieldFrequenciaInicial.FontSize = 11;
            app.EditFieldFrequenciaInicial.Layout.Row = 6;
            app.EditFieldFrequenciaInicial.Layout.Column = 1;
            app.EditFieldFrequenciaInicial.Value = [];

            % Create LabelFrequenciaFinal
            app.LabelFrequenciaFinal = uilabel(app.GridLayout2);
            app.LabelFrequenciaFinal.VerticalAlignment = 'bottom';
            app.LabelFrequenciaFinal.FontSize = 11;
            app.LabelFrequenciaFinal.Layout.Row = 5;
            app.LabelFrequenciaFinal.Layout.Column = 2;
            app.LabelFrequenciaFinal.Text = 'Frequência final (MH):';

            % Create EditFieldFrequenciaFinal
            app.EditFieldFrequenciaFinal = uieditfield(app.GridLayout2, 'numeric');
            app.EditFieldFrequenciaFinal.Limits = [20 18000];
            app.EditFieldFrequenciaFinal.ValueDisplayFormat = '%.3f';
            app.EditFieldFrequenciaFinal.AllowEmpty = 'on';
            app.EditFieldFrequenciaFinal.ValueChangedFcn = createCallbackFcn(app, @onSearchFilterChanged, true);
            app.EditFieldFrequenciaFinal.FontSize = 11;
            app.EditFieldFrequenciaFinal.Layout.Row = 6;
            app.EditFieldFrequenciaFinal.Layout.Column = 2;
            app.EditFieldFrequenciaFinal.Value = [];

            % Create LabelPlanoDescricao
            app.LabelPlanoDescricao = uilabel(app.GridLayout2);
            app.LabelPlanoDescricao.VerticalAlignment = 'bottom';
            app.LabelPlanoDescricao.FontSize = 11;
            app.LabelPlanoDescricao.Layout.Row = 3;
            app.LabelPlanoDescricao.Layout.Column = [3 5];
            app.LabelPlanoDescricao.Text = 'Plano/Descrição';

            % Create EditFieldPlanoDescricao
            app.EditFieldPlanoDescricao = uieditfield(app.GridLayout2, 'text');
            app.EditFieldPlanoDescricao.ValueChangedFcn = createCallbackFcn(app, @onSearchFilterChanged, true);
            app.EditFieldPlanoDescricao.FontSize = 11;
            app.EditFieldPlanoDescricao.Placeholder = 'Ex. %PMEC% ou parte do nome';
            app.EditFieldPlanoDescricao.Layout.Row = 4;
            app.EditFieldPlanoDescricao.Layout.Column = [3 6];

            % Create BuscarButton
            app.BuscarButton = uibutton(app.GridLayout2, 'push');
            app.BuscarButton.ButtonPushedFcn = createCallbackFcn(app, @onSearchClick, true);
            app.BuscarButton.Icon = 'icon_search.svg';
            app.BuscarButton.IconAlignment = 'top';
            app.BuscarButton.FontSize = 11;
            app.BuscarButton.Layout.Row = [5 6];
            app.BuscarButton.Layout.Column = 4;
            app.BuscarButton.Text = 'Buscar';

            % Create LimparButton
            app.LimparButton = uibutton(app.GridLayout2, 'push');
            app.LimparButton.ButtonPushedFcn = createCallbackFcn(app, @onCleanClick, true);
            app.LimparButton.Icon = 'icon_clean.svg';
            app.LimparButton.IconAlignment = 'top';
            app.LimparButton.FontSize = 11;
            app.LimparButton.Layout.Row = [5 6];
            app.LimparButton.Layout.Column = 5;
            app.LimparButton.Text = 'Limpar';

            % Create DetailButton
            app.DetailButton = uibutton(app.GridLayout2, 'push');
            app.DetailButton.ButtonPushedFcn = createCallbackFcn(app, @onDetailClick, true);
            app.DetailButton.Icon = 'icon_detail.svg';
            app.DetailButton.IconAlignment = 'top';
            app.DetailButton.FontSize = 11;
            app.DetailButton.Layout.Row = [5 6];
            app.DetailButton.Layout.Column = 6;
            app.DetailButton.Text = 'Detalhe';

            % Create EstadoLabel
            app.EstadoLabel = uilabel(app.GridLayout2);
            app.EstadoLabel.FontSize = 11;
            app.EstadoLabel.Layout.Row = 1;
            app.EstadoLabel.Layout.Column = 1;
            app.EstadoLabel.Text = 'Estado';

            % Create DropDownEstado
            app.DropDownEstado = uidropdown(app.GridLayout2);
            app.DropDownEstado.Items = {};
            app.DropDownEstado.ValueChangedFcn = createCallbackFcn(app, @onStateChanged, true);
            app.DropDownEstado.FontSize = 11;
            app.DropDownEstado.BackgroundColor = [1 1 1];
            app.DropDownEstado.Layout.Row = 2;
            app.DropDownEstado.Layout.Column = 1;
            app.DropDownEstado.Value = {};

            % Create LabelTotalPaginas
            app.LabelTotalPaginas = uilabel(app.GridLayout);
            app.LabelTotalPaginas.HorizontalAlignment = 'right';
            app.LabelTotalPaginas.Layout.Row = 5;
            app.LabelTotalPaginas.Layout.Column = [3 6];
            app.LabelTotalPaginas.Text = 'Selecionado (0) Elementos';

            % Create Download
            app.Download = uiimage(app.GridLayout);
            app.Download.ScaleMethod = 'none';
            app.Download.ImageClickedFcn = createCallbackFcn(app, @DownloadClicked, true);
            app.Download.Layout.Row = 5;
            app.Download.Layout.Column = 1;
            app.Download.ImageSource = 'Import_16.png';

            % Create SelectedRowsLabel
            app.SelectedRowsLabel = uilabel(app.GridLayout);
            app.SelectedRowsLabel.Layout.Row = 5;
            app.SelectedRowsLabel.Layout.Column = 2;
            app.SelectedRowsLabel.Text = '(0) Linhas Selecionadas';

            % Create DetailPanel
            app.DetailPanel = uipanel(app.GridLayout);
            app.DetailPanel.AutoResizeChildren = 'off';
            app.DetailPanel.Visible = 'off';
            app.DetailPanel.Layout.Row = 4;
            app.DetailPanel.Layout.Column = [1 6];

            % Create DetailGridLayout
            app.DetailGridLayout = uigridlayout(app.DetailPanel);
            app.DetailGridLayout.ColumnWidth = {'1x'};
            app.DetailGridLayout.RowHeight = {20, '1x'};
            app.DetailGridLayout.Padding = [5 5 5 5];

            % Create DetailSummaryLabel
            app.DetailSummaryLabel = uilabel(app.DetailGridLayout);
            app.DetailSummaryLabel.FontSize = 11;
            app.DetailSummaryLabel.Layout.Row = 1;
            app.DetailSummaryLabel.Layout.Column = 1;
            app.DetailSummaryLabel.Text = 'Detalhes do arquivo';

            % Create DetailUITable
            app.DetailUITable = uitable(app.DetailGridLayout);
            app.DetailUITable.ColumnName = {'ID Espectro'; 'Descrição'; 'Localidade'; 'Faixa (MHz)'; 'Início'; 'Fim'};
            app.DetailUITable.RowName = {};
            app.DetailUITable.Layout.Row = 2;
            app.DetailUITable.Layout.Column = 1;
            app.DetailUITable.FontSize = 11;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockRepoFiles_exported(Container, varargin)

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
