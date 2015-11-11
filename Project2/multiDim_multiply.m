A = 2;
B = 3;
C = 4;
D = 5;

X = rand(A,B,C);
Y = rand(B,D);

%# calculate result in one big matrix
Z = reshape(reshape(permute(X, [2 1 3]), [A B*C]), [B A*C])' * Y;

%'# split into third dimension
Z = permute(reshape(Z',[D A C]),[2 1 3]);