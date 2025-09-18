function MITT
clear
clc

% Opens the launch window 
% Called from command line
% Calls OrganizeInput, CleanSeries, ClassifyArrayGUI, ClassifyArrayAuto 

% modifications May 2016 by BM
% add buttons for SpikeARMA and setARMAopts to allow despiking by this method
% don't turn off Run button if any of three boxes in Computational Block Control are active
% more commenting

%% Create figure/uicontrols
% create launch GUI figure
pltLaunch = CreatepltLaunch;

% create uicontrol buttons in pltLaunch
[P,hGUIControl,faQC] = makeUIControls(pltLaunch);

%% initialize panel visibilty
set(hGUIControl.ChannelType,'Visible','off');
set(P.SamplingLocations,'Visible','off');
set(P.Uniform,'Visible','off');
set(P.NonUniform,'Visible','off');
set(P.Organize,'Visible','off');

set(P.SpikeOptions,'Visible','off');
set(P.FilterOptions,'Visible','off');
set(P.Clean,'Visible','off');

set(P.Classify,'Visible','off');
P.faQCOptions.Visible = 'off';
set(P.Select,'Visible','off');
set(P.run,'Enable','off');

%% set callback functions for the various uicontrols
% set the CSVcontrol file names
set(P.getfile,'ButtonPushedFcn',@hgetfileCallback);
% Computational block control callbacks
set(hGUIControl.Organize,'ValueChangedFcn',@hOrganizeCallback);
set(hGUIControl.Clean,'ValueChangedFcn',@hCleanCallback);
set(hGUIControl.Classify,'ValueChangedFcn',@hClassifyCallback);
% Organization block callbacks
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

%% Callback functions

%%  File and Message Center
% to get CSVControl file through a gui window
function hgetfileCallback(~, ~, ~)
    % get the name and path of file
    [CSVControlfilename, CSVControlpathname] = uigetfile({'*.csv';'*.txt'},'Get control text file');
    % set field values equal to name and path of file
    hGUIControl.CSVControlpathname.Text = CSVControlpathname;
    hGUIControl.CSVControlfilename.Text = CSVControlfilename;
    
    % set and create output directory (odir) 
    odir = [CSVControlpathname,'MITT Filtered Data'];
    % check for existance of odir
    chk1 = dir(odir);
    % if odir does not exist
    if isempty(chk1)
        % make it
        mkdir(odir);
    end

    % save odir to pltLaunch
    setappdata(pltLaunch.FigureHandle,'odir',odir)
    % change message
    P.message.Value = {'New file selected'};
    % turn on Select button
    P.Select.Visible = 'on';
end

%% Computation block control
% to turn on/off Organization block
function hOrganizeCallback(~, ~, ~)
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
        text = P.message.Value;
        text{end+1} = 'Organize block ON';
        P.message.Value = text;
        scroll(P.message,'bottom')
    else
        % make the panel invisible
        P.Organize.Visible = 'off';
        % change message
        text = P.message.Value;
        text{end+1} = 'Organize block OFF';
        P.message.Value = text;
        scroll(P.message,'bottom')
        % if no block is active
        if ~(yClean||yClassify)
            % turn Run button off
            P.run.Enable = 'off';
        end
    end
end
% to turn on/off Clean block
function hCleanCallback(~, ~, ~)
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
        text = P.message.Value;
        text{end+1} = 'Clean block ON';
        P.message.Value = text;
        scroll(P.message,'bottom')
    else
        % make the panel invisible
        set(P.Clean,'Visible','off');
        set(P.SpikeOptions,'Visible','off');
        set(P.FilterOptions,'Visible','off');
        % change message
        text = P.message.Value;
        text{end+1} = 'Clean block OFF';
        P.message.Value = text;
        scroll(P.message,'bottom')
        % if no block is active
        if ~(yOrg||yClassify)
            % turn Run button off
            set(P.run,'Enable','off');
        end
    end
