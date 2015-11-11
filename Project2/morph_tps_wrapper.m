function morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts,warp_frac,dissolve_frac)

    myNC = im1;
    myBat = im2;
    
    nolanPoints = im1_pts;
    batPoints = im2_pts;

    % find the cmontrolPoints w.r.t given warp_frac
    ctr_pts = (1-warp_frac).*nolanPoints + warp_frac.*(batPoints);
    
    %% get the coefficinets of the tps model
    % for x part
    target_value =  nolanPoints(:,1);
    [a1_s_x, ax_s_x, ay_s_x, w_s_x] = est_tps(ctr_pts,target_value);    
    % for y part
    target_value =  nolanPoints(:,2);
    [a1_s_y, ax_s_y, ay_s_y, w_s_y] = est_tps(ctr_pts,target_value);
    
    a1_s = [a1_s_x a1_s_y];
    ax_s = [ax_s_x ax_s_y];
    ay_s = [ay_s_x ay_s_y];
    w_s = [w_s_x w_s_y];
    
    % Do the same for the destImage
    %x part
    target_value =  batPoints(:,1);
    [a1_d_x, ax_d_x, ay_d_x, w_d_x] = est_tps(ctr_pts,target_value);    
    % for y part
    target_value =  batPoints(:,2);
    [a1_d_y, ax_d_y, ay_d_y, w_d_y] = est_tps(ctr_pts,target_value);
    
    a1_d = [a1_d_x a1_d_y];
    ax_d = [ax_d_x ax_d_y];
    ay_d = [ay_d_x ay_d_y];
    w_d = [w_d_x w_d_y];
    
    %% morph_tps   
    im_source = myNC;
    a1 = a1_s; ax = ax_s; ay = ay_s; w = w_s;sz=size(im_source);
    morphed_im_src = morph_tps(im_source, a1, ax, ay, w, ctr_pts, sz);
    
    im_dest = myBat;
    a1 = a1_d; ax = ax_d; ay = ay_d; w = w_d;sz=size(im_dest);
    morphed_im_dest = morph_tps(im_dest, a1, ax, ay, w, ctr_pts, sz);
    
    %% cross dissolve
    net_morphed = (1-dissolve_frac).*morphed_im_src + ...
                                     dissolve_frac.*morphed_im_dest;
    
                                 
    morphed_im = net_morphed;


end