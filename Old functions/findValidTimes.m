function [t_idx1,t_idx2]=findValidTimes(T1,T2,tf)
keyboard %Check: is this function in use??
%Args: data1, data2, time format (e.g. ToW)
%Finds the valid times to check for between two recievers

%Which ever started later will be used for start time
if (T1(1).(tf)< T2(1).(tf))
    t0=T2.(tf);
else
    t0=T1.(tf);
end

%Decide last measurement (which one ended first)
if (T1(end).(tf)<T2(end).(tf))
    t_end=T1(end).(tf);
else
    t_end=T2(end).(tf);
end

%Find the valid indices for each measurement
t_idx1=find([T1(:).(tf)]>=t0&[T1(:).(tf)]<=t_end);
t_idx2=find([T2(:).(tf)]>=t0&[T2(:).(tf)]<=t_end);