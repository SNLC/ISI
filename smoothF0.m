Im = f0m1{1} - f0m1{2};
id = find(bw);
mi = min(Im(id));
ma = max(Im(id));
figure,imagesc(Im,[mi ma])
colormap gray
configdisplaycom


dim = size(Im);
[x y] = meshgrid(1:dim(2),1:dim(1));
x = x-dim(1)/2;
y = y-dim(2)/2;
r = sqrt(x.^2 + y.^2);
sig = 2;
h = exp(-r.^2/(2*sig^2));
h = h/sum(h(:));

imF = ifft2(fft2(Im).*abs(fft2(h)));

id = find(bw);
mi = min(imF(id));
ma = max(imF(id));

figure,imagesc(imF,[mi ma]), colormap gray
