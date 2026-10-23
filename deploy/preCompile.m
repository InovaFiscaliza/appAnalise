function preCompile(operationType, prjInfo, appNames)
    arguments
        operationType char {mustBeMember(operationType, {'generateExportedApps', 'generateMLAPPFromExported'})} = 'generateExportedApps'
        prjInfo       matlab.project.Project = matlab.project.Project.empty
        appNames      cell {mustBeText} = {}
    end

    appName = 'appAnalise';

    switch operationType
        case 'generateExportedApps' % .MLAPP >> .M (exported)
            appEngine.generateExportedApps(appName, prjInfo, appNames)

        case 'generateMLAPPFromExported' % .M (exported) >> .MLAPP
            appEngine.generateMLAPPFromExported(appName, prjInfo, appNames)
    end
end