end
% to turn on/off Classify block
function hClassifyCallback(~, ~, ~)
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
        text = P.message.Value;
        text = string(text);
        text{end+1} = 'Classify block ON';
        P.message.Value = text;
        scroll(P.message,'bottom')
    else
        % make the panel invisible
        set(P.Classify,'Visible','off');
        P.faQCOptions.Visible = 'off';
        % change message
        text = P.message.Value;
        text{end+1} = 'Classify block OFF';
        P.message.Value = text;
        scroll(P.message,'bottom')
        % if no block is active
        if ~(yClean||yOrg)
            set(P.run,'Enable','off'); % turn Run button off
        end
    end
end

%% Organization Control Panel
% to control whether geometry is defined as part of organization or not
function hDefineGeometryCallback(~, ~, ~)
    % get checkmark value
    yCheck = get(hGUIControl.DefineGeometry,'Value');
    % if it is checked
    if yCheck
        % enable uniform/nonuniform channel panel
        set(hGUIControl.ChannelType,'Visible','on');
        set(P.run,'Enable','off');% turn Run button off
    % if it is unchecked 
    else
        % turn off panels
        set(hGUIControl.ChannelType,'Visible','off');
        set(P.Uniform,'Visible','off');
        set(P.NonUniform,'Visible','off');
        set(P.run,'Enable','on');% turn Run button on
    end
    hChannelTypeCallback % run logic for default channel type
    hChannelPresetCallback % run logic for default channel preset
end
% to identify whether a uniform or non-uniform channel was used
function hChannelTypeCallback(~, ~, ~)
    % get checkmark value
    channelType = get(hGUIControl.ChannelType,'Value');
    % if uniform channel
    if strcmp(channelType,'Uniform')
        % turn off nonuniform panel
        set(P.NonUniform,'Visible','off');
        % turn on uniform panel
        set(P.Uniform,'Visible','on');
        set(P.run,'Enable','on');% turn Run button on
    % else it's a non-uniform channel
    else
        % turn off uniform panel
        set(P.Uniform,'Visible','off');
        % turn on nonuniform panel
        set(P.NonUniform,'Visible','on');
        set(P.run,'Enable','off');% turn Run button off
    end            
end
% to set channel values for defined preset(s)
function hChannelPresetCallback(~, ~, ~)
    channelPreset = hGUIControl.ChannelPreset.Value;
    vals = DefaultChannels(channelPreset);
    hGUIControl = subSetValues(hGUIControl,vals);
    % calculate default grid spacing
    hWidthCallback
    hDepthCallback
    hLengthCallback
end
% set of fields that gets data about channel geometry
% to get the length of the test section
function hLengthCallback(~, ~, ~)
    % get length (in m)
    L = hGUIControl.Length.Value;
    % calculate and set default grid spacing (in m)
    l = L/100;
    hGUIControl.Lengthgrid.Value = l;
end
% to get the width of the test section
function hWidthCallback(~, ~, ~)
    % get width (in m)
    B = hGUIControl.Width.Value;
    % calculate and set default grid spacing (in m)
    b = B/100;
    hGUIControl.Widthgrid.Value = b;
end
% to get the depth of the test section
function hDepthCallback(~, ~, ~)
    % get depth (in m)
    H = hGUIControl.Depth.Value;
    % calculate and set default grid spacing (in m)
    h = H/100;
    hGUIControl.Depthgrid.Value = h;
end
% to get a *.csv file of scattered channel geometry or an *.m file that
% calculates the geometry
function hgetCalcChannelfileCallback(~, ~, ~)
    % get value of listbox
    ChannelDefinition = get(hGUIControl.ChannelDefinition,'Value');
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
end
% to control how sampling locations are entered
function hSamplingCallback(~, ~, ~)
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
end
% to get an *.m program that calculates the sampling location
function hgetCalcXYZfileCallback(~, ~, ~)
    % get the name and path of file
    [xyzname, xyzpathname] = uigetfile({'*.m'},'Get sampling locations subprogram');
    % set field values equal to the name and path
    hGUIControl.CalcXYZpathname.Text = xyzpathname;
    hGUIControl.CalcXYZfile.Text = xyzname;
    % turn on Run button
    set(P.run,'Enable','on');
end

%% Clean block Control Panel
% to ask if despiking will be done
function hDespikeCallback(~, ~, ~)
    % get checkmark value
    yCheck = get(hGUIControl.Despike,'Value');
    if yCheck
        %enable spike options popup
        set(P.SpikeOptions,'Visible','on');
    else
        % disable spike options popup
        set(P.SpikeOptions,'Visible','off');
    end            
