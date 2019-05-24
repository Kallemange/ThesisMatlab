function W=findWMatrix(D, iD, indexD)
SNR=D.SNR(iD,:);
SNR(indexD,:)=[];
W=diag((SNR(:,1).^2).*(SNR(:,2).^2)./(SNR(:,1).^2)+(SNR(:,2).^2));

