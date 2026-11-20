classdef winRFDataHub_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        DockModule                 matlab.ui.container.GridLayout
        DockCloseButton            matlab.ui.control.Image
        DockUndockButton           matlab.ui.control.Image
        Toolbar                    matlab.ui.container.GridLayout
        TableResultsExportButton   matlab.ui.control.Image
        PlotTableLayoutButton      matlab.ui.control.Image
        LeftPanelVisibilityButton  matlab.ui.control.Image
        Document                   matlab.ui.container.GridLayout
        RightPanel                 matlab.ui.container.GridLayout
        AxesPopup                  matlab.ui.control.Label
        AntennaPatternPanel        matlab.ui.container.Panel
        UITable                    matlab.ui.control.Table
        AxesToolbar                matlab.ui.container.GridLayout
        AxesBasemap                matlab.ui.control.DropDown
        AxesRegionZoomButton       matlab.ui.control.Image
        AxesRestoreViewButton      matlab.ui.control.Image
        AxesContainer              matlab.ui.container.Panel
        LeftPanel                  matlab.ui.container.Panel
        LeftPanelGrid              matlab.ui.container.GridLayout
        CacheUpdatedAt             matlab.ui.control.Label
        CacheUpdatedAtIcon         matlab.ui.control.Image
        FilterRulesList            matlab.ui.control.Label
        FilterAdvancedLink         matlab.ui.control.Hyperlink
        FilterByDistance           matlab.ui.control.NumericEditField
        FilterByDistanceLabel      matlab.ui.control.Label
        FilterByFrequency          matlab.ui.control.NumericEditField
        FilterByFrequencyLabel     matlab.ui.control.Label
        FilterByLocation           matlab.ui.control.DropDown
        FilterByLocationLabel      matlab.ui.control.Label
        FilterByState              matlab.ui.control.DropDown
        FilterByStateLabel         matlab.ui.control.Label
        ModuleIntro                matlab.ui.control.Label
        ModuleIcon                 matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'RFDATAHUB'
        AppHandleNameInBase

        rxInitialSite
        rxDistanceSource
        stateLocationMap = struct('stateNames', {{}}, 'locationNames', {{}}, 'pairs', [])
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
        popupContainer

        rfDataHub
        rfDataHubLOG
        rfDataHubTableFilterObj
        
        UIAxes1
        UIAxes2
        UIAxes3
        restoreView = struct( ...
            'ID', {}, ...
            'xLim', {}, ...
            'yLim', {}, ...
            'cLim', {} ...
        )

        channelReportObj
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        UITABLE_HEADER_TO_COLUMNS = dictionary( ...
            ["FREQUÊNCIA|(MHz)", "LARGURA|(kHz)", "DESCRIÇÃO|(Entidade+Fistel+Multiplicidade+Localidade)", "FISTEL", "SERVIÇO", "ID", "ESTAÇÃO", "DISTÂNCIA|(km)"], ...
            ["Frequency", "BW", "Description", "Fistel", "Service", "ID", "Station", "Distance"] ...
        )

        STATIONS_COLOR = '#00ffff'
        RFLINK_COLOR = '#ff365e'  % RX, TX, enlace TX-RX e azimute
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'onRFDataHubTXLocationEditRequested'
                        rfDataHubIdx = findRFDataHubIndex(app);
                        if isempty(rfDataHubIdx)
                            return
                        end

                        stationAttributes = getTXStationAttributes(app, rfDataHubIdx);
                        ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RFDataHubLocation', app.Context, 'TX', stationAttributes)

                    case 'onRFDataHubRXLocationEditRequested'
                        stationAttributes = getRXStationAttributes(app);
                        ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RFDataHubLocation', app.Context, 'RX', stationAttributes)

                    case 'onRFDataHubChannelReportOpenRequested'
                        rfDataHubIdx = findRFDataHubIndex(app);
                        if isempty(rfDataHubIdx)
                            return
                        end
    
                        if app.rfDataHub.Source(rfDataHubIdx) == "MOSAICO-SRD"
                            if isempty(app.channelReportObj)
                                app.channelReportObj = RF.ChannelReport;
                            end
                            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'RFDataHubChannelReport', app.Context, rfDataHubIdx, app.channelReportObj)
                        end

                    case 'onRFLinkToggleViewRequested'
                        toggleRFLinkPlotVisibility(app)

                    case 'onFilterRuleDeleteRequested'
                        % O evento carrega o hash da regra, uma vez que os índices
                        % mudam a cada inclusão ou exclusão.
                        filterRules = app.rfDataHubTableFilterObj.filterRules;
                        ruleIdx = find(strcmp(filterRules.Hash, event.HTMLEventData), 1);

                        if isempty(ruleIdx) || ~filterRules.Deletable(ruleIdx)
                            return
                        end

                        removeFilterRule(app.rfDataHubTableFilterObj, ruleIdx)
                        applyFilterRulesChange(app)

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
                    case {'winAppAnalise', 'winAppAnalise_exported', ...
                          'winMonitorRNI', 'winMonitorRNI_exported'}
                        operationType = varargin{1};

                        switch operationType
                            case 'onRFDataHubUpdate'
                                closeFcn(app)

                            case 'onRFDataHubLocationChanged'
                                stationType = varargin{2};

                                switch stationType
                                    case 'TX'
                                        updateTableStyle(app)

                                        % Força a atualização do painel HTML e dos plots...
                                        app.AxesPopup.UserData.rfDataHubIdx = [];
                                        onUITableSelectionChanged(app)

                                    case 'RX'
                                        % O novo valor já foi persistido pelo módulo 
                                        % em "General.context.RFDATAHUB.rx.last". Sincroniza-se,
                                        % então, a coluna "Distance" e os plots.
                                        applyRXSiteChange(app)

                                    otherwise
                                        error('auxApp:winRFDataHub:UnexpectedStationType', 'Unexpected station type "%s"', stationType)
                                end

                            case 'onFilterRulesChanged'
                                % Módulo auxApp.dockTableFilter: inclusão, exclusão,
                                % habilitação ou desabilitação de regras em
                                % "rfDataHubTableFilterObj".
                                applyFilterRulesChange(app)

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
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.FilterByState;
                app.FilterRulesList;
                app.AxesToolbar;
                app.UITable;
                app.RightPanel;
                app.AxesPopup;
                app.LeftPanelVisibilityButton;
                app.PlotTableLayoutButton;
                app.TableResultsExportButton;
                app.DockUndockButton;
                app.DockCloseButton
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.FilterByState.UserData.id,              'selector', 'input', 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')), ...
                    struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id,                'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                    struct('appName', appName, 'dataTag', app.UITable.UserData.id,                    'tableMultiline', struct('status', true, 'verticalCenter', false), 'tableTextAlignment', {{struct('columnId', 3, 'textAlign', 'justify')}}), ...
                    struct('appName', appName, 'dataTag', app.RightPanel.UserData.id,                 'style', struct('border', '1px solid lightgray')), ...
                    struct('appName', appName, 'dataTag', app.LeftPanelVisibilityButton.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna visibilidade do painel')), ...
                    struct('appName', appName, 'dataTag', app.PlotTableLayoutButton.UserData.id,      'tooltip', struct('defaultPosition', 'top',    'textContent', 'Alterna entre três layouts do conjunto plot+tabela<br>(apenas plot, apenas tabela ou plot+tabela)')), ...
                    struct('appName', appName, 'dataTag', app.TableResultsExportButton.UserData.id,   'tooltip', struct('defaultPosition', 'top',    'textContent', 'Exporta planilha filtrada (.xlsx)')), ...
                    struct('appName', appName, 'dataTag', app.DockUndockButton.UserData.id,           'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                    struct('appName', appName, 'dataTag', app.DockCloseButton.UserData.id,            'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                });
            catch
            end

            try
                ui.TextView.startup(app.jsBackDoor, app.FilterRulesList, appName, struct('class', 'textview--borderless'));
                ui.TextView.startup(app.jsBackDoor, app.AxesPopup,       appName, struct('class', 'textview--borderless'));
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRFDataHub(app)

            app.rxInitialSite = getRXInitialSite(app);
            updateRXDistanceColumn(app, app.rxInitialSite)

            initializeFilterRules(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.DockUndockButton.Enable = 1;
            end

            app.UITable.UserData.rfDataHubIdxs = [];
            app.UITable.UserData.selectedRow = [];
            app.UITable.UserData.selectedRowStyleIdx = [];
            
            app.AxesPopup.UserData.rfDataHubIdx = [];
            
            app.LeftPanelVisibilityButton.UserData.status = true;
            app.PlotTableLayoutButton.UserData.layout = 1;
            app.UIAxes2.Visible = false;

            defaultBasemap = app.mainApp.General.plot.geographicAxes.Basemap;
            if ismember(defaultBasemap, app.AxesBasemap.Items)
                app.AxesBasemap.Value = defaultBasemap;
            end

            initializeAxes(app)
            
            cacheUpdatedAt = strsplit(app.mainApp.General.AppVersion.database.ReleaseDate);
            app.CacheUpdatedAt.Text = sprintf('%s às %s', cacheUpdatedAt{1}, cacheUpdatedAt{2});

            % Campos de filtragem rápida: o valor de cada campo reflete a
            % regra simples correspondente em "rfDataHubTableFilterObj".
            initializeStateLocationIndex(app)
            updateQuickFilterFields(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateTable(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeRFDataHub(app)
            app.rfDataHub = app.mainApp.rfDataHub;
            app.rfDataHubLOG = app.mainApp.rfDataHubLOG;
        end
        
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.AxesContainer, 3, 5, "Padding", "none", "TileSpacing", "none");

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.AxesBasemap.Value,                        ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [3, 5];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')

            geolimits(app.UIAxes1, 'auto')

            if ismember(app.AxesBasemap.Value, {'darkwater', 'none'})
                app.UIAxes1.Grid = 'on';
            end

            % Eixo cartesiano: PERFIL DE RELEVO
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'XGrid', 'off', 'XMinorGrid', 'off', 'XTick', [], 'XColor', [.8,.8,.8], 'XLimitMethod', 'padded', ...
                                                                    'YGrid', 'off', 'YMinorGrid', 'off', 'YTick', [], 'YColor', 'none',                               ...
                                                                    'Color', 'none', 'Clipping', 'off', 'LineWidth', 2, 'Layer', 'top', 'Visible', 'off'});
            app.UIAxes2.Layout.Tile = 11;
            app.UIAxes2.Layout.TileSpan = [1 2];
            app.UIAxes2.XAxis.TickLabelFormat = '%.1f';

            % Eixo cartesiano: DIAGRAMA DE RADIAÇÃO DA ANTENA
            app.UIAxes3 = polaraxes(app.AntennaPatternPanel, 'Units',             'normalized',      ...
                                                             'Position',          [.08, 0, .9, .85], ...
                                                             'ThetaZeroLocation', 'top',             ...
                                                             'Toolbar',           [],                ...
                                                             'FontSize',          8,                 ...
                                                             'Color',             'yellow',          ...
                                                             'ThetaTick',         0,                 ...
                                                             'ThetaDir',          'clockwise',       ...
                                                             'RTickLabel',        {});
            hold(app.UIAxes3, 'on')

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation(app.UIAxes1, [dataTipInteraction, zoomInteraction, panInteraction])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes2, dataTipInteraction)
        end


        %-----------------------------------------------------------------%
        % ## FILTRAGEM ##
        %-----------------------------------------------------------------%
        function initializeFilterRules(app)
            app.rfDataHubTableFilterObj = tableFiltering;

            % As regras iniciais vêm das últimas regras persistidas (filter.last)
            % ou, na ausência delas, das regras padrão (filter.default), ambas
            % em "General.context.RFDATAHUB".
            filterContext = app.mainApp.General.context.RFDATAHUB.filter;
            persistedRules = filterContext.last;
            if isempty(persistedRules)
                persistedRules = filterContext.default;
            end

            disabledHashes = {};
            for ii = 1:numel(persistedRules)
                try
                    rule = persistedRules(ii);

                    operators = reshape(cellstr(rule.Operators), 1, []);
                    values    = reshape(rule.Values, 1, []);
                    if ~iscell(values)
                        values = num2cell(values);
                    end

                    deletable = true;
                    if isfield(rule, 'Deletable')
                        deletable = logical(rule.Deletable);
                    end

                    addFilterRule(app.rfDataHubTableFilterObj, rule.Field, operators, values, rule.Connector, deletable)

                    if isfield(rule, 'Enable') && ~rule.Enable && isfield(rule, 'Hash')
                        disabledHashes{end+1} = rule.Hash; %#ok<AGROW>
                    end
                catch
                    % Regra inválida ou incompatível com a base atual.
                end
            end

            % As regras são reordenadas por coluna a cada inclusão, razão pela
            % qual o estado "Enable" é restaurado a partir do hash da regra.
            filterRules = app.rfDataHubTableFilterObj.filterRules;
            enableArray = ~ismember(filterRules.Hash, disabledHashes) | ~filterRules.Deletable;
            toogleFilterRule(app.rfDataHubTableFilterObj, enableArray)
        end

        %-----------------------------------------------------------------%
        function updateFilterRulesList(app)
            filterRules = app.rfDataHubTableFilterObj.filterRules;
            ruleIdxs = find(filterRules.Enable)';

            filteredRecordCount = numel(app.UITable.UserData.rfDataHubIdxs);
            totalRecordCount    = height(app.rfDataHub);
            htmlContent = sprintf('<font style="font-size: 12px;"><b>Filtros ativos (%d)</b><br><font style="font-size: 10px; color: gray;">%d de %d registros (%.1f %%)<br> </font></font>', numel(ruleIdxs), filteredRecordCount, totalRecordCount, (filteredRecordCount/totalRecordCount)*100);

            if ~isempty(ruleIdxs)
                appHandleNameInBase = getAppHandleNameInBase(app);

                % "filterList" e "isDeletable" estão alinhados às regras 
                % habilitadas, cujos hashes são "filterRules.Hash(ruleIdxs)".
                [filterList, isDeletable] = getFilterList(app.rfDataHubTableFilterObj, 'tbl', 'on');
                ruleHashes = filterRules.Hash(ruleIdxs);

                ruleItems = strings(numel(filterList), 1);
                for ii = 1:numel(filterList)
                    ruleItems(ii) = createFilterRuleItem(app, filterList{ii}, isDeletable(ii), ruleHashes{ii}, appHandleNameInBase);
                end
                htmlContent = [htmlContent, char(strjoin(ruleItems, ''))];
            end

            ui.TextView.update(app.FilterRulesList, htmlContent)
        end

        %-----------------------------------------------------------------%
        function htmlItem = createFilterRuleItem(app, ruleText, isDeletable, ruleHash, appHandleNameInBase)
            % O ícone de exclusão é apresentado apenas para regras deletáveis.
            deleteButton = '';
            if isDeletable
                deleteButton = ui.TextView.createHTMLLink('customImage', appHandleNameInBase, 'onFilterRuleDeleteRequested', ruleHash, 'close-16px-red.svg', 16, 16, app.mainApp.General);
                deleteButton = sprintf('<span title="Excluir filtro">%s</span>', deleteButton);
            end

            htmlItem = sprintf([ ...
                '<section style="background-color: #f0f0f0; margin: 0 2px 4px 0; padding: 4px; border-radius: 8px;">' ...
                    '<table style="width: 100%%;"><tbody><tr>' ...
                        '<td><font style="color: rgb(32, 32, 32);">%s</font></td>' ...
                        '<td style="width: 20px; text-align: right; padding-left: 4px;">%s</td>' ...
                    '</tr></tbody></table>' ...
                '</section>' ...
            ], ...
                escapeHtml(app, ruleText), ...
                deleteButton ...
            );
        end

        %-----------------------------------------------------------------%
        function escapedValue = escapeHtml(~, value)
            escapedValue = replace(char(value), {'&', '<', '>', '"', ''''}, {'&amp;', '&lt;', '&gt;', '&quot;', '&#39;'});
        end

        %-----------------------------------------------------------------%
        function applyFilterRulesChange(app)
            updateQuickFilterFields(app)
            persistRFDataHubSettings(app)
            updateTable(app)
        end

        %-----------------------------------------------------------------%
        function hFields = getQuickFilterFields(app)
            hFields = [app.FilterByState, app.FilterByLocation, app.FilterByFrequency, app.FilterByDistance];
        end

        %-----------------------------------------------------------------%
        function [columnName, operator] = parseQuickFilterTag(~, hField)
            % A tag possui o formato "coluna,operação", com a operação conforme
            % os símbolos do tableFiltering (por exemplo, "Distance,≤").
            tagParts   = strsplit(hField.Tag, ',');
            columnName = tagParts{1};
            operator   = tagParts{2};
        end

        %-----------------------------------------------------------------%
        function ruleIdxs = findQuickFilterRules(app, columnName, operator)
            % Regras simples: uma única operação na coluna, sem conectores 
            % (&&, ||) com outras operações.
            filterRules = app.rfDataHubTableFilterObj.filterRules;

            ruleIdxs = [];
            for ii = 1:height(filterRules)
                if strcmp(filterRules.Field{ii}, columnName) && isscalar(filterRules.Operators{ii}) && strcmp(filterRules.Operators{ii}{1}, operator)
                    ruleIdxs(end+1) = ii; %#ok<AGROW>
                end
            end
        end

        %-----------------------------------------------------------------%
        function initializeStateLocationIndex(app)
            pairs = unique([double(app.rfDataHub.State), double(app.rfDataHub.Location)], 'rows');
            pairs(any(isnan(pairs), 2), :) = [];

            app.stateLocationMap = struct( ...
                'stateNames',    {categories(app.rfDataHub.State)}, ...
                'locationNames', {categories(app.rfDataHub.Location)}, ...
                'pairs',         pairs ...
            );
        end

        %-----------------------------------------------------------------%
        function updateStateLocationItems(app, correlateFields)
            % Com "correlateFields" verdadeiro, o filtro "State" apresenta 
            % apenas as UFs que possuem o município em "Location" e vice-versa.
            stateNames    = app.stateLocationMap.stateNames;
            locationNames = app.stateLocationMap.locationNames;
            pairs         = app.stateLocationMap.pairs;

            stateValue    = app.FilterByState.Value;
            locationValue = app.FilterByLocation.Value;

            % Na criação, os campos possuem valor "{}" (ver createComponents).
            if ~ischar(stateValue)
                stateValue = '';
            end

            if ~ischar(locationValue)
                locationValue = '';
            end
            stateIdxs    = 1:numel(stateNames);
            locationIdxs = 1:numel(locationNames);

            if correlateFields
                selectedStateIdx    = find(strcmp(stateNames, stateValue));
                selectedLocationIdx = find(strcmp(locationNames, locationValue));

                if ~isempty(selectedLocationIdx)
                    stateIdxs = union(pairs(pairs(:,2) == selectedLocationIdx, 1)', selectedStateIdx);
                end

                if ~isempty(selectedStateIdx)
                    locationIdxs = union(pairs(pairs(:,1) == selectedStateIdx, 2)', selectedLocationIdx);
                end
            end

            app.FilterByState.Items    = [{''}; stateNames(stateIdxs)];
            app.FilterByLocation.Items = [{''}; textAnalysis.sort(locationNames(locationIdxs))];

            app.FilterByState.Value    = stateValue;
            app.FilterByLocation.Value = locationValue;
        end

        %-----------------------------------------------------------------%
        function updateQuickFilterFields(app)
            filterRules = app.rfDataHubTableFilterObj.filterRules;

            % Os valores aplicados podem não constar nas opções atuais dos 
            % campos "State" e "Location", razão pela qual elas são 
            % restauradas antes de atualizá-los.
            updateStateLocationItems(app, false)

            for hField = getQuickFilterFields(app)
                [columnName, operator] = parseQuickFilterTag(app, hField);
                ruleIdxs = findQuickFilterRules(app, columnName, operator);
                ruleIdxs = ruleIdxs(filterRules.Enable(ruleIdxs));

                if isa(hField, 'matlab.ui.control.NumericEditField')
                    value = [];
                    if ~isempty(ruleIdxs)
                        ruleValue = filterRules.Values{ruleIdxs(1)}{1};
                        if isnumeric(ruleValue) && isscalar(ruleValue) && ruleValue >= hField.Limits(1) && ruleValue <= hField.Limits(2)
                            value = double(ruleValue);
                        end
                    end

                else
                    value = '';
                    if ~isempty(ruleIdxs)
                        ruleValue = filterRules.Values{ruleIdxs(1)}{1};
                        if ischar(ruleValue) && (ismember(ruleValue, hField.Items) || strcmp(hField.Editable, 'on'))
                            value = ruleValue;
                        end
                    end
                end

                hField.Value = value;
            end

            updateStateLocationItems(app, true)
        end


        %-----------------------------------------------------------------%
        % ## TABELA ##
        %-----------------------------------------------------------------%
        function updateTable(app)
            app.progressDialog.Visible = 'visible';

            % Identifica registro inicialmente selecionado da tabela.
            initialSelectedRow = "";
            if ~isempty(app.UITable.Selection)
                initialSelectedRow = app.UITable.Data.ID(app.UITable.Selection);
            end

            % Filtragem, preenchendo a tabela e o seu label (nº de linhas).
            rfDataHubIdxs = find(run(app.rfDataHubTableFilterObj, 'filterRules', app.rfDataHub));
            columnNames   = cellstr(values(app.UITABLE_HEADER_TO_COLUMNS)');
            [rfDataHubFiltered, sortedIdxs] = sortrows(app.rfDataHub(rfDataHubIdxs, columnNames), 'Frequency');

            set(app.UITable, 'Selection', [], 'Data', rfDataHubFiltered)
            
            app.UITable.UserData.rfDataHubIdxs = rfDataHubIdxs(sortedIdxs);
            app.UITable.UserData.selectedRow = [];
            app.UITable.UserData.selectedRowStyleIdx = [];

            updateFilterRulesList(app)

            % Aplicando a seleção inicial da tabela, caso aplicável.
            selectedRow = 0;
            if ~isempty(app.UITable.Data)
                if initialSelectedRow.strlength
                    [~, selectedRow] = ismember(initialSelectedRow, app.UITable.Data.ID);
                end

                if ~selectedRow
                    selectedRow = 1;
                end

                app.UITable.Selection = selectedRow;
                app.UITable.UserData.selectedRow = selectedRow;

                scroll(app.UITable, 'Row', selectedRow)
            end

            updateTableStyle(app)
            
            % Plots
            updateStationsPlot(app)
            updateRXPlot(app)
            onUITableSelectionChanged(app, struct('Source', app.UITable))
            
            plot.axes.StackingOrder.execute(app.UIAxes1, 'RFDataHub')
            app.restoreView(1) = struct( ...
                'ID', 'app.UIAxes1', ...
                'xLim', app.UIAxes1.LatitudeLimits, ...
                'yLim', app.UIAxes1.LongitudeLimits, ...
                'cLim', 'auto' ...
            );

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            applyTableStyle(app, 'clearCellStyles')
            applyTableStyle(app, 'emissionIndicators')
            applyTableStyle(app, 'selectedRow')
        end

        %-----------------------------------------------------------------%
        function applyTableStyle(app, style)
            switch style
                case 'clearCellStyles'
                    cellStylesIdxs = find(app.UITable.StyleConfigurations.Target == "cell");
                    if ~isempty(cellStylesIdxs)
                        removeStyle(app.UITable, cellStylesIdxs)
                    end
                    app.UITable.UserData.selectedRowStyleIdx = [];

                case 'emissionIndicators'
                    editedEmissionIdxs = find(contains(app.UITable.Data.ID, app.mainApp.rfDataHubAnnotation.ID));

                    if ~isempty(editedEmissionIdxs)
                        cellList = [editedEmissionIdxs, ones(numel(editedEmissionIdxs), 1)];
                        addStyle(app.UITable, uistyle('Icon', 'edit.svg',  'IconAlignment', 'leftmargin'), 'cell', cellList) 
                    end

                case 'selectedRow'
                    % Destaca célula selecionada...
                    if ~isempty(app.UITable.Data)
                        selectedRow = app.UITable.UserData.selectedRow;
                        selectedRowStyleIdx = app.UITable.UserData.selectedRowStyleIdx;

                        if isempty(selectedRowStyleIdx)
                            selectedRowStyleIdx = height(app.UITable.StyleConfigurations) + 1;
                        else
                            removeStyle(app.UITable, selectedRowStyleIdx)
                        end

                        addStyle(app.UITable, uistyle('Icon', 'eye.svg', 'IconAlignment', 'leftmargin'), 'cell', [selectedRow, 1])
                        app.UITable.UserData.selectedRowStyleIdx = selectedRowStyleIdx;
                        drawnow
                    end
            end
        end


        %-----------------------------------------------------------------%
        % ## PLOT ##
        %-----------------------------------------------------------------%
        function updateStationsPlot(app)
            delete(findobj(app.UIAxes1.Children, '-not', 'Tag', 'TX'))
            app.AxesPopup.UserData.rfDataHubIdx = [];

            if ~isempty(app.UITable.Data)
                geolimits(app.UIAxes1, 'auto')

                rfDataHubIdxs = app.UITable.UserData.rfDataHubIdxs;
                lats = app.rfDataHub.Latitude(rfDataHubIdxs);
                lngs = app.rfDataHub.Longitude(rfDataHubIdxs);

                hStations = geoscatter(app.UIAxes1, lats, lngs, ...
                    'MarkerEdgeColor', app.STATIONS_COLOR, ...
                    'MarkerFaceColor', app.STATIONS_COLOR, ...
                    'SizeData', 5, ...
                    'DisplayName', 'RFDataHub', ...
                    'Tag', 'Stations' ...
                );
                plot.datatip.Template(hStations, 'winRFDataHub.Geographic', app.UITable.Data)
            end
        end

        %-----------------------------------------------------------------%
        function updateRXPlot(app)
            rxSite = getRXCurrentSite(app);

            hRX = geoscatter(app.UIAxes1, rxSite.Latitude, rxSite.Longitude, ...
                'Marker', '^', ...
                'MarkerEdgeColor', app.RFLINK_COLOR, ...
                'MarkerFaceColor', app.RFLINK_COLOR, ...
                'SizeData', 92, ...
                'DisplayName', 'RX', ...
                'Tag', 'RX' ...
            );
            plot.datatip.Template(hRX, 'Coordinates')
        end

        %-----------------------------------------------------------------%
        function updateTXPlot(app, rfDataHubIdx)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))
            delete(findobj(app.UIAxes1.Children, 'Tag', 'RFLink'))

            if ~isempty(rfDataHubIdx)
                [txObj, rxObj] = createRFLinkObjects(app, 'TX-RX', rfDataHubIdx);

                % Linha tracejada entre TX e RX (apenas os extremos). É criada 
                % antes do marcador TX para que este fique sobreposto.
                geoplot(app.UIAxes1, [txObj.Latitude, rxObj.Latitude], [txObj.Longitude, rxObj.Longitude], Color=app.RFLINK_COLOR, LineStyle='-.', PickableParts='none', DisplayName='Enlace', Tag='RFLink');

                hTX = geoscatter(app.UIAxes1, txObj.Latitude, txObj.Longitude, ...
                    'LineWidth', 2, ...
                    'Marker', 'o', ...
                    'MarkerEdgeColor', app.RFLINK_COLOR, ...
                    'MarkerFaceColor', app.RFLINK_COLOR, ...
                    'SizeData', 48, ...
                    'PickableParts', 'none', ...
                    'DisplayName', 'TX', ...
                    'Tag', 'TX' ...
                );

                plot.datatip.Template(hTX, 'Coordinates')
            end
        end

        %-----------------------------------------------------------------%
        function updateStationInfoPanel(app)
            % Painel HTML com as informações de TX, RX e enlace do registro 
            % selecionado. Sem seleção, apenas a estação RX.
            % Verifica se o handle para o app continua ativo no workspace
            % base do MATLAB, possibilitando que clicks no ui.TextView sejam 
            % capturados corretamente.
            appHandleNameInBase = getAppHandleNameInBase(app);
            rfDataHubIdx = findRFDataHubIndex(app);

            ui.TextView.update(app.AxesPopup, util.HtmlTextGenerator.getStationInfo(app.rfDataHub, rfDataHubIdx, app.rfDataHubLOG, app.mainApp.General, app.mainApp.rfDataHubAnnotation, createRFLinkObjects(app, 'RX'), appHandleNameInBase, app.RFLINK_COLOR, app.UIAxes2.Visible));
        end

        %-----------------------------------------------------------------%
        function toggleRFLinkPlotVisibility(app)
            set(findobj(app.UIAxes2), 'Visible', ~app.UIAxes2.Visible)

            updateStationInfoPanel(app)
            updateRFLinkPlot(app)
        end

        %-----------------------------------------------------------------%
        function updateRFLinkPlot(app)
            cla(app.UIAxes2)

            if app.UIAxes2.Visible && ~isempty(app.UITable.Selection)
                rfDataHubIdx = findRFDataHubIndex(app);

                app.progressDialog.Visible = 'visible';

                try
                    % OBJETOS TX e RX
                    [txObj, rxObj] = createRFLinkObjects(app, 'TX-RX', rfDataHubIdx);
        
                    % ELEVAÇÃO DO LINK TX-RX
                    [wayPoints3D, msgWarning] = Get(app.mainApp.elevationObj, txObj, rxObj, app.mainApp.General.elevation.pointCount, app.mainApp.General.elevation.forceRefresh, app.mainApp.General.elevation.provider);
                    if ~isempty(msgWarning)
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                    end
                    
                    % PLOT: RFLink
                    plot.RFLink(app.UIAxes2, txObj, rxObj, wayPoints3D, 'light', true)
                catch
                end

                app.progressDialog.Visible = 'hidden';
            end
        end

        %-----------------------------------------------------------------%
        function updateAzimuthPlot(app)
            % O azimute independe do perfil de elevação (e do botão de enlace), 
            % pois depende apenas das coordenadas de TX e RX.
            delete(findobj(app.UIAxes3.Children, 'Tag', 'Azimuth'))

            if isempty(app.UITable.Selection)
                return
            end

            try
                rfDataHubIdx = findRFDataHubIndex(app);
                [txObj, rxObj] = createRFLinkObjects(app, 'TX-RX', rfDataHubIdx);
                [~, azimuth] = RF.Propagation.Distance(txObj, rxObj);

                az = deg2rad(azimuth);
                polarplot(app.UIAxes3, az, app.UIAxes3.RLim(1), 'MarkerEdgeColor', app.RFLINK_COLOR, 'MarkerFaceColor', app.RFLINK_COLOR, 'Marker', 'o', 'PickableParts', 'none', 'Tag', 'Azimuth');
                polarplot(app.UIAxes3, az, app.UIAxes3.RLim(2), 'MarkerEdgeColor', app.RFLINK_COLOR, 'MarkerFaceColor', app.RFLINK_COLOR, 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Azimuth');
                polarplot(app.UIAxes3, [az, az], app.UIAxes3.RLim, 'Color', app.RFLINK_COLOR, 'LineStyle', '-.', 'PickableParts', 'none', 'Tag', 'Azimuth');
            catch
            end
        end


        %-----------------------------------------------------------------%
        % ## MISCELÂNEAS ##
        %-----------------------------------------------------------------%
        function appHandleNameInBase = getAppHandleNameInBase(app)
            % Os links do HTML invocam o app por meio do workspace base do MATLAB.
            appHandleNameInBase = app.AppHandleNameInBase;

            if isempty(appHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', appHandleNameInBase, appHandleNameInBase, class(app), appHandleNameInBase))
                appHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
                app.AppHandleNameInBase = appHandleNameInBase;
            end
        end

        %-----------------------------------------------------------------%
        function [rfDataHubIdx, selectedRowIdx] = findRFDataHubIndex(app)
            if isempty(app.UITable.Selection)
                rfDataHubIdx   = [];
                selectedRowIdx = 0;                
            else
                selectedRowIdx = app.UITable.Selection;
                virtualIdx     = app.UITable.Data.ID(selectedRowIdx);    
                rfDataHubIdx   = str2double(extractAfter(virtualIdx, '#'));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = createRFLinkObjects(app, siteType, varargin)
            arguments
                app 
                siteType char {mustBeMember(siteType, {'TX', 'RX', 'TX-RX'})} = 'TX-RX'
            end

            arguments (Repeating)
                varargin
            end

            % txSite e rxSite estão como struct, mas basta mudar para "txsite" e 
            % "rxsite" que eles poderão ser usados em predições, uma vez que os 
            % campos da estrutura são idênticos às propriedades dos objetos.

            varargout = {};

            % TX
            if contains(siteType, 'TX')
                rfDataHubIdx = varargin{1};

                % Valor em vigor: o editado pelo usuário, caso exista em
                % app.mainApp.rfDataHubAnnotation, ou o constante em base.
                stationAttributes = getTXStationAttributes(app, rfDataHubIdx);
                txCurrentValue = stationAttributes.CurrentValue;

                txSite = struct( ...
                    'Name', 'TX', ...
                    'TransmitterFrequency', double(app.rfDataHub.Frequency(rfDataHubIdx)) * 1e+6, ...
                    'Latitude', txCurrentValue.Latitude, ...
                    'Longitude', txCurrentValue.Longitude, ...
                    'AntennaHeight', txCurrentValue.Height, ...
                    'ID', app.rfDataHub.ID(rfDataHubIdx), ...
                    'Station', app.rfDataHub.Station(rfDataHubIdx) ...
                );
                varargout{end+1} = txSite;
            end

            % RX
            if contains(siteType, 'RX')
                varargout{end+1} = getRXCurrentSite(app);
            end
        end

        %-----------------------------------------------------------------%
        function [txLatitude, txLongitude, txHeight] = getTXSiteRawData(app, rfDataHubIdx)
            txLatitude   = round(double(app.rfDataHub.Latitude(rfDataHubIdx)),  6);
            txLongitude  = round(double(app.rfDataHub.Longitude(rfDataHubIdx)), 6);
            txHeight     = round(str2double(char(app.rfDataHub.AntennaHeight(rfDataHubIdx))), 1);
            if txHeight < 0
                txHeight = app.mainApp.General.context.RFDATAHUB.tx.defaultHeight;
            end
        end

        %-----------------------------------------------------------------%
        function stationAttributes = getTXStationAttributes(app, rfDataHubIdx)
            % Atributos da estação TX passados ao módulo auxApp.dockRFDataHubLocation:
            % • InitialValue: valores constantes em base;
            % • CurrentValue: valores em vigor, isto é, os editados, caso 
            %   haja registro em app.mainApp.rfDataHubAnnotation.
            [txLatitude, txLongitude, txHeight] = getTXSiteRawData(app, rfDataHubIdx);
            initialValue = struct('Latitude', txLatitude, 'Longitude', txLongitude, 'Height', txHeight);
            currentValue = initialValue;

            stationId = app.rfDataHub.ID(rfDataHubIdx);
            [~, annotationIdx] = ismember(stationId, app.mainApp.rfDataHubAnnotation.ID);

            if annotationIdx
                txSite = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx);

                if txSite.Latitude.Status
                    currentValue.Latitude = txSite.Latitude.EditedValue;
                end

                if txSite.Longitude.Status
                    currentValue.Longitude = txSite.Longitude.EditedValue;
                end

                if txSite.AntennaHeight.Status
                    currentValue.Height = txSite.AntennaHeight.EditedValue;
                end
            end

            stationAttributes = struct( ...
                'ID', stationId, ...
                'Station', app.rfDataHub.Station(rfDataHubIdx), ...
                'InitialValue', initialValue, ...
                'CurrentValue', currentValue ...
            );
        end

        %-----------------------------------------------------------------%
        function  rxSite = getRXInitialSite(app)
            if isequal(app.mainApp.General.context.RFDATAHUB.rx.default, app.mainApp.General.context.RFDATAHUB.rx.last)
                refRXFlag = false;

                switch class(app.mainApp)
                    case {'winAppAnalise', 'winAppAnalise_exported'}
                        referenceData = app.mainApp.specData;

                        for ii = 1:numel(referenceData)
                            if referenceData(ii).GPS.Status
                                rxLatitude  = referenceData(ii).GPS.Latitude;
                                rxLongitude = referenceData(ii).GPS.Longitude;
            
                                % Salvo engano, o campo de altura só existe nos arquivos 
                                % gerados pelo appColeta, no formato "10m", por exemplo.
                                rxHeight = [];
                                if isfield(referenceData(ii).MetaData.Antenna, 'Height')
                                    rxHeight = str2double(extractBefore(referenceData(ii).MetaData.Antenna.Height, 'm'));
                                end
            
                                if isempty(rxHeight) || isnan(rxHeight) || (rxHeight <= 0) || isinf(rxHeight)
                                    rxHeight = app.mainApp.General.context.RFDATAHUB.rx.default.height;
                                end
                                
                                refRXFlag = true;
                                break
                            end
                        end
            
                        case {'winMonitorRNI', 'winMonitorRNI_exported'}
                            referenceData = app.mainApp.measData;

                            if ~isempty(referenceData)
                                rxLatitude  = referenceData(1).Latitude;
                                rxLongitude = referenceData(1).Longitude;
                                rxHeight    = app.mainApp.General.context.RFDATAHUB.rx.default.height;

                                refRXFlag = true;
                            end
                end
    
                if ~refRXFlag
                    rxLatitude  = app.mainApp.General.context.RFDATAHUB.rx.default.latitude;
                    rxLongitude = app.mainApp.General.context.RFDATAHUB.rx.default.longitude;
                    rxHeight    = app.mainApp.General.context.RFDATAHUB.rx.default.height;
                end

            else
                rxLatitude  = app.mainApp.General.context.RFDATAHUB.rx.last.latitude;
                rxLongitude = app.mainApp.General.context.RFDATAHUB.rx.last.longitude;
                rxHeight    = app.mainApp.General.context.RFDATAHUB.rx.last.height;
            end

            rxSite = struct('Name', 'RX', 'Latitude', rxLatitude, 'Longitude', rxLongitude, 'AntennaHeight', rxHeight);
        end

        %-----------------------------------------------------------------%
        function rxSite = getRXCurrentSite(app)
            rxConfig = app.mainApp.General.context.RFDATAHUB.rx;

            if isequal(rxConfig.default, rxConfig.last)
                rxSite = app.rxInitialSite;
            else
                rxSite = struct('Name', 'RX', 'Latitude', rxConfig.last.latitude, 'Longitude', rxConfig.last.longitude, 'AntennaHeight', rxConfig.last.height);
            end
        end

        %-----------------------------------------------------------------%
        function stationAttributes = getRXStationAttributes(app)
            % Atributos da estação RX passados ao módulo auxApp.dockRFDataHubLocation:
            % • InitialValue: valor inicial da estação de referência;
            % • CurrentValue: valor em vigor (inclusive o editado).
            initialSite = app.rxInitialSite;
            currentSite = getRXCurrentSite(app);

            stationAttributes = struct( ...
                'InitialValue', struct('Latitude', initialSite.Latitude, 'Longitude', initialSite.Longitude, 'Height', initialSite.AntennaHeight), ...
                'CurrentValue', struct('Latitude', currentSite.Latitude, 'Longitude', currentSite.Longitude, 'Height', currentSite.AntennaHeight)  ...
            );
        end

        %-----------------------------------------------------------------%
        function updateRXDistanceColumn(app, rxSite)
            app.rfDataHub.Distance = round(single(deg2km(distance(app.rfDataHub.Latitude, app.rfDataHub.Longitude, rxSite.Latitude, rxSite.Longitude))), 1);
            app.rxDistanceSource = rxSite;
        end

        %-----------------------------------------------------------------%
        function applyRXSiteChange(app)
            rxSite = getRXCurrentSite(app);

            % Recalcula a coluna "Distance" caso a alteração tenha 
            % ocorrido em "Latitude" ou "Longitude".            
            if ~isequal(rmfield(app.rxDistanceSource, 'AntennaHeight'), rmfield(rxSite, 'AntennaHeight'))
                refreshRFDataHubView(app, rxSite)

            elseif ~isequal(app.rxDistanceSource.AntennaHeight, rxSite.AntennaHeight)
                app.rxDistanceSource.AntennaHeight = rxSite.AntennaHeight;
                app.AxesPopup.UserData.rfDataHubIdx = [];
                onUITableSelectionChanged(app)
            end
        end

        %-----------------------------------------------------------------%
        function refreshRFDataHubView(app, rxSite)
            updateRXDistanceColumn(app, rxSite)
            updateTable(app)
        end

        %-----------------------------------------------------------------%
        function persistRFDataHubSettings(app)
            filterRules = app.rfDataHubTableFilterObj.filterRules;
            currentRules = struct('Hash', {}, 'Field', {}, 'Operators', {}, 'Values', {}, 'Connector', {}, 'Enable', {}, 'Deletable', {});

            for ii = 1:height(filterRules)
                currentRules(ii).Hash      = filterRules.Hash{ii};
                currentRules(ii).Field     = filterRules.Field{ii};
                currentRules(ii).Operators = filterRules.Operators{ii};
                currentRules(ii).Values    = filterRules.Values{ii};
                currentRules(ii).Connector = filterRules.Connector{ii};
                currentRules(ii).Enable    = filterRules.Enable(ii);
                currentRules(ii).Deletable = filterRules.Deletable(ii);
            end

            app.mainApp.General.context.RFDATAHUB.filter.last   = currentRules;
            app.mainApp.General_I.context.RFDATAHUB.filter.last = currentRules;
            
            appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            try
                app.UIFigure.Name = class.Constants.appName;
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

        % Image clicked function: DockCloseButton, DockUndockButton
        function onDockModuleGroupButtonClicked(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.DockUndockButton
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;
                    
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.DockCloseButton
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Selection changed function: UITable
        function onUITableSelectionChanged(app, event)
            
            if exist('event', 'var') && isfield(struct(event), 'Selection')
                selectedRow = event.Selection;
    
                if isempty(selectedRow)
                    app.UITable.Selection = event.PreviousSelection;
                    return
                end
            end

            [rfDataHubIdx, selectedRow] = findRFDataHubIndex(app);

            if ~isequal(app.UITable.UserData.selectedRow, selectedRow)
                app.UITable.UserData.selectedRow = selectedRow;
                applyTableStyle(app, 'selectedRow')
            end

            % Painel HTML
            % Caso nenhum registro atenda aos critérios de filtragem,
            % reinicializa a área de visualização do app, mantendo apenas
            % as informações da estação RX.
            if isempty(rfDataHubIdx)
                app.AxesPopup.UserData.rfDataHubIdx = [];
                updateStationInfoPanel(app)

                % Área de plot:
                delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))
                cla(app.UIAxes2)
                cla(app.UIAxes3)

                return

            % Caso a alteração na seleção da tabela seja restrita à coluna,
            % por exemplo, mantendo-se selecionada a mesma linha, não será 
            % realizado um novo plot.
            elseif isequal(app.AxesPopup.UserData.rfDataHubIdx, rfDataHubIdx)
                return
            end

            app.AxesPopup.UserData.rfDataHubIdx = rfDataHubIdx;

            updateStationInfoPanel(app)
                
            % Plot "AntennaPattern"
            % O bloco try/catch protege possível erro no parser da informação
            % do Mosaico. Como exposto em model.RFDataHub.parsingAntennaPattern
            % foram identificados quatro formas de armazenar a informação.
            cla(app.UIAxes3)
            if app.rfDataHub.AntennaPattern(rfDataHubIdx) ~= "-1"
                try
                    [angle, gain] = model.RFDataHub.parsingAntennaPattern(app.rfDataHub.AntennaPattern(rfDataHubIdx), 360);
                    hAntennaPattern = polarplot(app.UIAxes3, angle, gain, 'Tag', 'AntennaPattern');
                    plot.datatip.Template(hAntennaPattern, "AntennaPattern")
                catch
                end
            end

            % Plot "TX"
            updateTXPlot(app, rfDataHubIdx)

            % Plot "RFLink" e azimute
            updateRFLinkPlot(app)
            updateAzimuthPlot(app)
            
        end

        % Image clicked function: LeftPanelVisibilityButton, 
        % ...and 1 other component
        function onToolbarInteractionButtonClicked(app, event)
            
            switch event.Source
                case app.LeftPanelVisibilityButton
                    app.LeftPanelVisibilityButton.UserData.status = ~app.LeftPanelVisibilityButton.UserData.status;

                    if app.LeftPanelVisibilityButton.UserData.status
                        app.LeftPanelVisibilityButton.ImageSource = 'layout-sidebar-left.svg';
                        app.LeftPanel.Visible = 'on';
                        app.Document.ColumnWidth(1:2) = {232, 10};
                    else
                        app.LeftPanelVisibilityButton.ImageSource = 'layout-sidebar-left-off.svg';
                        app.LeftPanel.Visible = 'off';
                        app.Document.ColumnWidth(1:2) = {0, 0};
                    end

                case app.PlotTableLayoutButton
                    app.PlotTableLayoutButton.UserData.layout = mod(app.PlotTableLayoutButton.UserData.layout + 1, 3);

                    switch app.PlotTableLayoutButton.UserData.layout
                        case 0
                            app.UITable.Visible = 'off';
                            app.Document.RowHeight = {24, '1x', 0, 0};
                        case 1
                            app.UITable.Visible = 'on';
                            app.Document.RowHeight = {24, '1x', 10, '0.4x'};
                        case 2
                            app.UITable.Visible = 'on';
                            app.Document.RowHeight = {0, 0, 0, '1x'};
                    end
            end

        end

        % Image clicked function: TableResultsExportButton
        function onToolbarTableResultsExportButtonClicked(app, event)

                nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
                defaultName   = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'RFDataHub', -1); 
                fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
                if isempty(fileFullPath)
                    return
                end
                
                app.progressDialog.Visible = 'visible';

                try
                    rfDataHubIdxs = app.UITable.UserData.rfDataHubIdxs;
                    tempRFDataHub = model.RFDataHub.ColumnNames(app.rfDataHub(rfDataHubIdxs, 1:29), 'eng2port');
                    writetable(tempRFDataHub, fileFullPath, 'WriteMode', 'overwritesheet')
                catch ME
                    ui.Dialog(app.UIFigure, 'warning', getReport(ME));
                end

                app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: AxesRegionZoomButton, 
        % ...and 1 other component
        function onAxesToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.AxesRestoreViewButton
                    geolimits(app.UIAxes1, app.restoreView(1).xLim, app.restoreView(1).yLim)

                case app.AxesRegionZoomButton
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes1, app.AxesRegionZoomButton)
            end

        end

        % Value changed function: FilterByDistance, FilterByFrequency, 
        % ...and 2 other components
        function onQuickFilterValueChanged(app, event)
            
            hField = event.Source;
            [columnName, operator] = parseQuickFilterTag(app, hField);
            value = hField.Value;

            if ischar(value) && ~isempty(value) && ~ismember(value, hField.Items)
                ui.Dialog(app.UIFigure, 'warning', sprintf('O valor "%s" não consta entre as opções disponíveis.', value));
                updateQuickFilterFields(app)
                return
            end

            % Edição: a regra simples vigente (habilitada) é substituída pela
            % nova ou, caso o campo tenha sido esvaziado, apenas excluída.
            filterRules = app.rfDataHubTableFilterObj.filterRules;
            ruleIdxs = findQuickFilterRules(app, columnName, operator);
            ruleIdxs = ruleIdxs(filterRules.Enable(ruleIdxs));

            if ~isempty(ruleIdxs)
                if ~filterRules.Deletable(ruleIdxs(1))
                    ui.Dialog(app.UIFigure, 'warning', 'O filtro vigente para este campo não pode ser editado.');
                    updateQuickFilterFields(app)
                    return
                end
                removeFilterRule(app.rfDataHubTableFilterObj, ruleIdxs(1))
            end

            if ~isempty(value)
                filterRules = app.rfDataHubTableFilterObj.filterRules;
                ruleIdxs = findQuickFilterRules(app, columnName, operator);
                sameValueIdxs = ruleIdxs(cellfun(@(x) isequal(x{1}, value), filterRules.Values(ruleIdxs)));

                if isempty(sameValueIdxs)
                    addFilterRule(app.rfDataHubTableFilterObj, columnName, {operator}, {value}, 'E')
                else
                    % Já existe regra idêntica, porém desabilitada.
                    enableArray = filterRules.Enable;
                    enableArray(sameValueIdxs(1)) = true;
                    toogleFilterRule(app.rfDataHubTableFilterObj, enableArray)
                end
            end

            persistRFDataHubSettings(app)
            updateStateLocationItems(app, true)
            updateTable(app)

        end

        % Value changed function: AxesBasemap
        function onConfigOthersParameterChanged(app, event)
            
            switch event.Source
                case app.AxesBasemap
                    app.UIAxes1.Basemap = app.AxesBasemap.Value;
                    switch app.AxesBasemap.Value
                        case {'darkwater', 'none'}
                            app.UIAxes1.Grid = 'on';
                        otherwise
                            app.UIAxes1.Grid = 'off';
                    end
                    return
            end

        end

        % Callback function: FilterAdvancedLink
        function onFilterAdvancedLinkHyperlinkClicked(app, event)
            
            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'TableFilter', app.Context, app.rfDataHub, app.rfDataHubTableFilterObj)

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
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                children = Container.Children;
                if isa(Container, 'matlab.ui.Figure') && isprop(Container, 'RunningAppInstance') && isprop(Container.RunningAppInstance, 'jsBackDoor')
                    children(children == Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)

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
            app.GridLayout.ColumnWidth = {20, '1x', 38, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, '1x', 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {232, 10, 5, 190, '1x', 10, 232};
            app.Document.RowHeight = {24, '1x', 10, 158};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [4 5];
            app.Document.Layout.Column = [2 3];
            app.Document.BackgroundColor = [1 1 1];

            % Create LeftPanel
            app.LeftPanel = uipanel(app.Document);
            app.LeftPanel.AutoResizeChildren = 'off';
            app.LeftPanel.Layout.Row = [1 4];
            app.LeftPanel.Layout.Column = 1;

            % Create LeftPanelGrid
            app.LeftPanelGrid = uigridlayout(app.LeftPanel);
            app.LeftPanelGrid.ColumnWidth = {22, 5, 73, 10, 100};
            app.LeftPanelGrid.RowHeight = {92, 17, 22, 22, 22, 36, 22, 32, '1x', 17};
            app.LeftPanelGrid.ColumnSpacing = 0;
            app.LeftPanelGrid.RowSpacing = 5;
            app.LeftPanelGrid.BackgroundColor = [1 1 1];

            % Create ModuleIcon
            app.ModuleIcon = uiimage(app.LeftPanelGrid);
            app.ModuleIcon.Layout.Row = 1;
            app.ModuleIcon.Layout.Column = 1;
            app.ModuleIcon.VerticalAlignment = 'top';
            app.ModuleIcon.ImageSource = 'database-24px.svg';

            % Create ModuleIntro
            app.ModuleIntro = uilabel(app.LeftPanelGrid);
            app.ModuleIntro.VerticalAlignment = 'top';
            app.ModuleIntro.WordWrap = 'on';
            app.ModuleIntro.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ModuleIntro.Layout.Row = 1;
            app.ModuleIntro.Layout.Column = [3 5];
            app.ModuleIntro.Interpreter = 'html';
            app.ModuleIntro.Text = {'<b>RF.DataHub</b>'; '<p style="padding: 2px; text-align: justify; font-size: 10px; color: gray; line-height: 13px">Centraliza a coleta, organiza e disponibiliza dados de estações de telecomunicações, integrando registros extraídos do Mosaico, ICAO, AISWEB etc.</p>'};

            % Create FilterByStateLabel
            app.FilterByStateLabel = uilabel(app.LeftPanelGrid);
            app.FilterByStateLabel.VerticalAlignment = 'bottom';
            app.FilterByStateLabel.FontSize = 11;
            app.FilterByStateLabel.Layout.Row = 2;
            app.FilterByStateLabel.Layout.Column = [1 3];
            app.FilterByStateLabel.Text = 'UF:';

            % Create FilterByState
            app.FilterByState = uidropdown(app.LeftPanelGrid);
            app.FilterByState.Items = {};
            app.FilterByState.ValueChangedFcn = createCallbackFcn(app, @onQuickFilterValueChanged, true);
            app.FilterByState.Tag = 'State,=';
            app.FilterByState.FontSize = 11;
            app.FilterByState.FontColor = [1 1 1];
            app.FilterByState.BackgroundColor = [0.7216 0.1882 0.1686];
            app.FilterByState.Layout.Row = 3;
            app.FilterByState.Layout.Column = [1 3];
            app.FilterByState.Value = {};

            % Create FilterByLocationLabel
            app.FilterByLocationLabel = uilabel(app.LeftPanelGrid);
            app.FilterByLocationLabel.VerticalAlignment = 'bottom';
            app.FilterByLocationLabel.FontSize = 11;
            app.FilterByLocationLabel.Layout.Row = 4;
            app.FilterByLocationLabel.Layout.Column = [1 5];
            app.FilterByLocationLabel.Text = 'Município:';

            % Create FilterByLocation
            app.FilterByLocation = uidropdown(app.LeftPanelGrid);
            app.FilterByLocation.Items = {};
            app.FilterByLocation.Editable = 'on';
            app.FilterByLocation.ValueChangedFcn = createCallbackFcn(app, @onQuickFilterValueChanged, true);
            app.FilterByLocation.Tag = 'Location,=';
            app.FilterByLocation.FontSize = 11;
            app.FilterByLocation.BackgroundColor = [1 1 1];
            app.FilterByLocation.Layout.Row = 5;
            app.FilterByLocation.Layout.Column = [1 5];
            app.FilterByLocation.Value = {};

            % Create FilterByFrequencyLabel
            app.FilterByFrequencyLabel = uilabel(app.LeftPanelGrid);
            app.FilterByFrequencyLabel.VerticalAlignment = 'bottom';
            app.FilterByFrequencyLabel.FontSize = 11;
            app.FilterByFrequencyLabel.Layout.Row = 6;
            app.FilterByFrequencyLabel.Layout.Column = [1 3];
            app.FilterByFrequencyLabel.Text = {'Frequência central '; '(MHz):'};

            % Create FilterByFrequency
            app.FilterByFrequency = uieditfield(app.LeftPanelGrid, 'numeric');
            app.FilterByFrequency.Limits = [20 18000];
            app.FilterByFrequency.ValueDisplayFormat = '%.3f';
            app.FilterByFrequency.AllowEmpty = 'on';
            app.FilterByFrequency.ValueChangedFcn = createCallbackFcn(app, @onQuickFilterValueChanged, true);
            app.FilterByFrequency.Tag = 'Frequency,=';
            app.FilterByFrequency.FontSize = 11;
            app.FilterByFrequency.Layout.Row = 7;
            app.FilterByFrequency.Layout.Column = [1 3];
            app.FilterByFrequency.Value = [];

            % Create FilterByDistanceLabel
            app.FilterByDistanceLabel = uilabel(app.LeftPanelGrid);
            app.FilterByDistanceLabel.VerticalAlignment = 'bottom';
            app.FilterByDistanceLabel.FontSize = 11;
            app.FilterByDistanceLabel.Layout.Row = 6;
            app.FilterByDistanceLabel.Layout.Column = 5;
            app.FilterByDistanceLabel.Text = {'Distância máxima '; 'TX - RX (km):'};

            % Create FilterByDistance
            app.FilterByDistance = uieditfield(app.LeftPanelGrid, 'numeric');
            app.FilterByDistance.Limits = [0 1000];
            app.FilterByDistance.RoundFractionalValues = 'on';
            app.FilterByDistance.ValueDisplayFormat = '%d';
            app.FilterByDistance.AllowEmpty = 'on';
            app.FilterByDistance.ValueChangedFcn = createCallbackFcn(app, @onQuickFilterValueChanged, true);
            app.FilterByDistance.Tag = 'Distance,≤';
            app.FilterByDistance.FontSize = 11;
            app.FilterByDistance.Layout.Row = 7;
            app.FilterByDistance.Layout.Column = 5;
            app.FilterByDistance.Value = [];

            % Create FilterAdvancedLink
            app.FilterAdvancedLink = uihyperlink(app.LeftPanelGrid);
            app.FilterAdvancedLink.HyperlinkClickedFcn = createCallbackFcn(app, @onFilterAdvancedLinkHyperlinkClicked, true);
            app.FilterAdvancedLink.VisitedColor = [0.1529 0.4078 0.6471];
            app.FilterAdvancedLink.HorizontalAlignment = 'right';
            app.FilterAdvancedLink.FontSize = 11;
            app.FilterAdvancedLink.FontWeight = 'normal';
            app.FilterAdvancedLink.FontColor = [0.1529 0.4078 0.6471];
            app.FilterAdvancedLink.Layout.Row = 8;
            app.FilterAdvancedLink.Layout.Column = 5;
            app.FilterAdvancedLink.Text = 'Mais filtros';

            % Create FilterRulesList
            app.FilterRulesList = uilabel(app.LeftPanelGrid);
            app.FilterRulesList.VerticalAlignment = 'top';
            app.FilterRulesList.WordWrap = 'on';
            app.FilterRulesList.FontSize = 11;
            app.FilterRulesList.Layout.Row = 9;
            app.FilterRulesList.Layout.Column = [1 5];
            app.FilterRulesList.Interpreter = 'html';
            app.FilterRulesList.Text = '';

            % Create CacheUpdatedAtIcon
            app.CacheUpdatedAtIcon = uiimage(app.LeftPanelGrid);
            app.CacheUpdatedAtIcon.ScaleMethod = 'none';
            app.CacheUpdatedAtIcon.Enable = 'off';
            app.CacheUpdatedAtIcon.Layout.Row = 10;
            app.CacheUpdatedAtIcon.Layout.Column = 1;
            app.CacheUpdatedAtIcon.ImageSource = 'calendar.svg';

            % Create CacheUpdatedAt
            app.CacheUpdatedAt = uilabel(app.LeftPanelGrid);
            app.CacheUpdatedAt.FontSize = 11;
            app.CacheUpdatedAt.FontColor = [0.502 0.502 0.502];
            app.CacheUpdatedAt.Layout.Row = 10;
            app.CacheUpdatedAt.Layout.Column = [3 5];
            app.CacheUpdatedAt.Text = '';

            % Create AxesContainer
            app.AxesContainer = uipanel(app.Document);
            app.AxesContainer.AutoResizeChildren = 'off';
            app.AxesContainer.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.AxesContainer.BorderType = 'none';
            app.AxesContainer.BackgroundColor = [0 0 0];
            app.AxesContainer.Layout.Row = [1 2];
            app.AxesContainer.Layout.Column = [3 5];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {10, 25, 25, 5, 110, 10};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 4;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create AxesRestoreViewButton
            app.AxesRestoreViewButton = uiimage(app.AxesToolbar);
            app.AxesRestoreViewButton.ScaleMethod = 'none';
            app.AxesRestoreViewButton.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.AxesRestoreViewButton.Layout.Row = 1;
            app.AxesRestoreViewButton.Layout.Column = 2;
            app.AxesRestoreViewButton.ImageSource = 'Home_18.png';

            % Create AxesRegionZoomButton
            app.AxesRegionZoomButton = uiimage(app.AxesToolbar);
            app.AxesRegionZoomButton.ScaleMethod = 'none';
            app.AxesRegionZoomButton.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.AxesRegionZoomButton.Layout.Row = 1;
            app.AxesRegionZoomButton.Layout.Column = 3;
            app.AxesRegionZoomButton.ImageSource = 'ZoomRegion_20.png';

            % Create AxesBasemap
            app.AxesBasemap = uidropdown(app.AxesToolbar);
            app.AxesBasemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.AxesBasemap.ValueChangedFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.AxesBasemap.FontSize = 11;
            app.AxesBasemap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.AxesBasemap.BackgroundColor = [1 1 1];
            app.AxesBasemap.Layout.Row = 1;
            app.AxesBasemap.Layout.Column = 5;
            app.AxesBasemap.Value = 'satellite';

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.BackgroundColor = [1 1 1;0.96078431372549 0.96078431372549 0.96078431372549];
            app.UITable.ColumnName = {'FREQUÊNCIA|(MHz)'; 'LARGURA|(kHz)'; 'DESCRIÇÃO|(Entidade+Fistel+Multiplicidade+Localidade)'; 'FISTEL'; 'SERVIÇO'; 'ID'; 'ESTAÇÃO'; 'DISTÂNCIA|(km)'};
            app.UITable.ColumnWidth = {95, 95, 'auto', 75, 75, 75, 75, 90};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onUITableSelectionChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.ForegroundColor = [0.149 0.149 0.149];
            app.UITable.Layout.Row = 4;
            app.UITable.Layout.Column = [3 5];
            app.UITable.FontSize = 11;

            % Create RightPanel
            app.RightPanel = uigridlayout(app.Document);
            app.RightPanel.ColumnWidth = {'1x', 128, 10};
            app.RightPanel.RowHeight = {'1x', 128, 10};
            app.RightPanel.Padding = [0 0 0 0];
            app.RightPanel.Layout.Row = [1 4];
            app.RightPanel.Layout.Column = 7;
            app.RightPanel.BackgroundColor = [1 1 1];

            % Create AntennaPatternPanel
            app.AntennaPatternPanel = uipanel(app.RightPanel);
            app.AntennaPatternPanel.AutoResizeChildren = 'off';
            app.AntennaPatternPanel.BorderType = 'none';
            app.AntennaPatternPanel.BackgroundColor = [1 1 1];
            app.AntennaPatternPanel.Layout.Row = 2;
            app.AntennaPatternPanel.Layout.Column = 2;

            % Create AxesPopup
            app.AxesPopup = uilabel(app.RightPanel);
            app.AxesPopup.VerticalAlignment = 'top';
            app.AxesPopup.WordWrap = 'on';
            app.AxesPopup.FontSize = 11;
            app.AxesPopup.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.AxesPopup.Layout.Row = [1 3];
            app.AxesPopup.Layout.Column = [1 3];
            app.AxesPopup.Interpreter = 'html';
            app.AxesPopup.Text = '';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, '1x', 18};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 7;
            app.Toolbar.Layout.Column = [1 6];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create LeftPanelVisibilityButton
            app.LeftPanelVisibilityButton = uiimage(app.Toolbar);
            app.LeftPanelVisibilityButton.ScaleMethod = 'none';
            app.LeftPanelVisibilityButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarInteractionButtonClicked, true);
            app.LeftPanelVisibilityButton.Layout.Row = [1 3];
            app.LeftPanelVisibilityButton.Layout.Column = 1;
            app.LeftPanelVisibilityButton.ImageSource = 'layout-sidebar-left.svg';

            % Create PlotTableLayoutButton
            app.PlotTableLayoutButton = uiimage(app.Toolbar);
            app.PlotTableLayoutButton.ScaleMethod = 'none';
            app.PlotTableLayoutButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarInteractionButtonClicked, true);
            app.PlotTableLayoutButton.Layout.Row = [1 3];
            app.PlotTableLayoutButton.Layout.Column = 2;
            app.PlotTableLayoutButton.ImageSource = 'View_16.png';

            % Create TableResultsExportButton
            app.TableResultsExportButton = uiimage(app.Toolbar);
            app.TableResultsExportButton.ScaleMethod = 'none';
            app.TableResultsExportButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarTableResultsExportButtonClicked, true);
            app.TableResultsExportButton.Layout.Row = [1 3];
            app.TableResultsExportButton.Layout.Column = 4;
            app.TableResultsExportButton.ImageSource = 'Export_16.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [3 5];
            app.DockModule.BackgroundColor = [0.1294 0.2 0.2392];

            % Create DockUndockButton
            app.DockUndockButton = uiimage(app.DockModule);
            app.DockUndockButton.ScaleMethod = 'none';
            app.DockUndockButton.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.DockUndockButton.Enable = 'off';
            app.DockUndockButton.Layout.Row = 1;
            app.DockUndockButton.Layout.Column = 1;
            app.DockUndockButton.ImageSource = 'Undock_18White.png';

            % Create DockCloseButton
            app.DockCloseButton = uiimage(app.DockModule);
            app.DockCloseButton.ScaleMethod = 'none';
            app.DockCloseButton.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.DockCloseButton.Layout.Row = 1;
            app.DockCloseButton.Layout.Column = 2;
            app.DockCloseButton.ImageSource = 'Delete_12SVG_white.svg';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winRFDataHub_exported(Container, varargin)

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
                children = app.Container.Children;
                if isa(app.Container, 'matlab.ui.Figure') && isprop(app.Container, 'RunningAppInstance') && isprop(app.Container.RunningAppInstance, 'jsBackDoor')
                    children(children == app.Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
