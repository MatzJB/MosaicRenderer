
% Constants used by renderMosaics
galobal DEBUG = false
reInit = true; 
% if false we will get a choice between generated mosaic files, otherwise
% the mosaic palette will be re-calculated

collectConst = {};
collectConst.stats = false;
collectConst.debug = false;
collectConst.blurMosels = true;
collectConst.nSamples = 10; %default: 10
collectConst.skipMosel = 15; %100
collectConst.blurSigma = 0.5;
collectConst.nPrgrs = 10;
collectConst.ignoreWhite = false; %if mosel contains lots of white

renderConst = {};
renderConst.plot = false;
renderConst.render = true;
renderConst.stats = false;
renderConst.debug = false;
renderConst.useColors = true; %should use colors, B/W seems to be wrong
renderConst.speedup = true; %approximately 20 times speedup

renderHeight = 9000; % height of result (pixels)

%moselsDir = 'C:\tmp\mix';
%moselsDir = 'C:\tmp\crosshatch';
moselsDir = 'C:\tmp\HofD';
%moselsDir = 'C:\tmp\test2';

%outputDir = 'E:\Archive 2014\Projects\Mosaic\mosaicData';

%outputDir = 'C:\Users\User\Dropbox\to mosaic\mosaics';
outputDir = 'C:\Users\User\Dropbox\Graphics_programming\projects\mosaic_viewer\src\gallery';
%moves input files to this dir when finished
mosaicMoveDir = 'C:\Users\User\Dropbox\to mosaic\finished';
mosaicDir = 'C:\Users\User\Dropbox\to mosaic';
%mosaicDir = 'E:\Archive 2014\Projects\Mosaic\To mosaic';
mosaicPaletteDir = outputDir;

% read a mosel and base the dimensions on a single sample
[r, c] = fetchImageSizeDir(moselsDir);

targetHeight = 60;
factor = targetHeight/r;
r = targetHeight;
c = factor*c;

%todo: add support to add full size mosaics from directory
