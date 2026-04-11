classdef (Abstract) Interactivity

    % As interações com os eixos são de duas naturezas - TOOLBAR e DEFAULT.
    % A TOOLBAR demanda interação com o toolbar do eixo, que fica visível toda
    % vez que o mouse está sobre o eixo, englobando todas as interações com o
    % eixo, incluindo salvar a imagem em arquivo, por exemplo; a DEFAULT, por 
    % outro lado, contempla apenas interações que podem ser aplicadas pelo mouse 
    % ou teclado diretamente no eixo, não demandando "habilitar" no toolbar a 
    % interação.

    % (1) DEFAULT
    %     • hAxes.Interactions = [dataTipInteraction, regionZoomInteraction];
    %     • Interações:
    %       - dataTipInteraction
    %       - panInteraction
    %       - rulerPanInteraction
    %       - zoomInteraction
    %       - regionZoomInteraction (não possível em geoaxes)
    %       - rotateInteraction
    %     • Métodos:
    %       - enableDefaultInteractivity(hAxes)
    %       - disableDefaultInteractivity(hAxes)
    
    % (2) TOOLBAR
    %     • hAxes.Toolbar = axtoolbar(hAxes, {'pan', 'restoreview'});
    %     • Interações ("Type", "Tag" e "Tooltip"):
    %       - Tipo 'toolbarpushbutton'
    %         'saveas'      'Save as'
    %         'copyimage'   'Copy as image'
    %         'copyvector'  'Copy as vector graphic'
    %         'restoreview' 'Restore view'
    %       - Tipo 'toolbarstatebutton'
    %         'brush'       'Brush data'
    %         'datacursor'  'Data tips'
    %         'rotate'      'Rotate 3D'
    %         'pan'         'Pan'
    %         'zoomin'      'Zoom in'
    %         'zoomout'     'Zoom out'
    %     • Callbacks customizados:
    %       - ButtonPushedFcn
    %       - ValueChangedFcn

    % Interação implementada nos eixos do appAnalise:
    % (1) Eixo cartesiano
    %     • hAxes.Interactions = [dataTipInteraction, regionZoomInteraction];
    %     • hAxes.Toolbar = [];
    %     • O toolbar programático contém opções "RestoreView", "Pan" e "DataTip". 
    %     • Callback para forçar panInteraction, quando botão 'pan' está habilitado,
    %       e forçar regionZoomInteraction desabilitar, quando o botão "pan" está
    %       desabilitado. Implentado porque foi observado comportamentos
    %       inesperados no callback padrão do MATLAB.
    %     • Callback para forçar RestoreView para limites dos eixos xyzc orientado
    %       à preferência do usuário (customPlayback) e do próprio appAnalise
    %       (limitando eixo x à faixa de frequência, por exemplo).
    %
    % (2) Eixo geográfico
    %     • hAxes.Interactions = [dataTipInteraction, zoomInteraction, panInteraction]
    %     • hAxes.Toolbar = [];
    %     • O toolbar programático contém opções "RestoreView" e "RegionZoom". 

    % Notas: 
    %     • O dataTipInteraction não está operacional para todo tipo de plot, como 
    %       o gerado pela função image, por exemplo. Nesse caso, a alternativa
    %       é habilitar o datacursormode da figura.
    %
    %       hFig  = uifigure; 
    %       hAxes = uiaxes(hFig, 'Interactions', [], 'Toolbar', []);
    %       datacursormode(hFig, 'on')
    %       hImg  = imshow(img, 'Parent', ax);
    
    % Nomenclatura:
    %     • hAxes.....: refere-se a um único objeto uiaxes ou geoaxes. 
    %     • hMultiAxes: refere-se a um ou mais objetos uiaxes ou geoaxes.

    methods (Static = true)
        %-----------------------------------------------------------------%
        % DEFAULT: INTERAÇÕES MOUSE+TECLADO
        %-----------------------------------------------------------------%
        function DefaultCreation(hMultiAxes, interactionList)
            arguments
                hMultiAxes
                interactionList matlab.graphics.interaction.interface.BaseInteraction = [dataTipInteraction, regionZoomInteraction]
            end

            if ~isempty(interactionList)
                for ii = 1:numel(hMultiAxes)
                    hMultiAxes(ii).Interactions = interactionList;
                    enableDefaultInteractivity(hMultiAxes(ii))
                end
            else
                arrayfun(@(x) disableDefaultInteractivity(x), hMultiAxes)
            end
        end

        %-----------------------------------------------------------------%
        % TOOLBAR: INTERAÇÕES HABILITÁVEIS EM TOOLBAR (POP-UP)
        %-----------------------------------------------------------------%
        function ToolbarCreation(hMultiAxes, interaction2Add, interaction2Remove)
            arguments
                hMultiAxes
                interaction2Add         = {'pan', 'restoreview'}
                interaction2Remove cell = {}
            end

            for ii = 1:numel(hMultiAxes)
                hToolbar = axtoolbar(hMultiAxes(ii), interaction2Add);

                if isa(hMultiAxes, 'matlab.graphics.axis.GeographicAxes')
                    addToolbarMapButton(hToolbar, "basemap")
                end

                if ~isempty(interaction2Remove)
                    idx = cell2mat(cellfun(@(x) find(strcmpi(x, {hToolbar.Children.Tag})), interaction2Remove, 'UniformOutput', false));
                    delete(hToolbar.Children(idx))
                end                

                set(hToolbar.Children, 'Visible', 1)
            end
        end

        %-----------------------------------------------------------------%
        % MISCELÂNEAS RELACIONADAS ÀS INTERAÇÕES DEFAULT E TOOLBAR
        %-----------------------------------------------------------------%
        function DefaultEnable(hMultiAxes)
            arrayfun(@(x) enableDefaultInteractivity(x), hMultiAxes)
        end

        %-----------------------------------------------------------------%
        function DefaultDisable(hMultiAxes)
            arrayfun(@(x) disableDefaultInteractivity(x), hMultiAxes)
        end

        %-----------------------------------------------------------------%
        function CustomCallbacks(hAxes, hRelatedAxes, interactionToCustomize, varargin)
            arguments
                hAxes (1,1) matlab.ui.control.UIAxes
                hRelatedAxes = []
                interactionToCustomize (1,:) cell = {'pan', 'restoreview'}
            end

            arguments (Repeating)
                varargin
            end

            for ii = 1:numel(interactionToCustomize)
                [~, hInteraction] = plot.axes.Interactivity.FindInteractionObject(hAxes, 'Toolbar', interactionToCustomize{ii});

                if ~isempty(hInteraction)
                    switch interactionToCustomize{ii}
                        case 'pan'
                            if isprop(hInteraction, 'ValueChangedFcn')
                                hInteraction.ValueChangedFcn = @(~, evt)plot.axes.Interactivity.CustomPanFcn(evt, hAxes, hRelatedAxes);
                            end
        
                        case 'restoreview'
                            if isprop(hInteraction, 'ButtonPushedFcn')
                                callingApp = varargin{1};
                                hInteraction.ButtonPushedFcn = @(~, ~)plot.axes.Interactivity.CustomRestoreViewFcn(hAxes, hRelatedAxes, callingApp);
                            end
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function CustomRestoreViewFcn(hAxes, hRelatedAxes, callingApp)
            % Para que essa função customizada funcione, o callingApp precisa 
            % ter uma propriedade chamada "restoreView", que é uma estrutura 
            % com ao menos os campos "xLim" e "yLim".

            hMultiAxes = [hAxes, hRelatedAxes];

            try
                xLim = callingApp.restoreView(1).xLim;
                if isempty(xLim)
                    xLim = [0, 1];
                end
                hAxes.XLim = xLim;

                for ii = 1:numel(hMultiAxes)
                    yLim = callingApp.restoreView(ii).yLim;
                    if isempty(yLim)
                        switch class(hMultiAxes(ii).YAxis)
                            case 'matlab.graphics.axis.decorator.DatetimeRuler'
                                yLim = [datetime('now'), datetime('now')+seconds(1)];
                            otherwise % 'matlab.graphics.axis.decorator.NumericRuler'
                                yLim = [0, 1];
                        end
                    end

                    hMultiAxes(ii).YLim = yLim;
                end
            catch
            end
        end
        
        %-----------------------------------------------------------------%
        function CustomPanFcn(evt, hAxes, hRelatedAxes)
            arguments
                evt
                hAxes
                hRelatedAxes = []
            end
            
            % Para que essa função customizada funcione, os eixos precisam ter
            % sido criados com a diretiva Interactions=0. Se um eixo não for 
            % criado dessa forma, o MATLAB criará automaticamente um objeto 
            % "matlab.graphics.interaction.interface.DefaultAxesInteractionSet"
            % com uma série de interações - inclusive "panInteraction".
            
            % Essa função alterna uma das interações do eixo, entre "panInteraction"
            % e "regionZoomInteraction".

            hMultiAxes = [hAxes, hRelatedAxes];

            for ii = 1:numel(hMultiAxes)
                try
                    if evt.Value
                        idx = plot.axes.Interactivity.FindInteractionObject(hMultiAxes(ii), 'Interaction', 'matlab.graphics.interaction.interactions.RegionZoomInteraction');
                        if ~isempty(idx)
                            hMultiAxes(ii).Interactions(idx) = panInteraction;
                        else
                            if isempty(hMultiAxes(ii).Interactions)
                                hMultiAxes(ii).Interactions = panInteraction;
                            else
                                hMultiAxes(ii).Interactions(end+1) = panInteraction;
                            end
                        end
    
                    else
                        idx = plot.axes.Interactivity.FindInteractionObject(hMultiAxes(ii), 'Interaction', 'matlab.graphics.interaction.interactions.PanInteraction');
                        if ~isempty(idx)
                            hMultiAxes(ii).Interactions(idx) = regionZoomInteraction;
                        else
                            if isempty(hMultiAxes(ii).Interactions)
                                hMultiAxes(ii).Interactions = regionZoomInteraction;
                            else
                                hMultiAxes(ii).Interactions(end+1) = regionZoomInteraction;
                            end
                        end
                    end
                catch
                end
            end

            plot.axes.Interactivity.DefaultEnable(hMultiAxes)
        end

        %-----------------------------------------------------------------%
        function [idx, hInteraction] = FindInteractionObject(hAxes, axesProperty, varargin)
            % Aplicável apenas no contexto em que o eixo foi criado com a diretiva 
            % Interactions=0.

            idx = [];
            hInteraction = [];

            switch axesProperty
                case 'Toolbar'
                    if ~isempty(hAxes.Toolbar.Children)
                        tag = varargin{1};
                        idx = find(strcmpi({hAxes.Toolbar.Children.Tag}, tag), 1);
                        hInteraction = hAxes.Toolbar.Children(idx);                
                    end

                case 'Interaction'
                    if ~isempty(hAxes.Interactions)
                        objClass = varargin{1};
                        idx = find(strcmp(objClass, arrayfun(@(x) class(x), hAxes.Interactions, "UniformOutput", false)), 1);
                        hInteraction = hAxes.Interactions(idx);
                    end
            end
        end

        %-----------------------------------------------------------------%
        % ROI
        %-----------------------------------------------------------------%
        function CustomROIInteractionFcn(event, hMultiAxes, CustomFcnHandle)
            % Para que essa função customizada funcione, deve ser passado como
            % argumento de entrada um handle para a função externa (pode ser 
            % um método do callingApp, por exemplo) que efetuará as operações 
            % durante e após a movimentação do ROI.

            switch(event.EventName)
                case 'MovingROI'
                    plot.axes.Interactivity.DefaultDisable(hMultiAxes)
                case 'ROIMoved'
                    plot.axes.Interactivity.DefaultEnable(hMultiAxes)
                    CustomFcnHandle()
            end
        end

        %-----------------------------------------------------------------%
        function DeleteROIListeners(hROI)
            % Foi evidenciado que após a exclusão de ROIs o eixo poderia perder a sua
            % interatividade. Identificado que os listeners automáticos do ROI estavam
            % causando o problema. Foi criado um listener "ObjectBeingDestroyed" que 
            % garante a execução deste função, resolvendo o problema ao forçar a 
            % exclusão dos objetos.
        
            % addlistener(hROI, 'MovingROI', @ROICallback);
            % addlistener(hROI, 'ROIMoved',  @ROICallback);
            % addlistener(hROI, 'ObjectBeingDestroyed', @(src, ~)plot.axes.Interactivity.DeleteListeners(src));

            try
                listenersList = struct(hROI).AutoListeners__;
                cellfun(@(x) delete(x), listenersList)
            catch
            end
        end

        %-----------------------------------------------------------------%
        % DATATIP
        %-----------------------------------------------------------------%
        function DataCursorMode(hAxes, dataTipInteractionStatus)
            d = dictionary([true, false], ["on", "off"]);
            datacursormode(hAxes, d(dataTipInteractionStatus))
        end

        %-----------------------------------------------------------------%
        % GEOGRAPHICREGIONZOOM
        %-----------------------------------------------------------------%
        function GeographicRegionZoomInteraction(hAxes, hToolbarButton)
            disableDefaultInteractivity(hAxes)
            hToolbarButton.ImageSource = 'ZoomRegion_20Filled.png';

            r = drawrectangle(hAxes, 'FaceSelectable', 0, 'InteractionsAllowed', 'none', 'LineWidth', 1, 'FaceAlpha', 0, 'Tag', 'RegionZoom');
            if ~isempty(r.Position)                           && ...
                    all(r.Position(3:4) > 0)                  && ...
                    r.Position(1) >= hAxes.LatitudeLimits(1)  && ...
                    r.Position(1) <  hAxes.LatitudeLimits(2)  && ...
                    r.Position(2) >= hAxes.LongitudeLimits(1) && ...
                    r.Position(2) <  hAxes.LongitudeLimits(2)

                newLatitudeLimits  = [r.Position(1), sum(r.Position([1,3]))];
                newLongitudeLimits = [r.Position(2), sum(r.Position([2,4]))];

                geolimits(hAxes, newLatitudeLimits, newLongitudeLimits)
            end
            delete(r)

            hToolbarButton.ImageSource = 'ZoomRegion_20.png';
            enableDefaultInteractivity(hAxes)
        end
    end
end