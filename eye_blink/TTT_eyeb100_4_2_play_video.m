function [] = TTT_eyeb100_4_2_play_video()
%%
% 20231016. Joon.
% Generate all trial videos in the given folder.
warning off;

video_start_time = -0.5;
is_save_video = 1;
fig_size = [100 100 500 400];

IBI = 1.2;
% rec_freq = 100; %video is actually 100 Hz.
rec_freq = 280; %video is actually 280 Hz.
camclk_on_dur = 2; %sec.

mark_DLC = 1;
% dlc_clr = [
%     1 0 0
%     0 1 0
%     1 1 0
%     0 0 1
%     ];
dlc_clr = [
    1 1 0 %upper lid
    1 0 0 %lower lid
    1 1 0 %CR
    1 0.5 0 %full close   
    ];

dlc_body_plot = [1 1 0 1]; % Plot the point if 1. No plot if 0.
likelihood_thr = 0.7;

dropbox_fo = 'G:\Dropbox_joon\Dropbox (HMS)';
% dropbox_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';

video_fo_arr = {};
% video_fo_arr{end+1} = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\WildType\m1067-m1070\day2'];
video_fo_arr{end+1} = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO\batch2\day1_sess3'];

% trial_no_arr = [1:20 33 57]; %if empty, all trials.

% video_names = {'B1_20231101_090349.mp4'}; %example: {'B1_20231013_151750.mp4', 'B2_20231013_151750.mp4'} if empty, all videos.
% trial_no_arr = [101]; %if empty, all trials.
% video_names = {'B2_20231101_090349.mp4'}; %example: {'B1_20231013_151750.mp4', 'B2_20231013_151750.mp4'} if empty, all videos.
% trial_no_arr = [78]; %if empty, all trials.
% video_names = {'B3_20231101_090349.mp4'}; %example: {'B1_20231013_151750.mp4', 'B2_20231013_151750.mp4'} if empty, all videos.
% trial_no_arr = [96]; %if empty, all trials.

% video_names = {'B4_20230727_135931.mp4'}; %example: {'B1_20231013_151750.mp4', 'B2_20231013_151750.mp4'} if empty, all videos.
% trial_no_arr = [37]; %if empty, all trials.
% video_names = {'B4_20230720_120903.mp4'}; %example: {'B1_20231013_151750.mp4', 'B2_20231013_151750.mp4'} if empty, all videos.
% trial_no_arr = [49]; %if empty, all trials.
video_names = {'B1_20230720_120903.mp4'}; %example: {'B1_20231013_151750.mp4', 'B2_20231013_151750.mp4'} if empty, all videos.
trial_no_arr = [13]; %if empty, all trials.

analysis_fo = 'analysis';

