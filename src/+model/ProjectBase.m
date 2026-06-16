classdef (Abstract) ProjectBase

    % ## model.ProjectBase ##      
    % - *.*
    %   ├── computeProjectHash (Static)
    %   └── ...
    %       └── ...

    methods (Static = true)
        %-----------------------------------------------------------------%
        % Hash do projeto, utilizado para identificar alterações em
        % informações sensíveis durante a sessão corrente do app.
        %-----------------------------------------------------------------%
        function hash = computeProjectHash(prjName, prjFile, prjIssueDetails, prjEntityDetails, prjExternalFiles, specData)
            flowHashs = '';
            emissionUuids = '';
            
            if ~isempty(specData)
                flowHashs = strjoin(sort({specData.Hash}), ' - ');
                flowSweeps = jsonencode(arrayfun(@(x) sum(x.RelatedFiles.NumSweeps), specData));
                
                emissionUuids = arrayfun(@(x) x.UserData.Emissions.Uuid, specData, 'UniformOutput', false);
                emissionUuids = vertcat(emissionUuids{:});
                emissionUuids = strjoin(sort(emissionUuids), ' - ');
            end

            hash = Hash.sha1(sprintf('%s - %s - %s - %s - %s - %s - %s - %s', prjName, prjFile, jsonencode(prjIssueDetails), jsonencode(prjEntityDetails), jsonencode(prjExternalFiles), flowHashs, flowSweeps, emissionUuids));
        end

        %-----------------------------------------------------------------%
        function hash = computeFilterRuleHash(filterType, filterOperation, filterValue)
            hash = Hash.sha1(sprintf('%s - %s - %s', filterType, filterOperation, strjoin(string(filterValue), ' - ')));
        end

        %-----------------------------------------------------------------%
        function hash = computeReportHash(specData)
            hash = strjoin(sort({specData.Hash}), ' - ');
        end
    end
end