global f0m1  %ProcessF0 made this.  Now do the rest...


%Low contrast - high contrast response 
Im = (f0m1{1} - f0m1{8})./(f0m1{1} + f0m1{8}); 

%make the filter
dim = size(Im);
[x y] = meshgrid(1:dim(2),1:dim(1));
x = x-dim(1)/2;
y = y-dim(2)/2;
r = sqrt(x.^2 + y.^2);
sig = 1;
h = exp(-r.^2/(2*sig^2));
h = h/sum(h(:));
ImF = ifft2(fft2(Im).*abs(fft2(h))); %filter it


%%%Get the region of interest
figure,imagesc(ImF), colormap gray  %plot it
bw = roipoly;
%%%%


%%%Get the region of interest
figure,imagesc(Im), colormap gray  %plot it
bw = roipoly;


%%%%
id = find(bw(:));
mi = min(Im(id));
ma = max(Im(id));
figure,imagesc(Im,[mi ma]), colormap jet, colorbar



%Plot it
id = find(bw(:));
mi = min(ImF(id));
ma = max(ImF(id));
figure,imagesc(ImF,[mi ma]), colormap jet, colorbar
