function [editedData, log] = levelFiltering(specData, idxThreads, fcnHandleStr, fcnHandleArgs, filterMode, copyMode)
    arguments
        specData
        idxThreads
        fcnHandleStr  (1,:) char = '@(matrix, minLevel, maxLevel) abs(minLevel-maxLevel) < 3'
        fcnHandleArgs (0,0) cell = {}
        filterMode    (1,:) char {mustBeMember(filterMode, {'keep', 'remove'})}  = 'remove'
        copyMode      (1,:) char {mustBeMember(copyMode,   {'copy', 'inplace'})} = 'copy'
    end

    fcnHandle = eval(fcnHandleStr);
    if ~isa(fcnHandle, 'function_handle')
        error('Invalid function_handle expression')
    end
    
    editedData = eval(class(specData)).empty;
    log = {};
    
    for ii = idxThreads
        matrix = specData(ii).Data{2};
        [minLevel, maxLevel]  = bounds(matrix);
        
        initialSweeps = numel(specData(ii).Data{1});        
        indexes = fcnHandle(matrix, minLevel, maxLevel, fcnHandleArgs{:});

        switch filterMode
            case 'keep'
                finalSweeps = sum(indexes);
            case 'remove'
                finalSweeps = sum(~indexes);
        end

        switch finalSweeps
            case initialSweeps
                log{end+1} = sprintf('Fluxo #%d: todas as varreduras atendem à condição estabelecida, portanto o processamento foi ignorado.', ii);
                continue
            case 0
                log{end+1} = sprintf('Fluxo #%d: nenhuma varredura atende à condição estabelecida, portanto o processamento foi ignorado.', ii);
                continue
            otherwise
                log{end+1} = sprintf('Fluxo #%d: %d de %d varreduras atendem à condição estabelecida.', ii, finalSweeps, initialSweeps);
        end

        idx = numel(editedData)+1;

        switch copyMode
            case 'copy'
                editedData(idx) = copy(specData(ii));
            case 'inplace'
                editedData(idx) = specData(ii);
        end

        FilterLOG = struct('fcnHandle',     fcnHandleStr, ...
                           'fcnHandleArgs', {fcnHandleArgs}, ...
                           'copyMode',      copyMode, ...
                           'filterMode',    filterMode, ...                           
                           'initialSweeps', initialSweeps,...
                           'finalSweeps',   finalSweeps);

        switch filterMode
            case 'keep'
                FilterLogicalArray = indexes;
            case 'remove'
                FilterLogicalArray = ~indexes;
        end

        editedData(idx) = filter(editedData(idx), FilterLOG, FilterLogicalArray);
    end
end