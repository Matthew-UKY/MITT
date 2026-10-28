function def = DefaultPlotSeries(Config,GUIControl)
Acolor = [0,0,1;
          0,1,0;
          1,0,0]; % blue, green, red
yAnalysis = [true,Config.Despiked,Config.Filtered];

def = struct();
def.FileItems = GUIControl.MITTdir.name;
def.FileValue = GUIControl.MITTdir.name{1};
def.AnalysisValue = [true,false,false];
def.AnalysisVisible = yAnalysis;
def.AnalysisColors = Acolor;
def.CellValue = 1;
def.CellMin = 1;
def.CellMax = Config.nCells;
end