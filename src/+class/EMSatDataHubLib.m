classdef (Abstract) EMSatDataHubLib
    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function channelList = importSatelliteChannels(channels)
            channelList = struct( ...
                'Name', {}, ...
                'Band', [], ...
                'FirstChannel', [], ...
                'LastChannel', [], ...
                'StepWidth', [], ...
                'ChannelBW', [], ...
                'FreqList', [], ...
                'Reference', '', ...
                'EmissionClass', '' ...
            );

            for ii = 1:height(channels)
                channelFreqCenter = channels.FREQ_CENTRAL_DOWN(ii);
                channelBandWidth = channels.BW(ii);

                channelList(ii).Name = sprintf('%s %s %s @ %.1f MHz', channels.DESIG_INT(ii), channels.CODE(ii), channels.FEIXE_POLARIZ_DOWN(ii), channelFreqCenter);
                channelList(ii).Band = [channelFreqCenter-channelBandWidth/2, channelFreqCenter+channelBandWidth/2];
                channelList(ii).FirstChannel = channelFreqCenter;
                channelList(ii).LastChannel = channelFreqCenter;
                channelList(ii).StepWidth = -1;
                channelList(ii).ChannelBW = channelBandWidth;
                channelList(ii).FreqList = [];
                channelList(ii).Reference = jsonencode(channels(ii, {'SNAPSHOT_DT', 'SAT_ANATEL_ID', 'LICENCIADO_BRASIL', 'TECNOLOGIA', 'SENTIDO_GATEWAY', 'FEIXE_UP', 'FEIXE_DOWN', 'FREQ_CENTRAL_UP', 'OCUPACAO_TOTAL', 'METRICA_OCUPACAO', 'OBS'}));
                channelList(ii).EmissionClass = 'Satellite';
            end
        end

        %-----------------------------------------------------------------%
        function channels = importRawCSVFile(fileFullName)
            [~, ~, fileExt] = fileparts(fileFullName);
            if ~strcmpi(fileExt, '.csv')
                error('FileMustBeCSV')
            end
        
            % Set up the Import Options and import the data
            opts = delimitedTextImportOptions("NumVariables", 19, "Encoding", "UTF-8");
            
            % Specify range and delimiter
            opts.DataLines = [2, Inf];
            opts.Delimiter = ";";
            
            % Specify column names and types
            opts.VariableNames = ["SNAPSHOT_DT", "SAT_ANATEL_ID", "DESIG_INT", "CODE", "LICENCIADO_BRASIL", "TECNOLOGIA", "SENTIDO_GATEWAY", "FEIXE_UP", "FEIXE_DOWN", "FEIXE_POLARIZ_UP", "FEIXE_POLARIZ_DOWN", "BW", "FREQ_CENTRAL_UP", "FREQ_CENTRAL_DOWN", "OCUPACAO_TOTAL", "OCUPACAO_BR", "METRICA_OCUPACAO", "RESTRICAO_DADO", "OBS"];
            opts.VariableTypes = ["datetime", "categorical", "categorical", "categorical", "double", "double", "double", "categorical", "categorical", "categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "string"];
            
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            
            % Specify variable properties
            opts = setvaropts(opts, "OBS", "WhitespaceRule", "preserve");
            opts = setvaropts(opts, ["SAT_ANATEL_ID", "DESIG_INT", "CODE", "FEIXE_UP", "FEIXE_DOWN", "FEIXE_POLARIZ_UP", "FEIXE_POLARIZ_DOWN", "OBS"], "EmptyFieldRule", "auto");
            opts = setvaropts(opts, "SNAPSHOT_DT", "InputFormat", "dd/MM/yyyy", "DatetimeFormat", "preserveinput");
            opts = setvaropts(opts, ["LICENCIADO_BRASIL", "TECNOLOGIA", "SENTIDO_GATEWAY", "BW", "FREQ_CENTRAL_UP", "FREQ_CENTRAL_DOWN", "OCUPACAO_TOTAL", "OCUPACAO_BR", "METRICA_OCUPACAO", "RESTRICAO_DADO"], "DecimalSeparator", ",");
            opts = setvaropts(opts, ["LICENCIADO_BRASIL", "TECNOLOGIA", "SENTIDO_GATEWAY", "BW", "FREQ_CENTRAL_UP", "FREQ_CENTRAL_DOWN", "OCUPACAO_TOTAL", "OCUPACAO_BR", "METRICA_OCUPACAO", "RESTRICAO_DADO"], "ThousandsSeparator", ".");
            
            % Import the data
            channels = readtable(fileFullName, opts);
        end
    end
end