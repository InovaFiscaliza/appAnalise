function GeneralTable = Channel(specData, idxThread, tempBandObj, occInfo)

    % O relatório para o PM-SAT será composto de duas tabelas. 
    % • TABELA GERAL que será apresentada abaixo do plot de toda a faixa, 
    %   contendo informações gerais de cada um dos transponders.
    % • TABELA DE EMISSÕES que será apresentada abaixo do plot de transponder
    %   ocupado, contendo informações das emissões relacionadas.
    
    % Métricas de ocupação:
    % • FCO ("Frequency Channel Occupancy"): no tempo, com integração infinita
    %   (24 horas, no caso das monitorações ordinárias do PM-SAT);
    % • FBO ("Frequency Band Occupancy"): no espaço, aferido para cada varredura.
    
    % Descrição dos passos para aferição de FCO e FBO:
    % • Faixa de guarda de 10% (5% para cima e 5% para baixo) para definição 
    %   de rol de dados que subsidiarão cálculo do THRESHOLD.
    % • Ordena os dados para cada varredura e calcula a média das 20% amostras 
    %   com menores níveis.
    % • A esse valor, soma-se 5dB de offset. Assim, define-se o THRESHOLD
    %   para cada varredura.
    % • Calcula a ocupação por bin para cada varredura (occMatrix). Limitado 
    %   apenas aos limites do canal (não usa a Faixa de Guarda).
    % • Calcula a ocupação espacial do canal por varredura (chFBO). Limitado 
    %   apenas aos limites do canal (não usa a Faixa de Guarda).
    % • Calcula a ocupação do canal no período de observação (chFCO). Um único 
    %   valor. Limitado apenas aos limites do canal (não usa a Faixa de Guarda).

    arguments
        specData 
        idxThread
        tempBandObj
        occInfo   = struct('Method',             'Linear adaptativo', ...
                           'IntegrationTime',    Inf,                 ...
                           'Offset',             5,                   ...
                           'noiseFcn',           'mean',              ...
                           'noiseTrashSamples',  0,                   ...
                           'noiseUsefulSamples', 20)

        % Estrutura "occInfo" usada no appAnalise. Externalizar essa estrutura 
        % para a classe Occupancy, e usá-la aqui, de forma a possibilitar
        % outras análises.

        % occInfo = struct('Method',                  app.play_OCC_Method.Value,                      ...
        %                  'IntegrationTime',         str2double(app.play_OCC_IntegrationTime.Value), ...
        %                  'IntegrationTimeCaptured', app.play_OCC_IntegrationTimeCaptured.Value,     ...
        %                  'THR',                     app.play_OCC_THR.Value,                         ...
        %                  'THRCaptured',             str2double(app.play_OCC_THRCaptured.Value),     ...
        %                  'Offset',                  app.play_OCC_Offset.Value,                      ...
        %                  'ceilFactor',              app.play_OCC_ceilFactor.Value,                  ...
        %                  'noiseFcn',                app.play_OCC_noiseFcn.Value,                    ...
        %                  'noiseTrashSamples',       app.play_OCC_noiseTrashSamples.Value/100,       ...
        %                  'noiseUsefulSamples',      app.play_OCC_noiseUsefulSamples.Value/100);
    end

    specData = specData(idxThread);

    chTable  = specData.UserData.reportChannelTable;
    if isempty(chTable)
        chTable = ChannelTable2Plot(tempBandObj.callingApp.channelObj, specData);
        specData.UserData.reportChannelTable = chTable;
    end

    chTable.ChannelGuardBW = ceil(chTable.ChannelBW/20);
    
    % Insere na planilha informação de ocupação total informada pela operadora...
    try
        TPDRInfo = cellfun(@(x) jsondecode(x), chTable.Reference, "UniformOutput", false);
        chTable.OCUPACAO_TOTAL = cellfun(@(x) x.OCUPACAO_TOTAL, TPDRInfo, "UniformOutput", true);
    catch
        chTable.OCUPACAO_TOTAL = -ones(height(chTable), 1);
    end

    GeneralTable   = getTableTemplate('GeneralTable', height(chTable));
    
    for ii = 1:height(chTable)
        % Limites do canal sob análise.
        chStart    = chTable.FreqStart(ii);
        chStop     = chTable.FreqStop(ii);
        
        % Limites do canal sob análise (incluindo banda de guarda).
        chStart_GB = chStart - chTable.ChannelGuardBW(ii);
        chStop_GB  = chStop  + chTable.ChannelGuardBW(ii);
    
        % Matriz de níveis do canal (incluindo banda de guarda p/ fins 
        % de cômputo do piso de ruído usando o método das 20% menores 
        % amostras). Ao final, o THR é aproximado para o interior superior
        % mais próximo (evitando casas decimais no THR).
        idx1_GB    = freq2idx(specData.MetaData.FreqStart, specData.MetaData.FreqStop, height(specData.Data{2}), chStart_GB * 1e+6);
        idx2_GB    = freq2idx(specData.MetaData.FreqStart, specData.MetaData.FreqStop, height(specData.Data{2}), chStop_GB  * 1e+6);
        nPoints_GB = idx2_GB-idx1_GB+1;
        chMatrix_GB= specData.Data{2}(idx1_GB:idx2_GB, :);
    
        sortedData = sort(chMatrix_GB);
        meanNoise  = mean(sortedData(1:ceil(.2*nPoints_GB), :));
        occTHR     = ceil(meanNoise) + occInfo.Offset;
    
        % Cálculo da ocupação por bin para cada varredura.
        idx1       = freq2idx(specData.MetaData.FreqStart, specData.MetaData.FreqStop, height(specData.Data{2}), chStart  * 1e+6);
        idx2       = freq2idx(specData.MetaData.FreqStart, specData.MetaData.FreqStop, height(specData.Data{2}), chStop   * 1e+6);
        nPoints    = idx2-idx1+1;
        chMatrix   = specData.Data{2}(idx1:idx2, :);
    
        occMatrix  = chMatrix > occTHR;
        chTable.occMatrix(ii) = {occMatrix};
    
        % Afere a ocupação por dois métodos: FBO e FCO
        % FBO: "Frequency Band Occupancy" (%)
        % FCO: "Frequency Channel Occupancy" (%)
        chFBO      = 100 * sum(occMatrix)/nPoints;
        chFCO      = 100 * sum(any(occMatrix)) / width(occMatrix);
        binFCO     = 100 * sum(occMatrix, 2)   / width(occMatrix);
    
        % Identificação de emissões relacionadas a cada transponder.
        Emissions      = specData.UserData.Emissions;
        idxEmissions   = find((Emissions.Frequency >= chStart) & (Emissions.Frequency < chStop));
        EmissionsCount = numel(idxEmissions);
        EmissionTable  = getTableTemplate('EmissionTable', numel(idxEmissions));

        for jj = 1:EmissionsCount
            idxEmission = idxEmissions(jj);
    
            EmissionFrequency    = specData.UserData.Emissions.Frequency(idxEmission);
            idxEmissionFrequency = freq2idx(chStart*1e+6, chStop*1e+6, height(chMatrix), EmissionFrequency*1e+6);
    
            EmissionDescription  = specData.UserData.Emissions.Description(idxEmission);
            if EmissionDescription == "" || ismissing(EmissionDescription)
                EmissionDescription = "-";
            end

            % Ocupação da frequência central. Uma espécia de FCO do bin que
            % corresponde à frequência central da emissão.
            % EmissionOccupancy  = 100 * sum(occMatrix(idxEmissionFrequency, :)) / width(occMatrix);
            EmissionOccupancy    = binFCO(idxEmissionFrequency);

            EmissionTable(jj, :) = {EmissionFrequency,                               ...
                                    specData.UserData.Emissions.BW_kHz(idxEmission), ...
                                    EmissionOccupancy,                               ...
                                    char(EmissionDescription)};
        end

        chName = extractBefore(chTable.Name{ii}, ' @');
        if isempty(chName)
            chName = chTable.Name{ii};
        end
    
        GeneralTable(ii, :) = {chName,                          ...
                               chTable.FirstChannel(ii),        ...
                               chTable.ChannelBW(ii) * 1000,    ...
                               chTable.Reference{ii},           ...
                               chTable.OCUPACAO_TOTAL(ii),      ...
                               min(occTHR),                     ...
                               max(occTHR),                     ...
                               occInfo.Offset,                  ...
                               min(chFBO),                      ...
                               mean(chFBO),                     ...
                               max(chFBO),                      ...
                               chFCO,                           ...
                               {struct('idx1', idx1, 'idx2', idx2, 'binFCO', binFCO)}, ...
                               EmissionsCount,                  ...
                               {idxEmissions},                  ...
                               {EmissionTable}};
    end

    specData.UserData.reportChannelAnalysis = GeneralTable;
