function [angx magx angy magy yrange xrange] = Gprocessret(f0dum,bw,hh)

%f0dum is the cell array returned from fmeanimage.m
%'retmap' is in degrees from 0 to 360

global pepANA

bflag = 0;

k = 1;
for(i=0:length(f0dum)-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        ori(k) = round(90*v(2));
        f0{k} = f0dum{i+1};
        k = k+1;
    else
        f0blank = f0dum{i+1};
        bflag = 1;
    end
end

%Build Tensor of x and y direction
i = 1; j = 1;
for k = 1:length(f0)
    if ori(k) == 0
        Tensx(:,:,i) = f0{k};    
        i = i+1;
    elseif ori(k) == 90
        Tensy(:,:,j) = f0{k};    
        j = j+1;
    end
end

%Normalize tuning curve of each pixel
mix = min(Tensx,[],3);
miy = min(Tensy,[],3);
for i = 1:length(Tensx(1,1,:))
    if bflag == 1
        Tensx(:,:,i) = Tensx(:,:,i)-f0blank;
        Tensy(:,:,i) = Tensy(:,:,i)-f0blank;
    else
        Tensx(:,:,i) = Tensx(:,:,i)-mix;
        Tensy(:,:,i) = Tensy(:,:,i)-miy;
    end
end

sux = sum(abs(Tensx),3);
suy = sum(abs(Tensy),3);
id = find(sux(:)==0);
sux(id) = 1;
id = find(suy(:)==0);
suy(id) = 1;

for i = 1:length(Tensx(1,1,:))
    Tensx(:,:,i) = Tensx(:,:,i)./sux;
    Tensy(:,:,i) = Tensy(:,:,i)./suy;
end

%%%%%%%%%

[xpos ypos xsize ysize] = getPosSize; %Gets position and width of bars for each condition, excluding blanks

xposdom = sort(xpos);
xposdom(isnan(xposdom)) = [];
dphase = 360/length(xposdom);
xphasedom = (0:dphase:360-dphase) + dphase/2;

yposdom = sort(ypos);
yposdom(isnan(yposdom)) = [];
dphase = 360/length(yposdom);
yphasedom = (0:dphase:360-dphase) + dphase/2;

%%%Get xpos/ypos for each pixel
xloc = zeros(size(f0{1}));
yloc = zeros(size(f0{1}));
i = 1; j = 1;
for k = 1:length(f0)
    if ori(k) == 0
        phase = xphasedom(find(xpos(k) == xposdom));
        xloc = xloc + Tensx(:,:,i)*exp(1i*phase*pi/180);    %Linear combination
        i = i+1;
    elseif ori(k) == 90
        phase = yphasedom(find(ypos(k) == yposdom));
        yloc = yloc + Tensy(:,:,j)*exp(1i*phase*pi/180);    %Linear combination
        j = j+1;
    end
end

%if a filter exists, use it...
if ~isempty(hh)
    xloc = ifft2(abs(fft2(hh)).*fft2(xloc));
    yloc = ifft2(abs(fft2(hh)).*fft2(yloc));
end

%Compute stimulus width
screenDist = pepANA.config.display.viewingDistance;
screenResX = pepANA.config.display.pixelspercm;
screenResY = pepANA.config.display.pixelspercm;
%screenResY = (1022-380)/24;  %For unknown reason, screen res is different in y direction

xsize_cm = (xposdom(end)-xposdom(1)+min(xsize))/screenResX;  %cm stimulus width
xsize_deg = 2*atan2(xsize_cm/2,screenDist)*180/pi;  %convert to deg
ysize_cm = (yposdom(end)-yposdom(1)+min(ysize))/screenResY;  
ysize_deg = 2*atan2(ysize_cm/2,screenDist)*180/pi;  

%Compute screen location in degrees of visual field
angx = angle(xloc)*180/pi;
angx = angx + (1-sign(angx))*360/2; %0 to 360
angx = xsize_deg*angx/360; %Position in deg from left to right

angy = angle(yloc)*180/pi;
angy = angy + (1-sign(angy))*360/2;  
angy = ysize_deg*angy/360; 

%Normalized selectivity
magx = abs(xloc);
magy = abs(yloc);
magy = magy-min(magy(:));
magy = magy/max(magy(:));
magx = magx-min(magx(:));
magx = magx/max(magx(:));

