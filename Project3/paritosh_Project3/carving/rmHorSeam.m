function [Iy, Ey, rmIdy] = rmHorSeam(I, My, Tby)
% I is the image. Note that I could be color or grayscale image.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.
% Iy is the image removed one row.
% E is the cost of seam removal

[nx, ny, nz] = size(I);
rmIdx = zeros(1, ny);
Iy = uint8(zeros(nx-1, ny, nz));

%% Add your code here

[Iy,Ey,rmIdy] =  rmVerSeam(I,My,Tby);

Iy = rot90(Iy,1);


end