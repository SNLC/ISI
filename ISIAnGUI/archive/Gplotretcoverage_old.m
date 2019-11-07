function Gplotretcoverage(angx,magx,angy,magy)       

%angx and angy are in degrees of visual field.  
%Important: angx goes from left to right, and angy goes from bottom to top
%to match the x_pos and y_pos domain

global bw pepANA

screenDist = pepANA.config.display.viewingDistance;
screenRes = pepANA.config.display.pixelspercm;

x_size = get(pepANA.module,'x_size');
y_size = get(pepANA.module,'y_size');
x_pos = get(pepANA.module,'x_pos');
y_pos = get(pepANA.module,'y_pos');

x_size_pix = 2*screenDist*tan(x_size/2*pi/180)*screenRes;
y_size_pix = 2*screenDist*tan(y_size/2*pi/180)*screenRes;
xrange = [x_pos-x_size_pix/2 x_pos+x_size_pix/2]; 
yrange = [y_pos-y_size_pix/2 y_pos+y_size_pix/2];

Nx = 512; Ny = 512;

angx = Nx*angx/x_size;
angx = ceil(angx+eps);

angy = Ny*angy/y_size; %Normalize between 0 and Ny
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
Xticklabs = round(x_size_pix*Xticklocs/Nx + xrange(1));
Yticklabs = round(y_size_pix*Yticklocs/Ny + yrange(1));

set(gca,'XTickLabel',{num2str(Xticklabs(1)),num2str(Xticklabs(2)),num2str(Xticklabs(3)),num2str(Xticklabs(4)),num2str(Xticklabs(5)),num2str(Xticklabs(6))})
set(gca,'YTickLabel',{num2str(Yticklabs(1)),num2str(Yticklabs(2)),num2str(Yticklabs(3)),num2str(Yticklabs(4)),num2str(Yticklabs(5)),num2str(Yticklabs(6))})
xlabel('x position (pixels)'),ylabel('y position (pixels)')
axis xy    %Flip axis and image from top to bottom because y_pos domain goes starts at the bottom

