function chAssigned = emissionChannel(specData, flowIdx, emissionIdx, channelObj)

    % Trata-se de função auxiliar ao módulo de DRIVE-TEST, que busca identificar 
    % o canal relacionado à emissão.

    % A análise aqui é simplista, até porque a informação pode ser editada 
    % diretamente na GUI. 
    
    % Inicialmente, trunca-se a frequência central da emissão, caso aplicável. 
    % E, em posse dessa informação, busca-se no RFDataHub todos os registros 
    % com essa frequência, retornando a largura mais comum.

    if isempty(emissionIdx)
        chFrequency = (specData(flowIdx).MetaData.FreqStart + specData(flowIdx).MetaData.FreqStop) / 2e6; % MHz
        chBandWidth = (specData(flowIdx).MetaData.FreqStop - specData(flowIdx).MetaData.FreqStart) / 1e3; % kHz
    else
        chFrequency = getChannelFrequency(specData, flowIdx, emissionIdx, channelObj);
        chBandWidth = getChannelBW(specData, flowIdx, emissionIdx, chFrequency);
    end

    chAssigned  = struct( ...
        'Frequency', round(double(chFrequency), 6), ...
        'ChannelBW', round(double(chBandWidth), 6) ...
    );
end

%-------------------------------------------------------------------------%
function chFrequency = getChannelFrequency(specData, flowIdx, emissionIdx, channelObj)
    if specData(flowIdx).UserData.Emissions.IsTruncated(emissionIdx)
        chFrequency = estimateChannelFrequency(channelObj, specData(flowIdx), specData(flowIdx).UserData.Emissions.Frequency(emissionIdx), 0);
    else
        chFrequency = specData(flowIdx).UserData.Emissions.Frequency(emissionIdx);
    end
end

%-------------------------------------------------------------------------%
function channelBandwidth = getChannelBW(specData, flowIdx, emissionIdx, channelFrequency)
    global RFDataHub

    frequencyMatchMask = abs(RFDataHub.Frequency - channelFrequency) <= 1e-5;
    channelBandwidth   = mode(RFDataHub.BW(frequencyMatchMask));
    
    if isempty(channelBandwidth) || ~isnumeric(channelBandwidth) || isnan(channelBandwidth) || (channelBandwidth <= 0)
        channelBandwidth = specData(flowIdx).UserData.Emissions.BandWidthkHz(emissionIdx);
    end
end