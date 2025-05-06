function [ax1] = TTTH_plot_box_from_cell_ver3(ax1, cell, jpg_path, y_lim, fig_size, title_in, y_label, start_x_coor, is_header_xlabel)
%%%%%%%%%%%%% style options %%%%%%%%%%%%%%%%%%%
%Plot style:
%1: box fill, scatter empty
%2: box empty, scatter fill
%3: box fill(light), scater outline colored.
% plot_style = 1; 
% plot_style = 2; 
plot_style = 3; 

box_line_width = 0.75;
box_line_width_for_paired_plot = 1.5;
box_line_color = [0 0 0];
box_face_alpha = 0.6; %only when plot_style==1.

if contains(title_in,'VOR_')
    scatter_size = 5;
else
    scatter_size = 40;
end
scatter_jitter = 0.2;
% scatter_edge_color = [0.2 0.2 0.2];
scatter_edge_color = [0 0 0];
scatter_face_alpha = 0.7; %only when plot_style==2.
scatter_line_width=1.4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    raw = cell;
    fig_titles = raw(1,2:end);
    bar_colors = cell2mat(raw(2:4, 2:end))/255;
    excel_data = raw(5:end, 2:end);
    f_paired = 0;
    if ~isnan(raw{1,1})
        
        % 20220324. temporarily commented
%         if strcmp(strtrim(raw{1,1}),'paired_plot')
%             f_paired = 1;
%             box_line_width = box_line_width_for_paired_plot;
%         end
        if strcmp(strtrim(raw{1,1}),'paired_plot2')
            f_paired = 1;
            box_line_width = box_line_width_for_paired_plot;
        end
        
    else
        f_paired = 0;
    end
    
    axes(ax1);
%     hold on;
    if isempty(fig_size)
%         [figure1] = figure('Color',[1 1 1]);
    else
%         [figure1] = TTTH_initiate_figure(fig_size,1);
        fig1 = gcf;
        fig1.Position = fig_size;
    end
    
    if isempty(start_x_coor)
        col_count = 0;
    else
        col_count = start_x_coor-1;
    end
    max_val = NaN;
    min_val = NaN;
        
% %     v_arr = Violin.empty;
%     v_arr = Violin_JL.empty;
    x_rand_mem = [];
    y_data_mem = [];
    
    x_ticks = [];
    x_labels = {};
    for i=1:size(excel_data,2)
        %if the header name is 'meta', skip.
        if contains(strtrim(fig_titles{i}),'meta')
            continue;
        end
        if contains(fig_titles{i},'empty')
            x_labels{end+1} = 'space';
        else
            x_labels{end+1} = fig_titles{i};
        end
        col_count = col_count + 1;
        
        %for paired plot
        cur_data = [excel_data{:,i}]';
        cur_data(isnan(cur_data))=[];
        if isempty(cur_data)
            %for paired plotting
            if f_paired
                if ~isempty(x_rand_mem)
                    hold on;
                    for k=1:size(x_rand_mem,1)
%                         H = plot(x_rand_mem(k,:),y_data_mem(k,:),'o-','Color',cc,...
%                             'MarkerEdgeColor',cc);
                        H = plot(x_rand_mem(k,:),y_data_mem(k,:),'-','Color',cc,...
                            'MarkerEdgeColor',cc);
                    end
                    hold off;
                    %initialize again
                    x_rand_mem = [];
                    y_data_mem = [];
                end
            end
            continue;
        end
        
        
        %         d_med = 0.7;
%         d_box = -1;
%         d_edge = 0;

        box_data = cell2mat(excel_data(:,i));
        box_data(isnan(box_data)) = [];
        cc = bar_colors(:,i)'; % current color
        
%         c_eg = [1 1 1];
%         c_box = max(min(cc+d_box, [1 1 1]),[0 0 0]);
%         c_med = [1 1 1];

        v_median = median(box_data);
        v_mean = mean(box_data,1);
        v_sem = std(box_data,1,1)/sqrt(length(box_data));
        disp(['col ' num2str(col_count) ', n=' num2str(size(box_data,1)) ...
            ', median=' num2str(v_median) ', mean=' num2str(v_mean) ', sem=' num2str(v_sem)]);

        p_box = [];
        hold on; %clf;
        p_box = boxplot(box_data,ones(length(box_data),1) + col_count-1,...
            'color',box_line_color,'MedianStyle','line','Notch','off',...
            'PlotStyle','traditional','Symbol','','Widths',0.7,'positions', col_count);
        
        if plot_style==1
            patch(get(p_box(5),'XData'),get(p_box(5),'YData'),cc,'FaceAlpha',box_face_alpha); %fill the box
            line(get(p_box(6),'XData'),get(p_box(6),'YData'),'linewidth' ,box_line_width,'color',box_line_color);
