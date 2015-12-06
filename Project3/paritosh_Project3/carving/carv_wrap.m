function [Ic, T, Mx, My, Ix, Iy, Ex, Ey] = carv_wrap(I, nr, nc, flag)
% I is the image of nx-by-ny matrix.
% nr is the numbers of rows to be removed from the image.
% nc is the numbers of columns to be removed from the image.

Ic = 0; T = 0;
Mx = 0; Ix = 0; Ex = 0;
My = 0; Iy = 0; Ey = 0;

eV = genEngMap(I);
% x refers to columns, y refers to rows.
[Mx, Tbx] = cumMinEngVer(eV);
[Ix, Ex] = rmVerSeam(I, Mx, Tbx);

IT = rot90(I,3);
eH = genEngMap(IT);
[My, Tby] = cumMinEngHor(eH);
[Iy, Ey] = rmHorSeam(IT, My, Tby);

[Ic, T] = carv(I, nr, nc);

end