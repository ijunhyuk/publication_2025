function [] = TTT_eyeb100_4_5_example_image_3()
%%
% 20221213. Joon.
% 20240724. from TTT_eyeb100_4_5_example_image_2 --> 3. Allow image_time to be
% multiple.

warning off;

video_start_time = -0.5;
is_save_video = 0;
is_img_adjust = 1; %make it brighter.
img_adjust_in = [0 0.7];
img_adjust_out = [0 1];
fig_size = [100 100 500 400];

is_show_title = 1;
is_show_sec = 1;
is_show_puff = 1;
is_only_show_one_image = 1; % when you want to save one representative image.
% is_only_show_one_image = 0; %
% rect_crop = [40 0 220 180];
rect_crop = [];

% dlc_clr = [
%     1 0 0 %upper lid
%     0 1 0 %lower lid
%     1 1 0 %CR
%     0 0 1 %full close
%     ];
% dlc_clr = [
%     1 1 0 %upper lid
%     0.5 0.5 0 %lower lid
%     1 1 0 %CR
%     0 0 1 %full close
%     ];
dlc_clr = [
    1 1 0 %upper lid
    1 0 0 %lower lid
    1 1 0 %CR
    1 0.5 0 %full close
    ];

dlc_body_plot = [1 1 0 1]; % Plot the point if 1. No plot if 0.
likelihood_thr = 0.7;

dropbox_fo = 'M:\Dropbox (HMS)';
% dropbox_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';

data_search_fo_arr = {};
data_search_fo_arr{end+1} = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data'];
output_fo = [dropbox_fo '\Research_RegehrLAB\Analysis\result_obj\plot_excel'];


% mat_batch_set = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO\eye_blink_batch1-2.mat';
% mouse_ids_ctr = 'm1012,m1013,m1014,m1015,m1023,m1026,m1027';
% mouse_ids_tko = 'm1016,m1017,m1021,m1024,m1025';
% image_times = 0.4; % 0 sec is when LED on. 0.5 sec airpuff on.
% trial_no_arr = 'cs_only';

% mat_batch_set = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO\eye_blink_batch1-2.mat';
% mouse_ids_ctr = 'm1012';
% mouse_ids_tko = 'm1021';
% image_times = [0.4, 0.6]; % 0 sec is when LED on. 0.5 sec airpuff on.
% trial_no_arr = 'cs_us';

% mat_batch_set = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1-2\eye_blink_batch1-2.mat';
% mouse_ids_ctr = 'm961,m965,m1002';
% mouse_ids_tko = 'm962,m963,m964,m1001,m1004';
% image_times = 0.4; % 0 sec is when LED on. 0.5 sec airpuff on.
% trial_no_arr = 'cs_only';

mat_batch_set = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1-2\eye_blink_batch1-2.mat';
mouse_ids_ctr = '';
mouse_ids_tko = 'm963';
image_times = [0.4, 0.6]; % 0 sec is when LED on. 0.5 sec airpuff on.
% trial_no_arr = 'cs_us';
trial_no_arr = 'cs_only';


% trial_no_arr = [91];   % if you set, only this images will be saved.

% target_days = [1,4,6,8]; %days to make jpegs.
% target_days = [1]; %days to make jpegs.
target_days = [9]; %days to make jpegs.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% takes long time.
batch_set = load(mat_batch_set);
batch_set = batch_set.batch_set;

%%
vari = {};

