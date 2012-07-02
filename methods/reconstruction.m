function [ estpos ] = reconstruct( position_data, spikes, model_params, startpoint, endpoint, window )
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

if(nargin<5)
    error('Argumements : Position data, spikes, model parameters, start point in time, end point, (time window)');
elseif(nargin<6)
    window=1;
end

binsize_grid=model_params{2};


max_x=max(position_data(:,2));
max_y=max(position_data(:,3));
n_grid=binsize_grid(1)-1;
m_grid=binsize_grid(2)-1;
m_grid=max_x/m_grid;
n_grid=max_y/n_grid;


for x=1:numel(position_data(:,1))
    position_data(x,2)=round(position_data(x,2)/m_grid) + 1;
    position_data(x,3)=round(position_data(x,3)/n_grid) + 1;
end

max_x=max(position_data(:,2));
max_y=max(position_data(:,3));


estpos=[];

time=startpoint;
window=window*10000; %unit conversion
neurons=model_params{1}(1);
gridmax_x=model_params{1}(5);
gridmax_y=model_params{1}(6);
spatial_occ=model_params{3};
firingrates=model_params{4};
tstep=333; % Timestep, algorithm specific. will resolve this.

while(time<=endpoint)
    
%window=2; %in seconds;


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
        prob_dist(x,y)=prob_dist(x,y)*temp*temp2;
    end
    fprintf('%d/%d\n',x,gridmax_x);
end

for looptemp=1:1
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
x=x*binsize_grid;
y=y*binsize_grid;
 fprintf('Estimated (x,y) #%d: (%d,%d)\n',looptemp,x,y);
 %prob_dist(x/2,y/2)=0;
end


truex=findnearest(time,position_data(:,1));
truey=findnearest(time,position_data(:,1));
truex=truex(1);
truey=truey(1);
truex=position_data(truex,2);
truey=position_data(truey,3);
% fprintf('True Pos  (x,y) : (%d,%d)\n',truex,truey);
estpos=[estpos;x,y,truex,truey];
   
time=time+tstep;
end
            
        

end

