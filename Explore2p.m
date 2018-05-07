function h = GUI_2p(varargin)

%% Make figure
scrn = get(0,'Screensize');
hfig = figure('Position',[scrn(3)*0.2 scrn(4)*0.05 scrn(3)*0.5 scrn(4)*0.5],...% [50 100 1700 900]
    'Name','GUI_2p','KeyPressFcn',@KeyPressCallback,...
    'ToolBar', 'none'); % 'MenuBar', 'none'
hold off; axis off

%% init data

h = load('C:\Users\xiuye\Documents\2P_processed\890C\122117\3\F_890C_122117_plane1_proc_020118.mat');

% dat = [];
guidata(hfig,h);

%% Create UI controls
set(gcf,'DefaultUicontrolUnits','normalized');
set(gcf,'defaultUicontrolBackgroundColor',[1 1 1]);

% tab group setup
tgroup = uitabgroup('Parent', hfig, 'Position', [0.05,0.88,0.91,0.12]);
numtabs = 6;
tab = cell(1,numtabs);
M_names = {'General','Operations','Regression','Clustering etc.','Saved Clusters','Atlas'};
for i = 1:numtabs,
    tab{i} = uitab('Parent', tgroup, 'BackgroundColor', [1,1,1], 'Title', M_names{i});
end


% grid setup, to help align display elements
rheight = 0.5;
yrow = 0.5:-0.5:0;%0.97:-0.03:0.88;
dTextHt = 0.05; % dTextHt = manual adjustment for 'text' controls:
% (vertical alignment is top instead of center like for all other controls)
bwidth = 0.03;
grid = 0:bwidth+0.001:1;


%% tabs

i_tab = 1;

%% UI row 1: File
i_row = 1;
i = 1;n = 0;
i=i+n;

n=2; % Export
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Export',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_Export_Callback);

i=i+n;
n=2; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','load .mat',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_loadmat_Callback);

i=i+n;
n=2; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Draw im',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_drawIm_Callback);


end

%% Callback functions for UI elements:
function pushbutton_Export_Callback(hObject,~)
h = guidata(hObject);
assignin('base', 'h', h);
end

function pushbutton_loadmat_Callback(hObject,~)
disp('hi...');
root = 'C:\Users\xiuye\Documents\2P_processed\';

[filename1,filepath1]=uigetfile(fullfile(root, 'F*.mat'), 'Select Data File');

h = load(fullfile(filepath1, filename1));
guidata(hObject, h);
end

function pushbutton_drawIm_Callback(hObject,~)
hfig = getParentFigure(hObject);
h = guidata(hObject);

%% rank traces

T = struct2table(h.dat.stat);
M = zscore(h.dat.Fcell{1},0,2);
IsCell = table2array(T(:,28));
IX_ROI = find(IsCell);

i_start = 1;%2000;
i_stop = size(M,2);%3000;

% calculate skewness
sk = zeros(length(IX_ROI),1);
for i = 1:length(IX_ROI)
    ichosen = IX_ROI(i);
    F =  h.dat.Fcell{1}(ichosen, i_start:i_stop);
    Fneu = h.dat.FcellNeu{1}(ichosen, i_start:i_stop);
    
    
    % F(:, ops.badframes)  = F(:,    indNoNaN(ix));
    % Fneu(:, ops.badframes)  = Fneu(:, indNoNaN(ix));
    
    
    coefNeu = 0.7 * ones(1, size(F,1));
    
    dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
    
    % dF          = F - Fneu;
    
    sd           = std(dF, [], 2);
    sdN          = std(Fneu, [], 2);
    
    sk(i, 1) = skewness(dF, [], 2);
end

[~,IX_sort] = sort(sk,'ascend');
cIX = IX_ROI;%(IX_sort(11:30));

%% plot mean image with ROI's drawn on top.
% mean image
im1_0 = squeeze(h.dat.mimg(:,:,2));

% ROI image
Sat1     =  ones(h.dat.cl.Ly, h.dat.cl.Lx);
Sat2     =  ones(h.dat.cl.Ly, h.dat.cl.Lx);
H1              = zeros(h.dat.cl.Ly, h.dat.cl.Lx);
H2              = zeros(h.dat.cl.Ly, h.dat.cl.Lx);


