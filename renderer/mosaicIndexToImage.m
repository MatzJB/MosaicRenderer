%mosaicIndexToImage(modelsDir, frameFormat, indices, offset, palette, gray)
%
%  mosaicIndexToImage takes the index matrix of a mosaic along with an
%  <offset> and a <palette> and returns the mosaic matrix. If <gray> is set to
%  true, the mosaic will be gray scale.
%
%  If frames from a movie is used as mosels and a movie sequence is to be
%  shown, an optimization is to only collect a subset of mosels but still
%  step in the frames of the movie at 30FPS. The benefit is that not all
%  frames are used in the palette which will speed up the render process.

function mosaic = mosaicIndexToImage(moselsDir, frameFormat, indices, offset, palette, gray, rescale)
%add rescale option, think about cropping without scaling

if gray, palette = paletteToGray(palette); end

[ri, ci, ~] = size(indices);
[rp, cp, ~] = size(palette(1).data);
rMosaic = ri*rp;
cMosaic = ci*cp;
mosaic = zeros(rMosaic, cMosaic, 3);
mosDim = size(palette(1).data);
paletteLength = length(palette);

for y = 1:mosDim(1):rMosaic
    for x = 1:mosDim(2):cMosaic
        iIndex = ceil( y/mosDim(1) );
        jIndex = ceil( x/mosDim(2) );
        ind = indices(iIndex, jIndex);

        if offset~=1  % read frame using name of sample
            moselName = palette(ind).name;
            nameParts = strsplit(moselName, '_');
            frame = strsplit(nameParts{2}, '.');
            frameId = offset + str2double(frame{1});
            frameId = 1 + mod(frameId,paletteLength); %cycling frame
            str = sprintf(frameFormat, frameId);
            newMoselName = [moselsDir, nameParts{1}, '_', str, '.jpg'];
            im = imread(newMoselName);
            tile = rescaleAndCrop(im, [rp, cp]);
        else
            tile = palette(ind).data;
        end
        
        if gray
            tile = rgb2gray(tile);
            tile = cat(3, tile, tile, tile);
        end
                
        mosaic((iIndex-1)*mosDim(1)+1:(iIndex)*mosDim(1), ...
                (jIndex-1)*mosDim(2)+1:(jIndex)*mosDim(2), :) = tile;
    end
end

