function [w, t]=UTC_in_sec2GPStime(t, week)
%Conversion between Unix time in seconds, to GPS time (week+second of week)
%as well as datetime (Year Month Day Hour Minute Second)    
GPS_UNIX_OFFSET= 315964800;
t= (t- GPS_UNIX_OFFSET- week*604800);
w=week;
