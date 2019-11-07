function [orimap] = GprocessOri(f0,hh)

global Analyzer
%Each element of the cell array 'f0dum' is the average image for the
%corresponding condition

nc = length(Analyzer.loops.conds);

%if blank exists, it is always the last condition
bflag = 0;
if strcmp(Analyzer.loops.conds{nc}.symbol,'blank') 
    bflag = 1;
end

for i = 1:(nc-bflag)
    ori(i) = Analyzer.loops.conds{i}.val{1};
    Tens(:,:,i) = f0{i};
end

mi = min(Tens,[],3);
for i = 1:(nc-bflag)
    if bflag == 1
        Tens(:,:,i) = Tens(:,:,i)-f0{end};
    else
        Tens(:,:,i) = Tens(:,:,i)-mi;
    end
end

% su = sum(abs(Tens),3);
% for k = 1:length(Tens(1,1,:))
%     Tens(:,:,k) = Tens(:,:,k)./su;
% end

% id = find(Tens(:)<0);
% Tens(id) = 0;

orimap = zeros(size(f0{1}));
for k = 1:(nc-bflag)
    %orimap = orimap + f0{k}*exp(1i*2*ori(k)*pi/180);    %Linear combination
    orimap = orimap + Tens(:,:,k)*exp(1i*2*ori(k)*pi/180);    %Linear combination
end

%if a filter exists, use it...
if ~isempty(hh)
    id = find(isnan(orimap));
    orimap(id) = 0;
    %hh = fspecial('gaussian',size(orimap),.5);
    orimap = ifft2(abs(fft2(hh)).*fft2(orimap));    
end

