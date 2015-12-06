%% carving demo script

nr = 50;
nc = 50;

originalI = imread('west_end_overlook.jpg');
tic
[Ic, T, Mx, My, Ix, Iy, Ex, Ey] = carv_wrap(originalI, nr, nc,0);
toc
fig_results = figure;
subplot(1,2,1);
imshow(originalI);
title('Original image');
subplot(1,2,2);
imshow(Ic);
title('After Seam Removal');
