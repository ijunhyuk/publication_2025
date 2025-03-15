function [] = TTT_eyeb100_9_1_CR_analysis()
%% 20240421 The following code is for trouble shooting of poor conditioning in wild 
%% type mouse, and it is not for CR response graph in the figure.

%% check puff intensity (eye lid distance) & eyeB conditioning.
% dropbox_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';
dropbox_fo = 'G:\Dropbox_joon\Dropbox (HMS)';
% sum_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO'];
sum_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1-2'];

filename = 'eye_blink_batch1-2.mat';

conditioned_response_threshold_z = 1.96;
conditioned_response_target_time = [0.5 1];


%%
path = [sum_fo filesep filename];
temp = load(path);
batch_set = temp.batch_set;
%% Check median values above 0 during CR target time. ex) 0.7-1.0 sec
cr_t = [0.7 1.0]; %CR target time

%copy basic information.
clearvars 'cr_st_arr'
n_st = numel(batch_set);
[cr_st_arr(1:n_st,1).mouse_id] = batch_set.mouse_id;
[cr_st_arr(1:n_st,1).day_no] = batch_set.day_no;
[cr_st_arr(1:n_st,1).date_str] = batch_set.date_str;
[cr_st_arr(1:n_st,1).box_no] = batch_set.box_no;
[cr_st_arr(1:n_st,1).video_name] = batch_set.video_name;

for i=1:length(batch_set) %i=55
    eyeB_st = batch_set(i);
    cs_norm = eyeB_st.median_cs_only_norm;
    xx_sec = eyeB_st.xx_sec;
    
    
    cr_mask = cr_t(1) <= xx_sec & xx_sec < cr_t(2);
    thr_mask = cs_norm > 0;
    valid_cr_mask = cr_mask & thr_mask;
    cr_val = cs_norm(valid_cr_mask);
    cr_size = sum(cr_val);
    
    cr_st_arr(i).cr_size = cr_size;
    
%     figure();
%     plot(xx_sec, cs_norm);
    
end
cr_tb = struct2table(cr_st_arr);
excel_save_path = [sum_fo filesep 'cr_table.xlsx'];
writetable(cr_tb,excel_save_path);

%% read the excel table for the info of eye-lid flip length and video path

xls_path = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\puff_eye_lid\puff_eye_lid.xlsx'];
[~,~,raw] = xlsread(xls_path);

puff_info_str = 'a6 TKO';
puff_info = [raw(4:end,1:2); raw(4:end,4:5)];

% puff_info_str = 'Gabra6 TKO';
% puff_info = [raw(4:end,7:8); raw(4:end,10:11); raw(4:end,13:14)];

nan_idx = [];
for i=1:size(puff_info,1)
    if isnan(puff_info{i,1})
        nan_idx(end+1) = i;
    end
end
puff_info(nan_idx,:) = [];

%%
%match puff videos to conditioning videos.
p_matched_idx = {};
p_used = [];
% search_fo = 'G:\Dropbox_joon\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO'; %Choose if the conditioning video and puff video are in the same folder.
search_fo = 'G:\Dropbox_joon\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data'; %Choose if the conditioning video and puff video are in the same folder.
mp4_list = TTTH_search_all_files(search_fo, 1, '*.mp4');
for i=1:size(cr_tb,1)
    v_name = cr_tb.video_name{i};
    tok = strsplit(v_name,'_');
    box_str = tok{1};
    date_str = tok{2};
    time_str = tok{3};
    
	list_idx = find(contains(mp4_list, v_name));
    v_path = mp4_list{list_idx};
    [v_fo,~,~] = fileparts(v_path);
    
    %find puff_name
    p_idx = [];
    for j=1:size(puff_info,1)
        [fo,p_name,ext] = fileparts(puff_info{j,1});
        p_tok = strsplit(p_name,'_');
        p_box_str = p_tok{3};
        p_date_str = p_tok{4};
        p_time_str = p_tok{5};

        list_idx = find(contains(mp4_list, p_name));
        p_path = mp4_list{list_idx};
        [p_fo,~,~] = fileparts(p_path);
        
        if strcmp(v_fo,p_fo)
            if strcmp(box_str, p_box_str) && strcmp(date_str, p_date_str) && str2num(p_time_str) < str2num(time_str)
                p_idx(end+1) = j;                
                if  length(find(p_used==j))>0
