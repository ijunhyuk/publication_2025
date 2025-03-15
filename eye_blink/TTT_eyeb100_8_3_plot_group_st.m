function [] = TTT_eyeb100_8_3_plot_group_st()
%% plot
close all;

% cs_color = [1 0.5 0];
cs_color = [1 0 0];
us_color = [0 0 0];
fig_position = [100 100 1500 1000];
y_lim = [-20 100];

% LED_color = [1 1 0];
LED_color = [0.5 0.5 0.5];
puff_color = [0.5 0.5 0.5];
is_save_fig = 1;

is_draw_ind_cs_only = 0;
is_draw_ind_cs_us = 0;
% is_draw_ind_cs_only = 1;
% is_draw_ind_cs_us = 1;

drop_box_fo = 'M:\Dropbox (HMS)';

batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO'];
batch_mat_path = [batch_fo '\eye_blink.mat'];
n_day = 9;

group_mat_name = 'eye_blink_group_norm_type1.mat';
font_r = 0.6;
num_column_plot = n_day;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
group_st_path = [batch_fo filesep group_mat_name];
temp = load(group_st_path);
group_st = temp.group_st;
group_names = {group_st.group_name};
group_color = {group_st.group_color};
[fo,fi,ext] = fileparts(group_st_path);

%print mice informations
for i=1:length(group_st)
    cur_group_name = group_st(i).group_name;
    cur_mice_names = group_st(i).mouse_ids;
    disp([cur_group_name ', n=' num2str(length(cur_mice_names))]);
    disp(group_st(i).mouse_ids);
end

% shaded plot. CTR and TKO separately.
fig_1 = figure('color',[1 1 1],'position',fig_position);
r = length(group_st); 
c = num_column_plot;
for group_no=1:length(group_st)
    for day=1:n_day %day=8
        xx = group_st(group_no).xx_sec-0.5;
        pos = c*(group_no-1)+day;
        cur_ax = subplot(r,c,pos);
        hold on;
        val_m = group_st(group_no).cs_us_group_avg(:,day);
        val_s = group_st(group_no).cs_us_group_sem(:,day);
        val_m(isnan(val_m)) = 0;
        val_s(isnan(val_s)) = 0;

        
%         aaa =  group_st.cs_us_mice_median(280:289,:,8);
%         aaa(aaa==inf) = nan
%         std_val = nanstd(aaa,0,2)
        
        ax = cur_ax;

        if is_draw_ind_cs_only
            hold(cur_ax, 'on');
            cs_us_mice_median = group_st(group_no).cs_us_mice_median(:,:,day);
            plot(cur_ax, cs_us_mice_median, 'color', us_color, 'LineWidth', 0.5); % 얇은 선
%             plot(cur_ax, val_m, '--', 'color', us_color, 'LineWidth', 3); % 굵은 선
        else %default.
            [hl, hp] = boundedline(xx, val_m, val_s, ...
                'cmap',us_color,'alpha', ax, 'transparency', 0.2);
        end
        
%     val_data = group_st(group_no).cs_us_mice_median(:,:,day)';        
%     options.handle     = cur_ax;
%     options.color_area = us_color;    % Blue theme
%     options.color_line = us_color;
%     options.alpha      = 0.2;
%     options.line_width = 1;
%     options.error      = 'sem';
%     options.x_axis = xx;
%     plot_areaerrorbar_joon(val_data, options);
       
        val_m = group_st(group_no).cs_only_group_avg(:,day);
        val_s = group_st(group_no).cs_only_group_sem(:,day);
               
        if is_draw_ind_cs_us %is_draw_ind_cs_us = 1
            hold(cur_ax, 'on');
            cs_only_mice_median = group_st(group_no).cs_only_mice_median(:,:,day);            
            plot(cur_ax, cs_only_mice_median, 'color', cs_color, 'LineWidth', 0.5); % 얇은 선
%             plot(cur_ax, val_m, '--', 'color', cs_color, 'LineWidth', 3); % 굵은 선
        else %default.
            [hl, hp] = boundedline(xx, val_m, val_s, ...
                'cmap',cs_color,'alpha', cur_ax, 'transparency', 0.2);            
        end
        
        ylim(y_lim);
        yticks([0 50 100]);
        set(gca,'fontsize',round(20*font_r));
        title([group_names{group_no} ', day' num2str(day)], 'fontsize', round(14*font_r));
        xlabel('(sec)', 'fontsize', round(14*font_r));
        
        if mod(pos,c)==1 %add ylabel only for first column.
            ylabel('Eye closure (%)', 'fontsize', round(20*font_r));
        end
    end
end
group_img_name = 'eye_blink_group_shaded.jpeg';
img_path = [fo filesep group_img_name];
saveas(fig_1, img_path,'jpeg');
if is_save_fig
    fig_name = 'eye_blink_group_shaded.fig';
    fig_path = [fo filesep fig_name];
    saveas(fig_1, fig_path);
end


% shaded plot. CTR vs TKO together.
fig_1 = figure('color',[1 1 1],'position',fig_position);
r = 2; c = num_column_plot;

cur_r = 1;
for day=1:n_day
        xx = group_st(group_no).xx_sec-0.5;
        pos = c*(cur_r-1)+day;
        cur_ax = subplot(r,c,pos);
        hold on;
    for group_no=1:length(group_st)
        
