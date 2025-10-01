function plotClustersWaterfall(dataMatrix, freqAxis_Hz, timeVec, freqIdx, timeIdx, labels)
% PLOTCLUSTERSWATERFALL - Plota espectrograma (freq x tempo) anotado com clusters DBSCAN
%
% Inputs:
%   dataMatrix   -> [M x N] matriz espectral (M bins de frequência, N snapshots tempo)
%   freqAxis_Hz  -> [M x 1] eixo de frequências em Hz
%   timeVec      -> [1 x N] timestamps dos snapshots (datetime ou numérico)
%   freqIdx      -> índices de linha dos pontos detectados
%   timeIdx      -> índices de coluna dos pontos detectados
%   labels       -> vetor de cluster retornado pelo DBSCAN (mesmo tamanho que freqIdx)
%
% Example:
%   plotClustersWaterfall(dataMatrix, freqAxis_Hz, timeVec, freqIdx, timeIdx, labels)

    %------------------------------------------------------%
    figure; 
    % Plota waterfall (ou pseudocolor) da dataMatrix
    if isdatetime(timeVec) || isduration(timeVec)
        tAxis = seconds(timeVec - timeVec(1)); % número relativo p/ plot
    else
        tAxis = timeVec;
    end

    % imagem de fundo
    imagesc(tAxis, freqAxis_Hz/1e6, dataMatrix);  
    axis xy; 
    colormap jet; 
    colorbar;
    xlabel('Tempo (s relativo)'); 
    ylabel('Frequência (MHz)');
    title('Waterfall com Clusters DBSCAN');

    hold on;

    %------------------------------------------------------%
    % Plota pontos dos clusters sobre a imagem
    uniqueClusters = unique(labels(labels > 0));
    cmap = lines(length(uniqueClusters)); % cores distintas

    for k = 1:length(uniqueClusters)
        c = uniqueClusters(k);
        sel = labels == c;

        scatter(tAxis(timeIdx(sel)), freqAxis_Hz(freqIdx(sel))/1e6, ...
            20, 'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', cmap(k,:), ...
            'LineWidth', 1.2, 'DisplayName', sprintf('Cluster %d', c));
    end

    legend('show');
    hold off;
end