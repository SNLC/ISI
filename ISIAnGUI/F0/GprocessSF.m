function [sfmap mag] = GprocessSF(f0dum,bw,hh)
%f0dum is the cell array returned from fmeanimage.m

global pepANA

k = 1;
for(i=0:length(f0dum)-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        for z = 1:length(pepANA.listOfResults{i+1}.values)  %loop through each loop parameter
            if strcmp(pepANA.listOfResults{i+1}.symbols(z),'s_freq')
                paramID = z;
                sf(k) = v(paramID);
            else
                pdumID = z;
                pdum(k) = v(pdumID);
            end
        end
        f0{k} = f0dum{i+1};
        k = k+1;
    end
end

for k = 1:length(f0)
    %For sf maps, we must filter before combining the images from each
    %condition because they are combined non-linearly.
    %if a filter exists, use it...
    if ~isempty(hh)
        id = find(isnan(f0{k}));
        f0{k}(id) = 0;
        f0{k} = ifft2(abs(fft2(hh)).*fft2(f0{k}));    
    end
    sfTens(:,:,k) = f0{k};    
end

[ma idma] = max(sfTens,[],3);
%dumloc = pdum(idma);
%Need to loop through each pixel to do this properly!!
[mi idmi] = min(sfTens,[],3);

figure,imagesc(ma), colorbar
figure,imagesc(mi),colorbar

%mag = (ma-mi)./(ma+mi);
mag = ma-mi;

sfmap = sf(idma);
