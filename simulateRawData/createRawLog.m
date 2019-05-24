function r = createRawLog(n, N, t0, calcD)
r.numSats                          = n;
r.ToW                              = t0;
r.data                             = table(n, n, n);
r=repmat(r,1,N);

for i=1:N
    r(i).numSats   = n;
    r(i).ToW       = i/5+t0;
    r(i).data      = table([1:n]', [1:n-1 3]', calcD(:,i));
    r(i).data.Properties.VariableNames    = {'sat' 'SNR', 'P'};
end
