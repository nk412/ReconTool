function [ final_out ] = reconstruction( position_data, spikes, model_params, intervals, window )
%RECONSTRUCT Summary of this function goes here
%   The reconstruct function uses a model to reconstruct the location of
%   the animal given the spiking activity of a set of neurons. The
%   estimated position is returned.
%
%   Inputs-
%   position_data - a vector which specifies the time, and the x and y 
%   co-ordinates of the animal. Time stamps are expected in 1/10000 second
%   units, and co-ordinates are in centimeters. In this function, this is
%   only used to calculate the accuracy of reconstruction.
%
%   spikes - a cell array consisting of N vectors, where N is the number of
%   neurons. Each vector consists of time stamps corresponding to when the
%   respective neuron fired. Units of time are in 1/10000th of a second.
%
%   model_params - A cell array that makes up the model for the information
%   learnt during training phase. Contains firing rates, occupancy matrices
%   and other information parameters.
% 
%   startpoint - (Algorithm specific) Specifies the start point from which 
%   the reconstruction algorithm will be applied. The position of the 
%   animal before this point will not be calculated. Expected units are in
%   1/10000th of a second.
%
%   endpoint - (Algorithm specific) Specifies the end point of the 
%   reconstruction. Reconstructions will not be carried for spikes after
%   this timestamp.
%
%   window - Specifies the time window that is used for reconstruction for
%   each step. For every timestep, only the information encoded by spikes
%   within this time window ('window/2' duration on either side) will be 
%   used for decoding.
%
%   Outputs -
%   
%   estpos - Estimated position - For every timestep in the given
%   reconstruction range (startpoint - endpoint), a row of four values are
%   appended to the vector. The first two values correspond to the
%   estimated 'x' and 'y' of the animal, while the next two values indicate
%   the true position (x and y) of the animal, as fetched from
%   position_data.


if(nargin<4)
    error('Argumements : Position data, spikes, model parameters, start point in time, end point, (time window)');
elseif(nargin<5)
    window=1;
end


%------------Discretizing Position_data into bins------------%
binsize_grid=model_params{2};
max_x=max(position_data(:,2));  % get max X value
max_y=max(position_data(:,3));  % get max Y value
n_grid=binsize_grid(1);       % horizontal divisions, n
m_grid=binsize_grid(2);       % vertical divisions, m
m_grid=max_x/m_grid;            % bin width
n_grid=max_y/n_grid;            % bin height
for x=1:numel(position_data(:,1))
    position_data(x,2)=round(position_data(x,2)/m_grid) ;
    position_data(x,3)=round(position_data(x,3)/n_grid);
end
max_x=max(position_data(:,2));
max_y=max(position_data(:,3));
%------------------------------------------------------------%



%----------------variable initialization---------------------%
estpos=[];
window=window*10000; %unit conversion from seconds to 1/10000th of a second
neurons=model_params{1}(1);
gridmax_x=model_params{1}(2);
gridmax_y=model_params{1}(3);
timestep=model_params{1}(4); % Timestep, algorithm specific. will resolve this.
spatial_occ=model_params{3};
firingrates=model_params{4};
no_of_intervals=numel(intervals(:,1));

final_out={};
per_out=[];
prob_out={};
%------------------------------------------------------------%





for intr=1:no_of_intervals
    startpoint=intervals(intr,1);
    endpoint=intervals(intr,2);
    time=startpoint;
    per_out=[];
    prob_out={};
    count=1;
    interval_out={};
    while(time<=endpoint)  



        % ---------------- Algorithm implementation---------------%
        prob_dist= algorithm( time, gridmax_x,gridmax_y,neurons,spikes,firingrates,spatial_occ, window);
        %=----------------Algorithm Implementation ends--------------%




        %-----------------------Calculate Estimated X and Y -----------------%
        tempx=findnearest(max(max(prob_dist)),prob_dist);
        [estx,esty]=ind2sub(size(prob_dist),tempx(1));
        %fprintf('Estimated (x,y) : (%d,%d)\n',estx,esty);
        fprintf('Completed: %f %%\n',((time-startpoint)/(endpoint-startpoint))*100);
        per_out=[per_out; time,estx,esty];
        prob_out{count}=prob_dist;
        %-----------------------Calculate Estimated X and Y -----------------%


        time=time+timestep;
        count=count+1;
    end
    interval_out={per_out prob_out};
    final_out{intr}=interval_out;
end


end
            
        
