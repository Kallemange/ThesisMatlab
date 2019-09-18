function [tVec, r_ab]=optimalSolPr(D, eph, sets)
%Calculate the optimal solution in a leat square sense. Working on a
%weighted matrix solution including a covariance matrix
%IN:
%D          STRUCT ARRAY, with difference calculations between rec_a and rec_b
%OUT:
%tVec,      ARRAY, time [s] since startup
%r_ab,      ARRAY[2D], momentary position estimates from optimal solution of pr
%residual,  ARRAY[2D], reconstruction error per satellite measurement


Sigma=0;
%Max value of the distance vector
i_max=size(D,2);
%Distance vector
r_ab        = zeros(3,i_max);
tVec        = zeros(1,i_max);
residual    = zeros(200,length(D));

%If the same sattelite is used for each epoch, use these:
%persistentSats=findPersistentSats(D);
%refSatId=chooseRefSat(persistentSats, D);
%In the case of only using GPS
%refSatId=chooseRefSatGPSOnly(persistentSats, D);

for i=1:length(D)
    %try
    %Find which u to use (latest arrival wrt the raw data)
    j=find([u.ToW]-u(1).ToW<=D(i).ToW, 1, 'last');
    %Find all valid satellites
    [~,iD,iu]   =intersect(D(i).sat, u(j).sv); 
    
    %Find the index representing the median distance, the corresponding
    %satellite, and its index in u.
    if strcmp(sets.optSol.sats,'median')
        [median_id, median_u]   =findMedianIndex(D(i),u(j),iD,iu);
    elseif strcmp(sets.optSol.sats, 'minHDOP')
        [median_id, median_u]   = findMinHDOP(D(i),u(j),iD,iu);
    end
    
    %Define double difference as DD=D_i-D_j where D_j=median(D)
    try
    DD                      =D(i).dp(iD)-D(i).dp(iD(median_id));
    catch 
        keyboard
    end
    %Remove that value corresponding to D_j from the solution (D_j-D_j:=0)
    DD(median_id)   =[];
    try
        
    dU              =u(j).dir(iu,:)-u(j).dir(iu(median_u),:);
    catch EM
        keyboard
    end
    dU(median_u,:) =[];

    if length(DD)>=4
        dU                  = dU+sets.noise.noiseH*randn(size(dU)); %Adding gaussian noise to direction matrix
        
        %Create a matrix with the weights for all signals as per 
        %A GPS Pseudorange Based Cooperative Vehicular Distance Measurement Technique
        if(sets.optSol.Weights)
            W   = findWMatrix(D(i),iD, median_id);
        else
            W   = eye(size(dU,1));
        end
        dP                  = inv(dU'*W*dU)*dU'*W*DD;
        r_ab(:,i)           = dP(1:3);
        D_hat               = dU*dP;
        residualRows        = D(i).sat((D(i).sat(iD)~=D(i).sat(iD(median_u))));
        residual(residualRows,i) = DD-D_hat;
    else
        if(i>1)
            r_ab(:,i)=r_ab(:,i-1);
        end
    end
    
    tVec(i)=D(i).ToW;
end
Sigma=calcCovariance(residual);
end


