
% Constants used by renderMosaics

collectConst = {};
collectConst.stats   = false;
collectConst.debug  = false;
collectConst.blurMosels = false;
collectConst.nSamples = 15; %10
collectConst.skipMosel = 35; %100
collectConst.blurSigma = 0.5;
collectConst.nPrgrs    = 10;

renderConst = {};
renderConst.plot = true;
renderConst.render = true;
renderConst.stats  = false;
renderConst.debug  = false;
renderConst.nocolors  = true; %ignore colors
renderConst.speedup  = true; %approximately 20 times speedup

renderHeight = 2000; % height of result (pixels)

% NOTE: specify path of mosaic images!!!
moselsDir = 'C:\tmp\star wars V\';
palettePath = 'C:\tmp\palette temp'; % not used
outputDir = 'E:\Archive 2014\Projects\Mosaic\mosaicData';
mosaicDir = 'E:\Archive 2014\Projects\Mosaic\To mosaic';
mosaicPaletteDir = outputDir;

r = 12;
c = round(r*2.35); %ratio from mosels
