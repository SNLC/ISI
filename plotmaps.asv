

global kmap_hor kmap_vert bw f1m magS


%%

mag = magS.hor;
ang = kmap_hor;

%mag = log(mag);
% mag = medfilt2(mag,[3 3]);

h = fspecial('gaussian',size(mag),.1);
h = abs(fft2(h));
magf = ifft2(h.*fft2(mag));

mag = magf.^1;
mag = mag-min(mag(:));
mag = mag/max(mag(:));

% 
thresh = .15;
id = find(mag(:)<thresh);
mag(id) = 0;

ang = fliplr(ang);
mag = fliplr(mag);
ang = rot90(ang);
mag = rot90(mag);
figure(29),imagesc(ang,'AlphaData',mag),colormap hsv