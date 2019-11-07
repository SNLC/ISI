function [xpos ypos xsize ysize] = getPosSize

%Used for coarse retinotopy analysis

global pepANA

x_zoom = get(pepANA.module,'x_zoom');
y_zoom = get(pepANA.module,'y_zoom');
loopform = get(pepANA.looper,'formula');

k = 1;
for i = 0:pepgetnoconditions-1
    pepsetcondition(i)
    if(~pepblank)       %This loop filters out the blanks
        v = pepgetvalues;

        a = v(1);
        b = v(2);
        
        eval(loopform);
        
        if b == 0
            xpos(k) = x_pos;
            xsize(k) = x_size*x_zoom; %units of pixels
            ypos(k) = NaN;  %y_pos starts at 380 and goes bottom to top
            ysize(k) = NaN;
        else
            %ypos(k) = y_pos - 380;  %y_pos starts at 380 and goes bottom to top
            ypos(k) = y_pos;
            ysize(k) = y_size*y_zoom;
            xpos(k) = NaN;
            xsize(k) = NaN;
        end
        
        k = k+1;
    end
end

