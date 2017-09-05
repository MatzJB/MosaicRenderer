%generateSpritemap(directory, height)
%
%  generateSpritemap returns a spritemap of the images using a 
%  height parameter
function spritemap = generateSpritemap(palette, indices, gray)


spritemap = mosaicIndexToImage('', '', indices, 1, palette, gray);
% calculate the optimal dimensions for spritemap (factors)


