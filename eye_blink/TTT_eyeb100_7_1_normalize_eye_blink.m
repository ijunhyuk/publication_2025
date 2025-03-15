function [eye_p_cs_us, median_cs_us, eye_p_cs_only, median_cs_only] = TTT_eyeb100_7_1_normalize_eye_blink(eyeB_st)
%% return the normalized values.
puff_residual_time = 0.03; %sec. the time still can see hair is puffed.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vi_fr = eyeB_st.vi_hz;

base_s = eyeB_st.baseline_time(1)*vi_fr+1;
base_e = eyeB_st.baseline_time(2)*vi_fr;
cs_s = eyeB_st.cs_start_end_sec(1)*vi_fr+1;
cs_e = eyeB_st.cs_start_end_sec(2)*vi_fr;
us_s = eyeB_st.us_start_end_sec(1)*vi_fr+1;
us_e = eyeB_st.us_start_end_sec(2)*vi_fr;

median_cs_us = eyeB_st.median_cs_us;
median_cs_only = eyeB_st.median_cs_only;
clr_cs_us = eyeB_st.clr_cs_us;
clr_cs_only = eyeB_st.clr_cs_only;
clr_cs_us_ind = min(clr_cs_us+0.4, [1 1 1]);
clr_cs_only_ind = min(clr_cs_only+0.4, [1 1 1]);

% full close time: the time right after the puff garantee full close.
full_close_s = us_e + round(puff_residual_time*vi_fr);
full_close_e = full_close_s + round(puff_residual_time*vi_fr);
eye_h_cs_us = eyeB_st.eye_h_cs_us;
eye_h_cs_only = eyeB_st.eye_h_cs_only;

    %when full close still there is distance between upper lid and lower
    %lid. offset it.
    
    %20230413 revised.
%     full_close_moment_trace = nanmedian(eye_h_cs_us([full_close_s:full_close_e],:),2);
%     full_close_amp = nanmedian(full_close_moment_trace,1);
    full_close_moments = eye_h_cs_us([full_close_s:full_close_e],:);       
    full_close_amp = prctile(full_close_moments(:),90);    
    % exception treat.
    full_close_amp = TTT_eyeb100_7_4_full_close_exception(eyeB_st, full_close_amp, full_close_moments);
    
    eye_h_cs_us = eye_h_cs_us - full_close_amp;
    eye_h_cs_only = eye_h_cs_only - full_close_amp;

    [eye_p_cs_us, median_cs_us] = TTT_eyeb100_7_2_convert_to_perc(eye_h_cs_us, base_s, base_e);
    [eye_p_cs_only, median_cs_only] = TTT_eyeb100_7_2_convert_to_perc(eye_h_cs_only, base_s, base_e);    
    
end

