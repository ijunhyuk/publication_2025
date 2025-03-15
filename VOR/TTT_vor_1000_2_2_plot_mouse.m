function TTT_vor_1000_2_2_plot_mouse()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vor_trial_suffix = '_processed.mat';
vor_trial_suffix_poor = '_processed_PoorDLC.mat';
% is_partial_procedure = 0;
exp_map_excel = 'exp_map';

clr_OKR = [1 0.5 0]*255;
clr_VVOR = [0 0 1]*255;
clr_VOR = [0 0 0]*255;
deli = '_';

mouse_fo = {};

% data_fo = 'G:\Dropbox_joon\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
data_fo = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
% data_fo = 'D:\';


% group_fo = 'GC_TKO\GC_TKO_m961_m962'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'm961'];
% mouse_fo{end+1} = [group_fo filesep 'm962'];

% group_fo = 'GC_TKO\GC_TKO_m963_m964_m965'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'm963'];
% mouse_fo{end+1} = [group_fo filesep 'm964'];
% mouse_fo{end+1} = [group_fo filesep 'm965'];

% group_fo = 'GC_TKO\GC_TKO_m1001_m1004'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'm1001'];
% mouse_fo{end+1} = [group_fo filesep 'm1002'];
% mouse_fo{end+1} = [group_fo filesep 'm1004'];

% group_fo = 'OKR_learning_test'; is_partial_procedure = 1;
% mouse_fo{end+1} = [group_fo filesep 'm1002_GCTKO-CTR'];

% group_fo = 'a6_TKO\a6_TKO_batch1'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'm1014'];
% mouse_fo{end+1} = [group_fo filesep 'm1016'];
% mouse_fo{end+1} = [group_fo filesep 'm1018'];
% mouse_fo{end+1} = [group_fo filesep 'm1021'];

% group_fo = 'a6_TKO\a6_TKO_batch2'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'm1023'];
% mouse_fo{end+1} = [group_fo filesep 'm1024'];
% mouse_fo{end+1} = [group_fo filesep 'm1025'];
% mouse_fo{end+1} = [group_fo filesep 'm1026'];

% group_fo = 'PC_TKO\PC_TKO_batch1-2'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'm1051'];
% mouse_fo{end+1} = [group_fo filesep 'm1052'];
% mouse_fo{end+1} = [group_fo filesep 'm1053'];
% mouse_fo{end+1} = [group_fo filesep 'm1054'];
% mouse_fo{end+1} = [group_fo filesep 'm1055'];
% mouse_fo{end+1} = [group_fo filesep 'm1056'];
% mouse_fo{end+1} = [group_fo filesep 'm1057'];
% mouse_fo{end+1} = [group_fo filesep 'm1058'];

% group_fo = 'KPPFA\cohort1-3'; is_partial_procedure = 0;
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-1'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-2'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-3'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-5'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-7'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-8'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFA-9'];

% group_fo = 'KPPF\cohort4';
% mouse_fo{end+1} = [group_fo filesep 'KPPFH-11'];
% mouse_fo{end+1} = [group_fo filesep 'KPPFH-12'];
% mouse_fo{end+1} = [group_fo filesep 'WT-A'];
% mouse_fo{end+1} = [group_fo filesep 'WT-B'];

% group_fo = 'PC_TKO\PC_TKO_batch3';
% % mouse_fo{end+1} = [group_fo filesep 'm1111'];
% mouse_fo{end+1} = [group_fo filesep 'm1112'];

group_fo = 'PC_TKO\PC_TKO_batch1-2';
% mouse_fo{end+1} = [group_fo filesep 'm1111'];
mouse_fo{end+1} = [group_fo filesep 'm1051'];


% ncol_base = 1; %number of column for base info.
% ncol_performance = 2*9; %number of column for one set of motor performance(=3X3). X2 becaues each one has meta column.
% ncol_learning = 2*7; %number of column for one set of motor learning(=7 VORs). X2 becaues each one has meta column.

% %full procedure
% empty_column_pos = [ncol_base+ncol_performance+1 
%     ncol_base+ncol_performance+ncol_performance+1 
%     ncol_base+ncol_performance+ncol_performance+2 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*1+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*2+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*3+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*4+1 
% %     ncol_base+ncol_performance+ncol_performance+ncol_learning*5+1 
%     ];

