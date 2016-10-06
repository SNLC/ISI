function [kmap_hor kmap_vert delay_hor delay_vert magS ang0 ang1 ang2 ang3] = Gprocesskret_generatekmaps(f1,bw,hl,hh)

%f1 is a cell containing the result from 'f1meanimage'.  varargin is the optional
%filter kernel.  Each of the images are smoothed with a Gaussian with a std 
%dev of 'stdev' and a width of 'width'.

ang1 = f1{2}; %two axes
ang3 = f1{4}; 
ang0 = f1{1};
ang2 = f1{3};

% ang1 = f1{1}; %for one axis
% ang3 = f1{2}; 
% ang0 = f1{1};
% ang2 = f1{2};


% ang0 = ang0*exp(-1i*180*pi/180);
% ang1 = ang1*exp(-1i*180*pi/180);
% ang2 = ang2*exp(-1i*180*pi/180);
% ang3 = ang3*exp(-1i*180*pi/180);

%The negative is to show where it peeks in the range of -180 to 180.
%i.e. -180 is the left most side of the stimulus.  Without the negative,
%an angle of -180 would have been the middle of the stimulus.
%angle(FourierTX(cos(wt-0))) == 0

if ~isempty(hh) %high pass filter
    ang1 = roifilt2(hh,ang1,bw,'same');
    ang3 = roifilt2(hh,ang3,bw,'same');
    ang0 = roifilt2(hh,ang0,bw,'same');
    ang2 = roifilt2(hh,ang2,bw,'same');
end
 
if ~isempty(hl) %else use standard smoothing
    ang1 = roifilt2(hl,-ang1,bw,'same');
    ang3 = roifilt2(hl,-ang3,bw,'same');
    ang0 = roifilt2(hl,-ang0,bw,'same');
    ang2 = roifilt2(hl,-ang2,bw,'same');
    
    mag1 = abs(ang1);
    mag3 = abs(ang3);
    mag0 = abs(ang0);
    mag2 = abs(ang2);
    magS.hor = (mag0+mag2)/2;
    magS.vert = (mag1+mag3)/2;
    
    ang1 = angle(ang1);
    ang3 = angle(ang3);
    ang0 = angle(ang0);
    ang2 = angle(ang2);
    
else %dont do anything, no LP filter
    mag1 = abs(ang1);
    mag3 = abs(ang3);
    mag0 = abs(ang0);
    mag2 = abs(ang2);
    magS.hor = (mag0+mag2)/2;
    magS.vert = (mag1+mag3)/2;
    
    ang1 = angle(-ang1);
    ang3 = angle(-ang3);
    ang0 = angle(-ang0);
    ang2 = angle(-ang2);
end


%Find delay as the angle between the vectors
delay_hor = angle(exp(1i*ang0) + exp(1i*ang2));
delay_vert = angle(exp(1i*ang1) + exp(1i*ang3));

%Make delay go from 0 to pi and 0 to pi, instead of 0 to pi and 0 to -pi.
%The delay can't be negative.  If the delay vector is in the bottom two
%quadrants, it is assumed that the it started at -180.  The delay always
%pushes the vectors counter clockwise.
delay_hor = delay_hor + pi/2*(1-sign(delay_hor));
delay_vert = delay_vert + pi/2*(1-sign(delay_vert));

%Use delay vector to calculate retinotopy.
kmap_hor = .5*(angle(exp(1i*(ang0-delay_hor))) - angle(exp(1i*(ang2-delay_hor))));
kmap_vert = .5*(angle(exp(1i*(ang1-delay_vert))) - angle(exp(1i*(ang3-delay_vert))));

%radians to degrees
delay_hor = delay_hor*180/pi.*bw;
kmap_hor = kmap_hor*180/pi.*bw;
delay_vert = delay_vert*180/pi.*bw;
kmap_vert = kmap_vert*180/pi.*bw;
% 
% %Create shadow of ROI coverage.
% x = bw.*floor(100/360*(kmap_hor+180))+1;
% y = bw.*floor(100/360*(-kmap_vert+180))+1;
% sh = shadow(x,y,100,100);

