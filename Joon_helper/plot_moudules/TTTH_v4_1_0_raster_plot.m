function [] = TTTH_v4_1_0_raster_plot(ax, time_stamps_cell, plot_range, marker_length, unit_names)

% time_stamps_cell: each cell element is one demension array (1 x N). each value of the array is time (sec).
% marker_length: the lenght of vertical line.

%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(time_stamps_cell)
    data = time_stamps_cell{i};
    if length(data) > 10000
        disp([num2str(i) 'th data has more than 10000 time stamps. It will take long time to plot it!!! if want, use plot_range option.']);
    end
end
if isempty(marker_length)
    marker_length = 1;
end
if ~isempty(plot_range)
    for i=1:length(time_stamps_cell)
        data = time_stamps_cell{i};
        time_stamps_cell{i} = data(plot_range(1)<=data & data<plot_range(2));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%
y_center = 1;
half_length = marker_length/2;
marker_color = [0 0 0];

ylim(ax, [0 length(time_stamps_cell)+1]);
hold on;
for i=1:length(time_stamps_cell)
    data = time_stamps_cell{i};
    xx = [data; data];
    yy = zeros(2,length(xx))+y_center;
    yy(1,:) = yy(1,:)-half_length;
    yy(2,:) = yy(2,:)+half_length;
    p = plot(ax,xx,yy, 'color',marker_color);
    
    y_center = y_center + 1;
end
hold off;
if ~isempty(unit_names)
    y_ticklabels = unit_names;
else
    y_ticklabels = {};
end
y_tick = 1:length(time_stamps_cell);
set(ax,'ytick',y_tick, 'tickdir','out','yticklabels',y_ticklabels); 

xlabel('Time(sec)');
ylabel('Neurons');

end
