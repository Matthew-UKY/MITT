% basic info from a Config array to display in a table
function signalInfo = GetSignalInfo(Config)

% Sampling frequency
headers{1} = "fs (Hz)";
fs = Config.Hz;
data{1} = fs;

% Use collection time variable in Config and display it
%% Fix this !!!
Config.timeZoneOffset = -14400;
%%
unixTime = Config.startCollectionTime_seconds + Config.startCollectionTime_subseconds + Config.timeZoneOffset;
dt = datetime(unixTime,'ConvertFrom','posixtime');
dt.Format = 'uuuu';
headers{2} = "Year";
data{2} = dt;
dt.Format = 'MMM d';
headers{3} = "Date";
data{3} = dt;
dt.Format = 'HH:mm:ss';
headers{4} = "Time";
data{4} = dt;

% Length of time of signal
headers{5} = "Collection Time";
collectionTime = Config.ntimetot/Config.Hz/60; % in minutes
data{5} = sprintf("%2.1f min",collectionTime);

headers = headers(:);
data = data(:);

signalInfo = [headers,data];
signalInfo = table(signalInfo);
end