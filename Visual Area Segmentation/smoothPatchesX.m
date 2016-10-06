function mapout = smoothPatchesX(map,im)

imlab = bwlabel(im,4); 
imdom = unique(imlab);

map(find(1-im)) = 45;

mapout = map;

SE = strel('disk',2,0);
for q = 1:length(imdom)-1 %loop through each patch ("visual area")

    idpatch = find(imlab == q );
    
    impatch = zeros(size(map));
    impatch(idpatch) = 1;
%     impatch = imdilate(impatch,SE);

%     L(q) = sqrt(length(idpatch));    
%     sig = L(q)/20;
    
    L(q) = length(idpatch);    
    sig = L(q)/2000;
    
    hh = fspecial('gaussian',size(map),sig);
    mapout = roifilt2(hh,mapout,impatch);
    
end
