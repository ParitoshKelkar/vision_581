[n,~] = size(country);
for i = 1 : n
    
    tempStr = cell2mat(country{i});
    if (strCmp(tempStr,'United States'))
        pos = [pos i] ;
    end
    
end