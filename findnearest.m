function [r,c,V] = findnearest(srchvalue,srcharray,bias)

if nargin<2
    error('Need two inputs: Search value and search array')
elseif nargin<3
    bias = 0;
end

% find the differences
srcharray = srcharray-srchvalue;

if bias == -1   % only choose values <= to the search value
    
    srcharray(srcharray>0) =inf;
        
elseif bias == 1  % only choose values >= to the search value
    
    srcharray(srcharray<0) =inf;
        
end

% give the correct output
if nargout==1 | nargout==0
    
    if all(isinf(srcharray(:)))
        r = [];
    else
        r = find(abs(srcharray)==min(abs(srcharray(:))));
    end 
        
elseif nargout>1
    if all(isinf(srcharray(:)))
        r = [];c=[];
    else
        [r,c] = find(abs(srcharray)==min(abs(srcharray(:))));
    end
    
    if nargout==3
        V = srcharray(r,c)+srchvalue;
    end
end


    
