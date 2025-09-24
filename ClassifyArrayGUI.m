function ClassifyArrayGUI(GUIControl,selmem)
% plots array statistics and interactively identifies bad cells from data array
% Called from MITT
% Calls CalcGoodCells, CalcArrayStats
% input is based on a control.csv file - each file should have passed
% through the MITT toolbox and have a Dataa and Configa file for each array

%% Create figure
% create figure, axes, and panels
[plt,axe,P] = qcFigure;
nxtot = plt.UserData.nxtot;

% create uicontrol buttons in figure
B = qcButtons(P);

% initialize buttons
initializeUIElements(B,P,nxtot)

% set callback functions
initializeCallbackFunctions(B,axe,nxtot)

% if files have been preselected (for example for duplicates)
if ~isempty(selmem)
    B.selfile.Items = selmem;
else
    B.selfile.Items = GUIControl.MITTdir.name; % select file listbox
end

% Load all the data into one struct, to be passed around to each callback
nFtot = length(GUIControl.MITTdir.name);
AllStruct = struct();
for nF = 1:nFtot
    inname = [GUIControl.odir,filesep,GUIControl.MITTdir.name{nF}];
    load(inname,'Config','Data');
    AllStruct(nF).Config = Config;
    AllStruct(nF).Data = Data;
end

% put everything in UserData, to be passed around to each callback
UserData = plt.UserData;
UserData.axe = axe;
UserData.P = P;
UserData.B = B;
UserData.GUIControl = GUIControl;
UserData.AllStruct = AllStruct;
plt.UserData = UserData;
end

%% Callback functions
%%%%%%%%%%
% Select arrays panel
%%%%%

% select file button
function hselfileCallback(~, ~, ~)
% to select files to display in selection list 
% acts when 'Done' button is pushed on 'Select Arrays' panel
plt = gcbf;
B = plt.UserData.B;
P = plt.UserData.P;
GUIControl = plt.UserData.GUIControl;
AllStruct = plt.UserData.AllStruct;
nxtot = plt.UserData.nxtot;
axe = plt.UserData.axe;
    yvar = GUIControl.Yvar;
    
    % get names of files selected
    sFnames = B.selfile.Value;
    sFindex = B.selfile.ValueIndex;
    % calc number of files selected
    nsFtot = length(sFnames);
    % set active array names
    B.actfile.Items = sFnames;

    % create selected files struct from AllStruct
    SelStruct = struct();
    for nsF = 1:nsFtot
        SelStruct(nsF).Config = AllStruct(sFindex(nsF)).Config;
        SelStruct(nsF).Data = AllStruct(sFindex(nsF)).Data;
    end
    % get all field names (including from subFields)
    allConfignames = fieldnames(SelStruct(1).Config);
    [~,allDatanames] = subFieldnames(SelStruct(1).Data);
    allDatanames = ['dummy';allDatanames];
    % set fieldnames
    B.Y.var.Items = allConfignames;
    % set default values; zZ is hardcoded in
    B.Y.var.Value = yvar;
    for nx = 1:nxtot
        B.X(nx).var.Items = allDatanames;
    end
% save workspace vars back to UserData
plt.UserData.B = B;
plt.UserData.P = P;
% store new data in UserData in plt
plt.UserData.SelStruct = SelStruct;
plt.UserData.allConfignames = allConfignames;
plt.UserData.allDatanames = allDatanames;

    % don't allow the done button to be pushed again
    B.selfiledone.Enable = 'off';
    % allow replacement of data
    B.replace.Enable = 'on';
    % allow input point to be selected on axes
    set(axe(:),'HitTest','on')
    
    % turn on actions and filter panels 
    P.Y.panel.Visible = 'on';
    P.Actions.Visible = 'on';
    P.Filter.Visible = 'on';
    
    hyvarCallback
    Config = SelStruct(1).Config;
    comp = Config.comp;
    for nx = 1:nxtot
        set(P.X(nx).panel,'Visible','on');
        % plot default profiles
        B.X(nx).var.Value = [GUIControl.nxvar,'.',comp{nx}];
        B.X(nx).analysis.Value = 'mean'; % default
        hxanalysisCallback([],[],nx)

        % place the legend on the first axis
        if nx==1 
            legend(axe(1),B.selfile.Value, ...
                TextColor = 'k', ...
                EdgeColor = 'k', ...
                FontSize = 9);
        end
    end
    hactfileCallback
    % set field values from Config data
    B.faQC = subSetValues(B.faQC,Config.faQC);
