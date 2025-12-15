function Config = CalcXYZVectrinoII(Config,Data)
% determine xyz position of sampled volumes using lab instruments (ADV and
% Vectrino Profiler)
% Key measurements can be passed to this function via the Control *.csv file

% create x,y,z coords for each cell
nCells = Config.nCells;
Config.xpos = Config.xpos*ones(1,nCells);
Config.ypos = Config.ypos*ones(1,nCells);
Config.zpos = Config.zpos*ones(1,nCells);

% cellDist is already calculated by the Vectrino Profiler in Data
Config.cellDist = Data.cellDist;
switch Config.Orientation
    case 0 % Orientation of 0 means use the transformation matrix.
        if isfield(Config,'transMatrix')
            % do things
        else
            msgbox("Transformation matrix not specified for file: " + Config.filename)
        end
    case 1 % 0, default
        Config.zpos = Config.zpos - Config.cellDist;
    case 2 % +180z
        Config.zpos = Config.zpos - Config.cellDist;
    case 3 % -90x, 180y
        Config.ypos = Config.ypos - Config.cellDist;
    case 4 % -90x
        Config.ypos = Config.ypos - Config.cellDist;
    case 5 % +90x, 180y
        Config.ypos = Config.ypos + Config.cellDist;
    case 6 % +90x
        Config.ypos = Config.ypos + Config.cellDist;
end
end