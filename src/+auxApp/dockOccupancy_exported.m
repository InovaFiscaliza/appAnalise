classdef dockOccupancy_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        play_OCC_Panel                 matlab.ui.container.Panel
        play_OCCGrid                   matlab.ui.container.GridLayout
        play_OCC_IntegrationTimeCaptured  matlab.ui.control.NumericEditField
        play_OCC_noisePanel            matlab.ui.container.Panel
        play_OCC_noiseGrid             matlab.ui.container.GridLayout
        play_OCC_noiseUsefulSamples    matlab.ui.control.Spinner
        play_OCC_noiseUsefulSamplesLabel  matlab.ui.control.Label
        play_OCC_noiseTrashSamples     matlab.ui.control.Spinner
        play_OCC_noiseTrashSamplesLabel  matlab.ui.control.Label
        play_OCC_noiseFcn              matlab.ui.control.DropDown
        play_OCC_noiseFcnLabel         matlab.ui.control.Label
        play_OCC_noiseLabel            matlab.ui.control.Label
        play_OCC_ceilFactor            matlab.ui.control.DropDown
        play_OCC_ceilFactorLabel       matlab.ui.control.Label
        play_OCC_Offset                matlab.ui.control.Spinner
        play_OCC_OffsetLabel           matlab.ui.control.Label
        play_OCC_THRCaptured           matlab.ui.control.DropDown
        play_OCC_THR                   matlab.ui.control.Spinner
        play_OCC_THRLabel              matlab.ui.control.Label
        play_OCC_Orientation           matlab.ui.control.DropDown
        play_OCC_OrientationLabel      matlab.ui.control.Label
        play_OCC_IntegrationTime       matlab.ui.control.DropDown
        play_OCC_IntegrationTimeLabel  matlab.ui.control.Label
        play_OCC_Method                matlab.ui.control.DropDown
        play_OCC_MethodLabel           matlab.ui.control.Label
        AddChannelButton               matlab.ui.control.Button
        RadioButtonPanelLabel          matlab.ui.control.Label
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
            % ...
        end

        %-----------------------------------------------------------------%
        function initialValues(app)
            % ...
        end

        %-----------------------------------------------------------------%
        % CÓDIGO LEGADO
        %-----------------------------------------------------------------%
        % function occParameters = play_OCCParameters(app)
        %     Method = app.play_OCC_Method.Value;
        % 
        %     switch Method
        %         case 'Linear fixo (COLETA)'
        %             occParameters = RF.Occupancy.Parameters(Method, app.play_OCC_IntegrationTimeCaptured.Value, str2double(app.play_OCC_THRCaptured.Value));
        %         case 'Linear fixo'
        %             occParameters = RF.Occupancy.Parameters(Method, str2double(app.play_OCC_IntegrationTime.Value), app.play_OCC_THR.Value);
        %         case {'Linear adaptativo', 'Envoltória do ruído'}
        %             occParameters = RF.Occupancy.Parameters(Method, str2double(app.play_OCC_IntegrationTime.Value), app.play_OCC_Offset.Value, app.play_OCC_noiseFcn.Value, app.play_OCC_noiseTrashSamples.Value/100, app.play_OCC_noiseUsefulSamples.Value/100, app.play_OCC_ceilFactor.Value);            
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function occIndex = play_OCCIndex(app, idx, srcFcn)
        %     arguments
        %         app
        %         idx
        %         srcFcn char {mustBeMember(srcFcn, {'PLAYBACK/REPORT', 'PLAYBACK', 'REPORT'})}
        %     end
        % 
        %     switch srcFcn
        %         case 'PLAYBACK/REPORT'
        %             if isempty(app.specData(idx).UserData.occCache)
        %                 occParameters = play_OCCParameters(app);
        %             else
        %                 occParameters = app.specData(idx).UserData.reportAlgorithms.Occupancy;
        %             end
        %             play_OCCLayoutStartup(app, idx)
        % 
        %         case 'PLAYBACK'
        %             occParameters = play_OCCParameters(app);
        % 
        %         case 'REPORT'
        %             occParameters = app.specData(idx).UserData.reportAlgorithms.Occupancy;
        %     end
        % 
        %     occIndex = find(cellfun(@(x) isequal(x, occParameters), {app.specData(idx).UserData.occCache.Info}));
        % 
        %     if isempty(occIndex)
        %         occIndex = numel(app.specData(idx).UserData.occCache)+1;
        %         occTHR   = RF.Occupancy.Threshold(occParameters.Method, occParameters, app.specData(idx), app.play_OCC_Orientation.Value);
        % 
        %         switch occParameters.Method
        %             case 'Linear fixo (COLETA)'
        %                 occData = app.specData(app.specData(idx).UserData.occMethod.SelectedIndex).Data;
        % 
        %             otherwise
        %                 update(app.specData(idx), 'UserData:OccupancyFields', 'SelectedIndex:Refresh')
        %                 occData = RF.Occupancy.run(app.specData(idx).Data{1}, app.specData(idx).Data{2}, occParameters.Method, occTHR, occParameters.IntegrationTime);
        %         end
        % 
        %         update(app.specData(idx), 'UserData:OccupancyFields', 'Cache:Add', occIndex, occParameters, occTHR, occData)
        %     end
        % 
        %     update(app.specData(idx), 'UserData:OccupancyFields', 'CacheIndex:Edit', occIndex)
        % end
        % 
        % %-----------------------------------------------------------------%
        % function selectedTreeNode = play_OCCSelectedTreeNode(app, idx)
        %     selectedTreeNode = [];
        %     for ii = 1:numel(app.play_Tree.Children)
        %         for jj = 1:numel(app.play_Tree.Children(ii).Children)
        %             if app.play_Tree.Children(ii).Children(jj).NodeData == idx
        %                 selectedTreeNode = app.play_Tree.Children(ii).Children(jj);
        %                 break
        %             end
        %         end
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function play_OCCSelectedTreeNodeIconUpdate(app, idx1)
        % 
        %     selectedTreeNode = play_OCCSelectedTreeNode(app, idx1);
        % 
        %     switch app.play_OCC_Method.Value
        %         case 'Linear fixo (COLETA)'
        %             idx2 = find(strcmp(app.play_OCC_THRCaptured.Items, app.play_OCC_THRCaptured.Value), 1);
        %             if isempty(app.specData(idx1).UserData.occMethod.SelectedIndex) || (app.specData(idx1).UserData.occMethod.SelectedIndex ~= app.specData(idx1).UserData.occMethod.RelatedIndex(idx2))
        %                 update(app.specData(idx1), 'UserData:OccupancyFields', 'SelectedIndex:Edit', app.specData(idx1).UserData.occMethod.RelatedIndex(idx2))
        %             end                    
        % 
        %         otherwise
        %             if ~isempty(app.specData(idx1).UserData.occMethod.RelatedIndex)
        %                 update(app.specData(idx1), 'UserData:OccupancyFields', 'SelectedIndex:Refresh')
        %                 idx2 = numel(selectedTreeNode.Children(end).Children);
        %             end
        %     end
        % 
        %     if exist('idx2', 'var')
        %         set(selectedTreeNode.Children(end).Children, Icon='')
        %         selectedTreeNode.Children(end).Children(idx2).Icon = 'modeSelected_32.png';
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function play_OCCNewPlot(app)
        %     if ~isempty(app.play_PlotPanel.UserData) && isvalid(app.play_PlotPanel.UserData)
        %         idx = app.play_PlotPanel.UserData.NodeData;
        % 
        %         % Layout
        %         play_OCCSelectedTreeNodeIconUpdate(app, idx)
        %         if strcmp(app.play_OCC_Method.Value, 'Linear fixo (COLETA)')
        %             idxOCC = app.specData(idx).UserData.occMethod.SelectedIndex;
        % 
        %             app.play_OCC_THRCaptured.Value = num2str(app.specData(idxOCC).MetaData.Threshold);
        %             app.play_OCC_IntegrationTimeCaptured.Value = mean(app.specData(idxOCC).RelatedFiles.RevisitTime)/60;
        %         end
        %         play_OCCLayoutVisibility(app, app.bandObj.LevelUnit)
        % 
        %         % Ao trocar qualquer um dos parâmetros relacionados aos métodos
        %         % de ocupação embarcados no appAnalise, afere-se, novamente, a
        %         % ocupação por bin. Isso, contudo, somente ocorre se estiver
        %         % habilitado o botão de ocupação, deixando visível o resultado
        %         % no app.axes2.
        % 
        %         % Ao inserir um fluxo de espectro para compor o relatório, será
        %         % definido um método de aferição de ocupação, caso ainda não
        %         % feita nenhuma simulação. Neste caso, a alteração dos parâmetros 
        %         % também irão refletir no algoritmo que será aplicado para fins
        %         % de geração do relatório.
        % 
        %         if app.axesTool_Occupancy.UserData.Value
        %             % Aferição da ocupação (armazenada no campo "occCache" da 
        %             % propriedade "UserData" de app.specData).
        %             occIndex = play_OCCIndex(app, idx, 'PLAYBACK');
        % 
        %             % Avalia se o fluxo que está sendo alterado foi incluído no
        %             % modo relatório e este é exatamente o fluxo selecionado.
        %             if app.specData(idx).UserData.reportFlag
        %                 update(app.specData(idx), 'UserData:ReportFields', 'ReportOCC:Edit', app.specData(idx).UserData.occCache(occIndex).Info)
        % 
        %                 idxOCC = [];
        %                 if ~isempty(app.play_Tree.SelectedNodes)
        %                     idxOCC = unique([app.play_Tree.SelectedNodes.NodeData]);
        %                 end
        % 
        %                 report_Algorithms(app, idxOCC)
        %             end
        % 
        %             % Plot                    
        %             plot.old_OCC(app, idx, 'Creation', occIndex)
        %         end
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function play_OCCLayoutStartup(app, idx)        
        %     % Ajuste dos itens de app.play_OCC_Method, o qual depende da existência
        %     % de fluxos de ocupação relacionados aos fluxos de espectro. Lembrando
        %     % que atualmente os fluxos de ocupação são aqueles gerados pelo Logger.
        %     if isempty(app.specData(idx).UserData.occMethod.RelatedIndex)
        %         app.play_OCC_Method.Items      = {'Linear fixo', 'Linear adaptativo', 'Envoltória do ruído'};
        %         app.play_OCC_THRCaptured.Items = {};        
        %     else
        %         app.play_OCC_Method.Items      = {'Linear fixo (COLETA)', 'Linear fixo', 'Linear adaptativo', 'Envoltória do ruído'};
        %         app.play_OCC_THRCaptured.Items = arrayfun(@(x) num2str(x.MetaData.Threshold), app.specData(app.specData(idx).UserData.occMethod.RelatedIndex), 'UniformOutput', false);
        %     end        
        % 
        %     % Caso não esteja habilitado o botão de ocupação, então o painel de
        %     % ocupação é desabilitado. Se o fluxo de espectro possui habilitado a 
        %     % customização do playback, então os campos de todos os principais painéis 
        %     % (Persistência, Ocupação e Waterfall) serão atualizados em 
        %     % "layoutFcn.customPlayback".
        %     % Caso essa funcionalidade não tenha sido habilitada, é necessária
        %     % atualizadar os valores do painel de Ocupação.
        %     if app.axesTool_Occupancy.Enable
        %         play_OCCLayoutUpdate(app, idx)
        %         play_OCCLayoutVisibility(app, app.specData(idx).MetaData.LevelUnit)        
        %     else
        %         hComponents = findobj(app.play_OCCGrid, '-not', {'Type', 'uilabel', '-or', 'Type', 'uigrid', '-or', 'Type', 'uipanel'});
        %         set(hComponents, Enable=0)
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function play_OCCLayoutUpdate(app, idx)        
        %     if isempty(app.specData(idx).UserData.occMethod.CacheIndex)
        %         SelectedIndex = app.specData(idx).UserData.occMethod.SelectedIndex;
        % 
        %         if ~isempty(SelectedIndex)
        %             app.play_OCC_Method.Value                  = 'Linear fixo (COLETA)';
        %             app.play_OCC_IntegrationTimeCaptured.Value = mean(app.specData(SelectedIndex).RelatedFiles.RevisitTime)/60;
        %             app.play_OCC_THRCaptured.Value             = num2str(app.specData(SelectedIndex).MetaData.Threshold);
        %         end        
        %     else
        %         occIndex = app.specData(idx).UserData.occMethod.CacheIndex;
        %         occInfo  = app.specData(idx).UserData.occCache(occIndex).Info;
        % 
        %         app.play_OCC_Method.Value = occInfo.Method;
        % 
        %         switch occInfo.Method
        %             case 'Linear fixo (COLETA)'
        %                 app.play_OCC_IntegrationTimeCaptured.Value = occInfo.IntegrationTimeCaptured;
        %                 app.play_OCC_THRCaptured.Value             = num2str(occInfo.THRCaptured);
        % 
        %             case 'Linear fixo'
        %                 app.play_OCC_IntegrationTime.Value         = num2str(occInfo.IntegrationTime);
        %                 app.play_OCC_THR.Value                     = occInfo.THR;
        % 
        %             otherwise % 'Linear adaptativo' | 'Envoltória do ruído'            
        %                 app.play_OCC_IntegrationTime.Value         = num2str(occInfo.IntegrationTime);
        %                 app.play_OCC_Offset.Value                  = occInfo.Offset;
        %                 app.play_OCC_noiseFcn.Value                = occInfo.noiseFcn;
        %                 app.play_OCC_noiseTrashSamples.Value       = 100 * occInfo.noiseTrashSamples;
        %                 app.play_OCC_noiseUsefulSamples.Value      = 100 * occInfo.noiseUsefulSamples;
        % 
        %                 if strcmp(occInfo.Method, 'Envoltória do ruído')
        %                     app.play_OCC_ceilFactor.Value          = occInfo.ceilFactor;
        %                 end
        %         end
        %     end
        % end
        % 
        % %-----------------------------------------------------------------%
        % function play_OCCLayoutVisibility(app, LevelUnit)
        %     hComponents = findobj(app.play_OCCGrid, '-not', {'Type', 'uilabel', '-or', 'Type', 'uigrid', '-or', 'Type', 'uipanel'});
        %     set(hComponents, Enable=1)
        % 
        %     switch app.play_OCC_Method.Value
        %         case 'Linear fixo (COLETA)'
        %             set(app.play_OCC_IntegrationTime,         Visible=0, Enable=0)
        %             set(app.play_OCC_IntegrationTimeCaptured, Visible=1)
        % 
        %             set(app.play_OCC_THRLabel,        Visible=1)
        %             set(app.play_OCC_THR,             Visible=0)
        %             set(app.play_OCC_THRCaptured,     Visible=1)
        % 
        %             set(app.play_OCC_OffsetLabel,     Visible=0)
        %             set(app.play_OCC_Offset,          Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_ceilFactorLabel, Visible=0)
        %             set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_noiseLabel,      Visible=0)
        %             set(app.play_OCC_noisePanel,      Visible=0)
        %             set(findobj(app.play_OCC_noiseGrid.Children, '-not', 'Type', 'uilabel'), Enable=0)
        % 
        %             play_OCCLayoutVisibilityUpdate(app, LevelUnit)
        % 
        %         case 'Linear fixo'
        %             set(app.play_OCC_IntegrationTime,         Visible=1)
        %             set(app.play_OCC_IntegrationTimeCaptured, Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_THRLabel,        Visible=1)
        %             set(app.play_OCC_THR,             Visible=1)
        %             set(app.play_OCC_THRCaptured,     Visible=0)
        % 
        %             set(app.play_OCC_OffsetLabel,     Visible=0)
        %             set(app.play_OCC_Offset,          Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_ceilFactorLabel, Visible=0)
        %             set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_noiseLabel,      Visible=0)
        %             set(app.play_OCC_noisePanel,      Visible=0)
        %             set(findobj(app.play_OCC_noiseGrid.Children, '-not', 'Type', 'uilabel'), Enable=0)
        % 
        %             play_OCCLayoutVisibilityUpdate(app, LevelUnit)
        % 
        %         otherwise % {'Linear adaptativo', 'Envoltória do ruído adaptativo'}
        %             set(app.play_OCC_IntegrationTime,         Visible=1)
        %             set(app.play_OCC_IntegrationTimeCaptured, Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_THRLabel,    Visible=0)
        %             set(app.play_OCC_THR,         Visible=0, Enable=0)
        %             set(app.play_OCC_THRCaptured, Visible=0, Enable=0)
        % 
        %             set(app.play_OCC_OffsetLabel, Visible=1)
        %             set(app.play_OCC_Offset,      Visible=1)
        % 
        %             set(app.play_OCC_noiseLabel,  Visible=1)
        %             set(app.play_OCC_noisePanel,  Visible=1)
        % 
        %             switch app.play_OCC_Method.Value
        %                 case'Linear adaptativo'
        %                     set(app.play_OCC_ceilFactorLabel, Visible=0)
        %                     set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)
        % 
        %                 case 'Envoltória do ruído'
        %                     set(app.play_OCC_ceilFactorLabel, Visible=1)
        %                     set(app.play_OCC_ceilFactor,      Visible=1)
        %             end
        %     end
        % end        
        % 
        % %-------------------------------------------------------------------------%
        % function play_OCCLayoutVisibilityUpdate(app, LevelUnit)        
        %     app.play_OCC_THRLabel.Text = sprintf('Valor (%s):', LevelUnit);
        % 
        %     switch LevelUnit
        %         case 'dBm'
        %             if app.play_OCC_THR.Value > 0                            
        %                 app.play_OCC_THR.Value = -80;
        %             end        
        %         case 'dBµV'
        %             if app.play_OCC_THR.Value < 0
        %                 app.play_OCC_THR.Value = 27;
        %             end
        %         case 'dBµV/m'
        %             if app.play_OCC_THR.Value < 0
        %                 app.play_OCC_THR.Value = 40;
        %             end
        %     end
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

        % Button pushed function: AddChannelButton
        function ButtonPushed(app, event)

            specData = app.callingApp.bandObj.SpecData;
            % ...

        end

        % Callback function
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

            % Create AddChannelButton
            app.AddChannelButton = uibutton(app.GridLayout, 'push');
            app.AddChannelButton.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.AddChannelButton.Icon = 'Add_16.png';
            app.AddChannelButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.AddChannelButton.Layout.Row = 4;
            app.AddChannelButton.Layout.Column = 2;
            app.AddChannelButton.Text = 'Incluir';

            % Create play_OCC_Panel
            app.play_OCC_Panel = uipanel(app.GridLayout);
            app.play_OCC_Panel.AutoResizeChildren = 'off';
            app.play_OCC_Panel.BackgroundColor = [1 1 1];
            app.play_OCC_Panel.Layout.Row = [2 3];
            app.play_OCC_Panel.Layout.Column = [1 2];

            % Create play_OCCGrid
            app.play_OCCGrid = uigridlayout(app.play_OCC_Panel);
            app.play_OCCGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.play_OCCGrid.RowHeight = {17, 22, 17, 22, 17, '1x'};
            app.play_OCCGrid.RowSpacing = 5;
            app.play_OCCGrid.Padding = [10 10 10 5];
            app.play_OCCGrid.BackgroundColor = [1 1 1];

            % Create play_OCC_MethodLabel
            app.play_OCC_MethodLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_MethodLabel.VerticalAlignment = 'bottom';
            app.play_OCC_MethodLabel.FontSize = 10;
            app.play_OCC_MethodLabel.Layout.Row = 1;
            app.play_OCC_MethodLabel.Layout.Column = [1 2];
            app.play_OCC_MethodLabel.Text = 'Tipo de threshold:';

            % Create play_OCC_Method
            app.play_OCC_Method = uidropdown(app.play_OCCGrid);
            app.play_OCC_Method.Items = {'Linear fixo (COLETA)', 'Linear fixo', 'Linear adaptativo', 'Envoltória do ruído'};
            app.play_OCC_Method.FontSize = 11;
            app.play_OCC_Method.BackgroundColor = [1 1 1];
            app.play_OCC_Method.Layout.Row = 2;
            app.play_OCC_Method.Layout.Column = [1 2];
            app.play_OCC_Method.Value = 'Linear fixo (COLETA)';

            % Create play_OCC_IntegrationTimeLabel
            app.play_OCC_IntegrationTimeLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_IntegrationTimeLabel.VerticalAlignment = 'bottom';
            app.play_OCC_IntegrationTimeLabel.WordWrap = 'on';
            app.play_OCC_IntegrationTimeLabel.FontSize = 10;
            app.play_OCC_IntegrationTimeLabel.Layout.Row = 1;
            app.play_OCC_IntegrationTimeLabel.Layout.Column = 3;
            app.play_OCC_IntegrationTimeLabel.Text = 'Integração (min):';

            % Create play_OCC_IntegrationTime
            app.play_OCC_IntegrationTime = uidropdown(app.play_OCCGrid);
            app.play_OCC_IntegrationTime.Items = {'1', '5', '15', '30', '60', 'Inf'};
            app.play_OCC_IntegrationTime.Tag = 'Factor';
            app.play_OCC_IntegrationTime.FontSize = 11;
            app.play_OCC_IntegrationTime.BackgroundColor = [1 1 1];
            app.play_OCC_IntegrationTime.Layout.Row = 2;
            app.play_OCC_IntegrationTime.Layout.Column = 3;
            app.play_OCC_IntegrationTime.Value = '1';

            % Create play_OCC_OrientationLabel
            app.play_OCC_OrientationLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_OrientationLabel.VerticalAlignment = 'bottom';
            app.play_OCC_OrientationLabel.FontSize = 10;
            app.play_OCC_OrientationLabel.Layout.Row = 3;
            app.play_OCC_OrientationLabel.Layout.Column = 1;
            app.play_OCC_OrientationLabel.Text = 'Orientação:';

            % Create play_OCC_Orientation
            app.play_OCC_Orientation = uidropdown(app.play_OCCGrid);
            app.play_OCC_Orientation.Items = {'bin'};
            app.play_OCC_Orientation.FontSize = 11;
            app.play_OCC_Orientation.BackgroundColor = [1 1 1];
            app.play_OCC_Orientation.Layout.Row = 4;
            app.play_OCC_Orientation.Layout.Column = 1;
            app.play_OCC_Orientation.Value = 'bin';

            % Create play_OCC_THRLabel
            app.play_OCC_THRLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_THRLabel.Tag = 'THR';
            app.play_OCC_THRLabel.VerticalAlignment = 'bottom';
            app.play_OCC_THRLabel.WordWrap = 'on';
            app.play_OCC_THRLabel.FontSize = 10;
            app.play_OCC_THRLabel.Layout.Row = 3;
            app.play_OCC_THRLabel.Layout.Column = 2;
            app.play_OCC_THRLabel.Text = 'Valor (dBm):';

            % Create play_OCC_THR
            app.play_OCC_THR = uispinner(app.play_OCCGrid);
            app.play_OCC_THR.RoundFractionalValues = 'on';
            app.play_OCC_THR.ValueDisplayFormat = '%d';
            app.play_OCC_THR.Tag = 'THR';
            app.play_OCC_THR.FontSize = 11;
            app.play_OCC_THR.Layout.Row = 4;
            app.play_OCC_THR.Layout.Column = 2;
            app.play_OCC_THR.Value = -80;

            % Create play_OCC_THRCaptured
            app.play_OCC_THRCaptured = uidropdown(app.play_OCCGrid);
            app.play_OCC_THRCaptured.Items = {};
            app.play_OCC_THRCaptured.Tag = 'Factor';
            app.play_OCC_THRCaptured.Visible = 'off';
            app.play_OCC_THRCaptured.FontSize = 11;
            app.play_OCC_THRCaptured.BackgroundColor = [1 1 1];
            app.play_OCC_THRCaptured.Layout.Row = 4;
            app.play_OCC_THRCaptured.Layout.Column = 2;
            app.play_OCC_THRCaptured.Value = {};

            % Create play_OCC_OffsetLabel
            app.play_OCC_OffsetLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_OffsetLabel.Tag = 'Offset';
            app.play_OCC_OffsetLabel.VerticalAlignment = 'bottom';
            app.play_OCC_OffsetLabel.WordWrap = 'on';
            app.play_OCC_OffsetLabel.FontSize = 10;
            app.play_OCC_OffsetLabel.Visible = 'off';
            app.play_OCC_OffsetLabel.Layout.Row = 3;
            app.play_OCC_OffsetLabel.Layout.Column = 2;
            app.play_OCC_OffsetLabel.Text = 'OffSet (dB):';

            % Create play_OCC_Offset
            app.play_OCC_Offset = uispinner(app.play_OCCGrid);
            app.play_OCC_Offset.Limits = [3 30];
            app.play_OCC_Offset.RoundFractionalValues = 'on';
            app.play_OCC_Offset.ValueDisplayFormat = '%d';
            app.play_OCC_Offset.Tag = 'Offset';
            app.play_OCC_Offset.FontSize = 11;
            app.play_OCC_Offset.Visible = 'off';
            app.play_OCC_Offset.Layout.Row = 4;
            app.play_OCC_Offset.Layout.Column = 2;
            app.play_OCC_Offset.Value = 12;

            % Create play_OCC_ceilFactorLabel
            app.play_OCC_ceilFactorLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_ceilFactorLabel.Tag = 'Factor';
            app.play_OCC_ceilFactorLabel.VerticalAlignment = 'bottom';
            app.play_OCC_ceilFactorLabel.FontSize = 10;
            app.play_OCC_ceilFactorLabel.Visible = 'off';
            app.play_OCC_ceilFactorLabel.Layout.Row = 3;
            app.play_OCC_ceilFactorLabel.Layout.Column = 3;
            app.play_OCC_ceilFactorLabel.Text = 'Ceifamento:';

            % Create play_OCC_ceilFactor
            app.play_OCC_ceilFactor = uidropdown(app.play_OCCGrid);
            app.play_OCC_ceilFactor.Items = {'1𝜎', '2𝜎', '3𝜎'};
            app.play_OCC_ceilFactor.Tag = 'Factor';
            app.play_OCC_ceilFactor.Visible = 'off';
            app.play_OCC_ceilFactor.FontSize = 11;
            app.play_OCC_ceilFactor.BackgroundColor = [1 1 1];
            app.play_OCC_ceilFactor.Layout.Row = 4;
            app.play_OCC_ceilFactor.Layout.Column = 3;
            app.play_OCC_ceilFactor.Value = '1𝜎';

            % Create play_OCC_noiseLabel
            app.play_OCC_noiseLabel = uilabel(app.play_OCCGrid);
            app.play_OCC_noiseLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseLabel.FontSize = 10;
            app.play_OCC_noiseLabel.Visible = 'off';
            app.play_OCC_noiseLabel.Layout.Row = 5;
            app.play_OCC_noiseLabel.Layout.Column = [1 3];
            app.play_OCC_noiseLabel.Text = 'Parâmetros relacionados à estimativa do piso de ruído:';

            % Create play_OCC_noisePanel
            app.play_OCC_noisePanel = uipanel(app.play_OCCGrid);
            app.play_OCC_noisePanel.AutoResizeChildren = 'off';
            app.play_OCC_noisePanel.Visible = 'off';
            app.play_OCC_noisePanel.Layout.Row = 6;
            app.play_OCC_noisePanel.Layout.Column = [1 3];

            % Create play_OCC_noiseGrid
            app.play_OCC_noiseGrid = uigridlayout(app.play_OCC_noisePanel);
            app.play_OCC_noiseGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.play_OCC_noiseGrid.RowHeight = {17, 22};
            app.play_OCC_noiseGrid.RowSpacing = 4;
            app.play_OCC_noiseGrid.Padding = [10 10 10 5];
            app.play_OCC_noiseGrid.BackgroundColor = [1 1 1];

            % Create play_OCC_noiseFcnLabel
            app.play_OCC_noiseFcnLabel = uilabel(app.play_OCC_noiseGrid);
            app.play_OCC_noiseFcnLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseFcnLabel.FontSize = 10;
            app.play_OCC_noiseFcnLabel.Layout.Row = 1;
            app.play_OCC_noiseFcnLabel.Layout.Column = [1 2];
            app.play_OCC_noiseFcnLabel.Text = 'Função estatística:';

            % Create play_OCC_noiseFcn
            app.play_OCC_noiseFcn = uidropdown(app.play_OCC_noiseGrid);
            app.play_OCC_noiseFcn.Items = {'mean', 'median'};
            app.play_OCC_noiseFcn.FontSize = 11;
            app.play_OCC_noiseFcn.BackgroundColor = [1 1 1];
            app.play_OCC_noiseFcn.Layout.Row = 2;
            app.play_OCC_noiseFcn.Layout.Column = 1;
            app.play_OCC_noiseFcn.Value = 'mean';

            % Create play_OCC_noiseTrashSamplesLabel
            app.play_OCC_noiseTrashSamplesLabel = uilabel(app.play_OCC_noiseGrid);
            app.play_OCC_noiseTrashSamplesLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseTrashSamplesLabel.WordWrap = 'on';
            app.play_OCC_noiseTrashSamplesLabel.FontSize = 10;
            app.play_OCC_noiseTrashSamplesLabel.Layout.Row = 1;
            app.play_OCC_noiseTrashSamplesLabel.Layout.Column = [2 3];
            app.play_OCC_noiseTrashSamplesLabel.Text = 'Descartadas (%):';

            % Create play_OCC_noiseTrashSamples
            app.play_OCC_noiseTrashSamples = uispinner(app.play_OCC_noiseGrid);
            app.play_OCC_noiseTrashSamples.Limits = [0 10];
            app.play_OCC_noiseTrashSamples.FontSize = 11;
            app.play_OCC_noiseTrashSamples.Layout.Row = 2;
            app.play_OCC_noiseTrashSamples.Layout.Column = 2;

            % Create play_OCC_noiseUsefulSamplesLabel
            app.play_OCC_noiseUsefulSamplesLabel = uilabel(app.play_OCC_noiseGrid);
            app.play_OCC_noiseUsefulSamplesLabel.VerticalAlignment = 'bottom';
            app.play_OCC_noiseUsefulSamplesLabel.WordWrap = 'on';
            app.play_OCC_noiseUsefulSamplesLabel.FontSize = 10;
            app.play_OCC_noiseUsefulSamplesLabel.Layout.Row = 1;
            app.play_OCC_noiseUsefulSamplesLabel.Layout.Column = 3;
            app.play_OCC_noiseUsefulSamplesLabel.Text = 'Úteis (%):';

            % Create play_OCC_noiseUsefulSamples
            app.play_OCC_noiseUsefulSamples = uispinner(app.play_OCC_noiseGrid);
            app.play_OCC_noiseUsefulSamples.Limits = [10 90];
            app.play_OCC_noiseUsefulSamples.FontSize = 11;
            app.play_OCC_noiseUsefulSamples.Layout.Row = 2;
            app.play_OCC_noiseUsefulSamples.Layout.Column = 3;
            app.play_OCC_noiseUsefulSamples.Value = 20;

            % Create play_OCC_IntegrationTimeCaptured
            app.play_OCC_IntegrationTimeCaptured = uieditfield(app.play_OCCGrid, 'numeric');
            app.play_OCC_IntegrationTimeCaptured.Limits = [0 Inf];
            app.play_OCC_IntegrationTimeCaptured.ValueDisplayFormat = '%.0f';
            app.play_OCC_IntegrationTimeCaptured.Editable = 'off';
            app.play_OCC_IntegrationTimeCaptured.HorizontalAlignment = 'left';
            app.play_OCC_IntegrationTimeCaptured.FontSize = 11;
            app.play_OCC_IntegrationTimeCaptured.Visible = 'off';
            app.play_OCC_IntegrationTimeCaptured.Layout.Row = 2;
            app.play_OCC_IntegrationTimeCaptured.Layout.Column = 3;

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
