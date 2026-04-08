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

        end
        
        %-----------------------------------------------------------------%
        function play_BandLimits_Layout(app, idx)
            if app.play_BandLimits_Status.Value
                update(app.specData(idx), 'UserData:BandLimits', 'Status:Edit', true)
                
                set(app.play_BandLimits_Grid.Children, Enable=1)
                app.play_BandLimits_add.Enable  = 1;
                app.play_BandLimits_Tree.Enable = 1;

            else
                update(app.specData(idx), 'UserData:BandLimits', 'Status:Edit', false)

                set(findobj(app.play_BandLimits_Grid, 'Type', 'uinumericeditfield'), Enable=0)
                app.play_BandLimits_add.Enable  = 0;
                app.play_BandLimits_Tree.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function play_BandLimits_TreeBuilding(app, idx)
            
            if ~isempty(app.play_BandLimits_Tree.Children)
                delete(app.play_BandLimits_Tree.Children)
            end

            bandLimitsTable = app.specData(idx).UserData.bandLimitsTable;
            for ii = 1:height(bandLimitsTable)
                uitreenode(app.play_BandLimits_Tree, 'Text', sprintf('%.3f - %.3f MHz', bandLimitsTable.FreqStart(ii), bandLimitsTable.FreqStop(ii)), ...
                                                     'NodeData', ii, 'ContextMenu', app.play_BandLimits_ContextMenu);
            end
        end
        % 
        % %-----------------------------------------------------------------%
        % function initialValues(app)
        %     idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;
        % 
        %     app.Algorithm.Value  = app.specData(idxThread).UserData.reportAlgorithms.Detection.Algorithm;
        %     set(app.FindPeaksPlusOCCClass, 'Items', [{''}; app.channelObj.FindPeaks.Name], 'Value', '')
        %     updatePanel(app)
        % 
        %     switch app.Algorithm.Value
        %         case 'FindPeaks'
        %             app.FindPeaksTrace.Value               = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Fcn;
        %             app.FindPeaksNumPeaks.Value            = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.NPeaks;
        %             app.FindPeaksThreshold.Value           = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.THR;
        %             app.FindPeaksProminence.Value          = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence;
        %             app.FindPeaksDistance.Value            = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz;
        %             app.FindPeaksBandWidth.Value           = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz;
        % 
        %         case 'FindPeaks+OCC'
        %             app.FindPeaksDistance.Value            = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz;
        %             app.FindPeaksBandWidth.Value           = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz;
        %             app.FindPeaksPlusOCCProminence1.Value  = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence1;
        %             app.FindPeaksPlusOCCProminence2.Value  = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence2;
        %             app.FindPeaksPlusOCCMinOccupancy.Value = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.meanOCC;
        %             app.FindPeaksPlusOCCMaxOccupancy.Value = app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.maxOCC;
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function editionFlag = checkEdition(app)
        %     editionFlag = false;
        % 
        %     idxThread = app.mainApp.play_PlotPanel.UserData.NodeData;
        %     if ~isequal(app.Algorithm.Value, app.specData(idxThread).UserData.reportAlgorithms.Detection.Algorithm)
        %         editionFlag = true;
        % 
        %     else
        %         switch app.Algorithm.Value
        %             case 'FindPeaks'
        %                 if ~isequal(app.FindPeaksTrace.Value,       app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Fcn)          || ...
        %                    ~isequal(app.FindPeaksNumPeaks.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.NPeaks)       || ...
        %                    ~isequal(app.FindPeaksThreshold.Value,         app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.THR)          || ...
        %                    ~isequal(app.FindPeaksProminence.Value,  app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence)   || ...
        %                    ~isequal(app.FindPeaksDistance.Value,    app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz) || ...
        %                    ~isequal(app.FindPeaksBandWidth.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz)
        % 
        %                     editionFlag = true;
        %                 end
        % 
        %             case 'FindPeaks+OCC'
        %                 if ~isequal(app.FindPeaksDistance.Value,    app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Distance_kHz) || ...
        %                    ~isequal(app.FindPeaksBandWidth.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.BW_kHz)       || ...
        %                    ~isequal(app.FindPeaksPlusOCCProminence1.Value, app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence1)  || ...
        %                    ~isequal(app.FindPeaksPlusOCCProminence2.Value, app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.Prominence2)  || ...
        %                    ~isequal(app.FindPeaksPlusOCCMinOccupancy.Value,     app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.meanOCC)      || ...
        %                    ~isequal(app.FindPeaksPlusOCCMaxOccupancy.Value,      app.specData(idxThread).UserData.reportAlgorithms.Detection.Parameters.maxOCC)
        % 
        %                     editionFlag = true;
        %                 end
        %         end
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function callingMainApp(app, updateFlag, returnFlag, idxThread)
        %     ipcMainMatlabCallsHandler(app.mainApp, app, 'REPORT:DETECTION', updateFlag, returnFlag, idxThread)
        % end
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

        % Callback function
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

        % Callback function
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

        % Callback function
        function ButtonPushed(app, event)

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

                if app.OnlySearchEmissions.Value
                    util.Detection.drawEmission('Creation', app.callingApp.UIAxes1, app.callingApp.restoreView, freqList, widthKHzList)
                else
                    update(specData, 'UserData:Emissions', 'Add', idxList, freqList, widthKHzList, methodList, [], channelObj)
                    % atualiza plot...
                end
            end

        end

        % Callback function
        function SearchModePanelSelectionChanged(app, event)
            
            app.SearchAllFlows.Visible = ~app.OnlySearchEmissions.Value && ~strcmp(app.Algorithm.Value, 'Manual – selecionar região da emissão');
            
        end

        % Value changed function: play_BandLimits_Status
        function play_BandLimits_StatusValueChanged(app, event)
            
            idx = app.play_PlotPanel.UserData.NodeData;
            play_BandLimits_Layout(app, idx)

            if app.play_BandLimits_Status.Value                      && ...
                ~isempty(app.specData(idx).UserData.bandLimitsTable) && ...
                ~isempty(app.specData(idx).UserData.Emissions)

                msgQuestion   = 'Confirma a reanálise das emissões, eventualmente eliminando aquelas que não estão em uma das subfaixas sob análise?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    app.play_BandLimits_Status.Value = 0;
                    play_BandLimits_Layout(app, idx)
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
        function play_BandLimits_addImageClicked(app, event)
            
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

            play_BandLimits_TreeBuilding(app, idx)
            plot.draw2D.horizontalSetOfLines(app.UIAxes1, app.bandObj, idx, 'BandLimits')

        end

        % Menu selected function: ExcluirMenu
        function ExcluirMenuSelected(app, event)
            
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
    
                play_BandLimits_TreeBuilding(app, idx)
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
            app.play_BandLimits_Status.ValueChangedFcn = createCallbackFcn(app, @play_BandLimits_StatusValueChanged, true);
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
            app.play_BandLimits_add.ImageClickedFcn = createCallbackFcn(app, @play_BandLimits_addImageClicked, true);
            app.play_BandLimits_add.Enable = 'off';
            app.play_BandLimits_add.Layout.Row = 3;
            app.play_BandLimits_add.Layout.Column = 2;
            app.play_BandLimits_add.ImageSource = 'Add_16.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create ExcluirMenu
            app.ExcluirMenu = uimenu(app.ContextMenu);
            app.ExcluirMenu.MenuSelectedFcn = createCallbackFcn(app, @ExcluirMenuSelected, true);
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
