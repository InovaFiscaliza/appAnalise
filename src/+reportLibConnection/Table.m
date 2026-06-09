classdef (Abstract) Table

    methods (Static)
        %-----------------------------------------------------------------%
        % RESUMO DA MONITORAÇÃO
        % (única, engloba todas as faixas sob análise)
        %-----------------------------------------------------------------&
        function tbl = MonitoringBandsOverview(reportInfo)
            specData = reportInfo.Object;
            
            % Ordena em relação à "FreqStart" e "FreqStop"...
            referenceTable = buildSpectrumReferenceTable(specData, 1:numel(specData));
            sortedIdxs = referenceTable.Idx;
            specData = specData(sortedIdxs);

            tbl = table( ...
                'Size', [numel(specData), 6], ...
                'VariableTypes', {'double', 'cell', 'cell', 'cell', 'cell', 'cell'}, ...
                'VariableNames', {'ID', 'Receiver', 'LocationSummary', 'Band', 'ObservationTime', 'Parameters'} ...
            );

            for ii = 1:numel(specData)
                tbl.ID(ii) = ii;
                tbl{ii, 2:6} = { ...
                    reportLibConnection.Variable.ClassProperty(reportInfo, specData(ii), 'Receiver'), ...
                    reportLibConnection.Variable.ClassProperty(reportInfo, specData(ii), 'LocationSummary'), ...
                    reportLibConnection.Variable.ClassProperty(reportInfo, specData(ii), 'Band'), ...
                    reportLibConnection.Variable.ClassProperty(reportInfo, specData(ii), 'ObservationTime'), ...
                    reportLibConnection.Variable.ClassProperty(reportInfo, specData(ii), 'Parameters') ...
                };
            end
        end


        %-----------------------------------------------------------------%
        % ALGORITMOS DETECÇÃO, CLASSIFICAÇÃO E OCUPAÇÃO
        % (recorrente, uma tabela por faixa sob análise)
        %-----------------------------------------------------------------&
        function tbl = BandAlgorithms(analyzedData)
            tbl = table( ...
                'Size', [3, 2], ...
                'VariableTypes', {'cell', 'cell'}, ...
                'VariableNames', {'Algorithm', 'Parameters'} ...
            );
            
            specData = analyzedData.InfoSet;
            % Ocupação
            if isempty(specData.UserData.Emissions)
                occupancy = {sprintf('Método: %s',       specData.UserData.ReportAlgorithms.Occupancy.Method); ...
                             sprintf('- Parâmetros: %s', jsonencode(structUtil.delEmptyFields(specData.UserData.ReportAlgorithms.Occupancy, {'Method'})))};
        
            else        
                occupancyList = arrayfun(@(x) x.Occupancy, specData.UserData.Emissions.Algorithms, 'UniformOutput', false);
                [occupancyType, ~, occupancyTypeIdx] = unique(occupancyList, 'stable');
        
                occupancy = {};        
                for ii = 1:numel(occupancyType)
                    sOCCType   = jsondecode(occupancyType{ii});
                    sOCCIndex  = find(occupancyTypeIdx == ii);
                    peaksLabel = strjoin(string(sOCCIndex), ', ');
            
                    occupancy(end+1:end+3,1) = {sprintf('Método: %s',       sOCCType.Method); ...
                                                sprintf('- Parâmetros: %s', jsonencode(structUtil.delEmptyFields(sOCCType, {'Method'}), "ConvertInfAndNaN", false)); ...
                                                sprintf('- Emissões: %s',   peaksLabel)};
            
                    if (numel(occupancyType) > 1) && (ii < numel(occupancyType))
                        occupancy(end+1) = {'&nbsp;'};
                    end
                end
            end
        
            % Detecção
            bandLimitsStatus = specData.UserData.DetectionSubBandsEnabled;
            bandLimitsTable  = specData.UserData.DetectionSubBands;
            if ~bandLimitsStatus || isempty(bandLimitsTable)
                bandLimits = sprintf('Faixa sob análise: %.3f - %.3f MHz', specData.MetaData.FreqStart / 1e+6, ...
                                                                           specData.MetaData.FreqStop  / 1e+6);    
            else
                bandLimits = {};
                for ii = 1:height(bandLimitsTable)
                    bandLimits{end+1} = sprintf('%.3f - %.3f MHz', bandLimitsTable.FreqStart(ii), ...
                                                                   bandLimitsTable.FreqStop(ii));
                end
                bandLimits = sprintf('Faixa sob análise: %s', strjoin(bandLimits, ', '));
            end
        
            % Essa operação aqui surgiu por conta da inclusão de emissões através
            % de arquivos (seja ele gerado pelo ROMES ou outra ferramenta).
            detectionList  = arrayfun(@(x) x.Detection, specData.UserData.Emissions.Algorithms, 'UniformOutput', false);
            [detectionType, ~, detectionTypeIdx] = unique(detectionList, 'stable');
        
            detection = {'Detecção limitada às emissoes identificadas no modo PLAYBACK do appAnalise'; bandLimits};
        
            if ~isempty(detectionType)
                detection = [detection; '&nbsp;'];
            end
        
            for ii =1:numel(detectionType)
                sOCCType   = jsondecode(detectionType{ii});
                sOCCIndex  = find(detectionTypeIdx == ii);
                peaksLabel = strjoin(string(sOCCIndex), ', ');
        
                if isfield(sOCCType, 'Parameters')
                    detection(end+1:end+3,1) = {sprintf('Algoritmo: %s',    sOCCType.Algorithm);                                         ...
                                                sprintf('- Parâmetros: %s', jsonencode(sOCCType.Parameters, "ConvertInfAndNaN", false)); ...
                                                sprintf('- Emissões: %s',   peaksLabel)};
                else
                    detection(end+1:end+2,1) = {sprintf('Algoritmo: %s',    sOCCType.Algorithm); ...
                                                sprintf('- Emissões: %s',   peaksLabel)};
                end
        
                if (numel(detectionType) > 1) && (ii < numel(detectionType))
                    detection(end+1) = {'&nbsp;'};
                end
            end
            
            % Classificação
            classification = {sprintf('Algoritmo: %s',  specData.UserData.ReportAlgorithms.Classification.Algorithm); ...
                              sprintf('- Parâmetros: %s', jsonencode(specData.UserData.ReportAlgorithms.Classification.Parameters, "ConvertInfAndNaN", false))};
        
        
            tbl(1,:) = {'Ocupação',                  occupancy};
            tbl(2,:) = {'Detecção de emissões',      detection};
            tbl(3,:) = {'Classificação de emissões', classification};
        end


        %-----------------------------------------------------------------%
        % EMISSÕES
        %-----------------------------------------------------------------&
        function tbl = GlobalEmissions(dataOverview)
            tempTableCellArray = {};

            for ii = 1:numel(dataOverview)
                specData = dataOverview(ii).InfoSet;

                tempTable = util.createEmissionsTable(specData, 1, 'REPORT: HTMLFile');
                tempTable.ID = string(ii) + "." + string(1:height(tempTable))';

                tempTableCellArray{end+1} = tempTable;
            end

            tbl = vertcat(tempTableCellArray{:});
        end

        %-----------------------------------------------------------------%
        function tbl = BandEmissions(reportInfo, analyzedData)
            specData = analyzedData.InfoSet;
            bandIdx = reportInfo.Function.var_Index;

            tbl = util.createEmissionsTable(specData, 1, 'REPORT: HTMLFile');
            tbl.ID = string(bandIdx) + "." + string(1:height(tbl))';
        end

        %-----------------------------------------------------------------%
        function tbl = EmissionPoints(reportInfo, analyzedData)
            specData = analyzedData.InfoSet;
            emissionIdx = reportInfo.Function.var_IndexEmission;
            pointsTable = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest.Points;

            tbl = table( ...
                'Size', [height(pointsTable), 3], ...
                'VariableTypes', {'cell', 'cell', 'cell'}, ...
                'VariableNames', {'Type', 'Source', 'Data'} ...
            );

            for ii = 1:height(pointsTable)
                tbl(ii, :) = { ...
                    pointsTable.type{ii}, ...
                    pointsTable.value(ii).source, ...
                    jsonencode(pointsTable.value(ii).data) ...
                };
            end
        end


        %-----------------------------------------------------------------%
        % CANAIS
        % (recorrente, uma tabela por faixa sob análise)
        %-----------------------------------------------------------------&
        function tbl = Channel(analyzedData)
            % ...
        end

        %-----------------------------------------------------------------%
        function tbl = ChannelEmissions(analyzedData)
            % ...
        end


        %-----------------------------------------------------------------%
        % SUMARIZAÇÃO DA CLASSIFICAÇÃO DE TODAS AS EMISSÕES
        % (única, engloba todas as emissões)
        %-----------------------------------------------------------------&
        function varargout = GlobalEmissionSummary(specData, requestedOutput, outputFinality)
            arguments
                specData
                requestedOutput char {mustBeMember(requestedOutput, {'EditedEmissionsTable', 'Summary', 'EditedEmissionsTable+Summary', 'Irregular'})} = 'Summary'
                outputFinality  char {mustBeMember(outputFinality,  {'SIGNALANALYSIS: GUI', 'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile', 'REPORT: HTMLFile'})} = 'REPORT: HTMLFile'
            end
        
            varargout = {};
            emissionsTable = util.createEmissionsTable(specData, 1:numel(specData), outputFinality);
        
            % Itera em relação às faixas de frequências monitoradas, montando tabela que 
            % pode ser renderizada no Relatório de Monitoração ou no "journal" (ou histórico) 
            % da ação de inspeção no Fiscaliza.
            if contains(requestedOutput, 'Summary')
                globalTable = table( ...
                    'Size', [0, 22], ...
                    'VariableTypes', {'cell',   'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16'}, ...
                    'VariableNames', {'Banda', 'N1_Licenciada', 'N1_NaoLicenciada', 'N1_NaoLicenciavel', 'N2_Fundamental', 'N2_Harmonico', 'N2_Produto', 'N2_Espuria', 'N2_NaoIdentificada', 'N2_NaoManifestada', 'N2_Pendente', 'N3_Licenciada', 'N3_NaoLicenciada', 'N3_NaoLicenciavel', 'N4_Baixo', 'N4_Medio', 'N4_Alto', 'N5_Radcom', 'N5_ClasseC', 'N5_ClasseB', 'N5_ClasseA', 'N5_ClasseE'} ...
                );        
        
                bands = unique(emissionsTable.Band, 'stable');
        
                for band = bands'
                    tagIdx = strcmp(emissionsTable.Band, band);
            
                    N1_Licenciada      = sum(tagIdx & ismember(emissionsTable.Regulatory, {'Licenciada', 'Licenciada UTE'})); % 'Licenciada' | 'Licenciada UTE'
                    N1_NaoLicenciada   = sum(tagIdx &  strcmpi(emissionsTable.Regulatory, 'Não licenciada'));
                    N1_NaoLicenciavel  = sum(tagIdx & contains(emissionsTable.Regulatory, 'Não passível', 'IgnoreCase', true));
            
                    N2_Fundamental     = sum(tagIdx &  strcmpi(emissionsTable.Type,       'Fundamental'));
                    N2_Harmonico       = sum(tagIdx &  strcmpi(emissionsTable.Type,       'Harmônico de fundamental'));
                    N2_Produto         = sum(tagIdx &  strcmpi(emissionsTable.Type,       'Produto de intermodulação'));
                    N2_Espuria         = sum(tagIdx &  strcmpi(emissionsTable.Type,       'Espúrio'));
                    N2_NaoIdentificada = sum(tagIdx &  strcmpi(emissionsTable.Type,       'Não identificado'));
                    N2_NaoManifestada  = sum(tagIdx &  strcmpi(emissionsTable.Type,       'Não se manifestou'));
                    N2_Pendente        = sum(tagIdx & contains(emissionsTable.Type,       'Pendente', 'IgnoreCase', true));
            
                    N3_Licenciada      = sum(tagIdx & ismember(emissionsTable.Regulatory, {'Licenciada', 'Licenciada UTE'})   & strcmpi(emissionsTable.Irregular, 'Sim'));
                    N3_NaoLicenciada   = sum(tagIdx &  strcmpi(emissionsTable.Regulatory, 'Não licenciada')                   & strcmpi(emissionsTable.Irregular, 'Sim'));
                    N3_NaoLicenciavel  = sum(tagIdx & contains(emissionsTable.Regulatory, 'Não passível', 'IgnoreCase', true) & strcmpi(emissionsTable.Irregular, 'Sim'));
                    
                    N4_Baixo           = sum(tagIdx &  strcmpi(emissionsTable.RiskLevel,  'Baixo'));
                    N4_Medio           = sum(tagIdx &  strcmpi(emissionsTable.RiskLevel,  'Médio'));
                    N4_Alto            = sum(tagIdx &  strcmpi(emissionsTable.RiskLevel,  'Alto'));
            
                    N5_Radcom          = sum(tagIdx & (emissionsTable.Service == 231));
                    N5_ClasseC         = sum(tagIdx & (emissionsTable.RFDataHubSource == "MOSAICO-SRD") & (emissionsTable.RFDataHubClass == "C"));
                    N5_ClasseB         = sum(tagIdx & (emissionsTable.RFDataHubSource == "MOSAICO-SRD") & ismember(emissionsTable.RFDataHubClass, ["B", "B1", "B2"]));
                    N5_ClasseA         = sum(tagIdx & (emissionsTable.RFDataHubSource == "MOSAICO-SRD") & ismember(emissionsTable.RFDataHubClass, ["A", "A1", "A2", "A3", "A4"]));
                    N5_ClasseE         = sum(tagIdx & (emissionsTable.RFDataHubSource == "MOSAICO-SRD") & ismember(emissionsTable.RFDataHubClass, ["E", "E1", "E2", "E3"]));
                    
                    globalTable(end+1, :) = {band, N1_Licenciada, N1_NaoLicenciada, N1_NaoLicenciavel,                                                       ...
                                                         N2_Fundamental, N2_Harmonico, N2_Produto, N2_Espuria, N2_NaoIdentificada, N2_NaoManifestada, N2_Pendente, ...
                                                         N3_Licenciada, N3_NaoLicenciada, N3_NaoLicenciavel,                                                       ...
                                                         N4_Baixo, N4_Medio, N4_Alto,                                                                              ...
                                                         N5_Radcom, N5_ClasseC, N5_ClasseB, N5_ClasseA, N5_ClasseE};
                end
            end
        
            if contains(requestedOutput, 'Irregular')
                irregularIndex = strcmpi(emissionsTable.Irregular, 'Sim');
                irregularTable = emissionsTable(irregularIndex, {'Frequency', 'Truncated', 'BandWidthkHz', 'MergedDescriptions', 'Regulatory', 'Type', 'RiskLevel'});
            end        
        
            % Saída:
            requestedOutput = strsplit(requestedOutput, '+');
            for jj = 1:numel(requestedOutput)
                switch requestedOutput{jj}
                    case 'Summary'
                        varargout = [varargout, {globalTable}];
                    case 'EditedEmissionsTable'
                        varargout = [varargout, {emissionsTable}];
                    case 'Irregular'
                        varargout = [varargout, {irregularTable}];
                end
            end
        end


        %-----------------------------------------------------------------%
        % CUSTOMIZÁVEL
        % (orientada à reportLibConnection.Variables.ClassProperty)
        %-----------------------------------------------------------------%
        function tbl = CustomClassPropertyTable(reportInfo, tableSettings)
            specData = reportInfo.Object;

            variableCount = numel(tableSettings.Settings);
            variableNames = tableSettings.Columns;
            variableTypes = {};

            for ii = 1:variableCount
                variablePrecision = regexp(tableSettings.Settings(ii).Precision, '\w*%(s|d|.[013]f)\w*', 'match', 'once');
                switch variablePrecision
                    case '%s'
                        variableTypes(end+1) = {'cell'};
                    case '%d'
                        variableTypes(end+1) = {'int64'};
                    case {'%.0f', '%.1f', '%.3f'}
                        variableTypes(end+1) = {'double'};
                    otherwise
                        error('reportLibConnection:Table:UnexpectedFormat', 'Unexpected format %s', variablePrecision)
                end
            end

            tbl = table( ...
                'Size', [numel(specData), variableCount], ...
                'VariableTypes', variableTypes,  ...
                'VariableNames', variableNames ...
            );

            ll = 0;
            for jj = 1:numel(specData)
                if ismember(specData(jj).MetaData.DataType, class.Constants.specDataTypes)
                    ll = ll+1;

                    for kk = 1:variableCount
                        fieldName = variableNames{kk};
                        switch fieldName
                            case 'ID'
                                tbl{ll, kk} = ll;
                            otherwise
                                tbl(ll, kk) = {reportLibConnection.Variable.ClassProperty(reportInfo, specData(jj), fieldName)};
                        end
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        % TABELAS PARA SHAREPOINT (SCARAB)
        %-----------------------------------------------------------------%
        function jsonFileContent = scarabJsonFile(projectData, context, specData, correlationKey, executionMode, issueDetails)
            jsonFileContent = struct( ...
                'schemaVersion', 1, ...
                'clientName', class.Constants.appName, ...
                'clientVersion', class.Constants.appVersion, ...
                'clientExecutionMode', executionMode, ...
                'auditorName', issueDetails.usuario.nome, ...
                'auditorEmail', issueDetails.usuario.email, ...
                'auditorDepartment', issueDetails.usuario.unidade, ...
                'auditorJobTitle', issueDetails.usuario.funcao, ...
                'project', struct( ...
                    'correlationKey', correlationKey, ...
                    'system', projectData.modules.(context).ui.system, ...
                    'unit', projectData.modules.(context).ui.unit, ...
                    'issue', projectData.modules.(context).ui.issue, ...
                    'macroTheme', issueDetails.issueContext.solicitacao.classificacao.macrotema, ...
                    'sei', issueDetails.issueContext.acao.sei.processo, ...
                    'entityGroupName', projectData.modules.(context).ui.entity.name, ...
                    'entityGroupId', projectData.modules.(context).ui.entity.id ...
                ), ...
                'tasks', [], ...
                'emissions', [] ...
            );

            % TASKS / EMISSIONS
            tasks = table( ...
                'Size', [numel(specData), 13], ...
                'VariableNames', {'correlationKey', 'bandId', 'sensor', 'latitude', 'longitude', 'freqStart', 'freqStop', 'measurementStartTime', 'measurementEndTime', 'measurementCount', 'taskType', 'taskDescription', 'relatedFiles'}, ...
                'VariableTypes', {'cell', 'double', 'cell', 'double', 'double', 'double', 'double', 'cell', 'cell', 'double', 'cell', 'cell', 'cell'} ...
            );

            globalEmissions = [];

            for ii = 1:numel(specData)
                tasks(ii, :) = { ...
                    correlationKey, ...
                    ii, ...
                    specData(ii).Receiver, ...
                    specData(ii).GPS.Latitude, ...
                    specData(ii).GPS.Longitude, ...
                    round(specData(ii).MetaData.FreqStart / 1e+6, 3), ...
                    round(specData(ii).MetaData.FreqStop  / 1e+6, 3), ...
                    datestr(specData(ii).Data{1}(1),   'yyyymmdd HH:MM:SS'), ...
                    datestr(specData(ii).Data{1}(end), 'yyyymmdd HH:MM:SS'), ...
                    numel(specData(ii).Data{1}), ...
                    gpsLib.classifyMonitoringType(specData(ii).GPS), ...
                    specData(ii).RelatedFiles.Description{1}, ...
                    strjoin(unique(specData(ii).RelatedFiles.File), ', ') ...
                };

                emissions = table( ...
                    'Size', [0, 23], ...
                    'VariableNames', { ...
                        'correlationKey', 'bandId', 'freqCenter', 'channelFrequency', 'bandWidthkHz', ...
                        'levelMin', 'levelAvg', 'levelMax', ...
                        'fcoIntegrationPeriod', 'fcoMin', 'fcoAvg', 'fcoMax', ... % FCO
                        'fboMin', 'fboAvg', 'fboMax', ... % FBO
                        'emissionType', 'regulatory', 'service', 'station', 'description', 'distance', 'irregular', 'riskLevel' ...
                    }, ...
                    'VariableTypes', { ...
                        'cell', 'double', 'double', 'double', 'double', ...
                        'double', 'double', 'double', ...
                        'double', 'double', 'double', 'double', ...
                        'double', 'double', 'double', ...
                        'cell', 'cell', 'int16', 'int32', 'cell', 'double', 'cell', 'cell' ...
                    } ...
                );

                for jj = 1:height(specData(ii).UserData.Emissions)
                    emissionDescription = specData(ii).UserData.Emissions.Classification(jj).UserModified.Description;
                    emissionFreeDescription = specData(ii).UserData.Emissions.Description(jj);
                    if isstring(emissionFreeDescription) && emissionFreeDescription.strlength
                        emissionDescription = sprintf('%s (%s)', emissionDescription, emissionFreeDescription);
                    end

                    emissions(end+1, :) = { ...
                        correlationKey, ...
                        ii, ...
                        specData(ii).UserData.Emissions.Frequency(jj), ...
                        specData(ii).UserData.Emissions.ChannelAssigned(jj).UserModified.Frequency, ...
                        specData(ii).UserData.Emissions.BandWidthkHz(jj), ...
                        specData(ii).UserData.Emissions.Measures(jj).Level.FreqCenter_Min, ...
                        specData(ii).UserData.Emissions.Measures(jj).Level.FreqCenter_Mean, ...
                        specData(ii).UserData.Emissions.Measures(jj).Level.FreqCenter_Max, ...
                        specData(ii).UserData.Emissions.Measures(jj).FCO.IntegrationPeriod, ...
                        specData(ii).UserData.Emissions.Measures(jj).FCO.FreqCenter_Finite_Min, ...
                        specData(ii).UserData.Emissions.Measures(jj).FCO.FreqCenter_Finite_Mean, ...
                        specData(ii).UserData.Emissions.Measures(jj).FCO.FreqCenter_Finite_Max, ...
                        specData(ii).UserData.Emissions.Measures(jj).FBO.Min, ...
                        specData(ii).UserData.Emissions.Measures(jj).FBO.Mean, ...
                        specData(ii).UserData.Emissions.Measures(jj).FBO.Max, ...
                        specData(ii).UserData.Emissions.Classification(jj).UserModified.EmissionType, ...
                        specData(ii).UserData.Emissions.Classification(jj).UserModified.Regulatory, ...
                        specData(ii).UserData.Emissions.Classification(jj).UserModified.Service, ...
                        specData(ii).UserData.Emissions.Classification(jj).UserModified.Station, ...
                        emissionDescription, ...
                        round(specData(ii).UserData.Emissions.Classification(jj).UserModified.Distance, 1), ...
                        specData(ii).UserData.Emissions.Classification(jj).UserModified.Irregular, ...
                        specData(ii).UserData.Emissions.Classification(jj).UserModified.RiskLevel ...
                    };
                end

                globalEmissions = [globalEmissions; emissions];
            end

            % Força arredondamento de valores numéricos, evitando que no
            % JSON apareça algo como "79.4000015258789", por exemplo.
            globalEmissions(:, {'freqCenter', 'channelFrequency'}) = round(globalEmissions(:, {'freqCenter', 'channelFrequency'}), 3);
            globalEmissions(:, {'bandWidthkHz', 'levelMin', 'levelAvg', 'levelMax', 'fcoIntegrationPeriod', 'fcoMin', 'fcoAvg', 'fcoMax', 'fboMin', 'fboAvg', 'fboMax'}) = round(globalEmissions(:, {'bandWidthkHz', 'levelMin', 'levelAvg', 'levelMax', 'fcoIntegrationPeriod', 'fcoMin', 'fcoAvg', 'fcoMax', 'fboMin', 'fboAvg', 'fboMax'}), 1);

            jsonFileContent.tasks = tasks;
            jsonFileContent.emissions = globalEmissions;

            jsonFileContent = jsonencode(jsonFileContent, 'PrettyPrint', true, 'ConvertInfAndNaN', false);
        end

        %-----------------------------------------------------------------%
        function teamsFileContent = scarabTeamsFileContent(projectData, context, specData, issueDetails, sharepointFileList)
            auditorAnalysis = reportLibConnection.Table.summarizeAuditorAnalysis(specData, issueDetails);
            teamsFileContent = struct( ...
                'schemaVersion', 1, ...
                'clientName', class.Constants.appName, ...
                'auditorName', issueDetails.usuario.nome, ...
                'auditorEmail', issueDetails.usuario.email, ...
                'auditorAnalysis', auditorAnalysis, ...
                'project', struct( ...
                    'system', projectData.modules.(context).ui.system, ...
                    'unit', projectData.modules.(context).ui.unit, ...
                    'issue', projectData.modules.(context).ui.issue, ...
                    'macroTheme', issueDetails.issueContext.solicitacao.classificacao.macrotema, ...
                    'sei', issueDetails.issueContext.acao.sei.processo ...
                ), ...
                'fileNameList', {sharepointFileList} ...
            );

            teamsFileContent = jsonencode(teamsFileContent, 'PrettyPrint', true);
        end

        %-----------------------------------------------------------------%
        function auditorAnalysis = summarizeAuditorAnalysis(specData, issueDetails)
            emissionsTable = util.createEmissionsTable(specData, 1:numel(specData), 'REPORT: HTMLFile');

            hasIrregularities = any(ismember(emissionsTable.RiskLevel, {'Baixo', 'Médio', 'Alto'}));
            emissionCount = height(emissionsTable);

            lowSeverityCount = sum(strcmp(emissionsTable.RiskLevel, 'Baixo'));
            mediumSeverityCount = sum(strcmp(emissionsTable.RiskLevel, 'Médio'));
            highSeverityCount = sum(strcmp(emissionsTable.RiskLevel, 'Alto'));

            macroTheme = issueDetails.issueContext.solicitacao.classificacao.macrotema;
            centralizerName = sprintf('Centralizador %s', macroTheme);
            
            if highSeverityCount
                highestSeverity = 'High';
                notificationRecipients = {'Auditor', centralizerName, 'FIGF'};
            elseif mediumSeverityCount
                highestSeverity = 'Medium';
                notificationRecipients = {'Auditor', centralizerName};
            elseif lowSeverityCount
                highestSeverity = 'Low';
                notificationRecipients = {'Auditor'};
            else
                highestSeverity = 'None';
                notificationRecipients = {'Auditor'};
            end

            auditorAnalysis = struct( ...
                'hasIrregularities', hasIrregularities, ...
                'notificationRecipients', {notificationRecipients}, ...
                'summary', struct( ...
                    'emissionCount', emissionCount, ...
                    'lowSeverityCount', lowSeverityCount, ...
                    'mediumSeverityCount', mediumSeverityCount, ...
                    'highSeverityCount', highSeverityCount, ...
                    'highestSeverity', highestSeverity ... % 'None' | 'Low' | 'Medium' | 'High'
                ) ...
            );
        end
    end
end