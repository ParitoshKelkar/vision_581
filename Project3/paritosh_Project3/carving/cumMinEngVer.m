function [Mx, Tbx] = cumMinEngVer(e)
% e is the energy map.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.

[nx,ny] = size(e);
Mx = zeros(nx, ny);
Tbx = zeros(nx, ny);
Mx(1,:) = e(1,:);

%% Add your code here

% do it normally
for rowIter = 2 : nx   
    
    % get indecies
    rowElement_idx = sub2ind([nx, ny], repmat(rowIter,ny,1),...
                    (1:ny)');
    
    % create LUT for referencing 
    backTrack_LUT = zeros(ny,3);    
    backTrack_LUT(:,1) = rowElement_idx - nx -1;
    backTrack_LUT(:,2) = rowElement_idx -1;
    backTrack_LUT(:,3) = rowElement_idx + nx -1;    
    
    % check for inconsistensies w.r.t dimensions
    find_out = find(backTrack_LUT < 1 | backTrack_LUT > nx*ny);
    backTrack_LUT(find_out) = 1;

    % substitute the energy values
    backTrack_LUT(:,1) = Mx(backTrack_LUT(:,1));
    backTrack_LUT(:,2) = Mx(backTrack_LUT(:,2));
    backTrack_LUT(:,3) = Mx(backTrack_LUT(:,3));
    
    % replace the inconsistensies
    backTrack_LUT(find_out) = NaN;
    
    % take the minima of all points
    [min_values,min_positions] = min(backTrack_LUT,[],2);    
    
    % put corresponding values in Tbx    
    Tbx(rowIter,:) = min_positions';
    
    % put corresponding values in Mbx
    Mx(rowIter,:)  = min_values' + e(rowIter,:);       
    
    
end


end