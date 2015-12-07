function [ match_results] = feat_match( i1_desc, i2_desc )
% performs feature matching 
% returns the probable match of each feature of i1 with some featue of i2

% initalise the match_results
match_results = -1*ones(length(i1_desc),2);
desc_range = (1:length(i1_desc));
match_results(:,1) = desc_range';

% compute distance between one point with all the other points
distance_metric = pdist2(i1_desc, i2_desc);
distance_metric =distance_metric.^2;

% find the closest match
[sorted_dist_mat, sorted_id] = sort(distance_metric,2);

% check for confidence
confidence = sorted_dist_mat(:,1)./sorted_dist_mat(:,2);
confident_idx = find(confidence < 0.5);

% 
match_results(confident_idx,2) = sorted_id(confident_idx,1);
match_results = match_results(:,2);

%% check the reverse
% 
% distance_metric_rev = pdist2(i2_desc, i1_desc);
% distance_metric_rev = distance_metric_rev.^2;
% 
% [sorted_dist_mat_rev, sorted_id_rev] = sort(distance_metric_rev,2);
% 
% confidence_rev = sorted_dist_mat_rev(:,1)./sorted_dist_mat_rev(:,2);
% confident_idx_rev = find(confidence_rev < 0.5);
% 
% %
% desc_range_2 = (1:lenght(i2_desc));
% match_rev_results = -1.*ones(length(i2_desc),2);
% match_rev_results(:,1) = desc_range_2;
% 
% %
% match_rev_results(confident_idx_rev,2) = sorted_id_rev;

end

