%retrieveSamples returns the samples of <img> using nSamples (nSamples^2 in total)

%todo: use number of total samples as a measurement instead, in the case
%that the mosaees are elongated
%todo: clean up this code
function [samples, coordinates] = retrieveSamples(img, nSamples)
[y_dim,x_dim,~] = size(img);

yc = linspace(1, y_dim, nSamples);
xc = linspace(1, x_dim, nSamples);
samples = zeros(nSamples^2, 3);
coordinates = zeros(nSamples^2, 2);

i_sample = 1;
for x=xc
    for y=yc
        xi = floor(x);
        yi = floor(y);
        tmp = img(yi,xi,:);
        samples(i_sample,:) = tmp;
        coordinates(i_sample,1:2) = [yi,xi];
        i_sample=i_sample+1;
    end
end

end