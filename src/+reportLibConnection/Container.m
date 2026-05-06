classdef (Abstract) Container

    methods (Static = true)
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
                        case 'Paragraph'
                            vararginArgument = [];

                            for kk = 1:numel(childNode.Data)
                                if ~isempty(childNode.Data(kk).Variable)
                                    childNode.Data(kk).Text = internalFcn_FillWords(reportInfo, dataOverview, analyzedData, childNode, kk);
                                end
                            end

                        case {'Image', 'Table'}
                            vararginArgument = eval(sprintf('internalFcn_%s(reportInfo, dataOverview, analyzedData, childNode.Data)', childType));

                        otherwise 
                            error('reportLibConnection:Container:UnexpectedContainerElement', 'Unexpected container element "%s"', childType)
                    end

                    htmlReport = [htmlReport, reportLib.sourceCode.htmlCreation(childNode, vararginArgument)];
                end
            end

            reportInfo.Function.var_IndexEmission = [];
        end


        %-----------------------------------------------------------------%
        function [reportInfo, htmlReport] = Channel(reportInfo, dataOverview, analyzedData, containerSettings, internalFcn_FillWords, internalFcn_Image, internalFcn_Table)
            htmlReport = '';
            % ...
        end
    end

end