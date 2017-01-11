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
%       nocolors - the renderer ignores colors for all samples and mosaees
%       (default: false)
%       nPrgrs   - number of progress printouts used during the course of
%       the render (default: 10)


function [mosaic, mosaicIndexed, mosaicMean] = renderMosaic(rMosaic, palette, sample_space, mosaicName, varargin)

warning('off', 'images:initSize:adjustingMag');

mosaic = [];
mosaicIndexed = [];

tmp          = size( palette(1).samples ); % must match samples
nSamples     = sqrt(tmp(1));

const = {};
const.plot   = false;
const.render = true;
const.stats   = true;
const.debug  = false;
const.speedup  = true;
const.nocolors  = false; %if true then ignore colors
const.nPrgrs = 10;

if nargin==5 % override defaults with constants
    try
        argconst       = varargin{1};
        const.plot   = argconst.plot;
        const.render = argconst.render;
        const.stats  = argconst.stats;
        const.debug  = argconst.debug;
        const.nocolors  = argconst.nocolors;
    catch
        %error('all optional variables has to be defined')
    end
end

if const.nocolors
    fprintf(1, 'converting samples to grayscale...\n');
    %vector containing [R,G,B,R,G,B,...]

palette = paletteToGray(palette);
end

try
    mosaee = imread(mosaicName);
catch Exception
    fprintf(1, 'Couldn''t find image file ''%s''\n', mosaicName);
    return
end

[r, c, d] = size(mosaee); % the image to be 'mosaiced'
 
% gray image
if d==1, mosaee = cat(3, mosaee, mosaee, mosaee); end

ratio = c/r;
% we use the ratio of the mosaic image when we create the mosels

% specify the height of resulting mosaic (pixels)
cMosaic  = ratio*rMosaic;
imMosaic = imresize(mosaee, [rMosaic, cMosaic]);

mosDim = size(palette(1).data);
rIndex = ceil(r/mosDim(1));
cIndex = ceil(c/mosDim(2));

mosaicIndexed = zeros(rIndex, cIndex, 'single');

if prod(mosDim)*4/2^20 > 200
    fprintf(1, 'The program is about to create a large matrix, press Enter to continue\n');
    fprintf(1, 'Estimated size of the mosaic: %f MB\n', mosDim(1)*mosDim(2)*4/2^20);
    pause
end

% todo: clean up
mosaicSize(1) = ceil(r/mosDim(1)) * mosDim(1);
mosaicSize(2) = ceil(c/mosDim(2)) * mosDim(2);

imMosaic = single(imMosaic);
mosaic = single(imMosaic);
mosaicMean = mosaic; % each mosic is the average color of the samples (for comparison)

figure;
h = imshow(mosaic/255);
title('Mosaic (render)')
drawnow

set(gcf, 'renderer', 'opengl')
ii = 0;
%tt = 0; % used for controlling printouts
hold on

