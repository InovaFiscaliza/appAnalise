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
        function hash = computeProjectHash(prjName, prjFile, prjModules, prjIssueDetails, prjEntityDetails, specData)
            hashList = sort({specData.Hash});

            contextList = fieldnames(prjModules);
            annotationTable = [];

            for ii = 1:numel(contextList)
                context = contextList{ii};
                annotationTable = [annotationTable; prjModules.(context).annotationTable];
            end

            if ~isempty(annotationTable)
                annotationTable = sortrows(annotationTable, 'Hash');
            end

            hash = Hash.sha1(sprintf('%s - %s - %s - %s - %s - %s', prjName, prjFile, strjoin(hashList, ' - '), jsonencode(annotationTable), jsonencode(prjIssueDetails), jsonencode(prjEntityDetails)));
        end

        %-----------------------------------------------------------------%
        function hash = computeFilterRuleHash(filterType, filterOperation, filterValue)
            hash = Hash.sha1(sprintf('%s - %s - %s', filterType, filterOperation, strjoin(string(filterValue), ' - ')));
        end
    end
end