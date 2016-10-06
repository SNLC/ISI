function getAreaBorders(anim,alt_expt,azi_expt)

%% INPUTS
%kmap_hor - Map of horizontal retinotopic location
%kmap_vert - Map of vertical retinotopic location

%% Set Save Directory & Low Pass Values
SaveDir = ['E:\AnalyzedData\',anim,'\'];
LP = [.5 .75 1]; % to run different low pass values, worth trying anything from 0 to 2

[token azi ] = strtok(azi_expt,'_');
[token alt ] = strtok(alt_expt,'_');
ExptID = strcat(anim,azi,alt)

%% Generate and load kmaps for vertical and horizontal retinotopy

% if you have kmaps you can skip this step
generatekret(anim,azi_expt,alt_expt,LP) % this script also generates overlays of azi/alt & blood vessels as well as resp mag maps

dimLP = size(LP);

for iLP = 1:dimLP(2);
    
    kmapfilename=strcat(SaveDir,'Kmaps\',anim,'_LP',num2str(LP(iLP)),'_Thresh_0.05_kret.mat')
    load(kmapfilename)
    kmap_hor_orig= -(kret.kmap_hor); % negative to correct values 
    kmap_vert_orig=kret.kmap_vert;
    
    %% Rotate & Up/Down Sample Maps
    % The images in Garrett et al '14 were collected at 39 pixels/mm.  It is
    % recommended that kmap_hor and kmap_vert be down/upsampled to this value
    % before running. The code below downsamples by 2 to achieve 39 pixels/mm
    
    kmap_hor_orig = rot90(rot90(kmap_hor_orig));
    kmap_vert_orig = rot90(rot90(kmap_vert_orig));
    
    kmap_hor = downsample(kmap_hor_orig,2);
    kmap_hor = downsample(rot90(kmap_hor),2);
    
    kmap_vert = downsample(kmap_vert_orig,2);
    kmap_vert = downsample(rot90(kmap_vert),2);
    
    kmap_hor_orig = rot90(kmap_hor_orig);
    kmap_vert_orig = rot90(kmap_vert_orig);
    
    pixpermm = 39;
    
    %% Compute visual field sign map
    
    mmperpix = 1/pixpermm;
    
    [dhdx dhdy] = gradient(kmap_hor);
    [dvdx dvdy] = gradient(kmap_vert);
    
    graddir_hor = atan2(dhdy,dhdx);
    graddir_vert = atan2(dvdy,dvdx);
    
    vdiff = exp(1i*graddir_hor) .* exp(-1i*graddir_vert); %Should be vert-hor, but the gradient in Matlab for y is opposite.
    VFS = sin(angle(vdiff)); %Visual field sign map
    id = find(isnan(VFS));
    VFS(id) = 0;
    
    hh = fspecial('gaussian',size(VFS),3);
    hh = hh/sum(hh(:));
    VFS = ifft2(fft2(VFS).*abs(fft2(hh)));  %Important to smooth before thresholding below
    
    %% Plot retinotopic maps
    
    xdom = (0:size(kmap_hor,2)-1)*mmperpix;
    ydom = (0:size(kmap_hor,1)-1)*mmperpix;
    
    screenDim = get(0,'ScreenSize');
    figure(10), clf
    set(10,'Position',[0,0,screenDim(3),screenDim(4)])
    
    subplot(3,4,1)
    imagesc(xdom,ydom,kmap_hor,[-50 50]),
    axis image, colorbar
    title('1. Horizontal (azim deg)')
    
    subplot(3,4,2)
    imagesc(xdom,ydom,kmap_vert,[-50 50]),
    axis image, colorbar
    title('2. Vertical (alt deg)')
    
    %% Plotting visual field sign and its threshold
    
    figure(10), subplot(3,4,3),
    imagesc(xdom,ydom,VFS,[-1 1]), axis image
    colorbar
    title('3. Sereno: sin(angle(Hor)-angle(Vert))')
    
    gradmag = abs(VFS);
    figure(10), subplot(3,4,4),
    
    threshSeg = 1.5*std(VFS(:));
    imseg = (sign(gradmag-threshSeg/2) + 1)/2;  %threshold visual field sign map at +/-1.5sig
    
    id = find(imseg);
    imdum = imseg.*VFS; imdum(id) = imdum(id)+1.1;
    plotmap(imdum,[.1 2.1],pixpermm);
    colorbar off
    axis image
    title(['4. +/-1.5xSig = ' num2str(threshSeg)])
    
    patchSign = getPatchSign(imseg,VFS);
    
    figure(10), subplot(3,4,5),
    plotmap(patchSign,[1.1 2.1],pixpermm);
    title('watershed')
    colorbar off
    title('5. Threshold patches')
    
    id = find(patchSign ~= 0);
    patchSign(id) = sign(patchSign(id) - 1);
    
    SE = strel('disk',2,0);
    imseg = imopen(imseg,SE);
    
    patchSign = getPatchSign(imseg,VFS);
    
    figure(10), subplot(3,4,6),
    ploteccmap(patchSign,[1.1 2.1],pixpermm);
    title('watershed')
    colorbar off
    title('6. "Open" & set boundary')
    
    %% Make boundary of visual cortex
    
    %First pad the image with zeros because the "imclose" function does this
    %weird thing where it tries to "bleed" to the edge if the patch near it
    
    Npad = 30;  %Arbitrary padding value.  May need more depending on image size and resolution
    dim = size(imseg);
    imsegpad = [zeros(dim(1),Npad) imseg zeros(dim(1),Npad)];
    dim = size(imsegpad);
    imsegpad = [zeros(Npad,dim(2)); imsegpad; zeros(Npad,dim(2))];
    
    SE = strel('disk',10,0);
    imbound = imclose(imsegpad,SE);
    
    imbound = imfill(imbound); %often unnecessary, but sometimes there are small gaps need filling
    
    % SE = strel('disk',5,0);
    % imbound = imopen(imbound,SE);
    
    SE = strel('disk',3,0);
    imbound = imdilate(imbound,SE); %Dilate to account for original thresholding.
    imbound = imfill(imbound);
    
    %Remove the padding
    imbound = imbound(Npad+1:end-Npad,Npad+1:end-Npad);
    imbound(:,1) = 0; imbound(:,end) = 0; imbound(1,:) = 0;  imbound(end,:) = 0;
    
    %Only keep the "main" group of patches. Preveiously used opening (see above), but this is more robust:
    bwlab = bwlabel(imbound,4);
    labid = unique(bwlab);
    for i = 1:length(labid)
        id = find(bwlab == labid(i));
        S(i) = length(id);
    end
    S(1) = 0; %To ignore the "surround patch"
    [dum id] = max(S);
    id = find(bwlab == labid(id));
    imbound = 0*imbound;
    imbound(id) = 1;
    imseg = imseg.*imbound;
    
    clear S
    
    %This is important in case a patch reaches the edge... we want it to be
    %smaller than imbound
    imseg(:,1:2) = 0; imseg(:,end-1:end) = 0; imseg(1:2,:) = 0;  imseg(end-1:end,:) = 0;
    
    figure(10), subplot(3,4,6)
    hold on
    contour(xdom,ydom,imbound,[.5 .5],'k')
    
    %% Morphological thinning to create borders that are one pixel wide
    
    %Thinning
    bordr = imbound-imseg;
    bordr = bwmorph(bordr,'thin',Inf);
    bordr = bwmorph(bordr,'spur',4);
    
    %Turn border map into patches
    im = bwlabel(1-bordr,4);
    im(find(im == 1)) = 0;
    im = sign(im);
    
    % bwlab = bwlabel(im,4);
    % labid = unique(bwlab);
    % for i = 1:length(labid)
    %    id = find(bwlab == labid(i));
    %    if length(id) < 30
    %        im(id) = 0;
    %    end
    % end
    
    %% Plot patches
    
    patchSign = getPatchSign(im,VFS);
    
    figure(10), subplot(3,4,7),
    ploteccmap(patchSign,[1.1 2.1],pixpermm);
    hold on,
    contour(xdom,ydom,im,[.5 .5],'k')
    title('"Thinning"')
    colorbar off
    
    %% Plot eccentricity map, with [0 0] defined as V1's center-of-mass
    
    SE = strel('disk',10);
    imdum = imopen(imseg,SE);
    [CoMxy Axisxy] = getPatchCoM(imdum);
    
    V1id = getV1id(imdum);
    
    AreaInfo.Vcent(1) = kmap_hor(round(CoMxy(V1id,2)),round(CoMxy(V1id,1)));  %Get point in visual space at the center of V1
    AreaInfo.Vcent(2) = kmap_vert(round(CoMxy(V1id,2)),round(CoMxy(V1id,1)));
    
    az = (kmap_hor - AreaInfo.Vcent(1))*pi/180; %azimuth
    alt = (kmap_vert - AreaInfo.Vcent(2))*pi/180; %altitude
    AreaInfo.kmap_rad = atan(  sqrt( tan(az).^2 + (tan(alt).^2)./(cos(az).^2)  )  )*180/pi;  %Eccentricity
    
    subplot(3,4,8)
    ploteccmap(AreaInfo.kmap_rad.*im,[0 45],pixpermm);
    hold on
    contour(xdom,ydom,im,[.5 .5],'k')
    axis image
    title('8. Eccentricity map')
    
    %% ID redundant patches and split them (criterion #2)
    
    im = splitPatchesX(im,kmap_hor,kmap_vert,AreaInfo.kmap_rad,pixpermm);
    
    %Remake the border with thinning
    bordr = imbound-im;
    bordr = bwmorph(bordr,'thin',Inf);
    bordr = bwmorph(bordr,'spur',4);
    
    %Turn border map into patches
    im = bwlabel(1-bordr,4);
    im(find(im == 1)) = 0;
    im = sign(im);
    SE = strel('disk',2);
    im = imopen(im,SE);
    
    %% ID adjacent patches of the same VFS and fuse them if not redundant (criterion #3)
    
    [im fuseflag] = fusePatchesX(im,kmap_hor,kmap_vert,pixpermm);
    
    figure(10), subplot(3,4,9),
    ploteccmap(im.*AreaInfo.kmap_rad,[0 45],pixpermm);
    title('9. Split redundant patches. Fuse exclusive patches.')
    
    subplot(3,4,1)
    hold on,
    contour(xdom,ydom,im,[.5 .5],'k')
    
    subplot(3,4,2)
    hold on,
    contour(xdom,ydom,im,[.5 .5],'k')
    
    [patchSign areaSign] = getPatchSign(im,VFS);
    figure(10), subplot(3,4,10)
    ploteccmap(patchSign,[1.1 2.1],pixpermm); colorbar off
    hold on
    contour(xdom,ydom,im,[.5 .5],'k')
    axis image
    
    title('10. visual areas')
    
    %% Plot contours
    figure(10)
    subplot(3,4,11)
    contour(xdom,ydom,kmap_vert.*im,[-90:4:90],'r')
    hold on
    contour(xdom,ydom,kmap_hor.*im,[-90:4:90],'k')
    axis ij
    title('Red: Vertical Ret;  Black: Horizontal Ret')
    axis image
    xlim([xdom(1) xdom(end)]), ylim([ydom(1) ydom(end)])
    
    %% Get magnification factor images
    [JacIm prefAxisMF Distort] = getMagFactors(kmap_hor,kmap_vert,pixpermm);
    
    figure(10)
    subplot(3,4,12)
    plotmap(im.*sqrt(1./abs(JacIm)),[sqrt(.000001) sqrt(.003)],pixpermm);  %This doesn't work
    title('Mag fac (mm2/deg2)')
    
    dim = size(prefAxisMF);
    DdomX = 10:10:dim(2);
    DdomY = 10:10:dim(1);
    prefAxisMF = prefAxisMF(DdomY,DdomX);
    Distort = Distort(DdomY,DdomX);
    
    figure(10)
    subplot(3,4,12)
    hold on,
    contour(xdom,ydom,im,[.5 .5],'k')
    for i = 1:length(DdomX)
        for j = 1:length(DdomY)
            
            xpart = 5*Distort(j,i)*cos(prefAxisMF(j,i)*pi/180);
            ypart = 5*Distort(j,i)*sin(prefAxisMF(j,i)*pi/180);
            
            if im(DdomY(j),DdomX(i))
                hold on, plot([DdomX(i)-xpart DdomX(i)+xpart]*mmperpix,[DdomY(j)-ypart DdomY(j)+ypart]*mmperpix,'k')
            end
            
        end
    end
    
    %% SAVE AREA BORDER GENERATION FIGURE
    bordersFig = strcat(SaveDir,ExptID,'_','LP',num2str(LP(iLP)),'_Area Border Generation.fig')
    saveas(gcf,bordersFig,'fig')
    bordersFig = strcat(SaveDir,ExptID,'_','LP',num2str(LP(iLP)),'_Area Border Generation.tif');
    saveas(gcf,bordersFig,'tif')
    
    %% Plot blood vessel overlays
    
    figure;
    set(gcf,'Position',[100, 100, 1500, 500]);
    
    % blood vessel picture
    subplot(1,3,1);
    anatomypic = rot90(rot90(rot90(kret.AnatomyPic)));
    imagesc(xdom,ydom,anatomypic)
    colormap gray
    hold on
    title(strcat('Anatomy'),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    xlabel('mm'); ylabel('mm')
    axis equal; axis tight
    hold on;
    contour(xdom,ydom,im,[.5 .5],'k','LineWidth',2);
    
    ratio=.2;
    aw = 1-ratio;  %anatomy weight of image (scalar)
    fw = ratio;  %anatomy weight of image (scalar)
    
    grayid = gray;
    hsvid = hsv;
    
    %normalize overlay maps
    kmap_hor_overlay = kmap_hor_orig;
    kmap_hor_overlay = kmap_hor_overlay-min(kmap_hor_overlay(:));
    kmap_hor_overlay = kmap_hor_overlay/max(kmap_hor_overlay(:));
    kmap_hor_overlay = round(kmap_hor_overlay*49+1);
    
    kmap_vert_overlay = kmap_vert_orig;
    kmap_vert_overlay = kmap_vert_overlay-min(kmap_vert_overlay(:));
    kmap_vert_overlay = kmap_vert_overlay/max(kmap_vert_overlay(:));
    kmap_vert_overlay = round(kmap_vert_overlay*49+1);
    
    dim = size(kmap_hor_overlay);
    
    for i = 1:dim(1)
        for j = 1:dim(2)
            overlay(i,j,:) = fw*hsvid(kmap_hor_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);
        end
    end
    overlay = overlay/max(overlay(:));
    
    for i = 1:dim(1)
        for j = 1:dim(2)
            vertoverlay(i,j,:) = fw*hsvid(kmap_vert_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);
        end
    end
    
    vertoverlay = vertoverlay/max(vertoverlay(:));
    
    subplot(1,3,2)
    imagesc(xdom,ydom,overlay,[-50 50])
    title(strcat('Horizontal Retinotopy Overlay'),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    xlabel('mm'); ylabel('mm')
    axis equal; axis tight
    hold on;
    contour(xdom,ydom,im,[.5 .5],'k','LineWidth',2)
    
    subplot(1,3,3)
    imagesc(xdom,ydom,vertoverlay,[-50 50])
    title(strcat('Vertical Retinotopy Overlay'),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    xlabel('mm'); ylabel('mm')
    axis equal; axis tight
    hold on;
    contour(xdom,ydom,im,[.5 .5],'k','LineWidth',2)
    
    
    overlaysFig = strcat(SaveDir,ExptID,'_','LP',num2str(LP(iLP)),'_Overlays.fig')
    saveas(gcf,overlaysFig,'fig');
    overlaysFig = strcat(SaveDir,ExptID,'_','LP',num2str(LP(iLP)),'_Overlays.tif');
    saveas(gcf,overlaysFig,'tif');
    
    close all
end