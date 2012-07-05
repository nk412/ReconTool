function [ out_cells ] = recon_error( position_data, post_recon_data, model_params )
%RECON_ERROR Summary of this function goes here
%   Detailed explanation goes here


%------------Discretizing Position data into bins------------%
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



%------------------Error calculation---------------------------%
intervals=numel(post_recon_data);

out_cells={};
for intr=1:intervals
	out_intervals=[];
	timesteps=numel(post_recon_data{intr}{1}(:,1));
	interval_data=post_recon_data{intr}{1};
	for each_time=1:timesteps
		true_time_index=findnearest(interval_data(each_time,1),position_data);
		true_x = position_data(true_time_index,2);
		true_y = position_data(true_time_index,3);

		est_x = interval_data(each_time,2);
		est_y = interval_data(each_time,3);
		time_val = interval_data(each_time,1);

		%----find euclidian distance------%

		error_dist=sqrt((true_x(1) - est_x(1))^2 + (true_y(1) - est_y(1))^2);
		out_intervals= [out_intervals; time_val(1), est_x(1), est_y(1), true_x(1), true_y(1), error_dist];
	end
	out_cells{intr}=out_intervals;
end

end

