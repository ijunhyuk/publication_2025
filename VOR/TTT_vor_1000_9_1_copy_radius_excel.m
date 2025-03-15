function TTT_vor_1000_9_1_copy_radius_excel()
%% Start:  backup Radius_. excel file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fo_path = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\Syt7_m941_m943_m945\m945';

%% backup
str_pattern = 'Radius_*.xlsx';
filelist = TTTH_search_all_files([fo_path], 1, str_pattern);
bak_fo = 'pupil_backup';

for i=1:length(filelist)
    cur_file = filelist{i};
    [fo,fi,ext] = fileparts(cur_file);
    backup_fo = [fo '\' bak_fo];
    if ~exist(backup_fo)
        mkdir(backup_fo);
    end
    to_file = [backup_fo '\old_' fi ext];
    movefile(cur_file, to_file);
end

%% restore
bak_fo = 'pupil_backup';
prefix = 'old_';
str_pattern = ['old_Radius_*.xlsx'];
filelist = TTTH_search_all_files([fo_path], 1, str_pattern);

for i=1:length(filelist)
    cur_file = filelist{i};
    [fo,fi,ext] = fileparts(cur_file);
    [par_fo,back_fo,~] = fileparts(fo);    
    new_fi = fi(length(prefix)+1:end);
    to_file = [par_fo '\' new_fi ext];
    movefile(cur_file, to_file);
end

%% End:  backup Radius_. excel file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
