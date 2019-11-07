function varargout = processEpi(varargin)
% PROCESSEPI M-file for processEpi.fig
%      PROCESSEPI, by itself, creates a new PROCESSEPI or raises the existing
%      singleton*.
%
%      H = PROCESSEPI returns the handle to a new PROCESSEPI or the handle to
%      the existing singleton*.
%
%      PROCESSEPI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSEPI.M with the given input arguments.
%
%      PROCESSEPI('Property','Value',...) creates a new PROCESSEPI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before processEpi_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to processEpi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help processEpi

% Last Modified by GUIDE v2.5 19-Jul-2005 20:35:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @processEpi_OpeningFcn, ...
                   'gui_OutputFcn',  @processEpi_OutputFcn, ...
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


% --- Executes just before processEpi is made visible.
function processEpi_OpeningFcn(hObject, eventdata, handles, varargin)
global pepDATADIR pepIMAGEDIR pepLOADED f0m bw
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to processEpi (see VARARGIN)

% Choose default command line output for processEpi
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes processEpi wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if ~isempty(pepDATADIR)
    set(handles.setdatadir,'string',pepDATADIR)
end
if ~isempty(pepIMAGEDIR)
    set(handles.setimagedir,'string',pepIMAGEDIR)
end
if ~isempty(pepLOADED)
    set(handles.loadexp,'string',pepLOADED)
    set(handles.dirstatus,'string','Loaded')
    set(handles.nocond,'string',num2str(pepgetnoconditions))
    set(handles.norep,'string',num2str(pepgetnorepeats))
    
    set(handles.setROI,'enable','on')
    set(handles.process,'enable','on')
    
    axes(handles.rimage);     %Make rimage current figure
    cla
    fno = str2double(get(handles.frameno,'String'));    %Get frame number
    imagesc(peploadimage(fno)), colormap gray        %Load and plot frame
    set(handles.rimage,'xtick',[],'ytick',[])
end
if ~isempty(f0m) & ~isempty(bw)
    set(handles.processspace,'enable','on')
end
    

% --- Outputs from this function are returned to the command line.
function varargout = processEpi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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



function setimagedir_Callback(hObject, eventdata, handles)
% hObject    handle to setimagedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setimagedir as text
%        str2double(get(hObject,'String')) returns contents of setimagedir as a double


% --- Executes during object creation, after setting all properties.
function setimagedir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setimagedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function loadexp_man_Callback(hObject, eventdata, handles)
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


function frameno_Callback(hObject, eventdata, handles)
% hObject    handle to frameno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameno as text
%        str2double(get(hObject,'String')) returns contents of frameno as a double


axes(handles.rimage);     %Make rimage current figure
cla

fno = str2double(get(handles.frameno,'String'));    %Get frame number
imagesc(peploadimage(fno)), colormap gray        %Load and plot frame

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


% --- Executes on button press in setdirs.
function setdirs_Callback(hObject, eventdata, handles)
% hObject    handle to setdirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dir = get(handles.setdatadir,'String')
pepsetdatadirectory(dir)

dir = get(handles.setimagedir,'String')
pepsetimagedir(dir)

dir = get(handles.loadexp,'String')
pepload(dir,1,'dario')

axes(handles.rimage);     %Make rimage current figure
cla

fno = str2double(get(handles.frameno,'String'));    %Get frame number
imagesc(peploadimage(fno)), colormap gray        %Load and plot frame

set(handles.rimage,'xtick',[],'ytick',[])

% --- Executes on button press in loadexp.
function loadexp_Callback(hObject, eventdata, handles)
% hObject    handle to loadexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function setdatadir_Callback(hObject, eventdata, handles)
% hObject    handle to setdatadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setdatadir as text
%        str2double(get(hObject,'String')) returns contents of setdatadir as a double


% --- Executes during object creation, after setting all properties.
function setdatadir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setdatadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ROI.
function ROI_Callback(hObject, eventdata, handles)
global bw
% hObject    handle to ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fno = str2double(get(handles.frameno,'String'));    %Get frame number

figure,imagesc(peploadimage(fno)), colormap gray        

bw = roipoly;
close

% --- Executes on button press in process.
function process_Callback(hObject, eventdata, handles)
global pim spim
% hObject    handle to process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.status,'string','Running')

% togstate = get(handles.episodic,'Value');
% 
% if togstate == 0
%     pim = f1meanimage;      %Process the Kalatsky experiment
% elseif get(handles.basesub,'Value') == 1
%     Tlim = str2double(get(handles.epistart,'String'))
%     Tlim(2) = str2double(get(handles.epistop,'String'))
%     b = str2double(get(handles.bstart,'String'))
%     b(2) = str2double(get(handles.bstop,'String'))
%     pim = f0meanimage(Tlim,b);    
% elseif get(handles.tempfilt,'Value') == 1
%     delay = str2double(get(handles.tau,'String'))
%     TLP = str2double(get(handles.LPBW,'String'))
%     THP = str2double(get(handles.HPBW,'String'))
%     pim = episodestim(delay,TLP,THP);
% else
%     Tlim = str2double(get(handles.epistart,'String'))
%     Tlim(2) = str2double(get(handles.epistop,'String'))
%     pim = f0meanimage(Tlim);    
% end

spim = pim;     %Create 'spatially processed image"

set(handles.status,'string','Done')

axes(handles.tspimage);     %Make tspimage current figure
cla
imagesc(spim), colorbar

