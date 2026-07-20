function [status, message] = checkFreeStorage(fileName, sessionTempFolder, freeStorageThreshold)

    arguments
        fileName             char
        sessionTempFolder    char
        freeStorageThreshold double = 4 % GB
    end

    status  = true;
    message = '';

    try
        [~,diskInfo]  = system('wmic volume get DriveLetter,FreeSpace');
        diskInfoTemp  = fullfile(sessionTempFolder, 'freeStorage.csv');
        writematrix(diskInfo, diskInfoTemp, 'WriteMode', 'overwrite', 'FileType', 'text', 'QuoteStrings', 'none', 'Encoding', 'UTF-8')

        diskInfoTable = readtable(diskInfoTemp, "FileType", "text", "Delimiter", " ", "MultipleDelimsAsOne", true, "MissingRule", "omitrow");
        diskInfoTable.FreeSpace_GB = diskInfoTable.FreeSpace / (1024^3);

        fileDisk      = fileName(1:2);
        freeStorage   = diskInfoTable.FreeSpace_GB(find(strcmp(diskInfoTable.DriveLetter, fileDisk), 1));
        
        if freeStorage < freeStorageThreshold
            status    = false;
            message   = sprintf(['Espaço livro em disco é de apenas %.1f GB, o que pode afetar o funcionamento do appAnalise. '    ...
                                 'Recomenda-se liberar espaço removendo arquivos temporários ou programas em desuso'], freeStorage);
        end
    catch
    end
end