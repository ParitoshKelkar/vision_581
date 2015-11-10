[r g b] = deal(rgb2gray(I2));
r(im2_filteredPts) = 255;
g(im2_filteredPts) = 255;
b(im2_filteredPts) = 0;
RGB = cat(3,r,g,b);
figure;
imshow(RGB)