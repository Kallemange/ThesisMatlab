function [s1shared, s2shared]=findSharedSV(s1,s2,t1,t2)
%At each time instance, find the satellites which are observed in both
%recievers.

%ISSUE, may be overlap, I will remove all duplicates of svID elements, will
%have to check that angles are the same later
s1shared=s1(t1);
s2shared=s2(t2);
%Create two structs to store previous reading, and update only in case a
%new reading is made
%[~, i1, i2]          = intersect([s1(t1).ToW], [s2(t2).ToW]);
for i=1:min(length(t1), length(t2))
    [~,idx1, idx2]   = intersect(s1(t1(i)).data.svID,s2(t2(i)).data.svID);
    s1shared(i).data = s1(t1(i)).data(idx1,:);
    s2shared(i).data = s2(t2(i)).data(idx2,:);
end

%{
for i=1:min(length(t1), length(t2))
        s1sortedID       = sortrows(s1(t1(i1(i))).data, 2);
        s2sortedID       = sortrows(s2(t2(i2(i))).data, 2);
        [~,idx1, idx2]   = intersect(s1sortedID.svID, s2sortedID.svID);
        s1shared(i).data = s1sortedID(idx1,:);
        s2shared(i).data = s2sortedID(idx2,:); 
        if (~all(s1shared(i).data.svID==s2shared(i).data.svID))
            keyboard
        end
end
%}
