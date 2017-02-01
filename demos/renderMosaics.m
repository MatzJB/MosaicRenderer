%{
    Mosaic render batch script
%}

constants %load constants used by this script
moselVer = 0.30; %current supported version, use only 2 decimal places
moselVer = sprintf('%.2f', moselVer);

if moselsDir(end) == filesep, moselsDir = moselsDir(1:end-1); end

moselProjectname = strsplit(moselsDir, filesep);
moselProjectname = moselProjectname(end);
moselProjectname = moselProjectname{1};

if reInit
    settingsStr = ['r=', num2str(r),...
        ' nSamples=', num2str(collectConst.nSamples),...
        ' skip=', num2str(collectConst.skipMosel)];
    moselStruct = collectMosaicData([r, c], moselsDir, collectConst);
    save([mosaicPaletteDir, filesep, 'Mosaic Data ver=', moselVer,...
        ' ', moselProjectname, '- ', settingsStr, '.mat'], 'moselStruct');
else % load precalculated sample and palette file
    try
        % load matching version
        mosaicDataFiles  = dir([outputDir, filesep, 'Mosaic Data ver=', moselVer, '*']);
        nFiles = length(mosaicDataFiles);
        
        if nFiles>1
            fprintf(1, 'More than one sample file was found. Please choose the one to load from the list below...\n');
            for iFile = 1:nFiles, fprintf(1, '(%d) %s\n', iFile, mosaicDataFiles(iFile).name); end
            
            id = nFiles+1;
            while id>nFiles || id<1, id = input('Select: '); end
            
            dataFilename = mosaicDataFiles(id).name;
        elseif nFiles==0
            error('could not find any moselStruct files')
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

mosaicMoveDir

while true
    close all
    imagefiles = dir([mosaicDir, filesep, '*.jpg']);
    
    if length(imagefiles) == 0
        fprintf(1, '.');
        pause(10)
        continue
    end
    
    mosaicName = imagefiles(1).name; % pick the first filename
    mosaicName = [mosaicDir, filesep, mosaicName];
    
    try
        [mosaic, mosInds, mosMean] = renderMosaic(renderHeight, moselStruct, mosaicName, renderConst);
    catch Exception
        warning(['rendering ', mosaicName,' was not successful'])
        rethrow(Exception)
    end
    
    [pathStr, name, ext] = fileparts(mosaicName);
    outFilename = [outputDir, filesep, name, '_mosaic', '.png'];
    mosaicIndexedName = [outputDir, filesep, name, '_ind.mat'];
    mosaicMeanName = [outputDir, filesep, name, '_mean.png'];
    imwrite(mosaic, outFilename, 'png')
    imwrite(mosMean/255, mosaicMeanName, 'png')
    save(mosaicIndexedName, 'mosInds');
    fprintf(1, 'Saved %s\n\n', outFilename);
    
    [~, name, ext] = fileparts(mosaicName);
    moselMoveName = [mosaicMoveDir, filesep, name, ext];
    movefile(mosaicName, moselMoveName);
end
