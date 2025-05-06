function copy_tool()
%% move or copy files with making same folder structures.
% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO';
% to_fo = '\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon\EyeBlink\Data\videos_air_Puff';

% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO';
% to_fo = '\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon\EyeBlink\Data\videos_air_Puff';

% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1';
% to_fo = '\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon\EyeBlink\Data\videos_air_Puff';

% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_m1001_m1002_m1004';
% to_fo = '\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon\EyeBlink\Data\videos_air_Puff';

% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO';
% to_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\vis_delay_bak\a6_TKO';

% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO';
% to_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\vis_delay_bak\GC_TKO';

% from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO';
% to_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\vis_delay_bak\PC_TKO';

from_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
to_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\vis_delay_bak\exp_map';

check_sub_dir = 1;
% str_pattern = 'Puff_test_*.mp4';
% str_pattern = '*_OKR_proc*.*';
str_pattern = 'exp_map_*.xlsx';

move_or_copy = 1; %0 is move, 1 is copy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_list = TTTH_search_all_files(from_fo, check_sub_dir, str_pattern);
% Example: file_list = TTTH_get_all_files('D:\root\sub_root', 0, 'JL_su_*.mat');

for i=1:length(file_list)
    cur_file = file_list{i};
    tok = strsplit(cur_file, filesep);
    relative_path = fullfile(tok{end-3:end});
    copy_to_path = fullfile(to_fo, relative_path);
    
    [fo,fi,ext] = fileparts(copy_to_path);
    if ~exist(fo)
        mkdir(fo);
    end
    if move_or_copy==0
        movefile(cur_file, copy_to_path);
    else
        copyfile(cur_file, copy_to_path);    
    end
end

disp('finished!!!');
end
