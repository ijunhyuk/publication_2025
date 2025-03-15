function TTT_eyeb100_5_2_plot_eyeB_st(eyeB_st, ax1, is_perc_plot)
% manual parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot for absolute amplitude
px_y_lim = [-120 0];

%plot for normalized amplitude
perc_y_lim = [-50 180];
perc_y_tick = [0 100];
y_cs_bar = 130; clr_cs_bar = [1 0 0];
y_us_bar = 150; clr_us_bar = [0 0 1];
bar_height = 20;
is_draw_puff_moment = 1;
puff_residual_time = 0.03; %sec. the time still can see hair is puffed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

if isempty(is_perc_plot)
    is_perc_plot = 0;
end
xx = eyeB_st.xx_sec - eyeB_st.cs_start_end_sec(1);
vi_fr = eyeB_st.vi_hz;

base_s = eyeB_st.baseline_time(1)*vi_fr+1;
base_e = eyeB_st.baseline_time(2)*vi_fr;
cs_s = eyeB_st.cs_start_end_sec(1)*vi_fr+1;
cs_e = eyeB_st.cs_start_end_sec(2)*vi_fr;
us_s = eyeB_st.us_start_end_sec(1)*vi_fr+1;
us_e = eyeB_st.us_start_end_sec(2)*vi_fr;

% full close time: the time right after the puff garantee full close.
full_close_s = us_e + round(puff_residual_time*vi_fr);
full_close_e = full_close_s + round(puff_residual_time*vi_fr);

eye_h_cs_us = eyeB_st.eye_h_cs_us;
eye_h_cs_only = eyeB_st.eye_h_cs_only;

if ~is_draw_puff_moment
    puff_effect_time_idx = us_s:(us_e + round(puff_residual_time*vi_fr));
    eye_h_cs_us(puff_effect_time_idx,:) = nan;
%     eye_h_cs_only(us_s:us_e,:) = nan;
end
median_cs_us = eyeB_st.median_cs_us;
median_cs_only = eyeB_st.median_cs_only;
clr_cs_us = eyeB_st.clr_cs_us;
clr_cs_only = eyeB_st.clr_cs_only;
clr_cs_us_ind = min(clr_cs_us+0.4, [1 1 1]);
clr_cs_only_ind = min(clr_cs_only+0.4, [1 1 1]);


if is_perc_plot==0
    plot(ax1,xx,eye_h_cs_us,'color',clr_cs_us_ind);
    plot(ax1,xx,eye_h_cs_only,'color',clr_cs_only_ind);
    plot(ax1,xx,median_cs_us,'color',clr_cs_us,'linewidth',2);
    plot(ax1,xx,median_cs_only,'color',clr_cs_only,'linewidth',2);    
    ylabel('Eye Height (px)');
    ylim(px_y_lim);
elseif is_perc_plot==1
    %cla;
    
    %when full close still there is distance between upper lid and lower
    %lid. offset it.
    full_close_amp = nanmedian(nanmedian(eye_h_cs_us([full_close_s:full_close_e],:),1),2);
    eye_h_cs_us = eye_h_cs_us - full_close_amp;
    eye_h_cs_only = eye_h_cs_only - full_close_amp;
    
    [eye_p_cs_us, median_cs_us] = convert_to_perc(eye_h_cs_us, base_s, base_e);
    [eye_p_cs_only, median_cs_only] = convert_to_perc(eye_h_cs_only, base_s, base_e);    
%     median_cs_us = nanmedian(eye_p_cs_us,2); 
%     median_cs_only = nanmedian(eye_p_cs_only,2); 
        
    plot(ax1,xx,eye_p_cs_us,'color',clr_cs_us_ind);
    plot(ax1,xx,eye_p_cs_only,'color',clr_cs_only_ind);
    plot(ax1,xx,median_cs_us,'color',clr_cs_us,'linewidth',2);
    plot(ax1,xx,median_cs_only,'color',clr_cs_only,'linewidth',2);    
%     ylabel(['Normalized ' newline 'Eye Closure (%)']);
    ylabel(['Normalized Eye Closure (%)']);
    ylim(perc_y_lim);
    yticks(perc_y_tick);
    
    %plot cs, us
    xx_cs_s = xx(1) + eyeB_st.cs_start_end_sec(1);
    xx_cs_e = xx(1) + eyeB_st.cs_start_end_sec(2);
    xx_us_s = xx(1) + eyeB_st.us_start_end_sec(1);
    xx_us_e = xx(1) + eyeB_st.us_start_end_sec(2);
    %cs
    rect_x = [xx_cs_s;xx_cs_e;xx_cs_e;xx_cs_s]; rect_y = [y_cs_bar; y_cs_bar; y_cs_bar+bar_height; y_cs_bar+bar_height];
    patch(rect_x,rect_y,clr_cs_bar,'EdgeColor','none','facealpha',0.8);
    text(xx(1)+0.1,rect_y(1)+bar_height/2,'CS','color',clr_cs_bar);
    %us
    rect_x = [xx_us_s;xx_us_e;xx_us_e;xx_us_s]; rect_y = [y_us_bar; y_us_bar; y_us_bar+bar_height; y_us_bar+bar_height];
    patch(rect_x,rect_y,clr_us_bar,'EdgeColor','none','facealpha',0.8);
    text(xx(1)+0.1,rect_y(1)+bar_height/2,'US','color',clr_us_bar);
    
    if ~is_draw_puff_moment
        %puff effect time
        puff_effect_time = [xx_us_s xx_us_e+puff_residual_time];
        plot([puff_effect_time(1) puff_effect_time(1)],[perc_y_lim(1) perc_y_lim(2)],'--','color',clr_us_bar);
        plot([puff_effect_time(2) puff_effect_time(2)],[perc_y_lim(1) perc_y_lim(2)],'--','color',clr_us_bar);        
    end
elseif is_perc_plot==2 || is_perc_plot==3 %different colors for different 1-110 trials.
    %cla;
    
    if is_perc_plot==2 %plot cs only
        n = size(eye_h_cs_only,2);
        temp_col = (n:-1:1)';
        temp_col2 = (1:n)';
        temp_zero = (1:n)'*0;
        
        col_arr = [temp_col temp_zero temp_col2]/n;
        %red: early trials, blue: late trials
        for i=1:n
            plot(ax1,xx,eye_h_cs_only(:,i),'color',col_arr(i,:)); hold on;
        end
    elseif is_perc_plot==3 %plot cs-us
        n = size(eye_h_cs_us,2);
        temp_col = (n:-1:1)';
        temp_col2 = (1:n)';
        temp_zero = (1:n)'*0;
        
        col_arr = [temp_col temp_zero temp_col2]/n;
        for i=1:n
            plot(ax1,xx,eye_h_cs_us(:,i),'color',col_arr(i,:)); hold on;
        end
    end
    ylabel('Eye Height (px)');
    ylim(px_y_lim);
 
end
xlabel('(sec)');
end

function [eye_p_cs_us, median_cs_us] = convert_to_perc(eye_h_cs_us, base_s, base_e, full_close_amp)
    eye_p_cs_us = eye_h_cs_us;
    med_val = nanmedian(eye_h_cs_us([base_s:base_e],:),1);
    for i=1:size(eye_h_cs_us,1)
        eye_p_cs_us(i,:) = eye_h_cs_us(i,:)./med_val;
    end
    eye_p_cs_us = (eye_p_cs_us*-1+1)*100;    
    median_cs_us = nanmedian(eye_p_cs_us,2);    
end