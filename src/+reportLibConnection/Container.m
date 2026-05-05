classdef (Abstract) Container

    methods (Static = true)
        %-----------------------------------------------------------------%
        function htmlReport = Emissions(reportInfo, dataOverview, analyzedData, containerSettings, internalFcn_Image, internalFcn_Table)
            bandObj = model.Band('appAnalise:REPORT:EMISSION', reportInfo.App);

            specData = analyzedData.InfoSet;
            emissions = specData.UserData.Emissions;

            htmlReport = '';
            for ii = 1:height(emissions)
                if isempty(emissions.AuxAppData(ii).DriveTest)
                    continue
                end

                updateSpectrumInfo(bandObj, specData, ii);

                for jj = 1:numel(containerSettings.Data.Component)
                    childNode = containerSettings.Data.Component(jj);
                    childType = containerSettings.Data.Component(jj).Type;

                    switch childType
                        case 'Paragraph'
                            vararginArgument = [];

                        case {'Image', 'Table'}
                            vararginArgument = eval(sprintf('internalFcn_%s(reportInfo, dataOverview, analyzedData, childNode.Data)', childType));

                        otherwise 
                            error('reportLibConnection:Container:UnexpectedContainerElement', 'Unexpected container element "%s"', childType)
                    end

                    htmlReport = [htmlReport, reportLib.sourceCode.Separato, reportLib.sourceCode.htmlCreation(childNode, vararginArgument)];
                end
            end

        end
    end

end