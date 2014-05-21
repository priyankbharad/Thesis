function varargout = proto1(varargin)
% PROTO1 MATLAB code for proto1.fig
%      PROTO1, by itself, creates a new PROTO1 or raises the existing
%      singleton*.
%
%      H = PROTO1 returns the handle to a new PROTO1 or the handle to
%      the existing singleton*.
%
%      PROTO1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROTO1.M with the given input arguments.
%
%      PROTO1('Property','Value',...) creates a new PROTO1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before proto1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to proto1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help proto1

% Last Modified by GUIDE v2.5 20-May-2014 11:07:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @proto1_OpeningFcn, ...
                   'gui_OutputFcn',  @proto1_OutputFcn, ...
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


% --- Executes just before proto1 is made visible.
function proto1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to proto1 (see VARARGIN)
count=0;
javaaddpath c:\users\priyank\documents\arduinoIO\RUarduinoComm.jar;

o=com.rapplogic.CACMatlab.RU_ZNarduinoComm({'COM4' '9600'});
handles.xbeeObject=o;
handles.cnt=count;
set(hObject, 'DeleteFcn', @exitWindow)
% Choose default command line output for test1
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


function exitWindow(hObject,eventdata)
    handles = guidata(hObject);
    handles.xbeeObject.closeConnection; 
   
    
% UIWAIT makes proto1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = proto1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
%hObject    handle to pushbutton1 (see GCBO)
%eventdata  reserved - to be defined in a future version of MATLAB
%handles    structure with handles and user data (see GUIDATA)
handles.iButton=hObject;
guidata(hObject, handles);
set(gcf,'WindowButtonDownFcn',@ImageClickCallback);
guidata(hObject, handles);


function ImageClickCallback ( objectHandle , eventData )
%axesHandle  = get(objectHandle,'Parent');

handles = guidata(objectHandle);
set(handles.iButton,'Visible','off');
set(objectHandle,'Units','pixels');
coordinates = get(objectHandle,'CurrentPoint');
coordinates = coordinates(1,1:2);
width=80;
height=100;
count=handles.cnt;

s = strcat('Node',num2str(count));
pbh = uipanel('Parent',gcf,'Title',s,...
                'Tag',s,'Units','pixels','Position',[coordinates(1)-(width/2) coordinates(2)-(height/2) width height],'BackgroundColor',[1 0 0],'TitlePosition','centertop');
pbh1 = uicontrol(pbh,'Style','edit','String','1',...
                'Units','normalized',...
                'Position',[.05 .80 .9 .2]);
            setInitialHelp(pbh1,'ZoneID')
pbh2 = uicontrol(pbh,'Style','edit','String','3',...
                'Units','normalized',...
                'Position',[.05 .55 .9 .2]);
            setInitialHelp(pbh2,'Sub-ZoneID')
pbh3 = uicontrol(pbh,'Style','edit','String','1',...
                'Units','normalized',...
                'Position',[.05 .30 .9 .2]);
            setInitialHelp(pbh3,'SensorID')
pbh4 = uicontrol(pbh,'Style','pushbutton','String','Configure',...
                'Units','normalized',...
                'Position',[.05 .05 .9 .2],...
                'Callback',{@connect_callback,count});


if(count==0)
    xyz=[pbh;pbh1;pbh2;pbh3;pbh4;0;0;0];
    handles.nodes=xyz;
else
    xyz=handles.nodes;
    temp=[pbh;pbh1;pbh2;pbh3;pbh4;0;0;0];
    xyz=[xyz temp];
end
handles.nodes=xyz;
count=count+1;
handles.cnt=count;
 set(gcf,'WindowButtonDownFcn','');
guidata(objectHandle, handles);

