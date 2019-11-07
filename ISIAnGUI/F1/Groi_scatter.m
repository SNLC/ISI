function [R dimv] = Groi_scatter(im1,im2,bw,angflag,oriflag)
%Make scatter plot and return corr coef for chosen region of interest. 
%angflag set to 1 computes for angular variables.
%oriflag set to 1 assumes the values are in orientation domain (0:180),
%(0:360 otherwise).

bwv = reshape(bw,prod(size(bw)),1);
unos = find(bwv == 1);    %Find ROI indices

imv1 = reshape(im1,prod(size(im1)),1);  %Reshape the same way as ROI
imv2 = reshape(im2,prod(size(im2)),1);

imv1 = imv1(unos);      %Extract values in ROI
imv2 = imv2(unos);

if angflag == 1
    if oriflag == 1
        R = cxcorr(imv1,imv2,180);      %Compute correlation of ori domain variables
        [imv1 imv2] = circscat(imv1,imv2);
    else
        R = cxcorr(imv1,imv2,360);      %Compute correlation of 0:360 variables (e.g. phase)
        [imv1 imv2] = circscat(imv1/2,imv2/2);
        imv1 = imv1*2;
        imv2 = imv2*2;
    end
else
    R = corrcoef(imv1,imv2);
    R = R(1,2);
end

scatter(imv1,imv2,'.')
dimv = imv1-imv2;
ind = find(abs(dimv)<50);
std(dimv(ind));
%figure,hist(dimv(ind),10);

function [im1 im2] = circscat(im1,im2);

im1 = im1-90;
im2 = im2-90;
amask1 = .25*(1+sign(im1)).*(sign(abs(im1)-45)+1);  %Top AND Left = Quadrant 2 (90 to 180)
amask2 = .25*(sign(im1)-1).*(sign(abs(im1)-45)+1);  %Bottom AND Left = Quadrant 3 (-90 to -180)
amask3 = amask1+amask2;       %Positives are quadrant 2, Neg are 3. 

bmask1 = .25*(1+sign(im2)).*(sign(abs(im2)-45)+1); %Quadrant 2
bmask2 = .25*(sign(im2)-1).*(sign(abs(im2)-45)+1); %Quadrant 3
bmask3 = bmask1+bmask2;       %Positives are quadrant 3, Neg are 2.

mask = -ceil(.5*(amask3.*bmask3 - 1));     %1's are the culprit
amask = -mask.*amask2*180;  %AND w/ 3rd quadrant 

bmask = -mask.*bmask2*180;

im1 = im1 + amask + 90 ; 
im2 = im2 + bmask + 90;

