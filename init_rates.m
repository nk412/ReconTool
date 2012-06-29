startpoint=min(position_data(:,1));
endpoint=max(position_data(:,1));
%startpoint=35818012;
%endpoint=41067684;
startpoint=findnearest(startpoint,position_data(:,1));
endpoint=findnearest(endpoint,position_data(:,1));
posdata=position_data(startpoint:endpoint,:);
binsize_grid=2; % in cm (default 1cm)
%binsize_time=1; % in seconds (default 1 second)
grid_factor=1.1;  % grid zoom factor (default 1x)
ignore_orig=1;  % Set to 1, to ignore all (0,0) points
max_x=max(position_data(:,2));
max_y=max(position_data(:,3));
del_t=333;

gridmax_x=round(max_x*grid_factor/binsize_grid);
gridmax_y=round(max_y*grid_factor/binsize_grid);

%=============== SPATIAL OCCUPANCY ===================%
fprintf('Calculating Spatial Occupancy...\n');
spatial_occ=zeros(gridmax_x,gridmax_y);
for x=1:size(posdata)
    xx=posdata(x,2)+1;
    yy=posdata(x,3)+1;
    if(ignore_orig==1)
        if(xx==1 && yy==1)
            continue;
        end
    end
    xx=floor(xx/binsize_grid);
    yy=floor(yy/binsize_grid);
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
spikes=hpc;
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
        xx=posdata(index,2)+1;
        yy=posdata(index,3)+1;
        if(ignore_orig==1)
            if(xx==1 && yy==1)
                continue;
            end
        end
        xx=floor(xx/binsize_grid);
        yy=floor(yy/binsize_grid);
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



params=[neurons; binsize_grid; startpoint; endpoint; gridmax_x; gridmax_y];
model_params={params occupancy_matrix spatial_occ firingrates};

        
    

%-----cleanup-----%
clear binsize_grid;
clear binsize_time;
clear grid_factor;
clear ignore_orig;
clear max_x;
clear max_y;
clear gridmax_x;
clear gridmax_y;
clear xx;
clear yy;
clear x;
clear n;
clear total_positions;
clear del_t;
clear frate;
clear spikes;
clear neurons;
clear startpoint;
clear endpoint;
clear occupancy_matrix;
clear spatial_occ;
clear firingrates;
clear params;
clear timestamp;
clear y;
clear posdata;
clear index;




