function A=readSatDataToFile(path)
%Read log-file to workspace. Note that ToW has been changed from ms->s
%IN directory
%OUT cell-struct with sat data
fid = fopen(path,'r');
tline=fgetl(fid);
titles=strsplit(tline,', ');
titles=string(titles);
L=length(titles)-2;
i=1;
while ischar(tline)
    tline=fgetl(fid);
    try
    line=str2num(tline);
    catch ME
        fclose(fid);
        return;
    end
    A(i).ToW=line(1)/1000;
    A(i).numSats=line(2);
    data=nan(A(i).numSats,L);
    %A(i).data=nan(A(i).numSats,L);
    for j=1:A(i).numSats
        data(j,:)=(line(3+(j-1)*L:2+L+(j-1)*L));
    end
    A(i).data=array2table(data, 'variableNames', titles(3:end));
    i=i+1;
end
fclose(fid)
keyboard;
