function retmap = Gprocessret(f0dum,bw,hh)

%f0dum is the cell array returned from fmeanimage.m
%'retmap' is in degrees from 0 to 360

if length(f0dum)>1  %It equals one if it came from a temporal filt processing.
    k = 1;
    for(i=0:length(f0dum)-1)
        pepsetcondition(i)
        if(~pepblank)       %This loop filters out the blanks
            v = pepgetvalues;
            phase(k) = v(1);
            f0{k} = f0dum{i+1};
            k = k+1;
        end
    end

    retmap = zeros(size(f0{1}));
    for k = 1:length(f0)
        retmap = retmap + f0{k}*exp(1i*phase(k)*pi/180);    %Linear combination
    end
    
else
    retmap = f0dum{1};
end

%if a filter exists, use it...
if ~isempty(hh)
    retmap = ifft2(fft2(hh).*fft2(retmap));
end

retmap = applyROI(bw,retmap);

