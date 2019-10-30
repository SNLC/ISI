function Im = makePerGratFrame_insep(sdom,tdom,i,pID)

Pstruct = getParamStruct;


Im = cos(sdom - tdom(i));


if pID == 1
    
    switch Pstruct.st_profile
        
        case 'sin'
            Im = Im*Pstruct.contrast/100;  %[-1 1]
            
        case 'square'
            thresh = cos(Pstruct.s_duty*pi);
            Im = sign(Im-thresh);
            Im = Im*Pstruct.contrast/100;
            
        case 'pulse'
            thresh = cos(Pstruct.s_duty*pi);
            Im = (sign(Im-thresh) + 1)/2;
            Im = Im*Pstruct.contrast/100;
            
    end
    
elseif pID == 2
    
    switch Pstruct.st_profile2
        
        case 'sin'
            Im = Im*Pstruct.contrast2/100;  %[-1 1]
            
        case 'square'
            thresh = cos(Pstruct.s_duty2*pi);
            Im = sign(Im-thresh);
            Im = Im*Pstruct.contrast2/100;
            
        case 'pulse'
            thresh = cos(Pstruct.s_duty2*pi);
            Im = (sign(Im-thresh) + 1)/2;
            Im = Im*Pstruct.contrast2/100;
            
    end
    
    
end


