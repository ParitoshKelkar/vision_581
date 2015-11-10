%% this script calculates the barycentric coordinates for every pixel

[numR,numC,~] = size(myBat);

baryCentricParams = zeros(numR*numC,3);

for iter_pixels = 1 : numR*numC
    
    inTri = tri_ids(iter_pixels);
    
    % all these values are in the wierd frame
    % (1,1) on top left and (numC,1) on top right
    tri_vertex_ids = tri(inTri,:);
    tri_vertices = meanPts(tri_vertex_ids,:);
    
    % put in Ax = B format
    A = [tri_vertices';ones(1,3)];
    [pixelR, pixelC] = ind2sub([numR,numC],iter_pixels);
    B = [pixelC;pixelR;1];    
        
    % compute the barycentric params
    baryCentricParams(iter_pixels,:) = (A\B)';
    
end