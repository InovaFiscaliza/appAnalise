classdef (Abstract) SpecDet

    % Detecção de emissões por meio do modelo de IA "SpecDet" (EfficientNet +
    % BiFPN + cabeça de detecção por âncoras), treinado em PyTorch no repo
    % code-anatel-axis4 e exportado em ONNX. A rede foi importada uma única
    % vez no MATLAB (importNetworkFromONNX) e salva em "ai_models/pmrd2_4.mat"
    % (na raiz do repositório), junto com as camadas geradas pelo importador
    % (pasta de namespace "ai_models/+pmrd2_4"). Em execução, basta o Deep
    % Learning Toolbox.
    %
    % A rede entrega apenas as predições densas (deltas das caixas, objectness
    % e SNR por âncora). O pós-processamento do PyTorch (SpectrogramDet.postprocess)
    % é replicado aqui: geração das âncoras, decodificação das caixas e NMS.

    properties (Constant)
        %-----------------------------------------------------------------%
        % Configuração de treinamento (code-anatel-axis4/params.yaml, dataset
        % "70MHz_110MHz_pmrd_band2"). Não alterar sem retreinar o modelo.
        RF_MIN_HZ      = 70e+6
        RF_MAX_HZ      = 110e+6
        DELTA_F_HZ     = 19531.25
        N_FREQ_BINS    = 2048
        N_TRACES       = 211

        ANCHOR_SCALES  = [1.0, 1.5, 2.0]
        ANCHOR_RATIOS  = [0.5, 0.25, 0.125]
        ANCHOR_BASE_SIZE_FACTOR = 4

        % Níveis da pirâmide de features (EfficientNet-B0, out_indices = 2, 3, 4),
        % com strides 8, 16 e 32. Cada redução por 2 arredonda para cima.
        PYRAMID_LEVEL_DOWNSAMPLINGS = [3, 4, 5]

        TOPK_PRE_NMS   = 1000
        TOPK_POST_NMS  = 100
        BATCH_SIZE     = 8

        MODEL_FILE_NAME = 'pmrd2_4.mat'
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function emitters = detect(levelMatrix, freqStartHz, freqStopHz, scoreThreshold, nmsIoUThreshold, mergeIoUThreshold)
            arguments
                levelMatrix (:,:) {mustBeNumeric}  % DataPoints x NumSweeps (dB)
                freqStartHz (1,1) double
                freqStopHz  (1,1) double
                scoreThreshold    (1,1) double = 0.5
                nmsIoUThreshold   (1,1) double = 0.8
                mergeIoUThreshold (1,1) double = 0.5
            end

            % Retorna tabela com uma linha por emissor, com as colunas
            % FreqStartHz, FreqStopHz, Score, SNRdB e NumWindows.

            freqAxisHz = linspace(freqStartHz, freqStopHz, size(levelMatrix, 1))';
            if freqAxisHz(1) > util.SpecDet.RF_MIN_HZ || freqAxisHz(end) < util.SpecDet.RF_MAX_HZ - util.SpecDet.DELTA_F_HZ
                error('util:SpecDet:UnsupportedBand', 'A faixa do fluxo (%.3f a %.3f MHz) não cobre a faixa do modelo (%.0f a %.0f MHz).', ...
                    freqAxisHz(1)/1e+6, freqAxisHz(end)/1e+6, util.SpecDet.RF_MIN_HZ/1e+6, util.SpecDet.RF_MAX_HZ/1e+6)
            end

            levelMatrix = double(levelMatrix);
            is_finite_level = isfinite(levelMatrix);
            if ~any(is_finite_level, 'all')
                error('util:SpecDet:NoFiniteLevel', 'O fluxo não possui níveis finitos.')
            end
            levelMatrix(~is_finite_level) = min(levelMatrix(is_finite_level));

            rebinnedLevel = util.SpecDet.rebinFrequency(levelMatrix, freqAxisHz);
            windows       = util.SpecDet.splitWindows(rebinnedLevel');
            anchors       = util.SpecDet.anchors();
            net           = util.SpecDet.loadNetwork();

            detections = table('Size', [0, 5], ...
                'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'WindowIdx', 'FreqStartHz', 'FreqStopHz', 'Score', 'SNRdB'});

            numWindows = size(windows, 4);
            for batchStart = 1:util.SpecDet.BATCH_SIZE:numWindows
                batchIdxs = batchStart:min(batchStart + util.SpecDet.BATCH_SIZE - 1, numWindows);
                batchInput = dlarray(single(windows(:, :, :, batchIdxs)), 'SSCB'); % [H=tempo, W=frequência, C=1, B]

                [codedBoxDeltas, objectnessLogits, snrDb] = predict(net, batchInput);
                codedBoxDeltas   = double(gather(extractdata(codedBoxDeltas)));   % [B, N, 4]
                objectnessLogits = double(gather(extractdata(objectnessLogits))); % [B, N]
                snrDb            = double(gather(extractdata(snrDb)));            % [B, N]

                if size(codedBoxDeltas, 2) ~= size(anchors, 1)
                    error('util:SpecDet:AnchorMismatch', 'Número de âncoras (%d) não corresponde ao número de predições (%d).', size(anchors, 1), size(codedBoxDeltas, 2))
                end

                for ii = 1:numel(batchIdxs)
                    [boxesPx, scores, boxSnrDb] = util.SpecDet.postprocess(squeeze(codedBoxDeltas(ii, :, :)), objectnessLogits(ii, :)', snrDb(ii, :)', anchors, scoreThreshold, nmsIoUThreshold);
                    if isempty(scores)
                        continue
                    end

                    [freqStartsHz, freqStopsHz] = util.SpecDet.px2Hz(boxesPx);
                    detections = [detections; table(repmat(batchIdxs(ii), numel(scores), 1), freqStartsHz, freqStopsHz, scores, boxSnrDb, ...
                        'VariableNames', detections.Properties.VariableNames)]; %#ok<AGROW>
                end
            end

            emitters = util.SpecDet.mergeWindows(detections, mergeIoUThreshold);
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        function net = loadNetwork()
            % A rede (~25 MB) é carregada uma única vez por sessão.
            persistent cachedNetwork
            if isempty(cachedNetwork)
                if isdeployed
                    % Na versão compilada, "ai_models" integra o CTF
                    % (AdditionalFiles) e já está no path.
                    modelFile = which(util.SpecDet.MODEL_FILE_NAME);
                    if isempty(modelFile)
                        modelFileInfo = dir(fullfile(ctfroot, '**', util.SpecDet.MODEL_FILE_NAME));
                        if ~isempty(modelFileInfo)
                            modelFile = fullfile(modelFileInfo(1).folder, modelFileInfo(1).name);
                        end
                    end
                else
                    % src/+util/SpecDet.m -> raiz do repositório
                    repoRootFolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
                    aiModelsFolder = fullfile(repoRootFolder, 'ai_models');
                    modelFile      = fullfile(aiModelsFolder, util.SpecDet.MODEL_FILE_NAME);

                    % As camadas geradas pelo importador ONNX ficam na pasta de
                    % namespace "+pmrd2_4" dentro de "ai_models", que precisa
                    % estar no path para que o load reconstrua a rede.
                    if ~contains(path, aiModelsFolder)
                        addpath(aiModelsFolder)
                    end
                end

                if isempty(modelFile) || ~isfile(modelFile)
                    error('util:SpecDet:MissingModel', 'Modelo SpecDet "%s" não encontrado.', util.SpecDet.MODEL_FILE_NAME)
                end

                modelData = load(modelFile, 'net');
                cachedNetwork = modelData.net;
            end
            net = cachedNetwork;
        end

        %-----------------------------------------------------------------%
        function rebinnedLevel = rebinFrequency(levelMatrix, freqAxisHz)
            % Agrega (média em potência linear) os pontos do fluxo na grade
            % de frequência do modelo. Bins sem ponto (fluxo com resolução
            % mais grosseira que a grade) são interpolados. Saída: N_FREQ_BINS x NumSweeps.
            numFreqBins = util.SpecDet.N_FREQ_BINS;
            binIdxs     = floor((freqAxisHz - util.SpecDet.RF_MIN_HZ) / util.SpecDet.DELTA_F_HZ) + 1;
            is_in_band  = binIdxs >= 1 & binIdxs <= numFreqBins;

            pointIdxs   = find(is_in_band);
            binningMatrix = sparse(binIdxs(is_in_band), pointIdxs, 1, numFreqBins, numel(freqAxisHz));
            pointsPerBin  = full(sum(binningMatrix, 2));

            linearPower = 10 .^ (levelMatrix / 10);
            rebinnedLinearPower = (binningMatrix * linearPower) ./ max(pointsPerBin, 1);

            is_empty_bin = pointsPerBin == 0;
            if any(is_empty_bin)
                emptyBinCentersHz = util.SpecDet.RF_MIN_HZ + (find(is_empty_bin) - 0.5) * util.SpecDet.DELTA_F_HZ;
                rebinnedLinearPower(is_empty_bin, :) = interp1(freqAxisHz, linearPower, emptyBinCentersHz, 'linear');
            end

            rebinnedLevel = 10 * log10(max(rebinnedLinearPower, 1e-30));
        end

        %-----------------------------------------------------------------%
        function windows = splitWindows(rebinnedLevel)
            % Recebe NumSweeps x N_FREQ_BINS e retorna N_TRACES x N_FREQ_BINS x 1 x NumWindows.
            % Janelas sem sobreposição; a última é alinhada à última varredura.
            % Fluxos com menos de N_TRACES varreduras são repetidos no tempo.
            numTraces = util.SpecDet.N_TRACES;
            numSweeps = size(rebinnedLevel, 1);

            if numSweeps < numTraces
                windows = rebinnedLevel(mod(0:numTraces-1, numSweeps) + 1, :);
                return
            end

            windowStarts = 1:numTraces:(numSweeps - numTraces + 1);
            if windowStarts(end) + numTraces - 1 < numSweeps
                windowStarts(end+1) = numSweeps - numTraces + 1;
            end

            windows = zeros(numTraces, size(rebinnedLevel, 2), 1, numel(windowStarts));
            for ii = 1:numel(windowStarts)
                windows(:, :, 1, ii) = rebinnedLevel(windowStarts(ii):windowStarts(ii) + numTraces - 1, :);
            end
        end

        %-----------------------------------------------------------------%
        function anchorBoxes = anchors()
            % Âncoras [x1, y1, x2, y2] em pixels (x = frequência, y = tempo),
            % na mesma ordem das predições da rede: nível da pirâmide, linha
            % (tempo), coluna (frequência) e âncora (SpectrogramDet.get_anchors).
            inputHeight = util.SpecDet.N_TRACES;
            inputWidth  = util.SpecDet.N_FREQ_BINS;
            anchorBoxes = zeros(0, 4);

            for numDownsamplings = util.SpecDet.PYRAMID_LEVEL_DOWNSAMPLINGS
                levelHeight = inputHeight;
                levelWidth  = inputWidth;
                for kk = 1:numDownsamplings
                    levelHeight = ceil(levelHeight / 2);
                    levelWidth  = ceil(levelWidth / 2);
                end

                strideY  = inputHeight / levelHeight;
                strideX  = inputWidth  / levelWidth;
                centersY = ((0:levelHeight-1) + 0.5) * strideY;
                centersX = ((0:levelWidth-1)  + 0.5) * strideX;
                baseSize = util.SpecDet.ANCHOR_BASE_SIZE_FACTOR * min(strideX, strideY);

                anchorWidths  = baseSize * util.SpecDet.ANCHOR_SCALES .* sqrt(util.SpecDet.ANCHOR_RATIOS);
                anchorHeights = baseSize * util.SpecDet.ANCHOR_SCALES ./ sqrt(util.SpecDet.ANCHOR_RATIOS);

                % Ordem do PyTorch (row-major [H, W, A]) equivale à ordem
                % column-major de [A, W, H].
                [anchorIdxs, gridX, gridY] = ndgrid(1:numel(anchorWidths), centersX, centersY);
                halfWidths  = anchorWidths(anchorIdxs(:))'  / 2;
                halfHeights = anchorHeights(anchorIdxs(:))' / 2;

                anchorBoxes = [anchorBoxes; gridX(:) - halfWidths, gridY(:) - halfHeights, gridX(:) + halfWidths, gridY(:) + halfHeights]; %#ok<AGROW>
            end
        end

        %-----------------------------------------------------------------%
        function [boxesPx, scores, boxSnrDb] = postprocess(codedBoxDeltas, objectnessLogits, snrDb, anchors, scoreThreshold, nmsIoUThreshold)
            % Replica SpectrogramDet.postprocess para um exemplo: score (sem
            % cabeça de modulação, score = sigmoid(objectness)), limiar,
            % top-k, decodificação das caixas, NMS e top-k final.
            scores = 1 ./ (1 + exp(-objectnessLogits));

            candidateIdxs = find(scores >= scoreThreshold);
            [~, sortIdxs] = sort(scores(candidateIdxs), 'descend');
            candidateIdxs = candidateIdxs(sortIdxs(1:min(end, util.SpecDet.TOPK_PRE_NMS)));

            boxesPx = util.SpecDet.decodeBoxes(codedBoxDeltas(candidateIdxs, :), anchors(candidateIdxs, :));
            boxesPx(:, [1 3]) = min(max(boxesPx(:, [1 3]), 0), util.SpecDet.N_FREQ_BINS);
            boxesPx(:, [2 4]) = min(max(boxesPx(:, [2 4]), 0), util.SpecDet.N_TRACES);

            keepIdxs = util.SpecDet.nms(boxesPx, scores(candidateIdxs), nmsIoUThreshold);
            keepIdxs = keepIdxs(1:min(end, util.SpecDet.TOPK_POST_NMS));

            boxesPx  = boxesPx(keepIdxs, :);
            scores   = scores(candidateIdxs(keepIdxs));
            boxSnrDb = snrDb(candidateIdxs(keepIdxs));
        end

        %-----------------------------------------------------------------%
        function boxesPx = decodeBoxes(codedBoxDeltas, anchors)
            % Replica SpectrogramDet.get_tl_br_px: deltas (dx, dy, dw, dh)
            % relativos ao centro e às dimensões da âncora.
            anchorWidths   = max(anchors(:, 3) - anchors(:, 1), 1e-6);
            anchorHeights  = max(anchors(:, 4) - anchors(:, 2), 1e-6);
            anchorCentersX = anchors(:, 1) + 0.5 * anchorWidths;
            anchorCentersY = anchors(:, 2) + 0.5 * anchorHeights;

            boxCentersX = codedBoxDeltas(:, 1) .* anchorWidths  + anchorCentersX;
            boxCentersY = codedBoxDeltas(:, 2) .* anchorHeights + anchorCentersY;
            boxWidths   = anchorWidths  .* exp(min(codedBoxDeltas(:, 3), 30));
            boxHeights  = anchorHeights .* exp(min(codedBoxDeltas(:, 4), 10));

            boxesPx = [boxCentersX - 0.5 * boxWidths, boxCentersY - 0.5 * boxHeights, ...
                       boxCentersX + 0.5 * boxWidths, boxCentersY + 0.5 * boxHeights];
        end

        %-----------------------------------------------------------------%
        function keepIdxs = nms(boxesPx, scores, iouThreshold)
            % NMS guloso: mantém a caixa de maior score e descarta as demais
            % com IoU acima do limiar.
            [~, order] = sort(scores, 'descend');
            keepIdxs = zeros(0, 1);

            while ~isempty(order)
                currentIdx = order(1);
                keepIdxs(end+1, 1) = currentIdx; %#ok<AGROW>
                remainingIdxs = order(2:end);

                intersectionWidths  = max(0, min(boxesPx(currentIdx, 3), boxesPx(remainingIdxs, 3)) - max(boxesPx(currentIdx, 1), boxesPx(remainingIdxs, 1)));
                intersectionHeights = max(0, min(boxesPx(currentIdx, 4), boxesPx(remainingIdxs, 4)) - max(boxesPx(currentIdx, 2), boxesPx(remainingIdxs, 2)));
                intersectionAreas   = intersectionWidths .* intersectionHeights;

                boxAreas = max(boxesPx(:, 3) - boxesPx(:, 1), 0) .* max(boxesPx(:, 4) - boxesPx(:, 2), 0);
                ious = intersectionAreas ./ max(boxAreas(currentIdx) + boxAreas(remainingIdxs) - intersectionAreas, 1e-6);

                order = remainingIdxs(ious <= iouThreshold);
            end
        end

        %-----------------------------------------------------------------%
        function [freqStartsHz, freqStopsHz] = px2Hz(boxesPx)
            rfSpanHz     = util.SpecDet.RF_MAX_HZ - util.SpecDet.RF_MIN_HZ;
            freqStartsHz = util.SpecDet.RF_MIN_HZ + boxesPx(:, 1) / util.SpecDet.N_FREQ_BINS * rfSpanHz;
            freqStopsHz  = util.SpecDet.RF_MIN_HZ + boxesPx(:, 3) / util.SpecDet.N_FREQ_BINS * rfSpanHz;
        end

        %-----------------------------------------------------------------%
        function emitters = mergeWindows(detections, mergeIoUThreshold)
            % Agrupa as detecções de todas as janelas que se sobrepõem em
            % frequência (IoU >= limiar), em ordem decrescente de score. Cada
            % grupo é um emissor, com a mediana dos limites de frequência.
            detections = sortrows(detections, 'Score', 'descend');
            clusterIdxs  = zeros(height(detections), 1);
            clusterLimits = zeros(0, 2); % limites do detector de maior score do grupo

            for ii = 1:height(detections)
                currentLimits = [detections.FreqStartHz(ii), detections.FreqStopHz(ii)];
                for jj = 1:size(clusterLimits, 1)
                    intersection = max(0, min(currentLimits(2), clusterLimits(jj, 2)) - max(currentLimits(1), clusterLimits(jj, 1)));
                    union        = max(currentLimits(2), clusterLimits(jj, 2)) - min(currentLimits(1), clusterLimits(jj, 1));
                    if union > 0 && intersection / union >= mergeIoUThreshold
                        clusterIdxs(ii) = jj;
                        break
                    end
                end

                if ~clusterIdxs(ii)
                    clusterLimits(end+1, :) = currentLimits; %#ok<AGROW>
                    clusterIdxs(ii) = size(clusterLimits, 1);
                end
            end

            numClusters = size(clusterLimits, 1);
            emitters = table('Size', [numClusters, 5], ...
                'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'FreqStartHz', 'FreqStopHz', 'Score', 'SNRdB', 'NumWindows'});

            for jj = 1:numClusters
                members = detections(clusterIdxs == jj, :);
                emitters(jj, :) = {median(members.FreqStartHz), median(members.FreqStopHz), max(members.Score), median(members.SNRdB, 'omitnan'), numel(unique(members.WindowIdx))};
            end

            emitters = sortrows(emitters, 'FreqStartHz');
        end
    end
end
