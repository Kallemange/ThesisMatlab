%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Version 1, June 2007, Copyright (C) 2007, Isaac Skog 
%
% function call: GPStime=UTC2GPStime(UTCtime);
%
% Input:
% UTCtime=[year month day hour minute seconds]
% GPStime=[week seconds] 
%
% This functions converts UTC time to GPS time.
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


function [week sec]=UTC2GPStime(UTCtime)


%% List of dates when leap seconds was introduced. 
leap_sec_dates = [...
    'Jul 1 1981'
    'Jul 1 1982'
    'Jul 1 1983'
    'Jul 1 1985'
    'Jan 1 1988'
    'Jan 1 1990'
    'Jan 1 1991'
    'Jul 1 1992'
    'Jul 1 1993'
    'Jul 1 1994'
    'Jan 1 1996'
    'Jul 1 1997'
    'Jan 1 1999'
    'Jan 1 2006'
    'Jan 1 2009'];

%% The start date of the GPS time is Jan 6 1980.
GPS_start_time=[1980 1 6 0 0 0];

%% Number of leap seconds  
num_of_leap_seconds=sum(datenum(UTCtime)>datenum(leap_sec_dates)); 
nr_of_elpased_sec=etime(UTCtime,GPS_start_time)+num_of_leap_seconds;

%% Calculate GPS time
week=floor(nr_of_elpased_sec / (7*24*60*60));
sec=round(nr_of_elpased_sec-7*24*60*60*week);






