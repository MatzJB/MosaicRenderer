%collectMosaicData(mosaicSize, moselsDir, constants)
%
%  collectMosaicData is a function processing mosaic elements returning two
%  matrices: <palette> and <samples>. The function requires a image directory
%  <moselsDir> and size of processed mosels <mosaicSize> as a vector [height, width] specifying mosel size in pixels.
%
%  Optional arguments: constants
%
%       stats - show statistics while collecting mosaic data (default)
%       debug - showing debug prints and lines in render (default: false)
%       blurMosels  - using speedier code. (default: false)
%       nSamples - Number of samples used (one dimension)
%       (default: 10)
%       skipMosel - number of mosels skipped (useful when rendering frames
%       from a move) (default:1)
%       blurSigma - gaussian blur sigma
%       nPrgrs - number of progress printouts (default:10)
%       ignoreColor - ignore a specific color from mosel

function [moselStruct] = collectMosaicData(mosaicSize, moselsDir, varargin)

constants = {};
constants.stats = false;
constants.debug = false;
constants.blurMosels = false;
constants.nSamples = 10;
constants.skipMosel = 1;
constants.blurSigma = 0.5;
constants.nPrgrs = 10;
constants.ignoreWhite = false;


if nargin==3 % override defaults with constants
    try
        argconst = varargin{1};
        constants.stats = argconst.stats;
        constants.debug = argconst.debug;
        constants.blurMosels = argconst.blurMosels;
        constants.nSamples = argconst.nSamples;
        constants.skipMosel = argconst.skipMosel;
        constants.blurSigma = argconst.blurSigma;
        constants.nPrgrs = argconst.nPrgrs;
        constants.ignoreWhite = argconst.ignoreWhite;
    catch
        warning('some variables were not defined by optional argumen')
    end
end

if constants.debug
    fprintf(1, 'skip: %d\n', constants.skipMosel);
end
% Larger mosels require filtering to provide nice samples
mosaicSize  = round(mosaicSize);
% mosaic element number of rows and columns (pixels)
rMosel   = mosaicSize(1);
cMosel   = mosaicSize(2);
ratMosel = cMosel/rMosel; %ratio

if constants.nSamples > rMosel || constants.nSamples > cMosel
    warning('Number of samples is larger than resolution of mosel')
end

% todo: remove speedup option
speedup    = 1; % optimized code

if constants.debug
    fprintf(1, 'Creating palette from %s...\n', pwd);
end

tmpPwd     = pwd;

%todo: we might wish to simply supply path to moselsDir instead of moving there
cd(moselsDir)
imagefiles = dir('*');
nFiles     = length(imagefiles);
if constants.debug
    fprintf(1, 'Reading, cropping and sampling %d mosels...\n', nFiles);
end

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
range = 3:constants.skipMosel:nFiles;
[inds, coordinates] = getSamplePattern([rMosel, cMosel], constants.nSamples);

index = 1;
%nSamplesTotal = 3*constants.nSamples^2; %Note: grid*RGB
tPalette = tic;
for ii = range % skip . and ..
    imname = imagefiles(ii).name;
    [~, ~, ext] = fileparts(imname);
    if ~strcmp(ext, '.jpeg') && ~strcmp(ext, '.jpg') && ~strcmp(ext, '.png')
        continue
    end
    
    im = imread(imname);
    if constants.debug && size(im,3)~=3 %we only accept RGB images
        fprintf(1, 'image %s not RGB, skipping\n', imname);
        continue
    end
    
    if ii==3
        %todo: fix so we can use the coordinates
        if constants.ignoreWhite
            im2 = rgb2gray(im);
            inds = inds(im2(inds)~=1);
        end
        
        indsRGB = [inds + rMosel*cMosel*0; inds + rMosel*cMosel*1;...
                   inds + rMosel*cMosel*2]; %2d to 3d sample indices
        indsBW = inds;
    end
    
    imTmp = rescaleAndCrop(im, [rMosel, cMosel]);
    palette(index).name = imname;
    
    % get samples, decide if blurred, BW too
    if constants.blurMosels
        imTmp = applyBlurFilter(single(imTmp), blurKernel);
    end
    
    tmpSamples = imTmp(indsRGB);
    nSamplesTotal = numel(indsRGB);
    palette(index).samples = tmpSamples;
    tmpSamplesGray = 255*rgb2gray(reshape(im2double(tmpSamples), nSamplesTotal/3, 3));
    palette(index).samplesBW = tmpSamplesGray;
    palette(index).data = imTmp; % the image
    
    if size(tmpSamples, 3)==1
        palette(index).mean=[mean(tmpSamples), mean(tmpSamples), mean(tmpSamples)];
    else
        palette(index).mean = mean(tmpSamples);
    end
    
    if constants.debug && ~debugRun
        figure
        imagesc(imTmp)
        figure
        imagesc(moselBlurred/255)
        axis off
        hold on
        plot(coordinates(:, 2), coordinates(:, 1), 'rO')
        title('One Mosel, gaussian filtered with coordinates of the samples', 'fontsize', 12)
        pause(1)
        drawnow
        debugRun = true;
    end
    
    % printouts
    if constants.stats && mod(index, round(nFiles/constants.nPrgrs))==0
        fprintf(1, '%d...', round(progPerc(iPrgs)));
        iPrgs = iPrgs+1;
    end
    
    index = index+1;
end

if constants.stats
    fprintf(1, '100.\n');
    toc(tPalette)
    fprintf(1, 'Collected %d mosaics\n', index);
    fprintf(1, 'Creating sample space coordinates...\n');
end

% Preprocessing:
M = length(palette); %number of mosels
N = numel(palette(1).samples); %total number of samples (RGB)
sampleSpace = zeros(M, N); %matrix of all samples (M-by-N-by-3) m mosels with N samples
sampleSpaceBW = zeros(M, N); %matrix of all samples (M-by-N) m mosels with N samples (M-by-N)

% Pack all samples into vectors in N^n space and search mosels using dsearchn
if speedup
    try
        for ii = 1:M
            sampleSpace(ii, :) = reshape(palette(ii).samples', 1, numel(palette(1).samples));
            %numel(palette(1).samples)
            sampleSpaceBW(ii, :) = reshape(palette(ii).samplesBW', 1, numel(palette(1).samplesBW));
        end
    catch Exception
        numel(palette(1).samples)
        size(palette(ii).samples')
        ii
        rethrow(Exception)
    end
    
    cd(tmpPwd)
end

moselStruct.ver = 0.3;
moselStruct.palette = palette;
% for use with dsearchn
moselStruct.sampleSpace = sampleSpace;
moselStruct.sampleSpaceBW = sampleSpaceBW;
moselStruct.nSamples = constants.nSamples;
moselStruct.samplePatternBW = indsBW;
moselStruct.samplePatternRGB = indsRGB;

% todo: remove sample from mosaics and only use sampleSpace
