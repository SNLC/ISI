function Gplotorimap(mag,ang)

global fh

mag(1,1) = 0;  %Do this in case they are all ones

mag = mag-min(mag(:));
mag = mag/max(mag(:));
%mag = ones(size(mag));

set(gcf,'Color',[1 1 1]);
x = image(1:length(ang(:,1)),1:length(ang(1,:)),ang*64/(180),'CDataMapping','direct','AlphaData',mag,'AlphaDataMapping','none');

axis image;
colormap hsv;

fh = gcf;
colorbar('YTick',[1 16:16:64],'YTickLabel',{'0','45','90','135','180'})

% datacursormode on;
% dcm_obj = datacursormode(fh);
% set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on','UpdateFcn',@myupdatefcn);


% function txt = myupdatefcn(empt,event_obj)
% 
% %Matlab doesn't like it when I try to input other things into myupdatefcn,
% %this is why I have these globals
%  
% global Analyzer Tens1 Tens2 Tens1_var Tens2_var f0m1 f0m2 f0m1_var f0m2_var bcond Flim pepANA
% 
% fper = 1/10;  %frame period
% 
% varflag = 0;
% if ~isempty(Tens1_var)
%     varflag = 1;
% end
%     
% tdom = 0:length(Tens1{1}(1,1,:))-1;
% tdom = tdom*fper;
% 
% predelay = getparam('predelay');
% trialtime = getparam('stim_time');
% tdom = tdom-predelay;
% 
% nr = length(Analyzer.loops.conds{1}.repeats);
% rows = length(Tens1{1}(:,1,1));
% cols = length(Tens1{1}(1,:,1));
% 
% SEn = sqrt(length(Flim(1):Flim(2))*nr);  %standard error normalizer for tuning curve
% %  
% pos = get(event_obj,'Position'); %pos(1) is column dimension
% W = 5;
% xran = (pos(1)-floor(W/2)):(pos(1)+floor(W/2));
% yran = (pos(2)-floor(W/2)):(pos(2)+floor(W/2));
% 
% nc = length(Analyzer.loops.conds);
% figure(99)
% bflag = 0;
% k = 1;
% for i=1:nc
%     if ~strcmp(Analyzer.loops.conds{i}.symbol,'blank')        %This loop filters out the blanks
%         v = Analyzer.loops.conds{i}.val;
%         for z = 1:length(Analyzer.loops.conds{i}.symbol)  %loop through each loop parameter
%             if strcmp(Analyzer.loops.conds{i}.symbol{1},'ori')
%                 oridom(i) = v{z};
%             else
%                 pdum(i) = v{z};
%             end
%         end
%         dum1 = f0m1{i}(yran,xran);
%         dum2 = f0m2{i}(yran,xran);
%         tc1(i) = mean(dum1(:));
%         tc2(i) = mean(dum2(:));
%         if varflag
%             dum1 = f0m1_var{i}(yran,xran);
%             dum2 = f0m2_var{i}(yran,xran);
%             tc1_var(i) = mean(dum1(:));
%             tc2_var(i) = mean(dum2(:));
%         end
%         k = k+1;
%     else
%         dum1 = f0m1{i}(yran,xran);
%         dum2 = f0m2{i}(yran,xran);
%         blank1 = mean(dum1(:));
%         blank2 = mean(dum2(:));
%         tc1(i) = NaN;
%         tc2(i) = NaN;     %need to do this in order to index the best/worst ori.   
%         if varflag
%             tc1_var(i) = NaN;
%             tc2_var(i) = NaN;
%         end
%         pdum(i) = NaN;
%         oridom(i) = NaN;
%         bflag = 1;
%     end
% end
% 
% [ma1 idma1] = max(tc1);
% if length(Analyzer.loops.conds{1}.val) > 1  %if multiple params in looper
%     dumslice = find(pdum == pdum(idma1));
%     mi1 = min(tc1(dumslice));
%     idmi1 = find(tc1 == mi1);
%     idmi1 = idmi1(1);
%     tc1 = tc1(dumslice);
%     oridom1 = oridom(dumslice);
% else
%     [mi1 idmi1] = min(tc1);
%     tc1(find(isnan(tc1))) = []; %Get rid of blank index
%     oridom1 = oridom;
%     oridom1(find(isnan(oridom1))) = [];
% end
% 
% [ma2 idma2] = max(tc2);
% if length(Analyzer.loops.conds{1}.val) > 1
%     dumslice = find(pdum == pdum(idma2));
%     mi2 = min(tc2(dumslice));
%     idmi2 = find(tc2 == mi2);
%     idmi2 = idmi2(1);
%     tc2 = tc2(dumslice);
%     oridom2 = oridom(dumslice);
% else
%     [mi2 idmi2] = min(tc2);
%     tc2(find(isnan(tc2))) = [];
%     oridom2 = oridom;
%     oridom2(find(isnan(oridom2))) = [];
% end
% 
% [oridom1 id1] = sort(oridom1);
% [oridom2 id2] = sort(oridom2);
% 
% subplot(2,2,1)
% if bflag == 1
%     plot([oridom1(1) oridom1(end)],[blank1 blank1],'k'), hold on
% end
% 
% if ~varflag
%     plot(oridom1,tc1(id1),'ob-')
% else
%     errorbar(oridom1,tc1(id1),sqrt(tc1_var(id1))/SEn,'b')
% end
% xlabel('orientation'), title('Chan 1'), xlim([0 360]), hold off
% 
% subplot(2,2,2)
% if bflag == 1
%     plot([oridom2(1) oridom2(end)],[blank2 blank2],'k'), legend('blank'), hold on
% end
% 
% if ~varflag
%     plot(oridom2,tc2(id2),'ob-')
% else
%     errorbar(oridom2,tc2(id2),sqrt(tc2_var(id2))/SEn,'b')
% end
% xlabel('orientation'), title('Chan 2'), xlim([0 360]), hold off
% 
% nopix = length(yran)*length(xran);
% 
% subplot(2,2,3)
% dum = squeeze(sum(sum(Tens1{idma1}(yran,xran,:),1),2))/nopix;
% if varflag
%     dum_var = squeeze(sum(sum(Tens1_var{idma1}(yran,xran,:),1),2))/nopix/nr;
%     errorbar(tdom,dum,sqrt(dum_var)), hold on 
% else
%     plot(tdom,dum), hold on
% end
% dum = squeeze(sum(sum(Tens1{idmi1}(yran,xran,:),1),2))/nopix;
% if varflag
%     dum_var = squeeze(sum(sum(Tens1_var{idmi1}(yran,xran,:),1),2))/nopix/nr;
%     errorbar(tdom,dum,sqrt(dum_var),'r')
% else
%     plot(tdom,dum,'r')
% end
% 
% ylimits = get(gca,'Ylim');
% plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')
% 
% hold off
% xlabel('sec')
% 
% subplot(2,2,4)
% dum = squeeze(sum(sum(Tens2{idma2}(yran,xran,:),1),2))/nopix;
% if varflag
%     dum_var = squeeze(sum(sum(Tens2_var{idma1}(yran,xran,:),1),2))/nopix/nr;
%     errorbar(tdom,dum,sqrt(dum_var)), hold on
% else
%     plot(tdom,dum), hold on
% end
% dum = squeeze(sum(sum(Tens2{idmi2}(yran,xran,:),1),2))/nopix;
% if varflag
%     dum_var = squeeze(sum(sum(Tens2_var{idmi1}(yran,xran,:),1),2))/nopix/nr;
%     errorbar(tdom,dum,sqrt(dum_var),'r')
% else
%     plot(tdom,dum,'r')
% end
% 
% ylimits = get(gca,'Ylim');
% plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')
% 
% hold off
% xlabel('sec')
% 
% tar = get(get(event_obj,'Target'));
% data = tar.CData;
% 
% txt = {['X: ',num2str(pos(1))],...
%        ['Y: ',num2str(pos(2))],...
%        ['Ori: ' sprintf('%2.1f %%',data(round(pos(2)),round(pos(1)))/64*180) ' deg']};
%        