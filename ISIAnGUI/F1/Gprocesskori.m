function [kmap delay] = Gprocesskori(f1,bw,hh)

%f1 is a cell containing the result from 'f1meanimage'.  Each of the images
%are smoothed with a Gaussian with a std dev of 'stdev' and a width of
%'width'.

ang0 = f1{1};
ang1 = f1{2}; 

ang0 = ang0*exp(-j*180*pi/180);
ang1 = ang1*exp(-j*180*pi/180);


if ~isempty(hh)
    h = varargin{1};
    ang1 = angle(roifilt2(h,-ang1,bw,'same'));
    ang0 = angle(roifilt2(h,-ang0,bw,'same'));
else
    ang1 = angle(-ang1);
    ang0 = angle(-ang0);
end

%Find delay as the angle between the vectors
delay = angle(exp(j*ang0) + exp(j*ang1));

%Make delay go from 0 to pi and 0 to pi, instead of 0 to pi and 0 to -pi.
delay = delay + pi/2*(1-sign(delay));

%Use delay vector to calculate orientation.
kmap = .5*(angle(exp(j*(ang0-delay))) - angle(exp(j*(ang1-delay))));

%radians to degrees
delay = delay*180/pi.*bw;
kmap = kmap*180/pi.*bw;

