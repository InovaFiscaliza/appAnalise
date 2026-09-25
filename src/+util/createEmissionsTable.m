function emissionsTable = createEmissionsTable(specData, flowIdxs, operationType, generalSettings)
    arguments
        specData
        flowIdxs
        operationType {mustBeMember(operationType, {'SIGNALANALYSIS: GUI', 'REPORT: HTMLFile'})}
        generalSettings = []
    end

    % Cria-se um objeto "SpecData" apenas p/ identificar formato base da 
    % tabela Emissions. Adiciona-se as colunas requeridas pela GUI (no
    % caso, auxApp.winSignalAnalysis).
    if isempty(flowIdxs)
        specTempData = model.SpecData;
        specTempData.UserData(1).LOG = '';

        emissionsTable = specTempData.UserData.Emissions;
        emissionsTable.Truncated(:) = zeros(0);
        emissionsTable.LevelRange(:) = {};
        emissionsTable.FCORange(:) = {};
        emissionsTable.Prediction(:) = {};
        emissionsTable.PredictionWarning(:) = false(0);
        emissionsTable.RFDataHubDescription(:) = {};
        emissionsTable.Distance(:) = {};

        return
    end

    emissionsTempTableCellArray = {};

    for ii = flowIdxs
        emissionsTempTable = specData(ii).UserData.Emissions;
        emissionsCount = height(emissionsTempTable);
        
        emissionsTempTable.Truncated = arrayfun(@(x) x.UserModified.Frequency, emissionsTempTable.ChannelAssigned);
        if any(~emissionsTempTable.IsTruncated)
            untruncatedIdxs = find(~emissionsTempTable.IsTruncated);
            emissionsTempTable.Truncated(untruncatedIdxs) = emissionsTempTable.Frequency(untruncatedIdxs);
        end

        emissionsTempTable.Band(:) = {sprintf('%.3f - %.3f MHz', specData(ii).MetaData.FreqStart/1e6, specData(ii).MetaData.FreqStop/1e6)};
        emissionsTempTable.flowIdx(:) = ii;
        emissionsTempTable.emissionIdx = (1:height(emissionsTempTable))';

        emissionsTempTable.Level_FreqCenter_Min = arrayfun(@(x) x.Level.FreqCenter_Min, emissionsTempTable.Measures);
        emissionsTempTable.Level_FreqCenter_Mean = arrayfun(@(x) x.Level.FreqCenter_Mean, emissionsTempTable.Measures);
        emissionsTempTable.Level_FreqCenter_Max = arrayfun(@(x) x.Level.FreqCenter_Max, emissionsTempTable.Measures);
        emissionsTempTable.LevelRange = arrayfun(@(x,y) sprintf('%.1f a %.1f %s', x, y, specData(ii).MetaData.LevelUnit), emissionsTempTable.Level_FreqCenter_Min, emissionsTempTable.Level_FreqCenter_Max, 'UniformOutput', false);

        emissionsTempTable.FCO_FreqCenter_Infinite = arrayfun(@(x) x.FCO.FreqCenter_Infinite, emissionsTempTable.Measures);
        emissionsTempTable.FCO_FreqCenter_Finite_Min = arrayfun(@(x) x.FCO.FreqCenter_Finite_Min, emissionsTempTable.Measures);
        emissionsTempTable.FCO_FreqCenter_Finite_Mean = arrayfun(@(x) x.FCO.FreqCenter_Finite_Mean, emissionsTempTable.Measures);
        emissionsTempTable.FCO_FreqCenter_Finite_Max = arrayfun(@(x) x.FCO.FreqCenter_Finite_Max, emissionsTempTable.Measures);
        
        emissionsTempTable.FCORange = arrayfun(@(x,y) sprintf('%.1f a %.1f%%', x, y), emissionsTempTable.FCO_FreqCenter_Finite_Min, emissionsTempTable.FCO_FreqCenter_Finite_Max, 'UniformOutput', false);
        sameOccupancyIdxs = find(emissionsTempTable.FCO_FreqCenter_Finite_Min == emissionsTempTable.FCO_FreqCenter_Finite_Max);
        if ~isempty(sameOccupancyIdxs)
            emissionsTempTable.FCORange(sameOccupancyIdxs) = extractAfter(emissionsTempTable.FCORange(sameOccupancyIdxs), ' a ');
        end

        emissionsTempTable.RFDataHubDescription = arrayfun(@(x) x.UserModified.Description, emissionsTempTable.Classification, 'UniformOutput', false);
        emissionsTempTable.Distance = arrayfun(@(x) x.UserModified.Distance, emissionsTempTable.Classification);

        % Predição de propagação: cache por emissão, calculado em
        % auxApp.winSignalAnalysis/getOrCalculateEmissionPrediction
        emissionsTempTable.Prediction = repmat({'-'}, emissionsCount, 1);
        emissionsTempTable.PredictionWarning = false(emissionsCount, 1);

        for jj = 1:height(emissionsTempTable)
            predictionResult = emissionsTempTable.AuxAppData(jj).SignalAnalysis;
            if isempty(predictionResult)
                continue
            end

            if predictionResult.IsCalculated
                delta = min(abs([predictionResult.P526.Delta, predictionResult.P1812.Delta]));
                predictionSummary = sprintf([ ...
                    '%.1f dBµV/m (integração canal)\n' ...
                    '%.1f (P.526) e %.1f dBµV/m (P.1812)\n' ...
                    'Δmin = %.1f dB' ...
                ], predictionResult.MeasuredValue, predictionResult.P526.E, predictionResult.P1812.E, delta);

                if ~isempty(generalSettings) && delta > generalSettings.context.SIGNALANALYSIS.detection.deltaPrediction
                    predictionSummary = [predictionSummary, ' ❗'];
                    
                    if emissionsTempTable.Classification(jj).UserModified.AlertClassificationMismatch
                        emissionsTempTable.PredictionWarning(jj) = true;
                    end
                end

            else
                predictionSummary = sprintf([ ...
                    '%.1f %s (integração canal)\n' ...
                    '%s' ...
                ], predictionResult.MeasuredValue, predictionResult.LevelUnit, predictionResult.ErrorMessage);
            end

            emissionsTempTable.Prediction{jj} = predictionSummary;
        end

        % Colunas aplicáveis apenas às tabelas que serão renderizadas no
        % relatório HTML (e não na GUI).
        if strcmp(operationType, 'REPORT: HTMLFile')
            emissionsTempTable.Type = arrayfun(@(x) x.UserModified.EmissionType, emissionsTempTable.Classification, 'UniformOutput', false);
            emissionsTempTable.Regulatory = arrayfun(@(x) x.UserModified.Regulatory, emissionsTempTable.Classification, 'UniformOutput', false);
            emissionsTempTable.Service = arrayfun(@(x) x.UserModified.Service, emissionsTempTable.Classification);
            emissionsTempTable.Station = arrayfun(@(x) x.UserModified.Station, emissionsTempTable.Classification);
            
            emissionsTempTable.Distance_auto = arrayfun(@(x) x.AutoSuggested.Distance, emissionsTempTable.Classification);
            emissionsTempTable.Distance_auto = replace(arrayfun(@(x) sprintf('%.1f', x), emissionsTempTable.Distance_auto, 'UniformOutput', false), '-1.0', '-');
            emissionsTempTable.Distance = replace(arrayfun(@(x) sprintf('%.1f', x), emissionsTempTable.Distance, 'UniformOutput', false), '-1.0', '-');

            emissionsTempTable.Irregular = arrayfun(@(x) x.UserModified.Irregular, emissionsTempTable.Classification, 'UniformOutput', false);
            emissionsTempTable.RiskLevel = arrayfun(@(x) x.UserModified.RiskLevel, emissionsTempTable.Classification, 'UniformOutput', false);
    
            emissionsTempTable.RFDataHubSource = repmat({''}, height(emissionsTempTable), 1);
            emissionsTempTable.RFDataHubClass = repmat({''}, height(emissionsTempTable), 1);    
            
            for kk = 1:height(emissionsTempTable)
                try
                    emissionSourceDetails = jsondecode(emissionsTempTable.Classification(kk).UserModified.Details);
                    emissionsTempTable.RFDataHubSource{kk} = emissionSourceDetails.Source;
                    emissionsTempTable.RFDataHubClass{kk}  = emissionSourceDetails.StationClass(1);
                catch
                end

                emissionsTempTable.MergedDescriptions{kk} = mergeDescriptions(emissionsTempTable, kk);
            end
        end

        emissionsTempTableCellArray{end+1} = emissionsTempTable;
    end

    emissionsTable = sortrows(vertcat(emissionsTempTableCellArray{:}), {'Frequency', 'BandWidthkHz'});
