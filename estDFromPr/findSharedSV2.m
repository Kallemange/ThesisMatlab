function [svShared]=findSharedSV2(s1,s2,t1,t2)
%At each time instance, find the satellites which are observed in both
%recievers. Chooses s1 as reference, and utilises its values and time
t1idx       = t1(1):t1(end);
t2idx       = t2(1):t2(end);
s1shared=s1(t1idx);
s2shared=s2(t2idx);
svShared=s1shared;

for i=1:min(length(t1idx), length(t2idx))
    try
    [~, idx1, idx2]     = intersect(s1shared(i).data.svID, s2shared(i).data.svID);
    svShared(i).data    = s1shared(i).data(idx1,:);
    svShared(i).numSats = length(idx1); 
    catch EM
        keyboard
    end
    
end
