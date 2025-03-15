function [] = TTT_eyeb100_8_2_make_eyeB_group_st()
%%
% avg_method = 2; %1:median, 2:mean
avg_method = 1; %1:median, 2:mean

drop_box_fo = 'M:\Dropbox (HMS)';
meta_fo = [drop_box_fo '\Research_RegehrLAB\Analysis'];
meta_path = [meta_fo '\Meta_info_20240606.xlsx'];

batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO'];
batch_mat_path = [batch_fo '\eye_blink.mat'];
n_days = 9;

plot_types = [1]; %0: absolute value, 1: percent, 2:early-late trial, CS only.  3: early-late trial, CS-US.

cr_threshold = 50; %percent.
% cr_time = [0.05, 0.5]; %timing of cr (sec) from CS onset.
cr_peak_avg_time = [0.4, 0.5]; %timing of cr (sec) from CS onset.

%for squinting detection. 
is_filter_squint = 1; %set 1 to filter. 0 to not.
squinting_search_time_window = [-0.5 0.5]; %before LED on. this is used to measure squinting.
squinting_control_days = [1]; %these days will be used as control eye height (full eye size).
squinting_control_trials = [1:10]; %these cs-us trials will be used as control eye height (full eye size).

squint_thr_perc_of_full_eye = 30; % Joon publication 20241030. if eye size become less than this value(%), it is classified as squint.
% squint_thr_perc_of_full_eye = 0; % if eye size become less than this value(%), it is classified as squint.


% cr_dur_thr = 0.2; %at least value should be > cr_threshold more than this time duration.
get_cr_from = 1; %'cs_only';
% get_cr_from = 2; %'all';
% sm_dur = 0.2; %sec. for calculating cr fraction.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp = load(batch_mat_path);
batch_set = temp.batch_set;
%%
for p=1:length(plot_types)
    cccc;
    plot_type = plot_types(p);
    % read info from plot_list sheet.
    group_names = {};
    mouse_ids = {};
    rgb_colors = {};
    
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
    
    % for age data. in progress... do later.
    tb_mouse_info = readtable(meta_path,'Sheet','mouse_info');
    info_ids = tb_mouse_info.mouse_id;
    info_DOB = tb_mouse_info.DOB;
    
    
    % male & female sorting.
    %do later.
    
    % get CTR data, KO data.
    clearvars group_st;
    %only upto n_days
    batch_set = batch_set([batch_set.day_no] <= n_days);
    n_sample = length(batch_set(1).xx_sec);
    if get_cr_from == 1
        n_cr_flag = length(batch_set(1).trial_no_cs_only);
    else
        n_cr_flag = length(batch_set(1).trial_no_cs_only) + length(batch_set(1).trial_no_cs_us);
    end
    n_trial_cs_us = length(batch_set(1).trial_no_cs_us);
    n_trial_cs_only = length(batch_set(1).trial_no_cs_only);
    
    for g=1:length(group_names)
        group_st(g).group_name = group_names{g};
        group_st(g).group_color = rgb_colors{g};
        group_st(g).mouse_ids = mouse_ids{g};
        
        %     group_st(g).mouse_age_days = ; %in progress...
        
        group_st(g).xx_sec = batch_set(1).xx_sec;
        vi_hz = batch_set(1).vi_hz;
        cs_start_end_sec = batch_set(1).cs_start_end_sec;
        
