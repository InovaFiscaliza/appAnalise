classdef dockReportLib_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        SpectrumFlowTree        matlab.ui.container.CheckBoxTree
        SpectrumFlowTreeLabel   matlab.ui.control.Label
        reportPanel             matlab.ui.container.Panel
        reportGrid              matlab.ui.container.GridLayout
        reportEntityPanel       matlab.ui.container.Panel
        reportEntityGrid        matlab.ui.container.GridLayout
        reportEntityName        matlab.ui.control.EditField
        reportEntityNameLabel   matlab.ui.control.Label
        reportEntityId          matlab.ui.control.EditField
        reportEntityIdCheck     matlab.ui.control.Image
        reportEntityIdLabel     matlab.ui.control.Label
        reportEntityType        matlab.ui.control.DropDown
        reportEntityTypeLabel   matlab.ui.control.Label
        reportEntityPanelLabel  matlab.ui.control.Label
        reportVersion           matlab.ui.control.DropDown
        reportVersionLabel      matlab.ui.control.Label
        reportModel             matlab.ui.control.DropDown
        reportModelButton       matlab.ui.control.Image
        reportModelLabel        matlab.ui.control.Label
        reportLabel             matlab.ui.control.Label
        eFiscalizaPanel         matlab.ui.container.Panel
        eFiscalizaGrid          matlab.ui.container.GridLayout
        eFiscalizaIssueDetails  matlab.ui.control.Image
        eFiscalizaIssue         matlab.ui.control.NumericEditField
        eFiscalizaIssueLabel    matlab.ui.control.Label
        eFiscalizaUnit          matlab.ui.control.DropDown
        eFiscalizaUnitLabel     matlab.ui.control.Label
        eFiscalizaSystem        matlab.ui.control.DropDown
        eFiscalizaSystemLabel   matlab.ui.control.Label
        eFiscalizaLabel         matlab.ui.control.Label
        prjPanel                matlab.ui.container.Panel
        prjGrid                 matlab.ui.container.GridLayout
        prjLastReportDelete     matlab.ui.control.Image
        prjLastReportView       matlab.ui.control.Image
        prjLastReport           matlab.ui.control.EditField
        prjLastReportLabel      matlab.ui.control.Label
        prjFile                 matlab.ui.control.Label
        prjName                 matlab.ui.control.EditField
        prjNameLabel            matlab.ui.control.Label
        prjNewProjectButton     matlab.ui.control.Image
        prjSaveButton           matlab.ui.control.Image
        prjOpenFileButton       matlab.ui.control.Image
        prjLabel                matlab.ui.control.Label
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
        function updatePanel(app, context)
            % PROJECT INITIALIZATION
            if isempty(app.projectData.modules.(context).ui.system) && ~isequal(app.projectData.modules.(context).ui.system, app.mainApp.General.reportLib.system)
                updateUiInfo(app.projectData, context, 'system', app.mainApp.General.reportLib.system)
            end
            
            if isempty(app.projectData.modules.(context).ui.unit) && ~isequal(app.projectData.modules.(context).ui.unit, app.mainApp.General.reportLib.unit)
                updateUiInfo(app.projectData, context, 'unit', app.mainApp.General.reportLib.unit)
            end

            if isempty(app.projectData.modules.(context).ui.entityTypes)
                updateUiInfo(app.projectData, context, 'entityTypes', app.mainApp.General.reportLib.entityType.options)
                app.projectData.modules.(context).ui.entity.type = app.mainApp.General.reportLib.entityType.default;
            end

            % PROJECT PANEL
            app.prjName.Value = app.projectData.name;
            app.prjSaveButton.Enable = ~isempty(app.projectData.name);
            
            prjFileText = '(projeto ainda não exportado)';
            if isfile(app.projectData.file)
                [~, prjFileName, prjFileExt] = fileparts(app.projectData.file);
                prjFileText = [prjFileName prjFileExt];
            end
            app.prjFile.Text = prjFileText;

            lastHTMLDocFullPath = getGeneratedDocumentFileName(app.projectData, '.html', context);
            if isfile(lastHTMLDocFullPath)
                [~, fileName, fileExt] = fileparts(lastHTMLDocFullPath);
                lastHTMLDocFullPath = [fileName, fileExt];
            end
            app.prjLastReport.Value = lastHTMLDocFullPath;
            set([app.prjLastReportView, app.prjLastReportDelete], 'Enable', ~isempty(app.prjLastReport.Value))

            % eFISCALIZA PANEL
            app.eFiscalizaSystem.Value = app.projectData.modules.(context).ui.system;
            app.eFiscalizaIssue.Value  = app.projectData.modules.(context).ui.issue;
            set(app.eFiscalizaUnit, 'Items', app.mainApp.General.eFiscaliza.defaultValues.unit, 'Value', app.projectData.modules.(context).ui.unit)
            app.eFiscalizaIssueDetails.Enable = (app.eFiscalizaIssue.Value > 0) && ~isinf(app.eFiscalizaIssue.Value);

            % REPORT PANEL
            set(app.reportModel, 'Items', app.projectData.modules.(context).ui.templates, 'Value', app.projectData.modules.(context).ui.reportModel)
            app.reportVersion.Value    = app.projectData.modules.(context).ui.reportVersion;

            [~, reportModelIdx] = ismember(app.reportModel.Value, {app.mainApp.projectData.report.templates.Name});
            app.reportModelButton.Enable = reportModelIdx && ~isempty(app.mainApp.projectData.report.templates(reportModelIdx).ExternalFiles);

            set(app.reportEntityType, 'Items', app.projectData.modules.(context).ui.entityTypes, 'Value', app.projectData.modules.(context).ui.entity.type)
            app.reportEntityName.Value = app.projectData.modules.(context).ui.entity.name;
            
            if app.projectData.modules.(context).ui.entity.status
                backgroundColor = [1,1,1];
                fontColor       = [0,0,0];
            else
                backgroundColor = '#c80b0f';
                fontColor       = [1,1,1];
            end
            set(app.reportEntityId, 'Value', app.projectData.modules.(context).ui.entity.id, 'BackgroundColor', backgroundColor, 'FontColor', fontColor)
            app.reportEntityIdCheck.Enable = ~isempty(app.reportEntityId.Value);

            buildTree(app)
        end

        %-----------------------------------------------------------------%
        function buildTree(app)
            if ~isempty(app.SpectrumFlowTree.Children)
                delete(app.SpectrumFlowTree.Children)
            end

            if ~isempty(app.mainApp.specData)
                [receiverList, ~, receiverListIdxs] = unique({app.mainApp.specData.Receiver});
                checkedNodes = [];
    
                for ii = 1:numel(receiverList)
                    receiverIdxs  = find(receiverListIdxs == ii)';
                    occupancyIdxs = arrayfun(@(x) ismember(x.MetaData.DataType, class.Constants.occDataTypes), app.mainApp.specData(receiverIdxs));
                    receiverIdxs(occupancyIdxs) = [];

                    if isempty(receiverIdxs)
                        continue
                    end

                    receiverNode = uitreenode(app.SpectrumFlowTree, 'Text',  util.layoutTreeNodeText(receiverList{ii}, 'play_TreeBuilding'), ...
                                                                    'NodeData', receiverIdxs, 'Icon', util.layoutTreeNodeIcon(receiverList{ii}), 'Tag', 'RECEIVER');

                    for jj = receiverIdxs
                        treeNode = uitreenode(receiverNode, 'Text', util.HtmlTextGenerator.createTag('Flow', app.mainApp.specData(jj)), ...
                                                            'NodeData', jj, 'Tag', 'BAND');

                        if app.mainApp.specData(jj).UserData.ReportInclude
                            checkedNodes = [checkedNodes; treeNode];
                        end
                    end
                end

                app.SpectrumFlowTree.CheckedNodes = checkedNodes;
                expand(app.SpectrumFlowTree, 'all')
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, varargin)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'varargin', {varargin});
                updatePanel(app, context)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: prjNewProjectButton
        function onProjectRestart(app, event)
            
            msgQuestion = 'Deseja excluir todas as referências do projeto e iniciar um novo projeto?';
            selection   = ui.Dialog(app.UIFigure, "uiconfirm", msgQuestion, {'Sim', 'Não'}, 1, 2, {'Icon', 'error'});
            if strcmp(selection, 'Não')
                return
            end
    
            context = app.inputArgs.context;
            restart(app.projectData, {context}, 'onProjectRestart', app.mainApp.General)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onProjectRestart', context)
            updatePanel(app, context)

        end

        % Image clicked function: prjOpenFileButton
        function onProjectLoad(app, event)
            
            appName  = class.Constants.appName;
            context  = app.inputArgs.context;
            varargin = app.inputArgs.varargin;
            
            [fileFullPath, fileFolder] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.mat', [appName ' (*.mat)']}, app.mainApp.General.fileFolder.lastVisited, {'MultiSelect', 'off'});
            if isempty(fileFullPath)
                return
            end
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', fileFolder)

            d = ui.Dialog(app.UIFigure, "progressdlg", "Em andamento...");
            
            try
                [app.mainApp.measData, msg] = load(app.projectData, context, fileFullPath, app.mainApp.General, varargin{:});
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onProjectLoad', context)
                updatePanel(app, context)

                if ~isempty(msg)
                    ui.Dialog(app.UIFigure, "warning", msg)
                end

            catch ME
                ui.Dialog(app.UIFigure, "error", ME.message);
            end
            
            delete(d)

        end

        % Image clicked function: prjSaveButton
        function onProjectSave(app, event)
            
            appName  = class.Constants.appName;
            context  = app.inputArgs.context;
            varargin = app.inputArgs.varargin;

            if isfile(app.projectData.file)
                if ~checkIfUpdateNeeded(app.projectData, varargin{:})
                    msgQuestion = sprintf('Ao que parece, o projeto "<b>%s</b>" não sofreu alterações.<br><br>Deseja continuar mesmo assim?', app.projectData.name);
                    selection   = ui.Dialog(app.UIFigure, "uiconfirm", msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if strcmp(selection, 'Não')
                        return
                    end
                end

                [defaultPath, defaultFile] = fileparts(app.projectData.file);
                defaultName = fullfile(defaultPath, defaultFile);
            else
                defaultName = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, [appName '_ProjectData'], -1);
            end
            
            projectName = app.projectData.name;
            projectFile = ui.Dialog(app.UIFigure, 'uiputfile', '', {'*.mat', [appName ' (*.mat)']}, defaultName);
            if isempty(projectFile)
                return
            end

            % Fluxos que irão compor o .MAT englobam, também, os de
            % ocupação...
            specDataIdx = find(arrayfun(@(x) x.UserData.ReportInclude, app.mainApp.specData));
            specData = app.mainApp.specData(specDataIdx);

            occupancyFlows = arrayfun(@(x) x.UserData.OccupancyComputationMode.RelatedHashes, specData, 'UniformOutput', false);
            occupancyFlows = horzcat(occupancyFlows{:});

            if ~isempty(occupancyFlows)
                occupancyFlowsIdxs = find(strcmp(occupancyFlows, {specData.Hash}));
                specData = [specData, app.mainApp.specData(occupancyFlowsIdxs)];
            end

            save(app.projectData, 'ProjectData', context, projectName, projectFile, app.mainApp.General.reportLib.outputCompressionMode, specData)
            updatePanel(app, context)

        end

        % Value changing function: prjName
        function onProjectNameChanging(app, event)
            
            changingValue = event.Value;
            app.prjSaveButton.Enable = ~isempty(strtrim(changingValue));
            
        end

        % Value changed function: eFiscalizaIssue, eFiscalizaSystem, 
        % ...and 7 other components
        function onProjectInfoUpdate(app, event)

            context = app.inputArgs.context;

            fieldValue = event.Value;
            switch event.Source
                case app.prjName
                    fieldName = 'name';
                    fieldValue = strtrim(fieldValue);

                case app.eFiscalizaSystem
                    fieldName = 'system';

                case app.eFiscalizaUnit
                    fieldName = 'unit';

                case app.eFiscalizaIssue
                    fieldName = 'issue';

                case app.reportModel
                    fieldName = 'reportModel';

                case app.reportVersion
                    fieldName = 'reportVersion';

                case {app.reportEntityType, app.reportEntityId, app.reportEntityName}
                    [entityId, status] = checkCNPJOrCPF(app.reportEntityId.Value, 'NumberValidation');

                    fieldName = 'entity';
                    fieldValue = struct( ...
                        'type', strtrim(app.reportEntityType.Value), ...
                        'name', strtrim(app.reportEntityName.Value), ...
                        'id', entityId, ...
                        'status', status ...
                    );

                case app.reportEntityIdCheck
                    fieldName = 'entityDetails';
            end

            updateUiInfo(app.projectData, context, fieldName, fieldValue)
            updatePanel(app, context)
            
        end

        % Image clicked function: eFiscalizaIssueDetails
        function onFetchIssueDetails(app, event)
            
            % <VALIDAÇÕES>
            context = app.inputArgs.context;
            issue = app.projectData.modules.(context).ui.issue;
            
            if ~validateReportRequirements(app.projectData, context, 'issue')
                msg = sprintf('O número da inspeção "%.0f" é inválido.', issue);
                ui.Dialog(app.UIFigure, 'warning', msg);
                return
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            system  = app.projectData.modules.(context).ui.system;
            details = getIssueDetailsFromCache(app.projectData, system, issue);

            if ~isempty(details)
                msg = util.HtmlTextGenerator.issueDetails(system, issue, details);
                ui.Dialog(app.UIFigure, 'info', msg);

            else
                if isempty(app.mainApp.eFiscalizaObj) || ~isvalid(app.mainApp.eFiscalizaObj)
                    dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                    dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                    sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'onFetchIssueDetails', 'Fields', dialogBox, 'Context', context))
                else
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onFetchIssueDetails', context)
                end
            end
            % </PROCESSO>

        end

        % Image clicked function: prjLastReportDelete, prjLastReportView
        function onFinalReportFileButtonClicked(app, event)
            
            context = app.inputArgs.context;
            updateNeeded = false;
            lastHTMLDocFullPath = getGeneratedDocumentFileName(app.projectData, '.html', context);

            try
                switch event.Source
                    case app.prjLastReportView                        
                        web(lastHTMLDocFullPath, '-new')

                    case app.prjLastReportDelete
                        delete(lastHTMLDocFullPath)

                        updateNeeded = true;
                        updateGeneratedFiles(app.projectData, context)                        
                end

            catch ME
                updateNeeded = true;
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            if updateNeeded
                updatePanel(app, context)
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onFinalReportFileChanged', context)
            end

        end

        % Image clicked function: reportEntityIdCheck
        function onEntityIdCheckButtonClicked(app, event)
            
            details = getEntityDetailsFromCache(app.projectData, app.reportEntityId.Value);

            if isempty(details)
                app.progressDialog.Visible = 'visible';
                details = getOrFetchEntityDetails(app.projectData, app.reportEntityId.Value);
                app.progressDialog.Visible = 'hidden';
            end

            if ~isempty(details)                
                msg = util.HtmlTextGenerator.entityDetails(app.reportEntityId.Value, details);                
            else
                msg = 'Esta pesquisa está disponível apenas para CNPJs válidos.';
            end
            
            ui.Dialog(app.UIFigure, "none", msg);

        end

        % Callback function: SpectrumFlowTree
        function onReportFlowListChanged(app, event)
            
            checkedNodes = app.SpectrumFlowTree.CheckedNodes;
            flowIdxs = [];
            if ~isempty(checkedNodes)
                flowIdxs = unique([checkedNodes.NodeData]);
            end

            update(app.mainApp.specData, 'UserData:ReportInclude', flowIdxs)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onReportFlowListChanged', app.inputArgs.context)
            
        end

        % Image clicked function: reportModelButton
        function onExternalFileModuleOpenRequest(app, event)
            
            if ~any(arrayfun(@(x) x.UserData.ReportInclude, app.mainApp.specData))
                warningMsg = [ ...
                    'Antes de incluir anexos ao projeto ou a um fluxo espectral, ' ...
                    'defina ao menos um fluxo como "Fluxo a incluir no relatório".' ...
                ];
                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                return
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onExternalFileModuleOpenRequest')

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
                app.UIFigure.Position = [100 100 784 594];
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
            app.GridLayout.ColumnWidth = {286, 81, 10, 286, 5, 22, 5, 22, 5, 22};
            app.GridLayout.RowHeight = {17, 136, 22, 100, 22, 230};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create prjLabel
            app.prjLabel = uilabel(app.GridLayout);
            app.prjLabel.VerticalAlignment = 'bottom';
            app.prjLabel.FontSize = 10;
            app.prjLabel.Layout.Row = 1;
            app.prjLabel.Layout.Column = 1;
            app.prjLabel.Text = 'PROJETO';

            % Create prjOpenFileButton
            app.prjOpenFileButton = uiimage(app.GridLayout);
            app.prjOpenFileButton.ScaleMethod = 'none';
            app.prjOpenFileButton.ImageClickedFcn = createCallbackFcn(app, @onProjectLoad, true);
            app.prjOpenFileButton.Tooltip = {'Abre projeto'};
            app.prjOpenFileButton.Layout.Row = 1;
            app.prjOpenFileButton.Layout.Column = 6;
            app.prjOpenFileButton.VerticalAlignment = 'bottom';
            app.prjOpenFileButton.ImageSource = 'Import_16.png';

            % Create prjSaveButton
            app.prjSaveButton = uiimage(app.GridLayout);
            app.prjSaveButton.ScaleMethod = 'none';
            app.prjSaveButton.ImageClickedFcn = createCallbackFcn(app, @onProjectSave, true);
            app.prjSaveButton.Enable = 'off';
            app.prjSaveButton.Tooltip = {'Salva projeto'};
            app.prjSaveButton.Layout.Row = 1;
            app.prjSaveButton.Layout.Column = 8;
            app.prjSaveButton.VerticalAlignment = 'bottom';
            app.prjSaveButton.ImageSource = 'save.svg';

            % Create prjNewProjectButton
            app.prjNewProjectButton = uiimage(app.GridLayout);
            app.prjNewProjectButton.ScaleMethod = 'none';
            app.prjNewProjectButton.ImageClickedFcn = createCallbackFcn(app, @onProjectRestart, true);
            app.prjNewProjectButton.Tooltip = {'Cria novo projeto'};
            app.prjNewProjectButton.Layout.Row = 1;
            app.prjNewProjectButton.Layout.Column = 10;
            app.prjNewProjectButton.VerticalAlignment = 'bottom';
            app.prjNewProjectButton.ImageSource = 'new-project.svg';

            % Create prjPanel
            app.prjPanel = uipanel(app.GridLayout);
            app.prjPanel.AutoResizeChildren = 'off';
            app.prjPanel.Layout.Row = 2;
            app.prjPanel.Layout.Column = [1 10];

            % Create prjGrid
            app.prjGrid = uigridlayout(app.prjPanel);
            app.prjGrid.ColumnWidth = {130, '1x', 18, 18};
            app.prjGrid.RowHeight = {17, 22, 15, 17, 22};
            app.prjGrid.ColumnSpacing = 5;
            app.prjGrid.RowSpacing = 5;
            app.prjGrid.BackgroundColor = [1 1 1];

            % Create prjNameLabel
            app.prjNameLabel = uilabel(app.prjGrid);
            app.prjNameLabel.FontSize = 11;
            app.prjNameLabel.Layout.Row = 1;
            app.prjNameLabel.Layout.Column = 1;
            app.prjNameLabel.Text = 'Nome do projeto:';

            % Create prjName
            app.prjName = uieditfield(app.prjGrid, 'text');
            app.prjName.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.prjName.ValueChangingFcn = createCallbackFcn(app, @onProjectNameChanging, true);
            app.prjName.FontSize = 11;
            app.prjName.Layout.Row = 2;
            app.prjName.Layout.Column = [1 4];

            % Create prjFile
            app.prjFile = uilabel(app.prjGrid);
            app.prjFile.VerticalAlignment = 'top';
            app.prjFile.FontSize = 10;
            app.prjFile.FontColor = [0.502 0.502 0.502];
            app.prjFile.Layout.Row = 3;
            app.prjFile.Layout.Column = [1 4];
            app.prjFile.Text = '(projeto ainda não exportado)';

            % Create prjLastReportLabel
            app.prjLastReportLabel = uilabel(app.prjGrid);
            app.prjLastReportLabel.VerticalAlignment = 'bottom';
            app.prjLastReportLabel.FontSize = 11;
            app.prjLastReportLabel.Layout.Row = 4;
            app.prjLastReportLabel.Layout.Column = [1 3];
            app.prjLastReportLabel.Text = 'Último relatório gerado:';

            % Create prjLastReport
            app.prjLastReport = uieditfield(app.prjGrid, 'text');
            app.prjLastReport.Editable = 'off';
            app.prjLastReport.FontSize = 11;
            app.prjLastReport.Layout.Row = 5;
            app.prjLastReport.Layout.Column = [1 2];

            % Create prjLastReportView
            app.prjLastReportView = uiimage(app.prjGrid);
            app.prjLastReportView.ScaleMethod = 'none';
            app.prjLastReportView.ImageClickedFcn = createCallbackFcn(app, @onFinalReportFileButtonClicked, true);
            app.prjLastReportView.Enable = 'off';
            app.prjLastReportView.Tooltip = {'Visualiza relatório'};
            app.prjLastReportView.Layout.Row = 5;
            app.prjLastReportView.Layout.Column = 3;
            app.prjLastReportView.ImageSource = 'eye.svg';

            % Create prjLastReportDelete
            app.prjLastReportDelete = uiimage(app.prjGrid);
            app.prjLastReportDelete.ScaleMethod = 'none';
            app.prjLastReportDelete.ImageClickedFcn = createCallbackFcn(app, @onFinalReportFileButtonClicked, true);
            app.prjLastReportDelete.Enable = 'off';
            app.prjLastReportDelete.Tooltip = {'Exclui relatório'};
            app.prjLastReportDelete.Layout.Row = 5;
            app.prjLastReportDelete.Layout.Column = 4;
            app.prjLastReportDelete.ImageSource = 'close-16px-red.svg';

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.GridLayout);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontSize = 10;
            app.eFiscalizaLabel.Layout.Row = 3;
            app.eFiscalizaLabel.Layout.Column = 1;
            app.eFiscalizaLabel.Text = 'eFISCALIZA';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.GridLayout);
            app.eFiscalizaPanel.AutoResizeChildren = 'off';
            app.eFiscalizaPanel.Layout.Row = 4;
            app.eFiscalizaPanel.Layout.Column = [1 2];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {'1x', 123, 18};
            app.eFiscalizaGrid.RowHeight = {22, 22, 22};
            app.eFiscalizaGrid.ColumnSpacing = 5;
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [1 1 1];

            % Create eFiscalizaSystemLabel
            app.eFiscalizaSystemLabel = uilabel(app.eFiscalizaGrid);
            app.eFiscalizaSystemLabel.VerticalAlignment = 'top';
            app.eFiscalizaSystemLabel.WordWrap = 'on';
            app.eFiscalizaSystemLabel.FontSize = 11;
            app.eFiscalizaSystemLabel.Layout.Row = [1 2];
            app.eFiscalizaSystemLabel.Layout.Column = 1;
            app.eFiscalizaSystemLabel.Text = 'Ambiente do sistema de gestão à fiscalização:';

            % Create eFiscalizaSystem
            app.eFiscalizaSystem = uidropdown(app.eFiscalizaGrid);
            app.eFiscalizaSystem.Items = {'eFiscaliza', 'eFiscaliza TS', 'eFiscaliza HM', 'eFiscaliza DS'};
            app.eFiscalizaSystem.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.eFiscalizaSystem.FontSize = 11;
            app.eFiscalizaSystem.BackgroundColor = [1 1 1];
            app.eFiscalizaSystem.Layout.Row = 1;
            app.eFiscalizaSystem.Layout.Column = [2 3];
            app.eFiscalizaSystem.Value = 'eFiscaliza';

            % Create eFiscalizaUnitLabel
            app.eFiscalizaUnitLabel = uilabel(app.eFiscalizaGrid);
            app.eFiscalizaUnitLabel.FontSize = 11;
            app.eFiscalizaUnitLabel.Layout.Row = 2;
            app.eFiscalizaUnitLabel.Layout.Column = 1;
            app.eFiscalizaUnitLabel.Text = 'Unidade responsável pela fiscalização:';

            % Create eFiscalizaUnit
            app.eFiscalizaUnit = uidropdown(app.eFiscalizaGrid);
            app.eFiscalizaUnit.Items = {};
            app.eFiscalizaUnit.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.eFiscalizaUnit.FontSize = 11;
            app.eFiscalizaUnit.BackgroundColor = [1 1 1];
            app.eFiscalizaUnit.Layout.Row = 2;
            app.eFiscalizaUnit.Layout.Column = [2 3];
            app.eFiscalizaUnit.Value = {};

            % Create eFiscalizaIssueLabel
            app.eFiscalizaIssueLabel = uilabel(app.eFiscalizaGrid);
            app.eFiscalizaIssueLabel.FontSize = 11;
            app.eFiscalizaIssueLabel.Layout.Row = 3;
            app.eFiscalizaIssueLabel.Layout.Column = 1;
            app.eFiscalizaIssueLabel.Text = 'Atividade de inspeção (# ID):';

            % Create eFiscalizaIssue
            app.eFiscalizaIssue = uieditfield(app.eFiscalizaGrid, 'numeric');
            app.eFiscalizaIssue.Limits = [-1 Inf];
            app.eFiscalizaIssue.RoundFractionalValues = 'on';
            app.eFiscalizaIssue.ValueDisplayFormat = '%d';
            app.eFiscalizaIssue.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.eFiscalizaIssue.FontSize = 11;
            app.eFiscalizaIssue.Layout.Row = 3;
            app.eFiscalizaIssue.Layout.Column = 2;
            app.eFiscalizaIssue.Value = -1;

            % Create eFiscalizaIssueDetails
            app.eFiscalizaIssueDetails = uiimage(app.eFiscalizaGrid);
            app.eFiscalizaIssueDetails.ScaleMethod = 'none';
            app.eFiscalizaIssueDetails.ImageClickedFcn = createCallbackFcn(app, @onFetchIssueDetails, true);
            app.eFiscalizaIssueDetails.Enable = 'off';
            app.eFiscalizaIssueDetails.Tooltip = {'Detalhes da inspeção'};
            app.eFiscalizaIssueDetails.Layout.Row = 3;
            app.eFiscalizaIssueDetails.Layout.Column = 3;
            app.eFiscalizaIssueDetails.ImageSource = 'eye.svg';

            % Create reportLabel
            app.reportLabel = uilabel(app.GridLayout);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontSize = 10;
            app.reportLabel.Layout.Row = 5;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'RELATÓRIO';

            % Create reportPanel
            app.reportPanel = uipanel(app.GridLayout);
            app.reportPanel.AutoResizeChildren = 'off';
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 6;
            app.reportPanel.Layout.Column = [1 2];

            % Create reportGrid
            app.reportGrid = uigridlayout(app.reportPanel);
            app.reportGrid.ColumnWidth = {'1x', 150, 150, 18};
            app.reportGrid.RowHeight = {17, 22, 22, 15, '1x'};
            app.reportGrid.RowSpacing = 5;
            app.reportGrid.BackgroundColor = [1 1 1];

            % Create reportModelLabel
            app.reportModelLabel = uilabel(app.reportGrid);
            app.reportModelLabel.VerticalAlignment = 'bottom';
            app.reportModelLabel.FontSize = 11;
            app.reportModelLabel.Layout.Row = 1;
            app.reportModelLabel.Layout.Column = [1 2];
            app.reportModelLabel.Text = 'Modelo (.json):';

            % Create reportModelButton
            app.reportModelButton = uiimage(app.reportGrid);
            app.reportModelButton.ImageClickedFcn = createCallbackFcn(app, @onExternalFileModuleOpenRequest, true);
            app.reportModelButton.Enable = 'off';
            app.reportModelButton.Tooltip = {'Adiciona arquivos externos'};
            app.reportModelButton.Layout.Row = 1;
            app.reportModelButton.Layout.Column = 4;
            app.reportModelButton.VerticalAlignment = 'bottom';
            app.reportModelButton.ImageSource = 'attach_32.png';

            % Create reportModel
            app.reportModel = uidropdown(app.reportGrid);
            app.reportModel.Items = {''};
            app.reportModel.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportModel.FontSize = 11;
            app.reportModel.BackgroundColor = [1 1 1];
            app.reportModel.Layout.Row = 2;
            app.reportModel.Layout.Column = [1 4];
            app.reportModel.Value = '';

            % Create reportVersionLabel
            app.reportVersionLabel = uilabel(app.reportGrid);
            app.reportVersionLabel.WordWrap = 'on';
            app.reportVersionLabel.FontSize = 11;
            app.reportVersionLabel.Layout.Row = 3;
            app.reportVersionLabel.Layout.Column = [1 2];
            app.reportVersionLabel.Text = 'Versão do relatório:';

            % Create reportVersion
            app.reportVersion = uidropdown(app.reportGrid);
            app.reportVersion.Items = {'Preliminar', 'Definitiva'};
            app.reportVersion.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportVersion.FontSize = 11;
            app.reportVersion.BackgroundColor = [1 1 1];
            app.reportVersion.Layout.Row = 3;
            app.reportVersion.Layout.Column = [3 4];
            app.reportVersion.Value = 'Preliminar';

            % Create reportEntityPanelLabel
            app.reportEntityPanelLabel = uilabel(app.reportGrid);
            app.reportEntityPanelLabel.VerticalAlignment = 'bottom';
            app.reportEntityPanelLabel.FontSize = 11;
            app.reportEntityPanelLabel.Layout.Row = 4;
            app.reportEntityPanelLabel.Layout.Column = [1 2];
            app.reportEntityPanelLabel.Text = 'Fiscalizada';

            % Create reportEntityPanel
            app.reportEntityPanel = uipanel(app.reportGrid);
            app.reportEntityPanel.AutoResizeChildren = 'off';
            app.reportEntityPanel.Layout.Row = 5;
            app.reportEntityPanel.Layout.Column = [1 4];

            % Create reportEntityGrid
            app.reportEntityGrid = uigridlayout(app.reportEntityPanel);
            app.reportEntityGrid.ColumnWidth = {'1x', 114, 16};
            app.reportEntityGrid.RowHeight = {17, 22, 17, 22};
            app.reportEntityGrid.RowSpacing = 5;
            app.reportEntityGrid.Padding = [10 10 10 5];
            app.reportEntityGrid.BackgroundColor = [1 1 1];

            % Create reportEntityTypeLabel
            app.reportEntityTypeLabel = uilabel(app.reportEntityGrid);
            app.reportEntityTypeLabel.VerticalAlignment = 'bottom';
            app.reportEntityTypeLabel.FontSize = 11;
            app.reportEntityTypeLabel.Layout.Row = 1;
            app.reportEntityTypeLabel.Layout.Column = 1;
            app.reportEntityTypeLabel.Text = 'Tipo:';

            % Create reportEntityType
            app.reportEntityType = uidropdown(app.reportEntityGrid);
            app.reportEntityType.Items = {};
            app.reportEntityType.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportEntityType.FontSize = 11;
            app.reportEntityType.BackgroundColor = [1 1 1];
            app.reportEntityType.Layout.Row = 2;
            app.reportEntityType.Layout.Column = 1;
            app.reportEntityType.Value = {};

            % Create reportEntityIdLabel
            app.reportEntityIdLabel = uilabel(app.reportEntityGrid);
            app.reportEntityIdLabel.VerticalAlignment = 'bottom';
            app.reportEntityIdLabel.WordWrap = 'on';
            app.reportEntityIdLabel.FontSize = 11;
            app.reportEntityIdLabel.Layout.Row = 1;
            app.reportEntityIdLabel.Layout.Column = 2;
            app.reportEntityIdLabel.Text = 'CNPJ/CPF:';

            % Create reportEntityIdCheck
            app.reportEntityIdCheck = uiimage(app.reportEntityGrid);
            app.reportEntityIdCheck.ImageClickedFcn = createCallbackFcn(app, @onEntityIdCheckButtonClicked, true);
            app.reportEntityIdCheck.Enable = 'off';
            app.reportEntityIdCheck.Tooltip = {'Consulta'};
            app.reportEntityIdCheck.Layout.Row = 1;
            app.reportEntityIdCheck.Layout.Column = 3;
            app.reportEntityIdCheck.VerticalAlignment = 'bottom';
            app.reportEntityIdCheck.ImageSource = 'Info_32.png';

            % Create reportEntityId
            app.reportEntityId = uieditfield(app.reportEntityGrid, 'text');
            app.reportEntityId.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportEntityId.FontSize = 11;
            app.reportEntityId.Layout.Row = 2;
            app.reportEntityId.Layout.Column = [2 3];

            % Create reportEntityNameLabel
            app.reportEntityNameLabel = uilabel(app.reportEntityGrid);
            app.reportEntityNameLabel.VerticalAlignment = 'bottom';
            app.reportEntityNameLabel.WordWrap = 'on';
            app.reportEntityNameLabel.FontSize = 11;
            app.reportEntityNameLabel.Layout.Row = 3;
            app.reportEntityNameLabel.Layout.Column = 1;
            app.reportEntityNameLabel.Text = 'Nome da fiscalizada:';

            % Create reportEntityName
            app.reportEntityName = uieditfield(app.reportEntityGrid, 'text');
            app.reportEntityName.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportEntityName.FontSize = 11;
            app.reportEntityName.Layout.Row = 4;
            app.reportEntityName.Layout.Column = [1 3];

            % Create SpectrumFlowTreeLabel
            app.SpectrumFlowTreeLabel = uilabel(app.GridLayout);
            app.SpectrumFlowTreeLabel.VerticalAlignment = 'bottom';
            app.SpectrumFlowTreeLabel.FontSize = 10;
            app.SpectrumFlowTreeLabel.Layout.Row = 3;
            app.SpectrumFlowTreeLabel.Layout.Column = 4;
            app.SpectrumFlowTreeLabel.Text = 'FLUXOS ESPECTRAIS A INCLUIR NO RELATÓRIO';

            % Create SpectrumFlowTree
            app.SpectrumFlowTree = uitree(app.GridLayout, 'checkbox');
            app.SpectrumFlowTree.FontSize = 11;
            app.SpectrumFlowTree.Layout.Row = [4 6];
            app.SpectrumFlowTree.Layout.Column = [4 10];

            % Assign Checked Nodes
            app.SpectrumFlowTree.CheckedNodesChangedFcn = createCallbackFcn(app, @onReportFlowListChanged, true);

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockReportLib_exported(Container, varargin)

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
