function [warningflag ddwarningflag] = checkSyncs

global Analyzer

nc = length(Analyzer.loops.conds);
nr = length(Analyzer.loops.conds{1}.repeats);

fper = 1/100;  %even if monitor is at 60Hz, it will catch the problem 

counter = zeros(nc,nr);
ddcounter = zeros(nc,nr);
for c = 1:nc
    for r = 1:nr
        dS = processSyncs(Analyzer.loops.conds{c}.repeats{r}.dSyncswave,10000);
        %dS = Analyzer.loops.conds{c}.repeats{r}.dispSyncs;
        
        dS = dS(2:end-1);

        
        counter(c,r) = length(dS);
        
        ddsync = diff(diff(dS));
        id = find(ddsync > fper/2);
        ddcounter(c,r) = length(id);
        
%         if ddcounter(c,r) ~= 0
%             
%             figure,
%             subplot(2,1,1), plot(Analyzer.loops.conds{c}.repeats{r}.dSyncswave)
%             subplot(2,1,2), stem(dS)
%             return
%         end

    end
end

counter
ddcounter
ddwarningflag = 0;
if sum(ddcounter(:)) ~= 0
    ddwarningflag = 1;   %indicates missed frames
end

warningflag = 0;
if length(unique(counter(:))) ~= 1 
    warningflag = 1;  %indicates missed syncs (if this happens, so might the other)
end