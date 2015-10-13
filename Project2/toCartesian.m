function [ cartX, cartY ] = toCartesian( pixelR, pixelC )
% This converts image coordinates to cartesian cooridantes

maxR = max(pixelR);
maxC = max(pixelC);

cartX = pixelC;
cartY = maxC - pixelR;

 
end

