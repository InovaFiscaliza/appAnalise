classdef Band < handle

    % ## model.Band (appAnalise) ##
    % PUBLIC
    %   ├── updateGeneralSettings
    %   ├── updateSpectrumInfo
    %   │   │── util.layoutTreeNodeText
    %   │   └── computeAxesLimits
    %   ├── getXYArrays️
    %   ├── idx2freq
    %   ├── freq2idx️
    %   ├── timestamp2idx
    %   └── idx2timestamp

    % PRIVATE
    %   ├── computeAxesLimits
    %   │   └── computeRoiXLimits
    %   └── computeRoiXLimits

    properties
        %-----------------------------------------------------------------%
        Context char {mustBeMember(Context, {'appAnalise:PLAYBACK',       ...
                                             'appAnalise:SIGNALANALYSIS', ...
                                             'appAnalise:DRIVETEST',      ...
                                             'appAnalise:REPORT:BAND',    ...
                                             'appAnalise:REPORT:CHANNEL', ...
                                             'appAnalise:REPORT:EMISSION'})} = 'appAnalise:PLAYBACK'
        GeneralSettings
        
        SpecData
        Receiver
        FreqStart % MHz
        FreqStop % MHz
        LevelUnit
        NumSweeps
        DataPoints
        
        XArray % MHz
