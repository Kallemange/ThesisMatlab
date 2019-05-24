function [t1idx t2idx, t0, t_end]=findFirstLast(r1, r2)
%IN: Two struct-arrays
%OUT: First and last valid index for array 1 and 2, first and last valid sample

t0          = max(r1(1).ToW,r2(1).ToW);
t_end       = min(r1(end).ToW,r2(end).ToW);
t1min       = find([r1.ToW]>=t0, 1, 'first');
t1max       = find([r1.ToW]<=t_end, 1, 'last');
t2min       = find([r2.ToW]>=t0, 1, 'first');
t2max       = find([r2.ToW]<=t_end, 1, 'last');
t1idx       = [t1min t1max];
t2idx       = [t2min t2max];
