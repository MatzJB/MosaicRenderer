# MosaicRenderer

MosaicRenderer is a small Matlab library containing functionality to create uniform grid mosaic images (https://en.wikipedia.org/wiki/Photographic_mosaic).

The library supports simple blur filtering, fast sampling (using dnsearch), resizing and cropping of mosaic images as a preprocessing step before render, amongst other features. In addition to aforementioned features, it also stores the resulting renders for reuse (separate upcoming project).


Installation
---
To install the library, simply add the path to 'renderer' using addpath.


How to generate mosaic element from movies
---
Download ffmpeg https://www.ffmpeg.org/. Given a filename, type in your terminal

`
ffmpeg.exe -i "movie_filename.avi" -r 0.2 -f image2 image%03d.jpeg`
`

If the source video contains black borders you can crop the video using

`-vf "crop=1280:520:0:100"`

The generated images can then be used by the renderer (see constants.m).


Viewer
---
I have written an efficient mosaic viewer in Javascript/ThreeJS that takes the generated json files and allows the viewer to zoom in and out of the mosaic image.


Examples
---

Using mosaic elements from several movie frames (note: educational use) of Escher's "Hand with Reflecting Sphere" lithograph.
![Escher-hand-sphere-reflection-mosaic](https://cloud.githubusercontent.com/assets/14231209/22531619/6850075a-e8e2-11e6-8357-a450970149f6.jpg)

Using pearl beads:
![hand-with-reflecting-sphere-by-curlie-11jpg-294924_mosaic_zip_mosaic](https://cloud.githubusercontent.com/assets/14231209/22531650/93e27c18-e8e2-11e6-8ed8-7668fce8d8dd.jpg)
