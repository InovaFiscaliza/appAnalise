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
            channelIdx = reportInfo.Function.var_IndexChannel;

            context = 'appAnalise:REPORT:BAND';
            if isfield(imgSettings, 'Context')
                context = imgSettings.Context;
            end

            bandObj = model.Band(context, reportInfo.App);
            switch context
                case 'appAnalise:DRIVETEST'
                    guardBand = {struct('Mode', 'manual', 'Parameters', struct('Type', 'BWRelated', 'Value', 6))};
                    updateSpectrumInfo(bandObj, specData, emissionIdx, guardBand{:})
                
                case 'appAnalise:REPORT:CHANNEL'
                    updateSpectrumInfo(bandObj, specData, channelIdx)

                otherwise % 'appAnalise:PLAYBACK', 'appAnalise:SIGNALANALYSIS' | 'appAnalise:REPORT:BAND' | 'appAnalise:REPORT:EMISSION'
                    updateSpectrumInfo(bandObj, specData, emissionIdx)
            end

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
                                                                                    'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                                    'Grid', 'on', 'TickDir', 'in', 'Box', 'on', 'FontSize', 7});

                        axesHandle.LatitudeAxis.Color = [.2,.2,.2];
                        axesHandle.LongitudeAxis.Color = [.2,.2,.2];
                        
                        geolimits(axesHandle, 'auto')
                    
                        plot.axes.Colormap(axesHandle, generalSettings.plot.geographicAxes.Colormap)

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
                                plot.draw2D.horizontalSetOfLines(axesHandle, bandObj, 'channel', channelTable)
                            end

                        case 'emission'
                            plot.Emissions.TStyle(axesHandle, bandObj, 'emission')

                        % <PENDENTE MIGRAR PARA NOVAS FUNÇÕES>
                        case 'occupancyThreshold'
                            reportLibConnection.Plot.ThresholdPlot(axesHandle, bandObj, specData, reportInfo)

                        case 'occupancyPerBin'
                            reportLibConnection.Plot.OccupancyPerBin(axesHandle, bandObj, specData, reportInfo)
                            axesHandle.YLim = [0,100];

                        case 'emissionROI'
                            reportLibConnection.Plot.EmissionPlot(axesHandle, specData, yLim, Parameters)
    
                        case {'occMinHold', 'occAverage', 'occMaxHold'}
                            axesHandle.YLim = [0,100];

                        case 'occupancyPerChannel'
                            axesHandle.YLim = [0,100];

                        case 'driveTestRoute'
                            plot.axes.Colorbar(axesHandle, 'eastoutside')
                            cb = findobj(axesHandle.Parent.Children, 'Type', 'colorbar');
                            if ~isempty(cb)
                                cb.Visible = 'off';
                            end

                            plot.DriveTest.Route(axesHandle, bandObj)
                        
                        case 'driveTestHeatmap'
                            axesHandle = reportLibConnection.Plot.DriveTestHeatmap(axesParent, axesHandle, bandObj, reportInfo, generalSettings);
                    end
                end
                
                % POST-PLOT
                plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
                switch axesType{ii}
                    case 'Geographic'
                        % Força renderização do basemap usando função waitfor
                        % customizada, evitando, assim, o risco de parar a
                        % execução (no caso de uso da MATLAB built-in waitfor).

                        % Protegido por bloco try/catch porque o basemap não 
                        % é informação essencial do plot e esse approach de usar 
                        % o objeto "TileReader" é algo não documentado, sujeito 
                        % a alterações pela Mathworks.
                        try
                            tilesController = struct(axesHandle).BasemapManager.TileReader;
                            if ~tilesController.MapTileAcquired && tilesController.NumMapTilesInCache == 0
                                % waitfor(tilesController, 'NumMapTilesInCache')
                                matlab.waitfor(tilesController, 'NumMapTilesInCache', @(x) x~=0, .100, 10)
                            end
                        catch
                        end

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
        function OccupancyPerBin(hAxes, bandObj, specData, reportInfo)
            defaultProperties = reportInfo.App.General_I;
            xArray = bandObj.XArray;
            
            switch bandObj.Context
                case 'appAnalise:REPORT:CHANNEL'
                    channelIdx = reportInfo.Function.var_IndexChannel;
                    
                    occTHR    = [specData.UserData.ReportChannelAnalysisResult.("Threshold mínimo")(channelIdx), ...
                                 specData.UserData.ReportChannelAnalysisResult.("Threshold máximo")(channelIdx)];
                    occOffset =  specData.UserData.ReportChannelAnalysisResult.Offset(channelIdx);
                    xIndexLim = [specData.UserData.ReportChannelAnalysisResult.("FCO per bin (%)"){channelIdx}.idx1, ...
                                 specData.UserData.ReportChannelAnalysisResult.("FCO per bin (%)"){channelIdx}.idx2];
                    occData   =  specData.UserData.ReportChannelAnalysisResult.("FCO per bin (%)"){channelIdx}.binFCO';

                    Occupancy  = defaultProperties.plot.occupancyPerBin;
                    plot(hAxes, xArray(xIndexLim(1):xIndexLim(2)), occData, 'Color',     Occupancy.Color,     ...
                                                                            'LineStyle', Occupancy.LineStyle, ...
                                                                            'LineWidth', Occupancy.LineWidth, ...
                                                                            'Tag', 'occupancyPerBin');
                    ysecondarylabel(hAxes, sprintf('Threshold: [%.1f, %.1f] (Offset em relação ao piso de ruído: %d dB)', occTHR(1), occTHR(2), occOffset))

                otherwise
                    occMinHold = defaultProperties.plot.occMinHold;
                    occAverage = defaultProperties.plot.occAverage;
                    occMaxHold = defaultProperties.plot.occMaxHold;

                    xIndexLim = bandObj.XLimitsIdxs;
                
                    reportLibConnection.Plot.OccupancyPerBinPlot(hAxes, specData, xIndexLim, xArray, 'occMinHold', occMinHold)
                    reportLibConnection.Plot.OccupancyPerBinPlot(hAxes, specData, xIndexLim, xArray, 'occAverage', occAverage)
                    reportLibConnection.Plot.OccupancyPerBinPlot(hAxes, specData, xIndexLim, xArray, 'occMaxHold', occMaxHold)
            end
        end

        %-----------------------------------------------------------------%
        function OccupancyPerBinPlot(hAxes, specData, xIndexLim, xArray, plotMode, Occupancy)
            occIndex = specData.UserData.OccupancyComputationMode.CacheIndex;
            if isempty(occIndex)
                return
            end

            switch plotMode
                case 'occMinHold'; idx = 1;
                case 'occAverage'; idx = 2;
                case 'occMaxHold'; idx = 3;
            end

            occData = specData.UserData.OccupancyFiniteIntegrationCache(occIndex).Data{3}(:,idx);

            switch Occupancy.Fcn
                case 'line'
                    p = plot(hAxes, xArray(xIndexLim(1):xIndexLim(2)), occData(xIndexLim(1):xIndexLim(2)), 'Tag', plotMode, 'LineStyle', Occupancy.LineStyle, 'LineWidth', Occupancy.LineWidth, 'Color', Occupancy.EdgeColor);
                case 'area'
                    p = area(hAxes, xArray(xIndexLim(1):xIndexLim(2)), occData(xIndexLim(1):xIndexLim(2)), 'Tag', plotMode, 'LineStyle', Occupancy.LineStyle, 'LineWidth', Occupancy.LineWidth, 'EdgeColor', Occupancy.EdgeColor, 'FaceColor', Occupancy.FaceColor, 'BaseValue', .1);
            end
            plot.datatip.Template(p, 'Frequency+Occupancy', '%%')
        end


        %-----------------------------------------------------------------%
        function EmissionPlot(hAxes, specData, yLim, ROI)
            pks = specData.UserData.Emissions;
            if ~isempty(pks)
                for ii = 1:height(pks)
                    if ischar(ROI.Color)
                        ROI.Color = hex2rgb(ROI.Color);
                    end
                    drawrectangle(hAxes, 'Position', [pks.Frequency(ii)-pks.BandWidthkHz(ii)/2000, yLim(1)+1, pks.BandWidthkHz(ii)/1000, diff(yLim)-2],                   ...
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
        function ThresholdPlot(hAxes, bandObj, specData, reportInfo)
            defaultProperties = reportInfo.App.General_I;
            plotConfig = structUtil.struct2cellWithFields(defaultProperties.plot.occupancyThreshold);
            xArray = bandObj.XArray;

            switch bandObj.Context
                case 'appAnalise:REPORT:CHANNEL'
                    channelIdx = reportInfo.Function.var_IndexChannel;
                    occMethod  = 'Linear adaptativo';
                    occTHR     = [specData.UserData.ReportChannelAnalysisResult.("Threshold mínimo")(channelIdx), ...
                                  specData.UserData.ReportChannelAnalysisResult.("Threshold máximo")(channelIdx)];

                otherwise
                    occIndex  = specData.UserData.OccupancyComputationMode.CacheIndex;
                    if isempty(occIndex)
                        return
                    end
        
                    occMethod = specData.UserData.OccupancyFiniteIntegrationCache(occIndex).Method;
                    occTHR    = specData.UserData.OccupancyFiniteIntegrationCache(occIndex).Threshold;
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

            arrayfun(@(x) set(x, 'MarkerIndices', [1, numel(x.XData)], 'Tag', 'occupancyThreshold', plotConfig{:}), p)
        end

        %-----------------------------------------------------------------%
        function axesHandle = DriveTestHeatmap(hParent, axesHandle, bandObj, reportInfo, generalSettings)
            % Replica plot apresentado no módulo "DRIVETEST".
            delete(axesHandle)
            set(hParent, 'GridSize', [24, 16], 'Padding', 'none', 'TileSpacing', 'none', 'Position', [0, 0, 1, 1])

            % Eixo geográfico: MAPA
            axesHandle = plot.axes.Creation(hParent, 'Geographic', {'Basemap', generalSettings.reportLib.basemap,                ...
                                                                     'Color',    [.2, .2, .2], 'GridColor', [.5, .5, .5], ...
                                                                     'UserData', struct('CLimMode', 'auto', 'Colormap', '', 'PlotMode', 'distortion')});
            axesHandle.Layout.Tile = 1;
            axesHandle.Layout.TileSpan = [24, 12];

            % Eixo cartesiano: ESPECTRO
            uiAxes2 = plot.axes.Creation(hParent, 'Cartesian', {'XColor', 'white', 'XGrid', 1, 'XMinorGrid', 0, 'XTick', {}, 'XTickLabel', {}, ...
                                                                    'YColor', 'white', 'YGrid', 0, 'YMinorGrid', 0, 'YTick', {},                   ...
                                                                    'Layer', 'top', 'GridLineStyle', '-.', 'TickDir', 'none',                      ...
                                                                    'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            uiAxes2.Layout.Tile = 13;
            uiAxes2.Layout.TileSpan = [6, 4];

            % Eixo cartesiano: WATERFALL
            uiAxes3 = plot.axes.Creation(hParent, 'Cartesian', {'XColor', 'white', 'XGrid', 1, 'XMinorGrid', 0, 'XTick', {}, 'XTickLabel', {}, ...
                                                                    'YColor', 'white', 'YGrid', 1, 'YMinorGrid', 0, 'YTick', {}, 'YTickLabel', {}, ...
                                                                    'Layer', 'top', 'GridLineStyle', '-.', 'TickDir', 'in',                        ...
                                                                    'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            uiAxes3.Layout.Tile = 109;
            uiAxes3.Layout.TileSpan = [18, 4];

            % Eixo cartesiano: POTÊNCIA DO CANAL
            uiAxes4 = plot.axes.Creation(hParent, 'Cartesian', {'XColor', 'white', 'XGrid', 1, 'XMinorGrid', 0,              ...
                                                                    'YColor', 'white', 'YGrid', 0, 'YMinorGrid', 0, 'YTick', {}, ...
                                                                    'GridLineStyle', '-.', 'TickDir', 'both', 'Color', 'none',   ...
                                                                    'HitTest', 'off',                                            ...
                                                                    'UserData', struct('YLimUnit', 'dBm')});
            uiAxes4.Layout.Tile = 112;
            uiAxes4.Layout.TileSpan = [18, 1];
            uiAxes4.View = [270, 90];
            uiAxes4.YAxis.Direction = "reverse";

            % Colorbar
            colorBar = colorbar(axesHandle, "Location", "layout", "TickDirection", "none", "PickableParts", "none", "FontSize", 7, "Color", "white", 'AxisLocation', 'in', 'Box', 'off');
            colorBar.Layout.Tile = 284;
            colorBar.Layout.TileSpan = [6,1];

            % Interações
            linkaxes([uiAxes2, uiAxes3], 'x')
            
            % % PLOT 
            specData = bandObj.SpecData;
            emissionIdx = reportInfo.Function.var_IndexEmission;

            chFrequency = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.Frequency;
            chBandWidth = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW;
            emissionTag = sprintf('%.3f MHz ⌂ %.1f kHz', chFrequency, chBandWidth);

            if isempty(axesHandle.Legend)
                pause(1)
                lgd = legend(axesHandle, 'Location', 'southwest', 'Color', [.94,.94,.94], 'BackgroundAlpha', 0.9, 'EdgeColor', [.9,.9,.9], 'NumColumns', 1, 'LineWidth', .5, 'FontSize', 7.5, 'PickableParts', 'none');
                lgd.Title.FontSize = 8.5;
            end
            set(axesHandle.Legend.Title, 'Visible', 'on', 'String', emissionTag)

            % Route && Density | Distortion
            driveTestAttributes = specData.UserData.Emissions.AuxAppData(emissionIdx).DriveTest;

            outTable  = driveTestAttributes.Measures.raw(~driveTestAttributes.Measures.raw.Filtered, :);
            inTable   = driveTestAttributes.Measures.raw;
            lineStyle = ':';
            outColor  = [0.502, 0.502, 0.502];
            inColor   = [0.8706, 0.5412, 0.5412];
            markerSize= 1;

            plot.DriveTest.Route(axesHandle, bandObj, outTable, inTable, lineStyle, outColor, inColor, markerSize)

            dataSource = driveTestAttributes.PlotDisplayConfig.Data.Source;
            switch dataSource
                case {'Raw', 'Filtered', 'Dados brutos'}
                    srcTable = driveTestAttributes.Measures.filtered;
                
                otherwise % 'Data-Binning' | 'Processados'
                    srcTable = driveTestAttributes.Measures.binned;
            end

            if ~strcmp(axesHandle.Basemap, driveTestAttributes.PlotDisplayConfig.Basemap)
                axesHandle.Basemap = driveTestAttributes.PlotDisplayConfig.Basemap;
            end
            colormap(axesHandle, driveTestAttributes.PlotDisplayConfig.Colormap)

            plot.DriveTest.DistortionAndDensityPlot(axesHandle, bandObj, srcTable, driveTestAttributes.PlotDisplayConfig.Data.PlotMode, driveTestAttributes.PlotDisplayConfig.Data.PlotSize)

            
            % (b) ClearWrite+Persistance
            plot.draw2D.OrdinaryLine(uiAxes2, 'average', bandObj, []);
            plot.Persistence('Creation', [], uiAxes2, bandObj, []);
            set(uiAxes2, 'XLim', bandObj.XLimits, 'YLim', bandObj.YLimitsLevel)

            % (c) Waterfall
            plot.Waterfall('Creation', [], uiAxes3, bandObj, bandObj.XLimits);

            % (d) ChannelPower
            plot.DriveTest.ChannelPower(uiAxes4, bandObj, driveTestAttributes.Measures.raw)

            % (e) ChannelROI
            chFreqCenter = specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.Frequency;
            chBandWidth  = max(10, specData.UserData.Emissions.ChannelAssigned(emissionIdx).UserModified.ChannelBW);

            srcROITable = table(chFreqCenter, chBandWidth, 'VariableNames', {'Frequency', 'BandWidthkHz'});
            postPlotConfig = { ...
                'InteractionsAllowed', 'none', ...
                'Color', hex2rgb("#b746ff"), ...
                'EdgeAlpha', 0, ...
                'FaceAlpha', .4 ...
            };
            
            plot.draw2D.rectangularROI(uiAxes2, bandObj, srcROITable, 1, 'channelROI', postPlotConfig, [-1000, 1000])
            plot.draw2D.rectangularROI(uiAxes3, bandObj, srcROITable, 1, 'channelROI', postPlotConfig)

            % (f) Filters
            filterTable = driveTestAttributes.Filters;
            plot.DriveTest.FilterRegions(filterTable, axesHandle, uiAxes4);

            % (g) Points
            pointsTable = driveTestAttributes.Points;
            if ~isempty(pointsTable)
                markerStyle = driveTestAttributes.PlotDisplayConfig.Points.Marker;
                markerColor = driveTestAttributes.PlotDisplayConfig.Points.Color;
                markerSize  = driveTestAttributes.PlotDisplayConfig.Points.Size;
                plot.DriveTest.Points(axesHandle, pointsTable, markerStyle, markerColor, markerSize)
            end
        end
    end
end