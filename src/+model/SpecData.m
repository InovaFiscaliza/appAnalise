classdef SpecData < model.SpecDataBase

    % ## model.SpecData (appAnalise) ##
    % PUBLIC
    %   ├── syncCollection
    %   |   └── buildSpectrumReferenceTable (model.MetaData)
    %   ├── populateSpectrum
    %   │   │── buildSpectrumReferenceTable (model.MetaData)
    %   │   │── preallocateData             (model.SpecDataBase)
    %   │   │── read                        (model.SpecDataBase)
    %   │   └── basicStats                  (model.SpecDataBase)
    %   ├── mergeWith ⚠️
    %   ├── applyFilter
    %   ├── update ⚠️
    %   ├── hasOccupancyPerBin ⚠️
    %   ├── hasEmissionsInSearchBand ⚠️
    %   ├── calculateAntennaHeight
    %   └── FindPeaks ⚠️

    % PRIVATE
    %   ├── checkIfScalar
    %   ├── createFlow
    %   ├── occupancyMapping
    %   └── buildSpectrumReferenceTableByCriteria

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
    
        % "IsMerged" indica se o fluxo foi gerado por mesclagem MANUAL via 
        % GUI. Ressalta-se, contudo, que os fluxos com mesmo Hash podem ser 
        % mesclados automaticamente, a depender da distância limite definida 
        % em arquivo de configuração ".\src\config\GeneralSettings.json".
        IsMerged (1,1) logical = false
    
        % "MergedeSources" armazena informações das fontes utilizadas na 
        % mesclagem MANUAL, quando aplicável.
        MergedSources struct = struct('Hash', {}, 'File', {})
    
        % "UserData" contém informações relacionadas à GUI, incluindo a lista
        % de emissões e customizações de plot.
        UserData = model.UserData
    end
    

    methods
        %-----------------------------------------------------------------%
        function obj = syncCollection(obj, metaData, generalSettings)
            % Identifica fluxos espectrais presentes nos diversos arquivos.
            referenceTable = buildSpectrumReferenceTable(metaData, generalSettings);
            [uniqueHashs, ~, uniqueHashIdxs] = unique(referenceTable.Hash, 'stable');

            % Exclui fluxos de specData, caso não mais existentes arquivos
            % que os suportam. Exceção aos fluxos mesclados, que são criados
            % e apagados APENAS manualmente.
            for ii = numel(obj):-1:1
                if obj(ii).IsMerged
                    continue
                end

                [~, hashIdx] = ismember(obj(ii).Hash, uniqueHashs);

                if hashIdx
                    flowRefRelatedFiles = referenceTable.RelatedFiles(uniqueHashIdxs == hashIdx);
                    if ~isscalar(flowRefRelatedFiles)
                        flowRefRelatedFiles = vertcat(flowRefRelatedFiles{:});
                    end

                    obj(ii).RelatedFiles(~ismember(obj(ii).RelatedFiles.File, flowRefRelatedFiles), :) = [];
                end

                if ~hashIdx || isempty(obj(ii).RelatedFiles)
                    delete(obj(ii))
                    obj(ii) = [];
                end
            end

            % Atualiza specData, editando fluxos atuais e includindo novos, 
            % caso aplicável.
            for ii = 1:numel(uniqueHashs)
                flowHash = uniqueHashs{ii};
                flowHashIdxs = find(uniqueHashIdxs == ii)';

                for jj = flowHashIdxs
                    fileName = referenceTable.File{jj};
                    fileIdx  = referenceTable.Idx{jj}{1}(1);
                    flowIdx  = referenceTable.Idx{jj}{1}(2);
                    flowLat  = referenceTable.Latitude(jj);
                    flowLng  = referenceTable.Longitude(jj);

                    idxs = find(strcmp({obj.Hash}, flowHash));
                    if isempty(idxs)
                        obj = createFlow(obj, metaData, fileIdx, flowIdx, flowHash, fileName);
                        continue
                    end

                    neededNewFlow = true;
                    for kk = idxs
                        if all(ismember(referenceTable.RelatedFiles(jj), obj(kk).RelatedFiles.File))
                            neededNewFlow = false;
                            break

                        else
                            distanceMeters = deg2km(distance(obj(kk).GPS.Latitude, obj(kk).GPS.Longitude, flowLat, flowLng)) * 1000;
                            if distanceMeters <= generalSettings.context.FILE.spectrumConsolidationPolicy.maxCoLocationDistanceMeters
                                neededNewFlow = false;
    
                                obj(kk).Data = {};
                                obj(kk).GPS = rmfield(gpsLib.summary(cell2mat(obj(kk).RelatedFiles.GPS)), 'Matrix');
                                obj(kk).RelatedFiles = [obj(kk).RelatedFiles; metaData(fileIdx).Data(flowIdx).RelatedFiles];
                                break
                            end
                        end
                    end

                    if neededNewFlow
                        obj = createFlow(obj, metaData, fileIdx, flowIdx, flowHash, fileName);
                    end
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
            referenceTable = buildSpectrumReferenceTable(metaData, generalSettings);

            for ii = 1:numel(obj)
                if ~isempty(obj(ii).Data) && (numel(obj(ii).Data{1}) == sum(obj(ii).RelatedFiles.NumSweeps))
                    continue
                end

                hashIdxs = find(strcmp(referenceTable.Hash, obj(ii).Hash));
    
                % Pré-aloca propriedade "Data" que registra timestamp, valores 
                % de níveis, azimutes etc.
                fileFormatName = '';
                try
                    fileFormatName = jsondecode(obj(ii).MetaData.Others).FileFormat;
                catch
                end
                preallocateData(obj(ii), fileFormatName);

                for jj = 1:numel(hashIdxs)
                    fileIdx  = referenceTable.Idx{hashIdxs(jj)}{1}(1);
                    flowIdx  = referenceTable.Idx{hashIdxs(jj)}{1}(2);
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
                % - "ReportAlgorithms.Detection"
                if isempty(obj(ii).UserData.PlotDisplayConfig)
                    obj(ii).UserData.AntennaHeightMeters = calculateAntennaHeight(obj, ii, -1, 'initialValue');
                    obj(ii).UserData.ReportAlgorithms.Detection = model.UserData.getFieldTemplate('DefaultAlgorithm: Detection', generalSettings.context.PLAYBACK.detection.manualMode);
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
        function obj = mergeWith(obj, flowIdxs, hFigure)
            % "obj" como saída é ESSENCIAL para garantir que tenha efeito
            % a diretriz: obj(idxThreads(2:nThreads)) = []; 

            % PROIBIR QUE SEJAM MESCLADOS FLUXOS QUE I TIMESTAMP SE
            % SOBREPÕE.


            arguments 
                obj
                flowIdxs
                hFigure    (1,1) matlab.ui.Figure
            end
            
            % <VALIDATION>
            if numel(flowIdxs) < 2
                error([ ...
                    'Os fluxos espectrais a mesclar não atendem aos requisitos dos dois tipos de mesclagem implantados no <i>app</i>, quais sejam:\n\n'    ...
                    '• Tipo "co-channel": os fluxos devem possuir os campos "FreqStart", "FreqStop", "LevelUnit", "DataPoints" e "DataType" idênticos;\n\n' ...
                    '• Tipo "adjacent-channel": os fluxos devem estar relacionados a faixas de frequências adjacentes, podendo ter sobreposição espectral entre fluxos, além de possuírem os campos "LevelUnit", "nSweeps" e "DataType" idênticos.'
                ])
            end

            mergeTable = buildSpectrumReferenceTableByCriteria(obj, flowIdxs);

            if ~isscalar(unique(mergeTable.Receiver)) || ~isscalar(unique(mergeTable.DataType)) || ~isscalar(unique(mergeTable.LevelUnit))               
                error([ ...
                    'Os fluxos espectrais a mesclar não atendem aos requisitos dos dois tipos de mesclagem implantados no <i>app</i>, quais sejam:\n\n'    ...
                    '• Tipo "co-channel": os fluxos devem possuir os campos "FreqStart", "FreqStop", "LevelUnit", "DataPoints" e "DataType" idênticos;\n\n' ...
                    '• Tipo "adjacent-channel": os fluxos devem estar relacionados a faixas de frequências adjacentes, podendo ter sobreposição espectral entre fluxos, além de possuírem os campos "LevelUnit", "nSweeps" e "DataType" idênticos.'
                ])
            end

            if any(mergeTable.NumCoordinates == 0)
                error('Ao menos um dos fluxos espectrais selecionados não pode ser mesclado por ser desconhecido o seu local da monitoração.')
            end

            resolutionList = unique(mergeTable.Resolution);
            stepWidthList  = unique(mergeTable.StepWidth);

            msgQuestion = {};
            if ~isscalar(resolutionList) && ~isscalar(stepWidthList)
                msgQuestion = arrayfun(@(x,y,z,w) sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (RBW), %.3f kHz (passo)', x, y, z, w), mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.Resolution/1000, mergeTable.StepWidth/1000, 'UniformOutput', false);
            elseif ~isscalar(resolutionList)
                msgQuestion = arrayfun(@(x,y,z)   sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (RBW)',                   x, y, z),    mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.Resolution/1000,                            'UniformOutput', false);
            elseif ~isscalar(stepWidthList)
                msgQuestion = arrayfun(@(x,y,z)   sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (passo)',                 x, y, z),    mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.StepWidth/1000,                             'UniformOutput', false);
            end

            if ~isempty(msgQuestion)
                msgQuestion = sprintf(['Os fluxos espectrais a mesclar possuem valores diferentes de resolução ou passo da varredura.\n\n' ...
                                       '<font style="font-size: 11px;">%s</font>\n\nDeseja continuar esse processo de mesclagem, o que '   ...
                                       'resultará em um fluxo que armazenará como metadados os maiores valores de resolução e passo da varredura?'], strjoin(msgQuestion, '\n'));
                
                userSelection = ui.Dialog(hFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
                if userSelection == "Não"
                    return
                end
            end
            % </VALIDATION>
            
            % <PROCESS>
            mergeType  = identifyMergeType(mergeTable);
            nThreads   = numel(flowIdxs);
            azTaskFlag = false;

            switch mergeType
                case 'co-channel'
                    refIndex     = 1;
                    timeArray    = [];
                    dataMatrix   = [];
                    azimuth      = [];
                    trustLevel   = [];
                    relatedFiles = [];

                    for ii = 1:nThreads
                        timeArray    = [timeArray,    obj(flowIdxs(ii)).Data{1}]; 
                        dataMatrix   = [dataMatrix,   obj(flowIdxs(ii)).Data{2}];
                        relatedFiles = [relatedFiles; obj(flowIdxs(ii)).RelatedFiles];

                        if numel(obj(flowIdxs(ii)).Data) == 5
                            azTaskFlag = true;
                            azimuth    = [azimuth,    obj(flowIdxs(ii)).Data{4}];
                            trustLevel = [trustLevel, obj(flowIdxs(ii)).Data{5}];
                        end
                    end
    
                    if ~issorted(timeArray)
                        [timeArray, idxSort] = sort(timeArray);
                        dataMatrix = dataMatrix(:,idxSort);

                        if azTaskFlag
                            azimuth    = azimuth(:,idxSort);
                            trustLevel = trustLevel(:,idxSort);
                        end
                    end

                    if ~issorted(relatedFiles.BeginTime)
                        relatedFiles = sortrows(relatedFiles, 'BeginTime');
                    end
    
                    obj(flowIdxs(refIndex)).Data{1}      = timeArray;
                    obj(flowIdxs(refIndex)).GPS          = rmfield(gpsLib.summary(cell2mat(relatedFiles.GPS)), 'Matrix');
                    obj(flowIdxs(refIndex)).RelatedFiles = relatedFiles;

                case {'adjacent-channel', 'gap-adjacent-channel'}
                    stepWidthRef = mode(mergeTable.StepWidth);
                    [refNumSweeps, refIndex] = min(mergeTable.NumSweeps);
                    dataMatrix   = [];

                    for ii = 1:nThreads
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

                        dataMatrix = [dataMatrix; newDataMatrix];
                    end

                    obj(flowIdxs(refIndex)).MetaData.DataPoints = height(dataMatrix);
                    obj(flowIdxs(refIndex)).MetaData.FreqStart  = min(mergeTable.FreqStart);
                    obj(flowIdxs(refIndex)).MetaData.FreqStop   = max(mergeTable.FreqStop);
            end

            obj(flowIdxs(refIndex)).MetaData.Resolution = max(resolutionList);
            obj(flowIdxs(refIndex)).Data{2}  = dataMatrix;
            basicStats(obj(flowIdxs(refIndex)))

            if azTaskFlag
                obj(flowIdxs(refIndex)).Data{4} = azimuth;
                obj(flowIdxs(refIndex)).Data{5} = trustLevel;
            end

            othersIndex = setdiff(1:nThreads, refIndex);
            delete(obj(flowIdxs(othersIndex)))
            obj(flowIdxs(othersIndex)) = [];

            occupancyMapping(obj)
            % </PROCESS>
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

                case 'UserData:Emissions' % Origem: winAppAnalise
                    checkIfScalar(obj)

                    switch updateType
                        case 'Add'
                            idxFreq     = varargin{1};
                            FreqCenter  = varargin{2};
                            BandWidth   = varargin{3};
                            Detection   = varargin{4};
                            Description = varargin{5};
                            channelObj  = varargin{end};

                            % Inicialmente, verifica se a ocupação por bin já foi aferida.
                            % Caso não, afere-se com os parâmetros padrão.
                            computeOccupancyPerBin(obj)
        
                            for ii = 1:numel(idxFreq)
                                idxEmission = height(obj.UserData.Emissions) + 1;
                                obj.UserData.Emissions(idxEmission, 1:4) = table(idxFreq(ii), FreqCenter(ii), BandWidth(ii), true);

                                defaultChannelEmission  = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idxEmission, channelObj);

                                % Ideia abaixo é eliminar as emissões com características
                                % muito parecidas com a de outras emissões já inclusas.
                                hasMatchingFrequency    = abs(obj.UserData.Emissions.Frequency(1:end-1) - obj.UserData.Emissions.Frequency(end)) <= .015; % 15kHz
                                hasMatchingBandWidth    = abs(obj.UserData.Emissions.BW_kHz(1:end-1)    - obj.UserData.Emissions.BW_kHz(end))    <= 30;   % 30kHz
                                hasMatchingChannel      = arrayfun(@(x) isequal(x, defaultChannelEmission.autoSuggested), arrayfun(@(x) x.userModified, obj.UserData.Emissions.ChannelAssigned(1:end-1)));
                                
                                if any(hasMatchingFrequency & hasMatchingBandWidth & hasMatchingChannel)
                                    obj.UserData.Emissions(idxEmission, :) = [];
                                    continue
                                end
        
                                userDescription = "";
                                if ~isempty(Description)
                                    userDescription = string(Description{ii});
                                end        
                                obj.UserData.Emissions.Description(idxEmission)               = userDescription;
                                
                                obj.UserData.Emissions.Algorithms(idxEmission).Detection      = Detection{ii};
                                obj.UserData.Emissions.Algorithms(idxEmission).Classification = jsonencode(obj.UserData.ReportAlgorithms.Classification);
                                obj.UserData.Emissions.Algorithms(idxEmission).Occupancy      = jsonencode(obj.UserData.ReportAlgorithms.Occupancy);
                                
                                obj.UserData.Emissions.ChannelAssigned(idxEmission)           = defaultChannelEmission;
                                obj.UserData.Emissions.Classification(idxEmission)            = model.UserData.getFieldTemplate('Classification',  obj, 1, idxEmission, channelObj);
                                
                                util.Measures(obj, 1, idxEmission, 'Emission', channelObj)
                            end
        
                        case 'Edit'
                            parameter   = varargin{1};
                            idxEmission = varargin{2};
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
                                    obj.UserData.Emissions.idxFrequency(idxEmission)         = varargin{3};
                                    obj.UserData.Emissions.Frequency(idxEmission)            = varargin{4};
                                    obj.UserData.Emissions.BW_kHz(idxEmission)               = varargin{5};

                                    obj.UserData.Emissions.Algorithms(idxEmission).Detection = '{"Algorithm":"Manual"}';

                                    if isequal(obj.UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, obj.UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                                        obj.UserData.Emissions.ChannelAssigned(idxEmission)  = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idxEmission, channelObj);
                                    end

                                    if isequal(obj.UserData.Emissions.Classification(idxEmission).autoSuggested, obj.UserData.Emissions.Classification(idxEmission).userModified)
                                        obj.UserData.Emissions.Classification(idxEmission)   = model.UserData.getFieldTemplate('Classification',  obj, 1, idxEmission, channelObj);
                                    end

                                    obj.UserData.Emissions.auxAppData(idxEmission).DriveTest = [];
                                    util.Measures(obj, 1, idxEmission, 'Emission', channelObj)

                                case 'IsTruncated'
                                    obj.UserData.Emissions.isTruncated(idxEmission)          = varargin{3};

                                    obj.UserData.Emissions.ChannelAssigned(idxEmission)      = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idxEmission, channelObj);

                                    if isequal(obj.UserData.Emissions.Classification(idxEmission).autoSuggested, obj.UserData.Emissions.Classification(idxEmission).userModified)
                                        obj.UserData.Emissions.Classification(idxEmission)   = model.UserData.getFieldTemplate('Classification',  obj, 1, idxEmission, channelObj);
                                    end
                                    return

                                case 'Description'
                                    obj.UserData.Emissions.Description(idxEmission)          = varargin{3};
                                    return
                            end
        
                        case 'Delete'
                            idxEmissions = varargin{1};
        
                            obj.UserData.Emissions(idxEmissions, :) = [];
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

                occParameters = RF.Occupancy.getDefaultParameters();
                occThreshold  = RF.Occupancy.getThreshold(occParameters.Method, occParameters, obj(ii), 'bin');
                occData       = RF.Occupancy.run(obj(ii).Data{1}, obj(ii).Data{2}, occParameters.Method, occThreshold, occParameters.IntegrationTime);

                obj(ii).UserData.OccupancyComputationMode.CacheIndex = 1;
                obj(ii).UserData.OccupancyFiniteIntegrationCache     = struct('Method', occParameters.Method, 'Parameters', occParameters, 'Threshold', occThreshold, 'Data', {occData});

                occParameters.IntegrationTime = inf;
                obj(ii).UserData.OccupancyCumulativeIntegration      = struct('Method', occParameters.Method, 'Parameters', occParameters, 'Threshold', occThreshold, 'Matrix', obj(ii).Data{2} > occThreshold);
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
                emissionsBase64Hash = cellfun(@(x) Hash.base64encode(x), arrayfun(@(x, y) sprintf('%.3f MHz ⌂ %.1f kHz', x, y), emissionsTable.Frequency, emissionsTable.BW_kHz, "UniformOutput", false), 'UniformOutput', false);
                [~, uniqueIndex]    = unique(emissionsBase64Hash);
                emissionsTable      = sortrows(emissionsTable(uniqueIndex, :), {'idxFrequency', 'BW_kHz'});

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
        function checkIfScalar(obj)
            if ~isscalar(obj)
                error('model:SpecData:ScalarObjectRequired', 'This method requires a scalar object.');
            end
        end

        %-----------------------------------------------------------------%
        function obj = createFlow(obj, metaData, fileIdx, flowIdx, flowHash, fileName)
            mergedSources = [obj.MergedSources];
            if ~isempty(mergedSources)
                if any(strcmp({mergedSources.Hash}, flowHash) & strcmp({mergedSources.File}, fileName))
                    return
                end
            end

            idx = numel(obj) + 1;
            obj(idx) = copy(metaData(fileIdx).Data(flowIdx), {'FileMap'});
            obj(idx).Hash = flowHash;
        end

        %-----------------------------------------------------------------%
        function occupancyMapping(obj)
            dataTypes = arrayfun(@(x) x.MetaData.DataType, obj);
            occupancyFlowIdxs = find(ismember(dataTypes, class.Constants.occDataTypes));
            
            for ii = 1:numel(obj)                         
                relatedHashes = {};
                selectedHash  = '';
                if ~isempty(obj(ii).UserData)
                    selectedHash = obj(ii).UserData.OccupancyComputationMode.SelectedHash;
                end

                for jj = occupancyFlowIdxs
                    hasSameMetaData = strcmp(obj(ii).Receiver, obj(jj).Receiver) && obj(ii).MetaData.FreqStart == obj(jj).MetaData.FreqStart && obj(ii).MetaData.FreqStop == obj(jj).MetaData.FreqStop && obj(ii).MetaData.DataPoints == obj(jj).MetaData.DataPoints;

                    if hasSameMetaData
                        relatedHashes{end+1} = obj(jj).Hash;
                    end
                end

                if ~isempty(relatedHashes) && ~ismember(selectedHash, relatedHashes)
                    selectedHash = relatedHashes{1};
                end

                obj(ii).UserData.OccupancyComputationMode.RelatedHashes = relatedHashes;
                obj(ii).UserData.OccupancyComputationMode.SelectedHash  = selectedHash;
            end
        end

        %-----------------------------------------------------------------%
        function [sortedTable, sortedIndexes] = buildSpectrumReferenceTableByCriteria(obj, idxThreads)
            numFlows = numel(idxThreads);
            sortedTable = table( ...
                'Size', [numFlows, 10], ...
                'VariableTypes', {'cell', 'double', 'double', 'double', 'cell', 'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'Receiver', 'DataType', 'FreqStart', 'FreqStop', 'LevelUnit', 'DataPoints', 'StepWidth', 'Resolution', 'NumSweeps', 'NumCoordinates'} ...
            );

            for ii = 1:numFlows
                idx = idxThreads(ii);
                
                sortedTable(ii,:) = {
                    obj(idx).Receiver, ...
                    obj(idx).MetaData.DataType, ...
                    obj(idx).MetaData.FreqStart, ...
                    obj(idx).MetaData.FreqStop, ...
                    obj(idx).MetaData.LevelUnit, ...
                    obj(idx).MetaData.DataPoints, ...
                    (obj(idx).MetaData.FreqStop - obj(idx).MetaData.FreqStart) / (obj(idx).MetaData.DataPoints - 1), ...
                    obj(idx).MetaData.Resolution, ...
                    numel(obj(idx).Data{1}), ...
                    obj(idx).GPS.Count ...
                };
            end
            
            sortedTable = sortrows(sortedTable, {'FreqStart', 'FreqStop'});
            sortedIndexes = sortedTable.idx;
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
                error([ ...
                    'Os fluxos espectrais a mesclar não atendem aos requisitos dos dois tipos de mesclagem implantados no <i>app</i>, quais sejam:\n\n'    ...
                    '• Tipo "co-channel": os fluxos devem possuir os campos "FreqStart", "FreqStop", "LevelUnit", "DataPoints" e "DataType" idênticos;\n\n' ...
                    '• Tipo "adjacent-channel": os fluxos devem estar relacionados a faixas de frequências adjacentes, podendo ter sobreposição espectral entre fluxos, além de possuírem os campos "LevelUnit", "nSweeps" e "DataType" idênticos.'
                ])
            end
        end
    end
end