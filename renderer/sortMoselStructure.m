%sortMoselStructure(moselStruct, useMean)
%
%  sortMoselStructure takes a mosaic element structure and sorts the
%  elements with respect to overall color either using the mean <useMean>
%  or using the samplespace from fully white to black.

function moselStructureSorted = sortMoselStructure(moselStruct, useMean)
moselStructureSorted = moselStruct;

if useMean % using the mean value of the samples
    [~, len] = size(moselStruct.palette);
    tmp = zeros(len,1,3);
    for i = 1:len
        tmp(i, 1, :) = moselStruct.palette(i).mean;
    end
    
    %RGB to index: R*255 + G*255^2 + B*255^3 <-[0,16581375]
    cols = tmp(:, 1, 1)*255 +...
        tmp(:, 1, 2)*255^2 +...
        tmp(:, 1, 3)*255^3;
    [~, ind] = sort(cols);
else % using the samples
    nSamples = moselStruct.nSamples;
    [r, ~] = size(moselStruct.sampleSpace);
    cols = zeros(r, 3);
    
    for i = 1:r
        cols(i, :) = mean(reshape(moselStruct.sampleSpace(i,:),...
            nSamples^2, 3), 1);
    end
    
    cols = cols(:, 1)*255 + cols(:, 2)*255*255 + cols(:, 3)*255*255*255;
    [~, ind] = sort(cols);
end

if all( sort(ind)==ind )
    warning('palette is already sorted')
    return
end

% rearrange into sorted order
for i = length(moselStruct.palette):-1:1
    index = ind(i);
    moselStructureSorted.palette(i) = moselStruct.palette(index);
    moselStructureSorted.sampleSpace(i, :) = moselStruct.sampleSpace(index, :);
    moselStructureSorted.sampleSpaceBW(i, :) = moselStruct.sampleSpaceBW(index, :);
end

