classdef dockOccupancy_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        PENDENTELabel          matlab.ui.control.Label
        AddChannelButton       matlab.ui.control.Button
        RadioButtonPanelLabel  matlab.ui.control.Label
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
            elHandles = app.ParametersGrid.Children;
            elHandlesTags = {elHandles.Tag};

            switch app.RadioButtonPanel.SelectedObject
                case app.ReferenceChannel
                    relatedTag = 'ReferenceChannel';
                    app.ParametersGrid.RowHeight = {26, 22, 0, 32, 22, 32, 22, '1x', 0, 0, 0};
                
                case app.FrequencyRange
                    relatedTag = 'FrequencyRange';
                    app.ParametersGrid.RowHeight = {26, 0, 22, 32, 22, 32, 22, '1x', 0, 0, 0};

                case app.SingleChannel
                    relatedTag = 'SingleChannel';
                    app.ParametersGrid.RowHeight = {26, 0, 22, 32, 22, 32, 22, '1x', 0, 0, 0};
                
                case app.FileImport
                    relatedTag = 'ExternalFile';
                    app.ParametersGrid.RowHeight = {0, 0, 0, 0, 0, 0, 0, 0, 26, 22, 22};
            end

            relatedElHandles = elHandles(contains(elHandlesTags, relatedTag));

            set(relatedElHandles, 'Visible', true)
            set(setdiff(elHandles, relatedElHandles), 'Visible', false)
        end

        %-----------------------------------------------------------------%
        function initialValues(app)
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

        % Button pushed function: AddChannelButton
        function ButtonPushed(app, event)

            specData = app.callingApp.bandObj.SpecData;
            % ...

        end

        % Callback function: not associated with a component
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
                app.UIFigure.Position = [100 100 412 516];
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
            app.GridLayout.ColumnWidth = {252, 110};
            app.GridLayout.RowHeight = {17, 166, 256, 22};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create RadioButtonPanelLabel
            app.RadioButtonPanelLabel = uilabel(app.GridLayout);
            app.RadioButtonPanelLabel.VerticalAlignment = 'bottom';
            app.RadioButtonPanelLabel.FontSize = 10;
            app.RadioButtonPanelLabel.Layout.Row = 1;
            app.RadioButtonPanelLabel.Layout.Column = 1;
            app.RadioButtonPanelLabel.Text = 'MODO DE INCLUSÃO';

            % Create AddChannelButton
            app.AddChannelButton = uibutton(app.GridLayout, 'push');
            app.AddChannelButton.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.AddChannelButton.Icon = 'Add_16.png';
            app.AddChannelButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.AddChannelButton.Layout.Row = 4;
            app.AddChannelButton.Layout.Column = 2;
            app.AddChannelButton.Text = 'Incluir';

            % Create PENDENTELabel
            app.PENDENTELabel = uilabel(app.GridLayout);
            app.PENDENTELabel.BackgroundColor = [0.6353 0.0784 0.1843];
            app.PENDENTELabel.HorizontalAlignment = 'center';
            app.PENDENTELabel.FontColor = [1 1 1];
            app.PENDENTELabel.Layout.Row = [2 3];
            app.PENDENTELabel.Layout.Column = [1 2];
            app.PENDENTELabel.Text = 'PENDENTE';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockOccupancy_exported(Container, varargin)

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
