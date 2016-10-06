function im = splitPatchesX(im,kmap_hor,kmap_vert,kmap_rad,pixpermm)

figTag = 0; % if you'd like to see figures along the way

xsize = size(kmap_hor,2)/pixpermm;  %Size of ROI mm
ysize = size(kmap_hor,1)/pixpermm; 
xdum = linspace(0,xsize,size(kmap_hor,2)); ydum = linspace(0,ysize,size(kmap_hor,1)); 
[xdom ydom] = meshgrid(xdum,ydum); %two-dimensional domain

kmap_rad = smoothPatchesX(kmap_rad,im); %smooth the larger patches

hh = fspecial('gaussian',size(kmap_hor),2);
kmap_horS = ifft2(fft2(kmap_hor).*abs(fft2(hh)));
kmap_vertS = ifft2(fft2(kmap_vert).*abs(fft2(hh)));

[dhdx dhdy] = gradient(kmap_horS);
[dvdx dvdy] = gradient(kmap_vertS);
Jac = (dhdx.*dvdy - dvdx.*dhdy)*pixpermm^2; %deg^2/mm^2  %magnification factor is determinant of Jacobian

%%%Make Interpolated data to construct the visual space representations%%%
dim = size(kmap_horS);
U = 3;
xdum = linspace(xdom(1,1),xdom(1,end),U*dim(2)); ydum = linspace(ydom(1,1),ydom(end,1),U*dim(1));
[xdomI ydomI] = meshgrid(xdum,ydum); %upsample the domain
kmap_horI = round(interp2(xdom,ydom,kmap_horS,xdomI,ydomI,'spline'));
kmap_vertI = round(interp2(xdom,ydom,kmap_vertS,xdomI,ydomI,'spline'));
kmap_radI = round(interp2(xdom,ydom,kmap_rad,xdomI,ydomI,'spline'));

[dhdx dhdy] = gradient(kmap_horI);
[dvdx dvdy] = gradient(kmap_vertI);
JacI = (dhdx.*dvdy - dvdx.*dhdy)*(pixpermm*U)^2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SE = strel('disk',1,0);
im = imopen(sign(im),SE);
imlab = bwlabel(im,4); 
imdom = unique(imlab);

SE = strel('disk',1,0);
im = imerode(sign(im),SE);

sphdom = -90:90;  %create the domain for the sphere
[sphX sphY] = meshgrid(sphdom,sphdom);

%% Find patches to 'split'
clear spCov

R = 30; %Find local min within central 30 deg

%%%%First limit patches to a certain eccentricity, R
imlab = bwlabel(im,4); 
imdom = unique(imlab);
centerPatch = getCenterPatch(kmap_rad,im,R);
for q = 1:length(imdom)-1 %loop through each patch ("visual area")    
    im = resetPatch(im,centerPatch,imlab,q);       
end

imI = round(interp2(xdom,ydom,im,xdomI,ydomI,'nearest')); %interpolate to be the same size as the maps

%%%%%Now proceed with splitting based on no. of minima
imlab = bwlabel(im,4); 
imdom = unique(imlab);

imlabI = bwlabel(imI,4); 

centerPatch = getCenterPatch(kmap_rad,im,R);
centerPatchI = getCenterPatch(kmap_radI,imI,R);

for q = 1:length(imdom)-1 %loop through each patch ("visual area")
    
    idpatch = find(imlab == q & centerPatch);        
    dumpatch = zeros(size(im));
    dumpatch(idpatch) = 1;
    
    idpatchI = find(imlabI == q & centerPatchI);   
    dumpatchI = zeros(size(imI));
    dumpatchI(idpatchI) = 1;

    
    %figure,imagesc(dumpatch)
    
    Nmin = 1;
    if ~isempty(find(idpatch))
        
        
        %%Determine if it has a overlapping representation of visual space%%%%%%

        [spCov JacCoverage ActualCoverage MagFac] = overRep(kmap_horI,kmap_vertI,U,JacI,dumpatchI,sphdom,sphX,pixpermm);
        CovOverlap = JacCoverage/ActualCoverage;

        
        if CovOverlap > .999
            
            %figure, imagesc(dumpatch)
            
            hor_cent = median(kmap_hor(find(dumpatch)));
            vert_cent = median(kmap_vert(find(dumpatch)));
            
            kmap_rad_cent = sqrt((kmap_hor-hor_cent).^2 + (kmap_vert-vert_cent).^2);
            
            kmap_rad_dum = zeros(size(kmap_rad));
            kmap_rad_dum(idpatch) = kmap_rad_cent(idpatch);

            [Nmin minpatch centerPatch2 Rdiscrete] = getNlocalmin(idpatch,R,kmap_rad_dum);

            [im splitflag Nsplit] = resetPatch(im,centerPatch2,imlab,q);
        end

    end


    if Nmin > 1
        id = find(imlab == q);
        dumpatch = zeros(size(im)); dumpatch(id) = 1;

        if figTag == 1;
            figure,
            subplot(1,3,1), ploteccmap(dumpatch.*kmap_rad_cent,[0 45],1,pixpermm);
            title('Smoothed eccentricity map'), colorbar off
            ylabel('mm'), xlabel('mm')
            
            id = find(Rdiscrete == median(Rdiscrete(:))); Rdiscrete(id) = 0;
            subplot(1,3,2), ploteccmap(dumpatch.*Rdiscrete,[0 45],1,pixpermm);
            hold on, contour(xdom,ydom,minpatch,[.5 .5],'k')
            title(['Discretized map; ' num2str(Nmin) ' minima found']), colorbar off
            
            subplot(1,3,3), ploteccmap(dumpatch.*kmap_rad_cent.*im,[0 45],1,pixpermm);
            title('Flood the patch with watershed')
        end

    end


