classdef dockDetection_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        ConfigRefresh                   matlab.ui.control.Image
        SearchAllFlows                  matlab.ui.control.CheckBox
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
        ManualAlgorithmDescription      matlab.ui.control.Label
        ExternalFileTemplateDownload    matlab.ui.control.Hyperlink
        ExternalFileSource              matlab.ui.control.DropDown
        ExternalFileSourceLabel         matlab.ui.control.Label
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
        function updatePanel(app)
            elHandles = app.AlgorithmGrid.Children;
            configRefresh = false;

            switch app.Algorithm.Value
                case 'Arquivo'
                    relatedElHandles = findobj(elHandles, 'Tag', 'ExternalFile');
                    app.AlgorithmGrid.RowHeight = {26, 22, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

                case 'Manual – selecionar região da emissão'
                    relatedElHandles = findobj(elHandles, 'Tag', 'Manual');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, '1x', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

                case 'Manual – usar pontos marcados (datatips)'
                    relatedElHandles = findobj(elHandles, 'Tag', 'Manual');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, '1x', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

                case 'Detecção por picos'
                    relatedElHandles = findobj(elHandles, 'Tag', 'FindPeaks');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, 0, 26, 22, 32, 22, 0, 0, 0, 0, 0, 0, 0};
                    configRefresh = true;

                case 'Picos com ocupação'
                    relatedElHandles = findobj(elHandles, 'Tag', 'FindPeaksPlusOCC');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, 0, 0, 0, 0, 0, 26, 22, '1x', 0, 0, 0, 0};
                    configRefresh = true;

                case 'Regiões conectadas'
                    relatedElHandles = findobj(elHandles, 'Tag', 'ConnectedRegions');
                    app.AlgorithmGrid.RowHeight = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 22, 32, 22};
                    configRefresh = true;
            end

            set(relatedElHandles, 'Visible', true)
            set(setdiff(elHandles, relatedElHandles), 'Visible', false)            
            app.ConfigRefresh.Visible = configRefresh;
            SearchModePanelSelectionChanged(app)

            % initialValues(app)
        end

        %-----------------------------------------------------------------%
        function initialValues(app)
            idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;
            
            app.Algorithm.Value  = app.specData(idxThread).UserData.reportAlgorithms.Detection.Algorithm;
            set(app.FindPeaksPlusOCCClass, 'Items', [{''}; app.channelObj.FindPeaks.Name], 'Value', '')
            updatePanel(app)

            switch app.Algorithm.Value
                case 'FindPeaks'
                    app.FindPeaksTrace.Value               = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Fcn;
                    app.FindPeaksNumPeaks.Value            = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.NPeaks;
                    app.FindPeaksThreshold.Value           = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.THR;
                    app.FindPeaksProminence.Value          = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence;
                    app.FindPeaksDistance.Value            = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz;
                    app.FindPeaksBandWidth.Value           = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz;

                case 'FindPeaks+OCC'
                    app.FindPeaksDistance.Value            = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz;
                    app.FindPeaksBandWidth.Value           = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz;
                    app.FindPeaksPlusOCCProminence1.Value  = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence1;
                    app.FindPeaksPlusOCCProminence2.Value  = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence2;
                    app.FindPeaksPlusOCCMinOccupancy.Value = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.meanOCC;
                    app.FindPeaksPlusOCCMaxOccupancy.Value = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.maxOCC;
            end
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app)
            editionFlag = false;

            idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;
            if ~isequal(app.Algorithm.Value, app.specData(idxThread).UserData.reportAlgorithms.Detection.Algorithm)
                editionFlag = true;

            else
                switch app.Algorithm.Value
                    case 'FindPeaks'
                        if ~isequal(app.FindPeaksTrace.Value,       app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Fcn)          || ...
                           ~isequal(app.FindPeaksNumPeaks.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.NPeaks)       || ...
                           ~isequal(app.FindPeaksThreshold.Value,         app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.THR)          || ...
                           ~isequal(app.FindPeaksProminence.Value,  app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence)   || ...
                           ~isequal(app.FindPeaksDistance.Value,    app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz) || ...
                           ~isequal(app.FindPeaksBandWidth.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz)
                            
                            editionFlag = true;
                        end

                    case 'FindPeaks+OCC'
                        if ~isequal(app.FindPeaksDistance.Value,    app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz) || ...
                           ~isequal(app.FindPeaksBandWidth.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz)       || ...
                           ~isequal(app.FindPeaksPlusOCCProminence1.Value, app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence1)  || ...
                           ~isequal(app.FindPeaksPlusOCCProminence2.Value, app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence2)  || ...
                           ~isequal(app.FindPeaksPlusOCCMinOccupancy.Value,     app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.meanOCC)      || ...
                           ~isequal(app.FindPeaksPlusOCCMaxOccupancy.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.maxOCC)
                            
                            editionFlag = true;
                        end
                end
            end
        end

        %-----------------------------------------------------------------%
        function callingMainApp(app, updateFlag, returnFlag, idxThread)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'REPORT:DETECTION', updateFlag, returnFlag, idxThread)
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

        % Value changed function: Algorithm
        function AlgorithmValueChanged(app, event)
            
            updatePanel(app)

        end

        % Callback function
        function FindPeaksPlusOCCClassValueChanged(app, event)
            
            if ~isempty(app.FindPeaksPlusOCCClass.Value)
                [~, idxFindPeaks] = ismember(app.FindPeaksPlusOCCClass.Value, app.channelObj.FindPeaks.Name);

                if idxFindPeaks    
                    app.FindPeaksDistance.Value    = 1000 * app.channelObj.FindPeaks.Distance(idxFindPeaks);
                    app.FindPeaksBandWidth.Value      = 1000 * app.channelObj.FindPeaks.BW(idxFindPeaks);
                    app.FindPeaksPlusOCCProminence1.Value = app.channelObj.FindPeaks.Prominence1(idxFindPeaks);
                    app.FindPeaksPlusOCCProminence2.Value = app.channelObj.FindPeaks.Prominence2(idxFindPeaks);
                    app.FindPeaksPlusOCCMinOccupancy.Value     = app.channelObj.FindPeaks.meanOCC(idxFindPeaks);
                    app.FindPeaksPlusOCCMaxOccupancy.Value      = app.channelObj.FindPeaks.maxOCC(idxFindPeaks);
    
                    ParameterValueChanged(app)
                end
            end

        end

        % Value changed function: FindPeaksPlusOCCMaxOccupancy, 
        % ...and 1 other component
        function occValueChanged(app, event)
            
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

        % Callback function
        function ParameterValueChanged(app, event)
            
            if checkEdition(app)
                app.SearchButton.Enable = 1;
            else
                app.SearchButton.Enable = 0;
            end

        end

        % Button pushed function: SearchButton
        function ButtonPushed(app, event)

            context = app.inputArgs.context;
            algorithm = app.Algorithm.Value;
            specData = app.callingApp.bandObj.SpecData;

            if app.SearchAllFlows.Visible && app.SearchAllFlows.Value && ~isscalar(app.mainApp.specData)
                msgQuestion = 'Confirma a busca de emissões em todos os fluxos de espectro?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                
                if userSelection == "Não"
                    if app.SearchAllFlows.Value
                        app.SearchAllFlows.Value = false;
                    end
                    return

                else
                    specData = app.mainApp.specData;
                end
            end

            for ii = 1:numel(specData)
                switch algorithm
                    case 'Arquivo'
                        idxList      = [];
                        freqList     = [];
                        widthKHzList = [];
                        methodList   = {};
                        % identifica [idxList, freqList, widthKHzList, methodList]
    
                    case 'Manual – selecionar região da emissão'
                        idxList      = [];
                        freqList     = [];
                        widthKHzList = [];
                        methodList   = {};
                        % inclui ROI... e identifica [idxList, freqList, widthKHzList, methodList]
    
                    case 'Manual – usar pontos marcados (datatips)'
                        idxList      = [];
                        freqList     = [];
                        widthKHzList = [];
                        methodList   = {};
                        % identifica [idxList, freqList, widthKHzList, methodList]

                    otherwise
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
                        
                        [idxList, freqList, widthKHzList, methodList] = util.Detection.run(specData, detectionConfig);
                end

                if isempty(idxList)
                    ui.Dialog(app.UIFigure, 'info', 'Não foi encontrada emissão que atenda aos critérios especificados.');
                    return
                end

                if app.OnlySearchEmissions.Value
                    util.Detection.drawEmission('Creation', app.callingApp.UIAxes1, app.callingApp.restoreView, freqList, widthKHzList)
                else
                    update(specData, 'UserData:Emissions', 'Add', idxList, freqList, widthKHzList, methodList, [], app.mainApp.channelObj)
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onEmissionAdded', context)
                end
            end

        end

        % Selection changed function: SearchModePanel
        function SearchModePanelSelectionChanged(app, event)
            
            app.SearchAllFlows.Visible = ~app.OnlySearchEmissions.Value && ~strcmp(app.Algorithm.Value, 'Manual – selecionar região da emissão');
            
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
            app.GridLayout.ColumnWidth = {'1x', 82, 18};
            app.GridLayout.RowHeight = {17, 166, 22, 22, '1x', 22};
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
            app.SearchModePanel.SelectionChangedFcn = createCallbackFcn(app, @SearchModePanelSelectionChanged, true);
            app.SearchModePanel.BackgroundColor = [1 1 1];
            app.SearchModePanel.Layout.Row = 2;
            app.SearchModePanel.Layout.Column = [1 3];

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
            app.Algorithm.Items = {'Arquivo', 'Manual – selecionar região da emissão', 'Manual – usar pontos marcados (datatips)', 'Detecção por picos', 'Picos com ocupação', 'Regiões conectadas'};
            app.Algorithm.ValueChangedFcn = createCallbackFcn(app, @AlgorithmValueChanged, true);
            app.Algorithm.FontSize = 11;
            app.Algorithm.BackgroundColor = [1 1 1];
            app.Algorithm.Layout.Row = 4;
            app.Algorithm.Layout.Column = [1 3];
            app.Algorithm.Value = 'Regiões conectadas';

            % Create AlgorithmPanel
            app.AlgorithmPanel = uipanel(app.GridLayout);
            app.AlgorithmPanel.Layout.Row = 5;
            app.AlgorithmPanel.Layout.Column = [1 3];

            % Create AlgorithmGrid
            app.AlgorithmGrid = uigridlayout(app.AlgorithmPanel);
            app.AlgorithmGrid.ColumnWidth = {110, 110, 110};
            app.AlgorithmGrid.RowHeight = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 22, 32, 22};
            app.AlgorithmGrid.RowSpacing = 5;
            app.AlgorithmGrid.BackgroundColor = [1 1 1];

            % Create ExternalFileSourceLabel
            app.ExternalFileSourceLabel = uilabel(app.AlgorithmGrid);
            app.ExternalFileSourceLabel.Tag = 'ExternalFile';
            app.ExternalFileSourceLabel.VerticalAlignment = 'bottom';
            app.ExternalFileSourceLabel.FontSize = 11;
            app.ExternalFileSourceLabel.Visible = 'off';
            app.ExternalFileSourceLabel.Layout.Row = 1;
            app.ExternalFileSourceLabel.Layout.Column = [1 3];
            app.ExternalFileSourceLabel.Text = {'Formato do arquivo a ser importado:'; '(origem dos dados)'};

            % Create ExternalFileSource
            app.ExternalFileSource = uidropdown(app.AlgorithmGrid);
            app.ExternalFileSource.Items = {'Genérico (.csv, .txt, .json, .xls e .xlsx)', 'ROMES (.csv)'};
            app.ExternalFileSource.Tag = 'ExternalFile';
            app.ExternalFileSource.Visible = 'off';
            app.ExternalFileSource.FontSize = 11;
            app.ExternalFileSource.BackgroundColor = [1 1 1];
            app.ExternalFileSource.Layout.Row = 2;
            app.ExternalFileSource.Layout.Column = [1 3];
            app.ExternalFileSource.Value = 'Genérico (.csv, .txt, .json, .xls e .xlsx)';

            % Create ExternalFileTemplateDownload
            app.ExternalFileTemplateDownload = uihyperlink(app.AlgorithmGrid);
            app.ExternalFileTemplateDownload.Tag = 'ExternalFile';
            app.ExternalFileTemplateDownload.VerticalAlignment = 'top';
            app.ExternalFileTemplateDownload.FontSize = 10;
            app.ExternalFileTemplateDownload.Visible = 'off';
            app.ExternalFileTemplateDownload.Layout.Row = 3;
            app.ExternalFileTemplateDownload.Layout.Column = [1 3];
            app.ExternalFileTemplateDownload.Text = 'Download modelo do arquivo';

            % Create ManualAlgorithmDescription
            app.ManualAlgorithmDescription = uilabel(app.AlgorithmGrid);
            app.ManualAlgorithmDescription.Tag = 'Manual';
            app.ManualAlgorithmDescription.BackgroundColor = [0.4667 0.6745 0.1882];
            app.ManualAlgorithmDescription.VerticalAlignment = 'top';
            app.ManualAlgorithmDescription.WordWrap = 'on';
            app.ManualAlgorithmDescription.FontSize = 11;
            app.ManualAlgorithmDescription.FontColor = [1 1 1];
            app.ManualAlgorithmDescription.Visible = 'off';
            app.ManualAlgorithmDescription.Layout.Row = 4;
            app.ManualAlgorithmDescription.Layout.Column = [1 3];
            app.ManualAlgorithmDescription.Text = 'PLACE HOLDER';

            % Create FindPeaksTraceLabel
            app.FindPeaksTraceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksTraceLabel.Tag = 'FindPeaks';
            app.FindPeaksTraceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksTraceLabel.FontSize = 11;
            app.FindPeaksTraceLabel.Visible = 'off';
            app.FindPeaksTraceLabel.Layout.Row = 5;
            app.FindPeaksTraceLabel.Layout.Column = 1;
            app.FindPeaksTraceLabel.Text = {'Tipo de traço:'; '(agregação dados)'};

            % Create FindPeaksTrace
            app.FindPeaksTrace = uidropdown(app.AlgorithmGrid);
            app.FindPeaksTrace.Items = {'MinHold', 'Mean', 'MaxHold'};
            app.FindPeaksTrace.Tag = 'FindPeaks';
            app.FindPeaksTrace.Visible = 'off';
            app.FindPeaksTrace.FontSize = 10;
            app.FindPeaksTrace.BackgroundColor = [1 1 1];
            app.FindPeaksTrace.Layout.Row = 6;
            app.FindPeaksTrace.Layout.Column = 1;
            app.FindPeaksTrace.Value = 'Mean';

            % Create FindPeaksDistanceLabel
            app.FindPeaksDistanceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksDistanceLabel.Tag = 'FindPeaks';
            app.FindPeaksDistanceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksDistanceLabel.WordWrap = 'on';
            app.FindPeaksDistanceLabel.FontSize = 11;
            app.FindPeaksDistanceLabel.Visible = 'off';
            app.FindPeaksDistanceLabel.Layout.Row = 5;
            app.FindPeaksDistanceLabel.Layout.Column = 2;
            app.FindPeaksDistanceLabel.Text = 'Distância entre picos (kHz):';

            % Create FindPeaksDistance
            app.FindPeaksDistance = uispinner(app.AlgorithmGrid);
            app.FindPeaksDistance.Step = 25;
            app.FindPeaksDistance.Limits = [0 Inf];
            app.FindPeaksDistance.RoundFractionalValues = 'on';
            app.FindPeaksDistance.ValueDisplayFormat = '%.0f';
            app.FindPeaksDistance.Tag = 'FindPeaks';
            app.FindPeaksDistance.FontSize = 10;
            app.FindPeaksDistance.Visible = 'off';
            app.FindPeaksDistance.Layout.Row = 6;
            app.FindPeaksDistance.Layout.Column = 2;
            app.FindPeaksDistance.Value = 25;

            % Create FindPeaksBandWidthLabel
            app.FindPeaksBandWidthLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksBandWidthLabel.Tag = 'FindPeaks';
            app.FindPeaksBandWidthLabel.VerticalAlignment = 'bottom';
            app.FindPeaksBandWidthLabel.WordWrap = 'on';
            app.FindPeaksBandWidthLabel.FontSize = 11;
            app.FindPeaksBandWidthLabel.Visible = 'off';
            app.FindPeaksBandWidthLabel.Layout.Row = 5;
            app.FindPeaksBandWidthLabel.Layout.Column = 3;
            app.FindPeaksBandWidthLabel.Text = {'Largura ocupada'; '(kHz):'};

            % Create FindPeaksBandWidth
            app.FindPeaksBandWidth = uispinner(app.AlgorithmGrid);
            app.FindPeaksBandWidth.Step = 10;
            app.FindPeaksBandWidth.Limits = [0 Inf];
            app.FindPeaksBandWidth.RoundFractionalValues = 'on';
            app.FindPeaksBandWidth.ValueDisplayFormat = '%.0f';
            app.FindPeaksBandWidth.Tag = 'FindPeaks';
            app.FindPeaksBandWidth.FontSize = 10;
            app.FindPeaksBandWidth.Visible = 'off';
            app.FindPeaksBandWidth.Layout.Row = 6;
            app.FindPeaksBandWidth.Layout.Column = 3;
            app.FindPeaksBandWidth.Value = 10;

            % Create FindPeaksProminenceLabel
            app.FindPeaksProminenceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksProminenceLabel.Tag = 'FindPeaks';
            app.FindPeaksProminenceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksProminenceLabel.WordWrap = 'on';
            app.FindPeaksProminenceLabel.FontSize = 11;
            app.FindPeaksProminenceLabel.Visible = 'off';
            app.FindPeaksProminenceLabel.Layout.Row = 7;
            app.FindPeaksProminenceLabel.Layout.Column = 1;
            app.FindPeaksProminenceLabel.Text = {'Proeminência'; '(dB):'};

            % Create FindPeaksProminence
            app.FindPeaksProminence = uispinner(app.AlgorithmGrid);
            app.FindPeaksProminence.Step = 3;
            app.FindPeaksProminence.Limits = [1 Inf];
            app.FindPeaksProminence.RoundFractionalValues = 'on';
            app.FindPeaksProminence.ValueDisplayFormat = '%.0f';
            app.FindPeaksProminence.Tag = 'FindPeaks';
            app.FindPeaksProminence.FontSize = 10;
            app.FindPeaksProminence.Visible = 'off';
            app.FindPeaksProminence.Layout.Row = 8;
            app.FindPeaksProminence.Layout.Column = 1;
            app.FindPeaksProminence.Value = 12;

            % Create FindPeaksNumPeaksLabel
            app.FindPeaksNumPeaksLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksNumPeaksLabel.Tag = 'FindPeaks';
            app.FindPeaksNumPeaksLabel.VerticalAlignment = 'bottom';
            app.FindPeaksNumPeaksLabel.WordWrap = 'on';
            app.FindPeaksNumPeaksLabel.FontSize = 11;
            app.FindPeaksNumPeaksLabel.Visible = 'off';
            app.FindPeaksNumPeaksLabel.Layout.Row = 7;
            app.FindPeaksNumPeaksLabel.Layout.Column = 2;
            app.FindPeaksNumPeaksLabel.Text = {'Número máximo '; 'de picos:'};

            % Create FindPeaksNumPeaks
            app.FindPeaksNumPeaks = uispinner(app.AlgorithmGrid);
            app.FindPeaksNumPeaks.Step = 5;
            app.FindPeaksNumPeaks.Limits = [1 100];
            app.FindPeaksNumPeaks.RoundFractionalValues = 'on';
            app.FindPeaksNumPeaks.ValueDisplayFormat = '%.0f';
            app.FindPeaksNumPeaks.Tag = 'FindPeaks';
            app.FindPeaksNumPeaks.FontSize = 10;
            app.FindPeaksNumPeaks.Visible = 'off';
            app.FindPeaksNumPeaks.Layout.Row = 8;
            app.FindPeaksNumPeaks.Layout.Column = 2;
            app.FindPeaksNumPeaks.Value = 50;

            % Create FindPeaksThresholdLabel
            app.FindPeaksThresholdLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksThresholdLabel.Tag = 'FindPeaks';
            app.FindPeaksThresholdLabel.VerticalAlignment = 'bottom';
            app.FindPeaksThresholdLabel.FontSize = 11;
            app.FindPeaksThresholdLabel.Visible = 'off';
            app.FindPeaksThresholdLabel.Layout.Row = 7;
            app.FindPeaksThresholdLabel.Layout.Column = 3;
            app.FindPeaksThresholdLabel.Text = {'Threshold'; '(dB):'};

            % Create FindPeaksThreshold
            app.FindPeaksThreshold = uispinner(app.AlgorithmGrid);
            app.FindPeaksThreshold.Step = 10;
            app.FindPeaksThreshold.RoundFractionalValues = 'on';
            app.FindPeaksThreshold.ValueDisplayFormat = '%.0f';
            app.FindPeaksThreshold.Tag = 'FindPeaks';
            app.FindPeaksThreshold.FontSize = 10;
            app.FindPeaksThreshold.Visible = 'off';
            app.FindPeaksThreshold.Layout.Row = 8;
            app.FindPeaksThreshold.Layout.Column = 3;
            app.FindPeaksThreshold.Value = -Inf;

            % Create FindPeaksPlusOCCClassLabel
            app.FindPeaksPlusOCCClassLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCClassLabel.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCClassLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCClassLabel.FontSize = 11;
            app.FindPeaksPlusOCCClassLabel.Visible = 'off';
            app.FindPeaksPlusOCCClassLabel.Layout.Row = 9;
            app.FindPeaksPlusOCCClassLabel.Layout.Column = 1;
            app.FindPeaksPlusOCCClassLabel.Text = {'Classe de emissão:'; '(tecnologia)'};

            % Create FindPeaksPlusOCCClass
            app.FindPeaksPlusOCCClass = uidropdown(app.AlgorithmGrid);
            app.FindPeaksPlusOCCClass.Items = {};
            app.FindPeaksPlusOCCClass.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCClass.Visible = 'off';
            app.FindPeaksPlusOCCClass.FontSize = 10;
            app.FindPeaksPlusOCCClass.BackgroundColor = [1 1 1];
            app.FindPeaksPlusOCCClass.Layout.Row = 10;
            app.FindPeaksPlusOCCClass.Layout.Column = 1;
            app.FindPeaksPlusOCCClass.Value = {};

            % Create FindPeaksPlusOCCDistanceLabel
            app.FindPeaksPlusOCCDistanceLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCDistanceLabel.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCDistanceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCDistanceLabel.WordWrap = 'on';
            app.FindPeaksPlusOCCDistanceLabel.FontSize = 11;
            app.FindPeaksPlusOCCDistanceLabel.Visible = 'off';
            app.FindPeaksPlusOCCDistanceLabel.Layout.Row = 9;
            app.FindPeaksPlusOCCDistanceLabel.Layout.Column = 2;
            app.FindPeaksPlusOCCDistanceLabel.Text = 'Distância entre picos (kHz):';

            % Create FindPeaksPlusOCCDistance
            app.FindPeaksPlusOCCDistance = uispinner(app.AlgorithmGrid);
            app.FindPeaksPlusOCCDistance.Step = 25;
            app.FindPeaksPlusOCCDistance.Limits = [0 Inf];
            app.FindPeaksPlusOCCDistance.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCDistance.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCDistance.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCDistance.FontSize = 10;
            app.FindPeaksPlusOCCDistance.Visible = 'off';
            app.FindPeaksPlusOCCDistance.Layout.Row = 10;
            app.FindPeaksPlusOCCDistance.Layout.Column = 2;
            app.FindPeaksPlusOCCDistance.Value = 25;

            % Create FindPeaksPlusOCCBandWidthLabel
            app.FindPeaksPlusOCCBandWidthLabel = uilabel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCBandWidthLabel.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCBandWidthLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCBandWidthLabel.WordWrap = 'on';
            app.FindPeaksPlusOCCBandWidthLabel.FontSize = 11;
            app.FindPeaksPlusOCCBandWidthLabel.Visible = 'off';
            app.FindPeaksPlusOCCBandWidthLabel.Layout.Row = 9;
            app.FindPeaksPlusOCCBandWidthLabel.Layout.Column = 3;
            app.FindPeaksPlusOCCBandWidthLabel.Text = {'Largura ocupada'; '(kHz):'};

            % Create FindPeaksPlusOCCBandWidth
            app.FindPeaksPlusOCCBandWidth = uispinner(app.AlgorithmGrid);
            app.FindPeaksPlusOCCBandWidth.Step = 10;
            app.FindPeaksPlusOCCBandWidth.Limits = [0 Inf];
            app.FindPeaksPlusOCCBandWidth.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCBandWidth.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCBandWidth.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCBandWidth.FontSize = 10;
            app.FindPeaksPlusOCCBandWidth.Visible = 'off';
            app.FindPeaksPlusOCCBandWidth.Layout.Row = 10;
            app.FindPeaksPlusOCCBandWidth.Layout.Column = 3;
            app.FindPeaksPlusOCCBandWidth.Value = 10;

            % Create FindPeaksPlusOCCPanel1
            app.FindPeaksPlusOCCPanel1 = uipanel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCPanel1.Title = 'MÉDIA';
            app.FindPeaksPlusOCCPanel1.Visible = 'off';
            app.FindPeaksPlusOCCPanel1.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCPanel1.Layout.Row = 11;
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
            app.FindPeaksPlusOCCProminence1Label.FontSize = 10;
            app.FindPeaksPlusOCCProminence1Label.Layout.Row = 1;
            app.FindPeaksPlusOCCProminence1Label.Layout.Column = 1;
            app.FindPeaksPlusOCCProminence1Label.Text = {'Proeminência'; '(dB):'};

            % Create FindPeaksPlusOCCProminence1
            app.FindPeaksPlusOCCProminence1 = uispinner(app.FindPeaksPlusOCCGrid1);
            app.FindPeaksPlusOCCProminence1.Step = 3;
            app.FindPeaksPlusOCCProminence1.Limits = [1 Inf];
            app.FindPeaksPlusOCCProminence1.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCProminence1.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCProminence1.FontSize = 10;
            app.FindPeaksPlusOCCProminence1.Layout.Row = 2;
            app.FindPeaksPlusOCCProminence1.Layout.Column = 1;
            app.FindPeaksPlusOCCProminence1.Value = 12;

            % Create FindPeaksPlusOCCPanel2
            app.FindPeaksPlusOCCPanel2 = uipanel(app.AlgorithmGrid);
            app.FindPeaksPlusOCCPanel2.Title = 'MAXHOLD';
            app.FindPeaksPlusOCCPanel2.Visible = 'off';
            app.FindPeaksPlusOCCPanel2.Tag = 'FindPeaksPlusOCC';
            app.FindPeaksPlusOCCPanel2.Layout.Row = 11;
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
            app.FindPeaksPlusOCCProminence2Label.WordWrap = 'on';
            app.FindPeaksPlusOCCProminence2Label.FontSize = 10;
            app.FindPeaksPlusOCCProminence2Label.Layout.Row = 1;
            app.FindPeaksPlusOCCProminence2Label.Layout.Column = [1 5];
            app.FindPeaksPlusOCCProminence2Label.Text = {'Proeminência'; '(dB):'};

            % Create FindPeaksPlusOCCProminence2
            app.FindPeaksPlusOCCProminence2 = uispinner(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCProminence2.Step = 3;
            app.FindPeaksPlusOCCProminence2.Limits = [1 Inf];
            app.FindPeaksPlusOCCProminence2.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCProminence2.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCProminence2.FontSize = 10;
            app.FindPeaksPlusOCCProminence2.Layout.Row = 2;
            app.FindPeaksPlusOCCProminence2.Layout.Column = 1;
            app.FindPeaksPlusOCCProminence2.Value = 30;

            % Create FindPeaksPlusOCCOccupancyLabel
            app.FindPeaksPlusOCCOccupancyLabel = uilabel(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCOccupancyLabel.VerticalAlignment = 'bottom';
            app.FindPeaksPlusOCCOccupancyLabel.FontSize = 10;
            app.FindPeaksPlusOCCOccupancyLabel.Layout.Row = 1;
            app.FindPeaksPlusOCCOccupancyLabel.Layout.Column = [3 5];
            app.FindPeaksPlusOCCOccupancyLabel.Interpreter = 'html';
            app.FindPeaksPlusOCCOccupancyLabel.Text = {'Ocupação (%):'; '<p style="line-height:10px; font-size:9px; color:gray;">(Mínima | Máxima)</p>'};

            % Create FindPeaksPlusOCCMinOccupancy
            app.FindPeaksPlusOCCMinOccupancy = uispinner(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCMinOccupancy.Step = 10;
            app.FindPeaksPlusOCCMinOccupancy.Limits = [0 100];
            app.FindPeaksPlusOCCMinOccupancy.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCMinOccupancy.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCMinOccupancy.ValueChangedFcn = createCallbackFcn(app, @occValueChanged, true);
            app.FindPeaksPlusOCCMinOccupancy.FontSize = 10;
            app.FindPeaksPlusOCCMinOccupancy.Layout.Row = 2;
            app.FindPeaksPlusOCCMinOccupancy.Layout.Column = 3;
            app.FindPeaksPlusOCCMinOccupancy.Value = 1;

            % Create FindPeaksPlusOCCMaxOccupancy
            app.FindPeaksPlusOCCMaxOccupancy = uispinner(app.FindPeaksPlusOCCGrid2);
            app.FindPeaksPlusOCCMaxOccupancy.Step = 10;
            app.FindPeaksPlusOCCMaxOccupancy.Limits = [0 100];
            app.FindPeaksPlusOCCMaxOccupancy.RoundFractionalValues = 'on';
            app.FindPeaksPlusOCCMaxOccupancy.ValueDisplayFormat = '%.0f';
            app.FindPeaksPlusOCCMaxOccupancy.ValueChangedFcn = createCallbackFcn(app, @occValueChanged, true);
            app.FindPeaksPlusOCCMaxOccupancy.FontSize = 10;
            app.FindPeaksPlusOCCMaxOccupancy.Layout.Row = 2;
            app.FindPeaksPlusOCCMaxOccupancy.Layout.Column = 5;
            app.FindPeaksPlusOCCMaxOccupancy.Value = 10;

            % Create ConnectedRegionsOffsetLabel
            app.ConnectedRegionsOffsetLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsOffsetLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsOffsetLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsOffsetLabel.WordWrap = 'on';
            app.ConnectedRegionsOffsetLabel.FontSize = 11;
            app.ConnectedRegionsOffsetLabel.Layout.Row = 12;
            app.ConnectedRegionsOffsetLabel.Layout.Column = 1;
            app.ConnectedRegionsOffsetLabel.Text = {'Proeminência'; '(dB):'};

            % Create ConnectedRegionsOffset
            app.ConnectedRegionsOffset = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsOffset.Step = 3;
            app.ConnectedRegionsOffset.Limits = [3 30];
            app.ConnectedRegionsOffset.RoundFractionalValues = 'on';
            app.ConnectedRegionsOffset.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsOffset.Tag = 'ConnectedRegions';
            app.ConnectedRegionsOffset.FontSize = 10;
            app.ConnectedRegionsOffset.Layout.Row = 13;
            app.ConnectedRegionsOffset.Layout.Column = 1;
            app.ConnectedRegionsOffset.Value = 12;

            % Create ConnectedRegionsAreaLabel
            app.ConnectedRegionsAreaLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsAreaLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsAreaLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsAreaLabel.WordWrap = 'on';
            app.ConnectedRegionsAreaLabel.FontSize = 11;
            app.ConnectedRegionsAreaLabel.Layout.Row = 12;
            app.ConnectedRegionsAreaLabel.Layout.Column = 2;
            app.ConnectedRegionsAreaLabel.Text = 'Área mínima acumulada (%):';

            % Create ConnectedRegionsArea
            app.ConnectedRegionsArea = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsArea.Limits = [50 100];
            app.ConnectedRegionsArea.RoundFractionalValues = 'on';
            app.ConnectedRegionsArea.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsArea.Tag = 'ConnectedRegions';
            app.ConnectedRegionsArea.FontSize = 10;
            app.ConnectedRegionsArea.Layout.Row = 13;
            app.ConnectedRegionsArea.Layout.Column = 2;
            app.ConnectedRegionsArea.Value = 99;

            % Create ConnectedRegionsMaxOccupancyLabel
            app.ConnectedRegionsMaxOccupancyLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsMaxOccupancyLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMaxOccupancyLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsMaxOccupancyLabel.WordWrap = 'on';
            app.ConnectedRegionsMaxOccupancyLabel.FontSize = 11;
            app.ConnectedRegionsMaxOccupancyLabel.Layout.Row = 12;
            app.ConnectedRegionsMaxOccupancyLabel.Layout.Column = 3;
            app.ConnectedRegionsMaxOccupancyLabel.Text = 'Ocupação mínima refinamento pico (%)';

            % Create ConnectedRegionsMaxOccupancy
            app.ConnectedRegionsMaxOccupancy = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsMaxOccupancy.Limits = [50 100];
            app.ConnectedRegionsMaxOccupancy.RoundFractionalValues = 'on';
            app.ConnectedRegionsMaxOccupancy.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsMaxOccupancy.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMaxOccupancy.FontSize = 10;
            app.ConnectedRegionsMaxOccupancy.Layout.Row = 13;
            app.ConnectedRegionsMaxOccupancy.Layout.Column = 3;
            app.ConnectedRegionsMaxOccupancy.Value = 99;

            % Create ConnectedRegionsMinOccupancyLabel
            app.ConnectedRegionsMinOccupancyLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsMinOccupancyLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOccupancyLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsMinOccupancyLabel.WordWrap = 'on';
            app.ConnectedRegionsMinOccupancyLabel.FontSize = 11;
            app.ConnectedRegionsMinOccupancyLabel.Layout.Row = 14;
            app.ConnectedRegionsMinOccupancyLabel.Layout.Column = 1;
            app.ConnectedRegionsMinOccupancyLabel.Text = {'Ocupação mínima'; '(%):'};

            % Create ConnectedRegionsMinOccupancy
            app.ConnectedRegionsMinOccupancy = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsMinOccupancy.Step = 3;
            app.ConnectedRegionsMinOccupancy.Limits = [0 90];
            app.ConnectedRegionsMinOccupancy.RoundFractionalValues = 'on';
            app.ConnectedRegionsMinOccupancy.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsMinOccupancy.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOccupancy.FontSize = 10;
            app.ConnectedRegionsMinOccupancy.Layout.Row = 15;
            app.ConnectedRegionsMinOccupancy.Layout.Column = 1;
            app.ConnectedRegionsMinOccupancy.Value = 3;

            % Create ConnectedRegionsMinOrientationLabel
            app.ConnectedRegionsMinOrientationLabel = uilabel(app.AlgorithmGrid);
            app.ConnectedRegionsMinOrientationLabel.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOrientationLabel.VerticalAlignment = 'bottom';
            app.ConnectedRegionsMinOrientationLabel.WordWrap = 'on';
            app.ConnectedRegionsMinOrientationLabel.FontSize = 11;
            app.ConnectedRegionsMinOrientationLabel.Layout.Row = 14;
            app.ConnectedRegionsMinOrientationLabel.Layout.Column = 2;
            app.ConnectedRegionsMinOrientationLabel.Text = 'Inclinação absoluta mínima (º):';

            % Create ConnectedRegionsMinOrientation
            app.ConnectedRegionsMinOrientation = uispinner(app.AlgorithmGrid);
            app.ConnectedRegionsMinOrientation.Step = 5;
            app.ConnectedRegionsMinOrientation.Limits = [0 90];
            app.ConnectedRegionsMinOrientation.RoundFractionalValues = 'on';
            app.ConnectedRegionsMinOrientation.ValueDisplayFormat = '%.0f';
            app.ConnectedRegionsMinOrientation.Tag = 'ConnectedRegions';
            app.ConnectedRegionsMinOrientation.FontSize = 10;
            app.ConnectedRegionsMinOrientation.Layout.Row = 15;
            app.ConnectedRegionsMinOrientation.Layout.Column = 2;
            app.ConnectedRegionsMinOrientation.Value = 75;

            % Create SearchButton
            app.SearchButton = uibutton(app.GridLayout, 'push');
            app.SearchButton.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.SearchButton.Icon = 'search-sparkle.svg';
            app.SearchButton.IconAlignment = 'leftmargin';
            app.SearchButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SearchButton.Layout.Row = 6;
            app.SearchButton.Layout.Column = [2 3];
            app.SearchButton.Text = 'Pesquisar';

            % Create SearchAllFlows
            app.SearchAllFlows = uicheckbox(app.GridLayout);
            app.SearchAllFlows.Text = 'Aplicar a todos os fluxos espectrais';
            app.SearchAllFlows.FontSize = 11;
            app.SearchAllFlows.Layout.Row = 6;
            app.SearchAllFlows.Layout.Column = 1;

            % Create ConfigRefresh
            app.ConfigRefresh = uiimage(app.GridLayout);
            app.ConfigRefresh.ScaleMethod = 'none';
            app.ConfigRefresh.Visible = 'off';
            app.ConfigRefresh.Layout.Row = 3;
            app.ConfigRefresh.Layout.Column = 3;
            app.ConfigRefresh.ImageSource = 'Refresh_18.png';

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
