%% This script takes up the triangulation in the fashion that it should have been probably done


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
    
    
    for iterPixel = 1 : numR*numC
        
        
        inTri = tri_ids(iterPixel);
        inTri_vertices = tri(inTri,:);
        
        % get intermediate_cp vertices
        tri_vertices_im = intermediate_cp(inTri_vertices,:);
        
        % calculate respective baryCentric coordinates
        % Ax= B; x = A\B
        A = [tri_vertices_im';ones(1,3)];
        [pixelR, pixelC] = ind2sub([numR,numC],iterPixel);
        B = [pixelC;pixelR;1];    % wierd frame system
        bary = A\B;        
        
        % take this barycentic and apply on the source images
        % for batman
        batTris = batPoints(inTri_vertices,:);        
        
        %  form of the equation
        A = [batTris';ones(1,3)];       
        
        % get transformed coordinates
        inversePos_batman = A*bary;
        inversePos_batman = round(inversePos_batman./inversePos_batman(3));
        inversePos_batman(inversePos_batman < 1) = 1;
        if inversePos_batman(1) > numC
               inversePos_batman(1) = numC;
        end
        if inversePos_batman(2) > numR
               inversePos_batman(2) = numR;
        end
        
         % for Nolan
        nolanTris = nolanPoints(inTri_vertices,:);        
        
        %  form of the equation
        A = [nolanTris';ones(1,3)];       
        
        % get transformed coordinates
        inversePos_nolan = A*bary; % bary remains the same
        inversePos_nolan = round(inversePos_nolan./inversePos_nolan(3));
        inversePos_nolan(inversePos_nolan < 1) = 1;
        
        if inversePos_nolan(1) > numC
               inversePos_nolan(1) = numC;
        end
        if inversePos_nolan(2) > numR
               inversePos_nolan(2) = numR;
        end
        % use cross dissolve for this timestep        
        intermediateFrames(pixelR,pixelC,:,frameIter) = ...
                            (1-cross_dissolve(frameIter)).*myNC(inversePos_nolan(2), inversePos_nolan(1),:) + ...
                            (cross_dissolve(frameIter)).*myBat(inversePos_batman(2), inversePos_batman(1),:); 
        
        
    end
    
    
    
    
end



