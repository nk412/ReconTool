%   bin grid m x n
%   m ROWS and n COLUMNS

max_x=max(pos(:,2));
max_y=max(pos(:,3));
m=20;
n=20;
m=max_x/m;
n=max_y/n;

for x=1:numel(pos(:,1))
    pos(x,2)=round((pos(x,2)/m) + 1);
    pos(x,3)=round((pos(x,3)/n) + 1);
end