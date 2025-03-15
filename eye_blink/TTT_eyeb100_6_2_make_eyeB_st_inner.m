function [] = TTT_eyeb100_6_2_make_eyeB_st_inner(is_plot, is_save_jpeg, video_format, ...
    dirName, dlc_suffix, mat_prefix, analysis_fo_name, eye_st_set_name, eye_st_name, is_eye_set_overwrite, is_st_overwrite)
%%
% is_plot = 0;
% is_save_jpeg = 0;
% video_format = 'mp4';
% % dirName = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_m831_m832_m834';
% dirName = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\Syt7_m861_m862_m864';
% dlc_suffix = 'DLC_resnet_50_Eyeblink_20220928Sep28shuffle1_100000';
% mat_prefix = 'Sess_Info_';
% analysis_fo_name = 'analysis';
% eye_st_set_name = 'eye_st_set';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
save_fo = [dirName filesep analysis_fo_name];
if ~exist(save_fo)
    mkdir(save_fo);
end
set_path = [save_fo filesep eye_st_set_name '.mat'];

if ~is_eye_set_overwrite
    if exist(set_path)
        disp(['Already exists, Skip... ' set_path]);
        return;
    end
end
file_list = TTTH_get_all_files(dirName, 1, video_format);
%exclude trial example videos.
remove_idx = [];
for i=1:length(file_list)
    if contains(file_list{i},'_trial_') || contains(file_list{i},'Puff_test_')
        remove_idx = [remove_idx i];
    end
end
file_list(remove_idx) = [];

disp(['Total ' num2str(length(file_list)) ' videos detected.']);

box_no_prev = 0;
clear('eye_st_set');
for i=1:length(file_list) %i=34
    video_path = file_list{i};
    [fo,fi,ext] = fileparts(video_path);    
    st_path = [fo filesep fi '_' eye_st_name '.mat'];    
    if ~is_st_overwrite
        if exist(st_path)
            temp = load(st_path);
            eyeB_st = temp.eyeB_st;
            eye_st_set(i,:) = eyeB_st;
            disp(['Already exists, Skip... ' st_path]);
            continue;
        end
    end
    
    close all;
    disp(['Processing... ' num2str(i) '/' num2str(length(file_list))]);
    box_no = str2num(fi(2));
    tok = split(fi,'_');
    date_str = tok{2};
%     if box_no_prev~=box_no
%         day_no = 1;
%         box_no_prev = box_no;
%     else
%         day_no = day_no + 1;
%     end
    excel_path = [fo filesep fi dlc_suffix '.csv'];
    mat_path = [fo filesep mat_prefix fi(4:end) '.mat'];
%     [eyeB_st] = TTT_eyeb100_3_1_analyze_video_with_DLC_excel(video_path, excel_path, mat_path, box_no, day_no, is_plot, is_save_jpeg);
    [eyeB_st] = TTT_eyeb100_3_2_analyze_video_with_DLC_excel(video_path, excel_path, mat_path, box_no, date_str, is_plot, is_save_jpeg);

    %20240927 try to change method from DLC to old-thresholding.
%     [eyeB_st] = TTT_eyeb100_3_3_analyze_video_with_DLC_excel(video_path, excel_path, mat_path, box_no, date_str, is_plot, is_save_jpeg);
    
    %20230412. add normalized median.
    [eye_p_cs_us, median_cs_us, eye_p_cs_only, median_cs_only] = TTT_eyeb100_7_1_normalize_eye_blink(eyeB_st);
    eyeB_st.median_cs_us_norm = median_cs_us;
    eyeB_st.median_cs_only_norm = median_cs_only;
    %20240422. added.
    eyeB_st.eye_p_cs_us_norm = eye_p_cs_us;
    eyeB_st.eye_p_cs_only_norm = eye_p_cs_only;
    
    save(st_path,'eyeB_st');
    disp(['eye_st saved... ' st_path]);
    eye_st_set(i,:) = eyeB_st;
end

% sorting.
T = struct2table(eye_st_set); % convert the struct array to a table
sortedT = sortrows(T, {'date_str','mouse_id'}); % sort the table by 'DOB'
eye_st_set = table2struct(sortedT);

% identify the day_no per mouse.
m_id_arr = {eye_st_set.mouse_id};
uniq_m_id = unique(m_id_arr);
disp(['Total ' num2str(length(uniq_m_id)) ' unique id detected: ']);
disp([uniq_m_id]);

for i=1:length(uniq_m_id)
    cur_id = uniq_m_id{i};
    idx = find(ismember(m_id_arr, cur_id));
    sub_set = eye_st_set(idx);
    
    %get day1_no
    date_arr = {sub_set.date_str};
    uniq_date = sortrows(unique(date_arr));
    day1_no = str2num(uniq_date{1});
    
    for j=1:length(idx)
        day_no = str2num(eye_st_set(idx(j)).date_str);        
        
        time_diff = datetime(num2str(day_no),'InputFormat','yyyyMMdd') - datetime(num2str(day1_no),'InputFormat','yyyyMMdd');
        n = days(time_diff)+1;        
        
        eye_st_set(idx(j)).day_no = n;
    end
end

% % add day numbers.
% date_arr = {eye_st_set.date_str};
% uniq_date = unique(date_arr);
% for i=1:length(date_arr) %i=12
%     idx = find(contains(uniq_date, date_arr{i}));
%     eye_st_set(i).day_no = idx;
% end

save(set_path,'eye_st_set');
disp(['eye_st_set saved... ' set_path]);
end
