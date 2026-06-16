classdef (Abstract) Container

    methods (Static = true)
        %-----------------------------------------------------------------%
        function [reportInfo, htmlReport] = DriveTestRoute(reportInfo, dataOverview, ~, containerSettings, internalFcn_FillWords, internalFcn_Image, internalFcn_Table)
            gpsSummary = struct('lat', {}, 'lng', {});
            htmlReport = '';

            for ii = 1:numel(dataOverview)
                analyzedData = dataOverview(ii);
                specData = analyzedData.InfoSet;

                monitoringType = gpsLib.classifyMonitoringType(specData.GPS);
                if monitoringType ~= "mobile" || (~isempty(gpsSummary) && any(deg2km(distance([gpsSummary.lat], [gpsSummary.lng], specData.GPS.Latitude, specData.GPS.Longitude)) < .1))
                    continue
                end
                
                gpsSummary(end+1) = struct('lat', specData.GPS.Latitude, 'lng', specData.GPS.Longitude);
                
                htmlReport = [htmlReport, reportLib.sourceCode.Separator];
                
                for jj = 1:numel(containerSettings.Data.Component)
                    childNode = containerSettings.Data.Component(jj);
                    childType = containerSettings.Data.Component(jj).Type;

                    switch childType
                        case {'ItemN2', 'Paragraph'}
                            vararginArgument = [];

                            for kk = 1:numel(childNode.Data)
                                if ~isempty(childNode.Data(kk).Variable)
                                    childNode.Data(kk).Text = internalFcn_FillWords(reportInfo, dataOverview, analyzedData, childNode, kk);
                                end
                            end

                        case 'Image'
                            vararginArgument = eval(sprintf('internalFcn_%s(reportInfo, dataOverview, analyzedData, childNode.Data, false)', childType));

                        otherwise 
                            error('reportLibConnection:Container:UnexpectedContainerElement', 'Unexpected container element "%s"', childType)
                    end

                    htmlReport = [htmlReport, reportLib.sourceCode.htmlCreation(childNode, vararginArgument)];
                end
            end
        end


        %-----------------------------------------------------------------%
        function [reportInfo, htmlReport] = Emissions(reportInfo, dataOverview, analyzedData, containerSettings, internalFcn_FillWords, internalFcn_Image, internalFcn_Table)
            bandObj = model.Band('appAnalise:REPORT:EMISSION', reportInfo.App);

            specData = analyzedData.InfoSet;
            emissions = specData.UserData.Emissions;

            htmlReport = '';
            for ii = 1:height(emissions)
                reportInfo.Function.var_IndexEmission = ii;

                if isempty(emissions.AuxAppData(ii).DriveTest) || ~emissions.AuxAppData(ii).DriveTest.ReportInclude
                    continue
                end

                updateSpectrumInfo(bandObj, specData, ii);
                htmlReport = [htmlReport, reportLib.sourceCode.Separator];

                for jj = 1:numel(containerSettings.Data.Component)
                    childNode = containerSettings.Data.Component(jj);
                    childType = containerSettings.Data.Component(jj).Type;

                    switch childType
                        case {'ItemN2', 'Paragraph'}
                            vararginArgument = [];

                            for kk = 1:numel(childNode.Data)
                                if ~isempty(childNode.Data(kk).Variable)
                                    childNode.Data(kk).Text = internalFcn_FillWords(reportInfo, dataOverview, analyzedData, childNode, kk);
                                end
                            end

                        case 'Image'
                            vararginArgument = internalFcn_Image(reportInfo, dataOverview, analyzedData, childNode.Data, false);

                        case 'Table'
                            try
                                vararginArgument = internalFcn_Table(reportInfo, dataOverview, analyzedData, childNode.Data, false);
                                if isempty(vararginArgument)
                                    continue
                                end
                            catch
                                continue
                            end

                        otherwise 
                            error('reportLibConnection:Container:UnexpectedContainerElement', 'Unexpected container element "%s"', childType)
                    end

                    htmlReport = [htmlReport, reportLib.sourceCode.htmlCreation(childNode, vararginArgument)];
                end
            end

            reportInfo.Function.var_IndexEmission = [];
        end


        %-----------------------------------------------------------------%
        function [reportInfo, htmlReport] = Channels(reportInfo, dataOverview, analyzedData, containerSettings, internalFcn_FillWords, internalFcn_Image, internalFcn_Table)
            bandObj = model.Band('appAnalise:REPORT:CHANNEL', reportInfo.App);

            specData = analyzedData.InfoSet;
            channels = specData.UserData.ReportChannels;
            if isempty(channels)
                channels = ChannelTable2Plot(bandObj.mainApp.channelObj, specData);
                specData.UserData.ReportChannels = channels;
            end

            htmlReport = '';
            for ii = 1:height(channels)
                reportInfo.Function.var_IndexChannel = ii;

                updateSpectrumInfo(bandObj, specData, ii);
                htmlReport = [htmlReport, reportLib.sourceCode.Separator];

                for jj = 1:numel(containerSettings.Data.Component)
                    childNode = containerSettings.Data.Component(jj);
                    childType = containerSettings.Data.Component(jj).Type;

                    switch childType
                        case {'ItemN2', 'Paragraph'}
                            vararginArgument = [];

                            for kk = 1:numel(childNode.Data)
                                if ~isempty(childNode.Data(kk).Variable)
                                    childNode.Data(kk).Text = internalFcn_FillWords(reportInfo, dataOverview, analyzedData, childNode, kk);
                                end
                            end

                        case 'Image'
                            vararginArgument = internalFcn_Image(reportInfo, dataOverview, analyzedData, childNode.Data, false);

                        case 'Table'
                            try
                                vararginArgument = internalFcn_Table(reportInfo, dataOverview, analyzedData, childNode.Data, false);
                                if isempty(vararginArgument)
                                    continue
                                end
                            catch
                                continue
                            end

                        otherwise 
                            error('reportLibConnection:Container:UnexpectedContainerElement', 'Unexpected container element "%s"', childType)
                    end

                    htmlReport = [htmlReport, reportLib.sourceCode.htmlCreation(childNode, vararginArgument)];
                end
            end

            reportInfo.Function.var_IndexChannel = [];
        end
    end

end