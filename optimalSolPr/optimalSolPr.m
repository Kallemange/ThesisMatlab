function [tVec, r_ab, DDVec, refSat]=optimalSolPr(D, eph, sets)
%{
Calculate the optimal solution in a leat square sense.
IN:
    D, Struct[]:        Observation difference rec_1-rec_2, with fields
        dp, double[]:       P_1-P_2 pseudorange difference
        sat, int[]:         svID for the observations
        ToW, double:        Time of observation (UNIX-time [s])
    eph, struct[]:      Ephemeris data for satellites to calculate the position
    sets, struct:       Calculations settings, fields:
        sim, struct:    Simulation data, fields:
            dist, double[]:         receiver distance
            t, double[]:            observation time [s]
            skipT, function(t):     random skipping of satellites
            skipSats, double:       % of skipping satellite
            minElev, double:        minimal elevation for sv [deg]
            clockError, double:     receiver clock bias [s]
        noise, struct:
        optSol:
        plots:
        posECEF:
        posLLA:
OUT:
    tVec,   double[]:       time [s] since startup
    r_ab,   double[3][]:    momentary relative position estimate
    DDVec,  cell[]:     Double difference over time per satellite, field:
        DD, double[]:       Double differenced obs
        dU: double[][3]:    Differenced direction vector p_sat-p_rec
        ToW: double[]:      Time of week (GPST [s])
        satID, int[]:       svID
    refSat, int[]:      sv used as reference

%}
%Max value of the distance vector
i_max=size(D,2);
%Distance vector
r_ab        = zeros(3,i_max);
tVec        = zeros(1,i_max);

%If the same sattelite is used for each epoch, use these:
persistentSats=findPersistentSats(D);
%We'll use the first satellite for reference all epochs
refSat.ID=persistentSats.sats(1);
refSat.elAz=[];

%Use only GPS-signals
if sets.optSol.OnlyGPS
    eph=eph([eph(:).sat]<33);
end
%Create cell array to get Double difference over time
DDVec=cell(eph(end).sat,1);
for i=1:length(D)
    if size(D(i).sat, 1)<4
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Select the observations with a corresponding eph for the current epoch
    [~, iE, iD]=intersect([eph.sat], [D(i).sat]);
    [D_i, eph_i]=selectObsFromEph(D(i), eph, iD, iE);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get satellite position and unit vector to satellite
    Xs=zeros(size(eph_i,2),3);
    %Get satellite position from ephemerides data at time of arrival
    for j=1:length(eph_i)
       [xs, ys, zs]=get_satellite_position(eph_i(j),D_i.ToW);
       Xs(j,:)=[xs, ys, zs];
    end
    %Define all unit vectors pointing to the satellites
    u=(Xs-sets.posECEF)./vecnorm(Xs-sets.posECEF,2,2);
    %Find reference satellite index in D_i
    sat_idx=find(D_i.sat==refSat.ID);
    if isempty(sat_idx)
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Create all the el-az values for the satellites, to reference with what
    %it should be in the readings as well as sorting out the low sats
    [az, el]                = ecef2elaz(Xs,sets.posECEF);
    refSat.elAz(end+1,:)    = [el(el==el(sat_idx)),az(az==az(sat_idx))];
    elAz                    = [el(el~=el(sat_idx)),az(az~=az(sat_idx))];
    lowSats                 = elAz(:,1)<sets.optSol.elMask;
    DD                      = D_i.dp-D_i.dp(sat_idx);
    SNR                     = D_i.SNR;
    SNR(sat_idx)            = [];
    %Remove that value corresponding to D_j from the solution (D_j-D_j:=0)
    DD(sat_idx)             = [];
    %Store all measurements in a cell-structure for later plotting
    DD_sats                 = D_i.sat(D_i.sat~=refSat.ID);
    %Difference in direction vector u_i-u_j for 2 satellites
    dU                      = u-u(sat_idx,:);
    dU(sat_idx,:)           = [];    
    DD(lowSats)             = [];
    DD_sats(lowSats)        = [];
    dU(lowSats,:)           = [];
    SNR(lowSats)            = [];
    DDVec=fillDDVec(DDVec, DD_sats, DD,dU, elAz, D_i.ToW);
    if length(DD)>=4
        %Create weighted matrix
        if(strcmp(sets.optSol.Weights,"SNR"))
            W   = findWMatrix(SNR, "SNR", D_i.SNR(sat_idx));
        elseif (strcmp(sets.optSol.Weights,"elev"))
            el(sat_idx)=[];
            el(lowSats)=[];
            W   = findWMatrix(el, "elev");           
        else
            W   = 1;
        end
        try
        dP                  = (dU'*W*dU)\(dU'*W*DD);
        catch 
            keyboard
        end
        r_ab(:,i)           = dP;
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
function DDVec=fillDDVec(DDVec, DD_sats, DD,dU, elAz, t)
    for j=1:size(DD_sats,1)
            if (~isempty(DDVec{(DD_sats(j))}))
                DDVec{DD_sats(j)}.DD(end+1)=DD(j);
                DDVec{DD_sats(j)}.dU(end+1,:)=dU(j,:);
                DDVec{DD_sats(j)}.elAz(end+1,:)=elAz(j,:);
                DDVec{DD_sats(j)}.ToW(end+1)=t;
                
            else
                DDVec{DD_sats(j)}.DD=DD(j);
                DDVec{DD_sats(j)}.dU=dU(j,:);
                DDVec{DD_sats(j)}.elAz=elAz(j,:);
                DDVec{DD_sats(j)}.ToW=t;
                DDVec{DD_sats(j)}.satID=DD_sats(j);
                
            end
    end
end

function [D_i, eph_i]=selectObsFromEph(D, eph, iD, iE)
    week=eph(1).week;
    eph_i=eph(iE);
    D_i.dp=D.dp(iD);
    D_i.sat=D.sat(iD);
    D_i.SNR=D.SNR(iD);
    [~, D_i.ToW]=UTC_in_sec2GPStime(D.ToW, week);
end

function W=findWMatrix(value, type, refVal)
    switch type
        case "SNR"
            %Create a matrix with the weights for all signals as per 
            %A GPS Pseudorange Based Cooperative Vehicular Distance Measurement Technique
            W = diag((refVal^2)*value.^2./(refVal^2+value.^2));
        case "elev"
            %POSSIBLE WEIGHTING SCHEMES FOR GPS CARRIER PHASE OBSERVATION
            %1.001/[0.002001+SIN^2(ELEV)]^0.5
            %W = diag(1.001./(0.002001+sind(value).^2).^0.5);
            %W=diag(sind(value).^-2);
            %Enhancing Least Squares GNSS Positioning with3D Mapping without Accurate Prior Knowledge
            sigma=0.13+0.56*exp(-pi/180*value/0.1745);
            W=diag(sigma.^-2);
        otherwise
            W = 1;
    end
end