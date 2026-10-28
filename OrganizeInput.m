function OrganizeInput(GUIControl,P)
% Control file for organizing instrument output into Data and Config arrays
% Called from MITT
% Calls Organize(Instrument)Data, where Instrument comes from Control.Instrument 
% and CalcChannelMesh

%%
% get control file
control_name = fullfile(GUIControl.Controlpathname,GUIControl.Controlfilename);
Control = ReadControlFile(control_name);

% number of files
nftot = height(Control);

% store output name and number of files
GUIControl.nftot = nftot;

if GUIControl.DefineGeometry
    % calculate mesh of sampling channel
    P.message.Value{end+1} = '    Runnning CalcChannelMesh';
    scroll(P.message,'bottom')
    pause(0.01)
    GUIControl = CalcChannelMesh(GUIControl,Control);
end
% save file
chk = dir(GUIControl.outname);
P.message.Value{end+1} = '    Saving GUIControl output file';
scroll(P.message,'bottom')
if isempty(chk)
    save(GUIControl.outname,'GUIControl')
else
    save(GUIControl.outname,'GUIControl','-append')
end

% for each file
for nf = 1:nftot
    % load data by sending Control structure to the instrument-appropriate Organize**Data file
    OrganizeData = str2func(['Organize',Control.instrument{nf},'Data']);
    P.message.Value{end+1} = ['    ',Control.filename{nf}];
    scroll(P.message,'bottom')
    pause(0.01)
    [Data,Config] = OrganizeData(GUIControl,Control(nf,:));
    % save control info to Config
    Config.Controlpathname = GUIControl.Controlpathname;
    Config.filename = Control.filename{nf};
    % save Config and Data to the output file
    oname = fullfile(GUIControl.odir,['MITT_',Config.filename]);
    % if this file has not been created
    if ~isfile(oname)
        % add empty variables faQC and goodCells to Config in
        % preparation for data quality control
        Config.faQC = struct;
        goodCells = true(Config.nCells,1);
        % add a goodCells vector for each component
        ncomptot = length(Config.comp);            
        for nc = 1:ncomptot
            Config.goodCells.(Config.comp{nc}) = goodCells;
        end
        % add logical values to keep track of what analyses have been completed
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