function GrabContOverlay(varargin)

global ROIcrop IMGSIZE imstate parport imagerhandles

h = imagerhandles;

h.mildig.set('GrabFrameEndEvent',0,'GrabEndEvent',...
            0,'GrabStartEvent',0);

grayid = gray;
hsvid = jet;

aw = 1-imstate.intRatio;  %anatomy weight of image (scalar)
fw = imstate.intRatio;  %anatomy weight of image (scalar)

mag = imstate.mag.*imstate.bw;
mag = mag-min(mag(:));
mag = mag/max(mag(:));

imfunc = imstate.imfunc;
imfunc = imfunc-min(imfunc(:));
imfunc = imfunc/max(imfunc(:));
imfunc = round(imfunc*63+1);

zz = zeros(ROIcrop(3),ROIcrop(4),'uint16');
h.mildig.Grab;
h.mildig.GrabWait(3);

imanat = h.milimg.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));

%TTL pulse
putvalue(parport,1); putvalue(parport,0);

imout = makeplotter(double(imanat),imfunc,mag,aw,fw,grayid,hsvid);

figure(87)
imagesc(imout), colormap hsv
drawnow;
    

function imout = makeplotter(imanat,imfunc,mag,aw,fw,grayid,hsvid)

dim = size(imfunc);

imanat = imanat-min(imanat(:));
imanat = imanat/max(imanat(:));
imanat = round(imanat*63+1);

for i = 1:dim(1)
    for j = 1:dim(2)
        imout(i,j,:) = fw*mag(i,j)*hsvid(imfunc(i,j),:) + aw*grayid(imanat(i,j),:);  
        %imout(i,j,:) = grayid(imanat(i,j),:);  
    end
end

imout = imout/max(imout(:));
 

