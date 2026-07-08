function generateWaterfallImages(inputDir, outputDir)
    arguments
        inputDir  (1,:) char = 'D:\sample-files\appAnalise\inputs\Combo11 (CRFS Bin - PMEC e PMRD 2025)'
        outputDir (1,:) char = ''
    end

    if isempty(outputDir)
        outputDir = fullfile(inputDir, 'waterfall-images');
    end

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    releaseYear = char(matlabRelease.Release);
    releaseYear = str2double(releaseYear(2:end-1));
    
    % Cria figura, painel e eixo para renderização das imagens.
    figureHandle = uifigure("WindowState", "fullscreen");
    
    tiledLayout = tiledlayout(figureHandle, 1, 1, ...
        'TileSpacing', 'none', ...
        'Padding', 'compact' ...
    );
    
    axesHandle = uiaxes(tiledLayout, ...
        Color=[0, 0, 0], ColorScale='log', ...
        XGrid='off', XMinorGrid='off', YGrid='off', YMinorGrid='off', TickDir='none', ...
        XTickLabel={}, YTickLabel={}, Interactions=[], Toolbar=[] ...
    );
    hold(axesHandle, 'on');
    drawnow

    % Carrega as configurações gerais do aplicativo e cria 
    % o objeto de banda, que armazenará os limites dos eixos.
    generalSettings = jsondecode(fileread('C:\InovaFiscaliza\appAnalise\src\config\GeneralSettings.json'));
    mainApp = struct('General', generalSettings);
    bandObj = model.Band('appAnalise:REPORT:BAND', mainApp);

    % Itera sobre os arquivos no diretório de entrada, 
    % processando cada arquivo de dados espectrais.
    d = dir(inputDir);

    for ii = 1:numel(d)
        fileName = fullfile(d(ii).folder, d(ii).name);
        [~, ~, fileExt] = fileparts(fileName);
        if ~isfile(fileName)
            continue;
        end

        try
            specData = model.SpecData.empty;
            specData = read(specData, fileName, 'SingleFile');

            for jj = 1:numel(specData)
                specData(jj).UserData.PlotDisplayConfig = model.UserData.getFieldTemplate('DefaultPlotDisplayConfig', generalSettings);
                updateSpectrumInfo(bandObj, specData(jj));
                bandTag = sprintf('%.3f - %.3f MHz', bandObj.FreqStart, bandObj.FreqStop);
                
                minValue = min(specData(jj).Data{3}(:, 1));
                maxValue = max(specData(jj).Data{3}(:, 3));
                minBlueScreen = min(minValue+30, maxValue-30);
    
                cLimits = { ...
                    bandObj.CLimits, ... % Critério: plot appAnalise
                    [minValue, maxValue], ... % Critério: minHold+maxHold
                    [minBlueScreen, minBlueScreen+30] ... % Critério: "Tela azul"
                };
    
                for kk = 1:numel(cLimits)
                    if kk == 1
                        plot.Waterfall('Creation', [], axesHandle, bandObj);
                        ysecondarylabel(axesHandle, '')
                    end
                    set(axesHandle, 'XLim', bandObj.XLimits, 'CLim', cLimits{kk})
        
                    imgFileNameHR = fullfile(outputDir, replace(d(ii).name, fileExt, sprintf('_HR_Flow%d_CLimits%d (%s).png', jj, kk, bandTag)));
                    imgFileNameLR = fullfile(outputDir, replace(d(ii).name, fileExt, sprintf('_LR_Flow%d_CLimits%d (%s).png', jj, kk, bandTag)));
                    
                    % Imagem em ALTA RESOLUÇÃO, em 300 dpi. A resolução, em 
                    % pixels, depende da configuração de "ScreenPixelsPerInch".
                    exportgraphics(axesHandle, imgFileNameHR, 'ContentType', 'image', 'Units', 'pixels', 'Resolution', 300)
                    while true
                        pause(1)
                        if isfile(imgFileNameHR)
                            break
                        end
                    end
                    
                    % Imagem em BAIXA RESOLUÇÃO, 640x640 pixels, entrada dos
                    % modelos YOLO, sem precisar que seja feito recorte.
                    if releaseYear >= 2025
                        exportgraphics(axesHandle, imgFileNameLR, 'ContentType', 'image', 'Units', 'pixels', 'Width', 640, 'Height', 640, 'Padding', 0)
                        while true
                            pause(1)
                            if isfile(imgFileNameLR)
                                break
                            end
                        end
                    end
                end
            end
        catch
        end

        cla(axesHandle)
        delete(specData)
    end

    delete(figureHandle)
end