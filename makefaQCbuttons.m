function faQC = makefaQCbuttons(grid,def)
% creates buttons on panel for Classification options
% called from MITT and ClassifyArrayGUI

% use cell range
faQC.Range = uicheckbox(grid,def.Checkbox, ...
    Text = 'set range (Cell number)');
faQC.nigood = uieditfield(grid,'numeric',def.Editfield);
faQC.negood = uieditfield(grid,'numeric',def.Editfield);

% use correlation threshold
faQC.Correlation = uicheckbox(grid,def.Checkbox,...
    Text = 'Correlation Threshold:');
faQC.Corthreshold = uieditfield(grid,'numeric',def.Editfield);
    faQC.Corthreshold.Layout.Column = [2,3];

% use frequency of mode
faQC.pctmodecheck = uicheckbox(grid,def.Checkbox,...
    Text = 'Mode threshold (%)');
faQC.pctmode = uieditfield(grid,'numeric',def.Editfield);
    faQC.pctmode.Layout.Column = [2,3];

% use cross-correlation between adjacent time series
faQC.xcorr = uicheckbox(grid,def.Checkbox,...
    Text = 'xcorr adjacent cells (%)');
faQC.xcorrthreshold = uieditfield(grid,'numeric',def.Editfield);
    faQC.xcorrthreshold.Layout.Column = [2,3];

% use Hurther Lemmin w1 w2 
faQC.w1w2xcorr = uicheckbox(grid,def.Checkbox,...
    Text = 'Hurth/Lemm w1w2 noise ratio');
faQC.w1w2xcorrthreshold = uieditfield(grid,'numeric',def.Editfield);
    faQC.w1w2xcorrthreshold.Layout.Column = [2,3];

% use percentage of Spikes
faQC.Spikes = uicheckbox(grid,def.Checkbox,...
    Text = 'Spike threshold (%)');
faQC.SpikeThreshold = uieditfield(grid,'numeric',def.Editfield);
    faQC.SpikeThreshold.Layout.Column = [2,3];

% use InertialSlope (Jay)
faQC.InertialSlope = uicheckbox(grid,def.Checkbox,...
    Text = 'Slope of inertial subrange');
faQC.InertialSlopeThreshold = uieditfield(grid,'numeric',def.Editfield);
    faQC.InertialSlopeThreshold.Layout.Column = [2,3];

% use 3rd order polynomial fit
faQC.PolyFilt = uicheckbox(grid,def.Checkbox,...
    Text = '3rd order Poly fit (z score)');
faQC.zscore = uieditfield(grid,'numeric',def.Editfield);
    faQC.zscore.Layout.Column = [2,3];

end
