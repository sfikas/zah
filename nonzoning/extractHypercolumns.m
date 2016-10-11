function [hypercolumn act nn] = extractHypercolumns(imfn, modelchoice, layers2use, centerprior, resizeheight)
% 
% Arguments:
%   modelchoice
%           0           Use unigrams        charnet_layers.mat
%           1           Use bigrams         bigramsvtnet_layers.mat      
%           2           Use both
% layerchoice:  Choose layers to use.
%               'Appropriate' layers are 3(conv), 6(conv), 11(fc), 16(softmax).
% centerprior:  Prior that makes pixels near the center row
%               more important. Input is the Gaussian precision
%               (default: 0, ie no smoothing)
% resizeheight: Resize word image to this height (default: 30)
%
%   Example:
%           h = extractHypercolumns('data/cropim.jpg', 2, [6]);
%               This will return a 30xcolsxdims feature map.
%               It comprises info from both unigram & bigram models.
%               It uses their respective last conv layers (layer 6).
%           h = extractHypercolumns('data/cropim.jpg', 0, [3 6 11]);
%               Will use the unigram model only + concat all hidden layers.
%
% G.Sfikas Apr 2016
if(~exist('resizeheight', 'var'))
    resizeheight = 30;
end

co_layers = [3 6];  %convolutional layers
%fc_layers = [11 16];%convolutionalized fully-connected layers
if(~exist('layers2use', 'var'))
    layers2use = co_layers(end); %use only the last convolutional layer activation
end
%[curdir, ~, ~] = fileparts(mfilename('fullpath'));
if(modelchoice == 0)
    modeldata = 'pretrained/models/charnet_layers.mat';    
    %modeldata = sprintf('%s/../models/charnet_layers.mat', curdir);
elseif(modelchoice == 1)
    modeldata = 'pretrained/models/bigramsvtnet_layers.mat';    
    %modeldata = sprintf('%s/../models/bigramsvtnet_layers.mat', curdir);
elseif(modelchoice == 2)
    [h0, act0] = extractHypercolumns(imfn, 0, layers2use, centerprior, resizeheight);
    [h1, act1] = extractHypercolumns(imfn, 1, layers2use, centerprior, resizeheight);
    hypercolumn = cat(3, h0, h1);
    act = [act0 act1];
    return;
else
    error('modelchoice: Argument error.');
end
if(~exist('centerprior', 'var'))
    centerprior = 0;
end
if(centerprior ~= 0)
    blurwin = gausswin(resizeheight, centerprior);
else
    blurwin = ones(resizeheight, 1);
end
if(ischar(imfn))
    im = imread(imfn);
else
    im = imfn;
end
if(numel(size(im)) == 3)
    img = single(rgb2gray(im));
else
    img = single(im);
end
[wimg, ~] = simple_gray_normalize_p(double(img), 1.5, 1);
img = single(255*wimg);
rows = resizeheight; %this is related to the specifics of the pretrained CNN
img = imresize(img, [rows NaN]); %resize to resizeheight(default:3O) rows, preserve the aspect ratio
cols = size(img, 2); %will need this to resize (? or not?)
img = padarray(img, [11 11]);
winsz = 24;
mu = (1/winsz^2) * conv2(img, ones(winsz, winsz, 'single'), 'same');
x_ = (img - mu).^2;
stdim = sqrt((1/winsz^2) * conv2(x_, ones(winsz, winsz, 'single'), 'same'));
data = img - mu;
eps = 1e-9;
data = data ./ (stdim + eps);
nn = cudaconvnet_to_mconvnet(modeldata);
nn = nn.forward(nn, struct('data', data));
%
act = cell(numel(layers2use, 1));
for i = 1:numel(layers2use)
    currentLayer = layers2use(i);
    %act(:, :, i) = zeros(rows, cols);
    actMap = nn.layers{currentLayer}.Xout;
    sz = size(actMap);
    if(sz(1) < rows)
        actMap = imresize(actMap, [rows NaN]);
        sz = size(actMap);        
    end
    if(sz(2) < cols)
        actMap = imresize(actMap, [sz(1) sz(2)]);
        sz = size(actMap);
    end
    startP = floor(.5*(sz(1) - rows));
    cropping = actMap((startP + 1):(startP + rows), (startP + 1):(startP + cols), :);
    blurwinrepeated = repmat(blurwin*ones(1, size(cropping, 2)), [1 1 size(cropping, 3)]);
    cropping = cropping .* blurwinrepeated;
    act{i} = cropping;
end
hypercolumn = act{1};
for i = 2:numel(act)
    hypercolumn = cat(3, hypercolumn, act{i});
end
return;
