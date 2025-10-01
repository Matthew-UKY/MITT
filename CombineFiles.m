% Combine large output files from the Vectrino Profiler
% Order determined from the timeStamp variable
function [Data,Config] = CombineFiles(AllStruct)
    nFiles = length(AllStruct);
    timeStamp = zeros(nFiles,1);
    for i = 1:nFiles
        timeStamp(i) = AllStruct(i).Data.Profiles_TimeStamp(1);
    end
    [~,sortIndx] = sort(timeStamp);
    % Create useful variables
    prefix = 'Profiles_';
    HostTime = strcat(prefix,'HostTime');
    HostTimeMatlab = strcat(prefix,'HostTimeMatlab');
    comp = strcat(prefix,{'VelX','VelY','VelZ1','VelZ2'});
    qual = {'Cor';'Amp';'SNR';'DataQuality'};
    beam = {'Beam1','Beam2','Beam3','Beam4'};
    deets = cell(4);
    for i = 1:length(beam)
        deets(:,i) = strcat(prefix,qual,beam{i});
    end
    TimeStamp = strcat(prefix,'TimeStamp');
    Status = strcat(prefix,'Status');
    SpeedOfSound = strcat(prefix,'SpeedOfSound');
    Temperature = strcat(prefix,'Temperature');
    AveragedPingPairs = strcat(prefix,'AveragedPingPairs');

    prefix = 'BottomCheck_';
    BcHostTime = strcat(prefix,'HostTime');
    BcHostTimeMatlab = strcat(prefix,'HostTimeMatlab');
    CenterBeamAmp = strcat(prefix,'CenterBeamAmp');
    CenterBeamCurveFit = strcat(prefix,'CenterBeamCurveFit');
    CenterBeamBottomPeak = strcat(prefix,'CenterBeamBottomPeak');
    BcTimeStamp = strcat(prefix,'TimeStamp');
    BottomDistance = strcat(prefix,'BottomDistance');
    BcStatus = strcat(prefix,'Status');
    
    nComps = length(comp);

    % Combine the files
    Data = AllStruct(sortIndx(1)).Data;
    Config = AllStruct(sortIndx(1)).Config;

    for nf = 2:nFiles
        tempData = AllStruct(sortIndx(nf)).Data;
        % combine Profiles data
        Data.(HostTime) = [Data.(HostTime),tempData.(HostTime)];
        Data.(HostTimeMatlab) = [Data.(HostTimeMatlab),tempData.(HostTimeMatlab)];
        for nc = 1:nComps
            Data.(comp{nc}) = [Data.(comp{nc}) ; tempData.(comp{nc})];
            for nd = 1:length(deets)
                Data.(deets{nd,nc}) = [Data.(deets{nd,nc}) ; tempData.(deets{nd,nc})];
            end
        end
        Data.(TimeStamp) = [Data.(TimeStamp) ; tempData.(TimeStamp)];
        Data.(Status) = [Data.(Status) ; tempData.(Status)];
        Data.(SpeedOfSound) = [Data.(SpeedOfSound) ; tempData.(SpeedOfSound)];
        Data.(Temperature) = [Data.(Temperature) ; tempData.(Temperature)];
        Data.(AveragedPingPairs) = [Data.(AveragedPingPairs) ; tempData.(AveragedPingPairs)];
        % Combine BottomCheck data
        Data.(BcHostTime) = [Data.(BcHostTime),tempData.(BcHostTime)];
        Data.(BcHostTimeMatlab) = [Data.(BcHostTimeMatlab),tempData.(BcHostTimeMatlab)];
        Data.(CenterBeamAmp) = [Data.(CenterBeamAmp) ; tempData.(CenterBeamAmp)];
        Data.(CenterBeamCurveFit) = [Data.(CenterBeamCurveFit) ; tempData.(CenterBeamCurveFit)];
        Data.(CenterBeamBottomPeak) = [Data.(CenterBeamBottomPeak) ; tempData.(CenterBeamBottomPeak)];
        Data.(BcTimeStamp) = [Data.(BcTimeStamp) ; tempData.(BcTimeStamp)];
        Data.(BottomDistance) = [Data.(BottomDistance) ; tempData.(BottomDistance)];
        Data.(BcStatus) = [Data.(BcStatus) ; tempData.(BcStatus)];
    end
end
