function PlotQCTable(Config)
% to create table that shows the output from the Data Quality Classification 

f = figure();
    f.Name = ['Classify Cell Quality Output for file: ' Config.filename];
Qrnames = 1:Config.nCells;
t = uitable(f);
    t.Data = Config.Qdat;
    t.Position = [0 0 f.Position(3) f.Position(4)];
    t.ColumnName = Config.Qcnames;
    t.RowName = Qrnames;
ncomptot = length(Config.comp);
t.ColumnFormat = repmat({'logical'},[1,ncomptot]);
    
end