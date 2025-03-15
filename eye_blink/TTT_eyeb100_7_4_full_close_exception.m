function full_close_amp_new = TTT_eyeb100_7_4_full_close_exception(eyeB_st, full_close_amp, full_close_moments)
    % exception treat.
    if strcmp(eyeB_st.mouse_id, 'm1182')
        if strcmp(eyeB_st.video_name, 'B2_20241009_161119')
            full_close_amp = prctile(full_close_moments(:),99);
        elseif strcmp(eyeB_st.video_name, 'B2_20241004_160650')
            full_close_amp = prctile(full_close_moments(:),99);
        elseif strcmp(eyeB_st.video_name, 'B2_20241005_153409')
            full_close_amp = prctile(full_close_moments(:),99);
        end
    end
    full_close_amp_new = full_close_amp;
end

