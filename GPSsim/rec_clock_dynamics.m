function tr=rec_clock_dynamics(N)

%% --------------- GPS receiver clock error ------------------------ 

% The GPS clock error is modeled according to the model on page 152 in 
% "The Global Positioning System and Inertial Navigation", J.A. Farrell 
% and B. Matthew. The clock error is in meters, i.e. scaled with the speed 
% of light.    

global gps_simsettings;

c=gps_simsettings.speed_of_light;

tr=zeros(2,N);

% Initial values
tr(1,1)=c*(2*0.001*rand-0.001);
tr(2,1)=c*0.01*(2*0.001*rand-0.001);
% State transition matrix
F=[1 Ts; 0 1];


% Noise covariance
S1=c^2*gps_simsettings.frequency_error;  % Converted into meters by multiplying with c^2
S2=c^2*gps_simsettings.phase_error;

Q=zeros(2);
Q(1,1)=S1*Ts+Ts^3/3*S2;
Q(2,1)=Ts^2/2*S2;
Q(1,2)=Q(2,1);
Q(2,2)=S2*Ts;
sqrtQ=sqrt(Q);

for k=1:N-1
    tr(:,k+1)=F*tr(:,k)+sqrtQ*randn(2,1);
    
    % The clock error can't get larger than 1ms
    if tr(1,k+1)>0.001*c
       tr(1,k+1)=0.001*c-tr(1,k+1);
    
    elseif tr(1,k+1)<-0.001*c
       tr(1,k+1)=tr(1,k+1)+0.001*c;
    end
end

return;