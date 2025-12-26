function [idxThreads, reportInfo] = GeneralInfo(app, Mode, reportTemplateIndex)
    switch Mode
        case 'Report'
            idxThreads    = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));

             switch app.report_Version.Value
                    case 'Definitiva'
                    detectionMode = 'Manual';
                 otherwise
                     detectionMode = 'Automatic+Manual';
             end

        case 'playback.AddEditOrDeleteEmission'
            idxThreads    = app.play_PlotPanel.UserData.NodeData;
            detectionMode = 'Manual';

        case {'report.AddOrDeleteThread', 'signalAnalysis.EditOrDeleteEmission', 'signalAnalysis.externalJSON'}
            idxThreads    = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            detectionMode = 'Manual';
    end
    
    % Criação de variável local que suportará a criação do relatório de
    % monitoração.
    reportInfo = struct('Version',       app.General.AppVersion,                         ...
                        'Issue',         app.report_Issue.Value,                         ...
                        'Unit',          app.report_Unit.Value,                          ...
                        'General',       struct('Mode',        Mode,                     ...
                                                'Image',       app.General.Image,        ...
                                                'Parameters',  app.General.Plot,         ...
                                                'RootFolder',  app.rootFolder,           ...
                                                'TempPath',    app.General.fileFolder.tempPath,  ...
                                                'UserPath',    app.General.fileFolder.userPath), ...
                        'ExternalFiles', app.projectData.externalFiles,                  ...
                        'DetectionMode', detectionMode,                                  ...
                        'Filename',      '');

    fieldsUnnecessary = {'rootFolder', 'entryPointFolder', 'tempSessionFolder', 'ctfRoot'};
    fieldsUnnecessary(cellfun(@(x) ~isfield(app.General.AppVersion.application, x), fieldsUnnecessary)) = [];
    if ~isempty(fieldsUnnecessary)
        reportInfo.Version.application = rmfield(reportInfo.Version.application, fieldsUnnecessary);
    end

    if reportTemplateIndex >= 1
        [projectFolder, ...
         programDataFolder]  = appEngine.util.Path(class.Constants.appName, app.rootFolder);

        if isfile(fullfile(programDataFolder, 'ReportTemplates', app.General.Models.Template{reportTemplateIndex}))
            reportTemplateScript = fileread(fullfile(programDataFolder, 'ReportTemplates', app.General.Models.Template{reportTemplateIndex}));
        else
            reportTemplateScript = fileread(fullfile(projectFolder,     'ReportTemplates', app.General.Models.Template{reportTemplateIndex}));
        end

        reportInfo.Model = struct('Name',         app.report_ModelName.Value,                ...
                                  'DocumentType', 'Relatório de Atividades',                 ...
                                  'idx',          reportTemplateIndex,                       ...
                                  'Type',         app.General.Models(reportTemplateIndex,:), ...
                                  'Version',      app.report_Version.Value,                  ...
                                  'Script',       reportTemplateScript);
    end
end