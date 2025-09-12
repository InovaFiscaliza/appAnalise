function htmlReport = ReportGenerator(app, idxThreads, reportInfo, progressDialog)
    
    global hContainer

    if nargin == 3
        progressDialog = [];
    end

    internalFcn_counterCreation()
    tempBandObj   = class.Band('appAnalise:REPORT:BAND', app);
    
    % HTML header (style)
    htmlReport = '';
    if ismember(reportInfo.Model.Version, {'preview', 'Preliminar'})
        docTitle   = reportInfo.Model.Name;
        docType    = reportInfo.Model.DocumentType;
        docStyle   = sprintf(fileread(fullfile(reportLib.Path, 'html', 'docStyle.txt')), docTitle, docType);

        htmlReport = sprintf('%s\n\n', docStyle);
    end
    tableStyleFlag = 1;

    % HTML body
    jsonScript = jsondecode(reportInfo.Model.Script);
    for ii = 1:numel(jsonScript)
        parentNode = jsonScript(ii);

        if isfield(parentNode.Data, 'Variable') && ~isempty(parentNode.Data.Variable)
            parentNode.Data.Text = internalFcn_FillWords(app.specData, idxThreads, 1, reportInfo, parentNode);
        end
        htmlReport = [htmlReport, reportLib.sourceCode.htmlCreation(parentNode)];

        if tableStyleFlag
            htmlReport = sprintf('%s%s\n\n', htmlReport, fileread(fullfile(reportLib.Path, 'html', 'docTableStyle.txt')));
            tableStyleFlag = 0;
        end

        NN = 1;
        if parentNode.Recurrence
            NN = numel(idxThreads);
        end

        for jj = 1:NN
            if parentNode.Recurrence && ~isempty(progressDialog)
                progressDialog.Message = sprintf('<p style="font-size: 12px; text-align: justify;">%d de %d</p>', jj, NN);
            end

            update(tempBandObj, idxThreads(jj));
            reportInfo.General.Parameters.Plot = struct('idxThread',   idxThreads(jj), ...
                                                        'idxBand',     jj,             ...
                                                        'idxChannel',  -1,             ...
                                                        'idxEmission', -1);

            % Insere uma quebra de linha, caso exista recorrência no
            % item.
            if jj > 1
                htmlReport = [htmlReport, reportLib.sourceCode.LineBreak];
            end

            htmlReport = [htmlReport, HTMLRenderization(parentNode, app.specData, idxThreads, jj, reportInfo, tempBandObj)];

            % Atualiza barra de progresso... e cancela operação, caso
            % requisitado pelo usuário.
            if parentNode.Recurrence && ~isempty(progressDialog)
                if progressDialog.CancelRequested
                    return
                end
            end
        end
    end

    % HTML footnotes
    FootnoteList = fields(reportInfo.Version);
    FootnoteText = '';
        
    for ii = 1:numel(FootnoteList)
        FootnoteVersion = reportInfo.Version.(FootnoteList{ii});

        if ~isempty(FootnoteVersion)
            FootnoteFields = fields(FootnoteVersion);
            
            FootnoteFieldsText = {};
            for jj = 1:numel(FootnoteFields)
                switch FootnoteFields{jj}
                    case 'name'
                        FootnoteFieldsText{end+1} = sprintf('<b>__%s</b>', upper(FootnoteVersion.(FootnoteFields{jj})));
                    otherwise
                        if isstruct(FootnoteVersion.(FootnoteFields{jj}))
                            FootnoteVersion.(FootnoteFields{jj}) = jsonencode(FootnoteVersion.(FootnoteFields{jj}));
                        end

                        FootnoteFieldsText{end+1} = sprintf('<b>%s</b>: %s', FootnoteFields{jj}, string(FootnoteVersion.(FootnoteFields{jj})));
                end
            end
            FootnoteFieldsText = strjoin(FootnoteFieldsText, ', ');
            FootnoteText       = [FootnoteText, reportLib.sourceCode.htmlCreation(struct('Type', 'Footnote', 'Data', struct('Editable', 'false', 'Text', FootnoteFieldsText, 'Variable', [])))];
        end
    end
    htmlReport = [htmlReport, reportLib.sourceCode.LineBreak, reportLib.sourceCode.Separator, FootnoteText, reportLib.sourceCode.LineBreak];

    % HTML trailer
    if ismember(reportInfo.Model.Version, {'preview', 'Preliminar'})
        htmlReport = sprintf('%s</body>\n</html>', htmlReport);
    end

    if ~isempty(hContainer) && isvalid(hContainer)
        delete(hContainer.Children)
    end

    arrayfun(@(x) eval('x.UserData.reportChannelTable    = [];'), app.specData)
    arrayfun(@(x) eval('x.UserData.reportChannelAnalysis = [];'), app.specData)
