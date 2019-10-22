function pval = getparam(param)

global Analyzer

for i = 1:length(Analyzer.P.param)
    if strcmp(Analyzer.P.param{i}{1},param)
        
        pval = Analyzer.P.param{i}{3};
        break
        
    end
end