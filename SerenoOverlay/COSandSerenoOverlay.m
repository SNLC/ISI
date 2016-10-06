function COSandSerenoOverlay(anim,AzExpt,AltExpt)
% 
% anim='EM2';
% AzExpt='000_005';
% AltExpt='000_006';
% 

scalebarxpos= 200; %200 typical
scalebarypos= 220; %210 usually typical

%'R43','000_005','000_004'

%filename=strcat('C:\Analyzed Data_ISI\', anim,'\Kmaps\',anim,'_LP1_Thresh_0.05_kret.mat');
% filename=strcat('C:\Analyzed Data_ISI\', anim,'\Kmaps\',anim,'_LP0.75_Thresh_0.05_kret.mat');
filename=strcat('E:\AnalyzedData\', anim,'\Kmaps\',anim,'_LP0.75_Thresh_0.05_kret.mat'); %new hard drive (march 2016)

% if exist(filename) == 2
% load(filename)
% else
    generatekret(anim,AzExpt,AltExpt)
    load(filename)
% end    

kmap_hor=kret.kmap_hor;
kmap_vert=kret.kmap_vert;

%get borders from sereno analysis - output AreaMap is a matrix of ones and
%twos where each represents either mirror or non mirror visual field sign
[AreaMap] = SerenoAnalysis(kmap_hor,kmap_vert);
close all
figure,imagesc(AreaMap)

%% make mapROI mask of center of space - currently hardcoded values
%make center of space mask
theta=kmap_hor;
phi=kmap_vert;
%approximate center of space
minphi=10; %10 typical
maxphi=30; %30 typical
mintheta=-10; %-10 typical
maxtheta=20; %20 typical
% find pixels representing center of space
[idvert] = find(phi(:) < maxphi & phi(:) > minphi);
[idhor] = find(theta(:) < maxtheta & theta(:) > mintheta);
retROI = intersect(idhor,idvert);
% make mask for center of space
mapROI =ones(size(theta));
mapROI(retROI) = 64;
figure,imagesc(mapROI)

% make anatomy pic and mapROI and kmaps square so they match the dimensions of
% AreaMap and can be overlayed
anatomypic=kret.AnatomyPic;
[dim1 dim2] = size(anatomypic);
if dim1<dim2
    dimdif = dim2-dim1;
    temp = zeros(dim2,dim2);
    TA = temp;
    TM = temp;
    TH = temp;
    TV = temp;
    TA(1:dim1,1:dim2) = anatomypic;
    TM(1:dim1,1:dim2) = mapROI;
    TH(1:dim1,1:dim2) = kmap_hor;
    TV(1:dim1,1:dim2) = kmap_vert;
    anatomypic = TA;
    mapROI = TM;
    kmap_hor = TH;
    kmap_vert = TV;
end
    
%find Borders
BW = edge(AreaMap,'canny',.3,5);
figure('Name','Border Estimate'), imagesc(BW), colormap(gray),axis image
[border] = find(BW == 1);
%Draw borders on anatomy pic
BorderAnatomy=anatomypic;
BorderAnatomy(border)=64;
figure,imagesc(BorderAnatomy),colormap gray 
%put borders on kmaps
kmap_hor_border=kmap_hor;
kmap_hor_border(border)=85;
kmap_vert_border=kmap_vert;
kmap_vert_border(border)=85;

%% make overlays

%make overlay with anatomy pic with sereno borders on it, plus center of
%space mask
%normalize anatomy picture and make between 1 and 64 (to match colormap
%indices)
anatomypic=double(BorderAnatomy);
anatomypic = anatomypic-min(anatomypic(:));
anatomypic = anatomypic/max(anatomypic(:));
anatomypic = round(anatomypic*63+1);
figure,imagesc(anatomypic),colormap gray

AnatomySereno=figure('Name','  Anatomy and Sereno Overlay','NumberTitle','off');
    imagesc(anatomypic)
    colormap gray
    title(strcat(anim,' Anatomy and Sereno Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis image
    
%normalize mapROI and make between 1 and 64 (to match colormap indices)
mapROI_overlay= mapROI;
mapROI_overlay = mapROI_overlay-min(mapROI_overlay(:));
mapROI_overlay = mapROI_overlay/max(mapROI_overlay(:));
mapROI_overlay = round(mapROI_overlay*63+1);
ratio=.2;
aw = 1-ratio;  %anatomy weight of image (scalar)
fw = ratio;  %anatomy weight of image (scalar)
grayid = gray;
hsvid = cool; %colormap for mapROI
dim = size(mapROI_overlay);

for i = 1:dim(1)
    for j = 1:dim(2)
        overlay(i,j,:) = fw*hsvid(mapROI_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
overlay = overlay/max(overlay(:));

MapROISereno=figure('Name','  Center of Space and Sereno Overlay','NumberTitle','off');
    imagesc(overlay)
    line([scalebarxpos scalebarxpos+20],[scalebarypos scalebarypos],'Color','k','LineWidth',4,'LineStyle','-')
    title(strcat(anim, ' Center of Space and Sereno Overlay,  phi = ',num2str(minphi),', ',num2str(maxphi),', theta = ',num2str(mintheta),', ',num2str(maxtheta)));
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis image
    
%normalize kmap_hor1 and make between 1 and 64 (to match colormap indices)
kmap_hor_overlay=kmap_hor;
kmap_hor_overlay = kmap_hor_overlay-min(kmap_hor_overlay(:));
kmap_hor_overlay = kmap_hor_overlay/max(kmap_hor_overlay(:));
kmap_hor_overlay = round(kmap_hor_overlay*63+1);
ratio=.2;
aw = 1-ratio;  %anatomy weight of image (scalar)
fw = ratio;  %anatomy weight of image (scalar)
grayid = gray;
hsvid = hsv;
dim = size(kmap_hor_overlay);

for i = 1:dim(1)
    for j = 1:dim(2)
        overlay_hor(i,j,:) = fw*hsvid(kmap_hor_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
overlay_hor = overlay_hor/max(overlay_hor(:));

HorizRetAnatomySereno=figure('Name','  Horizontal Retinotopy Anatomy Sereno Overlay','NumberTitle','off');
    imagesc(overlay_hor)
    line([scalebarxpos scalebarxpos+20],[scalebarypos scalebarypos],'Color','k','LineWidth',4,'LineStyle','-')
    title(strcat(anim,' Horizontal Retinotopy Anatomy Sereno Overlay'),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis image
    
%normalize kmap_vert and make between 1 and 64 (to match colormap indices)
kmap_vert_overlay=kmap_vert;
kmap_vert_overlay = kmap_vert_overlay-min(kmap_vert_overlay(:));
kmap_vert_overlay = kmap_vert_overlay/max(kmap_vert_overlay(:));
kmap_vert_overlay = round(kmap_vert_overlay*63+1);
ratio=.2;
aw = 1-ratio;  %anatomy weight of image (scalar)
fw = ratio;  %anatomy weight of image (scalar)
grayid = gray;
hsvid = hsv;
dim = size(kmap_vert_overlay);

for i = 1:dim(1)
    for j = 1:dim(2)
        overlay_vert(i,j,:) = fw*hsvid(kmap_vert_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
overlay_vert = overlay_vert/max(overlay_vert(:));

VertRetAnatomySereno=figure('Name','  Vertical Retinotopy Anatomy Sereno Overlay','NumberTitle','off');
    imagesc(overlay_vert)
    line([scalebarxpos scalebarxpos+20],[scalebarypos scalebarypos],'Color','k','LineWidth',4,'LineStyle','-')
    title(strcat(anim,' Vertical Retinotopy Anatomy Sereno Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis image
    
%make threshold colormap so that the value of the borders (80) is  white
colormap hsv;
cmap=colormap;
threshmap=cmap;
lastcolor=length(threshmap)+1;
threshmap(lastcolor,:) = ([1 1 1]);

VertRetSereno=figure('Name','  Vertical Retinotopy Sereno Overlay','NumberTitle','off');
imagesc(kmap_vert_border)
colormap(threshmap)
line([scalebarxpos scalebarxpos+20],[scalebarypos scalebarypos],'Color','k','LineWidth',4,'LineStyle','-')
title(strcat(anim,' Vertical Retinotopy Sereno Overlay '),'FontSize',12,'Interpreter','none');
set(gca,'FontName','arial');
set(gcf,'Color','w')
axis image


HorizRetSereno=figure('Name','  Horizontal Retinotopy Sereno Overlay','NumberTitle','off');
imagesc(kmap_hor_border)
colormap(threshmap)
line([scalebarxpos scalebarxpos+20],[scalebarypos scalebarypos],'Color','k','LineWidth',4,'LineStyle','-')
title(strcat(anim,' Horizontal Retinotopy Sereno Overlay '),'FontSize',12,'Interpreter','none');
set(gca,'FontName','arial');
set(gcf,'Color','w')
axis image

SerenoAreaMap=figure('Name','Sereno Area Map','NumberTitle','off');
imagesc(AreaMap)
colormap(gray)
title(strcat(anim,' Sereno Area Map'),'FontSize',12,'Interpreter','none');
line([scalebarxpos scalebarxpos+20],[scalebarypos scalebarypos],'Color','k','LineWidth',4,'LineStyle','-')
set(gca,'FontName','arial');
set(gcf,'Color','w')
axis image


%% save 
 %Root_AnalDir = 'C:\Analyzed Data_ISI\';
 Root_AnalDir = 'E:\AnalyzedData\'; %new hard drive (march 2016)
    AnalDir = strcat(Root_AnalDir,anim,'\SerenoOverlay\');
    filename1 = strcat(anim,'_AnatomySerenoOverlay');
    filename2 = strcat(anim,'_MapROISerenoOverlay');
    filename3 = strcat(anim,'_HorizRetAnatomySerenoOverlay');
    filename4 = strcat(anim,'_VertRetAnatomySerenoOverlay');
    filename5 = strcat(anim,'_HorizRetSerenoOverlay');
    filename6 = strcat(anim,'_VertRetSerenoOverlay');
    filename7 = strcat(anim,'_SerenoAreaMap');
    
    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
        saveas(AnatomySereno,strcat(AnalDir,filename1,'.tif'))
        saveas(AnatomySereno,strcat(AnalDir,filename1,'.fig'))
        saveas(MapROISereno,strcat(AnalDir,filename2,'.tif'))
        saveas(MapROISereno,strcat(AnalDir,filename2,'.fig'))
        saveas(HorizRetAnatomySereno,strcat(AnalDir,filename3,'.tif'))
        saveas(HorizRetAnatomySereno,strcat(AnalDir,filename3,'.fig')) 
        saveas(VertRetAnatomySereno,strcat(AnalDir,filename4,'.tif'))
        saveas(VertRetAnatomySereno,strcat(AnalDir,filename4,'.fig'))
        saveas(HorizRetSereno,strcat(AnalDir,filename5,'.tif'))
        saveas(HorizRetSereno,strcat(AnalDir,filename5,'.fig')) 
        saveas(VertRetSereno,strcat(AnalDir,filename6,'.tif'))
        saveas(VertRetSereno,strcat(AnalDir,filename6,'.fig'))
        saveas(SerenoAreaMap,strcat(AnalDir,filename7,'.tif'))
        saveas(SerenoAreaMap,strcat(AnalDir,filename7,'.fig'))
        
close all
        
end
