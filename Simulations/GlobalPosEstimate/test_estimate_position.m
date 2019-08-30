function test_estimate_position(in, convergence, pres, saveToFile)
%IN:
% in, struct:                       All indata, containing fields:
%      p, double[3]:                True position of receiver in ECEF (from internal solution of receiver)
%      pSat double[i*3]:            position of satellites at time of tansmission.
%      eps, struct:                 noise level (epsilon)
%           -satPos                 Noise in satellite positions
%           -recPos                 Noise in receiver position
%           -clockB                 Noise in clock bias
%           -gauss                  Gaussian noise added on observation
%       noise, str:                 For switch case, which noise to test
%       mag, int[1]:                Magnitude of noise level
%  convergence, str:                If argument provided, test for convergence
%  pres (optional), double:         Iteration termination value for estimate_position
%  saveToFile (optional), bool:     If to save image to file, if yes, name will be given by name in switch
%OUT:
%   NA

%   Code will perform an input-output test for different noise levels and
%   types. Testing estimate_position with different noise levels and plotting the
%   results in order to see what behaviour to expect from a certain noise.
%   The different noise possibilities are: satellite position, receiver
%   position, receiver clock bias, Gaussian noise, and a clock conversion
%   error. 
%Argument 'convergence' will decide action of code to perform. 
    %Options:
%1) No 'convergence': 
%   For provided type of noise, the final value at which the calculation 
%   terminates is used, for an increasing magnitude of noise. The values
%   presented are: 
%       the difference between true and estimated position: |x-x_est|
%       the difference measurement and predicted estimate:  |y-f(x_est)|
%       mean square error of estimate:                      Sum((y-f(x_est))^2)/n
%2) 'convergence' provided:
%   Code will feed noisy input as specified by 'noise' to estimate_position
%   and output a plot of convergence for different magnitudes of noise.
%   For noiseless data, values should converge to ~0, while for noisy data
%   the expected terminal value should be of the same order of magnitude as
%   that of the noise term.

%Number of steps in iteration for final estimat and convergence order
if nargin<4
    saveToFile=1;
end
if nargin<3
    pres=1e-3;
end


N=100; N_conv=7;
c=299792458;
label_y="estimate error magnitude";
switch in.noise
    case 'clockB'
        noiseVec=c*linspace(0,10e-3, N);
        noise_convergence=round(c*10.^linspace(-7,-3, N_conv));
        plotTitle="Error in position estimate as a function of receiver clock bias";
        plotTitle_convergence="Convergence of estimate with receiver clock bias";
        label_x="clock error [ms]";
        figname='clockB';
    case 'recPos'
        noiseVec=linspace(0,1000,N);
        noise_convergence=round(linspace(0,1000,N_conv));
        plotTitle="Error in position estimate as function of receiver position error";
        plotTitle_convergence="Convergence of estimate with receiver position error";
        label_x="receiver position error";
        figname='recPos';
    case 'satPos'
        noiseVec=linspace(0,1000, N);
        noise_convergence=round(linspace(0,1000,N_conv));
        plotTitle="Error in position estimate as function of satellite position error";
        plotTitle_convergence="Convergence of estimate with satellite position error";
        label_x="satellite position error";
        figname='satPos';
    case 'gauss'
        noiseVec=linspace(0,1000, N);
        noise_convergence=round(linspace(0,1000,N_conv));
        plotTitle="Error in position estimate as function of a random noise";
        plotTitle_convergence="Convergence of estimate with added random noise";
        label_x="random noise magnitude";
        figname='Gaussian';
    case 'clockErr'
        noiseVec=linspace(-20,20,N);
        noise_convergence=round(linspace(-20,20,N_conv));
        plotTitle="Error in position estimate as function of time conversion error";
        plotTitle_convergence="Convergence of estimate as function of time conversion error";
        label_x="Time shift [s]";
        figname='clockErr';
    otherwise
        plotTitle="Positional estimate error using noise free data"; 
        plotTitle_convergence="Convergence of estimate using a noise free measurement";
        label_x="";
        N=10e2;
        noiseVec=zeros(1,N);
        noise_convergence=zeros(1,N_conv);
        figname='noiseFree';
