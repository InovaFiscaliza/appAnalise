classdef specData < handle

    % Objeto legado, usado até o appAnalise v. 1.85. Migrado p/ model.SpecDataBase 
    % (SupportPackage) e model.SpecData, mas mantido no projeto p/ garantir 
    % compatibilidade com a versão atual do appAnalise.

    properties
        %-----------------------------------------------------------------%
        Receiver
        MetaData     = model.SpecDataBase.templateMetaData()
        Data
        GPS
        RelatedFiles = table('Size', [0,10],                                                                                                  ...
                             'VariableTypes', {'cell', 'cell', 'double', 'cell', 'datetime', 'datetime', 'double', 'double', 'cell', 'cell'}, ...
                             'VariableNames', {'File', 'Task', 'ID', 'Description', 'BeginTime', 'EndTime', 'nSweeps', 'RevisitTime', 'GPS', 'uuid'})
        UserData     = class.userData.empty
        FileMap
        Enable
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        callingApp
        sortType
    end


    methods
        %-----------------------------------------------------------------%
        function varargout = compatibilitityAdapter(obj, operationType, varargin)
            arguments
                obj 
                operationType char {mustBeMember(operationType, {'MetaData', 'SpecData', 'ProjectInfo'})}
            end

            arguments (Repeating)
                varargin
            end

            appEngine.util.disableWarnings()

            switch operationType 
                case {'MetaData', 'SpecData'}
                    specData   = model.SpecData.empty;
                    
                    appName    = class.Constants.appName;
                    channelObj = class.ChannelLib(appName);

                    for ii = 1:numel(obj)
                        specData(ii).Receiver     = obj(ii).Receiver;
                        specData(ii).MetaData     = obj(ii).MetaData;
                        specData(ii).RelatedFiles = obj(ii).RelatedFiles;
                        specData(ii).Enable       = obj(ii).Enable;

                        compatibilitityGPS(obj(ii))
                        specData(ii).GPS          = obj(ii).GPS;

                        if strcmp(operationType, 'SpecData')
                            specData(ii).Data     = obj(ii).Data;
                            compatibilityUserData(obj(ii), specData(ii), channelObj, varargin{:});
                        end
                    end
                    varargout = {specData};

                case 'ProjectInfo'
                    prjInfo = varargin{1};
                    varargout = {prjInfo};
            end
        end

        %-----------------------------------------------------------------%
        function compatibilitityGPS(obj)
            for ii = 1:numel(obj)
                obj(ii).GPS.Status        = double(obj(ii).GPS.Status);
                obj(ii).GPS.Latitude      = round(double(obj(ii).GPS.Latitude),      6);
                obj(ii).GPS.Longitude     = round(double(obj(ii).GPS.Longitude),     6);
                obj(ii).GPS.Latitude_std  = round(double(obj(ii).GPS.Latitude_std),  6);
                obj(ii).GPS.Longitude_std = round(double(obj(ii).GPS.Longitude_std), 6);
            end
        end

        %-----------------------------------------------------------------%
        function compatibilityUserData(obj, specData, channelObj, varargin)
            exceptionList = [];
            if ~isempty(varargin) && isfield(varargin{1}, 'exceptionList')
                global RFDataHub
                exceptionList = varargin{1}.exceptionList;
            end

            for ii = 1:numel(obj)
                if isempty(obj(ii).UserData)
                    specData(ii).UserData(1).AntennaHeight    = AntennaHeight(specData, ii, -1, 'initialValue');
                    specData(ii).UserData.channelLibIndex     = FindRelatedBands(channelObj, specData(ii));
                    FindPeaks(specData, ii, channelObj)

                else
                    specData(ii).UserData(1).customPlayback   = obj(ii).UserData.customPlayback;                
                    
                    specData(ii).UserData.occMethod           = obj(ii).UserData.occMethod;
                    specData(ii).UserData.occCache            = obj(ii).UserData.occCache;
                    checkIfOccupancyPerBinExist(specData(ii))
                    
                    specData(ii).UserData.channelLibIndex     = obj(ii).UserData.channelLibIndex;
                    specData(ii).UserData.channelManual       = obj(ii).UserData.channelManual;
                    specData(ii).UserData.bandLimitsStatus    = obj(ii).UserData.bandLimitsStatus;
                    specData(ii).UserData.bandLimitsTable     = obj(ii).UserData.bandLimitsTable;
                    specData(ii).UserData.measCalibration     = obj(ii).UserData.measCalibration;
                    
                    if obj(ii).UserData.reportFlag
                        reportDetection      = obj(ii).UserData.reportDetection;
                        reportDetection.Parameters = structUtil.renameFieldNames(reportDetection.Parameters, dictionary(["Distance", "BW"], ["Distance_kHz", "BW_kHz"]));
                        
                        reportClassification = obj(ii).UserData.reportClassification;
                        reportOccupancy      = obj(ii).UserData.reportOCC;
                    else
                        reportDetection      = model.UserData.getFieldTemplate('DefaultAlgorithm: Detection');
                        reportClassification = model.UserData.getFieldTemplate('DefaultAlgorithm: Classification');
                        reportOccupancy      = model.UserData.getFieldTemplate('DefaultAlgorithm: Occupancy');
                    end
                    
                    specData(ii).UserData.reportFlag          = obj(ii).UserData.reportFlag;
                    specData(ii).UserData.reportAlgorithms    = struct('Detection', reportDetection, 'Classification', reportClassification, 'Occupancy', reportOccupancy);
                    specData(ii).UserData.reportExternalFiles = obj(ii).UserData.reportExternalFiles;                
                    
                    specData(ii).UserData.AntennaHeight       = AntennaHeight(specData, ii);
    
                    for jj = 1:height(obj(ii).UserData.Emissions)
                        idxFreq     = obj(ii).UserData.Emissions.Index(jj);
                        FreqCenter  = obj(ii).UserData.Emissions.Frequency(jj);
                        BandWidth   = obj(ii).UserData.Emissions.BW(jj);                    
                        Detection   = obj(ii).UserData.Emissions.Detection(jj);
                        Description = {obj(ii).UserData.Emissions.UserData(jj).Description};
    
                        update(specData(ii), 'UserData:Emissions', 'Add', idxFreq, FreqCenter, BandWidth, Detection, Description, channelObj)
                        
                        isTruncated = obj(ii).UserData.Emissions.isTruncated(jj);
                        if ~isTruncated
                            update(specData(ii), 'UserData:Emissions', 'Edit', 'IsTruncated', jj, isTruncated, channelObj)
                        end
    
                        if ~isempty(exceptionList)
                            bandTag      = Tag(specData, ii);
                            idxException = find(strcmp(exceptionList.Tag, bandTag) & abs(exceptionList.Frequency - FreqCenter) < 1e-5, 1);
    
                            if ~isempty(idxException)
                                if exceptionList.Station(idxException) ~= -1
                                    receiverLatitude  = specData(ii).GPS.Latitude;
                                    receiverLongitude = specData(ii).GPS.Longitude;

                                    % Se o registro não compor mais a base do RFDataHub, 
                                    % a edição do usuário será desfeita.
                                    try
                                        stationInfo = model.RFDataHub.query(RFDataHub, string(exceptionList.Station(idxException)), receiverLatitude, receiverLongitude);
        
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Service       = stationInfo.Service;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Station       = stationInfo.Station;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Latitude      = stationInfo.Latitude;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Longitude     = stationInfo.Longitude;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.AntennaHeight = stationInfo.AntennaHeight;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Description   = stationInfo.Description;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Details       = stationInfo.Details;
                                        specData(ii).UserData.Emissions.Classification(jj).userModified.Distance      = stationInfo.Distance;
                                    catch
                                    end
                                end
    
                                specData(ii).UserData.Emissions.Classification(jj).userModified.Regulatory    = exceptionList.Regulatory{idxException};
                                specData(ii).UserData.Emissions.Classification(jj).userModified.EmissionType  = exceptionList.Type{idxException};
                                specData(ii).UserData.Emissions.Classification(jj).userModified.Irregular     = exceptionList.Irregular{idxException};
                                specData(ii).UserData.Emissions.Classification(jj).userModified.RiskLevel     = exceptionList.RiskLevel{idxException};
                            end
                        end
    
                        driveTest   = obj(ii).UserData.Emissions.UserData(jj).DriveTest;
                        if ~isempty(driveTest)
                            specData(ii).UserData.Emissions.auxAppData(jj).DriveTest = driveTest;
                        end
                    end
                end
            end
        end
    end
end