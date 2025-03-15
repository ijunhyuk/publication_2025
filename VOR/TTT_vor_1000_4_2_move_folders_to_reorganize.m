function TTT_vor_1000_4_2_move_folders_to_reorganize()
%%  Rearragne folders to the hierarchy, e.g. (mouse_id) / (phaseday1)

tar_fo = {};
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO_batch1\GC_TKO_m1001_m1004';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO_batch2\GC_TKO_m1001_m1004';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\batch1_temp';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch2';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\KPPF\cohort4';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\KPPF\cohort5';
% tar_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO\GC_TKO_batch4';
tar_fo{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch4';

excel_name = 'rearrange_folders.xlsx';
dayfo_sheetname = 'dayfo_arrange';
% rp_sheetname = 'rp_arrange';

search_name = '*_trial_*.mat';
inclue_sub_folders = 1;

%%
% Make folder list and save to excel file.
% find all (but unique) folders that contains search_name, and writedown to excel file.

%find unique sub folders
tar_fo_list = {};
for i=1:length(tar_fo)
    cur_fo = tar_fo{i};
    file_list = TTTH_search_all_files(cur_fo, inclue_sub_folders, search_name);
    sub_fo_list = {};
    for j=1:length(file_list)
        [fo,fi,ext] = fileparts(file_list(j));
        [sub_f1,sub_f2,ext] = fileparts(fo);
        sub_fo_list{j,1} = sub_f1;
    end
    uniq_sub_fo = unique(sub_fo_list);
    tar_fo_list{i,1} = uniq_sub_fo;
end
    
for ti=1:length(tar_fo_list)
    uniq_sub_fo = tar_fo_list{ti};

    root_fos = {};
    sub_fos1 = {};
    sub_fos2 = {};
%     root_f = cur_fo; root_pos = length(cur_fo);
    for j=1:length(uniq_sub_fo)
        cur = uniq_sub_fo{j};
        [fo,fi,ext] = fileparts(cur);        
        [sub_f1,sub_f2,ext] = fileparts(fo);
        root_fos{j,1} = sub_f1;
        sub_fos1{j,1} = sub_f2;
        sub_fos2{j,1} = fi;
    end
    
    con_main = [root_fos sub_fos1 sub_fos2 root_fos];
    header = {'','','',''};
    content = [header;con_main];
    header = {'copied from (root folder)','(from sub folder1)','(from sub folder2)', ...
        'copied to (root folder)','(to sub folder1)','(to sub folder2)','rp_folder', 'rp_file_name'};
%     rp_column = [1 2 3];
    content(1,1:length(header)) = header;
    
    con_tb = cell2table(content(2:end,:));
    con_tb.Properties.VariableNames = content(1,:);
    
%     rp_con_tb = con_tb(:,rp_column);    
    
%sorting 
    con_tb2 = sortrows(con_tb,{'(from sub folder2)','(from sub folder1)'}, {'ascend', 'ascend'});
    
    save_excel_path = [tar_fo{ti} filesep excel_name];
%     xlswrite(save_excel_path, content, sheetname);
    writetable(con_tb,save_excel_path, 'sheet', dayfo_sheetname);
%     writetable(rp_con_tb,save_excel_path, 'sheet', rp_sheetname);
%     writecell(rp_header,save_excel_path, 'sheet', rp_sheetname,'Range','A1:E1');
end

disp('finished!!!');
%%  Now you need to manually fill in the columns 'to_sub1', 'to_sub2' in the excel file.
% Do manually.
% No need to fill in the field (rp_folder	rp_file_name) yet.

%%  Read excel file and move folders as specified in the excel.
col_from_root = 1;
col_from_sub1 = 2;
col_from_sub2 = 3;
col_to_root = 4;
col_to_sub1 = 5;
col_to_sub2 = 6;

for ti=1:length(tar_fo)
    cur_fo = tar_fo{ti};
    cur_excel = [cur_fo filesep excel_name];

    tb_rp = readtable(cur_excel, 'sheet', dayfo_sheetname);
    for r=1:size(tb_rp,1)
        fo_to = [tb_rp{r,col_from_root}{1} filesep tb_rp{r,col_from_sub1}{1} filesep tb_rp{r,col_from_sub2}{1}];
        rp_from = [tb_rp{r,col_to_root}{1} filesep tb_rp{r,col_to_sub1}{1} filesep tb_rp{r,col_to_sub2}{1}];
        if exist(fo_to) %check if fo_from exist.
            any_content = TTTH_search_all_files(fo_to, 1, '*');
            if ~isempty(any_content) %check if fo_from has any files.
                if ~exist(rp_from) %make fo_to if it does not exist.
                    mkdir(rp_from);
                end
                if ~strcmp(rp_from, fo_to)
                    movefile([fo_to '\*.*'], rp_from); %move all contents.
                else
                    
                end
            end
        end
    end
end

disp(['finished!!!']);

%%
%% arrange Rp files. Make a excel list of all Radius_*.xlsx files.

rp_search_fo = {};
% rp_search_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\pupil_zip';
% rp_search_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\pupil_zip\batch2';
% rp_search_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\KPPFA\cohort3\RP';
% rp_search_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch3';
% rp_search_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO\GC_TKO_batch4\Rp';
rp_search_fo{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch4\Rp';


rp_search_name = 'Radius_*.xlsx';
sorting=1;

for i=1:length(rp_search_fo)
    cur_fo = rp_search_fo{i};
    file_list = TTTH_search_all_files(cur_fo, inclue_sub_folders, rp_search_name);
    fo_arr = {};
    fi_arr = {};
    for j=1:length(file_list)
        [fo,fi,ext] = fileparts(file_list{j});
        fo_arr{j,1} = fo;
        fi_arr{j,1} = [fi ext];
    end
    %sorting.
    if sorting == 1
        % no need.
    end
    
    list_save_path = [cur_fo filesep 'temp_rp_list.xlsx'];
    writecell([fo_arr fi_arr],list_save_path);
    disp(['Rp_list saved... ' list_save_path]);
end

%% copy Rp files to the designated positions.
% fill in the column (rp_folder	rp_file_name) in rearrange_folders.xlsx
% fill in the fo and filename of Rp files in the excel.

rearrange_xls = {};
% rearrange_xls{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch2\rearrange_folders.xlsx';
% rearrange_xls{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\KPPFA\cohort2\rearrange_folders.xlsx';
% rearrange_xls{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch3\rearrange_folders.xlsx';
% rearrange_xls{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\OKR_learning\OKR_learning_m1151-1154\analysis\rearrange_folders.xlsx';
% rearrange_xls{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO\GC_TKO_batch4\rearrange_folders.xlsx';
rearrange_xls{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch4\rearrange_folders.xlsx';

copy_rp_to_folders_after_arranged = 1; %default 1. if 1, Rp files will be copied to the folders after arranged (ex: m1024\day0)
% if 0, to the folders before arranged (ex: day0\m1024)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if copy_rp_to_folders_after_arranged
    col_from_root = 4;
    col_from_sub1 = 5;
    col_from_sub2 = 6;
else
    col_from_root = 1;
    col_from_sub1 = 2;
    col_from_sub2 = 3;

end
rp_fo = 7;
rp_name = 8;

for ti=1:length(rearrange_xls)
    cur_excel = rearrange_xls{ti};

    tb_day = readtable(cur_excel, 'sheet', dayfo_sheetname);
%     tb_rp = readtable(cur_excel, 'sheet', rp_sheetname);
    
    for r=1:size(tb_day,1)
        fo_to = [tb_day{r,col_from_root}{1} filesep tb_day{r,col_from_sub1}{1} filesep tb_day{r,col_from_sub2}{1}];
        
        if ~isempty(tb_day{r,rp_fo}) && iscell(tb_day{r,rp_fo})
            rp_from = [tb_day{r,rp_fo}{1} filesep tb_day{r,rp_name}{1}];
            if ~exist(fo_to)
                mkdir(fo_to);
            end
            copyfile([rp_from], fo_to); %copy rp files to the designated positions.
        else
            disp(['No Rp location for... ' fo_to]);
        end
    end
end

disp(['finished!!!']);

end