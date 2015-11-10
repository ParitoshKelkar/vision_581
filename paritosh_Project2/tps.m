%% This script is for implementing TPS--

clear all
close all

% misc parameters
movieTime = 3;

% load the points
load('myBat.mat');
myBat = im2double(myBat);
load('batPoints_preProcess.mat'); % batman/
batPoints = batPoints;

load('myNC.mat');
myNC = im2double(myNC);
load('nolanPoints_preProcess.mat'); % nolan
nolanPoints = nolanPoints;

deltaR = batPoints(:,1) - nolanPoints(:,1);
deltaC = batPoints(:,2) - nolanPoints(:,2);

% sizes
[numR, numC,~] = size(myNC);

% meanPts 
meanPtsR = nolanPoints(:,1) + 0.5.*deltaR;
meanPtsC = nolanPoints(:,2) + 0.5.*deltaC;

% preprocess the menPtsR and meanPtsC
meanPtsR(meanPtsR < 3) = 1;
meanPtsR(meanPtsR > 187) = 188;

meanPtsC(meanPtsC < 3) = 1;
meanPtsC(meanPtsC > 217) = 219;

meanPts = [round(meanPtsR) round(meanPtsC)];

% find the coefficients for x;
% source image
warp_frac = (0.01:0.01:0.99);

figure;
hold on;
for frameIter = 1 : length(warp_frac)
         
    
    intermediate_cp = (1-warp_frac(frameIter)).*nolanPoints + ...
                                        warp_frac(frameIter).*(batPoints);                                    
    ctr_pts = intermediate_cp;    
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
    
    
    %% cross disssolve
    
    net_morphed = (1-warp_frac(frameIter)).*morphed_im_src + ...
                                     warp_frac(frameIter).*morphed_im_dest;    
    

                            
    imshow(net_morphed);
    
end
