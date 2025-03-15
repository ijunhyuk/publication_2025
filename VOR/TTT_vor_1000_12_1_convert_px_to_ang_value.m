function [p_diff_ang] = TTT_vor_1000_12_1_convert_px_to_ang_value(p_diff_px, radius_pupil)
    p_diff_ang = asind(p_diff_px./radius_pupil);
end