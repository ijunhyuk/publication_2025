function TTT_vor_1000_4_1_change_filename_short()
%%
tar_fo = {};
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\detection_in_progress';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\in_processing';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\WildType\m1067-m1070';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\KPPF\cohort5';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\KPPF';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\KPPF\in_processing';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\temp';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO\a6_TKO_batch3';
% tar_fo{end+1} = 'G:\Dropbox_joon\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\OKR_learning\OKR_learning_m1151-1154\analysis';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\AC_GC_m1161_m1166';
tar_fo{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO\PC-TKO_m1181-m1184';



tar_delete = {};
tar_delete{end+1} = 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_100000';
tar_delete{end+1} = 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_171000';
tar_delete{end+1} = 'DLC_resnet50_VOR_test_20220920Sep20shuffle1_171000';
tar_delete{end+1} = 'DLC_resnet_50_Eyeblink_20220928Sep28shuffle1_100000';
tar_delete{end+1} = 'DLC_resnet_50_VOR_test_20220920Sep20shuffle1_1030000';
tar_delete{end+1} = 'DLC_resnet_50_Updated_InVivo_Analysis_DeeplabcutMar8shuffle1_1030000';


replace_str = '_DLC';
inclue_sub_folders = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c_renamed = 0;
for i=1:length(tar_fo)
    cur_fo = tar_fo{i};
    file_list = TTTH_get_all_files(cur_fo, inclue_sub_folders, 'csv');
    disp(['Total ' num2str(length(file_list)) ' csv files detected']);
    for f=1:length(file_list)
        path_name = file_list{f};
        [fo,fi,ext] = fileparts(path_name);
        
        if contains(fi, tar_delete)
            for s=1:length(tar_delete)
                tf(s) = contains(fi, tar_delete{s});
            end            
            idx = find(tf==1);
            pat = tar_delete{idx(1)};
            
            idx_s = findstr(fi,pat);            
            new_fi = [fi(1:idx_s-1) replace_str fi(idx_s+length(pat):end)];
            new_path = [fo filesep new_fi ext];
            movefile(path_name, new_path); 
            c_renamed = c_renamed + 1;
            disp(['Name is chenged to: ' new_path]);
        else
            
        end
    end
end
disp(['finished. Total ' num2str(c_renamed) ' csv files renamed']);

end