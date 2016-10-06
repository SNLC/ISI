function VertRet(saveFlag)
saveFlag;
% after running processf1, run the following

global anim expt Conditions kmap_hor kmap_vert
ExptID = strcat(anim,'_',expt); 

% f1 = f1meanimage;  %Build F1 images (takes the longest)
% L = fspecial('gaussian',15,1);  %make spatial filter
% bw = ones(size(f1{1}));
% [kmap_hor kmap_vert] = processkret(f1,bw,L);  %Make maps to plot, delete L if no smoothing

ysize = getparam('y_size');
vertscfactor = ysize/360;
kmap_vert = kmap_vert*vertscfactor;

VertRet=figure('Name','Vertical Retinotopy','NumberTitle','off');
    imagesc(kmap_vert,[-ysize/2 ysize/2])
    title('Vertical Retinotopy ','FontSize',16)
    set(gcf,'Color','w')
    colorbar
    colormap hsv
    truesize

VertRet_Contour=figure('Name','Vertical Retinotopy- Contour','NumberTitle','off');
    [C,h]=contour(kmap_vert);
    contour(kmap_vert)
    clabel(C,'manual')
    set(gcf,'Color','w')
    colormap winter
    title('Vertical Retinotopy Contour','FontSize',16)
    axis ij
    
    
VertRet_Contour=figure('Name','Vertical Retinotopy- Borders','NumberTitle','off');
    borders=[-50 -40 -30 40 50 60]; 
    [C,h]=contour(kmap_vert,borders);
    clabel(C,'manual')
    set(gcf,'Color','w')
    colormap winter
    title('Vertical Retinotopy Borders','FontSize',16)
    colorbar
    axis ij
    
 
    
    
    if saveFlag == 1
    %Paths for saving data and plots
    Root_AnalDir = '/Users/marinagarrett/MapCortex/AnalyzedData_2P/';
    AnalDir = strcat(Root_AnalDir,anim,'/',ExptID,'_VertRet','/');
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
        saveas(VertRet,strcat(AnalDir,ExptID,'_VertRet.fig'))
        saveas(VertRet,strcat(AnalDir,ExptID,'_VertRet.tif'))
        saveas(VertRet,strcat(AnalDir,ExptID,'_VertRet.eps'))
        saveas(VertRet_Contour,strcat(AnalDir,ExptID,'_VertRet_Contour.fig'))
        saveas(VertRet_Contour,strcat(AnalDir,ExptID,'_VertRet_Contour.tif'))
        saveas(VertRet_Contour,strcat(AnalDir,ExptID,'_VertRet_Contour.eps'))
    end
end

FigureHandles = [VertRet, VertRet_Contour, Conditions];

button = questdlg('Would you like to close all the figure windows?','Close figures?','Close all','No','No');
if strcmp(button, 'Close all')
    close (FigureHandles)
elseif strcmp(button, 'No')
end


    