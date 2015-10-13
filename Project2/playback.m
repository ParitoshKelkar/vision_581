%% playback

frames = length(warp_frac);
figure;
hold on;
for iter = 1 : frames
    
    imshow(intermediateFrames(:,:,:,iter));
    
    
end