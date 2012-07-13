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

p1=round(time- twindow/2);
p2=round(time+ twindow/2);
            
prob_dist=zeros(gridmax_x,gridmax_y);
for x=1:gridmax_x
    for y=1:gridmax_y
        if(spatial_occ(x,y)==0)
            continue;
        else
            prob_dist(x,y)=spatial_occ(x,y);
        end

        temp=1;
        
        temp2=0;
        for tt=1:neurons
            number_of_spikes=0;
            closestp1=findnearest(p1,spikes{tt},-1);
            closestp2=findnearest(p2,spikes{tt},1);

            if(numel(closestp2)==0 || numel(closestp1)==0)
                for z=1:numel(spikes{tt})
                    if(spikes{tt}(z)>p1 && spikes{tt}(z)<p2)
                        number_of_spikes=number_of_spikes+1;
                    elseif(spikes{tt}(z)>p2)
                        break;
                    end      
                end
            else
                number_of_spikes=closestp2-closestp1-1;
            end



            temp=temp*power(firingrates{tt}(x,y),number_of_spikes);
            %temp=temp*timestep*power(firingrates{tt}(x,y),number_of_spikes);
            %temp=temp/factorial(number_of_spikes);
            
            
            temp2=temp2+firingrates{tt}(x,y);
        end
        temp2=temp2*-twindow;
        temp2=exp(temp2);



        prob_dist(x,y)=spatial_occ(x,y)*temp*temp2;

        %prob_dist(x,y)=firingrates{1}(x,y);
    end
    %fprintf('%d/%d\n',x,gridmax_x);  %display any debug messages, for ever cell calc
end
total_sum=sum(sum(prob_dist));
if(total_sum~=0)
    normalization_constant=1/total_sum;
    if(normalization_constant==Inf)
        normalization_constant=1;
    end
    prob_dist=prob_dist.*normalization_constant;
end
end

