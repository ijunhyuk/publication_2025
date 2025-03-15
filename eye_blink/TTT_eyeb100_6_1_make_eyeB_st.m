function [] = TTT_eyeb100_6_1_make_eyeB_st()
%%
is_eye_set_overwrite = 1;
is_st_overwrite = 0;
is_plot = 1;
is_save_jpeg = 1;
video_format = 'mp4';

dirName = {};
dirName{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO\PC-TKO_m1205-m1209';

% dlc_suffix = 'DLC_resnet_50_Eyeblink_20220928Sep28shuffle1_100000';
dlc_suffix = '_DLC';
mat_prefix = 'Sess_Info_';
analysis_fo_name = 'summary';
eye_st_set_name = 'eye_st_set';
eye_st_name = 'eye_st';

for d=1:length(dirName)
    cur_dirName = dirName{d};
    TTT_eyeb100_6_2_make_eyeB_st_inner(is_plot, is_save_jpeg, video_format, ...
        cur_dirName, dlc_suffix, mat_prefix, analysis_fo_name, eye_st_set_name, eye_st_name, is_eye_set_overwrite, is_st_overwrite);
end

disp(['Finished!!!']);
end