for g=1:2
    if g==1
        ids = strsplit(mouse_ids_ctr,',');
        group_name = 'CTR';
    elseif g==2
        ids = strsplit(mouse_ids_tko,',');
        group_name = 'TKO';
    end
    
    for m=1:length(ids)
        cur_id = ids{m};
        for d=1:length(target_days) %d=1;
            day_no = target_days(d);
            idx = find(ismember({batch_set.mouse_id},{cur_id}) & [batch_set.day_no] == day_no);
            target_st = batch_set(idx);
            if isempty(target_st)
                continue;
            end
            %find the video
            for fo=1:length(data_search_fo_arr)
                v_list = TTTH_search_all_files(data_search_fo_arr{fo},1,[target_st.video_name '.mp4']);
                if ~isempty(v_list)
                    video_path = v_list{1}; %there should only one video list.
                    [video_fo,fi,ext] = fileparts(video_path);
                    break;
                end
            end
            cur_vari = struct();
            cur_vari.video_fo = video_fo;
            cur_vari.video_path = video_path; 
            cur_vari.box_no = target_st.box_no;
            %cur_vari.trial_no_arr = [91];   % if you set, only this images will be saved.
            cur_vari.trial_no_arr = trial_no_arr;
            cur_vari.mark_DLC = 1;
            [fo,fi,ext] = fileparts(cur_vari.video_path);
            str_pos = strfind(fi,'_');
            cur_vari.mat_path = [cur_vari.video_fo '\Sess_Info_' fi(str_pos+1:end) '.mat'];
            cur_vari.dlc_path = [cur_vari.video_fo '\' fi '_DLC.csv'];
            cur_vari.save_video_fo = output_fo;
            cur_vari.file_name_prefix = [group_name '_' cur_id '_day' num2str(day_no)];
            % vari(end+1) = cur_vari;
            vari{end+1} = cur_vari;
        end
    end
end


%%

if is_only_show_one_image
    is_save_video=0;
end

for v=1:length(vari)
    cur_vari = vari{v};
    video_fo=cur_vari.video_fo;
    video_path=cur_vari.video_path;
    trial_no_arr=cur_vari.trial_no_arr;
    mark_DLC=cur_vari.mark_DLC;
    mat_path=cur_vari.mat_path;
    dlc_path=cur_vari.dlc_path;
    save_video_fo=cur_vari.save_video_fo;
    file_name_prefix = cur_vari.file_name_prefix;
    box_no = cur_vari.box_no;
    %%
    param_mat = load(mat_path);
    
    tr_id = param_mat.sess_param.trial_ID(:,box_no);
    tr_id_cs_only = find(tr_id==1);
    tr_id_cs_us = find(tr_id==0);
    if ~isnumeric(trial_no_arr)
        if strcmp(trial_no_arr,'cs_only')
            trial_no_arr = tr_id_cs_only;
            disp(['CS only trials: ...']);
            tr_id_cs_only
        else
            trial_no_arr = tr_id_cs_us;
            disp(['CS US trials: ...']);
            tr_id_cs_us
        end
    end
    %% read DLC excel. it takes time...
    if mark_DLC
        [~,~,raw] = xlsread(dlc_path);
    end
    
    %%
    cccc;
    fig1 = figure('color',[1 1 1],'position',fig_size);
    
    for t=1:length(trial_no_arr)
        clf;
        trial_no = trial_no_arr(t);
        if ~isempty(find(tr_id_cs_only==trial_no))
            name_str = '_cs_only';
        else
            name_str = '_cs_us';
        end
        param_mat = load(mat_path);
        nbox = 4;
        IBI = 1.2;
        s.Rate = 20000;
        % rec_freq = 100; %video is actually 100 Hz.
        rec_freq = 280; %video is actually 280 Hz.
        camclk_on_dur = 2; %sec.
        
        [fo,fi,ext] = fileparts(cur_vari.video_path);
        param_mat = load(mat_path);
        
        vi = VideoReader(video_path);
        if ~isempty(rect_crop)
            img = imcrop(read(vi,1),rect_crop);
        else
            img = read(vi,1);
        end
        if is_img_adjust
            img = imadjust(img, img_adjust_in, img_adjust_out);
        end
        
        h=imshow(img);
        if is_show_title
            h_title = title(video_path, 'fontsize',5);
        end
        if is_show_sec
            h_sec = text(size(h.CData,2)-80, -10, '-0.5 sec','color',[0.5,0.5,0.5],'fontsize',15);
        end
        
        hold on;
        
        dlc_info = {};
        if mark_DLC
            %     [~,~,raw] = xlsread(dlc_path);
            dlc_info{1} = cell2mat(raw(4:end,2:4));
            dlc_info{2} = cell2mat(raw(4:end,5:7));
            dlc_info{3} = cell2mat(raw(4:end,8:10));
            dlc_info{4} = cell2mat(raw(4:end,11:13));
            
            clearvars p_arr;
            for d=1:length(dlc_info)
                p_arr(d) = plot(0,0,'.','color',dlc_clr(d,:),'markersize',50);
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
            save_video_path = [save_video_fo filesep fi '_trial_' num2str(trial_no) '.mp4'];
            vw = VideoWriter(save_video_path, 'MPEG-4');
            vw.FrameRate = 40;
            vw.open();
        end
        count = 0;
        count2 = 0;
        if is_only_show_one_image
%             image_time_idx = round((image_time-video_start_time)*rec_freq);
            image_time_idx = round((image_times-video_start_time)*rec_freq);
            run_idx = rec_dur*(trial_no-1)+1 + image_time_idx;
%             count = round((image_times-video_start_time)*rec_freq);
        else
            run_idx = rec_dur*(trial_no-1)+1:rec_dur*(trial_no);
        end
        for i=run_idx
            count = count + 1;
            if is_only_show_one_image
                count2 = count2+1;
                cur_f = image_time_idx(count2);
                if is_show_sec
                    h_sec.String = [sprintf('%0.2f', cur_f/rec_freq+video_start_time) ' sec'];
                end
            else
                if is_show_sec
                    h_sec.String = [sprintf('%0.2f', count/rec_freq+video_start_time) ' sec'];
                end
            end
            if i == LED_onset
                if is_show_sec
                    h_LED = text(10, -10, 'LED ON','color','yellow');
                end
            end
            if i == LED_offset
                if is_show_sec
                    delete(h_LED);
                end
            end
            if i == puff_onset
                if is_show_puff
                    h_puff = text(10, -10, 'Puff ON','color','green');
                end
            end
            if i == puff_offset
                if is_show_puff
                    delete(h_puff);
                end
            end
            if ~isempty(rect_crop)
                img = imcrop(read(vi,i),rect_crop);
            else
                img = read(vi,i);
            end
            if is_img_adjust
                img = imadjust(img, img_adjust_in, img_adjust_out);
            end
            h.CData = img;
            
            for d=1:length(dlc_info)
                cur_p = p_arr(d);
                cur_dlc = dlc_info{d};
                like = cur_dlc(i,3);
                if ~isempty(rect_crop)
                    offset_x = -rect_crop(1);
                    offset_y = -rect_crop(2);
                else
                    offset_x = 0;
                    offset_y = 0;
                end
                if like >= likelihood_thr && dlc_body_plot(d)==1
                    cur_p.XData = cur_dlc(i,1) + offset_x;
                    cur_p.YData = cur_dlc(i,2) + offset_y;
                else
                    cur_p.XData = 0;
                    cur_p.YData = 0;
                end
                drawnow nocallbacks;
            end
            
            if is_save_video
                writeVideo(vw,getframe(fig1));
            end
            if is_only_show_one_image
                save_img_path = [save_video_fo filesep file_name_prefix '_' fi '_trial_' num2str(trial_no) name_str '_f' num2str(cur_f) '.jpg'];
                if ~exist(save_video_fo)
                    mkdir(save_video_fo);
                end
                %     save_img_path = [save_video_fo filesep fi '_trial_' num2str(trial_no) '.svg'];
                saveas(fig1, save_img_path);
            end
%             pause(0.01);
        end
        if is_save_video
            close(vw);
            disp(['Video saved... ' save_video_path]);
        end
        disp(['Done(' num2str(t) '/' num2str(length(trial_no_arr)) ')']);
        
    end
    
end
disp(['All Finished!!']);
end
