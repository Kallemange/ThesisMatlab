function [median_id, median_u]=findMedianIndex(D, u, iD, iu)
    dP=D.dp(iD);
    if(~mod(length(dP),2))
        [~, median_id]=min(abs(median(dP)-dP)); 
    else
        median_id  = find(dP==median(dP), 1, 'first');
    end
        median_sat = D.sat(iD(median_id));
        median_u   = find(u.sv(iu)==median_sat);
if isempty(median_u)
    keyboard
end
    
