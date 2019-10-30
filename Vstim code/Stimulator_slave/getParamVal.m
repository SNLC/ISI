function pval = getParamVal(psymbol)

global Pstate

for i = 1:length(Pstate.param)
    if strcmp(psymbol,Pstate.param{i}{1})
    	idx = i;
        break;
    end
end

pval = Pstate.param{idx}{3};
