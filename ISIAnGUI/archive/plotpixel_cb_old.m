function plotpixel_cb

fh = gcf;
%colorbar('YTick',[1 16:16:64],'YTickLabel',{'0','45','90','135','180'})

datacursormode on;
dcm_obj = datacursormode(fh);
set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on','UpdateFcn',@myupdatefcn);


function txt = myupdatefcn(empt,event_obj)

%Matlab doesn't like it when I try to input other things into myupdatefcn,
%this is why I have these globals
 
global ACQinfo Tens1 Tens2 f0m1 f0m2 pepANA

x_size = get(pepANA.module,'x_size');
y_size = get(pepANA.module,'y_size');
sduty = 1-get(pepANA.module,'s_duty');

tdom = 0:length(Tens1{1}(1,:))-1;
tdom = tdom*ACQinfo.msPerLine*ACQinfo.linesPerFrame;

rows = ACQinfo.linesPerFrame;
cols = ACQinfo.pixelsPerLine;
%  
pos = get(event_obj,'Position'); %pos(1) is column dimension (top left is origin)
W = 5;
xran = (pos(1)-floor(W/2)):(pos(1)+floor(W/2));
yran = (pos(2)-floor(W/2)):(pos(2)+floor(W/2));

tau = pos(2)*ACQinfo.msPerLine;
tdom = tdom + tau;

%Corresponding 1D index in vectorized matrix... It is vectorized across rows
%because that is how it was scanned. 
k = 1;
for i = 1:W
    for j = 1:W
        TensID(k) = cols*(yran(j)-1) + xran(i);  
        k = k+1;
    end
end

figure(99)

retorixy = [0 90];
for z = 1:2 %loop through x and y dimension
    clear phasedom
    tc1 = NaN*ones(1,length(f0m1));
    tc2 = NaN*ones(1,length(f0m1));
    k = 1;
    for(i=0:length(f0m1)-1)  %loop through each condition
        pepsetcondition(i)
        if(~pepblank)       %This loop filters out the blanks

            v = pepgetvalues;
            ori = v(2);
            
            if retorixy(z) == ori

                dum1 = f0m1{i+1}(yran,xran);
                dum2 = f0m2{i+1}(yran,xran);
                tc1(i+1) = mean(dum1(:));
                tc2(i+1) = mean(dum2(:));
                phasedom(k) = v(1);

                k = k+1;

            end

        end
    end

    [ma1 idma1] = max(tc1);
    [mi1 idmi1] = min(tc1);
    [ma2 idma2] = max(tc2);
    [mi2 idmi2] = min(tc2);
    tc1(find(isnan(tc1))) = []; %Get rid of blank index
    tc2(find(isnan(tc2))) = [];

    [phasedom id] = sort(phasedom);
    shifter = 360*sduty/2;
    phasedom = phasedom+shifter;
    subplot(2,4,1+(z-1))
    if z == 1
        plot(x_size*(360-phasedom)/360,tc1(id)) %x-axis runs right to left
        xlabel('x position')
    else
        plot(y_size*phasedom/360,tc1(id))
        xlabel('y position')
    end
    title('Chan 1')
    
    subplot(2,4,3+(z-1))
    if z == 1
        plot(x_size*(360-phasedom)/360,tc2(id)) %x-axis runs right to left
        xlabel('x position')
    else
        plot(y_size*phasedom/360,tc2(id))
        xlabel('y position')
    end
    title('Chan 2')

    subplot(2,4,1+(z-1)+4)
    mu = mean(Tens1{idma1}(TensID,:),1);
    plot(tdom,mu)
    hold on
    mu = mean(Tens1{idmi1}(TensID,:),1);
    plot(tdom,mu,'r')
    hold off
    xlabel('sec')
    legend('best','worst')

    subplot(2,4,3+(z-1)+4)
    mu = mean(Tens2{idma1}(TensID,:),1);
    plot(tdom,mu)
    hold on
    mu = mean(Tens2{idmi1}(TensID,:),1);
    plot(tdom,mu,'r')
    hold off
    xlabel('sec')
    legend('best','worst')

    tar = get(get(event_obj,'Target'));
    data = tar.CData;

    txt = {['X: ',num2str(pos(1))],...
        ['Y: ',num2str(pos(2))],...
        ['Pos: ' sprintf('%2.1f %%',data(round(pos(2)),round(pos(1)))/64*180) ' deg']};
end