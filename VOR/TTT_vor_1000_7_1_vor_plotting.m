function TTT_vor_1000_7_1_vor_plotting()

%% plot gains.
sheet_name = ['VOR_Gain'];
is_save_fig = 1;
is_save_svg = 1;
% save_excel_path = 'D:\Syt7_m861_m862_m864\m861\plot_20221205_184027.xlsx';
% save_excel_path = 'D:\Syt7_m861_m862_m864_2nd_Rp\m861\plot_20221205_193545.xlsx';

% save_excel_path = 'D:\Syt7_m861_m862_m864\m862\plot_20221206_163953.xlsx';
% save_excel_path = 'D:\Syt7_m861_m862_m864\m864\plot_20221206_161829.xlsx';

save_excel_path = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO_m831_m834\m831\plot_20221106_101102.xlsx';

[~,~,excel_raw] = xlsread(save_excel_path,sheet_name);

y_label = 'Gain';
title_in = 'VOR_Gain';
start_x_coor = 1;
is_header_xlabel = 1;
figure('color',[1 1 1]); ax1 = gcf;
[fig] = TTTH_plot_box_from_cell_ver3(ax1, excel_raw, [], [], [],title_in, y_label, start_x_coor, is_header_xlabel);

% axis tight;
ylim([-0.2 1.5]);
fig.Position = [100 100 2600 1700];

%% plot phase: Need to revise.
fig1 = figure('color',[1 1 1],'position',[100 100 600 500]);
phase_diff = vor_tb.phase_diff;
idx = phase_diff<-60;
phase_diff(idx) = phase_diff(idx)+360;
xx = 1:length(phase_diff);
plot(xx,phase_diff,'-ok');
set(gca,'fontsize',7);
ylabel('Phase difference','fontsize',20);
xticks(xx);
set(gca,'TickLabelInterpreter','none');
xticklabels(x_label);
xtickangle(45);
box off;
ylim([-60 200]);

yyaxis right;
plot(xx,vor_tb.gain_median,'-o');
ylabel('Gain','fontsize',20);
box off;


end