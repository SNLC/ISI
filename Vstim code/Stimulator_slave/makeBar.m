function barout = makeBar(Wx,Wy,ori)

%Wx,Wy are the size of the bar in pixels (hasn't yet corrected for different x,y resolutions)

domy = linspace(0,2*max([Wx Wy]),round(2*max([Wx Wy])));
domx = linspace(0,2*max([Wx Wy]),round(2*max([Wx Wy])));
domx = domx-median(domx);
domy = domy-median(domy);

[domx domy] = meshgrid(domx,domy);

xp = domx*cos(-ori*pi/180) + domy*sin(-ori*pi/180);
yp = domx*sin(-ori*pi/180) - domy*cos(-ori*pi/180);

idx = find(xp <= Wx/2 & xp >= -Wx/2  &  yp <= Wy/2 & yp >= -Wy/2);

temp = zeros(size(domx));
temp(idx) = 1;

[domx domy] = meshgrid(1:length(domx(1,:)),1:length(domx(:,1)));

idxmin = min(domx(idx)); idxmin = idxmin(1);
idxmax = max(domx(idx)); idxmax = idxmax(1);
idymin = min(domy(idx)); idymin = idymin(1);
idymax = max(domy(idx)); idymax = idymax(1);

barout = temp(idymin:idymax,idxmin:idxmax);