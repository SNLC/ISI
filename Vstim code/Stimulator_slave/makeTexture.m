function makeTexture(modID)


switch modID
    
    case 'PG'  %Periodic Grater
                
        makeGratingTexture_periodic
                
    case 'FG'  %Flash Grater
        
        if getParamVal('FourierBit')
            makeGratingTexture_flash
        else
            makeGratingTexture_flashCartesian
        end
        
    case 'RD'  %Raindropper
        
        makeRainTexture
        
    case 'FN'  %Filtered Noise
        
        makeNoiseTexture        
        
    case 'MP'  %Mapper
        
        %makeMapper  %He doesn't need a make file
        
    case 'CM'
        
        makeCohMotion
        
        
end

