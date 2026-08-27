function [txObj, rxObj, stationSignature] = buildRFLinkObjects(specData, emissionIdx, defaultTxAntennaHeight)
    % buildRFLinkObjects Monta os objetos TX/RX de uma emissão a partir do
    % specData (sem depender de campos de UI), permitindo reaproveitamento
    % tanto na seleção de uma linha (plot) quanto no cálculo em lote
    % (colunas de predição da UITable).
    %
    %   [txObj, rxObj, stationSignature] = util.buildRFLinkObjects(specData, emissionIdx, defaultTxAntennaHeight)
    %
    %   stationSignature: string que resume os dados relevantes (localização,
    %   altura de antena, frequência do canal e detalhes RFDataHub) usados
    %   no cálculo do enlace, permitindo detectar mudanças (invalidação de
    %   cache) sem precisar recalcular tudo novamente.

    arguments
        specData
        emissionIdx (1,1) double
        defaultTxAntennaHeight (1,1) double
    end

    classification = specData.UserData.Emissions.Classification(emissionIdx).UserModified;

    if (classification.Latitude == -1) && (classification.Longitude == -1)
        error('util:buildRFLinkObjects:EmptyLocation', 'Unexpected empty index')
    end

    if specData.UserData.Emissions.IsTruncated(emissionIdx)
        truncatedFrequencyMHz = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.Frequency;
    else
        truncatedFrequencyMHz = specData.UserData.Emissions.Frequency(emissionIdx);
    end

    antennaHeight = classification.AntennaHeight;
    if ~(antennaHeight > 0)
        antennaHeight = defaultTxAntennaHeight;
    end

    txObj = struct( ...
        'Name', 'TX', ...
        'TransmitterFrequency', double(truncatedFrequencyMHz * 1e+6), ...
        'Latitude', classification.Latitude, ...
        'Longitude', classification.Longitude, ...
        'AntennaHeight', antennaHeight ...
        );

    rxObj = struct( ...
        'Name', 'RX', ...
        'Latitude', specData.GPS.Latitude, ...
        'Longitude', specData.GPS.Longitude, ...
        'AntennaHeight', calculateAntennaHeight(specData, 1, 10) ...
        );

    stationSignature = sprintf('%.6f|%.6f|%.2f|%.6f|%s', ...
        classification.Latitude, classification.Longitude, antennaHeight, truncatedFrequencyMHz, classification.Details);
end
