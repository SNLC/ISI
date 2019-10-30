function saveLog_rain(x,varargin)

global Mstate

root = '/Matlab_code/log_files/';

rootnet = ['/Volumes/neurostuff/log_files/' Mstate.anim '/'];

expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.mat'];
fnamenet = [rootnet expt '.mat'];

frate = Mstate.refresh_rate;

if isempty(varargin)  %from 'make'  (happens on first trial only)

    domains = x; 
    if ~exist(fname)
        save(fname,'domains','frate')    
        save(fnamenet,'domains','frate')
    end
    
else %from 'play'
    
    eval(['rseed' num2str(varargin{1}) '=x;' ])
    eval(['save ' fname ' rseed' num2str(varargin{1}) ' -append'])    
    eval(['save ' fnamenet ' rseed' num2str(varargin{1}) ' -append'])   
    
end
