function [bestH_post, inlier_ind] = ransac_es_homography(destR, destC, sourceR, sourceC, margin)

global visualizeRANSAC;
global visualizeHomography;


 %% RANSAC to get rid of false positives

 
source_pts =  [sourceR, sourceC];
dest_pts = [destR, destC] ;
 
% ransac param
list = (1: length(sourceR));
maxNumInliers = 0;

%say that the max number of iterations that we will need = 100
maxIter = 200;

% visual handles
if (visualizeRANSAC)
    ransac_fig = figure;
    ransac_ax = axes;
end
if (visualizeHomography)
    hom_graph = figure;    
    hom_axes = axes;
    imshow(I2);
end

% iterations
for iterRANSAC = 1 : maxIter
  
    % get valid 4 points
    curr_desc_idx = randsample(list,4);
    
    
    % current points in consideration - cartesian
    current_source = source_pts(curr_desc_idx,:);
    current_dest = dest_pts(curr_desc_idx,:);
    
    % the line check
    if ( size(unique(current_source(:,1))) == 1 | length(unique(current_source(:,2))) == 1  )
        continue;
    end
    
    
    % visualize the points of RANSAC - verify matched points     
    if (visualizeRANSAC) 
        
        showMatchedFeatures(rgb2gray(I1), rgb2gray(I2),fliplr(current_source), fliplr(current_dest),...
                            'montage', 'Parent', ransac_ax);
        title(ransac_ax, 'Candidate point matches');
        legend(ransac_ax, 'Matched points 1','Matched points 2');
    end
    
    % the est_homography
    H = est_homography(current_dest(:,2), current_dest(:,1),...
                        current_source(:,2), current_source(:,1));
    
    % apply this estimate to all the desc points    
    [projected_destC, projected_destR] = apply_homography(H, source_pts(:,2), source_pts(:,1));    
    projected_dest = [projected_destR projected_destC];

    
    % visualize all projected points
    
    if (visualizeHomography)
        
        figure(hom_graph);
        hold(hom_axes);
        plot(projected_dest(:,2), projected_dest(:,1),'.r');
        plot(dest_pts(:,2), dest_pts(:,1),'*b');
        hold(hom_axes);
    end
    

    
    % comapare the result with original points - calculate the error    
    error = ((dest_pts(:,1) - projected_dest(:,1)).^2 + (dest_pts(:,2) - projected_dest(:,2)).^2);
    
    % filter by margin threshold
    inliers_ = (error < margin);
    
    % store data if valuable
    if length(find(inliers_)) > maxNumInliers
        
        bestH = H;
        bestInliers_id = find(inliers_);
        maxNumInliers = length(bestInliers_id);
        
        inlierSet = source_pts(bestInliers_id,:);
        corr_inlierSet = dest_pts(bestInliers_id,:);
        bestH_post = est_homography(corr_inlierSet(:,2), corr_inlierSet(:,1),...
                                    inlierSet(:,2), inlierSet(:,1));

        
        
    end

    disp(iterRANSAC);
    
end

inlier_ind = bestInliers_id;


end