classdef dockMiscellaneous_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        RadioGroup                   matlab.ui.container.ButtonGroup
        PeaksOption_5                matlab.ui.control.RadioButton
        PeaksOption_4                matlab.ui.control.RadioButton
        PeaksOption_3                matlab.ui.control.RadioButton
        PeaksMinDistanceMeters       matlab.ui.control.Spinner
        PeaksMinDistanceMetersLabel  matlab.ui.control.Label
        PeaksCount                   matlab.ui.control.Spinner
        PeaksCountLabel              matlab.ui.control.Label
        PeaksDataSource              matlab.ui.control.DropDown
        PeaksDataSourceLabel         matlab.ui.control.Label
        StationMaxDistanceKm         matlab.ui.control.NumericEditField
        StationMaxDistanceKmLabel    matlab.ui.control.Label
        StationTypeValue             matlab.ui.control.EditField
        StationType                  matlab.ui.control.DropDown
        StationTypeLabel             matlab.ui.control.Label
        StationOption                matlab.ui.control.RadioButton
        OPERAESLabel                 matlab.ui.control.Label
        FLUXOSESPECTRAISLabel        matlab.ui.control.Label
        SpectrumFlowTree             matlab.ui.container.CheckBoxTree
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
                        treeNode = uitreenode(receiverNode, 'Text', sprintf('%.3f - %.3f MHz', app.mainApp.specData(jj).MetaData.FreqStart / 1e6, app.mainApp.specData(jj).MetaData.FreqStop  / 1e6), ...
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
            if ~isempty(app.SpectrumFlowTree.SelectedNodes) && isscalar(app.SpectrumFlowTree.SelectedNodes.NodeData)
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
                app.UIFigure.Position = [100 100 880 908];
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
            app.GridLayout.ColumnWidth = {320, 10, '1x'};
            app.GridLayout.RowHeight = {22, 5, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create SpectrumFlowTree
            app.SpectrumFlowTree = uitree(app.GridLayout, 'checkbox');
            app.SpectrumFlowTree.FontSize = 11;
            app.SpectrumFlowTree.Layout.Row = 3;
            app.SpectrumFlowTree.Layout.Column = 1;

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
            app.OPERAESLabel.Layout.Column = 3;
            app.OPERAESLabel.Text = 'OPERAÇÕES';

            % Create RadioGroup
            app.RadioGroup = uibuttongroup(app.GridLayout);
            app.RadioGroup.AutoResizeChildren = 'off';
            app.RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RadioGroup.BackgroundColor = [1 1 1];
            app.RadioGroup.Layout.Row = 3;
            app.RadioGroup.Layout.Column = 3;
            app.RadioGroup.FontWeight = 'bold';
            app.RadioGroup.FontSize = 10;

            % Create StationOption
            app.StationOption = uiradiobutton(app.RadioGroup);
            app.StationOption.Text = {'<b>MESCLA FLUXOS ESPECTRAIS</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona estações incluídas no RFDataHub.</font>'};
            app.StationOption.FontSize = 11;
            app.StationOption.Interpreter = 'html';
            app.StationOption.Position = [11 796 278 31];
            app.StationOption.Value = true;

            % Create StationTypeLabel
            app.StationTypeLabel = uilabel(app.RadioGroup);
            app.StationTypeLabel.Tag = 'STATION';
            app.StationTypeLabel.VerticalAlignment = 'bottom';
            app.StationTypeLabel.FontSize = 11;
            app.StationTypeLabel.FontColor = [0.302 0.302 0.302];
            app.StationTypeLabel.Position = [30 775 181 17];
            app.StationTypeLabel.Text = 'Tipo de registro:';

            % Create StationType
            app.StationType = uidropdown(app.RadioGroup);
            app.StationType.Items = {'Lista de frequências (MHz)', 'Índices de registros do RFDataHub'};
            app.StationType.Tag = 'STATION';
            app.StationType.FontSize = 11;
            app.StationType.FontColor = [0.302 0.302 0.302];
            app.StationType.BackgroundColor = [1 1 1];
            app.StationType.Position = [30 748 330 22];
            app.StationType.Value = 'Lista de frequências (MHz)';

            % Create StationTypeValue
            app.StationTypeValue = uieditfield(app.RadioGroup, 'text');
            app.StationTypeValue.Tag = 'STATION';
            app.StationTypeValue.FontSize = 11;
            app.StationTypeValue.FontColor = [0.302 0.302 0.302];
            app.StationTypeValue.Tooltip = {'Exemplos:'; '• 101.1, 101.3, 101.5 (Lista de frequências)'; '• #1000 #1500 #2000 (RFDataHub)'};
            app.StationTypeValue.Position = [30 718 330 22];

            % Create StationMaxDistanceKmLabel
            app.StationMaxDistanceKmLabel = uilabel(app.RadioGroup);
            app.StationMaxDistanceKmLabel.Tag = 'STATION';
            app.StationMaxDistanceKmLabel.WordWrap = 'on';
            app.StationMaxDistanceKmLabel.FontSize = 11;
            app.StationMaxDistanceKmLabel.FontColor = [0.302 0.302 0.302];
            app.StationMaxDistanceKmLabel.Position = [30 684 221 28];
            app.StationMaxDistanceKmLabel.Text = 'Distância máxima entre estação e local da monitoração (km):';

            % Create StationMaxDistanceKm
            app.StationMaxDistanceKm = uieditfield(app.RadioGroup, 'numeric');
            app.StationMaxDistanceKm.Limits = [1 Inf];
            app.StationMaxDistanceKm.RoundFractionalValues = 'on';
            app.StationMaxDistanceKm.ValueDisplayFormat = '%d';
            app.StationMaxDistanceKm.Tag = 'STATION';
            app.StationMaxDistanceKm.FontSize = 11;
            app.StationMaxDistanceKm.FontColor = [0.302 0.302 0.302];
            app.StationMaxDistanceKm.Position = [262 689 98 22];
            app.StationMaxDistanceKm.Value = 30;

            % Create PeaksDataSourceLabel
            app.PeaksDataSourceLabel = uilabel(app.RadioGroup);
            app.PeaksDataSourceLabel.Tag = 'PEAKS';
            app.PeaksDataSourceLabel.VerticalAlignment = 'bottom';
            app.PeaksDataSourceLabel.FontSize = 11;
            app.PeaksDataSourceLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksDataSourceLabel.Enable = 'off';
            app.PeaksDataSourceLabel.Position = [31 602 181 17];
            app.PeaksDataSourceLabel.Text = 'Fonte da informação:';

            % Create PeaksDataSource
            app.PeaksDataSource = uidropdown(app.RadioGroup);
            app.PeaksDataSource.Items = {'Dados brutos', 'Processados'};
            app.PeaksDataSource.Tag = 'PEAKS';
            app.PeaksDataSource.Enable = 'off';
            app.PeaksDataSource.FontSize = 11;
            app.PeaksDataSource.FontColor = [0.302 0.302 0.302];
            app.PeaksDataSource.BackgroundColor = [1 1 1];
            app.PeaksDataSource.Position = [31 575 220 22];
            app.PeaksDataSource.Value = 'Dados brutos';

            % Create PeaksCountLabel
            app.PeaksCountLabel = uilabel(app.RadioGroup);
            app.PeaksCountLabel.Tag = 'PEAKS';
            app.PeaksCountLabel.VerticalAlignment = 'bottom';
            app.PeaksCountLabel.FontSize = 11;
            app.PeaksCountLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksCountLabel.Enable = 'off';
            app.PeaksCountLabel.Position = [262 602 94 17];
            app.PeaksCountLabel.Text = 'Número de picos:';

            % Create PeaksCount
            app.PeaksCount = uispinner(app.RadioGroup);
            app.PeaksCount.Limits = [1 100];
            app.PeaksCount.RoundFractionalValues = 'on';
            app.PeaksCount.ValueDisplayFormat = '%.0f';
            app.PeaksCount.Tag = 'PEAKS';
            app.PeaksCount.FontSize = 11;
            app.PeaksCount.FontColor = [0.302 0.302 0.302];
            app.PeaksCount.Enable = 'off';
            app.PeaksCount.Position = [262 575 98 22];
            app.PeaksCount.Value = 1;

            % Create PeaksMinDistanceMetersLabel
            app.PeaksMinDistanceMetersLabel = uilabel(app.RadioGroup);
            app.PeaksMinDistanceMetersLabel.Tag = 'PEAKS';
            app.PeaksMinDistanceMetersLabel.FontSize = 11;
            app.PeaksMinDistanceMetersLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksMinDistanceMetersLabel.Enable = 'off';
            app.PeaksMinDistanceMetersLabel.Position = [31 543 204 22];
            app.PeaksMinDistanceMetersLabel.Text = 'Distância mínima entre picos (metros):';

            % Create PeaksMinDistanceMeters
            app.PeaksMinDistanceMeters = uispinner(app.RadioGroup);
            app.PeaksMinDistanceMeters.Step = 100;
            app.PeaksMinDistanceMeters.Limits = [0 10000];
            app.PeaksMinDistanceMeters.RoundFractionalValues = 'on';
            app.PeaksMinDistanceMeters.ValueDisplayFormat = '%.0f';
            app.PeaksMinDistanceMeters.Tag = 'PEAKS';
            app.PeaksMinDistanceMeters.FontSize = 11;
            app.PeaksMinDistanceMeters.FontColor = [0.302 0.302 0.302];
            app.PeaksMinDistanceMeters.Enable = 'off';
            app.PeaksMinDistanceMeters.Position = [262 543 98 22];
            app.PeaksMinDistanceMeters.Value = 1000;

            % Create PeaksOption_3
            app.PeaksOption_3 = uiradiobutton(app.RadioGroup);
            app.PeaksOption_3.Text = {'<b>CURVA DE CORREÇÃO</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.PeaksOption_3.WordWrap = 'on';
            app.PeaksOption_3.FontSize = 11;
            app.PeaksOption_3.Interpreter = 'html';
            app.PeaksOption_3.Position = [18 626 347 46];

            % Create PeaksOption_4
            app.PeaksOption_4 = uiradiobutton(app.RadioGroup);
            app.PeaksOption_4.Text = {'<b>EXPORTA ANÁLISE</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.PeaksOption_4.WordWrap = 'on';
            app.PeaksOption_4.FontSize = 11;
            app.PeaksOption_4.Interpreter = 'html';
            app.PeaksOption_4.Position = [11 243 347 46];

            % Create PeaksOption_5
            app.PeaksOption_5 = uiradiobutton(app.RadioGroup);
            app.PeaksOption_5.Text = {'<b>IMPORTA ANÁLISE</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.PeaksOption_5.WordWrap = 'on';
            app.PeaksOption_5.FontSize = 11;
            app.PeaksOption_5.Interpreter = 'html';
            app.PeaksOption_5.Position = [34 140 347 46];

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
