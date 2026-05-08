classdef dockDriveTestPoints_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        points_Tree                   matlab.ui.container.CheckBoxTree
        points_AddImage               matlab.ui.control.Image
        points_AddValuePanel          matlab.ui.container.Panel
        points_AddValueGrid           matlab.ui.container.GridLayout
        points_Subtype2Distance       matlab.ui.control.Spinner
        points_Subtype2DistanceLabel  matlab.ui.control.Label
        points_Subtype2NPeaks         matlab.ui.control.Spinner
        points_Subtype2NPeaksLabel    matlab.ui.control.Label
        points_Subtype2DropDown       matlab.ui.control.DropDown
        points_Subtype2Label          matlab.ui.control.Label
        points_Subtype1Distance       matlab.ui.control.NumericEditField
        points_Subtype1DistanceLabel  matlab.ui.control.Label
        points_Subtype1Value          matlab.ui.control.EditField
        points_Subtype1DropDown       matlab.ui.control.DropDown
        points_Subtype1Label          matlab.ui.control.Label
        points_RadioGroup             matlab.ui.container.ButtonGroup
        points_AddFindPeaks           matlab.ui.control.RadioButton
        points_AddRFDataHub           matlab.ui.control.RadioButton
        GridLayout                    matlab.ui.container.GridLayout
        ChannelPanel                  matlab.ui.container.Panel
        ChannelGrid                   matlab.ui.container.GridLayout
        BandWidthkHz                  matlab.ui.control.NumericEditField
        BandWidthkHzLabel             matlab.ui.control.Label
        FreqCenterMHz                 matlab.ui.control.NumericEditField
        FreqCenterMHzLabel            matlab.ui.control.Label
        Toolbar                       matlab.ui.container.GridLayout
        CancelEdition                 matlab.ui.control.Image
        ConfirmEdition                matlab.ui.control.Image
        ToggleEditMode                matlab.ui.control.Image
        Refresh                       matlab.ui.control.Image
        Title                         matlab.ui.control.Label
        Icon                          matlab.ui.control.Image
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
        function initialValues(app, flowIdx, emissionIdx)
            app.ToggleEditMode.UserData.status = false;
            updatePanel(app, flowIdx, emissionIdx)
        end

        %-----------------------------------------------------------------%
        function updatePanel(app, flowIdx, emissionIdx)
            specData = app.mainApp.specData(flowIdx);
            emission = specData.UserData.Emissions(emissionIdx, :);

            app.FreqCenterMHz.Value = emission.ChannelAssigned.UserModified.Frequency;
            app.BandWidthkHz.Value = emission.ChannelAssigned.UserModified.ChannelBW;
            app.Refresh.Visible = ~isequal(emission.ChannelAssigned.AutoSuggested, emission.ChannelAssigned.UserModified);
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
            
            set([app.ConfirmEdition, app.CancelEdition], 'Enable',   editionStatus)
            set([app.FreqCenterMHz,  app.BandWidthkHz],  'Editable', editionStatus)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx, emissionIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'flowIdx', flowIdx, 'emissionIdx', emissionIdx);
                initialValues(app, flowIdx, emissionIdx)
                
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
            emissionIdx = app.inputArgs.emissionIdx;

            switch event.Source
                case {app.Refresh, app.ConfirmEdition}
                    specData = app.mainApp.specData(flowIdx);
                    
                    switch event.Source
                        case app.Refresh
                            update(specData, 'UserData:Emissions', 'Refresh', emissionIdx)

                        otherwise
                            userModified = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified;
                            channelLimits = [ ...
                                app.FreqCenterMHz.Value - app.BandWidthkHz.Value / 2000, ...
                                app.FreqCenterMHz.Value + app.BandWidthkHz.Value / 2000 ...
                            ];

                            if all([abs(userModified.Frequency - app.FreqCenterMHz.Value) < 1e-3, abs(userModified.ChannelBW - app.BandWidthkHz.Value)  < 1e-1]) || ...
                               (channelLimits(1) < specData.MetaData.FreqStart / 1e+6) || ...
                               (channelLimits(2) > specData.MetaData.FreqStop / 1e+6)
                                
                                onButtonClicked(app, struct('Source', app.CancelEdition))
                                return
                            end

                            update(specData, 'UserData:Emissions', 'Edit', 'Channel', emissionIdx, app.FreqCenterMHz.Value, app.BandWidthkHz.Value, app.mainApp.channelObj)
                    end

                    updateLayout(app, 'off')
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onEmissionChannelChanged', context)

                case app.ToggleEditMode
                    app.ToggleEditMode.UserData.status = ~app.ToggleEditMode.UserData.status;
        
                    if app.ToggleEditMode.UserData.status
                        updateLayout(app, 'on')
                        focus(app.FreqCenterMHz)        
                    else
                        updateLayout(app, 'off')
                    end

                case app.CancelEdition
                    updateLayout(app, 'off')
            end

            updatePanel(app, flowIdx, emissionIdx)

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
                app.UIFigure.Position = [100 100 412 138];
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
            app.GridLayout.RowHeight = {22, 70};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Icon
            app.Icon = uiimage(app.GridLayout);
            app.Icon.ScaleMethod = 'none';
            app.Icon.Layout.Row = 1;
            app.Icon.Layout.Column = 1;
            app.Icon.ImageSource = 'Channel_18.png';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 2;
            app.Title.Text = 'CANAL SOB ANÁLISE';

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

            % Create ChannelPanel
            app.ChannelPanel = uipanel(app.GridLayout);
            app.ChannelPanel.AutoResizeChildren = 'off';
            app.ChannelPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ChannelPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ChannelPanel.Layout.Row = 2;
            app.ChannelPanel.Layout.Column = [1 3];

            % Create ChannelGrid
            app.ChannelGrid = uigridlayout(app.ChannelPanel);
            app.ChannelGrid.ColumnWidth = {'1x', 110};
            app.ChannelGrid.RowHeight = {22, 22};
            app.ChannelGrid.RowSpacing = 5;
            app.ChannelGrid.BackgroundColor = [1 1 1];

            % Create FreqCenterMHzLabel
            app.FreqCenterMHzLabel = uilabel(app.ChannelGrid);
            app.FreqCenterMHzLabel.FontSize = 11;
            app.FreqCenterMHzLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FreqCenterMHzLabel.Layout.Row = 1;
            app.FreqCenterMHzLabel.Layout.Column = 1;
            app.FreqCenterMHzLabel.Text = 'Frequência central (MHz):';

            % Create FreqCenterMHz
            app.FreqCenterMHz = uieditfield(app.ChannelGrid, 'numeric');
            app.FreqCenterMHz.Limits = [0 Inf];
            app.FreqCenterMHz.ValueDisplayFormat = '%.3f';
            app.FreqCenterMHz.Editable = 'off';
            app.FreqCenterMHz.FontSize = 11;
            app.FreqCenterMHz.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FreqCenterMHz.Layout.Row = 1;
            app.FreqCenterMHz.Layout.Column = 2;

            % Create BandWidthkHzLabel
            app.BandWidthkHzLabel = uilabel(app.ChannelGrid);
            app.BandWidthkHzLabel.FontSize = 11;
            app.BandWidthkHzLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandWidthkHzLabel.Layout.Row = 2;
            app.BandWidthkHzLabel.Layout.Column = 1;
            app.BandWidthkHzLabel.Text = 'Largura (kHz):';

            % Create BandWidthkHz
            app.BandWidthkHz = uieditfield(app.ChannelGrid, 'numeric');
            app.BandWidthkHz.Limits = [0 Inf];
            app.BandWidthkHz.ValueDisplayFormat = '%.1f';
            app.BandWidthkHz.Editable = 'off';
            app.BandWidthkHz.FontSize = 11;
            app.BandWidthkHz.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.BandWidthkHz.Layout.Row = 2;
            app.BandWidthkHz.Layout.Column = 2;

            % Create points_RadioGroup
            app.points_RadioGroup = uibuttongroup(app.UIFigure);
            app.points_RadioGroup.AutoResizeChildren = 'off';
            app.points_RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_RadioGroup.BackgroundColor = [1 1 1];
            app.points_RadioGroup.FontWeight = 'bold';
            app.points_RadioGroup.FontSize = 10;
            app.points_RadioGroup.Position = [-336 292 298 92];

            % Create points_AddRFDataHub
            app.points_AddRFDataHub = uiradiobutton(app.points_RadioGroup);
            app.points_AddRFDataHub.Text = {'<b>ESTAÇÕES DE TELECOMUNICAÇÕES</b>'; '<p style="color: gray; text-align: justify;">Adiciona estações incluídas no RFDataHub.</font>'};
            app.points_AddRFDataHub.FontSize = 10;
            app.points_AddRFDataHub.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_AddRFDataHub.Interpreter = 'html';
            app.points_AddRFDataHub.Position = [11 58 278 25];
            app.points_AddRFDataHub.Value = true;

            % Create points_AddFindPeaks
            app.points_AddFindPeaks = uiradiobutton(app.points_RadioGroup);
            app.points_AddFindPeaks.Text = {'<b>POTÊNCIA DO CANAL</b>'; '<p style="color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.points_AddFindPeaks.WordWrap = 'on';
            app.points_AddFindPeaks.FontSize = 10;
            app.points_AddFindPeaks.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_AddFindPeaks.Interpreter = 'html';
            app.points_AddFindPeaks.Position = [12 7 277 44];

            % Create points_AddValuePanel
            app.points_AddValuePanel = uipanel(app.UIFigure);
            app.points_AddValuePanel.AutoResizeChildren = 'off';
            app.points_AddValuePanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_AddValuePanel.Title = 'aaa';
            app.points_AddValuePanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.points_AddValuePanel.Position = [-336 47 298 240];

            % Create points_AddValueGrid
            app.points_AddValueGrid = uigridlayout(app.points_AddValuePanel);
            app.points_AddValueGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.points_AddValueGrid.RowHeight = {17, 22, 22, 22, 22, 22, 22, 22};
            app.points_AddValueGrid.RowSpacing = 5;
            app.points_AddValueGrid.Padding = [10 10 10 5];
            app.points_AddValueGrid.BackgroundColor = [1 1 1];

            % Create points_Subtype1Label
            app.points_Subtype1Label = uilabel(app.points_AddValueGrid);
            app.points_Subtype1Label.VerticalAlignment = 'bottom';
            app.points_Subtype1Label.FontSize = 10;
            app.points_Subtype1Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1Label.Layout.Row = 1;
            app.points_Subtype1Label.Layout.Column = [1 2];
            app.points_Subtype1Label.Text = 'Tipo de registro:';

            % Create points_Subtype1DropDown
            app.points_Subtype1DropDown = uidropdown(app.points_AddValueGrid);
            app.points_Subtype1DropDown.Items = {'Lista de frequências (MHz)', 'Índices de registros do RFDataHub'};
            app.points_Subtype1DropDown.FontSize = 11;
            app.points_Subtype1DropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1DropDown.BackgroundColor = [1 1 1];
            app.points_Subtype1DropDown.Layout.Row = 2;
            app.points_Subtype1DropDown.Layout.Column = [1 3];
            app.points_Subtype1DropDown.Value = 'Lista de frequências (MHz)';

            % Create points_Subtype1Value
            app.points_Subtype1Value = uieditfield(app.points_AddValueGrid, 'text');
            app.points_Subtype1Value.FontSize = 11;
            app.points_Subtype1Value.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1Value.Tooltip = {'Exemplos:'; '• 101.1, 101.3, 101.5 (Lista de frequências)'; '• #1000 #1500 #2000 (RFDataHub)'};
            app.points_Subtype1Value.Layout.Row = 3;
            app.points_Subtype1Value.Layout.Column = [1 3];

            % Create points_Subtype1DistanceLabel
            app.points_Subtype1DistanceLabel = uilabel(app.points_AddValueGrid);
            app.points_Subtype1DistanceLabel.WordWrap = 'on';
            app.points_Subtype1DistanceLabel.FontSize = 10;
            app.points_Subtype1DistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1DistanceLabel.Layout.Row = 4;
            app.points_Subtype1DistanceLabel.Layout.Column = [1 2];
            app.points_Subtype1DistanceLabel.Text = 'Distância máxima entre estação e local da monitoração (km):';

            % Create points_Subtype1Distance
            app.points_Subtype1Distance = uieditfield(app.points_AddValueGrid, 'numeric');
            app.points_Subtype1Distance.Limits = [1 Inf];
            app.points_Subtype1Distance.RoundFractionalValues = 'on';
            app.points_Subtype1Distance.ValueDisplayFormat = '%d';
            app.points_Subtype1Distance.FontSize = 11;
            app.points_Subtype1Distance.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype1Distance.Layout.Row = 4;
            app.points_Subtype1Distance.Layout.Column = 3;
            app.points_Subtype1Distance.Value = 30;

            % Create points_Subtype2Label
            app.points_Subtype2Label = uilabel(app.points_AddValueGrid);
            app.points_Subtype2Label.VerticalAlignment = 'bottom';
            app.points_Subtype2Label.FontSize = 10;
            app.points_Subtype2Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2Label.Layout.Row = 5;
            app.points_Subtype2Label.Layout.Column = [1 2];
            app.points_Subtype2Label.Text = 'Fonte da informação:';

            % Create points_Subtype2DropDown
            app.points_Subtype2DropDown = uidropdown(app.points_AddValueGrid);
            app.points_Subtype2DropDown.Items = {'Dados brutos', 'Dados processados (Data Binning)'};
            app.points_Subtype2DropDown.FontSize = 11;
            app.points_Subtype2DropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2DropDown.BackgroundColor = [1 1 1];
            app.points_Subtype2DropDown.Layout.Row = 6;
            app.points_Subtype2DropDown.Layout.Column = [1 3];
            app.points_Subtype2DropDown.Value = 'Dados brutos';

            % Create points_Subtype2NPeaksLabel
            app.points_Subtype2NPeaksLabel = uilabel(app.points_AddValueGrid);
            app.points_Subtype2NPeaksLabel.FontSize = 10;
            app.points_Subtype2NPeaksLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2NPeaksLabel.Layout.Row = 7;
            app.points_Subtype2NPeaksLabel.Layout.Column = [1 2];
            app.points_Subtype2NPeaksLabel.Text = 'Número de picos:';

            % Create points_Subtype2NPeaks
            app.points_Subtype2NPeaks = uispinner(app.points_AddValueGrid);
            app.points_Subtype2NPeaks.Limits = [1 100];
            app.points_Subtype2NPeaks.RoundFractionalValues = 'on';
            app.points_Subtype2NPeaks.ValueDisplayFormat = '%.0f';
            app.points_Subtype2NPeaks.FontSize = 11;
            app.points_Subtype2NPeaks.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2NPeaks.Layout.Row = 7;
            app.points_Subtype2NPeaks.Layout.Column = 3;
            app.points_Subtype2NPeaks.Value = 1;

            % Create points_Subtype2DistanceLabel
            app.points_Subtype2DistanceLabel = uilabel(app.points_AddValueGrid);
            app.points_Subtype2DistanceLabel.WordWrap = 'on';
            app.points_Subtype2DistanceLabel.FontSize = 10;
            app.points_Subtype2DistanceLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2DistanceLabel.Layout.Row = 8;
            app.points_Subtype2DistanceLabel.Layout.Column = [1 2];
            app.points_Subtype2DistanceLabel.Text = 'Distância mínima entre picos (metros):';

            % Create points_Subtype2Distance
            app.points_Subtype2Distance = uispinner(app.points_AddValueGrid);
            app.points_Subtype2Distance.Step = 100;
            app.points_Subtype2Distance.Limits = [0 10000];
            app.points_Subtype2Distance.RoundFractionalValues = 'on';
            app.points_Subtype2Distance.ValueDisplayFormat = '%.0f';
            app.points_Subtype2Distance.FontSize = 11;
            app.points_Subtype2Distance.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Subtype2Distance.Layout.Row = 8;
            app.points_Subtype2Distance.Layout.Column = 3;
            app.points_Subtype2Distance.Value = 1000;

            % Create points_AddImage
            app.points_AddImage = uiimage(app.UIFigure);
            app.points_AddImage.ScaleMethod = 'scaledown';
            app.points_AddImage.HorizontalAlignment = 'right';
            app.points_AddImage.VerticalAlignment = 'bottom';
            app.points_AddImage.Position = [-60 34 22 8];

            % Create points_Tree
            app.points_Tree = uitree(app.UIFigure, 'checkbox');
            app.points_Tree.FontSize = 10.5;
            app.points_Tree.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.points_Tree.Position = [-336 -155 298 184];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockDriveTestPoints_exported(Container, varargin)

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
