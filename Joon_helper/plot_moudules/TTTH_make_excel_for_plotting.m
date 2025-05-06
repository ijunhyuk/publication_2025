function [excel_raw] = TTTH_make_excel_for_plotting(data, data_meta_cell, data_header, cell_color_map, save_excel_path,sheet_name)
%data:array or cell (S x G) where S: num of samples, G:num of groups 
% data_meta_cell:cell type. meta info for data (S x G). default is empty.
%data_header: usually group names. ex) data_header = {'GC-CTR','GC-TKO'}; default is empty.
%cell_color_map:rgb(0-255) ex) cell_color_map = {[0 0 255], [255 100 0]}; default is black.

con_total = {'';'bar color(R)';'bar color(G)';'bar color(B)'};

if iscell(data)
    cell_data = data;
elseif isnumeric(data)
    cell_data = num2cell(data);
else
    disp(['input type: array or cell!!!']);
    return;
end
for i=1:size(cell_data,2)
    cur_header = {'meta';nan;nan;nan};    
    if isempty(data_header)
        cur_header(1,2) = {''};
    else
        cur_header(1,2) = data_header(i);
    end    
    if isempty(cell_color_map)
        cur_header(2:4,2) = num2cell([0 0 0]'); %base color: black.
    else
        cur_header(2:4,2) = num2cell(cell_color_map{i}');
    end
    if isempty(data_meta_cell)
        cur_meta = cell(size(cell_data,1),1);
    else
        cur_meta = data_meta_cell(:,i);
    end
    cur_data = [cur_meta cell_data(:,i)];
    cur_con = [cur_header;cur_data];
    con_total(1:size(cur_con,1),end+1:end+2) = cur_con;
end
con_total{1,end+1} = 'empty';

excel_raw = con_total;
if ~isempty(save_excel_path)
    xlswrite(save_excel_path,excel_raw,sheet_name);
end
end