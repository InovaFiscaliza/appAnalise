classdef dockAddFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        Document                      matlab.ui.container.GridLayout
        btnImport                     matlab.ui.control.Image
        btnImport_2                   matlab.ui.control.Image
        TAGsDEREFERNCIATextArea       matlab.ui.control.TextArea
        TAGsDEREFERNCIATextAreaLabel  matlab.ui.control.Label
        UITableLabel_3                matlab.ui.control.Label
        report_Tree                   matlab.ui.container.Tree
        ButtonGroup                   matlab.ui.container.ButtonGroup
        FLUXOSAPROCESSARButton        matlab.ui.control.RadioButton
        PROJETOButton                 matlab.ui.control.RadioButton
        UITableLabel_2                matlab.ui.control.Label
        btnOK                         matlab.ui.control.Button
        UITable                       matlab.ui.control.Table
        UITableLabel                  matlab.ui.control.Label
        btnClose                      matlab.ui.control.Image
        ContextMenu                   matlab.ui.container.ContextMenu
        btnDelete                     matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true

        mainApp
        General
        specData
        projectData

        emptyTable  = table('Size',          [0, 4],                           ...
                            'VariableTypes', {'cell', 'cell', 'cell', 'int8'}, ...
                            'VariableNames', {'Type', 'Tag', 'Filename', 'ID'});
        editionType char {mustBeMember(editionType, {'ProjectData', 'SpectralData'})} = 'ProjectData'
        editionFlag = false
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%        
        function initialValues(app, TAGs)
            app.TAGsDEREFERNCIATextArea.Value = TAGs;
            TreeBuilding(app)
            ButtonGroupSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function TreeBuilding(app)
            initialNodeData = Index(app);

            if ~isempty(app.report_Tree.Children)
                delete(app.report_Tree.Children);
            end            
            
            idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            [receiverList, ~, ic] = unique({app.specData(idxThreads).Receiver});

            for ii = 1:numel(receiverList)
                idx2 = find(ic == ii)';
                parentNode = uitreenode(app.report_Tree, 'Text',     receiverList{ii}, ...
                                                         'NodeData', idxThreads(idx2), ...
                                                         'Icon',     util.layoutTreeNodeIcon(receiverList{ii}));                
                for jj = idx2
                    idx3 = idxThreads(jj);
                    childNode = uitreenode(parentNode, 'Text', misc_nodeTreeText(app, idx3), ...
                                                       'NodeData', idx3);
                    if ~isempty(app.specData(idx3).UserData.reportExternalFiles)
                        childNode.Icon = 'attach_32.png';
                    end
                end
            end
            expand(app.report_Tree, 'all')

            if ~isempty(initialNodeData)
                idxSelectedTree = findobj(app.report_Tree.Children, 'NodeData', initialNodeData);
                app.report_Tree.SelectedNodes = idxSelectedTree(end);
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
            if ~isempty(app.report_Tree.SelectedNodes) && isscalar(app.report_Tree.SelectedNodes.NodeData)
                idx = app.report_Tree.SelectedNodes.NodeData;
            else
                idx = [];
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainapp, TAGs)

            app.mainApp     = mainapp;
            app.General     = mainapp.General;
            app.specData    = mainapp.specData;
            app.projectData = mainapp.projectData;

            initialValues(app, TAGs)
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcnCallFromPopupApp', 'mainApp', 'auxApp.dockAddFiles')
            delete(app)
            
        end

        % Image clicked function: btnImport
        function btnImportPushed(app, event)
            
            [fileName, filePath] = uigetfile({'*.xls;*.xlsx;*.csv;*.txt;*.json;*.jpg;*.jpeg;*.png'}, '', app.General.fileFolder.lastVisited, 'MultiSelect', 'on');
            figure(app.UIFigure)

            if isequal(fileName, 0)
                return
            elseif ~iscell(fileName)
                fileName = {fileName};
            end
            app.General.fileFolder.lastVisited = filePath;

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

        % Callback function: btnClose, btnOK
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
                    app.report_Tree.Enable = 0;                    
                otherwise
                    app.editionType = 'SpectralData';
                    app.report_Tree.Enable = 1;                    
            end

            app.UITable.Data = getTable(app);
            
        end

        % Selection changed function: report_Tree
        function report_TreeSelectionChanged(app, event)
            
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
            app.GridLayout.ColumnWidth = {'1x', 30};
            app.GridLayout.RowHeight = {30, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.902 0.902 0.902];

            % Create btnClose
            app.btnClose = uiimage(app.GridLayout);
            app.btnClose.ScaleMethod = 'none';
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @btnOKAndClosePushed, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {18, 22, '1x', '1x', 90};
            app.Document.RowHeight = {17, 56, 22, '1x', 22, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create UITableLabel
            app.UITableLabel = uilabel(app.Document);
            app.UITableLabel.VerticalAlignment = 'bottom';
            app.UITableLabel.FontSize = 10;
            app.UITableLabel.Layout.Row = 5;
            app.UITableLabel.Layout.Column = [1 5];
            app.UITableLabel.Text = 'ARQUIVOS EXTERNOS';

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.ColumnName = {'TIPO'; 'TAG'; 'ARQUIVO'; 'ID'};
            app.UITable.ColumnWidth = {70, 110, 'auto', 70};
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.ColumnEditable = [false true false true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.Layout.Row = 6;
            app.UITable.Layout.Column = [1 5];
            app.UITable.FontSize = 10.5;

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @btnOKAndClosePushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Layout.Row = 7;
            app.btnOK.Layout.Column = 5;
            app.btnOK.Text = 'OK';

            % Create UITableLabel_2
            app.UITableLabel_2 = uilabel(app.Document);
            app.UITableLabel_2.VerticalAlignment = 'bottom';
            app.UITableLabel_2.FontSize = 10;
            app.UITableLabel_2.Layout.Row = 1;
            app.UITableLabel_2.Layout.Column = [1 3];
            app.UITableLabel_2.Text = 'TIPO';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.Document);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.BackgroundColor = [1 1 1];
            app.ButtonGroup.Layout.Row = 2;
            app.ButtonGroup.Layout.Column = [1 3];

            % Create PROJETOButton
            app.PROJETOButton = uiradiobutton(app.ButtonGroup);
            app.PROJETOButton.Text = 'PROJETO';
            app.PROJETOButton.FontSize = 10.5;
            app.PROJETOButton.Position = [10 27 71 22];
            app.PROJETOButton.Value = true;

            % Create FLUXOSAPROCESSARButton
            app.FLUXOSAPROCESSARButton = uiradiobutton(app.ButtonGroup);
            app.FLUXOSAPROCESSARButton.Text = 'FLUXOS A PROCESSAR';
            app.FLUXOSAPROCESSARButton.FontSize = 10.5;
            app.FLUXOSAPROCESSARButton.Position = [10 6 142 22];

            % Create report_Tree
            app.report_Tree = uitree(app.Document);
            app.report_Tree.SelectionChangedFcn = createCallbackFcn(app, @report_TreeSelectionChanged, true);
            app.report_Tree.Enable = 'off';
            app.report_Tree.FontSize = 10;
            app.report_Tree.Layout.Row = [2 4];
            app.report_Tree.Layout.Column = [4 5];

            % Create UITableLabel_3
            app.UITableLabel_3 = uilabel(app.Document);
            app.UITableLabel_3.VerticalAlignment = 'bottom';
            app.UITableLabel_3.FontSize = 10;
            app.UITableLabel_3.Layout.Row = 1;
            app.UITableLabel_3.Layout.Column = [4 5];
            app.UITableLabel_3.Text = 'FLUXOS A PROCESSAR';

            % Create TAGsDEREFERNCIATextAreaLabel
            app.TAGsDEREFERNCIATextAreaLabel = uilabel(app.Document);
            app.TAGsDEREFERNCIATextAreaLabel.VerticalAlignment = 'bottom';
            app.TAGsDEREFERNCIATextAreaLabel.FontSize = 10;
            app.TAGsDEREFERNCIATextAreaLabel.Layout.Row = 3;
            app.TAGsDEREFERNCIATextAreaLabel.Layout.Column = [1 3];
            app.TAGsDEREFERNCIATextAreaLabel.Text = 'TAGs DE REFERÊNCIA';

            % Create TAGsDEREFERNCIATextArea
            app.TAGsDEREFERNCIATextArea = uitextarea(app.Document);
            app.TAGsDEREFERNCIATextArea.Editable = 'off';
            app.TAGsDEREFERNCIATextArea.FontSize = 10.5;
            app.TAGsDEREFERNCIATextArea.Layout.Row = 4;
            app.TAGsDEREFERNCIATextArea.Layout.Column = [1 3];

            % Create btnImport_2
            app.btnImport_2 = uiimage(app.Document);
            app.btnImport_2.ImageClickedFcn = createCallbackFcn(app, @btnImport_2ImageClicked, true);
            app.btnImport_2.Tooltip = {'Reinicia mapeamento de arquivos'};
            app.btnImport_2.Layout.Row = 7;
            app.btnImport_2.Layout.Column = 1;
            app.btnImport_2.ImageSource = 'Refresh_18.png';

            % Create btnImport
            app.btnImport = uiimage(app.Document);
            app.btnImport.ScaleMethod = 'none';
            app.btnImport.ImageClickedFcn = createCallbackFcn(app, @btnImportPushed, true);
            app.btnImport.Tooltip = {'Seleciona arquivos'};
            app.btnImport.Layout.Row = 7;
            app.btnImport.Layout.Column = 2;
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
        function app = dockAddFiles_exported(Container, varargin)

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
