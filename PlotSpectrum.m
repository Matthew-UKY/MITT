function PlotSpectrum(AllStruct,init)
%{
% debug

Config = struct();
Config.ntimetot = 180000;
Config.Hz = 100;
Config.comp = {'u','v','w1','w2'};
Config.startCollectionTime_seconds = 1760907575;
Config.startCollectionTime_subseconds = 0.5;
Config.timeZoneOffset = -14400;
AllStruct = struct();
AllStruct.Config = Config;

Acolor = [0,0,1;
          0,1,0;
          1,0,0]; % blue, green, red
init = struct();
init.FileItems = {'File 1','File 2','File 3','File 4'};
init.FileValue = {'File 1'};
init.AnalysisValue = [true,false,false];
init.AnalysisVisible = [true,true,true];
init.AnalysisColors = Acolor;
init.CellValue = 1;
init.CellMin = 1;
init.CellMax = 35;

%}
% create the default figure w/ control panel
f = VisualizeUIFigure;

% create ui-specific controls
f = PlotSpectrumControls(f);

% create the callback functions
f = CreateCallbacks(f);

% create the ui-specific axes
f.UserData.AllStruct = AllStruct;
f = PlotSpectrumAxes(f);

% initialize figure with user-supplied values
f.UserData.init = init;
f = InitializeUI(f);

% create and update the line objects for each plot
CreateLines(f)
UpdateSpectrumLines(f)
UpdateReferenceLines(f)

f.Name = 'Plot spectrum GUI';
f.Visible = 'on';
end

%% ui creation functions
% create controls for plottimeseries
function f = PlotSpectrumControls(f)
plt = f.UserData;

    plt.SignalPanel = uipanel(plt.grid,Title='Signal Controls');
    plt.SignalPanel.Layout.Column = 3;
    plt.SignalPanel.Layout.Row = 1;
    
    bh = 25; % button height
    grid = uigridlayout(plt.SignalPanel);
    grid.RowHeight = {'fit',bh,'fit',bh,'fit',bh,'fit',bh,'fit',bh,'fit',bh,'fit',bh};
    grid.ColumnWidth = {'1x','2x','1x'};
    grid.Padding = 5;
    grid.RowSpacing = 5;
    grid.ColumnSpacing = 5;

%   pwelch controls
    plt.WindowDropdownLabel = uilabel(grid,Text='Window Type');
    plt.WindowDropdownLabel.Layout.Row = 1;
    plt.WindowDropdownLabel.Layout.Column = [1,3];

    plt.WindowDropdown = uidropdown(grid);
    plt.WindowDropdown.Layout.Row = 2;
    plt.WindowDropdown.Layout.Column = [1,3];

    plt.WindowEditboxLabel = uilabel(grid,Text='Number of Segments');
    plt.WindowEditboxLabel.Layout.Row = 3;
    plt.WindowEditboxLabel.Layout.Column = [1,3];

    plt.WindowEditbox = uieditfield(grid,'numeric');
    plt.WindowEditbox.Layout.Row = 4;
    plt.WindowEditbox.Layout.Column = 3;

    plt.WindowSlider = uislider(grid);
    plt.WindowSlider.Layout.Row = 4;
    plt.WindowSlider.Layout.Column = [1,2];

    plt.NoverlapEditboxLabel = uilabel(grid,Text='Percentage of Overlap');
    plt.NoverlapEditboxLabel.Layout.Row = 5;
    plt.NoverlapEditboxLabel.Layout.Column = [1,3];

    plt.NoverlapEditbox = uieditfield(grid,'numeric');
    plt.NoverlapEditbox.Layout.Row = 6;
    plt.NoverlapEditbox.Layout.Column = 3;

    plt.NoverlapSlider = uislider(grid);
    plt.NoverlapSlider.Layout.Row = 6;
    plt.NoverlapSlider.Layout.Column = [1,2];
        
