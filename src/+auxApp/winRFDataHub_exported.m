classdef winRFDataHub_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        dockModule_Close                matlab.ui.control.Image
        dockModule_Undock               matlab.ui.control.Image
        Document                        matlab.ui.container.GridLayout
        AxesToolbar                     matlab.ui.container.GridLayout
        axesTool_RegionZoom             matlab.ui.control.Image
        axesTool_RestoreView            matlab.ui.control.Image
        plotPanel                       matlab.ui.container.Panel
        chReportUndock                  matlab.ui.control.Image
        chReportHotDownload             matlab.ui.control.Image
        chReportDownloadTime            matlab.ui.control.Label
        chReportHTML                    matlab.ui.control.HTML
        UITable                         matlab.ui.control.Table
        SubTabGroup                     matlab.ui.container.TabGroup
        SubTab1                         matlab.ui.container.Tab
        SubGrid1                        matlab.ui.container.GridLayout
        stationInfo                     matlab.ui.control.Label
        stationInfoAntennaPattern       matlab.ui.container.Panel
        stationInfoImage                matlab.ui.control.Image
        referenceTX_Panel               matlab.ui.container.Panel
        referenceTX_Grid                matlab.ui.container.GridLayout
        referenceTX_Height              matlab.ui.control.NumericEditField
        referenceTX_HeightLabel         matlab.ui.control.Label
        referenceTX_Longitude           matlab.ui.control.NumericEditField
        referenceTX_LongitudeLabel      matlab.ui.control.Label
        referenceTX_Latitude            matlab.ui.control.NumericEditField
        referenceTX_LatitudeLabel       matlab.ui.control.Label
        referenceTX_TitleGrid           matlab.ui.container.GridLayout
        referenceTX_EditionCancel       matlab.ui.control.Image
        referenceTX_EditionConfirm      matlab.ui.control.Image
        referenceTX_EditionMode         matlab.ui.control.Image
        referenceTX_Refresh             matlab.ui.control.Image
        referenceTX_Label               matlab.ui.control.Label
        referenceTX_Icon                matlab.ui.control.Image
        SubTab2                         matlab.ui.container.Tab
        SubGrid2                        matlab.ui.container.GridLayout
        filter_SecondaryTypePanel       matlab.ui.container.ButtonGroup
        filter_SecondaryType13          matlab.ui.control.RadioButton
        filter_SecondaryType12          matlab.ui.control.RadioButton
        filter_SecondaryType11          matlab.ui.control.RadioButton
        filter_SecondaryType10          matlab.ui.control.RadioButton
        filter_SecondaryType9           matlab.ui.control.RadioButton
        filter_SecondaryType8           matlab.ui.control.RadioButton
        filter_SecondaryType7           matlab.ui.control.RadioButton
        filter_SecondaryType6           matlab.ui.control.RadioButton
        filter_SecondaryType5           matlab.ui.control.RadioButton
        filter_SecondaryType3           matlab.ui.control.RadioButton
        filter_SecondaryType2           matlab.ui.control.RadioButton
        filter_SecondaryType1           matlab.ui.control.RadioButton
        referenceRX_TitleGrid           matlab.ui.container.GridLayout
        referenceRX_EditionCancel       matlab.ui.control.Image
        referenceRX_EditionConfirm      matlab.ui.control.Image
        referenceRX_EditionMode         matlab.ui.control.Image
        referenceRX_Refresh             matlab.ui.control.Image
        referenceRX_Label               matlab.ui.control.Label
        referenceRX_Icon                matlab.ui.control.Image
        filter_Tree                     matlab.ui.container.CheckBoxTree
        filter_AddImage                 matlab.ui.control.Image
        filter_SecondaryValuePanel      matlab.ui.container.ButtonGroup
        filter_SecondaryValueSubpanel   matlab.ui.container.Panel
        filter_SecondaryValueGrid       matlab.ui.container.GridLayout
        filter_SecondaryLogicalOperator  matlab.ui.control.DropDown
        filter_SecondaryLogicalOperatorLabel  matlab.ui.control.Label
        filter_SecondaryReferenceFilter  matlab.ui.control.DropDown
        filter_SecondaryReferenceFilterLabel  matlab.ui.control.Label
        filter_SecondaryTextList        matlab.ui.control.DropDown
        filter_SecondaryTextFree        matlab.ui.control.EditField
        filter_SecondaryNumValue2       matlab.ui.control.NumericEditField
        filter_SecondaryNumSeparator    matlab.ui.control.Label
        filter_SecondaryNumValue1       matlab.ui.control.NumericEditField
        filter_SecondaryOperation10     matlab.ui.control.ToggleButton
        filter_SecondaryOperation9      matlab.ui.control.ToggleButton
        filter_SecondaryOperation8      matlab.ui.control.ToggleButton
        filter_SecondaryOperation7      matlab.ui.control.ToggleButton
        filter_SecondaryOperation6      matlab.ui.control.ToggleButton
        filter_SecondaryOperation5      matlab.ui.control.ToggleButton
        filter_SecondaryOperation4      matlab.ui.control.ToggleButton
        filter_SecondaryOperation3      matlab.ui.control.ToggleButton
        filter_SecondaryOperation2      matlab.ui.control.ToggleButton
        filter_SecondaryOperation1      matlab.ui.control.ToggleButton
        filter_SecondaryLabel           matlab.ui.control.Label
        referenceRX_Panel               matlab.ui.container.Panel
        referenceRX_Grid                matlab.ui.container.GridLayout
        referenceRX_Height              matlab.ui.control.NumericEditField
        referenceRX_HeightLabel         matlab.ui.control.Label
        referenceRX_Longitude           matlab.ui.control.NumericEditField
        referenceRX_LongitudeLabel      matlab.ui.control.Label
        referenceRX_Latitude            matlab.ui.control.NumericEditField
        referenceRX_LatitudeLabel       matlab.ui.control.Label
        SubTab3                         matlab.ui.container.Tab
        SubGrid3                        matlab.ui.container.GridLayout
        config_ElevationSourcePanel     matlab.ui.container.Panel
        config_ElevationSourceGrid      matlab.ui.container.GridLayout
        config_ElevationForceSearch     matlab.ui.control.CheckBox
        config_ElevationNPoints         matlab.ui.control.DropDown
        config_ElevationNPointsLabel    matlab.ui.control.Label
        config_ElevationAPISource       matlab.ui.control.DropDown
        config_ElevationAPISourceLabel  matlab.ui.control.Label
        config_ElevationSourceLabel     matlab.ui.control.Label
        config_geoAxesPanel             matlab.ui.container.Panel
        config_geoAxesGrid              matlab.ui.container.GridLayout
        config_RX_Size                  matlab.ui.control.Slider
        config_RX_Color                 matlab.ui.control.ColorPicker
        config_RX_Label                 matlab.ui.control.Label
        config_TX_DataTipVisibility     matlab.ui.control.DropDown
        config_TX_Size                  matlab.ui.control.Slider
        config_TX_Color                 matlab.ui.control.ColorPicker
        config_TX_Label                 matlab.ui.control.Label
        config_Station_Size             matlab.ui.control.Slider
        config_Station_Color            matlab.ui.control.ColorPicker
        config_Station_Label            matlab.ui.control.Label
        config_Colormap                 matlab.ui.control.DropDown
        config_ColormapLabel            matlab.ui.control.Label
        config_Basemap                  matlab.ui.control.DropDown
        config_BasemapLabel             matlab.ui.control.Label
        config_Refresh                  matlab.ui.control.Image
        config_geoAxesLabel             matlab.ui.control.Label
        Toolbar                         matlab.ui.container.GridLayout
        tool_tableNRowsIcon             matlab.ui.control.Image
        tool_tableNRows                 matlab.ui.control.Label
        tool_ExportButton               matlab.ui.control.Image
        tool_Separator2                 matlab.ui.control.Image
        tool_PDFButton                  matlab.ui.control.Image
        tool_RFLinkButton               matlab.ui.control.Image
        tool_TableVisibility            matlab.ui.control.Image
        tool_Separator1                 matlab.ui.control.Image
        tool_PanelVisibility            matlab.ui.control.Image
        ContextMenu                     matlab.ui.container.ContextMenu
        contextmenu_del                 matlab.ui.container.Menu
        contextmenu_delAll              matlab.ui.container.Menu
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

        elevationObj = RF.Elevation
        ChannelReportObj

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
        ANNOTATION_STYLE = uistyle('Icon', 'edit.svg', 'IconAlignment', 'leftmargin')

        FILTER_TYPE_TO_COLUMNS = dictionary( ...
            ["Fonte", "Frequência", "Largura banda", "Entidade", "Fistel", "Serviço", "Estação", "UF", "Município", "Distância"], ...
            ["Source", "Frequency", "BW", "_Name", "Fistel", "Service", "Station", "State", "_Location", "Distance"] ...
        )
        
        UITABLE_HEADER_TO_COLUMNS = dictionary( ...
            ["ID", "FREQUÊNCIA|(MHz)", "DESCRIÇÃO|(Entidade+Fistel+Multiplicidade+Localidade)", "FISTEL", "SERVIÇO", "ESTAÇÃO", "LARGURA|(kHz)", "DISTÂNCIA|(km)"], ...
            ["ID", "Frequency", "Description", "Fistel", "Service", "Station", "BW", "Distance"] ...
        )
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'auxApp.winRFDataHub.filter_Tree'
                        filter_delFilter(app, struct('Source', app.contextmenu_del))

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
                    case {'winAppAnalise', 'winAppAnalise_exported', ...
                          'winMonitorRNI', 'winMonitorRNI_exported'}
                        operationType = varargin{1};

                        switch operationType
                            case 'onRFDataHubUpdate'
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
                        app.referenceTX_Refresh;
                        app.referenceTX_EditionMode;
                        app.referenceTX_EditionConfirm;
                        app.referenceTX_EditionCancel;
                        app.stationInfo;
                        app.stationInfoImage;
                        app.tool_PanelVisibility;
                        app.tool_TableVisibility;
                        app.tool_RFLinkButton;
                        app.tool_PDFButton;
                        app.tool_ExportButton;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.stationInfo, appName);
                        ui.TextView.startup(app.jsBackDoor, app.stationInfoImage, appName, 'NÃO HÁ REGISTRO QUE ATENDA<br>AOS CRITÉRIOS DE FILTRAGEM');
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.referenceTX_Refresh.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna aos valores constantes em base')), ...
                            struct('appName', appName, 'dataTag', app.referenceTX_EditionMode.UserData.id,    'tooltip', struct('defaultPosition', 'top',    'textContent', 'Habilita ou desabilita edição de características da estação')), ...
                            struct('appName', appName, 'dataTag', app.referenceTX_EditionConfirm.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Confirma edição')), ...
                            struct('appName', appName, 'dataTag', app.referenceTX_EditionCancel.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Cancela edição')), ...
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

                case 2 % FILTRAGEM
                    elToModify = {
                        app.referenceRX_Refresh;
                        app.referenceRX_EditionMode;
                        app.referenceRX_EditionConfirm;
                        app.referenceRX_EditionCancel;
                        app.filter_Tree
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.referenceRX_Refresh.UserData.id,        'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna aos valores iniciais')), ...
                            struct('appName', appName, 'dataTag', app.referenceRX_EditionMode.UserData.id,    'tooltip', struct('defaultPosition', 'top',    'textContent', 'Habilita ou desabilita edição de características da estação')), ...
                            struct('appName', appName, 'dataTag', app.referenceRX_EditionConfirm.UserData.id, 'tooltip', struct('defaultPosition', 'top',    'textContent', 'Confirma edição')), ...
                            struct('appName', appName, 'dataTag', app.referenceRX_EditionCancel.UserData.id,  'tooltip', struct('defaultPosition', 'top',    'textContent', 'Cancela edição')), ...
                            struct('appName', appName, 'dataTag', app.filter_Tree.UserData.id, 'listener', struct('componentName', 'auxApp.winRFDataHub.filter_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end

                    buildFilterRuleTree(app)
                    
                case 3 % CONFIGURAÇÕES GERAIS
                    elToModify = {
                        app.config_Refresh;
                        app.config_ElevationForceSearch
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.config_Refresh.UserData.id,             'tooltip', struct('defaultPosition', 'top',    'textContent', 'Retorna aos valores iniciais')), ...
                            struct('appName', appName, 'dataTag', app.config_ElevationForceSearch.UserData.id, 'generation', 1, 'style', struct('textAlign', 'justify')) ...
                        });
                    catch
                    end

                    % Elevação:
                    app.config_ElevationAPISource.Value    = app.mainApp.General.elevation.provider;
                    app.config_ElevationNPoints.Value      = num2str(app.mainApp.General.elevation.pointCount);
                    app.config_ElevationForceSearch.Value  = app.mainApp.General.elevation.forceRefresh;
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            initializeRFDataHub(app)

            % refRX: armazena o valor inicial da estação receptora de referência
            %        para fins de análise da edição.
            rxSite = referenceRX_InitialValue(app);
            app.referenceRX_Refresh.UserData.InitialValue = rxSite;
            referenceRX_UpdatePanel(app, rxSite)

            referenceRX_CalculateDistance(app, rxSite)

            % lastPrimarySearch
            initializeFilterRules(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            % Controles de funcionalidades:
            app.referenceTX_EditionMode.UserData.status = false;
            app.referenceRX_EditionMode.UserData.status = false;
            
            app.tool_TableVisibility.UserData.layout    = 1;
            app.tool_RFLinkButton.UserData.status       = false;
            app.tool_PDFButton.UserData.status          = false;

            startup_AxesCreation(app)

            app.UITable.RowName = 'numbered';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            buildFilterRuleTree(app)
            applyFilterRulesToTable(app)
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
        function startup_AxesCreation(app)
            hParent     = tiledlayout(app.plotPanel, 2, 2, "Padding", "none", "TileSpacing", "none");

            % Eixo geográfico: MAPA
            app.UIAxes1 = plot.axes.Creation(hParent, 'Geographic', {'Basemap', app.config_Basemap.Value,                 ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '')});

            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [2, 2];

            set(app.UIAxes1.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
            set(app.UIAxes1.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
            geolimits(app.UIAxes1, 'auto')
            plot.axes.Colormap(app.UIAxes1, app.config_Colormap.Value)

            if ismember(app.config_Basemap.Value, {'darkwater', 'none'})
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
            app.UIAxes3 = polaraxes(app.stationInfoAntennaPattern, 'Units',             'normalized',      ...
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
        function [idxRFDataHub, idxSelectedRow] = getRFDataHubIndex(app)
            if isempty(app.UITable.Selection)
                idxRFDataHub   = [];
                idxSelectedRow = 0;
                
            else
                idxSelectedRow = app.UITable.Selection(1);
                idxVirtual     = app.UITable.Data.ID(idxSelectedRow);    
                idxRFDataHub   = str2double(extractAfter(idxVirtual, '#'));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = RFLinkObjects(app, siteType, varargin)
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

            if contains(siteType, 'TX')
                idxRFDataHub = varargin{1};

                % TX
                txSite = struct('Name',                 'TX',                                                 ...
                                'TransmitterFrequency', double(app.rfDataHub.Frequency(idxRFDataHub)) * 1e+6, ...
                                'Latitude',             app.referenceTX_Latitude.Value,                       ...
                                'Longitude',            app.referenceTX_Longitude.Value,                      ...
                                'AntennaHeight',        app.referenceTX_Height.Value,                         ...
                                'ID',                   app.rfDataHub.ID(idxRFDataHub),                       ...
                                'Station',              app.rfDataHub.Station(idxRFDataHub));
                varargout{end+1} = txSite;
            end

            if contains(siteType, 'RX')
                % RX
                rxSite = struct('Name',                 'RX',                            ...
                                'Latitude',             app.referenceRX_Latitude.Value,  ...
                                'Longitude',            app.referenceRX_Longitude.Value, ...
                                'AntennaHeight',        app.referenceRX_Height.Value);
                varargout{end+1} = rxSite;
            end
        end


        %-----------------------------------------------------------------%
        % TAB: 1
        % PAINEL: ESTAÇÃO TRANSMISSORA - TX
        %-----------------------------------------------------------------%
        function referenceTX_UpdatePanel(app, idxRFDataHub)
            idxAnnotation = referenceTX_AddOrDelTXSiteTempList(app, 'Search', app.rfDataHub.ID(idxRFDataHub));

            % A ideia aqui é destacar as informações que foram editadas...
            txLatitudeFontColor   = [0,0,0];
            txLongitudeFontColor  = [0,0,0];
            txHeightFontColor     = [0,0,0];

            txLatitudeBackground  = [1,1,1];
            txLongitudeBackground = [1,1,1];
            txHeightBackground    = [1,1,1];

            if idxAnnotation
                app.referenceTX_Refresh.Visible = 1;
                % Latitude
                if app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).Latitude.Status
                    txLatitude  = app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).Latitude.EditedValue;
                    txLatitudeFontColor   = [1,1,1];
                    txLatitudeBackground  = [1,0,0];
                else
                    txLatitude  = app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).Latitude.RawValue;
                end

                % Longitude
                if app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).Longitude.Status
                    txLongitude = app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).Longitude.EditedValue;
                    txLongitudeFontColor  = [1,1,1];
                    txLongitudeBackground = [1,0,0];
                else
                    txLongitude = app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).Longitude.RawValue;
                end

                % Height
                if app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).AntennaHeight.Status
                    txHeight    = app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).AntennaHeight.EditedValue;
                    txHeightFontColor     = [1,1,1];
                    txHeightBackground    = [1,0,0];
                else
                    txHeight    = app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation).AntennaHeight.RawValue;
                end

            else
                app.referenceTX_Refresh.Visible = 0;

                [txLatitude,  ...
                 txLongitude, ...
                 txHeight]  = referenceTX_getRawData(app);
            end

            set(app.referenceTX_Latitude,  'Value', txLatitude,  'FontColor', txLatitudeFontColor,  'BackgroundColor', txLatitudeBackground)
            set(app.referenceTX_Longitude, 'Value', txLongitude, 'FontColor', txLongitudeFontColor, 'BackgroundColor', txLongitudeBackground)
            set(app.referenceTX_Height,    'Value', txHeight,    'FontColor', txHeightFontColor,    'BackgroundColor', txHeightBackground)
        end

        %-----------------------------------------------------------------%
        function referenceTX_EditionPanelLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            idxRFDataHub = getRFDataHubIndex(app);
            hEditFields = findobj(app.referenceTX_Grid.Children, '-not', 'Type', 'uilabel');            

            switch editionStatus
                case 'on'
                    app.referenceTX_EditionMode.ImageSource = 'Edit_32Filled.png';
                    app.referenceTX_EditionMode.UserData.status = true;
                    set(hEditFields, 'Editable', true)
                    
                    app.referenceTX_TitleGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.referenceTX_EditionConfirm.Enable = 1;
                    app.referenceTX_EditionCancel.Enable  = 1;

                case 'off'
                    referenceTX_UpdatePanel(app, idxRFDataHub)

                    app.referenceTX_EditionMode.ImageSource = 'Edit_32.png';
                    app.referenceTX_EditionMode.UserData.status = false;
                    set(hEditFields, 'Editable', false)

                    app.referenceTX_TitleGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.referenceTX_EditionConfirm.Enable = 0;
                    app.referenceTX_EditionCancel.Enable  = 0;
            end
        end

        %-----------------------------------------------------------------%
        function varargout = referenceTX_AddOrDelTXSiteTempList(app, operationType, varargin)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'Search', 'Add', 'Del'})}
            end

            arguments (Repeating)
                varargin
            end

            switch operationType
                case 'Search'
                    ID = varargin{1};
                    [~, idxAnnotation] = ismember(ID, app.mainApp.rfDataHubAnnotation.ID);
                    varargout = {idxAnnotation};

                case 'Add'
                    [txObj, ID, Station, idxAnnotation] = referenceTX_checkTXSiteTempList(app);

                    [txLatitude,  ...
                     txLongitude, ...
                     txHeight]  = referenceTX_getRawData(app);

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
                        if idxAnnotation
                            if isequal(app.mainApp.rfDataHubAnnotation.TXSite(idxAnnotation), txSiteDiff)
                                return
                            end
                        else
                            idxAnnotation = height(app.mainApp.rfDataHubAnnotation) + 1;
                        end

                        app.mainApp.rfDataHubAnnotation(idxAnnotation, :) = {ID, Station, txSiteDiff};
                        layout_AddNewTableStyle(app, 'EditedRows')
                        
                        % Força a atualização do painel HTML e dos plots...
                        app.stationInfo.UserData.idxRFDataHub = [];
                        UITableSelectionChanged(app)
                    else
                        % Não evidenciada alteração no registro. Apaga-se linha,
                        % caso existente. O usuário, aqui, desfez alteração
                        % manualmente (sem pressionar no Refresh).
                        if idxAnnotation
                            app.mainApp.rfDataHubAnnotation(idxAnnotation, :) = [];
                            layout_AddNewTableStyle(app, 'EditedRows')

                            app.stationInfo.UserData.idxRFDataHub = [];
                            UITableSelectionChanged(app)
                        end
                    end

                case 'Del'
                    [~, ~, ~, idxAnnotation] = referenceTX_checkTXSiteTempList(app);
                    if idxAnnotation
                        app.mainApp.rfDataHubAnnotation(idxAnnotation, :) = [];
                        layout_AddNewTableStyle(app, 'EditedRows')

                        app.stationInfo.UserData.idxRFDataHub = [];
                        UITableSelectionChanged(app)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function [txObj, ID, Station, idxAnnotation] = referenceTX_checkTXSiteTempList(app)
            idxRFDataHub = getRFDataHubIndex(app);

            % Objeto.
            txObj   = RFLinkObjects(app, 'TX', idxRFDataHub);
            ID      = txObj.ID;
            Station = txObj.Station;

            % Consulta se esse objeto está na lista temporária de estações
            % editadas do RFDataHub.
            [~, idxAnnotation] = ismember(ID, app.mainApp.rfDataHubAnnotation.ID);
        end

        %-----------------------------------------------------------------%
        function [txLatitude, txLongitude, txHeight] = referenceTX_getRawData(app)
            idxRFDataHub = getRFDataHubIndex(app);

            txLatitude   = round(double(app.rfDataHub.Latitude(idxRFDataHub)),  6);
            txLongitude  = round(double(app.rfDataHub.Longitude(idxRFDataHub)), 6);
            txHeight     = round(str2double(char(app.rfDataHub.AntennaHeight(idxRFDataHub))), 1);
            if txHeight < 0
                txHeight = app.mainApp.General.context.RFDATAHUB.tx.defaultHeight;
            end
        end


        %-----------------------------------------------------------------%
        % TAB: 2
        % PAINEL: ESTAÇÃO RECEPTORA - RX
        %-----------------------------------------------------------------%
        function  rxSite = referenceRX_InitialValue(app)
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
        function referenceRX_UpdatePanel(app, rxSite)
            app.referenceRX_Latitude.Value  = rxSite.Latitude;
            app.referenceRX_Longitude.Value = rxSite.Longitude;
            app.referenceRX_Height.Value    = rxSite.AntennaHeight;
        end

        %-----------------------------------------------------------------%
        function referenceRX_CalculateDistance(app, rxSite)
            app.rfDataHub.Distance = round(single(deg2km(distance(app.rfDataHub.Latitude,  ...
                                                                  app.rfDataHub.Longitude, ...
                                                                  rxSite.Latitude,         ...
                                                                  rxSite.Longitude))), 1);
            app.referenceRX_Refresh.UserData.DistanceColumnSource = rxSite;
        end

        %-----------------------------------------------------------------%
        function referenceRX_EditOrRefreshReferenceRX(app, operationType)
            arguments
                app 
                operationType char {mustBeMember(operationType, {'Refresh', 'Edit'})}
            end

            refInitialValue         = app.referenceRX_Refresh.UserData.InitialValue;
            refDistanceColumnSource = app.referenceRX_Refresh.UserData.DistanceColumnSource;

            switch operationType
                case 'Refresh'
                    rxSite = refInitialValue;
                    referenceRX_UpdatePanel(app, rxSite)

                case 'Edit'
                    rxSite = RFLinkObjects(app, 'RX');
            end
            
            set([app.referenceRX_Latitude, app.referenceRX_Longitude, app.referenceRX_Height], 'BackGroundColor', [1,1,1], 'FontColor', [0,0,0])

            if ~isequal(rxSite, refInitialValue)
                app.referenceRX_Refresh.Visible = 1;
                
                if ~isequal(rxSite.Latitude, refInitialValue.Latitude)
                    set(app.referenceRX_Latitude, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end

                if ~isequal(rxSite.Longitude, refInitialValue.Longitude)
                    set(app.referenceRX_Longitude, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end

                if ~isequal(rxSite.AntennaHeight, refInitialValue.AntennaHeight)
                    set(app.referenceRX_Height, 'BackGroundColor', [1,0,0], 'FontColor', [1,1,1])
                end
            else
                app.referenceRX_Refresh.Visible = 0;
            end

            % Recalcula a coluna "Distance" caso a alteração tenha 
            % ocorrido em "Latitude" ou "Longitude".            
            if ~isequal(rmfield(refDistanceColumnSource, 'AntennaHeight'), rmfield(rxSite, 'AntennaHeight'))
                referenceRX_RefreshTableAndPlots(app, rxSite)

            elseif ~isequal(refDistanceColumnSource.AntennaHeight, rxSite.AntennaHeight)
                app.referenceRX_Refresh.UserData.DistanceColumnSource.AntennaHeight = rxSite.AntennaHeight;
                app.stationInfo.UserData.idxRFDataHub = [];
                UITableSelectionChanged(app)
            end
        end

        %-----------------------------------------------------------------%
        function referenceRX_EditionPanelLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            hEditFields = findobj(app.referenceRX_Grid.Children, '-not', 'Type', 'uilabel');

            switch editionStatus
                case 'on' 
                    app.referenceRX_EditionMode.ImageSource = 'Edit_32Filled.png';
                    app.referenceRX_EditionMode.UserData.status = true;
                    set(hEditFields, 'Editable', true)
                    
                    app.referenceRX_TitleGrid.ColumnWidth(5:6) = {18, 18};
                    app.referenceRX_EditionConfirm.Enable = 1;
                    app.referenceRX_EditionCancel.Enable  = 1;

                case 'off'
                    app.referenceRX_EditionMode.ImageSource = 'Edit_32.png';
                    app.referenceRX_EditionMode.UserData.status = false;
                    set(hEditFields, 'Editable', false)

                    app.referenceRX_TitleGrid.ColumnWidth(5:6) = {0, 0};
                    app.referenceRX_EditionConfirm.Enable = 0;
                    app.referenceRX_EditionCancel.Enable  = 0;
            end
        end

        %-----------------------------------------------------------------%
        function referenceRX_RefreshTableAndPlots(app, rxSite)
            referenceRX_CalculateDistance(app, rxSite)
            applyFilterRulesToTable(app)
        end


        %-----------------------------------------------------------------%
        % FILTRAGEM
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

            buildFilterRuleTree(app)
            applyFilterRulesToTable(app)
            syncRFDATAHUBStateToConfig(app, 'filter')
        end

        %-----------------------------------------------------------------%
        function syncRFDATAHUBStateToConfig(app, updateType)
            arguments
                app
                updateType {mustBeMember(updateType, {'rx', 'filter'})}
            end

            switch updateType
                case 'rx'
                    configRx  = app.mainApp.General.context.RFDATAHUB.rx.last;
                    currentRx = struct( ...
                        'latitude',  round(app.referenceRX_Latitude.Value,  6), ...
                        'longitude', round(app.referenceRX_Longitude.Value, 6), ...
                        'height',    round(app.referenceRX_Height.Value,    1)  ...
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

        %-----------------------------------------------------------------%
        function buildFilterRuleTree(app)
            if ~isempty(app.filter_Tree.Children)
                delete(app.filter_Tree.Children)
            end

            idx1 = find(strcmp(app.FilterRules.Order, 'Node'))';
            if ~isempty(idx1)
                checkedNodes = [];
                for ii = idx1
                    idx2 = find(app.FilterRules.RelatedID == app.FilterRules.ID(ii))';
                    if isempty(idx2)
                        parentNode = uitreenode(app.filter_Tree, 'Text', sprintf('#%d: RFDataHub.("%s") %s %s', app.FilterRules.ID(ii),                        ...
                                                                                                                app.FilterRules.Type{ii},                      ...
                                                                                                                app.FilterRules.Operation{ii},                 ...
                                                                                                                filter_Value(app, app.FilterRules.Value{ii})), ...
                                                                 'NodeData', ii, 'ContextMenu', app.ContextMenu);
                        if app.FilterRules.Enable(ii)
                            checkedNodes = [checkedNodes, parentNode];
                        end

                    else
                        parentNode = uitreenode(app.filter_Tree, 'Text', '*.*', ...
                                                                 'NodeData', [ii, idx2], 'ContextMenu', app.ContextMenu);
                        for jj = [ii, idx2]
                            childNode = uitreenode(parentNode, 'Text', sprintf('#%d: RFDataHub.("%s") %s %s', app.FilterRules.ID(jj),                        ...
                                                                                                              app.FilterRules.Type{jj},                      ...
                                                                                                              app.FilterRules.Operation{jj},                 ...
                                                                                                              filter_Value(app, app.FilterRules.Value{jj})), ...
                                                               'NodeData', jj, 'ContextMenu', app.ContextMenu);
        
                            if app.FilterRules.Enable(jj)
                                checkedNodes = [checkedNodes, childNode];
                            end
                        end
                    end
                end
                app.filter_Tree.CheckedNodes = checkedNodes;
                expand(app.filter_Tree, 'all')
            end

            app.filter_SecondaryReferenceFilter.Items = [{''}, cellstr("#" + string((idx1)))];
        end

        %-----------------------------------------------------------------%
        function applyFilterRulesToTable(app)
            app.progressDialog.Visible = 'visible';

            % Identifica registro inicialmente selecionado da tabela.
            initialSelectedRow = "";
            if ~isempty(app.UITable.Selection)
                initialSelectedRow = app.UITable.Data.ID(app.UITable.Selection(1));
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
                    addlistener(hROI, 'MovingROI',   @app.onROIChanged);
                    addlistener(hROI, 'ROIMoved',    @app.onROIChanged);
                    addlistener(hROI, 'DeletingROI', @app.onROIChanged);
                    addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));

                    app.FilterRules.Handle{ii} = hROI;                    
                end
            end

            % Filtragem, preenchendo a tabela e o seu label (nº de linhas).
            rfDataHubIdxs = find(util.TableFiltering(app.rfDataHub, app.FilterRules));
            columnNames   = cellstr(values(app.UITABLE_HEADER_TO_COLUMNS)');
            [rfDataHubFiltered, sortedIdxs] = sortrows(app.rfDataHub(rfDataHubIdxs, columnNames), 'Distance');

            set(app.UITable, 'Selection', [], 'Data', rfDataHubFiltered, 'UserData', rfDataHubIdxs(sortedIdxs))

            NN = numel(rfDataHubIdxs);
            MM = height(app.rfDataHub);
            app.tool_tableNRows.Text = sprintf('%d de %d registros\n%.1f %%', NN, MM, (NN/MM)*100);

            % Aplicando a seleção inicial da tabela, caso aplicável.
            selectedRow = 0;
            if ~isempty(app.UITable.Data)
                if initialSelectedRow.strlength
                    [~, selectedRow] = ismember(initialSelectedRow, app.UITable.Data.ID);
                end

                if ~selectedRow
                    selectedRow = 1;
                end

                app.UITable.Selection = [selectedRow, 1];
                scroll(app.UITable, 'Row', selectedRow)
            end

            layout_AddNewTableStyle(app, 'EditedRows')
            
            % Plots.
            if isempty(app.UIAxes1.Legend)
                legend(app.UIAxes1, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 4, 'LineWidth', .5, 'FontSize', 7.5)
            end

            plot_Stations(app)
            plot_RX(app)
            UITableSelectionChanged(app, struct('Source', app.UITable))
            
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
        % PLOT
        %-----------------------------------------------------------------%
        function plot_Stations(app)
            delete(findobj(app.UIAxes1.Children, '-not', {'Tag', 'FilterROI', '-or', 'Tag', 'TX'}))
            app.stationInfo.UserData.idxRFDataHub = [];

            if ~isempty(app.UITable.Data)
                geolimits(app.UIAxes1, 'auto')

                idxRFDataHubArray = app.UITable.UserData;
                latitudeArray     = app.rfDataHub.Latitude(idxRFDataHubArray);
                longitudeArray    = app.rfDataHub.Longitude(idxRFDataHubArray);

                hStations = geoscatter(app.UIAxes1, latitudeArray, longitudeArray, ...
                    'MarkerEdgeColor', app.config_Station_Color.Value,             ...
                    'SizeData',        app.config_Station_Size.Value,              ...
                    'DisplayName',     'RFDataHub',                                ...
                    'Tag',             'Stations');
                plot.datatip.Template(hStations, 'winRFDataHub.Geographic', app.UITable.Data)
            end
        end

        %-----------------------------------------------------------------%
        function plot_RX(app)
            RX = struct('Latitude',  app.referenceRX_Latitude.Value, ...
                        'Longitude', app.referenceRX_Longitude.Value);

            hRX = geoscatter(app.UIAxes1, RX.Latitude, RX.Longitude, ...
                'Marker',          '^',                              ...
                'MarkerEdgeColor', app.config_RX_Color.Value,        ...
                'MarkerFaceColor', app.config_RX_Color.Value,        ...
                'SizeData',        44*app.config_RX_Size.Value,      ...
                'DisplayName',     'RX',                             ...
                'Tag',             'RX');
            plot.datatip.Template(hRX, 'Coordinates')
        end

        %-----------------------------------------------------------------%
        function plot_TX(app, idxRFDataHub, idxSelectedRow)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))

            if ~isempty(idxRFDataHub)
                txObj = RFLinkObjects(app, 'TX', idxRFDataHub);

                % Scatter
                hTXScatter = findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX');
                if isempty(hTXScatter)
                    hTX = geoscatter(app.UIAxes1, txObj.Latitude, txObj.Longitude, ...
                        'LineWidth',       2,                                      ...
                        'Marker',          'o',                                    ...
                        'MarkerEdgeColor', app.config_TX_Color.Value,              ...
                        'MarkerFaceColor', app.config_TX_Color.Value,              ...
                        'SizeData',        20*app.config_TX_Size.Value ,           ...
                        'PickableParts',   'none',                                 ...
                        'DisplayName',     'TX',                                   ...
                        'Tag',             'TX');
                    plot.datatip.Template(hTX, 'Coordinates')
                else
                    set(hTXScatter, 'LatitudeData',  txObj.Latitude, ...
                                    'LongitudeData', txObj.Longitude)
                end

                % DataTip
                if strcmp(app.config_TX_DataTipVisibility.Value, 'on')
                    hTXDataTip = findobj(app.UIAxes1.Children, 'Type', 'datatip', 'Tag', 'TX');
                    if isempty(hTXDataTip)
                        hStations = findobj(app.UIAxes1.Children, 'Tag', 'Stations');
                        datatip(hStations,                   ...
                            'DataIndex',     idxSelectedRow, ...
                            'PickableParts', 'none',         ...
                            'Tag',           'TX');
                    else
                        hTXDataTip.DataIndex = idxSelectedRow;
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function plot_createRFLinkPlot(app)
            delete(findobj(app.UIAxes1.Children, 'Tag', 'RFLink'))
            cla(app.UIAxes2)
            delete(findobj(app.UIAxes3.Children, 'Tag', 'Azimuth'))

            if app.tool_RFLinkButton.UserData.status && ~isempty(app.UITable.Selection)
                idxRFDataHub = getRFDataHubIndex(app);

                app.progressDialog.Visible = 'visible';

                try
                    % OBJETOS TX e RX
                    [txObj, rxObj] = RFLinkObjects(app, 'TX-RX', idxRFDataHub);
        
                    % ELEVAÇÃO DO LINK TX-RX
                    [wayPoints3D, msgWarning] = Get(app.elevationObj, txObj, rxObj, str2double(app.config_ElevationNPoints.Value), app.config_ElevationForceSearch.Value, app.config_ElevationAPISource.Value);
                    if ~isempty(msgWarning)
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                    end
        
                    % PLOT: RFLink Map
                    geoplot(app.UIAxes1, wayPoints3D(:,1), wayPoints3D(:,2), Color='#c94756', LineStyle='-.', PickableParts='none', DisplayName='Enlace', Tag='RFLink');
                    
                    % PLOT: RFLink
                    plot.RFLink(app.UIAxes2, txObj, rxObj, wayPoints3D, 'light', true, true)
    
                    % PLOT: RFLink Azimuth
                    Azimuth = deg2rad(app.UIAxes2.UserData.Azimuth);
                    polarplot(app.UIAxes3, Azimuth,            app.UIAxes3.RLim(1), 'MarkerEdgeColor', '#c94756', 'MarkerFaceColor', '#c94756', 'Marker', 'o', 'PickableParts', 'none', 'Tag', 'Azimuth');
                    polarplot(app.UIAxes3, Azimuth,            app.UIAxes3.RLim(2), 'MarkerEdgeColor', '#c94756', 'MarkerFaceColor', '#c94756', 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Azimuth');
                    polarplot(app.UIAxes3, [Azimuth, Azimuth], app.UIAxes3.RLim,              'Color', '#c94756', 'LineStyle', '-.',                           'PickableParts', 'none', 'Tag', 'Azimuth');
                    
                catch
                end

                app.progressDialog.Visible = 'hidden';
            end

            plot_PolarAxesVisibility(app)
        end

        %-----------------------------------------------------------------%
        function plot_PolarAxesVisibility(app)
            % Visibilidade do eixo polar, com diagrama de radiação da
            % antena e azimute do enlace, caso aplicáveis.
            app.stationInfoAntennaPattern.Visible = ~isempty(app.UIAxes3.Children);
        end

        %-----------------------------------------------------------------%
        function misc_getChannelReport(app, operationType)
            arguments
                app
                operationType char {mustBeMember(operationType, {'OnlyCache', 'Cache+RealTime', 'RealTime'})}
            end

            if app.tool_PDFButton.UserData.status && ~isempty(app.UITable.Selection)
                idxRFDataHub = getRFDataHubIndex(app);

                URL = char(app.rfDataHub.URL(idxRFDataHub));
                if strcmp(URL, '-1')
                    layout_restartChannelReport(app)
                    return
                end

                % Caso a URL seja válida, cria-se objeto ChannelReport, caso
                % não existente.            
                if isempty(app.ChannelReportObj)
                    app.ChannelReportObj = RF.ChannelReport;
                end
    
                % A operação poderá ser demorada caso seja do tipo "Cache+RealTime" 
                % ou "RealTime". 
                if ismember(operationType, {'Cache+RealTime', 'RealTime'})
                    app.progressDialog.Visible = 'visible';
                end
    
                [idxCache, msgError] = Get(app.ChannelReportObj, URL, operationType);
                if ~isempty(idxCache)    
                    app.chReportHTML.HTMLSource     = app.ChannelReportObj.cacheMapping.File{idxCache};
                    app.chReportDownloadTime.Text   = sprintf('DOWNLOAD EM %s', app.ChannelReportObj.cacheMapping.Timestamp{idxCache});
                    app.chReportHotDownload.Visible = 1;
                    app.chReportUndock.Visible      = 1;
    
                else
                    layout_restartChannelReport(app)
    
                    if ismember(operationType, {'Cache+RealTime', 'RealTime'}) && ~isempty(msgError)
                        ui.Dialog(app.UIFigure, 'error', msgError);
                    end
                end
    
                if strcmp(app.progressDialog.Visible, 'visible')
                    app.progressDialog.Visible = 'hidden';
                end

            else
                layout_restartChannelReport(app)
            end
        end

        %-----------------------------------------------------------------%
        function layout_restartChannelReport(app)
            app.chReportHTML.HTMLSource     = 'Warning2.html';
            app.chReportDownloadTime.Text   = '';
            app.chReportHotDownload.Visible = 0;
            app.chReportUndock.Visible      = 0;
        end

        %-----------------------------------------------------------------%
        function layout_AddNewTableStyle(app, operationType, varargin)
            arguments
                app
                operationType char {mustBeMember(operationType, {'EditedRows', 'RowSelectionChanged'})}
            end

            arguments (Repeating)
                varargin
            end

            switch operationType
                case 'EditedRows'
                    styleType = "cell";
                    layout_RemoveOldTableStyle(app, styleType)

                    idxRows = find(contains(app.UITable.Data.ID, app.mainApp.rfDataHubAnnotation.ID));
                    if ~isempty(idxRows)
                        listOfCells = [idxRows, 2*ones(numel(idxRows), 1)];
                        addStyle(app.UITable, app.ANNOTATION_STYLE, styleType, listOfCells)
                    end

                case 'RowSelectionChanged'
                    styleType = "row";
                    layout_RemoveOldTableStyle(app, styleType)

                    idxSelectedRow = varargin{1};
                    if idxSelectedRow
                        addStyle(app.UITable, uistyle('BackgroundColor', '#d8ebfa'), styleType, idxSelectedRow)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function layout_RemoveOldTableStyle(app, styleType)
            idxStyle = find(app.UITable.StyleConfigurations.Target == styleType);
            if ~isempty(idxStyle)
                removeStyle(app.UITable, idxStyle)
            end
        end

        %-----------------------------------------------------------------%
        function layout_FilterOperationPanel(app, filterType, filterDefault)            
            layout_FilterDefaultValues(app)
            filter_SecondaryReferenceFilterValueChanged(app)

            hComp = findobj(app.filter_SecondaryValuePanel, 'Type', 'uitogglebutton');
            hCompTagFlag = contains(arrayfun(@(x) x.Tag, hComp, 'UniformOutput', false), filterType);

            set(hComp(hCompTagFlag),  Enable=1)
            set(hComp(~hCompTagFlag), Enable=0)

            selectedButton = app.filter_SecondaryValuePanel.SelectedObject;
            if ~selectedButton.Enable
                switch filterType
                    case {'textList1', 'ROI'}
                        app.filter_SecondaryOperation3.Value = 1; % CONTÉM

                    case 'textList3'
                        app.filter_SecondaryOperation2.Value = 1; % DIFERENTE

                    otherwise
                        app.filter_SecondaryOperation1.Value = 1; % IGUAL
                end
            end

            switch filterType
                case 'numeric'
                    app.filter_SecondaryNumValue1.Visible    = 1;
                    app.filter_SecondaryNumSeparator.Visible = 1;
                    app.filter_SecondaryNumValue2.Visible    = 1;
                    app.filter_SecondaryTextFree.Visible     = 0;
                    app.filter_SecondaryTextList.Visible     = 0;

                case 'textFree'
                    app.filter_SecondaryNumValue1.Visible    = 0;
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
                    app.filter_SecondaryTextFree.Visible     = 1;
                    app.filter_SecondaryTextList.Visible     = 0;

                case {'textList1', 'textList2', 'ROI'}
                    app.filter_SecondaryNumValue1.Visible    = 0;
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
                    app.filter_SecondaryTextFree.Visible     = 0;
                    app.filter_SecondaryTextList.Visible     = 1;
                    app.filter_SecondaryTextList.Items       = filterDefault;

                case 'textList3'
                    app.filter_SecondaryNumValue1.Visible    = 0;
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
                    app.filter_SecondaryTextFree.Visible     = 0;
                    app.filter_SecondaryTextList.Visible     = 1;
                    app.filter_SecondaryTextList.Items       = filterDefault;
            end
        end

        %-----------------------------------------------------------------%
        function layout_FilterDefaultValues(app)
            app.filter_SecondaryNumValue1.Value       = -1;
            app.filter_SecondaryNumValue2.Value       = -1;
            app.filter_SecondaryTextFree.Value        = '';
            app.filter_SecondaryTextList.Items        = {};
            app.filter_SecondaryLogicalOperator.Items = {'E (&&)'};
        end

        %-----------------------------------------------------------------%
        function filterValue = filter_Value(app, filterValue)
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

        %-----------------------------------------------------------------%
        function onROIChanged(app, src, event)
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
                    
                    buildFilterRuleTree(app)
                    applyFilterRulesToTable(app)
                    syncRFDATAHUBStateToConfig(app, 'filter')

                    if isvalid(event.Source)
                        uistack(event.Source, 'top')
                    end

                case 'DeletingROI'
                    filterIdx = find(cellfun(@(x) isequal(src, x), app.FilterRules.Handle), 1);
                    removeFilterRule(app, filterIdx)
            end            
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

        % Image clicked function: dockModule_Close, dockModule_Undock
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

        % Selection change function: SubTabGroup
        function SubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

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
                        
                        app.UIAxes1.Layout.TileSpan = [1,2];
                        set(findobj(app.UIAxes2), 'Visible', 1)
                    else
                        app.UIAxes1.Layout.TileSpan = [2,2];
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

        % Image clicked function: axesTool_RegionZoom, axesTool_RestoreView
        function AxesToolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.axesTool_RestoreView
                    geolimits(app.UIAxes1, app.restoreView(1).xLim, app.restoreView(1).yLim)

                case app.axesTool_RegionZoom
                    plot.axes.Interactivity.GeographicRegionZoomInteraction(app.UIAxes1, app.axesTool_RegionZoom)
            end

        end

        % Image clicked function: chReportHotDownload, chReportUndock
        function PDFToolbar_ReportImageClicked(app, event)
            
            if strcmp(app.chReportHTML.HTMLSource, 'Warning2.html')
                return
            end

            switch event.Source
                case app.chReportHotDownload
                    misc_getChannelReport(app, 'RealTime')

                case app.chReportUndock
                    switch app.mainApp.executionMode
                        case 'webApp'
                            idxRFDataHub = getRFDataHubIndex(app);
                            URL = char(app.rfDataHub.URL(idxRFDataHub));
                            web(URL, '-new')
                        otherwise
                            appEngine.util.OperationSystem('openFile', app.chReportHTML.HTMLSource)
                    end                    
                    Toolbar_InteractionImageClicked(app, struct('Source', app.tool_PDFButton))
            end

        end

        % Selection changed function: UITable
        function UITableSelectionChanged(app, event)
            
            [idxRFDataHub, idxSelectedRow] = getRFDataHubIndex(app);

            % Caso nenhum registro atenda aos critérios de filtragem,
            % reinicializa a área de visualização do app.
            if isempty(idxRFDataHub)
                % Painel:
                app.referenceTX_Refresh.Visible     = 0;
                app.referenceTX_EditionMode.Visible = 0;
                app.referenceTX_Latitude.Value      = -1;
                app.referenceTX_Longitude.Value     = -1;
                app.referenceTX_Height.Value        = 0;

                ui.TextView.update(app.stationInfo, '');
                app.stationInfoImage.Visible = 'on';

                % Área de plot/PDF:
                delete(findobj(app.UIAxes1.Children, 'Tag', 'TX'))
                cla(app.UIAxes2)
                cla(app.UIAxes3)

                plot_PolarAxesVisibility(app)
                layout_restartChannelReport(app)
                return

            % Caso a alteração na seleção da tabela seja restrita à coluna,
            % por exemplo, mantendo-se selecionada a mesma linha, não será 
            % realizado um novo plot.
            elseif isequal(app.stationInfo.UserData.idxRFDataHub, idxRFDataHub)
                return
            end

            app.stationInfo.UserData.idxRFDataHub = idxRFDataHub;
            layout_AddNewTableStyle(app, 'RowSelectionChanged', idxSelectedRow)
            
            % Estação transmissora - TX
            if ~app.referenceTX_EditionMode.Visible
                app.referenceTX_EditionMode.Visible = 1;
            end

            referenceTX_UpdatePanel(app, idxRFDataHub)
            if app.referenceTX_EditionMode.UserData.status
                referenceTX_EditionModeImageClicked(app, struct('Source', app.referenceTX_EditionMode))
            end

            % Painel HTML
            ui.TextView.update(app.stationInfo, util.HtmlTextGenerator.Station(app.rfDataHub, idxRFDataHub, app.rfDataHubLOG, app.mainApp.General));
            app.stationInfoImage.Visible = 'off';

            % Painel PDF
            if app.rfDataHub.Source(idxRFDataHub) == "MOSAICO-SRD"
                misc_getChannelReport(app, 'Cache+RealTime')
            else
                layout_restartChannelReport(app)
            end
                
            % Plot "AntennaPattern"
            % O bloco try/catch protege possível erro no parser da informação
            % do Mosaico. Como exposto em model.RFDataHub.parsingAntennaPattern
            % foram identificados quatro formas de armazenar a informação.
            cla(app.UIAxes3)
            if app.rfDataHub.AntennaPattern(idxRFDataHub) ~= "-1"
                try
                    [angle, gain] = model.RFDataHub.parsingAntennaPattern(app.rfDataHub.AntennaPattern(idxRFDataHub), 360);
                    hAntennaPattern = polarplot(app.UIAxes3, angle, gain, 'Tag', 'AntennaPattern');
                    plot.datatip.Template(hAntennaPattern, "AntennaPattern")
                catch
                end
            end

            % Plot "TX"
            plot_TX(app, idxRFDataHub, idxSelectedRow)

            % Plot "RFLink"
            plot_createRFLinkPlot(app)
            
        end

        % Image clicked function: referenceTX_EditionCancel, 
        % ...and 3 other components
        function referenceTX_EditionModeImageClicked(app, event)
            
            switch event.Source
                case app.referenceTX_Refresh
                    referenceTX_AddOrDelTXSiteTempList(app, 'Del')
                    referenceTX_EditionPanelLayout(app, 'off')

                case app.referenceTX_EditionMode
                    app.referenceTX_EditionMode.UserData.status = ~app.referenceTX_EditionMode.UserData.status;
                    
                    if app.referenceTX_EditionMode.UserData.status
                        referenceTX_EditionPanelLayout(app, 'on')
                        focus(app.referenceTX_Latitude)
                    else
                        referenceTX_EditionModeImageClicked(app, struct('Source', app.referenceTX_EditionCancel))
                    end

                case app.referenceTX_EditionConfirm
                    referenceTX_AddOrDelTXSiteTempList(app, 'Add')
                    referenceTX_EditionPanelLayout(app, 'off')

                case app.referenceTX_EditionCancel
                    idxRFDataHub = getRFDataHubIndex(app);
                    referenceTX_UpdatePanel(app, idxRFDataHub)
                    referenceTX_EditionPanelLayout(app, 'off')
            end

        end

        % Image clicked function: referenceRX_EditionCancel, 
        % ...and 3 other components
        function referenceRX_EditionModeImageClicked(app, event)
            
            switch event.Source
                case app.referenceRX_Refresh
                    referenceRX_EditOrRefreshReferenceRX(app, 'Refresh')
                    referenceRX_EditionPanelLayout(app, 'off')
                    syncRFDATAHUBStateToConfig(app, 'rx')

                case app.referenceRX_EditionMode
                    app.referenceRX_EditionMode.UserData.status = ~app.referenceRX_EditionMode.UserData.status;

                    if app.referenceRX_EditionMode.UserData.status
                        referenceRX_EditionPanelLayout(app, 'on')
                        focus(app.referenceRX_Latitude)
                    else
                        referenceRX_EditionModeImageClicked(app, struct('Source', app.referenceRX_EditionCancel))
                    end

                case app.referenceRX_EditionConfirm
                    referenceRX_EditOrRefreshReferenceRX(app, 'Edit')
                    referenceRX_EditionPanelLayout(app, 'off')
                    syncRFDATAHUBStateToConfig(app, 'rx')

                case app.referenceRX_EditionCancel
                    rxSite = app.referenceRX_Refresh.UserData.DistanceColumnSource;
                    referenceRX_UpdatePanel(app, rxSite)
                    referenceRX_EditionPanelLayout(app, 'off')
            end        

        end

        % Selection changed function: filter_SecondaryTypePanel
        function filter_typePanelSelectionChanged(app, event)
                        
            selectedButton = app.filter_SecondaryTypePanel.SelectedObject;
            switch selectedButton
                case app.filter_SecondaryType1                              % BASE DE DADOS
                    filterType    = 'textList1';
                    filterDefault = app.rfDataHubSummary.Source.RawCategories;

                case {app.filter_SecondaryType2, ...                      % FREQUÊNCIA
                      app.filter_SecondaryType3, ...                      % LARGURA BANDA
                      app.filter_SecondaryType6, ...                      % FISTEL
                      app.filter_SecondaryType7, ...                      % SERVIÇO
                      app.filter_SecondaryType8, ...                      % ESTAÇÃO
                      app.filter_SecondaryType11}                         % DISTÂNCIA
                    filterType    = 'numeric';
                    filterDefault = {};

                case {app.filter_SecondaryType5, ...                      % ENTIDADE
                      app.filter_SecondaryType10}                         % MUNICÍPIO
                    filterType    = 'textFree';
                    filterDefault = {};

                case app.filter_SecondaryType9                            % UF
                    filterType    = 'textList2';
                    filterDefault = app.rfDataHubSummary.State.Categories;

                case app.filter_SecondaryType12                           % ROI
                    filterType    = 'ROI';
                    filterDefault = {'images.roi.Circle', 'images.roi.Rectangle', 'images.roi.Polygon'};

                case app.filter_SecondaryType13                           % Padrão de antena
                    filterType    = 'textList3';
                    filterDefault = {'-1'};
            end

            layout_FilterOperationPanel(app, filterType, filterDefault)
            filter_SecondaryValuePanelSelectionChanged(app)
            
        end

        % Selection changed function: filter_SecondaryValuePanel
        function filter_SecondaryValuePanelSelectionChanged(app, event)
            
            selectedButton = app.filter_SecondaryValuePanel.SelectedObject;
            switch selectedButton
                case {app.filter_SecondaryOperation9, app.filter_SecondaryOperation10}
                    app.filter_SecondaryNumSeparator.Visible = 1;
                    app.filter_SecondaryNumValue2.Visible    = 1;
                    
                otherwise
                    app.filter_SecondaryNumSeparator.Visible = 0;
                    app.filter_SecondaryNumValue2.Visible    = 0;
            end
            
        end

        % Value changed function: filter_SecondaryReferenceFilter
        function filter_SecondaryReferenceFilterValueChanged(app, event)
            
            value = app.filter_SecondaryReferenceFilter.Value;
            if isempty(value)
                app.filter_SecondaryLogicalOperator.Items = {'E (&&)'};
            else
                app.filter_SecondaryLogicalOperator.Items = {'OU (||)'};
            end
            
        end

        % Image clicked function: filter_AddImage
        function filter_addFilter(app, event)
            
            selectedRadioButtonFilterType = app.filter_SecondaryTypePanel.SelectedObject;
            selectedRadioButtonFilterOperation = app.filter_SecondaryValuePanel.SelectedObject;

            if isempty(app.filter_SecondaryReferenceFilter.Value)
                filterOrder = 'Node';
                relatedId   = -1;
            else
                filterOrder = 'Child';
                relatedId   = str2double(app.filter_SecondaryReferenceFilter.Value(2:end));
            end

            filterType = selectedRadioButtonFilterType.Text;
            filterOperation = selectedRadioButtonFilterOperation.Text;
            filterHandle = [];

            switch selectedRadioButtonFilterType
                case {app.filter_SecondaryType1, ...                        % BASE DE DADOS
                      app.filter_SecondaryType9, ...                        % UF
                      app.filter_SecondaryType13}                           % PADRÃO DA ANTENA
                    filterValue = app.filter_SecondaryTextList.Value;

                case {app.filter_SecondaryType2, ...                        % FREQUÊNCIA
                      app.filter_SecondaryType3, ...                        % LARGURA BANDA
                      app.filter_SecondaryType6, ...                        % FISTEL
                      app.filter_SecondaryType7, ...                        % SERVIÇO
                      app.filter_SecondaryType8, ...                        % ESTAÇÃO
                      app.filter_SecondaryType11}                           % DISTÂNCIA

                    if ismember(selectedRadioButtonFilterOperation.Text, {'<>', '><'})
                        filterValue = [ ...
                            app.filter_SecondaryNumValue1.Value, ...
                            app.filter_SecondaryNumValue2.Value ...
                        ];
                    else
                        filterValue = app.filter_SecondaryNumValue1.Value;
                    end

                case {app.filter_SecondaryType5, ...                        % ENTIDADE
                      app.filter_SecondaryType10}                           % MUNICÍPIO
                    filterValue = app.filter_SecondaryTextFree.Value;

                case app.filter_SecondaryType12                             % ROI
                    hROI = [];
                    
                    plot.axes.Interactivity.DefaultDisable(app.UIAxes1)
                    pause(.1)

                    filterType = app.filter_SecondaryTextList.Value;
                    switch filterType
                        case 'images.roi.Circle';    roiFcn = 'drawcircle';    roiNameArgument = '';
                        case 'images.roi.Rectangle'; roiFcn = 'drawrectangle'; roiNameArgument = 'Rotatable=1, ';
                        case 'images.roi.Polygon';   roiFcn = 'drawpolygon';   roiNameArgument = '';
                    end
                    eval(sprintf('hROI = %s(app.UIAxes1, Color=[0.40,0.73,0.88], LineWidth=1, Deletable=1, FaceSelectable=0, %sTag="FilterROI");', roiFcn, roiNameArgument))
                    plot.axes.Interactivity.DefaultEnable(app.UIAxes1)

                    if isempty(hROI.Position)
                        delete(hROI)
                        return
                    end
                    addlistener(hROI, 'MovingROI',   @app.onROIChanged);
                    addlistener(hROI, 'ROIMoved',    @app.onROIChanged);
                    addlistener(hROI, 'DeletingROI', @app.onROIChanged);
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

            buildFilterRuleTree(app)
            applyFilterRulesToTable(app)
            syncRFDATAHUBStateToConfig(app, 'filter')

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

        % Callback function: filter_Tree
        function filter_TreeCheckedNodesChanged(app, event)
            
            hTree             = findobj(app.filter_Tree, '-not', 'Type', 'uicheckboxtree');
            
            hTreeNode         = arrayfun(@(x) x.NodeData, hTree, 'UniformOutput', false);
            hTreeNodeDataList = unique(horzcat(hTreeNode{:}));

            hCheckedNode      = arrayfun(@(x) x.NodeData, app.filter_Tree.CheckedNodes, 'UniformOutput', false);
            hCheckedNodeData  = unique(horzcat(hCheckedNode{:}));

            disableIndexList  = setdiff(hTreeNodeDataList, hCheckedNodeData);
            enableIndexList   = setdiff((1:height(app.FilterRules))', disableIndexList);

            app.FilterRules.Enable(disableIndexList) = false;
            app.FilterRules.Enable(enableIndexList)  = true;

            applyFilterRulesToTable(app)
            
        end

        % Callback function: config_RX_Color, config_Station_Color, 
        % ...and 1 other component
        function config_geoAxesColorParameterChanged(app, event)
            
            selectedColor = event.Source.Value;

            switch event.Source
                case app.config_Station_Color
                    set(findobj(app.UIAxes1.Children, 'Tag', 'Stations'), 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.config_TX_Color
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX'), 'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)

                case app.config_RX_Color
                    set(findobj(app.UIAxes1.Children, 'Tag', 'RX'),  'MarkerFaceColor', selectedColor, 'MarkerEdgeColor', selectedColor)
            end

        end

        % Callback function: config_Basemap, config_Colormap, 
        % ...and 4 other components
        function config_geoAxesOthersParametersChanged(app, event)
            
            switch event.Source
                case app.config_Basemap
                    app.UIAxes1.Basemap = app.config_Basemap.Value;
                    switch app.config_Basemap.Value
                        case {'darkwater', 'none'}
                            app.UIAxes1.Grid = 'on';
                        otherwise
                            app.UIAxes1.Grid = 'off';
                    end
                    return

                case app.config_Colormap
                    if strcmp(app.UIAxes1.UserData.Colormap, event.Value)
                        return
                    end

                    plot.axes.Colormap(app.UIAxes1, event.Value)

                case app.config_TX_DataTipVisibility
                    switch app.config_TX_DataTipVisibility.Value
                        case 'on'
                            [idxRFDataHub, idxSelectedRow] = getRFDataHubIndex(app);
                            plot_TX(app, idxRFDataHub, idxSelectedRow)
                            plot.axes.StackingOrder.execute(app.UIAxes1, 'RFDataHub')
                            
                        case 'off'
                            hDataTip = findobj(app.UIAxes1.Children, 'Type', 'datatip', 'Tag', 'TX');
                            delete(hDataTip)
                    end

                case app.config_Station_Size
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'Stations'), 'SizeData', event.Value)

                case app.config_TX_Size
                    set(findobj(app.UIAxes1.Children, 'Type', 'scatter', 'Tag', 'TX'),       'SizeData', 20*event.Value)

                case app.config_RX_Size
                    set(findobj(app.UIAxes1.Children,                    'Tag', 'RX'),       'SizeData', 44*event.Value)
            end

        end

        % Image clicked function: config_Refresh
        function config_Refreshconfig_RefreshClicked(app, event)
            
            % ToDo: Pendente finalizar a implementação dessa funcionalidade.
            % Não gostei de plotar novamente a coisa... preciso identificar
            % os parâmetros que foram alterados, chamando individualmente
            % os callbacks de cada parâmetro. O botão ficará invisível até 
            % ajuste desses pontos.

            app.config_ElevationAPISource.Value = app.mainApp.General.elevation.provider;
            app.config_ElevationNPoints.Value      = num2str(app.mainApp.General.elevation.pointCount);

            % % Eixo geográfico - app.UIAxes1
            app.config_Colormap.Value             = 'turbo';            
            app.config_Station_Color.Value        = [0 1 1];
            app.config_Station_Size.Value         = 1;
            app.config_TX_Color.Value             = [0.7882 0.2784 0.3412];
            app.config_TX_Size.Value              = 1;
            app.config_TX_DataTipVisibility.Value = 'off';
            app.config_RX_Color.Value             = [0.7882 0.2784 0.3373];
            app.config_RX_Size.Value              = 1;
            
            % % Atualiza o plot...
            app.stationInfo.UserData.idxRFDataHub = [];
            applyFilterRulesToTable(app)            

            app.config_Refresh.Visible = 0;

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

            % Create tool_tableNRows
            app.tool_tableNRows = uilabel(app.Toolbar);
            app.tool_tableNRows.HorizontalAlignment = 'right';
            app.tool_tableNRows.FontSize = 10;
            app.tool_tableNRows.FontColor = [0.6 0.6 0.6];
            app.tool_tableNRows.Layout.Row = [1 3];
            app.tool_tableNRows.Layout.Column = 8;
            app.tool_tableNRows.Text = '';

            % Create tool_tableNRowsIcon
            app.tool_tableNRowsIcon = uiimage(app.Toolbar);
            app.tool_tableNRowsIcon.ScaleMethod = 'none';
            app.tool_tableNRowsIcon.Enable = 'off';
            app.tool_tableNRowsIcon.Layout.Row = [1 3];
            app.tool_tableNRowsIcon.Layout.Column = 9;
            app.tool_tableNRowsIcon.ImageSource = 'Filter_18.png';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @SubTabGroupSelectionChanged, true);
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

            % Create referenceTX_TitleGrid
            app.referenceTX_TitleGrid = uigridlayout(app.SubGrid1);
            app.referenceTX_TitleGrid.ColumnWidth = {22, '1x', 18, 18, 0, 0};
            app.referenceTX_TitleGrid.RowHeight = {18, 18};
            app.referenceTX_TitleGrid.ColumnSpacing = 5;
            app.referenceTX_TitleGrid.RowSpacing = 0;
            app.referenceTX_TitleGrid.Padding = [0 0 0 0];
            app.referenceTX_TitleGrid.Layout.Row = 1;
            app.referenceTX_TitleGrid.Layout.Column = [1 3];
            app.referenceTX_TitleGrid.BackgroundColor = [1 1 1];

            % Create referenceTX_Icon
            app.referenceTX_Icon = uiimage(app.referenceTX_TitleGrid);
            app.referenceTX_Icon.Layout.Row = [1 2];
            app.referenceTX_Icon.Layout.Column = 1;
            app.referenceTX_Icon.ImageSource = 'Pin_32.png';

            % Create referenceTX_Label
            app.referenceTX_Label = uilabel(app.referenceTX_TitleGrid);
            app.referenceTX_Label.VerticalAlignment = 'bottom';
            app.referenceTX_Label.FontSize = 11;
            app.referenceTX_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceTX_Label.Layout.Row = [1 2];
            app.referenceTX_Label.Layout.Column = 2;
            app.referenceTX_Label.Interpreter = 'html';
            app.referenceTX_Label.Text = {'<b>Estação transmissora - TX</b>'; '<font style="font-size: 9px; color: gray;">(Registro selecionado em tabela)</font>'};

            % Create referenceTX_Refresh
            app.referenceTX_Refresh = uiimage(app.referenceTX_TitleGrid);
            app.referenceTX_Refresh.ScaleMethod = 'none';
            app.referenceTX_Refresh.ImageClickedFcn = createCallbackFcn(app, @referenceTX_EditionModeImageClicked, true);
            app.referenceTX_Refresh.Visible = 'off';
            app.referenceTX_Refresh.Layout.Row = 2;
            app.referenceTX_Refresh.Layout.Column = 3;
            app.referenceTX_Refresh.ImageSource = 'Refresh_18.png';

            % Create referenceTX_EditionMode
            app.referenceTX_EditionMode = uiimage(app.referenceTX_TitleGrid);
            app.referenceTX_EditionMode.ImageClickedFcn = createCallbackFcn(app, @referenceTX_EditionModeImageClicked, true);
            app.referenceTX_EditionMode.Layout.Row = 2;
            app.referenceTX_EditionMode.Layout.Column = 4;
            app.referenceTX_EditionMode.ImageSource = 'Edit_32.png';

            % Create referenceTX_EditionConfirm
            app.referenceTX_EditionConfirm = uiimage(app.referenceTX_TitleGrid);
            app.referenceTX_EditionConfirm.ImageClickedFcn = createCallbackFcn(app, @referenceTX_EditionModeImageClicked, true);
            app.referenceTX_EditionConfirm.Enable = 'off';
            app.referenceTX_EditionConfirm.Layout.Row = 2;
            app.referenceTX_EditionConfirm.Layout.Column = 5;
            app.referenceTX_EditionConfirm.ImageSource = 'Ok_32Green.png';

            % Create referenceTX_EditionCancel
            app.referenceTX_EditionCancel = uiimage(app.referenceTX_TitleGrid);
            app.referenceTX_EditionCancel.ImageClickedFcn = createCallbackFcn(app, @referenceTX_EditionModeImageClicked, true);
            app.referenceTX_EditionCancel.Enable = 'off';
            app.referenceTX_EditionCancel.Layout.Row = 2;
            app.referenceTX_EditionCancel.Layout.Column = 6;
            app.referenceTX_EditionCancel.ImageSource = 'Delete_32Red.png';

            % Create referenceTX_Panel
            app.referenceTX_Panel = uipanel(app.SubGrid1);
            app.referenceTX_Panel.AutoResizeChildren = 'off';
            app.referenceTX_Panel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceTX_Panel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.referenceTX_Panel.Layout.Row = 2;
            app.referenceTX_Panel.Layout.Column = [1 3];

            % Create referenceTX_Grid
            app.referenceTX_Grid = uigridlayout(app.referenceTX_Panel);
            app.referenceTX_Grid.ColumnWidth = {85, 85, 85};
            app.referenceTX_Grid.RowHeight = {17, 22};
            app.referenceTX_Grid.RowSpacing = 5;
            app.referenceTX_Grid.Padding = [10 10 10 5];
            app.referenceTX_Grid.BackgroundColor = [1 1 1];

            % Create referenceTX_LatitudeLabel
            app.referenceTX_LatitudeLabel = uilabel(app.referenceTX_Grid);
            app.referenceTX_LatitudeLabel.VerticalAlignment = 'bottom';
            app.referenceTX_LatitudeLabel.FontSize = 10;
            app.referenceTX_LatitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceTX_LatitudeLabel.Layout.Row = 1;
            app.referenceTX_LatitudeLabel.Layout.Column = 1;
            app.referenceTX_LatitudeLabel.Text = 'Latitude:';

            % Create referenceTX_Latitude
            app.referenceTX_Latitude = uieditfield(app.referenceTX_Grid, 'numeric');
            app.referenceTX_Latitude.Limits = [-90 90];
            app.referenceTX_Latitude.ValueDisplayFormat = '%.6f';
            app.referenceTX_Latitude.Editable = 'off';
            app.referenceTX_Latitude.FontSize = 11;
            app.referenceTX_Latitude.Layout.Row = 2;
            app.referenceTX_Latitude.Layout.Column = 1;
            app.referenceTX_Latitude.Value = -1;

            % Create referenceTX_LongitudeLabel
            app.referenceTX_LongitudeLabel = uilabel(app.referenceTX_Grid);
            app.referenceTX_LongitudeLabel.VerticalAlignment = 'bottom';
            app.referenceTX_LongitudeLabel.FontSize = 10;
            app.referenceTX_LongitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceTX_LongitudeLabel.Layout.Row = 1;
            app.referenceTX_LongitudeLabel.Layout.Column = 2;
            app.referenceTX_LongitudeLabel.Text = 'Longitude:';

            % Create referenceTX_Longitude
            app.referenceTX_Longitude = uieditfield(app.referenceTX_Grid, 'numeric');
            app.referenceTX_Longitude.Limits = [-180 180];
            app.referenceTX_Longitude.ValueDisplayFormat = '%.6f';
            app.referenceTX_Longitude.Editable = 'off';
            app.referenceTX_Longitude.FontSize = 11;
            app.referenceTX_Longitude.Layout.Row = 2;
            app.referenceTX_Longitude.Layout.Column = 2;
            app.referenceTX_Longitude.Value = -1;

            % Create referenceTX_HeightLabel
            app.referenceTX_HeightLabel = uilabel(app.referenceTX_Grid);
            app.referenceTX_HeightLabel.VerticalAlignment = 'bottom';
            app.referenceTX_HeightLabel.FontSize = 10;
            app.referenceTX_HeightLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceTX_HeightLabel.Layout.Row = 1;
            app.referenceTX_HeightLabel.Layout.Column = 3;
            app.referenceTX_HeightLabel.Text = 'Altura (m):';

            % Create referenceTX_Height
            app.referenceTX_Height = uieditfield(app.referenceTX_Grid, 'numeric');
            app.referenceTX_Height.Limits = [0 Inf];
            app.referenceTX_Height.ValueDisplayFormat = '%.1f';
            app.referenceTX_Height.Editable = 'off';
            app.referenceTX_Height.FontSize = 11;
            app.referenceTX_Height.Layout.Row = 2;
            app.referenceTX_Height.Layout.Column = 3;

            % Create stationInfoImage
            app.stationInfoImage = uiimage(app.SubGrid1);
            app.stationInfoImage.ScaleMethod = 'none';
            app.stationInfoImage.Visible = 'off';
            app.stationInfoImage.Layout.Row = [3 5];
            app.stationInfoImage.Layout.Column = [1 3];
            app.stationInfoImage.ImageSource = 'warning.svg';

            % Create stationInfoAntennaPattern
            app.stationInfoAntennaPattern = uipanel(app.SubGrid1);
            app.stationInfoAntennaPattern.AutoResizeChildren = 'off';
            app.stationInfoAntennaPattern.BorderType = 'none';
            app.stationInfoAntennaPattern.BackgroundColor = [1 1 1];
            app.stationInfoAntennaPattern.Layout.Row = 4;
            app.stationInfoAntennaPattern.Layout.Column = 2;

            % Create stationInfo
            app.stationInfo = uilabel(app.SubGrid1);
            app.stationInfo.VerticalAlignment = 'top';
            app.stationInfo.WordWrap = 'on';
            app.stationInfo.FontSize = 11;
            app.stationInfo.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.stationInfo.Layout.Row = [3 5];
            app.stationInfo.Layout.Column = [1 3];
            app.stationInfo.Interpreter = 'html';
            app.stationInfo.Text = '';

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

            % Create referenceRX_Panel
            app.referenceRX_Panel = uipanel(app.SubGrid2);
            app.referenceRX_Panel.AutoResizeChildren = 'off';
            app.referenceRX_Panel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_Panel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.referenceRX_Panel.Layout.Row = 2;
            app.referenceRX_Panel.Layout.Column = [1 2];

            % Create referenceRX_Grid
            app.referenceRX_Grid = uigridlayout(app.referenceRX_Panel);
            app.referenceRX_Grid.ColumnWidth = {'1x', '1x', '1x'};
            app.referenceRX_Grid.RowHeight = {17, 22};
            app.referenceRX_Grid.RowSpacing = 5;
            app.referenceRX_Grid.Padding = [10 10 10 5];
            app.referenceRX_Grid.BackgroundColor = [1 1 1];

            % Create referenceRX_LatitudeLabel
            app.referenceRX_LatitudeLabel = uilabel(app.referenceRX_Grid);
            app.referenceRX_LatitudeLabel.VerticalAlignment = 'bottom';
            app.referenceRX_LatitudeLabel.FontSize = 10;
            app.referenceRX_LatitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_LatitudeLabel.Layout.Row = 1;
            app.referenceRX_LatitudeLabel.Layout.Column = 1;
            app.referenceRX_LatitudeLabel.Text = 'Latitude:';

            % Create referenceRX_Latitude
            app.referenceRX_Latitude = uieditfield(app.referenceRX_Grid, 'numeric');
            app.referenceRX_Latitude.Limits = [-90 90];
            app.referenceRX_Latitude.ValueDisplayFormat = '%.6f';
            app.referenceRX_Latitude.Editable = 'off';
            app.referenceRX_Latitude.FontSize = 11;
            app.referenceRX_Latitude.Layout.Row = 2;
            app.referenceRX_Latitude.Layout.Column = 1;
            app.referenceRX_Latitude.Value = -1;

            % Create referenceRX_LongitudeLabel
            app.referenceRX_LongitudeLabel = uilabel(app.referenceRX_Grid);
            app.referenceRX_LongitudeLabel.VerticalAlignment = 'bottom';
            app.referenceRX_LongitudeLabel.FontSize = 10;
            app.referenceRX_LongitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_LongitudeLabel.Layout.Row = 1;
            app.referenceRX_LongitudeLabel.Layout.Column = 2;
            app.referenceRX_LongitudeLabel.Text = 'Longitude:';

            % Create referenceRX_Longitude
            app.referenceRX_Longitude = uieditfield(app.referenceRX_Grid, 'numeric');
            app.referenceRX_Longitude.Limits = [-180 180];
            app.referenceRX_Longitude.ValueDisplayFormat = '%.6f';
            app.referenceRX_Longitude.Editable = 'off';
            app.referenceRX_Longitude.FontSize = 11;
            app.referenceRX_Longitude.Layout.Row = 2;
            app.referenceRX_Longitude.Layout.Column = 2;
            app.referenceRX_Longitude.Value = -1;

            % Create referenceRX_HeightLabel
            app.referenceRX_HeightLabel = uilabel(app.referenceRX_Grid);
            app.referenceRX_HeightLabel.VerticalAlignment = 'bottom';
            app.referenceRX_HeightLabel.FontSize = 10;
            app.referenceRX_HeightLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_HeightLabel.Layout.Row = 1;
            app.referenceRX_HeightLabel.Layout.Column = 3;
            app.referenceRX_HeightLabel.Text = 'Altura (metros):';

            % Create referenceRX_Height
            app.referenceRX_Height = uieditfield(app.referenceRX_Grid, 'numeric');
            app.referenceRX_Height.Limits = [0 Inf];
            app.referenceRX_Height.RoundFractionalValues = 'on';
            app.referenceRX_Height.ValueDisplayFormat = '%d';
            app.referenceRX_Height.Editable = 'off';
            app.referenceRX_Height.FontSize = 11;
            app.referenceRX_Height.Layout.Row = 2;
            app.referenceRX_Height.Layout.Column = 3;

            % Create filter_SecondaryLabel
            app.filter_SecondaryLabel = uilabel(app.SubGrid2);
            app.filter_SecondaryLabel.VerticalAlignment = 'bottom';
            app.filter_SecondaryLabel.FontSize = 10;
            app.filter_SecondaryLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryLabel.Layout.Row = 3;
            app.filter_SecondaryLabel.Layout.Column = 1;
            app.filter_SecondaryLabel.Text = 'FILTRO';

            % Create filter_SecondaryValuePanel
            app.filter_SecondaryValuePanel = uibuttongroup(app.SubGrid2);
            app.filter_SecondaryValuePanel.AutoResizeChildren = 'off';
            app.filter_SecondaryValuePanel.SelectionChangedFcn = createCallbackFcn(app, @filter_SecondaryValuePanelSelectionChanged, true);
            app.filter_SecondaryValuePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryValuePanel.BackgroundColor = [1 1 1];
            app.filter_SecondaryValuePanel.Layout.Row = 5;
            app.filter_SecondaryValuePanel.Layout.Column = [1 2];

            % Create filter_SecondaryOperation1
            app.filter_SecondaryOperation1 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation1.Tag = 'numeric+textFree+textList2';
            app.filter_SecondaryOperation1.Tooltip = {'Igual'};
            app.filter_SecondaryOperation1.Text = '=';
            app.filter_SecondaryOperation1.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation1.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation1.Position = [8 97 24 22];

            % Create filter_SecondaryOperation2
            app.filter_SecondaryOperation2 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation2.Tag = 'numeric+textFree+textList2+textList3';
            app.filter_SecondaryOperation2.Tooltip = {'Diferente'};
            app.filter_SecondaryOperation2.Text = '≠';
            app.filter_SecondaryOperation2.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation2.Position = [37 97 24 22];

            % Create filter_SecondaryOperation3
            app.filter_SecondaryOperation3 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation3.Tag = 'ROI+textFree+textList1';
            app.filter_SecondaryOperation3.Enable = 'off';
            app.filter_SecondaryOperation3.Tooltip = {'Contém'};
            app.filter_SecondaryOperation3.Text = '⊃';
            app.filter_SecondaryOperation3.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation3.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation3.Position = [66 97 24 22];

            % Create filter_SecondaryOperation4
            app.filter_SecondaryOperation4 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation4.Tag = 'textFree+textList1';
            app.filter_SecondaryOperation4.Enable = 'off';
            app.filter_SecondaryOperation4.Tooltip = {'Não contém'};
            app.filter_SecondaryOperation4.Text = '⊅';
            app.filter_SecondaryOperation4.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation4.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation4.Position = [96 97 24 22];

            % Create filter_SecondaryOperation5
            app.filter_SecondaryOperation5 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation5.Tag = 'numeric';
            app.filter_SecondaryOperation5.Tooltip = {'Menor'};
            app.filter_SecondaryOperation5.Text = '<';
            app.filter_SecondaryOperation5.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation5.FontName = 'Consolas';
            app.filter_SecondaryOperation5.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation5.Position = [125 97 24 22];

            % Create filter_SecondaryOperation6
            app.filter_SecondaryOperation6 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation6.Tag = 'numeric';
            app.filter_SecondaryOperation6.Tooltip = {'Menor ou igual'};
            app.filter_SecondaryOperation6.Text = '≤';
            app.filter_SecondaryOperation6.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation6.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation6.Position = [154 97 24 22];
            app.filter_SecondaryOperation6.Value = true;

            % Create filter_SecondaryOperation7
            app.filter_SecondaryOperation7 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation7.Tag = 'numeric';
            app.filter_SecondaryOperation7.Tooltip = {'Maior'};
            app.filter_SecondaryOperation7.Text = '>';
            app.filter_SecondaryOperation7.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation7.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation7.Position = [182 97 24 22];

            % Create filter_SecondaryOperation8
            app.filter_SecondaryOperation8 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation8.Tag = 'numeric';
            app.filter_SecondaryOperation8.Tooltip = {'Maior ou igual'};
            app.filter_SecondaryOperation8.Text = '≥';
            app.filter_SecondaryOperation8.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation8.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation8.Position = [211 97 24 22];

            % Create filter_SecondaryOperation9
            app.filter_SecondaryOperation9 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation9.Tag = 'numeric';
            app.filter_SecondaryOperation9.Tooltip = {'Dentro do intervalo'};
            app.filter_SecondaryOperation9.Text = '><';
            app.filter_SecondaryOperation9.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation9.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation9.Position = [239 97 24 22];

            % Create filter_SecondaryOperation10
            app.filter_SecondaryOperation10 = uitogglebutton(app.filter_SecondaryValuePanel);
            app.filter_SecondaryOperation10.Tag = 'numeric';
            app.filter_SecondaryOperation10.Tooltip = {'Fora do intervalo'};
            app.filter_SecondaryOperation10.Text = '<>';
            app.filter_SecondaryOperation10.BackgroundColor = [1 1 1];
            app.filter_SecondaryOperation10.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryOperation10.Position = [267 97 24 22];

            % Create filter_SecondaryValueSubpanel
            app.filter_SecondaryValueSubpanel = uipanel(app.filter_SecondaryValuePanel);
            app.filter_SecondaryValueSubpanel.AutoResizeChildren = 'off';
            app.filter_SecondaryValueSubpanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryValueSubpanel.BorderType = 'none';
            app.filter_SecondaryValueSubpanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.filter_SecondaryValueSubpanel.Position = [10 9 278 79];

            % Create filter_SecondaryValueGrid
            app.filter_SecondaryValueGrid = uigridlayout(app.filter_SecondaryValueSubpanel);
            app.filter_SecondaryValueGrid.ColumnWidth = {'1x', 10, '1x'};
            app.filter_SecondaryValueGrid.RowHeight = {22, 25, 22};
            app.filter_SecondaryValueGrid.ColumnSpacing = 5;
            app.filter_SecondaryValueGrid.RowSpacing = 5;
            app.filter_SecondaryValueGrid.Padding = [0 0 0 0];
            app.filter_SecondaryValueGrid.BackgroundColor = [1 1 1];

            % Create filter_SecondaryNumValue1
            app.filter_SecondaryNumValue1 = uieditfield(app.filter_SecondaryValueGrid, 'numeric');
            app.filter_SecondaryNumValue1.Limits = [-1 Inf];
            app.filter_SecondaryNumValue1.ValueDisplayFormat = '%10.10g';
            app.filter_SecondaryNumValue1.FontSize = 11;
            app.filter_SecondaryNumValue1.FontColor = [0.149 0.149 0.149];
            app.filter_SecondaryNumValue1.Layout.Row = 1;
            app.filter_SecondaryNumValue1.Layout.Column = 1;
            app.filter_SecondaryNumValue1.Value = 30;

            % Create filter_SecondaryNumSeparator
            app.filter_SecondaryNumSeparator = uilabel(app.filter_SecondaryValueGrid);
            app.filter_SecondaryNumSeparator.HorizontalAlignment = 'center';
            app.filter_SecondaryNumSeparator.FontSize = 11;
            app.filter_SecondaryNumSeparator.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryNumSeparator.Visible = 'off';
            app.filter_SecondaryNumSeparator.Layout.Row = 1;
            app.filter_SecondaryNumSeparator.Layout.Column = 2;
            app.filter_SecondaryNumSeparator.Text = '-';

            % Create filter_SecondaryNumValue2
            app.filter_SecondaryNumValue2 = uieditfield(app.filter_SecondaryValueGrid, 'numeric');
            app.filter_SecondaryNumValue2.Limits = [-1 Inf];
            app.filter_SecondaryNumValue2.FontSize = 11;
            app.filter_SecondaryNumValue2.FontColor = [0.149 0.149 0.149];
            app.filter_SecondaryNumValue2.Visible = 'off';
            app.filter_SecondaryNumValue2.Layout.Row = 1;
            app.filter_SecondaryNumValue2.Layout.Column = 3;
            app.filter_SecondaryNumValue2.Value = -1;

            % Create filter_SecondaryTextFree
            app.filter_SecondaryTextFree = uieditfield(app.filter_SecondaryValueGrid, 'text');
            app.filter_SecondaryTextFree.FontSize = 11;
            app.filter_SecondaryTextFree.FontColor = [0.149 0.149 0.149];
            app.filter_SecondaryTextFree.Visible = 'off';
            app.filter_SecondaryTextFree.Layout.Row = 1;
            app.filter_SecondaryTextFree.Layout.Column = [1 3];

            % Create filter_SecondaryTextList
            app.filter_SecondaryTextList = uidropdown(app.filter_SecondaryValueGrid);
            app.filter_SecondaryTextList.Items = {};
            app.filter_SecondaryTextList.Visible = 'off';
            app.filter_SecondaryTextList.FontSize = 11;
            app.filter_SecondaryTextList.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryTextList.BackgroundColor = [1 1 1];
            app.filter_SecondaryTextList.Layout.Row = 1;
            app.filter_SecondaryTextList.Layout.Column = [1 3];
            app.filter_SecondaryTextList.Value = {};

            % Create filter_SecondaryReferenceFilterLabel
            app.filter_SecondaryReferenceFilterLabel = uilabel(app.filter_SecondaryValueGrid);
            app.filter_SecondaryReferenceFilterLabel.VerticalAlignment = 'bottom';
            app.filter_SecondaryReferenceFilterLabel.FontSize = 10;
            app.filter_SecondaryReferenceFilterLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryReferenceFilterLabel.Layout.Row = 2;
            app.filter_SecondaryReferenceFilterLabel.Layout.Column = 1;
            app.filter_SecondaryReferenceFilterLabel.Text = {'Filtro de '; 'referência (ID):'};

            % Create filter_SecondaryReferenceFilter
            app.filter_SecondaryReferenceFilter = uidropdown(app.filter_SecondaryValueGrid);
            app.filter_SecondaryReferenceFilter.Items = {};
            app.filter_SecondaryReferenceFilter.ValueChangedFcn = createCallbackFcn(app, @filter_SecondaryReferenceFilterValueChanged, true);
            app.filter_SecondaryReferenceFilter.FontSize = 11;
            app.filter_SecondaryReferenceFilter.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryReferenceFilter.BackgroundColor = [1 1 1];
            app.filter_SecondaryReferenceFilter.Layout.Row = 3;
            app.filter_SecondaryReferenceFilter.Layout.Column = 1;
            app.filter_SecondaryReferenceFilter.Value = {};

            % Create filter_SecondaryLogicalOperatorLabel
            app.filter_SecondaryLogicalOperatorLabel = uilabel(app.filter_SecondaryValueGrid);
            app.filter_SecondaryLogicalOperatorLabel.VerticalAlignment = 'bottom';
            app.filter_SecondaryLogicalOperatorLabel.FontSize = 10;
            app.filter_SecondaryLogicalOperatorLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryLogicalOperatorLabel.Layout.Row = 2;
            app.filter_SecondaryLogicalOperatorLabel.Layout.Column = 3;
            app.filter_SecondaryLogicalOperatorLabel.Text = {'Operador '; 'lógico:'};

            % Create filter_SecondaryLogicalOperator
            app.filter_SecondaryLogicalOperator = uidropdown(app.filter_SecondaryValueGrid);
            app.filter_SecondaryLogicalOperator.Items = {'E (&&)'};
            app.filter_SecondaryLogicalOperator.FontSize = 11;
            app.filter_SecondaryLogicalOperator.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryLogicalOperator.BackgroundColor = [1 1 1];
            app.filter_SecondaryLogicalOperator.Layout.Row = 3;
            app.filter_SecondaryLogicalOperator.Layout.Column = 3;
            app.filter_SecondaryLogicalOperator.Value = 'E (&&)';

            % Create filter_AddImage
            app.filter_AddImage = uiimage(app.SubGrid2);
            app.filter_AddImage.ScaleMethod = 'none';
            app.filter_AddImage.ImageClickedFcn = createCallbackFcn(app, @filter_addFilter, true);
            app.filter_AddImage.Tooltip = {'Adicionar filtro'};
            app.filter_AddImage.Layout.Row = 6;
            app.filter_AddImage.Layout.Column = 2;
            app.filter_AddImage.HorizontalAlignment = 'right';
            app.filter_AddImage.ImageSource = 'Add_16.png';

            % Create filter_Tree
            app.filter_Tree = uitree(app.SubGrid2, 'checkbox');
            app.filter_Tree.FontSize = 10.5;
            app.filter_Tree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_Tree.Layout.Row = 7;
            app.filter_Tree.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.filter_Tree.CheckedNodesChangedFcn = createCallbackFcn(app, @filter_TreeCheckedNodesChanged, true);

            % Create referenceRX_TitleGrid
            app.referenceRX_TitleGrid = uigridlayout(app.SubGrid2);
            app.referenceRX_TitleGrid.ColumnWidth = {22, '1x', 18, 18, 0, 0};
            app.referenceRX_TitleGrid.RowHeight = {18, 18};
            app.referenceRX_TitleGrid.ColumnSpacing = 5;
            app.referenceRX_TitleGrid.RowSpacing = 0;
            app.referenceRX_TitleGrid.Padding = [0 0 0 0];
            app.referenceRX_TitleGrid.Layout.Row = 1;
            app.referenceRX_TitleGrid.Layout.Column = [1 2];
            app.referenceRX_TitleGrid.BackgroundColor = [1 1 1];

            % Create referenceRX_Icon
            app.referenceRX_Icon = uiimage(app.referenceRX_TitleGrid);
            app.referenceRX_Icon.Layout.Row = [1 2];
            app.referenceRX_Icon.Layout.Column = 1;
            app.referenceRX_Icon.ImageSource = 'Pin_32Triangle.png';

            % Create referenceRX_Label
            app.referenceRX_Label = uilabel(app.referenceRX_TitleGrid);
            app.referenceRX_Label.VerticalAlignment = 'bottom';
            app.referenceRX_Label.FontSize = 11;
            app.referenceRX_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.referenceRX_Label.Layout.Row = [1 2];
            app.referenceRX_Label.Layout.Column = 2;
            app.referenceRX_Label.Interpreter = 'html';
            app.referenceRX_Label.Text = {'<b>Estação receptora - RX</b>'; '<font style="font-size: 9px; color: gray;">(Referência coluna "Distância" e enlace)</font>'};

            % Create referenceRX_Refresh
            app.referenceRX_Refresh = uiimage(app.referenceRX_TitleGrid);
            app.referenceRX_Refresh.ScaleMethod = 'none';
            app.referenceRX_Refresh.ImageClickedFcn = createCallbackFcn(app, @referenceRX_EditionModeImageClicked, true);
            app.referenceRX_Refresh.Visible = 'off';
            app.referenceRX_Refresh.Layout.Row = 2;
            app.referenceRX_Refresh.Layout.Column = 3;
            app.referenceRX_Refresh.ImageSource = 'Refresh_18.png';

            % Create referenceRX_EditionMode
            app.referenceRX_EditionMode = uiimage(app.referenceRX_TitleGrid);
            app.referenceRX_EditionMode.ImageClickedFcn = createCallbackFcn(app, @referenceRX_EditionModeImageClicked, true);
            app.referenceRX_EditionMode.Layout.Row = 2;
            app.referenceRX_EditionMode.Layout.Column = 4;
            app.referenceRX_EditionMode.ImageSource = 'Edit_32.png';

            % Create referenceRX_EditionConfirm
            app.referenceRX_EditionConfirm = uiimage(app.referenceRX_TitleGrid);
            app.referenceRX_EditionConfirm.ImageClickedFcn = createCallbackFcn(app, @referenceRX_EditionModeImageClicked, true);
            app.referenceRX_EditionConfirm.Enable = 'off';
            app.referenceRX_EditionConfirm.Layout.Row = 2;
            app.referenceRX_EditionConfirm.Layout.Column = 5;
            app.referenceRX_EditionConfirm.ImageSource = 'Ok_32Green.png';

            % Create referenceRX_EditionCancel
            app.referenceRX_EditionCancel = uiimage(app.referenceRX_TitleGrid);
            app.referenceRX_EditionCancel.ImageClickedFcn = createCallbackFcn(app, @referenceRX_EditionModeImageClicked, true);
            app.referenceRX_EditionCancel.Enable = 'off';
            app.referenceRX_EditionCancel.Layout.Row = 2;
            app.referenceRX_EditionCancel.Layout.Column = 6;
            app.referenceRX_EditionCancel.ImageSource = 'Delete_32Red.png';

            % Create filter_SecondaryTypePanel
            app.filter_SecondaryTypePanel = uibuttongroup(app.SubGrid2);
            app.filter_SecondaryTypePanel.AutoResizeChildren = 'off';
            app.filter_SecondaryTypePanel.SelectionChangedFcn = createCallbackFcn(app, @filter_typePanelSelectionChanged, true);
            app.filter_SecondaryTypePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryTypePanel.BackgroundColor = [1 1 1];
            app.filter_SecondaryTypePanel.Layout.Row = 4;
            app.filter_SecondaryTypePanel.Layout.Column = [1 2];
            app.filter_SecondaryTypePanel.FontWeight = 'bold';
            app.filter_SecondaryTypePanel.FontSize = 10;

            % Create filter_SecondaryType1
            app.filter_SecondaryType1 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType1.Tag = 'Source';
            app.filter_SecondaryType1.Text = 'Base de dados';
            app.filter_SecondaryType1.FontSize = 10.5;
            app.filter_SecondaryType1.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType1.Interpreter = 'html';
            app.filter_SecondaryType1.Position = [8 69 94 22];

            % Create filter_SecondaryType2
            app.filter_SecondaryType2 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType2.Tag = 'Frequency';
            app.filter_SecondaryType2.Text = 'Frequência (MHz)';
            app.filter_SecondaryType2.FontSize = 10.5;
            app.filter_SecondaryType2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType2.Interpreter = 'html';
            app.filter_SecondaryType2.Position = [8 48 108 22];

            % Create filter_SecondaryType3
            app.filter_SecondaryType3 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType3.Tag = 'BW';
            app.filter_SecondaryType3.Text = 'Largura (kHz)';
            app.filter_SecondaryType3.FontSize = 10.5;
            app.filter_SecondaryType3.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType3.Interpreter = 'html';
            app.filter_SecondaryType3.Position = [8 27 88 22];

            % Create filter_SecondaryType5
            app.filter_SecondaryType5 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType5.Tag = '_Name';
            app.filter_SecondaryType5.Text = 'Entidade';
            app.filter_SecondaryType5.FontSize = 10.5;
            app.filter_SecondaryType5.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType5.Interpreter = 'html';
            app.filter_SecondaryType5.Position = [136 69 63 22];

            % Create filter_SecondaryType6
            app.filter_SecondaryType6 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType6.Tag = 'Fistel';
            app.filter_SecondaryType6.Text = 'Fistel';
            app.filter_SecondaryType6.FontSize = 10.5;
            app.filter_SecondaryType6.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType6.Interpreter = 'html';
            app.filter_SecondaryType6.Position = [136 48 47 22];

            % Create filter_SecondaryType7
            app.filter_SecondaryType7 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType7.Tag = 'Service';
            app.filter_SecondaryType7.Text = 'Serviço';
            app.filter_SecondaryType7.FontSize = 10.5;
            app.filter_SecondaryType7.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType7.Interpreter = 'html';
            app.filter_SecondaryType7.Position = [136 27 57 22];

            % Create filter_SecondaryType8
            app.filter_SecondaryType8 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType8.Tag = 'Station';
            app.filter_SecondaryType8.Text = 'Estação';
            app.filter_SecondaryType8.FontSize = 10.5;
            app.filter_SecondaryType8.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType8.Interpreter = 'html';
            app.filter_SecondaryType8.Position = [136 6 60 22];

            % Create filter_SecondaryType9
            app.filter_SecondaryType9 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType9.Tag = 'State';
            app.filter_SecondaryType9.Text = 'UF';
            app.filter_SecondaryType9.FontSize = 10.5;
            app.filter_SecondaryType9.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType9.Interpreter = 'html';
            app.filter_SecondaryType9.Position = [224 69 36 22];

            % Create filter_SecondaryType10
            app.filter_SecondaryType10 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType10.Tag = '_Location';
            app.filter_SecondaryType10.Text = 'Município';
            app.filter_SecondaryType10.FontSize = 10.5;
            app.filter_SecondaryType10.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType10.Interpreter = 'html';
            app.filter_SecondaryType10.Position = [224 48 67 22];

            % Create filter_SecondaryType11
            app.filter_SecondaryType11 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType11.Tag = 'Distance';
            app.filter_SecondaryType11.Text = 'Distância';
            app.filter_SecondaryType11.FontSize = 10.5;
            app.filter_SecondaryType11.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType11.Interpreter = 'html';
            app.filter_SecondaryType11.Position = [224 27 65 22];
            app.filter_SecondaryType11.Value = true;

            % Create filter_SecondaryType12
            app.filter_SecondaryType12 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType12.Tag = '-1';
            app.filter_SecondaryType12.Text = 'ROI';
            app.filter_SecondaryType12.FontSize = 10.5;
            app.filter_SecondaryType12.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType12.Interpreter = 'html';
            app.filter_SecondaryType12.Position = [224 5 41 22];

            % Create filter_SecondaryType13
            app.filter_SecondaryType13 = uiradiobutton(app.filter_SecondaryTypePanel);
            app.filter_SecondaryType13.Tag = 'AntennaPattern';
            app.filter_SecondaryType13.Text = 'Padrão de antena';
            app.filter_SecondaryType13.FontSize = 10.5;
            app.filter_SecondaryType13.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filter_SecondaryType13.Interpreter = 'html';
            app.filter_SecondaryType13.Position = [8 6 106 22];

            % Create SubTab3
            app.SubTab3 = uitab(app.SubTabGroup);
            app.SubTab3.AutoResizeChildren = 'off';
            app.SubTab3.Title = 'CONFIG';
            app.SubTab3.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SubTab3.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];

            % Create SubGrid3
            app.SubGrid3 = uigridlayout(app.SubTab3);
            app.SubGrid3.ColumnWidth = {'1x', 18};
            app.SubGrid3.RowHeight = {22, 154, 22, '1x'};
            app.SubGrid3.ColumnSpacing = 5;
            app.SubGrid3.RowSpacing = 5;
            app.SubGrid3.Padding = [10 10 10 5];
            app.SubGrid3.BackgroundColor = [1 1 1];

            % Create config_geoAxesLabel
            app.config_geoAxesLabel = uilabel(app.SubGrid3);
            app.config_geoAxesLabel.VerticalAlignment = 'bottom';
            app.config_geoAxesLabel.WordWrap = 'on';
            app.config_geoAxesLabel.FontSize = 10;
            app.config_geoAxesLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_geoAxesLabel.Layout.Row = 1;
            app.config_geoAxesLabel.Layout.Column = 1;
            app.config_geoAxesLabel.Text = 'EIXO GEOGRÁFICO';

            % Create config_Refresh
            app.config_Refresh = uiimage(app.SubGrid3);
            app.config_Refresh.ScaleMethod = 'none';
            app.config_Refresh.ImageClickedFcn = createCallbackFcn(app, @config_Refreshconfig_RefreshClicked, true);
            app.config_Refresh.Visible = 'off';
            app.config_Refresh.Layout.Row = 1;
            app.config_Refresh.Layout.Column = 2;
            app.config_Refresh.ImageSource = 'Refresh_18.png';

            % Create config_geoAxesPanel
            app.config_geoAxesPanel = uipanel(app.SubGrid3);
            app.config_geoAxesPanel.AutoResizeChildren = 'off';
            app.config_geoAxesPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_geoAxesPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.config_geoAxesPanel.Layout.Row = 2;
            app.config_geoAxesPanel.Layout.Column = [1 2];

            % Create config_geoAxesGrid
            app.config_geoAxesGrid = uigridlayout(app.config_geoAxesPanel);
            app.config_geoAxesGrid.ColumnWidth = {120, 36, '1x', 50};
            app.config_geoAxesGrid.RowHeight = {22, 22, 22, 22, 22};
            app.config_geoAxesGrid.RowSpacing = 5;
            app.config_geoAxesGrid.BackgroundColor = [1 1 1];

            % Create config_BasemapLabel
            app.config_BasemapLabel = uilabel(app.config_geoAxesGrid);
            app.config_BasemapLabel.FontSize = 10;
            app.config_BasemapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_BasemapLabel.Layout.Row = 1;
            app.config_BasemapLabel.Layout.Column = 1;
            app.config_BasemapLabel.Text = 'Basemap:';

            % Create config_Basemap
            app.config_Basemap = uidropdown(app.config_geoAxesGrid);
            app.config_Basemap.Items = {'none', 'darkwater', 'streets-light', 'streets-dark', 'satellite', 'topographic', 'grayterrain'};
            app.config_Basemap.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Basemap.FontSize = 11;
            app.config_Basemap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Basemap.BackgroundColor = [1 1 1];
            app.config_Basemap.Layout.Row = 1;
            app.config_Basemap.Layout.Column = [2 4];
            app.config_Basemap.Value = 'satellite';

            % Create config_ColormapLabel
            app.config_ColormapLabel = uilabel(app.config_geoAxesGrid);
            app.config_ColormapLabel.FontSize = 10;
            app.config_ColormapLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ColormapLabel.Layout.Row = 2;
            app.config_ColormapLabel.Layout.Column = 1;
            app.config_ColormapLabel.Text = 'Mapa de cor:';

            % Create config_Colormap
            app.config_Colormap = uidropdown(app.config_geoAxesGrid);
            app.config_Colormap.Items = {'winter', 'parula', 'turbo', 'gray', 'hot', 'jet', 'summer'};
            app.config_Colormap.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Colormap.FontSize = 11;
            app.config_Colormap.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Colormap.BackgroundColor = [1 1 1];
            app.config_Colormap.Layout.Row = 2;
            app.config_Colormap.Layout.Column = [2 4];
            app.config_Colormap.Value = 'winter';

            % Create config_Station_Label
            app.config_Station_Label = uilabel(app.config_geoAxesGrid);
            app.config_Station_Label.WordWrap = 'on';
            app.config_Station_Label.FontSize = 10;
            app.config_Station_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Station_Label.Layout.Row = 3;
            app.config_Station_Label.Layout.Column = 1;
            app.config_Station_Label.Text = 'Estações RFDataHub:';

            % Create config_Station_Color
            app.config_Station_Color = uicolorpicker(app.config_geoAxesGrid);
            app.config_Station_Color.Value = [0 1 1];
            app.config_Station_Color.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_Station_Color.Layout.Row = 3;
            app.config_Station_Color.Layout.Column = 2;
            app.config_Station_Color.BackgroundColor = [1 1 1];

            % Create config_Station_Size
            app.config_Station_Size = uislider(app.config_geoAxesGrid);
            app.config_Station_Size.Limits = [1 36];
            app.config_Station_Size.MajorTicks = [];
            app.config_Station_Size.ValueChangingFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_Station_Size.MinorTicks = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 36];
            app.config_Station_Size.FontSize = 10;
            app.config_Station_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_Station_Size.Tooltip = {'Tamanho do marcador'};
            app.config_Station_Size.Layout.Row = 3;
            app.config_Station_Size.Layout.Column = [3 4];
            app.config_Station_Size.Value = 1;

            % Create config_TX_Label
            app.config_TX_Label = uilabel(app.config_geoAxesGrid);
            app.config_TX_Label.WordWrap = 'on';
            app.config_TX_Label.FontSize = 10;
            app.config_TX_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_TX_Label.Layout.Row = 4;
            app.config_TX_Label.Layout.Column = [1 2];
            app.config_TX_Label.Text = 'Estação transmissora - TX:';

            % Create config_TX_Color
            app.config_TX_Color = uicolorpicker(app.config_geoAxesGrid);
            app.config_TX_Color.Value = [0.7882 0.2784 0.3412];
            app.config_TX_Color.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_TX_Color.Layout.Row = 4;
            app.config_TX_Color.Layout.Column = 2;
            app.config_TX_Color.BackgroundColor = [1 1 1];

            % Create config_TX_Size
            app.config_TX_Size = uislider(app.config_geoAxesGrid);
            app.config_TX_Size.Limits = [1 3];
            app.config_TX_Size.MajorTicks = [];
            app.config_TX_Size.ValueChangingFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_TX_Size.MinorTicks = [1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3];
            app.config_TX_Size.FontSize = 10;
            app.config_TX_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_TX_Size.Tooltip = {'Tamanho do marcador'};
            app.config_TX_Size.Layout.Row = 4;
            app.config_TX_Size.Layout.Column = 3;
            app.config_TX_Size.Value = 1;

            % Create config_TX_DataTipVisibility
            app.config_TX_DataTipVisibility = uidropdown(app.config_geoAxesGrid);
            app.config_TX_DataTipVisibility.Items = {'on', 'off'};
            app.config_TX_DataTipVisibility.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_TX_DataTipVisibility.Tooltip = {'Datatip'};
            app.config_TX_DataTipVisibility.FontSize = 11;
            app.config_TX_DataTipVisibility.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_TX_DataTipVisibility.BackgroundColor = [1 1 1];
            app.config_TX_DataTipVisibility.Layout.Row = 4;
            app.config_TX_DataTipVisibility.Layout.Column = 4;
            app.config_TX_DataTipVisibility.Value = 'off';

            % Create config_RX_Label
            app.config_RX_Label = uilabel(app.config_geoAxesGrid);
            app.config_RX_Label.WordWrap = 'on';
            app.config_RX_Label.FontSize = 10;
            app.config_RX_Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_RX_Label.Layout.Row = 5;
            app.config_RX_Label.Layout.Column = [1 2];
            app.config_RX_Label.Text = 'Estação receptora - RX:';

            % Create config_RX_Color
            app.config_RX_Color = uicolorpicker(app.config_geoAxesGrid);
            app.config_RX_Color.Value = [0.7882 0.2784 0.3373];
            app.config_RX_Color.ValueChangedFcn = createCallbackFcn(app, @config_geoAxesColorParameterChanged, true);
            app.config_RX_Color.Layout.Row = 5;
            app.config_RX_Color.Layout.Column = 2;
            app.config_RX_Color.BackgroundColor = [1 1 1];

            % Create config_RX_Size
            app.config_RX_Size = uislider(app.config_geoAxesGrid);
            app.config_RX_Size.Limits = [1 3];
            app.config_RX_Size.MajorTicks = [];
            app.config_RX_Size.ValueChangingFcn = createCallbackFcn(app, @config_geoAxesOthersParametersChanged, true);
            app.config_RX_Size.MinorTicks = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3];
            app.config_RX_Size.FontSize = 10;
            app.config_RX_Size.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_RX_Size.Tooltip = {'Tamanho do marcador'};
            app.config_RX_Size.Layout.Row = 5;
            app.config_RX_Size.Layout.Column = [3 4];
            app.config_RX_Size.Value = 1;

            % Create config_ElevationSourceLabel
            app.config_ElevationSourceLabel = uilabel(app.SubGrid3);
            app.config_ElevationSourceLabel.VerticalAlignment = 'bottom';
            app.config_ElevationSourceLabel.FontSize = 10;
            app.config_ElevationSourceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationSourceLabel.Layout.Row = 3;
            app.config_ElevationSourceLabel.Layout.Column = 1;
            app.config_ElevationSourceLabel.Text = 'ELEVAÇÃO';

            % Create config_ElevationSourcePanel
            app.config_ElevationSourcePanel = uipanel(app.SubGrid3);
            app.config_ElevationSourcePanel.AutoResizeChildren = 'off';
            app.config_ElevationSourcePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationSourcePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.config_ElevationSourcePanel.Layout.Row = 4;
            app.config_ElevationSourcePanel.Layout.Column = [1 2];

            % Create config_ElevationSourceGrid
            app.config_ElevationSourceGrid = uigridlayout(app.config_ElevationSourcePanel);
            app.config_ElevationSourceGrid.ColumnWidth = {120, '1x'};
            app.config_ElevationSourceGrid.RowHeight = {22, 22, 40};
            app.config_ElevationSourceGrid.RowSpacing = 5;
            app.config_ElevationSourceGrid.BackgroundColor = [1 1 1];

            % Create config_ElevationAPISourceLabel
            app.config_ElevationAPISourceLabel = uilabel(app.config_ElevationSourceGrid);
            app.config_ElevationAPISourceLabel.FontSize = 10;
            app.config_ElevationAPISourceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationAPISourceLabel.Layout.Row = 1;
            app.config_ElevationAPISourceLabel.Layout.Column = 1;
            app.config_ElevationAPISourceLabel.Text = 'Provedor:';

            % Create config_ElevationAPISource
            app.config_ElevationAPISource = uidropdown(app.config_ElevationSourceGrid);
            app.config_ElevationAPISource.Items = {'Open-Elevation', 'MathWorks WMS Server'};
            app.config_ElevationAPISource.FontSize = 11;
            app.config_ElevationAPISource.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationAPISource.BackgroundColor = [1 1 1];
            app.config_ElevationAPISource.Layout.Row = 1;
            app.config_ElevationAPISource.Layout.Column = 2;
            app.config_ElevationAPISource.Value = 'Open-Elevation';

            % Create config_ElevationNPointsLabel
            app.config_ElevationNPointsLabel = uilabel(app.config_ElevationSourceGrid);
            app.config_ElevationNPointsLabel.FontSize = 10;
            app.config_ElevationNPointsLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationNPointsLabel.Layout.Row = 2;
            app.config_ElevationNPointsLabel.Layout.Column = 1;
            app.config_ElevationNPointsLabel.Text = 'Pontos enlace:';

            % Create config_ElevationNPoints
            app.config_ElevationNPoints = uidropdown(app.config_ElevationSourceGrid);
            app.config_ElevationNPoints.Items = {'64', '128', '256', '512', '1024'};
            app.config_ElevationNPoints.FontSize = 11;
            app.config_ElevationNPoints.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationNPoints.BackgroundColor = [1 1 1];
            app.config_ElevationNPoints.Layout.Row = 2;
            app.config_ElevationNPoints.Layout.Column = 2;
            app.config_ElevationNPoints.Value = '256';

            % Create config_ElevationForceSearch
            app.config_ElevationForceSearch = uicheckbox(app.config_ElevationSourceGrid);
            app.config_ElevationForceSearch.Text = 'Ignora informações em cache, forçando uma consulta ao servidor.';
            app.config_ElevationForceSearch.WordWrap = 'on';
            app.config_ElevationForceSearch.FontSize = 11;
            app.config_ElevationForceSearch.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.config_ElevationForceSearch.Layout.Row = 3;
            app.config_ElevationForceSearch.Layout.Column = [1 2];

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
            app.UITable.ColumnName = {'ID'; 'FREQUÊNCIA|(MHz)'; 'DESCRIÇÃO|(Entidade+Fistel+Multiplicidade+Localidade)'; 'FISTEL'; 'SERVIÇO'; 'ESTAÇÃO'; 'LARGURA|(kHz)'; 'DISTÂNCIA|(km)'};
            app.UITable.ColumnWidth = {60, 110, 'auto', 75, 75, 75, 75, 90};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = [false true false true true true true true];
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @UITableSelectionChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.ForegroundColor = [0.149 0.149 0.149];
            app.UITable.Layout.Row = 4;
            app.UITable.Layout.Column = [1 7];
            app.UITable.FontSize = 10.5;

            % Create chReportHTML
            app.chReportHTML = uihtml(app.Document);
            app.chReportHTML.HTMLSource = 'Warning2.html';
            app.chReportHTML.Layout.Row = 2;
            app.chReportHTML.Layout.Column = [5 7];

            % Create chReportDownloadTime
            app.chReportDownloadTime = uilabel(app.Document);
            app.chReportDownloadTime.BackgroundColor = [0.2 0.2 0.2];
            app.chReportDownloadTime.HorizontalAlignment = 'center';
            app.chReportDownloadTime.FontSize = 10;
            app.chReportDownloadTime.FontColor = [0.902 0.902 0.902];
            app.chReportDownloadTime.Layout.Row = 1;
            app.chReportDownloadTime.Layout.Column = [5 7];
            app.chReportDownloadTime.Text = '';

            % Create chReportHotDownload
            app.chReportHotDownload = uiimage(app.Document);
            app.chReportHotDownload.ScaleMethod = 'none';
            app.chReportHotDownload.ImageClickedFcn = createCallbackFcn(app, @PDFToolbar_ReportImageClicked, true);
            app.chReportHotDownload.Visible = 'off';
            app.chReportHotDownload.Tooltip = {'Baixa versão atual do documento'};
            app.chReportHotDownload.Layout.Row = 1;
            app.chReportHotDownload.Layout.Column = 5;
            app.chReportHotDownload.ImageSource = 'refresh-18px-white.png';

            % Create chReportUndock
            app.chReportUndock = uiimage(app.Document);
            app.chReportUndock.ScaleMethod = 'none';
            app.chReportUndock.ImageClickedFcn = createCallbackFcn(app, @PDFToolbar_ReportImageClicked, true);
            app.chReportUndock.Visible = 'off';
            app.chReportUndock.Tooltip = {'Abre documento em leitor externo'};
            app.chReportUndock.Layout.Row = 1;
            app.chReportUndock.Layout.Column = 6;
            app.chReportUndock.ImageSource = 'Undock_18White.png';

            % Create plotPanel
            app.plotPanel = uipanel(app.Document);
            app.plotPanel.AutoResizeChildren = 'off';
            app.plotPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.plotPanel.BorderType = 'none';
            app.plotPanel.BackgroundColor = [1 1 1];
            app.plotPanel.Layout.Row = [1 2];
            app.plotPanel.Layout.Column = [1 3];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {22, 22};
            app.AxesToolbar.RowHeight = {22};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = 1;
            app.AxesToolbar.Layout.Column = 2;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ScaleMethod = 'none';
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_InteractionImageClicked, true);
            app.axesTool_RestoreView.Layout.Row = 1;
            app.axesTool_RestoreView.Layout.Column = 1;
            app.axesTool_RestoreView.ImageSource = 'Home_18.png';

            % Create axesTool_RegionZoom
            app.axesTool_RegionZoom = uiimage(app.AxesToolbar);
            app.axesTool_RegionZoom.ScaleMethod = 'none';
            app.axesTool_RegionZoom.ImageClickedFcn = createCallbackFcn(app, @AxesToolbar_InteractionImageClicked, true);
            app.axesTool_RegionZoom.Layout.Row = 1;
            app.axesTool_RegionZoom.Layout.Column = 2;
            app.axesTool_RegionZoom.ImageSource = 'ZoomRegion_20.png';

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
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winRFDataHub';

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
