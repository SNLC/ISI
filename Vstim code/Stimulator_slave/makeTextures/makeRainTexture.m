function makeRainTexture

global Mstate screenPTR screenNum 

global GtxtrAll OriAll StimLoc TDim  %'playgrating' will use these

Screen('Close')  %First clean up: Get rid of all textures/offscreen windows

GtxtrAll = []; OriAll = []; StimLoc = []; TDim = [];  %reset

screenNum = 0;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

P = getParamStruct;

barW = 2*Mstate.screenDist*tan(P.barWidth/2*pi/180);  %bar width in cm
barW = barW*pixpercmX; %bar width in pixels
barL = 2*Mstate.screenDist*tan(P.barLength/2*pi/180);  %bar length in cm
barL = barL*pixpercmY; %bar length in pixels

barW = round(barW/P.x_zoom);
barL = round(barL/P.y_zoom);

%Make black/white domain for texture creation (these are different from the bw/color domains created below)
if P.bw_bit == 0
    bwdom = -1;
elseif P.bw_bit == 1
    bwdom = 1;
else
    bwdom = [-1 1];
end

colordom = getColorDomain(P.colorspace);

Im = ones(barL,barW);
Im = Im*P.contrast/100;
TDim = size(Im); 
for bwid = 1:length(bwdom)
    for colorid = 1:length(colordom)
        Gtxtr(bwid,colorid) = putinTexture(Im*bwdom(bwid),colordom(colorid),P);
    end
end

%%%
%%This next part used to be in 'playrain', but for really big stimuli it took too long and messed up COM timing%%%%%
%%%

%The following assumes the screen is curved
xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels

% xcm = 2*Mstate.screenDist*tan(P.x_size*pi/180/2);  %stimulus width in cm
% xN = round(xcm*pixpercmX)  %stimulus width in pixels
% ycm = 2*Mstate.screenDist*tan(P.y_size*pi/180/2);   %stimulus height in cm
% yN = round(ycm*pixpercmY);  %stimulus height in pixels

%These define the perimeters of the "location grid"
xran = [P.x_pos-ceil(xN/2)+1  P.x_pos+floor(xN/2)];
yran = [P.y_pos-ceil(yN/2)+1  P.y_pos+floor(yN/2)];

%%%Make domains%%%
xdom = linspace(xran(1),xran(2),P.Nx); %Make x domain  (these are the center locations of the bar)
ydom = linspace(yran(1),yran(2),P.Ny); %Make y domain
%Make orientation domain
if P.speed ~= 0
    oridom = linspace(P.ori,P.ori+360,P.n_ori+1);  %It goes to 360 because it is actually 'direction'
else 
    oridom = linspace(P.ori,P.ori+180,P.n_ori+1);
end
oridom = oridom(1:end-1);
%Make bw domain
if P.bw_bit == 0 || P.bw_bit == 1
    bwdom = 1;
else
    bwdom = [1 2];
end
%Make color domain
if strcmp(P.colorspace,'DKL') || strcmp(P.colorspace,'LMS')
    colordom = [1 2 3];
else
    colordom = 1;
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



for k = 1:P.Ndrops

    xseqId = round(rand(s,1,N_Im)*length(xdom)+.5);  %The sequence for each drop
    xseq = xdom(xseqId);

    yseqId = round(rand(s,1,N_Im)*length(ydom)+.5);
    yseq = ydom(yseqId);

    oriseq = round(rand(s,1,N_Im)*length(oridom)+.5);

    if strcmp(P.gridType,'polar')

        xseqRot = (xseq-P.x_pos).*cos(-oridom(oriseq)*pi/180) - (yseq-P.y_pos).*sin(-oridom(oriseq)*pi/180);
        yseqRot = (xseq-P.x_pos).*sin(-oridom(oriseq)*pi/180) + (yseq-P.y_pos).*cos(-oridom(oriseq)*pi/180);

        xseq = xseqRot+P.x_pos;
        yseq = yseqRot+P.y_pos;

    end

    bwseq = round(rand(s,1,N_Im)*length(bwdom)+.5); %this should remain an index value
    
    colorseq = round(rand(s,1,N_Im)*length(colordom)+.5); %this should remain an index value

    xseqL = xseq-(ceil(TDim2(2)/2)-1);
    xseqR = xseq+floor(TDim2(2)/2);
    yseqL = yseq-(ceil(TDim2(1)/2)-1);
    yseqR = yseq+floor(TDim2(1)/2);

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

            StimLoc{i,j}(:,k) = [xseqL2 yseqL2 xseqR2 yseqR2]';
        end

        %StimPiece{i} = [StimPiece{i} [0 0 TDim2{oriseq(i)}(2)-1 TDim2{oriseq(i)}(1)-1]'];


        OriAll{i}(k) = -oridom(oriseq(i));
        GtxtrAll{i}(k) = Gtxtr(bwseq(i),colorseq(i));


    end

end

domains = struct;
domains.oridom = oridom;
domains.xdom = xdom;
domains.ydom = ydom;
domains.bwdom = bwdom;
domains.colordom = colordom;

if Mstate.running %if its in the looper
    
    saveLog_rain(domains)
    
    Pseq.oriseq = oriseq;
    Pseq.xseq = xseqId;
    Pseq.yseq = yseqId;
    Pseq.bwseq = bwseq;
    Pseq.colorseq = colorseq;
    saveLog_rain(Pseq,P.rseed)  %append log file with the latest sequence

end




function Gtxtr = putinTexture(Im,colortype,P)

global screenPTR

%%%%%%%%%%%%%%%%%%%%%%%
%Equate Contrast: This is a total hack%%
if strcmp(P.colorspace,'DKL')
    switch colortype
        case 4 %S
            Im = Im*.15/.82 * 3;
        case 5 %L-M
            Im = Im;
        case 6 %L+M
            Im = Im*.15/1.0;
    end
elseif strcmp(P.colorspace,'LMS')
    switch colortype
        case 2 %L
            Im = Im;
        case 3 %M
            Im = Im*.2/.23;
        case 4 %S
            Im = Im*.2/.82 * 3;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

Idraw = ImtoRGB(Im,colortype,P,[]);
Gtxtr = Screen(screenPTR, 'MakeTexture', Idraw);