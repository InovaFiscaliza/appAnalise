classdef dockLevelFiltering_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        Document              matlab.ui.container.GridLayout
        btnOK                 matlab.ui.control.Button
        FilterPanel           matlab.ui.container.Panel
        FilterGrid            matlab.ui.container.GridLayout
        ThresholdBottomValue  matlab.ui.control.NumericEditField
        ThresholdBottomLabel  matlab.ui.control.Label
        ThresholdTopValue     matlab.ui.control.NumericEditField
        ThresholdTopLabel     matlab.ui.control.Label
        ThresholdBottom       matlab.ui.control.CheckBox
        ThresholdTop          matlab.ui.control.CheckBox
        ConstantValue         matlab.ui.control.NumericEditField
        ConstantLabel         matlab.ui.control.Label
        Constant              matlab.ui.control.CheckBox
        FilterPanelLabel      matlab.ui.control.Label
        btnClose              matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true
        idxThreads

        mainApp
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, idxThreads)
            
            app.mainApp = mainApp;
            app.idxThreads = idxThreads;
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: btnClose, btnOK
        function OKButtonPushed(app, event)
            
            pushedButtonTag = event.Source.Tag;
            switch pushedButtonTag
                case 'OK'
                    fcnHandleStr  = '@(matrix, minLevel, maxLevel)';
                    fcnHandleFlag = false;
                    
                    if app.Constant.Value
                        fcnHandleStr  = [fcnHandleStr, sprintf(' maxLevel-minLevel < %f', app.ConstantValue.Value)];
                        fcnHandleFlag = true;
                    end

                    if app.ThresholdTop.Value
                        if fcnHandleFlag
                            fcnHandleStr = [fcnHandleStr, ' |'];
                        end
                        fcnHandleStr  = [fcnHandleStr, sprintf(' all(matrix < %.1f, 1)', app.ThresholdTopValue.Value)];
                        fcnHandleFlag = true;
                    end                    

                    if app.ThresholdBottom.Value
                        if fcnHandleFlag
                            fcnHandleStr = [fcnHandleStr, ' |'];
                        end
                        fcnHandleStr  = [fcnHandleStr, sprintf(' all(matrix > %.1f, 1)', app.ThresholdBottomValue.Value)];
                        fcnHandleFlag = true;
                    end

                    if ~fcnHandleFlag
                        ui.Dialog(app.mainApp.UIFigure, 'warning', 'Deve ser selecionado ao menos um dos tipos de análise.');
                        return
                    end

                    [editedData, filteringLog] = util.levelFiltering(...
                        app.mainApp.specData, ...
                        app.idxThreads, ...
                        fcnHandleStr ...
                    );

                    ui.Dialog(app.mainApp.UIFigure, 'info', strjoin(filteringLog, '\n\n'));
                    updateFlag = ~isempty(editedData);
                    args = {editedData, 'copy'};

                case 'Close'
                    updateFlag = false;
                    args = {};
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'MISCELLANEOUS:LEVELFILTERING', updateFlag, false, args{:})
            closeFcn(app)

        end

        % Value changed function: Constant, ThresholdBottom, ThresholdTop
        function CheckBoxValueChanged(app, event)
            
            switch event.Source
                case app.Constant
                    if app.Constant.Value
                        app.ConstantValue.Enable = 1;
                    else
                        app.ConstantValue.Enable = 0;
                    end

                case app.ThresholdTop
                    if app.ThresholdTop.Value
                        app.ThresholdTopValue.Enable = 1;
                    else
                        app.ThresholdTopValue.Enable = 0;
                    end
                
                case app.ThresholdBottom
                    if app.ThresholdBottom.Value
                        app.ThresholdBottomValue.Enable = 1;
                    else
                        app.ThresholdBottomValue.Enable = 0;
                    end
            end

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
                app.UIFigure.Position = [100 100 540 300];
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
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', 90};
            app.Document.RowHeight = {22, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create FilterPanelLabel
            app.FilterPanelLabel = uilabel(app.Document);
            app.FilterPanelLabel.VerticalAlignment = 'bottom';
            app.FilterPanelLabel.FontSize = 10;
            app.FilterPanelLabel.Layout.Row = 1;
            app.FilterPanelLabel.Layout.Column = 1;
            app.FilterPanelLabel.Text = 'FILTRAGEM POR NÍVEIS';

            % Create FilterPanel
            app.FilterPanel = uipanel(app.Document);
            app.FilterPanel.AutoResizeChildren = 'off';
            app.FilterPanel.Layout.Row = 2;
            app.FilterPanel.Layout.Column = [1 2];

            % Create FilterGrid
            app.FilterGrid = uigridlayout(app.FilterPanel);
            app.FilterGrid.ColumnWidth = {14, 60, 90, '1x'};
            app.FilterGrid.RowHeight = {26, 22, 5, 22, 22, 5, 22, 22};
            app.FilterGrid.ColumnSpacing = 3;
            app.FilterGrid.RowSpacing = 5;
            app.FilterGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create Constant
            app.Constant = uicheckbox(app.FilterGrid);
            app.Constant.ValueChangedFcn = createCallbackFcn(app, @CheckBoxValueChanged, true);
            app.Constant.Text = 'Excluir varreduras em que a diferença absoluta entre os valores máximo e mínimo é inferior a um threshold.';
            app.Constant.WordWrap = 'on';
            app.Constant.FontSize = 11;
            app.Constant.Layout.Row = 1;
            app.Constant.Layout.Column = [1 4];
            app.Constant.Value = true;

            % Create ConstantLabel
            app.ConstantLabel = uilabel(app.FilterGrid);
            app.ConstantLabel.FontSize = 11;
            app.ConstantLabel.Layout.Row = 2;
            app.ConstantLabel.Layout.Column = 2;
            app.ConstantLabel.Text = 'Threshold:';

            % Create ConstantValue
            app.ConstantValue = uieditfield(app.FilterGrid, 'numeric');
            app.ConstantValue.FontSize = 11;
            app.ConstantValue.Layout.Row = 2;
            app.ConstantValue.Layout.Column = 3;
            app.ConstantValue.Value = 1e-05;

            % Create ThresholdTop
            app.ThresholdTop = uicheckbox(app.FilterGrid);
            app.ThresholdTop.ValueChangedFcn = createCallbackFcn(app, @CheckBoxValueChanged, true);
            app.ThresholdTop.Text = 'Excluir varreduras em que os valores de todas as suas amostras são inferiores a um threshold.';
            app.ThresholdTop.FontSize = 11;
            app.ThresholdTop.Layout.Row = 4;
            app.ThresholdTop.Layout.Column = [1 4];

            % Create ThresholdBottom
            app.ThresholdBottom = uicheckbox(app.FilterGrid);
            app.ThresholdBottom.ValueChangedFcn = createCallbackFcn(app, @CheckBoxValueChanged, true);
            app.ThresholdBottom.Text = 'Excluir varreduras em que os valores de todas as suas amostras são superiores a um threshold.';
            app.ThresholdBottom.FontSize = 11;
            app.ThresholdBottom.Layout.Row = 7;
            app.ThresholdBottom.Layout.Column = [1 4];

            % Create ThresholdTopLabel
            app.ThresholdTopLabel = uilabel(app.FilterGrid);
            app.ThresholdTopLabel.FontSize = 11;
            app.ThresholdTopLabel.Layout.Row = 5;
            app.ThresholdTopLabel.Layout.Column = 2;
            app.ThresholdTopLabel.Text = 'Threshold:';

            % Create ThresholdTopValue
            app.ThresholdTopValue = uieditfield(app.FilterGrid, 'numeric');
            app.ThresholdTopValue.FontSize = 11;
            app.ThresholdTopValue.Enable = 'off';
            app.ThresholdTopValue.Layout.Row = 5;
            app.ThresholdTopValue.Layout.Column = 3;
            app.ThresholdTopValue.Value = -100;

            % Create ThresholdBottomLabel
            app.ThresholdBottomLabel = uilabel(app.FilterGrid);
            app.ThresholdBottomLabel.FontSize = 11;
            app.ThresholdBottomLabel.Layout.Row = 8;
            app.ThresholdBottomLabel.Layout.Column = 2;
            app.ThresholdBottomLabel.Text = 'Threshold:';

            % Create ThresholdBottomValue
            app.ThresholdBottomValue = uieditfield(app.FilterGrid, 'numeric');
            app.ThresholdBottomValue.FontSize = 11;
            app.ThresholdBottomValue.Enable = 'off';
            app.ThresholdBottomValue.Layout.Row = 8;
            app.ThresholdBottomValue.Layout.Column = 3;
            app.ThresholdBottomValue.Value = -100;

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Layout.Row = 3;
            app.btnOK.Layout.Column = 2;
            app.btnOK.Text = 'OK';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockLevelFiltering_exported(Container, varargin)

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
