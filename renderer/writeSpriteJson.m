%writeSpriteJson(jsonFilename, palette, gray)
%
%  writeSpriteJson writes a JSON file used by the 'Mosaic Viewer' along
%  with a mosaic json to visualize a mosaic in an efficient way.

function writeSpriteJson(jsonFilename, palette, gray)
%JPEGDimLimit = 65500;
threeTextureLimit = 16384;

len = length(palette);
factors = factor(len);
center = floor(length(factors)*0.5);

newRows = prod(factors(1:center));
newCols = prod(factors(center+1:end));


tmp = palette(1).data;
maxPixels = max(size(tmp));
%mult with size

% test the size of the spritemap
if max([newRows, newCols])*maxPixels > threeTextureLimit

    
newRows = ceil(sqrt(len));
newCols = newRows;

end

% test on updated size
if max([newRows, newCols])*maxPixels > threeTextureLimit
    error(['The largest dimension of the sprite map is exceeding ', threeTextureLimit, 'pixels. Consider using smaller mosels. Bailing out.'])
end






%{
% note: if prime, the spritemap will be a long sequence of images
%}
%{
if ceil(sqrt(len*palette.data(1))) > JPEGDimLimit
    error('The largest dimension of the sprite map is exceeding 65500 pixels, consider using smaller mosels')
end

if newRows > JPEGDimLimit || newCols > JPEGDimLimit
    fprintf(1, 'The dimensions of the spritemap are not optimal. Using as small dimensions as possible.\n');
    
    newRows = ceil(sqrt(len));
    newCols = newRows;
end
%}

[pathstr, name, ext] = fileparts(jsonFilename);
spriteFilename = [name, '.jpg'];

fileID = fopen(jsonFilename, 'w');
fprintf(1, '%s\n', jsonFilename);

if newRows*newCols ~= len
    fprintf(1, 'Spritemap is missing elements\n');
    fprintf(1, 'newRows:%d newCols:%d\n', newRows, newCols);
    fprintf(1, 'indices len:%d\n', len);
end

%generate spritemap with all indices
indices = 1:newRows*newCols;
[pathStr, jsonFilename, ext] = fileparts(jsonFilename);
indices = reshape(indices(:), newCols, newRows)';
indices = flip(indices); %flip because of threeJS
indices(indices>len) = 1;
spritemap = generateSpritemap(palette, indices, gray); %note use of len
%fix indices issue

tmp = size(palette(1).data);
ratio = tmp(1)/tmp(2);
pixelHeight= tmp(1);
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
fclose(fileID);

fprintf(1, '%s\n', jsonData);

fprintf(1, 'writing spritemap color data %s\n', spriteFilename);
imwrite(spritemap/255, [pathstr, filesep, spriteFilename], 'jpg', 'quality', 90)
