%rescaleAndCrop resacales <image> using <dim>

function z = rescaleAndCrop(im, dim)
[r, c, ~] = size(im);
[val, ~] = max(dim./[r, c]);
z = imresize(im, val);
z = z(1:dim(1), 1:dim(2), :);
end
