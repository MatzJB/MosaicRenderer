%{
Generate ascii mosaic elements
%}

%size of mosaic element:
m = 50;
n = 90;
close all
figure

for charId = 1:250
    pause(0.1)
    A = zeros(m, n, 3);
    imshow(A);
    sA = size(A);
    minDim = min(sA(1:2));
    hText = text(size(A,2)/2, size(A,1)/2, char(charId), 'Color',...
        [1 1 1], 'FontSize', 0.6*minDim, 'horizontalalignment', 'center');
    
    hFrame = getframe(gca);
    A = rgb2gray(hFrame.cdata);
    id = 1;
    imwrite(255-hFrame.cdata, ['char_', num2str(charId), '.png'], 'png')
    
    drawnow
end