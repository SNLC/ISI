function imout = plotmap(im,rng,pixpermm)

%This assumes that the zeros are the background

mmperpix = 1/pixpermm;
xdom = (0:size(im,2)-1)*mmperpix;
ydom = (0:size(im,1)-1)*mmperpix;

bg = ones(size(im));
bgid = find(im == 0);
bg(bgid) = 0;

im(find(im>rng(2))) = rng(2);
im(find(im<rng(1))) = rng(1);

im(1,1) = rng(1);
im(1,2) = rng(2);

im = im-rng(1);
im = im/(rng(2)-rng(1));

im = round(im*63+1);

im(1,1) = 1;
im(1,2) = 64;

im(bgid) = NaN;

dim = size(im);
jetid = jet;
imout = zeros(dim(1),dim(2),3);
for i = 1:dim(1)
    for j = 1:dim(2)
        
        if isnan(im(i,j))
            imout(i,j,:) = [1 1 1];
        else
            imout(i,j,:) = jetid(im(i,j),:);
        end
    end
end


image(xdom,ydom,imout), axis image

eccdom = round((linspace(rng(1),rng(2),5)).^2*10000)/10000;


for i = 1:length(eccdom)
    domcell{i} = eccdom(i);
end
iddom = linspace(1,64,length(eccdom));
colorbar('YTick',iddom,'YTickLabel',domcell)
