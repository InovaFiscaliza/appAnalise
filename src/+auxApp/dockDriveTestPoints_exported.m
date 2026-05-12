classdef dockDriveTestPoints_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        OkButton                     matlab.ui.control.Button
        RadioGroup                   matlab.ui.container.ButtonGroup
        PeaksMinDistanceMeters       matlab.ui.control.Spinner
        PeaksMinDistanceMetersLabel  matlab.ui.control.Label
        PeaksCount                   matlab.ui.control.Spinner
        PeaksCountLabel              matlab.ui.control.Label
        PeaksDataSource              matlab.ui.control.DropDown
        PeaksDataSourceLabel         matlab.ui.control.Label
        PeaksOption                  matlab.ui.control.RadioButton
        StationMaxDistanceKm         matlab.ui.control.NumericEditField
        StationMaxDistanceKmLabel    matlab.ui.control.Label
        StationTypeValue             matlab.ui.control.EditField
        StationType                  matlab.ui.control.DropDown
        StationTypeLabel             matlab.ui.control.Label
        StationOption                matlab.ui.control.RadioButton
        Title                        matlab.ui.control.Label
        TitleIcon                    matlab.ui.control.Image
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
        function [pointsIdxs, pointsCoordinates] = geoFindPeaks(app, dataSource, numMaxPeaks, maxCoLocationPeaksDistanceKm)
            pointsIdxs = [];
            pointsCoordinates = [];

            flowIdx = app.inputArgs.flowIdx;
            specData = app.mainApp.specData(flowIdx);
            emissionIdx = app.inputArgs.emissionIdx;
            driveTestAttributes = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest;

            switch dataSource
                case 'Dados brutos'
                    srcTable = driveTestAttributes.Measures.filtered;
                
                otherwise % 'Processados'
                    srcTable = driveTestAttributes.Measures.binned;
            end

            [~, peakIdxs] = findpeaks(srcTable.ChannelPower, 'SortStr', 'descend');

            if ~isempty(peakIdxs)
                pointsIdxs = peakIdxs(1);

                for ii = 2:numel(peakIdxs)
                    if numel(pointsIdxs) >= numMaxPeaks
                        break
                    end

                    referenceCoordinates = srcTable{pointsIdxs, {'Latitude', 'Longitude'}};
                    pointsCoordinates = srcTable{peakIdxs(ii), {'Latitude', 'Longitude'}};
    
                    pointsDistance = deg2km(distance(referenceCoordinates, pointsCoordinates(end,:))); % em km
                    if all(pointsDistance >= maxCoLocationPeaksDistanceKm)
                        pointsIdxs(end+1) = peakIdxs(ii);
                    end
                end

                pointsCoordinates = round(srcTable{pointsIdxs, {'Latitude', 'Longitude'}}, 6);
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, flowIdx, emissionIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                app.inputArgs = struct('context', context, 'flowIdx', flowIdx, 'emissionIdx', emissionIdx);
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Selection changed function: RadioGroup
        function onRadioGroupSelectionChanged(app, event)
            
            switch app.RadioGroup.SelectedObject
                case app.StationOption
                    set(findobj(app.RadioGroup.Children, 'Tag', 'STATION'), 'Enable', 'on')
                    set(findobj(app.RadioGroup.Children, 'Tag', 'PEAKS'),   'Enable', 'off')

                otherwise % app.PeaksOption
                    set(findobj(app.RadioGroup.Children, 'Tag', 'STATION'), 'Enable', 'off')
                    set(findobj(app.RadioGroup.Children, 'Tag', 'PEAKS'),   'Enable', 'on')
            end

        end

        % Button pushed function: OkButton
        function onOkButtonClicked(app, event)
            
            flowIdx = app.inputArgs.flowIdx;
            specData = app.mainApp.specData(flowIdx);

            switch app.RadioGroup.SelectedObject
                case app.StationOption
                    entryText = strtrim(app.StationTypeValue.Value);
                    
                    if isempty(entryText)
                        return
                    end
                    
                    global RFDataHub

                    % Inicialmente, identificam-se os valores da lista
                    % de entrada.            
                    switch app.StationType.Value
                        case 'Índices de registros do RFDataHub'
                            pointsIdxs = regexp(entryText, '#(\d+)', 'tokens');

                            if isempty(pointsIdxs)
                                warningMsg = [ ...
                                    'Valor inválido!<br><br>Deve ser informada lista de IDs ' ...
                                    'dos registros do RFDataHub. Exemplo: #1000 #1500 #2000' ...
                                ];
                                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                                return
                            end

                            pointsIdxs = str2double([pointsIdxs{:}]);
                            pointsIdxs(pointsIdxs < 1 | pointsIdxs > height(RFDataHub)) = [];
        
                        otherwise % 'Lista de frequências (MHz)'
                            freqList = regexp(entryText, '(\d+[.]*\d*)', 'tokens');

                            if isempty(freqList)
                                warningMsg = [ ...
                                    'Valor inválido!<br><br>Deve ser informada lista de ' ...
                                    'frequências em MHz. Exemplo: 101.1, 101.3, 101.5' ...
                                ];
                                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                                return
                            end

                            freqList = cellfun(@(x) str2double(x), [freqList{:}]);

                            % Criada tabela, de forma que possa ser consumida função utilitária 
                            % de filtragem "util.TableFiltering".        
                            filterTempTable = table( ...
                                'Size', [0, 8], ...
                                'VariableTypes', {'cell', 'int8', 'int8', 'cell', 'cell', 'int8', 'cell', 'logical'}, ...
                                'VariableNames', {'Order', 'ID', 'RelatedID', 'Type', 'Operation', 'Column', 'Value', 'Enable'} ...
                            );
        
                            for ii = 1:numel(freqList)
                                if ii == 1
                                    order = 'Node';
                                    relatedID = -1;
                                else
                                    order = 'Child';
                                    relatedID = 1;
                                end

                                filterTempTable(ii,:) = {order, ii, relatedID, 'Frequência', '=', 1, {freqList(ii)}, true};
                            end

                            pointsIdxs = find(util.TableFiltering(RFDataHub, filterTempTable));
                    end

                    % Quais desses registros estão no entorno do local da monitoração?!
                    if ~isempty(pointsIdxs)
                        initialNumPoints = numel(pointsIdxs);

                        distanceArray = deg2km(distance( ...
                            RFDataHub.Latitude(pointsIdxs), RFDataHub.Longitude(pointsIdxs), ...
                            specData.GPS.Latitude, specData.GPS.Longitude) ...
                        );
                        pointsIdxs(distanceArray > app.StationMaxDistanceKm.Value) = [];
                        
                        finalNumPoints = numel(pointsIdxs);

                        if finalNumPoints > 0
                            logMsg = sprintf([ ...
                                'Foram identificadas %d estações de telecomunicações ' ...
                                'que atendem ao critério "%s".' ...
                            ], initialNumPoints, app.StationType.Value);

                            if finalNumPoints ~= initialNumPoints
                                logMsg = sprintf([ ...
                                    '%s Contudo, apenas %d atendem ao critério de ' ...
                                    'distância máxima em relação ao sensor.' ...
                                ], logMsg, finalNumPoints);
                            end

                            newRowType = 'RFDataHub';
                            newRowData = struct('source', app.StationType.Value, 'data', RFDataHub(pointsIdxs, setdiff(RFDataHub.Properties.VariableNames, {'ID', 'Description', '_Name', '_Location'})), 'dataIdx', pointsIdxs);
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'onDriveTestPointsAdded', newRowType, newRowData)

                        else
                            logMsg = 'Nenhuma estação de telecomunicações foi identificada para os critérios informados.';
                        end

                    else
                        logMsg = 'Nenhuma estação de telecomunicações foi identificada para os critérios informados.';
                    end

                otherwise % app.PeaksOption
                    [pointsIdxs, pointsCoordinates] = geoFindPeaks(app, app.PeaksDataSource.Value, app.PeaksCount.Value, app.PeaksMinDistanceMeters.Value/1000);
                    numPoints = numel(pointsIdxs);

                    newRowType = 'FindPeaks';
                    newRowData = struct('source', app.PeaksDataSource.Value, 'data', pointsCoordinates, 'dataIdx', pointsIdxs);
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onDriveTestPointsAdded', newRowType, newRowData)

                    logMsg = sprintf('Foram identificados %d pontos que atendem ao critério "%s".', numPoints, app.StationType.Value);
            end

            ui.Dialog(app.UIFigure, 'warning', logMsg);

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
                app.UIFigure.Position = [100 100 412 408];
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
            app.GridLayout.ColumnWidth = {18, 234, 110};
            app.GridLayout.RowHeight = {17, 5, 312, 10, 24};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TitleIcon
            app.TitleIcon = uiimage(app.GridLayout);
            app.TitleIcon.ScaleMethod = 'none';
            app.TitleIcon.Layout.Row = 1;
            app.TitleIcon.Layout.Column = 1;
            app.TitleIcon.ImageSource = 'Pin_18.png';

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.FontSize = 10;
            app.Title.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = 2;
            app.Title.Text = 'PONTOS DE INTERESSE';

            % Create RadioGroup
            app.RadioGroup = uibuttongroup(app.GridLayout);
            app.RadioGroup.AutoResizeChildren = 'off';
            app.RadioGroup.SelectionChangedFcn = createCallbackFcn(app, @onRadioGroupSelectionChanged, true);
            app.RadioGroup.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RadioGroup.BackgroundColor = [1 1 1];
            app.RadioGroup.Layout.Row = 3;
            app.RadioGroup.Layout.Column = [1 3];
            app.RadioGroup.FontWeight = 'bold';
            app.RadioGroup.FontSize = 10;

            % Create StationOption
            app.StationOption = uiradiobutton(app.RadioGroup);
            app.StationOption.Text = {'<b>ESTAÇÕES DE TELECOMUNICAÇÕES</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona estações incluídas no RFDataHub.</font>'};
            app.StationOption.FontSize = 11;
            app.StationOption.Interpreter = 'html';
            app.StationOption.Position = [11 267 278 31];
            app.StationOption.Value = true;

            % Create StationTypeLabel
            app.StationTypeLabel = uilabel(app.RadioGroup);
            app.StationTypeLabel.Tag = 'STATION';
            app.StationTypeLabel.VerticalAlignment = 'bottom';
            app.StationTypeLabel.FontSize = 11;
            app.StationTypeLabel.FontColor = [0.302 0.302 0.302];
            app.StationTypeLabel.Position = [30 246 181 17];
            app.StationTypeLabel.Text = 'Tipo de registro:';

            % Create StationType
            app.StationType = uidropdown(app.RadioGroup);
            app.StationType.Items = {'Lista de frequências (MHz)', 'Índices de registros do RFDataHub'};
            app.StationType.Tag = 'STATION';
            app.StationType.FontSize = 11;
            app.StationType.FontColor = [0.302 0.302 0.302];
            app.StationType.BackgroundColor = [1 1 1];
            app.StationType.Position = [30 219 330 22];
            app.StationType.Value = 'Lista de frequências (MHz)';

            % Create StationTypeValue
            app.StationTypeValue = uieditfield(app.RadioGroup, 'text');
            app.StationTypeValue.Tag = 'STATION';
            app.StationTypeValue.FontSize = 11;
            app.StationTypeValue.FontColor = [0.302 0.302 0.302];
            app.StationTypeValue.Tooltip = {'Exemplos:'; '• 101.1, 101.3, 101.5 (Lista de frequências)'; '• #1000 #1500 #2000 (RFDataHub)'};
            app.StationTypeValue.Position = [30 189 330 22];

            % Create StationMaxDistanceKmLabel
            app.StationMaxDistanceKmLabel = uilabel(app.RadioGroup);
            app.StationMaxDistanceKmLabel.Tag = 'STATION';
            app.StationMaxDistanceKmLabel.WordWrap = 'on';
            app.StationMaxDistanceKmLabel.FontSize = 11;
            app.StationMaxDistanceKmLabel.FontColor = [0.302 0.302 0.302];
            app.StationMaxDistanceKmLabel.Position = [30 155 221 28];
            app.StationMaxDistanceKmLabel.Text = 'Distância máxima entre estação e local da monitoração (km):';

            % Create StationMaxDistanceKm
            app.StationMaxDistanceKm = uieditfield(app.RadioGroup, 'numeric');
            app.StationMaxDistanceKm.Limits = [1 Inf];
            app.StationMaxDistanceKm.RoundFractionalValues = 'on';
            app.StationMaxDistanceKm.ValueDisplayFormat = '%d';
            app.StationMaxDistanceKm.Tag = 'STATION';
            app.StationMaxDistanceKm.FontSize = 11;
            app.StationMaxDistanceKm.FontColor = [0.302 0.302 0.302];
            app.StationMaxDistanceKm.Position = [262 160 98 22];
            app.StationMaxDistanceKm.Value = 30;

            % Create PeaksOption
            app.PeaksOption = uiradiobutton(app.RadioGroup);
            app.PeaksOption.Text = {'<b>POTÊNCIA DO CANAL</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.PeaksOption.WordWrap = 'on';
            app.PeaksOption.FontSize = 11;
            app.PeaksOption.Interpreter = 'html';
            app.PeaksOption.Position = [12 94 347 46];

            % Create PeaksDataSourceLabel
            app.PeaksDataSourceLabel = uilabel(app.RadioGroup);
            app.PeaksDataSourceLabel.Tag = 'PEAKS';
            app.PeaksDataSourceLabel.VerticalAlignment = 'bottom';
            app.PeaksDataSourceLabel.FontSize = 11;
            app.PeaksDataSourceLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksDataSourceLabel.Enable = 'off';
            app.PeaksDataSourceLabel.Position = [31 73 181 17];
            app.PeaksDataSourceLabel.Text = 'Fonte da informação:';

            % Create PeaksDataSource
            app.PeaksDataSource = uidropdown(app.RadioGroup);
            app.PeaksDataSource.Items = {'Dados brutos', 'Processados'};
            app.PeaksDataSource.Tag = 'PEAKS';
            app.PeaksDataSource.Enable = 'off';
            app.PeaksDataSource.FontSize = 11;
            app.PeaksDataSource.FontColor = [0.302 0.302 0.302];
            app.PeaksDataSource.BackgroundColor = [1 1 1];
            app.PeaksDataSource.Position = [31 46 220 22];
            app.PeaksDataSource.Value = 'Dados brutos';

            % Create PeaksCountLabel
            app.PeaksCountLabel = uilabel(app.RadioGroup);
            app.PeaksCountLabel.Tag = 'PEAKS';
            app.PeaksCountLabel.VerticalAlignment = 'bottom';
            app.PeaksCountLabel.FontSize = 11;
            app.PeaksCountLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksCountLabel.Enable = 'off';
            app.PeaksCountLabel.Position = [262 73 94 17];
            app.PeaksCountLabel.Text = 'Número de picos:';

            % Create PeaksCount
            app.PeaksCount = uispinner(app.RadioGroup);
            app.PeaksCount.Limits = [1 100];
            app.PeaksCount.RoundFractionalValues = 'on';
            app.PeaksCount.ValueDisplayFormat = '%.0f';
            app.PeaksCount.Tag = 'PEAKS';
            app.PeaksCount.FontSize = 11;
            app.PeaksCount.FontColor = [0.302 0.302 0.302];
            app.PeaksCount.Enable = 'off';
            app.PeaksCount.Position = [262 46 98 22];
            app.PeaksCount.Value = 1;

            % Create PeaksMinDistanceMetersLabel
            app.PeaksMinDistanceMetersLabel = uilabel(app.RadioGroup);
            app.PeaksMinDistanceMetersLabel.Tag = 'PEAKS';
            app.PeaksMinDistanceMetersLabel.FontSize = 11;
            app.PeaksMinDistanceMetersLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksMinDistanceMetersLabel.Enable = 'off';
            app.PeaksMinDistanceMetersLabel.Position = [31 14 204 22];
            app.PeaksMinDistanceMetersLabel.Text = 'Distância mínima entre picos (metros):';

            % Create PeaksMinDistanceMeters
            app.PeaksMinDistanceMeters = uispinner(app.RadioGroup);
            app.PeaksMinDistanceMeters.Step = 100;
            app.PeaksMinDistanceMeters.Limits = [0 10000];
            app.PeaksMinDistanceMeters.RoundFractionalValues = 'on';
            app.PeaksMinDistanceMeters.ValueDisplayFormat = '%.0f';
            app.PeaksMinDistanceMeters.Tag = 'PEAKS';
            app.PeaksMinDistanceMeters.FontSize = 11;
            app.PeaksMinDistanceMeters.FontColor = [0.302 0.302 0.302];
            app.PeaksMinDistanceMeters.Enable = 'off';
            app.PeaksMinDistanceMeters.Position = [262 14 98 22];
            app.PeaksMinDistanceMeters.Value = 1000;

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @onOkButtonClicked, true);
            app.OkButton.Icon = 'Add_16.png';
            app.OkButton.FontSize = 11;
            app.OkButton.Layout.Row = 5;
            app.OkButton.Layout.Column = 3;
            app.OkButton.Text = 'Incluir pontos';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockDriveTestPoints_exported(Container, varargin)

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
