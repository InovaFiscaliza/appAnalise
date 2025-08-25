function varargout = compile(compilationType, rootCompiledFolder, matlabRuntimeFolder, showConsoleInDesktopBuild, createGitHubReleaseForDesktopBuild, githubCLIFolder, githubAccount)
    
    % Automatiza compilação da ferramenta, nas suas versões desktop e webapp.
    % No caso de criação de release no repo do GitHub, deve-se certificar
    % de instalar o GitHub CLI e estar conectado a uma conta que tem perfil
    % de escrita no repo InovaFiscaliza/appAnalise.

    % ToDo:
    % Publicação do webapp no MATLAB WebServer ou no servidor local.

    arguments
        compilationType         char {mustBeMember(compilationType, {'Desktop+WebApp', 'Desktop', 'WebApp'})} = 'Desktop+WebApp'
        rootCompiledFolder      char    = 'C:\InovaFiscaliza (AppsDeployVersions)'
        matlabRuntimeFolder     char    = 'E:\MATLAB Runtime\MATLAB Runtime (Custom)\R2024a'
        showConsoleInDesktopBuild  (1,1) logical = false % versão desktop apresenta console
        createGitHubReleaseForDesktopBuild (1,1) logical = true
        githubCLIFolder         char    = 'C:\Program Files\GitHub CLI'
        githubAccount           char    = 'EricMagalhaesDelgado'
    end

    appName     = 'appAnalise';

    initFolder  = fileparts(mfilename('fullpath'));
    finalFolder = fullfile(rootCompiledFolder, appName);
    if ~isfolder(finalFolder)
        mkdir(finalFolder)
    end

    if contains(compilationType, 'Desktop') && createGitHubReleaseForDesktopBuild
        if showConsoleInDesktopBuild
            error('The flag "showConsoleInDesktopBuild" must be false when creating a GitHub release.');
        end

        cd(githubCLIFolder)
        [~, ghStatus] = system('gh auth status');
        if ~contains(ghStatus, githubAccount)
            cd(initFolder)
            error('GitHubNotConnected')
        end
    end

    % Abre projeto do "appAnalise", caso fechado, o que mapeia as pastas do
    % projeto, possibilitar chamar class.Constants.appRelease, por exemplo.
    try
        prjInfo = currentProject;

        if ~strcmp(prjInfo.Name, appName)
            error('UnexpectedProject')
        end
    catch
        openProject(fullfile(fileparts(initFolder), [appName '.prj']));
    end

    % Cria versões .M para cada um dos arquivos .MLAPP, possibilitando que
    % a figura do app principal (winAppAnalise.mlapp) seja um container para
    % os apps auxiliares.
    cd(initFolder)
    preCompile()

    % Atualiza base de dados, caso necessário.
    RFDataHubOriginalFile = fullfile(fileparts(initFolder), 'src', 'config', 'DataBase', 'RFDataHub.mat');
    RFDataHubEditedFile   = fullfile(fullfile(ccTools.fcn.OperationSystem('programData'), 'ANATEL', appName), 'DataBase', 'RFDataHub.mat');
    if isfile(RFDataHubEditedFile)
        load(RFDataHubOriginalFile, 'RFDataHub_info')
        originalReleaseDate = datetime(RFDataHub_info.ReleaseDate, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');

        load(RFDataHubEditedFile, 'RFDataHub_info')
        editedReleaseDate   = datetime(RFDataHub_info.ReleaseDate, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');

        if editedReleaseDate > originalReleaseDate
            copyfile(RFDataHubEditedFile, RFDataHubOriginalFile, 'f');
        end
    end

    % Gera as versões desktop e webapp.
    switch compilationType
        case 'Desktop+WebApp'
            varargout = {desktopCompilation(finalFolder, matlabRuntimeFolder, createGitHubReleaseForDesktopBuild, githubCLIFolder, showConsoleInDesktopBuild), ...
                          webappCompilation(finalFolder)};
        case 'Desktop'
            varargout = {desktopCompilation(finalFolder, matlabRuntimeFolder, createGitHubReleaseForDesktopBuild, githubCLIFolder, showConsoleInDesktopBuild)};
        case 'WebApp'
            varargout = { webappCompilation(finalFolder)};
    end
    cd(initFolder)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPILAÇÃO: DESKTOP                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function results = desktopCompilation(finalFolder, matlabRuntimeFolder, githubReleaseFlag, githubCLIFolder, windowsDebugMode)
    initFolder   = fileparts(mfilename('fullpath'));

    % Prepara a pasta
    deployFolder = fullfile(initFolder, 'desktop', 'application');
    if isfolder(deployFolder)
        rmdir(deployFolder, 's')
    end

    % Parser do projeto de referência (XML)
    xmlProject   = readstruct(fullfile(initFolder, 'desktop.prj'), 'FileType', 'xml');
    appName      = char(xmlProject.configuration.param_appname);
    appMainFile  = char(xmlProject.configuration.fileset_main.file);
    appResources = cellstr(xmlProject.configuration.fileset_resources.file);
    appPackages  = cellstr(xmlProject.configuration.fileset_package.file);
    appIcon      = fullfile(initFolder, 'desktop_resources', 'icon_48.png');
    appVersion   = class.Constants.appVersion;

    % Arquivo EXECUTÁVEL
    cd(fileparts(appMainFile))

    compilerOpts = compiler.build.StandaloneApplicationOptions(appMainFile, ...
        'ExecutableIcon',    appIcon,      ...
        'ExecutableName',    appName,      ...
        'ExecutableVersion', appVersion,   ...
        'AdditionalFiles',   appResources, ...
        'Verbose',           true,         ...
        'OutputDir',         deployFolder);

    if windowsDebugMode || ~ispc()
        results = compiler.build.standaloneApplication(compilerOpts);
    else
        results = compiler.build.standaloneWindowsApplication(compilerOpts);
    end
    cd(initFolder)

    % Copia arquivos para a pasta do usuário, além de criar vínculo entre 
    % o app e o seu splashscreen (construído em C#, no Visual Studio).
    for ii = 1:numel(appPackages)
        appPackage = appPackages{ii};

        if isfolder(appPackage)
            [~, folderName] = fileparts(appPackage);
            copyfile(appPackage, fullfile(deployFolder, folderName), 'f')
        else
            copyfile(appPackage, deployFolder, 'f')
        end
    end

    % Pós-compilação
    desktopPostCompilation(finalFolder, matlabRuntimeFolder, githubReleaseFlag, githubCLIFolder)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PÓS-COMPILAÇÃO: DESKTOP                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function desktopPostCompilation(finalFolder, matlabRuntimeFolder, githubReleaseFlag, githubCLIFolder)
    initFolder   = fileparts(mfilename('fullpath'));
    deployFolder = fullfile(initFolder,   'desktop');
    deploySplash = fullfile(initFolder,   'desktop_splashscreen');
    deployApp    = fullfile(deployFolder, 'application');    

    if isfolder(deployApp)
        appName    = class.Constants.appName;
        appRelease = class.Constants.appRelease;
        appVersion = class.Constants.appVersion;

        desktopFinalFolder = fullfile(finalFolder, 'desktop');

        % Aplicável apenas à versão desktop pois ela pode ser suportada
        % por uma versão customizada do MATLAB Runtime. Importante,
        % portanto, confirmar que todos os módulos serão contemplados
        % nesse versão customizada.
        if isfolder(matlabRuntimeFolder)
            fileContent  = strsplit(strtrim(fileread(fullfile(deployApp, 'requiredMCRProducts.txt'))), '\t');
            mcrProducts  = cellfun(@(x) int64(str2double(x)), fileContent);
        
            cacheContent = dir(fullfile(matlabRuntimeFolder, '*.zip'));
            for ii = 1:numel(cacheContent)
                cacheFileString  = char(extractBetween(cacheContent(ii).name, 'InstallAgent_', '.zip'));
                cacheFileProduts = compiler.internal.utils.hexString2RuntimeProducts(cacheFileString);
        
                if any(~ismember(mcrProducts, cacheFileProduts))
                    warning('Necessário atualizar a versão customizada do MATLAB Runtime.')
                end
            end
        end

        % Exclui "splash.png", caso existente.
        if isfile(fullfile(deployApp, 'splash.png'))
            delete(fullfile(deployApp, 'splash.png'))
        end

        % Cria arquivo "appIntegrity.json".
        cd(deployApp)

        [~, cmdout]  = system(sprintf('certUtil -hashfile %s.exe SHA256', appName));
        cmdout       = strsplit(cmdout, '\n');
        fileExeHash  = cmdout{2};
        fileObj      = dir([appName '.exe']);    
        fileExeSize  = uint32(fileObj.bytes);

        appIntegrity = struct('appName',     appName,       ...
                              'appRelease',  appRelease,    ...
                              'appVersion',  appVersion,    ...
                              'codeRepo',    ['https://github.com/InovaFiscaliza/' appName],      ...
                              'customFiles', {{}}, ...
                              'fileName',    [appName '.exe'],      ...
                              'fileHash',    fileExeHash,       ...
                              'fileSize',    fileExeSize);
        
        writematrix(jsonencode(appIntegrity, 'PrettyPrint', true), fullfile(deployApp, 'config', 'appIntegrity.json'), 'FileType', 'text', 'QuoteStrings', 'none')
    
        % Cria arquivos .ZIP e organiza pasta final.
        zipProcess(deployApp, sprintf('%s_Matlab.zip', appName))
        movefile(fullfile(deployFolder, sprintf('%s_Matlab.zip', appName)), finalFolder, 'f')
    
        if isfolder(desktopFinalFolder)
            rmdir(desktopFinalFolder, 's')
        end
        delete(fullfile(finalFolder, sprintf('%s_Installer.zip', appName)))
        
        copyfile(deploySplash, desktopFinalFolder, 'f')
        copyfile(deployApp, fullfile(desktopFinalFolder, 'application'), 'f')
        zipProcess(desktopFinalFolder, sprintf('%s.zip', appName))
    
        zip(fullfile(finalFolder, sprintf('%s_Installer.zip', appName)), {fullfile(initFolder, 'install.bat'), fullfile(finalFolder, sprintf('%s.zip', appName))})
        delete(fullfile(finalFolder, sprintf('%s.zip', appName)))

        % Cria release no GitHub, caso aplicável.
        if githubReleaseFlag
            try
                cd(githubCLIFolder)
                ghMessage = sprintf('gh release create %s "%s" --title "%s" --notes "https://anatel365.sharepoint.com/sites/InovaFiscaliza/SitePages/%s.aspx" --repo InovaFiscaliza/%s', appVersion, fullfile(finalFolder, sprintf('%s_Matlab.zip', appName)), appName, appName, appName);
                [~, ghStatus] = system(ghMessage);
                warning(ghStatus)
            catch ME
                warning(ME.message)
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPILAÇÃO: WEBAPP                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function results = webappCompilation(finalFolder)
    initFolder   = fileparts(mfilename('fullpath'));

   % Prepara a pasta
    deployFolder = fullfile(initFolder, 'webapp');
    if isfolder(deployFolder)
        rmdir(deployFolder, 's')
    end

    % Parser do projeto de referência (XML)
    xmlProject   = readstruct(fullfile(initFolder, 'webapp.prj'), 'FileType', 'xml');
    appName      = char(xmlProject.configuration.param_appname);
    appMainFile  = char(xmlProject.configuration.fileset_web_main.file);
    appResources = cellstr(xmlProject.configuration.fileset_resources.file);

    % Arquivo CTF
    cd(fileparts(appMainFile))

    compilerOpts = compiler.build.WebAppArchiveOptions(appMainFile, ...
        'ArchiveName',       appName,      ...
        'AdditionalFiles',   appResources, ...
        'Verbose',           true,         ...
        'OutputDir',         deployFolder);

    results = compiler.build.webAppArchive(compilerOpts);
    cd(initFolder)

    % Pós-compilação
    webappPostCompilation(finalFolder)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PÓS-COMPILAÇÃO: WEBAPP                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function webappPostCompilation(finalFolder)
    initFolder   = fileparts(mfilename('fullpath'));
    deployFolder = fullfile(initFolder, 'webapp');

    % Organiza pasta final.
    if isfolder(deployFolder)
        webappFinalFolder = fullfile(finalFolder, 'webapp');
        copyfile(deployFolder, webappFinalFolder, 'f')
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNÇÕES AUXILIARES                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zipProcess(zipFolder, zipFileName)
    cd(zipFolder)

    zipObj = struct2table(dir);
    zipObj = zipObj.name(3:end)';
    
    zip(zipFileName, zipObj)
    movefile(zipFileName, fileparts(zipFolder), 'f');
end