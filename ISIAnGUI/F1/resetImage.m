function resetImage(trx)

global imstate

switch trx
    
    case 'UD'        
        imstate.imanat = flipud(imstate.imanat);        
        imstate.imfunc = flipud(imstate.imfunc);  
        imstate.bw = flipud(imstate.bw);
        imstate.mag = flipud(imstate.mag);
        
        imstate.fmaps{1} = flipud(imstate.fmaps{1});
        imstate.fmaps{2} = flipud(imstate.fmaps{2});
        imstate.sigMag = flipud(imstate.sigMag);
    case 'LR'        
        imstate.imanat = fliplr(imstate.imanat);        
        imstate.imfunc = fliplr(imstate.imfunc); 
        imstate.bw = fliplr(imstate.bw);
        imstate.mag = fliplr(imstate.mag);
        
        imstate.fmaps{1} = fliplr(imstate.fmaps{1});
        imstate.fmaps{2} = fliplr(imstate.fmaps{2});
        imstate.sigMag = fliplr(imstate.sigMag);
    case 'rotate'        
        imstate.imanat = flipud(imstate.imanat');  %Rotate 90deg cc
        imstate.imfunc = flipud(imstate.imfunc');
        imstate.bw = flipud(imstate.bw');
        imstate.mag = flipud(imstate.mag');
        
        imstate.fmaps{1} = flipud(imstate.fmaps{1}');
        imstate.fmaps{2} = flipud(imstate.fmaps{2}');
        imstate.sigMag = flipud(imstate.sigMag');
end






