classdef (Abstract) datatip

    methods (Static = true)
        %-----------------------------------------------------------------%
        function [parentTag, dataIndex, xData, yData] = Search(dtParent)
            dtHandles = findobj(dtParent, 'Type', 'datatip');
            parentTag = arrayfun(@(x) x.Parent.Tag, dtHandles, "UniformOutput", false);
            dataIndex = arrayfun(@(x) x.DataIndex,  dtHandles, "UniformOutput", false);
            xData     = arrayfun(@(x) x.X,          dtHandles, "UniformOutput", false);
            yData     = arrayfun(@(x) x.Y,          dtHandles, "UniformOutput", false);
        end


        %-----------------------------------------------------------------%
        function Create(callingFcn, dtConfig, dtParent)
            arguments
                callingFcn char {mustBeMember(callingFcn, {'customPlayback', 'redrawWaterfall'})}
                dtConfig   struct
                dtParent
            end

            switch callingFcn
                case 'customPlayback'
                    % dtConfig = struct('parentTag', {}, 'dataIndex', {})
                    for ii = 1:numel(dtConfig)
                        dtParentHandle = findobj(dtParent, 'Tag', dtConfig(ii).parentTag);

                        if ~isempty(dtParentHandle)
                            datatip(dtParentHandle(1), 'DataIndex', dtConfig(ii).dataIndex);
                        end
                    end

                case 'redrawWaterfall'
                    % dtConfig = struct('xData', {}, 'yData', {})
                    for ii = 1:numel(dtConfig)
                        datatip(dtParent, dtConfig(ii).xData, dtConfig(ii).yData);
                    end
            end
        end


        %-----------------------------------------------------------------%
        function Template(dtParent, dtType, varargin)
            % ToDo:
            % Passar como argumento de entrada o contexto do plot, de forma
            % que o datatip seja incluído apenas em contextos que proveem
            % interatividade. Não faz sentido, por exemplo, ter datatip ao
            % gerar o relatório.

            arguments
                dtParent
                dtType char {mustBeMember(dtType, {'Frequency+Level', ...
                                                   'Frequency+Occupancy', ...
                                                   'Frequency+Timestamp+Level', ...
                                                   'Coordinates', ...
                                                   'Coordinates+Frequency' ...
                                                   'RepoSFI.Location', ...
                                                   'SweepID+ChannelPower+Coordinates' ...
                                                   'SweepID+ChannelPower' ...
                                                   'winRFDataHub.Geographic' ...
                                                   'RFLink.LOS', ...
                                                   'RFLink.Terrain', ...
                                                   'AntennaPattern'})}
            end

            arguments (Repeating)
                varargin
            end

            if isempty(dtParent)
                return
            elseif ~isprop(dtParent, 'DataTipTemplate')
                % 'images.roi.line' e 'images.roi.Rectangle' não suportam DataTip
                try
                    dt = datatip(dtParent, Visible = 'off');
                catch
                    return
                end
            end

            set(dtParent.DataTipTemplate, FontName='Calibri', FontSize=10)

            switch dtType
                case 'Frequency+Level'
                    hUnit = getUnit(varargin{1});

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f MHz';                    
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(2).Format = ['%.1f' hUnit];

                case 'Frequency+Occupancy'
                    hUnit = getUnit(varargin{1});

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f MHz';                    
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(2).Format = ['%.1f' hUnit];

                case 'Frequency+Timestamp+Level'
                    hUnit = getUnit(varargin{1});

                    switch class(dtParent)
                        case 'matlab.graphics.chart.primitive.Surface'
                            dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                            dtParent.DataTipTemplate.DataTipRows(2).Label  = '';
                            dtParent.DataTipTemplate.DataTipRows(3).Label  = '';
                                            
                            dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f MHz';
                            dtParent.DataTipTemplate.DataTipRows(2).Format =  'dd/MM/yyyy HH:mm:ss';
                            dtParent.DataTipTemplate.DataTipRows(3).Format =  ['%.1f' hUnit];

                        case 'matlab.graphics.primitive.Image'
                            dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                            dtParent.DataTipTemplate.DataTipRows(2).Label  = '';

                            dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f';
                            dtParent.DataTipTemplate.DataTipRows(2).Format = ['%.1f' hUnit];
                            dtParent.DataTipTemplate.DataTipRows(3)        = [];
                    end

                case 'Coordinates'
                    dtParent.DataTipTemplate.DataTipRows(1).Label = 'Lat:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label = 'Lon:';
                    if numel(dtParent.DataTipTemplate.DataTipRows) > 2
                        dtParent.DataTipTemplate.DataTipRows(3:end) = [];
                    end

                case 'Coordinates+Frequency'
                    hTable = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = 'Lat:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = 'Lon:';
                    dtParent.DataTipTemplate.DataTipRows(3)        = dataTipTextRow('', hTable.Frequency, '%.3f MHz');
                    dtParent.DataTipTemplate.DataTipRows(4)        = dataTipTextRow('', hTable.Name);

                    dtParent.DataTipTemplate.DataTipRows           = dtParent.DataTipTemplate.DataTipRows([3:4,1:2]);

                case 'RepoSFI.Location'
                    dbFilteredReference = varargin{1};
                    dtParent.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('', dbFilteredReference.Location);
                    dtParent.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('', dbFilteredReference.District);
                    dtParent.DataTipTemplate.DataTipRows = dtParent.DataTipTemplate.DataTipRows(end-1:end);

                case 'SweepID+ChannelPower+Coordinates'
                    hTable = table((1:numel(dtParent.LatitudeData))', 'VariableNames', {'ID'});
                    hUnit = getUnit(varargin{1});

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = 'Lat:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = 'Lon:';
                    dtParent.DataTipTemplate.DataTipRows(3)        = dataTipTextRow('', hTable.ID, '#%d');
                    dtParent.DataTipTemplate.DataTipRows(4)        = dataTipTextRow('', 'CData', ['%.1f' hUnit]);

                    if numel(dtParent.DataTipTemplate.DataTipRows) > 4
                        dtParent.DataTipTemplate.DataTipRows(5:end) = [];
                    end

                    dtParent.DataTipTemplate.DataTipRows           = dtParent.DataTipTemplate.DataTipRows([3:4,1:2]);

                case 'SweepID+ChannelPower'
                    hUnit = getUnit(varargin{1});

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(1).Format = '#%d';
                    dtParent.DataTipTemplate.DataTipRows(2)        = dataTipTextRow('', 'YData', ['%.1f' hUnit]);


                case 'winRFDataHub.Geographic'
                    hTable = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1)     = dataTipTextRow('', hTable.ID);
                    dtParent.DataTipTemplate.DataTipRows(2)     = dataTipTextRow('', hTable.Frequency, '%.3f MHz');
                    dtParent.DataTipTemplate.DataTipRows(3)     = dataTipTextRow('', hTable.Distance,  '%.1f km');

                case 'RFLink.LOS'
                    hTable = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Distância:',    hTable.Distance, '%.1f km');
                    dtParent.DataTipTemplate.DataTipRows(2) = dataTipTextRow('Altura:',       hTable.Height,   '%.1f m');
                    dtParent.DataTipTemplate.DataTipRows(3) = dataTipTextRow('Espaço livre:', hTable.PathLoss, '%.1f dB');

                case 'RFLink.Terrain'
                    hTable = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Lat:',  hTable.Latitude,  '%.6f');
                    dtParent.DataTipTemplate.DataTipRows(2) = dataTipTextRow('Lon:', hTable.Longitude, '%.6f');
                    dtParent.DataTipTemplate.DataTipRows(3) = dataTipTextRow('',  hTable.Elevation, '%.1f m');

                case 'AntennaPattern'
                    dtParent.DataTipTemplate.DataTipRows(1) = dataTipTextRow('', 'ThetaData', '%.0fº');
                    dtParent.DataTipTemplate.DataTipRows(2) = dataTipTextRow('', 'RData',     '%.1fdBd');
            end

            if exist('dt', 'var')
                delete(dt)
            end

            function unit = getUnit(unit)
                if strcmp(unit, '%')
                    unit = '%%';
                elseif startsWith(unit, 'dB')
                    unit = [' ' unit];
                end
            end
        end
    end
end