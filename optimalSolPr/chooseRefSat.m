function [sat_id]=chooseRefSat(PS, D)
%PS persistent sats, those who appear each (or most) epochs
SNRsum=zeros(max(PS.sats),1);
for i=1:length(D)
    [~,~,iD]                = intersect(PS.sats,D(i).sat);
    SNRsum(D(i).sat(iD))    = SNRsum(D(i).sat(iD))+sum(D(i).SNR(iD,:),2);
end
sat_id=find(SNRsum==max(SNRsum));