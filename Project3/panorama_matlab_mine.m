%% MATLAB oriented

close all
clear all


global I;
global numR; 
global numC;
global visualizeHomography;
global visualizeMatched;
global visualizeRANSAC;
global show_ANMS;
global visualizeRANSAC_result;


show_ANMS = 0;
visualizeRANSAC = 0; % sampling
visualizeMatched = 0;
visualizeHomography = 0;
visualizeRANSAC_result = 1;

if (visualizeRANSAC_result)
    
    ransac_result = figure;
    ransac_result_ax = axes;
    
end

% Load Images
filePath = '/home/pari/Desktop/Courses/Vision/Project3/image_data_cliff';
buildingScene = imageSet(filePath);

% Read the first image from the image set.
I = read(buildingScene, 1);
I_gray = rgb2gray(I);
I1  = I;

% Initializ features for I(1)
I_gray = double(I_gray);

[numR, numC] = size(I_gray);

% get the corners before ANMS
C_mag = cornermetric(im2double(rgb2gray(I)));

% params
NUM_PTS_REQD = 300;

% for every pixel, calc minR - mainly for visualizing
minR_mat = 0.*ones(size(I_gray,1), size(I_gray,2));

% perform anms
[im1_corn_c, im1_corn_r, ~ ] = anms(C_mag,NUM_PTS_REQD);
im1_filteredPts = sub2ind([numR, numC], im1_corn_r,im1_corn_c);

if (show_ANMS)
    
    fig_anms = figure; 
    subplot(1,buildingScene.Count,1);
    imshow(I1);
    hold on;
    plot(im1_corn_c, im1_corn_r,'.r');
    hold off;
end


% extract feature descriptors
im1_desc_linear = feat_desc(I_gray, im1_corn_r, im1_corn_c);
[im1_filterPts_cartesian(:,1),im1_filterPts_cartesian(:,2)] = ind2sub([numR, numC], im1_filteredPts);

% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.
tforms(buildingScene.Count) = projective2d(eye(3));
 

% Iterate over remaining image pairs
for n = 2:buildingScene.Count

 
    % Read I(n).
    I = read(buildingScene, n);
    I2 = I;
    I_gray = rgb2gray(I);
    [numR,numC] = size(I_gray);
    
    % Initialize features for I(1)
    I_gray = double(I_gray);

    % Detect and features for I(n).
   C_mag = cornermetric(im2double(rgb2gray(I)));

   % for every pixel, calc minR - mainly for visualising
   minR_mat = 0.*ones(size(I_gray,1), size(I_gray,2));
   
   % perform anms
   [im2_corn_c, im2_corn_r, ~ ] = anms(C_mag,NUM_PTS_REQD);
   im2_filteredPts = sub2ind([numR, numC], im2_corn_r,im2_corn_c);
   

   if (show_ANMS)
       
       figure(fig_anms);
       subplot(1,buildingScene.Count,n);
       imshow(I2);
       hold on;
       plot(im2_corn_c, im2_corn_r,'.r');
       hold off;
   end
   
   % compare the points
   %visualizeFeatures(I1, im1_filteredPts, I2, im2_filteredPts);
   
  
   % extract feature descriptors
   im2_desc_linear = feat_desc(I_gray, im2_corn_r, im2_corn_c);
   [im2_filterPts_cartesianR,im2_filterPts_cartesianC] = ...
                                ind2sub([numR, numC], im2_filteredPts);

    
   im2_filteredPts_cartesian = [im2_filterPts_cartesianR, im2_filterPts_cartesianC];
    % Find correspondences between I(n) and I(n-1).
   match_results = feat_match(im1_desc_linear, im2_desc_linear);

   % filter match_results
   valid_matches = find(match_results > -1);
   
   mappedTo_idx = im2_filteredPts(match_results(valid_matches));
   [mappedTo_cartR, mappedTo_cartC] = ind2sub([numR, numC], mappedTo_idx);
    
   mappedTo_cart = [mappedTo_cartR,mappedTo_cartC];
   
   % verify matched points 
   if (visualizeMatched)
       figure; ax = axes;
       showMatchedFeatures(rgb2gray(I1), rgb2gray(I2),fliplr(im1_filterPts_cartesian(valid_matches,:)), fliplr(mappedTo_cart),...
           'montage', 'Parent', ax);
       title(ax, 'initial Candidate point matches');
       legend(ax, 'Matched points 1','Matched points 2');
   end
   
   
   
   source_pts = im1_filterPts_cartesian(valid_matches,:);
   dest_pts = mappedTo_cart;


   % Estimate the transformation between I(n) and I(n-1).
   tforms(n) = estimateGeometricTransform(fliplr(dest_pts), fliplr(source_pts),...
       'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
   %
   [H, inliers] = ransac_es_homography(dest_pts(:,1), dest_pts(:,2),...
       source_pts(:,1), source_pts(:,2),10);
%    
   
   if (visualizeRANSAC_result)
       
       ransac_source  = source_pts(inliers,:);
       ransac_matched = dest_pts(inliers,:);
       figure(ransac_result);
       showMatchedFeatures(rgb2gray(I1), rgb2gray(I2),fliplr(ransac_source), fliplr(ransac_matched),...
           'montage', 'Parent', ransac_result_ax);
       title(ransac_result_ax, 'RANSAC point matches');
       legend(ransac_result_ax, 'Matched points 1','Matched points 2');
       
       
       
   end
   
   tforms(n).T = H';
   % Compute T(1) * ... * T(n-1) * T(n)
   tforms(n).T = tforms(n-1).T * tforms(n).T;
end

imageSize = size(I);  % all the images are the same size

% Compute the output limits  for each transform
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);


for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I);


blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:buildingScene.Count

    I = read(buildingScene, i);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
end

figure
imshow(panorama)