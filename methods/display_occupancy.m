function [ ] = display_occupancy( model_params, checker )
%DISPLAY_OCCUPANCY Summary of this function goes here
%   Detailed explanation goes here

if(nargin<1)
    error('Call function with parameter model.');
end
if(nargin==1)
    checker=1;
end

spatial_occupancy=model_params{2};
map=rot90(spatial_occupancy);
if(checker==1)
    pcolor(map);
else
    imagesc(map);
end

end

