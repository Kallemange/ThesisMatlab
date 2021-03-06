function dPr=calcDiffPr(r1,r2,t1, sets)
%{
Calculation of the difference in pseudorange per each measurement. For each
matching sv: dP:=r1.P1-r2.P2. If times not equal, r1.ToW(i)=\=r2.ToW(j) for some i,j, 
P2 is interpolated. 
Interpolation is performed as:
    If r2.ToW(j)<r1.ToW(i)&&r2.ToW(j+1)>r1.ToW(i)
    delta_t=r2.ToW(j+1)-r2.Tow(j)
    [w1 w2]=1-[r2.ToW(j+1)-r1.ToW(i) r1.ToW(i)-r2.ToW(j)]/delta_t

IN: 
    r1, struct[]: Observation data (receiver 1) with fields:
        numSats, int[]: #observed Satellites
        ToW, double[]:  Time of observation (UNIX-time [s])
        data, [][5]:    Satellite, SNR, LLI, code, P information matrix
    t1, double[]:       Time vector for first&last index when both
                        receivers are active
OUT:
    dPr, struct[]: Pseudorange difference with fields:
        dp, double[]:   difference observation P1-P2, interpolated for ToW_1=\=ToW_2
        sat, int[]:     svID for difference
        ToW, double:    Time of observation (UNIX-time [s])
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predefine structs
idx_to_remove=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Anonymous functions
%Indexing function to get the column in the dataset
I =@(var) find(["sat", "SNR", "LLI", "code", "P"]==var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=1;
L=length(r2);
for i=t1(1):t1(2)
    raw1 = r1(i);
    while k<L-1
        if r2(k+1).ToW>raw1.ToW
            break
        else
            k=k+1;
        end
    end
    % If to perform interpolation of the observations between 
    % r2(j).ToW<r1.ToW and r2(j+1)>r1.ToW
    if sets.diffPr.interpol  
        r2IdLow     = k;
        r2IdHigh    = k+1;
        r2Low.ToW   = r2(r2IdLow).ToW;
        r2High.ToW  = r2(r2IdHigh).ToW;
        % Calculate the distance between observation in time, if both r2
        % low and high >threshold -> discard observation
        if (all(abs([r2Low.ToW r2High.ToW]-raw1.ToW)>sets.diffPr.threshold_t))
            idx_to_remove(end+1) = i;
            continue
        end
        [~, r2idxL, r2idxH]    = intersect(r2(r2IdLow).data(:,I("sat")), r2(r2IdHigh).data(:,I("sat")));
        r2Low.data             = r2(r2IdLow).data(r2idxL,:);
        r2High.data            = r2(r2IdHigh).data(r2idxH,:);
        
        if (r2Low.ToW==r2High.ToW)
            w                  = 0.5*[1 1];
        else
            w                  = [(raw1.ToW-r2Low.ToW) (r2High.ToW-raw1.ToW)]/(r2High.ToW-r2Low.ToW);
        end
        if (sum(w)~=1||any(w<0))
            keyboard
        end
        raw2.data              = r2Low.data;
        raw2.data(:,I("P"))    = r2Low.data(:,I("P"))*w(2)+r2High.data(:,I("P"))*w(1);
    else %Don't interpolate
        [~, closest_idx]       = min([raw1.ToW-r2(k).ToW r2(k+1).ToW-raw1.ToW]);
        raw2                   = r2(k+closest_idx-1);   
        %If the observations are too far apart in time, discard it
        if abs(raw2.ToW-raw1.ToW)>sets.diffPr.threshold_t
            idx_to_remove(end+1)=i;
            continue
        end
        
    end 

    [~, i1, i2]            = intersect(raw1.data(:,I("sat")), raw2.data(:,I("sat")));
    dPr(i).dp              = raw1.data(i1,I("P"))-raw2.data(i2,I("P"));
    dPr(i).sat             = raw1.data(i1,I("sat"));
    dPr(i).SNR             = [raw1.data(i1,I("SNR")) raw2.data(i2,I("SNR"))];
    dPr(i).ToW             = raw1.ToW; 
end
dPr(idx_to_remove)=[];
end
