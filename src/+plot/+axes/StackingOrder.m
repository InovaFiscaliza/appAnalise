classdef (Abstract) StackingOrder

    properties (Constant)
        %-----------------------------------------------------------------%
        winAppAnalise     = {'mkrLabels', 'occupancyThreshold', 'mkrROI', 'ROI', 'emission', 'emissionsTemp', 'emissionSelected', 'emissions', 'average', 'clearWrite', 'maxHold', ...
                             'mkrLine', 'channel', 'bandLimits', 'persistence', 'minHold', 'waterfallTime', 'waterfall'}        
        
        winDriveTest      = {'filterROI', 'car', 'points', 'distortion', 'density', 'estimatedEmissorLocation', 'routePassFilter', 'routeFailFilter', ... % app.UIAxes1   (GeographicAxes)
                             'channelROI', 'clearWrite', 'persistence', 'channelPower', 'waterfallTime', 'waterfall'}  % app.UIAxes2-4 (CartesianAxes)
        
        winSignalAnalysis = {'emissionROI', 'average', 'maxHold', 'minHold'}                                      % app.UIAxes2   (CartesianAxes)
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function execute(hAxes, clientID)
            switch clientID
                case {'appAnalise:PLAYBACK', 'appAnalise:REPORT', 'appAnalise:REPORT:BAND', 'appAnalise:REPORT:CHANNEL', 'appAnalise:REPORT:EMISSION'}
                    refStackingOrder = plot.axes.StackingOrder.winAppAnalise;

                case 'appAnalise:DRIVETEST'
                    refStackingOrder = plot.axes.StackingOrder.winDriveTest;

                case 'appAnalise:SIGNALANALYSIS'
                    refStackingOrder = plot.axes.StackingOrder.winSignalAnalysis;

                otherwise
                    error('Unexpected option.')
            end
            
            stackingOrderTag = arrayfun(@(x) x.Tag, hAxes.Children, 'UniformOutput', false)';

            [~, newOrderMemberIndex] = ismember(stackingOrderTag, refStackingOrder);
            [~, newOrderIndex]       = sort(newOrderMemberIndex);
        
            hAxes.Children = hAxes.Children(newOrderIndex);
        end
    end
end