function varargout = COMPI_Reward_GUI(varargin)
% COMPI_REWARD_GUI MATLAB code for COMPI_Reward_GUI.fig
%      COMPI_REWARD_GUI, by itself, creates a new COMPI_REWARD_GUI or raises the existing
%      singleton*.
%
%      H = COMPI_REWARD_GUI returns the handle to a new COMPI_REWARD_GUI or the handle to
%      the existing singleton*.
%
%      COMPI_REWARD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPI_REWARD_GUI.M with the given input arguments.
%
%      COMPI_REWARD_GUI('Property','Value',...) creates a new COMPI_REWARD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before COMPI_Reward_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to COMPI_Reward_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help COMPI_Reward_GUI

% Last Modified by GUIDE v2.5 18-Oct-2017 19:25:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @COMPI_Reward_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @COMPI_Reward_GUI_OutputFcn, ...
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


% --- Executes just before COMPI_Reward_GUI is made visible.
function COMPI_Reward_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to COMPI_Reward_GUI (see VARARGIN)

% Choose default command line output for COMPI_Reward_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes COMPI_Reward_GUI wait for user response (see UIRESUME)
if isempty(varargin) 
uiwait(handles.figure1);
else
    reward = varargin{1}
    set(handles.edit2, 'String', sprintf('CHF %s', num2str(reward(4))));
    set(handles.editSRLReward, 'String', sprintf('CHF %s', num2str(reward(1))));
    set(handles.editWMReward, 'String', sprintf('CHF %s', num2str(reward(2))));
    set(handles.editMMNReward, 'String', sprintf('CHF %s', num2str(reward(3))));
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
% --- Outputs from this function are returned to the command line.


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume


function varargout = COMPI_Reward_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.edit1, 'String');




function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMMNReward_Callback(hObject, eventdata, handles)
% hObject    handle to editMMNReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMMNReward as text
%        str2double(get(hObject,'String')) returns contents of editMMNReward as a double


% --- Executes during object creation, after setting all properties.
function editMMNReward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMMNReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWMReward_Callback(hObject, eventdata, handles)
% hObject    handle to editWMReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWMReward as text
%        str2double(get(hObject,'String')) returns contents of editWMReward as a double


% --- Executes during object creation, after setting all properties.
function editWMReward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWMReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSRLReward_Callback(hObject, eventdata, handles)
% hObject    handle to editSRLReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSRLReward as text
%        str2double(get(hObject,'String')) returns contents of editSRLReward as a double


% --- Executes during object creation, after setting all properties.
function editSRLReward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSRLReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
