function [y] = f1image_BPF(cond)

%% Compute the F1 for one condition

global pepANA 

pepsetcondition(cond);
nr = pepgetnorepeats;

tic
for(r=0:nr-1)
    pepsetrepeat(r)
    T = pepgetperiod;
    ttag = pepgettimetag;
    ts = pepgettimes(ttag);
    sync = pepgetsync;      %Array of times for the beginning of each rotation within repeat
    frames = pepgetframeidx(ttag,[0 sync(end)]);
    framest = pepANA.imaging.isync(frames(1):frames(2));  %integer sample values
    framest = (framest - ts(1))/30;  %% frame sampling times in msec  (Cerebrus: 30 samp/ms)
    frameang = framest/T*2*pi;       %% convert to radians
    
%     load('filt2')
%     h = b;

    N = length(frameang);
    dt = trimmean(diff(pepANA.imaging.isync),50);
    Fs = 1000*30/dt;  %Calculate frames/sec
    t_domain = (ceil(-N/2):ceil(N/2)-1)/Fs;
    f1 = 1000/T;
    
    carrier = cos(2*pi*f1*t_domain); %f1 is cyc/sec and T is sec/sample
    h = gausswin(N,3)';
    h = h.*carrier;
    h = h-mean(h);

    pad = (N-length(h))/2;
    h = [zeros(1,ceil(pad)) h zeros(1,floor(pad))];
    
%     figure,plot(t_domain,h)
%     xlabel('seconds')
%         
%     hw = 2*fft(h)/length(h);
%     hw = hw(1:floor(length(h)/2));
%     hw_mag = abs(hw);
%     hw_phase = angle(hw)*180/pi;
%     f_domain = 0:(Fs/2)/(length(hw)-1):Fs/2;
%     figure,semilogx(f_domain,hw_mag),xlabel('Hz')
    
    %Compute circular correlation...
     h_alias = [fftshift(h) fftshift(h)];
     R = xcorr(exp(1i*frameang),h_alias);
     R = R(N:2*N-1);
  
    k = 1;
   
    for(j=frames(1):frames(2))
     
        img = peploadimage(j);
        
        if(j==frames(1))
            acc = zeros(size(img));
        end
        
        acc = acc + R(k).*img;
        
        k = k+1;
    end
    
%    f0 = f0./(length(frames(1):frames(2)));
%    acc = acc - f0*sum(exp(1i*frameang)); %Subtract f0 leakage
%    acc = 2*acc ./ (length(frames(1):frames(2))); %Normalize for f1 amplitude
   
   y{r+1} = acc;

end
toc

    
    