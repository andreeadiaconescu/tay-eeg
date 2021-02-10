function varargout = DH_GUI_GUIDE(varargin)
% DH_GUI_GUIDE MATLAB code for DH_GUI_GUIDE.fig
%      DH_GUI_GUIDE, by itself, creates a new DH_GUI_GUIDE or raises the existing
%      singleton*.
%
%      H = DH_GUI_GUIDE returns the handle to a new DH_GUI_GUIDE or the handle to
%      the existing singleton*.
%
%      DH_GUI_GUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DH_GUI_GUIDE.M with the given input arguments.
%
%      DH_GUI_GUIDE('Property','Value',...) creates a new DH_GUI_GUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DH_GUI_GUIDE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DH_GUI_GUIDE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DH_GUI_GUIDE

% Last Modified by GUIDE v2.5 02-Aug-2018 09:10:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DH_GUI_GUIDE_OpeningFcn, ...
    'gui_OutputFcn',  @DH_GUI_GUIDE_OutputFcn, ...
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


% --- Executes just before DH_GUI_GUIDE is made visible.
function DH_GUI_GUIDE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DH_GUI_GUIDE (see VARARGIN)

% Hide panels that are not required
set(handles.bg_run,'visible','on')
set(handles.bg_keymode,'visible','on')
set(handles.bg_adviser,'visible','on')
set(handles.bg_WMMode,'visible','off')
set(handles.bg_handedness,'visible','off')
set(handles.check_recording,'visible','off')

% Create output variable and defaults
handles.ui = struct;
handles.ui.modality = 'Behavior';
handles.ui.task = 'IOIO';
handles.ui.session = 'practice';
handles.ui.run = 1;
handles.ui.key_mode = 1;
handles.ui.wm_task = 'Memory';
handles.ui.handedness = 'r';
handles.ui.adviser = 1;

% Choose default command line output for DH_GUI_GUIDE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DH_GUI_GUIDE wait for user response (see UIRESUME)
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = DH_GUI_GUIDE_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.ui;     %handles.output;
delete(handles.figure1);




function edit_subject_code_Callback(hObject, eventdata, handles)
% hObject    handle to edit_subject_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_subject_code as text
%        str2double(get(hObject,'String')) returns contents of edit_subject_code as a double




% --- Executes during object creation, after setting all properties.
function edit_subject_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_subject_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% -------------------------------
% RECORDING CHECK BOX CALLBACK
% -------------------------------

% --- Executes on button press in check_recording.
function check_recording_Callback(hObject, eventdata, handles)
% hObject    handle to check_recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_recording




% -------------------------------
% START BUTTON CALLBACK
% -------------------------------

% --- Executes on button press in pb_start.
function pb_start_Callback(hObject, eventdata, handles)
% hObject    handle to pb_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.subject_ID = get(handles.edit_subject_code,'String');

if strcmp(handles.ui.modality,'EEG') && (get(handles.check_recording,'Value')== 0)
    set(handles.text_feedback,'String','Please, start EEG recording...');
else
    set(handles.text_feedback,'String','Input complete. Close the figure to start...');
    guidata(hObject, handles);
    %DH_GUI_GUIDE_OutputFcn(hObject, eventdata, handles);
    %figure1_CloseRequestFcn(hObject, eventdata, handles);
end








% -------------------------------
% BUTTON GROUP CALLBACKS
% -------------------------------

% --- Executes when selected object is changed in bg_modality.
function bg_modality_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_modality
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



handles.ui.modality = get(get(handles.bg_modality,'SelectedObject'), 'Tag');
guidata(hObject, handles);

switch handles.ui.modality
    case 'Behavior'
        set(handles.check_recording,'visible','off')
        
    case 'EEG'
        set(handles.check_recording,'visible','on')
        
    case 'fMRI'
        set(handles.check_recording,'visible','off')
end





% --- Executes when selected object is changed in bg_task.
function bg_task_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_task
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.task  = get(get(handles.bg_task,'SelectedObject'), 'Tag');
guidata(hObject, handles);

switch handles.ui.task
    case 'IOIO'
        
        set(handles.bg_run,'visible','on')
        set(handles.bg_keymode,'visible','on')
        set(handles.bg_adviser,'visible','on')
        
        set(handles.bg_WMMode,'visible','off')
        set(handles.bg_handedness,'visible','off')
        
    case 'WM'
        
        set(handles.bg_WMMode,'visible','on')
        
        set(handles.bg_run,'visible','off')
        set(handles.bg_keymode,'visible','off')
        set(handles.bg_handedness,'visible','off')
         set(handles.bg_adviser,'visible','off')
        
    case 'MMN'
        set(handles.bg_handedness,'visible','on')
        
        set(handles.bg_WMMode,'visible','off')
        set(handles.bg_run,'visible','off')
        set(handles.bg_keymode,'visible','off')
         set(handles.bg_adviser,'visible','off')
        
    case 'Rest'
        
        set(handles.bg_WMMode,'visible','off')
        set(handles.bg_run,'visible','off')
        set(handles.bg_keymode,'visible','off')
        set(handles.bg_adviser,'visible','off')
end



% --- Executes when selected object is changed in bg_session.
function bg_session_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_session
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.session = get(get(handles.bg_session,'SelectedObject'), 'Tag');
guidata(hObject, handles);





% --- Executes when selected object is changed in bg_run.
function bg_run_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_run
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.run = str2num(get(get(handles.bg_run,'SelectedObject'),'String'));
guidata(hObject, handles);


% --- Executes when selected object is changed in bg_keymode.
function bg_keymode_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_keymode
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.key_mode = str2num(get(get(handles.bg_keymode,'SelectedObject'),'String'));
guidata(hObject, handles);



% --- Executes when selected object is changed in bg_WMMode.
function bg_WMMode_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_WMMode
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.wm_task = get(get(handles.bg_WMMode,'SelectedObject'), 'Tag');
guidata(hObject, handles);


% --- Executes when selected object is changed in bg_handedness.
function bg_handedness_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_handedness 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ui.handedness = get(get(handles.bg_handedness,'SelectedObject'), 'String');
guidata(hObject, handles);


% --- Executes when selected object is changed in bg_adviser.
function bg_adviser_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bg_adviser 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ui.adviser = str2num(get(get(handles.bg_adviser,'SelectedObject'), 'String'));
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end



