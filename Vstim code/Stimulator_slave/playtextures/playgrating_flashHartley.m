function playgrating_flashHartley

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr TDim domains probRatios  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture


P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black
gray = (white+black)/2;
amp = white-gray;

%The following gives inaccurate spatial frequencies
% xN = 2*Mstate.screenDist*tan(P.x_size/2*pi/180);  %grating width in cm
% xN = round(xN*pixpercmX);  %grating width in pixels
% yN = 2*Mstate.screenDist*tan(P.y_size/2*pi/180);  %grating height in cm
% yN = round(yN*pixpercmY);  %grating height in pixels

%The following assumes the screen is curved
xcm = 2*pi*Mstate.screenDist*P.x_size/360;  %stimulus width in cm
xN = round(xcm*pixpercmX);  %stimulus width in pixels
ycm = 2*pi*Mstate.screenDist*P.y_size/360;   %stimulus height in cm
yN = round(ycm*pixpercmY);  %stimulus height in pixels

%Note: I used to truncate these things to the screen size, but it is not
%needed.  It also messes things up.
xran = [P.x_pos-floor(xN/2)+1  P.x_pos+ceil(xN/2)];
yran = [P.y_pos-floor(yN/2)+1  P.y_pos+ceil(yN/2)];

Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Create Sequence for this trial%%%%%

kdom = domains.kmatID; %indices into first quadrant of full subspace
oridom = [0 90 180 270];  %The four quadrants of Hartley space
bwdom = domains.bwdom;
colordom = domains.colordom;

N_Im = round(P.stim_time*screenRes.hz/P.h_per); %number of images to present

s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',P.rseed);
bwseq = randi(s,[1 length(bwdom)],1,N_Im); %N_Im random indices for the "mixed bag"
oriseq = randi(s,[1 length(oridom)],1,N_Im); %N_Im random indices for the "mixed bag"
kseq = randi(s,[1 length(kdom)],1,N_Im); %N_Im random indices for the "mixed bag"
colorseq = randi(s,[1 length(colordom)],1,N_Im); %N_Im random indices for the "mixed bag"

if P.blankProb > 0
    nblanks = round(P.blankProb*N_Im);
    bidx = randi(s,[1 N_Im],1,nblanks);
    %blank condition is identified with the following indices
    bwseq(bidx) = 1;
    oriseq(bidx) = 1;
    kseq(bidx) = length(kdom) + 1;
    colorseq(bidx) = 1;
end
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

%%%%
%SyncLoc = [0 screenRes.height-syncWY syncWX-1 screenRes.height-1]';
SyncLoc = [0 0 syncWX-1 syncWY-1]';
SyncPiece = [0 0 syncWX-1 syncWY-1]';
StimLoc = [xran(1) yran(1) xran(2) yran(2)]';
StimPiece = [0 0 TDim(2)-1 TDim(1)-1]';


srcrect = ones(N_Im,1)*StimPiece';

id = find(oridom(oriseq) == 90 | oridom(oriseq) == 180);
srcrect(id,[1 3]) = srcrect(id,[3 1]);

id = find(oridom(oriseq) == 270  | oridom(oriseq) == 180);
srcrect(id,[2 4]) = srcrect(id,[4 2]);

%%%%

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
    Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);
    Screen(screenPTR, 'Flip');
end

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%

%Unlike periodic grater, this doesn't produce a digital sync on last frame, just
%the start of each grating.  But this one will always show 'h_per' frames on
%the last grating, regardless of 'stimtime'.


for i = 1:N_Im
    
    Screen('DrawTextures', screenPTR, [Gtxtr(kseq(i),bwseq(i),colorseq(i)) Stxtr(2-rem(i,2))],...
    [srcrect(i,:)' SyncPiece],[StimLoc SyncLoc]);
    
    Screen(screenPTR, 'Flip');
    %digWord = bitxor(digWord,4);  %toggle only the 3rd bit on each grating update
    %DaqDOut(daq,0,digWord);
    for j = 2:P.h_per                  %sync flips on each update
        Screen('DrawTextures', screenPTR, [Gtxtr(kseq(i),bwseq(i),colorseq(i)) Stxtr(2-rem(i,2))],...
            [srcrect(i,:)' SyncPiece],[StimLoc SyncLoc]);
        
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
%digWord = bitxor(digWord,7); %toggle all 3 bits (1st/2nd bits go low, 3rd bit is flipped)
%DaqDOut(daq, 0,digWord);  

if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),SyncPiece,SyncLoc);  
Screen(screenPTR, 'Flip');


if Mstate.running
    Pseq.phaseseq = phaseseq;
    Pseq.oriseq = oriseq;
    Pseq.sfseq = sfseq;
    Pseq.colorseq = colorseq;
    saveLog(Pseq,P.rseed)  %append log file with the latest sequence
end


