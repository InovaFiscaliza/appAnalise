function measCalibration(specData, refCalibrationData)
    arguments
        specData (1, 1) model.SpecData
        refCalibrationData (1, 1) struct
    end

    freqStart = specData.MetaData.FreqStart / 1e+6;
    freqStop = specData.MetaData.FreqStop  / 1e+6;
    dataPoints = specData.MetaData.DataPoints;
    calibrationTable = specData.UserData.CalibrationCurve;

    % VALIDAÇÕES        
    if contains(calibrationTable.Name, refCalibrationData.Name)
        error('Curva de correção já incluída!')

    elseif strcmp(refCalibrationData.Type, 'Antenna k-Factor')
        if any(contains(calibrationTable.Type, 'Antenna k-Factor'))
            error('Já incluída uma curva de correção do tipo "Antenna k-Factor", a qual deve ser previamente excluída antes da inclusão de uma nova.')

        elseif ~ismember(specData.MetaData.LevelUnit, {'dBm', 'dBµV'})
            error('Para inclusão de uma curva de correção do tipo "Antenna k-Factor", a unidade de medida da faixa monitorada precisa ser "dBm" ou "dBµV".')
        end
    end

    if ~((refCalibrationData.xData(1) <= freqStart) && (refCalibrationData.xData(end) >= freqStop))
        error('A curva de correção não engloba a faixa monitorada.')
    end

    % UNIDADES INICIAL E FINAL (PÓS-PROCESSAMENTO)
    switch kFactorTable.Type
        case 'Antenna k-Factor'  
            previousLevelUnit = specData.MetaData.LevelUnit;
            currentLevelUnit = 'dBµV/m';
            update(specData, "MetaData:LevelUnit", currentLevelUnit)

        case 'Calibration'
            if isempty(calibrationTable)
                previousLevelUnit = specData.MetaData.LevelUnit;
            else
                previousLevelUnit = calibrationTable.oldUnitLevel{1};
            end
            currentLevelUnit = previousLevelUnit;
    end
    kFactorArray = computeCalibrationCurve(refCalibrationData, freqStart, freqStop, dataPoints, previousLevelUnit);
    
    specData.Data{2} = specData.Data{2} + kFactorArray;
    specData.Data{3} = specData.Data{3} + kFactorArray;

    specData.UserData.CalibrationCurve(end+1, :) = {refCalibrationData.Name, refCalibrationData.Type, previousLevelUnit, currentLevelUnit};
    specData.UserData.CalibrationCurve = sortrows(specData.UserData.CalibrationCurve, 'Type', 'descend');
end


%-------------------------------------------------------------------------%
function calibrationCurve = computeCalibrationCurve(refCalibrationData, freqStart, freqStop, dataPoints, levelUnit)
    calibrationCurve = interp1(refCalibrationData.xData, refCalibrationData.yData, linspace(freqStart, freqStop, dataPoints)', 'linear');
    
    if strcmp(refCalibrationData.Type, 'Antenna k-Factor') && strcmp(levelUnit, 'dBm')
        calibrationCurve = calibrationCurve + 107;
    end
end