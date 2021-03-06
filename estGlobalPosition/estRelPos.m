function [tVec, HVec, elevAzim, rECEF, rECEF_weighted, DDVec ]= estRelPos(r1, r2, eph, pos_rec)
%THROUGH THESE CALCULATIONS, ASSUME REC1 IS USED AS REFERENCE, R2 WILL BE 
%CALCULATED AND INTERPOLATED WRT IT.
%Estimate the relative position from raw data.
%In two steps
       %a)Relative positioning from global estimates, broken down into
       %different steps:
            %1) Use the same eph-data
            %2) Use different eph-data
            %3) Use joint eph-data
            %4) Increase the eph-data complexity, taking the latest message
            %into account rather than just the first
       %b)Relative estimates from DD-method
            %1) Calculate the vector from a static transformation of known
                %position of receiver
            %2) Don't estimate the clock biases
            %3) Estimate satellite clock bias
            %4) Estimate receiver clock bias
            %3) Calculate vector from iterative steps as in estGlobalPos

c = 299792458;
%Find those indices where both receivers are active
[r1, r2]=findValidTimeIndices(r1,r2);
L=length(r1);
if nargin<4
    pos_rec=estGlobalPos(r1, eph, 1,1);
end
posLLA=ecef2lla(pos_rec);
R1=rot(90+posLLA(1), 3);
R2=rot(90-posLLA(2), 1);
R=R2*R1;
%Calculate the unit vector to the satellites
rECEF=[];
rNED=[];
rECEF_weighted=[];
eph=eph([eph(:).sat]<=32);
D1Vec=zeros(89,10);
D2Vec=zeros(89,10);
DDVec=zeros(89,10);
%DOP matrix
HVec={};

%Elevation and azimuth angle vectors
elevAzim={};
tVec=[];
for i=1:100:10001
    i
    t=unix2GPSTime(r1(i).ToW);
    tVec(end+1)=t;
    t2_low=find([r2(:).ToW]<r1(i).ToW, 1, 'last');
    t2_high=find([r2(:).ToW]>r1(i).ToW, 1, 'first');
    w=findWeights(r1(i).ToW, r2(t2_low).ToW, r2(t2_high).ToW);
    %Find which observations we can use
    [r1_t, r2_low, r2_high, eph_t]=intersectObs(r1, r2, t2_low, t2_high, eph, i);
    dsv = zeros(size(eph_t));
    obs = r1_t.P;
    for j=1:length(eph_t)
        dsv(j) = estimate_satellite_clock_bias(t, eph_t(j));   
    end
    cpr=obs+dsv'*c;
    % Signal transmission time
    tau = cpr/c;
    
    satID=[eph_t(2:end).sat];
    satPos=zeros(length(eph_t),3);
    azVec=zeros(length(eph_t),1);
    elVec=zeros(length(eph_t),1);
    for j=1:length(eph_t)
        [xs, ys,zs]=get_satellite_position(eph_t(j), t-tau(j), 1);
        satPos(j,:)=[xs, ys, zs];
        [azVec(j) elVec(j)]=get_satellite_az_el(xs, ys, zs, pos_rec);
    end
    elAz_t.sats = [eph_t(:).sat]';
    elAz_t.azim = azVec;
    elAz_t.elev = elVec;
    elevAzim{end+1}=elAz_t;
    %Find the direction matrix from rec->sv
    G=directionMatrix(satPos, pos_rec);
    H=G(2:end,:)-G(1,:);
    D1=r1_t.P(2:end)-r1_t.P(1);
    D2=[r2_low.P(2:end)-r2_low.P(1) r2_high.P(2:end)-r2_high.P(1)]*w';
    DD=D1-D2;
    HVec{end+1}=H;
    r_ab=inv(H'*H)*H'*DD;
    W=diag(((r1_t.SNR(2:end).^2).*(r2_low.SNR(2:end).^2))./((r1_t.SNR(2:end).^2)+(r2_low.SNR(2:end).^2)));
    r_weighted=inv(H'*W*H)*H'*W*DD;
    rECEF(:,end+1)=r_ab;
    rECEF_weighted(:,end+1)=r_weighted;
    rNED(:,end+1)=R*r_ab;
    D1Vec(satID, i)=D1; 
    D2Vec(satID, i)=D2;
    DDVec(satID, i)=DD;
end
plotOut=0;
if(plotOut)
    figure
    NED=['N', 'E', 'D'];
    for i=1:3
        subplot(3,1, i)
        plot(rNED(i,:))
        xlabel(strcat('distance in ', 32, NED(i)))
    end
    
    figure
    subplot(3,1,1)
    D1idx=find(sum(D1Vec,2)~=0);
    plot([D1Vec(D1idx,:)]')
    xlabel('D1 vector')
    subplot(3,1,2)
    D2idx=find(sum(D2Vec,2)~=0);
    plot(D2Vec(D2idx,:)')
    xlabel('D2 vector')
    subplot(313)
    DDidx=find(sum(DDVec,2)~=0);
    plot(DDVec(DDidx,:)');
    xlabel('DD vector')
end

    
%PART B3)
%for j=1:length(eph_t)
%     dsv(j) = estimate_satellite_clock_bias(t, eph_t(j));   
%end


   


%[x1 t1]=estGlobalPos(raw1, eph, 100, 10);
%[x2 t2]=estGlobalPos(raw2, eph, 100, 10);
%figure
% for i=1:3
%     subplot(3,1,i)
% plot(t1-t1(1), x1(:,i)-x1(1,i))
% hold on
% plot(t2-t1(1), x2(:,i)-x1(1,i))
% xlabel(strcat('mean: ', 32, num2str(mean(x1(:,i)-x1(1,i))), 32, num2str(mean(x2(:,i)-x1(1,i)))))
% end
% keyboard
end

function w=findWeights(t, t_l, t_h)
    if(t_l~=t_h)
        w=1-[t-t_l t_h-t]/(t_h-t_l);
    else
        w=[0.5 0.5];
    end

end

function [r1_t, r2_low, r2_high, eph_t]=intersectObs(r1, r2, t_low, t_high, eph, i)
    r1_t=sortrows(r1(i).data, 1);
    r2_low=sortrows(r2(t_low).data,1);
    r2_high=sortrows(r2(t_high).data,1);
    minimal_subset=r1(i).data.sat;
    [~, imin, ~]=intersect(minimal_subset, r2_low.sat);
    minimal_subset=minimal_subset(imin);
    [~, imin, ~]=intersect(minimal_subset, r2_high.sat);
    minimal_subset=minimal_subset(imin);
    [~, imin, ~]=intersect(minimal_subset, [eph(:).sat]);
    minimal_subset=minimal_subset(imin);
    
    r1_t      = removeNonIntersecting(r1_t, minimal_subset);
    r2_low    = removeNonIntersecting(r2_low, minimal_subset);
    r2_high   = removeNonIntersecting(r2_high, minimal_subset);
    [~, ie, ~]=intersect([eph(:).sat], minimal_subset);
    eph_t=eph(ie);
    
end

function [n1]=removeNonIntersecting(n1, n2)
    [~, i1, ~]=intersect(n1.sat, n2);
    n1=n1(i1,:);
end