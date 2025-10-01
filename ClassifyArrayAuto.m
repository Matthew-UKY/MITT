function ClassifyArrayAuto(GUIControl,P)
% automatically identifies bad cells in data array
% Called by MITT
% Calls CalcGoodCells

% for each file in MITTdir
nFiles = length(GUIControl.MITTdir.name);
for i = 1:nFiles
    % get input file name
    inname = [GUIControl.odir,filesep,GUIControl.MITTdir.name{i}];
    % load Config (not Data yet, for runtime reasons)
    load(inname,'Config');

    % get x data
    GUIControl.Xvar = GUIControl.nxvar;
    P.message.Value{end+1} = ['    ',GUIControl.MITTdir.name{i}];
    scroll(P.message,'bottom')
    pause(0.01)

    faQCname = fieldnames(Config.faQC);
    % if it is empty, no filter has yet been run, or if you want to reset
    if isempty(faQCname)||GUIControl.resetFilter
        load(inname,'Data')
        Config = CalcGoodCells(Config,Data,GUIControl);
        % save faQC to Config
        Config.faQC = GUIControl.faQC;
        % append updated Config to file
        save([GUIControl.odir,filesep,GUIControl.MITTdir.name{i}],'Config','-append');
    end

    if GUIControl.plotQCauto
        PlotQCTable(Config)
    end
end
        
end

