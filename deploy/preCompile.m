function preCompile(operationType, prjInfo, appNames)
    arguments
        operationType char {mustBeMember(operationType, {'generateExportedApps', 'generateMLAPPFromExported'})} = 'generateExportedApps'
        prjInfo       matlab.project.Project = matlab.project.Project.empty
        appNames      cell {mustBeText} = {}
    end

    if isempty(prjInfo)
        rootFolder = fileparts(fileparts(mfilename('fullpath')));
    else
        rootFolder = prjInfo.RootFolder;
    end
    srcFolder = fullfile(rootFolder, 'src');

    switch operationType
        case 'generateExportedApps' % .MLAPP >> .M (exported)
            appEngine.AppExporter.toExported(srcFolder, appNames)

        case 'generateMLAPPFromExported' % .M (exported) >> .MLAPP
            appEngine.AppExporter.toMLAPP(srcFolder, appNames)
    end
end
