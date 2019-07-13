function lineAtEach10min(t0, L, range)
%Function to add a line at each whole 10 minute period in order to compare
%with that of the charts available in https://www.gnssplanning.com/#/charts
secs=60-t0(end);
mins=9-mod(t0(end-1), 10);
line_pos=secs/60+mins;
line(line_pos*ones(2,1), range)
line_text.min=mod(t0(5)+mins+1, 60);
line_text.hour=t0(4);
if line_text.min==0
    line_text.hour=line_text.hour+1;
end
text(line_pos+0.1, range(2), strcat(addZero(line_text.hour), ":", addZero(line_text.min)))
for i=1:L-1
    line_pos=line_pos+10;
    line(line_pos*ones(2,1), range)
    line_text.min=mod(line_text.min+10,60);
    if line_text.min==0
        line_text.hour=line_text.hour+1;
    end
    
    text(line_pos+0.1, range(2), strcat(addZero(line_text.hour), ":", addZero(line_text.min)))
end

function txt=addZero(x)
if x<10
    txt=strcat('0',num2str(x));
else
    txt=num2str(x);
end
    