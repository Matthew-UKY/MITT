% find fieldnames up to two levels deep
function [fnames,combinedNames] = subFieldnames(Struct)
% get structure fieldnames
fnames = fieldnames(Struct);
nFtot = length(fnames);
combinedNames = cell(nFtot,1);
for i = 1:nFtot
    subStruct = Struct.(fnames{i});
    if isstruct(subStruct)
        subfnames = fieldnames(subStruct);
        combinedNames{i} = strcat(fnames{i},'.',subfnames);
    end
end
combinedNames = vertcat(combinedNames{:});