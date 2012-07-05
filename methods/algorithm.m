function [ prob_dist ] = algorithm( time, gridmax_x,gridmax_y,neurons,spikes,firingrates,spatial_occ, window)
%function algorithm(time,gridmax_x, gridmax_y, neurons, spikes, firingrates, spatial_occ, window)


% prob_dist=zeros(gridmax_x,gridmax_y);
% for x=1:gridmax_x
% 	for y=1:gridmax_y
% 		prob_dist(x,y)=spatial_occ(x,y);
% 		eachpos=0;
% 		for n=1:neurons
% 			prob_n_firing=sum(sum(firingrates{n})) + 0.0001;
% 			prob_n_firing_at_loc = firingrates{n}(x,y) + 0.0001;
% 			eachpos=eachpos+(prob_n_firing_at_loc/prob_n_firing);
% 		end
% 		prob_dist(x,y)=prob_dist(x,y)*eachpos;
% 	end
% end

prob_dist=zeros(gridmax_x,gridmax_y);
for x=1:gridmax_x
    for y=1:gridmax_y
        prob_dist(x,y)=spatial_occ(x,y);
        temp=1;
        temp2=0;
        for tt=1:neurons
            start_spike=findnearest(time-round(window/2),spikes{tt});
            start_spike=start_spike(1);
            end_spike=findnearest(time+round(window/2),spikes{tt});
            end_spike=end_spike(1);
            temp=temp*power(firingrates{tt}(x,y),end_spike-start_spike+1);
            temp2=temp2+firingrates{tt}(x,y);
        end
        temp2=temp2*-window;
        temp2=exp(temp2);
        %temp=temp+0.000001;
        %temp2=temp2+0.000000001;
        prob_dist(x,y)=prob_dist(x,y)*temp*temp2;
    end
    %fprintf('%d/%d\n',x,gridmax_x);  %display any debug messages, for ever cell calc
end

end

