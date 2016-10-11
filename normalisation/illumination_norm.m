function [Ig,cnt] = illumination_norm(I)

[bw,I] = mySauvola(double(I),80,.1);
cnt = sum(sum(bw));
bw = bwareaopen(bw,20);

I(~bw) = 1.8*I(~bw);
Ig = I;
Ig = 1 - (Ig-min(min(Ig)))/(max(max(Ig))-min(min(Ig)));
