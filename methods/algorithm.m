function [ prob_dist ] = algorithm( time, gridmax_x,gridmax_y,neurons,spikes,firingrates,spatial_occ, timestep, twindow)
%function algorithm(time,gridmax_x, gridmax_y, neurons, spikes, firingrates, spatial_occ, window)
% Function not meant to be called independently. Contains the core
% reconstruction alogrithm. Takes all required data such as firing
% rates and spiking data, along with other algorithm specific
% information such as time window and grid size, and uses them to
% calculate a probability distribution of position.
%
% Output - prob_dist
%
% A matrix of size MxN, containing the probability distribution of expected position.
% MxN is the grid size as specified during training.

% for tt=1:neurons
%     firingrates{tt}=firingrates{tt}.*100000;
% end

prob_dist=zeros(gridmax_x,gridmax_y);
for x=1:gridmax_x
    for y=1:gridmax_y
        prob_dist(x,y)=spatial_occ(x,y);
        temp=1;
        temp2=0;
        for tt=1:neurons
            % start_spike=findnearest(time-round(twindow/2),spikes{tt},-1);
            % start_spike=start_spike(1);
            % end_spike=findnearest(time+round(twindow/2),spikes{tt},1);
            % end_spike=end_spike(1);
            p1=round(time- twindow/2);
            p2=round(time+ twindow/2);
            number_of_spikes=0;
            for z=1:numel(spikes{tt})
                if(spikes{tt}(z)>p1 && spikes{tt}(z)<p2)
                    number_of_spikes=number_of_spikes+1;
                end
            end
            temp=temp*timestep*power(firingrates{tt}(x,y),number_of_spikes);
            temp=temp/factorial(number_of_spikes);
            temp2=temp2+firingrates{tt}(x,y);
        end
        temp2=temp2*-twindow;
        temp2=exp(temp2);
        %temp=temp+0.000001;
        %temp2=temp2+0.000000001;
        prob_dist(x,y)=spatial_occ(x,y)*temp*temp2;
        %prob_dist(x,y)=firingrates{1}(x,y);
    end
    x
    %fprintf('%d/%d\n',x,gridmax_x);  %display any debug messages, for ever cell calc
end

end