tRender = tic;
for y = 1:mosDim(1):rMosaic - mosDim(1)
    for x = 1:mosDim(2):cMosaic - mosDim(2) % c_mosaic-c_step
        % used to place samples in mosaic
        yStart = round( y/mosDim(1) );
        xStart = round( x/mosDim(2) );
        % source_samples = retrieveSamples(im_mosaic(y:y + r_step, x:x + c_step, :), n_samples);
        try
            tmp_tile = retrieveTile(imMosaic, [y, x], [mosDim(1), mosDim(2)]);
        catch Exception
            fprintf(1, 'Found errors: (x, y) = (%d, %d)\n', x, y);
        end
        
        if const.debug
            line([x, x+mosDim(2), x+mosDim(2), x, x], [y, y, y+mosDim(1), y+mosDim(1), y], 'color', 'r')
        end
        
        [source_samples, ~] = retrieveSamples(tmp_tile, nSamples);
        
        if const.speedup
            source_vector = reshape(source_samples', 1, numel(source_samples));
            i_best = dsearchn(sample_space, source_vector);
        else
            dist_best = Inf;
            i_best = 1;
            % find the closest color in the palette
            if length(palette)==1
                error('Palette only has one mosel.')
            end
            
            for i = 1:length(palette)
                % im_tmp = image_palette(i).data;
                cand_samples = palette(i).samples;
                dist = 0;
                for j = 1:size(source_samples, 1)
                    dist = dist + ( tone_distance(source_samples(j, :), cand_samples(j, :)) );
                end
                
                % pick this one if the distances are small
                if dist < dist_best
                    dist_best = dist;
                    i_best    = i;
                end
            end
        end
        
        %Place in mosaic matrix in steps of r_mosel and c_mosel
        %for each y that is scanned r_step at a time, we need to place a mosel in
        %that position
        tmp = palette(i_best).data;
        iIndex = ceil(y/mosDim(1));
        jIndex = ceil(x/mosDim(2));
        mosaicIndexed(iIndex, jIndex) = i_best;
        tmpMean = palette(i_best).mean;
        %todo: clean up
        mosaicMean(yStart*mosDim(1)+1:(yStart+1)*mosDim(1), xStart*mosDim(2)+1:(xStart+1)*mosDim(2), 1) = tmpMean(1);
        mosaicMean(yStart*mosDim(1)+1:(yStart+1)*mosDim(1), xStart*mosDim(2)+1:(xStart+1)*mosDim(2), 2) = tmpMean(2);
        mosaicMean(yStart*mosDim(1)+1:(yStart+1)*mosDim(1), xStart*mosDim(2)+1:(xStart+1)*mosDim(2), 3) = tmpMean(3);
                
        try
            mosaic(yStart*mosDim(1)+1:(yStart+1)*mosDim(1), xStart*mosDim(2)+1:(xStart+1)*mosDim(2), :) = tmp;
        catch exception
            size(tmp)
            warning('Possible solution: reinit palette')
            rethrow(exception)
        end
        ii = ii + 1;
    end
    
    % very slow
    if const.render
        set(h, 'cdata', mosaic/255)
        drawnow
    end
    
    average_time = toc(tRender)/ii;
    
    %todo: check this
    if const.stats && mod(ii, round( mosDim(1)/const.nPrgrs ))==1
        %if const.stats && mod(tt, 15) == 0
        fprintf(1, 'Average speed: %d s/mosel\n', average_time);
        %fprintf(1, 'Finished: %d%%\n', ceil(100*y/(r_mosaic-r_step)))
        toc(tRender)
        fprintf(1, '  Finished: %d%%\n', ceil(100*y/(rMosaic-mosDim(1))));
        ETA = max(1, floor(average_time*(rMosaic/mosDim(1)*cMosaic/mosDim(2) - ii)));
        fprintf(1, 'ETA: %d s\n', ETA);
    end
end

if const.render
    set(h, 'cdata', mosaic/255)
    drawnow
end

toc(tRender)
mosaic = mosaic/255; %normalize result

%todo: for debugging, will be introduced later, probably
%{

  else %solid mosels at each sample
                
                %source_samples = retrieve_samples(retrieve_tile(im_mosaic, [y, x], [r_step, c_step]), n_samples);
                tmp = 0*image_palette(1).data;
                
                for gg = 1:length(source_samples)
                    tmp(source_coords(gg, 1), source_coords(gg, 2), :) = [255, 0, 0]; %source_samples(gg,:);
                end
                
                tmp(1, 1, 2) = 255; %corner
                tmp(end, end, 3)=255; %corner
                
                mosaic(yStart*mosDim(1)+1:(yStart+1)*mosDim(1)+1, xStart*mosDim(2)+1:(xStart+1)*mosDim(2)+1, :) = tmp;
                %mosaic(y_start*r_mosel+1:(y_start+1)*r_mosel, x_start*c_mosel+1:(x_start+1)*c_mosel, :) = tmp;
                %set(h, 'cdata', im_mosaic)
            end %solid_mosels
%}
