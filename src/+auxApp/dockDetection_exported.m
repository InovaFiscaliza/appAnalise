classdef dockDetection_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        SearchButton                    matlab.ui.control.Button
        AlgorithmPanel                  matlab.ui.container.Panel
        AlgorithmGrid                   matlab.ui.container.GridLayout
        ConnectedRegionsMinOrientation  matlab.ui.control.Spinner
        ConnectedRegionsMinOrientationLabel  matlab.ui.control.Label
        ConnectedRegionsMinOccupancy    matlab.ui.control.Spinner
        ConnectedRegionsMinOccupancyLabel  matlab.ui.control.Label
        ConnectedRegionsMaxOccupancy    matlab.ui.control.Spinner
        ConnectedRegionsMaxOccupancyLabel  matlab.ui.control.Label
        ConnectedRegionsArea            matlab.ui.control.Spinner
        ConnectedRegionsAreaLabel       matlab.ui.control.Label
        ConnectedRegionsOffset          matlab.ui.control.Spinner
        ConnectedRegionsOffsetLabel     matlab.ui.control.Label
        FindPeaksPlusOCCPanel2          matlab.ui.container.Panel
        FindPeaksPlusOCCGrid2           matlab.ui.container.GridLayout
        FindPeaksPlusOCCMaxOccupancy    matlab.ui.control.Spinner
        FindPeaksPlusOCCMinOccupancy    matlab.ui.control.Spinner
        FindPeaksPlusOCCOccupancyLabel  matlab.ui.control.Label
        FindPeaksPlusOCCProminence2     matlab.ui.control.Spinner
        FindPeaksPlusOCCProminence2Label  matlab.ui.control.Label
        FindPeaksPlusOCCPanel1          matlab.ui.container.Panel
        FindPeaksPlusOCCGrid1           matlab.ui.container.GridLayout
        FindPeaksPlusOCCProminence1     matlab.ui.control.Spinner
        FindPeaksPlusOCCProminence1Label  matlab.ui.control.Label
        FindPeaksPlusOCCBandWidth       matlab.ui.control.Spinner
        FindPeaksPlusOCCBandWidthLabel  matlab.ui.control.Label
        FindPeaksPlusOCCDistance        matlab.ui.control.Spinner
        FindPeaksPlusOCCDistanceLabel   matlab.ui.control.Label
        FindPeaksPlusOCCClass           matlab.ui.control.DropDown
        FindPeaksPlusOCCClassLabel      matlab.ui.control.Label
        FindPeaksThreshold              matlab.ui.control.Spinner
        FindPeaksThresholdLabel         matlab.ui.control.Label
        FindPeaksNumPeaks               matlab.ui.control.Spinner
        FindPeaksNumPeaksLabel          matlab.ui.control.Label
        FindPeaksProminence             matlab.ui.control.Spinner
        FindPeaksProminenceLabel        matlab.ui.control.Label
        FindPeaksBandWidth              matlab.ui.control.Spinner
        FindPeaksBandWidthLabel         matlab.ui.control.Label
        FindPeaksDistance               matlab.ui.control.Spinner
        FindPeaksDistanceLabel          matlab.ui.control.Label
        FindPeaksTrace                  matlab.ui.control.DropDown
        FindPeaksTraceLabel             matlab.ui.control.Label
        Algorithm                       matlab.ui.control.DropDown
        AlgorithmLabel                  matlab.ui.control.Label
        SearchModePanel                 matlab.ui.container.ButtonGroup
        OnlySearchEmissions             matlab.ui.control.RadioButton
        ReplaceEmissions                matlab.ui.control.RadioButton
        AddEmissions                    matlab.ui.control.RadioButton
        SearchModeLabel                 matlab.ui.control.Label
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
        function initialValues(app)
            channelObj = app.mainApp.channelObj;
            app.FindPeaksPlusOCCClass.Items = [{''}; channelObj.FindPeaks.EmissionClass];
        end

        %-----------------------------------------------------------------%
        function updatePanel(app)
            elHandles = app.AlgorithmGrid.Children;

            switch app.Algorithm.Value
                case 'Detecção por picos'
                    relatedElHandles = findobj(elHandles, 'Tag', 'FindPeaks');
                    app.AlgorithmGrid.RowHeight = {26, 22, 32, 22, 0, 0, 0, 0, 0, 0, 0};

                case 'Picos com ocupação'
                    relatedElHandles = findobj(elHandles, 'Tag', 'FindPeaksPlusOCC');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, 0, 26, 22, '1x', 0, 0, 0, 0};

                otherwise % 'Regiões conectadas'
                    relatedElHandles = findobj(elHandles, 'Tag', 'ConnectedRegions');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, 0, 0, 0, 0, 26, 22, 32, 22};
            end

            set(relatedElHandles, 'Visible', true)
            set(setdiff(elHandles, relatedElHandles), 'Visible', false)
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
                updatePanel(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Value changed function: Algorithm
        function onAlgorithmValueChanged(app, event)
            
            updatePanel(app)

        end

        % Value changed function: FindPeaksPlusOCCClass
        function onEmissionClassValueChanged(app, event)
            
            if ~isempty(app.FindPeaksPlusOCCClass.Value)
                channelObj = app.mainApp.channelObj;
                [~, findPeaksIdx] = ismember(app.FindPeaksPlusOCCClass.Value, channelObj.FindPeaks.EmissionClass);

                if findPeaksIdx
                    app.FindPeaksPlusOCCDistance.Value     = 1000 * channelObj.FindPeaks.MinDistanceMHz(findPeaksIdx);
                    app.FindPeaksPlusOCCBandWidth.Value    = 1000 * channelObj.FindPeaks.MinWidthMHz(findPeaksIdx);
                    app.FindPeaksPlusOCCProminence1.Value  = channelObj.FindPeaks.MinProminenceCenter(findPeaksIdx);
                    app.FindPeaksPlusOCCProminence2.Value  = channelObj.FindPeaks.MinProminenceMax(findPeaksIdx);
                    app.FindPeaksPlusOCCMinOccupancy.Value = channelObj.FindPeaks.MinOccupancyMeanOverTime(findPeaksIdx);
                    app.FindPeaksPlusOCCMaxOccupancy.Value = channelObj.FindPeaks.MinOccupancyMaxOverTime(findPeaksIdx);
                end
            end

        end

        % Value changed function: FindPeaksPlusOCCMaxOccupancy, 
        % ...and 1 other component
        function onOccupancyValueChanged(app, event)
            
            switch event.Source
                case app.FindPeaksPlusOCCMinOccupancy
                    if app.FindPeaksPlusOCCMinOccupancy.Value > app.FindPeaksPlusOCCMaxOccupancy.Value
                        app.FindPeaksPlusOCCMaxOccupancy.Value = app.FindPeaksPlusOCCMinOccupancy.Value;
                    end

                case app.FindPeaksPlusOCCMaxOccupancy
                    if app.FindPeaksPlusOCCMaxOccupancy.Value < app.FindPeaksPlusOCCMinOccupancy.Value
                        app.FindPeaksPlusOCCMinOccupancy.Value = app.FindPeaksPlusOCCMaxOccupancy.Value;
                    end
            end

        end

        % Button pushed function: SearchButton
        function onSearchButtonClicked(app, event)

            context = app.inputArgs.context;
            algorithm = app.Algorithm.Value;
            specData = app.callingApp.bandObj.SpecData;

            for ii = 1:numel(specData)
                switch algorithm
                    case 'Regiões conectadas'
                        detectionConfig = struct( ...
                            'Algorithm', 'FindConnectedRegions', ...
                            'Offset', app.ConnectedRegionsOffset.Value, ...
                            'CumulativeAreaThreshold', app.ConnectedRegionsArea.Value, ...
                            'MaxOccupancyForRegions', app.ConnectedRegionsMaxOccupancy.Value, ...
                            'MinOccupancy', app.ConnectedRegionsMinOccupancy.Value, ...
                            'MinAbsOrientation', app.ConnectedRegionsMinOrientation.Value ...
                        );
                    
                    case 'Detecção por picos'
                        detectionConfig = struct( ...
                            'Algorithm', 'FindPeaks', ...
                            'MinDistanceKHz', app.FindPeaksDistance.Value, ...
                            'MinWidthKHz', app.FindPeaksBandWidth.Value, ...
                            'TraceMode', app.FindPeaksTrace.Value, ...
                            'MinProminence', app.FindPeaksProminence.Value, ...
                            'NumPeaks', app.FindPeaksNumPeaks.Value, ...
                            'Threshold', app.FindPeaksThreshold.Value ...
                        );
                    
                    case 'Picos com ocupação'
                        detectionConfig = struct( ...
                            'Algorithm', 'FindPeaks+OCC', ...
                            'MinDistanceKHz', app.FindPeaksPlusOCCDistance.Value, ...
                            'MinWidthKHz', app.FindPeaksPlusOCCBandWidth.Value, ...
                            'MinProminenceCenter', app.FindPeaksPlusOCCProminence1.Value, ...
                            'MinProminenceMax', app.FindPeaksPlusOCCProminence2.Value, ...
                            'MinOccupancyMeanOverTime', app.FindPeaksPlusOCCMinOccupancy.Value, ...
                            'MinOccupancyMaxOverTime', app.FindPeaksPlusOCCMaxOccupancy.Value ...
                        );

                    otherwise
                        error('auxApp:dockDetection:UnexpectedAlgorithm', 'Unexpected algorithm "%s"', algorithm)
                end
                        
                [idxList, freqList, widthkHzList, methodList] = util.Detection.run(specData, detectionConfig);

                if isempty(idxList)
                    ui.Dialog(app.UIFigure, 'info', 'Não foi encontrada emissão que atenda aos critérios especificados.');
                    return
                end

                switch app.SearchModePanel.SelectedObject
                    case app.AddEmissions
                        update(specData, 'UserData:Emissions', 'Add', idxList, freqList, widthkHzList, methodList, [], app.mainApp.channelObj)
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onEmissionAdded', context)
                    
                    case app.ReplaceEmissions
                        update(specData, 'UserData:Emissions', 'Replace', idxList, freqList, widthkHzList, methodList, [], app.mainApp.channelObj)
                        ipcMainMatlabCallsHandler(app.mainApp, app, 'onEmissionAdded', context)

                    otherwise % app.OnlySearchEmissions
                        util.Detection.drawEmission('Creation', app.callingApp.UIAxes1, app.callingApp.restoreView, freqList, widthkHzList)
                end
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
                app.UIFigure.Position = [100 100 412 484];
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
            app.GridLayout.RowHeight = {17, 166, 22, 22, 168, 24};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create SearchModeLabel
            app.SearchModeLabel = uilabel(app.GridLayout);
            app.SearchModeLabel.VerticalAlignment = 'bottom';
            app.SearchModeLabel.FontSize = 10;
            app.SearchModeLabel.Layout.Row = 1;
            app.SearchModeLabel.Layout.Column = 1;
            app.SearchModeLabel.Text = 'MODO DE PESQUISA';

            % Create SearchModePanel
            app.SearchModePanel = uibuttongroup(app.GridLayout);
            app.SearchModePanel.AutoResizeChildren = 'off';
            app.SearchModePanel.BackgroundColor = [1 1 1];
            app.SearchModePanel.Layout.Row = 2;
            app.SearchModePanel.Layout.Column = [1 2];

            % Create AddEmissions
            app.AddEmissions = uiradiobutton(app.SearchModePanel);
            app.AddEmissions.Text = {'Adicionar novas emissões (sem duplicar)'; '<font style="font-size: 10px; color: gray;">Realiza a busca e adiciona apenas emissões que não se sobrepõem com as já relacionadas ao fluxo.</font>'};
            app.AddEmissions.WordWrap = 'on';
            app.AddEmissions.FontSize = 11;
            app.AddEmissions.Interpreter = 'html';
            app.AddEmissions.Position = [11 108 352 51];
            app.AddEmissions.Value = true;

            % Create ReplaceEmissions
            app.ReplaceEmissions = uiradiobutton(app.SearchModePanel);
            app.ReplaceEmissions.Text = {'Substituir emissões existentes'; '<font style="font-size: 10px; color: gray;">Realiza a busca e substitui todas as emissões já relacionadas ao fluxo espectral.</font>'};
            app.ReplaceEmissions.WordWrap = 'on';
            app.ReplaceEmissions.FontSize = 11;
            app.ReplaceEmissions.Interpreter = 'html';
            app.ReplaceEmissions.Position = [11 58 348 45];

            % Create OnlySearchEmissions
            app.OnlySearchEmissions = uiradiobutton(app.SearchModePanel);
            app.OnlySearchEmissions.Text = {'Apenas consulta'; '<font style="font-size: 10px; color: gray;">Apenas realiza a busca, sem alterar os dados. As emissões encontradas são destacadas em vermelho no plot.</font>'};
            app.OnlySearchEmissions.WordWrap = 'on';
            app.OnlySearchEmissions.FontSize = 11;
            app.OnlySearchEmissions.Interpreter = 'html';
            app.OnlySearchEmissions.Position = [11 8 348 45];

            % Create AlgorithmLabel
            app.AlgorithmLabel = uilabel(app.GridLayout);
            app.AlgorithmLabel.VerticalAlignment = 'bottom';
            app.AlgorithmLabel.FontSize = 10;
            app.AlgorithmLabel.Layout.Row = 3;
            app.AlgorithmLabel.Layout.Column = 1;
            app.AlgorithmLabel.Text = 'TIPO DE DETECÇÃO DE EMISSÕES';

            % Create Algorithm
            app.Algorithm = uidropdown(app.GridLayout);
            app.Algorithm.Items = {'Detecção por picos', 'Picos com ocupação', 'Regiões conectadas'};
            app.Algorithm.ValueChangedFcn = createCallbackFcn(app, @onAlgorithmValueChanged, true);
            app.Algorithm.FontSize = 11;
            app.Algorithm.BackgroundColor = [1 1 1];
            app.Algorithm.Layout.Row = 4;
            app.Algorithm.Layout.Column = [1 2];
            app.Algorithm.Value = 'Detecção por picos';

            % Create AlgorithmPanel
            app.AlgorithmPanel = uipanel(app.GridLayout);
            app.AlgorithmPanel.AutoResizeChildren = 'off';
            app.AlgorithmPanel.Layout.Row = 5;
            app.AlgorithmPanel.Layout.Column = [1 2];

            % Create AlgorithmGrid
            app.AlgorithmGrid = uigridlayout(app.AlgorithmPanel);
            app.AlgorithmGrid.ColumnWidth = {110, 110, 110};
            app.AlgorithmGrid.RowHeight = {26, 22, 32, 22, 0, 0, 0, 0, 0, 0, 0};
            app.AlgorithmGrid.RowSpacing = 5;
            app.AlgorithmGrid.BackgroundColor = [1 1 1];

            % Create FindPeaksTraceLabel
            app.FindPeaksTraceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksTraceLabel.Tag = 'FindPeaks';
            app.FindPeaksTraceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksTraceLabel.FontSize = 11;
            app.FindPeaksTraceLabel.Layout.Row = 1;
            app.FindPeaksTraceLabel.Layout.Column = 1;
            app.FindPeaksTraceLabel.Text = {'Tipo de traço:'; '(agregação dados)'};

            % Create FindPeaksTrace
            app.FindPeaksTrace = uidropdown(app.AlgorithmGrid);
            app.FindPeaksTrace.Items = {'MinHold', 'Mean', 'MaxHold'};
            app.FindPeaksTrace.Tag = 'FindPeaks';
            app.FindPeaksTrace.FontSize = 11;
            app.FindPeaksTrace.BackgroundColor = [1 1 1];
            app.FindPeaksTrace.Layout.Row = 2;
            app.FindPeaksTrace.Layout.Column = 1;
            app.FindPeaksTrace.Value = 'Mean';

            % Create FindPeaksDistanceLabel
            app.FindPeaksDistanceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksDistanceLabel.Tag = 'FindPeaks';
            app.FindPeaksDistanceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksDistanceLabel.WordWrap = 'on';
            app.FindPeaksDistanceLabel.FontSize = 11;
            app.FindPeaksDistanceLabel.Layout.Row = 1;
            app.FindPeaksDistanceLabel.Layout.Column = 2;
            app.FindPeaksDistanceLabel.Text = 'Distância entre picos (kHz):';

            % Create FindPeaksDistance
            app.FindPeaksDistance = uispinner(app.AlgorithmGrid);
            app.FindPeaksDistance.Step = 25;
            app.FindPeaksDistance.Limits = [0 Inf];
            app.FindPeaksDistance.RoundFractionalValues = 'on';
            app.FindPeaksDistance.ValueDisplayFormat = '%.0f';
            app.FindPeaksDistance.Tag = 'FindPeaks';
            app.FindPeaksDistance.FontSize = 11;
            app.FindPeaksDistance.Layout.Row = 2;
            app.FindPeaksDistance.Layout.Column = 2;
            app.FindPeaksDistance.Value = 25;

            % Create FindPeaksBandWidthLabel
            app.FindPeaksBandWidthLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksBandWidthLabel.Tag = 'FindPeaks';
            app.FindPeaksBandWidthLabel.VerticalAlignment = 'bottom';
            app.FindPeaksBandWidthLabel.WordWrap = 'on';
            app.FindPeaksBandWidthLabel.FontSize = 11;
            app.FindPeaksBandWidthLabel.Layout.Row = 1;
            app.FindPeaksBandWidthLabel.Layout.Column = 3;
            app.FindPeaksBandWidthLabel.Text = {'Largura ocupada'; '(kHz):'};

            % Create FindPeaksBandWidth
            app.FindPeaksBandWidth = uispinner(app.AlgorithmGrid);
            app.FindPeaksBandWidth.Step = 10;
            app.FindPeaksBandWidth.Limits = [0 Inf];
            app.FindPeaksBandWidth.RoundFractionalValues = 'on';
            app.FindPeaksBandWidth.ValueDisplayFormat = '%.0f';
            app.FindPeaksBandWidth.Tag = 'FindPeaks';
            app.FindPeaksBandWidth.FontSize = 11;
            app.FindPeaksBandWidth.Layout.Row = 2;
            app.FindPeaksBandWidth.Layout.Column = 3;
            app.FindPeaksBandWidth.Value = 10;

            % Create FindPeaksProminenceLabel
            app.FindPeaksProminenceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksProminenceLabel.Tag = 'FindPeaks';
            app.FindPeaksProminenceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksProminenceLabel.WordWrap = 'on';
            app.FindPeaksProminenceLabel.FontSize = 11;
            app.FindPeaksProminenceLabel.Layout.Row = 3;
            app.FindPeaksProminenceLabel.Layout.Column = 1;
            app.FindPeaksProminenceLabel.Text = {'Proeminência'; '(dB):'};

            % Create FindPeaksProminence
            app.FindPeaksProminence = uispinner(app.AlgorithmGrid);
            app.FindPeaksProminence.Step = 3;
            app.FindPeaksProminence.Limits = [1 Inf];
            app.FindPeaksProminence.RoundFractionalValues = 'on';
            app.FindPeaksProminence.ValueDisplayFormat = '%.0f';
            app.FindPeaksProminence.Tag = 'FindPeaks';
            app.FindPeaksProminence.FontSize = 11;
            app.FindPeaksProminence.Layout.Row = 4;
            app.FindPeaksProminence.Layout.Column = 1;
            app.FindPeaksProminence.Value = 12;

            % Create FindPeaksNumPeaksLabel
            app.FindPeaksNumPeaksLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksNumPeaksLabel.Tag = 'FindPeaks';
            app.FindPeaksNumPeaksLabel.VerticalAlignment = 'bottom';
            app.FindPeaksNumPeaksLabel.WordWrap = 'on';
            app.FindPeaksNumPeaksLabel.FontSize = 11;
            app.FindPeaksNumPeaksLabel.Layout.Row = 3;
            app.FindPeaksNumPeaksLabel.Layout.Column = 2;
            app.FindPeaksNumPeaksLabel.Text = {'Número máximo '; 'de picos:'};

            % Create FindPeaksNumPeaks
            app.FindPeaksNumPeaks = uispinner(app.AlgorithmGrid);
            app.FindPeaksNumPeaks.Step = 5;
            app.FindPeaksNumPeaks.Limits = [1 100];
            app.FindPeaksNumPeaks.RoundFractionalValues = 'on';
            app.FindPeaksNumPeaks.ValueDisplayFormat = '%.0f';
            app.FindPeaksNumPeaks.Tag = 'FindPeaks';
            app.FindPeaksNumPeaks.FontSize = 11;
            app.FindPeaksNumPeaks.Layout.Row = 4;
            app.FindPeaksNumPeaks.Layout.Column = 2;
            app.FindPeaksNumPeaks.Value = 50;

            % Create FindPeaksThresholdLabel
            app.FindPeaksThresholdLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksThresholdLabel.Tag = 'FindPeaks';
            app.FindPeaksThresholdLabel.VerticalAlignment = 'bottom';
            app.FindPeaksThresholdLabel.FontSize = 11;
            app.FindPeaksThresholdLabel.Layout.Row = 3;
            app.FindPeaksThresholdLabel.Layout.Column = 3;
            app.FindPeaksThresholdLabel.Text = {'Threshold'; '(dB):'};

            % Create FindPeaksThreshold
            app.FindPeaksThreshold = uispinner(app.AlgorithmGrid);
            app.FindPeaksThreshold.Step = 10;
            app.FindPeaksThreshold.RoundFractionalValues = 'on';
            app.FindPeaksThreshold.ValueDisplayFormat = '%.0f';
            app.FindPeaksThreshold.Tag = 'FindPeaks';
            app.FindPeaksThreshold.FontSize = 11;
            app.FindPeaksThreshold.Layout.Row = 4;
            app.FindPeaksThreshold.Layout.Column = 3;
            app.FindPeaksThreshold.Value = -Inf;

            % Create FindPeaksPlusOCCClassLabel
            app.FindPeaksPlusOCCClassLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCClassLabel.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCClassLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCClassLabel.FontSize = 11;
            app.FindPeaksPlusOCCClassLabel.Visible = 'off';
            app.FindPeaksPlusOCCClassLabel.Layout.Row = 5;
            app.FindPeaksPlusOCCClassLabel.Layout.Column = 1;
            app.FindPeaksPlusOCCClassLabel.Text = {'Classe de emissão:'; '(tecnologia)'};

            % Create FindPeaksPlusOCCClass
            app.FindPeaksPlusOCCClass = uidropdown(app.AlgorithmGrid);
            app.FindPeaksPlusOCCClass.Items = {};
            app.FindPeaksPlusOCCClass.ValueChangedFcn = createCallbackFcn(app, @onEmissionClassValueChanged, true);
            app.FindPeaksPlusOCCClass.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCClass.Visible = 'off';
            app.FindPeaksPlusOCCClass.FontSize = 11;
            app.FindPeaksPlusOCCClass.BackgroundColor = [1 1 1];
            app.FindPeaksPlusOCCClass.Layout.Row = 6;
            app.FindPeaksPlusOCCClass.Layout.Column = 1;
            app.FindPeaksPlusOCCClass.Value = {};

            % Create FindPeaksPlusOCCDistanceLabel
            app.FindPeaksPlusOCCDistanceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCDistanceLabel.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCDistanceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCDistanceLabel.WordWrap = 'on';
            app.FindPeaksPlusOCCDistanceLabel.FontSize = 11;
            app.FindPeaksPlusOCCDistanceLabel.Visible = 'off';
            app.FindPeaksPlusOCCDistanceLabel.Layout.Row = 5;
            app.FindPeaksPlusOCCDistanceLabel.Layout.Column = 2;
            app.FindPeaksPlusOCCDistanceLabel.Text = 'Distância entre picos (kHz):';

            % Create FindPeaksPlusOCCDistance
            app.FindPeaksPlusOCCDistance = uispinner(app.AlgorithmGrid);
            app.FindPeaksPlusOCCDistance.Step = 25;
            app.FindPeaksPlusOCCDistance.Limits = [0 Inf];
            app.FindPeaksPlusOCCDistance.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCDistance.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCDistance.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCDistance.FontSize = 11;
            app.FindPeaksPlusOCCDistance.Visible = 'off';
            app.FindPeaksPlusOCCDistance.Layout.Row = 6;
            app.FindPeaksPlusOCCDistance.Layout.Column = 2;
            app.FindPeaksPlusOCCDistance.Value = 25;

            % Create FindPeaksPlusOCCBandWidthLabel
            app.FindPeaksPlusOCCBandWidthLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCBandWidthLabel.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCBandWidthLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCBandWidthLabel.WordWrap = 'on';
            app.FindPeaksPlusOCCBandWidthLabel.FontSize = 11;
            app.FindPeaksPlusOCCBandWidthLabel.Visible = 'off';
            app.FindPeaksPlusOCCBandWidthLabel.Layout.Row = 5;
            app.FindPeaksPlusOCCBandWidthLabel.Layout.Column = 3;
            app.FindPeaksPlusOCCBandWidthLabel.Text = {'Largura ocupada'; '(kHz):'};

            % Create FindPeaksPlusOCCBandWidth
            app.FindPeaksPlusOCCBandWidth = uispinner(app.AlgorithmGrid);
            app.FindPeaksPlusOCCBandWidth.Step = 10;
            app.FindPeaksPlusOCCBandWidth.Limits = [0 Inf];
            app.FindPeaksPlusOCCBandWidth.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCBandWidth.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCBandWidth.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCBandWidth.FontSize = 11;
            app.FindPeaksPlusOCCBandWidth.Visible = 'off';
            app.FindPeaksPlusOCCBandWidth.Layout.Row = 6;
            app.FindPeaksPlusOCCBandWidth.Layout.Column = 3;
            app.FindPeaksPlusOCCBandWidth.Value = 10;

            % Create FindPeaksPlusOCCPanel1
            app.FindPeaksPlusOCCPanel1 = uipanel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCPanel1.AutoResizeChildren = 'off';
            app.FindPeaksPlusOCCPanel1.Title = 'MÉDIA';
            app.FindPeaksPlusOCCPanel1.Visible = 'off';
            app.FindPeaksPlusOCCPanel1.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCPanel1.Layout.Row = 7;
            app.FindPeaksPlusOCCPanel1.Layout.Column = 1;
            app.FindPeaksPlusOCCPanel1.FontSize = 10;

            % Create FindPeaksPlusOCCGrid1
            app.FindPeaksPlusOCCGrid1 = uigridlayout(app.FindPeaksPlusOCCPanel1);
            app.FindPeaksPlusOCCGrid1.ColumnWidth = {'1x'};
            app.FindPeaksPlusOCCGrid1.RowHeight = {27, 22};
            app.FindPeaksPlusOCCGrid1.RowSpacing = 5;
            app.FindPeaksPlusOCCGrid1.Padding = [10 10 10 5];
            app.FindPeaksPlusOCCGrid1.BackgroundColor = [1 1 1];

            % Create FindPeaksPlusOCCProminence1Label
            app.FindPeaksPlusOCCProminence1Label = uilabel(app.FindPeaksPlusOCCGrid1);
            app.FindPeaksPlusOCCProminence1Label.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCProminence1Label.WordWrap = 'on';
            app.FindPeaksPlusOCCProminence1Label.FontSize = 11;
            app.FindPeaksPlusOCCProminence1Label.Layout.Row = 1;
            app.FindPeaksPlusOCCProminence1Label.Layout.Column = 1;
            app.FindPeaksPlusOCCProminence1Label.Text = {'Proeminência'; '(dB):'};

            % Create FindPeaksPlusOCCProminence1
            app.FindPeaksPlusOCCProminence1 = uispinner(app.FindPeaksPlusOCCGrid1);
            app.FindPeaksPlusOCCProminence1.Step = 3;
            app.FindPeaksPlusOCCProminence1.Limits = [1 Inf];
            app.FindPeaksPlusOCCProminence1.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCProminence1.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCProminence1.FontSize = 11;
            app.FindPeaksPlusOCCProminence1.Layout.Row = 2;
            app.FindPeaksPlusOCCProminence1.Layout.Column = 1;
            app.FindPeaksPlusOCCProminence1.Value = 12;

            % Create FindPeaksPlusOCCPanel2
            app.FindPeaksPlusOCCPanel2 = uipanel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCPanel2.AutoResizeChildren = 'off';
            app.FindPeaksPlusOCCPanel2.Title = 'MAXHOLD';
            app.FindPeaksPlusOCCPanel2.Visible = 'off';
            app.FindPeaksPlusOCCPanel2.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCPanel2.Layout.Row = 7;
            app.FindPeaksPlusOCCPanel2.Layout.Column = [2 3];
            app.FindPeaksPlusOCCPanel2.FontSize = 10;

            % Create FindPeaksPlusOCCGrid2
            app.FindPeaksPlusOCCGrid2 = uigridlayout(app.FindPeaksPlusOCCPanel2);
            app.FindPeaksPlusOCCGrid2.ColumnWidth = {60, 10, 68, 5, 67};
            app.FindPeaksPlusOCCGrid2.RowHeight = {27, 22};
            app.FindPeaksPlusOCCGrid2.ColumnSpacing = 0;
            app.FindPeaksPlusOCCGrid2.RowSpacing = 5;
            app.FindPeaksPlusOCCGrid2.Padding = [10 10 8 5];
            app.FindPeaksPlusOCCGrid2.BackgroundColor = [1 1 1];

            % Create FindPeaksPlusOCCProminence2Label
            app.FindPeaksPlusOCCProminence2Label = uilabel(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCProminence2Label.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCProminence2Label.FontSize = 11;
            app.FindPeaksPlusOCCProminence2Label.Layout.Row = 1;
            app.FindPeaksPlusOCCProminence2Label.Layout.Column = [1 5];
            app.FindPeaksPlusOCCProminence2Label.Text = {'Proeminência'; '(dB):'};

            % Create FindPeaksPlusOCCProminence2
            app.FindPeaksPlusOCCProminence2 = uispinner(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCProminence2.Step = 3;
            app.FindPeaksPlusOCCProminence2.Limits = [1 Inf];
            app.FindPeaksPlusOCCProminence2.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCProminence2.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCProminence2.FontSize = 11;
            app.FindPeaksPlusOCCProminence2.Layout.Row = 2;
            app.FindPeaksPlusOCCProminence2.Layout.Column = 1;
            app.FindPeaksPlusOCCProminence2.Value = 30;

            % Create FindPeaksPlusOCCOccupancyLabel
            app.FindPeaksPlusOCCOccupancyLabel = uilabel(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCOccupancyLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCOccupancyLabel.FontSize = 11;
            app.FindPeaksPlusOCCOccupancyLabel.Layout.Row = 1;
            app.FindPeaksPlusOCCOccupancyLabel.Layout.Column = [3 5];
            app.FindPeaksPlusOCCOccupancyLabel.Text = {'Ocupação (%):'; '(Mínima | Máxima)'};

            % Create FindPeaksPlusOCCMinOccupancy
            app.FindPeaksPlusOCCMinOccupancy = uispinner(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCMinOccupancy.Step = 10;
            app.FindPeaksPlusOCCMinOccupancy.Limits = [0 100];
            app.FindPeaksPlusOCCMinOccupancy.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCMinOccupancy.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCMinOccupancy.ValueChangedFcn = createCallbackFcn(app, @onOccupancyValueChanged, true);
            app.FindPeaksPlusOCCMinOccupancy.FontSize = 11;
            app.FindPeaksPlusOCCMinOccupancy.Layout.Row = 2;
            app.FindPeaksPlusOCCMinOccupancy.Layout.Column = 3;
            app.FindPeaksPlusOCCMinOccupancy.Value = 1;

            % Create FindPeaksPlusOCCMaxOccupancy
            app.FindPeaksPlusOCCMaxOccupancy = uispinner(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCMaxOccupancy.Step = 10;
            app.FindPeaksPlusOCCMaxOccupancy.Limits = [0 100];
            app.FindPeaksPlusOCCMaxOccupancy.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCMaxOccupancy.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCMaxOccupancy.ValueChangedFcn = createCallbackFcn(app, @onOccupancyValueChanged, true);
            app.FindPeaksPlusOCCMaxOccupancy.FontSize = 11;
            app.FindPeaksPlusOCCMaxOccupancy.Layout.Row = 2;
            app.FindPeaksPlusOCCMaxOccupancy.Layout.Column = 5;
            app.FindPeaksPlusOCCMaxOccupancy.Value = 10;

            % Create ConnectedRegionsOffsetLabel
            app.ConnectedRegionsOffsetLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsOffsetLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsOffsetLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsOffsetLabel.WordWrap = 'on';
            app.ConnectedRegionsOffsetLabel.FontSize = 11;
            app.ConnectedRegionsOffsetLabel.Visible = 'off';
            app.ConnectedRegionsOffsetLabel.Layout.Row = 8;
            app.ConnectedRegionsOffsetLabel.Layout.Column = 1;
            app.ConnectedRegionsOffsetLabel.Text = {'Proeminência'; '(dB):'};

            % Create ConnectedRegionsOffset
            app.ConnectedRegionsOffset = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsOffset.Step = 3;
            app.ConnectedRegionsOffset.Limits = [3 30];
            app.ConnectedRegionsOffset.RoundFractionalValues = 'on';
            app.ConnectedRegionsOffset.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsOffset.Tag = 'ConnectedRegions';
            app.ConnectedRegionsOffset.FontSize = 11;
            app.ConnectedRegionsOffset.Visible = 'off';
            app.ConnectedRegionsOffset.Layout.Row = 9;
            app.ConnectedRegionsOffset.Layout.Column = 1;
            app.ConnectedRegionsOffset.Value = 12;

            % Create ConnectedRegionsAreaLabel
            app.ConnectedRegionsAreaLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsAreaLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsAreaLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsAreaLabel.WordWrap = 'on';
            app.ConnectedRegionsAreaLabel.FontSize = 11;
            app.ConnectedRegionsAreaLabel.Visible = 'off';
            app.ConnectedRegionsAreaLabel.Layout.Row = 8;
            app.ConnectedRegionsAreaLabel.Layout.Column = 2;
            app.ConnectedRegionsAreaLabel.Text = 'Área mínima acumulada (%):';

            % Create ConnectedRegionsArea
            app.ConnectedRegionsArea = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsArea.Limits = [50 100];
            app.ConnectedRegionsArea.RoundFractionalValues = 'on';
            app.ConnectedRegionsArea.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsArea.Tag = 'ConnectedRegions';
            app.ConnectedRegionsArea.FontSize = 11;
            app.ConnectedRegionsArea.Visible = 'off';
            app.ConnectedRegionsArea.Layout.Row = 9;
            app.ConnectedRegionsArea.Layout.Column = 2;
            app.ConnectedRegionsArea.Value = 99;

            % Create ConnectedRegionsMaxOccupancyLabel
            app.ConnectedRegionsMaxOccupancyLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsMaxOccupancyLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMaxOccupancyLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsMaxOccupancyLabel.WordWrap = 'on';
            app.ConnectedRegionsMaxOccupancyLabel.FontSize = 11;
            app.ConnectedRegionsMaxOccupancyLabel.Visible = 'off';
            app.ConnectedRegionsMaxOccupancyLabel.Layout.Row = 8;
            app.ConnectedRegionsMaxOccupancyLabel.Layout.Column = 3;
            app.ConnectedRegionsMaxOccupancyLabel.Text = 'Ocupação mínima refinamento pico (%)';

            % Create ConnectedRegionsMaxOccupancy
            app.ConnectedRegionsMaxOccupancy = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsMaxOccupancy.Limits = [50 100];
            app.ConnectedRegionsMaxOccupancy.RoundFractionalValues = 'on';
            app.ConnectedRegionsMaxOccupancy.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsMaxOccupancy.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMaxOccupancy.FontSize = 11;
            app.ConnectedRegionsMaxOccupancy.Visible = 'off';
            app.ConnectedRegionsMaxOccupancy.Layout.Row = 9;
            app.ConnectedRegionsMaxOccupancy.Layout.Column = 3;
            app.ConnectedRegionsMaxOccupancy.Value = 99;

            % Create ConnectedRegionsMinOccupancyLabel
            app.ConnectedRegionsMinOccupancyLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsMinOccupancyLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOccupancyLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsMinOccupancyLabel.WordWrap = 'on';
            app.ConnectedRegionsMinOccupancyLabel.FontSize = 11;
            app.ConnectedRegionsMinOccupancyLabel.Visible = 'off';
            app.ConnectedRegionsMinOccupancyLabel.Layout.Row = 10;
            app.ConnectedRegionsMinOccupancyLabel.Layout.Column = 1;
            app.ConnectedRegionsMinOccupancyLabel.Text = {'Ocupação mínima'; '(%):'};

            % Create ConnectedRegionsMinOccupancy
            app.ConnectedRegionsMinOccupancy = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsMinOccupancy.Step = 3;
            app.ConnectedRegionsMinOccupancy.Limits = [0 90];
            app.ConnectedRegionsMinOccupancy.RoundFractionalValues = 'on';
            app.ConnectedRegionsMinOccupancy.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsMinOccupancy.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOccupancy.FontSize = 11;
            app.ConnectedRegionsMinOccupancy.Visible = 'off';
            app.ConnectedRegionsMinOccupancy.Layout.Row = 11;
            app.ConnectedRegionsMinOccupancy.Layout.Column = 1;
            app.ConnectedRegionsMinOccupancy.Value = 3;

            % Create ConnectedRegionsMinOrientationLabel
            app.ConnectedRegionsMinOrientationLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsMinOrientationLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOrientationLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsMinOrientationLabel.WordWrap = 'on';
            app.ConnectedRegionsMinOrientationLabel.FontSize = 11;
            app.ConnectedRegionsMinOrientationLabel.Visible = 'off';
            app.ConnectedRegionsMinOrientationLabel.Layout.Row = 10;
            app.ConnectedRegionsMinOrientationLabel.Layout.Column = 2;
            app.ConnectedRegionsMinOrientationLabel.Text = 'Inclinação absoluta mínima (º):';

            % Create ConnectedRegionsMinOrientation
            app.ConnectedRegionsMinOrientation = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsMinOrientation.Step = 5;
            app.ConnectedRegionsMinOrientation.Limits = [0 90];
            app.ConnectedRegionsMinOrientation.RoundFractionalValues = 'on';
            app.ConnectedRegionsMinOrientation.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsMinOrientation.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOrientation.FontSize = 11;
            app.ConnectedRegionsMinOrientation.Visible = 'off';
            app.ConnectedRegionsMinOrientation.Layout.Row = 11;
            app.ConnectedRegionsMinOrientation.Layout.Column = 2;
            app.ConnectedRegionsMinOrientation.Value = 75;

            % Create SearchButton
            app.SearchButton = uibutton(app.GridLayout, 'push');
            app.SearchButton.ButtonPushedFcn = createCallbackFcn(app, @onSearchButtonClicked, true);
            app.SearchButton.Icon = 'search-sparkle.svg';
            app.SearchButton.IconAlignment = 'leftmargin';
            app.SearchButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SearchButton.Layout.Row = 6;
            app.SearchButton.Layout.Column = 2;
            app.SearchButton.Text = 'Pesquisar';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockDetection_exported(Container, varargin)

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
