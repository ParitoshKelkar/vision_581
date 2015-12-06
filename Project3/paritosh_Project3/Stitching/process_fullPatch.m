function  patch  = process_fullPatch( fullPatch )
% Does the blurring and then subsampling on the 40 x 40 i/p

    filteredPatch = imgaussfilt(fullPatch,0.5);
    
    % subsample
    patch = filteredPatch(1:5:end,1:5:end);


end

