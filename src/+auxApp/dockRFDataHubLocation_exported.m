classdef dockRFDataHubLocation_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        GridLayout        matlab.ui.container.GridLayout
        CoordinatesPanel  matlab.ui.container.Panel
        CoordinatesGrid   matlab.ui.container.GridLayout
        Height            matlab.ui.control.NumericEditField
        HeightLabel       matlab.ui.control.Label
        Longitude         matlab.ui.control.NumericEditField
        LongitudeLabel    matlab.ui.control.Label
        Latitude          matlab.ui.control.NumericEditField
        LatitudeLabel     matlab.ui.control.Label
        CancelEdition     matlab.ui.control.Image
        ConfirmEdition    matlab.ui.control.Image
        ToggleEditMode    matlab.ui.control.Image
        Refresh           matlab.ui.control.Image
        Title             matlab.ui.control.Label
        Icon              matlab.ui.control.Image
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
            stationType = app.inputArgs.stationType;

            switch stationType
                case 'RX'
                    app.Icon.ImageSource = 'Pin_32Triangle.png';
                    app.Title.Text = '<b>Estação receptora - RX</b><br><font style="font-size: 11px; color: gray;">(referência coluna "Distância" e enlace)</font>';

                case 'TX'
                    app.Icon.ImageSource = 'Pin_32.png';
                    app.Title.Text = '<b>Estação transmissora - TX</b><br><font style="font-size: 11px; color: gray;">(registro selecionado em tabela)</font>';

                    % A altura de estações do RFDataHub pode ser fracionária.
                    set(app.Height, 'RoundFractionalValues', 'off', 'ValueDisplayFormat', '%.1f')
            end

            app.ToggleEditMode.UserData.status = false;
            updatePanel(app)
        end

        %-----------------------------------------------------------------%
        function updatePanel(app)
            % Valores inicial (InitialValue) e corrente (CurrentValue) são 
            % structs com os campos Latitude, Longitude e Height. Os campos 
            % editados, isto é, cujo valor corrente difere do inicial, são
            % destacados.
            stationAttributes = app.inputArgs.stationAttributes;
            initialValue = stationAttributes.InitialValue;
            currentValue = stationAttributes.CurrentValue;

            editFields = {app.Latitude, app.Longitude, app.Height};
            fieldNames = {'Latitude', 'Longitude', 'Height'};
            tolerances = [1e-6, 1e-6, 1e-1];
            isEdited   = false(1, 3);

            for ii = 1:3
                fieldName = fieldNames{ii};
                isEdited(ii) = abs(initialValue.(fieldName) - currentValue.(fieldName)) > tolerances(ii);

                if isEdited(ii)
                    set(editFields{ii}, 'Value', currentValue.(fieldName), 'FontColor', [1,1,1], 'BackgroundColor', [1,0,0])
                else
                    set(editFields{ii}, 'Value', currentValue.(fieldName), 'FontColor', [0,0,0], 'BackgroundColor', [1,1,1])
                end
            end

            app.Refresh.Visible = any(isEdited);
        end

        %-----------------------------------------------------------------%
        function updateLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end

            elementHandles = [app.Latitude, app.Longitude, app.Height];

            switch editionStatus
                case 'on' 
                    app.ToggleEditMode.ImageSource = 'Edit_32Filled.png';
                    app.ToggleEditMode.UserData.status = true;
                    app.GridLayout.ColumnWidth(end-1:end) = {18, 18};
                    set([app.ConfirmEdition, app.CancelEdition], 'Enable', 'on')
                    set(elementHandles, 'Editable', true)

                case 'off'
                    app.ToggleEditMode.ImageSource = 'Edit_32.png';
                    app.ToggleEditMode.UserData.status = false;
                    app.GridLayout.ColumnWidth(end-1:end) = {0, 0};
                    set([app.ConfirmEdition, app.CancelEdition], 'Enable', 'off')
                    set(elementHandles, 'Editable', false)
            end
        end

        %-----------------------------------------------------------------%
        function hasChanged = persistSettings(app, updateType)
            % "add" persiste os valores editados no painel; "delete" retorna 
            % aos valores iniciais (InitialValue). Retorna false caso o novo 
            % valor coincida com o valor corrente (nada a persistir ou notificar).
            %
            % Estação RX: app.mainApp.General.context.RFDATAHUB.rx.last
            % Estação TX: app.mainApp.rfDataHubAnnotation (registro mantido 
            %             apenas enquanto houver diferença em relação ao valor 
            %             inicial, isto é, o valor constante em base).
            arguments
                app 
                updateType {mustBeMember(updateType, {'add', 'delete'})}
            end

            stationType = app.inputArgs.stationType;
            stationAttributes = app.inputArgs.stationAttributes;

            switch updateType
                case 'add'
                    newValue = struct( ...
                        'Latitude',  round(app.Latitude.Value,  6), ...
                        'Longitude', round(app.Longitude.Value, 6), ...
                        'Height',    round(app.Height.Value,    1)  ...
                    );

                case 'delete'
                    newValue = stationAttributes.InitialValue;
            end

            hasChanged = ~isequaln(newValue, stationAttributes.CurrentValue);
            if ~hasChanged
                return
            end

            switch stationType
                case 'RX'
                    newRx = struct( ...
                        'latitude',  newValue.Latitude,  ...
                        'longitude', newValue.Longitude, ...
                        'height',    newValue.Height     ...
                    );

                    if ~isequaln(app.mainApp.General.context.RFDATAHUB.rx.last, newRx)
                        app.mainApp.General.context.RFDATAHUB.rx.last   = newRx;
                        app.mainApp.General_I.context.RFDATAHUB.rx.last = newRx;

                        appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
                    end

                case 'TX'
                    initialValue = stationAttributes.InitialValue;
                    txSiteDiff = struct( ...
                        'Latitude',      struct('Status', false, 'RawValue', initialValue.Latitude,  'EditedValue', []), ...
                        'Longitude',     struct('Status', false, 'RawValue', initialValue.Longitude, 'EditedValue', []), ...
                        'AntennaHeight', struct('Status', false, 'RawValue', initialValue.Height,    'EditedValue', [])  ...
                    );

                    % Evidencia quais parâmetros foram editados manualmente.
                    fieldMap = {'Latitude', 'Latitude'; 'Longitude', 'Longitude'; 'Height', 'AntennaHeight'};
                    for ii = 1:height(fieldMap)
                        [valueField, annotationField] = fieldMap{ii, :};

                        if ~isequal(newValue.(valueField), initialValue.(valueField))
                            txSiteDiff.(annotationField).Status = true;
                            txSiteDiff.(annotationField).EditedValue = newValue.(valueField);
                        end
                    end

                    isEdited = any([txSiteDiff.Latitude.Status, txSiteDiff.Longitude.Status, txSiteDiff.AntennaHeight.Status]);
                    [~, annotationIdx] = ismember(stationAttributes.ID, app.mainApp.rfDataHubAnnotation.ID);

                    if isEdited
                        % Cria-se nova linha ou edita-se a existente.
                        if ~annotationIdx
                            annotationIdx = height(app.mainApp.rfDataHubAnnotation) + 1;
                        end
                        app.mainApp.rfDataHubAnnotation(annotationIdx, :) = {stationAttributes.ID, stationAttributes.Station, txSiteDiff};

                    elseif annotationIdx
                        % O usuário desfez a alteração, manualmente ou por 
                        % meio do Refresh.
                        app.mainApp.rfDataHubAnnotation(annotationIdx, :) = [];
                    end
            end

            app.inputArgs.stationAttributes.CurrentValue = newValue;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, stationType, stationAttributes)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'stationType', stationType, 'stationAttributes', stationAttributes);
                initialValues(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: CancelEdition, ConfirmEdition, Refresh, 
        % ...and 1 other component
        function onButtonClicked(app, event)
            
            switch event.Source
                case {app.Refresh, app.ConfirmEdition}
                    if event.Source == app.Refresh
                        hasChanged = persistSettings(app, 'delete');
                    else
                        hasChanged = persistSettings(app, 'add');
                    end

                    updateLayout(app, 'off')
                    updatePanel(app)

                    if hasChanged
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onRFDataHubLocationChanged', app.inputArgs.context, app.inputArgs.stationType)
                    end

                case app.ToggleEditMode
                    app.ToggleEditMode.UserData.status = ~app.ToggleEditMode.UserData.status;

                    if app.ToggleEditMode.UserData.status
                        updateLayout(app, 'on')
                        focus(app.Latitude)
                    else
                        onButtonClicked(app, struct('Source', app.CancelEdition))
                    end

                case app.CancelEdition
                    updateLayout(app, 'off')
                    updatePanel(app)
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
                app.UIFigure.Position = [100 100 412 156];
                app.UIFigure.Name = 'appAnalise';
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.Resize = 'off';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                children = Container.Children;
                if isa(Container, 'matlab.ui.Figure') && isprop(Container, 'RunningAppInstance') && isprop(Container.RunningAppInstance, 'jsBackDoor')
                    children(children == Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)

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
            app.GridLayout.ColumnWidth = {22, '1x', 18, 18, 0, 0};
            app.GridLayout.RowHeight = {18, 18, 10, '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Icon
            app.Icon = uiimage(app.GridLayout);
            app.Icon.Layout.Row = [1 2];
            app.Icon.Layout.Column = 1;
            app.Icon.ImageSource = 'Pin_32.png';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.VerticalAlignment = 'bottom';
            app.Title.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Title.Layout.Row = [1 2];
            app.Title.Layout.Column = 2;
            app.Title.Interpreter = 'html';
            app.Title.Text = '';

            % Create Refresh
            app.Refresh = uiimage(app.GridLayout);
            app.Refresh.ScaleMethod = 'none';
            app.Refresh.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.Refresh.Visible = 'off';
            app.Refresh.Layout.Row = 2;
            app.Refresh.Layout.Column = 3;
            app.Refresh.ImageSource = 'Refresh_18.png';

            % Create ToggleEditMode
            app.ToggleEditMode = uiimage(app.GridLayout);
            app.ToggleEditMode.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.ToggleEditMode.Layout.Row = 2;
            app.ToggleEditMode.Layout.Column = 4;
            app.ToggleEditMode.ImageSource = 'Edit_32.png';

            % Create ConfirmEdition
            app.ConfirmEdition = uiimage(app.GridLayout);
            app.ConfirmEdition.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.ConfirmEdition.Enable = 'off';
            app.ConfirmEdition.Layout.Row = 2;
            app.ConfirmEdition.Layout.Column = 5;
            app.ConfirmEdition.ImageSource = 'Ok_32Green.png';

            % Create CancelEdition
            app.CancelEdition = uiimage(app.GridLayout);
            app.CancelEdition.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.CancelEdition.Enable = 'off';
            app.CancelEdition.Layout.Row = 2;
            app.CancelEdition.Layout.Column = 6;
            app.CancelEdition.ImageSource = 'Delete_32Red.png';

            % Create CoordinatesPanel
            app.CoordinatesPanel = uipanel(app.GridLayout);
            app.CoordinatesPanel.AutoResizeChildren = 'off';
            app.CoordinatesPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.CoordinatesPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.CoordinatesPanel.Layout.Row = 4;
            app.CoordinatesPanel.Layout.Column = [1 6];

            % Create CoordinatesGrid
            app.CoordinatesGrid = uigridlayout(app.CoordinatesPanel);
            app.CoordinatesGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.CoordinatesGrid.RowHeight = {22, 22};
            app.CoordinatesGrid.RowSpacing = 5;
            app.CoordinatesGrid.Padding = [10 10 10 5];
            app.CoordinatesGrid.BackgroundColor = [1 1 1];

            % Create LatitudeLabel
            app.LatitudeLabel = uilabel(app.CoordinatesGrid);
            app.LatitudeLabel.VerticalAlignment = 'bottom';
            app.LatitudeLabel.FontSize = 11;
            app.LatitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.LatitudeLabel.Layout.Row = 1;
            app.LatitudeLabel.Layout.Column = 1;
            app.LatitudeLabel.Text = 'Latitude (º):';

            % Create Latitude
            app.Latitude = uieditfield(app.CoordinatesGrid, 'numeric');
            app.Latitude.Limits = [-90 90];
            app.Latitude.ValueDisplayFormat = '%.6f';
            app.Latitude.Editable = 'off';
            app.Latitude.FontSize = 11;
            app.Latitude.Layout.Row = 2;
            app.Latitude.Layout.Column = 1;
            app.Latitude.Value = -1;

            % Create LongitudeLabel
            app.LongitudeLabel = uilabel(app.CoordinatesGrid);
            app.LongitudeLabel.VerticalAlignment = 'bottom';
            app.LongitudeLabel.FontSize = 11;
            app.LongitudeLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.LongitudeLabel.Layout.Row = 1;
            app.LongitudeLabel.Layout.Column = 2;
            app.LongitudeLabel.Text = 'Longitude (º):';

            % Create Longitude
            app.Longitude = uieditfield(app.CoordinatesGrid, 'numeric');
            app.Longitude.Limits = [-180 180];
            app.Longitude.ValueDisplayFormat = '%.6f';
            app.Longitude.Editable = 'off';
            app.Longitude.FontSize = 11;
            app.Longitude.Layout.Row = 2;
            app.Longitude.Layout.Column = 2;
            app.Longitude.Value = -1;

            % Create HeightLabel
            app.HeightLabel = uilabel(app.CoordinatesGrid);
            app.HeightLabel.VerticalAlignment = 'bottom';
            app.HeightLabel.FontSize = 11;
            app.HeightLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.HeightLabel.Layout.Row = 1;
            app.HeightLabel.Layout.Column = 3;
            app.HeightLabel.Text = 'Altura (metros):';

            % Create Height
            app.Height = uieditfield(app.CoordinatesGrid, 'numeric');
            app.Height.Limits = [0 Inf];
            app.Height.RoundFractionalValues = 'on';
            app.Height.ValueDisplayFormat = '%d';
            app.Height.Editable = 'off';
            app.Height.FontSize = 11;
            app.Height.Layout.Row = 2;
            app.Height.Layout.Column = 3;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockRFDataHubLocation_exported(Container, varargin)

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
                children = app.Container.Children;
                if isa(app.Container, 'matlab.ui.Figure') && isprop(app.Container, 'RunningAppInstance') && isprop(app.Container.RunningAppInstance, 'jsBackDoor')
                    children(children == app.Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
