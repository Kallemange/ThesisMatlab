function s1=makeSatLog(almanac_data, L,rec1, svID, t, N, sets)
CNO=25*ones(length(svID), 1);
for i=1:L
    elev            = zeros(N,1);
    azim            = zeros(N,1);
    allSatsECEF     = zeros(3, N);
    
    for j=1:N
    [satPosECEF, satPosECI]         = Sat_pos(almanac_data(:,j), t(i));
    allSatsECEF(:,j)                = satPosECEF;
    [~, elev(j), azim(j)]    = RangeandAngle(satPosECEF, rec1(:,i), sets);
    end
    if sets.noise.round
        elev=round(elev);
        azim=round(azim);
    end
    data            = table(svID,CNO, elev, azim);
    s1(i).ToW       = t(i);
    s1(i).numSats   = sum(elev>0);
    validSats       = find(data.elev>0);
    data            = data(validSats,:);
    s1(i).data      = data;
end
