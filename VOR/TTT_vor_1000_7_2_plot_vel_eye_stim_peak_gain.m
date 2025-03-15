function [xx_peak, peak_val] = TTT_vor_1000_7_2_plot_vel_eye_stim_peak_gain(ax, mat_path)
is_down_sample = 1;
down_nth = 10; % only choose every n th element.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tok = strsplit(mat_path,filesep);
data_fo = strjoin(tok(1:end-4),filesep);
middle_fo = strjoin(tok(end-3:end-1),filesep);
mat_filename = tok{end};

vor_trial = load(mat_path);
vor_trial = vor_trial.vor_trial;

fr = vor_trial.protocol_param.cam_command.camclk_freq;
p_ang_vel_filterd = vor_trial.p_ang_vel_filterd;
xx_sec = [1:length(p_ang_vel_filterd)]/fr;

xx_peak = vor_trial.peak_gain_smoothed_xy(:,1);
peak_vals = vor_trial.peak_gain_smoothed_xy(:,2);

if ~isempty(vor_trial.table_vel_interpol)
    stim_vel_interpol = vor_trial.table_vel_interpol;
else
    stim_vel_interpol = vor_trial.vis_vel_interpol;
end

p_ang_vel_filterd = vor_trial.p_ang_vel_filterd;
if is_down_sample
    xx_sec = downsample(xx_sec, down_nth);
    stim_vel_interpol = downsample(stim_vel_interpol, down_nth);
    p_ang_vel_filterd = downsample(p_ang_vel_filterd, down_nth);
end

peak_val = vor_trial.p_ang_vel_filterd(round(xx_peak*fr));
axes(ax);
hold on;
% plot(xx_sec, vor_trial.table_vel,'k');
plot(xx_sec, stim_vel_interpol,'k');
plot(xx_sec, p_ang_vel_filterd,'b');
plot(xx_peak, peak_val,'magenta*');
for i=1:length(xx_peak)
    xline(xx_peak(i),'--','color',[0.5,0.5,0.5]);
end
axis tight;
ylim([-45 45]);
title([middle_fo mat_filename]);
xlabel('(sec)');
ylabel('Velocity (ang/sec)');

end