function connect_callback ( hObject , eventData ,cnt)
   handles = guidata(hObject);
   tmp=handles.nodes(:,cnt+1);
 
   zone=get(tmp(2),'String');
   subzone=get(tmp(3),'String');
   sensor=get(tmp(4),'String');
   set(tmp(1),'Title',strcat(num2str(zone),'.',num2str(subzone),'.',num2str(sensor)));
   
   
   tmp(6)=str2double(zone);
   tmp(7)=str2double(subzone);
   tmp(8)=str2double(sensor);
    handles.nodes(:,cnt+1)=tmp;
    handles.nodes(:,cnt+1)
    
   
   s=handles.xbeeObject.sendData({'NodeDiscover'});
   
s(1,2)


   if(cnt==0)
       newMap = containers.Map();
       if(str2double(char(s(1,1)))==1)
           set(handles.iButton,'Visible','on');
           set(tmp(5),'Visible','off');
           set(tmp(2),'Visible','off');
           set(tmp(3),'Visible','off');
           set(tmp(4),'Visible','off');
           set(handles.Mon,'Visible','on');
           set(handles.popupmenu1,'Visible','on');
            set(handles.popupmenu2,'Visible','on');
             set(handles.text1,'Visible','on');
             set(gcf,'WindowButtonDownFcn',{@PanelCallbackDown,cnt});
               set(gcf,'WindowButtonUpFcn',{@PanelCallbackUp,cnt});
   
   a=get(tmp(1),'Position')
   set(tmp(1),'Position',[a(1)+(a(3)/2)-10 a(2)+(a(4)/2)-15 20 30]);  
           x=char(s(1,2));
            x=(x(1:end-1))
            tempOut=handles.xbeeObject.sendData({'AssignIdentifier',char(x),num2str(zone),num2str(subzone),num2str(sensor)})
            newMap(char(s(1,2)))=strcat(num2str(zone),'_',num2str(subzone),'_',num2str(sensor));
       end
   else
       newMap=handles.HashMap;
       
       for j=1:size(s,1)
           if(isKey(newMap,char(s(j,2)))~=1)
                if(str2double(char(s(j,1)))==1)
                    set(handles.iButton,'Visible','on');
                    set(tmp(5),'Visible','off');
                    set(tmp(2),'Visible','off');
                    set(tmp(3),'Visible','off');
                    set(tmp(4),'Visible','off');
                    
                    x=char(s(j,2));
                    x=(x(1:end-1));
                    handles.xbeeObject.sendData({'AssignIdentifier',char(x),num2str(zone),num2str(subzone),num2str(sensor)});
                    newMap(char(s(1,2)))=strcat(num2str(zone),'_',num2str(subzone),'_',num2str(sensor));
                end
                break;
           end
           
       
       end
       
   end

   
   % isKey(newMap,char(s(1,2)))
    handles.HashMap=newMap;
  
  guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function PanelCallbackDown ( hObject , eventData ,cnt)
handles = guidata(hObject);
tmp=handles.nodes(:,cnt+1);
a=get(tmp(1),'Position');
width=80;
height=100;
set(tmp(1),'Position',[a(1)+(a(3)/2)-(width/2) a(2)+(a(4)/2)-(height/2) width height]);  

function PanelCallbackUp ( hObject , eventData ,cnt)
handles = guidata(hObject);
tmp=handles.nodes(:,cnt+1);
 a=get(tmp(1),'Position');
width=20;
height=30;
set(tmp(1),'Position',[a(1)+(a(3)/2)-(width/2) a(2)+(a(4)/2)-(height/2) width height]);

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.axes1=hObject;
% Hint: place code in OpeningFcn to populate axes1
imshow('floorMap.png','Parent',hObject);
guidata(hObject, handles);


function pushbutton4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.Mon=hObject;
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopMon,'Visible','on');
for i=1:size(handles.nodes,2)
    tmp=handles.nodes(:,i);
    set(tmp(2),'Visible','off');
    set(tmp(3),'Visible','off');
    set(tmp(4),'Visible','off');
    
