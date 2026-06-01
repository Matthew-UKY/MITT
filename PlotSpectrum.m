function PlotSpectrum(AllStruct,init)
%
% debug
%{
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
f.UserData.init = init;

% create ui-specific controls
f = PlotSpectrumControls(f);

% create the callback functions
f = CreateCallbacks(f);

% create the ui-specific axes
f.UserData.AllStruct = AllStruct;
f = PlotSpectrumAxes(f);

% initialize figure with user-supplied values
f = InitializeUI(f);

% create and update the line objects for each plot
CreateLines(f)
UpdateSpectrumLines(f)

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
    
    bh = 22; % button height
    grid = uigridlayout(plt.SignalPanel);
    grid.RowHeight = {'fit','fit',bh,'fit',bh,'fit',96};
    grid.ColumnWidth = {'1x'};
    grid.Padding = 0;
    grid.RowSpacing = 0;
    grid.ColumnSpacing = 0;

%   pwelch controls
    plt.PwelchSubpanel = uipanel(grid,Title='pwelch Parameters');
    grid1 = uigridlayout(plt.PwelchSubpanel);
    grid1.RowHeight = {'fit',bh,'fit',bh,'fit',bh};
    grid1.ColumnWidth = {'1x','2x','1x'};
    grid1.Padding = 5;
    grid1.RowSpacing = 5;
    grid1.ColumnSpacing = 5;

    plt.WindowDropdownLabel = uilabel(grid1,Text='Window Type');
    plt.WindowDropdownLabel.Layout.Row = 1;
    plt.WindowDropdownLabel.Layout.Column = [1,3];

    plt.WindowDropdown = uidropdown(grid1);
    plt.WindowDropdown.Layout.Row = 2;
    plt.WindowDropdown.Layout.Column = [1,3];

    plt.WindowEditboxLabel = uilabel(grid1,Text='Number of Segments');
    plt.WindowEditboxLabel.Layout.Row = 3;
    plt.WindowEditboxLabel.Layout.Column = [1,3];

    plt.WindowEditbox = uieditfield(grid1,'numeric');
    plt.WindowEditbox.Layout.Row = 4;
    plt.WindowEditbox.Layout.Column = 3;

    plt.WindowSlider = uislider(grid1);
    plt.WindowSlider.Layout.Row = 4;
    plt.WindowSlider.Layout.Column = [1,2];

    plt.NoverlapEditboxLabel = uilabel(grid1,Text='Percentage of Overlap');
    plt.NoverlapEditboxLabel.Layout.Row = 5;
    plt.NoverlapEditboxLabel.Layout.Column = [1,3];

    plt.NoverlapEditbox = uieditfield(grid1,'numeric');
    plt.NoverlapEditbox.Layout.Row = 6;
    plt.NoverlapEditbox.Layout.Column = 3;

    plt.NoverlapSlider = uislider(grid1);
    plt.NoverlapSlider.Layout.Row = 6;
    plt.NoverlapSlider.Layout.Column = [1,2];
        
%   pod controls
    plt.PodSubpanel = uipanel(grid,Title='pod Denoising Parameters');
    grid1 = uigridlayout(plt.PodSubpanel);
    grid1.RowHeight = {'fit',bh,'fit',bh};
    grid1.ColumnWidth = {'1x','2x','1x'};
    grid1.Padding = 5;
    grid1.RowSpacing = 5;
    grid1.ColumnSpacing = 5;

    plt.EnergyPercentageLabel = uilabel(grid1,Text='Percentage of signal energy');
    plt.EnergyPercentageLabel.Layout.Row = 1;
    plt.EnergyPercentageLabel.Layout.Column = [1,3];

    plt.EnergyPercentageEditbox = uieditfield(grid1,'numeric');
    plt.EnergyPercentageEditbox.Layout.Row = 2;
    plt.EnergyPercentageEditbox.Layout.Column = 3;

    plt.EnergyPercentageSlider = uislider(grid1);
    plt.EnergyPercentageSlider.Layout.Row = 2;
    plt.EnergyPercentageSlider.Layout.Column = [1,2];

    plt.PodSizeLabel = uilabel(grid1,Text='Change size of POD (row x col)');
    plt.PodSizeLabel.Layout.Row = 3;
    plt.PodSizeLabel.Layout.Column = [1,3];

    plt.PodRowEditbox = uieditfield(grid1,'numeric');
    plt.PodRowEditbox.Layout.Row = 4;
    plt.PodRowEditbox.Layout.Column = 1;

    plt.PodColEditbox = uieditfield(grid1,'numeric');
    plt.PodColEditbox.Layout.Row = 4;
    plt.PodColEditbox.Layout.Column = 3;

% reference line controls
    plt.ReferenceLineCheckbox = uicheckbox(grid,Text='ON/OFF Reference Lines');

    plt.ReferenceLineSubpanel = uipanel(grid,Title='Reference Line Parameters');
    grid1 = uigridlayout(plt.ReferenceLineSubpanel);
    grid1.RowHeight = {'fit',bh,'fit',bh};
    grid1.ColumnWidth = {'1x','2x','1x'};
    grid1.Padding = 5;
    grid1.RowSpacing = 5;
    grid1.ColumnSpacing = 5;

    plt.SlopeLabel = uilabel(grid1,Text='Change slope of reference lines');
    plt.SlopeLabel.Layout.Row = 1;
    plt.SlopeLabel.Layout.Column = [1,3];

    plt.SlopeEditbox = uieditfield(grid1,'numeric');
    plt.SlopeEditbox.Layout.Row = 2;
    plt.SlopeEditbox.Layout.Column = 3;

    plt.SlopeSlider = uislider(grid1);
    plt.SlopeSlider.Layout.Row = 2;
    plt.SlopeSlider.Layout.Column = [1,2];

    plt.TranslateLabel = uilabel(grid1,Text='Translate reference lines');
    plt.TranslateLabel.Layout.Row = 3;
    plt.TranslateLabel.Layout.Column = [1,3];

    plt.TranslateSlider = uislider(grid1);
    plt.TranslateSlider.Layout.Row = 4;
    plt.TranslateSlider.Layout.Column = [1,3];

% spectrum smoothing controls
    plt.SmoothingCheckbox = uicheckbox(grid,Text='ON/OFF Smoothing');

    plt.SmoothingSubpanel = uipanel(grid,Title='Smoothing Parameters');
    grid1 = uigridlayout(plt.SmoothingSubpanel);
    grid1.RowHeight = {'fit',bh,'fit',bh};
    grid1.ColumnWidth = {'1x','2x','1x'};
    grid1.Padding = 5;
    grid1.RowSpacing = 5;
    grid1.ColumnSpacing = 5;

    plt.SmoothWidthLabel = uilabel(grid1,Text='width of moving window 1');
    plt.SmoothWidthLabel.Layout.Row = 1;
    plt.SmoothWidthLabel.Layout.Column = [1,3];

    plt.SmoothWidthEditbox = uieditfield(grid1,'numeric');
    plt.SmoothWidthEditbox.Layout.Row = 2;
    plt.SmoothWidthEditbox.Layout.Column = 3;

    plt.SmoothWidthSlider = uislider(grid1);
    plt.SmoothWidthSlider.Layout.Row = 2;
    plt.SmoothWidthSlider.Layout.Column = [1,2];

    plt.SmoothPointLabel = uilabel(grid1,Text='# of points in moving window 2');
    plt.SmoothPointLabel.Layout.Row = 3;
    plt.SmoothPointLabel.Layout.Column = [1,3];

    plt.SmoothPointEditbox = uieditfield(grid1,'numeric');
    plt.SmoothPointEditbox.Layout.Row = 4;
    plt.SmoothPointEditbox.Layout.Column = 3;

    plt.SmoothPointSlider = uislider(grid1);
    plt.SmoothPointSlider.Layout.Row = 4;
    plt.SmoothPointSlider.Layout.Column = [1,2];

% switch independent variable controls
    plt.SwitchVarButtonGroup = uibuttongroup(grid);

    for i = 1:3
        plt.SwitchVarButton(i) = uiradiobutton(plt.SwitchVarButtonGroup);
        plt.SwitchVarButton(i).Position = [10 60-25*(i-1) 91 22];
    end

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
% smoothing callbacks
    plt.SmoothingCheckbox.ValueChangedFcn = @UpdateVisibility;
    plt.SmoothWidthEditbox.ValueChangedFcn = @SmoothWidthEditboxValueChanged;
    plt.SmoothWidthSlider.ValueChangedFcn = @SmoothWidthSliderValueChanged;
    plt.SmoothPointEditbox.ValueChangedFcn = @SmoothPointEditboxValueChanged;
    plt.SmoothPointSlider.ValueChangedFcn = @SmoothPointSliderValueChanged;
% reference line callbacks
    plt.ReferenceLineCheckbox.ValueChangedFcn = @UpdateVisibility;
    plt.SlopeEditbox.ValueChangedFcn = @SlopeEditboxValueChanged;
    plt.SlopeSlider.ValueChangingFcn = @SlopeSliderValueChanging;
    plt.TranslateSlider.ValueChangingFcn = @TranslateSliderValueChanging;
% switch independent variable callbacks
    plt.SwitchVarButtonGroup.SelectionChangedFcn = @SwitchVarSelectionChanged;

% data callbacks
    plt.FilenameListbox.ValueChangedFcn = @FilenameValueChanged;
    plt.VelButton.ValueChangedFcn = @UpdateVisibility;
    plt.DespikedButton.ValueChangedFcn = @UpdateVisibility;
    plt.FilteredButton.ValueChangedFcn = @UpdateVisibility;
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
            YScale = 'linear');
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

