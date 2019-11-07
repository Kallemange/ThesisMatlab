function eph=readEphFromTable(path)

fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline, {',',' '});
titles=strip(titles, 'left', '.');
titles=string(titles);
%several gtime parameters have been logged separate (e.g. toe1 and toe2)
%must be merged (in name and in value)
[titles, idx]=removeExtraTitles(titles);
titles=removeTGD(titles);
L=length(titles);

while ischar(tline)
    tline=fgetl(fid);
    try
    
    line=strsplit(tline, ',');
    for i=1:length(line)
        line{i}=str2num(line{i});
    end
    week=line{titles=="week"};
    for i=1:length(idx)
        line{idx(i)-1}=posix2GPSTime(line{idx(i)-1}, week);
        line{idx(i)-1}=line{idx(i)-1}+line{idx(i)};
    end
    
    line(idx)=[];
    for j=1:L
        obs.(titles(j))=line{j};
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


end
function [t, idx]=removeExtraTitles(t)
idx=[];
[~, idx(end+1)]=find(t=="toe.sec");
[~, idx(end+1)]=find(t=="toc.sec");
[~, idx(end+1)]=find(t=="ttr.sec");
temp=char(t(idx-1));
t(idx-1)=string(temp(1,1:3,:));
t(idx)=[];
end

function t=removeTGD(t)
t(t=="tgd.0")="tgd0";
t(t=="tgd.1")="tgd1";
t(t=="tgd.2")="tgd2";
t(t=="tgd.3")="tgd3";
end
%The following values need to be replaced: 
%toe1 & toe2 => toe
%toc1 & toc2 => toc
%ttr1 & ttr2 => ttr
% t(t=="toe1")="toe";
% t(t=="toe2")=[];
% t(t=="toc1")="toc";
% t(t=="toc2")=[];
% t(t=="ttr1")="ttr";
% t(t=="ttr2")=[];

function tow=posix2GPSTime(t, week)
%Update time format from posix (since 1970 -> time in week and s)
GPS_UNIX_OFFSET= 315964800;
tow= (t- GPS_UNIX_OFFSET- week*604800);

end