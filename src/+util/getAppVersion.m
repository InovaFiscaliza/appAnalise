function appVersion = getAppVersion(rootFolder, entryPointFolder, temporaryDir)

    arguments
        rootFolder       char
        entryPointFolder char
        temporaryDir     char
    end

    appName = class.Constants.appName;

    appVersion = struct('machine',   '',                                              ...
                        'matlab',    '',                                              ...
                        appName,     struct('release',    class.Constants.appRelease, ...
                                            'version',    class.Constants.appVersion, ...
                                            'rootFolder', rootFolder,                 ...
                                            'entryPointFolder',  entryPointFolder,    ...
                                            'tempSessionFolder', temporaryDir),       ...
                        'rfDataHub', []);

    if exist('ctfroot', 'file')
        appVersion.(appName).ctfRoot = ctfroot;
    end

    % OS
    appVersion.machine = struct('platform',     ccTools.fcn.OperationSystem('platform'),     ...
                                'version',      ccTools.fcn.OperationSystem('ver'),          ...
                                'computerName', ccTools.fcn.OperationSystem('computerName'), ...
                                'userName',     ccTools.fcn.OperationSystem('userName'));

    % OpenGL
    graphRender = '';
    try
        graphRender = jsonencode(rendererinfo);
    catch
    end

    % MATLAB    
    [matVersion, matReleaseDate] = version;
    matProducts = struct2table(ver);
    appVersion.matlab = struct('version',  sprintf('%s (Release date: %s)', matVersion, matReleaseDate),   ...
                               'pid',      feature('getpid'),                                              ...
                               'rootPath', matlabroot,                                                     ...
                               'products', strjoin(matProducts.Name + " v. " + matProducts.Version, ', '), ...
                               'openGL',   graphRender);

    % RFDataHub
    global RFDataHub
    global RFDataHub_info

    if isempty(RFDataHub) || isempty(RFDataHub_info)
        model.RFDataHub.read(appName, rootFolder, temporaryDir)
    end
    appVersion.rfDataHub = RFDataHub_info;
end