end


%-------------------------------------------------------------------------%
function description = mergeDescriptions(emissionTable, idx)
    arguments
        emissionTable
        idx
    end

    % emissiontTable possui três campos de descrição:
    % (a) Descrição livre - DESCRIÇÃO_LIVRE
    %     • "emissionsTable.Description(idx)"
    %     • "string" (tipo de dado), "" (valor inicial) e editável    
    %     • Campo obrigatório, caso classificação automática não identifique como provável emissor estação na base do RFDataHub.
    %
    % (b) Descrição relacionada à classificação automática - DESCRIÇÃO_CLASSIFICAÇÃO_AUTOMÁTICA
    %     • "emissionsTable.Classification(idx).AutoSuggested.Description"
    %     • "char" (tipo de dado), '-' (valor inicial) e NÃO editável
    %     • Descrição extraída da base do RFDataHub, caso classificação automática sugira estação que consta na base.
    %
    % (c) Descrição relacionada à classificação manual - DESCRIÇÃO_CLASSIFICAÇÃO_MANUAL
    %     • "emissionsTable.Classification(idx).UserModified.Description"
    %     • "char" (tipo de dado), "emissionsTable.Classification(idx).AutoSuggested.Description" (valor inicial) e editável
    %     • Descrição extraída da base do RFDataHub, caso classificação manual sugira estação que consta na base; ou '[EXC]', caso outra fonte.
    %     • Outra informação útil, caso preenchida, é a Latitude/Longitude de uma estação que não consta na base.

    % O formato de saída muda ligeiramente, a depender se a saída é um documento JSON ou HTML.

    % Descrições primárias:
    autoDescription = emissionTable.Classification(idx).AutoSuggested.Description; % Valor: RFDataHub.Description | '-' (char)
    userDescription = emissionTable.Classification(idx).UserModified.Description;  % Valor inicial: autoDescription     (char)
    freeDescription = emissionTable.Description(idx);                              % Valor inicial: ""                  (string)
    
    % Descrições secundárias:
    userLatitude    = emissionTable.Classification(idx).UserModified.Latitude;     % Valor inicial: -1
    userLongitude   = emissionTable.Classification(idx).UserModified.Longitude;    % Valor inicial: -1

    userCoords      = '';
    if strcmp(userDescription, '[EXC]') && any([userLatitude, userLongitude] ~= -1)
        userCoords  = sprintf(' (Latitude=%.6fº, Longitude=%.6fº)', userLatitude, userLongitude);
    end

    freeDescriptionComment  = '';
    if isstring(freeDescription) && ~isempty(freeDescription.strlength) && freeDescription.strlength
        freeDescriptionComment = sprintf(' (%s)', freeDescription);
    end

    switch autoDescription
        case '-'
            if ismember(userDescription, {'-', '[EXC]'})
                description = sprintf('[EXC] %s%s', freeDescription, userCoords);
                description = addHTMLTag(description, '#FF0000');
            else
                description = addHTMLTag(userDescription, '#FF0000');
                description = addFreeDescriptionComment(description, freeDescriptionComment);
            end

        otherwise
            if isequal(autoDescription, userDescription)
                description = autoDescription;
                description = addFreeDescriptionComment(description, freeDescriptionComment);
    
            else
                switch userDescription
                    case {'-', '[EXC]'}
                        description = sprintf('[EXC] %s%s', freeDescription, userCoords);
                        description = addHTMLTag(description, '#FF0000');
                        description = sprintf('<del>%s</del><br>%s', autoDescription, description);

                    otherwise
                        description = sprintf('<del>%s</del><br><font style="color: #FF0000;">%s</font>', autoDescription, userDescription);
                        description = addFreeDescriptionComment(description, freeDescriptionComment);
                end
            end
    end
end


%-------------------------------------------------------------------------%
function description = addHTMLTag(description, color)
    description = sprintf('<font style="color: %s;">%s</font>', color, description);
end


%-------------------------------------------------------------------------%
function description = addFreeDescriptionComment(description, userFreeDescriptionComment)
    if ~isempty(userFreeDescriptionComment)
        description = sprintf('%s<br><font style="color: #0000FF;">%s</font>', description, strtrim(userFreeDescriptionComment));
    end
end