%   pod controls
    plt.EnergyPercentageLabel = uilabel(grid,Text='Percentage of signal energy');
    plt.EnergyPercentageLabel.Layout.Row = 7;
    plt.EnergyPercentageLabel.Layout.Column = [1,3];

    plt.EnergyPercentageEditbox = uieditfield(grid,'numeric');
    plt.EnergyPercentageEditbox.Layout.Row = 8;
    plt.EnergyPercentageEditbox.Layout.Column = 3;

    plt.EnergyPercentageSlider = uislider(grid);
    plt.EnergyPercentageSlider.Layout.Row = 8;
    plt.EnergyPercentageSlider.Layout.Column = [1,2];

    plt.PodSizeLabel = uilabel(grid,Text='Change size of POD (row x col)');
    plt.PodSizeLabel.Layout.Row = 9;
    plt.PodSizeLabel.Layout.Column = [1,3];

    plt.PodRowEditbox = uieditfield(grid,'numeric');
    plt.PodRowEditbox.Layout.Row = 10;
    plt.PodRowEditbox.Layout.Column = 1;

    plt.PodColEditbox = uieditfield(grid,'numeric');
    plt.PodColEditbox.Layout.Row = 10;
    plt.PodColEditbox.Layout.Column = 3;

% slope lines control
    plt.SlopeLabel = uilabel(grid,Text='Change slope of reference lines');
    plt.SlopeLabel.Layout.Row = 11;
    plt.SlopeLabel.Layout.Column = [1,3];

    plt.SlopeEditbox = uieditfield(grid,'numeric');
    plt.SlopeEditbox.Layout.Row = 12;
    plt.SlopeEditbox.Layout.Column = 3;

    plt.SlopeSlider = uislider(grid);
    plt.SlopeSlider.Layout.Row = 12;
    plt.SlopeSlider.Layout.Column = [1,2];

    plt.TranslateLabel = uilabel(grid,Text='Translate reference lines');
    plt.TranslateLabel.Layout.Row = 13;
    plt.TranslateLabel.Layout.Column = [1,3];

    plt.TranslateSlider = uislider(grid);
    plt.TranslateSlider.Layout.Row = 14;
    plt.TranslateSlider.Layout.Column = [1,3];

f.UserData = plt;
end
% create callback functions
function f = CreateCallbacks(f)
plt = f.UserData;

% pwelch callbacks
    plt.WindowDropdown.ValueChangedFcn = @WindowDropdownValueChanged;
    plt.WindowEditbox.ValueChangedFcn = @WindowEditboxValueChanged;
    plt.WindowSlider.ValueChangedFcn = @WindowSliderValueChanged;
    plt.WindowSlider.ValueChangingFcn = @WindowSliderValueChanging;
    plt.NoverlapEditbox.ValueChangedFcn = @NoverlapEditboxValueChanged;
    plt.NoverlapSlider.ValueChangedFcn = @NoverlapSliderValueChanged;
    plt.NoverlapSlider.ValueChangingFcn = @NoverlapSliderValueChanging;
    plt.EnergyPercentageEditbox.ValueChangedFcn = @EnergyPercentageEditboxValueChanged;
% pod callbacks
    plt.EnergyPercentageSlider.ValueChangedFcn = @EnergyPercentageSliderValueChanged;
    plt.EnergyPercentageSlider.ValueChangingFcn = @EnergyPercentageSliderValueChanging;
    plt.PodRowEditbox.ValueChangedFcn = @PodRowEditboxValueChanged;
    plt.PodColEditbox.ValueChangedFcn = @PodColEditboxValueChanged;
% reference line callbacks
    plt.SlopeEditbox.ValueChangedFcn = @SlopeEditboxValueChanged;
    plt.SlopeSlider.ValueChangingFcn = @SlopeSliderValueChanging;
    plt.TranslateSlider.ValueChangingFcn = @TranslateSliderValueChanging;
% data callbacks
    plt.FilenameListbox.ValueChangedFcn = @FilenameValueChanged;
    plt.VelButton.ValueChangedFcn = @VelButtonValueChanged;
    plt.DespikedButton.ValueChangedFcn = @DespikedButtonValueChanged;
    plt.FilteredButton.ValueChangedFcn = @FilteredButtonValueChanged;
    plt.CellSpinner.ValueChangedFcn = @CellSpinnerValueChanged;

