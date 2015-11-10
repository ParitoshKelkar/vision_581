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
load('nolanPoints_preProcess2.mat'); % nolan
nolanPoints = nolanPoints;

deltaR = batPoints(:,1) - nolanPoints(:,1);
deltaC = batPoints(:,2) - nolanPoints(:,2);


%% load the other image

% img = (imread('project2_testimg.png'));
% p1 = [1 1; 257 1; 1 257; 257 257; 129 129];
% p2(1) = {[1 1; 257 1; 1 257; 257 257; 129 33]};
% p2(2) = {[1 1; 257 1; 1 257; 257 257; 33 129]};
% p2(3) = {[1 1; 257 1; 1 257; 257 257; 129 223]};
% p2(4) = {[1 1; 257 1; 1 257; 257 257; 223 129]};
% p2(5) = {cell2mat(p2(1))};
% tri = delaunay(p1(:,1),p1(:,2));
%%
% sizes
[numR, numC,~] = size(myNC);

% process the points
batPoints(batPoints < 3) =1;
batPointsX = batPoints(:,1);
batPointsY = batPoints(:,2);
batPointsX(batPointsX > numC-3) = numC;
batPointsY(batPointsY > numR-3) = numR;
batPoints = [batPointsX batPointsY];


nolanPoints(nolanPoints < 3) =1;
nolanPointsX = nolanPoints(:,1);
nolanPointsY = nolanPoints(:,2);
nolanPointsX(nolanPointsX> numC-3) = numC;
nolanPointsY(nolanPointsY> numR-3) = numR;
nolanPoints = [nolanPointsX nolanPointsY];

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
for frameIter = 50: 0.5*length(warp_frac)
    
    
    intermediate_cp = (1-warp_frac(frameIter)).*nolanPoints + warp_frac(frameIter).*(batPoints);
    
    intermediate_cpX = intermediate_cp(:,1);
%     intermediate_cpX(intermediate_cpX < 10) = 1;
%     intermediate_cpX(intermediate_cpX > numC-10) = numC;
    
    
    intermediate_cpY = intermediate_cp(:,2);
%     intermediate_cpY(intermediate_cpY < 10) = 1;
%     intermediate_cpY(intermediate_cpY > numR-10) = numR;
    
    intermediate_cp = [intermediate_cpX intermediate_cpY];
    
    for iterPixel = 1 : numR*numC
        
        [pixelR, pixelC] = ind2sub([numR,numC],iterPixel);
        tri_ids = tsearchn((intermediate_cp),tri,[pixelC',pixelR']);
        inTri = tri_ids;
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



