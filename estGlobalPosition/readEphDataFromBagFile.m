function eph=readEphDataFromBagFile(path)
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline, {','});
titles=string(titles);
%several gtime parameters have been logged separate (e.g. toe1 and toe2)
%must be merged (in name and in value)
titles=removeExtraTitles(titles);
L=length(titles);

i=1;
while ischar(tline)
    tline=fgetl(fid);
    try
    line=string(strsplit(tline, {','}));
    for i=2:length(line)
        line2(i)=str2num(line(i));
    end
    line2(isnan(line2))=0;
    line=removeGtimeVal(line2, titles);
    for j=3:length(line)-1
        temp=char(titles(j));
        obs.(temp(2:end))=line(j);
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
t(t==".header.frame_id")=[];
t(t==".toe.time")=".toe";
t(t==".toe.sec")=[];
t(t==".toc.time")=".toc";
t(t==".toc.sec")=[];
t(t==".ttr.time")=".ttr";
t(t==".ttr.sec")=[];

function l=removeGtimeVal(l, t)
%Add the values of toe1+toe2, toc1+toc2, ttr1+ttr2, remove all 2:s
l(11)=l(11)+l(12);
l(13)=l(13)+l(14);
l(15)=l(15)+l(16);
l([12 14 16])=[];


