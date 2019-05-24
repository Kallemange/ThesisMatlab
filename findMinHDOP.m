function [indexD, indexU]=findMinHDOP(D,u,iD,iu)
%Similar to A GPS Pseudorange Based Cooperative Vehicular Distance Measurement Technique
%As well as p. 161 "The global positioning system"
%Extract the HDOPmin-value as sqrt(V11+V22) where 
%V=H'*H and H=[u_1-u_i ... u_n-u_i]', for all but u_i

H       = u.dir(iu,:);
%H1      = H(2:end,:)-H(1,:);
H1      = H(2:end,:);
V=inv(H1'*H1)^(-1);
DOPmin  = sqrt(V(1,1)+V(2,2));
%median_u=1;
refSat  = u.sv(iu(1));

for i=2:length(iD)
    index   = [1:i-1, i+1:length(iD)];
    Hi      = H(index,:);
    V       = (Hi'*Hi)^(-1);
    if (rcond(V)<1e-5||isnan(rcond(V))||any(any(isnan(V))))
        keyboard
    end
    DOP     = sqrt(V(1,1)+V(2,2));
    if DOP<DOPmin
        DOPmin=DOP;
        refSat=u.sv(iu(i));
    end
end
indexD=find(D.sat(iD)==refSat);
indexU=find(u.sv(iu)==refSat);
%keyboard