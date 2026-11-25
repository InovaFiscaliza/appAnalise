function modelParams = fetchSpecDetModel(band, versionOrStage)
%FETCHSPECDETMODEL Baixa, importa e registra o modelo SpecDet de uma faixa.
%
%   modelParams = fetchSpecDetModel(band, versionOrStage)
%
%   band           - faixa do modelo, isto é, o sufixo do artefato DVC
%                    "specdet-<band>" do repositório code-anatel-axis4
%                    (ex.: "pmrd-band2").
%   versionOrStage - versão (ex.: "v0.1.0") ou estágio GTO (ex.: "demo",
%                    "prod"). O estágio é convertido na versão que ele aponta.
%
%   Gera, nesta pasta ("ai_models"), com <base> = specdet_<band>_<versão>:
%     - <base>.onnx:  modelo baixado do DVC (tag specdet-<band>@<versão>);
%     - <base>.json:  parâmetros do modelo, lidos dos metadados do ONNX;
%     - <base>.mat:   rede importada no MATLAB e inicializada;
%     - +<namespace>: camadas geradas pelo importador ONNX (não versionada).
%   E registra o modelo para a faixa em "specdet_models.json", que o
%   appAnalise (util.SpecDet) usa para escolher o modelo de cada fluxo,
%   comparando a faixa do fluxo com RfMinHz e RfMaxHz do modelo. O modelo
%   anterior da mesma faixa deixa de ser usado (seus arquivos são mantidos).
%
%   Requer modelos exportados com os parâmetros nos metadados do ONNX
%   (a partir de v0.2.0).
%
%   Pré-requisitos: "uv" no PATH, acesso ao repositório code-anatel-axis4 e
%   login na AWS (aws sso login --profile AdministratorAccess-567736086855).
%
%   Exemplos:
%     fetchSpecDetModel("pmrd-band2", "v0.1.0")
%     fetchSpecDetModel("pmrd-band2", "demo")

    arguments
        band           (1,1) string {mustBeNonzeroLengthText}
        versionOrStage (1,1) string {mustBeNonzeroLengthText}
    end

    REPO_URL = "https://github.com/ita-gnss-lab/code-anatel-axis4";
    REGISTRY_FILE_NAME = "specdet_models.json";

    aiModelsFolder = string(fileparts(mfilename('fullpath')));
    repoRootFolder = string(fileparts(aiModelsFolder));

    checkOnnxImporter()

    artifactName = "specdet-" + band;

    % Versão ou estágio
    stage = "";
    if ~isempty(regexp(versionOrStage, '^v\d+\.\d+\.\d+$', 'once'))
        version = versionOrStage;
    else
        stage   = versionOrStage;
        output  = runCommand(repoRootFolder, sprintf('uv run gto show "%s#%s" --repo %s --version', artifactName, stage, REPO_URL));
        version = string(regexp(output, 'v\d+\.\d+\.\d+', 'match', 'once'));
        if version == ""
            error('fetchSpecDetModel:UnknownStage', 'Nenhuma versão de "%s" no estágio "%s".', artifactName, stage)
        end
        fprintf('Estágio "%s" de %s: %s\n', stage, artifactName, version);
    end
    tag = artifactName + "@" + version;

    % Nomes dos arquivos. O namespace não aceita pontos nem hífens.
    baseName      = replace(artifactName, "-", "_") + "_" + version;
    namespaceName = string(matlab.lang.makeValidName(replace(baseName, ".", "_")));
    onnxFile      = fullfile(aiModelsFolder, baseName + ".onnx");
    paramsFile    = fullfile(aiModelsFolder, baseName + ".json");
    matFile       = fullfile(aiModelsFolder, baseName + ".mat");

    % 1. Modelo (ONNX)
    fprintf('Baixando %s...\n', tag);
    runCommand(repoRootFolder, sprintf('uv run dvc artifacts get %s %s --rev %s -o "%s" --force', REPO_URL, artifactName, version, onnxFile));

    % 2. Parâmetros: metadados do ONNX
    metadata = readOnnxMetadata(onnxFile);
    if metadata.artifact_name ~= artifactName || metadata.version ~= version
        error('fetchSpecDetModel:MetadataMismatch', 'O ONNX baixado é "%s@%s", mas era esperado "%s".', metadata.artifact_name, metadata.version, tag)
    end

    inputHeightWidth = metadata.input_hw;
    modelParams = struct( ...
        'Band',                  band, ...
        'Artifact',              artifactName, ...
        'Version',               version, ...
        'Tag',                   tag, ...
        'Stage',                 stage, ...
        'OnnxFile',              baseName + ".onnx", ...
        'MatFile',               baseName + ".mat", ...
        'Namespace',             namespaceName, ...
        ... % Grade do espectrograma
        'RfMinHz',               metadata.rf_min_hz, ...
        'RfMaxHz',               metadata.rf_max_hz, ...
        'DeltaFHz',              metadata.delta_f_hz, ...
        'NumFreqBins',           inputHeightWidth(2), ...
        'NumTraces',             inputHeightWidth(1), ...
        'WindowStride',          metadata.window_stride, ...
        ... % Âncoras e decodificação das caixas
        'AnchorScales',          reshape(metadata.anchor_scales, 1, []), ...
        'AnchorRatios',          reshape(metadata.anchor_ratios, 1, []), ...
        'AnchorBaseSizeFactor',  metadata.anchor_base_size_factor, ...
        'PyramidLevelShapes',    metadata.bifpn_level_shapes, ...
        'MaxWidthDelta',         metadata.max_width_delta, ...
        'MaxHeightDelta',        metadata.max_height_delta, ...
        ... % Pós-processamento
        'ScoreThreshold',        metadata.score_threshold, ...
        'NMSIoUThreshold',       metadata.nms_iou_threshold, ...
        'TopkPreNMS',            metadata.topk_pre_nms, ...
        'TopkPostNMS',           metadata.topk_post_nms);
    writelines(jsonencode(modelParams, 'PrettyPrint', true), paramsFile)

    % 3. Importação no MATLAB. A pasta de namespace é gerada na pasta atual.
    fprintf('Importando %s no MATLAB...\n', onnxFile);
    namespaceFolder = fullfile(aiModelsFolder, "+" + namespaceName);
    if isfolder(namespaceFolder)
        rmdir(namespaceFolder, 's')
    end

    initialFolder = pwd;
    restoreFolderObj = onCleanup(@() cd(initialFolder));
    cd(aiModelsFolder)
    try
        net = importNetworkFromONNX(onnxFile, 'Namespace', namespaceName);
    catch importException
        is_invalid_mex = strcmp(importException.identifier, 'MATLAB:mex:ErrInvalidMEXFile') || contains(importException.message, 'Invalid MEX-file');
        if is_invalid_mex
            versionException = MException('fetchSpecDetModel:IncompatibleMatlabVersion', ...
                ['O importador ONNX não funciona nesta versão do MATLAB (%s). ' ...
                 'Execute fetchSpecDetModel a partir do MATLAB R2025a.'], matlabRelease().Release);
            throw(addCause(versionException, importException))
        end
        rethrow(importException)
    end

    % A dimensão de lote do ONNX é dinâmica, então a rede vem não
    % inicializada. A entrada segue a ordem do ONNX: [lote, 1, tempo, frequência].
    exampleInput = dlarray(zeros(1, 1, modelParams.NumTraces, modelParams.NumFreqBins, 'single'), 'UUUU');
    net = initialize(net, exampleInput);
    save(matFile, 'net')

    % 4. Registro do modelo para a faixa
    updateRegistry(fullfile(aiModelsFolder, REGISTRY_FILE_NAME), band, baseName + ".json");

    fprintf('Modelo %s registrado para a faixa "%s" (%.3f a %.3f MHz).\n', tag, band, modelParams.RfMinHz / 1e+6, modelParams.RfMaxHz / 1e+6);
    fprintf('No appAnalise já aberto, execute "clear util.SpecDet" para recarregar os modelos.\n');
