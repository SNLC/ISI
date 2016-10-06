function plotISImaps

%%
anim='m85';
expt='000_004';
AltAz='azimuth';
AltAz='altitude';

%% HorizRet
if strcmp('azimuth',AltAz)==1
AzAnim=anim;
AzExpt=strcat('u',expt);
AzExpt1=expt;
ExptID = strcat(anim,'_',AzExpt); 

%get analyzer file
Dir = 'C:\neurodata\AnalyzerFiles\';
Anadir=[Dir AzAnim,'\params ',ExptID '.mat'];
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

LP=[0,2];
%%
for x=1:length(LP)
if LP(x)==0
    L=0;
    bw = ones(size(f1m{1}));
else
L = fspecial('gaussian',15,LP(x));  %make LP spatial filter
bw = ones(size(f1m{1}));
end
[kmap_hor kmap_vert delay_hor delay_vert sh magS] = Gprocesskret_batch(f1m,bw,L);

xsize = Analyzer.P.param{10}{3};
horscfactor = xsize/360;
kmap_hor = kmap_hor*horscfactor; %puts kmap into eccentricity values instead of phase

kmap_hor = fliplr(kmap_hor);
kmap_hor = rot90(kmap_hor);
kmap_hor = rot90(kmap_hor);
kmap_hor = rot90(kmap_hor);

%flip and rotate mag and ang to orient correctly 
mag = fliplr(mag);
mag = rot90(mag);
mag = rot90(mag);
mag = rot90(mag);

%%
if x==1
%% plot threshold maps
mag = magS; %mag=response magnitude for each pixel
ang = kmap_hor; %ang=phase of each pixel. 

%put kmap in ecc values instead of phase
xsize = Analyzer.P.param{10}{3};
horscfactor = xsize/360;
kmap_hor_ecc = kmap_hor*horscfactor; %puts kmap into eccentricity values instead of phase

ang_orig=ang;
mag_orig=mag; %save original magnitude image before filtering and thresholding

ang=kmap_hor_ecc;%scale angle values to be ecc instead of phase

%filter 
h = fspecial('gaussian',size(mag),1.5);
h = abs(fft2(h));
magf = ifft2(h.*fft2(mag));

%normalize 
mag = magf.^0.5; % increase difference in values in mag to separate 
mag = mag-min(mag(:));
mag = mag/max(mag(:)); % normalize mag from 0 (min value) to 1 (max value)

%threshold and make mask of values above threshold
magROI=mag; %mag ROI of pixels above threshold
thresh = .3;
id_belowthresh = find(magROI(:)<thresh);
id_abovethresh = find(magROI(:)>=thresh);
magROI(id_belowthresh) = NaN;
magROI(id_abovethresh) =1;

kmap_thresh=magROI.*kmap_hor_ecc; %make map where pixels above threshold have their ecc value and pixels below thresh are Nans
maxval = (max(kmap_thresh(:)));
maxval=maxval+1;
nanvals=find(isnan(kmap_thresh)); %find nanvalues
kmap_thresh(nanvals)=maxval; %assign maxval+1 to NaN values
  
%make threshold colormap so that values less than thresh (now set to maxval+1) are white
colormap hsv;
colormap(flipud(hsv)); 
cmap=colormap;
threshmap=cmap;
lastcolor=length(threshmap)+1;
threshmap(lastcolor,:) = ([1 1 1]);

%plot thresholded kmap
HorizRet_Thresh=figure('Name','Horizontal Retinotopy- Threshold Map','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
imagesc(kmap_thresh);
title(strcat(ExptID,' Horizontal Retinotopy - Threshold Map '),'FontSize',14,'Interpreter','none')
colormap(threshmap)
colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70])
set(gcf,'Color','w');
set(gca,'FontName','arial');
axis equal
axis tight

HorizRet_RespMag=figure('Name','Horizontal Retinotopy- Response Magnitude','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
imagesc(ang,'AlphaData',mag);
title(strcat(ExptID,' Horizontal Retinotopy - Response Magnitude '),'FontSize',14,'Interpreter','none')
colormap hsv;
colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70])
set(gcf,'Color','w');
set(gca,'FontName','arial');
axis equal
axis tight

