%writeSpriteJson(jsonFilename, palette, gray)
%
%  writeSpriteJson writes a JSON file used by the 'Mosaic Viewer' along
%  with a mosaic json to visualize a mosaic in an efficient way.

function writeSpriteJson(jsonFilename, palette, gray)
global DEBUG
threeTextureLimit = 16384;

len = length(palette);
tmp = palette(1).data;
maxPixels = max(size(tmp));
newRows = ceil(sqrt(len));
newCols = newRows;

% test on updated size
if max([newRows, newCols])*maxPixels > threeTextureLimit
    error(['The largest dimension of the sprite map is exceeding ',...
        num2str(threeTextureLimit),...
        ' pixels. Consider using smaller mosels. Bailing out.'])
end

[pathstr, name, ~] = fileparts(jsonFilename);
spriteFilename = [name, '.jpg'];

fileID = fopen(jsonFilename, 'w');
fprintf(1, '%s\n', jsonFilename);

if newRows*newCols ~= len
    fprintf(1, ' Spritemap is missing elements\n');
    fprintf(1, ' newRows:%d newCols:%d\n', newRows, newCols);
end

% generate spritemap with all indices
indices = 1:newRows*newCols;
indices = reshape(indices(:), newCols, newRows)';
indices = flip(indices); %flip because of threeJS
indices(indices>len) = 1; % map same mosel to the ones left
spritemap = generateSpritemap(palette, indices, gray); %note use of len

tmp = size(palette(1).data);
ratio = tmp(1)/tmp(2);
pixelHeight = tmp(1);
pixelWidth = tmp(2);

% note: flipped columns and rows because of the transpose after reshape
jsonData = ['{', '"colordata":', '"', spriteFilename, '", ',...
    '"metadata": {', ...
    '"columns": ', num2str(newCols), ', '...
    '"rows": ', num2str(newRows), ', '...
    '"ratio": ', num2str(ratio), ', '...
    '"pixelWidth ": ', num2str(pixelWidth), ', '...
    '"pixelHeight": ', num2str(pixelHeight), ...
    '}}'];

fprintf(fileID, '%s\n', jsonData);

if DEBUG
    fprintf(1, '%s\n', jsonData);
end

fclose(fileID);

if DEBUG
    fprintf(1, '%s\n', jsonData);
    fprintf(1, 'writing spritemap color data %s\n', spriteFilename);
end

imwrite(spritemap/255, [pathstr, filesep, spriteFilename], 'jpg',...
    'quality', 95)
