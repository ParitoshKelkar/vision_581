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

lambda = 0.01;

for frameIter = 1 : length(warp_frac)
    
    % for source x and y
    [a1_s_x, ax_s_x, ay_s_x, w_s_x] = est_tps(ctr_pts,...
                                       target_value);
    
    
    intermediate_cp = (1-warp_frac(frameIter)).*nolanPoints + warp_frac(frameIter).*(batPoints);
    
    
    % for the source
    dist_mat = pdist2(intermediate_cp,nolanPoints);    
    K_source = -(dist_mat.^2)*log(dist_mat.^2); % p x p
    
    K_source(isnan(K_source)) = 0;
    P = [intermediate_cp, ones(size(intermediate_cp,1),1)];
    
    % formulating for x_source and y_source    
    concat_matrix = [K_source P; P' zeros(3,3)];
    vx = [nolanPoints(:,1); zeros(3,1)];    
    vy = [nolanPoints(:,2);zeros(3,1)];
    
    [coeff_x_source]  = inv(concat_matrix + lambda.*eye(size(nolanPoints,1)+3))*vx;
    [coeff_y_source]  = inv(concat_matrix + lambda.*eye(size(nolanPoints,1)+3))*vy;
    
    
    % for the final image(bat)
    dist_mat = pdist2(intermediate_cp,batPoints);    
    K_dest = -(dist_mat.^2)*log(dist_mat.^2); % p x p
    
    K_dest(isnan(K_dest)) = 0;
    P = [intermediate_cp, ones(size(intermediate_cp,1),1)];
    
    % formulating for x_dest and y_dest    
    concat_matrix = [K_dest P; P' zeros(3,3)];
    vx = [batPoints(:,1); zeros(3,1)];
    vy = [batPoints(:,2);zeros(3,1)];
    
    [coeff_x_dest]  = (concat_matrix + lambda.*eye(size(nolanPoints,1)+3))\vx;
    [coeff_y_dest]  = (concat_matrix + lambda.*eye(size(nolanPoints,1)+3))\vy;
    %% 
    % take these coefficients and implement the inverse mapping
    % for both, the source and the dest im
    
    [pixelR, pixelC] = ind2sub([numR, numC],(1:numR*numC));
    
    % to calculate pdist2,
    dist_mat_source_x = pdist2([pixelC', pixelR'],...
                                    intermediate_cp);
    U_mat = -(dist_mat_source_x.^2).*log(dist_mat_source_x.^2)                            ;
    U_mat(isnan(U_mat)) = 0;
    
    % form the w-array
    w_params_x_source = coeff_x_source(1:end-3)';
    w_params_x_source = repmat(w_params_x_source,numR*numC,1);
    A = coeff_x_source(end-2:end)';
    
   % A = [ay_x_source ax_x_source a1];
   
    % do the summation after the multiplication
    interiorSum = w_params_x_source.*U_mat;
    summation = sum(interiorSum,2);
    
    a_source_mat = repmat(A,numR*numC,1);
    
    % multiple with corresponding pixel cooridantes
    outsideSum = a_source_mat.*[pixelR', pixelC', ones(numR*numC,1)];
    
    % get final transformed x-coordinates source
    x_cdts_source = sum([outsideSum,summation],2);
    
    % similarly take y_cdts_source-_____________________
     % form the w-array
    w_params_y_source = coeff_y_source(1:end-3)';
    w_params_y_source = repmat(w_params_y_source,numR*numC,1);
    A = coeff_y_source(end-2:end)';
    
    %A = [ay_y_source ax_y_source a1];
    
    % do the summation after the multiplication
    interiorSum = w_params_y_source.*U_mat;
    summation = sum(interiorSum,2);
    
    a_source_mat = repmat(A,numR*numC,1);
    
    % multiple with corresponding pixel cooridantes
    outsideSum = a_source_mat.*[pixelR', pixelC', ones(numR*numC,1)];
    
    % get final transformed x-coordinates source
    y_cdts_source = sum([outsideSum,summation],2);
    
    
    %% DEST
    
    
    % take these coefficients and implement the inverse mapping
    % for both, the source and the dest im
    
    [pixelR, pixelC] = ind2sub([numR, numC],(1:numR*numC));
    
    % to calculate pdist2,
    dist_mat_dest_x = pdist2([pixelC', pixelR'],...
                                    intermediate_cp);
    U_mat = -(dist_mat_dest_x.^2).*log(dist_mat_dest_x.^2)                            ;
    U_mat(isnan(U_mat)) = 0;
    
    % form the w-array
    w_params_x_dest = coeff_x_dest(1:end-3)';
    w_params_x_dest = repmat(w_params_x_dest,numR*numC,1);
    A = coeff_x_dest(end-2:end)';
    
   % A = [ay_x_source ax_x_source a1];
   
    % do the summation after the multiplication
    interiorSum = w_params_x_source.*U_mat;
    summation = sum(interiorSum,2);
    
    a_dest_mat = repmat(A,numR*numC,1);
    
    % multiple with corresponding pixel cooridantes
    outsideSum = a_dest_mat.*[pixelR', pixelC', ones(numR*numC,1)];
    
    % get final transformed x-coordinates DEST
    x_cdts_dest = sum([outsideSum,summation],2);
    
    % similarly take y_cdts_DEST-_____________________
     % form the w-array
    w_params_y_dest = coeff_y_dest(1:end-3)';
    w_params_y_dest = repmat(w_params_y_dest,numR*numC,1);
    A = coeff_y_dest(end-2:end)';
    
    %A = [ay_y_source ax_y_source a1];
    
    % do the summation after the multiplication
    interiorSum = w_params_y_dest.*U_mat;
    summation = sum(interiorSum,2);
    
    a_dest_mat = repmat(A,numR*numC,1);
    
    % multiple with corresponding pixel cooridantes
    outsideSum = a_dest_mat.*[pixelR', pixelC', ones(numR*numC,1)];
    
    % get final transformed x-coordinates DEST
    y_cdts_dest = sum([outsideSum,summation],2);
                           
    
    %% Cross dissolve = warp_frac
    
%    inv_source_ids = sub2ind([numR, numC],[y_cdts_source,x_cdts_source]);
%    inv_dest_ids = sub2ind([numR, numC],[y_cdts_dest,x_cdts_dest]);    
    
    intermediateFrame = (1-warp_frac).*myNC(x_cdts_source,y_cdts_source,:) + ...
                            (warp_frac).*myBat(x_cdts_dest,y_cdts_dest,:);
                            
    
    
end
