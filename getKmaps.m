function [kmap] = getKmaps(anim,expt,LP,HP)

%% INPUTS
% LP and HP are low pass and high pass values

%% Get Analyzer File
AnalyzerExpt = strcat('u',expt);
ExptID = strcat(anim,'_',AnalyzerExpt); 
Dir = 'C:/ISI Data/AnalyzerFiles/';
Anadir=[Dir anim,'/',ExptID '.analyzer'];
AnalyzerFileName = [ExptID '.analyzer'];
Anadir = fullfile(Dir,AnalyzerFileName); 
load(Anadir,'Analyzer','-mat')

%% Get Processed Data
pathname='C:/ISI Data/Processed/';
filename=strcat(anim,'_',expt,'.mat');
filepath=strcat(pathname,filename);
    S = load(filepath);  %Returns the contents in the .mat under the structure S
    f1m = S.f1m;    %f1m is a cell array with images from each condition
     
% one axes hack
if length(f1m) == 2 
    f1m{3} = f1m{2};
    f1m{4} = f1m{3};
    f1m{2} = f1m{1};
end

%% Get Blood Vessel Image
Dir = 'C:/ISI Data/RawData/';
GrabsDir = [Dir anim '/grabs/'];
D = dir([GrabsDir '*.mat']);
pic=D(001).name;
filename=strcat(GrabsDir, pic);
image=load(filename);
anatomypic_orig=image.grab.img;
 
%% Process data for various LP params
for iLP=1:length(LP)
    
    if LP(iLP)==0
        L=[];
        bw = ones(size(f1m{1}));
    else
        L = fspecial('gaussian',15,LP(iLP));  %make LP spatial filter
        bw = ones(size(f1m{1}));
    end
    if HP(iLP)==0
        H=[];
    else
        sizedum = 2.5*HP(iLP);
        H = -fspecial('gaussian',sizedum,HP(iLP));
        H(round(sizedum/2),round(sizedum/2)) = 1+H(round(sizedum/2),round(sizedum/2));
    end
    
    [kmap_hor kmap_vert delay_hor delay_ver magS] = Gprocesskret_batch(f1m,bw,L,H);

%% Save kmaps

SaveDir = ['C:/ISI Data/KMaps/',anim,'/'];
if exist(SaveDir,'dir') == 0;
    mkdir(SaveDir)
end
VertFileName = strcat(SaveDir,ExptID,'_LP',num2str(LP(iLP)),'_kmap_vert.mat');
HorFileName = strcat(SaveDir,ExptID,'_LP',num2str(LP(iLP)),'_kmap_hor.mat');

if strcmp('altitude',Analyzer.P.param{12}{3})==1
    save(VertFileName,'kmap_vert');
    kmap = kmap_vert;
elseif strcmp('azimuth',Analyzer.P.param{12}{3})==1
    save(HorFileName,'kmap_hor');
    kmap = kmap_hor;
end

end

    



