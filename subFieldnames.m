% find fieldnames up to two levels deep
function [fnames,combinedNames] = subFieldnames(Struct)
% get structure fieldnames
fnames = fieldnames(Struct);
combinedNames = fnames;
nFtot = length(fnames);
for i = 1:nFtot
    subStruct = Struct.(fnames{i});
    if isstruct(subStruct)
        subfnames = fieldnames(subStruct);
        combinedNames{i} = strcat(fnames{i},'.',subfnames);
    end
end
% convert combinedNames into one cell array, containing all subfield names
% as '(fieldname).(subfieldname)'
if ~all(strcmp(fnames,combinedNames))
    combinedNames = vertcat(combinedNames{:});
end