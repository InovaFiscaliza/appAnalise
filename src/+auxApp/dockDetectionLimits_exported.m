classdef dockDetectionLimits_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        play_BandLimits_add       matlab.ui.control.Image
        play_BandLimits_Tree      matlab.ui.control.ListBox
        play_BandLimits_Panel     matlab.ui.container.Panel
        play_BandLimits_Grid      matlab.ui.container.GridLayout
        play_BandLimits_xLabel_2  matlab.ui.control.Label
        play_BandLimits_xLim2     matlab.ui.control.NumericEditField
        play_BandLimits_xLabel    matlab.ui.control.Label
        play_BandLimits_xLim1     matlab.ui.control.NumericEditField
        play_BandLimits_Status    matlab.ui.control.CheckBox
        ContextMenu               matlab.ui.container.ContextMenu
        ExcluirMenu               matlab.ui.container.Menu
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
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel(app)
            if specData.UserData.DetectionSubBandsEnabled && ~isempty(specData.UserData.DetectionSubBands)
                app.FlowDetectionLimits.Items = cellstr(string(specData.UserData.DetectionSubBands.FreqStart) + " – " + string(specData.UserData.DetectionSubBands.FreqStop) + " MHz");
            else
                app.FlowDetectionLimits.Items = {sprintf('%.3f – %.3f MHz (padrão)', specData.MetaData.FreqStart/1e+6, specData.MetaData.FreqStop/1e+6)};
            end

        end
        
        %-----------------------------------------------------------------%
        function updateStatus(app, specData)
            update(specData, 'UserData:BandLimits', 'Status:Edit', app.play_BandLimits_Status.Value)

            if app.play_BandLimits_Status.Value
                set(app.play_BandLimits_Grid.Children, 'Enable', 'on')
                app.play_BandLimits_add.Enable  = 1;
                app.play_BandLimits_Tree.Enable = 1;

            else
                set(findobj(app.play_BandLimits_Grid, 'Type', 'uinumericeditfield'), 'Enable', 'off')
                app.play_BandLimits_add.Enable  = 0;
                app.play_BandLimits_Tree.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function buildTree(app, idx)
            
            if ~isempty(app.play_BandLimits_Tree.Children)
                delete(app.play_BandLimits_Tree.Children)
            end

            bandLimitsTable = app.specData(idx).UserData.bandLimitsTable;
            for ii = 1:height(bandLimitsTable)
                uitreenode(app.play_BandLimits_Tree, 'Text', sprintf('%.3f - %.3f MHz', bandLimitsTable.FreqStart(ii), bandLimitsTable.FreqStop(ii)), ...
                                                     'NodeData', ii, 'ContextMenu', app.play_BandLimits_ContextMenu);
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
                updatePanel(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Value changed function: play_BandLimits_Status
        function onSubBandsModeChanged(app, event)
            
            specData = app.callingApp.bandObj.SpecData;
            updateStatus(app, specData)

            if app.play_BandLimits_Status.Value && ~isempty(specData.UserData.bandLimitsTable) && ~isempty(specData.UserData.Emissions)
                questionMsg = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                
                if userSelection == "Não"
                    app.play_BandLimits_Status.Value = 0;
                    updateStatus(app, specData)
                    return
                end

                % Identificar o índice da emissão selecionada, para o qual
                % foi desenhado um ROI no app.axes1.
                idxEmission = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;
                newIndex = app.specData(idx).UserData.Emissions.idxFrequency(idxEmission);

                plot_updateSelectedEmission(app, idx, newIndex)
                play_UpdateAuxiliarApps(app)
            end

            plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')
            
        end

        % Image clicked function: play_BandLimits_add
        function onSubBandsAdded(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            bandLimitsTable = app.specData(idx).UserData.bandLimitsTable;

            % Validações:
            if app.play_BandLimits_xLim2.Value <= app.play_BandLimits_xLim1.Value                    
                ui.Dialog(app.UIFigure, 'warning', 'Subfaixa inválida.');
                return

            elseif any((bandLimitsTable.FreqStart <= app.play_BandLimits_xLim1.Value) & (bandLimitsTable.FreqStop >= app.play_BandLimits_xLim2.Value))
                ui.Dialog(app.UIFigure, 'warning', 'Subfaixa já contemplada.');
                return
            end

            % Compara subfaixa a analisar inserida com os registros já existentes.
            xLim1 = app.play_BandLimits_xLim1.Value;
            xLim2 = app.play_BandLimits_xLim2.Value;

            % Passo 1 de 2
            Flag = true;
            for ii = 1:height(bandLimitsTable)
                if (xLim1 <= bandLimitsTable.FreqStart(ii)) && (xLim2 >= bandLimitsTable.FreqStop(ii))
                    bandLimitsTable(ii,:) = {xLim1, xLim2};
                    Flag = false;
                    continue
                
                elseif (xLim1 <= bandLimitsTable.FreqStart(ii)) && (xLim2 > bandLimitsTable.FreqStart(ii)) && (xLim2 < bandLimitsTable.FreqStop(ii))
                    bandLimitsTable(ii,1) = {xLim1};
                    Flag = false;
                    continue

                elseif (xLim1 > bandLimitsTable.FreqStart(ii)) && (xLim1 < bandLimitsTable.FreqStop(ii)) && (xLim2 >= bandLimitsTable.FreqStop(ii))
                    bandLimitsTable(ii,2) = {xLim2};
                    Flag = false;
                    continue
                end
            end

            if Flag
                bandLimitsTable(end+1,:) = {xLim1, xLim2};
            end
            bandLimitsTable = sortrows(bandLimitsTable, 'FreqStart');

            % Passo 2 de 2
            for ii = height(bandLimitsTable):-1:2
                if bandLimitsTable.FreqStart(ii) <= bandLimitsTable.FreqStop(ii-1)
                    bandLimitsTable(ii-1,2) = {bandLimitsTable.FreqStop(ii)};
                    bandLimitsTable(ii,:)   = [];
                end
            end

            if isempty(app.specData(idx).UserData.bandLimitsTable) && ~isempty(app.specData(idx).UserData.Emissions)
                msgQuestion   = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end

                % Identificar o índice da emissão selecionada, para o qual
                % foi desenhado um ROI no app.axes1.
                idxEmission  = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;
                idxFrequency = app.specData(idx).UserData.Emissions.idxFrequency(idxEmission);

                update(app.specData(idx), 'UserData:BandLimits', 'Table:Edit', bandLimitsTable)
                plot_updateSelectedEmission(app, idx, idxFrequency)
                play_UpdateAuxiliarApps(app)

            else
                update(app.specData(idx), 'UserData:BandLimits', 'Table:Edit', bandLimitsTable)
            end

            buildTree(app, idx)
            plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')

        end

        % Menu selected function: ExcluirMenu
        function onSubBandsDeleted(app, event)
            
            if ~isempty(app.play_BandLimits_Tree.SelectedNodes)
                idx = app.play_PlotPanel.UserData.NodeData;
                idxBandLimits = [app.play_BandLimits_Tree.SelectedNodes.NodeData];
                
                if ~isempty(app.specData(idx).UserData.Emissions) && height(app.specData(idx).UserData.bandLimitsTable) > 1
                    msgQuestion   = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                    userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        return
                    end
                end

                update(app.specData(idx), 'UserData:BandLimits', 'Table:DeleteRows', idxBandLimits)
                if exist('userSelection', 'var')
                    plot_updateSelectedEmission(app, idx, app.specData(idx).UserData.Emissions.idxFrequency)
                    play_UpdateAuxiliarApps(app)
                end
    
                buildTree(app, idx)
                plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')
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
                app.UIFigure.Position = [100 100 292 360];
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
            app.GridLayout.ColumnWidth = {224, 18};
            app.GridLayout.RowHeight = {22, 76, 22, '1x'};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create play_BandLimits_Status
            app.play_BandLimits_Status = uicheckbox(app.GridLayout);
            app.play_BandLimits_Status.ValueChangedFcn = createCallbackFcn(app, @onSubBandsModeChanged, true);
            app.play_BandLimits_Status.Text = 'Limitar detecção de emissões a subfaixa(s)';
            app.play_BandLimits_Status.FontSize = 11;
            app.play_BandLimits_Status.Layout.Row = 1;
            app.play_BandLimits_Status.Layout.Column = [1 2];

            % Create play_BandLimits_Panel
            app.play_BandLimits_Panel = uipanel(app.GridLayout);
            app.play_BandLimits_Panel.AutoResizeChildren = 'off';
            app.play_BandLimits_Panel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.play_BandLimits_Panel.Layout.Row = 2;
            app.play_BandLimits_Panel.Layout.Column = [1 2];
            app.play_BandLimits_Panel.FontSize = 10;

            % Create play_BandLimits_Grid
            app.play_BandLimits_Grid = uigridlayout(app.play_BandLimits_Panel);
            app.play_BandLimits_Grid.ColumnWidth = {110, 110};
            app.play_BandLimits_Grid.RowHeight = {26, 22};
            app.play_BandLimits_Grid.RowSpacing = 5;
            app.play_BandLimits_Grid.BackgroundColor = [1 1 1];

            % Create play_BandLimits_xLim1
            app.play_BandLimits_xLim1 = uieditfield(app.play_BandLimits_Grid, 'numeric');
            app.play_BandLimits_xLim1.ValueDisplayFormat = '%.3f';
            app.play_BandLimits_xLim1.FontSize = 11;
            app.play_BandLimits_xLim1.Enable = 'off';
            app.play_BandLimits_xLim1.Layout.Row = 2;
            app.play_BandLimits_xLim1.Layout.Column = 1;

            % Create play_BandLimits_xLabel
            app.play_BandLimits_xLabel = uilabel(app.play_BandLimits_Grid);
            app.play_BandLimits_xLabel.VerticalAlignment = 'bottom';
            app.play_BandLimits_xLabel.FontSize = 11;
            app.play_BandLimits_xLabel.Layout.Row = 1;
            app.play_BandLimits_xLabel.Layout.Column = 1;
            app.play_BandLimits_xLabel.Text = {'Frequência inicial:'; '(MHz)'};

            % Create play_BandLimits_xLim2
            app.play_BandLimits_xLim2 = uieditfield(app.play_BandLimits_Grid, 'numeric');
            app.play_BandLimits_xLim2.ValueDisplayFormat = '%.3f';
            app.play_BandLimits_xLim2.FontSize = 11;
            app.play_BandLimits_xLim2.Enable = 'off';
            app.play_BandLimits_xLim2.Layout.Row = 2;
            app.play_BandLimits_xLim2.Layout.Column = 2;

            % Create play_BandLimits_xLabel_2
            app.play_BandLimits_xLabel_2 = uilabel(app.play_BandLimits_Grid);
            app.play_BandLimits_xLabel_2.VerticalAlignment = 'bottom';
            app.play_BandLimits_xLabel_2.FontSize = 11;
            app.play_BandLimits_xLabel_2.Layout.Row = 1;
            app.play_BandLimits_xLabel_2.Layout.Column = 2;
            app.play_BandLimits_xLabel_2.Text = {'Frequência final:'; '(MHz)'};

            % Create play_BandLimits_Tree
            app.play_BandLimits_Tree = uilistbox(app.GridLayout);
            app.play_BandLimits_Tree.Items = {};
            app.play_BandLimits_Tree.Enable = 'off';
            app.play_BandLimits_Tree.FontSize = 11;
            app.play_BandLimits_Tree.Layout.Row = 4;
            app.play_BandLimits_Tree.Layout.Column = [1 2];
            app.play_BandLimits_Tree.Value = {};

            % Create play_BandLimits_add
            app.play_BandLimits_add = uiimage(app.GridLayout);
            app.play_BandLimits_add.ScaleMethod = 'none';
            app.play_BandLimits_add.ImageClickedFcn = createCallbackFcn(app, @onSubBandsAdded, true);
            app.play_BandLimits_add.Enable = 'off';
            app.play_BandLimits_add.Layout.Row = 3;
            app.play_BandLimits_add.Layout.Column = 2;
            app.play_BandLimits_add.ImageSource = 'Add_16.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create ExcluirMenu
            app.ExcluirMenu = uimenu(app.ContextMenu);
            app.ExcluirMenu.MenuSelectedFcn = createCallbackFcn(app, @onSubBandsDeleted, true);
            app.ExcluirMenu.Text = '❌ Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockDetectionLimits_exported(Container, varargin)

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