% initialize the inputs to plotting functions in the Config structs
nFiles = length(plt.AllStruct);
for i = 1:nFiles
    Config = plt.AllStruct(i).Config;
    Config.Spectrum = struct();
    % Use a hanning window
    Config.Spectrum.winType = 'hanning';
    Config.Spectrum.N = Config.ntimetot;
    % Assumption that the mean stabilizes in 1 minute
    Config.Spectrum.nSegments = round(Config.ntimetot/Config.Hz/60);
    Config.Spectrum.overlapPercentage = 0;
    Config.Spectrum.energyPercentage = 0.8;
    % Assume square POD matrix
    N = Config.ntimetot;
    rows = floor(sqrt(N));
    cols = floor(N/rows);
    Config.Spectrum.nRows = rows;
    Config.Spectrum.nCols = cols;

    Config.Smooth = struct();
    Config.Smooth.pointMethod = 'movmedian'; % add dropdown
    Config.Smooth.nPoints = 7;
    Config.Smooth.widthMethod = 'gaussian'; % add dropdown
    Config.Smooth.percentWidth = 0.01;

    Config.Reflines = struct();
    Config.Reflines.slope = -5/3;
    Config.Reflines.translate = 0;

    plt.AllStruct(i).Config = Config;
end

% initialize the ui to display the 1st file
Config = plt.AllStruct(1).Config;

