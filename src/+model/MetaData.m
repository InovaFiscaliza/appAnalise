classdef MetaData < handle

    properties
        %-----------------------------------------------------------------%
        File    char
        Type    char {mustBeMember(Type, {'SpectralData', 'ProjectData'})} = 'SpectralData'
        Data    model.SpecData
        Samples double
        Memory  double
    end


    methods
        %-----------------------------------------------------------------%
        function [obj, msg] = importFile(obj, fileFullPath, projectData, generalSettings)
            msg = '';

            try
                idx = numel(obj) + 1;
                obj(idx).File = fileFullPath;

                [~, ~, fileExt] = fileparts(fileFullPath);

                % O arquivo .MAT, disponível no RepoSFI, concentra informações de 
                % um ou mais arquivos .DBM em uma única variável: "out".

                % Além disso, há o .MAT que registra informações do projeto
                % nas variáveis "source", "type", "version", "variables" e
                % "userData".
                
                varsInFile = {};
                if strcmpi(fileExt, '.mat')
                    varsInFile = who('-file', fileFullPath);
                end

                if ~isempty(varsInFile) && ~contains(varsInFile, 'out')
                    [specData, fileType, msg] = load(projectData, 'PLAYBACK', fileFullPath, 'MetaData', generalSettings);
                    if ~isempty(msg)
                        error(msg)
                    end
                else
                    specData = read(obj(idx).Data, fileFullPath, 'MetaData');
                    fileType = 'SpectralData';
                end
                
                obj(idx).Type = fileType;
                obj(idx).Data = specData;
                addHashColumnToRelatedFilesTable(obj(idx).Data)
                obj(idx).Samples = computeSweepNumber(obj(idx).Data);

                if isempty(obj(idx).Samples)
                    error('model:MetaData:EmptyFile', 'Empty file')
                end
                obj(idx).Memory = computeEstimatedMemory(obj(idx).Data);

            catch ME
                [~, fileName, fileExt] = fileparts(fileFullPath);
                msg = sprintf('%s - "%s"', [fileName fileExt], ME.message);

                delete(obj(idx))
                obj(idx) = [];
                fclose('all');

                if ~isvalid(obj)
                    obj = model.MetaData.empty;
                end
            end
        end

        %-----------------------------------------------------------------%
        function isInvalid = isInvalidData(obj, fileIdx, flowIdx)
            isInvalid = ~isvalid(obj(fileIdx).Data(flowIdx));
        end

        %-----------------------------------------------------------------%
        function updateEnabledState(obj, universe, varargin)
            arguments
                obj
                universe {mustBeMember(universe, {'all-flows', 'specific-flow'})}
            end

            arguments (Repeating)
                varargin
            end

            switch universe
                case 'all-flows'
                    status = varargin{1};

                    for ii = 1:numel(obj)
                        for jj = 1:numel(obj(ii).Data)
                            if isInvalidData(obj, ii, jj)
                                continue
                            end

                            obj(ii).Data(jj).Enable = status;
                        end
                    end

                case 'specific-flow'
                    fileIdx = varargin{1};
                    flowIdx = varargin{2};
                    status  = varargin{3};

                    if isInvalidData(obj, fileIdx, flowIdx)
                        return
                    end

                    obj(fileIdx).Data(flowIdx).Enable = status;
            end
        end

        %-----------------------------------------------------------------%
        function relatedFiles = getRelatedFiles(obj)
            relatedFiles = {};
            for ii = 1:numel(obj)
                for jj = 1:numel(obj(ii).Data)
                    if isInvalidData(obj, ii, jj)
                        continue
                    end

                    relatedFiles = [relatedFiles; obj(ii).Data(jj).RelatedFiles.File];
                end
            end
            relatedFiles = unique(relatedFiles);
        end

        %-----------------------------------------------------------------%
        function estimatedMemory = computeEstimatedMemory(obj, ii)
            estimatedMemory = 0;
            for jj = 1:numel(obj(ii).Data)
                if isInvalidData(obj, ii, jj)
                    continue
                end

                estimatedMemory = estimatedMemory + 4 * sum(obj(ii).Data(jj).RelatedFiles.NumSweeps) .* obj(ii).Data(jj).MetaData.DataPoints; % Bytes
            end
        end

        %-----------------------------------------------------------------%
        function referenceTable = buildSpectrumReferenceTable(obj, generalSettings, includeDisabledFlows)
            arguments
                obj
                generalSettings
                includeDisabledFlows (1,1) logical = false
            end

            referenceTable = table( ...
                'Size', [0, 12], ...
                'VariableTypes', {'cell', 'cell', 'cell', 'double', 'cell', 'double', 'double', 'cell', 'double', 'double', 'cell', 'logical'}, ...
                'VariableNames', {'Idx', 'File', 'RelatedFiles', 'Id', 'Receiver', 'FreqStart', 'FreqStop', 'Band', 'Latitude', 'Longitude', 'Hash', 'IsOccupancyFlow'} ...
            );

            for ii = 1:numel(obj)
                for jj = 1:numel(obj(ii).Data)
                    if isInvalidData(obj, ii, jj) || (~includeDisabledFlows && ~obj(ii).Data(jj).Enable)
                        continue
                    end

                    flowHashSource = model.SpecDataBase.comparableMetaData(obj(ii).Data(jj), generalSettings);
                    flowHash = Hash.sha1(jsonencode(flowHashSource));

                    freqStart = obj(ii).Data(jj).MetaData.FreqStart;
                    freqStop  = obj(ii).Data(jj).MetaData.FreqStop;
                    bandTag   = sprintf('%.3f – %.3f MHz', freqStart / 1e+6, freqStop / 1e+6);

                    referenceTable(end+1, 2:end) = { ...
                        obj(ii).File, ...
                        obj(ii).Data(jj).RelatedFiles.File, ...
                        obj(ii).Data(jj).RelatedFiles.Id(1), ...
                        obj(ii).Data(jj).Receiver, ...
                        freqStart, ...
                        freqStop, ...
                        bandTag, ...
                        obj(ii).Data(jj).GPS.Latitude, ...
                        obj(ii).Data(jj).GPS.Longitude, ...
                        flowHash, ...
                        ismember(obj(ii).Data(jj).MetaData.DataType, class.Constants.occDataTypes) ...
                    };

                    referenceTable.Idx{end} = {[ii, jj]};
                end
            end

            referenceTable = sortrows(referenceTable, {'Receiver', 'FreqStart', 'FreqStop', 'IsOccupancyFlow'});
        end
    end
end