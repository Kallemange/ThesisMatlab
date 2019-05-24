function s=createSatLog(n, N, t0, sats, angles)
s.numSats                          = n;
s.ToW                              = t0;
s.data                             = table(n, n, n);
s=repmat(s,1,N);
e0=angles.e0;
e1=angles.e1;
a0=angles.a0;
a1=angles.a1;

elev=round(createPoints(e0,e1,N));
azim=round(createPoints(a0,a1,N));


for i=1:N
    s(i).numSats   = n;
    s(i).ToW       = i/5+t0;
    s(i).data      = table([1:n]', elev(:,i), azim(:,i), (1:n)', [1:n-1 3]');
    s(i).data.Properties.VariableNames    = {'svID' 'elev', 'azim', 'prRes','CNO'};
end

function posV=createPoints(theta0, theta1, N)
    n=length(theta0);
    posV=zeros(n,N);
    for i=1:n
        posV(i,:)=linspace(theta0(i),theta1(i),N);
    end

% 
% * Sat logs need: numSats, ToW~=10^5, data:
%                                             svID, elev, azim, prRes, CNO