%         idx = contains({batch_set.mouse_id}, mouse_ids{g});
        idx = ismember({batch_set.mouse_id}, mouse_ids{g});        
        cur_set = batch_set(idx);        
        uniq_day = unique([cur_set.day_no]);
        uniq_mice = unique({cur_set.mouse_id});
        squint_thr_px_mice = [];
        cs_us_mice_median = []; %dimension 1(row): data points, 2:each mouse, 3:days.
        cs_us_group_avg = [];%dimension 1(row): data points, 2:days.
        cs_us_group_sem = [];
        cs_only_mice_median = []; %dimension 1(row): data points, 2:each mouse, 3:days.
        cs_only_group_avg = [];%dimension 1(row): data points, 2:days.
        cs_only_group_sem = [];
        cr_flag_mice = []; %dimension 1(row): data points, 2:each mouse, 3:days.
        cr_peak_mice = []; %dimension 1(row): data points, 2:each mouse, 3:days.
        
        squint_flag_mice_cs_only = []; %if the trial was squinting.
        squint_flag_mice_cs_us = []; %if the trial was squinting.
        
        
        %get squint_thr_px for each mouse
        for m=1:length(uniq_mice) %m=1
            idx_cur = find(strcmp({cur_set.mouse_id},uniq_mice{m})); % find target mouse
            mouse_set = cur_set(idx_cur);
            idx_cur = find(ismember([mouse_set.day_no],squinting_control_days)); % find target day
            day_set = mouse_set(idx_cur);
            squint_idx = (squinting_search_time_window+cs_start_end_sec(1))*vi_hz;
            eye_h_cs_us = day_set(1).eye_h_cs_us;
            
            % calculate full eye height in day1.
            us_s = day_set(1).us_start_end_sec(1)*vi_hz+1;
            us_e = day_set(1).us_start_end_sec(2)*vi_hz;
            puff_residual_time = 0.03; %sec. the time still can see hair is puffed.
            full_close_s = us_e + round(puff_residual_time*vi_hz);
            full_close_e = full_close_s + round(puff_residual_time*vi_hz);
            full_close_moments = eye_h_cs_us([full_close_s:full_close_e],:);
            full_close_amp = prctile(full_close_moments(:),90);

            squint_examine_data = eye_h_cs_us(squint_idx(1)+1:squint_idx(2),squinting_control_trials);
            median_val = nanmedian(squint_examine_data,2)-full_close_amp;            
            squint_thr_px_mice(m) = prctile(abs(median_val),90)*squint_thr_perc_of_full_eye/100;
        end
        
        
        
        for d=uniq_day %for each day
            clearvars day_st;
            values_cs_only = [];
            values_cs_us = [];
            cr_flag = [];
            cr_peak = [];
            squint_flag_cs_only = [];
            squint_flag_cs_us = [];
            day_set = cur_set([cur_set.day_no]==d);
            mask = ismember(uniq_mice, {day_set.mouse_id});


            
            
            for k=1:length(mask) %for each mouse,   k=2
                if mask(k)
                    idx_cur = find(strcmp({day_set.mouse_id},uniq_mice{k}));
                    squint_thr_px = squint_thr_px_mice(k);                    
                    
                    % 20240430, currently CR fraction is not used.
                   % instead, use the average closure during
                   %  cr_peak_avg_time.
%                     cur_eye_st = day_set(k);                    
%                     [eye_p_cs_us, median_cs_us, eye_p_cs_only, median_cs_only] = TTT_eyeb100_7_1_normalize_eye_blink(cur_eye_st);                                        
%                     cr_time_abs = cr_time + +cs_start_end_sec(1);
%                     cr_time_idx = round([cr_time_abs(1)*vi_hz, cr_time_abs(2)*vi_hz]);
%                     cr_dur_thr_idx = round(cr_dur_thr*vi_hz);
%                     sm_eye_p_cs_only = medfilt1(eye_p_cs_only,round(sm_dur*vi_hz),'omitnan');
%                     [cr_flag(:,k), cr_peak(:,k)] = TTT_eyeb100_7_3_count_conditioned_response(sm_eye_p_cs_only, cr_threshold, cr_time_idx, cr_dur_thr_idx); %if CR count is done by CS_only. 20240422.

                    % 20240501, calculate CR fraction. '_p' means 'p'ercent.
                    cur_eye_st = day_set(idx_cur);                    
