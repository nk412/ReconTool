function [ ] = display_neuronselectivity( params, checker)
%DISPLAY_NEURONSELECTIVITY Summary of this function goes here
%   Detailed explanation goes here
if(nargin<1)
    error('Call function with parameter model and neuron number.');
end

if(nargin==1)
    checker=1;
end

neurons=params{1}(1);
gridmax_x=params{1}(2);
gridmax_y=params{1}(3);
firingrates=params{4};

selectivity_grid=zeros(gridmax_x,gridmax_y);

for x=1:gridmax_x
	for y=1:gridmax_y
		max_rate=0;
		max_n=0;
		for tt=1:neurons
			sumrates=sum(sum(firingrates{tt}));
			selectivity= firingrates{tt}(x,y)/sumrates;
			if(selectivity>max_rate)
				max_rate=sumrates;
				max_n=tt;
			end
		end
		selectivity_grid(x,y)=max_n;
		if(selectivity_grid(x,y)==0)
			selectivity_grid(x,y)=-1;
		end

	end
end

map=rot90(selectivity_grid);
if(checker==1)
    pcolor(flipud(map));
else
    imagesc(map);
end




end

