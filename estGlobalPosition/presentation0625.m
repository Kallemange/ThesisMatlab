%F�ljande skall presenteras 
% Jag skall ta fram grafer och v�rden f�r f�ljande
% 
% 1) Position skattad av mottagaren (i ECEF och lla)
% 2) Position skattad av mig i N&E (i ECEF och lla)
% 3) DOP-v�rden
% 4) DD inklusive satellit-nummer
% 5) std-avvikelse v�rden
% 6) Satellitpositioner �ver tid

%% 3) 


%% 4) DD values
DDidx=find(sum(DDVec,2)~=0);
figure(4)
plot(t1-t1(1),DDVec(DDidx,:)')
DDtext=num2str(DDidx);
legend(DDtext)
sgtitle('DD over time, sat2 as reference')