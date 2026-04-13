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
        EditCancelBtn   matlab.ui.control.Image
        EditConfirmBtn  matlab.ui.control.Image
        EditModeBtn     matlab.ui.control.Image
        RefreshBtn      matlab.ui.control.Image
        PanelLabel      matlab.ui.control.Label
        PanelIcon       matlab.ui.control.Image
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
        function updatePanelValues(app)
            specData = app.callingApp.bandObj.SpecData;
            if isempty(specData)
                closeFcn(app)
                return
            end

            app.Latitude.Value  = round(specData.GPS.Latitude,  6);
            app.Longitude.Value = round(specData.GPS.Longitude, 6);
            app.Height.Value    = AntennaHeight(specData, 1, -1);
            app.City.Value      = specData.GPS.Location;
            app.RefreshBtn.Visible = specData.GPS.Edited;
        end

        %-----------------------------------------------------------------%
        function updatePanelLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    set(app.EditModeBtn, 'ImageSource', 'Edit_32Filled.png', 'Tooltip', 'Cancela edição dos parâmetros do local da monitoração', 'UserData', true)
                    app.Toolbar.ColumnWidth(end-1:end) = {18, 18};
                    app.EditConfirmBtn.Enable = 1;
                    app.EditCancelBtn.Enable  = 1;

                    set(findobj(app.LocationGrid.Children, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), 'Editable', 1)

                case 'off'
                    set(app.EditModeBtn, 'ImageSource', 'Edit_32.png', 'Tooltip', 'Possibilita edição dos parâmetros do local da monitoração', 'UserData', false)
                    app.Toolbar.ColumnWidth(end-1:end) = {0, 0};
                    app.EditConfirmBtn.Enable = 0;
                    app.EditCancelBtn.Enable  = 0;
                    set(findobj(app.LocationGrid.Children, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), 'Editable', 0)
                    

                    updatePanelValues(app)
            end
        end

        %-----------------------------------------------------------------%
        function currentGPS = currentGPS(app)
            currentGPS = struct('Latitude',  app.Latitude.Value,  ...
                                'Longitude', app.Longitude.Value, ...
                                'Height',    app.Height.Value,    ...
                                'Location',  app.City.Value);
        end

        %-----------------------------------------------------------------%
        function applyManualEdition(app)
            idxThreads        = app.selectedThreads;
            currentLocation   = currentGPS(app);

            gpsEditionFlag    = ~isequal(rmfield(app.initialGPS, 'Height'), rmfield(currentLocation, 'Height'));
            heightEditionFlag = ~isequal(app.initialGPS.Height, currentLocation.Height);

            if gpsEditionFlag
                newGPS = struct('Status', -1, 'Matrix', [app.Latitude.Value, app.Longitude.Value]);
                newGPS = rmfield(gpsLib.summary(newGPS), 'Matrix');
                newGPS.Location = app.City.Value;
                newGPS.Edited = true;

                update(app.specData, 'GPS', 'ManualEdition', idxThreads, newGPS)
            end

            if heightEditionFlag
                newAntennaHeight = app.Height.Value;
                update(app.specData, 'UserData:AntennaHeight', 'ManualEdition', idxThreads, newAntennaHeight)
            end

            if gpsEditionFlag || heightEditionFlag
                updatePanelValues(app)
                app.initialGPS = currentGPS(app);
                callingMainApp(app, true, true)
            end
        end

        %-----------------------------------------------------------------%
        function callingMainApp(app, updateFlag, returnFlag)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'MISCELLANEOUS', updateFlag, returnFlag)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, varargin)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'varargin', {varargin});
                updatePanelValues(app, context)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: EditCancelBtn, EditConfirmBtn, 
        % ...and 2 other components
        function buttonPushed(app, event)
            
            switch event.Source
                case app.RefreshBtn
                    idxThreads = app.selectedThreads;

                    update(app.specData, 'GPS',                    'Refresh', idxThreads)
                    update(app.specData, 'UserData:AntennaHeight', 'Refresh', idxThreads)

                    updatePanelValues(app)
                    callingMainApp(app, true, true)

                case app.EditModeBtn
                    app.EditModeBtn.UserData = ~app.EditModeBtn.UserData;
        
                    if app.EditModeBtn.UserData
                        updatePanelLayout(app, 'on')
                        focus(app.Latitude)        
                    else
                        buttonPushed(app, struct('Source', app.EditCancelBtn))
                    end

                case app.EditConfirmBtn
                    applyManualEdition(app)
                    updatePanelLayout(app, 'off')

                case app.EditCancelBtn
                    updatePanelLayout(app, 'off')
            end
            
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

                    app.progressDialog.Visible = 'hidden';

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
                        app.City.Value = event.PreviousValue;
                        
                        msgWarning = sprintf([ ...
                            'Não encontrada em base do IBGE o município <b>"%s"</b>. ' ...
                            'Favor corrigir eventual erro na grafia, inserindo os acentos, ' ...
                            'no formato Município/UF.' ...
                        ], app.City.Value);
                        ui.Dialog(app.mainApp.UIFigure, 'warning', msgWarning);
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
                app.UIFigure.Position = [100 100 414 190];
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
            app.GridLayout.ColumnWidth = {18, 170, 174};
            app.GridLayout.RowHeight = {22, 122};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create PanelIcon
            app.PanelIcon = uiimage(app.GridLayout);
            app.PanelIcon.Layout.Row = 1;
            app.PanelIcon.Layout.Column = 1;
            app.PanelIcon.ImageSource = 'Pin_18.png';

            % Create PanelLabel
            app.PanelLabel = uilabel(app.GridLayout);
            app.PanelLabel.VerticalAlignment = 'bottom';
            app.PanelLabel.FontSize = 10;
            app.PanelLabel.Layout.Row = 1;
            app.PanelLabel.Layout.Column = 2;
            app.PanelLabel.Text = 'LOCAL DA MONITORAÇÃO';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {'1x', 18, 18, 0, 0};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [0 0 0 0];
            app.Toolbar.Layout.Row = 1;
            app.Toolbar.Layout.Column = 3;
            app.Toolbar.BackgroundColor = [1 1 1];

            % Create RefreshBtn
            app.RefreshBtn = uiimage(app.Toolbar);
            app.RefreshBtn.ScaleMethod = 'none';
            app.RefreshBtn.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.RefreshBtn.Visible = 'off';
            app.RefreshBtn.Tooltip = {'Retorna às configurações iniciais'};
            app.RefreshBtn.Layout.Row = 1;
            app.RefreshBtn.Layout.Column = 2;
            app.RefreshBtn.VerticalAlignment = 'bottom';
            app.RefreshBtn.ImageSource = 'Refresh_18.png';

            % Create EditModeBtn
            app.EditModeBtn = uiimage(app.Toolbar);
            app.EditModeBtn.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.EditModeBtn.Tooltip = {'Possibilita edição dos parâmetros do local da monitoração'};
            app.EditModeBtn.Layout.Row = 1;
            app.EditModeBtn.Layout.Column = 3;
            app.EditModeBtn.VerticalAlignment = 'bottom';
            app.EditModeBtn.ImageSource = 'Edit_32.png';

            % Create EditConfirmBtn
            app.EditConfirmBtn = uiimage(app.Toolbar);
            app.EditConfirmBtn.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.EditConfirmBtn.Enable = 'off';
            app.EditConfirmBtn.Tooltip = {'Confirma edição, recriando perfil de terreno'};
            app.EditConfirmBtn.Layout.Row = 1;
            app.EditConfirmBtn.Layout.Column = 4;
            app.EditConfirmBtn.VerticalAlignment = 'bottom';
            app.EditConfirmBtn.ImageSource = 'Ok_32Green.png';

            % Create EditCancelBtn
            app.EditCancelBtn = uiimage(app.Toolbar);
            app.EditCancelBtn.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.EditCancelBtn.Enable = 'off';
            app.EditCancelBtn.Tooltip = {'Cancela edição'};
            app.EditCancelBtn.Layout.Row = 1;
            app.EditCancelBtn.Layout.Column = 5;
            app.EditCancelBtn.VerticalAlignment = 'bottom';
            app.EditCancelBtn.ImageSource = 'Delete_32Red.png';

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
