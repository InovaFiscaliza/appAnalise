classdef MetaData < handle

    properties
        %-----------------------------------------------------------------%
        File    char
        Type    char {mustBeMember(Type, {'Spectral data', 'Project data'})} = 'Spectral data'
        Data    model.SpecData
        Samples double
        Memory  double
    end


    methods
        %-----------------------------------------------------------------%
        function [obj, msg] = importFile(obj, fileFullPath, fileType)
            msg = '';

            try
                idx = numel(obj) + 1;

                obj(idx).File = fileFullPath;
                obj(idx).Type = fileType;
                obj(idx).Data = read(obj(idx).Data, fileFullPath, 'MetaData');
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
                            obj(ii).Data(jj).Enable = status;
                        end
                    end

                case 'specific-flow'
                    fileIdx = varargin{1};
                    flowIdx = varargin{2};
                    status  = varargin{3};

                    obj(fileIdx).Data(flowIdx).Enable = status;
            end
        end

        %-----------------------------------------------------------------%
        function relatedFiles = getRelatedFiles(obj)
            relatedFiles = {};
            for ii = 1:numel(obj)
                for jj = 1:numel(obj(ii).Data)
                    relatedFiles = [relatedFiles; obj(ii).Data(jj).RelatedFiles.File];
                end
            end
            relatedFiles = unique(relatedFiles);
        end

        %-----------------------------------------------------------------%
        function estimatedMemory = computeEstimatedMemory(obj, idx)
            estimatedMemory = 0;
            for ii = 1:numel(obj(idx).Data)
                estimatedMemory = estimatedMemory + 4 * sum(obj(idx).Data(ii).RelatedFiles.NumSweeps) .* obj(idx).Data(ii).MetaData.DataPoints; % Bytes
            end
        end

        %-----------------------------------------------------------------%
        function referenceTable = buildSpectrumReferenceTable(obj, generalSettings)
            referenceTable = table( ...
                'Size', [0, 9], ...
                'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'double', 'double', 'double', 'double', 'cell'}, ...
                'VariableNames', {'Idx', 'File', 'RelatedFiles', 'Receiver', 'FreqStart', 'FreqStop', 'Latitude', 'Longitude', 'Hash'} ...
            );

            for ii = 1:numel(obj)
                for jj = 1:numel(obj(ii).Data)
                    if ~obj(ii).Data(jj).Enable
                        continue
                    end

                    flowHashSource = model.SpecDataBase.comparableMetaData(obj(ii).Data(jj), generalSettings);
                    flowHash = Hash.sha1(jsonencode(flowHashSource));

                    referenceTable(end+1, 2:end) = { ...
                        obj(ii).File, ...
                        obj(ii).Data(jj).RelatedFiles.File, ...
                        obj(ii).Data(jj).Receiver, ...
                        obj(ii).Data(jj).MetaData.FreqStart, ...
                        obj(ii).Data(jj).MetaData.FreqStop, ...
                        obj(ii).Data(jj).GPS.Latitude, ...
                        obj(ii).Data(jj).GPS.Longitude, ...
                        flowHash ...
                    };

                    referenceTable.Idx{end} = {[ii, jj]};
                end
            end

            referenceTable = sortrows(referenceTable, {'Receiver', 'FreqStart', 'FreqStop'});
        end
    end
end