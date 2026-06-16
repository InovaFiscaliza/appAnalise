function editedReceiverName = layoutTreeNodeText(rawIDN, callingFcn)

    arguments
        rawIDN
        callingFcn char {mustBeMember(callingFcn, {'file_TreeBuilding', 'play_TreeBuilding', 'model.Band.updateSpectrumInfo'})}
    end

    IDN = strsplit(rawIDN, ',');

    if numel(IDN) == 4        
        d = dictionary(["keysight technologies", "rohde&schwarz", "tektronix"], ...
                       ["Keysight",              "R&S",           "Tektronix"]);

        switch callingFcn
            case {'file_TreeBuilding', 'play_TreeBuilding'}
                if isKey(d, lower(IDN{1}))
                    IDN{1} = char(d(lower(IDN{1})));
                    editedReceiverName = strjoin(IDN, ',');
                else
                    editedReceiverName = rawIDN;
                end

            case 'model.Band.updateSpectrumInfo'
                editedReceiverName = strjoin(IDN(1:2), ' ');
        end

    else
        editedReceiverName = rawIDN;
    end
end