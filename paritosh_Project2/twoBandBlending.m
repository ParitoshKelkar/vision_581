function [im_blend, im1_low, im1_high, im2_low, im2_high] = twoBandBlending(im1, im2)

i1 = im2double(im1);
i2 = im2double(im2);

[r,c,~] = size(i1);

% define the window size 
window = 25; % on each side

% define a smoothing kernel with some standard deviation and variance
STD_DEV = 5;
smoothing_kernel = fspecial('gaussian',window, STD_DEV);
% win_str = num2str(window);
% std_str = num2str(STD_DEV);
% figure; mesh(smoothing_kernel);
% title(strcat('the kernel used: window =',win_str,' and std_Dev= ',std_str));                                           

% apply the filter to the images 
i1_smooth = imfilter(i1,smoothing_kernel,'replicate');
i2_smooth = imfilter(i2,smoothing_kernel,'replicate');

% extract the high freq components of both the images
i1_high = i1 - i1_smooth;
i2_high = i2 - i2_smooth;

% display high and low images
% figure;
% subplot(2,2,1);
% imshow(i1_smooth);
% title('i1_smooth');
% 
% subplot(2,2,2);
% imshow(i1_high);
% title('i1_high');
% 
% subplot(2,2,3);
% imshow(i2_smooth);
% title('i2_smooth');
% 
% subplot(2,2,4);
% imshow(i2_high);
% title('i2_high');


% defining a binary mask for these images; i1 has priority
binary_mask = ([ones(r, floor(c/2)+window),zeros(r, ceil(c/2)-window)]);


% the high component of the blend
blended_high = repmat(binary_mask,[1,1,3]).*i1_high + ...
                    i2_high.*(1 - repmat(binary_mask, [1,1,3]));
                
% figure;
% imshow(blended_high); title('high blend');

% the low component of the blended image should follow the same mask?\
linear_values = fliplr(0 : 1/window : 1);
linear_window = repmat(linear_values,r,1,1);
linear_mask = ([ones(r,floor(c/2)+ceil(0.5*length(linear_values)) ),linear_window,zeros(r,ceil(c/2)- ceil(1.5*size(linear_window,2)))]);

% the blended_low component
blended_low = repmat(linear_mask,[1,1,3]).*i1_smooth + ...
                    i2_smooth.*(1 - repmat(linear_mask, [1,1,3]));


% figure;
% imshow(blended_low);title('low blend');
% 
% figure; imshow(blended_low + blended_high); title('result');  

im_blend = (blended_low + blended_high);
im1_low = i1_smooth;
im1_high = i1_high;
im2_low = i2_smooth;
im2_high = i2_high;


end