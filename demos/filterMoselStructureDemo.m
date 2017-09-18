% filter mosel structure and save spritemap for each of them

writeSpriteJson('c:\tmp\spritemap_before.json', moselStruct.palette, false)

filterThresholds = [10, 50, 100, 200, 500, 1000, 5000];
for i=1:length(filterThresholds)
    tmp = filterMoselStructure(moselStruct, i);
    writeSpriteJson(['c:\tmp\spritemap_after_', num2str(filterThresholds(i)), '_units.json'], tmp.palette, false)
end

