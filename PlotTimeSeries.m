function PlotTimeSeries(AllStruct,init)

% create the default figure
f = VisualizeUIFigure;
f.UserData.AllStruct = AllStruct;
f.UserData.init = init;

% create PlotTimeSeries control panel
f = PlotTimeSeriesControls(f);

% initialize it with user-supplied values
f = InitializeUI(f);

% create the callback functions
f = CreateCallbacks(f);

% send to UpdatePlots
UpdatePlots(f)
end


%% ui creation functions
% create controls for plottimeseries
function f = PlotTimeSeriesControls(f)
plt = f.UserData;
Data = plt.AllStruct(1).Data;
Config = plt.AllStruct(1).Config;

    plt.PlotPanel = uipanel(plt.grid,Title='Plotting Controls');
    plt.PlotPanel.Layout.Column = 3;
    plt.PlotPanel.Layout.Row = 1;
    
    grid = uigridlayout(plt.PlotPanel);
    grid.RowHeight = {'fit','1x'};
    grid.ColumnWidth = {'1x'};

    % switch from XYZ to Beam toggleswitch
    plt.switchCoordinates = uiswitch(grid);
    plt.switchCoordinates.Items = {'XYZ','Beam'};
    switch Config.coordSystem % set initial coord-system
        case 1
            plt.switchCoordinates.Value = 'XYZ';
        case 2
            plt.switchCoordinates.Value = 'Beam';
    end

    nComp = length(Config.comp);
    grid = uigridlayout(plt.AxesPanel,[4,1]);
    grid.ColumnSpacing = 0;
    grid.RowSpacing = 0;
    grid.Padding = 0;
    ax = struct;
    for i = 1:nComp
        p = uipanel(grid);
        p.BorderType = 'none';
        t = tiledlayout(p,5,5);
        t.Padding = 'none';
        t.TileSpacing = 'tight';
        if isfield(Data,'Cor')
            ax(i).Cor = nexttile(t,1,[1,4]);
            ax(i).Cor.NextPlot = 'add';
            ax(i).Cor.XTick = [];
            ax(i).Cor.YLim = [0,100];
            ax(i).Time = nexttile(t,6,[4,4]);
            ax(i).Time.NextPlot = 'add';
            ax(i).Box = nexttile(t,5,[5,1]);
            ax(i).Box.NextPlot = 'add';
        else
            % add code for other instruments
        end
    end
plt.ax = ax;
f.UserData = plt;
end
% initialize the ui
function f = InitializeUI(f)
plt = f.UserData;
init = plt.init;
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
end
% create callback functions
function f = CreateCallbacks(f)
    plt = f.UserData;
    plt.FilenameListbox.ValueChangedFcn = @FilenameValueChanged;
    plt.VelButton.ValueChangedFcn = @VelButtonValueChanged;
    plt.DespikedButton.ValueChangedFcn = @DespikedButtonValueChanged;
    plt.FilteredButton.ValueChangedFcn = @FilteredButtonValueChanged;
    plt.CellSpinner.ValueChangedFcn = @CellSpinnerValueChanged;

    plt.switchCoordinates.ValueChangedFcn = @SwitchCoordinatesChanged;
end

%% plotting functions
% update plots from user input
function UpdatePlots(f)
plt = f.UserData;
ax = plt.ax;
nfile = plt.FilenameListbox.ValueIndex;
ncell = plt.CellSpinner.Value;
Data = plt.AllStruct(nfile).Data;
Config = plt.AllStruct(nfile).Config;
switch Config.coordSystem
    case 1
        originalCoord = 'XYZ';
    case 2
        originalCoord = 'Beam';
