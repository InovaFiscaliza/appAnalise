classdef dockDriveTestFilter_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        GridLayout           matlab.ui.container.GridLayout
        OkButton             matlab.ui.control.Button
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
        TitleIcon            matlab.ui.control.Image
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
                    set([app.GeographicType, app.GeographicTypeLabel], 'Enable', 'off')
                    set(findobj(app.RadioGroup.Children, 'Tag', 'KML'), 'Enable', 'off')

                case app.GeographicOption
                    set([app.GeographicType, app.GeographicTypeLabel], 'Enable', 'on')
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

        % Button pushed function: OkButton
        function onAddFilterButtonClicked(app, event)
            
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

                otherwise % app.GeographicOption
                    filterType = 'Geographic ROI';

                    switch app.GeographicType.Value
                        case 'Arquivo externo KML/KMZ'
                            if isempty(app.KMLFilename.Value)
                                msgWarning = [ ...
                                    'É preciso escolher um arquivo KML/KMZ antes de adicioná-lo como ' ...
                                    'filtro geográfico.' ...
                                ];
                                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                                return
                            end
                            
                            filterSubtype = 'PolygonKML';

                        case 'ROI:Círculo'
                            filterSubtype = 'Circle';

                        case 'ROI:Retângulo'
                            filterSubtype = 'Rectangle';

                        otherwise % 'ROI:Polígono'
                            filterSubtype = 'Polygon';
                    end
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onDriveTestFilterChanged', filterType, filterSubtype)
            closeFcn(app)

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
                app.UIFigure.Position = [100 100 412 338];
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
            app.GridLayout.ColumnWidth = {18, 234, 110};
            app.GridLayout.RowHeight = {17, 5, 242, 10, 24};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TitleIcon
            app.TitleIcon = uiimage(app.GridLayout);
            app.TitleIcon.ScaleMethod = 'none';
            app.TitleIcon.Layout.Row = 1;
            app.TitleIcon.Layout.Column = 1;
            app.TitleIcon.ImageSource = 'Filter_18.png';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 2;
            app.Title.Text = 'TIPO DE FILTRO';

            % Create RadioGroup
            app.RadioGroup = uibuttongroup(app.GridLayout);
            app.RadioGroup.AutoResizeChildren = 'off';
            app.RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @onRadioGroupSelectionChanged, true);
            app.RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RadioGroup.BackgroundColor = [1 1 1];
            app.RadioGroup.Layout.Row = 3;
            app.RadioGroup.Layout.Column = [1 3];
            app.RadioGroup.FontWeight = 'bold';
            app.RadioGroup.FontSize = 10;

            % Create ThresholdOption
            app.ThresholdOption = uiradiobutton(app.RadioGroup);
            app.ThresholdOption.Text = {'<b>NÍVEL</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Elimina medições cuja potência do canal sob análise é inferior a limiar configurado diretamente no eixo que apresenta o gráfico de potência.</font>'};
            app.ThresholdOption.WordWrap = 'on';
            app.ThresholdOption.FontSize = 11;
            app.ThresholdOption.Interpreter = 'html';
            app.ThresholdOption.Position = [11 182 349 46];
            app.ThresholdOption.Value = true;

            % Create GeographicOption
            app.GeographicOption = uiradiobutton(app.RadioGroup);
            app.GeographicOption.Text = {'<b>GEOGRÁFICO</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Elimina medições coletadas fora de regiões de interesse (ROI).</p>'};
            app.GeographicOption.FontSize = 11;
            app.GeographicOption.Interpreter = 'html';
            app.GeographicOption.Position = [11 140 309 31];

            % Create GeographicTypeLabel
            app.GeographicTypeLabel = uilabel(app.RadioGroup);
            app.GeographicTypeLabel.VerticalAlignment = 'bottom';
            app.GeographicTypeLabel.FontSize = 11;
            app.GeographicTypeLabel.FontColor = [0.302 0.302 0.302];
            app.GeographicTypeLabel.Enable = 'off';
            app.GeographicTypeLabel.Position = [30 119 61 16];
            app.GeographicTypeLabel.Text = 'Fonte:';

            % Create GeographicType
            app.GeographicType = uidropdown(app.RadioGroup);
            app.GeographicType.Items = {'ROI:Círculo', 'ROI:Retângulo', 'ROI:Polígono', 'Arquivo externo KML/KMZ'};
            app.GeographicType.ValueChangedFcn = createCallbackFcn(app, @onGeographicTypeValueChanged, true);
            app.GeographicType.Enable = 'off';
            app.GeographicType.FontSize = 11;
            app.GeographicType.FontColor = [0.302 0.302 0.302];
            app.GeographicType.BackgroundColor = [1 1 1];
            app.GeographicType.Position = [29 95 301 22];
            app.GeographicType.Value = 'ROI:Círculo';

            % Create KMLFilenameLabel
            app.KMLFilenameLabel = uilabel(app.RadioGroup);
            app.KMLFilenameLabel.Tag = 'KML';
            app.KMLFilenameLabel.VerticalAlignment = 'bottom';
            app.KMLFilenameLabel.FontSize = 11;
            app.KMLFilenameLabel.FontColor = [0.302 0.302 0.302];
            app.KMLFilenameLabel.Enable = 'off';
            app.KMLFilenameLabel.Position = [30 71 85 18];
            app.KMLFilenameLabel.Text = 'Arquivo externo:';

            % Create KMLFilename
            app.KMLFilename = uieditfield(app.RadioGroup, 'text');
            app.KMLFilename.Tag = 'KML';
            app.KMLFilename.Editable = 'off';
            app.KMLFilename.FontSize = 11;
            app.KMLFilename.FontColor = [0.302 0.302 0.302];
            app.KMLFilename.Enable = 'off';
            app.KMLFilename.Position = [29 46 301 22];

            % Create KMLOpenFile
            app.KMLOpenFile = uiimage(app.RadioGroup);
            app.KMLOpenFile.ScaleMethod = 'none';
            app.KMLOpenFile.ImageClickedFcn = createCallbackFcn(app, @onKMLOpenFileButtonClicked, true);
            app.KMLOpenFile.Tag = 'KML';
            app.KMLOpenFile.Enable = 'off';
            app.KMLOpenFile.Position = [340 48 18 18];
            app.KMLOpenFile.ImageSource = 'folder-opened-16px.svg';

            % Create KMLFileLayer
            app.KMLFileLayer = uidropdown(app.RadioGroup);
            app.KMLFileLayer.Items = {};
            app.KMLFileLayer.Tag = 'KML';
            app.KMLFileLayer.Enable = 'off';
            app.KMLFileLayer.FontSize = 11;
            app.KMLFileLayer.FontColor = [0.302 0.302 0.302];
            app.KMLFileLayer.BackgroundColor = [1 1 1];
            app.KMLFileLayer.Position = [29 19 301 22];
            app.KMLFileLayer.Value = {};

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onAddFilterButtonClicked, true);
            app.OkButton.Icon = 'Add_16.png';
            app.OkButton.FontSize = 11;
            app.OkButton.Layout.Row = 5;
            app.OkButton.Layout.Column = 3;
            app.OkButton.Text = 'Incluir filtro';

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
