%fetchImageSizeDir(imagepath)
%
%  fetchImageSizeDir fetches the dimensions of the first image in a directory
function [r, c] = fetchImageSizeDir(imagePath)

tmpPwd = pwd;
cd(imagePath)
imagefiles = dir('*');
sampleImageFilename = imagefiles(3).name;
img = imread(sampleImageFilename);
[r, c, ~] = size(img);
cd(tmpPwd);
