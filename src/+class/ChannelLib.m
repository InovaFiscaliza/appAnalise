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
        function addChannel(obj, typeOfChannel, specData, idxThreads, channels2Add)
            for ii = idxThreads
                FreqStart = specData(ii).MetaData.FreqStart / 1e+6;
                FreqStop  = specData(ii).MetaData.FreqStop  / 1e+6;

                for jj = 1:numel(channels2Add)
                    BandLimits = channels2Add(jj).Band;

                    if ((FreqStart >= BandLimits(1)) && (FreqStart < BandLimits(2))) || ...
                       ((FreqStart <= BandLimits(1)) && (FreqStop > BandLimits(1)))
                        switch typeOfChannel
                            case 'channelLib'
                                idxChannel = find(strcmp({obj.Channel.Name}, channels2Add(jj).Name), 1);
                                if ismember(idxChannel, specData(ii).UserData.ChannelLibraryRelatedIndexes)
                                    error('ChannelLib:addChannel', 'Canalização já relacionada ao fluxo espectral selecionado.')
                                end
                                specData(ii).UserData.ChannelLibraryRelatedIndexes = unique([specData(ii).UserData.ChannelLibraryRelatedIndexes; idxChannel]);
        
                            case 'manual'
                                % As canalizações incluídas manualmente podem ser editadas - 
                                % tanto por edição direta no registro, em GUI, quanto pela
                                % inclusão de arquivo externo.
                                idxChannel = find(strcmp({specData(ii).UserData.ChannelUserDefined.Name}, channels2Add(jj).Name), 1);
                                if isempty(idxChannel)
                                    specData(ii).UserData.ChannelUserDefined(end+1)      = channels2Add(jj);
                                else
                                    specData(ii).UserData.ChannelUserDefined(idxChannel) = channels2Add(jj);
                                end
                        end
                    end
                end

                if ~isempty(specData(ii).UserData.ChannelUserDefined)
                    [~, idxSort] = sort([specData(ii).UserData.ChannelUserDefined.FirstChannel]);
                    specData(ii).UserData.ChannelUserDefined = specData(ii).UserData.ChannelUserDefined(idxSort);
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
        function chPlotTable = PreparingData2Plot(obj, chPlotTable, chRawInfo)
            if ~isempty(chRawInfo)
                channelBW = chRawInfo.ChannelBW; % MHz
                if channelBW <= 0
                    return
                end
    
                if ~isempty(chRawInfo.FreqList)
                    FreqList = chRawInfo.FreqList;
                else
                    FreqList = (chRawInfo.FirstChannel:chRawInfo.StepWidth:chRawInfo.LastChannel)';
                end

                chName      = repmat({chRawInfo.Name},      numel(FreqList), 1);
                chBW        = repmat(channelBW,             numel(FreqList), 1);
                chReference = repmat({chRawInfo.Reference}, numel(FreqList), 1);
                chPlotTable = [chPlotTable; table(chName, FreqList, chBW, chReference, FreqList-channelBW/2, FreqList+channelBW/2, 'VariableNames', {'Name', 'FirstChannel', 'ChannelBW', 'Reference', 'FreqStart', 'FreqStop'})];
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