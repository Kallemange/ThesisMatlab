%Read log files sent from Linnea on 01-11-19
path="Logs/LogsFromLinnea/";
%%
logRaw="2019-10-13-13-11-19-rec1-gps-obs.csv";
raw=rRawFromTable(path+logRaw);
x=estGlobalPos(raw, eph,sets);
%%
logEph="2019-10-13-13-11-19-eph.csv";
eph=readEphFromTable(path+logEph);
%%
logGPS="2019-10-13-13-11-19rec1-gps.csv";
gps=readtable(path+logGPS);
properties_old_names=[  "x_latitude","x_longitude", "x_altitude", ...
                        "x_posEcef_x", "x_posEcef_y", "x_posEcef_z"];
properties_new_names=[  "lla0",     "lla1",     "lla2",...
                        "ecef0",  "ecef1",  "ecef2"];
for i=1:length(properties_old_names)
    gps.Properties.VariableNames{properties_old_names(i)}=char(properties_new_names(i));
end