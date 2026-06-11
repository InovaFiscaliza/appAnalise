classdef dockDetectionLimits_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure         matlab.ui.Figure
        GridLayout       matlab.ui.container.GridLayout
        SubBandsList     matlab.ui.control.ListBox
        SubBandsButton   matlab.ui.control.Image
        EntryPanel       matlab.ui.container.Panel
        EntryGrid        matlab.ui.container.GridLayout
        EntryXLim2       matlab.ui.control.NumericEditField
        EntryXLim2Label  matlab.ui.control.Label
        EntryXLim1       matlab.ui.control.NumericEditField
        EntryXLim1Label  matlab.ui.control.Label
        SubBandsMode     matlab.ui.control.CheckBox
        ContextMenu      matlab.ui.container.ContextMenu
        DeleteOption     matlab.ui.container.Menu
        DeleteAllOption  matlab.ui.container.Menu
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
        function initialValues(app)
            specData = app.callingApp.bandObj.SpecData;
            limits = [specData.MetaData.FreqStart, specData.MetaData.FreqStop] / 1e+6;
            
            set([app.EntryXLim1, app.EntryXLim2], 'Limits', limits)
            app.EntryXLim1.Value = limits(1);
            app.EntryXLim2.Value = limits(2);

            updatePanel(app, specData)
            updateStatus(app)
        end

        %-----------------------------------------------------------------%
        function updatePanel(app, specData)
            app.SubBandsMode.Value = specData.UserData.DetectionSubBandsEnabled;

            if ~isempty(specData.UserData.DetectionSubBands)
                app.SubBandsList.Items = cellstr(string(specData.UserData.DetectionSubBands.FreqStart) + " – " + string(specData.UserData.DetectionSubBands.FreqStop) + " MHz");
            else
                app.SubBandsList.Items = {};
            end

            if app.SubBandsMode.Value && ~isempty(app.SubBandsList.Items)
                app.SubBandsList.ContextMenu = app.ContextMenu;
            else
                app.SubBandsList.ContextMenu = [];
            end
        end
        
        %-----------------------------------------------------------------%
        function updateStatus(app)
            elHandles = findobj(app.EntryGrid, 'Type', 'uinumericeditfield');
            if app.SubBandsMode.Value
                set(elHandles, 'Enable', 'on')
                app.SubBandsButton.Enable = 'on';
                app.SubBandsList.Enable = 'on';

            else
                set(elHandles, 'Enable', 'off')
                app.SubBandsButton.Enable = 'off';
                app.SubBandsList.Enable = 'off';
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
                initialValues(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Value changed function: SubBandsMode
        function onSubBandsModeChanged(app, event)
            
            specData = app.callingApp.bandObj.SpecData;

            if app.SubBandsMode.Value && ~isempty(specData.UserData.DetectionSubBands) && ~isempty(specData.UserData.Emissions)
                questionMsg = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                
                if userSelection == "Não"
                    app.SubBandsMode.Value = false;
                    return
                end
            end

            requestVisibilityChange(app.progressDialog, 'visible', 'locked')

            numEmissions = height(specData.UserData.Emissions);
            update(specData, 'UserData:BandLimits', 'Status:Edit', app.SubBandsMode.Value)
            emissionsDeleted = numEmissions ~= height(specData.UserData.Emissions);
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onDetectionSubBandsChanged', emissionsDeleted)
            
            updatePanel(app, specData)
            updateStatus(app)

            requestVisibilityChange(app.progressDialog, 'hidden', 'locked')
            
        end

        % Image clicked function: SubBandsButton
        function onSubBandsAdded(app, event)
            
            specData = app.callingApp.bandObj.SpecData;
            subBands = specData.UserData.DetectionSubBands;

            % Validações:
            if app.EntryXLim2.Value <= app.EntryXLim1.Value                    
                ui.Dialog(app.UIFigure, 'warning', 'Subfaixa inválida.');
                return

            elseif any((subBands.FreqStart <= app.EntryXLim1.Value) & (subBands.FreqStop >= app.EntryXLim2.Value))
                ui.Dialog(app.UIFigure, 'warning', 'Subfaixa já contemplada.');
                return
            end

            % Compara subfaixa a analisar inserida com os registros já existentes.
            xLim1 = app.EntryXLim1.Value;
            xLim2 = app.EntryXLim2.Value;

            % Passo 1 de 2
            Flag = true;
            for ii = 1:height(subBands)
                if (xLim1 <= subBands.FreqStart(ii)) && (xLim2 >= subBands.FreqStop(ii))
                    subBands(ii,:) = {xLim1, xLim2};
                    Flag = false;
                    continue
                
                elseif (xLim1 <= subBands.FreqStart(ii)) && (xLim2 > subBands.FreqStart(ii)) && (xLim2 < subBands.FreqStop(ii))
                    subBands(ii,1) = {xLim1};
                    Flag = false;
                    continue

                elseif (xLim1 > subBands.FreqStart(ii)) && (xLim1 < subBands.FreqStop(ii)) && (xLim2 >= subBands.FreqStop(ii))
                    subBands(ii,2) = {xLim2};
                    Flag = false;
                    continue
                end
            end

            if Flag
                subBands(end+1,:) = {xLim1, xLim2};
            end
            subBands = sortrows(subBands, 'FreqStart');

            % Passo 2 de 2
            for ii = height(subBands):-1:2
                if subBands.FreqStart(ii) <= subBands.FreqStop(ii-1)
                    subBands(ii-1,2) = {subBands.FreqStop(ii)};
                    subBands(ii,:)   = [];
                end
            end

            requestVisibilityChange(app.progressDialog, 'visible', 'locked')

            numEmissions = height(specData.UserData.Emissions);
            update(specData, 'UserData:BandLimits', 'Table:Edit', subBands)
            emissionsDeleted = numEmissions ~= height(specData.UserData.Emissions);
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onDetectionSubBandsChanged', emissionsDeleted)
            
            updatePanel(app, specData)
            updateStatus(app)

            requestVisibilityChange(app.progressDialog, 'hidden', 'locked')

        end

        % Menu selected function: DeleteAllOption, DeleteOption
        function onSubBandsDeleted(app, event)
            
            specData = app.callingApp.bandObj.SpecData;

            switch event.Source
                case app.DeleteOption
                    subBandsIdxs = app.SubBandsList.ValueIndex;

                case app.DeleteAllOption
                    subBandsIdxs = 1:height(specData.UserData.DetectionSubBands);
            end

            if isempty(subBandsIdxs)
                return
            end

            requestVisibilityChange(app.progressDialog, 'visible', 'locked')

            update(specData, 'UserData:BandLimits', 'Table:DeleteRows', subBandsIdxs)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onDetectionSubBandsChanged', true)
            
            updatePanel(app, specData)
            updateStatus(app)

            requestVisibilityChange(app.progressDialog, 'hidden', 'locked')

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

            % Create SubBandsMode
            app.SubBandsMode = uicheckbox(app.GridLayout);
            app.SubBandsMode.ValueChangedFcn = createCallbackFcn(app, @onSubBandsModeChanged, true);
            app.SubBandsMode.Text = 'Limitar detecção de emissões a subfaixa(s)';
            app.SubBandsMode.FontSize = 11;
            app.SubBandsMode.Layout.Row = 1;
            app.SubBandsMode.Layout.Column = [1 2];

            % Create EntryPanel
            app.EntryPanel = uipanel(app.GridLayout);
            app.EntryPanel.AutoResizeChildren = 'off';
            app.EntryPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.EntryPanel.Layout.Row = 2;
            app.EntryPanel.Layout.Column = [1 2];
            app.EntryPanel.FontSize = 10;

            % Create EntryGrid
            app.EntryGrid = uigridlayout(app.EntryPanel);
            app.EntryGrid.ColumnWidth = {110, 110};
            app.EntryGrid.RowHeight = {26, 22};
            app.EntryGrid.RowSpacing = 5;
            app.EntryGrid.BackgroundColor = [1 1 1];

            % Create EntryXLim1Label
            app.EntryXLim1Label = uilabel(app.EntryGrid);
            app.EntryXLim1Label.VerticalAlignment = 'bottom';
            app.EntryXLim1Label.FontSize = 11;
            app.EntryXLim1Label.Layout.Row = 1;
            app.EntryXLim1Label.Layout.Column = 1;
            app.EntryXLim1Label.Text = {'Frequência inicial:'; '(MHz)'};

            % Create EntryXLim1
            app.EntryXLim1 = uieditfield(app.EntryGrid, 'numeric');
            app.EntryXLim1.ValueDisplayFormat = '%.3f';
            app.EntryXLim1.FontSize = 11;
            app.EntryXLim1.Enable = 'off';
            app.EntryXLim1.Layout.Row = 2;
            app.EntryXLim1.Layout.Column = 1;

            % Create EntryXLim2Label
            app.EntryXLim2Label = uilabel(app.EntryGrid);
            app.EntryXLim2Label.VerticalAlignment = 'bottom';
            app.EntryXLim2Label.FontSize = 11;
            app.EntryXLim2Label.Layout.Row = 1;
            app.EntryXLim2Label.Layout.Column = 2;
            app.EntryXLim2Label.Text = {'Frequência final:'; '(MHz)'};

            % Create EntryXLim2
            app.EntryXLim2 = uieditfield(app.EntryGrid, 'numeric');
            app.EntryXLim2.ValueDisplayFormat = '%.3f';
            app.EntryXLim2.FontSize = 11;
            app.EntryXLim2.Enable = 'off';
            app.EntryXLim2.Layout.Row = 2;
            app.EntryXLim2.Layout.Column = 2;

            % Create SubBandsButton
            app.SubBandsButton = uiimage(app.GridLayout);
            app.SubBandsButton.ScaleMethod = 'none';
            app.SubBandsButton.ImageClickedFcn = createCallbackFcn(app, @onSubBandsAdded, true);
            app.SubBandsButton.Enable = 'off';
            app.SubBandsButton.Layout.Row = 3;
            app.SubBandsButton.Layout.Column = 2;
            app.SubBandsButton.ImageSource = 'Add_16.png';

            % Create SubBandsList
            app.SubBandsList = uilistbox(app.GridLayout);
            app.SubBandsList.Items = {};
            app.SubBandsList.Multiselect = 'on';
            app.SubBandsList.Enable = 'off';
            app.SubBandsList.FontSize = 11;
            app.SubBandsList.Layout.Row = 4;
            app.SubBandsList.Layout.Column = [1 2];
            app.SubBandsList.Value = {};

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create DeleteOption
            app.DeleteOption = uimenu(app.ContextMenu);
            app.DeleteOption.MenuSelectedFcn = createCallbackFcn(app, @onSubBandsDeleted, true);
            app.DeleteOption.Text = '❌ Excluir';

            % Create DeleteAllOption
            app.DeleteAllOption = uimenu(app.ContextMenu);
            app.DeleteAllOption.MenuSelectedFcn = createCallbackFcn(app, @onSubBandsDeleted, true);
            app.DeleteAllOption.Text = '🚫 Excluir tudo';

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
