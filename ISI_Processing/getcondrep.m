function [cond rep] = getcondrep(ttag)

global Analyzer

conds = length(Analyzer.loops.conds);
reps = length(Analyzer.loops.conds{1}.repeats);

for c = 1:conds
    for r = 1:reps
        ttag2 = Analyzer.loops.conds{c}.repeats{r}.timetag;
        if ttag == ttag2
            cond = c;
            rep = r;
            return
        end
    end
end
