function varargout = wave_clus(varargin)
% WAVE_CLUS M-file for wave_clus.fig
%      WAVE_CLUS, by itself, creates a new WAVE_CLUS or raises the existing
%      singleton*.
%
%      H = WAVE_CLUS returns the handle to a new WAVE_CLUS or the handle to
%      the existing singleton*.
%
%      WAVE_CLUS('Property','Value',...) creates a new WAVE_CLUS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wave_clus_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WAVE_CLUS('CALLBACK') and WAVE_CLUS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WAVE_CLUS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wave_clus

% Last Modified by GUIDE v2.5 18-Feb-2007 12:52:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wave_clus_OpeningFcn, ...
                   'gui_OutputFcn',  @wave_clus_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before wave_clus is made visible.
function wave_clus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for wave_clus
handles.output = hObject;
data_types = get(handles.data_type_popupmenu, 'String');
handles.datatype = data_types{1};      % initial type being displayed.
set(handles.isi1_accept_button,'value',1);
set(handles.isi2_accept_button,'value',1);
set(handles.isi3_accept_button,'value',1);
%set(handles.spike_shapes_button,'value',1);
set(handles.force_button,'value',0);
set(handles.plot_all_button,'value',1);
set(handles.plot_average_button,'value',0);
set(handles.fix1_button,'value',0);
set(handles.fix2_button,'value',0);
set(handles.fix3_button,'value',0);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wave_clus wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wave_clus_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



clus_colors = [0 0 1; 1 0 0; 0 0.5 0; 0 0.75 0.75; 0.75 0 0.75; 0.75 0.75 0; 0.25 0.25 0.25];
set(0,'DefaultAxesColorOrder',clus_colors)



% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
wave_clus_reset_handles(handles);

