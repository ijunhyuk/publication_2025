function TTT_vor_1000_2_5_get_mouse_exp_map()

%% Generate exp_map. The result excel file defines what to plot.
% dropbox_fo = 'G:\Dropbox_joon\Dropbox (HMS)';
dropbox_fo = 'M:\Dropbox (HMS)';

template_path = ['exp_map_template.xlsx'];

mouse_fo_arr = {};

mouse_fo_arr{end+1} = [dropbox_fo '\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch4\m1181'];
mouse_fo_arr{end+1} = [dropbox_fo '\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch4\m1182'];
mouse_fo_arr{end+1} = [dropbox_fo '\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch4\m1183'];

vor_trial_suffix = '_processed.mat';
vor_trial_suffix_poor = '_processed_PoorDLC.mat';
exp_map_excel = 'exp_map';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for mf=1:length(mouse_fo_arr)
    mouse_fo = mouse_fo_arr{mf};
    filelist_st1 = TTTH_search_all_files([mouse_fo], 1, vor_trial_suffix);
    filelist_st2 = TTTH_search_all_files([mouse_fo], 1, vor_trial_suffix_poor);
    
    [fo,fi,ext] = fileparts(mouse_fo);
    mouse_id = fi;
    
    filelist = [filelist_st1;filelist_st2];
    n_mat_files = length(filelist);
    fi_cell = {};
    for i=1:length(filelist)
        [fo,fi_cell{i,1},ext] = fileparts(filelist{i});
    end
    [fi_cell, idx] = sortrows(fi_cell,1);
    filelist = filelist(idx);
    %get relative path
    len = length(mouse_fo);
    filelist_relative = {};
    for i=1:length(filelist)
        cur = filelist{i};
        filelist_relative{i,1} = cur(len+1:end);
    end
    parsed_st = TTT_vor_1000_2_4_parse_vor_name(filelist_relative);
    tb = readtable(template_path);
    exp_type1 = tb.exp_type1(:,1);
    space_idx = find(contains(exp_type1,'empty'));
    cell_count = 1;
    new_mouse_id = {};
    new_mat_path = {};
    new_stim_hz = {};
    new_day = {};
    for tr=1:size(tb,1)
        if isempty(find(tr==space_idx)) && cell_count <= n_mat_files
            cur_mat = filelist_relative{cell_count};
            new_mouse_id{tr,1} = mouse_id;
            new_mat_path{tr,1} = cur_mat;
            new_stim_hz{tr,1} = parsed_st(cell_count).stim_hz;
            new_day{tr,1} = parsed_st(cell_count).day_no;
            cell_count = cell_count + 1;
        else
            new_mouse_id{tr,1} = '';
            new_mat_path{tr,1} = '';
            new_stim_hz{tr,1} = '';
            new_day{tr,1} = '';
        end
    end
    tb.mouse_id = new_mouse_id;
    tb.mat_path = new_mat_path;
    tb.exp_type3_day_ = new_day;
    tb.exp_type2_StimHz_ = new_stim_hz;
    
    excel_path = [mouse_fo filesep exp_map_excel '_' mouse_id '.xlsx'];
    writetable(tb, excel_path);
    
    if isempty(new_mouse_id{end-1})
        disp(['Caution!!! Some experiments were omitted. Need to revise exp_map.xlsx manually!!! ...' excel_path]);
    else
        disp(excel_path);
    end
end
disp(['finished!']);
end