% Initialize window controls
    plt.WindowDropdown.Items = {'hamming','hanning','rectangular'};
    plt.WindowDropdown.Value = Config.Spectrum.winType;
    minVal = 1;
    maxVal = MaxSegments(Config); 
    nSegments = Config.Spectrum.nSegments;
    plt.WindowEditbox.Limits = [minVal,maxVal];
    plt.WindowEditbox.Value = nSegments;
    plt.WindowSlider.Limits = [minVal,maxVal];
    plt.WindowSlider.Value = nSegments;
    plt.WindowSlider.MajorTicks = [minVal,5:5:maxVal,maxVal];
    plt.WindowSlider.MinorTicks = minVal:maxVal;
% Initialize noverlap controls
    minVal = 0;
    maxVal = 0.90;
    novDefault = Config.Spectrum.overlapPercentage;
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
    energyDefault = Config.Spectrum.energyPercentage;
    plt.EnergyPercentageEditbox.Limits = [minVal,maxVal];
    plt.EnergyPercentageEditbox.Value = energyDefault;
    plt.EnergyPercentageSlider.Limits = [minVal,maxVal];
    plt.EnergyPercentageSlider.Value = energyDefault;
    plt.EnergyPercentageSlider.MajorTicks = minVal:0.25:maxVal;
    plt.EnergyPercentageSlider.MajorTickLabels = string(minVal:0.25:maxVal);
    plt.EnergyPercentageSlider.MinorTicks = minVal:0.05:maxVal;
    plt.PodRowEditbox.Value = Config.Spectrum.nRows;
    plt.PodColEditbox.Value = Config.Spectrum.nCols;
