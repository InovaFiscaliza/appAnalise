classdef dockFilterByTime_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        OkButton            matlab.ui.control.Button
        FilterValuesPanel   matlab.ui.container.Panel
        FilterValuesGrid    matlab.ui.container.GridLayout
        Saturday            matlab.ui.control.CheckBox
        Friday              matlab.ui.control.CheckBox
        Thursday            matlab.ui.control.CheckBox
        Wednesday           matlab.ui.control.CheckBox
        Tuesday             matlab.ui.control.CheckBox
        Monday              matlab.ui.control.CheckBox
        Sunday              matlab.ui.control.CheckBox
        MinuteStop          matlab.ui.control.Spinner
        HourStop            matlab.ui.control.Spinner
        DateStop            matlab.ui.control.DatePicker
        MinuteStart         matlab.ui.control.Spinner
        HourStart           matlab.ui.control.Spinner
        DateStart           matlab.ui.control.DatePicker
        RadioGroup          matlab.ui.container.ButtonGroup
        DayOfTheWeekOption  matlab.ui.control.RadioButton
        OnlyTimeOption      matlab.ui.control.RadioButton
        OnlyDateOption      matlab.ui.control.RadioButton
        DateTimeOption      matlab.ui.control.RadioButton
        Title               matlab.ui.control.Label
        TitleIcon           matlab.ui.control.Image
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
        function updateDatePickers(app, flowIdx)
            observationStartDate = app.mainApp.specData(flowIdx).Data{1}(1);
            observationStopDate  = app.mainApp.specData(flowIdx).Data{1}(end);

            app.DateStart.Limits = [observationStartDate, observationStopDate];
            app.DateStop.Limits  = app.DateStart.Limits;
            app.DateStart.Value  = app.DateStart.Limits(1);
            app.DateStop.Value   = app.DateStop.Limits(2);
        end

        %-----------------------------------------------------------------%
        function [isValidFilterResult, matchMask, resultSummary] = computeFilterMatchIndexes(~, specData, filterSpecification)
            filterType = filterSpecification.Type;
            filterValue = filterSpecification.Value;
            filterValueStr = "[" + strjoin(string(filterValue), ', ') + "]";

            switch filterType
                case {'Date+Time', 'Date'}
                    valuesToFilter = specData.Data{1};
                    matchMask = (valuesToFilter >= filterValue(1)) & (valuesToFilter <= filterValue(2));

                case 'Time'
                    valuesToFilter = specData.Data{1}.Hour + specData.Data{1}.Minute / 60;
                    matchMask = (valuesToFilter >= filterValue(1)) & (valuesToFilter <= filterValue(2));

                case 'DayOfTheWeek'
                    valuesToFilter = weekday(specData.Data{1});
                    matchMask = ismember(valuesToFilter, filterValue);

                otherwise
                    error('auxApp:dockFilterByTime:UnexpectedFilterType', 'Unexpected filter type "%s"', filterType)
            end
            
            numInitialSweeps = numel(specData.Data{1});
            numFinalSweeps = sum(matchMask);

            if numInitialSweeps == numFinalSweeps
                isValidFilterResult = false;
                resultSummary = sprintf([ ...
                    'O fluxo espectral analisado contém %d varreduras. O filtro do tipo "%s", com valores %s, foi aplicado, ' ...
                    'mas todas as varreduras atendem ao critério.' ...
                ], numInitialSweeps, filterType, filterValueStr);
            
            elseif numFinalSweeps == 0
                isValidFilterResult = false;
                resultSummary = sprintf([ ...
                    'O fluxo espectral analisado contém %d varreduras. O filtro do tipo "%s", com valores %s, foi aplicado, ' ...
                    'mas nenhuma varredura atende ao critério.' ...
                ], numInitialSweeps, filterType, filterValueStr);
            
            else
                isValidFilterResult = true;
                resultSummary = sprintf([ ...
                    'O fluxo espectral analisado contém %d varreduras. O filtro do tipo "%s", com valores %s, foi aplicado, ' ...
                    'resultando em %d varreduras.' ...
                ], numInitialSweeps, filterType, filterValueStr, numFinalSweeps);
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
                updateDatePickers(app, flowIdx)
                
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
            
            dateElements = findobj(app.FilterValuesGrid.Children, 'Type', 'uidatepicker');
            timeElements = findobj(app.FilterValuesGrid.Children, 'Type', 'uispinner');
            daysElements = findobj(app.FilterValuesGrid.Children, 'Type', 'uicheckbox');

            switch app.RadioGroup.SelectedObject
                case app.DateTimeOption
                    set(dateElements, 'Visible', 'on', 'Enable', 'on')
                    set(timeElements, 'Visible', 'on', 'Enable', 'on')
                    set(daysElements, 'Visible', 'off')

                case app.OnlyDateOption
                    set(dateElements, 'Visible', 'on', 'Enable', 'on')
                    set(timeElements, 'Visible', 'on', 'Enable', 'off')
                    set(daysElements, 'Visible', 'off')

                    app.HourStart.Value   = 0;
                    app.MinuteStart.Value = 0;
                    app.HourStop.Value    = 23;
                    app.MinuteStop.Value  = 59;

                case app.OnlyTimeOption
                    set(dateElements, 'Visible', 'on', 'Enable', 'off')
                    set(timeElements, 'Visible', 'on', 'Enable', 'on')
                    set(daysElements, 'Visible', 'off')

                    app.DateStart.Value = app.DateStart.Limits(1);
                    app.DateStop.Value  = app.DateStop.Limits(2);

                case app.DayOfTheWeekOption
                    set(dateElements, 'Visible', 'off')
                    set(timeElements, 'Visible', 'off')
                    set(daysElements, 'Visible', 'on')
            end
            
        end

        % Button pushed function: OkButton
        function onOkButtonClicked(app, event)
            
            flowIdx = app.inputArgs.flowIdx;
            specData = app.mainApp.specData(flowIdx);

            try
                selectedButton = app.RadioGroup.SelectedObject;

                switch selectedButton
                    case {app.DateTimeOption, app.OnlyDateOption}
                        beginTimestamp = app.DateStart.Value + hours(app.HourStart.Value) + minutes(app.MinuteStart.Value);
                        endTimestamp   = app.DateStop.Value + hours(app.HourStop.Value) + minutes(app.MinuteStop.Value);

                        beginTimestamp.Format = 'dd/MM/yyyy HH:mm';
                        endTimestamp.Format   = 'dd/MM/yyyy HH:mm';

                        if isnat(beginTimestamp) || isnat(endTimestamp) || (beginTimestamp > endTimestamp)
                            error('Período de observação inválido.')
                        end
                        filterSpecification = struct('Action', 'FilterByTime', 'Type', selectedButton.Tag, 'Value', [beginTimestamp, endTimestamp]);
    
                    case app.OnlyTimeOption
                        beginHour = round(app.HourStart.Value + app.MinuteStart.Value / 60, 3);
                        endHour   = round(app.HourStop.Value  + app.MinuteStop.Value  / 60, 3);
                        
                        if beginHour >= endHour
                            error('A hora de início não pode ser igual ou posterior à hora de fim.')
                        end

                        filterSpecification = struct('Action', 'FilterByTime', 'Type', selectedButton.Tag, 'Value', [beginHour, endHour]);
    
                    case app.DayOfTheWeekOption
                        daysElements = findobj(app.FilterValuesGrid.Children, 'Type', 'uicheckbox', 'Value', true);
                        
                        if isempty(daysElements)
                            error('Deve ser selecionado ao menos um dia.')
                        elseif numel(daysElements) == 7
                            error('Todos os dias estão selecionados, portanto o filtro não terá efeito.')
                        end
    
                        daysOfTheWeek = str2double({daysElements.Tag});
                        filterSpecification = struct('Action', 'FilterByTime', 'Type', selectedButton.Tag, 'Value', daysOfTheWeek);
                end

                [isValidFilterResult, matchMask, resultSummary] = computeFilterMatchIndexes(app, specData, filterSpecification);

                if isValidFilterResult
                    questionMsg = sprintf('%s<br><br>Deseja aplicar esse filtro?', resultSummary);
                    userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        return
                    end

                    filterSpecification.Result = replace(resultSummary, 'contém', 'continha');
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onFilterByTimeRequested', flowIdx, filterSpecification, matchMask)

                else
                    warningMsg = sprintf('%s<br><br>Por essa razão, não se pode aplicar esse filtro.', resultSummary);
                    ui.Dialog(app.UIFigure, 'warning', warningMsg);
                end

            catch ME
                ui.Dialog(app.UIFigure, 'warning', ME.message);
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
                app.UIFigure.Position = [100 100 452 208];
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
            app.GridLayout.ColumnWidth = {18, 274, 110};
            app.GridLayout.RowHeight = {17, 5, 34, 5, 73, 10, 24};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TitleIcon
            app.TitleIcon = uiimage(app.GridLayout);
            app.TitleIcon.ScaleMethod = 'none';
            app.TitleIcon.Layout.Row = 1;
            app.TitleIcon.Layout.Column = 1;
            app.TitleIcon.ImageSource = 'calendar.svg';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = [2 3];
            app.Title.Text = 'FILTRAGEM TEMPORAL';

            % Create RadioGroup
            app.RadioGroup = uibuttongroup(app.GridLayout);
            app.RadioGroup.AutoResizeChildren = 'off';
            app.RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @onRadioGroupSelectionChanged, true);
            app.RadioGroup.BackgroundColor = [1 1 1];
            app.RadioGroup.Layout.Row = 3;
            app.RadioGroup.Layout.Column = [1 3];

            % Create DateTimeOption
            app.DateTimeOption = uiradiobutton(app.RadioGroup);
            app.DateTimeOption.Tag = 'Date+Time';
            app.DateTimeOption.Text = 'Data e hora';
            app.DateTimeOption.FontSize = 11;
            app.DateTimeOption.Position = [11 6 79 22];
            app.DateTimeOption.Value = true;

            % Create OnlyDateOption
            app.OnlyDateOption = uiradiobutton(app.RadioGroup);
            app.OnlyDateOption.Tag = 'Date';
            app.OnlyDateOption.Text = 'Data';
            app.OnlyDateOption.FontSize = 11;
            app.OnlyDateOption.Position = [120 6 65 22];

            % Create OnlyTimeOption
            app.OnlyTimeOption = uiradiobutton(app.RadioGroup);
            app.OnlyTimeOption.Tag = 'Time';
            app.OnlyTimeOption.Text = 'Hora';
            app.OnlyTimeOption.FontSize = 11;
            app.OnlyTimeOption.Position = [209 6 65 22];

            % Create DayOfTheWeekOption
            app.DayOfTheWeekOption = uiradiobutton(app.RadioGroup);
            app.DayOfTheWeekOption.Tag = 'DayOfTheWeek';
            app.DayOfTheWeekOption.Text = 'Dia da semana';
            app.DayOfTheWeekOption.FontSize = 11;
            app.DayOfTheWeekOption.Position = [303 6 96 22];

            % Create FilterValuesPanel
            app.FilterValuesPanel = uipanel(app.GridLayout);
            app.FilterValuesPanel.AutoResizeChildren = 'off';
            app.FilterValuesPanel.Layout.Row = 5;
            app.FilterValuesPanel.Layout.Column = [1 3];

            % Create FilterValuesGrid
            app.FilterValuesGrid = uigridlayout(app.FilterValuesPanel);
            app.FilterValuesGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.FilterValuesGrid.RowHeight = {22, 22};
            app.FilterValuesGrid.RowSpacing = 5;
            app.FilterValuesGrid.BackgroundColor = [1 1 1];

            % Create DateStart
            app.DateStart = uidatepicker(app.FilterValuesGrid);
            app.DateStart.DisplayFormat = 'dd/MM/uuuu';
            app.DateStart.FontSize = 11;
            app.DateStart.Layout.Row = 1;
            app.DateStart.Layout.Column = [1 2];

            % Create HourStart
            app.HourStart = uispinner(app.FilterValuesGrid);
            app.HourStart.Limits = [0 23];
            app.HourStart.RoundFractionalValues = 'on';
            app.HourStart.ValueDisplayFormat = '%.0f';
            app.HourStart.HorizontalAlignment = 'center';
            app.HourStart.FontSize = 11;
            app.HourStart.Layout.Row = 2;
            app.HourStart.Layout.Column = 1;

            % Create MinuteStart
            app.MinuteStart = uispinner(app.FilterValuesGrid);
            app.MinuteStart.Step = 10;
            app.MinuteStart.Limits = [0 59];
            app.MinuteStart.RoundFractionalValues = 'on';
            app.MinuteStart.ValueDisplayFormat = '%.0f';
            app.MinuteStart.HorizontalAlignment = 'center';
            app.MinuteStart.FontSize = 11;
            app.MinuteStart.Layout.Row = 2;
            app.MinuteStart.Layout.Column = 2;

            % Create DateStop
            app.DateStop = uidatepicker(app.FilterValuesGrid);
            app.DateStop.DisplayFormat = 'dd/MM/uuuu';
            app.DateStop.FontSize = 11;
            app.DateStop.Layout.Row = 1;
            app.DateStop.Layout.Column = [3 4];

            % Create HourStop
            app.HourStop = uispinner(app.FilterValuesGrid);
            app.HourStop.Limits = [0 23];
            app.HourStop.RoundFractionalValues = 'on';
            app.HourStop.ValueDisplayFormat = '%.0f';
            app.HourStop.HorizontalAlignment = 'center';
            app.HourStop.FontSize = 11;
            app.HourStop.Layout.Row = 2;
            app.HourStop.Layout.Column = 3;
            app.HourStop.Value = 23;

            % Create MinuteStop
            app.MinuteStop = uispinner(app.FilterValuesGrid);
            app.MinuteStop.Step = 10;
            app.MinuteStop.Limits = [0 59];
            app.MinuteStop.RoundFractionalValues = 'on';
            app.MinuteStop.ValueDisplayFormat = '%.0f';
            app.MinuteStop.HorizontalAlignment = 'center';
            app.MinuteStop.FontSize = 11;
            app.MinuteStop.Layout.Row = 2;
            app.MinuteStop.Layout.Column = 4;
            app.MinuteStop.Value = 59;

            % Create Sunday
            app.Sunday = uicheckbox(app.FilterValuesGrid);
            app.Sunday.Tag = '1';
            app.Sunday.Visible = 'off';
            app.Sunday.Text = 'Domingo';
            app.Sunday.FontSize = 11;
            app.Sunday.Layout.Row = 1;
            app.Sunday.Layout.Column = 1;
            app.Sunday.Value = true;

            % Create Monday
            app.Monday = uicheckbox(app.FilterValuesGrid);
            app.Monday.Tag = '2';
            app.Monday.Visible = 'off';
            app.Monday.Text = 'Segunda-feira';
            app.Monday.FontSize = 11;
            app.Monday.Layout.Row = 2;
            app.Monday.Layout.Column = 1;
            app.Monday.Value = true;

            % Create Tuesday
            app.Tuesday = uicheckbox(app.FilterValuesGrid);
            app.Tuesday.Tag = '3';
            app.Tuesday.Visible = 'off';
            app.Tuesday.Text = 'Terça-feira';
            app.Tuesday.FontSize = 11;
            app.Tuesday.Layout.Row = 1;
            app.Tuesday.Layout.Column = 2;
            app.Tuesday.Value = true;

            % Create Wednesday
            app.Wednesday = uicheckbox(app.FilterValuesGrid);
            app.Wednesday.Tag = '4';
            app.Wednesday.Visible = 'off';
            app.Wednesday.Text = 'Quarta-feira';
            app.Wednesday.FontSize = 11;
            app.Wednesday.Layout.Row = 2;
            app.Wednesday.Layout.Column = 2;
            app.Wednesday.Value = true;

            % Create Thursday
            app.Thursday = uicheckbox(app.FilterValuesGrid);
            app.Thursday.Tag = '5';
            app.Thursday.Visible = 'off';
            app.Thursday.Text = 'Quinta-feira';
            app.Thursday.FontSize = 11;
            app.Thursday.Layout.Row = 1;
            app.Thursday.Layout.Column = 3;
            app.Thursday.Value = true;

            % Create Friday
            app.Friday = uicheckbox(app.FilterValuesGrid);
            app.Friday.Tag = '6';
            app.Friday.Visible = 'off';
            app.Friday.Text = 'Sexta-feira';
            app.Friday.FontSize = 11;
            app.Friday.Layout.Row = 2;
            app.Friday.Layout.Column = 3;
            app.Friday.Value = true;

            % Create Saturday
            app.Saturday = uicheckbox(app.FilterValuesGrid);
            app.Saturday.Tag = '7';
            app.Saturday.Visible = 'off';
            app.Saturday.Text = 'Sábado';
            app.Saturday.FontSize = 11;
            app.Saturday.Layout.Row = 1;
            app.Saturday.Layout.Column = 4;
            app.Saturday.Value = true;

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onOkButtonClicked, true);
            app.OkButton.Tag = 'OK';
            app.OkButton.Icon = 'Add_16.png';
            app.OkButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.OkButton.FontSize = 11;
            app.OkButton.Layout.Row = 7;
            app.OkButton.Layout.Column = 3;
            app.OkButton.Text = 'Aplicar filtro';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockFilterByTime_exported(Container, varargin)

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
