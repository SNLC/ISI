function makeMapperTexture

%make one cycle of the grating

global Mstate screenPTR screenNum 

global Gtxtr TDim  %'playgrating' will use these

Gtxtr = []; TDim = [];  %reset

screenRes = Screen('Resolution',screenNum);

white = WhiteIndex(screenPTR); % pixel value for white
black = BlackIndex(screenPTR); % pixel value for black
gray = (white+black)/2;
amp = white-gray;

Pstruct = getParamStruct;

barWcm = 2*Mstate.screenDist*tan(Pstruct.barWidth/2*pi/180);  %bar width in cm
barLcm = 2*Mstate.screenDist*tan(Pstruct.barLength/2*pi/180);  %bar length in cm

%Make black/white domain
if Pstruct.bw_bit == 0
    bwdom = -1;
elseif Pstruct.bw_bit == 1
    bwdom = 1;
else
    bwdom = [-1 1];
end


Im = makeBar(barWcm,barLcm,0,screenRes);
Im = Im*Pstruct.contrast/100;
TDim = size(Im);  
for bwid = 1:length(bwdom)
    Gtxtr(bwid) = Screen(screenPTR, 'MakeTexture', gray+amp*Im*bwdom(bwid));
end


