%%  This script is mainly for testing the idxing 

angles = randi([0,80],[3,4]);
Q = 1 + floor(angles./20);
R = 1- rem(angles,20)./20;
mag = randi([1,10],[3,4]);
votedMag = mag.*R;


storage = zeros(3,4,4);

Q_idx = reshape((1:3*4),[3,4]);
Q_idx_linear = reshape(Q_idx,[3*4,1]);

% apply the fomrula to generate the corresponding storage idx
[Qr,Qc] = ind2sub([3,4], Q_idx_linear);
storage_Q_idx = 4*3.*(Qc-1) + Qr + 3.*(reshape(Q,[3*4,1]) - 1);

storage(storage_Q_idx) = reshape(votedMag,[3*4,1]);
