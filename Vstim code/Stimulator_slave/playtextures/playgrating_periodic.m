function playgrating_periodic

global Mstate screenPTR screenNum loopTrial 

global Gtxtr TDim daq  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture

Pstruct = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black
gray = (white+black)/2;
amp = white-gray;

if strcmp(Pstruct.altazimuth,'none')
    
    %The following assumes the screen is curved
    xcm = 2*pi*Mstate.screenDist*Pstruct.x_size/360;  %stimulus width in cm
    xN = round(xcm*pixpercmX);  %stimulus width in pixels
    ycm = 2*pi*Mstate.screenDist*Pstruct.y_size/360;   %stimulus height in cm
    yN = round(ycm*pixpercmY);  %stimulus height in pixels
    
else
    
    xN = 2*Mstate.screenDist*tan(Pstruct.x_size/2*pi/180);  %grating width in cm
    xN = round(xN*pixpercmX);  %grating width in pixels
    yN = 2*Mstate.screenDist*tan(Pstruct.y_size/2*pi/180);  %grating height in cm
    yN = round(yN*pixpercmY);  %grating height in pixels
    
end

%Note: I used to truncate these things to the screen size, but it is not
%needed.  It also messes things up.
xran = [Pstruct.x_pos-floor(xN/2)+1  Pstruct.x_pos+ceil(xN/2)];
yran = [Pstruct.y_pos-floor(yN/2)+1  Pstruct.y_pos+ceil(yN/2)];

cycles = Pstruct.stim_time/(Pstruct.t_period/screenRes.hz);
Nlast = round(TDim(3)*(cycles-floor(cycles)));  %number of frames on last cycle

nDisp = TDim(3)*ones(1,floor(cycles));  %vector of the number of frames for N-1 cycles
if Nlast >= 2 %Need one for sync start, and one for stop
    nDisp = [nDisp Nlast];  %subtract one because of last sync pulse 
elseif Nlast == 1  %This is an annoying circumstance because I need one frame for sync start
                    %and one for sync stop.  I just get rid of it as a hack.
    cycles = cycles - 1;
end

nDisp(end) = nDisp(end)-1; %subtract one because of last sync pulse


Npreframes = ceil(Pstruct.predelay*screenRes.hz);
Npostframes = ceil(Pstruct.postdelay*screenRes.hz);

%%%%
%SyncLoc = [0 screenRes.height-syncWY syncWX-1 screenRes.height-1]';
SyncLoc = [0 0 syncWX-1 syncWY-1]';
SyncPiece = [0 0 syncWX-1 syncWY-1]';
StimLoc = [xran(1) yran(1) xran(2) yran(2)]';
StimPiece = [0 0 TDim(2)-1 TDim(1)-1]';
%%%%

Screen(screenPTR, 'FillRect', Pstruct.background)

%Wake up the daq:
DaqDOut(daq, 0, 0); %I do this at the beginning because it improves timing on the first call to daq below

   

%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1  %if you hit "run", send pulse
    digWord = 7;  %Make 1st,2nd,3rd bits high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);
    Screen(screenPTR, 'Flip');
end



%%%%%%Play sound also%%%%%%
switch Pstruct.sound_type
    case 0
        
    case 1
        
        d = Pstruct.stim_time; f = Pstruct.tone_freq; Fs = 22050;
        soundwave = audioplayer(sin(linspace(0, d*f*2*pi, round(d*Fs))),Fs);        
        play(soundwave);
        
    case 2
        
        d = Pstruct.stim_time; Fs = 22050;
        soundwave = audioplayer(randn(d*Fs,1)/2,Fs);
        play(soundwave);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%
for j = 1:ceil(cycles)
    Screen('DrawTextures', screenPTR, [Gtxtr(1) Stxtr(1)],[StimPiece SyncPiece],[StimLoc SyncLoc]);
    Screen(screenPTR, 'Flip');
    %digWord = bitxor(digWord,4);  %toggle only the 3rd bit on each grating cycle
    %DaqDOut(daq,0,digWord);  
    for i=2:nDisp(j)
        Screen('DrawTextures', screenPTR, [Gtxtr(i) Stxtr(2)],[StimPiece SyncPiece],[StimLoc SyncLoc]);
        Screen(screenPTR, 'Flip');
    end
end
Screen('DrawTextures', screenPTR, [Gtxtr(nDisp(j)+1) Stxtr(1)],[StimPiece SyncPiece],[StimLoc SyncLoc]);
Screen(screenPTR, 'Flip');  %Show sync on last frame of stimulus
%digWord = bitxor(digWord,4);  %toggle only the 3rd bit on each grating cycle
%DaqDOut(daq, 0, digWord); 


%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);
    Screen(screenPTR, 'Flip');
end
Screen('DrawTexture', screenPTR, Stxtr(1),SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1 %if you hit "run", send pulse
    digWord = bitxor(digWord,7); %toggle all 3 bits (1st/2nd bits go low, 3rd bit is flipped)
    DaqDOut(daq, 0,digWord);
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);  
Screen(screenPTR, 'Flip');

