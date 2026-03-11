function layoutDropDownTreeStyle(dropDownHandle, specData)
    previousValue = dropDownHandle.Value;
    if ~isempty(previousValue) && isnumeric(previousValue)
        previousValue = dropDownHandle.Items{previousValue};
    end

    maxFreqStart = max(arrayfun(@(x) x.MetaData.FreqStart, specData) / 1e+6);
    maxFreqStop  = max(arrayfun(@(x) x.MetaData.FreqStop,  specData) / 1e+6);

    [receivers, ~, indexes] = unique({specData.Receiver});
    items = {};
    itemsData = [];
    
    for ii = 1:numel(receivers)
        receiverIdxs = find(indexes == ii)';
        receiverName = util.layoutTreeNodeText(receivers{ii}, 'play_TreeBuilding');
        
        for jj = receiverIdxs
            freqStart = specData(jj).MetaData.FreqStart / 1e+6;
            freqStop  = specData(jj).MetaData.FreqStop  / 1e+6;
            levelUnit = specData(jj).MetaData.LevelUnit;
            
            freqStartAlignSpaces = computeAlignSpaces(maxFreqStart, freqStart);
            freqStopAlignSpaces  = computeAlignSpaces(maxFreqStop,  freqStop);

            freqStartAlignSpaces = '';
            freqStopAlignSpaces  = '';

            reportStatus = '';
            if ~isempty(specData(jj).UserData) && specData(jj).UserData.ReportInclude
                reportStatus = '&emsp;&#x1F7E2;';
            end

            items{end+1, 1} = sprintf('%s<br>└── %s%.3f&ensp;a&ensp;%s%.3f MHz%s', ...
                receiverName, ...
                freqStartAlignSpaces, ...
                freqStart, ...
                freqStopAlignSpaces, ...
                freqStop, ...
                reportStatus ...
            );
                
            itemsData(end+1, 1) = jj;
        end
    end

    currentValue = {};    
    if ~isempty(previousValue)
        [~, previousValueIndex] = ismember(previousValue, items);

        if previousValueIndex
            currentValue = {'Value', previousValueIndex};
        end
    end

    set(dropDownHandle, 'Items', items, 'ItemsData', itemsData, currentValue{:})
end

%-------------------------------------------------------------------------%
function alignSpaces = computeAlignSpaces(maxFreqStart, currentFreqStart)
    arguments
        maxFreqStart     (1,1) double
        currentFreqStart (1,1) double
    end

    maxStr  = num2str(floor(maxFreqStart));
    currStr = num2str(floor(currentFreqStart));
    nDiff   = strlength(maxStr) - strlength(currStr);

    if nDiff > 0
        alignSpaces = repmat('&thinsp;', 1, 3*nDiff);
    else
        alignSpaces = '';
    end
end