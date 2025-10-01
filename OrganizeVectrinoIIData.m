function [Data,Config] = OrganizeVectrinoIIData(GUIControl,CSVControl)
% gets raw data from VectrinoII output files and saves in Config, Data.  
% called from AOrganize
% subfunctions include CalcConfigVectrinoII GetDataVectrinoII

%% get Config and Data
% get filenames
inname = strcat(GUIControl.CSVControlpathname,filesep,CSVControl.filename{1});
% get Config data from subprogram
Config = CalcConfigVectrinoII(inname);
% save component names in Config
Config.comp = {'u';'v';'w1';'w2'};
% get all variables from CSVControl and put them in Config
vnames = CSVControl.Properties.VariableNames;
nftot = length(vnames);
for nf = 1:nftot
    Config.(vnames{nf}) = CSVControl.(vnames{nf});
end

% if a sampling locations algorithm was specified
if GUIControl.Sampling
    % get position data using CalcXYZfile
    CalcXYZfile = str2func(GUIControl.CalcXYZfile(1:end-2)); % rmv .m
    Config = CalcXYZfile(Config);
end

% calculate derived position data
Config.zZ = Config.zpos/Config.waterDepth;
Config.waterElevation = Config.bedElevation+Config.waterDepth;
Config.zposGlobal = Config.bedElevation+Config.zpos;

if isfield(Config,'Y')
    Config.yY = Config.ypos/Config.Y;
