function anatomyoverlay(anim,AzExpt,AltExpt)

anim='L38';
AzExpt='000_004';
AltExpt='000_005';

% determine whether expt is altitude or azimuth
AzAnim=anim;
AzExpt1=AzExpt;
AzExpt=strcat('u',AzExpt);
AzExptID = strcat(anim,'_',AzExpt); 

AltAnim=anim;
AltExpt1=AltExpt;
AltExpt=strcat('u',AltExpt);
AltExptID = strcat(anim,'_',AltExpt); 

%% get anatomy image
Dir = 'C:\imager_data\';
Anatdir=[Dir AzAnim,'\grabs\'];
D = dir([Anatdir '*.mat']);
pic=D(001).name;
filename=strcat(Anatdir, pic);
image=load(filename);
anatomypic=image.grab.img;
anatomypic_orig=anatomypic;

% figure,imagesc(anatomypic),colormap(gray)
 
% rotate
anatomypic = fliplr(anatomypic);
anatomypic = rot90(anatomypic);
anatomypic = rot90(anatomypic);
anatomypic = rot90(anatomypic);

%normalize anatomy picture and make between 1 and 64 (to match colormap
%indices)
anatomypic=double(anatomypic);
anatomypic = anatomypic-min(anatomypic(:));
anatomypic = anatomypic/max(anatomypic(:));
anatomypic = round(anatomypic*63+1);


%% HorizRet
%get analyzer file
Dir = 'C:\neurodata\AnalyzerFiles\';
Anadir=[Dir AzAnim,'\params ',AzExptID '.mat'];
load(Anadir,'Analyzer','-mat')

%get processed data
pathname='C:\neurodata\Processed Data\';
filename=strcat(AzAnim,'_',AzExpt1,'.mat');
filepath=strcat(pathname,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
%one axes hack
if length(f1m) == 2 
    f1m{3} = f1m{2};
    f1m{4} = f1m{3};
    f1m{2} = f1m{1};
end

%% process data with 2pixel LowPass smoothing
L = fspecial('gaussian',15,2);  %make LP spatial filter
bw = ones(size(f1m{1}));

[kmap_hor dum delay_hor delay_vert sh magSh] = Gprocesskret_batch(f1m,bw,L);

xsize = Analyzer.P.param{10}{3};
horscfactor = xsize/360;
kmap_hor = kmap_hor*horscfactor; %puts kmap into eccentricity values instead of phase

kmap_hor = fliplr(kmap_hor);
kmap_hor = rot90(kmap_hor);
kmap_hor = rot90(kmap_hor);
kmap_hor = rot90(kmap_hor);

%normalize kmap_hor1 and make between 1 and 64 (to match colormap indices)
kmap_hor_overlay=kmap_hor;
kmap_hor_overlay = kmap_hor_overlay-min(kmap_hor_overlay(:));
kmap_hor_overlay = kmap_hor_overlay/max(kmap_hor_overlay(:));
kmap_hor_overlay = round(kmap_hor_overlay*63+1);

ratio=.15;
aw = 1-ratio;  %anatomy weight of image (scalar)
fw = ratio;  %anatomy weight of image (scalar)

grayid = gray;
hsvid = hsv;

dim = size(kmap_hor_overlay);

for i = 1:dim(1)
    for j = 1:dim(2)
        hor_overlay(i,j,:) = fw*hsvid(kmap_hor_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
hor_overlay = hor_overlay/max(hor_overlay(:));



%%  Vert Ret 
%get analyzer file
Dir = 'C:\neurodata\AnalyzerFiles\';
Anadir=[Dir AltAnim,'\params ',AltExptID '.mat'];
load(Anadir,'Analyzer','-mat')

%get processed data
pathname='C:\neurodata\Processed Data\';
filename=strcat(AltAnim,'_',AltExpt1,'.mat');
filepath=strcat(pathname,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
%one axes hack
if length(f1m) == 2 
    f1m{3} = f1m{2};
    f1m{4} = f1m{3};
    f1m{2} = f1m{1};
end

%% process data with 2pixel LowPass smoothing

L = fspecial('gaussian',15,2);  %make LP spatial filter
bw = ones(size(f1m{1}));

[dum kmap_vert delay_hor delay_vert sh magSv] = Gprocesskret_batch(f1m,bw,L);

ysize = Analyzer.P.param{11}{3};
vertscfactor = ysize/360;
kmap_vert = kmap_vert*vertscfactor; %puts kmap into eccentricity values instead of phase

%% rotate maps and make overlay 
kmap_vert = fliplr(kmap_vert);
kmap_vert = rot90(kmap_vert);
kmap_vert = rot90(kmap_vert);
kmap_vert = rot90(kmap_vert);

%normalize kmap_vert1 and make between 1 and 64 (to match colormap indices)
kmap_vert_overlay=kmap_vert;
kmap_vert_overlay = kmap_vert_overlay-min(kmap_vert_overlay(:));
kmap_vert_overlay = kmap_vert_overlay/max(kmap_vert_overlay(:));
kmap_vert_overlay = round(kmap_vert_overlay*63+1);

ratio=.15;
aw = 1-ratio;  %anatomy weight of image (scalar)
fw = ratio;  %anatomy weight of image (scalar)

grayid = gray;
hsvid = hsv;

dim = size(kmap_vert_overlay);

for i = 1:dim(1)
    for j = 1:dim(2)
        vert_overlay(i,j,:) = fw*hsvid(kmap_vert_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
vert_overlay = vert_overlay/max(vert_overlay(:));


%% plot figures
Anatomy=figure('Name','  Anatomy','NumberTitle','off');
    imagesc(anatomypic)
    colormap gray 
    title(strcat(AzExptID,' Anatomy '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis equal
    axis tight
    
HorizRet1=figure('Name','  Horizontal Retinotopy Overlay','NumberTitle','off');
    imagesc(hor_overlay,[-70 70])
    title(strcat(AzExptID,' Horizontal Retinotopy Anatomy Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis ij
    axis equal
    axis tight
    
HorizRet2=figure('Name','  Horizontal Retinotopy','NumberTitle','off');
    imagesc(kmap_hor,[-70 70])
    title(strcat(AzExptID,' Horizontal Retinotopy '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    axis equal
    axis tight

HorizRetContour=figure('Name','  Horizontal Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    contour(kmap_hor,[-70:20:70],'LineWidth',2)
    title(strcat(AzExptID,' Horizontal Retinotopy Contour '),'FontSize',16,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70])
    axis ij
    axis equal
    axis tight
    
HorizRetContourOverlay=figure('Name','  Horizontal Retinotopy Overlay','NumberTitle','off');
    hold on    
    imagesc(hor_overlay,[-70 70])
    contour(kmap_hor,[-70:20:70],'-w','LineWidth',1.5)
    hold off
    title(strcat(AzExptID,' Horizontal Retinotopy Contour Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis ij
    axis equal
    axis tight
    

VertRet1=figure('Name','  Vertical Retinotopy Overlay','NumberTitle','off');
    imagesc(vert_overlay,[-30 70])
    title(strcat(AltExptID,' Vertical Retinotopy Anatomy Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis ij
    axis equal
    axis tight
    
VertRet2=figure('Name','  Vertical Retinotopy','NumberTitle','off');
    imagesc(kmap_vert,[-30 70])
    title(strcat(AltExptID,' Vertical Retinotopy '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    axis equal
    axis tight

    
VertRetContour=figure('Name','  Vertical Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    contour(kmap_vert,[-30:10:70],'LineWidth',2)
    title(strcat(AltExptID,' Vertical Retinotopy Contour '),'FontSize',16,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('SouthOutside','FontSize',12,'XTick',[-30:10:70])
    axis ij
    axis equal
    axis tight
    
VertRetContourOverlay=figure('Name','  Vertical Retinotopy Overlay','NumberTitle','off');
    hold on    
    imagesc(vert_overlay,[-30 70])
    contour(kmap_vert,[-30:10:70],'-w','LineWidth',1.5)
    hold off
    title(strcat(AltExptID,' Vertical Retinotopy Contour Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis ij
    axis equal
    axis tight
    
    ContourOverlay=figure('Name','  Horizontal Retinotopy Overlay','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    hold on    
    imagesc(anatomypic),colormap gray
    contour(kmap_vert,[-30:10:70],'-b','LineWidth',1.5)
    contour(kmap_hor,[-70:20:70],'-k','LineWidth',1.5)
    hold off
    title(strcat(anim,' Horizontal Retinotopy Contour Overlay '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis ij
    axis equal
    axis tight
    


%% save overlay
    Root_AnalDir = 'C:\Analyzed Data_ISI\';
    AnalDir = strcat(Root_AnalDir,anim,'\Overlays\');
    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
    filename1 = strcat(AzExptID,'_HorizRet1');
    filename2 = strcat(AzExptID,'_HorizRet2');
    filename3 = strcat(AzExptID,'_HorizAnatomy');
    filename4 = strcat(AzExptID,'_HorizContour');
    filename5 = strcat(AzExptID,'_HorizContourOverlay');
    
    filename6 = strcat(AltExptID,'_VertRet1');
    filename7 = strcat(AltExptID,'_VertRet2');
    filename8 = strcat(AltExptID,'_VertAnatomy');
    filename9 = strcat(AltExptID,'_VertContour');
    filename10 = strcat(AltExptID,'_VertContourOverlay');
    
    filename11 = strcat(anim,'_ContourOverlay');
    
    saveas(HorizRet1,strcat(AnalDir,filename1,'.tif'))
    saveas(HorizRet1,strcat(AnalDir,filename1,'.fig'))
    saveas(HorizRet2,strcat(AnalDir,filename2,'.tif'))
    saveas(HorizRet2,strcat(AnalDir,filename2,'.fig'))
    saveas(Anatomy,strcat(AnalDir,filename3,'.tif'))
    saveas(Anatomy,strcat(AnalDir,filename3,'.fig'))
    saveas(HorizRetContour,strcat(AnalDir,filename4,'.tif'))
    saveas(HorizRetContour,strcat(AnalDir,filename4,'.fig'))
    saveas(HorizRetContourOverlay,strcat(AnalDir,filename5,'.tif'))
    saveas(HorizRetContourOverlay,strcat(AnalDir,filename5,'.fig'))

    saveas(VertRet1,strcat(AnalDir,filename6,'.tif'))
    saveas(VertRet1,strcat(AnalDir,filename6,'.fig'))
    saveas(VertRet2,strcat(AnalDir,filename7,'.tif'))
    saveas(VertRet2,strcat(AnalDir,filename7,'.fig'))
    saveas(Anatomy,strcat(AnalDir,filename8,'.tif'))
    saveas(Anatomy,strcat(AnalDir,filename8,'.fig'))
    saveas(VertRetContour,strcat(AnalDir,filename9,'.tif'))
    saveas(VertRetContour,strcat(AnalDir,filename9,'.fig'))
    saveas(VertRetContourOverlay,strcat(AnalDir,filename10,'.tif'))
    saveas(VertRetContourOverlay,strcat(AnalDir,filename10,'.fig'))

    saveas(ContourOverlay,strcat(AnalDir,filename11,'.tif'))
    saveas(ContourOverlay,strcat(AnalDir,filename11,'.fig'))
    
close all
end