f.UserData = plt;
end
% create the axes objects for this ui
function f = PlotSpectrumAxes(f)
plt = f.UserData;
Config = plt.AllStruct(1).Config;
comp = Config.comp;
nComp = length(comp);
    ax = struct;
    t = tiledlayout(plt.AxesPanel,2,nComp,...
        Padding = 'none',...
        TileSpacing = 'tight',...
        TileIndexing = 'columnmajor');
    for i = 1:nComp
        ax(i).Psd = nexttile(t);
        set(ax(i).Psd,...
            XGrid = 'on',...
            YGrid = 'on',...
            NextPlot = 'add',...
            XScale = 'log',...
            YScale = 'log');
            title(ax(i).Psd,[comp{i},'-component']);
        ax(i).Pre = nexttile(t);
        set(ax(i).Pre,...
            XGrid = 'on',...
            YGrid = 'on',...
            NextPlot = 'add',...
            XScale = 'log',...
            YScale = 'log');
            xlabel(ax(i).Pre,'Frequency (Hz)')
        if i == 1
            ylabel(ax(i).Psd,'Power Spectral Density (m^2/s^2/Hz)')
            ylabel(ax(i).Pre,'Energy (m^2/s^2)')
        end
    end
linkaxes([ax.Psd])
linkaxes([ax.Pre])
plt.ax = ax;
f.UserData = plt;
end
% initialize the ui
function f = InitializeUI(f)
plt = f.UserData;
init = plt.init;
Config = plt.AllStruct(1).Config;

% Initialize window controls
    plt.WindowDropdown.Items = {'hamming','hanning','rectangular'};
    plt.WindowDropdown.Value = 'hanning';
    minVal = 1;
    maxVal = MaxSegments(Config); 
    nSegments = maxVal;
    plt.WindowEditbox.Limits = [minVal,maxVal];
    plt.WindowEditbox.Value = nSegments;
    plt.WindowSlider.Limits = [minVal,maxVal];
    plt.WindowSlider.Value = nSegments;
    plt.WindowSlider.MajorTicks = [minVal,5:5:maxVal,maxVal];
    plt.WindowSlider.MinorTicks = minVal:maxVal;
% Initialize noverlap controls
    minVal = 0;
    maxVal = 0.90;
    novDefault = 0;
    plt.NoverlapEditbox.Limits = [minVal,maxVal];
    plt.NoverlapEditbox.Value = novDefault;
    plt.NoverlapSlider.Limits = [minVal,maxVal];
    plt.NoverlapSlider.Value = novDefault;
    plt.NoverlapSlider.MajorTicks = minVal:0.20:maxVal;
    plt.NoverlapSlider.MajorTickLabels = string(minVal:0.20:maxVal);
    plt.NoverlapSlider.MinorTicks = minVal:0.05:maxVal;
% Initialize pod ui controls
    minVal = 0;
    maxVal = 1;
    energyDefault = 1;
    plt.EnergyPercentageEditbox.Limits = [minVal,maxVal];
    plt.EnergyPercentageEditbox.Value = energyDefault;
    plt.EnergyPercentageSlider.Limits = [minVal,maxVal];
    plt.EnergyPercentageSlider.Value = energyDefault;
    plt.EnergyPercentageSlider.MajorTicks = minVal:0.25:maxVal;
    plt.EnergyPercentageSlider.MajorTickLabels = string(minVal:0.25:maxVal);
    plt.EnergyPercentageSlider.MinorTicks = minVal:0.05:maxVal;
    N = Config.ntimetot;
    rows = floor(sqrt(N));
    cols = floor(N/rows);
    plt.PodRowEditbox.Value = rows;
    plt.PodColEditbox.Value = cols;
% initialize reference line controls
    minVal = -10;
    maxVal = 0;
    defaultSlope = -1;
    plt.SlopeEditbox.Limits = [minVal,maxVal];
    plt.SlopeEditbox.Value = defaultSlope;
    plt.SlopeSlider.Limits = [minVal,maxVal];
    plt.SlopeSlider.Value = defaultSlope;
    minVal = -1;
    maxVal = 1;
    defaultTranslate = 0;
    plt.TranslateSlider.Limits = [minVal,maxVal];
    plt.TranslateSlider.MajorTicks = [];
    plt.TranslateSlider.MinorTicks = [];
    plt.TranslateSlider.Value = defaultTranslate;
    plt.Slope = plt.SlopeSlider.Value;
    plt.Translate = plt.TranslateSlider.Value;
