classdef dockExternalFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        btnImport                     matlab.ui.control.Image
        btnImport_2                   matlab.ui.control.Image
        TAGsDEREFERNCIATextArea       matlab.ui.control.TextArea
        TAGsDEREFERNCIATextAreaLabel  matlab.ui.control.Label
        UITableLabel_3                matlab.ui.control.Label
        SpectrumFlowTree              matlab.ui.container.Tree
        ButtonGroup                   matlab.ui.container.ButtonGroup
        FLUXOSESPECTRAISAINCLUIRNORELATRIOButton  matlab.ui.control.RadioButton
        PROJETOButton                 matlab.ui.control.RadioButton
        UITableLabel_2                matlab.ui.control.Label
        btnOK                         matlab.ui.control.Button
        UITable                       matlab.ui.control.Table
        UITableLabel                  matlab.ui.control.Label
        ContextMenu                   matlab.ui.container.ContextMenu
        btnDelete                     matlab.ui.container.Menu
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
        emptyTable  = table( ...
            'Size', [0, 4], ...
            'VariableTypes', {'cell', 'cell', 'cell', 'int8'}, ...
            'VariableNames', {'Type', 'Tag', 'Filename', 'ID'} ...
        );
        
        editionType char {mustBeMember(editionType, {'ProjectData', 'SpectralData'})} = 'ProjectData'
        editionFlag = false
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%        
        function initialValues(app, tags)
            app.TAGsDEREFERNCIATextArea.Value = tags;
            buildTree(app)
        end

        %-----------------------------------------------------------------%
        function buildTree(app)
            if ~isempty(app.SpectrumFlowTree.Children)
                delete(app.SpectrumFlowTree.Children)
            end

            if ~isempty(app.mainApp.specData)
                [receiverList, ~, receiverListIdxs] = unique({app.mainApp.specData.Receiver});
    
                for ii = 1:numel(receiverList)
                    receiverIdxs  = find(receiverListIdxs == ii)';
                    reportIdxs = arrayfun(@(x) x.UserData.ReportInclude, app.mainApp.specData(receiverIdxs));
                    receiverIdxs(~reportIdxs) = [];

                    if isempty(receiverIdxs)
                        continue
                    end

                    receiverNode = uitreenode(app.SpectrumFlowTree, 'Text',  util.layoutTreeNodeText(receiverList{ii}, 'play_TreeBuilding'), ...
                                                                    'NodeData', receiverIdxs, 'Icon', util.layoutTreeNodeIcon(receiverList{ii}), 'Tag', 'RECEIVER');

                    for jj = receiverIdxs
                        uitreenode(receiverNode, 'Text', util.HtmlTextGenerator.createTag('Flow', app.mainApp.specData(jj)), ...
                                                 'NodeData', jj, 'Tag', 'BAND');
                    end
                end

                expand(app.SpectrumFlowTree, 'all')
            end
        end

        %-----------------------------------------------------------------%
        function nodeText = misc_nodeTreeText(app, idx)
            FreqStart = app.specData(idx).MetaData.FreqStart / 1e+6;
            FreqStop  = app.specData(idx).MetaData.FreqStop  / 1e+6;

            nodeText = sprintf('%.3f - %.3f MHz', FreqStart, FreqStop);
        end

        %-----------------------------------------------------------------%
        function srcTable = getTable(app)
            switch app.editionType
                case 'ProjectData'
                    srcTable = app.projectData.externalFiles;
                otherwise
                    idx = Index(app);
                    if isempty(idx)
                        srcTable = app.emptyTable;
                    else
                        srcTable = app.specData(idx).UserData.reportExternalFiles;                        
                    end
            end
        end

        %-----------------------------------------------------------------%
        function setTable(app)
            switch app.editionType
                case 'ProjectData'
                    app.projectData.externalFiles = app.UITable.Data;
                otherwise
                    idx = Index(app);
                    if isempty(idx)
                        return                        
                    end

                    app.specData(idx).UserData.reportExternalFiles = app.UITable.Data;
            end

            TreeBuilding(app)
            app.editionFlag = true;
        end

        %-----------------------------------------------------------------%
        function idx = Index(app)
            if ~isempty(app.SpectrumFlowTree.SelectedNodes) && isscalar(app.SpectrumFlowTree.SelectedNodes.NodeData)
                idx = app.SpectrumFlowTree.SelectedNodes.NodeData;
            else
                idx = [];
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, tags)

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                initialValues(app, tags)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: btnImport
        function btnImportPushed(app, event)
            
            [~, filePath, ~, fileName] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.xls;*.xlsx;*.csv;*.txt;*.json;*.jpg;*.jpeg;*.png'}, app.General.fileFolder.lastVisited, {'MultiSelect', 'on'});

            if isempty(fileName)
                return
            elseif ~iscell(fileName)
                fileName = {fileName};
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', filePath);

            % Questiona usuário se o arquivo deve ser inserido na lista de
            % arquivo relacionado a todos os fluxos espectrais
            msgQuestion   = 'Deseja adicionar o(s) arquivo(s) selecionado(s) a todos os fluxos espectrais a processar?';
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

            switch userSelection
                case 'Sim'
                    idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
                otherwise
                    idxThreads = Index(app);
            end

            fileFullName  = fullfile(filePath, fileName);
            for ii = 1:numel(fileFullName)
                [~,~,fileExt] = fileparts(fileFullName{ii});

                switch lower(fileExt)
                    case {'.xls', '.xlsx', '.csv', '.txt', '.json'}
                        fileType = 'Table';
                    case {'.jpg', '.jpeg', '.png'}
                        fileType = 'Image';
                    otherwise
                        continue
                end
                newRow = {fileType, '-1', fileFullName{ii}, -1};

                app.UITable.Data(end+1, :) = newRow;
                if strcmp(app.editionType, 'ProjectData')
                    app.projectData.externalFiles(end+1, :) = newRow;
                end

                for jj = idxThreads
                    app.specData(jj).UserData.reportExternalFiles(end+1, :) = newRow;
                end
            end

            TreeBuilding(app)
            app.editionFlag = true;

        end

        % Button pushed function: btnOK
        function btnOKAndClosePushed(app, event)
            
            updateFlag = app.editionFlag;
            returnFlag = false;

            ipcMainMatlabCallsHandler(app.mainApp, app, 'REPORT:EXTERNALFILES', updateFlag, returnFlag)
            closeFcn(app)

        end

        % Menu selected function: btnDelete
        function btnDeletePushed(app, event)
            
            idxRow = app.UITable.Selection;
            if ~isempty(idxRow)
                app.UITable.Data(idxRow, :) = [];
                setTable(app)
            end

        end

        % Cell edit callback: UITable
        function UITableCellEdit(app, event)
            
            setTable(app)

        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            
            switch app.ButtonGroup.SelectedObject
                case app.PROJETOButton
                    app.editionType = 'ProjectData';
                    app.SpectrumFlowTree.Enable = 0;                    
                otherwise
                    app.editionType = 'SpectralData';
                    app.SpectrumFlowTree.Enable = 1;                    
            end

            app.UITable.Data = getTable(app);
            
        end

        % Selection changed function: SpectrumFlowTree
        function SpectrumFlowTreeSelectionChanged(app, event)
            
            app.UITable.Data = getTable(app);
            
        end

        % Image clicked function: btnImport_2
        function btnImport_2ImageClicked(app, event)
            
            msgQuestion   = 'Deseja reiniciar o mapeamento entre o projeto e arquivos externos?';
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            if strcmp(userSelection, 'Não')
                return
            end

            app.projectData.externalFiles = app.emptyTable;
            
            idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            for ii = idxThreads
                app.specData(ii).UserData.reportExternalFiles = app.emptyTable;
            end

            app.UITable.Data = getTable(app);
            TreeBuilding(app)
            app.editionFlag = true;

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
            app.GridLayout.ColumnWidth = {22, 5, 22, '1x', 10, '1x', 90};
            app.GridLayout.RowHeight = {17, 5, 56, 5, 22, 5, '1x', 5, 22, 5, '1x', 10, 22};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create UITableLabel
            app.UITableLabel = uilabel(app.GridLayout);
            app.UITableLabel.VerticalAlignment = 'bottom';
            app.UITableLabel.FontSize = 10;
            app.UITableLabel.Layout.Row = 9;
            app.UITableLabel.Layout.Column = [1 7];
            app.UITableLabel.Text = 'ARQUIVOS EXTERNOS';

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'TIPO'; 'TAG'; 'ARQUIVO'; 'ID'};
            app.UITable.ColumnWidth = {70, 110, 'auto', 70};
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.ColumnEditable = [false true false true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.Layout.Row = 11;
            app.UITable.Layout.Column = [1 7];
            app.UITable.FontSize = 11;

            % Create btnOK
            app.btnOK = uibutton(app.GridLayout, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @btnOKAndClosePushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Layout.Row = 13;
            app.btnOK.Layout.Column = 7;
            app.btnOK.Text = 'OK';

            % Create UITableLabel_2
            app.UITableLabel_2 = uilabel(app.GridLayout);
            app.UITableLabel_2.VerticalAlignment = 'bottom';
            app.UITableLabel_2.FontSize = 10;
            app.UITableLabel_2.Layout.Row = 1;
            app.UITableLabel_2.Layout.Column = [1 4];
            app.UITableLabel_2.Text = 'TIPO';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.GridLayout);
            app.ButtonGroup.AutoResizeChildren = 'off';
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.BackgroundColor = [1 1 1];
            app.ButtonGroup.Layout.Row = 3;
            app.ButtonGroup.Layout.Column = [1 4];

            % Create PROJETOButton
            app.PROJETOButton = uiradiobutton(app.ButtonGroup);
            app.PROJETOButton.Text = 'PROJETO';
            app.PROJETOButton.FontSize = 10.5;
            app.PROJETOButton.Position = [10 27 71 22];
            app.PROJETOButton.Value = true;

            % Create FLUXOSESPECTRAISAINCLUIRNORELATRIOButton
            app.FLUXOSESPECTRAISAINCLUIRNORELATRIOButton = uiradiobutton(app.ButtonGroup);
            app.FLUXOSESPECTRAISAINCLUIRNORELATRIOButton.Text = 'FLUXOS ESPECTRAIS A INCLUIR NO RELATÓRIO';
            app.FLUXOSESPECTRAISAINCLUIRNORELATRIOButton.FontSize = 10.5;
            app.FLUXOSESPECTRAISAINCLUIRNORELATRIOButton.Position = [10 6 272 22];

            % Create SpectrumFlowTree
            app.SpectrumFlowTree = uitree(app.GridLayout);
            app.SpectrumFlowTree.SelectionChangedFcn = createCallbackFcn(app, @SpectrumFlowTreeSelectionChanged, true);
            app.SpectrumFlowTree.FontSize = 11;
            app.SpectrumFlowTree.Layout.Row = [3 7];
            app.SpectrumFlowTree.Layout.Column = [6 7];

            % Create UITableLabel_3
            app.UITableLabel_3 = uilabel(app.GridLayout);
            app.UITableLabel_3.VerticalAlignment = 'bottom';
            app.UITableLabel_3.FontSize = 10;
            app.UITableLabel_3.Layout.Row = 1;
            app.UITableLabel_3.Layout.Column = [6 7];
            app.UITableLabel_3.Text = 'FLUXOS ESPECTRAIS A INCLUIR NO RELATÓRIO';

            % Create TAGsDEREFERNCIATextAreaLabel
            app.TAGsDEREFERNCIATextAreaLabel = uilabel(app.GridLayout);
            app.TAGsDEREFERNCIATextAreaLabel.VerticalAlignment = 'bottom';
            app.TAGsDEREFERNCIATextAreaLabel.FontSize = 10;
            app.TAGsDEREFERNCIATextAreaLabel.Layout.Row = 5;
            app.TAGsDEREFERNCIATextAreaLabel.Layout.Column = [1 4];
            app.TAGsDEREFERNCIATextAreaLabel.Text = 'TAGs DE REFERÊNCIA';

            % Create TAGsDEREFERNCIATextArea
            app.TAGsDEREFERNCIATextArea = uitextarea(app.GridLayout);
            app.TAGsDEREFERNCIATextArea.Editable = 'off';
            app.TAGsDEREFERNCIATextArea.FontSize = 11;
            app.TAGsDEREFERNCIATextArea.Layout.Row = 7;
            app.TAGsDEREFERNCIATextArea.Layout.Column = [1 4];

            % Create btnImport_2
            app.btnImport_2 = uiimage(app.GridLayout);
            app.btnImport_2.ScaleMethod = 'none';
            app.btnImport_2.ImageClickedFcn = createCallbackFcn(app, @btnImport_2ImageClicked, true);
            app.btnImport_2.Tooltip = {'Reinicia mapeamento de arquivos'};
            app.btnImport_2.Layout.Row = 13;
            app.btnImport_2.Layout.Column = 1;
            app.btnImport_2.ImageSource = 'Refresh_18.png';

            % Create btnImport
            app.btnImport = uiimage(app.GridLayout);
            app.btnImport.ScaleMethod = 'none';
            app.btnImport.ImageClickedFcn = createCallbackFcn(app, @btnImportPushed, true);
            app.btnImport.Tooltip = {'Seleciona arquivos'};
            app.btnImport.Layout.Row = 13;
            app.btnImport.Layout.Column = 3;
            app.btnImport.ImageSource = 'Import_16.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.dockAddFiles';

            % Create btnDelete
            app.btnDelete = uimenu(app.ContextMenu);
            app.btnDelete.MenuSelectedFcn = createCallbackFcn(app, @btnDeletePushed, true);
            app.btnDelete.Text = 'Deletar';
            
            % Assign app.ContextMenu
            app.UITable.ContextMenu = app.ContextMenu;

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
