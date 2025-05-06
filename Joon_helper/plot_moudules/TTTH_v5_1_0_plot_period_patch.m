function [cur_ax] = TTTH_v5_1_0_plot_period_patch(cur_ax, move_xx_sec, is_move_mask, y_val, patch_height, patch_color, face_alpha)
% mark (patch) where movement happens by using movement mask.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis(cur_ax);

is_move = [0; is_move_mask]; %add non-move points at first/last
is_move(end) = 0; %add non-move points last

diff_move = diff(is_move);
idx_move_on = find(diff_move==1);
idx_move_off = find(diff_move==-1);

bin_tp = [move_xx_sec(idx_move_on)', move_xx_sec(idx_move_off)'];

y1 = y_val;
% y2 = y_val + patch_height;

for i=1:size(bin_tp,1)
    x1 = bin_tp(i,1);
    x2 = bin_tp(i,2);
    rectangle('Position', [x1, y1, x2-x1, patch_height], 'FaceColor', [patch_color face_alpha], ...
        'EdgeColor', 'none');
end



end
