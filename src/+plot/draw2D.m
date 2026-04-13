classdef (Abstract) draw2D

    methods (Static = true)
        %-----------------------------------------------------------------%
        function plotHandle = OrdinaryLine(axesHandle, plotTag, bandObj, sweepTimeIdx)
            plotHandle = [];
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            [plotConfig, plotType] = plot.Config(plotTag, bandObj.GeneralSettings);
            [xArray, yArray] = getXYArrays(bandObj, plotTag, sweepTimeIdx, class(axesHandle.YAxis));
            
            switch plotType
                case 'line'
                    plotHandle = line(axesHandle, xArray, yArray, plotConfig{:});
                case 'area'
                    plotHandle = area(axesHandle, xArray, yArray, 'BaseValue', min(min(yArray), axesHandle.YLim(1)), 'FaceAlpha', 0.25, plotConfig{:});
            end

            plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
        end

        %-----------------------------------------------------------------%
        function OrdinaryLineUpdate(plotTag, plotHandle, bandObj, sweepTimeIdx)
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            switch plotTag
                case {'clearWrite', 'minHold', 'average', 'maxHold'}
                    yArray = bandObj.SpecData.Data{2}(:, sweepTimeIdx)';

                    switch plotTag                
                        case 'clearWrite'
                            plotHandle.YData = yArray;
                        case 'minHold'
                            plotHandle.YData = min(plotHandle.YData, yArray);
                        case 'average'
                            integrationFactor = bandObj.General.context.PLAYBACK.integration.traceMode;
                            plotHandle.YData = ((integrationFactor-1)*plotHandle.YData + yArray) / integrationFactor;
                        case 'maxHold'
                            plotHandle.YData = max(plotHandle.YData, yArray);
                    end

                case 'waterfallTime'
                    switch class(plotHandle.YData)
                        case 'datetime'
                            tInstant = bandObj.SpecData.Data{1}(sweepTimeIdx);
                            plotHandle.YData = [tInstant, tInstant];
                        otherwise
                            plotHandle.YData = [sweepTimeIdx, sweepTimeIdx];
                    end
            end
        end

        %-----------------------------------------------------------------%
        function horizontalSetOfLines(axesHandle, bandObj, plotTag, varargin)
            specData = bandObj.SpecData;
            if isempty(specData)
                return
            end

            switch plotTag
                case 'bandLimits'
                    srcInfo  = specData.UserData.DetectionSubBands;
                    plotFlag = specData.UserData.DetectionSubBandsEnabled;                    
                    
                case 'channel'
                    srcInfo  = varargin{1};

                case 'emission'
                    srcInfo  = specData.UserData.Emissions;
                    srcInfo.FreqStart = srcInfo.Frequency - srcInfo.BandWidthkHz/2000;
                    srcInfo.FreqStop  = srcInfo.Frequency + srcInfo.BandWidthkHz/2000;
            end

            if ~exist('plotFlag', 'var')
                if isempty(srcInfo)
                    plotFlag = false;
                else
                    plotFlag = true;
                end
            end

            delete(findobj(axesHandle, 'Tag', plotTag))
            
            if plotFlag && ~isempty(srcInfo)
                [plotConfig,     ...
                 yLimOffsetMode, ...
                 yLimOffset,     ...
                 stepEffect] = plot.Config(plotTag, bandObj.GeneralSettings);

                switch yLimOffsetMode
                    case 'bottom'
                        yLevel = axesHandle.YLim(1)+yLimOffset;
                    otherwise % 'top'
                        yLevel = axesHandle.YLim(2)-yLimOffset;                        
                end
            
                for ii = 1:height(srcInfo)
                    freqStart = srcInfo.FreqStart(ii);
                    freqStop  = srcInfo.FreqStop(ii);

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
                    
                    line(axesHandle, [freqStart, freqStop], [yLevel2Plot, yLevel2Plot], plotConfig{:})

                    if strcmp(plotTag, 'emission')
                        freqCenter = srcInfo.Frequency(ii);
                        line(axesHandle, [freqCenter, freqCenter], [-1000, 1000], 'Color', '#ffff12', 'LineWidth', 1, 'LineStyle', ':', 'PickableParts', 'none', 'Tag', 'emission');
                        text(axesHandle, freqCenter, yLevel2Plot, sprintf(' %d', ii), 'Color', '#ffff12', 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Helvetica', 'VerticalAlignment', 'bottom', 'Tag', 'emissionTag');
                    end
                end
                plot.axes.StackingOrder.execute(axesHandle, bandObj.Context)
            end
        end

        %-----------------------------------------------------------------%
        function rectangularROI(hAxes, bandObj, srcROITable, idxROI, plotTag, postPlotConfig, yLimits)
            arguments
                hAxes
                bandObj
                srcROITable
                idxROI
                plotTag
                postPlotConfig = {}
                yLimits = []
            end

            if isempty(idxROI)
                idxROI = 1:height(srcROITable);
            end

            if ~isempty(srcROITable)
                [plotConfigROI,   ...
                 plotConfigText,  ...
                 LabelOffsetMode, ...
                 LabelOffset] = plot.Config(plotTag, bandObj.GeneralSettings);

                if isempty(yLimits)
                    yLimits = double(hAxes.YLim);
                end
                
                for ii = idxROI
                    hROI = drawrectangle(hAxes, 'Position', [srcROITable.Frequency(ii)-srcROITable.BW_kHz(ii)/2000, yLimits(1)+1, srcROITable.BW_kHz(ii)/1000, diff(yLimits)-2], plotConfigROI{:});

                    if ~isempty(postPlotConfig)
                        set(hROI, postPlotConfig{:})
                    end
                end

                switch bandObj.Context
                    case {'appAnalise:SIGNALANALYSIS', 'appAnalise:DRIVETEST'}
                        % ...
                        % Pendente migrar o ROI do PLAYBACK, hoje criado na
                        % função "ClearWrite_old" desta classe.
                        % ...

                    case 'appAnalise:REPORT:BAND'
                        switch LabelOffsetMode
                            case 'bottom'
                                yTextPosition = yLimits(1)+LabelOffset;
                            otherwise % 'top'
                                yTextPosition = yLimits(2)-LabelOffset;                        
                        end

                        text(hAxes, srcROITable.Frequency(idxROI), repmat(yLimits(1)+yTextPosition, numel(idxROI), 1), string((idxROI)'), plotConfigText{:});
                end
            end
        end

        %-----------------------------------------------------------------%
        % FUNÇÕES ANTIGAS
        %-----------------------------------------------------------------%
        function ClearWrite_old(app, idx, plotType, selectedEmission)
            switch plotType
                    case 'TreeSelectionChanged'
                        idx2 = app.play_FindPeaks_Tree.SelectedNodes.NodeData;
                        app.plotHandles.selectedEmission.Position(:, [1, 3]) = [app.mainApp.specData(idx).UserData.Emissions.Frequency(idx2) - app.mainApp.specData(idx).UserData.Emissions.BW_kHz(idx2)/(2*1000), app.mainApp.specData(idx).UserData.Emissions.BW_kHz(idx2)/1000];
                        return
                    
                    case 'PeakValueChanged'
                        delete(findobj('Tag', 'mkrTemp', '-or', 'Tag', 'mkrLine', '-or', 'Tag', 'mkrLabels'))
        
                    case 'DeleteButtonPushed'
                        delete(findobj('Tag', 'mkrTemp', '-or', 'Tag', 'mkrLine', '-or', 'Tag', 'mkrLabels', '-or', 'Tag', 'mkrROI'))
                        
                        app.plotHandles.selectedEmission = [];
                        app.plotHandles.emissionMarkers  = [];
            end
        
            % Processing...
            play_EmissionList(app, idx, selectedEmission)
        
            if isempty(app.mainApp.specData(idx).UserData.Emissions)
                app.plotHandles.clearWrite.MarkerIndices = [];
        
            else
                app.plotHandles.clearWrite.MarkerIndices = app.mainApp.specData(idx).UserData.Emissions.idxFrequency;
        
                yLevel1   = app.restoreView(1).yLim(1) + 1;
                yLevel2   = diff(app.restoreView(1).yLim) - 2;
        
                mkrLabels = {};
                for ii = 1:height(app.mainApp.specData(idx).UserData.Emissions)
                    mkrLabels = [mkrLabels {['  ' num2str(ii)]}];
        
                    FreqStart = app.mainApp.specData(idx).UserData.Emissions.Frequency(ii) - app.mainApp.specData(idx).UserData.Emissions.BW_kHz(ii)/(2*1000);
                    FreqStop  = app.mainApp.specData(idx).UserData.Emissions.Frequency(ii) + app.mainApp.specData(idx).UserData.Emissions.BW_kHz(ii)/(2*1000);
                    BW        = app.mainApp.specData(idx).UserData.Emissions.BW_kHz(ii)/1000;            
                    
                    % Cria uma linha por emissão, posicionando-o na parte inferior
                    % do plot.
                    line(app.UIAxes1, [FreqStart, FreqStop], [yLevel1, yLevel1], ...
                                    Color=[0.40,0.73,0.88], LineWidth=1, ...
                                    Marker='.',             MarkerSize=14, ...
                                    PickableParts='none',   Tag='mkrLine')
        
                    % Cria um ROI para a emissão selecionada, posicionando-o em
                    % todo o plot.
                    if ii == selectedEmission
                        newPosition = [FreqStart, yLevel1, ...
                                       BW,        yLevel2];
                        
                        if isempty(app.plotHandles.selectedEmission)
                            app.plotHandles.selectedEmission = images.roi.Rectangle(app.UIAxes1, Position=newPosition,   ...
                                                                                      Color=[0.40,0.73,0.88], ...
                                                                                      MarkerSize=5,           ...
                                                                                      Deletable=0,            ...
                                                                                      FaceSelectable=0,       ...
                                                                                      LineWidth=1,            ...
                                                                                      Tag='mkrROI');
                
                            addlistener(app.plotHandles.selectedEmission, 'MovingROI', @(~,evt)plot.draw2D.mkrLineROI_old(evt, app, idx));
                            addlistener(app.plotHandles.selectedEmission, 'ROIMoved',  @(~,evt)plot.draw2D.mkrLineROI_old(evt, app, idx));
        
                        else
                            app.plotHandles.selectedEmission.Position = newPosition;
                        end
                    end
                end
        
                app.plotHandles.emissionMarkers = text(app.UIAxes1, app.mainApp.specData(idx).UserData.Emissions.Frequency, double(app.mainApp.specData(idx).Data{2}(app.mainApp.specData(idx).UserData.Emissions.idxFrequency, app.idxTime)), mkrLabels, ...
                                                         Color=[0.40,0.73,0.88], FontSize=11, FontWeight='bold', FontName='Helvetica', FontSmoothing='on', Tag='mkrLabels', Visible=app.mainApp.General.context.PLAYBACK.clearWriteVisibility);
            end
        end        
        
        %-------------------------------------------------------------------------%
        function mkrLineROI_old(evt, app, idxThread)

            idxEmission = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;

            switch(evt.EventName)
                case 'MovingROI'
                    plot.axes.Interactivity.DefaultDisable([app.UIAxes1, app.UIAxes2, app.UIAxes3])
        
                    FreqCenter = app.plotHandles.selectedEmission.Position(1) + app.plotHandles.selectedEmission.Position(3)/2;
                    if (FreqCenter*1e+6 < app.mainApp.specData(idxThread).MetaData.FreqStart) || ...
                       (FreqCenter*1e+6 > app.mainApp.specData(idxThread).MetaData.FreqStop)
                    
                       return
                    end
        
                    app.play_FindPeaks_PeakCF.Value = round(FreqCenter, 3);
                    app.play_FindPeaks_PeakBW.Value = round(app.plotHandles.selectedEmission.Position(3) * 1000, 3);        
                    
                    app.hClearWrite.MarkerIndices(idxEmission) = freq2idx(app.bandObj, app.play_FindPeaks_PeakCF.Value*1e+6);
                    
                    % Se tiver apenas um marcador, então a string fica como
                    % cell. Caso tenha mais de um marcador, então a string
                    % fica como char.
                    markerTag = findobj('Type', 'Text', 'String', sprintf('  %d', idxEmission));
                    if isempty(markerTag)
                        markerTag = findobj('Type', 'Text', 'String', {sprintf('  %d', idxEmission)});
                    end
                    markerTag.Position(1:2) = [app.play_FindPeaks_PeakCF.Value, app.hClearWrite.YData(app.hClearWrite.MarkerIndices(idxEmission))];
                    
                    set(app.play_FindPeaks_Tree.Children(idxEmission), 'Text', sprintf("%d: %.3f MHz ⌂ %.3f kHz", idxEmission, app.play_FindPeaks_PeakCF.Value, app.play_FindPeaks_PeakBW.Value), ...
                                                                       'NodeData', idxEmission)
                    
                case 'ROIMoved'
                    plot.axes.Interactivity.DefaultEnable([app.UIAxes1, app.UIAxes2, app.UIAxes3])

                    idxFrequency = freq2idx(app.bandObj, app.play_FindPeaks_PeakCF.Value*1e+6);
                    FreqCenter   = app.play_FindPeaks_PeakCF.Value;
                    BW_kHz       = app.play_FindPeaks_PeakBW.Value;
                    update(app.mainApp.specData(idxThread), 'UserData:Emissions', 'Edit', 'Frequency|BandWidth', idxEmission, idxFrequency, FreqCenter, BW_kHz, app.channelObj)

                    plot_updateSelectedEmission(app, idxThread, idxFrequency)
            end
        end
    end
end

