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
        function bandsIndex = FindRelatedBands(obj, specData)        
            FreqStart  = specData.MetaData.FreqStart/1e+6;
            FreqStop   = specData.MetaData.FreqStop /1e+6;

            BandLimits = [obj.Channel.Band]';        
            bandsIndex = find(((FreqStart >= BandLimits(:,1)) & (FreqStart < BandLimits(:,2))) | ...
                              ((FreqStart <= BandLimits(:,1)) & (FreqStop  > BandLimits(:,1))));
        end

        %-----------------------------------------------------------------%
        function findPeaks = FindPeaksOfPrimaryBand(obj, specData)
            findPeaks = [];

            % Concatena as canalizações - a automática, incluída automaticamente
            % pelo app a partir dos canais especificados em "ChannelLib.json", 
            % e a manual, inserida pelo fiscal no app.
            allRelatedChannels = [obj.Channel(specData.UserData.channelLibIndex); ...
                                  specData.UserData.channelManual];

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
                idx2  = find(strcmp(obj.FindPeaks.Name, allRelatedChannels(idx1).FindPeaksName), 1);
                findPeaks = obj.FindPeaks(idx2,:);
            end
        end

        %-----------------------------------------------------------------%
        function Truncated = TruncatedFrequency(obj, specData, idxEmission)

            Channels = [];
            if ~isempty(specData.UserData.channelLibIndex) && ~isempty(specData.UserData.channelManual)
                Channels = ChannelList(obj, specData, 'Lib',    Channels, idxEmission);
                Channels = ChannelList(obj, specData, 'Custom', Channels, idxEmission);

            elseif ~isempty(specData.UserData.channelLibIndex)
                Channels = ChannelList(obj, specData, 'Lib',    Channels, idxEmission);

            elseif ~isempty(specData.UserData.channelManual)
                Channels = ChannelList(obj, specData, 'Custom', Channels, idxEmission);
            end

            if isempty(Channels)
                FreqStart   = round(specData.MetaData.FreqStart ./ 1e+6, 1);  % Hz >> MHz
                FreqStop    = specData.MetaData.FreqStop  ./ 1e+6;            % Hz >> MHz
                StepWidth   = obj.DefaultChannelStep;

                Channels = FreqStart:StepWidth:FreqStop;
            end
            Channels  = unique(Channels);

            [~, idxFind] = min(abs(Channels - specData.UserData.Emissions.Frequency(idxEmission)));
            Truncated    = Channels(idxFind);
        end

        %-----------------------------------------------------------------%
        function checkIfNewChannelIsValid(obj, Name, Band, FirstChannel, LastChannel, StepWidth, ChannelBW, FreqList, Reference, FindPeaksName)
            arguments
                obj
                Name           (1,:) char   {mustBeTextScalar}
                Band           (2,1) double {mustBeFinite, mustBePositive}
                FirstChannel   (1,1) double {mustBeFinite, mustBePositive}
                LastChannel    (1,1) double {mustBeFinite, mustBePositive}
                StepWidth      (1,1) double {mustBeFinite, mustBeGreaterThanOrEqual(StepWidth, -1)}
                ChannelBW      (1,1) double {mustBeFinite, mustBeGreaterThanOrEqual(ChannelBW, -1)}
                FreqList             double
                Reference            char   {mustBeTextScalar}
                FindPeaksName  (1,:) char   {mustBeTextScalar}
            end

            if isempty(strtrim(Name))
                error('ChannelLib:checkIfNewChannelIsValid', 'O nome de um registro de canalização não pode ser vazio.')
            end
            
            if ~issorted(Band, 'strictascend')
                error('ChannelLib:checkIfNewChannelIsValid', 'Campo "Band" deve ser um vetor numérico 1x2 em que o segundo elemento é maior do que o primeiro.')
            end

            if StepWidth <= 0
                if (FirstChannel ~= LastChannel) && isempty(FreqList)
                    error('ChannelLib:checkIfNewChannelIsValid', 'Quando não é informado o espaçamento entre os canais, o campo "FreqList" deve ser um vetor numérico 1xn com a lista de frequências centrais dos canais.')
                end
            else
                if ~isempty(FreqList)
                    error('ChannelLib:checkIfNewChannelIsValid', 'Em sendo preenchido o espaçamento entre os canais, não deve ser preenchido o campo "FreqList".')
                end
            end

            refFindPeaksName = unique(obj.FindPeaks.Name);
            if ~ismember(FindPeaksName, refFindPeaksName)
                error('ChannelLib:checkIfNewChannelIsValid', 'Campo "FindPeaksName" deve ser membro da lista %s.', textFormatGUI.cellstr2ListWithQuotes(refFindPeaksName))
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
                                if ismember(idxChannel, specData(ii).UserData.channelLibIndex)
                                    error('ChannelLib:addChannel', 'Canalização já relacionada ao fluxo espectral selecionado.')
                                end
                                specData(ii).UserData.channelLibIndex = unique([specData(ii).UserData.channelLibIndex; idxChannel]);
        
                            case 'manual'
                                % As canalizações incluídas manualmente podem ser editadas - 
                                % tanto por edição direta no registro, em GUI, quanto pela
                                % inclusão de arquivo externo.
                                idxChannel = find(strcmp({specData(ii).UserData.channelManual.Name}, channels2Add(jj).Name), 1);
                                if isempty(idxChannel)
                                    specData(ii).UserData.channelManual(end+1)      = channels2Add(jj);
                                else
                                    specData(ii).UserData.channelManual(idxChannel) = channels2Add(jj);
                                end
                        end
                    end
                end

                if ~isempty(specData(ii).UserData.channelManual)
                    [~, idxSort] = sort([specData(ii).UserData.channelManual.FirstChannel]);
                    specData(ii).UserData.channelManual = specData(ii).UserData.channelManual(idxSort);
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

            for ii = specData.UserData.channelLibIndex'
                chRawInfo   = obj.Channel(ii);
                chPlotTable = PreparingData2Plot(obj, chPlotTable, chRawInfo);
            end

            for jj = 1:numel(specData.UserData.channelManual)
                chRawInfo   = specData.UserData.channelManual(jj);
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
        function Channels = ChannelList(obj, specData, truncatedType, Channels, idxEmission)
            emission_downLim = specData.UserData.Emissions.Frequency(idxEmission) - specData.UserData.Emissions.BW_kHz(idxEmission)/2000;
            emission_upLim   = specData.UserData.Emissions.Frequency(idxEmission) + specData.UserData.Emissions.BW_kHz(idxEmission)/2000;

            switch truncatedType
                case 'Lib'
                    for ii = specData.UserData.channelLibIndex'
                        if emission_downLim > obj.Channel(ii).Band(2) || emission_upLim < obj.Channel(ii).Band(1)
                            continue
                        end

                        if ~isempty(obj.Channel(ii).FreqList)
                            Channels = [Channels, obj.Channel(ii).FreqList];
    
                        else    
                            FreqStart   = obj.Channel(ii).FirstChannel;
                            FreqStop    = obj.Channel(ii).LastChannel;
                            StepWidth   = obj.Channel(ii).StepWidth;
        
                            Channels = [Channels, FreqStart:StepWidth:FreqStop];
                        end
                    end

                case 'Custom'
                    for ii = 1:height(specData.UserData.channelManual)
                        if emission_downLim > specData.UserData.channelManual(ii).Band(2) || emission_upLim < specData.UserData.channelManual(ii).Band(1)
                            continue
                        end

                        FreqStart   = specData.UserData.channelManual(ii).FirstChannel;
                        FreqStop    = specData.UserData.channelManual(ii).LastChannel;
                        StepWidth   = specData.UserData.channelManual(ii).StepWidth;
    
                        Channels = [Channels, FreqStart:StepWidth:FreqStop];
                    end
            end
        end
    end
end