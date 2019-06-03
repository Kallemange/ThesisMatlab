function raw=readRawDataFromBagFile(path)
%Create a struct array from bag file containing sat and P data
fid = fopen(path,'r');
tline=fgetl(fid);
titles=["sat" "P"];
%several gtime parameters have been logged separate (e.g. toe1 and toe2)
%must be merged (in name and in value)

L=length(titles);

index=1;
while ischar(tline)
    tline=fgetl(fid);
    try
        if(~isempty(strfind(tline, '[')))
            obs.ToW=0;
            sat=[];
            P=[];
            first=true;
            while(1)
               for i=1:6
               fgetl(fid);
               end
               tline=fgetl(fid);
               line=strsplit(tline);
               time=str2num(line{3});
               tline=fgetl(fid);
               line=strsplit(tline);
               sec=str2num(line{3});
               if(first)
                   obs.ToW=time+sec;
                   first=false;
               end
               tline=fgetl(fid);
               line=strsplit(tline);
               sat=[sat; str2num(line{2})];
               for i=1:8
                   tline=fgetl(fid);
               end
               line=strsplit(tline);
               if(line{1}=="P:")
               P=[P; str2num(line{2})];
               else 
                   keyboard
               end
               tline=fgetl(fid);
               if(~isempty(strfind(tline, ']')))
                break
               end
               
            end
            obs.data=sortrows(table(sat, P), 1);
            raw(index)=obs;
            index=index+1;
        end
%         line=strsplit(tline, ',');
%         obs.ToW=str2num(line{3})+str2num(line{4});
%         tline=fgetl(fid);
%         while(isepmty(strfind(tline, ']')))
%             keyboard
%         end
            
%     for j=1:L
%         obs.(titles(j))=line(j);
%     end
%     %Initiate the struct-array or expand if needed
%     if (~exist('eph')||obs.sat>length(eph))
%         eph(obs.sat)=obs;
%     elseif(isempty(eph(obs.sat).sat))
%         eph(obs.sat)=obs;
    %I'll remove this version for now, since it's making things complicated
    %but will later possibly be in use to use the most accurate ephmeris
    %data. For now it's enough to have the first measurement of all
    %else
    %    for k=1:L
    %    eph(obs.sat).(titles(k))=[eph(obs.sat).(titles(k)) obs.(titles(k))]
    %    end   
    
    catch ME
        keyboard
        fclose(fid);
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

function l=removeGtimeVal(l)
%Add the values of toe1+toe2, toc1+toc2, ttr1+ttr2, remove all 2:s
l(9)=l(9)+l(10);
l(11)=l(11)+l(12);
l(13)=l(13)+l(14);
l([10 12 14])=[];


