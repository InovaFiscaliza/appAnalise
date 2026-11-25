classdef (Abstract) SpecDet

    % Detecção de emissões por meio dos modelos de IA "SpecDet" (EfficientNet +
    % BiFPN + cabeça de detecção por âncoras), treinados em PyTorch no repo
    % code-anatel-axis4 e exportados em ONNX. Há um modelo por faixa: cada um
    % é baixado e importado no MATLAB por "ai_models/fetchSpecDetModel.m", que
    % gera, na pasta "ai_models" (raiz do repositório):
    %   - <base>.mat:   rede importada (importNetworkFromONNX);
    %   - +<namespace>: camadas geradas pelo importador;
    %   - <base>.json:  parâmetros do modelo (params.yaml da tag e metadados do ONNX).
    % O registro "specdet_models.json" indica o modelo em uso em cada faixa.
    % Em execução, basta o Deep Learning Toolbox.
    %
    % A rede entrega apenas as predições densas (deltas das caixas, objectness
    % e SNR por âncora). O pós-processamento do PyTorch (SpectrogramDet.postprocess)
    % é replicado aqui: geração das âncoras, decodificação das caixas e NMS.

    properties (Constant)
        %-----------------------------------------------------------------%
        % Os parâmetros do modelo (grade do espectrograma, âncoras e
        % pós-processamento) vêm dos metadados do ONNX, gravados no JSON
        % do modelo por ai_models/fetchSpecDetModel.m.
        BATCH_SIZE              = 8    % janelas por chamada da rede (não altera o resultado)
        BAND_TOLERANCE_HZ       = 100e+3

        REGISTRY_FILE_NAME      = 'specdet_models.json'
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function emitters = detect(modelParams, levelMatrix, freqStartHz, freqStopHz, scoreThreshold, nmsIoUThreshold, mergeIoUThreshold)
            arguments
                modelParams (1,1) struct           % util.SpecDet.findModel
                levelMatrix (:,:) {mustBeNumeric}  % DataPoints x NumSweeps (dB)
                freqStartHz (1,1) double
                freqStopHz  (1,1) double
                scoreThreshold    (1,1) double = modelParams.ScoreThreshold
                nmsIoUThreshold   (1,1) double = modelParams.NMSIoUThreshold
                mergeIoUThreshold (1,1) double = 0.5
            end

            % Retorna tabela com uma linha por emissor, com as colunas
            % FreqStartHz, FreqStopHz, SweepStartIdx, SweepStopIdx, Score,
            % SNRdB e NumWindows. "SweepStartIdx" e "SweepStopIdx" delimitam,
            % em índices de varredura do fluxo, o intervalo de tempo em que o
            % emissor foi detectado (união das caixas de todas as janelas).

            freqAxisHz = linspace(freqStartHz, freqStopHz, size(levelMatrix, 1))';
            if freqAxisHz(1) > modelParams.RfMinHz || freqAxisHz(end) < modelParams.RfMaxHz - modelParams.DeltaFHz
                error('util:SpecDet:UnsupportedBand', 'A faixa do fluxo (%.3f a %.3f MHz) não cobre a faixa do modelo (%.3f a %.3f MHz).', ...
                    freqAxisHz(1)/1e+6, freqAxisHz(end)/1e+6, modelParams.RfMinHz/1e+6, modelParams.RfMaxHz/1e+6)
            end

            levelMatrix = double(levelMatrix);
            is_finite_level = isfinite(levelMatrix);
            if ~any(is_finite_level, 'all')
                error('util:SpecDet:NoFiniteLevel', 'O fluxo não possui níveis finitos.')
            end
            levelMatrix(~is_finite_level) = min(levelMatrix(is_finite_level));

            rebinnedLevel = util.SpecDet.rebinFrequency(modelParams, levelMatrix, freqAxisHz);
            numSweeps     = size(levelMatrix, 2);
            [windows, windowStartSweepIdxs] = util.SpecDet.splitWindows(modelParams, rebinnedLevel');
            anchors       = util.SpecDet.anchors(modelParams);
            net           = util.SpecDet.loadNetwork(modelParams);

            detections = table('Size', [0, 7], ...
                'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'WindowIdx', 'FreqStartHz', 'FreqStopHz', 'SweepStartIdx', 'SweepStopIdx', 'Score', 'SNRdB'});

            numWindows = size(windows, 4);
            for batchStart = 1:util.SpecDet.BATCH_SIZE:numWindows
                batchIdxs = batchStart:min(batchStart + util.SpecDet.BATCH_SIZE - 1, numWindows);
                % O importador ONNX exige a entrada na ordem do ONNX, com
                % dimensões não rotuladas: [B, C=1, H=tempo, W=frequência].
                batchInput = dlarray(single(permute(windows(:, :, :, batchIdxs), [4 3 1 2])), 'UUUU');

                [codedBoxDeltas, objectnessLogits, snrDb] = predict(net, batchInput);
                codedBoxDeltas   = double(gather(extractdata(codedBoxDeltas)));   % [B, N, 4]
                objectnessLogits = double(gather(extractdata(objectnessLogits))); % [B, N]
                snrDb            = double(gather(extractdata(snrDb)));            % [B, N]

                if size(codedBoxDeltas, 2) ~= size(anchors, 1)
                    error('util:SpecDet:AnchorMismatch', 'Número de âncoras (%d) não corresponde ao número de predições (%d).', size(anchors, 1), size(codedBoxDeltas, 2))
                end

                for ii = 1:numel(batchIdxs)
                    [boxesPx, scores, boxSnrDb] = util.SpecDet.postprocess(modelParams, squeeze(codedBoxDeltas(ii, :, :)), objectnessLogits(ii, :)', snrDb(ii, :)', anchors, scoreThreshold, nmsIoUThreshold);
                    if isempty(scores)
                        continue
                    end

                    [freqStartsHz, freqStopsHz] = util.SpecDet.px2Hz(modelParams, boxesPx);
                    [sweepStartIdxs, sweepStopIdxs] = util.SpecDet.px2SweepIdx(modelParams, boxesPx, windowStartSweepIdxs(batchIdxs(ii)), numSweeps);
                    detections = [detections; table(repmat(batchIdxs(ii), numel(scores), 1), freqStartsHz, freqStopsHz, sweepStartIdxs, sweepStopIdxs, scores, boxSnrDb, ...
                        'VariableNames', detections.Properties.VariableNames)]; %#ok<AGROW>
                end
            end

            emitters = util.SpecDet.mergeWindows(detections, mergeIoUThreshold);
        end

        %-----------------------------------------------------------------%
        function modelParams = findModel(freqStartHz, freqStopHz)
            % Retorna os parâmetros do modelo registrado para a faixa do
            % fluxo (limites coincidentes, com tolerância), ou [] se não há.
            modelParams = [];
            for candidate = util.SpecDet.listModels()
                if abs(freqStartHz - candidate.RfMinHz) <= util.SpecDet.BAND_TOLERANCE_HZ && ...
                   abs(freqStopHz  - candidate.RfMaxHz) <= util.SpecDet.BAND_TOLERANCE_HZ
                    modelParams = candidate;
                    return
                end
            end
        end

        %-----------------------------------------------------------------%
        function modelParamsList = listModels()
            % Lê o registro "specdet_models.json" e o arquivo de parâmetros
            % de cada faixa registrada. Lido uma única vez por sessão.
            persistent cachedModelParamsList
            if isempty(cachedModelParamsList)
                cachedModelParamsList = struct([]);

                registryFile = util.SpecDet.locateModelFile(util.SpecDet.REGISTRY_FILE_NAME);
                if isempty(registryFile)
                    modelParamsList = cachedModelParamsList;
                    return
                end

                registry = jsondecode(fileread(registryFile));
                for ii = 1:numel(registry)
                    paramsFile = util.SpecDet.locateModelFile(registry(ii).ParamsFile);
                    if isempty(paramsFile)
                        warning('util:SpecDet:MissingParams', 'Arquivo de parâmetros "%s" (faixa "%s") não encontrado.', registry(ii).ParamsFile, registry(ii).Band)
                        continue
                    end

                    modelParams = jsondecode(fileread(paramsFile));
                    % jsondecode converte listas de listas em matriz.
                    modelParams.AnchorScales = modelParams.AnchorScales(:)';
                    modelParams.AnchorRatios = modelParams.AnchorRatios(:)';
                    cachedModelParamsList = [cachedModelParamsList, modelParams]; %#ok<AGROW>
                end
            end
            modelParamsList = cachedModelParamsList;
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        function net = loadNetwork(modelParams)
            % Cada rede (~25 MB) é carregada uma única vez por sessão.
            persistent cachedNetworks
            if isempty(cachedNetworks)
                cachedNetworks = dictionary(string.empty, cell.empty);
            end

            if isKey(cachedNetworks, modelParams.Tag)
                net = cachedNetworks{modelParams.Tag};
                return
            end

            modelFile = util.SpecDet.locateModelFile(modelParams.MatFile);
            if isempty(modelFile)
                error('util:SpecDet:MissingModel', 'Modelo SpecDet "%s" (%s) não encontrado.', modelParams.MatFile, modelParams.Tag)
            end

            modelData = load(modelFile, 'net');
            net = modelData.net;

            % O ONNX tem dimensão de lote dinâmica, então o
            % importNetworkFromONNX gera uma rede não inicializada.
            % Inicializa com uma entrada de exemplo na ordem do ONNX
            % ([B, C, H, W], não rotulada).
            if ~net.Initialized
                exampleInput = dlarray(zeros(1, 1, modelParams.NumTraces, modelParams.NumFreqBins, 'single'), 'UUUU');
                net = initialize(net, exampleInput);
            end
            cachedNetworks{modelParams.Tag} = net;
        end

        %-----------------------------------------------------------------%
        function fileFullPath = locateModelFile(fileName)
            % Localiza um arquivo da pasta "ai_models", que também precisa
            % estar no path para que o load encontre as camadas geradas pelo
            % importador ONNX (pastas de namespace "+<namespace>").
            fileFullPath = '';
            if isdeployed
                % Na versão compilada, "ai_models" integra o CTF
                % (AdditionalFiles) e já está no path.
                fileFullPath = which(fileName);
                if isempty(fileFullPath)
                    fileInfo = dir(fullfile(ctfroot, '**', fileName));
                    if ~isempty(fileInfo)
                        fileFullPath = fullfile(fileInfo(1).folder, fileInfo(1).name);
                    end
                end
            else
                % src/+util/SpecDet.m -> raiz do repositório
                repoRootFolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
                aiModelsFolder = fullfile(repoRootFolder, 'ai_models');
                if ~contains(path, aiModelsFolder)
                    addpath(aiModelsFolder)
                end

                if isfile(fullfile(aiModelsFolder, fileName))
                    fileFullPath = fullfile(aiModelsFolder, fileName);
                end
            end
        end

        %-----------------------------------------------------------------%
        function rebinnedLevel = rebinFrequency(modelParams, levelMatrix, freqAxisHz)
            % Agrega (média em potência linear) os pontos do fluxo na grade
            % de frequência do modelo. Bins sem ponto (fluxo com resolução
            % mais grosseira que a grade) são interpolados. Saída: NumFreqBins x NumSweeps.
            numFreqBins = modelParams.NumFreqBins;
            binIdxs     = floor((freqAxisHz - modelParams.RfMinHz) / modelParams.DeltaFHz) + 1;
            is_in_band  = binIdxs >= 1 & binIdxs <= numFreqBins;

            pointIdxs   = find(is_in_band);
            binningMatrix = sparse(binIdxs(is_in_band), pointIdxs, 1, numFreqBins, numel(freqAxisHz));
            pointsPerBin  = full(sum(binningMatrix, 2));

            linearPower = 10 .^ (levelMatrix / 10);
            rebinnedLinearPower = (binningMatrix * linearPower) ./ max(pointsPerBin, 1);

            is_empty_bin = pointsPerBin == 0;
            if any(is_empty_bin)
                emptyBinCentersHz = modelParams.RfMinHz + (find(is_empty_bin) - 0.5) * modelParams.DeltaFHz;
                rebinnedLinearPower(is_empty_bin, :) = interp1(freqAxisHz, linearPower, emptyBinCentersHz, 'linear');
            end

            rebinnedLevel = 10 * log10(max(rebinnedLinearPower, 1e-30));
        end

        %-----------------------------------------------------------------%
        function [windows, windowStarts] = splitWindows(modelParams, rebinnedLevel)
            % Recebe NumSweeps x NumFreqBins e retorna NumTraces x NumFreqBins x 1 x NumWindows,
            % além do índice da varredura inicial de cada janela.
            % Janelas a cada WindowStride varreduras; a última é alinhada à
            % última varredura. Fluxos com menos de NumTraces varreduras são
            % repetidos no tempo.
            numTraces = modelParams.NumTraces;
            numSweeps = size(rebinnedLevel, 1);

            if numSweeps < numTraces
                windows = rebinnedLevel(mod(0:numTraces-1, numSweeps) + 1, :);
                windowStarts = 1;
                return
            end

            windowStarts = 1:modelParams.WindowStride:(numSweeps - numTraces + 1);
            if windowStarts(end) + numTraces - 1 < numSweeps
                windowStarts(end+1) = numSweeps - numTraces + 1;
            end

            windows = zeros(numTraces, size(rebinnedLevel, 2), 1, numel(windowStarts));
            for ii = 1:numel(windowStarts)
                windows(:, :, 1, ii) = rebinnedLevel(windowStarts(ii):windowStarts(ii) + numTraces - 1, :);
            end
        end

        %-----------------------------------------------------------------%
        function anchorBoxes = anchors(modelParams)
            % Âncoras [x1, y1, x2, y2] em pixels (x = frequência, y = tempo),
            % na mesma ordem das predições da rede: nível da pirâmide, linha
            % (tempo), coluna (frequência) e âncora (SpectrogramDet.get_anchors).
            inputHeight = modelParams.NumTraces;
            inputWidth  = modelParams.NumFreqBins;
            anchorBoxes = zeros(0, 4);

            for levelIdx = 1:size(modelParams.PyramidLevelShapes, 1)
                levelHeight = modelParams.PyramidLevelShapes(levelIdx, 1);
                levelWidth  = modelParams.PyramidLevelShapes(levelIdx, 2);

                strideY  = inputHeight / levelHeight;
                strideX  = inputWidth  / levelWidth;
                centersY = ((0:levelHeight-1) + 0.5) * strideY;
                centersX = ((0:levelWidth-1)  + 0.5) * strideX;
                baseSize = modelParams.AnchorBaseSizeFactor * min(strideX, strideY);

                anchorWidths  = baseSize * modelParams.AnchorScales .* sqrt(modelParams.AnchorRatios);
                anchorHeights = baseSize * modelParams.AnchorScales ./ sqrt(modelParams.AnchorRatios);

                % Ordem do PyTorch (row-major [H, W, A]) equivale à ordem
                % column-major de [A, W, H].
                [anchorIdxs, gridX, gridY] = ndgrid(1:numel(anchorWidths), centersX, centersY);
                halfWidths  = anchorWidths(anchorIdxs(:))'  / 2;
                halfHeights = anchorHeights(anchorIdxs(:))' / 2;

                anchorBoxes = [anchorBoxes; gridX(:) - halfWidths, gridY(:) - halfHeights, gridX(:) + halfWidths, gridY(:) + halfHeights]; %#ok<AGROW>
            end
        end

        %-----------------------------------------------------------------%
        function [boxesPx, scores, boxSnrDb] = postprocess(modelParams, codedBoxDeltas, objectnessLogits, snrDb, anchors, scoreThreshold, nmsIoUThreshold)
            % Replica SpectrogramDet.postprocess para um exemplo: score (sem
            % cabeça de modulação, score = sigmoid(objectness)), limiar,
            % top-k, decodificação das caixas, NMS e top-k final.
            scores = 1 ./ (1 + exp(-objectnessLogits));

            candidateIdxs = find(scores >= scoreThreshold);
            [~, sortIdxs] = sort(scores(candidateIdxs), 'descend');
            candidateIdxs = candidateIdxs(sortIdxs(1:min(end, modelParams.TopkPreNMS)));

            boxesPx = util.SpecDet.decodeBoxes(modelParams, codedBoxDeltas(candidateIdxs, :), anchors(candidateIdxs, :));
            boxesPx(:, [1 3]) = min(max(boxesPx(:, [1 3]), 0), modelParams.NumFreqBins);
            boxesPx(:, [2 4]) = min(max(boxesPx(:, [2 4]), 0), modelParams.NumTraces);

            keepIdxs = util.SpecDet.nms(boxesPx, scores(candidateIdxs), nmsIoUThreshold);
            keepIdxs = keepIdxs(1:min(end, modelParams.TopkPostNMS));

            boxesPx  = boxesPx(keepIdxs, :);
            scores   = scores(candidateIdxs(keepIdxs));
            boxSnrDb = snrDb(candidateIdxs(keepIdxs));
        end

        %-----------------------------------------------------------------%
        function boxesPx = decodeBoxes(modelParams, codedBoxDeltas, anchors)
            % Replica SpectrogramDet.get_tl_br_px: deltas (dx, dy, dw, dh)
            % relativos ao centro e às dimensões da âncora.
            anchorWidths   = max(anchors(:, 3) - anchors(:, 1), 1e-6);
            anchorHeights  = max(anchors(:, 4) - anchors(:, 2), 1e-6);
            anchorCentersX = anchors(:, 1) + 0.5 * anchorWidths;
            anchorCentersY = anchors(:, 2) + 0.5 * anchorHeights;

            boxCentersX = codedBoxDeltas(:, 1) .* anchorWidths  + anchorCentersX;
            boxCentersY = codedBoxDeltas(:, 2) .* anchorHeights + anchorCentersY;
            boxWidths   = anchorWidths  .* exp(min(codedBoxDeltas(:, 3), modelParams.MaxWidthDelta));
            boxHeights  = anchorHeights .* exp(min(codedBoxDeltas(:, 4), modelParams.MaxHeightDelta));

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
        function [freqStartsHz, freqStopsHz] = px2Hz(modelParams, boxesPx)
            rfSpanHz     = modelParams.RfMaxHz - modelParams.RfMinHz;
            freqStartsHz = modelParams.RfMinHz + boxesPx(:, 1) / modelParams.NumFreqBins * rfSpanHz;
            freqStopsHz  = modelParams.RfMinHz + boxesPx(:, 3) / modelParams.NumFreqBins * rfSpanHz;
        end

        %-----------------------------------------------------------------%
        function [sweepStartIdxs, sweepStopIdxs] = px2SweepIdx(modelParams, boxesPx, windowStartSweepIdx, numSweeps)
            % Converte os limites verticais das caixas (pixels, 0 a NumTraces)
            % em índices de varredura do fluxo. A linha k da janela ocupa os
            % pixels [k-1, k].
            rowStartIdxs = floor(boxesPx(:, 2)) + 1;
            rowStopIdxs  = max(ceil(boxesPx(:, 4)), rowStartIdxs);

            if numSweeps < modelParams.NumTraces
                % Janela formada pela repetição do fluxo no tempo: caixas que
                % cobrem o fluxo inteiro ou cruzam a emenda abrangem todas as
                % varreduras.
                sweepStartIdxs = mod(rowStartIdxs - 1, numSweeps) + 1;
                sweepStopIdxs  = mod(rowStopIdxs  - 1, numSweeps) + 1;
                is_full_span   = (rowStopIdxs - rowStartIdxs + 1 >= numSweeps) | (sweepStopIdxs < sweepStartIdxs);
                sweepStartIdxs(is_full_span) = 1;
                sweepStopIdxs(is_full_span)  = numSweeps;
            else
                sweepStartIdxs = windowStartSweepIdx - 1 + rowStartIdxs;
                sweepStopIdxs  = windowStartSweepIdx - 1 + rowStopIdxs;
            end

            sweepStartIdxs = min(max(sweepStartIdxs, 1), numSweeps);
            sweepStopIdxs  = min(max(sweepStopIdxs,  1), numSweeps);
        end

        %-----------------------------------------------------------------%
        function emitters = mergeWindows(detections, mergeIoUThreshold)
            % Agrupa as detecções de todas as janelas que se sobrepõem em
            % frequência (IoU >= limiar), em ordem decrescente de score. Cada
            % grupo é um emissor, com a mediana dos limites de frequência e
            % a união dos intervalos de tempo.
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
            emitters = table('Size', [numClusters, 7], ...
                'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                'VariableNames', {'FreqStartHz', 'FreqStopHz', 'SweepStartIdx', 'SweepStopIdx', 'Score', 'SNRdB', 'NumWindows'});

            for jj = 1:numClusters
                members = detections(clusterIdxs == jj, :);
                emitters(jj, :) = {median(members.FreqStartHz), median(members.FreqStopHz), min(members.SweepStartIdx), max(members.SweepStopIdx), max(members.Score), median(members.SNRdB, 'omitnan'), numel(unique(members.WindowIdx))};
            end

            emitters = sortrows(emitters, 'FreqStartHz');
        end
    end
end
