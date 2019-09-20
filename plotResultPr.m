function plotResultPr(r_ab, tVec, DD, trueDir, sets)
%{ 
%Plot the results from previous calculations.
The plots consist of:
    Plot1: 
        The cumulative value of position over time and
        Distance over time in NED
    Plot2:
        suplot 1
            Double difference value per satellite
        subplot 2
            TODO
            Expected double difference wrt satellite position
    Plot3:
        Histogram over all distances in NED
    Plot4:
        Residual over reconstruction error (removed)
    Plot5:
        Covariance of satellite difference (removed)
    Plot6:
        Histogram over relative estimates
IN:
    r_ab, double[3][n]:     Calculated distance between receivers in ECEF
    tVec, double[n]:        Time of measurement (GPST time of week [s])
    DD, cell[n]:            Struct with field:
                                DD[n]: Double difference dp(i)-dp(j)
                                ToW[n]: time (GPST time of week [s])
                                satID: name of satellite [1,32]
    trueDir, str:           Ground truth direction (N or E)
    sets, struct:           Multiple settings for which plots to show and
                            to run simulations
OUT:
    N/A
%}
labelVec = ['N-direction'; 'E-direction'; 'D-direction'];
posOverTime=zeros(size(r_ab)); %Calculating the cumsum mean position
posOverTime(:,1)=r_ab(:,1);
rec2ECEF=sets.posECEF'+r_ab;
spheroid=wgs84Ellipsoid;
%Transform from ECEF->NED coordinates, using the position from internal
%solution as ground truth. Simulation has been tested using the following
%transform, and was shown correct to within cm
% [x1, y1, z1]=ned2ecef(10,0,0,sets.poslla(1), sets.poslla(2), sets.poslla(3),spheroid);
% [x2, y2, z2]=ned2ecef(0,10,0, sets.poslla(1), sets.poslla(2), sets.poslla(3),spheroid);
% r_ab_test=([x1 y1 z1]-sets.posECEF)';
% r_ab_test(:,2)=([x2 y2 z2]-sets.posECEF)';

