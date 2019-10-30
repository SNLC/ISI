function [amp temp] = makeSeparableProfiles(tdom,sdom,x_ecc,y_ecc,pID)

%Ian Nauhaus

%thetax and thetay are input only in case of 'checker'

global Mstate

P = getParamStruct;

if pID == 1
    
    temp = cos(sdom - P.s_phase*pi/180);  %template image to modulate
    switch P.s_profile
        
        case 'sin'
            temp = temp*P.contrast/100;
            
        case 'square'
            thresh = cos(P.s_duty*pi);
            temp = sign(temp-thresh);
            temp = temp*P.contrast/100;
            
        case 'pulse'
            thresh = cos(P.s_duty*pi);
            temp = (sign(temp-thresh) + 1)/2;
            temp = temp*P.contrast/100;
        case 'checker'
            sdom2 = x_ecc*sin(P.ori*pi/180+pi/2) - y_ecc*sin(P.ori*pi/180+pi/2); 
            sdom2 = atan(sdom2/Mstate.screenDist)*180/pi;    
            sdom2 = sdom2*P.s_freq*2*pi;
            temp2 = sin(sdom2);
            
            temp = double((sign(temp+eps)+1)/2);
            temp2 = double((sign(temp2+eps)+1)/2);  %'bitand' won't take 'single' precision
            temp = (sign(bitand(temp+1,temp2+1)) - .5) * 2;  %-1s and +1s
            temp = single(temp*P.contrast/100);
    end
    
    amp = sin(tdom - P.t_phase*pi/180);
    switch P.t_profile
        
        case 'square'
            thresh = cos(P.t_duty*pi);
            amp = sign(amp-thresh);
            
        case 'pulse'
            thresh = cos(P.t_duty*pi);
            amp = (sign(amp-thresh) + 1)/2;
    end
    
    
    
elseif pID == 2  %set grating variables (plaid)
    
    temp = cos(sdom - P.s_phase2*pi/180);  %template image to modulate
    switch P.s_profile2
        
        case 'sin'
            temp = temp*P.contrast2/100;
            
        case 'square'
            thresh = cos(P.s_duty2*pi);
            temp = sign(temp-thresh);
            temp = temp*P.contrast2/100;
            
        case 'pulse'
            thresh = cos(P.s_duty2*pi);
            temp = (sign(temp-thresh) + 1)/2;
            temp = temp*P.contrast2/100;
        case 'checker'
            %sdom2 = thetax*sin((P.ori2+90)*pi/180) - thetay*sin((P.ori2+90)*pi/180);
            sdom2 = imrotate(sdom,90);
            temp2 = sin(sdom2);
            
            temp = double((sign(temp+eps)+1)/2);
            temp2 = double((sign(temp2+eps)+1)/2);  %'bitand' won't take 'single' precision
            temp = (sign(bitand(temp+1,temp2+1)) - .5) * 2;  %-1s and +1s
            temp = single(temp*P.contrast2/100);
    end
    
    amp = sin(tdom - P.t_phase2*pi/180);
    switch P.t_profile2
        
        case 'square'
            thresh = cos(P.t_duty2*pi);
            amp = sign(amp-thresh);
            
        case 'pulse'
            thresh = cos(P.t_duty2*pi);
            amp = (sign(amp-thresh) + 1)/2;
    end
    
end


