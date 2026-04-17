function tableStr = fiscalizaJsonFile(specData, flowIdxs, emissionsTable)
    
    % Tabelas que irão compor o JSON que será carregado como anexo
    % à inspeção (no Fiscaliza).
    taskTable           = table('Size', [0, 12],                                                                                                                 ...
                                'VariableTypes', {'uint16', 'cell', 'single', 'single', 'double', 'double', 'cell', 'cell', 'uint32', 'double', 'cell', 'cell'}, ...
                                'VariableNames', {'PK1', 'Node', 'Latitude', 'Longitude', 'FreqStart', 'FreqStop', 'BeginTime', 'EndTime', 'Samples', 'timeOCC', 'Description', 'RelatedFiles'});

    occMethodTable      = table('Size', [0, 2], 'VariableTypes', {'uint16', 'cell'}, 'VariableNames', {'PK2', 'occMethod'});
    detectionTable      = table('Size', [0, 2], 'VariableTypes', {'uint16', 'cell'}, 'VariableNames', {'PK3', 'Detection'});
    classificationTable = table('Size', [0, 2], 'VariableTypes', {'uint16', 'cell'}, 'VariableNames', {'PK4', 'Classification'});

    emissionsTable.Frequency = round(emissionsTable.Frequency, 3);
    emissionsTable.BandWidthkHz = round(emissionsTable.BandWidthkHz, 1);

    jj = 0;
    for ii = flowIdxs
        try
            if ismember(specData(ii).MetaData.DataType, class.Constants.specDataTypes)
                jj = jj+1;
    
                occupancyCacheIdx = specData(ii).UserData.OccupancyComputationMode.CacheIndex;
                integrationTime = specData(ii).UserData.OccupancyFiniteIntegrationCache(occupancyCacheIdx).Parameters.IntegrationTime;
                
                taskTable(end+1,:) = {jj,                              ...
                                      specData(ii).Receiver,           ...
                                      specData(ii).GPS.Latitude,       ...
                                      specData(ii).GPS.Longitude,      ...
                                      specData(ii).MetaData.FreqStart / 1e+6, ...
                                      specData(ii).MetaData.FreqStop  / 1e+6, ...
                                      datestr(specData(ii).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), ...
                                      datestr(specData(ii).Data{1}(end), 'dd/mm/yyyy HH:MM:SS'), ...
                                      numel(specData(ii).Data{1}),      ...
                                      integrationTime,                      ...
                                      specData(ii).RelatedFiles.Description{1}, ...
                                      strjoin(specData(ii).RelatedFiles.File, ', ')};
                
                idx1 = find(emissionsTable.flowIdx == ii);
                if ~isempty(idx1)
                    emissionsTable.FK1(idx1) = uint16(jj);
                end
            end
        catch
        end
    end

    % occMethod, detection and classification tables
    occMethodList      = arrayfun(@(x) x.Occupancy,      emissionsTable.Algorithms, 'UniformOutput', false);
    DetectionList      = arrayfun(@(x) x.Detection,      emissionsTable.Algorithms, 'UniformOutput', false);
    ClassificationList = arrayfun(@(x) x.Classification, emissionsTable.Algorithms, 'UniformOutput', false);

    occMethod          = unique(occMethodList);
    Detection          = unique(DetectionList);
    Classification     = unique(ClassificationList);

    occMethodTable(1:numel(occMethod),:)           = [num2cell((1:numel(occMethod))'), cellfun(@(x) jsonencode(structUtil.delEmptyFields(jsondecode(x))), occMethod, 'UniformOutput', false)];
    detectionTable(1:numel(Detection),:)           = [num2cell((1:numel(Detection))'), Detection];    
    classificationTable(1:numel(Classification),:) = [num2cell((1:numel(Classification))'), Classification];

    for ii = 1:numel(occMethod)
        idx_OCC = find(strcmp(occMethodList, occMethod(ii)));

        if ~isempty(idx_OCC); emissionsTable.FK2(idx_OCC) = uint16(ii);
        end                
    end

    for ii = 1:numel(Detection)
        idx_Det = find(strcmp(DetectionList, Detection(ii)));

        if ~isempty(idx_Det); emissionsTable.FK3(idx_Det) = uint16(ii);
        end
    end

    for ii = 1:numel(Classification)
        idx_Cla = find(strcmp(ClassificationList, Classification(ii)));

        if ~isempty(idx_Cla); emissionsTable.FK4(idx_Cla) = uint16(ii);
        end
    end

    if ~isempty(emissionsTable)
        emissionsTable = emissionsTable(:, {'FK1', 'FK2', 'FK3', 'FK4',   ...
                                            'Frequency',                  ...
                                            'Truncated',                  ...
                                            'BandWidthkHz',               ...
                                            'Level_FreqCenter_Min',       ...
                                            'Level_FreqCenter_Mean',      ...
                                            'Level_FreqCenter_Max',       ...
                                            'FCO_FreqCenter_Finite_Mean', ...
                                            'FCO_FreqCenter_Finite_Max',  ...
                                            'Type',                       ...
                                            'Regulatory',                 ...
                                            'Service',                    ...
                                            'Station',                    ...
                                            'MergedDescriptions',         ...
                                            'Distance',                   ...
                                            'Irregular',                  ...
                                            'RiskLevel'});

        emissionsTable = renamevars(emissionsTable, emissionsTable.Properties.VariableNames([7:12, 17]), {'BW', 'minLevel', 'meanLevel', 'maxLevel', 'meanOCC', 'maxOCC', 'Description'});
        emissionsTable = movevars(emissionsTable, {'FK1', 'FK2', 'FK3', 'FK4'}, 'Before', 1);

        emissionsTable.minLevel  = round(emissionsTable.minLevel, 1);
        emissionsTable.meanLevel = round(emissionsTable.meanLevel, 1);
        emissionsTable.maxLevel  = round(emissionsTable.maxLevel, 1);
        emissionsTable.meanOCC   = round(emissionsTable.meanOCC, 1);
        emissionsTable.maxOCC    = round(emissionsTable.maxOCC, 1);
        emissionsTable.Distance  = emissionsTable.Distance;

        tableStr  = jsonencode(struct('Version', '1.01', 'ReferenceData1', taskTable, 'ReferenceData2', occMethodTable, 'ReferenceData3', detectionTable, 'ReferenceData4', classificationTable, 'MeasurementData', emissionsTable), 'PrettyPrint', true, 'ConvertInfAndNaN', false);
    else
        tableStr  = jsonencode(struct('Version', '1.01', 'ReferenceData1', taskTable), 'PrettyPrint', true, 'ConvertInfAndNaN', false);
    end            
end