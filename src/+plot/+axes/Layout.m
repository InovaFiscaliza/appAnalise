classdef (Abstract) Layout

    methods (Static = true)
        %-----------------------------------------------------------------%
        function XLabel(hAxes, occVisibility, waterfallVisibility, Context)
            arguments
                hAxes               (1,3) matlab.ui.control.UIAxes
                occVisibility       (1,1) logical
                waterfallVisibility (1,1) logical
                Context             (1,:) char {mustBeMember(Context, {'appAnalise:PLAYBACK'})} = 'appAnalise:PLAYBACK'
            end

            UIAxes1 = hAxes(1);
            UIAxes2 = hAxes(2);
          % UIAxes3 = hAxes(3);

            if occVisibility && waterfallVisibility
                xlabel(UIAxes1, '')
                xlabel(UIAxes2, '')                
                UIAxes1.XTickLabel = {};
                UIAxes2.XTickLabel = {};

            elseif occVisibility
                xlabel(UIAxes1, '')
                xlabel(UIAxes2, 'Frequência (MHz)')
                UIAxes1.XTickLabel = {};
                UIAxes2.XTickLabelMode = 'auto';

            elseif waterfallVisibility
                xlabel(UIAxes1, '')
                UIAxes1.XTickLabel = {};
                
            else
                xlabel(UIAxes1, 'Frequência (MHz)')
                UIAxes1.XTickLabelMode = 'auto';
            end
        end

        %-----------------------------------------------------------------%
        function YLabel(hWaterfall, waterfallVisibility, Context)
            arguments
                hWaterfall            (1,1)
                waterfallVisibility (1,1) logical
                Context             (1,:) char {mustBeMember(Context, {'appAnalise:PLAYBACK'})} = 'appAnalise:PLAYBACK'
            end

            if waterfallVisibility
                hAxes = hWaterfall.Parent;
                switch class(hAxes.YAxis)
                    case 'matlab.graphics.axis.decorator.DatetimeRuler'
                        ylabel(hAxes, 'Instante')
                    otherwise
                        ylabel(hAxes, 'Varredura')
                end
            end

        end
        
        %-----------------------------------------------------------------%
        function RatioAspect(hAxes, occVisibility, waterfallVisibility, ratioAspectComponent, context)
            arguments
                hAxes                (1,3) matlab.ui.control.UIAxes
                occVisibility        (1,1) logical
                waterfallVisibility  (1,1) logical
                ratioAspectComponent (1,1) matlab.ui.control.DropDown
                context              (1,:) char {mustBeMember(context, {'appAnalise:PLAYBACK'})} = 'appAnalise:PLAYBACK'
            end

            if occVisibility && waterfallVisibility
                ratioAspectOptions = {'2:1:1', '1:2:1', '1:1:2'};
            elseif occVisibility
                ratioAspectOptions = {'3:1:0', '1:1:0', '1:3:0'};
            elseif waterfallVisibility        
                ratioAspectOptions = {'3:0:1', '1:0:1', '1:0:3'};                
            else
                ratioAspectOptions = {'1:0:0'};
            end

            ratioAspect = ratioAspectComponent.Value;
            if ~ismember(ratioAspect, ratioAspectOptions)
                ratioAspect = ratioAspectOptions{1};
            end            
            set(ratioAspectComponent, 'Items', ratioAspectOptions, 'Value', ratioAspect)
            
            plot.axes.Layout.Visibility(hAxes, ratioAspect, context)
        end

        %-----------------------------------------------------------------%
        function Visibility(hAxes, ratioAspect, context)
            arguments
                hAxes       (1,3) matlab.ui.control.UIAxes
                ratioAspect (1,:) char {mustBeMember(ratioAspect, {'1:0:0', '1:1:0', '1:0:1', '1:3:0', '1:0:3', '1:2:1', '1:1:2', '2:1:1', '3:1:0', '3:0:1'})}
                context     (1,:) char {mustBeMember(context, {'appAnalise:PLAYBACK'})} = 'appAnalise:PLAYBACK'
            end

            tiledSpan = str2double(strsplit(ratioAspect, ':'));
            tiledSpan = (4/sum(tiledSpan)) * tiledSpan;
            
            tiledPos  = 1;
            for kk = 1:3
                UIAxes = hAxes(kk);

                if tiledSpan(kk)
                    axVisibility = 1;        
                    UIAxes.Layout.Tile = tiledPos;
                    UIAxes.Layout.TileSpan = [tiledSpan(kk) 1];
                else
                    axVisibility = 0;
                end

                set(findobj(UIAxes, '-not', {'Tag', 'ClearWrite', '-or', 'Tag', 'mkrLabels'}), 'Visible', axVisibility)
                if kk == 3
                    ysecondarylabel(UIAxes, 'Visible', axVisibility)
                    set(findobj(UIAxes.Parent.Children, 'Type', 'colorbar'), 'Visible', axVisibility)
                end

                tiledPos = tiledPos+tiledSpan(kk);
            end
        end
    end
end