function [isolumMap colorSel] = GprocessDKL(f0dum,hh)

%Each element of the cell array 'f0dum' is the average image for the
%corresponding condition
bflag = 0;
k = 1;
for(i=0:length(f0dum)-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        color(k) = v(1);
        f0{k} = f0dum{i+1};
        k = k+1;
    else
        f0blank = f0dum{i+1};
        bflag = 1;
    end
end

for k = 1:length(f0)
    Tens(:,:,k) = f0{k};
end

mi = min(Tens,[],3);
for k = 1:length(Tens(1,1,:))
    if bflag == 1
        Tens(:,:,k) = Tens(:,:,k)-f0blank;
    else
        Tens(:,:,k) = Tens(:,:,k)-mi;
    end
end
su = sum(abs(Tens),3);

isoLumOri = 0:45:135;

isolumMap = zeros(size(f0{1}));
lumavg = zeros(size(f0{1}));
for k = 1:length(f0)
    id = color(k)-4;  %5 to 8 is isoluminance, 9 is luminance
    if id ~= 5   %only use isoluminance conditions for vector measurement
        %isolumMap = isolumMap + f0{k}*exp(1i*2*ori(k)*pi/180);    %Linear combination
        isolumMap = isolumMap + Tens(:,:,k)*exp(1i*2*isoLumOri(id)*pi/180);    %Linear combination
    else
        lumavg = Tens(:,:,k);
    end
end

id = find(color-4 ~= 5);
isolummax = max(Tens(:,:,id),[],3);  %Take response to max direction for color response

isolumMap = isolumMap./su; %normalize magnitudes to be between 0 and 1

%if a filter exists, use it...
if ~isempty(hh)
    id = find(isnan(isolumMap));
    isolumMap(id) = 0;
    isolumMap = ifft2(abs(fft2(hh)).*fft2(isolumMap));  
    
    lumavg(id) = 0;
    lumavg = ifft2(abs(fft2(hh)).*fft2(lumavg)); 
    
    isolummax(id) = 0;
    isolummax = ifft2(abs(fft2(hh)).*fft2(isolummax)); 
end

colormag = abs(isolummax);
colorSel = (colormag-lumavg)./(colormag+abs(lumavg));
