function [ c, r, rad ] = anms( C_mag, NUM_PTS_REQD )

% Returns the anms points
global numR;
global numC;
global I;

    C_mag(C_mag < 0.1.*max(C_mag(:))) = 0;
    C = imregionalmax(C_mag);
    
    if ( NUM_PTS_REQD > length(find(C))) 
        NUM_PTS_REQD = length(find(C));
    end
    
    % not sure how to set the corner threshold
    % taking all the points for now
    potCorners_idx = find(C);
    potCorners_mag = C_mag(potCorners_idx);

    % init radius tracker aray
    radius_tracker = -1.*ones(length(potCorners_idx),2);
    radius_tracker(:,1) = potCorners_idx;

    % stupid for loop for ANMS
    for iterANMS  = 1 : length(potCorners_idx)

        current_idx = potCorners_idx(iterANMS);
        current_idx_mag = C_mag(current_idx);

        % subtract this from the list of all the other values 
        diff_ = current_idx_mag./potCorners_mag;

        % take those points that satisy the `robustify' criteria
        robust_idx = potCorners_idx(abs(diff_) <= 0.9);
        if (isempty(robust_idx))
            if (current_idx_mag == max(potCorners_mag))
                radius_tracker(iterANMS,:) = [current_idx, Inf];            
%             else
%                 radius_tracker(iterANMS,:) = [current_idx, Inf];            
            end
            continue;
        end
        
        % with each of these points, calculate the distance from current_idx 
        [robust_cartesianR, robust_cartesianC] = ind2sub([numR, numC], robust_idx);
        [current_cartesian(:,1), current_cartesian(:,2)] = ind2sub([numR, numC], current_idx);    
        robust_cartesian = [robust_cartesianR robust_cartesianC];
        dist_measure = pdist2(current_cartesian,robust_cartesian);
        sorted_dist_measure = sort(dist_measure); 

        % fill in radius_tracker
        radius_tracker(iterANMS,:) = [current_idx, sorted_dist_measure(1)]; 
        
        %disp(iterANMS);


    end

    % take the top NUM_PTS_REQD from the radius_tracker
    [sorted_radius,idx_track] = sort(radius_tracker(:,2), 'DESCEND');

    % filteredPts 
    anms_op  = potCorners_idx(idx_track(1:NUM_PTS_REQD));
    
    % convert to cartesian
    [r,c] = ind2sub([numR, numC], anms_op);
    
    % radius at which result was obtained
    rad = sorted_radius(NUM_PTS_REQD);
    
    
    
    
    
    % just do harris for now
%     RC = corner(rgb2gray(I));
%     r = RC(:,1);
%     c = RC(:,2);

end

