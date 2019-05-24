function [tVec, r_ab]=optimalSolPrOld(D,u)
%Max value of the distance vector
i_max=min(size(u,2),size(D,2));
%Distance vector
r_ab=zeros(3,i_max);
tVec=zeros(1,i_max);

for i=1:i_max
    %try
    %Find all valid satellites
    [~,iD,iu]   =intersect(D(i).sat, u(i).sv); 
    
    %Find the index representing the median distance, the corresponding
    %satellite, and its index in u.
    [median_id, median_u]   =findMedianIndex(D(i),u(i),iD,iu);
    
    %Define double difference as DD=D_i-D_j where D_j=median(D)
    DD                      =D(i).dp(iD)-D(i).dp(iD(median_id));
    %Remove that value corresponding to D_j from the solution (D_j-D_j:=0)
    DD(median_id)   =[];
    try
    dU              =u(i).dir(iu,:)-u(i).dir(iu(median_u),:);
    catch EM
        keyboard
    end
    dU(median_id,:) =[];
    %Remove all the values which are too big
    %outlier_idx=find(abs(DD)>1e4);
    %DD(outlier_idx) =[];
    %dU(outlier_idx,:)=[];
    
    if length(DD)>=4
        dP=inv(dU'*dU)*dU'*DD;
        r_ab(:,i)=dP(1:3);
    else
        if(i>1)
            r_ab(:,i)=r_ab(:,i-1);
        end
    end
    tVec(i)=D(i).ToW;
end
tVec=tVec-D(1).ToW;




