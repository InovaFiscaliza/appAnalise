classdef (Abstract) Table

    methods (Static)
        %-----------------------------------------------------------------%
        function Table = Algorithms(analyzedData)
            Table = table('Size', [3, 2],                    ...
                          'VariableTypes', {'cell', 'cell'}, ...
                          'VariableNames', {'Algorithm', 'Parameters'});
            
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
        
        
            Table(1,:) = {'Ocupação',                  occupancy};
            Table(2,:) = {'Detecção de emissões',      detection};
            Table(3,:) = {'Classificação de emissões', classification};
        end

        %-----------------------------------------------------------------%
        function Table = EmissionPerBand(reportInfo, analyzedData)
            specData = analyzedData.InfoSet;
            bandIdx = reportInfo.Function.var_Index;

            Table = util.createEmissionsTable(specData, 1, 'REPORT: HTMLFile');
            Table.ID = string(bandIdx) + "." + string(1:height(Table))';
        end

        %-----------------------------------------------------------------%
        function varargout = Summary(specData, requestedOutput, outputFinality)
            arguments
                specData
                requestedOutput char {mustBeMember(requestedOutput, {'EditedEmissionsTable', 'TotalSummaryTable', 'EditedEmissionsTable+TotalSummaryTable', 'IrregularTable'})} = 'TotalSummaryTable'
                outputFinality  char {mustBeMember(outputFinality,  {'SIGNALANALYSIS: GUI', 'SIGNALANALYSIS: JSONFile', 'REPORT: JSONFile', 'REPORT: HTMLFile'})}               = 'REPORT: HTMLFile'
            end
        
            varargout = {};
            emissionsTable = util.createEmissionsTable(specData, 1:numel(specData), outputFinality);
        
            % Itera em relação às faixas de frequências monitoradas, montando tabela que 
            % pode ser renderizada no Relatório de Monitoração ou no "journal" (ou histórico) 
            % da ação de inspeção no Fiscaliza.
            if contains(requestedOutput, 'TotalSummaryTable')
                TotalSummaryTable = table('Size', [0, 22],                                                                                                                                   ...
                                          'VariableTypes', {'cell',   'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16',                    ...
                                                            'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16', 'uint16'},                   ...
                                          'VariableNames', {'Banda', 'N1_Licenciada', 'N1_NaoLicenciada', 'N1_NaoLicenciavel',                                                               ...
                                                                     'N2_Fundamental', 'N2_Harmonico', 'N2_Produto', 'N2_Espuria', 'N2_NaoIdentificada', 'N2_NaoManifestada', 'N2_Pendente', ...
                                                                     'N3_Licenciada', 'N3_NaoLicenciada', 'N3_NaoLicenciavel',                                                               ...
                                                                     'N4_Baixo', 'N4_Medio', 'N4_Alto',                                                                                      ...
                                                                     'N5_Radcom', 'N5_ClasseC', 'N5_ClasseB', 'N5_ClasseA', 'N5_ClasseE'});
        
        
                Bands = unique(emissionsTable.Band, 'stable');
        
                for Band = Bands'
                    tagIdx = strcmp(emissionsTable.Band, Band);
            
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
                    
                    TotalSummaryTable(end+1, :) = {Band, N1_Licenciada, N1_NaoLicenciada, N1_NaoLicenciavel,                                                       ...
                                                         N2_Fundamental, N2_Harmonico, N2_Produto, N2_Espuria, N2_NaoIdentificada, N2_NaoManifestada, N2_Pendente, ...
                                                         N3_Licenciada, N3_NaoLicenciada, N3_NaoLicenciavel,                                                       ...
                                                         N4_Baixo, N4_Medio, N4_Alto,                                                                              ...
                                                         N5_Radcom, N5_ClasseC, N5_ClasseB, N5_ClasseA, N5_ClasseE};
                end
            end
        
            if contains(requestedOutput, 'IrregularTable')
                irregularIndex = strcmpi(emissionsTable.Irregular, 'Sim');
                irregularTable = emissionsTable(irregularIndex, {'Frequency', 'Truncated', 'BandWidthkHz', 'MergedDescriptions', 'Regulatory', 'Type', 'RiskLevel'});
            end        
        
            % Saída:
            requestedOutput = strsplit(requestedOutput, '+');
            for jj = 1:numel(requestedOutput)
                switch requestedOutput{jj}
                    case 'TotalSummaryTable'
                        varargout = [varargout, {TotalSummaryTable}];
                    case 'EditedEmissionsTable'
                        varargout = [varargout, {emissionsTable}];
                    case 'IrregularTable'
                        varargout = [varargout, {irregularTable}];
                end
            end
        end

        %-----------------------------------------------------------------%
        function Table = Custom(reportInfo, tableSettings)
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

            Table = table( ...
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
                                Table{ll, kk} = ll;

                            otherwise
                                Table(ll, kk) = {reportLibConnection.Variable.ClassProperty(reportInfo, specData(jj), fieldName)};
                        end
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        % TABELAS PARA SHAREPOINT (SCARAB)
        %-----------------------------------------------------------------%
        % function jsonFileContent = scarabJsonFile(projectData, context, correlationKey, executionMode, issueDetails, generalSettings, EMFieldObj, referenceTable)
        %     entityGroupName = projectData.modules.(context).ui.entity.name;
        %     entityGroupId = projectData.modules.(context).ui.entity.id;
        % 
        %     jsonFileContent = struct( ...
        %         'schemaVersion', 1, ...
        %         'clientName', class.Constants.appName, ...
        %         'clientVersion', class.Constants.appVersion, ...
        %         'clientExecutionMode', executionMode, ...
        %         'auditorName', issueDetails.usuario.nome, ...
        %         'auditorEmail', issueDetails.usuario.email, ...
        %         'auditorDepartment', issueDetails.usuario.unidade, ...
        %         'auditorJobTitle', issueDetails.usuario.funcao, ...
        %         'project', struct( ...
        %             'correlationKey', correlationKey, ...
        %             'system', projectData.modules.(context).ui.system, ...
        %             'issue', projectData.modules.(context).ui.issue, ...
        %             'context', context, ...
        %             'entityGroupName', entityGroupName, ...
        %             'entityGroupId', entityGroupId, ...
        %             'unit', projectData.modules.(context).ui.unit ...
        %         ), ...
        %         'rawFiles', [] ...
        %     );
        % 
        %     % RAWFILES
        %     rawFiles = table( ...
        %         'Size', [numel(EMFieldObj), 17], ...
        %         'VariableNames', {'correlationKey', 'fileName', 'sensorManufacturer', 'sensorModel', 'sensorSerialNumber', 'measurementStartTime', 'measurementEndTime', 'measurementCount', 'electricFieldMin', 'electricFieldMax', 'centralPointLat', 'centralPointLng', 'boundingBoxLatMin', 'boundingBoxLatMax', 'boundingBoxLngMin', 'boundingBoxLngMax', 'coveredDistanceKm'}, ...
        %         'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'cell', 'cell', 'cell', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'} ...
        %     );
        % 
        %     for ii = 1:numel(EMFieldObj)
        %         rawFiles(ii, :) = { ...
        %             correlationKey,                     ...
        %             EMFieldObj(ii).FileName,            ...
        %             EMFieldObj(ii).Sensor,              ...
        %             EMFieldObj(ii).MetaData.Model,      ...
        %             EMFieldObj(ii).MetaData.Serial,     ...
        %             datestr(EMFieldObj(ii).Data.Timestamp(1),   'yyyymmdd HH:MM:SS'), ...
        %             datestr(EMFieldObj(ii).Data.Timestamp(end), 'yyyymmdd HH:MM:SS'), ...
        %             EMFieldObj(ii).Measures,            ...
        %             EMFieldObj(ii).FieldValueLimits(1), ...
        %             EMFieldObj(ii).FieldValueLimits(2), ...
        %             EMFieldObj(ii).Latitude,            ...
        %             EMFieldObj(ii).Longitude,           ...
        %             EMFieldObj(ii).LatitudeLimits(1),   ...
        %             EMFieldObj(ii).LatitudeLimits(2),   ...
        %             EMFieldObj(ii).LongitudeLimits(1),  ...
        %             EMFieldObj(ii).LongitudeLimits(2),  ...
        %             EMFieldObj(ii).CoveredDistanceKm ...
        %         };
        %     end
        % 
        %     jsonFileContent.rawFiles = rawFiles;
        % 
        %     % STATIONTABLE & POINTSTABLE
        %     referenceTable = model.ProjectBase.prepareReferenceTableToExport(context, referenceTable, generalSettings);
        %     referenceTable.('correlationKey')(:) = {correlationKey};
        %     referenceTable = movevars(referenceTable, 'correlationKey', 'Before', 1);
        % 
        %     switch context
        %         case 'MONITORINGPLAN'
        %             jsonFileContent.stationTable = referenceTable;
        % 
        %         case 'EXTERNALREQUEST'
        %             jsonFileContent.pointsTable  = referenceTable;
        %     end
        % 
        %     jsonFileContent = jsonencode(jsonFileContent, 'PrettyPrint', true);
        % end
        % 
        % %-----------------------------------------------------------------%
        % function teamsFileContent = scarabTeamsFileContent(issueDetails, sharepointFileList)
        %     teamsFileContent = struct( ...
        %         'schemaVersion', 1, ...
        %         'clientName', class.Constants.appName, ...
        %         'auditorName', issueDetails.usuario.nome, ...
        %         'auditorEmail', issueDetails.usuario.email, ...
        %         'fileNameList', {sharepointFileList} ...
        %     );
        % 
        %     teamsFileContent = jsonencode(teamsFileContent, 'PrettyPrint', true);
        % end
    end
end