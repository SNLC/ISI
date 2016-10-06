function generatekret(anim,AzExpt,AltExpt,LP)

%% VARIABLES ------------
% generatekret('R43','000_005','000_004')
% anim='R44';
% AzExpt='000_005';
% AltExpt='000_006';

figTag = 0; %if you want to see hor/vert ret figures
intensityFigTag = 1; %if you want to see intensity maps

%set low/highpass smoothing values
LPdim = size(LP);
HP = zeros(LPdim);

%% process data for various LP smothing
for x=1:length(LP)
    
    %% SET FILE DIRECTORIES  --------------
    AnalyzerDir = 'E:\AnalyzerFiles\';
    ProcessedDir = 'E:\ProcessedData\';
    GrabDir = 'E:\RawData\';
    SaveDir = strcat('E:\AnalyzedData\',anim,'\');
    
    if exist(SaveDir,'dir') == 0;
        mkdir(SaveDir)
    end
    
    
    %% HORIZONTAL RETINOTOPY -----------
    Anim=anim;
    Expt=strcat('u',AzExpt);
    Expt1=AzExpt;
    ExptID = strcat(anim,'_',Expt);
    Horiz_ExptID = ExptID;
    
    %% GET ANALYZER FILE
    AnaDir = [AnalyzerDir,anim,'\',ExptID '.analyzer'];
    load(AnaDir,'Analyzer','-mat')
    
    % confirm this is the horiz ret expt
    if strcmp(Analyzer.P.param{12}(3), 'altitude') == 1;
        disp('Experiments entered incorrectly.')
        pause
    end
    
    Horiz_Analyzer = Analyzer;
    
    %% GET PROCESSED DATA
    filename=strcat(Anim,'_',Expt1,'.mat');
    filepath=strcat(ProcessedDir,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
    
    %one axes hack
    if length(f1m) == 2
        f1m{3} = f1m{2};
        f1m{4} = f1m{3};
        f1m{2} = f1m{1};
    end
    
    %% GET ANATOMY IMAGE
    Anatdir=[GrabDir Anim,'/grabs/'];
    D = dir([Anatdir '*.mat']);
    pic=D(001).name;
    filename=strcat(Anatdir, pic);
    image=load(filename);
    anatomypic_orig=image.grab.img;
    
    %%
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
    %% run processkret
    
    [kmap_hor kmap_vert delay_hor delay_vert magS ang0 ang1 ang2 ang3] = Gprocesskret_generatekmaps(f1m,bw,L,H);
    
    xsize = Analyzer.P.param{6}{3};
    horscfactor = xsize/360;
    kmap_hor1 = kmap_hor*horscfactor; %puts kmap into eccentricity values instead of phase
    
    %% flip everything to be oriented correctly
    kmap_hor1 = fliplr(kmap_hor1);
    % kmap_hor1 = rot90(kmap_hor1);
    % kmap_hor1 = rot90(kmap_hor1);
    % kmap_hor1 = rot90(kmap_hor1);
    %
    anatomypic=anatomypic_orig;
    anatomypic = fliplr(anatomypic);
    % anatomypic = rot90(anatomypic);
    % anatomypic = rot90(anatomypic);
    % anatomypic = rot90(anatomypic);
    
    ang0 = fliplr(ang0);
    % ang0 = rot90(ang0);
    % ang0 = rot90(ang0);
    % ang0 = rot90(ang0);
    
    ang1 = fliplr(ang1);
    % ang1 = rot90(ang1);
    % ang1 = rot90(ang1);
    % ang1 = rot90(ang1);
    
    ang2 = fliplr(ang2);
    % ang2 = rot90(ang2);
    % ang2 = rot90(ang2);
    % ang2 = rot90(ang2);
    
    ang3 = fliplr(ang3);
    % ang3 = rot90(ang3);
    % ang3 = rot90(ang3);
    % ang3 = rot90(ang3);
    
    magS.hor = fliplr(magS.hor);
    % magS.hor = rot90(magS.hor);
    % magS.hor = rot90(magS.hor);
    % magS.hor = rot90(magS.hor);
    
    delay_hor = fliplr(delay_hor);
    % delay_hor = rot90(delay_hor);
    % delay_hor = rot90(delay_hor);
    % delay_hor = rot90(delay_hor);
    
    %% threshold by normalized response mag
    thresh=0.05; % typically range including 0.05, 0.07, 0.1
    for y=1:length(thresh)
        raw_horiz_mag=magS.hor; %mag=response magnitude for each pixel (from processkret)
        mag = raw_horiz_mag.^1.1; % increase difference in values in mag to separate
        mag = mag-min(mag(:));
        mag = mag/max(mag(:)); % normalize mag from 0 (min value) to 1 (max value)
        magROI=mag; %magROI = mask of pixels above threshold
        id_belowthresh = find(magROI(:)<thresh(y)); %find pixels above and below thresh
        id_abovethresh = find(magROI(:)>=thresh(y));
        magROI(id_belowthresh) = NaN; %pixels below threshold are NaNs
        magROI(id_abovethresh) =1; %pixels above threshold are 1
        kmap_thresh=magROI.*kmap_hor1; %apply mask to kmap
        horiz_ret_thresh{y}=kmap_thresh; %thresholded map
        horiz_resp_mag=mag; % normalized response magnitude
        horiz_resp_mag_ROI{y}=magROI; %normalized response magnitude threshold mask
    end
    
    %% rename variables for saving
    kmap_hor_ecc=kmap_hor1;
    kmap_hor_phase=kmap_hor;
    horiz_ang0=ang0;
    horiz_ang1=ang1;
    horiz_ang2=ang2;
    horiz_ang3=ang3;
    horiz_delay=delay_hor;
    
    % %threshold by delay
    % a=size(horiz_delay);
    % delayROI=zeros(a(1),a(2));
    % id_delay = find(horiz_delay(:,:)<120 & horiz_delay(:,:)>=50); %find pixels above and below thresh
    % delayROI(id_delay) = 1; %pixels below threshold are NaNs
    % delayROI(id_delay_high) =1; %pixels above threshold are 1
    %
    
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
    %scale kmap and overlay with anatomypic
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
    
%% PLOT FIGURES
  
if figTag == 1;
    
    Anatomy=figure('Name','  Anatomy','NumberTitle','off','Visible','off');
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
    imagesc(kmap_hor1,[-60 60])
    title(strcat(ExptID,' Horizontal Retinotopy -LP ',num2str(LP(x))),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hsv
    colorbar('SouthOutside','FontSize',12,'XTick',[-70:20:70]);
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

    % save figures
    AnalDir = strcat(SaveDir,'KretFigures/');
    if iscell(AnalDir)
        AnalDir=AnalDir{1};
    end
    if exist(AnalDir) == 0
        mkdir(AnalDir)
    end
    
    filename5 = strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet1');
    filename8 = strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet2');
    filename9 = strcat(ExptID,'_LP',num2str(LP(x)),'_HorizAnatomy');
    filename18= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet3');
    filename19= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizMag');
    filename20= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizAng1');
    filename21= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizAng2');
    filename22= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizDelay');
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
    saveas(HorizAng2,strcat(AnalDir,filename21,'.tif'))
    saveas(HorizAng2,strcat(AnalDir,filename21,'.fig'))
    saveas(HorizDelay,strcat(AnalDir,filename22,'.tif'))
    saveas(HorizDelay,strcat(AnalDir,filename22,'.fig'))
    
    close all
    
end

%% PLOT INTENSITY FIGURES

if intensityFigTag == 1;
    
    ResponseMag = figure(8);
    set(8,'Position',[0,0,1500,800])
    
    subplot(2,3,1)
    imagesc(raw_horiz_mag)
    title(strcat('Horiz Ret Raw Response Mag'),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','Arial','YTickLabel',[],'XTickLabel',[]);
    set(gcf,'Color','w')
    colormap gray; freezeColors;
    h = colorbar('EastOutside','FontSize',10); %cbfreeze(h);
    axis equal; axis tight
    
    subplot(2,3,2)
    imagesc(horiz_resp_mag)
    title(strcat('Horiz Ret Normalized Response Mag'),'FontSize',12,'Interpreter','none');
    set(gca,'FontName','Arial','YTickLabel',[],'XTickLabel',[]);
    set(gcf,'Color','w')
    colormap hot; freezeColors;
    h = colorbar('EastOutside','FontSize',10); %cbfreeze(h);
    axis equal; axis tight
    
    subplot(2,3,3)
    imagesc(kmap_hor1,'AlphaData',horiz_resp_mag,[-60 60])
    title(strcat('Horiz Ret Scaled by Norm Response Mag'),'FontSize',12,'Interpreter','none')
    colormap hsv; freezeColors;
    h = colorbar('SouthOutside','FontSize',10,'XTick',[-80:20:80]); %cbfreeze(h);
    set(gcf,'Color','w');
    set(gca,'FontName','Arial','YTickLabel',[],'XTickLabel',[]);
    axis equal; axis tight


end
   
    %% PLOT AND SAVE THRESHOLDED MAPS
    if figTag == 1;
        
        for y=1:length(thresh)
            %make threshold colormap so that values less than thresh (now set to maxval+1) are white
            colormap hsv;
            cmap=colormap;
            threshmap=cmap;
            lastcolor=length(threshmap)+1;
            threshmap(1,:) = ([1 1 1]);
            
            HorizRet_Thresh=figure('Name','Horizontal Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
            imagesc(horiz_ret_thresh{y},[-60 60])
            title(strcat(ExptID,' Horizontal Retinotopy LP ',num2str(LP(x)),' Thresholded by_',num2str(thresh(y))),'FontSize',14,'Interpreter','none')
            colormap(threshmap)
            colorbar('SouthOutside','FontSize',12,'XTick',[-60:20:60])
            set(gcf,'Color','w');
            set(gca,'FontName','arial');
            axis equal
            axis tight
            
            filename23= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet_Thresh_',num2str(thresh(y)));
            saveas(HorizRet_Thresh,strcat(AnalDir,filename23,'.tif'))
            saveas(HorizRet_Thresh,strcat(AnalDir,filename23,'.fig'))
        end
    end
        
%%  VERTICAL RETINOTOPY ---------------------------------------------------------

    Expt=strcat('u',AltExpt);
    Expt1=AltExpt;
    ExptID = strcat(anim,'_',Expt);
    Vert_ExptID=ExptID;
    
    %% GET ANALYZER
    AnaDir=[AnalyzerDir,anim,'\',ExptID '.analyzer'];
    load(AnaDir,'Analyzer','-mat')
    Vert_Analyzer = Analyzer;
    
%% GET PROCESSED DATA
    filename=strcat(Anim,'_',Expt1,'.mat');
    filepath=strcat(ProcessedDir,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
    %one axes hack
    if length(f1m) == 2
        f1m{3} = f1m{2};
        f1m{4} = f1m{3};
        f1m{2} = f1m{1};
    end
    
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
    
%% RUN PROCESS KRET
    [kmap_hor kmap_vert delay_hor delay_vert magS ang0 ang1 ang2 ang3] = Gprocesskret_generatekmaps(f1m,bw,L,H);
    
    ysize = Analyzer.P.param{7}{3};
    vertscfactor = ysize/360;
    kmap_vert1 = kmap_vert*vertscfactor; %puts kmap into eccentricity values instead of phase
    
    %% flip everything to be oriented correctly
    
    kmap_vert1 = fliplr(kmap_vert1);
    % kmap_vert1 = rot90(kmap_vert1);
    % kmap_vert1 = rot90(kmap_vert1);
    % kmap_vert1 = rot90(kmap_vert1);
    
    anatomypic=anatomypic_orig;
    anatomypic = fliplr(anatomypic);
    % anatomypic = rot90(anatomypic);
    % anatomypic = rot90(anatomypic);
    % anatomypic = rot90(anatomypic);
    
    ang0 = fliplr(ang0);
    % ang0 = rot90(ang0);
    % ang0 = rot90(ang0);
    % ang0 = rot90(ang0);
    
    ang1 = fliplr(ang1);
    % ang1 = rot90(ang1);
    % ang1 = rot90(ang1);
    % ang1 = rot90(ang1);
    
    ang2 = fliplr(ang2);
    % ang2 = rot90(ang2);
    % ang2 = rot90(ang2);
    % ang2 = rot90(ang2);
    
    ang3 = fliplr(ang3);
    % ang3 = rot90(ang3);
    % ang3 = rot90(ang3);
    % ang3 = rot90(ang3);
    
    magS.vert = fliplr(magS.vert);
    % magS.vert = rot90(magS.vert);
    % magS.vert = rot90(magS.vert);
    % magS.vert = rot90(magS.vert);
    
    delay_vert = fliplr(delay_vert);
    % delay_vert = rot90(delay_vert);
    % delay_vert = rot90(delay_vert);
    % delay_vert = rot90(delay_vert);
    
    %% threshold by normalized response mag
    % thresh=[0.05 0.07 0.1];
    for y=1:length(thresh)
        raw_mag = magS.vert; %mag=response magnitude for each pixel (from processkret)
        mag = raw_mag.^1.1; % increase difference in values in mag to separate
        mag = mag-min(mag(:));
        mag = mag/max(mag(:)); % normalize mag from 0 (min value) to 1 (max value)
        magROI=mag; %magROI = mask of pixels above threshold
        id_belowthresh = find(magROI(:)<thresh(y)); %find pixels above and below thresh
        id_abovethresh = find(magROI(:)>=thresh(y));
        magROI(id_belowthresh) = NaN; %pixels below threshold are NaNs
        magROI(id_abovethresh) =1; %pixels above threshold are 1
        kmap_thresh=magROI.*kmap_vert1; %apply mask to kmap
        vert_ret_thresh{y}=kmap_thresh; %thresholded map
        vert_resp_mag=mag; % normalized response magnitude
        vert_resp_mag_ROI{y}=magROI; %normalized response magnitude threshold mask
    end
    
    %% rename variables for saving
    kmap_vert_ecc=kmap_vert1;
    kmap_vert_phase=kmap_vert;
    vert_ang0=ang0;
    vert_ang1=ang1;
    vert_ang2=ang2;
    vert_ang3=ang3;
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
    %overlay hsv kmap with gray anatomypic
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
    
%% PLOT FIGURES
if figTag == 1;
    
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
    
    VertMag=figure('Name','  Vertical Retinotopy Response Magnitude','NumberTitle','off');
    imagesc(vert_resp_mag)
    title(strcat(ExptID,' Vertical Retinotopy Response Magnitude LP ',num2str(LP(x))),'FontSize',14,'Interpreter','none');
    set(gca,'FontName','arial');
    set(gcf,'Color','w')
    colormap hot
    colorbar('EastOutside','FontSize',12);
    axis equal
    axis tight
    
    
    AnalDir = strcat(SaveDir,'KretFigures/');
    
    filename5 = strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet1');
    filename8 = strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet2');
    filename9 = strcat(ExptID,'_LP',num2str(LP(x)),'_VertAnatomy');
    filename18= strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet3');
    filename19= strcat(ExptID,'_LP',num2str(LP(x)),'_VertMag');
    filename20= strcat(ExptID,'_LP',num2str(LP(x)),'_VertAng1');
    filename21= strcat(ExptID,'_LP',num2str(LP(x)),'_VertAng2');
    filename22= strcat(ExptID,'_LP',num2str(LP(x)),'_VertDelay');
    filename25= strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet_RespMag');
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
    saveas(VertAng2,strcat(AnalDir,filename21,'.tif'))
    saveas(VertAng2,strcat(AnalDir,filename21,'.fig'))
    saveas(VertDelay,strcat(AnalDir,filename22,'.tif'))
    saveas(VertDelay,strcat(AnalDir,filename22,'.fig'))
    saveas(VertRet_RespMag,strcat(AnalDir,filename25,'.tif'))
    saveas(VertRet_RespMag,strcat(AnalDir,filename25,'.fig'))
    
end

%% PLOT INTENSITY FIGURES

if intensityFigTag == 1;

    RespMag = figure(8);
    
    subplot(2,3,4)
    imagesc(raw_mag)
    title(strcat('Vert Ret Raw Response Mag'),'FontSize',12,'Interpreter','none')
    colormap gray; freezeColors;
    h = colorbar('EastOutside','FontSize',10); %cbfreeze(h);
    set(gcf,'Color','w');
    set(gca,'FontName','Arial','YTickLabel',[],'XTickLabel',[]);
    axis equal; axis tight
    
    subplot(2,3,5);
    imagesc(vert_resp_mag)
    title(strcat('Vert Ret Normalized Response Mag'),'FontSize',12,'Interpreter','none')
    colormap hot; freezeColors;
    h = colorbar('EastOutside','FontSize',10); %cbfreeze(h);
    set(gcf,'Color','w');
    set(gca,'FontName','Arial','YTickLabel',[],'XTickLabel',[]);
    axis equal; axis tight
    
    subplot(2,3,6)
    imagesc(kmap_vert1,'AlphaData',vert_resp_mag,[-30 70])
    title(strcat('Vert Ret Scaled by Norm Response Mag'),'FontSize',12,'Interpreter','none')
    colormap hsv; freezeColors;
    h = colorbar('EastOutside','FontSize',10,'XTick',[-30:10:70]); %cbfreeze(h);
    set(gcf,'Color','w');
    set(gca,'FontName','Arial','YTickLabel',[],'XTickLabel',[]);
    axis equal; axis tight
    
    respMagFilename = strcat(anim,'_LP',num2str(LP(x)),'_ResponseMag');
    saveas(RespMag,strcat(SaveDir,respMagFilename,'.tif'))
    saveas(RespMag,strcat(SaveDir,respMagFilename,'.fig'))
    close all
    
end
   
    %% plot and save thresholded maps
    
    if figTag == 1;
        
        for y=1:length(thresh)
            %make threshold colormap so that values less than thresh (now set to maxval+1) are white
            colormap hsv;
            cmap=colormap;
            threshmap=cmap;
            lastcolor=length(threshmap)+1;
            threshmap(1,:) = ([1 1 1]);
            
            VertRet_Thresh=figure('Name','Vertical Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
            imagesc(vert_ret_thresh{y},[-30 70])
            title(strcat(ExptID,' Vertical Retinotopy LP ',num2str(LP(x)),' Thresholded by_',num2str(thresh(y))),'FontSize',14,'Interpreter','none')
            colormap(threshmap)
            colorbar('EastOutside','FontSize',12,'XTick',[-30:10:70])
            set(gcf,'Color','w');
            set(gca,'FontName','arial');
            axis equal
            axis tight
            
            filename23= strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet_Thresh_',num2str(thresh(y)));
            saveas(VertRet_Thresh,strcat(AnalDir,filename23,'.tif'))
            saveas(VertRet_Thresh,strcat(AnalDir,filename23,'.fig'))
        end
    end
    
    close all
    

%% CREATE COMBINED THRESHOLD MAP
    for y=1:length(thresh)
        a=size(kmap_hor1);
        combinedROI=zeros(a(1),a(2));
        exclusiveROI=zeros(a(1),a(2));
        id_included_horiz = find(horiz_resp_mag_ROI{y}==1);
        id_included_vert = find(vert_resp_mag_ROI{y}==1);
        %make mask where pixels that are included in both horiz and vert resp mag
        %thresholds are set to 1 and non included or included in only one are NaNs
        exclusiveROI(id_included_horiz)=1;
        exclusiveROI(id_included_vert)=exclusiveROI(id_included_vert)+1;
        id_ones_ex = find(exclusiveROI==1);
        exclusiveROI(id_ones_ex)=NaN;
        id_zeros_ex = find(exclusiveROI==0);
        exclusiveROI(id_zeros_ex)=NaN;
        id_twos_ex = find(exclusiveROI==2);
        exclusiveROI(id_twos_ex)=1;
        %make mask where pixels included in either horiz or vert resp mag
        %thresholds are set to 1
        combinedROI(id_included_horiz)=1;
        combinedROI(id_included_vert)=1;
        id_zeros = find(combinedROI==0);
        combinedROI(id_zeros)=NaN;
        %multipy maps by masks
        horiz_map_thresh=combinedROI.*kmap_hor1;
        vert_map_thresh=combinedROI.*kmap_vert1;
        horiz_map_thresh_ex=exclusiveROI.*kmap_hor1;
        vert_map_thresh_ex=exclusiveROI.*kmap_vert1;
        horiz_ret_thresh_combinedROI{y}=horiz_map_thresh;
        vert_ret_thresh_combinedROI{y}=vert_map_thresh;
        resp_mag_combinedROI{y}=combinedROI;
        horiz_ret_thresh_exclusiveROI{y}=horiz_map_thresh_ex;
        vert_ret_thresh_exclusiveROI{y}=vert_map_thresh_ex;
        resp_mag_exclusiveROI{y}=exclusiveROI;
        
    end
    
    %% PLOT AND SAVE COMBINED THRESHOLD MAP
    
    if figTag == 1;
        
        for y=1:length(thresh)
            %make threshold colormap so that values less than thresh (now set to maxval+1) are white
            colormap hsv;
            cmap=colormap;
            threshmap=cmap;
            lastcolor=length(threshmap)+1;
            threshmap(1,:) = ([1 1 1]);
            
            VertRet_CombinedThresh=figure('Name','Vertical Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
            imagesc(vert_ret_thresh_combinedROI{y},[-30 70])
            title(strcat(ExptID,' Vertical Retinotopy LP ',num2str(LP(x)),' ComboThresh_',num2str(thresh(y))),'FontSize',14,'Interpreter','none')
            colormap(threshmap)
            colorbar('EastOutside','FontSize',12,'XTick',[-30:10:70])
            set(gcf,'Color','w');
            set(gca,'FontName','arial');
            axis equal
            axis tight
            
            HorizRet_CombinedThresh=figure('Name','Horizontal Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
            imagesc(horiz_ret_thresh_combinedROI{y},[-60 60])
            title(strcat(ExptID,' Horizontal Retinotopy LP ',num2str(LP(x)),' ComboThresh_',num2str(thresh(y))),'FontSize',14,'Interpreter','none')
            colormap(threshmap)
            colorbar('SouthOutside','FontSize',12,'XTick',[-60:20:60])
            set(gcf,'Color','w');
            set(gca,'FontName','arial');
            axis equal
            axis tight
            
            VertRet_ExclusiveThresh=figure('Name','Vertical Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
            imagesc(vert_ret_thresh_exclusiveROI{y},[-30 70])
            title(strcat(ExptID,' Vertical Retinotopy LP ',num2str(LP(x)),' ExclusiveThresh_',num2str(thresh(y))),'FontSize',14,'Interpreter','none')
            colormap(threshmap)
            colorbar('EastOutside','FontSize',12,'XTick',[-30:10:70])
            set(gcf,'Color','w');
            set(gca,'FontName','arial');
            axis equal
            axis tight
            
            HorizRet_ExclusiveThresh=figure('Name','Horizontal Retinotopy- Thresholded','NumberTitle','off','OuterPosition',[200, 200, 800, 800]);
            imagesc(horiz_ret_thresh_exclusiveROI{y},[-60 60])
            title(strcat(ExptID,' Horizontal Retinotopy LP ',num2str(LP(x)),' ExclusiveThresh_',num2str(thresh(y))),'FontSize',14,'Interpreter','none')
            colormap(threshmap)
            colorbar('SouthOutside','FontSize',12,'XTick',[-60:20:60])
            set(gcf,'Color','w');
            set(gca,'FontName','arial');
            axis equal
            axis tight
            
            filename27= strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet_CombinedThresh_',num2str(thresh(y)));
            saveas(VertRet_CombinedThresh,strcat(AnalDir,filename27,'.tif'))
            saveas(VertRet_CombinedThresh,strcat(AnalDir,filename27,'.fig'))
            filename28= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet_CombinedThresh_',num2str(thresh(y)));
            saveas(HorizRet_CombinedThresh,strcat(AnalDir,filename28,'.tif'))
            saveas(HorizRet_CombinedThresh,strcat(AnalDir,filename28,'.fig'))
            filename31= strcat(ExptID,'_LP',num2str(LP(x)),'_VertRet_ExclusiveThresh_',num2str(thresh(y)));
            saveas(VertRet_ExclusiveThresh,strcat(AnalDir,filename31,'.tif'))
            saveas(VertRet_ExclusiveThresh,strcat(AnalDir,filename31,'.fig'))
            filename32= strcat(ExptID,'_LP',num2str(LP(x)),'_HorizRet_ExclusiveThresh_',num2str(thresh(y)));
            saveas(HorizRet_ExclusiveThresh,strcat(AnalDir,filename32,'.tif'))
            saveas(HorizRet_ExclusiveThresh,strcat(AnalDir,filename32,'.fig'))
        end
        
    end
    
    close all

%% SAVE VARIABLES

    for y=1:length(thresh)
        
        kret = struct('LP', LP(x),...
            'thresh',thresh(y),...
            'AzExpt', AzExpt,...
            'Horiz_ExptID', Horiz_ExptID,...
            'Horiz_Analyzer', Horiz_Analyzer,...
            'kmap_hor_phase', kmap_hor_phase,...
            'kmap_hor', kmap_hor_ecc,...
            'horiz_ang0', horiz_ang0,...
            'horiz_ang1', horiz_ang1,...
            'horiz_ang2', horiz_ang2,...
            'horiz_ang3', horiz_ang3,...
            'horiz_delay', horiz_delay,...
            'horiz_overlay', horiz_overlay,...
            'horiz_resp_mag', horiz_resp_mag,...
            'horiz_ret_thresh', horiz_ret_thresh{y},...
            'horiz_resp_mag_ROI', horiz_resp_mag_ROI{y},...
            'horiz_ret_thresh_combinedROI', horiz_ret_thresh_combinedROI{y},...
            'horiz_ret_thresh_exclusiveROI', horiz_ret_thresh_exclusiveROI{y},...
            'AltExpt', AzExpt,...
            'Vert_ExptID', Vert_ExptID,...
            'Vert_Analyzer', Vert_Analyzer,...
            'kmap_vert_phase', kmap_vert_phase,...
            'kmap_vert', kmap_vert_ecc,...
            'vert_ang0', vert_ang0,...
            'vert_ang1', vert_ang1,...
            'vert_ang2', vert_ang2,...
            'vert_ang3', vert_ang3,...
            'vert_delay', vert_delay,...
            'vert_overlay', vert_overlay,...
            'vert_resp_mag', vert_resp_mag,...
            'vert_ret_thresh', vert_ret_thresh{y},...
            'vert_resp_mag_ROI', vert_resp_mag_ROI{y},...
            'vert_ret_thresh_combinedROI', vert_ret_thresh_combinedROI{y},...
            'vert_ret_thresh_exclusiveROI', vert_ret_thresh_exclusiveROI{y},...
            'resp_mag_combinedROI', resp_mag_combinedROI{y},...
            'resp_mag_exclusiveROI', resp_mag_exclusiveROI{y},...
            'AnatomyPic',anatomypic,...
            'xsize', xsize,...
            'ysize', ysize);
        
        AnalDir1 = strcat(SaveDir,'/Kmaps/');
        if iscell(AnalDir1)
            AnalDir1=AnalDir1{1};
        end
        if exist(AnalDir1) == 0
            mkdir(AnalDir1)
        end
        filename43= strcat(AnalDir1,Anim,'_LP',num2str(LP(x)),'_Thresh_',num2str(thresh(y)),'_kret.mat');
        save(filename43,'kret')
        
    end
    
close all

end %ends LP loop
