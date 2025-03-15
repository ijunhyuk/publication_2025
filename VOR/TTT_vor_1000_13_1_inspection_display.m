function TTT_vor_1000_13_1_inspection_display()
%% 
dropbox_fo = 'M:\Dropbox (HMS)';
save_fo = [dropbox_fo '\Research_RegehrLAB\Analysis\result_obj\plot_excel'];

vor_mat_fo_arr = {};
% vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch1-2\m1051\day1';
% vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch1-2\m1052\day1';
% vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch1-2\m1053\learning_day1';
% vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch1-2\m1055\learning_day1';
% vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch3\m1111\day1';
% vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO\PC_TKO_batch3\m1114\day1';

vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO\a6_TKO_batch1\m1014\20230706_performance';
vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO\a6_TKO_batch1\m1018\20230706_performance';
vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO\a6_TKO_batch2\m1023\0_motor_performance';
vor_mat_fo_arr{end+1} = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO\a6_TKO_batch2\m1026\0_motor_performance';


search_pattern = '*0_2Hz_OKR*.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f=1:length(vor_mat_fo_arr)
    cccc;
    vor_mat_fo = vor_mat_fo_arr{f};
    tok = strsplit(vor_mat_fo,filesep);
    save_img_name = [save_fo filesep 'vel_eye_stim_peak_' tok{end-1} '_' tok{end} '.jpg'];
    file_list = TTTH_search_all_files(vor_mat_fo,0,search_pattern);
    
    fig1 = figure('color',[1,1,1],'position',[100,100,2000,1800]);
    n_mat = length(file_list);
    for i=1:n_mat
        ax = subplot(n_mat,10,(i-1)*10+(1:9));
        [xx_peak, peak_val] = TTT_vor_1000_7_2_plot_vel_eye_stim_peak_gain(ax, file_list{i});
        
        ax2 = subplot(n_mat,10,(i-1)*10+10);
        xx = rand(1,length(peak_val));
        plot(xx, peak_val, 'o', 'color', 'magenta');
        box off;
        xlim([-1 2]);
        ylim([-45 45]);
        xticklabels({});
        ylabel('Velocities at peak gains');
    end
    saveas(fig1, save_img_name);    
end
%%


end
