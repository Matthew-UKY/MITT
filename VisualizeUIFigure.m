function f = VisualizeUIFigure()

    % Create UIFigure and hide until all components are created
    f = uifigure('Visible', 'off');
    f.AutoResizeChildren = 'off';
    colormap(f, 'jet');
    f.Name = 'Default uifigure';
    f.WindowState = 'maximized';

    % store all ui elements in one struct
    plt = struct();

    % Create GridLayout
    plt.grid = uigridlayout(f);
    plt.grid.ColumnWidth = {200,'1x',200};
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
    plt.grid2.ColumnWidth = {'1x'};
    plt.grid2.RowHeight = {'fit', 'fit', 'fit', 25, 25, 25, 'fit', 25};
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
    plt.AxesPanel.Layout.Column = 2;

    % Show the figure after all components are created
    f.Visible = 'on';

    % save plt struct in UserData
    f.UserData = plt;
end