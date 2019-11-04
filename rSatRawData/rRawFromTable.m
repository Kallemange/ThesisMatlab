function r=rRawFromTable(path)
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline,',');
titles=string(titles);
titles=erase(titles, '.');
L=length(titles)-3;
timeOld=0;
data=[];
i=1;
j=0;
first=true;
[~, idxSNR]=find(titles=="obsSNR");
[~, idxSAT]=find(titles=="obssat");
[~, idxLLI]=find(titles=="obsLLI");
[~, idxCODE]=find(titles=="obscode");
[~, idxP]=find(titles=="obsP");

while 1
    tline=fgetl(fid);
    
    try
    tline=split(tline, ',');
    %Extrahera sat, SNR, LLI, code,P
    time=str2double(tline{6})+str2double(tline{7});
    if time>timeOld&&timeOld>0
        r(i).data=data;
        r(i).ToW=timeOld;
        r(i).numSats=j;
        data=[];
        i=i+1;
        j=0;
    end
    j=j+1;
    data(end+1,:)=[ str2double(tline{idxSAT}) str2double(tline{idxSNR}) ...
                    str2double(tline{idxLLI}) str2double(tline{idxCODE})...
                    str2double(tline{idxP})];
    %keyboard
    timeOld=time;        
    
    %In case the package is split into two, but the sampling time is the
    %same, the next line measurements are attached to previous
    
    catch ME
        fclose(fid);
        %keyboard
        return;
    end
    
    
end
fclose(fid)
end
