function [w, t, start_time]=UTC_in_sec2GPStime(t, week)
%Conversion between Unix time in seconds, to GPS time (week+second of week)
%as well as datetime (Year Month Day Hour Minute Second)    
GPS_UNIX_OFFSET= 315964800;
t= (t- GPS_UNIX_OFFSET- week*604800);
w=week;

%     t_decimal=t-floor(t);
%     t0Posix=datetime(t,'ConvertFrom','posixtime');
%     start_time=[t0Posix.Year, t0Posix.Month, t0Posix.Day, t0Posix.Hour, ...
%                 t0Posix.Minute, floor(t0Posix.Second)];
%     [w, t]=UTC2GPStime(start_time);
%     t=t+t_decimal;
