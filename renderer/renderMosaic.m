%renderMosaic(rMosaic, image_palette, sample_space, mosaicName, [constants])
%
%  renderMosaic renders a given image <mosaicName> at a specified height
%  <rMosaic> (in pixels). The mosaic elements used must be calculated by
%  collectMosaicData (resulting in <image_palette>, <sample_space>).
%
%  Optional arguments: cell of constants containing elements:
%       plot     - unused
%       stats    - printing statistics while rendering (default: false)
%       debug    - showing debug prints and lines in render (default: false)
%       speedup  - using speedier code. (default: true)
%       useColors - when false, renderer ignores colors for all samples and mosaees
%       (default: true)
%       nPrgrs   - number of progress printouts used during the course of
%       the render (default: 10)

function [mosaic, mosaicIndexed, mosaicMean] = renderMosaic(rMosaic, moselStruct, mosaicName, varargin)

warning('off', 'images:initSize:adjustingMag');

mosaic = [];
mosaicIndexed = [];
palette = moselStruct.palette;
nSamples = moselStruct.nSamples;

%default constants:
const = {};
const.plot = false;
const.render = true;
const.stats = true;
const.debug = false;
const.speedup = true;
const.useColors = false;
const.nPrgrs = 10;

if nargin==4 % override defaults with constants
    try
        argconst = varargin{1};
        const.plot = argconst.plot;
        const.render = argconst.render;
        const.stats  = argconst.stats;
        const.debug = argconst.debug;
        const.useColors = argconst.useColors;
        const.speedup = argconst.speedup;
    catch
        warning('some variables were not defined by optional argument')
    end
end

if const.stats
    fprintf(1, 'speedup: %d\n', const.speedup);
end

try
    mosaee = imread(mosaicName);
catch Exception
    fprintf(1, 'Couldn''t find image file ''%s''\n', mosaicName);
    return
end

[r, c, d] = size(mosaee); % the image to be 'mosaiced'
if d==1, mosaee = cat(3, mosaee, mosaee, mosaee); end % support gray image
ratio = c/r; % we use the ratio of the mosaic image when we create the mosels

% specify the height of resulting mosaic (pixels) must be a multiple of
% the mosels size

[rMosel, cMosel, ~] = size(palette(1).data);
cMosaic  = ratio*rMosaic;
cMosaic = ceil(cMosaic/cMosel)*cMosel+1;
rMosaic = ceil(rMosaic/rMosel)*rMosel+1;

imMosaic = imresize(mosaee, [rMosaic, cMosaic]);
rIndex = ceil(rMosaic/rMosel)-1;
cIndex = ceil(cMosaic/cMosel)-1;
mosaicIndexed = zeros(rIndex, cIndex, 'single');

imMosaic = single(imMosaic);
mosaic = single(imMosaic);
mosaicMean = mosaic; % each mosic is the average color of the samples (for comparison)

if const.render
    figure
    h = imshow(mosaic/255.0);
    title('Mosaic (render)')
    drawnow
    set(gcf, 'renderer', 'opengl')
    hold on
end

ii = 0;
jj = 0;

% pick out B/W and RGB samples patterns
indsRGB = moselStruct.samplePatternRGB;
indsBW = moselStruct.samplePatternBW;
%[inds, coordinates] = getSamplePattern([rMosel,cMosel], nSamples);
%indsRGB = []; for i=0:2; indsRGB = [indsRGB, inds+rMosel*cMosel*i]; end
%indsBW = inds;

tRender = tic;

for y = 1:rMosel:rMosaic-rMosel % - rMosel, update
    for x = 1:cMosel:cMosaic-cMosel% - cMosel
        % used to place samples in mosaic
        yStart = ceil( y/rMosel );
        xStart = ceil( x/cMosel );
        tmpTile = retrieveTile(imMosaic, [y, x], [rMosel, cMosel]);
        
        if const.debug
            line([x, x+cMosel, x+cMosel, x, x], [y, y, y+rMosel,...
                y+rMosel, y], 'color', 'r')
        end
        
        sourceSamples = tmpTile(indsRGB);
        
        if const.speedup
            if const.useColors
                sampleSpace = moselStruct.sampleSpace;
            else
                sampleSpace = moselStruct.sampleSpaceBW;
            end
            
            sourceVector = reshape(sourceSamples', 1, numel(sourceSamples));
            iBest = dsearchn(sampleSpace, sourceVector);
        else
            dist_best = Inf;
            iBest = 1;
            % find the closest color in the palette
            if length(palette)==1
                error('Palette only has one mosel.')
            end
            
            for index = 1:length(palette)
                if const.useColors
                    candSamples = palette(index).samplesBW;
                else
                    candSamples = palette(index).samples;
                end
                
                dist = 0;
                for j = 1:size(sourceSamples, 1)
                    dist = dist + toneDistance(sourceSamples(j, :), ...
                        candSamples(j, :));
                end
                
                % pick this one if the distances are small
                if dist < dist_best
                    dist_best = dist;
                    iBest    = index;
                end
            end
        end
        
        %Place in mosaic matrix in steps of r_mosel and c_mosel
        %for each y that is scanned r_step at a time, we need to place a mosel in
        %that position
        tmp = palette(iBest).data;
        iIndex = ceil(y/rMosel);
        jIndex = ceil(x/cMosel);
        mosaicIndexed(iIndex, jIndex) = iBest;
        
        tmpMean = palette(iBest).mean;
        
        yRange = (yStart-1)*rMosel+1:(yStart)*rMosel;
        xRange = (xStart-1)*cMosel+1:(xStart)*cMosel;
        
        mosaicMean(yRange, xRange, 1) = tmpMean(1);
        mosaicMean(yRange, xRange, 2) = tmpMean(2);
        mosaicMean(yRange, xRange, 3) = tmpMean(3);
        
        try
            
            mosaic(yRange, xRange, :) = tmp;
        catch exception
            size(tmp)
            warning('Possible solution: reinit palette')
            rethrow(exception)
        end
        ii = ii + 1;
    end
    
    jj = jj + 1;
    averageTime = toc(tRender)/ii;
    
    if mod(jj, 7)==0 % Warning: very slow
        if const.render
            set(h, 'cdata', mosaic/255)
            drawnow
        end
    end
    
    if const.stats && mod(ii, round( rMosel/const.nPrgrs ))==1
        fprintf(1, 'Average speed: %d s/mosel\n', averageTime);
        toc(tRender)
        fprintf(1, '  Finished: %d%%\n', ceil(100*y/(rMosaic-rMosel)));
        ETA = max(1, floor(averageTime*(rMosaic/rMosel*cMosaic/cMosel - ii)));
        fprintf(1, 'ETA: %d s\n', ETA);
    end
end

if const.render
    mosaic = mosaic/255;
    set(h, 'cdata', mosaic)
    drawnow
end

% statistics of render routine
if const.stats
    averageTime = toc(tRender) / (numel(sourceSamples) * numel(mosaicIndexed));
    fprintf(1, '\n\n average time per sample:%f\n\n', averageTime);
end

toc(tRender)

