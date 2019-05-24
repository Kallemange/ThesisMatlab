function covRemapped=calcCovariance(res)
sats            = find(sum(res,2)~=0);
Sigma           = zeros(max(sats));
SigmaCount      = zeros(max(sats));
for i=1:size(res,2)
    sats_i=find(res(:,i)~=0);
    cov=res(sats_i,i)*res(sats_i,i)';
    Sigma(sats_i,sats_i)=Sigma(sats_i,sats_i)+cov;
    SigmaCount(sats_i, sats_i) =SigmaCount(sats_i, sats_i)+1;
end
Sigma                       = Sigma(sats, sats);
SigmaCount                  = SigmaCount(sats,sats);
SigmaCount(SigmaCount==0)   = 1;
Sigma                       = Sigma./SigmaCount;
%range                       = [min(min(Sigma)) max(max(Sigma))];
%covRemapped.Sigma           = (Sigma-range(1))/(range(2)-range(1));
covRemapped.Sigma           = Sigma;
covRemapped.satID           = sats;            
