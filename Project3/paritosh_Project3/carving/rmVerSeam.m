function [Ix, E, rmIdx] = rmVerSeam(I, Mx, Tbx)
% I is the image. Note that I could be color or grayscale image.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.
% Ix is the image removed one column.
% E is the cost of seam removal

[nx, ny, nz] = size(I);
rmIdx = zeros(nx, 1);
Ix = uint8(zeros(nx, ny-1, nz));

%% Add your code here

[~, seedPoint] = min(Mx(end,:));
rmIdx(nx) = sub2ind([nx ny],nx,seedPoint);
[~,delC] = ind2sub([nx ny],rmIdx(nx));
Ix(nx,:,:) = [I(nx,1:delC-1,:),I(nx,delC+1:ny,:)];
% create idx LUT
allIdx = 1 : nx*ny;
idx_LUT = zeros(nx*ny,3);
idx_LUT(:,1) = allIdx - nx - 1;
idx_LUT(:,2) = allIdx - 1;
idx_LUT(:,3) = allIdx + nx - 1;

% do the greedy traceBack
for iterTrace = nx : -1 : 2     
    
    % trace the ids
    grid_id = rmIdx(iterTrace);    
    rmIdx(iterTrace-1) = idx_LUT(grid_id,Tbx(grid_id));
    
    % remove those particular pixels
    % shift everything to the right    
    [~,delC] = ind2sub([nx,ny],rmIdx(iterTrace));
    if (delC -1 < 1)
        delC = 2 ;
    elseif (delC + 1 > ny)
        delC = ny-1;
    end
      
    Ix(iterTrace-1,:,:) = [I(iterTrace-1,1:delC-1,:),I(iterTrace-1,delC+1:ny,:)];

    
end

e = genEngMap(I);
E = sum(e(rmIdx));

end