function [raw,is_col_empty,is_col_txt,is_col_num] = ...
    TTTH_v1_2_0_xlsread_nan_lowercase(excel_path,sheet,is_1st_row_header,is_replace_nan,lower_upper)
%
% read excel file
% is_1st_row_header: if first row is header in excel contents, set 1.
% is_replace_nan: if 1, every nan value will be replaced with empty string('').
% lower_upper: 'lower' or 'upper': change to lower/upper case. emtpy string(''): do nothing.

%output
%raw: cell array of excel contents.
%is_: each column type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[num,txt,raw] = xlsread(excel_path,sheet); % read again to change data types.

if is_1st_row_header
    header = raw(1,:);
    body = raw(2:end,:);
else
    header = {};
    body = raw(1:end,:);
end

%get representative data in each column.
temp = zeros(1,size(raw,2));
is_col_empty = temp;
is_col_txt = temp;
is_col_num = temp;
for i=1:size(raw,2)
    cur_col = body(:,i);
    nan_idx =find(cell2mat(cellfun(@(x)any(isnan(x)),cur_col,'UniformOutput',false)));
    cur_col(nan_idx) = [];
    if isempty(cur_col)
        is_col_empty(i) = 1;
    elseif ischar(cur_col{1})
        is_col_txt(i) = 1;        
    elseif isnumeric(cur_col{1})
        is_col_num(i) = 1;        
    end
end

for i=1:size(raw,2)
    cur_col = body(:,i);
    if is_col_empty(i)
        if is_replace_nan
            nan_idx =find(cell2mat(cellfun(@(x)any(isnan(x)),cur_col,'UniformOutput',false)));
            cur_col(nan_idx) = {''};            
        end
    end
    if is_col_txt(i)
        if is_replace_nan
            nan_idx =find(cell2mat(cellfun(@(x)any(isnan(x)),cur_col,'UniformOutput',false)));
            cur_col(nan_idx) = {''};            
        end
        if ~isempty(lower_upper)
            no_nan_idx =find(cell2mat(cellfun(@(x)any(~isnan(x)),cur_col,'UniformOutput',false)));
            if strcmp(lower_upper,'lower')
                cur_col(no_nan_idx) = lower(cur_col(no_nan_idx));
            else strcmp(lower_upper,'upper')
                cur_col(no_nan_idx) = upper(cur_col(no_nan_idx));
            end
        end
    end
    if is_col_num(i)
        
    end
    body(:,i) = cur_col;
end

if is_1st_row_header
    raw(1,:) = header;
    raw(2:end,:) = body;
else    
    raw(1:end,:) = body;
end

end