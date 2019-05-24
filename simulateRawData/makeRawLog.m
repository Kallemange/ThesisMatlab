function r1=makeRawLog(almanac_data, L,rec1, sat, t, N, sets)
SNR=100*ones(length(sat), 1);
for i=1:L
    range           = zeros(N, 1); 
    elev            = zeros(N,1);
    azim            = zeros(N,1);
    allSatsECEF     = zeros(3, N);
    for j=1:N
    [satPosECEF, satPosECI]         = Sat_pos(almanac_data(:,j), t(i));
    allSatsECEF(:,j)                = satPosECEF;
    [range(j), elev(j), azim(j)]    = RangeandAngle(satPosECEF, rec1(:,i), sets);
    end
    P      = simPr(range, sets, i);
    data    = table(sat,SNR, elev, P);
    r1(i).ToW = t(i);
    r1(i).numSats   = sum(elev>0);
    data            = data(data.elev>sets.sim.minElev,:);
    data            = data(rand(length(data.sat),1)>=sets.sim.skipSats,:); %Remove random satellites
    r1(i).data      = data;
end