%filterMoselStructure(moselStruct, sampleThreshold)
%
%  moselStructureFiltered takes a mosaic element structure and a
%  sampleThreshold value and returns a filtered mosel structure based on
%  the similary of the mosels. The higher the value, the more mosels will
%  be removed.

function moselStructureFiltered = filterMoselStructure(moselStruct, sampleThreshold)

% Todo: should be able to target a number of mosels and show the colors and the
% distribution of color and also sort the mosels using overall mean colors

moselStructureFiltered = moselStruct;
nSamples = length(moselStruct.palette(1).samples);

for i=1:length(moselStruct.palette)
    moselStructureFiltered.palette(i).dirty = 0;
end

nSimilarSamples = 0;
nMosels= length(moselStruct.palette);
for j = 1:nMosels-1
    for i = j+1:nMosels
        if moselStructureFiltered.palette(j).dirty == 0
            v = single( moselStruct.palette(i).samples );
            w = single( moselStruct.palette(j).samples );
            sumdiff = sum(abs(v - w));
            
            if sumdiff/nSamples  < sampleThreshold %threshold using "difference per sample"
                nSimilarSamples = nSimilarSamples+1;
                moselStructureFiltered.palette(j).dirty = 1; %will be removed
            end
        end
    end
end

fprintf(1, 'Marked %d/%d samples as similar\n', nSimilarSamples, length(moselStruct.palette));

for i = length(moselStruct.palette):-1:1
    if moselStructureFiltered.palette(i).dirty == 1
        moselStructureFiltered.palette(i) = [];
        moselStructureFiltered.sampleSpace(i,:) = [];
        moselStructureFiltered.sampleSpaceBW(i,:) = [];
    end
end