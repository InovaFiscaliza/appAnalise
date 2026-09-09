function [hasObstruction, obstructionDistance, obstructionElevation] = hasFirstFresnelObstruction(txSite, rxSite, wayPoints3D)
    % hasFirstFresnelObstruction Detecta a penetracao do terreno na zona F1.
    hasObstruction = false;
    obstructionDistance = [];
    obstructionElevation = [];

    if size(wayPoints3D, 2) < 3 || size(wayPoints3D, 1) < 3
        return
    end

    txAntenna = wayPoints3D(1, 3);
    if txSite.AntennaHeight > 0
        txAntenna = txAntenna + txSite.AntennaHeight;
    end

    rxAntenna = wayPoints3D(end, 3);
    if rxSite.AntennaHeight > 0
        rxAntenna = rxAntenna + rxSite.AntennaHeight;
    end

    [~, distM, d1] = RF.Propagation.FresnelZone(txSite, rxSite, size(wayPoints3D, 1));
    if ~isfinite(distM) || distM <= 0
        return
    end

    d1 = double(d1(:));
    terrain = double(wayPoints3D(:, 3));
    los = interp1([0, distM], [txAntenna, rxAntenna], d1, 'linear');

    % Densifica a avaliacao para capturar a interseccao entre amostras.
    densePointCount = max(4097, 10 * (numel(d1) - 1) + 1);
    d1Dense = linspace(d1(1), d1(end), densePointCount)';
    terrainDense = interp1(d1, terrain, d1Dense, 'linear');
    losDense = interp1(d1, los, d1Dense, 'linear');

    lambda = physconst('LightSpeed') / txSite.TransmitterFrequency;
    d2Dense = distM - d1Dense;
    fresnelRadiusDense = sqrt((d1Dense .* d2Dense / distM) * lambda);

    finitePoints = isfinite(terrainDense) & isfinite(losDense) & isfinite(fresnelRadiusDense);
    clearance = losDense - fresnelRadiusDense - terrainDense;
    isObstructed = finitePoints & (clearance <= 1e-3);
    isObstructed([1, end]) = false;

    obstructionIdx = find(isObstructed, 1);
    if ~isempty(obstructionIdx)
        hasObstruction = true;
        obstructionDistance = d1Dense(obstructionIdx);
        obstructionElevation = terrainDense(obstructionIdx);
    end
end
