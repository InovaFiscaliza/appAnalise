classdef (Abstract) Emissions

    methods (Static = true)
        %-----------------------------------------------------------------%
        function emissionSelected = draw(emissionSelectedIdx, axesHandle, restoreView, bandObj)
            emissionSelected = [];
            
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            yLevel1 = restoreView(1).yLim(1) + 1;
            yLevel2 = diff(restoreView(1).yLim) - 2;
    
            emissions = specData.UserData.Emissions;

            if ~isempty(emissions)
                if isempty(emissionSelectedIdx)
                    emissionSelectedIdx = 1;
                end

                for ii = 1:height(emissions)
                    freqStart = emissions.Frequency(ii) - emissions.BandWidthkHz(ii) / 2000;
                    freqStop  = emissions.Frequency(ii) + emissions.BandWidthkHz(ii) / 2000;
                    bandWidthKHz = specData.UserData.Emissions.BandWidthkHz(ii) / 1000;            
                    
                    % Cria uma linha por emissão, posicionando-o na parte inferior
                    % do plot.
                    line(axesHandle, [freqStart, freqStop], [yLevel1, yLevel1], 'Color', [0.40,0.73,0.88], 'LineWidth', 1, 'Marker', '.', 'MarkerSize', 14, 'PickableParts', 'none', 'Tag', 'emissions');
        
                    % Cria um ROI para a emissão selecionada, posicionando-o em
                    % todo o plot.
                    if ii == emissionSelectedIdx
                        roiPosition = [freqStart, yLevel1, bandWidthKHz, yLevel2];
                        emissionSelected = images.roi.Rectangle(axesHandle, 'Position', roiPosition, 'Color', [0.40,0.73,0.88], 'MarkerSize', 5, 'Deletable', 0, 'FaceSelectable', 0, 'LineWidth', 1, 'Tag', 'emissionSelected');
                    end
                end

                plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
            end
        end

        %-----------------------------------------------------------------%
        function TStyle(axesHandle, bandObj, plotTag, varargin)
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            emissions = specData.UserData.Emissions;
            emissions.FreqStart = emissions.Frequency - emissions.BandWidthkHz/2000;
            emissions.FreqStop  = emissions.Frequency + emissions.BandWidthkHz/2000;

            delete(findobj(axesHandle, 'Tag', plotTag))
            
            if ~isempty(emissions)
                [~, yLimOffsetMode, yLimOffset, stepEffect] = plot.Config(plotTag, bandObj.GeneralSettings);

                switch yLimOffsetMode
                    case 'bottom'
                        yLimOffset = 0;
                        yLevel = axesHandle.YLim(1)+yLimOffset;
                    otherwise % 'top'
                        yLevel = axesHandle.YLim(2)-yLimOffset;                        
                end
            
                for ii = 1:height(emissions)
                    freqCenter = emissions.Frequency(ii);
                    freqStart  = emissions.FreqStart(ii);
                    freqStop   = emissions.FreqStop(ii);

                    if stepEffect
                        switch yLimOffsetMode
                            case 'bottom'
                                yLevel2Plot = yLevel + mod(ii+1,2);
                            otherwise
                                yLevel2Plot = yLevel - mod(ii+1,2);
                        end
                    else
                        yLevel2Plot = yLevel;
                    end

                    % ToDo:
                    % Deixar configuráveis os parâmetros...
                    % Editar "GeneralSettings.json"

                    line(axesHandle, [freqStart, freqStop], [yLevel2Plot, yLevel2Plot], 'Color', '#ffff12', 'LineWidth', 1, 'LineStyle', ':', 'Marker', '.', 'MarkerSize', 8, 'PickableParts', 'none', 'Tag', 'Emission');
                    line(axesHandle, [freqCenter, freqCenter], [-1000, 1000], 'Color', '#ffff12', 'LineWidth', 1, 'LineStyle', ':', 'PickableParts', 'none', 'Tag', 'Emission');
                    text(axesHandle, freqCenter, yLevel2Plot, sprintf(' %d', ii), Color='#ffff12', FontSize=10, FontWeight='bold', FontName='Helvetica', VerticalAlignment='bottom', Tag='EmissionTag');
                end

                plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
            end
        end
    end
end