% % %partial procedure
% if is_partial_procedure
% empty_column_pos = [
%     ncol_base+ncol_learning*1+1 
% %     ncol_base+ncol_learning*2+1 
% %     ncol_base+ncol_learning*3+1 
% %     ncol_base+ncol_learning*4+1 
%     ];

% empty_column_pos = [ncol_base+ncol_performance+1 
%     ncol_base+ncol_performance+ncol_performance+1 
%     ncol_base+ncol_performance+ncol_performance+2 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*1+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*2+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*3+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*4+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*4+3
%     ];
% empty_column_pos = [ncol_base+ncol_performance+1 
%     ncol_base+ncol_performance+ncol_performance+1 
%     ncol_base+ncol_performance+ncol_performance+2 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*1+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*2+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*3+1 
%     ncol_base+ncol_performance+ncol_performance+ncol_learning*4+1 
%     ];
% empty_column_pos = [
%     ncol_base+ncol_learning*1+1 
%     ];
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load vor_st
for m=1:length(mouse_fo)
    cccc;
target_fo = [data_fo filesep mouse_fo{m}];
[fo,mosue_id,ext] = fileparts(target_fo);
cur_mouse_id = mosue_id;
% filelist_mp4 = TTTH_search_all_files([target_fo], 1, 'mp4');
% filelist_mp4 = sortrows(filelist_mp4,1);

% filelist_st1 = TTTH_search_all_files([target_fo], 1, vor_trial_suffix);
% filelist_st2 = TTTH_search_all_files([target_fo], 1, vor_trial_suffix_poor);
% filelist_st = [filelist_st1;filelist_st2];
% filelist_st = sortrows(filelist_st,1);

tok = strsplit(mouse_fo{m},filesep);
map_path = [target_fo filesep exp_map_excel '_' tok{end} '.xlsx'];
tb = readtable(map_path);
filelist_st = {};

%find where to insert 'empty' column for plotting later.
empty_column_pos = [];
col_without_empty = 0;
for i=1:size(tb,1)
    if ~isempty(tb.mat_path{i})
        filelist_st{end+1,1} = [target_fo tb.mat_path{i}];
        col_without_empty = col_without_empty + 1;
    end
    if strcmp(tb.exp_type1{i},'empty')
        empty_column_pos(end+1) = col_without_empty+1;
    end    
end

median_gain = [];
vor_trial_store = {};
header = {'mouse_name','exp_date_str','exp_type','hz','gain_median','gain_values','phase_diff'};
header_len = length(header);
vor_cell = cell(1,header_len);

for i=1:length(filelist_st) %i=43
    cur_path = filelist_st{i};
    temp = load(cur_path);
    vor_trial = temp.vor_trial;
    token = strsplit(vor_trial.video_relative_path, filesep);
    mouse_name = token{end-3};
    trial_name = token{end-1};
    token2 = strsplit(trial_name, '_');
    %     hz_str = token2{3};
    exp_type = token2{end};
    c = 0;
    c=c+1; vor_cell{i,c} = mouse_name;
    c=c+1; vor_cell{i,c} = vor_trial.exp_date_str;
    c=c+1; vor_cell{i,c} = exp_type;
    c=c+1; vor_cell{i,c} = vor_trial.protocol_param.table_rotation_command.zigzag_freq;
    if ~contains(cur_path,vor_trial_suffix_poor) && isfield(vor_trial, 'gain_median')
        c=c+1; vor_cell{i,c} = vor_trial.gain_median;
        c=c+1; vor_cell{i,c} = vor_trial.peak_gain_xy(:,2);
        c=c+1; vor_cell{i,c} = vor_trial.phase_diff_max;        
    else
        c=c+1; vor_cell{i,c} = [];
        c=c+1; vor_cell{i,c} = [];
        c=c+1; vor_cell{i,c} = [];
    end
end
vor_tb = cell2table(vor_cell);
vor_tb.Properties.VariableNames = header;
%sort by date.-> No need. I did it in the beggining.
% sort_col = find(contains(header,'exp_date_str'));
% vor_tb = sortrows(vor_tb,sort_col,{'ascend'});

