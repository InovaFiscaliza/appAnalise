classdef dockChannelsFileImport_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        ARQUIVOLIDOEditField       matlab.ui.control.EditField
        ARQUIVOLIDOEditFieldLabel  matlab.ui.control.Label
        Location                   matlab.ui.control.ListBox
        LocationLabel              matlab.ui.control.Label
        Delete                     matlab.ui.control.Image
        Add                        matlab.ui.control.Image
        RefLocation                matlab.ui.control.ListBox
        RefLocationLabel           matlab.ui.control.Label
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
        function initialValues(app, fileFullPath)
            app.ARQUIVOLIDOEditField.Value = fileFullPath;
            % ...
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, fileFullPath, specData, channels)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'specData', specData, 'channels', channels);
                initialValues(app, fileFullPath)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function
        function ButtonPushed(app, event)

            specData = app.callingApp.bandObj.SpecData;
            % ...

        end

        % Callback function
        function RadioButtonPanelSelectionChanged(app, event)
            
            updatePanel(app)
            
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
                app.UIFigure.Position = [100 100 620 480];
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
            app.GridLayout.ColumnWidth = {'1x', 16, '1x'};
            app.GridLayout.RowHeight = {17, 22, 22, 22, 22, '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create RefLocationLabel
            app.RefLocationLabel = uilabel(app.GridLayout);
            app.RefLocationLabel.VerticalAlignment = 'bottom';
            app.RefLocationLabel.FontSize = 10;
            app.RefLocationLabel.Layout.Row = 3;
            app.RefLocationLabel.Layout.Column = 1;
            app.RefLocationLabel.Interpreter = 'html';
            app.RefLocationLabel.Text = 'CANAIS LIDOS:';

            % Create RefLocation
            app.RefLocation = uilistbox(app.GridLayout);
            app.RefLocation.Items = {};
            app.RefLocation.Multiselect = 'on';
            app.RefLocation.FontSize = 11;
            app.RefLocation.Layout.Row = [4 6];
            app.RefLocation.Layout.Column = 1;
            app.RefLocation.Value = {};

            % Create Add
            app.Add = uiimage(app.GridLayout);
            app.Add.ScaleMethod = 'none';
            app.Add.Enable = 'off';
            app.Add.Tooltip = {'Adiciona localidades selecionadas'};
            app.Add.Layout.Row = 4;
            app.Add.Layout.Column = 2;
            app.Add.ImageSource = 'Continue_16.png';

            % Create Delete
            app.Delete = uiimage(app.GridLayout);
            app.Delete.ScaleMethod = 'none';
            app.Delete.Enable = 'off';
            app.Delete.Tooltip = {'Exclui localidades selecionadas'};
            app.Delete.Layout.Row = 5;
            app.Delete.Layout.Column = 2;
            app.Delete.ImageSource = 'delete-12px-red.svg';

            % Create LocationLabel
            app.LocationLabel = uilabel(app.GridLayout);
            app.LocationLabel.VerticalAlignment = 'bottom';
            app.LocationLabel.FontSize = 10;
            app.LocationLabel.Layout.Row = 3;
            app.LocationLabel.Layout.Column = 3;
            app.LocationLabel.Interpreter = 'html';
            app.LocationLabel.Text = 'CANAIS A INCLUIR:';

            % Create Location
            app.Location = uilistbox(app.GridLayout);
            app.Location.Items = {};
            app.Location.Multiselect = 'on';
            app.Location.FontSize = 11;
            app.Location.Layout.Row = [4 6];
            app.Location.Layout.Column = 3;
            app.Location.Value = {};

            % Create ARQUIVOLIDOEditFieldLabel
            app.ARQUIVOLIDOEditFieldLabel = uilabel(app.GridLayout);
            app.ARQUIVOLIDOEditFieldLabel.VerticalAlignment = 'bottom';
            app.ARQUIVOLIDOEditFieldLabel.FontSize = 10;
            app.ARQUIVOLIDOEditFieldLabel.Layout.Row = 1;
            app.ARQUIVOLIDOEditFieldLabel.Layout.Column = 1;
            app.ARQUIVOLIDOEditFieldLabel.Text = 'ARQUIVO LIDO:';

            % Create ARQUIVOLIDOEditField
            app.ARQUIVOLIDOEditField = uieditfield(app.GridLayout, 'text');
            app.ARQUIVOLIDOEditField.Editable = 'off';
            app.ARQUIVOLIDOEditField.FontSize = 11;
            app.ARQUIVOLIDOEditField.Layout.Row = 2;
            app.ARQUIVOLIDOEditField.Layout.Column = [1 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockChannelsFileImport_exported(Container, varargin)

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
