classdef (Abstract) Detection

    properties (Constant)
        %-----------------------------------------------------------------%
        findPeaksDefaultValues = struct( ...
            'Algorithm', 'FindPeaks', ...
            'MinDistanceKHz', 25, ...
            'MinWidthKHz', 10, ...
            'TraceMode', 'Mean', ...
            'MinProminence', 12, ...
            'NumPeaks', 100, ...
            'Threshold', -inf ...
        )

        findPeaksPlusOCCDefaultValues = struct( ...
            'Algorithm', 'FindPeaks+OCC', ...
            'MinDistanceKHz', 25, ...
            'MinWidthKHz', 10, ...
            'MinProminenceCenter', 12, ...
            'MinProminenceMax', 30, ...
            'MinOccupancyMeanOverTime', 10, ...
            'MinOccupancyMaxOverTime', 67 ...
        )

        findConnectedRegionsDefaultValues = struct( ...
            'Algorithm', 'FindConnectedRegions', ...
            'Offset', 12, ...
            'CumulativeAreaThreshold', 99, ...
            'MaxOccupancyForRegions', 99, ...
            'MinOccupancy', 3, ...
            'MinAbsOrientation', 75 ...
        )
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [idxList, freqList, widthKHzList, methodList] = run(specData, detectionConfig)
            arguments
                specData (1,1) model.SpecDataBase
                detectionConfig (1,1) struct
            end

            switch detectionConfig.Algorithm
                case 'FindPeaks'
                    [idxList, freqList, widthList, methodList] = util.Detection.findPeaks(specData, detectionConfig);
                case 'FindPeaks+OCC'                    
                    [idxList, freqList, widthList, methodList] = util.Detection.findPeaksPlusOCC(specData, detectionConfig);
                case 'FindConnectedRegions'
                    [idxList, freqList, widthList, methodList] = util.Detection.findConnectedRegions(specData, detectionConfig);
            end    
            widthKHzList = widthList * 1000;

            if ~iscellstr(methodList)
                methodList = cellstr(methodList);
            end
        end

        %-----------------------------------------------------------------%
        function [idxList, freqList, widthList, methodList] = findPeaks(specData, detectionConfig)
            arguments
                specData (1,1) model.SpecDataBase
                detectionConfig (1,1) struct = util.Detection.findPeaksDefaultValues
            end

            switch detectionConfig.TraceMode
                case 'MinHold'
                    traceModeIdx = 1;
                case 'Mean'
                    traceModeIdx = 2;
                case 'MaxHold'
                    traceModeIdx = 3;
            end

            data = specData.Data{3}(:, traceModeIdx);
            if ismember(detectionConfig.TraceMode, {'MinHold', 'MaxHold'})
                data = smoothdata(data, 'movmean', 'SmoothingFactor', 0.05);
            end
            aCoef = util.Detection.idx2freqCoeffs(specData);
        
            idxRange = matlab.findpeaks( ...
                data, ...
                'NPeaks', detectionConfig.NumPeaks, ...
                'MinPeakHeight', detectionConfig.Threshold, ...
                'MinPeakProminence', detectionConfig.MinProminence, ...
                'MinPeakDistance', 1000 * detectionConfig.MinDistanceKHz / aCoef, ... % kHz >> Hertz
                'MinPeakWidth', 1000 * detectionConfig.MinWidthKHz / aCoef, ... % kHz >> Hertz
                'SortStr', 'descend' ...
            );

            if isempty(idxRange)
                idxList    = [];
                freqList   = [];
                widthList  = [];
                methodList = {};
            else
                idxList    = mean(idxRange, 2);
                freqList   = util.Detection.idx2freq(specData, idxList) / 1e+6; % Hz >> MHz
                idxList    = round(idxList);

                widthList  = (idxRange(:,2) - idxRange(:,1)) * aCoef / 1e+6; % Hz >> MHz
                methodList = repmat({jsonencode(struct( ...
                    'Algorithm', detectionConfig.Algorithm, ...
                    'Parameters', rmfield(detectionConfig, 'Algorithm') ...
                ), 'ConvertInfAndNaN', false)}, numel(idxList), 1);
            end
        end

        %-----------------------------------------------------------------%
        function [idxList, freqList, widthList, methodList] = findPeaksPlusOCC(specData, detectionConfig)
            arguments
                specData (1,1) model.SpecDataBase 
                detectionConfig (1,1) struct = util.Detection.findPeaksPlusOCCDefaultValues
            end
        
            % Critério primário: Média
            primaryThreshold = -inf;
            if specData.MetaData.Threshold ~= -1
                primaryThreshold = specData.MetaData.Threshold + detectionConfig.MinProminenceCenter;
            end
            
            primaryCriteriaConfig = struct( ...
                'Algorithm', detectionConfig.Algorithm, ...
                'MinDistanceKHz', detectionConfig.MinDistanceKHz, ...
                'MinWidthKHz', detectionConfig.MinWidthKHz, ...
                'TraceMode', 'Mean', ...
                'MinProminence', detectionConfig.MinProminenceCenter, ...
                'NumPeaks', 100, ...
                'Threshold', primaryThreshold ...
            );
                
            [primaryIdxs, primaryFreqs, primaryWidths, primaryMethods] = util.Detection.findPeaks(specData, primaryCriteriaConfig);
        
            % Critério secundário: MaxHold
            secondaryThreshold = -inf;
            if specData.MetaData.Threshold ~= -1
                secondaryThreshold = specData.MetaData.Threshold + detectionConfig.MinProminenceMax;
            end
            secondaryCriteriaConfig = struct( ...
                'Algorithm', detectionConfig.Algorithm, ...
                'MinDistanceKHz', detectionConfig.MinDistanceKHz, ...
                'MinWidthKHz', detectionConfig.MinWidthKHz, ...
                'TraceMode', 'MaxHold', ...
                'MinProminence', detectionConfig.MinProminenceMax, ...
                'NumPeaks', 100, ...
                'Threshold', secondaryThreshold, ...
                'MinOccupancyMeanOverTime', detectionConfig.MinOccupancyMeanOverTime, ...
                'MinOccupancyMaxOverTime', detectionConfig.MinOccupancyMaxOverTime ...
            );
        
            [secondaryIdxs, secondaryFreqs, secondaryWidths, secondaryMethods] = util.Detection.findPeaks(specData, secondaryCriteriaConfig);
            
            if ~isempty(secondaryIdxs)
                occupancyCacheIdx = specData.UserData.OccupancyComputationMode.CacheIndex;
                occupancyMeanIdxs = find(specData.UserData.OccupancyFiniteIntegrationCache(occupancyCacheIdx).Data{3}(:,2) >= detectionConfig.MinOccupancyMeanOverTime);
                occupancyMaxIdxs  = find(specData.UserData.OccupancyFiniteIntegrationCache(occupancyCacheIdx).Data{3}(:,3) >= detectionConfig.MinOccupancyMaxOverTime);
                
                [secondaryIdxs, intersectIdxs] = intersect(secondaryIdxs, intersect(occupancyMeanIdxs, occupancyMaxIdxs), 'stable');
                
                secondaryFreqs   = secondaryFreqs(intersectIdxs);
                secondaryWidths  = secondaryWidths(intersectIdxs);
                secondaryMethods = secondaryMethods(intersectIdxs);
            end        
        
            % Elimina emissões identificadas no critério secundário cujas 
            % frequências centrais estão contidas em alguma das emissões 
            % identificadas no critério primário
            for ii = numel(secondaryFreqs):-1:1
                for jj = 1:numel(primaryFreqs)
                    if (secondaryIdxs(ii) == primaryIdxs(jj)) || ((secondaryFreqs(ii) >= primaryFreqs(jj)-primaryWidths(jj)/2) && (secondaryFreqs(ii) <= primaryFreqs(jj)+primaryWidths(jj)/2))
                        secondaryIdxs(ii)    = [];
                        secondaryFreqs(ii)   = [];
                        secondaryWidths(ii)  = [];
                        secondaryMethods(ii) = [];
        
                        break
                    end
                end
            end        
        
            idxList    = [primaryIdxs;    secondaryIdxs   ];
            freqList   = [primaryFreqs;   secondaryFreqs  ];
            widthList  = [primaryWidths;  secondaryWidths ];
            methodList = [primaryMethods; secondaryMethods];
        end

        %-----------------------------------------------------------------%
        function [idxList, freqList, widthList, methodList] = findConnectedRegions(specData, detectionConfig)
            arguments
                specData (1,1) model.SpecDataBase
                detectionConfig (1,1) struct = util.Detection.findConnectedRegionsDefaultValues
            end

            idxList    = [];
            freqList   = [];
            widthList  = [];
            methodList = {};

            emissions = table( ...
                'Size', [0, 6], ...
                'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'FreqCenter', 'BandWidth', 'Count', 'Occorrences', 'Occupancy', 'Orientation'} ...
            );

            % Inicialmente, suaviza-se a imagem espectral a ser comparada 
            % com um limiar de detecção para obtenção da imagem binária, na 
            % qual serão identificadas as regiões conectadas. Os pixels nas
            % bordas são "desligados", aumentando possibilidade de excluir 
            % regiões que tocam as bordas laterais por, provavelmente, se 
            % tratar de emissões não relevantes na faixa sob análise.
            smoothed   = medfilt2(specData.Data{2}', [3 3], "symmetric");
            threshold  = util.Detection.computeThreshold(specData, detectionConfig.Offset);

            binaryMask = smoothed >= threshold;
            binaryMask(:, [1, end]) = false;

            connectedRegions = regionprops(binaryMask, {'Area', 'BoundingBox', 'Orientation'});
            if isempty(connectedRegions)
                return
            end

            connectedRegions = struct2table(connectedRegions, "AsArray", true);

            % Agrupam-se regiões com mesma posição em frequência (frequência
            % central e largura), o que é essencial para identificar emissões 
            % rápidas com baixa ocupação.
            connectedRegions.PositionKey = string(connectedRegions.BoundingBox(:,1)) + " - " + string(connectedRegions.BoundingBox(:,3));
            
            groupedRegionIds = findgroups(connectedRegions.PositionKey);
            groupedRegionCount = splitapply(@numel, connectedRegions.PositionKey, groupedRegionIds);
            groupedRegionArea = splitapply(@sum, connectedRegions.Area, groupedRegionIds);
            groupedRegionOrientation = splitapply(@(area, theta) atan2d(sum(area .* sind(theta)), sum(area .* cosd(theta))), connectedRegions.Area, connectedRegions.Orientation, groupedRegionIds);
            groupedRegionIdxs = splitapply(@(idx) idx(1), (1:height(connectedRegions))', groupedRegionIds);
            groupedRegionTimeSum = splitapply(@sum, connectedRegions.BoundingBox(:, 4), groupedRegionIds);
            
            % Cria-se uma nova tabela, ordenando-a pela coluna "Area". Calcula-se 
            % a área acumulada, eliminando registros não relevantes. No caso,
            % são mantidas as regiões que correspondem a 99% (configurável) da área 
            % acumulada e as regiões que se manifestaram mais de uma vez (mesma 
            % frequência central e largura).
            numPoints = specData.MetaData.DataPoints;
            numSweeps = numel(specData.Data{1});

            mergedRegions = table( ...
                groupedRegionArea, ...
                groupedRegionOrientation, ...
                connectedRegions.BoundingBox(groupedRegionIdxs, :), ...
                groupedRegionCount, ...
                'VariableNames', {'Area', 'Orientation', 'BoundingBox', 'GroupCount'} ...
            );
            mergedRegions.BoundingBox(:, 4) = groupedRegionTimeSum;

            mergedRegions = sortrows(mergedRegions, 'Area', 'descend');
            mergedRegions.CumulativeArea = 100 * cumsum(mergedRegions.Area) / sum(mergedRegions.Area);
            mergedRegions = mergedRegions(union(1:find(mergedRegions.CumulativeArea >= detectionConfig.CumulativeAreaThreshold, 1, 'first'), find(mergedRegions.GroupCount > 1)), :);
            if isempty(mergedRegions)
                return
            end

            bBoxX = mergedRegions.BoundingBox(:,1);
            bBoxW = mergedRegions.BoundingBox(:,3);
            bBoxH = mergedRegions.BoundingBox(:,4);
            
            freqStartIdx = max(fix(bBoxX), 1);
            freqStopIdx  = min(ceil(bBoxX + bBoxW), numPoints);
            
            freqStart = util.Detection.idx2freq(specData, freqStartIdx) / 1e6; % Hz >> MHz
            freqStop  = util.Detection.idx2freq(specData, freqStopIdx)  / 1e6; % Hz >> MHz

            mergedRegions.FreqCenter = (freqStart + freqStop) / 2;
            mergedRegions.BandWidth  = (freqStop - freqStart);
            mergedRegions.Occupancy  = 100 * bBoxH / numSweeps;
            
            mergedRegions = movevars(mergedRegions, {'FreqCenter', 'BandWidth'}, 'After', 'Area');
            mergedRegions = movevars(mergedRegions, 'Occupancy', 'After', 'BandWidth');

            % Percorre as regiões ordenadas por área, agrupando regiões sobrepostas.
            % Uma emissão é registrada se a ocupação combinada excede 3% (configurável)
            % ou se há múltiplas regiões com baixa ocupação, mas alto agrupamento, 
            % sugerindo emissões rápidas/intermitentes.
            ii = 1;
            while true
                groupIdxs = ii;
                
                if ii ~= height(mergedRegions)                    
                    for jj = ii+1:height(mergedRegions)
                        if util.Detection.hasOverlap('FromRegionTable', mergedRegions, ii, jj)
                            groupIdxs(end+1) = jj;
                        end
                    end
                end

                groupIdxRange = [
                    ceil(mergedRegions.BoundingBox(ii, 1)), ...
                    fix(sum(mergedRegions.BoundingBox(ii, [1,3]))) ...
                ];

                groupCount = numel(groupIdxs);
                groupOccorrences = sum(mergedRegions.GroupCount(groupIdxs));
                groupOrientation = atan2d(sum(mergedRegions(groupIdxs, :).Area .* sind(mergedRegions(groupIdxs, :).Orientation)), sum(mergedRegions(groupIdxs, :).Area .* cosd(mergedRegions(groupIdxs, :).Orientation)));
                groupOccupancy = sum(mergedRegions.Occupancy(groupIdxs));
                
                if diff(groupIdxRange) > 1 && ...
                   ((groupOccupancy >= detectionConfig.MaxOccupancyForRegions) || ...
                    (groupOccupancy >= detectionConfig.MinOccupancy && abs(groupOrientation) >= detectionConfig.MinAbsOrientation) || ...
                    (~isscalar(groupIdxs) && groupOccorrences > 10*groupCount))
                    % Emissões constantes no tempo, caso cercadas por outras
                    % com a mesma características, tendem a criar rais laterais
                    % que impedem a sua individualização via o processo de
                    % busca de regiões conectadas. Neste caso, aplica-se o
                    % FINDPEAKS tradicional na curva de média, validando a 
                    % informação.

                    if mergedRegions.Occupancy(ii) < detectionConfig.MaxOccupancyForRegions
                        addEmission(mergedRegions.FreqCenter(ii), mergedRegions.BandWidth(ii), groupCount, groupOccorrences, groupOccupancy, groupOrientation);

                    else
                        emissionIdxRange = matlab.findpeaks( ...
                            specData.Data{3}(groupIdxRange(1):groupIdxRange(2), 2), ...
                            'MinPeakProminence', detectionConfig.Offset ...
                        );
            
                        if isempty(emissionIdxRange)
                            addEmission(mergedRegions.FreqCenter(ii), mergedRegions.BandWidth(ii), groupCount, groupOccorrences, groupOccupancy, groupOrientation);
                        
                        else
                            emissionIdxRange = groupIdxRange(1) + emissionIdxRange;
                            primaryIdxs      = mean(emissionIdxRange, 2);
                            primaryFreqs     = util.Detection.idx2freq(specData, primaryIdxs) / 1e+6; % Hz >> MHz            
                            [aCoef, bCoef]   = util.Detection.idx2freqCoeffs(specData);
                            primaryWidths    = (emissionIdxRange(:,2) - emissionIdxRange(:,1)) * aCoef / 1e+6; % Hz >> MHz

                            for kk = 1:numel(primaryFreqs)
                                addEmission(primaryFreqs(kk), primaryWidths(kk), groupCount, groupOccorrences, groupOccupancy, groupOrientation);
                            end
                        end
                    end
                end

                if ~isscalar(groupIdxs)
                    mergedRegions(setdiff(groupIdxs, ii), :) = [];
                end

                ii = ii+1;
                if ii > height(mergedRegions)
                    break
                end
            end
            emissions = sortrows(emissions, 'FreqCenter');

            if ~isempty(emissions)
                freqList   = emissions.FreqCenter;
                idxList    = util.Detection.freq2idx(specData, freqList * 1e+6);
                widthList  = emissions.BandWidth;
                methodList = repmat({jsonencode(struct( ...
                    'Algorithm', detectionConfig.Algorithm, ...
                    'Parameters', rmfield(detectionConfig, 'Algorithm') ...
                ))}, numel(idxList), 1);
            end

            function addEmission(freqCenterMHz, widthMHz, count, occorrences, occupancy, orientation)
                emissions(end+1, :) = {freqCenterMHz, widthMHz, count, occorrences, occupancy, orientation};
            end
        end
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [aCoef, bCoef] = idx2freqCoeffs(specData)
            arguments
                specData (1,1) model.SpecDataBase 
            end

            % FrequencyInHertz = aCoef * FrequencyInHertzIdx + bCoef;

            nPoints = specData.MetaData.DataPoints;
            freqStart = specData.MetaData.FreqStart;
            freqStop = specData.MetaData.FreqStop;
            
            aCoef = (freqStop - freqStart) / (nPoints - 1);
            bCoef = freqStart - aCoef;
        end

        %-----------------------------------------------------------------%
        function freq = idx2freq(specData, idx)
            arguments
                specData (1,1) model.SpecDataBase 
                idx 
            end

            [aCoef, bCoef] = util.Detection.idx2freqCoeffs(specData);
            freq = aCoef * idx + bCoef;
        end

        %-----------------------------------------------------------------%
        function idx = freq2idx(specData, freq, roundMode)
            arguments
                specData (1,1) model.SpecDataBase
                freq
                roundMode {mustBeMember(roundMode, {'round', 'fix', 'ceil'})} = 'round'
            end

            [aCoef, bCoef] = util.Detection.idx2freqCoeffs(specData);
            idx = (freq - bCoef) / aCoef;

            roundFcn = str2func(roundMode);
            idx = roundFcn(idx);

            nPoints = specData.MetaData.DataPoints;
            idx = max(1, min(nPoints, idx));
        end

        %-----------------------------------------------------------------%
        function timestamp = idx2timestamp(specData, idx)
            arguments
                specData (1,1) model.SpecDataBase 
                idx 
            end

            timestamp = specData.Data{1}(idx);
        end

        %-----------------------------------------------------------------%
        function threshold = computeThreshold(specData, offset)
            arguments
                specData (1,1) model.SpecDataBase
                offset = 12
            end

            % Estima o limiar de detecção (threshold) a partir do piso de ruído,
            % utilizando uma abordagem iterativa sobre amostras ordenadas.
            % - Faz-se uso da curva Average - specData.Data{3}(:,2).
            % - Assume-se que os menores níveis dessa curva são compostos por 
            %   ruído.
            % - De forma iterativa, expande-se o subconjunto de amostras (de 
            %   5% até 100%), estimando o piso de ruído por meio da mediana. 
            %   A cada iteração, avalia-se a diferença entre o maior valor do 
            %   subconjunto e essa mediana. Em ultrapassando o offset (tipicamente 
            %   em torno de 12 dB, com base em testes práticos), a expansão é 
            %   interrompida, indicando a presença de sinal.
            % - Para o último subconjunto válido (predominantemente ruído), 
            %   estima-se a dispersão utilizando o MAD.
            % - O limiar é então calculado pela expressão:
            %   threshold = noiseMedian + 3*noiseStd + offset

            numPoints = specData.MetaData.DataPoints;
            sortedValues = sort(specData.Data{3}(:, 2));
            noiseStd = 0;

            for sampleFraction = 0.05:0.01:1
                numNoiseSamples = ceil(sampleFraction * numPoints);
                noiseSubset = sortedValues(1:numNoiseSamples);                
                noiseMedian = median(noiseSubset);

                if noiseSubset(end) - noiseMedian > offset
                    break
                end

                noiseStd = 1.4826 * mad(noiseSubset, 1);
            end

            threshold = ceil(noiseMedian + 3*noiseStd + offset);
        end

        %-----------------------------------------------------------------%
        function hasOverlap = hasOverlap(method, varargin)
            arguments
                method {mustBeMember(method, {'FromRegionTable', 'FromFrequencyAndWidths'})}
            end

            arguments (Repeating)
                varargin
            end

            switch method
                case 'FromRegionTable'
                    regions = varargin{1};
                    idx1 = varargin{2};
                    idx2 = varargin{3};

                    fc = regions.FreqCenter([idx1 idx2]);
                    bw = regions.BandWidth([idx1 idx2]);

                case 'FromFrequencyAndWidths'
                    fc = varargin{1};
                    bw = varargin{2};
            end

            fmin = fc - bw/2;
            fmax = fc + bw/2;

            noOverlap = (fmax(1) <= fmin(2)) || (fmin(1) >= fmax(2));
            hasOverlap = ~noOverlap;
        end

        %-----------------------------------------------------------------%
        function drawEmission(operationType, axesHandle, varargin)
            arguments
                operationType (1,:) char {mustBeMember(operationType, {'Creation', 'Delete'})}
                axesHandle (1,1) matlab.ui.control.UIAxes
            end

            arguments (Repeating)
                varargin
            end

            switch operationType
                case 'Creation'
                    util.Detection.drawEmission('Delete', axesHandle)

                    restoreView = varargin{1};
                    yMin = restoreView(1).yLim(1) + 1;
                    yMax = diff(restoreView(1).yLim) - 2;

                    freqList = varargin{2};
                    widthKHzList = varargin{3};
        
                    for ii = 1:height(freqList)
                        bandWidth = widthKHzList(ii) / 1000;
                        freqStart = freqList(ii) - bandWidth/2;
        
                        images.roi.Rectangle( ...
                            axesHandle, ...
                            'Position', [freqStart, yMin, bandWidth, yMax], ...
                            'Color', [0.6350 0.0780 0.1840], ...
                            'SelectedColor', [0.8500 0.3250 0.0980], ...
                            'MarkerSize', 5, ...
                            'Deletable', 0, ...
                            'FaceSelectable', 0, ...
                            'LineWidth', 1, ...
                            'InteractionsAllowed', 'none', ...
                            'Tag', 'emissionsTemp' ...
                        );
                    end

                case 'Delete'
                    delete(findobj(axesHandle.Children, 'Tag', 'emissionsTemp'))
            end
        end
    end
end