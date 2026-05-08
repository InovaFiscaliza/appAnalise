classdef dockDriveTestFilter_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        GridLayout           matlab.ui.container.GridLayout
        FilterList           matlab.ui.control.ListBox
        AddFilterButton      matlab.ui.control.Image
        RadioGroup           matlab.ui.container.ButtonGroup
        KMLFileLayer         matlab.ui.control.DropDown
        KMLOpenFile          matlab.ui.control.Image
        KMLFilename          matlab.ui.control.EditField
        KMLFilenameLabel     matlab.ui.control.Label
        GeographicType       matlab.ui.control.DropDown
        GeographicTypeLabel  matlab.ui.control.Label
        GeographicOption     matlab.ui.control.RadioButton
        ThresholdOption      matlab.ui.control.RadioButton
        Title                matlab.ui.control.Label
        ContextMenu          matlab.ui.container.ContextMenu
        DeleteSelectedItem   matlab.ui.container.Menu
        DeleteAllEntries     matlab.ui.container.Menu
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
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            updateKMLElements(app)
            rebuildFilterList(app)
        end

        %-----------------------------------------------------------------%
        function updateKMLElements(app)
            kmlObj = app.mainApp.kmlObj;

            if ~isempty(kmlObj) && isvalid(kmlObj) && isfile(kmlObj.File)
                [~, fileName, fileExt] = fileparts(app.mainApp.kmlObj.File);
                app.KMLFilename.Value  = [fileName fileExt];
                app.KMLFileLayer.Items = kmlObj.LayerNames;
            else
                app.KMLFilename.Value  = '';
                app.KMLFileLayer.Items = {};
            end
        end

        %-----------------------------------------------------------------%
        function rebuildFilterList(app)
            filterTable = app.callingApp.filterTable;

            if ~isempty(filterTable)
                set(app.FilterList, 'Items', strcat(filterTable.type, {':'}, filterTable.subtype), 'ContextMenu', app.ContextMenu)
            else
                set(app.FilterList, 'Items', {}, 'ContextMenu', [])
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx, emissionIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'flowIdx', flowIdx, 'emissionIdx', emissionIdx);
                initialValues(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Selection changed function: RadioGroup
        function onRadioGroupSelectionChanged(app, event)
            
            switch app.RadioGroup.SelectedObject
                case app.ThresholdOption
                    app.GeographicType.Enable = 'off';
                    set(findobj(app.RadioGroup.Children, 'Tag', 'KML'), 'Enable', 'off')

                case app.GeographicOption
                    app.GeographicType.Enable = 'on';                    
                    onGeographicTypeValueChanged(app)
            end

        end

        % Value changed function: GeographicType
        function onGeographicTypeValueChanged(app, event)
            
            switch app.GeographicType.Value
                case 'Arquivo externo KML/KMZ'
                    set(findobj(app.RadioGroup.Children, 'Tag', 'KML'), 'Enable', 'on')

                otherwise
                    set(findobj(app.RadioGroup.Children, 'Tag', 'KML'), 'Enable', 'off')
            end

        end

        % Image clicked function: KMLOpenFile
        function onKMLOpenFileButtonClicked(app, event)
            
            [~, filePath, ~, fileName] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.kml;*.kmz', '(*.kml, *.kmz)'}, app.mainApp.General.fileFolder.lastVisited);
            
            if ~isempty(fileName)
                app.progressDialog.Visible = 'visible';

                ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', filePath)
                fileFullPath = fullfile(filePath, fileName);

                try
                    kmlObj = app.mainApp.kmlObj;

                    if ~isempty(kmlObj) && isvalid(kmlObj) && isequal(kmlObj.File, fileFullPath)
                        return
                    end

                    if ~isempty(kmlObj)
                        delete(app.mainApp.kmlObj)
                    end

                    app.mainApp.kmlObj = RF.KML(fileFullPath);

                catch ME
                    delete(app.mainApp.kmlObj)
                    app.mainApp.kmlObj = [];

                    ui.Dialog(app.UIFigure, 'error', ME.message);
                end
                updateKMLElements(app)

                app.progressDialog.Visible = 'hidden';
            end   

        end

        % Image clicked function: AddFilterButton
        function onAddFilterButtonClicked(app, event)
            
            kmlObj = app.mainApp.kmlObj;
            emissionPoints = app.callingApp.emissionPoints;

            switch app.RadioGroup.SelectedObject
                case app.ThresholdOption
                    if ismember('Level', app.callingApp.filterTable.type)
                        msgWarning = [ ...
                            'Já foi incluído o filtro de nível, cujo <i>threshold</i> pode ser ajustado ' ...
                            'diretamente no eixo que apresenta a potência do canal sob análise.' ...
                        ];
                        ui.Dialog(app.UIFigure, 'warning', msgWarning);
                        return
                    end

                    filterType = 'Level';
                    filterSubtype = 'Threshold';
                    initialThreshold = min(app.callingApp.emissionPoints.raw.ChannelPower);

                    hROI = plot_FilterROIObject(app, 'DrawInRealTime', filterSubtype, app.callingApp.UIAxes4);
                    hROI.Position = [height(emissionPoints.raw) initialThreshold; 1 initialThreshold];

                    app.callingApp.filterTable(end+1, :) = {filterType, filterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onDriveTestFilterChanged', app.callingApp.filterTable)

                case app.GeographicOption
                    filterType = 'Geographic ROI';

                    switch app.GeographicType.Value
                        case 'Arquivo externo KML/KMZ'
                            if isempty(app.KMLFilename.Value)
                                msgWarning = 'É preciso escolher um arquivo KML/KMZ antes de adicioná-lo como filtro geográfico.';
                                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                                return
                            end
                            
                            filterSubtype = 'PolygonKML';

                            try
                                readgeotable(kmlObj, app.KMLFileLayer.Value)
                                for ii = 1:height(kmlObj.GeoTable)
                                    shapeObj = kmlObj.GeoTable.Shape(ii);

                                    if isa(shapeObj, 'geopolyshape')
                                        hROI = plot_FilterROIObject(app, 'DrawInRealTime', filterSubtype, app.callingApp.UIAxes1, shapeObj);
                                        app.callingApp.filterTable(end+1, :) = {filterType, filterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};
                                    end
                                end

                                if ~exist('hROI', 'var')
                                    error([ ...
                                        'A pasta "%s", do arquivo "%s", possui apenas objetos do tipo "%s". Um filtro '  ...
                                        'geográfico, contudo, precisa ser um polígono.' ...
                                    ], app.KMLFileLayer.Value, kmlObj.File, textFormatGUI.cellstr2ListWithQuotes(unique(arrayfun(@(x) class(x), kmlObj.GeoTable.Shape, "UniformOutput", false))))
                                end

                            catch ME
                                ui.Dialog(app.UIFigure, 'error', ME.message);
                                return
                            end

                        otherwise
                            switch app.GeographicType.Value
                                case 'ROI:Círculo'
                                    filterSubtype = 'Circle';
                                case 'ROI:Retângulo'
                                    filterSubtype = 'Rectangle';
                                case 'ROI:Polígono'
                                    filterSubtype = 'Polygon';
                            end

                            hROI = plot_FilterROIObject(app, 'DrawInRealTime', filterSubtype, app.CallingApp.UIAxes1);

                            if isempty(hROI.Position)
                                delete(hROI)                
                                return
                            end

                            app.callingApp.filterTable(end+1,:) = {filterType, filterSubtype, struct('handle', hROI, 'specification', plot.ROI.specification(hROI))};
                    end
                    
                    if isprop(hROI, 'DisplayName')
                        hROI.DisplayName = 'Contorno';
                    end
            end
            
            % Insere filtro à tabela app.filterTable, redesenhando a árvore
            % de fitros.
            rebuildFilterList(app)

            % Atualiza o plot...
            UpdatePlot(app)

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
                app.UIFigure.Position = [100 100 412 484];
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
            app.GridLayout.ColumnWidth = {'1x', 18};
            app.GridLayout.RowHeight = {17, 232, 22, '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 1;
            app.Title.Text = 'TIPO DE FILTRO';

            % Create RadioGroup
            app.RadioGroup = uibuttongroup(app.GridLayout);
            app.RadioGroup.AutoResizeChildren = 'off';
            app.RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @onRadioGroupSelectionChanged, true);
            app.RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RadioGroup.BackgroundColor = [1 1 1];
            app.RadioGroup.Layout.Row = 2;
            app.RadioGroup.Layout.Column = [1 2];
            app.RadioGroup.FontWeight = 'bold';
            app.RadioGroup.FontSize = 10;

            % Create ThresholdOption
            app.ThresholdOption = uiradiobutton(app.RadioGroup);
            app.ThresholdOption.Text = {'<b>NÍVEL</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Elimina medições cuja potência do canal sob análise é inferior a limiar configurado diretamente no eixo que apresenta o gráfico de potência.</font>'};
            app.ThresholdOption.WordWrap = 'on';
            app.ThresholdOption.FontSize = 11;
            app.ThresholdOption.Interpreter = 'html';
            app.ThresholdOption.Position = [11 176 349 46];
            app.ThresholdOption.Value = true;

            % Create GeographicOption
            app.GeographicOption = uiradiobutton(app.RadioGroup);
            app.GeographicOption.Text = {'<b>GEOGRÁFICO</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Elimina medições coletadas fora de regiões de interesse (ROI).</p>'};
            app.GeographicOption.FontSize = 11;
            app.GeographicOption.Interpreter = 'html';
            app.GeographicOption.Position = [11 135 309 31];

            % Create GeographicTypeLabel
            app.GeographicTypeLabel = uilabel(app.RadioGroup);
            app.GeographicTypeLabel.VerticalAlignment = 'bottom';
            app.GeographicTypeLabel.FontSize = 11;
            app.GeographicTypeLabel.Position = [30 115 61 16];
            app.GeographicTypeLabel.Text = 'Fonte:';

            % Create GeographicType
            app.GeographicType = uidropdown(app.RadioGroup);
            app.GeographicType.Items = {'ROI:Círculo', 'ROI:Retângulo', 'ROI:Polígono', 'Arquivo externo KML/KMZ'};
            app.GeographicType.ValueChangedFcn = createCallbackFcn(app, @onGeographicTypeValueChanged, true);
            app.GeographicType.Enable = 'off';
            app.GeographicType.FontSize = 11;
            app.GeographicType.BackgroundColor = [1 1 1];
            app.GeographicType.Position = [29 91 301 22];
            app.GeographicType.Value = 'ROI:Círculo';

            % Create KMLFilenameLabel
            app.KMLFilenameLabel = uilabel(app.RadioGroup);
            app.KMLFilenameLabel.VerticalAlignment = 'bottom';
            app.KMLFilenameLabel.FontSize = 11;
            app.KMLFilenameLabel.Position = [30 67 61 18];
            app.KMLFilenameLabel.Text = 'Arquivo:';

            % Create KMLFilename
            app.KMLFilename = uieditfield(app.RadioGroup, 'text');
            app.KMLFilename.Tag = 'KML';
            app.KMLFilename.Editable = 'off';
            app.KMLFilename.FontSize = 11;
            app.KMLFilename.Enable = 'off';
            app.KMLFilename.Position = [29 42 301 22];

            % Create KMLOpenFile
            app.KMLOpenFile = uiimage(app.RadioGroup);
            app.KMLOpenFile.ScaleMethod = 'none';
            app.KMLOpenFile.ImageClickedFcn = createCallbackFcn(app, @onKMLOpenFileButtonClicked, true);
            app.KMLOpenFile.Tag = 'KML';
            app.KMLOpenFile.Enable = 'off';
            app.KMLOpenFile.Position = [340 44 18 18];
            app.KMLOpenFile.ImageSource = 'folder-opened-16px.svg';

            % Create KMLFileLayer
            app.KMLFileLayer = uidropdown(app.RadioGroup);
            app.KMLFileLayer.Items = {};
            app.KMLFileLayer.Tag = 'KML';
            app.KMLFileLayer.Enable = 'off';
            app.KMLFileLayer.FontSize = 11;
            app.KMLFileLayer.BackgroundColor = [1 1 1];
            app.KMLFileLayer.Position = [29 15 301 22];
            app.KMLFileLayer.Value = {};

            % Create AddFilterButton
            app.AddFilterButton = uiimage(app.GridLayout);
            app.AddFilterButton.ScaleMethod = 'none';
            app.AddFilterButton.ImageClickedFcn = createCallbackFcn(app, @onAddFilterButtonClicked, true);
            app.AddFilterButton.Layout.Row = 3;
            app.AddFilterButton.Layout.Column = 2;
            app.AddFilterButton.HorizontalAlignment = 'right';
            app.AddFilterButton.ImageSource = 'Add_16.png';

            % Create FilterList
            app.FilterList = uilistbox(app.GridLayout);
            app.FilterList.Items = {};
            app.FilterList.FontSize = 11;
            app.FilterList.Layout.Row = 4;
            app.FilterList.Layout.Column = [1 2];
            app.FilterList.Value = {};

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create DeleteSelectedItem
            app.DeleteSelectedItem = uimenu(app.ContextMenu);
            app.DeleteSelectedItem.Text = '❌ Excluir';

            % Create DeleteAllEntries
            app.DeleteAllEntries = uimenu(app.ContextMenu);
            app.DeleteAllEntries.Text = '🚫 Excluir todos';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockDriveTestFilter_exported(Container, varargin)

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