end

%-------------------------------------------------------------------------%
function htmlContent = HTMLRenderization(parentNode, specData, idxThreads, idx, reportInfo, tempBandObj)
    
    arguments
        parentNode
        specData
        idxThreads
        idx
        reportInfo
        tempBandObj
    end

    if ~isfield(parentNode, 'Recurrence')
        parentNode.Recurrence = 0;
    end
    
    htmlContent = '';

    for ii = 1:numel(parentNode.Data.Children)
        childNode = parentNode.Data.Children(ii);
        childType = childNode.Type;
    
        try
            switch childType
                case 'Container'
                    htmlTempContent = '';

                    switch childNode.Data.Source
                        case 'Channel'
                            channelBandObj = class.Band('appAnalise:REPORT:CHANNEL', tempBandObj.callingApp);

                            for channelIndex = 1:height(specData(idxThreads(idx)).UserData.reportChannelTable)
                                if ~specData(idxThreads(idx)).UserData.reportChannelAnalysis.("Qtd. emissões")(channelIndex)
                                    continue
                                end

                                update(channelBandObj, idxThreads(idx), channelIndex);
                                reportInfo.General.Parameters.Plot.idxChannel = channelIndex;

                                htmlTempContent = [htmlTempContent, reportLib.sourceCode.Separator, HTMLRenderization(childNode, specData, idxThreads, idx, reportInfo, channelBandObj)];
                            end

                        case 'Emission'
                            emissionBandObj = class.Band('appAnalise:REPORT:EMISSION', tempBandObj.callingApp);

                            for emissionIndex = 1:height(specData(idxThreads(idx)).UserData.Emissions)
                                if isempty(specData(idxThreads(idx)).UserData.Emissions.auxAppData(emissionIndex).DriveTest)
                                    continue
                                end

                                update(emissionBandObj, idxThreads(idx), emissionIndex);
                                reportInfo.General.Parameters.Plot.idxEmission = emissionIndex;

                                htmlTempContent = [htmlTempContent, reportLib.sourceCode.Separator, HTMLRenderization(childNode, specData, idxThreads, idx, reportInfo, emissionBandObj)];
                            end

                        otherwise
                            error('UnexpectedValue')
                    end
    
                case {'ItemN2', 'ItemN3', 'Paragraph', 'List', 'Footnote'}
                    for jj = 1:numel(childNode.Data)
                        if isfield(childNode.Data(jj), 'Variable') && ~isempty(childNode.Data(jj).Variable)
                            childNode.Data(jj).Text = internalFcn_FillWords(specData, idxThreads, idx, reportInfo, childNode);
                        end
                    end
    
                    htmlTempContent = reportLib.sourceCode.htmlCreation(childNode);
    
                case 'Image'
                    hFigure    = tempBandObj.callingApp.UIFigure;

                    plotName   = strsplit(childNode.Data.Plot, ':');
                    plotLayout = str2double(strsplit(childNode.Data.Layout, ':'));    
                    plotInfo   = arrayfun(@(x, y) struct('Name', x, 'Layout', y), plotName, plotLayout);

                    % Outra exceção... 
                    % Se a ideia é incluir o plot da rota percorrida no início
                    % do relatório, deve-se identificar a rota que apresenta
                    % a maior variação das coordenadas geográficas.
                    if ~parentNode.Recurrence && isequal(plotName, {'DriveTestRoute'})
                        referenceGPS = arrayfun(@(x) x.GPS, specData(idxThreads));

                        [~, idxLat]  = max([referenceGPS.Latitude_std]);
                        [~, idxLong] = max([referenceGPS.Longitude_std]);

                        if idxLat == idxLong
                            idx = idxLat;
                        elseif ~ismember(idx, [idxLat, idxLong])
                            idx = idxLat;
                        end
                    end
                    
                    Image = Fcn_Image(specData, idxThreads, idx, tempBandObj, reportInfo, parentNode.Recurrence, childNode, plotInfo, hFigure);
                    htmlTempContent = reportLib.sourceCode.htmlCreation(childNode, Image);
    
                case 'Table'
                    Table = Fcn_Table(specData, idxThreads, idx, tempBandObj, reportInfo, parentNode.Recurrence, childNode);
                    htmlTempContent = reportLib.sourceCode.htmlCreation(childNode, Table);
    
                otherwise
                    error('Unexpected type "%s"', childType)
            end

            htmlContent = [htmlContent, htmlTempContent];
    
        catch ME
            struct2table(ME.stack)
            msgError = extractAfter(ME.message, 'Configuration file error message: ');
    
            if ~isempty(msgError)
                htmlContent = reportLib.sourceCode.AuxiliarHTMLBlock(htmlContent, 'Error', msgError);
            end
        end
    end
