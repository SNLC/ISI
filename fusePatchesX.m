function [im fuseflag] = fusePatchesX(im,kmap_hor,kmap_vert,pixpermm)

%Fuse patches if they are adjacent, the same sign, and unique regions of visual space

xsize = size(kmap_hor,2)/pixpermm;  %Size of ROI mm
ysize = size(kmap_hor,1)/pixpermm; 
xdum = linspace(0,xsize,size(kmap_hor,2)); ydum = linspace(0,ysize,size(kmap_hor,1)); 
[xdom ydom] = meshgrid(xdum,ydum); %two-dimensional domain

%%%First make a set of matrices that are not interpolated
[dhdx dhdy] = gradient(kmap_hor);
[dvdx dvdy] = gradient(kmap_vert);
Jac = (dhdx.*dvdy - dvdx.*dhdy)*(pixpermm)^2;
graddir_hor = atan2(dhdy,dhdx);
graddir_vert = atan2(dvdy,dvdx);
vdiff = exp(1i*graddir_hor) .* exp(-1i*graddir_vert);
Sereno = sin(angle(vdiff));
imlab = bwlabel(im,4);  %Better to keep this as default (i.e. don' put in a 4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hh = fspecial('gaussian',size(kmap_hor),2);
kmap_horS = ifft2(fft2(kmap_hor).*abs(fft2(hh)));
kmap_vertS = ifft2(fft2(kmap_vert).*abs(fft2(hh)));

%%%Make Interpolated data to construct the visual space representations%%%
dim = size(kmap_horS);
U = 3;
xdum = linspace(xdom(1,1),xdom(1,end),U*dim(2)); ydum = linspace(ydom(1,1),ydom(end,1),U*dim(1));
[xdomI ydomI] = meshgrid(xdum,ydum); %upsample the domain
kmap_horI = round(interp2(xdom,ydom,kmap_horS,xdomI,ydomI,'nearest'));
kmap_vertI = round(interp2(xdom,ydom,kmap_vertS,xdomI,ydomI,'nearest'));

[dhdx dhdy] = gradient(kmap_horI);
[dvdx dvdy] = gradient(kmap_vertI);
JacI = (dhdx.*dvdy - dvdx.*dhdy)*(pixpermm*U)^2;

imI = round(interp2(xdom,ydom,im,xdomI,ydomI,'nearest')); %interpolate to be the same size as the maps
imI(find(isnan(imI))) = 0;
imlabI = bwlabel(imI,4); %Better to keep this as default (i.e. don't put in a 4)
labdom = unique(imlabI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sphdom = -90:90;  %create the domain for the sphere
[sphX sphY] = meshgrid(sphdom,sphdom);

%Create matrix of v. space coverage for each patch
SE = strel('disk',1,0);
for i = 1:length(labdom)-1
    patch = zeros(size(kmap_horI));
    id = find(imlabI == i);  
    patch(id) = 1;
    patch = imdilate(patch,SE);
    spCov{i} = overRep(kmap_horI,kmap_vertI,U,JacI,patch,sphdom,sphX,pixpermm);
    
    %Sereno map is messed up when ret is interpolated, so use the uninterped
    patch = zeros(size(kmap_hor));
    id = find(imlab == i);  
    patch(id) = 1;
    AreaSign(i) = sign(mean(Sereno(id))); 
end

imlab2 = imlab;

domX = sphX*pi/180; %azimuth
domY = sphY*pi/180; %altitude
ecc = atan(sqrt(tan(domX).^2 + (tan(domY).^2)./(cos(domX).^2)))*180/pi;  %he is upside-down, like spCov.  Keep them that way for contour plot
ax = atan2(tan(domY),(cos(domX).*tan(domX)))*180/pi;

fuseflag = 0;

for i = 1:length(spCov) 
    for j = (i+1):length(spCov)         
        
        %Compute overlap if the patches border each other and have the same sign
        
        if AreaSign(i)*AreaSign(j) == 1 %if they have the same sign
            
            patch1 = zeros(size(im));
            patch2 = zeros(size(im));
            
            id = find(imlab == i);
            id = find(imlab2 == median(imlab2(id))); %If its was fused at a previous part of the loop, this will take the fused patch
            patch1(id) = 1;
            
            %Find location of the patch.  Also limit it to points included
            %by imlab2 because the "opening" below can make a majority of
            %the pixels zeros if the patch was small.
            id = find(imlab == j & imlab2);  
            id = find(imlab2 == median(imlab2(id)));
            patch2(id) = 1;

            SE = strel('disk',3,0);
            patch1D = imdilate(patch1,SE);
            patch2D = imdilate(patch2,SE);

            ovlap = length(find(patch1D+patch2D == 2));
            touchflag = sign(ovlap);
            
            if touchflag %if they border each other
                Norm = min([sum(spCov{i}(:))  sum(spCov{j}(:))]);
                %Norm = sum(sign(spCov{i}(:) + spCov{j}(:)));
                OLap = (spCov{i}(:)'*spCov{j}(:))/Norm; % Percent of the smaller one that overlaps 
                
                if OLap < .1 %If there is very little visual overlap (i.e. not redundant), fuse them
                    
                    SE = strel('disk',5,0);
                    patchFuse = imclose(patch1+patch2,SE);
                    
                    SE = strel('disk',1,0);
                    imdum = imdilate(im-(patch1+patch2),SE);
                    patchFuse(find(imdum)) = 0;

                    im = im - patch1 - patch2 + patchFuse;
                   
                    dum = bwlabel(im,4);
                    
                    figure,
                    subplot(2,2,1), 
                    ploteccmap((patch1+patch2).*kmap_hor,[min(kmap_hor(find(patch1+patch2))) max(kmap_hor(find(patch1+patch2)))],pixpermm);
                    subplot(2,2,2), 
                    ploteccmap((patch1+patch2).*kmap_vert,[min(kmap_vert(find(patch1+patch2))) max(kmap_vert(find(patch1+patch2)))],pixpermm);
                    subplot(2,2,3), 
                    
                    contour(domX(1,:)*180/pi,(domY(:,1))*180/pi,ecc,[.1 25 50 75],'k'), axis image
                    hold on
                    contour(domX(1,:)*180/pi,(domY(:,1))*180/pi,ax,[-135:45:180],'k'), axis image
                    hold on,
                    [c h] = contour(domX(1,:)*180/pi,(domY(:,1))*180/pi,spCov{i},[.5 .5],'LineColor',[1 0 0]);
                    set(h,'LineWidth',4)  %its buggy if I try to do this above
                    hold on,
                    [c h] = contour(domX(1,:)*180/pi,(domY(:,1))*180/pi,spCov{j},[.5 .5],'LineColor',[0 0 1]);
                    set(h,'LineWidth',4)  %its buggy if I try to do this above
                    xlabel('azimuth'), ylabel('altitude')
                    title(['Overlap % = ' num2str(OLap)])                    
                    
                    %imagesc((spCov{i} + spCov{j}))
                    subplot(2,2,4), 
                    imagesc(1-patchFuse), %colormap gray
                    axis image                    
                    
                    SE = strel('disk',1,0);
                    im = imopen(im,SE);
                    imlab2 = bwlabel(im,4);  %Reset this for next loop
                    spCov{i} = sign(spCov{i} + spCov{j});
                    spCov{j} = sign(spCov{i} + spCov{j});
                    
                    fuseflag = 1;
                    
                end
                
            end
        end
        
    end
end

id = find(im ~= 1);
im(id) = 0;

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



function imout = ploteccmap(im,rng,pixpermm)

%This assumes that the zeros are the background

mmperpix = 1/pixpermm;
xdom = (0:size(im,2)-1)*mmperpix;
ydom = (0:size(im,1)-1)*mmperpix;

bg = ones(size(im));
bgid = find(im == 0);
bg(bgid) = 0;

im(find(im>rng(2))) = rng(2);
im(find(im<rng(1))) = rng(1);
im = im-rng(1);
im = im/(rng(2)-rng(1));

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

