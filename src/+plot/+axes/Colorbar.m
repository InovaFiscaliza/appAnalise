function Colorbar(hAxes, Location)
    arguments
        hAxes
        Location char {mustBeMember(Location, {'off', 'on', 'west', 'east', 'north', 'south', 'eastoutside', 'southoutside', 'westoutside'})}
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
                colorbar(hAxes, 'Location', Location, 'Color', 'white', 'FontSize', 7, 'PickableParts', 'none');
            end
    end
end