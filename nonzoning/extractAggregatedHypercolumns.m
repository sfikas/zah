function res = extractAggregatedHypercolumns(im, modelchoice, layerchoice, centerprior, resizeheight)
% This function returns aggregations of hypercolumn features.
% Aggregation-encoding is done with sum-pooling and l2 normalization.
%
% modelchoice:  Can be 0, 1 or 2 (default: 2)
% layerchoice:  Choose layers to use (default: [3 6])
%               'Appropriate' layers are 3(conv), 6(conv), 11(fc), 16(softmax).
% centerprior:  Prior that makes pixels near the center row
%               more important. Input is the Gaussian precision
%               (default: 0, ie no smoothing)
%
% G.Sfikas 25 Apr 2016
if(~exist('modelchoice', 'var'))
    modelchoice = 2;
end
if(~exist('layerchoice', 'var'))
    layerchoice = [3 6];
end
if(~exist('centerprior', 'var'))
    centerprior = 0;
end
if(~exist('resizeheight', 'var'))
    resizeheight = [24 30 36];
end
h = extractHypercolumns(im, modelchoice, layerchoice, centerprior, resizeheight(1));
dims = size(h, 3);
baselength = size(h, 2);
%Variable length
a = squeeze(mean(h, 1));
for height = 2:numel(resizeheight)
    assert(resizeheight(height) > resizeheight(1));
    h = extractHypercolumns(im, modelchoice, layerchoice, centerprior, resizeheight(height));
    squeeze_h = squeeze(mean(h, 1));
    a = a + imresize(squeeze_h, [baselength dims], 'nearest');
end
%L2 normalization
res = a ./ (sqrt(sum(a .* a, 2)) * ones(1, dims));
return;