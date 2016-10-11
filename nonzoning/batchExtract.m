function cue = batchExtract(dirname, modelchoice, layerchoice, centerprior, resizeheight)
% batchExtract
%
% Script to extract VLDCF features for jpg files in the 'dirname' folder.
% Descriptors are saved in a format readable by the SSWR utility.
%
% G Sfikas May '16
if(exist('modelchoice', 'var'))
    modelchoice = str2num(modelchoice);
end
if(exist('layerchoice', 'var'))
    layerchoice = str2num(layerchoice);
end
if(exist('centerprior', 'var'))
    centerprior = str2num(centerprior);
end
if(exist('resizeheight', 'var'))
    resizeheight = str2num(resizeheight);
end
a = dir(sprintf('%s/*.jpg', dirname));
fprintf('Found %d image files.\n', numel(a));
cue = cell(numel(a), 1);
lengths = zeros(numel(a), 1);
largestindex = 0;
foundnumberedFiles = 0;
for i = 1:numel(a)
    fn = a(i).name;
    [~, fp2, ~] = fileparts(fn);
    idx = str2double(fp2) + 1;
    if(isnan(idx))
        continue;
    end
    foundnumberedFiles = foundnumberedFiles + 1;
    largestindex = max(idx, largestindex);
    if(nargin < 2)
        fv = extractAggregatedHypercolumns(strcat(dirname, '/', fn));
    else
        fv = extractAggregatedHypercolumns(strcat(dirname, '/', fn), modelchoice, layerchoice, centerprior, resizeheight);
    end
    r = fv;
    nDims = size(r, 2);
    lengths(idx) = size(r, 1);
    cue{idx} = r(:); %concatenation of L rows
end
if largestindex ~= foundnumberedFiles
    error('error reading data! Indices of jpgs are inconsistent.');
end
% Write to file
dimsFileID = fopen('dimensions.txt','w');
fprintf(dimsFileID, '%d\n', nDims);
fclose(dimsFileID);
%
cuesFileID = fopen('distance.txt','w');
lengFileID = fopen('length.txt', 'w');
for i = 1:numel(cue)
    fprintf(lengFileID, '%d\n', lengths(i));
    tt = cue{i};
    for meg = 1:numel(cue{i})
        fprintf(cuesFileID, '%f ', tt(meg));
    end
    fprintf(cuesFileID, '\n');
    %fprintf('.');
    fprintf('Wrote %d feature vectors at line %d of "distance" file for image %d\n', round(numel(cue{i})/nDims), i, i-1);
end
fprintf('\n');
return;