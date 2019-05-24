%Due to unforeseen 's' in log, will be removed from logfile

close, clear, clc
fid = fopen('prom2/Ins.csv');
fid2 = fopen('prom2/Ins2.csv', 'w');
tline = fgetl(fid);
fprintf(fid2, tline);
fprintf(fid2, '\n');
while ischar(tline)    
    tline = fgetl(fid);
    try
        fprintf(fid2, [tline(1:10), tline(12:end)]);
    catch ME
        fclose(fid);
        fclose(fid2);
        return;
    end
        fprintf(fid2,'\n');
    
end
fclose(fid);
fclose(fid2);