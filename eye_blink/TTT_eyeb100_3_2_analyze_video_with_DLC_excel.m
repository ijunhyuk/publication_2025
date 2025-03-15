function [eyeB_st] = TTT_eyeb100_3_2_analyze_video_with_DLC_excel(video_path, excel_path, mat_path, box_no, date_str, is_plot, is_save_jpeg)
%%
% 20221213. Joon.

%input

% manual parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clr_detection = [
    11 8 134%upper lid
    126 3 170%down lid
    206 70 118%cr
    255 0 0%closedlid
    ]/255;
clr_cs_us = [0.4 0.4 0.4];
clr_cs_only = [1 0 0];

% like_thr = 0.5; %for upperlid, lowerlid. consider it as eye closing below this.
like_thr = 0.8; %for upperlid, lowerlid. consider it as eye closing below this.
like_thr_closed = 0.9; %for closed_lid. consider it as eye closing above this.
n_frame_per_trial = 560; % 560 fraemes x 110 trials = 61600
baseline_time = 0.5; %sec. time before CS onset in the video.
vi_hz = 280; % video Hz.
fig_position = [100 100 1000 1000];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
[fo,fi,ext] = fileparts(video_path);
% jpeg_path = [fo filesep analysis_fo_name filesep fi '_trace_day' num2str(date_str) '.jpeg'];
jpeg_path = [fo filesep fi '_trace_day' num2str(date_str) '.jpeg'];
param_mat = load(mat_path);
trial_id = param_mat.sess_param.trial_ID(:,box_no);
mouse_id = param_mat.sess_param.subject_ID{box_no};

eyeB_st = struct();
eyeB_st.mouse_id = mouse_id;
eyeB_st.day_no = [];
eyeB_st.date_str = date_str;
eyeB_st.box_no = box_no;
eyeB_st.video_name = fi;
eyeB_st.clr_detection = clr_detection;
eyeB_st.like_thr = like_thr;
eyeB_st.n_frame_per_trial = n_frame_per_trial;
eyeB_st.vi_hz = vi_hz;
eyeB_st.clr_cs_us = clr_cs_us;
eyeB_st.clr_cs_only = clr_cs_only;
eyeB_st.trial_id = trial_id;

eyeB_st.baseline_time = [0 baseline_time];
eyeB_st.cs_start_end_sec = baseline_time + [0 param_mat.trial_param.CS_dur(box_no)];
eyeB_st.us_start_end_sec = baseline_time + param_mat.trial_param.ISI + [0 param_mat.trial_param.US_dur(box_no)];

dlc_st = parse_dlc_csv_eyeB(excel_path, clr_detection);
ud = dlc_st.upperlid;
ld = dlc_st.lowerlid;
cd = dlc_st.closedlid;
cr = dlc_st.cr;

% combined_ud_likelihood = max([ud.likelihood cd.likelihood],[],2);
% combined_ld_likelihood = max([ld.likelihood cd.likelihood],[],2);

% figure(); clf;
% plot(cd.likelihood); ylim([-1 2]); hold on;
% plot(ud.likelihood,'r');
% yyaxis right; hold on;
% plot(ud.y);
% plot(ld.y);
% plot(mask_full_close, 'g');

eyeB_st.dlc_st = dlc_st;
eyeB_st.param_mat = param_mat;

% [LED_onset, LED_offset, puff_onset, puff_offset] = TTT_eyeb100_2_1_get_timing_sec(param_mat, trial_no);

% to better infer.
smooth_sec = 0.050;
sm_win = round(smooth_sec*vi_hz);
if mod(sm_win,2)==0; sm_win = sm_win-1; end;
ud_hood = smooth(ud.likelihood, sm_win);
ld_hood = smooth(ld.likelihood, sm_win);

% mask_poor_DLC_detection = ((ud_hood < like_thr) | (ld_hood < like_thr));

mask_full_close = ((ud_hood < like_thr) | (ld_hood < like_thr)) ...
    & (cd.likelihood > like_thr_closed);

ud.y(ud_hood<like_thr) = NaN;
ld.y(ld_hood<like_thr) = NaN;

% ud.y = medfilt1(ud.y,sm_win,'omitnan', 'truncate');
% ld.y = medfilt1(ld.y,sm_win,'omitnan', 'truncate');

