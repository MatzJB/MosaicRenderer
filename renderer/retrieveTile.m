%Get the sub matrix of im, given start coordinate and the size of the submatrix size_
function im = retrieveTile(im, start, size_)

im = im(start(1):start(1) + size_(1), start(2):start(2) + size_(2), :);

