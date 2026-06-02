classdef dockExternalFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        UITable2           matlab.ui.control.Table
        UITable2Button     matlab.ui.control.Image
        UITable2Label      matlab.ui.control.Label
        UITable1           matlab.ui.control.Table
        UITable1Button     matlab.ui.control.Image
        UITable1Label      matlab.ui.control.Label
        ReportModel        matlab.ui.control.DropDown
        ReportModelLabel   matlab.ui.control.Label
        ContextMenu        matlab.ui.container.ContextMenu
        ContextMenuDelete  matlab.ui.container.Menu
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
        jsBackDoor
        progressDialog
        projectData
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%        
        function initialValues(app, context)
            app.UITable1.Data = table( ...
                'Size', [0, 4], ...
                'VariableTypes', {'cell', 'cell', 'cell', 'double'}, ...
                'VariableNames', {'TAG', 'TIPO', 'ARQUIVO', 'ID'} ...
            );

            app.UITable2.Data = table( ...
                'Size', [0, 5], ...
                'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'double'}, ...
                'VariableNames', {'TAG', 'TIPO', 'BANDA', 'ARQUIVO', 'ID'} ...
            );

            refreshPanelContent(app, context)
        end

        %-----------------------------------------------------------------%
        function refreshPanelContent(app, context)
            reportModel = app.projectData.modules.(context).ui.reportModel;
            refreshPanelStatus(app, reportModel)
            
            [~, reportModelIdx] = ismember(reportModel, {app.projectData.report.templates.Name});            
            flowIdxs = find(arrayfun(@(x) x.UserData.ReportInclude, app.mainApp.specData));
            mappingFlowIdxs = [];
            
            if reportModelIdx
                externalFiles = app.projectData.report.templates(reportModelIdx).ExternalFiles;
    
                for ii = 1:numel(externalFiles)
                    tag = externalFiles(ii).Tag;
                    recurrence = externalFiles(ii).Recurrence;
                    type = externalFiles(ii).Type;

                    switch recurrence
                        case 0 % PROJECT
                            app.UITable1.Data(end+1, :) = {tag, type, '', -1};        
                            entryIdx = find(strcmp(app.projectData.ReportAttachments.Tag, tag) & strcmp(app.projectData.ReportAttachments.Type, type));
                            if ~isempty(entryIdx)
                                entryIdx = entryIdx(1);
                                app.UITable1.Data(end, {'ARQUIVO', 'ID'}) = {app.projectData.ReportAttachments.Filename{entryIdx}, app.projectData.ReportAttachments.Id(entryIdx)};
                            end

                        otherwise % FLOW
                            for jj = flowIdxs
                                app.UITable2.Data(end+1, :) = {tag, type, util.HtmlTextGenerator.createTag('Flow', app.mainApp.specData(jj)), '', -1};
                                entryIdx = find(strcmp(app.mainApp.specData(jj).UserData.ReportAttachments.Tag, tag) & strcmp(app.mainApp.specData(jj).UserData.ReportAttachments.Type, type));
                                if ~isempty(entryIdx)
                                    entryIdx = entryIdx(1);
                                    app.UITable2.Data(end, {'ARQUIVO', 'ID'}) = {app.mainApp.specData(jj).UserData.ReportAttachments.Filename{entryIdx}, app.mainApp.specData(jj).UserData.ReportAttachments.Id(entryIdx)};
                                end
                            end

                            mappingFlowIdxs = [mappingFlowIdxs, flowIdxs];
                    end
                end

                app.UITable2.UserData.flowIdxs = mappingFlowIdxs;
            end
        end

        %-----------------------------------------------------------------%
        function refreshPanelStatus(app, reportModel)
            app.ReportModel.Items = {reportModel};
            
            app.UITable1.Data(:, :) = [];
            app.UITable1.Selection  = [];
            
            app.UITable2.Data(:, :) = [];
            app.UITable2.Selection  = [];
            app.UITable2.UserData.flowIdxs = [];

            set([app.UITable1Button, app.UITable2Button], 'Enable', 'off')
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context)

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                app.inputArgs = struct('context', context);
                initialValues(app, context)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Menu selected function: ContextMenuDelete
        function onContextMenuOptionClicked(app, event)
            
            evtSource = event.ContextObject;
            selection = evtSource.Selection;
            if isempty(selection)
                return
            end

            attachmentInfo = struct( ...
                'Type', evtSource.Data.TIPO{selection}, ...
                'Tag', evtSource.Data.TAG{selection}, ...
                'Filename', evtSource.Data.ARQUIVO{selection}, ...
                'Id', evtSource.Data.ID(selection) ...
            );

            attachmentHash = Hash.sha1(char(string(attachmentInfo.Type) + " - " + string(attachmentInfo.Tag) + " - " + string(attachmentInfo.Filename) + " - " + string(attachmentInfo.Id)));

            switch evtSource
                case app.UITable1
                    updateReportAttachments(app.projectData, 'delete', attachmentHash)

                otherwise % app.UITable2
                    flowIdx = app.UITable2.UserData.flowIdxs(selection);
                    update(app.mainApp.specData(flowIdx), 'UserData:ReportAttachments', 'delete', attachmentHash)
            end

            context = app.inputArgs.context;
            refreshPanelContent(app, context)

        end

        % Image clicked function: UITable1Button, UITable2Button
        function onTableButtonClicked(app, event)
            
            switch event.Source
                case app.UITable1Button
                    selection = app.UITable1.Selection;
                    expectedFileType = app.UITable1.Data.TIPO{selection};

                otherwise % app.UITable2Button
                    selection = app.UITable2.Selection;
                    expectedFileType = app.UITable2.Data.TIPO{selection};
            end

            switch expectedFileType
                case 'Image'
                    expectedFileExtensions = {'*.jpg;*.jpeg;*.png'};

                otherwise % 'Table'
                    expectedFileExtensions = {'*.xls;*.xlsx;*.csv;*.txt'};
            end

            [fileFullPath, filePath, fileExt] = ui.Dialog(app.UIFigure, 'uigetfile', '', expectedFileExtensions, app.mainApp.General.fileFolder.lastVisited);

            if isempty(fileFullPath)
                return
            elseif ~iscell(fileFullPath)
                fileFullPath = {fileFullPath};
            end

            switch fileExt
                case {'.xls', '.xlsx', '.csv', '.txt', '.json'}
                    fileType = 'Table';
                case {'.jpg', '.jpeg', '.png'}
                    fileType = 'Image';
                otherwise
                    return
            end

            if ~strcmp(expectedFileType, fileType)
                return
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', filePath);

            switch event.Source
                case app.UITable1Button
                    attachmentInfo = struct( ...
                        'Type', fileType, ...
                        'Tag', app.UITable1.Data.TAG{selection}, ...
                        'Filename', fileFullPath, ...
                        'Id', -1 ...
                    );

                    updateReportAttachments(app.projectData, 'add', attachmentInfo)

                otherwise % app.UITable2Button
                    attachmentInfo = struct( ...
                        'Type', fileType, ...
                        'Tag', app.UITable2.Data.TAG{selection}, ...
                        'Filename', fileFullPath, ...
                        'Id', -1 ...
                    );

                    % Questiona usuário se o arquivo deve ser inserido na lista de
                    % arquivo relacionado a todos os fluxos espectrais
                    flowIdxs = app.UITable2.UserData.flowIdxs;

                    if ~isscalar(flowIdxs)
                        questionMsg = 'Deseja adicionar o arquivo apenas ao fluxo selecionado ou a todos os fluxos espectrais a processar?';
                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 2, 2);

                        if strcmp(userSelection, 'Não')
                            flowIdxs = flowIdxs(selection);
                        end
                    end

                    flowIdxs = unique(flowIdxs);
                    update(app.mainApp.specData(flowIdxs), 'UserData:ReportAttachments', 'add', attachmentInfo)
            end

            context = app.inputArgs.context;
            refreshPanelContent(app, context)

        end

        % Selection changed function: UITable1, UITable2
        function onTableSelectionChanged(app, event)
            
            switch event.Source
                case app.UITable1
                    set(app.UITable2, 'Selection', [], 'ContextMenu', [])

                otherwise % app.UITable2
                    set(app.UITable1, 'Selection', [], 'ContextMenu', [])
            end

            isNonEmptyUITable1Selection = ~isempty(app.UITable1.Selection);
            if isNonEmptyUITable1Selection
                app.UITable1.ContextMenu = app.ContextMenu;
            end

            isNonEmptyUITable2Selection = ~isempty(app.UITable2.Selection);
            if isNonEmptyUITable2Selection
                app.UITable2.ContextMenu = app.ContextMenu;
            end

            app.UITable1Button.Enable   = isNonEmptyUITable1Selection;
            app.UITable2Button.Enable   = isNonEmptyUITable2Selection;
            
        end

        % Cell edit callback: UITable1, UITable2
        function onTableSelectionEdited(app, event)
            
            selection = event.Indices(1);
            newValue  = round(event.NewData);

            if strcmp(event.Source.Data.TIPO{selection}, 'Image') || isempty(event.Source.Data.ARQUIVO{selection}) || isnan(newValue) || newValue <= 0 || isinf(newValue)
                event.Source.Data.ID(selection) = event.PreviousData;
                return
            end

            tag = event.Source.Data.TAG{selection};
            type = event.Source.Data.TIPO{selection};

            switch event.Source
                case app.UITable1
                    entryIdx = find(strcmp(app.projectData.ReportAttachments.Tag, tag) & strcmp(app.projectData.ReportAttachments.Type, type));
                    
                    if ~isempty(entryIdx)
                        entryIdx = entryIdx(1);
                        updateReportAttachments(app.projectData, 'edit', entryIdx, newValue)
                    end

                otherwise % app.UITable2
                    flowIdx = event.Source.UserData.flowIdxs(selection);
                    entryIdx = find(strcmp(app.mainApp.specData(flowIdx).UserData.ReportAttachments.Tag, tag) & strcmp(app.mainApp.specData(flowIdx).UserData.ReportAttachments.Type, type));
                    
                    if ~isempty(entryIdx)
                        entryIdx = entryIdx(1);
                        update(app.mainApp.specData(flowIdx), 'UserData:ReportAttachments', 'edit', entryIdx, newValue)
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
                app.UIFigure.Position = [100 100 880 520];
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
            app.GridLayout.ColumnWidth = {367, '1x', 18};
            app.GridLayout.RowHeight = {17, 22, 22, '0.5x', 22, '1x'};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create ReportModelLabel
            app.ReportModelLabel = uilabel(app.GridLayout);
            app.ReportModelLabel.VerticalAlignment = 'bottom';
            app.ReportModelLabel.FontSize = 11;
            app.ReportModelLabel.Layout.Row = 1;
            app.ReportModelLabel.Layout.Column = 1;
            app.ReportModelLabel.Text = 'Modelo (.json):';

            % Create ReportModel
            app.ReportModel = uidropdown(app.GridLayout);
            app.ReportModel.Items = {};
            app.ReportModel.Enable = 'off';
            app.ReportModel.FontSize = 11;
            app.ReportModel.Layout.Row = 2;
            app.ReportModel.Layout.Column = 1;
            app.ReportModel.Value = {};

            % Create UITable1Label
            app.UITable1Label = uilabel(app.GridLayout);
            app.UITable1Label.VerticalAlignment = 'bottom';
            app.UITable1Label.FontSize = 11;
            app.UITable1Label.Layout.Row = 3;
            app.UITable1Label.Layout.Column = [1 2];
            app.UITable1Label.Interpreter = 'html';
            app.UITable1Label.Text = 'Arquivos externos relacionados ao <b>PROJETO</b>:';

            % Create UITable1Button
            app.UITable1Button = uiimage(app.GridLayout);
            app.UITable1Button.ScaleMethod = 'none';
            app.UITable1Button.ImageClickedFcn = createCallbackFcn(app, @onTableButtonClicked, true);
            app.UITable1Button.Tag = 'DataHub_POST';
            app.UITable1Button.Enable = 'off';
            app.UITable1Button.Layout.Row = 3;
            app.UITable1Button.Layout.Column = 3;
            app.UITable1Button.VerticalAlignment = 'bottom';
            app.UITable1Button.ImageSource = 'folder-opened-16px.svg';

            % Create UITable1
            app.UITable1 = uitable(app.GridLayout);
            app.UITable1.ColumnName = {'TAG'; 'TIPO'; 'ARQUIVO'; 'ID'};
            app.UITable1.ColumnWidth = {90, 90, 'auto', 70};
            app.UITable1.RowName = {};
            app.UITable1.SelectionType = 'row';
            app.UITable1.ColumnEditable = [false false false true];
            app.UITable1.CellEditCallback = createCallbackFcn(app, @onTableSelectionEdited, true);
            app.UITable1.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable1.Multiselect = 'off';
            app.UITable1.Layout.Row = 4;
            app.UITable1.Layout.Column = [1 3];
            app.UITable1.FontSize = 11;

            % Create UITable2Label
            app.UITable2Label = uilabel(app.GridLayout);
            app.UITable2Label.VerticalAlignment = 'bottom';
            app.UITable2Label.FontSize = 11;
            app.UITable2Label.Layout.Row = 5;
            app.UITable2Label.Layout.Column = [1 2];
            app.UITable2Label.Interpreter = 'html';
            app.UITable2Label.Text = 'Arquivos externos relacionados aos <b>FLUXOS ESPECTRAIS A INCLUIR NO RELATÓRIO</b>:';

            % Create UITable2Button
            app.UITable2Button = uiimage(app.GridLayout);
            app.UITable2Button.ScaleMethod = 'none';
            app.UITable2Button.ImageClickedFcn = createCallbackFcn(app, @onTableButtonClicked, true);
            app.UITable2Button.Tag = 'DataHub_POST';
            app.UITable2Button.Enable = 'off';
            app.UITable2Button.Layout.Row = 5;
            app.UITable2Button.Layout.Column = 3;
            app.UITable2Button.VerticalAlignment = 'bottom';
            app.UITable2Button.ImageSource = 'folder-opened-16px.svg';

            % Create UITable2
            app.UITable2 = uitable(app.GridLayout);
            app.UITable2.ColumnName = {'TAG'; 'TIPO'; 'BANDA'; 'ARQUIVO'; 'ID'};
            app.UITable2.ColumnWidth = {90, 90, 150, 'auto', 70};
            app.UITable2.RowName = {};
            app.UITable2.SelectionType = 'row';
            app.UITable2.ColumnEditable = [false false false false true];
            app.UITable2.CellEditCallback = createCallbackFcn(app, @onTableSelectionEdited, true);
            app.UITable2.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable2.Multiselect = 'off';
            app.UITable2.Layout.Row = 6;
            app.UITable2.Layout.Column = [1 3];
            app.UITable2.FontSize = 11;

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.dockAddFiles';

            % Create ContextMenuDelete
            app.ContextMenuDelete = uimenu(app.ContextMenu);
            app.ContextMenuDelete.MenuSelectedFcn = createCallbackFcn(app, @onContextMenuOptionClicked, true);
            app.ContextMenuDelete.Text = '❌ Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockExternalFiles_exported(Container, varargin)

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