%%
for vf = 1:length(video_fo_arr)
    video_fo = video_fo_arr{vf};
    
    save_video_fo = [video_fo '\' analysis_fo];
    
    %get sess_info_*.mat
    sess_info_file = TTTH_search_all_files(video_fo, 0, 'sess_info_*.mat');
    mat_path = sess_info_file{1};
    
    video_path_arr = {};
    if ~isempty(video_names)
        for i=1:length(video_names)
            video_path_arr{end+1,1} = [video_fo filesep video_names{i}];
        end
    else
        file_list = TTTH_search_all_files(video_fo, 0, '*.mp4');
        for i=1:length(file_list)
            if ~contains(lower(file_list{i}), 'puff_test')
                video_path_arr{end+1,1} = file_list{i};
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %%
    dlc_path_arr = {};
    if mark_DLC
        for i=1:length(video_path_arr)
            video_path = video_path_arr{i};
            [fo,fi,ext] = fileparts(video_path);
            dlc_path = [fo filesep fi '_DLC.csv'];
            if exist(dlc_path)
                dlc_path_arr{i,1} = dlc_path;
            else
                dlc_path_arr{i,1} = [];
                disp(['Cannot find DLC csv for.. ' video_path]);
            end
        end
    end
    
    for v=1:length(video_path_arr)
        param_mat = load(mat_path);
        dlc_path = dlc_path_arr{v};
        
        video_path = video_path_arr{v};
        [fo,fi,ext] = fileparts(video_path);
        box_str = fi(strfind(fi,'B')+1);
        box_no = str2num(box_str);
        
        tr_id = param_mat.sess_param.trial_ID(:,box_no);
        tr_id_cs_us = find(tr_id==0);
        tr_id_cs_only = find(tr_id==1);
        disp(['cs_only... ']);
        tr_id_cs_only

        if isempty(trial_no_arr)
            trial_no_arr = 1:param_mat.sess_param.ntrials;
        end
        
        for t=1:length(trial_no_arr)
            cccc;
            trial_no = trial_no_arr(t);
            
            if ismember(trial_no, tr_id_cs_only)
                cs_us_str = '_CS_only';
            else
                cs_us_str = '_CSUS';
            end
            
            vi = VideoReader(video_path);
            fig1 = figure('color',[1 1 1],'position',fig_size);
            h=imshow(read(vi,1));
            h_title = title(video_path, 'fontsize',5);
            h_sec = text(100, size(h.CData,1)-30, '-0.50 sec','color',[1 1 1],'fontsize',18);
            hold on;
            
            dlc_info = {};
            if mark_DLC && ~isempty(dlc_path)
                [~,~,raw] = xlsread(dlc_path);
                dlc_info{1} = cell2mat(raw(4:end,2:4));
                dlc_info{2} = cell2mat(raw(4:end,5:7));
                dlc_info{3} = cell2mat(raw(4:end,8:10));
                dlc_info{4} = cell2mat(raw(4:end,11:13));
                
                clearvars p_arr;
                for d=1:length(dlc_info)
                    p_arr(d) = plot(0,0,'.','color',dlc_clr(d,:),'markersize',30);
                end
            end
            
            
            cur_box_seq = param_mat.sess_param.box_seq(trial_no,box_no);
            idx = round(cur_box_seq*IBI*rec_freq);
            US_dur = param_mat.trial_param.US_dur(cur_box_seq);
            CS_dur = param_mat.trial_param.CS_dur(cur_box_seq);
            rec_dur = rec_freq*camclk_on_dur;
            
            [LED_onset, LED_offset, puff_onset, puff_offset] = TTT_eyeb100_2_1_get_timing_sec(param_mat, trial_no);
            
            % frame = read(vi, idx_LED(1)-1); h=imshow(frame);
            % frame = read(vi, idx_LED(1)); h=imshow(frame);
            % frame = read(vi, idx_puff(1)-1); h=imshow(frame);
            % frame = read(vi, idx_puff(1)+1); h=imshow(frame);
            % frame = read(vi, idx_LED(2)); h=imshow(frame);
            % frame = read(vi, idx_LED(2)+1); h=imshow(frame);
            
            
            idx_base = rec_dur*(trial_no-1);
            if is_save_video
                if ~exist(save_video_fo)
                    mkdir(save_video_fo);
                end
                save_video_path = [save_video_fo filesep fi '_trial_' num2str(trial_no) cs_us_str '.mp4'];
                vw = VideoWriter(save_video_path, 'MPEG-4');
                vw.FrameRate = 40;
                vw.open();
            end
            count = 0;
            font_size=18;
            off_color = [1,1,1];
            puff_color = [0,1,0];
            LED_color = [1,1,0];
            h_LED_2 = text(80, 12, 'LED','color',off_color,FontSize=font_size);
            h_LED = text(80, 32, 'OFF','color',off_color,FontSize=font_size);
            h_puff_2 = text(180, 12, 'Puff','color',off_color,FontSize=font_size);
            h_puff = text(180, 32, 'OFF','color',off_color,FontSize=font_size);
            for i=rec_dur*(trial_no-1)+1:rec_dur*(trial_no)
                count = count + 1;
                h_sec.String = [sprintf('%0.2f', count/rec_freq+video_start_time) ' sec'];
                if i == LED_onset
                    % h_LED = text(10, 12, 'LED ON','color','yellow',FontSize=font_size);
                    h_LED.String = 'ON';
                    h_LED.Color=LED_color;
                end
                if i == LED_offset
                    % delete(h_LED);
                    % h_LED = text(10, 12, 'LED OFF','color',[0.7,0.7,0.7],FontSize=font_size);
                    h_LED.String = 'OFF';
                    h_LED.Color=off_color;
                end
                if i == puff_onset
                    % h_puff = text(10, 35, 'Puff ON','color','green',FontSize=font_size);
                    h_puff.String = 'ON';
                    h_puff.Color=puff_color;
                end
                if i == puff_offset
                    % delete(h_puff);
                    % h_puff = text(10, 35, 'Puff OFF','color',[0.7,0.7,0.7],FontSize=font_size);
                    h_puff.String = 'OFF';
                    h_puff.Color=off_color;
                end
                h.CData = read(vi,i);
                
                for d=1:length(dlc_info)
                    cur_p = p_arr(d);
                    cur_dlc = dlc_info{d};
                    like = cur_dlc(i,3);
                    if like >= likelihood_thr && dlc_body_plot(d)==1
                        cur_p.XData = cur_dlc(i,1);
                        cur_p.YData = cur_dlc(i,2);
                    else
                        cur_p.XData = 0;
                        cur_p.YData = 0;
                    end
                    drawnow nocallbacks;
                end
                
                if is_save_video
                    writeVideo(vw,getframe(fig1));
                end
                pause(0.01);
            end
            if is_save_video
                close(vw);
                disp(['Video saved... ' save_video_path]);
            end
            disp(['Done(' num2str(t) '/' num2str(length(trial_no_arr)) ')']);
            
        end
    end
end
disp(['All Finished!!']);
end
