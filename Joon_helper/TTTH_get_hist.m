function [hist_count,idx_arr_cell] = TTTH_get_hist(x_data,edges)
%
% like MATLAB histogram, the edges works edges(k) <= data < edges(k+1).
% except the last range will be edges(end-1) <= data <= edges(end).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_arr_cell = {};
hist_count = [];
for i=1:length(edges)-1
    if ~(i==length(edges)-1)
        idx = find(edges(i)<=x_data & x_data<edges(i+1));
    else
        idx = find(edges(i)<=x_data & x_data<=edges(i+1));
    end    
    hist_count(i) = length(idx);
    idx_arr_cell{i} = idx;
end

end