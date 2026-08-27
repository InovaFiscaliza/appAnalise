function predictionResult = calcEmissionPropagationPrediction(specData, emissionIdx, txObj, rxObj, wayPoints3D, stationSignature)
    % calcEmissionPropagationPrediction Calcula a predição de propagação
    % (modelos ITU-R P.526 e P.1812) para uma emissão, comparando com a
    % potência medida (integração de canal, já em cache em
    % specData.UserData.Emissions.Measures(emissionIdx).Level.Channel_Max).
    %
    %   predictionResult = util.calcEmissionPropagationPrediction(specData, emissionIdx, txObj, rxObj, wayPoints3D, stationSignature)
    %
    %   Esta função NÃO busca o perfil de elevação (wayPoints3D deve ser
    %   fornecido pelo chamador, via RF.Elevation.Get), permitindo que o
    %   chamador controle o cache/progressDialog de forma independente.
    %
    %   O resultado é uma struct pronta para ser armazenada em
    %   specData.UserData.Emissions.AuxAppData(emissionIdx).SignalAnalysis,
    %   servindo como cache por emissão (válido até StationHash mudar).

    arguments
        specData
        emissionIdx  (1,1) double
        txObj        struct
        rxObj        struct
        wayPoints3D  double
        stationSignature (1,:) char = ''
    end

    predictionResult = struct( ...
        'StationHash',   stationSignature, ...
        'MeasuredValue', [], ...
        'LevelUnit',     '', ...
        'P526',          struct('Lb', [], 'E', [], 'Delta', []), ...
        'P1812',         struct('Lb', [], 'E', [], 'Delta', []), ...
        'IsCalculated',  false, ...
        'ErrorMessage',  '', ...
        'WayPoints3D',   wayPoints3D, ...
        'TxObj',         txObj, ...
        'RxObj',         rxObj, ...
        'PreditionData', [] ...
        );

    try
        classification = specData.UserData.Emissions.Classification(emissionIdx).UserModified;

        clutterData = [];

        txJson = jsondecode(classification.Details);
        txData = struct2table(txJson);
        lineAttenuation = utils.numValRDH(txData.LineAttenuation);
        totalLineLoss   = 10 ^ (-(lineAttenuation + utils.numValRDH(txData.LineAccessoryLosses)) / 10);
        txObj.AntennaAzimuth   = utils.numValRDH(txData.AntennaAzimuth);
        txObj.AntennaElevation = utils.numValRDH(txData.AntennaElevation);
        txObj.TransmitterPower = utils.numValRDH(txData.TransmitterPower) * totalLineLoss;
        if ~strcmp(txData.AntennaPattern, '-1')
            txObj.AntennaPattern = txData.AntennaPattern;
        else
            txObj.AntennaPattern = "{'0': 0}";
        end

        modelDict = dictionary(["COST-231/Hata", "ITU P526", "ITU P1812"], ...
            ["Hata", "P.526", "P.1812"]);
        preditionData = struct('modeloPredicao', modelDict("ITU P526"), ...
            'frequencia',     txObj.TransmitterFrequency, ...
            'dadosRelevo',    wayPoints3D(:,3), ...
            'dadosClutter',   clutterData, ...
            'Movel', struct('Antena', struct('Altura',  utils.numValRDH(rxObj.AntennaHeight))), ...
            'Base',  struct('Nome', txObj.Name, ...
            'Latitude', txObj.Latitude, ...
            'Longitude', txObj.Longitude, ...
            'Potencia', txObj.TransmitterPower, ...
            'Antena', struct('Altura', txObj.AntennaHeight, ...
            'ArquivoDados', txObj.AntennaPattern, ...
            'Modelo', 'AIR6419', ...
            'Funcao', 'TX', ...
            'Azimute', txObj.AntennaAzimuth, ...
            'tiltMecanico', txObj.AntennaElevation, ...
            'Tipo', 'isotropic')));

        predictionResult.LevelUnit = specData.MetaData.LevelUnit;
        try
            predictionResult.MeasuredValue = specData.UserData.Emissions.Measures(emissionIdx).Level.Channel_Max;
        catch
            predictionResult.MeasuredValue = [];
        end

        % Predição de propagação (OPCIONAL) — suporta P.526 e P.1812
        if preditionData.Base.Potencia > 0
            txAntenna = wayPoints3D(1,3);
            if txObj.AntennaHeight > 0
                txAntenna = txAntenna + txObj.AntennaHeight;
            end

            rxAntenna = wayPoints3D(end,3);
            rxObj.AntennaHeight = rxObj.AntennaHeight + 30; % hardcode 30m de offset na altura da antena do sensor
            if rxObj.AntennaHeight > 0
                rxAntenna = rxAntenna + rxObj.AntennaHeight;
            end

            [~, distM, d1, Azimuth] = RF.Propagation.FresnelZone(txObj, rxObj, height(wayPoints3D));

            for ii = 2:numel(modelDict.keys)
                modelName = modelDict(modelDict.keys{ii});
                preditionData.modeloPredicao = modelName;

                [Lb_pred, E_pred] = utils.calcPredicaoEnlace(preditionData, rxObj, txAntenna, rxAntenna, distM, Azimuth, d1, wayPoints3D);

                delta = [];
                if ~isempty(E_pred) && ~isempty(predictionResult.MeasuredValue) && strcmp(predictionResult.LevelUnit, 'dBµV/m')
                    delta = predictionResult.MeasuredValue - E_pred;
                end

                switch modelName
                    case 'P.526'
                        predictionResult.P526  = struct('Lb', Lb_pred, 'E', E_pred, 'Delta', delta);
                    case 'P.1812'
                        predictionResult.P1812 = struct('Lb', Lb_pred, 'E', E_pred, 'Delta', delta);
                end
            end

            predictionResult.RxObj = rxObj; % refletir ajuste de +30m aplicado acima
        end

        predictionResult.PreditionData = preditionData;
        predictionResult.IsCalculated  = true;

    catch ME
        predictionResult.ErrorMessage = ME.message;
        predictionResult.IsCalculated = false;
    end
end
