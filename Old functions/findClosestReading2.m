function [t1idx t2idx]=findClosestReading2(r1, r2)
%Have to find the raw data which closest resemble wrt time. 
%If they're not aligned, simply choose the index closest

%Find min and max value for time
t0          =max(r1(1).ToW,r2(1).ToW);
t_end       =min(r1(end).ToW,r2(end).ToW);
%Find corresponding indices

t1idx=nan(1,max(length(r1), length(r2)));
t2idx=nan(1,max(length(r1), length(r2)));
i=1;
if (r1(1).ToW==t0)
    while (r1(i).ToW<=t_end)
        low=find([r2(:).ToW]<=r1(i).ToW, 1, 'last');
        high=find([r2(:).ToW]>=r1(i).ToW, 1, 'first');
        i=i+1;
    end
else
    t2idx=find(([r2(:).ToW]>=t0));
    t2idx=find([r2(t2idx).ToW]<=t_end);
    for i=1:t2idx(end)
        low=find([r1(:).ToW]<=r2(i).ToW, 1, 'last');
        high=find([r1(:).ToW]>=r2(i).ToW, 1, 'first');
        if (abs(r2(i).ToW-r1(low).ToW)<abs(r2(i).ToW-r1(high).ToW))
            t1idx(i)=low;
        else
            t1idx(i)=high;
        end
        i=i+1;
    end
end
%Remove any nan introduced initially
t1idx = t1idx(~isnan(t1idx));
t2idx = t2idx(~isnan(t2idx));
%Use the one starting latest as reference for matching


end