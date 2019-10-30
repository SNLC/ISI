function makeRainTexture_polar

global Mstate screenPTR screenNum 

global GtxtrAll OriAll StimPiece TDim  %'playgrating' will use these

Screen('Close')  %First clean up: Get rid of all textures/offscreen windows

GtxtrAll = []; OriAll = []; StimLoc = []; TDim = [];  %reset

screenNum = 0;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black
gray = (white+black)/2;
amp = white-gray;

P = getParamStruct;


%Make black/white domain
if P.bw_bit == 0
    bwdom = -1;
elseif P.bw_bit == 1
    bwdom = 1;
else
    bwdom = [-1 1];
end


%The following assumes the screen is curved
xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %grid width in cm
xN = round(xcm*pixpercmX);  %grid width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %grid height in cm
yN = round(ycm*pixpercmY);  %grid height in pixels

barxcm = 2*pi*Mstate.screenDist*P.barWidth/360;  %bar width in cm
barxN = round(barxcm*pixpercmX);  %bar width in pixels
barycm = 2*pi*Mstate.screenDist*P.barLength/360;   %bar height in cm
baryN = round(barycm*pixpercmY);  %bar height in pixels

Im = ones(yN+baryN,xN+barxN);
Im = Im*P.contrast/100;
TDim = size(Im); 

for bwid = 1:length(bwdom)
    Gtxtr(bwid) = Screen(screenPTR, 'MakeTexture', gray+amp*Im*bwdom(bwid));
end

%%%Make domains%%%
xdom = linspace(0,xN,P.Nx) + barxN/2; %Make x domain  (these are the center locations of the bar)
ydom = linspace(0,yN,P.Ny) + baryN/2; %Make y domain

%Make orientation domain
oridom = linspace(P.ori,P.ori+360,P.n_ori+1);  %It goes to 360 because it is actually 'direction'
oridom = oridom(1:end-1);
%Make bw domain
if P.bw_bit == 0 || P.bw_bit == 1
    bwdom = 1;
else
    bwdom = [1 2];
end
%%%%%%%%%%%%%%%%%%

N_Im = round(P.stim_time*screenRes.hz/P.h_per); %number of images to present

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create independent sequence for each parameter

s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',P.rseed);

TDim2(1) = TDim(1)*P.x_zoom;  %Size of texture on the screen
TDim2(2) = TDim(2)*P.y_zoom;


%Preallocate!!!
StimLoc = cell(N_Im,P.h_per);
OriAll = cell(1,N_Im);
GtxtrAll = cell(1,N_Im);
for i = 1:N_Im
    for j = 1:P.h_per
        StimLoc{i,j} = zeros(4,P.Ndrops);        
    end
    OriAll{i} = zeros(1,P.Ndrops);
    GtxtrAll{i} = zeros(1,P.Ndrops);
end


%TextPiece = cell(1,N_Im);

for k = 1:P.Ndrops
    
    xseq = round(rand(s,1,N_Im)*P.Nx+.5);  %The sequence for each drop
    xseq = xdom(xseq);
   
    yseq = round(rand(s,1,N_Im)*P.Ny+.5);
    yseq = ydom(yseq);
    
    oriseq = round(rand(s,1,N_Im)*length(oridom)+.5);
    
    bwseq = round(rand(s,1,N_Im)*length(bwdom)+.5); %this should remain an index value
    
    %Define the borders of the bar within the screen
    
%     for i = 1:length(oriseq)
%         textW(i) = TDim2{oriseq(i)}(2);
%         textL(i) = TDim2{oriseq(i)}(1);
%     end
    
    xseqL = xseq-barxN/2;
    xseqR = xseq+barxN/2;
    yseqL = yseq-baryN/2;
    yseqR = yseq+baryN/2;
    
    Dinc = 2*Mstate.screenDist*tan(P.speed/2*pi/180);  %cm increment per frame
    
    for i = 1:N_Im
        xinc = Dinc*cos(oridom(oriseq(i))*pi/180);
        yinc = -Dinc*sin(oridom(oriseq(i))*pi/180);  %negative because origin is at top
        for j = 1:P.h_per
            dx = (j-1)*xinc;
            dx = round(dx*pixpercmX);  %convert to pixels
            dy = (j-1)*yinc;
            dy = round(dy*pixpercmY);  %convert to pixels
            xseqL2 = xseqL(i)+dx;
            xseqR2 = xseqR(i)+dx;
            yseqL2 = yseqL(i)+dy;
            yseqR2 = yseqR(i)+dy;

            StimPiece{i,j}(:,k) = [xseqL2 yseqL2 xseqR2 yseqR2]';
        end
        
        
        
        OriAll{i}(k) = -oridom(oriseq(i));
        GtxtrAll{i}(k) = Gtxtr(bwseq(i));
        

    end    
    
end


