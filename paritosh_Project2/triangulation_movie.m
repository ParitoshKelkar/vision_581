%% This script depicts the changing triangular meshes that are genereated

clear all
close all

% misc parameters
movieTime = 5;

% load the points
load('newBatPts.mat'); % batman
batPoints = newBatPts;

load('newNolanPts.mat'); % nolan
nolanPoints = newNolanPts;


% compute the triangular mesh for the origianl set of points
% batOriginalMesh = delaunayTriangulation(fixedPoints1);
% nolanOriginalMesh = delaunayTriangulation(movingPoints1);

% we define some factor meshDissolve to be from [0,1]
meshDissolve = 0:0.01:1; 
scale = length(meshDissolve);

deltaR = batPoints(:,1) - nolanPoints(:,1);
deltaC = batPoints(:,2) - nolanPoints(:,2);

scaleR = deltaR./scale;
scaleC = deltaC./scale;

zR = zeros(length(scale),1);
zC = zeros(length(scale),1);

% we keep the bat fixed and nolan moving
meshIter = 1;
figure;
while(meshIter < length(meshDissolve))
    
        
    % incremental steps
    incrementalR = zR + meshIter.*scaleR;
    incrementalC = zC + meshIter.*scaleC;

    
    intermediateR = nolanPoints(:,1) + incrementalR;
    intermediateC = nolanPoints(:,2) + incrementalC;
    
    % generate the triangulations
    intermediate = delaunayTriangulation([intermediateR ...
                                                   intermediateC]);    
                                                    
    
                                                    
    % display the triangluation
    triplot(intermediate);
    str = num2str(meshIter);
    title(strcat('Iterations :',str));
    
    pause(movieTime/scale);
    
    % increment the iterator
    meshIter = meshIter + 1;   
    
    
    
end

