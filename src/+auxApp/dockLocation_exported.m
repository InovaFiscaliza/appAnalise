classdef dockLocation_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        GridLayout      matlab.ui.container.GridLayout
        LocationPanel   matlab.ui.container.Panel
        LocationGrid    matlab.ui.container.GridLayout
        City            matlab.ui.control.EditField
        CityLabel       matlab.ui.control.Label
        Height          matlab.ui.control.NumericEditField
        HeightLabel     matlab.ui.control.Label
        Longitude       matlab.ui.control.NumericEditField
        LongitudeLabel  matlab.ui.control.Label
        Latitude        matlab.ui.control.NumericEditField
        LatitudeLabel   matlab.ui.control.Label
        Toolbar         matlab.ui.container.GridLayout
        CancelEdition   matlab.ui.control.Image
        ConfirmEdition  matlab.ui.control.Image
        ToggleEditMode  matlab.ui.control.Image
        Refresh         matlab.ui.control.Image
        Title           matlab.ui.control.Label
        Icon            matlab.ui.control.Image
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
        function initialValues(app, flowIdx)
            app.ToggleEditMode.UserData.status = false;
            updatePanel(app, flowIdx)
        end

        %-----------------------------------------------------------------%
        function updatePanel(app, flowIdx)
            specData = app.mainApp.specData(flowIdx);

            app.Latitude.Value = round(specData.GPS.Latitude,  6);
            app.Longitude.Value = round(specData.GPS.Longitude, 6);
            app.Height.Value = calculateAntennaHeight(specData, 1);
            app.City.Value = specData.GPS.Location;
            app.Refresh.Visible = specData.GPS.Edited;
        end

        %-----------------------------------------------------------------%
        function updateLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    app.Toolbar.ColumnWidth(end-1:end) = {18, 18};
                    app.ToggleEditMode.ImageSource = 'Edit_32Filled.png';
                    app.ToggleEditMode.UserData.status = true;

                case 'off'
                    app.Toolbar.ColumnWidth(end-1:end) = {0, 0};
                    app.ToggleEditMode.ImageSource = 'Edit_32.png';
                    app.ToggleEditMode.UserData.status = false;
            end

            set([app.ConfirmEdition, app.CancelEdition], 'Enable', editionStatus)
            set(findobj(app.LocationGrid.Children, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), 'Editable', editionStatus)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'flowIdx', flowIdx);
                initialValues(app, flowIdx)
                
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
            
            context = app.inputArgs.context;
            flowIdx = app.inputArgs.flowIdx;
            
            switch event.Source
                case {app.Refresh, app.ConfirmEdition}
                    specData = app.mainApp.specData(flowIdx);

                    receiverIdxs = find(strcmp({app.mainApp.specData.Receiver}, specData.Receiver));
                    if numel(receiverIdxs) > 1
                        msgQuestion = sprintf([ ...
                            'Há %d fluxos espectrais gerados pelo sensor <b>%s</b>.\n\n' ...
                            'Deseja atualizar as informações do local de monitoração apenas para o fluxo selecionado ' ...
                            'ou para todos os fluxos deste receptor?' ...
                        ], numel(receiverIdxs), specData.Receiver);
                        userSelection = ui.Dialog(app.mainApp.UIFigure, 'uiconfirm', msgQuestion, {'Todos', 'Apenas selecionado'}, 2, 2);
                        if userSelection == "Todos"
                            specData = app.mainApp.specData(receiverIdxs);
                        end
                    end
                    
                    switch event.Source
                        case app.Refresh
                            update(specData, 'GPS',                    'Refresh')
                            update(specData, 'UserData:AntennaHeight', 'Refresh')

                        otherwise
                            isPositionUpdated = false;

                            for ii = 1:numel(specData)
                                currentGps = specData(ii).GPS;
                                currentAntennaHeight = specData(ii).UserData.AntennaHeightMeters;
    
                                if any([ ...
                                        abs(currentGps.Latitude  - app.Latitude.Value)  > 1e-6, ...
                                        abs(currentGps.Longitude - app.Longitude.Value) > 1e-6 ...
                                    ])
                                    isPositionUpdated = true;
    
                                    editedGps = struct('Status', -1, 'Matrix', [app.Latitude.Value, app.Longitude.Value]);
                                    editedGps = rmfield(gpsLib.summary(editedGps), 'Matrix');
                                    editedGps.Location = app.City.Value;
                                    editedGps.Edited = true;
    
                                    update(specData(ii), 'GPS', 'CoordinatesChanged', editedGps)
                                end
    
                                if ~strcmp(currentGps.Location, app.City.Value)
                                    isPositionUpdated = true;
                                    update(specData(ii), 'GPS', 'LocationChanged', app.City.Value)
                                end
    
                                if app.Height.Value > 0 && abs(currentAntennaHeight - app.Height.Value) > 0.1
                                    isPositionUpdated = true;
                                    update(specData(ii), 'UserData:AntennaHeight', 'ManualEdition', app.Height.Value)
                                end
                            end

                            if ~isPositionUpdated
                                onButtonClicked(app, struct('Source', app.CancelEdition))
                                return
                            end
                    end

                    updateLayout(app, 'off')
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onLocationChanged', context)
                    
                case app.ToggleEditMode
                    app.ToggleEditMode.UserData.status = ~app.ToggleEditMode.UserData.status;
        
                    if app.ToggleEditMode.UserData.status
                        updateLayout(app, 'on')
                        focus(app.Latitude)        
                    else
                        updateLayout(app, 'off')
                    end

                case app.CancelEdition
                    updateLayout(app, 'off')
            end

            updatePanel(app, flowIdx)
            
        end

        % Value changed function: City, Latitude, Longitude
        function rxCityValueChanged(app, event)
                
            app.progressDialog.Visible = 'visible';

            switch event.Source
                case {app.Latitude, app.Longitude}                    
                    refPoint = struct('Latitude',  app.Latitude.Value, 'Longitude', app.Longitude.Value);
                    city = gpsLib.findNearestCity(refPoint);

                    if ~strcmp(city, app.City.Value)        
                        app.City.Value = city;
                    end

                case app.City
                    app.City.Value = strtrim(app.City.Value);
                    [city, lat, lng] = gpsLib.findCityCoordinates(app.City.Value);

                    app.progressDialog.Visible = 'hidden';
        
                    if ~isempty(city)
                        app.City.Value = city;

                        msgQuestion = [ ...
                            'Deseja atualizar, além da localidade, as informações de ' ...
                            'Latitude e Longitude?' ...
                        ];
                        userSelection = ui.Dialog(app.mainApp.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                        if userSelection == "Não"
                            return
                        end
        
                        app.Latitude.Value = lat;
                        app.Longitude.Value = lng;
                        
                    else
                        msgWarning = sprintf([ ...
                            'Não encontrada em base do IBGE o município <b>"%s"</b>. ' ...
                            'Favor corrigir eventual erro na grafia, inserindo os acentos, ' ...
                            'no formato Município/UF.' ...
                        ], app.City.Value);
                        ui.Dialog(app.mainApp.UIFigure, 'warning', msgWarning);

                        app.City.Value = event.PreviousValue;
                    end
            end

            app.progressDialog.Visible = 'hidden';
            
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
                app.UIFigure.Position = [100 100 412 190];
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
            app.GridLayout.ColumnWidth = {18, 244, 100};
            app.GridLayout.RowHeight = {22, 122};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Icon
            app.Icon = uiimage(app.GridLayout);
            app.Icon.Layout.Row = 1;
            app.Icon.Layout.Column = 1;
            app.Icon.ImageSource = 'Pin_18.png';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 2;
            app.Title.Text = 'LOCAL DA MONITORAÇÃO';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {'1x', 18, 18, 0, 0};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [0 0 0 0];
            app.Toolbar.Layout.Row = 1;
            app.Toolbar.Layout.Column = 3;
            app.Toolbar.BackgroundColor = [1 1 1];

            % Create Refresh
            app.Refresh = uiimage(app.Toolbar);
            app.Refresh.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.Refresh.Visible = 'off';
            app.Refresh.Layout.Row = 1;
            app.Refresh.Layout.Column = 2;
            app.Refresh.ImageSource = 'Refresh_18.png';

            % Create ToggleEditMode
            app.ToggleEditMode = uiimage(app.Toolbar);
            app.ToggleEditMode.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.ToggleEditMode.Layout.Row = 1;
            app.ToggleEditMode.Layout.Column = 3;
            app.ToggleEditMode.ImageSource = 'Edit_32.png';

            % Create ConfirmEdition
            app.ConfirmEdition = uiimage(app.Toolbar);
            app.ConfirmEdition.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.ConfirmEdition.Enable = 'off';
            app.ConfirmEdition.Layout.Row = 1;
            app.ConfirmEdition.Layout.Column = 4;
            app.ConfirmEdition.ImageSource = 'Ok_32Green.png';

            % Create CancelEdition
            app.CancelEdition = uiimage(app.Toolbar);
            app.CancelEdition.ImageClickedFcn = createCallbackFcn(app, @onButtonClicked, true);
            app.CancelEdition.Enable = 'off';
            app.CancelEdition.Layout.Row = 1;
            app.CancelEdition.Layout.Column = 5;
            app.CancelEdition.ImageSource = 'Delete_32Red.png';

            % Create LocationPanel
            app.LocationPanel = uipanel(app.GridLayout);
            app.LocationPanel.AutoResizeChildren = 'off';
            app.LocationPanel.Layout.Row = 2;
            app.LocationPanel.Layout.Column = [1 3];

            % Create LocationGrid
            app.LocationGrid = uigridlayout(app.LocationPanel);
            app.LocationGrid.ColumnWidth = {110, 110, 110};
            app.LocationGrid.RowHeight = {22, 22, 22, 22};
            app.LocationGrid.RowSpacing = 5;
            app.LocationGrid.Padding = [10 10 10 5];
            app.LocationGrid.BackgroundColor = [1 1 1];

            % Create LatitudeLabel
            app.LatitudeLabel = uilabel(app.LocationGrid);
            app.LatitudeLabel.VerticalAlignment = 'bottom';
            app.LatitudeLabel.FontSize = 11;
            app.LatitudeLabel.Layout.Row = 1;
            app.LatitudeLabel.Layout.Column = 1;
            app.LatitudeLabel.Text = 'Latitude:';

            % Create Latitude
            app.Latitude = uieditfield(app.LocationGrid, 'numeric');
            app.Latitude.Limits = [-90 90];
            app.Latitude.ValueDisplayFormat = '%.6f';
            app.Latitude.ValueChangedFcn = createCallbackFcn(app, @rxCityValueChanged, true);
            app.Latitude.Editable = 'off';
            app.Latitude.FontSize = 11;
            app.Latitude.Layout.Row = 2;
            app.Latitude.Layout.Column = 1;
            app.Latitude.Value = -1;

            % Create LongitudeLabel
            app.LongitudeLabel = uilabel(app.LocationGrid);
            app.LongitudeLabel.VerticalAlignment = 'bottom';
            app.LongitudeLabel.FontSize = 11;
            app.LongitudeLabel.Layout.Row = 1;
            app.LongitudeLabel.Layout.Column = 2;
            app.LongitudeLabel.Text = 'Longitude:';

            % Create Longitude
            app.Longitude = uieditfield(app.LocationGrid, 'numeric');
            app.Longitude.Limits = [-180 180];
            app.Longitude.ValueDisplayFormat = '%.6f';
            app.Longitude.ValueChangedFcn = createCallbackFcn(app, @rxCityValueChanged, true);
            app.Longitude.Editable = 'off';
            app.Longitude.FontSize = 11;
            app.Longitude.Layout.Row = 2;
            app.Longitude.Layout.Column = 2;
            app.Longitude.Value = -1;

            % Create HeightLabel
            app.HeightLabel = uilabel(app.LocationGrid);
            app.HeightLabel.VerticalAlignment = 'bottom';
            app.HeightLabel.FontSize = 11;
            app.HeightLabel.Layout.Row = 1;
            app.HeightLabel.Layout.Column = 3;
            app.HeightLabel.Text = 'Altura (m):';

            % Create Height
            app.Height = uieditfield(app.LocationGrid, 'numeric');
            app.Height.Limits = [-1 1000];
            app.Height.ValueDisplayFormat = '%.1f';
            app.Height.Editable = 'off';
            app.Height.FontSize = 11;
            app.Height.Layout.Row = 2;
            app.Height.Layout.Column = 3;
            app.Height.Value = -1;

            % Create CityLabel
            app.CityLabel = uilabel(app.LocationGrid);
            app.CityLabel.VerticalAlignment = 'bottom';
            app.CityLabel.FontSize = 11;
            app.CityLabel.Layout.Row = 3;
            app.CityLabel.Layout.Column = 1;
            app.CityLabel.Text = 'Município/UF:';

            % Create City
            app.City = uieditfield(app.LocationGrid, 'text');
            app.City.ValueChangedFcn = createCallbackFcn(app, @rxCityValueChanged, true);
            app.City.Editable = 'off';
            app.City.FontSize = 11;
            app.City.Layout.Row = 4;
            app.City.Layout.Column = [1 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockLocation_exported(Container, varargin)

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
