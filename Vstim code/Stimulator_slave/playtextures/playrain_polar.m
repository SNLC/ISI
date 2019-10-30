function playrain_polar


global Mstate screenPTR screenNum loopTrial

global GtxtrAll OriAll StimPiece daq  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture


P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);
SyncLoc = [0 0 syncWX-1 syncWY-1]';
SyncPiece = [0 0 syncWX-1 syncWY-1]';

xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels

xran = [P.x_pos-floor(xN/2)+1  P.x_pos+ceil(xN/2)];
yran = [P.y_pos-floor(yN/2)+1  P.y_pos+ceil(yN/2)];

StimLoc = [xran(1) yran(1) xran(2) yran(2)]';
StimLoc = StimLoc*ones(1,P.Ndrops);

screenRes = Screen('Resolution',screenNum);
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);

%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

Screen(screenPTR, 'FillRect', P.background)

%Wake up the daq:
DaqDOut(daq, 0, 0); %I do this at the beginning because it improves timing on the first call to daq below

%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 7;  %Make 1st,2nd,3rd bits high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2), SyncPiece, SyncLoc);
    Screen(screenPTR, 'Flip');
end

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%


for i = 1:length(GtxtrAll)
    
    Screen('DrawTextures', screenPTR, [GtxtrAll{i} Stxtr(2-rem(i,2))],...
        [StimPiece{i,1} SyncPiece],[StimLoc SyncLoc],[OriAll{i} 0]);    
    Screen(screenPTR, 'Flip');
    
%     digWord = bitxor(digWord,4);  %toggle only the 3rd bit on each grating update
%     DaqDOut(daq,0,digWord); 
    
    for j = 2:P.h_per                  %sync flips on each update    
        
        Screen('DrawTextures', screenPTR, [GtxtrAll{i} Stxtr(2-rem(i,2))],...
            [StimPiece{i,j} SyncPiece],[StimLoc SyncLoc],[OriAll{i} 0]);          
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
    digWord = bitxor(digWord,7); %toggle all 3 bits (1st/2nd bits go low, 3rd bit is flipped)
    DaqDOut(daq, 0,digWord);
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),[0 0 syncWX-1 syncWY-1],SyncLoc);  
Screen(screenPTR, 'Flip');