end

%-------------------------------------------------------------------------%
function internalFcn_counterCreation()
    global ID_img
    global ID_tab

    ID_img = 0;
    ID_tab = 0;
end

%-------------------------------------------------------------------------%
function Text = internalFcn_FillWords(specData, idxThreads, idx, reportInfo, Children)
    for ii = 1:numel(Children.Data.Variable)
        Precision = string(Children.Data.Variable(ii).Precision);
        fieldName = Children.Data.Variable(ii).Source;
        
        FillWords(ii) = sprintf(Precision, Fcn_Source(specData, idxThreads, idx, reportInfo, fieldName));
    end
    
    Text = sprintf(Children.Data.Text, FillWords);
end

%-------------------------------------------------------------------------%
function value = Fcn_Source(specData, idxThreads, idx, reportInfo, fieldName)
    arguments
        specData 
        idxThreads
        idx
        reportInfo 
        fieldName char {mustBeMember(fieldName, {'Band',             ...
                                                 'BeginTime',        ...
                                                 'Description',      ...
                                                 'EndTime',          ...
                                                 'FreqStart',        ...
                                                 'FreqStop',         ...
                                                 'GPS',              ...
                                                 'Issue',            ...
                                                 'Location',         ...
                                                 'ObservationTime',  ...
                                                 'Receiver',         ...
                                                 'RelatedFiles',     ...
                                                 'RelatedLocations', ...
                                                 'StepWidth',        ...
                                                 'Parameters',       ...
                                                 'threadTag',        ...
                                                 'channelTag',       ...
                                                 'emissionTag'})}
    end

    switch fieldName
        case 'Band'
            value = sprintf('%.3f - %.3f MHz', specData(idxThreads(idx)).MetaData.FreqStart * 1e-6, specData(idxThreads(idx)).MetaData.FreqStop * 1e-6);
        case 'BeginTime'
            value = char(specData(idxThreads(idx)).Data{1}(1));
        case 'Description'
            value = specData(idxThreads(idx)).RelatedFiles.Description{1};
        case 'EndTime'
            value = char(specData(idxThreads(idx)).Data{1}(end));        
        case 'FreqStart'
            value = specData(idxThreads(idx)).MetaData.FreqStart * 1e-6;
        case 'FreqStop'
            value = specData(idxThreads(idx)).MetaData.FreqStop  * 1e-6;
        case 'GPS'
            value = sprintf('%.6f, %.6f (%s)', specData(idxThreads(idx)).GPS.Latitude,  specData(idxThreads(idx)).GPS.Longitude, specData(idxThreads(idx)).GPS.Location);
        case 'Issue'
            value = reportInfo.Issue;
        case 'Location'
            value = specData(idxThreads(idx)).GPS.Location;
        case 'ObservationTime'
            BeginTime   = specData(idxThreads(idx)).Data{1}(1);
            EndTime     = specData(idxThreads(idx)).Data{1}(end);
            nSweeps     = numel(specData(idxThreads(idx)).Data{1});
            RevisitTime = mean(specData(idxThreads(idx)).RelatedFiles.RevisitTime);
            value = sprintf('%s - %s<br>%d varreduras<br>%.1f segundos (tempo de revisita estimado)', BeginTime, EndTime, nSweeps, RevisitTime);
        case 'Receiver'
            value = specData(idxThreads(idx)).Receiver;
        case 'RelatedFiles'
            value = strjoin(specData(idxThreads(idx)).RelatedFiles.File, ', ');        
        case 'RelatedLocations'
            value = strjoin(unique(arrayfun(@(x) x.GPS.Location, specData(idxThreads), 'UniformOutput', false), 'stable'), ', ');
        case 'StepWidth'
            value = ((specData(idxThreads(idx)).MetaData.FreqStop - specData(idxThreads(idx)).MetaData.FreqStart) / (specData(idxThreads(idx)).MetaData.DataPoints - 1)) * 1e-3;
        case 'Parameters'
            value = {};

            % Description
            value{end+1} = sprintf('- Descrição: "%s"', Fcn_Source(specData, idxThreads, idx, reportInfo, 'Description'));
            
            % TraceMode+TraceIntegration+Detector
            if ~isempty(specData(idxThreads(idx)).MetaData.TraceMode) 
                TraceIntegration = '';
                if specData(idxThreads(idx)).MetaData.TraceIntegration ~= -1
                    TraceIntegration = sprintf(' (Integração: %d amostras)', specData(idxThreads(idx)).MetaData.TraceIntegration);
                end

                if ~isempty(specData(idxThreads(idx)).MetaData.Detector)
                    Operation = sprintf('- Operação: %s-%s%s', specData(idxThreads(idx)).MetaData.TraceMode, specData(idxThreads(idx)).MetaData.Detector, TraceIntegration);
                else
                    Operation = sprintf('- Operação: %s%s', specData(idxThreads(idx)).MetaData.TraceMode, TraceIntegration);
                end

            elseif ~isempty(specData(idxThreads(idx)).MetaData.Detector)
                Operation = sprintf('- Operação: %s', specData(idxThreads(idx)).MetaData.Detector);
            end
            value{end+1} = Operation;

            % DataPoints
            value{end+1} = sprintf('- %d pontos por varredura', specData(idxThreads(idx)).MetaData.DataPoints);

            % Resolution+VBW+StepWidth
            RBW       = specData(idxThreads(idx)).MetaData.Resolution/1000;
            VBW       = specData(idxThreads(idx)).MetaData.VBW/1000;
            StepWidth = Fcn_Source(specData, idxThreads, idx, reportInfo, 'StepWidth');

            if (specData(idxThreads(idx)).MetaData.Resolution ~= -1) && (specData(idxThreads(idx)).MetaData.VBW ~= -1)
                Resolution = sprintf('- Resolução: %.3f kHz (RBW), %.3f kHz (VBW), %.3f kHz (Passo da varredura)', RBW, VBW, StepWidth);
            elseif specData(idxThreads(idx)).MetaData.Resolution ~= -1
                Resolution = sprintf('- Resolução: %.3f kHz (RBW), %.3f kHz (Passo da varredura)', RBW, StepWidth);
            elseif specData(idxThreads(idx)).MetaData.VBW ~= -1
                Resolution = sprintf('- Resolução: %.3f kHz (VBW), %.3f kHz (Passo da varredura)', VBW, StepWidth);
            else
                Resolution = sprintf('- Resolução: %.3f kHz (Passo da varredura)', StepWidth);
            end
            value{end+1} = Resolution;

            % Antenna
            value{end+1} = sprintf('- Antena: %s', jsonencode(specData(idxThreads(idx)).MetaData.Antenna));

            % GPS
            value{end+1} = sprintf('- GPS: %.6f, %.6f (%s)', specData(idxThreads(idx)).GPS.Latitude,  ...
                                                             specData(idxThreads(idx)).GPS.Longitude, ...
                                                             specData(idxThreads(idx)).GPS.Location);
            % Lista de arquivos
            value{end+1} = sprintf('- Arquivo(s): %s', Fcn_Source(specData, idxThreads, idx, reportInfo, 'RelatedFiles'));

            % Others
            if ~isempty(specData(idxThreads(idx)).MetaData.Others)
                value{end+1} = sprintf('- Outros metadados: %s', specData(idxThreads(idx)).MetaData.Others);
            end

            value = strjoin(value, '<br>');
        case 'threadTag'
            idxThread = reportInfo.General.Parameters.Plot.idxThread;
            idxBand   = reportInfo.General.Parameters.Plot.idxBand;

            value = sprintf('FAIXA DE FREQUÊNCIA #%d: <b>%.3f - %.3f MHz</b>', idxBand,                                     ...
                                                                             specData(idxThread).MetaData.FreqStart * 1e-6, ...
                                                                             specData(idxThread).MetaData.FreqStop  * 1e-6);
        case 'channelTag'
            idxThread  = reportInfo.General.Parameters.Plot.idxThread;
            idxBand    = reportInfo.General.Parameters.Plot.idxBand;
            idxChannel = reportInfo.General.Parameters.Plot.idxChannel;
            
            chTable = specData(idxThread).UserData.reportChannelTable;
            chName  = extractBefore(chTable.Name{idxChannel}, ' @');
            if isempty(chName)
                chName = chTable.Name{idxChannel};
            end
            value = sprintf('CANAL #%d.%d: <b>%s @ %.3f MHz ⌂ %.1f kHz</b>', idxBand, idxChannel,  chName,     ...
                                                                             chTable.FirstChannel(idxChannel), ...
                                                                             chTable.ChannelBW(idxChannel) * 1000);
        case 'emissionTag'
            idxThread   = reportInfo.General.Parameters.Plot.idxThread;
            idxBand     = reportInfo.General.Parameters.Plot.idxBand;
            idxEmission = reportInfo.General.Parameters.Plot.idxEmission;

            value = sprintf('EMISSÃO #%d.%d: <b>%.3f MHz ⌂ %.1f kHz</b>',    idxBand, idxEmission,                                          ...
                                                                             specData(idxThread).UserData.Emissions.Frequency(idxEmission), ...
                                                                             specData(idxThread).UserData.Emissions.BW_kHz(idxEmission));
    end
