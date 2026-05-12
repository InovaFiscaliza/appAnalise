classdef dockRepoFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        INDICAQUANTASLINHASSELECIONADASLabel  matlab.ui.control.Label
        Image                       matlab.ui.control.Image
        LabelTotalPaginas           matlab.ui.control.Label
        Panel                       matlab.ui.container.Panel
        GridLayout2                 matlab.ui.container.GridLayout
        LimparButton                matlab.ui.control.Button
        SearchButton                matlab.ui.control.Button
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
        currentPage = 1
        pageSize = 50
        hasNextPage = false
        totalPages = 1
        totalResults = 0

        columnNameMapping = dictionary([ ...
            "NOME_1", "NOME_2"],...
            ["NOME_BONITO_1", "NOME_BONITO_2"] ...
        )
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % Funções de incialização e configurações iniciais do layout da
        % pagina
        %-----------------------------------------------------------------%
        function updatePanel(app)
            % Inicializa o painel e dispara a primeira consulta contextual.
            if isempty(app.dbHandler)
                app.dbHandler = util.DBHandler();
            end

            configureTable(app)
            initializeFilters(app)
            loadEquipmentOptions(app)
            updateLocalityOptions(app, getContextValue(app, 'siteId'))
            refreshSearchResults(app)
        end


        function configureTable(app)
            % Configura a aparência e o comportamento base da tabela que exibe os
            % resultados das consultas no dock.

            app.UITable.ColumnName = {'ID Arquivo'; 'Arquivo'; 'Localidades'; 'Qtd. Espectros'; 'Faixa (MHz)'; 'Início'; 'Fim'; 'Caminho'};
            app.UITable.ColumnWidth = {75, 220, 210, 105, 120, 135, 135, 'auto'};

        end


        function initializeFilters(app)
            % Inicializa os filtros da tela a partir do contexto recebido na abertura
            % do dock e limpa o resumo do resultado atual.
            app.totalResults = 0;

            % Preenche o período inicial e final convertendo os valores crus do
            % contexto para datetime, quando disponíveis.
            app.DatePickerPeriodoInicial.Value = rawToDatetime(app, getContextValue(app, 'startDate'));
            app.DatePickerPeriodoFinal.Value = rawToDatetime(app, getContextValue(app, 'endDate'));

            app.EditFieldFrequenciaInicial.Value = rawToFiniteNumber(app, getContextValue(app, 'freqStart'), 20, 18000);
            app.EditFieldFrequenciaFinal.Value = rawToFiniteNumber(app, getContextValue(app, 'freqEnd'), 20, 18000);

            % Carrega a descrição textual associada ao contexto da consulta.
            app.EditFieldPlanoDescricao.Value = char(normalizedContextText(app, 'description', ""));
        end

        %-----------------------------------------------------------------%
        % Popula informações inicias dos filrtos de buscas
        %-----------------------------------------------------------------%

        function loadEquipmentOptions(app)
            % Carrega o catalogo de equipamentos observado no repositório.
            rows = app.dbHandler.getSpectrumEquipments();
            items = {'Selecione uma estação/equipamento'};
            itemsData = {''};

            if istable(rows) && ~isempty(rows)
                for ii = 1:height(rows)
                    equipmentId = formatIdValue(app, rows.ID_EQUIPMENT(ii));
                    equipmentName = displayText(app, rows.NA_EQUIPMENT(ii), '(sem nome)');
                    items{end + 1} = char(equipmentName); %#ok<AGROW>
                    itemsData{end + 1} = char(equipmentId); %#ok<AGROW>
                end
            end

            app.DropDownEquipamento.Items = items;
            app.DropDownEquipamento.ItemsData = itemsData;

            contextEquipmentId = formatIdValue(app, getContextValue(app, 'equipmentId'));
            if ~isempty(contextEquipmentId) && strlength(contextEquipmentId) > 0 && any(strcmp(itemsData, char(contextEquipmentId)))
                app.DropDownEquipamento.Value = char(contextEquipmentId);
            else
                app.DropDownEquipamento.Value = '';
            end
        end


        function updateLocalityOptions(app, preferredSiteId)
            % Recarrega as opções de localidade com base no equipamento atualmente
            % selecionado e, quando possível, restaura uma localidade preferencial.

            % Obtém o identificador numérico do equipamento selecionado no filtro.
            equipmentId = selectedNumericValue(app, app.DropDownEquipamento);

            % Inicia a lista com a opção neutra, que representa consulta sem
            % restrição por localidade.
            items = {'Todas as localidades'};
            itemsData = {''};

            % Só consulta as localidades se houver um equipamento válido
            % selecionado.
            if ~isnan(equipmentId)
                rows = app.dbHandler.getSpectrumLocalities(equipmentId, getCurrentFilters(app));

                % Converte cada linha retornada pelo banco em uma opção do dropdown:
                % - o texto exibido ao usuário
                % - o siteId correspondente usado internamente como valor
                if istable(rows) && ~isempty(rows)
                    for ii = 1:height(rows)
                        siteId = formatIdValue(app, rows.ID_SITE(ii));
                        localityLabel = formatLocalityOption(app, rows(ii, :));
                        items{end + 1} = char(localityLabel); %#ok<AGROW>
                        itemsData{end + 1} = char(siteId); %#ok<AGROW>
                    end
                end
            end

            % Atualiza o dropdown com o conjunto recém-montado de localidades.
            app.DropDownLocalidade.Items = items;
            app.DropDownLocalidade.ItemsData = itemsData;

            % Tenta restaurar a localidade preferencial recebida pelo chamador.
            % Se ela não existir nas opções atuais, volta para a opção neutra.
            preferredSiteId = formatIdValue(app, preferredSiteId);
            if strlength(preferredSiteId) > 0 && any(strcmp(itemsData, char(preferredSiteId)))
                app.DropDownLocalidade.Value = char(preferredSiteId);
            else
                app.DropDownLocalidade.Value = '';
            end
        end

        %-----------------------------------------------------------------%
        % Execução da pesquisa em banco
        %-----------------------------------------------------------------%
        function refreshSearchResults(app)
            % Executa a consulta atual com base nos filtros da tela, atualiza a
            % tabela de resultados em uma única carga.

            % Captura o snapshot atual dos filtros visíveis na interface.
            filters = getCurrentFilters(app);

            % Sem equipamento válido não existe consulta possível. Nesse caso a
            % tabela é limpa e a paginação volta para o estado vazio padrão.
            if isnan(filters.equipmentId)
                app.UITable.Data = emptyResultTable(app);
                app.UITable.UserData = table();
                app.totalResults = 0;
                updatePaginationState(app)
                return
            end

            try
                % Primeiro mede o universo filtrado para então carregar tudo em
                % uma única consulta, sem navegação por páginas.
                app.totalResults = app.dbHandler.getSpectrumFileDataCount(filters);

                filters.page = 1;
                filters.pageSize = max(app.totalResults, 1);

                % O resultado do dock sempre é orientado a arquivo: a busca filtra
                % espectros e então colapsa a página para uma linha por arquivo.
                rawRows = app.dbHandler.getSpectrumFileData(filters);

                app.UITable.Data = formatFileResults(app, rawRows);

                % Mantém os dados originais associados à tabela para suportar ações
                % posteriores que precisem do registro completo selecionado.
                app.UITable.UserData = rawRows;

                % Atualiza rótulos, botões e demais elementos visuais da paginação.
                updatePaginationState(app)
            catch ME
                % Em caso de falha, limpa a tabela, reseta a paginação e informa o
                % erro ao usuário sem deixar a interface em estado inconsistente.
                app.UITable.Data = emptyResultTable(app);
                app.UITable.UserData = table();
                app.totalResults = 0;
                updatePaginationState(app)
                ui.Dialog(app.UIFigure, 'error', sprintf('Erro ao consultar arquivos do repositório:\n%s', ME.message));
            end
        end

        function filters = getCurrentFilters(app)
            % Consolida o estado da UI no contrato esperado pelo DBHandler.
            filters = struct( ...
                'equipmentId', selectedNumericValue(app, app.DropDownEquipamento), ...
                'siteId', selectedNumericValue(app, app.DropDownLocalidade), ...
                'startDate', app.DatePickerPeriodoInicial.Value, ...
                'endDate', app.DatePickerPeriodoFinal.Value, ...
                'freqStart', app.EditFieldFrequenciaInicial.Value, ...
                'freqEnd', app.EditFieldFrequenciaFinal.Value, ...
                'description', strtrim(string(app.EditFieldPlanoDescricao.Value)) ...
                );

            if isempty(filters.freqStart) || ~isfinite(filters.freqStart) || (filters.freqStart < 0)
                filters.freqStart = NaN;
            end

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
            % Converte o resultado bruto da consulta por arquivo para o formato
            % tabular exibido pela UITable.
            if ~istable(rawRows) || isempty(rawRows)
                output = emptyResultTable(app);
                return
            end

            % Pré-aloca as colunas exibidas para montar a saída final de forma
            % explícita e previsível.
            nRows = height(rawRows);
            id = strings(nRows, 1);
            fileName = strings(nRows, 1);
            localities = strings(nRows, 1);
            spectrumCount = strings(nRows, 1);
            band = strings(nRows, 1);
            startAt = strings(nRows, 1);
            endAt = strings(nRows, 1);
            pathValue = strings(nRows, 1);

            % Normaliza os campos retornados pelo banco para uma apresentação mais
            % amigável e consistente na tabela.
            for ii = 1:nRows
                id(ii) = formatIdValue(app, rawRows.ID_FILE(ii));
                fileName(ii) = buildRepositoryFileName(app, rawRows(ii, :));
                localities(ii) = displayText(app, rawRows.LOCALITY_LABELS(ii), '-');
                spectrumCount(ii) = formatIdValue(app, rawRows.NU_SPECTRA(ii));
                band(ii) = formatFrequencyRange(app, rawRows.NU_FREQ_START(ii), rawRows.NU_FREQ_END(ii));
                startAt(ii) = formatDateValue(app, rawRows.DT_TIME_START(ii));
                endAt(ii) = formatDateValue(app, rawRows.DT_TIME_END(ii));
                pathValue(ii) = displayText(app, rawRows.NA_PATH(ii), '-');
            end

            output = table(id, fileName, localities, spectrumCount, band, startAt, endAt, pathValue, ...
                'VariableNames', {'IDArquivo', 'Arquivo', 'Localidades', 'QtdEspectros', 'FaixaMHz', 'Inicio', 'Fim', 'Caminho'});
        end

        function output = emptyResultTable(~)
            % Cria uma tabela vazia com o layout fixo da busca orientada a arquivo.
            output = table(strings(0, 1), strings(0, 1), strings(0, 1), strings(0, 1), ...
                strings(0, 1), strings(0, 1), strings(0, 1), strings(0, 1), ...
                'VariableNames', {'IDArquivo', 'Arquivo', 'Localidades', 'QtdEspectros', 'FaixaMHz', 'Inicio', 'Fim', 'Caminho'});
        end

        %------------------------------------------------------------------
        % Funções auxiliares de consistência e conversão de formatos de
        % dados
        %------------------------------------------------------------------
        function output = selectedNumericValue(~, dropDownHandle)
            % Converte o valor atualmente selecionado em um dropdown para número.
            % Quando a conversão não é possível, retorna NaN como sinalização padrão.
            output = str2double(string(dropDownHandle.Value));
            if isnan(output)
                output = NaN;
            end
        end

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

        function output = normalizedContextText(app, fieldName, defaultValue)
            % Lê um campo textual do contexto e devolve uma versão normalizada:
            % escalar, sem células aninhadas, sem missing e sem espaços sobrando.
            % Se nada válido for encontrado, retorna o valor padrão informado.
            if nargin < 3
                defaultValue = "";
            end

            rawValue = getContextValue(app, fieldName);
            output = string(defaultValue);

            % Desempacota células sucessivas para chegar ao valor efetivo.
            while iscell(rawValue)
                if isempty(rawValue)
                    return
                end
                rawValue = rawValue{1};
            end

            if isempty(rawValue)
                return
            end

            % Normaliza para string e elimina entradas vazias/inválidas.
            textValue = string(rawValue);
            textValue = textValue(~ismissing(textValue));
            textValue = strtrim(textValue);
            textValue = textValue(strlength(textValue) > 0);

            if isempty(textValue)
                return
            end

            % Mantém apenas o primeiro valor útil, porque o consumo do contexto no
            % dock espera sempre um texto escalar.
            output = textValue(1);
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



        

        function output = formatLocalityOption(app, row)
            % Mantém um ponto único para formatar a localidade no contexto de opções
            % de dropdown, reaproveitando a mesma regra usada na exibição em tabela.
            output = formatLocalityDisplay(app, row);
        end


        function output = formatLocalityDisplay(app, row)
            label = displayText(app, row.LOCALITY_LABEL, '-');
            county = displayText(app, row.COUNTY_NAME, '');
            stateCode = displayText(app, row.STATE_CODE, '');

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
            startText = formatNumericValue(app, startFreq, 3);
            endText = formatNumericValue(app, endFreq, 3);

            if strlength(startText) == 0 && strlength(endText) == 0
                output = "-";
            elseif strlength(endText) == 0
                output = startText;
            else
                output = startText + " - " + endText;
            end
        end

        function output = formatNumericValue(~, rawValue, precision)
            numericValue = str2double(string(rawValue));
            if isnan(numericValue)
                output = "";
                return
            end

            output = string(sprintf(['%0.', num2str(precision), 'f'], numericValue));
            output = regexprep(output, '([\.,]0+)$', '');
            output = regexprep(output, '[\.,]$', '');
        end

        function output = buildRepositoryFileName(app, row)
            fileName = displayText(app, row.NA_FILE, '');
            extension = displayText(app, row.NA_EXTENSION, '');

            if strlength(extension) > 0 && startsWith(extension, '.') == 0
                extension = "." + extension;
            end

            if strlength(fileName) == 0
                output = '-';
            elseif endsWith(fileName, extension)
                output = fileName;
            else
                output = fileName + extension;
            end
        end

        function output = formatDateValue(~, rawValue)
            value = rawValue;

            while iscell(value)
                if isempty(value)
                    output = "-";
                    return
                end
                value = value{1};
            end

            if isempty(value)
                output = "-";
                return
            end

            try
                if ~isdatetime(value)
                    value = datetime(value);
                end
            catch
                output = string(value);
                return
            end

            if isnat(value)
                output = "-";
            else
                output = string(value(1), 'dd-MMM-yyyy HH:mm:ss');
            end
        end

        function output = displayText(~, rawValue, defaultValue)
            if nargin < 3
                defaultValue = "";
            end

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

        function output = formatIdValue(~, rawValue)
            numericValue = str2double(string(rawValue));
            if isnan(numericValue)
                output = "";
            else
                output = string(round(numericValue));
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, inputArgs)

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = inputArgs;
                updatePanel(app)

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            delete(app)

        end

        % Value changed function: DropDownEquipamento
        function onEquipmentChanged(app, event)
            updateLocalityOptions(app, [])
            app.UITable.Data = emptyResultTable(app);

        end

        % Button pushed function: SearchButton
        function onSearchClick(app, event)
            refreshSearchResults(app)
        end

        % Button pushed function: LimparButton
        function onCleanClick(app, event)
            initializeFilters(app)
            loadEquipmentOptions(app)
            updateLocalityOptions(app, getContextValue(app, 'siteId'))
            refreshSearchResults(app)
        end

        % Image clicked function: Image
        function ImageClicked(app, event)
            
            % o QUE VOCÊ QUER FAZER?
            questionMsg = 'O que você quer fazer com os n arquivos selecionados?';
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Download', 'Visualizar', 'Cancelar'}, 1, 3);
            if userSelection == "Cancelar"
                return
            end

            userSelection;

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
            app.GridLayout.ColumnWidth = {18, '1x', '1x', 18, 18, 70};
            app.GridLayout.RowHeight = {17, 148, '1x', 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'ID'; 'Plano'; 'Equipamento'; 'Localidade'; 'Faixa(MHz)'; 'Início'; 'Fim'; 'Arquivo Oficial'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
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
            app.GridLayout2.ColumnWidth = {150, 150, '1x', 49, 49};
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
            app.DatePickerPeriodoInicial.FontSize = 11;
            app.DatePickerPeriodoInicial.Layout.Row = 4;
            app.DatePickerPeriodoInicial.Layout.Column = 1;

            % Create LabelEquipamento
            app.LabelEquipamento = uilabel(app.GridLayout2);
            app.LabelEquipamento.VerticalAlignment = 'bottom';
            app.LabelEquipamento.FontSize = 11;
            app.LabelEquipamento.Layout.Row = 1;
            app.LabelEquipamento.Layout.Column = 1;
            app.LabelEquipamento.Text = 'Sensor:';

            % Create DropDownEquipamento
            app.DropDownEquipamento = uidropdown(app.GridLayout2);
            app.DropDownEquipamento.Items = {};
            app.DropDownEquipamento.ValueChangedFcn = createCallbackFcn(app, @onEquipmentChanged, true);
            app.DropDownEquipamento.FontSize = 11;
            app.DropDownEquipamento.BackgroundColor = [1 1 1];
            app.DropDownEquipamento.Layout.Row = 2;
            app.DropDownEquipamento.Layout.Column = [1 2];
            app.DropDownEquipamento.Value = {};

            % Create LabelLocalidade
            app.LabelLocalidade = uilabel(app.GridLayout2);
            app.LabelLocalidade.VerticalAlignment = 'bottom';
            app.LabelLocalidade.FontSize = 11;
            app.LabelLocalidade.Layout.Row = 1;
            app.LabelLocalidade.Layout.Column = [3 5];
            app.LabelLocalidade.Text = 'Localidade:';

            % Create DropDownLocalidade
            app.DropDownLocalidade = uidropdown(app.GridLayout2);
            app.DropDownLocalidade.Items = {};
            app.DropDownLocalidade.FontSize = 11;
            app.DropDownLocalidade.BackgroundColor = [1 1 1];
            app.DropDownLocalidade.Layout.Row = 2;
            app.DropDownLocalidade.Layout.Column = [3 5];
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
            app.EditFieldPlanoDescricao.FontSize = 11;
            app.EditFieldPlanoDescricao.Placeholder = 'Ex. %PMEC% ou parte do nome';
            app.EditFieldPlanoDescricao.Layout.Row = 4;
            app.EditFieldPlanoDescricao.Layout.Column = [3 5];

            % Create SearchButton
            app.SearchButton = uibutton(app.GridLayout2, 'push');
            app.SearchButton.ButtonPushedFcn = createCallbackFcn(app, @onSearchClick, true);
            app.SearchButton.Icon = 'Add_16.png';
            app.SearchButton.IconAlignment = 'top';
            app.SearchButton.Layout.Row = [5 6];
            app.SearchButton.Layout.Column = 4;
            app.SearchButton.Text = 'Search';

            % Create LimparButton
            app.LimparButton = uibutton(app.GridLayout2, 'push');
            app.LimparButton.ButtonPushedFcn = createCallbackFcn(app, @onCleanClick, true);
            app.LimparButton.Icon = 'Add_16.png';
            app.LimparButton.IconAlignment = 'top';
            app.LimparButton.Layout.Row = [5 6];
            app.LimparButton.Layout.Column = 5;
            app.LimparButton.Text = 'Limpar';

            % Create LabelTotalPaginas
            app.LabelTotalPaginas = uilabel(app.GridLayout);
            app.LabelTotalPaginas.HorizontalAlignment = 'right';
            app.LabelTotalPaginas.Layout.Row = 4;
            app.LabelTotalPaginas.Layout.Column = [3 6];
            app.LabelTotalPaginas.Text = 'Selecionado (0) Elementos';

            % Create Image
            app.Image = uiimage(app.GridLayout);
            app.Image.ScaleMethod = 'none';
            app.Image.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.Image.Layout.Row = 4;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = 'Import_16.png';

            % Create INDICAQUANTASLINHASSELECIONADASLabel
            app.INDICAQUANTASLINHASSELECIONADASLabel = uilabel(app.GridLayout);
            app.INDICAQUANTASLINHASSELECIONADASLabel.Layout.Row = 4;
            app.INDICAQUANTASLINHASSELECIONADASLabel.Layout.Column = 2;
            app.INDICAQUANTASLINHASSELECIONADASLabel.Text = 'INDICA QUANTAS LINHAS SELECIONADAS';

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
