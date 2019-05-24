function logData=readLog(path)
for i=1:2
    file=strcat(path,'/',num2str(i),'Raw',path,'.csv');
    if i==1
        logData{i}=csvread(file);
    elseif i==2
        logData{i}=readtable(file);
        
    end
end
