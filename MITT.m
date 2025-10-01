clear
clc

% Opens the launch window 
% Called from command line
% Calls OrganizeInput, CleanSeries, ClassifyArrayGUI, ClassifyArrayAuto 

% default directory for stored data
dataPath = 'C:\Users\mattl\Documents\College\Water Resources Research\Turbulence Research\2 Data Repository';

%% Create figure/uicontrols
% create launch GUI figure
f = CreateUIFigure;
f.UserData.dataPath = dataPath;

% create uicontrol buttons in f
f = MakeUIControls(f);

% initialize panel visibilty
f = InitializeUI(f);

% set callbacks
f = SetCallbackFunctions(f);

%% Callback functions

%%  File and Message Center
% to get/setup the CSV control file
function hgetfileCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    if isfolder(f.UserData.dataPath)
        dataPath = f.UserData.dataPath;
    else
        dataPath = '';
    end
    % get the path housing the data
    CSVControlpathname = uigetdir(dataPath,'Get data folder');
    datadir = dir(CSVControlpathname);
    datadir = struct2table(datadir);
    datadir = datadir(~datadir.isdir,:);
    
    % check for existence of csv control file
    nFiles = length(datadir.name);
    fileExtensions = cell(nFiles,1);
    for i = 1:nFiles
        temp1 = strsplit(datadir.name{i},'.');
        fileExtensions{i} = temp1{end};
    end
    CSVControlfilename = [CSVControlpathname,filesep,'ControlFile.csv'];
    % if default named control file doesn't exist
    if ~isfile(CSVControlfilename)
        % user might have made their own control file (e.g. prev version)
        if any(strcmp(fileExtensions,'csv'))
            temp = uigetfile('*.csv','Select existing Control file',CSVControlpathname);
            filename = [CSVControlpathname,filesep,temp];
            CSVControl = readtable(filename);
            if ~ismember('filename', CSVControl.Properties.VariableNames)
                P.message.Value{end+1} = 'Please pick a valid csv control file.';
                scroll(P.message,'bottom')
                return
            end
            CSVControl = sortrows(CSVControl,'filename');
            writetable(CSVControl,CSVControlfilename)
        % otherwise, user has not made a control file yet
        else
            % fill in control file information that is known up front, e.g.
            % instrument type (from file extension) and filename
            CSVControl = DefaultCSVControl(datadir,fileExtensions,CSVControlpathname);
            CSVControl = sortrows(CSVControl,'filename');
            writetable(CSVControl,CSVControlfilename)
        end
    end
    CSVControl = readtable(CSVControlfilename);
    hGUIControl.FilestoCombine.Items = CSVControl.filename;
    % set field values equal to name and path of file
    hGUIControl.CSVControlpathname.Text = CSVControlpathname;
    hGUIControl.CSVControlfilename.Text = 'ControlFile.csv';
    % add data input folder to the path
    addpath(genpath(CSVControlpathname))
    % set and create output directory (odir) 
    odir = [CSVControlpathname,filesep,'MITT Filtered Data'];
    % check for existance of odir
    chk1 = dir(odir);
    % if odir does not exist
    if isempty(chk1)
        % make it
        mkdir(odir);
        % add odir to the path
        addpath(odir)
    end
    % save odir to the figure
    f.UserData.odir = odir;
    % start new message chain
    P.message.Value = {'New data path selected'};
    % turn on Select button
    P.Select.Enable = 'on';
f.UserData.CSVControl = CSVControl;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end

%% Computation block control
% to turn on/off Organization block
function hOrganizeCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get values of buttons on computational block
    yOrg = hGUIControl.Organize.Value;
    yClean = hGUIControl.Clean.Value;
    yClassify = hGUIControl.Classify.Value;
    % if organization block is on
    if yOrg
        % make the panel visible
        P.Organize.Visible = 'on';
        % turn Run button on
        P.run.Enable = 'on';
        % change message
        P.message.Value{end+1} = 'Organize block ON';
        scroll(P.message,'bottom')
    else
        % make the panel invisible
        P.Organize.Visible = 'off';
        % change message
        P.message.Value{end+1} = 'Organize block OFF';
        scroll(P.message,'bottom')
        % if no block is active
        if ~(yClean||yClassify)
            % turn Run button off
            P.run.Enable = 'off';
        end
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to turn on/off Clean block
function hCleanCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get values of buttons on computational block
    yOrg = hGUIControl.Organize.Value;
    yClean = hGUIControl.Clean.Value;
    yClassify = hGUIControl.Classify.Value;
    if yClean
        % make the panel visible
        set(P.Clean,'Visible','on');
        set(P.SpikeOptions,'Visible','on');
        set(P.FilterOptions,'Visible','on');
        % turn Run button on
        set(P.run,'Enable','on');
        % change message
        P.message.Value{end+1} = 'Clean block ON';
        scroll(P.message,'bottom')
    else
        % make the panel invisible
        set(P.Clean,'Visible','off');
        set(P.SpikeOptions,'Visible','off');
        set(P.FilterOptions,'Visible','off');
        % change message
        P.message.Value{end+1} = 'Clean block OFF';
        scroll(P.message,'bottom')
        % if no block is active
        if ~(yOrg||yClassify)
            % turn Run button off
            set(P.run,'Enable','off');
        end
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to turn on/off Classify block
function hClassifyCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
faQC = f.UserData.faQC;
    % get values of buttons on computational block
    yOrg = hGUIControl.Organize.Value;
    yClean = hGUIControl.Clean.Value;
    yClassify = hGUIControl.Classify.Value;
    if yClassify
        % load default cell quality parameters
        faQCdefault = DefaultfaQC; % DefaultfaQC is a separate m file that is used only to load default values
        % set default values
        faQC = subSetValues(faQC,faQCdefault);
        % make the panel visible
        set(P.Classify,'Visible','on');
        P.faQCOptions.Visible = 'on';
        % turn Run button on
        set(P.run,'Enable','on');
        % change message
        P.message.Value{end+1} = 'Classify block ON';
        scroll(P.message,'bottom')
    else
        % make the panel invisible
        set(P.Classify,'Visible','off');
        P.faQCOptions.Visible = 'off';
        % change message
        P.message.Value{end+1} = 'Classify block OFF';
        scroll(P.message,'bottom')
        % if no block is active
        if ~(yClean||yOrg)
            set(P.run,'Enable','off'); % turn Run button off
        end
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
f.UserData.faQC = faQC;
end

