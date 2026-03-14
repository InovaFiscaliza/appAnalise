function [waterfallHandle, decimation] = Waterfall(operationType, waterfallHandle, axesHandle, bandObj)
    arguments
        operationType {mustBeMember(operationType, {'Creation', 'Delete'})}
        waterfallHandle
        axesHandle = []
        bandObj = []
    end

    switch operationType
        case 'Creation'
            specData = bandObj.SpecData;
            plotDisplayConfig = specData.UserData.PlotDisplayConfig;

            xArray = bandObj.XArray';
            xLim = [xArray(1), xArray(end)];
            
            decimation = plotDisplayConfig.waterfall.decimation;

            set(axesHandle, 'CLimMode', 'auto')
            switch plotDisplayConfig.waterfall.function
                case 'mesh'
                    [nDecimation, tArray] = checkDecimation(specData, bandObj, decimation, 1);
        
                    if tArray(1) == tArray(end)
                        tArray(end) = tArray(1)+seconds(1);
                    end
                    yLim = [tArray(1), tArray(end)];
                    plot.axes.Ruler(axesHandle, xLim, yLim)
        
                    [X, Y] = meshgrid(xArray, tArray);
                    waterfallHandle = mesh(axesHandle, X, Y, specData.Data{2}(:, 1:nDecimation:end)', 'MeshStyle', plotDisplayConfig.waterfall.meshStyle, 'SelectionHighlight', 'off', 'Tag', 'waterfall');

                case 'image'
                    nSweeps = bandObj.NumSweeps;
                    nDecimation = checkDecimation(specData, bandObj, decimation, 16);

                    timeIdxs = 1:nDecimation:nSweeps;
                    if timeIdxs(end) ~= nSweeps
                        timeIdxs(end+1) = nSweeps;
                    end

                    yLim = [1, nSweeps];
                    plot.axes.Ruler(axesHandle, xLim, yLim)

                    waterfallHandle = image(axesHandle, xArray, timeIdxs, specData.Data{2}(:, timeIdxs)', 'CDataMapping', 'scaled', 'Tag', 'waterfall');
            end
            decimation = num2str(nDecimation);

            cLimits = plotDisplayConfig.limits.waterfall.current;
            if isequal(cLimits, [0; 1])
                cLimits = bandObj.CLimits;
                axesHandle.UserData.CLimMode = 'auto';
            else                        
                axesHandle.UserData.CLimMode = 'manual';
            end
            
            set(axesHandle, 'YLim', yLim, 'CLim', cLimits)
            update(specData, 'UserData:PlotDisplayConfig', 'limitsWaterfallStartup', axesHandle.CLim)

            if ~strcmp(bandObj.Context, 'appAnalise:DRIVETEST')
                ysecondarylabel(axesHandle, sprintf('%s - %s', specData.Data{1}(1), specData.Data{1}(end)))
            end

            if ~strcmp(bandObj.Context, 'appAnalise:REPORT:BAND')
                plot.datatip.Template(waterfallHandle, 'Frequency+Timestamp+Level', bandObj.LevelUnit)
            end

            plot.axes.Colormap(axesHandle, plotDisplayConfig.waterfall.colormap)            
            plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)

        case 'Delete'
            decimation = 'auto';
            
            if ~isempty(waterfallHandle) && isvalid(waterfallHandle)
                cla(waterfallHandle.Parent)
                waterfallHandle = [];
            end
    end
end

%-----------------------------------------------------------------%
function [nDecimation, tArray] = checkDecimation(specData, bandObj, decimationType, decimationFactor)
    switch decimationType
        case 'auto'
            nWaterFallPoints    = bandObj.DataPoints * bandObj.NumSweeps;
            nMaxWaterFallPoints = decimationFactor * class.Constants.nMaxWaterFallPoints;

            if nWaterFallPoints > nMaxWaterFallPoints
                nDecimation = ceil(nWaterFallPoints/nMaxWaterFallPoints);
            else
                nDecimation = 1;
            end

        otherwise
            nDecimation = str2double(decimationType);
    end

    while true
        tArray = specData.Data{1}(1:nDecimation:end);
        if numel(tArray) > 1
            break
        else
            nDecimation = round(nDecimation/2);
        end
    end
end