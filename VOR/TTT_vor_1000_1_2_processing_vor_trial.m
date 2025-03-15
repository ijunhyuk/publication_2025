function TTT_vor_1000_1_2_processing_vor_trial(data_fo, group_fo, mouse_fo, is_overwrite_vor_trial)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calrib_angle = 20; %angle for calibration. 20 degree. (+-10)

if isempty(data_fo) || isempty(group_fo) || isempty(mouse_fo)
    data_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
    % mouse_fo = 'm792_test';
    mouse_fo = 'm792_etc';
end

% dlc_suffix = 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_100000';
% dlc_suffix = 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_171000';
dlc_suffix = '_DLC';

% % filename_suffix = '_trial_1_VORcam_org200Hz';
% % filename_suffix = '_trial_1_VORcam_org200Hz_saved40';
% filename_suffix = '_trial_1_VORcam_org200Hz_saved40Hz';

clr_pupil = [
    11 8 134%pupil left
    126 3 170%right
    206 70 118%upper
    248 150 66%bottom
    239 249 30%CR
    ]/255;
v_fr = 200; %video frame rate.
filter_window_pupil_size = 1; %sec. pupil cannot change quickly.
filter_window_nan_fill = 0.1; %sec. to compensate the period where liklihood is less than threshold.(ex, when eye blink)
% filter_window_ang_vel = 1; %sec. to remove velocity noise and also saccades.
filter_hz_multiply = 4; %filter for x,y position of pupil. stim_hz x n times
likelihood_thr = 0.90; %if likelihood is less than this, it will be marked as NaN.
poor_DLC_percent = 20; %ex) 10 %. if the amount of poor detection is greater than this value, analysis is not proceed further.
saccade_ang_vel_thr = 50; %40 degree/sec. (Galliano, 2013, cell reports). 20220928. reduced to 20 because the fastest vestibular reflex
%is 20 degree/sec.(when 1hz 5degree VOR).
remove_around_saccade = 0.05; % if velocity exceed 40 degree/sec, then also remove before/after 30ms.
ni_sub_sampling_fr = 200; %hz. NI has too big fr (100000). Need to do subsampling.
plot_opposite_direction = 1; %if set 1, VOR response will be the same direction to table rotation. it will be easier to see gain decrease.
peak_gain_avg_time_window = 0.02; %sec. to get peak gain smoothed.

vor_ext = 'mp4';
% is_overwrite_vor_trial = 1;
fig_size = [100 100 1600 1800];

radius_excel_prefix = 'radius_';
ori_mp4_name = '_org200Hz';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t_total = tic;
%video check and make all mp4 lists.
check_sub_dir = 1;
file_list = TTTH_search_all_files([data_fo filesep mouse_fo], check_sub_dir, ['*' ori_mp4_name '*.' vor_ext]);
disp(['Total ' num2str(length(file_list)) ' video files (*.' vor_ext ') were detected.']);
delete_video_idx = []; %to exclude pupil-measure mp4 videos.
for f=1:length(file_list) %f=24
    cur_file = file_list{f};
    [fo,fi,ext] = fileparts(cur_file);
    
    if contains(fi, 'pupil_images')
        delete_video_idx(end+1) = [f];
    end
    idx = findstr(fi,'_');
    if contains(fi,'_saved')
        hz_idx = idx(end-1);
    else
        hz_idx = idx(end);
    end
    if ~strcmp(fi(hz_idx+4:hz_idx+6),num2str(v_fr))  %if the video is not properly recorded.
        disp(['Video Hz is wrong!!! ' cur_file]);
    end
end

