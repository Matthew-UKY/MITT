function PlotTimeSeries(AllStruct)
f = createComponents;

% determine number of analyses
Anames = {'Vel','Despiked','Filtered'};
yAnalysis = [true,Config.Despiked,Config.Filtered];
Anames = Anames(yAnalysis);
leg = Anames; % legend names
nAtot = length(Anames);

% determine number of components 
ncomptot = length(Config.comp);

% create a multidimensional array in 4D with rows, columns, sheets and volumes 
% as time intervals, cells, components, and analyses
Pdata = zeros(Config.ntimetot,Config.nCells,ncomptot,nAtot);

%% get other analyses and save in Pdata
% for each analysis
for nA = 1:nAtot
    % convert structure to multidimensional array format
    Pdata(:,:,:,nA) = ConvStruct2Multi(Data.(Anames{nA}),Config.comp);
end

%% get correlation data
% determine if correlation data is available
CORy = isfield(Data,'Cor');
if CORy
    % create a string with field names
    compstr = {'Beam1','Beam2','Beam3','Beam4'};
    COR = ConvStruct2Multi(Data.Cor,compstr);
else
    COR = [];
end

%% send data to plotting algorithm Plot1Series
% reshape Pdata for plotting
if length(size(Pdata))==4
    Pdata = permute(Pdata,[1 4 3 2]); 
end

% if a list of values were sent in nCellmem, then only those cellnumbers
% will be plotted, otherwise all cells will be plotted
if isempty(nCellmem)
    nCellmem = 1:Config.nCells;
end

% for each cell
for nCell = nCellmem
    % isolate the correct correlation data
    if ~isempty(COR)
        CORi = squeeze(COR(:,nCell,:));
    else
        CORi = COR;
    end
    % set title for figure
    titover = [Config.CSVControlpathname,' ',Config.filename,' nCell = ',num2str(nCell)];
    % send to Plot1Series
    Plot1Series(Pdata(:,:,:,nCell),CORi,titover,Config.Hz,Config.comp,leg)
    % 
    pause(2);
end

end

% Create UIFigure and components
function f = createComponents()

    % Create UIFigure and hide until all components are created
    f = uifigure('Visible', 'off');
    f.AutoResizeChildren = 'off';
    colormap(f, 'jet');
    f.Position = [100 100 640 480];
    f.Name = 'Default uifigure';
    f.WindowState = 'maximized';

    % store all ui elements in one struct
    plt = struct();

    % Create GridLayout
    plt.grid = uigridlayout(f);
    plt.grid.ColumnWidth = {100,'1x',100};
    plt.grid.RowHeight = {'1x'};
    plt.grid.ColumnSpacing = 0;
    plt.grid.RowSpacing = 0;
    plt.grid.Padding = [0 0 0 0];
    plt.grid.Scrollable = 'on';

    % Create ControlPanel
    plt.ControlPanel = uipanel(plt.grid);
    plt.ControlPanel.Title = 'Control Panel';
    plt.ControlPanel.Layout.Row = 1;
    plt.ControlPanel.Layout.Column = 1;

    % Create GridLayout2
    plt.grid2 = uigridlayout(plt.ControlPanel);
    plt.grid2.ColumnWidth = {75};
    plt.grid2.RowHeight = {'fit', '1x', 'fit', 25, 25, 25, 'fit', 25};
    plt.grid2.ColumnSpacing = 5;
    plt.grid2.RowSpacing = 5;
    plt.grid2.Padding = [5 5 5 5];

    % Create FilenameLabel
    plt.FilenameLabel = uilabel(plt.grid2);
    plt.FilenameLabel.HorizontalAlignment = 'center';
    plt.FilenameLabel.Layout.Row = 1;
    plt.FilenameLabel.Layout.Column = 1;
    plt.FilenameLabel.Text = 'Filename';

    % Create FilenameListbox
    plt.FilenameListbox = uilistbox(plt.grid2);
    plt.FilenameListbox.Layout.Row = 2;
    plt.FilenameListbox.Layout.Column = 1;
    plt.FilenameListbox.ValueChangedFcn = @FilenameValueChanged;

    % Create AnalysisLabel
    plt.AnalysisLabel = uilabel(plt.grid2);
    plt.AnalysisLabel.HorizontalAlignment = 'center';
    plt.AnalysisLabel.Layout.Row = 3;
    plt.AnalysisLabel.Layout.Column = 1;
    plt.AnalysisLabel.Text = 'Analysis';

    % Create VelButton
    plt.VelButton = uibutton(plt.grid2, 'state');
    plt.VelButton.Text = 'Vel';
    plt.VelButton.Layout.Row = 4;
    plt.VelButton.Layout.Column = 1;
    plt.VelButton.ValueChangedFcn = @VelButtonValueChanged;

    % Create DespikedButton
    plt.DespikedButton = uibutton(plt.grid2, 'state');
    plt.DespikedButton.Text = 'Despiked';
    plt.DespikedButton.Layout.Row = 5;
    plt.DespikedButton.Layout.Column = 1;
    plt.DespikedButton.ValueChangedFcn = @DespikedButtonValueChanged;

    % Create FilteredButton
    plt.FilteredButton = uibutton(plt.grid2, 'state');
    plt.FilteredButton.Text = 'Filtered';
    plt.FilteredButton.Layout.Row = 6;
    plt.FilteredButton.Layout.Column = 1;
    plt.FilteredButton.ValueChangedFcn = @FilteredButtonValueChanged;

    % Create CellLabel
    plt.CellLabel = uilabel(plt.grid2);
    plt.CellLabel.HorizontalAlignment = 'center';
    plt.CellLabel.Layout.Row = 7;
    plt.CellLabel.Layout.Column = 1;
    plt.CellLabel.Text = 'Cell Number';

    % Create CellSpinner
    plt.CellSpinner = uispinner(plt.grid2);
    plt.CellSpinner.Layout.Row = 8;
    plt.CellSpinner.Layout.Column = 1;
    plt.CellSpinner.ValueChangedFcn = @CellSpinnerValueChanged;

    % Create AxesPanel
    plt.AxesPanel = uipanel(plt.grid);
    plt.AxesPanel.Layout.Row = 1;
    plt.AxesPanel.Layout.Column = [2,3];

    % Show the figure after all components are created
    f.Visible = 'on';

    % save plt struct in UserData
    f.UserData = plt;
end

%% Callbacks
% Value changed function: FilenameListbox
function FilenameValueChanged(src, event)
    plt = ancestor(src,'figure','toplevel');
    value = event.Value;
    
end

% Value changed function: VelButton
function VelButtonValueChanged(src, event)
    plt = ancestor(src,'figure','toplevel');
    value = event.Value;
    
end
% Value changed function: DespikedButton
function DespikedButtonValueChanged(src, event)
    plt = ancestor(src,'figure','toplevel');
    value = event.Value;
    
end
% Value changed function: FilteredButton
function FilteredButtonValueChanged(src, event)
    plt = ancestor(src,'figure','toplevel');
    value = event.Value;
    
end

% Value changed function: CellSpinner
function CellSpinnerValueChanged(plt, event)
    plt = ancestor(src,'figure','toplevel');
    value = event.Value;
    
end
