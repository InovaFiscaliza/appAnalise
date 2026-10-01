classdef Player
    % Controle do PLAYBACK de uma tarefa de monitoração do espectro radioelétrico,
    % acionado por auxApp.winPlayback e auxApp.winDriveTest.
    %
    % Para que seja operacional, o app deve expor publicamente as seguintes propriedades
    % (o que deve ser validado por meio de chamada à util.Player.boot no startup do app):
    % 
    %   Nome              Tipo                           Acesso exigido   Uso
    %   ----------------  -----------------------------  ---------------  ---------------------------------------------
    %   plotUpdateEvent   double                         leitura/escrita  0 = pausado; ~=0 = reprodução em andamento
    %   sweepTimeIdx      double                         leitura/escrita  índice da varredura corrente
    %   tool_Play         matlab.ui.control.Image        leitura          escrita em ImageSource
    %   tool_LoopControl  matlab.ui.control.Image        leitura          UserData.loopMode (logical) e ImageSource
    %   mainApp           matlab.apps.AppBase            leitura          General.context.PLAYBACK.minSweepTimeSeconds

    methods (Static)
        %-----------------------------------------------------------------%
        function boot(app)
            % Falha cedo se o app não expõe, como públicas, as propriedades exigidas.
            arguments
                app {mustBeA(app, 'matlab.apps.AppBase')}
            end

            requiredProps = struct( ...
                'name',     {'plotUpdateEvent', 'sweepTimeIdx', 'tool_Play', 'tool_LoopControl', 'mainApp'}, ...
                'needsSet', {true,              true,           false,       false,              false} ...
            );

            propList = metaclass(app).PropertyList;
            propName = {propList.Name};

            missingProps   = {};
            nonPublicProps = {};
            for ii = 1:numel(requiredProps)
                idx = find(strcmp(propName, requiredProps(ii).name), 1);
                if isempty(idx)
                    missingProps{end+1} = requiredProps(ii).name; %#ok<AGROW>
                    continue
                end

                isPublicGet = isequal(propList(idx).GetAccess, 'public');
                isPublicSet = isequal(propList(idx).SetAccess, 'public');
                if ~isPublicGet || (requiredProps(ii).needsSet && ~isPublicSet)
                    nonPublicProps{end+1} = requiredProps(ii).name; %#ok<AGROW>
                end
            end

            if ~isempty(missingProps) || ~isempty(nonPublicProps)
                error('util:Player:IncompatibleApp', ...
                    'App compatibility check failed for util.Player. Missing properties: [%s]. Non-public properties: [%s].', ...
                    strjoin(missingProps, ', '), strjoin(nonPublicProps, ', '));
            end
        end

        %-----------------------------------------------------------------%
        function toggle(app, callbacks)
            % Toggle playback using callbacks supplied by the owning app.
            util.Player.validateCallbacks(callbacks)

            if app.plotUpdateEvent ~= 0
                app.plotUpdateEvent = 0;
                return
            end

            numSweeps = callbacks.getNumSweeps();
            if isempty(numSweeps) || ~isscalar(numSweeps) || ~isfinite(numSweeps) || numSweeps < 1
                return
            end

            callbacks.onPlaybackStarted();
            app.plotUpdateEvent = 1;
            util.Player.run(app, numSweeps, callbacks)
        end

        %-----------------------------------------------------------------%
        function run(app, numSweeps, callbacks)
            % Run playback; the app callback interprets its event codes.
            util.Player.validateCallbacks(callbacks)
            if isempty(numSweeps) || ~isscalar(numSweeps) || ~isfinite(numSweeps) || numSweeps < 1
                return
            end

            app.tool_Play.ImageSource = 'playback-stop-16px-gray.png';
            cleanup = onCleanup(@()util.Player.finish(app, callbacks));

            while app.sweepTimeIdx <= numSweeps
                iteration = callbacks.prepareIteration(numSweeps);
                numSweeps = iteration.numSweeps;
                shouldContinue = iteration.shouldContinue;

                if ~shouldContinue || app.plotUpdateEvent == 0 || isempty(numSweeps) || numSweeps < 1
                    app.sweepTimeIdx = max(1, app.sweepTimeIdx-1);
                    break
                end

                if isempty(app.sweepTimeIdx) || app.sweepTimeIdx < 1 || app.sweepTimeIdx > numSweeps
                    break
                end

                sweepTic = tic;
                callbacks.renderFrame();

                minSweepTime = app.mainApp.General.context.PLAYBACK.minSweepTimeSeconds;
                pause(max(minSweepTime - toc(sweepTic), .025))

                if app.sweepTimeIdx == numSweeps
                    if ~app.tool_LoopControl.UserData.loopMode || app.plotUpdateEvent == 0
                        break
                    end
                    app.sweepTimeIdx = 1;
                else
                    app.sweepTimeIdx = app.sweepTimeIdx + 1;
                end
            end
        end

        %-----------------------------------------------------------------%
        function toggleLoop(app)
            app.tool_LoopControl.UserData.loopMode = ~app.tool_LoopControl.UserData.loopMode;

            if app.tool_LoopControl.UserData.loopMode
                app.tool_LoopControl.ImageSource = 'playback-loop-36px-gray.png';
            else
                app.tool_LoopControl.ImageSource = 'playback-straight-36px-gray.png';
            end
        end

        %-----------------------------------------------------------------%
        function seek(app, sliderValue, numSweeps, renderFrameFcn)
            % Seek to a percentage position and render only while paused.
            if isempty(numSweeps) || numSweeps < 1
                return
            end

            app.sweepTimeIdx = util.Player.indexFromSlider(sliderValue, numSweeps);
            if app.plotUpdateEvent == 0
                renderFrameFcn();
            end
        end

        %-----------------------------------------------------------------%
        function step(app, direction, numSweeps, renderFrameFcn)
            % Move by one sweep while playback is stopped.
            if app.plotUpdateEvent ~= 0 || isempty(numSweeps) || numSweeps < 1
                return
            end

            currentIdx = min(max(round(app.sweepTimeIdx), 1), numSweeps);
            nextIdx = min(max(currentIdx + sign(direction), 1), numSweeps);
            if nextIdx == currentIdx
                return
            end

            app.sweepTimeIdx = nextIdx;
            renderFrameFcn();
        end

        %-----------------------------------------------------------------%
        function handleKey(app, key, modifiers, callbacks)
            % Handle common playback keys when the app enables keyboard input.
            if ~isempty(modifiers)
                return
            end

            key = lower(char(key));
            keypadDigit = regexp(key, '^(?:numpad|keypad|kp)[ _-]*([1-9])$', 'tokens', 'once');
            if ~isempty(keypadDigit)
                key = keypadDigit{1};
            end

            switch key
                case 'space'
                    util.Player.toggle(app, callbacks)
                case {'leftarrow', 'rightarrow'}
                    numSweeps = callbacks.getNumSweeps();
                    direction = 2 * strcmp(key, 'rightarrow') - 1;
                    util.Player.step(app, direction, numSweeps, callbacks.renderFrame)
                case {'home', 'end', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                    if app.plotUpdateEvent ~= 0
                        return
                    end

                    switch key
                        case 'home'
                            percentage = 0;
                        case 'end'
                            percentage = 100;
                        otherwise
                            percentage = str2double(key) * 10;
                    end

                    numSweeps = callbacks.getNumSweeps();
                    util.Player.seek(app, percentage, numSweeps, callbacks.renderFrame)
            end
        end
    end


    methods (Static, Access = private)
        %-----------------------------------------------------------------%
        function idx = indexFromSlider(sliderValue, numSweeps)
            idx = round(sliderValue / 100 * numSweeps);
            idx = min(max(idx, 1), numSweeps);
        end

        %-----------------------------------------------------------------%
        function validateCallbacks(callbacks)
            requiredCallbacks = {'getNumSweeps', 'onPlaybackStarted', 'prepareIteration', 'renderFrame'};
            if ~isstruct(callbacks) || ~isscalar(callbacks) || ~all(isfield(callbacks, requiredCallbacks))
                error('util:Player:InvalidCallbacks', ...
                    'Callbacks must define getNumSweeps, onPlaybackStarted, prepareIteration, and renderFrame.');
            end

            for ii = 1:numel(requiredCallbacks)
                if ~isa(callbacks.(requiredCallbacks{ii}), 'function_handle')
                    error('util:Player:InvalidCallbacks', ...
                        'Callback "%s" must be a function handle.', requiredCallbacks{ii});
                end
            end
        end

        %-----------------------------------------------------------------%
        function finish(app, callbacks)
            app.plotUpdateEvent = 0;
            app.tool_Play.ImageSource = 'playback-play-16px-gray.png';

            if isfield(callbacks, 'onPlaybackStopped') && isa(callbacks.onPlaybackStopped, 'function_handle')
                callbacks.onPlaybackStopped();
            end
        end
    end
end