%% regular maps
HorizRet_Raw=figure('Name','  Horizontal Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    imagesc(kmap_hor,[-70 70])
    title(strcat(ExptID,' Horizontal Retinotopy Raw '),'FontSize',16,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70])
    axis equal
    axis tight
end
    %% contour
if x==2
HorizRet_Contour=figure('Name','  Horizontal Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    contour(kmap_hor,[-70:20:70],'LineWidth',2)
    title(strcat(ExptID,' Horizontal Retinotopy -LP ',num2str(LP(x))),'FontSize',16,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70])
    axis ij
    axis equal
    axis tight
end
end
    %%
     %% save
    
     Root_AnalDir = 'D:\IntrinsicImaging\Analyzed Data_ISI\';
    AnalDir = strcat(Root_AnalDir,AzAnim,'\');
    filename1 = strcat(ExptID,'_HorizRet_Thresh');
    filename2 = strcat(ExptID,'_HorizRet_RespMag');
    filename3 = strcat(ExptID,'_HorizRet_Raw');
    filename4 = strcat(ExptID,'_HorizRet_Contour');
    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
        saveas(HorizRet_Thresh,strcat(AnalDir,filename1,'.fig'))
        saveas(HorizRet_Thresh,strcat(AnalDir,filename1,'.tif'))
        saveas(HorizRet_RespMag,strcat(AnalDir,filename2,'.fig')) 
        saveas(HorizRet_RespMag,strcat(AnalDir,filename2,'.tif'))
        saveas(HorizRet_Raw,strcat(AnalDir,filename3,'.fig'))
        saveas(HorizRet_Raw,strcat(AnalDir,filename3,'.tif'))
        saveas(HorizRet_Contour,strcat(AnalDir,filename4,'.tif'))
        saveas(HorizRet_Contour,strcat(AnalDir,filename4,'.fig'))  

end
    
 %% VertRet

if strcmp('altitude',AltAz)==1
AltAnim=anim;
AltExpt=strcat('u',expt);
AltExpt1=expt;
ExptID = strcat(anim,'_',AltExpt); 

%get analyzer file
Dir = 'C:\neurodata\AnalyzerFiles\';
Anadir=[Dir AltAnim,'\params ',ExptID '.mat'];
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

LP=[0,2];

%%
for x=1:length(LP)
if LP(x)==0
    L=0;
    bw = ones(size(f1m{1}));
else
L = fspecial('gaussian',15,LP(x));  %make LP spatial filter
bw = ones(size(f1m{1}));
end
[kmap_hor kmap_vert delay_hor delay_vert sh magS] = Gprocesskret_batch(f1m,bw,L);

ysize = Analyzer.P.param{10}{3};
vertscfactor = ysize/360;
kmap_vert = kmap_vert*vertscfactor; %puts kmap into eccentricity values instead of phase

kmap_vert = fliplr(kmap_vert);
kmap_vert = rot90(kmap_vert);
kmap_vert = rot90(kmap_vert);
kmap_vert = rot90(kmap_vert);

%flip and rotate mag and ang to orient correctly 
mag = fliplr(mag);
mag = rot90(mag);
mag = rot90(mag);
mag = rot90(mag);


%% 
if x==1
%% plot threshold maps
mag = magS; %mag=response magnitude for each pixel
ang = kmap_vert; %ang=phase of each pixel. 

%put kmap in ecc values instead of phase
ysize = Analyzer.P.param{10}{3};
vertscfactor = ysize/360;
kmap_vert_ecc = kmap_vert*vertscfactor; %puts kmap into eccentricity values instead of phase

ang_orig=ang;
mag_orig=mag; %save original magnitude image before filtering and thresholding

ang=kmap_vert_ecc;%scale angle values to be ecc instead of phase

%filter 
h = fspecial('gaussian',size(mag),1.5);
h = abs(fft2(h));
magf = ifft2(h.*fft2(mag));

%normalize 
mag = magf.^0.5; % increase difference in values in mag to separate 
mag = mag-min(mag(:));
mag = mag/max(mag(:)); % normalize mag from 0 (min value) to 1 (max value)

%threshold and make mask of values above threshold
magROI=mag; %mag ROI of pixels above threshold
thresh = .3;
id_belowthresh = find(magROI(:)<thresh);
id_abovethresh = find(magROI(:)>=thresh);
magROI(id_belowthresh) = NaN;
magROI(id_abovethresh) =1;

kmap_thresh=magROI.*kmap_vert_ecc; %make map where pixels above threshold have their ecc value and pixels below thresh are Nans
maxval = (max(kmap_thresh(:)));
maxval=maxval+1;
nanvals=find(isnan(kmap_thresh)); %find nanvalues
kmap_thresh(nanvals)=maxval; %assign maxval+1 to NaN values

%make threshold colormap so that values less than thresh (now set to maxval+1) are white
colormap hsv;
colormap(flipud(hsv)); 
cmap=colormap;
threshmap=cmap;
lastcolor=length(threshmap)+1;
threshmap(lastcolor,:) = ([1 1 1]);

%plot thresholded kmap
VertRet_Thresh=figure('Name','Vertical Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
imagesc(kmap_thresh,[-30 70]);
title(strcat(ExptID,' Vertical Retinotopy - Threshold Map '),'FontSize',14,'Interpreter','none')
colormap(threshmap)
colorbar('EastOutside','FontSize',12,'YTick',[-30:10:70])
set(gcf,'Color','w');
set(gca,'FontName','arial');
axis equal
axis tight

VertRet_RespMag=figure('Name','Vertical Retinotopy- ResponseMagnitude','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
imagesc(ang,'AlphaData',mag,[-30 70]);
title(strcat(ExptID,' Vertical Retinotopy - Response Magnitude '),'FontSize',14,'Interpreter','none')
colormap hsv;
colorbar('EastOutside','FontSize',12,'YTick',[-30:10:70])
set(gcf,'Color','w');
set(gca,'FontName','arial');
axis equal
axis tight

%% regular map
VertRet=figure('Name','  Vertical Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    imagesc(kmap_vert,[-30 70])
    title(strcat(ExptID,' Vertical Retinotopy Raw '),'FontSize',16,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('EastOutside','FontSize',12,'YTick',[-30:10:70])
    axis equal
    axis tight
end
    %%
if x==2

    VertRet_Contour=figure('Name','  Vertical Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
    contour(kmap_vert,[-30:10:70],'LineWidth',2)
    title(strcat(ExptID,' Vertical Retinotopy Contour '),'FontSize',16,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('EastOutside','FontSize',12,'YTick',[-30:10:70])
    axis ij
    axis equal
    axis tight
end
end
      %% save
    
     Root_AnalDir = 'D:\IntrinsicImaging\Analyzed Data_ISI\';
    AnalDir = strcat(Root_AnalDir,AltAnim,'\');
    filename1 = strcat(ExptID,'_VertRet_Thresh');
    filename2 = strcat(ExptID,'_VertRet_RespMag');
    filename3 = strcat(ExptID,'_VertRet_Raw');
    filename4 = strcat(ExptID,'_VertRet_Contour');
    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
        saveas(VertRet_Thresh,strcat(AnalDir,filename1,'.fig'))
        saveas(VertRet_Thresh,strcat(AnalDir,filename1,'.tif'))
        saveas(VertRet_RespMag,strcat(AnalDir,filename2,'.fig')) 
        saveas(VertRet_RespMag,strcat(AnalDir,filename2,'.tif'))
        saveas(VertRet_Raw,strcat(AnalDir,filename3,'.fig'))
        saveas(VertRet_Raw,strcat(AnalDir,filename3,'.tif'))
        saveas(VertRet_Contour,strcat(AnalDir,filename4,'.tif'))
        saveas(VertRet_Contour,strcat(AnalDir,filename4,'.fig'))  
end
end
%% 

        