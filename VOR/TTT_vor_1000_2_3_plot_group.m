function TTT_vor_1000_2_3_plot_group()
%% Plot mice per group by meta_info excel file.
dropbox_fo = 'M:\Dropbox (HMS)';
meta_info_path = [dropbox_fo '\Research_RegehrLAB\analysis\Meta_info_20240606.xlsx'];

% system(['start excel "' meta_info_path '"']);
%%
% save_prefix = ''; y_lim = [-0.1 1.3]; %default
% save_prefix = 'GC_TKO'; y_lim = [-0.1 1.3]; %default
% save_prefix = 'AC_TKO'; y_lim = [-0.1 1.3]; %default
save_prefix = 'PC_TKO'; y_lim = [-0.1 1.5];
% save_prefix = 'KPPF_WT'; y_lim = [-0.1 1.3]; %default
% save_prefix = 'KPPF_TOX'; y_lim = [-0.1 1.3]; %default
% save_prefix = 'WT'; y_lim = [-0.1 1.3]; %default


search_fo = {};

search_fo{end+1} = [dropbox_fo '\BigData_HMS\VOR\VOR_data'];
save_fo = [dropbox_fo '\Research_RegehrLAB\Analysis\result_obj\plot_excel'];

fig_size = [100 100 2000 800];

thr_gain_nan_perc = 70; % default is 70%. If the gain values cannot be calculated in more than 70% moments(because of closing eye/poor detection/etc),
%the gain value will be set as NaN. For example, there is 60 calculation
%points in 0.5Hz VOR (60sec,maximum turning left/right). If the gain values cannot not be calculated more than 60*0.9 = 54 moments, The averaged gain will be set as
%NaN.

% thr_saccade_period = 100; % default is 5%. if too many saccades, set the gain as NaN. for example, if saccedes moments were more than (saccade_period_perc) during 61 sec recording.
% % 20231207. set to 100%. No need to change.

clr_OKR = round([1 0.5 0]*255);
clr_VVOR = round([0 0 1]*255);
clr_VOR = round([0 0 0]*255);

