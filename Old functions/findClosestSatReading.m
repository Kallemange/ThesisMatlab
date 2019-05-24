function is=findClosestSatReading(r1, s1, t1, i, t0)
%Have to find the satellite data which closest resemble that of the
%raw-data wrt time. If they're not aligned, simply choose the index closest
t_curr=r1(t1(i)).ToW-t0;
% if any(round(t_curr,3)==round([s1.ToW]-s1(1).ToW,3))
%     [~, ir, is]=find(round(r1(t1(i)).ToW-t0,3)==round([s1.ToW]-s1(1).ToW,3));
% else
idx_lower=find(t_curr>=[s1.ToW]-s1(1).ToW, 1, 'last');
idx_upper=find(t_curr<=[s1.ToW]-s1(1).ToW, 1, 'first');
dt1=abs(t_curr-(s1(idx_lower).ToW-s1(1).ToW));
dt2=abs(t_curr-(s1(idx_upper).ToW-s1(1).ToW));
if dt1<dt2
    is=idx_lower;
else
    is=idx_upper;
end
%end
end