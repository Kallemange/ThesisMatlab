function [maxSNRid, u_id]=findMaxSNR(D,u,iD,iu)
[~, maxSNRid]=max(sum(D.SNR(iD,:),2));
u_id=find(u.sv(iu)==D.sat(iD(maxSNRid)), 1, 'first');
a=0;