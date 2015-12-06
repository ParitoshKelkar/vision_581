%% MATLAB does the stitching. Ill provide the features and all that

%% This script is the stitching _supervisor


% 
clear all
close all


% global params
global I;
global numR; 
global numC;

show_ANMS = 1;
visualizeRANSAC = 1;
visualizeResult = 0;
visualizeHomography = 1;

%% 1st image
% get the image
I = (imread('ex1.jpg'));
%I = imresize(I,0.5);
I1 = I;
I_gray = rgb2gray(I);
I_gray = double(I_gray);

[numR, numC] = size(I_gray);

% get the corners before ANMS
C_mag = cornermetric(im2double(rgb2gray(I)));

% params
NUM_PTS_REQD = 300;

% for every pixel, calc minR - mainly for visualising
minR_mat = 0.*ones(size(I_gray,1), size(I_gray,2));

% perform anms
[im1_corn_c, im1_corn_r, ~ ] = anms(C_mag,NUM_PTS_REQD);
im1_filteredPts = sub2ind([numR, numC], im1_corn_r,im1_corn_c);

% display
if (show_ANMS)
    
    figure; pts = axes;
    subplot(1,2,1);
    imshow(I1);
    hold on;
    plot(im1_corn_c, im1_corn_r,'.r');
    hold off;
end

% extract feature descriptors
im1_desc_linear = feat_desc(I_gray, im1_corn_r, im1_corn_c);
[im1_filterPts_cartesian(:,1),im1_filterPts_cartesian(:,2)] = ind2sub([numR, numC], im1_filteredPts);

%% 2nd image

I = (imread('ex2.jpg'));
%I = imresize(I,0.5);
I2 = I;
I_gray = rgb2gray(I);
I_gray = double(I_gray);

[numR, numC] = size(I_gray);

% get the corners before ANMS
C_mag = cornermetric(im2double(rgb2gray(I)));

% for every pixel, calc minR - mainly for visualising
minR_mat = 0.*ones(size(I_gray,1), size(I_gray,2));

% perform anms
[im2_corn_c, im2_corn_r, ~ ] = anms(C_mag,NUM_PTS_REQD);
im2_filteredPts = sub2ind([numR, numC], im2_corn_r,im2_corn_c);

% compare the points 
%visualizeFeatures(I1, im1_filteredPts, I2, im2_filteredPts);

% display
if (show_ANMS)
   
%    figure(pts); 
    subplot(1,2,2);
    imshow(I2);
    hold on;
    plot(im2_corn_c, im2_corn_r,'.b');
    hold off
    
end

% extract feature descriptors
im2_desc_linear = feat_desc(I_gray, im2_corn_r, im2_corn_c);
[im2_filterPts_cartesian(:,1),im2_filterPts_cartesian(:,2)] = ind2sub([numR, numC], im2_filteredPts);

%% feature matching

match_results = feat_match(im1_desc_linear, im2_desc_linear);

% filter match_results
valid_matches = find(match_results > -1);

mappedTo_idx = im2_filteredPts(match_results(valid_matches));
[mappedTo_cart(:,1), mappedTo_cart(:,2)] = ind2sub([numR, numC], mappedTo_idx);

% verify matched points 
figure; ax = axes;
showMatchedFeatures(rgb2gray(I1), rgb2gray(I2),fliplr(im1_filterPts_cartesian(valid_matches,:)), fliplr(mappedTo_cart),...
                    'montage', 'Parent', ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');

% verify that the features are indeed a match - visualise



%% get the notations sorted
source_pts = im1_filterPts_cartesian(valid_matches,:);
dest_pts = mappedTo_cart;

%% 
matchedPoints = dest_pts;
matchedPointsPrev = source_pts;

%%
% Estimate the transformation between I(n) and I(n-1).
tforms = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
    'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

imageSize = size(I);

[xlim(1,:), ylim(1,:)] = outputLimits(tforms, [1 imageSize(2)], [1 imageSize(1)]);


avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);