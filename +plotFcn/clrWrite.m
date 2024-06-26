function clrWrite(app, idx, plotType, selectedEmission)

    switch plotType
        case 'InitialPlot'
            newArray  = app.specData(idx).Data{2}(:,app.timeIndex)';
            LevelUnit = app.specData(idx).MetaData.LevelUnit;

            app.line_ClrWrite = plot(app.axes1, app.Band.xArray, newArray, Color=app.General.Plot.ClearWrite.EdgeColor, ...
                                                                           Marker='.',                             ...
                                                                           MarkerIndices=[],                       ...
                                                                           MarkerFaceColor=[0.40,0.73,0.88],       ...
                                                                           MarkerEdgeColor=[0.40,0.73,0.88],       ...
                                                                           MarkerSize=14,                          ...
                                                                           Visible=app.play_LineVisibility.Value,  ...
                                                                           Tag='ClearWrite');
            plotFcn.DataTipModel(app.line_ClrWrite, LevelUnit)

            case 'TreeSelectionChanged'
                idx2 = app.play_FindPeaks_Tree.SelectedNodes.NodeData;
                app.mkr_ROI.Position(:, [1, 3]) = [app.specData(idx).UserData.Emissions.Frequency(idx2) - app.specData(idx).UserData.Emissions.BW(idx2)/(2*1000), ...
                                                   app.specData(idx).UserData.Emissions.BW(idx2)/1000];
                return
            
            case 'PeakValueChanged'
                delete(findobj('Tag', 'mkrTemp', '-or', 'Tag', 'mkrLine', '-or', 'Tag', 'mkrLabels'))

            case 'DeleteButtonPushed'
                delete(findobj('Tag', 'mkrTemp', '-or', 'Tag', 'mkrLine', '-or', 'Tag', 'mkrLabels', '-or', 'Tag', 'mkrROI'))
                
                app.mkr_ROI   = [];
                app.mkr_Label = [];
    end

    % Processing...
    play_EmissionList(app, idx, selectedEmission)

    if isempty(app.specData(idx).UserData.Emissions)
        app.line_ClrWrite.MarkerIndices = [];

    else
        app.line_ClrWrite.MarkerIndices = app.specData(idx).UserData.Emissions.Index;

        yLevel1   = app.restoreView{2}(1)+1;
        yLevel2   = app.restoreView{2}(2)-app.restoreView{2}(1)-2;

        mkrLabels = {};
        for ii = 1:height(app.specData(idx).UserData.Emissions)
            mkrLabels = [mkrLabels {['  ' num2str(ii)]}];

            FreqStart = app.specData(idx).UserData.Emissions.Frequency(ii) - app.specData(idx).UserData.Emissions.BW(ii)/(2*1000);
            FreqStop  = app.specData(idx).UserData.Emissions.Frequency(ii) + app.specData(idx).UserData.Emissions.BW(ii)/(2*1000);
            BW        = app.specData(idx).UserData.Emissions.BW(ii)/1000;            
            
            % Cria uma linha por emissão, posicionando-o na parte inferior
            % do plot.
            line(app.axes1, [FreqStart, FreqStop], [yLevel1, yLevel1], ...
                            Color=[0.40,0.73,0.88], LineWidth=1, ...
                            Marker='.',             MarkerSize=14, ...
                            PickableParts='none',   Tag='mkrLine')

            % Cria um ROI para a emissão selecionada, posicionando-o em
            % todo o plot.
            if ii == selectedEmission
                newPosition = [FreqStart, yLevel1, ...
                               BW,        yLevel2];
                
                if isempty(app.mkr_ROI)
                    app.mkr_ROI = images.roi.Rectangle(app.axes1, Position=newPosition,   ...
                                                                  Color=[0.40,0.73,0.88], ...
                                                                  MarkerSize=5,           ...
                                                                  Deletable=0,            ...
                                                                  FaceSelectable=0,       ...
                                                                  LineWidth=1,            ...
                                                                  Tag='mkrROI');
        
                    addlistener(app.mkr_ROI, 'MovingROI', @(src, evt)mkrLineROI(src, evt, app, idx));
                    addlistener(app.mkr_ROI, 'ROIMoved',  @(src, evt)mkrLineROI(src, evt, app, idx));

                else
                    app.mkr_ROI.Position = newPosition;
                end
            end
        end

        app.mkr_Label = text(app.axes1, app.specData(idx).UserData.Emissions.Frequency, double(app.specData(idx).Data{2}(app.specData(idx).UserData.Emissions.Index, app.timeIndex)), mkrLabels, ...
                                             Color=[0.40,0.73,0.88], FontSize=11, FontWeight='bold', FontName='Helvetica', FontSmoothing='on', Tag='mkrLabels', Visible=app.play_LineVisibility.Value);
    end
end


%-------------------------------------------------------------------------%
function mkrLineROI(src, evt, app, idx1)

    switch(evt.EventName)
        case 'MovingROI'
            plotFcn.axesInteraction.DisableDefaultInteractions([app.axes1, app.axes2, app.axes3])

            FreqCenter = app.mkr_ROI.Position(1) + app.mkr_ROI.Position(3)/2;
            if (FreqCenter*1e+6 < app.specData(idx1).MetaData.FreqStart) || ...
               (FreqCenter*1e+6 > app.specData(idx1).MetaData.FreqStop)
            
               return
            end

            app.play_FindPeaks_PeakCF.Value = round(FreqCenter, 3);
            app.play_FindPeaks_PeakBW.Value = round(app.mkr_ROI.Position(3) * 1000, 3);

            idx2 = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;
            app.line_ClrWrite.MarkerIndices(idx2) = round((app.play_FindPeaks_PeakCF.Value*1e+6 - app.Band.bCoef)/app.Band.aCoef);
            
            % Se tiver apenas um marcador, então a string fica como
            % cell. Caso tenha mais de um marcador, então a string
            % fica como char.
            markerTag = findobj('Type', 'Text', 'String', sprintf('  %d', idx2));
            if isempty(markerTag)
                markerTag = findobj('Type', 'Text', 'String', {sprintf('  %d', idx2)});
            end
            markerTag.Position(1:2) = [app.play_FindPeaks_PeakCF.Value, app.line_ClrWrite.YData(app.line_ClrWrite.MarkerIndices(idx2))];
            
            set(app.play_FindPeaks_Tree.Children(idx2), 'Text', sprintf("%d: %.3f MHz ⌂ %.3f kHz", idx2, app.play_FindPeaks_PeakCF.Value, app.play_FindPeaks_PeakBW.Value), ...
                                                        'NodeData', idx2)
            
        case 'ROIMoved'
            plotFcn.axesInteraction.EnableDefaultInteractions([app.axes1, app.axes2, app.axes3])

            idx2 = app.play_FindPeaks_Tree.SelectedNodes(1).NodeData;            
            newIndex = round((app.play_FindPeaks_PeakCF.Value*1e+6 - app.Band.bCoef)/app.Band.aCoef);

            emissionInfo = jsondecode(app.specData(idx1).UserData.Emissions.Detection{idx2});
            emissionInfo.Algorithm = 'Manual';
            
            app.specData(idx1).UserData.Emissions(idx2,[1:3, 5]) = {newIndex, app.play_FindPeaks_PeakCF.Value, app.play_FindPeaks_PeakBW.Value, jsonencode(emissionInfo)};
            play_BandLimits_updateEmissions(app, idx1, newIndex)
            play_UpdatePeaksTable(app, idx1)
    end
end