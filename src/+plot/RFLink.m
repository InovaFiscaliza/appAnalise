function RFLink(hAxes, txSite, rxSite, wayPoints3D, plotMode, rotateViewFlag)
    arguments
        hAxes
        txSite
        rxSite
        wayPoints3D
        plotMode char {mustBeMember(plotMode,  {'dark', 'light'})}  = 'light'
        rotateViewFlag logical = false
    end

    % ## prePlot
    % (a) Altura das estações TX-RX.
    txAntennaElevation = wayPoints3D(1,3);
    if txSite.AntennaHeight > 0
        txAntennaElevation = txAntennaElevation + txSite.AntennaHeight;
    end

    rxAntennaElevation = wayPoints3D(end,3);
    if rxSite.AntennaHeight > 0
        rxAntennaElevation = rxAntennaElevation + rxSite.AntennaHeight;
    end

    % (b) 1ª Zona de Fresnel, atenuação no espaço livre, análise de visada 
    %     entre TX e RX, distância e azimute.
    [fresnelRadius, linkDistanceMeters, profileDistance, az] = RF.Propagation.FresnelZone(txSite, rxSite, height(wayPoints3D));
    profileDistance   = double(profileDistance); % força double porque fspl só aceita double
    profileDistanceKm = profileDistance/1000;
    linkDistanceKm    = linkDistanceMeters/1000;
    losHeight         = interp1([0, linkDistanceMeters], [txAntennaElevation, rxAntennaElevation], profileDistance, 'linear');
    pathLoss          = fspl(profileDistance, physconst('LightSpeed')/txSite.TransmitterFrequency);
    [~, firstObstructionIdx] = RF.Propagation.LOS(wayPoints3D(:,3), losHeight, fresnelRadius);

    % (c) Cores
    [terrainFaceColor, ...
     terrainEdgeColor] = getPlotColor(plotMode, 'Terrain');
    terrainFaceAlpha   = 0.75;

    colorObstruction   = getPlotColor(plotMode, 'FirstObstruction');
    colorStation       = getPlotColor(plotMode, 'Station');
    colorLink          = getPlotColor(plotMode, 'Link');
    colorFresnel       = getPlotColor(plotMode, 'Fresnel');

    % ## Plot
    cla(hAxes)
    hAxes.XLimMode = 'auto';
    hAxes.YLimMode = 'auto';

    % (a) Perfil de terreno e primeira obstrução (caso aplicável)
    hTerrain = area(hAxes, profileDistanceKm, wayPoints3D(:,3), BaseValue=0, FaceColor=terrainFaceColor, FaceAlpha=terrainFaceAlpha, EdgeColor=terrainEdgeColor, LineWidth=1, Tag='Terrain');
    terrainTable = table(wayPoints3D(:,1), wayPoints3D(:,2), wayPoints3D(:,3), 'VariableNames', {'Latitude', 'Longitude', 'Elevation'});
    plot.datatip.Template(hTerrain, 'RFLink.Terrain', terrainTable)

    if ~isempty(firstObstructionIdx)
        stem(hAxes, profileDistanceKm(firstObstructionIdx), wayPoints3D(firstObstructionIdx,3), 'filled', 'Marker', 'square', 'MarkerSize', 8, 'MarkerFaceColor', colorObstruction, 'LineStyle', '-.', 'Color', colorObstruction, 'PickableParts', 'none', 'Tag', 'FirstObstruction');
    end
    
    % (b) Estações TX e RX
    stem(hAxes, 0,              txAntennaElevation, 'filled', 'MarkerFaceColor', colorStation, 'Color', colorStation,                'PickableParts', 'none', 'Tag', 'Station');
    stem(hAxes, linkDistanceKm, rxAntennaElevation, 'filled', 'MarkerFaceColor', colorStation, 'Color', colorStation, 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Station');
        
    % (c) Linha de visada entre TX e RX
    hLOS = plot(hAxes, profileDistanceKm, losHeight, 'Color', colorLink, 'LineStyle', '-.', 'LineWidth', .5,  'Tag', 'Link');
    losTable = table(profileDistanceKm, losHeight, pathLoss, 'VariableNames', {'Distance', 'Height', 'PathLoss'});
    plot.datatip.Template(hLOS, 'RFLink.LOS', losTable)

    % (d) 1ª Zona de Fresnel
    images.roi.Polygon( ...
        hAxes, ...
        Position=[profileDistanceKm, losHeight+fresnelRadius; flip(profileDistanceKm), flip(losHeight-fresnelRadius)],  ...
        Color=colorFresnel, ...
        Deletable=0, ...
        EdgeAlpha=.35, ...
        FaceAlpha=.15, ...
        FaceSelectable=0, ...
        InteractionsAllowed='none', ...
        LineWidth=.5, ...
        Tag='Fresnel' ...
    );

    yLimMin = max(hAxes.YLim(1), min(wayPoints3D(:,3))-10);
    if ~wayPoints3D(1,3) || ~wayPoints3D(end,3)
        yLimMin = -10;
    end

    hAxes.YLim(1) = yLimMin;
    hTerrain.BaseValue = hAxes.YLim(1);

    % (e) Visualização do eixo (OPCIONAL) e labels das estações TX e RX
    txLabel      = 'TX   ';
    rxLabel      = '  RX';
    txLabelAlign = 'right';
    rxLabelAlign = 'left';

    if rotateViewFlag
        if txSite.Longitude <= rxSite.Longitude
            hAxes.View   = [0,90];
        else
            hAxes.View   = [180,270];
            txLabel      = '  TX';
            rxLabel      = 'RX   ';
            txLabelAlign = 'left';
            rxLabelAlign = 'right';
        end
    end

    text(hAxes, 0,              txAntennaElevation, txLabel, 'Color', colorStation, 'HorizontalAlignment', txLabelAlign, 'VerticalAlignment', 'bottom', 'FontSize', 10, 'PickableParts', 'none', 'Tag', 'StationLabel');
    text(hAxes, linkDistanceKm, rxAntennaElevation, rxLabel, 'Color', colorStation, 'HorizontalAlignment', rxLabelAlign, 'VerticalAlignment', 'bottom', 'FontSize', 10, 'PickableParts', 'none', 'Tag', 'StationLabel');

    % ## post-Plot
    hAxes.UserData = struct('TX', txSite, 'RX', rxSite, 'Distance', linkDistanceKm, 'Azimuth', az, 'TXAntennaElevation', txAntennaElevation, 'RXAntennaElevation', rxAntennaElevation);
    plot.axes.StackingOrder.execute(hAxes, 'RFLink')
end

%-------------------------------------------------------------------------%
function varargout = getPlotColor(plotMode, plotTag)
    % O terreno usa o mesmo par de cores nos dois modos: âmbar com borda 
    % escura, legível sobre basemaps claros, escuros e de satélite.
    if strcmp(plotTag, 'Terrain')
        terrainFaceColor = '#FFFF00';
        terrainEdgeColor = '#997A00';
        varargout = {terrainFaceColor, terrainEdgeColor};
        return
    end

    switch plotMode
        case 'light'
            switch plotTag
                case 'FirstObstruction'
                    varargout = {'#FFFF00'};
                case {'Station', 'Link'}
                    varargout = {'#ff365e'};
                case 'Fresnel'
                    varargout = {[1, 0.21, 0.37]};
            end

        case 'dark'
            switch plotTag
                case 'FirstObstruction'
                    varargout = {[.94,.94,.94]};
                case {'Station', 'Link', 'Fresnel'}
                    varargout = {'cyan'};
            end
    end
end