% initialize data display controls
    signalInfo = GetSignalInfo(Config);
    plt.SignalTable.Data = signalInfo;
    plt.FilenameListbox.Items = init.FileItems;
    plt.FilenameListbox.Value = init.FileValue;
    Bnames = {'VelButton','DespikedButton','FilteredButton'};
    for i = 1:length(Bnames)
        plt.(Bnames{i}).Value = init.AnalysisValue(i);
        plt.(Bnames{i}).Visible = init.AnalysisVisible(i);
        plt.(Bnames{i}).BackgroundColor = init.AnalysisColors(i,:);
        plt.(Bnames{i}).FontColor = 'w';
    end
    plt.CellSpinner.Limits = [init.CellMin,init.CellMax];
    plt.CellSpinner.Value = init.CellValue;
% initialize y limits
    ax = plt.ax;
    set([ax.Psd],'XLim',[10^-2,Config.Hz],'YLim',[10^-8,10^-1])
    set([ax.Pre],'XLim',[10^-2,Config.Hz],'YLim',[10^-8,10^-1])

f.UserData = plt;
end
% create the lines in each of the axes
function CreateLines(f)
plt = f.UserData;
ax = plt.ax;
Config = plt.AllStruct(1).Config;
init = plt.init;

    % analysis/comp variables
    comp = Config.comp;
    nComp = length(comp);
    yAnalysis = init.AnalysisVisible;
    Anames = {'Vel','Despiked','Filtered'};
    Anames = Anames(yAnalysis);
    nAnalysis = length(Anames);

    % spectral lines
    SpectrumLines = struct();
    SpectrumLines.Psd = gobjects(nComp,nAnalysis);
    SpectrumLines.Pre = gobjects(nComp,nAnalysis);

    % slope reference lines
    ReferenceLines = struct();
    lineDensity = 9; % number of lines to show on screen
    expansionCoeff = 0.5; % to prevent cutoff of lines as they rotate
    nRef = round(lineDensity*(1+expansionCoeff)-1);
    ReferenceLines.Psd = gobjects(nComp,nRef);
    ReferenceLines.Pre = gobjects(nComp,nRef);
    for i = 1:nComp
        for j = 1:nAnalysis
            % plot dummy lines as containers for spectrum data
            SpectrumLines.Psd(i,j) = plot(ax(i).Psd,1,1);
            SpectrumLines.Pre(i,j) = plot(ax(i).Pre,1,1);
        end
        for k = 1:nRef
            % plot dummy lines as containers for reference line data
            ReferenceLines.Psd(i,k) = plot(ax(i).Psd,[1,1],[1,1],'--',Color=0.8*ones(1,3));
            ReferenceLines.Pre(i,k) = plot(ax(i).Pre,[1,1],[1,1],'--',Color=0.8*ones(1,3));
        end
    end
    ReferenceLines.LineDensity = lineDensity;
    ReferenceLines.ExpansionCoefficient = expansionCoeff;

plt.SpectrumLines = SpectrumLines;
plt.ReferenceLines = ReferenceLines;
f.UserData = plt;
end

%% plotting functions
% update plots from user input
function UpdateSpectrumLines(f)
plt = f.UserData;
ax = plt.ax;
nfile = plt.FilenameListbox.ValueIndex;
ncell = plt.CellSpinner.Value;
Data = plt.AllStruct(nfile).Data;
Config = plt.AllStruct(nfile).Config;
SpectrumLines = plt.SpectrumLines;
Acolor = plt.init.AnalysisColors;

% config variables
    comp = Config.comp;
    nComp = length(comp);
    yAnalysis = [true,Config.Despiked,Config.Filtered];
    Anames = {'Vel','Despiked','Filtered'};
    Anames = Anames(yAnalysis);
    nAnalysis = length(Anames);

