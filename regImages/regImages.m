function varargout = regImages(varargin)
% REGIMAGES M-file for regImages.fig
%      REGIMAGES, by itself, creates a new REGIMAGES or raises the existing
%      singleton*.
%
%      H = REGIMAGES returns the handle to a new REGIMAGES or the handle to
%      the existing singleton*.
%
%      REGIMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGIMAGES.M with the given input arguments.
%
%      REGIMAGES('Property','Value',...) creates a new REGIMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before regImages_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to regImages_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help regImages

% Last Modified by GUIDE v2.5 26-Oct-2010 10:43:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @regImages_OpeningFcn, ...
                   'gui_OutputFcn',  @regImages_OutputFcn, ...
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


% --- Executes just before regImages is made visible.
function regImages_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to regImages (see VARARGIN)

% Choose default command line output for regImages
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes regImages wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = regImages_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function saveImgpath_Callback(hObject, eventdata, handles)
global saveImgPath
% hObject    handle to saveImgpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveImgpath as text
%        str2double(get(hObject,'String')) returns contents of saveImgpath as a double

saveImgPath = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function saveImgpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveImgpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in LoadImagesButton.
function LoadImagesButton_Callback(hObject, eventdata, handles)
global ref_out ref_in img_in
% hObject    handle to LoadImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[BaseFile,BasePathName,BaseFilterIndex] = uigetfile({'*.tif'; '*.mat'},'Select Base Image (i.e., tfori cell image)');
[InputFile,InputPathName,InputFilterIndex] = uigetfile({'*.tif';'*.mat'},'Select Image to Register with Base (i.e., kalret cell image)');
[Im2trxFile,Im2trxPathName,Im2trxFilterIndex] = uigetfile({'*.tif';'*.mat'},'Select Image to Perform the Transformation on (i.e., map variable file)');

BaseFilename = strcat(BasePathName,BaseFile);
InputFilename = strcat(InputPathName,InputFile);
Im2trxFilename = strcat(Im2trxPathName,Im2trxFile);

if BaseFilterIndex == 2
    A = whos('-file',BaseFilname);
    ref_out = load(BaseFilename,A.name);
    ref_out = struct2cell(ref_out);
    ref_out = cell2mat(ref_out);
elseif BaseFilterIndex == 1
    ref_out = imread(BaseFilename,1);
    ref_out = double(ref_out);
else
    error('You must select data type in the load dialog')
end

if InputFilterIndex == 2
    B = whos('-file',InputFilname);
    ref_in = load(InputFilename,B.name);
    ref_in = struct2cell(ref_in);
    ref_in = cell2mat(ref_in);
elseif InputFilterIndex == 1
    ref_in = imread(InputFilename,1);
    ref_in = double(ref_in);
else
   error('You must select data type in the load dialog')
end
    
if Im2trxFilterIndex == 2
    C = whos('-file',Im2trxFilename);
    img_in = load(Im2trxFilename,C.name);
    img_in = struct2cell(img_in);
    img_in = cell2mat(img_in);
elseif Im2trxFilterIndex == 1
    img_in = imread(Im2trxFilename,1);
    img_in = double(img_in);
else
    error('You must select data type in the load dialog')
end


% --- Executes on button press in SelectRefPoints.
function SelectRefPoints_Callback(hObject, eventdata, handles)
global ref_out ref_in
% hObject    handle to SelectRefPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear base_points input_points');
cpselect(double(ref_in)/max(ref_out(:)),double(ref_out)/max(ref_out(:)))


% --- Executes on button press in TransformButton.
function TransformButton_Callback(hObject, eventdata, handles)
global ref_out ref_in img_in img_out saveImgPath imgtrx
% hObject    handle to TransformButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','global base_points input_points')
global base_points input_points
[img_out, LT, ref_out_hat] = imgtrxrun(ref_in,ref_out,img_in,input_points,base_points);
%evalin('base','global img_out')
imgtrx = struct('img_out',img_out,'ref_out_hat',ref_out_hat,'trx',LT,'ref_in',ref_in,'ref_out',ref_out,'img_in',img_in,'input_points',input_points,'base_points',base_points)
save(saveImgPath,'imgtrx');