filter_spec = get_filter_spec_by_datatype(handles.datatype);
[filename, pathname] = uigetfile(filter_spec, 'Select file');
if (filename == 0)        % if the user pressed `Cancel'
    return;
end
is_rejected = wave_clus_load(hObject, handles, filename, pathname);


% --- Executes on button press in change_temperature_button.
function change_temperature_button_Callback(hObject, eventdata, handles)
axes(handles.temperature_plot)
[temp aux]= ginput(1);                  %gets the mouse input
temp = round(temp);
if temp < 1; temp=1;end                 %temp should be within the limits
if temp > handles.par.num_temp; temp=handles.par.num_temp; end
min_clus = round(aux);
set(handles.min_clus_edit,'string',num2str(min_clus));

USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.min_clus = min_clus;
clu = USER_DATA{4};
classes = clu(temp,3:end)+1; 
tree = USER_DATA{5};
USER_DATA{1} = par;
USER_DATA{6} = classes(:)';
USER_DATA{8} = temp;
USER_DATA{9} = classes(:)';         % backup for non-forced classes.
set(handles.wave_clus_figure,'userdata',USER_DATA);

switch par.temp_plot
    case 'lin'
        plot([1 handles.par.num_temp],[par.min_clus par.min_clus],'k:',...
            1:par.num_temp,tree(1:par.num_temp,5:size(tree,2)),[temp temp],[1 tree(1,5)],'k:')
    case 'log'
        semilogy([1 handles.par.num_temp],[par.min_clus par.min_clus],'k:',...
            1:par.num_temp,tree(1:par.num_temp,5:size(tree,2)),[temp temp],[1 tree(1,5)],'k:')
end
xlim([0 par.num_temp + 0.5])
xlabel('Temperature'); ylabel('Clusters size');
% ARIEL: 02.11.2005:
set(gca, 'XMinorTick', 'on');

plot_spikes(handles);
set(handles.force_button,'value',0);
set(handles.force_button,'string','Force');
%set(handles.fix1_button,'value',0);
%set(handles.fix2_button,'value',0);
%set(handles.fix3_button,'value',0);


% --- Change min_clus_edit     
function min_clus_edit_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.min_clus = str2num(get(hObject, 'String'));
clu = USER_DATA{4};
temp = USER_DATA{8};
classes = clu(temp,3:end)+1;
tree = USER_DATA{5};
USER_DATA{1} = par;
USER_DATA{6} = classes(:)';
USER_DATA{9} = classes(:)';         % backup for non-forced classes.
set(handles.wave_clus_figure,'userdata',USER_DATA);

axes(handles.temperature_plot)
switch par.temp_plot
    case 'lin'
        plot([1 handles.par.num_temp],[par.min_clus par.min_clus],'k:',...
            1:par.num_temp,tree(1:par.num_temp,5:size(tree,2)),[temp temp],[1 tree(1,5)],'k:')
    case 'log'
        semilogy([1 handles.par.num_temp],[par.min_clus par.min_clus],'k:',...
            1:par.num_temp,tree(1:par.num_temp,5:size(tree,2)),[temp temp],[1 tree(1,5)],'k:')
end
xlim([0 par.num_temp + 0.5])
xlabel('Temperature'); ylabel('Clusters size');
plot_spikes(handles);
set(handles.force_button,'value',0);
set(handles.force_button,'string','Force');
%set(handles.fix1_button,'value',0);
%set(handles.fix2_button,'value',0);
%set(handles.fix3_button,'value',0);



% --- Executes on button press in save_clusters_button.
function save_clusters_button_Callback(hObject, eventdata, handles)
set(handles.status, 'String', 'Saving...');
drawnow;

USER_DATA = get(handles.wave_clus_figure,'userdata');
spikes = USER_DATA{2};
par = USER_DATA{1};
classes = USER_DATA{6};

% Classes should be consecutive numbers
i=1;
while i<=max(classes)
    if isempty(classes(find(classes==i)))
        greater_than_i = find(classes > i);
        if (~isempty(greater_than_i))
            classes(greater_than_i) = classes(greater_than_i) - 1;
        end
    else
        i=i+1;
    end
end

% Save clusters
cluster_class=zeros(size(spikes,1),2);
cluster_class(:,1) = classes(:);
cluster_class(:,2) = USER_DATA{3}';
if (par.filename(1) == 't')
    outfile = par.filename(1:end-4);
else
    outfile = ['times_' par.filename(1:end-4)];
end
comments = get_edit_comments(max(classes));

save_vars = {'cluster_class', 'par', 'spikes', 'comments'};
if ~isempty(USER_DATA{7})
    inspk = USER_DATA{7};
    save_vars = [save_vars, {'inspk'}];
end
if (length(USER_DATA) >= 31)
    time0   = USER_DATA{30};
    timeend = USER_DATA{31};
    save_vars = [save_vars, {'time0', 'timeend'}];
end
save(outfile, save_vars{:});

% ARIEL: revised picture saving.

if (get(handles.with_pic, 'value') == 0)
    % don't save a picture.
    set(handles.status, 'String', 'Ready');
    return;
end

% Save figures
h_figs = get(0,'children');
h_fig_list = cell(3, 1);
h_fig_list{1} = findobj(h_figs,'tag','wave_clus_figure');
h_fig_list{2} = findobj(h_figs,'tag','wave_clus_aux0');
h_fig_list{3} = findobj(h_figs,'tag','wave_clus_aux1');
tic;      % ARIEL:  03.11.2005.
if strcmp(outfile(7:9),'CSC')
    out_file_infix = ['ch', outfile(10:end)];
else
    out_file_infix = outfile(7:end);
end

for i=1:length(h_fig_list)
    if (~isempty(h_fig_list{i}))
        frm = getframe(h_fig_list{i});
        if (i == 1)
            infix2 = '';
        else
            infix2 = sprintf('%c', 95+i);     % ASCII for 'a', 'b', 'c', ...
        end
        imwrite(frm.cdata, sprintf('fig2print_%s%s.png', out_file_infix, ...
                    infix2), 'png');
    end
end
if (~isempty(h_fig_list{1}))
    figure(h_fig_list{1});     % return to main window upon completion.
end

set(handles.status, 'String', 'Ready');
drawnow;

% --- Executes on selection change in data_type_popupmenu.
function data_type_popupmenu_Callback(hObject, eventdata, handles)
aux = get(hObject, 'String');
aux1 = get(hObject, 'Value');
handles.datatype = aux(aux1);
guidata(hObject, handles);


% --- Executes on button press in set_parameters_button.
function set_parameters_button_Callback(hObject, eventdata, handles)
helpdlg('Check the set_parameters files in the subdirectory Wave_clus\Parameters_files');


%SETTING OF FORCE MEMBERSHIP
% --------------------------------------------------------------------
function force_button_Callback(hObject, eventdata, handles)
set(handles.status, 'String', 'Enforcing...');
drawnow;

%set(gcbo,'value',1);
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
spikes = USER_DATA{2};
classes = USER_DATA{6};
inspk = USER_DATA{7};

switch par.force_feature
    case 'spk'
        f_in  = spikes(find(classes~=0),:);
        f_out = spikes(find(classes==0),:);
    case 'wav'
        if isempty(inspk)
            [inspk] = wave_features_wc(spikes,handles);        % Extract spike features.
            USER_DATA{7} = inspk;
        end
        f_in  = inspk(find(classes~=0),:);
        f_out = inspk(find(classes==0),:);
end
class_in = classes(find(classes~=0));

if get(handles.force_button,'value') ==1
    class_out = force_membership_wc(f_in, class_in, f_out, handles.par);
    classes(find(classes==0)) = class_out;
    set(handles.force_button,'string','Forced');
elseif get(handles.force_button,'value') ==0
    classes = USER_DATA{9};
    set(handles.force_button,'string','Force');
end
par = unfix_all(handles, par);
USER_DATA{1} = par;
USER_DATA{6} = classes(:)';
set(handles.wave_clus_figure,'userdata',USER_DATA)

plot_spikes(handles);

%set(handles.fix1_button,'value',0);
%set(handles.fix2_button,'value',0);
%set(handles.fix3_button,'value',0);

drawnow;
set(handles.status, 'String', 'Ready');

% PLOT ALL PROJECTIONS BUTTON
% --------------------------------------------------------------------
function Plot_all_projections_button_Callback(hObject, eventdata, handles)
if (~strcmp(get(handles.file_name, 'string'), 'No file selected'))
    Plot_all_features(handles)
end
% --------------------------------------------------------------------


% fix1 button --------------------------------------------------------------------
function fix1_button_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
classes = USER_DATA{6};
fix_class = find(classes==1);
if get(handles.fix1_button,'value') ==1
    USER_DATA{10} = fix_class;
else
    USER_DATA{10} = [];
end
set(handles.wave_clus_figure,'userdata',USER_DATA)

% fix2 button --------------------------------------------------------------------
function fix2_button_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
classes = USER_DATA{6};
fix_class = find(classes==2);
if get(handles.fix2_button,'value') ==1
    USER_DATA{11} = fix_class;
else
    USER_DATA{11} = [];
end
set(handles.wave_clus_figure,'userdata',USER_DATA)

% fix3 button --------------------------------------------------------------------
function fix3_button_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
classes = USER_DATA{6};
fix_class = find(classes==3);
if get(handles.fix3_button,'value') ==1
    USER_DATA{12} = fix_class;
else
    USER_DATA{12} = [];
end
set(handles.wave_clus_figure,'userdata',USER_DATA)



%%%SETTING OF SPIKE FEATURES OR PROJECTIONS
%%% --------------------------------------------------------------------
%%function spike_shapes_button_Callback(hObject, eventdata, handles)
%%set(gcbo,'value',1);
%%set(handles.spike_features_button,'value',0);
%%plot_spikes(handles);
%%% --------------------------------------------------------------------
%%function spike_features_button_Callback(hObject, eventdata, handles)
%%set(gcbo,'value',1);
%%set(handles.spike_shapes_button,'value',0);
%%plot_spikes(handles);


%SETTING OF SPIKE PLOTS
% --------------------------------------------------------------------
function plot_all_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.plot_average_button,'value',0);
plot_spikes(handles);
% --------------------------------------------------------------------
function plot_average_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.plot_all_button,'value',0);
plot_spikes(handles);



%SETTING OF ISI HISTOGRAMS
% --------------------------------------------------------------------
function isi1_nbins_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.nbins1 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi1_bin_step_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.bin_step1 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi2_nbins_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.nbins2 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi2_bin_step_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.bin_step2 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi3_nbins_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.nbins3 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi3_bin_step_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.bin_step3 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi0_nbins_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.nbins0 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)
% --------------------------------------------------------------------
function isi0_bin_step_Callback(hObject, eventdata, handles)
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.bin_step0 = str2num(get(hObject, 'String'));
USER_DATA{1} = par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
plot_spikes(handles)



%SETTING OF ISI BUTTONS

% --------------------------------------------------------------------
function isi1_accept_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.isi1_reject_button,'value',0);

% --------------------------------------------------------------------
function isi1_reject_button_Callback(hObject, eventdata, handles)
set(handles.status, 'String', 'Rejecting Cluster #1...');
drawnow;
set(gcbo,'value',1);
set(handles.isi1_accept_button,'value',0);
USER_DATA = get(handles.wave_clus_figure,'userdata');
classes = USER_DATA{6};
classes(find(classes==1))=0;
USER_DATA{6} = classes;
USER_DATA{9} = classes;
USER_DATA = shift_fixed_buttons(1, handles, USER_DATA, classes);
set(handles.wave_clus_figure,'userdata',USER_DATA);

%shift_comments(1, max(classes));
plot_spikes(handles)

set(gcbo,'value',0);
set(handles.isi1_accept_button,'value',1);
drawnow;
set(handles.status, 'String', 'Ready');

% --------------------------------------------------------------------
function isi2_accept_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.isi2_reject_button,'value',0);

% --------------------------------------------------------------------
function isi2_reject_button_Callback(hObject, eventdata, handles)
set(handles.status, 'String', 'Rejecting Cluster #2...');
drawnow;
set(gcbo,'value',1);
set(handles.isi2_accept_button,'value',0);
USER_DATA = get(handles.wave_clus_figure,'userdata');
classes = USER_DATA{6};
classes(find(classes==2))=0;
USER_DATA{6} = classes;
USER_DATA{9} = classes;
USER_DATA = shift_fixed_buttons(2, handles, USER_DATA, classes);
set(handles.wave_clus_figure,'userdata',USER_DATA);

%shift_comments(2, max(classes));
plot_spikes(handles)

set(gcbo,'value',0);
set(handles.isi2_accept_button,'value',1);
drawnow;
set(handles.status, 'String', 'Ready');

% --------------------------------------------------------------------
function isi3_accept_button_Callback(hObject, eventdata, handles)
set(gcbo,'value',1);
set(handles.isi3_reject_button,'value',0);

% --------------------------------------------------------------------
function isi3_reject_button_Callback(hObject, eventdata, handles)
set(handles.status, 'String', 'Rejecting Cluster #3...');
drawnow;
set(gcbo,'value',1);
set(handles.isi3_accept_button,'value',0);
USER_DATA = get(handles.wave_clus_figure,'userdata');
classes = USER_DATA{6};
classes(find(classes==3))=0;
USER_DATA{6} = classes;
USER_DATA{9} = classes;
USER_DATA = shift_fixed_buttons(3, handles, USER_DATA, classes);
set(handles.wave_clus_figure,'userdata',USER_DATA);

%shift_comments(3, max(classes));
plot_spikes(handles)

set(gcbo,'value',0);
set(handles.isi3_accept_button,'value',1);
drawnow;
set(handles.status, 'String', 'Ready');


% --- Executes during object creation, after setting all properties.
function isi1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate isi1


% --- Executes during object creation, after setting all properties.
function isi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate isi2

% -------------------------------------------------------------------
% ARIEL: 02.11.2005:  Dummy functions:
function min_clus_edit_CreateFcn(hObject, eventdata, handles)

function isi3_nbins_CreateFcn(hObject, eventdata, handles)

function isi2_nbins_CreateFcn(hObject, eventdata, handles)

function isi1_nbins_CreateFcn(hObject, eventdata, handles)

function isi0_nbins_CreateFcn(hObject, eventdata, handles)

function isi0_bin_step_CreateFcn(hObject, eventdata, handles)

function isi1_bin_step_CreateFcn(hObject, eventdata, handles)

function isi2_bin_step_CreateFcn(hObject, eventdata, handles)

function isi3_bin_step_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in load_next.
function load_next_Callback(hObject, eventdata, handles)
% hObject    handle to load_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


is_rejected = true;
while (is_rejected)      % automatically skip all rejected channels.

    t = tic;
    switch (handles.datatype)
     case {'CSC data', 'CSC data (pre-clustered)'}
      ext = '.Ncs';
     case 'Neuroport data'
      ext = '.mat';
    end
    if (~isfield(handles, 'par'))
        % this is first load.
        fname = [pwd, filesep, 'CSC0', ext];
    else
        fname = [pwd, filesep, handles.par.filename];
    end
    if (~isempty(strfind(fname, 'Loading:')))
        % no file name to take next:
        fprintf('Unable to take next of current file name.\n');
        return;
    end
    if (~isempty(strfind(fname, 'No file selected')))
        pathname = pwd;
        name = 'CSC0';
    else
        if (verLessThan('matlab', '8.1'))
            [pathname, name, ext, versn] = fileparts(fname);
        else
            [pathname, name, ext] = fileparts(fname);
        end
    end
    
    % We use lower() because on non-unix, upper & lower may be mixed.
    if (~(strcmp(lower(ext), '.ncs') & strcmp(lower(name(1:3)), 'csc')) & ...
        ~strcmp(lower(ext), '.mat'))
        set(handles.status, 'String', 'Current file is not a CSC file.');
        drawnow;
        return;
    end

    if (name(1) == 't')    % times_CSC
        cur_file_no = str2num(name(10:end));
    else
        cur_file_no = str2num(name(4:end));
    end
    filename = sprintf('CSC%d%s', cur_file_no + 1 + ...
                get(handles.single_step, 'Value'), ext);   % 0=single inc.;
                                                           % 1=double inc.
    if (strcmp(handles.datatype, 'Neuroport data'))
        filename = ['times_', filename];
    end
    
    pathname = [pathname, filesep];
    if (~exist([pathname, filename], 'file'))
        set(handles.status, 'String', ...
            sprintf('Next file not found (%s).', [pathname, filename]));
        drawnow;
        return;
    end
    
    wave_clus_reset_handles(handles);
%    pack;

    is_rejected = wave_clus_load(hObject, handles, filename, pathname);

    if (is_rejected)
        % update filename for next iteration:
        handles = guidata(hObject);
    end

    fprintf('Total loading time: ');
    toc(t);

end

% --- Executes on button press in single_step.
function single_step_Callback(hObject, eventdata, handles)
% hObject    handle to single_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint:  returns toggle state of single_step

if (get(hObject,'Value') == 0)
    set(hObject, 'String', 'Single step');
else
    set(hObject, 'String', 'Double step');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit0_Callback(hObject, eventdata, handles)
% hObject    handle to edit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0 as text
%        str2double(get(hObject,'String')) returns contents of edit0 as a double


% --- Executes during object creation, after setting all properties.
function edit0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in merge_fixed.
function merge_fixed_Callback(hObject, eventdata, handles)
% hObject    handle to merge_fixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.status, 'String', 'Merging...');
drawnow;
USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
classes = USER_DATA{6};
comments = get_edit_comments(max(classes));

fixed_vec_bool = get_fixed_vec(par, handles);
cluster_ids = find(fixed_vec_bool);
if (isempty(cluster_ids))
    drawnow;
    set(handles.status, 'String', 'Ready');
    return;
end
[classes, comments] = merge_clusters(cluster_ids, classes, comments);
par = unfix_all(handles, par);

USER_DATA{1} = par;
USER_DATA{6} = classes;
clear_edit_objs;
set_edit_comments(comments);

set(handles.wave_clus_figure,'userdata',USER_DATA);

plot_spikes(handles);

drawnow;
set(handles.status, 'String', 'Ready');


% --- Executes on button press in fixed_y_range.
function fixed_y_range_Callback(hObject, eventdata, handles)
% hObject    handle to fixed_y_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixed_y_range


% update display upon check/uncheck:
plot_spikes(handles);


% --- Executes on button press in reload.
function reload_Callback(hObject, eventdata, handles)
% hObject    handle to reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


t = tic;
if (~isfield(handles, 'par'))
    % no file name to load:
    set(handles.status, 'String', sprintf('No current file to reload.'));
    return;
end    

fname = handles.par.filename;
path_name = [pwd, filesep];
if (~exist([path_name, fname], 'file'))
    set(handles.status, 'String', sprintf('Current file not found (%s).', ...
                fname));
    drawnow;
    return;
end

wave_clus_reset_handles(handles);
%pack;

is_rejected = wave_clus_load(hObject, handles, fname, path_name);

if (is_rejected)
    % update filename for next iteration:
    handles = guidata(hObject);
end

fprintf('Total loading time: ');
toc(t);
    
% --- Executes on button press in with_pic.
function with_pic_Callback(hObject, eventdata, handles)
% hObject    handle to with_pic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of with_pic


% --- Executes on button press in split_2nd_cluster_temp.
function split_2nd_cluster_temp_Callback(hObject, eventdata, handles)
% hObject    handle to split_2nd_cluster_temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


axes(handles.temperature_plot)
[temp aux]= ginput(1);                  %gets the mouse input
temp = round(temp);
if temp < 1; temp=1;end                 %temp should be within the limits
if temp > handles.par.num_temp; temp=handles.par.num_temp; end
min_clus = round(aux);
set(handles.min_clus_edit,'string',num2str(min_clus));

USER_DATA = get(handles.wave_clus_figure,'userdata');
par = USER_DATA{1};
par.min_clus = min_clus;
tree = USER_DATA{5};
clu = USER_DATA{4};

%classes = clu(temp,3:end)+1;
new_classes = zeros(1, size(clu, 2)-2);
cur_cluster = 2;
for i=temp:-1:1
    % tree(i, 6) refers to cluster #2 in the i-th temperature.
    if ((i == 1) | (i == temp) | ...
        ((tree(i, 6) > tree(i-1, 6)) & (tree(i, 6) >= tree(i+1, 6))))
%        fprintf('i = %d\n', i);
        fix_clusters = find(clu(i, 3:end)+1 == 2);
%        fprintf('    #fix_clusters = %d\n', length(fix_clusters));
        if (~isempty(fix_clusters))
            new_classes(fix_clusters) = cur_cluster;
            cur_cluster = cur_cluster + 1;
        end
    end
end

% update largest cluster:
first_cluster = find(clu(temp, 3:end)+1 == 1);
%fprintf('    #first_cluster = %d\n', length(first_cluster));
new_classes(first_cluster) = 1;
classes = new_classes;
USER_DATA{1} = par;

USER_DATA = fix_some(handles, USER_DATA, classes, 1:(cur_cluster-1), 1);
classes = zeros(size(classes));   % `classes' should store non-fixed clusters.
                                  % The fixed clusters are taken from
                                  % USER_DATA{9+i}.

