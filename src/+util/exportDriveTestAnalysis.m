function msgWarning = exportDriveTestAnalysis(emissionPoints, basename, fileZIP, dataSource, hPlot, channelTag)

    % TABELAS DO APPANALISE:DRIVE-TEST:
    % - specRawTable.....: "Timestamp", "Latitude", "Longitude", "ChannelPower", "Filtered"
    % - specFilteredTable:              "Latitude", "Longitude", "ChannelPower", "LatEq", "LongEq", "BinIndex"
    % - specBinTable.....:              "Latitude", "Longitude", "ChannelPower", "Measures"

    % ARQUIVOS DE SAÍDA:
    % - XLSX: para uso no Excel; e
    % - KML: para uso no Google Earth e afins.
    msgWarning = {};
    msgError   = {};

    fileSheetName   = [basename '.xlsx'];
    fileKMLMeasures = [basename '_Measures.kml'];
    fileKMLRoute    = [basename '_Route.kml'];

    specRawTable = emissionPoints.raw;
    specFilteredTable = emissionPoints.filtered;
    specBinTable = emissionPoints.binned;

    % XLSX
    try
        % Cria coluna "BinIndex" para facilitar a vida de quem for usar um
        % "PROCV da vida" no Excel.
        specBinTable.BinIndex = (1:height(specBinTable))';
        specBinTable = movevars(specBinTable, 'BinIndex', 'Before', 1);

        writetable(specRawTable,      fileSheetName, 'FileType', 'spreadsheet', 'WriteMode', 'replacefile',    'Sheet', 'RAW')
        writetable(specFilteredTable, fileSheetName, 'FileType', 'spreadsheet', 'WriteMode', 'overwritesheet', 'Sheet', 'FILTERED')
        writetable(specBinTable,      fileSheetName, 'FileType', 'spreadsheet', 'WriteMode', 'overwritesheet', 'Sheet', 'DATA-BINNING')        
        msgWarning{end+1} = sprintf('•&thinsp;%s', fileSheetName);
    catch ME
        msgError{end+1}   = ME.message;
    end

    % KML
    switch dataSource
        case {'Raw', 'Filtered'}
            srcTable = specFilteredTable(:,{'Timestamp', 'Latitude', 'Longitude', 'ChannelPower'});
            measDescription = arrayfun(@(x,y) sprintf('%s\n%s\n%.1f dBm', channelTag, x, y), srcTable.Timestamp, srcTable.ChannelPower, 'UniformOutput', false);

        case 'Data-Binning'
            srcTable = specBinTable;
            measDescription = arrayfun(@(x,y) sprintf('%s\n%d measures\n%.1f dBm', channelTag, x, y), srcTable.Measures, srcTable.ChannelPower, 'UniformOutput', false);
    end
    geoTable = table2geotable(srcTable);    
    RGB      = imageUtil.getRGB(hPlot);

    try
        kmlwrite(fileKMLMeasures, geoTable, 'Name', string(1:height(geoTable))', 'Description', measDescription, 'Color', RGB)
        msgWarning{end+1} = sprintf('•&thinsp;%s', fileKMLMeasures);
    catch ME
        msgError{end+1}   = ME.message;
    end

    try
        routeDescription = sprintf('%s\n%s - %s', channelTag, char(specRawTable.Timestamp(1)), char(specRawTable.Timestamp(end)));
        kmlwriteline(fileKMLRoute, specRawTable.Latitude, specRawTable.Longitude, 'Name', 'Route', 'Description', routeDescription', 'Color', 'red', 'LineWidth', 3)
        msgWarning{end+1} = sprintf('•&thinsp;%s', fileKMLRoute);
    catch ME
        msgError{end+1}   = ME.message;
    end

    if isempty(msgError)
        zip(fileZIP, {fileSheetName, fileKMLMeasures, fileKMLRoute})
    else
        error('DriveTest:ExportFiles:FileNotCreated', strjoin(msgError, '\n'))
    end

    fileFolder = fileparts(basename);
    msgWarning = replace(msgWarning, fileFolder, '.');
    msgWarning = sprintf('Lista de arquivos criados na pasta de trabalho:\n%s', strjoin(msgWarning, '\n'));
end