%% Organization Control Panel
% to edit the csv control file
function hEditCSVCallback(~,~,~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    fcsv = figure(WindowState='maximized',...
                  Name='CSV Editing Window');
    CSVControl = f.UserData.CSVControl;
    t = uitable(fcsv,Data=CSVControl);
    Position = fcsv.Position;
    t.Position = [0 0 Position(3) Position(4)];
    t.ColumnEditable = true;
    t.CellEditCallback = @hCellEditCallback;
    t.UserData = f;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% save the data edits to the figure and the ControlFile
function hCellEditCallback(src,~,~)
t = src;
f = t.UserData;
hGUIControl = f.UserData.hGUIControl;
CSVControl = t.Data;
CSVControlpathname = hGUIControl.CSVControlpathname.Text;
CSVControlfilename = hGUIControl.CSVControlfilename.Text;
writetable(CSVControl,[CSVControlpathname,filesep,CSVControlfilename])
f.UserData.CSVControl = CSVControl;
end
% to combine files before organization occurs
function hCombineFilesCallback(~,~,~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    yCheck = hGUIControl.CombineFiles.Value;
    P.Combine.Visible = yCheck;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to react to files selected by the user
function hFileCombineCallback(~,~,~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
CSVControl = f.UserData.CSVControl;
    CSVControlpathname = hGUIControl.CSVControlpathname.Text;
    files = hGUIControl.FilestoCombine.Value;
    IsSelected = ismember(CSVControl.filename,files);
    ins = CSVControl.instrument(IsSelected);
    % files selected must be VectrinoII's and must be more than one file
    if all(strcmp(ins,'VectrinoII')) || length(ins) > 1
        startTime = zeros(length(files),1);
        for i = 1:length(files)
            file = [CSVControlpathname,filesep,files{i}];
            load(file,'Config')
            startTime(i) = Config.startCollectionTime_seconds + Config.startCollectionTime_subseconds;
        end
        if range(startTime) == 0
            AllStruct = struct();
            % load each file and save its raw data in AllStruct
            for i = 1:length(files)
                file = [CSVControlpathname,filesep,files{i}];
                load(file,'Data','Config')
                AllStruct(i).Data = Data;
                AllStruct(i).Config = Config;
            end
            [Data,Config] = CombineFiles(AllStruct);
            % save into the data folder under a new name
            ySame = (files{1}-files{2}) == 0;
            defname = files{1}(ySame);
            if isempty(defname)
                defname = 'Combined File';
            end
            combinedFilename = uiputfile('*.mat','Save combined file',[CSVControlpathname,filesep,defname]);
            P.message.Value{end+1} = 'Saving combined file...';
            scroll(P.message,'bottom')
            pause(1) % allow message to pop up
            save([CSVControlpathname,filesep,combinedFilename],'Config','Data')
            P.message.Value{end+1} = 'Done';
            scroll(P.message,'bottom')

            % move old files to a new folder called 'Uncombined Files'
            uncombinedFolder = [CSVControlpathname,filesep,'Uncombined Files'];
            if ~isfolder(uncombinedFolder)
                mkdir(uncombinedFolder)
            end
            for i = 1:length(files)
                file = [CSVControlpathname,filesep,files{i}];
                movefile(file,uncombinedFolder)
            end
            % update the csv control file to reflect the change
            IsCombined = ismember(CSVControl.filename,files);
            datarow = CSVControl(IsCombined,:);
            datarow = datarow(1,:);
            datarow.filename = combinedFilename;
            CSVControl(IsCombined,:) = [];
            CSVControl = [CSVControl;datarow];
            CSVControl = sortrows(CSVControl,'filename');
            % update GUI to reflect the change, i.e. the FiletoCombine list
            hGUIControl.FilestoCombine.Items = CSVControl.filename;
            hGUIControl.FilestoCombine.Value = combinedFilename;
        else
            P.message.Value{end+1} = 'Files are not from the same data collection';
            scroll(P.message,'bottom')
        end
    else
        P.message.Value{end+1} = 'This function only works for the VectrinoII';
        scroll(P.message,'bottom')
    end
f.UserData.CSVControl = CSVControl;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to control whether geometry is defined as part of organization or not
function hDefineGeometryCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get checkbox value
    yCheck = get(hGUIControl.DefineGeometry,'Value');

    % run logic for channeltype / preset
    hGUIControl.ChannelType.Visible = yCheck;
    P.Uniform.Visible = yCheck;
    P.NonUniform.Visible = yCheck;
    if yCheck
        hChannelTypeCallback
        hChannelPresetCallback
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to identify whether a uniform or non-uniform channel was used
function hChannelTypeCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get checkmark value
    channelType = hGUIControl.ChannelType.Value;
    % if uniform channel
    if strcmp(channelType,'Uniform')
        % turn off nonuniform panel
        set(P.NonUniform,'Visible','off');
        % turn on uniform panel
        set(P.Uniform,'Visible','on');
    % else it's a non-uniform channel
    else
        % turn off uniform panel
        set(P.Uniform,'Visible','off');
        % turn on nonuniform panel
        set(P.NonUniform,'Visible','on');
    end  
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to set channel values for defined preset(s)
function hChannelPresetCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    channelPreset = hGUIControl.ChannelPreset.Value;
    vals = DefaultChannels(channelPreset);
    hGUIControl = subSetValues(hGUIControl,vals);
    % calculate default grid spacing
    hWidthCallback
    hDepthCallback
    hLengthCallback
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% set of fields that gets data about channel geometry
% to get the length of the test section
function hLengthCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get length (in m)
    L = hGUIControl.Length.Value;
    % calculate and set default grid spacing (in m)
    l = L/100;
    hGUIControl.Lengthgrid.Value = l;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to get the width of the test section
function hWidthCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get width (in m)
    B = hGUIControl.Width.Value;
    % calculate and set default grid spacing (in m)
    b = B/100;
    hGUIControl.Widthgrid.Value = b;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to get the depth of the test section
function hDepthCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get depth (in m)
    H = hGUIControl.Depth.Value;
    % calculate and set default grid spacing (in m)
    h = H/100;
    hGUIControl.Depthgrid.Value = h;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to get a *.csv file of scattered channel geometry or an *.m file that
% calculates the geometry
function hgetCalcChannelfileCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get value of listbox
    ChannelDefinition = hGUIControl.ChannelDefinition.Value;
    if strcmp(ChannelDefinition,'CSV File')
        % get channel and path name
        [channelname, channelpathname] = uigetfile({'*.csv';'*.txt'},'Get channel geometry *.csv file');
    elseif strcmp(ChannelDefinition,'Subprogram')
        % get channel and path name
        [channelname, channelpathname] = uigetfile('*.m','Get channel geometry subprogram');
    end
    % set channel and path name values to edit fields
    hGUIControl.CalcChannelpathname.Text = channelpathname;
    hGUIControl.CalcChannelfile.Text = channelname;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to control how sampling locations are entered
function hSamplingCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    yCheck = get(hGUIControl.Sampling,'Value');
    % if custom subprogram is to be used
    if yCheck
        % enable window for this purpose
        set(P.SamplingLocations,'Visible','on');
        set(P.run,'Enable','off');% turn Run button off
    % otherwise no subroutine is run
    else
        % disable window
        set(P.SamplingLocations,'Visible','off');
        set(P.run,'Enable','on');% turn Run button on
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to get an *.m program that calculates the sampling location
function hgetCalcXYZfileCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % assume user is currently in the MITT folder
    curpath = pwd;
    defpath = [curpath,filesep,'CalcXYZFiles'];
    if ~isfolder(defpath)
        defpath = '';
    end
    [xyzname, xyzpathname] = uigetfile('*.m','Get sampling locations subprogram',defpath);
    % set field values equal to the name and path
    hGUIControl.CalcXYZpathname.Text = xyzpathname;
    hGUIControl.CalcXYZfile.Text = xyzname;
    % add the folder where CalcXYZ files are located to the path
    addpath(xyzpathname)
    % turn on Run button
    set(P.run,'Enable','on');
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end

%% Clean block Control Panel
% to ask if despiking will be done
function hDespikeCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
    % get checkmark value
    yCheck = get(hGUIControl.Despike,'Value');
    if yCheck
        %enable spike options popup
        set(P.SpikeOptions,'Visible','on');
    else
        % disable spike options popup
        set(P.SpikeOptions,'Visible','off');
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to control how preprocessing is done
function hPreprocessCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    Preprocess = get(hGUIControl.Preprocess,'Value');
    % if doing high pass
    if strcmp(Preprocess,'High Pass')
        % enable window for this purpose
        set(hGUIControl.HighPassTime,'Visible','on');
        set(P.HighPasstext,'Visible','on');
    % otherwise, turn that window off
    else
        % disable window
        set(hGUIControl.HighPassTime,'Visible','off');
        set(P.HighPasstext,'Visible','off');
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to ask if SpikeARMA will be run
function hSpikeARMACallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get check mark value
    yCheck = get(hGUIControl.SpikeARMA,'Value');
    if yCheck
        % enable ARMAopts pushbutton
        set(P.ARMAopts,'Enable','on');
        % if there is no attached variable called ARMAopts
        if ~isfield(f.UserData,'ARMAopts')
            % don't allow the run button to be pushed (would cause an
            % error to try to run without ARMAopts
            set(P.run,'Enable','off');
        end
    else
        % turn off the setARMAopts button
        set(P.ARMAopts,'Enable','off');
        % turn on the Run button
        set(P.run,'Enable','on');
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end
% to run setARMAopts when the ARMAopts button is pushed
function hARMAoptsCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    ARMAopts = struct();
    % get the ARMAopts data from the figure if it exists
    if isfield(f.UserData,'ARMAopts')
        ARMAopts = f.UserData.ARMAopts;
    end
    % run the setARMAopts sub function
    setARMAopts(ARMAopts,f);
    % turn on the Run button
    set(P.run,'Enable','on');
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
f.UserData.ARMAopts = ARMAopts;
end
% to ask if filtering will be done
function hFiltrBWCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % get check mark value
    yCheck = get(hGUIControl.FiltrBW,'Value');
    if yCheck
        % enable filter options popup
        set(P.FilterOptions,'Visible','on');
    else
        % disable filter options popup
        set(P.FilterOptions,'Visible','off');
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end

%% Run
% when Run button is pushed
function hrunCallback(~, ~, ~)
f = gcbf;
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
faQC = f.UserData.faQC;
    % remove all previous messages
    P.message.Value = '';
    % get GUIControl parameters from buttons (hGUIControl)
    GUIControl = subGetValues(hGUIControl,[]);
    % get output directory
    GUIControl.odir = f.UserData.odir;
    % set output filename
    GUIControl.outname = [GUIControl.odir,filesep,GUIControl.CSVControlfilename(1:end-4),'_output.mat'];
    % if SpikeARMA is active
    if GUIControl.SpikeARMA
        % get ARMAopts from figure
        GUIControl.ARMAopts = f.UserData.ARMAopts;
    end
    
    % Organize data into Config and Data matrices and save one file for each set of simultaneous data
    if GUIControl.Organize
        tic
        % change message
        P.message.Value{end+1} = 'Organizing data...';
        scroll(P.message,'bottom')
        pause(0.01)
        % send to OrganizeInput subprogram
        OrganizeInput(GUIControl,P);
        TimeToOrganize = toc;
        % change message
        P.message.Value{end+1} = sprintf('    Time to Organize: %1.3fs',TimeToOrganize);
        P.message.Value{end+1} = 'Done';
        scroll(P.message,'bottom')
    end
    % files stored in MITTdir
    GUIControl.MITTdir = dir([GUIControl.odir,filesep,'MITT_*.mat']);
    % store as a table for easier indexing
    GUIControl.MITTdir = struct2table(GUIControl.MITTdir);

    % Clean data using the analysis activated in the C structure
    if GUIControl.Clean
        % change message
        P.message.Value{end+1} = 'Cleaning Data...';
        scroll(P.message,'bottom')
        pause(0.01)
        
        tic
        % send to CleanSeries subprogram
        CleanSeries(GUIControl,P)
        TimeToClean = toc;
        % change message
        P.message.Value{end+1} = sprintf('    Time to Clean: %1.3fs',TimeToClean);
        P.message.Value{end+1} = 'Done';
        scroll(P.message,'bottom')
        pause(0.01)
    end
    
    if GUIControl.Classify
        tic
        % get field names (including subFieldnames using subprogram)
        GUIControl.faQC = subGetValues(faQC,[]);
        % automatically run ClassifyArrayAuto
        P.message.Value{end+1} = 'Running ClassifyArrayAuto...';
        scroll(P.message,'bottom')
        pause(0.01)
        ClassifyArrayAuto(GUIControl,P)
        TimeToClassify = toc;
        P.message.Value{end+1} = sprintf('Time to classify: %1.3fs',TimeToClassify);
        P.message.Value{end+1} = 'Done';
        scroll(P.message,'bottom')
        pause(0.01)
        % if interactive analysis is selected
        if GUIControl.plotArray
            tic
            P.message.Value{end+1} = 'Loading data for interactive analysis GUI';
            scroll(P.message,'bottom')
            pause(0.01)
            % send to ClassifyArrayGUI subprogram
            ClassifyArrayGUI(GUIControl,P)
            TimeToLoad = toc;
            P.message.Value{end+1} = sprintf('Time to load: %1.3fs',TimeToLoad);
            P.message.Value{end+1} = 'Done';
            scroll(P.message,'bottom')
        end
    end
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
f.UserData.GUIControl = GUIControl;
end

%% UI creation functions
% to create the uifigure (initial MITT screen) 
function f = CreateUIFigure 
% this subprogram only includes the figures and axes, not the buttons
% create the figure and set its properties
f = uifigure();
    f.WindowState = 'maximized';
    f.Name = 'MITT Figure';
grid = uigridlayout(f,[3,3],...
    RowSpacing = 5,...
    ColumnSpacing = 5,...
    Padding = 5,...
    BackgroundColor = ([204 108 231])/255,... % purple
    RowHeight = {'fit','fit','1x'});
f.UserData.Grid = grid;
end

% to create buttons & fields on input control figure
function f = MakeUIControls(f)
grid = f.UserData.Grid;
% defaults across the GUI
Fsize = 12;
Fname = 'Calibri';
backcol = [220 220 220]/255; % used on level 1 boxes
backcol2 = [190 255 255]/255; % used on panels
btn.width = 100;
btn.height = 25;
% defaults for grids
def.Grid.RowSpacing = 5;
def.Grid.ColumnSpacing = 5;
def.Grid.Padding = 5;
% defaults for uipanel
def.Panel.Title = '';
def.Panel.FontSize = Fsize;
def.Panel.FontName = Fname;
def.Panel.ForegroundColor = 'b'; % blue
def.Panel.BackgroundColor = 'w'; % white
% defaults for uilabel
def.Label.Text = '';
def.Label.FontSize = Fsize;
def.Label.FontName = Fname;
def.Label.HorizontalAlignment = 'center';
%defaults for uibutton
def.Button.Text = '';
def.Button.FontSize = Fsize;
def.Button.FontName = Fname;
def.Button.BackgroundColor = 'w';
% defaults for uicheckbox
def.Checkbox.Text = '';
def.Checkbox.FontSize = Fsize;
def.Checkbox.FontName = Fname;
% defaults for uidropdown
def.Dropdown.Items = {''};
def.Dropdown.FontSize = Fsize;
def.Dropdown.FontName = Fname;
% defaults for uieditfield
def.Editfield.FontSize = Fsize;
def.Editfield.FontName = Fname;
def.Editfield.HorizontalAlignment = 'center';
% defaults for uilistbox
def.Listbox.FontSize = Fsize;
def.Listbox.FontName = Fname;
def.Listbox.Multiselect = 'on';

%%%% Title block
P.Figtitle = uilabel(grid,def.Label, ...
    Text = 'MITT - GUI for Data Quality Control',...
    FontColor = 'b',...
    BackgroundColor = 'w',...
    FontSize = 40);
    P.Figtitle.Layout.Column = [1,3];

%%%% Start - Computational Block Control
P.Select = uipanel(grid,def.Panel, ...
    Title = 'Computational block control');
    P.Select.Layout.Column = [1,3];
grid1 = uigridlayout(P.Select,[1,3],def.Grid,...
    RowSpacing = 1);
% Organization block checkbox
GUIControl.Organize = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Organize raw data into Data and Config array');
% Clean block checkbox
GUIControl.Clean = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Clean raw time series');
% Classify block checkbox
GUIControl.Classify = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Classify quality of time series');
%%%% End - Computational Block Control

%%%% Start - Organization panel
grid1 = uigridlayout(grid,[2,1],def.Grid,...
    RowHeight = {'fit','fit'});
%%% File and Message Center
P.File = uipanel(grid1,def.Panel, ...
    Title = 'File and message center');
grid2 = uigridlayout(P.File,[3,2],def.Grid,...
    RowHeight = {btn.height,btn.height,'1x'},...
    ColumnWidth = {btn.width,'1x'},...
    RowSpacing = 0,...
    ColumnSpacing = 0,...
    Padding = 0);
% file selection pushbutton
P.getfile = uibutton(grid2,def.Button, ...
    Text = 'Select File');
% CSVControl filename textbox
GUIControl.CSVControlfilename = uilabel(grid2,def.Label, ...
    BackgroundColor = backcol,...
    HorizontalAlignment = 'left');
% CSVControl pathname textbox
GUIControl.CSVControlpathname = uilabel(grid2,def.Label, ...
    BackgroundColor = backcol,...
    HorizontalAlignment = 'left');
    GUIControl.CSVControlpathname.Layout.Column = [1,2];
% message textbox
P.message = uitextarea(grid2,...
    FontSize = Fsize,...
    FontName = Fname,...
    BackgroundColor = backcol2,...
    HorizontalAlignment = 'left',...
    Editable = 'off');
    P.message.Layout.Column = [1,2];
%%% Organization Block Options
P.Organize = uipanel(grid1,def.Panel, ...
    Title = 'Organization block options');
grid2 = uigridlayout(P.Organize,[8,1],def.Grid,...
    RowHeight = {btn.height,btn.height,btn.height*5,btn.height,btn.height,'fit',btn.height,'fit'});
% edit csv file button
GUIControl.EditCSV = uibutton(grid2,def.Button,...
    Text = 'Edit CSV File');
% Combine files checkbox
GUIControl.CombineFiles = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Combine split files');
%%% Combine files
P.Combine = uipanel(grid2,def.Panel, ...
    Title = 'Combine files',...
    FontAngle = 'italic');
grid3 = uigridlayout(P.Combine,[2,2],def.Grid,...
    RowHeight = {'1x',btn.height},...
    ColumnWidth = {'1x',btn.width});
GUIControl.FilestoCombine = uilistbox(grid3,def.Listbox);
    GUIControl.FilestoCombine.Layout.Row = [1,2];
P.FileCombine = uibutton(grid3,def.Button,...
    Text = 'Combine');
% uniform/nonuniform dropdown
GUIControl.ChannelType = uidropdown(grid2,def.Dropdown, ...
    Items = {'Uniform','Non-uniform'});
% Define geometry checkbox
GUIControl.DefineGeometry = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Define channel geometry');
%%% Uniform channel dimensions
P.Uniform = uipanel(grid2,def.Panel, ...
    Title = 'Uniform channel dimensions',...
    FontAngle = 'italic');
grid3 = uigridlayout(P.Uniform,[3,10],def.Grid,...
    RowHeight = {btn.height,btn.height,btn.height},...
    ColumnWidth = repmat({btn.height,'1x'},[1,5]));
% state channel type (only trapezoidal is available - including rectangular with m = 0
% and triangular with B = 0)
P.UniformTypename = uilabel(grid3,def.Label, ...
    Text = 'Trapezoidal channel with origin at u\s centerline',...
    HorizontalAlignment = 'left');
    P.UniformTypename.Layout.Column = [1,8];
GUIControl.ChannelPreset = uidropdown(grid3,def.Dropdown,...
    Items = {'LABS','LABM','LABL','WELL'});
    GUIControl.ChannelPreset.Layout.Column = [9,10];
% create series of labels and text boxes for channel dimensions
% S = bedslope, B = bottom width, H = total flow depth, L = length of
% experimental section, m = sideslope (ratio of mH:1V)
% slope
def.Label.HorizontalAlignment = 'right'; % change for this set of values
P.Slopename = uilabel(grid3,def.Label,Text='S: ');
GUIControl.Slope = uieditfield(grid3,'numeric',def.Editfield);
% width
P.Widthname = uilabel(grid3,def.Label,Text='B: ');
GUIControl.Width = uieditfield(grid3,'numeric',def.Editfield);
% depth
P.Depthname = uilabel(grid3,def.Label,Text='Z: ');
GUIControl.Depth = uieditfield(grid3,'numeric',def.Editfield);
% length
P.Lengthname = uilabel(grid3,def.Label,Text='L: ');
GUIControl.Length = uieditfield(grid3,'numeric',def.Editfield);
% sideslope
P.Sideslopename = uilabel(grid3,def.Label,Text='m: ');
GUIControl.Sideslope = uieditfield(grid3,'numeric',def.Editfield);
% specify grid sizes for 1D and 2D interpolants where the lateral, vertical
% and streamwise grid sizes are represented by b, h, and l, respectively
P.Gridname = uilabel(grid3,def.Label,Text='Grid Size');
    P.Gridname.HorizontalAlignment = 'center';
    P.Gridname.Layout.Column = [1,2];
% widthgrid
P.Widthgridname = uilabel(grid3,def.Label,Text='bg: ');
GUIControl.Widthgrid = uieditfield(grid3,'numeric',def.Editfield);
% depthgrid
P.Depthgridname = uilabel(grid3,def.Label,Text='zg: ');
GUIControl.Depthgrid = uieditfield(grid3,'numeric',def.Editfield);
% lengthgrid
P.Lengthgridname = uilabel(grid3,def.Label,Text='lg: ');
GUIControl.Lengthgrid = uieditfield(grid3,'numeric',def.Editfield);
def.Label.HorizontalAlignment = 'center'; % return to default

%%% Non-uniform channel properties panel
% sub-panel
P.NonUniform = uipanel(grid2,def.Panel, ...
    Title = 'Specify a non-uniform channel',...
    FontAngle = 'italic');
    P.NonUniform.Layout.Row = P.Uniform.Layout.Row; % takes up same space as the uniform channel block
% sub-sub-grid
grid3 = uigridlayout(P.NonUniform,[3,2],def.Grid,...
    RowHeight = {btn.height,btn.height,btn.height},...
    RowSpacing = 0,...
    ColumnSpacing = 0,...
    Padding = 0);
% text box for csv/subprogram option
P.Channeltext = uilabel(grid3,def.Label, ...
    Text = 'Channel coordinates defined in:');
% csv/subprogram popup
GUIControl.ChannelDefinition = uidropdown(grid3,def.Dropdown, ...
    Items = {'CSV File','Subprogram'}, ...
    Value = 'CSV File');
% select file pushbutton
GUIControl.getCalcChannelfile = uibutton(grid3,def.Button, ...
    Text = 'Select program/csv file');
% selected file name text box
GUIControl.CalcChannelfile = uilabel(grid3,def.Label, ...
    BackgroundColor=backcol);
% selected file path name text box
GUIControl.CalcChannelpathname = uilabel(grid3,def.Label, ...
    Backgroundcolor=backcol);
    GUIControl.CalcChannelpathname.Layout.Column = [1,2];
% Subprogram to calculate sampling locations checkbox
GUIControl.Sampling = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Custom algorithm to define sampling locations');
%%% Custom subprogram to calculate sampling locations panel
% sub-panel
P.SamplingLocations = uipanel(grid2,def.Panel,Title='Sampling locations algorithm',FontAngle='italic');
% sub-sub-grid
grid3 = uigridlayout(P.SamplingLocations,[2,2],def.Grid,...
    RowHeight = {btn.height,btn.height}, ...
    ColumnWidth = {'1x','1x'},...
    RowSpacing = 0,...
    ColumnSpacing = 0,...
    Padding = 0);
% select file pushbutton
GUIControl.getCalcXYZfile = uibutton(grid3,def.Button,Text='Select');
% selected file name text box
GUIControl.CalcXYZfile = uilabel(grid3,def.Label,BackgroundColor=backcol);
% selected file path name text box
GUIControl.CalcXYZpathname = uilabel(grid3,def.Label,BackgroundColor=backcol);
    GUIControl.CalcXYZpathname.Layout.Column = [1,2];
%%%% End - Organization panel


%%%% Second panel
% grid
grid1 = uigridlayout(grid,[3,1],def.Grid);
    grid1.RowHeight = {'fit','fit','fit'};
%%% Clean block options
% panel
P.Clean = uipanel(grid1,def.Panel,Title='Clean block options');
% sub-grid
grid2 = uigridlayout(P.Clean,[4,1],def.Grid,...
    RowHeight = repmat({btn.height},[4,1]));
% reset any existing despiked and/or filtered time series checkbox
GUIControl.SpikeReset = uicheckbox(grid2,def.Checkbox,Text='Reset despiked and/or filtered time series');
% plot time series
GUIControl.plotTimeSeries = uicheckbox(grid2,def.Checkbox,Text='Plot all time series');
% perform despiking
GUIControl.Despike = uicheckbox(grid2,def.Checkbox,Text='Despike');
% perform filtering
GUIControl.FiltrBW = uicheckbox(grid2,def.Checkbox,Text='Frequency filter');

%%% Spike options panel
% panel
P.SpikeOptions = uipanel(grid1,def.Panel,...
    Title = 'Despike options',...
    FontAngle='italic');
% sub-grid
grid2 = uigridlayout(P.SpikeOptions,[9,2],def.Grid,...
    RowHeight = ['fit',repmat({btn.height},[1,8])],...
    RowSpacing = 0,...
    ColumnSpacing = 0);
P.Preprocess = uipanel(grid2,def.Panel, ...
    Title = 'Pre-processing',...
    FontAngle = 'italic',...
    ForegroundColor = 'k');
    P.Preprocess.Layout.Column = [1,2];
grid3 = uigridlayout(P.Preprocess,[3,4],def.Grid,...
    RowHeight = {btn.height,btn.height,btn.height});
% switch to beam velocitites for spike detection rather than orthogonal components
GUIControl.switch2beam = uicheckbox(grid3,def.Checkbox,...
    Text = 'Use beam veocities?');
    GUIControl.switch2beam.Layout.Column = [1,4];
% preprocess popup
GUIControl.pctmodetext = uilabel(grid3,def.Label, ...
    Text = 'Classify Mode threshold');
    GUIControl.pctmodetext.Layout.Column = [1,2];
% mode edit field
GUIControl.pctmode = uieditfield(grid3,'numeric',def.Editfield, ...
    Value = 20,...
    ValueDisplayFormat = '%0.1f %%');
    GUIControl.pctmode.Layout.Column = [3,4];
% trend removal text
GUIControl.Preprocesstext = uilabel(grid3,def.Label, ...
    Text = 'Trend Removal');
% trend removal dropdown
GUIControl.Preprocess = uidropdown(grid3,def.Dropdown, ...
    Items = {'Median','Linear','High Pass'});
% high pass time edit field
GUIControl.HighPassTime = uieditfield(grid3,'numeric',def.Editfield, ...
    Value = 5,...
    ValueDisplayFormat = '%0.1f (s)',...
    Visible = 'off');
% high pass label
P.HighPasstext = uilabel(grid3,def.Label, ...
    Text = 'windowSize',...
    Visible = 'off');

% spike method label
P.SpikeMethod = uilabel(grid2,def.Label, ...
    Text = 'Despiking Method(s)',...
    HorizontalAlignment = 'left',...
    FontAngle = 'italic');
% spike multiplier label
P.SpikeMultiplier = uilabel(grid2,def.Label, ...
    Text = 'Thresh. Multiplier',...
    HorizontalAlignment = 'left',...
    FontAngle = 'italic');
% Standard deviation checkbox
GUIControl.SpikeStddev = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Standard deviation');
% Standard deviation threshold
GUIControl.StddevThreshold = uieditfield(grid2,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Skewness checkbox
GUIControl.SpikeSkewness = uicheckbox(grid2,def.Checkbox, ...
    Text = 'One side skewness');
% Skewness threshold
GUIControl.SkewnessThreshold = uieditfield(grid2,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Velocity Correlation checkbox
GUIControl.SpikeVelCorr = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Velocity Correlation (Cea07)');
% Velocity Correlation threshold
GUIControl.VelCorrThreshold = uieditfield(grid2,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Goring Nikora checkbox
GUIControl.SpikeGoringNikora = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Phase space thresh. (GN 02)');
% Goring Nikora threshold
GUIControl.GoringNikoraThreshold = uieditfield(grid2,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Freeze good data, Parsheh
GUIControl.Parsheh = uicheckbox(grid2,def.Checkbox, ...
    Text = 'Freeze good data (Parsheh 10)');
    GUIControl.Parsheh.Layout.Column = 2;
GUIControl.SpikeARMA = uicheckbox(grid2,def.Checkbox, ...
    Text = 'ARMA (DM 15)');
% Goring Nikora threshold
P.ARMAopts = uibutton(grid2,def.Button, ...
    Text = 'setARMAopts', ...
    Enable = 'off');
P.SpikeReplace = uilabel(grid2,def.Label,...
    Text = 'Replacement Method',...
    HorizontalAlignment = 'left',...
    FontAngle = 'italic');
GUIControl.ReplacementMethod = uidropdown(grid2,def.Dropdown, ...
    Items = {'linear interpolation','quadratic interpolation'});

%%% Filter options panel
P.FilterOptions = uipanel(grid1,def.Panel, ...
    Title = 'Filter options',...
    FontAngle = 'italic');
grid2 = uigridlayout(P.FilterOptions,[1,1],def.Grid,...
    RowHeight = {btn.height});
GUIControl.FilterMethod = uidropdown(grid2,def.Dropdown,...
    Items = {'3rd order butterworth'});

%%%% 3rd panel
% ui panel listing all filter array options and parameters
% grid
grid1 = uigridlayout(grid,[3,1],def.Grid,...
    RowHeight = {'fit','1x',btn.height});

% sub-panel
P.Classify = uipanel(grid1,def.Panel, ...
    Title = 'Classify block options');
% sub-grid
grid2 = uigridlayout(P.Classify,[4,3],def.Grid,...
    RowHeight = repmat({btn.height},[4,1]));
% reset classification
GUIControl.resetFilter = uicheckbox(grid2,def.Checkbox,...
    Text = 'Reset classifications w/ listed parameters');
    GUIControl.resetFilter.Layout.Column = [1,3];
% use interactive plot or automatic analysis
GUIControl.plotArray = uicheckbox(grid2,def.Checkbox,...
    Text = 'Interactive QC GUI (unchecked = auto analysis)');
    GUIControl.plotArray.Layout.Column = [1,3];
% plot classification results in new window
GUIControl.plotQCauto = uicheckbox(grid2,def.Checkbox,...
    Text = 'Plot classification results in tables');
    GUIControl.plotQCauto.Layout.Column = [1,3];
% set x and y variables for automatic analysis
P.variables = uilabel(grid2,def.Label, ...
    Text = 'Set default x and y variables',...
    HorizontalAlignment = 'left');
GUIControl.nxvar = uidropdown(grid2,def.Dropdown, ...
    Items = {'Vel','Despiked','Filtered'});
GUIControl.Yvar = uidropdown(grid2,def.Dropdown, ...
    Items = {'zZ'});

% Spike options panel
P.faQCOptions = uipanel(grid1,def.Panel, ...
    Title = 'Classification parameters',...
    FontAngle = 'italic');
grid2 = uigridlayout(P.faQCOptions,[8,3],...
    RowHeight = repmat({btn.height},[8,1]),...
    ColumnWidth = {'fit','1x','1x'},...
    RowSpacing = 0,...
    ColumnSpacing = 0,...
    Padding = 5);
% make faQC buttons
faQC = makefaQCbuttons(grid2,def);
        
% file selection 'Done' pushbutton
P.run = uibutton(grid1,def.Button,...
    Text = 'Run Analysis');

f.UserData.Grid = grid;
f.UserData.P = P;
f.UserData.hGUIControl = GUIControl;
f.UserData.faQC = faQC;
end

% initializes all the uipanels to their initial visibility
function f = InitializeUI(f)
hGUIControl = f.UserData.hGUIControl;
P = f.UserData.P;
    % organize panel
    hGUIControl.ChannelType.Visible = 'off';
    P.SamplingLocations.Visible = 'off';
    P.Uniform.Visible = 'off';
    P.NonUniform.Visible = 'off';
    P.Combine.Visible = 'off';
    P.Organize.Visible = 'off';
    % clean panel
    P.SpikeOptions.Visible = 'off';
    P.FilterOptions.Visible = 'off';
    P.Clean.Visible = 'off';
    % classify panel(s)
    P.Classify.Visible = 'off';
    P.faQCOptions.Visible = 'off';
    P.Select.Enable = 'off';
    P.run.Enable = 'off';
f.UserData.hGUIControl = hGUIControl;
f.UserData.P = P;
end

% set callback functions for the various uicontrols
function f = SetCallbackFunctions(f)
P = f.UserData.P;
hGUIControl = f.UserData.hGUIControl;
    % set the CSVcontrol file names
    set(P.getfile,'ButtonPushedFcn',@hgetfileCallback);
    % Computational block control callbacks
    set(hGUIControl.Organize,'ValueChangedFcn',@hOrganizeCallback);
    set(hGUIControl.Clean,'ValueChangedFcn',@hCleanCallback);
    set(hGUIControl.Classify,'ValueChangedFcn',@hClassifyCallback);
    % Organization block callbacks
    set(hGUIControl.EditCSV,'ButtonPushedFcn',@hEditCSVCallback);
    set(hGUIControl.CombineFiles,'ValueChangedFcn',@hCombineFilesCallback);
    set(P.FileCombine,'ButtonPushedFcn',@hFileCombineCallback);
    set(hGUIControl.DefineGeometry,'ValueChangedFcn',@hDefineGeometryCallback);
    set(hGUIControl.Sampling,'ValueChangedFcn',@hSamplingCallback);
    set(hGUIControl.getCalcChannelfile,'ButtonPushedFcn',@hgetCalcChannelfileCallback);
    set(hGUIControl.ChannelType,'ValueChangedFcn',@hChannelTypeCallback); 
    set(hGUIControl.ChannelPreset,'ValueChangedFcn',@hChannelPresetCallback);
    set(hGUIControl.Length,'ValueChangedFcn',@hLengthCallback);
    set(hGUIControl.Width,'ValueChangedFcn',@hWidthCallback);
    set(hGUIControl.Depth,'ValueChangedFcn',@hDepthCallback);
    set(hGUIControl.getCalcXYZfile,'ButtonPushedFcn',@hgetCalcXYZfileCallback);
    % Clean block callbacks
    set(hGUIControl.Despike,'ValueChangedFcn',@hDespikeCallback);
    set(hGUIControl.Preprocess,'ValueChangedFcn',@hPreprocessCallback);
    set(hGUIControl.SpikeARMA,'ValueChangedFcn',@hSpikeARMACallback);
    set(P.ARMAopts,'ButtonPushedFcn',@hARMAoptsCallback);
    set(hGUIControl.FiltrBW,'ValueChangedFcn',@hFiltrBWCallback);
    % Run button callback
    set(P.run,'ButtonPushedFcn',@hrunCallback);
f.UserData.P = P;
f.UserData.hGUIControl = hGUIControl;
end