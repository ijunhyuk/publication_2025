function [cr_flag, cr_peak] = TTT_eyeb100_7_3_count_conditioned_response(perc_trace, cr_threshold, cr_time_idx, cr_dur_thr_idx)
% make array of flag. 1: CR, 0: not CR.
    cr_flag = [];
    cr_peak = [];
    for i=1:size(perc_trace,2)
        cur_trace = perc_trace(:,i);
        tar_trace = cur_trace(cr_time_idx(1):cr_time_idx(2));
        cr_flag(i) = length(find(tar_trace>cr_threshold))>cr_dur_thr_idx;
        cr_peak(i) = nanmax(tar_trace); % this value is too noisy.
    end    
end
