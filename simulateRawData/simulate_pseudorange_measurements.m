function raw_simulated = simulate_pseudorange_measurements(receiver_pos, raw_obs, sat_eph_data, sat_idx, with_bias, clock_bias)
week=sat_eph_data(1).week;
time=[raw_obs.ToW];
if nargin <= 4
        fprintf('No clock or satellite bias added\n')
        with_bias = false;
        clock_bias = zeros(length(time));
end
c = 299792458;              % Speed of light (m/s)
omega_e = 7.2921151467e-5;  % Earth's rotation rate (rad/sec)
raw_simulated   = raw_obs;

for obs_itr = 1:length(time)
    [~, iR, iE]=intersect(raw_obs(obs_itr).data(:,1), sat_idx);
    raw_t=raw_obs(obs_itr).data(iR,:);
    eph_t=sat_eph_data(iE);
    obs=raw_obs(obs_itr).data(iR, 5);
    active_satellites = sat_idx(iE);
    rcvr_bias = clock_bias(obs_itr,1);
    [~, rcvr_tow] = UTC_in_sec2GPStime(raw_obs(obs_itr).ToW, week);
        
    for sat_itr = 1: length(obs)
        %sv_idx = active_satellites(sat_itr);
        %if ~isempty(find(active_satellites == sv_idx, 1))
            % Match observation with ephemeris data
        %eph_data=sat_eph_data(iE(sat_itr));
        eph_data=eph_t(sat_itr);
        % Compute the pseudorange iteratively 
        distance0 = obs(sat_itr); delta_distance = 10;
        while delta_distance > 0.001
            tau = distance0/c; 
            [xs, ys, zs] = get_satellite_position(eph_data,rcvr_tow-tau);
            theta = omega_e*tau;
            sat_ecef = ([cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs; ys; zs])';
            %sat_ecef =[xs; ys; zs]';
            distance = sqrt(sum((sat_ecef-receiver_pos).^2, 2));
            dsv = estimate_satellite_clock_bias(rcvr_tow - tau, eph_data);
            delta_distance = norm(distance0-distance);
            distance0 = distance;
        end
        if with_bias % Add the bias to the simulated measurements
            raw_simulated(obs_itr).data(iR(sat_itr),5) = distance + rcvr_bias - c*dsv;
        else
            raw_simulated(obs_itr).data(iR(sat_itr),5)= distance - c*dsv;
        end
        %end
    end 
end
end