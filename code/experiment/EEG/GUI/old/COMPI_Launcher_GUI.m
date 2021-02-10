function varargout = COMPI_Launcher_GUI(varargin)
% COMPI_LAUNCHER_GUI MATLAB code for COMPI_Launcher_GUI.fig
%      COMPI_LAUNCHER_GUI, by itself, creates a new COMPI_LAUNCHER_GUI or raises the existing
%      singleton*.
%
%      H = COMPI_LAUNCHER_GUI returns the handle to a new COMPI_LAUNCHER_GUI or the handle to
%      the existing singleton*.
%
%      COMPI_LAUNCHER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPI_LAUNCHER_GUI.M with the given input arguments.
%
%      COMPI_LAUNCHER_GUI('Property','Value',...) creates a new COMPI_LAUNCHER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before COMPI_Launcher_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to COMPI_Launcher_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help COMPI_Launcher_GUI

% Last Modified by GUIDE v2.5 18-Oct-2017 19:26:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @COMPI_Launcher_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @COMPI_Launcher_GUI_OutputFcn, ...
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


% --- Executes just before COMPI_Launcher_GUI is made visible.
function COMPI_Launcher_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to COMPI_Launcher_GUI (see VARARGIN)

% Choose default command line output for COMPI_Launcher_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes COMPI_Launcher_GUI wait for user response (see UIRESUME)
 uiwait(handles.figure1);

 
function EnterSubjectField_Callback(hObject, eventdata, handles)
% hObject    handle to EnterSubjectField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EnterSubjectField as text
%        str2double(get(hObject,'String')) returns contents of EnterSubjectField as a double


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function EnterSubjectField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnterSubjectField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in TaskPanel.
function TaskPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in TaskPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected object is changed in SessionPanel.
function SessionPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in SessionPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on selection change in PopUpSettings.
function PopUpSettings_Callback(hObject, eventdata, handles)
% hObject    handle to PopUpSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopUpSettings contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopUpSettings


% --- Executes during object creation, after setting all properties.
function PopUpSettings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopUpSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'Default Settings', 'No Memory', 'Memory'})


        


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(handles.checkbox1, 'Value')
    case 0
        set(handles.text2, 'String', 'Please Start the EEG recording...')
    case 1
        uiresume
end
    

% --- Outputs from this function are returned to the command line.
function varargout = COMPI_Launcher_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
UserInput = struct;

UserInput.Subject = get(handles.EnterSubjectField, 'String');
UserInput.Task = get(get(handles.TaskPanel, 'SelectedObject'), 'String');
UserInput.Session = get(get(handles.SessionPanel, 'SelectedObject'), 'String');
setItems = get(handles.PopUpSettings, 'String');
setSelected = get(handles.PopUpSettings, 'Value');
UserInput.Settings = setItems{setSelected};

varargout{1} = UserInput;

close(handles.figure1);
