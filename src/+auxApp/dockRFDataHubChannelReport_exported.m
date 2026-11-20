classdef dockRFDataHubChannelReport_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        PdfViewer           matlab.ui.control.HTML
        UndockButton        matlab.ui.control.Image
        DownloadButton      matlab.ui.control.Image
        CacheUpdatedAt      matlab.ui.control.Label
        CacheUpdatedAtIcon  matlab.ui.control.Image
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
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.PdfViewer;
                app.DownloadButton;
                app.UndockButton
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.callingApp.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.PdfViewer.UserData.id,      'style',   struct('borderRadius', '5px')), ... 
                    struct('appName', appName, 'dataTag', app.DownloadButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Baixa versão atual do documento',  'zIndex', 901)), ... 
                    struct('appName', appName, 'dataTag', app.UndockButton.UserData.id,   'tooltip', struct('defaultPosition', 'top', 'textContent', 'Abre documento em leitor externo', 'zIndex', 901)) ... 
                });
            catch
            end
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

            [cacheIdx, errorMsg] = Get(app.channelReportObj, url, operationType);
            if ~isempty(cacheIdx)    
                app.PdfViewer.HTMLSource = app.channelReportObj.cacheMapping.File{cacheIdx};

                downloadAt = [];
                try
                    downloadAt = datetime(app.channelReportObj.cacheMapping.Timestamp{cacheIdx}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Format', 'dd/MM/yyyy HH:mm:ss');
                catch
                end

                if isempty(downloadAt)
                    app.CacheUpdatedAt.Text = app.channelReportObj.cacheMapping.Timestamp{cacheIdx};
                    app.DownloadButton.Visible = 'on';

                else
                    cacheUpdatedAt = strsplit(char(downloadAt));
                    app.CacheUpdatedAt.Text = sprintf('%s às %s', replace(cacheUpdatedAt{1}, '-', '/'), cacheUpdatedAt{2});
                    app.DownloadButton.Visible = hours(datetime('now') - downloadAt) > 24;
                end

                app.UndockButton.Visible = 'on';

            else
                resetPanel(app)

                if ismember(operationType, {'Cache+RealTime', 'RealTime'}) && ~isempty(errorMsg)
                    ui.Dialog(app.UIFigure, 'error', errorMsg);
                end
            end

            if strcmp(app.progressDialog.Visible, 'visible')
                app.progressDialog.Visible = 'hidden';
            end
        end

        %-----------------------------------------------------------------%
        function resetPanel(app)
            app.PdfViewer.HTMLSource = '';
            app.CacheUpdatedAt.Text = '';
            set([app.DownloadButton, app.UndockButton], 'Visible', 'off')
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

                applyJSCustomizations(app)
                updatePanel(app, 'Cache+RealTime')
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: DownloadButton
        function onDownloadButtonClicked(app, event)
            
            updatePanel(app, 'RealTime')

        end

        % Image clicked function: UndockButton
        function onUndockButtonClicked(app, event)
            
            switch app.mainApp.executionMode
                case 'webApp'
                    web(getStationURL(app), '-new')
                otherwise
                    appEngine.util.OperationSystem('openFile', app.PdfViewer.HTMLSource)
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
            app.GridLayout.ColumnWidth = {22, '1x', 22, 22};
            app.GridLayout.RowHeight = {22, '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create CacheUpdatedAtIcon
            app.CacheUpdatedAtIcon = uiimage(app.GridLayout);
            app.CacheUpdatedAtIcon.ScaleMethod = 'none';
            app.CacheUpdatedAtIcon.Enable = 'off';
            app.CacheUpdatedAtIcon.Layout.Row = 1;
            app.CacheUpdatedAtIcon.Layout.Column = 1;
            app.CacheUpdatedAtIcon.ImageSource = 'calendar.svg';

            % Create CacheUpdatedAt
            app.CacheUpdatedAt = uilabel(app.GridLayout);
            app.CacheUpdatedAt.FontSize = 11;
            app.CacheUpdatedAt.FontColor = [0.502 0.502 0.502];
            app.CacheUpdatedAt.Layout.Row = 1;
            app.CacheUpdatedAt.Layout.Column = 2;
            app.CacheUpdatedAt.Text = '';

            % Create DownloadButton
            app.DownloadButton = uiimage(app.GridLayout);
            app.DownloadButton.ScaleMethod = 'none';
            app.DownloadButton.ImageClickedFcn = createCallbackFcn(app, @onDownloadButtonClicked, true);
            app.DownloadButton.Visible = 'off';
            app.DownloadButton.Layout.Row = 1;
            app.DownloadButton.Layout.Column = 3;
            app.DownloadButton.ImageSource = 'Refresh_18.png';

            % Create UndockButton
            app.UndockButton = uiimage(app.GridLayout);
            app.UndockButton.ScaleMethod = 'none';
            app.UndockButton.ImageClickedFcn = createCallbackFcn(app, @onUndockButtonClicked, true);
            app.UndockButton.Visible = 'off';
            app.UndockButton.Layout.Row = 1;
            app.UndockButton.Layout.Column = 4;
            app.UndockButton.ImageSource = 'open-in-window.svg';

            % Create PdfViewer
            app.PdfViewer = uihtml(app.GridLayout);
            app.PdfViewer.Layout.Row = 2;
            app.PdfViewer.Layout.Column = [1 4];

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
