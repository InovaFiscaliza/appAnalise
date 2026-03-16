function Occupancy(operationType, axes1Handle, axes2Handle, varargin)
    switch operationType
        case 'Creation'
            resetOccupancyPlot(axes1Handle, axes2Handle)
            
            occParameters = varargin{1};
            occThreshold  = varargin{2};
            occData = varargin{3};
            bandObj = varargin{4};
            generalSettings = varargin{5};

            % axes1Handle
            xArray = bandObj.XArray;
            levelUnit = bandObj.LevelUnit;
            switch occParameters.Method
                case 'Linear fixo (COLETA)'
                    thresholdPlotHandle    = plot(axes1Handle, [xArray(1), xArray(end)], [occThreshold, occThreshold], Color='red', LineStyle='-', LineWidth=1, Marker='o', MarkerSize=4, MarkerIndices=1:2, MarkerFaceColor='red', MarkerEdgeColor='black', Tag='occupancyThreshold');

                case 'Linear fixo'
                    thresholdPlotHandle    = images.roi.Line(axes1Handle,'Position',[xArray(1) occThreshold; xArray(end) occThreshold], 'Color', 'red', 'MarkerSize', 4, 'Deletable', 0, 'LineWidth', 1, 'InteractionsAllowed', 'translate', 'Tag', 'occupancyThreshold');
                    
                    addlistener(thresholdPlotHandle, 'MovingROI', @(~,evt)occLineROI(evt));
                    addlistener(thresholdPlotHandle, 'ROIMoved',  @(~,evt)occLineROI(evt));

                case 'Linear adaptativo'                        
                    [minThreshold, maxThreshold] = bounds(occThreshold);

                    thresholdPlotHandle(1) = plot(axes1Handle, [xArray(1), xArray(end)], [minThreshold, minThreshold], Color='red', LineStyle='-.', LineWidth=1, Marker='o', MarkerSize=4, MarkerIndices=1:2, MarkerFaceColor='red', MarkerEdgeColor='black', Tag='occupancyThreshold');
                    thresholdPlotHandle(2) = plot(axes1Handle, [xArray(1), xArray(end)], [maxThreshold, maxThreshold], Color='red', LineStyle='-.', LineWidth=1, Marker='o', MarkerSize=4, MarkerIndices=1:2, MarkerFaceColor='red', MarkerEdgeColor='black', Tag='occupancyThreshold');

                case 'Envoltória do ruído'
                    thresholdPlotHandle    = plot(axes1Handle, xArray, occThreshold, Color='red', LineStyle='-', LineWidth=1, Marker='o', MarkerSize=4, MarkerIndices=[1, numel(xArray)], MarkerFaceColor='r', MarkerEdgeColor='black', Tag='occupancyThreshold');
            end

            % axes2Handle
            axes2Handle.YLim = [0, 100];
            occupancyPlotHandle = plot(axes2Handle, xArray, occData, Color=generalSettings.plot.clearWrite.EdgeColor, Tag='occupancyData');

            if isinf(occParameters.IntegrationTime)
                integrationTime = 'integração cumulativa';
            else
                integrationTime = sprintf('integração: %d minutos', occParameters.IntegrationTime);
            end

            [minTHR, maxTHR] = bounds(occThreshold);
            if isscalar(unique(round([minTHR, maxTHR])))
                threshold = sprintf('%d', minTHR);
            else
                threshold = sprintf('%d a %d', minTHR, maxTHR);
            end

            ysecondarylabel(axes2Handle, sprintf('Método: "%s", %s, threshold: %s %s', occParameters.Method, integrationTime, threshold, levelUnit))

            % DataTip
            customizeDataTipStyle(thresholdPlotHandle, levelUnit)
            customizeDataTipStyle(occupancyPlotHandle, '%%')

        case 'Delete'
            resetOccupancyPlot(axes1Handle, axes2Handle)
    end
end

%-------------------------------------------------------------------------%
function resetOccupancyPlot(axes1Handle, axes2Handle)
    delete(findobj(axes1Handle, 'Tag', 'occupancyThreshold'))
    ysecondarylabel(axes2Handle, '')
    cla(axes2Handle)
end

%-------------------------------------------------------------------------%
function customizeDataTipStyle(plotHandle, levelUnit)
    for ii = 1:numel(plotHandle)
        plot.datatip.Template(plotHandle(ii), 'Frequency+Occupancy', levelUnit)
    end
end

%-------------------------------------------------------------------------%
function occLineROI(src, evt, specData)
    switch(event.EventName)
        case 'MovingROI'
            plot.axes.Interactivity.DefaultDisable(axes1Handle)
            
        case 'ROIMoved'
            plot.axes.Interactivity.DefaultEnable(axes1Handle)
            update(specData, "UserData:OccupancyFields")
    end
end