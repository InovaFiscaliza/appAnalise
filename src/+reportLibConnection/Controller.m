function Controller(app, operationType)

    arguments
        app
        operationType char {mustBeMember(operationType, {'Report'})}
    end

    d = uiprogressdlg(app.UIFigure, 'Indeterminate', 'on', 'Interpreter', 'html', 'Cancelable', 'on', 'CancelText', 'Cancelar', 'Message', 'Em andamento...');

    try    
        reportTemplateIndex = find(strcmp(app.report_ModelName.Items, app.report_ModelName.Value), 1) - 1;
        [idxThreads, reportInfo]   = reportLibConnection.GeneralInfo(app, operationType, reportTemplateIndex);

        % Verifica se o template e relatório selecionado demanda
        % arquivos externos (imagens e tabelas).
        if contains(reportInfo.Model.Script, '"Origin": "External"')
            msg = '<p style="font-size:12px; text-align: justify;">Confirma que foram relacionados os arquivos externos ao appAnalise estabelecidos no modelo?</p>';
            selection = uiconfirm(app.UIFigure, msg, '', 'Options', {'OK', 'Cancelar'}, 'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question', 'Interpreter', 'html');
            
            if selection == "Cancelar"
                return
            end
        end

        % Identifica emissões, caso não se trate da versão definita e esteja 
        % habilitado.
        if app.report_Version.Value ~= "Definitiva"
            for ii = idxThreads
                checkIfOccupancyPerBinExist(app.specData(ii))

                ManualMode = app.specData(ii).UserData.reportAlgorithms.Detection.ManualMode;
                if ~ManualMode
                    Attributes = app.specData(ii).UserData.reportAlgorithms.Detection.Parameters;
                    Attributes.Algorithm = app.specData(ii).UserData.reportAlgorithms.Detection.Algorithm;

                    util.Detection.Controller(app.specData, ii, Attributes, true, app.channelObj);
                end
            end
        end

        % Cria relatório...
        htmlReport = reportLibConnection.ReportGenerator(app, idxThreads, reportInfo, d);

        switch app.report_Version.Value
            case 'Definitiva'
                [baseFullFileName, baseFileName] = appUtil.DefaultFileName(app.General.fileFolder.tempPath, 'Report', app.report_Issue.Value);
                HTMLDocFullPath = [baseFullFileName '.html'];
                fileID = fopen(HTMLDocFullPath, 'w', 'native', 'ISO-8859-1');

            case 'Preliminar'
                [baseFullFileName, baseFileName] = appUtil.DefaultFileName(app.General.fileFolder.tempPath, '~Report', app.report_Issue.Value);
                HTMLDocFullPath = [baseFullFileName '.html'];
                fileID = fopen(HTMLDocFullPath, 'w');
        end
        
        fprintf(fileID, '%s', htmlReport);
        fclose(fileID);

        switch app.report_Version.Value
            case 'Definitiva'
                JSONFile = [baseFullFileName '.json'];
                MATFile  = [baseFullFileName '.mat'];
                ZIPFile  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', {'*.zip', 'appAnalise (*.zip)'}, fullfile(app.General.fileFolder.userPath, [baseFileName '.zip']));
                if isempty(ZIPFile)
                    return
                end
                
                [ReportProject, emissionFiscalizaTable] = reportLibConnection.table.fiscalizaStructureFields(app, idxThreads, reportInfo, 'REPORT: JSONFile');

                save(MATFile, 'ReportProject', '-mat', '-v7.3')
                writematrix(emissionFiscalizaTable, JSONFile, "FileType", "text", "QuoteStrings", "none", "Encoding", "UTF-8", "WriteMode", "overwrite")
                zip(ZIPFile, {HTMLDocFullPath, JSONFile, MATFile})
                
                app.projectData.generatedFiles.lastHTMLDocFullPath = HTMLDocFullPath;
                app.projectData.generatedFiles.lastTableFullPath   = JSONFile;
                app.projectData.generatedFiles.lastMATFullPath     = MATFile;
                app.projectData.generatedFiles.lastZIPFullPath     = ZIPFile;

            case 'Preliminar'
                web(HTMLDocFullPath, '-new')
        end
        
    catch ME
        appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
    end

    delete(d)
end