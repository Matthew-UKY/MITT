function PlotTimeSpace(xdata,ydata,Udata,goodCells,ptitle)
% creates array image plot
% called from ClassifyArrayGUI
% subfunctions include CreateFig, makeLegend

%% user parameters
%pcont = [-0.05:0.01:0.05]; % hard wire in contours

%% prepare data
% find size of array
[nttot,nCells] = size(Udata);
% remove mean from each cell
Umean = mean(Udata);
Unomean = Udata - Umean;

%% calculate intervals for colorbar
% find range from max/min from each good cell
Ugooddata = Unomean(:,goodCells);
Umax = max(Ugooddata,[],'all');
Umin = min(Ugooddata,[],'all');
rngtot = Umax-Umin;

% get rounded values
if rngtot>1
    divrng = 1;
elseif rngtot>0.1
    divrng = 10;
else
    divrng = 100;
end
pmaxe = ceil(Umax*divrng)/divrng;
pmine = floor(Umin*divrng)/divrng;
nIntervals = 50;
% set intervals for contour lines
pcont = linspace(pmine,pmaxe,nIntervals);

%% create image
% figure and axes
axe = CreateFig;
% add image
image(xdata-xdata(1),ydata,(Unomean'-pcont(1))/(pcont(2)-pcont(1)),...
    'CDataMapping','direct');%values are integers that map to colors
% colormap 
nctot = length(pcont)-1;
cmap = getColline(nctot);
colormap(cmap);

% labels and titles
xlabel(ptitle.xaxis)
ylabel(ptitle.yaxis)
title(ptitle.top);
% legend
c = colorbar(axe,'eastoutside');
c.Ticks = round(nctot/10:nctot/10:nctot);
c.TickLabels = string(pcont(c.Ticks));

end

%%%%%
function axe = CreateFig
% multiple axes
f = figure(WindowState = 'maximized');
grid = uigridlayout(f,[1,1]);
axe = axes(grid);
end
%%%%%