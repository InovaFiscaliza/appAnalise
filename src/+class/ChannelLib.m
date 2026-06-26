classdef ChannelLib < handle

    properties
        %-----------------------------------------------------------------%
        Channel
        Exception
        DefaultChannelStep
        DefaultMinBandSpan
        FindPeaks
    end


    methods
        %-----------------------------------------------------------------%
        function obj = ChannelLib(appName, rootFolder)
            if nargin < 2
                rootFolder = fileparts(fileparts(mfilename('fullpath')));
            end

            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(appName, rootFolder);
            try
                channelTempLib  = jsondecode(fileread(fullfile(programDataFolder, 'ChannelLib.json')));
            catch
                channelTempLib  = jsondecode(fileread(fullfile(projectFolder,     'ChannelLib.json')));
            end

            obj.Channel    = channelTempLib.Channel;
            obj.Exception  = struct2table(channelTempLib.Exception);
            obj.FindPeaks  = struct2table(channelTempLib.FindPeaks);

            obj.DefaultChannelStep = channelTempLib.DefaultChannelStep;
            obj.DefaultMinBandSpan = channelTempLib.DefaultMinBandSpan;
        end

        %-----------------------------------------------------------------%
        function Save(obj, appName, rootFolder)
            [~, ...
             programDataFolder] = appEngine.util.Path(appName, rootFolder);
            programDataFilePath = fullfile(programDataFolder, 'ChannelLib.json');

            try
                channelTempLib = struct(obj);
                writematrix(jsonencode(channelTempLib, 'PrettyPrint', true), programDataFilePath, "FileType", "text", "QuoteStrings", "none", "WriteMode", "overwrite")
            catch
            end
        end

        %-----------------------------------------------------------------%
        function bandsIdxs = getRelatedChannelIndexes(obj, specData)        
            freqStart  = specData.MetaData.FreqStart/1e+6;
            freqStop   = specData.MetaData.FreqStop /1e+6;

            bandLimits = [obj.Channel.Band]';        
            bandsIdxs  = find(((freqStart >= bandLimits(:,1)) & (freqStart < bandLimits(:,2))) | ...
                              ((freqStart <= bandLimits(:,1)) & (freqStop  > bandLimits(:,1))));
        end

        %-----------------------------------------------------------------%
        function findPeaks = FindPeaksOfPrimaryBand(obj, specData)
            findPeaks = [];

            % Concatena as canalizações - a automática, incluída automaticamente
            % pelo app a partir dos canais especificados em "ChannelLib.json", 
            % e a manual, inserida pelo fiscal no app.
            allRelatedChannels = [
                obj.Channel(specData.UserData.ChannelLibraryRelatedIndexes); ...
                specData.UserData.ChannelUserDefined ...
            ];

            % Identifica a canalização que apresenta maior sobreposição com
            % o fluxo espectral sob análise.
            commumSpan = [];
            for ii = 1:numel(allRelatedChannels)
                spanLim1 = max(allRelatedChannels(ii).Band(1), specData.MetaData.FreqStart/1e+6);
                spanLim2 = min(allRelatedChannels(ii).Band(2), specData.MetaData.FreqStop/1e+6);

                commumSpan(ii) = diff([spanLim1, spanLim2]);
            end
            [~, idx1] = max(commumSpan);
            
            if ~isempty(idx1)
                idx2  = find(strcmp(obj.FindPeaks.EmissionClass, allRelatedChannels(idx1).EmissionClass), 1);
                findPeaks = obj.FindPeaks(idx2,:);
            end
        end

        %-----------------------------------------------------------------%
        function channelFrequency = estimateChannelFrequency(obj, specData, emissionFrequency, emissionWidth)

            channels = [];
            channels = ChannelList(obj, channels, 'Lib',    specData, emissionFrequency, emissionWidth);
            channels = ChannelList(obj, channels, 'Custom', specData, emissionFrequency, emissionWidth);

            if isempty(channels)
                freqStart = round(specData.MetaData.FreqStart ./ 1e+6, 1);  % Hz >> MHz
                freqStop  = specData.MetaData.FreqStop  ./ 1e+6;            % Hz >> MHz
                stepWidth = obj.DefaultChannelStep;
                channels  = freqStart:stepWidth:freqStop;
            end
            
            channels = unique(channels);

            [~, channelIdx] = min(abs(channels - emissionFrequency));
            channelFrequency = channels(channelIdx);
        end

        %-------------------------------------------------------------------------%
        function channelWidth = estimateChannelWidth(obj, channelFreq, emissionWidth)
            global RFDataHub
        
            idxs = abs(RFDataHub.Frequency - channelFreq) <= 1e-5;
            widthList = RFDataHub.BW(idxs);
            widthList(isnan(widthList) | widthList<=0) = [];
            
            if isempty(widthList)
                channelWidth = emissionWidth;
            else
                [~, channelWidthIdx] = min(abs(widthList - emissionWidth));
                channelWidth = widthList(channelWidthIdx);
            end
        end

        %-----------------------------------------------------------------%
        function checkIfNewChannelIsValid(obj, name, band, firstChannel, lastChannel, stepWidth, channelBW, freqList, reference, emissionClass)
            arguments
                obj
                name           (1,:) char   {mustBeTextScalar}
                band           (2,1) double {mustBeFinite, mustBePositive}
                firstChannel   (1,1) double {mustBeFinite, mustBePositive}
                lastChannel    (1,1) double {mustBeFinite, mustBePositive}
                stepWidth      (1,1) double {mustBeFinite, mustBeGreaterThanOrEqual(stepWidth, -1)}
                channelBW      (1,1) double {mustBeFinite, mustBeGreaterThanOrEqual(channelBW, -1)}
                freqList             double
                reference            char   {mustBeTextScalar}
                emissionClass  (1,:) char   {mustBeTextScalar}
            end

            if isempty(strtrim(name))
                error('ChannelLib:checkIfNewChannelIsValid', 'O nome de um registro de canalização não pode ser vazio.')
            end
            
            if ~issorted(band, 'strictascend')
                error('ChannelLib:checkIfNewChannelIsValid', 'Campo "Band" deve ser um vetor numérico 1x2 em que o segundo elemento é maior do que o primeiro.')
            end

            if stepWidth <= 0
                if (firstChannel ~= lastChannel) && isempty(freqList)
                    error('ChannelLib:checkIfNewChannelIsValid', 'Quando não é informado o espaçamento entre os canais, o campo "FreqList" deve ser um vetor numérico 1xn com a lista de frequências centrais dos canais.')
                end
            else
                if ~isempty(freqList)
                    error('ChannelLib:checkIfNewChannelIsValid', 'Em sendo preenchido o espaçamento entre os canais, não deve ser preenchido o campo "FreqList".')
                end
            end

            refFindPeaksName = unique(obj.FindPeaks.EmissionClass);
            if ~ismember(emissionClass, refFindPeaksName)
                error('ChannelLib:checkIfNewChannelIsValid', 'Campo "EmissionClass" deve ser membro da lista %s.', textFormatGUI.cellstr2ListWithQuotes(refFindPeaksName))
            end
        end

        %-----------------------------------------------------------------%
        function addChannel(obj, typeOfChannel, specData, flowIdxs, channels2Add)
            for ii = flowIdxs
                freqStart = specData(ii).MetaData.FreqStart / 1e+6;
                freqStop  = specData(ii).MetaData.FreqStop  / 1e+6;

                for jj = 1:numel(channels2Add)
                    channelLibIndex = specData(ii).UserData.ChannelLibraryRelatedIndexes;
                    channelUserDefined = specData(ii).UserData.ChannelUserDefined;
                    channels = [obj.Channel(channelLibIndex); channelUserDefined'];
                    channelsHash = arrayfun(@(x) Hash.sha1(jsonencode(rmfield(x, {'Name', 'Reference', 'EmissionClass'}))), channels, 'UniformOutput', false);

                    newChannelLimits = channels2Add(jj).Band;

                    if ((freqStart >= newChannelLimits(1)) && (freqStart < newChannelLimits(2))) || ...
                       ((freqStart <= newChannelLimits(1)) && (freqStop > newChannelLimits(1)))

                        newChannelHash = Hash.sha1(jsonencode(rmfield(channels2Add(jj), {'Name', 'Reference', 'EmissionClass'})));
                        if ismember(newChannelHash, channelsHash)
                            continue
                        end                        

                        switch typeOfChannel
                            case 'channelLib'
                                specData(ii).UserData.ChannelLibraryRelatedIndexes = unique([specData(ii).UserData.ChannelLibraryRelatedIndexes; channelIdx]);
        
                            case 'manual'
                                % As canalizações incluídas manualmente podem ser editadas - 
                                % tanto por edição direta no registro, em GUI, quanto pela
                                % inclusão de arquivo externo.
                                channelIdx = find(strcmp({specData(ii).UserData.ChannelUserDefined.Name}, channels2Add(jj).Name), 1);
                                if isempty(channelIdx)
                                    update(specData(ii), 'UserData:Channel', 'ChannelUserDefined:Add', channels2Add(jj))
                                else
                                    update(specData(ii), 'UserData:Channel', 'ChannelUserDefined:Edit', channelIdx, channels2Add(jj))
                                end
                        end
                    end
                end

                if ~isempty(specData(ii).UserData.ChannelUserDefined)
                    [~, sortIdxs] = sort([specData(ii).UserData.ChannelUserDefined.FirstChannel]);
                    specData(ii).UserData.ChannelUserDefined = specData(ii).UserData.ChannelUserDefined(sortIdxs);
                end
            end
        end

        %-----------------------------------------------------------------%
        function channel2Add = readFileWithChannel2Add(obj, fileFullPath)
            channel2Add = jsondecode(fileread(fileFullPath));
            
            refFieldNames = fieldnames(obj.Channel);
            if ~isequal(fieldnames(channel2Add), refFieldNames)
                error('ChannelLib:openExternalFile', 'O arquivo deve ser uma estrutura com os campos %s, dispostos nesta ordem.', textFormatGUI.cellstr2ListWithQuotes(refFieldNames))
            end

            for ii = 1:numel(channel2Add)
                channelCell2Add = struct2cell(channel2Add(ii));
                checkIfNewChannelIsValid(obj, channelCell2Add{:})
            end
        end

        %-----------------------------------------------------------------%
        function chPlotTable = ChannelTable2Plot(obj, specData)
            chPlotTable = table('Size',          [0, 6],                                                                      ...
                                'VariableNames', {'Name', 'FirstChannel', 'ChannelBW', 'Reference', 'FreqStart', 'FreqStop'}, ...
                                'VariableTypes', {'cell', 'double', 'double', 'cell', 'double', 'double'});

            for ii = specData.UserData.ChannelLibraryRelatedIndexes'
                chRawInfo   = obj.Channel(ii);
                chPlotTable = PreparingData2Plot(obj, chPlotTable, chRawInfo);
            end

            for jj = 1:numel(specData.UserData.ChannelUserDefined)
                chRawInfo   = specData.UserData.ChannelUserDefined(jj);
                chPlotTable = PreparingData2Plot(obj, chPlotTable, chRawInfo);
            end

            % Elimina canais cuja frequência central estão fora dos limites
            % do fluxo espectral sob análise.
            idxLogicalFilter = (chPlotTable.FirstChannel < specData.MetaData.FreqStart/1e+6) | (chPlotTable.FirstChannel > specData.MetaData.FreqStop/1e+6);
            chPlotTable(idxLogicalFilter, :) = [];
        end

        %-----------------------------------------------------------------%
        function chPlotTable = PreparingData2Plot(~, chPlotTable, chRawInfo)
            for ii = 1:numel(chRawInfo)
                channelBW = chRawInfo(ii).ChannelBW; % MHz
                if channelBW <= 0
                    continue
                end
    
                if ~isempty(chRawInfo(ii).FreqList)
                    freqList = chRawInfo(ii).FreqList;
                else
                    freqList = (chRawInfo(ii).FirstChannel:chRawInfo(ii).StepWidth:chRawInfo(ii).LastChannel)';
                end

                chName      = repmat({chRawInfo(ii).Name},      numel(freqList), 1);
                chBandWidth = repmat(channelBW,                 numel(freqList), 1);
                chReference = repmat({chRawInfo(ii).Reference}, numel(freqList), 1);
                chPlotTable = [chPlotTable; table(chName, freqList, chBandWidth, chReference, freqList-channelBW/2, freqList+channelBW/2, 'VariableNames', {'Name', 'FirstChannel', 'ChannelBW', 'Reference', 'FreqStart', 'FreqStop'})];
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function channels = ChannelList(obj, channels, truncatedType, specData, emissionFrequency, emissionWidth)
            emissionFreqStart = emissionFrequency - emissionWidth/2;
            emissionFreqStop  = emissionFrequency + emissionWidth/2;

            switch truncatedType
                case 'Lib'
                    for ii = specData.UserData.ChannelLibraryRelatedIndexes'
                        if emissionFreqStart > obj.Channel(ii).Band(2) || emissionFreqStop < obj.Channel(ii).Band(1)
                            continue
                        end

                        if ~isempty(obj.Channel(ii).FreqList)
                            channels  = [channels, obj.Channel(ii).FreqList];
    
                        else    
                            freqStart = obj.Channel(ii).FirstChannel;
                            freqStop  = obj.Channel(ii).LastChannel;
                            stepWidth = obj.Channel(ii).StepWidth;
                            channels  = [channels, freqStart:stepWidth:freqStop];
                        end
                    end

                case 'Custom'
                    for ii = 1:height(specData.UserData.ChannelUserDefined)
                        if emissionFreqStart > specData.UserData.ChannelUserDefined(ii).Band(2) || emissionFreqStop < specData.UserData.ChannelUserDefined(ii).Band(1)
                            continue
                        end

                        freqStart = specData.UserData.ChannelUserDefined(ii).FirstChannel;
                        freqStop  = specData.UserData.ChannelUserDefined(ii).LastChannel;
                        stepWidth = specData.UserData.ChannelUserDefined(ii).StepWidth;    
                        channels  = [channels, freqStart:stepWidth:freqStop];
                    end
            end
        end
    end
end