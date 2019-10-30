function noiseIm = makeNoiseIm_beta(dim,P,x_ecc,y_ecc)

% 'width' is the width of the each box, in pixels
% 'Ny/Nx' are the size of the image, in pixels
% 'type' is a string

global Mstate


switch P.altazimuth
    
    case 'none'
        
        sdomAz = x_ecc; 
        sdomAlt = y_ecc;
        
    case 'altitude'
        
        sdomAlt = atan(y_ecc.*cos(atan(x_ecc/Mstate.screenDist))/Mstate.screenDist)*180/pi; %deg
        sdomAz = atan(x_ecc/Mstate.screenDist)*180/pi; %deg
        
    case 'azimuth' %The projection of azimuth onto a plane is the same as a cylinder on a plane
        
        sdomAz = atan(x_ecc/Mstate.screenDist)*180/pi; %deg
        sdomAlt = atan(y_ecc.*cos(atan(x_ecc/Mstate.screenDist))/Mstate.screenDist)*180/pi; %deg
        
end

sdomAlt = round(sdomAlt/P.noise_width);
sdomAz = round(sdomAz/P.noise_width);


if strcmp('random',P.noise_type)
        noiseIm = [];
        for i = 1:r
            noise_c = rand(1,c);
            noise_c = interpVec(noise_c,widthc);
            noise_c = ones(widthc,1)*noise_c;
            
            noiseIm = [noiseIm; noise_c];
        end
        noiseIm = noiseIm(1:dim(1),1:dim(2));        
        
elseif strcmp('checker',P.noise_type)         
    
     noiseIm = xor(rem(sdomAz,2),rem(sdomAlt,2));  %xor produces the checker pattern
     
end



function vecout = interpVec(vec,W)

vecout = ones(1,length(vec)*W);


for i = 1:W
    vecout(i:W:end) = vec;
end
    
