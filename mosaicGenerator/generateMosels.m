%generateMosels(inputFilename, outputPath, nMosels)
%
%  generateMosels creates mosaic elements for the renderMosaics function.
% <inputFilename> is a gray scale version of the mosel. GenerateMosels will
% apply a color mapping to this image and yield a number of mosels.
% Tip: If the resulting images are too dark, change the brightness/contrast of
% the source.
%
% The function will base the mosel names from the inputFilename.
% <nMosels> is the total number of mosels you wish to generate (multiple of 4).

function generateMosels(inputFilename, outputPath, nMosels)

[~, outputFilePrefix, ~] = fileparts(inputFilename);
nColors = ceil(nMosels*0.25);
A = imread(inputFilename);
A = double(rgb2gray(A));
nCols = 200; % total number of shades

% gaussian function for color mapping highlights
x = linspace(-10, 10, nCols);
gauss  = @(x, b, c) 1.0*exp(-(x-b).^2 / (2*c^2));
ind = 1;
f = imagesc(A);
cols = jet(nCols);

for brightness = 1:4
    for k = ceil(linspace(1, nCols, nColors))
        
        % saturation * gauss(x, brightness, width of color spectrum, makes dark pixels colored)
        gaussVecMid = brightness*0.25*gauss(x, 1, 10)';
        
        % shininess*gauss(x, ?, width of highlight)
        gaussVecHigh = 0.5*gauss(x, 5, 3)';
        thIndex = ceil(0.8*nCols); % percent of attenuation where color is constant
        mask = [linspace(0, 1, thIndex), ones(1, nCols - thIndex)]';
        newColors = repmat(gaussVecHigh, 1, 3) +...
            repmat(gaussVecMid, 1, 3).*...
            repmat(cols(k, :), nCols, 1);
        newColors = min(newColors, 1); %clamp
        newColors(end-ceil(nCols/15):end, :) = 1; %background
        out = [outputPath, filesep, outputFilePrefix, num2str(ind), '.jpg'];
        set(f, 'cdata', A)
        colormap(newColors)
        imwrite(A, newColors, out, 'quality', 100)
        ind = ind+1;
    end
end
