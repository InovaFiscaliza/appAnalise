classdef dockTableFilter_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        ColumnFilterPanel       matlab.ui.container.Panel
        ColumnFilterGrid        matlab.ui.container.GridLayout
        ColumnFilterList        matlab.ui.container.CheckBoxTree
        ColumnFilterDel         matlab.ui.control.Image
        ColumnFilterAdd         matlab.ui.control.Image
        Value2_TextFree         matlab.ui.control.EditField
        Value2_TextList         matlab.ui.control.DropDown
        Value2_Numeric          matlab.ui.control.NumericEditField
        Value2_Date             matlab.ui.control.DatePicker
        Operation2_List         matlab.ui.control.DropDown
        Operation2_LogicalGrid  matlab.ui.container.ButtonGroup
        Operation2_LogicalOr    matlab.ui.control.RadioButton
        Operation2_LogicalAnd   matlab.ui.control.RadioButton
        Value1_TextFree         matlab.ui.control.EditField
        Value1_TextList         matlab.ui.control.DropDown
        Value1_Numeric          matlab.ui.control.NumericEditField
        Value1_Date             matlab.ui.control.DatePicker
        Operation1_List         matlab.ui.control.DropDown
        SymbolicNameList        matlab.ui.control.DropDown
        ColumnFilterLabel       matlab.ui.control.Label
        Title                   matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
        Context
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true        
        mainApp
        callingApp
        projectData
    end


    properties (Constant, Access = private)
        %-----------------------------------------------------------------%
        % Acima desse limite, colunas categóricas são filtradas por
        % uieditfield (text) ao invés de uidropdown.
        MAX_CATEGORIES_AS_DROPDOWN = 500
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        TargetTable
        FilterController
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialLayout(app)
            columnRawNames = app.TargetTable.Properties.VariableNames;
            columnRawTypes = matlab.Compatibility.resolveTableVariableTypes(app.TargetTable);

            [columnNames, sortedIdxs] = textAnalysis.sort(columnRawNames);
            columnTypes = columnRawTypes(sortedIdxs);
            
            pseudoClasses = tableFiltering.getPseudoClasses(columnTypes);
            symbolicNames = tableFiltering.mergedSymbolWithColumnNames(columnNames, columnTypes);
            
            % Atualiza componente dropdown com os nomes símbolicos das
            % colunas, além de armazenar em "UserData" detalhes sobre os
            % tipos de dados (nome, tipo e pseudo classe de cada coluna).
            app.SymbolicNameList.Items = [{''}; symbolicNames'];
            
            restartState(app)            
            app.SymbolicNameList.UserData.columnNames   = columnNames;
            app.SymbolicNameList.UserData.columnTypes   = columnTypes;
            app.SymbolicNameList.UserData.pseudoClasses = pseudoClasses;

            updateTree(app)
        end

        %-----------------------------------------------------------------%
        function restartState(app)
            % O componente de INPUT do valor do filtro pode ser uidatepicker,
            % uieditfield (numeric/text) ou uidropdown, a depender da pseudo 
            % classe da coluna. Guarda-se um handle p/ o elemento ativo.
            app.Operation1_List.UserData.inputHandle = [];
            app.Operation2_List.UserData.inputHandle = [];

            % Reinicializa os campos de valor.
            set([app.Value1_Date,     app.Value2_Date],     'Value', NaT, 'Visible', 'off')
            set([app.Value1_Numeric,  app.Value2_Numeric],  'Value', 1,   'Visible', 'off')
            set([app.Value1_TextList, app.Value2_TextList], 'Editable', 'on', 'Items', {''}, 'Value', '', 'Visible', 'off')
            set([app.Value1_TextFree, app.Value2_TextFree], 'Value', '',  'Visible', 'on')
        end

        %-----------------------------------------------------------------%
        function updateTree(app)
            if ~isempty(app.ColumnFilterList.Children)
                delete(app.ColumnFilterList.Children)
                app.ColumnFilterDel.Visible = 'off';
            end

            if ~isempty(app.ColumnFilterList.StyleConfigurations)
                removeStyle(app.ColumnFilterList)
            end

            filterList = getFilterList(app.FilterController, 'tbl');
            if ~isempty(filterList)
                undeletable = [];
                checkedNodes = [];
    
                for ii = 1:numel(filterList)
                    childNode = uitreenode(app.ColumnFilterList, 'Text', filterList{ii}, 'NodeData', ii);

                    if ~app.FilterController.filterRules.Deletable(ii)
                        undeletable = [undeletable, childNode];
                    end
    
                    if app.FilterController.filterRules.Enable(ii)
                        checkedNodes = [checkedNodes, childNode];
                    end
                end
    
                if ~isempty(checkedNodes)
                    app.ColumnFilterList.CheckedNodes = checkedNodes;
                end
                
                if ~isempty(undeletable)
                    addStyle(app.ColumnFilterList, uistyle('FontColor', '#808080', 'Icon', 'lock_20Gray.svg'), 'node', undeletable)
                end
            end
        end

        %-----------------------------------------------------------------%
        function [columName, pseudoClass] = inspectColumnData(app)
            symbolicName = app.SymbolicNameList.Value;
            [~, symbolicIndex] = ismember(symbolicName, app.SymbolicNameList.Items);
            columnIndex = symbolicIndex-1;

            if columnIndex == 0
                columName   = '';
                pseudoClass = '';
            else
                columName   = app.SymbolicNameList.UserData.columnNames{columnIndex};
                pseudoClass = app.SymbolicNameList.UserData.pseudoClasses{columnIndex};
            end
        end

        %-----------------------------------------------------------------%
        function cats = getCategories(app, columnName)
            cats = {};
            if iscategorical(app.TargetTable.(columnName))
                cats = categories(app.TargetTable.(columnName));
            end
        end

        %-----------------------------------------------------------------%
        function errorMessage = validateInputValue(app, value, pseudoClass)
            errorMessage = '';

            switch pseudoClass
                case {'cellstr', 'categorical'}
                    if isempty(strtrim(value))
                        errorMessage = 'O valor do filtro não pode ser vazio.';
                    end

                case 'numeric'
                    if ~isscalar(value) || ~isfinite(value)
                        errorMessage = 'O valor do filtro deve ser um número finito.';
                    end

                case 'datetime'
                    if isnat(value)
                        errorMessage = 'Selecione uma data para o filtro.';
                    end
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, targetTable, filterController)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                
                app.Context = context;
                app.TargetTable = targetTable;
                app.FilterController = filterController;

                initialLayout(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Value changed function: SymbolicNameList
        function onFilterColumnChanged(app, event)
            
            restartState(app)

            [columnName, pseudoClass] = inspectColumnData(app);
            app.SymbolicNameList.UserData.selected = struct('columnName', columnName, 'pseudoClass', pseudoClass);

            if isempty(pseudoClass)
                operations = {};
            else
                operations = tableFiltering.getFilterCapabilities(pseudoClass);
            end
            
            app.Operation1_List.Items = operations;
            set(app.Operation2_List, 'Items', [{''}, operations], 'Value', '')

            if ~isempty(operations)
                app.Operation1_List.Value = app.Operation1_List.Items{1};
                onFilterOperatorChanged(app, struct('Source', app.Operation1_List))
                onFilterOperatorChanged(app, struct('Source', app.Operation2_List))
            end

            app.ColumnFilterAdd.Enable = ~isempty(operations);

        end

        % Value changed function: Operation1_List, Operation2_List
        function onFilterOperatorChanged(app, event)
            
            switch event.Source
                case app.Operation1_List
                    valueHandles = [ ...
                        app.Value1_Date, ...
                        app.Value1_Numeric, ...
                        app.Value1_TextFree, ...
                        app.Value1_TextList ...
                    ];
                    
                case app.Operation2_List
                    valueHandles = [ ...
                        app.Value2_Date, ...
                        app.Value2_Numeric, ...
                        app.Value2_TextFree, ...
                        app.Value2_TextList ...
                    ];
            end
            tagHandles  = arrayfun(@(x) x.Tag, valueHandles, 'UniformOutput', false);

            columnName  = app.SymbolicNameList.UserData.selected.columnName;
            pseudoClass = app.SymbolicNameList.UserData.selected.pseudoClass;
            cats  = getCategories(app, columnName);

            switch pseudoClass
                case 'cellstr'
                    [~, tagIndex] = ismember('textFree', tagHandles);
                    optionalArgs  = {};

                case 'numeric'
                    [~, tagIndex] = ismember('numeric', tagHandles);
                    optionalArgs  = {};

                case 'datetime'
                    [~, tagIndex] = ismember('datePicker', tagHandles);
                    optionalArgs  = {};

                case 'logical'
                    [~, tagIndex] = ismember('textList', tagHandles);
                    optionalArgs  = {'Editable', 'off', 'Items', {'true', 'false'}};

                case 'categorical'
                    % Se a coluna não tiver categorias ou tiver mais categorias
                    % do que o limite, apresenta-se como uieditfield (text) ao
                    % invés de dropdown.
                    if isempty(cats) || numel(cats) > app.MAX_CATEGORIES_AS_DROPDOWN
                        [~, tagIndex] = ismember('textFree', tagHandles);
                        optionalArgs  = {};
                    else
                        [~, tagIndex] = ismember('textList', tagHandles);
                        optionalArgs  = {'Editable', 'on', 'Items', [{''}; cats]};
                    end
            end

            event.Source.UserData.inputHandle = valueHandles(tagIndex);
            set(valueHandles(tagIndex), 'Visible', 1, optionalArgs{:})
            set(setdiff(valueHandles, valueHandles(tagIndex)), 'Visible', 0)
            
        end

        % Image clicked function: ColumnFilterAdd
        function onFilterAddButtonClicked(app, event)
            
            columnName = app.SymbolicNameList.UserData.selected.columnName;
            pseudoClass = app.SymbolicNameList.UserData.selected.pseudoClass;
            operators  = {app.Operation1_List.Value};
            values     = {app.Operation1_List.UserData.inputHandle.Value};
            connector  = app.Operation2_LogicalGrid.SelectedObject.Text;

            if ~isempty(app.Operation2_List.Value) && (~strcmp(app.Operation1_List.Value, app.Operation2_List.Value) || ~isequal(app.Operation1_List.UserData.inputHandle.Value, app.Operation2_List.UserData.inputHandle.Value))
                operators = [operators, {app.Operation2_List.Value}];
                values    = [values, {app.Operation2_List.UserData.inputHandle.Value}];
            end

            for ii = 1:numel(values)
                errorMessage = validateInputValue(app, values{ii}, pseudoClass);
                if ~isempty(errorMessage)
                    ui.Dialog(app.UIFigure, 'warning', errorMessage);
                    return
                end
            end

            % Colunas lógicas são filtradas por uidropdown com os valores
            % "true" e "false", convertidos aqui para logical.
            if strcmp(pseudoClass, 'logical')
                values = cellfun(@(x) strcmp(x, 'true'), values, 'UniformOutput', false);
            end

            try
                addFilterRule(app.FilterController, columnName, operators, values, connector);
            catch ME
                ui.Dialog(app.UIFigure, 'warning', ME.message);
                return
            end
            updateTree(app)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onFilterRulesChanged', app.Context)

        end

        % Image clicked function: ColumnFilterDel
        function onFilterDelButtonClicked(app, event)
            
            selectedNode = app.ColumnFilterList.SelectedNodes;

            if ~isempty(selectedNode)
                removeFilterRule(app.FilterController, selectedNode.NodeData)
                updateTree(app)

                ipcMainMatlabCallsHandler(app.mainApp, app, 'onFilterRulesChanged', app.Context)
            end

        end

        % Selection changed function: ColumnFilterList
        function onColumnFilterListSelectionChanged(app, event)
            
            selectedNode = app.ColumnFilterList.SelectedNodes;

            % O botão de exclusão só é exibido para regras deletáveis.
            app.ColumnFilterDel.Visible = ~isempty(selectedNode) && app.FilterController.filterRules.Deletable(selectedNode.NodeData);
            
        end

        % Callback function: ColumnFilterList
        function onColumnFilterCheckedNodesChanged(app, event)

            checkedNodesData = [];            
            if ~isempty(app.ColumnFilterList.CheckedNodes)
                checkedNodesData = [app.ColumnFilterList.CheckedNodes.NodeData];
            end

            initialEnableArray = app.FilterController.filterRules.Enable;
            currentEnableArray = zeros(height(initialEnableArray), 1, 'logical');

            if ~isempty(checkedNodesData)
                currentEnableArray(checkedNodesData) = true;
            end

            undeletableFilterMask = ~app.FilterController.filterRules.Deletable;
            if any(undeletableFilterMask)
                currentEnableArray(undeletableFilterMask) = true;
            end

            if ~isequal(initialEnableArray, currentEnableArray)
                toogleFilterRule(app.FilterController, currentEnableArray)
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onFilterRulesChanged', app.Context)
            end

            updateTree(app)
            
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
                app.UIFigure.Position = [100 100 518 376];
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
            app.GridLayout.ColumnWidth = {478};
            app.GridLayout.RowHeight = {40, 22, 264};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.VerticalAlignment = 'top';
            app.Title.FontSize = 15;
            app.Title.FontColor = [0 0.1294 0.2392];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 1;
            app.Title.Interpreter = 'html';
            app.Title.Text = {'<b>Configurações de filtragem e exibição</b>'; '<font style="font-size: 11px;">Defina como os filtros serão aplicados para refinar os resultados exibidos</font>'};

            % Create ColumnFilterLabel
            app.ColumnFilterLabel = uilabel(app.GridLayout);
            app.ColumnFilterLabel.VerticalAlignment = 'bottom';
            app.ColumnFilterLabel.FontSize = 11;
            app.ColumnFilterLabel.FontColor = [0 0.1294 0.2392];
            app.ColumnFilterLabel.Layout.Row = 2;
            app.ColumnFilterLabel.Layout.Column = 1;
            app.ColumnFilterLabel.Text = 'Filtro por coluna';

            % Create ColumnFilterPanel
            app.ColumnFilterPanel = uipanel(app.GridLayout);
            app.ColumnFilterPanel.AutoResizeChildren = 'off';
            app.ColumnFilterPanel.Layout.Row = 3;
            app.ColumnFilterPanel.Layout.Column = 1;

            % Create ColumnFilterGrid
            app.ColumnFilterGrid = uigridlayout(app.ColumnFilterPanel);
            app.ColumnFilterGrid.ColumnWidth = {22, 110, '1x', 22};
            app.ColumnFilterGrid.RowHeight = {22, 22, 22, 22, 22, '1x'};
            app.ColumnFilterGrid.ColumnSpacing = 5;
            app.ColumnFilterGrid.RowSpacing = 5;
            app.ColumnFilterGrid.BackgroundColor = [1 1 1];

            % Create SymbolicNameList
            app.SymbolicNameList = uidropdown(app.ColumnFilterGrid);
            app.SymbolicNameList.Items = {};
            app.SymbolicNameList.ValueChangedFcn = createCallbackFcn(app, @onFilterColumnChanged, true);
            app.SymbolicNameList.FontSize = 11;
            app.SymbolicNameList.BackgroundColor = [1 1 1];
            app.SymbolicNameList.Layout.Row = 1;
            app.SymbolicNameList.Layout.Column = [1 4];
            app.SymbolicNameList.Value = {};

            % Create Operation1_List
            app.Operation1_List = uidropdown(app.ColumnFilterGrid);
            app.Operation1_List.Items = {};
            app.Operation1_List.ValueChangedFcn = createCallbackFcn(app, @onFilterOperatorChanged, true);
            app.Operation1_List.FontSize = 11;
            app.Operation1_List.BackgroundColor = [1 1 1];
            app.Operation1_List.Layout.Row = 2;
            app.Operation1_List.Layout.Column = [1 2];
            app.Operation1_List.Value = {};

            % Create Value1_Date
            app.Value1_Date = uidatepicker(app.ColumnFilterGrid);
            app.Value1_Date.Editable = 'off';
            app.Value1_Date.Tag = 'datePicker';
            app.Value1_Date.FontSize = 11;
            app.Value1_Date.BackgroundColor = [0.96 0.96 0.96];
            app.Value1_Date.Visible = 'off';
            app.Value1_Date.Layout.Row = 2;
            app.Value1_Date.Layout.Column = [3 4];

            % Create Value1_Numeric
            app.Value1_Numeric = uieditfield(app.ColumnFilterGrid, 'numeric');
            app.Value1_Numeric.Tag = 'numeric';
            app.Value1_Numeric.FontSize = 11;
            app.Value1_Numeric.Visible = 'off';
            app.Value1_Numeric.Layout.Row = 2;
            app.Value1_Numeric.Layout.Column = [3 4];
            app.Value1_Numeric.Value = 1;

            % Create Value1_TextList
            app.Value1_TextList = uidropdown(app.ColumnFilterGrid);
            app.Value1_TextList.Items = {''};
            app.Value1_TextList.Editable = 'on';
            app.Value1_TextList.Tag = 'textList';
            app.Value1_TextList.Visible = 'off';
            app.Value1_TextList.FontSize = 11;
            app.Value1_TextList.BackgroundColor = [1 1 1];
            app.Value1_TextList.Layout.Row = 2;
            app.Value1_TextList.Layout.Column = [3 4];
            app.Value1_TextList.Value = '';

            % Create Value1_TextFree
            app.Value1_TextFree = uieditfield(app.ColumnFilterGrid, 'text');
            app.Value1_TextFree.Tag = 'textFree';
            app.Value1_TextFree.FontSize = 11;
            app.Value1_TextFree.FontColor = [0.149 0.149 0.149];
            app.Value1_TextFree.Layout.Row = 2;
            app.Value1_TextFree.Layout.Column = [3 4];

            % Create Operation2_LogicalGrid
            app.Operation2_LogicalGrid = uibuttongroup(app.ColumnFilterGrid);
            app.Operation2_LogicalGrid.AutoResizeChildren = 'off';
            app.Operation2_LogicalGrid.BorderType = 'none';
            app.Operation2_LogicalGrid.BackgroundColor = [1 1 1];
            app.Operation2_LogicalGrid.Layout.Row = 3;
            app.Operation2_LogicalGrid.Layout.Column = [1 2];

            % Create Operation2_LogicalAnd
            app.Operation2_LogicalAnd = uiradiobutton(app.Operation2_LogicalGrid);
            app.Operation2_LogicalAnd.Text = 'E';
            app.Operation2_LogicalAnd.FontSize = 11;
            app.Operation2_LogicalAnd.Position = [1 1 51 22];
            app.Operation2_LogicalAnd.Value = true;

            % Create Operation2_LogicalOr
            app.Operation2_LogicalOr = uiradiobutton(app.Operation2_LogicalGrid);
            app.Operation2_LogicalOr.Text = 'Ou';
            app.Operation2_LogicalOr.FontSize = 11;
            app.Operation2_LogicalOr.Position = [60 1 50 22];

            % Create Operation2_List
            app.Operation2_List = uidropdown(app.ColumnFilterGrid);
            app.Operation2_List.Items = {};
            app.Operation2_List.ValueChangedFcn = createCallbackFcn(app, @onFilterOperatorChanged, true);
            app.Operation2_List.FontSize = 11;
            app.Operation2_List.BackgroundColor = [1 1 1];
            app.Operation2_List.Layout.Row = 4;
            app.Operation2_List.Layout.Column = [1 2];
            app.Operation2_List.Value = {};

            % Create Value2_Date
            app.Value2_Date = uidatepicker(app.ColumnFilterGrid);
            app.Value2_Date.Editable = 'off';
            app.Value2_Date.Tag = 'datePicker';
            app.Value2_Date.FontSize = 11;
            app.Value2_Date.BackgroundColor = [0.96 0.96 0.96];
            app.Value2_Date.Visible = 'off';
            app.Value2_Date.Layout.Row = 4;
            app.Value2_Date.Layout.Column = [3 4];

            % Create Value2_Numeric
            app.Value2_Numeric = uieditfield(app.ColumnFilterGrid, 'numeric');
            app.Value2_Numeric.Tag = 'numeric';
            app.Value2_Numeric.FontSize = 11;
            app.Value2_Numeric.Visible = 'off';
            app.Value2_Numeric.Layout.Row = 4;
            app.Value2_Numeric.Layout.Column = [3 4];
            app.Value2_Numeric.Value = 1;

            % Create Value2_TextList
            app.Value2_TextList = uidropdown(app.ColumnFilterGrid);
            app.Value2_TextList.Items = {''};
            app.Value2_TextList.Editable = 'on';
            app.Value2_TextList.Tag = 'textList';
            app.Value2_TextList.Visible = 'off';
            app.Value2_TextList.FontSize = 11;
            app.Value2_TextList.BackgroundColor = [1 1 1];
            app.Value2_TextList.Layout.Row = 4;
            app.Value2_TextList.Layout.Column = [3 4];
            app.Value2_TextList.Value = '';

            % Create Value2_TextFree
            app.Value2_TextFree = uieditfield(app.ColumnFilterGrid, 'text');
            app.Value2_TextFree.Tag = 'textFree';
            app.Value2_TextFree.FontSize = 11;
            app.Value2_TextFree.FontColor = [0.149 0.149 0.149];
            app.Value2_TextFree.Layout.Row = 4;
            app.Value2_TextFree.Layout.Column = [3 4];

            % Create ColumnFilterAdd
            app.ColumnFilterAdd = uiimage(app.ColumnFilterGrid);
            app.ColumnFilterAdd.ScaleMethod = 'none';
            app.ColumnFilterAdd.ImageClickedFcn = createCallbackFcn(app, @onFilterAddButtonClicked, true);
            app.ColumnFilterAdd.Enable = 'off';
            app.ColumnFilterAdd.Layout.Row = 5;
            app.ColumnFilterAdd.Layout.Column = 1;
            app.ColumnFilterAdd.ImageSource = 'Add_16.png';

            % Create ColumnFilterDel
            app.ColumnFilterDel = uiimage(app.ColumnFilterGrid);
            app.ColumnFilterDel.ImageClickedFcn = createCallbackFcn(app, @onFilterDelButtonClicked, true);
            app.ColumnFilterDel.Visible = 'off';
            app.ColumnFilterDel.Layout.Row = 5;
            app.ColumnFilterDel.Layout.Column = 4;
            app.ColumnFilterDel.ImageSource = 'close-16px-red.svg';

            % Create ColumnFilterList
            app.ColumnFilterList = uitree(app.ColumnFilterGrid, 'checkbox');
            app.ColumnFilterList.SelectionChangedFcn = createCallbackFcn(app, @onColumnFilterListSelectionChanged, true);
            app.ColumnFilterList.FontSize = 11;
            app.ColumnFilterList.Layout.Row = 6;
            app.ColumnFilterList.Layout.Column = [1 4];

            % Assign Checked Nodes
            app.ColumnFilterList.CheckedNodesChangedFcn = createCallbackFcn(app, @onColumnFilterCheckedNodesChanged, true);

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockTableFilter_exported(Container, varargin)

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
