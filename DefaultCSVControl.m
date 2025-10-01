function CSVControl = DefaultCSVControl(datadir,fileExtensions,CSVControlpathname)
% Create all required fields
VariableNames = {'instrument','filename','date','waterDepth',...
                 'bedElevation','xpos','ypos','zpos','Orientation'};
VariableTypes = {'string','string','datetime','double',...
                 'double','double','double','double','double'};
CSVControl = table(Size=[0,length(VariableNames)],...
                   VariableNames=VariableNames,...
                   VariableTypes=VariableTypes);
if any(strcmp(fileExtensions,'hdr'))
    % implement code to automatically remove .dat files from
    % the CSVControl file if they're associated with a .hdr
    % file. For Vectrinos.
end
for i = 1:height(datadir)
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
    filename = datadir.name{i};
    % if VectrinoII, grab from Config
    if strcmp(instrument,'VectrinoII')
        load([CSVControlpathname,filesep,filename],'Config')
        date = Config.date(1:end-4); % remove time zone indicator
        date = datetime(date);
    % otherwise, set temporary value
    else
        date = datetime('now');
    end
    waterDepth = 1;
    bedElevation = 0;
    xpos = 0;
    ypos = 0;
    zpos = 0;
    Orientation = 1; % default orientation is down-looking and pos-x
    datarow = {instrument,filename,date,waterDepth,bedElevation,...
               xpos,ypos,zpos,Orientation};
    CSVControl = [CSVControl;datarow];
end
end