% initialize smoothing controls
    minVal = 0;
    maxVal = 1;
    defaultWidth = Config.Smooth.percentWidth;
    plt.SmoothWidthEditbox.Limits = [minVal,maxVal];
    plt.SmoothWidthEditbox.Value = defaultWidth;
    plt.SmoothWidthSlider.Limits = [minVal,maxVal];
    plt.SmoothWidthSlider.Value = defaultWidth;
    minVal = 1;
    maxVal = 20; % arbitrary
    defaultPoints = Config.Smooth.nPoints;
    plt.SmoothPointEditbox.Limits = [minVal,maxVal];
    plt.SmoothPointEditbox.Value = defaultPoints;
    plt.SmoothPointSlider.Limits = [minVal,maxVal];
    plt.SmoothPointSlider.Value = defaultPoints;
% initialize reference line controls
    minVal = -3;
    maxVal = 0;
    defaultSlope = Config.Reflines.slope;
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
% initialize independent variable switch
    plt.SwitchVarButton(1).Text = 'Frequency';
    plt.SwitchVarButton(2).Text = 'Wavenumber';
    plt.SwitchVarButton(3).Text = 'Wavelength';

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

f.UserData = plt;
end
% create empty containers for each of the lines in each plot
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

    % smoothed lines
    SmoothLines = struct();
    SmoothLines.Psd = gobjects(nComp,nAnalysis);
    SmoothLines.Pre = gobjects(nComp,nAnalysis);

    % slope reference line struct
    ReferenceLines = struct();
    nRef = 21; % estimate of max # of lines needed for plotting
    ReferenceLines.LineDensity = 9; % number of lines shown on screen
    ReferenceLines.Psd = gobjects(nComp,nRef);
    ReferenceLines.Pre = gobjects(nComp,nRef);

    for i = 1:nComp
        for j = 1:nAnalysis
            % plot dummy lines as containers for spectrum data
            SpectrumLines.Psd(i,j) = plot(ax(i).Psd,1,1);
            SpectrumLines.Pre(i,j) = plot(ax(i).Pre,1,1);
            % dummy lines for smoothed spectra
            SmoothLines.Psd(i,j) = plot(ax(i).Psd,[1,1],[1,1],'-k');
            SmoothLines.Pre(i,j) = plot(ax(i).Pre,[1,1],[1,1],'-k');
        end
        for k = 1:nRef
            % dummy lines for reference line data
            ReferenceLines.Psd(i,k) = plot(ax(i).Psd,[1,1],[1,1],'--',Color=0.8*ones(1,3));
            ReferenceLines.Pre(i,k) = plot(ax(i).Pre,[1,1],[1,1],'--',Color=0.8*ones(1,3));
        end
    end

plt.SpectrumLines = SpectrumLines;
plt.SmoothLines = SmoothLines;
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
SmoothLines = plt.SmoothLines;
Config = GetInputs(plt,Config);

% config variables
    comp = Config.comp;
    nComp = length(comp);
    yAnalysis = [true,Config.Despiked,Config.Filtered];
    Anames = {'Vel','Despiked','Filtered'};
    Anames = Anames(yAnalysis);
    Acolor = plt.init.AnalysisColors;
    nAnalysis = length(Anames);
    blackshift = 2;
    smoothColor = Acolor/blackshift;

