function [dlc_st, inst_ang_vel] = TTT_vor_1000_10_1_filter_dlc(dlc_st, likelihood_thr)
%%
% filter sudden mis-detections.
% in freely moving mice, the eye pupil velocity does not exceed 2300 degree/sec (Sakatani and Isa, 2007).
% in our setup, the pupil cannot move 19.93 pixel per frame (which is 2300
% degree/sec in conservative way assuming the pupil size is minimum).
% So, if cr is moved more than 20 pixels next frame, and if likelihood value
% is more than 'likelihood_thr:0.9', it is false-positive.
% Replace the wrong coordinates to the previous coordinates.


% %% test calculation.
% radius_pupil = 100; %80-100. maximum is around 100 when pupil size is minimum.
% angle_speed = 2300;%degree
% px_move = 20;
% 
% sind(angle_speed/200)*radius_pupil = px_move
% angle_speed = asind(px_move/radius_pupil)*200;

px_move_thr = 20;
max_estimate_frames = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dlc_st.pupil_left = filter_inner(dlc_st.pupil_left, px_move_thr, likelihood_thr, max_estimate_frames);
dlc_st.pupil_right = filter_inner(dlc_st.pupil_right, px_move_thr, likelihood_thr, max_estimate_frames);
dlc_st.pupil_upper = filter_inner(dlc_st.pupil_upper, px_move_thr, likelihood_thr, max_estimate_frames);
dlc_st.pupil_lower = filter_inner(dlc_st.pupil_lower, px_move_thr, likelihood_thr, max_estimate_frames);
dlc_st.cr = filter_inner(dlc_st.cr, px_move_thr, likelihood_thr, max_estimate_frames);

end

function cur = filter_inner(cur, px_move_thr, likelihood_thr, max_estimate_frames)
% condition1: the distance between good_base and current postion
% become less than px_move_thr.
% or, condition2: the current point is moved from wrong_base more
% than px_move_thr.
p_diff_xy = sqrt(diff(cur.x).^2 + diff(cur.y).^2);
p_diff_xy = ([0; p_diff_xy]);

mask_diff = p_diff_xy > px_move_thr;
mask_likeli = cur.likelihood > likelihood_thr;
idx = find(mask_diff & mask_likeli);
pos = 0;
for i=1:length(idx)
    if idx(i)>pos %skip if this pos is already done.
        pos = idx(i);
        
        good_base_x = cur.x(pos-1);
        good_base_y = cur.y(pos-1);
        wrong_base_x = cur.x(pos);
        wrong_base_y = cur.y(pos);
        go_f = 1;
        count = 1;
        while go_f
            cur.x(pos) = cur.x(pos-1);
            cur.y(pos) = cur.y(pos-1);
            cur.likelihood(pos) = cur.likelihood(pos-1);
            
            %check next point
            pos = pos + 1;
            dist_from_good_base = sqrt( (good_base_x-cur.x(pos))^2 + (good_base_y-cur.y(pos))^2);            
            if dist_from_good_base <= px_move_thr || ... %if the detection point come back to correct position.
                    count > max_estimate_frames %if more than 10 frames were wrongly detected, then stop to estimate.
                go_f = 0;
            end
            count = count + 1;
        end
    end
end

% figure();
% plot(p_diff_xy); ylim([0 30]);
% yyaxis right;
% plot(cur.x);hold on;
% plot(cur.y);hold on;
% plot(cur.likelihood);

end