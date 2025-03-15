function [eyeB_st] = TTT_eyeb100_3_1_analyze_video_with_DLC_excel(video_path, excel_path, mat_path, box_no, day_no, is_plot, is_save_jpeg)
%%
% 20221213. Joon.

%input

% manual parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clr_detection = [
    11 8 134%upper lid
    126 3 170%upper lid
    206 70 118%cr
    ]/255;
clr_cs_us = [0.4 0.4 0.4];
clr_cs_only = [1 0 0];

like_thr = 0.5; %consider it as eye closing below this.
n_frame_per_trial = 560; % 560 fraemes x 110 trials = 61600
vi_hz = 280; % video Hz.
fig_position = [100 100 300 300];
analysis_fo_name = 'analysis';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
[fo,fi,ext] = fileparts(video_path);
jpeg_path = [fo filesep analysis_fo_name filesep fi '_trace_day' num2str(day_no) '.jpeg'];
param_mat = load(mat_path);
trial_id = param_mat.sess_param.trial_ID(:,box_no);
mouse_id = param_mat.sess_param.subject_ID{box_no};

eyeB_st = struct();
eyeB_st.mouse_id = mouse_id;
eyeB_st.day_no = day_no;
eyeB_st.box_no = box_no;
eyeB_st.video_name = fi;
eyeB_st.clr_detection = clr_detection;
eyeB_st.like_thr = like_thr;
eyeB_st.n_frame_per_trial = n_frame_per_trial;
eyeB_st.vi_hz = vi_hz;
eyeB_st.clr_cs_us = clr_cs_us;
eyeB_st.clr_cs_only = clr_cs_only;
eyeB_st.trial_id = trial_id;

dlc_st = parse_dlc_csv_eyeB(excel_path, clr_detection);
ud = dlc_st.upperlid;
ld = dlc_st.lowerlid;
cr = dlc_st.cr;

eyeB_st.dlc_st = dlc_st;


eyeB_st.param_mat = param_mat;

% [LED_onset, LED_offset, puff_onset, puff_offset] = TTT_eyeb100_2_1_get_timing_sec(param_mat, trial_no);


mask_dlc_miss = ud.likelihood<like_thr;
ud.y(mask_dlc_miss) = NaN;
ld.y(mask_dlc_miss) = NaN;

ori_sz = length(ud.y);
re_ud_y = reshape(ud.y,[n_frame_per_trial ori_sz/n_frame_per_trial]); %each col is 1 trial.
re_ld_y = reshape(ld.y,[n_frame_per_trial ori_sz/n_frame_per_trial]); %each col is 1 trial.
eye_h = (re_ud_y-re_ld_y); % calculate eye height.
xx = [1:n_frame_per_trial]'/vi_hz;
eyeB_st.xx_sec = xx;
eye_h_cs_us = eye_h(:,find(trial_id==0));
eye_h_cs_only = eye_h(:,find(trial_id==1));
median_cs_us = nanmedian(eye_h_cs_us,2);
median_cs_only = nanmedian(eye_h_cs_only,2);

eyeB_st.eye_h_cs_us = eye_h_cs_us;
eyeB_st.eye_h_cs_only = eye_h_cs_only;
eyeB_st.median_cs_us = median_cs_us;
eyeB_st.median_cs_only = median_cs_only;

if is_plot
    
    fig1 = figure('color',[1 1 1],'position',fig_position);
    ax1 = gca; hold on;
    TTT_eyeb100_5_1_plot_eyeB_st(eyeB_st, ax1);
    
    if is_save_jpeg
        [fo,fi,ext] = fileparts(jpeg_path);
        if ~exist(fo)
            mkdir(fo);
        end
        saveas(fig1, jpeg_path);
    end
end
end

function dlc_st = parse_dlc_csv_eyeB(excel_path, clr_pupil)
[~,~,raw] = xlsread(excel_path);
num_detection = 3;
add = 1; %python index starts with 0 (1 for matlab).
for i=1:num_detection
    detection_names{i} = raw{2,3*(i-1)+2};
    dlc_st.(detection_names{i}).color = clr_pupil(i,:);
    dlc_st.(detection_names{i}).x = [raw{4:end,3*(i-1)+2}]'+add;
    dlc_st.(detection_names{i}).y = [raw{4:end,3*(i-1)+3}]'+add;
    dlc_st.(detection_names{i}).likelihood = [raw{4:end,3*(i-1)+4}]';
end

end
