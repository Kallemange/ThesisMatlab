function [xVec, bVec]=globalEstFromRaw(raw, s, almanac_data)
xVec=[]; bVec=[];
x=g2r('N',59,'E',18,0)';
b=0;
for i=1:10
    t=raw(i).ToW;
    t=[t-raw(1).ToW]+s;
    satIdx=find(raw(i).data.sat<32);
    satID=sort(raw(i).data.sat(satIdx));
    numSat=length(satID);
    xs=zeros(3,numSat);
    allPosECI=zeros(3,numSat);
    raw=sortrows(raw(i).data(satIdx,:));
    for k=1:numSat
        [posECEF, posECI]=Sat_pos(almanac_data(:,satID(k)),t);
        xs(:,k)=posECEF;
        allPosECI(:,k)=posECI;
    end
dim=3;
[x, b, norm_dp, G] = estimate_position(xs', raw.P, numSat, x, b, dim);
xVec=[xVec; x];
bVec=[bVec b];
end