end
contents = get(handles.popupmenu1,'String');
popupmenu1value = contents{get(handles.popupmenu1,'Value')};
if strcmp(popupmenu1value,'0')
    grideyeFlag=true;
else
    grideyeFlag=false;
end 

%pinNumber=get(handles.pi,'String')
%l=num2str(pinNumber)
s=handles.xbeeObject.sendData({'Monitor',num2str(popupmenu1value)});
pause(1);
flag=true;initFlag=true;
 monitorMap = containers.Map();
   
while(flag==true)
   
  

    s=handles.xbeeObject.getReply({num2str(size(handles.nodes,2))});
    
 
    for i=1:size(s,1)
    an=handles.HashMap(char(s(i,2)));
        for j=1:size(handles.nodes,2)
            % (char(strcat(handles.nodes(6,j),'_',handles.nodes(7,j),'_',handles.nodes(8,j))))==char(an)
            if(strcmp(strcat(num2str(handles.nodes(6,j)),'_',num2str(handles.nodes(7,j)),'_',num2str(handles.nodes(8,j))),an))
                if(initFlag)
                      pbh1 = uicontrol(handles.nodes(1,j),'Style','text','String',char(s(i,1)),...
                      'Units','normalized',...
                      'Position',[.05 .50 .9 .5],'ForegroundColor',[1 1 1],'BackgroundColor',[1 0 0],'FontSize',20);
                      monitorMap(strcat(num2str(handles.nodes(6,j)),'_',num2str(handles.nodes(7,j)),'_',num2str(handles.nodes(8,j))))=[pbh1];
                     
                else
                     a=monitorMap(strcat(num2str(handles.nodes(6,j)),'_',num2str(handles.nodes(7,j)),'_',num2str(handles.nodes(8,j))));
                     b=num2cell(char(s(i,1)));
                     b=reshape(b,8,[]);
                     d=cell2num(b);
                     d=d-48
                     %imshow(d,'InitialMagnification','fit');
                     %drawnow
                     out=bwconncomp(d);
                     disp(out.NumObjects);


                     set(a(1),'String',out.NumObjects);
                end
                
              
          
          uistack(pbh1,'up',1);
            end
        
        end
    end
     initFlag=false;
    handles.MonitorTable=monitorMap;
    guidata(hObject, handles);
    userData = get(handles.stopMon, 'UserData');
   if userData.stop
       userData.stop = false;
       set(handles.stopMon, 'UserData',userData);
       flag=false;
       handles.xbeeObject.sendData({'NodeDiscover'});
       disp('Stop')
       set(handles.stopMon,'Visible','off');
   end
    pause(0.1);
end
guidata(hObject, handles);
%ans=handles.HashMap(char(s(2)));
%ans
%;s(2)
%handles.nodes(:,handles.cnt)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.stopMon.flag=false;
data = get(handles.stopMon, 'UserData');
data.stop = true;
set(handles.stopMon, 'UserData',data);

monitorMap=handles.MonitorTable;
for i=1:size(handles.nodes,2)
   
    a=monitorMap(strcat(num2str(handles.nodes(6,i)),'_',num2str(handles.nodes(7,i)),'_',num2str(handles.nodes(8,i))));
    set(a(1),'Visible','off');
   
    
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pushbutton6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.stopMon=hObject;
data = get(handles.stopMon, 'UserData');
data.stop=false;
set(handles.stopMon, 'UserData',data);


set(hObject,'Visible','off');
guidata(hObject, handles);






% --- Executes during object creation, after setting all properties.


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
handles.text1=hObject;
guidata(hObject, handles);
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(hObject,'String')
popupmenu1value = contents{get(hObject,'Value')}
if strcmp(popupmenu1value,'0')
    set(handles.popupmenu2,'Visible','on')
else
    set(handles.popupmenu2,'Visible','off')
end 
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%handles.monitorOptions=hObject;
guidata(hObject, handles);
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
