function TTT_vor_1000_2_1_analysis()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vor_trial_suffix = '_processed.mat';

% data_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
% data_fo = 'G:\Dropbox_joon\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
data_fo = 'D:\';

% group_fo = 'Control_test';
% group_fo = 'GC_TKO_m831_m834';
% group_fo = 'temp';
group_fo = 'Syt7_m861_m862_m864';

% mouse_fo = [group_fo filesep 'm792_test'];
% mouse_fo = [group_fo filesep 'm792_test'];
% mouse_fo = [group_fo filesep 'm831'];
% mouse_fo = [group_fo filesep 'm832'];
% mouse_fo = [group_fo filesep 'm833'];
% mouse_fo = [group_fo filesep 'm834'];
mouse_fo = [group_fo filesep 'm861'];

clr_OKR = [1 0.5 0]*255;
clr_VVOR = [0 0 1]*255;
clr_VOR = [0 0 0]*255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load vor_st
target_fo = [data_fo filesep mouse_fo];
filelist_st = TTTH_search_all_files([target_fo], 1, vor_trial_suffix);
filelist_st = sortrows(filelist_st,1);

median_gain = [];
vor_cell = {};
vor_trial_store = {};
header = {'mouse_name','exp_date_str','exp_type','hz','gain_median','gain_values','phase_diff'};
for i=1:length(filelist_st)
    cur_path = filelist_st{i};
    temp = load(cur_path);
    vor_trial = temp.vor_trial;
    token = strsplit(vor_trial.video_relative_path, filesep);
    mouse_name = token{2};
    trial_name = token{4};
    token2 = strsplit(trial_name, '_');
%     hz_str = token2{3};
    exp_type = token2{end};
    
    c = 0;
    c=c+1; vor_cell{i,c} = mouse_name;
    c=c+1; vor_cell{i,c} = vor_trial.exp_date_str;
    c=c+1; vor_cell{i,c} = exp_type;
    c=c+1; vor_cell{i,c} = vor_trial.protocol_param.table_rotation_command.zigzag_freq;
    c=c+1; vor_cell{i,c} = vor_trial.gain_median;
    c=c+1; vor_cell{i,c} = vor_trial.peak_gain_xy(:,2);  
    c=c+1; vor_cell{i,c} = vor_trial.phase_diff_max;
    
    vor_trial_store{i} = vor_trial;
end
vor_tb = cell2table(vor_cell);
vor_tb.Properties.VariableNames = header;
%sort by date.
sort_col = find(contains(header,'exp_date_str'));
vor_tb = sortrows(vor_tb,sort_col,{'ascend'});

%% plot gain
x_label = {}; x_pos = 0; clr = {};
cell_data = {};
data_header = {};
for i=1:size(vor_tb,1)
    exp_type = vor_tb.exp_type{i};
    exp_date_str = vor_tb.exp_date_str{i};
    hz = vor_tb.hz(i);
    gain_values = vor_tb.gain_values{i};
    
%     x_label{i} = [exp_type '_' num2str(hz)];
    x_label{i} = [exp_date_str];
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
save_excel_path = [target_fo filesep 'plot_' datestr(now,'yyyymmdd_HHMMSS') '.xlsx'];
sheet_name = ['VOR_Gain'];
[excel_raw] = TTTH_make_excel_for_plotting(cell_data, data_meta_cell, data_header, cell_color_map, save_excel_path,sheet_name);
y_label = 'Gain';

[fig] = TTTH_plot_box_from_cell(excel_raw, [], [], [],'', y_label);
axis tight;
ylim([-0.2 1.5]);
set(gca,'XTick',1:size(cell_data,2));
xticklabels(x_label);
xtickangle(45);

%% plot phase
fig1 = figure('color',[1 1 1],'position',[100 100 600 500]);
phase_diff = vor_tb.phase_diff;
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
plot(xx,vor_tb.gain_median,'-o');
ylabel('Gain','fontsize',20);
box off;


end