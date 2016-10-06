function HorizRet(saveFlag)
saveFlag;
%saveFlag = 1 or 0.  When equals 1, the figures will be automatically saved
%in fig, tif and eps formats.

global anim expt Conditions maskS kmap_hor kmap_vert
ExptID = strcat(anim,'_',expt); 

% f1 = f1meanimage;  %Build F1 images (takes the longest)
% L = fspecial('gaussian',15,1);  %make spatial filter
% bw = ones(size(f1{1}));
% [kmap_hor kmap_vert] = processkret(f1,maskS.bwCell{1},L);  %Make maps to plot, delete L if no smoothing

xsize = getparam('x_size');
horscfactor = xsize/360;
kmap_hor = kmap_hor*horscfactor;

HorizRet=figure('Name','Horizontal Retinotopy','NumberTitle','off');
    imagesc(kmap_hor,[-xsize/2 xsize/2])
    title('Horizontal Retinotopy ','FontSize',16)
    colorbar('SouthOutside')
    set(gcf,'Color','w')
    colormap hsv
    truesize

HorizRet_Contour=figure('Name','Horizontal Retinotopy- Contour','NumberTitle','off');
    [C,h]=contour(kmap_hor);
    contour(kmap_hor)
    clabel(C,'manual')
    title('Horizontal Retinotopy Contour  ','FontSize',16)
    set(gcf,'Color','w')
    colormap autumn
    axis ij
   
    
HorizRet_Contour=figure('Name','Horizontal Retinotopy- Contour','NumberTitle','off');
    borders=[-60 -50 -40 40 50 60]; 
    contour(kmap_hor,borders)
    clabel(C,'manual')
    title('Horizontal Retinotopy Borders  ','FontSize',16)
    set(gcf,'Color','w')
    colormap hsv
    colorbar
    axis ij
    
    
if saveFlag == 1
    %Paths for saving data and plots
    Root_AnalDir = '/Users/marinagarrett/MapCortex/AnalyzedData_2P/';
    AnalDir = strcat(Root_AnalDir,anim,'/',ExptID,'_HorizRet','/');
    if exist(AnalDir) == 0
        mkdir(AnalDir)
        ContinueTag = 1;
    elseif exist(AnalDir) == 7
        button = questdlg('Warning: The directory already exists for this experiment.  Hit Cancel to stop the save function.','Overwrite data?','Overwrite','Cancel','Cancel');
        if strcmp(button,'Overwrite') == 1
            ContinueTag = 1;
        elseif strcmp(button,'Cancel') == 1
            ContinueTag = 1;
            error('Save operation canceled by user. Consider renaming existing PopAnalysis directories and redoing the analysis.');
        end
    end
    if ContinueTag == 1
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.fig'))
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.tif'))
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.eps'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.fig'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.tif'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.eps'))
    end
end

FigureHandles = [HorizRet, HorizRet_Contour, Conditions];

button = questdlg('Would you like to close all the figure windows?','Close figures?','Close all','No','No');
if strcmp(button, 'Close all')
    close (FigureHandles)
elseif strcmp(button, 'No')
end