%         val_m = group_st(group_no).cs_us_group_avg(:,day);
%         val_s = group_st(group_no).cs_us_group_sem(:,day);
%         [hl, hp] = boundedline(xx, val_m, val_s, ...
%             'cmap',group_color{group_no},'alpha', cur_ax, 'transparency', 0.2);
        val_m = group_st(group_no).cs_only_group_avg(:,day);
        val_s = group_st(group_no).cs_only_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',group_color{group_no}/255,'alpha', cur_ax, 'transparency', 0.2);
        ylim(y_lim);
        yticks([0 50 100]);
        set(gca,'fontsize',round(20*font_r));
        title(['CTR vs TKO, CS only, day' num2str(day)], 'fontsize', round(14*font_r));
        xlabel('(sec)', 'fontsize', round(14*font_r));
        
        if mod(pos,c)==1 %add ylabel only for first column.
            ylabel('Eye closure (%)', 'fontsize', round(20*font_r));
        end
    end
end
cur_r = 2;
for day=1:n_day
        xx = group_st(group_no).xx_sec-0.5;
        pos = c*(cur_r-1)+day;
        cur_ax = subplot(r,c,pos);
        hold on;
    for group_no=1:length(group_st)
        
        val_m = group_st(group_no).cs_us_group_avg(:,day);
        val_s = group_st(group_no).cs_us_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',group_color{group_no}/255,'alpha', cur_ax, 'transparency', 0.2);
%         val_m = group_st(group_no).cs_only_group_avg(:,day);
%         val_s = group_st(group_no).cs_only_group_sem(:,day);
%         [hl, hp] = boundedline(xx, val_m, val_s, ...
%             'cmap',group_color{group_no}/255,'alpha', cur_ax, 'transparency', 0.2);
        ylim(y_lim);
        yticks([0 50 100]);
        set(gca,'fontsize',round(20*font_r));
        title(['CTR vs TKO, US+CS, day' num2str(day)], 'fontsize', round(14*font_r));
        xlabel('(sec)', 'fontsize', round(14*font_r));
        
        if mod(pos,c)==1 %add ylabel only for first column.
            ylabel('Eye closure (%)', 'fontsize', round(20*font_r));
        end
    end
end
group_img_name = 'eye_blink_group_shaded_CTRvsTKO.jpeg';
img_path = [fo filesep group_img_name];
saveas(fig_1, img_path,'jpeg');
if is_save_fig
    fig_name = 'eye_blink_group_shaded_CTRvsTKO.fig';
    fig_path = [fo filesep fig_name];
    saveas(fig_1, fig_path);
end

% daily stack plot.
fig_1 = figure('color',[1 1 1],'position',fig_position); %cla;
c = 2;
y_base_all = 0;

for group_no=1:length(group_st)
    xx = group_st(group_no).xx_sec-0.5;
    
    % CS+US plot
    pos = c*(group_no-1)+1;
    cur_ax = subplot(1,length(group_st)*c,pos);
    set(gca,'XColor', 'none','YColor','none')
    hold on;
    y_base = y_base_all; increment = 120;
    for day=1:n_day
        val_m = group_st(group_no).cs_us_group_avg(:,day);
        val_m = val_m + y_base;
        val_s = group_st(group_no).cs_us_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',us_color,'alpha', cur_ax, 'transparency', 0.2);
        
        text(-0.8,y_base,['day' num2str(day)],'fontsize',round(20*font_r));
        y_base = y_base + increment;
    end
    line([0 0],[y_base_all y_base],'LineStyle','--','color',LED_color);
    line([0.5 0.5],[y_base_all y_base],'LineStyle','--','color',puff_color);
    
    yticks([]);
    %scale bar
    line([-0.5 -0.5],[-150 -50],'color',[0 0 0]); text(-0.5,-100,['100%'],'fontsize',round(20*font_r));
    line([-0.5 0],[-150 -150],'color',[0 0 0]); text(-0.4,-170,['0.5 sec'],'fontsize',round(20*font_r));
    set(gca,'fontsize',round(20*font_r));
    title([group_names{group_no} ', CS+US'], 'fontsize', round(14*font_r));
    xlabel('(sec)', 'fontsize', round(14*font_r));
    ylim([-200 y_base]);
        
    % CS only plot    
    pos = c*(group_no-1)+2;
    cur_ax = subplot(1,length(group_st)*c,pos);
    set(gca,'XColor', 'none','YColor','none')
    hold on;
    y_base = y_base_all; increment = 120;
    for day=1:n_day
        val_m = group_st(group_no).cs_only_group_avg(:,day);
        val_m = val_m + y_base;
        val_s = group_st(group_no).cs_only_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',cs_color,'alpha', cur_ax, 'transparency', 0.2);
        
        text(-0.8,y_base,['day' num2str(day)],'fontsize',round(20*font_r));
        y_base = y_base + increment;
    end
    line([0 0],[y_base_all y_base],'LineStyle','--','color',LED_color);
    line([0.5 0.5],[y_base_all y_base],'LineStyle','--','color',puff_color);
    
    yticks([]);
    %scale bar
    line([-0.5 -0.5],[-150 -50],'color',[0 0 0]); text(-0.5,-100,['100%'],'fontsize',round(20*font_r));
    line([-0.5 0],[-150 -150],'color',[0 0 0]); text(-0.4,-170,['0.5 sec'],'fontsize',round(20*font_r));
    set(gca,'fontsize',round(20*font_r));
    title([group_names{group_no} ', CS only'], 'fontsize', round(14*font_r));
    xlabel('(sec)', 'fontsize', round(14*font_r));
    ylim([-200 y_base]);
end
group_img_name = 'eye_blink_group_stack.jpeg';
img_path = [fo filesep group_img_name];
saveas(fig_1, img_path,'jpeg');
if is_save_fig
    fig_name = 'eye_blink_group_stack.fig';
    fig_path = [fo filesep fig_name];
    saveas(fig_1, fig_path);
end

disp(['Plot Finished!!!']);
end