end
newCoord = plt.switchCoordinates.Value;
init = plt.init;
    comp = Config.comp;
    nComp = length(comp);
    yAnalysis = [true,Config.Despiked,Config.Filtered];
    Anames = {'Vel','Despiked','Filtered'};
    Anames = Anames(yAnalysis);
    Acolor = init.AnalysisColors;
    Acolor = Acolor(yAnalysis,:);
    nAnalysis = length(Anames);

    time = Data.timeStamp;

    if ~strcmp(originalCoord,newCoord)
        if isfield(Config, 'beam2XYZMatrix')
            % reshape the transformation matrix
            transMatrix = reshape(Config.beam2XYZMatrix(ncell,:),4,4)';
            % change to other coordinate system
            for j = 1:nAnalysis
                raw = Data.(Anames{j});
                rawMulti = ConvStruct2Multi(raw,Config.comp);
                rawMulti = squeeze(rawMulti(:,ncell,:));
                % convert to right coordinates
                if strcmp(originalCoord,'XYZ')
                    rawMulti = ConvXYZ2Beam(rawMulti,transMatrix,1);
                elseif strcmp(originalCoord,'Beam')
                    rawMulti = ConvXYZ2Beam(rawMulti,transMatrix,2);
                end
                for i = 1:nComp
                    Data.(Anames{j}).(comp{i})(:,ncell) = rawMulti(:,i);
                end
            end
        else
            plt.coordSystem.Value = originalCoord;
            msgbox('No beam2XYZ matrix specified!')
        end
    end

    for i = 1:nComp
        cla(ax(i).Cor)
        cla(ax(i).Time)
        cla(ax(i).Box)
        ax(i).Time.ColorOrder = Acolor;
        ax(i).Box.ColorOrder = Acolor;
        if isfield(ax,'Cor')
            beam = strcat('Beam',num2str(i));
            cor = Data.Cor.(beam)(:,ncell);
            plot(ax(i).Cor,time,cor,Color=[254,153,0]/255); % orange
            yline(ax(i).Cor,70,'--k') % 70% correlation threshold
        end
        dat = zeros(Config.ntimetot,nAnalysis);
        xgroup = cell(size(dat));
        for j = 1:nAnalysis
            dat(:,j) = Data.(Anames{j}).(comp{i})(:,ncell);
            xgroup(:,j) = repmat(Anames(j),[length(dat),1]);
        end
        p = plot(ax(i).Time,time,dat);
        dat = dat(:);
        xgroup = xgroup(:);
        xgroup = categorical(xgroup,Anames);
        b = boxchart(ax(i).Box,xgroup,dat,...
            GroupByColor = xgroup,...
            JitterOutliers = 'on',...
            MarkerStyle = '.');
        for j = 1:nAnalysis
            p(j).Tag = Anames{j};
            b(j).Tag = Anames{j};
        end
    end
VelButtonValueChanged(plt.VelButton,plt.VelButton)
DespikedButtonValueChanged(plt.DespikedButton,plt.DespikedButton)
FilteredButtonValueChanged(plt.FilteredButton,plt.FilteredButton)
end

%% Callbacks
% Value changed function: FilenameListbox
function FilenameValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    UpdatePlots(f)
end
% Value changed function: VelButton
function VelButtonValueChanged(src, event)
    f = ancestor(src,'figure','toplevel');
    plt = f.UserData;
    ax = plt.ax;
    Config = plt.AllStruct(1).Config;
    Acolor = plt.init.AnalysisColors;
    val = event.Value;
    if val
        src.BackgroundColor = Acolor(1,:);
    else
        src.BackgroundColor = 0.8*ones(1,3);
    end
    for i = 1:length(Config.comp)
        lines = get(ax(i).Time,'Children');
        boxes = get(ax(i).Box,'Children');
        for j = 1:length(lines)
            if strcmp(lines(j).Tag,'Vel')
                lines(j).Visible = val;
            end
            if strcmp(boxes(j).Tag,'Vel')
                boxes(j).Visible = val;
            end
        end
    end
end
% Value changed function: DespikedButton
function DespikedButtonValueChanged(src, event)
    f = ancestor(src,'figure','toplevel');
    plt = f.UserData;
    ax = plt.ax;
    Config = plt.AllStruct(1).Config;
    Acolor = plt.init.AnalysisColors;
    val = event.Value;
    if val
        src.BackgroundColor = Acolor(2,:);
    else
        src.BackgroundColor = 0.8*ones(1,3);
    end
    for i = 1:length(Config.comp)
        lines = get(ax(i).Time,'Children');
        boxes = get(ax(i).Box,'Children');
        for j = 1:length(lines)
            if strcmp(lines(j).Tag,'Despiked')
                lines(j).Visible = val;
            end
            if strcmp(boxes(j).Tag,'Despiked')
                boxes(j).Visible = val;
            end
        end
    end
end
% Value changed function: FilteredButton
function FilteredButtonValueChanged(src, event)
    f = ancestor(src,'figure','toplevel');
    plt = f.UserData;
    ax = plt.ax;
    Config = plt.AllStruct(1).Config;
    Acolor = plt.init.AnalysisColors;
    val = event.Value;
    if val
        src.BackgroundColor = Acolor(3,:);
    else
        src.BackgroundColor = 0.8*ones(1,3);
    end
    for i = 1:length(Config.comp)
        lines = get(ax(i).Time,'Children');
        boxes = get(ax(i).Box,'Children');
        for j = 1:length(lines)
            if strcmp(lines(j).Tag,'Filtered')
                lines(j).Visible = val;
            end
            if strcmp(boxes(j).Tag,'Filtered')
                boxes(j).Visible = val;
            end
        end
    end
end
% Value changed function: CellSpinner
function CellSpinnerValueChanged(src, ~)
    f = ancestor(src,'figure','toplevel');
    UpdatePlots(f)
end
% Value changed function: switchCoordinates
function SwitchCoordinatesChanged(src,~)
    f = ancestor(src,'figure','toplevel');
    UpdatePlots(f)
end