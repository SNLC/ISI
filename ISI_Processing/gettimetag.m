function ttag = gettimetag(c,r)

global Analyzer

ttag = Analyzer.loops.conds{c}.repeats{r}.timetag;
