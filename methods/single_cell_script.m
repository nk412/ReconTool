tic
post_recon=reconstruction(pos,hpc,params,[31577213,31577215],timewindow);


% post_recon=reconstruction(pos,hpc,params,[30703849,30907914],timewindow);

toc
err=recon_error(pos,post_recon,params);
intr1=err{1};
intr1
