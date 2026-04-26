classdef dockOccupancy_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        AddChannelButton              matlab.ui.control.Button
        ParametersPanel               matlab.ui.container.Panel
        ParametersGrid                matlab.ui.container.GridLayout
        ExternalFileTemplateDownload  matlab.ui.control.Hyperlink
        ExternalFileSource            matlab.ui.control.DropDown
        ExternalFileSourceLabel       matlab.ui.control.Label
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
                app.UIFigure.Position = [100 100 412 516];
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
            app.GridLayout.ColumnWidth = {252, 110};
            app.GridLayout.RowHeight = {17, 166, 256, 22};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create RadioButtonPanelLabel
            app.RadioButtonPanelLabel = uilabel(app.GridLayout);
            app.RadioButtonPanelLabel.VerticalAlignment = 'bottom';
            app.RadioButtonPanelLabel.FontSize = 10;
            app.RadioButtonPanelLabel.Layout.Row = 1;
            app.RadioButtonPanelLabel.Layout.Column = 1;
            app.RadioButtonPanelLabel.Text = 'MODO DE INCLUSÃO';

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
            app.FrequencyRange.Text = {'Faixa de frequência'; '<font style="font-size: 10px; color: gray;">Inclui canais definidos pela faixa de frequência, largura do canal e espaçamento entre canais.</font>'};
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
            app.FileImport.Text = {'Arquivo'; '<font style="font-size: 10px; color: gray;">Inclui canais definidos em um arquivo externo.</font>'};
            app.FileImport.FontSize = 11;
            app.FileImport.Interpreter = 'html';
            app.FileImport.Position = [11 5 348 38];

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.GridLayout);
            app.ParametersPanel.AutoResizeChildren = 'off';
            app.ParametersPanel.Layout.Row = 3;
            app.ParametersPanel.Layout.Column = [1 2];

            % Create ParametersGrid
            app.ParametersGrid = uigridlayout(app.ParametersPanel);
            app.ParametersGrid.ColumnWidth = {110, 110, 84, 16};
            app.ParametersGrid.RowHeight = {26, 22, 0, 32, 22, 32, 22, '1x', 0, 0, 0};
            app.ParametersGrid.RowSpacing = 5;
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

            % Create ExternalFileSourceLabel
            app.ExternalFileSourceLabel = uilabel(app.ParametersGrid);
            app.ExternalFileSourceLabel.Tag = 'ExternalFile';
            app.ExternalFileSourceLabel.VerticalAlignment = 'bottom';
            app.ExternalFileSourceLabel.FontSize = 11;
            app.ExternalFileSourceLabel.Visible = 'off';
            app.ExternalFileSourceLabel.Layout.Row = 9;
            app.ExternalFileSourceLabel.Layout.Column = [1 4];
            app.ExternalFileSourceLabel.Text = {'Formato do arquivo a ser importado:'; '(origem dos dados)'};

            % Create ExternalFileSource
            app.ExternalFileSource = uidropdown(app.ParametersGrid);
            app.ExternalFileSource.Items = {'Genérico (.json)', 'Satélite (.csv)'};
            app.ExternalFileSource.Tag = 'ExternalFile';
            app.ExternalFileSource.Visible = 'off';
            app.ExternalFileSource.FontSize = 11;
            app.ExternalFileSource.BackgroundColor = [1 1 1];
            app.ExternalFileSource.Layout.Row = 10;
            app.ExternalFileSource.Layout.Column = [1 4];
            app.ExternalFileSource.Value = 'Genérico (.json)';

            % Create ExternalFileTemplateDownload
            app.ExternalFileTemplateDownload = uihyperlink(app.ParametersGrid);
            app.ExternalFileTemplateDownload.Tag = 'ExternalFile';
            app.ExternalFileTemplateDownload.VerticalAlignment = 'top';
            app.ExternalFileTemplateDownload.FontSize = 10;
            app.ExternalFileTemplateDownload.Visible = 'off';
            app.ExternalFileTemplateDownload.Layout.Row = 11;
            app.ExternalFileTemplateDownload.Layout.Column = [1 4];
            app.ExternalFileTemplateDownload.Text = 'Download modelo do arquivo';

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
        function app = dockOccupancy_exported(Container, varargin)

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
