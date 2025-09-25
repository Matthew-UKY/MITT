function Table = ConvCSV2Table(fname)
% fname must be a text file with two header lines
% first header line has the column names
% second header line has the format
%   (e.g. double for number or string for text)

% get automatic options
opts = detectImportOptions(fname);
% number of files identified in the .csv file
nftot = length(opts.VariableNames);
% import everything as strings at first
opts.VariableTypes = repmat({'string'},[1,nftot]);
% store user-requested variable types in the units property
opts.VariableUnitsLine = 2;

% load data into a table
Table = readtable(fname,opts);
% set the units as requested by the user
Table.Properties.VariableTypes = Table.Properties.VariableUnits;

end