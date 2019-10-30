function makeGratingTexture_flash

%This one builds either a Cartesian or Hartley domain of gratings.  It makes the entire ensemble here.
%For the Cartesian case, the texture is only a line for each spatial
%frequence.  The play file rotates it... and will distort it if the pixels
%are not square.  This one allows for contrast reversal and drift.

global Mstate screenPTR screenNum loopTrial

global Gtxtr TDim Masktxtr domains probRatios %'playgrating' will use these

Screen('Close')  %First clean up: Get rid of all textures/offscreen windows

Gtxtr = []; TDim = [];  %reset

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black
gray = (white+black)/2;
amp = white-gray;

P = getParamStruct;
screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

% xcm = 2*Mstate.screenDist*tan(P.x_size/2*pi/180);  %grating width in cm
% xN = round(xcm*pixpercmX);  %grating width in pixels
% ycm = 2*Mstate.screenDist*tan(P.y_size/2*pi/180);  %grating height in cm
% yN = round(ycm*pixpercmY);  %grating height in pixels

%The following assumes the screen is curved.  It will give 
%a slightly wrong stimulus size when they are large.
xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels

xN = round(xN/P.x_zoom);  %Downsample for the zoom
yN = round(yN/P.y_zoom);

pixpercmX = pixpercmX/P.x_zoom;
pixpercmY = pixpercmY/P.y_zoom;

%create the mask
xdom = linspace(-P.x_size/2,P.x_size/2,xN);
ydom = linspace(-P.y_size/2,P.y_size/2,yN);
[xdom ydom] = meshgrid(xdom,ydom);
r = sqrt(xdom.^2 + ydom.^2);
maskblob = P.background*ones(yN,xN,2);

if strcmp(P.mask_type,'gauss')
    mask = exp((-r.^2)/(2*P.mask_radius^2));
else %disc is the default
    mask = zeros(size(r));
    id = find(r<=P.mask_radius);
    mask(id) = 1;
end

maskblob(:,:,2) = 255*(1-mask);
Masktxtr = Screen(screenPTR, 'MakeTexture', maskblob);
%%%%%%%%%


if ~P.FourierBit
    
    %Make spatial phase domain
    phasedom = linspace(0,360,P.n_phase+1);
    phasedom = phasedom(1:end-1);
    %Make orientation domain
    if P.separable
        orirange = 180;
    else
        orirange = 360;
    end
    oridom = linspace(P.ori,P.ori+orirange,P.n_ori+1);
    oridom = oridom(1:end-1);
    %Make spatial frequency domain
    if strcmp(P.sf_domain,'log')
        sfdom = logspace(log10(P.min_sf),log10(P.max_sf),P.n_sfreq);
    elseif strcmp(P.sf_domain,'lin')
        sfdom = linspace(P.min_sf,P.max_sf,P.n_sfreq);
    end
    
    sfdom = unique(sfdom);
    
    colordom = getColorDomain(P.colorspace);
    probRatios = ones(length(oridom),length(sfdom),length(phasedom),length(colordom));
    
    
    for sfid = 1:length(sfdom)
        
        %%%Get spatial profile%%%
        
        xcycles = sfdom(sfid) * P.x_size;
        %thetax = linspace(0,2*pi*xcycles,xN+1);
        pixpercycle = round(xN/xcycles);
        
        if sfdom(sfid) == 0
            pixpercycle = 2;
        end

        thetax = linspace(0,2*pi*(xcycles+1),xN+1+pixpercycle); %append with one extra cycle
        thetax = thetax(1:end-1);
        %thetax = ones(yN,1)*thetax;
        %thetax(Bads_x) = [];
        
        Im = cos(thetax);
        
        switch P.s_profile
            
            case 'sin'
                Im = Im*P.contrast/100;
                
            case 'square'
                thresh = cos(P.s_duty*pi);
                Im = sign(Im-thresh);
                Im = Im*P.contrast/100;
                
            case 'pulse'
                thresh = cos(P.s_duty*pi);
                Im = (sign(Im-thresh) + 1)/2;
                Im = Im*P.contrast/100;                
        end
        
        %%%Build textures (over time) differently for contrast reversing or drifting%%%
        
        if ~P.separable %drifting
            

            for colorID = 1:length(colordom)                
                putinTexture(Im,colordom,sfid,1,colorID,P)                
            end
            
            if P.blankProb > 0 && sfid == 1 %just do this once if blank is set    
                putinTexture(Im*0,colordom,length(sfdom)+1,1,1,P) %these indices signify 'blank'               
            end
    
            
        else  %contrast reversing (or flash)
            
            tdom = single(linspace(0,2*pi,P.t_period+1));
            tdom = tdom(1:end-1);
            amp = sin(tdom);
            
            switch P.t_profile
                
                case 'square'
                    thresh = cos(P.t_duty*pi);
                    amp = sign(amp-thresh);
                    
                case 'pulse'
                    thresh = cos(P.t_duty*pi);
                    amp = (sign(amp-thresh) + 1)/2;
                    
                case 'none'
                    
                    amp = ones(1,length(amp)); %standard 'Ringach'
                    
            end
            
            for tid = 1:length(tdom)
                
                Im2 = amp(tid)*Im;
                
                for colorID = 1:length(colordom)
                    putinTexture(Im2,colordom,sfid,tid,colorID,P)
                end
                
                if P.blankProb > 0 && sfid == 1 %just do this once if blank is set
                    putinTexture(Im*0,colordom,length(sfdom)+1,tid,1,P) %index 99 signifies 'blank'
                end
                
            end
            
            
        end
    end
    
    domains = struct;
    domains.oridom = oridom;
    domains.sfdom = sfdom;
    domains.phasedom = phasedom;
    domains.colordom = colordom;
    %important to know how the domain order within 'Gtxtr' for reconstructin the sequence...
    domains.higherarchy = {'ori','s_freq','phase','color'};
    
