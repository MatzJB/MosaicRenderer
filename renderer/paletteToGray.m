function palette = paletteToGray(palette)

    rg = size(palette(1).samples, 2); % rows after grouping in RGB
    rs = size(palette(:), 1); % number of samples
    for ii=1:rs
        dataBW = rgb2gray(palette(ii).data);
        dataRGB = cat(3, dataBW, dataBW, dataBW);
        palette(ii).data = dataRGB;
        samples = palette(ii).samples;
        tmp = rgb2gray(reshape(samples(1,:), rg/3, 3)/255);
        palette(ii).samples = tmp(:);
    end



