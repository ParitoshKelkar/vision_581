%% This script implements the anms part of feature matching

% take in the image
I = im2double(imread('statue.jpg'));
I_gray = rgb2gray(I);
[numR, numC] = size(I_gray);
C_mag = cornermetric(I_gray);
C = imadjust(C_mag);
C = imregionalmax(C);

%  params
NUM_PTS_REQD = round(0.35.*length(find(C)));
show_ANMS = 1;

% for every pixel, calc minR
minR_mat = 0.*ones(size(C,1), size(C,2));

% 
potCorners_idx = find(C);
potCorners_mag = C_mag(potCorners_idx);

% init radius tracker aray
radius_tracker = -1.*ones(length(potCorners_idx),2);
radius_tracker(:,1) = potCorners_idx;

% stupid for loop for ANMS
for iterANMS  = 1 : length(potCorners_idx)
           
    current_idx = potCorners_idx(iterANMS);
    current_idx_mag = C(current_idx);
    
    % subtract this from the list of all the other values 
    diff_ = current_idx_mag./potCorners_mag;
    
    % take those points that satisy the `robustify' criteria
    robust_idx = potCorners_idx(diff_ >= 0.9);
    
    % with each of these points, calculate the distance from current_idx 
    robust_cartesian = ind2sub([numR, numC], robust_idx);
    current_cartesian = ind2sub([numR, numC], current_idx);    
    dist_measure = pdist2(current_cartesian,robust_cartesian);
    sorted_dist_measure = sort(dist_measure); 
    
    % fill in radius_tracker
    radius_tracker(iterANMS,:) = [current_idx, sorted_dist_measure(2)];    
  
    
end

% take the top NUM_PTS_REQD from the radius_tracker
[descending_radii,idx_track] = sort(radius_tracker(:,2), 'DESCEND');

% filteredPts 
filteredPts  = potCorners_idx(idx_track(1:NUM_PTS_REQD));


% display
if (show_ANMS)
    minR_mat(filteredPts) = 1;
    imshow(minR_mat);
end

%% form the feature descriptors

% form the 40 by 40 pixel box around the points chosen by the ANMS
% we use axis aligned descriptors over here

% check if we need to use symmetric padding
[filteredPts_cartersian(:,1), filteredPts_cartersian(:,2)] = ind2sub([numR numC], filteredPts);
padReqd_check = any(filteredPts_cartersian(:,1)>(numR-20) | filteredPts_cartersian(:,1) < 20 | ...
                    filteredPts_cartersian(:,2) > (numC - 20) | filteredPts_cartersian(:,2) < 20); 
if (padReqd_check)
    padded_image = padarray(I_gray,[40 40],'replicate');
    filteredPts_cartersian(:,1) = filteredPts_cartersian(:,1) + 40;
    filteredPts_cartersian(:,2) = filteredPts_cartersian(:,2) + 40;
end


% extract axis aligned patches
descriptors_patches = -1.*ones(8,8, length(filteredPts));
descriptors_linear = -1.*ones(length(filteredPts),8*8);

for iterDesc = 1:length(filteredPts)
    
    % set the bounds for every corner point
    curr_cart = filteredPts_cartersian(iterDesc,:);
    currR = curr_cart(1);
    currC = curr_cart(2);
    bounds = [currR-19, currR+20, currC-19, currC+20];  
    
    % patch process
    temp_patch = padded_image(bounds(1):bounds(2), bounds(3):bounds(4));
    patch = process_fullPatch(temp_patch);    
    linear_patch = imresize(patch,[1,size(patch,1)*size(patch,2)]);    
   
    % normalize the data
    norm_linear_patch = (linear_patch - mean(linear_patch))./std(linear_patch);
    
    % store the values 
    descriptors_patches(:,:,iterDesc) = patch;
    descriptors_linear(iterDesc,:) = norm_linear_patch;                           
   
end


%% match them with the other image - SSD

% We'll have to run the process till now through the other image

