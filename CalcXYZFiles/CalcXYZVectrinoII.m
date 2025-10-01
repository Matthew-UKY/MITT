function Config = CalcXYZVectrinoII(Config)
% determine xyz position of sampled volumes using lab instruments (ADV and
% Vectrino Profiler)
% Key measurements can be passed to this function via the Control *.csv file

% create x,y,z coords for each cell
nCells = Config.nCells;
Config.xpos = Config.xpos*ones(1,nCells);
Config.ypos = Config.ypos*ones(1,nCells);
Config.zpos = Config.zpos*ones(1,nCells);

% calculate distances from the probe head for all cells for 
% Vectrino Profiler
if Config.instrument == "VectrinoII"
    Config.cellDist = Config.cellStart+ Config.cellInterval*(0:Config.nCells-1);
    switch Config.Orientation
        case 1 % default orientation
            Config.zpos = Config.zpos-Config.cellDist;
        case 2 % backwards orientation
            Config.zpos = Config.zpos-Config.cellDist;
        case 3 % side-looking orientation
            Config.ypos = Config.ypos-Config.cellDist;
    end
end
end