% inputs to the pwelch function
    fs = Config.Hz;
    window = CreateWindow(Config.Spectrum);
    noverlap = CreateNoverlap(Config.Spectrum);

    varbg = f.UserData.SwitchVarButtonGroup;
    varbuttons = varbg.Buttons;
    yVar = [varbuttons.Value];
    yVar = yVar(:); % ensure col vector

    oldLength = length(SpectrumLines.Psd(1,1).XData);
% calculations and plotting
    for i = 1:nComp
        for j = 1:nAnalysis
            convectionVelocity = abs(mean(Data.(Anames{j}).u(:,ncell)));
            % use POD/pwelch to create a denoised spectrum of the data
            signal = Data.(Anames{j}).(comp{i})(:,ncell);
            signal = PodDenoiseSignal(signal,Config.Spectrum);
            [psd,freq] = pwelch(signal,window,noverlap,[],fs);
            power = freq .* psd;
            powerAxes = [ax.Pre];
            indvarLabels = [powerAxes.XLabel];
            if yVar(1) % frequency
                indvar = freq;
                label = 'Frequency (Hz)';
            elseif yVar(2) % wavenumber
                indvar = 2*pi*freq/convectionVelocity;
                label = 'Wavenumber (1/m)';
            elseif yVar(3) % wavelength
                indvar = convectionVelocity./freq;
                label = 'Wavelength (m)';
            end
            set(indvarLabels,'String',label)
            psd = power./indvar;
            % sort independent variable so it's in ascending order
            [indvar,sortIndx] = sort(indvar);
            psd = psd(sortIndx);
            power = power(sortIndx);
            % pre-multiplied and smoothing calcs
            smoothPsd = SmoothSignal(psd,indvar,Config.Smooth);
            smoothPower = indvar .* smoothPsd;
            newLength = length(psd);
            if newLength ~= oldLength
                delete(SpectrumLines.Psd(i,j))
                delete(SpectrumLines.Pre(i,j))
                delete(SmoothLines.Psd(i,j))
                delete(SmoothLines.Pre(i,j))
                SpectrumLines.Psd(i,j) = plot(ax(i).Psd,indvar,psd,Color=Acolor(j,:));
                SpectrumLines.Pre(i,j) = plot(ax(i).Pre,indvar,power,Color=Acolor(j,:));
                SmoothLines.Psd(i,j) = plot(ax(i).Psd,indvar,smoothPsd,Color=smoothColor(j,:));
                SmoothLines.Pre(i,j) = plot(ax(i).Pre,indvar,smoothPower,Color=smoothColor(j,:));
            else
                SpectrumLines.Psd(i,j).XData = indvar;
                SpectrumLines.Psd(i,j).YData = psd;
                SpectrumLines.Pre(i,j).XData = indvar;
                SpectrumLines.Pre(i,j).YData = power;
                SmoothLines.Psd(i,j).XData = indvar;
                SmoothLines.Psd(i,j).YData = smoothPsd;
                SmoothLines.Pre(i,j).XData = indvar;
                SmoothLines.Pre(i,j).YData = smoothPower;
            end
        end
    end
% save data to figure
plt.SpectrumLines = SpectrumLines;
plt.SmoothLines = SmoothLines;
f.UserData = plt;

% update the visibility of lines
UpdateVisibility(f)

% update the reference lines to match new y limits
UpdateReferenceLines(f)
end
% smoothly update the reference lines
function UpdateReferenceLines(f)
plt = f.UserData;
ax = plt.ax;
nfile = plt.FilenameListbox.ValueIndex;
Config = plt.AllStruct(nfile).Config;
ReferenceLines = plt.ReferenceLines;
slope = Config.Reflines.slope;
translate = Config.Reflines.translate;
lineDensity = ReferenceLines.LineDensity;

% Psd axes
xlims = ax(1).Psd.XLim;
ylims = ax(1).Psd.YLim;
lineSpacing = log10(ylims(2)/ylims(1))/lineDensity;

