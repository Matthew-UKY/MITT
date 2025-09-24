function Struct = subSetValues(Struct,val)
% set values for buttons, editable fields and other GUI input fields
% called from MITT and ClassifyArrayGUI
% modified May 25 2016 to work with setARMAopts by BM

% call subfunction to get fieldnames up to two levels deep
fnames = subFieldnames(val);
nFtot = length(fnames);
for nF = 1:nFtot
    fnamei = fnames{nF};
    if isfield(Struct,fnamei)
        Struct.(fnamei).Value = val.(fnamei);
    end
end
