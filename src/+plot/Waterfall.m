function [hWaterfall, Decimation] = Waterfall(operationType, varargin)
    switch operationType
        case 'Creation'
            hAxes   = varargin{1};
            bandObj = varargin{2};
            idx     = varargin{3};

            Context     = bandObj.Context;
            defaultProp = bandObj.callingApp.General_I;
            customProp  = bandObj.callingApp.specData(idx).UserData.customPlayback.Parameters;

            [plotConfig,   ...
             Fcn,          ...
             Decimation,   ...
             colormapName, ...
             cLimits]   = plot.Config('waterfall', defaultProp, customProp, Context);

            xArray      = bandObj.xArray';
            xLim        = [xArray(1), xArray(end)];
            specData    = bandObj.callingApp.specData(idx);
            nSweeps     = numel(specData.Data{1});

            set(hAxes, 'CLimMode', 'auto')
            switch Fcn
                case 'mesh'
                    [nDecimation, tArray] = checkDecimation(specData, bandObj, Decimation, 1);
        
                    if tArray(1) == tArray(end)
                        tArray(end) = tArray(1)+seconds(1);
                    end
                    yLim = [tArray(1), tArray(end)];
                    plot.axes.Ruler(hAxes, xLim, yLim)
        
                    [X, Y] = meshgrid(xArray, tArray);
                    hWaterfall = mesh(hAxes, X, Y, specData.Data{2}(:,1:nDecimation:end)', plotConfig{:});                            

                case 'image'
                    nDecimation = checkDecimation(specData, bandObj, Decimation, 16);

                    idxTimeArray = 1:nDecimation:nSweeps;
                    if idxTimeArray(end) ~= nSweeps
                        idxTimeArray(end+1) = nSweeps;
                    end

                    yLim = [1, nSweeps];
                    plot.axes.Ruler(hAxes, xLim, yLim)

                    hWaterfall = image(hAxes, xArray, idxTimeArray, specData.Data{2}(:, idxTimeArray)', plotConfig{:});
            end

            Decimation = num2str(nDecimation);

            if isempty(cLimits)
                cLimits = bandObj.cLim;
                hAxes.UserData.CLimMode = 'auto';
            else                        
                hAxes.UserData.CLimMode = 'manual';
            end
            
            postPlotConfig = {'YLim', yLim, 'CLim', cLimits};
            set(hAxes, postPlotConfig{:})
            if ~strcmp(Context, 'appAnalise:DRIVETEST')
                ysecondarylabel(hAxes, sprintf('%s - %s', specData.Data{1}(1), specData.Data{1}(end)))
            end

            if ~strcmp(Context, 'appAnalise:REPORT:BAND')
                plot.datatip.Template(hWaterfall, 'Frequency+Timestamp+Level', bandObj.LevelUnit)
            end

            plot.axes.Colormap(hAxes, colormapName)            
            plot.axes.StackingOrder.execute(hAxes, bandObj.Context)

        case 'Delete'
            hWaterfall = varargin{1};
            Decimation = 'auto';
            
            if ~isempty(hWaterfall) && isvalid(hWaterfall)
                cla(hWaterfall.Parent)
                hWaterfall = [];
            end
    end
end

%-----------------------------------------------------------------%
function [nDecimation, tArray] = checkDecimation(specData, bandObj, DecimationType, DecimationFactor)
    switch DecimationType
        case 'auto'
            nWaterFallPoints    = bandObj.DataPoints * bandObj.nSweeps;
            nMaxWaterFallPoints = DecimationFactor * class.Constants.nMaxWaterFallPoints;

            if nWaterFallPoints > nMaxWaterFallPoints
                nDecimation = ceil(nWaterFallPoints/nMaxWaterFallPoints);
            else
                nDecimation = 1;
            end

        otherwise
            nDecimation = str2double(DecimationType);
    end

    while true
        tArray = specData.Data{1}(1:nDecimation:end);
        if numel(tArray) > 1; break
        else;                 nDecimation = round(nDecimation/2);
        end
    end
end