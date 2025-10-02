% estimate the position of the probe from the filename
function N = NumFromString(S)
N = regexp(S,'\d*','match');
N = str2double(N);
if isempty(N)
    N = 0;
end
% I name my files in cm, so divide by 100 to get to m
N = N/100;
end