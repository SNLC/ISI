function [CoMxy Axisxy] = getPatchCoM(imseg)

%gets the center of mass and principle axis of all patches in image

imlabel = bwlabel(imseg,4);

areaID = unique(imlabel);

xdom = 1:size(imseg,2);
ydom = 1:size(imseg,1);

for i = 1:length(areaID)-1
    
    id = find(imlabel == i);
    temp = zeros(size(imseg));
    temp(id) = 1;
    
    tempx = sum(temp,1);
    CoMxy(i,1) = sum(tempx.*xdom)/sum(tempx);
    tempy = sum(temp,2)';
    CoMxy(i,2) = sum(tempy.*ydom)/sum(tempy);
    
    [xgrid ygrid] = meshgrid(xdom-CoMxy(i,1),ydom-CoMxy(i,2));
    rdom = sqrt(xgrid.^2 + ygrid.^2);   
    ang = atan2(ygrid,xgrid);
    Res = rdom.*temp.*exp(1i*ang*2)/sum(temp(:));
    Res = sum(Res(:));
    prefAng = angle(Res)*180/pi/2;
    prefMag = abs(Res)*2;
    Axisxy(i,1) = prefMag*cos(prefAng*pi/180);
    Axisxy(i,2) = prefMag*sin(prefAng*pi/180);
    
    %If the patch is curved the CoM will not be on the patch, which screws
    %things up later
    if imlabel(round(CoMxy(i,2)),round(CoMxy(i,1))) ~= i
        [y x] = find(rdom == min(rdom(find(temp))));
        CoMxy(i,1) = x; CoMxy(i,2) = y; %Take patch location that is shortest distance to CoM
    end
    
end
