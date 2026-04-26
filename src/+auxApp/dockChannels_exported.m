classdef dockChannels_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        AddChannelButton              matlab.ui.control.Button
        ParametersPanel               matlab.ui.container.Panel
        GridLayout3                   matlab.ui.container.GridLayout
        SatelliteIDGrid               matlab.ui.container.GridLayout
        FeixeDownList                 matlab.ui.control.ListBox
        FeixeDownListLabel            matlab.ui.control.Label
        PolarizationList              matlab.ui.control.ListBox
        PolarizationListLabel         matlab.ui.control.Label
        SatelliteID                   matlab.ui.control.DropDown
        SatelliteIDLabel              matlab.ui.control.Label
        GridLayout_2                  matlab.ui.container.GridLayout
        Location                      matlab.ui.control.ListBox
        LocationLabel                 matlab.ui.control.Label
        Delete                        matlab.ui.control.Image
        Add                           matlab.ui.control.Image
        RefLocation                   matlab.ui.control.ListBox
        RefLocationLabel              matlab.ui.control.Label
        GridLayout2                   matlab.ui.container.GridLayout
        DataHubPOSTButton             matlab.ui.control.Image
        ExternalFileTemplateDownload  matlab.ui.control.Hyperlink
        ExternalFileSource            matlab.ui.control.DropDown
        ExternalFileSourceLabel       matlab.ui.control.Label
        ParametersGrid                matlab.ui.container.GridLayout
        ChannelSample                 matlab.ui.control.Label
        BandWidth                     matlab.ui.control.NumericEditField
        BandWidthLabel                matlab.ui.control.Label
        StepWidth                     matlab.ui.control.NumericEditField
        StepWidthLabel                matlab.ui.control.Label
        EmissionClass                 matlab.ui.control.DropDown
        EmissionClassLabel            matlab.ui.control.Label
        LastChannel                   matlab.ui.control.NumericEditField
        LastChannelLabel              matlab.ui.control.Label
        FirstChannel                  matlab.ui.control.NumericEditField
        FirstChannelLabel             matlab.ui.control.Label
        NumChannels                   matlab.ui.control.NumericEditField
        NumChannelsLabel              matlab.ui.control.Label
        ChannelReferenceName          matlab.ui.control.EditField
        ChannelReferenceList          matlab.ui.control.DropDown
        ChannelListUpdateButton       matlab.ui.control.Image
        ChannelListLabel              matlab.ui.control.Label
        RadioButtonPanel              matlab.ui.container.ButtonGroup
        FileImport                    matlab.ui.control.RadioButton
        SingleChannel                 matlab.ui.control.RadioButton
        FrequencyRange                matlab.ui.control.RadioButton
        ReferenceChannel              matlab.ui.control.RadioButton
        RadioButtonPanelLabel         matlab.ui.control.Label
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
            elHandles = app.ParametersGrid.Children;
            elHandlesTags = {elHandles.Tag};

            switch app.RadioButtonPanel.SelectedObject
                case app.ReferenceChannel
                    relatedTag = 'ReferenceChannel';
                    app.ParametersGrid.RowHeight = {26, 22, 0, 32, 22, 32, 22, '1x', 0, 0, 0};
                
                case app.FrequencyRange
                    relatedTag = 'FrequencyRange';
                    app.ParametersGrid.RowHeight = {26, 0, 22, 32, 22, 32, 22, '1x', 0, 0, 0};

                case app.SingleChannel
                    relatedTag = 'SingleChannel';
                    app.ParametersGrid.RowHeight = {26, 0, 22, 32, 22, 32, 22, '1x', 0, 0, 0};
                
                case app.FileImport
                    relatedTag = 'ExternalFile';
                    app.ParametersGrid.RowHeight = {0, 0, 0, 0, 0, 0, 0, 0, 26, 22, 22};
            end

            relatedElHandles = elHandles(contains(elHandlesTags, relatedTag));

            set(relatedElHandles, 'Visible', true)
            set(setdiff(elHandles, relatedElHandles), 'Visible', false)
        end

        %-----------------------------------------------------------------%
        function initialValues(app)
            % ...
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

        % Button pushed function: AddChannelButton
        function ButtonPushed(app, event)

            specData = app.callingApp.bandObj.SpecData;
            % ...

        end

        % Selection changed function: RadioButtonPanel
        function RadioButtonPanelSelectionChanged(app, event)
            
            updatePanel(app)
            
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
                app.UIFigure.Position = [100 100 419 585];
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
            app.GridLayout.ColumnWidth = {'1x', 110};
            app.GridLayout.RowHeight = {17, 166, '1x', 22};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create RadioButtonPanelLabel
            app.RadioButtonPanelLabel = uilabel(app.GridLayout);
            app.RadioButtonPanelLabel.VerticalAlignment = 'bottom';
            app.RadioButtonPanelLabel.FontSize = 10;
            app.RadioButtonPanelLabel.Layout.Row = 1;
            app.RadioButtonPanelLabel.Layout.Column = 1;
            app.RadioButtonPanelLabel.Text = 'ORIGEM:';

            % Create RadioButtonPanel
            app.RadioButtonPanel = uibuttongroup(app.GridLayout);
            app.RadioButtonPanel.AutoResizeChildren = 'off';
            app.RadioButtonPanel.SelectionChangedFcn = createCallbackFcn(app, @RadioButtonPanelSelectionChanged, true);
            app.RadioButtonPanel.BackgroundColor = [1 1 1];
            app.RadioButtonPanel.Layout.Row = 2;
            app.RadioButtonPanel.Layout.Column = [1 2];

            % Create ReferenceChannel
            app.ReferenceChannel = uiradiobutton(app.RadioButtonPanel);
            app.ReferenceChannel.Text = {'Canalização de referência'; '<font style="font-size: 10px; color: gray;">Inclui canais relacionados a canalizações já cadastradas no appAnalise.</font>'};
            app.ReferenceChannel.FontSize = 11;
            app.ReferenceChannel.Interpreter = 'html';
            app.ReferenceChannel.Position = [11 128 352 29];
            app.ReferenceChannel.Value = true;

            % Create FrequencyRange
            app.FrequencyRange = uiradiobutton(app.RadioButtonPanel);
            app.FrequencyRange.Text = {'Faixa de frequência'; '<font style="font-size: 10px; color: gray;">Inclui lista de canais definida pela faixa de frequência, largura de cada canal e espaçamento entre canais.</font>'};
            app.FrequencyRange.WordWrap = 'on';
            app.FrequencyRange.FontSize = 11;
            app.FrequencyRange.Interpreter = 'html';
            app.FrequencyRange.Position = [11 78 348 45];

            % Create SingleChannel
            app.SingleChannel = uiradiobutton(app.RadioButtonPanel);
            app.SingleChannel.Text = {'Canal'; '<font style="font-size: 10px; color: gray;">Inclui um único canal definido pela frequência e largura.</font>'};
            app.SingleChannel.FontSize = 11;
            app.SingleChannel.Interpreter = 'html';
            app.SingleChannel.Position = [11 46 348 29];

            % Create FileImport
            app.FileImport = uiradiobutton(app.RadioButtonPanel);
            app.FileImport.Text = {'Arquivo'; '<font style="font-size: 10px; color: gray;">Inclui canais listados em arquivo (ex: plano de frequência de transponder).</font>'};
            app.FileImport.WordWrap = 'on';
            app.FileImport.FontSize = 11;
            app.FileImport.Interpreter = 'html';
            app.FileImport.Position = [11 14 360 29];

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.GridLayout);
            app.ParametersPanel.AutoResizeChildren = 'off';
            app.ParametersPanel.Layout.Row = 3;
            app.ParametersPanel.Layout.Column = [1 2];

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ParametersPanel);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {0, 80, '1x', 0};
            app.GridLayout3.RowSpacing = 5;
            app.GridLayout3.BackgroundColor = [1 1 1];

            % Create ParametersGrid
            app.ParametersGrid = uigridlayout(app.GridLayout3);
            app.ParametersGrid.ColumnWidth = {110, 110, 84, 16};
            app.ParametersGrid.RowHeight = {26, 22, 0, 32, 22, 32, 22, '1x'};
            app.ParametersGrid.RowSpacing = 5;
            app.ParametersGrid.Padding = [0 0 0 0];
            app.ParametersGrid.Layout.Row = 1;
            app.ParametersGrid.Layout.Column = 1;
            app.ParametersGrid.BackgroundColor = [1 1 1];

            % Create ChannelListLabel
            app.ChannelListLabel = uilabel(app.ParametersGrid);
            app.ChannelListLabel.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.ChannelListLabel.VerticalAlignment = 'bottom';
            app.ChannelListLabel.FontSize = 11;
            app.ChannelListLabel.Layout.Row = 1;
            app.ChannelListLabel.Layout.Column = [1 3];
            app.ChannelListLabel.Text = {'Referência da canalização:'; '(tecnologia, serviço etc)'};

            % Create ChannelListUpdateButton
            app.ChannelListUpdateButton = uiimage(app.ParametersGrid);
            app.ChannelListUpdateButton.ScaleMethod = 'none';
            app.ChannelListUpdateButton.Tag = 'ReferenceChannel';
            app.ChannelListUpdateButton.Visible = 'off';
            app.ChannelListUpdateButton.Tooltip = {''};
            app.ChannelListUpdateButton.Layout.Row = 1;
            app.ChannelListUpdateButton.Layout.Column = 4;
            app.ChannelListUpdateButton.VerticalAlignment = 'bottom';
            app.ChannelListUpdateButton.ImageSource = 'Refresh_18.png';

            % Create ChannelReferenceList
            app.ChannelReferenceList = uidropdown(app.ParametersGrid);
            app.ChannelReferenceList.Items = {};
            app.ChannelReferenceList.Tag = 'ReferenceChannel';
            app.ChannelReferenceList.FontSize = 11;
            app.ChannelReferenceList.BackgroundColor = [1 1 1];
            app.ChannelReferenceList.Layout.Row = 2;
            app.ChannelReferenceList.Layout.Column = [1 4];
            app.ChannelReferenceList.Value = {};

            % Create ChannelReferenceName
            app.ChannelReferenceName = uieditfield(app.ParametersGrid, 'text');
            app.ChannelReferenceName.CharacterLimits = [0 128];
            app.ChannelReferenceName.Tag = 'FrequencyRange+SingleChannel';
            app.ChannelReferenceName.Enable = 'off';
            app.ChannelReferenceName.Layout.Row = 3;
            app.ChannelReferenceName.Layout.Column = [1 4];

            % Create NumChannelsLabel
            app.NumChannelsLabel = uilabel(app.ParametersGrid);
            app.NumChannelsLabel.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.NumChannelsLabel.VerticalAlignment = 'bottom';
            app.NumChannelsLabel.WordWrap = 'on';
            app.NumChannelsLabel.FontSize = 11;
            app.NumChannelsLabel.Layout.Row = 4;
            app.NumChannelsLabel.Layout.Column = 1;
            app.NumChannelsLabel.Text = {'Quantidade de'; 'canais:'};

            % Create NumChannels
            app.NumChannels = uieditfield(app.ParametersGrid, 'numeric');
            app.NumChannels.Limits = [-1 Inf];
            app.NumChannels.RoundFractionalValues = 'on';
            app.NumChannels.ValueDisplayFormat = '%d';
            app.NumChannels.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.NumChannels.Editable = 'off';
            app.NumChannels.FontSize = 11;
            app.NumChannels.Layout.Row = 5;
            app.NumChannels.Layout.Column = 1;
            app.NumChannels.Value = 1;

            % Create FirstChannelLabel
            app.FirstChannelLabel = uilabel(app.ParametersGrid);
            app.FirstChannelLabel.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.FirstChannelLabel.VerticalAlignment = 'bottom';
            app.FirstChannelLabel.WordWrap = 'on';
            app.FirstChannelLabel.FontSize = 11;
            app.FirstChannelLabel.Layout.Row = 4;
            app.FirstChannelLabel.Layout.Column = 2;
            app.FirstChannelLabel.Text = {'Frequência central'; '1º canal (MHz):'};

            % Create FirstChannel
            app.FirstChannel = uieditfield(app.ParametersGrid, 'numeric');
            app.FirstChannel.Limits = [0 Inf];
            app.FirstChannel.ValueDisplayFormat = '%.3f';
            app.FirstChannel.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.FirstChannel.FontSize = 11;
            app.FirstChannel.Layout.Row = 5;
            app.FirstChannel.Layout.Column = 2;

            % Create LastChannelLabel
            app.LastChannelLabel = uilabel(app.ParametersGrid);
            app.LastChannelLabel.Tag = 'ReferenceChannel+FrequencyRange';
            app.LastChannelLabel.VerticalAlignment = 'bottom';
            app.LastChannelLabel.WordWrap = 'on';
            app.LastChannelLabel.FontSize = 11;
            app.LastChannelLabel.Layout.Row = 4;
            app.LastChannelLabel.Layout.Column = [3 4];
            app.LastChannelLabel.Text = {'Frequência central'; 'n-ésimo canal:'};

            % Create LastChannel
            app.LastChannel = uieditfield(app.ParametersGrid, 'numeric');
            app.LastChannel.Limits = [0 Inf];
            app.LastChannel.ValueDisplayFormat = '%.3f';
            app.LastChannel.Tag = 'ReferenceChannel+FrequencyRange';
            app.LastChannel.FontSize = 11;
            app.LastChannel.Layout.Row = 5;
            app.LastChannel.Layout.Column = [3 4];

            % Create EmissionClassLabel
            app.EmissionClassLabel = uilabel(app.ParametersGrid);
            app.EmissionClassLabel.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.EmissionClassLabel.VerticalAlignment = 'bottom';
            app.EmissionClassLabel.WordWrap = 'on';
            app.EmissionClassLabel.FontSize = 11;
            app.EmissionClassLabel.Layout.Row = 6;
            app.EmissionClassLabel.Layout.Column = 1;
            app.EmissionClassLabel.Text = 'Classe de emissões da faixa/canal:';

            % Create EmissionClass
            app.EmissionClass = uidropdown(app.ParametersGrid);
            app.EmissionClass.Items = {''};
            app.EmissionClass.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.EmissionClass.FontSize = 11;
            app.EmissionClass.BackgroundColor = [1 1 1];
            app.EmissionClass.Layout.Row = 7;
            app.EmissionClass.Layout.Column = 1;
            app.EmissionClass.Value = '';

            % Create StepWidthLabel
            app.StepWidthLabel = uilabel(app.ParametersGrid);
            app.StepWidthLabel.Tag = 'ReferenceChannel+FrequencyRange';
            app.StepWidthLabel.VerticalAlignment = 'bottom';
            app.StepWidthLabel.WordWrap = 'on';
            app.StepWidthLabel.FontSize = 11;
            app.StepWidthLabel.Layout.Row = 6;
            app.StepWidthLabel.Layout.Column = 2;
            app.StepWidthLabel.Text = {'Espaçamento canais'; '(kHz):'};

            % Create StepWidth
            app.StepWidth = uieditfield(app.ParametersGrid, 'numeric');
            app.StepWidth.Limits = [-1 Inf];
            app.StepWidth.ValueDisplayFormat = '%.1f';
            app.StepWidth.Tag = 'ReferenceChannel+FrequencyRange';
            app.StepWidth.FontSize = 11;
            app.StepWidth.Layout.Row = 7;
            app.StepWidth.Layout.Column = 2;

            % Create BandWidthLabel
            app.BandWidthLabel = uilabel(app.ParametersGrid);
            app.BandWidthLabel.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.BandWidthLabel.VerticalAlignment = 'bottom';
            app.BandWidthLabel.WordWrap = 'on';
            app.BandWidthLabel.FontSize = 11;
            app.BandWidthLabel.Layout.Row = 6;
            app.BandWidthLabel.Layout.Column = [3 4];
            app.BandWidthLabel.Text = {'Largura canal'; '(kHz):'};

            % Create BandWidth
            app.BandWidth = uieditfield(app.ParametersGrid, 'numeric');
            app.BandWidth.Limits = [-1 Inf];
            app.BandWidth.ValueDisplayFormat = '%.1f';
            app.BandWidth.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.BandWidth.FontSize = 11;
            app.BandWidth.Layout.Row = 7;
            app.BandWidth.Layout.Column = [3 4];

            % Create ChannelSample
            app.ChannelSample = uilabel(app.ParametersGrid);
            app.ChannelSample.Tag = 'ReferenceChannel+FrequencyRange+SingleChannel';
            app.ChannelSample.VerticalAlignment = 'top';
            app.ChannelSample.WordWrap = 'on';
            app.ChannelSample.FontSize = 11;
            app.ChannelSample.FontColor = [0.651 0.651 0.651];
            app.ChannelSample.Layout.Row = 8;
            app.ChannelSample.Layout.Column = [1 4];
            app.ChannelSample.Interpreter = 'html';
            app.ChannelSample.Text = '<p style="text-align: justify;">Amostra:<br>101.700 MHz, 101.900 MHz, 102.100 MHz, 102.300 MHz, 102.500 MHz, 102.700 MHz...</font>';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout3);
            app.GridLayout2.ColumnWidth = {'1x', 20};
            app.GridLayout2.RowHeight = {26, 22, 22};
            app.GridLayout2.ColumnSpacing = 5;
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 2;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create ExternalFileSourceLabel
            app.ExternalFileSourceLabel = uilabel(app.GridLayout2);
            app.ExternalFileSourceLabel.Tag = 'ExternalFile';
            app.ExternalFileSourceLabel.VerticalAlignment = 'bottom';
            app.ExternalFileSourceLabel.FontSize = 11;
            app.ExternalFileSourceLabel.Visible = 'off';
            app.ExternalFileSourceLabel.Layout.Row = 1;
            app.ExternalFileSourceLabel.Layout.Column = 1;
            app.ExternalFileSourceLabel.Text = {'Formato do arquivo a ser importado:'; '(origem dos dados)'};

            % Create ExternalFileSource
            app.ExternalFileSource = uidropdown(app.GridLayout2);
            app.ExternalFileSource.Items = {'Genérico (.json)', 'Satélite (.csv)'};
            app.ExternalFileSource.Tag = 'ExternalFile';
            app.ExternalFileSource.Visible = 'off';
            app.ExternalFileSource.FontSize = 11;
            app.ExternalFileSource.BackgroundColor = [1 1 1];
            app.ExternalFileSource.Layout.Row = 2;
            app.ExternalFileSource.Layout.Column = 1;
            app.ExternalFileSource.Value = 'Genérico (.json)';

            % Create ExternalFileTemplateDownload
            app.ExternalFileTemplateDownload = uihyperlink(app.GridLayout2);
            app.ExternalFileTemplateDownload.Tag = 'ExternalFile';
            app.ExternalFileTemplateDownload.VerticalAlignment = 'top';
            app.ExternalFileTemplateDownload.FontSize = 10;
            app.ExternalFileTemplateDownload.Visible = 'off';
            app.ExternalFileTemplateDownload.Layout.Row = 3;
            app.ExternalFileTemplateDownload.Layout.Column = 1;
            app.ExternalFileTemplateDownload.Text = 'Download modelo do arquivo';

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.GridLayout2);
            app.DataHubPOSTButton.ScaleMethod = 'none';
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Enable = 'off';
            app.DataHubPOSTButton.Layout.Row = 2;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'folder-opened-16px.svg';

            % Create GridLayout_2
            app.GridLayout_2 = uigridlayout(app.GridLayout3);
            app.GridLayout_2.ColumnWidth = {'1x', 16, '1x'};
            app.GridLayout_2.RowHeight = {32, 22, 22, '1x'};
            app.GridLayout_2.ColumnSpacing = 5;
            app.GridLayout_2.RowSpacing = 5;
            app.GridLayout_2.Padding = [0 0 0 0];
            app.GridLayout_2.Layout.Row = 3;
            app.GridLayout_2.Layout.Column = 1;
            app.GridLayout_2.BackgroundColor = [1 1 1];

            % Create RefLocationLabel
            app.RefLocationLabel = uilabel(app.GridLayout_2);
            app.RefLocationLabel.VerticalAlignment = 'bottom';
            app.RefLocationLabel.FontSize = 10;
            app.RefLocationLabel.Layout.Row = 1;
            app.RefLocationLabel.Layout.Column = 1;
            app.RefLocationLabel.Interpreter = 'html';
            app.RefLocationLabel.Text = {'CANAIS LIDOS:'; '<font style="color: gray; font-size: 9px;">(relacionadas às estações previstas no PM-RNI)</font>'};

            % Create RefLocation
            app.RefLocation = uilistbox(app.GridLayout_2);
            app.RefLocation.Items = {};
            app.RefLocation.Multiselect = 'on';
            app.RefLocation.FontSize = 11;
            app.RefLocation.Layout.Row = [2 4];
            app.RefLocation.Layout.Column = 1;
            app.RefLocation.Value = {};

            % Create Add
            app.Add = uiimage(app.GridLayout_2);
            app.Add.ScaleMethod = 'none';
            app.Add.Enable = 'off';
            app.Add.Tooltip = {'Adiciona localidades selecionadas'};
            app.Add.Layout.Row = 2;
            app.Add.Layout.Column = 2;
            app.Add.ImageSource = 'Continue_16.png';

            % Create Delete
            app.Delete = uiimage(app.GridLayout_2);
            app.Delete.ScaleMethod = 'none';
            app.Delete.Enable = 'off';
            app.Delete.Tooltip = {'Exclui localidades selecionadas'};
            app.Delete.Layout.Row = 3;
            app.Delete.Layout.Column = 2;
            app.Delete.ImageSource = 'delete-12px-red.svg';

            % Create LocationLabel
            app.LocationLabel = uilabel(app.GridLayout_2);
            app.LocationLabel.VerticalAlignment = 'bottom';
            app.LocationLabel.FontSize = 10;
            app.LocationLabel.Layout.Row = 1;
            app.LocationLabel.Layout.Column = 3;
            app.LocationLabel.Interpreter = 'html';
            app.LocationLabel.Text = {'CANAIS A INCLUIR:'; '<font style="color: gray; font-size: 9px;">(relacionadas às estações previstas no PM-RNI)</font>'};

            % Create Location
            app.Location = uilistbox(app.GridLayout_2);
            app.Location.Items = {};
            app.Location.Multiselect = 'on';
            app.Location.FontSize = 11;
            app.Location.Layout.Row = [2 4];
            app.Location.Layout.Column = 3;
            app.Location.Value = {};

            % Create SatelliteIDGrid
            app.SatelliteIDGrid = uigridlayout(app.GridLayout3);
            app.SatelliteIDGrid.ColumnWidth = {110, '1x', 150};
            app.SatelliteIDGrid.RowHeight = {34, 22, 34, '1x'};
            app.SatelliteIDGrid.RowSpacing = 5;
            app.SatelliteIDGrid.Padding = [0 0 0 0];
            app.SatelliteIDGrid.Layout.Row = 4;
            app.SatelliteIDGrid.Layout.Column = 1;
            app.SatelliteIDGrid.BackgroundColor = [1 1 1];

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
            app.FeixeDownList.FontSize = 11;
            app.FeixeDownList.Layout.Row = 4;
            app.FeixeDownList.Layout.Column = [2 3];
            app.FeixeDownList.Value = {};

            % Create AddChannelButton
            app.AddChannelButton = uibutton(app.GridLayout, 'push');
            app.AddChannelButton.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.AddChannelButton.Icon = 'Add_16.png';
            app.AddChannelButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.AddChannelButton.Layout.Row = 4;
            app.AddChannelButton.Layout.Column = 2;
            app.AddChannelButton.Text = 'Incluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockChannels_exported(Container, varargin)

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