file_list(delete_video_idx) = [];
disp(['Total ' num2str(length(file_list)) ' video files (*.' vor_ext ') were detected.']);
for fi=1:length(file_list) %fi = 24;
    close all;
    warning off;
    
    cur_file = file_list{fi};    
    disp(['Processing.. ' num2str(fi) '/' num2str(length(file_list)) '...' cur_file]);
    [fo,fn,ext] = fileparts(cur_file);
    token = strsplit(fo,filesep);
    exp_fo = token{end-1};
    trial_fo = token{end};
    mat_save_name = [data_fo filesep mouse_fo filesep exp_fo filesep trial_fo];
    title_str = [mouse_fo filesep exp_fo filesep trial_fo];
    
    if exist([mat_save_name '_processed.mat']) || exist([mat_save_name '_processed_PoorDLC.mat'])
        if ~is_overwrite_vor_trial
            disp(['Skip already existing file: ' cur_file]);
            continue;
        else
            disp(['Overwrite already existing file: ' cur_file]);
        end
    end
    
    idx = findstr(fn,'_');
    if contains(fn,'_saved')
        hz_idx = idx(end-1);
    else
        hz_idx = idx(end);
    end
    filename_suffix = fn(idx(1):end);
    if ~strcmp(fn(hz_idx+4:hz_idx+6),num2str(v_fr)) %if the video is not properly recorded.
        disp(['Video Hz is wrong!!! Skip this Video...' cur_file]);    
        fig1 = figure();
        jpeg_save_name = [mat_save_name '_processing_WrongHz.jpeg'];
        if ~exist(jpeg_save_name)
            saveas(fig1,jpeg_save_name);
        end        
        continue;
    end


    rp_relative_path = {};
    if contains(trial_fo,'_OKR')
        is_vestibular_stim = 0;
        is_visual_stim = 1; %0:VOR, 1:OKR, 2:VVOR
        relative_fo = [mouse_fo filesep exp_fo filesep trial_fo];
        mat_relative_path = [relative_fo filesep 'OKR_trial_1.mat'];
        filename = ['OKR' filename_suffix];        
        video_relative_path = [relative_fo filesep filename '.mp4'];
        csv_relative_path = [relative_fo filesep filename dlc_suffix '.csv'];
