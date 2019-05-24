function dPr=calcDiffPr(r1,r2,t1,t2, s1, t_max)
%Calculation of the difference in pseudorange per each measurement
%IN raw data[2], valid times indices[2], satellite info
%OUT cell-struct with pseudorange difference, satID, ToW
idx_max=find(t_max>=[r1(t1).ToW]-r1(t1(1)).ToW, 1,'last');
t0=r1(t1(1)).ToW;

%dPr={};
dPr=[];
for i=1:min(length(t2),idx_max) 
    idx1=[]; idx2=[];
    r1Sorted=sortrows(r1(t1(i)).data,1);
    r2Sorted=sortrows(r2(t2(i)).data,1);
    idx_sat=findClosestSatReading(r1, s1, t1, i, t0); 
    for j=1:size(s1(idx_sat).data,1)
        try
        idx1=[idx1 find(r1Sorted.sat==s1(idx_sat).data.svID(j),1, 'first')];
        idx2=[idx2 find(r2Sorted.sat==s1(idx_sat).data.svID(j),1, 'first')];
        %keyboard
        catch ME
            keyboard
        end
           
        
    end
        %r1(t1(i)).ToW-t0>57 break condition
        [~, i1, i2] = intersect(r1Sorted.sat(idx1),r2Sorted.sat(idx2));
        dPr(i).dp   = r1Sorted.P(idx1(i1))-r2Sorted.P(idx2(i2));
        dPr(i).sat  = r1Sorted.sat(idx1(i1));
        %dPr(i).ToW  = s1(idx_sat).ToW;  
        dPr(i).ToW  = r1(t1(i)).ToW-t0; 

end

end