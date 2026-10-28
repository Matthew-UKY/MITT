function data = ReadControlFile(filename)
opts = detectImportOptions(filename);
% opts.VariableTypes{1} = 'string';
% opts.VariableTypes{2} = 'string';
opts.VariableTypes{3} = 'string';
opts.VariableTypes{4} = 'string';
data = readtable(filename,opts);
data.date = datetime(data.date,'Format','dd-MMM-uuuu HH:mm:ss.SSS','TimeZone',data.timezone{1});
end