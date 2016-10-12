function writeLineHypercolumnFeatures(fn)
% 'lines/a01-000u-00.png'
features = squeeze(sum(extractHypercolumns(fn, 1, 11, 0), 1));
% //grafo plithos feature vectors
fileID = fopen('out.bin','w');
% //grafo sample period
fwrite(fileID, size(features, 1), 'uint');
fwrite(fileID, 10000, 'uint');
% //grafo arithmo plithos bytes gia ola ta features tou feature vector
% //to plithos ton features einai size(features, 2), to kathe variate einai
% // apothikevmeno san float, ara apotelesma 4*size(features, 2)
fwrite(fileID, 4*size(features, 2), 'ushort');
% //grafo ton typo ton features (9=USER DEFINED)
fwrite(fileID, 9, 'ushort');
% //Swzw to kathe fv me thn seira
for i = 1:size(features, 1)
    for d = 1:size(features, 2)
        fwrite(fileID, features(i, d), 'float');
    end
end
fclose(fileID);

return;