% gathering user input from the spectrum controls
    userInput = struct();
    userInput.winType = plt.WindowDropdown.Value;
    userInput.nSegments = plt.WindowEditbox.Value;
    userInput.overlapPercentage = plt.NoverlapEditbox.Value;
    userInput.N = Config.ntimetot;
    userInput.energyPercentage = plt.EnergyPercentageEditbox.Value;
    userInput.nRows = plt.PodRowEditbox.Value;
    userInput.nCols = plt.PodColEditbox.Value;

% inputs to the pwelch function
    fs = Config.Hz;
    window = CreateWindow(userInput);
    noverlap = CreateNoverlap(userInput);

    oldPxxLength = length(SpectrumLines.Psd(1,1).XData);
    for i = 1:nComp
        for j = 1:nAnalysis
            % use POD/pwelch to create a denoised spectrum of the data
            signal = Data.(Anames{j}).(comp{i})(:,ncell);
            signal = PodDenoiseSignal(signal,userInput);
            [pxx,freq] = pwelch(signal,window,noverlap,[],fs);
            newPxxLength = length(pxx);
            if newPxxLength ~= oldPxxLength
                delete(SpectrumLines.Psd(i,j))
                delete(SpectrumLines.Pre(i,j))
                SpectrumLines.Psd(i,j) = plot(ax(i).Psd,freq,pxx,Color=Acolor(j,:));
                SpectrumLines.Pre(i,j) = plot(ax(i).Pre,freq,freq.*pxx,Color=Acolor(j,:));
            else
                SpectrumLines.Psd(i,j).XData = freq;
                SpectrumLines.Psd(i,j).YData = pxx;
                SpectrumLines.Pre(i,j).XData = freq;
                SpectrumLines.Pre(i,j).YData = freq.*pxx;
            end

        end
    end
% save data to figure
plt.SpectrumLines = SpectrumLines;
f.UserData = plt;

% update the visibility of lines
VelButtonValueChanged(f)
DespikedButtonValueChanged(f)
FilteredButtonValueChanged(f)
end
% smoothly update the reference lines
function UpdateReferenceLines(f)
plt = f.UserData;
ax = plt.ax;
Config = plt.AllStruct(1).Config;
comp = Config.comp;
nComp = length(comp);
slope = plt.Slope;
translate = plt.Translate;
ReferenceLines = plt.ReferenceLines;
nRef = length(ReferenceLines.Psd);
expansionCoeff = ReferenceLines.ExpansionCoefficient;

graphType = {'Psd','Pre'};
slope = [slope,slope+1];
for i = 1:length(graphType)
    xlim = ax(1).(graphType{i}).XLim;
    xdata(1) = xlim(1)/(xlim(2)/xlim(1))^(expansionCoeff/2);
    xdata(2) = xlim(2)*(xlim(2)/xlim(1))^(expansionCoeff/2);
    ylim = ax(1).(graphType{i}).YLim;
    ydata(1) = ylim(1)/(ylim(2)/ylim(1))^(expansionCoeff/2);
    ydata(2) = ylim(2)*(ylim(2)/ylim(1))^(expansionCoeff/2);
    lineSpacing = linspace(log10(ydata(1)),log10(ydata(2)),nRef);
    x0 = mean(xlim);
    y0 = mean(ylim);
    for j = 1:nComp
        for k = 1:nRef
            line = ReferenceLines.(graphType{i})(j,k);
            line.XData = xdata;
            ydata = y0*(xdata/x0).^slope(i) * 10^(lineSpacing(k)*sqrt(1+slope(i)^2));
            ydata = ydata * 10^translate; % translate up and down
            line.YData = ydata;
        end
    end
end
end
% split into 32s segments
function maxSegments = MaxSegments(Config)
nSec = 32;
fs = Config.Hz;
nPoints = nSec*fs;
maxSegments = round(Config.ntimetot/nPoints);
end
% Create a new window from updated information
function window = CreateWindow(userInput)
N = userInput.N;
nSegments = userInput.nSegments;
winLength = floor(N/nSegments);
winType = userInput.winType;
switch winType
    case 'hamming'
        window = hamming(winLength);
    case 'hanning'
        window = hanning(winLength);
    case 'rectangular'
        window = ones(winLength,1);
