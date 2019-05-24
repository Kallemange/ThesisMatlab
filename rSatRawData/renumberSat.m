function sRenumb=renumberSat(s)
sRenumb=s;
    for h=1:length(s)
        noRenumbered=zeros(size(s(h).data,1),1);
        for i=1:size(s(h).data,1)
            noRenumbered(i)=renumberSat2Raw(table2array(s(h).data(i,1)),table2array(s(h).data(i,2)));
        end
        sRenumb(h).data.svID=noRenumbered;
    end
end

