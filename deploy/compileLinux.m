function buildResults = compileLinux(supportPackagesFolder, outputFolder)
    % Compila a versão desktop do appAnalise para Linux, replicando o que
    % deploy/compile.m faz no Windows (sem splashscreen .NET, certUtil e
    % release no GitHub).

    arguments
        supportPackagesFolder char = fullfile(getenv('HOME'), 'git', 'SupportPackages')
        outputFolder          char = fullfile(getenv('HOME'), 'appAnalise_linux')
    end

    appName        = 'appAnalise';
    repoRootFolder = fileparts(fileparts(mfilename('fullpath')));
    sourceFolder   = fullfile(repoRootFolder, 'src');

    supportPackagesSubfolders = fullfile(supportPackagesFolder, 'src', {'Anatel', 'General', 'Propagation', 'Spectrum'});
    is_missing_subfolder      = ~cellfun(@isfolder, supportPackagesSubfolders);
    if any(is_missing_subfolder)
        error('Pasta(s) do SupportPackages não encontrada(s): %s', strjoin(supportPackagesSubfolders(is_missing_subfolder), ', '))
    end
    addpath(supportPackagesSubfolders{:})

    openProject(fullfile(repoRootFolder, 'AppAnalise.prj'));

    % Regenera os arquivos *_exported.m a partir dos .mlapp.
    cd(fullfile(repoRootFolder, 'deploy'))
    preCompile()

    additionalFiles = [fullfile(sourceFolder, {'+auxApp', '+class', '+model', '+plot', '+reportLibConnection', '+util', 'resources'}), ...
                       supportPackagesSubfolders];
    appVersion      = char(regexp(class.Constants.appVersion, '^(?:alpha|beta)?_?(\d+(?:\.\d+){2})', 'tokens', 'once'));

    cd(sourceFolder)
    compilerOptions = compiler.build.StandaloneApplicationOptions(fullfile(sourceFolder, 'winAppAnalise.mlapp'), ...
        'ExecutableName',    appName,         ...
        'ExecutableVersion', appVersion,      ...
        'AdditionalFiles',   additionalFiles, ...
        'Verbose',           true,            ...
        'OutputDir',         outputFolder);

    buildResults = compiler.build.standaloneApplication(compilerOptions);

    % Equivalente ao "fileset.package" do desktop.prj.
    copyfile(fullfile(sourceFolder, 'config'), fullfile(outputFolder, 'config'), 'f')
    cd(repoRootFolder)
end
