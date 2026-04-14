function emissionsTable = createEmissionsTable(specData, flowIdxs, operationType)
    arguments
        specData
        flowIdxs
        operationType {mustBeMember(operationType, {'SIGNALANALYSIS: GUI', 'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile', 'REPORT: HTMLFile'})}
    end

    if isempty(flowIdxs)
        % Cria-se um objeto "SpecData" apenas p/ identificar formato base
        % da tabela Emissions. Adiciona-se as colunas requeridas pela GUI.
        specTempData = model.SpecData;
        specTempData.UserData(1).LOG = '';

        emissionsTable                               = specTempData.UserData.Emissions;
        emissionsTable.Truncated(:)                  = zeros(0);
        emissionsTable.Level_FreqCenter_Min(:)       = zeros(0);
        emissionsTable.Level_FreqCenter_Mean(:)      = zeros(0);
        emissionsTable.Level_FreqCenter_Max(:)       = zeros(0);
        emissionsTable.FCO_FreqCenter_Infinite(:)    = zeros(0);
        emissionsTable.FCO_FreqCenter_Finite_Min(:)  = zeros(0);
        emissionsTable.FCO_FreqCenter_Finite_Mean(:) = zeros(0);
        emissionsTable.FCO_FreqCenter_Finite_Max(:)  = zeros(0);
        emissionsTable.RFDataHubDescription(:)       = {};

    else
        emissionsTempTableCellArray = {};
    
        for ii = flowIdxs
            emissionsTempTable = specData(ii).UserData.Emissions;
    
            emissionsTempTable.Truncated = arrayfun(@(x) x.UserModified.Frequency,     emissionsTempTable.ChannelAssigned);
            if any(~emissionsTempTable.IsTruncated)
                idxUntruncated = find(~emissionsTempTable.IsTruncated);
                emissionsTempTable.Truncated(idxUntruncated) = emissionsTempTable.Frequency(idxUntruncated);
            end
    
            emissionsTempTable.Band(:) = {sprintf('%.3f - %.3f MHz', specData(ii).MetaData.FreqStart/1e6, specData(ii).MetaData.FreqStop/1e6)};
            emissionsTempTable.idxThread(:) = ii;
            emissionsTempTable.idxEmission = (1:height(emissionsTempTable))';
    
            emissionsTempTable.Level_FreqCenter_Min           = arrayfun(@(x) x.Level.FreqCenter_Min,       emissionsTempTable.Measures);
            emissionsTempTable.Level_FreqCenter_Mean          = arrayfun(@(x) x.Level.FreqCenter_Mean,      emissionsTempTable.Measures);
            emissionsTempTable.Level_FreqCenter_Max           = arrayfun(@(x) x.Level.FreqCenter_Max,       emissionsTempTable.Measures);
            emissionsTempTable.FCO_FreqCenter_Infinite        = arrayfun(@(x) x.FCO.FreqCenter_Infinite,    emissionsTempTable.Measures);
            emissionsTempTable.FCO_FreqCenter_Finite_Min      = arrayfun(@(x) x.FCO.FreqCenter_Finite_Min,  emissionsTempTable.Measures);
            emissionsTempTable.FCO_FreqCenter_Finite_Mean     = arrayfun(@(x) x.FCO.FreqCenter_Finite_Mean, emissionsTempTable.Measures);
            emissionsTempTable.FCO_FreqCenter_Finite_Max      = arrayfun(@(x) x.FCO.FreqCenter_Finite_Max,  emissionsTempTable.Measures);
    
            emissionsTempTable.RFDataHubDescription_auto      = arrayfun(@(x) x.AutoSuggested.Description,  emissionsTempTable.Classification, 'UniformOutput', false);
            emissionsTempTable.RFDataHubDescription           = arrayfun(@(x) x.UserModified.Description,   emissionsTempTable.Classification, 'UniformOutput', false);
    
            if ismember(operationType, {'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile', 'REPORT: HTMLFile'})
                emissionsTempTable.Type                       = arrayfun(@(x) x.UserModified.EmissionType,  emissionsTempTable.Classification, 'UniformOutput', false);
                emissionsTempTable.Regulatory                 = arrayfun(@(x) x.UserModified.Regulatory,    emissionsTempTable.Classification, 'UniformOutput', false);
                emissionsTempTable.Service                    = arrayfun(@(x) x.UserModified.Service,       emissionsTempTable.Classification);
                emissionsTempTable.Station                    = arrayfun(@(x) x.UserModified.Station,       emissionsTempTable.Classification);
                
                emissionsTempTable.Distance_auto              = arrayfun(@(x) x.AutoSuggested.Distance,     emissionsTempTable.Classification);
                emissionsTempTable.Distance                   = arrayfun(@(x) x.UserModified.Distance,      emissionsTempTable.Classification);
    
                emissionsTempTable.Irregular                  = arrayfun(@(x) x.UserModified.Irregular,     emissionsTempTable.Classification, 'UniformOutput', false);
                emissionsTempTable.RiskLevel                  = arrayfun(@(x) x.UserModified.RiskLevel,     emissionsTempTable.Classification, 'UniformOutput', false);
        
                emissionsTempTable.RFDataHubSource            = repmat({''}, height(emissionsTempTable), 1);
                emissionsTempTable.RFDataHubClass             = repmat({''}, height(emissionsTempTable), 1);    
                
                for kk = 1:height(emissionsTempTable)
                    try
                        stationInfo = jsondecode(emissionsTempTable.Classification(kk).UserModified.Details);
        
                        emissionsTempTable.RFDataHubSource{kk} = stationInfo.Source;
                        emissionsTempTable.RFDataHubClass{kk}  = stationInfo.StationClass(1);
                    catch
                    end
                end
            end
    
            emissionsTempTableCellArray{end+1} = emissionsTempTable;
        end
    
        emissionsTable = sortrows(vertcat(emissionsTempTableCellArray{:}), {'Frequency', 'BandWidthkHz'});
        
        if ismember(operationType, {'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile', 'REPORT: HTMLFile'})
            for jj = 1:height(emissionsTable)
                emissionsTable.MergedDescriptions{jj} = mergeDescriptions(emissionsTable, jj, operationType);
            end

            if strcmp(operationType, 'REPORT: HTMLFile')
                emissionsTable.Distance_auto = replace(arrayfun(@(x) sprintf('%.1f', x), emissionsTable.Distance_auto, 'UniformOutput', false), '-1.0', '-');
                emissionsTable.Distance      = replace(arrayfun(@(x) sprintf('%.1f', x), emissionsTable.Distance,      'UniformOutput', false), '-1.0', '-');
            end
        end
    end
