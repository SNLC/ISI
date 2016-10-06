function [AreaMap] = SerenoAnalysis(kmap_hor,kmap_vert)
%function [AreaMap] = SerenoAnalysis(kmap_hor,kmap_vert) Applies visual
%field sign analysis as in Sereno & Allman 1994, Sereno et al. 1995. Also
%rotates the maps using the hardcoded pitch, yaw, roll values and outputs
%them as RPHI and RTHETA globally. Plots intermediate steps as in the
%Sereno & Allman 1994 paper.
%
%Jim Marshel. 8/23/2012

global RTHETA RPHI% VTHETAx VTHETAy VPHIx VPHIy THETAmag PHImag PHIangles THETAangles

%The size of kmap_vert and kmap_hor must be the same.
kmap_vert = kmap_vert-20;
%transform from spherical to cartesian coordinates and plot data in 3D
THETA = deg2rad(kmap_hor);
PHI = deg2rad(kmap_vert);
[dim1 dim2] = size(THETA);

if dim1<dim2
    dimdif = dim2-dim1;
    temp = NaN(dim2,dim2);
    TH = temp;
    PH = temp;
    TH(1:dim1,1:dim2) = THETA;
    PH(1:dim1,1:dim2) = PHI;
    THETA = TH;
    PHI = PH;
    [dim1 dim2] = size(THETA);
elseif dim2<dim1
    dimdif = dim1-dim2;
    temp = NaN(dim1,dim1);
    TH = temp;
    PH = temp;
    TH(1:dim1,1:dim2) = THETA;
    PH(1:dim1,1:dim2) = PHI;
    THETA = TH;
    PHI = PH;
    [dim1 dim2] = size(THETA);
end   

R = ones(dim1,dim2);
[x,y,z] = sph2cart(THETA,PHI,R);
figure('Name','Retinotopy 3D')
surf(x,y,z)
xlabel('x'),ylabel('y'),zlabel('z')
axis equal

%test transform back from cartesian to spherical
[hor,vert,R]=cart2sph(x,y,z);
figure('Name','Retransformed Horizontal Retinotopy - THETA (should be same as original)'), imagesc(hor),colorbar,colormap(hsv)
figure('Name','Retransformed Vertical Retinotopy - PHI (should be same as original'), imagesc(vert),colorbar,colormap(jet)

%Rotate coordinates
%-90,180,90 for fovea, with theta rotated properly for arrow diagram
yaw = -90;  %-90 for rotation where center of gaze is directly in front of animal
pitch = 180;  %90 to rotate such that the center of gaze is the fovea without theta rotation
roll = 90;

alpha = yaw; alpha = alpha*pi/180;
beta = pitch; beta = beta*pi/180;
gamma = roll; gamma = gamma*pi/180;

%Rotation Matrix
Rx = [1 0 0; 0 cos(alpha) -sin(alpha); 0 sin(alpha) cos(alpha)]; %rotate y-axis towards z-axis
Ry = [cos(beta) 0 sin(beta);  0 1 0; -sin(beta) 0 cos(beta)]; %rotate z-axis towards x axis
Rz = [cos(gamma) -sin(gamma) 0; sin(gamma) cos(gamma) 0; 0 0 1]; %rotate x-axis towards y-axis
Rm = Rx*Ry*Rz; %Arbitrary rotation

for i = 1:length(x)
    R = Rm*[x(i,:);y(i,:);z(i,:)]; %Rotation
    Xm(i,:) = R(1,:);
    Ym(i,:) = R(2,:);
    Zm(i,:) = R(3,:);
end

%plot rotated
figure('Name','Rotated Retinotopy 3D'), surf(Xm,Ym,Zm)
xlabel('x'),ylabel('y'),zlabel('z')
axis equal

%transform back to spherical
[RTHETA,RPHI,RR] = cart2sph(Xm,Ym,Zm);
%minRPHI = min(min(RPHI));
%RPHI = RPHI-minRPHI;
%minRTHETA = min(min(RTHETA));
%RTHETA = RTHETA-minRTHETA;

figure('Name','Rotated Retinotopy - THETA'), imagesc(RTHETA), colorbar, colormap(hsv)
figure('Name','Rotated Retinotopy - PHI'), imagesc(RPHI), colorbar, colormap(hsv)

%% Sereno analysis

%% Arrow diagram
X = RPHI.*cos(RTHETA);
Y = RPHI.*sin(RTHETA);
figure('Name','Arrow Diagram'), quiver(flipud(X),flipud(Y))

%% Area Map

[VTHETAx,VTHETAy] = gradient(RTHETA);
[VPHIx,VPHIy] = gradient(RPHI);
%figure('Name','Theta Gradient'), quiver(VTHETAx,VTHETAy,30)
%figure('Name','Phi Gradient'), quiver(VPHIx,VPHIy,30)

figure('Name','Theta and Phi Gradients')
quiver(flipud(VTHETAx),flipud(VTHETAy),30)
hold on
quiver(flipud(VPHIx),flipud(VPHIy),30)
legend('V\theta','Vr')
hold off

%calculate lambda
%figure
for i = 1:dim1
    for j = 1:dim2
        %compass(VPHIx(i,j),VPHIy(i,j))
        [PHIangle PHImag(i,j)] = cart2pol(VPHIx(i,j),VPHIy(i,j));
        if PHIangle < 0
            PHIangle = PHIangle+2*pi;
        end
        %hold on
        %compass(VTHETAx(i,j),VTHETAy(i,j),'g')
        [THETAangle THETAmag(i,j)] = cart2pol(VTHETAx(i,j),VTHETAy(i,j));
        if THETAangle <0
            THETAangle = THETAangle+2*pi;
        end
        %legend('Vr','V\theta')
        %hold off
        dif = (PHIangle+(2*pi-THETAangle));
        if dif > 2*pi
            dif = dif-2*pi;
        elseif dif < 0
            dif = dif+2*pi;
        end
        lambda(i,j) = dif;
        PHIangles(i,j) = PHIangle;
        THETAangles(i,j) = THETAangle;
        %PHIangle= PHIangle*180/pi;
        %THETAangle = THETAangle*180/pi;
    end
end

figure('Name','Lambda'), imagesc(lambda), colorbar, colormap(hsv)

figure('Name','Lambda'),quiver(flipud(cos(lambda)),flipud(sin(lambda)))

[mirror] = find(lambda > 0 & lambda < pi);
[nonmirror] = find(lambda < 2*pi & lambda > pi);
[undefined] = find(lambda == 0 | lambda == pi);

AreaMap = THETA*0;
AreaMap(mirror) = 1;
AreaMap(nonmirror) = 2;
AreaMap(undefined) = 3;
figure('Name','Area Diagram'), imagesc((AreaMap)), colormap(gray)
 
%Draw Borders
BW = edge(AreaMap,'canny',.3,5);
figure('Name','Border Estimate'), imagesc(BW), colormap(gray)
[border] = find(BW == 1);
BorderTHETA = RTHETA;
BorderPHI = RPHI;
BorderAreaMap = AreaMap;
BorderTHETA(border) = 1;
BorderPHI(border) = -1;
BorderAreaMap(border) = 0;
figure('Name', 'Rotated Theta with Estimated Area Borders'), imagesc(BorderTHETA), colormap(hsv), colorbar;
figure('Name', 'Rotated Phi with Estimated Area Borders'), imagesc(BorderPHI), colormap(hsv), colorbar;
figure('Name', 'AreaMap with Estimated Area Borders'), imagesc(BorderAreaMap), colormap(gray);


