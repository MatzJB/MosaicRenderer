
%applyBlurFilter convolves <img> using <kernel>
%todo: change name of function
function im = applyBlurFilter(im, kernel)

if size(kernel,3)~=1
    error('kernel must be a 2d matrix')
end

for i=1:2
    if size(im,i)~=size(kernel,i)
        error(['args mismatching dimension, dim=', str(i)])
    end
end

for i=1:size(im,3)
    im(:, :, i) = conv2(im(:, :, i), kernel, 'same'); %same valid
end
