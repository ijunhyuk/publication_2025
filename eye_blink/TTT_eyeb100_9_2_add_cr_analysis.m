function eyeB_st_ret = TTT_eyeb100_9_2_add_cr_analysis(eyeB_st, conditioned_response_threshold_z, conditioned_response_target_time)
cr_thr = conditioned_response_threshold_z;
cr_target_t = conditioned_response_target_time;

    xx = eyeB_st.xx_sec;
    
%     figure();
%     r=2;c=3;
%     p = 1;
%     subplot(r,c,p);
%     plot(xx,eyeB_st.eye_h_cs_us);
%     subplot(2,3,p+c);
%     plot(xx,eyeB_st.eye_h_cs_only);
% 
%     p = 2;
%     subplot(r,c,p);
%     plot(xx,eyeB_st.median_cs_us);
%     subplot(2,3,p+c);
%     plot(xx,eyeB_st.median_cs_only);    
% 
%     p = 3;
%     subplot(r,c,p);
%     plot(xx,eyeB_st.median_cs_us_norm);
%     subplot(2,3,p+c);
%     plot(xx,eyeB_st.median_cs_only_norm);

cur_cs = eyeB_st.eye_h_cs_only;
baseline_time = eyeB_st.baseline_time;
base_idx = find(baseline_time(1) <= xx & xx < baseline_time(2));
normalize_type = 1;
cur_cs_z = TTTH_v5_1_1_normalize(cur_cs, base_idx, normalize_type);
t_mask = cr_target_t(1) <= xx & xx < cr_target_t(2);
%     figure();hold on;
% plot(xx, cur_cs_z);

tar_xx = xx(t_mask);
tar_z_res = cur_cs_z(t_mask,:);

is_cr = zeros(1,size(cur_cs,2));
cr_z_amount = zeros(1,size(cur_cs,2)); % the area above the threshold.
for i=1:size(tar_z_res,2)     %  i=2
    cur_trace = tar_z_res(:,i);
    
    %determine if it is CR response.
    cr_idx = find(cur_trace>cr_thr);
%     cr_idx_t = cr_target_t(1) + xx(cr_idx);
%     is_cr(i) = ~isempty(cr_idx_t);
    
    is_cr(i) = median(cur_trace) > cr_thr;
    cr_z_amount(i) = sum(cur_trace(cr_idx));
end
perc_cr = length(find(is_cr==1))/length(is_cr)*100;
eyeB_st.cr_thrshold_z = cr_thr;
eyeB_st.is_cr = is_cr;
eyeB_st.cr_z_amount = cr_z_amount;
eyeB_st.perc_cr = perc_cr;

%     plot(tar_xx, tar_z_res(:,:));
%     plot(tar_xx, mean(tar_z_res,2));


eyeB_st_ret = eyeB_st;

% temp.

end
