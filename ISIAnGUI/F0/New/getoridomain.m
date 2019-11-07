function oridomain = getoridomain

k = 1;
for(i=0:pepgetnoconditions-1)
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;
        ori(k) = v(1);
        k = k+1;
    end
end

oridomain = sort(ori);