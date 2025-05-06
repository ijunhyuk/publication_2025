function [figure1] = TTTH_plot_violin_from_cell(cell, jpg_path, y_lim, fig_size, y_label)
% http://www.stat.cmu.edu/~rnugent/PCMI2016/papers/ViolinPlots.pdf

% y_lim = [0 100];
% fig_size = [50 50 46.5 42];

v_trans = 0.6;
% if most left-upper cell is 'paired_plot', then it draws paired plot.

%설정값끝.%%%%%%%%%%%%%%%%%%%%%%%% 

    raw = cell;
    fig_titles = raw(1,2:end);
    bar_colors = cell2mat(raw(2:4, 2:end))/255;
    excel_data = raw(5:end, 2:end);
    if ~isnan(raw{1,1})
        if strcmp(strtrim(raw{1,1}),'paired_plot')
            f_paired = 1;
        end
    else
        f_paired = 0;
    end
    
    if isempty(fig_size)
        [figure1] = figure('Color',[1 1 1]);
    else
        [figure1] = TTT_p3_3_ver1_initiate_figure(fig_size,1);
    end
    
    col_count = 0;
    max_val = NaN;
    min_val = NaN;
        
%     v_arr = Violin.empty;
    v_arr = Violin_JL.empty;
    
    for i=1:size(excel_data,2)
        %if the header name is 'meta', skip.
        if contains(strtrim(fig_titles{i}),'meta')
            continue;
        end
        if contains(strtrim(fig_titles{i}),'empty')
            col_count = col_count + 1;
            continue;
        end
        
        col_count = col_count + 1;
        d_med = 0.7;
        d_box = -1;
        d_edge = 0;

        violin_data = cell2mat(excel_data(:,i));
        violin_data(isnan(violin_data)) = [];
        cc = bar_colors(:,i)'; % current color
        c_eg = [1 1 1];
        c_box = max(min(cc+d_box, [1 1 1]),[0 0 0]);
        c_med = [1 1 1];

        v_median = median(violin_data);
        v_mean = mean(violin_data,1);
        v_sem = std(violin_data,1,1)/sqrt(length(violin_data));
        disp(['col ' num2str(col_count) ', n=' num2str(size(violin_data,1)) ...
            ', median=' num2str(v_median) ', mean=' num2str(v_mean) ', sem=' num2str(v_sem)]);
        v_arr(end+1) = Violin_JL(violin_data,col_count, ...
            'ViolinColor', cc,'ViolinAlpha',v_trans, ...
            'EdgeColor', c_eg,'BoxColor', c_box, ...
            'MedianColor', c_med, 'BoxWidth', 0.07, ...
            'ShowNotches', false,'ShowMean', false);

    end

%     violinplot(v_arr);

    set(gca,'TickDir','out');

    % tick_len = get(gca,'TickLength');
    % set(gca,'XTick',[1:length(fig_titles)],'TickLength', [0 0]);
    % set(gca,'XTickLabel',fig_titles);
    set(gca,'XTick',[]);
    set(gca,'FontSize',20);
    ylabel(y_label,'interpreter','none');
    xlim([0 col_count]);
    if ~isempty(y_lim)
        if y_lim(1) > min_val; y_lim(1)=min_val; end
        if y_lim(2) < max_val; y_lim(2)=max_val; end
        ylim(y_lim);
    end
%     title(title_in,'interpreter','none');
    
    %save image
    if ~isempty(jpg_path)
        TTT_p7_3_ver1_save_figure(jpg_path, figure1);
    end
end