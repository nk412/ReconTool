time=32693592;
window=2; %in seconds;
window=window*10000; %unit conversion
neurons=model_params{1}(1);
gridmax_x=model_params{1}(5);
gridmax_y=model_params{1}(6);

prob_dist=zeros(gridmax_x,gridmax_y);
for x=1:gridmax_x
    for y=1:gridmax_y
        prob_dist(x,y)=spatial_occ(x,y);
        temp=1;
        temp2=0;
        for tt=1:neurons
            start_spike=findnearest(time-round(window/2),spikes{tt},1);
            end_spike=findnearest(time+round(window/2),spikes{tt},-1);
            temp=temp*power(firingrates{tt}(x,y),end_spike-start_spike+1);
            temp2=temp2+firingrates{tt}(x,y);
        end
        temp2=temp2*-window;
        temp2=exp(temp2);
        prob_dist(x,y)=prob_dist(x,y)*temp*temp2;
    end
    fprintf('%d/%d\n',x,gridmax_x);
end

for looptemp=1:5
jump=0;
for x=1:gridmax_x
    for y=1:gridmax_y
        if(prob_dist(x,y)==max(max(prob_dist)))
            jump=1;
        end
        if(jump==1)
            break;
        end
    end
    if(jump==1)
        break;
    end
end
x=x*2;
y=y*2;
fprintf('Estimated (x,y) #%d: (%d,%d)\n',looptemp,x,y);
prob_dist(x/2,y/2)=0;
end


truex=findnearest(time,posdata(:,1));
truey=findnearest(time,posdata(:,1));
truex=truex(1);
truey=truey(1);
truex=posdata(truex,2);
truey=posdata(truey,3);
fprintf('True Pos  (x,y) : (%d,%d)\n',truex,truey);

    
            
        