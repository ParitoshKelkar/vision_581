function mat = customReshape(in_mat)

global CELL_SIZE;
[numR, numC] = size(in_mat);

C = mat2cell(im_id_template,[repmat(CELL_SIZE,numR/CELL_SIZE,1)],...
                                   [repmat(CELL_SIZE, numR/CELL_SIZE,1)]);
cellIds = cell2mat(reshape(C,[numR/CELL_SIZE*numC/CELL_SIZE,1]));



end