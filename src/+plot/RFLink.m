function RFLink(hAxes, txSite, rxSite, wayPoints3D, preditionData, plotMode, rotateViewFlag, footnoteFlag, clutterCategories, clutterHeights, fieldStrengthData)
    arguments
        hAxes
        txSite
        rxSite
        wayPoints3D
        preditionData     struct  = struct.empty
        plotMode          char {mustBeMember(plotMode,  {'dark', 'light'})}  = 'light'
        rotateViewFlag    logical = false
        footnoteFlag      logical = false
        clutterCategories double  = []
        clutterHeights    double  = []
        fieldStrengthData struct  = struct.empty
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
    [Rn, distM, d1, Azimuth] = RF.Propagation.FresnelZone(txSite, rxSite, height(wayPoints3D));
    d1  = double(d1); % força double porque fspl só aceita double
    vq  = interp1([0, distM], [txAntenna, rxAntenna], d1, 'linear');    
    PL  = fspl(d1, physconst('LightSpeed')/txSite.TransmitterFrequency);
    [~, xFirstObstruction] = RF.Propagation.LOS(wayPoints3D(:,3), vq, Rn);

    % (c) Cores
    [faceColorTerrain, ...
     edgeColorTerrain] = Color(plotMode, 'Terrain');
    colorObstruction   = Color(plotMode, 'FirstObstruction');
    colorStation       = Color(plotMode, 'Station');
    colorLink          = Color(plotMode, 'Link');
    colorFresnel       = Color(plotMode, 'Fresnel');
    colorClutter       = Color(plotMode, 'Clutter');

    % ## Plot
    cla(hAxes)
    if ~isempty(fieldStrengthData)
        yyaxis(hAxes, 'right'); cla(hAxes);
        yyaxis(hAxes, 'left');
    end
    hAxes.XLimMode = 'auto';
    hAxes.YLimMode = 'auto';

    % (a) Clutter colorido por categoria (caso disponível) — plotado antes do terreno
    if ~isempty(clutterCategories) && ~isempty(clutterHeights) && numel(clutterCategories) == height(wayPoints3D)
        for n = 1:(numel(d1) - 1)
            cor = ceil(clutterCategories(n));
            if isnan(cor) || cor < 1; cor = 1; end
            if cor > size(colorClutter, 1); cor = size(colorClutter, 1); end
            if clutterHeights(n) > 0
                fill(hAxes, [d1(n)/1000, d1(n)/1000, d1(n+1)/1000, d1(n+1)/1000], ...
                    [wayPoints3D(n,3), wayPoints3D(n,3)+clutterHeights(n), ...
                     wayPoints3D(n,3)+clutterHeights(n), wayPoints3D(n,3)], ...
                    colorClutter(cor,:), 'EdgeColor', 'none', 'PickableParts', 'none', 'Tag', 'Clutter');
            end
        end
    end

    % (b) Perfil de terreno e primeira obstrução (caso aplicável)
    hTerrain = area(hAxes, d1/1000, wayPoints3D(:,3), BaseValue=0, FaceColor=faceColorTerrain, EdgeColor=edgeColorTerrain, Tag='Terrain');
    hTerrainTable = table(wayPoints3D(:,1), wayPoints3D(:,2), wayPoints3D(:,3), 'VariableNames', {'Latitude', 'Longitude', 'Elevation'});
    plot.datatip.Template(hTerrain, 'RFLink.Terrain', hTerrainTable)

    if ~isempty(xFirstObstruction)
        stem(hAxes, d1(xFirstObstruction)/1000, wayPoints3D(xFirstObstruction,3), 'filled', 'Marker', 'square', 'MarkerSize', 8, 'MarkerFaceColor', colorObstruction, 'LineStyle', '-.', 'Color', colorObstruction, 'PickableParts', 'none', 'Tag', 'FirstObstruction');
    end
    
    % (b) Estações TX e RX
    stem(hAxes, 0,          txAntenna, 'filled', 'MarkerFaceColor', colorStation, 'Color', colorStation,                'PickableParts', 'none', 'Tag', 'Station');
    stem(hAxes, distM/1000, rxAntenna, 'filled', 'MarkerFaceColor', colorStation, 'Color', colorStation, 'Marker', '^', 'PickableParts', 'none', 'Tag', 'Station');
        
    % (c) Linha de visada entre TX e RX
    hLOS = plot(hAxes, d1/1000, vq, 'Color', colorLink, 'LineStyle', ':',  'LineWidth', .5, 'Tag', 'Link');
    hLOSTable = table(d1/1000, vq, PL, 'VariableNames', {'Distance', 'Height', 'PathLoss'});
    plot.datatip.Template(hLOS, 'RFLink.LOS', hLOSTable)

    % (d) 1ª Zona de Fresnel
    plot(hAxes, d1/1000, vq+Rn, 'LineStyle', '-.', 'LineWidth', 1, 'Color', colorFresnel, 'PickableParts', 'none', 'Tag', 'Fresnel');
    plot(hAxes, d1/1000, vq-Rn, 'LineStyle', '-.', 'LineWidth', 1, 'Color', colorFresnel, 'PickableParts', 'none', 'Tag', 'Fresnel');

    yLim1 = max(hAxes.YLim(1), min(wayPoints3D(:,3))-10);
    if ~wayPoints3D(1,3) || ~wayPoints3D(end,3)
        yLim1 = -10;
    end

    if ~isempty(fieldStrengthData); yyaxis(hAxes, 'left'); end
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
    text(hAxes, distM/1000, rxAntenna, rxLabel, 'Color', colorStation, 'HorizontalAlignment', rxLabelAlign, 'VerticalAlignment', 'bottom', 'FontSize', 10, 'PickableParts', 'none', 'Tag', 'StationLabel');

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
                            rxSite.Latitude, rxSite.Longitude, wayPoints3D(end,3), rxSite.AntennaHeight, distM/1000, Azimuth, PL(end));
        text(hAxes, footNotePosition, 1, Footnote, Units='normalized', FontSize=10, Interpreter='tex', HorizontalAlignment=footNoteAlign, VerticalAlignment='top', PickableParts='none', Tag='Footnote');
    end

    % (g) Campo elétrico / potência recebida no eixo direito (OPCIONAL)
    if ~isempty(fieldStrengthData)
        yyaxis(hAxes, 'right')
        plot(hAxes, fieldStrengthData.distances, fieldStrengthData.values, ...
            'Color', [0.8510, 0.3255, 0.0980], 'LineWidth', 1, ...
            'PickableParts', 'none', 'Tag', 'FieldStrength');
        hAxes.YLim(1) = 0;
        hAxes.YLim(2) = 1.5 * max(fieldStrengthData.values);
        ylabel(hAxes, fieldStrengthData.label);
        yyaxis(hAxes, 'left')
    end

    % ## post-Plot

    % % Predição de propagação (OPCIONAL) — suporta P.526 e P.1812
    % if ~isempty(preditionData) && preditionData.Base.Potencia > 0
    %     [Lb_pred, E_pred] = utils.calcPredicaoEnlace(preditionData, rxSite, txAntenna, rxAntenna, distM, Azimuth, d1, wayPoints3D);
    %     fprintf('%s  Lb = %.2f dB | E = %.2f dBuV/m\n', preditionData.modeloPredicao, Lb_pred, E_pred);
    % end

    hAxes.UserData = struct('TX', txSite, 'RX', rxSite, 'Distance', distM/1000, 'Azimuth', Azimuth, 'TXAntennaElevation', txAntenna, 'RXAntennaElevation', rxAntenna);
    plot.axes.StackingOrder.execute(hAxes, 'RFLink')
