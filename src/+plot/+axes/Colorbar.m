function Colorbar(hAxes, Location, customConfig)
    arguments
        hAxes
        Location char {mustBeMember(Location, {'off', 'on', 'west', 'east', 'north', 'south', 'eastoutside', 'southoutside', 'westoutside'})}
        customConfig = {}
    end

    switch Location
        case 'off'
            colorbar(hAxes,'off')
        otherwise
            if strcmp(Location, 'on')
                Location = 'east';
            end

            cb = findobj(hAxes.Parent.Children, 'Type', 'colorbar');
            if ~isempty(cb)
                cb.Location = Location;
            else
                cb = colorbar(hAxes, 'Location', Location, 'Color', [.8,.8,.8], 'FontSize', 7, 'PickableParts', 'none');
                if ~isempty(customConfig)
                    set(cb, customConfig{:})
                end
            end
    end
end