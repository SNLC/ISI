function playmapper

global Mstate screenPTR screenNum 

global Gtxtr TDim  %Created in makeGratingTexture

Pstruct = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;


%%%%%%%%%%%%%%%%%%

symbList = {'ori','width','length','barLum','background'};
valdom{1} = 0:10:350;
valdom{2} = logspace(log10(.1),log10(60),30);
valdom{3} = logspace(log10(.1),log10(60),30);
valdom{4} = [0 128 255];
valdom{5} = [0 128 255];

state.valId = [1 8 15 3 1];  %Current index for each value domain
state.symId = 1;  %Current symbol index
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

%initialize the texture
[L W] = getbarDim(state,valdom,pixpercmX,pixpercmY);
Im = ones(L,W);
Im = Im*valdom{4}(state.valId(4));
Gtxtr = Screen(screenPTR, 'MakeTexture',Im);
TDim = size(Im);

symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];

StimPiece = [0 0 TDim(2)-1 TDim(1)-1]';

Screen(screenPTR, 'FillRect', valdom{5}(state.valId(5)))

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%

Screen(screenPTR,'DrawText','ori 0',40,30,255-255*floor(valdom{5}(state.valId(5))/255));
Screen('Flip', screenPTR);

bLast = [0 0 0];
keyIsDown = 0;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    
    db = bLast - b; %'1' is a button release
           
    %%%Case 1: Left Button%%%
    if ~sum(abs([1 0 0]-db))
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        end       
        
        val = valdom{state.symId}(state.valId(state.symId));

        [L W] = getbarDim(state,valdom,pixpercmX,pixpercmY);
                
        Im = ones(L,W);
        Im = Im*valdom{4}(state.valId(4));
        Gtxtr = Screen(screenPTR, 'MakeTexture', Im);
        TDim = size(Im);
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,255-255*floor(valdom{5}(state.valId(5))/255));
        Screen('Flip', screenPTR);
    end
    
    %%%Case 2: Middle Button%%%
    if ~sum(abs([0 0 1]-db))  % [0 0 1] is the scroll bar in the middle
        
        state.symId = state.symId+1; %update the symbol
        if state.symId > length(symbList)
            state.symId = 1; %unwrap
        end
        symbol = symbList{state.symId};
        val = valdom{state.symId}(state.valId(state.symId));
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,255-255*floor(valdom{5}(state.valId(5))/255));
        Screen('Flip', screenPTR);
    end
    
    %%%Case 3: Right Button%%%
    if ~sum(abs([0 1 0]-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        [L W] = getbarDim(state,valdom,pixpercmX,pixpercmY);
        
        Im = ones(L,W);
        Im = Im*valdom{4}(state.valId(4));
        Gtxtr = Screen(screenPTR, 'MakeTexture', Im);
        TDim = size(Im);
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,255-255*floor(valdom{5}(state.valId(5))/255));
        Screen('Flip', screenPTR);
    end
    
    
    xL = mx-(ceil(TDim(2)/2)-1);
    xR = mx+floor(TDim(2)/2);
    yL = my-(ceil(TDim(1)/2)-1);
    yR = my+floor(TDim(1)/2);
    StimLoc = [xL yL xR yR]';
    
    ori = valdom{1}(state.valId(1));
    %wi = valdom{2}(state.valId(2));
    %len = valdom{3}(state.valId(3));
    
    Screen('DrawTextures', screenPTR,Gtxtr,StimPiece,StimLoc,ori);    
    Screen(screenPTR,'DrawText',newtext,40,30,255-255*floor(valdom{5}(state.valId(5))/255));
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,255-255*floor(valdom{5}(state.valId(5))/255));
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck();
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', Pstruct.background)
Screen(screenPTR, 'Flip');

Screen('Close')  %Get rid of all textures/offscreen windows



function [L W] = getbarDim(state,valdom,pixpercmX,pixpercmY)

global Mstate

ori = valdom{1}(state.valId(1))*pi/180;

Wcm = 2*pi*Mstate.screenDist*valdom{2}(state.valId(2))/360;  %stimulus width in cm
W = sqrt((Wcm*cos(ori)*pixpercmX)^2  +  (Wcm*sin(ori)*pixpercmY)^2); 
W = round(W);

Lcm = 2*pi*Mstate.screenDist*valdom{3}(state.valId(3))/360;  %stimulus length in cm
L = sqrt((Lcm*sin(ori)*pixpercmX)^2  +  (Lcm*cos(ori)*pixpercmY)^2);
L = round(L);
