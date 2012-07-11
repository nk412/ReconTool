function [ post_recon ] = reconstruction( position_data, spikes, model_params, intervals, twindow )
% reconstruction(position_data, spikes, model_params, intervals, twindow)
% Uses the animal's positional data, spiking activity of the neurons, model
% parameters (firing rates, occupancy matrices...) generated during from
% the training method, to reconstruct the location of the animal.
%
% Inputs -
% position_data - Positional data in the form of a Tx3 matrix, where T is the
%                 number of timesteps. The three columns correspond to timestep,
%                 X coordinate at T and Y coordinate at T respectively.
% spikes        - A cell array containing N vectors, where N is the number of
%                 neurons. Each vector contains timestamps at which the neuron
%                 fired.
% model_params  - Cell array containing parameters such as firing rates and
%                 occupancy matrices. This object is generated by the training
%                 method, given the spiking and positinal data.
% intervals     - A matrix of size Ix2, where I is the number of intervals for
%                 reconstruction. For every interval specified, the first column
%                 indicates the start timestamp of the interval and the second
%                 column represents the end timestamp of the interval.
%
% Optional Inputs-
% twindow       - This is the time window specified in seconds, the window within
%                 which the spiking activity of the neurons will be used for
%                 reconstruction. This parameter is algorithm specific, and may
%                 not be used by all methods. By default, twindow is set to 1 sec.
%
% Output -
% post_recon     - This is a cell array that contains I cells, where I is the number
%                 of reconstruction intervals specified. Each of these cells 
%                 contain two elements,
%                 i. A Tx3 matrix which contains T timesteps lying between the
%                    interval specified. The first column denotes the timestamp,
%                    the second column corresponds to the estimated X co-ordinate
%                    at the timestep, and the third column consists of the estimated
%                    Y co-ordinate at the same timestep.
%                 ii. The second cell is a cell array containing T matrices,
%                    where T is the number of timesteps in the interval specified.
%                    Each matrix is of size MxN, the grid size, that gives the
%                    probability distribution of finding the animal on the grid.
%                    The estimated position is calcualted by finding the location
%                    with the maximum probability.



if(nargin<4)
    error('Argumements : Position data, spikes, model parameters, start point in time, end point, (time twindow)');
elseif(nargin<5)
    twindow=1;
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
twindow=twindow*10000; %unit conversion from seconds to 1/10000th of a second
neurons=model_params{1}(1);
gridmax_x=model_params{1}(2);
gridmax_y=model_params{1}(3);
timestep=model_params{1}(4); % Timestep, algorithm specific. will resolve this.
spatial_occ=model_params{3};
firingrates=model_params{4};
no_of_intervals=numel(intervals(:,1));

post_recon={};
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
        prob_dist= algorithm( time, gridmax_x,gridmax_y,neurons,spikes,firingrates,spatial_occ, timestep,twindow);
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
    post_recon{intr}=interval_out;
end


end
            
        
