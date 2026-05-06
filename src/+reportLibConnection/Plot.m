classdef (Abstract) Plot

    methods (Static = true)
        %-----------------------------------------------------------------%
        function imgFileName = Controller(reportInfo, analyzedData, imgSettings)
            arguments
                reportInfo
                analyzedData
                imgSettings
            end

            generalSettings = reportInfo.Settings;
            specData = analyzedData.InfoSet;
            emissionIdx = reportInfo.Function.var_IndexEmission;

            context = 'appAnalise:REPORT:BAND';
            if isfield(imgSettings, 'Context')
                context = imgSettings.Context;
            end

            bandObj = model.Band(context, reportInfo.App);
            updateSpectrumInfo(bandObj, specData, emissionIdx)

            % Container
            hFigure = reportInfo.App.UIFigure;
            hContainer = findobj(hFigure, 'Tag', 'reportGeneratorContainer');
            if isempty(hContainer)
                hContainer = reportLibConnection.Plot.ContainerCreation(hFigure);
            end

            if ~isempty(hContainer.Children)
                delete(hContainer.Children)
            end

            % Cria eixos de acordo com estabelecido no JSON.
            tiledPos = 1;
            tiledSpan = str2double(strsplit(imgSettings.Layout, ':'));
            tiledNames = strsplit(imgSettings.Name, ':');

            axesParent = tiledlayout(hContainer, sum(tiledSpan), 1, "Padding", "tight", "TileSpacing", "tight");           
            [axesType,   ...
             axesXLabel, ...
             axesYLabel, ...
             axesYScale] = plot.axes.axesTypeMapping(tiledNames, bandObj);

            for ii = 1:numel(tiledNames)
                xLabelFlag  = true;
                
                switch axesType{ii}
                    case 'Geographic'
                        axesHandle = plot.axes.Creation(axesParent, 'Geographic',  {'Basemap',  generalSettings.reportLib.basemap, ...
                                                                                    'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5]});

                        if ismember(generalSettings.plot.geographicAxes.Basemap, {'darkwater', 'none'})
                            axesHandle.Grid = 'on';
                        end
                    
                        set(axesHandle.LatitudeAxis,  'TickLabels', {}, 'Color', 'none')
                        set(axesHandle.LongitudeAxis, 'TickLabels', {}, 'Color', 'none')
                        
                        geolimits(axesHandle, 'auto')
                    
                        plot.axes.Colormap(axesHandle, generalSettings.plot.geographicAxes.Colormap)
                        plot.axes.Colorbar(axesHandle, generalSettings.plot.geographicAxes.Colorbar)

                        legend(axesHandle, 'Location', 'southwest', 'Color', [.94,.94,.94], 'EdgeColor', [.9,.9,.9], 'NumColumns', 4, 'LineWidth', .5, 'FontSize', 7.5, 'PickableParts', 'none')

                    case 'Cartesian'
                        axesHandle = plot.axes.Creation(axesParent, 'Cartesian', {'XColor', [.15,.15,.15], 'YColor', [.15,.15,.15], 'XLim', bandObj.XLimits, 'YLim', bandObj.YLimitsLevel});
                        if ~isscalar(tiledNames) && (ii < numel(tiledNames)) && any(strcmp(axesType(ii+1:end), 'Cartesian'))
                            xLabelFlag = false;
                        end
                end
                axesHandle.Layout.Tile     = tiledPos;
                axesHandle.Layout.TileSpan = [tiledSpan(ii) 1];
            
                % PLOT
                plotNames = strsplit(tiledNames{ii}, '+');
                for plotTag = plotNames
                    switch plotTag{1}
                        case {'minHold', 'average', 'maxHold'}
                            plot.draw2D.OrdinaryLine(axesHandle, plotTag{1}, bandObj);
    
                        case 'persistence'
                            plot.Persistence('Creation', [], axesHandle, bandObj);
    
                        case 'waterfall'
                            plot.Waterfall('Creation', [], axesHandle, bandObj);
                            plot.axes.Colorbar(axesHandle, 'eastoutside', {'Color', 'black'})
    
                        case 'bandLimits'
                            plot.draw2D.horizontalSetOfLines(axesHandle, bandObj, 'bandLimits')
                        
                        case 'channel'
                            channelTable  = specData.UserData.ReportChannels;
                            if isempty(channelTable)
                                channelTable = ChannelTable2Plot(reportInfo.App.channelObj, specData);
                                specData.UserData.ReportChannels = channelTable;
                            end

                            if ~isempty(channelTable)
                                plot.draw2D.horizontalSetOfLines(axesHandle, bandObj, 'Channel', channelTable)
                            end

                        case 'emission'
                            % plot.draw2D.horizontalSetOfLines(axesHandle, bandObj, 'emission')
                            plot.Emissions.TStyle(axesHandle, bandObj, 'emission')

                        % <PENDENTE MIGRAR PARA NOVAS FUNÇÕES>
                        case 'occupancyThreshold'
                            reportLibConnection.Plot.ThresholdPlot(axesHandle, bandObj, idxThread, reportInfo)

                        case 'occupancyPerBin'
                            reportLibConnection.Plot.OccupancyPerBin(axesHandle, bandObj, idxThread, reportInfo)
                            axesHandle.YLim = [0,100];

                        case 'emissionROI'
                            reportLibConnection.Plot.EmissionPlot(axesHandle, specData, yLim, Parameters)
    
                        case {'occMinHold', 'occAverage', 'occMaxHold'}
                            axesHandle.YLim = [0,100];

                        case 'occupancyPerChannel'
                            axesHandle.YLim = [0,100];

                        case 'driveTestHeatmap'
                            reportLibConnection.Plot.DriveTestPlot(axesHandle, bandObj, reportInfo)                         
    
                        case 'driveTestRoute'
                            plot.axes.Colorbar(axesHandle, 'off')
                            plot.DriveTest.Route(axesHandle, bandObj)
                    end
                end
                
                % POST-PLOT
                plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
                switch axesType{ii}
                    case 'Geographic'
                        % ...

                    case 'Cartesian'
                        % xAxes
                        axesHandle.XLim = bandObj.XLimits;

                        if xLabelFlag
                            xlabel(axesHandle, axesXLabel{ii})
                        else
                            axesHandle.XTickLabel = {};
                            xlabel(axesHandle, '')
                        end

                        % yAxes
                        if ~isempty(axesYScale{ii})
                            axesHandle.YScale = axesYScale{ii};
                        end

                        if ~isempty(axesYLabel{ii})
                            ylabel(axesHandle, axesYLabel{ii})
                        end
                end
                tiledPos = tiledPos+tiledSpan(ii);
            end
            drawnow

            % Espera renderizar e salva a imagem...
            defaultFilename = appEngine.util.DefaultFileName(generalSettings.fileFolder.tempPath, class.Constants.appName, reportInfo.Function.var_Issue);
            imgFileName     = sprintf('%s.%s', defaultFilename, generalSettings.reportLib.image.format);
            if ~ismember(reportInfo.Model.Version, {'final', 'Definitiva'})
                imgFileName = replace(imgFileName, 'Image', '~Image');
            end
            
            exportgraphics(hContainer, imgFileName, 'ContentType', 'image', 'Resolution', generalSettings.reportLib.image.resolutionDpi)
            
            while true
                pause(1)
                if isfile(imgFileName)
                    break
                end
            end

            delete(hContainer.Children)
        end

        %-----------------------------------------------------------------%
        function hContainer = ContainerCreation(hFigure)
            xWidth = class.Constants.windowSize(1);
            yHeight = class.Constants.windowSize(2);    
            hContainer = uipanel(hFigure, AutoResizeChildren='off',          ...
                                          Position=[100 100 xWidth yHeight], ...
                                          BorderType='none',                 ...
                                          BackgroundColor=[0 0 0],           ...
                                          Visible=0,                         ...
                                          Tag="reportGeneratorContainer");
        end

        %-----------------------------------------------------------------%
        function OccupancyPerBin(hAxes, bandObj, idx, reportInfo)
            defaultProperties = reportInfo.App.General_I;

            specData  = reportInfo.App.specData(idx);
            xArray    = bandObj.xArray;
            
            switch bandObj.Context
                case 'appAnalise:REPORT:CHANNEL'
                    idxChannel = reportInfo.General.Parameters.Plot.idxChannel;
                    
                    occTHR    = [specData.UserData.reportChannelAnalysis.("Threshold mínimo")(idxChannel), ...
                                 specData.UserData.reportChannelAnalysis.("Threshold máximo")(idxChannel)];
                    occOffset =  specData.UserData.reportChannelAnalysis.Offset(idxChannel);
                    xIndexLim = [specData.UserData.reportChannelAnalysis.("FCO per bin (%)"){idxChannel}.idx1, ...
                                 specData.UserData.reportChannelAnalysis.("FCO per bin (%)"){idxChannel}.idx2];
                    occData   =  specData.UserData.reportChannelAnalysis.("FCO per bin (%)"){idxChannel}.binFCO';

                    Occupancy  = defaultProperties.Plot.OccupancyPerBin;
                    plot(hAxes, xArray(xIndexLim(1):xIndexLim(2)), occData, 'Color',     Occupancy.Color,     ...
                                                                            'LineStyle', Occupancy.LineStyle, ...
                                                                            'LineWidth', Occupancy.LineWidth, ...
                                                                            'Tag', 'OccupancyPerBin');
                    ysecondarylabel(hAxes, sprintf('Threshold: [%.1f, %.1f] (Offset em relação ao piso de ruído: %d dB)', occTHR(1), occTHR(2), occOffset))

                otherwise
                    occMinHold = defaultProperties.Plot.occMinHold;
                    occAverage = defaultProperties.Plot.occAverage;
                    occMaxHold = defaultProperties.Plot.occMaxHold;

                    xIndexLim = bandObj.XLimitsIdxs;
                
                    reportLibConnection.Plot.OccupancyPerBinPlot(hAxes, specData(idx), xIndexLim, xArray, 'occMinHold', occMinHold)
                    reportLibConnection.Plot.OccupancyPerBinPlot(hAxes, specData(idx), xIndexLim, xArray, 'occAverage', occAverage)
                    reportLibConnection.Plot.OccupancyPerBinPlot(hAxes, specData(idx), xIndexLim, xArray, 'occMaxHold', occMaxHold)
            end
        end

        %-----------------------------------------------------------------%
        function OccupancyPerBinPlot(hAxes, SpecInfo, xIndexLim, xArray, plotMode, Occupancy)
            occIndex = SpecInfo.UserData.occMethod.CacheIndex;
            if isempty(occIndex)
                return
            end

            switch plotMode
                case 'occMinHold'; idx = 1;
                case 'occAverage'; idx = 2;
                case 'occMaxHold'; idx = 3;
            end

            occData = SpecInfo.UserData.occCache(occIndex).Data{3}(:,idx);

            switch Occupancy.Fcn
                case 'line'
                    p = plot(hAxes, xArray(xIndexLim(1):xIndexLim(2)), occData(xIndexLim(1):xIndexLim(2)), 'Tag', plotMode, 'LineStyle', Occupancy.LineStyle, 'LineWidth', Occupancy.LineWidth, 'Color', Occupancy.EdgeColor);
                case 'area'
                    p = area(hAxes, xArray(xIndexLim(1):xIndexLim(2)), occData(xIndexLim(1):xIndexLim(2)), 'Tag', plotMode, 'LineStyle', Occupancy.LineStyle, 'LineWidth', Occupancy.LineWidth, 'EdgeColor', Occupancy.EdgeColor, 'FaceColor', Occupancy.FaceColor, 'BaseValue', .1);
            end
            plot.datatip.Template(p, 'Frequency+Occupancy', '%%')
        end


        %-----------------------------------------------------------------%
        function EmissionPlot(hAxes, SpecInfo, yLim, ROI)
            pks = SpecInfo.UserData.Emissions;
            if ~isempty(pks)
                for ii = 1:height(pks)
                    if ischar(ROI.Color)
                        ROI.Color = hex2rgb(ROI.Color);
                    end
                    drawrectangle(hAxes, 'Position', [pks.Frequency(ii)-pks.BW_kHz(ii)/2000, yLim(1)+1, pks.BW_kHz(ii)/1000, diff(yLim)-2],                   ...
                                         'Color', ROI.Color, 'EdgeAlpha', ROI.EdgeAlpha, 'FaceAlpha', ROI.FaceAlpha, 'MarkerSize', 5, 'LineWidth', 1, ...
                                         'Deletable', 0, 'InteractionsAllowed', 'none', 'Tag', 'mkrROI');
                end

                NN = height(pks);
                pksLabel = string((1:NN)'); % Opcionalmente: "P_" + string((1:NN)')
                text(hAxes, pks.Frequency, repmat(yLim(1)+ROI.LabelOffset, NN, 1), pksLabel, ...
                           'Color', ROI.LabelColor, 'BackgroundColor', ROI.Color,            ...
                           'FontSize', ROI.LabelFontSize, 'FontWeight', 'bold',              ...
                           'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'PickableParts', 'none', 'Tag', 'mkrLabels');
            end
        end


        %-----------------------------------------------------------------%
        function ThresholdPlot(hAxes, bandObj, idx, reportInfo)
            defaultProperties = bandObj.callingApp.General_I;
            plotConfig = structUtil.struct2cellWithFields(defaultProperties.Plot.OccupancyThreshold);

            specData = bandObj.callingApp.specData(idx);
            xArray   = bandObj.xArray;

            switch bandObj.Context
                case 'appAnalise:REPORT:CHANNEL'
                    idxChannel = reportInfo.General.Parameters.Plot.idxChannel;
                    
                    occMethod = 'Linear adaptativo';
                    occTHR    = [specData.UserData.reportChannelAnalysis.("Threshold mínimo")(idxChannel), ...
                                 specData.UserData.reportChannelAnalysis.("Threshold máximo")(idxChannel)];

                otherwise
                    occIndex  = specData.UserData.occMethod.CacheIndex;
                    if isempty(occIndex)
                        return
                    end
        
                    occMethod = specData.UserData.occCache(occIndex).Info.Method;
                    occTHR    = specData.UserData.occCache(occIndex).THR;
            end

            switch occMethod
                case {'Linear fixo (COLETA)', 'Linear fixo'}
                    p    = plot(hAxes, [xArray(1), xArray(end)], [occTHR, occTHR]);
                case 'Linear adaptativo'
                    [minTHR, maxTHR] = bounds(occTHR);
                    p(1) = plot(hAxes, [xArray(1), xArray(end)], [minTHR, minTHR]);
                    p(2) = plot(hAxes, [xArray(1), xArray(end)], [maxTHR, maxTHR]);
                case 'Envoltória do ruído'
                    p    = plot(hAxes, xArray, occTHR);
            end
            arrayfun(@(x) set(x, 'MarkerIndices', [1, numel(x.XData)], 'Tag', 'OccupancyThreshold', plotConfig{:}), p)
        end

        %-----------------------------------------------------------------%
        function DriveTestPlot(axesHandle, bandObj, reportInfo)
            specData = bandObj.SpecData;
            emissionIdx = reportInfo.Function.var_IndexEmission;

            driveTestAttributes = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest;

            % Density | Distortion
            dataSource = driveTestAttributes.PlotDisplayConfig.Data.Source;
            switch dataSource
                case 'Dados brutos'
                    tableSource = driveTestAttributes.Measures.filtered;
                
                case 'Processados'
                    tableSource = driveTestAttributes.Measures.binned;

                otherwise
                    error('reportLibConnection:Plot:UnexpectedDataSource', 'Unexpected data source "%s"', dataSource)
            end

            if ~strcmp(axesHandle.Basemap, driveTestAttributes.PlotDisplayConfig.Basemap)
                axesHandle.Basemap = driveTestAttributes.PlotDisplayConfig.Basemap;
            end
            colormap(axesHandle, driveTestAttributes.PlotDisplayConfig.Colormap)

            plot.DriveTest.DistortionAndDensityPlot(axesHandle, bandObj, tableSource, driveTestAttributes.PlotDisplayConfig.Data.PlotMode, driveTestAttributes.PlotDisplayConfig.Data.PlotSize)
            plot.axes.StackingOrder.execute(axesHandle, 'appAnalise:DRIVETEST')

            % Points
            pointsTable = driveTestAttributes.Points;
            if ~isempty(pointsTable)
                markerStyle = driveTestAttributes.PlotDisplayConfig.Points.Marker;
                markerColor = driveTestAttributes.PlotDisplayConfig.Points.Color;
                markerSize  = driveTestAttributes.PlotDisplayConfig.Points.Size;
                plot.DriveTest.Points(axesHandle, pointsTable, markerStyle, markerColor, markerSize)
            end

            % Filters
            filterTable = driveTestAttributes.Filters;
            if ~isempty(filterTable)
                for ii = 1:height(filterTable)
                    filterSubtype = filterTable.subtype{ii};

                    switch filterSubtype
                        case 'PolygonKML'
                            lat = filterTable.roi(ii).specification.Latitude;
                            lng = filterTable.roi(ii).specification.Longitude;
                            shapeObj = geopolyshape(lat, lng);

                            geoplot(axesHandle, shapeObj, FaceColor=[0 0.4470 0.7410], ...
                                                          EdgeColor=[0 0.4470 0.7410], ...
                                                          FaceAlpha=0.05,              ...
                                                          EdgeAlpha=1,                 ...
                                                          LineWidth=1,               ...
                                                          PickableParts='none',        ...
                                                          Tag='filterROI');

                        case {'Circle', 'Rectangle', 'Polygon'}
                            switch filterSubtype
                                case 'Circle';     roiFcn = 'images.roi.Circle';
                                case 'Rectangle';  roiFcn = 'images.roi.Rectangle';
                                case 'Polygon';    roiFcn = 'images.roi.Polygon';
                            end
        
                            roiHandle = evalc(sprintf('%s(hAxes, LineWidth=1, FaceAlpha=0.05, Deletable=0, FaceSelectable=0, InteractionsAllowed="none", Tag="filterROI");', roiFcn));

                            fieldsList = fieldnames(filterTable.roi(ii).specification);
                            for jj = 1:numel(fieldsList)
                                roiHandle.(fieldsList{jj}) = filterTable.roi(ii).specification.(fieldsList{jj});
                            end

                        otherwise
                            error('reportLibConnection:Plot:UnexpectedFilterSubtype', 'Unexpected filter subtype "%s"', filterSubtype)
                    end
                end
            end
        end
    end
end