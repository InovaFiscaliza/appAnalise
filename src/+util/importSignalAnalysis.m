function importSignalAnalysis(specData, exportedEmissions, metaData, projectData, channelObj, generalSettings, rfDataHub)

    % ToDo: Migrar atualizações de specData para o método "update" da classe
    % model.SpecData.

    % exportedEmissions = table( ...
    %     'Size', [0, 15], ...
    %     'VariableNames', { ...
    %         'freqCenter', 'bandWidthkHz', 'channelFrequency', 'channelBandWidthkHz', 'monitoringLatitude', 'monitoringLongitude', ...
    %         'emissionType', 'regulatory', 'service', 'station', 'description', 'annotation', 'distance', 'irregular', 'riskLevel' ...
    %     }, ...
    %     'VariableTypes', { ...
    %         'double', 'double', 'double', 'double', 'double', 'double', ...
    %         'cell', 'cell', 'int16', 'int32', 'cell', 'string', 'double', 'cell', 'cell' ...
    %     } ...
    % );

    method = {jsonencode(struct('Algorithm', 'ExternalFile'))};

    for ii = 1:numel(specData)
        tempEmissions = exportedEmissions;
        emissionIdxs  = util.Detection.freq2idx(specData(ii), tempEmissions.freqCenter * 1e+6);
        invalidIdxs   = ismember(emissionIdxs, [1, specData(ii).MetaData.DataPoints]);
    
        if all(invalidIdxs)
            continue
        end
    
        tempEmissions(invalidIdxs,:) = [];
        emissionIdxs(invalidIdxs) = [];
    
        if ~isempty(specData(ii)) && (isempty(specData(ii).Data) || (numel(specData(ii).Data{1}) ~= sum(specData(ii).RelatedFiles.NumSweeps)))
            try
                populateSpectrum(specData(ii), metaData,  projectData, channelObj, generalSettings)
            catch
                continue
            end
        end

        for jj = 1:height(tempEmissions)
            freqCenter   = tempEmissions.freqCenter(jj); % Em MHz
            bandWidthkHz = tempEmissions.bandWidthkHz(jj);
            annotation   = tempEmissions.annotation(jj);

            update(specData(ii), 'UserData:Emissions', 'Add', emissionIdxs(jj), freqCenter, bandWidthkHz, method, annotation, channelObj)

            emissionIdx = find(specData(ii).UserData.Emissions.FrequencyIdx == emissionIdxs(jj), 1);
            if ~isempty(emissionIdx)
                % A classificação não é tão importante quanto a inclusão da
                % emissão. Dessa forma, eventual erro fica protegido no bloco
                % try/catch.

                try
                    currentChannel = specData(ii).UserData.Emissions.ChannelAssigned(emissionIdx).UserModified;
                    currentClass = specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified;
                    
                    % Canal
                    channelFrequency = tempEmissions.channelFrequency(jj);
                    channelBandWidthkHz = tempEmissions.channelBandWidthkHz(jj);
    
                    if abs(currentChannel.Frequency - channelFrequency) >= 1e-3 || abs(currentChannel.ChannelBW - channelBandWidthkHz) >= 1e-1
                        update(specData(ii), 'UserData:Emissions', 'Edit', 'Channel', emissionIdx, channelFrequency, channelBandWidthkHz, channelObj)
                    end
    
                    % Classificação
                    station = tempEmissions.station(jj);
                    emissionType = tempEmissions.emissionType{jj};
                    regulatory = tempEmissions.regulatory{jj};
                    irregular = tempEmissions.irregular{jj};
                    riskLevel = tempEmissions.riskLevel{jj};
    
                    if station > 0 && currentClass.Station ~= station
                        receiverLatitude  = specData(ii).GPS.Latitude;
                        receiverLongitude = specData(ii).GPS.Longitude;
                        stationInfo = model.RFDataHub.query(rfDataHub, station, receiverLatitude, receiverLongitude);
    
                        switch stationInfo.Service 
                            case -1
                                newRegulatory = 'Não licenciada';
                                newCompliance = 'Sim';
                                newRiskLevel  = 'Baixo';
                            otherwise
                                newRegulatory = 'Licenciada';
                                newCompliance = 'Não';
                                newRiskLevel  = '-';
                        end
    
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Service       = stationInfo.Service;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Station       = stationInfo.Station;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Latitude      = stationInfo.Latitude;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Longitude     = stationInfo.Longitude;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.AntennaHeight = stationInfo.AntennaHeight;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Description   = stationInfo.Description;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Details       = stationInfo.Details;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Distance      = stationInfo.Distance;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Regulatory    = newRegulatory;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.EmissionType  = 'Fundamental';                        
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Irregular     = newCompliance;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.RiskLevel     = newRiskLevel;
                    end
    
                    if ~strcmp(currentClass.EmissionType, emissionType) || ...
                       ~strcmp(currentClass.Regulatory,   regulatory)   || ...
                       ~strcmp(currentClass.Irregular,    irregular)    || ...
                       ~strcmp(currentClass.RiskLevel,    riskLevel)
    
                        oldRegulatory = currentClass.Regulatory;
                        newRegulatory = regulatory;
    
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Regulatory    = regulatory;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.EmissionType  = emissionType;                        
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Irregular     = irregular;
                        specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.RiskLevel     = riskLevel;
    
                        if newRegulatory ~= "Licenciada"
                            specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Service     = int16(-1);
                            specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Station     = int32(-1);
                            specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Description = '[EXC]';
                            specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Details     = '';
    
                            if oldRegulatory == "Licenciada"
                                specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Latitude      = -1;
                                specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Longitude     = -1;
                                specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.AntennaHeight = 0;
                                specData(ii).UserData.Emissions.Classification(emissionIdx).UserModified.Distance      = -1;
                            end
                        end
                    end
                catch
                end
            end
        end
    end
end