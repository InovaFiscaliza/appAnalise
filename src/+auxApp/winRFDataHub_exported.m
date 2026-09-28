classdef winRFDataHub_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        DockCloseButton                 matlab.ui.control.Image
        DockUndockButton                matlab.ui.control.Image
        Document                        matlab.ui.container.GridLayout
        AxesToolbar                     matlab.ui.container.GridLayout
        AxesRegionZoomButton            matlab.ui.control.Image
        AxesRestoreViewButton           matlab.ui.control.Image
        PlotPanel                       matlab.ui.container.Panel
        ChannelReportUndockButton       matlab.ui.control.Image
        ChannelReportDownloadButton     matlab.ui.control.Image
        ChannelReportDownloadTimeLabel  matlab.ui.control.Label
        ChannelReportViewer             matlab.ui.control.HTML
        UITable                         matlab.ui.control.Table
        SubTabGroup                     matlab.ui.container.TabGroup
        SubTab1                         matlab.ui.container.Tab
        SubGrid1                        matlab.ui.container.GridLayout
        StationInfoLabel                matlab.ui.control.Label
        AntennaPatternPanel             matlab.ui.container.Panel
        StationInfoPlaceholderImage     matlab.ui.control.Image
        TXReferencePanel                matlab.ui.container.Panel
        TXReferenceGrid                 matlab.ui.container.GridLayout
        TXHeight                        matlab.ui.control.NumericEditField
        TXHeightLabel                   matlab.ui.control.Label
        TXLongitude                     matlab.ui.control.NumericEditField
        TXLongitudeLabel                matlab.ui.control.Label
        TXLatitude                      matlab.ui.control.NumericEditField
        TXLatitudeLabel                 matlab.ui.control.Label
        TXTitleGrid                     matlab.ui.container.GridLayout
        TXEditCancelButton              matlab.ui.control.Image
        TXEditConfirmButton             matlab.ui.control.Image
        TXEditModeButton                matlab.ui.control.Image
        TXRefreshButton                 matlab.ui.control.Image
        TXPanelTitle                    matlab.ui.control.Label
        TXPanelIcon                     matlab.ui.control.Image
        SubTab2                         matlab.ui.container.Tab
        SubGrid2                        matlab.ui.container.GridLayout
        FilterTypeButtonGroup           matlab.ui.container.ButtonGroup
        FilterTypeAntennaPatternRadio   matlab.ui.control.RadioButton
        FilterTypeROIRadio              matlab.ui.control.RadioButton
        FilterTypeDistanceRadio         matlab.ui.control.RadioButton
        FilterTypeMunicipalityRadio     matlab.ui.control.RadioButton
        FilterTypeStateRadio            matlab.ui.control.RadioButton
        FilterTypeStationRadio          matlab.ui.control.RadioButton
        FilterTypeServiceRadio          matlab.ui.control.RadioButton
        FilterTypeFistelRadio           matlab.ui.control.RadioButton
        FilterTypeEntityRadio           matlab.ui.control.RadioButton
        FilterTypeBandwidthRadio        matlab.ui.control.RadioButton
        FilterTypeFrequencyRadio        matlab.ui.control.RadioButton
        FilterTypeSourceRadio           matlab.ui.control.RadioButton
        RXTitleGrid                     matlab.ui.container.GridLayout
        RXEditCancelButton              matlab.ui.control.Image
        RXEditConfirmButton             matlab.ui.control.Image
        RXEditModeButton                matlab.ui.control.Image
        RXRefreshButton                 matlab.ui.control.Image
        RXPanelTitle                    matlab.ui.control.Label
        RXPanelIcon                     matlab.ui.control.Image
        FilterRulesTree                 matlab.ui.container.CheckBoxTree
        FilterAddButton                 matlab.ui.control.Image
        FilterOperationButtonGroup      matlab.ui.container.ButtonGroup
        FilterValuePanel                matlab.ui.container.Panel
        FilterValueGrid                 matlab.ui.container.GridLayout
        FilterLogicalOperatorDropDown   matlab.ui.control.DropDown
        FilterLogicalOperatorLabel      matlab.ui.control.Label
        FilterReferenceDropDown         matlab.ui.control.DropDown
        FilterReferenceLabel            matlab.ui.control.Label
        FilterTextListDropDown          matlab.ui.control.DropDown
        FilterFreeTextField             matlab.ui.control.EditField
        FilterNumericValue2Field        matlab.ui.control.NumericEditField
        FilterNumericRangeSeparator     matlab.ui.control.Label
        FilterNumericValue1Field        matlab.ui.control.NumericEditField
        FilterOperation10Button         matlab.ui.control.ToggleButton
        FilterOperation9Button          matlab.ui.control.ToggleButton
        FilterOperation8Button          matlab.ui.control.ToggleButton
        FilterOperation7Button          matlab.ui.control.ToggleButton
        FilterOperation6Button          matlab.ui.control.ToggleButton
        FilterOperation5Button          matlab.ui.control.ToggleButton
        FilterOperation4Button          matlab.ui.control.ToggleButton
        FilterOperation3Button          matlab.ui.control.ToggleButton
        FilterOperation2Button          matlab.ui.control.ToggleButton
        FilterOperation1Button          matlab.ui.control.ToggleButton
        filter_SecondaryLabel           matlab.ui.control.Label
        RXReferencePanel                matlab.ui.container.Panel
        RXReferenceGrid                 matlab.ui.container.GridLayout
        RXHeight                        matlab.ui.control.NumericEditField
        RXHeightLabel                   matlab.ui.control.Label
        RXLongitude                     matlab.ui.control.NumericEditField
        RXLongitudeLabel                matlab.ui.control.Label
        RXLatitude                      matlab.ui.control.NumericEditField
        RXLatitudeLabel                 matlab.ui.control.Label
        SubTab3                         matlab.ui.container.Tab
        SubGrid3                        matlab.ui.container.GridLayout
        ElevationSourcePanel            matlab.ui.container.Panel
        ElevationSourceGrid             matlab.ui.container.GridLayout
        ElevationForceSearchCheckBox    matlab.ui.control.CheckBox
        ElevationPointCount             matlab.ui.control.DropDown
        ElevationPointCountLabel        matlab.ui.control.Label
        ElevationProvider               matlab.ui.control.DropDown
        ElevationProviderLabel          matlab.ui.control.Label
        ElevationSourceSectionLabel     matlab.ui.control.Label
        GeoAxesSettingsPanel            matlab.ui.container.Panel
        GeoAxesSettingsGrid             matlab.ui.container.GridLayout
        RXMarkerSizeSlider              matlab.ui.control.Slider
        RXMarkerColorPicker             matlab.ui.control.ColorPicker
        RXMarkerSectionLabel            matlab.ui.control.Label
        TXDataTipVisibilityDropDown     matlab.ui.control.DropDown
        TXMarkerSizeSlider              matlab.ui.control.Slider
        TXMarkerColorPicker             matlab.ui.control.ColorPicker
        TXMarkerSectionLabel            matlab.ui.control.Label
        StationMarkerSizeSlider         matlab.ui.control.Slider
        StationMarkerColorPicker        matlab.ui.control.ColorPicker
        StationMarkerSectionLabel       matlab.ui.control.Label
        Colormap                        matlab.ui.control.DropDown
        ColormapLabel                   matlab.ui.control.Label
        Basemap                         matlab.ui.control.DropDown
        BasemapLabel                    matlab.ui.control.Label
        SettingsResetButton             matlab.ui.control.Image
        GeoAxesSettingsSectionLabel     matlab.ui.control.Label
        Toolbar                         matlab.ui.container.GridLayout
        TableRowCountIcon               matlab.ui.control.Image
        TableRowCountLabel              matlab.ui.control.Label
        ExportButton                    matlab.ui.control.Image
        ToolbarSeparator2               matlab.ui.control.Image
        ChannelReportButton             matlab.ui.control.Image
        RFLinkButton                    matlab.ui.control.Image
        TableLayoutToggleButton         matlab.ui.control.Image
        ToolbarSeparator1               matlab.ui.control.Image
        SidePanelToggleButton           matlab.ui.control.Image
        ContextMenu                     matlab.ui.container.ContextMenu
        DeleteFilterMenuItem            matlab.ui.container.Menu
        DeleteAllFiltersMenuItem        matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'RFDATAHUB'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog

        referenceData

        rfDataHub
        rfDataHubLOG
        rfDataHubSummary
        
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

        % "Hash" identifica unicamente o filtro por meio das colunas
        % "Type", "Operation" e "Value".
        FilterRules = table( ...
            'Size', [0, 10], ...
            'VariableTypes', {'cell', 'int8', 'int8', 'cell', 'cell', 'int8', 'cell', 'cell', 'logical', 'cell'}, ...
            'VariableNames', {'Order', 'ID', 'RelatedID', 'Type', 'Operation', 'Column', 'Value', 'Handle', 'Enable', 'Hash'} ...
        )
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        FILTER_TYPE_TO_COLUMNS = dictionary( ...
            ["Fonte", "Frequência", "Largura banda", "Entidade", "Fistel", "Serviço", "Estação", "UF", "Município", "Distância"], ...
            ["Source", "Frequency", "BW", "_Name", "Fistel", "Service", "Station", "State", "_Location", "Distance"] ...
        )
        
        UITABLE_HEADER_TO_COLUMNS = dictionary( ...
            ["FREQUÊNCIA|(MHz)", "LARGURA|(kHz)", "DESCRIÇÃO|(Entidade+Fistel+Multiplicidade+Localidade)", "FISTEL", "SERVIÇO", "ID", "ESTAÇÃO", "DISTÂNCIA|(km)"], ...
            ["Frequency", "BW", "Description", "Fistel", "Service", "ID", "Station", "Distance"] ...
        )
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
                    case {'winAppAnalise', 'winAppAnalise_exported', ...
                          'winMonitorRNI', 'winMonitorRNI_exported'}
                        operationType = varargin{1};

                        switch operationType
                            case 'onRFDataHubUpdate'
                                closeFcn(app)

                            case 'auxApp.winRFDataHub.FilterTree'
                                onFilterDeleteButtonClicked(app, struct('Source', app.DeleteFilterMenuItem))

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
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;

            appName = class(app);
            switch tabIndex
                case 1 % RFDATAHUB
                    appName = class(app);
                    elToModify = {
                        app.AxesToolbar;
                        app.UITable;
                        app.TXRefreshButton;
                        app.TXEditModeButton;
                        app.TXEditConfirmButton;
                        app.TXEditCancelButton;
                        app.StationInfoLabel;
                        app.StationInfoPlaceholderImage;
                        app.SidePanelToggleButton;
                        app.TableLayoutToggleButton;
                        app.RFLinkButton;
                        app.ChannelReportButton;
                        app.ExportButton;
                        app.DockUndockButton;
                        app.DockCloseButton
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.StationInfoLabel, appName);
                        ui.TextView.startup(app.jsBackDoor, app.StationInfoPlaceholderImage, appName, 'NÃO HÁ REGISTRO QUE ATENDA<br>AOS CRITÉRIOS DE FILTRAGEM');
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.UITable.UserData.id, 'tableMultiline', struct('status', true, 'verticalCenter', false), 'tableTextAlignment', {{struct('columnId', 3, 'textAlign', 'justify')}}), ...
                            struct('appName', appName, 'dataTag', app.TXRefreshButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Retorna aos valores constantes em base')), ...
                            struct('appName', appName, 'dataTag', app.TXEditModeButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Habilita ou desabilita edição de características da estação')), ...
                            struct('appName', appName, 'dataTag', app.TXEditConfirmButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Confirma edição')), ...
                            struct('appName', appName, 'dataTag', app.TXEditCancelButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Cancela edição')), ...
                            struct('appName', appName, 'dataTag', app.SidePanelToggleButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Alterna visibilidade do painel')), ...
                            struct('appName', appName, 'dataTag', app.TableLayoutToggleButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Alterna entre três layouts do conjunto plot+tabela<br>(apenas plot, apenas tabela ou plot+tabela)')), ...
                            struct('appName', appName, 'dataTag', app.RFLinkButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Apresenta perfil de terreno entre registro selecionado (TX)<br>e estação de referência (RX)')), ...
                            struct('appName', appName, 'dataTag', app.ChannelReportButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Apresenta documento gerado pelo Mosaico (limitado à radiodifusão)')), ...
                            struct('appName', appName, 'dataTag', app.ExportButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Exporta planilha filtrada (.xlsx)')), ...
                            struct('appName', appName, 'dataTag', app.DockUndockButton.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.DockCloseButton.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                case 2 % FILTRAGEM
                    elToModify = {
                        app.RXRefreshButton;
                        app.RXEditModeButton;
                        app.RXEditConfirmButton;
                        app.RXEditCancelButton;
                        app.FilterRulesTree
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.RXRefreshButton.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna aos valores iniciais')), ...
                            struct('appName', appName, 'dataTag', app.RXEditModeButton.UserData.id,    'tooltip', struct('defaultPosition', 'top',    'textContent', 'Habilita ou desabilita edição de características da estação')), ...
                            struct('appName', appName, 'dataTag', app.RXEditConfirmButton.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Confirma edição')), ...
                            struct('appName', appName, 'dataTag', app.RXEditCancelButton.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Cancela edição')), ...
                            struct('appName', appName, 'dataTag', app.FilterRulesTree.UserData.id, 'listener', struct('componentName', 'auxApp.winRFDataHub.FilterTree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end

                    buildFilterRuleTree(app)
                    
                case 3 % CONFIGURAÇÕES GERAIS
                    elToModify = {
                        app.SettingsResetButton;
                        app.ElevationForceSearchCheckBox
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.SettingsResetButton.UserData.id,             'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna aos valores iniciais')), ...
                            struct('appName', appName, 'dataTag', app.ElevationForceSearchCheckBox.UserData.id, 'generation', 1, 'style', struct('textAlign', 'justify')) ...
                        });
                    catch
                    end

                    % Elevação:
                    app.ElevationProvider.Value    = app.mainApp.General.elevation.provider;
                    app.ElevationPointCount.Value      = num2str(app.mainApp.General.elevation.pointCount);
                    app.ElevationForceSearchCheckBox.Value  = app.mainApp.General.elevation.forceRefresh;
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRFDataHub(app)

            % refRX: armazena o valor inicial da estação receptora de referência
            %        para fins de análise da edição.
            rxSite = getRXInitialSite(app);
            app.RXRefreshButton.UserData.InitialValue = rxSite;
            updateRXPanel(app, rxSite)

            updateRXDistanceColumn(app, rxSite)

            % lastPrimarySearch
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
            
            app.StationInfoLabel.UserData.rfDataHubIdx = [];

            app.TXEditModeButton.UserData.status = false;
            app.RXEditModeButton.UserData.status = false;
            
            app.TableLayoutToggleButton.UserData.layout    = 1;
            app.RFLinkButton.UserData.status       = false;
            app.ChannelReportButton.UserData.status          = false;

            initializeAxes(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            buildFilterRuleTree(app)
            updateTable(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initializeRFDataHub(app)
            app.rfDataHub        = app.mainApp.rfDataHub;
            app.rfDataHubLOG     = app.mainApp.rfDataHubLOG;
            app.rfDataHubSummary = app.mainApp.rfDataHubSummary;
        end
        
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            hParent = tiledlayout(app.PlotPanel, 2, 2, "Padding", "none", "TileSpacing", "none");

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.Basemap.Value,                        ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2, 2];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')

            geolimits(app.UIAxes1, 'auto')
            plot.axes.Colormap(app.UIAxes1, app.Colormap.Value)

            if ismember(app.Basemap.Value, {'darkwater', 'none'})
                app.UIAxes1.Grid = 'on';
            end

            % Eixo cartesiano: PERFIL DE RELEVO
            app.UIAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'XGrid', 'off', 'XMinorGrid', 'off', 'XTick', [], 'XColor', [.8,.8,.8], 'XLimitMethod', 'padded', ...
                                                                    'YGrid', 'off', 'YMinorGrid', 'off', 'YTick', [], 'YColor', 'none',                               ...
                                                                    'Color', 'none', 'Clipping', 'off', 'LineWidth', 2, 'Layer', 'top', 'Visible', 'off'});
            app.UIAxes2.Layout.Tile = 3;
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

            % Legenda
            % legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 4, 'LineWidth', .5, 'FontSize', 7.5)

            % Axes interactions:
            plot.axes.Interactivity.DefaultCreation(app.UIAxes1, [dataTipInteraction, zoomInteraction, panInteraction])
            plot.axes.Interactivity.DefaultCreation(app.UIAxes2, dataTipInteraction)
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

                txSite = struct( ...
                    'Name', 'TX', ...
                    'TransmitterFrequency', double(app.rfDataHub.Frequency(rfDataHubIdx)) * 1e+6, ...
                    'Latitude', app.TXLatitude.Value, ...
                    'Longitude', app.TXLongitude.Value, ...
                    'AntennaHeight', app.TXHeight.Value, ...
                    'ID', app.rfDataHub.ID(rfDataHubIdx), ...
                    'Station', app.rfDataHub.Station(rfDataHubIdx) ...
                );
                varargout{end+1} = txSite;
            end

            % RX
            if contains(siteType, 'RX')
                rxSite = struct( ...
                    'Name', 'RX', ...
                    'Latitude', app.RXLatitude.Value, ...
                    'Longitude', app.RXLongitude.Value, ...
                    'AntennaHeight', app.RXHeight.Value ...
                );
                varargout{end+1} = rxSite;
            end
        end


        %-----------------------------------------------------------------%
        % ## FILTRAGEM ##
        %-----------------------------------------------------------------%
        function initializeFilterRules(app)
            if ~isempty(app.mainApp.General.context.RFDATAHUB.filter.last)
                try
                    lastColumnFilters    = struct2table(app.mainApp.General.context.RFDATAHUB.filter.last, "AsArray", true);
                    
                    lastColumnDataTypes  = matlab.Compatibility.resolveTableVariableTypes(lastColumnFilters, false);
                    filterRulesDataTypes = matlab.Compatibility.resolveTableVariableTypes(app.FilterRules, false);
    
                    diffDataTypesIdxs = find(cellfun(@(x,y) ~isequal(x, y), lastColumnDataTypes, filterRulesDataTypes));
                    for ii = 1:numel(diffDataTypesIdxs)
                        lastColumnFilters = convertvars(lastColumnFilters, diffDataTypesIdxs(ii), filterRulesDataTypes{diffDataTypesIdxs(ii)});
                    end
    
                    app.FilterRules(1:height(lastColumnFilters), :) = lastColumnFilters;
                catch
                end
            end

            if isempty(app.FilterRules)
                filterType = app.mainApp.General.context.RFDATAHUB.filter.default.columnLabel;
                filterOperation = app.mainApp.General.context.RFDATAHUB.filter.default.operation;
                columnName = app.FILTER_TYPE_TO_COLUMNS(filterType);
                filterValue = app.mainApp.General.context.RFDATAHUB.filter.default.value;
                hash = model.ProjectBase.computeFilterRuleHash(filterType, filterOperation, filterValue);
                
                addFilterRule(app, 'Node', -1, filterType, filterOperation, columnName, filterValue, [], hash)
            end
        end

        %-----------------------------------------------------------------%
        function addFilterRule(app, filterOrder, relatedId, filterType, filterOperation, columnName, filterValue, filterHandle, hash)
            filterIdx = height(app.FilterRules) + 1;

            [~, columnNameIdx] = ismember(columnName, app.rfDataHub.Properties.VariableNames);
            if ~columnNameIdx
                columnNameIdx = -1; % ROI
            end

            app.FilterRules(filterIdx, {'Order', 'ID', 'RelatedID', 'Type', 'Operation', 'Column', 'Enable', 'Hash'}) = { ...
                filterOrder, ...
                filterIdx, ...
                relatedId, ...
                filterType, ...
                filterOperation, ...
                columnNameIdx, ...
                true, ...
                hash ...
            };
            app.FilterRules.Value{filterIdx}  = filterValue;
            app.FilterRules.Handle{filterIdx} = filterHandle;
        end

        %-----------------------------------------------------------------%
        function removeFilterRule(app, filterIdx)
            % Apaga os ROI's, caso existentes.
            roiIdxs = find(contains(app.FilterRules.Type, 'ROI', 'IgnoreCase', true))';
            for ii = roiIdxs
                if ismember(ii, filterIdx)
                    roiHash = app.FilterRules.Hash{ii};
                    delete(findobj(app.UIAxes1.Children, 'UserData', roiHash))
                end
            end

            % Apaga os filtros e atualiza os índices dos remanecentes. Por
            % fim, atualiza a árvore e o plot, criando os novos ROI's.
            app.FilterRules(filterIdx, :) = [];

            currentListIds = app.FilterRules.ID';
            newValueId = 0;

            for ii = currentListIds
                newValueId = newValueId+1;

                app.FilterRules.ID(app.FilterRules.ID == ii) = newValueId;
                app.FilterRules.RelatedID(app.FilterRules.RelatedID == ii) = newValueId;
            end

            applyInitialLayout(app)
            persistRFDataHubSettings(app, 'filter')
        end

        %-----------------------------------------------------------------%
        function buildFilterRuleTree(app)
            if ~isempty(app.FilterRulesTree.Children)
                delete(app.FilterRulesTree.Children)
            end

            rootFilterIdxs = find(strcmp(app.FilterRules.Order, 'Node'))';
            if ~isempty(rootFilterIdxs)
                checkedNodes = [];
                for rootIdx = rootFilterIdxs
                    childFilterIdxs = find(app.FilterRules.RelatedID == app.FilterRules.ID(rootIdx))';
                    if isempty(childFilterIdxs)
                        parentNode = uitreenode(app.FilterRulesTree, 'Text', sprintf('#%d: RFDataHub.("%s") %s %s', app.FilterRules.ID(rootIdx),                        ...
                                                                                                                app.FilterRules.Type{rootIdx},                      ...
                                                                                                                app.FilterRules.Operation{rootIdx},                 ...
                                                                                                                formatFilterValueLabel(app.FilterRules.Value{rootIdx})), ...
                                                                 'NodeData', rootIdx, 'ContextMenu', app.ContextMenu);
                        if app.FilterRules.Enable(rootIdx)
                            checkedNodes = [checkedNodes, parentNode];
                        end

                    else
                        parentNode = uitreenode(app.FilterRulesTree, 'Text', '*.*', ...
                                                                 'NodeData', [rootIdx, childFilterIdxs], 'ContextMenu', app.ContextMenu);
                        for nodeIdx = [rootIdx, childFilterIdxs]
                            childNode = uitreenode(parentNode, 'Text', sprintf('#%d: RFDataHub.("%s") %s %s', app.FilterRules.ID(nodeIdx),                        ...
                                                                                                              app.FilterRules.Type{nodeIdx},                      ...
                                                                                                              app.FilterRules.Operation{nodeIdx},                 ...
                                                                                                              formatFilterValueLabel(app.FilterRules.Value{nodeIdx})), ...
                                                               'NodeData', nodeIdx, 'ContextMenu', app.ContextMenu);
        
                            if app.FilterRules.Enable(nodeIdx)
                                checkedNodes = [checkedNodes, childNode];
                            end
                        end
                    end
                end
                app.FilterRulesTree.CheckedNodes = checkedNodes;
                expand(app.FilterRulesTree, 'all')
            end

            app.FilterReferenceDropDown.Items = [{''}, cellstr("#" + string((rootFilterIdxs)))];

            function filterValue = formatFilterValueLabel(filterValue)
                if isnumeric(filterValue)
                    if isscalar(filterValue)
                        filterValue = string(filterValue);
                    else
                        filterValue = "[" + strjoin(string(filterValue), ', ') + "]";
                    end
                elseif ischar(filterValue)
                    filterValue = sprintf('"%s"', upper(filterValue));
                else
                    filterValue = '⌂';
                end
            end
        end

        %-----------------------------------------------------------------%
        function handleFilterROIChanged(app, src, event)
            switch(event.EventName)
                case 'MovingROI'
                    plot.axes.Interactivity.DefaultDisable(app.UIAxes1)
                    
                case 'ROIMoved'
                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)

                    filterIdx = find(cellfun(@(x) isequal(src, x), app.FilterRules.Handle), 1);
                    filterType = app.FilterRules.Type{filterIdx};
                    filterOperation = app.FilterRules.Operation{filterIdx};
                    filterValue = jsonencode(plot.ROI.specification(src));

                    app.FilterRules(filterIdx, {'Value', 'Hash'}) = { ...
                        jsonencode(plot.ROI.specification(src)), ...
                        model.ProjectBase.computeFilterRuleHash(filterType, filterOperation, filterValue) ...
                    };
                    
                    applyInitialLayout(app)
                    persistRFDataHubSettings(app, 'filter')

                    if isvalid(event.Source)
                        uistack(event.Source, 'top')
                    end

                case 'DeletingROI'
                    filterIdx = find(cellfun(@(x) isequal(src, x), app.FilterRules.Handle), 1);
                    removeFilterRule(app, filterIdx)
            end            
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

            % Verifica se todos os filtros geográficos que envolvem ROIs
            % estão válidos, eventualmente recriando os ROIs.
            roiIdxs = find(contains(app.FilterRules.Type, 'ROI', 'IgnoreCase', true));
            if ~isempty(roiIdxs) && any(cellfun(@(x) isempty(x) || ~isvalid(x), app.FilterRules.Handle(roiIdxs)))
                delete(findobj(app.UIAxes1, 'Tag', 'FilterROI'))

                for ii = roiIdxs'
                    roiType = app.FilterRules.Type{ii};
                    roiSpecification = [
                        structUtil.struct2cellWithFields(jsondecode(app.FilterRules.Value{ii})), ...
                        {'Color', [0.40,0.73,0.88], 'LineWidth', 1, 'Deletable', 1, 'FaceSelectable', 0, 'Tag', 'FilterROI', 'UserData', app.FilterRules.Hash{ii}}
                    ];

                    columnNumericIdxs = cellfun(@(x) isnumeric(x) && iscolumn(x), roiSpecification);
                    if any(columnNumericIdxs)
                        roiSpecification(columnNumericIdxs) = cellfun(@(x) x.', roiSpecification(columnNumericIdxs), 'UniformOutput', false);
                    end
                    
                    if strcmp(app.FilterRules.Type{ii}, 'images.roi.Rectangle')
                        roiSpecification = [roiSpecification, {'Rotatable', 1}];
                    end

                    hROI = plot.ROI.draw(roiType, app.UIAxes1, roiSpecification);

                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)                    
                    addlistener(hROI, 'MovingROI',   @app.handleFilterROIChanged);
                    addlistener(hROI, 'ROIMoved',    @app.handleFilterROIChanged);
                    addlistener(hROI, 'DeletingROI', @app.handleFilterROIChanged);
                    addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));

                    app.FilterRules.Handle{ii} = hROI;                    
                end
            end

            % Filtragem, preenchendo a tabela e o seu label (nº de linhas).
            rfDataHubIdxs = find(util.TableFiltering(app.rfDataHub, app.FilterRules));
            columnNames   = cellstr(values(app.UITABLE_HEADER_TO_COLUMNS)');
            [rfDataHubFiltered, sortedIdxs] = sortrows(app.rfDataHub(rfDataHubIdxs, columnNames), 'Frequency');

            set(app.UITable, 'Selection', [], 'Data', rfDataHubFiltered)
            
            app.UITable.UserData.rfDataHubIdxs = rfDataHubIdxs(sortedIdxs);
            app.UITable.UserData.selectedRow = [];
            app.UITable.UserData.selectedRowStyleIdx = [];

            filteredRecordCount = numel(rfDataHubIdxs);
            totalRecordCount    = height(app.rfDataHub);
            app.TableRowCountLabel.Text = sprintf('%d de %d registros\n%.1f %%', filteredRecordCount, totalRecordCount, (filteredRecordCount/totalRecordCount)*100);

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
            
            % Plots.
            if isempty(app.UIAxes1.Legend)
                legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 4, 'LineWidth', .5, 'FontSize', 7.5)
            end

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
            delete(findobj(app.UIAxes1.Children, '-not', {'Tag', 'FilterROI', '-or', 'Tag', 'TX'}))
            app.StationInfoLabel.UserData.rfDataHubIdx = [];

            if ~isempty(app.UITable.Data)
                geolimits(app.UIAxes1, 'auto')

                rfDataHubIdxs = app.UITable.UserData.rfDataHubIdxs;
                lats = app.rfDataHub.Latitude(rfDataHubIdxs);
                lngs = app.rfDataHub.Longitude(rfDataHubIdxs);

                hStations = geoscatter(app.UIAxes1, lats, lngs, ...
                    'MarkerFaceColor', app.StationMarkerColorPicker.Value, ...
                    'MarkerEdgeColor', app.StationMarkerColorPicker.Value, ...
                    'SizeData', app.StationMarkerSizeSlider.Value, ...
                    'DisplayName', 'RFDataHub', ...
                    'Tag', 'Stations' ...
                );
                plot.datatip.Template(hStations, 'winRFDataHub.Geographic', app.UITable.Data)
            end
        end

        %-----------------------------------------------------------------%
        function updateRXPlot(app)
            rxSite = struct('Latitude',  app.RXLatitude.Value, ...
                            'Longitude', app.RXLongitude.Value);

            hRX = geoscatter(app.UIAxes1, rxSite.Latitude, rxSite.Longitude, ...
                'Marker', '^', ...
                'MarkerEdgeColor', app.RXMarkerColorPicker.Value, ...
                'MarkerFaceColor', app.RXMarkerColorPicker.Value, ...
                'SizeData', 44*app.RXMarkerSizeSlider.Value, ...
                'DisplayName', 'RX', ...
                'Tag', 'RX' ...
            );
            plot.datatip.Template(hRX, 'Coordinates')
        end

        %-----------------------------------------------------------------%
        function updateTXPlot(app, rfDataHubIdx, selectedRow)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))

            if ~isempty(rfDataHubIdx)
                txObj = createRFLinkObjects(app, 'TX', rfDataHubIdx);

                % Scatter
                hTXScatter = findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX');
                if isempty(hTXScatter)
                    hTX = geoscatter(app.UIAxes1, txObj.Latitude, txObj.Longitude, ...
                        'LineWidth', 2, ...
                        'Marker', 'o', ...
                        'MarkerEdgeColor', app.TXMarkerColorPicker.Value, ...
                        'MarkerFaceColor', app.TXMarkerColorPicker.Value, ...
                        'SizeData', 20*app.TXMarkerSizeSlider.Value , ...
                        'PickableParts', 'none', ...
                        'DisplayName', 'TX', ...
                        'Tag', 'TX' ...
                    );
                    plot.datatip.Template(hTX, 'Coordinates')
                else
                    set(hTXScatter, 'LatitudeData',  txObj.Latitude, 'LongitudeData', txObj.Longitude)
                end

                % DataTip
                if strcmp(app.TXDataTipVisibilityDropDown.Value, 'on')
                    hTXDataTip = findobj(app.UIAxes1.Children, 'Type', 'datatip', 'Tag', 'TX');
                    if isempty(hTXDataTip)
                        hStations = findobj(app.UIAxes1.Children, 'Tag', 'Stations');
                        datatip(hStations, 'DataIndex', selectedRow, 'PickableParts', 'none', 'Tag', 'TX');
                    else
                        hTXDataTip.DataIndex = selectedRow;
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function updateRFLinkPlot(app)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'RFLink'))
            cla(app.UIAxes2)
            delete(findobj(app.UIAxes3.Children, 'Tag', 'Azimuth'))

            if app.RFLinkButton.UserData.status && ~isempty(app.UITable.Selection)
                rfDataHubIdx = findRFDataHubIndex(app);

                app.progressDialog.Visible = 'visible';

                try
                    % OBJETOS TX e RX
                    [txObj, rxObj] = createRFLinkObjects(app, 'TX-RX', rfDataHubIdx);
        
                    % ELEVAÇÃO DO LINK TX-RX
                    [wayPoints3D, msgWarning] = Get(app.mainApp.elevationObj, txObj, rxObj, str2double(app.ElevationPointCount.Value), app.ElevationForceSearchCheckBox.Value, app.ElevationProvider.Value);
                    if ~isempty(msgWarning)
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                    end
        
                    % PLOT: RFLink Map
                    geoplot(app.UIAxes1, wayPoints3D(:,1), wayPoints3D(:,2), Color='#c94756', LineStyle='-.', PickableParts='none', DisplayName='Enlace', Tag='RFLink');
                    
                    % PLOT: RFLink
                    plot.RFLink(app.UIAxes2, txObj, rxObj, wayPoints3D, 'light', true, true)
    
                    % PLOT: RFLink Azimuth
                    az = deg2rad(app.UIAxes2.UserData.Azimuth);
                    polarplot(app.UIAxes3, az, app.UIAxes3.RLim(1), 'MarkerEdgeColor', '#c94756', 'MarkerFaceColor', '#c94756', 'Marker', 'o', 'PickableParts', 'none', 'Tag', 'Azimuth');
                    polarplot(app.UIAxes3, az, app.UIAxes3.RLim(2), 'MarkerEdgeColor', '#c94756', 'MarkerFaceColor', '#c94756', 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Azimuth');
                    polarplot(app.UIAxes3, [az, az], app.UIAxes3.RLim, 'Color', '#c94756', 'LineStyle', '-.', 'PickableParts', 'none', 'Tag', 'Azimuth');
                catch
                end

                app.progressDialog.Visible = 'hidden';
            end

            updatePolarAxesVisibility(app)
        end

        %-----------------------------------------------------------------%
        function updatePolarAxesVisibility(app)
            % Visibilidade do eixo polar, com diagrama de radiação da
            % antena e azimute do enlace, caso aplicáveis.
            app.AntennaPatternPanel.Visible = ~isempty(app.UIAxes3.Children);
        end


        %-----------------------------------------------------------------%
        % ## PAINEL TX ##
        %-----------------------------------------------------------------%
        function updateTXPanel(app, rfDataHubIdx)
            annotationIdx = syncTXSiteAnnotation(app, 'Search', app.rfDataHub.ID(rfDataHubIdx));

            % A ideia aqui é destacar as informações que foram editadas...
            txLatitudeFontColor   = [0,0,0];
            txLongitudeFontColor  = [0,0,0];
            txHeightFontColor     = [0,0,0];

            txLatitudeBackground  = [1,1,1];
            txLongitudeBackground = [1,1,1];
            txHeightBackground    = [1,1,1];

            if annotationIdx
                app.TXRefreshButton.Visible = 1;
                % Latitude
                if app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).Latitude.Status
                    txLatitude = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).Latitude.EditedValue;
                    txLatitudeFontColor  = [1,1,1];
                    txLatitudeBackground = [1,0,0];
                else
                    txLatitude = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).Latitude.RawValue;
                end

                % Longitude
                if app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).Longitude.Status
                    txLongitude = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).Longitude.EditedValue;
                    txLongitudeFontColor  = [1,1,1];
                    txLongitudeBackground = [1,0,0];
                else
                    txLongitude = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).Longitude.RawValue;
                end

                % Height
                if app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).AntennaHeight.Status
                    txHeight = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).AntennaHeight.EditedValue;
                    txHeightFontColor  = [1,1,1];
                    txHeightBackground = [1,0,0];
                else
                    txHeight = app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx).AntennaHeight.RawValue;
                end

            else
                app.TXRefreshButton.Visible = 0;
                [txLatitude, txLongitude, txHeight] = getTXSiteRawData(app);
            end

            set(app.TXLatitude,  'Value', txLatitude,  'FontColor', txLatitudeFontColor,  'BackgroundColor', txLatitudeBackground)
            set(app.TXLongitude, 'Value', txLongitude, 'FontColor', txLongitudeFontColor, 'BackgroundColor', txLongitudeBackground)
            set(app.TXHeight,    'Value', txHeight,    'FontColor', txHeightFontColor,    'BackgroundColor', txHeightBackground)
        end

        %-----------------------------------------------------------------%
        function applyTXPanelEditionMode(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            rfDataHubIdx = findRFDataHubIndex(app);
            hEditFields = findobj(app.TXReferenceGrid.Children, '-not', 'Type', 'uilabel');            

            switch editionStatus
                case 'on'
                    app.TXEditModeButton.ImageSource = 'Edit_32Filled.png';
                    app.TXEditModeButton.UserData.status = true;
                    set(hEditFields, 'Editable', true)
                    
                    app.TXTitleGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.TXEditConfirmButton.Enable = 1;
                    app.TXEditCancelButton.Enable  = 1;

                case 'off'
                    updateTXPanel(app, rfDataHubIdx)

                    app.TXEditModeButton.ImageSource = 'Edit_32.png';
                    app.TXEditModeButton.UserData.status = false;
                    set(hEditFields, 'Editable', false)

                    app.TXTitleGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.TXEditConfirmButton.Enable = 0;
                    app.TXEditCancelButton.Enable  = 0;
            end
        end

        %-----------------------------------------------------------------%
        function varargout = syncTXSiteAnnotation(app, operationType, varargin)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'Search', 'Add', 'Del'})}
            end

            arguments (Repeating)
                varargin
            end

            switch operationType
                case 'Search'
                    stationId = varargin{1};
                    [~, annotationIdx] = ismember(stationId, app.mainApp.rfDataHubAnnotation.ID);
                    varargout = {annotationIdx};

                case 'Add'
                    [txObj, stationId, stationName, annotationIdx] = findTXSiteAnnotationIndex(app);

                    [txLatitude,  ...
                     txLongitude, ...
                     txHeight]  = getTXSiteRawData(app);

                    % Confirma que ocorreu alteração em algum dos parâmetros 
                    % do registro.
                    txSiteDiff = struct('Latitude',      struct('Status', false, 'RawValue', txLatitude,  'EditedValue', []), ...
                                        'Longitude',     struct('Status', false, 'RawValue', txLongitude, 'EditedValue', []), ...
                                        'AntennaHeight', struct('Status', false, 'RawValue', txHeight,    'EditedValue', []));
                    txSiteDiffFlag = false;

                    % Cria estrutura que possibilita identificar quais dos
                    % parâmetros foram editados manualmente...
                    % Latitude
                    if ~isequal(txObj.Latitude, txLatitude)
                        txSiteDiffFlag = true;

                        txSiteDiff.Latitude.Status = true;
                        txSiteDiff.Latitude.EditedValue = txObj.Latitude;
                    end

                    % Longitude
                    if ~isequal(txObj.Longitude, txLongitude)
                        txSiteDiffFlag = true;

                        txSiteDiff.Longitude.Status = true;
                        txSiteDiff.Longitude.EditedValue = txObj.Longitude;
                    end

                    % Height
                    if ~isequal(txObj.AntennaHeight, txHeight)
                        txSiteDiffFlag = true;

                        txSiteDiff.AntennaHeight.Status = true;
                        txSiteDiff.AntennaHeight.EditedValue = txObj.AntennaHeight;
                    end

                    if txSiteDiffFlag
                        % Evidenciada alteração no registro. Cria-se nova linha
                        % ou edita-se a existente.
                        if annotationIdx
                            if isequal(app.mainApp.rfDataHubAnnotation.TXSite(annotationIdx), txSiteDiff)
                                return
                            end
                        else
                            annotationIdx = height(app.mainApp.rfDataHubAnnotation) + 1;
                        end

                        app.mainApp.rfDataHubAnnotation(annotationIdx, :) = {stationId, stationName, txSiteDiff};
                        updateTableStyle(app)
                        
                        % Força a atualização do painel HTML e dos plots...
                        app.StationInfoLabel.UserData.rfDataHubIdx = [];
                        onUITableSelectionChanged(app)
                    else
                        % Não evidenciada alteração no registro. Apaga-se linha,
                        % caso existente. O usuário, aqui, desfez alteração
                        % manualmente (sem pressionar no Refresh).
                        if annotationIdx
                            app.mainApp.rfDataHubAnnotation(annotationIdx, :) = [];
                            updateTableStyle(app)

                            app.StationInfoLabel.UserData.rfDataHubIdx = [];
                            onUITableSelectionChanged(app)
                        end
                    end

                case 'Del'
                    [~, ~, ~, annotationIdx] = findTXSiteAnnotationIndex(app);
                    if annotationIdx
                        app.mainApp.rfDataHubAnnotation(annotationIdx, :) = [];
                        updateTableStyle(app)

                        app.StationInfoLabel.UserData.rfDataHubIdx = [];
                        onUITableSelectionChanged(app)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function [txObj, id, station, idxAnnotation] = findTXSiteAnnotationIndex(app)
            rfDataHubIdx = findRFDataHubIndex(app);

            % Objeto.
            txObj = createRFLinkObjects(app, 'TX', rfDataHubIdx);
            id = txObj.ID;
            station = txObj.Station;

            % Consulta se esse objeto está na lista temporária de estações
            % editadas do RFDataHub.
            [~, idxAnnotation] = ismember(id, app.mainApp.rfDataHubAnnotation.ID);
        end

        %-----------------------------------------------------------------%
        function [txLatitude, txLongitude, txHeight] = getTXSiteRawData(app)
            rfDataHubIdx = findRFDataHubIndex(app);

            txLatitude   = round(double(app.rfDataHub.Latitude(rfDataHubIdx)),  6);
            txLongitude  = round(double(app.rfDataHub.Longitude(rfDataHubIdx)), 6);
            txHeight     = round(str2double(char(app.rfDataHub.AntennaHeight(rfDataHubIdx))), 1);
            if txHeight < 0
                txHeight = app.mainApp.General.context.RFDATAHUB.tx.defaultHeight;
            end
        end


        %-----------------------------------------------------------------%
        % ## PAINEL RX ##
        %-----------------------------------------------------------------%
        function  rxSite = getRXInitialSite(app)
            if isequal(app.mainApp.General.context.RFDATAHUB.rx.default, app.mainApp.General.context.RFDATAHUB.rx.last)
                refRXFlag = false;

                switch class(app.mainApp)
                    case 'winAppAnalise'
                        for ii = 1:numel(app.referenceData)
                            if app.referenceData(ii).GPS.Status
                                rxLatitude  = app.referenceData(ii).GPS.Latitude;
                                rxLongitude = app.referenceData(ii).GPS.Longitude;
            
                                % Salvo engano, o campo de altura só existe nos arquivos 
                                % gerados pelo appColeta, no formato "10m", por exemplo.
                                rxHeight = [];
                                if isfield(app.referenceData(ii).MetaData.Antenna, 'Height')
                                    rxHeight = str2double(extractBefore(app.referenceData(ii).MetaData.Antenna.Height, 'm'));
                                end
            
                                if isempty(rxHeight) || isnan(rxHeight) || (rxHeight <= 0) || isinf(rxHeight)
                                    rxHeight = app.mainApp.General.context.RFDATAHUB.rx.default.height;
                                end
                                
                                refRXFlag = true;
                                break
                            end
                        end
            
                        case 'winMonitorRNI'
                            if ~isempty(app.referenceData)
                                rxLatitude  = app.referenceData(1).Latitude;
                                rxLongitude = app.referenceData(1).Longitude;
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

            rxSite = struct('Name',          'RX',        ...
                            'Latitude',      rxLatitude,  ...
                            'Longitude',     rxLongitude, ...
                            'AntennaHeight', rxHeight);
        end

        %-----------------------------------------------------------------%
        function updateRXPanel(app, rxSite)
            app.RXLatitude.Value  = rxSite.Latitude;
            app.RXLongitude.Value = rxSite.Longitude;
            app.RXHeight.Value    = rxSite.AntennaHeight;
        end

        %-----------------------------------------------------------------%
        function updateRXDistanceColumn(app, rxSite)
            app.rfDataHub.Distance = round(single(deg2km(distance(app.rfDataHub.Latitude,  ...
                                                                  app.rfDataHub.Longitude, ...
                                                                  rxSite.Latitude,         ...
                                                                  rxSite.Longitude))), 1);
            app.RXRefreshButton.UserData.DistanceColumnSource = rxSite;
        end

        %-----------------------------------------------------------------%
        function applyRXSiteChange(app, operationType)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'Refresh', 'Edit'})}
            end

            refInitialValue         = app.RXRefreshButton.UserData.InitialValue;
            refDistanceColumnSource = app.RXRefreshButton.UserData.DistanceColumnSource;

            switch operationType
                case 'Refresh'
                    rxSite = refInitialValue;
                    updateRXPanel(app, rxSite)

                case 'Edit'
                    rxSite = createRFLinkObjects(app, 'RX');
            end
            
            set([app.RXLatitude, app.RXLongitude, app.RXHeight], 'BackGroundColor', [1,1,1], 'FontColor', [0,0,0])

            if ~isequal(rxSite, refInitialValue)
                app.RXRefreshButton.Visible = 1;
                
                if ~isequal(rxSite.Latitude, refInitialValue.Latitude)
                    set(app.RXLatitude, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end

                if ~isequal(rxSite.Longitude, refInitialValue.Longitude)
                    set(app.RXLongitude, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end

                if ~isequal(rxSite.AntennaHeight, refInitialValue.AntennaHeight)
                    set(app.RXHeight, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end
            else
                app.RXRefreshButton.Visible = 0;
            end

            % Recalcula a coluna "Distance" caso a alteração tenha 
            % ocorrido em "Latitude" ou "Longitude".            
            if ~isequal(rmfield(refDistanceColumnSource, 'AntennaHeight'), rmfield(rxSite, 'AntennaHeight'))
                refreshRFDataHubView(app, rxSite)

            elseif ~isequal(refDistanceColumnSource.AntennaHeight, rxSite.AntennaHeight)
                app.RXRefreshButton.UserData.DistanceColumnSource.AntennaHeight = rxSite.AntennaHeight;
                app.StationInfoLabel.UserData.rfDataHubIdx = [];
                onUITableSelectionChanged(app)
            end
        end

        %-----------------------------------------------------------------%
        function applyRXPanelEditionMode(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            hEditFields = findobj(app.RXReferenceGrid.Children, '-not', 'Type', 'uilabel');

            switch editionStatus
                case 'on' 
                    app.RXEditModeButton.ImageSource = 'Edit_32Filled.png';
                    app.RXEditModeButton.UserData.status = true;
                    set(hEditFields, 'Editable', true)
                    
                    app.RXTitleGrid.ColumnWidth(5:6) = {18, 18};
                    app.RXEditConfirmButton.Enable = 1;
                    app.RXEditCancelButton.Enable  = 1;

                case 'off'
                    app.RXEditModeButton.ImageSource = 'Edit_32.png';
                    app.RXEditModeButton.UserData.status = false;
                    set(hEditFields, 'Editable', false)

                    app.RXTitleGrid.ColumnWidth(5:6) = {0, 0};
                    app.RXEditConfirmButton.Enable = 0;
                    app.RXEditCancelButton.Enable  = 0;
            end
        end

        %-----------------------------------------------------------------%
        function refreshRFDataHubView(app, rxSite)
            updateRXDistanceColumn(app, rxSite)
            updateTable(app)
        end


        %-----------------------------------------------------------------%
        % ## FILTRO: PAINEL DE OPERAÇÃO ##
        %-----------------------------------------------------------------%
        function updateFilterOperationPanel(app, filterType, filterDefault)            
            resetFilterOperationDefaults(app)
            onFilterReferenceValueChanged(app)

            hComp = findobj(app.FilterOperationButtonGroup, 'Type', 'uitogglebutton');
            hCompTagFlag = contains(arrayfun(@(x) x.Tag, hComp, 'UniformOutput', false), filterType);

            set(hComp(hCompTagFlag),  Enable=1)
            set(hComp(~hCompTagFlag), Enable=0)

            selectedButton = app.FilterOperationButtonGroup.SelectedObject;
            if ~selectedButton.Enable
                switch filterType
                    case {'textList1', 'ROI'}
                        app.FilterOperation3Button.Value = 1; % CONTÉM

                    case 'textList3'
                        app.FilterOperation2Button.Value = 1; % DIFERENTE

                    otherwise
                        app.FilterOperation1Button.Value = 1; % IGUAL
                end
            end

            switch filterType
                case 'numeric'
                    app.FilterNumericValue1Field.Visible    = 1;
                    app.FilterNumericRangeSeparator.Visible = 1;
                    app.FilterNumericValue2Field.Visible    = 1;
                    app.FilterFreeTextField.Visible         = 0;
                    app.FilterTextListDropDown.Visible      = 0;

                case 'textFree'
                    app.FilterNumericValue1Field.Visible    = 0;
                    app.FilterNumericRangeSeparator.Visible = 0;
                    app.FilterNumericValue2Field.Visible    = 0;
                    app.FilterFreeTextField.Visible         = 1;
                    app.FilterTextListDropDown.Visible      = 0;

                case {'textList1', 'textList2', 'ROI'}
                    app.FilterNumericValue1Field.Visible    = 0;
                    app.FilterNumericRangeSeparator.Visible = 0;
                    app.FilterNumericValue2Field.Visible    = 0;
                    app.FilterFreeTextField.Visible         = 0;
                    app.FilterTextListDropDown.Visible      = 1;
                    app.FilterTextListDropDown.Items        = filterDefault;

                case 'textList3'
                    app.FilterNumericValue1Field.Visible    = 0;
                    app.FilterNumericRangeSeparator.Visible = 0;
                    app.FilterNumericValue2Field.Visible    = 0;
                    app.FilterFreeTextField.Visible         = 0;
                    app.FilterTextListDropDown.Visible      = 1;
                    app.FilterTextListDropDown.Items        = filterDefault;
            end
        end

        %-----------------------------------------------------------------%
        function resetFilterOperationDefaults(app)
            app.FilterNumericValue1Field.Value      = -1;
            app.FilterNumericValue2Field.Value      = -1;
            app.FilterFreeTextField.Value           = '';
            app.FilterTextListDropDown.Items        = {};
            app.FilterLogicalOperatorDropDown.Items = {'E (&&)'};
        end

        %-----------------------------------------------------------------%
        % ## RELATÓRIO DE CANAL (PDF) ##
        %-----------------------------------------------------------------%
        function updateChannelReportPanel(app, operationType)
            arguments
                app
                operationType char {mustBeMember(operationType, {'OnlyCache', 'Cache+RealTime', 'RealTime'})}
            end

            if app.ChannelReportButton.UserData.status && ~isempty(app.UITable.Selection)
                rfDataHubIdx = findRFDataHubIndex(app);

                url = char(app.rfDataHub.URL(rfDataHubIdx));
                if strcmp(url, '-1')
                    resetChannelReportPanel(app)
                    return
                end

                % Caso a URL seja válida, cria-se objeto ChannelReport, caso
                % não existente.            
                if isempty(app.channelReportObj)
                    app.channelReportObj = RF.ChannelReport;
                end
    
                % A operação poderá ser demorada caso seja do tipo "Cache+RealTime" 
                % ou "RealTime". 
                if ismember(operationType, {'Cache+RealTime', 'RealTime'})
                    app.progressDialog.Visible = 'visible';
                end
    
                [idxCache, msgError] = Get(app.channelReportObj, url, operationType);
                if ~isempty(idxCache)    
                    app.ChannelReportViewer.HTMLSource      = app.channelReportObj.cacheMapping.File{idxCache};
                    app.ChannelReportDownloadTimeLabel.Text = sprintf('DOWNLOAD EM %s', app.channelReportObj.cacheMapping.Timestamp{idxCache});
                    app.ChannelReportDownloadButton.Visible = 1;
                    app.ChannelReportUndockButton.Visible   = 1;
    
                else
                    resetChannelReportPanel(app)
    
                    if ismember(operationType, {'Cache+RealTime', 'RealTime'}) && ~isempty(msgError)
                        ui.Dialog(app.UIFigure, 'error', msgError);
                    end
                end
    
                if strcmp(app.progressDialog.Visible, 'visible')
                    app.progressDialog.Visible = 'hidden';
                end

            else
                resetChannelReportPanel(app)
            end
        end

        %-----------------------------------------------------------------%
        function resetChannelReportPanel(app)
            app.ChannelReportViewer.HTMLSource      = 'Warning2.html';
            app.ChannelReportDownloadTimeLabel.Text = '';
            app.ChannelReportDownloadButton.Visible = 0;
            app.ChannelReportUndockButton.Visible   = 0;
        end

        %-----------------------------------------------------------------%
        % ## PERSISTÊNCIA DE CONFIGURAÇÕES ##
        %-----------------------------------------------------------------%
        function persistRFDataHubSettings(app, updateType)
            arguments
                app
                updateType {mustBeMember(updateType, {'rx', 'filter'})}
            end

            switch updateType
                case 'rx'
                    configRx  = app.mainApp.General.context.RFDATAHUB.rx.last;
                    currentRx = struct( ...
                        'latitude',  round(app.RXLatitude.Value,  6), ...
                        'longitude', round(app.RXLongitude.Value, 6), ...
                        'height',    round(app.RXHeight.Value,    1)  ...
                    );

                    if isequaln(configRx, currentRx)
                        return
                    end
        
                    app.mainApp.General.context.RFDATAHUB.rx.last   = currentRx;
                    app.mainApp.General_I.context.RFDATAHUB.rx.last = currentRx;

                case 'filter'
                    configRulesHash = '';
                    if ~isempty(app.mainApp.General.context.RFDATAHUB.filter.last)
                        configRulesHash = strjoin(sort({app.mainApp.General.context.RFDATAHUB.filter.last.Hash}));
                    end
                    currentRulesHash = strjoin(sort(app.FilterRules.Hash));
        
                    if isequal(configRulesHash, currentRulesHash)
                        return                
                    end
        
                    currentRules = app.FilterRules;
                    currentRules.Handle(:) = {[]};
                    currentRules = table2struct(currentRules);
        
                    app.mainApp.General.context.RFDATAHUB.filter.last   = currentRules;
                    app.mainApp.General_I.context.RFDATAHUB.filter.last = currentRules;
            end
            
            appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            % Módulo auxiliar RFDataHub, consumido, em 18/09/2025, tanto pelo 
            % appAnalise quanto pelo monitorRNI. Toda modificação deste módulo
            % demanda a posterior atualização MANUAL do ".mlapp" em todos os
            % projetos.
            try
                app.UIFigure.Name = class.Constants.appName;

                switch class(mainApp)
                    case 'winAppAnalise'
                        app.referenceData = mainApp.specData;

                    case 'winMonitorRNI'
                        app.referenceData = mainApp.measData;
                end

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

        % Selection change function: SubTabGroup
        function onSubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

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

            % Caso nenhum registro atenda aos critérios de filtragem,
            % reinicializa a área de visualização do app.
            if isempty(rfDataHubIdx)
                % Painel:
                app.TXRefreshButton.Visible = 0;
                app.TXEditModeButton.Visible = 0;
                app.TXLatitude.Value = -1;
                app.TXLongitude.Value = -1;
                app.TXHeight.Value = 0;

                ui.TextView.update(app.StationInfoLabel, '');
                app.StationInfoPlaceholderImage.Visible = 'on';

                % Área de plot/PDF:
                delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))
                cla(app.UIAxes2)
                cla(app.UIAxes3)

                updatePolarAxesVisibility(app)
                resetChannelReportPanel(app)
                return

            % Caso a alteração na seleção da tabela seja restrita à coluna,
            % por exemplo, mantendo-se selecionada a mesma linha, não será 
            % realizado um novo plot.
            elseif isequal(app.StationInfoLabel.UserData.rfDataHubIdx, rfDataHubIdx)
                return
            end

            app.StationInfoLabel.UserData.rfDataHubIdx = rfDataHubIdx;
            
            % Estação transmissora - TX
            if ~app.TXEditModeButton.Visible
                app.TXEditModeButton.Visible = 1;
            end

            updateTXPanel(app, rfDataHubIdx)
            if app.TXEditModeButton.UserData.status
                onTXEditButtonClicked(app, struct('Source', app.TXEditModeButton))
            end

            % Painel HTML
            ui.TextView.update(app.StationInfoLabel, util.HtmlTextGenerator.getStationInfo(app.rfDataHub, rfDataHubIdx, app.rfDataHubLOG, app.mainApp.General));
            app.StationInfoPlaceholderImage.Visible = 'off';

            % Painel PDF
            if app.rfDataHub.Source(rfDataHubIdx) == "MOSAICO-SRD"
                updateChannelReportPanel(app, 'Cache+RealTime')
            else
                resetChannelReportPanel(app)
            end
                
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
            updateTXPlot(app, rfDataHubIdx, selectedRow)

            % Plot "RFLink"
            updateRFLinkPlot(app)
            
        end

        % Image clicked function: ChannelReportButton, RFLinkButton, 
        % ...and 2 other components
        function onToolbarInteractionButtonClicked(app, event)
            
            switch event.Source
                case app.SidePanelToggleButton
                    if app.SubTabGroup.Visible
                        app.SidePanelToggleButton.ImageSource = 'layout-sidebar-left-off.svg';
                        app.SubTabGroup.Visible = 0;
                        app.Document.Layout.Column = [2 5];
                    else
                        app.SidePanelToggleButton.ImageSource = 'layout-sidebar-left.svg';
                        app.SubTabGroup.Visible = 1;
                        app.Document.Layout.Column = [4 5];
                    end

                case app.TableLayoutToggleButton
                    app.TableLayoutToggleButton.UserData.layout = mod(app.TableLayoutToggleButton.UserData.layout + 1, 3);
                    switch app.TableLayoutToggleButton.UserData.layout
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

                case app.ChannelReportButton
                    app.ChannelReportButton.UserData.status = ~app.ChannelReportButton.UserData.status;
                    if app.ChannelReportButton.UserData.status
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout.
                        if app.TableLayoutToggleButton.UserData.layout == 2
                            app.TableLayoutToggleButton.UserData.layout = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                        end

                        app.Document.ColumnWidth(4:7) = {10,22,22,'1x'};
                    else
                        app.Document.ColumnWidth(4:7) = {0,0,0,0};
                    end
                    updateChannelReportPanel(app, 'Cache+RealTime')

                case app.RFLinkButton
                    app.RFLinkButton.UserData.status = ~app.RFLinkButton.UserData.status;
                    if app.RFLinkButton.UserData.status
                        % Se a tabela estiver ocupando toda a tela, então
                        % muda-se o layout. O pause é uma espécie de "drawnow"
                        % e garante que o plot será realizado corretamente.
                        if app.TableLayoutToggleButton.UserData.layout == 2
                            app.TableLayoutToggleButton.UserData.layout = 1;
                            app.Document.RowHeight = {24,'1x',10,'.4x'};
                            pause(.100)
                        end
                        
                        app.UIAxes1.Layout.TileSpan = [1,2];
                        set(findobj(app.UIAxes2), 'Visible', 1)
                    else
                        app.UIAxes1.Layout.TileSpan = [2,2];
                        set(findobj(app.UIAxes2), 'Visible', 0)
                    end
                    updateRFLinkPlot(app)
            end

        end

        % Image clicked function: ExportButton
        function onToolbarExportButtonClicked(app, event)

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

        % Image clicked function: ChannelReportDownloadButton, 
        % ...and 1 other component
        function onChannelReportButtonClicked(app, event)
            
            if strcmp(app.ChannelReportViewer.HTMLSource, 'Warning2.html')
                return
            end

            switch event.Source
                case app.ChannelReportDownloadButton
                    updateChannelReportPanel(app, 'RealTime')

                case app.ChannelReportUndockButton
                    switch app.mainApp.executionMode
                        case 'webApp'
                            rfDataHubIdx = findRFDataHubIndex(app);
                            url = char(app.rfDataHub.URL(rfDataHubIdx));
                            web(url, '-new')
                        otherwise
                            appEngine.util.OperationSystem('openFile', app.ChannelReportViewer.HTMLSource)
                    end                    
                    onToolbarInteractionButtonClicked(app, struct('Source', app.ChannelReportButton))
            end

        end

        % Image clicked function: TXEditCancelButton, TXEditConfirmButton, 
        % ...and 2 other components
        function onTXEditButtonClicked(app, event)
            
            switch event.Source
                case app.TXRefreshButton
                    syncTXSiteAnnotation(app, 'Del')
                    applyTXPanelEditionMode(app, 'off')

                case app.TXEditModeButton
                    app.TXEditModeButton.UserData.status = ~app.TXEditModeButton.UserData.status;
                    
                    if app.TXEditModeButton.UserData.status
                        applyTXPanelEditionMode(app, 'on')
                        focus(app.TXLatitude)
                    else
                        onTXEditButtonClicked(app, struct('Source', app.TXEditCancelButton))
                    end

                case app.TXEditConfirmButton
                    syncTXSiteAnnotation(app, 'Add')
                    applyTXPanelEditionMode(app, 'off')

                case app.TXEditCancelButton
                    rfDataHubIdx = findRFDataHubIndex(app);
                    updateTXPanel(app, rfDataHubIdx)
                    applyTXPanelEditionMode(app, 'off')
            end

        end

        % Image clicked function: RXEditCancelButton, RXEditConfirmButton, 
        % ...and 2 other components
        function onRXEditButtonClicked(app, event)
            
            switch event.Source
                case app.RXRefreshButton
                    applyRXSiteChange(app, 'Refresh')
                    applyRXPanelEditionMode(app, 'off')
                    persistRFDataHubSettings(app, 'rx')

                case app.RXEditModeButton
                    app.RXEditModeButton.UserData.status = ~app.RXEditModeButton.UserData.status;

                    if app.RXEditModeButton.UserData.status
                        applyRXPanelEditionMode(app, 'on')
                        focus(app.RXLatitude)
                    else
                        onRXEditButtonClicked(app, struct('Source', app.RXEditCancelButton))
                    end

                case app.RXEditConfirmButton
                    applyRXSiteChange(app, 'Edit')
                    applyRXPanelEditionMode(app, 'off')
                    persistRFDataHubSettings(app, 'rx')

                case app.RXEditCancelButton
                    rxSite = app.RXRefreshButton.UserData.DistanceColumnSource;
                    updateRXPanel(app, rxSite)
                    applyRXPanelEditionMode(app, 'off')
            end        

        end

        % Selection changed function: FilterTypeButtonGroup
        function onFilterTypeButtonGroupSelectionChanged(app, event)
                        
            selectedButton = app.FilterTypeButtonGroup.SelectedObject;
            switch selectedButton
                case app.FilterTypeSourceRadio                              % BASE DE DADOS
                    filterType    = 'textList1';
                    filterDefault = app.rfDataHubSummary.Source.RawCategories;

                case {app.FilterTypeFrequencyRadio, ...                      % FREQUÊNCIA
                      app.FilterTypeBandwidthRadio, ...                      % LARGURA BANDA
                      app.FilterTypeFistelRadio, ...                      % FISTEL
                      app.FilterTypeServiceRadio, ...                      % SERVIÇO
                      app.FilterTypeStationRadio, ...                      % ESTAÇÃO
                      app.FilterTypeDistanceRadio}                         % DISTÂNCIA
                    filterType    = 'numeric';
                    filterDefault = {};

                case {app.FilterTypeEntityRadio, ...                      % ENTIDADE
                      app.FilterTypeMunicipalityRadio}                         % MUNICÍPIO
                    filterType    = 'textFree';
                    filterDefault = {};

                case app.FilterTypeStateRadio                            % UF
                    filterType    = 'textList2';
                    filterDefault = app.rfDataHubSummary.State.Categories;

                case app.FilterTypeROIRadio                           % ROI
                    filterType    = 'ROI';
                    filterDefault = {'images.roi.Circle', 'images.roi.Rectangle', 'images.roi.Polygon'};

                case app.FilterTypeAntennaPatternRadio                           % Padrão de antena
                    filterType    = 'textList3';
                    filterDefault = {'-1'};
            end

            updateFilterOperationPanel(app, filterType, filterDefault)
            onFilterOperationButtonGroupSelectionChanged(app)
            
        end

        % Selection changed function: FilterOperationButtonGroup
        function onFilterOperationButtonGroupSelectionChanged(app, event)
            
            selectedButton = app.FilterOperationButtonGroup.SelectedObject;
            switch selectedButton
                case {app.FilterOperation9Button, app.FilterOperation10Button}
                    app.FilterNumericRangeSeparator.Visible = 1;
                    app.FilterNumericValue2Field.Visible    = 1;
                    
                otherwise
                    app.FilterNumericRangeSeparator.Visible = 0;
                    app.FilterNumericValue2Field.Visible    = 0;
            end
            
        end

        % Value changed function: FilterReferenceDropDown
        function onFilterReferenceValueChanged(app, event)
            
            value = app.FilterReferenceDropDown.Value;
            if isempty(value)
                app.FilterLogicalOperatorDropDown.Items = {'E (&&)'};
            else
                app.FilterLogicalOperatorDropDown.Items = {'OU (||)'};
            end
            
        end

        % Image clicked function: FilterAddButton
        function onFilterAddButtonClicked(app, event)
            
            selectedRadioButtonFilterType = app.FilterTypeButtonGroup.SelectedObject;
            selectedRadioButtonFilterOperation = app.FilterOperationButtonGroup.SelectedObject;

            if isempty(app.FilterReferenceDropDown.Value)
                filterOrder = 'Node';
                relatedId   = -1;
            else
                filterOrder = 'Child';
                relatedId   = str2double(app.FilterReferenceDropDown.Value(2:end));
            end

            filterType = selectedRadioButtonFilterType.Text;
            filterOperation = selectedRadioButtonFilterOperation.Text;
            filterHandle = [];

            switch selectedRadioButtonFilterType
                case {app.FilterTypeSourceRadio, ...
                      app.FilterTypeStateRadio, ...
                      app.FilterTypeAntennaPatternRadio}
                    filterValue = app.FilterTextListDropDown.Value;

                case {app.FilterTypeFrequencyRadio, ...
                      app.FilterTypeBandwidthRadio, ...
                      app.FilterTypeFistelRadio, ...
                      app.FilterTypeServiceRadio, ...
                      app.FilterTypeStationRadio, ...
                      app.FilterTypeDistanceRadio}

                    if ismember(selectedRadioButtonFilterOperation.Text, {'<>', '><'})
                        filterValue = [ ...
                            app.FilterNumericValue1Field.Value, ...
                            app.FilterNumericValue2Field.Value ...
                        ];
                    else
                        filterValue = app.FilterNumericValue1Field.Value;
                    end

                case {app.FilterTypeEntityRadio, ...
                      app.FilterTypeMunicipalityRadio}
                    filterValue = app.FilterFreeTextField.Value;

                case app.FilterTypeROIRadio
                    hROI = [];
                    
                    plot.axes.Interactivity.DefaultDisable(app.UIAxes1)
                    pause(.1)

                    filterType = app.FilterTextListDropDown.Value;
                    
                    switch filterType
                        case 'images.roi.Circle'
                            roiFcn = 'drawcircle';
                            roiNameArgument = '';

                        case 'images.roi.Rectangle'
                            roiFcn = 'drawrectangle';
                            roiNameArgument = 'Rotatable=1, ';

                        case 'images.roi.Polygon'
                            roiFcn = 'drawpolygon';
                            roiNameArgument = '';
                    end
                    eval(sprintf('hROI = %s(app.UIAxes1, Color=[0.40,0.73,0.88], LineWidth=1, Deletable=1, FaceSelectable=0, %sTag="FilterROI");', roiFcn, roiNameArgument))
                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)

                    if isempty(hROI.Position)
                        delete(hROI)
                        return
                    end

                    addlistener(hROI, 'MovingROI',   @app.handleFilterROIChanged);
                    addlistener(hROI, 'ROIMoved',    @app.handleFilterROIChanged);
                    addlistener(hROI, 'DeletingROI', @app.handleFilterROIChanged);
                    addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));

                    filterValue  = jsonencode(plot.ROI.specification(hROI));
                    filterHandle = hROI;
            end

            hash = model.ProjectBase.computeFilterRuleHash(filterType, filterOperation, filterValue);

            if ismember(hash, app.FilterRules.Hash)
                msg = 'Filtro já incluído!';
                ui.Dialog(app.UIFigure, 'warning', msg);

                if exist('hROI', 'var')
                    delete(hROI)
                end
                
                return
            end

            if exist('hROI', 'var')
                hROI.UserData = hash;
            end
            
            columnName = selectedRadioButtonFilterType.Tag;
            addFilterRule(app, filterOrder, relatedId, filterType, filterOperation, columnName, filterValue, filterHandle, hash)

            applyInitialLayout(app)
            persistRFDataHubSettings(app, 'filter')

        end

        % Menu selected function: DeleteAllFiltersMenuItem, 
        % ...and 1 other component
        function onFilterDeleteButtonClicked(app, event)
            
            if isempty(app.FilterRules)
                return
            end

            switch event.Source
                case app.DeleteFilterMenuItem
                    if isempty(app.FilterRulesTree.SelectedNodes)
                        return
                    end
                    filterIdxsToRemove = app.FilterRulesTree.SelectedNodes.NodeData;
                    
                    % Identifica se algum dos fluxos selecionado é um nó de
                    % filtros, inserindo na lista os seus filhos.
                    filterIdxsToRemove = [filterIdxsToRemove, find(ismember(app.FilterRules.RelatedID, filterIdxsToRemove))'];

                case app.DeleteAllFiltersMenuItem
                    filterIdxsToRemove = 1:height(app.FilterRules);
            end 
    
            if ~isempty(filterIdxsToRemove)
                removeFilterRule(app, filterIdxsToRemove);
            end

        end

        % Callback function: FilterRulesTree
        function onFilterRulesTreeCheckedNodesChanged(app, event)
            
            hTree = findobj(app.FilterRulesTree, '-not', 'Type', 'uicheckboxtree');
            hTreeNode = arrayfun(@(x) x.NodeData, hTree, 'UniformOutput', false);
            hTreeNodeDataList = unique(horzcat(hTreeNode{:}));

            hCheckedNode = arrayfun(@(x) x.NodeData, app.FilterRulesTree.CheckedNodes, 'UniformOutput', false);
            hCheckedNodeData = unique(horzcat(hCheckedNode{:}));

            disableIndexList = setdiff(hTreeNodeDataList, hCheckedNodeData);
            enableIndexList = setdiff((1:height(app.FilterRules))', disableIndexList);

            app.FilterRules.Enable(disableIndexList) = false;
            app.FilterRules.Enable(enableIndexList)  = true;

            updateTable(app)
            
        end

        % Callback function: RXMarkerColorPicker, StationMarkerColorPicker,
        % 
        % ...and 1 other component
        function onConfigRXParameterChanged(app, event)
            
            selectedColor = event.Source.Value;

            switch event.Source
                case app.StationMarkerColorPicker
                    set(findobj(app.UIAxes1.Children, 'Tag', 'Stations'), 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.TXMarkerColorPicker
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX'), 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.RXMarkerColorPicker
                    set(findobj(app.UIAxes1.Children, 'Tag', 'RX'),  'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)
            end

        end

        % Callback function: Basemap, Colormap, RXMarkerSizeSlider, 
        % ...and 3 other components
        function onConfigOthersParameterChanged(app, event)
            
            switch event.Source
                case app.Basemap
                    app.UIAxes1.Basemap = app.Basemap.Value;
                    switch app.Basemap.Value
                        case {'darkwater', 'none'}
                            app.UIAxes1.Grid = 'on';
                        otherwise
                            app.UIAxes1.Grid = 'off';
                    end
                    return

                case app.Colormap
                    if strcmp(app.UIAxes1.UserData.Colormap, event.Value)
                        return
                    end

                    plot.axes.Colormap(app.UIAxes1, event.Value)

                case app.TXDataTipVisibilityDropDown
                    switch app.TXDataTipVisibilityDropDown.Value
                        case 'on'
                            [rfDataHubIdx, selectedRow] = findRFDataHubIndex(app);
                            updateTXPlot(app, rfDataHubIdx, selectedRow)
                            plot.axes.StackingOrder.execute(app.UIAxes1, 'RFDataHub')
                            
                        case 'off'
                            hDataTip = findobj(app.UIAxes1.Children, 'Type', 'datatip', 'Tag', 'TX');
                            delete(hDataTip)
                    end

                case app.StationMarkerSizeSlider
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'Stations'), 'SizeData', event.Value)

                case app.TXMarkerSizeSlider
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX'), 'SizeData', 20*event.Value)

                case app.RXMarkerSizeSlider
                    set(findobj(app.UIAxes1.Children, 'Tag', 'RX'), 'SizeData', 44*event.Value)
            end

        end

        % Image clicked function: SettingsResetButton
        function onConfigResetButtonClicked(app, event)
            
            app.ElevationProvider.Value = app.mainApp.General.elevation.provider;
            app.ElevationPointCount.Value = num2str(app.mainApp.General.elevation.pointCount);

            % % Eixo geográfico - app.UIAxes1
            app.Colormap.Value = 'turbo';            
            app.StationMarkerColorPicker.Value = [0 1 1];
            app.StationMarkerSizeSlider.Value = 1;
            app.TXMarkerColorPicker.Value = [0.7882 0.2784 0.3412];
            app.TXMarkerSizeSlider.Value = 1;
            app.TXDataTipVisibilityDropDown.Value = 'off';
            app.RXMarkerColorPicker.Value = [0.7882 0.2784 0.3373];
            app.RXMarkerSizeSlider.Value = 1;
            
            % % Atualiza o plot...
            app.StationInfoLabel.UserData.rfDataHubIdx = [];
            updateTable(app)            

            app.SettingsResetButton.Visible = 0;

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
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 22, 5, 22, '1x', 18};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create SidePanelToggleButton
            app.SidePanelToggleButton = uiimage(app.Toolbar);
            app.SidePanelToggleButton.ScaleMethod = 'none';
            app.SidePanelToggleButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarInteractionButtonClicked, true);
            app.SidePanelToggleButton.Layout.Row = [1 3];
            app.SidePanelToggleButton.Layout.Column = 1;
            app.SidePanelToggleButton.ImageSource = 'layout-sidebar-left.svg';

            % Create ToolbarSeparator1
            app.ToolbarSeparator1 = uiimage(app.Toolbar);
            app.ToolbarSeparator1.ScaleMethod = 'none';
            app.ToolbarSeparator1.Enable = 'off';
            app.ToolbarSeparator1.Layout.Row = [1 3];
            app.ToolbarSeparator1.Layout.Column = 2;
            app.ToolbarSeparator1.VerticalAlignment = 'bottom';
            app.ToolbarSeparator1.ImageSource = 'LineV.svg';

            % Create TableLayoutToggleButton
            app.TableLayoutToggleButton = uiimage(app.Toolbar);
            app.TableLayoutToggleButton.ScaleMethod = 'none';
            app.TableLayoutToggleButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarInteractionButtonClicked, true);
            app.TableLayoutToggleButton.Layout.Row = [1 3];
            app.TableLayoutToggleButton.Layout.Column = 3;
            app.TableLayoutToggleButton.ImageSource = 'View_16.png';

            % Create RFLinkButton
            app.RFLinkButton = uiimage(app.Toolbar);
            app.RFLinkButton.ScaleMethod = 'none';
            app.RFLinkButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarInteractionButtonClicked, true);
            app.RFLinkButton.Layout.Row = [1 3];
            app.RFLinkButton.Layout.Column = 4;
            app.RFLinkButton.ImageSource = 'Publish_HTML_16.png';

            % Create ChannelReportButton
            app.ChannelReportButton = uiimage(app.Toolbar);
            app.ChannelReportButton.ScaleMethod = 'none';
            app.ChannelReportButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarInteractionButtonClicked, true);
            app.ChannelReportButton.Layout.Row = [1 3];
            app.ChannelReportButton.Layout.Column = 5;
            app.ChannelReportButton.ImageSource = 'Publish_PDF_16.png';

            % Create ToolbarSeparator2
            app.ToolbarSeparator2 = uiimage(app.Toolbar);
            app.ToolbarSeparator2.ScaleMethod = 'none';
            app.ToolbarSeparator2.Enable = 'off';
            app.ToolbarSeparator2.Layout.Row = [1 3];
            app.ToolbarSeparator2.Layout.Column = 6;
            app.ToolbarSeparator2.VerticalAlignment = 'bottom';
            app.ToolbarSeparator2.ImageSource = 'LineV.svg';

            % Create ExportButton
            app.ExportButton = uiimage(app.Toolbar);
            app.ExportButton.ScaleMethod = 'none';
            app.ExportButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarExportButtonClicked, true);
            app.ExportButton.Layout.Row = [1 3];
            app.ExportButton.Layout.Column = 7;
            app.ExportButton.ImageSource = 'Export_16.png';

            % Create TableRowCountLabel
            app.TableRowCountLabel = uilabel(app.Toolbar);
            app.TableRowCountLabel.HorizontalAlignment = 'right';
            app.TableRowCountLabel.FontSize = 10;
            app.TableRowCountLabel.FontColor = [0.6 0.6 0.6];
            app.TableRowCountLabel.Layout.Row = [1 3];
            app.TableRowCountLabel.Layout.Column = 8;
            app.TableRowCountLabel.Text = '';

            % Create TableRowCountIcon
            app.TableRowCountIcon = uiimage(app.Toolbar);
            app.TableRowCountIcon.ScaleMethod = 'none';
            app.TableRowCountIcon.Enable = 'off';
            app.TableRowCountIcon.Layout.Row = [1 3];
            app.TableRowCountIcon.Layout.Column = 9;
            app.TableRowCountIcon.ImageSource = 'filter.svg';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @onSubTabGroupSelectionChanged, true);
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = 2;

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'RFDATAHUB';
            app.SubTab1.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SubTab1.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {'1x', 128, 15};
            app.SubGrid1.RowHeight = {36, 62, '1x', 128, 15};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.Padding = [10 10 10 5];
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create TXTitleGrid
            app.TXTitleGrid = uigridlayout(app.SubGrid1);
            app.TXTitleGrid.ColumnWidth = {22, '1x', 18, 18, 0, 0};
            app.TXTitleGrid.RowHeight = {18, 18};
            app.TXTitleGrid.ColumnSpacing = 5;
            app.TXTitleGrid.RowSpacing = 0;
            app.TXTitleGrid.Padding = [0 0 0 0];
            app.TXTitleGrid.Layout.Row = 1;
            app.TXTitleGrid.Layout.Column = [1 3];
            app.TXTitleGrid.BackgroundColor = [1 1 1];

            % Create TXPanelIcon
            app.TXPanelIcon = uiimage(app.TXTitleGrid);
            app.TXPanelIcon.Layout.Row = [1 2];
            app.TXPanelIcon.Layout.Column = 1;
            app.TXPanelIcon.ImageSource = 'Pin_32.png';

            % Create TXPanelTitle
            app.TXPanelTitle = uilabel(app.TXTitleGrid);
            app.TXPanelTitle.VerticalAlignment = 'bottom';
            app.TXPanelTitle.FontSize = 11;
            app.TXPanelTitle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXPanelTitle.Layout.Row = [1 2];
            app.TXPanelTitle.Layout.Column = 2;
            app.TXPanelTitle.Interpreter = 'html';
            app.TXPanelTitle.Text = {'<b>Estação transmissora - TX</b>'; '<font style="font-size: 9px; color: gray;">(registro selecionado em tabela)</font>'};

            % Create TXRefreshButton
            app.TXRefreshButton = uiimage(app.TXTitleGrid);
            app.TXRefreshButton.ScaleMethod = 'none';
            app.TXRefreshButton.ImageClickedFcn = createCallbackFcn(app, @onTXEditButtonClicked, true);
            app.TXRefreshButton.Visible = 'off';
            app.TXRefreshButton.Layout.Row = 2;
            app.TXRefreshButton.Layout.Column = 3;
            app.TXRefreshButton.ImageSource = 'Refresh_18.png';

            % Create TXEditModeButton
            app.TXEditModeButton = uiimage(app.TXTitleGrid);
            app.TXEditModeButton.ImageClickedFcn = createCallbackFcn(app, @onTXEditButtonClicked, true);
            app.TXEditModeButton.Layout.Row = 2;
            app.TXEditModeButton.Layout.Column = 4;
            app.TXEditModeButton.ImageSource = 'Edit_32.png';

            % Create TXEditConfirmButton
            app.TXEditConfirmButton = uiimage(app.TXTitleGrid);
            app.TXEditConfirmButton.ImageClickedFcn = createCallbackFcn(app, @onTXEditButtonClicked, true);
            app.TXEditConfirmButton.Enable = 'off';
            app.TXEditConfirmButton.Layout.Row = 2;
            app.TXEditConfirmButton.Layout.Column = 5;
            app.TXEditConfirmButton.ImageSource = 'Ok_32Green.png';

            % Create TXEditCancelButton
            app.TXEditCancelButton = uiimage(app.TXTitleGrid);
            app.TXEditCancelButton.ImageClickedFcn = createCallbackFcn(app, @onTXEditButtonClicked, true);
            app.TXEditCancelButton.Enable = 'off';
            app.TXEditCancelButton.Layout.Row = 2;
            app.TXEditCancelButton.Layout.Column = 6;
            app.TXEditCancelButton.ImageSource = 'Delete_32Red.png';

            % Create TXReferencePanel
            app.TXReferencePanel = uipanel(app.SubGrid1);
            app.TXReferencePanel.AutoResizeChildren = 'off';
            app.TXReferencePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXReferencePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.TXReferencePanel.Layout.Row = 2;
            app.TXReferencePanel.Layout.Column = [1 3];

            % Create TXReferenceGrid
            app.TXReferenceGrid = uigridlayout(app.TXReferencePanel);
            app.TXReferenceGrid.ColumnWidth = {85, 85, 85};
            app.TXReferenceGrid.RowHeight = {17, 22};
            app.TXReferenceGrid.RowSpacing = 5;
            app.TXReferenceGrid.Padding = [10 10 10 5];
            app.TXReferenceGrid.BackgroundColor = [1 1 1];

            % Create TXLatitudeLabel
            app.TXLatitudeLabel = uilabel(app.TXReferenceGrid);
            app.TXLatitudeLabel.VerticalAlignment = 'bottom';
            app.TXLatitudeLabel.FontSize = 11;
            app.TXLatitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLatitudeLabel.Layout.Row = 1;
            app.TXLatitudeLabel.Layout.Column = 1;
            app.TXLatitudeLabel.Text = 'Latitude:';

            % Create TXLatitude
            app.TXLatitude = uieditfield(app.TXReferenceGrid, 'numeric');
            app.TXLatitude.Limits = [-90 90];
            app.TXLatitude.ValueDisplayFormat = '%.6f';
            app.TXLatitude.Editable = 'off';
            app.TXLatitude.FontSize = 11;
            app.TXLatitude.Layout.Row = 2;
            app.TXLatitude.Layout.Column = 1;
            app.TXLatitude.Value = -1;

            % Create TXLongitudeLabel
            app.TXLongitudeLabel = uilabel(app.TXReferenceGrid);
            app.TXLongitudeLabel.VerticalAlignment = 'bottom';
            app.TXLongitudeLabel.FontSize = 11;
            app.TXLongitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXLongitudeLabel.Layout.Row = 1;
            app.TXLongitudeLabel.Layout.Column = 2;
            app.TXLongitudeLabel.Text = 'Longitude:';

            % Create TXLongitude
            app.TXLongitude = uieditfield(app.TXReferenceGrid, 'numeric');
            app.TXLongitude.Limits = [-180 180];
            app.TXLongitude.ValueDisplayFormat = '%.6f';
            app.TXLongitude.Editable = 'off';
            app.TXLongitude.FontSize = 11;
            app.TXLongitude.Layout.Row = 2;
            app.TXLongitude.Layout.Column = 2;
            app.TXLongitude.Value = -1;

            % Create TXHeightLabel
            app.TXHeightLabel = uilabel(app.TXReferenceGrid);
            app.TXHeightLabel.VerticalAlignment = 'bottom';
            app.TXHeightLabel.FontSize = 11;
            app.TXHeightLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXHeightLabel.Layout.Row = 1;
            app.TXHeightLabel.Layout.Column = 3;
            app.TXHeightLabel.Text = 'Altura (m):';

            % Create TXHeight
            app.TXHeight = uieditfield(app.TXReferenceGrid, 'numeric');
            app.TXHeight.Limits = [0 Inf];
            app.TXHeight.ValueDisplayFormat = '%.1f';
            app.TXHeight.Editable = 'off';
            app.TXHeight.FontSize = 11;
            app.TXHeight.Layout.Row = 2;
            app.TXHeight.Layout.Column = 3;

            % Create StationInfoPlaceholderImage
            app.StationInfoPlaceholderImage = uiimage(app.SubGrid1);
            app.StationInfoPlaceholderImage.ScaleMethod = 'none';
            app.StationInfoPlaceholderImage.Visible = 'off';
            app.StationInfoPlaceholderImage.Layout.Row = [3 5];
            app.StationInfoPlaceholderImage.Layout.Column = [1 3];
            app.StationInfoPlaceholderImage.ImageSource = 'warning.svg';

            % Create AntennaPatternPanel
            app.AntennaPatternPanel = uipanel(app.SubGrid1);
            app.AntennaPatternPanel.AutoResizeChildren = 'off';
            app.AntennaPatternPanel.BorderType = 'none';
            app.AntennaPatternPanel.BackgroundColor = [1 1 1];
            app.AntennaPatternPanel.Layout.Row = 4;
            app.AntennaPatternPanel.Layout.Column = 2;

            % Create StationInfoLabel
            app.StationInfoLabel = uilabel(app.SubGrid1);
            app.StationInfoLabel.VerticalAlignment = 'top';
            app.StationInfoLabel.WordWrap = 'on';
            app.StationInfoLabel.FontSize = 11;
            app.StationInfoLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.StationInfoLabel.Layout.Row = [3 5];
            app.StationInfoLabel.Layout.Column = [1 3];
            app.StationInfoLabel.Interpreter = 'html';
            app.StationInfoLabel.Text = '';

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'FILTRO';
            app.SubTab2.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SubTab2.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {'1x', 18};
            app.SubGrid2.RowHeight = {36, 62, 22, 96, 130, 18, '1x'};
            app.SubGrid2.ColumnSpacing = 5;
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.Padding = [10 10 10 5];
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create RXReferencePanel
            app.RXReferencePanel = uipanel(app.SubGrid2);
            app.RXReferencePanel.AutoResizeChildren = 'off';
            app.RXReferencePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXReferencePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.RXReferencePanel.Layout.Row = 2;
            app.RXReferencePanel.Layout.Column = [1 2];

            % Create RXReferenceGrid
            app.RXReferenceGrid = uigridlayout(app.RXReferencePanel);
            app.RXReferenceGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.RXReferenceGrid.RowHeight = {17, 22};
            app.RXReferenceGrid.RowSpacing = 5;
            app.RXReferenceGrid.Padding = [10 10 10 5];
            app.RXReferenceGrid.BackgroundColor = [1 1 1];

            % Create RXLatitudeLabel
            app.RXLatitudeLabel = uilabel(app.RXReferenceGrid);
            app.RXLatitudeLabel.VerticalAlignment = 'bottom';
            app.RXLatitudeLabel.FontSize = 11;
            app.RXLatitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXLatitudeLabel.Layout.Row = 1;
            app.RXLatitudeLabel.Layout.Column = 1;
            app.RXLatitudeLabel.Text = 'Latitude:';

            % Create RXLatitude
            app.RXLatitude = uieditfield(app.RXReferenceGrid, 'numeric');
            app.RXLatitude.Limits = [-90 90];
            app.RXLatitude.ValueDisplayFormat = '%.6f';
            app.RXLatitude.Editable = 'off';
            app.RXLatitude.FontSize = 11;
            app.RXLatitude.Layout.Row = 2;
            app.RXLatitude.Layout.Column = 1;
            app.RXLatitude.Value = -1;

            % Create RXLongitudeLabel
            app.RXLongitudeLabel = uilabel(app.RXReferenceGrid);
            app.RXLongitudeLabel.VerticalAlignment = 'bottom';
            app.RXLongitudeLabel.FontSize = 11;
            app.RXLongitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXLongitudeLabel.Layout.Row = 1;
            app.RXLongitudeLabel.Layout.Column = 2;
            app.RXLongitudeLabel.Text = 'Longitude:';

            % Create RXLongitude
            app.RXLongitude = uieditfield(app.RXReferenceGrid, 'numeric');
            app.RXLongitude.Limits = [-180 180];
            app.RXLongitude.ValueDisplayFormat = '%.6f';
            app.RXLongitude.Editable = 'off';
            app.RXLongitude.FontSize = 11;
            app.RXLongitude.Layout.Row = 2;
            app.RXLongitude.Layout.Column = 2;
            app.RXLongitude.Value = -1;

            % Create RXHeightLabel
            app.RXHeightLabel = uilabel(app.RXReferenceGrid);
            app.RXHeightLabel.VerticalAlignment = 'bottom';
            app.RXHeightLabel.FontSize = 11;
            app.RXHeightLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXHeightLabel.Layout.Row = 1;
            app.RXHeightLabel.Layout.Column = 3;
            app.RXHeightLabel.Text = 'Altura (metros):';

            % Create RXHeight
            app.RXHeight = uieditfield(app.RXReferenceGrid, 'numeric');
            app.RXHeight.Limits = [0 Inf];
            app.RXHeight.RoundFractionalValues = 'on';
            app.RXHeight.ValueDisplayFormat = '%d';
            app.RXHeight.Editable = 'off';
            app.RXHeight.FontSize = 11;
            app.RXHeight.Layout.Row = 2;
            app.RXHeight.Layout.Column = 3;

            % Create filter_SecondaryLabel
            app.filter_SecondaryLabel = uilabel(app.SubGrid2);
            app.filter_SecondaryLabel.VerticalAlignment = 'bottom';
            app.filter_SecondaryLabel.FontSize = 10;
            app.filter_SecondaryLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryLabel.Layout.Row = 3;
            app.filter_SecondaryLabel.Layout.Column = 1;
            app.filter_SecondaryLabel.Text = 'FILTRO';

            % Create FilterOperationButtonGroup
            app.FilterOperationButtonGroup = uibuttongroup(app.SubGrid2);
            app.FilterOperationButtonGroup.AutoResizeChildren = 'off';
            app.FilterOperationButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @onFilterOperationButtonGroupSelectionChanged, true);
            app.FilterOperationButtonGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperationButtonGroup.BackgroundColor = [1 1 1];
            app.FilterOperationButtonGroup.Layout.Row = 5;
            app.FilterOperationButtonGroup.Layout.Column = [1 2];

            % Create FilterOperation1Button
            app.FilterOperation1Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation1Button.Tag = 'numeric+textFree+textList2';
            app.FilterOperation1Button.Tooltip = {'Igual'};
            app.FilterOperation1Button.Text = '=';
            app.FilterOperation1Button.BackgroundColor = [1 1 1];
            app.FilterOperation1Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation1Button.Position = [8 97 24 22];

            % Create FilterOperation2Button
            app.FilterOperation2Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation2Button.Tag = 'numeric+textFree+textList2+textList3';
            app.FilterOperation2Button.Tooltip = {'Diferente'};
            app.FilterOperation2Button.Text = '≠';
            app.FilterOperation2Button.BackgroundColor = [1 1 1];
            app.FilterOperation2Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation2Button.Position = [37 97 24 22];

            % Create FilterOperation3Button
            app.FilterOperation3Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation3Button.Tag = 'ROI+textFree+textList1';
            app.FilterOperation3Button.Enable = 'off';
            app.FilterOperation3Button.Tooltip = {'Contém'};
            app.FilterOperation3Button.Text = '⊃';
            app.FilterOperation3Button.BackgroundColor = [1 1 1];
            app.FilterOperation3Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation3Button.Position = [66 97 24 22];

            % Create FilterOperation4Button
            app.FilterOperation4Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation4Button.Tag = 'textFree+textList1';
            app.FilterOperation4Button.Enable = 'off';
            app.FilterOperation4Button.Tooltip = {'Não contém'};
            app.FilterOperation4Button.Text = '⊅';
            app.FilterOperation4Button.BackgroundColor = [1 1 1];
            app.FilterOperation4Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation4Button.Position = [96 97 24 22];

            % Create FilterOperation5Button
            app.FilterOperation5Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation5Button.Tag = 'numeric';
            app.FilterOperation5Button.Tooltip = {'Menor'};
            app.FilterOperation5Button.Text = '<';
            app.FilterOperation5Button.BackgroundColor = [1 1 1];
            app.FilterOperation5Button.FontName = 'Consolas';
            app.FilterOperation5Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation5Button.Position = [125 97 24 22];

            % Create FilterOperation6Button
            app.FilterOperation6Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation6Button.Tag = 'numeric';
            app.FilterOperation6Button.Tooltip = {'Menor ou igual'};
            app.FilterOperation6Button.Text = '≤';
            app.FilterOperation6Button.BackgroundColor = [1 1 1];
            app.FilterOperation6Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation6Button.Position = [154 97 24 22];
            app.FilterOperation6Button.Value = true;

            % Create FilterOperation7Button
            app.FilterOperation7Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation7Button.Tag = 'numeric';
            app.FilterOperation7Button.Tooltip = {'Maior'};
            app.FilterOperation7Button.Text = '>';
            app.FilterOperation7Button.BackgroundColor = [1 1 1];
            app.FilterOperation7Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation7Button.Position = [182 97 24 22];

            % Create FilterOperation8Button
            app.FilterOperation8Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation8Button.Tag = 'numeric';
            app.FilterOperation8Button.Tooltip = {'Maior ou igual'};
            app.FilterOperation8Button.Text = '≥';
            app.FilterOperation8Button.BackgroundColor = [1 1 1];
            app.FilterOperation8Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation8Button.Position = [211 97 24 22];

            % Create FilterOperation9Button
            app.FilterOperation9Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation9Button.Tag = 'numeric';
            app.FilterOperation9Button.Tooltip = {'Dentro do intervalo'};
            app.FilterOperation9Button.Text = '><';
            app.FilterOperation9Button.BackgroundColor = [1 1 1];
            app.FilterOperation9Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation9Button.Position = [239 97 24 22];

            % Create FilterOperation10Button
            app.FilterOperation10Button = uitogglebutton(app.FilterOperationButtonGroup);
            app.FilterOperation10Button.Tag = 'numeric';
            app.FilterOperation10Button.Tooltip = {'Fora do intervalo'};
            app.FilterOperation10Button.Text = '<>';
            app.FilterOperation10Button.BackgroundColor = [1 1 1];
            app.FilterOperation10Button.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterOperation10Button.Position = [267 97 24 22];

            % Create FilterValuePanel
            app.FilterValuePanel = uipanel(app.FilterOperationButtonGroup);
            app.FilterValuePanel.AutoResizeChildren = 'off';
            app.FilterValuePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterValuePanel.BorderType = 'none';
            app.FilterValuePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.FilterValuePanel.Position = [10 9 278 79];

            % Create FilterValueGrid
            app.FilterValueGrid = uigridlayout(app.FilterValuePanel);
            app.FilterValueGrid.ColumnWidth = {'1x', 10, '1x'};
            app.FilterValueGrid.RowHeight = {22, 25, 22};
            app.FilterValueGrid.ColumnSpacing = 5;
            app.FilterValueGrid.RowSpacing = 5;
            app.FilterValueGrid.Padding = [0 0 0 0];
            app.FilterValueGrid.BackgroundColor = [1 1 1];

            % Create FilterNumericValue1Field
            app.FilterNumericValue1Field = uieditfield(app.FilterValueGrid, 'numeric');
            app.FilterNumericValue1Field.Limits = [-1 Inf];
            app.FilterNumericValue1Field.ValueDisplayFormat = '%10.10g';
            app.FilterNumericValue1Field.FontSize = 11;
            app.FilterNumericValue1Field.FontColor = [0.149 0.149 0.149];
            app.FilterNumericValue1Field.Layout.Row = 1;
            app.FilterNumericValue1Field.Layout.Column = 1;
            app.FilterNumericValue1Field.Value = 30;

            % Create FilterNumericRangeSeparator
            app.FilterNumericRangeSeparator = uilabel(app.FilterValueGrid);
            app.FilterNumericRangeSeparator.HorizontalAlignment = 'center';
            app.FilterNumericRangeSeparator.FontSize = 11;
            app.FilterNumericRangeSeparator.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterNumericRangeSeparator.Visible = 'off';
            app.FilterNumericRangeSeparator.Layout.Row = 1;
            app.FilterNumericRangeSeparator.Layout.Column = 2;
            app.FilterNumericRangeSeparator.Text = '-';

            % Create FilterNumericValue2Field
            app.FilterNumericValue2Field = uieditfield(app.FilterValueGrid, 'numeric');
            app.FilterNumericValue2Field.Limits = [-1 Inf];
            app.FilterNumericValue2Field.FontSize = 11;
            app.FilterNumericValue2Field.FontColor = [0.149 0.149 0.149];
            app.FilterNumericValue2Field.Visible = 'off';
            app.FilterNumericValue2Field.Layout.Row = 1;
            app.FilterNumericValue2Field.Layout.Column = 3;
            app.FilterNumericValue2Field.Value = -1;

            % Create FilterFreeTextField
            app.FilterFreeTextField = uieditfield(app.FilterValueGrid, 'text');
            app.FilterFreeTextField.FontSize = 11;
            app.FilterFreeTextField.FontColor = [0.149 0.149 0.149];
            app.FilterFreeTextField.Visible = 'off';
            app.FilterFreeTextField.Layout.Row = 1;
            app.FilterFreeTextField.Layout.Column = [1 3];

            % Create FilterTextListDropDown
            app.FilterTextListDropDown = uidropdown(app.FilterValueGrid);
            app.FilterTextListDropDown.Items = {};
            app.FilterTextListDropDown.Visible = 'off';
            app.FilterTextListDropDown.FontSize = 11;
            app.FilterTextListDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTextListDropDown.BackgroundColor = [1 1 1];
            app.FilterTextListDropDown.Layout.Row = 1;
            app.FilterTextListDropDown.Layout.Column = [1 3];
            app.FilterTextListDropDown.Value = {};

            % Create FilterReferenceLabel
            app.FilterReferenceLabel = uilabel(app.FilterValueGrid);
            app.FilterReferenceLabel.VerticalAlignment = 'bottom';
            app.FilterReferenceLabel.FontSize = 10;
            app.FilterReferenceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterReferenceLabel.Layout.Row = 2;
            app.FilterReferenceLabel.Layout.Column = 1;
            app.FilterReferenceLabel.Text = {'Filtro de '; 'referência (ID):'};

            % Create FilterReferenceDropDown
            app.FilterReferenceDropDown = uidropdown(app.FilterValueGrid);
            app.FilterReferenceDropDown.Items = {};
            app.FilterReferenceDropDown.ValueChangedFcn = createCallbackFcn(app, @onFilterReferenceValueChanged, true);
            app.FilterReferenceDropDown.FontSize = 11;
            app.FilterReferenceDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterReferenceDropDown.BackgroundColor = [1 1 1];
            app.FilterReferenceDropDown.Layout.Row = 3;
            app.FilterReferenceDropDown.Layout.Column = 1;
            app.FilterReferenceDropDown.Value = {};

            % Create FilterLogicalOperatorLabel
            app.FilterLogicalOperatorLabel = uilabel(app.FilterValueGrid);
            app.FilterLogicalOperatorLabel.VerticalAlignment = 'bottom';
            app.FilterLogicalOperatorLabel.FontSize = 10;
            app.FilterLogicalOperatorLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterLogicalOperatorLabel.Layout.Row = 2;
            app.FilterLogicalOperatorLabel.Layout.Column = 3;
            app.FilterLogicalOperatorLabel.Text = {'Operador '; 'lógico:'};

            % Create FilterLogicalOperatorDropDown
            app.FilterLogicalOperatorDropDown = uidropdown(app.FilterValueGrid);
            app.FilterLogicalOperatorDropDown.Items = {'E (&&)'};
            app.FilterLogicalOperatorDropDown.FontSize = 11;
            app.FilterLogicalOperatorDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterLogicalOperatorDropDown.BackgroundColor = [1 1 1];
            app.FilterLogicalOperatorDropDown.Layout.Row = 3;
            app.FilterLogicalOperatorDropDown.Layout.Column = 3;
            app.FilterLogicalOperatorDropDown.Value = 'E (&&)';

            % Create FilterAddButton
            app.FilterAddButton = uiimage(app.SubGrid2);
            app.FilterAddButton.ScaleMethod = 'none';
            app.FilterAddButton.ImageClickedFcn = createCallbackFcn(app, @onFilterAddButtonClicked, true);
            app.FilterAddButton.Tooltip = {'Adicionar filtro'};
            app.FilterAddButton.Layout.Row = 6;
            app.FilterAddButton.Layout.Column = 2;
            app.FilterAddButton.HorizontalAlignment = 'right';
            app.FilterAddButton.ImageSource = 'Add_16.png';

            % Create FilterRulesTree
            app.FilterRulesTree = uitree(app.SubGrid2, 'checkbox');
            app.FilterRulesTree.FontSize = 10.5;
            app.FilterRulesTree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterRulesTree.Layout.Row = 7;
            app.FilterRulesTree.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.FilterRulesTree.CheckedNodesChangedFcn = createCallbackFcn(app, @onFilterRulesTreeCheckedNodesChanged, true);

            % Create RXTitleGrid
            app.RXTitleGrid = uigridlayout(app.SubGrid2);
            app.RXTitleGrid.ColumnWidth = {22, '1x', 18, 18, 0, 0};
            app.RXTitleGrid.RowHeight = {18, 18};
            app.RXTitleGrid.ColumnSpacing = 5;
            app.RXTitleGrid.RowSpacing = 0;
            app.RXTitleGrid.Padding = [0 0 0 0];
            app.RXTitleGrid.Layout.Row = 1;
            app.RXTitleGrid.Layout.Column = [1 2];
            app.RXTitleGrid.BackgroundColor = [1 1 1];

            % Create RXPanelIcon
            app.RXPanelIcon = uiimage(app.RXTitleGrid);
            app.RXPanelIcon.Layout.Row = [1 2];
            app.RXPanelIcon.Layout.Column = 1;
            app.RXPanelIcon.ImageSource = 'Pin_32Triangle.png';

            % Create RXPanelTitle
            app.RXPanelTitle = uilabel(app.RXTitleGrid);
            app.RXPanelTitle.VerticalAlignment = 'bottom';
            app.RXPanelTitle.FontSize = 11;
            app.RXPanelTitle.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXPanelTitle.Layout.Row = [1 2];
            app.RXPanelTitle.Layout.Column = 2;
            app.RXPanelTitle.Interpreter = 'html';
            app.RXPanelTitle.Text = {'<b>Estação receptora - RX</b>'; '<font style="font-size: 9px; color: gray;">(referência coluna "Distância" e enlace)</font>'};

            % Create RXRefreshButton
            app.RXRefreshButton = uiimage(app.RXTitleGrid);
            app.RXRefreshButton.ScaleMethod = 'none';
            app.RXRefreshButton.ImageClickedFcn = createCallbackFcn(app, @onRXEditButtonClicked, true);
            app.RXRefreshButton.Visible = 'off';
            app.RXRefreshButton.Layout.Row = 2;
            app.RXRefreshButton.Layout.Column = 3;
            app.RXRefreshButton.ImageSource = 'Refresh_18.png';

            % Create RXEditModeButton
            app.RXEditModeButton = uiimage(app.RXTitleGrid);
            app.RXEditModeButton.ImageClickedFcn = createCallbackFcn(app, @onRXEditButtonClicked, true);
            app.RXEditModeButton.Layout.Row = 2;
            app.RXEditModeButton.Layout.Column = 4;
            app.RXEditModeButton.ImageSource = 'Edit_32.png';

            % Create RXEditConfirmButton
            app.RXEditConfirmButton = uiimage(app.RXTitleGrid);
            app.RXEditConfirmButton.ImageClickedFcn = createCallbackFcn(app, @onRXEditButtonClicked, true);
            app.RXEditConfirmButton.Enable = 'off';
            app.RXEditConfirmButton.Layout.Row = 2;
            app.RXEditConfirmButton.Layout.Column = 5;
            app.RXEditConfirmButton.ImageSource = 'Ok_32Green.png';

            % Create RXEditCancelButton
            app.RXEditCancelButton = uiimage(app.RXTitleGrid);
            app.RXEditCancelButton.ImageClickedFcn = createCallbackFcn(app, @onRXEditButtonClicked, true);
            app.RXEditCancelButton.Enable = 'off';
            app.RXEditCancelButton.Layout.Row = 2;
            app.RXEditCancelButton.Layout.Column = 6;
            app.RXEditCancelButton.ImageSource = 'Delete_32Red.png';

            % Create FilterTypeButtonGroup
            app.FilterTypeButtonGroup = uibuttongroup(app.SubGrid2);
            app.FilterTypeButtonGroup.AutoResizeChildren = 'off';
            app.FilterTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @onFilterTypeButtonGroupSelectionChanged, true);
            app.FilterTypeButtonGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeButtonGroup.BackgroundColor = [1 1 1];
            app.FilterTypeButtonGroup.Layout.Row = 4;
            app.FilterTypeButtonGroup.Layout.Column = [1 2];
            app.FilterTypeButtonGroup.FontWeight = 'bold';
            app.FilterTypeButtonGroup.FontSize = 10;

            % Create FilterTypeSourceRadio
            app.FilterTypeSourceRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeSourceRadio.Tag = 'Source';
            app.FilterTypeSourceRadio.Text = 'Base de dados';
            app.FilterTypeSourceRadio.FontSize = 10.5;
            app.FilterTypeSourceRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeSourceRadio.Interpreter = 'html';
            app.FilterTypeSourceRadio.Position = [8 69 94 22];

            % Create FilterTypeFrequencyRadio
            app.FilterTypeFrequencyRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeFrequencyRadio.Tag = 'Frequency';
            app.FilterTypeFrequencyRadio.Text = 'Frequência (MHz)';
            app.FilterTypeFrequencyRadio.FontSize = 10.5;
            app.FilterTypeFrequencyRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeFrequencyRadio.Interpreter = 'html';
            app.FilterTypeFrequencyRadio.Position = [8 48 108 22];

            % Create FilterTypeBandwidthRadio
            app.FilterTypeBandwidthRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeBandwidthRadio.Tag = 'BW';
            app.FilterTypeBandwidthRadio.Text = 'Largura (kHz)';
            app.FilterTypeBandwidthRadio.FontSize = 10.5;
            app.FilterTypeBandwidthRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeBandwidthRadio.Interpreter = 'html';
            app.FilterTypeBandwidthRadio.Position = [8 27 88 22];

            % Create FilterTypeEntityRadio
            app.FilterTypeEntityRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeEntityRadio.Tag = '_Name';
            app.FilterTypeEntityRadio.Text = 'Entidade';
            app.FilterTypeEntityRadio.FontSize = 10.5;
            app.FilterTypeEntityRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeEntityRadio.Interpreter = 'html';
            app.FilterTypeEntityRadio.Position = [136 69 63 22];

            % Create FilterTypeFistelRadio
            app.FilterTypeFistelRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeFistelRadio.Tag = 'Fistel';
            app.FilterTypeFistelRadio.Text = 'Fistel';
            app.FilterTypeFistelRadio.FontSize = 10.5;
            app.FilterTypeFistelRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeFistelRadio.Interpreter = 'html';
            app.FilterTypeFistelRadio.Position = [136 48 47 22];

            % Create FilterTypeServiceRadio
            app.FilterTypeServiceRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeServiceRadio.Tag = 'Service';
            app.FilterTypeServiceRadio.Text = 'Serviço';
            app.FilterTypeServiceRadio.FontSize = 10.5;
            app.FilterTypeServiceRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeServiceRadio.Interpreter = 'html';
            app.FilterTypeServiceRadio.Position = [136 27 57 22];

            % Create FilterTypeStationRadio
            app.FilterTypeStationRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeStationRadio.Tag = 'Station';
            app.FilterTypeStationRadio.Text = 'Estação';
            app.FilterTypeStationRadio.FontSize = 10.5;
            app.FilterTypeStationRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeStationRadio.Interpreter = 'html';
            app.FilterTypeStationRadio.Position = [136 6 60 22];

            % Create FilterTypeStateRadio
            app.FilterTypeStateRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeStateRadio.Tag = 'State';
            app.FilterTypeStateRadio.Text = 'UF';
            app.FilterTypeStateRadio.FontSize = 10.5;
            app.FilterTypeStateRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeStateRadio.Interpreter = 'html';
            app.FilterTypeStateRadio.Position = [224 69 36 22];

            % Create FilterTypeMunicipalityRadio
            app.FilterTypeMunicipalityRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeMunicipalityRadio.Tag = '_Location';
            app.FilterTypeMunicipalityRadio.Text = 'Município';
            app.FilterTypeMunicipalityRadio.FontSize = 10.5;
            app.FilterTypeMunicipalityRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeMunicipalityRadio.Interpreter = 'html';
            app.FilterTypeMunicipalityRadio.Position = [224 48 67 22];

            % Create FilterTypeDistanceRadio
            app.FilterTypeDistanceRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeDistanceRadio.Tag = 'Distance';
            app.FilterTypeDistanceRadio.Text = 'Distância';
            app.FilterTypeDistanceRadio.FontSize = 10.5;
            app.FilterTypeDistanceRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeDistanceRadio.Interpreter = 'html';
            app.FilterTypeDistanceRadio.Position = [224 27 65 22];
            app.FilterTypeDistanceRadio.Value = true;

            % Create FilterTypeROIRadio
            app.FilterTypeROIRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeROIRadio.Tag = '-1';
            app.FilterTypeROIRadio.Text = 'ROI';
            app.FilterTypeROIRadio.FontSize = 10.5;
            app.FilterTypeROIRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeROIRadio.Interpreter = 'html';
            app.FilterTypeROIRadio.Position = [224 5 41 22];

            % Create FilterTypeAntennaPatternRadio
            app.FilterTypeAntennaPatternRadio = uiradiobutton(app.FilterTypeButtonGroup);
            app.FilterTypeAntennaPatternRadio.Tag = 'AntennaPattern';
            app.FilterTypeAntennaPatternRadio.Text = 'Padrão de antena';
            app.FilterTypeAntennaPatternRadio.FontSize = 10.5;
            app.FilterTypeAntennaPatternRadio.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FilterTypeAntennaPatternRadio.Interpreter = 'html';
            app.FilterTypeAntennaPatternRadio.Position = [8 6 106 22];

            % Create SubTab3
            app.SubTab3 = uitab(app.SubTabGroup);
            app.SubTab3.AutoResizeChildren = 'off';
            app.SubTab3.Title = 'CONFIG';
            app.SubTab3.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SubTab3.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create SubGrid3
            app.SubGrid3 = uigridlayout(app.SubTab3);
            app.SubGrid3.ColumnWidth = {'1x', 18};
            app.SubGrid3.RowHeight = {22, 284, 22, '1x'};
            app.SubGrid3.ColumnSpacing = 5;
            app.SubGrid3.RowSpacing = 5;
            app.SubGrid3.Padding = [10 10 10 5];
            app.SubGrid3.BackgroundColor = [1 1 1];

            % Create GeoAxesSettingsSectionLabel
            app.GeoAxesSettingsSectionLabel = uilabel(app.SubGrid3);
            app.GeoAxesSettingsSectionLabel.VerticalAlignment = 'bottom';
            app.GeoAxesSettingsSectionLabel.WordWrap = 'on';
            app.GeoAxesSettingsSectionLabel.FontSize = 10;
            app.GeoAxesSettingsSectionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.GeoAxesSettingsSectionLabel.Layout.Row = 1;
            app.GeoAxesSettingsSectionLabel.Layout.Column = 1;
            app.GeoAxesSettingsSectionLabel.Text = 'EIXO GEOGRÁFICO';

            % Create SettingsResetButton
            app.SettingsResetButton = uiimage(app.SubGrid3);
            app.SettingsResetButton.ScaleMethod = 'none';
            app.SettingsResetButton.ImageClickedFcn = createCallbackFcn(app, @onConfigResetButtonClicked, true);
            app.SettingsResetButton.Visible = 'off';
            app.SettingsResetButton.Layout.Row = 1;
            app.SettingsResetButton.Layout.Column = 2;
            app.SettingsResetButton.ImageSource = 'Refresh_18.png';

            % Create GeoAxesSettingsPanel
            app.GeoAxesSettingsPanel = uipanel(app.SubGrid3);
            app.GeoAxesSettingsPanel.AutoResizeChildren = 'off';
            app.GeoAxesSettingsPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.GeoAxesSettingsPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.GeoAxesSettingsPanel.Layout.Row = 2;
            app.GeoAxesSettingsPanel.Layout.Column = [1 2];

            % Create GeoAxesSettingsGrid
            app.GeoAxesSettingsGrid = uigridlayout(app.GeoAxesSettingsPanel);
            app.GeoAxesSettingsGrid.ColumnWidth = {36, '1x', 36, '1x'};
            app.GeoAxesSettingsGrid.RowHeight = {17, 22, 40, 22, 40, 22, 40, 22};
            app.GeoAxesSettingsGrid.RowSpacing = 5;
            app.GeoAxesSettingsGrid.BackgroundColor = [1 1 1];

            % Create BasemapLabel
            app.BasemapLabel = uilabel(app.GeoAxesSettingsGrid);
            app.BasemapLabel.VerticalAlignment = 'bottom';
            app.BasemapLabel.FontSize = 11;
            app.BasemapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BasemapLabel.Layout.Row = 1;
            app.BasemapLabel.Layout.Column = [1 2];
            app.BasemapLabel.Text = 'Basemap:';

            % Create Basemap
            app.Basemap = uidropdown(app.GeoAxesSettingsGrid);
            app.Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.Basemap.ValueChangedFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.Basemap.FontSize = 11;
            app.Basemap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Basemap.BackgroundColor = [1 1 1];
            app.Basemap.Layout.Row = 2;
            app.Basemap.Layout.Column = [1 2];
            app.Basemap.Value = 'satellite';

            % Create ColormapLabel
            app.ColormapLabel = uilabel(app.GeoAxesSettingsGrid);
            app.ColormapLabel.VerticalAlignment = 'bottom';
            app.ColormapLabel.FontSize = 11;
            app.ColormapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ColormapLabel.Layout.Row = 1;
            app.ColormapLabel.Layout.Column = [3 4];
            app.ColormapLabel.Text = 'Mapa de cor:';

            % Create Colormap
            app.Colormap = uidropdown(app.GeoAxesSettingsGrid);
            app.Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.Colormap.ValueChangedFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.Colormap.FontSize = 11;
            app.Colormap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Colormap.BackgroundColor = [1 1 1];
            app.Colormap.Layout.Row = 2;
            app.Colormap.Layout.Column = [3 4];
            app.Colormap.Value = 'winter';

            % Create StationMarkerSectionLabel
            app.StationMarkerSectionLabel = uilabel(app.GeoAxesSettingsGrid);
            app.StationMarkerSectionLabel.VerticalAlignment = 'bottom';
            app.StationMarkerSectionLabel.FontSize = 11;
            app.StationMarkerSectionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.StationMarkerSectionLabel.Layout.Row = 3;
            app.StationMarkerSectionLabel.Layout.Column = [1 3];
            app.StationMarkerSectionLabel.Interpreter = 'html';
            app.StationMarkerSectionLabel.Text = {'Estação RF.DataHub:'; '<font style="font-size: 9px; color: gray;">(Cor e tamanho do marcador)</font>'};

            % Create StationMarkerColorPicker
            app.StationMarkerColorPicker = uicolorpicker(app.GeoAxesSettingsGrid);
            app.StationMarkerColorPicker.Value = [0 1 1];
            app.StationMarkerColorPicker.ValueChangedFcn = createCallbackFcn(app, @onConfigRXParameterChanged, true);
            app.StationMarkerColorPicker.Layout.Row = 4;
            app.StationMarkerColorPicker.Layout.Column = 1;
            app.StationMarkerColorPicker.BackgroundColor = [1 1 1];

            % Create StationMarkerSizeSlider
            app.StationMarkerSizeSlider = uislider(app.GeoAxesSettingsGrid);
            app.StationMarkerSizeSlider.Limits = [1 36];
            app.StationMarkerSizeSlider.MajorTicks = [];
            app.StationMarkerSizeSlider.MajorTickLabels = {''};
            app.StationMarkerSizeSlider.ValueChangingFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.StationMarkerSizeSlider.MinorTicks = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36];
            app.StationMarkerSizeSlider.FontSize = 10;
            app.StationMarkerSizeSlider.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.StationMarkerSizeSlider.Tooltip = {''};
            app.StationMarkerSizeSlider.Layout.Row = 4;
            app.StationMarkerSizeSlider.Layout.Column = [2 4];
            app.StationMarkerSizeSlider.Value = 1;

            % Create TXMarkerSectionLabel
            app.TXMarkerSectionLabel = uilabel(app.GeoAxesSettingsGrid);
            app.TXMarkerSectionLabel.VerticalAlignment = 'bottom';
            app.TXMarkerSectionLabel.FontSize = 11;
            app.TXMarkerSectionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXMarkerSectionLabel.Layout.Row = 5;
            app.TXMarkerSectionLabel.Layout.Column = [1 4];
            app.TXMarkerSectionLabel.Interpreter = 'html';
            app.TXMarkerSectionLabel.Text = {'Estação transmissora - TX:'; '<font style="font-size: 9px; color: gray;">(Cor, visibilidade do datatip e tamanho do marcador)</font>'};

            % Create TXMarkerColorPicker
            app.TXMarkerColorPicker = uicolorpicker(app.GeoAxesSettingsGrid);
            app.TXMarkerColorPicker.Value = [0.7882 0.2784 0.3412];
            app.TXMarkerColorPicker.ValueChangedFcn = createCallbackFcn(app, @onConfigRXParameterChanged, true);
            app.TXMarkerColorPicker.Layout.Row = 6;
            app.TXMarkerColorPicker.Layout.Column = 1;
            app.TXMarkerColorPicker.BackgroundColor = [1 1 1];

            % Create TXMarkerSizeSlider
            app.TXMarkerSizeSlider = uislider(app.GeoAxesSettingsGrid);
            app.TXMarkerSizeSlider.Limits = [1 3];
            app.TXMarkerSizeSlider.MajorTicks = [];
            app.TXMarkerSizeSlider.MajorTickLabels = {''};
            app.TXMarkerSizeSlider.ValueChangingFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.TXMarkerSizeSlider.MinorTicks = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3];
            app.TXMarkerSizeSlider.FontSize = 10;
            app.TXMarkerSizeSlider.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXMarkerSizeSlider.Tooltip = {''};
            app.TXMarkerSizeSlider.Layout.Row = 6;
            app.TXMarkerSizeSlider.Layout.Column = [3 4];
            app.TXMarkerSizeSlider.Value = 1;

            % Create TXDataTipVisibilityDropDown
            app.TXDataTipVisibilityDropDown = uidropdown(app.GeoAxesSettingsGrid);
            app.TXDataTipVisibilityDropDown.Items = {'on', 'off'};
            app.TXDataTipVisibilityDropDown.ValueChangedFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.TXDataTipVisibilityDropDown.Tooltip = {''};
            app.TXDataTipVisibilityDropDown.FontSize = 11;
            app.TXDataTipVisibilityDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TXDataTipVisibilityDropDown.BackgroundColor = [1 1 1];
            app.TXDataTipVisibilityDropDown.Layout.Row = 6;
            app.TXDataTipVisibilityDropDown.Layout.Column = 2;
            app.TXDataTipVisibilityDropDown.Value = 'on';

            % Create RXMarkerSectionLabel
            app.RXMarkerSectionLabel = uilabel(app.GeoAxesSettingsGrid);
            app.RXMarkerSectionLabel.VerticalAlignment = 'bottom';
            app.RXMarkerSectionLabel.FontSize = 11;
            app.RXMarkerSectionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXMarkerSectionLabel.Layout.Row = 7;
            app.RXMarkerSectionLabel.Layout.Column = [1 4];
            app.RXMarkerSectionLabel.Interpreter = 'html';
            app.RXMarkerSectionLabel.Text = {'Estação transmissora - RX:'; '<font style="font-size: 9px; color: gray;">(Cor e tamanho do marcador)</font>'};

            % Create RXMarkerColorPicker
            app.RXMarkerColorPicker = uicolorpicker(app.GeoAxesSettingsGrid);
            app.RXMarkerColorPicker.Value = [0.7882 0.2784 0.3373];
            app.RXMarkerColorPicker.ValueChangedFcn = createCallbackFcn(app, @onConfigRXParameterChanged, true);
            app.RXMarkerColorPicker.Layout.Row = 8;
            app.RXMarkerColorPicker.Layout.Column = 1;
            app.RXMarkerColorPicker.BackgroundColor = [1 1 1];

            % Create RXMarkerSizeSlider
            app.RXMarkerSizeSlider = uislider(app.GeoAxesSettingsGrid);
            app.RXMarkerSizeSlider.Limits = [1 3];
            app.RXMarkerSizeSlider.MajorTicks = [];
            app.RXMarkerSizeSlider.MajorTickLabels = {''};
            app.RXMarkerSizeSlider.ValueChangingFcn = createCallbackFcn(app, @onConfigOthersParameterChanged, true);
            app.RXMarkerSizeSlider.MinorTicks = [1 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2 2.05 2.1 2.15 2.2 2.25 2.3 2.35 2.4 2.45 2.5 2.55 2.6 2.65 2.7 2.75 2.8 2.85 2.9 2.95 3];
            app.RXMarkerSizeSlider.FontSize = 10;
            app.RXMarkerSizeSlider.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RXMarkerSizeSlider.Tooltip = {''};
            app.RXMarkerSizeSlider.Layout.Row = 8;
            app.RXMarkerSizeSlider.Layout.Column = [2 4];
            app.RXMarkerSizeSlider.Value = 1;

            % Create ElevationSourceSectionLabel
            app.ElevationSourceSectionLabel = uilabel(app.SubGrid3);
            app.ElevationSourceSectionLabel.VerticalAlignment = 'bottom';
            app.ElevationSourceSectionLabel.FontSize = 10;
            app.ElevationSourceSectionLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationSourceSectionLabel.Layout.Row = 3;
            app.ElevationSourceSectionLabel.Layout.Column = 1;
            app.ElevationSourceSectionLabel.Text = 'ELEVAÇÃO';

            % Create ElevationSourcePanel
            app.ElevationSourcePanel = uipanel(app.SubGrid3);
            app.ElevationSourcePanel.AutoResizeChildren = 'off';
            app.ElevationSourcePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationSourcePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ElevationSourcePanel.Layout.Row = 4;
            app.ElevationSourcePanel.Layout.Column = [1 2];

            % Create ElevationSourceGrid
            app.ElevationSourceGrid = uigridlayout(app.ElevationSourcePanel);
            app.ElevationSourceGrid.ColumnWidth = {110, '1x'};
            app.ElevationSourceGrid.RowHeight = {17, 22, 22, 22, 40};
            app.ElevationSourceGrid.RowSpacing = 5;
            app.ElevationSourceGrid.BackgroundColor = [1 1 1];

            % Create ElevationProviderLabel
            app.ElevationProviderLabel = uilabel(app.ElevationSourceGrid);
            app.ElevationProviderLabel.VerticalAlignment = 'bottom';
            app.ElevationProviderLabel.FontSize = 11;
            app.ElevationProviderLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationProviderLabel.Layout.Row = 1;
            app.ElevationProviderLabel.Layout.Column = 1;
            app.ElevationProviderLabel.Text = 'Provedor:';

            % Create ElevationProvider
            app.ElevationProvider = uidropdown(app.ElevationSourceGrid);
            app.ElevationProvider.Items = {'Open-Elevation', 'MathWorks WMS Server'};
            app.ElevationProvider.FontSize = 11;
            app.ElevationProvider.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationProvider.BackgroundColor = [1 1 1];
            app.ElevationProvider.Layout.Row = 2;
            app.ElevationProvider.Layout.Column = [1 2];
            app.ElevationProvider.Value = 'Open-Elevation';

            % Create ElevationPointCountLabel
            app.ElevationPointCountLabel = uilabel(app.ElevationSourceGrid);
            app.ElevationPointCountLabel.VerticalAlignment = 'bottom';
            app.ElevationPointCountLabel.FontSize = 11;
            app.ElevationPointCountLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationPointCountLabel.Layout.Row = 3;
            app.ElevationPointCountLabel.Layout.Column = 1;
            app.ElevationPointCountLabel.Text = 'Pontos enlace:';

            % Create ElevationPointCount
            app.ElevationPointCount = uidropdown(app.ElevationSourceGrid);
            app.ElevationPointCount.Items = {'64', '128', '256', '512', '1024'};
            app.ElevationPointCount.FontSize = 11;
            app.ElevationPointCount.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationPointCount.BackgroundColor = [1 1 1];
            app.ElevationPointCount.Layout.Row = 4;
            app.ElevationPointCount.Layout.Column = 1;
            app.ElevationPointCount.Value = '256';

            % Create ElevationForceSearchCheckBox
            app.ElevationForceSearchCheckBox = uicheckbox(app.ElevationSourceGrid);
            app.ElevationForceSearchCheckBox.Text = 'Ignora informações em cache, forçando uma consulta ao servidor.';
            app.ElevationForceSearchCheckBox.WordWrap = 'on';
            app.ElevationForceSearchCheckBox.FontSize = 11;
            app.ElevationForceSearchCheckBox.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ElevationForceSearchCheckBox.Layout.Row = 5;
            app.ElevationForceSearchCheckBox.Layout.Column = [1 2];

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {5, 50, '1x', 0, 0, 0, 0};
            app.Document.RowHeight = {24, '1x', 10, '0.4x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 5];
            app.Document.BackgroundColor = [1 1 1];

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
            app.UITable.Layout.Column = [1 7];
            app.UITable.FontSize = 11;

            % Create ChannelReportViewer
            app.ChannelReportViewer = uihtml(app.Document);
            app.ChannelReportViewer.HTMLSource = 'Warning2.html';
            app.ChannelReportViewer.Layout.Row = 2;
            app.ChannelReportViewer.Layout.Column = [5 7];

            % Create ChannelReportDownloadTimeLabel
            app.ChannelReportDownloadTimeLabel = uilabel(app.Document);
            app.ChannelReportDownloadTimeLabel.BackgroundColor = [0.2 0.2 0.2];
            app.ChannelReportDownloadTimeLabel.HorizontalAlignment = 'center';
            app.ChannelReportDownloadTimeLabel.FontSize = 10;
            app.ChannelReportDownloadTimeLabel.FontColor = [0.902 0.902 0.902];
            app.ChannelReportDownloadTimeLabel.Layout.Row = 1;
            app.ChannelReportDownloadTimeLabel.Layout.Column = [5 7];
            app.ChannelReportDownloadTimeLabel.Text = '';

            % Create ChannelReportDownloadButton
            app.ChannelReportDownloadButton = uiimage(app.Document);
            app.ChannelReportDownloadButton.ScaleMethod = 'none';
            app.ChannelReportDownloadButton.ImageClickedFcn = createCallbackFcn(app, @onChannelReportButtonClicked, true);
            app.ChannelReportDownloadButton.Visible = 'off';
            app.ChannelReportDownloadButton.Tooltip = {'Baixa versão atual do documento'};
            app.ChannelReportDownloadButton.Layout.Row = 1;
            app.ChannelReportDownloadButton.Layout.Column = 5;
            app.ChannelReportDownloadButton.ImageSource = 'refresh-18px-white.png';

            % Create ChannelReportUndockButton
            app.ChannelReportUndockButton = uiimage(app.Document);
            app.ChannelReportUndockButton.ScaleMethod = 'none';
            app.ChannelReportUndockButton.ImageClickedFcn = createCallbackFcn(app, @onChannelReportButtonClicked, true);
            app.ChannelReportUndockButton.Visible = 'off';
            app.ChannelReportUndockButton.Tooltip = {'Abre documento em leitor externo'};
            app.ChannelReportUndockButton.Layout.Row = 1;
            app.ChannelReportUndockButton.Layout.Column = 6;
            app.ChannelReportUndockButton.ImageSource = 'Undock_18White.png';

            % Create PlotPanel
            app.PlotPanel = uipanel(app.Document);
            app.PlotPanel.AutoResizeChildren = 'off';
            app.PlotPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PlotPanel.BorderType = 'none';
            app.PlotPanel.BackgroundColor = [1 1 1];
            app.PlotPanel.Layout.Row = [1 2];
            app.PlotPanel.Layout.Column = [1 3];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {22, 22};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 2;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create AxesRestoreViewButton
            app.AxesRestoreViewButton = uiimage(app.AxesToolbar);
            app.AxesRestoreViewButton.ScaleMethod = 'none';
            app.AxesRestoreViewButton.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.AxesRestoreViewButton.Layout.Row = 1;
            app.AxesRestoreViewButton.Layout.Column = 1;
            app.AxesRestoreViewButton.ImageSource = 'Home_18.png';

            % Create AxesRegionZoomButton
            app.AxesRegionZoomButton = uiimage(app.AxesToolbar);
            app.AxesRegionZoomButton.ScaleMethod = 'none';
            app.AxesRegionZoomButton.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarButtonClicked, true);
            app.AxesRegionZoomButton.Layout.Row = 1;
            app.AxesRegionZoomButton.Layout.Column = 2;
            app.AxesRegionZoomButton.ImageSource = 'ZoomRegion_20.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [5 6];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

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

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winRFDataHub';

            % Create DeleteFilterMenuItem
            app.DeleteFilterMenuItem = uimenu(app.ContextMenu);
            app.DeleteFilterMenuItem.MenuSelectedFcn = createCallbackFcn(app, @onFilterDeleteButtonClicked, true);
            app.DeleteFilterMenuItem.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DeleteFilterMenuItem.Text = '❌ Excluir';

            % Create DeleteAllFiltersMenuItem
            app.DeleteAllFiltersMenuItem = uimenu(app.ContextMenu);
            app.DeleteAllFiltersMenuItem.MenuSelectedFcn = createCallbackFcn(app, @onFilterDeleteButtonClicked, true);
            app.DeleteAllFiltersMenuItem.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DeleteAllFiltersMenuItem.Text = '⛔ Excluir todos';

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
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