end



%% Compute level of over-representation

imlab = bwlabel(im,4); 
imdom = unique(imlab);

imI = round(interp2(xdom,ydom,im,xdomI,ydomI,'nearest')); %interpolate to be the same size as the maps
imI(find(isnan(imI))) = 0;
imlabI = bwlabel(imI,4);

R = 35;

centerPatch = getCenterPatch(kmap_rad,im,R);
centerPatchI = getCenterPatch(kmap_radI,imI,R);
clear spCov JacCoverage ActualCoverage MagFac

for q = 1:length(imdom)-1 %loop through each patch ("visual area")

    idpatch = find(imlab == q & centerPatch);
    dumpatch = zeros(size(im));
    dumpatch(idpatch) = 1;
    
    idpatchI = find(imlabI == q & centerPatchI);   
    dumpatchI = zeros(size(imI));
    dumpatchI(idpatchI) = 1;
    
    %figure,imagesc(dumpatchI)

    [spCov{q} JacCoverage(q) ActualCoverage(q) MagFac(q)] = overRep(kmap_horI,kmap_vertI,U,JacI,dumpatchI,sphdom,sphX,pixpermm);

    CovOverlap = JacCoverage(q)/ActualCoverage(q);

    % if JacCoverage/(pi*R^2) < .01 %get rid of the areas with practically no screen coverage
    if CovOverlap > 1.05 | JacCoverage(q)/(pi*R^2) < .01

        id = find(imlab == q);
        im(id) = 0;
    end

end

if figTag == 1;
    figure,
    scatter(JacCoverage,ActualCoverage)
    hold on
    plot([0 max(JacCoverage)], [0 max(JacCoverage)],'k')
    xlabel('Jacobian integral (deg^2)')
    ylabel('Actual Coverage (deg^2)')
end


function [spCov JacCoverage ActualCoverage MagFac] = overRep(kmap_hor,kmap_vert,U,Jac,patch,sphdom,sphX,pixpermm)

pixpermm = pixpermm*U;

N = length(sphdom);

posneg = sign(mean(Jac(find(patch))));
id = find(sign(Jac)~=posneg | Jac == 0);
Jac(id) = 0;
patch(id) = 0;
    
idpatch = find(patch);
JacCoverage = abs(sum(abs(Jac(idpatch))))/pixpermm^2; %deg^2

sphlocX = round(kmap_hor(idpatch));
sphlocX = sphlocX-sphdom(1)+1;
sphlocY = round(kmap_vert(idpatch));
sphlocY = sphlocY-sphdom(1)+1;
sphlocVec = N*(sphlocX-1) + sphlocY;

spCov = zeros(size(sphX)); %a matrix that represents the sphreen
spCov(sphlocVec) = 1;
spCov = imfill(spCov);
SE = strel('disk',1,0);
spCov = imclose(spCov,SE);
spCov = imfill(spCov);
%spCov = medfilt2(spCov,[3 3]);
ActualCoverage = sum(spCov(:)); %deg^2
MagFac = ActualCoverage/length(idpatch);



function [im splitflag Npatch] = resetPatch(im,centerPatch,imlab,q)

%First make a dilated version of the original patch, as defined by the
%Sereno 
idorig = find(imlab == q);
imorigpatch = zeros(size(im));
imorigpatch(idorig) = 1; %the original region
SE = strel('disk',1,0);
imdilpatch = imdilate(imorigpatch,SE);

%Now make the same patch, but limited to the pixels at the center of
%space
idpatch = find(imlab == q & centerPatch); %get pixels for this patch that are at the center of visual space
impatch = zeros(size(im));
impatch(idpatch) = 1; %an image of the patch we are looking at
SE = strel('disk',1,0);
impatch = imopen(impatch,SE);
idpatch = find(impatch);
imlabdum = bwlabel(impatch,4);
idlab  = unique(imlabdum);
Npatch = length(idlab)-1;