end
% replace button
function hreplaceCallback(~,~,~)
% replace files easily, without having to re-enter everything
% acts when 'Replace' button is pushed on 'Select Arrays' panel
plt = gcbf;
B = plt.UserData.B;
P = plt.UserData.P;
AllStruct = plt.UserData.AllStruct;
nxtot = plt.UserData.nxtot;
axe = plt.UserData.axe;    
    % get names of files selected
    sFnames = B.selfile.Value;
    sFindex = B.selfile.ValueIndex;
    % calc number of files selected
    nsFtot = length(sFnames);
    % set active array names
    B.actfile.Items = sFnames;

    % create selected files struct from AllStruct
    SelStruct = struct();
    for nsF = 1:nsFtot
        SelStruct(nsF).Config = AllStruct(sFindex(nsF)).Config;
        SelStruct(nsF).Data = AllStruct(sFindex(nsF)).Data;
    end

% store data in UserData
plt.UserData.B = B;
plt.UserData.P = P;
plt.UserData.SelStruct = SelStruct;

    % clear previous plots
    for nx = 1:nxtot
        cla(axe(nx))
    end

    % create new ydata variable
    hyvarCallback

    % create new xdata variable
    Config = SelStruct(1).Config;
    for nx = 1:nxtot
        % use previous user-input to find xdata
        hxanalysisCallback([],[],nx)

        % place the legend on the first axis
        if nx==1 
            legend(axe(1),B.selfile.Value, ...
                TextColor = 'k', ...
                EdgeColor = 'k', ...
                FontSize = 9);
        end
    end
    % set field values from Config data
    B.faQC = subSetValues(B.faQC,Config.faQC);
end

%%%%%%%%%%
% y axis panel callbacks
%%%%%
% executes when y axis variable is changed
function hyvarCallback(~, ~, ~)
% to get ydata values from SelStruct
plt = gcbf;
B = plt.UserData.B;
SelStruct = plt.UserData.SelStruct;
nxtot = plt.UserData.nxtot;
    % file information
    sFnames = B.selfile.Value;
    nsFtot = length(sFnames);
    yvar = B.Y.var.Value;

    % loop to get ydata for each file 
    ydata = cell(1,nsFtot);
    for nsF = 1:nsFtot
        Config = SelStruct(nsF).Config;
        ydata{nsF} = Config.(yvar);
    end

    % make an empty xdata array if one doesn't already exist
    if ~isfield(plt.UserData,'xdata')
        xdata = cell(nxtot,nsFtot);
        plt.UserData.xdata = xdata;
    end
% save in UserData
plt.UserData.ydata = ydata;
end
% executes when either y minimum or y maximum editable box is changed
function hyminCallback(~, ~, ~)
% to set y axis limits manually
plt = gcbf;
axe = plt.UserData.axe;
B = plt.UserData.B;
nxtot = plt.UserData.nxtot;
    % get values
    ymin = B.Y.min.Value;
    ymax = B.Y.max.Value;
    % set y axis limits on all axes
    for nx = 1:nxtot
        axe(nx).YLim = [ymin ymax];
    end
plt.UserData.axe = axe;
end

%%%%%%%%%%
% xaxis callbacks
%%%%%
% does nothing for now
function hxvarCallback(~, ~, nx)