else  %Fourier Basis
    tic
    
    subspaceType = 'ring';
    
    xN = xN - rem(xN,2); %ensures an even number of points
    yN = yN - rem(yN,2);
    
    colordom = getColorDomain(P.colorspace);
    
    cmperdeg = (2*pi*Mstate.screenDist)/360;
    Fs_x = pixpercmX*cmperdeg;    %sample rate: pixels per degree
    Fs_y = pixpercmY*cmperdeg;
    nx = 0:xN-1;
    ny = 0:yN-1;
    dk = 1; %Downsample Hartley space
    kx = -xN/2:dk:xN/2-1;
    ky = -yN/2:dk:yN/2-1;
    
    %Take only the first quadrant;
    kx = kx(find(kx>=0)); 
    ky = ky(find(ky>=0));    
    [kxmat kymat] = meshgrid(kx,ky);
    
    [nxmat nymat] = meshgrid(nx,ny);
    
    sfxdom = (kxmat/xN)*Fs_x;  %convert to cycles/deg to define subspace
    sfydom = (kymat/yN)*Fs_y;
    if strcmp(subspaceType,'square')        
        kmatID = find(abs(sfxdom) <= P.max_sf & abs(sfxdom) >= P.min_sf & abs(sfydom) <= P.max_sf & abs(sfydom) >= P.min_sf);       
    elseif strcmp(subspaceType,'ring')
        rsf = sqrt(sfxdom.^2 + sfydom.^2);
        kmatID = find(rsf <= P.max_sf & rsf >= P.min_sf);                 
    end
    
    probRatios = ones(length(kmatID),1,length(colordom)); %need to be integers
    
    for kID = 1:length(kmatID)
        
        kx_o = kxmat(kmatID(kID));
        ky_o = kymat(kmatID(kID));
        
        Im = sin(2*pi*kx_o*nxmat/xN + 2*pi*ky_o*nymat/yN) + cos(2*pi*kx_o*nxmat/xN + 2*pi*ky_o*nymat/yN); %Hartley trx
        
        bwdom = [-1 1];
        
        for bw = 1:length(bwdom)  %need the inverted version as well (180/270)
            
            for colorID = 1:length(colordom)  %color domain
                
                %%%%%%%%%%%%%%%%%%%%%%%
                %This is a total hack%%
                
                if strcmp(P.colorspace,'DKL')
                    switch colordom(colorID)
                        case 4 %S
                            Im2 = Im*.15/.82;
                        case 5 %L-M
                            Im2 = Im;
                        case 6 %L+M
                            Im2 = Im*.15/1.0;
                            
                    end
                elseif strcmp(P.colorspace,'LMS')
                    switch colordom(colorID)
                        case 2 %L
                            Im2 = Im;
                        case 3 %M
                            Im2 = Im*.2/.23;
                        case 4 %S
                            Im2 = Im*.2/.82;
                    end
                elseif strcmp(P.colorspace,'gray')
                    Im2 = Im;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%
                
                Idraw = ImtoRGB(Im2*bwdom(bw)*P.contrast/100,colordom(colorID),P,[]);
                Gtxtr(kID,bw,colorID) = Screen(screenPTR, 'MakeTexture', Idraw);                
                
            end
            
        end
        
        if P.blankProb > 0 && kID == 1 %just do this once if blank is set
            Idraw = ImtoRGB(Im*0,colordom(colorID),P,[]);
            Gtxtr(length(kmatID)+1,1,1) = Screen(screenPTR, 'MakeTexture', Idraw);
        end

%         prcdone = round(kID/length(kmatID)*100);
%         newtext = ['Building: ' num2str(prcdone) '%'];
%         Screen(screenPTR,'DrawText',newtext,40,200,0);
%         Screen('Flip', screenPTR);
        
    end
    
    
    domains = struct;
    domains.kx = kx;  %1st quadrant of full Hartley space
    domains.ky = ky;  %1st quadrant of full Hartley space
    domains.kmatID = kmatID; %The vectorized indices of the kx/ky matrices
    domains.bwdom = bwdom;
    domains.colordom = colordom;
    %important to know how the domain order within 'Gtxtr' for reconstructin the sequence...    
    domains.higherarchy = {'kx','ky','phase','color'};
    toc

end

if Mstate.running && loopTrial == 1  %if its in the looper and it the first trial
    saveLog(domains)
end
    
TDim = [yN xN];
TDim(3) = length(Gtxtr(:));



function putinTexture(Im,colordom,sfid,tid,colorID,P)

global Gtxtr screenPTR

%%%%%%%%%%%%%%%%%%%%%%%
%This is a total hack%%
if strcmp(P.colorspace,'DKL')
    switch colordom(colorID)
        case 4 %S
            Im = Im*.15/.82;
        case 5 %L-M
            Im = Im;
        case 6 %L+M
            Im = Im*.15/1.0;
    end
elseif strcmp(P.colorspace,'LMS')
    switch colordom(colorID)
        case 2 %L
            Im = Im;
        case 3 %M
            Im = Im*.2/.23;
        case 4 %S
            Im = Im*.2/.82;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

Idraw = ImtoRGB(Im,colordom(colorID),P,[]);
Gtxtr(sfid,tid,colorID) = Screen(screenPTR, 'MakeTexture', Idraw);

