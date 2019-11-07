function [f1m signals] = Gf1meanimage(varargin)

global Analyzer f1

% Compute mean f1 across all conditions and repeats

nc = length(Analyzer.loops.conds);

f1 = cell(1,nc);
sig1 = cell(1,nc);

for c=1:nc
    [f1{c} sig1{c}] = Gf1image(c,varargin);
end

% Now average all the repeats

if length(varargin) == 2
    for c = 1:nc 
        nr = length(f1{c});
        sig2 = addtrunc(sig1{c},nr); %sig2 is a matrix where each row is a pixel (mean is already subtracted)
        sig2 = sig2./nr;
        signals{c} = sig2;
    end
else
    signals = 0;
end


for c=1:nc
    img = f1{c}{1};
    nr = length(f1{c});
    for r=2:nr
        img = img+f1{c}{r};
    end
    img = img/nr;
    f1m{c} = img;  %% Compute mean image
end


function y = addtrunc(x,nr)
%Truncates all signals in x to the length of shortest one, and then adds them.
for i = 1:nr
    N(i) = length(x{i}(1,:));
end
shortest = min(N);  %Length of shortest repeat

y = zeros(length(x{1}(:,1)),shortest); %(No. of pixels) x (length of shortest repeat)
for i = 1:nr
    y = y + x{i}(:,1:shortest);
end
 