tree = USER_DATA{5};
USER_DATA{6} = classes(:)';
USER_DATA{8} = temp;
USER_DATA{9} = classes(:)';         % backup for non-forced classes.
set(handles.wave_clus_figure,'userdata',USER_DATA);

switch par.temp_plot
    case 'lin'
        plot([1 handles.par.num_temp],[par.min_clus par.min_clus],'k:',...
            1:par.num_temp,tree(1:par.num_temp,5:size(tree,2)),[temp temp],[1 tree(1,5)],'k:')
    case 'log'
        semilogy([1 handles.par.num_temp],[par.min_clus par.min_clus],'k:',...
            1:par.num_temp,tree(1:par.num_temp,5:size(tree,2)),[temp temp],[1 tree(1,5)],'k:')
end
xlim([0 par.num_temp + 0.5])
xlabel('Temperature'); ylabel('Clusters size');
% ARIEL: 02.11.2005:
set(gca, 'XMinorTick', 'on');

plot_spikes(handles);
set(handles.force_button,'value',0);
set(handles.force_button,'string','Force');

%set(handles.fix1_button,'value',0);
%set(handles.fix2_button,'value',0);
%set(handles.fix3_button,'value',0);

drawnow;

% Run Force following a spilt_temp:
set(handles.force_button,'value',1);
%force_button_Callback(handles.force_button, [], handles);
wave_clus('force_button_Callback', handles.force_button, [], ...
          guidata(handles.force_button));
%force_clustering(handles);
