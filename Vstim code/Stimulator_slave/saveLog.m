function saveLog(x,varargin)

%An important thing to note on the way this is saved:  Since domains are
%only saved once, I can't put variables in the looper that
%would change this.  Also, rseeds are saved on top of each other. The
%sequences would also change if other parameters change, such as nori.

global Mstate

root = '/Matlab_code/log_files/';

rootnet = ['/Volumes/neurostuff/log_files/' Mstate.anim '/'];

expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.mat'];
fnamenet = [rootnet expt '.mat'];

frate = Mstate.refresh_rate;

if isempty(varargin)  %from 'make'  (happens on first trial only)... save domains and frame rate

    domains = x; 
    save(fname,'domains','frate')    
    save(fnamenet,'domains','frate')
    
else %from 'play'... save sequence as 'rseedn'
    
    eval(['rseed' num2str(varargin{1}) '=x;' ])
    eval(['save ' fname ' rseed' num2str(varargin{1}) ' -append'])    
    eval(['save ' fnamenet ' rseed' num2str(varargin{1}) ' -append'])   
    
end

%%%The following version would save the domains on each trial (but I haven't tested it).
%I would also have to change the conditional statement that calls it in the
%make file
% 
global loopTrial

if isempty(varargin)  %from 'make'  (happens on first trial only)... save domains and frame rate

    eval(['domains' num2str(loopTrial) '= x']);     
    eval(['save ' fname 'domains' num2str(loopTrial) ' -append'])
    eval(['save ' fnamenet 'domains' num2str(loopTrial) ' -append'])
    
else %from 'play'... save sequence as 'rseedn'
    
    eval(['rseed' num2str(varargin{1}) '=x;' ])
    eval(['save ' fname ' rseed' num2str(varargin{1}) ' -append'])    
    eval(['save ' fnamenet ' rseed' num2str(varargin{1}) ' -append'])   
    
end