end


%-------------------------------------------------------------------------%
function checkOnnxImporter()
    % A importação requer o Deep Learning Toolbox e o add-on "Deep Learning
    % Toolbox Converter for ONNX Model Format". Verificado antes do download.
    ONNX_CONVERTER_NAME = "Deep Learning Toolbox Converter for ONNX Model Format";

    has_deep_learning_toolbox = license('test', 'Neural_Network_Toolbox') && ~isempty(ver('nnet'));
    if ~has_deep_learning_toolbox
        error('fetchSpecDetModel:MissingToolbox', 'O Deep Learning Toolbox não está instalado ou licenciado.')
    end

    installedAddons = matlab.addons.installedAddons;
    has_onnx_converter = any(installedAddons.Identifier == "ONNXCONVERTER" & installedAddons.Enabled);
    if ~has_onnx_converter || ~exist('importNetworkFromONNX', 'file')
        error('fetchSpecDetModel:MissingAddOn', ['O add-on "%s" não está instalado ou habilitado. ' ...
            'Instale-o pelo Add-On Explorer e execute novamente.'], ONNX_CONVERTER_NAME)
    end
end

%-------------------------------------------------------------------------%
function output = runCommand(workingFolder, command)
    % "uv" precisa rodar na raiz do repositório (pyproject.toml).
    if ispc
        fullCommand = sprintf('cd /d "%s" && %s', workingFolder, command);
    else
        fullCommand = sprintf('cd "%s" && %s', workingFolder, command);
    end

    [status, output] = system(fullCommand);
    if status ~= 0
        error('fetchSpecDetModel:CommandFailed', 'Falha ao executar:\n%s\n\n%s', command, output)
    end
end

