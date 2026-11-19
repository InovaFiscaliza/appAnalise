classdef dockRFDataHubChannelReport_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        ChannelReportViewer             matlab.ui.control.HTML
        ChannelReportUndockButton       matlab.ui.control.Image
        ChannelReportDownloadButton     matlab.ui.control.Image
        ChannelReportDownloadTimeLabel  matlab.ui.control.Label
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
        channelReportObj
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            % O objeto ChannelReport (handle) é compartilhado com o módulo 
            % chamador, reaproveitando o cache de documentos já baixados.
            if isempty(app.channelReportObj)
                app.channelReportObj = RF.ChannelReport;
            end

            resetPanel(app)
            updatePanel(app, 'Cache+RealTime')
        end

        %-----------------------------------------------------------------%
        function updatePanel(app, operationType)
            arguments
                app
                operationType char {mustBeMember(operationType, {'OnlyCache', 'Cache+RealTime', 'RealTime'})}
            end

            url = getStationURL(app);
            if strcmp(url, '-1')
                resetPanel(app)
                return
            end

            % A operação poderá ser demorada caso seja do tipo "Cache+RealTime" 
            % ou "RealTime". 
            if ismember(operationType, {'Cache+RealTime', 'RealTime'})
                app.progressDialog.Visible = 'visible';
            end

            [idxCache, msgError] = Get(app.channelReportObj, url, operationType);
            if ~isempty(idxCache)    
                app.ChannelReportViewer.HTMLSource = app.channelReportObj.cacheMapping.File{idxCache};
                app.ChannelReportDownloadTimeLabel.Text = sprintf('DOWNLOAD EM %s', app.channelReportObj.cacheMapping.Timestamp{idxCache});
                set([app.ChannelReportDownloadButton, app.ChannelReportUndockButton], 'Visible', 'on')

            else
                resetPanel(app)

                if ismember(operationType, {'Cache+RealTime', 'RealTime'}) && ~isempty(msgError)
                    ui.Dialog(app.UIFigure, 'error', msgError);
                end
            end

            if strcmp(app.progressDialog.Visible, 'visible')
                app.progressDialog.Visible = 'hidden';
            end
        end

        %-----------------------------------------------------------------%
        function resetPanel(app)
            app.ChannelReportViewer.HTMLSource = 'Warning2.html';
            app.ChannelReportDownloadTimeLabel.Text = '';
            set([app.ChannelReportDownloadButton, app.ChannelReportUndockButton], 'Visible', 'off')
        end

        %-----------------------------------------------------------------%
        function url = getStationURL(app)
            url = char(app.mainApp.rfDataHub.URL(app.inputArgs.rfDataHubIdx));
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, rfDataHubIdx, channelReportObj)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'rfDataHubIdx', rfDataHubIdx);
                app.channelReportObj = channelReportObj;
                initialValues(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: ChannelReportDownloadButton, 
        % ...and 1 other component
        function onChannelReportButtonClicked(app, event)
            
            if strcmp(app.ChannelReportViewer.HTMLSource, 'Warning2.html')
                return
            end

            switch event.Source
                case app.ChannelReportDownloadButton
                    updatePanel(app, 'RealTime')

                case app.ChannelReportUndockButton
                    switch app.mainApp.executionMode
                        case 'webApp'
                            web(getStationURL(app), '-new')
                        otherwise
                            appEngine.util.OperationSystem('openFile', app.ChannelReportViewer.HTMLSource)
                    end

                    % Fecha o módulo, uma vez que o documento passou a ser
                    % apresentado em leitor externo.
                    if app.isDocked
                        sendEventToHTMLSource(app.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', app.GridLayout.UserData.id))
                    else
                        delete(app)
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
                app.UIFigure.Position = [100 100 412 600];
                app.UIFigure.Name = 'appAnalise';
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.Resize = 'off';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                children = Container.Children;
                if isa(Container, 'matlab.ui.Figure') && isprop(Container, 'RunningAppInstance') && isprop(Container.RunningAppInstance, 'jsBackDoor')
                    children(children == Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)

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
            app.GridLayout.ColumnWidth = {22, 22, '1x'};
            app.GridLayout.RowHeight = {22, '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create ChannelReportDownloadTimeLabel
            app.ChannelReportDownloadTimeLabel = uilabel(app.GridLayout);
            app.ChannelReportDownloadTimeLabel.BackgroundColor = [0.2 0.2 0.2];
            app.ChannelReportDownloadTimeLabel.HorizontalAlignment = 'center';
            app.ChannelReportDownloadTimeLabel.FontSize = 10;
            app.ChannelReportDownloadTimeLabel.FontColor = [0.902 0.902 0.902];
            app.ChannelReportDownloadTimeLabel.Layout.Row = 1;
            app.ChannelReportDownloadTimeLabel.Layout.Column = [1 3];
            app.ChannelReportDownloadTimeLabel.Text = '';

            % Create ChannelReportDownloadButton
            app.ChannelReportDownloadButton = uiimage(app.GridLayout);
            app.ChannelReportDownloadButton.ScaleMethod = 'none';
            app.ChannelReportDownloadButton.ImageClickedFcn = createCallbackFcn(app, @onChannelReportButtonClicked, true);
            app.ChannelReportDownloadButton.Visible = 'off';
            app.ChannelReportDownloadButton.Tooltip = {'Baixa versão atual do documento'};
            app.ChannelReportDownloadButton.Layout.Row = 1;
            app.ChannelReportDownloadButton.Layout.Column = 1;
            app.ChannelReportDownloadButton.ImageSource = 'refresh-18px-white.png';

            % Create ChannelReportUndockButton
            app.ChannelReportUndockButton = uiimage(app.GridLayout);
            app.ChannelReportUndockButton.ScaleMethod = 'none';
            app.ChannelReportUndockButton.ImageClickedFcn = createCallbackFcn(app, @onChannelReportButtonClicked, true);
            app.ChannelReportUndockButton.Visible = 'off';
            app.ChannelReportUndockButton.Tooltip = {'Abre documento em leitor externo'};
            app.ChannelReportUndockButton.Layout.Row = 1;
            app.ChannelReportUndockButton.Layout.Column = 2;
            app.ChannelReportUndockButton.ImageSource = 'Undock_18White.png';

            % Create ChannelReportViewer
            app.ChannelReportViewer = uihtml(app.GridLayout);
            app.ChannelReportViewer.HTMLSource = 'Warning2.html';
            app.ChannelReportViewer.Layout.Row = 2;
            app.ChannelReportViewer.Layout.Column = [1 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockRFDataHubChannelReport_exported(Container, varargin)

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
                children = app.Container.Children;
                if isa(app.Container, 'matlab.ui.Figure') && isprop(app.Container, 'RunningAppInstance') && isprop(app.Container.RunningAppInstance, 'jsBackDoor')
                    children(children == app.Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