end
% to control how preprocessing is done
function hPreprocessCallback(~, ~, ~)
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
end
% to ask if SpikeARMA will be run
function hSpikeARMACallback(~, ~, ~)
    % get check mark value
    yCheck = get(hGUIControl.SpikeARMA,'Value');
    if yCheck
        % enable ARMAopts pushbutton
        set(P.ARMAopts,'Enable','on');
        % get attached ARMAopts info from the pltLaunch figure 
        ARMAopts = getappdata(pltLaunch.FigureHandle,'ARMAopts');
        % if there is no attached variable called ARMAopts
        if isempty(ARMAopts)
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
end
% to run setARMAopts when the ARMAopts button is pushed
function hARMAoptsCallback(~, ~, ~)
    % get the ARMAopts data from the figure (can be empty if
    % setARMAopts has not been run previously)
    ARMAopts = getappdata(pltLaunch.FigureHandle,'ARMAopts');
    % run the setARMAopts sub function
    setARMAopts(ARMAopts,pltLaunch);
    % turn on the Run button
    set(P.run,'Enable','on');
end
% to ask if filtering will be done
function hFiltrBWCallback(~, ~, ~)
    % get check mark value
    yCheck = get(hGUIControl.FiltrBW,'Value');
    if yCheck
        % enable filter options popup
        set(P.FilterOptions,'Visible','on');
    else
        % disable filter options popup
        set(P.FilterOptions,'Visible','off');
    end            
end

%% Run
% when Run button is pushed
function hrunCallback(~, ~, ~)
    % get GUIControl parameters from buttons (GUIControl)
    GUIControl = subGetValues(hGUIControl,[]);
    % get output directory
    GUIControl.odir = getappdata(pltLaunch.FigureHandle,'odir');
    % set output filename
    GUIControl.outname = [GUIControl.odir,filesep,GUIControl.CSVControlfilename(1:end-4),'_output.mat'];
    % if SpikeARMA is active
    if GUIControl.SpikeARMA
        % get ARMAopts from figure
        GUIControl.ARMAopts = getappdata(pltLaunch.FigureHandle,'ARMAopts');
    end
    
    % Organize data into Config and Data matrices and save one file for each set of simultaneous data
    if GUIControl.Organize
        % change message
        P.message.Value = 'Organizing data';
        % pause to allow message change
        pause(1)
        % send to OrganizeInput subprogram
        OrganizeInput(GUIControl);
        % change message
        set(P.message,'Value','Finished')
    end
    % files stored in MITTdir
    GUIControl.MITTdir = dir([GUIControl.odir,filesep,'MITT_*.mat']);
    GUIControl.MITTdir = struct2table(GUIControl.MITTdir);

    % Clean data using the analysis activated in the C structure
    if GUIControl.Clean
        % change message
        set(P.message,'Value','Cleaning data')
        % pause to allow message change
        pause(1)
        % send to CleanSeries subprogram
        CleanSeries(GUIControl)
        % change message
        set(P.message,'Value','Finished')
    end
    
    if GUIControl.Classify
        % get field names (including subFieldnames using subprogram)
        GUIControl.faQC = subGetValues(faQC,[]);
        % automatically run ClassifyArrayAuto
        set(P.message,'Value','Running automatic quality control analysis')
        ClassifyArrayAuto(GUIControl)
        set(P.message,'Value','Finished')
        % if interactive analysis is selected
        if GUIControl.plotArray
            % change message
            set(P.message,'Value','Interactive analysis GUI is running')
            % pause to allow message change
            pause(1)
            % send to ClassifyArrayGUI subprogram
            ClassifyArrayGUI(GUIControl,[])
        end
    end
end
     
end

%%
% to create the pltLaunch (initial MITT screen) Figure 
function pltLaunch = CreatepltLaunch 
% this subprogram only includes the figures and axes, not the buttons

% create the figure and set its properties
f = uifigure();
    f.WindowState = 'maximized';
    f.Name = 'MITT GUI for Data Quality Control';
nPanels = 3;
pnl = gobjects(1,3);
uigl = uigridlayout(f,[1,nPanels]);
    uigl.BackgroundColor = ([204 108 231])/255; % purple
