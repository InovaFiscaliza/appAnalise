function varargout = Config(plotTag, defaultProperties, customProperties, Context)
    arguments
        plotTag
        defaultProperties     % "GeneralSettings.json"        
        customProperties = [] % Customização disponibilizada no modo PLAYBACK do app
        Context          = ''
    end

    selectedProperties  = customPropertiesParser(plotTag, defaultProperties, customProperties, Context);
    tempPlotConfig      = selectedProperties.plot.(plotTag);

    switch plotTag
        case 'persistence'
            plotConfig  = {'CDataMapping', 'scaled', 'PickableParts', 'none', 'Interpolation', tempPlotConfig.Interpolation};

            % Aspectos relacionados ao cLim da curva de persistência:
            % (a) O arquivo "GeneralSettings.json" tem como padrão o vetor [-1,-1]. 
            % (b) A customização desse parâmetro é possível apenas quando o tamanho 
            %     da janela da persistência é "full". 
            if ~issorted(tempPlotConfig.LevelLimits, 'strictascend') || (tempPlotConfig.LevelLimits(1) == 0 && tempPlotConfig.LevelLimits(2) == 1) || ~strcmp(tempPlotConfig.WindowSize, 'full')
                tempPlotConfig.LevelLimits = [];
            end

            varargout   = {plotConfig, tempPlotConfig.WindowSize, tempPlotConfig.Colormap, tempPlotConfig.Transparency, tempPlotConfig.LevelLimits};

        case 'waterfall'
            switch tempPlotConfig.Fcn
                case 'mesh'
                    plotConfig = {'MeshStyle', tempPlotConfig.MeshStyle, 'SelectionHighlight', 'off'};
                case 'image'
                    plotConfig = {'CDataMapping', 'scaled'};
            end

            if ~issorted(tempPlotConfig.LevelLimits, 'strictascend') || (tempPlotConfig.LevelLimits(1) == 0 && tempPlotConfig.LevelLimits(2) == 1)
                tempPlotConfig.LevelLimits = [];
            end

            varargout   = {plotConfig, tempPlotConfig.Fcn, tempPlotConfig.Decimation, tempPlotConfig.Colormap, tempPlotConfig.LevelLimits};

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
            switch tempPlotConfig.Fcn
                case 'line'
                    tempPlotConfig = rmfield(tempPlotConfig, {'EdgeColor', 'FaceColor'});
                case 'area'
                    tempPlotConfig = rmfield(tempPlotConfig, {'Color'});
                otherwise
                    error('UnexpectedPlotType')
            end

            plotType   = tempPlotConfig.Fcn;
            plotConfig = structUtil.struct2cellWithFields(rmfield(tempPlotConfig, 'Fcn'));
            varargout  = {plotConfig, plotType};
    end

    varargout{1} = [varargout{1}, {'Tag', plotTag}];
end


%-------------------------------------------------------------------------%
function selectedProperties = customPropertiesParser(plotTag, defaultProperties, customProperties, Context)
    arguments
        plotTag 
        defaultProperties 
        customProperties 
        Context = ''
    end

    selectedProperties = defaultProperties;

    if ~isempty(customProperties)
        if ismember(plotTag, {'persistence', 'waterfall', 'waterfallTime'}) && ~strcmp(Context, 'appAnalise:DRIVETEST')
            selectedProperties.plot.(plotTag) = customProperties.(plotTag);
        end
    end
end