classdef Band < handle

    properties
        %-----------------------------------------------------------------%
        Context     char {mustBeMember(Context, {'appAnalise:PLAYBACK',       ...
                                                 'appAnalise:SIGNALANALYSIS', ...
                                                 'appAnalise:DRIVETEST',      ...
                                                 'appAnalise:REPORT',         ...
                                                 'appAnalise:REPORT:BAND',    ...
                                                 'appAnalise:REPORT:CHANNEL', ...
                                                 'appAnalise:REPORT:EMISSION'})} = 'appAnalise:PLAYBACK'
        mainApp
        callingApp
        
        SpecData
        Receiver
        NumSweeps
        DataPoints
        FreqStart   % in MHz
        FreqStop    % in MHz
        LevelUnit

        xArray      % in MHz
        xLim
        xIndexLimits
        yLevelLim
        yTimeLim
        cLim

%       xFreq = aCoef * xIndex + bCoef
        aCoef
        bCoef        
    end


    methods
        %-----------------------------------------------------------------%
        function obj = Band(Context, callingApp)
            obj.Context    = Context;
            obj.callingApp = callingApp;
            obj.mainApp    = callingApp.mainApp;
        end

        %-----------------------------------------------------------------%
        function axesLimits = update(obj, idx, varargin)
            obj.SpecData   = obj.mainApp.specData(idx);
            obj.Receiver   = util.layoutTreeNodeText(obj.SpecData.Receiver, 'class.Band.update');
            obj.NumSweeps  = numel(obj.SpecData.Data{1});
            obj.DataPoints = obj.SpecData.MetaData.DataPoints;
            obj.FreqStart  = obj.SpecData.MetaData.FreqStart / 1e+6;
            obj.FreqStop   = obj.SpecData.MetaData.FreqStop  / 1e+6;
            obj.LevelUnit  = obj.SpecData.MetaData.LevelUnit;

            obj.xArray     = round(linspace(obj.FreqStart, obj.FreqStop, obj.DataPoints), class.Constants.xDecimals);
            obj.aCoef      = (obj.FreqStop - obj.FreqStart)*1e+6 ./ (obj.DataPoints - 1);
            obj.bCoef      = obj.FreqStart*1e+6 - obj.aCoef;

            axesLimits     = Limits(obj, idx, varargin{:});
        end

        %-----------------------------------------------------------------%
        function axesLimits = Limits(obj, idx, varargin)
            % Nos contextos "appAnalise:PLAYBACK" e "appAnalise:REPORT:BAND"
            % o plot é orientado à faixa de frequência. Neste caso, os limites
            % dos eixos serão manuais - selecionados diretamente no PLAYBACK - 
            % ou automáticos.

            % Já nos contextos cujo plot é orientado à emissão, os limites serão
            % delimitados pelas características da emissão (FreqCenter e BW) e 
            % pela variável BandGuard.

            % O campo "xIndexLimits" é aplicável apenas ao plot orientado à
            % emissão. Mantido em todos os contextos para garantir uma estrutura
            % uniforme de axesLimits.

            switch obj.Context
                case {'appAnalise:PLAYBACK', 'appAnalise:REPORT:BAND'}
                    specData = obj.mainApp.specData(idx);

                    switch specData.UserData.PlotDisplayConfig.Type
                        case 'manual'
                            xLimits      = specData.UserData.PlotDisplayConfig.Parameters.Controls.FrequencyLimits;
                            yLevelLimits = specData.UserData.PlotDisplayConfig.Parameters.Controls.LevelLimits;
                            cLimits      = specData.UserData.PlotDisplayConfig.Parameters.Waterfall.LevelLimits;

                            if isequal(cLimits, [0,0])
                                cLimits  = [0,1];
                            end
        
                            if issorted(xLimits, 'strictascend') && issorted(yLevelLimits, 'strictascend') && issorted(cLimits, 'strictascend')
                                axesLimits = struct('xLim',         xLimits,                                      ...
                                                    'xIndexLimits', freq2idx(obj, xLimits * 1e+6),                ...
                                                    'yLevelLim',    yLevelLimits,                                 ...
                                                    'yTimeLim',     [specData.Data{1}(1), specData.Data{1}(end)], ...
                                                    'cLim',         cLimits);

                                if specData.Data{1}(1) == specData.Data{1}(end)
                                    axesLimits.yTimeLim(2) = axesLimits.yTimeLim(2) + seconds(1);
                                end        
                            else
                                axesLimits = XYCLimits(obj, idx);
                            end        
                    otherwise
                        axesLimits = XYCLimits(obj, idx);
                    end

                case {'appAnalise:REPORT:CHANNEL', 'appAnalise:REPORT:EMISSION', 'appAnalise:SIGNALANALYSIS'}
                    if isempty(varargin)
                        error('Band:Limits:UnexpectedNumberOfInputArguments', 'Unexpected number of input arguments')
                    end

                    axesLimits = XYCLimits(obj, idx, struct('Mode', 'manual', 'Parameters', struct('Type', 'BWRelated', 'Value', 5)), varargin{:});

                case 'appAnalise:DRIVETEST'
                    if isempty(varargin)
                        error('Band:Limits:UnexpectedNumberOfInputArguments', 'Unexpected number of input arguments')
                    end

                    axesLimits = XYCLimits(obj, idx, varargin{:});
            end

            obj.xLim         = axesLimits.xLim;
            obj.xIndexLimits = axesLimits.xIndexLimits;
            obj.yLevelLim    = axesLimits.yLevelLim;
            obj.yTimeLim     = axesLimits.yTimeLim;
            obj.cLim         = axesLimits.cLim;
        end

        %-----------------------------------------------------------------%
        function [XArray, YArray] = XYArray(obj, idx, plotTag)

            arguments
                obj
                idx
                plotTag {mustBeMember(plotTag, {'clearWrite', 'minHold', 'average', 'maxHold', 'waterfallTime'})}
            end

            specData = obj.mainApp.specData(idx);
            if isprop(obj.callingApp, 'sweepTimeIdx')
                idxTime = obj.callingApp.sweepTimeIdx;
            end

            switch plotTag
                case 'clearWrite'
                    XArray = obj.xArray;
                    YArray = specData.Data{2}(:,idxTime)';                    

                case {'minHold', 'average', 'maxHold'}
                    XArray = obj.xArray;

                    switch plotTag
                        case 'minHold'; idxFcn = 1;
                        case 'average'; idxFcn = 2;
                        case 'maxHold'; idxFcn = 3;
                    end
        
                    switch obj.Context
                        case 'appAnalise:PLAYBACK'
                            if ismember(plotTag, {'minHold', 'average', 'maxHold'}) && isinf(str2double(obj.callingApp.play_TraceIntegration.Value))
                                YArray  = specData.Data{3}(:,idxFcn)';        
                            else
                                YArray  = specData.Data{2}(:,idxTime)';
                            end
        
                        otherwise
                            YArray = specData.Data{3}(:,idxFcn)';
                    end

                case 'waterfallTime'
                     XArray = [obj.xArray(1), obj.xArray(end)];

                    switch obj.Context
                        case {'appAnalise:PLAYBACK', 'appAnalise:DRIVETEST'}
                            hAxes = obj.callingApp.UIAxes3;
                            switch class(hAxes.YAxis)
                                case 'matlab.graphics.axis.decorator.DatetimeRuler'
                                    YArray = [specData.Data{1}(idxTime), specData.Data{1}(idxTime)];
                                otherwise
                                    YArray = [idxTime, idxTime];
                            end

                        otherwise
                            error('Band:XYArray:UnexpectedPlotTag', 'UnexpectedPlotTag')
                    end
            end
        end

        %-----------------------------------------------------------------%
        function FrequencyInHertz = idx2freq(obj, idx)
            FrequencyInHertz = obj.aCoef * idx + obj.bCoef;
        end

        %-----------------------------------------------------------------%
        function [idx, invalidIndex] = freq2idx(obj, FrequencyInHertz, validationType, roundType)
            arguments
                obj
                FrequencyInHertz
                validationType {mustBeMember(validationType, {'CheckAndRound', 'OnlyCheck'})} = 'CheckAndRound'
                roundType      {mustBeMember(roundType,      {'round', 'fix', 'ceil'})} = 'round'
            end

            idx = (FrequencyInHertz - obj.bCoef) / obj.aCoef;
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
        function idxTime = Timestamp2idxTime(obj, idx, Timestamp)
            [~, idxTime] = min(abs(obj.mainApp.specData(idx).Data{1}-Timestamp));
        end

        %-----------------------------------------------------------------%
        function Timestamp = idxTime2Timestamp(obj, idx, idxTime)
            Timestamp = obj.mainApp.specData(idx).Data{1}(idxTime);
        end
    end

    methods(Access = private)
        %-----------------------------------------------------------------%
        function axesLimits = XYCLimits(obj, idx, GuardBand, varargin)
            arguments
                obj
                idx
                GuardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'BWRelated', 'Value', 5))
            end

            arguments (Repeating)
                varargin                
            end
            
            specData = obj.mainApp.specData(idx);

            % xLimits
            switch obj.Context
                case {'appAnalise:PLAYBACK', 'appAnalise:REPORT:BAND'}
                    xLimits    = [obj.FreqStart, obj.FreqStop];
                    xIndexDown = 1;
                    xIndexUp   = obj.DataPoints;

                case 'appAnalise:REPORT:CHANNEL'
                    idxChannel = varargin{1};

                    chFreqCenter = specData.UserData.ReportChannels.FirstChannel(idxChannel); % MHz
                    chBW         = specData.UserData.ReportChannels.ChannelBW(idxChannel);    % MHz

                    if chBW <= 0
                        GuardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', 1));
                    else
                        GuardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', ceil(1.1*chBW)));
                    end
                    [xLimits,    ...
                     xIndexDown, ...
                     xIndexUp] = XEmissionLimits(obj, chFreqCenter, chBW, GuardBand);

                case {'appAnalise:REPORT:EMISSION', 'appAnalise:SIGNALANALYSIS'}
                    idxEmission = varargin{1};

                    emissionFreqCenter = specData.UserData.Emissions.Frequency(idxEmission); % MHz
                    emissionBW         = specData.UserData.Emissions.BW_kHz(idxEmission) / 1000; % kHz >> MHz

                    if emissionBW <= 0
                        GuardBand = struct('Mode', 'manual', 'Parameters', struct('Type', 'Fixed', 'Value', 1));
                    end
                    [xLimits,    ...
                     xIndexDown, ...
                     xIndexUp] = XEmissionLimits(obj, emissionFreqCenter, emissionBW, GuardBand);

                case 'appAnalise:DRIVETEST'
                    idxEmission = varargin{1};

                    if isempty(idxEmission)
                        chFreqCenter = (specData.MetaData.FreqStart + specData.MetaData.FreqStop) / 2e6; % MHz
                        chBandWidth  = (specData.MetaData.FreqStop - specData.MetaData.FreqStart) / 1e6; % MHz
                    else
                        chFreqCenter = specData.UserData.Emissions.ChannelAssigned(idxEmission).userModified.Frequency; % MHz
                        chBandWidth  = specData.UserData.Emissions.ChannelAssigned(idxEmission).userModified.ChannelBW / 1000; % kHz >> MHz
                    end

                    [xLimits,    ...
                     xIndexDown, ...
                     xIndexUp] = XEmissionLimits(obj, chFreqCenter, chBandWidth, GuardBand);
            end
        
            % yLevelLimits
            DataType     = specData.MetaData.DataType;
            if ismember(DataType, class.Constants.specDataTypes)
                % yLimits
                minArray = sort(specData.Data{3}(xIndexDown:xIndexUp, 1));
                maxArray = sort(specData.Data{3}(xIndexDown:xIndexUp, 3), 'descend');

                nSamples = ceil(.01*numel(minArray));
                minValue = median(minArray(1:nSamples));
                maxValue = median(maxArray(1:nSamples));

                downYLim = minValue - mod(minValue, 5);
                upYLim   = maxValue - mod(maxValue, 10) + 10;

                % cLimits
                downCLim = RF.noiseEstimation(specData, xIndexDown, xIndexUp, .05, .15, 3);
                upCLim   = upYLim - 10;
                downCLim = max(downCLim, upCLim-30);

                diffCLim = upCLim-downCLim;
                if diffCLim < 15
                    downCLim = downCLim - (15-diffCLim)/2;
                    upCLim   = upCLim   + (15-diffCLim)/2;
                end

            elseif ismember(DataType, class.Constants.occDataTypes)
                downYLim = 0;
                upYLim   = 100;

                downCLim = 0;
                upCLim   = 1;

            else
                error('Band:XYCLimits:UnexpectedDataType', 'UnexpectedDataType')
            end
            yLevelLimits = [downYLim, upYLim];
        
            if diff(yLevelLimits) > class.Constants.yMaxLimRange
                yLevelLimits(1) = yLevelLimits(1) + diff(yLevelLimits) - class.Constants.yMaxLimRange;
            end

            axesLimits = struct('xLim',         xLimits,                                      ...
                                'xIndexLimits', [xIndexDown, xIndexUp],                       ...
                                'yLevelLim',    yLevelLimits,                                 ...
                                'yTimeLim',     [specData.Data{1}(1), specData.Data{1}(end)], ...
                                'cLim',         [downCLim, upCLim]);

            if specData.Data{1}(1) == specData.Data{1}(end)
                axesLimits.yTimeLim(2) = axesLimits.yTimeLim(2) + seconds(1);
            end
        end

        %-----------------------------------------------------------------%
        function [xFrequencyLimits, xIndexDown, xIndexUp] = XEmissionLimits(obj, refFreqCenter, refBW, GuardBand)
            % Escolhido como nome da variável "refFreqCenter" e "refBW" 
            % porque essa chamada é consumida tanto por ROIs relacionadas a
            % emissões, quanto por ROIs relacionadas a canais.

            switch GuardBand.Mode
                case 'auto'
                    screenFreqStart = refFreqCenter - refBW/2;
                    screenFreqStop  = refFreqCenter + refBW/2;
        
                case 'manual'
                    switch GuardBand.Parameters.Type
                        case 'Fixed'
                            screenFreqStart = refFreqCenter - GuardBand.Parameters.Value/2;
                            screenFreqStop  = refFreqCenter + GuardBand.Parameters.Value/2;
        
                        case 'BWRelated'
                            screenFreqStart = refFreqCenter - GuardBand.Parameters.Value * refBW/2;
                            screenFreqStop  = refFreqCenter + GuardBand.Parameters.Value * refBW/2;
                    end
            end
    
            xIndexDown       = freq2idx(obj, screenFreqStart * 1e+6, 'CheckAndRound', 'fix');
            xIndexUp         = freq2idx(obj, screenFreqStop  * 1e+6, 'CheckAndRound', 'ceil');
            xFrequencyLimits = [screenFreqStart, screenFreqStop];
        end
    end
end