classdef (Abstract) Propagation

    properties (Constant)
        %-----------------------------------------------------------------%
        RESULT_DEFAULT = struct( ...
            'StationHash', '', ...
            'MeasuredValue', [], ...
            'LevelUnit', '', ...
            'P526', struct('Lb', [], 'E', [], 'Delta', []), ...
            'P1812', struct('Lb', [], 'E', [], 'Delta', []), ...
            'IsCalculated', false, ...
            'ErrorMessage', '', ...
            'WayPoints3D', [], ...
            'TxObj', [], ...
            'RxObj', [], ...
            'PreditionData', [] ...
        )

        FLOAT_TOLERANCE = 1e-5
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [txObj, rxObj, stationSignature] = buildRFLinkObjects(specData, emissionIdx, defaultTxAntennaHeight)
            % buildRFLinkObjects Monta os objetos TX/RX de uma emissão a partir do
            % specData (sem depender de campos de UI), permitindo reaproveitamento
            % tanto na seleção de uma linha (plot) quanto no cálculo em lote
            % (colunas de predição da UITable). stationSignature é uma string que 
            % resume os dados relevantes (localização, altura de antena, frequência 
            % do canal e detalhes RFDataHub) usados no cálculo do enlace, permitindo 
            % detectar mudanças (invalidação de cache).
        
            arguments
                specData
                emissionIdx (1, 1) double
                defaultTxAntennaHeight (1, 1) double
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
            if antennaHeight <= 0
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
        
            stationSignature = sprintf('%.6f|%.6f|%.2f|%.6f|%s', classification.Latitude, classification.Longitude, antennaHeight, truncatedFrequencyMHz, classification.Details);
        end


        %-----------------------------------------------------------------%
        function predictionResult = calculateEmissionPrediction(specData, emissionIdx, txObj, rxObj, wayPoints3D, stationSignature)
            % Calcula a predição de propagação (modelos ITU-R P.526 e P.1812) 
            % para uma emissão, comparando com a potência medida (integração 
            % de canal, já em cache em specData.UserData.Emissions.Measures(emissionIdx).Level.Channel_Max).
            %
            % Esta função NÃO busca o perfil de elevação (wayPoints3D deve ser
            % fornecido pelo chamador, via RF.Elevation.Get), permitindo que o
            % chamador controle o cache/progressDialog de forma independente.
            %
            % O resultado é uma struct pronta para ser armazenada em
            % specData.UserData.Emissions.AuxAppData(emissionIdx).SignalAnalysis,
            % servindo como cache por emissão (válido até StationHash mudar).
        
            arguments
                specData
                emissionIdx  (1,1) double
                txObj        struct
                rxObj        struct
                wayPoints3D  double
                stationSignature (1,:) char = ''
            end

            % Considera-se como valor medido a máxima potência recepcionada
            % do canal (integração ao longo do canal).
            predictionResult = util.Propagation.RESULT_DEFAULT;
            predictionResult.StationHash = stationSignature;
            predictionResult.MeasuredValue = specData.UserData.Emissions.Measures(emissionIdx).Level.Channel_Max;
            predictionResult.LevelUnit = specData.MetaData.LevelUnit;
            predictionResult.WayPoints3D = wayPoints3D;
            predictionResult.TxObj = txObj;
            predictionResult.RxObj = rxObj;

            if ~ismember(predictionResult.LevelUnit, {'dBµV/m', 'dBμV/m'})
                predictionResult.ErrorMessage = '<font style = "color: red;">Unidade incompatível para estimar recepção</font>';
                return
            end
        
            try
                emissionSourceDetails = specData.UserData.Emissions.Classification(emissionIdx).UserModified.Details;
                if isempty(emissionSourceDetails) || model.RFDataHub.isEmissionMerged(emissionSourceDetails)
                    predictionResult.ErrorMessage = '<font style = "color: red;">Dados do provável emissor pendentes</font>';
                    return
                end

                txData = jsondecode(emissionSourceDetails);
                if utils.numValRDH(txData.TransmitterPower) <= 0
                    predictionResult.ErrorMessage = '<font style = "color: red;">Valor de potência inválido</font>';
                    return
                end

                lineAttenuation = utils.numValRDH(txData.LineAttenuation);
                totalLineLoss = 10 ^ (-(lineAttenuation + utils.numValRDH(txData.LineAccessoryLosses)) / 10);
                
                txObj.AntennaAzimuth   = utils.numValRDH(txData.AntennaAzimuth);
                txObj.AntennaElevation = utils.numValRDH(txData.AntennaElevation);
                txObj.TransmitterPower = utils.numValRDH(txData.TransmitterPower) * totalLineLoss;
                if ~strcmp(txData.AntennaPattern, '-1')
                    txObj.AntennaPattern = txData.AntennaPattern;
                else
                    txObj.AntennaPattern = "{'0': 0}";
                end
        
                preditionData = struct( ...
                    'modeloPredicao', '', ...
                    'frequencia', txObj.TransmitterFrequency, ...
                    'dadosRelevo', wayPoints3D(:,3), ...
                    'dadosClutter', [], ...
                    'Movel', struct( ...
                        'Antena', struct( ...
                            'Altura',  utils.numValRDH(rxObj.AntennaHeight) ...
                        ) ...
                    ), ...
                    'Base', struct( ...
                        'Nome', txObj.Name, ...
                        'Latitude', txObj.Latitude, ...
                        'Longitude', txObj.Longitude, ...
                        'Potencia', txObj.TransmitterPower, ...
                        'Antena', struct( ...
                            'Altura', txObj.AntennaHeight, ...
                            'ArquivoDados', txObj.AntennaPattern, ...
                            'Modelo', 'AIR6419', ...
                            'Funcao', 'TX', ...
                            'Azimute', txObj.AntennaAzimuth, ...
                            'tiltMecanico', txObj.AntennaElevation, ...
                            'Tipo', 'isotropic' ...
                        ) ...
                    ) ...
                );

                % Predição de propagação — suporta P.526 e P.1812
                txAntenna = wayPoints3D(1,3);
                if txObj.AntennaHeight > 0
                    txAntenna = txAntenna + txObj.AntennaHeight;
                end
    
                rxAntenna = wayPoints3D(end,3);
                rxObj.AntennaHeight = rxObj.AntennaHeight + 30; % hardcode 30m de offset na altura da antena do sensor
                if rxObj.AntennaHeight > 0
                    rxAntenna = rxAntenna + rxObj.AntennaHeight;
                end
    
                [~, distMeters, d1, az] = RF.Propagation.FresnelZone(txObj, rxObj, height(wayPoints3D));
    
                modelDict = dictionary(["ITU P526", "ITU P1812"], ["P.526", "P.1812"]);
                for ii = 1:numel(modelDict.keys)
                    modelName = modelDict(modelDict.keys{ii});
                    preditionData.modeloPredicao = modelName;
    
                    [Lb_pred, E_pred] = utils.calcPredicaoEnlace(preditionData, rxObj, txAntenna, rxAntenna, distMeters, az, d1, wayPoints3D);
    
                    delta = [];
                    if ~isempty(E_pred)
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
                predictionResult.PreditionData = preditionData;
                predictionResult.IsCalculated = true;
        
            catch ME
                predictionResult.ErrorMessage = sprintf('<font style = "color: red;">%s</font>', ME.message);
            end
        end
    end
end