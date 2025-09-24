function ClassifyArrayAuto(GUIControl)
% automatically identifies bad cells in data array
% Called by MITT
% Calls CalcGoodCells

%% directories

% for each file in MITTdir
nsFtot = length(GUIControl.MITTdir.name);
for nsF = 1:nsFtot
    % get input file name
    inname = [GUIControl.odir,filesep,GUIControl.MITTdir.name{nsF}];
    % load Config and Data
    load(inname,'Config','Data');

    GUIControl.Xvar = GUIControl.nxvar;

    % get y data
    Config = CalcGoodCells(Config,Data,GUIControl);

    if GUIControl.plotQCauto
        PlotQCTable(Config)
    end

    % save faQC to Config
    Config.faQC = GUIControl.faQC;
    % append updated Config to file
    save([GUIControl.odir,filesep,GUIControl.MITTdir.name{nsF}],'Config','-append');
end
        
end

