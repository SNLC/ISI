function Gplotretcoverage(angx,magx,angy,magy)       

%angx and angy are in degrees of visual field.  
%Important: angx goes from left to right, and angy goes from bottom to top
%to match the x_pos and y_pos domain

global bw pepANA

screenDist = pepANA.config.display.viewingDistance;
screenResX = pepANA.config.display.pixelspercm;  %Should be 24.42
screenResY = pepANA.config.display.pixelspercm;
%%%
%screenResY = (1022-380)/24;  %For unknown reason, screen res is different in y direction
%%%                          %This is my estimate

%Gets position and width of bars for each condition, excluding blanks:
[xpos ypos xsize ysize] = getPosSize;

xposdom = sort(xpos);
xposdom(isnan(xposdom)) = [];
xsize_cm = (xposdom(end)-xposdom(1)+min(xsize))/screenResX;
xsize_deg = 2*atan2(xsize_cm/2,screenDist)*180/pi;

yposdom = sort(ypos);
yposdom(isnan(yposdom)) = [];
ysize_cm = (yposdom(end)-yposdom(1)+min(ysize))/screenResY;
ysize_deg = 2*atan2(ysize_cm/2,screenDist)*180/pi;  %convert to deg

xrange = [xposdom(1)-min(xsize)/2 xposdom(end)+min(xsize)/2];
yrange = [yposdom(1)-min(ysize)/2 yposdom(end)+min(ysize)/2];

Nx = 512; Ny = 512;

angx = Nx*angx/xsize_deg;
angx = ceil(angx+eps);

angy = Ny*angy/ysize_deg; %Normalize between 0 and Ny
angy = ceil(angy+eps);  %Set the range to be 1 to N

implot = zeros(Ny,Nx);

posID = angy(:) + (angx(:)-1)*Ny;

locality = sqrt(magx + magy);

locality = locality-min(locality(:));
locality = locality/max(locality(:));
locality = locality.*bw;

implot(posID) = locality(:);

imagesc(implot), colormap gray
Xticklocs = 0:100:Nx; 
Yticklocs = 0:100:Ny;
set(gca,'Ytick',Yticklocs,'Xtick',Xticklocs);
Xticklabs = round(screenResX*xsize_cm*Xticklocs/Nx);
%Yticklabs = round(screenResY*ysize_cm*Yticklocs/Ny) + 380;
Yticklabs = round(screenResY*ysize_cm*Yticklocs/Ny);

set(gca,'XTickLabel',{num2str(Xticklabs(1)),num2str(Xticklabs(2)),num2str(Xticklabs(3)),num2str(Xticklabs(4)),num2str(Xticklabs(5)),num2str(Xticklabs(6))})
set(gca,'YTickLabel',{num2str(Yticklabs(1)),num2str(Yticklabs(2)),num2str(Yticklabs(3)),num2str(Yticklabs(4)),num2str(Yticklabs(5)),num2str(Yticklabs(6))})
xlabel('x position (pixels)'),ylabel('y position (pixels)')
axis xy    %Flip axis and image from top to bottom because y_pos domain starts at the bottom

