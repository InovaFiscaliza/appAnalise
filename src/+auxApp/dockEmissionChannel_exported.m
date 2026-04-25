classdef dockEmissionChannel_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        channelEditGrid        matlab.ui.container.GridLayout
        channelEditCancel      matlab.ui.control.Image
        channelEditConfirm     matlab.ui.control.Image
        channelEditMode        matlab.ui.control.Image
        channelRefresh         matlab.ui.control.Image
        channelPanel           matlab.ui.container.Panel
        channelGrid            matlab.ui.container.GridLayout
        channelBandWidth       matlab.ui.control.NumericEditField
        channelBandWidthLabel  matlab.ui.control.Label
        channelFrequency       matlab.ui.control.NumericEditField
        channelFrequencyLabel  matlab.ui.control.Label
        channelLabel           matlab.ui.control.Label
        PanelIcon              matlab.ui.control.Image
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
        function updatePanelValues(app, flowIdx, emissionIdx)
            specData = app.mainApp.specData(flowIdx);
            emission = specData.UserData.Emissions(emissionIdx, :);

            app.channelFrequency.Value = emission.ChannelAssigned.UserModified.Frequency;
            app.channelBandWidth.Value = emission.ChannelAssigned.UserModified.ChannelBW;

            app.channelRefresh.Visible = ~isequal(emission.ChannelAssigned.AutoSuggested, emission.ChannelAssigned.UserModified);
        end

        %-----------------------------------------------------------------%
        function layout_editChannelAssigned(app, editionStatus)
            arguments
                app 
                editionStatus char {mustBeMember(editionStatus, {'on', 'off'})}
            end            

            switch editionStatus
                case 'on'
                    set(app.channelEditMode, 'ImageSource', 'Edit_32Filled.png', 'Tooltip', 'Desabilita edição do canal', 'UserData', true)
                    app.channelEditGrid.ColumnWidth(end-1:end) = {18, 18};
                    app.channelEditConfirm.Enable = 1;
                    app.channelEditCancel.Enable  = 1;
                    app.channelFrequency.Editable = 1;
                    app.channelBandWidth.Editable = 1;

                case 'off'
                    set(app.channelEditMode, 'ImageSource', 'Edit_32.png',       'Tooltip', 'Habilita edição do canal',   'UserData', false)
                    app.channelEditGrid.ColumnWidth(end-1:end) = {0, 0};
                    app.channelEditConfirm.Enable = 0;
                    app.channelEditCancel.Enable  = 0;
                    app.channelFrequency.Editable = 0;
                    app.channelBandWidth.Editable = 0;

                    [idxThread, idxEmission]      = specDataIndex(app, 'ChannelDefault');
                    app.channelFrequency.Value    = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified.Frequency;
                    app.channelBandWidth.Value    = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified.ChannelBW;
            end
        end

        %-----------------------------------------------------------------%
        function checkChannelAssigned(app, idxThread, idxEmission)            
            if isempty(idxEmission)
                chAssigned = util.emissionChannel(app.specData, idxThread, idxEmission, app.mainApp.channelObj);
                app.channelRefresh.Visible = 0;

            else
                chAssigned = app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified;
                
                if isequal(app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, ...
                           app.specData(idxThread).UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                    app.channelRefresh.Visible = 0;
                else
                    app.channelRefresh.Visible = 1;
                end
            end

            app.channelGrid.UserData   = chAssigned;
            app.channelFrequency.Value = chAssigned.Frequency;
            app.channelBandWidth.Value = chAssigned.ChannelBW;

            checkFixedScreenSpanLimits(app)
        end

        %-----------------------------------------------------------------%
        function checkFixedScreenSpanLimits(app)
            switch app.config_BandGuardType.Value
                case 'Fixed'
                    chBW        = app.channelBandWidth.Value; % kHz
                    chBWLimits = chBW * app.config_BandGuardBWRelatedValue.Limits;
        
                    if app.config_BandGuardFixedValue.Value < chBWLimits(1)
                        app.config_BandGuardFixedValue.Value = chBWLimits(1);
                    elseif app.config_BandGuardFixedValue.Value > chBWLimits(2)
                        app.config_BandGuardFixedValue.Value = chBWLimits(2);
                    end

                otherwise
                    % ...
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx, emissionIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'flowIdx', flowIdx, 'emissionIdx', emissionIdx);
                updatePanelValues(app, flowIdx, emissionIdx)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: channelEditCancel, channelEditConfirm, 
        % ...and 2 other components
        function channelRefreshImageClicked(app, event)
            
            switch event.Source
                case {app.channelRefresh, app.channelEditConfirm}
                    switch event.Source
                        case app.channelRefresh
                            operationType = 'ChannelDefault';
                            [idxThread, idxEmission] = specDataIndex(app, operationType);
                            updateCustomProperty(app, idxThread, idxEmission, operationType)        
                            checkChannelAssigned(app, idxThread, idxEmission)
                        otherwise
                            operationType = 'ChannelParameterChanged';
                            [idxThread, idxEmission] = specDataIndex(app, operationType);
                            updateCustomProperty(app, idxThread, idxEmission, operationType)
                            app.channelRefresh.Visible = 1;
                    end

                    layout_editChannelAssigned(app, 'off')

                    if app.plotFlag
                        app.plotFlag = 0;
                        pause(.100)
                    end
        
                    prePlot_Startup(app, idxThread, idxEmission, operationType)

                case app.channelEditMode
                    app.channelEditMode.UserData = ~app.channelEditMode.UserData;
        
                    if app.channelEditMode.UserData
                        layout_editChannelAssigned(app, 'on')
                        focus(app.channelFrequency)        
                    else
                        layout_editChannelAssigned(app, 'off')
                    end

                case app.channelEditCancel
                    layout_editChannelAssigned(app, 'off')
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
            app.GridLayout.ColumnWidth = {18, '100x', 174};
            app.GridLayout.RowHeight = {22, 70};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create PanelIcon
            app.PanelIcon = uiimage(app.GridLayout);
            app.PanelIcon.ScaleMethod = 'none';
            app.PanelIcon.Layout.Row = 1;
            app.PanelIcon.Layout.Column = 1;
            app.PanelIcon.ImageSource = 'Channel_18.png';

            % Create channelLabel
            app.channelLabel = uilabel(app.GridLayout);
            app.channelLabel.VerticalAlignment = 'bottom';
            app.channelLabel.FontSize = 10;
            app.channelLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelLabel.Layout.Row = 1;
            app.channelLabel.Layout.Column = 2;
            app.channelLabel.Text = 'CANAL SOB ANÁLISE';

            % Create channelPanel
            app.channelPanel = uipanel(app.GridLayout);
            app.channelPanel.AutoResizeChildren = 'off';
            app.channelPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelPanel.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.channelPanel.Layout.Row = 2;
            app.channelPanel.Layout.Column = [1 3];

            % Create channelGrid
            app.channelGrid = uigridlayout(app.channelPanel);
            app.channelGrid.ColumnWidth = {'1x', 110};
            app.channelGrid.RowHeight = {22, 22};
            app.channelGrid.RowSpacing = 5;
            app.channelGrid.BackgroundColor = [1 1 1];

            % Create channelFrequencyLabel
            app.channelFrequencyLabel = uilabel(app.channelGrid);
            app.channelFrequencyLabel.FontSize = 11;
            app.channelFrequencyLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelFrequencyLabel.Layout.Row = 1;
            app.channelFrequencyLabel.Layout.Column = 1;
            app.channelFrequencyLabel.Text = 'Frequência central (MHz):';

            % Create channelFrequency
            app.channelFrequency = uieditfield(app.channelGrid, 'numeric');
            app.channelFrequency.Limits = [0 Inf];
            app.channelFrequency.ValueDisplayFormat = '%.3f';
            app.channelFrequency.Editable = 'off';
            app.channelFrequency.FontSize = 11;
            app.channelFrequency.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelFrequency.Layout.Row = 1;
            app.channelFrequency.Layout.Column = 2;

            % Create channelBandWidthLabel
            app.channelBandWidthLabel = uilabel(app.channelGrid);
            app.channelBandWidthLabel.FontSize = 11;
            app.channelBandWidthLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelBandWidthLabel.Layout.Row = 2;
            app.channelBandWidthLabel.Layout.Column = 1;
            app.channelBandWidthLabel.Text = 'Largura (kHz):';

            % Create channelBandWidth
            app.channelBandWidth = uieditfield(app.channelGrid, 'numeric');
            app.channelBandWidth.Limits = [0 Inf];
            app.channelBandWidth.ValueDisplayFormat = '%.1f';
            app.channelBandWidth.Editable = 'off';
            app.channelBandWidth.FontSize = 11;
            app.channelBandWidth.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.channelBandWidth.Layout.Row = 2;
            app.channelBandWidth.Layout.Column = 2;

            % Create channelEditGrid
            app.channelEditGrid = uigridlayout(app.GridLayout);
            app.channelEditGrid.ColumnWidth = {'1x', 18, 18, 0, 0};
            app.channelEditGrid.RowHeight = {'1x'};
            app.channelEditGrid.ColumnSpacing = 5;
            app.channelEditGrid.Padding = [0 0 0 0];
            app.channelEditGrid.Layout.Row = 1;
            app.channelEditGrid.Layout.Column = 3;
            app.channelEditGrid.BackgroundColor = [1 1 1];

            % Create channelRefresh
            app.channelRefresh = uiimage(app.channelEditGrid);
            app.channelRefresh.ImageClickedFcn = createCallbackFcn(app, @channelRefreshImageClicked, true);
            app.channelRefresh.Visible = 'off';
            app.channelRefresh.Tooltip = {'Volta à configuração inicial'};
            app.channelRefresh.Layout.Row = 1;
            app.channelRefresh.Layout.Column = 2;
            app.channelRefresh.VerticalAlignment = 'bottom';
            app.channelRefresh.ImageSource = 'Refresh_18.png';

            % Create channelEditMode
            app.channelEditMode = uiimage(app.channelEditGrid);
            app.channelEditMode.ImageClickedFcn = createCallbackFcn(app, @channelRefreshImageClicked, true);
            app.channelEditMode.Tooltip = {'Possibilita edição dos parâmetros do canal'};
            app.channelEditMode.Layout.Row = 1;
            app.channelEditMode.Layout.Column = 3;
            app.channelEditMode.VerticalAlignment = 'bottom';
            app.channelEditMode.ImageSource = 'Edit_32.png';

            % Create channelEditConfirm
            app.channelEditConfirm = uiimage(app.channelEditGrid);
            app.channelEditConfirm.ImageClickedFcn = createCallbackFcn(app, @channelRefreshImageClicked, true);
            app.channelEditConfirm.Enable = 'off';
            app.channelEditConfirm.Tooltip = {'Confirma edição'};
            app.channelEditConfirm.Layout.Row = 1;
            app.channelEditConfirm.Layout.Column = 4;
            app.channelEditConfirm.VerticalAlignment = 'bottom';
            app.channelEditConfirm.ImageSource = 'Ok_32Green.png';

            % Create channelEditCancel
            app.channelEditCancel = uiimage(app.channelEditGrid);
            app.channelEditCancel.ImageClickedFcn = createCallbackFcn(app, @channelRefreshImageClicked, true);
            app.channelEditCancel.Enable = 'off';
            app.channelEditCancel.Tooltip = {'Cancela edição'};
            app.channelEditCancel.Layout.Row = 1;
            app.channelEditCancel.Layout.Column = 5;
            app.channelEditCancel.VerticalAlignment = 'bottom';
            app.channelEditCancel.ImageSource = 'Delete_32Red.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockEmissionChannel_exported(Container, varargin)

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
