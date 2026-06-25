classdef dockChannelsSatellite_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        FeixeDownListLabel_2       matlab.ui.control.Label
        RefLocation                matlab.ui.control.ListBox
        FeixeDownList              matlab.ui.control.ListBox
        PolarizationList           matlab.ui.control.ListBox
        FeixeDownListLabel         matlab.ui.control.Label
        PolarizationListLabel      matlab.ui.control.Label
        SatelliteID                matlab.ui.control.DropDown
        SatelliteIDLabel           matlab.ui.control.Label
        AddChannelButton           matlab.ui.control.Button
        ARQUIVOLIDOEditField       matlab.ui.control.EditField
        ARQUIVOLIDOEditFieldLabel  matlab.ui.control.Label
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
            app.ARQUIVOLIDOEditField.Value = fileFullPath;

            satelliteList = cellstr(unique(channels.DESIG_INT));
            if isscalar(satelliteList)
                app.SatelliteID.Items = satelliteList;
            else
                app.SatelliteID.Items = [{''}; satelliteList];
            end

            onSatelliteIDValueChanged(app)
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

        % Value changed function: SatelliteID
        function onSatelliteIDValueChanged(app, event)

            if ~isempty(app.SatelliteID.Value)
                channels = app.inputArgs.channels;
                satelliteIdx = strcmp(cellstr(channels.DESIG_INT), app.SatelliteID.Value);
                app.PolarizationList.Items = cellstr(unique(channels.FEIXE_POLARIZ_DOWN(satelliteIdx)));
                app.PolarizationList.Value = app.PolarizationList.Items(1);
                
            else
                app.FeixeDownList.Items    = {};
                app.PolarizationList.Items = {};
            end

            onPolarizationValueChanged(app)
            
        end

        % Value changed function: PolarizationList
        function onPolarizationValueChanged(app, event)
            
            if ~isempty(app.PolarizationList.Value)
                channels = app.inputArgs.channels;
                feixeIdx = strcmp(cellstr(channels.DESIG_INT), app.SatelliteID.Value) & ...
                           ismember(cellstr(channels.FEIXE_POLARIZ_DOWN), app.PolarizationList.Value);

                app.FeixeDownList.Items = cellstr(unique(channels.FEIXE_DOWN(feixeIdx)));
                app.FeixeDownList.Value = app.FeixeDownList.Items(1);

            else
                app.FeixeDownList.Items = {};
            end

            onFeixeListValueChanged(app)
            
        end

        % Value changed function: FeixeDownList
        function onFeixeListValueChanged(app, event)
            
            if isempty(app.FeixeDownList.Value)
                app.RefLocation.Items = {};

            else
                channels = app.inputArgs.channels;
                channelMatch = ...
                    strcmp(cellstr(channels.DESIG_INT), app.SatelliteID.Value) & ...
                    ismember(cellstr(channels.FEIXE_POLARIZ_DOWN), app.PolarizationList.Value) & ...
                    ismember(cellstr(channels.FEIXE_DOWN), app.FeixeDownList.Value);

                if any(channelMatch)
                    channels = channels(channelMatch, :);
                    channelList = arrayfun(@(x, y) util.HtmlTextGenerator.createTag('Channel', x, y), channels.FREQ_CENTRAL_DOWN, channels.BW, 'UniformOutput', false);
                else
                    channelList = {};
                end

                app.RefLocation.Items = channelList;
            end

            app.AddChannelButton.Enable = ~isempty(app.RefLocation.Items);
            
        end

        % Button pushed function: AddChannelButton
        function onAddButtonClicked(app, event)
            
            specData = app.inputArgs.specData;
            channels = app.inputArgs.channels;
            channelMatch = ...
                strcmp(cellstr(channels.DESIG_INT), app.SatelliteID.Value)      & ...
                ismember(cellstr(channels.FEIXE_DOWN), app.FeixeDownList.Value) & ...
                ismember(cellstr(channels.FEIXE_POLARIZ_DOWN), app.PolarizationList.Value);

            if any(channelMatch)
                channelList = class.EMSatDataHubLib.importSatelliteChannels(channels(channelMatch, :));

                try
                    for ii = 1:numel(channelList)
                        channelCell2Add = struct2cell(channelList(ii));
                        checkIfNewChannelIsValid(app.mainApp.channelObj, channelCell2Add{:})                    
                    end
                    addChannel(app.mainApp.channelObj, 'manual', specData, 1:numel(specData), channelList)
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
            app.GridLayout.ColumnWidth = {110, '1x', 100, '1x', 110};
            app.GridLayout.RowHeight = {17, 22, 34, 22, 34, '1x', 1, 24};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create ARQUIVOLIDOEditFieldLabel
            app.ARQUIVOLIDOEditFieldLabel = uilabel(app.GridLayout);
            app.ARQUIVOLIDOEditFieldLabel.VerticalAlignment = 'bottom';
            app.ARQUIVOLIDOEditFieldLabel.FontSize = 10;
            app.ARQUIVOLIDOEditFieldLabel.Layout.Row = 1;
            app.ARQUIVOLIDOEditFieldLabel.Layout.Column = [1 5];
            app.ARQUIVOLIDOEditFieldLabel.Text = 'ARQUIVO LIDO:';

            % Create ARQUIVOLIDOEditField
            app.ARQUIVOLIDOEditField = uieditfield(app.GridLayout, 'text');
            app.ARQUIVOLIDOEditField.Editable = 'off';
            app.ARQUIVOLIDOEditField.FontSize = 11;
            app.ARQUIVOLIDOEditField.Layout.Row = 2;
            app.ARQUIVOLIDOEditField.Layout.Column = [1 5];

            % Create AddChannelButton
            app.AddChannelButton = uibutton(app.GridLayout, 'push');
            app.AddChannelButton.ButtonPushedFcn = createCallbackFcn(app, @onAddButtonClicked, true);
            app.AddChannelButton.Icon = 'Add_16.png';
            app.AddChannelButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.AddChannelButton.Enable = 'off';
            app.AddChannelButton.Layout.Row = 8;
            app.AddChannelButton.Layout.Column = 5;
            app.AddChannelButton.Text = 'Incluir';

            % Create SatelliteIDLabel
            app.SatelliteIDLabel = uilabel(app.GridLayout);
            app.SatelliteIDLabel.VerticalAlignment = 'bottom';
            app.SatelliteIDLabel.FontSize = 11;
            app.SatelliteIDLabel.Layout.Row = 3;
            app.SatelliteIDLabel.Layout.Column = 1;
            app.SatelliteIDLabel.Interpreter = 'html';
            app.SatelliteIDLabel.Text = {'Satélite:'; '<font style="color: gray; font-size: 9px;">(DESIG_INT)</font>'};

            % Create SatelliteID
            app.SatelliteID = uidropdown(app.GridLayout);
            app.SatelliteID.Items = {};
            app.SatelliteID.ValueChangedFcn = createCallbackFcn(app, @onSatelliteIDValueChanged, true);
            app.SatelliteID.FontSize = 11;
            app.SatelliteID.BackgroundColor = [1 1 1];
            app.SatelliteID.Layout.Row = 4;
            app.SatelliteID.Layout.Column = 1;
            app.SatelliteID.Value = {};

            % Create PolarizationListLabel
            app.PolarizationListLabel = uilabel(app.GridLayout);
            app.PolarizationListLabel.VerticalAlignment = 'bottom';
            app.PolarizationListLabel.FontSize = 11;
            app.PolarizationListLabel.Layout.Row = 5;
            app.PolarizationListLabel.Layout.Column = 1;
            app.PolarizationListLabel.Interpreter = 'html';
            app.PolarizationListLabel.Text = {'Polarização:'; '<font style="color: gray; font-size: 9px;">(FEIXE_POLARIZ_DOWN)</font>'};

            % Create FeixeDownListLabel
            app.FeixeDownListLabel = uilabel(app.GridLayout);
            app.FeixeDownListLabel.VerticalAlignment = 'bottom';
            app.FeixeDownListLabel.FontSize = 11;
            app.FeixeDownListLabel.Layout.Row = 5;
            app.FeixeDownListLabel.Layout.Column = [2 3];
            app.FeixeDownListLabel.Interpreter = 'html';
            app.FeixeDownListLabel.Text = {'Identificação do feixe de descida:'; '<font style="color: gray; font-size: 9px;">(FEIXE_DOWN)</font>'};

            % Create PolarizationList
            app.PolarizationList = uilistbox(app.GridLayout);
            app.PolarizationList.Items = {};
            app.PolarizationList.Multiselect = 'on';
            app.PolarizationList.ValueChangedFcn = createCallbackFcn(app, @onPolarizationValueChanged, true);
            app.PolarizationList.FontSize = 11;
            app.PolarizationList.Layout.Row = 6;
            app.PolarizationList.Layout.Column = 1;
            app.PolarizationList.Value = {};

            % Create FeixeDownList
            app.FeixeDownList = uilistbox(app.GridLayout);
            app.FeixeDownList.Items = {};
            app.FeixeDownList.Multiselect = 'on';
            app.FeixeDownList.ValueChangedFcn = createCallbackFcn(app, @onFeixeListValueChanged, true);
            app.FeixeDownList.FontSize = 11;
            app.FeixeDownList.Layout.Row = 6;
            app.FeixeDownList.Layout.Column = [2 3];
            app.FeixeDownList.Value = {};

            % Create RefLocation
            app.RefLocation = uilistbox(app.GridLayout);
            app.RefLocation.Items = {};
            app.RefLocation.Multiselect = 'on';
            app.RefLocation.FontSize = 11;
            app.RefLocation.Layout.Row = 6;
            app.RefLocation.Layout.Column = [4 5];
            app.RefLocation.Value = {};

            % Create FeixeDownListLabel_2
            app.FeixeDownListLabel_2 = uilabel(app.GridLayout);
            app.FeixeDownListLabel_2.VerticalAlignment = 'bottom';
            app.FeixeDownListLabel_2.FontSize = 11;
            app.FeixeDownListLabel_2.Layout.Row = 5;
            app.FeixeDownListLabel_2.Layout.Column = [4 5];
            app.FeixeDownListLabel_2.Interpreter = 'html';
            app.FeixeDownListLabel_2.Text = {'Identificação dos canais:'; '<font style="color: gray; font-size: 9px;">(FREQUÊNCIA E LARGURA)</font>'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockChannelsSatellite_exported(Container, varargin)

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
