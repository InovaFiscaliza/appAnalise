classdef (Abstract) Detection

    methods (Static = true)
        %-----------------------------------------------------------------%
        function [newIndex, newFreq, newBW_kHz, Method] = Controller(specData, idxThread, Attributes, AddEmissionsFlag, varargin)
            arguments
                specData         model.SpecDataBase
                idxThread        (1,1) {mustBeInteger, mustBeNonnegative, mustBeNonempty}
                Attributes       (1,1) struct
                AddEmissionsFlag (1,1) logical = false
            end

            arguments (Repeating)
                varargin
            end

            switch Attributes.Algorithm
                case 'FindPeaks'
                    [newIndex, newFreq, newBW_MHz, Method] = util.Detection.FindPeaks(specData, idxThread, Attributes);

                case 'FindPeaks+OCC'
                    [newIndex, newFreq, newBW_MHz, Method] = util.Detection.FindPeaksPlusOCC(specData, idxThread, Attributes);

                case 'DBSCAN'
                    [newIndex, newFreq, newBW_MHz, Method] = util.Detection.FindDBSCAN(specData, idxThread, Attributes);
            end
            newBW_kHz  = newBW_MHz * 1000;

            if AddEmissionsFlag
                channelObj = varargin{1};

                if ischar(Method)
                    Method = {Method};
                end

                if numel(newIndex)
                    update(specData(idxThread), 'UserData:Emissions', 'Add', newIndex, newFreq, newBW_kHz, Method, [], channelObj)
                end
            end
        end

        %-----------------------------------------------------------------%
        function [newIndex, newFreq, newBW_MHz, method] = FindPeaks(specData, idxThread, Attributes)
            newIndex  = [];
            newFreq   = [];
            newBW_MHz = [];
            method    = [];

            switch Attributes.Fcn
                case 'MinHold'; idxFcn = 1;
                case 'Média';   idxFcn = 2;
                case 'MaxHold'; idxFcn = 3;
            end

            [aCoef, ...
                bCoef]  = util.freq2idx('Coefficients', specData, idxThread);

            idxRange = matlab.findpeaks(specData(idxThread).Data{3}(:,idxFcn), 'NPeaks',            Attributes.NPeaks,                      ...
                'MinPeakHeight',     Attributes.THR,                         ...
                'MinPeakProminence', Attributes.Prominence,                  ...
                'MinPeakDistance',   1000 * Attributes.Distance_kHz / aCoef, ... % kHz >> Hertz
                'MinPeakWidth',      1000 * Attributes.BW_kHz       / aCoef, ... % kHz >> Hertz
                'SortStr',           'descend');
            if ~isempty(idxRange)
                newIndex  = mean(idxRange, 2);
                newFreq   = util.freq2idx('FrequencyInHertz', aCoef, bCoef, newIndex) ./ 1e+6; % Em MHz
                newBW_MHz = (idxRange(:,2)-idxRange(:,1)) * aCoef / 1e+6; % Em MHz

                newIndex  = round(newIndex);
                method    = repmat({jsonencode(struct('Algorithm',  Attributes.Algorithm, 'Parameters', rmfield(Attributes, 'Algorithm')), 'ConvertInfAndNaN', false)}, numel(newIndex), 1);
            end
        end


        %-----------------------------------------------------------------%
        function [newIndex, newFreq, newBW_MHz, method] = FindPeaksPlusOCC(specData, idxThread, Attributes)
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

            % Critério 1: Média
            % (Critério primário)
            THR1 = -inf;
            if specData(idxThread).MetaData.Threshold ~= -1
                THR1 = specData(idxThread).MetaData.Threshold + Attributes.Prominence1;
            end

            Attributes_C1 = struct('Algorithm',    'FindPeaks+OCC',         ...
                'Fcn',          'Média',                 ...
                'NPeaks',       100,                     ...
                'THR',          THR1,                    ...
                'Prominence',   Attributes.Prominence1,  ...
                'Distance_kHz', Attributes.Distance_kHz, ...
                'BW_kHz',       Attributes.BW_kHz);

            [meanIndex, meanFrequency, meanBW, meanMethod] = util.Detection.FindPeaks(specData, idxThread, Attributes_C1);


            % Critério 2: MaxHold
            % (Critério secundário)
            THR2 = -inf;
            if specData(idxThread).MetaData.Threshold ~= -1
                THR2 = specData(idxThread).MetaData.Threshold + Attributes.Prominence2;
            end
            Attributes_C2 = struct('Algorithm',    'FindPeaks+OCC',         ...
                'Fcn',          'MaxHold',               ...
                'NPeaks',       100,                     ...
                'THR',          THR2,                    ...
                'Prominence',   Attributes.Prominence2,  ...
                'Distance_kHz', Attributes.Distance_kHz, ...
                'BW_kHz',       Attributes.BW_kHz,       ...
                'meanOCC',      Attributes.meanOCC,      ...
                'maxOCC',       Attributes.maxOCC);

            [maxIndex, maxFrequency, maxBW, maxMethod] = util.Detection.FindPeaks(specData, idxThread, Attributes_C2);

            if ~isempty(maxIndex)
                checkIfOccupancyPerBinExist(specData(idxThread))
                occIndex = specData(idxThread).UserData.occMethod.CacheIndex;

                occIndex_Mean = find(specData(idxThread).UserData.occCache(occIndex).Data{3}(:,2) >= Attributes.meanOCC);
                occIndex_Max  = find(specData(idxThread).UserData.occCache(occIndex).Data{3}(:,3) >= Attributes.maxOCC);

                [maxIndex, idx2] = intersect(maxIndex, intersect(occIndex_Mean, occIndex_Max), 'stable');

                maxFrequency = maxFrequency(idx2);
                maxBW        = maxBW(idx2);
                maxMethod    = maxMethod(idx2);
            end

            % Validação
            % Elimina emissões identificadas no Critério 2 cujas frequências centrais estão
            % contidas em alguma das emissões identificadas no Critério 1.
            for ii = numel(maxFrequency):-1:1
                for jj = 1:numel(meanFrequency)
                    if (maxIndex(ii) == meanIndex(jj)) || ((maxFrequency(ii) >= meanFrequency(jj)-meanBW(jj)/2) && (maxFrequency(ii) <= meanFrequency(jj)+meanBW(jj)/2))
                        maxIndex(ii)     = [];
                        maxFrequency(ii) = [];
                        maxBW(ii)        = [];
                        maxMethod(ii)   = [];

                        break
                    end
                end
            end

            % Variáveis de saída
            newIndex  = [meanIndex;     maxIndex];
            newFreq   = [meanFrequency; maxFrequency];
            newBW_MHz = [meanBW;        maxBW];
            method    = [meanMethod;    maxMethod];
        end

        %-----------------------------------------------------------------%
        function [newIndex, newFreq, newBW_MHz, method] = FindDBSCAN(specData, idxThread, Attributes)
            % DETECTION ALGORITHM: DBSCAN (tempo-frequência em Data{2})
            % Matriz: M (bins de frequência) x N (snapshots no tempo)
            %
            % Usa FreqStart/FreqStop da estrutura MetaData para construir eixo de frequência

            newIndex  = [];
            newFreq   = [];
            newBW_MHz = [];
            method    = [];

            %--------------------------------------------------------------%
            % Extrai matriz tempo-freq (M x N)
            dataMatrix = specData(idxThread).Data{2};   % valores espectrais
            [M, N] = size(dataMatrix);

            % Eixo de frequências (Hz) via limites
            fMin = specData(idxThread).MetaData.FreqStart;
            fMax = specData(idxThread).MetaData.FreqStop;
            freqAxis_Hz = linspace(fMin, fMax, M).';    % vetor de frequências por linha

            % Vetor de timestamps dos snapshots (1 x N, em datetime/datenum/string)
            timeVec = specData(idxThread).Data{1};
            if iscell(timeVec), timeVec = datetime(timeVec); end

            % Threshold
            %mask = dataMatrix > Attributes.THR;

            % Threshold dinâmico calculado pela média da energia espectral de cada varredura acrescido do SNRMin informado 
            mask = dataMatrix > (max((mean(dataMatrix, 1)), (mean(dataMatrix, "all"))) * (1 + (10^(Attributes.SNRMin/20)/10)));

            % Índices de pontos acima do limiar
            [freqIdx, timeIdx] = find(mask);   % freqIdx = linha, timeIdx = coluna
            if isempty(freqIdx)
                return
            end

            % Converter índices -> freq/tempo reais
            freqVals = freqAxis_Hz(freqIdx) / 1e6;   % MHz
            freqVals = freqVals(:);

            % Passo temporal médio
            dt = median(seconds(diff(timeVec)));

            timeVals = timeVec(timeIdx);            % datetime
            timeVals = timeVals(:);  

            % Converte tempos para múltiplos de dt (snapshots normalizados)
            timeBins = round(seconds(timeVals - timeVec(1)) / dt);

            % Constrói vetor [f, t] já escalonado
            Xnorm = [freqVals/Attributes.epsFreq_MHz, timeBins/Attributes.epsTime];

            %--------------------------------------------------------------%
            % Escolha do epsilon (manual ou automático)
            if isfield(Attributes, 'eps') && ~isempty(Attributes.eps)
                epsilon = Attributes.eps;
                elbowIdx = [];
            else
                k = Attributes.MinPts;
                [~, D] = knnsearch(Xnorm, Xnorm, 'K', k);
                kDist = sort(D(:,end));

                nPoints    = length(kDist);
                allIdx     = (1:nPoints)';
                firstPoint = [1, kDist(1)];
                lastPoint  = [nPoints, kDist(end)];

                lineVec     = lastPoint - firstPoint;
                lineVecNorm = lineVec / norm(lineVec);

                vecFromFirst= [allIdx - firstPoint(1), kDist - firstPoint(2)];
                scalarProj  = vecFromFirst*lineVecNorm';
                projVec     = scalarProj*lineVecNorm;
                vecToLine   = vecFromFirst - projVec;
                distToLine  = sqrt(sum(vecToLine.^2,2));

                [~, elbowIdx] = max(distToLine);
                epsilon = kDist(elbowIdx);
            end

            %--------------------------------------------------------------%
            % DBSCAN
            labels = dbscan(Xnorm, epsilon, Attributes.MinPts);

            %--------------------------------------------------------------%
            % Pós-processamento
            uniqueClusters = unique(labels(labels > 0));
            for c = uniqueClusters'
                clusterFreqs = freqVals(labels == c);
                clusterTimes = timeVals(labels == c);
                clusterIdx   = freqIdx(labels == c);

                f0 = mean(clusterFreqs);                        % frequência central
                BW = max(clusterFreqs) - min(clusterFreqs);     % largura de banda
                tStart = min(clusterTimes);
                tEnd   = max(clusterTimes);

                % Armazena
                newIndex  = [newIndex; round(mean(clusterIdx))];
                newFreq   = [newFreq; f0];
                newBW_MHz = [newBW_MHz; BW];

                % Metadata como JSON
                method = [method; {jsonencode(struct(...
                    'Algorithm',  Attributes.Algorithm, ...
                    'Epsilon',    epsilon, ...
                    'TimeStart',  char(tStart), ...
                    'TimeEnd',    char(tEnd), ...
                    'Duration_s', seconds(tEnd - tStart), ...
                    'Parameters', rmfield(Attributes, 'Algorithm')),...
                    'ConvertInfAndNaN', false)}];
            end

            %--------------------------------------------------------------%
            % (Opcional) Plota gráfico k-distance
            if (isfield(Attributes, 'Showplots')) && Attributes.Showplots
                figure
                waterfall(mask)
                util.plotClustersWaterfall(dataMatrix, freqAxis_Hz, timeVec, freqIdx, timeIdx, labels);
            end
        end
    end
end