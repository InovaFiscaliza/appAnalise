function varargout = Config(plotTag, defaultProperties)
    arguments
        plotTag
        defaultProperties % "GeneralSettings.json"
    end

    tempPlotConfig = defaultProperties.plot.(plotTag);

    switch plotTag
        case 'waterfall'
            switch tempPlotConfig.Function
                case 'mesh'
                    plotConfig = {'MeshStyle', tempPlotConfig.MeshStyle, 'SelectionHighlight', 'off'};
                case 'image'
                    plotConfig = {'CDataMapping', 'scaled'};
            end

            if ~issorted(tempPlotConfig.LevelLimits, 'strictascend') || (tempPlotConfig.LevelLimits(1) == 0 && tempPlotConfig.LevelLimits(2) == 1)
                tempPlotConfig.LevelLimits = [];
            end

            varargout   = {plotConfig, tempPlotConfig.Function, tempPlotConfig.Decimation, tempPlotConfig.Colormap, tempPlotConfig.LevelLimits};

        case 'waterfallTime'
            plotType    = 'line';
            plotConfig  = {'Color', 'red', 'LineWidth', 1, 'PickableParts', 'none', 'Visible', tempPlotConfig.Visible, 'ZData', tempPlotConfig.ZData};
            varargout   = {plotConfig, plotType};

        case {'BandLimits', 'Channel', 'Emission'}
            plotConfig  = textFormatGUI.struct2cellArray(rmfield(tempPlotConfig, {'YLimOffsetMode', 'YLimOffset', 'StepEffect'}));
            varargout   = {plotConfig, tempPlotConfig.YLimOffsetMode, tempPlotConfig.YLimOffset, tempPlotConfig.StepEffect};

        case {'EmissionROI', 'ChannelROI'}
            if ischar(tempPlotConfig.Color)
                tempPlotConfig.Color = hex2rgb(tempPlotConfig.Color);
            end

            plotConfig     = {'Color', tempPlotConfig.Color, 'MarkerSize', tempPlotConfig.MarkerSize, 'LineWidth', tempPlotConfig.LineWidth, 'EdgeAlpha', tempPlotConfig.EdgeAlpha, 'FaceAlpha', tempPlotConfig.FaceAlpha, 'Deletable', 0, 'FaceSelectable', 0};
            plotConfigText = {'Color', tempPlotConfig.LabelColor, 'BackgroundColor', tempPlotConfig.Color, 'FontSize', tempPlotConfig.LabelFontSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'PickableParts', 'none', 'Tag', plotTag};
            varargout      = {plotConfig, plotConfigText, tempPlotConfig.LabelOffsetMode, tempPlotConfig.LabelOffset};

        case {'clearWrite', 'average', 'minHold', 'maxHold'}
            switch tempPlotConfig.Function
                case 'line'
                    tempPlotConfig = rmfield(tempPlotConfig, {'EdgeColor', 'FaceColor'});
                case 'area'
                    tempPlotConfig = rmfield(tempPlotConfig, {'Color'});
                otherwise
                    error('plot:Config:UnexpectedFunction', 'Unexpected plot function "%s"', tempPlotConfig.Function)
            end

            plotType   = tempPlotConfig.Function;
            plotConfig = structUtil.struct2cellWithFields(rmfield(tempPlotConfig, 'Function'));
            varargout  = {plotConfig, plotType};
    end

    varargout{1} = [varargout{1}, {'Tag', plotTag}];
end