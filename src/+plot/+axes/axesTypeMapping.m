function [axesType, axesXLabel, axesYLabel, axesYScale] = axesTypeMapping(plotNamesPerAxes, tempBandObj)

    axesType   = {};
    axesXLabel = {};
    axesYLabel = {};
    axesYScale = {};

    for ii = 1:numel(plotNamesPerAxes)
        plotNames = strsplit(plotNamesPerAxes{ii}, '+');

        switch plotNames{1}
            case {'driveTestRoute', ...
                  'driveTestHeatmap', ...
                  'stations'}
                axesType{ii}   = 'Geographic';
                axesXLabel{ii} = '';
                axesYLabel{ii} = '';
                axesYScale{ii} = '';
            
            case {'minHold',             ...
                  'average',             ...
                  'clearWrite',          ...
                  'maxHold',             ...
                  'persistence',         ...
                  'channel',             ...
                  'emission',            ...
                  'emissionROI'}
                axesType{ii}   = 'Cartesian';
                axesXLabel{ii} = 'Frequência (MHz)';
                axesYScale{ii} = '';

                switch tempBandObj.LevelUnit
                    case 'dBm'
                        axesYLabel{ii} = 'Potência (dBm)';
                    otherwise
                        axesYLabel{ii} = sprintf('Nível (%s)', tempBandObj.LevelUnit);
                end
            
            case {'occupancyPerBin', ...
                  'occupancyPerChannel'}
                axesType{ii}   = 'Cartesian';
                axesXLabel{ii} = 'Frequência (MHz)';
                axesYLabel{ii} = 'Ocupação (%)';
                axesYScale{ii} = 'log';
            
            case 'waterfall'
                axesType{ii}   = 'Cartesian';
                axesXLabel{ii} = 'Frequência (MHz)';
                axesYLabel{ii} = 'Varredura';
                axesYScale{ii} = '';

            case {'channelPower', ...
                  'RFLink'}
                axesType{ii}   = 'Cartesian';
                axesXLabel{ii} = '';
                axesYLabel{ii} = '';
                axesYScale{ii} = '';
            
            otherwise
                error('plot:axes:axesTypeMapping:UnexpectedPlotName', 'Unexpected plotName %s', plotNamesPerAxes{ii})
        end
    end

end