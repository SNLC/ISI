function screenconfig

global screenPTR screenNum Mstate

%screens=Screen('Screens');
%screenNum=max(screens);

screenNum=0;

screenRes = Screen('Resolution',screenNum);

screenPTR = Screen('OpenWindow',screenNum);

Screen(screenPTR,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

updateMonitor

Screen('PixelSizes',screenPTR)

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

Mstate.refresh_rate = 1/Screen('GetFlipInterval', screenPTR);

%SyncLoc = [0 screenRes.height-syncWY syncWX-1 screenRes.height-1]';
SyncLoc = [0 0 syncWX-1 syncWY-1]';
SyncPiece = [0 0 syncWX-1 syncWY-1]';

%Set the screen

Screen(screenPTR, 'FillRect', 128)
Screen(screenPTR, 'Flip');

wsync = Screen(screenPTR, 'MakeTexture', 0*ones(syncWY,syncWX)); % "low"

Screen('DrawTexture', screenPTR, wsync,SyncPiece,SyncLoc);
Screen(screenPTR, 'Flip');


