function updatePstate(psymbol,pval)

global Pstate

for i = 1:length(Pstate.param)
    if strcmp(psymbol,Pstate.param{i}{1})
    	idx = i;
        break;
    end
end

switch Pstate.param{idx}{2}
    
   case 'float'
      Pstate.param{idx}{3} = str2num(pval);
   case 'int'
      Pstate.param{idx}{3} = str2num(pval);
   case 'string'
      Pstate.param{idx}{3} = pval;
end
   


