function [y s] = Gf1image(cond,varargin)

%%% Compute the F1 for one condition

global Analyzer

inputs = varargin{1};
nr = length(Analyzer.loops.conds{cond}.repeats);

if length(inputs)==2    %if we want to analyze a pixel.
    N = length(inputs{1}(:,1));   %# of pixels;
    ps = inputs{2};  %pixel size
    pixels = inputs{1};  %Matrix of pixel locations; 1st column is y values
    for i = 1:N
        yr(i,:) = ((pixels(i,1):pixels(i,1)+ps-1))-floor(ps/2);   %yrange of first pixel
        xr(i,:) = ((pixels(i,2):pixels(i,2)+ps-1))-floor(ps/2);   %xrange of first pixel
    end
else
    s = [];
end



for r = 1:nr
%    for r=1:1 %for one repeat

    Grabtimes = Analyzer.loops.conds{cond}.repeats{r}.acqSyncs;
    %Stimulus starts on 2nd sync, and ends on the second to last.  I also
    %get rid of the last bar rotation (dispSyncs(end-1)) in case it is not an integer multiple
    %of the stimulus trial length
    Disptimes = Analyzer.loops.conds{cond}.repeats{r}.dispSyncs(2:end-1);
    
    %T = getparam('t_period')/60;
    T = mean(diff(Disptimes)); %This one might be more accurate
    
    fidx = find(Grabtimes>Disptimes(1) & Grabtimes<Disptimes(end));  %frames during stimulus

    framest = Grabtimes(fidx)-Disptimes(1);  % frame sampling times in sec
    frameang = framest/T*2*pi;       %% convert to radians
    
    %Stack = loadTrialData(cond,r);
    
    k = 1;
   
    tic
    for j=fidx(1):fidx(end)
        
        img = 4096-getTrialFrame(j,cond,r);
        %img = 4096-double(Stack(:,:,j));
        
        if length(inputs)==2
            for i = 1:N
                sig(i,k) = mean2(img(yr(i,:),xr(i,:)));
            end
        end
     
        if j==fidx(1)
            acc = zeros(size(img));
            f0 =  zeros(size(img));
        end

        acc = acc + exp(1i*frameang(k)).*img;
        f0 = f0 + img;

        k = k+1;

    end
    toc
    
  %% f0 = f0./(fidx(end)-fidx(1)+1);
   f0 = f0./(k-1);
   acc = acc - f0*sum(exp(1i*frameang)); %Subtract f0 leakage
  %% acc = 2*acc ./ (length(fidx(1):fidx(end))); %Normalize for f1 amplitude
   acc = 2*acc ./ (k-1); %Normalize for f1 amplitude 
  
   y{r} = acc;
   
   if length(inputs)==2
       mp = mean(sig');             %find mean of each pixel in the repeat
       mp = meshgrid(mp,1:length(sig(1,:)))';
       s{r} = sig-mp;
   end

end

    
    