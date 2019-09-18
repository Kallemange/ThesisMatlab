function eph=readEphDataFromFile(path)
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline, {',',' '});
titles=string(titles);
%several gtime parameters have been logged separate (e.g. toe1 and toe2)
%must be merged (in name and in value)
titles=removeExtraTitles(titles);
L=length(titles);

i=1;
while ischar(tline)
    tline=fgetl(fid);
    try
    line=str2num(tline);
    line([9 11 13])=posix2GPSTime(line([9 11 13]));
    line=removeGtimeVal(line);
    for j=1:L
        obs.(titles(j))=line(j);
    end
    %Initiate the struct-array or expand if needed
    if (~exist('eph')||obs.sat>length(eph))
        eph(obs.sat)=obs;
    elseif(isempty(eph(obs.sat).sat))
        eph(obs.sat)=obs;
    %I'll remove this version for now, since it's making things complicated
    %but will later possibly be in use to use the most accurate ephmeris
    %data. For now it's enough to have the first measurement of all
    %else
    %    for k=1:L
    %    eph(obs.sat).(titles(k))=[eph(obs.sat).(titles(k)) obs.(titles(k))]
    %    end   
    end
    catch ME
        fclose(fid);
        emptyIndex = find(arrayfun(@(eph) isempty(eph.sat),eph));
        eph(emptyIndex)=[];
        return;
    end

end
fclose(fid);


function t=removeExtraTitles(t)
%The following values need to be replaced: 
%toe1 & toe2 => toe
%toc1 & toc2 => toc
%ttr1 & ttr2 => ttr
t(t=="toe1")="toe";
t(t=="toe2")=[];
t(t=="toc1")="toc";
t(t=="toc2")=[];
t(t=="ttr1")="ttr";
t(t=="ttr2")=[];

function tVec=posix2GPSTime(t)
%Update time format from posix (since 1970 -> time in week and s)
tVec=zeros(1,length(t));
for i=1:length(t)
    t0Posix=datetime(t(i),'ConvertFrom','posixtime');
    start_time=[t0Posix.Year, t0Posix.Month, t0Posix.Day, t0Posix.Hour, t0Posix.Minute, floor(t0Posix.Second)];
    [~, ToW]=UTC2GPStime(start_time);
    tVec(i)=ToW;
end

function l=removeGtimeVal(l)
%Add the values of toe1+toe2, toc1+toc2, ttr1+ttr2, remove all 2:s
l(9)=l(9)+l(10);
l(11)=l(11)+l(12);
l(13)=l(13)+l(14);
l([10 12 14])=[];