for i = 1:nPanels
    pnl(i) = uipanel(uigl,'Units','normalized');
end

pltLaunch.FigureHandle = f;
pltLaunch.PanelHandles = pnl;
end

%%
% to create buttons & fields on input control figure
function [P,GUIControl,faQC] = makeUIControls(pltLaunch)
f = pltLaunch.FigureHandle;
pnl = pltLaunch.PanelHandles;

% defaults across the GUI
Fsize = 12;
Fname = 'Calibri';
backcol = [220 220 220]/255; % used on level 1 boxes
backcol2 = [190 255 255]/255; % used on panels
btn.width = 100;
btn.height = 25;
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

%%%% First panel
% grid
grid = uigridlayout(pnl(1),[4,1]);
    grid.RowHeight = {'fit','1x','fit','fit'};

%%% Title block
P.figtitle = uilabel(grid,def.Label, ...
    Text = 'MITT',...
    FontColor = 'b',...
    BackgroundColor = 'w',...
    FontSize = 40);

%%% File and Message Center
% sub-panel
P.File = uipanel(grid,def.Panel, ...
    Title = 'File and message center');
% sub-grid
grid1 = uigridlayout(P.File,[3,2],...
    RowHeight = {btn.height,btn.height,'1x'},...
    ColumnWidth = {btn.width,'1x'},...
    RowSpacing = 0,...
    ColumnSpacing = 0,...
    Padding = 0);
% file selection pushbutton
P.getfile = uibutton(grid1,def.Button, ...
    Text = 'Select File');
% CSVControl filename textbox
GUIControl.CSVControlfilename = uilabel(grid1,def.Label, ...
    BackgroundColor = backcol,...
    HorizontalAlignment = 'left');
% CSVControl pathname textbox
GUIControl.CSVControlpathname = uilabel(grid1,def.Label, ...
    BackgroundColor = backcol,...
    HorizontalAlignment = 'left');
    GUIControl.CSVControlpathname.Layout.Column = [1,2];
% message textbox
P.message = uitextarea(grid1,...
    FontSize = Fsize,...
    FontName = Fname,...
    BackgroundColor = backcol2,...
    HorizontalAlignment = 'left',...
    Editable = 'off');
    P.message.Layout.Column = [1,2];

%%% Computational Block Control
% sub-panel
P.Select = uipanel(grid,def.Panel, ...
    Title = 'Computational block control');
