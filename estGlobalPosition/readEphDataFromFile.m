function eph=readEphDataFromFile(path)
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline, {',',' '});
titles=string(titles);
L=length(titles);
i=1;
while ischar(tline)
    tline=fgetl(fid);
    try
    line=str2num(tline);
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
        return;
    end

end
fclose(fid);
keyboard;

