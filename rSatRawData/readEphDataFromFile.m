function eph=readEphDataFromFile(path)
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline, {',',' '});
titles=string(titles);
%several gtime parameters have been logged separate (e.g. toe1 and toe2)
%must be merged (in name and in value)
titles=removeExtraTitles(titles);
L=length(titles);

while ischar(tline)
    tline=fgetl(fid);
    try
    
    line=str2num(tline);
    line([9 11 13])=line([9 11 13])+line([10 12 14]);
    week=line(titles=="week");
    line([9 11 13])=posix2GPSTime(line([9 11 13]), week);
    line([10 12 14])=[];
    for j=1:L
        obs.(titles(j))=line(j);
    end
    %Initiate the struct-array or expand if needed
    if (~exist('eph')||obs.sat>length(eph))
        eph(obs.sat)=obs;
    elseif(isempty(eph(obs.sat).sat))
        eph(obs.sat)=obs;
    else 
        %eph(obs.sat)=obs; %Only include the latest version in the eph-data
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

function tow=posix2GPSTime(t, week)
%Update time format from posix (since 1970 -> time in week and s)
GPS_UNIX_OFFSET= 315964800;
tow= (t- GPS_UNIX_OFFSET- week*604800);


