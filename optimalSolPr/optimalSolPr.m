function [tVec, r_ab, DDVec, refSat]=optimalSolPr(D, eph, sets)
%Calculate the optimal solution in a leat square sense. Working on a
%weighted matrix solution including a covariance matrix
%IN:
%D          STRUCT ARRAY, with difference calculations between rec_a and rec_b
%eph,       ephemeris data for satellites to calculate the position
%OUT:
%tVec,      ARRAY, time [s] since startup
%r_ab,      ARRAY[2D], momentary position estimates from optimal solution of pr
%DDVec,     cell,struct: Double difference over time. 


%residual,  ARRAY[2D], reconstruction error per satellite measurement

%Max value of the distance vector
i_max=size(D,2);
%Distance vector
r_ab        = zeros(3,i_max);
tVec        = zeros(1,i_max);
%residual    = zeros(200,length(D));

%If the same sattelite is used for each epoch, use these:
persistentSats=findPersistentSats(D);
%We'll use the first satellite for reference all epochs
refSat=persistentSats.sats(1);

%Use only GPS-signals
eph=eph([eph(:).sat]<33);

%Create cell array to get Double difference over time
DDVec=cell(32,1);
for i=1:length(D)
    if mod(i,1000)==0
        i
    end
    if size(D(i).sat, 1)<4
        continue
    end
    [~, iE, iD]=intersect([eph.sat], [D(i).sat]);
    eph_i=eph(iE);
    D_i=D(i);
    D_i.dp=D_i.dp(iD);
    D_i.sat=D_i.sat(iD);
    [~, D_i.ToW]=UTC_in_sec2GPStime(D_i.ToW);
    Xs=zeros(size(eph_i,2),3);
    %Get satellite position from ephemerides data at time of arrival
    for j=1:length(eph_i)
       [xs, ys, zs]=get_satellite_position(eph_i(j),D_i.ToW);
       Xs(j,:)=[xs, ys, zs];
    end
    %Define all unit vectors pointing to the satellites
    u=(Xs-sets.posECEF)./vecnorm(Xs-sets.posECEF,2,2);
    %Find reference satellite index in D_i
    sat_idx=find(D_i.sat==refSat);
    if isempty(sat_idx)
        continue
    end
    %Define double difference as DD=D_i-D_j where D_j=median(D)
    try
    %DD                      =D(i).dp(iD)-D(i).dp(iD(median_id));
    DD                      =D_i.dp-D_i.dp(sat_idx);
    
    catch EM
        keyboard
    end
    %Remove that value corresponding to D_j from the solution (D_j-D_j:=0)
    DD(sat_idx)   =[];
    %Store all measurements in a cell-structure for later plotting
    DD_sats=D_i.sat(D_i.sat~=refSat);
    %Difference in direction vector u_i-u_j for 2 satellites
    dU            = u-u(sat_idx);
    dU(sat_idx,:) =[];
    
    for j=1:length(DD_sats')
            if (~isempty(DDVec{(DD_sats(j))}))
                DDVec{DD_sats(j)}.DD(end+1)=DD(j);
                DDVec{DD_sats(j)}.dU(end+1,:)=dU(j,:);
                DDVec{DD_sats(j)}.ToW(end+1)=D_i.ToW;
            else
                DDVec{DD_sats(j)}.DD=DD(j);
                DDVec{DD_sats(j)}.dU=dU(j,:);
                DDVec{DD_sats(j)}.ToW=D_i.ToW;
                DDVec{DD_sats(j)}.satID=DD_sats(j);
                
            end
         
    end
       
    
    try
        
    %dU              =u(j).dir(iu,:)-u(j).dir(iu(median_u),:);
    
    catch EM
        keyboard
    end
    

    if length(DD)>=4
        dU                  = dU+sets.noise.noiseH*randn(size(dU)); %Adding gaussian noise to direction matrix
        
        %Create a matrix with the weights for all signals as per 
        %A GPS Pseudorange Based Cooperative Vehicular Distance Measurement Technique
        if(sets.optSol.Weights)
            W   = findWMatrix(D(i),iD, median_id);
        else
            W   = eye(size(dU,1));
        end
        %dP                  = inv(dU'*W*dU)*dU'*W*DD;
        dP                  = (dU'*W*dU)\(dU'*DD);
        r_ab(:,i)           = dP(1:3);
        %D_hat               = dU*dP;
        %residualRows        = D(i).sat((D(i).sat(iD)~=D(i).sat(iD(median_u))));
        %residual(residualRows,i) = DD-D_hat;
        
    else
        if(i>1)
            r_ab(:,i)=r_ab(:,i-1);
        end
    end
    
    tVec(i)=D_i.ToW;
end
%Remove some unused epochs and predefined structs
idx_to_remove=[];
for i=1:length(DDVec)
    if isempty(DDVec{i})
        idx_to_remove(end+1)=i;
    end
end

DDVec(idx_to_remove)=[];
tVec(sum(r_ab)==0)=[];
r_ab(:,sum(r_ab)==0)=[];

end
