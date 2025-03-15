function [] = TTT_eyeb100_8_5_plot_group_st_temp()
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

% drop_box_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';
drop_box_fo = 'G:\Dropbox_joon\Dropbox (HMS)';

batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1-2'];
batch_mat_path = [batch_fo '\eye_blink_batch1-2.mat'];
n_day = 8;

% batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\a6_TKO'];
% batch_mat_path = [batch_fo '\eye_blink_batch1-2.mat'];
% n_day = 8;

% batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO'];
% batch_mat_path = [batch_fo '\eye_blink_batch1-2.mat'];
% n_day = 8;

% batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\WildType\m1067-m1070'];
% batch_mat_path = [batch_fo '\eye_blink.mat'];
% n_day = 6;

group_mat_name = 'eye_blink_group_type1.mat';
font_r = 0.6;
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
c = 10;
for group_no=1
    for day=[1 2 4 8]
        cs_color =[0 0 0];
        
        xx = group_st(group_no).xx_sec-0.5;
        pos = c*(group_no-1)+day;
        cur_ax = subplot(r,c,[1 2 3]);
        hold on;
%         val_m = group_st(group_no).cs_us_group_median(:,day);
%         val_s = group_st(group_no).cs_us_group_sem(:,day);
%         [hl, hp] = boundedline(xx, val_m, val_s, ...
%             'cmap',us_color,'alpha', cur_ax, 'transparency', 0.2);
        val_m = group_st(group_no).cs_only_group_median(:,day);
        val_s = group_st(group_no).cs_only_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',cs_color,'alpha', cur_ax, 'transparency', 0.2);
        ylim(y_lim);
        yticks([0 50 100]);
        set(gca,'fontsize',round(20*font_r));
%         title([group_names{group_no} ', day' num2str(day)], 'fontsize', round(14*font_r));
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
r = 2; c = 10;

cur_r = 1;
for day=1:n_day
        xx = group_st(group_no).xx_sec-0.5;
        pos = c*(cur_r-1)+day;
        cur_ax = subplot(r,c,pos);
        hold on;
    for group_no=1:length(group_st)
        
%         val_m = group_st(group_no).cs_us_group_median(:,day);
%         val_s = group_st(group_no).cs_us_group_sem(:,day);
%         [hl, hp] = boundedline(xx, val_m, val_s, ...
%             'cmap',group_color{group_no},'alpha', cur_ax, 'transparency', 0.2);
        val_m = group_st(group_no).cs_only_group_median(:,day);
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
        
        val_m = group_st(group_no).cs_us_group_median(:,day);
        val_s = group_st(group_no).cs_us_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',group_color{group_no}/255,'alpha', cur_ax, 'transparency', 0.2);
%         val_m = group_st(group_no).cs_only_group_median(:,day);
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
% r = length(group_st); 
c = 2;
for group_no=1:length(group_st) %group_no=2
    xx = group_st(group_no).xx_sec-0.5;
    
    pos = c*(group_no-1)+1;
    cur_ax = subplot(1,length(group_st)*c,pos);
    set(gca,'XColor', 'none','YColor','none')
    hold on;
    y_base = 0; increment = 120;
    for day=1:n_day
        val_m = group_st(group_no).cs_us_group_median(:,day);
        val_m = val_m + y_base;
        val_s = group_st(group_no).cs_us_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',us_color,'alpha', cur_ax, 'transparency', 0.2);

%         val_m = group_st(group_no).cs_only_group_median(:,day);
%         val_m = val_m + y_base;
%         val_s = group_st(group_no).cs_only_group_sem(:,day);
%         [hl, hp] = boundedline(xx, val_m, val_s, ...
%             'cmap',cs_color,'alpha', cur_ax, 'transparency', 0.2);
        
        text(-0.8,y_base,['day' num2str(day)],'fontsize',round(20*font_r));
        y_base = y_base + increment;
    end
    line([0 0],[0 y_base],'LineStyle','--','color',LED_color);
    line([0.5 0.5],[0 y_base],'LineStyle','--','color',puff_color);
    
    yticks([]);
    %scale bar
    line([-0.5 -0.5],[-150 -50],'color',[0 0 0]); text(-0.5,-100,['100%'],'fontsize',round(20*font_r));
    line([-0.5 0],[-150 -150],'color',[0 0 0]); text(-0.4,-170,['0.5 sec'],'fontsize',round(20*font_r));
    set(gca,'fontsize',round(20*font_r));
    title([group_names{group_no} ', CS+US'], 'fontsize', round(14*font_r));
    xlabel('(sec)', 'fontsize', round(14*font_r));

        
        
    pos = c*(group_no-1)+2;
    cur_ax = subplot(1,length(group_st)*c,pos);
    set(gca,'XColor', 'none','YColor','none')
    hold on;
    y_base = 0; increment = 120;
    for day=1:n_day
%         val_m = group_st(group_no).cs_us_group_median(:,day);
%         val_m = val_m + y_base;
%         val_s = group_st(group_no).cs_us_group_sem(:,day);
%         [hl, hp] = boundedline(xx, val_m, val_s, ...
%             'cmap',us_color,'alpha', cur_ax, 'transparency', 0.2);

        val_m = group_st(group_no).cs_only_group_median(:,day);
        val_m = val_m + y_base;
        val_s = group_st(group_no).cs_only_group_sem(:,day);
        [hl, hp] = boundedline(xx, val_m, val_s, ...
            'cmap',cs_color,'alpha', cur_ax, 'transparency', 0.2);
        
        text(-0.8,y_base,['day' num2str(day)],'fontsize',round(20*font_r));
        y_base = y_base + increment;
    end
    line([0 0],[0 y_base],'LineStyle','--','color',LED_color);
    line([0.5 0.5],[0 y_base],'LineStyle','--','color',puff_color);
    
    yticks([]);
    %scale bar
    line([-0.5 -0.5],[-150 -50],'color',[0 0 0]); text(-0.5,-100,['100%'],'fontsize',round(20*font_r));
    line([-0.5 0],[-150 -150],'color',[0 0 0]); text(-0.4,-170,['0.5 sec'],'fontsize',round(20*font_r));
    set(gca,'fontsize',round(20*font_r));
    title([group_names{group_no} ', CS only'], 'fontsize', round(14*font_r));
    xlabel('(sec)', 'fontsize', round(14*font_r));
        
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