% replace the eye height(y_diff) to minimum eye_height (eye_close_h) when
% full_close.
y_diff = ud.y-ld.y;
y_diff(y_diff > 0) = nan; %distance cannot be above 0.
idx = find(isnan(y_diff) & mask_full_close);

%calculating the eye size when close.
% Fill linearly when likelihood is below threshold. (when DLC could not detect lids).
y_diff = fillmissing(y_diff,'linear');

closed_values = y_diff(cd.likelihood > like_thr_closed);
eye_close_h = prctile(closed_values,90);

% eye_close_h = nanmedian(y_diff(idx));
y_diff(idx) = eye_close_h;


ori_sz = length(ud.y);
% re_ud_y = reshape(ud.y,[n_frame_per_trial ori_sz/n_frame_per_trial]); %each col is 1 trial.
% re_ld_y = reshape(ld.y,[n_frame_per_trial ori_sz/n_frame_per_trial]); %each col is 1 trial.
eye_h = reshape(y_diff,[n_frame_per_trial ori_sz/n_frame_per_trial]); %each col is 1 trial.

% re_mask_full_close = reshape(mask_full_close,[n_frame_per_trial ori_sz/n_frame_per_trial]); %each col is 1 trial.
% eye_h = (re_ud_y-re_ld_y); % calculate eye height.
% eye_h(re_mask_full_close) = 0;

% clf;
% plot(eye_h);

xx = [1:n_frame_per_trial]'/vi_hz;
eyeB_st.xx_sec = xx;
trial_no_cs_us = find(trial_id==0)';
trial_no_cs_only = find(trial_id==1)';
eye_h_cs_us = eye_h(:,trial_no_cs_us);
eye_h_cs_only = eye_h(:,trial_no_cs_only);
median_cs_us = nanmedian(eye_h_cs_us,2);
median_cs_only = nanmedian(eye_h_cs_only,2);

eyeB_st.trial_no_cs_us = trial_no_cs_us;
eyeB_st.trial_no_cs_only = trial_no_cs_only;
eyeB_st.eye_h_cs_us = eye_h_cs_us;
eyeB_st.eye_h_cs_only = eye_h_cs_only;
eyeB_st.median_cs_us = median_cs_us;
eyeB_st.median_cs_only = median_cs_only;

if is_plot
    
    fig1 = figure('color',[1 1 1],'position',fig_position);
    ax1 = subplot(4,4,1);
    hold on;
%     TTT_eyeb100_5_1_plot_eyeB_st(eyeB_st, ax1);
%     TTT_eyeb100_5_2_plot_eyeB_st(eyeB_st, ax1, 1);
    TTT_eyeb100_5_3_plot_eyeB_st(eyeB_st, ax1, 1);
    title([eyeB_st.mouse_id ', Day' num2str(eyeB_st.date_str)]);

    xx_like = [1:length(ud.likelihood)]/vi_hz;
    ax2 = subplot(4,4,(1:4)+4); %cla;
    plot(xx_like,ud.likelihood,'color',clr_detection(1,:)); hold on; ylabel('Upper lid likelihood'); ylim([0 1]);
    ax2 = subplot(4,4,(1:4)+8); %cla;
    plot(xx_like,ld.likelihood,'color',clr_detection(2,:)); hold on; ylabel('Lower lid likelihood'); ylim([0 1]);
    ax2 = subplot(4,4,(1:4)+12); %cla;
    plot(xx_like,cd.likelihood,'color',clr_detection(4,:)); hold on; ylabel('Closed lid likelihood');ylim([0 1]);
        
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
num_detection = 4;
add = 1; %python index starts with 0 (1 for matlab).
for i=1:num_detection
    detection_names{i} = raw{2,3*(i-1)+2};
    dlc_st.(detection_names{i}).color = clr_pupil(i,:);
    dlc_st.(detection_names{i}).x = [raw{4:end,3*(i-1)+2}]'+add;
    dlc_st.(detection_names{i}).y = [raw{4:end,3*(i-1)+3}]'+add;
    dlc_st.(detection_names{i}).likelihood = [raw{4:end,3*(i-1)+4}]';
end

end
