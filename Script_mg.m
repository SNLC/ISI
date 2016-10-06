%Script for analyzing kalatsky retinotopy with 2photon data

f1 = f1meanimage;  %Build F1 images (takes the longest)
L = fspecial('gaussian',15,6);  %make spatial filter
bw = ones(size(f1{1}));
[kmap_hor kmap_vert] = processkret(f1,bw,L);  %Make maps to plot, delete L if no smoothing

%%%%%%%%%%%%%%%
%%
%%% need to do this individually after processing each orientation
kmap_hor1=kmap_hor;
kmap_vert1=kmap_vert;

%% 
%%%% for contour plots
global Analyzer

xsize=Analyzer.P.param{6}{3};
conversionfactor=xsize/360; %get degrees of visual space from degrees of phase
realspace_hor=kmap_hor1*conversionfactor;

ysize=Analyzer.P.param{7}{3};
conversionfactor=ysize/360;
realspace_vert=kmap_vert1*conversionfactor;


y=[-ysize:20:ysize];
x=[-xsize:20:xsize];


x=-150:20:150;

%% colorbars

figure
[C,h] = contour(realspace_hor,x);
contour(realspace_hor,x)
r = findobj('Type','patch');
set(r,'LineWidth',2)
colormap autumn
% clabel(C,'manual')
title('Horizontal Retinotopy','FontSize',16)
colorbar('SouthOutside','FontSize',16,'xtick',x)
colorbar('EastOutside','xtick',x)
set(findall(gcf,'Type','text'),'FontSize',16);
set(gcf,'Color', 'w');
axis square
scrsz = get(0,'ScreenSize');
set(gcf,'OuterPosition',[1 1 scrsz(3) 3*scrsz(4)])

figure
[C,l] = contour(realspace_vert,y);
contour(realspace_vert,y)
r = findobj('Type','patch');
set(r,'LineWidth',2)
colormap winter
% clabel(C,'manual')
title('Vertical Retinotopy','FontSize',16)
colorbar('EastOutside','FontSize',16,'xtick',x)
colorbar('SouthOutside','xtick',x)
set(findall(gcf,'Type','text'),'FontSize',16);
set(gcf,'Color', 'w');
axis square
scrsz = get(0,'ScreenSize');
set(gcf,'OuterPosition',[1 1 scrsz(3) 3*scrsz(4)])

%% solid colors

figure
[C,h] = contour(realspace_hor,x);
contour(realspace_hor,x,'r')
clabel(C,'manual')
r = findobj('Type','patch');
set(r,'LineWidth',3)
title('Horizontal Retinotopy','FontSize',16)
set(findall(gcf,'Type','text'),'FontSize',16);
set(gcf,'Color', 'w');
axis square
scrsz = get(0,'ScreenSize');
set(gcf,'OuterPosition',[1 1 scrsz(3) 3*scrsz(4)])

figure
[C,l] = contour(realspace_vert,y);
contour(realspace_vert,y,'b')
clabel (C,'manual')
r = findobj('Type','patch');
set(r,'LineWidth',3)
title('Vertical Retinotopy','FontSize',16)
set(findall(gcf,'Type','text'),'FontSize',16);
set(gcf,'Color', 'w');
axis square
scrsz = get(0,'ScreenSize');
set(gcf,'OuterPosition',[1 1 scrsz(3) 3*scrsz(4)])


%%
%%%% for regular plots

figure
imagesc(kmap_hor,[-180 180])
title('Horizontal Retinotopy')
colorbar('SouthOutside')
colormap hsv
truesize

figure
imagesc(kmap_vert,[-180 180])
title('Vertical Retinotopy')
colorbar
colormap hsv
truesize

%%
%%%% ians contour plots

figure
contour(kmap_hor1.*bw,-180:20:180,'r')
hold on
contour(kmap_vert1.*bw,-180:20:180,'b')
title('Contour')
axis ij     %'contour' plots inverted
hold off

%%%%%%%%%%%%%%%%%%

figure
imagesc(sh)
colormap gray
title('ROI Coverage of Stimulus Area')