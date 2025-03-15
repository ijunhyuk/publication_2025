function idx_result = TTT_vor_1000_1_3_1_sub_idx_padding(idx_to_be_pad, pad_count)
%padding the idx_to_be_pad
% ex) 
% idx_to_be_pad = [0 0 0 0 1 0 0 0]
% pad_count = 2
% idx_result = [0 0 1 1 1 1 1 0]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pad_count = round(pad_count);
idx_result = idx_to_be_pad;
for c=-pad_count:pad_count
    temp = circshift(idx_to_be_pad,c);
    idx_result = idx_result | temp;
end

end