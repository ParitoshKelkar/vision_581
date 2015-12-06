function [ iRm,costRm ] = removeSeam( I_cell, method )
% This function asceratins the cost of removing one verSeam or horSeam


I = I_cell;

if strcmp(method,'rV')    
    
    e = genEngMap(I);

    % Generate the Mx and Tbx
    [Mx, Tbx] = cumMinEngVer(e);

    % get the ids of indecies that have to be removed
    [iRm,costRm,~] = rmVerSeam(I,Mx,Tbx);

    % visualise seam
    %[r,c] = ind2sub([size(I,1), size(I,2)], rmIdx);
    
else
    
    % transpose the image
    IT = rot90(I,3);   
    
    e = genEngMap(IT);

    % Generate the My and Tby
    [My, Tby] = cumMinEngVer(e);

    % get the ids of indecies that have to be removed
    [iRm,costRm,~] = rmVerSeam(IT,My,Tby);
    
    iRm = rot90(iRm,1);
    
    % visualise seam
    %[r,c] = ind2sub([size(IT,1), size(IT,2)], rmIdy);
    
    
    
    
    
end



end

