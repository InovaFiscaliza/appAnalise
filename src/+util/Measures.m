function Measures(specData, flowIdx, emissionIdx, orientation, varargin)

    arguments
        specData    model.SpecData
        flowIdx     {mustBeInteger, mustBeNonnegative, mustBeFinite} =  1
        emissionIdx {mustBeInteger, mustBeFinite} = -1
        orientation {mustBeMember(orientation, {'Band', 'Channel', 'Emission'})} = 'Band'
    end

    arguments (Repeating)
        varargin
    end

    switch orientation
        case 'Band'
            % BAND
            % (a) "Level"
            %      Mínimo, médio e máximo por bin, armazenando a informação em 
            %      specData(idxThread).Data{3}.
            % (b) "Occupancy"
            %     FCO por bin, armazenando a informaçãoem specData(idxThread).UserData.occCache 
            %     e specData(idxThread).UserData.occoccMethod.CacheIndex.
            %     FBO da banda.
            % (c) "BandWidth"
            %     Não aplicável.

        case 'Channel'
            channelObj = varargin{1};

            % CHANNEL: itera em todos os canais
            % (a) "Level"
            %      Potência do canal.         reportChannelTable    = []
                reportChannelAnalysis = []
            % (b) "Occupancy"
            %     Aferida ocupação por ponto de frequência, armazenando a informação
            %     em specData(idxThread).UserData.occCache e
            %     specData(idxThread).UserData.occoccMethod.CacheIndex
            % (c) "BandWidth"
            %     Não aplicável.
            chTable  = specData(flowIdx).UserData.reportChannelTable;
            if isempty(chTable)
                chTable = ChannelTable2Plot(channelObj, specData(flowIdx));
                specData(flowIdx).UserData.reportChannelTable = chTable;
            end

        case 'Emission'
            bandFreqStart     = specData(flowIdx).MetaData.FreqStart;
            bandFreqStop      = specData(flowIdx).MetaData.FreqStop;
            bandDataPoints    = specData(flowIdx).MetaData.DataPoints;

            % Inicialmente, identifica os índices que delimitam a emissão:
            emissionFreqStart = specData(flowIdx).UserData.Emissions.Frequency(emissionIdx) * 1e+6 - (specData(flowIdx).UserData.Emissions.BandWidthkHz(emissionIdx)/2) * 1e+3;
            emissionFreqStop  = specData(flowIdx).UserData.Emissions.Frequency(emissionIdx) * 1e+6 + (specData(flowIdx).UserData.Emissions.BandWidthkHz(emissionIdx)/2) * 1e+3;

            idxMatrixStart    = freq2idx(bandFreqStart, bandFreqStop, bandDataPoints, emissionFreqStart);
            idxMatrixStop     = freq2idx(bandFreqStart, bandFreqStop, bandDataPoints, emissionFreqStop);

            % E agora afere as medidas...
            Level(    specData, flowIdx, emissionIdx, emissionFreqStart, emissionFreqStop)
            Occupancy(specData, flowIdx, emissionIdx, idxMatrixStart, idxMatrixStop)
            BandWidth()
    end
end

%-------------------------------------------------------------------------%
function frequencyIdx = freq2idx(freqStart, freqStop, dataPoints, frequencyInHertz)
    aCoef = (freqStop - freqStart) ./ (dataPoints - 1);
    bCoef = freqStart - aCoef;

    frequencyIdx = round((frequencyInHertz - bCoef)/aCoef);
    frequencyIdx(frequencyIdx < 1) = 1;
    frequencyIdx(frequencyIdx > dataPoints) = dataPoints;
end

%-------------------------------------------------------------------------%
function Level(specData, flowIdx, emissionIdx, emissionFreqStart, emissionFreqStop)
    frequencyIdx  = specData(flowIdx).UserData.Emissions.FrequencyIdx(emissionIdx);
    emissionPower = RF.ChannelPower(specData, flowIdx, [emissionFreqStart, emissionFreqStop]);

    specData(flowIdx).UserData.Emissions.Measures(emissionIdx).Level = struct( ...
        'FreqCenter_Min',  specData(flowIdx).Data{3}(frequencyIdx, 1), ...
        'FreqCenter_Mean', specData(flowIdx).Data{3}(frequencyIdx, 2), ...
        'FreqCenter_Max',  specData(flowIdx).Data{3}(frequencyIdx, 3), ...
        'Channel_Min',     min(emissionPower), ...
        'Channel_Mean',    mean(emissionPower), ...
        'Channel_Max',     max(emissionPower) ...
    );
end

%-------------------------------------------------------------------------%
function Occupancy(specData, flowIdx, emissionIdx, idx1, idx2)
    idxMatrixCenter = specData(flowIdx).UserData.Emissions.FrequencyIdx(emissionIdx);

    % INTEGRAÇÃO TEMPORAL INFINITA
    refInfMatrix = specData(flowIdx).UserData.OccupancyCumulativeIntegration(idx1:idx2, :);
    FBOPerSweep = 100 * sum(refInfMatrix)/(idx2 - idx1 + 1);
    FCOChannel = 100 * sum(any(refInfMatrix)) / width(refInfMatrix);
    FCOFreqCenter = 100 * sum(refInfMatrix(idxMatrixCenter-idx1+1, :)) / width(refInfMatrix);

    % INTEGRAÇÃO TEMPORAL FINITA
    cacheIndex = specData(flowIdx).UserData.OccupancyComputationMode.CacheIndex;
    refFinMatrix = specData(flowIdx).UserData.OccupancyFiniteIntegrationCache(cacheIndex).Data{3};

    % SAÍDA
    specData(flowIdx).UserData.Emissions.Measures(emissionIdx).FBO = struct( ...
        'Min', min(FBOPerSweep), ...
        'Mean', mean(FBOPerSweep), ...
        'Max', max(FBOPerSweep) ...
    );

    specData(flowIdx).UserData.Emissions.Measures(emissionIdx).FCO = struct( ...
        'Channel_Infinite', FCOChannel, ...
        'FreqCenter_Infinite', FCOFreqCenter, ...
        'FreqCenter_Finite_Min', refFinMatrix(idxMatrixCenter, 1), ...
        'FreqCenter_Finite_Mean', refFinMatrix(idxMatrixCenter, 2), ...
        'FreqCenter_Finite_Max', refFinMatrix(idxMatrixCenter, 3) ...
    );
end

%-------------------------------------------------------------------------%
function BandWidth()
    % PENDENTE
    % ...
end