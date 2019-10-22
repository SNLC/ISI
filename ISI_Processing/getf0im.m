function f0im = getf0im

global Analyzer datadir

ue = 'u000_044';
Anroot = 'Z:\Ian_N\neurodata\xx0\';
Dataloc = ['C:\imager_data\xx0\' ue '\'];

setAnalyzerDirectory(Anroot)
loadAnalyzer(ue)

setISIdatadirectory(Dataloc)

nc = length(Analyzer.loops.conds);

for c = 1:nc
    f0im{c} = 0;
    nr = length(Analyzer.loops.conds{c}.repeats);
    for r = 1:nr
        
        tens = double(loadTrialData(c,r));
        if r == 1
            f0im{c} = zeros(size(tens));
        end

        f0im{c} = f0im{c} + tens/nr;
        
    end
end



