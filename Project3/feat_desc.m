function [ descriptors_linear ] = feat_desc(I_gray, im_corn_r, im_corn_c)
%% form the feature descriptors

global numR;
global numC;

filteredPts = sub2ind([numR, numC], im_corn_r,im_corn_c);

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
else
    padded_image = I_gray;
end


% extract axis aligned patchessaml 
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
    temp_patch = imgaussfilt(temp_patch,2.5);
    patch = process_fullPatch(temp_patch);    
    linear_patch = imresize(patch,[1,size(patch,1)*size(patch,2)]);   
   
    % normalize the data
    norm_linear_patch = (linear_patch - mean(linear_patch))./std(linear_patch);
    
    % store the values 
    descriptors_patches(:,:,iterDesc) = patch;
    descriptors_linear(iterDesc,:) = norm_linear_patch;                           
   

end