end
% executes when analysis is changed on axis nx
function hxanalysisCallback(~, ~, nx)
% to plot xdata vs ydata for a given axis
plt = gcbf;
B = plt.UserData.B;
xdata = plt.UserData.xdata;
ydata = plt.UserData.ydata;
axe = plt.UserData.axe;
SelStruct = plt.UserData.SelStruct;
    % get button values
    typeanalysis = B.X(nx).analysis.Value;
    xvar = B.X(nx).var.Value;
    xvar = strsplit(xvar,'.');

    % empty array dat needs to be declared in GUI figure
    dat = [];
    % loop to plot Dataa
    nsFtot = length(SelStruct);
    colline = getColline(nsFtot);
    h = gobjects(nsFtot,1);
    for nsF = 1:nsFtot
        % get data from SelStruct
        if isscalar(xvar)
            dat = SelStruct(nsF).Data.(xvar);
        elseif length(xvar) == 2
            dat = SelStruct(nsF).Data.(xvar{1}).(xvar{2});
        end
        % sub array analysis
        xdata{nx,nsF} = CalcArrayStats(dat,typeanalysis);
        if strcmp(typeanalysis,'box ')
            serror = std(dat);
            meanx1 = mean(dat);
            lx = [meanx1-serror;meanx1+serror];
            ly = [ydata{nsF};ydata{nsF}];
            line(axe(nx),lx,ly,'Color',col1,'LineStyle','-','Marker','+');
        end
        % plot line
        h(nsF) = line(axe(nx),xdata{nx,nsF},ydata{nsF}, ...
            'Color',colline(nsF,:), ...
            'LineStyle','none', ...
            'Marker','*');
    end
    
    % get automatically determined limits to plot
    xlim = axe(nx).XLim;
    ylim = axe(nx).YLim;
    % write values to the appropriate editable boxes
    B.Y.min.Value = ylim(1);
    B.Y.max.Value = ylim(2);
    B.X(nx).min.Value = xlim(1);
    B.X(nx).max.Value = xlim(2);
% save data in UserData
plt.UserData.xdata = xdata;
plt.UserData.B = B;
end
% executes when either x minimum or x maximum editable box is changed
function hxminCallback(~, ~, nx)
% to set x axis limits manually
plt = gcbf;
B = plt.UserData.B;
axe = plt.UserData.axe;
    % get values
    xmin = B.X(nx).min.Value;
    xmax = B.X(nx).max.Value;
    % set axis x limits
    axe(nx).XLim = [xmin xmax];
plt.UserData.axe = axe;
end
% executes when clear axis button is pushed
function hxclearCallback(~, ~, nx)
% to clear all data and legends from axis
plt = gcbf;
axe = plt.UserData.axe;
    % allow axes limits to change automatically
    axe(nx).XLimMode = 'auto';
    % clear axis
    cla(axe(nx))
end

%%%%%%%%%%
% Actions panel
%%%%%
% to show positions of probes and sampling volumes within the channel
function hplotpositionsCallback(~, ~, ~)
% retrieve data from figure
plt = gcbf;
SelStruct = plt.UserData.SelStruct;
GUIControl = plt.UserData.GUIControl;
PlotPositions(SelStruct,GUIControl.outname);
end
% to enable filtering and plotting of active file
function hactfileCallback(~, ~, ~)
plt = gcbf;
B = plt.UserData.B;
SelStruct = plt.UserData.SelStruct;
    % get values
    Anames = {'Vel','Despiked','Filtered'};
    Config = SelStruct(1).Config;
    yAnalysis = [true Config.Despiked,Config.Filtered];
    Anames = Anames(yAnalysis);
    % display the available data component names
    set(B.filtanalysis,'Items',Anames);
    set(B.plotaicomp,'Items',Config.comp)
    set(B.plotaianalysis,'Items',Anames);
plt.UserData.B = B;
end
% to plot timeseries from selected data point in profile
function hplotoneCallback(~, ~, ~)
plt = gcbf;
ydata = plt.UserData.ydata;
SelStruct = plt.UserData.SelStruct;
B = plt.UserData.B;
    % get values
    naF = get(B.actfile,'ValueIndex');

    % get position of point to plot
    yi = plt.UserData.yi;

    % find nearest point
    [~,naP] = min(abs(yi-ydata{naF}));

    % plot that point as a time series
    PlotTimeSeries(SelStruct(naF).Config,SelStruct(naF).Data,naP);
end
% to turn on filtering panel and load previous filter
function hplotarrayimageCallback(~, ~, ~)
% acts when 'Classify' button is pushed on 'Options' panel
plt = gcbf;
B = plt.UserData.B;
    % enable filtering components dropdown menu
    set(B.plotaicomp,'Enable','on');
