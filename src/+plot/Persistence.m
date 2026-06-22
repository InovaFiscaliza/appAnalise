function [persistenceObj, windowSize] = Persistence(operationType, persistenceObj, axesHandle, bandObj, sweepTimeIdx)
    arguments
        operationType
        persistenceObj
        axesHandle = []
        bandObj = []
        sweepTimeIdx = []
    end

    switch operationType
        case {'Creation', 'Update'}
            specData = bandObj.SpecData;
            plotDisplayConfig = specData.UserData.PlotDisplayConfig;

            plotConfig = {
                'CDataMapping', 'scaled', ...
                'PickableParts', 'none', ...
                'Interpolation', plotDisplayConfig.persistence.interpolation, ...
                'Tag', 'persistence' ...
            };

            windowSize = checkWindowSize(bandObj, plotDisplayConfig.persistence.windowSize);
            colormapName = plotDisplayConfig.persistence.colormap;
            transparency = plotDisplayConfig.persistence.transparency;
            cLimits = plotDisplayConfig.limits.persistence.cLim;

            switch operationType
                case 'Creation'    
                    xResolution = min(801, bandObj.DataPoints);
                    yResolution = 201;
            
                    yAmplitude = class.Constants.yMaxLimRange;
                    [yMin, yMax] = bounds(specData.Data{2}, 'all');
                    yMax = max(yMin + yAmplitude, yMax);
                    yMin = yMax - yAmplitude;
                    
                    xEdges = linspace(bandObj.FreqStart, bandObj.FreqStop, xResolution + 1);
                    yEdges = linspace(yMin, yMax, yResolution + 1);
                    specHist = zeros(yResolution, xResolution);
    
                    % Cria uma imagem vazia, o que possibilita criar o
                    % objeto hPersistanceObj. E logo em seguida chama essa
                    % mesma função, mas no modo "Update".
                    persistenceHandle = image(axesHandle, specHist, 'AlphaData', specHist,'XData', [bandObj.FreqStart, bandObj.FreqStop], 'YData', [yMin, yMax], plotConfig{:});
                    persistenceObj = struct('handle', persistenceHandle, 'xEdges', xEdges, 'yEdges', yEdges);
    
                    set(axesHandle, 'CLimMode', 'auto')
                    persistenceObj = plot.Persistence('Update', persistenceObj, axesHandle, bandObj, sweepTimeIdx);
                    
                    if isempty(cLimits) || ~issorted(cLimits, 'strictascend')
                        axesHandle.UserData.CLimMode = 'auto';
                    else
                        axesHandle.CLim  = cLimits;
                        axesHandle.UserData.CLimMode = 'manual';
                    end

                    plot.axes.Colormap(axesHandle, colormapName)
                    plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
    
                case 'Update'
                    if isempty(persistenceObj)
                        persistenceObj = plot.Persistence('Creation', persistenceObj, axesHandle, bandObj);
                        return
                    end

                    nSweeps = bandObj.NumSweeps;
                    switch windowSize
                        case 'full'
                            timeIdxs = 1:nSweeps;

                        otherwise
                            winSize = str2double(windowSize);

                            switch bandObj.Context
                                case {'appAnalise:PLAYBACK', 'appAnalise:DRIVETEST'}
                                    timeIdxs = max(1, sweepTimeIdx - winSize + 1):sweepTimeIdx;

                                case {'appAnalise:REPORT', 'appAnalise:REPORT:BAND', 'appAnalise:REPORT:EMISSION'}
                                    timeIdxs = round(linspace(1, nSweeps, winSize));
                            end                          
                    end

                    nTimeArray = numel(timeIdxs);

                    specHist = histcounts2(specData.Data{2}(:, timeIdxs), repmat(bandObj.XArray', 1, nTimeArray), persistenceObj.yEdges, persistenceObj.xEdges);
                    set(persistenceObj.handle, 'CData', (100 * specHist ./ sum(specHist)), 'AlphaData', double(logical(specHist))*transparency)
            end

        case 'Delete'
            windowSize = '';

            if ~isempty(persistenceObj)
                delete(persistenceObj.handle)
                persistenceObj = [];
            end
    end       
end

%-----------------------------------------------------------------%
function windowSize = checkWindowSize(bandObj, windowSize)
    if strcmp(windowSize, 'full')
        nPersistancePoints    = bandObj.DataPoints * bandObj.NumSweeps;
        nMaxPersistancePoints = class.Constants.nMaxPersistancePoints;

        if nPersistancePoints > nMaxPersistancePoints
            windowSize = num2str(min(bandObj.NumSweeps, 512));
        end
    end
end