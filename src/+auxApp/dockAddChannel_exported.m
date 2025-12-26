classdef dockAddChannel_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        Document               matlab.ui.container.GridLayout
        SatelliteIDPanelLabel  matlab.ui.control.Label
        btnOK                  matlab.ui.control.Button
        SatelliteIDPanel       matlab.ui.container.Panel
        SatelliteIDGrid        matlab.ui.container.GridLayout
        FeixeDownList          matlab.ui.control.ListBox
        FeixeDownListLabel     matlab.ui.control.Label
        PolarizationList       matlab.ui.control.ListBox
        PolarizationListLabel  matlab.ui.control.Label
        SatelliteID            matlab.ui.control.DropDown
        SatelliteIDLabel       matlab.ui.control.Label
        btnClose               matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = false

        mainApp
        specData
        idxThread

        channelTable
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            satelliteList = cellstr(unique(app.channelTable.DESIG_INT));
            if isscalar(satelliteList)
                app.SatelliteID.Items = satelliteList;
            else
                app.SatelliteID.Items = [{''}; satelliteList];
            end

            SatelliteIDValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function callingMainApp(app, updateFlag, returnFlag, varargin)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'PLAYBACK:CHANNEL', updateFlag, returnFlag, varargin{:})
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainapp, idxThread, channelTable)
            
            app.mainApp      = mainapp;
            app.specData     = mainapp.specData;

            app.idxThread    = idxThread;
            app.channelTable = channelTable;

            initialValues(app)
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: btnClose, btnOK
        function ButtonPushed(app, event)
            
            pushedButtonTag = event.Source.Tag;
            switch pushedButtonTag
                case 'OK'
                    idxChannels    = strcmp(cellstr(app.channelTable.DESIG_INT), app.SatelliteID.Value)      & ...
                                     ismember(cellstr(app.channelTable.FEIXE_DOWN), app.FeixeDownList.Value) & ...
                                     ismember(cellstr(app.channelTable.FEIXE_POLARIZ_DOWN), app.PolarizationList.Value);
                    chList         = class.EMSatDataHubLib.importSatelliteChannels(app.channelTable(idxChannels, :));

                    msgQuestion    = sprintf(['Foram extraídos os registros %s, os quais serão incluídos na lista de canais manuais do ' ...
                                              'fluxo espectral selecionado, caso se sobreponham à faixa de frequência, substituindo '    ...
                                              'eventuais canalizações inseridas manualmente que tenham um dos supracitados nomes.\n\n'   ...
                                              'Deseja analisar a inclusão desses registros para os outros fluxos?'], strjoin({chList.Name}, ', '));
                    userSelection  = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

                    switch userSelection
                        case 'Não'
                            idxThreads = app.idxThread;
                        case 'Sim'
                            idxThreads = 1:numel(app.specData);
                    end
                    typeOfChannel  = 'manual';    

                    inputArguments = {chList, typeOfChannel, idxThreads};
                    updateFlag = true;                    

                case 'Close'
                    inputArguments = {};
                    updateFlag = false;
            end

            callingMainApp(app, updateFlag, false, inputArguments{:})
            closeFcn(app)

        end

        % Value changed function: SatelliteID
        function SatelliteIDValueChanged(app, event)

            if ~isempty(app.SatelliteID.Value)
                idxSatellite = strcmp(cellstr(app.channelTable.DESIG_INT), app.SatelliteID.Value);
                app.PolarizationList.Items = cellstr(unique(app.channelTable.FEIXE_POLARIZ_DOWN(idxSatellite)));
                app.PolarizationList.Value = app.PolarizationList.Items(1);
                
            else
                app.FeixeDownList.Items    = {};
                app.PolarizationList.Items = {};
            end

            PolarizationListValueChanged(app)
            
        end

        % Value changed function: PolarizationList
        function PolarizationListValueChanged(app, event)
            
            if ~isempty(app.PolarizationList.Value)
                idxFeixe = strcmp(cellstr(app.channelTable.DESIG_INT), app.SatelliteID.Value) & ...
                           ismember(cellstr(app.channelTable.FEIXE_POLARIZ_DOWN), app.PolarizationList.Value);

                app.FeixeDownList.Items = cellstr(unique(app.channelTable.FEIXE_DOWN(idxFeixe)));
                app.FeixeDownList.Value = app.FeixeDownList.Items(1);

            else
                app.FeixeDownList.Items = {};
            end

            FeixeListValueChanged(app)
            
        end

        % Value changed function: FeixeDownList
        function FeixeListValueChanged(app, event)

            if ~isempty(app.FeixeDownList.Value) && ~isempty(app.PolarizationList.Value)
                app.btnOK.Enable = 1;
            else
                app.btnOK.Enable = 0;
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
                app.UIFigure.Position = [100 100 560 480];
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
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', 69, 16};
            app.Document.RowHeight = {22, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create SatelliteIDPanel
            app.SatelliteIDPanel = uipanel(app.Document);
            app.SatelliteIDPanel.AutoResizeChildren = 'off';
            app.SatelliteIDPanel.Layout.Row = 2;
            app.SatelliteIDPanel.Layout.Column = [1 3];

            % Create SatelliteIDGrid
            app.SatelliteIDGrid = uigridlayout(app.SatelliteIDPanel);
            app.SatelliteIDGrid.ColumnWidth = {150, '1x', 150};
            app.SatelliteIDGrid.RowHeight = {34, 22, 34, '1x'};
            app.SatelliteIDGrid.RowSpacing = 5;
            app.SatelliteIDGrid.Padding = [10 10 10 5];
            app.SatelliteIDGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create SatelliteIDLabel
            app.SatelliteIDLabel = uilabel(app.SatelliteIDGrid);
            app.SatelliteIDLabel.VerticalAlignment = 'bottom';
            app.SatelliteIDLabel.FontSize = 11;
            app.SatelliteIDLabel.Layout.Row = 1;
            app.SatelliteIDLabel.Layout.Column = 1;
            app.SatelliteIDLabel.Interpreter = 'html';
            app.SatelliteIDLabel.Text = {'Satélite:'; '<font style="color: gray; font-size: 9px;">(DESIG_INT)</font>'};

            % Create SatelliteID
            app.SatelliteID = uidropdown(app.SatelliteIDGrid);
            app.SatelliteID.Items = {};
            app.SatelliteID.ValueChangedFcn = createCallbackFcn(app, @SatelliteIDValueChanged, true);
            app.SatelliteID.FontSize = 11;
            app.SatelliteID.BackgroundColor = [1 1 1];
            app.SatelliteID.Layout.Row = 2;
            app.SatelliteID.Layout.Column = 1;
            app.SatelliteID.Value = {};

            % Create PolarizationListLabel
            app.PolarizationListLabel = uilabel(app.SatelliteIDGrid);
            app.PolarizationListLabel.VerticalAlignment = 'bottom';
            app.PolarizationListLabel.FontSize = 11;
            app.PolarizationListLabel.Layout.Row = 3;
            app.PolarizationListLabel.Layout.Column = 1;
            app.PolarizationListLabel.Interpreter = 'html';
            app.PolarizationListLabel.Text = {'Polarização:'; '<font style="color: gray; font-size: 9px;">(FEIXE_POLARIZ_DOWN)</font>'};

            % Create PolarizationList
            app.PolarizationList = uilistbox(app.SatelliteIDGrid);
            app.PolarizationList.Items = {};
            app.PolarizationList.Multiselect = 'on';
            app.PolarizationList.ValueChangedFcn = createCallbackFcn(app, @PolarizationListValueChanged, true);
            app.PolarizationList.FontSize = 11;
            app.PolarizationList.Layout.Row = 4;
            app.PolarizationList.Layout.Column = 1;
            app.PolarizationList.Value = {};

            % Create FeixeDownListLabel
            app.FeixeDownListLabel = uilabel(app.SatelliteIDGrid);
            app.FeixeDownListLabel.VerticalAlignment = 'bottom';
            app.FeixeDownListLabel.FontSize = 11;
            app.FeixeDownListLabel.Layout.Row = 3;
            app.FeixeDownListLabel.Layout.Column = [2 3];
            app.FeixeDownListLabel.Interpreter = 'html';
            app.FeixeDownListLabel.Text = {'Identificação do feixe de descida:'; '<font style="color: gray; font-size: 9px;">(FEIXE_DOWN)</font>'};

            % Create FeixeDownList
            app.FeixeDownList = uilistbox(app.SatelliteIDGrid);
            app.FeixeDownList.Items = {};
            app.FeixeDownList.Multiselect = 'on';
            app.FeixeDownList.ValueChangedFcn = createCallbackFcn(app, @FeixeListValueChanged, true);
            app.FeixeDownList.FontSize = 11;
            app.FeixeDownList.Layout.Row = 4;
            app.FeixeDownList.Layout.Column = [2 3];
            app.FeixeDownList.Value = {};

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 3;
            app.btnOK.Layout.Column = [2 3];
            app.btnOK.Text = 'OK';

            % Create SatelliteIDPanelLabel
            app.SatelliteIDPanelLabel = uilabel(app.Document);
            app.SatelliteIDPanelLabel.VerticalAlignment = 'bottom';
            app.SatelliteIDPanelLabel.FontSize = 10;
            app.SatelliteIDPanelLabel.Layout.Row = 1;
            app.SatelliteIDPanelLabel.Layout.Column = [1 2];
            app.SatelliteIDPanelLabel.Text = 'INCLUSÃO DE CANAIS';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockAddChannel_exported(Container, varargin)

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
