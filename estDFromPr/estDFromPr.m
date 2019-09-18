function D=estDFromPr(r1,r2, sets)

%Find times that both sensors are active for raw data
%IN data1, data2, name of sorting variable
%OUT vector subset of valid indices wrt time
[t1raw, ~, t0r]     = findFirstLast(r1, r2);
t1idx   =t1raw(1):t1raw(end);
% for i=t1idx(1):t1idx(2)
%     t_decimal=r1(i).ToW-floor(r1(i).ToW);
%     [~, t] = UTC_in_sec2GPStime(r1(i).ToW);
%     t=t+t_decimal;
%     %calculate satellite positions from ephemeris data
%     Xs=zeros(length(eph), 3);
%     Xs_azel=zeros(length(eph), 2);
%     for j=1:length(eph)
%         [x, y, z]=get_satellite_position(eph(j),t);
%         Xs(j,:)=[x, y, z];
%         [az_, el_]=get_satellite_az_el(x,y,z,sets.posECEF(1), sets.posECEF(2), sets.posECEF(3));
%         Xs_azel(j,:)=[az_, el_];
%     end
% end


%Finds the satellites shared between r1, r2 and s1. Calculates the
%difference in pseudorange dp1-dp2 for each valid measurement
%IN raw data (1 and 2), valid times indices (1 and 2), valid satellites
%OUT cell-struct containing the pseudorange difference, sat ToW