end

%-------------------------------------------------------------------------%
% IMAGEM
%-------------------------------------------------------------------------%
function hContainer = PlotContainer(hFigure)
    xWidth     = class.Constants.windowSize(1);
    yHeight    = class.Constants.windowSize(2);    
    hContainer = uipanel(hFigure, AutoResizeChildren='off',          ...
                                  Position=[100 100 xWidth yHeight], ...
                                  BorderType='none',                 ...
                                  BackgroundColor=[0 0 0],           ...
                                  Visible=0);
end

%-------------------------------------------------------------------------%
function Image = Fcn_Image(specData, idxThreads, idx, tempBandObj, reportInfo, Recurrence, Children, plotInfo, hFigure)
    global hContainer

    Image = '';
    switch Children.Data.Origin
        case 'Internal'
            if isempty(hContainer) || ~isvalid(hContainer)
                hContainer = PlotContainer(hFigure);
            end

            Image = reportLibConnection.Plot.Controller(hContainer, specData, idxThreads(idx), tempBandObj, reportInfo, plotInfo);

        case 'External'
            if Recurrence
                idxImage  = find(strcmp(specData(idxThreads(idx)).UserData.reportExternalFiles.Type, 'Image') & strcmpi(specData(idxThreads(idx)).UserData.reportExternalFiles.Tag,  plotInfo.Name), 1);
                if ~isempty(idxImage)
                    Image = specData(idxThreads(idx)).UserData.reportExternalFiles.Filename{idxImage};
                end

            else
                idxImage  = find(strcmp(reportInfo.ExternalFiles.Type, 'Image') & strcmpi(reportInfo.ExternalFiles.Tag,  plotInfo.Name), 1);
                if ~isempty(idxImage)
                    Image = sreportInfo.ExternalFiles.Filename{idxImage};
                end
            end
    end

    if ~isfile(Image)
        error('Configuration file error message: %s', Children.Data.Error)
    end
