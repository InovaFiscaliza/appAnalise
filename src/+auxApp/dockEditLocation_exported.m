classdef dockEditLocation_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        Document               matlab.ui.container.GridLayout
        rxLocationPanel        matlab.ui.container.Panel
        rxLocationGrid         matlab.ui.container.GridLayout
        rxCity                 matlab.ui.control.EditField
        rxCityLabel            matlab.ui.control.Label
        rxHeight               matlab.ui.control.NumericEditField
        rxHeightLabel          matlab.ui.control.Label
        rxLongitude            matlab.ui.control.NumericEditField
        rxLongitudeLabel       matlab.ui.control.Label
        rxLatitude             matlab.ui.control.NumericEditField
        rxLatitudeLabel        matlab.ui.control.Label
        rxLocationEditCancel   matlab.ui.control.Image
        rxLocationEditConfirm  matlab.ui.control.Image
        rxLocationEditMode     matlab.ui.control.Image
        rxRefresh              matlab.ui.control.Image
        rxLocationPanelLabel   matlab.ui.control.Label
        btnClose               matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true

        mainApp
        specData
        selectedThreads
        progressDialog

        initialGPS
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanelValues(app)
            % A edição de informações relacionadas ao local de monitoração 
            % é aplicável apenas quando selecionados fluxos espectrais 
            % relacionados ao mesmo local.
            idxThread = app.selectedThreads;
            idxThread = idxThread(1);

            % Atualiza painel...
            app.rxLatitude.Value  = round(app.specData(idxThread).GPS.Latitude,  6);
            app.rxLongitude.Value = round(app.specData(idxThread).GPS.Longitude, 6);
            app.rxHeight.Value    = AntennaHeight(app.specData, idxThread, -1);
            app.rxCity.Value      = app.specData(idxThread).GPS.Location;
            app.rxRefresh.Visible = app.specData(idxThread).GPS.Edited;
        end

        %-----------------------------------------------------------------%
        function updatePanelLayout(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    set(app.rxLocationEditMode, 'ImageSource', 'Edit_32Filled.png', 'Tooltip', 'Cancela edição dos parâmetros do local da monitoração', 'UserData', true)
                    app.Document.ColumnWidth(end-1:end) = {16,16};
                    app.rxLocationEditConfirm.Enable = 1;
                    app.rxLocationEditCancel.Enable  = 1;

                    set(findobj(app.rxLocationGrid.Children, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), 'Editable', 1)

                case 'off'
                    set(app.rxLocationEditMode, 'ImageSource', 'Edit_32.png', 'Tooltip', 'Possibilita edição dos parâmetros do local da monitoração', 'UserData', false)
                    app.Document.ColumnWidth(end-1:end) = {0,0};
                    app.rxLocationEditConfirm.Enable = 0;
                    app.rxLocationEditCancel.Enable  = 0;
                    set(findobj(app.rxLocationGrid.Children, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), 'Editable', 0)
                    

                    updatePanelValues(app)
            end
        end

        %-----------------------------------------------------------------%
        function currentGPS = currentGPS(app)
            currentGPS = struct('Latitude',  app.rxLatitude.Value,  ...
                                'Longitude', app.rxLongitude.Value, ...
                                'Height',    app.rxHeight.Value,    ...
                                'Location',  app.rxCity.Value);
        end

        %-----------------------------------------------------------------%
        function applyManualEdition(app)
            idxThreads        = app.selectedThreads;
            currentLocation   = currentGPS(app);

            gpsEditionFlag    = ~isequal(rmfield(app.initialGPS, 'Height'), rmfield(currentLocation, 'Height'));
            heightEditionFlag = ~isequal(app.initialGPS.Height, currentLocation.Height);

            if gpsEditionFlag
                newGPS = struct('Status', -1, 'Matrix', [app.rxLatitude.Value, app.rxLongitude.Value]);
                newGPS = rmfield(gpsLib.summary(newGPS), 'Matrix');
                newGPS.Location = app.rxCity.Value;
                newGPS.Edited = true;

                update(app.specData, 'GPS', 'ManualEdition', idxThreads, newGPS)
            end

            if heightEditionFlag
                newAntennaHeight = app.rxHeight.Value;
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
        function startupFcn(app, mainApp, idxThreads)
            
            app.mainApp  = mainApp;
            app.specData = mainApp.specData;
            app.selectedThreads = idxThreads;
            app.progressDialog  = app.mainApp.progressDialog;

            updatePanelValues(app)
            app.initialGPS = currentGPS(app);
            app.rxLocationEditMode.UserData = false;
            
        end

        % Callback function: UIFigure, btnClose
        function closeFcn(app, event)
            
            callingMainApp(app, false, false)            
            delete(app)
            
        end

        % Image clicked function: rxLocationEditCancel, 
        % ...and 3 other components
        function buttonPushed(app, event)
            
            switch event.Source
                case app.rxRefresh
                    idxThreads = app.selectedThreads;

                    update(app.specData, 'GPS',                    'Refresh', idxThreads)
                    update(app.specData, 'UserData:AntennaHeight', 'Refresh', idxThreads)

                    updatePanelValues(app)
                    app.initialGPS = currentGPS(app);
                    callingMainApp(app, true, true)

                case app.rxLocationEditMode
                    app.rxLocationEditMode.UserData = ~app.rxLocationEditMode.UserData;
        
                    if app.rxLocationEditMode.UserData
                        updatePanelLayout(app, 'on')
                        focus(app.rxLatitude)        
                    else
                        buttonPushed(app, struct('Source', app.rxLocationEditCancel))
                    end

                case app.rxLocationEditConfirm
                    applyManualEdition(app)
                    updatePanelLayout(app, 'off')

                case app.rxLocationEditCancel
                    updatePanelLayout(app, 'off')
            end
            
        end

        % Value changed function: rxCity, rxLatitude, rxLongitude
        function rxCityValueChanged(app, event)
                
            app.progressDialog.Visible = 'visible';

            switch event.Source
                case {app.rxLatitude, app.rxLongitude}                    
                    refPoint = struct('Latitude',  app.rxLatitude.Value, 'Longitude', app.rxLongitude.Value);
                    cityName = gpsLib.findNearestCity(refPoint);

                    if ~strcmp(cityName, app.rxCity.Value)        
                        app.rxCity.Value = cityName;
                    end

                    app.progressDialog.Visible = 'hidden';

                case app.rxCity
                    app.rxCity.Value = strtrim(app.rxCity.Value);
                    [cityName, Latitude, Longitude] = gpsLib.findCityCoordinates(app.rxCity.Value);

                    app.progressDialog.Visible = 'hidden';
        
                    if ~isempty(cityName)
                        app.rxCity.Value = cityName;

                        msgQuestion      = 'Deseja atualizar, além da localidade, as informações de Latitude e Longitude?';
                        userSelection    = ui.Dialog(app.mainApp.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);        
                        if userSelection == "Não"
                            return
                        end
        
                        app.rxLatitude.Value  = Latitude;
                        app.rxLongitude.Value = Longitude;
                        
                    else
                        app.rxCity.Value = event.PreviousValue;
                        
                        msgWarning       = sprintf(['Não encontrada em base do IBGE o município <b>"%s"</b>. Favor corrigir ' ...
                                                    'eventual erro na grafia, inserindo os acentos, no formato Município/UF.'], app.rxCity.Value);
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
                app.UIFigure.Position = [100 100 394 194];
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
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @closeFcn, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', 16, 16, 0, 0};
            app.Document.RowHeight = {22, '1x'};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create rxLocationPanelLabel
            app.rxLocationPanelLabel = uilabel(app.Document);
            app.rxLocationPanelLabel.VerticalAlignment = 'bottom';
            app.rxLocationPanelLabel.FontSize = 10;
            app.rxLocationPanelLabel.Layout.Row = 1;
            app.rxLocationPanelLabel.Layout.Column = 1;
            app.rxLocationPanelLabel.Text = 'LOCAL DA MONITORAÇÃO';

            % Create rxRefresh
            app.rxRefresh = uiimage(app.Document);
            app.rxRefresh.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.rxRefresh.Visible = 'off';
            app.rxRefresh.Tooltip = {'Retorna às configurações iniciais'};
            app.rxRefresh.Layout.Row = 1;
            app.rxRefresh.Layout.Column = 2;
            app.rxRefresh.VerticalAlignment = 'bottom';
            app.rxRefresh.ImageSource = 'Refresh_18.png';

            % Create rxLocationEditMode
            app.rxLocationEditMode = uiimage(app.Document);
            app.rxLocationEditMode.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.rxLocationEditMode.Tooltip = {'Possibilita edição dos parâmetros do local da monitoração'};
            app.rxLocationEditMode.Layout.Row = 1;
            app.rxLocationEditMode.Layout.Column = 3;
            app.rxLocationEditMode.VerticalAlignment = 'bottom';
            app.rxLocationEditMode.ImageSource = 'Edit_32.png';

            % Create rxLocationEditConfirm
            app.rxLocationEditConfirm = uiimage(app.Document);
            app.rxLocationEditConfirm.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.rxLocationEditConfirm.Enable = 'off';
            app.rxLocationEditConfirm.Tooltip = {'Confirma edição, recriando perfil de terreno'};
            app.rxLocationEditConfirm.Layout.Row = 1;
            app.rxLocationEditConfirm.Layout.Column = 4;
            app.rxLocationEditConfirm.VerticalAlignment = 'bottom';
            app.rxLocationEditConfirm.ImageSource = 'Ok_32Green.png';

            % Create rxLocationEditCancel
            app.rxLocationEditCancel = uiimage(app.Document);
            app.rxLocationEditCancel.ImageClickedFcn = createCallbackFcn(app, @buttonPushed, true);
            app.rxLocationEditCancel.Enable = 'off';
            app.rxLocationEditCancel.Tooltip = {'Cancela edição'};
            app.rxLocationEditCancel.Layout.Row = 1;
            app.rxLocationEditCancel.Layout.Column = 5;
            app.rxLocationEditCancel.VerticalAlignment = 'bottom';
            app.rxLocationEditCancel.ImageSource = 'Delete_32Red.png';

            % Create rxLocationPanel
            app.rxLocationPanel = uipanel(app.Document);
            app.rxLocationPanel.AutoResizeChildren = 'off';
            app.rxLocationPanel.Layout.Row = 2;
            app.rxLocationPanel.Layout.Column = [1 5];

            % Create rxLocationGrid
            app.rxLocationGrid = uigridlayout(app.rxLocationPanel);
            app.rxLocationGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.rxLocationGrid.RowHeight = {22, 22, 22, 22};
            app.rxLocationGrid.RowSpacing = 5;
            app.rxLocationGrid.Padding = [10 10 10 5];
            app.rxLocationGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create rxLatitudeLabel
            app.rxLatitudeLabel = uilabel(app.rxLocationGrid);
            app.rxLatitudeLabel.VerticalAlignment = 'bottom';
            app.rxLatitudeLabel.FontSize = 11;
            app.rxLatitudeLabel.Layout.Row = 1;
            app.rxLatitudeLabel.Layout.Column = 1;
            app.rxLatitudeLabel.Text = 'Latitude:';

            % Create rxLatitude
            app.rxLatitude = uieditfield(app.rxLocationGrid, 'numeric');
            app.rxLatitude.Limits = [-90 90];
            app.rxLatitude.ValueDisplayFormat = '%.6f';
            app.rxLatitude.ValueChangedFcn = createCallbackFcn(app, @rxCityValueChanged, true);
            app.rxLatitude.Editable = 'off';
            app.rxLatitude.FontSize = 11;
            app.rxLatitude.Layout.Row = 2;
            app.rxLatitude.Layout.Column = 1;
            app.rxLatitude.Value = -1;

            % Create rxLongitudeLabel
            app.rxLongitudeLabel = uilabel(app.rxLocationGrid);
            app.rxLongitudeLabel.VerticalAlignment = 'bottom';
            app.rxLongitudeLabel.FontSize = 11;
            app.rxLongitudeLabel.Layout.Row = 1;
            app.rxLongitudeLabel.Layout.Column = 2;
            app.rxLongitudeLabel.Text = 'Longitude:';

            % Create rxLongitude
            app.rxLongitude = uieditfield(app.rxLocationGrid, 'numeric');
            app.rxLongitude.Limits = [-180 180];
            app.rxLongitude.ValueDisplayFormat = '%.6f';
            app.rxLongitude.ValueChangedFcn = createCallbackFcn(app, @rxCityValueChanged, true);
            app.rxLongitude.Editable = 'off';
            app.rxLongitude.FontSize = 11;
            app.rxLongitude.Layout.Row = 2;
            app.rxLongitude.Layout.Column = 2;
            app.rxLongitude.Value = -1;

            % Create rxHeightLabel
            app.rxHeightLabel = uilabel(app.rxLocationGrid);
            app.rxHeightLabel.VerticalAlignment = 'bottom';
            app.rxHeightLabel.FontSize = 11;
            app.rxHeightLabel.Layout.Row = 1;
            app.rxHeightLabel.Layout.Column = 3;
            app.rxHeightLabel.Text = 'Altura (m):';

            % Create rxHeight
            app.rxHeight = uieditfield(app.rxLocationGrid, 'numeric');
            app.rxHeight.Limits = [-1 1000];
            app.rxHeight.ValueDisplayFormat = '%.1f';
            app.rxHeight.Editable = 'off';
            app.rxHeight.FontSize = 11;
            app.rxHeight.Layout.Row = 2;
            app.rxHeight.Layout.Column = 3;
            app.rxHeight.Value = -1;

            % Create rxCityLabel
            app.rxCityLabel = uilabel(app.rxLocationGrid);
            app.rxCityLabel.VerticalAlignment = 'bottom';
            app.rxCityLabel.FontSize = 11;
            app.rxCityLabel.Layout.Row = 3;
            app.rxCityLabel.Layout.Column = 1;
            app.rxCityLabel.Text = 'Município/UF:';

            % Create rxCity
            app.rxCity = uieditfield(app.rxLocationGrid, 'text');
            app.rxCity.ValueChangedFcn = createCallbackFcn(app, @rxCityValueChanged, true);
            app.rxCity.Editable = 'off';
            app.rxCity.FontSize = 11;
            app.rxCity.Layout.Row = 4;
            app.rxCity.Layout.Column = [1 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockEditLocation_exported(Container, varargin)

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
