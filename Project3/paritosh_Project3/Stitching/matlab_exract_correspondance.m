%% MATLAB detect features

I1 = rgb2gray(imread('ex1.jpg'));
I2 = rgb2gray(imread('ex2.jpg'));

points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);

[features1, valid_points1] = extractFeatures(I1, points1);
[features2, valid_points2] = extractFeatures(I2, points2);


indexPairs = matchFeatures(features1, features2);

matchedPoints1 = valid_points1(indexPairs(:, 1), :);
matchedPoints2 = valid_points2(indexPairs(:, 2), :);

%figure; showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2,'montage');

%%

show_ANMS = 1;
visualizeRANSAC = 0;
visualizeResult = 0;
visualizeHomography = 0;


%% assign the nomenclature
source_pts = fliplr(matchedPoints1.Location);
dest_pts = fliplr(matchedPoints2.Location);

%% RANSAC to get rid of false positives

% ransac param
list = (1: size(source_pts,1));
maxNumInliers = 0;
lineCheck = 1;
margin = 20; 
%say that the max number of iterations that we will need = 100
maxIter = 100;

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

    
    % visualize the points of RANSAC - verify matched points     
    if (visualizeRANSAC) 
        
        showMatchedFeatures(I1, I2,fliplr(current_source), fliplr(current_dest),...
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
        bestH_post = est_homography(dest_pts(:,2), dest_pts(:,1),...
                                    inlierSet(:,2), inlierSet(:,1));

        
        
    end

    disp(iterRANSAC);
    
end