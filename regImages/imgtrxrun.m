function [img_out, LT, ref_out_hat] = imgtrxrun(ref_in,ref_out,img_in,input_points,base_points)

%%This code requires the use of something like 'cpselect' to acquire the
%%input and base points from the reference images.
%% Use imgtrx.m 

dim = size(ref_out);
%Compute transform
LT = cp2tform(input_points,base_points,'affine');

%Check mapping ([x y] ~ base_points  &  ref_out ~ ref_out_hat ?) 
[x,y] = tformfwd(LT,input_points(:,1),input_points(:,2));  
figure,plot([x;y],base_points(1:end)','.'),title('base points vs. trx points')

[ref_out_hat xdata ydata] = imtransform(ref_in,LT,'FillValues',NaN);  
Lxpad = round(abs(min(0,xdata(1)-1)));
Lypad = round(abs(min(0,ydata(1)-1)));
xwide = Lxpad +  round(max(dim(2),xdata(2)));
ywide = Lypad +  round(max(dim(1),ydata(2)));
%dum = zeros(ywide,xwide);
dum = NaN(ywide,xwide);
dimr = size(ref_out_hat);
x = round(max(1,xdata(1)));
y = round(max(1,ydata(1)));
dum(y:y+dimr(1)-1,x:x+dimr(2)-1) = ref_out_hat;
ref_out_hat = dum(Lypad+1:Lypad+dim(1),Lxpad+1:Lxpad+dim(2));

figure, imagesc(ref_out),title('Base Image')
figure, imagesc(ref_out_hat),title('Input Image After Trx')

%Trx input image
img_out = imtransform(img_in,LT,'FillValues',NaN);
%dum = zeros(ywide,xwide);
dum = NaN(ywide,xwide);
dum(y:y+dimr(1)-1,x:x+dimr(2)-1) = img_out;
img_out = dum(Lypad+1:Lypad+dim(1),Lxpad+1:Lxpad+dim(2));
figure, imagesc(img_out),title('Output Image')


% %Trx input reference --added by JHM 10-25-10
% refimg_out = imtransform(ref_in,LT);
% dum = zeros(ywide,xwide);
% dum(y:y+dimr(1)-1,x:x+dimr(2)-1) = img_out;
% refimg_out = dum(Lypad+1:Lypad+dim(1),Lxpad+1:Lxpad+dim(2));
% figure, imagesc(refimg_out),title('Transformed Input Reference')
