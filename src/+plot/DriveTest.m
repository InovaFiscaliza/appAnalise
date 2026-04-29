classdef (Abstract) DriveTest

    methods (Static = true)
        %-----------------------------------------------------------------%
        function Route(hAxes, tempBandObj, varargin)
            switch tempBandObj.Context
                case 'appAnalise:REPORT:BAND'
                    if hAxes.Basemap == "none"
                        hAxes.Basemap = 'streets-light';
                    end

                    idxThread  = varargin{1};
                    specData   = tempBandObj.callingApp.specData(idxThread);
        
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
        function Filters(app)
            % Migrar para essa classe funções de auxApp.DriveTest:
            % - plot_FiltersController(app)
            % - hROI = plot_FilterROIObject(app, callingFcn, FilterSubtype, hAxes, varargin)

            % Organizar código de forma a ser consumido pelo modo RELATÓRIO,
            % atualmente em:
            % - plot.old_axesDraw.DriveTestFilterPlot(hAxes, Parameters, plotType)
            % 
        end

        %-----------------------------------------------------------------%
        function Points(hAxes, pointsTable, MarkerStyle, MarkerColor, MarkerSize)
            for ii = 1:height(pointsTable)
                if ~pointsTable.visible(ii)
                    continue
                end
            
                switch pointsTable.type{ii}
                    case 'RFDataHub'
                        Coordinates = [pointsTable.value(ii).Data.Latitude, pointsTable.value(ii).Data.Longitude];
                        hStation    = geoplot(hAxes, Coordinates(:,1), Coordinates(:,2), ...
                            'LineStyle',       'none',       ...
                            'Color',           MarkerColor,  ...
                            'Marker',          MarkerStyle,  ...
                            'MarkerSize',      MarkerSize,   ...
                            'MarkerFaceColor', MarkerColor,  ...
                            'MarkerEdgeColor', MarkerColor,  ...
                            'DisplayName',     'Pontos de interesse (RFDataHub)', ...
                            'Tag',             'points');
                        plot.datatip.Template(hStation, 'Coordinates+Frequency', pointsTable.value(ii).Data)
            
                    case 'FindPeaks'
                        Coordinates = pointsTable.value(ii).Data;
                        hFindPeaks  = geoplot(hAxes, Coordinates(:,1), Coordinates(:,2), ...
                            'LineStyle',       'none',      ...
                            'Color',           MarkerColor, ...
                            'Marker',          MarkerStyle, ...
                            'MarkerSize',      MarkerSize,  ...
                            'MarkerFaceColor', 'none',      ...
                            'MarkerEdgeColor', MarkerColor, ...
                            'PickableParts',   'none',      ...
                            'DisplayName',     'Pontos de interesse (FindPeaks)', ...
                            'Tag',             'points');
                        % plot.datatip.Template(hFindPeaks, 'Coordinates', pointsTable.value(ii).Data)
                end
            end
        end

        %-----------------------------------------------------------------%
        function ChannelPower(hAxes, tempBandObj, specRawTable, Color, EdgeAlpha, FaceAlpha)
            minY = bounds(specRawTable.ChannelPower);
            set(hAxes, 'XLim', [1, height(specRawTable)+.001], 'YLimMode', 'auto')

            chPowerLine  = area(hAxes, specRawTable.ChannelPower, minY, 'EdgeAlpha', EdgeAlpha, ...
                                                                        'FaceAlpha', FaceAlpha, ...
                                                                        'FaceColor', Color,     ...
                                                                        'EdgeColor', Color,     ...
                                                                        'Tag', 'channelPower');
            hAxes.YLim(1) = minY;
            plot.datatip.Template(chPowerLine, 'SweepID+ChannelPower', tempBandObj.LevelUnit)
        end
    end
end