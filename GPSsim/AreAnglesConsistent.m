%Script to check that angles given are consistent and no jumps in angle appear
%Plot shows consistency in both elev-azim besides jumping to 0 (indicating
%loss of contact)
elev=zeros(32,1707);
azim=zeros(32,1707);
for i=1:1707
    idx=sat1(i).data.svID;
    idxSat=idx(idx>0);

    elev(idxSat,i)=sat1(i).data.elev(idx>0);
    azim(idxSat,i)=sat1(i).data.azim(idx>0);
end
elevIdx=find(sum(elev,2)>0);
azimIdx=find(sum(azim,2)~=0);

plot(elev(elevIdx,:)')
plot(azim(azimIdx,:)')