nRef = length(ReferenceLines.Psd);
lines = ReferenceLines.Psd(:,1);
[xdata,ydata] = PsdReflineData(xlims,ylims,slope,translate,0);
set(lines,'XData',xdata)
set(lines,'YData',ydata)
for i = 1:(nRef-1)/2
    % positive offset lines
    lines = ReferenceLines.Psd(:,2*i);
    [xdata,ydata,inBounds] = PsdReflineData(xlims,ylims,slope,translate,i*lineSpacing);
    if inBounds
        set(lines,'XData',xdata)
        set(lines,'YData',ydata)
    else
        set(lines,'XData',[])
        set(lines,'YData',[])
    end
    % negative offset lines
    lines = ReferenceLines.Psd(:,2*i+1);
    [xdata,ydata,inBounds] = PsdReflineData(xlims,ylims,slope,translate,-i*lineSpacing);
    if inBounds
        set(lines,'XData',xdata)
        set(lines,'YData',ydata)
    else
        set(lines,'XData',[])
        set(lines,'YData',[])
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
% smooth the signal in logscale and then go back to linscale
function ydataSmooth = SmoothSignal(ydata,xdata,userInput)
% go to logscale
logX = log10(xdata);
logY = log10(ydata);
% remove Inf and NaN
yBad = isinf(logX) | isinf(logY) | isnan(logX) | isnan(logY);
logX = logX(~yBad);
logY = logY(~yBad);
% smooth using fixed-width window and an n-point window with given method
pointMethod = userInput.pointMethod;
nPoints = userInput.nPoints;
widthMethod = userInput.widthMethod;
percentWidth = userInput.percentWidth;
windowWidth = (percentWidth)*range(logY);
ydataSmooth = smoothdata(logY,pointMethod,nPoints);
ydataSmooth = smoothdata(ydataSmooth,widthMethod,windowWidth,SamplePoints=logX);
% return to linscale
ydataSmooth = 10.^ydataSmooth;
% add back in the values that became nan/inf when going to logscale
temp = ydataSmooth;
ydataSmooth = zeros(size(ydata));
ydataSmooth(yBad) = ydata(yBad);
ydataSmooth(~yBad) = temp;
end
% find limits of data, where limits are the closest round #'s to extremes
function [lower,upper] = CreateLimits(dat)
    % pre-processing for log axes
    logiKeep = ~isinf(dat) & ~isnan(dat) & dat > 0;
    dat = dat(logiKeep);

lower = min(dat);
lowerSign = sign(lower);
lower = abs(lower);
if lower ~= 0
    exponent = floor(log10(lower));
    mantissa = lower/10^exponent;
    lower = floor(lowerSign*mantissa)*10^exponent;
end

upper = max(dat);
upperSign = sign(upper);
upper = abs(upper);
if upper ~= 0
    exponent = floor(log10(upper));
    mantissa = upper/10^exponent;
    upper = ceil(upperSign*mantissa)*10^exponent;
end
end
% get inputs from the GUI and save in Config
function Config = GetInputs(plt,Config)
sp = Config.Spectrum;
sp.winType = plt.WindowDropdown.Value;
sp.N = Config.ntimetot;
sp.nSegments = plt.WindowEditbox.Value;
sp.overlapPercentage = plt.NoverlapEditbox.Value;
sp.energyPercentage = plt.EnergyPercentageEditbox.Value;
sp.nRows = plt.PodRowEditbox.Value;
sp.nCols = plt.PodColEditbox.Value;
Config.Spectrum = sp;

sm = Config.Smooth;
sm.pointMethod;
sm.nPoints = plt.SmoothPointEditbox.Value;
sm.widthMethod;
sm.percentWidth = plt.SmoothWidthEditbox.Value;
Config.Smooth = sm;
end
% xdata and ydata are found at the borders of the view window defined by
% xlims and ylims
function [xdata,ydata,inBounds] = PsdReflineData(xlims,ylims,slope,translate,lineSpacing)
% find geometric mean for midpoint in logspace
x0 = sqrt(xlims(1)*xlims(2));
y0 = sqrt(ylims(1)*ylims(2));

