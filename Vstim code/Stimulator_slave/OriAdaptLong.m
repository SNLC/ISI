%function OriAdaptLong

%screen parameters
global Mstate screenPTR screenNum 

Mstate.monitor='LCD';
screenconfig

%stimulus parameters
x_size=40;
y_size=40;
x_pos=490;
y_pos=225;
mask_radius=20;
ori=190;
s_freq=.05;
st_profile='square';

t_period=25;
s_duty=0.5;
contrast=100;
ncyc_total=1000; %nr of cycles total
ncyc_dir=100; %nr of cycles per direction

Adapttxtr=[];


screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;



%The following assumes the screen is curved.  It will give 
%a slightly wrong stimulus size when they are large.

xcm = 2*pi*Mstate.screenDist*x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels



%create basic stuff for grating 
xdom = linspace(-x_size/2,x_size/2,xN);
ydom = linspace(-y_size/2,y_size/2,yN);
[xdom ydom] = meshgrid(xdom,ydom);

sdom = xdom*cos(ori*pi/180) - ydom*sin(ori*pi/180);    %deg
sdom = sdom*s_freq*2*pi; %radians


sdom2 = xdom*cos((ori+180)*pi/180) - ydom*sin((ori+180)*pi/180);    %deg
sdom2 = sdom2*s_freq*2*pi; %radians


%tdom = single(linspace(0,2*pi,t_period+1));
tdom = linspace(0,2*pi,t_period+1);
tdom = tdom(1:end-1);


%make mask
r = sqrt(xdom.^2 + ydom.^2);
mask = zeros(size(r));
id = find(r<=mask_radius);
mask(id) = 1;
%mask = single(mask);



%make forward grating
for i = 1:length(tdom)
    Im = cos(sdom - tdom(i));
    
    switch st_profile
        case 'sin'
            Im = Im*contrast/100;  %[-1 1]
            
        case 'square'
            thresh = cos(s_duty*pi);
            Im = sign(Im-thresh);
            Im = Im*contrast/100;
    end
    
    Im = Im.*mask;
    
  
    
    Im=(Im+1)/2; %to convert to range [0 1]
    ImRGB=repmat(round(Im*255),[1 1 3]);
    
     
     
    Adapttxtr(1,i) = Screen(screenPTR, 'MakeTexture', ImRGB);
end


   

%make reverse grating
%im2=zeros(size(ImRGB));
for i = 1:length(tdom)
    Im = cos(sdom2 - tdom(i));
    switch st_profile
        case 'sin'
            Im = Im*contrast/100;  %[-1 1]
            
        case 'square'
            thresh = cos(s_duty*pi);
            Im = sign(Im-thresh);
            Im = Im*contrast/100;
    end
    
    Im = Im.*mask;
    
    Im=(Im+1)/2; %to convert to range [0 1]
    
    ImRGB=repmat(round(Im*255),[1 1 3]);
   
    Adapttxtr(2,i) = Screen(screenPTR, 'MakeTexture', ImRGB);
end    
 

%play grating
%%%%%Play adapting stimulus
xran = [x_pos-floor(xN/2)+1  x_pos+ceil(xN/2)];
yran = [y_pos-floor(yN/2)+1  y_pos+ceil(yN/2)];
StimLoc = [xran(1) yran(1) xran(2) yran(2)]';
StimPiece = [0 0 size(sdom,2)-1 size(sdom,1)-1]';

gratdir=0;
for j = 1:ncyc_total
    if mod(j,ncyc_dir)==0
        gratdir=~gratdir;
    end
    for i=1:length(tdom)
        Screen('DrawTexture', screenPTR, Adapttxtr(gratdir+1,i),StimPiece,StimLoc);
        Screen(screenPTR, 'Flip');
    end
end



