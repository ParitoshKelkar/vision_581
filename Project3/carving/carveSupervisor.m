%% This code is for testing and debugging seam carving

% define the image
I = imread('west_end_overlook.jpg');
originalI = I;
[nx,ny,~] = size(I);

% define the number of seams that have to be removed
% as a percentage of the number of col
reduceWidth = 0.20;
reduceHt = 0.2;
hist_rmIdx = [];
hist_rmIdy = [];

% for iterReduceWidth  = 1 : round(reduceWidth*ny)
% 
% 
% % get the energy map
% e = genEngMap(I);
% 
% % Generate the Mx and Tbx
% [Mx, Tbx] = cumMinEngVer(e);
% 
% % get the ids of indecies that have to be removed
% [Ix,E,rmIdx] = rmVerSeam(I,Mx,Tbx);
% 
% % visualise seam
% [r,c] = ind2sub([size(I,1), size(I,2)], rmIdx);
% 
% 
% I = Ix;
% 
% hist_rmIdx = [hist_rmIdx; rmIdx];

% end


% flip images to take care of stupid matlab convention 
% in images
I1 = fliplr(I(:,:,1)');
I2 = fliplr(I(:,:,2)');
I3 = fliplr(I(:,:,3)');
IT(:,:,1) = I1;
IT(:,:,2) = I2;
IT(:,:,3) = I3;

for iterReduceHt  = 1 : round(reduceHt*ny)


% get the energy map
e = genEngMap(IT);

% Generate the Mx and Tbx
[My, Tby] = cumMinEngHor(e);

% get the ids of indecies that have to be removed
[Iy,E,rmIdy] = rmHorSeam(IT,My,Tby);

% visualise seam
[r,c] = ind2sub([size(IT,1), size(IT,2)], rmIdy);


IT = Iy;

hist_rmIdy = [hist_rmIdy; rmIdy];

end



%% The transport layer implication

[r,c] = ind2sub([size(originalI,1), size(originalI,2)], hist_rmIdx);
for iter = 1 : length(hist_rmIdx)
    originalI(r(iter),c(iter),:) = [255 0 0];
end


