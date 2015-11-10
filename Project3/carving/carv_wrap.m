function [Ic, T, Mx, My, Ix, Iy, Ex, Ey] = carv_wrap(I, nr, nc)
% I is the image of nx-by-ny matrix.
% nr is the numbers of rows to be removed from the image.
% nc is the numbers of columns to be removed from the image.

Ic = 0; T = 0;
Mx = 0; Ix = 0; Ex = 0;
My = 0; Iy = 0; Ey = 0;

e = genEngMap(I);
% x refers to columns, y refers to rows.
[Mx, Tbx] = cumMinEngVer(e);
[My, Tby] = cumMinEngHor(e);
[Ix, Ex] = rmVerSeam(I, Mx, Tbx);
[Iy, Ey] = rmHorSeam(I, My, Tby);

[Ic, T] = carv(I, nr, nc);

end