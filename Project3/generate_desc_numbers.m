%% This script gives the desc indecies

im1_c_r = [799 391; 468 332; 838 333; 789 257; 833 29; 450 283];
im2_c_r = [493 380; 163 331; 530 324; 484 251; 519 34; 147 280];

% the desc idx arrays
im1_desc_idx = zeros(size(im1_c_r,1),1);
im2_desc_idx = zeros(size(im1_c_r,1),1);

for iter = 1 : size(im1_c_r,1)
    
    im1_desc_idx(iter) = find(im1_corn_r == im1_c_r(iter,2) & im1_corn_c == im1_c_r(iter,1));
    im2_desc_idx(iter) = find(im2_corn_r == im2_c_r(iter,2) & im2_corn_c == im2_c_r(iter,1));
end