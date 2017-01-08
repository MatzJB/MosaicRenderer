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
function [image_palette, sample_space] = collectMosaicData(mosaicSize, moselsDir, varargin)

% todo: remove skip and use a mosel filter system instead
skip = 5; %pick each <skip> mosaee in the directory

% todo: add constants arg for samples, sigma etc
if nargin==3 %number of samples
    nSamples = varargin{1};
else
    nSamples   = 10; % n_samples^2 total samples per mosel is used
end

if nargin==4 %should we blur mosaees prior to sampling, makes for better mosaics
    blurMosaee = varargin{2};
else
    blurMosaee = false;
end

% todo: add sigma as argument or part of cell array
sampleSigma = 0.6; % depends on n_samples, should be as small as possible, introduces black borders.
% Larger mosels require filtering to provide nice samples
nPrgrs      = 10; % number of prints from progress
mosaicSize  = round(mosaicSize);
% mosic element number of rows and columns (pixels)
rMosel   = mosaicSize(1);
cMosel   = mosaicSize(2);
ratMosel = cMosel/rMosel; %ratio

%todo: add HD mosel data handling
rMoselHD = 400; %experimental
cMoselHD = round(rMoselHD*ratMosel);

if nSamples>rMosel || nSamples>cMosel
    warning('Number of samples is larger than resolution of mosel')
end

%scale = 9; % high quality version size (ratio scale:=<large version>/<small>)
% todo: remove speedup option
speedup    = 1; % optimized code

fprintf(1, 'Creating palette from %s...\n', pwd);

tmpPwd     = pwd;

%we might wish to simply supply path to moselsDir instead of moving there
cd(moselsDir)
imagefiles = dir('*');
nFiles     = length(imagefiles);
fprintf(1, 'Reading, cropping and sampling %d mosels...\n', nFiles);

progPerc = linspace(0, 100, nPrgrs);
i       = 1;
iPrgs   = 1;

%todo: (otimization) bypass if no blurring is used
if blurMosaee
blurKernel = single( fspecial('gaussian', [rMosel, cMosel], sampleSigma) );
else % bypassing blurring
blurKernel = zeros(rMosel, cMosel);
blurKernel(ceil(end*0.5), floor(end*0.5)+1) = 1;
end

tPalette = tic;
for ii = 3:skip:nFiles % skip . and ..
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
    % imTmpHq = im; % rescaleAndCrop(im, scale*[rMosel, cMosel]); % HD version of mosels
    % todo: preallocate?
    image_palette(i).name = imname;
    moselBlurred = applyBlurFilter(single(imTmp), blurKernel);
    [tmp_samples, coords]    = retrieveSamples(moselBlurred, nSamples);
    image_palette(i).samples = tmp_samples;
    image_palette(i).data    = imTmp; % the image
    image_palette(i).mean    = mean(tmp_samples); % used for histogram
    
    if ii == 10
        figure
        imagesc(imTmp)
        figure
        imagesc(moselBlurred/255)
        axis off
        hold on
        plot(coords(:, 2), coords(:, 1), 'rO')
        title('One Mosel, gaussian filtered with coordinates of the samples', 'fontsize', 14)
        pause(1)
        drawnow
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
    if mod(i, round(nFiles/nPrgrs))==0
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
M = size(image_palette, 2); %number of mosels
N = numel(image_palette(1).samples); %total number of samples (RGB)
sample_space = zeros(M, N); %matrix of all samples (M-by-N) m mosels with N samples (RGB)

% Pack all samples into vectors in N^n space and search mosels using dsearchn
if speedup
    for ii = 1:M
        sample_space(ii, :) = reshape(image_palette(ii).samples', 1, numel(image_palette(1).samples));
    end
end

cd(tmpPwd)

end

