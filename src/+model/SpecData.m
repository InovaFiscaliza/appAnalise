classdef SpecData < model.SpecDataBase

    properties
        %-----------------------------------------------------------------%
        UserData = model.UserData.empty
        callingApp
        sortType = 'Receiver+Frequency'
    end
    

    methods
        %-----------------------------------------------------------------%
        % ToDo: 
        % - Migrar toda e qualquer atualização do objeto model.SpecData
        %   para esse método.
        %
        % - Organizar as varreduras de forma georeferenciada, evitando
        %   mesclagens de vários arquivos e a possível perda do mapeamento
        %   entre as coordenadas registradas em um arquivo e as suas
        %   respectivas varreduras. (IMPORTANTE!)
        %
        % - Eliminar as propriedades "sortType" e "callingApp" quando for 
        %   realizar uma nova refatoração, gerando a v. 2 do app.
        %-----------------------------------------------------------------%
        function update(obj, propertyName, updateType, varargin)
            arguments
                obj
                propertyName char {mustBeMember(propertyName, {'GPS',                      ...
                                                               'UserData:AntennaHeight',   ...
                                                               'UserData:BandLimits',      ...
                                                               'UserData:Channel',         ...
                                                               'UserData:CustomPlayback',  ...
                                                               'UserData:Emissions',       ...
                                                               'UserData:OccupancyFields', ...
                                                               'UserData:ReportFields',    ...
                                                               'UserData:OccupancyFields+ReportFields'})}
                updateType
            end

            arguments (Repeating)
                varargin
            end

            switch propertyName
                case 'GPS' % Origem: auxApp.dockEditLocation
                    idxThreads = varargin{1};

                    switch updateType
                        case 'Refresh'
                            for ii = idxThreads
                                gpsData = cell2mat(obj(ii).RelatedFiles.GPS);
                                obj(ii).GPS = rmfield(gpsLib.summary(gpsData), 'Matrix');
                            end         

                        case 'ManualEdition'
                            newGPS = varargin{2};        
                            for ii = idxThreads
                                obj(ii).GPS = newGPS;
                            end

                        otherwise 
                            error('Unexpected update type')
                    end

                case 'UserData:BandLimits'
                    if ~isscalar(obj)
                        error('Unexpected non scalar object')
                    end

                    switch updateType
                        case 'Status:Edit'
                            obj.UserData.bandLimitsStatus = varargin{1};

                        case 'Table:Edit'
                            obj.UserData.bandLimitsTable  = varargin{1};

                        case 'Table:DeleteRows'
                            obj.UserData.bandLimitsTable(varargin{1}, :) = [];

                        otherwise 
                            error('Unexpected update type')
                    end

                    checkIfEmissionsInSearchableBand(obj)

                case 'UserData:AntennaHeight' % Origem: auxApp.dockEditLocation
                    idxThreads = varargin{1};
        
                    switch updateType
                        case 'Refresh'
                            for ii = idxThreads
                                newAntennaHeight = AntennaHeight(obj, ii, -1, 'refreshValue');
                                obj(ii).UserData.AntennaHeight = newAntennaHeight;
                            end

                        case 'ManualEdition'
                            newAntennaHeight = varargin{2};
                            for ii = idxThreads
                                obj(ii).UserData.AntennaHeight = newAntennaHeight;
                            end

                        otherwise 
                            error('Unexpected update type')
                    end

                case 'UserData:Channel'
                    if ~isscalar(obj)
                        error('Unexpected non scalar object')
                    end

                    switch updateType
                        case 'ChannelLibIndex:Add'
                            channelObj = varargin{1};
                            obj.UserData.channelLibIndex = FindRelatedBands(channelObj, obj);

                        case 'ChannelLibIndex:Edit'
                            idxChannel = varargin{1};
                            obj.UserData.channelLibIndex = setdiff(obj.UserData.channelLibIndex, idxChannel);

                        case 'ChannelManual:Refresh'
                            idxChannel = varargin{1};
                            obj.UserData.channelManual(idxChannel) = [];

                        case 'ChannelManual:Edit'
                            % Pendente

                        otherwise 
                            error('Unexpected update type')
                    end

                case 'UserData:CustomPlayback'
                    if ~isscalar(obj)
                        error('Unexpected non scalar object')
                    end

                    switch updateType
                        case 'Edit'
                            customPlayback = varargin{1};

                            obj.UserData.customPlayback.Type                     = 'manual';
                            obj.UserData.customPlayback.Parameters.Controls      = customPlayback.Controls;
                            obj.UserData.customPlayback.Parameters.Persistance   = customPlayback.Persistance;
                            obj.UserData.customPlayback.Parameters.Waterfall     = customPlayback.Waterfall;
                            obj.UserData.customPlayback.Parameters.WaterfallTime = customPlayback.WaterfallTime;

                        case 'DataTip'
                            obj.UserData.customPlayback.Parameters.Datatip       = struct('ParentTag', varargin{1}, 'DataIndex', varargin{2});

                        case 'Refresh'
                            obj.UserData.customPlayback = struct('Type', 'auto', 'Parameters', []);

                        otherwise 
                            error('Unexpected update type')
                    end

                case 'UserData:Emissions' % Origem: winAppAnalise
                    if ~isscalar(obj)
                        error('Unexpected non scalar object')
                    end

                    switch updateType
                        case 'Add'
                            idxFreq     = varargin{1};
                            FreqCenter  = varargin{2};
                            BandWidth   = varargin{3};
                            Detection   = varargin{4};
                            Description = varargin{5};
                            channelObj  = varargin{end};

                            % Inicialmente, verifica se a ocupação por bin já foi aferida.
                            % Caso não, afere-se com os parâmetros padrão.
                            checkIfOccupancyPerBinExist(obj)
        
                            for ii = 1:numel(idxFreq)
                                idxEmission = height(obj.UserData.Emissions) + 1;
                                obj.UserData.Emissions(idxEmission, 1:4) = table(idxFreq(ii), FreqCenter(ii), BandWidth(ii), true);

                                defaultChannelEmission  = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idxEmission, channelObj);

                                % Ideia abaixo é eliminar as emissões com características
                                % muito parecidas com a de outras emissões já inclusas.
                                hasMatchingFrequency    = abs(obj.UserData.Emissions.Frequency(1:end-1) - obj.UserData.Emissions.Frequency(end)) <= .015; % 15kHz
                                hasMatchingBandWidth    = abs(obj.UserData.Emissions.BW_kHz(1:end-1)    - obj.UserData.Emissions.BW_kHz(end))    <= 30;   % 30kHz
                                hasMatchingChannel      = arrayfun(@(x) isequal(x, defaultChannelEmission.autoSuggested), arrayfun(@(x) x.userModified, obj.UserData.Emissions.ChannelAssigned(1:end-1)));
                                
                                if any(hasMatchingFrequency & hasMatchingBandWidth & hasMatchingChannel)
                                    obj.UserData.Emissions(idxEmission, :) = [];
                                    continue
                                end
        
                                userDescription = "";
                                if ~isempty(Description)
                                    userDescription = string(Description{ii});
                                end        
                                obj.UserData.Emissions.Description(idxEmission)               = userDescription;
                                
                                obj.UserData.Emissions.Algorithms(idxEmission).Detection      = Detection{ii};
                                obj.UserData.Emissions.Algorithms(idxEmission).Classification = jsonencode(obj.UserData.reportAlgorithms.Classification);
                                obj.UserData.Emissions.Algorithms(idxEmission).Occupancy      = jsonencode(obj.UserData.reportAlgorithms.Occupancy);
                                
                                obj.UserData.Emissions.ChannelAssigned(idxEmission)           = defaultChannelEmission;
                                obj.UserData.Emissions.Classification(idxEmission)            = model.UserData.getFieldTemplate('Classification',  obj, 1, idxEmission, channelObj);
                                
                                util.Measures(obj, 1, idxEmission, 'Emission', channelObj)
                            end
        
                        case 'Edit'
                            parameter   = varargin{1};
                            idxEmission = varargin{2};
                            channelObj  = varargin{end};
        
                            % A alteração das características de frequência e BW de uma emissão 
                            % demanda o recálculo das medidas. Além disso, ajusta-se o canal e
                            % a classificação, mas apenas quando tais valores não tinham sido 
                            % editados anteriormente.
                            
                            % Os parâmetros "isTruncated" e "Description" não demandam recálculo
                            % das medidas pois elas estão orientadas à frequência central da emissão
                            % e sua BW.
        
                            switch parameter
                                case {'Frequency', 'BandWidth', 'Frequency|BandWidth'}
                                    obj.UserData.Emissions.idxFrequency(idxEmission)         = varargin{3};
                                    obj.UserData.Emissions.Frequency(idxEmission)            = varargin{4};
                                    obj.UserData.Emissions.BW_kHz(idxEmission)               = varargin{5};

                                    obj.UserData.Emissions.Algorithms(idxEmission).Detection = '{"Algorithm":"Manual"}';

                                    if isequal(obj.UserData.Emissions.ChannelAssigned(idxEmission).autoSuggested, obj.UserData.Emissions.ChannelAssigned(idxEmission).userModified)
                                        obj.UserData.Emissions.ChannelAssigned(idxEmission)  = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idxEmission, channelObj);
                                    end

                                    if isequal(obj.UserData.Emissions.Classification(idxEmission).autoSuggested, obj.UserData.Emissions.Classification(idxEmission).userModified)
                                        obj.UserData.Emissions.Classification(idxEmission)   = model.UserData.getFieldTemplate('Classification',  obj, 1, idxEmission, channelObj);
                                    end

                                    obj.UserData.Emissions.auxAppData(idxEmission).DriveTest = [];
                                    util.Measures(obj, 1, idxEmission, 'Emission', channelObj)

                                case 'IsTruncated'
                                    obj.UserData.Emissions.isTruncated(idxEmission)          = varargin{3};

                                    obj.UserData.Emissions.ChannelAssigned(idxEmission)      = model.UserData.getFieldTemplate('ChannelAssigned', obj, 1, idxEmission, channelObj);

                                    if isequal(obj.UserData.Emissions.Classification(idxEmission).autoSuggested, obj.UserData.Emissions.Classification(idxEmission).userModified)
                                        obj.UserData.Emissions.Classification(idxEmission)   = model.UserData.getFieldTemplate('Classification',  obj, 1, idxEmission, channelObj);
                                    end
                                    return

                                case 'Description'
                                    obj.UserData.Emissions.Description(idxEmission)          = varargin{3};
                                    return
                            end
        
                        case 'Delete'
                            idxEmissions = varargin{1};
        
                            obj.UserData.Emissions(idxEmissions, :) = [];
                            return

                        otherwise 
                            error('Unexpected update type')
                    end

                    checkIfEmissionsInSearchableBand(obj)

                case 'UserData:OccupancyFields'
                    switch updateType
                        case {'SelectedIndex:Edit', 'SelectedIndex:Refresh'}
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end

                            switch updateType
                                case 'SelectedIndex:Edit'
                                    selectedIndex = varargin{1};
                                case 'SelectedIndex:Refresh'
                                    selectedIndex = [];
                            end

                            obj.UserData.occMethod.SelectedIndex = selectedIndex;

                        case 'Cache:Add'
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end
                            
                            occIndex = varargin{1};
                            occInfo  = varargin{2};
                            occTHR   = varargin{3};
                            occData  = varargin{4};
                            obj.UserData.occCache(occIndex)   = struct('Info', occInfo, 'THR', occTHR, 'Data', {occData});

                        case 'CacheIndex:Edit'
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end

                            occIndex = varargin{1};
                            obj.UserData.occMethod.CacheIndex = occIndex;

                        otherwise
                            error('Unexpected update type')
                    end

                case 'UserData:ReportFields'
                    switch updateType
                        case 'Creation'
                            idxThreads = varargin{1};
                            channelObj = varargin{2};
        
                            for ii = idxThreads
                                obj(ii).UserData.reportFlag = true;
                                
                                % Ocupação
                                checkIfOccupancyPerBinExist(obj(ii))
                
                                % Detecção de emissões
                                FindPeaks(obj, ii, channelObj)
                            end

                        case 'Delete'
                            idxThreads = varargin{1};

                            for ii = idxThreads
                                obj(ii).UserData.reportFlag = false;
                            end

                        case 'ReportOCC:Edit'
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end

                            occCache = varargin{1};
                            obj.UserData.reportAlgorithms.Occupancy = occCache;

                        case 'ReportDetection:ManualMode:Edit'
                            if numel(obj) > 1
                                error('Unexpected non scalar object')
                            end

                            obj.UserData.reportAlgorithms.Detection.ManualMode = varargin{1};

                        otherwise
                            error('Unexpected update type')
                    end

                case 'UserData:OccupancyFields+ReportFields'
                    switch updateType
                        case 'Refresh'
                            idxThreads = varargin{1};
                            channelObj = varargin{2};

                            for ii = idxThreads
                                if ~isempty(obj(ii).UserData.occMethod.CacheIndex)
                                    obj(ii).UserData.occMethod.CacheIndex = [];
                                    obj(ii).UserData.occCache             = struct('Info', {}, 'THR', {}, 'Data', {});

                                    update(obj, 'UserData:ReportFields', 'Creation', ii, channelObj)
                                end
                            end

                        otherwise
                            error('Unexpected update type')
                    end
            end
        end

        %-----------------------------------------------------------------%
        function checkIfOccupancyPerBinExist(obj)
            if isempty(obj.UserData.occMethod.CacheIndex) || ~isequal(size(obj.UserData.occInfIntegration), size(obj.Data{2}))
                occParameters = RF.Occupancy.ParametersDefault();
                occTHR        = RF.Occupancy.Threshold(occParameters.Method, occParameters, obj, 'bin');
                occData       = RF.Occupancy.run(obj.Data{1}, obj.Data{2}, occParameters.Method, occTHR, occParameters.IntegrationTime);
    
                obj.UserData.occMethod.CacheIndex = 1;
                obj.UserData.occCache             = struct('Info', occParameters, 'THR', occTHR, 'Data', {occData});
                obj.UserData.occInfIntegration    = obj.Data{2} > occTHR;
            else
                occIndex      = obj.UserData.occMethod.CacheIndex;
                occParameters = obj.UserData.occCache(occIndex).Info;

                obj.UserData.reportAlgorithms.Occupancy = occParameters;
            end
        end

        %-----------------------------------------------------------------%
        % Toda vez que é incluída emissão à tabela, ou editada, verifica-se
        % se a emissão consta no trecho espectral pesquisável do fluxo sob
        % análise ou se já existe emissão com o mesmo canal.
        %-----------------------------------------------------------------%
        function checkIfEmissionsInSearchableBand(obj)
            for ii = 1:numel(obj)
                bandLimitsStatus = obj(ii).UserData.bandLimitsStatus;
                bandLimitsTable  = obj(ii).UserData.bandLimitsTable;
                emissionsTable   = obj(ii).UserData.Emissions;
            
                if bandLimitsStatus && ~isempty(bandLimitsTable)
                    for jj = height(emissionsTable):-1:1
                        emissionsInSearchableBand = any((emissionsTable.Frequency(jj) >= bandLimitsTable.FreqStart) & (emissionsTable.Frequency(jj) <= bandLimitsTable.FreqStop));

                        if ~emissionsInSearchableBand
                            emissionsTable(jj, :) = [];
                        end
                    end
                end

                % Insere a coluna "Base64", que retorna um Hash do tag da emissão, no
                % formato "100.300 MHz ⌂ 256.0 kHz", por exemplo. Esse Hash é usado p/
                % identificar as emissões únicas.
                emissionsBase64Hash = cellfun(@(x) Base64Hash.encode(x), arrayfun(@(x, y) sprintf('%.3f MHz ⌂ %.1f kHz', x, y), emissionsTable.Frequency, emissionsTable.BW_kHz, "UniformOutput", false), 'UniformOutput', false);
                [~, uniqueIndex]    = unique(emissionsBase64Hash);
                emissionsTable      = sortrows(emissionsTable(uniqueIndex, :), {'idxFrequency', 'BW_kHz'});

                obj(ii).UserData.Emissions = emissionsTable;
            end
        end

        %-----------------------------------------------------------------%
        % ToDo: Revisar esse método...
        %-----------------------------------------------------------------%
        function obj = spectrumRead(obj, metaData, callingApp, d)
            obj = fileMapping(obj, metaData, callingApp.General);
            arrayfun(@(x) setProperty(x, 'callingApp', callingApp), obj)

            nFiles2Read    = numel(metaData);
            prjInfoFlag    = true;

            for ii = 1:nFiles2Read
                [~, fileName, fileExt] = fileparts(metaData(ii).File);
                d.Message = textFormatGUI.HTMLParagraph(sprintf('Em andamento a leitura dos dados de espectro do arquivo:\n•&thinsp;%s\n\n%d de %d', [fileName fileExt], ii, nFiles2Read));
                
                [SpecInfo, prjInfo] = read(metaData(ii).Data, metaData(ii).File, 'SpecData', metaData(ii));
                
                % Mapeamento entre o fluxo cujos dados de espectro acabaram de ser 
                % lidos (SpecInfo) e os fluxos já organizados na principal variável
                % do app (app.specData).
                for jj = 1:numel(SpecInfo)
                    for kk = 1:numel(obj)
                        idx1 = find(cellfun(@(x) ismember(x, unique(SpecInfo(jj).RelatedFiles.uuid)), obj(kk).RelatedFiles.uuid, 'UniformOutput', true));
        
                        if ~isempty(idx1)
                            break
                        end
                    end
        
                    if isempty(idx1)
                        continue
                    end
                    
                    if min(idx1) == 1
                        idx2 = 1;
                    else
                        idx2 = sum(obj(kk).RelatedFiles.nSweeps(1:(min(idx1)-1)))+1;
                    end
                    idx3 = sum(obj(kk).RelatedFiles.nSweeps(1:max(idx1)));
                    
                    obj(kk).Data{1}(1,idx2:idx3) = SpecInfo(jj).Data{1};
                    obj(kk).Data{2}(:,idx2:idx3) = SpecInfo(jj).Data{2};
        
                    if ~isempty(prjInfo)
                        obj(kk).UserData(1) = SpecInfo(jj).UserData;
        
                        if prjInfoFlag
                            prjInfoFlag = false;
        
                            callingApp.report_ProjectName.Value  = fullfile(fileparts(metaData(ii).File), prjInfo.Name);
                            callingApp.report_Issue.Value        = prjInfo.reportInfo.Issue;

                            if isfield(prjInfo.reportInfo, 'Unit')
                                if ismember(prjInfo.reportInfo.Unit, callingApp.report_Unit.Items)
                                    callingApp.report_Unit.Value = prjInfo.reportInfo.Unit;
                                end
                            end

                            if isfield(prjInfo.reportInfo, 'Model')
                                prjModelIndex = find(strcmp(callingApp.report_ModelName.Items, prjInfo.reportInfo.Model.Name), 1);
                                if ~isempty(prjModelIndex)
                                    callingApp.report_ModelName.Value = callingApp.report_ModelName.Items{prjModelIndex};
                                end
                            end

                            if ~isempty(prjInfo.generatedFiles)
                                try
                                    unzipFiles = unzip(prjInfo.generatedFiles, callingApp.General.fileFolder.tempPath);
                                    for ll = 1:numel(unzipFiles)
                                        [~, ~, unzipFileExt] = fileparts(unzipFiles{ll});
    
                                        switch lower(unzipFileExt)
                                            case '.html'
                                                callingApp.projectData.generatedFiles.lastHTMLDocFullPath = unzipFiles{ll};
                                            case '.json'
                                                callingApp.projectData.generatedFiles.lastTableFullPath   = unzipFiles{ll};
                                            case '.mat'
                                                callingApp.projectData.generatedFiles.lastMATFullPath     = unzipFiles{ll};
                                        end
                                    end
                                    
                                    callingApp.projectData.generatedFiles.lastZIPFullPath = prjInfo.generatedFiles;
                                catch 
                                end
                            end
                        end
                    end
                end
            end
            
            d.Message = textFormatGUI.HTMLParagraph('Em andamento outras manipulações, como a aferição de dados estatísticos e a identificação do fluxo de ocupação.');
            obj = finalOrganizationOfData(obj, prjInfo);
        end
        
        %-----------------------------------------------------------------%
        function sortedObj = sort(obj, sortType)
            arguments 
                obj
                sortType char {mustBeMember(sortType, {'Receiver+ID', 'Receiver+Frequency'})} = 'Receiver+Frequency'
            end

            idx = 1:numel(obj);
            switch sortType
                case 'Receiver+ID'
                    [~, sortIndex] = createSortableTable(obj, idx, {'Receiver', 'ID', 'FreqStart', 'FreqStop', 'DataType'});
                case 'Receiver+Frequency'
                    [~, sortIndex] = createSortableTable(obj, idx, {'FreqStart', 'FreqStop', 'DataType'});
            end

            sortedObj = obj(sortIndex);
            occupancyMapping(sortedObj)
        end

        %-----------------------------------------------------------------%
        function obj = merge(obj, idxThreads, hFigure)
            % "obj" como saída é ESSENCIAL para garantir que tenha efeito
            % a diretriz: obj(idxThreads(2:nThreads)) = []; 
            arguments 
                obj
                idxThreads
                hFigure    (1,1) matlab.ui.Figure
            end
            
            % <VALIDATION>
            if numel(idxThreads) < 2
                error(ErrorMessage(obj, 'merge'))
            end

            mergeTable = createSortableTable(obj, idxThreads, {'FreqStart', 'FreqStop'});

            if ~isscalar(unique(mergeTable.Receiver)) || ~isscalar(unique(mergeTable.DataType)) || ~isscalar(unique(mergeTable.LevelUnit))               
                error(ErrorMessage(obj, 'merge'))
            end

            if any(mergeTable.nCoordinates == 0)
                error(ErrorMessage(obj, 'merge:noCoordinates'))
            end

            resolutionList = unique(mergeTable.Resolution);
            stepWidthList  = unique(mergeTable.StepWidth);

            msgQuestion = {};
            if ~isscalar(resolutionList) && ~isscalar(stepWidthList)
                msgQuestion = arrayfun(@(x,y,z,w) sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (RBW), %.3f kHz (passo)', x, y, z, w), mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.Resolution/1000, mergeTable.StepWidth/1000, 'UniformOutput', false);
            elseif ~isscalar(resolutionList)
                msgQuestion = arrayfun(@(x,y,z)   sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (RBW)',                   x, y, z),    mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.Resolution/1000,                            'UniformOutput', false);
            elseif ~isscalar(stepWidthList)
                msgQuestion = arrayfun(@(x,y,z)   sprintf('• <b>%.3f - %.3f MHz</b>: %.3f kHz (passo)',                 x, y, z),    mergeTable.FreqStart/1e+6, mergeTable.FreqStop/1e+6, mergeTable.StepWidth/1000,                             'UniformOutput', false);
            end

            if ~isempty(msgQuestion)
                msgQuestion = sprintf(['Os fluxos espectrais a mesclar possuem valores diferentes de resolução ou passo da varredura.\n\n' ...
                                       '<font style="font-size: 11px;">%s</font>\n\nDeseja continuar esse processo de mesclagem, o que '   ...
                                       'resultará em um fluxo que armazenará como metadados os maiores valores de resolução e passo da varredura?'], strjoin(msgQuestion, '\n'));
                
                userSelection = appUtil.modalWindow(hFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
                if userSelection == "Não"
                    return
                end
            end
            % </VALIDATION>
            
            % <PROCESS>
            mergeType = identifyMergeType(obj, mergeTable);
            nThreads  = numel(idxThreads);

            switch mergeType
                case 'co-channel'
                    refIndex     = 1;
                    timeArray    = [];
                    dataMatrix   = [];
                    relatedFiles = [];
                    
                    for ii = 1:nThreads
                        timeArray    = [timeArray,    obj(idxThreads(ii)).Data{1}]; 
                        dataMatrix   = [dataMatrix,   obj(idxThreads(ii)).Data{2}];
                        relatedFiles = [relatedFiles; obj(idxThreads(ii)).RelatedFiles];
                    end
    
                    if ~issorted(timeArray)
                        [timeArray, idxSort] = sort(timeArray);
                        dataMatrix           = dataMatrix(:,idxSort);
                    end

                    if ~issorted(relatedFiles.BeginTime)
                        relatedFiles = sortrows(relatedFiles, 'BeginTime');
                    end
    
                    obj(idxThreads(refIndex)).Data{1}      = timeArray;
                    obj(idxThreads(refIndex)).GPS          = rmfield(gpsLib.summary(cell2mat(relatedFiles.GPS)), 'Matrix');
                    obj(idxThreads(refIndex)).RelatedFiles = relatedFiles;

                case {'adjacent-channel', 'gap-adjacent-channel'}
                    stepWidthRef = mode(mergeTable.StepWidth);
                    [refNumSweeps, refIndex] = min(mergeTable.nSweeps);
                    dataMatrix   = [];

                    for ii = 1:nThreads
                        newDataPoints = round((mergeTable.FreqStop(ii) - mergeTable.FreqStart(ii))/stepWidthRef + 1);
                        
                        x  = linspace(mergeTable.FreqStart(ii), mergeTable.FreqStop(ii), mergeTable.DataPoints(ii));
                        xq = linspace(mergeTable.FreqStart(ii), mergeTable.FreqStop(ii), newDataPoints);

                        if ii > 1
                            if (mergeTable.FreqStart(ii) ~= mergeTable.FreqStop(ii-1)) && ~isequal(unique(mergeTable.FreqStart(2:end)-mergeTable.FreqStop(1:end-1)), unique(mergeTable.StepWidth))
                                newFreqStart = mergeTable.FreqStop(ii-1);
                                newDataPoints = round((mergeTable.FreqStop(ii) - newFreqStart)/stepWidthRef + 1);
    
                                xq = linspace(newFreqStart, mergeTable.FreqStop(ii), newDataPoints);
                            end                            
                        end

                        if isequal(x, xq)
                            newDataMatrix = obj(idxThreads(ii)).Data{2}(:, 1:refNumSweeps);
                        else
                            newDataMatrix = zeros(newDataPoints, refNumSweeps, 'single');

                            for jj = 1:refNumSweeps
                                refMinValue = min(obj(idxThreads(ii)).Data{2}(:, jj));
                                newDataMatrix(:,jj) = interp1(x, obj(idxThreads(ii)).Data{2}(:, jj), xq, "linear", refMinValue);
                            end
                        end

                        % Elimina o primeiro bin do conjunto de dados atual 
                        % pois ele coincide com o último do conjunto de dados 
                        % anterior.
                        if strcmp(mergeType, 'adjacent-channel') && (ii > 1)
                            newDataMatrix = newDataMatrix(2:end,:);
                        end

                        dataMatrix = [dataMatrix; newDataMatrix];
                    end

                    obj(idxThreads(refIndex)).MetaData.DataPoints = height(dataMatrix);
                    obj(idxThreads(refIndex)).MetaData.FreqStart  = min(mergeTable.FreqStart);
                    obj(idxThreads(refIndex)).MetaData.FreqStop   = max(mergeTable.FreqStop);
            end

            obj(idxThreads(refIndex)).MetaData.Resolution = max(resolutionList);
            obj(idxThreads(refIndex)).Data{2}  = dataMatrix;
            basicStats(obj(idxThreads(refIndex)))

            othersIndex = setdiff(1:nThreads, refIndex);
            delete(obj(idxThreads(othersIndex)))
            obj(idxThreads(othersIndex)) = [];

            occupancyMapping(obj)
            % </PROCESS>
        end

        %-----------------------------------------------------------------%
        function obj = filter(obj, FilterLOG, FilterLogicalArray)
            if ~isscalar(obj)
                error('UnexpectedNonScalarObject')
            end

            % FILTRAGEM
            obj.Data{1}(~FilterLogicalArray)    = [];
            obj.Data{2}(:, ~FilterLogicalArray) = [];

            % LOG
            obj.UserData.LOG{end+1} = jsonencode(FilterLOG);

            % REINICIA CARACTERÍSTICAS RELACIONADAS À INFORMAÇÃO ESPECTRAL
            basicStats(obj)

            obj.UserData.occMethod.CacheIndex = [];
            checkIfOccupancyPerBinExist(obj)

            % Ajusta a informação da propriedade "RelatedFiles", que armazena
            % o período de observação de cada arquivo, o número de amostras
            % e uma estimativa do tempo de revisita.
            HH = height(obj.RelatedFiles);
            for ii = HH:-1:1
                idxSweepsInFile = find((obj.Data{1} >= obj.RelatedFiles.BeginTime(ii)) & (obj.Data{1} <= obj.RelatedFiles.EndTime(ii)));
                if isempty(idxSweepsInFile)
                    obj.RelatedFiles(ii,:) = [];

                else
                    BeginTime = obj.Data{1}(idxSweepsInFile(1));
                    EndTime   = obj.Data{1}(idxSweepsInFile(end));
                    nSweeps   = numel(idxSweepsInFile);

                    obj.RelatedFiles(ii,5:8) = {BeginTime, EndTime, nSweeps, seconds(EndTime-BeginTime)/(nSweeps-1)};
                end
            end
        end

        %-----------------------------------------------------------------%
        function antennaHeight = AntennaHeight(obj, idx, referenceValue, operationType)
            arguments
                obj
                idx
                referenceValue = -1
                operationType  char {mustBeMember(operationType, {'initialValue', 'getCurrentValue', 'refreshValue'})} = 'getCurrentValue'
            end

            antennaHeight = NaN;

            if strcmp(operationType, 'getCurrentValue') && ~isempty(obj(idx).UserData.AntennaHeight)
                antennaHeight = obj(idx).UserData.AntennaHeight;
                
            elseif isfield(obj(idx).MetaData.Antenna, 'Height')
                Height = obj(idx).MetaData.Antenna.Height;

                if isnumeric(Height) && isfinite(Height) && (Height > 0)
                    antennaHeight = Height;
                elseif ischar(Height)
                    antennaHeight = str2double(extractBefore(Height, 'm'));
                end
            end

            if isnan(antennaHeight)
                antennaHeight = referenceValue;
            end
        end

        %-----------------------------------------------------------------%
        function tag = Tag(obj, idx)
            tag = sprintf('%s\n%.3f - %.3f MHz', obj(idx).Receiver,                  ...
                                                 obj(idx).MetaData.FreqStart / 1e+6, ...
                                                 obj(idx).MetaData.FreqStop  / 1e+6);
        end

        %-----------------------------------------------------------------%
        function FindPeaks(obj, idx, channelObj)
            findPeaks = FindPeaksOfPrimaryBand(channelObj, obj(idx));

            if ~isempty(findPeaks)
                obj(idx).UserData(1).reportAlgorithms.Detection.Parameters = struct('Distance_kHz', 1000 * findPeaks.Distance, ... % MHz >> kHz
                                                                                    'BW_kHz',       1000 * findPeaks.BW,       ... % MHz >> kHz
                                                                                    'Prominence1',  findPeaks.Prominence1,     ...
                                                                                    'Prominence2',  findPeaks.Prominence2,     ...
                                                                                    'meanOCC',      findPeaks.meanOCC,         ...
                                                                                    'maxOCC',       findPeaks.maxOCC);
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function setProperty(obj, propName, propValue)
            obj.(propName) = propValue;
        end

        %-----------------------------------------------------------------%
        function status = checkIfSameMetaData(obj, idx1, idx2)
            status = strcmp(obj(idx1).Receiver, obj(idx2).Receiver)                && ...
                     obj(idx1).MetaData.FreqStart  == obj(idx2).MetaData.FreqStart && ...
                     obj(idx1).MetaData.FreqStop   == obj(idx2).MetaData.FreqStop  && ...
                     obj(idx1).MetaData.DataPoints == obj(idx2).MetaData.DataPoints;
        end

        %-----------------------------------------------------------------%
        function occupancyMapping(obj)
            dataTypesArray = arrayfun(@(x) x.MetaData.DataType, obj);
            idxOCCThreads  = find(ismember(dataTypesArray, class.Constants.occDataTypes));

            if ~isempty(idxOCCThreads)
                for ii = 1:numel(obj)                         
                    relatedIndex  = [];
                    for jj = idxOCCThreads
                        if checkIfSameMetaData(obj, ii, jj)
                            relatedIndex = [relatedIndex, jj];
                        end
                    end
                    
                    if ~isempty(relatedIndex)
                        obj(ii).UserData(1).occMethod.RelatedIndex  = relatedIndex;
                        obj(ii).UserData(1).occMethod.SelectedIndex = relatedIndex(1);
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function [sortTable, sortIndex] = createSortableTable(obj, idxThreads, columnNames)
            NN = numel(idxThreads);
            sortTable = table('Size',          [NN, 12],                                                                                                             ...
                              'VariableTypes', {'double', 'cell', 'double', 'double', 'double', 'double', 'cell', 'double', 'double', 'double', 'double', 'double'}, ...
                              'VariableNames', {'idx', 'Receiver', 'ID', 'DataType', 'FreqStart', 'FreqStop', 'LevelUnit', 'DataPoints', 'StepWidth', 'Resolution', 'nSweeps', 'nCoordinates'});

            for ii = 1:NN
                idx = idxThreads(ii);
                sortTable(ii,:) = {idx,                          ...
                                   obj(idx).Receiver,            ...
                                   obj(idx).RelatedFiles.ID(1),  ...
                                   obj(idx).MetaData.DataType,   ...
                                   obj(idx).MetaData.FreqStart,  ...
                                   obj(idx).MetaData.FreqStop,   ...
                                   obj(idx).MetaData.LevelUnit,  ...
                                   obj(idx).MetaData.DataPoints, ...
                                   (obj(idx).MetaData.FreqStop - obj(idx).MetaData.FreqStart) / (obj(idx).MetaData.DataPoints - 1), ...
                                   obj(idx).MetaData.Resolution, ...
                                   numel(obj(idx).Data{1}),      ...
                                   obj(idx).GPS.Count};
            end
            
            sortTable = sortrows(sortTable, columnNames);
            sortIndex = sortTable.idx;
        end

        %-----------------------------------------------------------------%
        function obj = fileMapping(obj, metaData, generalSettings)
            % O argumento de entrada "obj" aponta para um objeto vazio. Ao 
            % executar "obj(1:nThreads) = SpecInfo;" estou apontando essa
            % variável "obj" para outro objeto - o SpecInfo. Por isso, devo 
            % ter "obj" como argumento de saída.

            for ii = 1:numel(metaData)
                SpecInfo = copy(metaData(ii).Data, {'RelatedFiles', 'FileMap'});
        
                if ii == 1
                    nThreads        = numel(metaData(ii).Data);
                    obj(1:nThreads) = SpecInfo;
                    fileIndexMap    = num2cell((1:nThreads)');
                    continue
                end
        
                % Mapeamento entre os fluxos...
                SpecInfo_MetaData = comparableMetaData(SpecInfo, generalSettings);
                for mm = 1:numel(SpecInfo)
                    specData_MetaData = comparableMetaData(obj, generalSettings);
        
                    idx1 = [];
                    for kk = 1:numel(obj)
                        Distance_GPS = deg2km(distance(SpecInfo(mm).GPS.Latitude, SpecInfo(mm).GPS.Longitude, obj(kk).GPS.Latitude, obj(kk).GPS.Longitude)) * 1000;
        
                        if isequal(specData_MetaData(kk), SpecInfo_MetaData(mm)) && (Distance_GPS <= generalSettings.Merge.Distance)
                            idx1 = kk;
        
                            if width(fileIndexMap) < ii
                                fileIndexMap{idx1, ii} = mm;
                            else
                                fileIndexMap{idx1, ii} = [fileIndexMap{idx1, ii}, mm];
                            end
                            break
                        end
                    end
        
                    if isempty(idx1)
                        idx2 = numel(obj)+1;
                        
                        obj(idx2)     = SpecInfo(mm);
                        fileIndexMap{idx2, ii} = mm;
                    end
                end
            end
            
            % Pré-alocação:
            for ll = numel(obj):-1:1
                % Elimina fluxos filtrados...
                if ~obj(ll).Enable
                    delete(obj(ll))
                    obj(ll) = [];

                    fileIndexMap(ll,:) = [];        
                    continue
                end
        
                for mm = 1:width(fileIndexMap)
                    idxMap = fileIndexMap{ll,mm};

                    for kk = idxMap
                        nFiles = height(metaData(mm).Data(kk).RelatedFiles);
                        obj(ll).RelatedFiles(end+1:end+nFiles,:) = metaData(mm).Data(kk).RelatedFiles;
                    end
                end
                preallocateData(obj(ll));
            end
        end

        %-----------------------------------------------------------------%
        function comparableData = comparableMetaData(obj, generalSettings)        
            % Trata-se de função que define as características primárias (listadas 
            % abaixo) que identificam uma monitoração, possibilitando juntar informações 
            % registradas em diferentes arquivos.
            % - Receiver
            % - FreqStart, FreqStop
            % - LevelUnit
            % - DataPoints
            % - Resolution e VBW
            % - Threshold
            % - TraceMode, TraceIntegration e Detector
        
            % Pode-se excluir, dentre os campos de "MetaData", os campos DataType, 
            % Antenna e Others.
            % - O DataType por não estar relacionado à monitoração; 
            % - A Antenna que é um metadado comumente incluso manualmente pelo 
            %   fiscal (exceção à monitoração conduzida na EMSat);
            % - E o novo campo Others, que vai armazenar metadados secundários.

            % Lista de metadados a excluir:
            metaData2Delete = {'Others'};
            if generalSettings.Merge.Antenna == "remove"
                metaData2Delete{end+1} = 'Antenna';
            end
            if generalSettings.Merge.DataType == "remove"
                metaData2Delete{end+1} = 'DataType';
            end

            % Estrutura de referência:        
            for ii = 1:numel(obj)
                tempStruct = rmfield(obj(ii).MetaData, metaData2Delete);
                tempStruct.Receiver = obj(ii).Receiver;

                if isfield(tempStruct, 'Antenna') && ~isempty(tempStruct.Antenna)
                    antennaFields = fields(tempStruct.Antenna);
                    antennaFields = antennaFields(~ismember(antennaFields, generalSettings.Merge.AntennaAttributes));
                    
                    tempStruct.Antenna = rmfield(tempStruct.Antenna, antennaFields);
                end
        
                comparableData(ii) = tempStruct;
            end
        end

        %-----------------------------------------------------------------%
        function obj = finalOrganizationOfData(obj, prjInfo)
            obj = sort(obj, obj(1).sortType);
            app = obj(1).callingApp;

            for ii = 1:numel(obj)
                % Ordenando os dados...
                if ~issorted(obj(ii).Data{1})
                    [obj(ii).Data{1}, idx2] = sort(obj(ii).Data{1});
                    obj(ii).Data{2}         = obj(ii).Data{2}(:,idx2);
                end

                % Ordenando os arquivos...
                if ~issorted(obj(ii).RelatedFiles.BeginTime)
                    obj(ii).RelatedFiles = sortrows(obj(ii).RelatedFiles, 'BeginTime');
                end
        
                % GPS
                if height(obj(ii).RelatedFiles) > 1
                    update(obj, 'GPS', 'Refresh', ii)
                end
        
                % Estatística básica dos dados:
                basicStats(obj(ii))

                % O índice do "UserData" inicializa a estrutura...
                obj(ii).UserData(1).AntennaHeight = AntennaHeight(obj, ii, -1, 'initialValue');

                if ~app.General.Channel.ManualMode && ismember(obj(ii).MetaData.DataType, class.Constants.specDataTypes) && isempty(prjInfo)                    
                    obj(ii).UserData(1).channelLibIndex = FindRelatedBands(app.channelObj, obj(ii));
                end

                FindPeaks(obj, ii, app.channelObj)
                obj(ii).UserData(1).reportAlgorithms.Detection.ManualMode = app.General.Detection.ManualMode;
            end
        
            idxThreads = find(arrayfun(@(x) x.UserData.reportFlag, obj));
            update(obj, 'UserData:ReportFields', 'Creation', idxThreads, app.channelObj, @app.play_OCCIndex)
        end

        %-----------------------------------------------------------------%
        function mergeType = identifyMergeType(obj, mergeTable)
            if isscalar(unique(mergeTable.FreqStart)) && ...
               isscalar(unique(mergeTable.FreqStop))  && ...
               isscalar(unique(mergeTable.DataPoints))
                mergeType = 'co-channel';

            elseif issorted(mergeTable.FreqStart, "strictascend") && ...
               all(mergeTable.FreqStart(2:height(mergeTable)) <= mergeTable.FreqStop(1:height(mergeTable)-1))
                mergeType = 'adjacent-channel';
            
            elseif issorted(mergeTable.FreqStart, "strictascend") && ...
                   issorted(mergeTable.FreqStop,  "strictascend")
                mergeType = 'gap-adjacent-channel';
            
            else
                error(ErrorMessage(obj, 'merge'))
            end
        end

        %-----------------------------------------------------------------%
        function errorMessage = ErrorMessage(obj, errorType)
            switch errorType
                case 'merge'
                    errorMessage = sprintf(['Os fluxos espectrais a mesclar não atendem aos requisitos dos dois tipos de mesclagem implantados no <i>app</i>, quais sejam:\n\n'    ...
                                           '• Tipo "co-channel": os fluxos devem possuir os campos "FreqStart", "FreqStop", "LevelUnit", "DataPoints" e "DataType" idênticos;\n\n' ...
                                           '• Tipo "adjacent-channel": os fluxos devem estar relacionados a faixas de frequências adjacentes, podendo ter sobreposição espectral entre fluxos, além de possuírem os campos "LevelUnit", "nSweeps" e "DataType" idênticos.']);
                case 'merge:noCoordinates'
                    errorMessage = sprintf('Ao menos um dos fluxos espectrais selecionados não pode ser mesclado por ser desconhecido o seu local da monitoração.');
                otherwise
                    errorMessage = 'Unknown error';
            end
        end
    end
end