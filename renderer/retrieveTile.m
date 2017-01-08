
%Get the sub matrix
function im = retrieve_tile(im, start, size)
im = im(start(1):start(1) + size(1), start(2):start(2) + size(2), :);

