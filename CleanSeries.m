function CleanSeries(GUIControl)
% Control file for cleaning time series
% Called from MITT
% Calls CleanSpike, CleanFilter, and AutoPlotTimeSeries

% get list of all files in MITT directory
ncleantot = length(GUIControl.MITTdir.name);

for nclean = 1:ncleantot
    % get input file name
    inname = [GUIControl.odir,filesep,GUIControl.MITTdir.name{nclean}];
    % load input file
    load(inname,'Config','Data');
    
    % despike
    if GUIControl.Despike
        % if it has yet to be despiked or the spike reset checkbox is checked
        if ~Config.Despiked || GUIControl.SpikeReset
            % send to CleanSpike and return the new data
            Data = CleanSpike(Config,Data,GUIControl);
            % mark Config file as despiked
            Config.Despiked = true;
        end
    end
    % filter using butterworth
    if GUIControl.FiltrBW
        % if it has yet to be filtered or the spike reset checkbox is checked
        if ~Config.Filtered || GUIControl.SpikeReset
            % send to CleanFilter and return the new data
            Data = CleanFilter(Config,Data,GUIControl);
            % mark Config file as filtered
            Config.Filtered = true;
        end
    end
    % display
    if GUIControl.plotTimeSeries
        % send to subprogram to plot the time series
        PlotTimeSeries(Config,Data,1)
    end
    
    % save data
    save(inname,'Config','Data');
end

end