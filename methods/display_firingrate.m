function [ ] = display_firingrate( model_params,neuron,checker )
%DISPLAY_FIRINGRATE Summary of this function goes here
%   Detailed explanation goes here

if(nargin<2)
    error('Call function with parameter model and neuron number.');
end

if(nargin==2)
    checker=1;
end

maxneurons=model_params{1}(1);
if(neuron<1 || neuron>maxneurons)
    error('Neuron number exceeds that of model');
end
firing_rates=model_params{4};
map=rot90(firing_rates{neuron});
if(checker==1)
    pcolor(map);
else
    imagesc(map);
end

end