plt.UserData.B = B;
end
% to turn on filtering panel and load previous filter
function hplotaicompCallback(~, ~, ~)
% acts when a component is chosen on 'Options' panel
plt = gcbf;
B = plt.UserData.B;
    % enable filter analysis
    set(B.plotaianalysis,'Enable','on');
plt.UserData.B = B;
end
% to load profile filtering parameters
function hplotaianalysisCallback(~, ~, ~)
% acts when an analysis type is chosen on 'Options' panel
plt = gcbf;
B = plt.UserData.B;
SelStruct = plt.UserData.SelStruct;
ydata = plt.UserData.ydata;
    % get values
    aFname = get(B.actfile,'Value');
    naF = get(B.actfile,'ValueIndex');
    compi = get(B.plotaicomp,'Value');
    aType = get(B.plotaianalysis,'Value');
    yvar = get(B.Y.var,'Value');

    % isolate correct data
    Config = SelStruct(naF).Config;
    Data = SelStruct(naF).Data;

    % get goodCells for the appropriate component
    goodCellsi = Config.goodCells.(compi);
    dat = Data.(aType).(compi);
    aTimedata = Data.timeStamp;
    ptitle.top = aFname;
    ptitle.xaxis = 'time (s)';
    ptitle.yaxis = ['Config.',yvar];
    ptitle.legend = [' Data.',aType,'.',compi,' (m/s)'];
    PlotTimeSpace(aTimedata,ydata{naF},dat,goodCellsi,ptitle)
end
% plot classification results for active array in a table
function hfiltarrayCallback(~, ~, ~)
% acts when 'Classify data quality' button is pushed on 'Options' panel
plt = gcbf;
B = plt.UserData.B;
P = plt.UserData.P;
SelStruct = plt.UserData.SelStruct;
GUIControl = plt.UserData.GUIControl;
    % get file listed as the active array in 'set active array' window
    naF = get(B.actfile,'ValueIndex');
    aAnalysis = get(B.filtanalysis,'Value');
    yvar = get(B.Y.var,'Value');
    
    % save vars to GUIControl
    GUIControl.Xvar = aAnalysis;
    GUIControl.Yvar = yvar;

    % plot table of classification results
    Config = SelStruct(naF).Config;
    PlotQCTable(Config);        

plt.UserData.GUIControl = GUIControl;
end
% does nothing right now
function hfiltanalysisCallback(~, ~, ~)
% acts when an analysis type is chosen on 'Options' panel

end

%%%%%%%%%%
% Filter Options panel
%%%%%
% reclassify selected array
function hreClassifyCallback(~, ~, ~)
plt = gcbf;
B = plt.UserData.B;
SelStruct = plt.UserData.SelStruct;
GUIControl = plt.UserData.GUIControl;
    % get values
    naF = get(B.actfile,'ValueIndex');
    aAname = get(B.filtanalysis,'Value');
    yvar = get(B.Y.var,'Value');

    % set C values from Interactive Quality Control Plot
    GUIControl.faQC = subGetValues(B.faQC,[]);
    GUIControl.Xvar = aAname;
    GUIControl.Yvar = yvar;
    GUIControl.resetFilter = 1;
    
    % send to subprogram to filter array based on faQC parameters
    Config = CalcGoodCells(SelStruct(naF).Config,SelStruct(naF).Data,GUIControl);
    % plot table of classificaiton results
    PlotQCTable(Config);
SelStruct(naF).Config = Config;
plt.UserData.SelStruct = SelStruct;
plt.UserData.GUIControl = GUIControl;
end
% manually adjust classification of selected cell
function hmanualGoodCellsCallback(~, ~, ~) 
% get file listed as the active array in 'set active array' window
plt = gcbf;
B = plt.UserData.B;
SelStruct = plt.UserData.SelStruct;
ydata = plt.UserData.ydata;
    naF = get(B.actfile,'ValueIndex');

    % retrieve data from UserData
    Config = SelStruct(naF).Config;
    goodCells = Config.goodCells;
    Qdat = Config.Qdat;
    ydat = ydata{naF};
    comp = fieldnames(goodCells);
    ncomptot = length(comp);

    % find nearest point to user input
    yselect = plt.UserData.yi;
    [~,indx] = min(abs(yselect-ydat));
    
    goodCellsm = ConvStruct2Multi(goodCells,comp);
    goodCellsm = permute(goodCellsm,[1,3,2]); % remove singleton dimension

    if all(goodCellsm(indx,:))
        goodCellsm(indx,:) = 0;
    else
        goodCellsm(indx,:) = 1;
    end
    % save in goodCells
    for ncomp = 1:ncomptot
        goodCells.(comp{ncomp}) = goodCellsm(:,ncomp);
    end
    % save in Qdat
    Qdat(:,1:ncomptot) = goodCellsm;
