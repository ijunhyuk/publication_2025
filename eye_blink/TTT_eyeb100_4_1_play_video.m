function [] = TTT_eyeb100_4_1_play_video()
%%
% 20221213. Joon.
warning off;

video_start_time = -0.5;
is_save_video = 1;
fig_size = [100 100 500 400];

% dropbox_fo = 'G:\Dropbox_joon\Dropbox (HMS)';
dropbox_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';
% dropbox_fo = '\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon';

% video_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC_TKO_m963_m964_m965\20230409'];
% video_path = [video_fo '\B4_20230409_133826.mp4']; box_no = 4;
% mat_path = [video_fo '\Sess_Info_20230409_133826.mat'];
% trial_no = 90;

% video_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1\GC_TKO_m963_m964_m965\20230408'];
% video_path = [video_fo '\B4_20230408_122151.mp4']; box_no = 2;
% mat_path = [video_fo '\Sess_Info_20230408_122151.mat'];
% trial_no = 96;

% video_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1\GC_TKO_m963_m964_m965\20230405'];
% video_path = [video_fo '\B2_20230405_125608.mp4']; box_no = 2;
% mat_path = [video_fo '\Sess_Info_20230405_125608.mat'];
% trial_no = 5;

% video_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO\batch2\day6'];
% video_path = [video_fo '\B3_20230909_110308.mp4']; box_no = 3;
% mat_path = [video_fo '\Sess_Info_20230909_110308.mat'];
% % trial_no = 91;
% trial_no_arr = [26 37 44 50 73 97 98 101 102];

video_fo = [dropbox_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO\batch2\day1_sess3'];
video_path = [video_fo '\B4_20230720_120903.mp4']; box_no = 4;
mat_path = [video_fo '\Sess_Info_20230720_120903.mat'];
% trial_no = 91;
trial_no_arr = [    
    24
    ];


save_video_fo = [video_fo '\analysis'];

mark_DLC = 1;
dlc_path = [video_fo '\B4_20230720_120903_DLC.csv'];

is_show_title = 0;
is_show_sec = 0;
is_show_puff = 0;

dlc_clr = [
    1 0 0
    0 1 0
    1 1 0
    0 0 1   
    ];
dlc_body_plot = [1 1 0 1]; % Plot the point if 1. No plot if 0.
likelihood_thr = 0.7;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
param_mat = load(mat_path);

tr_id = param_mat.sess_param.trial_ID(:,box_no);
tr_id_cs_only = find(tr_id==1);
disp(['CS only trials: ...']);
tr_id_cs_only

%%
for t=1:length(trial_no_arr)
    cccc;
    trial_no = trial_no_arr(t);
param_mat = load(mat_path);
nbox = 4;
IBI = 1.2;
s.Rate = 20000;
% rec_freq = 100; %video is actually 100 Hz.
rec_freq = 280; %video is actually 280 Hz.
camclk_on_dur = 2; %sec.

[fo,fi,ext] = fileparts(video_path);
param_mat = load(mat_path);

vi = VideoReader(video_path);
fig1 = figure('color',[1 1 1],'position',fig_size);
h=imshow(read(vi,1));
if is_show_title
    h_title = title(video_path, 'fontsize',5);
end
if is_show_sec
    h_sec = text(size(h.CData,2)-80, 10, '-0.5 sec','color',[1 1 1],'fontsize',15);
end

hold on;

dlc_info = {};
if mark_DLC
    [~,~,raw] = xlsread(dlc_path);
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
for i=rec_dur*(trial_no-1)+1:rec_dur*(trial_no)
    count = count + 1;
    h_sec.String = [sprintf('%0.2f', count/rec_freq+video_start_time) ' sec'];
    if i == LED_onset
        if is_show_sec
            h_LED = text(10, 10, 'LED ON','color','yellow');
        end
    end
    if i == LED_offset
        if is_show_sec
            delete(h_LED);
        end
    end
    if i == puff_onset
        if is_show_puff
            h_puff = text(10, 25, 'Puff ON','color','green');
        end
    end
    if i == puff_offset
        if is_show_puff
            delete(h_puff);
        end
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

disp(['All Finished!!']);
end
