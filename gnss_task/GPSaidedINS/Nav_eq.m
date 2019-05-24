%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function call: x=Nav_eq(x,u,dt)
%
% Function that implements the navigation equations of an INS.
%
% Inputs:
% x         Current navigation state [position (NED), velocity (NED), attitude (Quaternion)]
% u         Measured inertial quantities [Specific force (m/s^2), Angular velocity (rad/s)]
% Ts        Sampling period (s)
%
% Output:
% x         Updated navigation state [position (NED), velocity (NED), attitude (Quaternion)]
%
% Edit: Isaac Skog (skog@kth.se), 2016-09-06
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x=Nav_eq(x,u,Ts)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          Position and velocity        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Gravity vector (This should depend on the current location, but
% since moving in a small area it is approximatly constant).
g_t=gravity(59,0);

f_t=q2dcm(x(7:10))*u(1:3);

% Subtract gravity, to obtain accelerations in tangent plane coordinates
acc_t=f_t-g_t;

% state space model matrices
A=eye(6);
A(1,4)=Ts;
A(2,5)=Ts;
A(3,6)=Ts;

B=[(Ts^2)/2*eye(3);Ts*eye(3)];

% Position and velocity update
x(1:6)=A*x(1:6)+B*acc_t;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        Attitude Quaternion            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quaternion algorithm according to Farrel, pp 49.

w_tb=u(4:6);

%Adding an error bias in gyro-x-axis
w_tb(1)=w_tb(1)+0.01*Ts;

P=w_tb(1)*Ts;
Q=w_tb(2)*Ts;
R=w_tb(3)*Ts;


OMEGA=zeros(4);
OMEGA(1,1:4)=0.5*[0 R -Q P];
OMEGA(2,1:4)=0.5*[-R 0 P Q];
OMEGA(3,1:4)=0.5*[Q -P 0 R];
OMEGA(4,1:4)=0.5*[-P -Q -R 0];

v=norm(w_tb)*Ts;

if v~=0
    x(7:10)=(cos(v/2)*eye(4)+2/v*sin(v/2)*OMEGA )*x(7:10);
end
return