%                     [eye_p_cs_us, median_cs_us, eye_p_cs_only, median_cs_only] = TTT_eyeb100_7_1_normalize_eye_blink(cur_eye_st);  
                    [eye_p_cs_us, median_cs_us, eye_p_cs_only, median_cs_only, is_squint_cs_only, is_squint_cs_us] = TTT_eyeb100_7_2_normalize_eye_blink(cur_eye_st, is_filter_squint, squint_thr_px);  
                    cr_time_abs = cr_peak_avg_time + +cs_start_end_sec(1);
                    cr_time_idx = round([cr_time_abs(1)*vi_hz, cr_time_abs(2)*vi_hz]);   
                    avg_cr_res = nanmedian(eye_p_cs_only(cr_time_idx(1):cr_time_idx(2), :),1)';
                    
%                     values(:,k) = day_set(idx_cur).median_cs_only_norm;
                    values_cs_only(:,k) = median_cs_only;
                    values_cs_us(:,k) = median_cs_us;

                    cr_peak(:,k) = avg_cr_res;        
                    cr_flag(:,k) = avg_cr_res > cr_threshold;                   
                    
                    squint_flag_cs_only(:,k) = is_squint_cs_only;
                    squint_flag_cs_us(:,k) = is_squint_cs_us;
                    
                else
                    values_cs_only(:,k) = nan(n_sample,1);
                    values_cs_us(:,k) = nan(n_sample,1);
                    cr_flag(:,k) = nan(n_cr_flag,1);
                    cr_peak(:,k) = nan(n_cr_flag,1);
                    squint_flag_cs_only(:,k) = nan(n_trial_cs_only,1);
                    squint_flag_cs_us(:,k) = nan(n_trial_cs_us,1);
                end
            end

            values_cs_only(values_cs_only==inf) = NaN;
            values_cs_us(values_cs_us==inf) = NaN;
            cr_peak(cr_peak==inf) = NaN;
            
            cs_only_mice_median(:,:,d) = values_cs_only;
            cs_us_mice_median(:,:,d) = values_cs_us;
            cr_peak_mice(:,:,d) = cr_peak;
            cr_flag_mice(:,:,d) = cr_flag;
            
            squint_flag_mice_cs_only(:,:,d) = squint_flag_cs_only;
            squint_flag_mice_cs_us(:,:,d) = squint_flag_cs_us;
            
            if avg_method==1
                cs_only_group_avg(:,d) = nanmedian(values_cs_only,2);
            elseif avg_method==2
                cs_only_group_avg(:,d) = nanmean(values_cs_only,2);
            end
            %         cs_only_group_sem(:,d) = nanstd(values,0,2)/sqrt(size(values,2));
            cs_only_group_sem(:,d) = nansem(values_cs_only);

            
            %%%%%% cs_us
%             for k=1:length(mask)
%                 if mask(k)
%                     idx_cur = find(contains({day_set.mouse_id},uniq_mice{k}));
%                     values(:,k) = day_set(idx_cur).median_cs_us_norm;
%                 else
%                     values(:,k) = nan(n_sample,1);
%                 end
%             end
%             values(values==inf) = NaN;
%             cs_us_mice_median(:,:,d) = values;
                        

            if avg_method==1
                cs_us_group_avg(:,d) = nanmedian(values_cs_us,2);
            elseif avg_method==2
                cs_us_group_avg(:,d) = nanmean(values_cs_us,2);
            end
            %         cs_us_group_sem(:,d) = nanstd(values,0,2)/sqrt(size(values,2));
            cs_us_group_sem(:,d) = nansem(values_cs_us);
            
        end
        
     
        % CR value Method: choose maximum peak