% chose cells
for i = 1:length(h.dat.stat)
    h.dat.stat(i).iscell = (ismember(i,cIX));
end
%
[iclust1, iclust2, V1, V2] = ...
    getviclust(h.dat.stat, h.dat.cl.Ly,  h.dat.cl.Lx, h.dat.cl.vmap, h.dat.F.ichosen);

% iselect     = iclust1==h.dat.F.ichosen;
% Sat1(iselect)= 0;
%
% iselect     = iclust2==h.dat.F.ichosen;
% Sat2(iselect)= 0;

% given cIX;
nColors = length(cIX);
c = linspace(0.05,0.9,nColors);
cl = zeros(1,length(h.dat.stat));
cl(cIX) = c;
H1(iclust1>0)   = cl(iclust1(iclust1>0));
% H1(iclust1>0)   = h.dat.cl.rands(iclust1(iclust1>0));
% H2(iclust2>0)   = h.dat.cl.rands(iclust2(iclust2>0));

I = hsv2rgb(cat(3, H1, Sat1, V1));
im2 = min(I, 1);

inew = find(H1>0);
% combine and draw
im1_1 = mat2gray(im1_0);
im1 = repmat(im1_1,1,1,3);
Low_High  = [0,0.5];
im1 = imadjust(im1,Low_High);

im3 = (im1+im2)/2;
im3(inew) = im2(inew);
numpix = numel(H1);
im3(inew+numpix) = im2(inew+numpix);
im3(inew+2*numpix) = im2(inew+2*numpix);

% figure;
figure(hfig);

% clean-up canvas
allAxesInFigure = findall(hfig,'type','axes');
if ~isempty(allAxesInFigure)
    delete(allAxesInFigure);
end

h1 = axes('Position',[0.05, 0.04, 0.55, 0.83]);
h2 = axes('Position',[0.63, 0.04, 0.35, 0.83]);

% left subplot
axes(h2);

imagesc(im3);
% Low_High  = [0,0.5];
% im4 = imadjust(im3,Low_High);
% imshow(im4)
axis equal; axis off

for i = 1:length(cIX)
    ichosen = cIX(i);
    x0 = mean(h.dat.stat(ichosen).xpix);
    y0 = mean(h.dat.stat(ichosen).ypix);
    clr = squeeze(hsv2rgb(cl(ichosen),1,1));
    if x0>10
        text(x0-10,y0,num2str(i),'color','w','HorizontalAlignment','right');%clr);
    else
        text(x0+10,y0,num2str(i),'color','w','HorizontalAlignment','left');%clr);
    end
end

%% draw traces

% left subplot
axes(h1);hold on;
pad = 1;


Fs = 15.3;            % Sampling frequency
xv = (1:i_stop-i_start+1)/Fs;
for i = 1:length(cIX)
    ichosen = cIX(i);
    F = [];
    Fneu = [];
    for j = 1:numel(h.dat.Fcell)
        F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
        Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
    end
    
    y = double(F(i_start:i_stop));%my_conv_local(medfilt1(double(F), 3), 3);
    y_m = y-mean(y);
    y_n = y_m/max(y_m);%zscore(y);
    
    clr = squeeze(hsv2rgb(cl(ichosen),1,0.8));
    plot(xv,y_n - pad*(i-1),'color',clr);%[0.5,0.5,0.5])
    axis tight
    text(-1, 0.2- pad*(i-1),num2str(i),'HorizontalAlignment','right','color',[0.5,0.5,0.5]);
end

% draw scale bar
base_y = -pad*length(cIX);
plot([0,5],[base_y,base_y],'linewidth',2,'color','k');
text(2.5,base_y-0.6,'5 sec','HorizontalAlignment','center')
xlabel('sec')
ylim([base_y-1,2])
% set(gca,'xcolor','w');

axis off

%% save 
h.cIX = cIX;
guidata(hObject, h);
end


function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the figure. Otherwise return [].
while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
    fig = get(fig,'parent');
end
end