end


if (nargin<2||~strcmp(convergence, 'convergence'))
    %initial position
    x0=[0 0 0];
    %Positional error, function error, mean square error
    deltaPVec=[];      deltaYVec=[];   mseVec=[];
    %clock bias estimate
    bVec=[];

    for i=1:length(noiseVec)
        in.eps.(in.noise)=noiseVec(i);
        pr=simulate_observation(in);
        if strcmp(in.noise, 'clockErr')
            in.pSat=satPositions(in.eph, in.eps.(in.noise));
        end
        %Estimate position using receiver observations and calculated positions of
        %the satellites
        [p_est, bVec(end+1)]=estimate_position(in.pSat, pr, length(pr), x0,0, 3);
        deltaPVec(end+1)=norm(p_est-in.pRec);
        deltaYVec(end+1)=norm([p_est-in.pRec bVec(end)-in.eps.clockB]);
        %Calculate the expected value of the measurement with given
        %estimates of receiver position and clock bias
        y_pred=vecnorm(in.pSat-p_est,2,2)+bVec(end);
        %And calculate the mean square error of expected and measured value
        mseVec(end+1)=sum((pr-y_pred).^2)/length(y_pred);
    end
    fig=figure;
    subplot(2,1,1)
    hold on
    if any(noiseVec~=0)
        plot(noiseVec,deltaPVec)
        plot(noiseVec,deltaYVec)
        plot(noiseVec,mseVec)
        legend("|x_{est}-x_{true}|", "|y-f(\theta)|", "(\Sigma(y-y_{pred})^2)/n");
        %semilogy(noiseVec,deltaPVec)
    else
        plot(1:N,deltaPVec)
        %semilogy(1:N,deltaPVec)
        axis([0 N -10e-9, 10e-9])
    end
    title(plotTitle)
    xlabel(label_x)
    ylabel(label_y)
    set(gca,'YScale','log')
    subplot(2,1,2)
    plot(noiseVec, bVec*1000/c)
    %semilogy(noiseVec, bVec*1000/c)
    ylabel("Estimated clock bias [ms]")
    xlabel("noise magnitude")
    %set(gca,'YScale','log')
    if saveToFile
        saveas(fig, strcat('Figures/',figname), 'epsc')
    end

elseif strcmp(convergence, 'convergence')
    fig=figure;
    %Start value for noisy estimates
    x0=[0,0,0];
    for i=1:length(noise_convergence)
        in.eps.(in.noise)=noise_convergence(i);
        pr=simulate_observation(in);
        if strcmp(in.noise, 'clockErr')
            in.pSat=satPositions(in.eph, in.eps.(in.noise));
        end
        %Starting position estimate for noiseless measurements
        %A distance of 10^i is subtracted from true position in all
        %directions, this seems convergent for any value <10e7
        if strcmp(in.noise, 'noiseless')
            x0=in.pRec-randn(1,3)*10^i;
        end
        [~, ~,~,~,xVec,bVec]=estimate_position(in.pSat, pr, length(pr),x0, 0, 3, pres);
        hold on
        posError=vecnorm([xVec bVec']-[in.pRec in.eps.clockB] ,2,2);
        plot(posError')
    end
    sgtitle(plotTitle_convergence);
    set(gca,'YScale','log')
    xlabel("#iteration")
    ylabel(label_y)
    %If noiseless estimates, see if position converges for a given starting
    %position
    if strcmp(in.noise, 'noiseless')
        leg=legend(strsplit(string(num2str(10.^[1:N_conv], "%10.0e"))));
        title(leg,"starting position")
    else
        leg=legend(num2str(noise_convergence'));
        title(leg, "noise magnitude")
    end
    if saveToFile
        saveas(fig, strcat('Figures/',figname, 'Conv'), 'epsc')
    end
end

