function T=readRawDataToFile(path)
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline,',');
titles=string(titles);
L=length(titles)-3;
i=1;

while ischar(tline)
    tline=fgetl(fid);
    try
    line=str2num(tline);
    %In case the package is split into two, but the sampling time is the
    %same, the next line measurements are attached to previous
    if(i>1&&line(2)+line(3)==T(i-1).ToW)
        T(i-1).numSats=T(i-1).numSats+line(1);
        for j=1:line(1)
            T(i-1).data(end+1,:)=array2table((line(4+(j-1)*L:3+L+(j-1)*L)), 'variableNames', titles(4:end));
        end
        %keyboard;
        continue;
    end
    catch ME
        fclose(fid);
        return;
    end
    T(i).numSats=line(1);
    T(i).ToW=line(2)+line(3);
    %T(i).data=table(titles(4), titles(5), titles(6), titles(7), titles(8))
    data=nan(T(i).numSats,L);
    for j=1:T(i).numSats
        data(j,:)=(line(4+(j-1)*L:3+L+(j-1)*L));
    end
    T(i).data=array2table(data, 'variableNames', titles(4:end));
    i=i+1;
end
fclose(fid)
keyboard;
