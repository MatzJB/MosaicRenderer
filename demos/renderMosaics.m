%{
    Mosaic render batch script
%}

constants %load constants used by this script

reInit = true; % we wish to re-calculate the mosaic elements

if moselsDir(end) == filesep, moselsDir = moselsDir(1:end-1); end

moselProjectname = strsplit(moselsDir, filesep);
moselProjectname = moselProjectname(end);
moselProjectname = moselProjectname{1};

imagefiles = dir([mosaicDir,filesep, '*.jpg']);
nFiles     = length(imagefiles);

fprintf(1, 'mosel project name %s\n', moselProjectname);
fprintf(1, 'Reading files to mosaic from %s...\n', mosaicDir);
fprintf(1, 'Found %d image(s)\n', nFiles);

mosaicNames{nFiles} = 0;
for ii = 1:nFiles
    imname = [mosaicDir,filesep,imagefiles(ii).name];
    mosaicNames{end+1} = imname;
end

if reInit
    [palette, samples] = collectMosaicData([r,c], moselsDir, collectConst);
    settingsStr = ['r=', num2str(r), ' nSamples=', num2str(collectConst.nSamples)];

    save([mosaicPaletteDir, filesep, 'palette - ', moselProjectname, ' - ', settingsStr, '.mat'], 'palette');
    save([mosaicPaletteDir, filesep, 'samples - ', moselProjectname, ' - ', settingsStr, '.mat'], 'samples');
else % load precalculated sample and palette file
    try
        sampleFiles  = dir([outputDir, filesep, 'samples*']);
        paletteFiles = dir([outputDir, filesep, 'palette*']);
        n = length(sampleFiles);
        
        if n>1
            fprintf(1, 'More than one sample file was found. Please choose the one to load from the list below...\n');
            for ii = 1:n, fprintf(1, '(%d) %s\n', ii, sampleFiles(ii).name); end
            
            id = n+1;
            while id>n || id<1, id = input('Select: '); end
            
            sampleFile  = sampleFiles(id).name;
            paletteFile = paletteFiles(id).name;
        elseif n==0
            error('could not find any samplefiles')
        else %n==1
            sampleFile  = sampleFiles.name;
            paletteFile = paletteFiles.name;
        end
        
        sampleFile = [outputDir,filesep,sampleFile];
        paletteFile = [outputDir,filesep,paletteFile];
        fprintf(1, ' palette file >> %s\n', paletteFile);
        fprintf(1, ' sample file >> %s\n', sampleFile);
        load(paletteFile, 'palette');
        load(sampleFile, 'samples');
    catch Exception
        fprintf(1, 'loading palette and samples did not succeed.\n');
        rethrow(Exception)
    end
end

if numel(palette)==0, error('palette file is empty'), end
if numel(samples)==0, error('samples was empty'), end

tTotal = tic;
for i = 1:length(mosaicNames)
    fprintf(1, 'mosaic number %d of %d\n', i, length(mosaicNames));
    close all
    mosaicName = mosaicNames{i};
    fprintf(1, 'render...%s\n', mosaicName);
    %todo: add try/catch if file was erased during render
    
    [mosaic, mosInds, mosMean] = renderMosaic(renderHeight, palette, samples, mosaicName, renderConst);
    
    [pathStr, name, ext] = fileparts(mosaicName);
    outFilename = [outputDir, filesep, name, '_mosaic', '.png'];
    mosaicIndexedName = [outputDir, filesep, name, '_ind.mat'];
    mosaicMeanName = [outputDir, filesep, name, '_mean.png'];
    imwrite(mosaic, outFilename, 'png')
    imwrite(mosMean/255, mosaicMeanName, 'png')
    save(mosaicIndexedName, 'mosInds');
    fprintf(1, 'Saved %s\n\n', outFilename);
end
toc(tTotal)