%                     i
%                     v_name
%                     j
%                     p_name
                    error('something wrong!');
                end
                p_used(end+1) = j;
            end
        end
    end
    p_matched_idx{i} = p_idx;
end
%% add puff_video & cr_size info to cr_tb.
% cr_tb = cr_tb_temp;
for i=1:size(cr_tb,1)
%     if i==24
%         'hi'
%     end
    if ~isempty(p_matched_idx{i})
        cr_tb.puff_video_name{i} = puff_info{p_matched_idx{i},1};
        cr_tb.lid_flip_inch(i) = puff_info{p_matched_idx{i},2};
    else
        cr_tb.puff_video_name{i} = [];
        cr_tb.lid_flip_inch(i) = NaN;
    end
end

%%
% drop_box_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';
drop_box_fo = 'G:\Dropbox_joon\Dropbox (HMS)';
meta_fo = [drop_box_fo '\Research_RegehrLAB\Analysis'];
meta_path = [meta_fo '\Meta_info_20221116.xlsx'];

[~,~,raw] = xlsread(meta_path,'plot_list');
plot_list_cell = raw(2:end,:);
for i=1:size(plot_list_cell,1)
    group_names{i} = plot_list_cell{i,1};
    mouse_ids_str = plot_list_cell{i,2};
    mouse_ids{i} = strsplit(mouse_ids_str,',');
    rgb_colors_str = plot_list_cell{i,4};
    aa = strsplit(rgb_colors_str,',');
    rgb_colors{i} = str2double(aa);
end


% group_str = ; tartget_ids = mouse_ids{1}; % select ctr mice only.
group_str = {'CTR', 'TKO'}; 
cmap = [
    0 0 0
    255 0 0
    ]/255;


% plotting averaged lid_flip during day1-8 vs. conditioning.
figure();
axes_cur = gca;
title_str = puff_info_str;

for g=1:length(group_str)
    tartget_ids = mouse_ids{g};
    target_tb = table();
    for i=1:size(cr_tb,1)
        if length(find(contains(tartget_ids, cr_tb.mouse_id{i}))) > 0
            target_tb(end+1,:) = cr_tb(i,:);
        end
    end
    
    uniq_mice = unique(target_tb.mouse_id(:));
    flip_mean = [];
    day8_cr_size = [];
    for u=1:length(uniq_mice)
%         if u==5
%             'hi'
%         end
        u_idx = find(contains(target_tb.mouse_id(:), uniq_mice{u}));
        mice_st = target_tb(u_idx,:);
        flip_mean(u,1) = nanmean(mice_st.lid_flip_inch(:));
        if isempty(mice_st.cr_size(mice_st.day_no==8))
            day8_cr_size(u,1) = NaN;
        else
            day8_cr_size(u,1) = mice_st.cr_size(mice_st.day_no==8);
        end
    end
    
    dat = [flip_mean day8_cr_size];
    dat(isnan(dat(:,2)),:) = [];
    dot_color = cmap(g,:);
    is_plot_regression = 1;
    is_plot_scatter = 1;
    [corr_val, p_val, regress_b, reg_x, reg_y, p_scatter, p_reg_line]= TTTH_v2_2_1_regression(axes_cur, dat, ...
        dot_color, is_plot_regression, is_plot_scatter)
    title_str = [title_str ', ' group_str{g} ', CorrCeff= ' num2str(corr_val) ', p-value= ' num2str(p_val) newline];
end
set(axes_cur,'FontSize',15);
xlabel('averaged lid_flip_inch(A.U.)', 'interpreter','none');
ylabel('conditioned eye closure(A.U.) at day8', 'interpreter','none');
title(title_str,'FontSize',10);
ylim([0 10000]);



% plotting individual days
% figure();
% axes_cur = gca;
% title_str = puff_info_str;
% 
% for g=1:length(group_str)
%     tartget_ids = mouse_ids{g};
%     target_tb = table();
%     for i=1:size(cr_tb,1)
%         if length(find(contains(tartget_ids, cr_tb.mouse_id{i}))) > 0
%             target_tb(end+1,:) = cr_tb(i,:);
%         end
%     end
%     
%     dat = [target_tb.lid_flip_inch target_tb.cr_size];
%     dat(isnan(dat(:,1)),:) = [];
%     dot_color = cmap(g,:);
%     is_plot_regression = 1;
%     is_plot_scatter = 1;
%     [corr_val, p_val, regress_b, reg_x, reg_y, p_scatter, p_reg_line]= TTTH_v2_2_1_regression(axes_cur, dat, ...
%         dot_color, is_plot_regression, is_plot_scatter)
%     title_str = [title_str ', ' group_str{g} ', CorrCeff= ' num2str(corr_val) ', p-value= ' num2str(p_val) newline];
% end
% set(axes_cur,'FontSize',15);
% xlabel('lid_flip_inch(A.U.)', 'interpreter','none');
% ylabel('index of conditioned eye closure(A.U.)', 'interpreter','none');
% title(title_str,'FontSize',10);
% ylim([0 10000]);


