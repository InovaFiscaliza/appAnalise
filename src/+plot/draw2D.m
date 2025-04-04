classdef (Abstract) draw2D

    methods (Static = true)
        %-----------------------------------------------------------------%
        function hLine = OrdinaryLine(hAxes, bandObj, idx, plotTag)
            defaultProp  = bandObj.callingApp.General_I;
            switch bandObj.Context
                case 'appAnalise:PLAYBACK'
                    customProp = bandObj.callingApp.specData(idx).UserData.customPlayback.Parameters;
                otherwise
                    customProp = [];
            end

            [plotConfig, ...
             plotType]   = plot.Config(plotTag, defaultProp, customProp);
            
            [XArray, ...
             YArray]     = XYArray(bandObj, idx, plotTag);

            switch plotType
                case 'line'
                    hLine = line(hAxes, XArray, YArray, plotConfig{:});
                case 'area'
                    hLine = area(hAxes, XArray, YArray, 'BaseValue', hAxes.YLim(1), 'FaceAlpha', 0.25, plotConfig{:});
            end

            plot.axes.StackingOrder.execute(hAxes, bandObj.Context)
        end

        %-----------------------------------------------------------------%
        function OrdinaryLineUpdate(hLine, bandObj, idx, plotTag)
            idxTime = bandObj.callingApp.idxTime;

            switch plotTag
                case {'ClearWrite', 'MinHold', 'Average', 'MaxHold'}
                    yArray = bandObj.callingApp.specData(idx).Data{2}(:,idxTime)';

                    switch plotTag                
                        case 'ClearWrite'
                            hLine.YData = yArray;
                        case 'MinHold'
                            hLine.YData = min(hLine.YData, yArray);
                        case 'Average'
                            integrationFactor = bandObj.callingApp.General.Integration.Trace;
                            hLine.YData = ((integrationFactor-1)*hLine.YData + yArray) / integrationFactor;
                        case 'MaxHold'
                            hLine.YData = max(hLine.YData, yArray);
                    end

                case 'WaterfallTime'
                    switch class(hLine.YData)
                        case 'datetime'
                            tInstant = bandObj.callingApp.specData(idx).Data{1}(idxTime);
                            hLine.YData = [tInstant, tInstant];
                        otherwise
                            hLine.YData = [idxTime, idxTime];
                    end
            end
        end

        %-----------------------------------------------------------------%
        function horizontalSetOfLines(hAxes, bandObj, idx, plotTag, varargin)
            specData = bandObj.callingApp.specData(idx);
            switch plotTag
                case 'BandLimits'
                    srcInfo  = specData.UserData.bandLimitsTable;
                    plotFlag = specData.UserData.bandLimitsStatus;                    
                    
                case 'Channel'
                    srcInfo  = varargin{1};

                case 'Emission'
                    srcInfo  = specData.UserData.Emissions;
                    srcInfo.FreqStart = srcInfo.Frequency - srcInfo.BW_kHz/2000;
                    srcInfo.FreqStop  = srcInfo.Frequency + srcInfo.BW_kHz/2000;
            end

            if ~exist('plotFlag', 'var')
                if isempty(srcInfo)
                    plotFlag = false;
                else
                    plotFlag = true;
                end
            end

            delete(findobj(hAxes, 'Tag', plotTag))
            
            if plotFlag && ~isempty(srcInfo)
                defaultProp  = bandObj.callingApp.General_I;

                [plotConfig,     ...
                 YLimOffsetMode, ...
                 YLimOffset,     ...
                 StepEffect] = plot.Config(plotTag, defaultProp, []);

                switch YLimOffsetMode
                    case 'bottom'
                        yLevel = hAxes.YLim(1)+YLimOffset;
                    otherwise % 'top'
                        yLevel = hAxes.YLim(2)-YLimOffset;                        
                end
            
                for ii = 1:height(srcInfo)
                    FreqStart   = srcInfo.FreqStart(ii);
                    FreqStop    = srcInfo.FreqStop(ii);

                    if StepEffect
                        switch YLimOffsetMode
                            case 'bottom'
                                yLevel2Plot = yLevel + mod(ii+1,2);
                            otherwise
                                yLevel2Plot = yLevel - mod(ii+1,2);
                        end
                    else
                        yLevel2Plot = yLevel;
                    end
                    
                    line(hAxes, [FreqStart, FreqStop], [yLevel2Plot, yLevel2Plot], plotConfig{:})
                end
                plot.axes.StackingOrder.execute(hAxes, bandObj.Context)
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
                defaultProp  = bandObj.callingApp.General_I;
                customProp   = [];

                [plotConfigROI,   ...
                 plotConfigText,  ...
                 LabelOffsetMode, ...
                 LabelOffset] = plot.Config(plotTag, defaultProp, customProp);

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
                        app.hSelectedEmission.Position(:, [1, 3]) = [app.specData(idx).UserData.Emissions.Frequency(idx2) - app.specData(idx).UserData.Emissions.BW_kHz(idx2)/(2*1000), ...
                                                                     app.specData(idx).UserData.Emissions.BW_kHz(idx2)/1000];
                        return
                    
                    case 'PeakValueChanged'
                        delete(findobj('Tag', 'mkrTemp', '-or', 'Tag', 'mkrLine', '-or', 'Tag', 'mkrLabels'))
        
                    case 'DeleteButtonPushed'
                        delete(findobj('Tag', 'mkrTemp', '-or', 'Tag', 'mkrLine', '-or', 'Tag', 'mkrLabels', '-or', 'Tag', 'mkrROI'))
                        
                        app.hSelectedEmission = [];
                        app.hEmissionMarkers  = [];
            end
        
            % Processing...
            play_EmissionList(app, idx, selectedEmission)
        
            if isempty(app.specData(idx).UserData.Emissions)
                app.hClearWrite.MarkerIndices = [];
        
            else
                app.hClearWrite.MarkerIndices = app.specData(idx).UserData.Emissions.idxFrequency;
        
                yLevel1   = app.restoreView(1).yLim(1) + 1;
                yLevel2   = diff(app.restoreView(1).yLim) - 2;
        
                mkrLabels = {};
                for ii = 1:height(app.specData(idx).UserData.Emissions)
                    mkrLabels = [mkrLabels {['  ' num2str(ii)]}];
        
                    FreqStart = app.specData(idx).UserData.Emissions.Frequency(ii) - app.specData(idx).UserData.Emissions.BW_kHz(ii)/(2*1000);
                    FreqStop  = app.specData(idx).UserData.Emissions.Frequency(ii) + app.specData(idx).UserData.Emissions.BW_kHz(ii)/(2*1000);
                    BW        = app.specData(idx).UserData.Emissions.BW_kHz(ii)/1000;            
                    
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
                        
                        if isempty(app.hSelectedEmission)
                            app.hSelectedEmission = images.roi.Rectangle(app.UIAxes1, Position=newPosition,   ...
                                                                                      Color=[0.40,0.73,0.88], ...
                                                                                      MarkerSize=5,           ...
                                                                                      Deletable=0,            ...
                                                                                      FaceSelectable=0,       ...
                                                                                      LineWidth=1,            ...
                                                                                      Tag='mkrROI');
                
                            addlistener(app.hSelectedEmission, 'MovingROI', @(~,evt)plot.draw2D.mkrLineROI_old(evt, app, idx));
                            addlistener(app.hSelectedEmission, 'ROIMoved',  @(~,evt)plot.draw2D.mkrLineROI_old(evt, app, idx));
        
                        else
                            app.hSelectedEmission.Position = newPosition;
                        end
                    end
                end
        
                app.hEmissionMarkers = text(app.UIAxes1, app.specData(idx).UserData.Emissions.Frequency, double(app.specData(idx).Data{2}(app.specData(idx).UserData.Emissions.idxFrequency, app.idxTime)), mkrLabels, ...
                                                         Color=[0.40,0.73,0.88], FontSize=11, FontWeight='bold', FontName='Helvetica', FontSmoothing='on', Tag='mkrLabels', Visible=app.play_LineVisibility.Value);
            end
        end        
        
        %-------------------------------------------------------------------------%
        function mkrLineROI_old(evt, app, idxThread)

            idxEmission = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;

            switch(evt.EventName)
                case 'MovingROI'
                    plot.axes.Interactivity.DefaultDisable([app.UIAxes1, app.UIAxes2, app.UIAxes3])
        
                    FreqCenter = app.hSelectedEmission.Position(1) + app.hSelectedEmission.Position(3)/2;
                    if (FreqCenter*1e+6 < app.specData(idxThread).MetaData.FreqStart) || ...
                       (FreqCenter*1e+6 > app.specData(idxThread).MetaData.FreqStop)
                    
                       return
                    end
        
                    app.play_FindPeaks_PeakCF.Value = round(FreqCenter, 3);
                    app.play_FindPeaks_PeakBW.Value = round(app.hSelectedEmission.Position(3) * 1000, 3);        
                    
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
                    update(app.specData(idxThread), 'UserData:Emissions', 'Edit', 'Frequency|BandWidth', idxEmission, idxFrequency, FreqCenter, BW_kHz, app.channelObj)

                    plot_updateSelectedEmission(app, idxThread, idxFrequency)
            end
        end
    end
end

