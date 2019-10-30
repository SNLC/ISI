function makeCohMotion
%this function generates random dots a la Britten et al, 1993
%on every frame, pixels are randomly assigned to be noise or signal pixels;
%the noise pixels are randomly relocated, the signal pixels follow the
%preset orientation; wrap around is handled by placing the pixel that run
%out on the opposite side (see longer explanation below); wrap around is 
%tested after the dots have been assigned their new locations; dots can have
%limited lifetime


global Mstate DotFrame screenNum loopTrial;


%get parameters
Pstruct = getParamStruct;

%get screen settings
screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second

%this calculation is based on the assumption that the screen is round
pxDeg = 2*pi/360*Mstate.screenDist*screenRes.width/Mstate.screenXcm;  % pixels per degree




%if mask selected, set the stimulus size to fit the
%radius
if strcmp(Pstruct.mask_type,'disc')
    stimSize=[2*Pstruct.mask_radius 2*Pstruct.mask_radius];
    maskradiusPx=round(Pstruct.mask_radius*pxDeg);
else %otherwise get preset numbers
    stimSize=[Pstruct.x_size Pstruct.y_size];
end

%conversion of parameters to pixels
stimSizePx=round(stimSize*pxDeg);


%figure out how many dots
stimArea=stimSize(1)*stimSize(2);
nrDots=round(Pstruct.dotDensity*stimArea/fps); %this is the number of dots in each frame

%figure out how many frames - we use the first and the last frame to be
%shown in the pre and postdelay, so only stimulus duration matters here
nrFrames=ceil(Pstruct.stim_time*fps);


%initialize random number generate to time of date
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+loopTrial);


%initialize dot positions
randpos=rand(s,2,nrDots); %this gives numbers between 0 and 1
randpos(1,:)=(randpos(1,:)-0.5)*stimSizePx(1); %now we have between -stimsize/2 and +stimsize/2
randpos(2,:)=(randpos(2,:)-0.5)*stimSizePx(2);

%get displacement vectors per frame
deltaFrame = Pstruct.speedDots*pxDeg/fps;                            % dot speed (pixels/frame)
deltaX=deltaFrame*cos(Pstruct.ori*pi/180);
deltaY=-1*deltaFrame*sin(Pstruct.ori*pi/180);

%initialize lifetime vector - between 1 and dotLifetimte
if Pstruct.dotLifetime>0
    randlife=randi(s,Pstruct.dotLifetime,nrDots,1);
    lifetime=randlife;
end

%initialize signal/noise vector; 1 indicates signal, 0 indicates noise
nrSignal=round(nrDots*Pstruct.dotCoherence/100);
noisevec=zeros(nrDots,1);
noisevec(1:nrSignal)=1;


xypos=randpos;

DotFrame={};

for i=1:nrFrames
    
    %check lifetime (unless inf)
    if Pstruct.dotLifetime>0
        idx=find(lifetime==0);
        temppos=rand(s,2,length(idx));
        temppos(1,:)=(temppos(1,:)-0.5)*stimSizePx(1); 
        temppos(2,:)=(temppos(2,:)-0.5)*stimSizePx(2);
        xypos(:,idx)=temppos;
        
        lifetime=lifetime-1;
        lifetime(idx)=dotLifetime;
    end
    
    %generate new positions - this is different for noise and signal pixels
    
    noiseid=noisevec(randperm(s,nrDots));
    
    %signal dots go with preset orientation
    idx=find(noiseid==1);
    xypos(1,idx)=xypos(1,idx)+deltaX;
    xypos(2,idx)=xypos(2,idx)+deltaY;

    %noise dots are randomly placed somewhere
    idx=find(noiseid==0);
    temppos=rand(s,2,length(idx));
    temppos(1,:)=(temppos(1,:)-0.5)*stimSizePx(1);
    temppos(2,:)=(temppos(2,:)-0.5)*stimSizePx(2);
    xypos(:,idx)=temppos;
    
    %check which ones are outside of the boundaries, and wrap around
    %logic behind this algorithm: the angle of movement determines the
    %probability with which a stimulus edge will be chosen; for this, compute the
    %projection of the movement vector onto the axes first (x=cos(ori),
    %y=sin(ori), then compute the ratio between them as
    %abs(x)/(abs(x)+abs(y)). the ratio will be 0 if the stimulus moves
    %along the y axis, 1 if it moves along the x axis, 0.5 for 45 deg,
    %and so forth; we'll randomly draw a number between 0 and 1 and compare it with the
    %ratio to determine which stimulus edge to place the dot on; the
    %dot will then randomly placed somewhere along this edge
    %we use the same square bounding box independent of the mask, so for
    %a circle dots may be placed outside the boundary and only appear a
    %little later
        
    
    %get projection of movement vector onto axes
    xproj=cos(Pstruct.ori*pi/180);
    yproj=-sin(Pstruct.ori*pi/180);
    
    %find out how many dots are out of the stimulus window
    idx=find(abs(xypos(1,:))>stimSizePx(1)/2 | abs(xypos(2,:))>stimSizePx(2)/2);
        
    %reset to the other side of the stimulus
    rvec=rand(s,size(idx));
    for j=1:length(idx)
        if rvec(j)<= abs(xproj)/(abs(xproj)+abs(yproj))
            %y axis chosen, so place stimulus at the other x axis and a
            %random y location
            xypos(1,idx(j))=-1*sign(xproj)*stimSizePx(1)/2;
            xypos(2,idx(j))=(rand(s,1)-0.5)*stimSizePx(2);
        else
            %x axis chosen
            xypos(1,idx(j))=(rand(s,1)-0.5)*stimSizePx(1);
            xypos(2,idx(j))=-1*sign(yproj)*stimSizePx(2)/2;
        end
    end
    
   
    
    
    %if there is a mask, find the dots that are inside its radius
    if strcmp(Pstruct.mask_type,'disc')
        [th,rad]=cart2pol(xypos(1,:),xypos(2,:));
        idx=find(rad<maskradiusPx);
    else
        idx=[1:size(xypos,2)];
    end
    
    
    DotFrame{i}=xypos(:,idx);
    
end
    
