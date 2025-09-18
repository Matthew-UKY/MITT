function val = subGetValues(Struct,val)
% get values from buttons, editable fields and other GUI input fields
% called from MITT and ClassifyArrayGUI
% modified May 25 2016 to work with setARMAopts by BM

yOverride = isempty(val);
fnames = subFieldnames(Struct);
nFtot = length(fnames);
for i = 1:nFtot
    fnamei = fnames{i};
    uitype = Struct.(fnamei).Type;
    if isfield(val,fnamei) || yOverride
        switch uitype
            case 'uilabel'
                val.(fnamei) = Struct.(fnamei).Text;
            case 'uibutton'
                continue % don't need to store anything from buttons
            otherwise
                val.(fnamei) = Struct.(fnamei).Value;
        end
    end
end
end

