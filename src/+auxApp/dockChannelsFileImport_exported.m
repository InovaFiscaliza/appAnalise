classdef dockChannelsFileImport_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        OkButton           matlab.ui.control.Button
        ChannelsTree       matlab.ui.container.CheckBoxTree
        ChannelsTreeLabel  matlab.ui.control.Label
        FileName           matlab.ui.control.EditField
        FileNameLabel      matlab.ui.control.Label
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
        function initialValues(app, fileFullPath, channels)
            app.FileName.Value = fileFullPath;
            addStyle(app.ChannelsTree, uistyle('Interpreter', 'html'))

            for ii = 1:numel(channels)
                frequencyMHz = sum(channels(ii).Band)/2;
                bandWidthMHz = diff(channels(ii).Band);

                channelText = sprintf([ ...
                    '<font style="color: black; font-size: 12px;">%s • %s • %s</font><br>' ...
                    'Frequência do primeiro canal: %.3f MHz • Último: %.3f MHz<br>' ...
                    'Espaçamento entre canais: %.1f kHz • Largura do canal: %.1f kHz<br>%s' ...
                ], channels(ii).Name, ...
                   channels(ii).EmissionClass, ...
                   util.HtmlTextGenerator.createTag('Channel', frequencyMHz, bandWidthMHz), ...
                   channels(ii).FirstChannel, ...
                   channels(ii).LastChannel, ...
                   channels(ii).StepWidth * 1000, ...
                   channels(ii).ChannelBW * 1000, ...
                   channels(ii).Reference);

                uitreenode(app.ChannelsTree, 'Text', channelText, 'NodeData', ii);
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, fileFullPath, specData, channels)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'specData', specData, 'channels', channels);
                initialValues(app, fileFullPath, channels)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: ChannelsTree
        function onTreeCheckedNodesChanged(app, event)
            
            app.OkButton.Enable = ~isempty(app.ChannelsTree.CheckedNodes);
            
        end

        % Button pushed function: OkButton
        function onAddButtonClicked(app, event)
            
            checkedNodes = app.ChannelsTree.CheckedNodes;
            
            if ~isempty(checkedNodes)
                specData = app.inputArgs.specData;
                channels = app.inputArgs.channels([checkedNodes.NodeData]);
                
                try
                    addChannel(app.mainApp.channelObj, 'manual', specData, 1:numel(specData), channels)
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onChannelAdded')

                catch ME
                    ui.Dialog(app.UIFigure, 'error', ME.message);
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
                app.UIFigure.Position = [100 100 620 440];
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
            app.GridLayout.ColumnWidth = {'1x', 110};
            app.GridLayout.RowHeight = {17, 22, 22, '1x', 1, 24};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create FileNameLabel
            app.FileNameLabel = uilabel(app.GridLayout);
            app.FileNameLabel.VerticalAlignment = 'bottom';
            app.FileNameLabel.FontSize = 10;
            app.FileNameLabel.Layout.Row = 1;
            app.FileNameLabel.Layout.Column = 1;
            app.FileNameLabel.Text = 'ARQUIVO LIDO:';

            % Create FileName
            app.FileName = uieditfield(app.GridLayout, 'text');
            app.FileName.Editable = 'off';
            app.FileName.FontSize = 11;
            app.FileName.Layout.Row = 2;
            app.FileName.Layout.Column = [1 2];

            % Create ChannelsTreeLabel
            app.ChannelsTreeLabel = uilabel(app.GridLayout);
            app.ChannelsTreeLabel.VerticalAlignment = 'bottom';
            app.ChannelsTreeLabel.FontSize = 10;
            app.ChannelsTreeLabel.Layout.Row = 3;
            app.ChannelsTreeLabel.Layout.Column = 1;
            app.ChannelsTreeLabel.Text = 'CANALIZAÇÕES:';

            % Create ChannelsTree
            app.ChannelsTree = uitree(app.GridLayout, 'checkbox');
            app.ChannelsTree.FontSize = 11;
            app.ChannelsTree.FontColor = [0.651 0.651 0.651];
            app.ChannelsTree.Layout.Row = 4;
            app.ChannelsTree.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.ChannelsTree.CheckedNodesChangedFcn = createCallbackFcn(app, @onTreeCheckedNodesChanged, true);

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onAddButtonClicked, true);
            app.OkButton.Icon = 'Add_16.png';
            app.OkButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.OkButton.Enable = 'off';
            app.OkButton.Layout.Row = 6;
            app.OkButton.Layout.Column = 2;
            app.OkButton.Text = 'Incluir';

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
