function Misc_PlotClone(oldFigure, RootFolder)

    newFigure = figure('Name', sprintf('appAnalise: Plot referência (%s)', datestr(now, 'dd/mm/yyyy HH:MM:SS')), 'NumberTitle', 'off', ...
                       'Color', [0.94,0.94,0.94], 'GraphicsSmoothing', 'on', ...
                       'Position', oldFigure.Position, 'WindowState', oldFigure.WindowState);
    delete(findall(newFigure, '-not', 'Type', 'Figure'));

    warning('off')
    jFrame = get(newFigure, 'javaframe');
    jIcon  = javax.swing.ImageIcon(fullfile(RootFolder, 'Icons', 'LR_icon.png'));
    jFrame.setFigureIcon(jIcon);
    warning('on')


    % COPY
    copyobj(oldFigure.Children, newFigure);
    

    % TOOLBAR
    h1 = findobj(newFigure.Children, 'Type', 'uitoolbar');    
    if ~isempty(h1)
        set(h1.Children, 'Visible', 0, 'Separator', 0)

        h2 = findobj(h1.Children, 'Tag', 'plotclone');
        if ~isempty(h2)
            set(h2, 'Visible', 1, 'Separator', 0)
        end
    end


    % DATATIP & ROI INTERACTION
    h3 = findobj(newFigure.Children, 'Type', 'axes');

    Unit = '';
    for ii = numel(h3):-1:1
        strUnit = regexp(h3(ii).YLabel.String, 'Nível \((?<value>.*)\)', 'names');
        if ~isempty(strUnit)
            Unit = strUnit.value;
        end

        if isempty(h3(ii).Children)
            delete(h3(ii))
            h3(ii) = [];
        end
    end
    linkaxes(h3, 'x')

    for ii = 1:numel(h3)
        set(h3(ii).Children, 'Tag', '')

        switch h3(ii).YLabel.String
            case 'Ocupação (%)'; UnitLevel = '%%';
            otherwise;           UnitLevel = Unit;
        end

        for jj = 1:numel(h3(ii).Children)
            switch lower(h3(ii).Children(jj).Type)
                case {'line', 'surface'}
                    try
                        Misc_DataTipSettings(h3(ii).Children(jj), UnitLevel)
                    catch
                    end
                case {'images.roi.line', 'images.roi.rectangle'}
                    h3(ii).Children(jj).InteractionsAllowed = 'none';
            end
        end
    end

end