[x y z]=ecef2ned(rec2ECEF(1,:)', rec2ECEF(2,:)', rec2ECEF(3,:)', sets.poslla(1), sets.poslla(2), sets.poslla(3),spheroid);
r_abNED=[x, y, z]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 1
if (sets.plots.posOverT)
    for i=2:size(r_abNED,2)
        posOverTime(:,i)=(r_abNED(:,i)+posOverTime(:,i-1)*(i-1))/i;
    end
end
if sets.plots.distOverT
    figure
    hold on
    sgtitle('Distance in each direction')
    NEDvec=['N'; 'E'; 'D'];
    for i=1:3
        subplot(4,1,i)
        hold on
        plot(tVec,r_abNED(i,:))
        plot(tVec,posOverTime(i,:))
        xlabel(strcat(NEDvec(i), '-direction, mean: ', ...
                num2str(mean(r_abNED(i,:))),32, 'and cumulative sum' ...       
        ))
    end
    subplot(414)
    d=vecnorm(r_abNED, 2);
    plot(tVec,d)
    xlabel('Euclidean distance')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 2
if sets.plots.DDVec
    figure
    sgtitle("Double Difference as function of time per satellite without changing reference sat")
    legendDD=[];
    
    subplot(211)
    title("Measured double difference")
    hold on
    for i=1:length(DD)
        plot(DD{i}.ToW-tVec(1),DD{i}.DD, '*', 'MarkerSize', 1)
        legendDD=[legendDD; string(num2str(DD{i}.satID))];
    end
    leg=legend(legendDD);
    title(leg,"SatID");
    xlabel("Time since startup [s]")
    ylabel("Double difference [m]")
    subplot(212)
    hold on
    if strcmp(trueDir, " E")
        distN=0;
        distE=10;
    elseif strcmp(trueDir, " N")
        distN=10;
        distE=0;
    end
    
    [x, y, z]=ned2ecef(distN,distE,0, sets.poslla(1), sets.poslla(2), sets.poslla(3),spheroid);
    r_true=([x y z]-sets.posECEF)';
    for i=1:length(DD)
        plot(DD{i}.ToW-tVec(1), DD{i}.dU*r_true)
    end
    title("Expected distance calculated as (e^i-e^0)\cdot r_{ab} over time")
    xlabel('Time since startup [s]')
    ylabel("Distance [m]")

    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 3
if sets.plots.histPerDir
    labelVec = ['N-direction'; 'E-direction'; 'D-direction'];
    numVec   = ['0', '1', '2'];
    figure
    sgtitle(strcat('Histogram drift relative estimates from pR, true distance 10m in ', trueDir, '-direction'))
    
    for i=1:3
        subplot(3,1,i)
        histogram(r_abNED(i,:)-mean(r_abNED(i,:)),'Normalization','probability', 'DisplayStyle', 'stairs');
        hold on
        xlabel(strcat(labelVec(i,:),', mean 2= ', num2str(round(mean(r_abNED(i,:)),2)), '[m]', ...
                ', \sigma^2= ', num2str(round(var(r_abNED(i,:)),2))  ...
            ))
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 4

if sets.plots.residual
%Plot the residual histogram
    figure
    sgtitle({'Histogram over reconstruction error'; 'Sattelite Number (sn), number of samples in %, Mean(\mu), Variance(\sigma^2)'})
    residualVec=find(sum(residual,2)~=0);
    numSubplot=5;
    for i=1:length(residualVec)
        subplot(numSubplot,numSubplot+1, i)
        histIdx=find(residual(residualVec(i),:)~=0);
        histogram(residual(residualVec(i),histIdx), 'Normalization','probability', 'DisplayStyle', 'stairs');
        occPerc= sum(residual(residualVec(i),:)~=0)/size(residual,2)*100;
        if (occPerc<1) 
            occPerc=round(occPerc,2); 
        else
            occPerc=round(occPerc) ;
        end

        xlabel(strcat( ...
                'sn:', 32, num2str(residualVec(i)),32, ...
                ', %:', 32, num2str(occPerc), 32, ...
                ', \mu:', 32, num2str(round(mean(residual(residualVec(i),:)),2)), 32,...
                ', \sigma^2: ', 32, num2str(round(var(residual(residualVec(i),:))))))
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 5
if sets.plots.cov
    figure
    sgtitle('Covariance matrix averaged')
    imagesc(Sigma.Sigma);
    colorbar
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot 6

if sets.plots.hist
    figure
    sgtitle(strcat('Histogram drift relative estimates from pR, true distance 10m in ', ...
                    trueDir, '-direction'))
    hold on
    colors=['r', 'g', 'b'];
    meanstr='mean: ';
    varstr ='\sigma^2: ';
    for i=1:3
        histogram(r_abNED(i,:),'Normalization','probability', 'DisplayStyle', 'stairs');    
        meanstr= strcat(meanstr,32, num2str(round(mean(r_abNED(i,:)),1)), ', ', 32);
        varstr= strcat(varstr, 32, num2str(round(sets.plots.var(r_abNED(i,:)),1)), ', ', 32);
    end
    legend(labelVec)
    if sets.plots.isSim
        xlabel({strcat('NED: ',32,  meanstr(1:end-2), '[m]',32, varstr(1:end-2));...
            strcat('TrueD: ', 32, num2str(sets.sim.dist), ', ',32, ...
                   'EstimD: ', 32, num2str(vecnorm(mean(r_ab'))), ', ', 32,...
                   '|Noise|: ',32, num2str(sets.noise.Gnoise),',', 32); ...
            strcat('Settings: sysNoise', 32, num2str(sets.noise.sysNoiseMag), ',', 32, ...
                    '\Delta t', 32, num2str(sets.sim.clockError), ',', 32, ...
                    'dirNoise', 32, num2str(sets.noise.dirNoise), ',' , 32, ...
                    'roundoff', 32, num2str(sets.noise.round), ',', 32, ...
                    'noiseH', 32, num2str(sets.noise.noiseH))})
    else
        xlabel(strcat('NED: ',32,  meanstr(1:end-2), '[m]',32, varstr(1:end-2)))
    end
end