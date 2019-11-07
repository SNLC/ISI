function [y] = f1image_append(cond)

%% Compute the F1 for one condition

global pepANA frameang

pepsetcondition(cond);
nr = pepgetnorepeats;

for(r=0:nr-1)
    pepsetrepeat(r)
    T = pepgetperiod;
    ttag = pepgettimetag;
    ts = pepgettimes(ttag);
    sync = pepgetsync;      %Array of times for the beginning of each rotation within repeat
    frames{r+1} = pepgetframeidx(ttag,[0 sync(end)]);
    framest = pepANA.imaging.isync(frames{r+1}(1):frames{r+1}(2));  %integer sample values
    framest = (framest - ts(1))/30;  %% frame sampling times in msec  (Cerebrus: 30 samp/ms)
    frameang{r+1} = framest/T*2*pi;       %% convert to radians
end
 
% for r = 1:nr-1
%     mod(r) = angle(exp(1i*frameang{r+1}(1))) - angle(exp(1i*frameang{r}(end))) - angle(exp(1i*mean(diff(frameang{r}))));
%     frameang{r+1} = frameang{r+1} - mod(r);  %Shift phase to match previous repeat.
% end

N = 0;
for r = 1:nr
    k = 1;
    for(j=frames{r}(1):frames{r}(2))
     
        img = peploadimage(j);
        
        if(j==frames{1}(1))
            acc = zeros(size(img));
            f0 =  zeros(size(img));
        end
        
        acc = acc + exp(1i*frameang{r}(k)).*img;
        f0 = f0 + img;
        
        k = k+1;
    end
    N = N + k-1;
end
    
   f0 = f0./N;
   
   residue = 0;
   for r = 1:nr
       residue = sum(exp(1i*frameang{r})) + residue;
   end
   acc = acc - f0*residue; %Subtract f0 leakage
   acc = 2*acc ./ N; %Normalize for f1 amplitude
   
   y = acc;

    
    