end
end
% Update the number of overlap points from updated information
function noverlap = CreateNoverlap(userInput)
overlapPercentage = userInput.overlapPercentage;
N = userInput.N;
nSegments = userInput.nSegments;
winLength = floor(N/nSegments);
noverlap = round(winLength * overlapPercentage);
end
% Denoise the signal with POD
function signal = PodDenoiseSignal(signal,funcInput)
rows = funcInput.nRows;
cols = funcInput.nCols;
energyPercentage = funcInput.energyPercentage;

% Transform the signal to perform pod
signal = signal - mean(signal); % remove mean
signal = signal(1:rows*cols); % make dimensions work out properly
signal = reshape(signal,rows,cols); % reshape into a matrix, time x records
[U,S,V] = svd(signal); % take the svd of the matrix

% Transform singular values matrix for use in the GUI
percent = diag(S)/sum(S,'all'); % convert to a row array and take percentage
cumulpercent = zeros(1,length(percent));
cumulpercent(1) = percent(1);
for i = 2:length(percent)
    cumulpercent(i) = cumulpercent(i-1) + percent(i);
end

% Find the index of the mode at the cumulative percentage specified by the user
[~,indx] = min(abs(cumulpercent - energyPercentage));

% Modify S to remove energy at higher modes
temp = S;
S = zeros(size(S));
S(1:indx,1:indx) = temp(1:indx,1:indx);

% Reconstruct the denoised signal
signal = U * S * V';
signal = reshape(signal,rows*cols,1);
end
% smooth the signal in logspace and then go back to linspace
function smooth = SmoothSignal(ydata,xdata,percentWidth)
% go to logspace
logX = log10(xdata);
logY = log10(ydata);
% remove any infinities
yNaN = isinf(logX) | isinf(logY);
logX = logX(~yNaN);
logY = logY(~yNaN);
% smooth using moving window of a certain width
method = 'gaussian';
nPoints = 20;
windowWidth = (percentWidth/100)*range(logY);
smooth = smoothdata(logY,method,windowWidth,SamplePoints=logX);
smooth = smoothdata(smooth,method,nPoints);
% return to linspace
smooth = 10.^smooth;
% restore smooth to length of o.g. signal
temp = smooth;
smooth = zeros(size(ydata));
smooth(yNaN) = ydata(yNaN);
smooth(2:end) = temp;
end

%% Callbacks
% Value changed function: WindowDropdown
function WindowDropdownValueChanged(src,~)
    f = ancestor(src,'figure','toplevel');
    UpdateSpectrumLines(f)
end
% Value changed function: WindowEditbox
function WindowEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    nSegments = round(event.Value);
    f.UserData.WindowSlider.Value = nSegments;
    UpdateSpectrumLines(f)
end
% Value changed function: WindowSlider
function WindowSliderValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    nSegments = round(event.Value);
    f.UserData.WindowEditbox.Value = nSegments;
    UpdateSpectrumLines(f)
end
% Value changing function: WindowSlider
function WindowSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    nSegments = round(event.Value);
    f.UserData.WindowEditbox.Value = nSegments;
end
% Value changed function: NoverlapEditbox
function NoverlapEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.NoverlapSlider.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changed function: NoverlapSlider
function NoverlapSliderValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.NoverlapEditbox.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changing function: NoverlapSlider
function NoverlapSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.NoverlapEditbox.Value = event.Value;
end
% Value changed function: EnergyPercentageEditbox
function EnergyPercentageEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.EnergyPercentageSlider.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changed function: EnergyPercentageSlider
function EnergyPercentageSliderValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.EnergyPercentageEditbox.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changing function: EnergyPercentageSlider
function EnergyPercentageSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.EnergyPercentageEditbox.Value = event.Value;
end
% Value changed function: PodRowEditbox
function PodRowEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    nfile = f.UserData.FilenameListbox.ValueIndex;
    Config = f.UserData.AllStruct(nfile).Config;
    N = Config.ntimetot;
    rows = round(event.Value);
    cols = floor(N/rows);
    f.UserData.PodRowEditbox.Value = rows;
    f.UserData.PodColEditbox.Value = cols;
    UpdateSpectrumLines(f)
