function [Ic, T,binPath] = carv(I, nr, nc)
% I is the image being resized
% [nr, nc] is the numbers of rows and columns to remove.
% Ic is the resized image
% T is the transport map

[nx, ny, nz] = size(I);
T = zeros(nr+1, nc+1);
binPath = -1*ones(nr+1, nc+1);
TI = cell(nr+1, nc+1);
TI{1,1} = I;
% TI is a trace table for images. TI{r+1,c+1} records the image removed r rows and c columns.

%% Add your code here

% fill the T-matrix

for iterR = 1:nr+1    

    
    for iterC = 1 : nc+1
        
        
        % calculate the image equivalents 
        % if we remove a vertical seam        
        if (iterR == 1 && iterC ==1 )
            continue;
        end
        
        % Calculate costs
        if (iterR ~= 1)
            [if_rmH,cost_rmH] = removeSeam(TI{iterR-1,iterC},'rH');
            TI{iterR ,iterC } = if_rmH;
        else
            cost_rmH = Inf;
        end
        
        if (iterC ~= 1)
            [if_rmV,cost_rmV] = removeSeam(TI{iterR,iterC-1},'rV');
            % store the images in the traceback 
            TI{iterR,iterC } = if_rmV;
        else
            cost_rmV = Inf;
        end
        
        % getting to this cell is the minimun of T(r-1) ..+ T(c-1)        
        prevR = iterR -1 ;
        prevC = iterC -1;
        if (iterR == 1)
               prevR = 1;        
        end
        if (iterC == 1)
            prevC =1;
        end
        
        
        % store the energy values
        [T(iterR,iterC),pos] = min([T(iterR,prevC)+ cost_rmV, 
                              T(prevR,iterC)+ cost_rmH]);
        
                          
        % udpate the path chosen
        if (pos == 1)            
            binPath(iterR,iterC) = 1;
        else
            binPath(iterR,iterC) = 0;
        end
        
        
        
       
        
    end
    
    
    
    
end

%% final result
Ic = TI{nr+1,nc+1};

end