%         mice_median = cs_only_mice_median;
%         % mice_median = cs_us_mice_median
%         cr_time_abs = cr_time + +cs_start_end_sec(1);
%         cr_time_idx = round([cr_time_abs(1)*vi_hz, cr_time_abs(2)*vi_hz]);   
%         cr_peak_mice = mice_median(cr_time_idx(1):cr_time_idx(2), :,:);
%         cr_peak_mice = squeeze(nanmax(cr_peak_mice,[],1));


        % CR value Method: choose avarage of certain period.
        cr_peak_mice_mean = squeeze(nanmedian(cr_peak_mice,1)); 
        temp_m = nanmedian(cr_peak_mice,1);
        temp_sz = size(temp_m);
        cr_peak_mice_mean = reshape(temp_m,[temp_sz(2), temp_sz(3)]);
        
        group_st(g).cs_us_mice_median = cs_us_mice_median;
        group_st(g).cs_us_group_avg = cs_us_group_avg;
        group_st(g).cs_us_group_sem = cs_us_group_sem;
        
        group_st(g).cs_only_mice_median = cs_only_mice_median;
        group_st(g).cs_only_group_avg = cs_only_group_avg;
        group_st(g).cs_only_group_sem = cs_only_group_sem;

        group_st(g).cr_flag_mice = cr_flag_mice;
        group_st(g).cr_peak_mice = cr_peak_mice_mean;
        
        group_st(g).squint_flag_mice_cs_us = squint_flag_mice_cs_us;
        group_st(g).squint_flag_mice_cs_only = squint_flag_mice_cs_only;
        group_st(g).squint_thr_perc = squint_thr_perc_of_full_eye;
        group_st(g).squint_thr_px_mice = squint_thr_px_mice;
    end
    
    [fo,fi,ext] = fileparts(batch_mat_path);
    group_mat_name = ['eye_blink_group_norm_type' num2str(plot_type) '.mat'];
    group_st_path = [fo filesep group_mat_name];
    save(group_st_path, 'group_st');
    disp(['group_st is saved!!! ' group_st_path]);
    
    if 0 %this is old plot.
        %plot indivisual mouse per group
        batch_set_mid = {batch_set.mouse_id};
        g_batch_set_arr = [];
        group_name_arr = [];
        for i=1:length({group_st(:).group_name})
            group_mid = group_st(i).mouse_ids;
            group_name = group_st(i).group_name;
            idx = ismember(batch_set_mid, group_mid);
            g_batch_set = batch_set(idx);
            [fig1, ax1] = TTT_eyeb100_6_3_plot_eyeB_st_set(g_batch_set, n_days, plot_type);
            [fo,fi,ext] = fileparts(group_st_path);
            jpeg_path = [fo filesep fi '_' group_name '_' datestr(now,'yyyymmdd_HHMMSS') '.jpeg'];
            saveas(fig1, jpeg_path);
            if is_save_fig
                fig_path = [fo filesep fi '_' group_name '_' datestr(now,'yyyymmdd_HHMMSS') '.fig'];
                saveas(fig1, fig_path);
            end
            if i==1
                g_batch_set_arr = g_batch_set;
                group_name_arr = group_name;
            else
                g_batch_set_arr = [g_batch_set_arr; g_batch_set];
                group_name_arr = [group_name_arr '-' group_name];
            end
        end
        
        disp(['Plotting individual mice is done!!! ' jpeg_path]);
    end
    
    % [fig1, ax1] = TTT_eyeb100_6_3_plot_eyeB_st_set(g_batch_set_arr, n_days, is_perc_plot);
    % [fo,fi,ext] = fileparts(group_st_path);
    % jpeg_path = [fo filesep fi '_' group_name_arr '_normalize_type' num2str(is_perc_plot) '_' datestr(now,'yyyymmdd_HHMMSS') '.jpeg'];
    % saveas(fig1, jpeg_path);
    % if is_save_fig
    %     fig_path = [fo filesep fi '_' group_name_arr '_normalize_type' num2str(is_perc_plot) '_' datestr(now,'yyyymmdd_HHMMSS') '.fig'];
    %     saveas(fig1, fig_path);
    % end
end
disp(['All finished!!!']);

end
function res = nansem(values)
std_val = nanstd(values,0,2);
nan_size = length(find(isnan(values(1,:))));
sz = size(values,2)- nan_size;
square_n = sqrt(sz);
res = std_val/square_n;
end