axes(handles.tpimage);     %Make tpimage current figure
cla
imagesc(pim), colorbar

cindex = get(handles.colormap,'value');
if cindex == 1
        colormap gray       
elseif cindex == 2
        colormap jet       
else
        colormap hsv       
end


% --- Executes on button press in basesub.
function basesub_Callback(hObject, eventdata, handles)
% hObject    handle to basesub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of basesub

togstate = get(hObject,'Value');

if togstate == 1
    set(handles.tempfilt,'value',0)
end


% --- Executes on button press in tempfilt.
function tempfilt_Callback(hObject, eventdata, handles)
% hObject    handle to tempfilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tempfilt

togstate = get(hObject,'Value');

if togstate == 1
    set(handles.basesub,'value',0)
end

% --- Executes on button press in episodic.
function episodic_Callback(hObject, eventdata, handles)
% hObject    handle to episodic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of episodic

togstate = get(hObject,'Value');

if togstate == 1
    set(handles.F1,'value',0)
end


% --- Executes on button press in F1.
function F1_Callback(hObject, eventdata, handles)
% hObject    handle to F1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of F1

togstate = get(hObject,'Value');

if togstate == 1
    set(handles.episodic,'value',0)
end



% --- Executes on selection change in colormap.
function colormap_Callback(hObject, eventdata, handles)
% hObject    handle to colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colormap


cindex = get(hObject,'value');
if cindex == 1
        colormap gray       
elseif cindex == 2 
        colormap jet       
else 
        colormap hsv       
end


% --- Executes during object creation, after setting all properties.
function colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)
global bw spim
% hObject    handle to setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

spim = spim.*bw;
Iroi = find(bw(:)~=0);
avg = mean(spim(Iroi));
Ibg = find(bw(:)==0);
spim(Ibg) = avg;

axes(handles.tspimage);     %Make tpimage current figure
cla
imagesc(spim), colorbar



% --- Executes on button press in savedata.
function savedata_Callback(hObject, eventdata, handles)
global spim pepANA

UE = get(handles.loadexp,'string');
AUE = strcat(UE,'_',pepANA.config.animal);
uisave('spim',AUE)


% --- Executes on button press in savefig.
function savefig_Callback(hObject, eventdata, handles)
global spim pepANA

UE = get(handles.loadexp,'string');
AUE = strcat(UE,'_',pepANA.config.animal);
uisave('spim',AUE)

% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
global pim spim
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

spim = pim;
axes(handles.tspimage);     %Make tpimage current figure
cla
imagesc(spim),colorbar

set(handles.statusspace,'string','')

% --- Executes on button press in LPflag.
function LPflag_Callback(hObject, eventdata, handles)

togstateL = get(hObject,'value');
togstateH = get(handles.HPflag,'value');

if (togstateL == 1) || (togstateH == 1)
    set(handles.processspace,'enable','on')
else
    set(handles.processspace,'enable','off')
end

% --- Executes on button press in HPflag.
function HPflag_Callback(hObject, eventdata, handles)

togstateH = get(hObject,'value');
togstateL = get(handles.LPflag,'value');

if (togstateL == 1) || (togstateH == 1)
    set(handles.processspace,'enable','on')
else
    set(handles.processspace,'enable','off')
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



function Lpixwidth_Callback(hObject, eventdata, handles)
% hObject    handle to Lpixwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lpixwidth as text
%        str2double(get(hObject,'String')) returns contents of Lpixwidth as a double


% --- Executes during object creation, after setting all properties.
function Lpixwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lpixwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Hpixwidth_Callback(hObject, eventdata, handles)
% hObject    handle to Hpixwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Hpixwidth as text
%        str2double(get(hObject,'String')) returns contents of Hpixwidth as a double


% --- Executes during object creation, after setting all properties.
function Hpixwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Hpixwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processspace.
function processspace_Callback(hObject, eventdata, handles)
global spim bw
% hObject    handle to processspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.statusspace,'string','Running')

togstateHP = get(handles.HPflag,'Value');
togstateLP = get(handles.LPflag,'Value');

if togstateHP == 1
    Hwidth = str2double(get(handles.Hpixwidth,'string'));
    ind = get(handles.HPWind,'value');
    
    switch ind
        case 1
            size = 3*Hwidth;
            H = -fspecial('gaussian',size,Hwidth);
            H(round(size/2),round(size/2)) = 1+H(round(size/2),round(size/2));
        case 2
            H = hann(Hwidth)*hann(Hwidth)';
            H = -H./sum(H(:));
            H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
        case 3
            H = -fspecial('disk',round(Hwidth/2));
            H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
    end
    if togstateLP == 0
        BPF = H;
    end
end

if togstateLP == 1
    Lwidth = str2double(get(handles.Lpixwidth,'string'));
    ind = get(handles.LPWind,'value');
    
    switch ind
        case 1
            size = 3*Lwidth;
            L = fspecial('gaussian',Lwidth,size);
        case 2
            L = hann(Lwidth)*hann(Lwidth)';
            L = L./sum(L(:));
        case 3
            L = fspecial('disk',round(Lwidth/2));
    end
    if togstateHP == 0
        BPF = L;
    else
        BPF = conv2(L,H);
    end
end

spim = filter2(BPF,spim);

set(handles.statusspace,'string','Done')

axes(handles.tspimage);     %Make tspimage current figure
cla
imagesc(spim), colorbar


%%%roifilt2%%%

% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in process.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


