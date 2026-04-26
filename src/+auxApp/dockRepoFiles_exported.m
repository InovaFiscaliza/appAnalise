classdef dockRepoFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        Panel               matlab.ui.container.Panel
        GridLayout2         matlab.ui.container.GridLayout
        CHAMAREVENTOButton  matlab.ui.control.Button
        DropDown            matlab.ui.control.DropDown
        DropDownLabel       matlab.ui.control.Label
        UITable             matlab.ui.control.Table
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
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel(app)
            % ...
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context);
                updatePanel(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Button pushed function: CHAMAREVENTOButton
        function CHAMAREVENTOButtonPushed(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'NomeEventoEspecifico')

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
            app.GridLayout.ColumnWidth = {'1x', 82, 18};
            app.GridLayout.RowHeight = {17, 166, 22, 22, '1x', 22};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable.RowName = {};
            app.UITable.Layout.Row = [5 6];
            app.UITable.Layout.Column = [1 3];

            % Create Panel
            app.Panel = uipanel(app.GridLayout);
            app.Panel.AutoResizeChildren = 'off';
            app.Panel.Layout.Row = [1 2];
            app.Panel.Layout.Column = [1 3];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x'};

            % Create DropDownLabel
            app.DropDownLabel = uilabel(app.GridLayout2);
            app.DropDownLabel.HorizontalAlignment = 'right';
            app.DropDownLabel.Layout.Row = 1;
            app.DropDownLabel.Layout.Column = 1;
            app.DropDownLabel.Text = 'Drop Down';

            % Create DropDown
            app.DropDown = uidropdown(app.GridLayout2);
            app.DropDown.Layout.Row = 1;
            app.DropDown.Layout.Column = 2;

            % Create CHAMAREVENTOButton
            app.CHAMAREVENTOButton = uibutton(app.GridLayout2, 'push');
            app.CHAMAREVENTOButton.ButtonPushedFcn = createCallbackFcn(app, @CHAMAREVENTOButtonPushed, true);
            app.CHAMAREVENTOButton.Layout.Row = 3;
            app.CHAMAREVENTOButton.Layout.Column = 2;
            app.CHAMAREVENTOButton.Text = 'CHAMAR EVENTO';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockRepoFiles_exported(Container, varargin)

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
