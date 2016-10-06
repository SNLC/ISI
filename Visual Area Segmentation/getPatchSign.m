function [patchSign areaSign] = getPatchSign(im,imsign)

imlabel = bwlabel(im,4);
areaID = unique(imlabel);
patchSign = zeros(size(imlabel));
for i = 2:length(areaID)
   id = find(imlabel == areaID(i));
   m = mean(imsign(id));
   areaSign(i-1) = sign(m);
   patchSign(id) = sign(m)+1.1;
end
