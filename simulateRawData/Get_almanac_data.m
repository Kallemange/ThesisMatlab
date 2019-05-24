%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Version 1, June 2007, Copyright (C) 2007, Isaac Skog 
%
% function call: output=Get_almanac_data(Time);
%
% Input:
% Time=[year month day hour mminute sec];
% 
% Output:
% Output=[Almanac_1 ... Almanac_N],  N=number satelites avilable.  
% 
% Almanac data (by row)
% 1 Satelite ID
% 2 Health 
% 3 Eccentricity
% 4 Time of Applicability(s)
% 5 Orbital Inclination(rad)
% 6 Rate of Right Ascen(r/s)
% 7 SQRT(A)  (m 1/2)
% 8 Right Ascen at Week(rad)
% 9 Argument of Perigee(rad)
% 10 Mean Anom(rad)
% 11 Af0(s)
% 12 Af1(s/s)
%
% This functions gets almanac data from "http://www.navcen.uscg.gov" for
% the date specified. 
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


function  almanac_data=Get_almanac_data(time)


%% Check that specified date can be download (data published with a delay 
%% of one day).

if datenum(time(1:3))>=datenum(date)
  error('Not a valid date')
end

year=time(1);
day=datenum(time(1:3))-datenum([year 0 0]);


%% Get the almanacs data 
year=time(1);
[week secOfWeek]=UTC2GPStime(time);
week=mod(week,1024);
if week<1000
    week=strcat('000',num2str(week));
end
%Overwrite the time, (for the moment, later should be dynamically
%programmed, now it's constant)
secOfWeek=405504;
page=sprintf('https://celestrak.com/GPS/almanac/Yuma/%s/almanac.yuma.week%s.%s.txt',...
        num2str(year), num2str(week),num2str(secOfWeek));
%page='https://celestrak.com/GPS/almanac/Yuma/almanac.yuma.txt';
almanacs=webread(page);


start_ID=strfind(almanacs,'ID:');
start_Health=strfind(almanacs,'Health:');
start_Eccentricity=strfind(almanacs,'Eccentricity:');
start_Time_of_Applicability=strfind(almanacs,'Time of Applicability(s):');
start_Orbital_Inclination=strfind(almanacs,'Orbital Inclination(rad):');
start_Rate_of_Right_Ascen=strfind(almanacs,'Rate of Right Ascen(r/s):');
start_sqrtA=strfind(almanacs,'SQRT(A)  (m 1/2):');
start_Right_Ascen_at_Week=strfind(almanacs,'Right Ascen at Week(rad):');
start_Argument_of_Perigee=strfind(almanacs,'Argument of Perigee(rad):');
start_Mean_Anom=strfind(almanacs,'Mean Anom(rad):');
start_Af0=strfind(almanacs,'Af0(s):');
start_Af1=strfind(almanacs,'Af1(s/s):');
start_week=strfind(almanacs,'week:');

almanac_data=zeros(12,length(start_ID));

for k=1:length(start_ID)
    
% ID (PRN)    
almanac_data(1,k)=str2num(almanacs(start_ID(k)+length('ID:'):start_Health(k)-1));

% Health
almanac_data(2,k)=str2num(almanacs(start_Health(k)+length('Health:'):...
    start_Eccentricity(k)-1));

% Eccentricity
almanac_data(3,k)=str2num(almanacs(start_Eccentricity(k)+length('Eccentricity:'):...
    start_Time_of_Applicability(k)-1));
    
% Time of Applicability(s)
almanac_data(4,k)=str2num(almanacs(start_Time_of_Applicability(k)...
    +length('Time of Applicability(s):'):start_Orbital_Inclination(k)-1));

% Orbital Inclination(rad): 
almanac_data(5,k)=str2num(almanacs(start_Orbital_Inclination(k)...
    +length('Orbital Inclination(rad):'):start_Rate_of_Right_Ascen(k)-1));

% Rate of Right Ascen(r/s):
almanac_data(6,k)=str2num(almanacs(start_Rate_of_Right_Ascen(k)+...
    length('Rate of Right Ascen(r/s):'):start_sqrtA(k)-1));

% SQRT(A)  (m 1/2):
almanac_data(7,k)=str2num(almanacs(start_sqrtA(k)+...
    length('SQRT(A)  (m 1/2):'):start_Right_Ascen_at_Week(k)-1));

% Right Ascen at Week(rad):
almanac_data(8,k)=str2num(almanacs(start_Right_Ascen_at_Week(k)+...
    length('Right Ascen at Week(rad):'):start_Argument_of_Perigee(k)-1));

% Argument of Perigee(rad):
almanac_data(9,k)=str2num(almanacs(start_Argument_of_Perigee(k)+...
    length('Argument of Perigee(rad):'):start_Mean_Anom(k)-1));

% Mean Anom(rad):
almanac_data(10,k)=str2num(almanacs(start_Mean_Anom(k)+...
    length('Mean Anom(rad):'):start_Af0(k)-1));

% Af0(s):
almanac_data(11,k)=str2num(almanacs(start_Af0(k)+length('Af0(s):')...
    :start_Af1(k)-1));

% Af1(s/s):
almanac_data(12,k)=str2num(almanacs(start_Af1(k)+length('Af1(s/s):')...
    :start_week(k)-1));


end


%% Check that the GPS week is correct

[week secounds]=UTC2GPStime(time);

start_week=strfind(almanacs,'week:');

if str2num(almanacs(start_week(1)+length('week:'):start_ID(2)-1))~=week;
 error('The week of the downloaded data is erroneous')
end