% create the four possible points of intersection
xdata = zeros(4,1);
ydata = xdata;
% (xlim(1),y) and (xlim(2),y)
for i = 1:2
    xdata(i) = xlims(i);
    ydata(i) = y0*(xdata(i)/x0).^slope;
    ydata(i) = ydata(i) * 10^(lineSpacing*sqrt(1+slope^2));
    ydata(i) = ydata(i) * 10^translate;
end
% (x,ylim(1)) and (x,ylim(2))
for i = 3:4
    ydata(i) = ylims(i-2);
    xdata(i) = ydata(i) / 10^translate;
    xdata(i) = xdata(i) / 10^(lineSpacing*sqrt(1+slope^2));
    xdata(i) = x0 * (xdata(i) / y0).^(1/slope);
end

% check that the x- and y-coordinates fall within the viewing rectangle
logiX = (xdata - xlims(1) >= 0) & (xlims(2) - xdata >= 0);
logiY = (ydata - ylims(1) >= 0) & (ylims(2) - ydata >= 0);
inBounds = logiX & logiY;

xdata = xdata(inBounds);
ydata = ydata(inBounds);
inBounds = any(inBounds); % if any are in bounds, allow program through

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
    f.UserData.SlopeSlider.Value = event.Value;
    nfile = f.UserData.FilenameListbox.ValueIndex;
    Config = f.UserData.AllStruct(nfile).Config;
    Config.Reflines.slope = event.Value;
    f.UserData.AllStruct(nfile).Config = Config;
    UpdateReferenceLines(f)
end
% Value changing function: SlopeSlider
function SlopeSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.SlopeEditbox.Value = event.Value;
    nfile = f.UserData.FilenameListbox.ValueIndex;
    Config = f.UserData.AllStruct(nfile).Config;
    Config.Reflines.slope = event.Value;
    f.UserData.AllStruct(nfile).Config = Config;
    UpdateReferenceLines(f)
end
% Value changing function: TranslateSlider
function TranslateSliderValueChanging(src,event)
    f = ancestor(src,'figure','toplevel');
    nfile = f.UserData.FilenameListbox.ValueIndex;
    Config = f.UserData.AllStruct(nfile).Config;
    Config.Reflines.translate = event.Value;
    f.UserData.AllStruct(nfile).Config = Config;
    UpdateReferenceLines(f)
end
% Value changed function: SmoothWidthEditbox
function SmoothWidthEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.SmoothWidthSlider.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changed function: SmoothWidthSlider
function SmoothWidthSliderValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.SmoothWidthEditbox.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changed function: SmoothPointEditbox
function SmoothPointEditboxValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.SmoothPointSlider.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Value changed function: SmoothPointSlider
function SmoothPointSliderValueChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    f.UserData.SmoothPointEditbox.Value = event.Value;
    UpdateSpectrumLines(f)
end
% Selection changed function: SwitchVarButtonGroup
function SwitchVarSelectionChanged(src,event)
    f = ancestor(src,'figure','toplevel');
    UpdateSpectrumLines(f)
end

% Value changed function: FilenameListbox
function FilenameValueChanged(src,event)
f = ancestor(src,'figure','toplevel');
plt = f.UserData;
AllStruct = plt.AllStruct;
% get the Config struct from the new file
nfile = event.ValueIndex;
Config = AllStruct(nfile).Config;
% window slider/editbox limits/values
    minVal = 1;
    maxVal = MaxSegments(Config);
    newVal = Config.Spectrum.nSegments;
    plt.WindowEditbox.Limits = [minVal,maxVal];
    plt.WindowEditbox.Value = newVal;
    plt.WindowSlider.Limits = [minVal,maxVal];
    plt.WindowSlider.Value = newVal;
    plt.WindowSlider.MajorTicks = [minVal,5:5:maxVal,maxVal];
    plt.WindowSlider.MinorTicks = minVal:maxVal;
% noverlap slider/editbox values
    newVal = Config.Spectrum.overlapPercentage;
    plt.NoverlapEditbox.Value = newVal;
    plt.NoverlapSlider.Value = newVal;
