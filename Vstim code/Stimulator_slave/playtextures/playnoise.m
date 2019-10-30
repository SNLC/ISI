function playnoise

global Mstate screenPTR screenNum loopTrial

global Gtxtr TDim daq  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture

%Wake up the daq:
DaqDOut(daq, 0, 0); %I do this at the beginning because it improves timing on the call to daq below

P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

% xcm = 2*Mstate.screenDist*tan(P.x_size/2*pi/180);  %stimulus width in cm
% xN = round(xcm*pixpercmX);  %stimulus width in pixels
% ycm = 2*Mstate.screenDist*tan(P.y_size/2*pi/180);  %stimulus height in cm
% yN = round(ycm*pixpercmY);  %stimulus height in pixels

%The following assumes the screen is curved
xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels

xran = [P.x_pos-floor(xN/2)+1  P.x_pos+ceil(xN/2)];
xran(1) = max([xran(1) 0]); xran(2) = min([xran(2) screenRes.width-1]);
yran = [P.y_pos-floor(yN/2)+1  P.y_pos+ceil(yN/2)];
yran(1) = max([yran(1) 0]); yran(2) = min([yran(2) screenRes.height-1]);

%%%%%%%%%%%%%%%%%%


Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
N_Im = round(P.stim_time*screenRes.hz/P.h_per); %number of images to present

%%%%%%%%%%%%%%%

%SyncLoc = [0 screenRes.height-syncWY syncWX-1 screenRes.height-1]';
SyncLoc = [0 0 syncWX-1 syncWY-1]';
SyncPiece = [0 0 syncWX-1 syncWY-1]';
StimLoc = [xran(1) yran(1) xran(2) yran(2)]';
StimPiece = [0 0 TDim(2)-1 TDim(1)-1]';
%%%%%%%%%%%%%%%


Screen(screenPTR, 'FillRect', P.background)

%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 3;  %Make 1st and 2nd bits high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);
    Screen(screenPTR, 'Flip');
end

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%
for i = 1:N_Im
    Screen('DrawTextures', screenPTR, [Gtxtr(i) Stxtr(2-rem(i,2))],[StimPiece SyncPiece],[StimLoc SyncLoc],0,0);
    Screen(screenPTR, 'Flip');
    for j = 2:P.h_per
        Screen('DrawTextures', screenPTR, [Gtxtr(i) Stxtr(2-rem(i,2))],[StimPiece SyncPiece],[StimLoc SyncLoc],0,0);
        Screen(screenPTR, 'Flip');
    end
end


%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);
    Screen(screenPTR, 'Flip');
end
Screen('DrawTexture', screenPTR, Stxtr(1),SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');

if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);  
Screen(screenPTR, 'Flip');

