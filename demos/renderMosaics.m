%{
    Mosaic render batch script
%}

constants %load constants used by this script

reInit = true; % we wish to re-calculate the mosaic elements
curMosaicVer = 0.2;

if moselsDir(end) == filesep, moselsDir = moselsDir(1:end-1); end

moselProjectname = strsplit(moselsDir, filesep);
moselProjectname = moselProjectname(end);
moselProjectname = moselProjectname{1};

imagefiles = dir([mosaicDir, filesep, '*.jpg']);
nFiles = length(imagefiles);

fprintf(1, 'mosel project name: %s\n', moselProjectname);
fprintf(1, 'Reading files to mosaic from %s...\n', mosaicDir);
fprintf(1, 'Found %d image(s)\n', nFiles);

mosaicNames{nFiles} = 0;
for iFile = 1:nFiles
    imname = [mosaicDir,filesep,imagefiles(iFile).name];
    mosaicNames{iFile} = imname;
end

if reInit
    settingsStr = ['r=', num2str(r), ' nSamples=', num2str(collectConst.nSamples), ' skip=', num2str(collectConst.skipMosel)];
    moselStruct = collectMosaicData([r,c], moselsDir, collectConst);
    save([mosaicPaletteDir, filesep, 'Mosaic Data ver=', num2str(curMosaicVer), ' -', moselProjectname, '- ', settingsStr, '.mat'], 'moselStruct');
else % load precalculated sample and palette file
    try
        mosaicDataFiles  = dir([outputDir, filesep, 'Mosaic Data ver=', num2str(curMosaicVer)', '*']);
        nFiles = length(mosaicDataFiles);
        
        if nFiles>1
            fprintf(1, 'More than one sample file was found. Please choose the one to load from the list below...\n');
            for iFile = 1:nFiles, fprintf(1, '(%d) %s\n', iFile, mosaicDataFiles(iFile).name); end
            
            id = nFiles+1;
            while id>nFiles || id<1, id = input('Select: '); end
            
            dataFilename = mosaicDataFiles(id).name;
        elseif nFiles==0
            error('could not find any samplefiles')
        else %n==1
            dataFilename = mosaicDataFiles.name;
        end
        
        dataFilename = [outputDir, filesep, dataFilename];
        fprintf(1, ' mosaic data file >> %s\n', dataFilename);
        load(dataFilename, 'moselStruct');
    catch Exception
        fprintf(1, 'loading mosaic data did not succeed.\n');
        rethrow(Exception)
    end
end

if numel(moselStruct)==0, error('mosaic data file is empty'), end

tTotal = tic;
for iMosaic = 1:length(mosaicNames)
    fprintf(1, 'mosaic number %d of %d\n', iMosaic, length(mosaicNames));
    close all
    mosaicName = mosaicNames{iMosaic};
    
    %todo: add try/catch if file was erased during render
    try
        fprintf(1, 'render...%s\n', mosaicName);
        [mosaic, mosInds, mosMean] = renderMosaic(renderHeight, moselStruct, mosaicName, renderConst);
    catch Exception
        %warning(['File ', mosaicName,' was not found'])
        continue
    end
    
    ext = 'jpg';
    [pathStr, name, ext] = fileparts(mosaicName);
    outFilename = [outputDir, filesep, name, '_mosaic.', ext];
    mosaicIndexedName = [outputDir, filesep, name, '_ind.mat'];
    mosaicMeanName = [outputDir, filesep, name, '_mean.', ext];
    imwrite(mosaic, moselStruct.map, outFilename)
    imwrite(mosMean/255, mosaicMeanName)
    save(mosaicIndexedName, 'mosInds');
    fprintf(1, 'Saved %s\n\n', outFilename);
end
toc(tTotal)
