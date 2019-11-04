%Read log files sent from Linnea on 01-11-19
logRaw="2019-10-13-13-11-19-rec1-gps-obs.csv";
raw=rRawFromTable(path+logRaw);
%%
path="Logs/LogsFromLinnea/";
logEph="2019-10-13-13-11-19-eph.csv";
eph=readEphFromTable(path+logEph);
%%
logGPS="2019-10-13-13-11-19rec1-gps.csv";
gps=readtable(path+logGPS);