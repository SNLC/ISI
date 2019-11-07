function reset_imstate

global imstate kmap_hor kmap_vert f1m bw 

imstate.fmaps{1} = kmap_hor;
imstate.fmaps{2} = kmap_vert;
imstate.sigMag = abs(f1m{1}) + abs(f1m{2});
imstate.bw = bw;

imstate.imfunc = kmap_hor;
imstate.mag = bw;
imstate.imanat = ones(size(bw));