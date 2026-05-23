classdef (Abstract) HtmlTextGenerator

    % ## util.HtmlTextGenerator (appAnalise) ##
    % PUBLIC
    %   ├── getAppInfo                    ⇐ winAppAnalise | auxApp.winConfig
    %   ├── getSelectedFileInfo           ⇐ winAppAnalise
    %   ├── getSelectedFlowMetadata       ⇐ auxApp.winPlayback
    %   ├── computeFlowAnalysis           ⇐ auxApp.winPlayback
    %   ├── getSelectedEmissionMetaData   ⇐ auxApp.winSignalAnalysis | auxApp.winDriveTest
    %   ├── checkEmissionEditConfirmation ⇐ auxApp.winPlayback
    %   ├── checkAvailableUpdate          ⇐ auxApp.winConfig
    %   ├── getStationInfo                ⇐ auxApp.winRFDataHub
    %   ├── issueDetails                  ⇐ winAppAnalise | auxApp.dockReportLib
    %   ├── entityDetails                 ⇐ auxApp.dockReportLib
    %   ├── createTag                     ⇐ auxApp.dockReportLib | auxApp.dockFlowMerge
    %   └── receiverStationDetails        ⇐ auxApp.winRepoSFI

    % PRIVATE
    %   ├── makeDisplayEntry
    %   ├── receiverBadge
    %   ├── monitoringTypeIcon
    %   ├── observationPeriod
    %   └── createEditHTMLLink

    properties (Constant)
        %-----------------------------------------------------------------%
        UNICODE_TO_HTML_HEX_MAP = struct( ...
            'Bullet',            struct('unicode', '•',  'html', '&#x2022;'), ...
            'Hourglass',         struct('unicode', '⌛', 'html', '&#x231B;'), ...
            'WhiteCircle',       struct('unicode', '⚪', 'html', '&#x26AA;'), ...
            'RedCircle',         struct('unicode', '🔴', 'html', '&#x1F534;'), ...
            'GreenCircle',       struct('unicode', '🟢', 'html', '&#x1F7E2;'), ...
            'ExclamationMark',   struct('unicode', '❗', 'html', '&#x2757;'), ...
            'PlusSign',          struct('unicode', '➕', 'html', '&#x2795;'), ...
            'ProhibitedSign',    struct('unicode', '🚫', 'html', '&#x1F6AB;'), ...
            'HierarchyArrow',    struct('unicode', '↳',  'html', '&#x21B3;'), ...
            'Pin',               struct('unicode', '📍', 'html', '&#x1F4CD;'), ...
            'Car',               struct('unicode', '🚗', 'html', '&#x1F697;'), ...
            'InterrogationMark', struct('unicode', '❓', 'html', '&#x2753;'), ...
            'Add',               struct('unicode', '➕', 'html', '&#10133;'), ...
            'Delete',            struct('unicode', '❌', 'html', '&#x274C;') ...
        )

        CHECKBOX_HTML = struct( ...
            'on',  '<table style="background-color: rgb(237, 237, 237); border-radius: 12px; height: 16px; width: 32px;"><tbody><tr><td></td><td style="background-color: rgb(76, 217, 100); border-radius: 50%;"></td></tr></tbody></table>', ...
            'off', '<table style="background-color: rgb(237, 237, 237); border-radius: 12px; height: 16px; width: 32px;"><tbody><tr><td style="background-color: rgb(150, 150, 150); border-radius: 50%;"></td><td></td></tr></tbody></table>' ...
        )

        MONITORING_TYPE_DICT = dictionary( ...
            ["fixed", "mobile", "undetermined"], ...
            ["FIXA", "MÓVEL", "INDETERMINADA"] ...
        )
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function htmlContent = getAppInfo(generalSettings, rootFolder, executionMode, renderCount, outputFormat)
            arguments
                generalSettings 
                rootFolder 
                executionMode 
                renderCount
                outputFormat char {mustBeMember(outputFormat, {'popup', 'textview'})} = 'textview'
            end

            global RFDataHub
            global RFDataHub_info

            appName = class.Constants.appName;
            appVersion = generalSettings.AppVersion;
            appURL = util.publicLink(appName, rootFolder, appName);
        
            switch executionMode
                case {'MATLABEnvironment', 'desktopStandaloneApp'}
                    appMode = 'desktopApp';  

                case 'webApp'
                    computerName = appEngine.util.OperationSystem('computerName');
                    if strcmpi(computerName, generalSettings.computerName.webServer)
                        appMode = 'webServer';
                    else
                        appMode = 'deployServer';                    
                    end
            end

            displayEntry = struct('group', 'COMPUTADOR', 'value', struct('Machine', rmfield(appVersion.machine, 'name'), 'Mode', sprintf('%s - %s', executionMode, appMode)));
            displayEntry(2) = struct('group', 'MATLAB', 'value', rmfield(appVersion.matlab, 'name'));
            if ~isempty(appVersion.browser)
                displayEntry(3) = struct('group', 'NAVEGADOR', 'value', rmfield(appVersion.browser, 'name'));
            end
            displayEntry(end+1) = struct('group', 'RENDERIZAÇÕES','value', renderCount);
            displayEntry(end+1) = struct('group', 'APLICATIVO', 'value', appVersion.application);
            displayEntry(end+1) = struct('group', 'RFDataHub', 'value', struct('releasedDate', RFDataHub_info.ReleaseDate, 'numberOfRows', height(RFDataHub), 'numberOfUniqueStations', numel(unique(RFDataHub.("Station")))));
        
            htmlIntro = sprintf('<font style="font-size: 12px;">O repositório das ferramentas desenvolvidas no Laboratório de inovação da SFI pode ser acessado <a href="%s" target="_blank">aqui</a>.</font>\n\n', appURL.Sharepoint);
            htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'print -1', htmlIntro, outputFormat);
        end

        %-----------------------------------------------------------------%
        function htmlContent = getSelectedFileInfo(metaData, fileIdx, varargin)
            if isscalar(fileIdx)
                flowIdxs = varargin{1};
                specData = metaData(fileIdx).Data(flowIdxs);

                displayEntry = util.HtmlTextGenerator.makeDisplayEntry( ...
                    'GERAL', ...
                    struct( ...
                        'File', metaData(fileIdx).File, ...
                        'Type', metaData(fileIdx).Type, ...
                        'nData', numel(flowIdxs), ...
                        'Memory', textFormatGUI.bytes2human(computeEstimatedMemory(specData)) ...
                    ) ...
                );

                if isscalar(specData)
                    [~, htmlIntro, tempDisplayEntry] = util.HtmlTextGenerator.getSelectedFlowMetadata(specData);
                    displayEntry = [displayEntry, tempDisplayEntry];

                else
                    receiverList = unique(arrayfun(@(x) x.Receiver, metaData(fileIdx).Data(flowIdxs), "UniformOutput", false));
                    receiverList = cellfun(@(x) util.layoutTreeNodeText(x, 'play_TreeBuilding'), receiverList, 'UniformOutput', false);
                    flowTag = strjoin(arrayfun(@(x) sprintf('%.3f – %.3f MHz', x.MetaData.FreqStart/1e+6, x.MetaData.FreqStop/1e+6), specData, "UniformOutput", false), '<br>');

                    htmlIntro = [ ...
                        strjoin(cellfun(@(r) [util.HtmlTextGenerator.receiverBadge(r) '<br>'], receiverList, 'UniformOutput', false), '') ...
                        sprintf('<br><font style="font-size: 16px;"><b>%s</b></font><br><br>', flowTag) ...
                    ];
                end

            else
                nodeData = varargin{1};
                specData = model.SpecData.empty;

                for ii = fileIdx
                    fileIdxs = ii == [nodeData.fileIdx];
                    flowIdxs = unique([nodeData(fileIdxs).flowIdx]);
                    for jj = flowIdxs
                        specData(end+1) = metaData(ii).Data(jj);
                    end
                end

                receiverList = unique({specData.Receiver});
                receiverList = cellfun(@(x) util.layoutTreeNodeText(x, 'play_TreeBuilding'), receiverList, 'UniformOutput', false);
                flowTag = strjoin(unique(arrayfun(@(x) sprintf('%.3f – %.3f MHz', x.MetaData.FreqStart/1e+6, x.MetaData.FreqStop/1e+6), specData, "UniformOutput", false), 'stable'), '<br>');

                displayEntry = util.HtmlTextGenerator.makeDisplayEntry( ...
                    'GERAL', ...
                    struct( ...
                        'File', textFormatGUI.cellstr2ListWithQuotes({metaData(fileIdx).File}), ...
                        'nData', numel(specData), ...
                        'Memory', textFormatGUI.bytes2human(computeEstimatedMemory(specData)) ...
                    ) ...
                );

                htmlIntro = [ ...
                    strjoin(cellfun(@(r) [util.HtmlTextGenerator.receiverBadge(r) '<br>'], receiverList, 'UniformOutput', false), '') ...
                    sprintf('<br><font style="font-size: 16px;"><b>%s</b></font><br><br>', flowTag) ...
                ];
            end

            htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'delete', htmlIntro);
        end

        %-----------------------------------------------------------------%
        function [htmlContent, htmlIntro, displayEntry] = getSelectedFlowMetadata(specData, appHandleNameInBase, generalSettings)
            arguments
                specData
                appHandleNameInBase = ''
                generalSettings = []
            end

            flowTag = util.HtmlTextGenerator.createTag('Flow', specData);
            observationPeriod = util.HtmlTextGenerator.observationPeriod(specData);
            description = sprintf('"%s"', specData.RelatedFiles.Description{1});

            % PARÂMETROS DE AQUISIÇÃO
            displayEntry = util.HtmlTextGenerator.makeDisplayEntry( ...
                'PARÂMETROS DE AQUISIÇÃO', ...
                rmfield(specData.MetaData, {'DataType'}) ...
            );

            % Tornando mais amigável apresentação de alguns dos metadados...
            displayEntry(1).value.FreqStart = sprintf('%d Hz', displayEntry(1).value.FreqStart);
            displayEntry(1).value.FreqStop  = sprintf('%d Hz', displayEntry(1).value.FreqStop);

            if specData.MetaData.Resolution ~= -1
                displayEntry(1).value.Resolution = sprintf('%.1f kHz', displayEntry(1).value.Resolution/1000);
            end

            if specData.MetaData.VBW ~= -1
                displayEntry(1).value.VBW = sprintf('%.3f kHz', displayEntry(1).value.VBW/1000);
            end

            % LOCAL DA MONITORAÇÃO
            monitoringTypeIcon = util.HtmlTextGenerator.monitoringTypeIcon(specData);
            initialAntennaHeight = calculateAntennaHeight(specData, 1, -1, 'initialValue');
            currentAntennaHeight = specData.UserData.AntennaHeightMeters;

            if isempty(currentAntennaHeight)
                currentAntennaHeight = initialAntennaHeight;
            end
            if abs(initialAntennaHeight - currentAntennaHeight) > 1e-1
                if initialAntennaHeight == -1
                    antennaHeight = sprintf('<font style="color: red;"><del>Desconhecida</del> → %d metros</font>', currentAntennaHeight);
                else
                    antennaHeight = sprintf('<font style="color: red;"><del>%d</del> → %d metros</font>', initialAntennaHeight, currentAntennaHeight);
                end

            else
                if currentAntennaHeight == -1
                    antennaHeight = '<font style="color: red;">Desconhecida</font>';
                else
                    antennaHeight = sprintf('%d metros', currentAntennaHeight);
                end
            end
            
            gpsSummaryToGui = struct( ...
                'GpsStatus', gpsLib.getGpsStatusLabel(specData.GPS.Status), ...
                'Count', specData.GPS.Count, ...
                'Latitude', sprintf('%.6f ± %.6f (1σ)', specData.GPS.Latitude, specData.GPS.Latitude_std), ...
                'Longitude', sprintf('%.6f ± %.6f (1σ)', specData.GPS.Longitude, specData.GPS.Longitude_std), ...
                'AntennaHeight', antennaHeight, ...
                'Location', sprintf('%s (Fonte: %s)', specData.GPS.Location, specData.GPS.LocationSource) ...
            );

            if specData.GPS.Status > 0 && strcmp(specData.GPS.LocationSource, 'Manual')
                gpsSummaryToGui.Location = sprintf('<font style="color: red;">%s</font>', gpsSummaryToGui.Location);
            elseif specData.GPS.Status == 0
                gpsSummaryToGui = rmfield(gpsSummaryToGui, 'Location');
            end

            displayEntry(2) = util.HtmlTextGenerator.makeDisplayEntry( ...
                'LOCAL DA MONITORAÇÃO', ...
                gpsSummaryToGui, ...
                util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onLocationEditRequested') ...
            );

            % HASH
            if ~isempty(specData.Hash)
                displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry( ...
                    'HASH', ...
                    specData.Hash ...
                );
            end

            % FONTE DA INFORMAÇÃO (links edição)
            infoSourceFilterIcon = 'filter.svg';
            if ~isempty(specData.UserData) && ~isempty(specData.UserData.LOG)
                infoSourceFilterIcon = 'filter-filled.svg';
            end
            
            infoSourceLink = util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onFilterRequested', '', 'link', infoSourceFilterIcon, 16, 16);
            if specData.IsUserModified
                infoSourceLink = [ ...
                    infoSourceLink ...
                    '&emsp;' ...
                    ui.TextView.createHTMLLink('customText', appHandleNameInBase, 'onFlowUnlockRequested', '', '<font style="font-size: 17px; color: black; transform: translateY(-2px);">&#x1F513;&#xFE0E;</font>') ...
                ];
            end

            displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry( ...
                'FONTE DA INFORMAÇÃO', ...
                struct( ...
                    'NumFiles', height(specData.RelatedFiles), ...
                    'NumSweeps', sum(specData.RelatedFiles.NumSweeps) ...
                ), ...
                infoSourceLink ...
            );

            for ii = 1:height(specData.RelatedFiles)
                displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry( ...
                    sprintf('#%d. %s', ii, specData.RelatedFiles.File{ii}), ...
                    struct( ...
                        'Id', specData.RelatedFiles.Id(ii), ...
                        'Task', sprintf('"%s"', specData.RelatedFiles.Task{ii}), ...
                        'Description', sprintf('"%s"', specData.RelatedFiles.Description{ii}), ...
                        'ObservationTime', sprintf('%s – %s', datestr(specData.RelatedFiles.BeginTime(ii), 'dd/mm/yyyy HH:MM:SS'), datestr(specData.RelatedFiles.EndTime(ii),   'dd/mm/yyyy HH:MM:SS')), ...
                        'NumSweeps', specData.RelatedFiles.NumSweeps(ii), ...
                        'RevisitTime', sprintf('%.3f segundos', specData.RelatedFiles.RevisitTime(ii)) ...
                    ) ...
                );
            end

            % LOG
            if ~isempty(specData.UserData) && ~isempty(specData.UserData.LOG)
                displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry( ...
                    'LOG', ...
                    textFormatGUI.cellstr2Bullets(specData.UserData.LOG) ...
                );
            end

            htmlIntro = [ ...
                util.HtmlTextGenerator.receiverBadge(util.layoutTreeNodeText(specData.Receiver, 'play_TreeBuilding')) '<br><br>' ...
                sprintf('<font style="font-size: 16px;"><b>%s</b></font><br>📃 %s<br>⌛ %s<br>%s %s<br><br>', flowTag, description, observationPeriod, monitoringTypeIcon, specData.GPS.Location) ...
            ];

            htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'delete', htmlIntro);
        end

        %-----------------------------------------------------------------%
        function htmlContent = computeFlowAnalysis(specData)
            freqStart = specData.MetaData.FreqStart;
            freqStop = specData.MetaData.FreqStop;
            resolution = specData.MetaData.Resolution;            
            traceMode = specData.MetaData.TraceMode;
            detector = specData.MetaData.Detector;
            levelUnit = specData.MetaData.LevelUnit;
            numPoints = specData.MetaData.DataPoints;
            numSweeps = sum(specData.RelatedFiles.NumSweeps);
            observationPeriod = util.HtmlTextGenerator.observationPeriod(specData);

            if resolution == -1
                stepWidth = (freqStop - freqStart) / (numPoints - 1);
                resolutionText = sprintf('passo de varredura igual a %.1f kHz', stepWidth/1000);
            else
                resolutionText = sprintf('resolução igual a %.1f kHz', resolution/1000);
            end

            switch traceMode
                case {'ClearWrite', 'Peak'}
                    traceModeText = sprintf([ ...
                        'O modo "%s" atualiza continuamente os dados da ' ...
                        'varredura, representando o comportamento ' ...
                        'instantâneo do espectro. É adequado para análise temporal, porém ' ...
                        'pode não evidenciar emissões esporádicas.' ...
                    ], traceMode);
                case 'Average'
                    traceModeText = sprintf([ ...
                        'O modo "%s" realiza média entre varreduras, ' ...
                        'proporcionando redução de flutuações e melhor estabilidade ' ...
                        'visual. Entretanto, pode atenuar picos rápidos e eventos transitórios.' ...
                    ], traceMode);
                case 'MaxHold'
                    traceModeText = sprintf([ ...
                        'O modo "%s" preserva os níveis máximos observados ' ...
                        'ao longo das varreduras, sendo eficaz na identificação de sinais ' ...
                        'intermitentes ou de baixa ocupação. Em contrapartida, tende a ' ...
                        'superestimar o nível médio do espectro e elevar artificialmente o piso visual.' ...
                    ], traceMode);
                case 'MinHold'
                    traceModeText = sprintf([ ...
                        'O modo "%s" registra os níveis mínimos medidos, ' ...
                        'sendo útil para estimativa do piso de ruído do ambiente. ' ...
                        'Contudo, pode mascarar emissões persistentes de baixa potência.' ...
                    ], traceMode);
                otherwise
                    traceModeText = '';
            end
            
            switch detector
                case {'Positive Peak', 'Peak'}
                    detectorText = sprintf([ ...
                        'O detector "%s" seleciona o maior valor dentro ' ...
                        'da banda de resolução, favorecendo a captura de picos rápidos, ' ...
                        'ainda que aumente a suscetibilidade a ruídos impulsivos.' ...
                    ], detector);
                case 'Negative Peak'
                    detectorText = sprintf([ ...
                        'O detector "%s" registra o menor valor dentro ' ...
                        'da banda de resolução, sendo aplicável na análise de piso de ruído, mas não ' ...
                        'representa adequadamente emissões intermitentes.' ...
                    ], detector);
                case {'Sample', 'Fast'}
                    detectorText = sprintf([ ...
                        'O detector "%s" registra o valor central da banda de resolução, ' ...
                        'oferecendo equilíbrio entre desempenho e representatividade estatística, ' ...
                        'com possibilidade de subestimação de picos.' ...
                    ], detector);
                case 'Average/RMS'
                    detectorText = sprintf([ ...
                        'O detector "%s" calcula valor médio do sinal, adequado para avaliação ' ...
                        'energética e conformidade normativa, embora suavize variações rápidas de amplitude.' ...
                    ], detector);
                otherwise
                    detectorText = '';
            end

            if ~isempty(detectorText)
                detectorText = sprintf('• Detector "%s". %s<br><br>', detector, detectorText);
            end

            switch levelUnit
                case {'dBm'}
                    levelUnitText = [ ...
                        'Os níveis espectrais estão expressos em dBm (potência referenciada a 1 mW). ' ...
                        'Para obtenção do campo elétrico equivalente (dBµV/m), é necessária a aplicação ' ...
                        'dos fatores de correção, incluindo fator de antena e perdas do sistema.' ...
                    ];
                case {'dBµV', 'dBμV'}
                    levelUnitText = [ ...
                        'Os níveis estão expressos em dBµV (tensão referenciada a 1 µV). ' ...
                        'A conversão para campo elétrico equivalente (dBµV/m) requer a aplicação ' ...
                        'dos fatores de correção, incluindo fator de antena e perdas do sistema.' ...
                    ];
                case {'dBµV/m', 'dBμV/m'}
                    levelUnitText = [ ...
                        'Os níveis estão expressos diretamente em dBµV/m, representando ' ...
                        'a intensidade de campo elétrico.' ...
                    ];
                otherwise
                    levelUnitText = '';
            end

            [monitoringType, radiusMeters] = gpsLib.classifyMonitoringType(specData.GPS);
            if isKey(util.HtmlTextGenerator.MONITORING_TYPE_DICT, monitoringType)
                monitoringType = util.HtmlTextGenerator.MONITORING_TYPE_DICT(monitoringType);
            end

            monitoringTypeText = sprintf([ ...
                'Com base na dispersão das coordenadas geográficas registradas ' ...
                'durante a monitoração, infere-se que se tratou de uma coleta "%s", ' ...
                'uma vez que o raio equivalente de dispersão foi igual a %.1f metros.' ...
            ], monitoringType, radiusMeters);
            
            htmlContent = sprintf([ ...
                '<p style="margin: 10px; word-break: normal;">Monitoração espectral ' ...
                'na faixa de %.3f MHz a %.3f MHz, com %s. A tarefa foi realizada no ' ...
                'período %s e englobou a coleta de %d varreduras.<br><br>' ...
                'Características da aquisição:<br>' ...
                '• Traço "%s". %s<br><br>%s' ...
                '• Unidade de medida "%s". %s<br><br>%s</p>' ...
            ], freqStart/1e+6, freqStop/1e+6, resolutionText, observationPeriod, numSweeps, traceMode, traceModeText, detectorText, levelUnit, levelUnitText, monitoringTypeText);
        end

        %-----------------------------------------------------------------%
        function varargout = getSelectedEmissionMetaData(specData, emissionIdx, context, appHandleNameInBase, generalSettings)
            arguments
                specData
                emissionIdx
                context {mustBeMember(context, {'SIGNALANALYSIS', 'DRIVETEST'})}
                appHandleNameInBase = ''
                generalSettings = []
            end

            if ~isempty(emissionIdx)
                emissionTable = specData.UserData.Emissions(emissionIdx, :);
                freqCenter    = emissionTable.Frequency;
                bandWidthkHz  = emissionTable.BandWidthkHz;
            else
                freqCenter    = (specData.MetaData.FreqStart + specData.MetaData.FreqStop)  / 2e6; % MHz
                bandWidthkHz  = (specData.MetaData.FreqStop  - specData.MetaData.FreqStart) / 1e3; % kHz
            end

            % TÍTULO
            flowTag = util.HtmlTextGenerator.createTag('Flow', specData);
            emissionTag = util.HtmlTextGenerator.createTag('Emission', freqCenter, bandWidthkHz);
            observationPeriod = util.HtmlTextGenerator.observationPeriod(specData);
            monitoringTypeIcon = util.HtmlTextGenerator.monitoringTypeIcon(specData);

            htmlIntro = [ ...
                util.HtmlTextGenerator.receiverBadge(util.layoutTreeNodeText(specData.Receiver, 'play_TreeBuilding')) '<br><br>' ...
                sprintf('<font style="font-size: 16px;"><b>%s</b></font><br>📶 %s<br>⌛ %s<br>%s %s<br><br>', emissionTag, flowTag, observationPeriod, monitoringTypeIcon, specData.GPS.Location) ...
            ];

            switch context
                case 'SIGNALANALYSIS'
                    emissionTable = specData.UserData.Emissions(emissionIdx, :);
                    emissionTag = util.HtmlTextGenerator.createTag('Emission', emissionTable.Frequency, emissionTable.BandWidthkHz);
        
                    % LOG
                    columnsToCompare = setdiff(fieldnames(util.Classification.RESULT_DEFAULT), 'Details', 'stable');
                    stationInfo = [];
                    columnsDiff = [];
        
                    for ii = 1:numel(columnsToCompare)
                        columnName = columnsToCompare{ii};
                        isNumeric = isnumeric(emissionTable.Classification.AutoSuggested.(columnName));
                        if isNumeric && abs(emissionTable.Classification.AutoSuggested.(columnName) - emissionTable.Classification.UserModified.(columnName)) > 1e-5 || ...
                          ~isNumeric && ~isequal(emissionTable.Classification.AutoSuggested.(columnName), emissionTable.Classification.UserModified.(columnName))
                            columnsDiff.(columnName) = sprintf('<del>%s</del> → <font style="color: red;">%s</font>', string(emissionTable.Classification.AutoSuggested.(columnName)), string(emissionTable.Classification.UserModified.(columnName)));
                        end
                        stationInfo.(columnName) = emissionTable.Classification.UserModified.(columnName);
                    end
        
                    if ~isempty(columnsDiff)
                        if isfield(columnsDiff, 'Regulatory') && stationInfo.Regulatory ~= "Licenciada"
                            columnsDiff.Regulatory = sprintf('<font style="color: red;">%s</font>', columnsDiff.Regulatory);
                        end
                    
                        if isfield(columnsDiff, 'Station') && stationInfo.Station == -1
                            columnsDiff.Station = sprintf('<font style="color: red;">%s</font>', columnsDiff.Station);
                        end
            
                        if isfield(columnsDiff, 'AntennaHeight') && stationInfo.AntennaHeight <= 0
                            columnsDiff.AntennaHeight = '<font style="color: red;">-1</font>';
                        end
                        
                        htmlContent2 = replace(sprintf('<p style="padding: 10px;">%s</p>', strtrim(textFormatGUI.structParser('', columnsDiff, 1))), newline, '<br>');
        
                    else
                        htmlContent2 = sprintf('<p style="padding: 10px;">%s</p>', 'Nenhuma alteração na classificação automática foi identificada.');
                    end
        
                    htmlContent1 = sprintf('<p style="padding-top: 3px;">%s</p>', htmlIntro);
                    varargout = {htmlContent1, htmlContent2, emissionTag, emissionTable.Description(1), emissionTable.Classification.UserModified};

                case 'DRIVETEST'
                    if ~isempty(emissionIdx)
                        % CANAL
                        channelAssigned = specData.UserData.Emissions(emissionIdx, :).ChannelAssigned;
                        channelInfo = [];
                        for channelField = ["Frequency", "ChannelBW"]
                            if isequal(channelAssigned.AutoSuggested.(channelField), channelAssigned.UserModified.(channelField))
                                channelInfo.(channelField) = formattedValue(channelField, channelAssigned.AutoSuggested.(channelField));
                            else
                                channelInfo.(channelField) = sprintf('<del>%s</del> → <font style="color: red;">%s</font>', formattedValue(channelField, channelAssigned.AutoSuggested.(channelField)), formattedValue(channelField, channelAssigned.UserModified.(channelField)));
                            end
                        end

                        % CLASSIFICAÇÃO        
                        classification = specData.UserData.Emissions(emissionIdx, :).Classification;
                        classificationInfo = [];                        
                        for classificationField = string(setdiff(fieldnames(util.Classification.RESULT_DEFAULT), 'Details', 'stable'))'
                            isNumeric = isnumeric(classification.AutoSuggested.(classificationField));
                            
                            if isNumeric && abs(classification.AutoSuggested.(classificationField) - classification.UserModified.(classificationField)) < 1e-5 || ...
                              ~isNumeric && isequal(classification.AutoSuggested.(classificationField), classification.UserModified.(classificationField))
                                classificationInfo.(classificationField) = classification.AutoSuggested.(classificationField);
                            else
                                classificationInfo.(classificationField) = sprintf('<del>%s</del> → <font style="color: red;">%s</font>', string(classification.AutoSuggested.(classificationField)), string(classification.UserModified.(classificationField)));                    
                            end
                        end
        
                        % MEDIDAS
                        measures = specData.UserData.Emissions(emissionIdx, :).Measures;
                        measuresInfo = struct( ...
                            'FreqCenterLevelRange', sprintf('%.1f a %.1f %s', measures.Level.FreqCenter_Min, measures.Level.FreqCenter_Max, specData.MetaData.LevelUnit), ...
                            'IntegratedEmissionLevelRange', sprintf('%.1f a %.1f %s (integração)', measures.Level.Channel_Min, measures.Level.Channel_Max, specData.MetaData.LevelUnit), ...
                            'FreqCenterCumulativeOccupancy', sprintf('%.1f%%', measures.FCO.FreqCenter_Infinite), ...                    
                            'EmissionCumulativeOccupancy', sprintf('%.1f%%', measures.FCO.Channel_Infinite) ...
                        );
        
                        % RELATÓRIO
                        if ~isempty(specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest) && specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest.ReportInclude
                            reportIncludeIcon = util.HtmlTextGenerator.CHECKBOX_HTML.on;
                            reportIncludeText = 'O plot desta emissão foi incluído para compor relatório de análise, caso previsto um dos plots suportados por este módulo.';
                        else
                            reportIncludeIcon = util.HtmlTextGenerator.CHECKBOX_HTML.off;
                            reportIncludeText = 'O plot desta emissão está restrito a este módulo.';
                        end
        
                        % TEXTO FORMATADO
                        displayEntry = struct('group', 'CANAL', 'value', channelInfo, 'link', util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onChannelEditRequested'));
                        displayEntry(2) = struct('group', 'CLASSIFICAÇÃO', 'value', classificationInfo, 'link', util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onClassificationEditRequested'));
                        displayEntry(3) = struct('group', 'MEDIDAS', 'value', measuresInfo,   'link', [ ...
                            util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onMeasurementsExportRequested', '', 'link', 'Export_16.png', 16, 16) ...
                            '&emsp;', ...
                            util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onMeasurementsDetailsRequested', '', 'question', 'info.svg') ...
                        ]);
                        displayEntry(4) = struct('group', 'RELATÓRIO', 'value', reportIncludeText, 'link', ui.TextView.createHTMLLink('customText', appHandleNameInBase, 'onReportIncludeRequested', '', reportIncludeIcon));

                    else
                        displayEntry = util.HtmlTextGenerator.makeDisplayEntry('INFO', 'Nenhuma emissão selecionada — toda a faixa monitorada está sendo tratada como uma emissão virtual');
                    end

                    htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'delete', htmlIntro);
                    varargout = {htmlContent};
            end

            function str = formattedValue(field, value)
                switch field
                    case 'Frequency'; str = sprintf('%.3f MHz', value);
                    case 'ChannelBW'; str = sprintf('%.1f kHz', value);
                end
            end
        end

        %-----------------------------------------------------------------%
        function htmlContent = checkEmissionEditConfirmation(specData, emissionIdx, stationInfo)
            % CLASSIFICAÇÃO AUTOMÁTICA
            autoValue = struct( ...
                'Regulatory', specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Regulatory, ...
                'Frequency', sprintf('%.3f MHz', specData.UserData.Emissions.Frequency(emissionIdx)) ...
            );

            if specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Regulatory == "Licenciada"
                autoValue.Description = specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Description;
                autoValue.Distance = sprintf('%.1f km', specData.UserData.Emissions.Classification(emissionIdx).AutoSuggested.Distance);
            end

            % CLASSIFICAÇÃO MANUAL
            switch stationInfo.Service
                case -1
                    emissionRegulatory = '<font style="color: #c94756;">Não Licenciada</font>';
                otherwise
                    emissionRegulatory = 'Licenciada';
            end

            manualValue = struct( ...
                'Regulatory',  emissionRegulatory, ...
                'Frequency', sprintf('%s MHz', stationInfo.Frequency), ...
                'Description', stationInfo.Description, ...
                'Distance', sprintf('%.1f km', stationInfo.Distance) ...
            );

            % TEXTO FORMATADO
            displayEntry = [ ...
                util.HtmlTextGenerator.makeDisplayEntry('INDICAÇÃO AUTOMÁTICA', autoValue), ...
                util.HtmlTextGenerator.makeDisplayEntry('MANUAL', manualValue) ...
            ];

            htmlContent = sprintf('%s<br><font style="font-size: 12px;">Confirma edição?<font>', textFormatGUI.struct2PrettyPrintList(displayEntry, "print -1", '', 'popup'));
        end

        %-----------------------------------------------------------------%
        function [htmlContent, stableVersion, updatedModule] = checkAvailableUpdate(generalSettings, rootFolder)
            stableVersion = [];
            updatedModule = {};
            
            try
                appName = class.Constants.appName;
                currentVersion = struct( ...
                    appName, generalSettings.AppVersion.application.version, ...
                    'rfDataHub', rmfield(generalSettings.AppVersion.database, 'name') ...
                );
                
                [versionFileURL, rfDataHubURL] = util.publicLink(appName, rootFolder, 'VersionFile+RFDataHub');        
                generalVersions = webread(versionFileURL,        weboptions("ContentType", "json"));
                rfdatahubVersion = webread(rfDataHubURL.Release, weboptions("ContentType", "json"));
        
                stableVersion = struct( ...
                    appName, generalVersions.(appName).Version, ...
                    'rfDataHub', rfdatahubVersion.rfdatahub ...
                );
                
                if isequal(currentVersion, stableVersion)
                    warningMsg = 'O appAnalise está atualizado.';
                    updatedModule = {'appAnalise', 'RFDataHub'};

                else
                    nonUpdatedModule = {};
                    if strcmp(currentVersion.(appName), stableVersion.(appName))
                        updatedModule(end+1)    = {'appAnalise'};
                    else
                        nonUpdatedModule(end+1) = {'appAnalise'};
                    end
        
                    if isequal(currentVersion.rfDataHub, stableVersion.rfDataHub)
                        updatedModule(end+1)    = {'RFDataHub'};
                    else
                        nonUpdatedModule(end+1) = {'RFDataHub'};
                    end
        
                    displayEntry = [ ...
                        util.HtmlTextGenerator.makeDisplayEntry('VERSÃO INSTALADA', currentVersion), ...
                        util.HtmlTextGenerator.makeDisplayEntry('VERSÃO ESTÁVEL', stableVersion), ...
                        util.HtmlTextGenerator.makeDisplayEntry('SITUAÇÃO', struct('updated', strjoin(updatedModule, ', '), 'nonupdated', strjoin(nonUpdatedModule, ', '))) ...
                    ];

                    warningMsg = textFormatGUI.struct2PrettyPrintList(displayEntry, "print -1", '', 'popup');
                end
                
            catch ME
                warningMsg = ME.message;
            end
        
            htmlContent = warningMsg;
        end

        %-----------------------------------------------------------------%
        function htmlContent = getStationInfo(rfDataHub, idxRFDataHub, rfDataHubLOG, generalSettings)
            % stationTag
            stationInfo    = table2struct(rfDataHub(idxRFDataHub,:));
            if stationInfo.BW <= 0
                stationTag = sprintf('%.3f MHz',            stationInfo.Frequency);
            else
                stationTag = sprintf('%.3f MHz ⌂ %.1f kHz', stationInfo.Frequency, stationInfo.BW);
            end
        
            % SERVIÇO
            global id2nameTable
            if isempty(id2nameTable)
                serviceOptions = generalSettings.eFiscaliza.defaultValues.servicos_da_inspecao.options;
                serviceIDs     = int16(str2double(extractBefore(serviceOptions, '-')));
                id2nameTable   = table(serviceIDs, serviceOptions, 'VariableNames', {'ID', 'Serviço'});
            end
            stationService = ws.eFiscaliza.serviceMapping(stationInfo.Service);
        
            [~, idxService] = ismember(stationInfo.Service, id2nameTable.ID);
            if idxService
                stationService = id2nameTable.("Serviço"){idxService};
            else
                stationService = num2str(stationService);
            end
        
            if strcmp(stationService, '-1')
                stationService = '<font style="color: red;">-1</font>';
            end
            
            % NÚMERO
            mergeCount = str2double(string(stationInfo.MergeCount));
            if stationInfo.Station == -1
                stationNumber = sprintf('<font style="color: red;">%d</font>', stationInfo.Station);
            else
                stationNumber = num2str(stationInfo.Station);
                if mergeCount > 1
                    stationNumber = sprintf('%s*', stationNumber);
                end
            end
        
            % LOCAL DE INSTALAÇÃO
            stationLocation = sprintf('(%.6fº, %.6fº)', stationInfo.Latitude, stationInfo.Longitude);
            stationHeight   = str2double(char(stationInfo.AntennaHeight));
            if stationHeight <= 0
                stationHeight = '<font style="color: red;">-1</font>';
            else
                stationHeight = sprintf('%.1fm', stationHeight);
            end    
        
            % LOG
            stationLOG = model.RFDataHub.queryLog(rfDataHubLOG, stationInfo.Log);
            if isempty(stationLOG)
                stationLOG = 'Registro não editado';
            end
        
            % TEXTO FORMATADO
            displayEntry = [ ...
                util.HtmlTextGenerator.makeDisplayEntry('Service', stationService), ...
                util.HtmlTextGenerator.makeDisplayEntry('Station', stationNumber), ...
                util.HtmlTextGenerator.makeDisplayEntry('Localização', stationLocation), ...
                util.HtmlTextGenerator.makeDisplayEntry('Altura', stationHeight) ...
            ];

            editedStationInfo = rmfield(stationInfo, { ...
                'AntennaPattern', 'BW', 'Description', 'Distance', 'Fistel', 'Frequency',     ...
                'ID', 'Latitude', 'LocationID', 'Location', 'Log', 'Longitude', 'MergeCount', ...
                'Name', 'Station', 'StationClass', 'Status', 'Service', 'Source', 'State', 'URL', 'x_Name', 'x_Location' ...
            });

            if any(cellfun(@(x) ~isequal(x, categorical(-1)), struct2cell(editedStationInfo)))
                displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry('OUTROS ASPECTOS TÉCNICOS', editedStationInfo);
            end

            if mergeCount > 1
                displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry('NÚMERO ESTAÇÕES AGRUPADAS', string(mergeCount));
            end
        
            try
                if isstruct(stationLOG) || ischar(stationLOG)
                    displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry('LOG', stationLOG);

                elseif iscell(stationLOG)
                    for ii = 1:numel(stationLOG)
                        displayEntry(end+1) = util.HtmlTextGenerator.makeDisplayEntry(sprintf('LOG #%d', ii), stationLOG{ii});
                    end
                end
            catch
            end
        
            htmlIntro = [ ...
                util.HtmlTextGenerator.receiverBadge(stationInfo.Source) ...
                sprintf('<span style="font-size: 10px; display: inline-block; vertical-align: sub; margin-left: 5px;">  ID %s</span><br><br>', stationInfo.ID) ...
                sprintf('<font style="font-size: 16px;"><b>%s</b></font><br>', stationTag) ...
                sprintf('<font style="font-size: 11px;">%s</font><br><br>', stationInfo.Description) ...
            ];

            htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'delete', htmlIntro);
        end

        %-----------------------------------------------------------------%
        function htmlContent = issueDetails(system, issue, details)
            displayEntry = util.HtmlTextGenerator.makeDisplayEntry('CADASTRO', details);
            htmlIntro = sprintf('<font style="font-size: 16px;"><b>Atividade de Inspeção #%d</b></font> %s<br><br>', issue, system);
            htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'print -1', htmlIntro, 'popup');
        end
    
        %-----------------------------------------------------------------%
        function htmlContent = entityDetails(id, details)
            displayEntry = util.HtmlTextGenerator.makeDisplayEntry('CADASTRO', details);
            htmlIntro = sprintf('<font style="font-size: 16px;"><b>%s</b></font><br><br>', id);
            htmlContent = textFormatGUI.struct2PrettyPrintList(displayEntry, 'delete', htmlIntro, 'popup');
        end

        %-----------------------------------------------------------------%
        function tag = createTag(type, varargin)
            arguments
                type {mustBeMember(type, {'Flow', 'Emission'})}
            end

            arguments (Repeating)
                varargin
            end

            switch type
                case 'Flow'
                    specData = varargin{1};
                    tag = sprintf('%.3f – %.3f MHz', specData.MetaData.FreqStart/1e+6, specData.MetaData.FreqStop/1e+6);

                otherwise % 'Emission'
                    frequencyMHz = varargin{1};
                    bandWidthkHz = varargin{2};
                    tag = sprintf('%.3f MHz ⌂ %.1f kHz', frequencyMHz, bandWidthkHz);
            end
        end

        %-----------------------------------------------------------------%
        function htmlContent = receiverStationDetails(pointDetails, appHandleNameInBase, generalSettings)
            summaryCount = getSummary(pointDetails);            

            htmlContent = sprintf([ ...
                '<section style="padding: 10px 10px 10px 0px; height: 100%%; max-height: calc(100%% - 20px);">' ...
                    '<section style="background-color: rgb(240, 240, 240); padding: 8px 12px 8px 12px; border-top-left-radius: 10px;">' ...
                        '<p><b>%s</b></p>' ...
                        '<p style="color: #707070;">%s</p>' ...
                    '</section>' ...
                    '<section style="height: calc(100%% - 48px); overflow-y: auto;">' ...
                        '%s' ...
                    '</section>' ...
                '</section>' ...
            ], summaryCount.Points, summaryCount.Stations, getPoints(pointDetails, appHandleNameInBase, generalSettings));

            function summaryCount = getSummary(pointDetails)
                pointCount = numel(pointDetails);            
                stationCount = sum(arrayfun(@(x) numel(x.detail.stations), pointDetails));

                summaryCount = struct( ...
                    'Points', sprintf('%d LOCALIDADES', pointCount), ...
                    'Stations', sprintf('%d ESTAÇÕES', stationCount) ...
                );

                if pointCount == 1
                    summaryCount.Points = '1 LOCALIDADE';
                end

                if stationCount == 1
                    summaryCount.Stations = '1 ESTAÇÃO';
                end
            end

            function locations = getPoints(pointDetails, appHandleNameInBase, generalSettings)
                locations = {};

                for pointIdx = 1:numel(pointDetails)
                    point = pointDetails(pointIdx).point;

                    bottomBorderStyle = '';
                    if pointIdx == numel(pointDetails)
                        bottomBorderStyle = ' border-radius: 0px 0px 0px 10px;';
                    end
        
                    locations{end+1} = sprintf([ ...
                        '<section style="padding: 10px; background-color: rgb(255, 255, 255,0.95);%s">' ...
                            '<p style="font-size: 12px; color: #202020;">&#x1F4CD; <b>%s</b></p>' ...
                            '<p style="padding-left: 20px; color: #707070; font-size: 10px;">%s/%s</p>' ...
                        '%s' ...
                        '</section>' ...
                    ], bottomBorderStyle, point.site_label, point.county_name, point.state_code, getStations(point.stations, appHandleNameInBase, generalSettings, pointIdx));
                end

                locations = strjoin(locations, '');
            end

            function stations = getStations(stationDetails, appHandleNameInBase, generalSettings, pointIdx)
                stations = {};

                for stationIdx = 1:numel(stationDetails)
                    station = stationDetails(stationIdx);
                    [statusText, statusColor] = getStatusLayout(station.map_state);
        
                    positionStatus = 'Posição atual';
                    if ~station.is_current_location
                        positionStatus = 'Posição histórica';
                    end
        
                    sawAt = '';
                    if isfield(station, 'last_seen_at')
                        sawAt = sprintf(' • Vista em %s', station.last_seen_at);
                    end

                    searchLink = util.HtmlTextGenerator.createEditHTMLLink(appHandleNameInBase, generalSettings, 'onRepoFileSearchRequested', jsonencode([pointIdx, stationIdx]), 'link', 'search-sparkle.svg', 16, 16);

                    stations{end+1} = sprintf([ ...
                        '<section style="margin: 10px 0 0 0px; padding: 5px 0 5px 11px; background-color: transparent;">' ...
                            '<table style="width: 100%%;">' ...
                                '<tr>' ...
                                    '<td style="width: 3px; background: %s;"></td>' ...
                                    '<td style="padding-left: 5px;">' ...
                                        '<p>' ...
                                            '<font style="font-size: 12px; color: #202020;"><b>%s</b></font><br>' ...
                                            '<font style="font-size: 10px; color: %s;"><b>%s</b></font><br>' ...
                                            '<font style="font-size: 10px; color: #606060;">%s%s</font>' ...
                                        '</p>' ...
                                    '</td>' ...
                                    '<td style="width: 18px; pointer-events: auto;"><br>%s</td>' ...
                                '</tr>' ...
                            '</table>' ...
                        '</section>' ...
                    ], statusColor, resolveStationName(station.host_name, station.equipment_name), statusColor, statusText, positionStatus, sawAt, searchLink);
                end

                stations = strjoin(stations, '');
            end

            function stationName = resolveStationName(hostName, equipamentName)
                hostName = char(hostName);
                equipamentName = char(equipamentName);

                if ~isempty(hostName)
                    stationName = hostName;
                elseif ~isempty(equipamentName)
                    stationName = equipamentName;
                else
                    stationName = '(ESTAÇÃO DESCONHECIDA)';
                end
            end

            function [label, color] = getStatusLayout(stationStatus)
                switch stationStatus
                    case 'online_current'
                        label = 'Online';
                        color = '#4f7f67';
                    case 'online_previous'
                        label = 'Online histórico';
                        color = '#4f7f67';
                    case 'offline_current'
                        label = 'Offline';
                        color = '#b88352';
                    case 'offline_previous'
                        label = 'Offline histórico';
                        color = '#b88352';
                    otherwise
                        label = 'Sem host';
                        color = '#7b8aa0';
                end
            end
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        function entry = makeDisplayEntry(group, value, link)
            arguments
                group
                value
                link = ''
            end

            entry = struct('group', group, 'value', value, 'link', link);
        end

        %-----------------------------------------------------------------%
        function html = receiverBadge(label)
            html = sprintf('<font style="color: white; background-color: #b7312c; display: inline-block; vertical-align: middle; padding: 5px; border-radius: 5px;">%s</font>', label);
        end

        %-----------------------------------------------------------------%
        function icon = monitoringTypeIcon(specData)
            monitoringType = gpsLib.classifyMonitoringType(specData.GPS);

            switch monitoringType
                case 'fixed'
                    icon = util.HtmlTextGenerator.UNICODE_TO_HTML_HEX_MAP.('Pin').html;
                case 'mobile'
                    icon = util.HtmlTextGenerator.UNICODE_TO_HTML_HEX_MAP.('Car').html;
                otherwise
                    icon = util.HtmlTextGenerator.UNICODE_TO_HTML_HEX_MAP.('InterrogationMark').html;
            end
        end

        %-----------------------------------------------------------------%
        function period = observationPeriod(specData)
            period = sprintf('%s – %s', ...
                datestr(min(specData.RelatedFiles.BeginTime), 'dd/mm/yyyy HH:MM:SS'), ...
                datestr(max(specData.RelatedFiles.EndTime),   'dd/mm/yyyy HH:MM:SS') ...
            );
        end

        %-----------------------------------------------------------------%
        function htmlLink = createEditHTMLLink(appHandleNameInBase, generalSettings, eventName, eventData, linkType, imgFileName, imgWidth, imgHeight)
            arguments
                appHandleNameInBase 
                generalSettings
                eventName
                eventData = ''                
                linkType {mustBeMember(linkType, {'link', 'question', 'edit'})} = 'edit'
                imgFileName = 'Edit_32.png'
                imgWidth = 18 % pixels
                imgHeight = 18% pixels
            end

            htmlLink = '';

            try
                if ~isempty(appHandleNameInBase)
                    if ~isempty(generalSettings) && ~isempty(generalSettings.AppVersion.application.resourceStaticURL)
                        htmlLink = ui.TextView.createHTMLLink('customImage', appHandleNameInBase, eventName, eventData, imgFileName, imgWidth, imgHeight, generalSettings);
                    else
                        htmlLink = ui.TextView.createHTMLLink(linkType, appHandleNameInBase, eventName, eventData);
                    end
                end
            catch
            end
        end
    end
end
