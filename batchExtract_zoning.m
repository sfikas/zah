function [cue filenames] = batchExtract_zoning(dirname, modelchoice, layerchoice, centerprior, resizeheight, usepca)
% batchExtract_zoning
%
% Script to extract ZAH features for jpg files in the 'dirname' folder.
% Descriptors are saved in a format readable by the SSWR utility.
%
% If usepca = 0, no PCA compression will be performed.
% Set usepca = 1 to enable it. The dimension that covers 98% of variance
% will be chosen.
%
% The output is a matrix of size NxD.
% N is number of data, D is number of dimensions.
%
% G Sfikas May '16

if(exist('modelchoice', 'var'))
    modelchoice = str2num(modelchoice);
%else
%    modelchoice = 2;
end

if(exist('layerchoice', 'var'))
    layerchoice = str2num(layerchoice);
%else
%    layerchoice = 11;
end

if(exist('centerprior', 'var'))
    centerprior = str2num(centerprior);
%else
%    centerprior = 6;
end 

if(exist('resizeheight', 'var'))
    resizeheight = str2num(resizeheight);
%else
%    resizeheight = 30;
end

if(exist('usepca', 'var'))
    usepca = str2num(usepca);
else
    usepca = 0;
end

a = dir(sprintf('%s/*.jpg', dirname));
fprintf('Found %d image files.\n', numel(a));
cue = cell(numel(a), 1);
batch_fns = cell(numel(a), 1);
cueMatrixCreated = false;
for i = 1:numel(a)
    fn = a(i).name;
    filenames{i} = fn;
    if(nargin < 2)
        fv = extractAggregatedHypercolumns_zoning(strcat(dirname, '/', fn));
    else
        fv = extractAggregatedHypercolumns_zoning(strcat(dirname, '/', fn), modelchoice, layerchoice, centerprior, resizeheight);
    end
    nDims = numel(fv);
    if(~cueMatrixCreated)
        cue = zeros(1, nDims);
        cueMatrixCreated = true;
    end
    cue(i, :) = fv;
end
if(usepca ~= 0)
    cueBig = cue;
    [~, cue, latent] = princomp(cueBig);
    newDims = findBestDims(cumsum(latent)./sum(latent));
    fprintf('Choosing new number of dimensions = %d (out of %d)\n', newDims, nDims);
    nDims = newDims;
    cue = normRows(cue(:, 1:nDims));
end
if nargout == 0
    % Write to file
    dimsFileID = fopen('dimensions.txt','w');
    fprintf(dimsFileID, '%d\n', nDims);
    fclose(dimsFileID);
    dlmwrite('distance.txt', cue, 'delimiter', ' ');
    fid = fopen('filenames.txt','wt');    
    for i=1:numel(filenames)
        fprintf(fid,'%s\n',filenames{i});
    end
    fclose(fid);
    fprintf('Create files: dimensions.txt, distance.txt, filenames.txt\n');
    fprintf('Wrote %d descriptors of %d dimensions\n', size(cue, 1), size(cue, 2));
end
return;

function res = findBestDims(x)
for i = 1:numel(x)
    if(x(i) >= .98)
        res = i;
        return;
    end
end
res = numel(x);
return;

function res = normRows(tt)
%L2-Normalizes all rows of matrix x
d = size(tt, 2);
res = tt ./ ( (sqrt(sum(tt .* tt, 2))+eps) * ones(1, d));
return;