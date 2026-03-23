classdef (Abstract) Detection

    methods (Static = true)
        %-----------------------------------------------------------------%
        function [idxList, freqList, widthKHzList, methodList] = Controller(specData, detectionConfig, channelObj)
            arguments
                specData model.SpecDataBase
                detectionConfig (1,1) struct
                channelObj = []
            end

            switch detectionConfig.Algorithm
                case 'FindPeaks'
                    [idxList, freqList, widthList, methodList] = util.Detection.findPeaks(specData, detectionConfig);
                case 'FindPeaks+OCC'                    
                    [idxList, freqList, widthList, methodList] = util.Detection.findPeaksPlusOCC(specData, detectionConfig);
                case 'FindConnectedRegions'
                    [idxList, freqList, widthList, methodList] = util.Detection.findConnectedRegions(specData, detectionConfig);
                case 'FindConnectedRegions+FindPeaks'
                    [idxList, freqList, widthList, methodList] = util.Detection.findConnectedRegionsPlusFindPeaks(specData, detectionConfig, channelObj);
            end    
            widthKHzList = widthList * 1000;

            if ~iscellstr(methodList)
                methodList = cellstr(methodList);
            end

            if ~isempty(channelObj) && ~isempty(idxList)
                update(specData, 'UserData:Emissions', 'Add', idxList, freqList, widthKHzList, methodList, [], channelObj)
            end
        end

        %-----------------------------------------------------------------%
        function [idxList, freqList, widthList, methodList] = findPeaks(specData, detectionConfig)
            switch detectionConfig.Fcn
                case 'MinHold'
                    fcnColumnIdx = 1;
                case 'Média'
                    fcnColumnIdx = 2;
                case 'MaxHold'
                    fcnColumnIdx = 3;
            end

            aCoef = util.Detection.idx2freqCoeffs(specData);
        
            idxRange = matlab.findpeaks( ...
                specData.Data{3}(:, fcnColumnIdx), ...
                'NPeaks', detectionConfig.NPeaks, ...
                'MinPeakHeight', detectionConfig.THR, ...
                'MinPeakProminence', detectionConfig.Prominence, ...
                'MinPeakDistance', 1000 * detectionConfig.Distance_kHz / aCoef, ... % kHz >> Hertz
                'MinPeakWidth', 1000 * detectionConfig.BW_kHz / aCoef, ...          % kHz >> Hertz
                'SortStr', 'descend' ...
            );

            if isempty(idxRange)
                idxList    = [];
                freqList   = [];
                widthList  = [];
                methodList = {};
            else
                idxList    = mean(idxRange, 2);
                freqList   = util.Detection.idx2freq(specData, idxList) / 1e+6;     % Hz >> MHz
                idxList    = round(idxList);

                widthList  = (idxRange(:,2) - idxRange(:,1)) * aCoef / 1e+6;        % Hz >> MHz
                methodList = repmat({jsonencode(struct( ...
                    'Algorithm', detectionConfig.Algorithm, ...
                    'Parameters', rmfield(detectionConfig, 'Algorithm') ...
                ), 'ConvertInfAndNaN', false)}, numel(idxList), 1);
            end
        end

        %-----------------------------------------------------------------%
        function [idxList, freqList, widthList, methodList] = findPeaksPlusOCC(specData, detectionConfig)
            % DETECTION ALGORITHM: FindPeaks+OCC (appAnálise v. 1.00)
            %
            % Possibilita identificação de emissões pelos seguintes critérios:
            % - Critério 1: na curva de tendência central (média ou mediana), identificam-se os 
            %               picos espaçados entre si ao menos de _minDistance_ (em kHz), cuja 
            %               largura e proeminência de cada um deles seja ao menos igual a _minWidth_ 
            %               (em kHz) e _minLevel_ (em dB), respectivamente.
            %
            % - Critério 2: na curva de máximo, identificam-se os picos espaçados entre si ao 
            %               menos de _minDistance_ (em kHz), cuja largura e proeminência de cada um 
            %               deles seja ao menos igual a _minWidth_ (em kHz) e _minLevel_ (em dB), 
            %               respectivamente, e cuja ocupação seja superior a _minOCC_ (em %).
            % % Versão: 22/10/2023        
        
            % Critério primário: Média
            primaryThreshold = -inf;
            if specData.MetaData.Threshold ~= -1
                primaryThreshold = specData.MetaData.Threshold + detectionConfig.Prominence1;
            end
            
            primaryCriteriaConfig = struct( ...
                'Algorithm', 'FindPeaks+OCC', ...
                'Fcn', 'Média', ...
                'NPeaks', 100, ...
                'THR', primaryThreshold, ...
                'Prominence', detectionConfig.Prominence1,  ...
                'Distance_kHz', detectionConfig.Distance_kHz, ...
                'BW_kHz', detectionConfig.BW_kHz ...
            );
                
            [primaryIdxs, primaryFreqs, primaryWidths, primaryMethods] = util.Detection.findPeaks(specData, primaryCriteriaConfig);
        
            % Critério secundário: MaxHold
            secondaryThreshold = -inf;
            if specData.MetaData.Threshold ~= -1
                secondaryThreshold = specData.MetaData.Threshold + detectionConfig.Prominence2;
            end
            secondaryCriteriaConfig = struct( ...
                'Algorithm', 'FindPeaks+OCC', ...
                'Fcn', 'MaxHold', ...
                'NPeaks', 100, ...
                'THR', secondaryThreshold, ...
                'Prominence', detectionConfig.Prominence2, ...
                'Distance_kHz', detectionConfig.Distance_kHz, ...
                'BW_kHz', detectionConfig.BW_kHz,...
                'meanOCC', detectionConfig.meanOCC, ...
                'maxOCC', detectionConfig.maxOCC ...
            );
        
            [secondaryIdxs, secondaryFreqs, secondaryWidths, secondaryMethods] = util.Detection.findPeaks(specData, secondaryCriteriaConfig);
            
            if ~isempty(secondaryIdxs)
                checkIfOccupancyPerBinExist(specData)
                occIndex = specData.UserData.occMethod.CacheIndex;
        
                occIndex_Mean = find(specData.UserData.occCache(occIndex).Data{3}(:,2) >= detectionConfig.meanOCC);
                occIndex_Max  = find(specData.UserData.occCache(occIndex).Data{3}(:,3) >= detectionConfig.maxOCC);
                
                [secondaryIdxs, intersectIdxs] = intersect(secondaryIdxs, intersect(occIndex_Mean, occIndex_Max), 'stable');
                
                secondaryFreqs = secondaryFreqs(intersectIdxs);
                secondaryWidths = secondaryWidths(intersectIdxs);
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
                specData model.SpecData
                detectionConfig = struct('Algorithm', 'FindConnectedRegions', 'Offset', 12, 'MinOccupancy', 3)
            end

            idxList    = [];
            freqList   = [];
            widthList  = [];
            methodList = {};

            emissions = table( ...
                'Size', [0, 2], ...
                'VariableTypes', {'double', 'double'}, ...
                'VariableNames', {'FreqCenter', 'BandWidth'} ...
            );

            % Inicialmente, suaviza-se a imagem espectral que é comparada 
            % com um limiar de detecção para obtenção da imagem binária a 
            % ser analisada, identificando as regiões conectadas.
            smoothed   = medfilt2(specData.Data{2}', [3 3], "symmetric");
            threshold  = util.Detection.computeThreshold(specData, detectionConfig.Offset);
            binaryMask = smoothed >= threshold;

            connectedRegions = regionprops(binaryMask, {'Area', 'BoundingBox', 'Orientation'});
            if isempty(connectedRegions)
                return
            end

            connectedRegions = struct2table(connectedRegions, "AsArray", true);

            % Agrupam-se regiões com mesma posição em frequência, o que é 
            % essencial, quando se trata de emissões rápidas com baixa ocupação.
            connectedRegions.PositionKey = string(connectedRegions.BoundingBox(:,1)) + " - " + string(connectedRegions.BoundingBox(:,3));
            
            groupedRegionIds = findgroups(connectedRegions.PositionKey);
            groupedRegionCount = splitapply(@numel, connectedRegions.PositionKey, groupedRegionIds);
            groupedRegionArea = splitapply(@sum, connectedRegions.Area, groupedRegionIds);
            groupedRegionIdxs = splitapply(@(idx) idx(1), (1:height(connectedRegions))', groupedRegionIds);
            groupedRegionTimeSum = splitapply(@sum, connectedRegions.BoundingBox(:, 4), groupedRegionIds);
            
            % Cria-se uma nova tabela, eliminado registros que apresentam as
            % seguintes características:
            % - Área inferior à mediana e regiões com largura de apenas um 
            %   pixel no eixo da frequência por, provavelmente, se tratar de 
            %   ruído.
            % - Regiões que tocam as bordas laterais por, provavelmente, se
            %   tratar de emissões não relevantes na faixa sob análise.
            nPoints = specData.MetaData.DataPoints;
            nSweeps = numel(specData.Data{1});

            mergedRegions = table( ...
                groupedRegionArea, ...
                connectedRegions.Orientation(groupedRegionIdxs), ...
                connectedRegions.BoundingBox(groupedRegionIdxs,:), ...
                groupedRegionCount, ...
                'VariableNames', {'Area', 'Orientation', 'BoundingBox', 'GroupCount'} ...
            );
            mergedRegions.BoundingBox(:, 4) = groupedRegionTimeSum;

            mergedRegions(mergedRegions.Area <= median(mergedRegions.Area) | mergedRegions.BoundingBox(:,3) == 1 | mergedRegions.BoundingBox(:,1) == 0.5 | sum(mergedRegions.BoundingBox(:,[1,3]), 2) == nPoints+0.5, :) = [];
            if isempty(mergedRegions)
                return
            end

            for ii = 1:height(mergedRegions)
                freqStartIdx = max(fix(mergedRegions.BoundingBox(ii, 1)), 1);
                freqStopIdx  = min(ceil(sum(mergedRegions.BoundingBox(ii, [1 3]))), nPoints);
                
                freqStart    = util.Detection.idx2freq(specData, freqStartIdx) / 1e+6; % Hz >> MHz
                freqStop     = util.Detection.idx2freq(specData, freqStopIdx)  / 1e+6;

                mergedRegions.FreqCenter(ii) = (freqStart + freqStop) / 2;
                mergedRegions.BandWidth(ii)  = (freqStop - freqStart);
                mergedRegions.Occupancy(ii)  = 100 * mergedRegions.BoundingBox(ii, 4) / nSweeps;
            end
            
            mergedRegions = movevars(mergedRegions, {'FreqCenter', 'BandWidth'}, 'After', 'Area');
            mergedRegions = movevars(mergedRegions, 'Occupancy', 'After', 'BandWidth');
            mergedRegions = sortrows(mergedRegions, 'Area', 'descend');

            % Percorre as regiões ordenadas por área, agrupando regiões sobrepostas.
            % Uma emissão é registrada se a ocupação combinada excede o limiar 
            % configurado ou se há múltiplas regiões com baixa ocupação, mas alto 
            % agrupamento, sugerindo emissões rápidas/intermitentes.
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

                groupOccupancy = sum(mergedRegions.Occupancy(groupIdxs));
                groupOccorrences = sum(mergedRegions.GroupCount(groupIdxs));
                
                if any(mergedRegions.Occupancy(groupIdxs) > 1) && (groupOccupancy >= detectionConfig.MinOccupancy || (~isscalar(groupIdxs) && groupOccorrences > 2*numel(groupIdxs)))
                    emissions(end+1, :) = { ...
                        mergedRegions.FreqCenter(ii), ...
                        mergedRegions.BandWidth(ii) ...
                    };
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
        end

        %-----------------------------------------------------------------%
        function emissions = findPeaksPlusConnectedRegions(specData, offset, minOccupancy)
            arguments
                specData 
                offset = 12
                minOccupancy = 3
            end

            % Critério primário: FindPeaks
            primaryCriteriaConfig = struct( ...
                'Algorithm', 'FindPeaks+ConnectedRegions', ...
                'Fcn', 'Média', ...
                'NPeaks', 100, ...
                'Prominence', offset ...
            );

            idxRange = matlab.findpeaks( ...
                specData.Data{3}(:, 2), ...
                'NPeaks', primaryCriteriaConfig.NPeaks, ...
                'MinPeakProminence', primaryCriteriaConfig.Prominence, ...
                'SortStr', 'descend' ...
            );

            if isempty(idxRange)
                primaryIdxs    = [];
                primaryFreqs   = [];
                primaryWidths  = [];
                primaryMethods = {};
            else
                primaryIdxs    = mean(idxRange, 2);
                primaryFreqs   = util.Detection.idx2freq(specData, primaryIdxs) / 1e+6;     % Hz >> MHz
                primaryIdxs    = round(primaryIdxs);

                [aCoef, bCoef] = util.Detection.idx2freqCoeffs(specData);
                primaryWidths  = (idxRange(:,2) - idxRange(:,1)) * aCoef / 1e+6;        % Hz >> MHz
                primaryMethods = repmat({jsonencode(struct( ...
                    'Algorithm', primaryCriteriaConfig.Algorithm, ...
                    'Parameters', rmfield(primaryCriteriaConfig, 'Algorithm') ...
                ), 'ConvertInfAndNaN', false)}, numel(primaryIdxs), 1);
            end
        
            % Critério secundário: ConnectedRegions
            secondaryCriteriaConfig = struct( ...
                'Algorithm', 'FindPeaks+ConnectedRegions', ...
                'Offset', offset, ...
                'MinOccupancy', minOccupancy ...
            );

            [secondaryIdxs, secondaryFreqs, secondaryWidths, secondaryMethods] = util.Detection.findConnectedRegions(specData, secondaryCriteriaConfig);
        
            % Elimina emissões identificadas no critério secundário cujas 
            % frequências centrais estão contidas em alguma das emissões 
            % identificadas no critério primário
            for ii = numel(secondaryFreqs):-1:1
                for jj = 1:numel(primaryFreqs)
                    freqList  = [primaryFreqs(jj);  secondaryFreqs(ii)];
                    widthList = [primaryWidths(jj); secondaryWidths(ii)];

                    if util.Detection.hasOverlap('FromFrequencyAndWidths', freqList, widthList)
                        secondaryIdxs(ii)    = [];
                        secondaryFreqs(ii)   = [];
                        secondaryWidths(ii)  = [];
                        secondaryMethods(ii) = [];
        
                        break
                    end
                end
            end        
        
            emissions = table( ...
                [primaryIdxs;    secondaryIdxs   ], ...
                [primaryFreqs;   secondaryFreqs  ], ...
                [primaryWidths;  secondaryWidths ], ...
                [primaryMethods; secondaryMethods], ...
                'VariableNames', {'FreqCenterIdx', 'FreqCenter', 'BandWidth', 'Method'} ...
            );
        end
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [aCoef, bCoef] = idx2freqCoeffs(specData)
            % FrequencyInHertz = aCoef * FrequencyInHertzIdx + bCoef;

            nPoints = specData.MetaData.DataPoints;
            freqStart = specData.MetaData.FreqStart;
            freqStop = specData.MetaData.FreqStop;
            
            aCoef = (freqStop - freqStart) / (nPoints - 1);
            bCoef = freqStart - aCoef;
        end

        %-----------------------------------------------------------------%
        function freq = idx2freq(specData, idx)
            [aCoef, bCoef] = util.Detection.idx2freqCoeffs(specData);
            freq = aCoef * idx + bCoef;
        end

        %-----------------------------------------------------------------%
        function idx = freq2idx(specData, freq, roundMode)
            arguments
                specData
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
            timestamp = specData.Data{1}(idx);
        end

        %-----------------------------------------------------------------%
        function threshold = computeThreshold(specData, offset)
            arguments
                specData
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

            nPoints = specData.MetaData.DataPoints;
            sortedValues = sort(specData.Data{3}(:, 2));
            noiseStd = 0;

            for sampleFraction = 0.05:0.01:1
                nNoiseSamples = ceil(sampleFraction * nPoints);
                noiseSubset  = sortedValues(1:nNoiseSamples);                
                noiseMedian  = median(noiseSubset);

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
        function isSame = isSameEmission(regions, idx1, idx2)
            fc = regions.FreqCenter([idx1 idx2]);
            bw = regions.BandWidth([idx1 idx2]);

            fstart = fc - bw/2;
            fstop  = fc + bw/2;

            inter = max(0, min(fstop) - max(fstart));        
            overlapRatio = inter / min(bw);
            isSame = overlapRatio > 0.7;
        end

        %-----------------------------------------------------------------%
        function drawEmission(operationType, axesHandle, varargin)
            switch operationType
                case 'Creation'
                    util.Detection.drawEmission('Delete', axesHandle)

                    restoreView = varargin{1};
                    emissions = varargin{2};

                    yMin = restoreView(1).yLim(1) + 1;
                    yMax = diff(restoreView(1).yLim) - 2;
        
                    for ii = 1:height(emissions)
                        bandWidth = emissions.BandWidth(ii);
                        freqStart = emissions.FreqCenter(ii) - bandWidth/2;
        
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
                            'Tag', 'EmissionROI' ...
                        );
                    end

                case 'Delete'
                    delete(findobj(axesHandle.Children, 'Tag', 'EmissionROI'))
            end
        end
    end
end