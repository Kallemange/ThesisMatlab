%Följande skall presenteras 
% Jag skall ta fram grafer och värden för följande
% 
% 1) Positions from INS and from my estimates in ECEF
% 2) Positions from INS and from my estimates in lla
% 3) Positions from INS and from my estimates in NED
% 4) DOP-värden
% 5) DD inklusive satellit-nummer
% 6) std-avvikelse värden
% 7) Satellitpositioner över tid
% 8) r_ab i NED över tid 

%Receiver position (from INS-data)
posRec=lla2ecef([59.3528910, 18.0730575, 30.94]);
[tVec, HVec, elevAzim, rECEF, r_weighted, DDVec ]= estRelPos(raw1, raw2, eph, posRec);

% 1) Positions from INS andfrom my estimates in ECEF
[x1 t1]=estGlobalPos(raw1, eph, 10001, 100);
[x2 t2]=estGlobalPos(raw2, eph, 10001, 100);

save('meeting0625Ndata.mat')
%%
figure(1)
sgtitle(strcat('Individual estimates from obs data over time, x0 in lla=', num2str(ecef2lla(x1(1,:)))))
for i=1:3
    XYZ='XYZ';
    subplot(3,1,i)
    hold on
    plot(t1-t1(1),x1(:,i)-x1(1,i))
    plot(t2-t1(1),x2(:,i)-x1(1,i))
    xlabel(strcat(XYZ(i), '-position, mean: x1:', 32,...
            num2str(mean(x1(:,i)-x1(1,i))), 32, 'x2: ', 32, ...
            num2str(mean(x2(:,i)-x1(1,i))), 32, ...
            'std-dev: x1:', 32, num2str(sqrt(var(x1(:,i)))), 32,...
                              'x2: ', 32, num2str(sqrt(var(x2(:,i))))))
end
%% 

%% 3) DOP-värden
L=length(HVec);
[lambda, phi, h] = WGStoEllipsoid(posRec(1), posRec(2), posRec(3));
% Calculate Rotation Matrix to Convert ECEF to local ENU reference
% frame
lat = phi*180/pi;
lon = lambda*180/pi;
R1=rot(90+lon, 3);
R2=rot(90-lat, 1);
R=R2*R1;
HDOP=zeros(1,L);
VDOP=zeros(1,L);
for i=1:L
    H_ = HVec{i}*R';
    H=inv(H_'*H_);
    HDOP(i)=sqrt(H(1,1)+H(2,2));
    VDOP(i)=sqrt(H(3,3));
end
figure(3)
sgtitle('DOP-values from double differenced geometry matrix')
subplot(2,1,1)
plot(tVec-tVec(1),VDOP)
xlabel('VDOP over time')
subplot(212)
plot(tVec-tVec(1),HDOP)
xlabel('HDOP over time')


%% 4) DD values
DDidx=find(sum(DDVec,2)~=0);
figure(4)
plot(tVec-tVec(1),DDVec(DDidx,1:100:end)')
DDtext=num2str(DDidx);
legend(DDtext)
sgtitle('DD over time')

%% 7) Satellite positions over time
L=length(elevAzim);
elev=zeros(32, L);
azim=zeros(32, L);
for i=1:L
    idx = elevAzim{i}.sats;
    elev(idx,i)=elevAzim{i}.elev;
    azim(idx,i)=elevAzim{i}.azim;
end
figure(7)
sgtitle('Elevation and Azimuth of satellites over time')
subplot(211)
satID = find(sum(elev,2)~=0);
plot(tVec-tVec(1),elev(satID,:))
legend(num2str(satID))
xlabel('elevation')
subplot(212)
plot(tVec-tVec(1),azim(satID,:))
xlabel('azimuth')
legend(num2str(satID))

%% 8) r_ab in NED over time
figure(8)
sgtitle('NED estimate over time')
for i=1:3
    NED='NED';
    subplot(3,1,i)
    plot(tVec-tVec(1), rECEF(i,:))
    xlabel(strcat(NED(i), '-direction, \sigma: ', num2str(sqrt(var(rECEF(i,:))))))
end
%% 9) r_ab weigthed using SNR in NED over time
figure(9)
sgtitle('weighted NED estimate over time')
for i=1:3
    NED='NED';
    subplot(3,1,i)
    plot(tVec-tVec(1), r_weighted(i,:))
    xlabel(strcat(NED(i), '-direction, \sigma: ', num2str(sqrt(var(r_weighted(i,:))))))
end