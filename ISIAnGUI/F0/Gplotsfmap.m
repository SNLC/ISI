function Gplotsfmap(mag,sf)

global fh

mag = mag-min(mag(:));
mag = mag/max(mag(:));

set(gcf,'Color',[1 1 1]);
imagesc(mag)
imagesc(sf,'AlphaData',mag)
colorbar
axis image;

fh = gcf;

datacursormode on;
dcm_obj = datacursormode(fh);
set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on','UpdateFcn',@myupdatefcn);


function txt = myupdatefcn(empt,event_obj)

%Matlab doesn't like it when I try to input other things into myupdatefcn,
%this is why I have these globals

global ACQinfo Tens1 Tens2 f0m1 f0m2 bcond pepANA

tdom = 0:length(Tens1{1}(1,1,:))-1;
tdom = tdom*ACQinfo.msPerLine*ACQinfo.linesPerFrame;

if isfield(ACQinfo,'stimPredelay')
    predelay = ACQinfo.stimPredelay;
    trialtime = ACQinfo.stimTrialtime;
    tdom = tdom-predelay;
end

rows = ACQinfo.linesPerFrame;
cols = ACQinfo.pixelsPerLine;
%  
pos = get(event_obj,'Position'); %pos(1) is column dimension
W = 5;
xran = (pos(1)-floor(W/2)):(pos(1)+floor(W/2));
yran = (pos(2)-floor(W/2)):(pos(2)+floor(W/2));

tau = pos(2)*ACQinfo.msPerLine;
tdom = tdom + tau;
figure(99)

k = 1;
for(i=0:length(f0m1)-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        for z = 1:length(pepANA.listOfResults{i+1}.values)  %loop through each loop parameter
            if strcmp(pepANA.listOfResults{i+1}.symbols(z),'s_freq')
                paramID = z;
                sfdom(i+1) = v(paramID);
            else
                pdumID = z;
                pdum(i+1) = v(pdumID);
            end
        end
        dum1 = f0m1{i+1}(yran,xran);
        dum2 = f0m2{i+1}(yran,xran);
        tc1(i+1) = mean(dum1(:));
        tc2(i+1) = mean(dum2(:));
        k = k+1;
    else
        sfdom(i+1) = NaN;
        pdum(i+1) = NaN;
        tc1(i+1) = NaN;
        tc2(i+1) = NaN; %need to do this in order to index the best/worst sf.
    end
end

[ma1 idma1] = max(tc1);
if length(pepANA.listOfResults{1}.values) > 1  %if multiple params in looper
    dumslice = find(pdum == pdum(idma1));
    mi1 = min(tc1(dumslice));
    idmi1 = find(tc1 == mi1);
    idmi1 = idmi1(1);
    tc1 = tc1(dumslice);
    sfdom1 = sfdom(dumslice);
else
    [mi1 idmi1] = min(tc1);
    tc1(find(isnan(tc1))) = []; %Get rid of blank index
    sfdom1 = sfdom;
    sfdom1(find(isnan(sfdom1))) = [];
end

[ma2 idma2] = max(tc2);
if length(pepANA.listOfResults{1}.values) > 1
    dumslice = find(pdum == pdum(idma2));
    mi2 = min(tc2(dumslice));
    idmi2 = find(tc2 == mi2);
    idmi2 = idmi2(1);
    tc2 = tc2(dumslice);
    sfdom2 = sfdom(dumslice);
else
    [mi2 idmi2] = min(tc2);
    tc2(find(isnan(tc2))) = [];
    sfdom2 = sfdom;
    sfdom2(find(isnan(sfdom2))) = [];
end

[sfdom1 id1] = sort(sfdom1);
[sfdom2 id2] = sort(sfdom2);

subplot(2,2,1)
plot(sfdom1,tc1(id1),'k'), hold on, plot(sfdom1,tc1(id1),'ok'), hold off
xlabel('spatial frequency'), title('Chan 1')
set(gca,'Xtick',round(sfdom1*100)/100,'Xscale','log')

subplot(2,2,2)
plot(sfdom2,tc2(id2),'k'), hold on, plot(sfdom2,tc2(id2),'ok'), hold off
xlabel('spatial frequency'), title('Chan 2')
set(gca,'Xtick',round(sfdom2*100)/100,'Xscale','log')

nopix = length(yran)*length(xran);

subplot(2,2,3)
dum = squeeze(sum(sum(Tens1{idma1}(yran,xran,:),1),2))/nopix;
plot(tdom(1:end-1),dum(1:end-1)), hold on, plot(tdom(1:end-1),dum(1:end-1),'o')   %Get rid of last frame because shutter closes before the end
hold on
dum = squeeze(sum(sum(Tens1{idmi1}(yran,xran,:),1),2))/nopix;
plot(tdom(1:end-1),dum(1:end-1),'r'), hold on, plot(tdom(1:end-1),dum(1:end-1),'or')
if isfield(ACQinfo,'stimPredelay')
    ylimits = get(gca,'Ylim');
    hold on, plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')
end
hold off
xlabel('sec')

subplot(2,2,4)
dum = squeeze(sum(sum(Tens2{idma2}(yran,xran,:),1),2))/nopix;
plot(tdom(1:end-1),dum(1:end-1)), hold on, plot(tdom(1:end-1),dum(1:end-1),'o')
hold on
dum = squeeze(sum(sum(Tens2{idmi2}(yran,xran,:),1),2))/nopix;
plot(tdom(1:end-1),dum(1:end-1),'r'), hold on, plot(tdom(1:end-1),dum(1:end-1),'or')
if isfield(ACQinfo,'stimPredelay')
    ylimits = get(gca,'Ylim');
    hold on, plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')
end
hold off
xlabel('sec')

tar = get(get(event_obj,'Target'));
data = tar.CData;

txt = {['X: ',num2str(pos(1))],...
       ['Y: ',num2str(pos(2))],...
       ['sf: ' sprintf('%2.1f %%',data(round(pos(2)),round(pos(1)))/64*180) ' deg']};
       