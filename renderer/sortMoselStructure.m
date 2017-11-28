%sortMoselStructure(moselStruct, useMean)
%
%  sortMoselStructure takes a mosaic element structure and sorts the
%  elements with respect to overall color either using the mean <useMean>
%  or using the samplespace from fully white to black.

function moselStructureSorted = sortMoselStructure(moselStruct, useMean)
moselStructureSorted = moselStruct;

if useMean % using the mean value of the samples, seems to produce poor sorting
    [r, ~] = size(moselStruct.palette);
    tmp = zeros(r, 3);

    %fix this!!!
    size(moselStruct.palette(1))
    
    for i = 1:r
        i
        tmp(i, :) = moselStruct.palette(i).mean;
    end
else
    % using the RGB samples and taking the mean (should be the same as
    % above, but provide a better sorting of uniformly colored mosels)
    
    nSamples = moselStruct.nSamples;
    [r, ~] = size(moselStruct.sampleSpace);
    cols = zeros(r, 3);
    
    for i = 1:r
        tmp(i, :) = mean(reshape(moselStruct.sampleSpace(i,:),...
            nSamples^2, 3), 1);
    end
end

cols = tmp;
cols2 = rgb2hsv(cols/255);
[~, ind] = sortrows(cols2, [-1 -3 2]);

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
