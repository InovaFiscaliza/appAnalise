function isMerged = isMergedEmission(classification)
    % isMergedEmission Identifica classificações associadas a múltiplas estações.
    isMerged = false;

    try
        details = jsondecode(classification.AutoSuggested.Details);
        for ii = 1:numel(details)
            if ~isfield(details(ii), 'MergeCount')
                continue
            end

            mergeCount = details(ii).MergeCount;
            if ischar(mergeCount) || isstring(mergeCount)
                mergeCount = str2double(string(mergeCount));
            end

            if isnumeric(mergeCount) && isscalar(mergeCount) && ...
                    ~isnan(mergeCount) && mergeCount ~= 1
                isMerged = true;
                return
            end
        end
    catch
    end
end
