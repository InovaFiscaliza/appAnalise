classdef SpecData < model.SpecDataBase

    % ## model.SpecData (appAnalise) ##
    % PUBLIC
    %   ├── syncCollection
    %   |   └── buildSpectrumReferenceTable (model.MetaData)
    %   ├── populateSpectrum
    %   │   │── preallocateData             (model.SpecDataBase)
    %   │   │── read                        (model.SpecDataBase)
    %   │   │── basicStats                  (model.SpecDataBase)
    %   │   └── computeOccupancyPerBin
    %   ├── mergeWith
    %   ├── applyFilter
    %   ├── update ⚠️
    %   ├── hasOccupancyPerBin ⚠️
    %   ├── hasEmissionsInSearchBand ⚠️
    %   ├── calculateAntennaHeight
    %   └── FindPeaks ⚠️

    % PRIVATE
    %   ├── checkIfScalar
    %   ├── occupancyMapping
    %   └── getSpectrumMergeTable

    % STATIC
    %   └── identifyMergeType

    % ⚠️: Pendente revisão

    properties
        %-----------------------------------------------------------------%
        % "Hash" é o identificador único do fluxo espectral gerado a partir 
        % dos principais metadados da monitoração, como "Receiver" e campos 
        % de "MetaData", como "FreqStart", "FreqStop", "DataPoints", "TraceMode", 
        % "Detector" e "LevelUnit".
        Hash

        % "InputFiles" armazena informações dos arquivos que compõem specData.
        % Dentre os seus campos, "Indexes" registra o mapeamento metaData x specData,
        % e "IsUserMerged" registra se o fluxo foi gerado por mesclagem MANUAL via 
        % GUI. Ressalta-se, contudo, que os fluxos com mesmo Hash podem ser 
        % mesclados automaticamente, a depender da distância limite definida 
        % em arquivo de configuração ".\src\config\GeneralSettings.json".
        InputFiles struct = struct('File', {}, 'Indexes', {}, 'Hash', {}, 'IsUserMerged', {})
    
        % "UserData" contém informações relacionadas à GUI, incluindo a lista
        % de emissões e customizações de plot.
        UserData = model.UserData
    end
    

    methods
        %-----------------------------------------------------------------%
        function obj = syncCollection(obj, metaData, generalSettings)
            % Identifica fluxos espectrais presentes nos arquivos.
            referenceTable = buildSpectrumReferenceTable(metaData, generalSettings);
            [uniqueHashs, ~, uniqueHashIdxs] = unique(referenceTable.Hash, 'stable');

            obj = deleteObsoleteFlows(obj, referenceTable, uniqueHashs, uniqueHashIdxs);

            % Atualiza specData, editando fluxos atuais e includindo novos, 
            % caso aplicável. A mesclagem segue três critérios: mesmo hash,
            % proximidade geográfica e timestamps não sobrepostos.
            for ii = 1:numel(uniqueHashs)
                flowHash = uniqueHashs{ii};
                flowHashIdxs = find(uniqueHashIdxs == ii)';

                for jj = flowHashIdxs
                    fileIdx = referenceTable.Idx{jj}{1}(1);
                    flowIdx = referenceTable.Idx{jj}{1}(2);
                    newFlowRelatedFiles = metaData(fileIdx).Data(flowIdx).RelatedFiles;
                    
                    % Tenta encontrar um fluxo existente para mesclar
                    candidateObjIdx = findMergeableFlow(obj, flowHash, referenceTable, jj, newFlowRelatedFiles, generalSettings);
                    
                    if ~isempty(candidateObjIdx)
                        % Mescla com fluxo existente
                        idx = candidateObjIdx;

                        obj(idx).RelatedFiles = [obj(idx).RelatedFiles; newFlowRelatedFiles];
                        [~, relatedFilesIdxs] = unique(obj(idx).RelatedFiles.Hash);
                        obj(idx).RelatedFiles = sortrows(obj(idx).RelatedFiles(relatedFilesIdxs, :), 'BeginTime');

                        obj(idx).Data = {};
                        obj(idx).GPS = rmfield(gpsLib.summary(cell2mat(obj(idx).RelatedFiles.GPS)), 'Matrix');

                    else
                        % Cria novo fluxo
                        idx = numel(obj) + 1;

                        obj(idx) = copy(metaData(fileIdx).Data(flowIdx), {'FileMap'});
                        obj(idx).Hash = flowHash;
                    end

                    obj(idx).InputFiles(end+1) = struct( ...
                        'File', referenceTable.File{jj}, ...
                        'Indexes', [fileIdx, flowIdx], ...
                        'Hash', flowHash, ...
                        'IsUserMerged', false ...
                    );
                end
            end

            % Reordena fluxos de espectro, além de mapear fluxos de espectro
            % e ocupação.
            sortedIdxs = cellfun(@(x) find(strcmp(x, {obj.Hash})), uniqueHashs, 'UniformOutput', false);
            sortedIdxs = horzcat(sortedIdxs{:});
            obj = obj(sortedIdxs);
            
            occupancyMapping(obj)
        end

        %-----------------------------------------------------------------%
        function populateSpectrum(obj, metaData, channelObj, generalSettings)
            for ii = 1:numel(obj)
                if ~isempty(obj(ii).Data) && (numel(obj(ii).Data{1}) == sum(obj(ii).RelatedFiles.NumSweeps))
                    continue
                end

                % Pré-aloca propriedade "Data" que registra timestamp, valores 
                % de níveis, azimutes etc.
                fileFormatName = '';
                try
                    fileFormatName = jsondecode(obj(ii).MetaData.Others).FileFormat;
                catch
                end
                preallocateData(obj(ii), fileFormatName);

                for jj = 1:numel(obj(ii).InputFiles)
                    fileIdx  = obj(ii).InputFiles(jj).Indexes(1);
                    flowIdx  = obj(ii).InputFiles(jj).Indexes(2);
                    
                    fileName = metaData(fileIdx).File;    
                    tempObj  = read(metaData(fileIdx).Data(flowIdx), fileName, 'SpecData');
                    if ~isscalar(tempObj)
                        delete(tempObj(setdiff(1:numel(tempObj), flowIdx)))
                        tempObj = tempObj(flowIdx);
                    end

                    if jj == 1
                        idx1 = 1;
                    else
                        idx1 = idx2+1;
                    end
                    idx2 = idx1 + numel(tempObj.Data{1}) - 1;
                    
                    obj(ii).Data{1}(1, idx1:idx2) = tempObj.Data{1};
                    obj(ii).Data{2}(:, idx1:idx2) = tempObj.Data{2};
        
                    if numel(tempObj.Data) == 5
                        obj(ii).Data{4}(:, idx1:idx2) = tempObj.Data{4};
                        obj(ii).Data{5}(:, idx1:idx2) = tempObj.Data{5};
                    end

                    delete(tempObj)
                end

                if ~issorted(obj(ii).Data{1})
                    [obj(ii).Data{1}, sortIdxs] = sort(obj(ii).Data{1});
                    obj(ii).Data{2} = obj(ii).Data{2}(:, sortIdxs);

                    if numel(obj(ii).Data) == 5
                        obj(ii).Data{4} = obj(ii).Data{4}(:, sortIdxs);
                        obj(ii).Data{5} = obj(ii).Data{5}(:, sortIdxs);
                    end
                end
                
                if ~issorted(obj(ii).RelatedFiles.BeginTime)
                    obj(ii).RelatedFiles = sortrows(obj(ii).RelatedFiles, 'BeginTime');
                end

                % É preciso inicializar seis propriedades de "UserData". As
                % outras são inicializadas pela classe model.UserData.
                % - "AntennaHeightMeters"
                % - "ChannelLibraryRelatedIndexes"
                % - "OccupancyComputationMode",
                % - "OccupancyFiniteIntegrationCache"
                % - "OccupancyCumulativeIntegration"
                if isempty(obj(ii).UserData.PlotDisplayConfig)
                    obj(ii).UserData.AntennaHeightMeters = calculateAntennaHeight(obj, ii, -1, 'initialValue');
                    obj(ii).UserData.PlotDisplayConfig = model.UserData.getFieldTemplate('DefaultPlotDisplayConfig', generalSettings);
                    
                    if ~generalSettings.context.PLAYBACK.channel.manualMode && ismember(obj(ii).MetaData.DataType, class.Constants.specDataTypes)
                        obj(ii).UserData.ChannelLibraryRelatedIndexes = getRelatedChannelIndexes(channelObj, obj(ii));
                    end
                end
            end

            basicStats(obj)
            computeOccupancyPerBin(obj)
        end

        %-----------------------------------------------------------------%
        function addHashColumnToRelatedFilesTable(obj)
            % Criada coluna "Hash", facilitando atualização de instância de 
            % model.SpecData.
            for ii = 1:numel(obj)
                comparableData = cellstr( ...
                    string(obj(ii).RelatedFiles.File) + " - " + ...
                    string(obj(ii).RelatedFiles.Task) + " - " + ...
                    string(obj(ii).RelatedFiles.Id) + " - " + ...
                    string(obj(ii).RelatedFiles.Description) + " - " + ...
                    string(obj(ii).RelatedFiles.BeginTime) + " - " + ...
                    string(obj(ii).RelatedFiles.EndTime) + " - " + ...
                    string(obj(ii).RelatedFiles.NumSweeps) + " - " + ...
                    string(obj(ii).RelatedFiles.RevisitTime) + " - " + ...
                    string(jsonencode(obj(ii).GPS)) ...
                );
                
                obj(ii).RelatedFiles.Hash = cellfun(@(x) Hash.sha1(x), comparableData, 'UniformOutput', false);
            end
        end

        %-----------------------------------------------------------------%
        function msg = validateMergeRequirements(obj, flowIdxs)
            if isscalar(flowIdxs)
                error('model:SpecData:InvalidMergeRequirements', 'O processo de mesclagem requer ao menos dois fluxos espectrais.')
            end

            mergeTable = getSpectrumMergeTable(obj, flowIdxs);

            if ~isscalar(unique(mergeTable.Receiver)) || ~isscalar(unique(mergeTable.DataType)) || ~isscalar(unique(mergeTable.LevelUnit))               
                error('model:SpecData:InvalidMergeRequirements', [ ...
                    'Os fluxos espectrais a mesclar não atendem aos requisitos dos dois tipos de mesclagem implantados no <i>app</i>, quais sejam:\n\n'    ...
                    '• Tipo "co-channel": os fluxos devem possuir os campos "FreqStart", "FreqStop", "LevelUnit", "DataPoints" e "DataType" idênticos;\n\n' ...
                    '• Tipo "adjacent-channel": os fluxos devem estar relacionados a faixas de frequências adjacentes, podendo ter sobreposição espectral entre fluxos, além de possuírem os campos "LevelUnit", "NumSweeps" e "DataType" idênticos.'
                ])
            end

            if any(mergeTable.NumCoordinates == 0)
                error('model:SpecData:MissingMonitoringLocation', 'Ao menos um dos fluxos espectrais selecionados não pode ser mesclado por ser desconhecido o seu local da monitoração.')
            end

            resolutionList = unique(mergeTable.Resolution);
            stepWidthList  = unique(mergeTable.StepWidth);

            msg = {};
            if ~isscalar(resolutionList) && ~isscalar(stepWidthList)
                msg = arrayfun(@(x,y,z,w) sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (RBW), %.3f kHz (passo)', x, y, z, w), mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.Resolution/1000, mergeTable.StepWidth/1000, 'UniformOutput', false);
            elseif ~isscalar(resolutionList)
                msg = arrayfun(@(x,y,z)   sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (RBW)',                   x, y, z),    mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.Resolution/1000,                            'UniformOutput', false);
            elseif ~isscalar(stepWidthList)
                msg = arrayfun(@(x,y,z)   sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (passo)',                 x, y, z),    mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.StepWidth/1000,                             'UniformOutput', false);
            end

            % % ToDo: Migrar trecho p/ auxApp.winMisc...

            % if ~isempty(msg)
            %     msg = sprintf([ ...
            %         'Os fluxos espectrais a mesclar possuem valores diferentes de resolução ou passo da varredura.\n\n' ...
            %         '<font style="font-size: 11px;">%s</font>\n\nDeseja continuar esse processo de mesclagem, o que '   ...
            %         'resultará em um fluxo que armazenará como metadados os maiores valores de resolução e passo da varredura?' ...
            %     ], strjoin(msg, '\n'));
            % 
            %     userSelection = ui.Dialog(hFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            %     if userSelection == "Não"
            %         return
            %     end
            % end
        end

        %-----------------------------------------------------------------%
        function obj = mergeWith(obj, flowIdxs)            
            mergeTable = getSpectrumMergeTable(obj, flowIdxs);
            mergeType = model.SpecData.identifyMergeType(mergeTable);

            numFlows = numel(flowIdxs);
            isAzimuthTask = false;

            switch mergeType
                case 'co-channel'
                    idx = 1;
                    timestampArray = [];
                    levelMatrix = [];
                    azimuthMatrix = [];
                    azimuthTrustScore = [];
                    relatedFiles = [];

                    for ii = 1:numFlows
                        timestampArray = [timestampArray, obj(flowIdxs(ii)).Data{1}]; 
                        levelMatrix    = [levelMatrix,    obj(flowIdxs(ii)).Data{2}];
                        relatedFiles   = [relatedFiles;   obj(flowIdxs(ii)).RelatedFiles];

                        if numel(obj(flowIdxs(ii)).Data) == 5
                            isAzimuthTask     = true;
                            azimuthMatrix     = [azimuthMatrix,     obj(flowIdxs(ii)).Data{4}];
                            azimuthTrustScore = [azimuthTrustScore, obj(flowIdxs(ii)).Data{5}];
                        end
                    end
    
                    if ~issorted(timestampArray)
                        [timestampArray, sortIdxs] = sort(timestampArray);
                        levelMatrix = levelMatrix(:, sortIdxs);

                        if isAzimuthTask
                            azimuthMatrix     = azimuthMatrix(:, sortIdxs);
                            azimuthTrustScore = azimuthTrustScore(:, sortIdxs);
                        end
                    end

                    if ~issorted(relatedFiles.BeginTime)
                        relatedFiles = sortrows(relatedFiles, 'BeginTime');
                    end
    
                    obj(flowIdxs(idx)).Data{1}      = timestampArray;
                    obj(flowIdxs(idx)).GPS          = rmfield(gpsLib.summary(cell2mat(relatedFiles.GPS)), 'Matrix');
                    obj(flowIdxs(idx)).RelatedFiles = relatedFiles;

                case {'adjacent-channel', 'gap-adjacent-channel'}
                    stepWidthRef = mode(mergeTable.StepWidth);
                    [refNumSweeps, idx] = min(mergeTable.NumSweeps);
                    levelMatrix   = [];

                    for ii = 1:numFlows
                        newDataPoints = round((mergeTable.FreqStop(ii) - mergeTable.FreqStart(ii))/stepWidthRef + 1);
                        
                        x  = linspace(mergeTable.FreqStart(ii), mergeTable.FreqStop(ii), mergeTable.DataPoints(ii));
                        xq = linspace(mergeTable.FreqStart(ii), mergeTable.FreqStop(ii), newDataPoints);

                        if ii > 1
                            if (mergeTable.FreqStart(ii) ~= mergeTable.FreqStop(ii-1)) && ~isequal(unique(mergeTable.FreqStart(2:end)-mergeTable.FreqStop(1:end-1)), unique(mergeTable.StepWidth))
                                newFreqStart = mergeTable.FreqStop(ii-1);
                                newDataPoints = round((mergeTable.FreqStop(ii) - newFreqStart)/stepWidthRef + 1);
    
                                xq = linspace(newFreqStart, mergeTable.FreqStop(ii), newDataPoints);
                            end                            
                        end

                        if isequal(x, xq)
                            newDataMatrix = obj(flowIdxs(ii)).Data{2}(:, 1:refNumSweeps);
                        else
                            newDataMatrix = zeros(newDataPoints, refNumSweeps, 'single');

                            for jj = 1:refNumSweeps
                                refMinValue = min(obj(flowIdxs(ii)).Data{2}(:, jj));
                                newDataMatrix(:,jj) = interp1(x, obj(flowIdxs(ii)).Data{2}(:, jj), xq, "linear", refMinValue);
                            end
                        end

                        % Elimina o primeiro bin do conjunto de dados atual 
                        % pois ele coincide com o último do conjunto de dados 
                        % anterior.
                        if strcmp(mergeType, 'adjacent-channel') && (ii > 1)
                            newDataMatrix = newDataMatrix(2:end,:);
                        end

                        levelMatrix = [levelMatrix; newDataMatrix];
                    end

                    obj(flowIdxs(idx)).MetaData.DataPoints = height(levelMatrix);
                    obj(flowIdxs(idx)).MetaData.FreqStart  = min(mergeTable.FreqStart);
                    obj(flowIdxs(idx)).MetaData.FreqStop   = max(mergeTable.FreqStop);
            end

            obj(flowIdxs(idx)).MetaData.Resolution = max(unique(mergeTable.Resolution));
            obj(flowIdxs(idx)).Data{2}  = levelMatrix;
            
            if isAzimuthTask
                obj(flowIdxs(idx)).Data{4} = azimuthMatrix;
                obj(flowIdxs(idx)).Data{5} = azimuthTrustScore;
            end

            basicStats(obj(flowIdxs(idx)))

            obj(flowIdxs(idx)).UserData.OccupancyComputationMode.CacheIndex = [];
            computeOccupancyPerBin(obj(flowIdxs(idx)))

            % Exclui fluxos...
            othersIndex = setdiff(1:numFlows, idx);
            delete(obj(flowIdxs(othersIndex)))
            obj(flowIdxs(othersIndex)) = [];

            % Remapeia fluxos de espectro com fluxos de ocupação, caso
            % aplicável.
            occupancyMapping(obj)
        end

        %-----------------------------------------------------------------%
        function obj = applyFilter(obj, filterSpecification, filterMask)
            checkIfScalar(obj)

            obj.Data{1}(~filterMask)    = [];
            obj.Data{2}(:, ~filterMask) = [];
            basicStats(obj)

            if numel(obj.Data) == 5
                obj.Data{4}(:, ~filterMask) = [];
                obj.Data{5}(:, ~filterMask) = [];
            end

            obj.UserData.OccupancyComputationMode.CacheIndex = [];
            computeOccupancyPerBin(obj)

            obj.UserData.LOG{end+1} = jsonencode(filterSpecification);

            % Por fim, ajusta a informação da propriedade "RelatedFiles", 
            % que armazena o período de observação de cada arquivo, o número 
            % de amostras e uma estimativa do tempo de revisita.
            numRelatedFiles = height(obj.RelatedFiles);
            for ii = numRelatedFiles:-1:1
                sweepsIdxs = find((obj.Data{1} >= obj.RelatedFiles.BeginTime(ii)) & (obj.Data{1} <= obj.RelatedFiles.EndTime(ii)));
                
                if isempty(sweepsIdxs)
                    obj.RelatedFiles(ii, :) = [];
                else
                    beginTime   = obj.Data{1}(sweepsIdxs(1));
                    endTime     = obj.Data{1}(sweepsIdxs(end));
                    nSweeps     = numel(sweepsIdxs);
                    revisitTime = seconds(endTime-beginTime)/(nSweeps-1);

                    obj.RelatedFiles(ii, {'BeginTime', 'EndTime', 'NumSweeps', 'RevisitTime'}) = {beginTime, endTime, nSweeps, revisitTime};
                end
            end
        end

        %-----------------------------------------------------------------%
        function update(obj, propertyName, updateType, varargin)
            arguments
                obj
                propertyName char {mustBeMember(propertyName, {'GPS',                      ...
                                                               'UserData:AntennaHeight',   ...
                                                               'UserData:BandLimits',      ...
                                                               'UserData:Channel',         ...
                                                               'UserData:PlotDisplayConfig', ...
                                                               'UserData:Emissions',       ...
                                                               'UserData:OccupancyFields', ...
                                                               'UserData:ReportFields',    ...
                                                               'UserData:OccupancyFields+ReportFields'})}
                updateType
            end

            arguments (Repeating)
                varargin
            end

            switch propertyName
                case 'GPS' % Origem: auxApp.dockEditLocation
                    idxThreads = varargin{1};

                    switch updateType
                        case 'Refresh'
                            for ii = idxThreads
                                gpsData = cell2mat(obj(ii).RelatedFiles.GPS);
                                obj(ii).GPS = rmfield(gpsLib.summary(gpsData), 'Matrix');
                            end         

                        case 'ManualEdition'
                            newGPS = varargin{2};        
                            for ii = idxThreads
                                obj(ii).GPS = newGPS;
                            end

                        otherwise 
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                case 'UserData:BandLimits'
                    if ~isscalar(obj)
                        error('Unexpected non scalar object')
                    end

                    switch updateType
                        case 'Status:Edit'
                            obj.UserData.DetectionSubBandsEnabled = varargin{1};

                        case 'Table:Edit'
                            obj.UserData.DetectionSubBands = varargin{1};

                        case 'Table:DeleteRows'
                            obj.UserData.DetectionSubBands(varargin{1}, :) = [];

                        otherwise 
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                    hasEmissionsInSearchBand(obj)

                case 'UserData:AntennaHeight' % Origem: auxApp.dockEditLocation
                    idxThreads = varargin{1};
        
                    switch updateType
                        case 'Refresh'
                            for ii = idxThreads
                                newAntennaHeight = calculateAntennaHeight(obj, ii, -1, 'refreshValue');
                                obj(ii).UserData.AntennaHeightMeters = newAntennaHeight;
                            end

                        case 'ManualEdition'
                            newAntennaHeight = varargin{2};
                            for ii = idxThreads
                                obj(ii).UserData.AntennaHeightMeters = newAntennaHeight;
                            end

                        otherwise 
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                case 'UserData:Channel'
                    checkIfScalar(obj)

                    switch updateType
                        case 'ChannelLibIndex:Add'
                            channelObj = varargin{1};
                            obj.UserData.ChannelLibraryRelatedIndexes = FindRelatedBands(channelObj, obj);

                        case 'ChannelLibIndex:Edit'
                            idxChannel = varargin{1};
                            obj.UserData.ChannelLibraryRelatedIndexes = setdiff(obj.UserData.ChannelLibraryRelatedIndexes, idxChannel);

                        case 'ChannelManual:Refresh'
                            idxChannel = varargin{1};
                            obj.UserData.ChannelUserDefined(idxChannel) = [];

                        case 'ChannelManual:Edit'
                            % Pendente

                        otherwise 
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                case 'UserData:PlotDisplayConfig'
                    checkIfScalar(obj)

                    switch updateType
                        % CONTROLES GERAIS
                        case 'layoutRatio'
                            obj.UserData.PlotDisplayConfig.layoutRatio = varargin{1};                            
                        case { 'minHold', 'average', 'maxHold', 'persistence', 'occupancy', 'waterfall' }
                            obj.UserData.PlotDisplayConfig.controls.(updateType) = varargin{1};
                        
                        % PERSISTÊNCIA
                        case 'persistenceInterpolation'
                            obj.UserData.PlotDisplayConfig.persistence.interpolation = varargin{1};
                        case 'persistenceWindowSize'
                            obj.UserData.PlotDisplayConfig.persistence.windowSize = varargin{1};
                        case 'persistenceColormap'
                            obj.UserData.PlotDisplayConfig.persistence.colormap = varargin{1};
                        case 'persistenceTransparency'
                            obj.UserData.PlotDisplayConfig.persistence.transparency = varargin{1};
                        
                        % WATERFALL
                        case 'waterfallFunction'
                            obj.UserData.PlotDisplayConfig.waterfall.function = varargin{1};
                        case 'waterfallDecimation'
                            obj.UserData.PlotDisplayConfig.waterfall.decimation = varargin{1};
                        case 'waterfallColormap'
                            obj.UserData.PlotDisplayConfig.waterfall.colormap = varargin{1};
                        case 'waterfallMeshStyle'
                            obj.UserData.PlotDisplayConfig.waterfall.meshStyle = varargin{1};
                        
                        % LIMITES
                        case 'limitsXYCStartup'
                            bandObj = varargin{1};
                            obj.UserData.PlotDisplayConfig.limits.frequency.initial   = bandObj.XLimits;
                            obj.UserData.PlotDisplayConfig.limits.frequency.current   = bandObj.XLimits;            
                            obj.UserData.PlotDisplayConfig.limits.level.initial       = bandObj.YLimitsLevel;
                            obj.UserData.PlotDisplayConfig.limits.level.current       = bandObj.YLimitsLevel;            
                            obj.UserData.PlotDisplayConfig.limits.color.initial       = bandObj.CLimits;
                            obj.UserData.PlotDisplayConfig.limits.color.current       = bandObj.CLimits;

                        case 'limitsXYRefresh'
                            obj.UserData.PlotDisplayConfig.limits.frequency.current   = obj.UserData.PlotDisplayConfig.limits.frequency.initial;
                            obj.UserData.PlotDisplayConfig.limits.level.current       = obj.UserData.PlotDisplayConfig.limits.level.initial;     

                        case 'limitsX'
                            obj.UserData.PlotDisplayConfig.limits.frequency.current   = varargin{1};     

                        case 'limitsY'
                            obj.UserData.PlotDisplayConfig.limits.level.current       = varargin{1};

                        case 'limitsPersistence'
                            obj.UserData.PlotDisplayConfig.limits.persistence.mode    = 'manual';
                            obj.UserData.PlotDisplayConfig.limits.persistence.cLim    = varargin{1};

                        case 'limitsPersistenceRefresh'
                            obj.UserData.PlotDisplayConfig.limits.persistence.mode    = 'auto';
                            obj.UserData.PlotDisplayConfig.limits.persistence.cLim    = [];

                        case 'limitsWaterfallStartup'
                            obj.UserData.PlotDisplayConfig.limits.waterfall.initial   = varargin{1};
                            obj.UserData.PlotDisplayConfig.limits.waterfall.current   = varargin{1};

                        case 'limitsWaterfall'
                            obj.UserData.PlotDisplayConfig.limits.waterfall.current   = varargin{1};
                            
                        case 'limitsWaterfallRefresh'
                            obj.UserData.PlotDisplayConfig.limits.waterfall.current   = obj.UserData.PlotDisplayConfig.limits.waterfall.initial;

                        % DATA TIPS
                        % case 'dataTip'
                        %     obj.UserData.PlotDisplayConfig.Parameters.dataTips(end+1) = struct('ParentTag', varargin{1}, 'DataIndex', varargin{2});
                        % 
                        % case 'globalRefresh'
                        %     generalSettings = varargin{1};
                        %     obj.UserData.PlotDisplayConfig = model.UserData.getFieldTemplate('DefaultPlotDisplayConfig', generalSettings);

                        otherwise 
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                case 'UserData:Emissions'
                    checkIfScalar(obj)

                    switch updateType
                        case 'Add'
                            idxList     = varargin{1};
                            freqList    = varargin{2};
                            widthList   = varargin{3};
                            methodList  = varargin{4};
                            userComment = varargin{5};
                            channelObj  = varargin{6};

                            % Inicialmente, verifica se a ocupação por bin já foi aferida.
                            % Caso não, afere-se com os parâmetros padrão.
                            computeOccupancyPerBin(obj)
        
                            for ii = 1:numel(idxList)
                                idx = height(obj.UserData.Emissions) + 1;
                                obj.UserData.Emissions(idx, {'Frequency', 'FrequencyIdx', 'BandWidthkHz', 'IsTruncated'}) = {freqList(ii), idxList(ii), widthList(ii), true};

                                defaultChannelEmission = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idx, channelObj);

                                % Ideia abaixo é eliminar as emissões com características
                                % muito parecidas com a de outras emissões já inclusas.
                                hasMatchingFrequency = abs(obj.UserData.Emissions.Frequency(1:end-1) - obj.UserData.Emissions.Frequency(end)) <= .015; % 15kHz
                                hasMatchingBandWidth = abs(obj.UserData.Emissions.BandWidthkHz(1:end-1) - obj.UserData.Emissions.BandWidthkHz(end)) <= 30; % 30kHz
                                hasMatchingChannel = arrayfun(@(x) isequal(x, defaultChannelEmission.AutoSuggested), arrayfun(@(x) x.UserModified, obj.UserData.Emissions.ChannelAssigned(1:end-1)));
                                
                                if any(hasMatchingFrequency & hasMatchingBandWidth & hasMatchingChannel)
                                    obj.UserData.Emissions(idx, :) = [];
                                    continue
                                end
        
                                userDescription = "";
                                if ~isempty(userComment)
                                    userDescription = string(userComment{ii});
                                end        
                                obj.UserData.Emissions.Description(idx) = userDescription;
                                
                                obj.UserData.Emissions.Algorithms(idx) = struct( ...
                                    'Detection', methodList{ii}, ...
                                    'Classification', jsonencode(obj.UserData.ReportAlgorithms.Classification), ...
                                    'Occupancy', jsonencode(obj.UserData.ReportAlgorithms.Occupancy), ...
                                    'BandWidth', jsonencode(obj.UserData.ReportAlgorithms.BandWidth) ...
                                );
                                
                                obj.UserData.Emissions.ChannelAssigned(idx) = defaultChannelEmission;
                                obj.UserData.Emissions.Classification(idx) = model.UserData.getFieldTemplate('Classification', obj, 1, idx, channelObj);
                                
                                util.Measures(obj, 1, idx, 'Emission', channelObj)
                            end
        
                        case 'Edit'
                            parameter   = varargin{1};
                            idx = varargin{2};
                            channelObj  = varargin{end};
        
                            % A alteração das características de frequência e BW de uma emissão 
                            % demanda o recálculo das medidas. Além disso, ajusta-se o canal e
                            % a classificação, mas apenas quando tais valores não tinham sido 
                            % editados anteriormente.
                            
                            % Os parâmetros "isTruncated" e "Description" não demandam recálculo
                            % das medidas pois elas estão orientadas à frequência central da emissão
                            % e sua BW.
        
                            switch parameter
                                case {'Frequency', 'BandWidth', 'Frequency|BandWidth'}
                                    obj.UserData.Emissions.FrequencyIdx(idx) = varargin{3};
                                    obj.UserData.Emissions.Frequency(idx) = varargin{4};
                                    obj.UserData.Emissions.BandWidthkHz(idx) = varargin{5};

                                    obj.UserData.Emissions.Algorithms(idx).Detection = '{"Algorithm":"Manual"}';

                                    if isequal(obj.UserData.Emissions.ChannelAssigned(idx).AutoSuggested, obj.UserData.Emissions.ChannelAssigned(idx).UserModified)
                                        obj.UserData.Emissions.ChannelAssigned(idx) = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idx, channelObj);
                                    end

                                    if isequal(obj.UserData.Emissions.Classification(idx).AutoSuggested, obj.UserData.Emissions.Classification(idx).UserModified)
                                        obj.UserData.Emissions.Classification(idx) = model.UserData.getFieldTemplate('Classification',  obj, 1, idx, channelObj);
                                    end

                                    obj.UserData.Emissions.auxAppData(idx).DriveTest = [];
                                    util.Measures(obj, 1, idx, 'Emission', channelObj)

                                case 'IsTruncated'
                                    obj.UserData.Emissions.IsTruncated(idx) = varargin{3};

                                    obj.UserData.Emissions.ChannelAssigned(idx) = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idx, channelObj);

                                    if isequal(obj.UserData.Emissions.Classification(idx).AutoSuggested, obj.UserData.Emissions.Classification(idx).UserModified)
                                        obj.UserData.Emissions.Classification(idx) = model.UserData.getFieldTemplate('Classification',  obj, 1, idx, channelObj);
                                    end
                                    return

                                case 'Description'
                                    obj.UserData.Emissions.Description(idx) = varargin{3};
                                    return
                            end
        
                        case 'Delete'
                            idx = varargin{1};
        
                            obj.UserData.Emissions(idx, :) = [];
                            return

                        otherwise 
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                    hasEmissionsInSearchBand(obj)

                case 'UserData:OccupancyFields'
                    checkIfScalar(obj)

                    switch updateType
                        case 'SelectedHashChanged'
                            obj.UserData.OccupancyComputationMode.SelectedHash = varargin{1};
                        
                        case 'SelectedHashRefresh'
                            relatedHashes = obj.UserData.OccupancyComputationMode.RelatedHashes;
                            if ~isempty(relatedHashes)
                                obj.UserData.OccupancyComputationMode.SelectedHash = relatedHashes{1};
                            end

                        case 'AddToCacheRequest'
                            occParameters = varargin{1};
                            occThreshold  = RF.Occupancy.getThreshold(occParameters.Method, occParameters, obj, 'bin');
                            occData       = RF.Occupancy.run(obj.Data{1}, obj.Data{2}, occParameters.Method, occThreshold, occParameters.IntegrationTime);
                            occIndex      = numel(obj.UserData.OccupancyFiniteIntegrationCache) + 1;
            
                            obj.UserData.OccupancyComputationMode.CacheIndex = occIndex;
                            obj.UserData.OccupancyFiniteIntegrationCache(occIndex) = struct('Method', occParameters.Method, 'Parameters', occParameters, 'Threshold', occThreshold, 'Data', {occData});

                        case 'SelectedCacheChanged'
                            obj.UserData.OccupancyComputationMode.CacheIndex = varargin{1};

                        otherwise
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                case 'UserData:ReportFields'
                    switch updateType
                        case 'Creation'
                            idxThreads = varargin{1};
                            channelObj = varargin{2};
        
                            for ii = idxThreads
                                obj(ii).UserData.ReportInclude = true;
                                
                                % Ocupação
                                hasOccupancyPerBin(obj(ii))
                
                                % Detecção de emissões
                                FindPeaks(obj, ii, channelObj)
                            end

                        case 'Delete'
                            idxThreads = varargin{1};

                            for ii = idxThreads
                                obj(ii).UserData.ReportInclude = false;
                            end

                        case 'ReportOCC:Edit'
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end

                            occCache = varargin{1};
                            obj.UserData.ReportAlgorithms.Occupancy = occCache;

                        case 'ReportDetection:ManualMode:Edit'
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end

                            obj.UserData.ReportAlgorithms.Detection.ManualMode = varargin{1};

                        otherwise
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end

                case 'UserData:OccupancyFields+ReportFields'
                    switch updateType
                        case 'Refresh'
                            idxThreads = varargin{1};
                            channelObj = varargin{2};

                            for ii = idxThreads
                                if ~isempty(obj(ii).UserData.OccupancyComputationMode.CacheIndex)
                                    obj(ii).UserData.OccupancyComputationMode.CacheIndex = [];
                                    obj(ii).UserData.OccupancyFiniteIntegrationCache     = struct('Parameters', {}, 'Threshold', {}, 'Data', {});

                                    update(obj, 'UserData:ReportFields', 'Creation', ii, channelObj)
                                end
                            end

                        otherwise
                            error('model:specData:UnexpectedUpdateType', 'Unexpected update type "%s"', updateType)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function computeOccupancyPerBin(obj)
            for ii = 1:numel(obj)
                if ~isempty(obj(ii).UserData.OccupancyComputationMode.CacheIndex) && isequal(size(obj(ii).UserData.OccupancyCumulativeIntegration), size(obj(ii).Data{2}))
                    continue
                end

                occupancyParameters = RF.Occupancy.getDefaultParameters();
                occupancyThreshold = RF.Occupancy.getThreshold(occupancyParameters.Method, occupancyParameters, obj(ii), 'bin');
                occupancyData = RF.Occupancy.run(obj(ii).Data{1}, obj(ii).Data{2}, occupancyParameters.Method, occupancyThreshold, occupancyParameters.IntegrationTime);

                obj(ii).UserData.OccupancyComputationMode.CacheIndex = 1;
                obj(ii).UserData.OccupancyFiniteIntegrationCache = struct('Method', occupancyParameters.Method, 'Parameters', occupancyParameters, 'Threshold', occupancyThreshold, 'Data', {occupancyData});
                obj(ii).UserData.OccupancyCumulativeIntegration = obj(ii).Data{2} > occupancyThreshold;
            end
        end

        %-----------------------------------------------------------------%
        % Toda vez que é incluída emissão à tabela, ou editada, verifica-se
        % se a emissão consta no trecho espectral pesquisável do fluxo sob
        % análise ou se já existe emissão com o mesmo canal.
        %-----------------------------------------------------------------% 
        function hasEmissionsInSearchBand(obj)
            for ii = 1:numel(obj)
                bandLimitsStatus = obj(ii).UserData.DetectionSubBandsEnabled;
                bandLimitsTable  = obj(ii).UserData.DetectionSubBands;
                emissionsTable   = obj(ii).UserData.Emissions;
            
                if bandLimitsStatus && ~isempty(bandLimitsTable)
                    for jj = height(emissionsTable):-1:1
                        emissionsInSearchableBand = any((emissionsTable.Frequency(jj) >= bandLimitsTable.FreqStart) & (emissionsTable.Frequency(jj) <= bandLimitsTable.FreqStop));

                        if ~emissionsInSearchableBand
                            emissionsTable(jj, :) = [];
                        end
                    end
                end

                % Insere a coluna "Base64", que retorna um Hash do tag da emissão, no
                % formato "100.300 MHz ⌂ 256.0 kHz", por exemplo. Esse Hash é usado p/
                % identificar as emissões únicas.
                emissionHashs  = cellfun(@(x) Hash.sha1(x), arrayfun(@(x, y) sprintf('%.3f MHz ⌂ %.1f kHz', x, y), emissionsTable.Frequency, emissionsTable.BandWidthkHz, "UniformOutput", false), 'UniformOutput', false);
                [~, hashIdxs]  = unique(emissionHashs);
                emissionsTable = sortrows(emissionsTable(hashIdxs, :), {'FrequencyIdx', 'BandWidthkHz'});

                obj(ii).UserData.Emissions = emissionsTable;
            end
        end

        %-----------------------------------------------------------------%
        function antennaHeight = calculateAntennaHeight(obj, idx, referenceValue, operationType)
            arguments
                obj
                idx
                referenceValue = -1
                operationType  char {mustBeMember(operationType, {'initialValue', 'getCurrentValue', 'refreshValue'})} = 'getCurrentValue'
            end

            antennaHeight = NaN;

            if strcmp(operationType, 'getCurrentValue') && ~isempty(obj(idx).UserData.AntennaHeightMeters)
                antennaHeight = obj(idx).UserData.AntennaHeightMeters;
                
            elseif isfield(obj(idx).MetaData.Antenna, 'Height')
                initialHeight = obj(idx).MetaData.Antenna.Height;

                if isnumeric(initialHeight) && isfinite(initialHeight) && (initialHeight > 0)
                    antennaHeight = initialHeight;
                elseif ischar(initialHeight)
                    antennaHeight = str2double(extractBefore(initialHeight, 'm'));
                end
            end

            if isnan(antennaHeight)
                antennaHeight = referenceValue;
            end
        end

        %-----------------------------------------------------------------%
        function FindPeaks(obj, idx, channelObj)
            findPeaks = FindPeaksOfPrimaryBand(channelObj, obj(idx));

            if ~isempty(findPeaks)
                obj(idx).UserData.ReportAlgorithms.Detection.Parameters = struct( ...
                    'Distance_kHz', 1000 * findPeaks.Distance, ...          % MHz >> kHz
                    'BW_kHz',       1000 * findPeaks.BW, ...                % MHz >> kHz
                    'Prominence1',  findPeaks.Prominence1, ...
                    'Prominence2',  findPeaks.Prominence2, ...
                    'meanOCC',      findPeaks.meanOCC, ...
                    'maxOCC',       findPeaks.maxOCC ...
                );
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function obj = deleteObsoleteFlows(obj, referenceTable, uniqueHashs, uniqueHashIdxs)
            % Exclui fluxos de specData cujos arquivos de suporte não existem mais.
            % Exceção aos fluxos mesclados manualmente pelo usuário (IsUserMerged),
            % que são criados e apagados APENAS pela GUI.
            %
            % Para cada fluxo não mesclado:
            %   - Se o Hash não existe mais em uniqueHashs, apaga o fluxo
            %   - Se o Hash existe mas alguns arquivos foram removidos, limpa esses
            %     arquivos e invalida o cache de dados (Data)
            %   - Se o Hash existe e ningum arquivo foi removido, apenas limpa
            %
            % InputFiles será reconstruído na segunda etapa de syncCollection.

            for ii = numel(obj):-1:1
                if any([obj(ii).InputFiles.IsUserMerged])
                    continue
                end

                [~, hashIdx] = ismember(obj(ii).Hash, uniqueHashs);

                if hashIdx
                    % Reúne todos os arquivos ainda válidos para este Hash
                    flowRefRelatedFiles = referenceTable.RelatedFiles(uniqueHashIdxs == hashIdx);
                    if ~isscalar(flowRefRelatedFiles)
                        flowRefRelatedFiles = vertcat(flowRefRelatedFiles{:});
                    end

                    % Remove arquivos relacionados que não existem mais
                    obsoleteFilesMatch = ~ismember(obj(ii).RelatedFiles.File, flowRefRelatedFiles);
                    if any(obsoleteFilesMatch)
                        obj(ii).Data = {};
                        obj(ii).RelatedFiles(obsoleteFilesMatch, :) = [];
                    end
                end

                if ~hashIdx || isempty(obj(ii).RelatedFiles)
                    delete(obj(ii))
                    obj(ii) = [];
                else
                    obj(ii).InputFiles(:) = [];
                end
            end
        end

        %-----------------------------------------------------------------%
        function candidateIdx = findMergeableFlow(obj, flowHash, referenceTable, refTableIdx, newFlowRelatedFiles, generalSettings)
            % Procura um fluxo existente que pode ser mesclado com o novo fluxo.
            % Retorna o índice do fluxo candidato, ou [] se nenhum for encontrado.
            % 
            % Critério de mesclagem:
            % - Mesmo Hash + proximidade geográfica (< maxCoLocationDistanceMeters) 
            %   + timestamps não sobrepostos
            
            candidateIdx = [];
            
            objIdxs = find(strcmp({obj.Hash}, flowHash));
            if isempty(objIdxs)
                return
            end
            
            flowLat = referenceTable.Latitude(refTableIdx);
            flowLng = referenceTable.Longitude(refTableIdx);
            
            for ii = objIdxs
                if all(ismember(newFlowRelatedFiles.Hash, obj(ii).RelatedFiles.Hash))
                    candidateIdx = ii;
                    return
                end

                % Critério: Proximidade geográfica + timestamps não sobrepostos
                distanceMeters = deg2km(distance(obj(ii).GPS.Latitude, obj(ii).GPS.Longitude, flowLat, flowLng)) * 1000;
                
                if distanceMeters <= generalSettings.context.FILE.spectrumConsolidationPolicy.maxCoLocationDistanceMeters
                    % Verifica sobreposição de timestamps
                    if ~model.SpecData.hasTimestampOverlap(obj(ii).RelatedFiles, newFlowRelatedFiles)
                        candidateIdx = ii;
                        return
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function checkIfScalar(obj)
            if ~isscalar(obj)
                error('model:SpecData:ScalarObjectRequired', 'This method requires a scalar object.');
            end
        end

        %-----------------------------------------------------------------%
        function occupancyMapping(obj)
            dataTypes = arrayfun(@(x) x.MetaData.DataType, obj);
            occupancyFlowIdxs = find(ismember(dataTypes, class.Constants.occDataTypes));
            
            for ii = 1:numel(obj)
                if ismember(obj(ii).MetaData.DataType, class.Constants.occDataTypes)
                    continue
                end

                relatedHashes = {};
                selectedHash = obj(ii).UserData.OccupancyComputationMode.SelectedHash;

                for jj = occupancyFlowIdxs
                    hasSameMetaData = ...
                        strcmp(obj(ii).Receiver, obj(jj).Receiver) && ...
                        obj(ii).MetaData.FreqStart == obj(jj).MetaData.FreqStart && ...
                        obj(ii).MetaData.FreqStop == obj(jj).MetaData.FreqStop && ...
                        obj(ii).MetaData.DataPoints == obj(jj).MetaData.DataPoints;

                    if hasSameMetaData
                        relatedHashes{end+1} = obj(jj).Hash;
                    end
                end

                if isempty(relatedHashes)
                    selectedHash = '';
                elseif ~ismember(selectedHash, relatedHashes)
                    selectedHash = relatedHashes{1};
                end

                obj(ii).UserData.OccupancyComputationMode.RelatedHashes = relatedHashes;
                obj(ii).UserData.OccupancyComputationMode.SelectedHash = selectedHash;
            end
        end

        %-----------------------------------------------------------------%
        function mergeTable = getSpectrumMergeTable(obj, flowIdxs)
            numFlows = numel(flowIdxs);
            mergeTable = table( ...
                'Size', [numFlows, 10], ...
                'VariableTypes', {'cell', 'double', 'double', 'double', 'cell', 'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'Receiver', 'DataType', 'FreqStart', 'FreqStop', 'LevelUnit', 'DataPoints', 'StepWidth', 'Resolution', 'NumSweeps', 'NumCoordinates'} ...
            );

            for ii = 1:numFlows
                idx = flowIdxs(ii);
                
                mergeTable(ii,:) = {
                    obj(idx).Receiver, ...
                    obj(idx).MetaData.DataType, ...
                    obj(idx).MetaData.FreqStart, ...
                    obj(idx).MetaData.FreqStop, ...
                    obj(idx).MetaData.LevelUnit, ...
                    obj(idx).MetaData.DataPoints, ...
                    (obj(idx).MetaData.FreqStop - obj(idx).MetaData.FreqStart) / (obj(idx).MetaData.DataPoints - 1), ...
                    obj(idx).MetaData.Resolution, ...
                    sum(obj(idx).RelatedFiles.NumSweeps), ...
                    obj(idx).GPS.Count ...
                };
            end
            
            mergeTable = sortrows(mergeTable, {'FreqStart', 'FreqStop'});
        end
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function mergeType = identifyMergeType(mergeTable)
            if isscalar(unique(mergeTable.FreqStart)) && ...
               isscalar(unique(mergeTable.FreqStop))  && ...
               isscalar(unique(mergeTable.DataPoints))
                mergeType = 'co-channel';

            elseif issorted(mergeTable.FreqStart, "strictascend") && ...
               all(mergeTable.FreqStart(2:height(mergeTable)) <= mergeTable.FreqStop(1:height(mergeTable)-1))
                mergeType = 'adjacent-channel';
            
            elseif issorted(mergeTable.FreqStart, "strictascend") && ...
                   issorted(mergeTable.FreqStop,  "strictascend")
                mergeType = 'gap-adjacent-channel';
            
            else
                error('model:SpecData:InvalidMergeRequirements', [ ...
                    'Os fluxos espectrais a mesclar não atendem aos requisitos dos dois tipos de mesclagem implantados no <i>app</i>, quais sejam:\n\n'    ...
                    '• Tipo "co-channel": os fluxos devem possuir os campos "FreqStart", "FreqStop", "LevelUnit", "DataPoints" e "DataType" idênticos;\n\n' ...
                    '• Tipo "adjacent-channel": os fluxos devem estar relacionados a faixas de frequências adjacentes, podendo ter sobreposição espectral entre fluxos, além de possuírem os campos "LevelUnit", "NumSweeps" e "DataType" idênticos.'
                ])
            end
        end

        %-----------------------------------------------------------------%
        function overlap = hasTimestampOverlap(existingRelatedFiles, newRelatedFiles)
            arguments
                existingRelatedFiles table
                newRelatedFiles table
            end

            % Verifica se há sobreposição de timestamps entre dois conjuntos
            % de arquivos relacionados.
            % Retorna true se houver sobreposição, false caso contrário.
            
            overlap = false;
            
            for ii = 1:height(newRelatedFiles)
                newBegin = newRelatedFiles.BeginTime(ii);
                newEnd   = newRelatedFiles.EndTime(ii);
                
                for jj = 1:height(existingRelatedFiles)
                    existBegin = existingRelatedFiles.BeginTime(jj);
                    existEnd   = existingRelatedFiles.EndTime(jj);
                    
                    % Verifica se há sobreposição entre os períodos
                    % Sobreposição ocorre quando: newBegin <= existEnd AND newEnd >= existBegin
                    if newBegin <= existEnd && newEnd >= existBegin
                        overlap = true;
                        return
                    end
                end
            end
        end
    end
end