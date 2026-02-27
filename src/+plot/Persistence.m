function [hPersistanceObj, windowSize] = Persistence(operationType, hPersistanceObj, varargin)
    switch operationType
        case {'Creation', 'Update'}
            hAxes       = varargin{1};
            bandObj     = varargin{2};
            idx         = varargin{3}; 

            specData    = bandObj.mainApp.specData(idx);

            defaultProp = bandObj.mainApp.General_I;
            customProp  = bandObj.mainApp.specData(idx).UserData.customPlayback.Parameters;

            [plotConfig,   ...
             windowSize,   ...
             colormapName, ...
             Transparency, ...
             cLimits]   = plot.Config('persistence', defaultProp, customProp);
            windowSize  = checkWindowSize(bandObj, windowSize);

            switch operationType
                case 'Creation'    
                    xResolution = min(801, bandObj.DataPoints);
                    yResolution = 201;
            
                    yAmplitude    = class.Constants.yMaxLimRange;
                    [yMin, yMax]  = bounds(specData.Data{2}, 'all');
                    yMax          = max(yMin+yAmplitude, yMax);
                    yMin          = yMax-yAmplitude;
                    
                    xEdges        = linspace(bandObj.FreqStart, bandObj.FreqStop, xResolution+1);
                    yEdges        = linspace(yMin, yMax, yResolution+1);
                    specHist      = zeros(yResolution, xResolution);
    
                    hPersistance  = image(hAxes, specHist, 'AlphaData', specHist,'XData', [bandObj.FreqStart, bandObj.FreqStop], 'YData', [yMin, yMax], plotConfig{:});
                    
                    % Cria uma imagem vazia, o que possibilita criar o
                    % objeto hPersistanceObj. E logo em seguida chama essa
                    % mesma função, mas no modo "Update".
                    hPersistanceObj = struct('handle',   hPersistance, ...
                                             'xEdges',   xEdges,       ...
                                             'yEdges',   yEdges);
    
                    set(hAxes, 'CLimMode', 'auto')
                    hPersistanceObj = plot.Persistance('Update', hPersistanceObj, hAxes, bandObj, idx);
                    
                    if isempty(cLimits)
                        hAxes.UserData.CLimMode = 'auto';
                    else
                        hAxes.CLim  = cLimits;
                        hAxes.UserData.CLimMode = 'manual';
                    end

                    plot.axes.Colormap(hAxes, colormapName)
                    plot.axes.StackingOrder.execute(hAxes, bandObj.Context)
    
                case 'Update'
                    if isempty(hPersistanceObj)
                        hPersistanceObj = plot.Persistance('Creation', hPersistanceObj, hAxes, bandObj, idx);
                        return
                    end

                    nSweeps = numel(specData.Data{1});
                    switch windowSize
                        case 'full'
                            idxTimeArray = 1:nSweeps;

                        otherwise
                            winSize = str2double(windowSize);

                            switch bandObj.Context
                                case {'appAnalise:PLAYBACK', 'appAnalise:DRIVETEST'}
                                    idxTime = bandObj.callingApp.sweepTimeIndex;
                                    idxTimeArray = max(1,idxTime-winSize+1):idxTime;

                                case {'appAnalise:REPORT', 'appAnalise:REPORT:BAND', 'appAnalise:REPORT:EMISSION'}
                                    idxTimeArray = round(linspace(1, nSweeps, winSize));
                            end                          
                    end

                    nTimeArray = numel(idxTimeArray);

                    specHist = histcounts2(specData.Data{2}(:, idxTimeArray), repmat(bandObj.xArray', 1, nTimeArray), hPersistanceObj.yEdges, hPersistanceObj.xEdges);
                    set(hPersistanceObj.handle, 'CData', (100 * specHist ./ sum(specHist)), 'AlphaData', double(logical(specHist))*Transparency)
            end

        case 'Delete'
            windowSize = '';

            if ~isempty(hPersistanceObj)
                delete(hPersistanceObj.handle)
                hPersistanceObj = [];
            end
    end       
end

%-----------------------------------------------------------------%
function windowSize = checkWindowSize(bandObj, windowSize)
    if windowSize == "full"
        nPersistancePoints    = bandObj.DataPoints * bandObj.nSweeps;
        nMaxPersistancePoints = class.Constants.nMaxPersistancePoints;

        if nPersistancePoints > nMaxPersistancePoints
            windowSize = num2str(min(bandObj.nSweeps, 512));
        end
    end
end