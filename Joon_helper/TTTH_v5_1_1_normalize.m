function normalized_data = TTTH_v5_1_1_normalize(data, base_row_idx, normalize_type)
% normalize the data with various methods.

%input
% data: rows are each time point,  columns are each cell.
% base_row_idx: rows that will be used as baseline.

% normalize_type
% 1: zscore with the baseline (base_row_idx).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
normalized_data = zeros(size(data));
if normalize_type==1
for i=1:size(data,2) %i=3
    cur = data(:,i);
    base_val = cur(base_row_idx);
    base_mean = mean(base_val);
    base_std = std(base_val);
    cur_norm = (cur-base_mean)/base_std;
    
%     figure();hold on;
%     plot(cur);
%     plot(base_val);
%     
%     figure();hold on;
%     plot(cur_norm);
    normalized_data(:,i) = cur_norm;
end

end

end