end
% Value changed function: PodColEditbox
function PodColEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    nfile = f.UserData.FilenameListbox.ValueIndex;
    Config = f.UserData.AllStruct(nfile).Config;
    N = Config.ntimetot;
    cols = round(event.Value);
    rows = floor(N/cols);
    f.UserData.PodRowEditbox.Value = rows;
    f.UserData.PodColEditbox.Value = cols;
    UpdateSpectrumLines(f)
end
% Value changed function: SlopeEditbox
function SlopeEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.Slope = event.Value;
    f.UserData.SlopeSlider.Value = event.Value;
    UpdateReferenceLines(f)
end
% Value changing function: SlopeSlider
function SlopeSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.Slope = event.Value;
    f.UserData.SlopeEditbox.Value = event.Value;
    UpdateReferenceLines(f)
end
% Value changing function: TranslateSlider
function TranslateSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.Translate = event.Value;
    UpdateReferenceLines(f)
end

% Value changed function: FilenameListbox
function FilenameValueChanged(src,event)
f = ancestor(src,'figure','toplevel');
plt = f.UserData;
AllStruct = plt.AllStruct;
    % get the Config struct from the new file
    nfile = event.ValueIndex;
    Config = AllStruct(nfile).Config;
    
% change slider limits and values to match new file
    minVal = 1;
    maxVal = MaxSegments(Config);
    plt.WIndowEditbox.Limits = [minVal,maxVal];
    plt.WindowEditbox.Value = maxVal;
    plt.WindowSlider.Limits = [minVal,maxVal];
    plt.WindowSlider.Value = maxVal;
    plt.WindowSlider.MajorTicks = [minVal,5:5:maxVal,maxVal];
    plt.WindowSlider.MinorTicks = minVal:maxVal;
% maintain the ratio of rows to cols
    rows = plt.PodRowEditbox.Value;
    cols = plt.PodColEditbox.Value;
    ratio = rows/cols;
    N = Config.ntimetot;
    rows = floor(sqrt(N*ratio));
    cols = floor(sqrt(N/ratio));
    plt.PodRowEditbox.Value = rows;
    plt.PodColEditbox.Value = cols;
% change signal info for new file
    signalInfo = GetSignalInfo(Config);
    plt.SignalTable.Data = signalInfo;

f.UserData = plt;
UpdateSpectrumLines(f)
end
% Value changed function: VelButton
function VelButtonValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    plt = f.UserData;
    Acolor = plt.init.AnalysisColors;
    SpectrumLines = plt.SpectrumLines;
    btn = plt.VelButton;
    val = btn.Value;
    % set button visuals
    if val
        btn.BackgroundColor = Acolor(1,:);
    else
        btn.BackgroundColor = 0.8*ones(1,3);
    end
    % set line visuals
    set(SpectrumLines.Psd(:,1),'Visible',val)
    set(SpectrumLines.Pre(:,1),'Visible',val)
end
% Value changed function: DespikedButton
function DespikedButtonValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    plt = f.UserData;
    Acolor = plt.init.AnalysisColors;
    SpectrumLines = plt.SpectrumLines;
    btn = plt.DespikedButton;
    val = btn.Value;
    % set button visuals
    if val
        btn.BackgroundColor = Acolor(2,:);
    else
        btn.BackgroundColor = 0.8*ones(1,3);
    end
    % set line visuals
    set(SpectrumLines.Psd(:,2),'Visible',val)
    set(SpectrumLines.Pre(:,2),'Visible',val)
end
% Value changed function: FilteredButton
function FilteredButtonValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    plt = f.UserData;
    Acolor = plt.init.AnalysisColors;
    SpectrumLines = plt.SpectrumLines;
    btn = plt.FilteredButton;
    val = btn.Value;
    % set button visuals
    if val
        btn.BackgroundColor = Acolor(3,:);
    else
        btn.BackgroundColor = 0.8*ones(1,3);
    end
    % set line visuals
    set(SpectrumLines.Psd(:,3),'Visible',val)
    set(SpectrumLines.Pre(:,3),'Visible',val)
end
% Value changed function: CellSpinner
function CellSpinnerValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    UpdateSpectrumLines(f)
end