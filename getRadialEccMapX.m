function AreaInfo = getRadialEccMapX(kmap_hor,kmap_vert)

%This one uses the intersection of RL LM and V1
%3 is a version of zero that uses the result of getAreaNames.  That is it
%takes a patch id to find the areas

kmap_hor = AreaInfo.kmap_hor;
kmap_vert = AreaInfo.kmap_vert;

mmperpix = 1/39;

LMpatch = zeros(size(AreaInfo.Patch_old));
RLpatch = zeros(size(AreaInfo.Patch_old));
V1patch = zeros(size(AreaInfo.Patch_old));

for i = 1:length(AreaInfo.List)

    switch AreaInfo.List{i}

        case 'V1'
            V1patch(find(AreaInfo.Patch_old == i)) = 1;
        case 'LM'
            LMpatch(find(AreaInfo.Patch_old == i)) = 1;
        case 'RL'
            RLpatch(find(AreaInfo.Patch_old == i)) = 1;
    end

end


%% Find the intersection

SE = strel('disk',5,0);

LMpatch = imdilate(LMpatch,SE); 
RLpatch = imdilate(RLpatch,SE); 
V1patch = imdilate(V1patch,SE); 

imOverLap = V1patch + RLpatch + LMpatch;

[idy idx] = find(imOverLap == 3);


if isempty(idy) %Try dilating more if they haven't all connected
    SE = strel('disk',4,0);
    imOverLap = imdilate(V1patch,SE) + imdilate(RLpatch,SE) + imdilate(LMpatch,SE);
    [idy idx] = find(imOverLap == 3);
end

AreaInfo.xCent = ceil(mean(idx));
AreaInfo.yCent = ceil(mean(idy));
    
az = (kmap_hor - kmap_hor(AreaInfo.yCent,AreaInfo.xCent))*pi/180; %azimuth
alt = (kmap_vert - kmap_vert(AreaInfo.yCent,AreaInfo.xCent))*pi/180; %altitude
AreaInfo.kmap_rad = atan(sqrt(tan(az).^2 + (tan(alt).^2)./(cos(az).^2)))*180/pi;  %eccentricity
AreaInfo.kmap_ang = atan2(alt,az)*180/pi;