% POD energy slider/editbox values
    newVal= Config.Spectrum.energyPercentage;
    plt.EnergyPercentageEditbox.Value = newVal;
    plt.EnergyPercentageSlider.Value = newVal;
% change nrows/ncols
    plt.PodRowEditbox.Value = Config.Spectrum.nRows;
    plt.PodColEditbox.Value = Config.Spectrum.nCols;
% smoothing parameters
    plt.SmoothWidthEditbox.Value = Config.Smooth.percentWidth;
    plt.SmoothWidthSlider.Value = Config.Smooth.percentWidth;
    plt.SmoothPointEditbox.Value = Config.Smooth.nPoints;
    plt.SmoothPointSlider.Value = Config.Smooth.nPoints;
% refline parameters
    plt.SlopeEditbox.Value = Config.Reflines.slope;
    plt.SlopeSlider.Value = Config.Reflines.slope;
    plt.TranslateSlider.Value = Config.Reflines.translate;
% change signal info for new file
    signalInfo = GetSignalInfo(Config);
    plt.SignalTable.Data = signalInfo;

f.UserData = plt;
UpdateSpectrumLines(f)
end
% update velocity button type visibility and y limits
function UpdateVisibility(src,~)
f = ancestor(src,'figure','toplevel');
plt = f.UserData;
ax = plt.ax;
SpectrumLines = plt.SpectrumLines;
SmoothLines = plt.SmoothLines;
ReferenceLines = plt.ReferenceLines;
init = plt.init;
Acolor = init.AnalysisColors;
btn = [plt.VelButton,plt.DespikedButton,plt.FilteredButton];
logi = [btn.Value];
showSmooth = plt.SmoothingCheckbox.Value;
plt.SmoothingSubpanel.Visible = showSmooth;
graphType = {'Psd','Pre'};
    for g = 1:length(graphType)
        % set button and line visuals
        for b = 1:length(btn)
            if logi(b)
                btn(b).BackgroundColor = Acolor(b,:);
                set(SpectrumLines.(graphType{g})(:,b),'Visible','on')
                set(SmoothLines.(graphType{g})(:,b),'Visible',showSmooth)
            else
                btn(b).BackgroundColor = 0.8*ones(1,3);
                set(SpectrumLines.(graphType{g})(:,b),'Visible','off')
                set(SmoothLines.(graphType{g})(:,b),'Visible','off')
            end
        end
        % create and set x- and y-limits, where the components are linked
        Lines = SpectrumLines.(graphType{g});
        [nComp,nAnalysis] = size(Lines);
        dataType = ["XData","YData"];
        nType = length(dataType);
        lower = zeros(nComp,nAnalysis,nType);
        upper = lower; % initialize upper and lower limits
        for i = 1:nComp
            for j = 1:nAnalysis
                for k = 1:2
                    [lower(i,j,k),upper(i,j,k)] = CreateLimits(Lines(i,j).(dataType(k)));
                end
            end
        end
        % take min/max across comp dimension
        lower = min(lower);
        lower = permute(lower,[2,3,1]); % rmv singleton
        upper = max(upper);
        upper = permute(upper,[2,3,1]); % rmv singleton
        % get rid of the analyses that aren't shown
        lower = lower(logi,:);
        upper = upper(logi,:);
        % find absolute min/max over the analyses that are shown
        lower = min(lower,[],1);
        upper = max(upper,[],1); 
        % create xlims and ylims
        xlims(1) = lower(1);
        xlims(2) = upper(1);
        ylims(1) = lower(2);
        ylims(2) = upper(2);
        % set limits onto the lines
        ax(1).(graphType{g}).XLim = xlims;
        ax(1).(graphType{g}).YLim = ylims;

        % update reference line visibility
        val = plt.ReferenceLineCheckbox.Value;
        plt.ReferenceLineSubpanel.Visible = val;
        set([ReferenceLines.(graphType{g})],'Visible',val)
    end
end
% Value changed function: CellSpinner
function CellSpinnerValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    UpdateSpectrumLines(f)
end