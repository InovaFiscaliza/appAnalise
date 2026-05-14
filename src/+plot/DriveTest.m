classdef (Abstract) DriveTest

    methods (Static = true)
        %-----------------------------------------------------------------%
        function Route(hAxes, tempBandObj, varargin)
            switch tempBandObj.Context
                case 'appAnalise:REPORT:BAND'
                    if hAxes.Basemap == "none"
                        hAxes.Basemap = 'streets-light';
                    end

                    specData   = tempBandObj.SpecData;        
                    gpsPerFile = vertcat(specData.RelatedFiles.GPS{:});
                    gpsMatrix  = vertcat(gpsPerFile.Matrix);
        
                    geoplot(hAxes, gpsMatrix(:,1), gpsMatrix(:,2));

                case 'appAnalise:DRIVETEST'
                    OutTable   = varargin{1};
                    InTable    = varargin{2};
                    LineStyle  = varargin{3};
                    OutColor   = varargin{4};
                    InColor    = varargin{5};
                    MarkerSize = varargin{6};

                    switch LineStyle
                        case 'none'; markerSize = 1;
                        otherwise;   markerSize = 8*MarkerSize;
                    end

                    % OutRoute
                    geoplot(hAxes, OutTable.Latitude, OutTable.Longitude, 'Marker',          '.',        ...
                                                                          'Color',           OutColor,   ...
                                                                          'MarkerFaceColor', OutColor,   ...
                                                                          'MarkerEdgeColor', OutColor,   ...
                                                                          'MarkerSize',      markerSize, ...
                                                                          'LineStyle',       'none',     ...
                                                                          'PickableParts',   'none',     ...
                                                                          'DisplayName',     'Rota',     ...
                                                                          'Tag',             'routeFailFilter');
                    % InRoute
                    geoplot(hAxes,  InTable.Latitude,  InTable.Longitude, 'Marker',          '.',        ...
                                                                          'Color',           InColor,    ...
                                                                          'MarkerFaceColor', InColor,    ...
                                                                          'MarkerEdgeColor', InColor,    ...
                                                                          'MarkerSize',      markerSize, ...
                                                                          'LineStyle',       LineStyle,  ...
                                                                          'PickableParts',   'none',     ...
                                                                          'DisplayName',     'Rota',     ...
                                                                          'Tag',             'routePassFilter');
                otherwise
                    error('UnexpectedCall')
            end
        end

        %-----------------------------------------------------------------%
        function DistortionAndDensityPlot(hAxes, tempBandObj, srcTable, plotMode, plotSize)
            LevelUnit = tempBandObj.LevelUnit;

            switch tempBandObj.Context
                case 'appAnalise:REPORT:EMISSION'
                    Visibility = true;
                    switch plotMode
                        case 'distortion'
                            plot.DriveTest.Distortion(hAxes, srcTable, plotSize, Visibility, LevelUnit)
                        case 'density'
                            plot.DriveTest.Density(hAxes, srcTable, plotSize, Visibility)
                    end

                case 'appAnalise:DRIVETEST'
                    hDistortionVisibility = 0;
                    hDensityVisibility    = 0;
                    switch plotMode
                        case 'distortion'
                            hDistortionVisibility = 1;
                        case 'density'
                            hDensityVisibility    = 1;
                    end

                    plot.DriveTest.Distortion(hAxes, srcTable, plotSize, hDistortionVisibility, LevelUnit)
                    plot.DriveTest.Density(hAxes, srcTable, plotSize, hDensityVisibility)

                otherwise
                    error('UnexpectedCall')
            end
        end

        %-----------------------------------------------------------------%
        function Distortion(hAxes, srcTable, plotSize, Visibility, LevelUnit)
            hDistortion = geoscatter(hAxes, srcTable.Latitude, srcTable.Longitude, [], srcTable.ChannelPower,  ...
                                            'filled', 'SizeData', 20*plotSize, 'Tag', 'distortion', 'Visible', Visibility, 'DisplayName', 'Potência do canal (Distorção)');
            plot.datatip.Template(hDistortion, 'SweepID+ChannelPower+Coordinates', LevelUnit)
        end

        %-----------------------------------------------------------------%
        function Density(hAxes, srcTable, plotSize, Visibility)
            weights = srcTable.ChannelPower;
            if min(weights) < 0
                weights = weights+abs(min(weights));
            end

            geodensityplot(hAxes, srcTable.Latitude, srcTable.Longitude, weights, ...
                                  'FaceColor','interp', 'Radius', 100*plotSize,   ...
                                  'PickableParts', 'none', 'Tag', 'density', 'Visible', Visibility, 'DisplayName', 'Potência do canal (Densidade)');
        end

        %-----------------------------------------------------------------%
        function filterTable = FilterRegions(filterTable, geoAxesHandle, cartesianAxesHandle, replotAfterFilterChangeFcn)
            arguments
                filterTable
                geoAxesHandle
                cartesianAxesHandle
                replotAfterFilterChangeFcn = []
            end
            
            if ~isempty(filterTable)
                for ii = 1:height(filterTable)
                    filterSubtype = filterTable.subtype{ii};

                    switch filterSubtype
                        case 'PolygonKML'
                            lat = filterTable.roi(ii).specification.Latitude;
                            lng = filterTable.roi(ii).specification.Longitude;
                            shapeObj = geopolyshape(lat, lng);

                            roiHandle = plot.DriveTest.FilterRoiGraphic(filterSubtype, geoAxesHandle, replotAfterFilterChangeFcn, shapeObj);

                        otherwise
                            switch filterSubtype                        
                                case 'Threshold'
                                    axesHandle = cartesianAxesHandle;
                                otherwise
                                    axesHandle = geoAxesHandle;
                            end

                            roiHandle = plot.DriveTest.FilterRoiGraphic(filterSubtype, axesHandle, replotAfterFilterChangeFcn, 'DrawProgrammatically');
            
                            fieldsList = fields(filterTable.roi(ii).specification);
                            for jj = 1:numel(fieldsList)
                                roiHandle.(fieldsList{jj}) = filterTable.roi(ii).specification.(fieldsList{jj});
                            end
                    end
    
                    filterTable.roi(ii).handle = roiHandle;
                end
            end
        end

        %-----------------------------------------------------------------%
        function roiHandle = FilterRoiGraphic(filterSubtype, axesHandle, replotAfterFilterChangeFcn, varargin)
            switch filterSubtype
                case 'Threshold'
                    roiHandle = plot.ROI.draw('images.roi.Line', axesHandle, {'Tag', 'filterROI'});

                case 'PolygonKML'
                    shapeObj = varargin{1};
                    roiHandle = geoplot(axesHandle, shapeObj, FaceColor=[0 0.4470 0.7410], ...
                                                              EdgeColor=[0 0.4470 0.7410], ...
                                                              FaceAlpha=0.05,              ...
                                                              EdgeAlpha=1,                 ...
                                                              LineWidth=.5,                ...
                                                              PickableParts='none',        ...
                                                              Tag='filterROI');

                otherwise
                    drawType = varargin{1};
                    roiNameArgument = '';

                    switch drawType
                        case 'DrawInRealTime'
                            switch filterSubtype
                                case 'Circle'
                                    roiFunction = 'drawcircle';
                                case 'Rectangle'
                                    roiFunction = 'drawrectangle';
                                case 'Polygon'
                                    roiFunction = 'drawpolygon';
                            end

                        case 'DrawProgrammatically'
                            switch filterSubtype
                                case 'Circle'
                                    roiFunction = 'images.roi.Circle';
                                case 'Rectangle'
                                    roiFunction = 'images.roi.Rectangle';
                                case 'Polygon'
                                    roiFunction = 'images.roi.Polygon';
                            end
                    end

                    if strcmp(filterSubtype, 'Rectangle')
                        roiNameArgument = 'Rotatable=true, ';
                    end

                    roiHandle = eval(sprintf('%s(axesHandle, LineWidth=.5, FaceAlpha=0.05, Deletable=0, FaceSelectable=0, %sTag="filterROI");', roiFunction, roiNameArgument));
            end

            if isprop(roiHandle, 'DisplayName')
                switch filterSubtype
                    case 'Threshold'
                        displayName = 'Filtro de nível';
                    otherwise
                        displayName = 'Fitro geográfico';
                end

                roiHandle.DisplayName = displayName;
            end

            if isprop(roiHandle, 'InteractionsAllowed')
                roiHandle.InteractionsAllowed = 'none';

                if ~isempty(replotAfterFilterChangeFcn)
                    addlistener(roiHandle, 'MovingROI',            @(~, evt)plot.axes.Interactivity.CustomROIInteractionFcn(evt, axesHandle, []));
                    addlistener(roiHandle, 'ROIMoved',             @(src, evt)plot.axes.Interactivity.CustomROIInteractionFcn(evt, axesHandle, replotAfterFilterChangeFcn, src));
                    addlistener(roiHandle, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteROIListeners(src));
                end
            end
        end

        %-----------------------------------------------------------------%
        function Points(axesHandle, pointsTable, markerStyle, markerEdgeColor, markerSize)
            for ii = 1:height(pointsTable)
                if ~pointsTable.visible(ii)
                    continue
                end
            
                switch pointsTable.type{ii}
                    case 'RFDataHub'
                        coordinates = [pointsTable.value(ii).data.Latitude, pointsTable.value(ii).data.Longitude];
                        stationHandle = geoplot(axesHandle, coordinates(:,1), coordinates(:,2), ...
                            'LineStyle',       'none', ...
                            'LineWidth',       2, ...
                            'Marker',          markerStyle, ...
                            'MarkerSize',      markerSize, ...
                            'MarkerFaceColor', imageUtil.deriveFaceColor(markerEdgeColor), ...
                            'MarkerEdgeColor', markerEdgeColor, ...
                            'DisplayName',     'Pontos de interesse (RFDataHub)', ...
                            'Tag',             'points');
                        
                        plot.datatip.Template(stationHandle, 'Coordinates+Frequency', pointsTable.value(ii).data)
            
                    otherwise % 'FindPeaks'
                        coordinates = pointsTable.value(ii).data;
                        geoplot(axesHandle, coordinates(:,1), coordinates(:,2), ...
                            'LineStyle',       'none', ...
                            'LineWidth',       1, ...
                            'Marker',          markerStyle, ...
                            'MarkerSize',      markerSize, ...
                            'MarkerFaceColor', 'none', ...
                            'MarkerEdgeColor', markerEdgeColor, ...
                            'PickableParts',   'none', ...
                            'DisplayName',     'Pontos de interesse (FindPeaks)', ...
                            'Tag',             'points');
                end
            end
        end

        %-----------------------------------------------------------------%
        function ChannelPower(hAxes, tempBandObj, specRawTable, color, edgeAlpha, faceAlpha)
            arguments
                hAxes
                tempBandObj
                specRawTable
                color = '#ffff12'
                edgeAlpha = 0
                faceAlpha = .4
            end

            minY = bounds(specRawTable.ChannelPower);
            set(hAxes, 'XLim', [1, height(specRawTable)+.001], 'YLimMode', 'auto')

            chPowerLine  = area(hAxes, specRawTable.ChannelPower, minY, 'EdgeAlpha', edgeAlpha, ...
                                                                        'FaceAlpha', faceAlpha, ...
                                                                        'FaceColor', color,     ...
                                                                        'EdgeColor', color,     ...
                                                                        'Tag', 'channelPower');
            hAxes.YLim(1) = minY;
            plot.datatip.Template(chPowerLine, 'SweepID+ChannelPower', tempBandObj.LevelUnit)
        end
    end
end