%% make excel data
x_label = {}; x_pos = 0; clr = {};
cell_data = {};
data_header = {};
for i=1:size(vor_tb,1)
    exp_type = vor_tb.exp_type{i};
    exp_date_str = vor_tb.exp_date_str{i};
    hz = vor_tb.hz(i);
    gain_values = vor_tb.gain_values{i};
    
    x_label{i} = [exp_type '_' num2str(hz)];
%     x_label{i} = [exp_date_str];
    if strcmp(exp_type,'OKR')
        clr{i} = clr_OKR;
    elseif strcmp(exp_type,'VVOR')
        clr{i} = clr_VVOR;
    elseif strcmp(exp_type,'VOR')
        clr{i} = clr_VOR;
    end
    cell_data(1:length(gain_values),i) = num2cell(gain_values);
    data_header{i} = [exp_type '_' num2str(hz)];
%     x_pos = x_pos + 1;
%     scatter(ones(length(gain_values),1)*x_pos,gain_values,10,'o','MarkerEdgeColor',clr,'LineWidth',1.5);
%     hold on;
%     plot(
    
end

data_meta_cell = [];
cell_color_map = clr;
sheet_name = ['VOR_Gain'];
save_excel_path = [target_fo filesep 'plot_' datestr(now,'yyyymmdd_HHMMSS') '.xlsx'];
% [excel_raw] = TTTH_make_excel_for_plotting(cell_data, data_meta_cell, data_header, cell_color_map, save_excel_path,sheet_name);


[excel_raw] = TTTH_make_excel_for_plotting_ver2(cell_data, data_meta_cell, data_header, cell_color_map, save_excel_path,sheet_name, empty_column_pos);

%% plot gains.: now moving to TTT_vor_1000_7_1_vor_plotting;
is_save_fig = 1;
is_save_svg = 1;
% save_excel_path = 'D:\Syt7_m861_m862_m864\m861\plot_20221205_184027.xlsx';
% save_excel_path = 'D:\Syt7_m861_m862_m864_2nd_Rp\m861\plot_20221205_193545.xlsx';

% save_excel_path = 'D:\Syt7_m861_m862_m864\m862\plot_20221206_144644.xlsx';
[~,~,excel_raw] = xlsread(save_excel_path,sheet_name);

y_label = 'Gain';
title_in = 'VOR_Gain';
start_x_coor = 1;
is_header_xlabel = 1;
figure('color',[1 1 1]); ax1 = gcf;
[fig] = TTTH_plot_box_from_cell_ver3(ax1, excel_raw, [], [], [],title_in, y_label, start_x_coor, is_header_xlabel);
title(cur_mouse_id);

% put horizontal line at y=0 and y=1
figure(fig);
x_lim = xlim;
plot(x_lim, [0 0], '--r');
plot(x_lim, [1 1], '--r');

% axis tight;
ylim([-0.2 1.5]);
fig.Position = [100 100 2600 1700];

[fo,mosue_id,ext] = fileparts(target_fo);
fig_save_path = [target_fo '\mouse_gain_plot_' mosue_id '.fig'];
img_save_path = [target_fo '\mouse_gain_plot_' mosue_id '.jpg'];
saveas(fig,fig_save_path);
saveas(fig,img_save_path);

%% plot phase: Need to revise.
fig1 = figure('color',[1 1 1],'position',[100 100 600 500]);
phase_diff = vor_tb.phase_diff;
if iscell(phase_diff)
    phase_diff = cell2mat(phase_diff);
end
idx = phase_diff<-60;
phase_diff(idx) = phase_diff(idx)+360;
xx = 1:length(phase_diff);
plot(xx,phase_diff,'-ok');
set(gca,'fontsize',7);
ylabel('Phase difference','fontsize',20);
xticks(xx);
set(gca,'TickLabelInterpreter','none');
xticklabels(x_label);
xtickangle(45);
box off;
ylim([-60 200]);

yyaxis right;
gain_median = vor_tb.gain_median;
if iscell(gain_median)
gain_median = cell2mat(gain_median);
end
plot(xx,gain_median,'-o');
ylabel('Gain','fontsize',20);
box off;
title(cur_mouse_id);

[fo,mosue_id,ext] = fileparts(target_fo);
fig_save_path = [target_fo '\mouse_phase_plot_' mosue_id '.fig'];
img_save_path = [target_fo '\mouse_phase_plot_' mosue_id '.jpg'];
saveas(fig1,fig_save_path);
saveas(fig1,img_save_path);

end
end