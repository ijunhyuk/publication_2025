function [excel_raw] = TTTH_make_excel_for_plotting_ver2(data, data_meta_cell, data_header, cell_color_map, save_excel_path,sheet_name, empty_column_pos)
%data:array or cell (S x G) where S: num of samples, G:num of groups 
% data_meta_cell:cell type. meta info for data (S x G). default is empty.
%data_header: usually group names. ex) data_header = {'GC-CTR','GC-TKO'}; default is empty.
%cell_color_map:rgb(0-255) ex) cell_color_map = {[0 0 255], [255 100 0]}; default is black.
% empty_column_pos: ex) [1 5 10]. To give empty column space between boxes.

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
    if strcmp(cell_data(1,i),'empty')
        con_total{1,end+1} = 'empty';
    else
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
end
% con_total{1,end+1} = 'empty'; % add one emppty column for better plotting.
excel_raw = con_total;

% insert 'empty' to insert space in the graph.
% start_col = 2; % because first colo is for rgb column.
if ~isempty(empty_column_pos)
    [n_row, n_col] = size(con_total);
    empty_col = cell(n_row,1); empty_col{1} = 'empty';
    base_pos = 1; %to exclude 'bar color' column
    for i=1:length(empty_column_pos)   
%         if i==1
%             col_s = 1;
%             col_e = 2*empty_column_pos(i)-1;
%         else
%             col_s = 2*empty_column_pos(i-1);
%             col_e = 2*empty_column_pos(i)-1;            
%         end
%         
%         col_e = min([col_e n_col]);
%         if col_e==col_s
%             new_cell_data = [new_cell_data empty_col];
%         else            
%             new_cell_data = [new_cell_data con_total(:,col_s:col_e) empty_col];
%         end
        cell_pos = base_pos + 2*(empty_column_pos(i)-1) + 1;
        excel_raw = [excel_raw(:,1:cell_pos-1) empty_col excel_raw(:,cell_pos:end)];        
        base_pos = base_pos + 1;
    end
end

if ~isempty(save_excel_path)
    xlswrite(save_excel_path,excel_raw,sheet_name);
end
end