end

%-------------------------------------------------------------------------%
% TABELA
%-------------------------------------------------------------------------%
function Table = Fcn_Table(specData, idxThreads, idx, tempBandObj, reportInfo, Recurrence, Children)    
    Origin = Children.Data.Origin;
    Source = '';
    
    if Origin == "Internal"
        Source = Children.Data.Source;

    else
        if Recurrence
            idxTable = find(strcmp(specData(idxThreads(idx)).UserData.reportExternalFiles.Type, 'Table') & strcmpi(specData(idxThreads(idx)).UserData.reportExternalFiles.Tag,  Children.Data.Source), 1);
            if ~isempty(idxTable)
                Source  = specData(idxThreads(idx)).UserData.reportExternalFiles.Filename{idxTable};
                SheetID = specData(idxThreads(idx)).UserData.reportExternalFiles.ID(idxTable);
            end

        else
            idxTable = find(strcmp(reportInfo.ExternalFiles.Type, 'Table') & strcmpi(reportInfo.ExternalFiles.Tag,  Children.Data.Source), 1);
            if ~isempty(idxTable)
                Source  = reportInfo.ExternalFiles.Filename{idxTable};
                SheetID = reportInfo.ExternalFiles.ID(idxTable);
            end
        end
    end

    if isempty(Source) || ((Origin == "External") && ~isfile(Source))
        error('Configuration file error message: %s', Children.Data.Error)
    end

    Table = [];
    switch Origin
        case 'Internal'
            switch Source
                case 'Algorithms'
                    Table = reportLibConnection.table.Algorithms(specData, idxThreads(idx));
                    Table = Fcn_Table_PreProcess(Table, reportInfo, Children);

                case 'Channel'
                    chTable = specData(idxThreads(idx)).UserData.reportChannelAnalysis;
                    if isempty(chTable)
                        chTable = reportLibConnection.table.Channel(specData, idxThreads(idx), tempBandObj);
                    end
                    Table = Fcn_Table_PreProcess(chTable, reportInfo, Children);

                case 'EmissionPerChannel'
                    chIndex = reportInfo.General.Parameters.Plot.idxChannel;
                    chTable = specData(idxThreads(idx)).UserData.reportChannelAnalysis;
                    if isempty(chTable)
                        chTable = reportLibConnection.table.Channel(specData, idxThreads(idx), tempBandObj);
                    end
                    emissionTable = chTable.("Emissões"){chIndex};
                    Table = Fcn_Table_PreProcess(emissionTable, reportInfo, Children);
        
                case 'EmissionPerBand'
                    if ~isempty(specData(idxThreads(idx)).UserData.Emissions)
                        Table = util.createEmissionsTable(specData, idxThreads(idx), 'REPORT: HTMLFile');
                        Table = Fcn_Table_PreProcess(Table, reportInfo, Children);
                        Table.Properties.VariableNames = replace(Table.Properties.VariableNames, '%LevelUnit%', specData(idxThreads(idx)).MetaData.LevelUnit);
                    end
        
                case 'Summary'
                    Table = reportLibConnection.table.Summary(specData, idxThreads, 'REPORT', 'TotalSummaryTable');
                    Table = Fcn_Table_PreProcess(Table, reportInfo, Children);

                case 'Irregular'
                    Table = reportLibConnection.table.Summary(specData, idxThreads, 'REPORT', 'IrregularTable');
                    Table = Fcn_Table_PreProcess(Table, reportInfo, Children);
        
                case 'Custom'
                    NN = numel(Children.Data.Settings);
        
                    VariableNames = {Children.Data.Settings.ColumnName};
                    VariableTypes = {};        
                    for ii = 1:NN
                        Precision = regexp(Children.Data.Settings(ii).Precision, '\w*%(s|d|.[013]f)\w*', 'match', 'once');
                        switch Precision
                            case '%s'
                                VariableTypes(end+1) = {'cell'};
                            case '%d'
                                VariableTypes(end+1) = {'int64'};
                            case {'%.0f', '%.1f', '%.3f'}
                                VariableTypes(end+1) = {'double'};
                            otherwise
                                error('UnexpectedFormat')
                        end
                    end
        
                    % Identifica quantidade de fluxos de espectro.
                    MM = numel(idxThreads);
                    
                    % Povoa a tabela.
                    Table = table('Size', [MM, NN], 'VariableTypes', VariableTypes,  'VariableNames', VariableNames);        
                    ll = 0;
                    for jj = idxThreads
                        if ismember(specData(jj).MetaData.DataType, class.Constants.specDataTypes)
                            ll = ll+1;
        
                            for kk = 1:NN
                                Source = Children.Data.Columns{kk};
                                switch Source
                                    case 'ID'
                                        Table{ll,kk} = ll;
                                    otherwise
                                        Table(ll,kk) = {Fcn_Source(specData, jj, 1, reportInfo, Source)};
                                end
                            end
                        end
                    end
            end

        case 'External'
            [~, ~, fileExt] = fileparts(Source);
            switch lower(fileExt)
                case '.json'
                    Table = struct2table(jsondecode(fileread(Source)));
                case {'.xls', '.xlsx'}
                    Table = readtable(Source, "VariableNamingRule", "preserve", "Sheet", SheetID);
                otherwise
                    Table = readtable(Source, "VariableNamingRule", "preserve");
            end

            Table = Fcn_Table_PreProcess(Table, reportInfo, Children);
    end
