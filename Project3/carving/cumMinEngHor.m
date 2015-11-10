function [My, Tby] = cumMinEngHor(e)
% e is the energy map.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.

[nx,ny] = size(e);
My = zeros(nx, ny);
Tby = zeros(nx, ny);
My(:,1) = e(:,1);

%% Add your code here

% call the vertical functions with the transpose
[My,Tby] = cumMinEngVer(e);

% before getting the ids, flip the matrices?


end