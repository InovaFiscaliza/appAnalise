function varargout = publicLink(appName, rootFolder, requiredLinks, fileName)
    arguments
        appName
        rootFolder
        requiredLinks
        fileName = 'PublicLinks.json'
    end

    varargout = {};
    [projectFolder, programDataFolder] = appEngine.util.Path(appName, rootFolder);

    try
        fileContent = jsondecode(fileread(fullfile(programDataFolder, fileName)));
    catch
        fileContent = jsondecode(fileread(fullfile(projectFolder,     fileName)));
    end

    requiredLinks = strsplit(requiredLinks, '+');
    for ii = 1:numel(requiredLinks)
        if isfield(fileContent, requiredLinks{ii})
            varargout{end+1} = fileContent.(requiredLinks{ii});
        end
    end
end