end


%-------------------------------------------------------------------------%
function description = mergeDescriptions(emissionTable, idx, operationType)
    arguments
        emissionTable
        idx
        operationType {mustBeMember(operationType, {'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile', 'REPORT: HTMLFile'})}
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

                if strcmp(operationType, 'REPORT: HTMLFile')
                    description = addHTMLTag(description, '#FF0000');
                end

            else
                switch operationType
                    case {'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile'}
                         description = sprintf('%s%s', userDescription, freeDescriptionComment);

                    case 'REPORT: HTMLFile'
                        description = addHTMLTag(userDescription, '#FF0000');
                        description = addFreeDescriptionComment(description, freeDescriptionComment);
                end
            end

        otherwise
            if isequal(autoDescription, userDescription)
                switch operationType
                    case {'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile'}
                         description = sprintf('%s%s', autoDescription, freeDescriptionComment);

                    case 'REPORT: HTMLFile'
                        description = autoDescription;
                        description = addFreeDescriptionComment(description, freeDescriptionComment);
                end
    
            else
                switch userDescription
                    case {'-', '[EXC]'}
                        description = sprintf('[EXC] %s%s', freeDescription, userCoords);

                        if strcmp(operationType, 'REPORT: HTMLFile')
                            description = addHTMLTag(description, '#FF0000');
                            description = sprintf('<del>%s</del><br>%s', autoDescription, description);
                        end

                    otherwise
                        switch operationType
                            case {'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile'}
                                description = sprintf('%s%s', userDescription, freeDescriptionComment);
        
                            case 'REPORT: HTMLFile'
                                description = sprintf('<del>%s</del><br><font style="color: #FF0000;">%s</font>', autoDescription, userDescription);
                                description = addFreeDescriptionComment(description, freeDescriptionComment);
                        end
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