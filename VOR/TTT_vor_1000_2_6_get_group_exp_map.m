function tb_map = TTT_vor_1000_2_6_get_group_exp_map(search_fo)

%%
search_pattern = 'exp_map_';
template_excel = 'exp_map_template';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filelist = {};
for i=1:length(search_fo)
    filelist = [filelist; TTTH_search_all_files(search_fo{i}, 1, search_pattern)];
end

tb_map = {}; count = 1;
header = {};
for i=1:length(filelist)
    cur_file = filelist{i};
    [fo,fi,ext] = fileparts(cur_file);
    if ~strcmp(fi,template_excel)
        mouse_id = fi(length(search_pattern)+1:end);
        tb_map{count,1} = mouse_id; header{1} = 'mouse_id';
        tb_map{count,2} = cur_file; header{2} = 'map_path';
        count = count + 1;
    end
end
tb_map = cell2table(tb_map);
tb_map.Properties.VariableNames = header;

end