SelStruct(naF).Config.goodCells = goodCells;
SelStruct(naF).Config.Qdat = Qdat;
plt.UserData.SelStruct = SelStruct; 
end
% get x/y coords from user input and display on axe
function hAxeClickCallback(src,~,~)
plt = gcbf;
axe = plt.UserData.axe;
nxtot = plt.UserData.nxtot;
    % find x,y coords
    xyz = src.CurrentPoint;
    xi = xyz(1,1);
    yi = xyz(1,2);

    % remove previous input point indicator from all axes
    for i = 1:nxtot
        children = axe(i).Children;
        for j = 1:length(children)
            plotType = children(j).Type;
            if strcmp(plotType,'constantline')
                delete(children(j))
            end
        end
    end

    % plot the input point indicator on the plot
    yline(src,yi,'--r',LineWidth = 0.1,Label = 'Input Point')
    %{
    % debug
        clc
        disp(xi)
        disp(yi)
    %}
plt.UserData.xi = xi;
plt.UserData.yi = yi;
end
% function to save QC to output file
function hsaveQCCallback(~, ~, ~)
plt = gcbf;
SelStruct = plt.UserData.SelStruct;
B = plt.UserData.B;
GUIControl = plt.UserData.GUIControl;
    % get active array
    naF = get(B.actfile,'ValueIndex');
    Config = SelStruct(naF).Config;
    % append Config to existing output file
    save([GUIControl.odir,filesep,GUIControl.MITTdir.name{naF}],'Config','-append');
end

%% subprograms
% create the interactive qaqc figure, axes, and panels
function [plt,axe,P] = qcFigure
% to create the Figure used for the interactive qc analysis.  
% Subprogram includes figure, axes, and panels

% defaults for entire figure
Fsize = 12;
Fname = 'Calibri';
pltcol = [230 230 230]/255;
backcol = [255 245 170]/255; % used on level 1 boxes
backcol2 = [210 255 255]/255; % used on axes boxes

% defaults for grid layout
row1Height = 260;
row2Height = 75;

% defaults for panels
def.Panel.Title = '';
def.Panel.FontSize = Fsize;
def.Panel.FontName = Fname;
def.Panel.ForegroundColor = 'k'; % black
def.Panel.BackgroundColor = 'w'; % white

% defaults for axes
nxtot = 3;

% create figure
plt = uifigure(...
    Name = 'MITT Interactive Quality Control Window',...
    Color = pltcol,...
    WindowState = 'maximized');

% create grid
grid = uigridlayout(plt,[3,nxtot],...
    RowHeight = {row1Height,row2Height,'1x'});

% create and set panel properties
pnl = uipanel(grid,...
    BorderType = 'none');
grid1 = uigridlayout(pnl,[2,1],...
    RowHeight = {'1x','fit'},...
    Padding = [0 0 0 0]);
P.select = uipanel(grid1,def.Panel,...
    Title = 'Select data to plot', ...
    BackgroundColor = backcol);
P.Y.panel = uipanel(grid1,def.Panel, ...
    Title = 'y-axis data',...
    BackgroundColor = backcol2);
    P.Y.panel.Layout.Row = 2;
P.Actions = uipanel(grid,def.Panel,...
    Title = 'Actions',...
    BackgroundColor = backcol);
P.Filter = uipanel(grid,def.Panel,...
    Title = 'Classify data quality - Options',...
    BackgroundColor = backcol);