end


%-------------------------------------------------------------------------%
function template = getTableTemplate(tableType, tableHeight)
    switch tableType
        case 'GeneralTable'
            template = table( ...
                'Size', [tableHeight, 16], ...
                 'VariableNames', {'Transponder', 'Frequência central (MHz)', 'Largura (kHz)', 'Referência', 'FBO estimada (%)', 'Threshold mínimo', 'Threshold máximo', 'Offset', 'FBO mínima (%)', 'FBO média (%)', 'FBO máxima (%)', 'FCO (%)', 'FCO per bin (%)', 'Qtd. emissões', 'idxEmission', 'Emissões'}, ...
                 'VariableTypes', {'cell', 'double', 'double', 'cell', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'cell', 'uint32', 'cell', 'cell'} ...
             );
            
        case 'EmissionTable'
            template = table( ...
                'Size', [tableHeight, 4], ...
                'VariableNames', {'Frequência central (MHz)', 'Largura (kHz)', 'FCO (%)', 'Descrição'}, ...
                'VariableTypes', {'double', 'double', 'double', 'cell'} ...
            );
    end
end


%-------------------------------------------------------------------------%
function frequencyIndex = freq2idx(freqStart, freqStop, dataPoints, frequencyInHertz)
    aCoef = (freqStop - freqStart) ./ (dataPoints - 1);
    bCoef = freqStart - aCoef;

    frequencyIndex = round((frequencyInHertz - bCoef)/aCoef);
    frequencyIndex(frequencyIndex < 1) = 1;
    frequencyIndex(frequencyIndex > dataPoints) = dataPoints;
end