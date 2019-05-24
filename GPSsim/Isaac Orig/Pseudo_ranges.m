%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Version 1, June 2008, Copyright (C) 2008, Isaac Skog
%
% function call: [pseudo_ranges tr]=Pseudo_ranges(Traj);
%
% Inputs:   Traj=GPS receiver position trajectory in ECEF coordinates
%           
%
% Output:  pseudo_ranges
%          tr= clock error in meters 
%
% Global: simdata (struct including several settings used in the 
%                  simulation)
%
% This function simulates the pseudo range estimation of a GPS receiver.
% Ionospheric, Tropospheric, Ephemeric are XXXX
%
%
% More documentation on the usage of this function can be found in
% "README" file distributed with this program package.
%
% This program is a free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License 2 as
% published by the Free Software Foundation.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.
%
% If results obtained using this software or parts of it, are
% published the source of the code should be refereed to as a
% reference.
%
% Kindly report an bugs found in the software to: skog@kth.se
%
% Edit: Isaac Skog, skog@kth.se, 2008-09-15
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pseudo_ranges tr t]=Pseudo_ranges(Rec_pos_ecef)


global general_simsettings;
global gps_simsettings;

N=length(Rec_pos_ecef);

pseudo_ranges=zeros(31,N);

Ts=general_simsettings.Ts;


%% Get almanac data
almanac=Get_almanac_data(general_simsettings.start_time);

%% Get GPS time and generate time vector in seconds of GPS week
[week sec]=UTC2GPStime(general_simsettings.start_time);
t=sec:Ts:(sec+Ts*(N-1));

tr=rec_clock_dynamics(N);



for k=1:N

    for n=1:31
        [Sat_pos_ECEF Sat_pos_ECI]=Sat_pos(almanac(:,n),t(k));
        [range angle]=RangeandAngle(Sat_pos_ECEF,Rec_pos_ecef(:,k));

        if angle > simdata.mask_angle && almanac(2,n)==0;
            Sat_ID=almanac(1,n);
            pseudo_ranges(Sat_ID-1,k)=range+tr(1,k)+1e8/range^2*...
                simdata.sigma_pseudo_range*randn;
        end

    end

end





function tr=rec_clock_dynamics(N)

%% --------------- GPS receiver clock error ------------------------ 

% The GPS clock error is modeled according to the model on page 152 in 
% "The Global Positioning System and Inertial Navigation", J.A. Farrell 
% and B. Matthew. The clock error is in meters, i.e. scaled with the speed 
% of light.    

global general_simsettings;
global gps_simsettings;

Ts=general_simsettings.Ts;
c=gps_simsettings.c;

tr=zeros(2,N);

% Initial values
tr(1,1)=c*(2*0.001*rand-0.001);
tr(2,1)=c*0.01*(2*0.001*rand-0.001);
% State transition matrix
F=[1 Ts; 0 1];


% Noise covariance
S1=c^2*gps_simsettings.phase_error;  % Converted into meters by multiplying with c^2
S2=c^2*gps_simsettings.frequency_error;

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