end

%-------------------------------------------------------------------------%
function varargout = Color(plotMode, plotTag)
    % Clutter: cores independentes de tema (5 categorias ITU-R P.1812)
    if strcmp(plotTag, 'Clutter')
        varargout = {[   0,      0.4863,      1; ...  % 1 - Água
                      0.0431,   0.8627, 0.0431; ...  % 2 - Rural
                         1,      0.4980, 0.4980; ...  % 3 - Suburbano
                      0.3098,   0.6824,      0; ...  % 4 - Urbano
                      0.7020,   0.1490, 0.2431]}; ... % 5 - Denso
        return
    end

    switch plotMode
        case 'light'
            switch plotTag
                case 'Terrain'
                    FaceColor = '#90a2b5';
                    EdgeColor = '#101010';
                    varargout = {FaceColor, EdgeColor};
                case 'FirstObstruction'
                    Color     = [0,0,0];
                    varargout = {Color};
                case 'Station'
                    Color     = '#c94756';
                    varargout = {Color};
                case 'Link'
                    Color     = '#00f9ff';
                    varargout = {Color};
                case 'Fresnel'
                    Color     = '#007cff';
                    varargout = {Color};
            end

        case 'dark'
            switch plotTag
                case 'Terrain'
                    FaceColor = '#1e3a4f';
                    EdgeColor = '#2a5a7a';
                    varargout = {FaceColor, EdgeColor};
                case 'FirstObstruction'
                    Color     = [.94,.94,.94];
                    varargout = {Color};
                case 'Station'
                    Color     = 'cyan';
                    varargout = {Color};
                case 'Link'
                    Color     = 'cyan';
                    varargout = {Color};
                case 'Fresnel'
                    Color     = '#007cff';
                    varargout = {Color};
            end
    end
end