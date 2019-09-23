function tGPS = unix2GPSTime(t_unix)
%Conversion UNIX->GPS-time (sec of week+decimal)
t_decimal=t_unix-floor(t_unix);
t0Posix=datetime(t_unix,'ConvertFrom','posixtime');
start_time=[t0Posix.Year, t0Posix.Month, t0Posix.Day, t0Posix.Hour, ...
            t0Posix.Minute, floor(t0Posix.Second)];
[~, t]=UTC2GPStime(start_time);
tGPS=t+t_decimal;
