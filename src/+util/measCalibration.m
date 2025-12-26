function measCalibration(specData, rootFolder, OperationType, idxThread, idxCalibration, Name)

    FreqStart   = specData(idxThread).MetaData.FreqStart / 1e+6;
    FreqStop    = specData(idxThread).MetaData.FreqStop  / 1e+6;
    DataPoints  = specData(idxThread).MetaData.DataPoints;
    Calibration = specData(idxThread).UserData.measCalibration;

    switch OperationType
        case 'Add'
            kFactorTable = FactorTable(rootFolder, Name);

            % VALIDAÇÕES        
            if contains(Calibration.Name, Name)
                error('Curva de correção já incluída!')

            elseif strcmp(kFactorTable.Type, 'Antenna k-Factor')
                if any(contains(Calibration.Type, 'Antenna k-Factor'))
                    error('Já incluída uma curva de correção do tipo "Antenna k-Factor", a qual deve ser previamente excluída antes da inclusão de uma nova.')

                elseif ~ismember(specData(idxThread).MetaData.LevelUnit, {'dBm', 'dBµV'})
                    error('Para inclusão de uma curva de correção do tipo "Antenna k-Factor", a unidade de medida da faixa monitorada precisa ser "dBm" ou "dBµV".')
                end
            end

            if ~((kFactorTable.xData(1) <= FreqStart) && (kFactorTable.xData(end) >= FreqStop))
                error('A curva de correção não engloba a faixa monitorada.')
            end
        
            % UNIDADES INICIAL E FINAL (PÓS-PROCESSAMENTO)
            switch kFactorTable.Type
                case 'Antenna k-Factor'  
                    oldLevelUnit = specData(idxThread).MetaData.LevelUnit;
                    newLevelUnit = 'dBµV/m';
                    specData(idxThread).MetaData.LevelUnit = newLevelUnit;

                case 'Calibration'
                    if isempty(Calibration)
                        oldLevelUnit = specData(idxThread).MetaData.LevelUnit;
                    else
                        oldLevelUnit = Calibration.oldUnitLevel{1};
                    end
                    newLevelUnit = oldLevelUnit;
            end
            kFactorArray = FactorArray(kFactorTable, FreqStart, FreqStop, DataPoints, oldLevelUnit);
            
            specData(idxThread).Data{2} = specData(idxThread).Data{2} + kFactorArray;
            specData(idxThread).Data{3} = specData(idxThread).Data{3} + kFactorArray;

            specData(idxThread).UserData.measCalibration(end+1,:) = {kFactorTable.Name, kFactorTable.Type, oldLevelUnit, newLevelUnit};
            specData(idxThread).UserData.measCalibration          = sortrows(specData(idxThread).UserData.measCalibration, 'Type', 'descend');

        case 'Remove'
            oldLevelUnit = Calibration.oldUnitLevel{1};

            for ii = numel(idxCalibration):-1:1
                kFactorTable = FactorTable(rootFolder, Name{ii});                
                kFactorArray = FactorArray(kFactorTable, FreqStart, FreqStop, DataPoints, oldLevelUnit);

                if strcmp(kFactorTable.Type, 'Antenna k-Factor')
                    specData(idxThread).MetaData.LevelUnit = oldLevelUnit;
                end
                
                specData(idxThread).Data{2} = specData(idxThread).Data{2} - kFactorArray;
                specData(idxThread).Data{3} = specData(idxThread).Data{3} - kFactorArray;
                
                specData(idxThread).UserData.measCalibration(idxCalibration(ii),:) = [];
            end
    end
end


%-------------------------------------------------------------------------%
function kFactorTable = FactorTable(rootFolder, Name)
    [projectFolder, ...
     programDataFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
    try
        kFactorTable = jsondecode(fileread(fullfile(programDataFolder, 'Calibration.json')));
    catch
        kFactorTable = jsondecode(fileread(fullfile(projectFolder,     'Calibration.json')));
    end
    
    kFactorTable(~strcmp({kFactorTable.Name}, Name)) = [];
end


%-------------------------------------------------------------------------%
function kFactorArray = FactorArray(kFactor, FreqStart, FreqStop, DataPoints, LevelUnit)
    kFactorArray = interp1(kFactor.xData, kFactor.yData, linspace(FreqStart, FreqStop, DataPoints)', 'linear');
    if strcmp(kFactor.Type, 'Antenna k-Factor') && strcmp(LevelUnit, 'dBm')
        kFactorArray = kFactorArray + 107;
    end
end