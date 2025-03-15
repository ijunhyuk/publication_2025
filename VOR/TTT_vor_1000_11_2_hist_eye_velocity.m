function [cur_ax] = TTT_vor_1000_11_2_hist_eye_velocity(cur_ax, p_ang_vel)
%% plot histogram of eye velocity (2D, angular velocity)

axis(cur_ax);

% figure();
% histogram(ang_vel);

hist_edge = [0:10:2300];
rgb_total = [0.5 0.5 0.5];
hist_face_alpha = 0.8;
area_normalize = 0;

histf_JH_ver1(p_ang_vel,hist_edge,'facecolor',rgb_total,'FaceAlpha',min([1,hist_face_alpha]),...
    'BarWidth',1,'edgecolor','none','area_normalize',area_normalize);
ylabel('count');

yyaxis right; %plot only above 500 degree/sec.
x_thr = 200;
sac_ang_vel = p_ang_vel(p_ang_vel>x_thr);
rgb_total = [1 0.5 0];
histf_JH_ver1(sac_ang_vel,hist_edge,'facecolor',rgb_total,'FaceAlpha',min([1,hist_face_alpha]),...
    'BarWidth',1,'edgecolor','none','area_normalize',area_normalize);
ylabel('count');

xlabel('Instant angular velocity (degree/sec), 2D');
end
