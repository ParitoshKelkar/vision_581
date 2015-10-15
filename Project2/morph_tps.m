function [morphed_im] = morph_tps(im_source, a1, ax, ay, w, ctr_pts, sz)

   % transofrm all pixels in imB to imA.
   % use this transformed points to read the 
   
   morphed_im = zeros(size(im_source,1),size(im_source,2),3);
   morphedR = zeros(size(im_source,1), size(im_source,2));
   morphedG = zeros(size(im_source,1), size(im_source,2));
   morphedB = zeros(size(im_source,1), size(im_source,2));
   
   % take the dist mat as a (numR*numC) x p; ctr_pts are the intermediate 
   % control points
   [numR, numC,~] = size(im_source);
   [pixelR, pixelC] = ind2sub(size(im_source),1:numR*numC);
   p = size(ctr_pts,1);
   
   % The coefficients returned encompass the (x,y) components
   dist_mat = pdist2([pixelC',pixelR'],ctr_pts);
   uMat = (dist_mat.^2).*log(dist_mat.^2);
   uMat(isnan(uMat)) = 0;
   
   % inner summation
   % for the x_component
   inSummation_x = repmat(w(:,1)',numR*numC,1).*uMat;
   % for the y component
   inSummation_y = repmat(w(:,2)',numR*numC,1).*uMat;
   
   % sum the inSummation terms along each row
   xSummed = sum(inSummation_x,2);
   ySummed = sum(inSummation_y,2);
   
   % repmat the a1, ax and ay values
   % multiply the ax with x and ay with y ->xPart
   x_coeff = [a1(1).*ones(numR*numC,1)+ax(1).*pixelC'+ay(1).*pixelR'+xSummed]; 
   % for the y-part
   y_coeff = [a1(2).*ones(numR*numC,1)+ax(2).*pixelC'+ay(2).*pixelR'+ySummed];   
   
   % x_coeff bounds check
   x_coeff(x_coeff < 1) = 1;
   x_coeff(x_coeff > numC) = numC;
   x_coeff = round(x_coeff);
   
   % x_coeff bounds check
   y_coeff(y_coeff < 1) = 1;
   y_coeff(y_coeff > numR) = numR;
   y_coeff = round(y_coeff);
   
   morphed_ids = sub2ind([numR,numC],[y_coeff],[x_coeff]);
   % sanity check for morphed_ids
  
   % convert to morphed image
   im_source_R = im_source(:,:,1);
   im_source_G = im_source(:,:,2);
   im_source_B = im_source(:,:,3);
   
   morphedR(1:numR*numC) =im_source_R(morphed_ids);
   morphedG(1:numR*numC) =im_source_G(morphed_ids);
   morphedB(1:numR*numC) =im_source_B(morphed_ids);
   
   morphed_im(:,:,1) = morphedR;
   morphed_im(:,:,2) = morphedG;
   morphed_im(:,:,3) = morphedB;
   
   
   
end