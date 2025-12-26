classdef projectLib < handle

    properties
        %-----------------------------------------------------------------%
        name (1,:) char = ''
        file (1,:) char = ''
        hash (1,:) char = ''

        report  = struct( ...
            'templates', [], ...
            'settings',  [] ...
        )

        % O "id", do "generatedFiles", é a lista ordenada de "hashs" dos fluxos 
        % relacionados aos documentos gerados.

        modules = struct( ...
            'PLAYBACK', struct('annotationTable', [], ...
                            'generatedFiles',  struct('id', '', 'rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                            'ui',              struct('system',        '',  ...
                                                      'unit',          '',  ...
                                                      'issue',         -1,  ...
                                                      'issueDetails',  [],  ...
                                                      'templates',    {{}}, ...
                                                      'reportModel',   '',  ...
                                                      'reportVersion', 'Preliminar')), ...
            'DRIVETEST', struct('annotationTable', [], ...
                            'generatedFiles',  struct('id', '', 'rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                            'ui',              struct('system',        '',  ...
                                                      'unit',          '',  ...
                                                      'issue',         -1,  ...
                                                      'issueDetails',  [],  ...
                                                      'templates',    {{}}, ...
                                                      'reportModel',   '',  ...
                                                      'reportVersion', 'Preliminar')), ...
            'SIGNALANALYSIS', struct('annotationTable', [], ...
                            'generatedFiles',  struct('id', '', 'rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                            'ui',              struct('system',        '',  ...
                                                      'unit',          '',  ...
                                                      'issue',         -1,  ...
                                                      'issueDetails',  [],  ...
                                                      'templates',    {{}}, ...
                                                      'reportModel',   '',  ...
                                                      'reportVersion', 'Preliminar')), ...
            'RFDATAHUB', struct('annotationTable', [], ...
                            'generatedFiles',  struct('id', '', 'rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                            'ui',              struct('system',        '',  ...
                                                      'unit',          '',  ...
                                                      'issue',         -1,  ...
                                                      'issueDetails',  [],  ...
                                                      'templates',    {{}}, ...
                                                      'reportModel',   '',  ...
                                                      'reportVersion', 'Preliminar')) ...
        )
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
    end


    methods
        %-----------------------------------------------------------------%
        function obj = projectLib(mainApp, rootFolder)            
            obj.mainApp    = mainApp;
            obj.rootFolder = rootFolder;

            ReadReportTemplates(obj, rootFolder)
        end

        %-----------------------------------------------------------------%
        function updateNeeded = CheckIfUpdateNeeded(obj, specDataObj)
            updateNeeded = false;
            
            if ~isempty(obj.name)
                currentPrjHash = computeProjectHash(obj, obj.name, obj.file, specDataObj);
                updateNeeded   = ~isequal(obj.hash, currentPrjHash);
            end
        end

        %-----------------------------------------------------------------%
        function Restart(obj)
            % ...

            updateGeneratedFiles(obj, 'PLAYBACK')
            updateGeneratedFiles(obj, 'DRIVETEST')
            updateGeneratedFiles(obj, 'SIGNALANALYSIS')
            updateGeneratedFiles(obj, 'RFDATAHUB')
        end

        %-----------------------------------------------------------------%
        function ReadReportTemplates(obj, rootFolder)
            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
            projectFilePath  = fullfile(projectFolder,     'ReportTemplates.json');
            externalFilePath = fullfile(programDataFolder, 'ReportTemplates.json');

            try
                if ~isdeployed()
                    error('ForceDebugMode')
                end
                obj.report.templates = jsondecode(fileread(externalFilePath));
            catch
                obj.report.templates = jsondecode(fileread(projectFilePath));
            end

            % Identifica lista de templates por módulo...
            moduleNameList   = fieldnames(obj.modules);
            templateNameList = {obj.report.templates.Name};

            for ii = 1:numel(moduleNameList)
                templateIndexes = ismember({obj.report.templates.Module}, moduleNameList(ii));
                obj.modules.(moduleNameList{ii}).ui.templates = [{''}, templateNameList(templateIndexes)];
            end
        end

        %-----------------------------------------------------------------%
        function prjHash = computeProjectHash(obj, prjName, prjFile, ecdObj)
            hashList = sort({ecdObj.Hash});

            annotationTable = [];
            for ii = 1:numel(ecdObj)
                if isfield(ecdObj(ii).Table, 'x_CONTAS_ANOTACAO') && ~isempty(ecdObj(ii).Table.x_CONTAS_ANOTACAO)
                    if isempty(annotationTable)
                        annotationTable = ecdObj(ii).Table.x_CONTAS_ANOTACAO;
                    else
                        annotationTable = [annotationTable; ecdObj(ii).Table.x_CONTAS_ANOTACAO];
                    end
                end
            end

            if ~isempty(annotationTable)
                annotationTable = sortrows(annotationTable, 'COD_CTA');
            end

            prjHash = Hash.sha1(sprintf('%s - %s - %s - %s', prjName, prjFile, strjoin(hashList, ' - '), jsonencode(annotationTable)));
        end

        %-----------------------------------------------------------------%
        function updateGeneratedFiles(obj, context, ecdObj, id, rawFiles, htmlFile, tableFile, zipFile)
            arguments
                obj
                context   (1,:) char {mustBeMember(context, {'File', 'ECD'})}
                ecdObj         = []
                id        char = ''
                rawFiles  cell = {}
                htmlFile  char = ''
                tableFile char = ''
                zipFile   char = ''
            end

            obj.modules.(context).generatedFiles.id                  = id;
            obj.modules.(context).generatedFiles.rawFiles            = rawFiles;
            obj.modules.(context).generatedFiles.lastHTMLDocFullPath = htmlFile;
            obj.modules.(context).generatedFiles.lastTableFullPath   = tableFile;
            obj.modules.(context).generatedFiles.lastZIPFullPath     = zipFile;

            if isscalar(ecdObj)
                update(ecdObj, 'GUI.GeneratedFiles', 'addFinalReportFiles', obj, context)
            end
        end

        %-----------------------------------------------------------------%
        function updateUiInfo(obj, context, fieldName, fieldValue)
            arguments
                obj
                context    (1,:) char {mustBeMember(context, {'File', 'ECD'})}
                fieldName  (1,:) char
                fieldValue
            end

            obj.modules.(context).ui.(fieldName) = fieldValue;
        end

        %-----------------------------------------------------------------%
        function filename = getGeneratedDocumentFileName(obj, fileExt, context)
            arguments
                obj
                fileExt (1,:) char {mustBeMember(fileExt, {'.html', '.json', '.zip'})}
                context (1,:) char {mustBeMember(context, {'File', 'ECD'})}
            end

            switch fileExt
                case '.html'
                    filename = obj.modules.(context).generatedFiles.lastHTMLDocFullPath;
                case '.json'
                    filename = obj.modules.(context).generatedFiles.lastTableFullPath;
                case '.zip'
                    filename = obj.modules.(context).generatedFiles.lastZIPFullPath;
            end
        end
    end
end