end

%-------------------------------------------------------------------------%
function Table = Fcn_Table_PreProcess(Table, reportInfo, Children)
    if iscellstr(Children.Data.Columns) && strcmp(Children.Data.Columns{1}, 'ID') && ~ismember('ID', Table.Properties.VariableNames)
        Source = Children.Data.Source;
        IDReference = (1:height(Table))';

        switch Source
            case 'Channel'
                idxBand     = reportInfo.General.Parameters.Plot.idxBand;
                Table.ID(:) = string(idxBand) + "." + string(IDReference);

            case 'EmissionPerChannel'
                idxBand     = reportInfo.General.Parameters.Plot.idxBand;
                idxChannel  = reportInfo.General.Parameters.Plot.idxChannel;
                Table.ID(:) = string(idxBand) + "." + string(idxChannel) + "." + string(IDReference);

            case 'EmissionPerBand'
                idxBand     = reportInfo.General.Parameters.Plot.idxBand;
                Table.ID(:) = string(idxBand) + "." + string(IDReference);

            otherwise
                Table.ID(:) = IDReference;
        end    
        
        Table = movevars(Table, 'ID', 'Before', 1);
    end

    Table = Table(:, Children.Data.Columns);
    Table.Properties.VariableNames = {Children.Data.Settings.ColumnName};
end