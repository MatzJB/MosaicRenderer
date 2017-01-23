% getSamplePattern returns the sample pattern of M-by-N matrix <im> and
% the coordinates, using <nSamples> (nSamples^2 in total)
% The pattern is a M-by-1 matrix consisting of indices into <im>.

function [inds, coordinates] = getSamplePattern(dims, nSamples)
r = dims(1);
c = dims(2);
yc = linspace(1, r, nSamples);
xc = linspace(1, c, nSamples);
coordinates = zeros(nSamples^2, 2);
% note: make sure the patterns are unique
i_sample = 1;

for x = xc
    for y = yc
        xi = floor(x);
        yi = floor(y);
        coordinates(i_sample, 1:2) = [yi, xi];
        i_sample = i_sample+1;
    end
end

inds = sub2ind([r,c], coordinates(:,1), coordinates(:,2), ones(length(coordinates(:,1)), 1));
inds = unique(inds); %filter out conflicting samples