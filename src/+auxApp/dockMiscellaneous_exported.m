classdef dockMiscellaneous_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        OPERAESLabel              matlab.ui.control.Label
        FLUXOSESPECTRAISLabel     matlab.ui.control.Label
        misc_Panel1               matlab.ui.container.Panel
        misc_Grid1                matlab.ui.container.GridLayout
        Image_2                   matlab.ui.control.Image
        Image                     matlab.ui.control.Image
        misc_DeleteAllLabel       matlab.ui.control.Label
        misc_DeleteAll            matlab.ui.control.Button
        misc_AddCorrectionLabel   matlab.ui.control.Label
        misc_AddCorrection        matlab.ui.control.Button
        misc_EditLocationLabel    matlab.ui.control.Label
        misc_EditLocation         matlab.ui.control.Button
        misc_LevelFilteringLabel  matlab.ui.control.Label
        misc_LevelFiltering       matlab.ui.control.Button
        misc_TimeFilteringLabel   matlab.ui.control.Label
        misc_TimeFiltering        matlab.ui.control.Button
        misc_ImportLabel          matlab.ui.control.Label
        misc_Import               matlab.ui.control.Button
        misc_ExportLabel          matlab.ui.control.Label
        misc_Export               matlab.ui.control.Button
        misc_MergeLabel           matlab.ui.control.Label
        misc_Merge                matlab.ui.control.Button
        misc_DuplicateLabel       matlab.ui.control.Label
        misc_Duplicate            matlab.ui.control.Button
        misc_SaveLabel            matlab.ui.control.Label
        misc_Save                 matlab.ui.control.Button
        play_Tree                 matlab.ui.container.Tree
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
        function buildFlowTree(app, idx)
            arguments
                app 
                idx = []
            end

            if isempty(idx)
                idx = Index(app);
            end

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

            if ~isempty(idx)
                idxSelectedTree = findobj(app.report_Tree.Children, 'NodeData', idx);
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

            buildFlowTree(app)
            app.editionFlag = true;
        end

        %-----------------------------------------------------------------%
        function idx = Index(app)
            if ~isempty(app.play_Tree.SelectedNodes) && isscalar(app.play_Tree.SelectedNodes.NodeData)
                idx = app.report_Tree.SelectedNodes.NodeData;
            else
                idx = [];
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context)

            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context);
                % updatePanel(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function
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

            buildFlowTree(app)
            app.editionFlag = true;

        end

        % Callback function
        function btnOKAndClosePushed(app, event)
            
            updateFlag = app.editionFlag;
            returnFlag = false;

            ipcMainMatlabCallsHandler(app.mainApp, app, 'REPORT:EXTERNALFILES', updateFlag, returnFlag)
            closeFcn(app)

        end

        % Callback function
        function btnDeletePushed(app, event)
            
            idxRow = app.UITable.Selection;
            if ~isempty(idxRow)
                app.UITable.Data(idxRow, :) = [];
                setTable(app)
            end

        end

        % Callback function
        function UITableCellEdit(app, event)
            
            setTable(app)

        end

        % Callback function
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

        % Callback function
        function report_TreeSelectionChanged(app, event)
            
            app.UITable.Data = getTable(app);
            
        end

        % Callback function
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
            buildFlowTree(app)
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
                app.UIFigure.Position = [100 100 880 480];
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
            app.GridLayout.ColumnWidth = {320, '1x'};
            app.GridLayout.RowHeight = {22, '1x'};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create play_Tree
            app.play_Tree = uitree(app.GridLayout);
            app.play_Tree.Multiselect = 'on';
            app.play_Tree.FontSize = 10;
            app.play_Tree.FontColor = [0.651 0.651 0.651];
            app.play_Tree.Layout.Row = 2;
            app.play_Tree.Layout.Column = 1;

            % Create misc_Panel1
            app.misc_Panel1 = uipanel(app.GridLayout);
            app.misc_Panel1.AutoResizeChildren = 'off';
            app.misc_Panel1.Layout.Row = 2;
            app.misc_Panel1.Layout.Column = 2;

            % Create misc_Grid1
            app.misc_Grid1 = uigridlayout(app.misc_Panel1);
            app.misc_Grid1.ColumnWidth = {3, 28, 3, 3, 28, 3, 3, 28, 3, 3, 3, 28, 3, 3, 28, 3, 3, 28, 3, 3, 28, 3, 3, 3, 28, 3, 3, 28, 3};
            app.misc_Grid1.RowHeight = {1, 34, 26, 1, 34, 26, '1x', 34, 26};
            app.misc_Grid1.ColumnSpacing = 5;
            app.misc_Grid1.RowSpacing = 5;
            app.misc_Grid1.Padding = [10 10 10 5];
            app.misc_Grid1.BackgroundColor = [1 1 1];

            % Create misc_Save
            app.misc_Save = uibutton(app.misc_Grid1, 'push');
            app.misc_Save.Icon = 'save.svg';
            app.misc_Save.BackgroundColor = [1 1 1];
            app.misc_Save.FontSize = 10;
            app.misc_Save.Tooltip = {''};
            app.misc_Save.Layout.Row = 2;
            app.misc_Save.Layout.Column = 2;
            app.misc_Save.Text = '';

            % Create misc_SaveLabel
            app.misc_SaveLabel = uilabel(app.misc_Grid1);
            app.misc_SaveLabel.HorizontalAlignment = 'center';
            app.misc_SaveLabel.WordWrap = 'on';
            app.misc_SaveLabel.FontSize = 10;
            app.misc_SaveLabel.Layout.Row = 3;
            app.misc_SaveLabel.Layout.Column = [1 3];
            app.misc_SaveLabel.Text = {'Salvar'; 'fluxo(s)'};

            % Create misc_Duplicate
            app.misc_Duplicate = uibutton(app.misc_Grid1, 'push');
            app.misc_Duplicate.Icon = 'copy-20px.svg';
            app.misc_Duplicate.BackgroundColor = [1 1 1];
            app.misc_Duplicate.FontSize = 10;
            app.misc_Duplicate.Tooltip = {''};
            app.misc_Duplicate.Layout.Row = 2;
            app.misc_Duplicate.Layout.Column = 5;
            app.misc_Duplicate.Text = '';

            % Create misc_DuplicateLabel
            app.misc_DuplicateLabel = uilabel(app.misc_Grid1);
            app.misc_DuplicateLabel.HorizontalAlignment = 'center';
            app.misc_DuplicateLabel.WordWrap = 'on';
            app.misc_DuplicateLabel.FontSize = 10;
            app.misc_DuplicateLabel.Layout.Row = 3;
            app.misc_DuplicateLabel.Layout.Column = [4 6];
            app.misc_DuplicateLabel.Text = {'Duplicar'; 'fluxo(s)'};

            % Create misc_Merge
            app.misc_Merge = uibutton(app.misc_Grid1, 'push');
            app.misc_Merge.Icon = 'Merge_18.png';
            app.misc_Merge.BackgroundColor = [1 1 1];
            app.misc_Merge.FontSize = 10;
            app.misc_Merge.Tooltip = {''};
            app.misc_Merge.Layout.Row = 2;
            app.misc_Merge.Layout.Column = 8;
            app.misc_Merge.Text = '';

            % Create misc_MergeLabel
            app.misc_MergeLabel = uilabel(app.misc_Grid1);
            app.misc_MergeLabel.HorizontalAlignment = 'center';
            app.misc_MergeLabel.WordWrap = 'on';
            app.misc_MergeLabel.FontSize = 10;
            app.misc_MergeLabel.Layout.Row = 3;
            app.misc_MergeLabel.Layout.Column = [7 9];
            app.misc_MergeLabel.Text = {'Mesclar'; 'fluxos'};

            % Create misc_Export
            app.misc_Export = uibutton(app.misc_Grid1, 'push');
            app.misc_Export.Icon = 'Export_16.png';
            app.misc_Export.BackgroundColor = [1 1 1];
            app.misc_Export.FontSize = 10;
            app.misc_Export.Tooltip = {''};
            app.misc_Export.Layout.Row = 2;
            app.misc_Export.Layout.Column = 25;
            app.misc_Export.Text = '';

            % Create misc_ExportLabel
            app.misc_ExportLabel = uilabel(app.misc_Grid1);
            app.misc_ExportLabel.HorizontalAlignment = 'center';
            app.misc_ExportLabel.WordWrap = 'on';
            app.misc_ExportLabel.FontSize = 10;
            app.misc_ExportLabel.Layout.Row = 3;
            app.misc_ExportLabel.Layout.Column = [24 26];
            app.misc_ExportLabel.Text = {'Exportar'; 'análise'};

            % Create misc_Import
            app.misc_Import = uibutton(app.misc_Grid1, 'push');
            app.misc_Import.Icon = 'Import_16.png';
            app.misc_Import.BackgroundColor = [1 1 1];
            app.misc_Import.FontSize = 10;
            app.misc_Import.Tooltip = {''};
            app.misc_Import.Layout.Row = 2;
            app.misc_Import.Layout.Column = 28;
            app.misc_Import.Text = '';

            % Create misc_ImportLabel
            app.misc_ImportLabel = uilabel(app.misc_Grid1);
            app.misc_ImportLabel.HorizontalAlignment = 'center';
            app.misc_ImportLabel.WordWrap = 'on';
            app.misc_ImportLabel.FontSize = 10;
            app.misc_ImportLabel.Layout.Row = 3;
            app.misc_ImportLabel.Layout.Column = [27 29];
            app.misc_ImportLabel.Text = {'Importar'; 'análise'};

            % Create misc_TimeFiltering
            app.misc_TimeFiltering = uibutton(app.misc_Grid1, 'push');
            app.misc_TimeFiltering.Icon = 'Filter_18.png';
            app.misc_TimeFiltering.BackgroundColor = [1 1 1];
            app.misc_TimeFiltering.Tooltip = {''};
            app.misc_TimeFiltering.Layout.Row = 2;
            app.misc_TimeFiltering.Layout.Column = 15;
            app.misc_TimeFiltering.Text = '';

            % Create misc_TimeFilteringLabel
            app.misc_TimeFilteringLabel = uilabel(app.misc_Grid1);
            app.misc_TimeFilteringLabel.HorizontalAlignment = 'center';
            app.misc_TimeFilteringLabel.WordWrap = 'on';
            app.misc_TimeFilteringLabel.FontSize = 10;
            app.misc_TimeFilteringLabel.Layout.Row = 3;
            app.misc_TimeFilteringLabel.Layout.Column = [14 16];
            app.misc_TimeFilteringLabel.Text = 'Filtro temporal';

            % Create misc_LevelFiltering
            app.misc_LevelFiltering = uibutton(app.misc_Grid1, 'push');
            app.misc_LevelFiltering.Icon = 'clear_breakpoints_16.png';
            app.misc_LevelFiltering.BackgroundColor = [1 1 1];
            app.misc_LevelFiltering.Tooltip = {''};
            app.misc_LevelFiltering.Layout.Row = 2;
            app.misc_LevelFiltering.Layout.Column = 18;
            app.misc_LevelFiltering.Text = '';

            % Create misc_LevelFilteringLabel
            app.misc_LevelFilteringLabel = uilabel(app.misc_Grid1);
            app.misc_LevelFilteringLabel.HorizontalAlignment = 'center';
            app.misc_LevelFilteringLabel.WordWrap = 'on';
            app.misc_LevelFilteringLabel.FontSize = 10;
            app.misc_LevelFilteringLabel.Layout.Row = 3;
            app.misc_LevelFilteringLabel.Layout.Column = [17 19];
            app.misc_LevelFilteringLabel.Text = {'Filtro'; 'nível'};

            % Create misc_EditLocation
            app.misc_EditLocation = uibutton(app.misc_Grid1, 'push');
            app.misc_EditLocation.Icon = 'Pin_32.png';
            app.misc_EditLocation.BackgroundColor = [1 1 1];
            app.misc_EditLocation.Tooltip = {''};
            app.misc_EditLocation.Layout.Row = 2;
            app.misc_EditLocation.Layout.Column = 12;
            app.misc_EditLocation.Text = '';

            % Create misc_EditLocationLabel
            app.misc_EditLocationLabel = uilabel(app.misc_Grid1);
            app.misc_EditLocationLabel.HorizontalAlignment = 'center';
            app.misc_EditLocationLabel.WordWrap = 'on';
            app.misc_EditLocationLabel.FontSize = 10;
            app.misc_EditLocationLabel.Layout.Row = 3;
            app.misc_EditLocationLabel.Layout.Column = [11 13];
            app.misc_EditLocationLabel.Text = {'Editar'; 'Local'};

            % Create misc_AddCorrection
            app.misc_AddCorrection = uibutton(app.misc_Grid1, 'push');
            app.misc_AddCorrection.Icon = 'RFFilter_32.png';
            app.misc_AddCorrection.BackgroundColor = [1 1 1];
            app.misc_AddCorrection.Tooltip = {''};
            app.misc_AddCorrection.Layout.Row = 2;
            app.misc_AddCorrection.Layout.Column = 21;
            app.misc_AddCorrection.Text = '';

            % Create misc_AddCorrectionLabel
            app.misc_AddCorrectionLabel = uilabel(app.misc_Grid1);
            app.misc_AddCorrectionLabel.HorizontalAlignment = 'center';
            app.misc_AddCorrectionLabel.WordWrap = 'on';
            app.misc_AddCorrectionLabel.FontSize = 10;
            app.misc_AddCorrectionLabel.Layout.Row = 3;
            app.misc_AddCorrectionLabel.Layout.Column = [20 22];
            app.misc_AddCorrectionLabel.Text = {'Aplicar'; 'correção'};

            % Create misc_DeleteAll
            app.misc_DeleteAll = uibutton(app.misc_Grid1, 'push');
            app.misc_DeleteAll.Icon = 'Trash_32.png';
            app.misc_DeleteAll.BackgroundColor = [1 1 1];
            app.misc_DeleteAll.Tooltip = {''};
            app.misc_DeleteAll.Layout.Row = 8;
            app.misc_DeleteAll.Layout.Column = 2;
            app.misc_DeleteAll.Text = '';

            % Create misc_DeleteAllLabel
            app.misc_DeleteAllLabel = uilabel(app.misc_Grid1);
            app.misc_DeleteAllLabel.HorizontalAlignment = 'center';
            app.misc_DeleteAllLabel.WordWrap = 'on';
            app.misc_DeleteAllLabel.FontSize = 10;
            app.misc_DeleteAllLabel.Layout.Row = 9;
            app.misc_DeleteAllLabel.Layout.Column = [1 3];
            app.misc_DeleteAllLabel.Text = 'Reiniciar análise';

            % Create Image
            app.Image = uiimage(app.misc_Grid1);
            app.Image.Enable = 'off';
            app.Image.Layout.Row = [2 3];
            app.Image.Layout.Column = 10;
            app.Image.ImageSource = 'LineV.svg';

            % Create Image_2
            app.Image_2 = uiimage(app.misc_Grid1);
            app.Image_2.Enable = 'off';
            app.Image_2.Layout.Row = [2 3];
            app.Image_2.Layout.Column = 23;
            app.Image_2.ImageSource = 'LineV.svg';

            % Create FLUXOSESPECTRAISLabel
            app.FLUXOSESPECTRAISLabel = uilabel(app.GridLayout);
            app.FLUXOSESPECTRAISLabel.VerticalAlignment = 'bottom';
            app.FLUXOSESPECTRAISLabel.FontSize = 10;
            app.FLUXOSESPECTRAISLabel.Layout.Row = 1;
            app.FLUXOSESPECTRAISLabel.Layout.Column = 1;
            app.FLUXOSESPECTRAISLabel.Text = 'FLUXOS ESPECTRAIS';

            % Create OPERAESLabel
            app.OPERAESLabel = uilabel(app.GridLayout);
            app.OPERAESLabel.VerticalAlignment = 'bottom';
            app.OPERAESLabel.FontSize = 10;
            app.OPERAESLabel.Layout.Row = 1;
            app.OPERAESLabel.Layout.Column = 2;
            app.OPERAESLabel.Text = 'OPERAÇÕES';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockMiscellaneous_exported(Container, varargin)

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
