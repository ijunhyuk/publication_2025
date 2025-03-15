function [eye_p_cs_us, median_cs_us] = TTT_eyeb100_7_2_convert_to_perc(eye_h_cs_us, base_s, base_e)
% change to perc.
    eye_p_cs_us = eye_h_cs_us;
    med_val = nanmedian(eye_h_cs_us([base_s:base_e],:),1);
    for i=1:size(eye_h_cs_us,1)
        eye_p_cs_us(i,:) = eye_h_cs_us(i,:)./med_val;
    end
    eye_p_cs_us = (eye_p_cs_us*-1+1)*100;    
    median_cs_us = nanmedian(eye_p_cs_us,2);    
end
