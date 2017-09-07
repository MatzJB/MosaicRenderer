
%Get the sub matrix
function im = retrieveTile(im, start, size_)

im = im(start(1):start(1) + size_(1), start(2):start(2) + size_(2), :);

