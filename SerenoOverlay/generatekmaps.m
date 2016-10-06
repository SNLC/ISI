function generatekmaps(anim,expt)

anim='R43';
% expt='000_005';
AzExpt='000_005';
AltExpt='000_004';

%set lowpass smoothing valuess
LP=[0,1,2,3,4,5];
%set highpass smoothing values
HP=[0];

%% process data for various LP smothing
for x=1:length(LP)
%% Horiz Ret
Anim=anim;
Expt=strcat('u',AzExpt);
Expt1=AzExpt;
ExptID = strcat(anim,'_',Expt); 
Horiz_ExptID=ExptID;

%get analyzer file
Dir = 'G:\Mouse3\Intrinsic Imaging\neurodata\AnalyzerFiles_new\';
Anadir=[Dir Anim,'\',ExptID '.analyzer'];
load(Anadir,'Analyzer','-mat')
Horiz_Analyzer=Analyzer;

%get processed data
pathname='G:\Mouse3\Intrinsic Imaging\neurodata\Processed Data\';
filename=strcat(Anim,'_',Expt1,'.mat');
filepath=strcat(pathname,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
%one axes hack
if length(f1m) == 2 
    f1m{3} = f1m{2};
    f1m{4} = f1m{3};
    f1m{2} = f1m{1};
end

% get anatomy image
Dir = 'G:\Mouse3\Intrinsic Imaging\imager_data\';
Anatdir=[Dir Anim,'\grabs\'];
D = dir([Anatdir '*.mat']);
pic=D(001).name;
filename=strcat(Anatdir, pic);
image=load(filename);
anatomypic_orig=image.grab.img;


if LP(x)==0
    L=[];
    bw = ones(size(f1m{1}));
else
L = fspecial('gaussian',15,LP(x));  %make LP spatial filter
bw = ones(size(f1m{1}));
end
if HP(x)==0
    H=[];
else
    sizedum = 2.5*HP(x);
    H = -fspecial('gaussian',sizedum,HP(x));
    H(round(sizedum/2),round(sizedum/2)) = 1+H(round(sizedum/2),round(sizedum/2));
end

[kmap_vert kmap_vert delay_hor delay_vert magS ang0 ang1 ang2 ang3] = Gprocesskret_generatekmaps(f1m,bw,L,H);

xsize = Analyzer.P.param{6}{3};
horscfactor = xsize/360;
kmap_hor1 = kmap_hor*horscfactor; %puts kmap into eccentricity values instead of phase

% flip everything to be oriented correctly 
kmap_hor1 = fliplr(kmap_hor1);
kmap_hor1 = rot90(kmap_hor1);
kmap_hor1 = rot90(kmap_hor1);
kmap_hor1 = rot90(kmap_hor1);
  
anatomypic=anatomypic_orig;   
anatomypic = fliplr(anatomypic);
anatomypic = rot90(anatomypic);
anatomypic = rot90(anatomypic);
anatomypic = rot90(anatomypic);


ang0 = fliplr(ang0);
ang0 = rot90(ang0);
ang0 = rot90(ang0);
ang0 = rot90(ang0);

ang1 = fliplr(ang1);
ang1 = rot90(ang1);
ang1 = rot90(ang1);
ang1 = rot90(ang1);

ang2 = fliplr(ang2);
ang2 = rot90(ang2);
ang2 = rot90(ang2);
ang2 = rot90(ang2);

ang3 = fliplr(ang3);
ang3 = rot90(ang3);
ang3 = rot90(ang3);
ang3 = rot90(ang3);

magS.hor = fliplr(magS.hor);
magS.hor = rot90(magS.hor);
magS.hor = rot90(magS.hor);
magS.hor = rot90(magS.hor);

delay_hor = fliplr(delay_hor);
delay_hor = rot90(delay_hor);
delay_hor = rot90(delay_hor);
delay_hor = rot90(delay_hor);

% rename variables for saving   
kmap_hor_ecc=kmap_hor1;
kmap_hor_phase=kmap_hor;
horiz_ang0=ang0;
horiz_ang1=ang1;
horiz_ang2=ang2;
horiz_ang3=ang3;
horiz_magS=magS.hor;
horiz_delay=delay_hor;

%normalize anatomy picture and make between 1 and 64 (to match colormap
%indices)
anatomypic=double(anatomypic);
anatomypic = anatomypic-min(anatomypic(:));
anatomypic = anatomypic/max(anatomypic(:));
anatomypic = round(anatomypic*63+1);

%normalize kmap_hor1 and make between 1 and 64 (to match colormap indices)
kmap_hor_overlay=kmap_hor1;
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
        overlay(i,j,:) = fw*hsvid(kmap_hor_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
overlay = overlay/max(overlay(:));
horiz_overlay=overlay;

Anatomy=figure('Name','  Anatomy','NumberTitle','off');
    imagesc(anatomypic)
    colormap gray 
    title(strcat(ExptID,' Anatomy '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis equal
    axis tight
 
HorizRet1=figure('Name','  Horizontal Retinotopy Overlay','NumberTitle','off');
    imagesc(overlay)
    title(strcat(ExptID,' Horizontal Retinotopy Overlay-LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis equal
    axis tight
    
HorizRet2=figure('Name','  Horizontal Retinotopy','NumberTitle','off');
    imagesc(kmap_hor1)
    title(strcat(ExptID,' Horizontal Retinotopy -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    axis equal
    axis tight
    
HorizRet3=figure('Name','  Horizontal Retinotopy','NumberTitle','off');
    imagesc(kmap_hor1,[-70 70])
    title(strcat(ExptID,' Horizontal Retinotopy -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70]);
    axis equal
    axis tight
    
HorizMag=figure('Name','  Horizontal Retinotopy Response Magnitude','NumberTitle','off');
    imagesc(horiz_magS)
    title(strcat(ExptID,' Horizontal Retinotopy Response Magnitude -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap bone
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
HorizAng1=figure('Name','  Horizontal Retinotopy Angle 1','NumberTitle','off');
    imagesc(horiz_ang1)
    title(strcat(ExptID,' Horizontal Retinotopy Angle1 -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap jet
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
   
HorizAng2=figure('Name','  Horizontal Retinotopy Angle 2','NumberTitle','off');
    imagesc(horiz_ang2)
    title(strcat(ExptID,' Horizontal Retinotopy Angle2 -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap jet
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
HorizDelay=figure('Name','  Horizontal Retinotopy Delay','NumberTitle','off');
    imagesc(horiz_delay)
    title(strcat(ExptID,' Horizontal Retinotopy Delay -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hot
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
    %% save figures and variables
    Root_AnalDir = 'G:\Mouse3\Intrinsic Imaging\Kmaps\';
    AnalDir = strcat(Root_AnalDir,Anim,'\Figures\');
    AnalDir1 = strcat(Root_AnalDir,Anim,'\');
    filename5 = strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet1');
    filename8 = strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet2');
    filename9 = strcat(ExptID,'_LP',num2str(LP(x)),'_HorizAnatomy');
    filename18= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet3');
    filename19= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizMag');
    filename20= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizAng1');
    filename21= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizAng2');
    filename22= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizDelay');

    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
    saveas(HorizRet1,strcat(AnalDir,filename5,'.tif'))
    saveas(HorizRet1,strcat(AnalDir,filename5,'.fig'))
    saveas(HorizRet2,strcat(AnalDir,filename8,'.tif'))
    saveas(HorizRet2,strcat(AnalDir,filename8,'.fig'))
    saveas(Anatomy,strcat(AnalDir,filename9,'.tif'))
    saveas(Anatomy,strcat(AnalDir,filename9,'.fig'))
    saveas(HorizRet3,strcat(AnalDir,filename18,'.tif'))
    saveas(HorizRet3,strcat(AnalDir,filename18,'.fig'))
    saveas(HorizMag,strcat(AnalDir,filename19,'.tif'))
    saveas(HorizMag,strcat(AnalDir,filename19,'.fig'))
    saveas(HorizAng1,strcat(AnalDir,filename20,'.tif'))
    saveas(HorizAng1,strcat(AnalDir,filename20,'.fig'))
    saveas(HorizAng1,strcat(AnalDir,filename21,'.tif'))
    saveas(HorizAng1,strcat(AnalDir,filename21,'.fig'))
    saveas(HorizDelay,strcat(AnalDir,filename22,'.tif'))
    saveas(HorizDelay,strcat(AnalDir,filename22,'.fig'))

close all



%%  Vert Ret 
Anim=anim;
Expt=strcat('u',AltExpt);
Expt1=AltExpt;
ExptID = strcat(anim,'_',Expt); 
Vert_ExptID=ExptID;

%get analyzer file
Dir = 'G:\Mouse3\Intrinsic Imaging\neurodata\AnalyzerFiles_new\';
Anadir=[Dir Anim,'\',ExptID '.analyzer'];
load(Anadir,'Analyzer','-mat')
Vert_Analyzer=Analyzer;

%get processed data
pathname='G:\Mouse3\Intrinsic Imaging\neurodata\Processed Data\';
filename=strcat(Anim,'_',Expt1,'.mat');
filepath=strcat(pathname,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
%one axes hack
if length(f1m) == 2 
    f1m{3} = f1m{2};
    f1m{4} = f1m{3};
    f1m{2} = f1m{1};
end

% get anatomy image
Dir = 'G:\Mouse3\Intrinsic Imaging\imager_data\';
Anatdir=[Dir Anim,'\grabs\'];
D = dir([Anatdir '*.mat']);
pic=D(001).name;
filename=strcat(Anatdir, pic);
image=load(filename);
anatomypic_orig=image.grab.img;

if LP(x)==0
    L=[];
    bw = ones(size(f1m{1}));
else
L = fspecial('gaussian',15,LP(x));  %make LP spatial filter
bw = ones(size(f1m{1}));
end
if HP(x)==0
    H=[];
else
    sizedum = 2.5*HP(x);
    H = -fspecial('gaussian',sizedum,HP(x));
    H(round(sizedum/2),round(sizedum/2)) = 1+H(round(sizedum/2),round(sizedum/2));
end

[kmap_vert kmap_vert delay_hor delay_vert magS ang0 ang1 ang2 ang3] = Gprocesskret_generatekmaps(f1m,bw,L,H);


ysize = Analyzer.P.param{7}{3};
vertscfactor = ysize/360;
kmap_vert1 = kmap_vert*vertscfactor; %puts kmap into eccentricity values instead of phase

% flip everything to be oriented correctly 

kmap_vert1 = fliplr(kmap_vert1);
kmap_vert1 = rot90(kmap_vert1);
kmap_vert1 = rot90(kmap_vert1);
kmap_vert1 = rot90(kmap_vert1);

anatomypic=anatomypic_orig;   
anatomypic = fliplr(anatomypic);
anatomypic = rot90(anatomypic);
anatomypic = rot90(anatomypic);
anatomypic = rot90(anatomypic);

ang0 = fliplr(ang0);
ang0 = rot90(ang0);
ang0 = rot90(ang0);
ang0 = rot90(ang0);

ang1 = fliplr(ang1);
ang1 = rot90(ang1);
ang1 = rot90(ang1);
ang1 = rot90(ang1);

ang2 = fliplr(ang2);
ang2 = rot90(ang2);
ang2 = rot90(ang2);
ang2 = rot90(ang2);

ang3 = fliplr(ang3);
ang3 = rot90(ang3);
ang3 = rot90(ang3);
ang3 = rot90(ang3);

magS.vert = fliplr(magS.vert);
magS.vert = rot90(magS.vert);
magS.vert = rot90(magS.vert);
magS.vert = rot90(magS.vert);

delay_vert = fliplr(delay_vert);
delay_vert = rot90(delay_vert);
delay_vert = rot90(delay_vert);
delay_vert = rot90(delay_vert);


% rename variables for saving   
kmap_vert_ecc=kmap_vert1;
kmap_vert_phase=kmap_vert;
vert_ang0=ang0;
vert_ang1=ang1;
vert_ang2=ang2;
vert_ang3=ang3;
vert_magS=magS.vert;
vert_delay=delay_vert;

%normalize anatomy picture and make between 1 and 64 (to match colormap
%indices)
anatomypic=double(anatomypic);
anatomypic = anatomypic-min(anatomypic(:));
anatomypic = anatomypic/max(anatomypic(:));
anatomypic = round(anatomypic*63+1);

%normalize kmap_vert1 and make between 1 and 64 (to match colormap indices)
kmap_vert_overlay=kmap_vert1;
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
        overlay(i,j,:) = fw*hsvid(kmap_vert_overlay(i,j),:) + aw*grayid(anatomypic(i,j),:);       
    end
end
overlay = overlay/max(overlay(:));
vert_overlay=overlay; 

Anatomy=figure('Name','  Anatomy','NumberTitle','off');
    imagesc(anatomypic)
    colormap gray 
    title(strcat(ExptID,' Anatomy '),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis equal
    axis tight
 
VertRet1=figure('Name','  Vertical Retinotopy Overlay','NumberTitle','off');
    imagesc(overlay)
    title(strcat(ExptID,' Vertical Retinotopy Overlay-LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    axis equal
    axis tight
    
VertRet2=figure('Name','  Vertical Retinotopy','NumberTitle','off');
    imagesc(kmap_vert1)
    title(strcat(ExptID,' Vertical Retinotopy -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    axis equal
    axis tight
    
VertRet3=figure('Name','  Vertical Retinotopy','NumberTitle','off');
    imagesc(kmap_vert1,[-30 70])
    title(strcat(ExptID,' Vertical Retinotopy -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('EastOutside','FontSize',12,'XTick',[-30:10:70]);
    axis equal
    axis tight
    
VertMag=figure('Name','  Vertical Retinotopy Response Magnitude','NumberTitle','off');
    imagesc(vert_magS)
    title(strcat(ExptID,' Vertical Retinotopy Response Magnitude -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap bone
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
VertAng1=figure('Name','  Vertical Retinotopy Angle 1','NumberTitle','off');
    imagesc(vert_ang1)
    title(strcat(ExptID,' Vertical Retinotopy Angle1 -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap jet
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
   
VertAng2=figure('Name','  Vertical Retinotopy Angle 2','NumberTitle','off');
    imagesc(vert_ang2)
    title(strcat(ExptID,' Vertical Retinotopy Angle2 -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap jet
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
VertDelay=figure('Name','  Vertical Retinotopy Delay','NumberTitle','off');
    imagesc(vert_delay)
    title(strcat(ExptID,' Vertical Retinotopy Delay -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hot
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
    %% save figures and variables
    Root_AnalDir = 'G:\Mouse3\Intrinsic Imaging\Kmaps\';
    AnalDir = strcat(Root_AnalDir,Anim,'\Figures\');
    AnalDir1 = strcat(Root_AnalDir,Anim,'\');
    filename5 = strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet1');
    filename8 = strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet2');
    filename9 = strcat(ExptID,'_LP',num2str(LP(x)),'_VertAnatomy');
    filename18= strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet3');
    filename19= strcat(ExptID,'_LP',num2str(LP(x)),'_VertMag');
    filename20= strcat(ExptID,'_LP',num2str(LP(x)),'_VertAng1');
    filename21= strcat(ExptID,'_LP',num2str(LP(x)),'_VertAng2');
    filename22= strcat(ExptID,'_LP',num2str(LP(x)),'_VertDelay');

    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
    saveas(VertRet1,strcat(AnalDir,filename5,'.tif'))
    saveas(VertRet1,strcat(AnalDir,filename5,'.fig'))
    saveas(VertRet2,strcat(AnalDir,filename8,'.tif'))
    saveas(VertRet2,strcat(AnalDir,filename8,'.fig'))
    saveas(Anatomy,strcat(AnalDir,filename9,'.tif'))
    saveas(Anatomy,strcat(AnalDir,filename9,'.fig'))
    saveas(VertRet3,strcat(AnalDir,filename18,'.tif'))
    saveas(VertRet3,strcat(AnalDir,filename18,'.fig'))
    saveas(VertMag,strcat(AnalDir,filename19,'.tif'))
    saveas(VertMag,strcat(AnalDir,filename19,'.fig'))
    saveas(VertAng1,strcat(AnalDir,filename20,'.tif'))
    saveas(VertAng1,strcat(AnalDir,filename20,'.fig'))
    saveas(VertAng1,strcat(AnalDir,filename21,'.tif'))
    saveas(VertAng1,strcat(AnalDir,filename21,'.fig'))
    saveas(VertDelay,strcat(AnalDir,filename22,'.tif'))
    saveas(VertDelay,strcat(AnalDir,filename22,'.fig'))

close all

kret = struct('LP', LP,...
    'AzExpt', AzExpt,...
    'Horiz_ExptID', Horiz_ExptID,...
    'Horiz_Analyzer', Horiz_Analyzer,...
    'kmap_hor_phase', kmap_hor_phase,...
    'kmap_hor', kmap_hor_ecc,...
    'Horiz_ang0', horiz_ang0,...
    'Horiz_ang1', horiz_ang1,...
    'Horiz_ang2', horiz_ang2,...
    'Horiz_ang3', horiz_ang3,...
    'Horiz_magS', hoirz_magS,...
    'Horiz_delay', horiz_delay,...
    'Horiz_overlay', horiz_overlay,...
    'AltExpt', AzExpt,...
    'Vert_ExptID', Vert_ExptID,...
    'Vert_Analyzer', Vert_Analyzer,...
    'kmap_vert_phase', kmap_vert_phase,...
    'kmap_vert', kmap_vert_ecc,...
    'Vert_ang0', vert_ang0,...
    'Vert_ang1', vert_ang1,...
    'Vert_ang2', vert_ang2,...
    'Vert_ang3', vert_ang3,...
    'Vert_magS', vert_magS,...
    'Vert_delay', vert_delay,...
    'Vert_overlay', vert_overlay,...
    'AnatomyPic',anatomypic,...
    'xsize', xsize,...
    'ysize', ysize,...)


end
