% sort mosels demo

moselStruct = collectMosaicData([r, c], moselsDir, collectConst);
writeSpriteJson('c:\tmp\spritemap_before3.json',...
    moselStruct.palette, false);

moselStructNew = sortMoselStructure(moselStruct, false);
writeSpriteJson('c:\tmp\spritemap_after3.json',...
    moselStructNew.palette, false);

moselStructNew = sortMoselStructure(moselStruct, true);
writeSpriteJson('c:\tmp\spritemap_after_mean3.json',...
    moselStructNew.palette, false);
