
% Constants used by renderMosaics

reInit = true; % we wish to re-calculate the mosaic elements

collectConst = {};
collectConst.stats = false;
collectConst.debug = false;
collectConst.blurMosels = false;
collectConst.nSamples = 30; %default: 10
collectConst.skipMosel = 50; %100
collectConst.blurSigma = 0.5;
collectConst.nPrgrs = 10;

renderConst = {};
renderConst.plot = true;
renderConst.render = true;
renderConst.stats = true;
renderConst.debug = false;
renderConst.useColors = true;
renderConst.speedup = true; %approximately 20 times speedup

renderHeight = 4000; % height of result (pixels)

moselsDir = 'C:\tmp\Inception Coherence Predestination Triangle Memento\';
%moselsDir = 'C:\tmp\mix';
%moselsDir = 'C:\tmp\star wars V';
palettePath = 'C:\tmp\palette temp'; % not used
%outputDir = 'E:\Archive 2014\Projects\Mosaic\mosaicData';
outputDir = 'C:\Users\User\Dropbox\RapidResearch\mosaicAnimation';

mosaicDir = 'E:\Archive 2014\Projects\Mosaic\To mosaic';
mosaicPaletteDir = outputDir;

r = 30;
c = round(r*2.35); %ratio from mosels
