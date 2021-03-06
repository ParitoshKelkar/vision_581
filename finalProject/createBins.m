%% This script is going to be used to experiement with the parallel computing toolbox 
%  to extract and create the histogram bins


SET_PARAMS;

% create the mag, idxing template - gives us 144*9 matrix - (36*36)
sampleImg = read(dataSet,1);
[numR, numC,~] = size(sampleImg);
sampleImg = imresize(sampleImg, [RESIZE_R RESIZE_C]);

im_id_template  = reshape((1:RESIZE_C*RESIZE_R)',[RESIZE_R, RESIZE_C]);

% get the NUM_CELLS*CELL_SIZE by CELL_SIZE matrix
C = mat2cell(im_id_template,[repmat(CELL_SIZE,RESIZE_R/CELL_SIZE,1)],...
                                   [repmat(CELL_SIZE, RESIZE_R/CELL_SIZE,1)]);
cellIds = cell2mat(reshape(C,[RESIZE_R/CELL_SIZE*RESIZE_C/CELL_SIZE,1]));
cell_pixel_ids = cellIds((1:3:CELL_SIZE*NUM_CELLS)',1);
idx_template = repmat(cell_pixel_ids,1,CELL_SIZE*CELL_SIZE);
patch = cell2mat(C(1));
increment = patch - 1;
linear_adder = reshape(increment,CELL_SIZE*CELL_SIZE,1)';
linear_adder_spread = repmat(linear_adder,NUM_CELLS,1);
cell_pixel_ids = linear_adder_spread + idx_template;

% make template for the NUM_CELLS*(CELL_SIZE^2)
template_cell_idx = reshape((1:NUM_CELLS*CELL_SIZE*CELL_SIZE),NUM_CELLS,...
                                            CELL_SIZE*CELL_SIZE);
[cR, cC] = ind2sub([NUM_CELLS,CELL_SIZE*CELL_SIZE], ...
                                (1:NUM_CELLS*CELL_SIZE*CELL_SIZE));
    
cC =cC';
cR = cR';

clearStorage = zeros(NUM_CELLS,CELL_SIZE*CELL_SIZE,NUM_BINS);
storage =  zeros(NUM_CELLS,CELL_SIZE*CELL_SIZE,NUM_BINS);

% define the block layout - in terms of cell_idx
cellGrid = reshape((1:NUM_CELLS),[CELLM_R, CELLM_R]);
blockGrid = cellGrid(1:end-1,1:end-1);
blockIncrement = [0 1 CELLM_R CELLM_R+1];
blockIds = reshape(blockGrid,[(BLOCKM_R)*(BLOCKM_R),1]);
blockIds_spread = repmat(blockIds,1,4);
blockIncrement_spread = repmat(blockIncrement,(BLOCKM_R)*(BLOCKM_R),1);
blockLayout = blockIncrement_spread + blockIds_spread;

myfun = @testCellFun;

for n = 1: dataSet.Count    
    

    tic
    % resize a bit
    currImg = double(read(dataSet,n));
    currImg = imresize(currImg, [RESIZE_R RESIZE_C]);
    
    % calculate the gradient(keep max over each channel at that pixel)
    
    [ix, iy] = gradient(currImg);
    ix = max(ix,[],3);
    iy = max(iy,[],3);
    
    angles = atan2d(iy, ix); % orientation of the gradient element; can be
                             % made an edge - should not make a difference
                            
    % change the range of the angles
    angles(angles > 179 ) = angles(angles > 179) - 179;
    angles(angles <  0) = angles(angles < 0) + 179;
    angles(angles < 10) = 10;
    angles(angles > 170) = 169;
    angles = angles + 10;
    
    % the magnitude of the gradient - arranged by cell
    magGradient = sqrt(ix.*ix + iy.*iy);       
    
    reshapedAngles = angles(reshape(cell_pixel_ids,RESIZE_R*RESIZE_C,1)');
    reshapedAngles = reshape(reshapedAngles,[NUM_CELLS,CELL_SIZE*CELL_SIZE]);    
    
    magGradient = magGradient(reshape(cell_pixel_ids,RESIZE_R*RESIZE_C,1)');
    magGradient = reshape(magGradient, [NUM_CELLS,CELL_SIZE*CELL_SIZE]);    
    
    % to this mag matrix, obtain the quotient and remainder
    binCentres_rows = floor(reshapedAngles./20);
    R = 1 - rem(reshapedAngles,20)./20;
    votedMag_lower = magGradient.*R;
    
    
    % storage ids
    storage_ids = NUM_CELLS*CELL_SIZE*CELL_SIZE.*(cC-1) + cR + ...
                  NUM_CELLS.*(reshape(binCentres_rows,...
                            [NUM_CELLS*CELL_SIZE*CELL_SIZE, 1]) - 1);
                        
    
    storage(storage_ids) = reshape(votedMag_lower,...
                            [NUM_CELLS*CELL_SIZE*CELL_SIZE, 1]);
    % clear storage
    
    
    
    accBins = sum(storage,3);
    storage = clearStorage;
    
    % do the same shit for the upper part of the bilinear interpolation
    binCentres_rows = ceil(reshapedAngles./20);
    R = rem(reshapedAngles,20)./20;
    votedMag_upper = magGradient.*R;
    
    % storage ids - upper part of the bilinear interpolation
    storage_ids = NUM_CELLS*CELL_SIZE*CELL_SIZE.*(cC-1) + cR + ...
                  NUM_CELLS.*(reshape(binCentres_rows,...
                            [NUM_CELLS*CELL_SIZE*CELL_SIZE, 1]) - 1);
                        
    
    storage(storage_ids) = reshape(votedMag_upper,...
                            [NUM_CELLS*CELL_SIZE*CELL_SIZE, 1]);
    
    
    tempAccBins = sum(storage,3);
    accBins = tempAccBins + accBins;
    storage = clearStorage;    
    
    
    blockBins = accBins(blockLayout',:);
    
    blockCelled = mat2cell(blockBins,[4.*ones(BLOCKM_R*BLOCKM_R,1)],NUM_BINS);
    tempBins = cellfun(myfun,blockCelled,'UniformOutput',0);
    tempBins = cell2mat(tempBins);
    hog_features  = reshape(tempBins,[1,BLOCKM_R*BLOCKM_R*4*NUM_BINS]);
    
   toc
   tic
    [u,v] = extractHOGFeatures(currImg);
toc
    
end

