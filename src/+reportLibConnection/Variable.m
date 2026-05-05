classdef (Abstract) Variable

    % Relação de variáveis que podem ser manipuladas quando da execução de
    % um dos métodos desta classe estática. Importante, contudo, editar os
    % argumentos previstos por método em "reportLibConnection.Controller".

    % • reportInfo....: estrutura com os campos "App", "Version", "Path", 
    %   "Model" e "Function".

    % • dataOverview..: lista de estruturas com os campos "ID", "InfoSet" e
    %   "HTML". Em "InfoSet", armazena-se um handle para instância da classe 
    %   model.SpecData. 

    % • analyzedData..: instância da classe model.SpecData.
    
    % • tableSettings.: campo extraído do script .JSON que norteia a criação
    %   do relatório, o qual é uma estrutura com os campos "Origin", "Source", 
    %   "Columns", "Caption", "Settings", "Intro", "Error" e "LineBreak".

    methods (Static)
        %-----------------------------------------------------------------%
        function fieldValue = GeneralSettings(reportInfo, fieldName, varargin)
            projectData     = reportInfo.Project;
            context         = reportInfo.Context;
            ecdObj          = reportInfo.Object;
            generalSettings = reportInfo.Settings;

            switch fieldName
                case {'FILE', 'PLAYBACK', 'DRIVETEST', 'SIGNALANALYSIS', 'RFDATAHUB'}
                    fieldValue = jsonencode(generalSettings.context.(fieldName));

                case 'ReportTemplate'
                     fieldValue = jsonencode(struct('Name', reportInfo.Model.Name, 'DocumentType', reportInfo.Model.DocumentType, 'Version', reportInfo.Model.Version));

                otherwise
                    error('reportLibConnection:Variable:UnexpectedFieldName', 'Unexpected field name "%s"', fieldName)
            end
        end

        %-----------------------------------------------------------------%
        function fieldValue = GlobalProperty(specData, fieldName)
            switch fieldName
                case 'RelatedLocations'
                    fieldValue = textFormatGUI.cellstr2FriendlyListWithQuotes(unique(arrayfun(@(x) x.GPS.Location, specData, 'UniformOutput', false), 'stable'));

                otherwise
                    error('reportLibConnection:Variable:UnexpectedFieldName', 'Unexpected field name "%s"', fieldName)
            end
        end

        %-----------------------------------------------------------------%
        function fieldValue = ClassProperty(specData, fieldName)
            switch fieldName
                case 'Band'
                    fieldValue = sprintf('%.3f - %.3f MHz', specData.MetaData.FreqStart * 1e-6, specData.MetaData.FreqStop * 1e-6);

                case 'Description'
                    fieldValue = specData.RelatedFiles.Description{1};

                case 'BeginTime'
                    fieldValue = char(specData.Data{1}(1));

                case 'EndTime'
                    fieldValue = char(specData.Data{1}(end));

                case 'FreqStart'
                    fieldValue = specData.MetaData.FreqStart * 1e-6;
                
                case 'FreqStop'
                    fieldValue = specData.MetaData.FreqStop  * 1e-6;

                case 'GPS'
                    fieldValue = sprintf('%.6f, %.6f (%s)', specData.GPS.Latitude,  specData.GPS.Longitude, specData.GPS.Location);

                case 'Location'
                    fieldValue = specData.GPS.Location;

                case 'ObservationTime'
                    beginTime = specData.Data{1}(1);
                    endTime = specData.Data{1}(end);
                    numSweeps = numel(specData.Data{1});
                    revisitTime = mean(specData.RelatedFiles.RevisitTime);
                    fieldValue = sprintf('%s - %s<br>%d varreduras<br>%.1f segundos (tempo de revisita estimado)', beginTime, endTime, numSweeps, revisitTime);

                case 'Receiver'
                    fieldValue = specData.Receiver;
                
                case 'RelatedFiles'
                    fieldValue = strjoin(specData.RelatedFiles.File, ', ');

                case 'StepWidth'
                    fieldValue = ((specData.MetaData.FreqStop - specData.MetaData.FreqStart) / (specData.MetaData.DataPoints - 1)) * 1e-3;

                case 'Parameters'
                    fieldValue = {};
        
                    % Description
                    fieldValue{end+1} = sprintf('- Descrição: "%s"', specData.RelatedFiles.Description{1});
                    
                    % TraceMode+TraceIntegration+Detector
                    if ~isempty(specData.MetaData.TraceMode) 
                        traceIntegration = '';
                        if specData.MetaData.TraceIntegration ~= -1
                            traceIntegration = sprintf(' (Integração: %d amostras)', specData.MetaData.TraceIntegration);
                        end
        
                        if ~isempty(specData.MetaData.Detector)
                            operation = sprintf('- Operação: %s-%s%s', specData.MetaData.TraceMode, specData.MetaData.Detector, traceIntegration);
                        else
                            operation = sprintf('- Operação: %s%s', specData.MetaData.TraceMode, traceIntegration);
                        end
        
                    elseif ~isempty(specData.MetaData.Detector)
                        operation = sprintf('- Operação: %s', specData.MetaData.Detector);
                    end
                    fieldValue{end+1} = operation;
        
                    % DataPoints
                    fieldValue{end+1} = sprintf('- %d pontos por varredura', specData.MetaData.DataPoints);
        
                    % Resolution+VBW+StepWidth
                    rbw = specData.MetaData.Resolution / 1000;
                    vbw = specData.MetaData.VBW / 1000;
                    stepWidth = ((specData.MetaData.FreqStop - specData.MetaData.FreqStart) / (specData.MetaData.DataPoints - 1)) / 1000; % Hertz >> kHz
        
                    if (specData.MetaData.Resolution ~= -1) && (specData.MetaData.VBW ~= -1)
                        resolution = sprintf('- Resolução: %.3f kHz (RBW), %.3f kHz (VBW), %.3f kHz (Passo da varredura)', rbw, vbw, stepWidth);
                    elseif specData.MetaData.Resolution ~= -1
                        resolution = sprintf('- Resolução: %.3f kHz (RBW), %.3f kHz (Passo da varredura)', rbw, stepWidth);
                    elseif specData.MetaData.VBW ~= -1
                        resolution = sprintf('- Resolução: %.3f kHz (VBW), %.3f kHz (Passo da varredura)', vbw, stepWidth);
                    else
                        resolution = sprintf('- Resolução: %.3f kHz (Passo da varredura)', stepWidth);
                    end
                    fieldValue{end+1} = resolution;
        
                    % Antenna
                    fieldValue{end+1} = sprintf('- Antena: %s', jsonencode(specData.MetaData.Antenna));
        
                    % GPS
                    fieldValue{end+1} = sprintf('- GPS: %.6f, %.6f (%s)', specData.GPS.Latitude, specData.GPS.Longitude, specData.GPS.Location);
                    % Lista de arquivos
                    fieldValue{end+1} = sprintf('- Arquivo(s): %s', textFormatGUI.cellstr2FriendlyListWithQuotes(specData.RelatedFiles.File));
        
                    % Others
                    if ~isempty(specData.MetaData.Others)
                        fieldValue{end+1} = sprintf('- Outros metadados: %s', specData.MetaData.Others);
                    end
        
                    fieldValue = strjoin(fieldValue, '<br>');
                    
                case 'TagFlow'
                    flowIdx = reportInfo.General.Parameters.Plot.idxThread;
                    bandIdx = reportInfo.General.Parameters.Plot.idxBand;        
                    fieldValue = sprintf('FAIXA DE FREQUÊNCIA #%d: <b>%.3f - %.3f MHz</b>', bandIdx, specData.MetaData.FreqStart * 1e-6, specData.MetaData.FreqStop  * 1e-6);

                case 'TagChannel'
                    flowIdx = reportInfo.General.Parameters.Plot.idxThread;
                    bandIdx = reportInfo.General.Parameters.Plot.idxBand;
                    channelIdx = reportInfo.General.Parameters.Plot.idxChannel;
                    
                    channelTable = specData.UserData.reportChannelTable;
                    channelName  = extractBefore(channelTable.Name{channelIdx}, ' @');
                    if isempty(channelName)
                        channelName = channelTable.Name{channelIdx};
                    end
                    fieldValue = sprintf('CANAL #%d.%d: <b>%s @ %.3f MHz ⌂ %.1f kHz</b>', bandIdx, channelIdx, channelName, channelTable.FirstChannel(channelIdx), channelTable.ChannelBW(channelIdx) * 1000);

                case 'TagEmission'
                    flowIdx = reportInfo.General.Parameters.Plot.idxThread;
                    bandIdx = reportInfo.General.Parameters.Plot.idxBand;
                    emissionIdx = reportInfo.General.Parameters.Plot.idxEmission;        
                    fieldValue = sprintf('EMISSÃO #%d.%d: <b>%.3f MHz ⌂ %.1f kHz</b>', bandIdx, emissionIdx, specData.UserData.Emissions.Frequency(emissionIdx), specData.UserData.Emissions.BW_kHz(emissionIdx));

                otherwise
                    error('reportLibConnection:Variable:UnexpectedFieldName', 'Unexpected field name "%s"', fieldName)
            end
        end
    end
end