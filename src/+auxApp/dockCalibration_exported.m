classdef dockCalibration_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        btnOK              matlab.ui.control.Button
        btnRefresh         matlab.ui.control.Image
        kFactorPanel       matlab.ui.container.Panel
        kFactorGrid        matlab.ui.container.GridLayout
        kFactorTree        matlab.ui.container.Tree
        kFactorAdd         matlab.ui.control.Image
        kFactor            matlab.ui.control.DropDown
        kFactorBand        matlab.ui.control.Label
        kFactorLabel       matlab.ui.control.Label
        unitRaw            matlab.ui.control.EditField
        unitRawLabel       matlab.ui.control.Label
        kFactorPanelLabel  matlab.ui.control.Label
        ContextMenu        matlab.ui.container.ContextMenu
        ContextMenu_del    matlab.ui.container.Menu
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
        referenceData
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app, idxThread)
            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            try
                kFactorTable = jsondecode(fileread(fullfile(programDataFolder, 'Calibration.json')));
            catch
                kFactorTable = jsondecode(fileread(fullfile(projectFolder,     'Calibration.json')));
            end

            app.referenceData = struct('idxThread',    idxThread,                                        ...
                                       'Calibration',  app.specData(idxThread).UserData.measCalibration, ...
                                       'kFactorTable', kFactorTable);
            app.kFactor.Items = [{''}; {app.referenceData.kFactorTable.Name}'];

            Layout(app)            
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app)
            idxThread = app.referenceData.idxThread;
            if ~isequal(app.referenceData.Calibration, app.specData(idxThread).UserData.measCalibration)
                editionFlag = true;
            else
                editionFlag = false;
            end
        end

        %-----------------------------------------------------------------%
        function Layout(app)
            if ~isempty(app.kFactorTree.Children)
                delete(app.kFactorTree.Children)
                removeStyle(app.kFactorTree)
            end

            idxThread   = app.referenceData.idxThread;
            Calibration = app.specData(idxThread).UserData.measCalibration;

            if ~isempty(Calibration)
                app.unitRaw.Value = Calibration.oldUnitLevel{1};

                for ii = 1:height(Calibration)
                    uitreenode(app.kFactorTree, 'Text',        sprintf('#%d: %s<br><font style="padding-left: 18px; color: gray; font-size: 10px;">%s → %s</font>', ii, Calibration.Name{ii}, Calibration.oldUnitLevel{ii}, Calibration.newUnitLevel{ii}), ...
                                                'NodeData',    ii,                                                                                                                                                                          ...
                                                'ContextMenu', app.ContextMenu);
                end

                addStyle(app.kFactorTree, uistyle('Interpreter', 'html'), "tree", "")

            else
                app.unitRaw.Value = app.specData(idxThread).MetaData.LevelUnit;
            end
            app.kFactorAdd.Enable = 1;

            if ~isempty(app.kFactorTree.Children)
                app.btnRefresh.Enable = 1;
            else
                app.btnRefresh.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function msgError = Correction(app, operationType, idxThread, idxCalibration, kFactorName)
            msgError = '';

            try
                util.measCalibration(app.specData, app.rootFolder, operationType, idxThread, idxCalibration, kFactorName)
            catch ME
                msgError = ME.message;
                ui.Dialog(app.UIFigure, 'warning', ME.message);
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'flowIdx', flowIdx);
                % initialValues(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: ContextMenu_del, btnRefresh, kFactorAdd
        function FieldValueChanged(app, event)
            
            focus(app.jsBackDoor)

            idxThread = app.referenceData.idxThread;

            switch event.Source
                case app.kFactorAdd
                    idxCalibration = [];
                    kFactorName    = app.kFactor.Value;
                    operationType  = 'Add';

                otherwise
                    switch event.Source
                        case app.ContextMenu_del
                            idxCalibration = app.kFactorTree.SelectedNodes.NodeData;
                            
                        case app.btnRefresh
                            idxCalibration = 1:height(app.specData(idxThread).UserData.measCalibration);
                    end

                    kFactorName   = app.specData(idxThread).UserData.measCalibration.Name(idxCalibration);
                    operationType = 'Remove';
            end

            msgError = Correction(app, operationType, idxThread, idxCalibration, kFactorName);
            if isempty(msgError)
                Layout(app)
                callingMainApp(app, true, true)
            end

            if checkEdition(app)
                app.btnOK.Enable = 1;
            else
                app.btnOK.Enable = 0;
            end
            
        end

        % Button pushed function: btnOK
        function ButtonPushed(app, event)
            
            callingMainApp(app, false, false)
            closeFcn(app)

        end

        % Value changed function: kFactor
        function kFactorValueChanged(app, event)
            
            kFactorTable = app.referenceData.kFactorTable;
            idxTable = find(strcmp({kFactorTable.Name}, app.kFactor.Value), 1);

            if ~isempty(idxTable)
                app.kFactorBand.Text = sprintf('%.3f - %.3f MHz', kFactorTable(idxTable).xData(1), kFactorTable(idxTable).xData(end));
            else
                app.kFactorBand.Text = '';
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
                app.UIFigure.Position = [100 100 480 360];
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
            app.GridLayout.ColumnWidth = {16, 324, 90};
            app.GridLayout.RowHeight = {22, 266, 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create kFactorPanelLabel
            app.kFactorPanelLabel = uilabel(app.GridLayout);
            app.kFactorPanelLabel.VerticalAlignment = 'bottom';
            app.kFactorPanelLabel.FontSize = 10;
            app.kFactorPanelLabel.Layout.Row = 1;
            app.kFactorPanelLabel.Layout.Column = [1 2];
            app.kFactorPanelLabel.Text = 'CALIBRAÇÃO';

            % Create kFactorPanel
            app.kFactorPanel = uipanel(app.GridLayout);
            app.kFactorPanel.AutoResizeChildren = 'off';
            app.kFactorPanel.Layout.Row = 2;
            app.kFactorPanel.Layout.Column = [1 3];

            % Create kFactorGrid
            app.kFactorGrid = uigridlayout(app.kFactorPanel);
            app.kFactorGrid.ColumnWidth = {110, '1x', 18};
            app.kFactorGrid.RowHeight = {26, 22, 18, '1x'};
            app.kFactorGrid.RowSpacing = 5;
            app.kFactorGrid.Padding = [10 10 10 5];
            app.kFactorGrid.BackgroundColor = [1 1 1];

            % Create unitRawLabel
            app.unitRawLabel = uilabel(app.kFactorGrid);
            app.unitRawLabel.VerticalAlignment = 'bottom';
            app.unitRawLabel.WordWrap = 'on';
            app.unitRawLabel.FontSize = 11;
            app.unitRawLabel.Layout.Row = 1;
            app.unitRawLabel.Layout.Column = 1;
            app.unitRawLabel.Interpreter = 'html';
            app.unitRawLabel.Text = {'Unidade original:'; '<p style="line-height:10px; font-size:9px; color:gray;">(coleta)</p>'};

            % Create unitRaw
            app.unitRaw = uieditfield(app.kFactorGrid, 'text');
            app.unitRaw.Editable = 'off';
            app.unitRaw.FontSize = 11;
            app.unitRaw.Layout.Row = 2;
            app.unitRaw.Layout.Column = 1;

            % Create kFactorLabel
            app.kFactorLabel = uilabel(app.kFactorGrid);
            app.kFactorLabel.VerticalAlignment = 'bottom';
            app.kFactorLabel.FontSize = 11;
            app.kFactorLabel.Layout.Row = 1;
            app.kFactorLabel.Layout.Column = [2 3];
            app.kFactorLabel.Interpreter = 'html';
            app.kFactorLabel.Text = {'Curva de correção:'; '<p style="line-height:10px; font-size:9px; color:gray;">(calibração, fator-k)</p>'};

            % Create kFactorBand
            app.kFactorBand = uilabel(app.kFactorGrid);
            app.kFactorBand.HorizontalAlignment = 'right';
            app.kFactorBand.VerticalAlignment = 'bottom';
            app.kFactorBand.FontSize = 11;
            app.kFactorBand.Layout.Row = 1;
            app.kFactorBand.Layout.Column = [2 3];
            app.kFactorBand.Text = '';

            % Create kFactor
            app.kFactor = uidropdown(app.kFactorGrid);
            app.kFactor.Items = {'', 'CRFS Low Band (10 MHz - 1.2 GHz)', 'CRFS High Band (750 MHz - 6 GHz)', 'Rohde & Schwarz ADDx07 (Argus)', 'Rohde & Schwarz ADD107 (20 MHz - 1.3 GHz)', 'Rohde & Schwarz ADD207 (690 MHz - 6 GHz)'};
            app.kFactor.ValueChangedFcn = createCallbackFcn(app, @kFactorValueChanged, true);
            app.kFactor.FontSize = 11;
            app.kFactor.BackgroundColor = [1 1 1];
            app.kFactor.Layout.Row = 2;
            app.kFactor.Layout.Column = [2 3];
            app.kFactor.Value = '';

            % Create kFactorAdd
            app.kFactorAdd = uiimage(app.kFactorGrid);
            app.kFactorAdd.ScaleMethod = 'none';
            app.kFactorAdd.ImageClickedFcn = createCallbackFcn(app, @FieldValueChanged, true);
            app.kFactorAdd.Layout.Row = 3;
            app.kFactorAdd.Layout.Column = 3;
            app.kFactorAdd.HorizontalAlignment = 'right';
            app.kFactorAdd.VerticalAlignment = 'bottom';
            app.kFactorAdd.ImageSource = 'Add_16.png';

            % Create kFactorTree
            app.kFactorTree = uitree(app.kFactorGrid);
            app.kFactorTree.FontSize = 10.5;
            app.kFactorTree.Layout.Row = 4;
            app.kFactorTree.Layout.Column = [1 3];

            % Create btnRefresh
            app.btnRefresh = uiimage(app.GridLayout);
            app.btnRefresh.ScaleMethod = 'none';
            app.btnRefresh.ImageClickedFcn = createCallbackFcn(app, @FieldValueChanged, true);
            app.btnRefresh.Tooltip = {'Retorna às configurações iniciais'};
            app.btnRefresh.Layout.Row = 3;
            app.btnRefresh.Layout.Column = 1;
            app.btnRefresh.ImageSource = 'Refresh_18.png';

            % Create btnOK
            app.btnOK = uibutton(app.GridLayout, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 3;
            app.btnOK.Layout.Column = 3;
            app.btnOK.Text = 'OK';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.dockAddKFactor';

            % Create ContextMenu_del
            app.ContextMenu_del = uimenu(app.ContextMenu);
            app.ContextMenu_del.MenuSelectedFcn = createCallbackFcn(app, @FieldValueChanged, true);
            app.ContextMenu_del.Text = 'Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockCalibration_exported(Container, varargin)

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
