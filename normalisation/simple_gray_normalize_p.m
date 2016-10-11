function [In,mh] = simple_gray_normalize_p(I,r,preproc)

if preproc == 1
% basic binarization
[Ig,cnt] = illumination_norm(I);
if (cnt < 200)
    In = Ig; mh = 0;
    return;
end
elseif preproc == 2
Ig = I;
Ig = 1 - (Ig-min(min(Ig)))/(max(max(Ig))-min(min(Ig)));    
else 
Ig = I;
end

% main region
proj = sum(Ig,2);

N = sum(proj);
K = numel(proj);
P = cumsum(proj);
[~,md] = min(abs(P-N/2));


sp = zeros(size(P));
sp(1:md) = sp(1:md) + proj(md:-1:1);
sp(1:(K-md)) = sp(1:(K-md)) + proj(md+1:K);

[~,ms] = min(abs(cumsum(sp)-.75*N));

rotations = (-4:2:4);
tr = -2:1:8;
lwa = zeros(1,numel(rotations)); upa = zeros(size(lwa)); score = zeros(size(lwa));
for i = 1:numel(rotations)
    Ir = imrotate(Ig,rotations(i),'bilinear');
    [lwa(i),upa(i),score(i)] = find_main_region(sum(Ir,2),ms+5,tr);   
end

[~,mi] = max(score);
lw = lwa(mi);
up = upa(mi);
%a = tand(rotations(mi));

Ir = imrotate(Ig,rotations(mi),'bilinear');
[h,w] = size(Ir);

m = r*(lw-up);
v_up = round(m - up);
if v_up >= 0
    pad_up = round(v_up);
    i_up = 1;
else 
    pad_up = 0;
    i_up = -v_up;
end
    
v_lw = round(m + lw - h);
if v_lw >= 0
    pad_lw = round(v_lw);
    i_lw = h;
else 
    pad_lw = 0;
    i_lw = h+v_lw;
end


In = Ir(i_up:i_lw,:);
pad_l =0;%max(0,max_x-max(cx-X));
pad_r =0;%max(0,max_x-max(X-cx));
In = padarray(In,[pad_up pad_l],0,'pre');
In = padarray(In,[pad_lw pad_r],0,'post');

mh = lw-up;

%{
figure(1); imshow(In,[]); hold on;
x = 1:size(Ir,2);
plot(x,r*mh,'g','linewidth',5);hold on;
plot(x,(r+1)*mh,'r','linewidth',5);hold off;
%}

%{
In = In/max(max(In));
rimg = zeros([size(In) 3]);
rimg(:,:,1) = In;
rimg(:,:,2) = In;
rimg(:,:,3) = In;

rimg(round((r+1)*mh),:,1) = 1; %rimg(round((r+1)*mh),:,[2,3]) = 0;
rimg(round((r)*mh),:,2) = 1; %rimg(round((r)*mh),:,[1,3]) = 0;
imwrite(rimg,'example.png');
%}

%{
figure(1);
subplot(2,2,1);imshow(I,[]);
subplot(2,2,2);imshow(bw,[]);
subplot(2,2,3);imshow(Ir,[]);
subplot(2,2,4);imshow(In,[]);
%}
end

function [lw,up,score] = find_main_region(proj,ms,tr)


N = sum(proj);
K = numel(proj);

for kk = 1:numel(tr)
l = .5*(1/(ms+tr(kk)));

% dynamic programming

%{
P = proj/N - l;


tempSum = P(1);
score = 0;
lw = 1 ; up = 1;
for i = 2:K
    if (tempSum>P(i))
        tempSum = tempSum + P(i);
    else
        tempSum = P(i);
        up = i;
    end
    if (tempSum >score)
        score = tempSum;
        lw = i;
    end
end
%}

P = cumsum(proj)/N - l*(1:K)';

tscore = P(2) - P(1);
minv = P(1);
for i = 2:K     
    if (P(i) - minv > tscore)                              
      tscore = P(i) - minv;
      tlw = i;
    end
    if (P(i) < minv)
         minv = P(i);
    end
end
if ~exist('tlw','var')
    tlw = N;
    tup = 1;
else
    [~,tup] = max(P(tlw)-P(1:tlw));
end    

score(kk) = tscore;
up(kk) = tup;
lw(kk) = tlw;

clear tlw tup;
end

score = median(score);
up = median(up);
lw = median(lw);

end

