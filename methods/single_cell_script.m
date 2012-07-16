tic


%------SINGLE POINT---------------------
% [traj,prob]=reconstruction(hpc,params,[31577213,31577215],pos,timewindow,1);
%post_recon=reconstruction(pos,hpc,params,[28394731,28394733],timewindow);


%-------LONG TRAIL-------------------------------
%post_recon=reconstruction(pos,hpc,params,[30703849,30907914],timewindow);
[traj,prob]=reconstruction(hpc,params,[30300000,31100000]);


%----full run----
%post_recon=reconstruction(pos,hpc,params,[30400000,31000000],timewindow);
 % post_recon=reconstruction(pos,hpc,params,[30450000,30500000],timewindow);


%--------SMALL TRAIL-----------------------------
%post_recon=reconstruction(pos,hpc,params,[30840000,30850000],timewindow);
%post_recon=reconstruction(pos,hpc,params,[28480000,28500000],timewindow);

toc
err=recon_error(pos,traj,params);
interval_one=err{1};
%display_plots;
beep;