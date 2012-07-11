function [ model_params ] = traindata( position_data, spikes, binsize_grid, intervals )
%  traindata(position_data, spikes, binsize_grid, intervals)
% Trains the model on given position data and spiking activity of an neural
% ensemble. The grid size for discretization is also specified. Optionally,
% intervals within which training should be carried out can also be specified.
%
% Inputs -
% position_data - Positional data in the form of a Tx3 matrix, where T is the
%                 number of timesteps. The three columns correspond to timestep,
%                 X coordinate at T and Y coordinate at T respectively.
% spikes        - A cell array containing N vectors, where N is the number of
%                 neurons. Each vector contains timestamps at which the neuron
%                 fired.
%
% Optional Inputs-
% binsize_grid  - [M,N] - Is a vector containing two values, M and N, and is used
%                 break discretize the data into an MxN grid. By default, a
%                 64x64 bin density is used.
% intervals     - This is a Ix2 matrix, where I is the number of intervals.
%                 The model will be trained only on data falling within these 
%                 intervals. At every interval specified, the first column 
%                 represents the start timestamp, and the second columnt 
%                 indicates the end timestamp for the interval. By default,
%                 A single interval that encompasses all given data is used.
%
% Outputs-
% model_params  - Model_params contains parameters built from the given data.
%                 It is in the form of a cell array, that contains the following
%                 general elements : number of neurons, grid size X, grid size Y.
%                 It also contains occupancy matrix and firing rates for the 
%                 individual neurons. The intervals between which it was trained
%                 is also contained in model_params. The model_params cell array
%                 encapsulates all information that would be required for
%                 reconstruction by any algorithm.



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
if(n_grid<4 || m_grid<4)
    error('Minimum grid size should be 4x4'); % minimum 4x4
end
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

tempy=[];
for tempx=2:numel(posdata(:,1))
    tempy=[tempy;posdata(tempx,1)-posdata(tempx-1,1)];
end
del_t=round(mean(tempy));


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

%Calculates firing rates from occupancy matrix -------------------------
for n=1:neurons
    for x=1:gridmax_x
        for y=1:gridmax_y
            if(firingrates{n}(x,y)~=0)
                firingrates{n}(x,y)=firingrates{n}(x,y)/(del_t*occupancy_matrix(x,y));
            end
        end
    end
end



params=[neurons; gridmax_x; gridmax_y; del_t];
%params=[neurons; binsize_grid; startpoint; endpoint; gridmax_x; gridmax_y];

%model_params={params occupancy_matrix spatial_occ firingrates};
model_params={params binsize_grid spatial_occ firingrates intervals occupancy_matrix};
end

