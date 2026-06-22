% convert datetime array to date string to prevent conversion errors in
% excel
function WriteControlFile(data,filename)
data.date = string(data.date);
writetable(data,filename)
end