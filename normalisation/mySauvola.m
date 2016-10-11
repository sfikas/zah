function [bw,nimg] = mySauvola(img,ws,k)


h = ones(ws);
h = h/numel(h);

% Mean value
mean = imfilter(img,h,'replicate');

% Standard deviation
mean2 = imfilter(img.^2,h,'replicate');
deviation = (mean2 - mean.^2).^0.5;

% Sauvola
R = max(deviation(:));
threshold = mean.*(1 + k * (deviation / R-1));
bw = (img > threshold);
bw = bwareaopen(~bw,20);

% extra bbox ;
if 0
    [Y,X] = find(bw == 1);
    bw = bw(min(Y):max(Y),min(X):max(X));
    nimg = img(min(Y):max(Y),min(X):max(X));
else
    nimg = img;
end
% Niblack
%offset = 10;
%bw = img > (mean + k * deviation - offset) ;