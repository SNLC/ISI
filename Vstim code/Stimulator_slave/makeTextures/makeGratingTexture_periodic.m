function makeGratingTexture_periodic

%make one cycle of the grating

global Mstate screenPTR screenNum %movieBlock 

global Gtxtr TDim  %'playgrating' will use these

Screen('Close')  %First clean up: Get rid of all textures/offscreen windows

Gtxtr = []; TDim = [];  %reset

% frame1=1;

P = getParamStruct;
screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;


if strcmp(P.altazimuth,'none')
    
    %The following assumes the screen is curved
    xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
    xN = round(xcm*pixpercmX);  %stimulus width in pixels
    ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
    yN = round(ycm*pixpercmY);  %stimulus height in pixels
    
else
    
    %The following assumes a projection of spherical coordinates onto the
    %flat screen
    xN = 2*Mstate.screenDist*tan(P.x_size/2*pi/180);  %grating width in cm
    xN = round(xN*pixpercmX);  %grating width in pixels
    yN = 2*Mstate.screenDist*tan(P.y_size/2*pi/180);  %grating height in cm
    yN = round(yN*pixpercmY);  %grating height in pixels
    
end

xN = round(xN/P.x_zoom);  %Downsample for the zoom
yN = round(yN/P.y_zoom);

%create the mask
xdom = linspace(-P.x_size/2,P.x_size/2,xN);
ydom = linspace(-P.y_size/2,P.y_size/2,yN);
[xdom ydom] = meshgrid(xdom,ydom);
r = sqrt(xdom.^2 + ydom.^2);
if strcmp(P.mask_type,'disc')
    mask = zeros(size(r));
    id = find(r<=P.mask_radius);
    mask(id) = 1;
elseif strcmp(P.mask_type,'gauss')
    mask = exp((-r.^2)/(2*P.mask_radius^2));
else
    mask = [];
end
mask = single(mask);
%%%%%%%%%

%%%%%%
%%%%%%BETA VERSION
[sdom tdom x_ecc y_ecc] = makeGraterDomain_beta(xN,yN,P.ori,P.s_freq,P.t_period,P.altazimuth);%orig


if P.plaid_bit
    %I am ignoring t_period2 for now, and just setting it to t_period
%     if strcmp(P.altazimuth,'altitude')
%         AZ2 = 'azimuth'
%     elseif strcmp(P.altazimuth,'azimuth')
%         AZ2 = 'altitude';
%     end
    AZ2 = P.altazimuth;
    [sdom2 tdom2 x_ecc2 y_ecc2] = makeGraterDomain(xN,yN,P.ori2,P.s_freq2,P.t_period,AZ2);
end



flipbit = 0;

if ~P.separable

    for i = 1:length(tdom)
        
        Im = makePerGratFrame_insep(sdom,tdom,i,1);
        
        if P.plaid_bit
            Im = makePerGratFrame_insep(sdom2,tdom2,i,2) + Im;
        end
        
        
        if P.noise_bit
            if rem(i,P.noise_lifetime) == 1
%                 nwx = round(P.noise_width/P.x_zoom);
%                 nwy = round(P.noise_width/P.y_zoom);
%                 noiseIm = makeNoiseIm(size(Im),nwx,nwy,P.noise_type);

                noiseIm = makeNoiseIm_beta(size(Im),P,x_ecc,y_ecc);
                
                flipbit = 1-flipbit;
                if flipbit
                    noiseIm = 1-noiseIm;
                end
            end
            
            Im = Im - 2*noiseIm;
            Im(find(Im(:)<-1)) = -1;
            
  
            
        end
        
        ImRGB = ImtoRGB(Im,P.colormod,P,mask);
        
        Gtxtr(i) = Screen(screenPTR, 'MakeTexture', ImRGB);
       
%         movieBlock(:,:,frame1)=Im;
%         frame1=frame1+1;
        
    end
    
else
    
    [amp temp] = makeSeparableProfiles(tdom,sdom,x_ecc,y_ecc,1);
    if P.plaid_bit
        [amp2 temp2] = makeSeparableProfiles(tdom2,sdom2,x_ecc2,y_ecc2,2);
    end
    
    for i = 1:length(tdom)
        
        Im = amp(i)*temp;
        
        if P.plaid_bit
            Im = Im + amp2(i)*temp2;
        end
        ImRGB = ImtoRGB(Im,P.colormod,P,mask);
        Gtxtr(i) = Screen(screenPTR, 'MakeTexture', ImRGB);
        
    end
    
end





TDim = size(ImRGB(:,:,1));
TDim(3) = length(Gtxtr);


