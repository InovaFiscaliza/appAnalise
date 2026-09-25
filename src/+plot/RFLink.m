function RFLink(hAxes, txSite, rxSite, wayPoints3D, plotMode, rotateViewFlag, footnoteFlag)
    arguments
        hAxes
        txSite
        rxSite
        wayPoints3D
        plotMode   char {mustBeMember(plotMode,  {'dark', 'light'})}  = 'light'
        rotateViewFlag logical = false
        footnoteFlag   logical = false
    end

    % ## prePlot
    % (a) Altura das estações TX-RX.
    txAntenna = wayPoints3D(1,3);
    if txSite.AntennaHeight > 0
        txAntenna = txAntenna + txSite.AntennaHeight;
    end

    rxAntenna = wayPoints3D(end,3);
    if rxSite.AntennaHeight > 0
        rxAntenna = rxAntenna + rxSite.AntennaHeight;
    end

    % (b) 1ª Zona de Fresnel, atenuação no espaço livre, análise de visada 
    %     entre TX e RX, distância e azimute.
    [rn, distMeters, d1, az] = RF.Propagation.FresnelZone(txSite, rxSite, height(wayPoints3D));
    d1  = double(d1); % força double porque fspl só aceita double
    vq  = interp1([0, distMeters], [txAntenna, rxAntenna], d1, 'linear');    
    PL  = fspl(d1, physconst('LightSpeed')/txSite.TransmitterFrequency);
    [~, xFirstObstruction] = RF.Propagation.LOS(wayPoints3D(:,3), vq, rn);

    % (c) Cores
    [faceColorTerrain, ...
     edgeColorTerrain] = Color(plotMode, 'Terrain');
    colorObstruction   = Color(plotMode, 'FirstObstruction');
    colorStation       = Color(plotMode, 'Station');
    colorLink          = Color(plotMode, 'Link');
    colorFresnel       = Color(plotMode, 'Fresnel');

    % ## Plot
    cla(hAxes)
    hAxes.XLimMode = 'auto';
    hAxes.YLimMode = 'auto';

    % (a) Perfil de terreno e primeira obstrução (caso aplicável)
    hTerrain = area(hAxes, d1/1000, wayPoints3D(:,3), BaseValue=0, FaceColor=faceColorTerrain, EdgeColor=edgeColorTerrain, Tag='Terrain');
    hTerrainTable = table(wayPoints3D(:,1), wayPoints3D(:,2), wayPoints3D(:,3), 'VariableNames', {'Latitude', 'Longitude', 'Elevation'});
    plot.datatip.Template(hTerrain, 'RFLink.Terrain', hTerrainTable)

    if ~isempty(xFirstObstruction)
        stem(hAxes, d1(xFirstObstruction)/1000, wayPoints3D(xFirstObstruction,3), 'filled', 'Marker', 'square', 'MarkerSize', 8, 'MarkerFaceColor', colorObstruction, 'LineStyle', '-.', 'Color', colorObstruction, 'PickableParts', 'none', 'Tag', 'FirstObstruction');
    end
    
    % (b) Estações TX e RX
    stem(hAxes, 0,          txAntenna, 'filled', 'MarkerFaceColor', colorStation, 'Color', colorStation,                'PickableParts', 'none', 'Tag', 'Station');
    stem(hAxes, distMeters/1000, rxAntenna, 'filled', 'MarkerFaceColor', colorStation, 'Color', colorStation, 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Station');
        
    % (c) Linha de visada entre TX e RX
    hLOS = plot(hAxes, d1/1000, vq, 'Color', colorLink, 'LineStyle', '-.', 'LineWidth', .5,  'Tag', 'Link');
    hLOSTable = table(d1/1000, vq, PL, 'VariableNames', {'Distance', 'Height', 'PathLoss'});
    plot.datatip.Template(hLOS, 'RFLink.LOS', hLOSTable)

    % (d) 1ª Zona de Fresnel
    images.roi.Polygon(hAxes, Position=[d1/1000, vq+rn; flip(d1/1000), flip(vq-rn)], ...
                              Color=colorFresnel, ...
                              Deletable=0, ...
                              EdgeAlpha=.25, ...
                              FaceAlpha=.05, ...
                              FaceSelectable=0, ...
                              InteractionsAllowed='none', ...
                              LineWidth=.5, ...
                              Tag='Fresnel');

    yLim1 = max(hAxes.YLim(1), min(wayPoints3D(:,3))-10);
    if ~wayPoints3D(1,3) || ~wayPoints3D(end,3)
        yLim1 = -10;
    end

    hAxes.YLim(1) = yLim1;
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

    text(hAxes, 0,          txAntenna, txLabel, 'Color', colorStation, 'HorizontalAlignment', txLabelAlign, 'VerticalAlignment', 'bottom', 'FontSize', 10, 'PickableParts', 'none', 'Tag', 'StationLabel');
    text(hAxes, distMeters/1000, rxAntenna, rxLabel, 'Color', colorStation, 'HorizontalAlignment', rxLabelAlign, 'VerticalAlignment', 'bottom', 'FontSize', 10, 'PickableParts', 'none', 'Tag', 'StationLabel');

    % (f) Nota de rodapé (OPCIONAL)
    if footnoteFlag
        footNotePosition = 0;
        footNoteAlign = 'left';
        
        if ((txAntenna > rxAntenna) && isequal(hAxes.View, [0,90])) || ...
           ((txAntenna < rxAntenna) && isequal(hAxes.View, [180,270]))
            footNotePosition = 1;
            footNoteAlign    = 'right';
        end

        Footnote = sprintf(['\n\\bfTX\nID: %s\nFrequência: %.3f MHz\nLocalização: (%.6fº, %.6fº, %.1fm)\nAltura: %.1fm\n\n'                         ...
                            '\\bfRX\nLocalização: (%.6fº, %.6fº, %.1fm)\nAltura: %.1fm\n\n'                                                         ...
                            '\\bfTX-RX\nDistância: %.1f km\nAzimute: %.1fº\nAtenuação espaço livre: %.1f dB'],                                      ...
                            txSite.ID, txSite.TransmitterFrequency/1e+6, txSite.Latitude, txSite.Longitude, wayPoints3D(1,3), txSite.AntennaHeight, ...
                            rxSite.Latitude, rxSite.Longitude, wayPoints3D(end,3), rxSite.AntennaHeight, distMeters/1000, az, PL(end));
        text(hAxes, footNotePosition, 1, Footnote, Units='normalized', FontSize=10, Interpreter='tex', HorizontalAlignment=footNoteAlign, VerticalAlignment='top', PickableParts='none', Tag='Footnote');
    end

    % ## post-Plot
    hAxes.UserData = struct('TX', txSite, 'RX', rxSite, 'Distance', distMeters/1000, 'Azimuth', az, 'TXAntennaElevation', txAntenna, 'RXAntennaElevation', rxAntenna);
    plot.axes.StackingOrder.execute(hAxes, 'RFLink')
end

%-------------------------------------------------------------------------%
function varargout = Color(plotMode, plotTag)
    switch plotMode
        case 'light'
            switch plotTag
                case 'Terrain'
                    FaceColor = [0.94,.94,.94];
                    EdgeColor = [0.80,0.80,0.80];
                    varargout = {FaceColor, EdgeColor};
                case 'FirstObstruction'
                    Color     = [0,0,0];
                    varargout = {Color};
                case {'Station', 'Link'}
                    Color     = '#c94756';
                    varargout = {Color};
                case 'Fresnel'
                    Color     = 'red';
                    varargout = {Color};
            end

        case 'dark'
            switch plotTag
                case 'Terrain'
                    FaceColor = '#333333';
                    EdgeColor = '#777777';
                    varargout = {FaceColor, EdgeColor};
                case 'FirstObstruction'
                    Color     = [.94,.94,.94];
                    varargout = {Color};
                case 'Station'
                    Color     = 'cyan';
                    varargout = {Color};
                case {'Link', 'Fresnel'}
                    Color     = 'cyan';
                    varargout = {Color};
            end
    end
end