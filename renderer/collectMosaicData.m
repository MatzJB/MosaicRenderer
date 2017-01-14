%collectMosaicData(mosaicSize, moselsDir[[, nSamples], blurMosaee])
%
%  collectMosaicData is a function processing mosaic elements returning two
%  matrices: <palette> and <samples>. The function requires a image directory
%  <moselsDir> and size of processed mosels <mosaicSize> as a vector [height, width] specifying mosel size in pixels.
%
%  Optional arguments: nSamples - the number of samples in one dimension (total number of samples over mosel is simply nSamples^2)
%                      blurMosaee - if true the mosels are blurred using a
%                      gaussian filter, otherwise, no filter is used.

% todo: add option to control printouts
% todo: support really skipping mosels
function [palette, sample_space] = collectMosaicData(mosaicSize, moselsDir, varargin)

constants = {};
constants.stats = false;
constants.debug = false;
constants.blurMosels = false;
constants.nSamples = 10;
constants.skipMosel = 1;
constants.blurSigma = 0.5;
constants.nPrgrs    = 10;

if nargin==3 % override defaults with constants
    try
        argconst = varargin{1};
        constants.stats = argconst.stats;
        constants.debug = argconst.debug;
        constants.blurMosels = argconst.blurMosels;
        constants.nSamples = argconst.nSamples;
        constants.skipMosel = argconst.skipMosel;
        constants.blurSigma = argconst.blurSigma;
        constants.nPrgrs    = argconst.nPrgrs;
    catch
        warning('some variables were not defined by optional argumen')
    end
end

fprintf(1,'skip: %d\n', constants.skipMosel);

% Larger mosels require filtering to provide nice samples
mosaicSize  = round(mosaicSize);
% mosic element number of rows and columns (pixels)
rMosel   = mosaicSize(1);
cMosel   = mosaicSize(2);
ratMosel = cMosel/rMosel; %ratio

%todo: add HD mosel data handling
rMoselHD = 400; %experimental
cMoselHD = round(rMoselHD*ratMosel);





if constants.nSamples > rMosel || constants.nSamples > cMosel
    warning('Number of samples is larger than resolution of mosel')
end

% todo: remove speedup option
speedup    = 1; % optimized code

fprintf(1, 'Creating palette from %s...\n', pwd);

tmpPwd     = pwd;

%todo: we might wish to simply supply path to moselsDir instead of moving there
cd(moselsDir)
imagefiles = dir('*');
nFiles     = length(imagefiles);
fprintf(1, 'Reading, cropping and sampling %d mosels...\n', nFiles);

progPerc = linspace(0, 100, constants.nPrgrs);

iPrgs   = 1;

%todo: (otimization) bypass if no blurring is used
if constants.blurMosels
    blurKernel = single( fspecial('gaussian', [rMosel, cMosel], constants.blurSigma) );
else % bypassing blurring
    blurKernel = zeros(rMosel, cMosel);
    blurKernel(ceil(end*0.5), floor(end*0.5)+1) = 1;
end

debugRun = false; %flag to discern if we run debug print

nElement = ceil(nFiles/constants.skipMosel);
for i=1:nElement
    palette(1).data = zeros(rMosel, cMosel, 3);
end


i       = 1;
tPalette = tic;
for ii = 3:constants.skipMosel:nFiles % skip . and ..
    imname = imagefiles(ii).name;
    [pathstr, name, ext] = fileparts(imname);
    if ~strcmp(ext, '.jpeg') && ~strcmp(ext, '.jpg')
        continue
    end
    
    im = imread(imname);
    if size(im,3)~=3 %we only accept RGB images
        fprintf(1,'image %s not RGB, skipping\n', imname);
        continue
    end
    
    % rescale original image to fit the new "pixel size"
    imTmp = rescaleAndCrop(im, [rMosel, cMosel]); % scale image so we can see
    %todo: rescale to a close-to-original size and crop, save as HQ
    %imTmpHq = rescaleAndCrop(im, [rMoselHD, cMoselHD]); % scale image so we can see
    %imTmpHq = im; % rescaleAndCrop(im, scale*[rMosel, cMosel]); % HD version of mosels
    
    % todo: preallocate?
    palette(i).name = imname;
    moselBlurred = applyBlurFilter(single(imTmp), blurKernel);
    [tmp_samples, coords]    = retrieveSamples(moselBlurred,  constants.nSamples);
    palette(i).samples = tmp_samples;
    palette(i).data    = imTmp; % the image
    palette(i).mean    = mean(tmp_samples); % used for histogram
    
    if constants.debug && ~debugRun
        figure
        imagesc(imTmp)
        figure
        imagesc(moselBlurred/255)
        axis off
        hold on
        plot(coords(:, 2), coords(:, 1), 'rO')
        title('One Mosel, gaussian filtered with coordinates of the samples', 'fontsize', 12)
        pause(1)
        drawnow
        debugRun = true;
    end
    
    %{
    if i==1
        if unique(v, 'rows') ~= length(v) %9/7 2013
            warning('The sample resolution is too high and does not affect the quality. Tip: Increase r_step.')
        end
        
        if size(tile_samples, 1) ~= size(mosel_samples, 1)
            error('The number of samples for a Mosel differs from a Tile. Tip: Modify n_samples and r_step.')
        end
    end
    %}
    %image_palette2(i).largedata = imTmpHq; %higher resolution version of the mosaic element
    
    % printouts
    if mod(i, round(nFiles/constants.nPrgrs))==0
        fprintf(1, '%d...', round(progPerc(iPrgs)));
        iPrgs = iPrgs+1;
    end
    i = i+1;
end

fprintf(1, '100.\n');
toc(tPalette)
fprintf(1, 'Found %d mosaics\n', i);

%todo: add code below

tic
%{
cd(palettePath)

fprintf(1, 'Storing mosels in %s...\n', palettePath);

for j = 1:size(image_palette, 2)
    %tmp = image_palette2(i).largedata;
    tmp = image_palette2(j).largedata;
    imwrite(tmp, ['mosel_', num2str(j), '.jpg'], 'jpg');
    image_palette2(i).largedata = [];
end
%}

fprintf(1, 'Creating sample space coordinates...\n');
% Preprocessing:
M = size(palette, 2); %number of mosels
N = numel(palette(1).samples); %total number of samples (RGB)
sample_space = zeros(M, N); %matrix of all samples (M-by-N) m mosels with N samples (RGB)

% Pack all samples into vectors in N^n space and search mosels using dsearchn
if speedup
    try
        for ii = 1:M
            sample_space(ii, :) = reshape(palette(ii).samples', 1, numel(palette(1).samples));
        end
    catch Exception
        
        fprintf(1,'an error occured with reshape \n')
        numel(palette(1).samples)
        size(palette(ii).samples')
    end
    
    cd(tmpPwd)
    
end

