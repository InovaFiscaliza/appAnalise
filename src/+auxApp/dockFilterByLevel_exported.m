classdef dockFilterByLevel_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        OkButton                        matlab.ui.control.Button
        RadioGroup                      matlab.ui.container.ButtonGroup
        RemoveAllAboveThreshold         matlab.ui.control.NumericEditField
        RemoveAllAboveThresholdLabel    matlab.ui.control.Label
        RemoveAllAboveThresholdOption   matlab.ui.control.RadioButton
        RemoveAllBelowThreshold         matlab.ui.control.NumericEditField
        RemoveAllBelowThresholdLabel    matlab.ui.control.Label
        RemoveAllBelowThresholdOption   matlab.ui.control.RadioButton
        RemoveRangeBelowTolerance       matlab.ui.control.NumericEditField
        RemoveRangeBelowToleranceLabel  matlab.ui.control.Label
        RemoveRangeBelowToleranceOption  matlab.ui.control.RadioButton
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


    methods (Access = private)
        %-----------------------------------------------------------------%
        function [isValidFilterResult, matchMask, resultSummary] = computeFilterMatchIndexes(~, specData, filterSpecification)
            filterType = filterSpecification.Type;
            
            filterRuleStr = filterSpecification.Rule;
            filterRule = eval(filterRuleStr);

            matrix = specData.Data{2};

            switch filterType
                case 'RemoveRangeBelowTolerance'
                    [minLevel, maxLevel] = bounds(matrix);
                    matchMask = filterRule(minLevel, maxLevel);

                case {'RemoveAllBelowThreshold', 'RemoveAllAboveThreshold'}
                    matchMask = filterRule(matrix);

                otherwise
                    error('auxApp:dockFilterByTime:UnexpectedFilterType', 'Unexpected filter type "%s"', filterType)
            end
            
            numInitialSweeps = width(matrix);
            numFinalSweeps = numInitialSweeps - sum(matchMask);

            if numInitialSweeps == numFinalSweeps
                isValidFilterResult = false;
                resultSummary = sprintf([ ...
                    'O fluxo espectral analisado contém %d varreduras. O filtro do tipo "%s", com regra %s, foi aplicado, ' ...
                    'mas nenhuma varredura atende ao critério.' ...
                ], numInitialSweeps, filterType, filterRuleStr);
            
            elseif numFinalSweeps == 0
                isValidFilterResult = false;
                resultSummary = sprintf([ ...
                    'O fluxo espectral analisado contém %d varreduras. O filtro do tipo "%s", com regra %s, foi aplicado, ' ...
                    'mas todas as varreduras atendem ao critério.' ...
                ], numInitialSweeps, filterType, filterRuleStr);
            
            else
                isValidFilterResult = true;
                resultSummary = sprintf([ ...
                    'O fluxo espectral analisado contém %d varreduras. O filtro do tipo "%s", com regra %s, foi aplicado, ' ...
                    'resultando em %d varreduras.' ...
                ], numInitialSweeps, filterType, filterRuleStr, numFinalSweeps);
            end
        end
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
            
            rangeBelowToleranceElements = findobj(app.RadioGroup.Children, 'Tag', 'RemoveRangeBelowTolerance');
            allBelowThresholdElements   = findobj(app.RadioGroup.Children, 'Tag', 'RemoveAllBelowThreshold');
            allAboveThresholdElements   = findobj(app.RadioGroup.Children, 'Tag', 'RemoveAllAboveThreshold');

            switch app.RadioGroup.SelectedObject
                case app.RemoveRangeBelowToleranceOption
                    set(rangeBelowToleranceElements, 'Enable', 'on')
                    set(allBelowThresholdElements,   'Enable', 'off')
                    set(allAboveThresholdElements,   'Enable', 'off')

                case app.RemoveAllBelowThresholdOption
                    set(rangeBelowToleranceElements, 'Enable', 'off')
                    set(allBelowThresholdElements,   'Enable', 'on')
                    set(allAboveThresholdElements,   'Enable', 'off')

                case app.RemoveAllAboveThresholdOption
                    set(rangeBelowToleranceElements, 'Enable', 'off')
                    set(allBelowThresholdElements,   'Enable', 'off')
                    set(allAboveThresholdElements,   'Enable', 'on')
            end

        end

        % Button pushed function: OkButton
        function onOkButtonClicked(app, event)
            
            flowIdx = app.inputArgs.flowIdx;
            specData = app.mainApp.specData(flowIdx);

            filterSpecification = struct('Action', 'FilterByLevel', 'Type', '', 'Rule', '', 'Result', '');

            switch app.RadioGroup.SelectedObject
                case app.RemoveRangeBelowToleranceOption
                    filterSpecification.Type = 'RemoveRangeBelowTolerance';
                    filterSpecification.Rule = sprintf('@(minLevel, maxLevel) maxLevel-minLevel < %d', app.RemoveRangeBelowTolerance.Value);

                case app.RemoveAllBelowThresholdOption
                    filterSpecification.Type = 'RemoveAllBelowThreshold';
                    filterSpecification.Rule = sprintf('@(matrix) all(matrix < %d, 1)', app.RemoveAllBelowThreshold.Value);

                case app.RemoveAllAboveThresholdOption
                    filterSpecification.Type = 'RemoveAllAboveThreshold';
                    filterSpecification.Rule = sprintf('@(matrix) all(matrix > %d, 1)', app.RemoveAllAboveThreshold.Value);
            end

            [isValidFilterResult, matchMask, resultSummary] = computeFilterMatchIndexes(app, specData, filterSpecification);

            if isValidFilterResult
                questionMsg = sprintf('%s<br><br>Deseja aplicar esse filtro?', resultSummary);
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end

                filterSpecification.Result = replace(resultSummary, 'contém', 'continha');
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onFilterByLevelRequested', flowIdx, filterSpecification, matchMask, 'remove')

            else
                warningMsg = sprintf('%s<br><br>Por essa razão, não se pode aplicar esse filtro.', resultSummary);
                ui.Dialog(app.UIFigure, 'warning', warningMsg);
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

            % Create RemoveRangeBelowToleranceOption
            app.RemoveRangeBelowToleranceOption = uiradiobutton(app.RadioGroup);
            app.RemoveRangeBelowToleranceOption.Text = 'Excluir varreduras em que a diferença absoluta entre os valores máximo e mínimo das amostras seja inferior a uma tolerância.';
            app.RemoveRangeBelowToleranceOption.WordWrap = 'on';
            app.RemoveRangeBelowToleranceOption.FontSize = 11;
            app.RemoveRangeBelowToleranceOption.Position = [11 169 495 28];
            app.RemoveRangeBelowToleranceOption.Value = true;

            % Create RemoveRangeBelowToleranceLabel
            app.RemoveRangeBelowToleranceLabel = uilabel(app.RadioGroup);
            app.RemoveRangeBelowToleranceLabel.Tag = 'RemoveRangeBelowTolerance';
            app.RemoveRangeBelowToleranceLabel.FontSize = 11;
            app.RemoveRangeBelowToleranceLabel.Position = [28 141 60 22];
            app.RemoveRangeBelowToleranceLabel.Text = 'Tolerância:';

            % Create RemoveRangeBelowTolerance
            app.RemoveRangeBelowTolerance = uieditfield(app.RadioGroup, 'numeric');
            app.RemoveRangeBelowTolerance.Limits = [1 100];
            app.RemoveRangeBelowTolerance.RoundFractionalValues = 'on';
            app.RemoveRangeBelowTolerance.ValueDisplayFormat = '%d';
            app.RemoveRangeBelowTolerance.Tag = 'RemoveRangeBelowTolerance';
            app.RemoveRangeBelowTolerance.FontSize = 11;
            app.RemoveRangeBelowTolerance.Position = [91 141 90 22];
            app.RemoveRangeBelowTolerance.Value = 1;

            % Create RemoveAllBelowThresholdOption
            app.RemoveAllBelowThresholdOption = uiradiobutton(app.RadioGroup);
            app.RemoveAllBelowThresholdOption.Text = 'Excluir varreduras em que todos os valores de suas amostras sejam inferiores a um limiar.';
            app.RemoveAllBelowThresholdOption.FontSize = 11;
            app.RemoveAllBelowThresholdOption.Position = [11 101 491 22];

            % Create RemoveAllBelowThresholdLabel
            app.RemoveAllBelowThresholdLabel = uilabel(app.RadioGroup);
            app.RemoveAllBelowThresholdLabel.Tag = 'RemoveAllBelowThreshold';
            app.RemoveAllBelowThresholdLabel.FontSize = 11;
            app.RemoveAllBelowThresholdLabel.Enable = 'off';
            app.RemoveAllBelowThresholdLabel.Position = [28 77 60 22];
            app.RemoveAllBelowThresholdLabel.Text = 'Limiar:';

            % Create RemoveAllBelowThreshold
            app.RemoveAllBelowThreshold = uieditfield(app.RadioGroup, 'numeric');
            app.RemoveAllBelowThreshold.RoundFractionalValues = 'on';
            app.RemoveAllBelowThreshold.ValueDisplayFormat = '%d';
            app.RemoveAllBelowThreshold.Tag = 'RemoveAllBelowThreshold';
            app.RemoveAllBelowThreshold.FontSize = 11;
            app.RemoveAllBelowThreshold.Enable = 'off';
            app.RemoveAllBelowThreshold.Position = [91 77 90 22];
            app.RemoveAllBelowThreshold.Value = -100;

            % Create RemoveAllAboveThresholdOption
            app.RemoveAllAboveThresholdOption = uiradiobutton(app.RadioGroup);
            app.RemoveAllAboveThresholdOption.Text = 'Excluir varreduras em que todos os valores de suas amostras sejam superiores a um limiar.';
            app.RemoveAllAboveThresholdOption.FontSize = 11;
            app.RemoveAllAboveThresholdOption.Position = [11 37 491 22];

            % Create RemoveAllAboveThresholdLabel
            app.RemoveAllAboveThresholdLabel = uilabel(app.RadioGroup);
            app.RemoveAllAboveThresholdLabel.Tag = 'RemoveAllAboveThreshold';
            app.RemoveAllAboveThresholdLabel.FontSize = 11;
            app.RemoveAllAboveThresholdLabel.Enable = 'off';
            app.RemoveAllAboveThresholdLabel.Position = [28 10 60 22];
            app.RemoveAllAboveThresholdLabel.Text = 'Limiar:';

            % Create RemoveAllAboveThreshold
            app.RemoveAllAboveThreshold = uieditfield(app.RadioGroup, 'numeric');
            app.RemoveAllAboveThreshold.RoundFractionalValues = 'on';
            app.RemoveAllAboveThreshold.ValueDisplayFormat = '%d';
            app.RemoveAllAboveThreshold.Tag = 'RemoveAllAboveThreshold';
            app.RemoveAllAboveThreshold.FontSize = 11;
            app.RemoveAllAboveThreshold.Enable = 'off';
            app.RemoveAllAboveThreshold.Position = [91 10 90 22];

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
