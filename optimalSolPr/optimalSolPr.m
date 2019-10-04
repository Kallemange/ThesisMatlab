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
if sets.optSol.OnlyGPS              % If true -> Use only GPS-signals
    eph=eph([eph(:).sat]<33);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Instantiate data
i_max=size(D,2);                    % Max value of the distance vector
r_ab        = zeros(3,i_max);       % Distance vector between receivers
tVec        = zeros(1,i_max);       % Time vector
refSat.ID   = [];                   % Information on which sv is used for reference
refSat.elAz = [];                   % and corresponding el-az data
DDVec=cell(eph(end).sat,1);         % Create cell array to get Double difference over time

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
    [Xs, u]=get_all_sats_pos(eph_i, D_i.ToW, sets.posECEF);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find reference satellite for the epoch
    sat_idx=find(D_i.SNR==max(D_i.SNR), 1, 'first');
    refSat=D_i.sat(sat_idx);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Create all the el-az values for the satellites, to reference with what
    %it should be in the readings as well as sorting out the low sats
    [az, el]                     = ecef2elaz(Xs,sets.posECEF);
    [elAz, DD, SNR, dU, DD_sats] = remove_low_sats(D_i, u, az, el, sat_idx, sets.optSol.elMask);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Populate DDVec with observations from current epoch
    DDVec=fillDDVec(DDVec, DD_sats, DD,dU, elAz, D_i.ToW);
    if length(DD)>=4
        %Create weighted matrix
        if(strcmp(sets.optSol.Weights,"SNR"))
            W   = findWMatrix(SNR, "SNR", D_i.SNR(sat_idx));
        elseif (strcmp(sets.optSol.Weights,"elev"))
            W   = findWMatrix(elAz(:,1), "elev");           
        elseif (strcmp(sets.optSol.Weights, "elevSNR"))
            W   = findWMatrix([elAz(:,1) SNR], "elevSNR");
        else
            W   = 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Weighted least squares solution to double difference problem
        dP                  = (dU'*W*dU)\(dU'*W*DD);
        r_ab(:,i)           = dP;
    end
    tVec(i)=D_i.ToW;
end
[DDVec, tVec, r_ab]=removeEmptyEpochs(DDVec, tVec, r_ab);
end

function [elAz, DD, SNR, dU, DD_sats]=remove_low_sats(D, u, az, el, idx, elMask)
    %Remove all sv's below elevation mask value from current observation
    %vector
    elAz                    = [el(el~=el(idx)),az(az~=az(idx))];
    lowSats                 = elAz(:,1)<elMask;
    DD                      = D.dp-D.dp(idx);
    SNR                     = D.SNR;
    SNR(idx)                = [];
    %Remove that value corresponding to D_j from the solution (D_j-D_j:=0)
    DD(idx)                 = [];
    %Store all measurements in a cell-structure for later plotting
    DD_sats                 = D.sat(D.sat~=D.sat(idx));
    %Difference in direction vector u_i-u_j for 2 satellites
    dU                      = u-u(idx,:);
    dU(idx,:)               = [];    
    DD(lowSats)             = [];
    DD_sats(lowSats)        = [];
    dU(lowSats,:)           = [];
    SNR(lowSats)            = [];
    elAz(lowSats,:)         = [];
end

function [Xs, u]=get_all_sats_pos(eph, t, x0)
    %Get satellite positions and unit vector to that satellite from
    %ephemerides data at time of arrival and unit vector pointing to that
    %satellite
    Xs=zeros(size(eph,2),3);
    for j=1:length(eph)
       [xs, ys, zs]=get_satellite_position(eph(j),t);
       Xs(j,:)=[xs, ys, zs];
    end
    u=(Xs-x0)./vecnorm(Xs-x0,2,2);
end

function [DDVec, tVec, r_ab]=removeEmptyEpochs(DDVec, tVec, r_ab)
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
%Fill DDVec with all the information to output
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
    %Find the observations which correspond to an ephemeris data
    %observation in current epoch
    week=eph(1).week;
    eph_i=eph(iE);
    D_i.dp=D.dp(iD);
    D_i.sat=D.sat(iD);
    D_i.SNR=D.SNR(iD);
    [~, D_i.ToW]=UTC_in_sec2GPStime(D.ToW, week);
end

function W=findWMatrix(value, type, refVal)
%Calculate a weighted diagonal matrix to use in the WLS either as function
%of SNR or as function of elevation. 
%Default case: I-matrix
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
        case "elevSNR"
            %Weighting models for GPS Pseudorange observationsfor land transportation in urban canyons
            W=diag(10.^(-0.1*value(:,2))./(sind(value(:,1))).^2);
        otherwise
            W = 1;
    end
end