function ocdom = GprocessOcdom(f0dum,bw,hh)
%y is a cell array of images returned from 'f0meanimage'
%z is a linear combination of the images using the loop parameters

if length(f0dum)>1  %It equals one if it came from a temporal filt processing.
    k = 1;
    for(i=0:pepgetnoconditions-1)
        pepsetcondition(i)
        if(~pepblank)       %This loop filters out the blanks
            v = pepgetvalues;
            f0{k} = f0dum{i+1};
            k = k+1;
        end
    end

    ocdom = f0{1}-f0{2};    %Linear combination

else
    ocdom = real(f0dum{1});  %From tempfilt processing
end

if ~isempty(hh)
    ocdom = ifft2(fft2(hh).*fft2(ocdom));
end

ocdom = applyROI(bw,ocdom);