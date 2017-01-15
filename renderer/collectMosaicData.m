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
%       nProfrs - number of progress printouts (default:10)
function [moselStruct] = collectMosaicData(mosaicSize, moselsDir, varargin)

constants = {};
constants.stats = false;
constants.debug = false;
constants.blurMosels = false;
constants.nSamples = 10;
constants.skipMosel = 1;
constants.blurSigma = 0.5;
constants.nPrgrs = 10;

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
    catch
        warning('some variables were not defined by optional argumen')
    end
end

if constants.debug
    fprintf(1, 'skip: %d\n', constants.skipMosel);
end

nShades = 5000; %used by RGB2index

% Larger mosels require filtering to provide nice samples
mosaicSize  = round(mosaicSize);
% mosic element number of rows and columns (pixels)
rMosel   = mosaicSize(1);
cMosel   = mosaicSize(2);

if constants.nSamples > rMosel || constants.nSamples > cMosel
    warning('Number of samples is larger than resolution of mosel')
end

speedup = 1; % optimized code

if constants.debug
    fprintf(1, 'Creating palette from %s...\n', pwd);
end

tmpPwd = pwd;

%todo: we might wish to simply supply path to moselsDir instead of moving there
cd(moselsDir)
imagefiles = dir('*');
nFiles = length(imagefiles);
if constants.debug
    fprintf(1, 'Reading, cropping and sampling %d mosels...\n', nFiles);
end

progPerc = linspace(0, 100, constants.nPrgrs);
iPrgs = 1;

if constants.blurMosels
    blurKernel = single( fspecial('gaussian', [rMosel, cMosel], constants.blurSigma) );
end

debugRun = false; %flag to discern if we run debug print
range = 3:constants.skipMosel:nFiles;

nElement = numel(range);
for index=1:nElement
    palette(index).data = zeros(rMosel, cMosel);
end

[sampleIndices,coords] = getSamplePattern(mosaicSize, constants.nSamples);

index = 1;
tPalette = tic;
for ii = range%3:constants.skipMosel:nFiles % skip . and ..
    imname = imagefiles(ii).name;
    [~, ~, ext] = fileparts(imname);
    if ~strcmp(ext, '.jpeg') && ~strcmp(ext, '.jpg')
        continue
    end
    
    im = imread(imname);
    [im, map] = rgb2ind(im, nShades); %convert to indexed image, for faster render
    imTmp = rescaleAndCrop(im, [rMosel, cMosel]); % scale image so we can see
    palette(index).name = imname;
    
    % get samples, decide if blurred, BW too
    if constants.blurMosels
        imTmp = applyBlurFilter(single(imTmp), blurKernel);
    end
    
    %[tmpSamples, coords] = retrieveSamples(imTmp, constants.nSamples);
    tmpSamples = imTmp(sampleIndices);
    palette(index).samples = tmpSamples;
    %tmp = rgb2gray(reshape(tmpSamples(:), nSamplesTotal/3, 3));
    %tmp = rgb2gray(tmpSamples);
    %fprintf(1,'samples:%d\n\n----', tmpSamples);
    %tmp = 255*ind2gray(tmpSamples(:)/255);
    
    palette(index).samplesBW = tmpSamples; %change
    palette(index).data = imTmp; % the image
    palette(index).mean = mean(tmpSamples); % used for histogram etc.
    
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
    fprintf(1, 'Found %d mosaics\n', index);
    fprintf(1, 'Creating sample space coordinates...\n');
end

% Preprocessing:
M = size(palette, 2); %number of mosels
N = numel(palette(1).samples); %total number of samples (RGB)
sampleSpace = zeros(M, N); %matrix of all samples (M-by-N-by-3) m mosels with N samples
sampleSpaceBW = zeros(M, N); %matrix of all samples (M-by-N) m mosels with N samples (M-by-N)

% Pack all samples into vectors in N^n space and search mosels using dsearchn
if speedup
    try
        for ii = 1:M %todo tidy up
            sampleSpace(ii, :) = reshape(palette(ii).samples', 1, numel(palette(1).samples));
            sampleSpaceBW(ii, :) = reshape(palette(ii).samplesBW', 1, numel(palette(1).samplesBW));
        end
    catch Exception
        numel(palette(1).samples)
        size(palette(ii).samples')
        error('an error occured with reshape')
    end
    
    cd(tmpPwd)
end

moselStruct.nShades = nShades;
moselStruct.ver = 0.2;
moselStruct.palette = palette;
moselStruct.map = map;
% for use with dsearchn
moselStruct.sampleSpace = sampleSpace;
moselStruct.sampleSpaceBW = sampleSpaceBW;