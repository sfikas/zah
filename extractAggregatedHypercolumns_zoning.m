function res = extractAggregatedHypercolumns_zoning(im, modelchoice, layerchoice, centerprior, resizeheight)
% extractAggregatedHypercolumns_zoning
%
% Extracts Zoning-Aggregated Hypercolumns (ZAH)
%
% G.Sfikas 29 Apr 2016

if(~exist('modelchoice', 'var'))
    %modelchoice = 0;
    modelchoice = 1;
end
if(~exist('layerchoice', 'var'))
    layerchoice = 11;
end
if(~exist('centerprior', 'var'))
    %centerprior = 0;
    centerprior = 6;
end
if(~exist('resizeheight', 'var'))
    resizeheight = 30;
end
chunks = 6;
h = extractHypercolumns(im, modelchoice, layerchoice, centerprior, resizeheight(1));
%dims = size(h, 3);
a = sumpoolAndNormalizePerChunk(h, chunks);
for height = 2:numel(resizeheight)
    assert(resizeheight(height) > resizeheight(1));
    h = extractHypercolumns(im, modelchoice, layerchoice, centerprior, resizeheight(height));
    a = [a; sumpoolAndNormalizePerChunk(h, chunks)];
end
%L2 normalization for the whole descriptor
%(a is a single vector, corresponding to the whole image)
res = a / norm(a);
return;

function res = sumpoolAndNormalizePerChunk(inmap, chunks)
% This calculates aggregated features per chunk(zone), l2-normalizes them,
% and concatenates them.
%
% inmap         Map of size HxWxdims
% chunks        Split the map (width) in this number of chunks
w = size(inmap, 2);
dims = size(inmap, 3);
chunksize = w / chunks;
chunkstartpixel = zeros(chunks+1, 1);
chunkstartpixel(1) = 1;
for c = 2:chunks
    chunkstartpixel(c) = round(chunksize*(c-1));
    if(chunkstartpixel(c) >= w)
        chunkstartpixel(c) = w-1;
    end
end
chunkstartpixel(end) = w+1; %start of fake c+1 th chunk
res = [];
overlap_size = round(.25*chunksize);
for c = 1:chunks
    meros_start = rectify(chunkstartpixel(c) - overlap_size, w);
    meros_end = rectify(chunkstartpixel(c+1)-1 + overlap_size, w);
    meros = inmap(:, meros_start:meros_end, :);
    if(isempty(meros))
        meros = zeros(1, 1, dims);
    end
    d = squeeze(sum(sum(meros, 1), 2));
    desc = d / norm(d); %L2-normalize chunk
    res = [res; desc(:)];
end
res = res / norm(res);
return;

function res = rectify(x, maxwidth)
res = x;
if(x < 1)
    res = 1;
end
if(x > maxwidth)
    res = maxwidth;
end
return;