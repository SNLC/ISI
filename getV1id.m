function [V1id ids V1map] = getV1id(im)

imlabel = bwlabel(im,4);
imdom = unique(imlabel);
clear Sqmm
for q = 1:length(imdom)-1
    Sqmm(q) = length(find(imlabel == q))/(39^2); %cortical area coverage
end
[dum V1id] = max(Sqmm);
ids = find(imlabel == V1id);

V1map = zeros(size(im));
V1map(ids) = 1;