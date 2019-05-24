function plotResultPr(r_ab, tVec, residual, Sigma, trueDir, sets)
labelVec = ['N-direction'; 'E-direction'; 'D-direction'];
posOverTime=zeros(size(r_ab)); %Calculating the cumsum mean position
posOverTime(:,1)=r_ab(:,1);

if (sets.plots.posOverT)
    for i=2:size(r_ab,2)
        posOverTime(:,i)=(r_ab(:,i)+posOverTime(:,i-1)*(i-1))/i;
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

        plot(tVec,r_ab(i,:))
        plot(tVec,posOverTime(i,:))
        xlabel(strcat(NEDvec(i), '-direction, mean: ', ...
                num2str(mean(r_ab(i,:))),32, 'and cumulative sum' ...       
        ))
    end
    subplot(414)
    d=vecnorm(r_ab, 1);
    plot(tVec,d)
    xlabel('Euclidean distance')
end

if sets.plots.histPerDir
    labelVec = ['N-direction'; 'E-direction'; 'D-direction'];
    numVec   = ['0', '1', '2'];
    figure
    sgtitle(strcat('Histogram drift relative estimates from pR, true distance 10m in ', trueDir, '-direction'))
    for i=1:3
        subplot(3,1,i)
        histogram(r_ab(i,:)-mean(r_ab(i,:)),'Normalization','probability', 'DisplayStyle', 'stairs');
        hold on
        xlabel(strcat(labelVec(i,:),', mean 2= ', num2str(round(mean(r_ab(i,:)),2)), '[m]', ...
                ', \sigma^2= ', num2str(round(var(r_ab(i,:)),2))  ...
            ))
    end
end

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

if sets.plots.cov
    figure
    sgtitle('Covariance matrix averaged')
    imagesc(Sigma.Sigma);
    colorbar
end

if sets.plots.hist
    figure
    sgtitle(strcat('Histogram drift relative estimates from pR, true distance 10m in ', ...
                    trueDir, '-direction'))
    hold on
    colors=['r', 'g', 'b'];
    meanstr='mean: ';
    varstr ='\sigma^2: ';
    for i=1:3
        histogram(r_ab(i,:),'Normalization','probability', 'DisplayStyle', 'stairs');    
        meanstr= strcat(meanstr,32, num2str(round(mean(r_ab(i,:)),1)), ', ', 32);
        varstr= strcat(varstr, 32, num2str(round(sets.plots.var(r_ab(i,:)),1)), ', ', 32);
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