function varargout = processF0(varargin)
% PROCESSF0 M-file for processF0.fig
%      PROCESSF0, by itself, creates a new PROCESSF0 or raises the existing
%      singleton*.
%
%      H = PROCESSF0 returns the handle to a new PROCESSF0 or the handle to
%      the existing singleton*.
%
%      PROCESSF0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSF0.M with the given input arguments.
%
%      PROCESSF0('Property','Value',...) creates a new PROCESSF0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before processF0_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to processF0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help processF0

% Last Modified by GUIDE v2.5 14-Jul-2009 10:48:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @processF0_OpeningFcn, ...
                   'gui_OutputFcn',  @processF0_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before processF0 is made visible.
function processF0_OpeningFcn(hObject, eventdata, handles, varargin)
global anadir datadir Analyzer f0m bw

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to processF0 (see VARARGIN)

% Choose default command line output for processF0
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes processF0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

clear f0m1 f0m2 funcmap1 funcmap2 bcond bsflag bwCell1 bwCell2

% --- Outputs from this function are returned to the command line.
function varargout = processF0_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in process.
function process_Callback(hObject, eventdata, handles)
global f0m1 f0m2 f0m1_var f0m2_var Tens1 Tens2 Tens1_var Tens2_var Analyzer bsflag Flim

bsflag = 0;

t0 = cputime;

varflag = get(handles.trialVarianceFlag,'Value');
bsflag = get(handles.basesub,'Value');
Tlim = str2double(get(handles.epistart,'String'));  %Frame start (to average)
Tlim(2) = str2double(get(handles.epistop,'String')); %Frame stop (to average)
b = str2double(get(handles.bstart,'String')); %in frames as well
b(2) = str2double(get(handles.bstop,'String'));

lumFlag = get(handles.lumFlag,'Value');  %normalize luminance of each frame

[skippedsyncflag skippedframeflag] = checkSyncs;
if skippedframeflag
    msgbox('There appear to be skipped frames from display','','warn');
end
if skippedsyncflag
    msgbox('There appear to be skipped syncs from display','','warn');
end
[f0m1 f0m2 f0m1_var f0m2_var] = condF0(Tlim,b,lumFlag,varflag);  %%Compute entire space time block for each condition

%[f0m1 f0m2] = CondF0(Tens1,Tens2,Flim);   %%%Compute mean over frame interval [Flim(1) Flim(2)]%%%  
%[f0m1_var f0m2_var] = CondF0(Tens1_var,Tens2_var,Flim);

sound(.6*sin(2*pi*400/(1200)*(0:400)),1200)  %Signal done

t1 = cputime-t0;

set(handles.time,'string',num2str(t1))

UE = get(handles.loadexp,'string');
AUE = strcat(Analyzer.M.anim,'_',UE);
set(handles.loaded,'string',AUE)

set(handles.plot,'enable','on')

set(handles.save,'enable','on')


% --- Executes on selection change in func.
function func_Callback(hObject, eventdata, handles)
% hObject    handle to func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns func contents as cell array
%        contents{get(hObject,'Value')} returns selected item from func


% --- Executes during object creation, after setting all properties.
function func_CreateFcn(hObject, eventdata, handles)
% hObject    handle to func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
global f0m1 f0m2 bw pepANA
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat', 'Pick a .mat file');

if filename ~= 0
    S = load(strcat(pathname,filename));  %Returns the contents in the .mat under the structure S
    
    if isfield(S,'f1m')
        warndlg('This is processed data from an F1 experiment.  Try again.','!!!') 
    else
    f0m1 = S.f0cell{1};    %f0m1 is a cell array with images from each condition
    f0m2 = S.f0cell{2};

    set(handles.plot,'enable','on')
    
    set(handles.loaded,'string',filename(1:length(filename)-4))
    
    end
end

