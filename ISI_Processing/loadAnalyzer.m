function loadAnalyzer(ue)

global anadir Analyzer
anadir
Anim = anadir(end-3:end-1);
fname = [Anim '_' ue];
path = [anadir fname '.analyzer']

load(path,'Analyzer','-mat')