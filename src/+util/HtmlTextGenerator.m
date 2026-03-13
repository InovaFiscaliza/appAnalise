classdef (Abstract) HtmlTextGenerator

    % Essa classe abstrata organiza a criação de "textos decorados",
    % valendo-se das funcionalidades do HTML+CSS. Um texto aqui produzido
    % será renderizado em um componente uihtml, uilabel ou outro que tenha 
    % html como interpretador.

    % Antes de cada função, consta a indicação do módulo que chama a
    % função.

    properties (Constant)
        %-----------------------------------------------------------------%
        unicodeToHtmlHexMap = struct( ...
            'Bullet',          struct('unicode', '•',  'html', '&#x2022;'), ...
            'Hourglass',       struct('unicode', '⌛', 'html', '&#x231B;'), ...
            'WhiteCircle',     struct('unicode', '⚪', 'html', '&#x26AA;'), ...
            'RedCircle',       struct('unicode', '🔴', 'html', '&#x1F534;'), ...
            'GreenCircle',     struct('unicode', '🟢', 'html', '&#x1F7E2;'), ...
            'ExclamationMark', struct('unicode', '❗', 'html', '&#x2757;'), ...
            'PlusSign',        struct('unicode', '➕', 'html', '&#x2795;'), ...
            'ProhibitedSign',  struct('unicode', '🚫', 'html', '&#x1F6AB;'), ...
            'HierarchyArrow',  struct('unicode', '↳',  'html', '&#x21B3;') ...
        );

        monitoringTypeDict = dictionary( ...
            ["fixed", "mobile", "undetermined"], ...
            ["FIXA", "MÓVEL", "INDETERMINADA"] ...
        )
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        % WINAPPANALISE - INFO
        %-----------------------------------------------------------------%
        function htmlContent = AppInfo(appGeneral, rootFolder, executionMode, renderCount, outputFormat)
            arguments
                appGeneral 
                rootFolder 
                executionMode 
                renderCount
                outputFormat char {mustBeMember(outputFormat, {'popup', 'textview'})} = 'textview'
            end
        
            appName    = class.Constants.appName;
            appVersion = appGeneral.AppVersion;
            appURL     = util.publicLink(appName, rootFolder, appName);
        
            switch executionMode
                case {'MATLABEnvironment', 'desktopStandaloneApp'}
                    appMode = 'desktopApp';        
                case 'webApp'
                    computerName = appEngine.util.OperationSystem('computerName');
                    if strcmpi(computerName, appGeneral.computerName.webServer)
                        appMode = 'webServer';
                    else
                        appMode = 'deployServer';                    
                    end
            end

            dataStruct    = struct('group', 'COMPUTADOR',     'value', struct('Machine', rmfield(appVersion.machine, 'name'), 'Mode', sprintf('%s - %s', executionMode, appMode)));
            dataStruct(2) = struct('group', 'MATLAB',         'value', rmfield(appVersion.matlab, 'name'));
            if ~isempty(appVersion.browser)
                dataStruct(3) = struct('group', 'NAVEGADOR',  'value', rmfield(appVersion.browser, 'name'));
            end
            dataStruct(end+1) = struct('group', 'RENDERIZAÇÕES','value', renderCount);
            dataStruct(end+1) = struct('group', 'APLICATIVO', 'value', appVersion.application);

            global RFDataHub
            global RFDataHub_info
            dataStruct(end+1) = struct('group', 'RFDataHub', 'value', struct('releasedDate', RFDataHub_info.ReleaseDate, 'numberOfRows', height(RFDataHub), 'numberOfUniqueStations', numel(unique(RFDataHub.("Station")))));
        
            freeInitialText = sprintf('<font style="font-size: 12px;">O repositório das ferramentas desenvolvidas no Laboratório de inovação da SFI pode ser acessado <a href="%s" target="_blank">aqui</a>.</font>\n\n', appURL.Sharepoint);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'print -1', freeInitialText, outputFormat);
        end


        %-----------------------------------------------------------------%
        % WINAPPANALISE - MODOS "FILE" E "PLAYBACK"
        %-----------------------------------------------------------------%
        function htmlContent = WarningMessage(msg)
            htmlContent = sprintf('<p style="text-align: center; font-size: 36px;">&#x26A0;&#xFE0F;<p style="text-align: center; font-size: 11px;"><b>%s</b></p></p>', upper(msg));
        end


        %-----------------------------------------------------------------%
        function htmlContent = SelectedFile(metaData, fileIdx, varargin)
            if isscalar(fileIdx)
                flowIdxs = varargin{1};
                specData = metaData(fileIdx).Data(flowIdxs);
                
                dataStruct = struct('group', 'GERAL', ...
                                    'value', struct('File',   metaData(fileIdx).File, ...
                                                    'Type',   metaData(fileIdx).Type, ...
                                                    'nData',  numel(flowIdxs), ...
                                                    'Memory', textFormatGUI.bytes2human(computeEstimatedMemory(specData))));
                
                if isscalar(specData)
                    [~, dataTempStruct, initialText] = util.HtmlTextGenerator.ThreadMetaData(specData);
                    dataStruct = [dataStruct, dataTempStruct];
    
                else
                    receiverList = unique(arrayfun(@(x) x.Receiver, metaData(fileIdx).Data(flowIdxs), "UniformOutput", false));
                    receiverList = cellfun(@(x) util.layoutTreeNodeText(x, 'play_TreeBuilding'), receiverList, 'UniformOutput', false);

                    flowTag = strjoin(arrayfun(@(x) sprintf('%.3f - %.3f MHz', x.MetaData.FreqStart/1e+6, x.MetaData.FreqStop/1e+6), specData, "UniformOutput", false), '<br>');
    
                    initialText = [ ...
                        strjoin(strcat({'<font style="color: white; background-color: #b7312c; display: inline-block; vertical-align: middle; padding: 5px; border-radius: 5px;">'}, receiverList, {'</font><br>'}), '') ...
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
                flowTag = strjoin(unique(arrayfun(@(x) sprintf('%.3f - %.3f MHz', x.MetaData.FreqStart/1e+6, x.MetaData.FreqStop/1e+6), specData, "UniformOutput", false), 'stable'), '<br>');

                dataStruct = struct('group', 'GERAL', ...
                                    'value', struct('File',   textFormatGUI.cellstr2ListWithQuotes({metaData(fileIdx).File}), ...
                                                    'nData',  numel(specData), ...
                                                    'Memory', textFormatGUI.bytes2human(computeEstimatedMemory(specData))));

                initialText = [ ...
                    strjoin(strcat({'<font style="color: white; background-color: #b7312c; display: inline-block; vertical-align: middle; padding: 5px; border-radius: 5px;">'}, receiverList, {'</font><br>'}), '') ...
                    sprintf('<br><font style="font-size: 16px;"><b>%s</b></font><br><br>', flowTag) ...
                ];
            end
        
            htmlContent = textFormatGUI.struct2PrettyPrintList(dataStruct, 'delete', initialText);
        end

        %-----------------------------------------------------------------%
        function [htmlContent, dataStruct, initialText] = ThreadMetaData(specData)
            threadTag = sprintf('%.3f - %.3f MHz', specData.MetaData.FreqStart/1e+6, specData.MetaData.FreqStop/1e+6);
            observationPeriod = sprintf('%s - %s', datestr(min(specData.RelatedFiles.BeginTime), 'dd/mm/yyyy HH:MM:SS'), datestr(max(specData.RelatedFiles.EndTime), 'dd/mm/yyyy HH:MM:SS'));
            description = sprintf('"%s"', specData.RelatedFiles.Description{1});
            
            dataStruct = struct('group', 'PARÂMETROS DE AQUISIÇÃO', 'value', rmfield(specData.MetaData, {'DataType'}));
            
            dataStruct.value.FreqStart = sprintf('%d Hz', dataStruct.value.FreqStart);
            dataStruct.value.FreqStop  = sprintf('%d Hz', dataStruct.value.FreqStop);

            if specData.MetaData.Resolution ~= -1
                dataStruct.value.Resolution = sprintf('%.1f kHz', dataStruct.value.Resolution/1000);
            end
    
            if specData.MetaData.VBW ~= -1
                dataStruct.value.VBW = sprintf('%.3f kHz', dataStruct.value.VBW/1000);
            end
    
            dataStruct(2) = struct('group', 'LOCAL DA MONITORAÇÃO', 'value', rmfield(specData.GPS, {'stdRange', 'Edited'}));
            dataStruct(3) = struct('group', 'FONTE DA INFORMAÇÃO', 'value', struct('NumFiles', height(specData.RelatedFiles), 'NumSweeps', sum(specData.RelatedFiles.NumSweeps)));
    
            for ii = 1:height(specData.RelatedFiles)
                beginTime = datestr(specData.RelatedFiles.BeginTime(ii), 'dd/mm/yyyy HH:MM:SS');
                endTime   = datestr(specData.RelatedFiles.EndTime(ii),   'dd/mm/yyyy HH:MM:SS');
    
                dataStruct(end+1) = struct('group', sprintf('#%d. %s', ii, specData.RelatedFiles.File{ii}), ...
                                           'value', struct('Id',              specData.RelatedFiles.Id(ii), ...
                                                           'Task',            sprintf('"%s"', specData.RelatedFiles.Task{ii}), ...
                                                           'Description',     sprintf('"%s"', specData.RelatedFiles.Description{ii}), ...
                                                           'ObservationTime', sprintf('%s - %s', beginTime, endTime), ...
                                                           'NumSweeps',       specData.RelatedFiles.NumSweeps(ii), ...
                                                           'RevisitTime',     sprintf('%.3f segundos', specData.RelatedFiles.RevisitTime(ii))));
            end
    
            if isprop(specData, 'UserData') && ~isempty(specData.UserData) && isstruct(specData.UserData) && isfield(specData.UserData, 'LOG') && ~isempty(specData.UserData.LOG)
                dataStruct(end+1) = struct('group', 'LOG', 'value', textFormatGUI.cellstr2Bullets(specData.UserData.LOG));
            end
            
            initialText = [ ...
                sprintf('<font style="color: white; background-color: #b7312c; display: inline-block; vertical-align: middle; padding: 5px; border-radius: 5px;">%s</font><br><br>', util.layoutTreeNodeText(specData.Receiver, 'play_TreeBuilding')) ...
                sprintf('<font style="font-size: 16px;"><b>%s</b></font><br>📃 %s<br>⌛ %s<br>📍 %s<br><br>', threadTag, description, observationPeriod, specData.GPS.Location) ...
            ];
            htmlContent = textFormatGUI.struct2PrettyPrintList(dataStruct, 'delete', initialText);
        end

        %-----------------------------------------------------------------%
        function htmlContent = ThreadAnalysis(specData)
            freqStart   = specData.MetaData.FreqStart;
            freqStop    = specData.MetaData.FreqStop;
            resolution  = specData.MetaData.Resolution;            
            traceMode   = specData.MetaData.TraceMode;
            detector    = specData.MetaData.Detector;
            levelUnit   = specData.MetaData.LevelUnit;
            numPoints   = specData.MetaData.DataPoints;
            numSweeps   = sum(specData.RelatedFiles.NumSweeps);
            observationPeriod = sprintf('%s - %s', ...
                datestr(min(specData.RelatedFiles.BeginTime), 'dd/mm/yyyy HH:MM:SS'), ...
                datestr(max(specData.RelatedFiles.EndTime), 'dd/mm/yyyy HH:MM:SS') ...
            );

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
            if isKey(util.HtmlTextGenerator.monitoringTypeDict, monitoringType)
                monitoringType = util.HtmlTextGenerator.monitoringTypeDict(monitoringType);
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
        function htmlContent = Algorithms(specData, operationType)
            switch operationType
                case 'Occupancy'
                    htmlContent = sprintf('<p style="padding: 10px;">%s</p>', textFormatGUI.jsonEncodePretty(specData.UserData.ReportAlgorithms.Occupancy));

                case 'Detection+Classification'
                    dataStruct = struct('group', 'DETECÇÃO', 'value', textFormatGUI.jsonEncodePretty(specData.UserData.ReportAlgorithms.Detection));
                    dataStruct(2) = struct('group', 'CLASSIFICAÇÃO', 'value', textFormatGUI.jsonEncodePretty(specData.UserData.ReportAlgorithms.Classification));
                    
                    htmlContent = textFormatGUI.struct2PrettyPrintList(dataStruct);
            end
        end

        %-----------------------------------------------------------------%
        % WINAPPANALISE - MODO "REPORT"
        %-----------------------------------------------------------------%
        function htmlContent = ReportAlgorithms(specData)
            threadTag = sprintf('%.3f - %.3f MHz', specData.MetaData.FreqStart/1e+6, specData.MetaData.FreqStop/1e+6);
        
            if specData.UserData.bandLimitsStatus && height(specData.UserData.bandLimitsTable)
                detectionBands = strjoin(arrayfun(@(x,y) sprintf('%.3f - %.3f MHz', x, y), specData.UserData.bandLimitsTable.FreqStart, ...
                                                                                           specData.UserData.bandLimitsTable.FreqStop, 'UniformOutput', false), ', ');
            else
                detectionBands = sprintf('%.3f - %.3f MHz', specData.MetaData.FreqStart/1e+6, ...
                                                            specData.MetaData.FreqStop /1e+6);
            end
        
            dataStruct    = struct('group', 'OCUPAÇÃO', 'value', specData.UserData.reportAlgorithms.Occupancy);
            dataStruct(2) = struct('group', 'DETECÇÃO ASSISTIDA', 'value', struct('Origin', 'PLAYBACK', 'BandLimits', detectionBands));
            if ~specData.UserData.reportAlgorithms.Detection.ManualMode
                dataStruct(end+1) = struct('group', 'DETECÇÃO NÃO ASSISTIDA', 'value', struct('Origin',     'RELATÓRIO', ...
                                                                                              'BandLimits',  detectionBands,     ...
                                                                                              'Algorithm',   specData.UserData.reportAlgorithms.Detection.Algorithm, ...
                                                                                              'Parameters',  jsonencode(specData.UserData.reportAlgorithms.Detection.Parameters)));
            end
            dataStruct(end+1) = struct('group', 'CLASSIFICAÇÃO', 'value', struct('Algorithm',  specData.UserData.reportAlgorithms.Classification.Algorithm, ...
                                                                                 'Parameters', specData.UserData.reportAlgorithms.Classification.Parameters));
            
            freeInitialText = sprintf('<font style="font-size: 16px;"><b>%s</b></font>\n\n', threadTag);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, "print -1", freeInitialText);
        end


        %-----------------------------------------------------------------%
        % AUXAPP.DOCKTIMEFILTERING
        %-----------------------------------------------------------------%
        function htmlContent = ThreadsInfo(specData, filteringSummary)
            htmlContent = {};
        
            for ii = 1:numel(specData)
                threadTag      = sprintf('%.3f - %.3f MHz', specData(ii).MetaData.FreqStart/1e+6, specData(ii).MetaData.FreqStop/1e+6);
        
                FilteredSweeps = '';
                if filteringSummary.RawSweeps(ii) ~= filteringSummary.FilteredSweeps(ii)
                    if filteringSummary.FilteredSweeps(ii)
                        fontColor = 'gray';
                    else
                        fontColor = 'red';
                    end
        
                    FilteredSweeps = sprintf('<br><font style="color: %s; font-size: 10px;">%d varreduras pós-filtragem</font>', fontColor, filteringSummary.FilteredSweeps(ii));
                end
            
                dataStruct(1)  = struct('group', 'TEMPO DE OBSERVAÇÃO', 'value', sprintf('%s - %s', datestr(specData(ii).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), datestr(specData(ii).Data{1}(end), 'dd/mm/yyyy HH:MM:SS')));
                dataStruct(2)  = struct('group', 'VARREDURAS',          'value', sprintf('%d >> %d', filteringSummary.RawSweeps(ii), filteringSummary.FilteredSweeps(ii)));
            
                htmlContent{end+1} = [sprintf('<p style="font-family: Helvetica, Arial, sans-serif; font-size: 16px; text-align: justify; line-height: 16px; margin: 10px;"><b>%s</b><br>', threadTag)               ...
                                      sprintf('<font style="color: gray; font-size: 10px;">%s - %s</font><br>', datestr(specData(ii).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), datestr(specData(ii).Data{1}(end), 'dd/mm/yyyy HH:MM:SS')) ...
                                      sprintf('<font style="color: gray; font-size: 10px;">%d varreduras inicias</font>%s</p>', filteringSummary.RawSweeps(ii), FilteredSweeps)];
            end
        
            htmlContent = strjoin(htmlContent);
        end


        %-----------------------------------------------------------------%
        % AUXAPP.SIGNALANALYSIS
        %-----------------------------------------------------------------%
        function [htmlContent, emissionTag, userDescription, stationInfo] = Emission(specData, idxThread, idxEmission)
            emissionTable = specData(idxThread).UserData.Emissions(idxEmission, :);
            emissionTag   = sprintf('%.3f MHz ⌂ %.1f kHz', emissionTable.Frequency, emissionTable.BW_kHz);
        
            % Identificando registros que foram editados pelo usuário:
            columns2Compare = {'Regulatory', 'Service', 'Station', 'EmissionType', 'Irregular', 'RiskLevel', 'Latitude', 'Longitude', 'AntennaHeight', 'Description', 'Distance'};
            stationInfo = [];
            for ii = 1:numel(columns2Compare)
                columnName = columns2Compare{ii};
                if isequal(emissionTable.Classification.autoSuggested.(columnName), emissionTable.Classification.userModified.(columnName))
                    columnsDiff.(columnName) = string(emissionTable.Classification.autoSuggested.(columnName));
                else
                    columnsDiff.(columnName) = sprintf('<del>%s</del> → <font style="color: red;">%s</font>', string(emissionTable.Classification.autoSuggested.(columnName)), string(emissionTable.Classification.userModified.(columnName)));                    
                end
                stationInfo.(columnName) = emissionTable.Classification.userModified.(columnName);
            end

            % Destacando em VERMELHO registros que possuem situação diferente de 
            % "Licenciada" e, também, registros cujo número da estação é igual a -1.
            % Este último caso, contudo, é feito apenas se a tabela exceptionList 
            % estiver vazia.
            if stationInfo.Regulatory ~= "Licenciada"
                columnsDiff.Regulatory = sprintf('<font style="color: red;">%s</font>', columnsDiff.Regulatory);
            end
        
            if stationInfo.Station == -1
                columnsDiff.Station = sprintf('<font style="color: red;">%s</font>', columnsDiff.Station);
            end

            if stationInfo.AntennaHeight <= 0
                columnsDiff.AntennaHeight = '<font style="color: red;">-1</font>';
            end
        
            % stationInfo
            stationInfo.Details       = emissionTable.Classification.userModified.Details;
        
            % HTML
            dataStruct(1) = struct('group', 'RECEPTOR',            'value', specData(idxThread).Receiver);
            dataStruct(2) = struct('group', 'TEMPO DE OBSERVAÇÃO', 'value', sprintf('%s - %s', datestr(specData(idxThread).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), datestr(specData(idxThread).Data{1}(end), 'dd/mm/yyyy HH:MM:SS')));    
            dataStruct(3) = struct('group', 'CANAL',               'value', struct('autoSuggested', sprintf('%.3f MHz ⌂ %.1f kHz', emissionTable.ChannelAssigned.autoSuggested.Frequency, emissionTable.ChannelAssigned.autoSuggested.ChannelBW)));
            
            if ~isequal(emissionTable.ChannelAssigned.autoSuggested, emissionTable.ChannelAssigned.userModified)
                dataStruct(3).value.userModified = sprintf('%.3f MHz ⌂ %.1f kHz', emissionTable.ChannelAssigned.userModified.Frequency,  emissionTable.ChannelAssigned.userModified.ChannelBW);
            end

            dataStruct(4) = struct('group', 'CLASSIFICAÇÃO',       'value', columnsDiff);
            dataStruct(5) = struct('group', 'ALGORITMOS',          'value', struct('Occupancy',       emissionTable.Algorithms.Occupancy, ...
                                                                                   'Detection',       emissionTable.Algorithms.Detection, ...
                                                                                   'Classification',  emissionTable.Algorithms.Classification));
        
            userDescription = specData(idxThread).UserData.Emissions.Description(idxEmission);
            if userDescription ~= ""
                dataStruct(4).value.userDescription = sprintf('<font style="color: blue;">%s</font>', userDescription);
            end
        
            freeInitialText1 = sprintf('<font style="font-size: 16px;"><b>%s</b></font><br><br>', emissionTag);
            htmlContent1     = textFormatGUI.struct2PrettyPrintList(dataStruct(1:4), 'print -1', freeInitialText1);

            freeInitialText2 = '<font style="color: gray; font-size: 10px;">&thinsp;&thinsp;&thinsp;&thinsp;&thinsp;&thinsp;&thinsp;____________________<br>&thinsp;̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ <br></font>';
            htmlContent2     = textFormatGUI.struct2PrettyPrintList(dataStruct(5),   'delete',   freeInitialText2);

            htmlContent      = strjoin({htmlContent1, htmlContent2}, '');
        end


        %-----------------------------------------------------------------%
        % AUXAPP.DRIVETEST
        %-----------------------------------------------------------------%
        function [htmlContent, emissionID] = Emission_v2(specData, idxThread, idxEmission)
            % No módulo auxApp.DriveTest existe a figura de "emissão
            % virtual", que corresponde à toda a faixa de frequência
            % monitorada.
            if isempty(idxEmission) % Emissão virtual
                FreqCenter  = (specData(idxThread).MetaData.FreqStart + specData(idxThread).MetaData.FreqStop) / 2e6; % MHz
                BW_kHz      = (specData(idxThread).MetaData.FreqStop - specData(idxThread).MetaData.FreqStart) / 1e3; % kHz
            
            else % Emissão real
                FreqCenter  = specData(idxThread).UserData.Emissions.Frequency(idxEmission);
                BW_kHz      = specData(idxThread).UserData.Emissions.BW_kHz(idxEmission);
            end
        
            emissionTag     = sprintf('%.3f MHz ⌂ %.1f kHz', FreqCenter, BW_kHz);
        
            bandFreqStart   = sprintf('%.3f MHz', specData(idxThread).MetaData.FreqStart/1e+6);
            bandFreqStop    = sprintf('%.3f MHz', specData(idxThread).MetaData.FreqStop/1e+6);
            bandStepWidth   = sprintf('%.1f kHz', (specData(idxThread).MetaData.FreqStop - specData(idxThread).MetaData.FreqStart)/(1000*(specData(idxThread).MetaData.DataPoints-1)));
            bandResolution  = sprintf('%.1f kHz', specData(idxThread).MetaData.Resolution/1000);
        
            metaData        = struct('FreqStart',        bandFreqStart,                           ...
                                     'FreqStop',         bandFreqStop,                            ...
                                     'DataPoints',       specData(idxThread).MetaData.DataPoints,       ...
                                     'StepWidth',        bandStepWidth,                           ...
                                     'Resolution',       bandResolution,                          ...
                                     'TraceMode',        specData(idxThread).MetaData.TraceMode,        ...
                                     'TraceIntegration', specData(idxThread).MetaData.TraceIntegration, ...
                                     'Detector',         specData(idxThread).MetaData.Detector,         ...
                                     'LevelUnit',        specData(idxThread).MetaData.LevelUnit);
        
            dataStruct(1)   = struct('group', 'RECEPTOR',            'value', specData(idxThread).Receiver);
            dataStruct(2)   = struct('group', 'TEMPO DE OBSERVAÇÃO', 'value', sprintf('%s - %s', datestr(specData(idxThread).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), datestr(specData(idxThread).Data{1}(end), 'dd/mm/yyyy HH:MM:SS')));
            dataStruct(3)   = struct('group', 'METADADOS',           'value', metaData);

            gpsInfo = specData(idxThread).GPS;
            if ~specData(idxThread).GPS.Status
                gpsInfo = '🔴 Não identificada informação válida';
            end
            dataStruct(4)   = struct('group', 'GPS',                 'value', gpsInfo);
        
            freeInitialText = sprintf('<font style="font-size: 16px;"><b>%s</b></font>\n\n', emissionTag);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'delete', freeInitialText);
        
            emissionID      = struct('Thread',   struct('Index',     idxThread, ...
                                                        'Hash',      specData(idxThread).Hash), ...
                                     'Emission', struct('Index',     idxEmission, ...
                                                        'Frequency', FreqCenter, ...
                                                        'BW_kHz',    BW_kHz, ...
                                                        'Tag',       emissionTag));
        end


        %-----------------------------------------------------------------%
        % AUXAPP.WINCONFIG
        %-----------------------------------------------------------------%
        function [htmlContent, stableVersion, updatedModule] = checkAvailableUpdate(appGeneral, rootFolder)
            stableVersion = [];
            updatedModule = {};
            
            try
                % Versão instalada no computador:
                appName          = class.Constants.appName;
                presentVersion   = struct(appName,     appGeneral.AppVersion.application.version, ...
                                          'rfDataHub', rmfield(appGeneral.AppVersion.database, 'name'));
                
                % Versão estável, indicada nos arquivos de referência (na nuvem):
                [versionFileURL, rfDataHubURL] = util.publicLink(appName, rootFolder, 'VersionFile+RFDataHub');
        
        
                generalVersions  = webread(versionFileURL,       weboptions("ContentType", "json"));
                rfdatahubVersion = webread(rfDataHubURL.Release, weboptions("ContentType", "json"));
        
                stableVersion    = struct(appName,     generalVersions.(appName).Version, ...
                                          'rfDataHub', rfdatahubVersion.rfdatahub);
                
                % Validação:
                if isequal(presentVersion, stableVersion)
                    msgWarning    = 'O appAnalise está atualizado.';
                    updatedModule = {'appAnalise', 'RFDataHub'};
                else
                    nonUpdatedModule = {};
                    if strcmp(presentVersion.(appName), stableVersion.(appName))
                        updatedModule(end+1)    = {'appAnalise'};
                    else
                        nonUpdatedModule(end+1) = {'appAnalise'};
                    end
        
                    if isequal(presentVersion.rfDataHub, stableVersion.rfDataHub)
                        updatedModule(end+1)    = {'RFDataHub'};
                    else
                        nonUpdatedModule(end+1) = {'RFDataHub'};
                    end
        
                    dataStruct    = struct('group', 'VERSÃO INSTALADA', 'value', presentVersion);
                    dataStruct(2) = struct('group', 'VERSÃO ESTÁVEL',   'value', stableVersion);
                    dataStruct(3) = struct('group', 'SITUAÇÃO',         'value', struct('updated', strjoin(updatedModule, ', '), 'nonupdated', strjoin(nonUpdatedModule, ', ')));
        
                    msgWarning    = textFormatGUI.struct2PrettyPrintList(dataStruct, "print -1", '', 'popup');
                end
                
            catch ME
                msgWarning = ME.message;
            end
        
            htmlContent = msgWarning;
        end


        %-----------------------------------------------------------------%
        % AUXAPP.RFDATAHUB
        %-----------------------------------------------------------------%
        function htmlContent = Station(rfDataHub, idxRFDataHub, rfDataHubLOG, appGeneral)
            % stationTag
            stationInfo    = table2struct(rfDataHub(idxRFDataHub,:));
            if stationInfo.BW <= 0
                stationTag = sprintf('%.3f MHz',            stationInfo.Frequency);
            else
                stationTag = sprintf('%.3f MHz ⌂ %.1f kHz', stationInfo.Frequency, stationInfo.BW);
            end
        
            % stationService
            global id2nameTable
            if isempty(id2nameTable)
                serviceOptions = appGeneral.eFiscaliza.defaultValues.servicos_da_inspecao.options;
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
            
            % stationNumber
            mergeCount = str2double(string(stationInfo.MergeCount));
            if stationInfo.Station == -1
                stationNumber = sprintf('<font style="color: red;">%d</font>', stationInfo.Station);
            else
                stationNumber = num2str(stationInfo.Station);
                if mergeCount > 1
                    stationNumber = sprintf('%s*', stationNumber);
                end
            end
        
            % stationLocation, stationHeight
            stationLocation = sprintf('(%.6fº, %.6fº)', stationInfo.Latitude, stationInfo.Longitude);
            stationHeight   = str2double(char(stationInfo.AntennaHeight));
            if stationHeight <= 0
                stationHeight = '<font style="color: red;">-1</font>';
            else
                stationHeight = sprintf('%.1fm', stationHeight);
            end    
        
            % stationLOG
            stationLOG = model.RFDataHub.queryLog(rfDataHubLOG, stationInfo.Log);
            if isempty(stationLOG)
                stationLOG = 'Registro não editado';
            end
        
            % dataStruct2HTMLContent
            dataStruct(1) = struct('group', 'Service',     'value', stationService);
            dataStruct(2) = struct('group', 'Station',     'value', stationNumber);
            dataStruct(3) = struct('group', 'Localização', 'value', stationLocation);
            dataStruct(4) = struct('group', 'Altura',      'value', stationHeight);

            editedStationInfo = rmfield(stationInfo, { ...
                'AntennaPattern', 'BW', 'Description', 'Distance', 'Fistel', 'Frequency',     ...
                'ID', 'Latitude', 'LocationID', 'Location', 'Log', 'Longitude', 'MergeCount', ...
                'Name', 'Station', 'StationClass', 'Status', 'Service', 'Source', 'State', 'URL', 'x_Name', 'x_Location' ...
            });
            if any(cellfun(@(x) ~isequal(x, categorical(-1)), struct2cell(editedStationInfo)))
                dataStruct(end+1) = struct('group', 'OUTROS ASPECTOS TÉCNICOS', 'value', editedStationInfo);
            end

            if mergeCount > 1
                dataStruct(end+1) = struct('group', 'NÚMERO ESTAÇÕES AGRUPADAS', 'value', string(mergeCount));
            end
        
            try
                if isstruct(stationLOG) || ischar(stationLOG)
                    dataStruct(end+1) = struct('group', 'LOG', 'value', stationLOG);
                elseif iscell(stationLOG)
                    for ii = 1:numel(stationLOG)
                        dataStruct(end+1) = struct('group', sprintf('LOG #%d', ii), 'value', stationLOG{ii});
                    end
                end
            catch
            end
        
            freeInitialText = [sprintf('<font style="color: white; background-color: #b7312c; display: inline-block; vertical-align: middle; padding: 5px; border-radius: 5px;">%s</font><span style="font-size: 10px; display: inline-block; vertical-align: sub; margin-left: 5px;">  ID %s</span><br><br>', stationInfo.Source, stationInfo.ID) ...
                               sprintf('<font style="font-size: 16px;"><b>%s</b></font><br>', stationTag)                                                                                                                                                                                                                                                     ...
                               sprintf('<font style="font-size: 11px;">%s</font><br><br>', stationInfo.Description)];
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'delete', freeInitialText);
        end
    end
end