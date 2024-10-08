function peaksTable = PreviewGenerator(app, idx, reportInfo)

    SpecInfo   = report.TimeStampFilter(app, idx, reportInfo.TimeStamp);
    peaksTable = [];

    for ii = 1:numel(SpecInfo)
        Peaks = report.ReportGenerator_Peaks(app, SpecInfo, ii, reportInfo);

        if ~isempty(Peaks)
            if isempty(peaksTable); peaksTable = Peaks;
            else;                   peaksTable = [peaksTable; Peaks];
            end
        end
    end
end