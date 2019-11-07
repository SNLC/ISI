function out = Locstd(piece)

dim = size(piece);
mid = ceil(dim(1)/2);

[x y] = meshgrid(1:dim(1),1:dim(1));
r = sqrt((x-mid).^2 +(y-mid).^2);
id = find(r<=mid);
out = std(piece(id));