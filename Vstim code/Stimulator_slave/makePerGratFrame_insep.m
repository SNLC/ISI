function Im = makePerGratFrame_insep(sdom,tdom,i,pID)

%Ian Nauhaus

P = getParamStruct;


if pID == 1
    
    Im = cos(sdom - tdom(i) - P.st_phase*pi/180);
    
    switch P.st_profile
        
        case 'sin'
            Im = Im*P.contrast/100;  %[-1 1]
            
        case 'square'
            thresh = cos(P.s_duty*pi);
            Im = sign(Im-thresh);
            Im = Im*P.contrast/100;
            
        case 'pulse'
            thresh = cos(P.s_duty*pi);
            Im = (sign(Im-thresh) + 1)/2;
            Im = Im*P.contrast/100;
            
    end
    
elseif pID == 2  %From the second set of grating variables (plaid)
    
    Im = cos(sdom - tdom(i) - P.st_phase2*pi/180);
    
    switch P.st_profile2
        
        case 'sin'
            Im = Im*P.contrast2/100;  %[-1 1]
            
        case 'square'
            thresh = cos(P.s_duty2*pi);
            Im = sign(Im-thresh);
            Im = Im*P.contrast2/100;
            
        case 'pulse'
            thresh = cos(P.s_duty2*pi);
            Im = (sign(Im-thresh) + 1)/2;
            Im = Im*P.contrast2/100;
            
    end
    
    
end


