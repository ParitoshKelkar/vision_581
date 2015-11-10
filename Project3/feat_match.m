function [ match_results] = feat_match( i1_desc, i2_desc )
% performs feature matching 
% returns the probable match of each feature of i1 with some featue of i2

% initalise the match_results
match_results = -1*ones(length(i1_desc),2);
desc_range = (1:length(i1_desc));
match_results(:,1) = desc_range';

% compute distance between one point with all the other points
distance_metric = pdist2(i1_desc, i2_desc);

% find the closest match
[sorted_dist_mat, sorted_id] = sort(distance_metric,2);

% check for confidence
confidence = sorted_dist_mat(:,1)./sorted_dist_mat(:,2);
confident_idx = find(confidence < 0.7);

% 
match_results(confident_idx,2) = sorted_id(confident_idx,1);
match_results = match_results(:,2);


end

