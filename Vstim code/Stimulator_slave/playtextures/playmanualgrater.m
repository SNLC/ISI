function playmanualgrater

global Mstate screenPTR screenNum 

global Gtxtr TDim  %Created in makeGratingTexture

Pstruct = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;


%%%%%%%%%%%%%%%%%%

symbList = {'ori','s_freq','t_period','mask_radius','background'};
valdom{1} = 0:10:350;
valdom{2} = logspace(log10(.01),log10(10),20);
valdom{3} = logspace(log10(.5),log10(10),20);  %Hz
valdom{3} = round(fliplr(screenRes.hz./valdom{3}));  %frames
valdom{4} = logspace(log10(.5),log10(60),20);
valdom{5} = [0 128 255];

state.valId = [10 10 5 8 2];  %Current index for each value domain
state.symId = 1;  %Current symbol index
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

%initialize the texture
for i = 1:length(valdom)
    symbol = symbList{i};
    val = valdom{i}(state.valId(i));
    updatePstate(symbol,num2str(val));
end
xsize = 2*valdom{4}(state.valId(4));  %width = 2*radius
ysize = xsize;
updatePstate('x_size',num2str(xsize));
updatePstate('y_size',num2str(ysize));
makeGratingTexture_periodic

symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];

StimPiece = [0 0 TDim(2)-1 TDim(1)-1]';

Screen(screenPTR, 'FillRect', valdom{5}(state.valId(5)))

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%

Screen(screenPTR,'DrawText','ori 0',40,30,255-255*floor(valdom{5}(state.valId(5))/255));
Screen('Flip', screenPTR);

TextrIdx = 1;
bLast = [0 0 0];
keyIsDown = 0;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    
    db = bLast - b; %'1' is a button release
           
    %%%Case 1: Left Button:  decrease value%%%
    if ~sum(abs([1 0 0]-db))  
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        end       
        
        val = valdom{state.symId}(state.valId(state.symId));
        
        if strcmp(symbol,'mask_radius')
            xsize = 2*valdom{4}(state.valId(4));  %width = 2*radius
            ysize = xsize;
            updatePstate('x_size',num2str(xsize));
            updatePstate('y_size',num2str(ysize));
        end
        
        updatePstate(symbol,num2str(val));
        makeGratingTexture_periodic
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,255-255*floor(valdom{5}(state.valId(5))/255));
        Screen('Flip', screenPTR);
    end
    
    %%%Case 2: Middle Button:  change parameter%%%
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
    
    %%%Case 3: Right Button: increase value%%%
    if ~sum(abs([0 1 0]-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        if strcmp(symbol,'mask_radius')
            xsize = 2*valdom{4}(state.valId(4));  %width = 2*radius
            ysize = xsize;
            updatePstate('x_size',num2str(xsize));
            updatePstate('y_size',num2str(ysize));
        end
        
        updatePstate(symbol,num2str(val));
        makeGratingTexture_periodic
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,255-255*floor(valdom{5}(state.valId(5))/255));
        Screen('Flip', screenPTR);
    end
    
    
    StimPiece = [0 0 TDim(2)-1 TDim(1)-1]';
    
    xL = mx-(ceil(TDim(2)/2)-1);
    xR = mx+floor(TDim(2)/2);
    yL = my-(ceil(TDim(1)/2)-1);
    yR = my+floor(TDim(1)/2);
    StimLoc = [xL yL xR yR]';
    
    ori = valdom{1}(state.valId(1));
    
    TextrIdx = rem(TextrIdx,length(Gtxtr))+1;
    
    Screen('DrawTextures', screenPTR,Gtxtr(TextrIdx),StimPiece,StimLoc);    
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

