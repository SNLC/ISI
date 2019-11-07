function [y1 y2] = condF0_sigma(b,normflag,F0_1,F0_2)

%Compute the standard deviation tensor for each condition

%The new version builds the entire Tensor, as opposed to truncating within a time interval 
%
%b is a 2D vector corresponding the the beginning and end of
%the baseline subtraction images, in milliseconds. e.g. varargin = {[0 500]} sums
%the images from 0 to .5 seconds for each repetition and then subtracts it
%from the mean response in the repeat.
%
%shiftflag performs movement correction 
%Rflag fits a line to the red/green scatter plot and subtracts this trend
%from the data in the green channel

global Analyzer bsflag bcond

nc = length(Analyzer.loops.conds);

%Find blank condition:
%if blank exists, it is always the last condition
if strcmp(Analyzer.loops.conds{nc}.symbol,'blank')
    bcond = nc;  
end


y1 = cell(1,nc);
y2 = cell(1,nc);

for c = 1:nc
    
    nr = length(Analyzer.loops.conds{c}.repeats);
    
    y1{c} = 0;
    for r = 1:2:nr
        
        im = getTrialMean(Tlim,c,r);

        if bsflag == 1

            bimg = getTrialMean(Tlimb,c,r);
            im = im-bimg;
            im = im./bimg;

        end
        
        %Average repeats:  /nr is important for when blanks have different
        %number of reps
 
        y1{c} = y1{c} + ((im-F0_1{c}).^2)/length(1:2:nr); 

    end
    
    y2{c} = 0;
    for r = 2:2:nr

        im = getTrialMean(Tlim,c,r);

        if bsflag == 1

            bimg = getTrialMean(Tlimb,c,r);
            im = im-bimg;
            im = im./bimg;

        end

        %Average repeats:  /nr is important for when blanks have different
        %number of reps

        y2{c} = y2{c} + ((im-F0_2{c}).^2)/length(2:2:nr);

    end

end

