classdef dockClassification_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        PanelGrid             matlab.ui.container.GridLayout
        btnOK                 matlab.ui.control.Button
        SubPanel2             matlab.ui.container.Panel
        SubGrid2              matlab.ui.container.GridLayout
        bwLim2                matlab.ui.control.Spinner
        bwLim2Label           matlab.ui.control.Label
        bwLim1                matlab.ui.control.Spinner
        bwLim1Label           matlab.ui.control.Label
        SubPanel1             matlab.ui.container.Panel
        SubGrid1              matlab.ui.container.GridLayout
        Multiplier            matlab.ui.control.Spinner
        MultiplierLabel       matlab.ui.control.Label
        Contour               matlab.ui.control.Spinner
        ContourLabel          matlab.ui.control.Label
        EmrelaodistnciaLabel  matlab.ui.control.Label
        bwLabel               matlab.ui.control.Label
        Algorithm             matlab.ui.control.DropDown
        AlgorithmLabel        matlab.ui.control.Label
        fontstylepaddingleft5pxCLASSIFICAOfontLabel  matlab.ui.control.Label
        btnClose              matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true
        
        mainApp
        specData
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;
            
            app.Algorithm.Value  = app.specData(idxThread).UserData.reportAlgorithms.Classification.Algorithm;
            app.Contour.Value    = app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.Contour;
            app.Multiplier.Value = app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.ClassMultiplier;
            app.bwLim1.Value     = app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.bwFactors(1);
            app.bwLim2.Value     = app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.bwFactors(2);
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app)
            editionFlag = false;

            idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;
            if ~isequal(app.Algorithm.Value,  app.specData(idxThread).UserData.reportAlgorithms.Classification.Algorithm)                  || ...
               ~isequal(app.Contour.Value,    app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.Contour)         || ...
               ~isequal(app.Multiplier.Value, app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.ClassMultiplier) || ...
               ~isequal(app.bwLim1.Value,     app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.bwFactors(1))    || ...
               ~isequal(app.bwLim2.Value,     app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.bwFactors(2))

                editionFlag = true;
            end
        end

        %-----------------------------------------------------------------%
        function callingMainApp(app, updateFlag, returnFlag, idxThread)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'REPORT:CLASSIFICATION', updateFlag, returnFlag, idxThread)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            app.mainApp  = mainApp;
            app.specData = mainApp.specData;

            initialValues(app)
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Value changed function: Algorithm, Contour, Multiplier, bwLim1, 
        % ...and 1 other component
        function ParameterValueChanged(app, event)
            
            if checkEdition(app)
                app.btnOK.Enable = 1;
            else
                app.btnOK.Enable = 0;
            end
            
        end

        % Callback function: btnClose, btnOK
        function ButtonPushed(app, event)
            
            idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;

            pushedButtonTag = event.Source.Tag;
            switch pushedButtonTag
                case 'OK'
                    app.specData(idxThread).UserData.reportAlgorithms.Classification.Algorithm  = app.Algorithm.Value;
                    app.specData(idxThread).UserData.reportAlgorithms.Classification.Parameters = struct('Contour',         app.Contour.Value,    ...
                                                                                                         'ClassMultiplier', app.Multiplier.Value, ...
                                                                                                         'bwFactors',       [app.bwLim1.Value, app.bwLim2.Value]);

                    updateFlag = true;

                case 'Close'
                    updateFlag = false;
            end

            callingMainApp(app, updateFlag, false, idxThread)
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
                app.UIFigure.Position = [100 100 534 248];
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
            app.GridLayout.ColumnWidth = {'1x', 30};
            app.GridLayout.RowHeight = {30, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.902 0.902 0.902];

            % Create btnClose
            app.btnClose = uiimage(app.GridLayout);
            app.btnClose.ScaleMethod = 'none';
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create fontstylepaddingleft5pxCLASSIFICAOfontLabel
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel = uilabel(app.GridLayout);
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel.FontSize = 11;
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel.FontWeight = 'bold';
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel.Layout.Row = 1;
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel.Layout.Column = 1;
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel.Interpreter = 'html';
            app.fontstylepaddingleft5pxCLASSIFICAOfontLabel.Text = '<font style="padding-left: 5px;">CLASSIFICAÇÃO</font>';

            % Create PanelGrid
            app.PanelGrid = uigridlayout(app.GridLayout);
            app.PanelGrid.ColumnWidth = {252, 152, 90};
            app.PanelGrid.RowHeight = {17, 22, 22, 100, 22};
            app.PanelGrid.RowSpacing = 5;
            app.PanelGrid.Padding = [10 10 10 5];
            app.PanelGrid.Layout.Row = 2;
            app.PanelGrid.Layout.Column = [1 2];
            app.PanelGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create AlgorithmLabel
            app.AlgorithmLabel = uilabel(app.PanelGrid);
            app.AlgorithmLabel.VerticalAlignment = 'bottom';
            app.AlgorithmLabel.FontSize = 10;
            app.AlgorithmLabel.Layout.Row = 1;
            app.AlgorithmLabel.Layout.Column = 1;
            app.AlgorithmLabel.Text = 'Algoritmo:';

            % Create Algorithm
            app.Algorithm = uidropdown(app.PanelGrid);
            app.Algorithm.Items = {'Frequency+Distance Type 1'};
            app.Algorithm.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Algorithm.FontSize = 10;
            app.Algorithm.BackgroundColor = [1 1 1];
            app.Algorithm.Layout.Row = 2;
            app.Algorithm.Layout.Column = [1 3];
            app.Algorithm.Value = 'Frequency+Distance Type 1';

            % Create bwLabel
            app.bwLabel = uilabel(app.PanelGrid);
            app.bwLabel.VerticalAlignment = 'bottom';
            app.bwLabel.FontSize = 10;
            app.bwLabel.Layout.Row = 3;
            app.bwLabel.Layout.Column = [2 3];
            app.bwLabel.Text = 'Em relação à largura ocupada:';

            % Create EmrelaodistnciaLabel
            app.EmrelaodistnciaLabel = uilabel(app.PanelGrid);
            app.EmrelaodistnciaLabel.VerticalAlignment = 'bottom';
            app.EmrelaodistnciaLabel.FontSize = 10;
            app.EmrelaodistnciaLabel.Layout.Row = 3;
            app.EmrelaodistnciaLabel.Layout.Column = 1;
            app.EmrelaodistnciaLabel.Text = 'Em relação à distância:';

            % Create SubPanel1
            app.SubPanel1 = uipanel(app.PanelGrid);
            app.SubPanel1.AutoResizeChildren = 'off';
            app.SubPanel1.Layout.Row = 4;
            app.SubPanel1.Layout.Column = 1;

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubPanel1);
            app.SubGrid1.ColumnWidth = {110, 110};
            app.SubGrid1.RowHeight = {50, 22};
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create ContourLabel
            app.ContourLabel = uilabel(app.SubGrid1);
            app.ContourLabel.Tag = 'Offset';
            app.ContourLabel.VerticalAlignment = 'bottom';
            app.ContourLabel.WordWrap = 'on';
            app.ContourLabel.FontSize = 10;
            app.ContourLabel.Layout.Row = 1;
            app.ContourLabel.Layout.Column = 1;
            app.ContourLabel.Text = {'Distância máxima entre sensor e estação sob análise (km):'; '(exceto FM e TV)'};

            % Create Contour
            app.Contour = uispinner(app.SubGrid1);
            app.Contour.Step = 10;
            app.Contour.Limits = [10 200];
            app.Contour.RoundFractionalValues = 'on';
            app.Contour.ValueDisplayFormat = '%d';
            app.Contour.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Contour.Tag = 'Offset';
            app.Contour.FontSize = 10;
            app.Contour.Layout.Row = 2;
            app.Contour.Layout.Column = 1;
            app.Contour.Value = 30;

            % Create MultiplierLabel
            app.MultiplierLabel = uilabel(app.SubGrid1);
            app.MultiplierLabel.Tag = 'THR';
            app.MultiplierLabel.VerticalAlignment = 'bottom';
            app.MultiplierLabel.WordWrap = 'on';
            app.MultiplierLabel.FontSize = 10;
            app.MultiplierLabel.Layout.Row = 1;
            app.MultiplierLabel.Layout.Column = 2;
            app.MultiplierLabel.Text = 'Fator multiplicador do contorno protegido de FM e TV na aferição da distâcia máxima:';

            % Create Multiplier
            app.Multiplier = uispinner(app.SubGrid1);
            app.Multiplier.Limits = [1 4];
            app.Multiplier.RoundFractionalValues = 'on';
            app.Multiplier.ValueDisplayFormat = '%d';
            app.Multiplier.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Multiplier.Tag = 'THR';
            app.Multiplier.FontSize = 10;
            app.Multiplier.Layout.Row = 2;
            app.Multiplier.Layout.Column = 2;
            app.Multiplier.Value = 2;

            % Create SubPanel2
            app.SubPanel2 = uipanel(app.PanelGrid);
            app.SubPanel2.AutoResizeChildren = 'off';
            app.SubPanel2.Layout.Row = 4;
            app.SubPanel2.Layout.Column = [2 3];

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubPanel2);
            app.SubGrid2.ColumnWidth = {110, 110};
            app.SubGrid2.RowHeight = {26, 22};
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create bwLim1Label
            app.bwLim1Label = uilabel(app.SubGrid2);
            app.bwLim1Label.Tag = 'Offset';
            app.bwLim1Label.WordWrap = 'on';
            app.bwLim1Label.FontSize = 10;
            app.bwLim1Label.Layout.Row = 1;
            app.bwLim1Label.Layout.Column = 1;
            app.bwLim1Label.Text = 'Fator de tolerância inferior (%):';

            % Create bwLim1
            app.bwLim1 = uispinner(app.SubGrid2);
            app.bwLim1.Step = 10;
            app.bwLim1.Limits = [10 100];
            app.bwLim1.RoundFractionalValues = 'on';
            app.bwLim1.ValueDisplayFormat = '%d';
            app.bwLim1.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.bwLim1.Tag = 'Offset';
            app.bwLim1.FontSize = 10;
            app.bwLim1.Layout.Row = 2;
            app.bwLim1.Layout.Column = 1;
            app.bwLim1.Value = 90;

            % Create bwLim2Label
            app.bwLim2Label = uilabel(app.SubGrid2);
            app.bwLim2Label.Tag = 'Offset';
            app.bwLim2Label.WordWrap = 'on';
            app.bwLim2Label.FontSize = 10;
            app.bwLim2Label.Layout.Row = 1;
            app.bwLim2Label.Layout.Column = 2;
            app.bwLim2Label.Text = 'Fator de tolerância superior (%):';

            % Create bwLim2
            app.bwLim2 = uispinner(app.SubGrid2);
            app.bwLim2.Step = 10;
            app.bwLim2.Limits = [10 300];
            app.bwLim2.RoundFractionalValues = 'on';
            app.bwLim2.ValueDisplayFormat = '%d';
            app.bwLim2.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.bwLim2.Tag = 'Offset';
            app.bwLim2.FontSize = 10;
            app.bwLim2.Layout.Row = 2;
            app.bwLim2.Layout.Column = 2;
            app.bwLim2.Value = 300;

            % Create btnOK
            app.btnOK = uibutton(app.PanelGrid, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 5;
            app.btnOK.Layout.Column = 3;
            app.btnOK.Text = 'OK';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockClassification_exported(Container, varargin)

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
