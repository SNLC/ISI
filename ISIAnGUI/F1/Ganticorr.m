function Ganticorr(f0mdum,bw,hh)


%f0m = f0mdum;
bcond = [];
k = 1;
nc = pepgetnoconditions;
for(i=0:nc-1)
    pepsetcondition(i)
    if ~pepblank       %Identify blank
        f0m{k} = f0mdum{i+1};
        v = pepgetvalues;
        ori(k) = v(1);
        k = k+1;
    else
        bcond = i;
    end
end

ori2 = angle(exp(1i*ori*pi/180*2))*180/pi;      %Put them in ori domain
ori2 = round(ori2);  % this is necessary for the "find" function.

cb = zeros(size(f0m{1}));
for i = 1:(nc-length(bcond))
    cb = cb+f0m{i};
end
cb = cb/(nc-length(bcond));

for i = 1:(nc-length(bcond))
    f0mcb{i} = f0m{i}./cb;
end

ind0 = find(ori2 == 0);
ind180 = find(ori2 == 180);   %180 in orientation domain
v0 = f0mcb{ind0(1)}+f0mcb{ind0(2)};
v180 = f0mcb{ind180(1)}+f0mcb{ind180(2)};
if ~isempty(hh)
    v0 = ifft2(fft2(hh).*fft2(v0));
    v180 = ifft2(fft2(hh).*fft2(v180));
end


R = roi_scatter(v0,v180,bw,0);
title(['0 vs 90  (R = ' num2str(R) ')'])

figure
subplot(1,2,1)
imagesc(100*v0.*bw),colorbar
title('% change 0deg')
subplot(1,2,2)
imagesc(100*v180.*bw),colorbar,colormap gray
title('% change 90deg')
truesize

figure,imagesc(100*(v0-v180).*bw),colormap gray,colorbar
title('Percent change 0-90')
truesize

ind90 = find(ori2 == 90);
ind270 = find(ori2 == -90);   
v90 = f0mcb{ind90(1)}+f0mcb{ind90(2)};
v270 = f0mcb{ind270(1)}+f0mcb{ind270(2)};
if ~isempty(hh)
    v90 = ifft2(fft2(hh).*fft2(v90));
    v270 = ifft2(fft2(hh).*fft2(v270));
end

R = roi_scatter(v90,v270,bw,0);
title(['45 vs 135  (R = ' num2str(R) ')'])

% figure
% subplot(1,2,1)
% imagesc(v90)
% subplot(1,2,2)
% imagesc(v270),colormap gray
% truesize