function setimagedir_Callback(hObject, eventdata, handles)
% hObject    handle to setimagedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setimagedir as text
%        str2double(get(hObject,'String')) returns contents of setimagedir as a double


function loadexp_Callback(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadexp as text
%        str2double(get(hObject,'String')) returns contents of loadexp as a double


% --- Executes during object creation, after setting all properties.
function loadexp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setdirs.
function setdirs_Callback(hObject, eventdata, handles)
% hObject    handle to setdirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Analyzer

anim = get(handles.loadana,'String');

dir = get(handles.analyzedir,'String'); %partial path for analyzer file
setAnalyzerDirectory([dir anim '\'])

expt = get(handles.loadexp,'String');
loadAnalyzer(expt)

dir = get(handles.datadir,'String'); %partial path for .mat files 
setISIDataDirectory([dir anim '\' expt '\']); %append with animal and expt

fno = str2double(get(handles.frameno,'String'));    %Get frame number
tno = str2double(get(handles.trialno,'String'));    %Get trial number

Im = getTrialFrame(fno,tno-1);

axes(handles.rimage);     %Make rimage current figure
cla
imagesc(Im), colormap gray        
set(handles.rimage,'xtick',[],'ytick',[])

conds = length(Analyzer.loops.conds);
reps = length(Analyzer.loops.conds{1}.repeats);
set(handles.nocond,'string',num2str(conds))
set(handles.norep,'string',num2str(reps))
set(handles.dirstatus,'string','Loaded')

set(handles.setROI,'enable','on')
set(handles.process,'enable','on')

set(handles.predelay,'string',['predelay=' num2str(getparam('predelay'))])
set(handles.postdelay,'string',['postdelay=' num2str(getparam('postdelay'))])
set(handles.trialtime,'string',['trialtime=' num2str(getparam('stim_time'))])


function datadir_Callback(hObject, eventdata, handles)
% hObject    handle to datadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datadir as text
%        str2double(get(hObject,'String')) returns contents of datadir as a double


% --- Executes during object creation, after setting all properties.
function datadir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epistart_Callback(hObject, eventdata, handles)
% hObject    handle to epistart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epistart as text
%        str2double(get(hObject,'String')) returns contents of epistart as a double


% --- Executes during object creation, after setting all properties.
function epistart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epistart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epistop_Callback(hObject, eventdata, handles)
% hObject    handle to epistop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epistop as text
%        str2double(get(hObject,'String')) returns contents of epistop as a double


% --- Executes during object creation, after setting all properties.
function epistop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epistop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tau_Callback(hObject, eventdata, handles)
% hObject    handle to tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tau as text
%        str2double(get(hObject,'String')) returns contents of tau as a double


% --- Executes during object creation, after setting all properties.
function tau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HPBW_Callback(hObject, eventdata, handles)
% hObject    handle to HPBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HPBW as text
%        str2double(get(hObject,'String')) returns contents of HPBW as a double


% --- Executes during object creation, after setting all properties.
function HPBW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LPBW_Callback(hObject, eventdata, handles)
% hObject    handle to LPBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LPBW as text
%        str2double(get(hObject,'String')) returns contents of LPBW as a double


% --- Executes during object creation, after setting all properties.
function LPBW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LPBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bstart_Callback(hObject, eventdata, handles)
% hObject    handle to bstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bstart as text
%        str2double(get(hObject,'String')) returns contents of bstart as a double


% --- Executes during object creation, after setting all properties.
function bstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bstop_Callback(hObject, eventdata, handles)
% hObject    handle to bstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bstop as text
%        str2double(get(hObject,'String')) returns contents of bstop as a double


% --- Executes during object creation, after setting all properties.
function bstop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in basesub.
function basesub_Callback(hObject, eventdata, handles)
% hObject    handle to basesub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of basesub

% --- Executes on button press in tempfilt.
function tempfilt_Callback(hObject, eventdata, handles)
% hObject    handle to tempfilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tempfilt


function Hwidth_Callback(hObject, eventdata, handles)
% hObject    handle to Hwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Hwidth as text
%        str2double(get(hObject,'String')) returns contents of Hwidth as a double


% --- Executes during object creation, after setting all properties.
function Hwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Hwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in HPWind.
function HPWind_Callback(hObject, eventdata, handles)
% hObject    handle to HPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns HPWind contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HPWind


% --- Executes during object creation, after setting all properties.
function HPWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Lwidth_Callback(hObject, eventdata, handles)
% hObject    handle to Lwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lwidth as text
%        str2double(get(hObject,'String')) returns contents of Lwidth as a double


% --- Executes during object creation, after setting all properties.
function Lwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LPWind.
function LPWind_Callback(hObject, eventdata, handles)
% hObject    handle to LPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns LPWind contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LPWind


% --- Executes during object creation, after setting all properties.
function LPWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LPWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HPflag.
function HPflag_Callback(hObject, eventdata, handles)
% hObject    handle to HPflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HPflag


% --- Executes on button press in LPflag.
function LPflag_Callback(hObject, eventdata, handles)
% hObject    handle to LPflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LPflag


% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)
global bw f0m1
% hObject    handle to setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fno = str2double(get(handles.frameno,'String'));    %Get frame number
tno = str2double(get(handles.trialno,'String'));    %Get frame number

Im = getTrialFrame(fno,tno-1);

figure,imagesc(Im), colormap gray        

bw = roipoly;
close

if ~isempty(f0m1)
    set(handles.plot,'enable','on')
end


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
global bw f0m1 f0m2 funcmap1 funcmap2 bcond ang Analyzer
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dim = size(f0m1{1});
if isempty(bw) | length(bw(:,1)) ~= dim(1) | length(bw(1,:)) ~= dim(2)
    bw = ones(dim);
end

checkvect = [get(handles.F0im,'value') get(handles.funcim,'value') get(handles.retcont,'value') get(handles.retcov,'value')];

togstateHP = get(handles.HPflag,'Value');
togstateLP = get(handles.LPflag,'Value');
if checkvect*[0 1 1 1]' >= 1

    sizeIM = length(f0m1{1}(:,1));
    if togstateHP == 1
        Hwidth = str2double(get(handles.Hwidth,'string'));
        ind = get(handles.HPWind,'value');

        switch ind
            case 1
                H = -fspecial('gaussian',sizeIM,Hwidth);
                H(round(sizeIM/2),round(sizeIM/2)) = 1+H(round(sizeIM/2),round(sizeIM/2));
            case 2
                H = hann(Hwidth)*hann(Hwidth)';
                H = -H./sum(H(:));
                H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
                Hsize = length(H(1,:));
                margin = (sizeIM-Hsize)/2;
                H = [zeros(floor(margin),sizeIM); [zeros(Hsize,floor(margin)) H zeros(Hsize,ceil(margin))]; zeros(ceil(margin),sizeIM)];
            case 3                
                H = -fspecial('disk',round(Hwidth/2));
                Hsize = length(H(1,:));  %~=Hwidth
                H(round(Hsize/2),round(Hsize/2)) = 1+H(round(Hsize/2),round(Hsize/2));
                margin = (sizeIM-Hsize)/2;
                H = [zeros(floor(margin),sizeIM); [zeros(Hsize,floor(margin)) H zeros(Hsize,ceil(margin))]; zeros(ceil(margin),sizeIM)];
                
        end
        if togstateLP == 0
            hh = ifft2(abs(fft2(H)));   %Eliminate phase information
        end
    end
    
    if togstateLP == 1
        Lwidth = str2double(get(handles.Lwidth,'string'));
        ind = get(handles.LPWind,'value');

        switch ind
            case 1                
                L = fspecial('gaussian',sizeIM,Lwidth);
            case 2
                L = hann(Lwidth)*hann(Lwidth)';
                L = L./sum(L(:));
                Lsize = length(L(1,:));
                margin = (sizeIM-Lsize)/2;
                L = [zeros(floor(margin),sizeIM); [zeros(Lsize,floor(margin)) L zeros(Lsize,ceil(margin))]; zeros(ceil(margin),sizeIM)];
            case 3
                L = fspecial('disk',round(Lwidth/2));
                Lsize = length(L(1,:));
                margin = (sizeIM-Lsize)/2;
                L = [zeros(floor(margin),sizeIM); [zeros(Lsize,floor(margin)) L zeros(Lsize,ceil(margin))]; zeros(ceil(margin),sizeIM)];
        end
        if togstateHP == 0
            hh = ifft2(abs(fft2(L)));   %Eliminate phase information
        else
            hh = ifft2(abs(fft2(L).*fft2(H)));   %Take mag because phase gives a slight shift.
        end
    end
end

if ~or(togstateLP,togstateHP)
    hh = [];
end

%%...Done making filter

%%Filter raw F0 images with hh and create the functional maps...
funcflag = get(handles.func,'value');

if checkvect(2) == 1        %if "Functional Images" is checked
    if funcflag == 1        %functionality is orientation
        funcmap1 = GprocessOri(f0m1,hh);  %Channel 1
        funcmap2 = GprocessOri(f0m2,hh);
    end

    if funcflag == 2        %functionality is direction
        funcmap1 = GprocessDir(f0m1,hh);  %Channel 1
        funcmap2 = GprocessDir(f0m2,hh);
    end
    
    if funcflag == 3        %functionality is ocular dominance
        funcmap1 = GprocessOcdom(f0m1,bw,hh);
        funcmap2 = GprocessOcdom(f0m2,bw,hh);
    end

    if funcflag == 4        %%functionality is retinotopy
        [angx1 magx1 angy1 magy1] = Gprocessret(f0m1,bw,hh);
        [angx2 magx2 angy2 magy2] = Gprocessret(f0m2,bw,hh);
    end
    
    if funcflag == 5        %%functionality is spat freq
        [funcmap1 sfmag1] = GprocessSF(f0m1,bw,hh);
        [funcmap2 sfmag2] = GprocessSF(f0m2,bw,hh);
    end
    
    if funcflag == 6        %%functionality is color
        [funcmap1 colorSel1] = GprocessColor(f0m1,hh);
        [funcmap2 colorSel2] = GprocessColor(f0m2,hh);
    end
    
    if funcflag == 7        %%functionality is color & form
        [funcmap1 colorSel1] = GprocessColorForm(f0m1,hh);
        [funcmap2 colorSel2] = GprocessColorForm(f0m2,hh);
    end
end

%Create plots
if funcflag == 1    %"orientation"
    if checkvect(1) == 1
        plotF0(f0m1,bw,hh)
        %plotF0(f0m2,bw,hh)
    end
    if checkvect(2) == 1  %functional maps
        if get(handles.splitExp,'value')
            ang = angle(funcmap1);
            mag = abs(funcmap1);
            ang = (ang+pi*(1-sign(ang)))/2*180/pi;  %Put in orientation domain and convert to degrees.
            figure
            subplot(1,2,1)
            %Gplotorimap(mag.*bw,ang), title('Orientation (odd trials)','FontWeight','bold','FontSize',15);
            Gplotorimap(bw,ang), title('Orientation (odd trials)','FontWeight','bold','FontSize',15);

            ang = angle(funcmap2);
            mag = abs(funcmap2);
            ang = (ang+pi*(1-sign(ang)))/2*180/pi;  %Put in orientation domain and convert to degrees.
            subplot(1,2,2)
            %Gplotorimap(mag.*bw,ang),  title('Orientation (even trials)','FontWeight','bold','FontSize',15);
            Gplotorimap(bw,ang),  title('Orientation (even trials)','FontWeight','bold','FontSize',15);
            
            orimapSplit(funcmap1,funcmap2,bw)

        else
            funcmap = funcmap1+funcmap2;          
            ang = angle(funcmap);
            mag = abs(funcmap);
            ang = (ang+pi*(1-sign(ang)))/2*180/pi;  %Put in orientation domain and convert to degrees.
            figure
            %Gplotorimap(mag.*bw,ang), title('Orientation','FontWeight','bold','FontSize',15);
            Gplotorimap(bw,ang), title('Orientation','FontWeight','bold','FontSize',15);
        end
            
    end
end
if funcflag == 2    %"direction"
    if checkvect(1) == 1
        plotF0(f0m1,bw,hh)
        %plotF0(f0m2,bw,hh)
    end
    if checkvect(2) == 1  %functional maps
        if get(handles.splitExp,'value')
            ang = angle(funcmap1)*180/pi;
            mag = abs(funcmap1);
            figure
            subplot(1,2,1)
            %Gplotorimap(mag.*bw,ang), title('Orientation (odd trials)','FontWeight','bold','FontSize',15);
            Gplotdirmap(bw,ang), title('Direction (odd trials)','FontWeight','bold','FontSize',15);

            ang = angle(funcmap2);
            mag = abs(funcmap2);
            ang = (ang+pi*(1-sign(ang)))/2*180/pi;  %Put in orientation domain and convert to degrees.
            subplot(1,2,2)
            %Gplotorimap(mag.*bw,ang),  title('Orientation (even trials)','FontWeight','bold','FontSize',15);
            Gplotdirmap(bw,ang),  title('Direction (even trials)','FontWeight','bold','FontSize',15);
            
            orimapSplit(funcmap1,funcmap2,bw)

        else
            funcmap = funcmap1+funcmap2;          
            ang = angle(funcmap)*180/pi;
            mag = abs(funcmap);
            figure
            %Gplotorimap(mag.*bw,ang), title('Orientation','FontWeight','bold','FontSize',15);
            Gplotdirmap(bw,ang), title('Direction','FontWeight','bold','FontSize',15);
        end
            
    end
end
if funcflag == 3   %Ocular Dominance
    if checkvect(1) == 1
        c = [1 2 3];            
        c(bcond+1) = [];
        figure
        subplot(2,2,1)
        imagesc(f0m1{c(1)})
        title(['Condition ' num2str(c(1)-1) '  CH 1'])
        subplot(2,2,3)
        imagesc(f0m2{c(1)})
        title(['Condition ' num2str(c(1)-1) '  CH 2'])
        
        subplot(2,2,2)
        imagesc(f0m1{c(2)})
        title(['Condition ' num2str(c(2)-1) '  CH 1'])
        subplot(2,2,4)
        imagesc(f0m2{c(2)})
        title(['Condition ' num2str(c(2)-1) '  CH 2'])
        colormap gray
        truesize
    end
    if checkvect(2) == 1
        figure
        subplot(1,2,1)
        imagesc(funcmap1),colorbar
        subplot(1,2,2)
        imagesc(funcmap2),colorbar
        title('Ocular Dominance','FontWeight','bold','FontSize',15)
        colormap gray
        truesize
        
    end
end

if funcflag == 4    %Retinotopy
    if checkvect(1) == 1
        N = length(f0m1);
        k = 1;
        figure
        for i = 1:N
            if i ~= bcond+1
                subplot(2,N-length(bcond),k)
                imagesc(f0m1{i})
                title(['Condition ' num2str(k-1) '  CH 1'])
                
                subplot(2,N-length(bcond),k+N-length(bcond))
                imagesc(f0m2{i})
                title(['Condition ' num2str(k-1) '  CH 2'])
                k = k+1;
            end
        end
        colormap gray
    end
    if checkvect(2) == 1  %functional maps
        
        global pepANA
        screenDist = pepANA.config.display.viewingDistance;
        screenResX = pepANA.config.display.pixelspercm;
        screenResY = pepANA.config.display.pixelspercm;
        %screenResY = (1022-380)/24;  %For unknown reason, screen res is different in y direction
        
        [xpos ypos xsize ysize] = getPosSize;
        xsize_cm = (max(xpos)-min(xpos)+min(xsize))/screenResX;  %cm stimulus width
        xsize_deg = 2*atan2(xsize_cm/2,screenDist)*180/pi;  %convert to deg
        ysize_cm = (max(ypos)-min(ypos)+min(ysize))/screenResY;  %cm stimulus width
        ysize_deg = 2*atan2(ysize_cm/2,screenDist)*180/pi;  %convert to deg
        
        figure('Name','RETINOTOPIC MAPS','NumberTitle','off')
        subplot(2,2,1), imagesc(angx1,'AlphaData',magx1.*bw,[0 xsize_deg]); colorbar, set(gca,'XtickLabel',[],'YtickLabel',[],'XTick',[],'YTick',[]), ylabel('x position'), title('chan1','FontWeight','bold')     
        subplot(2,2,2), imagesc(angx2,'AlphaData',magx2.*bw,[0 xsize_deg]); colorbar, set(gca,'XtickLabel',[],'YtickLabel',[],'XTick',[],'YTick',[]), title('chan2','FontWeight','bold') 
        subplot(2,2,3), imagesc(angy1,'AlphaData',magy1.*bw,[0 ysize_deg]); colorbar, set(gca,'XtickLabel',[],'YtickLabel',[],'XTick',[],'YTick',[]), ylabel('y position'),
        subplot(2,2,4), imagesc(angy2,'AlphaData',magy2.*bw,[0 ysize_deg]); colorbar, set(gca,'XtickLabel',[],'YtickLabel',[],'XTick',[],'YTick',[])
        plotpixel_cb
        
        figure('Name','SCREEN COVERAGE','NumberTitle','off')
        subplot(1,2,1)
        Gplotretcoverage(angx1,magx1,angy1,magy1), title('chan1','FontWeight','bold')
        subplot(1,2,2)
        Gplotretcoverage(angx2,magx2,angy2,magy2), title('chan2','FontWeight','bold')
    end
end

if funcflag == 5    %"spatial frequency"
    if checkvect(1) == 1
        N = length(f0m1);
        k = 1;
        figure
        for i = 1:N 
            subplot(2,N-length(bcond),i)
            imagesc(f0m1{i})
            title(['Condition ' num2str(i-1) '  CH 1'])

            subplot(2,N-length(bcond),i+N-length(bcond))
            imagesc(f0m2{i})
            title(['Condition ' num2str(i-1) '  CH 2'])
        end
        colormap gray
    end
    if checkvect(2) == 1  %functional maps
        figure
        subplot(1,2,1)
        Gplotsfmap(sfmag1,funcmap1), title('Spatial Freq (CH1)','FontWeight','bold','FontSize',15);
        
        subplot(1,2,2)
        Gplotsfmap(sfmag2,funcmap2), title('Spatial Freq (CH2)','FontWeight','bold','FontSize',15);

    end
end

if funcflag == 6    %"color"
    if checkvect(1) == 1
        plotF0(f0m1,bw,hh)
        %plotF0(f0m2,bw,hh)
    end
    if checkvect(2) == 1  %functional maps
        ang = angle(funcmap1);
        mag = abs(funcmap1);
        ang = (ang+pi*(1-sign(ang)))/2*180/pi;  %Put in orientation domain and convert to degrees.
        figure
        subplot(1,2,1)
        Gplotcolormap(bw.*mag,ang), title('Color Axis (CH1)','FontWeight','bold','FontSize',15);
        
        ang = angle(funcmap2);
        mag = abs(funcmap2);
        ang = (ang+pi*(1-sign(ang)))/2*180/pi;  %Put in orientation domain and convert to degrees.
        subplot(1,2,2)
        Gplotcolormap(bw.*mag,ang),  title('Color Axis (CH2)','FontWeight','bold','FontSize',15);
        
        figure
        subplot(1,2,1)
        imagesc(colorSel1), colormap gray, colorbar
        colorbar('YTick',[-1 0 1],'YTickLabel',{'-1 Lum','0 Both','+1 Color'})
        title('Color to Lum Response (CH1)','FontWeight','bold','FontSize',12); 
        
        subplot(1,2,2)
        imagesc(colorSel2), colormap gray, colorbar
        colorbar('YTick',[-1 0 1],'YTickLabel',{'-1 Lum','0 Both','+1 Color'})
        title('Color to Lum Response (CH2)','FontWeight','bold','FontSize',12);
        
    end
end

% --- Executes on button press in F0im.
function F0im_Callback(hObject, eventdata, handles)
% hObject    handle to F0im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of F0im



% --- Executes on button press in funcim.
function funcim_Callback(hObject, eventdata, handles)
% hObject    handle to funcim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of funcim


% --- Executes on button press in retcov.
function retcov_Callback(hObject, eventdata, handles)
% hObject    handle to retcov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of retcov


% --- Executes on button press in retcont.
function retcont_Callback(hObject, eventdata, handles)
% hObject    handle to retcont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of retcont



function frameno_Callback(hObject, eventdata, handles)
% hObject    handle to frameno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameno as text
%        str2double(get(hObject,'String')) returns contents of frameno as a double

tno = str2double(get(handles.trialno,'String'));    %Get trial number
fno = str2double(get(handles.frameno,'String'));    %Get frame number

Im = getTrialFrame(fno,tno-1);

axes(handles.rimage);     %Make rimage current figure
cla
imagesc(Im), colormap gray     
set(handles.rimage,'xtick',[],'ytick',[])

% --- Executes during object creation, after setting all properties.
function frameno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
global pepANA f0m1 f0m2
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UE = get(handles.loadexp,'string');
path = 'c:\Processed Data\';
filename = strcat(path,pepANA.config.animal,'_',UE);
f0cell = cell(1,2);
f0cell{1} = f0m1;   %Channel 1
f0cell{2} = f0m2;   %Channel 2
uisave('f0cell',filename)


function trialno_Callback(hObject, eventdata, handles)
% hObject    handle to trialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialno as text
%        str2double(get(hObject,'String')) returns contents of trialno as a double

tno = str2double(get(handles.trialno,'String'));    %Get trial number
fno = str2double(get(handles.frameno,'String'));    %Get frame number

Im = getTrialFrame(fno,tno-1);

axes(handles.rimage);     %Make rimage current figure
cla
imagesc(Im), colormap gray     
set(handles.rimage,'xtick',[],'ytick',[])

% --- Executes during object creation, after setting all properties.
function trialno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function analyzedir_Callback(hObject, eventdata, handles)
% hObject    handle to analyzedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of analyzedir as text
%        str2double(get(hObject,'String')) returns contents of analyzedir as a double


% --- Executes during object creation, after setting all properties.
function analyzedir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analyzedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function loadana_Callback(hObject, eventdata, handles)
% hObject    handle to loadana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadana as text
%        str2double(get(hObject,'String')) returns contents of loadana as a double


% --- Executes during object creation, after setting all properties.
function loadana_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in lumFlag.
function lumFlag_Callback(hObject, eventdata, handles)
% hObject    handle to lumFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lumFlag


% --- Executes on button press in trialVarianceFlag.
function trialVarianceFlag_Callback(hObject, eventdata, handles)
% hObject    handle to trialVarianceFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trialVarianceFlag




% --- Executes on button press in splitExp.
function splitExp_Callback(hObject, eventdata, handles)
% hObject    handle to splitExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of splitExp


