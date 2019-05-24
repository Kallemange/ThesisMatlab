function satCounts=findPersistentSats(D)
satCounts.sats=1:200;
satCounts.count=zeros(200,1)';

for i=1:length(D)
    SAT=D(i).sat;
    satCounts.count(SAT)=satCounts.count(SAT)+1;
    if any(SAT>100)
        keyboard
    end
end
maxCount        = max(satCounts.count);
maxIdx          = find(satCounts.count==maxCount);
satCounts.sats  = satCounts.sats(maxIdx);
satCounts.count = satCounts.count(maxIdx);