%             set(gca, 'Children', flipud(get(gca, 'Children')) ); %To bring median line to front.
        elseif plot_style==3
            patch(get(p_box(5),'XData'),get(p_box(5),'YData'),cc,'FaceAlpha',box_face_alpha); %fill the box
            
            %draw median value
%             line(get(p_box(6),'XData'),get(p_box(6),'YData'),'linewidth' ,box_line_width,'color',box_line_color);
            line(get(p_box(6),'XData'),get(p_box(6),'YData'),'linewidth' ,box_line_width*2,'color',[1 1 1]);
%             scatter(mean(get(p_box(6),'XData')),mean(get(p_box(6),'YData')),scatter_size*15,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
%             set(gca, 'Children', flipud(get(gca, 'Children')) ); %To bring median line to front.
        end        
        
        set(gca,'TickDir','out');
        box off;
        set(p_box, 'linewidth' ,box_line_width);
        
        set(p_box(1), 'linestyle' ,'-'); %vertical line to maximum
        set(p_box(2), 'linestyle' ,'-'); %vertical line to minimum
        delete(p_box(3)); %horizontal line for maximum
        delete(p_box(4)); %horizontal line for minimum
        
        p_box_cell{col_count} = p_box;
        
        p_sca = [];
        n=length(box_data);
        range = [-1 1]*scatter_jitter;
        r_val = rand(n,1)*diff(range)+range(1);
        x = repmat(col_count,1,length(cur_data)); %the x axis location
        
        if ~f_paired

        if plot_style==1
            p_sca = scatter(r_val + col_count, box_data, scatter_size, ...
                'MarkerEdgeColor',scatter_edge_color);
%             p_sca.MarkerFaceAlpha = scatter_face_alpha;
        elseif plot_style==2
            p_sca = scatter(r_val + col_count, box_data, scatter_size, ...
                'MarkerFaceColor',cc,'MarkerEdgeColor',scatter_edge_color);
            p_sca.MarkerFaceAlpha = scatter_face_alpha;
        elseif plot_style==3
            p_sca = scatter(r_val + col_count, box_data, scatter_size, ...
                'MarkerEdgeColor',cc,'linewidth',scatter_line_width);
            
%             p_sca = scatter(ones(length(box_data),1) + col_count-1, box_data, scatter_size, ...
%                 'jitter','on','JitterAmount', scatter_jitter,...
%                 'MarkerEdgeColor',cc,'linewidth',scatter_line_width);
%             p_sca.MarkerFaceAlpha = scatter_face_alpha;
        end
        else
            x_rand_mem(:,end+1) = (x+0.2)';
            y_data_mem(:,end+1) = cur_data;
        end
        p_sca_cell{col_count} = p_sca;        
        x_ticks(end+1) = col_count;
    end

    %basic style (it can be defined in detail in TTT_im6_2_3_format_fig().
    %later.
    set(gca,'TickDir','out');
    if is_header_xlabel
        set(gca,'XTick',1:length(x_labels));
        xticklabels(x_labels);
        xtickangle(45);
    else
        set(gca,'XTick',[]);
    end
    
    set(gca,'FontSize',16);
    set(gca,'LineWidth',1.5);
    set(gca,'TickLength',[0.025,0.01]);
    ylabel(y_label,'interpreter','none');
    xlim([0 col_count]);
    if ~isempty(y_lim)
        if y_lim(1) > min_val; y_lim(1)=min_val; end
        if y_lim(2) < max_val; y_lim(2)=max_val; end
        ylim(y_lim);
    else 
        ylim('auto');
    end
%     title(title_in,'interpreter','none');
    disp(['title: ' title_in]);
    %save image
    if ~isempty(jpg_path)
        TTT_p7_3_ver1_save_figure(jpg_path, fig1);
    end
        
end