%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Version 1, June 2008, Copyright (C) 2008, Isaac Skog
%
% function call: [pos_ECEF pos_ECI]=Sat_pos(Almanac,t);
%
% Inputs:   Almanac=Almanac_data_structure
%           t=time in seconds of the GPS week
%
% Output:  [pos_ECEF pos_ECI]=position (xyz) in ECEF and ECI coordinates
%
% This function calculate a satellites position for a given time.
% Based upon Table E.2 in  "The Global Positioning System and Inertial
% Navigation", J.A. Farrell and B. Matthew. For further references,
% see "Navstar global Positioning System, Interface specification".
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

function [pos_ECEF pos_ECI]=Sat_pos(almanac_data,t)


%% ---------------- Fixed parameters (WGS 84)  -----------------
My=3.986005e14;             % Garvity constant [m^3/s^2]
wie=7.2921151467e-5;        % Earth's rotation rate [rad/s]


%% ---------------- Input parameters ---------------------------

% Set parameters
e=almanac_data(3);          % Eccentricity
toa=almanac_data(4);        % Time of Applicability [s]
i0=almanac_data(5);         % Orbital Inclination(rad)
Omega_dot=almanac_data(6);  % Rate of Right Ascen [r/s]
A=almanac_data(7)^2;        % Orbit semimajor axis [m]
Omega0=almanac_data(8);     % Longitude of Ascending Node
omega=almanac_data(9);      % Argument of Perigee [rad]
M0=almanac_data(10);        % Mean anomaly at toe
 

%% ------------------- Position calculation --------------------

n0=sqrt(My/A^3);            % Computed  mean motion [rad/s]

tk=t-toa;                   % Time from ephemeris refeence epoch [s]

                
if abs(tk)>24*60*60              
   % If the difference between t and the reference time of the almanac data
   % exceed 24 h other almanac should be used
   %WARNING('Check that the correct almanac has been loaded');
end


n=n0;%+dn;                  % Corrected mean motion (not posssible without
% ephemeris correction data % pi???????????

Mk=M0+n*tk;                  % Mean anomaly at time tk
Mk=mod(Mk,2*pi);

Ek=fzero(@(Ek) Ek-e*sin(Ek)-Mk, Mk); % Kepler's Equation for Eccentric Anomaly

nuk=atan2(sqrt(1-e^2)*sin(Ek),(cos(Ek)-e));     % True Anomaly
nuk=mod(nuk,2*pi);                              % Riktigt????

Ek=acos((e+cos(nuk))/(1+e*cos(nuk)));          % Eccentric Anomaly

Phik=nuk+omega;                               % Argument of lattitude [rad]

uk=Phik;%+du;                                 % Corrected value of latitude
rk=A*(1-e*cos(Ek));%+Delta_rk;                % Corrected radious

%Compute satellite vehicle position
%Satellite position in orbital plane
x_Perk=rk*cos(uk);
y_Perk=rk*sin(uk);


ik=i0;                                       %Inclination
Omegak=Omega0+Omega_dot*tk;


%Satellite Position in ECI
pos_ECI=zeros(3,1);
pos_ECI(1)=x_Perk*cos(Omegak)-y_Perk*cos(ik)*sin(Omegak);
pos_ECI(2)=x_Perk*sin(Omegak)+y_Perk*cos(ik)*cos(Omegak);
pos_ECI(3)=y_Perk*sin(ik);

Omegak=Omegak-wie*t;
%Satellite Position in ECEF
pos_ECEF=zeros(3,1);
pos_ECEF(1)=x_Perk*cos(Omegak)-y_Perk*cos(ik)*sin(Omegak);
pos_ECEF(2)=x_Perk*sin(Omegak)+y_Perk*cos(ik)*cos(Omegak);
pos_ECEF(3)=y_Perk*sin(ik);

 


