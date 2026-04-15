classdef (Abstract) draw2D

    methods (Static = true)
        %-----------------------------------------------------------------%
        function plotHandle = OrdinaryLine(axesHandle, plotTag, bandObj, sweepTimeIdx)
            plotHandle = [];
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            [plotConfig, plotType] = plot.Config(plotTag, bandObj.GeneralSettings);
            [xArray, yArray] = getXYArrays(bandObj, plotTag, sweepTimeIdx, class(axesHandle.YAxis));
            
            switch plotType
                case 'line'
                    plotHandle = line(axesHandle, xArray, yArray, plotConfig{:});
                case 'area'
                    plotHandle = area(axesHandle, xArray, yArray, 'BaseValue', min(min(yArray), axesHandle.YLim(1)), 'FaceAlpha', 0.25, plotConfig{:});
            end

            plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
        end

        %-----------------------------------------------------------------%
        function OrdinaryLineUpdate(plotTag, plotHandle, bandObj, sweepTimeIdx)
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            switch plotTag
                case {'clearWrite', 'minHold', 'average', 'maxHold'}
                    yArray = bandObj.SpecData.Data{2}(:, sweepTimeIdx)';

                    switch plotTag                
                        case 'clearWrite'
                            plotHandle.YData = yArray;
                        case 'minHold'
                            plotHandle.YData = min(plotHandle.YData, yArray);
                        case 'average'
                            integrationFactor = bandObj.General.context.PLAYBACK.integration.traceMode;
                            plotHandle.YData = ((integrationFactor-1)*plotHandle.YData + yArray) / integrationFactor;
                        case 'maxHold'
                            plotHandle.YData = max(plotHandle.YData, yArray);
                    end

                case 'waterfallTime'
                    switch class(plotHandle.YData)
                        case 'datetime'
                            tInstant = bandObj.SpecData.Data{1}(sweepTimeIdx);
                            plotHandle.YData = [tInstant, tInstant];
                        otherwise
                            plotHandle.YData = [sweepTimeIdx, sweepTimeIdx];
                    end
            end
        end

        %-----------------------------------------------------------------%
        function horizontalSetOfLines(axesHandle, bandObj, plotTag, varargin)
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            switch plotTag
                case 'bandLimits'
                    srcInfo  = specData.UserData.DetectionSubBands;
                    plotFlag = specData.UserData.DetectionSubBandsEnabled;                    
                    
                case 'channel'
                    srcInfo  = varargin{1};

                case 'emission'
                    srcInfo  = specData.UserData.Emissions;
                    srcInfo.FreqStart = srcInfo.Frequency - srcInfo.BandWidthkHz/2000;
                    srcInfo.FreqStop  = srcInfo.Frequency + srcInfo.BandWidthkHz/2000;
            end

            if ~exist('plotFlag', 'var')
                if isempty(srcInfo)
                    plotFlag = false;
                else
                    plotFlag = true;
                end
            end

            delete(findobj(axesHandle, 'Tag', plotTag))
            
            if plotFlag && ~isempty(srcInfo)
                [plotConfig,     ...
                 yLimOffsetMode, ...
                 yLimOffset,     ...
                 stepEffect] = plot.Config(plotTag, bandObj.GeneralSettings);

                switch yLimOffsetMode
                    case 'bottom'
                        yLevel = axesHandle.YLim(1)+yLimOffset;
                    otherwise % 'top'
                        yLevel = axesHandle.YLim(2)-yLimOffset;                        
                end
            
                for ii = 1:height(srcInfo)
                    freqStart = srcInfo.FreqStart(ii);
                    freqStop  = srcInfo.FreqStop(ii);

                    if stepEffect
                        switch yLimOffsetMode
                            case 'bottom'
                                yLevel2Plot = yLevel + mod(ii+1,2);
                            otherwise
                                yLevel2Plot = yLevel - mod(ii+1,2);
                        end
                    else
                        yLevel2Plot = yLevel;
                    end
                    
                    line(axesHandle, [freqStart, freqStop], [yLevel2Plot, yLevel2Plot], plotConfig{:})

                    if strcmp(plotTag, 'emission')
                        freqCenter = srcInfo.Frequency(ii);
                        line(axesHandle, [freqCenter, freqCenter], [-1000, 1000], 'Color', '#ffff12', 'LineWidth', 1, 'LineStyle', ':', 'PickableParts', 'none', 'Tag', 'emission');
                        text(axesHandle, freqCenter, yLevel2Plot, sprintf(' %d', ii), 'Color', '#ffff12', 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Helvetica', 'VerticalAlignment', 'bottom', 'Tag', 'emissionTag');
                    end
                end
                plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
            end
        end

        %-----------------------------------------------------------------%
        function rectangularROI(hAxes, bandObj, srcROITable, idxROI, plotTag, postPlotConfig, yLimits)
            arguments
                hAxes
                bandObj
                srcROITable
                idxROI
                plotTag
                postPlotConfig = {}
                yLimits = []
            end

            if isempty(idxROI)
                idxROI = 1:height(srcROITable);
            end

            if ~isempty(srcROITable)
                [plotConfigROI,   ...
                 plotConfigText,  ...
                 LabelOffsetMode, ...
                 LabelOffset] = plot.Config(plotTag, bandObj.GeneralSettings);

                if isempty(yLimits)
                    yLimits = double(hAxes.YLim);
                end
                
                for ii = idxROI
                    hROI = drawrectangle(hAxes, 'Position', [srcROITable.Frequency(ii)-srcROITable.BandWidthkHz(ii)/2000, yLimits(1)+1, srcROITable.BandWidthkHz(ii)/1000, diff(yLimits)-2], plotConfigROI{:});

                    if ~isempty(postPlotConfig)
                        set(hROI, postPlotConfig{:})
                    end
                end

                switch bandObj.Context
                    case {'appAnalise:SIGNALANALYSIS', 'appAnalise:DRIVETEST'}
                        % ...
                        % Pendente migrar o ROI do PLAYBACK, hoje criado na
                        % função "ClearWrite_old" desta classe.
                        % ...

                    case 'appAnalise:REPORT:BAND'
                        switch LabelOffsetMode
                            case 'bottom'
                                yTextPosition = yLimits(1)+LabelOffset;
                            otherwise % 'top'
                                yTextPosition = yLimits(2)-LabelOffset;                        
                        end

                        text(hAxes, srcROITable.Frequency(idxROI), repmat(yLimits(1)+yTextPosition, numel(idxROI), 1), string((idxROI)'), plotConfigText{:});
                end
            end
        end
    end
end

