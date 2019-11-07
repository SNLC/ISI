function plotF0(f0dum,bw,hh)

global bcond

bwdum = double(bw);
id = find(bw(:) == 0);
bwdum(id) = NaN;

k = 1;
for(i=0:length(f0dum)-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        param(k) = v(1);
        if ~isempty(hh)
            f0dum{i+1} = ifft2(abs(fft2(hh)).*fft2(f0dum{i+1}));    
        end
        f0{k} = bwdum.*f0dum{i+1};
        tc(k) = nanmean(f0{k}(:));
        
        ma(k) = max(f0{k}(:));
        mi(k) = min(f0{k}(:));
        k = k+1;
    end
end

[domain id] = sort(param);
%figure,plot(domain,tc(id))

ma = max(ma);
mi = min(mi);

nc = pepgetnoconditions;

N = sqrt(length(f0));

figure
for i = 1:length(f0)

    id = find(param(i) == domain);

    subplot(ceil(N),floor(N),id)
    imagesc(f0{i},[mi ma])
    title(['value ' num2str(param(i)) '  CH 1'])
    set(gca,'Xtick',[],'Ytick',[])

end

colormap gray