function OrganizeInput(GUIControl)
% Control file for organizing instrument output into Data and Config arrays
% Called from MITT
% Calls Organize(Instrument)Data, where Instrument comes from Control.Instrument 
% and CalcChannelMesh

%%
% get control file
CSVControl = ConvCSV2Struct([GUIControl.CSVControlpathname,GUIControl.CSVControlfilename],0);
% number of files
nftot = length(CSVControl);

% store output name and number of files
GUIControl.nftot = nftot;

if GUIControl.DefineGeometry
    % calculate mesh of sampling channel
    GUIControl = CalcChannelMesh(GUIControl,CSVControl);
end

% save file
chk = dir(GUIControl.outname);
if isempty(chk)
    save(GUIControl.outname,'GUIControl')
else
    save(GUIControl.outname,'GUIControl','-append')
end

% for each file
for nf = 1:nftot
    % load data by sending Control structure to the instrument-appropriate Organize**Data file
    OrganizeData = str2func(['Organize',CSVControl(nf).instrument,'Data']);
    [Data,Config] = OrganizeData(GUIControl,CSVControl(nf));

    Config.CSVControlpathname = GUIControl.CSVControlpathname;
    % filename
    Config.filename = CSVControl(nf).filename;
    % save Config and Data to the output file
    oname = [GUIControl.odir,filesep,'MITT_',Config.filename,'.mat'];
    % chk for any output files
    chk = dir(oname);
    % if this file has not been created
    if isempty(chk)
        % add empty variables faQC and goodCells to Config in
        % preparation for data quality control
        Config.faQC = struct;
        goodCells = true(Config.nCells,1);
        % add a goodCells vector for each component
        ncomptot = length(Config.comp);            
        for nc = 1:ncomptot
            Config.goodCells.(Config.comp{nc}) = goodCells;
        end
        % add variable nums to keep track of what analyses have been completed
        Config.Despiked = false; %
        Config.Filtered = false; %

        save(oname,'Config','Data');
    % else if this file exists, then just worry about Config and
    % transfer information about quality analyses
    else
        Ctemp = load(oname,'Config');
        Config.faQC = Ctemp.Config.faQC';
        Config.goodCells = Ctemp.Config.goodCells;
        Config.Despiked = Ctemp.Config.Despiked;
        Config.Filtered = Ctemp.Config.Filtered;
        
        save(oname,'Config','-append');
    end       
end

end