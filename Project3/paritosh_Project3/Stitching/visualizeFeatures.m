function visualizeFeatures( im1,pts1, im2, pts2 )
% visualizes t1he feature desc
global numR;
global numC;


[im1_r, im1_c] = ind2sub([numR, numC], pts1);
subplot(1,2,1);
imshow(im1);
hold on;
plot(im1_c, im1_r,'r*');
hold off


[im2_r, im2_c] = ind2sub([numR, numC], pts2);
subplot(1,2,2);
imshow(im2);hold on
plot(im2_c, im2_r,'b*');
hold off




end

