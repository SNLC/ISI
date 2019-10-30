function makeSyncTexture

%write black/white sync to the offscreen

global Mstate screenPTR screenNum 

global Stxtr %'playgrating' will use these

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black

screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

Stxtr(1) = Screen(screenPTR, 'MakeTexture', white*ones(syncWY,syncWX)); % "hi"
Stxtr(2) = Screen(screenPTR, 'MakeTexture', black*ones(syncWY,syncWX)); % "low"

