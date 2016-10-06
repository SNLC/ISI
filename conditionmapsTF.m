global f0m1 

%% 8 conditions- Raindropper
figure,
h = fspecial('gaussian',size(f0m1{i}),1);
imagesc(f0m1{1}), colormap gray
bw = roipoly;

[y x]=find(bw==1);
yran(1)=min(y);
yran(2)=max(y);
xran(1)=min(x);
xran(2)=max(x);



scrsz = get(0,'ScreenSize');
figure('Position',[1 1 scrsz(3) scrsz(4)]),
% h = fspecial('gaussian',size(f0m1{i}),1);
ncond = length(f0m1);
for i = 1:size(f0m1,2)
    h = fspecial('gaussian',size(f0m1{i}),1);
    subplot(3,3,i)
    imagesc(f0m1{i}), colormap gray
    domain=eval(Analyzer.L.param{1}{2})*60;
    domain(ncond)=0; % last condition is the blank
    title(['Condition  ', num2str(i), ' - ',num2str(domain(i)), ' deg/sec']);
    set(gcf,'Color','w')
    axis square

    xran = [34 50];
    yran = [100 120];
    if i==ncond
        x=[xran(1) xran(1) xran(2) xran(2) xran(1)];
        y=[yran(1) yran(2) yran(2) yran(1) yran(1)];
        hold on
        plot(x,y,'k')
    end
   

    patch = f0m1{i}(yran(1):yran(2),xran(1):xran(2));
    tc(i) = mean(patch(:));
   
    subplot(3,3,i+1)
    plot(-tc)
    ylabel('deltaR/R'),xlabel('speed (deg/sec)')
    set(gca,'xtick',1:length(f0m1));
    set(gca,'xticklabel',domain);
    title('speed tuning curve of patch')
end

%%
h = fspecial('gaussian',size(f0m1{i}),2);
dim = size(f0m1{1});
ncond = length(f0m1);
Tens = zeros(dim(1),dim(2),ncond);
for i = 1:ncond
    dum = ifft2(fft2(f0m1{i}).*abs(fft2(h))); %filter it
    Tens(:,:,i) = dum;
end
[dum spmap] = min(Tens,[],3); %gives the smallest elements along the third dimension of Tens (the condition)
figure, imagesc((spmap),[1 ncond]), colorbar
colorbar('YTickLabel',domain)
title(['Preferred ', Analyzer.loops.conds{1}.symbol{1}, ' map', ' (deg/sec)'])

%%

    patch = f0m1{i}(100:120,34:50);
    tc(i) = mean(patch(:));
    figure, plot(tc(i))

