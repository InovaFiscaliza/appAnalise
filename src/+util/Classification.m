classdef (Abstract) Classification

    properties (Constant)
        %-----------------------------------------------------------------%
        ParametersDefault     = struct('Algorithm',  'Frequency+Distance Type 1', ...
                                       'Parameters', struct('Contour', 30,        ...
                                                            'ClassMultiplier', 2, ...
                                                            'bwFactors', [100, 300]))

        ClassificationDefault = struct('Service',       int16(-1),                ...
                                       'Station',       int32(-1),                ...
                                       'Latitude',      -1,                       ...
                                       'Longitude',     -1,                       ...
                                       'AntennaHeight', 0,                        ...
                                       'Description',   '-',                      ...
                                       'Details',       '',                       ...
                                       'Distance',      -1,                       ...
                                       'Regulatory',    'Não licenciada',         ...
                                       'EmissionType',  'Pendente identificação', ...
                                       'Irregular',     'Sim',                    ...
                                       'RiskLevel',     'Baixo')
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function emissionInfo = run(specData, idxThread, idxEmission, channelObj)    
            % Classificação inicial....
            emissionInfo = util.Classification.ClassificationDefault;
        
            % Trunca a frequência central da emissão, caso aplicável, possibilitando 
            % a sua classificação.
            Truncated = specData(idxThread).UserData.Emissions.Frequency(idxEmission);
            if specData(idxThread).UserData.Emissions.isTruncated(idxEmission)
                Truncated = TruncatedFrequency(channelObj, specData(idxThread), idxEmission);
            end
        
            % Se a frequência trunca estiver na lista de exceção global, então esse
            % registro retorna como a provável fonte de emissão.
            idxException = find((abs(channelObj.Exception.FreqCenter - Truncated) <= 1e-5), 1);   
        
            if ~isempty(idxException)
                emissionInfo.Regulatory   = 'Não passível de licenciamento';
                emissionInfo.Description  = channelObj.Exception.Description{idxException};
                emissionInfo.EmissionType = 'Fundamental';
                emissionInfo.Irregular    = 'Não';
                emissionInfo.RiskLevel    = '-';
        
            else
                switch specData(idxThread).UserData.reportAlgorithms.Classification.Algorithm
                    case 'Frequency+Distance Type 1'
                        emissionInfo = util.Classification.Type1_FreqDist(emissionInfo, Truncated, specData, idxThread, idxEmission, channelObj);
            
                    otherwise
                        error('Unexpected classification algorithm.')
                end
            end
        end
        
        %-------------------------------------------------------------------------%
        function emissionInfo = Type1_FreqDist(emissionInfo, Truncated, specData, idxThread, idxEmission, channelObj)
        
            global RFDataHub
        
            % Características da canalização primária do fluxo de dados sob análise,
            % além dos parâmetros relacionados ao algoritmo "Frequency+Distance Type 1".
            findPeaks       = FindPeaksOfPrimaryBand(channelObj, specData(idxThread));
            ruralContour    = specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.Contour;
            classMultiplier = specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.ClassMultiplier;
            bandwidthRange  = specData(idxThread).UserData.reportAlgorithms.Classification.Parameters.bwFactors / 100;
            
            % Identifica registros de RFDataHub que possuem a mesma frequência da
            % emissão.
            idxRFDataHub    = find(abs(RFDataHub.Frequency - Truncated) <= 1e-5);
            if isempty(idxRFDataHub)
                return
            end
        
            % Classifica...
            RFDataHubStationsDistance = deg2km(distance(specData(idxThread).GPS.Latitude, specData(idxThread).GPS.Longitude, ...
                                                        RFDataHub.Latitude(idxRFDataHub), RFDataHub.Longitude(idxRFDataHub)));
        
            while true
                if isempty(RFDataHubStationsDistance)
                    break
                end
        
                % Identifica a estação mais próxima...
                [refStationDistance, ...
                 idxStation]          = min(RFDataHubStationsDistance);
        
                % ToDo:
                % Criar método na classe RFDataHub que retorne os dados da estação.
        
                % stationID   = ['#' num2str(idxRFDataHub(idxStation))];
                % stationInfo = query(RFDataHub, stationID, specData(idxThread).GPS.Latitude, specData(idxThread).GPS.Longitude);
        
                refStationService     = RFDataHub.Service(idxRFDataHub(idxStation));
                refStationNumber      = RFDataHub.Station(idxRFDataHub(idxStation));        
                refStationLatitude    = RFDataHub.Latitude(idxRFDataHub(idxStation));
                refStationLongitude   = RFDataHub.Longitude(idxRFDataHub(idxStation));
                refStationDescription = model.RFDataHub.Description(RFDataHub, idxRFDataHub(idxStation));
        
                try
                    refStationAntennaHeight = str2double(char(RFDataHub.AntennaHeight(idxRFDataHub(idxStation))));
        
                    mustBeFinite(refStationAntennaHeight)
                    mustBeNonnegative(refStationAntennaHeight)
                    mustBeNonempty(refStationAntennaHeight)             
                catch
                    refStationAntennaHeight = 0;
                end
        
                if RFDataHub.BW(idxRFDataHub(idxStation)) > 0
                    refStationBandWidth = RFDataHub.BW(idxRFDataHub(idxStation));
                else
                    refStationBandWidth = specData(idxThread).UserData.Emissions.BW_kHz(idxEmission);
                end
        
                if isempty(findPeaks) || ~ismember(findPeaks.Name{1}, {'FM', 'TV'})
                    break
                else
                    switch findPeaks.Name{1}
                        case 'FM'
                            if contains(refStationDescription, ["[SRD] RADCOM", "[SRD] 231"])
                                if refStationDistance <= classMultiplier * 2.2
                                    classContour = 2.2;
                                    break
                                else
                                    idxRFDataHub(idxStation)              = [];
                                    RFDataHubStationsDistance(idxStation) = [];
                                    continue
                                end                        
                            elseif contains(refStationDescription, "[MOSAICO-SRD] FM") 
                                classStation = char(RFDataHub.StationClass(idxRFDataHub(idxStation)));
                                if ismember(classStation(1), {'A', 'B', 'C', 'E'})
                                    classContour = util.Classification.FM_classCountour(classStation(1));
                                    break
                                else
                                    idxRFDataHub(idxStation)              = [];
                                    RFDataHubStationsDistance(idxStation) = [];
                                    continue
                                end
                            else
                                break
                            end
                        
                        case 'TV'
                            if contains(refStationDescription, "[MOSAICO-SRD] TV")
                                classStation = char(RFDataHub.StationClass(idxRFDataHub(idxStation)));
                                if ismember(classStation(1), {'A', 'B', 'C', 'E'})
                                    classContour = util.Classification.TV_classCountour(classStation(1));
                                    break
                                else
                                    idxRFDataHub(idxStation)              = [];
                                    RFDataHubStationsDistance(idxStation) = [];
                                    continue
                                end
                            else
                                break
                            end
                    end
                end
            end
        
            if ~isempty(refStationDistance)
                emissionBandWidth = specData(idxThread).UserData.Emissions.BW_kHz(idxEmission);
                if exist('classContour', 'var')
                    ruralContour = classMultiplier * classContour;
                end        
        
                if (refStationDistance > ruralContour) || (refStationBandWidth < (1-bandwidthRange(1))*emissionBandWidth) || (refStationBandWidth > (1+bandwidthRange(2))*emissionBandWidth)
                    return
                end
                
                emissionInfo.Service        = refStationService;
                emissionInfo.Station        = refStationNumber;
                emissionInfo.Latitude       = refStationLatitude;
                emissionInfo.Longitude      = refStationLongitude;
                emissionInfo.AntennaHeight  = refStationAntennaHeight;
                emissionInfo.Description    = refStationDescription;
                emissionInfo.Distance       = refStationDistance;
                emissionInfo.Details        = jsonencode(RFDataHub(idxRFDataHub(idxStation), setdiff(RFDataHub.Properties.VariableNames, {'Service', 'Station', 'Latitude', 'Longitude', 'AntennaHeight'})));
                emissionInfo.EmissionType   = 'Fundamental';
        
                if refStationService ~= -1
                    emissionInfo.Regulatory = 'Licenciada';
                    emissionInfo.Irregular  = 'Não';
                    emissionInfo.RiskLevel  = '-';
                end
            end
        end
        
        %-------------------------------------------------------------------------%
        function classContour = FM_classCountour(classStation)
            switch classStation
                case 'C'; classContour =  7.5;
                case 'B'; classContour = 16.5;
                case 'A'; classContour = 38.5;
                case 'E'; classContour = 78.5;
            end
        end
        
        %-------------------------------------------------------------------------%
        function classContour = TV_classCountour(classStation)
            switch classStation
                case 'C'; classContour = 20.2;
                case 'B'; classContour = 32.3;
                case 'A'; classContour = 47.9;
                case 'E'; classContour = 65.6;
            end
        end
    end
end