%% This script is used to visualise if the descriptor is working

s1 = subplot(1,2,1);
imshow(I1);

s2 = subplot(1,2,2);
imshow(I2);

for iter = 1 : length(im1_filteredPts)
    
    hold(s1);
    plot(s1,im1_filterPts_cartesian(iter,2), im1_filterPts_cartesian(iter,1), '*r');
    
    hold(s1)
    
    
    hold(s2)
    plot(s2,mappedTo_cart(iter,2), mappedTo_cart(iter,1), '*b');
    hold(s2)
    
    drawnow
    
    
    
end