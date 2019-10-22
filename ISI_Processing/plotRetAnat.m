
hh = zeros(dim);
hh(1:3,1:3) = ones(3,3);
mapfilt = ifft2(fft2(f1m{1}).*abs(fft2(hh)));
figure,imagesc(angle(mapfilt))

mag = abs(mapfilt);
ang = angle(f1m{1});


imanat = Im;
imanat = imanat-min(imanat(:));
imanat = imanat/max(imanat(:));


imfunc = ang;
imfunc = imfunc-min(imfunc(:));
imfunc = imfunc/max(imfunc(:));
imfunc = round(imfunc*63+1);
imanat = round(imanat*63+1);
gi
grayid = gray;
jetid = jet;

mag = mag-min(mag(:));
mag = mag/max(mag(:));
mag(~bw) = 0;



dim = size(Im);

for i = 1:dim(1)
    for j = 1:dim(2)
   
        imout(i,j,:) = 2*mag(i,j)*jetid(imfunc(i,j),:).^3 + grayid(imanat(i,j),:);
        
    end
end


 imout = imout/max(imout(:));
 
 figure,image(imout)