%       XFreq = ACoef * XIdx + BCoef
        ACoef
        BCoef

        XLimits
        XLimitsIdxs
        YLimitsLevel
        YLimitsTime
        CLimits
    end


    methods
        %-----------------------------------------------------------------%
        function obj = Band(context, mainApp)
            obj.Context = context;
            obj.GeneralSettings = mainApp.General;
        end

        %-----------------------------------------------------------------%
        function updateGeneralSettings(obj, generalSettings)
            obj.GeneralSettings = generalSettings;
        end

        %-----------------------------------------------------------------%
        function updateSpectrumInfo(obj, specData, varargin)
            obj.SpecData = specData;

            if ~isempty(specData)
                obj.Receiver   = util.layoutTreeNodeText(obj.SpecData.Receiver, 'model.Band.updateSpectrumInfo');
                obj.FreqStart  = obj.SpecData.MetaData.FreqStart / 1e+6;
                obj.FreqStop   = obj.SpecData.MetaData.FreqStop  / 1e+6;
                obj.NumSweeps  = sum(obj.SpecData.RelatedFiles.NumSweeps);
                obj.DataPoints = obj.SpecData.MetaData.DataPoints;

                if ismember(obj.SpecData.MetaData.DataType, class.Constants.occDataTypes)
                    obj.LevelUnit = '%';
                else
                    obj.LevelUnit = obj.SpecData.MetaData.LevelUnit;
                end
                
                obj.XArray     = round(linspace(obj.FreqStart, obj.FreqStop, obj.DataPoints), class.Constants.xDecimals);
                obj.ACoef      = (obj.FreqStop - obj.FreqStart)*1e+6 ./ (obj.DataPoints - 1);
                obj.BCoef      = obj.FreqStart*1e+6 - obj.ACoef;
    
                if ismember(obj.Context, {'appAnalise:PLAYBACK', 'appAnalise:REPORT:BAND'})
                    specData = obj.SpecData;
    
                    xLimits = specData.UserData.PlotDisplayConfig.limits.frequency.current;
                    yLimitsLevel = specData.UserData.PlotDisplayConfig.limits.level.current;
                    cLimits = specData.UserData.PlotDisplayConfig.limits.color.current;
    
                    if ~isempty(xLimits) && ~isempty(yLimitsLevel) && ~isempty(cLimits) && issorted(xLimits, 'strictascend') && issorted(yLimitsLevel, 'strictascend') && issorted(cLimits, 'strictascend')
                        xLimitsIdxs = freq2idx(obj, xLimits * 1e+6);
    
                        yLimitsTime = [specData.Data{1}(1), specData.Data{1}(end)];
                        if yLimitsTime(1) == yLimitsTime(end)
                            yLimitsTime(2) = yLimitsTime(2) + seconds(1);
                        end
    
                        % Atualiza propriedades...
                        obj.XLimits = xLimits;
                        obj.XLimitsIdxs = xLimitsIdxs;
                        obj.YLimitsLevel = yLimitsLevel;
                        obj.YLimitsTime = yLimitsTime;
                        obj.CLimits = cLimits;
    
                        return
                    end
                end
    
                computeAxesLimits(obj, varargin{:})

            else
                propList = setdiff(properties(obj), {'Context', 'GeneralSettings', 'SpecData'});
                for ii = 1:numel(propList)
                    obj.(propList{ii}) = [];
                end
            end
        end

        %-----------------------------------------------------------------%
        function [xArray, yArray] = getXYArrays(obj, plotTag, varargin)
            arguments
                obj
                plotTag {mustBeMember(plotTag, {'clearWrite', 'minHold', 'average', 'maxHold', 'waterfallTime'})}
            end

            arguments (Repeating)
                varargin
            end

            specData = obj.SpecData;

            sweepTimeIdx = [];
            if ismember(obj.Context, {'appAnalise:PLAYBACK', 'appAnalise:DRIVETEST'})
                sweepTimeIdx = varargin{1};
            end

            switch plotTag
                case 'clearWrite'
                    xArray = obj.XArray;
                    yArray = specData.Data{2}(:, sweepTimeIdx)';

                case {'minHold', 'average', 'maxHold'}
                    xArray = obj.XArray;

                    switch plotTag
                        case 'minHold'; fcnIdx = 1;
                        case 'average'; fcnIdx = 2;
                        case 'maxHold'; fcnIdx = 3;
                    end
        
                    switch obj.Context
                        case 'appAnalise:PLAYBACK'
                            if ismember(plotTag, {'minHold', 'average', 'maxHold'}) && isinf(obj.GeneralSettings.context.PLAYBACK.integration.traceMode)
                                yArray  = specData.Data{3}(:, fcnIdx)';        
                            else
                                yArray  = specData.Data{2}(:, sweepTimeIdx)';
                            end
        
                        otherwise
                            yArray = specData.Data{3}(:, fcnIdx)';
                    end

                case 'waterfallTime'
                    xArray = [obj.XArray(1), obj.XArray(end)];
                    yAxisClass = varargin{2};
                    
                    switch yAxisClass
                        case 'matlab.graphics.axis.decorator.DatetimeRuler'
                            yArray = [specData.Data{1}(sweepTimeIdx), specData.Data{1}(sweepTimeIdx)];

                        otherwise
                            yArray = [sweepTimeIdx, sweepTimeIdx];
                    end
            end
        end

        %-----------------------------------------------------------------%
        function frequencyInHertz = idx2freq(obj, idx)
            frequencyInHertz = obj.ACoef * idx + obj.BCoef;
        end

        %-----------------------------------------------------------------%
        function [idx, invalidIndex] = freq2idx(obj, frequencyInHertz, validationType, roundType)
            arguments
                obj
                frequencyInHertz
                validationType {mustBeMember(validationType, {'CheckAndRound', 'OnlyCheck'})} = 'CheckAndRound'
                roundType      {mustBeMember(roundType,      {'round', 'fix', 'ceil'})} = 'round'
            end

            idx = (frequencyInHertz - obj.BCoef) / obj.ACoef;
            switch roundType
                case 'round'; idx = round(idx);
                case 'fix';   idx = fix(idx);
                case 'ceil';  idx = ceil(idx);
            end

            invalidIndex = (idx < 1) | (idx > obj.DataPoints);

            if validationType == "CheckAndRound"
                idx(idx < 1) = 1;
                idx(idx > obj.DataPoints) = obj.DataPoints;
            end
        end

        %-----------------------------------------------------------------%
        function idx = timestamp2idx(obj, timestamp)
            [~, idx] = min(abs(obj.SpecData.Data{1} - timestamp));
        end

        %-----------------------------------------------------------------%
        function timestamp = idx2timestamp(obj, sweepTimeIdx)
            timestamp = obj.SpecData.Data{1}(sweepTimeIdx);
        end
    end

    methods(Access = private)
        %-----------------------------------------------------------------%
        function computeAxesLimits(obj, varargin)
            specData = obj.SpecData;

            % xLimits
            switch obj.Context
                case {'appAnalise:PLAYBACK', 'appAnalise:REPORT:BAND'}
                    xLimits = [obj.FreqStart, obj.FreqStop];
                    xLimitDownIdx = 1;
                    xLimitUpIdx = obj.DataPoints;

                case 'appAnalise:REPORT:CHANNEL'
                    channelIdx = varargin{1};
                    channelFreqCenter = specData.UserData.ReportChannels.FirstChannel(channelIdx); % MHz
                    channelBandWidth  = specData.UserData.ReportChannels.ChannelBW(channelIdx);    % MHz

                    if channelBandWidth <= 0
                        guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', 1000)); % Value em kHz
                    else
                        guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', ceil(1.1*channelBandWidth)));
                    end

                    [xLimits, xLimitDownIdx, xLimitUpIdx] = computeRoiXLimits(obj, channelFreqCenter, channelBandWidth, guardBand);

                case {'appAnalise:REPORT:EMISSION', 'appAnalise:SIGNALANALYSIS'}
                    emissionIdx = varargin{1};
                    emissionFreqCenter = specData.UserData.Emissions.Frequency(emissionIdx);       % MHz
                    emissionBandWidth  = specData.UserData.Emissions.BandWidthkHz(emissionIdx) / 1000;   % kHz >> MHz

                    if emissionBandWidth <= 0
                        guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed',     'Value', 1000)); % Value em kHz
                    else
                        guardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'BWRelated', 'Value', 5));
                    end

                    [xLimits, xLimitDownIdx, xLimitUpIdx] = computeRoiXLimits(obj, emissionFreqCenter, emissionBandWidth, guardBand);

                case 'appAnalise:DRIVETEST'
                    emissionIdx = varargin{1};
                    guardBand = varargin{2};

                    if isempty(emissionIdx)
                        guardBand.Parameters.Value = 1;
                        channelFreqCenter = (specData.MetaData.FreqStart + specData.MetaData.FreqStop) / 2e+6; % MHz
                        channelBandWidth  = (specData.MetaData.FreqStop - specData.MetaData.FreqStart) / 1e+6; % MHz
                    else
                        channelFreqCenter = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.Frequency; % MHz
                        channelBandWidth  = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW / 1000; % kHz >> MHz
                    end

                    [xLimits, xLimitDownIdx, xLimitUpIdx] = computeRoiXLimits(obj, channelFreqCenter, channelBandWidth, guardBand);

                otherwise
                    error('class:Band:UnexpectedContext', 'Unexpected context "%s"', obj.Context)
            end
        
            % yLimits+cLimits
            dataType = specData.MetaData.DataType;

            if ismember(dataType, class.Constants.specDataTypes)
                minArray = sort(specData.Data{3}(xLimitDownIdx:xLimitUpIdx, 1));
                maxArray = sort(specData.Data{3}(xLimitDownIdx:xLimitUpIdx, 3), 'descend');

                nSamples = ceil(.01*numel(minArray));
                minValue = median(minArray(1:nSamples));
                maxValue = median(maxArray(1:nSamples));

                yLimitDown = minValue - mod(minValue, 5);
                yLimitUp = maxValue - mod(maxValue, 10) + 10;

                cLimitDown = RF.noiseEstimation(specData, xLimitDownIdx, xLimitUpIdx, .05, .15, 3);
                cLimitUp   = yLimitUp - 10;
                cLimitDown = max(cLimitDown, cLimitUp-30);

                cLimitRange = cLimitUp-cLimitDown;
                if cLimitRange < 15
                    cLimitDown = cLimitDown - (15-cLimitRange)/2;
                    cLimitUp   = cLimitUp   + (15-cLimitRange)/2;
                end

            elseif ismember(dataType, class.Constants.occDataTypes)
                yLimitDown = 0;
                yLimitUp = 100;

                cLimitDown = 0;
                cLimitUp = 1;

            else
                error('class:Band:UnexpectedDataType', 'Unexpected data type "%"', dataType)
            end

            yLimitsLevel = [yLimitDown, yLimitUp];        
            if diff(yLimitsLevel) > class.Constants.yMaxLimRange
                yLimitsLevel(1) = yLimitsLevel(1) + diff(yLimitsLevel) - class.Constants.yMaxLimRange;
            end

            yLimitsTime = [specData.Data{1}(1), specData.Data{1}(end)];
            if yLimitsTime(1) == yLimitsTime(end)
                yLimitsTime(2) = yLimitsTime(2) + seconds(1);
            end

            % Atualiza propriedades...
            obj.XLimits = xLimits;
            obj.XLimitsIdxs = [xLimitDownIdx, xLimitUpIdx];
            obj.YLimitsLevel = double(yLimitsLevel);
            obj.YLimitsTime = yLimitsTime;
            obj.CLimits = double([cLimitDown, cLimitUp]);

            if ismember(obj.Context, {'appAnalise:PLAYBACK', 'appAnalise:REPORT:BAND'})
                update(specData, 'UserData:PlotDisplayConfig', 'limitsXYCStartup', obj)
            end
        end

        %-----------------------------------------------------------------%
        function [xLimits, xDownIdx, xUpIdx] = computeRoiXLimits(obj, freqCenter, bandWidth, bandGuard)
            switch bandGuard.Mode
                case 'auto'
                    screenFreqStart = freqCenter - bandWidth / 2;
                    screenFreqStop  = freqCenter + bandWidth / 2;
        
                case 'manual'
                    switch bandGuard.Parameters.Type
                        case 'Fixed'
                            screenFreqStart = freqCenter - bandGuard.Parameters.Value / 2000;
                            screenFreqStop  = freqCenter + bandGuard.Parameters.Value / 2000;
        
                        case 'BWRelated'
                            screenFreqStart = freqCenter - bandGuard.Parameters.Value * bandWidth / 2;
                            screenFreqStop  = freqCenter + bandGuard.Parameters.Value * bandWidth / 2;
                    end
            end
    
            xDownIdx = freq2idx(obj, screenFreqStart * 1e+6, 'CheckAndRound', 'fix');
            xUpIdx   = freq2idx(obj, screenFreqStop  * 1e+6, 'CheckAndRound', 'ceil');
            xLimits  = [screenFreqStart, screenFreqStop];
        end
    end
end