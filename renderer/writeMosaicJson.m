%writeMosaicJson(palette, indices, gray)
%
%  writeMosaicJson writes a JSON file used by the 'Mosaic Viewer' along
%  with a sprite map file to visualize a mosaic in an efficient way.

function writeMosaicJson(mosaicJsonFilename, spriteJsonFilename, indices)

[rows, columns] = size(indices);
[~, spriteJsonFilename, ext] = fileparts(spriteJsonFilename);
spriteJsonFilename = [spriteJsonFilename, ext];
fileID = fopen(mosaicJsonFilename, 'wt');

fprintf(1, 'writing spritemap %s\n', spriteJsonFilename);

compressionRatio = length(unique(indices)) / numel(indices);

jsonData = ['{', '"spriteMap":', '"', spriteJsonFilename, '", ',...
    '"metadata": {', ...
    '"columns": ', num2str(columns),','...
    '"rows": ', num2str(rows),'},',...
    '"compressionRatio":', num2str(compressionRatio), ','...
    '"mosaicIndices": ['];
fprintf(fileID, '%s\n', jsonData);

indices = indices';

fprintf(fileID, '%d,\n', indices(1:end-1));
fprintf(fileID, '%d]}\n', indices(end));

fclose(fileID);

fprintf(1, 'json file %s was written to disk.\n', mosaicJsonFilename);