%         filterd_csv_relative_path = [relative_fo filesep filename 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_100000_filtered.csv'];
        [filelist_st, rp_relative_path] = TTTH_search_all_files_ver2([data_fo filesep mouse_fo filesep exp_fo], 0, [radius_excel_prefix '*.xlsx'], [mouse_fo filesep exp_fo filesep]);
    elseif contains(trial_fo,'_VOR')
        is_vestibular_stim = 1;
        is_visual_stim = 0; %0:VOR, 1:OKR, 2:VVOR
        relative_fo = [mouse_fo filesep exp_fo filesep trial_fo];
        mat_relative_path = [relative_fo filesep 'VOR_trial_1.mat'];
        filename = ['VOR' filename_suffix];        
        video_relative_path = [relative_fo filesep filename '.mp4'];
        csv_relative_path = [relative_fo filesep filename dlc_suffix '.csv'];
        % filterd_csv_relative_path = [relative_fo filesep filename 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_100000_filtered.csv'];
        [filelist_st, rp_relative_path] = TTTH_search_all_files_ver2([data_fo filesep mouse_fo filesep exp_fo], 0, [radius_excel_prefix '*.xlsx'], [mouse_fo filesep exp_fo filesep]);
    elseif contains(trial_fo,'_VVOR')
        is_vestibular_stim = 1;
        is_visual_stim = 2; %0:VOR, 1:OKR, 2:VVOR
        relative_fo = [mouse_fo filesep exp_fo filesep trial_fo];
        mat_relative_path = [relative_fo filesep 'VVOR_trial_1.mat'];
        filename = ['VVOR' filename_suffix];        
        video_relative_path = [relative_fo filesep filename '.mp4'];
        csv_relative_path = [relative_fo filesep filename dlc_suffix '.csv'];
        % filterd_csv_relative_path = [relative_fo filesep filename 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_100000_filtered.csv'];
        [filelist_st, rp_relative_path] = TTTH_search_all_files_ver2([data_fo filesep mouse_fo filesep exp_fo], 0, [radius_excel_prefix '*.xlsx'], [mouse_fo filesep exp_fo filesep]);
    end
    
    if ~isempty(rp_relative_path) && exist([data_fo filesep rp_relative_path{1}])
        rp_relative_path = rp_relative_path{1};
    else
        disp(['#Skip: radius_pupil.xlsx does not exists!! ..' [data_fo filesep mouse_fo filesep exp_fo]]);
        continue;
    end
    clearvars 'vor_trial';
    
    %load vor structure
    temp = load([data_fo filesep mat_relative_path]);
    vor_s = temp.vor_s;
    
    [exp_type, exp_hz, exp_date_str] = TTT_vor_1001_1_1_identify_exp_type(vor_s, trial_fo);
    vor_trial.exp_type = exp_type;
    vor_trial.exp_hz = exp_hz;
    vor_trial.exp_date_str = exp_date_str;
    
    filter_hz_ang_vel = exp_hz*filter_hz_multiply;
    vor_trial.protocol_param.table_rotation_command = vor_s.table_rotation_command;
    vor_trial.protocol_param.cam_command = vor_s.cam_command;
    vor_trial.protocol_param.clearPath_parameters = vor_s.clearPath_parameters;
    
    
    %load Rp excel file
    tb_rp = readtable([data_fo filesep rp_relative_path]);
    rp_arr = [];
    for i=1:size(tb_rp,1)
        pupil_size = (tb_rp{i,3}+tb_rp{i,5})/2;
        rp = abs(tb_rp{i,4}-tb_rp{i,6})/sin(calrib_angle*pi/180);
        rp_arr(i,:) = [pupil_size, rp];
    end
    
    %load dlc results.
    dlc_st = parse_dlc_csv([data_fo filesep csv_relative_path], clr_pupil);
    
    %commented. no use.
%     dlc_st = TTT_vor_1000_10_1_filter_dlc(dlc_st, likelihood_thr); % filter sudden mis-detections.
    
    %plots
    fig1 = figure('color',[1 1 1], 'position', fig_size);
    xx = [1:length(dlc_st.pupil_left.x)]/v_fr; %sec
    m=10; n=1; s=1;
    
    %get example image from the video
    vor_trial.video_relative_path = video_relative_path;
    vr = VideoReader([data_fo filesep video_relative_path]);
    frame_no = 1;
    exam_img = readFrame(vr);
    exam_img = read(vr,frame_no);
    vor_trial.exam_img = exam_img;
    
    %plot
    % s=s+1;
    subplot(m,4,1);
    imshow(exam_img); hold on;
    pt = dlc_st.pupil_left; plot(pt.x(frame_no), pt.y(frame_no),'.','color',pt.color,'markersize',15);
    pt = dlc_st.pupil_right; plot(pt.x(frame_no), pt.y(frame_no),'.','color',pt.color,'markersize',15);
    % pt = dlc_st.pupil_upper; plot(pt.x(frame_no), pt.y(frame_no),'.','color',pt.color,'markersize',10);
    % pt = dlc_st.pupil_lower; plot(pt.x(frame_no), pt.y(frame_no),'.','color',pt.color,'markersize',10);
    pt = dlc_st.cr; plot(pt.x(frame_no), pt.y(frame_no),'x','color',pt.color,'markersize',5);
    
    %plot regression
    cur_ax = subplot(m,4,3);
    [r, p, regress_b, reg_x, reg_y, p_scatter, p_reg_line] = TTT_vor_1000_5_1_plot_rp(cur_ax, rp_arr);
        
    vor_trial.Rp.pupil_rp = table(rp_arr(:,1),rp_arr(:,2),'VariableNames',{'pupil_diameter','pupil_radius'});
    vor_trial.Rp.regression_b = regress_b;
    
    %calculate pupil parameters
    pupil_center = (dlc_st.pupil_left.x + dlc_st.pupil_right.x)/2;
    if plot_opposite_direction %this option is just for plot in inverted way between table rotation & eye rotation.
        pupil_move = pupil_center-dlc_st.cr.x; %actual pupil movement (in pixel).
    else
        pupil_move = dlc_st.cr.x-pupil_center; %actual pupil movement (in pixel).
    end
    vor_trial.pupil_move = pupil_move;
    
    %plot x pixel position
    s=s+1; subplot(m,n,s);
    plot(xx, dlc_st.pupil_left.x,'color',dlc_st.pupil_left.color);
    box off; hold on;
    plot(xx, dlc_st.pupil_right.x,'color',dlc_st.pupil_right.color);
    plot(xx, pupil_center,'color',[0 0 0], 'linewidth',1);
    plot(xx, dlc_st.cr.x,'color',dlc_st.cr.color*0.7);
    xlabel('(sec)'); ylabel('Pixel Position (x)'); legend({'pupil_left_x','pupil_right_x','Pupil Center_x','CR_x'},'interpreter','none');
    title([title_str]);

    %plot y pixel position
    s=s+1; subplot(m,n,s);
    plot(xx, dlc_st.pupil_left.y,'color',dlc_st.pupil_left.color);
    box off; hold on;
    plot(xx, dlc_st.pupil_right.y,'color',dlc_st.pupil_right.color);
    plot(xx, dlc_st.cr.y,'color',dlc_st.cr.color*0.7);
    xlabel('(sec)'); ylabel('Pixel Position (y)'); legend({'pupil_left_y','pupil_right_y','CR_y'},'interpreter','none');
    
    
    bad_detection_idx = (dlc_st.cr.likelihood < likelihood_thr);
    pupil_move_filtered = pupil_move;
    pupil_move_filtered(bad_detection_idx) = nan;
    %fill the nan x 3 times.
    pupil_move_filtered = fillmissing(pupil_move_filtered,'spline');
    pupil_move_filtered = smooth(pupil_move_filtered,filter_window_nan_fill*v_fr);
    %test:  find(isnan(pupil_move_filtered))/v_fr
    
    %low pass filter 20Hz (to remove saccades).
    if ~isempty(find(~isnan(pupil_move_filtered)))
        pupil_move_filtered = lowpass(pupil_move_filtered,filter_hz_ang_vel,v_fr);
    end
    % figure();
    % plot(xx,pupil_move_filtered); hold on;
    % plot(xx,pupil_move_filtered,'r'); hold on;
    % [pupil_move_filtered] = TTT_a24_2_ver1_low_pass_filter(pupil_move_filtered, v_fr, filter_pupil_move_hz, 2);
    % [pupil_move_filtered] = TTT_a24_2_ver1_low_pass_filter(pupil_move_filtered, v_fr, 1, 2);
    % [pupil_move_filtered] = TTT_a24_3_ver1_band_pass_filter(pupil_move_filtered', v_fr, [0.2 2], 2);
    
    vor_trial.pupil_move_filtered = pupil_move_filtered;
    
    
    %plot
    s=s+1; subplot(m,n,s);
    plot(xx, pupil_move,'color',[0 0 0]);
    box off; hold on;
    plot(xx, pupil_move_filtered,'color',[0 0 1]);
    xlabel('(sec)'); ylabel('Pupil movement (PupilCenter - CR)');
    legend({'pupil movement','pupil movement filtered'},'interpreter','none');
    
    s=s+1; subplot(m,n,s);
%     yyaxis right;
    plot(xx, dlc_st.pupil_left.likelihood,'-','color',dlc_st.pupil_left.color);
    box off; hold on;
    plot(xx, dlc_st.pupil_right.likelihood,'-','color',dlc_st.pupil_right.color);
    plot(xx, dlc_st.cr.likelihood,'-','color',dlc_st.cr.color*0.7);
    xlabel('(sec)'); ylabel('Detection Likelihood');
    legend({'likelihood-left','likelihood-right','likelihood-cr'},'interpreter','none');
    ylim([0 1]);
    
    pupil_size = dlc_st.pupil_right.x - dlc_st.pupil_left.x;
    %filtering pupil size
    pupil_size_filt = medfilt1(pupil_size,filter_window_pupil_size*v_fr,'omitnan','truncate');
    % yyaxis right; plot(xx,pupil_size_filt,'b'); hold on;
    vor_trial.pupil_size_filt = pupil_size_filt;
    
    %calculate Rp depends on pupil diameter
    radius_pupil = TTTH_v2_3_0_regression_estimate(regress_b, pupil_size_filt);
    % yyaxis right; plot(xx,radius_pupil,'color',[1 1 1]); hold on;
    vor_trial.radius_pupil = radius_pupil;
    
    %plot angle velocity histogram in upper row
    %%%     p_diff_ang = asind(p_diff_px./radius_pupil(2:end));
    cur_ax = subplot(m,4,2);
    TTT_vor_1000_11_1_hist_eye_velocity(cur_ax, dlc_st, radius_pupil, v_fr);
    
    %plot
    s=s+1; subplot(m,n,s);
%     plot(xx, pupil_size,'color',[0 0 0]);
    box off; hold on;
    plot(xx, pupil_size_filt,'color',[0 0 1]);
    plot(xx, radius_pupil,'color',[1 0 0]);
    xlabel('(sec)'); ylabel('Pupil diameter (px)'); legend({'pupil size(filtered)','Rp'},'interpreter','none');
    ylim([0 200]);
    
    % Stop if DLC detection is poor.    
    hood_left = dlc_st.pupil_left.likelihood;
    hood_right = dlc_st.pupil_right.likelihood;
    hood_cr = dlc_st.cr.likelihood;
    data_len = length(hood_left);
    poor_percent_left = length(find(hood_left < likelihood_thr))/data_len*100;
    poor_percent_right = length(find(hood_right < likelihood_thr))/data_len*100;
    poor_percent_cr = length(find(hood_cr < likelihood_thr))/data_len*100;
    
    f_left = poor_percent_left > poor_DLC_percent;
    f_right = poor_percent_right > poor_DLC_percent;
    f_cr = poor_percent_cr > poor_DLC_percent;
    if f_left || f_right || f_cr
        disp(['Poor DLC detection!! No more proceessing. Poor percent (' ...
            'pupil left: ' num2str(round(poor_percent_left,1)) '%, ' ...
            'pupil right: ' num2str(round(poor_percent_right,1)) '%, ' ...
            'pupil CR: ' num2str(round(poor_percent_cr,1)) '%, ' ...
            ')']);
        jpeg_save_name = [mat_save_name '_processing_PoorDLC.jpeg'];
        if ~exist(jpeg_save_name)
            saveas(fig1,jpeg_save_name);
        end
%         save([mat_save_name '_processed_PoorDLC.mat'],'vor_trial');
        save([mat_save_name '_processed.mat'],'vor_trial');
        continue;
    end
    
    p_diff_px = diff(pupil_move_filtered);
    % Eye position (Ep) = arcsin [(P1-CR1)-(P2-CR2)/Rp].
    [p_diff_ang] = TTT_vor_1000_12_1_convert_px_to_ang_value(p_diff_px, radius_pupil(2:end));
%     p_diff_ang = asind(p_diff_px./radius_pupil(2:end));
    p_pos_ang = cumsum([0; p_diff_ang]); %starging angle is 0.
    vor_trial.p_pos_ang = p_pos_ang; %instant angle movement values for every 1/200 = 5 ms.
    
    p_ang_vel = p_diff_ang*v_fr;
    p_ang_vel = [p_ang_vel(1); p_ang_vel];
    vor_trial.p_ang_vel = p_ang_vel; %instant angle velocity for every 1/200 = 5 ms.
    
    p_ang_vel_filterd = p_ang_vel;
    %remove speed over than +-40 degree/sec.
    sac_mask = (p_ang_vel > saccade_ang_vel_thr) | (p_ang_vel < -1*saccade_ang_vel_thr);
    %expand sac_mask before/after remove_around_saccade.
    r_sac = round(remove_around_saccade*v_fr)-1; %number of elements to remove.
    diff_mask = diff(sac_mask);
    mask_on = find(diff_mask==1);
    mask_off = find(diff_mask==-1);
    for i=1:length(mask_on)
        sac_mask(max(mask_on(i)-r_sac,1):mask_on(i)) = 1;
    end
    for i=1:length(mask_off)
        sac_mask(mask_off(i)+1:min(mask_off(i)+r_sac,length(sac_mask))) = 1;
    end
    p_ang_vel_filterd(sac_mask) = nan;
    
    % p_ang_vel_filterd = fillmissing(p_ang_vel_filterd,'spline');
    p_ang_vel_filterd = fillmissing(p_ang_vel_filterd,'linear');
    % find(isnan(p_ang_vel_filterd))
    p_ang_vel_filterd = lowpass(p_ang_vel_filterd,filter_hz_ang_vel,v_fr,'Steepness',0.99);
    vor_trial.p_ang_vel_filterd = p_ang_vel_filterd;
    
    % p_ang_vel_filterd = medfilt1(p_ang_vel_filterd,filter_window_ang_vel*v_fr,'omitnan','truncate');
    % p_ang_vel_filterd = smooth(p_ang_vel_filterd,filter_window_ang_vel*v_fr);
    % plot(xx(2:end),p_diff_ang); hold on;
    % plot(xx(2:end),p_move_ang_vel); hold on;
    % plot(xx(1:end),p_pos_ang); hold on;
    
    
    s=s+1; subplot(m,n,s); %cla
    plot(xx, p_pos_ang,'color',[0 0 1]);
    box off; hold on;
    xlabel('(sec)'); ylabel('Pupil angle (degree)');
    yyaxis right;
    plot(xx, p_ang_vel,'color',[0.5 0.5 0.5]); hold on;
    plot(xx, p_ang_vel_filterd,'-','color',[1 0 0],'linewidth',2);
    ylim([-saccade_ang_vel_thr saccade_ang_vel_thr]); ylabel('Pupil Velocity (degree/sec)');
    legend({'pupil angle','Pupil Velocity','Pupil Velocity(filtered)'},'interpreter','none');
    
    %get vestibular stim or visual stim.
    table_pos = vor_s.table_rotation_result.table_pos;
    vis_pos = vor_s.vis_command.pre_recorded_table_pos;
    cmd_fr = vor_s.table_rotation_command.cmd_freq;
%     exp_type = vor_s.exp_type;
    %subsampling
    space = round(cmd_fr/ni_sub_sampling_fr);
    new_cmd_fr = cmd_fr/space;
    table_pos = table_pos(1:space:end);
    vis_pos = vis_pos(1:space:end);
    
    %filter minimum
    table_pos = smooth(table_pos,3);
    vis_pos = smooth(vis_pos,3);
    vis_pos = vis_pos*-1; %the original recording is inverted.
    vor_trial.vis_pos = vis_pos;
    vor_trial.table_pos = table_pos;
    
    ni_xx = (1:length(table_pos))/new_cmd_fr;
    table_vel = diff(table_pos)*new_cmd_fr;
    table_vel = [table_vel(1); table_vel];    
    
    table_vel = lowpass(table_vel,filter_hz_ang_vel,v_fr,'Steepness',0.99);
    
    if is_visual_stim==1
        vis_vel = diff(vis_pos)*new_cmd_fr;
        vis_vel = [vis_vel(1); vis_vel];
        vis_vel = lowpass(vis_vel,filter_hz_ang_vel,v_fr,'Steepness',0.99);
    else
        vis_vel = zeros(length(table_vel),1);
    end
    vor_trial.vis_vel = vis_vel;
    vor_trial.table_vel = table_vel;
    
    
    % checklee. 20220928. Now I don't have
    % vor_s.table_rotation_command.t_run_extra property but delete this in real experiment.
    if ~isfield(vor_s.table_rotation_command, 't_run_extra')
        vor_s.table_rotation_command.t_run_extra = 1;
    end
    
    prefix_time = vor_s.table_rotation_command.t_head + vor_s.table_rotation_command.info_adjust_s{2} + vor_s.table_rotation_command.t_run_extra;
    run_time = vor_s.table_rotation_command.t_run;
    suffix_time = vor_s.table_rotation_command.info_adjust_e{2} + vor_s.table_rotation_command.t_tail;
    (prefix_time + run_time + suffix_time)*new_cmd_fr;
    
    %make smooth sig to detect peaks
    stim_freq = vor_s.table_rotation_command.zigzag_freq;
    
    vor_trial.vis_vel_interpol = [];
    vor_trial.table_vel_interpol = [];
    
    if is_vestibular_stim==1
        %plot vestibular stim with eye vel.
        s=s+1; subplot(m,n,s); %cla
        plot(ni_xx, table_pos,'color',[0 0 0]); 
        box off; hold on;
        plot(ni_xx, table_vel,'color',[0 0 1]);
        plot(xx, p_ang_vel_filterd,'color',[1 0 0]);
        xlabel('(sec)'); ylabel('Angle Velocity (degree/sec)'); ylim([-40 40]);
        legend({'table pos.','table vel.','pupil vel.'},'interpreter','none');
        
        %gain for eye vel/table vel
        table_vel_interpol = interp1(ni_xx,table_vel,xx,'linear','extrap')';
        cur_vel = table_vel_interpol;
        cur_vel_str = 'table';
        
        vor_trial.table_vel_interpol = table_vel_interpol;
    end
    
    if is_visual_stim==1
        %plot visual stim with eye vel.
        s=s+1; subplot(m,n,s); %cla
        plot(ni_xx, vis_pos,'color',[0 0 0]); 
        box off; hold on;
        plot(ni_xx, vis_vel,'color',[0 0 1]);
        plot(xx, p_ang_vel_filterd,'color',[1 0 0]);
        xlabel('(sec)'); ylabel('Angle Velocity (degree/sec)'); ylim([-40 40]);
        legend({'vis stim pos.','vis stim vel.','pupil vel.'},'interpreter','none');
        
        %gain for eye vel/Vis vel
        vis_vel_interpol = interp1(ni_xx,vis_vel,xx,'linear','extrap')';
        cur_vel = vis_vel_interpol;
        cur_vel_str = 'vis stim';    
        
        vor_trial.vis_vel_interpol = vis_vel_interpol;
    end
    
    gain = p_ang_vel_filterd./cur_vel;
    bonus_time = 0.1; %give 0.1 sec more to detect peak at the end.
    run_idx = round(prefix_time*new_cmd_fr+1):round((prefix_time + run_time + bonus_time)*new_cmd_fr);
    
    %smooth the signal to get phase. smoothing signal with half period (1/stim_freq)/2
    sm_sig = smooth(cur_vel,(1/stim_freq)/2*new_cmd_fr);
    sm_run_stim_vel = sm_sig(run_idx);
    sm_ang_vel = smooth(vor_trial.p_ang_vel_filterd,(1/stim_freq)/2*new_cmd_fr);
    sm_run_ang_vel = sm_ang_vel(run_idx);
    
    enhanced_sm_run_stim_vel = sm_run_stim_vel;
    enhanced_sm_run_stim_vel = smooth(enhanced_sm_run_stim_vel,(1/stim_freq)/2*new_cmd_fr);
    sig_d = enhanced_sm_run_stim_vel;
    sig_d(sig_d < 0) = 0;
    [max_pks,max_locs] = findpeaks(sig_d); %local maximas
    sig_d = -enhanced_sm_run_stim_vel;
    sig_d(sig_d < 0) = 0;
    [min_pks,min_locs] = findpeaks(-enhanced_sm_run_stim_vel); %local minimas
    run_gain = gain(run_idx);
    all_peak_idx = [max_locs; min_locs]; %all of the peak index.
    all_peak_idx = sort(all_peak_idx); %sorting.
    peak_gains = run_gain(all_peak_idx);
    peak_gains_smoothed = [];
    n_point = round(peak_gain_avg_time_window/2*new_cmd_fr);
    for p=1:length(all_peak_idx)
        peak_sm_idx = max(all_peak_idx(p)-n_point,1):min(all_peak_idx(p)+n_point-1,size(run_gain,1));
        peak_gains_smoothed(p,1) = median(run_gain(peak_sm_idx));
    end
    
    xx_peak_pos = (run_idx(1)-1+all_peak_idx)/new_cmd_fr;
    xx_run = run_idx/new_cmd_fr;
    gain_median = nanmedian(peak_gains_smoothed);
    
    vor_trial.gain_xy = [xx_run', run_gain];
    vor_trial.peak_gain_xy = [xx_peak_pos, peak_gains];
    vor_trial.peak_gain_smoothed_xy = [xx_peak_pos, peak_gains_smoothed];
    vor_trial.gain_median = gain_median;

    %plot
    s=s+1; subplot(m,n,s); %cla
    plot(xx_peak_pos, peak_gains,'o','color',[1 0 0]);
    box off; hold on;
    plot([xx(1),xx(end)], [gain_median gain_median],'-','color',[1 0 0]);
    xlabel('(sec)'); ylabel(['Gain (eye vel/' cur_vel_str ' vel)']); ylim([-1.5 1.5]);
    yyaxis right;
    plot(xx, cur_vel,'color',[0.5 0.5 1]);
    box off; hold on; ylim(['auto']);
    plot(ni_xx(run_idx), sm_run_stim_vel,'-','color',[0.5 0.5 0.5]);
    plot(ni_xx(run_idx), sm_run_ang_vel,'-','color',[1 0.5 0.5]);
    legend({'Gain',['Median Gain= ' num2str(gain_median)],[cur_vel_str ' vel'],['phase ' cur_vel_str],['phase pupil vel']},'interpreter','none','Location','southeast');

    title([title_str ', (n_peak_gains = ' num2str(size(peak_gains,1)) ')']);
    
    camclk_freq = vor_trial.protocol_param.cam_command.camclk_freq;
    period_sz = round(camclk_freq/exp_hz); %period size. ex) 0.25Hz -> 800 sample points.
    n_periods = round(length(sm_run_ang_vel)/period_sz);
    
    %plot
    s=s+1; subplot(m,n,s); %cla
    p_idx = [1:period_sz];
    p_xx = p_idx/camclk_freq;
    p_cur_vel_arr = [];
    p_ang_vel_arr = [];
    for p=1:n_periods
        cur_p_idx = p_idx + period_sz*(p-1);
        p_cur_vel = sm_run_stim_vel(cur_p_idx);
        p_ang_vel = sm_run_ang_vel(cur_p_idx);
        
        plot(p_xx, p_cur_vel,'--','color',[0.5 0.5 0.5]); hold on;
        plot(p_xx, p_ang_vel,'--','color',[1 0 0]); hold on;
        
        p_cur_vel_arr = [p_cur_vel_arr p_cur_vel];
        p_ang_vel_arr = [p_ang_vel_arr p_ang_vel];
        
    end
    p_cur_vel_median = nanmedian(p_cur_vel_arr,2);
    p_ang_vel_median = nanmedian(p_ang_vel_arr,2);
    dark = 1; %make median color dark
    plot(p_xx, p_cur_vel_median,'color',[0.5 0.5 0.5]*dark,'linewidth',3); hold on;
    box off; hold on; ylim(['auto']);
    plot(p_xx, p_ang_vel_median,'color',[1 0 0]*dark,'linewidth',3); hold on;
    legend({['phase ' cur_vel_str],['phase pupil vel']},'interpreter','none','Location','southeast');

    
%     plot(p_ang_vel_median); hold on;
    temp = smooth([p_ang_vel_median;p_ang_vel_median;p_ang_vel_median],(1/stim_freq)/2*new_cmd_fr);
    sz = length(p_ang_vel_median);
    p_ang_vel_median_smoothed = temp(sz+1:sz*2);
%     plot(p_ang_vel_median_smoothed);
    vor_trial.p_cur_vel_median = p_cur_vel_median;
    vor_trial.p_ang_vel_median = p_ang_vel_median;
    vor_trial.p_ang_vel_median = p_ang_vel_median_smoothed;
    
    [~,p_vel_idx_max] = max(p_cur_vel_median);
    [~,p_ang_idx_max] = max(p_ang_vel_median_smoothed);
    [~,p_vel_idx_min] = min(p_cur_vel_median);
    [~,p_ang_idx_min] = min(p_ang_vel_median_smoothed);
    
%     [~,p_vel_idx_max] = max(p_cur_vel_median);
%     [~,p_ang_idx_max] = max(p_ang_vel_median);
%     [~,p_vel_idx_min] = min(p_cur_vel_median);
%     [~,p_ang_idx_min] = min(p_ang_vel_median);
    
%cla
    y_lim = ylim;
    y_pos = y_lim(2)*1.2;
    plot(p_xx(p_vel_idx_max),y_pos,'*','color',[0.5 0.5 0.5]);
    plot(p_xx(p_ang_idx_max),y_pos,'*','color',[1 0 0]);
    diff_idx_max = p_ang_idx_max - p_vel_idx_max; %Plus value means pupil vel is delayed.
    plot(p_xx(p_vel_idx_min),y_pos,'x','color',[0.5 0.5 0.5]);
    plot(p_xx(p_ang_idx_min),y_pos,'x','color',[1 0 0]);
    diff_idx_min = p_ang_idx_min - p_vel_idx_min; %Plus value means pupil vel is delayed.
    
    phase_diff_max = diff_idx_max*360/(new_cmd_fr/stim_freq);
    if phase_diff_max <= -180; phase_diff_max = phase_diff_max + 360; end
    if phase_diff_max > 180; phase_diff_max = phase_diff_max - 360; end
    phase_diff_min = diff_idx_min*360/(new_cmd_fr/stim_freq);
    if phase_diff_min <= -180; phase_diff_min = phase_diff_min + 360; end
    if phase_diff_min > 180; phase_diff_min = phase_diff_min - 360; end
    
    vor_trial.phase_diff_max = phase_diff_max;
    vor_trial.phase_diff_min = phase_diff_min;
    
    title([title_str ', (*)smoothed local maxima, (x)minima, Max val Phase diff(degree): ' ...
        num2str(phase_diff_max) ', Min phase diff: ' num2str(phase_diff_min)]);    
    
    saveas(fig1,[mat_save_name '_processing.jpeg']);
    save([mat_save_name '_processed.mat'],'vor_trial');
end

disp(['All done!!! for ' num2str(length(file_list)) ' video files (*.' vor_ext ')']);
toc(t_total);
end

function dlc_st = parse_dlc_csv(csv_path, clr_pupil)
    [~,~,raw] = xlsread(csv_path);
    num_detection = 5;
    add = 1; %python index starts with 0 (1 for matlab).
    for i=1:num_detection
        detection_names{i} = raw{2,3*(i-1)+2};                
        dlc_st.(detection_names{i}).color = clr_pupil(i,:);
        dlc_st.(detection_names{i}).x = [raw{4:end,3*(i-1)+2}]'+add;
        dlc_st.(detection_names{i}).y = [raw{4:end,3*(i-1)+3}]'+add;
        dlc_st.(detection_names{i}).likelihood = [raw{4:end,3*(i-1)+4}]';
    end
    
end