date_str = datestr(now,'yyyymmdd_HHMMSS');
fig_save_path = [save_fo '\' date_str '_group_error_bar_' save_prefix '.fig'];
img_save_path = [save_fo '\' date_str '_group_error_bar_' save_prefix '.jpg'];
excel_save_path = [save_fo '\' date_str '_VOR_excel_' save_prefix];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

tb_map_list = TTT_vor_1000_2_6_get_group_exp_map(search_fo);
% tb_meta_mouse_info = readtable(meta_info_path,'Sheet','mouse_info');
tb_meta_plot_list = readtable(meta_info_path,'Sheet','plot_list');
tb_mouse_info = readtable(meta_info_path,'Sheet','mouse_info');
info_ids = tb_mouse_info.mouse_id;
info_DOB = tb_mouse_info.DOB;
info_sex = tb_mouse_info.sex;

%plot the mice in plot_list
group_result = {};
group_names = {};
group_colors = {};
mouse_all_id = {};
for g=1:size(tb_meta_plot_list,1) %g=2
    if isempty(tb_meta_plot_list{g,2}{1}) %if there is no mouse_ids.
        continue;
    end
    group_names{g} = tb_meta_plot_list{g,1}{1};
    mouse_all_id{g} = tb_meta_plot_list{g,2}{1};
    clr_str = tb_meta_plot_list{g,4};
    tok = strsplit(clr_str{1},',');
    group_colors{g} = [str2num(tok{1}) str2num(tok{2}) str2num(tok{3})];
    mouse_ids_str = tb_meta_plot_list{g,2};
    
    tok = strsplit(clr_str{1},',');
    group_clr{g} = [str2num(tok{1}) str2num(tok{2}) str2num(tok{3})]/255;
    mouse_ids = strsplit(mouse_ids_str{1},',');
    
    mice_result = {};
    for m=1:length(mouse_ids)        
        idx = find(contains(tb_map_list.mouse_id, strtrim(mouse_ids{m})));
        cur_list = tb_map_list(idx,:);
        if isempty(cur_list); error('Cannot find any mice. Maybe mouse_id is wrong!'); end
        cur_path = cur_list.map_path{1};
        [root, fi, ext] = fileparts(cur_path);
        tb_map = readtable(cur_path);
        for r=1:size(tb_map)
            if ~strcmp(tb_map.exp_type1(r),'empty') && ~isempty(tb_map.mat_path{r})
                mat_path = [root tb_map.mat_path{r}];
                temp = load(mat_path);
                vor_trial = temp.vor_trial;
                exp_time = datetime(vor_trial.exp_date_str,'InputFormat','yyyyMMdd_HHmmss');
                tb_map.exp_date(r) = exp_time;                
                if isfield(vor_trial,'gain_median')
                    tb_map.gain_values(r) = {vor_trial.peak_gain_smoothed_xy};
                    
                    %check how many NaNs are in.
                    temp = tb_map.gain_values{r};
                    gain_values = temp(:,2);
                    perc_nan = length(find(isnan(gain_values)))/length(gain_values)*100;
                    f_too_many_nan_gain = perc_nan > thr_gain_nan_perc;
          
                    % Not being used. 20231207.
%                     % get run_p_ang_vel (vel during running 61 secs). and, 
%                     % if saccades moments are dominant, then set gain as
%                     % NaN.
%                     if (vor_trial.exp_hz == 1) && (strcmp(vor_trial.exp_type,'VOR') || strcmp(vor_trial.exp_type,'VVOR'))
%                         saccde_thr = vor_trial.analysis_param.saccade_ang_vel_thr_1hz;
%                     else
%                         saccde_thr = vor_trial.analysis_param.saccade_ang_vel_thr;
%                     end                    
%                     p_ang_vel = vor_trial.p_ang_vel;
%                     v_fr = vor_trial.analysis_param.v_fr;
%                     xx = (1:length(p_ang_vel))/v_fr;
%                     run_start_t = vor_trial.gain_xy(1,1);
%                     run_end_t = vor_trial.gain_xy(end,1);
%                     run_mask = (run_start_t <= xx) & (xx <= run_end_t);
% %                     xx_run = xx(run_mask);
%                     run_p_ang_vel = p_ang_vel(run_mask);
%                     saccade_mask = (run_p_ang_vel < -saccde_thr) | (saccde_thr < run_p_ang_vel);
%                     saccade_period_perc = length(find(saccade_mask))/length(saccade_mask)*100;
%                     f_too_many_saccade = (thr_saccade_period <= saccade_period_perc);
%                     
% %                     disp([vor_trial.exp_type ' ' num2str(vor_trial.exp_hz) ', ' num2str(saccade_period_perc)]);
                    
%                     if f_too_many_nan_gain || f_too_many_saccade
                    if f_too_many_nan_gain
                        tb_map.gain_median(r) = NaN;
                    else
                        tb_map.gain_median(r) = vor_trial.gain_median;
                    end
                else
                    tb_map.gain_median(r) = NaN;
                    tb_map.gain_values(r) = {[]};
                end                
            else
                tb_map.gain_median(r) = NaN;
                tb_map.gain_values(r) = {[]};
            end
        end    
        mice_result{m} = tb_map;
    end
    
    group_result{g} = mice_result;
end

% 20240128 check distribution of gain values.
if 0 %set 0 if you don't want to run.
    tb_sum = [];
    for g=1:length(group_result)
        mice_result = group_result{g};
        for m=1:length(mice_result)
            if isempty(tb_sum)
                tb_sum = [mice_result{m}];
            else
                tb_sum = [tb_sum; mice_result{m}];
            end
        end
    end
    
    
    g_val = [];
    for r=1:size(tb_sum,1)
        c_gain = tb_sum.gain_values{r};
        if ~isempty(c_gain)
            g_val = [g_val; c_gain(:,2)];
        end
    end
    
    figure(); hold on;
    histogram(g_val);
    title(save_prefix,'interpreter','none');
    ylim([0 30]);
    find(g_val>3)
end

% 20240128 discarding abnormal gains..
if 0 %set 0 if you don't want to run.
    abnormal_gain_thr = [-2 2];
    for g=1:length(group_result)
        mice_result = group_result{g};
        for m=1:length(mice_result)
            mouse = mice_result{m};
            for r=1:size(mouse,1)
                c_gain = mouse.gain_values{r};
                if ~isempty(c_gain)
                    
                    idx = find((c_gain(:,2))<=abnormal_gain_thr(1) | abnormal_gain_thr(2) <(c_gain(:,2)));
                    if ~isempty(idx)
                        disp(['abnormal gain detected: ' mouse.mouse_id{r} ',' mouse.exp_type1{r} ',' ...
                            num2str(mouse.exp_type2_StimHz_(r)) 'Hz,day' num2str(mouse.exp_type3_day_(r))]);
                        disp(c_gain(idx,2));
                        
                        c_gain(idx,2) = nan;
                        mouse.gain_values{r} = c_gain;
                        mouse.gain_median(r) = nanmedian(c_gain(:,2));
                        
                    end
                end
            end
            mice_result{m} = mouse;
        end
        group_result{g} = mice_result;
    end    
end


% make structure
OKR_1_idx = [1 4 7];
OKR_2_idx = [11 14 17];
VVOR_1_idx = OKR_1_idx+1;
VVOR_2_idx = OKR_2_idx+1;
VOR_1_idx = OKR_1_idx+2;
VOR_2_idx = OKR_2_idx+2;

reversal_day1_idx = [22:28];
reversal_day2_idx = reversal_day1_idx+8;
reversal_day3_idx = reversal_day1_idx+16;
reversal_day4_idx = reversal_day1_idx+24;

clearvars 'group_st';
group_st = [];
for g=1:length(group_result)
    mice_result = group_result{g};   
    clearvars 'mice_st';
    for m=1:length(mice_result)
        n_rows = size(mice_result{m},1);
        mouse_ids = mice_result{m}.mouse_id;
        mouse_ids(strcmp(mouse_ids,'')) = [];
        mice_st(m).mouse_id = mouse_ids(1); %earlist time
        times = sortrows(mice_result{m}.exp_date);
        
        idx = find(contains(info_ids, mouse_ids(m)));
        DOB = info_DOB(idx(1));
        sex_str = upper(info_sex{idx(1)});
        if isnan(str2double(DOB)) %sometimes, readtable read them as double, char.
            DOB = num2str(DOB); 
        end    
        if ischar(DOB) && ~strcmp(DOB,'NaN')
            DOB_time = datetime(DOB, 'InputFormat', 'yyyyMMdd')+hours(12); 
            age_day = round(datenum(times(1) - DOB_time));
        else
            age_day = NaN;
        end
        mice_st(m).age_day = age_day; %earlist time
        mice_st(m).sex_str = sex_str; %earlist time
        
        if n_rows > 0
            mice_st(m).OKR_1 = mice_result{m}.gain_median(OKR_1_idx);
            mice_st(m).VVOR_1 = mice_result{m}.gain_median(VVOR_1_idx);
            mice_st(m).VOR_1 = mice_result{m}.gain_median(VOR_1_idx);
            mice_st(m).OKR_2 = mice_result{m}.gain_median(OKR_2_idx);
            mice_st(m).VVOR_2 = mice_result{m}.gain_median(VVOR_2_idx);
            mice_st(m).VOR_2 = mice_result{m}.gain_median(VOR_2_idx);

            mice_st(m).OKR_avg = nanmean([mice_result{m}.gain_median(OKR_1_idx) mice_result{m}.gain_median(OKR_2_idx)],2);
            mice_st(m).VVOR_avg = nanmean([mice_result{m}.gain_median(VVOR_1_idx) mice_result{m}.gain_median(VVOR_2_idx)],2);
            mice_st(m).VOR_avg = nanmean([mice_result{m}.gain_median(VOR_1_idx) mice_result{m}.gain_median(VOR_2_idx)],2);
        end
        
        if n_rows < reversal_day1_idx; continue; end
        mice_st(m).reversal_day1 = mice_result{m}.gain_median(reversal_day1_idx);
        if n_rows < reversal_day2_idx; continue; end
        mice_st(m).reversal_day2 = mice_result{m}.gain_median(reversal_day2_idx);
        if n_rows < reversal_day3_idx; continue; end
        mice_st(m).reversal_day3 = mice_result{m}.gain_median(reversal_day3_idx);
        if n_rows < reversal_day4_idx; continue; end
        mice_st(m).reversal_day4 = mice_result{m}.gain_median(reversal_day4_idx);
    end
    group_st(g).mice_st = mice_st;
end
for g=1:length(group_st)
    disp([group_names{g} '(n=' num2str(length(group_result{g})) '): ' mouse_all_id{g}]);
end

% Export as excel to report data for publication.

% Export age.
data_header = {};
data_meta_cell = {};
data = {};
for g=1:length(group_st)
    ages = {group_st(g).mice_st.age_day}';    
    sexs = {group_st(g).mice_st.sex_str}';    
    mouse_ids = [group_st(g).mice_st.mouse_id]';
    mouse_ids_with_sex = {};
    for m=1:length(mouse_ids)
        mouse_ids_with_sex{m,1} = [mouse_ids{m} ',' sexs{m}];
    end
    data_meta_cell(1:length(mouse_ids),end+1) = mouse_ids_with_sex;
    data(1:length(ages),end+1) = ages;
end
data_header = group_names;
cell_color_map = group_colors;

%plot age.
save_excel_path = [excel_save_path '_age.xlsx'];
sheet_name = 'age';
empty_column_pos = [];
[excel_raw] = TTTH_make_excel_for_plotting_ver2(data, data_meta_cell, data_header, ...
    cell_color_map, save_excel_path,sheet_name,empty_column_pos);

figure('color',[1 1 1]); ax1 = gca;
jpg_path = []; y_lim_age = [0 140]; fig_size2 = [100 100 300 400]; title_in = ''; y_label = 'age'; start_x_coor = [];
[fig2] = TTTH_plot_box_from_cell_ver2(ax1, excel_raw, jpg_path, y_lim_age, fig_size2, title_in, y_label, start_x_coor);
xlim([0 3]);

% Export VOR data to excel.
data_header = {};
data_meta_cell = {};
data = {};
save_excel_path = [excel_save_path '.xlsx'];
empty_column_pos = [4,7,7,10,13,13,16,19,19, 26,33,40];
for i=1:length(group_st)
    mice_st = group_st(i).mice_st;
    sheet_name = group_names{i};    
    
    performance = [mice_st.OKR_1; mice_st.OKR_2; mice_st.VVOR_1; mice_st.VVOR_2; mice_st.VOR_1; mice_st.VOR_2]';
    learning = [mice_st.reversal_day1; mice_st.reversal_day2; mice_st.reversal_day3; mice_st.reversal_day4]';
    data_num = [performance learning];
    data = num2cell(data_num);

    data_header = cell(1,size(data,2));
    data_header(:) = {'-'};
    data_header([1,4,7,10,13,16,19,26,33,40]) = {'OKR_1','OKR_2','VVOR_1','VVOR_2','VOR_1','VOR_2','learning_day1','learning_day2','learning_day3','learning_day4'};

%     cell_color_map = repmat(group_colors(i),[1,size(data,2)]);
    cell_color_map = [repmat({clr_OKR},[1,3]), repmat({clr_OKR},[1,3]), repmat({clr_VVOR},[1,3]), repmat({clr_VVOR},[1,3]), repmat({clr_VOR},[1,3]), repmat({clr_VOR},[1,3]), repmat({clr_VOR},[1,28])];
    
    data_meta_cell = [mice_st.mouse_id]';
    data_meta_cell(1:size(data,1),2:size(data,2)) = {[]};
    
    [excel_raw] = TTTH_make_excel_for_plotting_ver2(data, data_meta_cell, data_header, ...
        cell_color_map, save_excel_path, sheet_name, empty_column_pos);

end

parameter_cell = {
    'thr_gain_nan_perc', thr_gain_nan_perc %70.
%     'thr_saccade_period', 100
    };
xlswrite(save_excel_path,parameter_cell,'parameters');

% fig = TTT_im16_1_1_ver1_plot_excel(3);

%% plot group result
fig = figure('color',[1 1 1]);
fig.Position = fig_size;
m=1; n=7;
font_size = 20;

ax_OKR = subplot(m,n,1); hold on;
ax_VVOR = subplot(m,n,2); hold on;
ax_VOR = subplot(m,n,3); hold on;
ax_reversal = subplot(m,n,4:7); hold on;
    set(ax_OKR,'fontsize',font_size);
    set(ax_VVOR,'fontsize',font_size);
    set(ax_VOR,'fontsize',font_size);
    set(ax_reversal,'fontsize',font_size);

x_lim = [0 7];
x_lim_2 = [0 32];
% y_lim = [-0.1 1.3];

for g=1:length(group_st)
    mice_st = group_st(g).mice_st;
    cur_clr = group_clr{g};
    
    if isfield(mice_st,'OKR_1')
    data = [mice_st(:).OKR_1]; cur_ax = ax_OKR; title(cur_ax,'OKR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
    data = [mice_st(:).OKR_2];
    xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    if isfield(mice_st,'VVOR_1')
    data = [mice_st(:).VVOR_1]; cur_ax = ax_VVOR; title(cur_ax,'VVOR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
    data = [mice_st(:).VVOR_2];
    xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    if isfield(mice_st,'VOR_1')
    data = [mice_st(:).VOR_1]; cur_ax = ax_VOR; title(cur_ax,'VOR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
    data = [mice_st(:).VOR_2];
    xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    cur_ax = ax_reversal;  title(cur_ax,'Learning day1/day2/day3/day4','fontsize',10);
    if isfield(mice_st,'reversal_day1')
    data = [mice_st(:).reversal_day1]; 
    xx = [1 2 3 4 5 6 7]; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day2')
    data = [mice_st(:).reversal_day2]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day3')
    data = [mice_st(:).reversal_day3]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day4')
    data = [mice_st(:).reversal_day4]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    xlim(cur_ax,x_lim_2); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
end

saveas(fig, fig_save_path);
saveas(fig, img_save_path);

%% plot indivisual result
fig = figure('color',[1 1 1]);
fig.Position = fig_size;
m=1; n=7;
font_size = 20;

ax_OKR = subplot(m,n,1); hold on;
ax_VVOR = subplot(m,n,2); hold on;
ax_VOR = subplot(m,n,3); hold on;
ax_reversal = subplot(m,n,4:7); hold on;
    set(ax_OKR,'fontsize',font_size);
    set(ax_VVOR,'fontsize',font_size);
    set(ax_VOR,'fontsize',font_size);
    set(ax_reversal,'fontsize',font_size);

x_lim = [0 7];
x_lim_2 = [0 32];
% y_lim = [-0.1 1.3];

for g=1:length(group_st)
    mice_st = group_st(g).mice_st;
    cur_clr = group_clr{g};
    
    if isfield(mice_st,'OKR_1')
    data = [mice_st(:).OKR_1]; cur_ax = ax_OKR; title(cur_ax,'OKR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
    data = [mice_st(:).OKR_2];
    xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    if isfield(mice_st,'VVOR_1')
    data = [mice_st(:).VVOR_1]; cur_ax = ax_VVOR; title(cur_ax,'VVOR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
    data = [mice_st(:).VVOR_2];
    xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    if isfield(mice_st,'VOR_1')
    data = [mice_st(:).VOR_1]; cur_ax = ax_VOR; title(cur_ax,'VOR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
    data = [mice_st(:).VOR_2];
    xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    cur_ax = ax_reversal;  title(cur_ax,'Learning day1/day2/day3/day4','fontsize',10);
    if isfield(mice_st,'reversal_day1')
    data = [mice_st(:).reversal_day1]; 
    xx = [1 2 3 4 5 6 7]; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day2')
    data = [mice_st(:).reversal_day2]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day3')
    data = [mice_st(:).reversal_day3]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day4')
    data = [mice_st(:).reversal_day4]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    xlim(cur_ax,x_lim_2); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
end

for g=1:length(group_st)
    mice_st = group_st(g).mice_st;
    cur_clr = group_clr{g};
    
    data = [mice_st(:).OKR_1]; cur_ax = ax_OKR; title(cur_ax,'OKR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = repmat([1:size(data,1)],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
    data = [mice_st(:).OKR_2];
    xx = xx+size(data,1); plot(cur_ax, xx, data, 'color',cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
    data = [mice_st(:).VVOR_1]; cur_ax = ax_VVOR; title(cur_ax,'VVOR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = repmat([1 2 3],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
    data = [mice_st(:).VVOR_2];
    xx = xx+size(data,1); plot(cur_ax, xx, data, 'color',cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
    data = [mice_st(:).VOR_1]; cur_ax = ax_VOR; title(cur_ax,'VOR 0.2/0.5/1 Hz, two times','fontsize',10);
    xx = repmat([1 2 3],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
    data = [mice_st(:).VOR_2];
    xx = xx+size(data,1); plot(cur_ax, xx, data, 'color',cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
    cur_ax = ax_reversal;  title(cur_ax,'Learning day1/day2/day3/day4','fontsize',10);
    if isfield(mice_st,'reversal_day1')
    data = [mice_st(:).reversal_day1]; 
    xx = repmat([1:size(data,1)],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    if isfield(mice_st,'reversal_day2')
    data = [mice_st(:).reversal_day2]; 
    xx = xx+size(data,1)+1; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    if isfield(mice_st,'reversal_day3')
    data = [mice_st(:).reversal_day3]; 
    xx = xx+size(data,1)+1; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    if isfield(mice_st,'reversal_day4')
    data = [mice_st(:).reversal_day4]; 
    xx = xx+size(data,1)+1; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    xlim(cur_ax,x_lim_2); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
end

[fo,fi,ext] = fileparts(fig_save_path);
saveas(fig, [fo filesep fi '_ind' ext]);
[fo,fi,ext] = fileparts(img_save_path);
saveas(fig, [fo filesep fi '_ind' ext]);

%% plot indivisual result (plotting combined 2 OKR/VVOR/VOR)
fig = figure('color',[1 1 1]);
fig.Position = fig_size;
m=1; n=7;
font_size = 20;

ax_OKR = subplot(m,n,1); hold on;
ax_VVOR = subplot(m,n,2); hold on;
ax_VOR = subplot(m,n,3); hold on;
ax_reversal = subplot(m,n,4:7); hold on;
    set(ax_OKR,'fontsize',font_size);
    set(ax_VVOR,'fontsize',font_size);
    set(ax_VOR,'fontsize',font_size);
    set(ax_reversal,'fontsize',font_size);

x_lim = [0 4];
x_lim_2 = [0 32];
% y_lim = [-0.1 1.3];

for g=1:length(group_st)
    mice_st = group_st(g).mice_st;
    cur_clr = group_clr{g};
    
    if isfield(mice_st,'OKR_avg')
    data = [mice_st(:).OKR_avg]; cur_ax = ax_OKR; title(cur_ax,'OKR 0.2/0.5/1 Hz','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
%     data = [mice_st(:).OKR_2];
%     xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    if isfield(mice_st,'VVOR_avg')
    data = [mice_st(:).VVOR_avg]; cur_ax = ax_VVOR; title(cur_ax,'VVOR 0.2/0.5/1 Hz','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
%     data = [mice_st(:).VVOR_2];
%     xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    if isfield(mice_st,'VOR_avg')
    data = [mice_st(:).VOR_avg]; cur_ax = ax_VOR; title(cur_ax,'VOR 0.2/0.5/1 Hz','fontsize',10);
    xx = [1 2 3]; plot_gain(cur_ax, xx, data, cur_clr);    
%     data = [mice_st(:).VOR_2];
%     xx = [4 5 6]; plot_gain(cur_ax, xx, data, cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    end
    
    cur_ax = ax_reversal;  title(cur_ax,'Learning day1/day2/day3/day4','fontsize',10);
    if isfield(mice_st,'reversal_day1')
    data = [mice_st(:).reversal_day1]; 
    xx = [1 2 3 4 5 6 7]; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day2')
    data = [mice_st(:).reversal_day2]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day3')
    data = [mice_st(:).reversal_day3]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    if isfield(mice_st,'reversal_day4')
    data = [mice_st(:).reversal_day4]; 
    xx = xx+8; plot_gain(cur_ax, xx, data, cur_clr);    
    end
    xlim(cur_ax,x_lim_2); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
end

for g=1:length(group_st)
    mice_st = group_st(g).mice_st;
    cur_clr = group_clr{g};
    
    data = [mice_st(:).OKR_avg]; cur_ax = ax_OKR; title(cur_ax,'OKR 0.2/0.5/1 Hz','fontsize',10);
    xx = repmat([1:size(data,1)],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
%     data = [mice_st(:).OKR_2];
%     xx = xx+size(data,1); plot(cur_ax, xx, data, 'color',cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
    data = [mice_st(:).VVOR_avg]; cur_ax = ax_VVOR; title(cur_ax,'VVOR 0.2/0.5/1 Hz','fontsize',10);
    xx = repmat([1 2 3],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
%     data = [mice_st(:).VVOR_2];
%     xx = xx+size(data,1); plot(cur_ax, xx, data, 'color',cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
    data = [mice_st(:).VOR_avg]; cur_ax = ax_VOR; title(cur_ax,'VOR 0.2/0.5/1 Hz','fontsize',10);
    xx = repmat([1 2 3],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
%     data = [mice_st(:).VOR_2];
%     xx = xx+size(data,1); plot(cur_ax, xx, data, 'color',cur_clr);    
    xlim(cur_ax,x_lim); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
    cur_ax = ax_reversal;  title(cur_ax,'Learning day1/day2/day3/day4','fontsize',10);
    if isfield(mice_st,'reversal_day1')
    data = [mice_st(:).reversal_day1]; 
    xx = repmat([1:size(data,1)],[size(data,2),1])'; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    if isfield(mice_st,'reversal_day2')
    data = [mice_st(:).reversal_day2]; 
    xx = xx+size(data,1)+1; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    if isfield(mice_st,'reversal_day3')
    data = [mice_st(:).reversal_day3]; 
    xx = xx+size(data,1)+1; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    if isfield(mice_st,'reversal_day4')
    data = [mice_st(:).reversal_day4]; 
    xx = xx+size(data,1)+1; plot(cur_ax, xx, data, 'color',cur_clr);    
    end
    xlim(cur_ax,x_lim_2); ylim(cur_ax,y_lim); xticks(cur_ax,[]);
    
end

[fo,fi,ext] = fileparts(fig_save_path);
saveas(fig, [fo filesep fi '_ind_perform-avg' ext]);
[fo,fi,ext] = fileparts(img_save_path);
saveas(fig, [fo filesep fi '_ind_perform-avg' ext]);
end

function plot_gain(cur_ax, xx, data, cur_clr)
    val_m = nanmean(data,2); val_s = nanstd(data,0,2)/sqrt(size(data,2));    
    errorbar(cur_ax,xx, val_m, val_s, 'color', cur_clr, 'linewidth',2);
end
