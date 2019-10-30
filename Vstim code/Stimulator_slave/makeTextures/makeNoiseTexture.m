function makeNoiseTexture

%make one cycle of the grating

global Mstate screenPTR screenNum 

global Gtxtr TDim  %'playgrating' will use these

Screen('Close')  %First clean up: Get rid of all textures/offscreen windows

Gtxtr = []; TDim = [];  %reset

screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

P = getParamStruct;

%The following assumes the screen is curved
xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black
gray = (white+black)/2;
amp = white-gray;

N_Im = round(P.stim_time*screenRes.hz/P.h_per); %number of images to present

xN = round(xN/P.x_zoom);  %Downsample for the zoom
yN = round(yN/P.y_zoom);

%Set sample rates
Fx = xN/xcm; %pixels/cm (sample rate)
Fy = yN/ycm; %pixels/cm
Ft = Mstate.refresh_rate; %frames/sec

%Set Fourier domains
Fxdom = single(linspace(-Fx/2,Fx/2,xN)); %cycles/cm
Fydom = single(linspace(-Fy/2,Fy/2,yN)); %cycles/cm
%Ftdom = single(linspace(-Ft/2,Ft/2,N_Im)); %cycles/sec

[Fxdom Fydom] = meshgrid(Fxdom,Fydom);

sf = sqrt(Fxdom.^2 + Fydom.^2);

Ht = getFilt(N_Im,Ft,P.h_per,P.tlp_cutoff,P.thp_cutoff);
Hxy = 1./(sf.^P.freq_decay);

Hxy(round(yN/2),round(xN/2),:) = 0;

Hxy = fftshift(fftshift(Hxy,1),2);

RandStream.setDefaultStream(RandStream('mt19937ar','seed',P.rseed)); 

Im = rand(yN,xN,N_Im,'single');  %Make it single instead of double to save memory

Im = round(Im);

Im = Filt_xy(Im,Hxy); 

Im = Filt_t(Im,Ht); 

Im = real(Im);

    
switch P.tAmp_profile
    
    case 'sin'        
        
        Nt = length(Im(1,1,:));
        Ncyc = Nt/P.tAmp_period;
        tdom = single(linspace(0,2*pi*Ncyc,Nt));
        A = sin(tdom);
        for i = 1:length(Im(1,1,:))
            Im(:,:,i) = Im(:,:,i)*A(i);
        end
        
    case 'square'
        
        Nt = length(Im(1,1,:));
        Ncyc = Nt/P.tAmp_period;
        tdom = single(linspace(0,2*pi*Ncyc,Nt));
        A = sign(sin(tdom));
        for i = 1:length(Im(1,1,:))
            Im(:,:,i) = Im(:,:,i)*A(i);
        end
        
end


Im = Im-min(Im(:));
Im = Im*white/max(Im(:));  %0 to 255
Im = Im-gray;
Im = Im*P.contrast/100 + gray;  %0 to 255

Im = uint8(Im);  %'Screen' won't take 'single' as an input

for i = 1:N_Im
    Gtxtr(i) = Screen(screenPTR, 'MakeTexture', Im(:,:,i));
end

TDim = size(Im);

function  Im = Filt_xy(Im,H)

dim = size(Im);
for z = 1:dim(3)
    Im(:,:,z) = fft2(Im(:,:,z)).*H;  %2D FFT and filter
    Im(:,:,z) = ifft2(Im(:,:,z));
end


function  Im = Filt_t(Im,H)

dim = size(Im);
Hmat = ones(dim(2),1)*H;

for z = 1:dim(1)
    dum = squeeze(Im(z,:,:));
    dum = fft(dum,[],2).*Hmat;  %1D FFT and filter
    Im(z,:,:) = ifft(dum,[],2);
end


function H = getFilt(N_Im,Ft,hper,tlp,thp)
% 

fdom = linspace(-Ft/hper/2,Ft/hper/2,N_Im);  %cycles/sec
%fdom = fdom(1:end-1);

if tlp > Ft/hper/2  %it can't be greater than the Nyquist    
    Hlp = ones(1,length(fdom));    
else    
    Hlp = 1./(1+(fdom./tlp).^2);    
end

Hhp = 1./(1+(thp./fdom).^2);
H = Hlp.*Hhp;

H = fftshift(H);