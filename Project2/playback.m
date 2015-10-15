%% playback
warp_frac = 0.01:0.01:0.99
frames = length(warp_frac);
figure;
hold on;
for iter = 1 : frames
    
    imshow(intermediateFrames(:,:,:,iter));
    
    
end