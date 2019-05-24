%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function call: out_data=GPSaidedINS(in_data,settings)
%
% This function integrates GNSS and IMU data. The data fusion
% is base upon a loosely-coupled feedback GNSS-aided INS approach. 
%
% Input struct: 
% in_data.GNSS.pos_ned      GNSS-receiver position estimates in NED
%                           coordinates [m]
% in_data.GNSS.t            Time of GNSS measurements [s]
% in_data.IMU.acc           Accelerometer measurements [m/s^2]
% in_data.IMU.gyro          Gyroscope measurements [rad/s]
% in_data.IMU.t             Time of IMU measurements [s]
%
% Output struct:
% out_data.x_h              Estimated navigation state vector [position, velocity, attitude]  
% out_data.delta_u_h        Estimated IMU biases [accelerometers, gyroscopes]
% out_data.diag_P           Diagonal elements of the Kalman filter state
%                           covariance matrix.
%
%
% Edit: Isaac Skog (skog@kth.se), 2016-09-06
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out_data=GPSaidedINS(in_data,settings)


% Copy data to variables with shorter name
u=[in_data.IMU.acc;in_data.IMU.gyro];
t=in_data.IMU.t;
y=in_data.GNSS.pos_ned;


%% Initialization
% Initialize the navigation state
x_h=init_navigation_state(u,settings);

% Initialize the sensor bias estimate
delta_u_h=zeros(6,1);

% Initialize the Kalman filter
[P,Q1,Q2,R,H]=init_filter(settings);


% Allocate memory for the output data
N=size(u,2);
out_data.x_h=zeros(10,N);
out_data.x_h(:,1)=x_h;
out_data.diag_P=zeros(15,N);
out_data.diag_P(:,1)=diag(P);
out_data.delta_u_h=zeros(6,N);

%% Information fusion
ctr_gnss_data=1;
for k=2:N
    
    % Sampling period
    Ts=t(k)-t(k-1);
    
    % Calibrate the sensor measurements using current sensor bias estimate.
    u_h=u(:,k)+delta_u_h;
    
    
    % Update the INS navigation state
    x_h=Nav_eq(x_h,u_h,Ts);
    
    % Get state space model matrices
    [F,G]=state_space_model(x_h,u_h,Ts);
    
    % Time update of the Kalman filter state covariance.
    P=F*P*F'+G*blkdiag(Q1,Q2)*G';
    
    % Check if GNSS measurement is available
    if t(k)==in_data.GNSS.t(ctr_gnss_data)  
        
        %if t(k)<250 
            
        %R=4^2*diag([in_data.GNSS.HDOP(ctr_gnss_data) in_data.GNSS.HDOP(ctr_gnss_data) in_data.GNSS.VDOP(ctr_gnss_data)].^2);
        
        % Calculate the Kalman filter gain.
        K=(P*H')/(H*P*H'+R);
        
        % Update the perturbation state estimate.
        z=[zeros(9,1); delta_u_h]+K*(y(:,ctr_gnss_data)-x_h(1:3));
        
        % Correct the navigation states using current perturbation estimates.
        x_h(1:6)=x_h(1:6)+z(1:6);
        x_h(7:10)=Gamma(x_h(7:10),z(7:9));
        delta_u_h=z(10:15);
        
        % Update the Kalman filter state covariance.
        P=(eye(15)-K*H)*P;
        %end
        
        % Update GNSS data counter
        ctr_gnss_data=min(ctr_gnss_data+1,length(in_data.GNSS.t));
    end
    
    % Save the data to the output data structure
    out_data.x_h(:,k)=x_h;
    out_data.diag_P(:,k)=diag(P);
    out_data.delta_u_h(:,k)=delta_u_h;
    
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                          SUB-FUNCTIONS                                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Init filter          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,Q1,Q2,R,H]=init_filter(settings)


% Kalman filter state matrix
P=zeros(15);
P(1:3,1:3)=settings.factp(1)^2*eye(3);
P(4:6,4:6)=settings.factp(2)^2*eye(3);
P(7:9,7:9)=diag(settings.factp(3:5)).^2;
P(10:12,10:12)=settings.factp(6)^2*eye(3);
P(13:15,13:15)=settings.factp(7)^2*eye(3);

% Process noise covariance
Q1=zeros(6);
Q1(1:3,1:3)=diag(settings.sigma_acc).^2;
Q1(4:6,4:6)=diag(settings.sigma_gyro).^2;

Q2=zeros(6);
Q2(1:3,1:3)=settings.sigma_acc_bias^2*eye(3);
Q2(4:6,4:6)=settings.sigma_gyro_bias^2*eye(3);

% GNSS-receiver position measurement noise
R=settings.sigma_gps^2*eye(3);

% Observation matrix
H=[eye(3) zeros(3,12)];

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Init navigation state     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x_h=init_navigation_state(u,settings)


% Calculate the roll and pitch
f=mean(u(:,1:100),2);
roll=atan2(-f(2),-f(3));
pitch=atan2(f(1),norm(f(2:3)));

% Initial coordinate rotation matrix
Rb2t=Rt2b([roll pitch settings.init_heading])';

% Calculate quaternions
q=dcm2q(Rb2t);

% Initial navigation state vector
x_h=[zeros(6,1); q];

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  State transition matrix   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,G]=state_space_model(x,u,Ts)

% Convert quaternion to DCM
Rb2t=q2dcm(x(7:10));

% Transform measured force to force in
% the tangent plane coordinate system.
f_t=Rb2t*u(1:3);
St=[0 -f_t(3) f_t(2); f_t(3) 0 -f_t(1); -f_t(2) f_t(1) 0];

% Only the standard errors included
O=zeros(3);
I=eye(3);
Fc=[O I O O O;
    O O St Rb2t O;
    O O O O -Rb2t;
    O O O O O;
    O O O O O];

% Approximation of the discret
% time state transition matrix
F=eye(15)+Ts*Fc;

% Noise gain matrix
G=Ts*[O O O O; Rb2t O O O; O -Rb2t O O; O O I O; O O O I];
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     Error correction of quaternion    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q=Gamma(q,epsilon)

% Convert quaternion to DCM
R=q2dcm(q);

% Construct skew symetric matrx
OMEGA=[0 -epsilon(3) epsilon(2); epsilon(3) 0 -epsilon(1); -epsilon(2) epsilon(1) 0];

% Cortect the DCM matrix
R=(eye(3)-OMEGA)*R;

% Calculte the corrected quaternions
q=dcm2q(R);
return








