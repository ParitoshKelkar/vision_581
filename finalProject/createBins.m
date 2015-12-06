%% This script is going to be used to experiement with the parallel computing toolbox 
%  to extract and create the histogram bins


% define the imageLocation and collection
imageLocation = 'Caltech_CropFaces';
%imageLocation = 'images';
dataset = imageSet(imageLocation);

% the input size of the faces is 250 * 250 - This will be the sliding
% detection window

CELL_SIZE = 3; % in terms of pixels
BLOCK_SIZE = 2; % in terms of cells 

for n = 1: dataset.Count    
    
    % resize a bit
    currImg = double(read(dataset,n));
    currImg = imresize(currImg, [36 36]);
    
    % calculate the gradient(keep max over each channel at that pixel)
    [ix, iy] = gradient(currImg);
    ix = max(ix,[],3);
    iy = max(iy,[],3);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end

