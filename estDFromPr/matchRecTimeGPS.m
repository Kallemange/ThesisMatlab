function [t1_idx, t2_idx]=matchRecTimeGPS(g1,g2)
%[t1_idx, t2_idx]=matchRecTime(x1,x2)

%Match observations time such that observations are plotted close to each
%other in time (less than 0.05s)
if g1.ToWms(1)<g2.ToWms(1)
    x1=g2;
    x2=g1;
else
    x1=g1;
    x2=g2;
end
x1Vec=[];
x2Vec=[];
L=length(x2.ToWms);
x2_idx=1;
for x1_idx=1:length(x1.ToWms)
    while x2_idx<L-1
            if x2.ToWms(x2_idx)>x1.ToWms(x1_idx)
                break
            else
                x2_idx=x2_idx+1;
            end
    end
    
    [dt, idx]=min(abs(x1.ToWms(x1_idx)-x2.ToWms([x2_idx x2_idx-1])));
    if dt<0.05
        x1Vec(end+1)=x1_idx;
        x2Vec(end+1)=x2_idx+1-idx;
    end
end
%plot(x1.tVec(x1Vec)-x2.tVec(x2Vec))
if g1.ToWms(1)<g2.ToWms(1)
    t1_idx=x2Vec;
    t2_idx=x1Vec;
else
    t1_idx=x1Vec;
    t2_idx=x2Vec;
end
end