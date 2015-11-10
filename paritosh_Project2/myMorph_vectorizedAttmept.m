%% This script takes up the triangulation in the fashion that it should have been probably done
%% optimized version

clear all
close all

% misc parameters
movieTime = 3;

% load the points
load('myBat.mat');
myBat = im2double(myBat);
load('batPoints_preProcess.mat'); % batman
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


% compute the triangulation for the mean triangle
tri = delaunay((meanPtsR), (meanPtsC));

% create an array defining the pixel idx vs the triangleId
px_ids = 1 : numR*numC;
[pixelR, pixelC] = ind2sub([numR, numC],px_ids);

% convert the points to the cartesian space
% tsearchn works with cartesian space
% [cartX, cartY] = toCartesian(pixelR, pixelC);

tri_ids = tsearchn(meanPts,tri,[pixelC',pixelR']); % this is the swap 
%because cpselect returns stuff in a wierd coordinate frame

warp_frac = (0.01 : 0.01 : 0.99);
cross_dissolve = (0.01 : 0.01 : 0.99);


intermediateFrames = zeros(0,0,3,length(warp_frac));
for frameIter = 1: length(warp_frac)
    
    
    intermediate_cp = (1-warp_frac(frameIter)).*nolanPoints + warp_frac(frameIter).*(batPoints);
    
    % need to find the barycentric coordiantes for every pixelId
    pixelIds = 1 : numR*numC;
    [pixelR, pixelC] = ind2sub([numR, numC], pixelIds);
    
    
    % of the form Ax=B
    B_all = [pixelC';pixelR';ones(1,length(pixelR))];
    
    % calcualte A
    % find a triangle for every pt
    inTri = tri_ids(pixelIds);
    inTri_vertices = tri(inTri,:);    
    
    % get all the required triangle vertex coordinate
    tri_vertices_im(:,:,1) = intermediate_cp(inTri_vertices(:,1),:);
    tri_vertices_im(:,:,2) = intermediate_cp(inTri_vertices(:,2),:);
    tri_vertices_im(:,:,3) = intermediate_cp(inTri_vertices(:,3),:);
    
    
    
end

    
   
    
    