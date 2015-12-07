%% This script demos the image stitching


close all


% params
global I;
global numR; 
global numC;
global visualizeMatched;
global visualizeRANSAC;
global show_ANMS;
global visualizeRANSAC_result;


show_ANMS = 0;
visualizeRANSAC = 0; % sampling
visualizeMatched = 0;
visualizeRANSAC_result = 0;


load('carCell.mat');
panorama = mymosaic(carCell);


% load('cellPitt.mat')
% panorama = mymosaic(cellPitt);

imshow(panorama);
title('Panorama')