%% Below is Not being used for now, but use it later when we need CR ratio.

% compare_st_set = [];
new_batch_set = [];
for i=1:length(batch_set) %i=55
    eyeB_st = batch_set(i);
    %     compare_st = [];
    %     compare_st.mouse_id = eyeB_st.mouse_id;
    %     compare_st.day_no = eyeB_st.day_no;
    %     compare_st.date_str = eyeB_st.date_str;
    %     compare_st.box_no = eyeB_st.box_no;
    %     compare_st.video_name = eyeB_st.video_name;
    %     compare_st.vi_hz = eyeB_st.vi_hz;
    %     compare_st.xx_sec = eyeB_st.xx_sec;
    
    eyeB_st = TTT_eyeb100_9_2_add_cr_analysis(eyeB_st, conditioned_response_threshold_z, conditioned_response_target_time);
    if i==1
        new_batch_set = eyeB_st;
    else
        new_batch_set(i,1) = eyeB_st;
    end
end

%% plotting
drop_box_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';
% drop_box_fo = 'G:\Dropbox_joon\Dropbox (HMS)';
meta_fo = [drop_box_fo '\Research_RegehrLAB\Analysis'];
meta_path = [meta_fo '\Meta_info_20221116.xlsx'];

[~,~,raw] = xlsread(meta_path,'plot_list');
plot_list_cell = raw(2:end,:);
for i=1:size(plot_list_cell,1)
    group_names{i} = plot_list_cell{i,1};
    mouse_ids_str = plot_list_cell{i,2};
    mouse_ids{i} = strsplit(mouse_ids_str,',');
    rgb_colors_str = plot_list_cell{i,4};
    aa = strsplit(rgb_colors_str,',');
    rgb_colors{i} = str2double(aa);
end


cr_mat = [];

batch_set_ctr = [];
batch_set_tko = [];

for i=1:length(new_batch_set)
    eyeB_st = new_batch_set(i);
    mouse_id = eyeB_st.mouse_id;
    if length(find(contains(mouse_ids{1}, mouse_id))) > 0
        if isempty(batch_set_ctr)
            batch_set_ctr = eyeB_st;
        else
            batch_set_ctr(end+1) = eyeB_st;
        end
    elseif length(find(contains(mouse_ids{2}, mouse_id))) > 0
        if isempty(batch_set_tko)
            batch_set_tko = eyeB_st;
        else
            batch_set_tko(end+1) = eyeB_st;
        end
    end
end


for g=1:2
    if g==1; cur_set = batch_set_ctr; end;
    if g==2; cur_set = batch_set_tko; end;
    
    unique_mice = unique({cur_set.mouse_id});
    n_mice = length(unique_mice);
    mice_cmap = jet(n_mice);
    
    fig1 = figure(); hold on;
    
    for i=1:length(cur_set)
        
        eyeB_st = cur_set(i);
        mouse_id = eyeB_st.mouse_id;
        day = eyeB_st.day_no;
        perc_cr = eyeB_st.perc_cr;
        idx = find(contains(unique_mice, mouse_id));
        cr_mat(idx,day) = perc_cr;
        
        box = eyeB_st.box_no;
        clr = mice_cmap(idx,:);
        
%         fig2 = figure();
        xx = eyeB_st.xx_sec;
        cur_cs = eyeB_st.eye_h_cs_only;
        cur_cs_z = zscore(cur_cs);
        
%         plot(xx,cur_cs_z);
%         title(['Mouse: ' mouse_id ', Day:' num2str(day) ', Box:' num2str(box)]);
        
        xx = day + rand(1)/2;
        figure(fig1);
        plot(xx, perc_cr,'o','color',clr,'markersize',5);
    end
    m_cr = mean(cr_mat,1);
    plot(m_cr);
    ylim([0 100]);
    
end

disp(['Finished!!!']);
end
