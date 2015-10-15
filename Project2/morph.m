function [ morphed_im ] = morph( im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac )
% This is the image morphing function


deltaR = im2_pts(:,1) - im1_pts(:,1);
deltaC = im2_pts(:,2) - im1_pts(:,2);

% sizes
[numR, numC, ~] = size(im1);

meanPtsR  = im1_pts(:,1) + 0.5*im2_pts(:,1);
meanPtsC  = im1_pts(:,2) + 0.5*im2_pts(:,2);

meanPtsR(meanPtsR < 3) = 1;
meanPtsR(meanPtsR > numC -2) = numC;

meanPtsC(meanPtsC < 3) = 1;
meanPtsC(meanPtsC > numR -1) = numR;

meanPts = [round(meanPtsR) round(meanPtsC)];

%tri = delaunay((meanPtsR), (meanPtsC));

% create an array defining the pixel idx vs the triangleId
px_ids = 1 : numR*numC;
[pixelR, pixelC] = ind2sub([numR, numC],px_ids);

% convert the points to the cartesian space
% tsearchn works with cartesian space
% [cartX, cartY] = toCartesian(pixelR, pixelC);

tri_ids = tsearchn([im1_pts(:,1) im1_pts(:,2)],tri,[pixelC',pixelR']); % this is the swap 
%because cpselect returns stuff in a wierd coordinate frame

cross_dissolve = dissolve_frac;

intermediateFrames = zeros(0,0,3);
%for frameIter = 1: length(warp_frac)
    
    
    intermediate_cp = (1-warp_frac).*im1_pts + warp_frac.*(im2_pts);
    
    
    for iterPixel = 1 : numR*numC
        
        
        inTri = tri_ids(iterPixel);
        inTri_vertices = tri(inTri,:);
        
        % get intermediate_cp vertices
        tri_vertices_im = intermediate_cp(inTri_vertices,:);
        
        % calculate respective baryCentric coordinates
        % Ax= B; x = A\B
        A = [tri_vertices_im';ones(1,3)];
        [pixelR, pixelC] = ind2sub([numR,numC],iterPixel);
        B = [pixelC;pixelR;1];    % wierd frame system
        bary = A\B;        
        
        % take this barycentic and apply on the source images
        % for batman
        batTris = im2_pts(inTri_vertices,:);        
        
        %  form of the equation
        A = [batTris';ones(1,3)];       
        
        % get transformed coordinates
        inversePos_batman = A*bary;
        inversePos_batman = round(inversePos_batman./inversePos_batman(3));
        inversePos_batman(inversePos_batman < 1) = 1;
        if inversePos_batman(1) > numC
               inversePos_batman(1) = numC;
        end
        if inversePos_batman(2) > numR
               inversePos_batman(2) = numR;
        end
        
         % for Nolan
        nolanTris = im1_pts(inTri_vertices,:);        
        
        %  form of the equation
        A = [nolanTris';ones(1,3)];       
        
        % get transformed coordinates
        inversePos_nolan = A*bary; % bary remains the same
        inversePos_nolan = round(inversePos_nolan./inversePos_nolan(3));
        inversePos_nolan(inversePos_nolan < 1) = 1;
        
        if inversePos_nolan(1) > numC
               inversePos_nolan(1) = numC;
        end
        if inversePos_nolan(2) > numR
               inversePos_nolan(2) = numR;
        end
        % use cross dissolve for this timestep        
        intermediateFrames(pixelR,pixelC,:) = ...
                            (1-cross_dissolve).*im1(inversePos_nolan(2), inversePos_nolan(1),:) + ...
                            (cross_dissolve).*im2(inversePos_batman(2), inversePos_batman(1),:); 
        
        
    end
    
    
    
    

morphed_im = intermediateFrames;

end

