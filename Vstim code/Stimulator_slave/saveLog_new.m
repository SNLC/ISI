function saveLog_new(domains,seqs)


global Mstate loopTrial

root = '/Matlab_code/log_files/';

rootnet = ['/Volumes/neurostuff/log_files/' Mstate.anim '/'];

expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.mat'];
fnamenet = [rootnet expt '.mat'];

frate = Mstate.refresh_rate;

%%%

basename = ['randlog_T' num2str(loopTrial)];

eval([basename '.seqs = seqs;'])
eval([basename '.domains = domains;'])

if loopTrial == 1
    save(fname,['randlog_T' num2str(loopTrial)])
    save(fnamenet,['randlog_T' num2str(loopTrial)])
    
    save(fname,'frate','-append')
    save(fnamenet,'frate','-append')
else
    save(fname,['randlog_T' num2str(loopTrial)],'-append')
    save(fnamenet,['randlog_T' num2str(loopTrial)],'-append')
end


