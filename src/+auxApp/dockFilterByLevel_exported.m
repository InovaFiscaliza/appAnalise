classdef dockFilterByLevel_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        OkButton                        matlab.ui.control.Button
        RadioGroup                      matlab.ui.container.ButtonGroup
        AllSamplesAboveThreshold        matlab.ui.control.NumericEditField
        AllSamplesAboveThresholdLabel   matlab.ui.control.Label
        AllSamplesAboveThresholdOption  matlab.ui.control.RadioButton
        AllSamplesBelowThreshold        matlab.ui.control.NumericEditField
        AllSamplesBelowThresholdLabel   matlab.ui.control.Label
        AllSamplesBelowThresholdOption  matlab.ui.control.RadioButton
        SampleDiffBelowTolerance        matlab.ui.control.NumericEditField
        SampleDiffBelowToleranceLabel   matlab.ui.control.Label
        SampleDiffBelowToleranceOption  matlab.ui.control.RadioButton
        Title                           matlab.ui.control.Label
        TitleIcon                       matlab.ui.control.Image
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
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                app.inputArgs = struct('context', context, 'flowIdx', flowIdx);
                
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
            
            sampleDiffBelowToleranceElements = findobj(app.RadioGroup.Children, 'Tag', 'SampleDiffBelowTolerance');
            allSamplesBelowThresholdElements = findobj(app.RadioGroup.Children, 'Tag', 'AllSamplesBelowThreshold');
            allSamplesAboveThresholdElements = findobj(app.RadioGroup.Children, 'Tag', 'AllSamplesAboveThreshold');

            switch app.RadioGroup.SelectedObject
                case app.SampleDiffBelowToleranceOption
                    set(sampleDiffBelowToleranceElements, 'Enable', 'on')
                    set(allSamplesBelowThresholdElements, 'Enable', 'off')
                    set(allSamplesAboveThresholdElements, 'Enable', 'off')

                case app.AllSamplesBelowThresholdOption
                    set(sampleDiffBelowToleranceElements, 'Enable', 'off')
                    set(allSamplesBelowThresholdElements, 'Enable', 'on')
                    set(allSamplesAboveThresholdElements, 'Enable', 'off')

                case app.AllSamplesAboveThresholdOption
                    set(sampleDiffBelowToleranceElements, 'Enable', 'off')
                    set(allSamplesBelowThresholdElements, 'Enable', 'off')
                    set(allSamplesAboveThresholdElements, 'Enable', 'on')
            end

        end

        % Button pushed function: OkButton
        function onOkButtonClicked(app, event)
            
            pushedButtonTag = event.Source.Tag;
            switch pushedButtonTag
                case 'OK'
                    fcnHandleStr  = '@(matrix, minLevel, maxLevel)';
                    fcnHandleFlag = false;
                    
                    if app.Constant.Value
                        fcnHandleStr  = [fcnHandleStr, sprintf(' maxLevel-minLevel < %f', app.SampleDiffBelowTolerance.Value)];
                        fcnHandleFlag = true;
                    end

                    if app.ThresholdTop.Value
                        if fcnHandleFlag
                            fcnHandleStr = [fcnHandleStr, ' |'];
                        end
                        fcnHandleStr  = [fcnHandleStr, sprintf(' all(matrix < %.1f, 1)', app.AllSamplesBelowThreshold.Value)];
                        fcnHandleFlag = true;
                    end                    

                    if app.ThresholdBottom.Value
                        if fcnHandleFlag
                            fcnHandleStr = [fcnHandleStr, ' |'];
                        end
                        fcnHandleStr  = [fcnHandleStr, sprintf(' all(matrix > %.1f, 1)', app.AllSamplesAboveThreshold.Value)];
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
                app.UIFigure.Position = [100 100 550 308];
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
            app.GridLayout.ColumnWidth = {18, 372, 110};
            app.GridLayout.RowHeight = {17, 5, 212, 10, 24};
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
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 2;
            app.Title.Text = 'FILTRAGEM DE NÍVEL';

            % Create RadioGroup
            app.RadioGroup = uibuttongroup(app.GridLayout);
            app.RadioGroup.AutoResizeChildren = 'off';
            app.RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @onRadioGroupSelectionChanged, true);
            app.RadioGroup.BackgroundColor = [1 1 1];
            app.RadioGroup.Layout.Row = 3;
            app.RadioGroup.Layout.Column = [1 3];

            % Create SampleDiffBelowToleranceOption
            app.SampleDiffBelowToleranceOption = uiradiobutton(app.RadioGroup);
            app.SampleDiffBelowToleranceOption.Text = 'Excluir varreduras em que a diferença absoluta entre os valores máximo e mínimo das amostras seja inferior a uma tolerância.';
            app.SampleDiffBelowToleranceOption.WordWrap = 'on';
            app.SampleDiffBelowToleranceOption.FontSize = 11;
            app.SampleDiffBelowToleranceOption.Position = [11 169 495 28];
            app.SampleDiffBelowToleranceOption.Value = true;

            % Create SampleDiffBelowToleranceLabel
            app.SampleDiffBelowToleranceLabel = uilabel(app.RadioGroup);
            app.SampleDiffBelowToleranceLabel.Tag = 'SampleDiffBelowTolerance';
            app.SampleDiffBelowToleranceLabel.FontSize = 11;
            app.SampleDiffBelowToleranceLabel.Position = [28 141 60 22];
            app.SampleDiffBelowToleranceLabel.Text = 'Tolerância:';

            % Create SampleDiffBelowTolerance
            app.SampleDiffBelowTolerance = uieditfield(app.RadioGroup, 'numeric');
            app.SampleDiffBelowTolerance.Tag = 'SampleDiffBelowTolerance';
            app.SampleDiffBelowTolerance.FontSize = 11;
            app.SampleDiffBelowTolerance.Position = [91 141 90 22];
            app.SampleDiffBelowTolerance.Value = 1e-05;

            % Create AllSamplesBelowThresholdOption
            app.AllSamplesBelowThresholdOption = uiradiobutton(app.RadioGroup);
            app.AllSamplesBelowThresholdOption.Text = 'Excluir varreduras em que todos os valores de suas amostras sejam inferiores a um limiar.';
            app.AllSamplesBelowThresholdOption.FontSize = 11;
            app.AllSamplesBelowThresholdOption.Position = [11 101 491 22];

            % Create AllSamplesBelowThresholdLabel
            app.AllSamplesBelowThresholdLabel = uilabel(app.RadioGroup);
            app.AllSamplesBelowThresholdLabel.Tag = 'AllSamplesBelowThreshold';
            app.AllSamplesBelowThresholdLabel.FontSize = 11;
            app.AllSamplesBelowThresholdLabel.Enable = 'off';
            app.AllSamplesBelowThresholdLabel.Position = [28 77 60 22];
            app.AllSamplesBelowThresholdLabel.Text = 'Limiar:';

            % Create AllSamplesBelowThreshold
            app.AllSamplesBelowThreshold = uieditfield(app.RadioGroup, 'numeric');
            app.AllSamplesBelowThreshold.Tag = 'AllSamplesBelowThreshold';
            app.AllSamplesBelowThreshold.FontSize = 11;
            app.AllSamplesBelowThreshold.Enable = 'off';
            app.AllSamplesBelowThreshold.Position = [91 77 90 22];
            app.AllSamplesBelowThreshold.Value = -100;

            % Create AllSamplesAboveThresholdOption
            app.AllSamplesAboveThresholdOption = uiradiobutton(app.RadioGroup);
            app.AllSamplesAboveThresholdOption.Text = 'Excluir varreduras em que todos os valores de suas amostras sejam superiores a um limiar.';
            app.AllSamplesAboveThresholdOption.FontSize = 11;
            app.AllSamplesAboveThresholdOption.Position = [11 37 491 22];

            % Create AllSamplesAboveThresholdLabel
            app.AllSamplesAboveThresholdLabel = uilabel(app.RadioGroup);
            app.AllSamplesAboveThresholdLabel.Tag = 'AllSamplesAboveThreshold';
            app.AllSamplesAboveThresholdLabel.FontSize = 11;
            app.AllSamplesAboveThresholdLabel.Enable = 'off';
            app.AllSamplesAboveThresholdLabel.Position = [28 10 60 22];
            app.AllSamplesAboveThresholdLabel.Text = 'Limiar:';

            % Create AllSamplesAboveThreshold
            app.AllSamplesAboveThreshold = uieditfield(app.RadioGroup, 'numeric');
            app.AllSamplesAboveThreshold.Tag = 'AllSamplesAboveThreshold';
            app.AllSamplesAboveThreshold.FontSize = 11;
            app.AllSamplesAboveThreshold.Enable = 'off';
            app.AllSamplesAboveThreshold.Position = [91 10 90 22];

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onOkButtonClicked, true);
            app.OkButton.Tag = 'OK';
            app.OkButton.Icon = 'Add_16.png';
            app.OkButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.OkButton.FontSize = 11;
            app.OkButton.Layout.Row = 5;
            app.OkButton.Layout.Column = 3;
            app.OkButton.Text = 'Aplicar filtro';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockFilterByLevel_exported(Container, varargin)

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
