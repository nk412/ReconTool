function [ model_params ] = traindata( position_data, spikes, binsize_grid, intervals )
%TRAINDATA Summary of this function goes here
%  traindata() builds a model from the given dataset with the specified
%  constraints
%
%  Inputs -
%
%  position_data - a vector which specifies the time, and the x and y 
%  co-ordinates of the animal. Time stamps are expected in 1/10000 second
%  units, and co-ordinates are in centimeters.
%
%  spikes - a cell array consisting of N vectors, where N is the number of
%  neurons. Each vector consists of time stamps corresponding to when the
%  respective neuron fired. Units of time are in 1/10000th of a second.
%
%  binsize_grid - (OPTIONAL) Specifies the size of the bin, in centimeters.
%  By default, the bin size is 1cm.
%
%  startpoint - (OPTIONAL) Specifies the timestamp beginning from which the
%  model will be built. By default, the first point in position_data will
%  be used.
%
%  endpoint - (OPTIONAL) Specifies the timestamp UP TO which the model will
%  be built. By default, the last point in position_data will be used.
%
%  Outputs-
%
%  model_params - This is a cell array that contains vectors of calculated
%  parameters such as firing rates and spatial occupancy. The cell array
%  contains four cells as described below.
%  
%  i. General parameters - The first vector contains general information about the model, that
%  can be used by the reconstruction method. The parameters contained in
%  this vector are ( number of neurons, binsize_grid, startpoint, endpoint, gridmax_x,
%  gridmax_y). The 'gridmax' variables are used to contain the size of the
%  grid after spatial binning.
%
%  ii. Occupancy matrix - The second cell is the occupancy matrix of the data. The address of
%  each cell can be considered to be the co-ordinates, for simplified
%  calculations. Each cell contains the number of times the animal was
%  found in the given data.
%
%  iii. Spatial Occupancy - This matrix contains the spatial occupancy of
%  different locations on the grid. Each cell contains a probability of
%  finding the animal in that location, as per the binning criteria given.
%
%  iv. Firing rates- The third cell is a cell array that consists of N
%  matrices, where N is the number of neurons given in the data. For each
%  neuron, each cell contains the firing rate of the cell from the given
%  data.

if(nargin<2)
    error('Need atleast position data and spiking information');
elseif(nargin<3)
    binsize_grid=[64,64]; % 64x64 default;
    intervals=[min(position_data(:,1)),max(position_data(:,1))];
elseif(nargin<4)
    intervals=[min(position_data(:,1)),max(position_data(:,1))];
end


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

posdata=[];
for tempx=1:numel(intervals(:,1))
    startpoint=findnearest(intervals(tempx,1),position_data(:,1));
    endpoint=findnearest(intervals(tempx,2),position_data(:,1));
    posdata=[posdata;position_data(startpoint:endpoint,:)];
end


ignore_orig=1;  % Set to 1, to ignore all (0,0) points

del_t=333;

gridmax_x=max_x;
gridmax_y=max_y;

%=============== SPATIAL OCCUPANCY ===================%
fprintf('Calculating Spatial Occupancy...\n');
spatial_occ=zeros(gridmax_x,gridmax_y);
for x=1:size(posdata)
    xx=posdata(x,2);
    yy=posdata(x,3);
    if(ignore_orig==1)
        if(xx==1 && yy==1)
            continue;
        end
    end
    xx=floor(xx);
    yy=floor(yy);
    if(xx==0)
        xx=1;
    end
    if(yy==0)
        yy=1;
    end
    spatial_occ(xx,yy)=spatial_occ(xx,yy)+1;
end
total_positions=sum(sum(spatial_occ));
occupancy_matrix=spatial_occ;
spatial_occ=spatial_occ./total_positions;

%================== FIRING RATES ====================%
fprintf('Calculating Firing rates...\n');

neurons=size(spikes);
neurons=neurons(2);
firingrates={};

for x=1:neurons
    frate=zeros(gridmax_x,gridmax_y);
    for timestamp=1:size(spikes{x})
        index=findnearest(spikes{x}(timestamp),posdata(:,1));
        index=index(1);
        if(index<startpoint || index>endpoint)
           continue;
        end
        xx=posdata(index,2);
        yy=posdata(index,3);
        if(ignore_orig==1)
            if(xx==1 && yy==1)
                continue;
            end
        end
        xx=floor(xx);
        yy=floor(yy);
        if(xx==0)
            xx=1;
        end
        if(yy==0)
            yy=1;
        end
        
        frate(xx,yy)=frate(xx,yy)+1;
    end
    firingrates=[firingrates {frate}];
    fprintf('Neuron %d complete\n',x);
end

for n=1:neurons
    for x=1:gridmax_x
        for y=1:gridmax_y
            if(firingrates{n}(x,y)~=0)
                firingrates{n}(x,y)=firingrates{n}(x,y)/(del_t*occupancy_matrix(x,y));
            end
        end
    end
end



params=[neurons; 0; startpoint; endpoint; gridmax_x; gridmax_y];
%params=[neurons; binsize_grid; startpoint; endpoint; gridmax_x; gridmax_y];

%model_params={params occupancy_matrix spatial_occ firingrates};
model_params={params binsize_grid spatial_occ firingrates};


        
    







end

