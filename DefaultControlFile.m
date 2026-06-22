function Control = DefaultControlFile(datadir,fileExtensions,Controlpathname)
% Create all required fields
nFile = length(datadir);
VariableNames = {'instrument','filename','date','timezone','waterDepth',...
                 'bedElevation','xpos','ypos','zpos','Orientation'};
VariableTypes = {'string','string','datetime','string','double',...
                 'double','double','double','double','uint8'};
Control = table(Size=[nFile,length(VariableNames)],...
                   VariableNames=VariableNames,...
                   VariableTypes=VariableTypes);
if any(strcmp(fileExtensions,'hdr'))
    % implement code to automatically remove .dat files from
    % the CSVControl file if they're associated with a .hdr
    % file. For Vectrinos.
end
for i = 1:nFile
    % get instrument type
    switch fileExtensions{i}
        case 'Vu'
            instrument = 'ADV';
        case 'DAT'
            instrument = 'ECM';
        case 'mfprof'
            instrument = 'UDVP';
        case 'hdr'
            instrument = 'Vectrino';
        case 'mat'
            instrument = 'VectrinoII';
        otherwise % not a data file, e.g. a *.csv file
            continue
    end
    filename = datadir(i).name;
    % if VectrinoII, grab from Config
    if strcmp(instrument,'VectrinoII')
        load(fullfile(Controlpathname,filename),'Config')
        date = Config.date(1:end-4); % remove time zone indicator
        timezone_code = Config.date(end-2:end);
        switch timezone_code
            case 'EST'
                timezone = 'America/New_York';
            case 'EDT'
                timezone = 'America/New_York';
            otherwise
                sprintf('stop')
                warning('Time zone unknown. Setting to local')
                timezone = 'local'; % default to local time zone
        end
        date = datetime(date,'Format','uuuu-MM-dd HH:mm:SS.sss','TimeZone',timezone);
    % otherwise, set temporary value
    else
        timezone = 'local';
        date = datetime('now','Format','dd-MMM-uuuu HH:mm:ss.SSS','TimeZone',timezone);
    end
    waterDepth = 1;
    bedElevation = 0;
    xpos = 0;
    ypos = 0;
    % try to estimate zpos from the filename
    zpos = NumFromString(filename);
    Orientation = 1; % default orientation is down-looking and pos-x
    datarow = {instrument,filename,date,timezone,waterDepth,bedElevation,...
               xpos,ypos,zpos,Orientation};
    Control.date.TimeZone = timezone;
    Control(i,:) = datarow;
end
% sort the data rows in their natural order
[~,sortIndx] = natsort(Control.filename);
Control = Control(sortIndx,:);
Control.date.Format = 'dd-MMM-uuuu HH:mm:ss.SSS';
end