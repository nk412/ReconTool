tic


%------SINGLE POINT---------------------
%post_recon=reconstruction(pos,hpc,params,[31577213,31577215],timewindow);
%post_recon=reconstruction(pos,hpc,params,[28394731,28394733],timewindow);


%-------LONG TRAIL-------------------------------
%post_recon=reconstruction(pos,hpc,params,[30703849,30907914],timewindow);


%--------SMALL TRAIL-----------------------------
%post_recon=reconstruction(pos,hpc,params,[30790000,30850000],timewindow);
post_recon=reconstruction(pos,hpc,params,[30790000,30820000],timewindow);

toc
err=recon_error(pos,post_recon,params);
interval_one=err{1};
%display_plots;
