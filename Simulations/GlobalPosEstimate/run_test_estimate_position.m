function run_test_estimate_position(in)
in.noise='noiseless';
test_estimate_position(in);
% Receiver clock error
in.noise='clockB';
test_estimate_position(in);
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in);
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in);
% Gaussian noise
in.noise='gauss';
test_estimate_position(in);
%% Testing the convergence of the simulations for different levels of input noise
% No noise 
in.noise='noiseless';
test_estimate_position(in, 'convergence', 1e-10);
% Receiver clock error
in.noise='clockB';
test_estimate_position(in,'convergence');
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in,'convergence');
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in,'convergence');
% Receiver position error
%in.noise='recPos';
%test_estimate_position(in,'convergence');
% Gaussian noise
in.noise='gauss';
test_estimate_position(in,'convergence');
% Mixed noise in receiver position and clock bias
in.noise='mixedNoise';
test_estimate_position(in,'convergence', 1e-8);
end