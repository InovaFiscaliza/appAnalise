classdef dockDriveTestPoints_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        OkButton                 matlab.ui.control.Button
        RadioGroup               matlab.ui.container.ButtonGroup
        PeaksMinDistance         matlab.ui.control.Spinner
        PeaksMinDistanceLabel    matlab.ui.control.Label
        PeaksCount               matlab.ui.control.Spinner
        PeaksCountLabel          matlab.ui.control.Label
        PeaksDataSource          matlab.ui.control.DropDown
        PeaksDataSourceLabel     matlab.ui.control.Label
        PeaksOption              matlab.ui.control.RadioButton
        StationMaxDistance       matlab.ui.control.NumericEditField
        StationMaxDistanceLabel  matlab.ui.control.Label
        StationTypeValue         matlab.ui.control.EditField
        StationType              matlab.ui.control.DropDown
        StationTypeLabel         matlab.ui.control.Label
        StationOption            matlab.ui.control.RadioButton
        Title                    matlab.ui.control.Label
        TitleIcon                matlab.ui.control.Image
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
        function [pointsIdxs, pointsCoordinates] = geoFindPeaks(app, dataSource, numPeaks, minPeaksDistance)
            pointsIdxs = [];
            pointsCoordinates = [];

            switch dataSource
                case 'Dados brutos'
                    sourceData = app.callingApp.emissionPoints.raw;

                otherwise % 'Processados'
                    sourceData = app.callingApp.emissionPoints.binned;
            end

            [~, peakIdxs] = findpeaks(sourceData.ChannelPower, 'SortStr', 'descend');

            if ~isempty(peakIdxs)
                pointsIdxs = peakIdxs(1);

                for ii = 2:numel(peakIdxs)
                    if numel(pointsIdxs) >= numPeaks
                        break
                    end

                    referenceCoordinates = sourceData{pointsIdxs, {'Latitude', 'Longitude'}};
                    pointsCoordinates = sourceData{peakIdxs(ii), {'Latitude', 'Longitude'}};
    
                    pointsDistance = deg2km(distance(referenceCoordinates, pointsCoordinates(end,:))); % em km
                    if all(pointsDistance >= minPeaksDistance)
                        pointsIdxs(end+1) = peakIdxs(ii);
                    end
                end

                switch dataSource
                    case 'Dados brutos'
                        pointsCoordinates = sourceData{pointsIdxs, {'Latitude', 'Longitude'}};

                    otherwise % 'Processados'
                        pointsCoordinates = sourceData{pointsIdxs, {'Latitude', 'Longitude'}};
                end
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

        % Callback function
        function onButtonClicked(app, event)
            
            context = app.inputArgs.context;
            flowIdx = app.inputArgs.flowIdx;
            specData = app.mainApp.specData(flowIdx);
            emissionIdx = app.inputArgs.emissionIdx;

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
                                warningMsg = 'Valor inválido! Deve ser inserida lista de IDs dos registros do RFDataHub. Por exemplo: #1000 #1500 #2000';
                                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                                return
                            end
                            pointsIdxs = str2double([pointsIdxs{:}]);
                            pointsIdxs(pointsIdxs < 1 | pointsIdxs > height(RFDataHub)) = [];
        
                        otherwise % 'Lista de frequências (MHz)'
                            freqList = regexp(entryText, '(\d+[.]*\d*)', 'tokens');
                            if isempty(freqList)
                                warningMsg = 'Valor inválido! Deve ser inserida lista de frequências em MHz. Por exemplos: 101.1, 101.3, 101.5';
                                ui.Dialog(app.UIFigure, 'warning', warningMsg);
                                return
                            end
                            freqList = cellfun(@(x) str2double(x), [freqList{:}]);

                            % ## ToDo ##
                            % Criada tabela, de forma que possa ser consumida função utilitária 
                            % de filtragem "util.TableFiltering". Posteriormente, deve ser
                            % refatorado esse trecho, de forma que seja consumida a função
                            % "tableFiltering", do repo "SupportPackages".
        
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
                        pointsIdxs(distanceArray > app.StationMaxDistance.Value) = [];
                        
                        finalNumPoints = numel(pointsIdxs);

                        if finalNumPoints > 0
                            logMsg = sprintf('Identificada(s) %d estação(ões) de telecomunicações que atende(m) ao critério "%s".', initialNumPoints, app.StationType.Value);
                            if finalNumPoints ~= initialNumPoints
                                logMsg = sprintf('%s Contudo, apenas %d atende(m) ao critério de distância máxima ao sensor.', msgLOG, finalNumPoints);
                            end

                            newRow = {'RFDataHub', struct('Source', app.StationType.Value, 'idxData', pointsIdxs, 'Data', RFDataHub(pointsIdxs,:)), true};
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'onDriveTestPointsAdded', newRow)

                        else
                            logMsg = 'Não identificada estação de telecomunicações que atenda ao critério.';
                        end

                    else
                        logMsg = 'Não identificada estação de telecomunicações que atenda ao critério.';
                    end

                otherwise % app.PeaksOption
                    [pointsIdxs, pointsCoordinates] = geoFindPeaks(app, app.PeaksDataSource.Value, app.PeaksCount.Value, app.PeaksMinDistance.Value/1000);
                    numPoints = numel(pointsIdxs);

                    newRow = {'FindPeaks', struct('Source', app.PeaksDataSource.Value, 'idxData', pointsIdxs, 'Data', pointsCoordinates), true};
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'onDriveTestPointsAdded', newRow)

                    logMsg = sprintf('Identificado(s) %d ponto(s) que atende(m) ao critério.', numPoints);
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

            % Create StationMaxDistanceLabel
            app.StationMaxDistanceLabel = uilabel(app.RadioGroup);
            app.StationMaxDistanceLabel.Tag = 'STATION';
            app.StationMaxDistanceLabel.WordWrap = 'on';
            app.StationMaxDistanceLabel.FontSize = 11;
            app.StationMaxDistanceLabel.FontColor = [0.302 0.302 0.302];
            app.StationMaxDistanceLabel.Position = [30 155 221 28];
            app.StationMaxDistanceLabel.Text = 'Distância máxima entre estação e local da monitoração (km):';

            % Create StationMaxDistance
            app.StationMaxDistance = uieditfield(app.RadioGroup, 'numeric');
            app.StationMaxDistance.Limits = [1 Inf];
            app.StationMaxDistance.RoundFractionalValues = 'on';
            app.StationMaxDistance.ValueDisplayFormat = '%d';
            app.StationMaxDistance.Tag = 'STATION';
            app.StationMaxDistance.FontSize = 11;
            app.StationMaxDistance.FontColor = [0.302 0.302 0.302];
            app.StationMaxDistance.Position = [262 160 98 22];
            app.StationMaxDistance.Value = 30;

            % Create PeaksOption
            app.PeaksOption = uiradiobutton(app.RadioGroup);
            app.PeaksOption.Text = {'<b>POTÊNCIA DO CANAL</b>'; '<p style="font-size: 10px; color: gray; text-align: justify;">Adiciona locais em que o sensor captou o canal sob análise com seus maiores níveis de potência.</font>'};
            app.PeaksOption.WordWrap = 'on';
            app.PeaksOption.FontSize = 11;
            app.PeaksOption.Interpreter = 'html';
            app.PeaksOption.Position = [12 94 347 46];

            % Create PeaksDataSourceLabel
            app.PeaksDataSourceLabel = uilabel(app.RadioGroup);
            app.PeaksDataSourceLabel.Tag = 'PEAK';
            app.PeaksDataSourceLabel.VerticalAlignment = 'bottom';
            app.PeaksDataSourceLabel.FontSize = 11;
            app.PeaksDataSourceLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksDataSourceLabel.Enable = 'off';
            app.PeaksDataSourceLabel.Position = [31 73 181 17];
            app.PeaksDataSourceLabel.Text = 'Fonte da informação:';

            % Create PeaksDataSource
            app.PeaksDataSource = uidropdown(app.RadioGroup);
            app.PeaksDataSource.Items = {'Dados brutos', 'Processados'};
            app.PeaksDataSource.Tag = 'PEAK';
            app.PeaksDataSource.Enable = 'off';
            app.PeaksDataSource.FontSize = 11;
            app.PeaksDataSource.FontColor = [0.302 0.302 0.302];
            app.PeaksDataSource.BackgroundColor = [1 1 1];
            app.PeaksDataSource.Position = [31 46 220 22];
            app.PeaksDataSource.Value = 'Dados brutos';

            % Create PeaksCountLabel
            app.PeaksCountLabel = uilabel(app.RadioGroup);
            app.PeaksCountLabel.Tag = 'PEAK';
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
            app.PeaksCount.Tag = 'PEAK';
            app.PeaksCount.FontSize = 11;
            app.PeaksCount.FontColor = [0.302 0.302 0.302];
            app.PeaksCount.Enable = 'off';
            app.PeaksCount.Position = [262 46 98 22];
            app.PeaksCount.Value = 1;

            % Create PeaksMinDistanceLabel
            app.PeaksMinDistanceLabel = uilabel(app.RadioGroup);
            app.PeaksMinDistanceLabel.Tag = 'PEAK';
            app.PeaksMinDistanceLabel.FontSize = 11;
            app.PeaksMinDistanceLabel.FontColor = [0.302 0.302 0.302];
            app.PeaksMinDistanceLabel.Enable = 'off';
            app.PeaksMinDistanceLabel.Position = [31 14 204 22];
            app.PeaksMinDistanceLabel.Text = 'Distância mínima entre picos (metros):';

            % Create PeaksMinDistance
            app.PeaksMinDistance = uispinner(app.RadioGroup);
            app.PeaksMinDistance.Step = 100;
            app.PeaksMinDistance.Limits = [0 10000];
            app.PeaksMinDistance.RoundFractionalValues = 'on';
            app.PeaksMinDistance.ValueDisplayFormat = '%.0f';
            app.PeaksMinDistance.Tag = 'PEAK';
            app.PeaksMinDistance.FontSize = 11;
            app.PeaksMinDistance.FontColor = [0.302 0.302 0.302];
            app.PeaksMinDistance.Enable = 'off';
            app.PeaksMinDistance.Position = [262 14 98 22];
            app.PeaksMinDistance.Value = 1000;

            % Create OkButton
            app.OkButton = uibutton(app.GridLayout, 'push');
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
