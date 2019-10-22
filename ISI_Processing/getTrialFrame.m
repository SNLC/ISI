function im = getTrialFrame(fno,varargin)

%if varargin has 2 elements, it assumes you have entered
%(condition,repeat).  If there is 1 element, it assumes you have entered
%the (timetag).

%fno is the frame number

global datadir

if length(varargin) ==  2
    cond = varargin{1};
    rep = varargin{2};
    ttag = gettimetag(cond,rep);
elseif length(varargin) == 1
	ttag = varargin{1};
end

ue = datadir(end-8:end-1);

fname = [datadir ue  '_' sprintf('%03d',ttag)];

var = ['f' num2str(fno)];

fname = [fname '_' var];
load(fname)

% load(fname,var)
% eval(['im = ' var ';'])

im = double(im);





