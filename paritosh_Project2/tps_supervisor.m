%% This script will be as close to the test script as possible
clear all
close all

%% INIT STUFF

% load the points
load('myBat.mat');
myBat = im2double(myBat);
load('batPoints_preProcess.mat'); % batman/
batPoints = batPoints;

load('myNC.mat');
myNC = im2double(myNC);
load('nolanPoints_preProcess.mat'); % nolan
nolanPoints = nolanPoints;

% sizes
[numR, numC,~] = size(myNC);

warp_frac = (0.01:0.01:0.99);
im1 = myNC;
im2 = myBat;
im1_pts = nolanPoints;
im2_pts = batPoints;

figure;
hold on;
for frameIter = 1 : length(warp_frac)
    
    dissolve_frac = warp_frac(frameIter);
    w = warp_frac(frameIter);
    morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts,w,dissolve_frac);
    
    imshow(morphed_im);
    
end



