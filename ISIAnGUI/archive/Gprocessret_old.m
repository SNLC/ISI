function [angx magx angy magy] = Gprocessret(f0dum,bw,hh)

%f0dum is the cell array returned from fmeanimage.m
%'retmap' is in degrees from 0 to 360

global pepANA
x_size = get(pepANA.module,'x_size');
y_size = get(pepANA.module,'y_size');
sduty = 1-get(pepANA.module,'s_duty');

k = 1;
for(i=0:length(f0dum)-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        phase(k) = v(1);
        ori(k) = v(2);
        f0{k} = f0dum{i+1};
        k = k+1;
    end
end

i = 1; j = 1;
for k = 1:length(f0)
    if ori(k) == 0
        Tensx(:,:,i) = f0{k};    
        i = i+1;
    elseif ori(k) == 90
        Tensy(:,:,j) = f0{k};    
        j = j+1;
    end
end



mix = min(Tensx,[],3);
miy = min(Tensy,[],3);
for i = 1:length(Tensx(1,1,:))
    Tensx(:,:,i) = Tensx(:,:,i)-mix;
    Tensy(:,:,i) = Tensy(:,:,i)-miy;
end
sux = sum(Tensx,3);
suy = sum(Tensy,3);
id = find(sux(:)==0);
sux(id) = eps;
id = find(suy(:)==0);
suy(id) = eps;

for i = 1:length(Tensx(1,1,:))
    Tensx(:,:,i) = Tensx(:,:,i)./sux;
    Tensy(:,:,i) = Tensy(:,:,i)./suy;
end


xpos = zeros(size(f0{1}));
ypos = zeros(size(f0{1}));
i = 1; j = 1;
for k = 1:length(f0)
    if ori(k) == 0
        xpos = xpos + Tensx(:,:,i)*exp(1i*phase(k)*pi/180);    %Linear combination
        i = i+1;
    elseif ori(k) == 90
        ypos = ypos + Tensy(:,:,j)*exp(1i*phase(k)*pi/180);    %Linear combination
        j = j+1;
    end
end

%if a filter exists, use it...
if ~isempty(hh)
    xpos = ifft2(abs(fft2(hh)).*fft2(xpos));
    ypos = ifft2(abs(fft2(hh)).*fft2(ypos));
end

shifter = 360*sduty/2;

magx = abs(xpos);
angx = angle(xpos*exp(1i*shifter*pi/180))*180/pi; %-180 to 180
angx = angx + (1-sign(angx))*360/2; %0 to 360
angx = 360-angx;  %x-axis (phase) runs from right to left ('x_pos' domain goes left to right)
angx = x_size*angx/360; %Output position in deg of visual field

magy = abs(ypos);
angy = angle(ypos*exp(1i*shifter*pi/180))*180/pi;
angy = angy + (1-sign(angy))*360/2;  
angy = 360-angy;  %Make y-axis (phase) go bottom to top to match the 'y_pos' domain
angy = y_size*angy/360;

magy = magy-min(magy(:));
magy = magy/max(magy(:));
magx = magx-min(magx(:));
magx = magx/max(magx(:));