splitflag = 0;
if length(idlab) > 2 %Did limiting the patch to the center of v. space "split it"? i.e. should it be multiple areas?

    imdist = bwdist(impatch); %distance trx on "truncated patch
    id = find(~imdilpatch); %Make a boundary around the patch
    imdist(id) = -inf;
    imdist(idpatch) = 0; %force the local minima before watershed
    wshed = watershed(imdist,4);
    wshed = sign(phi(wshed-1));  %make it isolated patches

    SE = strel('disk',1,0);
    wshed = imerode(wshed,SE);  %erode slightly just so the fracture is a bit wider
    im(idorig) = 0;
    im = im+wshed;  %replace old patch with the "split" one

    splitflag = 1;
end


function centerPatch = getCenterPatch(kmap_rad,im,R)

id = find(kmap_rad<R);  %Find pixels near the center of visual space
centerPatch = zeros(size(im));
centerPatch(id) = 1;  %Make a mask for them
centerPatch = centerPatch.*im;  
SE = strel('disk',2,0);
centerPatch = imopen(centerPatch,SE); %clean it up
centerPatch = medfilt2(centerPatch,[3 3]); 


function [Nmin minpatch newpatches rad] = getNlocalmin(idpatch,Rmax,kmap_rad)

%Determine number of local minima

dum = zeros(size(kmap_rad));
dum(idpatch) = 1;
idnopatch = find(dum == 0);

kr = kmap_rad(idpatch);
threshdom = min(kr)-1;
for prc = 2:10:90
    threshdom = [threshdom prctile(kr,prc)];
end
threshdom = [threshdom max(kr)+1];

for i = 1:length(threshdom)-1
   id = find(kmap_rad>threshdom(i) & kmap_rad<threshdom(i+1));
   kmap_rad(id) = mean(kmap_rad(id));
end

kmap_rad(idnopatch) = max(kmap_rad(idpatch));
SE = strel('disk',3,0);
kmap_rad = imopen(kmap_rad,SE);

%kmap_rad = medfilt2(kmap_rad,[3 3]);

rad = zeros(size(kmap_rad));
rad(idnopatch) = Rmax;
rad(idpatch) = kmap_rad(idpatch);


%medR = ceil(length(idpatch)/400);
medR = 3;
rad = medfilt2(rad,[medR medR]);  %Really important to do this after applying Rmax boundary. It gets rid of the tiny local minima on the edges
%rad = medfilt2(rad,[3 3]);

dumpatch = zeros(size(kmap_rad));
dumpatch(idpatch) = 1;

minpatch = imregionalmin(rad,8);
minpatch = minpatch.*dumpatch;

D = round(sqrt(length(idpatch))/20);
%D = 1;
SE = strel('disk',D,0);
minpatch = imdilate(minpatch,SE);
minpatch = minpatch.*dumpatch;

%figure,imagesc(dumpatch.*kmap_rad)

imlabel = bwlabel(minpatch,4);
idlabel = unique(imlabel);
Nmin = length(idlabel)-1;

imlabel = bwlabel(minpatch,4);
idlabel = unique(imlabel);
Nmin = length(idlabel)-1;
    
SE = strel('disk',3,0);
dumpatch2 = imdilate(dumpatch,SE);

rad2 = imimposemin(rad, minpatch);
id = find(1-dumpatch);
rad2(id) = Rmax;  %reset, in case min is on the edge


id = find(~dumpatch2);
rad2(id) = -inf;

newpatches = watershed(rad2);

id = find(newpatches == 1); %change 'im' to a binary set of patches
newpatches(id) = 0;
id = find(newpatches > 0);
newpatches(id) = 1;


function imout = ploteccmap(im,rng,DS,pixpermm)

%This assumes that the zeros are the background

im = im(DS:DS:end,DS:DS:end);

mmperpix = 1/pixpermm;
xdom = (0:size(im,2)-1)*mmperpix;
ydom = (0:size(im,1)-1)*mmperpix;

bg = ones(size(im));
bgid = find(im == 0);
bg(bgid) = 0;

im(find(im>rng(2))) = rng(2);
im = im/rng(2);

im = round(im*63+1);

im(bgid) = NaN;

dim = size(im);
jetid = jet;
imout = zeros(dim(1),dim(2),3);
for i = 1:dim(1)
    for j = 1:dim(2)
        
        if isnan(im(i,j))
            imout(i,j,:) = [1 1 1];
        else
            imout(i,j,:) = jetid(im(i,j),:);
        end
    end
end


image(xdom,ydom,imout), axis image

eccdom = round(linspace(rng(1),rng(2),5));
for i = 1:length(eccdom)
    domcell{i} = eccdom(i);
end
iddom = linspace(1,64,length(eccdom));
colorbar('YTick',iddom,'YTickLabel',domcell)

hold on,
contour(xdom,ydom,bg,[.5 .5],'k')



