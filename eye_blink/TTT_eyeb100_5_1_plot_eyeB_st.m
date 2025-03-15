function TTT_eyeb100_5_1_plot_eyeB_st(eyeB_st, ax1)
% manual parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
px_y_lim = [-120 0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
xx = eyeB_st.xx_sec;
eye_h_cs_us = eyeB_st.eye_h_cs_us;
eye_h_cs_only = eyeB_st.eye_h_cs_only;
median_cs_us = eyeB_st.median_cs_us;
median_cs_only = eyeB_st.median_cs_only;
clr_cs_us = eyeB_st.clr_cs_us;
clr_cs_only = eyeB_st.clr_cs_only;
clr_cs_us_ind = min(clr_cs_us+0.4, [1 1 1]);
clr_cs_only_ind = min(clr_cs_only+0.4, [1 1 1]);

plot(ax1,xx,eye_h_cs_us,'color',clr_cs_us_ind);
plot(ax1,xx,eye_h_cs_only,'color',clr_cs_only_ind);
plot(ax1,xx,median_cs_us,'color',clr_cs_us,'linewidth',2);
plot(ax1,xx,median_cs_only,'color',clr_cs_only,'linewidth',2);

ylim(px_y_lim);
xlabel('(sec)');
ylabel('Eye Height (px)');

end