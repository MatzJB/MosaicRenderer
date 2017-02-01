
% Constants used by renderMosaics
%add support for pearl mosaic sampling (one sample in a specific position)
reInit = true; % we wish to re-calculate the mosaic elements

collectConst = {};
collectConst.stats = false;
collectConst.debug = false;
collectConst.blurMosels = false;
collectConst.nSamples = 8; %default: 10
collectConst.skipMosel = 1; %100
collectConst.blurSigma = 0.5;
collectConst.nPrgrs = 10;
collectConst.ignoreWhite = true;

renderConst = {};
renderConst.plot = false;
renderConst.render = true;
renderConst.stats = false;
renderConst.debug = false;
renderConst.useColors = true;
renderConst.speedup = true; %approximately 20 times speedup

renderHeight = 4000; % height of result (pixels)

%moselsDir = 'C:\tmp\crosshatch';
%moselsDir = 'C:\tmp\perl'

%outputDir = 'E:\Archive 2014\Projects\Mosaic\mosaicData';
%moselsDir  = 'C:\tmp\Hateful eight'

outputDir = 'C:\Users\User\Dropbox\RapidResearch\mosaicAnimation';

mosaicDir = 'C:\Users\User\Dropbox\RapidResearch\mosaicAnimation\to mosaic';
mosaicMoveDir = 'C:\Users\User\Dropbox\RapidResearch\mosaicAnimation\to mosaic\finished';


%mosaicDir = 'E:\Archive 2014\Projects\Mosaic\To mosaic';
mosaicPaletteDir = outputDir;

r = 35;
%c = round(r*2.35); %ratio from mosels
%c = round(r*2.6550); %hateful eight
c=r;