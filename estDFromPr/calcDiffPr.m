function dPr=calcDiffPr(r1,r2,t1)
%Calculation of the difference in pseudorange per each measurement
%IN raw data[2], valid times indices[2], satellite info
%OUT struct-array with pseudorange difference, satID, ToW

%dPr=cell(100,1);
for i=t1(1):t1(2)
    try
        %With r1 as reference, find the closest r2 readings
        raw1                   = r1(i);
        r2IdLow                = find([r2.ToW]<=raw1.ToW, 1, 'last');
        r2IdHigh               = find([r2.ToW]>=raw1.ToW, 1, 'first');
        [~, r2idxL, r2idxH]    = intersect(r2(r2IdLow).data.sat, r2(r2IdHigh).data.sat);
        r2Low.ToW              = r2(r2IdLow).ToW;
        r2High.ToW             = r2(r2IdHigh).ToW;
        r2Low.data             = r2(r2IdLow).data(r2idxL,:);
        r2High.data            = r2(r2IdHigh).data(r2idxH,:);
        if (r2Low.ToW==r2High.ToW)
            w                  = 0.5*[1 1];
        else
            w                  = [(raw1.ToW-r2Low.ToW) (r2High.ToW-raw1.ToW)]/(r2High.ToW-r2Low.ToW);
        end
        if (sum(w)~=1||any(w<0))
            keyboard
        end
        raw2.data              = r2Low.data;
        raw2.data.P            = r2Low.data.P*w(2)+r2High.data.P*w(1);
        [~, i1, i2]            = intersect(raw1.data.sat, raw2.data.sat);
        dPr(i).dp              = raw1.data.P(i1)-raw2.data.P(i2);
        dPr(i).sat             = raw1.data.sat(i1);
        dPr(i).ToW             = raw1.ToW; 
    catch EM
        keyboard
    end
    
end