%-------------------------------------------------------------------------%
function updateRegistry(registryFile, band, paramsFileName)
    % Registro: lista de {"Band": ..., "ParamsFile": ...}, uma entrada por faixa.
    registry = struct('Band', {}, 'ParamsFile', {});
    if isfile(registryFile)
        registry = jsondecode(fileread(registryFile));
        registry = reshape(registry, 1, []);
    end

    is_same_band = arrayfun(@(entry) string(entry.Band) == band, registry);
    if any(is_same_band)
        previousParamsFile = string(registry(is_same_band).ParamsFile);
        if previousParamsFile ~= paramsFileName
            fprintf('A faixa "%s" deixa de usar "%s".\n', band, previousParamsFile);
        end
        registry(is_same_band) = [];
    end

    registry(end+1) = struct('Band', char(band), 'ParamsFile', char(paramsFileName));
    [~, sortIdxs] = sort(string({registry.Band}));
    registry = registry(sortIdxs);

    % Sempre gravado como lista JSON, mesmo com uma única faixa.
    if isscalar(registry)
        registryText = sprintf('[\n%s\n]', jsonencode(registry, 'PrettyPrint', true));
    else
        registryText = jsonencode(registry, 'PrettyPrint', true);
    end
    writelines(registryText, registryFile)
end

%-------------------------------------------------------------------------%
function metadata = readOnnxMetadata(onnxFile)
    % Lê o campo metadata_props (14) do ModelProto do ONNX, uma lista de
    % pares chave/valor em texto, sem depender de Python. Os valores são
    % números ou listas JSON, exceto os textos descritivos.
    REQUIRED_KEYS = ["artifact_name", "version", "input_hw", "rf_min_hz", "rf_max_hz", "delta_f_hz", ...
                     "window_stride", "bifpn_level_shapes", "anchor_scales", "anchor_ratios", ...
                     "anchor_base_size_factor", "max_width_delta", "max_height_delta", ...
                     "score_threshold", "nms_iou_threshold", "topk_pre_nms", "topk_post_nms"];
    TEXT_KEYS = ["artifact_name", "version"];

    fileId = fopen(onnxFile, 'r');
    if fileId == -1
        error('fetchSpecDetModel:FileNotFound', 'Não foi possível abrir "%s".', onnxFile)
    end
    modelBytes = fread(fileId, Inf, '*uint8');
    fclose(fileId);

    metadata = struct();
    for entryBytes = readProtobufFields(modelBytes, 14)
        entryFields = readProtobufFields(entryBytes{1}, [1 2]);
        key   = string(native2unicode(entryFields{1}', 'UTF-8'));
        value = string(native2unicode(entryFields{2}', 'UTF-8'));
        metadata.(key) = value;
    end

    missingKeys = setdiff(REQUIRED_KEYS, string(fieldnames(metadata)), 'stable');
    if ~isempty(missingKeys)
        error('fetchSpecDetModel:MissingMetadata', 'O ONNX "%s" não contém os metadados: %s.\nModelos anteriores a v0.2.0 não são suportados.', onnxFile, strjoin(missingKeys, ', '))
    end

    for key = setdiff(REQUIRED_KEYS, TEXT_KEYS)
        metadata.(key) = jsondecode(char(metadata.(key)));
    end
end

%-------------------------------------------------------------------------%
function fieldValues = readProtobufFields(messageBytes, fieldNumbers)
    % Percorre os campos de primeiro nível de uma mensagem protobuf e
    % retorna o conteúdo (bytes) dos campos de tamanho variável (wire type
    % 2) com os números pedidos. Os demais campos, como o grafo, são pulados.
    fieldValues = {};
    position = 1;
    numBytes = numel(messageBytes);

    while position <= numBytes
        [fieldKey, position] = readVarint(messageBytes, position);
        fieldNumber = floor(fieldKey / 8);
        wireType    = mod(fieldKey, 8);

        switch wireType
            case 0 % varint
                [~, position] = readVarint(messageBytes, position);
            case 1 % 64 bits
                position = position + 8;
            case 2 % tamanho variável
                [fieldLength, position] = readVarint(messageBytes, position);
                if ismember(fieldNumber, fieldNumbers)
                    fieldValues{end+1} = messageBytes(position:position+fieldLength-1); %#ok<AGROW>
                end
                position = position + fieldLength;
            case 5 % 32 bits
                position = position + 4;
            otherwise
                error('fetchSpecDetModel:InvalidOnnx', 'Arquivo ONNX inválido (wire type %d).', wireType)
        end
    end
end

%-------------------------------------------------------------------------%
function [value, position] = readVarint(messageBytes, position)
    value = 0;
    multiplier = 1;
    while true
        currentByte = double(messageBytes(position));
        position    = position + 1;
        value       = value + mod(currentByte, 128) * multiplier;
        if currentByte < 128
            break
        end
        multiplier = multiplier * 128;
    end
end