for i = 1:3
    P.X(i).panel = uipanel(grid,def.Panel,...
        Title = ['x',num2str(i),'-axis Data'],...
        BackgroundColor = backcol2);
end

% create and set axes properties
axe = gobjects(nxtot,1);
pnl = uipanel(grid);
    pnl.Layout.Column = [1,3];
    pnl.BorderType = 'none';
t = tiledlayout(pnl,1,3);
    t.TileSpacing = 'compact';
    t.Padding = 'tight';
for nx=1:nxtot
    axe(nx) = nexttile(t);
    if nx>1
        axe(nx).YTickLabel = [];
    end
end

% store some info in UserData field of plt
plt.UserData.nxtot = nxtot;
end
% create buttons for qaqc figure
function B = qcButtons(P)
% to create buttons & fields on figure

% defaults for entire figure
Fsize = 12;
Fname = 'Calibri';
btn.width = 100; % pixels
btn.height = 25; % pixels
nxtot = 3;

% defaults for grid
def.Grid.RowSpacing = 1;
def.Grid.ColumnSpacing = 1;
def.Grid.Padding = [1 1 1 1];

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
def.Listbox.BackgroundColor = 'w'; % white


%%%% file select panel
% grid for positioning
grid = uigridlayout(P.select,[3,2],def.Grid,...
    RowHeight = {'1x',btn.height,btn.height},...
    ColumnWidth = {'1x',btn.width});
% file selection listbox  
B.selfile = uilistbox(grid,def.Listbox,...
    Multiselect = 'on');
    B.selfile.Layout.Row = [1,3];
    B.selfile.Layout.Column = 1;
% file selection 'Done' pushbutton
B.selfiledone = uibutton(grid,def.Button,...
    Text = 'Done');
    B.selfiledone.Layout.Row = 2;
% file selection 'Replace' pushbutton
B.replace = uibutton(grid,def.Button,...
    Text = 'Replace');
    B.replace.Layout.Row = 3;

%%%% y-axis variables panel
grid = uigridlayout(P.Y.panel,[1,3],def.Grid,...
    RowHeight = {btn.height},...
    ColumnWidth = {'1x',btn.width,btn.width});
% Y axis variable dropdown list
B.Y.var = uidropdown(grid,def.Dropdown,...
    Items = {'y-axis Data'});
% Y axis minimum value editable field
B.Y.min = uieditfield(grid,'numeric',def.Editfield);
% Y axis maximum value editable field
B.Y.max = uieditfield(grid,'numeric',def.Editfield);

%%%% x-axis variable panels
% Dataa selection dropdown
for nx = 1:nxtot
    B.X(nx) = Createaxebuttongroup(P.X(nx).panel,def,btn);
end    

%%%% Actions panel
grid = uigridlayout(P.Actions,[5,3],def.Grid,...
    RowHeight = repmat({btn.height},[1,5]),...
    ColumnWidth = {btn.width,btn.width,'1x'});
% plot probe and sampling volume positions button
B.plotpositions = uibutton(grid,def.Button,...
    Text = 'Plot sampling volume positions');
    B.plotpositions.Layout.Column = [1,3];
% active file dropdown
B.actfilelabel = uilabel(grid,def.Label,...
    Text = 'Set active array:');
B.actfile = uidropdown(grid,def.Dropdown,...
    Items = {'a'});
    B.actfile.Layout.Column = [2,3];
% plot one series push button
B.plotone = uibutton(grid,def.Button,...
    Text = 'Plot one series');
    B.plotone.Layout.Column = [1,3];
% plot array image button
B.plotarrayimage = uibutton(grid,def.Button,...
    Text = 'Plot array image');
% plot array image component dropdown
B.plotaicomp = uidropdown(grid,def.Dropdown,...
    Items = {'components'});
% plot array image analysis dropdown
B.plotaianalysis = uidropdown(grid,def.Dropdown,...
    Items = {'analysis'});
% filter array push button
B.filtarray = uibutton(grid,def.Button,...
    Text = 'Classify data quality:');
% filter array dropdown
B.filtanalysis = uidropdown(grid,def.Dropdown,...
    Items = {'filter analysis'});
    B.filtanalysis.Layout.Column = [2,3];

