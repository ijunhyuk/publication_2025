function [r, p, regress_b, reg_x, reg_y, p_scatter, p_reg_line] = TTT_vor_1000_5_1_plot_rp(ax, rp_arr)
%%
x_lim = [40 250]; %to plot, max and min size of pupil pixel
y_lim = [40 160]; %to plot, max and min size of Rp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plotting
% axes(ax);
if isempty(rp_arr)
    disp(['Table is empty!!!']); return;
end
p_scatter = plot(ax, rp_arr(:,1),rp_arr(:,2),'ok');
xlim(x_lim);
ylim(y_lim);
xlabel('Pupil diameter (px)'); ylabel('Rp (px)');
%write numbers
off_x = 2; off_y = -2;
for i=1:size(rp_arr,1)
    text(rp_arr(i,1)+off_x,rp_arr(i,2)+off_y,num2str(i),'FontSize',10,'color','b');
end
box off;
if size(rp_arr,1) > 1
    %regression
    axes_cur = gca;
    line_color = [1 0 0];
    is_plot_regression = 1;
    is_plot_scatter = 1;
    [r, p, regress_b, reg_x, reg_y, ~, p_reg_line]= TTTH_v2_2_1_regression(axes_cur, rp_arr, line_color, is_plot_regression, 0);
end

end