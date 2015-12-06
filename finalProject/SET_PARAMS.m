% define the imageLocation and collection
imageLocation = 'Caltech_CropFaces';
%imageLocation = 'images';
dataSet = imageSet(imageLocation);

% the input size of the faces is 250 * 250 - This will be the sliding
% detection window


global CELL_SIZE;
global BLOCK_SIZE;
global RESIZE_R;
global RESIZE_C;
global NUM_CELLS;
global NUM_BINS;
global CELLM_R;
global BLOCKM_R;

CELL_SIZE = 3; % in terms of pixels
BLOCK_SIZE = 2; % in terms of cells 
RESIZE_R = 36;
RESIZE_C = 36;
NUM_BINS = 9;
NUM_CELLS = RESIZE_R*RESIZE_C / (CELL_SIZE*CELL_SIZE);
CELLM_R = RESIZE_R/CELL_SIZE;
BLOCKM_R = CELLM_R-1;