end
% calculate sampling volume (estimated - difficult to actually calculate
% according to Nortek
% assume a cylindrical volume the same diameter as ADV
Config.cellRadius = 0.006/2; % in m, from Sontek/YSI 2001 reference
Config.samplingVolume = pi()*Config.cellRadius^2*Config.cellWidth;

%% get Data from subprogram
Data = GetDataVectrinoII(Config,inname);
% save additional parameters to Config
Config.ntimetot = length(Data.timeStamp);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Config = CalcConfigVectrinoII(inname)

Raw = load(inname,'Config');

%% get relevant parameters from Config structure
datenull = 7;% number of columns to ignore for date value in Config (4 for UW Vectrino II, 7 for Australia)
Config.startTime = datenum(Raw.Config.date(1:end-datenull)); %  
Config.coordSystem = Raw.Config.coordSystem;
Config.syncType = Raw.Config.syncType;
Config.Hz = Raw.Config.sampleRate;
Config.cellWidth = Raw.Config.cellSize/10000;
Config.cellInterval = Config.cellWidth; %same as cellWidth
Config.nCells = Raw.Config.nCells;
% CellStart is at the centroid of the first cell
Config.cellStart = Raw.Config.cellStart/10000;
Config.velocityRange = Raw.Config.velocityRange/1000;
Config.horizontalVelocityRange = Raw.Config.horizontalVelocityRange/1000;
Config.verticalVelocityRange = Raw.Config.verticalVelocityRange/1000;
Config.bottom_supported = Raw.Config.bottom_supported ;
Config.bottom_enable = Raw.Config.bottom_enable ;
Config.bottom_Hz = Raw.Config.bottom_sampleRate;
Config.bottom_minRange = Raw.Config.bottom_minRange/1000;
Config.bottom_maxRange = Raw.Config.bottom_maxRange/1000;
Config.bottom_nCells = Raw.Config.bottom_nCells;
Config.bottom_cellSize = Raw.Config.bottom_cellSize/10000;
Config.MainBoard_acSerialNo = Raw.Config.MainBoard_acSerialNo;
Config.MainBoard_Hz = Raw.Config.MainBoard_hFrequency*1000;
Config.MainBoard_hPICversion = Raw.Config.MainBoard_hPICversion;
Config.MainBoard_hRecSize = Raw.Config.MainBoard_hRecSize;
Config.MainBoard_cFWversion = Raw.Config.MainBoard_cFWversion;
Config.MainBoard_cFWRepoVersion = Raw.Config.MainBoard_cFWRepoVersion;
Config.MainBoard_cFWdate = Raw.Config.MainBoard_cFWdate;
Config.Probe_acSerialNo = Raw.Config.Probe_acSerialNo;
Config.beam2XYZMatrix = Raw.Config.ProbeCalibration_calibrationMatrix;
Config.originalfileName = Raw.Config.fileName;
Config.startCollectionTime_seconds = Raw.Config.startCollectionTime_seconds;
Config.startCollectionTime_subseconds = Raw.Config.startCollectionTime_subseconds;
Config.endCollectionTime_seconds = Raw.Config.endCollectionTime_seconds;
Config.endCollectionTime_subseconds = Raw.Config.endCollectionTime_subseconds;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data = GetDataVectrinoII(Config,inname)
% updated 14/09/12 to fix errors in beam calculations

Raw = load(inname,'Data');
   
%% get measured data
if Config.coordSystem == 1
    Data.Vel.u = Raw.Data.Profiles_VelX;
    Data.Vel.v = Raw.Data.Profiles_VelY;
    Data.Vel.w1 = Raw.Data.Profiles_VelZ1;
    Data.Vel.w2 = Raw.Data.Profiles_VelZ2;
% if saved in Beam, transform into components u v w1 w2
elseif Config.coordSystem == 2
    ntimetot = length(Raw.Data.Profiles_TimeStamp); % added 14/09/12
    nCells=length(Raw.Data.Profiles_Range); % added 14/09/12 
    Beam = zeros(ntimetot,Config.nCells,4);
    Ortho = zeros(ntimetot,4,Config.nCells);

    Beams = {'Beam1','Beam2','Beam3','Beam4'};
    beamVel = strcat("Profiles_Vel",Beams);
    for b = 1:4
        Beam(:,:,b) = Raw.Data.(beamVel(b)); 
    end
    Beam = permute(Beam,[1 3 2 4]);
    for nC = 1:nCells
        % switch to beam
        TransMi = reshape(Config.transformationMatrix(nC,:),4,4)';
        Ortho(:,:,nC) = ConvXYZ2Beam(Beam(:,:,nC),TransMi,1); % edited 14/09/12 to send to correct subprogram
    end
    Ortho = permute(Ortho,[1 3 2]);
    % save components in 
    Data.Vel.u = Ortho(:,:,1);
    Data.Vel.v = Ortho(:,:,2);
    Data.Vel.w1 = Ortho(:,:,3);
    Data.Vel.w2 = Ortho(:,:,4);
end

% get additional detail from files
deets = {'Cor';'Amp';'SNR';'DataQuality'};
Beams = {'Beam1','Beam2','Beam3','Beam4'};
ndtot = length(deets);
nbtot = length(Beams);

rawDeets = strcat("Profiles_",deets);
rawDeets = repmat(rawDeets,[1,nbtot]);
rawDeets = strcat(rawDeets,repmat(Beams,[ndtot,1]));

for d=1:ndtot
    for b = 1:nbtot
        Data.(deets{d}).(Beams{b}) = Raw.Data.(rawDeets{d,b});
    end
end

Data.timeStamp = Raw.Data.Profiles_TimeStamp;

% If Orientation is specified, just permute the velocities to avoid
% slowdowns due to unnecessary matrix multiplication. Otherwise, use the
% specified transformation matrix.
if isfield(Config,'Orientation')
    Data = OrientVectrinoIIVelocities(Data,Config);
end
end

function Data = OrientVectrinoIIVelocities(Data,Config)
Orientation = Config.Orientation;
switch Orientation
case 0 % Orientation of 0 means use the transformation matrix.
    if isfield(Config,'transMatrix')
        Data = TransformVectrinoIIVelocities(Data, Config);
    else
        msgbox("Transformation matrix not specified for file: " + Config.filename)
    end
% The following rotations are in reference to the positive x-axis,
% i.e. downstream, using the right-hand rule
case 1 % No Rotation, Forward-Facing orientation, do nothing
case 2 % No Rotation, Backward-Facing orientation
    Data.Vel.u = -1 * Data.Vel.u;
    Data.Vel.v = -1 * Data.Vel.v;
case 3 % CW-Rotation, Backward-Facing orientation
    tData = Data;
    Data.Vel.u = -1 * tData.Vel.u;
    Data.Vel.v = (tData.Vel.w1 + tData.Vel.w2)/2;
    Data.Vel.w1 = tData.Vel.v;
    Data.Vel.w2 = tData.Vel.v;
case 4 % CW-Rotation, Forward-Facing orientation
    tData = Data;
    Data.Vel.u = tData.Vel.u;
    Data.Vel.v = (tData.Vel.w1 + tData.Vel.w2)/2;
    Data.Vel.w1 = -1 * tData.Vel.v;
    Data.Vel.w2 = -1 * tData.Vel.v;
case 5 % CCW-Rotation, Backward-Facing orientation
    tData = Data;
    Data.Vel.u = -1 * tData.Vel.u;
    Data.Vel.v = -1 * (tData.Vel.w1 + tData.Vel.w2)/2;
    Data.Vel.w1 = -1 * tData.Vel.v;
    Data.Vel.w2 = -1 * tData.Vel.v;
case 6 % CCW-Rotation, Forward-Facing orientation
    tData = Data;
    Data.Vel.u = tData.Vel.u;
    Data.Vel.v = -1 * (tData.Vel.w1 + tData.Vel.w2)/2;
    Data.Vel.w1 = tData.Vel.v;
    Data.Vel.w2 = tData.Vel.v;
end
end

% Transform the data using the user-input transformation matrix.
function Data = TransformVectrinoIIVelocities(Data, Config)
transMatrix = str2num(Config.transMatrix);
if size(transMatrix) == [3, 3]
    vel = ConvStruct2Multi(Data.Vel,["u";"v";"w1";"w2"]);
    [nttot,nCells,ncomptot] = size(vel);

    % transform the data
    for nt = 1:nttot
       for nc = 1:nCells
          uvw1 = vel(nt,nc,[1,2,3]);
          uvw2 = vel(nt,nc,[1,2,4]);
          % prepare for multiplication
          uvw1 = permute(uvw1,[3,2,1]);
          uvw1 = transMatrix*uvw1;  % transform velocity vector
          uvw2 = permute(uvw2,[3,2,1]);
          uvw2 = transMatrix*uvw2;  % transform velocity vector
          vel(nt,nc,[1,2]) = (uvw1(1:2) + uvw2(1:2)) / 2;
          vel(nt,nc,3) = uvw1(3);
          vel(nt,nc,4) = uvw2(3);
       end
     end
     Data = ConvMulti2Struct(vel,Data,["u";"v";"w1";"w2"],'Vel');
else
    msgbox("Transformation matrix input error for file: " + Config.filename)
end
end