% sub-grid
grid1 = uigridlayout(P.Select,[3,1],...
    RowHeight = {btn.height,btn.height,btn.height},...
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

%%% Organization Block Options
% sub-panel
P.Organize = uipanel(grid,def.Panel, ...
    Title = 'Organization block options');
% sub-grid
grid1 = uigridlayout(P.Organize,[5,1],...
    RowHeight = {btn.height,btn.height,btn.height,'1x','1x'},...
    RowSpacing = 1);
% Define geometry checkbox
GUIControl.DefineGeometry = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Define channel geometry');
% Subprogram to calculate sampling locations checkbox
GUIControl.Sampling = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Custom algorithm to define sampling locations');
% uniform/nonuniform popup
GUIControl.ChannelType = uidropdown(grid1,def.Dropdown, ...
    Items = {'Uniform','Non-uniform'});
%%% Uniform channel dimensions
% sub-sub-panel
P.Uniform = uipanel(grid1,def.Panel, ...
    Title = 'Uniform channel dimensions',...
    FontAngle = 'italic');
% sub-sub-grid
grid2 = uigridlayout(P.Uniform,[3,10],...
    RowHeight = {btn.height,btn.height,btn.height},...
    ColumnWidth = repmat({btn.height,'1x'},[1,5]),...
    RowSpacing = 2,...
    ColumnSpacing = 2);
% state channel type (only trapezoidal is available - including rectangular with m = 0
% and triangular with B = 0)
P.UniformTypename = uilabel(grid2,def.Label, ...
    Text = 'Trapezoidal channel with origin at u\s centerline',...
    HorizontalAlignment = 'left');
    P.UniformTypename.Layout.Column = [1,8];
GUIControl.ChannelPreset = uidropdown(grid2,def.Dropdown,...
    Items = {'LABS','LABM','LABL','WELL'});
    GUIControl.ChannelPreset.Layout.Column = [9,10];
% create series of labels and text boxes for channel dimensions
% S = bedslope, B = bottom width, H = total flow depth, L = length of
% experimental section, m = sideslope (ratio of mH:1V)
% slope
def.Label.HorizontalAlignment = 'right'; % change for this set of values
P.Slopename = uilabel(grid2,def.Label,Text='S: ');
GUIControl.Slope = uieditfield(grid2,'numeric',def.Editfield);
% width
P.Widthname = uilabel(grid2,def.Label,Text='B: ');
GUIControl.Width = uieditfield(grid2,'numeric',def.Editfield);
% depth
P.Depthname = uilabel(grid2,def.Label,Text='Z: ');
GUIControl.Depth = uieditfield(grid2,'numeric',def.Editfield);
% length
P.Lengthname = uilabel(grid2,def.Label,Text='L: ');
GUIControl.Length = uieditfield(grid2,'numeric',def.Editfield);
% sideslope
P.Sideslopename = uilabel(grid2,def.Label,Text='m: ');
GUIControl.Sideslope = uieditfield(grid2,'numeric',def.Editfield);
% specify grid sizes for 1D and 2D interpolants where the lateral, vertical
% and streamwise grid sizes are represented by b, h, and l, respectively
P.Gridname = uilabel(grid2,def.Label,Text='Grid Size');
    P.Gridname.HorizontalAlignment = 'center';
    P.Gridname.Layout.Column = [1,2];
% widthgrid
P.Widthgridname = uilabel(grid2,def.Label,Text='bg: ');
GUIControl.Widthgrid = uieditfield(grid2,'numeric',def.Editfield);
% depthgrid
P.Depthgridname = uilabel(grid2,def.Label,Text='zg: ');
GUIControl.Depthgrid = uieditfield(grid2,'numeric',def.Editfield);
% lengthgrid
P.Lengthgridname = uilabel(grid2,def.Label,Text='lg: ');
GUIControl.Lengthgrid = uieditfield(grid2,'numeric',def.Editfield);
def.Label.HorizontalAlignment = 'center'; % return to default

%%% Non-uniform channel properties panel
% sub-panel
P.NonUniform = uipanel(grid1,def.Panel, ...
    Title = 'Specify a non-uniform channel',...
    FontAngle = 'italic');
    P.NonUniform.Layout.Row = 4; % takes up same space as the uniform channel block
% sub-sub-grid
grid2 = uigridlayout(P.NonUniform,[3,2],...
    RowHeight = {btn.height,btn.height,btn.height},...
    RowSpacing = 0,...
    ColumnSpacing = 0);
% text box for csv/subprogram option
P.Channeltext = uilabel(grid2,def.Label, ...
    Text = 'Channel coordinates defined in:');
% csv/subprogram popup
GUIControl.ChannelDefinition = uidropdown(grid2,def.Dropdown, ...
    Items = {'CSV File','Subprogram'}, ...
    Value = 'CSV File');
% select file pushbutton
GUIControl.getCalcChannelfile = uibutton(grid2,def.Button, ...
    Text = 'Select program/csv file');
% selected file name text box
GUIControl.CalcChannelfile = uilabel(grid2,def.Label, ...
    BackgroundColor=backcol);
% selected file path name text box
GUIControl.CalcChannelpathname = uilabel(grid2,def.Label, ...
    Backgroundcolor=backcol);
    GUIControl.CalcChannelpathname.Layout.Column = [1,2];

%%% Custom subprogram to calculate sampling locations panel
% sub-panel
P.SamplingLocations = uipanel(grid1,def.Panel,Title='Sampling locations algorithm',FontAngle='italic');
% sub-sub-grid
grid2 = uigridlayout(P.SamplingLocations,[2,2]);
set(grid2, ...
    RowHeight = {btn.height,btn.height}, ...
    ColumnWidth = {'1x','1x'},...
    RowSpacing = 0,...
    ColumnSpacing = 0)
% select file pushbutton
GUIControl.getCalcXYZfile = uibutton(grid2,def.Button,Text='Select');
% selected file name text box
GUIControl.CalcXYZfile = uilabel(grid2,def.Label,BackgroundColor=backcol);
% selected file path name text box
GUIControl.CalcXYZpathname = uilabel(grid2,def.Label,BackgroundColor=backcol);
    GUIControl.CalcXYZpathname.Layout.Column = [1,2];



%%%% Second panel
% grid
grid = uigridlayout(pnl(2),[3,1]);
    grid.RowHeight = {'fit','fit','fit'};

%%% Clean block options
% panel
P.Clean = uipanel(grid,def.Panel,Title='Clean block options');
% sub-grid
grid1 = uigridlayout(P.Clean,[4,1]);
    grid1.RowHeight = repmat({btn.height},[4,1]);
    grid1.RowSpacing = 0;
    grid1.ColumnSpacing = 0;
% reset any existing despiked and/or filtered time series checkbox
GUIControl.SpikeReset = uicheckbox(grid1,def.Checkbox,Text='Reset despiked and/or filtered time series');
% plot time series
GUIControl.plotTimeSeries = uicheckbox(grid1,def.Checkbox,Text='Plot all time series');
% perform despiking
GUIControl.Despike = uicheckbox(grid1,def.Checkbox,Text='Despike');
% perform filtering
GUIControl.FiltrBW = uicheckbox(grid1,def.Checkbox,Text='Frequency filter');

%%% Spike options panel
% panel
P.SpikeOptions = uipanel(grid,def.Panel,...
    Title = 'Despike options',...
    FontAngle='italic');
% sub-grid
grid1 = uigridlayout(P.SpikeOptions,[9,2],...
    RowHeight = [5*btn.height;repmat({btn.height},[8,1])], ...
    RowSpacing = 0, ...
    ColumnSpacing = 0);
% sub-panel
P.Preprocess = uipanel(grid1,def.Panel, ...
    Title = 'Pre-processing',...
    FontAngle = 'italic',...
    ForegroundColor = 'k');
    P.Preprocess.Layout.Column = [1,2];

% sub-sub-grid
grid2 = uigridlayout(P.Preprocess,[3,4],...
    RowHeight = {btn.height,btn.height,btn.height}, ...
    RowSpacing = 0, ...
    ColumnSpacing = 0);
% switch to beam velocitites for spike detection rather than orthogonal components
GUIControl.switch2beam = uicheckbox(grid2,def.Checkbox,...
    Text = 'Use beam veocities?');
    GUIControl.switch2beam.Layout.Column = [1,4];
% preprocess popup
GUIControl.pctmodetext = uilabel(grid2,def.Label, ...
    Text = 'Classify Mode threshold');
    GUIControl.pctmodetext.Layout.Column = [1,2];
% mode edit field
GUIControl.pctmode = uieditfield(grid2,'numeric',def.Editfield, ...
    Value = 20,...
    ValueDisplayFormat = '%0.1f %%');
    GUIControl.pctmode.Layout.Column = [3,4];
% trend removal text
GUIControl.Preprocesstext = uilabel(grid2,def.Label, ...
    Text = 'Trend Removal');
% trend removal dropdown
GUIControl.Preprocess = uidropdown(grid2,def.Dropdown, ...
    Items = {'Median','Linear','High Pass'});
% high pass time edit field
GUIControl.HighPassTime = uieditfield(grid2,'numeric',def.Editfield, ...
    Value = 5,...
    ValueDisplayFormat = '%0.1f (s)',...
    Visible = 'off');
% high pass label
P.HighPasstext = uilabel(grid2,def.Label, ...
    Text = 'windowSize',...
    Visible = 'off');

% spike method label
P.SpikeMethod = uilabel(grid1,def.Label, ...
    Text = 'Despiking Method(s)',...
    HorizontalAlignment = 'left',...
    FontAngle = 'italic');
% spike multiplier label
P.SpikeMultiplier = uilabel(grid1,def.Label, ...
    Text = 'Thresh. Multiplier',...
    HorizontalAlignment = 'left',...
    FontAngle = 'italic');
% Standard deviation checkbox
GUIControl.SpikeStddev = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Standard deviation');
% Standard deviation threshold
GUIControl.StddevThreshold = uieditfield(grid1,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Skewness checkbox
GUIControl.SpikeSkewness = uicheckbox(grid1,def.Checkbox, ...
    Text = 'One side skewness');
% Skewness threshold
GUIControl.SkewnessThreshold = uieditfield(grid1,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Velocity Correlation checkbox
GUIControl.SpikeVelCorr = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Velocity Correlation (Cea07)');
% Velocity Correlation threshold
GUIControl.VelCorrThreshold = uieditfield(grid1,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Goring Nikora checkbox
GUIControl.SpikeGoringNikora = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Phase space thresh. (GN 02)');
% Goring Nikora threshold
GUIControl.GoringNikoraThreshold = uieditfield(grid1,'numeric',def.Editfield, ...
    Value = 1,...
    ValueDisplayFormat = '%0.1f');
% Freeze good data, Parsheh
GUIControl.Parsheh = uicheckbox(grid1,def.Checkbox, ...
    Text = 'Freeze good data (Parsheh 10)');
    GUIControl.Parsheh.Layout.Column = 2;
GUIControl.SpikeARMA = uicheckbox(grid1,def.Checkbox, ...
    Text = 'ARMA (DM 15)');
% Goring Nikora threshold
P.ARMAopts = uibutton(grid1,def.Button, ...
    Text = 'setARMAopts', ...
    Enable = 'off');
P.SpikeReplace = uilabel(grid1,def.Label,...
    Text = 'Replacement Method',...
    HorizontalAlignment = 'left',...
    FontAngle = 'italic');
GUIControl.ReplacementMethod = uidropdown(grid1,def.Dropdown, ...
    Items = {'linear interpolation','quadratic interpolation'});

%%% Filter options panel
P.FilterOptions = uipanel(grid,def.Panel, ...
    Title = 'Filter options',...
    FontAngle = 'italic');
grid1 = uigridlayout(P.FilterOptions,[1,1],...
    RowHeight = {btn.height}, ...
    RowSpacing = 0, ...
    ColumnSpacing = 0);
GUIControl.FilterMethod = uidropdown(grid1,def.Dropdown,...
    Items = {'3rd order butterworth'});

%%%% 3rd panel
% ui panel listing all filter array options and parameters
% grid
grid = uigridlayout(pnl(3),[3,1],...
    RowHeight = {'fit','fit','fit'});

% sub-panel
P.Classify = uipanel(grid,def.Panel, ...
    Title = 'Classify block options');
% sub-grid
grid1 = uigridlayout(P.Classify,[4,3],...
    RowHeight = repmat({btn.height},[4,1]), ...
    RowSpacing = 0,...
    ColumnSpacing = 0);
% reset classification
GUIControl.resetFilter = uicheckbox(grid1,def.Checkbox,...
    Text = 'Reset classifications w/ listed parameters');
    GUIControl.resetFilter.Layout.Column = [1,3];
% use interactive plot or automatic analysis
GUIControl.plotArray = uicheckbox(grid1,def.Checkbox,...
    Text = 'Interactive QC GUI (unchecked = auto analysis)');
    GUIControl.plotArray.Layout.Column = [1,3];
% plot classification results in new window
GUIControl.plotQCauto = uicheckbox(grid1,def.Checkbox,...
    Text = 'Plot classification results in tables');
    GUIControl.plotQCauto.Layout.Column = [1,3];
% set x and y variables for automatic analysis
P.variables = uilabel(grid1,def.Label, ...
    Text = 'Set default x and y variables',...
    HorizontalAlignment = 'left');
GUIControl.nxvar = uidropdown(grid1,def.Dropdown, ...
    Items = {'Vel','Despiked','Filtered'});
GUIControl.Yvar = uidropdown(grid1,def.Dropdown, ...
    Items = {'zZ'});

% Spike options panel
P.faQCOptions = uipanel(grid,def.Panel, ...
    Title = 'Classification parameters',...
    FontAngle = 'italic');
grid1 = uigridlayout(P.faQCOptions,[7,3],...
    RowHeight = repmat({btn.height},[7,1]),...
    ColumnWidth = {'fit','1x','1x'},...
    RowSpacing = 1,...
    ColumnSpacing = 1);
% make faQC buttons
faQC = makefaQCbuttons(grid1,def);
        
% file selection 'Done' pushbutton
P.run = uibutton(grid,def.Button,...
    Text = 'Run Analysis');

end

