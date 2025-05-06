function TTTH_v6_1_0_adjust_figure_axis
%% see also, TTT_im6_2_3_format_fig(fig, sheetname)

%% access multiple axis handles in the figure.
ax_all = findall(fig1,'type','axes');

%% Exmaples.
fig.Position = [100 100 250 200];
title('','interpreter','none');
yticks([0 5 10 15]);
yticklabels({'0','','','15'});

set(gca,'TickLength',[0.025,0.01]);
h_ylab = ylabel('#Paw Slips');
h_ylab.Position(1) = -0.2; % like data coordi.
y_tick = yticks;
h_ylab.Position(2) = y_tick(end)/2; % like data coordi.

set(gca,'LineWidth',0.75);
set(gca,'TickDir','out');

ax = gca;

cur_ax.OuterPosition = [0.1 0.1 0.9 0.9];
cur_ax.YLabel.FontSize = 14;
cur_ax.YLabel.Position(1) = -1;

cur_ax.XRuler.TickLabelGapOffset = -8;     % negative numbers move the ticklabels up (positive -> down)
cur_ax.YRuler.TickLabelGapOffset = -8;    % negative numbers move the ticklabels right (negative -> left)

%%



end