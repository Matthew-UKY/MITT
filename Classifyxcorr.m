function [goodCellsii,Qxcorr] = Classifyxcorr(dat,xcorrthreshold)
% calculates goodCells based on cross correlation between adjacent data cells

% calculate size of Data matrix
[ntimetot,nCells] = size(dat);
cmax = zeros(2,nCells);
% if there is more than one cell
if nCells>1
    for nc = 2:nCells
        c = xcorr(dat(:,nc),dat(:,nc-1),50,'coeff');
        cmax(2,nc-1) = max(c);
        cmax(1,nc) = max(c);
    end
    Qxcorr = nanmax(cmax)'*100;
    goodCellsii = Qxcorr > xcorrthreshold;
else
    Qxcorr = NaN;
    goodCellsii = true(nCells,1);
end
    
end