%%%% Panel listing all filter array options and parameters
grid = uigridlayout(P.Filter,[9,3],def.Grid,...
    RowHeight = repmat({btn.height},[1,9]),...
    ColumnWidth = {'fit','1x','1x'});
% make faQC buttons
B.faQC = makefaQCbuttons(grid,def);
% recalculate button for filter array
B.reClassify = uibutton(grid,def.Button,...
    Text = 'Reclassify');
% manual adjustment button
B.manualGoodCells = uibutton(grid,def.Button,...
    Text = 'Manually adjust classifications');
% save button
B.saveQC = uibutton(grid,def.Button,...
    Text = 'Save Classification');
end
% create buttons for x-axis variable control
function X = Createaxebuttongroup(xPanel,def,btn)
% create grid for panel
grid = uigridlayout(xPanel,[2,3],def.Grid,...
    RowHeight = {btn.height,btn.height},...
    ColumnWidth = {'1x',btn.width,btn.width});
% variable to be analysed
X.var = uidropdown(grid,def.Dropdown,...
    Items = {'dependent variable(s)'});
% X axis minimum value editable field
X.min = uieditfield(grid,'numeric',def.Editfield);
% X axis maximum value editable field
X.max = uieditfield(grid,'numeric',def.Editfield);
% analysis type
X.analysis = uidropdown(grid,def.Dropdown,...
    Items = {'sum','mean','std ','skew','kurt','box '});
% clear axis
X.clear = uibutton(grid,def.Button,...
    Text = 'Clear axis');
    X.clear.Layout.Column = [2,3];
end
% initializes the state of all ui elements
function initializeUIElements(B,P,nxtot)
    set(P.select,'Visible','on');
    set(B.replace,'Enable','off');
    set(P.Actions,'Visible','off');
    set(P.Filter,'Visible','off');
    set(P.Y.panel,'Visible','off');
    for nx = 1:nxtot
        set(P.X(nx).panel,'Visible','off');
    end
end
% adds the callback functions to each uielement
function initializeCallbackFunctions(B,axe,nxtot)
% Select arrays panel
set(B.selfiledone,'ButtonPushedFcn',@hselfileCallback);
set(B.replace,'ButtonPushedFcn',@hreplaceCallback);

% Actions panel
set(B.actfile,'ValueChangedFcn',@hactfileCallback);
set(B.plotpositions,'ButtonPushedFcn',@hplotpositionsCallback);
set(B.plotone,'ButtonPushedFcn',@hplotoneCallback);
set(B.plotarrayimage,'ButtonPushedFcn',@hplotarrayimageCallback);
set(B.plotaicomp,'ValueChangedFcn',@hplotaicompCallback);
set(B.plotaianalysis,'ValueChangedFcn',@hplotaianalysisCallback);
set(B.filtarray,'ButtonPushedFcn',@hfiltarrayCallback);
set(B.filtanalysis,'ValueChangedFcn',@hfiltanalysisCallback);

% Classify Options panel
set(B.reClassify,'ButtonPushedFcn',@hreClassifyCallback);
set(B.manualGoodCells,'ButtonPushedFcn',@hmanualGoodCellsCallback);
set(axe(:),'ButtonDownFcn',@hAxeClickCallback)
set(axe(:),'HitTest','off') % turn off axes logic for now
set(B.saveQC,'ButtonPushedFcn',@hsaveQCCallback);

% y axis callbacks
set(B.Y.var,'ValueChangedFcn',@hyvarCallback);
set(B.Y.min,'ValueChangedFcn',@hyminCallback);
set(B.Y.max,'ValueChangedFcn',@hyminCallback);

% x axis callbacks
for nx = 1:nxtot
    set(B.X(nx).var,'ValueChangedFcn',{@hxvarCallback,nx});
    set(B.X(nx).analysis,'ValueChangedFcn',{@hxanalysisCallback,nx});
    set(B.X(nx).min,'ValueChangedFcn',{@hxminCallback,nx});
    set(B.X(nx).max,'ValueChangedFcn',{@hxminCallback,nx});
    set(B.X(nx).clear,'ButtonPushedFcn',{@hxclearCallback,nx});
end
end
