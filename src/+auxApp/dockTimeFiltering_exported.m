classdef dockTimeFiltering_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        Document              matlab.ui.container.GridLayout
        filterAddImage        matlab.ui.control.Image
        threadInfo            matlab.ui.control.Label
        btnOK                 matlab.ui.control.Button
        filterTree            matlab.ui.container.Tree
        filterValuePanel      matlab.ui.container.Panel
        filterValueGrid       matlab.ui.container.GridLayout
        DayOfWeek_7           matlab.ui.control.CheckBox
        DayOfWeek_6           matlab.ui.control.CheckBox
        DayOfWeek_5           matlab.ui.control.CheckBox
        DayOfWeek_4           matlab.ui.control.CheckBox
        DayOfWeek_3           matlab.ui.control.CheckBox
        DayOfWeek_2           matlab.ui.control.CheckBox
        DayOfWeek_1           matlab.ui.control.CheckBox
        specificTime2_Minute  matlab.ui.control.Spinner
        specificTime2_Hour    matlab.ui.control.Spinner
        specificTime2_Date    matlab.ui.control.DatePicker
        specificTime1_Minute  matlab.ui.control.Spinner
        specificTime1_Hour    matlab.ui.control.Spinner
        specificTime1_Date    matlab.ui.control.DatePicker
        filterTypePanel       matlab.ui.container.ButtonGroup
        filterType_DayOfWeek  matlab.ui.control.RadioButton
        filterType_Time       matlab.ui.control.RadioButton
        filterType_Date       matlab.ui.control.RadioButton
        filterType_DateTime   matlab.ui.control.RadioButton
        filterTypePanelLabel  matlab.ui.control.Label
        HTMLLabel             matlab.ui.control.Label
        btnClose              matlab.ui.control.Image
        ContextMenu           matlab.ui.container.ContextMenu
        btnDelete             matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked      = true
        jsBackDoor

        mainApp
        specData

        filterSummary = table('Size',          [0, 4],                                 ...
                              'VariableTypes', {'uint16', 'uint32', 'uint32', 'cell'}, ...
                              'VariableNames', {'idxThread', 'RawSweeps', 'FilteredSweeps', 'FilterLogicalArray'})
        
        filterTable   = table('Size',          [0, 2],           ...
                              'VariableTypes', {'cell', 'cell'}, ...
                              'VariableNames', {'Type', 'Value'})
    end


    methods
        function ipcSecundaryJSEventsHandler(app, event, varargin)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        startup_Controller(app, varargin{:})
                    case 'auxApp.dockTimeFiltering.filterTree'
                        btnDeleteSelected(app)
                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app, varargin)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appEngine.util.jsBackDoorHTMLSource(),                       ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt, varargin{:}), ...
                                                  "Visible",              "off");
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app)
            elToModify = {app.filterTree, app.threadInfo};
            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
            if ~isempty(elDataTag)
                appName = class(app);

                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {                                                                                                             ...
                    struct('appName', appName, 'dataTag', elDataTag{1}, 'listener', struct('componentName', 'auxApp.dockTimeFiltering.filterTree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                });

                ui.TextView.startup(app.jsBackDoor, elToModify{2}, appName);
            end            
        end
    end

    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO
        %-----------------------------------------------------------------%
        function startup_timerCreation(app, idxThreads)            
            % A criação desse timer tem como objetivo garantir uma renderização 
            % mais rápida dos componentes principais da GUI, possibilitando a 
            % visualização da sua tela inicialpelo usuário. Trata-se de aspecto 
            % essencial quando o app é compilado como webapp.

            app.timerObj = timer("ExecutionMode", "fixedSpacing", ...
                                 "StartDelay",    1.5,            ...
                                 "Period",        .1,             ...
                                 "TimerFcn",      @(~,~)app.startup_timerFcn(idxThreads));
            start(app.timerObj)
        end

        %-----------------------------------------------------------------%
        function startup_timerFcn(app, idxThreads)
            if ui.FigureRenderStatus(app.UIFigure)
                stop(app.timerObj)
                delete(app.timerObj)
                
                jsBackDoor_Initialization(app, idxThreads)
            end
        end

        %-----------------------------------------------------------------%
        function startup_Controller(app, idxThreads)
            drawnow
            jsBackDoor_Customizations(app)

            observationStartDate = datetime.empty;
            observationStopDate  = datetime.empty;
            for ii = idxThreads
                app.filterSummary(end+1, 1:3) = {ii, numel(app.specData(ii).Data{1}), numel(app.specData(ii).Data{1})};
                
                observationStartDate(end+1) = app.specData(ii).Data{1}(1);
                observationStopDate(end+1)  = app.specData(ii).Data{1}(end);
            end

            app.specificTime1_Date.Limits = [min(observationStartDate), max(observationStopDate)];
            app.specificTime2_Date.Limits = app.specificTime1_Date.Limits;

            app.specificTime1_Date.Value  = app.specificTime1_Date.Limits(1);
            app.specificTime2_Date.Value  = app.specificTime2_Date.Limits(2);

            ui.TextView.update(app.threadInfo, util.HtmlTextGenerator.ThreadsInfo(app.specData(idxThreads), app.filterSummary));
        end

        %-----------------------------------------------------------------%
        function TreeBuilding(app)
            if ~isempty(app.filterTree.Children)
                delete(app.filterTree.Children)
                removeStyle(app.filterTree)
            end

            if ~isempty(app.filterTable)
                FilterTypeMapping = dictionary(["Date+Time", "Date", "Time", "DayOfWeek"], ["DATA E HORA", "DATA", "HORA", "DIA DA SEMANA"]);

                for ii = 1:height(app.filterTable)
                    fType  = app.filterTable.Type{ii};
                    fValue = app.filterTable.Value{ii};
        
                    switch fType
                        case 'Date+Time'
                            fValue2Show = sprintf('%s - %s', datestr(fValue(1), 'dd/mm/yyyy HH:MM:SS'), datestr(fValue(2), 'dd/mm/yyyy HH:MM:SS'));

                        case 'Date'
                            fValue2Show = sprintf('%s - %s', datestr(fValue(1), 'dd/mm/yyyy'), datestr(fValue(2), 'dd/mm/yyyy'));

                        case 'Time'
                            startTime = hours(fValue(1));
                            stopTime  = hours(fValue(2));
                            startTime.Format = 'hh:mm';
                            stopTime.Format  = 'hh:mm';

                            fValue2Show = sprintf('%s - %s', char(startTime), char(stopTime));
                        
                        case 'DayOfWeek'
                            DaysOfWeekMapping = dictionary(1:7, ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"]);
                            fValue2Show = strjoin(DaysOfWeekMapping(fValue), ', ');
                    end
    
                    uitreenode(app.filterTree, 'Text',        sprintf('#%d: %s<br><font style="padding-left: 18px; color: gray;">%s</font>', ii, FilterTypeMapping(fType), fValue2Show), ...
                                               'NodeData',    ii,                                                                                                                        ...
                                               'ContextMenu', app.ContextMenu);
                end
    
                addStyle(app.filterTree, uistyle('Interpreter', 'html'), "tree", "")
            end
        end

        %-----------------------------------------------------------------%
        function Filtering(app)
            for ii = 1:height(app.filterSummary)
                idxThread = app.filterSummary.idxThread(ii);
                fLogical  = ones(1, numel(app.specData(idxThread).Data{1}), 'logical');
                
                for jj = 1:height(app.filterTable)
                    fType  = app.filterTable.Type{jj};
                    fValue = app.filterTable.Value{jj};

                    switch fType
                        case 'DayOfWeek'
                            data2Filter  = weekday(app.specData(idxThread).Data{1});
                            fTempLogical = ismember(data2Filter, fValue);
                        
                        otherwise
                            switch fType
                                case {'Date+Time', 'Date'}
                                    data2Filter = app.specData(idxThread).Data{1};  

                                case 'Time'
                                    data2Filter = app.specData(idxThread).Data{1}.Hour + app.specData(idxThread).Data{1}.Minute/60;
                            end
                            fTempLogical = (data2Filter >= fValue(1)) & (data2Filter <= fValue(2));
                    end

                    fLogical = fLogical & fTempLogical;
                end

                app.filterSummary.FilteredSweeps(ii)     = sum(fLogical);
                app.filterSummary.FilterLogicalArray{ii} = fLogical;
            end
            
            if ~isempty(app.filterTable) && ~isequal(app.filterSummary.RawSweeps, app.filterSummary.FilteredSweeps) && all(app.filterSummary.FilteredSweeps)
                app.btnOK.Enable = 1;
            else
                app.btnOK.Enable = 0;
            end                

            idxThreads = app.filterSummary.idxThread;
            ui.TextView.update(app.threadInfo, util.HtmlTextGenerator.ThreadsInfo(app.specData(idxThreads), app.filterSummary));
        end

        %-----------------------------------------------------------------%
        function callingMainApp(app, updateFlag, returnFlag)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'MISCELLANEOUS', updateFlag, returnFlag)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, idxThreads)
            
            app.mainApp  = mainApp;
            app.specData = mainApp.specData;

            if app.isDocked
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app, idxThreads)
            else
                startup_timerCreation(app, idxThreads)
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcnCallFromPopupApp', 'mainApp', 'auxApp.dockTimeFiltering')
            delete(app)
            
        end

        % Selection changed function: filterTypePanel
        function filterTypePanelSelectionChanged(app, event)
            
            selectedButton = app.filterTypePanel.SelectedObject;

            hDate = findobj(app.filterValueGrid.Children, 'Type', 'uidatepicker');
            hTime = findobj(app.filterValueGrid.Children, 'Type', 'uispinner');
            hDay  = findobj(app.filterValueGrid.Children, 'Type', 'uicheckbox');

            switch selectedButton.Tag
                case 'Date+Time'
                    set(hDate, 'Enable', 1)
                    set(hTime, 'Enable', 1)
                    set(hDay,  'Enable', 0)
                    app.filterValueGrid.RowHeight = {22,22,0,0};

                case 'Date'
                    set(hDate, 'Enable', 1)
                    set(hTime, 'Enable', 0)
                    set(hDay,  'Enable', 0)
                    app.filterValueGrid.RowHeight = {22,22,0,0};

                    app.specificTime1_Hour.Value = 0;
                    app.specificTime1_Minute.Value = 0;
                    app.specificTime2_Hour.Value = 23;
                    app.specificTime2_Minute.Value = 59;

                case 'Time'
                    set(hDate, 'Enable', 0)
                    set(hTime, 'Enable', 1)
                    set(hDay,  'Enable', 0)
                    app.filterValueGrid.RowHeight = {22,22,0,0};

                    app.specificTime1_Date.Value  = app.specificTime1_Date.Limits(1);
                    app.specificTime2_Date.Value  = app.specificTime2_Date.Limits(2);

                case 'DayOfWeek'
                    set(hDate, 'Enable', 0)
                    set(hTime, 'Enable', 0)
                    set(hDay,  'Enable', 1)
                    app.filterValueGrid.RowHeight = {0,0,22,22};
            end
            
        end

        % Callback function: btnClose, btnOK
        function ButtonPushed(app, event)
            
            pushedButtonTag = event.Source.Tag;
            switch pushedButtonTag
                case 'OK'
                    if isempty(app.filterTable) || any(~app.filterSummary.FilteredSweeps)
                        app.btnOK.Enable = 0;
                        return
                    end
    
                    for ii = 1:height(app.filterSummary)
                        idxThread = app.filterSummary.idxThread(ii);
                        app.specData(idxThread) = filter(app.specData(idxThread), app.filterTable, app.filterSummary.FilterLogicalArray{ii});
                    end

                    updateFlag = true;

                case 'Close'
                    updateFlag = false;
            end

            callingMainApp(app, updateFlag, false)
            closeFcn(app)

        end

        % Image clicked function: filterAddImage
        function filterAddImageClicked(app, event)
            
            focus(app.jsBackDoor)

            try
                % Validações simples, criando filtro.
                selectedButton = app.filterTypePanel.SelectedObject;
                switch selectedButton.Tag
                    case {'Date+Time', 'Date'}
                        BeginTimestamp = app.specificTime1_Date.Value + hours(app.specificTime1_Hour.Value) + minutes(app.specificTime1_Minute.Value);
                        EndTimestamp   = app.specificTime2_Date.Value + hours(app.specificTime2_Hour.Value) + minutes(app.specificTime2_Minute.Value);

                        BeginTimestamp.Format = 'dd/MM/yyyy HH:mm';
                        EndTimestamp.Format   = 'dd/MM/yyyy HH:mm';

                        if isnat(BeginTimestamp) || isnat(EndTimestamp) || (BeginTimestamp > EndTimestamp)
                            error('Período de observação inválido.')
                        end
                        newFilter = struct('Type', selectedButton.Tag, 'Value', [BeginTimestamp, EndTimestamp]);
    
                    case 'Time'
                        BeginHour = app.specificTime1_Hour.Value + app.specificTime1_Minute.Value/60;
                        EndHour   = app.specificTime2_Hour.Value + app.specificTime2_Minute.Value/60;
                        
                        if BeginHour >= EndHour
                            error('A hora do início não pode ser igual ou superior à do fim.')
                        end

                        newFilter = struct('Type', selectedButton.Tag, 'Value', [BeginHour, EndHour]);
    
                    case 'DayOfWeek'
                        hDay = findobj(app.filterValueGrid.Children, 'Type', 'uicheckbox', 'Value', true);
                        
                        if isempty(hDay)
                            error('Deve ser selecionado ao menos um dia.')
                        end
    
                        DayOfWeek = str2double({hDay.Tag});
                        newFilter = struct('Type', selectedButton.Tag, 'Value', DayOfWeek);
                end

                % Adiciona filtro aos fluxos espectrais, filtrando...
                app.filterTable.Type{end+1} = newFilter.Type;
                app.filterTable.Value{end}  = newFilter.Value;

                TreeBuilding(app)
                Filtering(app)

            catch ME
                ui.Dialog(app.UIFigure, 'warning', ME.message);
            end

        end

        % Menu selected function: btnDelete
        function btnDeleteSelected(app, event)
            
            if ~isempty(app.filterTree.SelectedNodes)
                idxFilter = [app.filterTree.SelectedNodes.NodeData];                
                app.filterTable(idxFilter, :) = [];

                TreeBuilding(app)
                Filtering(app)
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
                app.UIFigure.Position = [100 100 640 480];
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

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', '1x', 65, 20};
            app.Document.RowHeight = {17, 33, 72, 8, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create HTMLLabel
            app.HTMLLabel = uilabel(app.Document);
            app.HTMLLabel.VerticalAlignment = 'bottom';
            app.HTMLLabel.FontSize = 10;
            app.HTMLLabel.Layout.Row = 1;
            app.HTMLLabel.Layout.Column = 1;
            app.HTMLLabel.Text = 'FLUXOS A PROCESSAR';

            % Create filterTypePanelLabel
            app.filterTypePanelLabel = uilabel(app.Document);
            app.filterTypePanelLabel.VerticalAlignment = 'bottom';
            app.filterTypePanelLabel.FontSize = 10;
            app.filterTypePanelLabel.Layout.Row = 1;
            app.filterTypePanelLabel.Layout.Column = 2;
            app.filterTypePanelLabel.Text = 'FILTRAGEM NO TEMPO';

            % Create filterTypePanel
            app.filterTypePanel = uibuttongroup(app.Document);
            app.filterTypePanel.SelectionChangedFcn = createCallbackFcn(app, @filterTypePanelSelectionChanged, true);
            app.filterTypePanel.BackgroundColor = [0.9804 0.9804 0.9804];
            app.filterTypePanel.Layout.Row = 2;
            app.filterTypePanel.Layout.Column = [2 4];

            % Create filterType_DateTime
            app.filterType_DateTime = uiradiobutton(app.filterTypePanel);
            app.filterType_DateTime.Tag = 'Date+Time';
            app.filterType_DateTime.Text = 'Data e hora';
            app.filterType_DateTime.FontSize = 10.5;
            app.filterType_DateTime.Position = [11 6 77 22];
            app.filterType_DateTime.Value = true;

            % Create filterType_Date
            app.filterType_Date = uiradiobutton(app.filterTypePanel);
            app.filterType_Date.Tag = 'Date';
            app.filterType_Date.Text = 'Data';
            app.filterType_Date.FontSize = 10.5;
            app.filterType_Date.Position = [115 6 65 22];

            % Create filterType_Time
            app.filterType_Time = uiradiobutton(app.filterTypePanel);
            app.filterType_Time.Tag = 'Time';
            app.filterType_Time.Text = 'Hora';
            app.filterType_Time.FontSize = 10.5;
            app.filterType_Time.Position = [181 6 65 22];

            % Create filterType_DayOfWeek
            app.filterType_DayOfWeek = uiradiobutton(app.filterTypePanel);
            app.filterType_DayOfWeek.Tag = 'DayOfWeek';
            app.filterType_DayOfWeek.Text = 'Dia da semana';
            app.filterType_DayOfWeek.FontSize = 10.5;
            app.filterType_DayOfWeek.Position = [248 6 93 22];

            % Create filterValuePanel
            app.filterValuePanel = uipanel(app.Document);
            app.filterValuePanel.Layout.Row = 3;
            app.filterValuePanel.Layout.Column = [2 4];

            % Create filterValueGrid
            app.filterValueGrid = uigridlayout(app.filterValuePanel);
            app.filterValueGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.filterValueGrid.RowHeight = {22, 22, 0, 0};
            app.filterValueGrid.RowSpacing = 5;
            app.filterValueGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create specificTime1_Date
            app.specificTime1_Date = uidatepicker(app.filterValueGrid);
            app.specificTime1_Date.DisplayFormat = 'dd/MM/uuuu';
            app.specificTime1_Date.FontSize = 11;
            app.specificTime1_Date.Layout.Row = 1;
            app.specificTime1_Date.Layout.Column = [1 2];

            % Create specificTime1_Hour
            app.specificTime1_Hour = uispinner(app.filterValueGrid);
            app.specificTime1_Hour.Limits = [0 23];
            app.specificTime1_Hour.RoundFractionalValues = 'on';
            app.specificTime1_Hour.ValueDisplayFormat = '%.0f';
            app.specificTime1_Hour.HorizontalAlignment = 'center';
            app.specificTime1_Hour.FontSize = 11;
            app.specificTime1_Hour.Layout.Row = 2;
            app.specificTime1_Hour.Layout.Column = 1;

            % Create specificTime1_Minute
            app.specificTime1_Minute = uispinner(app.filterValueGrid);
            app.specificTime1_Minute.Step = 10;
            app.specificTime1_Minute.Limits = [0 59];
            app.specificTime1_Minute.RoundFractionalValues = 'on';
            app.specificTime1_Minute.ValueDisplayFormat = '%.0f';
            app.specificTime1_Minute.HorizontalAlignment = 'center';
            app.specificTime1_Minute.FontSize = 11;
            app.specificTime1_Minute.Layout.Row = 2;
            app.specificTime1_Minute.Layout.Column = 2;

            % Create specificTime2_Date
            app.specificTime2_Date = uidatepicker(app.filterValueGrid);
            app.specificTime2_Date.DisplayFormat = 'dd/MM/uuuu';
            app.specificTime2_Date.FontSize = 11;
            app.specificTime2_Date.Layout.Row = 1;
            app.specificTime2_Date.Layout.Column = [3 4];

            % Create specificTime2_Hour
            app.specificTime2_Hour = uispinner(app.filterValueGrid);
            app.specificTime2_Hour.Limits = [0 23];
            app.specificTime2_Hour.RoundFractionalValues = 'on';
            app.specificTime2_Hour.ValueDisplayFormat = '%.0f';
            app.specificTime2_Hour.HorizontalAlignment = 'center';
            app.specificTime2_Hour.FontSize = 11;
            app.specificTime2_Hour.Layout.Row = 2;
            app.specificTime2_Hour.Layout.Column = 3;
            app.specificTime2_Hour.Value = 23;

            % Create specificTime2_Minute
            app.specificTime2_Minute = uispinner(app.filterValueGrid);
            app.specificTime2_Minute.Step = 10;
            app.specificTime2_Minute.Limits = [0 59];
            app.specificTime2_Minute.RoundFractionalValues = 'on';
            app.specificTime2_Minute.ValueDisplayFormat = '%.0f';
            app.specificTime2_Minute.HorizontalAlignment = 'center';
            app.specificTime2_Minute.FontSize = 11;
            app.specificTime2_Minute.Layout.Row = 2;
            app.specificTime2_Minute.Layout.Column = 4;
            app.specificTime2_Minute.Value = 59;

            % Create DayOfWeek_1
            app.DayOfWeek_1 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_1.Tag = '1';
            app.DayOfWeek_1.Enable = 'off';
            app.DayOfWeek_1.Text = 'Domingo';
            app.DayOfWeek_1.FontSize = 11;
            app.DayOfWeek_1.Layout.Row = 3;
            app.DayOfWeek_1.Layout.Column = 1;

            % Create DayOfWeek_2
            app.DayOfWeek_2 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_2.Tag = '2';
            app.DayOfWeek_2.Enable = 'off';
            app.DayOfWeek_2.Text = 'Segunda';
            app.DayOfWeek_2.FontSize = 11;
            app.DayOfWeek_2.Layout.Row = 4;
            app.DayOfWeek_2.Layout.Column = 1;

            % Create DayOfWeek_3
            app.DayOfWeek_3 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_3.Tag = '3';
            app.DayOfWeek_3.Enable = 'off';
            app.DayOfWeek_3.Text = 'Terça';
            app.DayOfWeek_3.FontSize = 11;
            app.DayOfWeek_3.Layout.Row = 3;
            app.DayOfWeek_3.Layout.Column = 2;

            % Create DayOfWeek_4
            app.DayOfWeek_4 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_4.Tag = '4';
            app.DayOfWeek_4.Enable = 'off';
            app.DayOfWeek_4.Text = 'Quarta';
            app.DayOfWeek_4.FontSize = 11;
            app.DayOfWeek_4.Layout.Row = 4;
            app.DayOfWeek_4.Layout.Column = 2;

            % Create DayOfWeek_5
            app.DayOfWeek_5 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_5.Tag = '5';
            app.DayOfWeek_5.Enable = 'off';
            app.DayOfWeek_5.Text = 'Quinta';
            app.DayOfWeek_5.FontSize = 11;
            app.DayOfWeek_5.Layout.Row = 3;
            app.DayOfWeek_5.Layout.Column = 3;

            % Create DayOfWeek_6
            app.DayOfWeek_6 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_6.Tag = '6';
            app.DayOfWeek_6.Enable = 'off';
            app.DayOfWeek_6.Text = 'Sexta';
            app.DayOfWeek_6.FontSize = 11;
            app.DayOfWeek_6.Layout.Row = 4;
            app.DayOfWeek_6.Layout.Column = 3;

            % Create DayOfWeek_7
            app.DayOfWeek_7 = uicheckbox(app.filterValueGrid);
            app.DayOfWeek_7.Tag = '7';
            app.DayOfWeek_7.Enable = 'off';
            app.DayOfWeek_7.Text = 'Sábado';
            app.DayOfWeek_7.FontSize = 11;
            app.DayOfWeek_7.Layout.Row = 3;
            app.DayOfWeek_7.Layout.Column = 4;

            % Create filterTree
            app.filterTree = uitree(app.Document);
            app.filterTree.Multiselect = 'on';
            app.filterTree.FontSize = 10.5;
            app.filterTree.BackgroundColor = [0.9804 0.9804 0.9804];
            app.filterTree.Layout.Row = 5;
            app.filterTree.Layout.Column = [2 4];

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 6;
            app.btnOK.Layout.Column = [3 4];
            app.btnOK.Text = 'OK';

            % Create threadInfo
            app.threadInfo = uilabel(app.Document);
            app.threadInfo.VerticalAlignment = 'top';
            app.threadInfo.WordWrap = 'on';
            app.threadInfo.FontSize = 11;
            app.threadInfo.Layout.Row = [2 5];
            app.threadInfo.Layout.Column = 1;
            app.threadInfo.Interpreter = 'html';
            app.threadInfo.Text = '';

            % Create filterAddImage
            app.filterAddImage = uiimage(app.Document);
            app.filterAddImage.ImageClickedFcn = createCallbackFcn(app, @filterAddImageClicked, true);
            app.filterAddImage.Layout.Row = 4;
            app.filterAddImage.Layout.Column = 4;
            app.filterAddImage.HorizontalAlignment = 'right';
            app.filterAddImage.VerticalAlignment = 'bottom';
            app.filterAddImage.ImageSource = 'addSymbol_32.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.dockTimeFiltering';

            % Create btnDelete
            app.btnDelete = uimenu(app.ContextMenu);
            app.btnDelete.MenuSelectedFcn = createCallbackFcn(app, @btnDeleteSelected, true);
            app.btnDelete.Text = 'Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockTimeFiltering_exported(Container, varargin)

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
