function [a1, ax, ay, w] = est_tps(ctr_pts, target_value)

% the ctr_pts are the intermediate control points
% and the target values are the control points in source imagers(original)

% xi, yi will refer to imageB
% v = f(xi, yi) and v is the target 

% calculate the dist_mat
dist_mat  = pdist2(ctr_pts,ctr_pts);

% apply the function U = -r^2.log(r)^2
K = (dist_mat.^2).*log(dist_mat.^2);
K(isnan(K)) = 0;

% create matrix P (xi, yi, 1)
P = [ctr_pts ones(size(target_value,1),1)];

% for the x_cooridnates
coeff_ = ([K P; P' zeros(3,3)] + eps*eye(size(P,1)+3))\[target_value;[0 0 0]'];

% for the y_coordinates
%coeff_y = inv([K P; P' zeros(3,3)] + eps*eye(size(P,1)+3))*[target_value(:,2);[0 0 0]'];

% concatenate both the results in the form of [x,y]
a1 = coeff_(end);
ax = coeff_(end-2);
ay = coeff_(end-1);
w =  coeff_(1:end-3);


end