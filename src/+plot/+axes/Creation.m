function hAxes = Creation(hParent, axesType, varargin)

    arguments
        hParent
        axesType  char {mustBeMember(axesType,  {'Cartesian', 'Geographic'})} = 'Cartesian'
    end

    arguments (Repeating)
        varargin 
    end

    switch axesType
        case 'Cartesian'
            hAxes = uiaxes(hParent, Color=[.07,0,0], ColorScale='log', FontName='Helvetica', FontSize=10,                    ...
                                    XColor=[.8,.8,.8], YColor=[.8,.8,.8],                                                    ...
                                    XGrid='on', XMinorGrid='on', YGrid='on', YMinorGrid='on', TickDir='in',                  ...
                                    GridAlpha=.25, GridColor=[.94,.94,.94], MinorGridAlpha=.2, MinorGridColor=[.94,.94,.94], ...
                                    Interactions=[], Toolbar=[]);
            
            if nargin == 3
                othersParameters = varargin{1};
                set(hAxes, othersParameters{:});
            end

        case 'Geographic'
            hAxes = geoaxes(hParent, FontSize=6, Basemap='none', AxisColor='white',      ...
                                     Grid='off', TickDir='none', Box='off', LineWidth=1, ...
                                     Interactions=[], Toolbar=[]);
            hAxes.LatitudeLabel.String  = '';
            hAxes.LongitudeLabel.String = '';
            hAxes.Scalebar.Visible = 0;

            if nargin == 3
                othersParameters = varargin{1};
                set(hAxes, othersParameters{:});
            end
    end

    hold(hAxes, 'on')
end