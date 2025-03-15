function [ax] = TTT_vor_1000_11_1_hist_eye_velocity(ax, dlc_st, radius_pupil, v_fr)
%% plot histogram of eye velocity (2D, angular velocity)

pupil_center_x = (dlc_st.pupil_left.x + dlc_st.pupil_right.x)/2;
pupil_center_y = (dlc_st.pupil_left.y + dlc_st.pupil_right.y)/2;

pupil_center_2d_diff = sqrt(diff(pupil_center_x).^2 + diff(pupil_center_y).^2);
pupil_center_2d_diff = [0; pupil_center_2d_diff];

[p_diff_ang] = TTT_vor_1000_12_1_convert_px_to_ang_value(pupil_center_2d_diff, radius_pupil);
ang_vel = p_diff_ang*v_fr;

axis(ax);

% figure();
% histogram(ang_vel);

hist_edge = [0:10:2300];
rgb_total = [0.5 0.5 0.5];
hist_face_alpha = 0.8;
area_normalize = 0;

histf_JH_ver1(ang_vel,hist_edge,'facecolor',rgb_total,'FaceAlpha',min([1,hist_face_alpha]),...
    'BarWidth',1,'edgecolor','none','area_normalize',area_normalize);
ylabel('count');

yyaxis right; %plot only above 500 degree/sec.
x_thr = 200;
sac_ang_vel = ang_vel(ang_vel>x_thr);
rgb_total = [1 0.5 0];
histf_JH_ver1(sac_ang_vel,hist_edge,'facecolor',rgb_total,'FaceAlpha',min([1,hist_face_alpha]),...
    'BarWidth',1,'edgecolor','none','area_normalize',area_normalize);
ylabel('count');

xlabel('Instant angular velocity (degree/sec), 2D');
end
