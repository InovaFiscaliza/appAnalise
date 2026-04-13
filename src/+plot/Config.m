function varargout = Config(plotTag, defaultProperties)
    arguments
        plotTag
        defaultProperties % "GeneralSettings.json"
    end

    tempPlotConfig = defaultProperties.plot.(plotTag);

    switch plotTag
        case 'waterfallTime'
            plotType    = 'line';
            plotConfig  = {'Color', tempPlotConfig.Color, 'LineWidth', 1, 'PickableParts', 'none', 'ZData', tempPlotConfig.ZData};
            varargout   = {plotConfig, plotType};

        case {'bandLimits', 'channel', 'emission'}
            plotConfig  = textFormatGUI.struct2cellArray(rmfield(tempPlotConfig, {'YLimOffsetMode', 'YLimOffset', 'StepEffect'}));
            varargout   = {plotConfig, tempPlotConfig.YLimOffsetMode, tempPlotConfig.YLimOffset, tempPlotConfig.StepEffect};

        case {'emissionROI', 'channelROI'}
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